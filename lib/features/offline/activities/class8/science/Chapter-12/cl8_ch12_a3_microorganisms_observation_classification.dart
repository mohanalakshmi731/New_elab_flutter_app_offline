// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 12.3: Microorganisms - Observation and Classification
// Converted from Cl8S-Ch12-A3-microorganisms-observation-and-classification
// .html (three.js r128 + tween.js -> mini3d).
//
// Five scenarios picked from the sidebar, each opened by a chalkboard:
// (1) Pond water - collect a sample with the dropper, put a drop on the
// slide, lower the coverslip at 45 degrees, focus the microscope and label
// Amoeba and Paramecium; (2) Soil suspension - pour water, stir, let it
// settle, sample the clear top layer and classify mould and bacteria under
// the microscope; (3) Viruses - check the inert virus, bring it to a
// bacterial host and watch it multiply, then answer why; (4) Riddles -
// match three microorganisms to their clue cards; (5) Growth conditions -
// set up a control dish, change one condition in each of dishes A, B and
// C, run 24 hours and complete the conclusion. Every 3D drag also has a
// sidebar button, and each finished scenario shows its summary (which the
// source never displayed) with "Next Scenario".
//
// SOURCE BUG FIXES:
// * Several drops succeeded on a bare click (the stir rod, the S2 dropper,
//   the coverslip and the S5 items started inside their drop radius).
//   Targets are now measured from the dropper tip / object footprint and a
//   real move is required; a missed drop snaps back with a hint instead of
//   leaving the object floating.
// * Repeating a successful action (coverslip, stirring, dropper, virus,
//   S2 structures, MCQ "B") queued extra advances, and every pending timer
//   kept running after a scenario change - both skipped scenarios. Actions
//   are latched and all timers are cancelled on scenario change/restart.
// * Scenario changes left state behind: Dish A raised, Dish B's agar
//   hidden, conclusion blanks filled, the Run button visible in other
//   scenarios, the virus label hidden. Each scenario is rebuilt cleanly.
// * The focus slider was never checked (labels worked at full blur) and
//   its Low/High ends were inverted; it is now a "sharpness" slider and the
//   labels only count once the image is sharp.
// * "Coverslip at 45 degrees" was never shown - the coverslip now tilts and
//   is lowered from 45 degrees.
// * The MCQ pre-highlighted the right answer; the S4 chip "Gut Bacteria"
//   gave the first riddle away (now "Bacteria") and wrong drops explain.
// * S5 items stayed draggable after placement (moving the heater away left
//   Dish A "set"); placed items lock.
// * Drags got stuck when released over the HUD/toolbar and the camera
//   orbited while dragging; drags are captured by the 3D view.
// * The lock icon showed "unlocked" while the camera was locked, and zoom
//   had no limit; the camera distance is now clamped and framed per step
//   (props, labels and panels stay on screen on phones).
// * Chalkboard text, toasts, the microscope/MCQ/riddle/setup panels and
//   their buttons were English-only; Hindi "नाइट्रोजन तय करता है" (decides)
//   -> "स्थिर करता है", "व्यंजनों" (food dishes) -> "पेट्री डिशों", and stray
//   zero-width characters are fixed. Restart keeps the language.
// * Objects at x = 9 / +-6 fell off narrow screens; props start closer.
// * Nothing showed what to drag or where: grabbable objects get a hand
//   and their drop target a dashed ring.
// * Wrong conclusion words were silently rejected; they now explain. The
//   Scenario 5 board button repeated the intro's "Enter Lab" and now
//   reads "Start Experiment". The mould threads are a shade darker so
//   they show on the light lens.
//
// CONTENT FIXES (approved by the user):
// * S3: the "bacterial" host had cilia and the virus was an animal-type
//   spiky ball. The host is now a rod-shaped bacterium with flagella,
//   labelled "Bacterial cell", infected by a bacteriophage.
// * S2: after stirring, the source turned all the water grey while asking
//   for the "clear top layer"; the beaker now settles into a clear top,
//   a cloudy middle and soil at the bottom.
// * S5: Dish B swapped its agar for dry soil (two changes at once); it now
//   keeps its agar, dried out by a drying agent. The heater is the only
//   temperature change, so the step text says "extreme heat".
// * S5 conclusion: "most microorganisms require..." (some live without air).
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
    'appTitle': 'Microorganisms: Observation and Classification',
    'appSubtitle': 'Class 8. The Invisible Living World: Beyond Our Naked Eye',
    'enterLab': 'Enter Lab',
    'selectScenario': 'Select Scenario',
    'missionObj': 'Mission Objective',
    'conceptExp': 'Observation Steps',
    'currObj': 'Current Task',
    'exploration': 'Step',
    'conceptFocus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'nextScenario': 'Next Scenario',
    'restartLab': 'Restart Entire Lab',
    'allComplete': 'Mastery Achieved!',
    'allCompleteDesc':
        'You have successfully explored the world of microorganisms, learned how to classify them, and understood the conditions they need to grow!',
    'scComplete': 'Scenario {n} Complete!',
    'scenarioDoneHud':
        'Scenario {n} complete! Go on to the next scenario.', // added
    'labDoneHud': 'All scenarios complete! Restart the lab any time.', // added
    'labControls': 'Lab Controls', // added
    'controlsHint':
        'Drag the objects in the 3D view, or use these buttons.', // added
    'ttLabels': 'Toggle labels', // added
    'ttLock': 'Lock / unlock camera', // added
    'lbl': {
      'pond': 'Pond',
      'slide': 'Glass Slide',
      'coverslip': 'Coverslip',
      'dropper': 'Dropper',
      'beaker': 'Beaker w/ Soil',
      'flask': 'Water Flask',
      'stirrod': 'Glass Rod',
      // Content fix: the host is a bacterium, the virus a bacteriophage.
      'host': 'Bacterial cell',
      'virus': 'Virus (bacteriophage)',
      'control': 'Control',
      'dishA': 'Dish A (Temp)',
      'dishB': 'Dish B (Moisture)',
      'dishC': 'Dish C (Air)',
      'heater': '100°C Heater',
      // Content fix: Dish B keeps its agar and is dried out.
      'dryAgent': 'Drying agent (silica gel)',
      'vacuum': 'Vacuum Lid',
    },
    // Lab-control twins of the 3D drags (all added).
    'twCollect': 'Collect a pond-water sample',
    'twDrop': 'Put a drop on the slide',
    'twCover': 'Lower the coverslip at 45°',
    'twPour': 'Pour water into the beaker',
    'twStir': 'Stir with the glass rod',
    'twSample': 'Sample the clear top layer',
    'twCheck': 'Check the virus',
    'twInfect': 'Bring the virus to the bacterial cell',
    'twHeater': 'Heater under Dish A',
    'twDry': 'Drying agent into Dish B',
    'twLid': 'Vacuum lid on Dish C',
    // Scenario 1 (toasts added unless noted).
    'fbPondMiss': 'Dip the dropper tip into the pond water.',
    'fbSampled': 'Pond water collected in the dropper.',
    'fbSlideMiss': 'Hold the dropper tip just above the glass slide.',
    'fbDropPlaced': 'One drop is on the slide. Now lower the coverslip at 45°.',
    'fbDropFirst': 'Put a drop of pond water on the slide first.',
    'fbCoverMiss': 'Bring the coverslip onto the drop on the slide.',
    'fbCoverslip':
        'Coverslip lowered at 45° - the air is pushed out, so no bubbles!',
    'microTitle': 'Microscope View',
    'obsStatus': 'Observation Status',
    'amoeba': 'Amoeba',
    'paramecium': 'Paramecium',
    'yes': 'Yes',
    'no': 'No',
    'adjustFocus': 'Adjust Focus',
    // The source's ends were inverted ("Low" was sharp).
    'blurry': 'Blurry',
    'sharp': 'Sharp',
    'dragLabels': 'Drag each label onto its organism', // added
    'fbBlurry': 'Too blurry to identify - focus the microscope first.', // added
    'fbFocused': 'In focus! Now label the organisms.', // added
    'fbLabelWrong':
        'Not that one - Amoeba has an irregular shape, Paramecium is slipper-shaped.', // added
    'fbLabelRight': 'Correct!', // added
    // Scenario 2.
    'fbFlaskMiss': 'Lift the flask over the beaker to pour.', // added
    'fbWaterAdded':
        'Water added! Now drag the glass rod into the beaker to stir it.',
    'fbWaterFirst': 'Add water from the flask first!',
    'fbRodMiss': 'Dip the glass rod into the beaker.', // added
    'fbSettling': 'Soil is settling...',
    'fbSettled':
        'Settled: clear water on top, a cloudy middle and soil at the bottom.', // added
    'fbBeakerMiss':
        'Dip the dropper tip into the water in the beaker.', // added
    'fbTopLayer': 'Take the sample from the clear TOP layer!',
    'mould': 'Bread Mould (Fungi)', // added
    'bacteria': 'Bacteria', // added
    'tapStructures': 'Tap each structure to classify it', // added
    'fbMould': 'Identified: Bread Mould (Fungi) - Thread-like structures.',
    'fbBacteria': 'Identified: Bacteria - Tiny shapes.',
    // Scenario 3.
    'fbInert': 'Status: Inert. Cannot reproduce outside host.',
    'fbHostMiss': 'Bring the virus onto the bacterial cell.', // added
    'fbMultiplying': 'Virus Multiplying rapidly inside host!',
    'mcqTitle': 'Observation Question',
    'mcqQ':
        'Why did the virus multiply only after entering the bacterial cell?',
    'mcqA': 'A: It found food inside.',
    'mcqB': 'B: It requires a living host cell to reproduce.',
    'mcqC': 'C: It entered a warmer environment.',
    'fbMcqRight': 'Correct! Viruses need a host to reproduce.',
    'fbMcqWrong': 'Try again. Think about what the bacteria provides.',
    // Scenario 4.
    'riddlesTitle': 'Identify the Microorganisms',
    'dragIcons': 'Drag icons to matching cards',
    'clueBacteria':
        'I live in every kind of environment, and even inside your gut to help digestion.',
    'clueYeast':
        'I am used in baking. I make bread and cakes soft and fluffy by releasing gas.',
    'clueRhizobium':
        'I live in the root nodules of leguminous plants and fix nitrogen for them.',
    'chipYeast': 'Yeast (Fungi)',
    'chipRhizobium': 'Rhizobium',
    'chipBacteria': 'Bacteria', // was "Gut Bacteria" (gave the clue away)
    'hintYeast':
        'Yeast is a fungus that releases gas - find the baking clue.', // added
    'hintRhizobium':
        'Rhizobium lives in the roots of legumes - find the nitrogen clue.', // added
    'hintBacteria':
        'Bacteria live almost everywhere - even in your gut.', // added
    // Scenario 5.
    'setupTitle': 'Setup Control Dish',
    'temperature': 'Temperature',
    'moisture': 'Moisture',
    'airExposure': 'Air Exposure',
    't100': '100°C',
    't30': '30°C',
    't0': '0°C',
    'dry': 'Dry',
    'moist': 'Moist',
    'exposed': 'Exposed',
    'vacuum': 'Vacuum',
    'confirmSetup': 'Confirm Setup',
    'fbControlRight': 'Control dish setup perfectly with optimal conditions!',
    'fbControlWrong':
        'Incorrect. The Control dish needs OPTIMAL conditions for growth.',
    'fbHeaterMiss': 'Put the heater under Dish A.', // added
    'fbDryMiss': 'Put the drying agent into Dish B.', // added
    'fbLidMiss': 'Put the vacuum lid on Dish C.', // added
    'fbNotControl':
        'Keep the Control dish at optimal conditions - change only the test dishes.', // added
    'fbHeaterSet': 'Dish A: extreme heat.', // added
    'fbDrySet': 'Dish B: the agar dries out - no moisture.', // added
    'fbLidSet': 'Dish C: the air is removed.', // added
    'fbAllSet': 'All three test dishes are ready. Run the experiment!', // added
    'runExp': 'Run Experiment (Simulate 24h)',
    'fbColonies':
        'After 24 hours, colonies grew only in the Control dish.', // added
    'resultsTitle': 'Experiment Results',
    // Content fix: "most" microorganisms (some live without air).
    'conclusion':
        'Based on our observations, most microorganisms require {temp}, {moisture}, and {air} to grow.',
    'chipAir': 'Air',
    'chipTemp': 'Optimal Temp',
    'chipMoisture': 'Moisture',
    'dragWords': 'Drag the words into the blanks', // added
    'fbBlankWrong': 'That word belongs in a different blank.', // added
    'scenarios': [
      {
        'title': 'Scenario 1: Observing Pond Water',
        'objective':
            'Observe and identify Amoeba and Paramecium from a pond water sample.',
        'board':
            'Activity 2.4: Let us observe pond water. Microorganisms are too small to be seen with the naked eye. We must prepare a slide to observe them.',
        'boardBtn': 'Setup Activity: Prepare Slide',
        'hud': [
          'Step 1: Read the objective on the board and start.',
          'Step 2: Drag the dropper to the pond to collect a water sample.',
          'Step 3: Drag the filled dropper to the glass slide, then place coverslip at 45°.',
          'Step 4: Use the slider to focus the microscope and drag labels to identify.',
        ],
        'steps': [
          {
            'concept': 'Objective Setup',
            'action':
                'Review the mission on the chalkboard to understand our goal.',
            'observation':
                'We learn that many single-celled microorganisms make their home in stagnant water environments like ponds.',
          },
          {
            'concept': 'Sample Collection',
            'action':
                'Use the dropper to carefully extract a small amount of water from the pond.',
            'observation':
                'The water looks clear to the naked eye, but it is actually teeming with microscopic life waiting to be discovered.',
          },
          {
            'concept': 'Slide Preparation',
            'action':
                'Place exactly one drop of the sample onto the glass slide, then gently lower the cover slip at a 45-degree angle.',
            'observation':
                'Placing the cover slip at an angle pushes air out, preventing bubbles which would obstruct our view under the microscope.',
          },
          {
            'concept': 'Microscopic Observation',
            'action':
                'Adjust the microscope focus until the shapes become sharp, then identify the moving organisms.',
            'observation':
                'We can clearly see an Amoeba, which constantly changes its irregular shape, and a Paramecium, easily recognized by its distinct slipper-like shape.',
          },
        ],
        'summaryTitle': 'Observation Complete!',
        'summary':
            'You successfully prepared a slide and used a microscope to identify single-celled organisms like **Amoeba** (irregular shape) and **Paramecium** (slipper shape) living in stagnant water.',
      },
      {
        'title': 'Scenario 2: Observing Soil Suspension',
        'objective':
            'Observe and identify Bread Mould and Bacteria from a moist soil sample.',
        'board':
            'Activity 2.5: Let us observe soil suspension. Soil contains moisture and tiny organisms. We will extract them using water.',
        'boardBtn': 'Setup Activity: Prepare Suspension',
        'hud': [
          'Step 1: Read the objective on the board and start.',
          'Step 2: Drag the flask to pour water into the beaker, then stir.',
          'Step 3: Drag the dropper to take a sample from the TOP clear layer.',
          'Step 4: Click on the structures in the microscope to classify them.',
        ],
        'steps': [
          {
            'concept': 'Objective Setup',
            'action': 'Review the chalkboard to understand the procedure.',
            'observation':
                "Soil isn't just dirt; it's a rich habitat providing moisture and nutrients for countless fungi and bacteria.",
          },
          {
            'concept': 'Creating a Suspension',
            'action':
                'Pour water into the beaker containing soil, stir vigorously, and allow the mixture to rest.',
            // Content fix: the settled layers are described as drawn.
            'observation':
                'As the mixture settles, the heavy soil and sand particles sink to the bottom due to gravity, leaving a cloudy middle layer and clear water on top.',
          },
          {
            'concept': 'Targeted Sampling',
            // Content fix: the source said "slightly cloudy" here but "clear
            // top layer" everywhere else.
            'action':
                'Carefully use the dropper to take water only from the clear top layer.',
            'observation':
                'Because microorganisms are incredibly light, they remain suspended in the upper water layer rather than sinking with the heavy soil.',
          },
          {
            'concept': 'Microbial Classification',
            'action':
                'Examine the sample under the microscope and click on different structures to classify them based on their shape.',
            'observation':
                'We identify Fungi (Bread Mould) by its long, branched, thread-like structures, and Bacteria by their extremely tiny, geometric shapes.',
          },
        ],
        'summaryTitle': 'Classification Complete!',
        'summary':
            'By extracting microbes from soil, you identified **Fungi (Bread Mould)** with thread-like structures and tiny geometrical **Bacteria**.',
      },
      {
        'title': 'Scenario 3: Virus Reproduction Mechanics',
        'objective':
            'Demonstrate that viruses are acellular and only reproduce inside a host.',
        'board':
            'Viruses are microscopic and acellular. They are different from other microorganisms because they reproduce ONLY inside a host organism.',
        'boardBtn': 'Setup Activity: Viral Infection',
        'hud': [
          'Step 1: Read the objective on the board and start.',
          'Step 2: Click the floating virus to check its status.',
          'Step 3: Drag the virus into the bacterial host cell.',
          'Step 4: Answer the multiple-choice question.',
        ],
        'steps': [
          {
            'concept': 'Objective Setup',
            'action':
                'Read the chalkboard to learn about the unique nature of viruses.',
            'observation':
                "Viruses are considered 'acellular' - meaning they aren't true cells - and they have a strict dependency on a host organism to survive.",
          },
          {
            'concept': 'Analyzing the Inert State',
            'action':
                'Click on the isolated virus particle floating outside of any cell to examine its activity level.',
            'observation':
                'The virus is completely inert (inactive). It lacks the cellular machinery required to consume food, grow, or reproduce on its own.',
          },
          {
            'concept': 'Infection Process',
            'action':
                'Drag the virus particle so that it comes into direct contact with the living Bacterial Host Cell.',
            'observation':
                "Once inside the host, the virus hijacks the living cell's internal machinery, using it to rapidly construct hundreds of copies of itself.",
          },
          {
            'concept': 'Scientific Analysis',
            'action':
                'Answer the observation question regarding why the virus began multiplying.',
            'observation':
                'We conclude that viruses act as non-living particles outside, but exhibit living characteristics (reproduction) only when infecting a living host.',
          },
        ],
        'summaryTitle': 'Mechanics Understood!',
        'summary':
            'You observed that viruses are **acellular** and remain inert outside. They only multiply when they infect a **living host cell**.',
      },
      {
        'title': 'Scenario 4: Identification Riddles',
        'objective':
            'Identify microorganisms based on specific functional clues.',
        'board':
            'Unsolved Challenge 1: Identify the microorganisms based on their specific characteristics and habitats.',
        'boardBtn': 'Start Identification',
        'hud': [
          'Step 1: Read the objective on the board and start.',
          'Step 2: Read the clues on the cards and drag the correct icon to match.',
        ],
        'steps': [
          {
            'concept': 'Objective Setup',
            'action':
                'Read the chalkboard to prepare for the identification challenge.',
            'observation':
                'We must use our knowledge of where specific microbes live and what they do to correctly identify them.',
          },
          {
            'concept': 'Deductive Analysis',
            'action':
                'Read the functional clues provided on each card and drag the matching microorganism icon into the slot.',
            'observation':
                'We successfully determined that Bacteria thrive everywhere (even in guts), Yeast is crucial for baking by releasing gas, and Rhizobium fixes nitrogen in plant roots.',
          },
        ],
        'summaryTitle': 'Riddles Solved!',
        'summary':
            'You correctly identified that **Bacteria** live everywhere including guts, **Yeast** helps in baking, and **Rhizobium** lives in root nodules.',
      },
      {
        'title': 'Scenario 5: Growth Conditions',
        'objective': 'Experiment to test what microorganisms need for growth.',
        'board':
            'Unsolved Challenge 2: Devise an experiment to test that microorganisms need optimal temperature, air, and moisture for their growth.',
        // The source repeated the intro's "Enter Lab" here.
        'boardBtn': 'Start Experiment',
        'hud': [
          'Step 1: Read the objective on the board and start.',
          'Step 2: Set up the Control dish with Optimal conditions.',
          'Step 3: Change conditions for Dish A, B, C (Heat, Dry, Vacuum).',
          "Step 4: Click 'Run Experiment' and complete the conclusion.",
        ],
        'steps': [
          {
            'concept': 'Objective Setup',
            'action':
                'Read the chalkboard to understand the goal of our controlled experiment.',
            'observation':
                "We are learning about 'Variable Control'. To prove what causes growth, we must isolate and test specific environmental conditions.",
          },
          {
            'concept': 'Establishing a Baseline',
            'action':
                "Configure the 'Control' Petri dish by selecting optimal conditions: Temp (30°C), Moisture (Moist), and Air (Exposed).",
            'observation':
                "A 'Control' dish represents ideal, perfect conditions. We use this as a baseline to compare against our other test dishes.",
          },
          {
            'concept': 'Variable Testing',
            // Content fix: one change per dish (Dish B keeps its agar) and
            // only heat is available, so no "heat/cold".
            'action':
                "Change one condition in each test dish: expose Dish A to extreme heat, dry out Dish B's agar with a drying agent, and place a vacuum seal on Dish C.",
            'observation':
                'By removing just one essential requirement (like air or moisture) from each test dish, we create unfavorable environments to observe the impact.',
          },
          {
            'concept': 'Simulation & Conclusion',
            'action':
                'Run the simulation to allow 24 hours to pass, then observe the results and complete the scientific conclusion.',
            'observation':
                'Microbial colonies only flourished in the Control dish. This shows that most microorganisms need a combination of optimal temperature, moisture, and air to grow rapidly.',
          },
        ],
        'summaryTitle': 'Experiment Complete!',
        'summary':
            'You proved that for **most** microorganisms to grow rapidly, they require a combination of **optimal temperature, moisture, and air**.',
      },
    ],
  },
  'hi': {
    'appTitle': 'सूक्ष्मजीव: अवलोकन और वर्गीकरण',
    'appSubtitle': 'कक्षा 8. अदृश्य जीवित दुनिया: हमारी नंगी आंखों से परे',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'missionObj': 'अभियान का उद्देश्य',
    'conceptExp': 'अवलोकन चरण',
    'currObj': 'वर्तमान कार्य',
    'exploration': 'चरण',
    'conceptFocus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'प्रयोगशाला पुनः प्रारंभ करें',
    'allComplete': 'महारत हासिल की!',
    'allCompleteDesc':
        'आपने सूक्ष्मजीवों की दुनिया का सफलतापूर्वक पता लगाया है, उन्हें वर्गीकृत करना सीखा है, और उन्हें बढ़ने के लिए आवश्यक शर्तों को समझा है!',
    'scComplete': 'परिदृश्य {n} पूर्ण!',
    'scenarioDoneHud': 'परिदृश्य {n} पूर्ण! अगले परिदृश्य पर जाएँ।', // added
    'labDoneHud':
        'सभी परिदृश्य पूरे हुए! प्रयोगशाला कभी भी पुनः आरंभ करें।', // added
    'labControls': 'प्रयोगशाला नियंत्रण', // added
    'controlsHint':
        '3D दृश्य में वस्तुओं को खींचें, या इन बटनों का उपयोग करें।', // added
    'ttLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'ttLock': 'कैमरा लॉक / अनलॉक', // added
    'lbl': {
      'pond': 'तालाब',
      'slide': 'कांच की स्लाइड',
      'coverslip': 'कवर स्लिप',
      'dropper': 'ड्रॉपर',
      'beaker': 'मिट्टी के साथ बीकर',
      'flask': 'पानी का फ्लास्क',
      'stirrod': 'कांच की छड़',
      'host': 'जीवाणु कोशिका',
      'virus': 'वायरस (बैक्टीरियोफेज)',
      'control': 'नियंत्रण',
      'dishA': 'डिश A (तापमान)',
      'dishB': 'डिश B (नमी)',
      'dishC': 'डिश C (वायु)',
      'heater': '100°C हीटर',
      'dryAgent': 'शुष्कक (सिलिका जेल)',
      'vacuum': 'वैक्यूम ढक्कन',
    },
    'twCollect': 'तालाब के पानी का नमूना लें',
    'twDrop': 'स्लाइड पर एक बूंद डालें',
    'twCover': 'कवरस्लिप को 45° पर नीचे करें',
    'twPour': 'बीकर में पानी डालें',
    'twStir': 'कांच की छड़ से हिलाएँ',
    'twSample': 'ऊपर की साफ़ परत से नमूना लें',
    'twCheck': 'वायरस की जाँच करें',
    'twInfect': 'वायरस को जीवाणु कोशिका तक ले जाएँ',
    'twHeater': 'हीटर को डिश A के नीचे रखें',
    'twDry': 'शुष्कक को डिश B में रखें',
    'twLid': 'वैक्यूम ढक्कन डिश C पर लगाएँ',
    'fbPondMiss': 'ड्रॉपर की नोक को तालाब के पानी में डुबोएँ।',
    'fbSampled': 'ड्रॉपर में तालाब का पानी भर गया।',
    'fbSlideMiss': 'ड्रॉपर की नोक को कांच की स्लाइड के ठीक ऊपर रखें।',
    'fbDropPlaced': 'स्लाइड पर एक बूंद है। अब कवरस्लिप को 45° पर नीचे करें।',
    'fbDropFirst': 'पहले स्लाइड पर तालाब के पानी की एक बूंद डालें।',
    'fbCoverMiss': 'कवरस्लिप को स्लाइड पर रखी बूंद पर लाएँ।',
    'fbCoverslip':
        'कवरस्लिप 45° पर नीचे किया गया - हवा बाहर निकल गई, इसलिए कोई बुलबुला नहीं!',
    'microTitle': 'सूक्ष्मदर्शी दृश्य',
    'obsStatus': 'अवलोकन स्थिति',
    'amoeba': 'अमीबा',
    'paramecium': 'पैरामीशियम',
    'yes': 'हाँ',
    'no': 'नहीं',
    'adjustFocus': 'फोकस समायोजित करें',
    'blurry': 'धुंधला',
    'sharp': 'स्पष्ट',
    'dragLabels': 'हर लेबल को उसके जीव पर खींचें',
    'fbBlurry':
        'पहचानने के लिए बहुत धुंधला है - पहले सूक्ष्मदर्शी को फोकस करें।',
    'fbFocused': 'फोकस हो गया! अब जीवों पर लेबल लगाएँ।',
    'fbLabelWrong':
        'यह नहीं - अमीबा का आकार अनियमित है, पैरामीशियम चप्पल के आकार का है।',
    'fbLabelRight': 'सही!',
    'fbFlaskMiss': 'पानी डालने के लिए फ्लास्क को बीकर के ऊपर उठाएँ।',
    'fbWaterAdded':
        'पानी डाल दिया! अब हिलाने के लिए कांच की छड़ को बीकर में खींचें।',
    'fbWaterFirst': 'पहले फ्लास्क से पानी डालें!',
    'fbRodMiss': 'कांच की छड़ को बीकर में डुबोएँ।',
    'fbSettling': 'मिट्टी नीचे बैठ रही है...',
    'fbSettled':
        'मिश्रण बैठ गया: ऊपर साफ़ पानी, बीच में धुंधली परत और तल में मिट्टी।',
    'fbBeakerMiss': 'ड्रॉपर की नोक को बीकर के पानी में डुबोएँ।',
    'fbTopLayer': 'नमूना साफ़ ऊपरी परत से लें!',
    'mould': 'ब्रेड मोल्ड (कवक)',
    'bacteria': 'बैक्टीरिया',
    'tapStructures': 'हर संरचना को वर्गीकृत करने के लिए उस पर टैप करें',
    'fbMould': 'पहचाना गया: ब्रेड मोल्ड (कवक) - धागे जैसी संरचनाएँ।',
    'fbBacteria': 'पहचाना गया: बैक्टीरिया - छोटी आकृतियाँ।',
    'fbInert': 'स्थिति: अक्रिय। मेज़बान के बाहर प्रजनन नहीं कर सकता।',
    'fbHostMiss': 'वायरस को जीवाणु कोशिका पर लाएँ।',
    'fbMultiplying': 'वायरस मेज़बान के अंदर तेज़ी से गुणा कर रहा है!',
    'mcqTitle': 'अवलोकन प्रश्न',
    'mcqQ': 'वायरस ने जीवाणु कोशिका में प्रवेश करने के बाद ही गुणा क्यों किया?',
    'mcqA': 'A: उसे अंदर भोजन मिला।',
    'mcqB': 'B: उसे प्रजनन के लिए एक जीवित मेज़बान कोशिका चाहिए।',
    'mcqC': 'C: वह एक गर्म वातावरण में आ गया।',
    'fbMcqRight': 'सही! वायरस को प्रजनन के लिए मेज़बान चाहिए।',
    'fbMcqWrong': 'फिर से प्रयास करें। सोचें कि जीवाणु क्या प्रदान करता है।',
    'riddlesTitle': 'सूक्ष्मजीवों को पहचानें',
    'dragIcons': 'आइकन को मेल खाते कार्ड पर खींचें',
    'clueBacteria':
        'मैं हर तरह के वातावरण में रहता हूँ, यहाँ तक कि पाचन में मदद के लिए आपकी आँतों में भी।',
    'clueYeast':
        'मेरा उपयोग बेकिंग में होता है। मैं गैस छोड़कर ब्रेड और केक को नरम और फूला हुआ बनाता हूँ।',
    'clueRhizobium':
        'मैं फलीदार पौधों की जड़ की गांठों में रहता हूँ और उनके लिए नाइट्रोजन स्थिर करता हूँ।',
    'chipYeast': 'यीस्ट (कवक)',
    'chipRhizobium': 'राइजोबियम',
    'chipBacteria': 'बैक्टीरिया',
    'hintYeast': 'यीस्ट एक कवक है जो गैस छोड़ता है - बेकिंग वाला सुराग खोजें।',
    'hintRhizobium':
        'राइजोबियम फलीदार पौधों की जड़ों में रहता है - नाइट्रोजन वाला सुराग खोजें।',
    'hintBacteria': 'बैक्टीरिया लगभग हर जगह रहते हैं - आपकी आँतों में भी।',
    'setupTitle': 'नियंत्रण डिश सेट करें',
    'temperature': 'तापमान',
    'moisture': 'नमी',
    'airExposure': 'वायु संपर्क',
    't100': '100°C',
    't30': '30°C',
    't0': '0°C',
    'dry': 'सूखा',
    'moist': 'नम',
    'exposed': 'खुला',
    'vacuum': 'निर्वात',
    'confirmSetup': 'सेटअप की पुष्टि करें',
    'fbControlRight':
        'नियंत्रण डिश इष्टतम स्थितियों के साथ पूरी तरह सेट हो गई!',
    'fbControlWrong':
        'गलत। नियंत्रण डिश को वृद्धि के लिए इष्टतम स्थितियाँ चाहिए।',
    'fbHeaterMiss': 'हीटर को डिश A के नीचे रखें।',
    'fbDryMiss': 'शुष्कक को डिश B में रखें।',
    'fbLidMiss': 'वैक्यूम ढक्कन को डिश C पर लगाएँ।',
    'fbNotControl':
        'नियंत्रण डिश को इष्टतम स्थितियों में ही रखें - केवल परीक्षण डिशें बदलें।',
    'fbHeaterSet': 'डिश A: अत्यधिक गर्मी।',
    'fbDrySet': 'डिश B: अगार सूख गया - कोई नमी नहीं।',
    'fbLidSet': 'डिश C: हवा हटा दी गई।',
    'fbAllSet': 'तीनों परीक्षण डिशें तैयार हैं। प्रयोग चलाएँ!',
    'runExp': 'प्रयोग चलाएँ (24 घंटे)',
    'fbColonies': '24 घंटे बाद, कॉलोनियाँ केवल नियंत्रण डिश में बढ़ीं।',
    'resultsTitle': 'प्रयोग के परिणाम',
    'conclusion':
        'हमारे अवलोकनों के आधार पर, अधिकांश सूक्ष्मजीवों को बढ़ने के लिए {temp}, {moisture} और {air} की आवश्यकता होती है।',
    'chipAir': 'वायु',
    'chipTemp': 'इष्टतम तापमान',
    'chipMoisture': 'नमी',
    'dragWords': 'शब्दों को रिक्त स्थानों में खींचें',
    'fbBlankWrong': 'यह शब्द किसी दूसरे रिक्त स्थान का है।',
    'scenarios': [
      {
        'title': 'परिदृश्य 1: तालाब के पानी का अवलोकन', // changed (was "1.")
        'objective':
            'तालाब के पानी के नमूने से अमीबा और पैरामीशियम का निरीक्षण और पहचान करें।',
        // Completed: the source dropped the last sentence.
        'board':
            'गतिविधि 2.4: आइए तालाब के पानी का निरीक्षण करें। सूक्ष्मजीव नग्न आंखों से देखे जाने के लिए बहुत छोटे हैं। उन्हें देखने के लिए हमें एक स्लाइड तैयार करनी होगी।',
        'boardBtn': 'गतिविधि सेट करें: स्लाइड तैयार करें',
        'hud': [
          'चरण 1: बोर्ड पर उद्देश्य पढ़ें और शुरू करें।',
          'चरण 2: पानी का नमूना लेने के लिए ड्रॉपर को तालाब में खींचें।',
          // Completed: the source dropped "45°" and the slider.
          'चरण 3: भरे हुए ड्रॉपर को कांच की स्लाइड पर खींचें, फिर कवरस्लिप को 45° पर रखें।',
          'चरण 4: स्लाइडर से सूक्ष्मदर्शी को फोकस करें और लेबल खींचकर जीवों को पहचानें।',
        ],
        'steps': [
          {
            'concept': 'उद्देश्य सेटअप',
            'action':
                'हमारे लक्ष्य को समझने के लिए चॉकबोर्ड पर मिशन की समीक्षा करें।',
            'observation':
                'हम सीखते हैं कि कई एककोशिकीय सूक्ष्मजीव तालाबों जैसे स्थिर जल वातावरण में अपना घर बनाते हैं।',
          },
          {
            'concept': 'नमूना संग्रह',
            'action':
                'तालाब से थोड़ी मात्रा में पानी निकालने के लिए ड्रॉपर का सावधानीपूर्वक उपयोग करें।',
            'observation':
                'पानी नंगी आँखों को साफ दिखता है, लेकिन वास्तव में यह सूक्ष्म जीवन से भरा हुआ है जिसे खोजा जाना बाकी है।',
          },
          {
            'concept': 'स्लाइड की तैयारी',
            'action':
                'कांच की स्लाइड पर नमूने की ठीक एक बूंद डालें, फिर कवर स्लिप को 45-डिग्री के कोण पर धीरे से नीचे करें।',
            'observation':
                'कवर स्लिप को एक कोण पर रखने से हवा बाहर धकेल दी जाती है, जिससे बुलबुले रुक जाते हैं जो माइक्रोस्कोप के नीचे हमारे दृश्य को बाधित करेंगे।',
          },
          {
            'concept': 'सूक्ष्मदर्शी अवलोकन',
            'action':
                'सूक्ष्मदर्शी के फोकस को तब तक समायोजित करें जब तक कि आकार स्पष्ट न हो जाएं, फिर चलने वाले जीवों की पहचान करें।',
            'observation':
                'हम स्पष्ट रूप से एक अमीबा देख सकते हैं, जो लगातार अपने अनियमित आकार को बदलता है, और एक पैरामीशियम, जिसे आसानी से इसके विशिष्ट चप्पल जैसे आकार से पहचाना जा सकता है।',
          },
        ],
        'summaryTitle': 'अवलोकन पूर्ण!',
        'summary':
            'आपने सफलतापूर्वक एक स्लाइड तैयार की और रुके हुए पानी में रहने वाले **अमीबा** (अनियमित आकार) और **पैरामीशियम** (चप्पल का आकार) जैसे एककोशिकीय जीवों की पहचान करने के लिए एक माइक्रोस्कोप का उपयोग किया।',
      },
      {
        'title': 'परिदृश्य 2: मिट्टी के निलंबन का अवलोकन', // changed
        'objective':
            'नम मिट्टी के नमूने से ब्रेड मोल्ड और बैक्टीरिया का निरीक्षण और पहचान करें।',
        'board':
            'गतिविधि 2.5: आइए मिट्टी के निलंबन का निरीक्षण करें। मिट्टी में नमी और छोटे जीव होते हैं। हम उन्हें पानी की मदद से निकालेंगे।',
        'boardBtn': 'गतिविधि सेट करें: निलंबन तैयार करें',
        'hud': [
          'चरण 1: बोर्ड पर उद्देश्य पढ़ें और शुरू करें।',
          'चरण 2: बीकर में पानी डालने के लिए फ्लास्क को खींचें, फिर हिलाएं।',
          'चरण 3: शीर्ष स्पष्ट परत से नमूना लेने के लिए ड्रॉपर को खींचें।',
          'चरण 4: उन्हें वर्गीकृत करने के लिए माइक्रोस्कोप में संरचनाओं पर क्लिक करें।',
        ],
        'steps': [
          {
            'concept': 'उद्देश्य सेटअप',
            'action': 'प्रक्रिया को समझने के लिए चॉकबोर्ड की समीक्षा करें।',
            'observation':
                'मिट्टी केवल गंदगी नहीं है; यह एक समृद्ध आवास है जो अनगिनत कवक और बैक्टीरिया के लिए नमी और पोषक तत्व प्रदान करता है।',
          },
          {
            'concept': 'निलंबन बनाना',
            'action':
                'मिट्टी वाले बीकर में पानी डालें, जोर से हिलाएं, और मिश्रण को आराम करने दें।',
            'observation':
                'जैसे-जैसे मिश्रण बैठता है, भारी मिट्टी और रेत के कण गुरुत्वाकर्षण के कारण तल पर डूब जाते हैं, जिससे बीच में एक धुंधली परत और ऊपर साफ़ पानी रह जाता है।', // changed
          },
          {
            'concept': 'लक्षित नमूनाकरण',
            'action':
                'ड्रॉपर से सावधानीपूर्वक केवल ऊपर की साफ़ परत से पानी लें।', // changed
            'observation':
                'चूंकि सूक्ष्मजीव अविश्वसनीय रूप से हल्के होते हैं, इसलिए वे भारी मिट्टी के साथ डूबने के बजाय ऊपरी जल परत में निलंबित रहते हैं।',
          },
          {
            'concept': 'माइक्रोबियल वर्गीकरण',
            'action':
                'माइक्रोस्कोप के नीचे नमूने की जांच करें और उनके आकार के आधार पर उन्हें वर्गीकृत करने के लिए विभिन्न संरचनाओं पर क्लिक करें।',
            'observation':
                'हम कवक (ब्रेड मोल्ड) को उसकी लंबी, शाखित, धागे जैसी संरचनाओं से और बैक्टीरिया को उनके बेहद छोटे, ज्यामितीय आकृतियों से पहचानते हैं।',
          },
        ],
        'summaryTitle': 'वर्गीकरण पूर्ण!',
        'summary':
            'मिट्टी से रोगाणुओं को निकालकर, आपने धागे जैसी संरचनाओं वाले **कवक (ब्रेड मोल्ड)** और छोटे ज्यामितीय **बैक्टीरिया** की सफलतापूर्वक पहचान की।',
      },
      {
        'title': 'परिदृश्य 3: वायरस प्रजनन यांत्रिकी', // changed
        'objective':
            'प्रदर्शित करें कि वायरस अकोशिकीय हैं और केवल एक मेजबान के अंदर प्रजनन करते हैं।',
        'board':
            'वायरस सूक्ष्म और अकोशिकीय होते हैं। वे अन्य सूक्ष्मजीवों से इस बात में भिन्न हैं कि वे केवल एक मेजबान जीव के अंदर ही प्रजनन करते हैं।',
        'boardBtn': 'गतिविधि सेट करें: वायरल संक्रमण',
        'hud': [
          'चरण 1: बोर्ड पर उद्देश्य पढ़ें और शुरू करें।',
          'चरण 2: इसकी स्थिति की जांच करने के लिए तैरते हुए वायरस पर क्लिक करें।',
          'चरण 3: वायरस को बैक्टीरियल सेल में खींचें।',
          'चरण 4: बहुविकल्पीय प्रश्न का उत्तर दें।',
        ],
        'steps': [
          {
            'concept': 'उद्देश्य सेटअप',
            'action':
                'वायरस की अनूठी प्रकृति के बारे में जानने के लिए चॉकबोर्ड पढ़ें।',
            'observation':
                "वायरस को 'अकोशिकीय' माना जाता है - जिसका अर्थ है कि वे सच्ची कोशिकाएं नहीं हैं - और उन्हें जीवित रहने के लिए मेजबान जीव पर सख्त निर्भरता होती है।",
          },
          {
            'concept': 'अक्रिय अवस्था का विश्लेषण',
            'action':
                'इसकी गतिविधि के स्तर की जांच करने के लिए किसी भी सेल के बाहर तैरते हुए अलग-थलग वायरस कण पर क्लिक करें।',
            'observation':
                'वायरस पूरी तरह से अक्रिय (निष्क्रिय) है। इसमें भोजन का उपभोग करने, बढ़ने या अपने आप प्रजनन करने के लिए आवश्यक सेलुलर मशीनरी का अभाव है।',
          },
          {
            'concept': 'संक्रमण प्रक्रिया',
            // Zero-width characters removed.
            'action':
                'वायरस कण को खींचें ताकि यह जीवित बैक्टीरियल होस्ट सेल के सीधे संपर्क में आए।',
            'observation':
                'मेजबान के अंदर एक बार, वायरस जीवित कोशिका की आंतरिक मशीनरी को हाईजैक कर लेता है, और इसका उपयोग तेजी से अपनी सैकड़ों प्रतियां बनाने के लिए करता है।',
          },
          {
            'concept': 'वैज्ञानिक विश्लेषण',
            'action':
                'वायरस क्यों गुणा करना शुरू कर दिया, इस संबंध में अवलोकन प्रश्न का उत्तर दें।',
            'observation':
                'हम निष्कर्ष निकालते हैं कि वायरस बाहर गैर-जीवित कणों के रूप में कार्य करते हैं, लेकिन जीवित मेजबान को संक्रमित करने पर ही जीवित विशेषताओं (प्रजनन) को प्रदर्शित करते हैं।',
          },
        ],
        'summaryTitle': 'यांत्रिकी समझी गई!',
        'summary':
            'आपने देखा कि वायरस **अकोशिकीय** हैं और बाहर अक्रिय रहते हैं। वे केवल तब गुणा करते हैं जब वे एक **जीवित मेजबान सेल** को संक्रमित करते हैं।',
      },
      {
        'title': 'परिदृश्य 4: पहचान पहेलियां', // changed
        'objective':
            'विशिष्ट कार्यात्मक सुरागों के आधार पर सूक्ष्मजीवों को पहचानें।',
        'board':
            'अनसुलझी चुनौती 1: सूक्ष्मजीवों की पहचान उनकी विशिष्ट विशेषताओं और आवासों के आधार पर करें।',
        'boardBtn': 'पहचान शुरू करें',
        'hud': [
          'चरण 1: बोर्ड पर उद्देश्य पढ़ें और शुरू करें।',
          'चरण 2: कार्ड पर सुराग पढ़ें और मिलान करने के लिए सही सूक्ष्मजीव आइकन खींचें।',
        ],
        'steps': [
          {
            'concept': 'उद्देश्य सेटअप',
            'action': 'पहचान चुनौती की तैयारी के लिए चॉकबोर्ड पढ़ें।',
            'observation':
                'हमें विशिष्ट रोगाणु कहाँ रहते हैं और वे क्या करते हैं, इसके ज्ञान का उपयोग उन्हें सही ढंग से पहचानने के लिए करना चाहिए।',
          },
          {
            'concept': 'निगमनात्मक विश्लेषण',
            'action':
                'प्रत्येक कार्ड पर दिए गए कार्यात्मक सुरागों को पढ़ें और मिलान करने वाले सूक्ष्मजीव आइकन को स्लॉट में खींचें।',
            // "तय करता है" (decides) -> "स्थिर करता है" (fixes); zero-width
            // characters removed.
            'observation':
                'हमने सफलतापूर्वक निर्धारित किया कि बैक्टीरिया हर जगह (यहां तक कि आंतों में भी) पनपते हैं, खमीर गैस छोड़कर बेकिंग के लिए महत्वपूर्ण है, और राइजोबियम पौधों की जड़ों में नाइट्रोजन स्थिर करता है।',
          },
        ],
        'summaryTitle': 'पहेलियां हल हो गईं!',
        'summary':
            'आपने सही ढंग से पहचाना कि **बैक्टीरिया** आंतों सहित हर जगह रहते हैं, **यीस्ट** बेकिंग में मदद करता है, और **राइजोबियम** जड़ की गांठों में रहता है।',
      },
      {
        'title': 'परिदृश्य 5: विकास की शर्तें', // changed
        'objective':
            'यह परीक्षण करने के लिए प्रयोग करें कि सूक्ष्मजीवों को विकास के लिए क्या चाहिए।',
        'board':
            'अनसुलझी चुनौती 2: एक प्रयोग बनाएँ जिससे परखा जा सके कि सूक्ष्मजीवों को विकास के लिए इष्टतम तापमान, हवा और नमी की आवश्यकता है।',
        'boardBtn': 'प्रयोग शुरू करें', // changed
        'hud': [
          'चरण 1: बोर्ड पर उद्देश्य पढ़ें और शुरू करें।',
          'चरण 2: इष्टतम स्थितियों के साथ नियंत्रण डिश सेट करें।',
          // Completed: the source dropped "(Heat, Dry, Vacuum)".
          'चरण 3: डिश A, B और C की शर्तें बदलें (गर्मी, सूखा, निर्वात)।',
          "चरण 4: 'प्रयोग चलाएँ' पर क्लिक करें और निष्कर्ष पूरा करें।",
        ],
        'steps': [
          {
            'concept': 'उद्देश्य सेटअप',
            'action':
                'हमारे नियंत्रित प्रयोग के लक्ष्य को समझने के लिए चॉकबोर्ड पढ़ें।',
            'observation':
                "हम 'परिवर्तनीय नियंत्रण' के बारे में सीख रहे हैं। विकास का कारण क्या है, यह साबित करने के लिए, हमें विशिष्ट पर्यावरणीय परिस्थितियों को अलग करना और उनका परीक्षण करना चाहिए।",
          },
          {
            'concept': 'एक आधार रेखा स्थापित करना',
            'action':
                "इष्टतम स्थितियों का चयन करके 'नियंत्रण' पेट्री डिश को कॉन्फ़िगर करें: तापमान (30°C), नमी (नम), और वायु (खुला)।",
            // "व्यंजनों" (food dishes) -> "पेट्री डिशों".
            'observation':
                "एक 'नियंत्रण' डिश आदर्श, उत्तम स्थितियों का प्रतिनिधित्व करती है। हम इसका उपयोग अपनी अन्य परीक्षण पेट्री डिशों की तुलना के लिए एक आधार रेखा के रूप में करते हैं।",
          },
          {
            'concept': 'चर परीक्षण',
            'action':
                'हर परीक्षण डिश में एक स्थिति बदलें: डिश A को अत्यधिक गर्मी दें, डिश B के अगार को शुष्कक से सुखाएँ, और डिश C पर वैक्यूम सील लगाएँ।', // changed
            'observation':
                'प्रत्येक परीक्षण डिश से केवल एक आवश्यक आवश्यकता (जैसे हवा या नमी) को हटाकर, हम प्रभाव का निरीक्षण करने के लिए प्रतिकूल वातावरण बनाते हैं।',
          },
          {
            'concept': 'सिमुलेशन और निष्कर्ष',
            'action':
                '24 घंटे बीतने की अनुमति देने के लिए सिमुलेशन चलाएं, फिर परिणामों का निरीक्षण करें और वैज्ञानिक निष्कर्ष को पूरा करें।',
            'observation':
                'माइक्रोबियल कॉलोनियाँ केवल नियंत्रण डिश में पनपीं। यह दर्शाता है कि अधिकांश सूक्ष्मजीवों को तेज़ी से बढ़ने के लिए इष्टतम तापमान, नमी और हवा के संयोजन की आवश्यकता होती है।', // changed
          },
        ],
        'summaryTitle': 'प्रयोग पूरा हुआ!',
        'summary':
            'आपने साबित कर दिया कि **अधिकांश** सूक्ष्मजीवों को तेज़ी से बढ़ने के लिए **इष्टतम तापमान, नमी और हवा** के संयोजन की आवश्यकता होती है।',
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.teal500;
const Color _accentSoft = Color(0xFF5EEAD4); // teal-300

/// Steps per scenario (step 1 is always the chalkboard).
const List<int> _stepCounts = [4, 4, 4, 2, 4];

/// Beaker axis (scenario 2) and dish centres (scenario 5: Control, A, B, C).
const double _beakerX = -2.2;
const List<double> _dishX = [-4.8, -1.6, 1.6, 4.8];

const Color _clearWater = Color(0xFF38BDF8);
const Color _muddyWater = Color(0xFF92400E);
const Color _topWater = Color(0xFFBAE6FD);
const Color _agarColor = Color(0xFFFEF08A);
const Color _dryAgarColor = Color(0xFFC8B273);

/// Where a dragged object's handle must be released, on the vertical drag
/// plane through [centre]: at most [halfWidth] to either side, and between
/// [below] under and [above] over the centre.
class _DropWindow {
  const _DropWindow(this.centre, this.halfWidth, this.below, this.above);

  final _rt_V3 centre;
  final double halfWidth;
  final double below;
  final double above;
}

/// S4 chips: id -> (label key, hint key, colour).
const Map<String, (String, String, Color)> _riddleChips = {
  'bacteria': ('chipBacteria', 'hintBacteria', Color(0xFFF472B6)),
  'yeast': ('chipYeast', 'hintYeast', Color(0xFFFACC15)),
  'rhizobium': ('chipRhizobium', 'hintRhizobium', Color(0xFFA3E635)),
};

/// S4 cards in the source order: id -> clue key.
const List<(String, String)> _riddleCards = [
  ('bacteria', 'clueBacteria'),
  ('yeast', 'clueYeast'),
  ('rhizobium', 'clueRhizobium'),
];

/// S5 conclusion chips: blank id -> label key.
const Map<String, String> _conclusionChips = {
  'temp': 'chipTemp',
  'moisture': 'chipMoisture',
  'air': 'chipAir',
};

/// S5 control-dish options: group, label key, (value, label key), answer.
const List<(String, String, List<(String, String)>, String)> _setupGroups = [
  ('temp', 'temperature', [('100', 't100'), ('30', 't30'), ('0', 't0')], '30'),
  ('moist', 'moisture', [('dry', 'dry'), ('moist', 'moist')], 'moist'),
  (
    'air',
    'airExposure',
    [('exposed', 'exposed'), ('vacuum', 'vacuum')],
    'exposed',
  ),
];

/// S5 test items: id -> (dish index, twin key, miss key, placed key).
const Map<String, (int, String, String, String)> _items = {
  'heater': (1, 'twHeater', 'fbHeaterMiss', 'fbHeaterSet'),
  'dry': (2, 'twDry', 'fbDryMiss', 'fbDrySet'),
  'lid': (3, 'twLid', 'fbLidMiss', 'fbLidSet'),
};

class _ConfettiPiece {
  _ConfettiPiece(math.Random r)
    : angle = (-90 + (r.nextDouble() - 0.5) * 140) * math.pi / 180,
      speed = 420 + r.nextDouble() * 480,
      color = const [
        _rt_Tw.teal400,
        _rt_Tw.emerald400,
        Colors.white,
        _rt_Tw.amber400,
        _rt_Tw.pink500,
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

class Cl8Ch12A3MicroorganismsObservationClassificationPage
    extends StatefulWidget {
  const Cl8Ch12A3MicroorganismsObservationClassificationPage({super.key});

  @override
  State<Cl8Ch12A3MicroorganismsObservationClassificationPage> createState() =>
      _Cl8Ch12A3MicroorganismsObservationClassificationPageState();
}

class _Cl8Ch12A3MicroorganismsObservationClassificationPageState
    extends State<Cl8Ch12A3MicroorganismsObservationClassificationPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF10262A), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 8, 18),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  math.Random _rng = math.Random(123);
  final _rt_Node3D _root = _rt_Node3D(name: 'scenario-root');
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);
  final List<_rt_Label3D> _labels = [];

  // Scenario objects (rebuilt on every scenario change). Draggable objects
  // are kept by id in [_objects].
  final Map<String, _rt_Node3D> _objects = {};
  _rt_Node3D? _pond;
  _rt_Node3D? _table;
  _rt_Mesh3D? _dropperLiquid;
  _rt_Mesh3D? _slideDrop;
  _rt_Node3D? _waterPivot;
  _rt_Mesh3D? _waterMesh;
  _rt_Node3D? _soilPivot;
  _rt_Mesh3D? _cloudy;
  _rt_Mesh3D? _stream;
  _rt_Mesh3D? _flaskWater;
  _rt_Node3D? _phageBobber;
  _rt_Material3D? _phageHeadMat;
  _rt_Label3D? _virusLabel;
  _rt_Material3D? _heaterPlate;
  final Map<String, _rt_Label3D> _itemLabels = {};
  final List<_rt_Node3D> _flagella = [];
  final List<_rt_Node3D> _copies = [];
  final List<_rt_Node3D> _colonies = [];
  final List<_rt_Node3D> _dishes = [];
  final List<_rt_Mesh3D> _agars = [];

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

  bool _sampled = false; // S1: dropper filled at the pond
  bool _dropOnSlide = false;
  bool _covered = false;
  bool _waterAdded = false; // S2
  bool _stirred = false;
  bool _microscope = false; // S1/S2 step 4
  double _focus = 0; // S1: 0 blurry .. 100 sharp
  final Set<String> _labeled = {}; // S1 organisms labelled
  final Set<String> _classified = {}; // S2 structures found
  bool _virusChecked = false; // S3
  bool _infected = false;
  bool _mcqDone = false;
  String? _mcqWrong;
  final Map<String, String> _riddle = {}; // S4 card -> chip
  List<String> _riddleOrder = const [];
  final Map<String, String> _setup = {}; // S5 group -> value
  bool _controlSet = false;
  final Set<String> _placedItems = {};
  bool _ran = false;
  bool _showConclusion = false;
  final Map<String, String> _blanks = {}; // blank -> chip
  List<String> _conclusionOrder = const [];
  String? _selectedChip;
  String? _wrongZone;

  // 3D drag (on the vertical plane through the drop target, facing the
  // camera, so the object stays under the finger).
  String? _dragId;
  _rt_V3? _planePoint;
  _rt_V3? _planeNormal;
  Offset _grabOffset = Offset.zero;
  double _dragTravel = 0;
  Offset? _lastPointer;

  /// Full-canvas 2D panels (microscope, riddles): no 3D toolbar.
  bool get _panelMode => _microscope || (_scenario == 4 && _step > 1);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _camera
      ..minDistance = 4
      ..maxDistance = 45;
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.75),
      _rt_Light3D.directional(_rt_V3(5, 10, 5), intensity: 0.6),
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
    Color? emissive,
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
        emissive: emissive,
      ),
    );
  }

  /// Invisible, finger-sized grab area around a thin object.
  _rt_Mesh3D _proxy(_rt_Geometry3D g) =>
      _mesh(g, Colors.white, opacity: 0)..userData['proxy'] = true;

  _rt_Label3D _label(String key, double x, double y, double z) {
    final label =
        _rt_Label3D(
            _tx.s('lbl.$key'),
            position: _rt_V3(x, y, z),
            pixelHeight: 12,
            color: Colors.white,
            background: const Color(0xCC0F172A),
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

  _rt_Label3D _itemLabel(String id, String key, double x, double y, double z) {
    final label = _label(key, x, y, z);
    _itemLabels[id] = label;
    return label;
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
    _flagella.clear();
    _copies.clear();
    _colonies.clear();
    _dishes.clear();
    _agars.clear();
    _pond = _table = _waterPivot = _soilPivot = _phageBobber = null;
    _dropperLiquid = _slideDrop = _waterMesh = _cloudy = _stream = null;
    _flaskWater = null;
    _phageHeadMat = _heaterPlate = null;
    _itemLabels.clear();
    _virusLabel = null;
    _rng = math.Random(123 + _scenario);
    switch (_scenario) {
      case 1:
        _buildPond();
      case 2:
        _buildSoil();
      case 3:
        _buildVirus();
      case 5:
        _buildDishes();
    }
    _syncLabels();
  }

  _rt_Node3D _buildDropper() {
    final d = _rt_Node3D(name: 'dropper');
    d
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.3, widthSegments: 14, heightSegments: 10),
            const Color(0xFFEF4444),
            shininess: 0.5,
          )
          ..position.y = 1.5
          ..scale.set(1, 1.8, 1),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.1, 0.1, 2, segments: 12),
          Colors.white,
          opacity: 0.4,
        ),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.1, 0.03, 0.5, segments: 12),
          Colors.white,
          opacity: 0.4,
        )..position.y = -1.25,
      );
    final liquid =
        _mesh(
            _rt_Geometry3D.cylinder(0.08, 0.08, 1, segments: 10),
            _clearWater,
            opacity: 0.85,
          )
          ..position.y = -0.4
          ..visible = false;
    _dropperLiquid = liquid;
    d
      ..add(liquid)
      ..add(_proxy(_rt_Geometry3D.capsule(0.45, 2.6))..position.y = 0.2)
      ..add(_label('dropper', 0, 2.6, 0));
    return _draggable('dropper', d);
  }

  void _buildPond() {
    // Pond: grass, water, a grassy bank with rocks and reeds, lily pads.
    final pond = _rt_Node3D(name: 'pond');
    pond
      ..add(
        _mesh(_rt_Geometry3D.circle(9, segments: 40), const Color(0xFF14532D))
          ..rotation.x = -math.pi / 2
          ..position.y = -2.2
          ..depthBias = 60,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(4.2, 4.0, 0.3, segments: 40),
            const Color(0xFF0F5E4B),
            opacity: 0.92,
            shininess: 0.6,
          )
          ..position.y = -1.95
          ..depthBias = 30,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.torus(
              4.6,
              0.9,
              radialSegments: 8,
              tubularSegments: 36,
            ),
            const Color(0xFF166534),
          )
          ..rotation.x = math.pi / 2
          ..position.y = -2.05
          ..scale.set(1, 1, 0.55),
      );
    double bankY(double r) =>
        -2.05 + 0.5 * math.sqrt(math.max(0, 0.81 - (r - 4.6) * (r - 4.6)));
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * 2 * math.pi + _rng.nextDouble() * 0.3;
      final r = 4.6 + (_rng.nextDouble() - 0.5) * 0.9;
      final size = 0.25 + _rng.nextDouble() * 0.25;
      pond.add(
        _mesh(_rt_Geometry3D.icosahedron(size), const Color(0xFF71717A))
          ..position.set(
            r * math.cos(a),
            bankY(r) + size * 0.4,
            r * math.sin(a),
          )
          ..rotation.set(_rng.nextDouble() * 3, _rng.nextDouble() * 3, 0),
      );
    }
    for (var i = 0; i < 14; i++) {
      final a = (i + 0.5) / 14 * 2 * math.pi + _rng.nextDouble() * 0.2;
      final r = 4.4 + _rng.nextDouble() * 0.6;
      final cluster = _rt_Node3D()
        ..position.set(r * math.cos(a), bankY(r), r * math.sin(a));
      for (var k = 0; k < 3; k++) {
        final h = 0.7 + _rng.nextDouble() * 0.6;
        cluster.add(
          _mesh(
              _rt_Geometry3D.cone(0.05, h, segments: 6),
              const Color(0xFF15803D),
            )
            ..position.set(
              (_rng.nextDouble() - 0.5) * 0.3,
              h / 2,
              (_rng.nextDouble() - 0.5) * 0.3,
            )
            ..rotation.z = (_rng.nextDouble() - 0.5) * 0.4,
        );
      }
      pond.add(cluster);
    }
    for (var i = 0; i < 6; i++) {
      final a = _rng.nextDouble() * 2 * math.pi;
      final r = 0.8 + _rng.nextDouble() * 2.6;
      pond.add(
        _mesh(
            _rt_Geometry3D.circle(
              0.3 + _rng.nextDouble() * 0.15,
              segments: 16,
              thetaStart: 0.3,
              thetaLength: 2 * math.pi - 0.6,
            ),
            const Color(0xFF4ADE80),
          )
          ..rotation.set(-math.pi / 2, 0, a)
          ..position.set(r * math.cos(a), -1.78, r * math.sin(a))
          ..depthBias = -1,
      );
    }
    pond.add(_label('pond', 0, 0.2, -3.2));
    _pond = pond;

    // Table with the glass slide, the (hidden) drop and the coverslip.
    final table = _rt_Node3D(name: 'table')
      ..add(
        _mesh(_rt_Geometry3D.box(8, 0.2, 5), const Color(0xFF94A3B8))
          ..position.y = -2.0
          ..depthBias = 30,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.box(3, 0.05, 1.5),
          Colors.white,
          opacity: 0.6,
          edge: Colors.white70,
        )..position.set(0, -1.875, 0),
      );
    final drop =
        _mesh(
            _rt_Geometry3D.sphere(0.15, widthSegments: 14, heightSegments: 8),
            const Color(0xFF7DD3FC),
            opacity: 0.85,
            shininess: 0.8,
          )
          ..position.set(0, -1.83, 0)
          ..scale.set(0, 0, 0)
          ..visible = false;
    _slideDrop = drop;
    table
      ..add(drop)
      ..add(_label('slide', 0, -1.2, -1.0));
    final cover = _rt_Node3D(name: 'coverslip')
      ..add(
        _mesh(
          _rt_Geometry3D.box(0.8, 0.03, 0.8),
          const Color(0xFFE0F2FE),
          opacity: 0.5,
          edge: Colors.white,
        ),
      )
      ..add(_proxy(_rt_Geometry3D.box(1.4, 0.5, 1.4)))
      ..add(_label('coverslip', 0, 0.6, 0));
    _setHome(cover, -2.6, -1.885, 1.2);
    table.add(_draggable('coverslip', cover));
    _table = table;

    final dropper = _buildDropper();
    _setHome(dropper, 5.8, 0.5, 1.2);
    _root
      ..add(pond)
      ..add(table)
      ..add(dropper);
  }

  void _buildSoil() {
    _root.add(
      _mesh(_rt_Geometry3D.box(12, 0.2, 6), const Color(0xFF94A3B8))
        ..position.y = -3.1
        ..depthBias = 30,
    );
    // Beaker (bottom at y -3): soil, then the poured water above it.
    final beaker = _rt_Node3D(name: 'beaker')..position.set(_beakerX, -1.25, 0);
    final soilPivot = _rt_Node3D()..position.y = -1.7;
    soilPivot.add(
      _mesh(
        _rt_Geometry3D.cylinder(1.45, 1.45, 1, segments: 28),
        const Color(0xFF78350F),
      )..position.y = 0.5,
    );
    final waterPivot = _rt_Node3D()
      ..position.y = -0.7
      ..scale.y = 0.05
      ..visible = false;
    final water = _mesh(
      _rt_Geometry3D.cylinder(1.44, 1.44, 2, segments: 28),
      _clearWater,
      opacity: 0.55,
    )..position.y = 1.0;
    waterPivot.add(water);
    final cloudy =
        _mesh(
            _rt_Geometry3D.cylinder(1.44, 1.44, 0.8, segments: 28),
            const Color(0xFFA16207),
            opacity: 0,
          )
          ..position.y = -0.6
          ..visible = false;
    beaker
      ..add(soilPivot)
      ..add(waterPivot)
      ..add(cloudy)
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.5, 1.5, 3.5, segments: 28, openEnded: true),
          const Color(0xFFBAE6FD),
          opacity: 0.22,
          doubleSided: true,
        ),
      )
      ..add(_label('beaker', 0, 2.3, 0));
    _soilPivot = soilPivot;
    _waterPivot = waterPivot;
    _waterMesh = water;
    _cloudy = cloudy;

    // Conical flask of water.
    final flask = _rt_Node3D(name: 'flask')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.4, 1.2, 1.5, segments: 24),
          const Color(0xFFE0F2FE),
          opacity: 0.4,
        ),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.38, 0.38, 0.9, segments: 16),
          const Color(0xFFE0F2FE),
          opacity: 0.4,
        )..position.y = 1.2,
      );
    final flaskWater = _mesh(
      _rt_Geometry3D.cylinder(0.5, 1.12, 1.1, segments: 24),
      const Color(0xFF0EA5E9),
      opacity: 0.75,
    )..position.y = -0.18;
    _flaskWater = flaskWater;
    flask
      ..add(flaskWater)
      ..add(_proxy(_rt_Geometry3D.cylinder(1.3, 1.3, 3.0))..position.y = 0.4)
      ..add(_label('flask', 0, 2.2, 0));
    _setHome(flask, 2.4, -2.25, 0.8);

    // Glass rod lying on the table.
    final rod = _rt_Node3D(name: 'rod')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.06, 0.06, 4, segments: 10),
          const Color(0xFFE2E8F0),
          opacity: 0.85,
        ),
      )
      ..add(_proxy(_rt_Geometry3D.cylinder(0.35, 0.35, 4)))
      ..add(_label('stirrod', 0.6, 0, 0))
      ..rotation.z = math.pi / 2;
    _setHome(rod, 1.6, -2.9, 2.0);

    final stream =
        _mesh(
            _rt_Geometry3D.cylinder(0.08, 0.08, 1, segments: 8),
            _clearWater,
            opacity: 0.8,
          )
          ..position.set(_beakerX + 0.35, -0.05, 0)
          ..scale.y = 3.8
          ..visible = false;
    _stream = stream;

    final dropper = _buildDropper()..visible = false;
    _setHome(dropper, 4.4, -1.4, 0.6);
    _root
      ..add(beaker)
      ..add(_draggable('flask', flask))
      ..add(_draggable('rod', rod))
      ..add(stream)
      ..add(dropper);
  }

  /// Bacteriophage: icosahedral head, tail with a base plate and six legs.
  _rt_Node3D _phage(double s, _rt_Material3D headMat) {
    final p = _rt_Node3D()
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.icosahedron(0.5 * s), headMat)
          ..position.y = 1.0 * s,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.13 * s, 0.13 * s, 0.9 * s, segments: 10),
          const Color(0xFF6D28D9),
        ),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.32 * s, 0.32 * s, 0.08 * s, segments: 12),
          const Color(0xFF5B21B6),
        )..position.y = -0.5 * s,
      );
    for (var k = 0; k < 6; k++) {
      final a = k / 6 * 2 * math.pi;
      final c = math.cos(a), sn = math.sin(a);
      p.add(
        _mesh(
          _rt_Geometry3D.tube([
            _rt_V3(0.25 * c * s, -0.5 * s, 0.25 * sn * s),
            _rt_V3(0.6 * c * s, -0.78 * s, 0.6 * sn * s),
            _rt_V3(0.72 * c * s, -1.25 * s, 0.72 * sn * s),
          ], 0.035 * s),
          const Color(0xFFA78BFA),
        ),
      );
    }
    return p;
  }

  void _buildVirus() {
    // Rod-shaped bacterium (content fix: flagella, not cilia).
    final host = _rt_Node3D(name: 'host')..position.set(2.2, 0, 0);
    host
      ..add(
        _mesh(
            _rt_Geometry3D.capsule(1.0, 2.4, segments: 24),
            const Color(0xFFFDE047),
            opacity: 0.45,
            edge: const Color(0x66CA8A04),
          )
          ..rotation.z = math.pi / 2
          ..depthBias = 2,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.capsule(0.82, 2.2, segments: 20),
          const Color(0xFFFEF9C3),
          opacity: 0.35,
        )..rotation.z = math.pi / 2,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.tube([
            for (var i = 0; i <= 16; i++)
              _rt_V3(
                -1.2 + i * 0.15,
                0.25 * math.sin(i * 1.3),
                0.2 * math.cos(i * 0.9),
              ),
          ], 0.06),
          const Color(0xFFF472B6),
        ),
      )
      ..add(
        _rt_Points3D(
          [
            for (var i = 0; i < 40; i++)
              _rt_V3(
                (_rng.nextDouble() - 0.5) * 3.6,
                (_rng.nextDouble() - 0.5) * 1.2,
                (_rng.nextDouble() - 0.5) * 1.2,
              ),
          ],
          color: const Color(0xFFA16207),
          size: 3,
          sizeAttenuation: false,
        ),
      );
    for (var i = 0; i < 3; i++) {
      final flag = _rt_Node3D()
        ..position.set(2.1, (i - 1) * 0.45, (i - 1) * 0.2);
      flag.add(
        _mesh(
          _rt_Geometry3D.tube([
            for (var k = 0; k <= 14; k++)
              _rt_V3(k * 0.16, 0.18 * math.sin(k * 0.9 + i), 0),
          ], 0.035),
          const Color(0xFFCA8A04),
        ),
      );
      _flagella.add(flag);
      host.add(flag);
    }
    // Copies assembled inside the host after the infection (hidden).
    for (var i = 0; i < 15; i++) {
      final copy =
          _phage(
              0.3,
              _rt_Material3D(color: const Color(0xFF8B5CF6), shininess: 0.4),
            )
            ..position.set(
              (_rng.nextDouble() - 0.5) * 3.4,
              (_rng.nextDouble() - 0.5) * 1.0,
              (_rng.nextDouble() - 0.5) * 1.0,
            )
            ..rotation.set(0, 0, (_rng.nextDouble() - 0.5) * 2)
            ..scale.set(0, 0, 0)
            ..visible = false;
      _copies.add(copy);
      host.add(copy);
    }
    // Under the cell: the phage lands on top of it.
    host.add(_label('host', 0, -1.7, 0));

    final headMat = _rt_Material3D(
      color: const Color(0xFF8B5CF6),
      shininess: 0.4,
      edgeColor: const Color(0xFF6D28D9),
      edgeWidth: 1.5,
    );
    _phageHeadMat = headMat;
    final bobber = _phage(1, headMat);
    _phageBobber = bobber;
    final virusLabel = _label('virus', 0, 2.0, 0);
    _virusLabel = virusLabel;
    final virus = _rt_Node3D(name: 'virus')
      ..add(bobber)
      ..add(_proxy(_rt_Geometry3D.sphere(1.1))..position.y = 0.3)
      ..add(virusLabel);
    _setHome(virus, -3.0, 0.4, 0);
    _root
      ..add(host)
      ..add(_draggable('virus', virus));
  }

  void _buildDishes() {
    _root.add(
      _mesh(_rt_Geometry3D.box(14, 0.2, 7), const Color(0xFFCBD5E1))
        ..position.set(0, -1.1, 0.8)
        ..depthBias = 30,
    );
    const labels = ['control', 'dishA', 'dishB', 'dishC'];
    for (var i = 0; i < 4; i++) {
      final dish = _rt_Node3D(name: 'dish-$i')
        ..position.set(_dishX[i], -0.97, 0);
      final agar = _mesh(
        _rt_Geometry3D.cylinder(1.12, 1.12, 0.08, segments: 28),
        _agarColor,
      )..position.y = 0.07;
      dish
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(1.2, 1.2, 0.05, segments: 28),
            const Color(0xFFE0F2FE),
            opacity: 0.3,
          ),
        )
        ..add(agar)
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(
              1.2,
              1.2,
              0.25,
              segments: 28,
              openEnded: true,
            ),
            const Color(0xFFE0F2FE),
            opacity: 0.3,
            doubleSided: true,
          )..position.y = 0.125,
        )
        ..add(_label(labels[i], 0, 1.0, -1.0));
      if (i == 0) {
        // Colonies that appear on the Control dish after 24 hours.
        const tints = [Color(0xFFFFFBEB), Color(0xFFFDE68A), Color(0xFFD9F99D)];
        for (var k = 0; k < 16; k++) {
          final a = _rng.nextDouble() * 2 * math.pi;
          final r = math.sqrt(_rng.nextDouble()) * 0.95;
          final colony =
              _mesh(
                  _rt_Geometry3D.sphere(
                    0.08 + _rng.nextDouble() * 0.09,
                    widthSegments: 10,
                    heightSegments: 6,
                    thetaLength: math.pi / 2,
                  ),
                  tints[k % 3],
                  shininess: 0.5,
                )
                ..position.set(r * math.cos(a), 0.11, r * math.sin(a))
                ..scale.set(0, 0, 0)
                ..visible = false;
          _colonies.add(colony);
          dish.add(colony);
        }
      }
      _dishes.add(dish);
      _agars.add(agar);
      _root.add(dish);
    }

    // Heater (Dish A), drying agent (Dish B), vacuum lid (Dish C).
    final plate = _rt_Material3D(
      color: const Color(0xFFEF4444),
      emissive: const Color(0xFF7F1D1D),
      emissiveIntensity: 0.5,
    );
    _heaterPlate = plate;
    final heater = _rt_Node3D(name: 'heater')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.85, 0.95, 0.16, segments: 24),
          const Color(0xFF334155),
        ),
      )
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.7, 0.7, 0.05, segments: 24), plate)
          ..position.y = 0.1,
      )
      ..add(_proxy(_rt_Geometry3D.cylinder(1.0, 1.0, 0.8))..position.y = 0.2)
      ..add(_itemLabel('heater', 'heater', 0, -0.45, 0.7));
    _setHome(heater, -3.2, -0.92, 2.6);

    final dry = _rt_Node3D(name: 'dry')
      ..add(
        _mesh(
          _rt_Geometry3D.box(0.9, 0.12, 0.6),
          Colors.white,
          opacity: 0.95,
          edge: const Color(0xFF94A3B8),
        ),
      )
      ..add(
        _rt_Points3D(
          [
            for (var k = 0; k < 14; k++)
              _rt_V3(
                (_rng.nextDouble() - 0.5) * 0.7,
                0.08,
                (_rng.nextDouble() - 0.5) * 0.4,
              ),
          ],
          color: const Color(0xFF3B82F6),
          size: 3.5,
          sizeAttenuation: false,
        ),
      )
      ..add(_proxy(_rt_Geometry3D.box(1.6, 0.8, 1.2)))
      ..add(_itemLabel('dry', 'dryAgent', 0, -0.45, 0.6));
    _setHome(dry, 0, -0.92, 2.6);

    final lid = _rt_Node3D(name: 'lid')
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(
            1.3,
            widthSegments: 24,
            heightSegments: 8,
            thetaLength: math.pi / 2,
          ),
          const Color(0xFFE0F2FE),
          opacity: 0.3,
          doubleSided: true,
        ),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.torus(1.3, 0.06, radialSegments: 6),
          const Color(0xFF1E293B),
        )..rotation.x = math.pi / 2,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.12, 0.12, 0.35, segments: 10),
          const Color(0xFF1E293B),
        )..position.y = 1.4,
      )
      ..add(_itemLabel('lid', 'vacuum', 0, -0.45, 1.3));
    _setHome(lid, 3.2, -0.95, 2.6);
    _root
      ..add(_draggable('heater', heater))
      ..add(_draggable('dry', dry))
      ..add(_draggable('lid', lid));
  }

  /// Shows the props each step needs (the source swapped them per step).
  void _applyStepVisuals() {
    switch (_scenario) {
      case 1:
        _pond?.visible = _step <= 2;
        _table?.visible = _step >= 3;
        final d = _objects['dropper'];
        if (d != null) {
          d.visible = _step >= 2;
          if (_step >= 3) _setHome(d, 2.9, -0.2, 1.2);
        }
      case 2:
        _objects['dropper']?.visible = _step >= 3;
        _objects['flask']?.visible = _step <= 2;
        _objects['rod']?.visible = _step <= 2;
    }
  }

  // ------------------------------------------------------------ camera ---
  /// Points that must stay on screen in the current step.
  List<_rt_V3> get _framePoints => switch ((_scenario, _step)) {
    (1, 1) => [
      _rt_V3(-5.4, -2.2, 0),
      _rt_V3(5.4, -2.2, 0),
      _rt_V3(0, -2.2, -5.4),
      _rt_V3(0, -2.2, 5.4),
      _rt_V3(0, 0.6, -3.2),
    ],
    (1, 2) => [
      _rt_V3(-5.4, -2.2, 0),
      _rt_V3(5.4, -2.2, 0),
      _rt_V3(0, -2.2, -5.4),
      _rt_V3(0, -2.2, 5.4),
      _rt_V3(5.8, 3.3, 1.2),
      _rt_V3(5.8, -1.0, 1.2),
    ],
    (1, _) => [
      _rt_V3(-4, -1.9, -2.5),
      _rt_V3(4, -1.9, -2.5),
      _rt_V3(-4, -1.9, 2.5),
      _rt_V3(4, -1.9, 2.5),
      _rt_V3(2.9, 2.6, 1.2),
    ],
    (2, _) => [
      _rt_V3(-5.2, -3.0, -1.5),
      _rt_V3(5.2, -3.0, -1.5),
      _rt_V3(-5.2, -3.0, 2.5),
      _rt_V3(5.2, -3.0, 2.5),
      _rt_V3(_beakerX, 1.6, 0),
      _rt_V3(_beakerX + 1.9, 3.0, 0),
      _rt_V3(4.4, 1.6, 0.6),
    ],
    (3, _) => [
      _rt_V3(-5.4, 2.0, 0),
      _rt_V3(-4.0, -1.0, 0),
      _rt_V3(-4.0, 2.8, 0),
      _rt_V3(6.6, -1.3, 0),
      _rt_V3(6.6, 2.2, 0),
    ],
    (5, _) => [
      _rt_V3(-6.2, -1.0, -1.4),
      _rt_V3(6.2, -1.0, -1.4),
      _rt_V3(-6.2, -1.0, 3.6),
      _rt_V3(6.2, -1.0, 3.6),
      _rt_V3(0, 0.6, -1.2),
    ],
    _ => [_rt_V3()],
  };

  double get _elevation => switch (_scenario) {
    1 => 0.55,
    2 => 0.2,
    3 => 0.05,
    _ => 0.62,
  };

  /// Width of the chalkboard on the left of 3D scenarios (step 1).
  double _boardWidth(Size size, bool compact) =>
      math.min(compact ? 270.0 : 420.0, size.width * 0.5);

  /// Height of the panel over the top of the 3D view (MCQ, control-dish
  /// setup, Run button, conclusion): the camera frames the props below it.
  double _topReserve(bool compact) => switch ((_scenario, _step)) {
    (3, 4) => compact ? 190 : 250,
    (5, 2) => compact ? 170 : 230,
    (5, 4) when _showConclusion => compact ? 150 : 190,
    (5, 4) => 50,
    _ => 0,
  };

  /// Canvas size the camera was last fitted for (per scenario and step).
  (int, int, Size, double)? _fitKey;

  /// Frames the step's props in the space left by the chalkboard, the HUD
  /// and the toolbar (the source's fixed camera pushed props at x = 9 or
  /// +-6 off narrow screens). A few projection passes converge.
  void _fitCamera(Size size, bool compact) {
    final reserve = _topReserve(compact);
    final key = (_scenario, _step, size, reserve);
    if (_fitKey == key || size.isEmpty || _scenario == 4) return;
    _fitKey = key;
    final points = _framePoints;
    const margin = 14.0;
    final top = (compact ? 8.0 : 16.0) + reserve + margin;
    final bottom = size.height - (compact ? 62.0 : 90.0) - margin;
    final left = (_step == 1 ? 12 + _boardWidth(size, compact) : 10.0) + margin;
    final right = size.width - (_panelMode ? 10.0 : 60.0) - margin;
    if (bottom - top < 40 || right - left < 40) return;
    final e = _elevation;
    final back = _rt_V3(0, math.sin(e), math.cos(e));
    final up = _rt_V3(0, math.cos(e), -math.sin(e));
    var target = _rt_V3();
    for (final p in points) {
      target.add(p);
    }
    target = target / points.length.toDouble();
    var distance = 18.0;
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
    _camera.target.copy(target);
    _camera.position.copy(target + back * distance);
    _camera.zoom = 1;
    // Smaller labels on phones, where the dishes stand close together.
    for (final l in _labels) {
      l.pixelHeight = compact ? 10 : 12;
    }
    _camera.saveHome();
  }

  // ------------------------------------------------------------- frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);
    for (final (i, f) in _flagella.indexed) {
      f.rotation.z = 0.2 * math.sin(_clock * 4 + i * 1.7);
    }
    final bob = _phageBobber;
    if (bob != null) {
      final still = _infected || _busy || _dragId == 'virus';
      bob.position.y = still ? 0 : 0.15 * math.sin(_clock * 1.6);
      bob.rotation.y = still ? bob.rotation.y : _clock * 0.3;
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
    setState(() => _confetti = List.generate(150, (_) => _ConfettiPiece(_rng)));
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
      _sampled = _dropOnSlide = _covered = false;
      _waterAdded = _stirred = _microscope = false;
      _focus = 0;
      _labeled.clear();
      _classified.clear();
      _virusChecked = _infected = _mcqDone = false;
      _mcqWrong = null;
      _riddle.clear();
      _setup.clear();
      _controlSet = _ran = _showConclusion = false;
      _placedItems.clear();
      _blanks.clear();
      _selectedChip = null;
      _wrongZone = null;
      _dragId = null;
    });
    _buildScenario();
    final shuffle = math.Random(7 + s);
    _riddleOrder = (_riddleChips.keys.toList()..shuffle(shuffle));
    _conclusionOrder = (_conclusionChips.keys.toList()..shuffle(shuffle));
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
        title: last
            ? _tx.s('allComplete')
            : _tx.s('scComplete').replaceAll('{n}', '$scenario'),
        message: last ? _tx.s('allCompleteDesc') : null,
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

  /// The per-scenario summary the source never showed (bold kept).
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
    if (_busy || _scenarioDone || _microscope) return false;
    return switch ((_scenario, _step, id)) {
      (1, 2, 'dropper') => !_sampled,
      (1, 3, 'dropper') => !_dropOnSlide,
      (1, 3, 'coverslip') => _dropOnSlide && !_covered,
      (2, 2, 'flask') => !_waterAdded,
      (2, 2, 'rod') => _waterAdded && !_stirred,
      (2, 3, 'dropper') => true,
      (3, 3, 'virus') => !_infected,
      (5, 3, 'heater' || 'dry' || 'lid') => !_placedItems.contains(id),
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
    'dropper' => _rt_V3(0, -1.05, 0),
    'virus' => _rt_V3(0, 0.4, 0),
    'lid' => _rt_V3(0, 0.6, 0),
    _ => _rt_V3(),
  };

  _rt_V3 _handleWorld(String id) =>
      _objects[id]!.localTransform.apply(_handleLocal(id));

  /// Tight drop targets measured from the handle (the source measured from
  /// the object's origin with radii large enough for a bare click to pass).
  _DropWindow? _window(String id) => switch ((_scenario, id)) {
    // Tip (0.45 below the handle) dipped into the pond water.
    (1, 'dropper') when _step == 2 => _DropWindow(
      _rt_V3(0, -1.5, 0),
      3.2,
      0.5,
      0.6,
    ),
    // Tip just above the slide.
    (1, 'dropper') => _DropWindow(_rt_V3(0, -1.15, 0), 0.9, 0.3, 0.7),
    (1, 'coverslip') => _DropWindow(_rt_V3(0, -1.6, 0), 0.8, 0.3, 1.0),
    (2, 'flask') => _DropWindow(_rt_V3(_beakerX + 0.3, 1.5, 0), 1.8, 1.3, 2.0),
    (2, 'rod') => _DropWindow(_rt_V3(_beakerX, 0.2, 0), 1.1, 1.1, 1.1),
    // Tip in the clear top layer (-1.45 .. 0.05).
    (2, 'dropper') => _DropWindow(_rt_V3(_beakerX, -0.15, 0), 1.1, 0.8, 0.6),
    (3, 'virus') => _DropWindow(_rt_V3(2.2, 0.4, 0), 2.3, 1.8, 1.6),
    (5, 'heater' || 'dry') => _DropWindow(
      _rt_V3(_dishX[_items[id]!.$1], -0.85, 0),
      1.0,
      0.6,
      1.6,
    ),
    (5, 'lid') => _DropWindow(_rt_V3(_dishX[3], -0.35, 0), 1.0, 0.8, 1.4),
    _ => null,
  };

  /// Lowest the handle may go (no dragging through tables or beakers).
  double _floorY(String id) => switch ((_scenario, id)) {
    (1, 'dropper') when _step == 2 => -1.85,
    (1, 'dropper') => -1.37,
    (1, 'coverslip') => -1.86,
    (2, 'flask') => -2.25,
    (2, 'rod') => -0.9,
    (2, 'dropper') => -2.45,
    (5, 'lid') => -0.37,
    (5, _) => -0.95,
    _ => -6,
  };

  bool _onPointerDown(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['drag'] != null);
    if (hit == null) return false;
    final id = hit.userData['drag'] as String;
    if (!_grabbable(id)) {
      // Explain objects that are not ready yet (and keep the camera still).
      if (_busy || _scenarioDone) return false;
      if (_scenario == 1 && _step == 3 && id == 'coverslip' && !_dropOnSlide) {
        _toast('fbDropFirst', good: false);
        return true;
      }
      if (_scenario == 2 && _step == 2 && id == 'rod' && !_waterAdded) {
        _toast('fbWaterFirst', good: false);
        return true;
      }
      return false;
    }
    final window = _window(id);
    final handle = e.frame.project(_handleWorld(id));
    if (window == null || handle == null) return false;
    final fwd = e.frame.fwd;
    final normal = _rt_V3(fwd.x, 0, fwd.z);
    if (normal.lengthSq < 1e-6) {
      normal.set(0, 0, 1);
    } else {
      normal.normalize();
    }
    _planePoint = window.centre;
    _planeNormal = normal;
    _grabOffset = handle - e.position;
    _dragTravel = 0;
    _lastPointer = e.position;
    if (id == 'rod') _objects['rod']!.rotation.set(0, 0, -0.2);
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

  /// Judges where [id] was let go.
  void _release(String id) {
    final w = _window(id);
    final n = _planeNormal;
    if (w == null || n == null) return;
    final h = _handleWorld(id);
    final side = (h - w.centre).dot(_rt_V3(n.z, 0, -n.x));
    final dy = h.y - w.centre.y;
    final across = side.abs() <= w.halfWidth;
    final inside = across && dy >= -w.below && dy <= w.above;
    switch ((_scenario, id)) {
      case (1, 'dropper') when _step == 2:
        inside ? _collect() : _miss(id, 'fbPondMiss');
      case (1, 'dropper'):
        inside ? _dropOnSlideAct() : _miss(id, 'fbSlideMiss');
      case (1, 'coverslip'):
        inside ? _lowerCoverslip() : _miss(id, 'fbCoverMiss');
      case (2, 'flask'):
        inside ? _pour() : _miss(id, 'fbFlaskMiss');
      case (2, 'rod'):
        inside ? _stir() : _miss(id, 'fbRodMiss');
      case (2, 'dropper'):
        if (inside) {
          _sample();
        } else {
          _miss(id, across && dy < -w.below ? 'fbTopLayer' : 'fbBeakerMiss');
        }
      case (3, 'virus'):
        inside ? _infect() : _miss(id, 'fbHostMiss');
      case (5, _):
        if (inside) {
          _placeItem(id);
          return;
        }
        final onControl =
            (h.x - _dishX[0]).abs() <= 1.0 && dy >= -w.below && dy <= w.above;
        _miss(id, onControl ? 'fbNotControl' : _items[id]!.$3);
    }
  }

  void _miss(String id, String key) {
    _toast(key, good: false, ms: 3000);
    _snapBack(id);
  }

  Future<void> _snapBack(String id) async {
    final node = _objects[id];
    if (node == null) return;
    final home = node.userData['home'] as _rt_V3;
    final homeRot = node.userData['homeRot'] as _rt_V3;
    final run = _run;
    setState(() => _busy = true);
    await _tweenNode(node, home, 350, rot: homeRot);
    if (!_alive(run)) return;
    setState(() => _busy = false);
  }

  // ------------------------------------------------- scenario 1 actions ---
  Future<void> _collect() async {
    if (_busy || _sampled || _scenario != 1 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final d = _objects['dropper']!;
    // Dip the tip under the surface, squeeze, lift it out full.
    await _tweenNode(d, _rt_V3(0.8, -0.4, 0.6), 550);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _dropperLiquid?.visible = true;
    _sampled = true;
    await _tweenNode(d, _rt_V3(0.8, 0.8, 0.6), 400);
    if (!_alive(run)) return;
    _toast('fbSampled');
    _advance(); // the table with the slide replaces the pond
  }

  Future<void> _dropOnSlideAct() async {
    if (_busy || _dropOnSlide || _scenario != 1 || _step != 3) return;
    final run = _run;
    setState(() => _busy = true);
    final d = _objects['dropper']!;
    await _tweenNode(d, _rt_V3(0, -0.15, 0), 500);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _dropperLiquid?.visible = false;
    final drop = _slideDrop!..visible = true;
    await _tweens.run(300, (t) => drop.scale.set(t, 0.5 * t, t));
    if (!_alive(run)) return;
    await _tweenNode(d, d.userData['home'] as _rt_V3, 500);
    if (!_alive(run)) return;
    setState(() {
      _dropOnSlide = true;
      _busy = false;
    });
    _toast('fbDropPlaced', ms: 3500);
  }

  /// Rests one edge on the slide at 45 degrees, then lowers the coverslip
  /// so it pushes the air out (the source just snapped it flat).
  Future<void> _lowerCoverslip() async {
    if (_busy || _covered || !_dropOnSlide) return;
    final run = _run;
    setState(() => _busy = true);
    final c = _objects['coverslip']!;
    const edgeX = -0.4, edgeY = -1.835;
    _rt_V3 at(double a) =>
        _rt_V3(edgeX + 0.4 * math.cos(a), edgeY + 0.4 * math.sin(a), 0);
    await _tweenNode(c, at(math.pi / 4), 500, rot: _rt_V3(0, 0, math.pi / 4));
    if (!_alive(run)) return;
    final drop = _slideDrop!;
    await _tweens.run(900, (t) {
      final a = math.pi / 4 * (1 - t);
      c.position.copy(at(a));
      c.rotation.set(0, 0, a);
      drop.scale.set(1 + 0.8 * t, 0.5 - 0.35 * t, 1 + 0.8 * t);
    }, ease: _rt_Ease.inOutQuad);
    if (!_alive(run)) return;
    _covered = true;
    _toast('fbCoverslip', ms: 3500);
    _after(1000, () {
      setState(() => _microscope = true);
      _advance();
    });
  }

  void _setFocus(double v) {
    if (!_microscope || _scenario != 1 || _scenarioDone) return;
    var value = v.clamp(0, 100).toDouble();
    if (value >= 95) value = 100;
    final wasSharp = _focus == 100;
    setState(() => _focus = value);
    if (value == 100 && !wasSharp) _toast('fbFocused');
  }

  /// A label chip dropped (or tap-placed) on an organism.
  void _labelOrganism(String chip, String zone) {
    if (!_microscope || _scenario != 1 || _busy || _labeled.contains(chip)) {
      return;
    }
    setState(() => _selectedChip = null);
    if (_focus < 100) {
      _toast('fbBlurry', good: false);
      return;
    }
    if (chip != zone) {
      _flashZone(zone);
      _toast('fbLabelWrong', good: false, ms: 3500);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _labeled.add(chip));
    if (_labeled.length == 2) {
      _busy = true;
      _after(1000, _completeScenario);
    } else {
      _toast('fbLabelRight', ms: 1500);
    }
  }

  // ------------------------------------------------- scenario 2 actions ---
  Future<void> _pour() async {
    if (_busy || _waterAdded || _scenario != 2 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final f = _objects['flask']!;
    await _tweenNode(f, _rt_V3(_beakerX + 1.9, 1.3, 0), 500);
    if (!_alive(run)) return;
    await _tweenNode(f, f.position.clone(), 300, rot: _rt_V3(0, 0, 1.2));
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    final stream = _stream!..visible = true;
    final water = _waterPivot!..visible = true;
    await _tweens.run(
      1000,
      (t) => water.scale.y = 0.05 + 0.95 * t,
      ease: _rt_Ease.linear,
    );
    if (!_alive(run)) return;
    stream.visible = false;
    _flaskWater?.visible = false;
    await _tweenNode(f, f.position.clone(), 250, rot: _rt_V3());
    if (!_alive(run)) return;
    await _tweenNode(f, f.userData['home'] as _rt_V3, 450);
    if (!_alive(run)) return;
    setState(() {
      _waterAdded = true;
      _busy = false;
    });
    _toast('fbWaterAdded', ms: 3500);
  }

  /// Stirs, then lets the suspension settle into visible layers (content
  /// fix: the source turned all the water grey).
  Future<void> _stir() async {
    if (_busy || _stirred || !_waterAdded || _scenario != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final r = _objects['rod']!;
    await _tweenNode(
      r,
      _rt_V3(_beakerX + 0.55, 0.1, 0),
      400,
      rot: _rt_V3(0, 0, -0.2),
    );
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    final water = _waterMesh!.material;
    final soil = _soilPivot!;
    await _tweens.run(1400, (t) {
      final a = t * 4 * math.pi;
      r.position.set(_beakerX + 0.55 * math.cos(a), 0.1, 0.55 * math.sin(a));
      water
        ..color = Color.lerp(_clearWater, _muddyWater, t)!
        ..opacity = 0.55 + 0.3 * t;
      soil.scale.y = 1 - 0.45 * t;
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    await _tweenNode(
      r,
      r.userData['home'] as _rt_V3,
      400,
      rot: r.userData['homeRot'] as _rt_V3,
    );
    if (!_alive(run)) return;
    _shell.showToast(
      _tx.s('fbSettling'),
      icon: Icons.hourglass_bottom,
      color: _accent,
      ms: 1800,
    );
    final cloudy = _cloudy!..visible = true;
    final pivot = _waterPivot!;
    await _tweens.run(1800, (t) {
      water
        ..color = Color.lerp(_muddyWater, _topWater, t)!
        ..opacity = 0.85 - 0.45 * t;
      cloudy.material.opacity = 0.7 * t;
      pivot
        ..position.y = -0.7 + 0.5 * t
        ..scale.y = 1 - 0.25 * t;
      soil.scale.y = 0.55 + 0.15 * t;
    }, ease: _rt_Ease.inOutQuad);
    if (!_alive(run)) return;
    _stirred = true;
    _toast('fbSettled', ms: 3500);
    _after(600, _advance);
  }

  Future<void> _sample() async {
    if (_busy || _microscope || _scenario != 2 || _step != 3) return;
    final run = _run;
    setState(() => _busy = true);
    final d = _objects['dropper']!;
    await _tweenNode(d, _rt_V3(_beakerX, 0.85, 0), 500); // tip at -0.65
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _dropperLiquid
      ?..material.color = _topWater
      ..visible = true;
    await _tweenNode(d, d.userData['home'] as _rt_V3, 500);
    if (!_alive(run)) return;
    _after(400, () {
      setState(() => _microscope = true);
      _advance();
    });
  }

  /// [what] is 'mould' or 'bacteria'.
  void _classify(String what) {
    if (!_microscope || _scenario != 2 || _busy || _classified.contains(what)) {
      return;
    }
    setState(() => _classified.add(what));
    _toast(what == 'mould' ? 'fbMould' : 'fbBacteria');
    if (_classified.length == 2) {
      _busy = true;
      _after(1500, _completeScenario);
    }
  }

  // ------------------------------------------------- scenario 3 actions ---
  void _checkVirus() {
    if (_scenario != 3 || _step != 2 || _busy || _virusChecked) return;
    setState(() {
      _busy = true;
      _virusChecked = true;
    });
    _rt_playSfx(_rt_Sfx.pop);
    _shell.showToast(
      _tx.s('fbInert'),
      icon: Icons.pause_circle,
      color: _accent,
      ms: 2500,
    );
    final body = _phageBobber;
    if (body != null) {
      unawaited(
        _tweens.run(600, (t) {
          final s = 1 + 0.2 * math.sin(t * math.pi);
          body.scale.set(s, s, s);
        }),
      );
    }
    _after(1600, _advance);
  }

  Future<void> _infect() async {
    if (_busy || _infected || _scenario != 3 || _step != 3) return;
    final run = _run;
    setState(() => _busy = true);
    final v = _objects['virus']!;
    // The phage lands tail-first on the cell wall ...
    await _tweenNode(v, _rt_V3(1.6, 1.6, 0), 600, rot: _rt_V3());
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _virusLabel?.userData['hidden'] = true;
    _syncLabels();
    // ... injects its genetic material (the head empties) ...
    final head = _phageHeadMat!;
    await _tweens.run(500, (t) => head.opacity = 1 - 0.6 * t);
    if (!_alive(run)) return;
    _shell.showToast(
      _tx.s('fbMultiplying'),
      icon: Icons.coronavirus,
      color: _rt_Tw.violet500,
      ms: 2500,
    );
    // ... and the cell assembles new viruses.
    for (final c in _copies) {
      c.visible = true;
    }
    final n = _copies.length;
    await _tweens.run(1500, (t) {
      for (final (i, c) in _copies.indexed) {
        final k = ((t - i / n * 0.6) / 0.4).clamp(0.0, 1.0);
        c.scale.set(k, k, k);
      }
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    _infected = true;
    _after(900, _advance);
  }

  void _answerMcq(String option) {
    if (_scenario != 3 || _step != 4 || _mcqDone || _busy) return;
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

  void _onCanvasTap(_rt_SceneEvent e) {
    if (_scenario == 3 && _step == 2) {
      if (e.hitWhere((n) => n.userData['drag'] == 'virus') != null) {
        _checkVirus();
      }
    }
  }

  // ------------------------------------------------- scenario 4 actions ---
  void _matchRiddle(String chip, String card) {
    if (_scenario != 4 || _step != 2 || _busy) return;
    if (_riddle.containsValue(chip) || _riddle.containsKey(card)) return;
    setState(() => _selectedChip = null);
    if (chip != card) {
      _flashZone(card);
      _toast(_riddleChips[chip]!.$2, good: false, ms: 3500);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _riddle[card] = chip);
    if (_riddle.length == _riddleCards.length) {
      _busy = true;
      _after(900, _completeScenario);
    }
  }

  // ------------------------------------------------- scenario 5 actions ---
  void _choose(String group, String value) {
    if (_scenario != 5 || _step != 2 || _controlSet) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _setup[group] = value);
  }

  void _confirmSetup() {
    if (_scenario != 5 || _step != 2 || _busy || _controlSet) return;
    if (!_setupGroups.every((g) => _setup[g.$1] == g.$4)) {
      _toast('fbControlWrong', good: false, ms: 3500);
      return;
    }
    setState(() {
      _controlSet = true;
      _busy = true;
    });
    _toast('fbControlRight');
    _after(700, _advance);
  }

  Future<void> _placeItem(String id) async {
    if (_busy || _placedItems.contains(id) || _scenario != 5 || _step != 3) {
      return;
    }
    final run = _run;
    setState(() => _busy = true);
    final n = _objects[id]!;
    final (dish, _, _, placedKey) = _items[id]!;
    final x = _dishX[dish];
    switch (id) {
      case 'heater':
        // Heater under Dish A: the dish sits on the hot plate.
        await _tweenNode(n, _rt_V3(x, -0.92, 0), 500, rot: _rt_V3());
        if (!_alive(run)) return;
        final d = _dishes[dish];
        final plate = _heaterPlate;
        await _tweens.run(400, (t) {
          d.position.y = -0.97 + 0.2 * t;
          plate?.emissiveIntensity = 0.5 + 0.5 * t;
        });
      case 'dry':
        // Drying agent beside the agar: Dish B keeps its agar (one change).
        await _tweenNode(n, _rt_V3(x + 0.5, -0.8, 0.5), 500, rot: _rt_V3());
        if (!_alive(run)) return;
        final agar = _agars[dish];
        await _tweens.run(900, (t) {
          agar.material.color = Color.lerp(_agarColor, _dryAgarColor, t)!;
          agar.scale.set(1 - 0.06 * t, 1 - 0.5 * t, 1 - 0.06 * t);
        });
      default:
        await _tweenNode(n, _rt_V3(x, -0.97, 0), 500, rot: _rt_V3());
    }
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.correct);
    // The dish label now names the change.
    _itemLabels[id]?.userData['hidden'] = true;
    _syncLabels();
    setState(() {
      _placedItems.add(id);
      _busy = false;
    });
    if (_placedItems.length == _items.length) {
      _toast('fbAllSet');
      _busy = true;
      _after(800, _advance);
    } else {
      _toast(placedKey, ms: 2000);
    }
  }

  Future<void> _runExperiment() async {
    if (_scenario != 5 || _step != 4 || _ran || _busy) return;
    final run = _run;
    setState(() {
      _ran = true;
      _busy = true;
    });
    _rt_playSfx(_rt_Sfx.magic);
    for (final c in _colonies) {
      c.visible = true;
    }
    final n = _colonies.length;
    await _tweens.run(2000, (t) {
      for (final (i, c) in _colonies.indexed) {
        final k = ((t - i / n * 0.5) / 0.5).clamp(0.0, 1.0);
        c.scale.set(k, k * 0.6, k);
      }
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    _shell.showToast(
      _tx.s('fbColonies'),
      icon: Icons.bubble_chart,
      color: _accent,
      ms: 3000,
    );
    _after(
      800,
      () => setState(() {
        _showConclusion = true;
        _busy = false;
      }),
    );
  }

  void _fillBlank(String chip, String blank) {
    if (!_showConclusion || _busy || _scenarioDone) return;
    if (_blanks.containsValue(chip) || _blanks.containsKey(blank)) return;
    setState(() => _selectedChip = null);
    if (chip != blank) {
      _flashZone(blank);
      _toast('fbBlankWrong', good: false);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _blanks[blank] = chip);
    if (_blanks.length == _conclusionChips.length) {
      _busy = true;
      _after(900, _completeScenario);
    }
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

  /// Sidebar twins of the 3D drags: (key, label key, action, done). The
  /// action is null while it is not available (busy, done or not yet).
  List<(String, String, VoidCallback?, bool)> get _twins {
    (String, String, VoidCallback?, bool) twin(
      String key,
      String label,
      bool ready,
      bool done,
      VoidCallback fn,
    ) => (key, label, ready && !done && !_busy ? fn : null, done);
    return switch ((_scenario, _step)) {
      (1, 2) => [twin('twin-collect', 'twCollect', true, _sampled, _collect)],
      (1, 3) => [
        twin('twin-drop', 'twDrop', true, _dropOnSlide, _dropOnSlideAct),
        twin('twin-cover', 'twCover', _dropOnSlide, _covered, _lowerCoverslip),
      ],
      (2, 2) => [
        twin('twin-pour', 'twPour', true, _waterAdded, _pour),
        twin('twin-stir', 'twStir', _waterAdded, _stirred, _stir),
      ],
      (2, 3) => [twin('twin-sample', 'twSample', true, _microscope, _sample)],
      (3, 2) => [
        twin('twin-check', 'twCheck', true, _virusChecked, _checkVirus),
      ],
      (3, 3) => [twin('twin-infect', 'twInfect', true, _infected, _infect)],
      (5, 3) => [
        for (final MapEntry(key: id, value: v) in _items.entries)
          twin(
            'twin-$id',
            v.$2,
            true,
            _placedItems.contains(id),
            () => _placeItem(id),
          ),
      ],
      _ => const [],
    };
  }

  /// Blur of the S1 microscope image (sharp at 100 %).
  double get _blur => _scenario == 1 && _microscope ? (100 - _focus) / 10 : 0;

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
              headerGradient: [_rt_Tw.slate900, Color(0xFF134E4A)],
              headerSubtitleColor: Color(0xFF99F6E4),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('appSubtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.biotech,
              buttonIcon: Icons.science,
            ),
            onRestart: _restart,
            // The microscope and riddle boards have nothing to zoom/rotate.
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
        if (_microscope) Positioned.fill(child: _microscopePanel(compact)),
        if (_scenario == 4 && _step > 1)
          Positioned.fill(child: _riddleBoard(compact)),
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

  /// Dashed rings where grabbable objects go, and a hand on each object
  /// (the source only showed a hand while dragging).
  Widget _markers(Size size, bool compact) {
    if (size.isEmpty) return const SizedBox.shrink();
    final frame = _camera.frame(size);
    final dragging = _dragId;
    final ids = dragging != null ? [dragging] : _grabbableIds;
    final ring = compact ? 46.0 : 60.0;
    final children = <Widget>[];
    for (final id in ids) {
      final w = _window(id);
      final t = w == null ? null : frame.project(w.centre);
      if (t != null) {
        children.add(
          Positioned(
            left: t.dx - ring / 2,
            top: t.dy - ring / 2,
            width: ring,
            height: ring,
            child: CustomPaint(
              key: ValueKey('target-$id'),
              painter: _DashedPainter(
                dragging == id ? _rt_Tw.amber400 : Colors.white70,
                round: true,
                fill: dragging == id,
              ),
            ),
          ),
        );
      }
      if (dragging == null) {
        final h = frame.project(_handleWorld(id));
        if (h != null) children.add(_hand('grab-$id', h, Icons.pan_tool_alt));
      }
    }
    // S3 step 2: the virus is tapped, not dragged.
    if (_scenario == 3 && _step == 2 && !_virusChecked && !_busy) {
      final h = frame.project(_handleWorld('virus'));
      if (h != null) children.add(_hand('tap-virus', h, Icons.touch_app));
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
    final centred = _scenario == 4; // no 3D scene behind the riddles
    final width = centred
        ? math.min(compact ? 340.0 : 480.0, size.width * 0.8)
        : _boardWidth(size, compact);
    return Positioned(
      left: centred ? (size.width - width) / 2 : 12,
      top: 8,
      bottom: compact ? 64 : 84,
      width: width,
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

  // ------------------------------------------------------- step panels ---
  List<Widget> _stepPanels(bool compact) {
    if (_scenarioDone) return const [];
    switch ((_scenario, _step)) {
      case (3, 4):
        return [_topPanel(_mcqPanel(compact))];
      case (5, 2):
        return [_topPanel(_setupPanel(compact))];
      case (5, 4) when !_ran:
        return [
          Positioned(
            top: 12,
            left: 12,
            right: 64,
            child: Center(
              child: _rt_ActionButton(
                key: const ValueKey('btn-run'),
                label: _tx.s('runExp'),
                icon: Icons.play_arrow,
                color: _rt_Tw.indigo600,
                onPressed: _busy ? null : _runExperiment,
              ),
            ),
          ),
        ];
      case (5, 4) when _showConclusion:
        return [_topPanel(_conclusionPanel(compact))];
      default:
        return const [];
    }
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
        // No option is pre-highlighted (the source coloured the answer).
        for (final o in const ['A', 'B', 'C'])
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 4 : 6),
            child: _rt_ChoiceButton(
              key: ValueKey('mcq-$o'),
              label: _tx.s('mcq$o'),
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

  Widget _setupPanel(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('setupTitle')),
        for (final (group, labelKey, options, _) in _setupGroups)
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 5 : 8),
            child: Row(
              children: [
                SizedBox(
                  width: compact ? 88 : 116,
                  child: Text(
                    _tx.s(labelKey),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final (value, key) in options)
                        _option(group, value, key, compact),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 2),
        Center(
          child: _rt_ActionButton(
            key: const ValueKey('btn-confirm'),
            label: _tx.s('confirmSetup'),
            icon: Icons.check,
            color: _accent,
            done: _controlSet,
            onPressed: _controlSet ? null : _confirmSetup,
          ),
        ),
      ],
    );
  }

  Widget _option(String group, String value, String labelKey, bool compact) {
    final on = _setup[group] == value;
    return InkWell(
      key: ValueKey('opt-$group-$value'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => _choose(group, value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: on ? _accent : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? _accentSoft : Colors.white24),
        ),
        child: Text(
          _tx.s(labelKey),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _conclusionPanel(bool compact) {
    final style = TextStyle(
      fontSize: compact ? 12.5 : 14,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final sentence = _tx.s('conclusion');
    final pieces = <Widget>[];
    void words(String text) {
      for (final w in text.split(' ')) {
        if (w.isNotEmpty) {
          pieces.add(
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(w, style: style),
            ),
          );
        }
      }
    }

    var last = 0;
    for (final m in RegExp(r'\{(\w+)\}').allMatches(sentence)) {
      words(sentence.substring(last, m.start));
      pieces.add(
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: _blank(m.group(1)!, compact),
        ),
      );
      last = m.end;
    }
    words(sentence.substring(last));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('resultsTitle')),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 6,
          children: pieces,
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          _tx.s('dragWords'),
          style: const TextStyle(fontSize: 10.5, color: Colors.white60),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final id in _conclusionOrder)
              if (!_blanks.containsValue(id))
                _draggableChip(id, _conclusionChips[id]!, _accentSoft, compact),
          ],
        ),
      ],
    );
  }

  Widget _blank(String id, bool compact) {
    return _dropZone(
      key: 'blank-$id',
      zone: id,
      onDrop: (chip) => _fillBlank(chip, id),
      builder: (hover, color) {
        final filled = _blanks[id];
        return Container(
          constraints: BoxConstraints(minWidth: compact ? 84 : 110),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: filled != null
                ? _rt_Tw.emerald600
                : (hover ? const Color(0x33FBBF24) : const Color(0x22FFFFFF)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: filled != null ? _rt_Tw.emerald400 : color,
              width: 1.5,
            ),
          ),
          child: Text(
            filled != null ? _tx.s(_conclusionChips[filled]!) : '?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------- microscope ---
  Widget _microscopePanel(bool compact) {
    final s1 = _scenario == 1;
    final side = compact ? 150.0 : 210.0;
    return Container(
      color: const Color(0xF2020617),
      padding: EdgeInsets.fromLTRB(12, compact ? 6 : 14, 12, compact ? 72 : 88),
      child: Column(
        children: [
          Text(
            _tx.s('microTitle').toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: _accentSoft,
            ),
          ),
          SizedBox(height: compact ? 4 : 10),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: side,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _statusCard(compact),
                          if (s1) ...[
                            const SizedBox(height: 8),
                            _focusPanel(compact),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) => Center(
                      child: _lens(
                        math.min(
                          math.min(c.maxWidth, c.maxHeight),
                          compact ? 320.0 : 440.0,
                        ),
                        compact,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: compact ? 118 : 160,
                  child: Center(
                    child: s1 ? _labelTray(compact) : _classifyHint(compact),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(bool compact) {
    final rows = _scenario == 1
        ? [
            ('amoeba', _labeled.contains('amoeba')),
            ('paramecium', _labeled.contains('paramecium')),
          ]
        : [
            ('mould', _classified.contains('mould')),
            ('bacteria', _classified.contains('bacteria')),
          ];
    return _glass(
      padding: EdgeInsets.all(compact ? 8 : 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelTitle(_tx.s('obsStatus')),
          for (final (id, yes) in rows)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _tx.s(id),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    key: ValueKey('status-$id'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: yes ? _rt_Tw.emerald500 : _rt_Tw.slate700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _tx.s(yes ? 'yes' : 'no').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Sharpness slider with +/- twins; its ends now read Blurry / Sharp.
  Widget _focusPanel(bool compact) {
    Widget nudge(String key, IconData icon, double delta) => InkResponse(
      key: ValueKey(key),
      radius: 18,
      onTap: () {
        _rt_playSfx(_rt_Sfx.tap);
        _setFocus(_focus + delta);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _rt_Lab.surface,
          shape: BoxShape.circle,
          border: Border.all(color: _accent),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
    const ends = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: Colors.white60,
    );
    return _glass(
      padding: EdgeInsets.all(compact ? 8 : 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelTitle(_tx.s('adjustFocus')),
          Text(
            '${_focus.round()}%',
            key: const ValueKey('focus-value'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accent,
              thumbColor: _accentSoft,
              inactiveTrackColor: Colors.white24,
            ),
            child: Slider(
              key: const ValueKey('slider-focus'),
              value: _focus.clamp(0, 100),
              max: 100,
              divisions: 20,
              onChanged: _labeled.length == 2 ? null : _setFocus,
            ),
          ),
          Row(
            children: [
              nudge('btn-focus-minus', Icons.remove, -10),
              const SizedBox(width: 4),
              Expanded(child: Text(_tx.s('blurry'), style: ends)),
              Expanded(
                child: Text(
                  _tx.s('sharp'),
                  textAlign: TextAlign.right,
                  style: ends,
                ),
              ),
              const SizedBox(width: 4),
              nudge('btn-focus-plus', Icons.add, 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelTray(bool compact) {
    final chips = const [
      'amoeba',
      'paramecium',
    ].where((c) => !_labeled.contains(c));
    return _glass(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('dragLabels'),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          for (final id in chips) ...[
            const SizedBox(height: 6),
            _draggableChip(
              id,
              id,
              id == 'amoeba'
                  ? const Color(0xFF93C5FD)
                  : const Color(0xFFA7F3D0),
              compact,
            ),
          ],
        ],
      ),
    );
  }

  Widget _classifyHint(bool compact) {
    return _glass(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 18, color: _accentSoft),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _tx.s('tapStructures'),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lens(double d, bool compact) {
    final s1 = _scenario == 1;
    final border = compact ? 6.0 : 8.0;
    final inner = math.max(0.0, d - 2 * border);
    final blur = _blur;
    return Container(
      key: const ValueKey('micro-lens'),
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _rt_Tw.slate100,
        border: Border.all(color: _rt_Tw.slate700, width: border),
        boxShadow: const [BoxShadow(color: Color(0x6614B8A6), blurRadius: 24)],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                enabled: blur > 0.05,
                imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: ValueListenableBuilder<int>(
                  valueListenable: _frameTick,
                  builder: (context, _, _) => CustomPaint(
                    painter: _MicroPainter(
                      scenario: _scenario,
                      clock: _clock,
                      found: {..._labeled, ..._classified},
                    ),
                  ),
                ),
              ),
            ),
            if (s1) ...[
              _organismZone(
                'amoeba',
                const Rect.fromLTWH(0.03, 0.18, 0.44, 0.44),
                inner,
              ),
              _organismZone(
                'paramecium',
                const Rect.fromLTWH(0.53, 0.38, 0.42, 0.42),
                inner,
              ),
            ] else
              Positioned.fill(
                child: GestureDetector(
                  key: const ValueKey('micro-tap'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    if (inner <= 0) return;
                    final hit = _MicroPainter.hitTest2(
                      details.localPosition * (100 / inner),
                    );
                    if (hit != null) _classify(hit);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _organismZone(String id, Rect f, double inner) {
    return Positioned(
      left: f.left * inner,
      top: f.top * inner,
      width: f.width * inner,
      height: f.height * inner,
      child: _dropZone(
        key: 'zone-$id',
        zone: id,
        idle: _rt_Tw.slate500,
        onDrop: (chip) => _labelOrganism(chip, id),
        builder: (hover, color) {
          final done = _labeled.contains(id);
          return CustomPaint(
            painter: _DashedPainter(
              done ? _rt_Tw.green600 : color,
              round: true,
              fill: hover,
            ),
            child: done
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Tw.green600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _tx.s(id),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------- riddles ---
  Widget _riddleBoard(bool compact) {
    return Container(
      color: const Color(0xF20F172A),
      padding: EdgeInsets.fromLTRB(12, compact ? 8 : 14, 12, compact ? 72 : 88),
      child: Column(
        children: [
          Text(
            _tx.s('riddlesTitle'),
            style: TextStyle(
              fontSize: compact ? 14 : 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: compact ? 6 : 12),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, (id, clue)) in _riddleCards.indexed) ...[
                        if (i > 0) SizedBox(width: compact ? 6 : 12),
                        Expanded(child: _riddleCard(id, clue, compact)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 6 : 10),
          Text(
            _tx.s('dragIcons'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _accentSoft,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final id in _riddleOrder)
                if (!_riddle.containsValue(id))
                  _draggableChip(
                    id,
                    _riddleChips[id]!.$1,
                    _riddleChips[id]!.$3,
                    compact,
                    icon: CustomPaint(
                      size: const Size(20, 20),
                      painter: _RiddleIconPainter(id),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riddleCard(String id, String clueKey, bool compact) {
    final matched = _riddle[id];
    final zone = compact ? 54.0 : 76.0;
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 14),
      decoration: BoxDecoration(
        color: _rt_Tw.slate100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: matched != null ? _rt_Tw.green500 : _accent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '"${_tx.s(clueKey)}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w700,
                color: _rt_Tw.slate700,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          _dropZone(
            key: 'card-$id',
            zone: id,
            idle: _rt_Tw.slate400,
            onDrop: (chip) => _matchRiddle(chip, id),
            builder: (hover, color) => SizedBox(
              width: zone,
              height: zone,
              child: CustomPaint(
                painter: _DashedPainter(
                  matched != null ? _rt_Tw.green500 : color,
                  round: true,
                  fill: hover,
                ),
                child: Center(
                  child: matched != null
                      ? CustomPaint(
                          size: Size.square(zone * 0.5),
                          painter: _RiddleIconPainter(matched),
                        )
                      : Icon(Icons.help_outline, color: color),
                ),
              ),
            ),
          ),
          if (matched != null) ...[
            const SizedBox(height: 4),
            Text(
              _tx.s(_riddleChips[matched]!.$1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _rt_Tw.green700,
              ),
            ),
          ],
        ],
      ),
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
                  label: _tx.s(label),
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
      color: _rt_Lab.onTinted(_accentSoft, _rt_Tw.teal700),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: current
            ? _rt_Lab.tinted(_rt_Tw.teal50, _accent)
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

/// The microscope image: pond organisms (S1, animated as in the source SVG)
/// or soil microbes (S2). Coordinates are the source's 100 x 100 viewBox.
class _MicroPainter extends CustomPainter {
  _MicroPainter({
    required this.scenario,
    required this.clock,
    required this.found,
  });

  final int scenario;
  final double clock;
  final Set<String> found;

  // Amoeba outline keyframes: start + (quadratic control, end) pairs, from
  // "M 20,40 Q 40,20 60,30 T 70,60 T 40,80 T 15,50 Z" and its second frame
  // (the T controls are the reflections of the previous control).
  static const _amoebaA = [
    Offset(20, 40),
    Offset(40, 20), Offset(60, 30), //
    Offset(80, 40), Offset(70, 60),
    Offset(60, 80), Offset(40, 80),
    Offset(20, 80), Offset(15, 50),
  ];
  static const _amoebaB = [
    Offset(25, 35),
    Offset(50, 15), Offset(65, 35), //
    Offset(80, 55), Offset(75, 65),
    Offset(70, 75), Offset(35, 75),
    Offset(0, 75), Offset(10, 45),
  ];

  /// Bacilli: rect (x, y, w, h) rotated by deg around (cx, cy).
  static const _rods = [
    (75.0, 25.0, 14.0, 5.5, 30.0, 82.0, 27.0),
    (85.0, 35.0, 14.0, 5.5, 45.0, 92.0, 37.0),
    (70.0, 40.0, 14.0, 5.5, 15.0, 77.0, 42.0),
    (30.0, 20.0, 12.0, 5.0, -20.0, 36.0, 22.0),
  ];
  static const _cocci = [
    Offset(25, 85),
    Offset(31, 87),
    Offset(37, 83),
    Offset(33, 77),
    Offset(27, 79),
  ];

  /// Hyphae as quadratic segments (start, control, end).
  static const _hyphae = [
    (Offset(15, 95), Offset(30, 65), Offset(45, 95)),
    (Offset(45, 95), Offset(35, 55), Offset(55, 35)),
    (Offset(55, 35), Offset(75, 55), Offset(65, 95)),
    (Offset(25, 75), Offset(20, 55), Offset(15, 45)),
    (Offset(65, 80), Offset(85, 65), Offset(95, 55)),
  ];
  static const _sporangia = [
    (Offset(55, 35), 9.0, Color(0xFF334155)),
    (Offset(15, 45), 6.0, Color(0xFF475569)),
    (Offset(95, 55), 7.0, Color(0xFF475569)),
  ];

  static Offset _quad(Offset a, Offset c, Offset b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);

  /// Which S2 structure is at [u] (viewBox units): bacteria are checked
  /// first because they sit on top of the mould.
  static String? hitTest2(Offset u) {
    for (final r in _rods) {
      if ((u - Offset(r.$1 + r.$3 / 2, r.$2 + r.$4 / 2)).distance < 7) {
        return 'bacteria';
      }
    }
    for (final c in _cocci) {
      if ((u - c).distance < 5) return 'bacteria';
    }
    for (final (c, r, _) in _sporangia) {
      if ((u - c).distance < r + 3) return 'mould';
    }
    for (final (a, c, b) in _hyphae) {
      for (var i = 0; i <= 20; i++) {
        if ((u - _quad(a, c, b, i / 20)).distance < 4) return 'mould';
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    if (scenario == 1) {
      _paintPond(canvas);
    } else {
      _paintSoil(canvas);
    }
    canvas.restore();
  }

  void _paintPond(Canvas canvas) {
    // Amoeba morphs over 4 s (SVG <animate values="A; B; A">).
    final t = (1 - math.cos(clock / 4 * 2 * math.pi)) / 2;
    final p = [
      for (var i = 0; i < _amoebaA.length; i++)
        Offset.lerp(_amoebaA[i], _amoebaB[i], t)!,
    ];
    final amoeba = Path()..moveTo(p[0].dx, p[0].dy);
    for (var i = 1; i < p.length; i += 2) {
      amoeba.quadraticBezierTo(p[i].dx, p[i].dy, p[i + 1].dx, p[i + 1].dy);
    }
    amoeba.close();
    canvas
      ..drawPath(amoeba, Paint()..color = const Color(0x9993C5FD))
      ..drawPath(
        amoeba,
        Paint()
          ..color = const Color(0xFF2563EB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      )
      ..drawCircle(
        Offset.lerp(const Offset(42, 52), const Offset(44, 48), t)!,
        5,
        Paint()..color = const Color(0xCC1D4ED8),
      );
    for (var i = 0; i < 7; i++) {
      final a = i * 0.9 + clock * 0.4;
      canvas.drawCircle(
        Offset(40 + 10 * math.cos(a), 52 + 8 * math.sin(a * 1.3)),
        1,
        Paint()..color = const Color(0x881E3A8A),
      );
    }
    // Paramecium glides between (60,50) and (70,60) every 3 s.
    final g = (1 - math.cos(clock / 3 * 2 * math.pi)) / 2;
    canvas
      ..save()
      ..translate(60 + 10 * g, 50 + 10 * g)
      ..rotate(math.pi / 4);
    final body = Rect.fromCenter(center: Offset.zero, width: 36, height: 16);
    canvas.drawOval(body, Paint()..color = const Color(0xCCA7F3D0));
    final cilia = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 0.5;
    for (var i = 0; i < 28; i++) {
      final a = i / 28 * 2 * math.pi;
      final wave = 0.6 * math.sin(clock * 12 + i);
      final o = Offset(18 * math.cos(a), 8 * math.sin(a));
      canvas.drawLine(o, o * (1.12 + wave * 0.03), cilia);
    }
    canvas
      ..drawOval(
        body,
        Paint()
          ..color = const Color(0xFF059669)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      )
      // Oral groove and nucleus.
      ..drawArc(
        Rect.fromCenter(center: const Offset(2, 3), width: 14, height: 8),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        Paint()
          ..color = const Color(0xFF047857)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      )
      ..drawOval(
        Rect.fromCenter(center: const Offset(-4, 0), width: 8, height: 5),
        Paint()..color = const Color(0x99047857),
      )
      ..restore();
  }

  void _paintSoil(Canvas canvas) {
    // Background debris.
    canvas
      ..drawCircle(
        const Offset(85, 85),
        8,
        Paint()
          ..color = const Color(0x4D1E293B)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )
      ..drawCircle(
        const Offset(15, 15),
        12,
        Paint()
          ..color = const Color(0x33334155)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    // Bread mould: hyphae threads (a shade darker than the source's
    // #cbd5e1 so they read on the light lens), sporangia and spores.
    final thread = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final (i, (a, c, b)) in _hyphae.indexed) {
      thread.strokeWidth = i < 3 ? 3 : 2.5;
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
        thread,
      );
    }
    for (final (c, r, color) in _sporangia) {
      canvas.drawCircle(c, r, Paint()..color = color);
    }
    for (final s in const [
      Offset(50, 20),
      Offset(60, 23),
      Offset(55, 17),
      Offset(63, 18),
    ]) {
      canvas.drawCircle(s, 1.5, Paint()..color = const Color(0xFF0F172A));
    }
    // Bacteria: bacilli (rods) and cocci.
    for (final (x, y, w, h, deg, cx, cy) in _rods) {
      canvas
        ..save()
        ..translate(cx, cy)
        ..rotate(deg * math.pi / 180)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - cx, y - cy, w, h),
            const Radius.circular(2.5),
          ),
          Paint()..color = const Color(0xFFEC4899),
        )
        ..restore();
    }
    for (final c in _cocci) {
      canvas.drawCircle(c, 3.5, Paint()..color = const Color(0xFFA855F7));
    }
    // Found structures get a teal halo.
    final halo = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    if (found.contains('mould')) {
      for (final (c, r, _) in _sporangia) {
        canvas.drawCircle(c, r + 2.5, halo);
      }
    }
    if (found.contains('bacteria')) {
      canvas
        ..drawCircle(const Offset(31, 82), 10, halo)
        ..drawCircle(const Offset(84, 34), 14, halo)
        ..drawCircle(const Offset(36, 22), 8, halo);
    }
  }

  @override
  bool shouldRepaint(covariant _MicroPainter oldDelegate) =>
      oldDelegate.clock != clock ||
      oldDelegate.scenario != scenario ||
      oldDelegate.found.length != found.length;
}

/// Riddle chip icons (the source's small SVGs).
class _RiddleIconPainter extends CustomPainter {
  const _RiddleIconPainter(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 100, size.height / 100);
    switch (id) {
      case 'yeast':
        final paint = Paint()..color = const Color(0xFFFACC15);
        canvas
          ..drawCircle(const Offset(50, 55), 30, paint)
          ..drawCircle(const Offset(72, 22), 15, paint);
      case 'rhizobium':
        canvas.drawPath(
          Path()
            ..moveTo(20, 80)
            ..quadraticBezierTo(50, 20, 80, 80)
            ..quadraticBezierTo(50, 90, 20, 80),
          Paint()..color = const Color(0xFFA3E635),
        );
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(20, 40, 60, 20),
            const Radius.circular(10),
          ),
          Paint()..color = const Color(0xFFF472B6),
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RiddleIconPainter oldDelegate) =>
      oldDelegate.id != id;
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
