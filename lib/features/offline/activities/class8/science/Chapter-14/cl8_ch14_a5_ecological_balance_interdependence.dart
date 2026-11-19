// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 14.5: Ecological Balance and Interdependence
// Converted from Cl8S-Ch14-A5-ecological-balance-and-interdependence.html
// (three.js r128 + tween.js -> mini3d).
//
// Two scenarios picked from the sidebar, each opened by a chalkboard:
// (1) The Indian bullfrog crisis: export frogs from a paddy field, watch
// the pests break out, inspect the damage and spray pesticide; (2) The
// Indian hare food web: a disease crashes the hares, then predict what
// happens to the fox, the eagle and the grass. Every 3D action also has a
// sidebar or panel button, and each finished scenario shows its summary
// with "Next Scenario".
//
// SOURCE BUG FIXES:
// * Re-entering a scenario replayed nothing (it passed instantly) and
//   pending timers and endless tweens ran on (TypeErrors after a reset);
//   scenarios are rebuilt cleanly and every timer and tween is cancelled.
//   Hidden objects stayed clickable and frogs stayed draggable later.
// * A click was a press shorter than 200 ms; the spray counted pointer
//   events instead of where it sprayed (it now kills the pests under its
//   mist), the mist pointed the wrong way and the bottle's label was
//   white on white. Steps advanced by a raw counter; double taps are
//   latched.
// * The scene arrows were sprites lying under the ground and the first
//   click on a trend arrow could already be right; the virus spikes lay
//   flat; labels sank into the ground; the crate overlapped a stalk and
//   frogs sat inside the rows; the grass was the colour of the ground.
// * The crop-health bar never turned green again; the field monitor now
//   shows crop health, pests, frogs and water pollution. The camera is
//   clamped and framed per step for phones; the toolbar's pan leaked into
//   drags. The summary's close left an empty screen; each scenario ends
//   with Next Scenario / Restart, and Restart keeps the language. Labels
//   and toasts were untranslated; the Hindi is complete and uses "गरुड़"
//   for eagle (the source's "चील" means kite).
//
// CONTENT FIXES (approved by the user):
// * S1: the pests lower crop health over time (inspecting only marks the
//   stalks); the pesticide also poisons the frogs left in the field and
//   the fish and pollutes the water; the balance is "seriously disrupted"
//   and recovers slowly (not "permanently"); "drops sharply" (not
//   "critical"); the summary mentions resistance and the 1987 export ban.
// * S2: the eagle named on the board is in the scene (the hare feeds the
//   fox and the eagle); bars start pyramid-shaped (80/50/25/25); explicit
//   Increase / Decrease predictions with feedback (the HUD no longer gives
//   the answer); the fox may switch prey; "Predicted Correctly" (not
//   "Verified"); the disease is labelled and the hare is brown.
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
    'appTitle': 'Ecological Balance and Interdependence',
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
      'export': 'Export crate',
      'inspected': 'Pests found', // was "INSPECTED"
      'spray': 'Pesticide spray',
      'frogsHarmed': 'Frogs poisoned', // added (content fix)
      'fishHarmed': 'Fish killed', // added (content fix)
      'grass': 'Grass',
      'hare': 'Indian hare',
      'fox': 'Fox',
      'eagle': 'Eagle', // added (content fix: the board named it)
      'disease': 'Disease',
      'outbreak': 'Disease outbreak', // was a skull emoji
    },
    // Lab-control twins (added).
    'twExport': 'Export a frog',
    'twInspect': 'Inspect the next stalk',
    'twSpray': 'Spray the next patch',
    'twDisease': 'Infect the hares',
    // Scenario 1 (added).
    'fbDropCrate': 'Drop the frog into the export crate.',
    'fbExported':
        'The frog population has dropped sharply - the pests have lost their natural predator.',
    'fbPests': 'Pests are multiplying and eating the crop!',
    'fbInspected':
        'All three patches are infested, and crop health keeps falling.',
    'fbSprayHint': 'Drag the spray over each damaged patch.',
    'fbSprayMore': 'Some pests are left - spray over every damaged patch.',
    'fbSprayDone':
        'Every pest is dead - but the poison also harmed the frogs and the fish and polluted the water.',
    'monitorTitle': 'Field Monitor',
    'cropHealth': 'Crop health',
    'pests': 'Pests',
    'frogsLeft': 'Frogs in the field',
    'pollution': 'Water pollution',
    // Scenario 2 (added).
    'fbDropHare': 'Drop the disease onto the Indian hare.',
    'fbOutbreak': 'The disease spreads and the hare population crashes.',
    'predTitle': 'There are now far fewer hares. Predict:',
    'pred': {
      'fox': 'Fox population',
      'eagle': 'Eagle population',
      'grass': 'Grass',
    },
    'inc': 'Increase',
    'dec': 'Decrease',
    'check': 'Check',
    'fbPickAll': 'Make a prediction for each population.',
    'fbPredatorWrong':
        'Not quite. What do the fox and the eagle eat - and how much of it is left?',
    'fbPredatorOk':
        'Correct! With fewer hares to eat, the fox and the eagle decrease. The fox may switch to other prey, but food is still scarce.',
    'fbGrassWrong':
        'Not quite. Who eats the grass - and how many of them are left?',
    'fbGrassOk':
        'Correct! With fewer hares grazing, the grass grows more - for a while.',
    'scenarios': [
      {
        'title': 'Scenario 1: The Indian Bullfrog Crisis',
        'objective':
            'Analyze the impact of overhunting Indian bullfrogs in the 1980s.',
        'board':
            "In the 1980s, Indian bullfrogs were caught in huge numbers to export their legs. We will simulate how this disrupted the paddy field's food web and made farmers depend on chemicals.",
        'boardBtn': 'Setup The 1980s Farm',
        'hud': [
          "Step 1: Read the objective, then click 'Setup The 1980s Farm'.",
          'Step 2: Simulate the 1980s export boom: drag at least 7 of the 15 frogs into the export crate.',
          'Step 3: Pests are attacking the crop! Tap the 3 damaged stalks to inspect them.',
          'Step 4: The farmer is desperate. Drag the pesticide spray over each damaged patch until every pest is gone.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Read the board and click 'Setup The 1980s Farm'.",
            'observation':
                'A stable paddy field relies on frogs as natural pest control. Crop health is high.',
          },
          {
            'concept': 'The Export Event',
            'action': 'Drag at least 7 of the 15 frogs into the export crate.',
            // Content fix: "drops sharply" (was "becomes critical").
            'observation':
                'The frog population drops sharply. The natural predator of the crop pests is removed from the ecosystem.',
          },
          {
            'concept': 'The Pest Outbreak',
            'action': 'Inspect the 3 damaged crop stalks.',
            // Content fix: the pests lower crop health over time (the
            // source lowered it with each inspection).
            'observation':
                'Without frogs, the insect pests multiply quickly and eat the crop, so crop health keeps falling.',
          },
          {
            'concept': 'Chemical Consequence',
            'action': 'Drag the pesticide spray over each damaged patch.',
            // Content fix: the harm to other organisms and "seriously
            // disrupted, slow recovery" (was "permanently").
            'observation':
                'The pests die, but the pesticide also poisons the remaining frogs and the fish and pollutes the water. The balance is seriously disrupted and recovers only slowly; farmers come to depend on chemicals.',
          },
        ],
        'summaryTitle': 'Ecological Imbalance Demonstrated',
        'summary':
            'Removing a key predator (the **Indian bullfrog**) let its prey (**insect pests**) multiply and damage the producers (**rice**). The pesticide killed the pests but also poisoned the remaining frogs and the fish and polluted the water - the balance is **seriously disrupted** and recovers only slowly. Pests can also become resistant, so farmers spray more and more. India banned the export of frog legs in 1987.',
      },
      {
        'title': 'Scenario 2: The Indian Hare Food Web',
        'objective':
            "Predict the cascading effects on a food web when a primary consumer's population crashes because of disease.",
        'board':
            'Look at a small food web: Grass -> Indian hare -> Fox and Eagle. If the hare population drops because of a disease, what happens to the others?',
        'boardBtn': 'Setup Food Web Analysis',
        'hud': [
          "Step 1: Read the objective, then click 'Setup Food Web Analysis'.",
          'Step 2: Drag the Disease onto the Indian hare to simulate an outbreak.',
          // Content fix: the source gave the answers ("Down=Decrease").
          'Step 3: Predict how the fox and eagle populations will change, then check.',
          'Step 4: Predict how the grass will change, then check.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Read the board and click 'Setup Food Web Analysis'.",
            // Content fix: the bars are pyramid-shaped (all started at 50%).
            'observation':
                'We are observing a small food web: grass (producer) is eaten by the Indian hare (herbivore), which is eaten by the fox and the eagle (carnivores). There are fewer organisms at each level up.',
          },
          {
            'concept': 'Introduce Disease',
            'action': 'Drag the Disease onto the Indian hare.',
            'observation':
                'The hare population crashes. A key link in the food web is severely weakened.',
          },
          {
            'concept': 'Analyze Predators',
            'action':
                'Choose Increase or Decrease for the fox and the eagle, then check.',
            // Content fix: the fox may switch prey.
            'observation':
                'With less food, the fox and eagle populations decrease: some starve or move away. The fox may switch to other prey, such as mice, but it still finds less food.',
          },
          {
            'concept': 'Analyze Producer',
            'action': 'Choose Increase or Decrease for the grass, then check.',
            'observation':
                'With fewer hares grazing, the grass increases for a while.',
          },
        ],
        'summaryTitle': 'Predicted Correctly', // was "Verified"
        'summary':
            'A crash in a **primary consumer** (the hare) harms the **higher trophic levels** - the fox and the eagle decrease - and helps the **producer** - the grass grows more for a while. Every population in a food web depends on the others.',
      },
    ],
  },
  'hi': {
    'appTitle': 'पारिस्थितिक संतुलन और अन्योन्याश्रय',
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
      'export': 'निर्यात क्रेट',
      'inspected': 'कीट मिले',
      'spray': 'कीटनाशक स्प्रे',
      'frogsHarmed': 'मेंढक विषाक्त',
      'fishHarmed': 'मछलियाँ मरीं',
      'grass': 'घास',
      'hare': 'भारतीय खरगोश',
      'fox': 'लोमड़ी',
      'eagle': 'गरुड़', // the source's "चील" means kite
      'disease': 'बीमारी',
      'outbreak': 'बीमारी का प्रकोप',
    },
    'twExport': 'एक मेंढक निर्यात करें',
    'twInspect': 'अगले डंठल का निरीक्षण करें',
    'twSpray': 'अगले हिस्से पर छिड़काव करें',
    'twDisease': 'खरगोशों को संक्रमित करें',
    'fbDropCrate': 'मेंढक को निर्यात क्रेट में छोड़ें।',
    'fbExported':
        'मेंढकों की संख्या तेज़ी से घट गई है - कीटों का प्राकृतिक शिकारी चला गया है।',
    'fbPests': 'कीट तेज़ी से बढ़ रहे हैं और फसल खा रहे हैं!',
    'fbInspected':
        'तीनों हिस्सों में कीट लगे हैं, और फसल का स्वास्थ्य लगातार गिर रहा है।',
    'fbSprayHint': 'स्प्रे को हर क्षतिग्रस्त हिस्से के ऊपर खींचें।',
    'fbSprayMore': 'कुछ कीट बचे हैं - हर क्षतिग्रस्त हिस्से पर छिड़काव करें।',
    'fbSprayDone':
        'सारे कीट मर गए - लेकिन ज़हर ने मेंढकों और मछलियों को भी नुकसान पहुँचाया और पानी को प्रदूषित कर दिया।',
    'monitorTitle': 'खेत मॉनिटर',
    'cropHealth': 'फसल स्वास्थ्य',
    'pests': 'कीट',
    'frogsLeft': 'खेत में मेंढक',
    'pollution': 'जल प्रदूषण',
    'fbDropHare': 'बीमारी को भारतीय खरगोश पर छोड़ें।',
    'fbOutbreak': 'बीमारी फैलती है और खरगोशों की संख्या तेज़ी से गिर जाती है।',
    'predTitle': 'अब खरगोश बहुत कम हैं। अनुमान लगाएँ:',
    'pred': {
      'fox': 'लोमड़ियों की संख्या',
      'eagle': 'गरुड़ों की संख्या',
      'grass': 'घास',
    },
    'inc': 'वृद्धि',
    'dec': 'कमी',
    'check': 'जाँचें',
    'fbPickAll': 'हर जनसंख्या के लिए अनुमान चुनें।',
    'fbPredatorWrong':
        'पूरी तरह सही नहीं। लोमड़ी और गरुड़ क्या खाते हैं - और उसमें से कितना बचा है?',
    'fbPredatorOk':
        'सही! खाने के लिए कम खरगोश होने से लोमड़ी और गरुड़ घटते हैं। लोमड़ी दूसरे शिकार की ओर जा सकती है, पर भोजन फिर भी कम रहता है।',
    'fbGrassWrong': 'पूरी तरह सही नहीं। घास कौन खाता है - और वे कितने बचे हैं?',
    'fbGrassOk': 'सही! कम खरगोश चरने से घास कुछ समय के लिए ज़्यादा बढ़ती है।',
    'scenarios': [
      {
        'title': 'परिदृश्य 1: भारतीय बुलफ्रॉग संकट',
        'objective':
            '1980 के दशक में भारतीय बुलफ्रॉग के अत्यधिक शिकार के प्रभाव का विश्लेषण करें।',
        'board':
            '1980 के दशक में, भारतीय बुलफ्रॉग को उनकी टाँगों के निर्यात के लिए भारी संख्या में पकड़ा गया। हम अनुकरण करेंगे कि इसने धान के खेत के खाद्य जाल को कैसे बिगाड़ा और किसानों को रसायनों पर निर्भर बना दिया।',
        'boardBtn': '1980 का फार्म सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर '1980 का फार्म सेट करें' पर क्लिक करें।",
          'चरण 2: 1980 के निर्यात उछाल का अनुकरण करें: 15 में से कम से कम 7 मेंढकों को निर्यात क्रेट में खींचें।',
          'चरण 3: कीट फसल पर हमला कर रहे हैं! 3 क्षतिग्रस्त डंठलों का निरीक्षण करने के लिए उन पर टैप करें।',
          'चरण 4: किसान हताश है। कीटनाशक स्प्रे को हर क्षतिग्रस्त हिस्से के ऊपर तब तक खींचें जब तक सारे कीट खत्म न हो जाएँ।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action': "बोर्ड पढ़ें और '1980 का फार्म सेट करें' पर क्लिक करें।",
            'observation':
                'एक स्थिर धान का खेत प्राकृतिक कीट नियंत्रण के लिए मेंढकों पर निर्भर करता है। फसल का स्वास्थ्य अच्छा है।',
          },
          {
            'concept': 'निर्यात घटना',
            'action':
                '15 में से कम से कम 7 मेंढकों को निर्यात क्रेट में खींचें।',
            'observation':
                'मेंढकों की संख्या तेज़ी से घटती है। फसल के कीटों का प्राकृतिक शिकारी पारितंत्र से हट जाता है।',
          },
          {
            'concept': 'कीटों का प्रकोप',
            'action': '3 क्षतिग्रस्त डंठलों का निरीक्षण करें।',
            'observation':
                'मेंढकों के बिना कीट तेज़ी से बढ़ते हैं और फसल खाते हैं, इसलिए फसल का स्वास्थ्य लगातार गिरता है।',
          },
          {
            'concept': 'रासायनिक परिणाम',
            'action': 'कीटनाशक स्प्रे को हर क्षतिग्रस्त हिस्से के ऊपर खींचें।',
            'observation':
                'कीट मर जाते हैं, लेकिन कीटनाशक बचे हुए मेंढकों और मछलियों को भी ज़हर देता है और पानी को प्रदूषित करता है। संतुलन गंभीर रूप से बिगड़ जाता है और धीरे-धीरे ही ठीक होता है; किसान रसायनों पर निर्भर हो जाते हैं।',
          },
        ],
        'summaryTitle': 'पारिस्थितिक असंतुलन प्रदर्शित',
        'summary':
            'एक प्रमुख शिकारी (**भारतीय बुलफ्रॉग**) को हटाने से उसके शिकार (**कीट**) बढ़ गए और उन्होंने उत्पादकों (**धान**) को नुकसान पहुँचाया। कीटनाशक ने कीटों को मारा, लेकिन बचे हुए मेंढकों और मछलियों को भी ज़हर दिया और पानी को प्रदूषित किया - संतुलन **गंभीर रूप से बिगड़ गया** और धीरे-धीरे ही ठीक होता है। कीट प्रतिरोधी भी बन सकते हैं, इसलिए किसान और अधिक छिड़काव करते हैं। भारत ने 1987 में मेंढक की टाँगों के निर्यात पर प्रतिबंध लगा दिया।',
      },
      {
        'title': 'परिदृश्य 2: भारतीय खरगोश खाद्य जाल',
        'objective':
            'यदि बीमारी के कारण किसी प्राथमिक उपभोक्ता की संख्या गिर जाए, तो खाद्य जाल पर पड़ने वाले व्यापक प्रभावों का अनुमान लगाएँ।',
        'board':
            'एक छोटा खाद्य जाल देखें: घास -> भारतीय खरगोश -> लोमड़ी और गरुड़। यदि बीमारी के कारण खरगोशों की संख्या घट जाए, तो दूसरों का क्या होगा?',
        'boardBtn': 'खाद्य जाल विश्लेषण सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'खाद्य जाल विश्लेषण सेट करें' पर क्लिक करें।",
          'चरण 2: प्रकोप का अनुकरण करने के लिए बीमारी को भारतीय खरगोश पर खींचें।',
          'चरण 3: अनुमान लगाएँ कि लोमड़ी और गरुड़ की संख्या कैसे बदलेगी, फिर जाँचें।',
          'चरण 4: अनुमान लगाएँ कि घास कैसे बदलेगी, फिर जाँचें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action':
                "बोर्ड पढ़ें और 'खाद्य जाल विश्लेषण सेट करें' पर क्लिक करें।",
            'observation':
                'हम एक छोटा खाद्य जाल देख रहे हैं: घास (उत्पादक) को भारतीय खरगोश (शाकाहारी) खाता है, जिसे लोमड़ी और गरुड़ (मांसाहारी) खाते हैं। ऊपर के हर स्तर पर जीव कम होते हैं।',
          },
          {
            'concept': 'बीमारी का परिचय',
            'action': 'बीमारी को भारतीय खरगोश पर खींचें।',
            'observation':
                'खरगोशों की संख्या तेज़ी से गिरती है। खाद्य जाल की एक प्रमुख कड़ी बहुत कमज़ोर हो जाती है।',
          },
          {
            'concept': 'शिकारियों का विश्लेषण',
            'action': 'लोमड़ी और गरुड़ के लिए वृद्धि या कमी चुनें, फिर जाँचें।',
            'observation':
                'भोजन कम होने से लोमड़ी और गरुड़ की संख्या घटती है: कुछ भूखे मरते हैं या कहीं और चले जाते हैं। लोमड़ी चूहों जैसे दूसरे शिकार की ओर जा सकती है, पर उसे फिर भी कम भोजन मिलता है।',
          },
          {
            'concept': 'उत्पादक का विश्लेषण',
            'action': 'घास के लिए वृद्धि या कमी चुनें, फिर जाँचें।',
            'observation': 'कम खरगोश चरने से घास कुछ समय के लिए बढ़ती है।',
          },
        ],
        'summaryTitle': 'सही अनुमान लगाया',
        'summary':
            'किसी **प्राथमिक उपभोक्ता** (खरगोश) में गिरावट **ऊँचे पोषी स्तरों** को नुकसान पहुँचाती है - लोमड़ी और गरुड़ घटते हैं - और **उत्पादक** को लाभ देती है - घास कुछ समय के लिए ज़्यादा बढ़ती है। खाद्य जाल की हर जनसंख्या दूसरों पर निर्भर है।',
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.green600;
const Color _accentSoft = Color(0xFF86EFAC); // green-300

/// Steps per scenario (step 1 is always the chalkboard).
const List<int> _stepCounts = [4, 4];

// --- Scenario 1: the paddy field ---
const int _frogCount = 15;
const int _exportGoal = 7;

/// Rice stalks stand in 3 rows of 6 on the mud beds; frogs sit between.
double _stalkX(int c) => -9.0 + 3.6 * c;
double _rowZ(int r) => -4.6 + 4.6 * r;

/// The three infested stalks (row, column), and the stalks the pests
/// spread to as crop health falls (health thresholds alongside).
const List<(int, int)> _patches = [(0, 1), (1, 4), (2, 2)];
const List<(int, int)> _spread = [
  (0, 2),
  (1, 5),
  (2, 1),
  (0, 0),
  (1, 3),
  (2, 3),
];
const List<double> _spreadAt = [86, 80, 74, 68, 62, 56];
const int _bugsPerPatch = 8;

_rt_V3 get _crateCentre => _rt_V3(15, -0.6, 4.6);
_rt_V3 get _sprayHome => _rt_V3(-15, -0.6, 4.6);

/// Heights of the horizontal drag planes (through the handle): a carried
/// frog, and the spray hovering over the crop.
const double _frogLift = 1.0;
const double _sprayLift = 3.2;
const double _sprayRadius = 2.2;

/// Crop health (%): high while the frogs keep the pests down, then
/// falling while the pests feed (content fix: the source lowered it on
/// each inspection).
const double _healthStart = 92;
const double _healthFloor = 30;
const double _healthDrop = 2.2; // per second

// --- Scenario 2: the food web ---
const List<String> _web = ['grass', 'hare', 'fox', 'eagle'];

/// Populations (% of the bar): pyramid-shaped (content fix: the source
/// started every bar half full), and after each change.
const Map<String, double> _popStart = {
  'grass': 80,
  'hare': 50,
  'fox': 25,
  'eagle': 25,
};
const Map<String, double> _popAfter = {
  'grass': 95,
  'hare': 10,
  'fox': 12,
  'eagle': 10,
};

/// Predictions: id -> right answer ('inc' or 'dec').
const Map<String, String> _answers = {
  'fox': 'dec',
  'eagle': 'dec',
  'grass': 'inc',
};

double _nodeX(int i) => -10.5 + 7.0 * i;

/// Where a dragged object's handle must be released, on the vertical drag
/// plane through [centre]: at most [halfWidth] to either side, and between
/// [below] under and [above] over the centre. Horizontal drags only use
/// [centre] and [halfWidth] (as a radius).
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

  bool containsFlat(_rt_V3 h) {
    final dx = h.x - centre.x, dz = h.z - centre.z;
    return dx * dx + dz * dz <= halfWidth * halfWidth;
  }
}

/// One rice stalk: its blade material (recoloured when damaged) and grains.
class _Stalk {
  _Stalk(this.node, this.mat, this.grains);

  final _rt_Node3D node;
  final _rt_Material3D mat;
  final _rt_Node3D grains;
  bool damaged = false;
}

/// One pest insect hovering around infested stalk [patch].
class _Bug {
  _Bug(this.node, this.patch, this.base, this.phase);

  final _rt_Node3D node;
  final int patch;
  final _rt_V3 base;
  final double phase;
  bool alive = true;
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

class Cl8Ch14A5EcologicalBalanceInterdependencePage extends StatefulWidget {
  const Cl8Ch14A5EcologicalBalanceInterdependencePage({super.key});

  @override
  State<Cl8Ch14A5EcologicalBalanceInterdependencePage> createState() =>
      _Cl8Ch14A5EcologicalBalanceInterdependencePageState();
}

class _Cl8Ch14A5EcologicalBalanceInterdependencePageState
    extends State<Cl8Ch14A5EcologicalBalanceInterdependencePage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF0F2A16), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 20, 22),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  math.Random _rng = math.Random(145);
  final _rt_Node3D _root = _rt_Node3D(name: 'scenario-root');
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);
  final List<_rt_Label3D> _labels = [];

  // Scenario objects (rebuilt on every scenario change). Draggable objects
  // are kept by id in [_objects].
  final Map<String, _rt_Node3D> _objects = {};
  final List<_rt_Node3D> _frogs = []; // S1
  final List<_rt_Material3D> _frogMats = [];
  final List<_Stalk> _stalks = [];
  final List<_Bug> _bugs = [];
  final List<_rt_Node3D> _fish = [];
  final List<_rt_Material3D> _fishMats = [];
  final List<_rt_Label3D> _inspectLabels = [];
  _rt_Material3D? _waterMat;
  _rt_Label3D? _crateCount;
  _rt_Label3D? _frogsHarmedLabel;
  _rt_Label3D? _fishHarmedLabel;
  _rt_Mesh3D? _mist;
  final List<_rt_Node3D> _hares = []; // S2
  final Map<String, _rt_Node3D> _bars = {};
  final Map<String, _rt_Label3D> _barLabels = {};
  final Map<String, _rt_Arrow3D> _trends = {};
  _rt_Label3D? _outbreakLabel;

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

  final Set<String> _exportedIds = {}; // S1
  bool _pests = false; // pests feeding (crop health falling)
  double _health = _healthStart;
  int _spreadDone = 0;
  final Set<int> _inspected = {};
  double _pollution = 0;
  bool _sprayed = false; // every pest dead
  bool _poisoned = false;
  bool _infected = false; // S2
  final Map<String, double> _popNow = {};
  final Map<String, String> _predictions = {};
  final Set<String> _predWrong = {};
  bool _predatorsDone = false;
  bool _grassDone = false;
  String? _selectedChip; // used by the shared chip widgets
  String? _wrongZone;

  // 3D drag: frogs and the spray move on a horizontal plane (over the
  // field), the disease on the vertical plane through the hare, facing
  // the camera, so each object stays under the finger.
  String? _dragId;
  _rt_V3? _planePoint;
  _rt_V3? _planeNormal;
  Offset _grabOffset = Offset.zero;
  double _dragTravel = 0;
  Offset? _lastPointer;

  bool get _panelMode => false;

  int get _exported => _exportedIds.length;

  int get _bugsAlive => _bugs.where((b) => b.alive).length;

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
  /// An Indian bullfrog (feet at the origin, facing +x); its skin material
  /// is kept so the poison can discolour it.
  _rt_Node3D _frogModel(_rt_Material3D skin) {
    final n = _rt_Node3D(name: 'frog')
      ..add(
        _rt_Mesh3D(
            _rt_Geometry3D.sphere(0.42, widthSegments: 10, heightSegments: 6),
            skin,
          )
          ..position.y = 0.26
          ..scale.set(1.25, 0.62, 1.0),
      );
    for (final side in const [-1.0, 1.0]) {
      n
        ..add(
          _rt_Mesh3D(
              _rt_Geometry3D.sphere(0.22, widthSegments: 8, heightSegments: 5),
              skin,
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

  /// A rice stalk: thin leaves merged into one mesh (one material to
  /// recolour) and a few yellow grains.
  _Stalk _stalk() {
    final parts = <(_rt_Geometry3D, _rt_Xf)>[];
    const blades = 7;
    for (var k = 0; k < blades; k++) {
      final h = 1.8 + _rng.nextDouble() * 1.0;
      final a = k / blades * 2 * math.pi + _rng.nextDouble() * 0.4;
      final tilt = 0.12 + _rng.nextDouble() * 0.3;
      final lean = _rt_Xf(
        _rt_M3.eulerXYZ(tilt * math.sin(a), 0, -tilt * math.cos(a)),
        _rt_V3(0.1 * math.cos(a), 0, 0.1 * math.sin(a)),
      );
      parts.add((
        _rt_Geometry3D.cone(0.13, h, segments: 3),
        lean * _rt_Xf(_rt_M3.identity(), _rt_V3(0, h / 2, 0)),
      ));
    }
    final mat = _rt_Material3D(color: const Color(0xFF84CC16), shininess: 0.2);
    final grains = _rt_Node3D();
    for (var k = 0; k < 4; k++) {
      final b = k * 1.6 + _rng.nextDouble();
      grains.add(
        _ball(
          0.075,
          const Color(0xFFFEF08A),
        )..position.set(0.28 * math.cos(b), 2.0 + 0.16 * k, 0.28 * math.sin(b)),
      );
    }
    final node = _rt_Node3D(name: 'stalk')
      ..add(_rt_Mesh3D(_rt_Geometry3D.merge(parts), mat))
      ..add(grains);
    return _Stalk(node, mat, grains);
  }

  /// A small paddy fish (facing +x).
  _rt_Node3D _fishModel(_rt_Material3D skin) {
    return _rt_Node3D(name: 'fish')
      ..add(
        _rt_Mesh3D(
          _rt_Geometry3D.sphere(0.3, widthSegments: 10, heightSegments: 6),
          skin,
        )..scale.set(1.6, 0.6, 0.65),
      )
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.cone(0.22, 0.4, segments: 4), skin)
          ..position.x = -0.6
          ..rotation.z = math.pi / 2,
      )
      ..add(
        _ball(0.05, const Color(0xFF111827))..position.set(0.32, 0.06, 0.12),
      );
  }

  /// A pest insect (brown body, dark head, pale wings).
  _rt_Node3D _bugModel() {
    return _rt_Node3D(name: 'bug')
      ..add(_ball(0.16, const Color(0xFFB45309)))
      ..add(_ball(0.1, const Color(0xFF451A03))..position.x = 0.2)
      ..add(
        _ball(0.12, const Color(0xFFE4E4E7), opacity: 0.6)
          ..position.set(-0.04, 0.14, 0),
      );
  }

  /// The export crate (slatted walls, corner posts), base on the ground.
  _rt_Node3D _crateModel() {
    const wood = Color(0xFF8B5A2B), post = Color(0xFF5C3A21);
    final n = _rt_Node3D(name: 'crate')
      ..add(
        _mesh(_rt_Geometry3D.box(3.2, 0.2, 3.2), wood)
          ..position.y = 0.1
          ..depthBias = 6,
      );
    for (final y in const [0.45, 1.0]) {
      for (final s in const [-1.0, 1.0]) {
        n
          ..add(
            _mesh(_rt_Geometry3D.box(3.2, 0.4, 0.12), wood)
              ..position.set(0, y, 1.54 * s),
          )
          ..add(
            _mesh(_rt_Geometry3D.box(0.12, 0.4, 3.0), wood)
              ..position.set(1.54 * s, y, 0),
          );
      }
    }
    for (final x in const [-1.5, 1.5]) {
      for (final z in const [-1.5, 1.5]) {
        n.add(
          _mesh(_rt_Geometry3D.box(0.3, 1.4, 0.3), post)
            ..position.set(x, 0.7, z),
        );
      }
    }
    return n;
  }

  /// The pesticide spray bottle (base at the origin).
  _rt_Node3D _sprayModel() {
    return _rt_Node3D(name: 'spray')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.55, 0.55, 1.9, segments: 14),
          const Color(0xFF16A34A),
          shininess: 0.5,
        )..position.y = 0.95,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.57, 0.57, 0.6, segments: 14),
          const Color(0xFFFEF3C7),
        )..position.y = 1.0,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.18, 0.55, 0.4, segments: 14),
          const Color(0xFFD4D4D8),
          shininess: 0.6,
        )..position.y = 2.1,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.5, 0.35, 0.35), const Color(0xFFEF4444))
          ..position.y = 2.45,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.06, 0.06, 0.5, segments: 6),
            const Color(0xFFD4D4D8),
          )
          ..position.set(0.45, 2.45, 0)
          ..rotation.z = math.pi / 2,
      );
  }

  /// A clump of grass blades (feet at the origin).
  _rt_Node3D _grassModel() {
    final n = _rt_Node3D(name: 'grass');
    for (final (dx, dz) in const [(-0.7, 0.3), (0.6, -0.2), (0.1, 0.8)]) {
      for (var k = 0; k < 6; k++) {
        final a = k / 6 * 2 * math.pi;
        n.add(
          _mesh(
              _rt_Geometry3D.cone(0.16, 1.3, segments: 4),
              k.isEven ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
            )
            ..position.set(dx + 0.3 * math.cos(a), 0.65, dz + 0.3 * math.sin(a))
            ..rotation.set(0.3 * math.sin(a), 0, -0.3 * math.cos(a)),
        );
      }
    }
    return n;
  }

  /// An Indian hare (content fix: brown, not grey; facing +x).
  _rt_Node3D _hareModel() {
    const fur = Color(0xFF8B6B4A), dark = Color(0xFF6B4F35);
    final n = _rt_Node3D(name: 'hare')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.45, widthSegments: 12, heightSegments: 8),
            fur,
          )
          ..position.y = 0.45
          ..scale.set(1.35, 0.95, 0.95),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(0.28, widthSegments: 10, heightSegments: 6),
          fur,
        )..position.set(0.55, 0.78, 0),
      )
      ..add(_ball(0.12, Colors.white)..position.set(-0.6, 0.55, 0));
    for (final side in const [-1.0, 1.0]) {
      n
        ..add(
          _mesh(
              _rt_Geometry3D.sphere(0.09, widthSegments: 8, heightSegments: 5),
              dark,
            )
            ..position.set(0.45, 1.25, 0.1 * side)
            ..scale.set(1.0, 3.6, 0.6)
            ..rotation.z = 0.25,
        )
        ..add(
          _ball(0.05, const Color(0xFF111827))
            ..position.set(0.74, 0.86, 0.13 * side),
        );
    }
    return n;
  }

  /// A fox (facing +x).
  _rt_Node3D _foxModel() {
    const fur = Color(0xFFEA580C), dark = Color(0xFF7C2D12);
    final n = _rt_Node3D(name: 'fox')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.5, widthSegments: 12, heightSegments: 8),
            fur,
          )
          ..position.y = 0.85
          ..scale.set(1.6, 0.75, 0.75),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(0.32, widthSegments: 10, heightSegments: 6),
          fur,
        )..position.set(0.85, 1.15, 0),
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cone(0.16, 0.45, segments: 6),
            const Color(0xFFFED7AA),
          )
          ..position.set(1.25, 1.07, 0)
          ..rotation.z = -math.pi / 2,
      )
      ..add(
        _mesh(_rt_Geometry3D.cone(0.24, 1.1, segments: 8), fur)
          ..position.set(-1.2, 0.8, 0)
          ..rotation.z = math.pi / 2 + 0.35,
      )
      ..add(_ball(0.12, Colors.white)..position.set(-1.72, 0.6, 0));
    for (final side in const [-1.0, 1.0]) {
      n
        ..add(
          _mesh(_rt_Geometry3D.cone(0.1, 0.3, segments: 4), dark)
            ..position.set(0.8, 1.5, 0.15 * side),
        )
        ..add(
          _ball(0.045, const Color(0xFF111827))
            ..position.set(1.08, 1.24, 0.14 * side),
        );
      for (final x in const [-0.45, 0.45]) {
        n.add(
          _mesh(_rt_Geometry3D.cylinder(0.07, 0.06, 0.6, segments: 5), dark)
            ..position.set(x, 0.3, 0.2 * side),
        );
      }
    }
    return n;
  }

  /// An eagle (facing +x).
  _rt_Node3D _eagleModel() {
    const brown = Color(0xFF78350F);
    final n = _rt_Node3D(name: 'eagle')
      ..add(
        _mesh(_rt_Geometry3D.capsule(0.38, 0.8, segments: 14), brown)
          ..position.y = 1.0
          ..rotation.z = -0.25,
      )
      ..add(_ball(0.3, const Color(0xFFF8FAFC))..position.set(0.22, 1.85, 0))
      ..add(
        _mesh(
            _rt_Geometry3D.cone(0.1, 0.32, segments: 6),
            const Color(0xFFFACC15),
          )
          ..position.set(0.56, 1.8, 0)
          ..rotation.z = -math.pi / 2,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.3, 0.55, 0.4), const Color(0xFF451A03))
          ..position.set(-0.4, 0.35, 0)
          ..rotation.z = 0.5,
      );
    for (final side in const [-1.0, 1.0]) {
      n
        ..add(
          _mesh(
              _rt_Geometry3D.sphere(0.5, widthSegments: 12, heightSegments: 8),
              const Color(0xFF92400E),
            )
            ..position.set(-0.05, 1.0, 0.36 * side)
            ..scale.set(0.45, 1.25, 0.22),
        )
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(0.05, 0.05, 0.4, segments: 5),
            const Color(0xFFFACC15),
          )..position.set(0.05, 0.2, 0.14 * side),
        );
    }
    return n;
  }

  /// The disease: a virus with spikes all round (the source's spikes lay
  /// flat).
  _rt_Node3D _virusModel() {
    final n = _rt_Node3D(name: 'disease')
      ..add(_ball(0.5, const Color(0xFFEF4444)));
    const count = 14;
    for (var k = 0; k < count; k++) {
      // Even directions on a sphere (Fibonacci spiral).
      final y = 1 - 2 * (k + 0.5) / count;
      final r = math.sqrt(1 - y * y);
      final a = k * 2.39996;
      final dir = _rt_V3(r * math.cos(a), y, r * math.sin(a));
      n
        ..add(
          _mesh(
              _rt_Geometry3D.cylinder(0.04, 0.07, 0.34, segments: 5),
              const Color(0xFFB91C1C),
            )
            ..position.copy(dir * 0.62)
            ..pointAlong(dir),
        )
        ..add(_ball(0.08, const Color(0xFFFCA5A5))..position.copy(dir * 0.82));
    }
    return n;
  }

  /// An arrow along +x (shaft and head) in [mat].
  _rt_Node3D _arrow(_rt_Material3D mat, {double length = 2.0}) {
    return _rt_Node3D()
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.box(length, 0.22, 0.22), mat)
          ..position.x = -0.25,
      )
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.cone(0.34, 0.6, segments: 10), mat)
          ..position.x = length / 2 + 0.05
          ..rotation.z = -math.pi / 2,
      );
  }

  // ---------------------------------------------------------- scenes ---
  void _buildScenario() {
    _root.clear();
    _labels.clear();
    _objects.clear();
    _frogs.clear();
    _frogMats.clear();
    _stalks.clear();
    _bugs.clear();
    _fish.clear();
    _fishMats.clear();
    _inspectLabels.clear();
    _hares.clear();
    _bars.clear();
    _barLabels.clear();
    _trends.clear();
    _waterMat = null;
    _crateCount = _frogsHarmedLabel = _fishHarmedLabel = null;
    _outbreakLabel = null;
    _mist = null;
    _rng = math.Random(145 + _scenario);
    switch (_scenario) {
      case 1:
        _buildField();
      case 2:
        _buildWeb();
    }
    _syncLabels();
  }

  /// S1: a paddy field (water, three mud beds with rice), 15 frogs, a few
  /// fish, the export crate and the pesticide spray (step 4).
  void _buildField() {
    _root.add(
      _mesh(_rt_Geometry3D.box(42, 0.1, 24), const Color(0xFF365314))
        ..position.set(0, -0.75, 0)
        ..depthBias = 50,
    );
    final water = _rt_Material3D(
      color: const Color(0xFF3B82F6),
      shininess: 0.6,
    );
    _waterMat = water;
    _root.add(
      _rt_Mesh3D(_rt_Geometry3D.box(24, 0.1, 15), water)
        ..position.set(0, -0.65, 0)
        ..depthBias = 40,
    );
    for (var r = 0; r < 3; r++) {
      _root.add(
        _mesh(_rt_Geometry3D.box(22, 0.4, 2.2), const Color(0xFF78350F))
          ..position.set(0, -0.4, _rowZ(r))
          ..depthBias = 30,
      );
    }
    const bund = Color(0xFF451A03);
    for (final z in const [-7.9, 7.9]) {
      _root.add(
        _mesh(_rt_Geometry3D.box(25.6, 0.5, 0.8), bund)
          ..position.set(0, -0.45, z)
          ..depthBias = 35,
      );
    }
    for (final x in const [-12.4, 12.4]) {
      _root.add(
        _mesh(_rt_Geometry3D.box(0.8, 0.5, 15), bund)
          ..position.set(x, -0.45, 0)
          ..depthBias = 35,
      );
    }
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 6; c++) {
        final s = _stalk();
        s.node.position.set(
          _stalkX(c) + (_rng.nextDouble() - 0.5) * 0.3,
          -0.2,
          _rowZ(r) + (_rng.nextDouble() - 0.5) * 0.3,
        );
        _stalks.add(s);
        _root.add(s.node);
      }
    }
    // The infested stalks: a tap area, a "Pests found" label and their
    // bugs (hidden until the outbreak).
    for (final (i, (r, c)) in _patches.indexed) {
      final s = _stalks[r * 6 + c];
      s.node.add(
        _proxy(_rt_Geometry3D.cylinder(1.3, 1.3, 3.2, segments: 8))
          ..position.y = 1.6
          ..userData['tap'] = 'stalk$i',
      );
      final label = _hiddenLabel(
        'inspected',
        s.node.position.x,
        3.4,
        s.node.position.z,
      );
      _inspectLabels.add(label);
      _root.add(label);
      for (var k = 0; k < _bugsPerPatch; k++) {
        final a = k / _bugsPerPatch * 2 * math.pi + _rng.nextDouble() * 0.5;
        final rad = 0.5 + _rng.nextDouble() * 0.8;
        final base = _rt_V3(
          s.node.position.x + rad * math.cos(a),
          0.3 + _rng.nextDouble() * 2.0,
          s.node.position.z + rad * math.sin(a),
        );
        final bug = _bugModel()
          ..position.copy(base)
          ..visible = false;
        _bugs.add(_Bug(bug, i, base, _rng.nextDouble() * 6.28));
        _root.add(bug);
      }
    }
    // 15 frogs between the stalks.
    for (var k = 0; k < _frogCount; k++) {
      final mat = _rt_Material3D(
        color: const Color(0xFF22C55E),
        shininess: 0.4,
      );
      final frog = _frogModel(mat)
        ..scale.set(1.15, 1.15, 1.15)
        ..rotation.y = _rng.nextDouble() * 2 * math.pi
        ..add(_proxy(_rt_Geometry3D.sphere(0.8))..position.y = 0.4);
      _setHome(
        frog,
        -7.2 + 3.6 * (k % 5) + (_rng.nextDouble() - 0.5) * 0.6,
        -0.2,
        _rowZ(k ~/ 5) + (_rng.nextDouble() - 0.5) * 0.8,
      );
      _frogs.add(frog);
      _frogMats.add(mat);
      _root.add(_draggable('frog$k', frog));
    }
    // Fish in the channels between the beds.
    for (final (i, (x, z)) in const [
      (-6.0, -2.3),
      (4.0, -2.3),
      (-2.0, 2.3),
      (7.0, 2.3),
    ].indexed) {
      final mat = _rt_Material3D(
        color: const Color(0xFFF97316),
        shininess: 0.5,
      );
      final fish = _fishModel(mat)
        ..position.set(x, -0.52, z)
        ..userData['x'] = x
        ..userData['phase'] = i * 1.7;
      _fish.add(fish);
      _fishMats.add(mat);
      _root.add(fish);
    }
    final crate = _crateModel()..position.copy(_crateCentre);
    final count = _rawLabel(_crateCentre.x, 1.6, _crateCentre.z)
      ..text = '0 / $_frogCount';
    _crateCount = count;
    _root
      ..add(crate)
      ..add(_label('export', _crateCentre.x, 2.5, _crateCentre.z))
      ..add(count);
    final spray = _sprayModel()
      ..add(
        _proxy(_rt_Geometry3D.cylinder(0.9, 0.9, 3.0, segments: 8))
          ..position.y = 1.4,
      )
      ..add(_label('spray', 0, 3.2, 0));
    _setHome(spray, _sprayHome.x, _sprayHome.y, _sprayHome.z);
    _root.add(_draggable('spray', spray));
    final mist = _rt_Mesh3D(
      _rt_Geometry3D.cone(1.7, 2.2, segments: 12),
      _rt_Material3D(
        color: const Color(0xFF86EFAC),
        opacity: 0.35,
        unlit: true,
      ),
    )..visible = false;
    mist.pickable = false;
    _mist = mist;
    _root.add(mist);
    final frogsHarmed = _hiddenLabel('frogsHarmed', 0, 1.6, 0);
    final fishHarmed = _hiddenLabel('fishHarmed', 0, 1.0, 0);
    _frogsHarmedLabel = frogsHarmed;
    _fishHarmedLabel = fishHarmed;
    _root
      ..add(frogsHarmed)
      ..add(fishHarmed);
  }

  /// Marks stalk ([r], [c]) as eaten by the pests.
  void _damage((int, int) rc) {
    final s = _stalks[rc.$1 * 6 + rc.$2];
    if (s.damaged) return;
    s.damaged = true;
    s.mat.color = const Color(0xFFA16207);
    s.grains.visible = false;
    s.node.rotation.z = 0.14;
  }

  _rt_V3 _patchCentre(int i) {
    final (r, c) = _patches[i];
    return _stalks[r * 6 + c].node.position.clone();
  }

  bool _patchAlive(int i) => _bugs.any((b) => b.patch == i && b.alive);

  /// S2: grass, hares, a fox and an eagle on bases, with population bars
  /// behind them and food arrows (the hare feeds both predators).
  void _buildWeb() {
    _root.add(
      _mesh(_rt_Geometry3D.box(32, 0.2, 13), const Color(0xFF3F6212))
        ..position.set(0, -2.1, 0.5)
        ..depthBias = 40,
    );
    final arrowMat = _rt_Material3D(
      color: const Color(0xFF22C55E),
      shininess: 0.4,
    );
    for (final (i, id) in _web.indexed) {
      final x = _nodeX(i);
      final node = _rt_Node3D(name: id)
        ..position.set(x, -1.7, 0.6)
        ..scale.set(1.2, 1.2, 1.2);
      switch (id) {
        case 'grass':
          node.add(_grassModel());
        case 'hare':
          for (final (dx, dz) in const [
            (-0.2, 0.2),
            (-0.9, -0.8),
            (0.7, 0.9),
          ]) {
            final hare = _hareModel()..position.set(dx, 0, dz);
            _hares.add(hare);
            node.add(hare);
          }
        case 'fox':
          node.add(_foxModel()..position.x = -0.2);
        case 'eagle':
          node.add(_eagleModel());
      }
      _root
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(1.9, 2.0, 0.3, segments: 28),
            const Color(0xFF451A03),
          )..position.set(x, -1.85, 0.6),
        )
        ..add(node)
        // Below the bases, so the names never pile up over the animals.
        ..add(_label(id, x, -1.75, 3.2))
        ..add(
          _mesh(
            _rt_Geometry3D.cylinder(0.45, 0.45, 4, segments: 16),
            const Color(0xFF334155),
            opacity: 0.5,
          )..position.set(x, 0.3, -2.6),
        );
      final barMat = _rt_Material3D(
        color: const Color(0xFF22C55E),
        shininess: 0.3,
      );
      final bar = _rt_Node3D()
        ..position.set(x, -1.7, -2.6)
        ..userData['mat'] = barMat;
      bar.add(
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.42, 0.42, 4, segments: 16), barMat)
          ..position.y = 2,
      );
      _bars[id] = bar;
      final value = _rawLabel(x, 2.9, -2.6);
      _barLabels[id] = value;
      _root
        ..add(bar)
        ..add(value);
      if (id != 'hare') {
        final down = id != 'grass';
        final trend = _rt_Arrow3D(
          dir: _rt_V3(0, down ? -1 : 1, 0),
          length: 1.8,
          origin: _rt_V3(x + 2.0, down ? 1.4 : -0.6, 1.8),
          color: down ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
          headLength: 0.6,
          headWidth: 0.36,
          shaftRadius: 0.12,
        )..visible = false;
        _trends[id] = trend;
        _root.add(trend);
      }
    }
    // Grass -> hare and hare -> fox: straight arrows between the bases.
    for (final i in const [0, 1]) {
      _root.add(
        _arrow(arrowMat, length: 1.6)
          ..position.set(_nodeX(i) + 3.5, -0.6, 0.6)
          ..scale.set(0.8, 0.8, 0.8),
      );
    }
    // Hare -> eagle: an arc over the fox (content fix: the eagle was named
    // on the board but missing from the scene).
    final start = _rt_V3(_nodeX(1) + 1.6, 0.2, 1.6);
    final end = _rt_V3(_nodeX(3) - 1.9, 0.2, 1.6);
    _rt_V3 arc(double t) => _rt_V3(
      start.x + (end.x - start.x) * t,
      start.y + 2.4 * math.sin(math.pi * t),
      start.z,
    );
    final points = [for (var k = 0; k <= 24; k++) arc(k / 24)];
    final tip = arc(1);
    final dir = (tip - arc(0.94))..normalize();
    _root
      ..add(
        _rt_Line3D(points, color: const Color(0xFF22C55E), width: 5)
          ..pickable = false,
      )
      ..add(
        _rt_Mesh3D(_rt_Geometry3D.cone(0.3, 0.6, segments: 10), arrowMat)
          ..position.copy(tip)
          ..pointAlong(dir),
      );
    final virus = _virusModel()
      ..add(_proxy(_rt_Geometry3D.sphere(1.0)))
      ..add(_label('disease', 0, 1.2, 0));
    _setHome(virus, _nodeX(1) - 0.5, 2.6, 4.4);
    _root.add(_draggable('disease', virus));
    final outbreak = _hiddenLabel('outbreak', _nodeX(1), 1.0, 0.6);
    _outbreakLabel = outbreak;
    _root.add(outbreak);
    for (final id in _web) {
      _setBar(id, _popStart[id]!);
    }
  }

  /// Sets population bar [id] to [p] percent.
  void _setBar(String id, double p) {
    _popNow[id] = p;
    final bar = _bars[id];
    if (bar == null) return;
    bar
      ..scale.set(1, math.max(0.001, p / 100), 1)
      ..visible = p > 0.5;
    _barLabels[id]?.text = '${p.round()}%';
  }

  Future<void> _tweenBars(Map<String, double> to, int ms) {
    final from = Map.of(_popNow);
    return _tweens.run(ms, (t) {
      for (final MapEntry(key: id, value: v) in to.entries) {
        _setBar(id, from[id]! + (v - from[id]!) * t);
      }
    });
  }

  void _tintWater(double k) {
    _waterMat?.color = Color.lerp(
      const Color(0xFF3B82F6),
      const Color(0xFF8A7A2E),
      k.clamp(0.0, 1.0),
    )!;
  }

  /// Shows only what the current step uses.
  void _applyStepVisuals() {
    if (_scenario != 1) return;
    _objects['spray']?.visible = _step >= 4;
  }

  // ------------------------------------------------------------ camera ---
  /// Points that must stay on screen in the current scenario.
  List<_rt_V3> get _framePoints => switch (_scenario) {
    1 => [
      _rt_V3(-17.6, -0.6, 6.4),
      _rt_V3(17.6, -0.6, 6.4),
      _rt_V3(-12.8, -0.6, 8.3),
      _rt_V3(12.8, -0.6, 8.3),
      _rt_V3(-12.8, -0.6, -8.3),
      _rt_V3(12.8, -0.6, -8.3),
      _rt_V3(-9.0, 3.0, -4.6),
      _rt_V3(9.0, 3.0, -4.6),
      _rt_V3(15.0, 3.0, 4.6),
      _rt_V3(-15.0, 3.4, 4.6),
      _rt_V3(-18.6, 3.4, 4.6),
      _rt_V3(0, 5.6, -4.6),
    ],
    _ => [
      _rt_V3(-13.2, -2.1, 3.6),
      _rt_V3(13.2, -2.1, 3.6),
      _rt_V3(-12.0, 3.4, -2.6),
      _rt_V3(12.0, 3.4, -2.6),
      _rt_V3(3.5, 3.4, 1.6),
      _rt_V3(-4.0, 4.0, 4.4),
    ],
  };

  double get _elevation => _scenario == 1 ? 0.9 : 0.3;

  /// Width of the chalkboard (step 1) or the step panel on the left.
  double _boardWidth(Size size, bool compact) =>
      math.min(compact ? 270.0 : 420.0, size.width * 0.5);

  double _panelWidth(Size size, bool compact) =>
      math.min(compact ? 220.0 : 330.0, size.width * 0.46);

  /// True for steps that show a panel on the left of the 3D view (the S2
  /// predictions).
  bool get _hasSidePanel => _scenario == 2 && _step >= 3;

  /// Height of the field monitor strip along the top (S1 from step 2).
  double _topReserve(bool compact) =>
      _scenario == 1 && _step >= 2 ? (compact ? 46.0 : 62.0) : 0.0;

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
    if (_scenario == 1) _animateField(dt);
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

  /// Bugs buzz, fish swim, the pests eat the crop, the mist follows the
  /// spray.
  void _animateField(double dt) {
    for (final b in _bugs) {
      if (!b.alive || !b.node.visible) continue;
      final t = _clock * 7 + b.phase;
      b.node
        ..position.set(
          b.base.x + 0.18 * math.cos(t * 0.6),
          b.base.y + 0.16 * math.sin(t),
          b.base.z + 0.18 * math.sin(t * 0.6),
        )
        ..rotation.y = -t * 0.6;
    }
    if (!_poisoned) {
      for (final f in _fish) {
        final s = _clock * 0.5 + (f.userData['phase'] as double);
        f.position.x = (f.userData['x'] as double) + 2.4 * math.sin(s);
        f.rotation.y = math.cos(s) >= 0 ? 0 : math.pi;
      }
    }
    if (_pests && !_sprayed && !_scenarioDone) {
      _health = math.max(_healthFloor, _health - dt * _healthDrop);
      while (_spreadDone < _spread.length &&
          _health <= _spreadAt[_spreadDone]) {
        _damage(_spread[_spreadDone]);
        _spreadDone++;
      }
    }
    final mist = _mist, spray = _objects['spray'];
    if (mist != null && spray != null && mist.visible) {
      mist.position.set(
        spray.position.x,
        spray.position.y - 1.1,
        spray.position.z,
      );
    }
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
      _exportedIds.clear();
      _pests = false;
      _health = _healthStart;
      _spreadDone = 0;
      _inspected.clear();
      _pollution = 0;
      _sprayed = false;
      _poisoned = false;
      _infected = false;
      _popNow.clear();
      _predictions.clear();
      _predWrong.clear();
      _predatorsDone = false;
      _grassDone = false;
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
  bool _grabbable(String id) {
    if (_busy || _scenarioDone) return false;
    return switch ((_scenario, _step)) {
      (1, 2) =>
        id.startsWith('frog') &&
            !_exportedIds.contains(id) &&
            _exported < _exportGoal,
      (1, 4) => id == 'spray' && !_sprayed,
      (2, 2) => id == 'disease' && !_infected,
      _ => false,
    };
  }

  /// Ids that can be dragged right now (for the grab / target markers).
  List<String> get _grabbableIds => [
    for (final id in _objects.keys)
      if (_grabbable(id) && _objects[id]!.isVisibleInTree) id,
  ];

  /// The handle: a frog's body, the spray bottle's middle, the virus'
  /// centre.
  _rt_V3 _handleLocal(String id) => switch (id) {
    'spray' => _rt_V3(0, 1.0, 0),
    'disease' => _rt_V3(),
    _ => _rt_V3(0, 0.3, 0),
  };

  _rt_V3 _handleWorld(String id) =>
      _objects[id]!.localTransform.apply(_handleLocal(id));

  /// Height of the horizontal drag plane for [id] (null: vertical plane).
  double? _liftY(String id) => switch (id) {
    'spray' => _sprayLift,
    'disease' => null,
    _ => _frogLift,
  };

  /// Drop targets: the crate (frogs), each patch with pests left (spray),
  /// the hares (disease).
  List<(String, _DropWindow)> _targets(String id) {
    if (id == 'spray') {
      return [
        for (var i = 0; i < _patches.length; i++)
          if (_patchAlive(i))
            (
              'patch$i',
              _DropWindow(_patchCentre(i)..y = _sprayLift, _sprayRadius, 0, 0),
            ),
      ];
    }
    if (id == 'disease') {
      return [
        ('hare', _DropWindow(_rt_V3(_nodeX(1), -0.9, 0.6), 2.2, 1.4, 3.2)),
      ];
    }
    final c = _crateCentre;
    return [('crate', _DropWindow(_rt_V3(c.x, _frogLift, c.z), 2.4, 0, 0))];
  }

  Iterable<String> _ringTargets(String id) => [
    for (final (t, _) in _targets(id)) t,
  ];

  bool _onPointerDown(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['drag'] != null);
    if (hit == null) return false;
    final id = hit.userData['drag'] as String;
    if (!_grabbable(id)) return false;
    final targets = _targets(id);
    final handle = e.frame.project(_handleWorld(id));
    if (targets.isEmpty || handle == null) return false;
    final lift = _liftY(id);
    if (lift != null) {
      _planePoint = _rt_V3(0, lift, 0);
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
    if (id == 'spray') _spraying(true);
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
    if (_liftY(id) != null) {
      p
        ..x = p.x.clamp(-18.0, 18.0)
        ..z = p.z.clamp(-8.5, 8.5);
    } else {
      p.y = math.max(p.y, -1.6);
    }
    node.position.copy(p - (_handleWorld(id) - node.position));
    if (id == 'spray') _sprayAt(node.position);
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final id = _dragId;
    if (id == null) return;
    setState(() => _dragId = null);
    if (id == 'spray') {
      _spraying(false);
      if (_sprayed) {
        _poisonField();
      } else {
        if (_dragTravel >= 12) _toast('fbSprayMore', good: false);
        _snapBack(id);
      }
      return;
    }
    // A tap (no real move) never counts as a drop.
    if (_dragTravel < 12) {
      _snapBack(id);
      return;
    }
    final h = _handleWorld(id);
    final w = _targets(id).first.$2;
    if (id == 'disease') {
      final n = _planeNormal!;
      if (w.contains(h, _rt_V3(n.z, 0, -n.x))) {
        _infect();
      } else {
        _toast('fbDropHare', good: false);
        _snapBack(id);
      }
    } else if (w.containsFlat(h)) {
      _export(id);
    } else {
      _toast('fbDropCrate', good: false);
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
  /// Frog [id] goes into the export crate; at 7 the pests break out.
  Future<void> _export(String id, {bool fromHome = false}) async {
    if (_busy ||
        _scenario != 1 ||
        _step != 2 ||
        _exportedIds.contains(id) ||
        _exported >= _exportGoal) {
      return;
    }
    final run = _run;
    final slot = _exported;
    setState(() {
      _busy = true;
      _exportedIds.add(id);
    });
    final node = _objects[id]!;
    final c = _crateCentre;
    final to = _rt_V3(
      c.x - 0.8 + 0.8 * (slot % 3),
      c.y + 0.2 + 0.35 * (slot ~/ 9),
      c.z - 0.8 + 0.8 * ((slot ~/ 3) % 3),
    );
    await _tweenNode(
      node,
      _rt_V3(to.x, _frogLift + 0.8, to.z),
      fromHome ? 450 : 200,
    );
    if (!_alive(run)) return;
    await _tweenNode(
      node,
      to,
      220,
      rot: _rt_V3(0, _rng.nextDouble() * 2 * math.pi, 0),
    );
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _crateCount?.text = '$_exported / $_frogCount';
    if (_exported >= _exportGoal) {
      _toast('fbExported', good: false, ms: 3500);
      _after(1000, _releasePests);
      return;
    }
    setState(() => _busy = false);
  }

  /// Twin: the next frog still in the field.
  void _exportNext() {
    for (final f in _frogs) {
      final id = f.userData['drag'] as String;
      if (!_exportedIds.contains(id)) {
        _export(id, fromHome: true);
        return;
      }
    }
  }

  /// Step 3 begins: the pests swarm the infested stalks and start eating.
  Future<void> _releasePests() async {
    if (_scenario != 1 || _step != 2) return;
    final run = _run;
    _advance();
    setState(() {
      _busy = true;
      _pests = true;
    });
    for (final p in _patches) {
      _damage(p);
    }
    for (final b in _bugs) {
      b.node
        ..visible = true
        ..scale.set(0.01, 0.01, 0.01);
    }
    _toast('fbPests', good: false);
    await _tweens.run(500, (t) {
      for (final b in _bugs) {
        b.node.scale.set(t, t, t);
      }
    });
    if (!_alive(run)) return;
    setState(() => _busy = false);
  }

  /// Marks infested stalk [i] (content fix: inspecting no longer lowers
  /// crop health - the pests do that over time).
  void _inspect(int i) {
    if (_busy || _scenario != 1 || _step != 3 || _inspected.contains(i)) {
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _inspected.add(i));
    _showLabel(_inspectLabels[i], true);
    if (_inspected.length == _patches.length) {
      setState(() => _busy = true);
      _toast('fbInspected', good: false, ms: 3500);
      _after(900, () {
        _advance();
        _hint('fbSprayHint');
      });
    }
  }

  void _inspectNext() {
    for (var i = 0; i < _patches.length; i++) {
      if (!_inspected.contains(i)) {
        _inspect(i);
        return;
      }
    }
  }

  /// Tilts the bottle and shows the mist while spraying.
  void _spraying(bool on) {
    final spray = _objects['spray'];
    if (spray == null) return;
    spray.rotation.z = on ? -0.25 : 0;
    _mist?.visible = on;
    if (on) {
      _mist?.position.set(
        spray.position.x,
        spray.position.y - 1.1,
        spray.position.z,
      );
    }
  }

  /// Kills the pests under the spray at [p] (the source counted pointer
  /// events instead).
  void _sprayAt(_rt_V3 p) {
    var killed = false;
    for (final b in _bugs) {
      if (!b.alive) continue;
      final dx = b.node.position.x - p.x, dz = b.node.position.z - p.z;
      if (dx * dx + dz * dz > _sprayRadius * _sprayRadius) continue;
      b.alive = false;
      killed = true;
      final n = b.node, from = n.position.clone();
      _tweens
          .run(350, (t) => n.position.y = from.y + (-0.3 - from.y) * t)
          .then((_) => n.visible = false);
    }
    if (!killed) return;
    for (var i = 0; i < _patches.length; i++) {
      if (!_patchAlive(i)) _showLabel(_inspectLabels[i], false);
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _pollution = 45.0 * (1 - _bugsAlive / _bugs.length);
      if (_bugsAlive == 0) _sprayed = true;
    });
    _tintWater(_pollution / 100);
  }

  /// Twin: sprays the next patch that still has pests.
  Future<void> _sprayNext() async {
    if (_busy || _scenario != 1 || _step != 4 || _sprayed) return;
    final patch = [
      for (var i = 0; i < _patches.length; i++) i,
    ].firstWhere(_patchAlive, orElse: () => -1);
    if (patch < 0) return;
    final run = _run;
    setState(() => _busy = true);
    final spray = _objects['spray']!;
    final c = _patchCentre(patch);
    await _tweenNode(spray, _rt_V3(c.x, _sprayLift - 1.0, c.z), 600);
    if (!_alive(run)) return;
    _spraying(true);
    _sprayAt(spray.position);
    await _pause(400);
    if (!_alive(run)) return;
    _spraying(false);
    if (_sprayed) {
      _poisonField();
      return;
    }
    await _tweenNode(spray, _sprayHome, 450, rot: _rt_V3());
    if (!_alive(run)) return;
    setState(() => _busy = false);
  }

  /// Content fix: the pesticide also poisons the frogs left in the field
  /// and the fish, and pollutes the water.
  Future<void> _poisonField() async {
    if (_poisoned || _scenario != 1) return;
    final run = _run;
    setState(() {
      _busy = true;
      _poisoned = true;
    });
    final spray = _objects['spray']!;
    unawaited(_tweenNode(spray, _sprayHome, 450, rot: _rt_V3()));
    _toast('fbSprayDone', good: false, ms: 4500);
    final left = [
      for (var k = 0; k < _frogs.length; k++)
        if (!_exportedIds.contains('frog$k')) k,
    ];
    final p0 = _pollution;
    final fishY = [for (final f in _fish) f.position.y];
    await _tweens.run(1600, (t) {
      _pollution = p0 + (85 - p0) * t;
      _tintWater(_pollution / 100);
      for (final k in left) {
        _frogMats[k].color = Color.lerp(
          const Color(0xFF22C55E),
          const Color(0xFF78716C),
          t,
        )!;
        _frogs[k].scale.y = 1.15 * (1 - 0.4 * t);
      }
      for (final (i, f) in _fish.indexed) {
        _fishMats[i].color = Color.lerp(
          const Color(0xFFF97316),
          const Color(0xFF9CA3AF),
          t,
        )!;
        f
          ..rotation.x = math.pi * t
          ..position.y = fishY[i] + 0.1 * t;
      }
    });
    if (!_alive(run)) return;
    if (left.isNotEmpty) {
      _frogsHarmedLabel?.position.copy(
        _frogs[left.first].position + _rt_V3(0, 1.4, 0),
      );
      _showLabel(_frogsHarmedLabel, true);
    }
    if (_fish.isNotEmpty) {
      _fishHarmedLabel?.position.copy(_fish.first.position + _rt_V3(0, 1.0, 0));
      _showLabel(_fishHarmedLabel, true);
    }
    setState(() {});
    _after(1200, _completeScenario);
  }

  // ------------------------------------------------- scenario 2 actions ---
  /// The disease reaches the hares: most of them die.
  Future<void> _infect({bool fromHome = false}) async {
    if (_busy || _infected || _scenario != 2 || _step != 2) return;
    final run = _run;
    setState(() {
      _busy = true;
      _infected = true;
    });
    final virus = _objects['disease']!;
    await _tweenNode(virus, _rt_V3(_nodeX(1), -0.6, 0.6), fromHome ? 600 : 250);
    if (!_alive(run)) return;
    final s0 = virus.scale.x;
    await _tweens.run(300, (t) {
      final s = s0 * (1 - t);
      virus.scale.set(s, s, s);
    });
    if (!_alive(run)) return;
    virus.visible = false;
    _rt_playSfx(_rt_Sfx.pop);
    (_bars['hare']?.userData['mat'] as _rt_Material3D?)?.color = const Color(
      0xFFEF4444,
    );
    unawaited(_tweenBars({'hare': _popAfter['hare']!}, 1000));
    final sick = _hares.sublist(1);
    await _tweens.run(800, (t) {
      for (final h in sick) {
        h.scale.set(1 - t, 1 - t, 1 - t);
      }
    });
    if (!_alive(run)) return;
    for (final h in sick) {
      h.visible = false;
    }
    _showLabel(_outbreakLabel, true);
    _toast('fbOutbreak', good: false, ms: 3500);
    _after(800, _advance);
  }

  /// The populations predicted in the current step.
  List<String> get _predIds =>
      _step == 3 ? const ['fox', 'eagle'] : const ['grass'];

  void _predict(String id, String choice) {
    if (_scenario != 2 || _busy || !_predIds.contains(id)) return;
    if (_step == 3 ? _predatorsDone : _grassDone) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _predictions[id] = choice;
      _predWrong.remove(id);
    });
  }

  /// Checks this step's predictions (content fix: explicit choices; the
  /// source's arrows cycled and the HUD gave the answer away).
  Future<void> _check() async {
    if (_scenario != 2 || _step < 3 || _busy) return;
    final predators = _step == 3;
    if (predators ? _predatorsDone : _grassDone) return;
    final ids = _predIds;
    if (ids.any((id) => !_predictions.containsKey(id))) {
      _toast('fbPickAll', good: false);
      return;
    }
    final wrong = {
      for (final id in ids)
        if (_predictions[id] != _answers[id]) id,
    };
    if (wrong.isNotEmpty) {
      setState(
        () => _predWrong
          ..clear()
          ..addAll(wrong),
      );
      _toast(
        predators ? 'fbPredatorWrong' : 'fbGrassWrong',
        good: false,
        ms: 4500,
      );
      return;
    }
    final run = _run;
    setState(() {
      _busy = true;
      _predWrong.clear();
      if (predators) {
        _predatorsDone = true;
      } else {
        _grassDone = true;
      }
    });
    _toast(predators ? 'fbPredatorOk' : 'fbGrassOk', ms: 4500);
    for (final id in ids) {
      _trends[id]?.visible = true;
      if (predators) {
        (_bars[id]?.userData['mat'] as _rt_Material3D?)?.color = const Color(
          0xFFEF4444,
        );
      }
    }
    await _tweenBars({for (final id in ids) id: _popAfter[id]!}, 1000);
    if (!_alive(run)) return;
    _after(800, predators ? _advance : _completeScenario);
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
    return switch ((_scenario, _step)) {
      (1, 2) => [
        twin('twin-export', 'twExport', _exported >= _exportGoal, _exportNext),
      ],
      (1, 3) => [
        twin(
          'twin-inspect',
          'twInspect',
          _inspected.length == _patches.length,
          _inspectNext,
        ),
      ],
      (1, 4) => [twin('twin-spray', 'twSpray', _sprayed, _sprayNext)],
      (2, 2) => [
        twin(
          'twin-disease',
          'twDisease',
          _infected,
          () => _infect(fromHome: true),
        ),
      ],
      _ => const [],
    };
  }

  /// Tap markers: the infested stalks (S1 step 3).
  List<(String, _rt_V3)> get _tapSpots {
    if (_busy || _scenarioDone) return const [];
    return switch ((_scenario, _step)) {
      (1, 3) => [
        for (var i = 0; i < _patches.length; i++)
          if (!_inspected.contains(i))
            ('tap-stalk$i', _patchCentre(i) + _rt_V3(0, 1.4, 0)),
      ],
      _ => const [],
    };
  }

  void _onCanvasTap(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['tap'] != null);
    final tap = hit?.userData['tap'];
    if (tap is String && tap.startsWith('stalk')) {
      _inspect(int.parse(tap.substring(5)));
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
              headerGradient: [_rt_Tw.slate900, Color(0xFF14532D)],
              headerSubtitleColor: Color(0xFFBBF7D0),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('appSubtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.balance,
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
        if (_scenario == 1 && _step >= 2) _monitor(compact),
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

  // ------------------------------------------------------ field monitor ---
  /// S1: crop health, pests, frogs and water pollution along the top (the
  /// source only showed crop health, which never turned green again).
  Widget _monitor(bool compact) {
    return Positioned(
      left: 12,
      right: 64,
      top: compact ? 6 : 10,
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: _frameTick,
          builder: (context, _, _) => _monitorRow(compact),
        ),
      ),
    );
  }

  Widget _monitorRow(bool compact) {
    final health = _health.round();
    final healthColor = health > 60
        ? _rt_Tw.green500
        : (health > 40 ? _rt_Tw.amber400 : _rt_Tw.red500);
    final pests = _pests ? _bugsAlive : 0;
    final frogsLeft = _frogCount - _exported;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Container(
        key: const ValueKey('monitor'),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xEB0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent, width: 1.2),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
        ),
        child: Row(
          children: [
            _meter(
              'monitor-health',
              Icons.grass,
              _tx.s('cropHealth'),
              '$health%',
              health / 100,
              healthColor,
              compact,
            ),
            _meter(
              'monitor-pests',
              Icons.bug_report,
              _tx.s('pests'),
              '$pests',
              _bugs.isEmpty ? 0 : pests / _bugs.length,
              pests > 0 ? _rt_Tw.red400 : _rt_Tw.green400,
              compact,
            ),
            _meter(
              'monitor-frogs',
              Icons.pets,
              _tx.s('frogsLeft'),
              '$frogsLeft',
              frogsLeft / _frogCount,
              _poisoned ? _rt_Tw.red400 : _rt_Tw.green400,
              compact,
            ),
            _meter(
              'monitor-pollution',
              Icons.water_drop,
              _tx.s('pollution'),
              '${_pollution.round()}%',
              _pollution / 100,
              _pollution > 50 ? _rt_Tw.red500 : _rt_Tw.amber400,
              compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _meter(
    String key,
    IconData icon,
    String label,
    String value,
    double fill,
    Color color,
    bool compact,
  ) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: compact ? 11 : 13, color: color),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 9 : 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  value,
                  key: ValueKey(key),
                  style: TextStyle(
                    fontSize: compact ? 10.5 : 12.5,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 3 : 4),
            Container(
              height: compact ? 4 : 5,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                widthFactor: fill.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------- step panels ---
  Widget _sidePanel(Size size, bool compact) {
    return Positioned(
      left: 12,
      top: 8,
      bottom: compact ? 64 : 84,
      width: _panelWidth(size, compact),
      child: Center(
        child: SingleChildScrollView(
          child: _glass(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: _predictionPanel(compact),
          ),
        ),
      ),
    );
  }

  Widget _choiceChip(
    String key,
    String label,
    IconData icon,
    _rt_ChoiceState state,
    VoidCallback? onTap,
    bool compact,
  ) {
    final (bg, border) = switch (state) {
      _rt_ChoiceState.correct => (_rt_Tw.green600, _rt_Tw.green500),
      _rt_ChoiceState.wrong => (const Color(0xFF7F1D1D), _rt_Tw.red500),
      _rt_ChoiceState.selected => (const Color(0xFF14532D), _accentSoft),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 13 : 15, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Increase / Decrease per population (content fix: the source's arrows
  /// cycled flat / down / up and the HUD named the answer). Step 4 keeps
  /// the predator answers on show.
  Widget _predictionPanel(bool compact) {
    final rows = _step == 3
        ? const ['fox', 'eagle']
        : const ['fox', 'eagle', 'grass'];
    final done = _step == 3 ? _predatorsDone : _grassDone;
    bool rowDone(String id) => id == 'grass' ? _grassDone : _predatorsDone;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('scenarios.1.steps.${_step - 1}.concept')),
        Padding(
          padding: EdgeInsets.only(bottom: compact ? 4 : 8),
          child: Text(
            _tx.s('predTitle'),
            style: TextStyle(
              fontSize: compact ? 11.5 : 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        for (final id in rows) ...[
          Text(
            _tx.s('pred.$id'),
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w900,
              color: _accentSoft,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final (i, c) in const ['inc', 'dec'].indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _choiceChip(
                    'pred-$id-$c',
                    _tx.s(c),
                    c == 'inc' ? Icons.arrow_upward : Icons.arrow_downward,
                    _predictions[id] != c
                        ? _rt_ChoiceState.idle
                        : (rowDone(id)
                              ? _rt_ChoiceState.correct
                              : (_predWrong.contains(id)
                                    ? _rt_ChoiceState.wrong
                                    : _rt_ChoiceState.selected)),
                    rowDone(id) ? null : () => _predict(id, c),
                    compact,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: compact ? 6 : 10),
        ],
        _rt_ActionButton(
          key: const ValueKey('btn-check'),
          label: _tx.s('check'),
          icon: Icons.fact_check,
          color: _accent,
          expand: true,
          done: done,
          onPressed: done || _busy ? null : _check,
        ),
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
        if (p != null) children.add(_hand(key, p, Icons.touch_app));
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
