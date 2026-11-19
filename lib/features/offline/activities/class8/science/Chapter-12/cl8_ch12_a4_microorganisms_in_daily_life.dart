// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 12.4: Microorganisms in Daily Life
// Converted from Cl8S-Ch12-A4-MicroorganismsInDailyLife.html (three.js r128
// + GSAP -> mini3d).
//
// Four investigation steps, each solved by dragging (or tapping) tokens from
// the tray onto numbered slots floating in the 3D scene and pressing VERIFY:
// (1) "Warm the Bowls" - yeast makes dough A rise with CO2 bubbles while
// Lactobacillus sets milk A into curd; (2) "Fast-Forward Time" - fungi and
// bacteria turn the waste in a compost pit into dark manure, Rhizobium
// nodules glow on a legume's roots; (3) "Let Sun Shine" - Spirulina,
// Chlorella and diatoms release oxygen bubbles in a pond; (4) sorting
// processes into the Helpful bin, the Harmful bin and the Prevention jar. A
// correct board advances after 1.5 s; the last one opens "Mission Complete".
//
// SOURCE BUG FIXES:
// * A second VERIFY during the 1.5 s advance queued another `step++` (from
//   step 3 that crashed on `steps[4]`; from step 4 the final popup fired
//   twice). VERIFY is latched while advancing and every pending timer is
//   cancelled on step jumps, restart and dispose.
// * Any accordion card jumped to any step (step 4 could be finished first);
//   steps past the furthest one reached are locked here.
// * Switching language rebuilt the step and wiped placements; here only the
//   text changes.
// * VERIFY ignored the trigger the task asks for; the action is now required
//   first.
// * Placed tokens were locked; tap a filled slot to send it back. An
//   incomplete board now says how many slots are filled instead of "Not
//   quite right".
// * Drops went to the first slot overlapping the dragged token's box (wrong
//   slot when slots are close); here the slot under the finger gets it.
// * The "?" hints were hover-only; tap an empty slot to read its hint.
// * On narrow canvases slots fell off-screen or under the token tray (making
//   a step impossible); the camera now frames every step's slots between
//   the HUD and the tray.
// * The endless GSAP loops (bubbles, nodule glow, fish) were never stopped;
//   they run from the frame clock of the current step only.
// * The labels toggle was switched back on at every step; zoom ignored the
//   lock and had no limit (the scene clipped away past distance 100).
// * Closing the final popup left a finished, dead step 4; the tray offers
//   Replay. Restart keeps the language. The fake "1000 XP / 10/10" metrics
//   are gone.
// * Slot fixes: "Lactic acid" sat over the control milk bowl (now on the
//   curdling bowl A); "Rhizobium" was on the stem and "Traps nitrogen from
//   air" underground (swapped: nodules / air); "Manure" pointed at the top
//   soil instead of the layer that darkens.
// * The risen dough hid its CO2 bubbles; the curd only changed from #fff to
//   #fefce8. Bubbles now rise out of the dough and lumps of curd form. The
//   pond's oxygen bubbles popped two units above the water; they pop at the
//   surface. Nodules are pink, diatoms golden-brown, nodules sit on roots.
// * "Tokens", "STEP n/4", the 3D labels and toasts were English-only.
//   Hindi: "शराब" (liquor) -> "एल्कोहॉल", step 1 "रोगाणु" (germs) ->
//   "सूक्ष्मजीव", the objective's missing "as microalgae", and the step-1
//   task now names the tokens.
//
// CONTENT FIXES (approved by the user):
// * Step 4 asked for salt/sugar preservatives in the HARMFUL bin, though
//   they prevent spoilage. There are now three targets - Helpful bin,
//   Harmful bin and a Prevention pickle jar - and the task says so.
// * A mouldy fruit now stands next to the Harmful bin (the instruction
//   describes one; the source scene had none).
// * Microalgae release "about half" of Earth's oxygen (the source's "more
//   than half" is a contested figure).
// --- TRANSLATION DATA (source `i18n` + `LabData`, en + hi; te ignored).
// Keys marked `// added` have no source string; their Hindi is written to
// match. ---

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
    'appTitle': 'Microorganisms in Daily Life',
    'appSubtitle': 'Class 8. The Invisible Living World: Beyond Our Naked Eye',
    'startMission': 'START MISSION',
    'missionObj': 'Mission Objective',
    'currTask': 'Current Task',
    'verify': 'VERIFY',
    'placed': 'Placed',
    'missionComplete': 'Mission Complete!',
    'whatWeLearnt': 'What we learnt:',
    'replayAct': 'Replay Activity',
    'successTitle': 'Excellent Observation!',
    'successMsg': 'You correctly matched the roles of microorganisms.',
    'errorTitle': 'Not quite right.',
    'errorMsg': "Check your placements. Use the '?' hints for guidance.",
    'finalLearntMsg':
        'Microorganisms are everywhere. Fungi and bacteria decompose waste into manure; Rhizobium fixes nitrogen; yeast and Lactobacillus ferment our food; and microalgae make oxygen. Most are helpful, but some spoil food!',
    'tokens': 'Tokens', // added
    'stepOf': 'STEP {n}/{total}', // added
    'stepsTitle': 'Investigation Steps', // added
    'triggerFirst': "First click '{btn}'.", // added
    'incomplete': 'Fill every slot first: {n}/{total} placed.', // added
    'allPlaced': 'All tokens placed. Press VERIFY.', // added
    'trayHelp':
        'Drag a token up onto a numbered slot, or tap a token and then a slot. Tap a filled slot to take its token back; tap an empty slot to read its hint.', // added
    'missionDoneHud':
        'Mission complete! Replay the activity whenever you like.', // added
    'lockedStep': 'Finish the earlier steps first.', // added
    'ttLabels': 'Toggle labels', // added
    'ttLock': 'Lock / unlock camera', // added
    'howTo': 'How to play', // added
    'objective':
        'See how microorganisms connect to daily life — clean the environment, make our food, enrich the soil, and live in water as microalgae.',
    'lbl': {
      'bowlA': 'Bowl A', // 3D label
      'bowlB': 'Bowl B', // 3D label
      'dough': 'Activity 2.8 Dough Comparison', // 3D label
      'milk': 'Activity 2.9 Milk into Curd', // 3D label
      'compost': 'Compost Pit', // 3D label
      'roots': 'Legume Root Nodules', // 3D label
      'aquatic': 'Aquatic Ecosystem', // 3D label
      'helpful': 'Helpful', // 3D label (source "Bin 1: Helpful")
      'harmful': 'Harmful', // 3D label (source "Bin 2: Harmful")
      'prevention': 'Prevention', // 3D label
      'mouldy': 'Mouldy fruit', // added (content fix)
    },
    'steps': [
      {
        'title': 'Microbes at the Table',
        'task':
            "Click 'Warm the Bowls'. Drag 'Yeast' and 'Carbon dioxide + alcohol' to the dough (left). Drag 'Lactobacillus' and 'Lactic acid' to the milk (right).",
        'instructions': [
          '1. Yeast (a fungus) makes bread/cake dough rise by releasing carbon dioxide and a little alcohol during respiration.',
          '2. Lactobacillus (a bacterium) feeds on lactose in milk, ferments it into curd, and produces lactic acid; it also ferments idli/dosa batter and bhatura dough.',
        ],
        'trigger': 'Warm the Bowls',
        'hints': {
          'p1': 'This fungus respires to make dough fluffy.',
          'p2': 'This bacterium turns milk into curd.',
          'p3': 'Gas bubbles that make bread rise + smell.',
          'p4': 'Acid produced that makes curd sour.',
        },
        'tokens': {
          't1': 'Yeast',
          't2': 'Lactobacillus',
          't3': 'Carbon dioxide + alcohol',
          't4': 'Lactic acid',
        },
      },
      {
        'title': "Nature's Cleaners",
        'task':
            "Click 'Fast-Forward Time'. Drag Fungi, Bacteria & Manure to the compost pit (left). Drag Rhizobium & Nitrogen to the roots (right).",
        'instructions': [
          '3. Fungi and bacteria in soil break down plant waste (peels, dry leaves) and animal waste into manure, returning nutrients to the soil.',
          '4. Rhizobium bacteria in legume root nodules (peas, beans, lentils) trap nitrogen from the air for the plant.',
        ],
        'trigger': 'Fast-Forward Time',
        'hints': {
          'p5': 'Two decomposers breaking down waste (1/2).',
          'p6': 'Two decomposers breaking down waste (2/2).',
          'p7': 'Dark, nutrient-rich end product.',
          'p8': 'Bacteria living in these swollen root nodules.',
          'p9': 'What does the root bacteria take from the atmosphere?',
        },
        'tokens': {
          't5': 'Fungi',
          't6': 'Bacteria',
          't7': 'Manure (returns nutrients)',
          't9': 'Rhizobium',
          't10': 'Traps nitrogen from air',
        },
      },
      {
        'title': 'Tiny Helpers in Water',
        'task':
            "Click 'Let Sun Shine'. Drag microalgae names to the floating organisms, and their benefits to the outcome slots.",
        'instructions': [
          // Content fix: "more than half" is a contested figure.
          "5. Microalgae (Spirulina, Chlorella, Diatoms) make their own food using sunlight, release about half of Earth's oxygen, feed aquatic animals, and are used as health supplements, in water-cleaning, and for biofuel.",
        ],
        'trigger': 'Let Sun Shine',
        'hints': {
          'p10': 'Coiled/spiral microalgae.',
          'p11': 'Spherical green microalgae.',
          'p12': 'Shell-like microalgae.',
          'p13': 'What bubbles up when they use sunlight?',
          'p14': 'Role in the aquatic food chain.',
        },
        'tokens': {
          't11': 'Spirulina',
          't12': 'Chlorella',
          't13': 'Diatoms',
          't14': 'Releases oxygen',
          't15': 'Food for aquatic animals',
        },
      },
      {
        'title': 'Helpful or Harmful?',
        // Content fix: preservatives prevent spoilage, they are not harmful.
        'task':
            "Drag the helpful processes to the 'Helpful' bin (left), fruit spoilage to the 'Harmful' bin, and salt/sugar preservatives to the 'Prevention' jar (right).",
        'instructions': [
          '6. Microorganisms can also be harmful — uncovered fruit can rot and grow a powdery/cotton-like microbial coating; salt/sugar preservatives (as in pickles/murabbas) stop this.',
        ],
        'trigger': null,
        'hints': {
          'p15': 'Bin for beneficial uses.',
          'p16': 'Bin for beneficial uses.',
          'p17': 'Bin for harmful effects.',
          'p18': 'Prevention for the harmful effect.',
        },
        'tokens': {
          't16': 'Nitrogen Fixation',
          't17': 'Making Curd/Bread',
          't18': 'Fruit Spoilage (rot/cotton growth)',
          't19': 'Salt/sugar preservatives',
        },
      },
    ],
  },
  'hi': {
    'appTitle': 'दैनिक जीवन में सूक्ष्मजीव',
    'appSubtitle': 'कक्षा 8. अदृश्य जीवित दुनिया: हमारी नंगी आंखों से परे',
    'startMission': 'मिशन प्रारंभ करें',
    'missionObj': 'मिशन का उद्देश्य',
    'currTask': 'वर्तमान कार्य',
    'verify': 'सत्यापित करें',
    'placed': 'रखा गया',
    'missionComplete': 'मिशन पूरा हुआ!',
    'whatWeLearnt': 'हमने क्या सीखा:',
    'replayAct': 'गतिविधि फिर से चलाएँ',
    'successTitle': 'उत्कृष्ट अवलोकन!',
    'successMsg': 'आपने सूक्ष्मजीवों की भूमिकाओं का सही मिलान किया।',
    'errorTitle': 'बिल्कुल सही नहीं।',
    'errorMsg':
        "अपनी प्लेसमेंट जांचें। मार्गदर्शन के लिए '?' संकेतों का उपयोग करें।",
    'finalLearntMsg':
        'सूक्ष्मजीव हर जगह हैं। कवक और बैक्टीरिया कचरे को खाद में विघटित करते हैं; राइजोबियम नाइट्रोजन को स्थिर करता है; खमीर और लैक्टोबैसिलस हमारे भोजन को किण्वित करते हैं; और सूक्ष्म शैवाल ऑक्सीजन बनाते हैं। अधिकांश सहायक हैं, लेकिन कुछ भोजन खराब करते हैं!',
    'tokens': 'टोकन', // added
    'stepOf': 'चरण {n}/{total}', // added
    'stepsTitle': 'जांच के चरण', // added
    'triggerFirst': "पहले '{btn}' पर क्लिक करें।", // added
    'incomplete': 'पहले हर स्थान भरें: {n}/{total} रखे गए।', // added
    'allPlaced': 'सभी टोकन रख दिए गए। सत्यापित करें दबाएँ।', // added
    'trayHelp':
        'किसी टोकन को ऊपर किसी क्रमांकित स्थान पर खींचें, या पहले टोकन और फिर स्थान पर टैप करें। भरे हुए स्थान पर टैप करने से टोकन वापस आ जाता है; खाली स्थान पर टैप करने से उसका संकेत दिखता है।', // added
    'missionDoneHud':
        'मिशन पूरा हुआ! आप जब चाहें गतिविधि फिर से चला सकते हैं।', // added
    'lockedStep': 'पहले पिछले चरण पूरे करें।', // added
    'ttLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'ttLock': 'कैमरा लॉक / अनलॉक करें', // added
    'howTo': 'कैसे खेलें', // added
    // Completed: the source Hindi dropped "as microalgae".
    'objective':
        'देखें कि सूक्ष्मजीव दैनिक जीवन से कैसे जुड़ते हैं — पर्यावरण को साफ करते हैं, हमारा भोजन बनाते हैं, मिट्टी को समृद्ध करते हैं, और सूक्ष्म शैवाल के रूप में पानी में रहते हैं।',
    'lbl': {
      'bowlA': 'कटोरा A', // added
      'bowlB': 'कटोरा B', // added
      'dough': 'गतिविधि 2.8 आटे की तुलना', // added
      'milk': 'गतिविधि 2.9 दूध से दही', // added
      'compost': 'कम्पोस्ट गड्ढा', // added
      'roots': 'फलीदार पौधे की जड़ की गांठें', // added
      'aquatic': 'जलीय पारितंत्र', // added
      'helpful': 'मददगार', // added
      'harmful': 'हानिकारक', // added
      'prevention': 'रोकथाम', // added
      'mouldy': 'फफूंदी लगा फल', // added
    },
    'steps': [
      {
        // "रोगाणु" means germs/pathogens; these are helpful microbes.
        'title': 'मेज पर सूक्ष्मजीव',
        'task':
            "'कटोरे गरम करें' पर क्लिक करें। 'खमीर' और 'कार्बन डाइऑक्साइड + एल्कोहॉल' को आटे (बाएं) पर खींचें। 'लैक्टोबैसिलस' और 'लैक्टिक एसिड' को दूध (दाएं) पर खींचें।",
        'instructions': [
          '1. खमीर (एक कवक) श्वसन के दौरान कार्बन डाइऑक्साइड और थोड़ा एल्कोहॉल छोड़कर ब्रेड/केक के आटे को फुलाता है।',
          '2. लैक्टोबैसिलस (एक जीवाणु) दूध में लैक्टोज को खाता है, इसे दही में किण्वित करता है, और लैक्टिक एसिड बनाता है; यह इडली/डोसा और भटूरे के आटे को भी किण्वित करता है।',
        ],
        'trigger': 'कटोरे गरम करें',
        'hints': {
          'p1': 'यह कवक आटे को फुलाने के लिए श्वसन करता है।',
          'p2': 'यह जीवाणु दूध को दही में बदल देता है।',
          'p3': 'गैस के बुलबुले जो ब्रेड को फुलाते हैं + गंध।',
          'p4': 'उत्पादित अम्ल जो दही को खट्टा बनाता है।',
        },
        'tokens': {
          't1': 'खमीर (Yeast)',
          't2': 'लैक्टोबैसिलस',
          't3': 'कार्बन डाइऑक्साइड + एल्कोहॉल',
          't4': 'लैक्टिक एसिड',
        },
      },
      {
        'title': 'प्रकृति के सफाईकर्मी',
        'task':
            "'समय आगे बढ़ाएं' पर क्लिक करें। कवक, बैक्टीरिया और खाद को कम्पोस्ट (बाएं), और राइजोबियम और नाइट्रोजन को जड़ों (दाएं) पर खींचें।",
        'instructions': [
          '3. मिट्टी में कवक और बैक्टीरिया पौधों के कचरे (छिलके, सूखे पत्ते) और पशुओं के कचरे को खाद में तोड़ देते हैं, जिससे मिट्टी में पोषक तत्व वापस आ जाते हैं।',
          '4. फलीदार जड़ों की गांठों में राइजोबियम बैक्टीरिया हवा से नाइट्रोजन को पौधे के लिए फंसाते हैं।',
        ],
        'trigger': 'समय आगे बढ़ाएं',
        'hints': {
          'p5': 'कचरे को तोड़ने वाले दो अपघटक (1/2)।',
          'p6': 'कचरे को तोड़ने वाले दो अपघटक (2/2)।',
          'p7': 'गहरा, पोषक तत्वों से भरपूर अंतिम उत्पाद।',
          'p8': 'इन सूजी हुई जड़ की गांठों में रहने वाले बैक्टीरिया।',
          'p9': 'जड़ बैक्टीरिया वायुमंडल से क्या लेता है?',
        },
        'tokens': {
          't5': 'कवक (Fungi)',
          't6': 'बैक्टीरिया',
          't7': 'खाद (पोषक तत्व लौटाता है)',
          't9': 'राइजोबियम',
          't10': 'हवा से नाइट्रोजन फंसाता है',
        },
      },
      {
        'title': 'पानी में छोटे मददगार',
        'task':
            "'सूरज को चमकने दें' पर क्लिक करें। सूक्ष्म शैवाल के नामों को जीवों पर और उनके लाभों को स्लॉट में खींचें।",
        'instructions': [
          '5. सूक्ष्म शैवाल (स्पिरुलिना, क्लोरेला, डायटम) सूरज की रोशनी का उपयोग करके अपना भोजन बनाते हैं, पृथ्वी की लगभग आधी ऑक्सीजन छोड़ते हैं, जलीय जंतुओं को खिलाते हैं, और स्वास्थ्य पूरक के रूप में, पानी की सफाई में और जैव ईंधन के लिए उपयोग किए जाते हैं।',
        ],
        'trigger': 'सूरज को चमकने दें',
        'hints': {
          'p10': 'कुंडलित/सर्पिल सूक्ष्म शैवाल।',
          'p11': 'गोलाकार हरे सूक्ष्म शैवाल।',
          'p12': 'खोल (shell) जैसे सूक्ष्म शैवाल।',
          'p13':
              'जब वे सूर्य के प्रकाश का उपयोग करते हैं तो क्या बुलबुले उठते हैं?',
          'p14': 'जलीय खाद्य श्रृंखला में भूमिका।',
        },
        'tokens': {
          't11': 'स्पिरुलिना',
          't12': 'क्लोरेला',
          't13': 'डायटम',
          't14': 'ऑक्सीजन छोड़ता है',
          't15': 'जलीय जंतुओं के लिए भोजन',
        },
      },
      {
        'title': 'मददगार या हानिकारक?',
        'task':
            "मददगार प्रक्रियाओं को 'मददगार' डिब्बे (बाएं) में, फल के खराब होने को 'हानिकारक' डिब्बे में, और नमक/चीनी परिरक्षकों को 'रोकथाम' जार (दाएं) में खींचें।",
        'instructions': [
          '6. सूक्ष्मजीव हानिकारक भी हो सकते हैं — बिना ढका फल सड़ सकता है और उस पर चूर्ण/कपास जैसी सूक्ष्मजीव परत उग सकती है; नमक/चीनी परिरक्षक (जैसे अचार/मुरब्बा में) इसे रोकते हैं।',
        ],
        'trigger': null,
        'hints': {
          'p15': 'लाभकारी उपयोग के लिए डिब्बा।',
          'p16': 'लाभकारी उपयोग के लिए डिब्बा।',
          'p17': 'हानिकारक प्रभावों के लिए डिब्बा।',
          'p18': 'हानिकारक प्रभाव के लिए रोकथाम।',
        },
        'tokens': {
          't16': 'नाइट्रोजन स्थिरीकरण',
          't17': 'दही/ब्रेड बनाना',
          't18': 'फल का खराब होना (सड़ना)',
          't19': 'नमक/चीनी परिरक्षक',
        },
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.indigo500;
const Color _accentSoft = Color(0xFFA5B4FC); // indigo-300

/// A numbered drop slot that floats at a 3D point.
///
/// [x], [y], [z] are world coordinates, or an offset from the node named
/// [anchor] when the slot follows a moving object.
class _PinDef {
  const _PinDef(
    this.id,
    this.x,
    this.y,
    this.z,
    this.accept, {
    this.anchor,
    this.bin,
  });

  final String id;
  final double x;
  final double y;
  final double z;
  final List<String> accept;
  final String? anchor;

  /// Unused here (kept so the slot code matches activity 12.1).
  final String? bin;
}

class _TokenDef {
  const _TokenDef(this.id, this.icon, this.color, [this.kind]);

  final String id;
  final IconData icon;
  final Color color;
  final String? kind;
}

class _StepDef {
  const _StepDef(this.pins, this.tokens);

  final List<_PinDef> pins;
  final List<_TokenDef> tokens;
}

const List<String> _decomposers = ['t5', 't6'];
const List<String> _helpful = ['t16', 't17'];

const _stepDefs = <_StepDef>[
  _StepDef(
    [
      _PinDef('p1', -5.5, 2.3, 0, ['t1']),
      _PinDef('p2', 2.0, 2.3, 0, ['t2']),
      _PinDef('p3', -6.9, 0.5, 1.9, ['t3']),
      // Moved onto the curdling bowl A (the source put it over control B).
      _PinDef('p4', 3.1, 0.4, 1.9, ['t4']),
    ],
    [
      _TokenDef('t1', Icons.bakery_dining, _rt_Tw.amber400),
      _TokenDef('t2', Icons.bubble_chart, _rt_Tw.sky400),
      _TokenDef('t3', Icons.cloud, _rt_Tw.slate300),
      _TokenDef('t4', Icons.science, _rt_Tw.lime500),
    ],
  ),
  _StepDef(
    [
      _PinDef('p5', -1.5, 1.3, 0.8, _decomposers),
      _PinDef('p6', 0.2, -0.5, 1.2, _decomposers),
      // On the layer that actually darkens into manure.
      _PinDef('p7', -3.0, -1.75, 1.35, ['t7']),
      // Rhizobium on the nodules, nitrogen in the air (source had them
      // swapped: Rhizobium on the stem, "nitrogen from air" underground).
      _PinDef('p8', 4.6, -1.0, 0.9, ['t9']),
      _PinDef('p9', 5.5, 3.6, 0.6, ['t10']),
    ],
    [
      _TokenDef('t5', Icons.grass, _rt_Tw.purple500),
      _TokenDef('t6', Icons.bubble_chart, _rt_Tw.green400),
      _TokenDef('t7', Icons.compost, Color(0xFFA16207)),
      _TokenDef('t9', Icons.scatter_plot, Color(0xFFFDA4AF)),
      _TokenDef('t10', Icons.air, _rt_Tw.sky400),
    ],
  ),
  _StepDef(
    [
      _PinDef('p10', -4.0, 0.9, 1.0, ['t11']),
      _PinDef('p11', 0.0, 0.9, -1.0, ['t12']),
      _PinDef('p12', 3.0, 0.9, 1.5, ['t13']),
      _PinDef('p13', -2.0, 0.7, 2.6, ['t14']),
      _PinDef('p14', 1.0, -1.1, 3.0, ['t15'], anchor: 'fish'),
    ],
    [
      _TokenDef('t11', Icons.all_inclusive, _rt_Tw.green400),
      _TokenDef('t12', Icons.circle, _rt_Tw.emerald400),
      _TokenDef('t13', Icons.hexagon, Color(0xFFEAB308)),
      _TokenDef('t14', Icons.bubble_chart, _rt_Tw.sky400),
      _TokenDef('t15', Icons.set_meal, _rt_Tw.cyan400),
    ],
  ),
  _StepDef(
    [
      _PinDef('p15', -5.6, 0.7, 0.3, _helpful),
      _PinDef('p16', -3.6, 0.7, 0.3, _helpful),
      _PinDef('p17', 0.6, 0.7, 0.3, ['t18']),
      // Content fix: preservatives go to the Prevention jar.
      _PinDef('p18', 6.4, 0.2, 0.3, ['t19']),
    ],
    [
      _TokenDef('t16', Icons.eco, _rt_Tw.green400),
      _TokenDef('t17', Icons.bakery_dining, _rt_Tw.amber400),
      _TokenDef('t18', Icons.warning_amber, _rt_Tw.red400),
      _TokenDef('t19', Icons.kitchen, _rt_Tw.orange400),
    ],
  ),
];

/// A bubble that rises from [base] and fades, looping with [phase].
class _Bubble {
  _Bubble(this.node, this.material, this.base, this.phase, this.rise);

  final _rt_Node3D node;
  final _rt_Material3D material;
  final _rt_V3 base;
  final double phase;
  final double rise;
}

class _ConfettiPiece {
  _ConfettiPiece(math.Random r)
    : angle = (-90 + (r.nextDouble() - 0.5) * 140) * math.pi / 180,
      speed = 420 + r.nextDouble() * 480,
      color = const [
        _rt_Tw.indigo500,
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

class Cl8Ch12A4MicroorganismsInDailyLifePage extends StatefulWidget {
  const Cl8Ch12A4MicroorganismsInDailyLifePage({super.key});

  @override
  State<Cl8Ch12A4MicroorganismsInDailyLifePage> createState() =>
      _Cl8Ch12A4MicroorganismsInDailyLifePageState();
}

class _Cl8Ch12A4MicroorganismsInDailyLifePageState
    extends State<Cl8Ch12A4MicroorganismsInDailyLifePage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF111A33), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 7, 18),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  final math.Random _rng = math.Random(124);
  final _rt_Node3D _root = _rt_Node3D(name: 'step-root');

  /// Ticks once per rendered frame so the floating slots follow the camera.
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);

  final List<_rt_Label3D> _labels = [];
  final Map<String, _rt_Node3D> _anchors = {};
  final List<(_rt_Material3D, double)> _focusMats = [];

  // Per-step animated parts (rebuilt with the scene).
  final List<_Bubble> _bubbles = [];
  _rt_Node3D? _doughA;
  _rt_Material3D? _doughMat;
  _rt_Material3D? _milkMat;
  final List<_rt_Node3D> _curdLumps = [];
  final List<_rt_Node3D> _waste = [];
  final List<(_rt_Material3D, Color)> _wasteMats = [];
  _rt_Material3D? _dirtMat;
  final List<_rt_Material3D> _noduleMats = [];
  _rt_Material3D? _beamMat;
  _rt_Node3D? _fish;

  // --- LAB STATE ---
  int _step = 1;
  int _furthest = 1;
  int? _expanded = 1;
  final Set<int> _completed = {};
  final Map<String, String> _placed = {}; // pin id -> token id
  final Set<String> _flashPins = {};
  String? _selectedToken;
  bool _triggered = false;
  bool _advancing = false;
  bool _missionDone = false;
  bool _labelsOn = true;
  bool _locked = true;
  double _clock = 0;
  double? _confettiStart;
  List<_ConfettiPiece> _confetti = const [];
  final List<Timer> _timers = [];

  _StepDef get _def => _stepDefs[_step - 1];

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
      ..maxDistance = 32;
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.8),
      _rt_Light3D.directional(_rt_V3(5, 10, 5), intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(-5, 5, -5), intensity: 0.25),
    ]);
    _scene.add(_root);
    _goToStep(1, sound: false);
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
  /// Runs [fn] after [ms] unless the step changes first.
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

  // ------------------------------------------------------ scene helpers ---
  _rt_Mesh3D _mesh(
    _rt_Geometry3D g,
    Color color, {
    double opacity = 1,
    double shininess = 0.15,
    bool unlit = false,
    bool doubleSided = false,
    Color? emissive,
  }) {
    return _rt_Mesh3D(
      g,
      _rt_Material3D(
        color: color,
        opacity: opacity,
        shininess: shininess,
        unlit: unlit,
        doubleSided: doubleSided,
        emissive: emissive,
      ),
    );
  }

  _rt_Label3D _label(
    String key,
    double x,
    double y,
    double z, {
    bool large = false,
  }) {
    final label =
        _rt_Label3D(
            _tx.s('lbl.$key'),
            position: _rt_V3(x, y, z),
            pixelHeight: large ? 13.5 : 11,
            color: Colors.white,
            background: const Color(0xD90F172A),
            borderColor: const Color(0x996366F1),
          )
          ..pickable = false
          ..visible = _labelsOn;
    label.userData['key'] = key;
    _labels.add(label);
    return label;
  }

  void _syncLabels() {
    for (final l in _labels) {
      l.text = _tx.s('lbl.${l.userData['key']}');
      l.visible = _labelsOn;
    }
  }

  _rt_Node3D _desk(double y) {
    return _mesh(_rt_Geometry3D.box(20, 0.5, 10), const Color(0xFF1E293B))
      ..position.set(0, y, 0)
      // Large faces sort badly in the painter: keep the desk behind props.
      ..depthBias = 40;
  }

  _rt_Node3D _wall() {
    return _mesh(_rt_Geometry3D.plane(22, 12), const Color(0xFF0F172A))
      ..position.set(0, 3.5, -5)
      ..depthBias = 60;
  }

  /// Registers a material (and its full opacity) that "Focus Slide" sharpens.
  _rt_Material3D _focusMat(Color color, {double opacity = 1}) {
    final m = _rt_Material3D(color: color, opacity: opacity, shininess: 0.35);
    _focusMats.add((m, opacity));
    return m;
  }

  // ---------------------------------------------------------- step scenes ---
  void _buildScene(int step) {
    _root.clear();
    _labels.clear();
    _anchors.clear();
    _focusMats.clear();
    _bubbles.clear();
    _curdLumps.clear();
    _waste.clear();
    _wasteMats.clear();
    _noduleMats.clear();
    _doughA = null;
    _doughMat = null;
    _milkMat = null;
    _dirtMat = null;
    _beamMat = null;
    _fish = null;
    switch (step) {
      case 1:
        _buildKitchen();
      case 2:
        _buildSoil();
      case 3:
        _buildPond();
      default:
        _buildBins();
    }
  }

  _rt_Mesh3D _box(double w, double h, double d, Color color) =>
      _mesh(_rt_Geometry3D.box(w, h, d), color);

  /// A mesh whose colour "Fast-Forward Time" darkens.
  _rt_Mesh3D _wasteMesh(_rt_Geometry3D g, Color color) {
    final m = _rt_Material3D(color: color, shininess: 0.2);
    _wasteMats.add((m, color));
    return _rt_Mesh3D(g, m);
  }

  void _bubble(double x, double y, double z, double r, double rise) {
    final m = _rt_Material3D(
      color: const Color(0xFFE0F2FE),
      opacity: 0,
      shininess: 0.7,
    );
    final node = _rt_Sphere3D(r, m)
      ..position.set(x, y, z)
      ..visible = false
      ..pickable = false;
    _bubbles.add(_Bubble(node, m, _rt_V3(x, y, z), _rng.nextDouble(), rise));
    _root.add(node);
  }

  /// Step 1: dough with/without yeast, milk with/without curd.
  void _buildKitchen() {
    _root
      ..add(
        _box(20, 0.5, 10, const Color(0xFFDEB887))
          ..position.set(0, -2, 0)
          ..depthBias = 40,
      )
      ..add(
        _mesh(_rt_Geometry3D.plane(22, 12), const Color(0xFF475569))
          ..position.set(0, 3, -5)
          ..depthBias = 60,
      );
    final bowl = _rt_Geometry3D.sphere(
      1.8,
      widthSegments: 26,
      heightSegments: 8,
      thetaStart: math.pi / 2,
      thetaLength: math.pi / 2,
    );
    final dome = _rt_Geometry3D.sphere(
      1.7,
      widthSegments: 26,
      heightSegments: 8,
      thetaLength: math.pi / 2,
    );
    for (final (i, x) in [-5.5, -2.0].indexed) {
      _root.add(
        _mesh(bowl, _rt_Tw.blue500, doubleSided: true, shininess: 0.4)
          ..position.set(x, -0.05, 0),
      );
      final mat = _rt_Material3D(color: const Color(0xFFFFFDF0));
      final dough = _rt_Mesh3D(dome, mat)
        ..position.set(x, -0.6, 0)
        ..scale.set(1, 0.2, 1);
      _root.add(dough);
      if (i == 0) {
        _doughA = dough;
        _doughMat = mat;
      }
    }
    for (final (i, x) in [2.0, 5.5].indexed) {
      _root.add(
        _mesh(bowl, const Color(0xFF8B4513), doubleSided: true, shininess: 0.4)
          ..position.set(x, -0.05, 0),
      );
      final mat = _rt_Material3D(color: Colors.white, shininess: 0.6);
      _root.add(
        _rt_Mesh3D(_rt_Geometry3D.circle(1.7, segments: 36), mat)
          ..position.set(x, -0.2, 0)
          ..rotation.x = -math.pi / 2,
      );
      if (i == 0) {
        _milkMat = mat;
        // Lumps of set curd (the source only nudged the colour/roughness).
        for (var k = 0; k < 7; k++) {
          final a = k / 7 * math.pi * 2 + 0.3;
          final r = k == 0 ? 0.0 : 0.6 + 0.45 * (k % 2);
          final lump =
              _mesh(
                  _rt_Geometry3D.sphere(
                    0.34,
                    widthSegments: 12,
                    heightSegments: 6,
                    thetaLength: math.pi / 2,
                  ),
                  const Color(0xFFF5DEB3), // wheat-coloured curd lumps
                )
                ..position.set(x + math.cos(a) * r, -0.2, math.sin(a) * r)
                ..scale.set(0.01, 0.01, 0.01)
                ..visible = false;
          _curdLumps.add(lump);
          _root.add(lump);
        }
      }
    }
    // CO2 bubbles that rise out of the risen dough (the source's bubbles sat
    // inside the dough, invisible).
    for (var k = 0; k < 15; k++) {
      final dx = (_rng.nextDouble() - 0.5) * 2;
      final dz = (_rng.nextDouble() - 0.5) * 2;
      final d = math.sqrt(dx * dx + dz * dz);
      final top =
          -0.6 + 1.87 * math.sqrt(math.max(0, 1 - (d / 1.7) * (d / 1.7)));
      _bubble(-5.5 + dx, top, dz, 0.07 + _rng.nextDouble() * 0.05, 0.9);
    }
    _root
      ..add(_label('bowlA', -5.5, -1.5, 3))
      ..add(_label('bowlB', -2, -1.5, 3))
      ..add(_label('bowlA', 2, -1.5, 3))
      ..add(_label('bowlB', 5.5, -1.5, 3))
      ..add(_label('dough', -3.75, 3.5, -2, large: true))
      ..add(_label('milk', 3.75, 3.5, -2, large: true));
  }

  /// Step 2: a compost pit cross-section and legume root nodules.
  void _buildSoil() {
    _root.add(
      _mesh(_rt_Geometry3D.plane(26, 14), const Color(0xFF0F172A))
        ..position.set(0, 2, -5)
        ..depthBias = 60,
    );
    final pit = _rt_Node3D()..position.set(-3, -2, 0);
    final dirt = _rt_Material3D(color: const Color(0xFF854D0E));
    _dirtMat = dirt;
    pit
      ..add(_box(5.5, 1.5, 2, const Color(0xFF24140B))..position.y = -1.25)
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.box(5.5, 1.5, 2), dirt)..position.y = 0.25,
      )
      ..add(_box(5.5, 1.2, 2, const Color(0xFF5C3A21))..position.y = 1.6)
      ..add(_box(5.7, 0.2, 2.2, const Color(0xFF22C55E))..position.y = 2.3);

    // Kitchen and garden waste lying on the grass.
    void waste(_rt_Node3D n) {
      _waste.add(n);
      pit.add(n);
    }

    for (final x in [-1.8, 0.5]) {
      final apple = _rt_Node3D()..position.set(x, 2.58, x < 0 ? 0.3 : -0.2);
      apple
        ..add(
          _wasteMesh(
            _rt_Geometry3D.sphere(0.18, widthSegments: 12, heightSegments: 8),
            const Color(0xFFEF4444),
          ),
        )
        ..add(
          _wasteMesh(
              _rt_Geometry3D.sphere(0.08, widthSegments: 8, heightSegments: 6),
              const Color(0xFF4ADE80),
            )
            ..position.set(0.05, 0.2, 0)
            ..scale.set(1, 0.4, 0.6),
        );
      waste(apple);
    }
    for (final (x, z, rz) in [(-1.0, 0.6, 0.5), (1.2, 0.4, -0.3)]) {
      final path = [
        for (var i = 0; i <= 8; i++)
          _rt_V3(-0.25 + i / 8 * 0.5, 0.15 * math.sin(i / 8 * math.pi), 0),
      ];
      waste(
        _wasteMesh(
            _rt_Geometry3D.tube(path, 0.06, radialSegments: 6),
            const Color(0xFFFACC15),
          )
          ..position.set(x, 2.45, z)
          ..rotation.z = rz,
      );
    }
    for (final (x, c) in [
      (-2.2, const Color(0xFF4ADE80)),
      (-0.2, const Color(0xFFD97706)),
      (2.0, const Color(0xFF4ADE80)),
    ]) {
      waste(
        _wasteMesh(
            _rt_Geometry3D.sphere(0.2, widthSegments: 10, heightSegments: 6),
            c,
          )
          ..position.set(x, 2.42, -0.3)
          ..scale.set(1, 0.1, 0.4),
      );
    }
    // Mushrooms (fungi) and a magnified bacteria callout.
    for (final (x, z, s) in [(1.5, 0.8, 1.0), (1.9, 0.7, 0.7)]) {
      final m = _rt_Node3D()
        ..position.set(x, 2.4, z)
        ..scale.set(s, s, s);
      m
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(0.04, 0.05, 0.4, segments: 8),
            const Color(0xFFE2E8F0),
          )..position.y = 0.2,
        )
        ..add(
          _mesh(
              _rt_Geometry3D.sphere(
                0.2,
                widthSegments: 12,
                heightSegments: 6,
                thetaLength: math.pi / 2,
              ),
              const Color(0xFF9333EA),
            )
            ..position.y = 0.38
            ..scale.set(1, 0.6, 1),
        );
      pit.add(m);
    }
    final callout = _rt_Node3D()..position.set(3.2, 0.5, 1.05);
    callout
      ..add(
        _mesh(
          _rt_Geometry3D.circle(0.6, segments: 24),
          Colors.white,
          unlit: true,
        ),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.ring(0.6, 0.67, segments: 24),
          const Color(0xFF9CA3AF),
          unlit: true,
        )..position.z = 0.01,
      );
    for (final (i, (x, y)) in [
      (0.0, 0.2),
      (-0.2, -0.1),
      (0.2, -0.2),
      (0.3, 0.2),
    ].indexed) {
      callout.add(
        _mesh(
            _rt_Geometry3D.capsule(0.06, 0.18, segments: 8, capSegments: 3),
            const Color(0xFF22C55E),
          )
          ..position.set(x, y, 0.05)
          ..rotation.z = i * 0.8,
      );
    }
    pit.add(callout);
    _root
      ..add(pit)
      ..add(_label('compost', -3, -4.5, 2));

    // Legume plant with its root system.
    final roots = _rt_Node3D()..position.set(4, -2, 0);
    roots
      ..add(_box(5, 6.5, 0.5, const Color(0xFF3D2314))..position.y = 0.5)
      ..add(
        _box(5.2, 0.3, 0.6, const Color(0xFF22C55E))..position.set(0, 3.6, 0.1),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.1, 0.15, 2, segments: 10),
          const Color(0xFF86EFAC),
        )..position.set(0, 4.7, 0.4),
      );
    for (final dx in [-0.5, 0.5]) {
      roots.add(
        _mesh(
            _rt_Geometry3D.sphere(0.45, widthSegments: 12, heightSegments: 8),
            const Color(0xFF16A34A),
          )
          ..position.set(dx, 5.5, 0.4)
          ..scale.set(1, 0.35, 0.6)
          ..rotation.z = dx * 0.8,
      );
    }
    const rootColor = Color(0xFFDBD7D2);
    roots.add(
      _mesh(_rt_Geometry3D.cylinder(0.18, 0.04, 5.5, segments: 10), rootColor)
        ..position.set(0, 0.9, 0.4),
    );
    // Real nodules are pinkish (the source made them cream).
    _rt_Sphere3D nodule(double x, double y, double s) {
      final m = _rt_Material3D(color: const Color(0xFFFDA4AF), shininess: 0.4);
      _noduleMats.add(m);
      return _rt_Sphere3D(0.15 * s, m)..position.set(x, y, 0.58);
    }

    for (final y in [1.5, 0.5, -0.5]) {
      roots.add(nodule(0, y, 1.3));
    }
    for (final (y, a, len, th) in [
      (2.5, math.pi / 3.5, 2.0, 0.15),
      (2.0, -math.pi / 3, 2.5, 0.15),
      (1.0, math.pi / 4, 1.8, 0.12),
      (0.0, -math.pi / 4, 1.8, 0.12),
      (-1.0, math.pi / 4, 1.5, 0.1),
    ]) {
      final end = _rt_V3(math.sin(a) * len, y - math.cos(a) * len, 0.4);
      roots.add(
        _mesh(
          _rt_Geometry3D.tube(
            [_rt_V3(0, y, 0.4), end],
            th / 2,
            radialSegments: 6,
          ),
          rootColor,
        ),
      );
      // Nodules sit on the branches (the source left some floating).
      for (final t in [0.4, 0.75]) {
        roots.add(
          nodule(math.sin(a) * len * t, y - math.cos(a) * len * t, 1.1),
        );
      }
    }
    _root
      ..add(roots)
      ..add(_label('roots', 4, -4.5, 1));
  }

  /// Step 3: a pond with three microalgae, fish and lily pads.
  void _buildPond() {
    _root.add(
      _mesh(_rt_Geometry3D.plane(30, 16), const Color(0xFF0C1E3A))
        ..position.set(0, 4, -9)
        ..depthBias = 80,
    );
    const earth = Color(0xFF3F2E1C);
    const grass = Color(0xFF4ADE80);
    _root
      ..add(
        _box(20, 4, 6, earth)
          ..position.set(0, -1, -6)
          ..depthBias = 30,
      )
      ..add(
        _box(20, 0.5, 6, grass)
          ..position.set(0, 1.25, -6)
          ..depthBias = 30,
      )
      ..add(_box(4, 4, 8, earth)..position.set(-8, -1, 1))
      ..add(_box(4, 0.5, 8, grass)..position.set(-8, 1.25, 1));
    for (final (x, z) in [
      (-7.5, -4.0),
      (-8.2, -3.0),
      (-6.5, -4.5),
      (-5.0, -5.0),
      (5.0, -4.0),
      (6.0, -5.0),
    ]) {
      _root
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(0.03, 0.04, 2.5, segments: 6),
            const Color(0xFF22C55E),
          )..position.set(x, 2.75, z),
        )
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(0.12, 0.12, 0.6, segments: 8),
            const Color(0xFF78350F),
          )..position.set(x, 3.6, z),
        );
    }
    // Pond (radius 7.5 so it no longer cuts into the banks).
    _root
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(7.5, 7.5, 0.2, segments: 40),
            const Color(0xFF1C1917),
          )
          ..position.set(0, -2.6, 1)
          ..depthBias = 25,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(7.5, 7.5, 2.5, segments: 40),
            const Color(0xFF0369A1),
            opacity: 0.45,
          )
          ..position.set(0, -1.3, 1)
          ..depthBias = 20,
      )
      // The surface is drawn after the organisms so they look submerged.
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(7.5, 7.5, 0.1, segments: 40),
            const Color(0xFF0EA5E9),
            opacity: 0.35,
          )
          ..position.set(0, 0, 1)
          ..depthBias = -6,
      );
    for (final (x, z, s) in [
      (-3.0, -2.0, 1.2),
      (-4.5, -1.0, 0.8),
      (3.0, -2.0, 1.0),
      (4.0, 0.0, 0.7),
    ]) {
      _root.add(
        _mesh(
            _rt_Geometry3D.cylinder(
              0.6,
              0.6,
              0.05,
              segments: 20,
              thetaLength: math.pi * 1.8,
            ),
            const Color(0xFF4ADE80),
          )
          ..position.set(x, 0.08, z)
          ..scale.set(s, 1, s)
          ..depthBias = -10,
      );
    }

    // Fish, swimming once the sun shines.
    final fish = _rt_Node3D(name: 'fish');
    for (final (x, y, z, ry) in [
      (-2.0, -1.5, 2.0, math.pi / 2),
      (1.0, -2.0, 3.0, math.pi / 2.5),
      (4.0, -1.0, 2.0, -math.pi / 4),
    ]) {
      final f = _rt_Node3D()
        ..position.set(x, y, z)
        ..rotation.y = ry;
      f
        ..add(
          _mesh(
            _rt_Geometry3D.cone(0.2, 0.8, segments: 10),
            const Color(0xFF0F766E),
          )..rotation.z = math.pi / 2,
        )
        ..add(
          _mesh(
              _rt_Geometry3D.cone(0.16, 0.3, segments: 8),
              const Color(0xFF0F766E),
            )
            ..position.set(0.5, 0, 0)
            ..rotation.z = -math.pi / 2,
        );
      fish.add(f);
    }
    _root.add(fish);
    _fish = fish;
    _anchors['fish'] = fish;

    // Highlight discs behind the three microalgae groups.
    for (final (x, z) in [(-4.0, 1.0), (0.0, -1.0), (3.0, 1.5)]) {
      _root.add(
        _mesh(
          _rt_Geometry3D.circle(1.5, segments: 28),
          Colors.white,
          opacity: 0.16,
          unlit: true,
        )..position.set(x, -0.5, z - 0.5),
      );
    }
    // Spirulina: green spiral filaments.
    final spirulina = _rt_Node3D()..position.set(-4, -0.5, 1);
    final helix = [
      for (var i = 0; i < 30; i++)
        _rt_V3(
          math.cos(i * 0.9) * 0.3,
          i * 0.06 - 0.9,
          math.sin(i * 0.9) * 0.3,
        ),
    ];
    for (final (x, y, z, s, tilt) in [
      (0.0, 0.0, 0.0, 1.0, 0.0),
      (-0.6, -0.2, 0.4, 0.7, 0.5),
      (0.5, 0.3, -0.3, 0.8, -0.5),
    ]) {
      spirulina.add(
        _mesh(
            _rt_Geometry3D.tube(helix, 0.07, radialSegments: 6),
            const Color(0xFF22C55E),
          )
          ..position.set(x, y, z)
          ..scale.set(s, s, s)
          ..rotation.z = math.pi / 2 + tilt,
      );
    }
    // Chlorella: round green cells with nucleus and chloroplasts.
    final chlorella = _rt_Node3D()..position.set(0, -0.5, -1);
    for (final (x, y, z, s) in [
      (0.0, 0.0, 0.0, 1.0),
      (0.9, 0.5, 0.3, 0.6),
      (-0.8, -0.4, 0.4, 0.7),
    ]) {
      final cell = _rt_Node3D()
        ..position.set(x, y, z)
        ..scale.set(s, s, s);
      cell
        ..add(
          _rt_Sphere3D(
            0.6,
            _rt_Material3D(color: const Color(0xFF4ADE80), opacity: 0.85),
          ),
        )
        ..add(
          _rt_Sphere3D(0.24, _rt_Material3D(color: const Color(0xFF14532D)))
            ..position.set(0.1, 0.1, 0.4),
        );
      for (final (cx, cy) in [(-0.25, -0.2), (0.3, -0.25)]) {
        cell.add(
          _rt_Sphere3D(0.14, _rt_Material3D(color: const Color(0xFF16A34A)))
            ..position.set(cx, cy, 0.42),
        );
      }
      chlorella.add(cell);
    }
    // Diatoms: golden-brown glassy shells (the source drew them mint green).
    final diatoms = _rt_Node3D()..position.set(3, -0.5, 1.5);
    const gold = Color(0xFFCA8A04);
    const shellEdge = Color(0xFF92400E);
    for (final (x, y, z) in [(0.0, 0.0, 0.0), (0.7, 0.4, 0.2)]) {
      final shell = _rt_Geometry3D.sphere(
        0.4,
        widthSegments: 12,
        heightSegments: 8,
      );
      diatoms
        ..add(
          _mesh(shell, gold, opacity: 0.9, shininess: 0.6)
            ..position.set(x, y, z)
            ..scale.set(1, 2, 1)
            ..rotation.z = math.pi / 4,
        )
        ..add(
          _rt_Mesh3D(
              shell,
              _rt_Material3D(color: shellEdge, wireframe: true, opacity: 0.8),
            )
            ..position.set(x, y, z)
            ..scale.set(1.02, 2.04, 1.02)
            ..rotation.z = math.pi / 4,
        );
    }
    diatoms
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.5, 0.5, 0.2, segments: 16),
            gold,
            opacity: 0.9,
          )
          ..position.set(-0.6, -0.3, 0.3)
          ..rotation.x = math.pi / 2,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.torus(
            0.32,
            0.03,
            radialSegments: 4,
            tubularSegments: 20,
          ),
          shellEdge,
        )..position.set(-0.6, -0.3, 0.42),
      );
    _root.addAll([spirulina, chlorella, diatoms]);

    // Sunbeam (fades in with "Let Sun Shine").
    final beam = _rt_Material3D(
      color: const Color(0xFFFEF08A),
      opacity: 0,
      unlit: true,
      doubleSided: true,
    );
    _beamMat = beam;
    _root.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(1.5, 6, 12, segments: 24, openEnded: true),
          beam,
        )
        ..position.set(-2, 5, -2)
        ..rotation.z = math.pi / 8
        ..depthBias = 15
        ..pickable = false,
    );
    // Oxygen bubbles that rise from the algae and pop at the surface (the
    // source's bubbles kept rising two units into the air).
    final sources = [(-4.0, 1.0), (0.0, -1.0), (3.0, 1.5)];
    for (var k = 0; k < 36; k++) {
      final (sx, sz) = sources[k % 3];
      final y = -1 - _rng.nextDouble();
      _bubble(
        sx + (_rng.nextDouble() - 0.5) * 2,
        y,
        sz + (_rng.nextDouble() - 0.5) * 2,
        0.06 + _rng.nextDouble() * 0.06,
        -y - 0.05,
      );
    }
    _root.add(_label('aquatic', 0, -3.5, 4, large: true));
  }

  /// Step 4: Helpful and Harmful bins, a mouldy fruit and a pickle jar.
  void _buildBins() {
    _root
      ..add(
        _box(20, 0.5, 8, const Color(0xFF1E293B))
          ..position.set(0, -3.2, 0)
          ..depthBias = 40,
      )
      ..add(
        _box(16.5, 7.5, 0.4, const Color(0xFF334155))
          ..position.set(0, 1.5, -3.25)
          ..depthBias = 55,
      )
      ..add(
        _box(16, 7, 0.5, const Color(0xFF475569))
          ..position.set(0, 1.5, -3)
          ..depthBias = 50,
      );
    for (final (x, color, key) in [
      (-4.6, _rt_Tw.green500, 'helpful'),
      (0.6, _rt_Tw.red500, 'harmful'),
    ]) {
      final bin = _rt_Node3D()..position.set(x, -2.95, 0);
      bin
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(
              2.0,
              1.6,
              3.0,
              segments: 28,
              openEnded: true,
            ),
            Colors.white,
            opacity: 0.25,
            doubleSided: true,
          )..position.y = 1.5,
        )
        ..add(
          _mesh(
              _rt_Geometry3D.circle(1.6, segments: 28),
              const Color(0xFFE2E8F0),
              opacity: 0.5,
            )
            ..rotation.x = -math.pi / 2
            ..position.y = 0.02,
        )
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(
              2.04,
              1.98,
              0.5,
              segments: 28,
              openEnded: true,
            ),
            color,
            doubleSided: true,
          )..position.y = 2.5,
        )
        ..add(
          _mesh(
              _rt_Geometry3D.torus(
                2.0,
                0.07,
                radialSegments: 6,
                tubularSegments: 40,
              ),
              const Color(0xFFE2E8F0),
            )
            ..rotation.x = math.pi / 2
            ..position.y = 3.0,
        );
      _root
        ..add(bin)
        ..add(_label(key, x, -2.5, 2.6));
    }
    // Content fix: the mouldy fruit the instruction describes.
    final fruit = _rt_Node3D()..position.set(3.2, -2.45, 1.2);
    fruit
      ..add(
        _rt_Sphere3D(
          0.5,
          _rt_Material3D(color: const Color(0xFFF97316), shininess: 0.3),
        ),
      )
      ..add(
        _rt_Sphere3D(0.22, _rt_Material3D(color: const Color(0xFF78350F)))
          ..position.set(0.15, 0.25, 0.4),
      );
    for (var k = 0; k < 9; k++) {
      final a = k * 2.4;
      final ring = 0.25 + 0.12 * (k % 3);
      fruit.add(
        _rt_Sphere3D(
            0.1 + 0.04 * (k % 2),
            _rt_Material3D(color: const Color(0xFFF1F5F9), opacity: 0.95),
          )
          ..position.set(
            math.cos(a) * ring,
            math.sin(a) * ring,
            math.sqrt(math.max(0, 0.25 - ring * ring)) + 0.08,
          ),
      );
    }
    _root
      ..add(fruit)
      ..add(_label('mouldy', 3.2, -1.55, 1.4));
    // Pickle jar = prevention with salt/sugar.
    final jar = _rt_Node3D()..position.set(6.4, -2.95, 0);
    jar
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.0, 1.0, 1.7, segments: 20),
          const Color(0xFF84CC16),
        )..position.y = 0.9,
      )
      ..add(
        _rt_Sphere3D(0.4, _rt_Material3D(color: const Color(0xFFEF4444)))
          ..position.set(0.3, 1.1, 0.75),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.1, 1.1, 2.4, segments: 20),
          Colors.white,
          opacity: 0.35,
          shininess: 0.8,
        )..position.y = 1.2,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.15, 1.15, 0.25, segments: 20),
          const Color(0xFFD97706),
        )..position.y = 2.55,
      );
    _root
      ..add(jar)
      ..add(_label('prevention', 6.4, -2.5, 2.4));
  }

  /// Extra points (besides the slots) that must stay in view per step.
  static final List<List<_rt_V3>> _frameExtras = [
    [
      _rt_V3(-7.4, -1.8, 0), _rt_V3(7.4, -1.8, 0), //
      _rt_V3(-5.5, -1.5, 3), _rt_V3(5.5, -1.5, 3),
      _rt_V3(-6.3, 3.6, -2), _rt_V3(6.3, 3.6, -2), _rt_V3(-5.5, 2.3, 0),
    ],
    [
      _rt_V3(-5.75, -4, 1), _rt_V3(-0.25, 0.7, 1), //
      _rt_V3(-3, -4.6, 2), _rt_V3(1.5, -4.75, 0.4), _rt_V3(6.5, 1.75, 0.4),
      _rt_V3(4, 3.8, 0.4), _rt_V3(4, -4.6, 1),
    ],
    [
      _rt_V3(-7.5, 0, 1), _rt_V3(7.5, 0, 1), _rt_V3(0, -3.5, 4), //
      _rt_V3(-7.5, 4.0, -4), _rt_V3(6, 4.0, -5), _rt_V3(-4, -1.7, 1),
    ],
    [
      _rt_V3(-6.6, -2.95, 0), _rt_V3(-6.6, 0.05, 0), _rt_V3(7.5, -0.25, 0), //
      _rt_V3(3.2, -1.55, 1.4), _rt_V3(-4.6, -2.5, 2.6), _rt_V3(6.4, -2.5, 2.4),
    ],
  ];

  /// Canvas size the camera was last fitted for (per step).
  (int, Size)? _fitKey;

  /// Frames the step's slots and props inside the band between the HUD and
  /// the tray, so on short phone canvases no slot hides behind either (the
  /// source's fixed camera pushed slots off narrow screens or under its
  /// tray). A few projection passes converge on the right distance/offset.
  void _fitCamera(Size size, bool compact) {
    final key = (_step, size);
    if (_fitKey == key || size.isEmpty) return;
    _fitKey = key;
    final points = [
      for (final pin in _def.pins)
        (pin.anchor == null
            ? _rt_V3(pin.x, pin.y, pin.z)
            : _anchors[pin.anchor]!.worldPosition +
                  _rt_V3(pin.x, pin.y, pin.z)),
      ..._frameExtras[_step - 1],
    ];
    const margin = 24.0;
    final top = (compact ? 70.0 : 100.0) + margin;
    final bottom = size.height - (compact ? 62.0 : 108.0) - margin;
    const left = 10.0 + margin;
    final right = size.width - 58.0 - margin;
    if (bottom - top < 40 || right - left < 40) return;
    const elevation = 0.24; // about 14 degrees above the desk
    final back = _rt_V3(0, math.sin(elevation), math.cos(elevation));
    final up = _rt_V3(0, math.cos(elevation), -math.sin(elevation));
    var target = _rt_V3();
    for (final p in points) {
      target.add(p);
    }
    target = target / points.length.toDouble();
    var distance = 16.0;
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
    _camera.saveHome();
  }

  // ------------------------------------------------------------- frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);
    if (_triggered) {
      // Bubbles fade in, rise and pop (dough top / pond surface).
      for (final b in _bubbles) {
        final f = (_clock * 0.55 + b.phase) % 1.0;
        b.node
          ..visible = true
          ..position.set(
            b.base.x + 0.06 * math.sin(_clock * 3 + b.phase * 9),
            b.base.y + f * b.rise,
            b.base.z,
          );
        b.material.opacity = 0.75 * math.sin(f * math.pi);
      }
      if (_step == 2) {
        final glow = 0.5 + 0.5 * math.sin(_clock * 3);
        for (final m in _noduleMats) {
          m.emissive = Color.lerp(
            Colors.black,
            const Color(0xFFFB7185),
            glow * 0.8,
          );
        }
      }
      final fish = _fish;
      if (fish != null) {
        fish.position.x = 0.5 - 0.5 * math.cos(_clock * math.pi / 3);
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
    setState(() => _confetti = List.generate(150, (_) => _ConfettiPiece(_rng)));
    _confettiStart = _clock;
  }

  // --------------------------------------------------------- step flow ---
  void _goToStep(int step, {bool sound = true}) {
    _cancelTimers();
    _tweens.cancelAll();
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _step = step;
      _furthest = math.max(_furthest, step);
      _expanded = step;
      _placed.clear();
      _flashPins.clear();
      _selectedToken = null;
      _triggered = false;
      _advancing = false;
      _missionDone = false;
    });
    _buildScene(step);
    _fitKey = null; // re-framed at the next layout
  }

  void _restart() {
    _confettiStart = null;
    setState(() {
      _completed.clear();
      _furthest = 1;
      _labelsOn = true;
      _locked = true;
      _confetti = const [];
    });
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _goToStep(1, sound: false);
  }

  void _onStepTap(int step) {
    if (step > _furthest) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('lockedStep'),
        color: _rt_Tw.amber500,
        icon: Icons.lock,
      );
      return;
    }
    if (step == _step) {
      _rt_playSfx(_rt_Sfx.tap);
      setState(() => _expanded = _expanded == step ? null : step);
      return;
    }
    _goToStep(step);
  }

  String? get _triggerLabel => _tx.get('steps.${_step - 1}.trigger') as String?;

  /// "Warm the Bowls" / "Fast-Forward Time" / "Let Sun Shine".
  Future<void> _trigger() async {
    if (_triggered || _advancing || _triggerLabel == null) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() => _triggered = true);
    switch (_step) {
      case 1:
        final dough = _doughA;
        final doughMat = _doughMat;
        final milk = _milkMat;
        if (dough == null || doughMat == null || milk == null) return;
        for (final l in _curdLumps) {
          l.visible = true;
        }
        await _tweens.run(2000, (t) {
          dough.scale.y = 0.2 + 0.9 * t;
          doughMat.color = Color.lerp(
            const Color(0xFFFFFDF0),
            const Color(0xFFFCF2C7),
            t,
          )!;
          milk.color = Color.lerp(Colors.white, const Color(0xFFFEF9C3), t)!;
          for (final l in _curdLumps) {
            final s = 0.01 + 0.99 * t;
            l.scale.set(s, s * 0.45, s);
          }
        }, ease: _rt_Ease.outQuad);
      case 2:
        final dirt = _dirtMat;
        await _tweens.run(2500, (t) {
          for (final w in _waste) {
            final s = 1 - 0.9 * t;
            w.scale.set(s, s, s);
          }
          for (final (m, base) in _wasteMats) {
            m.color = Color.lerp(base, const Color(0xFF1A0D00), t)!;
          }
          if (dirt != null) {
            dirt.color = Color.lerp(
              const Color(0xFF854D0E),
              const Color(0xFF2A1405),
              t,
            )!;
          }
        }, ease: _rt_Ease.inOutQuad);
      case 3:
        final beam = _beamMat;
        if (beam == null) return;
        await _tweens.run(1500, (t) => beam.opacity = 0.18 * t);
    }
  }

  // ---------------------------------------------------------- tokens ---
  String _tokenLabel(String id) => _tx.s('steps.${_step - 1}.tokens.$id');

  _TokenDef _token(String id) => _def.tokens.firstWhere((t) => t.id == id);

  bool get _locked2 => _advancing || _missionDone;

  void _selectToken(String id) {
    if (_locked2) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _selectedToken = _selectedToken == id ? null : id);
  }

  void _place(String pinId, String tokenId) {
    if (_locked2) return;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      // A token already on another slot moves; a filled slot swaps back.
      _placed.removeWhere((_, t) => t == tokenId);
      _placed[pinId] = tokenId;
      _selectedToken = null;
      _flashPins.remove(pinId);
    });
  }

  void _tapPin(_PinDef pin) {
    if (_locked2) return;
    final placed = _placed[pin.id];
    if (_selectedToken != null) {
      _place(pin.id, _selectedToken!);
    } else if (placed != null) {
      _rt_playSfx(_rt_Sfx.tap);
      setState(() => _placed.remove(pin.id));
    } else {
      final key = pin.bin ?? pin.id;
      _shell.showToast(
        _tx.s('steps.${_step - 1}.hints.$key'),
        color: _rt_Tw.amber500,
        icon: Icons.help_outline,
        ms: 3500,
      );
    }
  }

  void _toastError(String message) {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(
      message,
      color: _rt_Tw.red500,
      icon: Icons.warning_amber,
      ms: 3500,
    );
  }

  /// Pin ids holding a token they do not accept.
  List<String> _wrongPins() => [
    for (final pin in _def.pins)
      if (_placed[pin.id] case final tokenId?
          when !pin.accept.contains(tokenId))
        pin.id,
  ];

  void _verify() {
    if (_locked2) return;
    final trigger = _triggerLabel;
    if (trigger != null && !_triggered) {
      _toastError(_tx.s('triggerFirst').replaceAll('{btn}', trigger));
      return;
    }
    if (_placed.isEmpty) {
      _toastError('${_tx.s('errorTitle')} ${_tx.s('errorMsg')}');
      return;
    }
    final wrong = _wrongPins();
    if (wrong.isNotEmpty) {
      setState(() {
        for (final id in wrong) {
          _placed.remove(id);
        }
        _flashPins
          ..clear()
          ..addAll(wrong);
      });
      _after(900, () => setState(_flashPins.clear));
      _toastError('${_tx.s('errorTitle')} ${_tx.s('errorMsg')}');
      return;
    }
    final total = _def.pins.length;
    if (_placed.length < total) {
      _toastError(
        _tx
            .s('incomplete')
            .replaceAll('{n}', '${_placed.length}')
            .replaceAll('{total}', '$total'),
      );
      return;
    }
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _advancing = true;
      _completed.add(_step);
      _furthest = math.max(_furthest, math.min(_step + 1, _stepDefs.length));
    });
    _shell.showToast(
      '${_tx.s('successTitle')} ${_tx.s('successMsg')}',
      ms: 3500,
    );
    _after(1500, () {
      if (_step < _stepDefs.length) {
        _goToStep(_step + 1);
      } else {
        _finishMission();
      }
    });
  }

  void _finishMission() {
    setState(() {
      _advancing = false;
      _missionDone = true;
      _completed.add(_step);
    });
    _launchConfetti();
    _shell.showSuccess(
      title: _tx.s('missionComplete'),
      icon: Icons.emoji_events,
      color: _rt_Tw.yellow500,
      buttonLabel: _tx.s('replayAct'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('whatWeLearnt'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: _accentSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tx.s('finalLearntMsg'),
            style: TextStyle(fontSize: 13, color: _rt_Lab.text, height: 1.45),
          ),
        ],
      ),
      onConfirm: _restart,
    );
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labelsOn = !_labelsOn);
    _syncLabels();
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
            l.text = _tx.s('lbl.${l.userData['key']}');
          }
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('appTitle'),
            subtitle: _tx.s('appSubtitle'),
            canvasBackground: _rt_Tw.slate950,
            theme: const _rt_ShellTheme(
              accent: _accent,
              headerGradient: [_rt_Tw.slate900, Color(0xFF312E81)],
              headerSubtitleColor: _rt_Tw.indigo100,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('appSubtitle'),
              buttonLabel: _tx.s('startMission'),
              icon: Icons.biotech,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              _rt_RotatePanToggle(controller: _viewCtrl, accent: _accent),
              const SizedBox(height: 4),
              _toolButton(
                key: const ValueKey('btn-lock'),
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
            // No shell step hint: the HUD already shows the task and the
            // hint would sit on top of the token tray.
            tabs: [
              _rt_ShellTab(
                label: _tx.s('stepsTitle'),
                icon: Icons.biotech,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              cameraControls: !_locked,
              onFrame: _onFrame,
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
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
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

  /// HUD, floating slots, token tray and confetti over the canvas.
  Widget _overlay(Size size) {
    final compact = size.height < 480;
    _fitCamera(size, compact);
    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: _frameTick,
            builder: (context, _, _) => _pinsLayer(size, compact),
          ),
        ),
        Positioned(
          top: 10,
          left: 64,
          right: 64,
          child: Center(child: _hud(compact)),
        ),
        Positioned(left: 10, right: 58, bottom: 8, child: _tray(compact)),
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

  Widget _pinsLayer(Size size, bool compact) {
    if (size.isEmpty) return const SizedBox.shrink();
    final frame = _camera.frame(size);
    final pinSize = compact ? 30.0 : 36.0;
    final children = <Widget>[];
    for (final (i, pin) in _def.pins.indexed) {
      final anchor = pin.anchor == null ? null : _anchors[pin.anchor];
      final world = anchor == null
          ? _rt_V3(pin.x, pin.y, pin.z)
          : anchor.worldPosition + _rt_V3(pin.x, pin.y, pin.z);
      final p = frame.project(world);
      if (p == null ||
          p.dx < 0 ||
          p.dy < 0 ||
          p.dx > size.width ||
          p.dy > size.height) {
        continue;
      }
      children.add(
        Positioned(
          left: p.dx - 55,
          top: p.dy - pinSize / 2,
          width: 110,
          child: _pin(pin, i, pinSize, compact),
        ),
      );
    }
    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _pin(_PinDef pin, int index, double size, bool compact) {
    final tokenId = _placed[pin.id];
    final token = tokenId == null ? null : _token(tokenId);
    final flash = _flashPins.contains(pin.id);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (_) => !_locked2,
          onAcceptWithDetails: (d) => _place(pin.id, d.data),
          builder: (context, candidates, _) {
            final hover = candidates.isNotEmpty;
            final Color fill = flash
                ? _rt_Tw.red600
                : token != null
                ? _rt_Tw.green600
                : hover
                ? _accent
                : const Color(0xE61E1B4B);
            return GestureDetector(
              key: ValueKey('pin-${pin.id}'),
              onTap: () => _tapPin(pin),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: token != null
                            ? const Color(0xFFBBF7D0)
                            : (hover ? Colors.white : _accentSoft),
                        width: hover ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: fill.withValues(alpha: 0.6),
                          blurRadius: hover ? 16 : 8,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: token != null
                        ? Icon(
                            token.icon,
                            size: size * 0.5,
                            color: Colors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: size * 0.42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (token == null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 15,
                        height: 15,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: _rt_Tw.amber400,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: _rt_Tw.slate900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (token != null && !compact)
          IgnorePointer(
            child: Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xE6052E16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _tokenLabel(token.id),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBBF7D0),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// The source's draggable "Current Task" HUD (with the trigger button).
  Widget _hud(bool compact) {
    final trigger = _triggerLabel;
    final text = _missionDone
        ? _tx.s('missionDoneHud')
        : _tx.s('steps.${_step - 1}.task');
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 6 : 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xEB0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withValues(alpha: 0.6), width: 1.4),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_tx.s('currTask').toUpperCase()} · ${_stepOf(_step)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    key: const ValueKey('hud-task'),
                    maxLines: compact ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12.5,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (trigger != null && !_missionDone) ...[
              const SizedBox(width: 8),
              _triggerButton(trigger),
            ],
          ],
        ),
      ),
    );
  }

  Widget _triggerButton(String label) {
    final done = _triggered;
    return Opacity(
      opacity: done ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('btn-trigger'),
          borderRadius: BorderRadius.circular(20),
          onTap: done || _advancing ? null : _trigger,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_rt_Tw.amber500, _rt_Tw.orange500],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: done
                  ? null
                  : [
                      BoxShadow(
                        color: _rt_Tw.amber500.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  done ? Icons.check : Icons.play_arrow,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                // Long (Hindi) labels must not squeeze the task text.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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

  String _stepOf(int n) => _tx
      .s('stepOf')
      .replaceAll('{n}', '$n')
      .replaceAll('{total}', '${_stepDefs.length}');

  /// Token tray with the counter and VERIFY (or Replay after the mission).
  Widget _tray(bool compact) {
    final tray = _def.tokens
        .where((t) => !_placed.containsValue(t.id))
        .toList();
    final chipW = compact ? 128.0 : 140.0;
    final chipH = compact ? 38.0 : 44.0;
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.extension, size: 14, color: _accentSoft),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            _tx.s('tokens').toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: _accentSoft,
            ),
          ),
        ),
      ],
    );
    final count = Text(
      '${_placed.length}/${_def.pins.length} ${_tx.s('placed')}',
      key: const ValueKey('tray-count'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: Colors.white70,
      ),
    );
    final Widget button = _missionDone
        ? _rt_ActionButton(
            key: const ValueKey('btn-replay'),
            label: _tx.s('replayAct'),
            icon: Icons.replay,
            color: _rt_Tw.amber600,
            sound: _rt_Sfx.scenario,
            onPressed: _restart,
          )
        : _rt_ActionButton(
            key: const ValueKey('btn-verify'),
            label: _tx.s('verify'),
            icon: Icons.fact_check,
            color: _rt_Tw.indigo600,
            onPressed: _advancing ? null : _verify,
          );
    final list = SizedBox(
      height: chipH,
      child: tray.isEmpty
          ? Center(
              child: Text(
                _missionDone ? _tx.s('missionDoneHud') : _tx.s('allPlaced'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBBF7D0),
                ),
              ),
            )
          // At most nine tokens: build them all (no lazy list).
          : SingleChildScrollView(
              key: const ValueKey('tray-list'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (i, t) in tray.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _trayToken(t, chipW, chipH),
                  ],
                ],
              ),
            ),
    );
    return Container(
      key: const ValueKey('tray'),
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: const Color(0xEB0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      // Phones get a single row so the scene keeps most of the height.
      child: compact
          ? Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 2), count],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(child: list),
                const SizedBox(width: 6),
                button,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    title,
                    const SizedBox(width: 10),
                    Expanded(child: count),
                    const SizedBox(width: 8),
                    button,
                  ],
                ),
                const SizedBox(height: 7),
                list,
              ],
            ),
    );
  }

  Widget _trayToken(_TokenDef t, double w, double h) {
    final chip = _chip(t, w, h, selected: _selectedToken == t.id);
    return Draggable<String>(
      key: ValueKey('token-${t.id}'),
      data: t.id,
      affinity: Axis.vertical,
      maxSimultaneousDrags: _locked2 ? 0 : 1,
      onDragStarted: () => setState(() => _selectedToken = null),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.08, child: _chip(t, w, h)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: GestureDetector(onTap: () => _selectToken(t.id), child: chip),
    );
  }

  Widget _chip(_TokenDef t, double w, double h, {bool selected = false}) {
    return Container(
      width: w,
      height: h,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF3B2F0B) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? _rt_Tw.amber400 : t.color.withValues(alpha: 0.6),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(t.icon, size: 16, color: t.color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _tokenLabel(t.id).toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObj'),
          desc: _tx.s('objective'),
          accent: _accent,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('stepsTitle'),
                icon: Icons.format_list_numbered,
                color: _accent,
              ),
              for (var i = 1; i <= _stepDefs.length; i++) _stepCard(i),
              const SizedBox(height: 6),
              _rt_InfoCard(
                title: _tx.s('howTo'),
                icon: Icons.touch_app,
                color: _rt_Tw.amber500,
                body: _tx.s('trayHelp'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepCard(int i) {
    final current = i == _step;
    final done = _completed.contains(i);
    final locked = i > _furthest;
    final open = _expanded == i;
    final Widget badge = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done
            ? _rt_Tw.emerald500
            : current
            ? _accent
            : _rt_Lab.overlay,
        shape: BoxShape.circle,
      ),
      child: done
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : locked
          ? Icon(Icons.lock, size: 13, color: _rt_Lab.textMuted)
          : Text(
              '$i',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: current ? Colors.white : _rt_Lab.textMuted,
              ),
            ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: current
            ? _rt_Lab.tinted(_rt_Tw.indigo50, _accent)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('step-$i'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onStepTap(i),
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
                    badge,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_stepOf(i)}: ${_tx.s('steps.${i - 1}.title')}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: locked ? _rt_Lab.textMuted : _rt_Lab.text,
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
                if (open && !locked) ...[
                  const SizedBox(height: 8),
                  for (final line in _tx.list('steps.${i - 1}.instructions'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '$line',
                        style: TextStyle(
                          fontSize: 12,
                          color: _rt_Lab.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  if (current) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _rt_Lab.tintedBorder(_rt_Tw.amber500),
                        ),
                      ),
                      child: Text(
                        _tx.s('steps.${i - 1}.task'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: _rt_Lab.onTinted(
                            _rt_Tw.amber400,
                            _rt_Tw.amber700,
                          ),
                        ),
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

/// One `confetti({particleCount: 150, spread: 70, origin: {y: 0.3}})` burst.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress, this.pieces) : super(repaint: progress);

  final ValueNotifier<double> progress;
  final List<_ConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    final seconds = t * 2.2;
    final origin = Offset(size.width / 2, size.height * 0.3);
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
