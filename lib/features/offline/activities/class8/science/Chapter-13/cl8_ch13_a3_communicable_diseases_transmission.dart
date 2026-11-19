// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 13.3: Communicable Diseases and Transmission
// Converted from Cl8S-Ch13-A3-communicable-diseases-and-transmission.html
// (three.js r128 + tween.js -> mini3d).
//
// Five scenarios picked from the sidebar, each opened by a chalkboard:
// (1) Common cold - drag the virus onto the respiratory tract, pick the two
// symptoms, wash hands with the soap and switch off sharing personal
// items; (2) Malaria - the mosquito bites a person with malaria, then a
// healthy person; raise the fever above 38 °C and induce chills; put the
// net over the bed and the repellent on the person; (3) Bhadrak - pick the
// district on the map, build 5 latrines, raise toilet usage to 80% and
// watch the disease bars fall; (4) Flu at school - admin actions, a kind
// reply, then mask, sanitizer and distance; (5) Malaria trip - pack the
// suitcase and fill the logic board. Every 3D action also has a sidebar
// button (or a panel button), and each finished scenario shows its summary
// with "Next Scenario".
//
// SOURCE BUG FIXES:
// * Pending timers survived a scenario change or reset (the wash timer
//   opened the S1 toggle inside another scenario, the 3 s summary timer
//   showed the next scenario's summary) and removed tweens left S1 bubbles
//   in the scene. Every delayed step is cancelled on scenario change and
//   restart.
// * S5 could not be finished on replay (logic boxes stayed "filled"), and
//   packed items could still be dragged, so one item packed three times
//   passed. Scenarios are rebuilt cleanly; packed items lock.
// * S4: a full-screen layer swallowed every click on the 3D view, so the
//   mask could not be dragged and the wall sanitizer could not be tapped,
//   although the text asked for both. The mask can be dragged onto you,
//   tapped, or picked from the toolbox; the dispenser (moved out of the
//   locker it sat inside) or the toolbox sanitizes. The distance slider
//   stays locked until both are done instead of repeating an error toast on
//   every move; 1 m on the floor now matches the readout.
// * S3: the brick drop judged only x/y, so a plain click built two huts and
//   the back-row zones could not be reached; the bricks now slide over the
//   ground and build on the zone they are dropped on. Huts were buried
//   under the ground and leaked into other scenarios; the map coloured the
//   whole plaque instead of the Bhadrak spot, and any part of the easel
//   counted as Bhadrak. Fixed.
// * Completion could fire more than once (S1 toggle, S4 slider, S3 double
//   click); every action is latched. Final scales were undone by the
//   release tween.
// * Camera unlock stopped working after the first drag and the Pan tool did
//   nothing while locked; the camera is clamped and framed per step for
//   phones. "Induce Chills" had no visible effect (the patient now
//   shivers). The S3 slider text said 10-90% but needed 80%. The logic
//   board lit up the right box while dragging (giving the answer away) and
//   gave no feedback on a wrong drop. Labels: the toggle showed hidden
//   labels, labels stayed behind when their object moved, and the language
//   switch missed the board, the toggle text and every toast. Restart keeps
//   the language. HTML5 drag-and-drop did not work on touch screens; chips
//   can be dragged or tapped. The Hindi had English fragments ("Induce
//   Chills", "(OFF)", "(Execute)", "Logic Board", "Mosquito Repellent")
//   and two steps that did not match the English; they are rewritten.
//
// CONTENT FIXES (approved by the user):
// * S1: the virus sits in a petri dish shown through a microscope view (the
//   source used a magnifying glass, which cannot show a virus).
// * S2: the board says the parasites infect the liver and red blood cells
//   (not "skin and blood"); the mosquito picks up the parasite by biting a
//   person with malaria before it bites the healthy person (the protozoa
//   were dragged straight into it); the net and repellent prevent further
//   bites and the infection stays (the source's spray "cured" the person).
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
    'appTitle': 'Communicable Diseases and Transmission',
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
    'restartLab': 'Restart Lab', // added
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
    'lbl': {
      'resp': 'Respiratory Tract',
      // Content fix: a petri dish seen through a microscope (a hand lens
      // cannot show viruses).
      'virus': 'Virus (microscope view)',
      'dish': 'Petri Dish',
      'soap': 'Click to Wash Hands',
      'human': 'Healthy Person', // was "Human Skin"
      'infected': 'Person with Malaria', // added (content fix)
      'bitten': 'Newly Infected Person', // added
      'mosquito': 'Mosquito (Vector)',
      'net': 'Mosquito Net',
      'spray': 'Mosquito Repellent',
      'bed': 'Bed', // added
      'map': 'Click Bhadrak District',
      'bricks': 'Toilet Bricks',
      'mask': 'Mask',
      'sanitizer': 'Sanitizer',
      'sick': 'Sick Classmate', // added
      'you': 'You', // added
      'case': 'Suitcase',
      'shirt': 'Full-sleeved Shirt',
      'sleeveless': 'Sleeveless Shirt',
      'perfume': 'Perfume',
      'packNet': 'Mosquito Net',
      'repellent': 'Mosquito Repellent',
    },
    // Lab-control twins (added).
    'twVirus': 'Virus onto the respiratory tract',
    'twSoap': 'Wash hands with soap',
    'twBiteInfected': 'Mosquito bites the person with malaria',
    'twBiteHuman': 'Mosquito bites the healthy person',
    'twNet': 'Net over the bed',
    'twSpray': 'Repellent on the person',
    'twBhadrak': 'Select Bhadrak district',
    'twBuild': 'Build the next toilet',
    'twPack': 'Pack: {item}',
    // Scenario 1.
    'symTitle': 'Symptoms',
    'symDesc': 'Select the symptoms associated with the common cold.',
    'sym': {
      'fracture': 'Fracture',
      'nasal': 'Nasal Congestion',
      'bp': 'High Blood Pressure',
      'fever': 'Fever',
    },
    'diagnose': 'Diagnose',
    'shareItems': 'Share Personal Items',
    'on': 'ON', // added (was hard-coded)
    'off': 'OFF', // added
    'fbLungsMiss':
        'Incorrect. The common cold is a viral infection of the respiratory tract.',
    'fbVirusIn':
        'The virus invades the cells of the respiratory tract.', // added
    'fbWashSoap': 'Now, click the Soap to wash hands.',
    'fbSymWrong': 'Incorrect. Select exactly the 2 main symptoms of a cold.',
    'fbWashing': 'Washing hands (20s simulation)...',
    'fbWashed': 'Hands Washed! Now, turn off sharing personal items.',
    // Scenario 2.
    'fbPickedUp':
        'The mosquito picked up the malaria parasite from the infected person.', // content fix
    'fbNotCarrier':
        'This mosquito carries no parasite yet - it must first bite a person with malaria.', // added
    'fbBitten': 'The person has been bitten and infected!',
    'fbBiteMiss': 'Drag the mosquito onto a person.',
    'fbNowHealthy':
        'The mosquito already carries the parasite. Now drag it to the healthy person.', // added
    'temperature': 'Temperature',
    'chills': 'Induce Chills',
    'fbChills': 'Shivering chills: the fever spikes again and again.', // added
    'fbFeverLow': 'Temperature must be higher than 38°C to induce chills.',
    'fbProtect': 'Now, protect against more bites with the net and repellent.',
    'fbNetMiss': 'Drag the net over the bed.',
    'fbSprayMiss': "Apply the spray onto the person's skin.",
    'fbNetOn': 'The net blocks mosquitoes at night.', // added
    'fbSprayOn': 'The repellent keeps mosquitoes away.', // added
    // Scenario 3.
    'fbBhadrak': 'Bhadrak Selected! Now build toilets in the village.',
    'fbBuilt':
        'Latrine Built! ({n}/5). Drag the bricks again to the next zone.',
    'fbZoneMiss': 'Drop the bricks on an empty construction zone.', // added
    'fbMapMiss': 'Find Bhadrak: the red spot on the coast of Odisha.', // added
    'graphTitle': 'Correlating Data',
    'graphOd': 'Open Defecation Rate',
    'graphDiar': 'Diarrhoea Cases',
    'graphSlider': 'Toilet Usage Level',
    'graphBtn': 'Infection Rate Reduced',
    // Scenario 4.
    'adminTitle': 'Admin Control Panel',
    'adminDesc': 'Select the 2 correct proactive administrative actions:',
    'admin': [
      'Close Windows',
      'Sanitize Surfaces',
      'Ignore Symptoms',
      'Send Sick Students Home',
    ],
    'execute': 'Execute',
    'fbIgnore': 'Error: Ignoring symptoms accelerates outbreaks.',
    'fbAdminWrong': 'Select the correct proactive administrative actions.',
    'dialTitle': 'Your sick classmate is coughing. What do you say?', // added
    'dial': [
      '"I hope you feel better soon. I will help you catch up on notes when you recover."',
      '"Stay away from me! I don\'t want to get sick."',
      '"It\'s just a cold, stop coughing so loudly."',
    ],
    'fbDialWrong': 'Choose a response that demonstrates empathy and support.',
    'fbDialRight':
        'Kind and supportive. Now protect yourself: mask, sanitizer, distance.', // added
    'toolbox': 'Toolbox',
    'maskBtn': 'Mask',
    'sanitizeBtn': 'Sanitize',
    'distance': 'Distance',
    'fbMaskOn': 'Mask applied.',
    'fbMaskMiss': 'Drag the mask onto your face.', // added
    'fbMaskFirst': 'Please put on the mask before sanitizing hands.',
    'fbSanitized': 'Hands sanitized.',
    'fbOrder': 'Follow the steps: Mask, then Sanitize, then Distance.',
    'fbDistance': 'Distance Maintained!',
    // Scenario 5.
    'fbReject': "System reject: '{name}' is irrelevant or high risk.",
    'fbPacked': 'Packed: {name}', // added
    'fbCaseMiss': 'Drop it into the suitcase.', // added
    'logicTitle': 'Logic Board',
    'logic': {
      'carries': 'Mosquito carries Protozoa',
      'blocks': 'Net blocks Mosquito',
      'noBite': 'No Bite = No Malaria',
      'food': 'Eat healthy food',
    },
    'logicIntro':
        'Explain to your sibling why the net matters: place one idea in each box.', // added
    'zone': {
      'A': 'Pathogen carrier',
      'B': 'Barrier method',
      'C': 'Outcome',
    }, // added (from the step text)
    'fbLogicWrong': 'That idea belongs in a different box.', // added
    'fbFood':
        'Healthy food is good, but it does not stop mosquito bites.', // added
    'fbSibling': "Sibling says: 'Okay, I will use it!'",
    'scenarios': [
      {
        'title': 'Scenario 1: Common Cold and Influenza',
        'objective':
            'Understanding the pathogen, affected area, and prevention of the common cold.',
        'board':
            'Common cold and influenza are communicable diseases caused by a Virus. They primarily affect the respiratory tract. Symptoms include nasal congestion and fever.',
        'boardBtn': 'Setup Activity',
        'hud': [
          'Step 1: Read the objective.',
          "Step 2: Drag the 'Virus' pathogen to the correct affected area on the human body.",
          'Step 3: Identify the symptoms of the common cold.',
          'Step 4: Practice prevention by washing hands and not sharing items.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': 'Review the mission on the chalkboard.',
            'observation':
                'The common cold is a viral infection primarily affecting the respiratory tract.',
          },
          {
            'concept': 'Pathogen Identification',
            'action':
                "Drag the 'Virus' from the petri dish (seen under the microscope) and drop it onto the 'Respiratory Tract' (lungs area) of the human model.",
            'observation':
                'Viruses invade the cells of the respiratory tract to multiply.',
          },
          {
            'concept': 'Symptom Recognition',
            'action':
                "Select 'Nasal Congestion' and 'Fever' from the checklist.",
            'observation':
                'These are primary symptoms as the body fights off the viral infection.',
          },
          {
            'concept': 'Prevention Protocols',
            'action':
                "Click the Soap to simulate hand washing, and toggle 'Share Personal Items' to OFF.",
            'observation':
                'Hand hygiene and not sharing items stop the transmission of the virus.',
          },
        ],
        'summaryTitle': 'Prevention Protocol Active!',
        'summary':
            'You identified the **Virus** as the pathogen for the common cold, its target area, symptoms, and key preventative measures.',
      },
      {
        'title': 'Scenario 2: Malaria',
        'objective':
            'Identifying the cause, vector, and prevention methods for Malaria.',
        // Content fix: Plasmodium infects the liver and red blood cells.
        'board':
            'Malaria is caused by Protozoa (Plasmodium). The parasites infect the liver and the red blood cells. It is spread by insects called vectors (specifically mosquitoes). Prevention involves nets and repellents.',
        'boardBtn': 'Setup Activity',
        'hud': [
          'Step 1: Read the objective.',
          'Step 2: Drag the Mosquito to the person with malaria, then to the healthy person.',
          'Step 3: Adjust the thermometer to indicate high fever (>38°C) and induce chills.',
          'Step 4: Prevent more bites: set up the net over the bed and apply repellent.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': 'Review the chalkboard.',
            'observation':
                'Malaria is protozoan, transmitted via a vector (mosquito).',
          },
          {
            'concept': 'The Transmission Cycle',
            // Content fix: the mosquito picks the parasite up by biting an
            // infected person (the protozoa were dragged straight into it).
            'action':
                'Drag the Mosquito to the person with malaria so it picks up the parasite. Then drag it to the healthy person.',
            'observation':
                'The mosquito acts as a vector, carrying the pathogen to a new host without getting sick itself.',
          },
          {
            'concept': 'Symptom Analysis',
            'action':
                "Drag the thermometer slider up to > 38°C (High Fever) and click 'Induce Chills'.",
            'observation':
                'Malaria presents with characteristic high fevers and severe chills.',
          },
          {
            'concept': 'Deploying Countermeasures',
            'action':
                "Drag the 'Mosquito Net' to the bed, and 'Repellent Spray' to the person.",
            // Content fix: they prevent further bites; they do not cure.
            'observation':
                'Physical barriers and repellents prevent further bites, breaking the transmission cycle. They do not cure malaria - the sick person still needs a doctor.',
          },
        ],
        'summaryTitle': 'Vector Blocked!',
        'summary':
            'You successfully modeled the transmission cycle of **Malaria via a vector** and applied correct preventative measures.',
      },
      {
        'title': 'Scenario 3: Odisha Community-led Sanitation Campaign',
        'objective':
            'Analyzing the Bhadrak district case study regarding toilets and disease reduction.',
        'board':
            'In Bhadrak district, Odisha, a campaign increased toilet usage. This reduced open defecation and led to fewer cases of diarrhoea and infections.',
        'boardBtn': 'Setup Activity',
        'hud': [
          'Step 1: Read the objective.',
          'Step 2: Click on Bhadrak District on the map. Then drag Bricks to build 5 toilets in the village.',
          'Step 3: Use the slider to increase Toilet Usage and observe the effect on disease rates.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': 'Review the case study.',
            'observation':
                'Sanitation infrastructure directly impacts community health.',
          },
          {
            'concept': 'Geographic & Infrastructure Setup',
            'action':
                "Click 'Bhadrak' on the map. Drag 'Toilet Bricks' from the pile to the 5 designated construction zones.",
            'observation':
                'Building facilities is the first step to eliminating open defecation.',
          },
          {
            'concept': 'Correlating Data',
            'action':
                "Drag the 'Toilet Usage' slider up to at least 80%. Observe the graphs, then confirm.",
            'observation':
                'As toilet usage increases, open defecation decreases, resulting in a dramatic drop in diarrhoea cases.',
          },
        ],
        'summaryTitle': 'Public Health Win!',
        'summary':
            'You demonstrated how improving **sanitation infrastructure** directly reduces the spread of communicable diseases like diarrhoea.',
      },
      {
        'title': 'Scenario 4: Flu Outbreak in School',
        'objective':
            'Managing a flu outbreak scenario involving school policy, empathy, and self-protection.',
        'board':
            'Challenge: There is a flu outbreak in your school. Determine immediate actions, empathetic response, and self-protection.',
        'boardBtn': 'Setup Activity',
        'hud': [
          'Step 1: Read the challenge.',
          'Step 2: Select correct actions in the Admin Panel.',
          'Step 3: Choose an empathetic response to a sick classmate.',
          'Step 4: Put on the Mask, then use the Hand Sanitizer, then slide the distance above 1 meter.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': 'Review the challenge.',
            'observation':
                'Managing an outbreak requires administrative action, personal protection, and social empathy.',
          },
          {
            'concept': 'Immediate School Actions (i)',
            'action':
                "In the Admin Panel, select 'Sanitize Surfaces' and 'Send Sick Students Home'. Click Execute.",
            'observation':
                'These actions remove pathogens from the environment and isolate infected individuals.',
          },
          {
            'concept': 'Empathetic Response (ii)',
            'action': 'Select the supportive dialogue option.',
            'observation':
                'It is important to support peers without stigmatizing them while they are ill.',
          },
          {
            'concept': 'Self-Protection (iii)',
            'action':
                'Put on the Mask (tap it or drag it onto yourself), tap the wall Sanitizer, and slide the distance above 1 meter.',
            'observation':
                'PPE (masks), hygiene, and social distancing protect the individual from airborne droplets.',
          },
        ],
        'summaryTitle': 'Outbreak Contained!',
        'summary':
            'You handled the school outbreak by combining **policy, empathy, and personal protective measures**.',
      },
      {
        'title': 'Scenario 5: Family Travel to Malaria Zone',
        'objective':
            'Planning precautions for a trip to a malaria-prevalent city and educating a sibling.',
        'board':
            'Challenge: Family travel to a city with high Malaria prevalence. Plan precautions and explain the importance of nets to a sibling.',
        'boardBtn': 'Setup Activity',
        'hud': [
          'Step 1: Read the challenge.',
          'Step 2: Pack the correct protective items in the suitcase.',
          "Step 3: Complete the logic board to explain the 'why' to your sibling.",
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': 'Review the challenge.',
            'observation':
                'Traveling to endemic areas requires specific proactive preparations.',
          },
          {
            'concept': 'Packing Precautions (i)',
            'action':
                "Drag 'Full-sleeved Shirt', 'Mosquito Net', and 'Mosquito Repellent' into the suitcase.",
            'observation':
                'These items minimize exposed skin and actively deter vectors.',
          },
          {
            'concept': 'Educating the Sibling (ii)',
            'action':
                'Fill the logic board: pathogen carrier (A), barrier method (B), outcome (C).',
            'observation':
                'Understanding the logic (Mosquito carries Protozoa, Net blocks Mosquito, No Bite = No Malaria) ensures compliance.',
          },
        ],
        'summaryTitle': 'Ready for Travel!',
        'summary':
            'You packed the correct protective gear and logically explained how **breaking the vector chain** prevents Malaria.',
      },
    ],
  },
  'hi': {
    'appTitle': 'संक्रामक रोग और संचरण',
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
    'restartLab': 'प्रयोगशाला फिर से शुरू करें',
    'scComplete': 'परिदृश्य {n} पूर्ण!',
    'labComplete': 'सभी परिदृश्य पूर्ण!',
    'scenarioDoneHud': 'परिदृश्य {n} पूर्ण! अगले परिदृश्य पर जाएँ।',
    'labDoneHud': 'सभी परिदृश्य पूरे हुए! प्रयोगशाला कभी भी पुनः आरंभ करें।',
    'labControls': 'प्रयोगशाला नियंत्रण',
    'controlsHint':
        '3D दृश्य में वस्तुओं को खींचें या टैप करें, या इन बटनों का उपयोग करें।',
    'ttLabels': 'लेबल दिखाएँ/छिपाएँ',
    'ttLock': 'कैमरा लॉक / अनलॉक',
    'lbl': {
      'resp': 'श्वसन पथ',
      'virus': 'वायरस (सूक्ष्मदर्शी दृश्य)',
      'dish': 'पेट्री डिश',
      'soap': 'हाथ धोने के लिए क्लिक करें',
      'human': 'स्वस्थ व्यक्ति',
      'infected': 'मलेरिया से पीड़ित व्यक्ति',
      'bitten': 'नया संक्रमित व्यक्ति',
      'mosquito': 'मच्छर (वेक्टर)',
      'net': 'मच्छरदानी',
      'spray': 'मच्छर विकर्षक',
      'bed': 'बिस्तर',
      'map': 'भद्रक जिले पर क्लिक करें',
      'bricks': 'शौचालय की ईंटें',
      'mask': 'मास्क',
      'sanitizer': 'सैनिटाइज़र',
      'sick': 'बीमार सहपाठी',
      'you': 'आप',
      'case': 'सूटकेस',
      'shirt': 'पूरी बाजू की शर्ट',
      'sleeveless': 'बिना बाजू की शर्ट',
      'perfume': 'इत्र',
      'packNet': 'मच्छरदानी',
      'repellent': 'मच्छर विकर्षक',
    },
    'twVirus': 'वायरस को श्वसन पथ पर रखें',
    'twSoap': 'साबुन से हाथ धोएँ',
    'twBiteInfected': 'मच्छर मलेरिया पीड़ित को काटे',
    'twBiteHuman': 'मच्छर स्वस्थ व्यक्ति को काटे',
    'twNet': 'बिस्तर पर मच्छरदानी लगाएँ',
    'twSpray': 'व्यक्ति पर विकर्षक लगाएँ',
    'twBhadrak': 'भद्रक जिला चुनें',
    'twBuild': 'अगला शौचालय बनाएँ',
    'twPack': 'पैक करें: {item}',
    'symTitle': 'लक्षण',
    'symDesc': 'सामान्य सर्दी से जुड़े लक्षणों का चयन करें।',
    'sym': {
      'fracture': 'फ्रैक्चर',
      'nasal': 'नाक बंद होना',
      'bp': 'उच्च रक्तचाप',
      'fever': 'बुखार',
    },
    'diagnose': 'निदान करें',
    'shareItems': 'व्यक्तिगत वस्तुएँ साझा करें',
    'on': 'चालू',
    'off': 'बंद',
    'fbLungsMiss': 'गलत। सामान्य सर्दी श्वसन पथ का वायरल संक्रमण है।',
    'fbVirusIn': 'वायरस श्वसन पथ की कोशिकाओं पर आक्रमण करता है।',
    'fbWashSoap': 'अब, हाथ धोने के लिए साबुन पर क्लिक करें।',
    'fbSymWrong': 'गलत। सर्दी के ठीक 2 मुख्य लक्षण चुनें।',
    'fbWashing': 'हाथ धो रहे हैं (20 सेकंड का अभ्यास)...',
    'fbWashed': 'हाथ धुल गए! अब व्यक्तिगत वस्तुएँ साझा करना बंद करें।',
    'fbPickedUp': 'मच्छर ने संक्रमित व्यक्ति से मलेरिया परजीवी ले लिया।',
    'fbNotCarrier':
        'इस मच्छर में अभी कोई परजीवी नहीं है - पहले इसे मलेरिया पीड़ित व्यक्ति को काटना होगा।',
    'fbBitten': 'व्यक्ति को काट लिया गया और वह संक्रमित हो गया!',
    'fbBiteMiss': 'मच्छर को किसी व्यक्ति पर खींचें।',
    'fbNowHealthy':
        'मच्छर में पहले से परजीवी है। अब इसे स्वस्थ व्यक्ति पर खींचें।',
    'temperature': 'तापमान',
    'chills': 'कंपकंपी लाएँ', // was "ठंड लगना (Induce Chills)"
    'fbChills': 'कंपकंपी वाली ठंड: बुखार बार-बार तेज़ होता है।',
    'fbFeverLow': 'कंपकंपी लाने के लिए तापमान 38°C से अधिक होना चाहिए।',
    'fbProtect': 'अब मच्छरदानी और विकर्षक से और काटने से बचाएँ।',
    'fbNetMiss': 'मच्छरदानी को बिस्तर के ऊपर खींचें।',
    'fbSprayMiss': 'स्प्रे को व्यक्ति की त्वचा पर लगाएँ।',
    'fbNetOn': 'मच्छरदानी रात में मच्छरों को रोकती है।',
    'fbSprayOn': 'विकर्षक मच्छरों को दूर रखता है।',
    'fbBhadrak': 'भद्रक चुना गया! अब गाँव में शौचालय बनाएँ।',
    'fbBuilt':
        'शौचालय बन गया! ({n}/5)। ईंटों को फिर से अगले क्षेत्र में खींचें।',
    'fbZoneMiss': 'ईंटों को किसी खाली निर्माण क्षेत्र पर छोड़ें।',
    'fbMapMiss': 'भद्रक खोजें: ओडिशा के तट पर लाल बिंदु।',
    'graphTitle': 'डेटा सहसंबंध',
    'graphOd': 'खुले में शौच दर',
    'graphDiar': 'दस्त के मामले',
    'graphSlider': 'शौचालय उपयोग स्तर',
    'graphBtn': 'संक्रमण दर कम हुई',
    'adminTitle': 'व्यवस्थापक नियंत्रण पैनल',
    'adminDesc': '2 सही सक्रिय प्रशासनिक कार्य चुनें:',
    'admin': [
      'खिड़कियाँ बंद करें',
      'सतहों को सैनिटाइज़ करें',
      'लक्षणों को अनदेखा करें',
      'बीमार छात्रों को घर भेजें',
    ],
    'execute': 'लागू करें',
    'fbIgnore': 'त्रुटि: लक्षणों को अनदेखा करने से प्रकोप तेज़ी से फैलता है।',
    'fbAdminWrong': 'सही सक्रिय प्रशासनिक कार्य चुनें।',
    'dialTitle': 'आपका बीमार सहपाठी खाँस रहा है। आप क्या कहेंगे?',
    'dial': [
      '"मुझे उम्मीद है कि तुम जल्दी ठीक हो जाओगे। ठीक होने पर मैं नोट्स पूरे करने में तुम्हारी मदद करूँगा।"',
      '"मुझसे दूर रहो! मैं बीमार नहीं पड़ना चाहता।"',
      '"यह सिर्फ सर्दी है, इतनी ज़ोर से खाँसना बंद करो।"',
    ],
    'fbDialWrong': 'ऐसा उत्तर चुनें जिसमें सहानुभूति और सहयोग दिखे।',
    'fbDialRight':
        'दयालु और सहयोगी उत्तर। अब अपनी सुरक्षा करें: मास्क, सैनिटाइज़र, दूरी।',
    'toolbox': 'टूलबॉक्स',
    'maskBtn': 'मास्क',
    'sanitizeBtn': 'सैनिटाइज़ करें',
    'distance': 'दूरी',
    'fbMaskOn': 'मास्क लगा लिया।',
    'fbMaskMiss': 'मास्क को अपने चेहरे पर खींचें।',
    'fbMaskFirst': 'हाथ सैनिटाइज़ करने से पहले मास्क लगाएँ।',
    'fbSanitized': 'हाथ सैनिटाइज़ हो गए।',
    'fbOrder': 'क्रम अपनाएँ: मास्क, फिर सैनिटाइज़, फिर दूरी।',
    'fbDistance': 'दूरी बनी रही!',
    'fbReject': "सिस्टम अस्वीकार: '{name}' अनावश्यक है या खतरा बढ़ाता है।",
    'fbPacked': 'पैक किया: {name}',
    'fbCaseMiss': 'इसे सूटकेस में छोड़ें।',
    'logicTitle': 'तर्क बोर्ड', // was "तर्क बोर्ड (Logic Board)"
    'logic': {
      'carries': 'मच्छर प्रोटोजोआ ले जाता है',
      'blocks': 'मच्छरदानी मच्छर को रोकती है',
      'noBite': 'काटना नहीं = मलेरिया नहीं',
      'food': 'पौष्टिक भोजन खाएँ',
    },
    'logicIntro':
        'भाई-बहन को समझाएँ कि मच्छरदानी क्यों ज़रूरी है: हर खाने में एक विचार रखें।',
    'zone': {'A': 'रोगज़नक़ वाहक', 'B': 'अवरोध का तरीका', 'C': 'परिणाम'},
    'fbLogicWrong': 'यह विचार किसी दूसरे खाने का है।',
    'fbFood': 'पौष्टिक भोजन अच्छा है, पर यह मच्छर के काटने को नहीं रोकता।',
    'fbSibling': "भाई-बहन कहता है: 'ठीक है, मैं इसका उपयोग करूँगा!'",
    'scenarios': [
      {
        'title': 'परिदृश्य 1: सामान्य सर्दी और इन्फ्लुएंजा',
        'objective':
            'रोगज़नक़, प्रभावित क्षेत्र और सामान्य सर्दी की रोकथाम को समझें।',
        'board':
            'सामान्य सर्दी और इन्फ्लुएंजा संक्रामक रोग हैं जो वायरस के कारण होते हैं। वे मुख्य रूप से श्वसन पथ को प्रभावित करते हैं। लक्षणों में नाक बंद होना और बुखार शामिल हैं।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          'चरण 1: उद्देश्य पढ़ें।',
          "चरण 2: 'वायरस' को मानव शरीर के सही प्रभावित क्षेत्र पर खींचें।",
          'चरण 3: सामान्य सर्दी के लक्षणों को पहचानें।',
          'चरण 4: हाथ धोकर और वस्तुएँ साझा न करके रोकथाम का अभ्यास करें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': 'चॉकबोर्ड पर मिशन की समीक्षा करें।',
            'observation':
                'सामान्य सर्दी एक वायरल संक्रमण है जो मुख्य रूप से श्वसन पथ को प्रभावित करता है।',
          },
          {
            'concept': 'रोगज़नक़ की पहचान',
            'action':
                "पेट्री डिश (सूक्ष्मदर्शी से दिखाई गई) से 'वायरस' को खींचकर मानव मॉडल के 'श्वसन पथ' (फेफड़ों) पर छोड़ें।",
            'observation':
                'वायरस गुणा करने के लिए श्वसन पथ की कोशिकाओं पर आक्रमण करते हैं।',
          },
          {
            'concept': 'लक्षणों की पहचान',
            'action': "चेकलिस्ट से 'नाक बंद होना' और 'बुखार' चुनें।",
            'observation':
                'ये प्रमुख लक्षण हैं क्योंकि शरीर वायरल संक्रमण से लड़ता है।',
          },
          {
            'concept': 'रोकथाम के उपाय',
            'action':
                "हाथ धोने के लिए साबुन पर क्लिक करें, और 'व्यक्तिगत वस्तुएँ साझा करें' को बंद करें।", // changed
            'observation':
                'हाथों की स्वच्छता और वस्तुएँ साझा न करना वायरस के संचरण को रोकता है।',
          },
        ],
        'summaryTitle': 'रोकथाम प्रोटोकॉल सक्रिय!',
        'summary':
            'आपने सामान्य सर्दी के रोगज़नक़ (**वायरस**), उसके लक्ष्य क्षेत्र, लक्षणों और मुख्य बचाव उपायों की पहचान की।',
      },
      {
        'title': 'परिदृश्य 2: मलेरिया',
        'objective': 'मलेरिया के कारण, वेक्टर और रोकथाम के तरीकों को पहचानें।',
        'board':
            'मलेरिया प्रोटोजोआ (प्लाज़्मोडियम) के कारण होता है। ये परजीवी यकृत (लिवर) और लाल रक्त कोशिकाओं को संक्रमित करते हैं। यह वेक्टर (मच्छर) नामक कीटों द्वारा फैलता है। रोकथाम में मच्छरदानी और विकर्षक शामिल हैं।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          'चरण 1: उद्देश्य पढ़ें।',
          'चरण 2: मच्छर को मलेरिया पीड़ित व्यक्ति पर, फिर स्वस्थ व्यक्ति पर खींचें।',
          'चरण 3: तेज़ बुखार (>38°C) दिखाने के लिए थर्मामीटर समायोजित करें और कंपकंपी लाएँ।',
          'चरण 4: और काटने से बचाएँ: बिस्तर पर मच्छरदानी लगाएँ और विकर्षक लगाएँ।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': 'चॉकबोर्ड की समीक्षा करें।',
            'observation':
                'मलेरिया प्रोटोजोआ से होता है, जो एक वेक्टर (मच्छर) के माध्यम से फैलता है।',
          },
          {
            'concept': 'संचरण चक्र',
            'action':
                'मच्छर को मलेरिया पीड़ित व्यक्ति पर खींचें ताकि वह परजीवी ले ले। फिर उसे स्वस्थ व्यक्ति पर खींचें।',
            'observation':
                'मच्छर एक वेक्टर की तरह काम करता है, जो खुद बीमार हुए बिना रोगज़नक़ को नए मेज़बान तक ले जाता है।',
          },
          {
            'concept': 'लक्षणों का विश्लेषण',
            'action':
                "थर्मामीटर स्लाइडर को > 38°C (तेज़ बुखार) तक खींचें और 'कंपकंपी लाएँ' पर क्लिक करें।",
            'observation': 'मलेरिया में तेज़ बुखार और तीव्र कंपकंपी होती है।',
          },
          {
            'concept': 'बचाव के उपाय',
            'action':
                "'मच्छरदानी' को बिस्तर पर और 'विकर्षक स्प्रे' को व्यक्ति पर खींचें।",
            'observation':
                'भौतिक अवरोध और विकर्षक आगे के काटने को रोकते हैं और संचरण चक्र तोड़ते हैं। ये मलेरिया को ठीक नहीं करते - बीमार व्यक्ति को डॉक्टर की ज़रूरत है।',
          },
        ],
        'summaryTitle': 'वेक्टर अवरुद्ध!',
        'summary':
            'आपने **वेक्टर (मच्छर) के माध्यम से मलेरिया** के संचरण चक्र का मॉडल बनाया और सही बचाव उपाय लागू किए।',
      },
      {
        'title': 'परिदृश्य 3: ओडिशा का समुदाय-आधारित स्वच्छता अभियान',
        'objective':
            'शौचालयों और रोगों में कमी के संबंध में भद्रक जिले के केस अध्ययन का विश्लेषण करें।',
        'board':
            'ओडिशा के भद्रक जिले में एक अभियान ने शौचालयों का उपयोग बढ़ाया। इससे खुले में शौच कम हुआ और दस्त तथा संक्रमण के मामले घटे।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          'चरण 1: उद्देश्य पढ़ें।',
          'चरण 2: नक्शे पर भद्रक जिले पर क्लिक करें। फिर 5 शौचालय बनाने के लिए ईंटें खींचें।',
          'चरण 3: शौचालय उपयोग बढ़ाने के लिए स्लाइडर का उपयोग करें और रोग दर पर प्रभाव देखें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': 'केस अध्ययन की समीक्षा करें।',
            'observation':
                'स्वच्छता अवसंरचना सीधे सामुदायिक स्वास्थ्य को प्रभावित करती है।',
          },
          {
            'concept': 'भौगोलिक और अवसंरचना तैयारी',
            'action':
                "नक्शे पर 'भद्रक' पर क्लिक करें। ढेर से 'शौचालय की ईंटें' 5 निर्माण क्षेत्रों तक खींचें।",
            'observation':
                'सुविधाओं का निर्माण खुले में शौच को खत्म करने का पहला कदम है।',
          },
          {
            'concept': 'डेटा सहसंबंध',
            'action':
                "'शौचालय उपयोग' स्लाइडर को कम से कम 80% तक खींचें। ग्राफ़ देखें, फिर पुष्टि करें।",
            'observation':
                'शौचालय का उपयोग बढ़ने से खुले में शौच घटता है, और दस्त के मामलों में भारी गिरावट आती है।',
          },
        ],
        'summaryTitle': 'सार्वजनिक स्वास्थ्य की जीत!',
        'summary':
            'आपने दिखाया कि **स्वच्छता अवसंरचना** में सुधार से दस्त जैसे संक्रामक रोगों का प्रसार सीधे कम होता है।',
      },
      {
        'title': 'परिदृश्य 4: स्कूल में फ्लू का प्रकोप',
        'objective':
            'स्कूल नीति, सहानुभूति और आत्म-सुरक्षा से जुड़े फ्लू प्रकोप की स्थिति संभालें।',
        'board':
            'चुनौती: आपके स्कूल में फ्लू का प्रकोप है। तत्काल कार्य, सहानुभूतिपूर्ण प्रतिक्रिया और आत्म-सुरक्षा तय करें।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          'चरण 1: चुनौती पढ़ें।',
          'चरण 2: व्यवस्थापक पैनल में सही कार्य चुनें।',
          'चरण 3: बीमार सहपाठी के लिए सहानुभूतिपूर्ण उत्तर चुनें।',
          'चरण 4: मास्क लगाएँ, फिर हैंड सैनिटाइज़र का उपयोग करें, फिर दूरी 1 मीटर से अधिक करें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': 'चुनौती की समीक्षा करें।',
            'observation':
                'प्रकोप संभालने के लिए प्रशासनिक कार्रवाई, व्यक्तिगत सुरक्षा और सामाजिक सहानुभूति ज़रूरी है।',
          },
          {
            'concept': 'स्कूल के तत्काल कार्य (i)',
            'action':
                "व्यवस्थापक पैनल में 'सतहों को सैनिटाइज़ करें' और 'बीमार छात्रों को घर भेजें' चुनें। 'लागू करें' पर क्लिक करें।", // changed
            'observation':
                'ये कार्य वातावरण से रोगजनकों को हटाते हैं और संक्रमित व्यक्तियों को अलग करते हैं।',
          },
          {
            'concept': 'सहानुभूतिपूर्ण प्रतिक्रिया (ii)',
            'action': 'सहयोगी संवाद विकल्प चुनें।',
            'observation':
                'बीमार साथियों को कलंकित किए बिना उनका साथ देना महत्वपूर्ण है।',
          },
          {
            'concept': 'आत्म-सुरक्षा (iii)',
            // Was "drag the mask to the avatar / click the wall sanitizer",
            // which did not match the English.
            'action':
                'मास्क लगाएँ (उस पर टैप करें या उसे खुद पर खींचें), दीवार के सैनिटाइज़र पर टैप करें, और दूरी 1 मीटर से अधिक करें।',
            'observation':
                'पीपीई (मास्क), स्वच्छता और सामाजिक दूरी व्यक्ति को हवा में मौजूद बूंदों से बचाते हैं।',
          },
        ],
        'summaryTitle': 'प्रकोप नियंत्रित!',
        'summary':
            'आपने **नीति, सहानुभूति और व्यक्तिगत सुरक्षा उपायों** को मिलाकर स्कूल का प्रकोप संभाला।',
      },
      {
        'title': 'परिदृश्य 5: मलेरिया क्षेत्र की पारिवारिक यात्रा',
        'objective':
            'मलेरिया-प्रभावित शहर की यात्रा के लिए सावधानियाँ तय करें और भाई-बहन को समझाएँ।',
        'board':
            'चुनौती: अधिक मलेरिया वाले शहर की पारिवारिक यात्रा। सावधानियों की योजना बनाएँ और भाई-बहन को मच्छरदानी का महत्व समझाएँ।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          'चरण 1: चुनौती पढ़ें।',
          'चरण 2: सूटकेस में सही सुरक्षात्मक वस्तुएँ पैक करें।',
          "चरण 3: भाई-बहन को 'क्यों' समझाने के लिए तर्क बोर्ड पूरा करें।",
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': 'चुनौती की समीक्षा करें।',
            'observation':
                'प्रभावित क्षेत्रों की यात्रा के लिए खास तैयारियाँ ज़रूरी हैं।',
          },
          {
            'concept': 'पैकिंग की सावधानियाँ (i)',
            'action':
                "'पूरी बाजू की शर्ट', 'मच्छरदानी' और 'मच्छर विकर्षक' को सूटकेस में खींचें।",
            'observation':
                'ये वस्तुएँ खुली त्वचा कम करती हैं और मच्छरों को दूर रखती हैं।',
          },
          {
            'concept': 'भाई-बहन को समझाना (ii)',
            'action':
                'तर्क बोर्ड भरें: रोगज़नक़ वाहक (A), अवरोध का तरीका (B), परिणाम (C)।',
            'observation':
                'तर्क समझना (मच्छर प्रोटोजोआ ले जाता है, मच्छरदानी मच्छर को रोकती है, काटना नहीं = मलेरिया नहीं) पालन सुनिश्चित करता है।',
          },
        ],
        'summaryTitle': 'यात्रा के लिए तैयार!',
        'summary':
            'आपने सही सुरक्षा सामान पैक किया और तर्क से समझाया कि **वेक्टर श्रृंखला तोड़ने** से मलेरिया कैसे रुकता है।',
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.indigo500;
const Color _accentSoft = Color(0xFFA5B4FC); // indigo-300

/// Steps per scenario (step 1 is always the chalkboard).
const List<int> _stepCounts = [4, 4, 3, 4, 3];

/// S1 symptom ids; the cold's two are nasal congestion and fever.
const List<String> _symptomIds = ['fracture', 'nasal', 'bp', 'fever'];
const Set<String> _coldSymptoms = {'nasal', 'fever'};

/// S3 construction zones (x, z) on the village ground.
const List<(double, double)> _zones = [
  (0, -3.2),
  (4, -3.2),
  (8, -3.2),
  (2, 1.4),
  (6, 1.4),
];

/// Height of the S3 drag plane (the bricks slide over the ground).
const double _groundDragY = -3.0;

/// S4: you stand here; 1 m on the floor is [_metre] scene units.
const double _youX = -4.6, _metre = 3.4;

/// S4 admin options (index into `admin`) that are correct.
const Set<int> _adminRight = {1, 3};

/// S5 items: id -> packs (a protective item).
const Map<String, bool> _items = {
  'shirt': true,
  'sleeveless': false,
  'packNet': true,
  'repellent': true,
  'perfume': false,
};

/// S5 logic board: box -> the idea it takes; chips in a fixed mixed order.
const Map<String, String> _logicZones = {
  'A': 'carries',
  'B': 'blocks',
  'C': 'noBite',
};
const List<String> _logicChips = ['noBite', 'food', 'carries', 'blocks'];

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

/// A standing person (feet at the node origin, about 7 units tall before
/// scaling); the skin material is shared so it can be re-tinted.
class _Person {
  _Person(this.node, this.skin, this.leftArm, this.rightArm, this.head);

  final _rt_Node3D node;
  final _rt_Material3D skin;
  final _rt_Node3D leftArm;
  final _rt_Node3D rightArm;
  final _rt_Node3D head;
}

class _ConfettiPiece {
  _ConfettiPiece(math.Random r)
    : angle = (-90 + (r.nextDouble() - 0.5) * 140) * math.pi / 180,
      speed = 420 + r.nextDouble() * 480,
      color = const [
        Color(0xFF6366F1),
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

class Cl8Ch13A3CommunicableDiseasesTransmissionPage extends StatefulWidget {
  const Cl8Ch13A3CommunicableDiseasesTransmissionPage({super.key});

  @override
  State<Cl8Ch13A3CommunicableDiseasesTransmissionPage> createState() =>
      _Cl8Ch13A3CommunicableDiseasesTransmissionPageState();
}

class _Cl8Ch13A3CommunicableDiseasesTransmissionPageState
    extends State<Cl8Ch13A3CommunicableDiseasesTransmissionPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E1B4B), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 8, 20),
    target: _rt_V3(0, -1, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  math.Random _rng = math.Random(133);
  final _rt_Node3D _root = _rt_Node3D(name: 'scenario-root');
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);
  final List<_rt_Label3D> _labels = [];

  // Scenario objects (rebuilt on every scenario change). Draggable objects
  // are kept by id in [_objects].
  final Map<String, _rt_Node3D> _objects = {};
  final List<_rt_Material3D> _lungMats = [];
  _rt_Node3D? _soap;
  _rt_Material3D? _soapMat;
  _rt_Label3D? _soapLabel;
  _Person? _healthy; // S2
  _Person? _sick;
  _rt_Material3D? _mosquitoMat;
  _rt_Label3D? _healthyLabel;
  _rt_Node3D? _bed;
  _rt_Node3D? _netBundle;
  _rt_Node3D? _netCanopy;
  _rt_Node3D? _aura;
  _rt_Node3D? _spot; // S3
  _rt_Material3D? _spotMat;
  _rt_Node3D? _village;
  final List<_rt_Node3D> _zoneNodes = [];
  _Person? _you; // S4
  _Person? _classmate;
  _rt_Node3D? _faceMask;
  _rt_Node3D? _dispenser;
  _rt_Material3D? _dispenserMat;
  _rt_Node3D? _redRing;
  _rt_Line3D? _distanceLine;
  _rt_Label3D? _distanceLabel;
  final List<(_rt_Node3D, _rt_V3, double)> _droplets = [];

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

  bool _virusIn = false; // S1
  final Set<String> _symptoms = {};
  bool _symptomsOk = false;
  bool _handsWashed = false;
  bool _sharingOff = false;
  bool _carrying = false; // S2
  bool _bitten = false;
  double _temp = 37;
  bool _chills = false;
  bool _netOn = false;
  bool _sprayOn = false;
  bool _bhadrak = false; // S3
  int _built = 0;
  final Set<int> _builtZones = {};
  double _usage = 10;
  bool _reduced = false;
  final Set<int> _admin = {}; // S4
  bool _adminDone = false;
  int? _dialWrong;
  bool _dialDone = false;
  bool _maskOn = false;
  bool _sanitized = false;
  double _distance = 0.5;
  bool _distanceDone = false;
  final List<String> _packed = []; // S5
  final Map<String, String> _logic = {}; // box -> chip
  bool _logicDone = false;
  String? _selectedChip;
  String? _wrongZone;

  // 3D drag (on the vertical plane through the drop targets, facing the
  // camera, so the object stays under the finger; S3 bricks slide over the
  // ground instead).
  String? _dragId;
  _rt_V3? _planePoint;
  _rt_V3? _planeNormal;
  Offset _grabOffset = Offset.zero;
  double _dragTravel = 0;
  Offset? _lastPointer;

  /// The full-screen logic board (S5): no 3D toolbar.
  bool get _panelMode => _scenario == 5 && _step == 3;

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
      ..maxDistance = 55
      ..maxPolarAngle = math.pi * 0.47;
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(15, 25, 10), intensity: 0.8),
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
            background: const Color(0xD91E293B),
            borderColor: _accent,
          )
          ..pickable = false
          ..visible = _labelsOn;
    label.userData['key'] = key;
    _labels.add(label);
    return label;
  }

  /// Applies the labels toggle and language (labels marked hidden stay
  /// hidden; number readouts keep their text).
  void _syncLabels() {
    for (final l in _labels) {
      final key = l.userData['key'];
      if (key != null) l.text = _tx.s('lbl.$key');
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
    double? scale,
    double Function(double) ease = _rt_Ease.inOutCubic,
  }) {
    final from = n.position.clone();
    final fromRot = n.rotation.clone();
    final fromScale = n.scale.x;
    return _tweens.run(ms, (t) {
      n.position.copy(from.lerp(to, t));
      if (rot != null) n.rotation.copy(fromRot.lerp(rot, t));
      if (scale != null) {
        final s = fromScale + (scale - fromScale) * t;
        n.scale.set(s, s, s);
      }
    }, ease: ease);
  }

  _rt_Mesh3D _floor(double w, double d, Color color, {double x = 0}) =>
      _mesh(_rt_Geometry3D.box(w, 0.2, d), color)
        ..position.set(x, -3.6, 0)
        ..depthBias = 40;

  /// A simple standing person (short sleeves in the shirt colour).
  _Person _person({
    required Color skin,
    required Color shirt,
    Color pants = const Color(0xFF1E293B),
    Color hair = const Color(0xFF271C19),
  }) {
    final skinMat = _rt_Material3D(color: skin, shininess: 0.3);
    final node = _rt_Node3D(name: 'person');
    for (final side in const [-1.0, 1.0]) {
      node
        ..add(
          _mesh(_rt_Geometry3D.cylinder(0.3, 0.27, 2.8, segments: 12), pants)
            ..position.set(0.38 * side, 1.5, 0),
        )
        ..add(
          _mesh(_rt_Geometry3D.box(0.42, 0.24, 0.72), const Color(0xFF0F172A))
            ..position.set(0.38 * side, 0.12, 0.12),
        );
    }
    node.add(
      _mesh(_rt_Geometry3D.cylinder(0.85, 0.72, 2.6, segments: 18), shirt)
        ..position.y = 4.1
        ..scale.set(1, 1, 0.62),
    );
    _rt_Node3D arm(double side) {
      final a = _rt_Node3D()
        ..position.set(1.02 * side, 5.15, 0)
        ..rotation.z = 0.12 * side;
      a
        ..add(
          _mesh(_rt_Geometry3D.cylinder(0.3, 0.28, 0.9, segments: 10), shirt)
            ..position.y = -0.4,
        )
        ..add(
          _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.24, 0.21, 1.7, segments: 10),
            skinMat,
          )..position.y = -1.6,
        )
        ..add(_rt_Sphere3D(0.25, skinMat)..position.y = -2.55);
      node.add(a);
      return a;
    }

    final left = arm(-1);
    final right = arm(1);
    node.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.28, 0.3, 0.5, segments: 10), skinMat)
        ..position.y = 5.6,
    );
    final head = _rt_Node3D()..position.y = 6.35;
    head
      ..add(_rt_Sphere3D(0.72, skinMat))
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(
              0.77,
              widthSegments: 16,
              heightSegments: 6,
              thetaLength: math.pi * 0.42,
            ),
            hair,
          )
          ..position.y = 0.06
          ..rotation.x = -0.25,
      );
    for (final side in const [-1.0, 1.0]) {
      head.add(
        _ball(0.08, const Color(0xFF111827))
          ..position.set(0.25 * side, 0.1, 0.66),
      );
    }
    head.add(
      _mesh(_rt_Geometry3D.box(0.3, 0.06, 0.05), const Color(0xFF7F1D1D))
        ..position.set(0, -0.3, 0.68),
    );
    node.add(head);
    return _Person(node, skinMat, left, right, head);
  }

  // ---------------------------------------------------------- scenes ---
  void _buildScenario() {
    _root.clear();
    _labels.clear();
    _objects.clear();
    _lungMats.clear();
    _zoneNodes.clear();
    _droplets.clear();
    _soap = _bed = _netBundle = _netCanopy = _aura = null;
    _spot = _village = _faceMask = _dispenser = _redRing = null;
    _soapMat = _mosquitoMat = _spotMat = _dispenserMat = null;
    _soapLabel = _healthyLabel = _distanceLabel = null;
    _distanceLine = null;
    _healthy = _sick = _you = _classmate = null;
    _rng = math.Random(133 + _scenario);
    switch (_scenario) {
      case 1:
        _buildBody();
      case 2:
        _buildMalaria();
      case 3:
        _buildVillage();
      case 4:
        _buildClassroom();
      case 5:
        _buildBedroom();
    }
    _syncLabels();
  }

  /// S1: glass body with lungs, the virus seen in a petri dish under the
  /// microscope (content fix: the source showed a magnifying glass, which
  /// cannot show viruses), and the soap.
  void _buildBody() {
    _root.add(_floor(22, 12, const Color(0xFF1E293B)));
    const glass = Color(0xFF93C5FD);
    final body = _rt_Node3D(name: 'body')..position.set(-4.5, 0, -1);
    body
      ..add(
        _mesh(_rt_Geometry3D.cylinder(1.2, 1.6, 0.6), const Color(0xFF334155))
          ..position.y = -3.2,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(2.3, 1.8, 5.6, segments: 28),
            glass,
            opacity: 0.22,
          )
          ..scale.set(1, 1, 0.55)
          ..depthBias = 6,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.55, 0.6, 1.0, segments: 16),
          glass,
          opacity: 0.25,
        )..position.y = 3.2,
      )
      ..add(_ball(1.5, glass, opacity: 0.25)..position.y = 4.9);
    final lungs = _rt_Node3D(name: 'lungs')..position.set(0, 0.6, 0.15);
    _rt_Material3D lungMat(Color c, double opacity) {
      final m = _rt_Material3D(color: c, opacity: opacity, shininess: 0.3);
      _lungMats.add(m);
      return m;
    }

    lungs.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.18, 0.2, 1.8, segments: 10),
        lungMat(const Color(0xFFF87171), 1),
      )..position.y = 2.0,
    );
    for (final side in const [-1.0, 1.0]) {
      lungs
        ..add(
          _rt_Mesh3D(
              _rt_Geometry3D.cylinder(0.12, 0.12, 1.1, segments: 8),
              lungMat(const Color(0xFFF87171), 1),
            )
            ..position.set(0.4 * side, 0.85, 0)
            ..rotation.z = -0.9 * side,
        )
        ..add(
          _rt_Mesh3D(
              _rt_Geometry3D.sphere(1.0, widthSegments: 18, heightSegments: 12),
              lungMat(const Color(0xFFFCA5A5), 0.9),
            )
            ..position.set(1.0 * side, -0.2, 0)
            ..scale.set(0.85, 1.35, 0.6),
        );
    }
    body.add(lungs);
    _root
      ..add(body)
      ..add(_label('resp', -4.5, -1.7, 0.2));

    // Desk with the petri dish and the soap.
    _root.add(
      _mesh(_rt_Geometry3D.box(7.4, 0.4, 4.6), const Color(0xFF475569))
        ..position.set(4.6, -1.4, 0.6),
    );
    for (final (lx, lz) in const [
      (1.3, -1.3),
      (7.9, -1.3),
      (1.3, 2.5),
      (7.9, 2.5),
    ]) {
      _root.add(
        _mesh(
          _rt_Geometry3D.cylinder(0.14, 0.14, 2.0, segments: 8),
          const Color(0xFF334155),
        )..position.set(lx, -2.6, lz),
      );
    }
    _root
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.3, 1.3, 0.22, segments: 32),
          const Color(0xFFE0F2FE),
          opacity: 0.5,
        )..position.set(4.6, -1.08, 0.6),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.18, 1.18, 0.1, segments: 32),
          const Color(0xFFFBCFE8),
          opacity: 0.85,
        )..position.set(4.6, -1.05, 0.6),
      )
      ..add(_label('dish', 4.6, -0.9, 2.6));
    // Microscope view: a magnified circle over the dish, with call-out lines.
    const bubbleY = 2.5;
    _root
      ..add(
        _mesh(
          _rt_Geometry3D.circle(1.75, segments: 40),
          const Color(0xFF0F172A),
          opacity: 0.88,
          doubleSided: true,
        )..position.set(4.6, bubbleY, 0.5),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.torus(
            1.75,
            0.08,
            radialSegments: 6,
            tubularSegments: 40,
          ),
          const Color(0xFF67E8F9),
        )..position.set(4.6, bubbleY, 0.5),
      )
      ..add(
        _rt_Line3D(
          [
            _rt_V3(3.3, -0.95, 0.6),
            _rt_V3(2.95, bubbleY - 0.6, 0.5),
            _rt_V3(5.9, -0.95, 0.6),
            _rt_V3(6.25, bubbleY - 0.6, 0.5),
          ],
          color: const Color(0xFF67E8F9),
          width: 1.5,
          dashed: true,
          segments: true,
        ),
      );
    // Cold virus (magnified): capsid with spikes.
    final virus = _rt_Node3D(name: 'virus')..scale.set(0.9, 0.9, 0.9);
    virus.add(_mesh(_rt_Geometry3D.icosahedron(0.8), const Color(0xFF7C3AED)));
    for (final v in _rt_Geometry3D.icosahedron(0.8).vertices) {
      final dir = v.normalized();
      virus
        ..add(
          _mesh(
              _rt_Geometry3D.cylinder(0.04, 0.04, 0.4, segments: 5),
              const Color(0xFF4C1D95),
            )
            ..position.copy(dir * 0.95)
            ..pointAlong(dir),
        )
        ..add(_ball(0.12, const Color(0xFFC084FC))..position.copy(dir * 1.17));
    }
    virus
      ..add(_proxy(_rt_Geometry3D.sphere(1.4)))
      ..add(_label('virus', 0, 2.3, 0));
    _setHome(virus, 4.6, bubbleY, 0.8);
    _root.add(_draggable('virus', virus));

    // Soap bar (step 4).
    final soapMat = _rt_Material3D(
      color: const Color(0xFF38BDF8),
      shininess: 0.6,
    );
    _soapMat = soapMat;
    final soap = _rt_Node3D(name: 'soap')
      ..position.set(2.2, -1.0, 1.9)
      ..visible = false
      ..userData['tap'] = 'soap';
    soap
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.capsule(0.3, 0.9, segments: 14), soapMat)
          ..rotation.z = math.pi / 2
          ..scale.set(1, 1, 1.6),
      )
      ..add(_proxy(_rt_Geometry3D.sphere(1.0)));
    _soap = soap;
    final soapLabel = _label('soap', 2.2, 0.1, 1.9)..userData['hidden'] = true;
    _soapLabel = soapLabel;
    _root
      ..add(soap)
      ..add(soapLabel);
  }

  /// S2: a person with malaria, a healthy person, the mosquito; the bed,
  /// net and repellent come in step 4.
  void _buildMalaria() {
    _root.add(_floor(22, 12, const Color(0xFF64748B)));
    final healthy = _person(
      skin: const Color(0xFFFCD34D),
      shirt: const Color(0xFF3B82F6),
    );
    healthy.node
      ..position.set(-5.8, -3.5, -0.6)
      ..rotation.y = 0.3
      ..scale.set(0.7, 0.7, 0.7);
    _healthy = healthy;
    final sick = _person(
      skin: const Color(0xFFF87171),
      shirt: const Color(0xFF10B981),
      hair: const Color(0xFF3F2A1E),
    );
    sick.node
      ..position.set(6.0, -3.5, -1.2)
      ..rotation.y = -0.35
      ..scale.set(0.7, 0.7, 0.7);
    _sick = sick;
    final healthyLabel = _label('human', -5.8, 2.1, -0.6);
    _healthyLabel = healthyLabel;
    _root
      ..add(healthy.node)
      ..add(sick.node)
      ..add(healthyLabel)
      ..add(_label('infected', 6.0, 2.1, -1.2));

    // Mosquito (head towards -x).
    final mMat = _rt_Material3D(color: const Color(0xFF1E293B), shininess: 0.4);
    _mosquitoMat = mMat;
    final mosquito = _rt_Node3D(name: 'mosquito')..scale.set(0.9, 0.9, 0.9);
    for (var k = 0; k < 5; k++) {
      mosquito.add(
        _ball(
          0.3 - k * 0.03,
          k.isEven ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
        )..position.set(0.55 + k * 0.34, -0.04 * k, 0),
      );
    }
    mosquito
      ..add(_rt_Sphere3D(0.4, mMat))
      ..add(_rt_Sphere3D(0.24, mMat)..position.set(-0.55, 0.02, 0))
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.035, 0.02, 0.8, segments: 6), mMat)
          ..position.set(-0.98, -0.18, 0)
          ..rotation.z = math.pi / 2 + 0.45,
      );
    for (final side in const [-1.0, 1.0]) {
      mosquito.add(
        _mesh(
            _rt_Geometry3D.sphere(0.8, widthSegments: 14, heightSegments: 8),
            Colors.white,
            opacity: 0.4,
            doubleSided: true,
          )
          ..position.set(0.55, 0.32, 0.45 * side)
          ..rotation.y = -0.45 * side
          ..scale.set(1.15, 0.05, 0.42),
      );
    }
    final legs = <_rt_V3>[];
    for (final side in const [-1.0, 1.0]) {
      for (final dx in const [-0.3, 0.0, 0.3]) {
        legs
          ..add(_rt_V3(dx * 0.6, -0.25, 0.18 * side))
          ..add(_rt_V3(dx * 1.8, -1.05, 0.75 * side));
      }
    }
    mosquito
      ..add(
        _rt_Line3D(
          legs,
          color: const Color(0xFF0F172A),
          width: 1.5,
          segments: true,
        ),
      )
      ..add(_proxy(_rt_Geometry3D.sphere(1.5))..position.x = 0.3)
      ..add(_label('mosquito', 0.3, 1.3, 0));
    _setHome(mosquito, 0.8, 2.4, 0.4);
    _root.add(_draggable('mosquito', mosquito));

    // Step 4: bed, net (rolled up until placed) and repellent.
    final bed = _rt_Node3D(name: 'bed')
      ..position.set(-0.6, -3.5, 1.2)
      ..visible = false;
    bed
      ..add(
        _mesh(_rt_Geometry3D.box(5.8, 0.5, 3.6), const Color(0xFF451A03))
          ..position.y = 0.55,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(5.6, 0.35, 3.4), const Color(0xFFF8FAFC))
          ..position.y = 0.98,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(3.4, 0.14, 3.5), const Color(0xFF2563EB))
          ..position.set(1.0, 1.2, 0),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(1.0, 0.3, 2.4), Colors.white)
          ..position.set(-2.2, 1.3, 0),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.3, 1.8, 3.6), const Color(0xFF451A03))
          ..position.set(-2.95, 1.2, 0),
      )
      ..add(_label('bed', 0, 2.2, 1.6));
    _bed = bed;
    _root.add(bed);

    final net = _rt_Node3D(name: 'net')..visible = false;
    final bundle = _rt_Node3D()
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.38, 0.38, 2.2, segments: 14),
            const Color(0xFFDBEAFE),
            opacity: 0.9,
            edge: const Color(0xFF93C5FD),
          )
          ..position.y = 0.4
          ..rotation.z = math.pi / 2,
      )
      ..add(_proxy(_rt_Geometry3D.sphere(1.2))..position.y = 0.4)
      ..add(_label('net', 0, 1.6, 0));
    _netBundle = bundle;
    final canopy = _rt_Node3D()..visible = false;
    canopy.add(
      _mesh(
          _rt_Geometry3D.box(6.0, 3.0, 3.8),
          const Color(0xFFDBEAFE),
          opacity: 0.16,
          edge: const Color(0xFFE0F2FE),
          doubleSided: true,
        )
        ..position.y = 2.7
        ..depthBias = -4,
    );
    for (final (px, pz) in const [
      (-2.95, -1.85),
      (2.95, -1.85),
      (-2.95, 1.85),
      (2.95, 1.85),
    ]) {
      canopy.add(
        _mesh(
          _rt_Geometry3D.cylinder(0.05, 0.05, 4.2, segments: 6),
          const Color(0xFFCBD5E1),
        )..position.set(px, 2.1, pz),
      );
    }
    _netCanopy = canopy;
    net
      ..add(bundle)
      ..add(canopy);
    _setHome(net, 3.4, -3.5, 3.8);
    final spray = _rt_Node3D(name: 'spray')..visible = false;
    spray
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.36, 0.36, 1.3, segments: 16),
          const Color(0xFF22C55E),
          shininess: 0.6,
        )..position.y = 0.65,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.26, 0.3, 0.3, segments: 12),
          Colors.white,
        )..position.y = 1.45,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.16, 0.16, 0.26), const Color(0xFF334155))
          ..position.set(0, 1.66, 0.12),
      )
      ..add(_proxy(_rt_Geometry3D.capsule(0.7, 1.4))..position.y = 0.9)
      ..add(_label('spray', 0, 2.5, 0));
    _setHome(spray, 6.0, -3.5, 3.6);
    _root
      ..add(_draggable('net', net))
      ..add(_draggable('spray', spray));
  }

  /// S3: map of Odisha on an easel, and the village (shown once Bhadrak is
  /// picked) with five construction zones and the brick pile.
  void _buildVillage() {
    _root.add(_floor(26, 12, const Color(0xFF1E293B), x: 1.5));
    final easel = _rt_Node3D(name: 'easel')
      ..position.set(-8.2, -3.5, -1.0)
      ..rotation.y = 0.35
      ..userData['tap'] = 'map';
    for (final side in const [-1.0, 1.0]) {
      easel.add(
        _mesh(
            _rt_Geometry3D.cylinder(0.1, 0.1, 6.4, segments: 6),
            const Color(0xFF5C2C09),
          )
          ..position.set(1.4 * side, 3.0, -0.3)
          ..rotation.z = -0.18 * side
          ..depthBias = 40,
      );
    }
    easel
      ..add(
        _mesh(_rt_Geometry3D.box(5.6, 4.6, 0.15), const Color(0xFF78350F))
          ..position.set(0, 4.0, -0.1)
          ..depthBias = 30,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(5.2, 4.2, 0.2), const Color(0xFFFEF08A))
          ..position.set(0, 4.0, 0)
          ..depthBias = 20,
      );
    // Odisha outline (rough), 4.0 x 3.4 on the plaque.
    const outline = [
      Offset(0.02, 0.42),
      Offset(0.10, 0.30),
      Offset(0.22, 0.20),
      Offset(0.28, 0.05),
      Offset(0.40, 0.10),
      Offset(0.55, 0.25),
      Offset(0.70, 0.38),
      Offset(0.80, 0.50),
      Offset(0.88, 0.60),
      Offset(0.95, 0.72),
      Offset(0.85, 0.82),
      Offset(0.70, 0.92),
      Offset(0.50, 0.95),
      Offset(0.35, 0.80),
      Offset(0.15, 0.75),
      Offset(0.05, 0.55),
    ];
    Offset onPlaque(Offset p) => Offset((p.dx - 0.5) * 4.0, (p.dy - 0.5) * 3.4);
    easel.add(
      _mesh(
          _rt_Geometry3D.extrude([for (final p in outline) onPlaque(p)], 0.06),
          const Color(0xFF86EFAC),
          doubleSided: true,
        )
        ..position.set(0, 4.0, 0.1)
        ..depthBias = 10,
    );
    final spotMat = _rt_Material3D(
      color: const Color(0xFFEF4444),
      shininess: 0.4,
    );
    _spotMat = spotMat;
    final bhadrak = onPlaque(const Offset(0.82, 0.64));
    final spot = _rt_Node3D(name: 'bhadrak')
      ..position.set(bhadrak.dx, 4.0 + bhadrak.dy, 0.2)
      ..depthBias = -5
      ..userData['tap'] = 'bhadrak';
    spot
      ..add(
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.3, 0.3, 0.12, segments: 20),
            spotMat,
          )
          ..rotation.x = math.pi / 2
          ..depthBias = -5,
      )
      ..add(_proxy(_rt_Geometry3D.sphere(0.75)));
    _spot = spot;
    easel
      ..add(spot)
      ..add(_label('map', 0, 6.8, 0));
    _root.add(easel);

    // The village (hidden until Bhadrak is chosen).
    final village = _rt_Node3D(name: 'village')..visible = false;
    village
      ..add(
        _mesh(_rt_Geometry3D.box(14, 0.2, 9.6), const Color(0xFF65A30D))
          ..position.set(4, -3.45, -0.8)
          ..depthBias = 30,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(14, 0.21, 1.0), const Color(0xFFD97706))
          ..position.set(4, -3.44, -0.9)
          ..depthBias = 25,
      );
    for (final (tx, tz) in const [(-1.8, -4.6), (10.2, -4.6), (10.4, 2.6)]) {
      village
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(0.22, 0.28, 1.4, segments: 8),
            const Color(0xFF78350F),
          )..position.set(tx, -2.7, tz),
        )
        ..add(
          _mesh(
            _rt_Geometry3D.cone(1.1, 2.4, segments: 10),
            const Color(0xFF15803D),
          )..position.set(tx, -0.9, tz),
        );
    }
    for (var k = 0; k < 6; k++) {
      village.add(
        _mesh(_rt_Geometry3D.icosahedron(0.22), const Color(0xFF94A3B8))
          ..position.set(
            -1 + _rng.nextDouble() * 11,
            -3.3,
            -5 + _rng.nextDouble() * 1.2,
          ),
      );
    }
    for (final (zx, zz) in _zones) {
      final zone = _rt_Node3D()..position.set(zx, -3.33, zz);
      zone
        ..add(
          _mesh(
              _rt_Geometry3D.circle(1.1, segments: 28),
              const Color(0xFF78350F),
              doubleSided: true,
            )
            ..rotation.x = -math.pi / 2
            ..depthBias = 20,
        )
        ..add(
          _mesh(
              _rt_Geometry3D.ring(1.1, 1.25, segments: 28),
              Colors.white,
              doubleSided: true,
            )
            ..rotation.x = -math.pi / 2
            ..depthBias = 18,
        );
      _zoneNodes.add(zone);
      village.add(zone);
    }
    _village = village;
    _root.add(village);
    final bricks = _rt_Node3D(name: 'bricks')..visible = false;
    for (var k = 0; k < 12; k++) {
      final layer = k ~/ 4, i = k % 4;
      bricks.add(
        _mesh(_rt_Geometry3D.box(0.62, 0.3, 0.32), const Color(0xFFB45309))
          ..position.set(
            (i % 2) * 0.66 - 0.33 + (layer.isOdd ? 0.16 : 0),
            0.15 + layer * 0.31,
            (i ~/ 2) * 0.36 - 0.18,
          ),
      );
    }
    bricks
      ..add(_proxy(_rt_Geometry3D.sphere(1.1))..position.y = 0.5)
      ..add(_label('bricks', 0, 1.7, 0));
    _setHome(bricks, -2.8, -3.5, 3.6);
    _root.add(_draggable('bricks', bricks));
  }

  /// A finished latrine on zone [i] (inside the scenario group, standing on
  /// the ground - the source buried them and leaked them into other
  /// scenarios).
  _rt_Node3D _hut(int i) {
    final (zx, zz) = _zones[i];
    final hut = _rt_Node3D()
      ..position.set(zx, -3.35, zz)
      ..scale.set(0.05, 0.05, 0.05);
    hut
      ..add(
        _mesh(_rt_Geometry3D.box(1.6, 1.4, 1.6), const Color(0xFFD1D5DB))
          ..position.y = 0.7,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cone(1.35, 1.0, segments: 4),
            const Color(0xFFEF4444),
          )
          ..position.y = 1.9
          ..rotation.y = math.pi / 4,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.5, 0.85, 0.05), const Color(0xFF78350F))
          ..position.set(0, 0.43, 0.82),
      );
    return hut;
  }

  /// S4: classroom with you, a sick classmate, the mask on a stool and the
  /// wall sanitizer (moved out of the locker it sat inside).
  void _buildClassroom() {
    _root
      ..add(_floor(20, 12, const Color(0xFFCBD5E1)))
      ..add(
        _mesh(_rt_Geometry3D.box(20, 7.5, 0.3), const Color(0xFF94A3B8))
          ..position.set(0, 0.25, -5.0)
          ..depthBias = 50,
      );
    final tiles = <_rt_V3>[];
    for (var x = -9.0; x <= 9.0; x += 2) {
      tiles
        ..add(_rt_V3(x, -3.49, -4.8))
        ..add(_rt_V3(x, -3.49, 5.8));
    }
    for (var z = -4.0; z <= 6.0; z += 2) {
      tiles
        ..add(_rt_V3(-10, -3.49, z))
        ..add(_rt_V3(10, -3.49, z));
    }
    _root
      ..add(
        _rt_Line3D(
          tiles,
          color: const Color(0xFF94A3B8),
          width: 1,
          segments: true,
        ),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(6.2, 2.8, 0.12), const Color(0xFF475569))
          ..position.set(-3.0, 0.8, -4.8),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(5.8, 2.4, 0.12), Colors.white)
          ..position.set(-3.0, 0.8, -4.74),
      );
    for (var i = 0; i < 3; i++) {
      _root.add(
        _mesh(_rt_Geometry3D.box(1.3, 4.6, 1.2), const Color(0xFFEF4444))
          ..position.set(5.0 + i * 1.4, -1.2, -4.2),
      );
    }
    // Wall sanitizer (tap it in step 4).
    final dispMat = _rt_Material3D(color: const Color(0xFFF8FAFC));
    _dispenserMat = dispMat;
    final dispenser = _rt_Node3D(name: 'sanitizer')
      ..position.set(2.0, 0.2, -4.6)
      ..userData['tap'] = 'sanitizer';
    dispenser
      ..add(_rt_Mesh3D(_rt_Geometry3D.box(0.9, 1.3, 0.5), dispMat))
      ..add(
        _mesh(_rt_Geometry3D.box(0.5, 0.5, 0.06), const Color(0xFF22D3EE))
          ..position.set(0, 0.15, 0.27),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.2, 0.3, 0.3), const Color(0xFF334155))
          ..position.set(0, -0.75, 0.15),
      )
      ..add(_proxy(_rt_Geometry3D.box(1.6, 2.2, 1.2)))
      ..add(_label('sanitizer', 0, 1.3, 0.3));
    _dispenser = dispenser;
    _root.add(dispenser);

    final you = _person(
      skin: const Color(0xFFFCD34D),
      shirt: const Color(0xFF3B82F6),
    );
    you.node
      ..position.set(_youX, -3.5, 1.0)
      ..rotation.y = 0.45
      ..scale.set(0.62, 0.62, 0.62);
    // The mask on your face (shown once it is on).
    final faceMask = _rt_Node3D()..visible = false;
    faceMask
      ..add(
        _mesh(_rt_Geometry3D.box(0.95, 0.5, 0.22), Colors.white)
          ..position.set(0, -0.2, 0.62),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(1.5, 0.06, 0.06), const Color(0xFFCBD5E1))
          ..position.set(0, -0.1, 0.3),
      );
    _faceMask = faceMask;
    you.head.add(faceMask);
    _you = you;
    final classmate = _person(
      skin: const Color(0xFFBBF7D0),
      shirt: const Color(0xFF9333EA),
    );
    classmate.node
      ..rotation.y = -0.45
      ..scale.set(0.62, 0.62, 0.62);
    classmate.head.add(
      _ball(0.13, const Color(0xFFEF4444))..position.set(0, -0.05, 0.72),
    );
    for (var k = 0; k < 3; k++) {
      final d = _ball(0.12, const Color(0xFFA7F3D0), opacity: 0.85);
      final base = _rt_V3(-0.15 + 0.15 * k, -0.3, 0.9);
      _droplets.add((d, base, k / 3));
      classmate.head.add(d);
    }
    classmate.node.add(_label('sick', 0, 8.0, 0));
    _classmate = classmate;
    _root
      ..add(you.node)
      ..add(classmate.node)
      ..add(_label('you', _youX, 1.9, 1.0))
      ..add(
        _mesh(
            _rt_Geometry3D.ring(1.25, 1.4, segments: 32),
            const Color(0xFF3B82F6),
            doubleSided: true,
          )
          ..rotation.x = -math.pi / 2
          ..position.set(_youX, -3.47, 1.0),
      );
    final redRing =
        _mesh(
            _rt_Geometry3D.ring(1.25, 1.4, segments: 32),
            const Color(0xFFEF4444),
            doubleSided: true,
          )
          ..rotation.x = -math.pi / 2
          ..position.y = -3.47;
    _redRing = redRing;
    final line = _rt_Line3D(
      [_rt_V3(), _rt_V3()],
      color: const Color(0xFF1E3A8A),
      width: 2.5,
      dashed: true,
    );
    _distanceLine = line;
    final readout = _rt_Label3D(
      '',
      pixelHeight: 12,
      color: Colors.white,
      background: const Color(0xD91E3A8A),
      borderColor: _accentSoft,
    )..pickable = false;
    _distanceLabel = readout;
    _labels.add(readout);
    _root
      ..add(redRing)
      ..add(line)
      ..add(readout);
    // Mask on a stool in front of you.
    _root
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.7, 0.7, 0.2, segments: 16),
          const Color(0xFFD97706),
        )..position.set(-7.4, -1.6, 2.6),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.12, 0.12, 1.8, segments: 8),
          const Color(0xFF78350F),
        )..position.set(-7.4, -2.6, 2.6),
      );
    final mask = _rt_Node3D(name: 'mask')..visible = false;
    mask
      ..add(_mesh(_rt_Geometry3D.box(0.95, 0.5, 0.22), Colors.white))
      ..add(
        _mesh(_rt_Geometry3D.box(1.5, 0.06, 0.06), const Color(0xFFCBD5E1))
          ..position.z = -0.1,
      )
      ..add(_proxy(_rt_Geometry3D.sphere(1.0)))
      ..add(_label('mask', 0, 1.0, 0));
    _setHome(mask, -7.4, -1.15, 2.6);
    _root.add(_draggable('mask', mask));
    _placeClassmate();
  }

  /// Puts the classmate [_distance] metres from you.
  void _placeClassmate() {
    final x = _youX + _distance * _metre;
    _classmate?.node.position.set(x, -3.5, 1.0);
    _redRing?.position.set(x, -3.47, 1.0);
    _distanceLine?.points = [_rt_V3(_youX, -3.42, 2.6), _rt_V3(x, -3.42, 2.6)];
    _distanceLabel
      ?..position.set((_youX + x) / 2, -2.9, 2.6)
      ..text = '${(_distance + 1e-6).toStringAsFixed(1)} m';
  }

  /// S5: bedroom with the open suitcase and five items to choose from.
  void _buildBedroom() {
    _root
      ..add(_floor(20, 12, const Color(0xFFCBD5E1)))
      ..add(
        _mesh(_rt_Geometry3D.box(20, 8, 0.3), const Color(0xFF94A3B8))
          ..position.set(0, 0.5, -5.0)
          ..depthBias = 50,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(3.4, 2.4, 0.1), const Color(0xFF78350F))
          ..position.set(-5.0, 1.4, -4.8),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(3.0, 2.0, 0.1), const Color(0xFF7DD3FC))
          ..position.set(-5.0, 1.4, -4.74),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(3.2, 6.2, 1.6), const Color(0xFF78350F))
          ..position.set(7.4, -0.4, -4.0),
      );
    final suitcase = _rt_Node3D(name: 'suitcase')..position.set(0, -3.5, 0);
    suitcase
      ..add(
        _mesh(_rt_Geometry3D.box(5.0, 0.9, 3.4), const Color(0xFF1E293B))
          ..position.y = 0.45,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(4.6, 0.06, 3.0), const Color(0xFF475569))
          ..position.y = 0.92,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(5.0, 3.4, 0.25), const Color(0xFF1E293B))
          ..position.set(0, 2.45, -1.95)
          ..rotation.x = -0.22,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(1.2, 0.2, 0.3), const Color(0xFF64748B))
          ..position.set(0, 4.2, -2.3),
      );
    _root
      ..add(suitcase)
      ..add(_label('case', 0, 1.6, -2.4));
    // Items stand on the floor (the label rides on an unrotated group).
    _rt_Node3D item(String id, double x, double z, _rt_Node3D body) {
      final n = _rt_Node3D(name: id)
        ..add(body)
        ..add(_proxy(_rt_Geometry3D.sphere(1.2))..position.y = 0.6)
        ..add(_label(id, 0, 1.9, 0));
      _setHome(n, x, -3.5, z);
      return _draggable(id, n);
    }

    _rt_Node3D shirtBody(List<Offset> shape, Color c) => _rt_Node3D()
      ..add(
        _mesh(_rt_Geometry3D.extrude(shape, 0.14), c, doubleSided: true)
          ..position.y = 0.25
          ..rotation.x = -math.pi / 2 + 0.55
          ..scale.set(0.7, 0.7, 1),
      );
    const fullSleeve = [
      Offset(-0.8, -1.3),
      Offset(0.8, -1.3),
      Offset(0.8, 0.1),
      Offset(1.55, -1.2),
      Offset(2.0, -1.0),
      Offset(1.2, 0.8),
      Offset(0.45, 1.1),
      Offset(0, 0.85),
      Offset(-0.45, 1.1),
      Offset(-1.2, 0.8),
      Offset(-2.0, -1.0),
      Offset(-1.55, -1.2),
      Offset(-0.8, 0.1),
    ];
    const sleeveless = [
      Offset(-0.8, -1.3),
      Offset(0.8, -1.3),
      Offset(0.8, 0.5),
      Offset(0.55, 1.1),
      Offset(0.25, 1.1),
      Offset(0, 0.8),
      Offset(-0.25, 1.1),
      Offset(-0.55, 1.1),
      Offset(-0.8, 0.5),
    ];
    final netRoll = _rt_Node3D()
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.4, 0.4, 2.0, segments: 14),
            const Color(0xFFDBEAFE),
            opacity: 0.9,
            edge: const Color(0xFF93C5FD),
          )
          ..position.y = 0.42
          ..rotation.z = math.pi / 2,
      );
    final can = _rt_Node3D()
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.36, 0.36, 1.2, segments: 16),
          const Color(0xFF22C55E),
          shininess: 0.6,
        )..position.y = 0.6,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.26, 0.3, 0.3, segments: 12),
          Colors.white,
        )..position.y = 1.35,
      );
    final perfume = _rt_Node3D()
      ..add(
        _mesh(
          _rt_Geometry3D.box(0.7, 0.9, 0.5),
          const Color(0xFFF5D0FE),
          opacity: 0.8,
        )..position.y = 0.45,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.octahedron(0.35),
          const Color(0xFFD946EF),
          shininess: 0.6,
        )..position.y = 1.2,
      );
    _root
      ..add(
        item(
          'shirt',
          -4.6,
          2.6,
          shirtBody(fullSleeve, const Color(0xFF3B82F6)),
        ),
      )
      ..add(
        item(
          'sleeveless',
          4.6,
          2.6,
          shirtBody(sleeveless, const Color(0xFFEF4444)),
        ),
      )
      ..add(item('packNet', -5.4, -1.2, netRoll))
      ..add(item('repellent', 5.4, -1.0, can))
      ..add(item('perfume', 1.6, 3.4, perfume));
  }

  /// Shows only what the current step uses.
  void _applyStepVisuals() {
    switch (_scenario) {
      case 1:
        _soap?.visible = _step >= 4;
        _showLabel(_soapLabel, _step >= 4 && !_handsWashed);
      case 2:
        final protect = _step >= 4;
        _bed?.visible = protect;
        _objects['net']?.visible = protect;
        _objects['spray']?.visible = protect && !_sprayOn;
      case 4:
        _objects['mask']?.visible = _step >= 4 && !_maskOn;
    }
  }

  // ------------------------------------------------------------ camera ---
  /// Points that must stay on screen in the current scenario.
  List<_rt_V3> get _framePoints => switch (_scenario) {
    1 => [
      _rt_V3(-7.0, -3.5, -1),
      _rt_V3(-2.0, -3.5, -1),
      _rt_V3(-4.5, 6.5, -1),
      _rt_V3(8.2, -3.5, 0.6),
      _rt_V3(1.2, -3.5, 2.9),
      _rt_V3(4.6, 5.0, 0.8),
    ],
    2 => [
      _rt_V3(-7.4, -3.5, -0.6),
      _rt_V3(7.6, -3.5, -1.2),
      // Room for the name labels over the heads.
      _rt_V3(-8.6, 2.2, -0.6),
      _rt_V3(8.8, 2.2, -1.2),
      _rt_V3(-5.8, 2.6, -0.6),
      _rt_V3(6.0, 2.6, -1.2),
      _rt_V3(0.8, 3.9, 0.4),
      _rt_V3(6.0, -3.5, 4.4),
      _rt_V3(-3.6, -3.5, 3.0),
    ],
    3 => [
      _rt_V3(-10.4, -3.5, -1.6),
      _rt_V3(-8.2, 3.6, -1.0),
      // Plaque corners (the easel is turned towards the village).
      _rt_V3(-10.8, 2.8, -0.1),
      _rt_V3(-10.8, 0.4, -0.1),
      _rt_V3(11, -3.5, -5.6),
      _rt_V3(11, -3.5, 4.0),
      _rt_V3(-3.6, -3.5, 4.4),
      _rt_V3(-1.8, 0.2, -4.6),
    ],
    4 => [
      _rt_V3(-8.2, -3.5, 3.0),
      _rt_V3(8.8, -3.5, -3.6),
      _rt_V3(8.8, 1.2, -3.6),
      _rt_V3(_youX + 2 * _metre + 0.8, -3.5, 2.6),
      _rt_V3(_youX, 2.3, 1.0),
      _rt_V3(2.0, 1.8, -4.6),
      _rt_V3(2.2, -3.5, 3.2),
      _rt_V3(-6.0, 2.2, -4.8),
      _rt_V3(-7.4, -0.2, 2.6),
    ],
    5 => [
      _rt_V3(-6.8, -3.5, -1.2),
      _rt_V3(6.8, -3.5, -1.0),
      _rt_V3(0, 1.9, -2.4),
      _rt_V3(-6.2, -3.5, 2.6),
      _rt_V3(6.2, -3.5, 2.6),
      _rt_V3(0, -3.5, 4.2),
      _rt_V3(1.6, -1.4, 3.4),
      _rt_V3(-5.4, -1.4, -1.2),
      _rt_V3(5.4, -1.4, -1.0),
    ],
    _ => [_rt_V3()],
  };

  double get _elevation => switch (_scenario) {
    1 => 0.22,
    2 => 0.3,
    3 => 0.62,
    4 => 0.32,
    _ => 0.62,
  };

  /// Width of the chalkboard (step 1) or the step panel on the left.
  double _boardWidth(Size size, bool compact) =>
      math.min(compact ? 270.0 : 420.0, size.width * 0.5);

  double _panelWidth(Size size, bool compact) =>
      math.min(compact ? 210.0 : 320.0, size.width * 0.45);

  /// True for steps that show a panel on the left of the 3D view.
  bool get _hasSidePanel => switch ((_scenario, _step)) {
    (1, 3) || (1, 4) || (2, 3) || (3, 3) || (4, 2) || (4, 3) || (4, 4) => true,
    _ => false,
  };

  /// Canvas size the camera was last fitted for (per scenario and step).
  (int, int, Size)? _fitKey;

  /// Frames the scene in the space left by the chalkboard or step panel,
  /// the HUD and the toolbar (the source's fixed camera pushed props off
  /// narrow screens). A few projection passes converge.
  void _fitCamera(Size size, bool compact) {
    final key = (_scenario, _step, size);
    if (_fitKey == key || size.isEmpty || _panelMode) return;
    _fitKey = key;
    final points = _framePoints;
    const margin = 14.0;
    final top = (compact ? 8.0 : 16.0) + margin;
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
    // S4: the classmate's cough droplets drift out and repeat.
    for (final (node, base, phase) in _droplets) {
      final t = (_clock * 0.6 + phase) % 1.0;
      node
        ..position.set(base.x + 0.3 * t, base.y - 0.25 * t, base.z + 1.6 * t)
        ..visible = !_scenarioDone && t < 0.9;
    }
    // S2: the mosquito hovers while it waits.
    final mosquito = _objects['mosquito'];
    if (_scenario == 2 && mosquito != null && _dragId == null && !_busy) {
      final home = mosquito.userData['home'] as _rt_V3;
      if (mosquito.visible && (mosquito.position - home).length < 0.3) {
        mosquito.position.y = home.y + 0.12 * math.sin(_clock * 4);
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
      _virusIn = _symptomsOk = _handsWashed = _sharingOff = false;
      _symptoms.clear();
      _carrying = _bitten = _chills = _netOn = _sprayOn = false;
      _temp = 37;
      _bhadrak = _reduced = false;
      _built = 0;
      _builtZones.clear();
      _usage = 10;
      _admin.clear();
      _adminDone = _dialDone = false;
      _dialWrong = null;
      _maskOn = _sanitized = _distanceDone = false;
      _distance = 0.5;
      _packed.clear();
      _logic.clear();
      _logicDone = false;
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

  void _flashZone(String zone) {
    setState(() => _wrongZone = zone);
    _after(600, () => setState(() => _wrongZone = null));
  }

  // ------------------------------------------------------------ 3D drags ---
  /// True if [id] may be picked up in the current step.
  bool _grabbable(String id) {
    if (_busy || _scenarioDone) return false;
    return switch ((_scenario, _step, id)) {
      (1, 2, 'virus') => !_virusIn,
      (2, 2, 'mosquito') => !_bitten,
      (2, 4, 'net') => !_netOn,
      (2, 4, 'spray') => !_sprayOn,
      (3, 2, 'bricks') => _bhadrak && _built < _zones.length,
      (4, 4, 'mask') => !_maskOn,
      (5, 2, _) => _items.containsKey(id) && !_packed.contains(id),
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
    'mosquito' => _rt_V3(-0.6, 0, 0),
    'net' => _rt_V3(0, 0.4, 0),
    'spray' => _rt_V3(0, 1.5, 0),
    'bricks' => _rt_V3(0, 0.5, 0),
    'virus' || 'mask' => _rt_V3(),
    _ => _rt_V3(0, 0.6, 0),
  };

  _rt_V3 _handleWorld(String id) =>
      _objects[id]!.localTransform.apply(_handleLocal(id));

  _rt_V3 _personCentre(_Person? p) {
    final n = p!.node.position;
    return _rt_V3(n.x, -0.9, n.z);
  }

  /// Every place [id] can be released over (judged on release, so a wrong
  /// one can explain itself), measured from the handle with tight windows.
  List<(String, _DropWindow)> _targets(String id) => switch ((_scenario, id)) {
    (1, 'virus') => [
      ('lungs', _DropWindow(_rt_V3(-4.5, 0.6, -0.85), 2.4, 2.2, 2.0)),
    ],
    (2, 'mosquito') => [
      ('infected', _DropWindow(_personCentre(_sick), 1.7, 2.7, 3.2)),
      ('healthy', _DropWindow(_personCentre(_healthy), 1.7, 2.7, 3.2)),
    ],
    (2, 'net') => [
      ('bed', _DropWindow(_rt_V3(-0.6, -2.0, 1.2), 3.0, 1.5, 2.4)),
    ],
    (2, 'spray') => [
      ('person', _DropWindow(_personCentre(_healthy), 1.7, 2.7, 3.2)),
    ],
    (3, 'bricks') => [
      for (var i = 0; i < _zones.length; i++)
        if (!_builtZones.contains(i))
          (
            'zone$i',
            _DropWindow(
              _rt_V3(_zones[i].$1, _groundDragY, _zones[i].$2),
              1.6,
              1,
              1,
            ),
          ),
    ],
    (4, 'mask') => [
      ('face', _DropWindow(_rt_V3(_youX, 0.45, 1.0), 1.1, 1.1, 1.1)),
    ],
    (5, _) => [('case', _DropWindow(_rt_V3(0, -2.4, 0), 2.7, 1.4, 2.6))],
    _ => const [],
  };

  /// The targets shown as rings for [id]: only the right one(s).
  Iterable<String> _ringTargets(String id) => switch ((_scenario, id)) {
    (1, _) => const ['lungs'],
    (2, 'mosquito') => [_carrying ? 'healthy' : 'infected'],
    (2, 'net') => const ['bed'],
    (2, 'spray') => const ['person'],
    (3, _) => [for (final (t, _) in _targets(id)) t],
    (4, _) => const ['face'],
    (5, _) => const ['case'],
    _ => const [],
  };

  /// Lowest the handle may go (no dragging through the floor).
  double _floorY(String id) => switch (_scenario) {
    1 => -2.6,
    _ => -3.0,
  };

  bool _onPointerDown(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['drag'] != null);
    if (hit == null) return false;
    final id = hit.userData['drag'] as String;
    if (!_grabbable(id)) return false;
    final targets = _targets(id);
    final handle = e.frame.project(_handleWorld(id));
    if (targets.isEmpty || handle == null) return false;
    if (id == 'bricks') {
      // The bricks slide over the ground (the source dragged them on a
      // camera-facing plane and judged only x/y, so back-row zones failed).
      _planePoint = _rt_V3(0, _groundDragY, 0);
      _planeNormal = _rt_V3(0, 1, 0);
    } else {
      final fwd = e.frame.fwd;
      final normal = _rt_V3(fwd.x, 0, fwd.z);
      if (normal.lengthSq < 1e-6) {
        normal.set(0, 0, 1);
      } else {
        normal.normalize();
      }
      _planePoint = targets.first.$2.centre;
      _planeNormal = normal;
    }
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
    if (id == 'bricks') {
      p
        ..x = p.x.clamp(-6.0, 11.0)
        ..z = p.z.clamp(-6.0, 5.0);
    } else {
      p.y = math.max(p.y, _floorY(id));
    }
    node.position.copy(p - (_handleWorld(id) - node.position));
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final id = _dragId;
    if (id == null) return;
    setState(() => _dragId = null);
    // A tap (no real move) never counts as a drop - except the mask, which
    // can also be put on by tapping it.
    if (_dragTravel < 12) {
      _snapBack(id);
      if (id == 'mask') _after(380, _applyMask);
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
    String? hit;
    var best = double.infinity;
    if (id == 'bricks') {
      // Nearest zone on the ground (x/z), built or not.
      for (var i = 0; i < _zones.length; i++) {
        final d = math.sqrt(
          math.pow(h.x - _zones[i].$1, 2) + math.pow(h.z - _zones[i].$2, 2),
        );
        if (d < 1.6 && d < best) {
          best = d;
          hit = 'zone$i';
        }
      }
    } else {
      final side = _rt_V3(n.z, 0, -n.x);
      for (final (t, w) in _targets(id)) {
        if (!w.contains(h, side)) continue;
        final d = (h - w.centre).length;
        if (d < best) {
          best = d;
          hit = t;
        }
      }
    }
    switch ((_scenario, id, hit)) {
      case (1, _, 'lungs'):
        _infectLungs();
      case (1, _, _):
        _miss(id, 'fbLungsMiss');
      case (2, 'mosquito', 'infected'):
        if (_carrying) {
          _miss(id, 'fbNowHealthy');
        } else {
          _biteInfected();
        }
      case (2, 'mosquito', 'healthy'):
        if (_carrying) {
          _biteHealthy();
        } else {
          _miss(id, 'fbNotCarrier');
        }
      case (2, 'mosquito', _):
        _miss(id, 'fbBiteMiss');
      case (2, 'net', 'bed'):
        _placeNet();
      case (2, 'net', _):
        _miss(id, 'fbNetMiss');
      case (2, 'spray', 'person'):
        _applySpray();
      case (2, 'spray', _):
        _miss(id, 'fbSprayMiss');
      case (3, _, final String zone):
        final i = int.parse(zone.substring(4));
        if (_builtZones.contains(i)) {
          _miss(id, 'fbZoneMiss');
        } else {
          _build(i);
        }
      case (3, _, _):
        _miss(id, 'fbZoneMiss');
      case (4, _, 'face'):
        _applyMask();
      case (4, _, _):
        _miss(id, 'fbMaskMiss');
      case (5, _, 'case'):
        if (_items[id] == true) {
          _pack(id);
        } else {
          _toastText(
            _tx.s('fbReject').replaceAll('{name}', _tx.s('lbl.$id')),
            good: false,
            ms: 3500,
          );
          _snapBack(id);
        }
      default:
        _miss(id, 'fbCaseMiss');
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
  /// The virus settles in the respiratory tract; the lungs turn red.
  Future<void> _infectLungs() async {
    if (_busy || _virusIn || _scenario != 1 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final virus = _objects['virus']!;
    _showLabel(_labels.firstWhere((l) => l.userData['key'] == 'virus'), false);
    await _tweenNode(virus, _rt_V3(-4.5, 1.2, -0.5), 600, scale: 0.45);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    for (final m in _lungMats) {
      m.color = const Color(0xFFEF4444);
    }
    _virusIn = true;
    _toast('fbVirusIn', ms: 3500);
    _after(1000, _advance);
  }

  void _toggleSymptom(String id) {
    if (_scenario != 1 || _step != 3 || _symptomsOk || _busy) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      if (!_symptoms.remove(id)) _symptoms.add(id);
    });
  }

  void _diagnose() {
    if (_scenario != 1 || _step != 3 || _symptomsOk || _busy) return;
    final ok =
        _symptoms.length == _coldSymptoms.length &&
        _symptoms.containsAll(_coldSymptoms);
    if (!ok) {
      _toast('fbSymWrong', good: false, ms: 3500);
      return;
    }
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _symptomsOk = true;
      _busy = true;
    });
    _after(700, () {
      _advance();
      _hint('fbWashSoap');
    });
  }

  /// Hand washing: bubbles rise from the soap (2 s for the 20 s wash).
  Future<void> _washHands() async {
    if (_busy || _handsWashed || _scenario != 1 || _step != 4) return;
    final run = _run;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);
    _shell.showToast(
      _tx.s('fbWashing'),
      color: _rt_Tw.sky500,
      icon: Icons.water_drop,
      ms: 2000,
    );
    _soapMat?.color = const Color(0xFF2563EB);
    _showLabel(_soapLabel, false);
    final soap = _soap!;
    final bubbles = [
      for (var i = 0; i < 15; i++)
        (
          _ball(0.1 + _rng.nextDouble() * 0.15, Colors.white, opacity: 0.85)
            ..position.copy(soap.position + _rt_V3(0, 0.3, 0)),
          _rt_V3(
            (_rng.nextDouble() - 0.5) * 1.6,
            1.5 + _rng.nextDouble() * 1.5,
            (_rng.nextDouble() - 0.5) * 0.8,
          ),
          _rng.nextDouble() * 0.3,
        ),
    ];
    for (final (b, _, _) in bubbles) {
      _root.add(b);
    }
    final start = soap.position + _rt_V3(0, 0.3, 0);
    await _tweens.run(2000, (t) {
      for (final (b, rise, delay) in bubbles) {
        final k = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
        final e = 1 - (1 - k) * (1 - k);
        b
          ..position.copy(start + rise * e)
          ..scale.set(1 - k, 1 - k, 1 - k);
      }
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    for (final (b, _, _) in bubbles) {
      b.removeFromParent();
    }
    setState(() {
      _handsWashed = true;
      _busy = false;
    });
    _toast('fbWashed', ms: 3500);
  }

  void _toggleSharing() {
    if (_scenario != 1 || _step != 4 || _sharingOff || _busy) return;
    if (!_handsWashed) {
      _toast('fbWashSoap', good: false);
      return;
    }
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _sharingOff = true;
      _busy = true;
    });
    _after(1000, _completeScenario);
  }

  // ------------------------------------------------- scenario 2 actions ---
  /// Where the mosquito lands to bite [p] (on the arm facing the room).
  _rt_V3 _bitePoint(_Person p, double side) {
    final n = p.node.position;
    return _rt_V3(n.x + 1.1 * side, -0.9, n.z + 0.5);
  }

  /// The mosquito bites the person with malaria and picks up the parasite
  /// (content fix: the source dragged the protozoa straight into it).
  Future<void> _biteInfected() async {
    if (_busy || _carrying || _scenario != 2 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final m = _objects['mosquito']!;
    await _tweenNode(
      m,
      _bitePoint(_sick!, -1),
      600,
      rot: _rt_V3(0, math.pi, -0.3),
    );
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    await _tweens.wait(500);
    if (!_alive(run)) return;
    _mosquitoMat?.color = const Color(0xFFD946EF);
    _toast('fbPickedUp', ms: 3500);
    await _tweenNode(
      m,
      m.userData['home'] as _rt_V3,
      600,
      rot: m.userData['homeRot'] as _rt_V3,
    );
    if (!_alive(run)) return;
    setState(() {
      _carrying = true;
      _busy = false;
    });
  }

  /// The carrier bites the healthy person, who is now infected.
  Future<void> _biteHealthy() async {
    if (_busy || !_carrying || _bitten || _scenario != 2 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final m = _objects['mosquito']!;
    await _tweenNode(m, _bitePoint(_healthy!, 1), 600, rot: _rt_V3(0, 0, 0.3));
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    await _tweens.wait(500);
    if (!_alive(run)) return;
    _healthy!.skin.color = const Color(0xFFF87171);
    _healthyLabel?.userData['key'] = 'bitten';
    _syncLabels();
    _bitten = true;
    _toast('fbBitten', good: false, ms: 3500);
    await _tweenNode(
      m,
      m.userData['home'] as _rt_V3,
      600,
      rot: m.userData['homeRot'] as _rt_V3,
    );
    if (!_alive(run)) return;
    _after(600, _advance);
  }

  void _setTemp(double v) {
    if (_scenario != 2 || _step != 3 || _chills) return;
    setState(() => _temp = (v * 2).round().clamp(72, 80).toDouble() / 2);
  }

  /// "Induce Chills": the patient shivers (the source button had no effect).
  Future<void> _induceChills() async {
    if (_busy || _chills || _scenario != 2 || _step != 3) return;
    if (_temp <= 38) {
      _toast('fbFeverLow', good: false, ms: 3500);
      return;
    }
    final run = _run;
    setState(() {
      _busy = true;
      _chills = true;
    });
    _rt_playSfx(_rt_Sfx.correct);
    _shell.showToast(
      _tx.s('fbChills'),
      color: _rt_Tw.sky500,
      icon: Icons.ac_unit,
      ms: 3000,
    );
    final p = _healthy!.node;
    final base = p.position.clone();
    final rotY = p.rotation.y;
    await _tweens.run(1600, (t) {
      final shake = math.sin(t * math.pi * 28) * (1 - t * 0.5);
      p
        ..position.x = base.x + 0.06 * shake
        ..rotation.set(0, rotY, 0.03 * shake);
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    p
      ..position.copy(base)
      ..rotation.set(0, rotY, 0);
    _advance();
    _hint('fbProtect');
  }

  /// The net goes up over the bed.
  Future<void> _placeNet() async {
    if (_busy || _netOn || _scenario != 2 || _step != 4) return;
    final run = _run;
    setState(() => _busy = true);
    final net = _objects['net']!;
    await _tweenNode(net, _rt_V3(-0.6, -3.5, 1.2), 500, rot: _rt_V3());
    if (!_alive(run)) return;
    _netBundle?.visible = false;
    final canopy = _netCanopy!
      ..visible = true
      ..scale.set(1, 0.05, 1);
    _rt_playSfx(_rt_Sfx.pop);
    await _tweens.run(500, (t) {
      canopy.scale.set(1, 0.05 + 0.95 * t, 1);
    }, ease: _rt_Ease.outCubic);
    if (!_alive(run)) return;
    _netOn = true;
    _toast('fbNetOn');
    _afterProtection(run);
  }

  /// Repellent sprayed on the person: a mist, then a faint protective
  /// glow. The infected tint stays (content fix: the source's spray
  /// "cured" the person).
  Future<void> _applySpray() async {
    if (_busy || _sprayOn || _scenario != 2 || _step != 4) return;
    final run = _run;
    setState(() => _busy = true);
    final spray = _objects['spray']!;
    final person = _healthy!.node.position;
    await _tweenNode(
      spray,
      _rt_V3(person.x + 1.9, -3.5, person.z + 1.2),
      500,
      rot: _rt_V3(),
    );
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.magic);
    final nozzle = _handleWorld('spray');
    final mist = [
      for (var i = 0; i < 12; i++)
        _ball(0.18, const Color(0xFFD1FAE5), opacity: 0.7)
          ..position.copy(nozzle),
    ];
    for (final b in mist) {
      _root.add(b);
    }
    final aims = [
      for (var i = 0; i < mist.length; i++)
        _rt_V3(
          person.x + (_rng.nextDouble() - 0.5) * 1.2,
          -2.6 + _rng.nextDouble() * 3.6,
          person.z + 0.3,
        ),
    ];
    await _tweens.run(900, (t) {
      for (var i = 0; i < mist.length; i++) {
        mist[i]
          ..position.copy(nozzle.lerp(aims[i], t))
          ..scale.set(1 + t, 1 + t, 1 + t);
      }
    }, ease: _rt_Ease.outQuad);
    if (!_alive(run)) return;
    for (final b in mist) {
      b.removeFromParent();
    }
    spray.visible = false;
    final aura = _mesh(
      _rt_Geometry3D.capsule(1.25, 2.6, segments: 18),
      const Color(0xFF4ADE80),
      opacity: 0.16,
    )..position.set(person.x, -1.1, person.z);
    aura.pickable = false;
    _aura = aura;
    _root.add(aura);
    _sprayOn = true;
    _toast('fbSprayOn');
    _afterProtection(run);
  }

  /// Once the net and the repellent are both in place, the mosquito gives
  /// up and leaves.
  Future<void> _afterProtection(int run) async {
    if (!(_netOn && _sprayOn)) {
      setState(() => _busy = false);
      return;
    }
    final m = _objects['mosquito']!;
    await _tweenNode(m, _rt_V3(10, 6, -6), 1200, scale: 0.3);
    if (!_alive(run)) return;
    m.visible = false;
    _after(400, _completeScenario);
  }

  // ------------------------------------------------- scenario 3 actions ---
  void _selectBhadrak() {
    if (_busy || _bhadrak || _scenario != 3 || _step != 2) return;
    _rt_playSfx(_rt_Sfx.pop);
    _spotMat?.color = const Color(0xFF22C55E);
    _village?.visible = true;
    _objects['bricks']?.visible = true;
    setState(() => _bhadrak = true);
    _toast('fbBhadrak', ms: 3500);
  }

  /// Builds a latrine on zone [i] (the zone the bricks were dropped on).
  Future<void> _build(int i) async {
    if (_busy || !_bhadrak || _builtZones.contains(i)) return;
    if (_scenario != 3 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final bricks = _objects['bricks']!;
    final (zx, zz) = _zones[i];
    await _tweenNode(bricks, _rt_V3(zx, -3.3, zz), 250);
    if (!_alive(run)) return;
    bricks.visible = false;
    _rt_playSfx(_rt_Sfx.pop);
    final hut = _hut(i);
    _root.add(hut);
    _zoneNodes[i].visible = false;
    setState(() {
      _builtZones.add(i);
      _built++;
    });
    await _tweens.run(450, (t) {
      final s = 0.05 + 0.95 * t;
      hut.scale.set(s, s, s);
    }, ease: _rt_Ease.outBack);
    if (!_alive(run)) return;
    _toastText(_tx.s('fbBuilt').replaceAll('{n}', '$_built'), ms: 2500);
    if (_built >= _zones.length) {
      _after(1000, _advance);
      return;
    }
    bricks
      ..position.copy(bricks.userData['home'] as _rt_V3)
      ..visible = true;
    setState(() => _busy = false);
  }

  /// Twin: bricks to the next free zone.
  void _buildNext() {
    for (var i = 0; i < _zones.length; i++) {
      if (!_builtZones.contains(i)) {
        _build(i);
        return;
      }
    }
  }

  void _setUsage(double v) {
    if (_scenario != 3 || _step != 3 || _reduced) return;
    setState(() => _usage = ((v / 10).round() * 10).clamp(10, 90).toDouble());
  }

  void _confirmReduced() {
    if (_scenario != 3 || _step != 3 || _reduced || _usage < 80) return;
    setState(() {
      _reduced = true;
      _busy = true;
    });
    _rt_playSfx(_rt_Sfx.correct);
    _after(800, _completeScenario);
  }

  // ------------------------------------------------- scenario 4 actions ---
  void _toggleAdmin(int i) {
    if (_scenario != 4 || _step != 2 || _adminDone || _busy) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      if (!_admin.remove(i)) _admin.add(i);
    });
  }

  void _executeAdmin() {
    if (_scenario != 4 || _step != 2 || _adminDone || _busy) return;
    if (_admin.contains(2)) {
      _toast('fbIgnore', good: false, ms: 3500);
      return;
    }
    final ok =
        _admin.length == _adminRight.length && _admin.containsAll(_adminRight);
    if (!ok) {
      _toast('fbAdminWrong', good: false, ms: 3500);
      return;
    }
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _adminDone = true;
      _busy = true;
    });
    _after(700, _advance);
  }

  void _chooseDialogue(int i) {
    if (_scenario != 4 || _step != 3 || _dialDone || _busy) return;
    if (i != 0) {
      setState(() => _dialWrong = i);
      _toast('fbDialWrong', good: false, ms: 3500);
      return;
    }
    setState(() {
      _dialDone = true;
      _dialWrong = null;
      _busy = true;
    });
    _toast('fbDialRight', ms: 4500);
    _after(900, _advance);
  }

  /// The mask goes onto your face (by drag, tap or the toolbox).
  Future<void> _applyMask() async {
    if (_busy || _maskOn || _scenario != 4 || _step != 4) return;
    final run = _run;
    setState(() => _busy = true);
    final mask = _objects['mask']!;
    await _tweenNode(mask, _rt_V3(_youX + 0.25, 0.4, 1.4), 450);
    if (!_alive(run)) return;
    mask.visible = false;
    _faceMask?.visible = true;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _maskOn = true;
      _busy = false;
    });
    _toast('fbMaskOn');
  }

  /// Sanitizer (tap the wall dispenser or the toolbox): the dispenser
  /// flashes and you rub your hands. Mask first.
  Future<void> _sanitize() async {
    if (_busy || _sanitized || _scenario != 4 || _step != 4) return;
    if (!_maskOn) {
      _toast('fbMaskFirst', good: false, ms: 3500);
      return;
    }
    final run = _run;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);
    _dispenserMat?.color = const Color(0xFF3B82F6);
    _after(300, () => _dispenserMat?.color = const Color(0xFFF8FAFC));
    final you = _you!;
    final l = you.leftArm, r = you.rightArm;
    final lz = l.rotation.z, rz = r.rotation.z;
    await _tweens.run(400, (t) {
      l.rotation.set(-1.3 * t, 0, lz + (0.75 - lz) * t);
      r.rotation.set(-1.3 * t, 0, rz + (-0.75 - rz) * t);
    });
    if (!_alive(run)) return;
    await _tweens.run(1000, (t) {
      final w = 0.35 * math.sin(t * math.pi * 10);
      l.rotation.y = w;
      r.rotation.y = -w;
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    await _tweens.run(400, (t) {
      l.rotation.set(-1.3 * (1 - t), 0, 0.75 + (lz - 0.75) * t);
      r.rotation.set(-1.3 * (1 - t), 0, -0.75 + (rz + 0.75) * t);
    });
    if (!_alive(run)) return;
    setState(() {
      _sanitized = true;
      _busy = false;
    });
    _toast('fbSanitized');
  }

  void _setDistance(double v) {
    if (_scenario != 4 || _step != 4 || _distanceDone) return;
    if (!_maskOn || !_sanitized) {
      _toast('fbOrder', good: false);
      return;
    }
    setState(
      () => _distance = ((v * 10).round() / 10).clamp(0.5, 2.0).toDouble(),
    );
    _placeClassmate();
    if (_distance > 1.0 + 1e-6) {
      setState(() {
        _distanceDone = true;
        _busy = true;
      });
      _toast('fbDistance');
      _after(1000, _completeScenario);
    }
  }

  // ------------------------------------------------- scenario 5 actions ---
  /// Packs [id] into the next slot of the suitcase (it then stays there).
  Future<void> _pack(String id) async {
    if (_busy || _packed.contains(id) || _scenario != 5 || _step != 2) return;
    final run = _run;
    setState(() {
      _busy = true;
      _packed.add(id);
    });
    final node = _objects[id]!;
    _showLabel(_labels.firstWhere((l) => l.userData['key'] == id), false);
    final slot = _packed.length - 1;
    await _tweenNode(
      node,
      _rt_V3(-1.5 + slot * 1.5, -2.65, 0.2),
      500,
      scale: 0.6,
    );
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _toastText(
      _tx.s('fbPacked').replaceAll('{name}', _tx.s('lbl.$id')),
      ms: 2000,
    );
    if (_packed.length == _items.values.where((v) => v).length) {
      _after(1000, _advance);
      return;
    }
    setState(() => _busy = false);
  }

  /// Twin: the next protective item into the suitcase.
  String? get _nextItem {
    for (final MapEntry(key: id, value: good) in _items.entries) {
      if (good && !_packed.contains(id)) return id;
    }
    return null;
  }

  void _packNext() {
    final id = _nextItem;
    if (id != null) _pack(id);
  }

  void _placeIdea(String chip, String box) {
    if (_scenario != 5 || _step != 3 || _logicDone || _busy) return;
    if (_logic.containsKey(box) || _logic.containsValue(chip)) return;
    setState(() => _selectedChip = null);
    if (_logicZones[box] != chip) {
      _flashZone(box);
      _toast(chip == 'food' ? 'fbFood' : 'fbLogicWrong', good: false, ms: 3500);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _logic[box] = chip);
    if (_logic.length == _logicZones.length) {
      setState(() {
        _logicDone = true;
        _busy = true;
      });
      _shell.showToast(
        _tx.s('fbSibling'),
        color: _rt_Tw.green500,
        icon: Icons.record_voice_over,
        ms: 4000,
      );
      _after(2000, _completeScenario);
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

  /// Sidebar twins of the 3D actions: (key, label, action, done). The
  /// action is null while it is not available (busy, done or not yet).
  List<(String, String, VoidCallback?, bool)> get _twins {
    (String, String, VoidCallback?, bool) twin(
      String key,
      String label,
      bool done,
      VoidCallback fn, {
      bool ready = true,
    }) => (key, label, !done && !_busy && ready ? fn : null, done);
    final next = _nextItem;
    return switch ((_scenario, _step)) {
      (1, 2) => [twin('twin-virus', _tx.s('twVirus'), _virusIn, _infectLungs)],
      (1, 4) => [twin('twin-soap', _tx.s('twSoap'), _handsWashed, _washHands)],
      (2, 2) => [
        twin(
          'twin-bite-infected',
          _tx.s('twBiteInfected'),
          _carrying,
          _biteInfected,
        ),
        twin(
          'twin-bite-human',
          _tx.s('twBiteHuman'),
          _bitten,
          _biteHealthy,
          ready: _carrying,
        ),
      ],
      (2, 4) => [
        twin('twin-net', _tx.s('twNet'), _netOn, _placeNet),
        twin('twin-spray', _tx.s('twSpray'), _sprayOn, _applySpray),
      ],
      (3, 2) => [
        twin('twin-bhadrak', _tx.s('twBhadrak'), _bhadrak, _selectBhadrak),
        twin(
          'twin-build',
          '${_tx.s('twBuild')} ($_built/${_zones.length})',
          _built >= _zones.length,
          _buildNext,
          ready: _bhadrak,
        ),
      ],
      (5, 2) => [
        twin(
          'twin-pack',
          _tx
              .s('twPack')
              .replaceAll('{item}', next == null ? '-' : _tx.s('lbl.$next')),
          next == null,
          _packNext,
        ),
      ],
      _ => const [],
    };
  }

  /// Tap markers for 3D objects that are tapped, not dragged.
  List<(String, _rt_V3)> get _tapSpots {
    if (_busy || _scenarioDone) return const [];
    return switch ((_scenario, _step)) {
      (1, 4) when !_handsWashed && _soap != null => [
        ('tap-soap', _soap!.position + _rt_V3(0, 0.2, 0)),
      ],
      (3, 2) when !_bhadrak && _spot != null => [
        ('tap-bhadrak', _spot!.worldPosition),
      ],
      (4, 4) when _maskOn && !_sanitized && _dispenser != null => [
        ('tap-sanitizer', _dispenser!.position.clone()),
      ],
      _ => const [],
    };
  }

  void _onCanvasTap(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['tap'] != null);
    if (hit == null) return;
    switch ((_scenario, _step, hit.userData['tap'])) {
      case (1, 4, 'soap'):
        _washHands();
      case (3, 2, 'bhadrak'):
        _selectBhadrak();
      case (3, 2, 'map'):
        if (!_bhadrak && !_busy) _toast('fbMapMiss', good: false);
      case (4, 4, 'sanitizer'):
        _sanitize();
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
            final key = l.userData['key'];
            if (key != null) l.text = _tx.s('lbl.$key');
          }
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('appTitle'),
            subtitle: _tx.s('appSubtitle'),
            canvasBackground: _rt_Tw.slate950,
            theme: const _rt_ShellTheme(
              accent: _accent,
              headerGradient: [_rt_Tw.slate900, Color(0xFF312E81)],
              headerSubtitleColor: Color(0xFFC7D2FE),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('appSubtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.coronavirus,
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
        if (_panelMode) Positioned.fill(child: _logicBoard(compact)),
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

  Widget _boardTitle(String key, bool compact) => Text(
    _tx.s(key),
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: compact ? 14 : 19,
      fontWeight: FontWeight.w900,
      color: const Color(0xFFFEF08A),
    ),
  );

  // ------------------------------------------------------- step panels ---
  /// The step's panel, on the left of the 3D view (the source covered the
  /// whole scene with most of them).
  Widget _sidePanel(Size size, bool compact) {
    final Widget content = switch ((_scenario, _step)) {
      (1, 3) => _symptomPanel(compact),
      (1, 4) => _sharePanel(compact),
      (2, 3) => _thermoPanel(compact),
      (3, 3) => _graphPanel(compact),
      (4, 2) => _adminPanel(compact),
      (4, 3) => _dialoguePanel(compact),
      (4, 4) => _toolboxPanel(compact),
      _ => const SizedBox.shrink(),
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
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _panelText(String text, bool compact, {Color? color}) => Padding(
    padding: EdgeInsets.only(bottom: compact ? 6 : 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: compact ? 11.5 : 13,
        fontWeight: FontWeight.w700,
        color: color ?? Colors.white,
        height: 1.3,
      ),
    ),
  );

  Widget _gap(bool compact) => SizedBox(height: compact ? 4 : 6);

  Widget _symptomPanel(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('symTitle')),
        _panelText(_tx.s('symDesc'), compact),
        for (final id in _symptomIds) ...[
          _rt_ChoiceButton(
            key: ValueKey('sym-$id'),
            label: _tx.s('sym.$id'),
            state: _symptomsOk && _coldSymptoms.contains(id)
                ? _rt_ChoiceState.correct
                : (_symptoms.contains(id)
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle),
            onTap: _symptomsOk ? null : () => _toggleSymptom(id),
          ),
          _gap(compact),
        ],
        const SizedBox(height: 4),
        _rt_ActionButton(
          key: const ValueKey('btn-diagnose'),
          label: _tx.s('diagnose'),
          icon: Icons.medical_information,
          color: _accent,
          expand: true,
          done: _symptomsOk,
          onPressed: _symptomsOk || _symptoms.isEmpty ? null : _diagnose,
        ),
      ],
    );
  }

  Widget _sharePanel(bool compact) {
    final on = !_sharingOff;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('scenarios.0.steps.3.concept')),
        Row(
          children: [
            Icon(
              _handsWashed ? Icons.check_circle : Icons.wash,
              size: 18,
              color: _handsWashed ? _rt_Tw.green500 : Colors.white70,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _tx.s('twSoap'),
                style: TextStyle(
                  fontSize: compact ? 11.5 : 13,
                  fontWeight: FontWeight.w800,
                  color: _handsWashed ? _rt_Tw.green500 : Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          _tx.s('shareItems'),
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              key: const ValueKey('toggle-share'),
              onTap: _toggleSharing,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 30,
                padding: const EdgeInsets.all(3),
                alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: on ? _rt_Tw.red400 : _rt_Tw.green500,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _tx.s(on ? 'on' : 'off'),
              key: const ValueKey('share-state'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: on ? _rt_Tw.red400 : _rt_Tw.green500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// A slider with -/+ buttons (finger-friendly steps).
  Widget _valueSlider({
    required String key,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required double step,
    required ValueChanged<double>? onChanged,
  }) {
    Widget nudge(String k, IconData icon, double delta) => InkResponse(
      key: ValueKey(k),
      radius: 18,
      onTap: onChanged == null
          ? null
          : () {
              _rt_playSfx(_rt_Sfx.tap);
              onChanged((value + delta).clamp(min, max).toDouble());
            },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(
            color: onChanged == null ? Colors.white24 : _accentSoft,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onChanged == null ? Colors.white30 : Colors.white,
        ),
      ),
    );
    return Row(
      children: [
        nudge('$key-minus', Icons.remove, -step),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accent,
              thumbColor: _accentSoft,
              inactiveTrackColor: Colors.white24,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              key: ValueKey('slider-$key'),
              value: value.clamp(min, max).toDouble(),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        nudge('$key-plus', Icons.add, step),
      ],
    );
  }

  Widget _thermoPanel(bool compact) {
    final fever = _temp > 38;
    final fill = math.max(0.1, (_temp - 36) / 4);
    final tube = compact ? 84.0 : 120.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('temperature')),
        Row(
          children: [
            Container(
              width: 22,
              height: tube,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFF94A3B8), width: 3),
              ),
              child: FractionallySizedBox(
                heightFactor: fill,
                widthFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: _rt_Tw.red500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_temp.toStringAsFixed(1)} °C',
                key: const ValueKey('temp-value'),
                style: TextStyle(
                  fontSize: compact ? 20 : 26,
                  fontWeight: FontWeight.w900,
                  color: fever ? _rt_Tw.red400 : Colors.white,
                ),
              ),
            ),
          ],
        ),
        _gap(compact),
        _valueSlider(
          key: 'temp',
          value: _temp,
          min: 36,
          max: 40,
          divisions: 8,
          step: 0.5,
          onChanged: _chills || _busy ? null : _setTemp,
        ),
        _gap(compact),
        _rt_ActionButton(
          key: const ValueKey('btn-chills'),
          label: _tx.s('chills'),
          icon: Icons.ac_unit,
          color: fever ? _rt_Tw.cyan500 : _rt_Tw.slate500,
          expand: true,
          done: _chills,
          onPressed: _chills || _busy ? null : _induceChills,
        ),
      ],
    );
  }

  Widget _graphPanel(bool compact) {
    final od = 100 - _usage;
    final diarrhoea = math.max(5.0, 100 - 1.2 * _usage);
    final barHeight = compact ? 70.0 : 110.0;
    Widget bar(String key, String labelKey, double pct, Color color) {
      return Expanded(
        child: Column(
          children: [
            Text(
              _tx.s(labelKey),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: compact ? 10 : 11.5,
                fontWeight: FontWeight.w800,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: AnimatedContainer(
                key: ValueKey(key),
                duration: const Duration(milliseconds: 400),
                height: (barHeight - 10) * pct / 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ),
            ),
            Text(
              '${pct.round()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('graphTitle')),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            bar('bar-od', 'graphOd', od, _rt_Tw.blue500),
            const SizedBox(width: 10),
            bar('bar-diarrhoea', 'graphDiar', diarrhoea, _rt_Tw.red500),
          ],
        ),
        _gap(compact),
        Text(
          '${_tx.s('graphSlider')}: ${_usage.round()}%',
          key: const ValueKey('usage-value'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 11.5 : 13,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        _valueSlider(
          key: 'usage',
          value: _usage,
          min: 10,
          max: 90,
          divisions: 8,
          step: 10,
          onChanged: _reduced ? null : _setUsage,
        ),
        _gap(compact),
        _rt_ActionButton(
          key: const ValueKey('btn-reduced'),
          label: _tx.s('graphBtn'),
          icon: Icons.trending_down,
          color: _rt_Tw.green600,
          expand: true,
          done: _reduced,
          onPressed: _reduced || _usage < 80 ? null : _confirmReduced,
        ),
      ],
    );
  }

  Widget _adminPanel(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('adminTitle')),
        _panelText(_tx.s('adminDesc'), compact, color: _accentSoft),
        for (var i = 0; i < 4; i++) ...[
          _rt_ChoiceButton(
            key: ValueKey('admin-$i'),
            label: _tx.s('admin.$i'),
            state: _adminDone && _adminRight.contains(i)
                ? _rt_ChoiceState.correct
                : (_admin.contains(i)
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle),
            onTap: _adminDone ? null : () => _toggleAdmin(i),
          ),
          _gap(compact),
        ],
        const SizedBox(height: 4),
        _rt_ActionButton(
          key: const ValueKey('btn-execute'),
          label: _tx.s('execute'),
          icon: Icons.play_arrow,
          color: _accent,
          expand: true,
          done: _adminDone,
          onPressed: _adminDone || _admin.isEmpty ? null : _executeAdmin,
        ),
      ],
    );
  }

  Widget _dialoguePanel(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('scenarios.3.steps.2.concept')),
        _panelText(_tx.s('dialTitle'), compact),
        for (var i = 0; i < 3; i++) ...[
          _rt_ChoiceButton(
            key: ValueKey('dial-$i'),
            label: _tx.s('dial.$i'),
            state: _dialDone && i == 0
                ? _rt_ChoiceState.correct
                : (_dialWrong == i
                      ? _rt_ChoiceState.wrong
                      : _rt_ChoiceState.idle),
            onTap: _dialDone ? null : () => _chooseDialogue(i),
          ),
          _gap(compact),
        ],
      ],
    );
  }

  Widget _toolboxPanel(bool compact) {
    final ready = _maskOn && _sanitized;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('toolbox')),
        Row(
          children: [
            Expanded(
              child: _rt_ActionButton(
                key: const ValueKey('btn-mask'),
                label: _tx.s('maskBtn'),
                icon: Icons.masks,
                color: _rt_Tw.blue500,
                expand: true,
                done: _maskOn,
                onPressed: _maskOn || _busy ? null : _applyMask,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _rt_ActionButton(
                key: const ValueKey('btn-sanitize'),
                label: _tx.s('sanitizeBtn'),
                icon: Icons.sanitizer,
                color: _rt_Tw.green600,
                expand: true,
                done: _sanitized,
                onPressed: _sanitized || _busy ? null : _sanitize,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: Text(
                _tx.s('distance'),
                style: TextStyle(
                  fontSize: compact ? 12 : 13.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              '${(_distance + 1e-6).toStringAsFixed(1)} m',
              key: const ValueKey('dist-value'),
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w900,
                color: _distanceDone ? _rt_Tw.green500 : _accentSoft,
              ),
            ),
          ],
        ),
        // Locked until the mask and sanitizer are done (the source let it
        // move and repeated an error toast on every step).
        _valueSlider(
          key: 'dist',
          value: _distance,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          step: 0.1,
          onChanged: ready && !_distanceDone ? _setDistance : null,
        ),
        if (!ready)
          Text(
            _tx.s('fbOrder'),
            style: TextStyle(
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------- S5 logic board ---
  /// Fill A, B and C with one idea each (drag or tap-to-place); dragging no
  /// longer lights up the right box, and a wrong drop says why.
  Widget _logicBoard(bool compact) {
    return Container(
      color: const Color(0xF20F172A),
      padding: EdgeInsets.fromLTRB(12, compact ? 6 : 14, 12, compact ? 70 : 88),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            padding: EdgeInsets.all(compact ? 8 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2F4F2F),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF8B5A2B),
                width: compact ? 6 : 10,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _boardTitle('logicTitle', compact),
                  Text(
                    _tx.s('logicIntro'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 10.5 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: compact ? 4 : 10),
                  for (final (i, box) in _logicZones.keys.indexed) ...[
                    if (i > 0)
                      Icon(
                        Icons.arrow_downward,
                        size: compact ? 12 : 18,
                        color: Colors.white70,
                      ),
                    _logicBox(box, compact),
                  ],
                  SizedBox(height: compact ? 6 : 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final id in _logicChips)
                          if (!_logic.containsValue(id))
                            _draggableChip(
                              id,
                              'logic.$id',
                              const Color(0xFFFEF08A),
                              compact,
                            ),
                      ],
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

  Widget _logicBox(String box, bool compact) {
    final placed = _logic[box];
    return _dropZone(
      key: 'box-$box',
      zone: box,
      idle: const Color(0xFF166534),
      onDrop: (chip) => _placeIdea(chip, box),
      builder: (hover, c) => Container(
        constraints: BoxConstraints(minHeight: compact ? 34 : 46),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: hover ? const Color(0xFFDCFCE7) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 24 : 30,
              height: compact ? 24 : 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF166534),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                box,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: placed == null
                  ? Text(
                      _tx.s('zone.$box'),
                      style: TextStyle(
                        fontSize: compact ? 11 : 12.5,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF94A3B8),
                      ),
                    )
                  : Container(
                      key: ValueKey('placed-$box'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Tw.green600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _tx.s('logic.$placed'),
                        style: TextStyle(
                          fontSize: compact ? 11.5 : 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
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
