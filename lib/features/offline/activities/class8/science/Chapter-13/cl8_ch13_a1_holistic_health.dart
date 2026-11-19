// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 13.1: Holistic Health - Physical, Mental, and Social
// Well-being
// Converted from Cl8S-Ch13-A1-holistic-health-physical-mental-and-social-wellbeing.html
// (three.js r128 + tween.js -> mini3d).
//
// Five scenarios picked from the sidebar, each opened by a chalkboard:
// (1) Rohan - drag his symptoms onto him (he turns red), then the school
// counsellor and new friends (he turns green); (2) Two playgrounds - sort
// four items into the clean and polluted zones, then set each zone's
// sickness frequency; (3) Ayurvedic balance - put the Ayurveda weight on
// the raised pan, then sort daily and seasonal routines; (4) Habits - adopt
// or avoid, then sign a pledge; (5) Health diary - log Day 1 on the
// clipboard, then draw the illustrative 30-day trend. Each finished
// scenario shows its summary with "Next Scenario".
//
// SOURCE BUG FIXES:
// * Pending timers survived a scenario change and advanced or concluded the
//   new scenario; every delayed step is cancelled on scenario change and
//   restart. Closing a summary left an empty panel (dead end) and the last
//   step was never ticked; S5's summary was never shown and "Mastery"
//   appeared even with S1-S4 undone. Every scenario now ends with its
//   summary and "Next Scenario" / "Restart".
// * "Click to Sign" and the counsellor could fire again during the closing
//   delay; every action is latched. Drops counted on any overlap with a
//   substring test; zones now take the pointer, and every wrong drop
//   explains itself (fever, broken leg, wrong zone, wrong bin).
// * The S1 figures were invisible and S4's scene was empty; Rohan, the
//   counsellor and the friends are shown. The S2 bushes and trash moved on
//   every load (fixed seed now). The "Health Meter" rose as sickness rose;
//   each zone has its own sickness bar. The diary reset showed blank badges
//   and its checks did not match its labels ("~8h" accepted 12 h).
// * HTML5 drag-and-drop did not work on touch screens; chips can be
//   dragged or tapped. Four panel strings were missing from the language
//   table, the board and many labels were never translated, the pledge
//   toast inserted the English habit; all text is translated and the Hindi
//   (abridged in the source) is rewritten. Pan did nothing and zoom had no
//   limits; the camera is clamped and framed per step for phones. Restart
//   keeps the language (the source reloaded the page). The breakfast icon
//   showed bacon.
//
// CONTENT FIXES (approved by the user):
// * S1: "Weight loss" (not "< 50 kg"); the counsellor helps first, then the
//   new friends, as the story says.
// * S3: the Ayurveda weight goes on the raised pan (a weight on the fulcrum
//   cannot level a beam); the board defines Dinacharya and Ritucharya; the
//   seasonal example matches the "warm foods" card.
// * S5: any emotion can be logged; targets are 60+ min of exercise, 8-10 h
//   of sleep and 2 h or less of screen time; the trend is a smooth curve
//   labelled as an illustration (the source drew random noise).
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
    'appTitle': 'Holistic Health: Physical, Mental, and Social Well-being',
    'appSubtitle': 'Class 8. Health: The Ultimate Treasure',
    'enterLab': 'Enter Activity',
    'selectScenario': 'Select Scenario',
    'missionObj': 'Concept Focus',
    'conceptExp': 'Activity Step',
    'currObj': 'Current Task',
    'exploration': 'Step',
    'conceptFocus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'nextScenario': 'Next Scenario',
    'restartLab': 'Restart Activity',
    'scComplete': 'Scenario {n} Complete!',
    'labComplete': 'Mastery Achieved!',
    'scenarioDoneHud':
        'Scenario {n} complete! Go on to the next scenario.', // added
    'labDoneHud': 'All scenarios complete! Restart the lab any time.', // added
    'labControls': 'Lab Controls', // added
    'controlsHint':
        'Drag or tap the objects in the 3D view, or use these buttons.', // added
    'ttLabels': 'Toggle labels', // added
    'ttLock': 'Lock / unlock camera', // added
    'lbl': {
      'rohan': 'Rohan',
      'zoneA': 'Zone A (Clean)',
      'zoneB': 'Zone B (Polluted)',
      'body': 'Body',
      'mind': 'Mind',
      'surround': 'Surroundings',
      'diary': 'Health Diary',
      'ayurveda': 'Ayurveda',
      'counsellor': 'School Counsellor', // added
      'friends': 'New Friends', // added
    },
    'twWeight': 'Ayurveda weight onto the raised pan', // added
    'dropRohan': 'Drop onto Rohan', // added
    'dropZone': 'Drop here', // added
    // Scenario 1 (the panel keys were missing from the source table).
    'symTitle': 'Identify the Symptoms',
    'symDesc': 'Drag the symptoms mentioned in the text onto Rohan.',
    'sym': {
      'headache': 'Headache',
      'weight': 'Weight loss', // content fix (was "Weight Loss (< 50 kg)")
      'fever': 'Fever',
      'insomnia': 'Insomnia (awake at 3:00 AM)',
      'screen': 'Excessive Screen Time',
      'broken': 'Broken Leg',
    },
    'fbFever':
        "Fever is not in Rohan's story - look for headaches, weight loss, sleepless nights and screen time.", // added
    'fbBroken':
        'A broken leg is an injury, not a sign of loneliness or stress.', // added
    'fbUnwell': 'All symptoms identified. Rohan is unwell.',
    'intTitle': 'Apply Intervention',
    'intDesc': 'Drag the social solutions to help Rohan.',
    'int': {'counsellor': 'School Counsellor', 'friends': 'New Friends'},
    // Content fix: the counsellor helps first, then the friends.
    'fbCounsellor':
        "Counsellor says: 'Let's build a social circle!' Now add New Friends.",
    'fbCounsellorFirst':
        'First let the School Counsellor talk to Rohan.', // added
    'fbHealthy': 'Social connection improved physical health!',
    'poorHealth': 'RED (Poor Health)',
    'goodHealth': 'GREEN (Healthy)',
    'sleep8': '8 hrs sleep', // was "8 HRS"
    'phoneOff': 'Phone off at night', // added
    // Scenario 2.
    'sortTitle': 'Build the Playgrounds', // added
    'sortDesc':
        'Drag each item onto Zone A (clean) or Zone B (polluted).', // added
    'item': {
      'air': 'Fresh Air / Trees',
      'fountain': 'Clean Fountain',
      'water': 'Stagnant Water',
      'garbage': 'Garbage Pile',
    },
    'fbKeepClean': 'Keep the clean area hygienic.',
    'fbCleanItem':
        'Fresh air and a clean fountain belong in the clean playground.', // added
    'fbSorted': 'Environments sorted.',
    // The source's "Health Meter" rose as sickness rose; each zone now has
    // its own sickness bar.
    'sickTitle': 'Sickness Frequency',
    'zoneA': 'Zone A (Clean)',
    'zoneB': 'Zone B (Polluted)',
    'targetLow': 'Target: Low (< 20%)',
    'targetHigh': 'Target: High (> 80%)',
    'verify': 'Verify Impact',
    'fbSickWrong':
        'Polluted areas have HIGHER (>80%) sickness. Clean areas have LOWER (<20%). Adjust sliders.',
    'fbSickOk': 'Dirty surroundings mean more sickness.', // added
    // Scenario 3.
    'fbPivot':
        'A weight on the pivot cannot turn the beam - put it on the raised pan.', // added
    'fbLowPan':
        'That pan is already lower - the weight belongs on the raised pan.', // added
    'fbWeightMiss': 'Drop the Ayurveda weight onto a pan.', // added
    'fbBalanced': 'Balance Restored!',
    'routineTitle': 'Sort the Routines', // added
    'bin': {'dina': 'Dinacharya (Daily)', 'ritu': 'Ritucharya (Seasonal)'},
    'habit': {
      'wake': 'Waking before sunrise',
      'brush': 'Brushing teeth',
      'warm': 'Warm foods in Winter',
      'light': 'Light clothes in Summer',
    },
    'fbRoutineWrong':
        'Daily habits repeat every day; seasonal habits change with the season.', // added
    // Scenario 4.
    'habitTitle': 'Habit Filter',
    'adopt': "Elders' Advice (Adopt)",
    'avoid': 'Health Risks (Avoid)',
    'hb': {
      'listen': 'Listening to Teachers',
      'eat': 'Eating on time',
      'mobile': 'Spending >4 hrs on Mobile',
      'skip': 'Skipping Breakfast',
    },
    'fbHabitWrong':
        'Think again: does this habit help or harm your health?', // added
    'pledgeTitle': 'My Commitment',
    'pledgeQ': 'Select a good habit to start following:',
    'signHint': 'Sign below to commit',
    'sign': 'Click to Sign',
    'fbPledge': 'Pledge Signed: I will start {habit}!',
    'fbPickHabit': 'Please select a habit first.',
    // Scenario 5.
    'diaryTitle': 'My Health Diary',
    'day1': 'Day 1',
    'pillar': {
      'food': 'Food',
      'hygiene': 'Hygiene',
      'exercise': 'Exercise',
      'sleep': 'Sleep',
      'screen': 'Screen Time',
      'emotion': 'Emotion',
    },
    'healthy': 'Healthy',
    'junk': 'Junk',
    'bathed': 'Bathed & Brushed',
    'unset': 'Unset',
    'done': 'Done',
    'mins': '{v} mins',
    'hrs': '{v} hrs',
    // Content fix (approved): 60 min exercise (WHO, ages 5-17), 8-10 h
    // sleep, any emotion.
    'tExercise': 'Target: 60 mins or more',
    'tSleep': 'Target: 8-10 hrs',
    'tScreen': 'Target: 2 hrs or less',
    'emo': {
      'happy': 'Happy',
      'neutral': 'Neutral',
      'sad': 'Sad',
      'angry': 'Angry',
    },
    'emoNote':
        'Any feeling can be logged - noticing it is what counts.', // added
    'completeDay': 'Complete Day 1',
    'fbFillAll': 'Please fill in all 6 pillars to log your day.',
    'fbTargets':
        'Review the targets! Healthy food, bathed & brushed, at least 60 mins of exercise, 8-10 hrs of sleep and at most 2 hrs of screen time.',
    'fbLogged': 'Day 1 logged!', // added
    'projTitle': 'Monthly Projection',
    'projDesc': "Assuming you repeat Day 1's habits for 30 days...",
    'calDays': ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    'generate': 'Generate Trend Graph',
    'healthScore': 'Health Score',
    'time30': 'Time (30 Days)',
    // Content fix (approved): the curve is an illustration, not data.
    'illustrative': 'Illustrative trend - not real data', // added
    'scenarios': [
      {
        'title': 'Scenario 1: The Impact of Social Isolation',
        'objective':
            'Understand the Mind-Body Connection and how social factors influence physical symptoms.',
        'board':
            "A student, Rohan, moved to a new school. With no friends, he felt lonely. He spent hours on his phone, had headaches, lost weight, and couldn't sleep. A school counsellor helped him make new friends.",
        'boardBtn': 'Analyze Case Study',
        'hud': [
          'Step 1: Read the case study.',
          'Step 2: Drag the specific symptoms onto Rohan.',
          'Step 3: Apply a social intervention: first the School Counsellor, then New Friends.',
        ],
        'steps': [
          {
            'concept': 'Theory',
            'action':
                'Review the chalkboard to understand how social isolation affects physical health.',
            'observation':
                'Social factors (loneliness) lead to mental stress, which manifests as physical symptoms.',
          },
          {
            'concept': 'Identifying Symptoms',
            'action':
                'Drag the specific symptoms (Headache, Weight loss, Insomnia, Screen Time) onto Rohan.',
            'observation':
                "These specific symptoms match the text description of Rohan's condition, causing his health to decline (turns red).",
          },
          {
            'concept': 'The Intervention',
            'action':
                "Drag 'School Counsellor' and then 'New Friends' onto Rohan to apply a social solution to his physical problems.",
            'observation':
                'Building a social circle resolves the mental stress and improves his physical symptoms (turns green).',
          },
        ],
        'summaryTitle': 'Connection Understood!',
        'summary':
            'You saw how a **social issue (loneliness)** caused physical symptoms, and how a **social solution** fixed them.',
      },
      {
        'title': 'Scenario 2: Environmental Hygiene and Health',
        'objective':
            'Compare two playgrounds: One is clean and well-maintained, while the other is polluted and unhygienic. Understand that people living in dirty areas fall sick more often.',
        'board':
            'Comparison of two playgrounds: One is clean and well-maintained, while the other is polluted and unhygienic. People living in dirty areas may fall sick more often. Clean air and water are important for health.',
        'boardBtn': 'Compare Environments',
        'hud': [
          'Step 1: Read the objective.',
          'Step 2: Drag items to build a Clean Playground (Zone A) and Polluted Playground (Zone B).',
          'Step 3: Adjust the sickness frequency sliders based on the environment.',
        ],
        'steps': [
          {
            'concept': 'Surroundings & Hygiene',
            'action':
                'Review the chalkboard to understand how surroundings are a pillar of holistic health.',
            'observation':
                'There is a direct correlation between hygiene, air quality, and disease frequency.',
          },
          {
            'concept': 'The Split View',
            'action':
                'Sort elements to recreate the scenario: Drag Fresh Air/Trees & Clean Fountain to Zone A. Drag Stagnant Water & Garbage Pile to Zone B.',
            'observation':
                'Items are sorted into a Clean Playground (Zone A) and a Polluted Playground (Zone B).',
          },
          {
            'concept': 'Measuring Impact',
            'action':
                "Adjust the 'Sickness Frequency' sliders: Set Zone B to 'High' (> 80%) and Zone A to 'Low' (< 20%), then click 'Verify Impact'.",
            'observation':
                'The system validates that polluted areas equal higher sickness frequency.',
          },
        ],
        'summaryTitle': 'Environment Matters!',
        'summary':
            'You demonstrated that **hygienic surroundings** lead to **lower sickness frequency**.',
      },
      {
        'title': 'Scenario 3: Ayurvedic Balance',
        'objective':
            'Learn about Dinacharya (Daily) and Ritucharya (Seasonal) routines to maintain balance.',
        // The step text promised these definitions on the board.
        'board':
            'Ayurveda teaches that true health is a balance of Body, Mind, and Surroundings. Dinacharya is the daily routine (like waking early and brushing teeth). Ritucharya is the seasonal routine (like warm foods in winter and light clothes in summer).',
        'boardBtn': 'Restore Balance',
        'hud': [
          'Step 1: Read the concept.',
          // Content fix: a weight on the fulcrum cannot level the beam.
          "Step 2: Drag the 'Ayurveda' weight onto the raised pan to balance the scale.",
          'Step 3: Sort the habits into Daily (Dinacharya) or Seasonal (Ritucharya).',
        ],
        'steps': [
          {
            'concept': 'Theory',
            'action':
                'Review the definitions of Dinacharya (Daily) and Ritucharya (Seasonal) on the board.',
            'observation':
                'Ayurveda states that balance is the key to true health.',
          },
          {
            'concept': 'The Balance Scale',
            'action':
                "Drag the 'Ayurveda' weight onto the raised pan of the scale.",
            'observation':
                'Adding weight to the raised side levels the beam: Body and Mind are back in balance with the Surroundings.',
          },
          {
            'concept': 'Routine Sorting',
            'action':
                'Sort the habit cards into the correct Daily (Dinacharya) or Seasonal (Ritucharya) bins.',
            // The source said "warm or light clothes" for the warm-foods card.
            'observation':
                'Waking early and brushing are daily routines; warm foods in winter and light clothes in summer are seasonal adaptations.',
          },
        ],
        'summaryTitle': 'Health Harmony!',
        'summary':
            'You **balanced the scale** and correctly categorized **routines** that maintain holistic health.',
      },
      {
        'title': 'Scenario 4: Good vs. Bad Habits',
        'objective':
            'Filter daily habits into those that promote well-being and those that pose health risks.',
        'board':
            'Challenge 1: Sort these common habits. Which ones should you adopt, and which should you avoid? (e.g., spending too much time on phones).',
        'boardBtn': 'Habit Filter',
        'hud': [
          'Step 1: Read the challenge.',
          "Step 2: Drag habits to the 'Adopt' (Green) or 'Avoid' (Red) bins.",
          'Step 3: Select one good habit and sign your commitment.',
        ],
        'steps': [
          {
            'concept': 'Theory',
            'action':
                'Review habit formation principles discussed on the board.',
            'observation':
                'Habits, like screen time or diet, directly impact long-term health.',
          },
          {
            'concept': 'The Habit Sorter',
            'action':
                "Drag positive habits to the Green 'Adopt' bin and negative habits to the Red 'Avoid' bin.",
            'observation':
                'Screen time and skipping meals are identified as risks; listening and eating on time are positive.',
          },
          {
            'concept': 'The Commitment',
            'action':
                "Select one positive habit from the list and click 'Sign' to make a pledge.",
            'observation':
                'Making a conscious pledge encourages better personal health choices.',
          },
        ],
        'summaryTitle': 'Pledge Signed!',
        'summary':
            'You successfully identified **health risks** and committed to a **positive habit**.',
      },
      {
        'title': 'Scenario 5: The Health Diary',
        'objective':
            'Simulate tracking the 6 pillars of health to understand the value of self-monitoring.',
        'board':
            'Challenge 2: Maintain a health diary for a month tracking: Food, Hygiene, Exercise, Sleep, Screen Time, and Emotion.',
        'boardBtn': 'Log Daily Entry',
        'hud': [
          'Step 1: Read the challenge.',
          "Step 2: Fill in all 6 pillars for 'Day 1' to meet healthy targets.",
          'Step 3: Generate a 30-day trend graph.',
        ],
        'steps': [
          {
            'concept': 'Theory',
            'action': 'Review the 6 pillars of the Health Diary on the board.',
            'observation':
                'Self-monitoring is a practical method to maintain holistic health.',
          },
          {
            'concept': 'Data Entry',
            'action':
                'Log Day 1: Healthy Food, Bathed & Brushed, at least 60 mins of Exercise, 8-10 hrs of Sleep, at most 2 hrs of Screen Time, and how you feel.',
            'observation': 'A healthy day is logged in the diary.',
          },
          {
            'concept': 'Monthly Projection',
            'action':
                "Click 'Generate Trend Graph' to picture repeating this routine for 30 days.",
            'observation':
                'Consistent good habits lead to an upward trend in the overall Health Score (an illustration, not real data).',
          },
        ],
        'summaryTitle': 'Trend Visualized!',
        'summary':
            'You saw how daily tracking of the **6 pillars** leads to **long-term health improvements**.',
      },
    ],
  },
  'hi': {
    'appTitle': 'समग्र स्वास्थ्य: शारीरिक, मानसिक और सामाजिक कल्याण',
    'appSubtitle': 'कक्षा 8. स्वास्थ्य: सबसे बड़ा खज़ाना',
    'enterLab': 'गतिविधि में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'missionObj': 'मुख्य अवधारणा',
    'conceptExp': 'गतिविधि चरण',
    'currObj': 'वर्तमान कार्य',
    'exploration': 'चरण',
    'conceptFocus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'गतिविधि फिर से शुरू करें',
    'scComplete': 'परिदृश्य {n} पूर्ण!',
    'labComplete': 'महारत हासिल!',
    'scenarioDoneHud': 'परिदृश्य {n} पूर्ण! अगले परिदृश्य पर जाएँ।',
    'labDoneHud': 'सभी परिदृश्य पूरे हुए! प्रयोगशाला कभी भी पुनः आरंभ करें।',
    'labControls': 'प्रयोगशाला नियंत्रण',
    'controlsHint':
        '3D दृश्य में वस्तुओं को खींचें या टैप करें, या इन बटनों का उपयोग करें।',
    'ttLabels': 'लेबल दिखाएँ/छिपाएँ',
    'ttLock': 'कैमरा लॉक / अनलॉक',
    'lbl': {
      'rohan': 'रोहन',
      'zoneA': 'ज़ोन A (स्वच्छ)',
      'zoneB': 'ज़ोन B (प्रदूषित)',
      'body': 'शरीर',
      'mind': 'मन',
      'surround': 'परिवेश',
      'diary': 'स्वास्थ्य डायरी',
      'ayurveda': 'आयुर्वेद',
      'counsellor': 'स्कूल परामर्शदाता',
      'friends': 'नए दोस्त',
    },
    'twWeight': 'आयुर्वेद का बाट ऊपर उठे पलड़े पर रखें',
    'dropRohan': 'रोहन पर छोड़ें',
    'dropZone': 'यहाँ छोड़ें',
    'symTitle': 'लक्षण पहचानें',
    'symDesc': 'कहानी में बताए गए लक्षणों को रोहन पर खींचें।',
    'sym': {
      'headache': 'सिरदर्द',
      'weight': 'वज़न कम होना',
      'fever': 'बुखार',
      'insomnia': 'अनिद्रा (रात 3 बजे तक जागना)',
      'screen': 'बहुत अधिक स्क्रीन समय',
      'broken': 'टूटा हुआ पैर',
    },
    'fbFever':
        'बुखार रोहन की कहानी में नहीं है - सिरदर्द, वज़न कम होना, नींद न आना और स्क्रीन समय खोजें।',
    'fbBroken': 'टूटा हुआ पैर एक चोट है, अकेलेपन या तनाव का लक्षण नहीं।',
    'fbUnwell': 'सभी लक्षण पहचाने गए। रोहन अस्वस्थ है।',
    'intTitle': 'समाधान लागू करें',
    'intDesc': 'रोहन की मदद के लिए सामाजिक समाधानों को खींचें।',
    'int': {'counsellor': 'स्कूल परामर्शदाता', 'friends': 'नए दोस्त'},
    'fbCounsellor':
        "परामर्शदाता कहते हैं: 'आओ दोस्तों का एक समूह बनाएँ!' अब नए दोस्त जोड़ें।",
    'fbCounsellorFirst': 'पहले स्कूल परामर्शदाता को रोहन से बात करने दें।',
    'fbHealthy': 'सामाजिक जुड़ाव से शारीरिक स्वास्थ्य बेहतर हुआ!',
    'poorHealth': 'लाल (खराब स्वास्थ्य)',
    'goodHealth': 'हरा (स्वस्थ)',
    'sleep8': '8 घंटे की नींद',
    'phoneOff': 'रात में फ़ोन बंद',
    'sortTitle': 'खेल के मैदान बनाएँ',
    'sortDesc': 'हर वस्तु को ज़ोन A (स्वच्छ) या ज़ोन B (प्रदूषित) पर खींचें।',
    'item': {
      'air': 'ताज़ी हवा / पेड़',
      'fountain': 'स्वच्छ फव्वारा',
      'water': 'रुका हुआ पानी',
      'garbage': 'कचरे का ढेर',
    },
    'fbKeepClean': 'स्वच्छ क्षेत्र को साफ़-सुथरा रखें।',
    'fbCleanItem':
        'ताज़ी हवा और स्वच्छ फव्वारा स्वच्छ खेल के मैदान में रहते हैं।',
    'fbSorted': 'वातावरण छाँट दिए गए।',
    'sickTitle': 'बीमारी की आवृत्ति',
    'zoneA': 'ज़ोन A (स्वच्छ)',
    'zoneB': 'ज़ोन B (प्रदूषित)',
    'targetLow': 'लक्ष्य: कम (< 20%)',
    'targetHigh': 'लक्ष्य: अधिक (> 80%)',
    'verify': 'प्रभाव जाँचें',
    'fbSickWrong':
        'प्रदूषित क्षेत्रों में बीमारी अधिक (>80%) होती है। स्वच्छ क्षेत्रों में कम (<20%)। स्लाइडर ठीक करें।',
    'fbSickOk': 'गंदा परिवेश = अधिक बीमारी।',
    'fbPivot':
        'धुरी पर रखा बाट डंडी को नहीं घुमा सकता - इसे ऊपर उठे पलड़े पर रखें।',
    'fbLowPan': 'वह पलड़ा पहले से नीचे है - बाट ऊपर उठे पलड़े पर रखें।',
    'fbWeightMiss': 'आयुर्वेद का बाट किसी पलड़े पर छोड़ें।',
    'fbBalanced': 'संतुलन फिर से स्थापित!',
    'routineTitle': 'दिनचर्याएँ छाँटें',
    'bin': {'dina': 'दिनचर्या (दैनिक)', 'ritu': 'ऋतुचर्या (मौसमी)'},
    'habit': {
      'wake': 'सूर्योदय से पहले उठना',
      'brush': 'दाँत साफ़ करना',
      'warm': 'सर्दियों में गर्म भोजन',
      'light': 'गर्मियों में हल्के कपड़े',
    },
    'fbRoutineWrong':
        'दैनिक आदतें रोज़ दोहराई जाती हैं; मौसमी आदतें मौसम के साथ बदलती हैं।',
    'habitTitle': 'आदत छाँटें',
    'adopt': 'बड़ों की सलाह (अपनाएँ)',
    'avoid': 'स्वास्थ्य जोखिम (बचें)',
    'hb': {
      'listen': 'शिक्षकों की बात सुनना',
      'eat': 'समय पर भोजन करना',
      'mobile': 'मोबाइल पर 4 घंटे से अधिक बिताना',
      'skip': 'नाश्ता छोड़ना',
    },
    'fbHabitWrong': 'फिर सोचें: यह आदत स्वास्थ्य की मदद करती है या नुकसान?',
    'pledgeTitle': 'मेरा संकल्प',
    'pledgeQ': 'अपनाने के लिए एक अच्छी आदत चुनें:',
    'signHint': 'संकल्प के लिए नीचे हस्ताक्षर करें',
    'sign': 'हस्ताक्षर करें',
    'fbPledge': 'संकल्प पर हस्ताक्षर हुए: मैं {habit} शुरू करूँगा/करूँगी!',
    'fbPickHabit': 'कृपया पहले एक आदत चुनें।',
    'diaryTitle': 'मेरी स्वास्थ्य डायरी',
    'day1': 'दिन 1',
    'pillar': {
      'food': 'भोजन',
      'hygiene': 'स्वच्छता',
      'exercise': 'व्यायाम',
      'sleep': 'नींद',
      'screen': 'स्क्रीन समय',
      'emotion': 'भावना',
    },
    'healthy': 'स्वस्थ',
    'junk': 'जंक',
    'bathed': 'नहाया और ब्रश किया',
    'unset': 'खाली',
    'done': 'हो गया',
    'mins': '{v} मिनट',
    'hrs': '{v} घंटे',
    'tExercise': 'लक्ष्य: 60 मिनट या अधिक',
    'tSleep': 'लक्ष्य: 8-10 घंटे',
    'tScreen': 'लक्ष्य: 2 घंटे या कम',
    'emo': {
      'happy': 'खुश',
      'neutral': 'सामान्य',
      'sad': 'उदास',
      'angry': 'गुस्सा',
    },
    'emoNote': 'कोई भी भावना लिखी जा सकती है - उसे पहचानना ही ज़रूरी है।',
    'completeDay': 'दिन 1 पूरा करें',
    'fbFillAll': 'दिन दर्ज करने के लिए सभी 6 स्तंभ भरें।',
    'fbTargets':
        'लक्ष्य देखें! स्वस्थ भोजन, नहाना और ब्रश करना, कम से कम 60 मिनट व्यायाम, 8-10 घंटे नींद और अधिकतम 2 घंटे स्क्रीन समय।',
    'fbLogged': 'दिन 1 दर्ज हो गया!',
    'projTitle': 'मासिक अनुमान',
    'projDesc': 'मान लीजिए आप 30 दिनों तक दिन 1 की आदतें दोहराते हैं...',
    'calDays': ['र', 'सो', 'मं', 'बु', 'गु', 'शु', 'श'],
    'generate': 'रुझान ग्राफ़ बनाएँ',
    'healthScore': 'स्वास्थ्य स्कोर',
    'time30': 'समय (30 दिन)',
    'illustrative': 'उदाहरण के लिए रुझान - वास्तविक डेटा नहीं',
    'scenarios': [
      {
        'title': 'परिदृश्य 1: सामाजिक अलगाव का प्रभाव',
        'objective':
            'मन और शरीर के संबंध को समझें और जानें कि सामाजिक कारक शारीरिक लक्षणों को कैसे प्रभावित करते हैं।',
        'board':
            'रोहन नाम का एक छात्र नए स्कूल में आया। कोई दोस्त न होने से वह अकेला महसूस करता था। वह घंटों फ़ोन पर रहता, उसे सिरदर्द होता, उसका वज़न कम हो गया और उसे नींद नहीं आती थी। स्कूल परामर्शदाता ने उसे नए दोस्त बनाने में मदद की।',
        'boardBtn': 'केस अध्ययन का विश्लेषण करें',
        'hud': [
          'चरण 1: केस अध्ययन पढ़ें।',
          'चरण 2: खास लक्षणों को रोहन पर खींचें।',
          'चरण 3: सामाजिक समाधान लागू करें: पहले स्कूल परामर्शदाता, फिर नए दोस्त।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत',
            'action':
                'चॉकबोर्ड पढ़कर समझें कि सामाजिक अलगाव शारीरिक स्वास्थ्य को कैसे प्रभावित करता है।',
            'observation':
                'सामाजिक कारण (अकेलापन) मानसिक तनाव पैदा करते हैं, जो शारीरिक लक्षणों के रूप में दिखता है।',
          },
          {
            'concept': 'लक्षणों की पहचान',
            'action':
                'खास लक्षणों (सिरदर्द, वज़न कम होना, अनिद्रा, स्क्रीन समय) को रोहन पर खींचें।',
            'observation':
                'ये लक्षण रोहन की हालत के विवरण से मेल खाते हैं और उसका स्वास्थ्य गिरता है (लाल हो जाता है)।',
          },
          {
            'concept': 'समाधान',
            'action':
                "शारीरिक समस्याओं के सामाजिक समाधान के लिए पहले 'स्कूल परामर्शदाता' और फिर 'नए दोस्त' को रोहन पर खींचें।",
            'observation':
                'दोस्तों का समूह बनने से मानसिक तनाव दूर होता है और शारीरिक लक्षण सुधरते हैं (हरा हो जाता है)।',
          },
        ],
        'summaryTitle': 'संबंध समझ में आया!',
        'summary':
            'आपने देखा कि एक **सामाजिक समस्या (अकेलापन)** से शारीरिक लक्षण कैसे हुए, और एक **सामाजिक समाधान** ने उन्हें कैसे ठीक किया।',
      },
      {
        'title': 'परिदृश्य 2: पर्यावरणीय स्वच्छता और स्वास्थ्य',
        'objective':
            'दो खेल के मैदानों की तुलना करें: एक स्वच्छ और सुव्यवस्थित है, दूसरा प्रदूषित और गंदा। समझें कि गंदे क्षेत्रों में रहने वाले लोग अधिक बीमार पड़ते हैं।',
        'board':
            'दो खेल के मैदानों की तुलना: एक स्वच्छ और सुव्यवस्थित है, दूसरा प्रदूषित और गंदा। गंदे क्षेत्रों में रहने वाले लोग अधिक बार बीमार पड़ सकते हैं। स्वच्छ हवा और पानी स्वास्थ्य के लिए ज़रूरी हैं।',
        'boardBtn': 'वातावरणों की तुलना करें',
        'hud': [
          'चरण 1: उद्देश्य पढ़ें।',
          'चरण 2: वस्तुओं को खींचकर स्वच्छ खेल का मैदान (ज़ोन A) और प्रदूषित खेल का मैदान (ज़ोन B) बनाएँ।',
          'चरण 3: वातावरण के अनुसार बीमारी की आवृत्ति के स्लाइडर ठीक करें।',
        ],
        'steps': [
          {
            'concept': 'परिवेश और स्वच्छता',
            'action':
                'चॉकबोर्ड पढ़कर समझें कि परिवेश समग्र स्वास्थ्य का एक स्तंभ है।',
            'observation':
                'स्वच्छता, हवा की गुणवत्ता और बीमारी की आवृत्ति में सीधा संबंध है।',
          },
          {
            'concept': 'दो हिस्सों वाला दृश्य',
            'action':
                'स्थिति बनाने के लिए वस्तुएँ छाँटें: ताज़ी हवा/पेड़ और स्वच्छ फव्वारा ज़ोन A में; रुका हुआ पानी और कचरे का ढेर ज़ोन B में खींचें।',
            'observation':
                'वस्तुएँ स्वच्छ खेल के मैदान (ज़ोन A) और प्रदूषित खेल के मैदान (ज़ोन B) में बँट गईं।',
          },
          {
            'concept': 'प्रभाव मापना',
            'action':
                "'बीमारी की आवृत्ति' स्लाइडर ठीक करें: ज़ोन B को 'अधिक' (> 80%) और ज़ोन A को 'कम' (< 20%) करें, फिर 'प्रभाव जाँचें' पर क्लिक करें।",
            'observation':
                'प्रणाली पुष्टि करती है कि प्रदूषित क्षेत्रों में बीमारी अधिक होती है।',
          },
        ],
        'summaryTitle': 'वातावरण मायने रखता है!',
        'summary': 'आपने दिखाया कि **स्वच्छ परिवेश** से **बीमारी कम** होती है।',
      },
      {
        'title': 'परिदृश्य 3: आयुर्वेदिक संतुलन',
        'objective':
            'संतुलन बनाए रखने के लिए दिनचर्या (दैनिक) और ऋतुचर्या (मौसमी) के बारे में जानें।',
        'board':
            'आयुर्वेद सिखाता है कि सच्चा स्वास्थ्य शरीर, मन और परिवेश का संतुलन है। दिनचर्या रोज़ की आदतें हैं (जैसे जल्दी उठना और दाँत साफ़ करना)। ऋतुचर्या मौसम के अनुसार आदतें हैं (जैसे सर्दियों में गर्म भोजन और गर्मियों में हल्के कपड़े)।',
        'boardBtn': 'संतुलन लौटाएँ',
        'hud': [
          'चरण 1: अवधारणा पढ़ें।',
          "चरण 2: तराज़ू को संतुलित करने के लिए 'आयुर्वेद' बाट को ऊपर उठे पलड़े पर खींचें।",
          'चरण 3: आदतों को दैनिक (दिनचर्या) या मौसमी (ऋतुचर्या) में छाँटें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत',
            'action':
                'बोर्ड पर दिनचर्या (दैनिक) और ऋतुचर्या (मौसमी) की परिभाषाएँ पढ़ें।',
            'observation':
                'आयुर्वेद के अनुसार संतुलन ही सच्चे स्वास्थ्य की कुंजी है।',
          },
          {
            'concept': 'संतुलन तराज़ू',
            'action': "'आयुर्वेद' बाट को तराज़ू के ऊपर उठे पलड़े पर खींचें।",
            'observation':
                'ऊपर उठी ओर वज़न रखने से डंडी सीधी हो जाती है: शरीर और मन फिर से परिवेश के साथ संतुलन में आ जाते हैं।',
          },
          {
            'concept': 'दिनचर्या छाँटना',
            'action':
                'आदत कार्डों को सही दैनिक (दिनचर्या) या मौसमी (ऋतुचर्या) डिब्बों में छाँटें।',
            'observation':
                'जल्दी उठना और दाँत साफ़ करना दैनिक दिनचर्या है; सर्दियों में गर्म भोजन और गर्मियों में हल्के कपड़े मौसमी बदलाव हैं।',
          },
        ],
        'summaryTitle': 'स्वास्थ्य में सामंजस्य!',
        'summary':
            'आपने **तराज़ू संतुलित** किया और समग्र स्वास्थ्य बनाए रखने वाली **दिनचर्याओं** को सही वर्गों में बाँटा।',
      },
      {
        'title': 'परिदृश्य 4: अच्छी बनाम बुरी आदतें',
        'objective':
            'रोज़ की आदतों को कल्याण बढ़ाने वाली और स्वास्थ्य जोखिम वाली आदतों में छाँटें।',
        'board':
            'चुनौती 1: इन आम आदतों को छाँटें। कौन-सी अपनानी चाहिए और किनसे बचना चाहिए? (जैसे फ़ोन पर बहुत अधिक समय बिताना)।',
        'boardBtn': 'आदत छाँटें',
        'hud': [
          'चरण 1: चुनौती पढ़ें।',
          "चरण 2: आदतों को 'अपनाएँ' (हरा) या 'बचें' (लाल) डिब्बों में खींचें।",
          'चरण 3: एक अच्छी आदत चुनें और अपने संकल्प पर हस्ताक्षर करें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत',
            'action': 'बोर्ड पर आदतें बनने के सिद्धांत पढ़ें।',
            'observation':
                'स्क्रीन समय या आहार जैसी आदतें लंबे समय के स्वास्थ्य पर सीधा असर डालती हैं।',
          },
          {
            'concept': 'आदत छँटाई',
            'action':
                "अच्छी आदतों को हरे 'अपनाएँ' डिब्बे में और बुरी आदतों को लाल 'बचें' डिब्बे में खींचें।",
            'observation':
                'स्क्रीन समय और भोजन छोड़ना जोखिम हैं; शिक्षकों की बात सुनना और समय पर खाना अच्छी आदतें हैं।',
          },
          {
            'concept': 'संकल्प',
            'action':
                "सूची से एक अच्छी आदत चुनें और संकल्प लेने के लिए 'हस्ताक्षर करें' पर क्लिक करें।",
            'observation':
                'सोच-समझकर लिया गया संकल्प बेहतर स्वास्थ्य विकल्पों को बढ़ावा देता है।',
          },
        ],
        'summaryTitle': 'संकल्प पर हस्ताक्षर!',
        'summary':
            'आपने **स्वास्थ्य जोखिमों** को पहचाना और एक **अच्छी आदत** अपनाने का संकल्प लिया।',
      },
      {
        'title': 'परिदृश्य 5: स्वास्थ्य डायरी',
        'objective':
            'स्वास्थ्य के 6 स्तंभों पर नज़र रखकर स्व-निगरानी का महत्व समझें।',
        'board':
            'चुनौती 2: एक महीने तक स्वास्थ्य डायरी रखें और इन पर नज़र रखें: भोजन, स्वच्छता, व्यायाम, नींद, स्क्रीन समय और भावना।',
        'boardBtn': 'दैनिक प्रविष्टि लिखें',
        'hud': [
          'चरण 1: चुनौती पढ़ें।',
          "चरण 2: स्वस्थ लक्ष्यों के अनुसार 'दिन 1' के सभी 6 स्तंभ भरें।",
          'चरण 3: 30 दिनों का रुझान ग्राफ़ बनाएँ।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत',
            'action': 'बोर्ड पर स्वास्थ्य डायरी के 6 स्तंभ पढ़ें।',
            'observation':
                'स्व-निगरानी समग्र स्वास्थ्य बनाए रखने का व्यावहारिक तरीका है।',
          },
          {
            'concept': 'डेटा प्रविष्टि',
            'action':
                'दिन 1 दर्ज करें: स्वस्थ भोजन, नहाना और ब्रश करना, कम से कम 60 मिनट व्यायाम, 8-10 घंटे नींद, अधिकतम 2 घंटे स्क्रीन समय, और आप कैसा महसूस करते हैं।',
            'observation': 'एक स्वस्थ दिन डायरी में दर्ज हो गया।',
          },
          {
            'concept': 'मासिक अनुमान',
            'action':
                "30 दिनों तक यही दिनचर्या दोहराने की कल्पना के लिए 'रुझान ग्राफ़ बनाएँ' पर क्लिक करें।",
            'observation':
                'लगातार अच्छी आदतों से कुल स्वास्थ्य स्कोर में ऊपर की ओर रुझान आता है (यह एक उदाहरण है, वास्तविक डेटा नहीं)।',
          },
        ],
        'summaryTitle': 'रुझान दिखाई दिया!',
        'summary':
            'आपने देखा कि **6 स्तंभों** पर रोज़ नज़र रखने से **लंबे समय तक स्वास्थ्य सुधरता** है।',
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.blue500;
const Color _accentSoft = Color(0xFF93C5FD); // blue-300

/// Steps per scenario (step 1 is always the chalkboard).
const List<int> _stepCounts = [3, 3, 3, 3, 3];

/// S1 symptoms: id -> in Rohan's story (fixed, mixed order).
const Map<String, bool> _symptoms = {
  'headache': true,
  'fever': false,
  'weight': true,
  'insomnia': true,
  'broken': false,
  'screen': true,
};

/// S2 items: id -> zone ('A' clean, 'B' polluted), fixed mixed order.
const Map<String, String> _items = {
  'water': 'B',
  'air': 'A',
  'garbage': 'B',
  'fountain': 'A',
};

/// S3 routines: id -> bin; S4 habits: id -> bin.
const Map<String, String> _routines = {
  'warm': 'ritu',
  'wake': 'dina',
  'light': 'ritu',
  'brush': 'dina',
};
const Map<String, String> _habits = {
  'mobile': 'avoid',
  'listen': 'adopt',
  'skip': 'avoid',
  'eat': 'adopt',
};
const Map<String, IconData> _habitIcons = {
  'listen': Icons.hearing,
  'eat': Icons.schedule,
  'mobile': Icons.phone_android,
  'skip': Icons.no_meals, // the source's icon showed bacon
};

/// S3 balance: pivot height, half beam length, starting tilt.
const double _pivotY = 1.2, _halfBeam = 6.0, _tilt = math.pi / 10;

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
        Color(0xFF3B82F6),
        Color(0xFF10B981),
        Color(0xFFFACC15),
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

class Cl8Ch13A1HolisticHealthPage extends StatefulWidget {
  const Cl8Ch13A1HolisticHealthPage({super.key});

  @override
  State<Cl8Ch13A1HolisticHealthPage> createState() =>
      _Cl8Ch13A1HolisticHealthPageState();
}

class _Cl8Ch13A1HolisticHealthPageState
    extends State<Cl8Ch13A1HolisticHealthPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF172554), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 5, 15),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  math.Random _rng = math.Random(131);
  final _rt_Node3D _root = _rt_Node3D(name: 'scenario-root');
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);
  final ValueNotifier<double> _trendT = ValueNotifier(0); // S5 graph
  final List<_rt_Label3D> _labels = [];

  // Scenario objects (rebuilt on every scenario change). Draggable objects
  // are kept by id in [_objects].
  final Map<String, _rt_Node3D> _objects = {};
  _rt_Material3D? _rohanMat; // S1
  _rt_Node3D? _counsellor;
  final List<_rt_Node3D> _friends = [];
  final Map<String, _rt_Node3D> _zoneProps = {}; // S2
  _rt_Node3D? _beam; // S3
  _rt_Node3D? _leftPan;
  _rt_Node3D? _rightPan;
  _rt_Line3D? _strings;
  final Map<String, _rt_Label3D> _diaryLabels = {}; // S5

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

  final List<String> _foundSymptoms = []; // S1
  bool _counselled = false;
  bool _befriended = false;
  final Map<String, String> _placedItems = {}; // S2 item -> zone
  double _sickA = 50;
  double _sickB = 50;
  bool _verified = false;
  bool _balanced = false; // S3
  final Map<String, String> _sorted = {}; // S3/S4 card -> bin
  String? _pledge; // S4
  bool _signed = false;
  String? _food; // S5
  bool _hygiene = false;
  double _exercise = 0;
  double _sleep = 4;
  double _screen = 0;
  String? _emotion;
  bool _logged = false;
  bool _trendDone = false;
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

  /// Full-screen 2D boards: no 3D toolbar.
  bool get _panelMode => switch ((_scenario, _step)) {
    (3, 3) || (4, > 1) || (5, 3) => true,
    _ => false,
  };

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
      ..maxDistance = 60
      ..maxPolarAngle = math.pi * 0.47;
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.7),
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
    _trendT.dispose();
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
  _rt_Label3D _label(String key, double x, double y, double z, {String? tkey}) {
    final path = tkey ?? 'lbl.$key';
    final label =
        _rt_Label3D(
            _tx.s(path),
            position: _rt_V3(x, y, z),
            pixelHeight: 12,
            color: Colors.white,
            background: const Color(0xE6000000),
            borderColor: Colors.white,
          )
          ..pickable = false
          ..visible = _labelsOn;
    label.userData['key'] = key;
    label.userData['tkey'] = path;
    _labels.add(label);
    return label;
  }

  /// A label whose text the code sets (diary entries).
  _rt_Label3D _rawLabel(double x, double y, double z) {
    final label = _rt_Label3D(
      '',
      position: _rt_V3(x, y, z),
      pixelHeight: 12,
      color: const Color(0xFF0F172A),
      background: const Color(0xF2F8FAFC),
      borderColor: _accent,
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
    _updateDiaryLabels();
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

  Future<void> _grow(_rt_Node3D n, {int ms = 500, double to = 1}) {
    n.visible = true;
    return _tweens.run(ms, (t) {
      final s = 0.01 + (to - 0.01) * t;
      n.scale.set(s, s, s);
    }, ease: _rt_Ease.outBack);
  }

  /// A simple standing figure in one material (feet at the origin, about
  /// 6.8 units tall).
  _rt_Node3D _figure(_rt_Material3D mat) {
    final person = _rt_Node3D();
    _rt_Mesh3D part(_rt_Geometry3D g) => _rt_Mesh3D(g, mat);
    for (final side in const [-1.0, 1.0]) {
      person
        ..add(
          part(_rt_Geometry3D.cylinder(0.32, 0.28, 2.8, segments: 12))
            ..position.set(0.4 * side, 1.4, 0),
        )
        ..add(
          part(_rt_Geometry3D.cylinder(0.26, 0.22, 2.6, segments: 10))
            ..position.set(1.15 * side, 3.6, 0)
            ..rotation.z = 0.15 * side,
        );
    }
    person
      ..add(
        part(_rt_Geometry3D.cylinder(0.95, 0.85, 2.6, segments: 18))
          ..position.y = 4.0
          ..scale.set(1, 1, 0.6),
      )
      ..add(_rt_Sphere3D(0.75, mat)..position.y = 6.0);
    return person;
  }

  _rt_Node3D _tree(double scale) {
    final t = _rt_Node3D()..scale.set(scale, scale, scale);
    t
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.2, 0.3, 1.5, segments: 8),
          const Color(0xFF78350F),
        )..position.y = 0.75,
      )
      ..add(_ball(1.2, const Color(0xFF22C55E))..position.y = 2.1)
      ..add(_ball(0.8, const Color(0xFF16A34A))..position.set(0.6, 1.6, 0.5))
      ..add(_ball(0.9, const Color(0xFF15803D))..position.set(-0.5, 1.8, -0.5));
    return t;
  }

  _rt_Node3D _deadTree(double scale) {
    final t = _rt_Node3D()..scale.set(scale, scale, scale);
    t
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.15, 0.25, 2.0, segments: 8),
          const Color(0xFF3F3F46),
        )..position.y = 1.0,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.05, 0.1, 1.0, segments: 6),
            const Color(0xFF3F3F46),
          )
          ..position.set(0.4, 1.6, 0)
          ..rotation.z = -math.pi / 4,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.05, 0.1, 0.8, segments: 6),
            const Color(0xFF3F3F46),
          )
          ..position.set(-0.3, 1.3, 0.3)
          ..rotation.z = math.pi / 3,
      );
    return t;
  }

  // ---------------------------------------------------------- scenes ---
  void _buildScenario() {
    _root.clear();
    _labels.clear();
    _objects.clear();
    _friends.clear();
    _zoneProps.clear();
    _diaryLabels.clear();
    _rohanMat = null;
    _counsellor = _beam = _leftPan = _rightPan = null;
    _strings = null;
    _rng = math.Random(131 + _scenario); // fixed layout every visit
    switch (_scenario) {
      case 1:
        _buildRohan();
      case 2:
        _buildPlaygrounds();
      case 3:
        _buildBalance();
      case 5:
        _buildClipboard();
    }
    _syncLabels();
  }

  /// S1: Rohan (the source's figure was invisible) and, later, the
  /// counsellor and two new friends.
  void _buildRohan() {
    _root.add(
      _mesh(_rt_Geometry3D.box(16, 0.2, 9), const Color(0xFF1E293B))
        ..position.set(0, -3.6, 0)
        ..depthBias = 40,
    );
    final mat = _rt_Material3D(color: const Color(0xFF94A3B8), shininess: 0.3);
    _rohanMat = mat;
    final rohan = _figure(mat)..position.set(0, -3.5, 0);
    final counsellor =
        _figure(_rt_Material3D(color: const Color(0xFF0EA5E9), shininess: 0.3))
          ..position.set(-6.0, -3.5, -0.6)
          ..rotation.y = 0.5
          ..scale.set(0.01, 0.01, 0.01)
          ..visible = false;
    counsellor.add(_label('counsellor', 0, 7.6, 0));
    _counsellor = counsellor;
    for (final (x, z, c) in const [
      (3.2, 1.4, Color(0xFFF59E0B)),
      (6.2, -0.4, Color(0xFFA855F7)),
    ]) {
      final f = _figure(_rt_Material3D(color: c, shininess: 0.3))
        ..position.set(x, -3.5, z)
        ..rotation.y = -0.45
        ..scale.set(0.01, 0.01, 0.01)
        ..visible = false;
      _friends.add(f);
      _root.add(f);
    }
    final friendsLabel = _label('friends', 4.7, 3.6, 0.5)
      ..userData['hidden'] = true;
    _root
      ..add(rohan)
      ..add(counsellor)
      ..add(friendsLabel)
      ..add(_label('rohan', 0, 4.3, 0));
  }

  /// S2: Zone A (grass) and Zone B (mud) with seeded scenery; the four
  /// sorted items appear in their zone.
  void _buildPlaygrounds() {
    _root
      ..add(
        _mesh(_rt_Geometry3D.box(10, 0.2, 10), const Color(0xFF4ADE80))
          ..position.set(-5.25, -3.6, 0)
          ..depthBias = 40,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(10, 0.2, 10), const Color(0xFF5C4033))
          ..position.set(5.25, -3.6, 0)
          ..depthBias = 40,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.5, 0.21, 10), const Color(0xFFD4D4D8))
          ..position.set(0, -3.59, 0)
          ..depthBias = 35,
      )
      ..add(_label('zoneA', -5.25, 0.2, -4.6))
      ..add(_label('zoneB', 5.25, 0.2, -4.6));
    // Slide A (good) and the broken slide B.
    final slideA = _rt_Node3D()..position.set(-6.5, -3.5, 1.5);
    slideA
      ..add(
        _mesh(_rt_Geometry3D.box(0.8, 2, 0.2), const Color(0xFFFACC15))
          ..position.y = 1,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.6, 2.5, 0.1), const Color(0xFFEF4444))
          ..position.set(1, 1, 0)
          ..rotation.z = -math.pi / 4,
      );
    final slideB = _rt_Node3D()..position.set(3.0, -3.5, 1.0);
    slideB
      ..add(
        _mesh(_rt_Geometry3D.box(0.8, 2, 0.2), const Color(0xFF52525B))
          ..position.set(1, 0.2, 0)
          ..rotation.z = math.pi / 2.2,
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.6, 2.5, 0.1), const Color(0xFF3F3F46))
          ..position.set(2.5, 0.1, 0)
          ..rotation.z = math.pi / 2.1,
      );
    _root
      ..add(slideA)
      ..add(slideB)
      ..add(_deadTree(1.2)..position.set(8.0, -3.5, -2.6));
    for (var i = 0; i < 6; i++) {
      _root.add(
        _ball(0.3, const Color(0xFF22C55E))
          ..position.set(
            -9.5 + _rng.nextDouble() * 8,
            -3.25,
            -4 + _rng.nextDouble() * 8,
          ),
      );
    }
    // Items that appear when sorted.
    final trees = _rt_Node3D()..visible = false;
    trees
      ..add(_tree(1.2)..position.set(-8.0, -3.5, -2.2))
      ..add(_tree(0.8)..position.set(-3.6, -3.5, -3.2));
    final fountain = _rt_Node3D()
      ..position.set(-2.8, -3.5, 2.4)
      ..visible = false;
    fountain
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.8, 0.8, 0.4, segments: 20),
          const Color(0xFF94A3B8),
        )..position.y = 0.2,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.7, 0.7, 0.45, segments: 20),
          const Color(0xFF3B82F6),
          opacity: 0.85,
        )..position.y = 0.25,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.1, 0.1, 1.0, segments: 8),
          const Color(0xFF94A3B8),
        )..position.y = 0.9,
      )
      ..add(_ball(0.18, const Color(0xFF93C5FD))..position.y = 1.5);
    final puddles = _rt_Node3D()..visible = false;
    puddles
      ..add(
        _mesh(
            _rt_Geometry3D.circle(1.4, segments: 20),
            const Color(0xFF65A30D),
            opacity: 0.75,
            doubleSided: true,
          )
          ..position.set(6.0, -3.47, 2.0)
          ..rotation.x = -math.pi / 2
          ..scale.set(1.3, 1, 1)
          ..depthBias = 20,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.circle(1.0, segments: 20),
            const Color(0xFF854D0E),
            opacity: 0.85,
            doubleSided: true,
          )
          ..position.set(3.5, -3.47, -1.2)
          ..rotation.x = -math.pi / 2
          ..depthBias = 20,
      );
    final garbage = _rt_Node3D()..visible = false;
    for (var i = 0; i < 14; i++) {
      final kind = _rng.nextInt(3);
      final p = _rt_V3(
        6.5 + (_rng.nextDouble() - 0.5) * 3.2,
        -3.3,
        -2.8 + (_rng.nextDouble() - 0.5) * 2.4,
      );
      garbage.add(
        kind == 0
            ? (_mesh(_rt_Geometry3D.icosahedron(0.3), const Color(0xFF1E293B))
                ..position.copy(p))
            : (_mesh(
                  _rt_Geometry3D.box(0.4, 0.4, 0.4),
                  kind == 1 ? const Color(0xFFEF4444) : const Color(0xFFFACC15),
                )
                ..position.copy(p)
                ..rotation.set(
                  _rng.nextDouble(),
                  _rng.nextDouble(),
                  _rng.nextDouble(),
                )),
      );
    }
    _zoneProps
      ..['air'] = trees
      ..['fountain'] = fountain
      ..['water'] = puddles
      ..['garbage'] = garbage;
    _root
      ..add(trees)
      ..add(fountain)
      ..add(puddles)
      ..add(garbage);
  }

  /// S3: brass balance with Body and Mind pans hanging from the beam, the
  /// Surroundings above, and the Ayurveda weight.
  void _buildBalance() {
    const wood = Color(0xFF5C4033), brass = Color(0xFFD4AF37);
    _root
      ..add(
        _mesh(_rt_Geometry3D.box(20, 0.6, 9), const Color(0xFF3F2A1E))
          ..position.set(0, -4.5, 0.5)
          ..depthBias = 40,
      )
      ..add(
        _mesh(_rt_Geometry3D.cylinder(3, 3.5, 0.4, segments: 24), wood)
          ..position.y = -4.0,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(2, 2.5, 0.4, segments: 24),
          brass,
          shininess: 0.7,
        )..position.y = -3.6,
      )
      ..add(
        _mesh(_rt_Geometry3D.cylinder(0.4, 0.6, 4.6, segments: 14), wood)
          ..position.y = -1.1,
      )
      ..add(_ball(0.6, brass)..position.y = _pivotY)
      ..add(_label('surround', 0, _pivotY + 3.0, 0));
    final beam = _rt_Node3D()..position.y = _pivotY;
    beam
      ..add(_mesh(_rt_Geometry3D.box(2 * _halfBeam, 0.4, 1.0), wood))
      ..add(
        _mesh(
          _rt_Geometry3D.box(2 * _halfBeam + 0.2, 0.15, 1.2),
          brass,
          shininess: 0.7,
        )..position.y = 0.25,
      );
    _beam = beam;
    _rt_Node3D pan(String key) => _rt_Node3D()
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(1.8, 1.1, 0.6, segments: 24),
          brass,
          shininess: 0.7,
        )..position.y = 0.3,
      )
      ..add(_label(key, 0, 1.8, 0));
    final left = pan('body');
    final right = pan('mind');
    _leftPan = left;
    _rightPan = right;
    final strings = _rt_Line3D(
      [],
      color: const Color(0xFFCBD5E1),
      width: 1.5,
      segments: true,
    );
    _strings = strings;
    _root
      ..add(beam)
      ..add(left)
      ..add(right)
      ..add(strings);
    _setBeam(_tilt);
    // The Ayurveda weight on the table front.
    final weight = _rt_Node3D(name: 'weight')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.75, 0.85, 0.9, segments: 20),
          const Color(0xFFF97316),
          shininess: 0.5,
        )..position.y = 0.45,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.torus(
              0.25,
              0.08,
              radialSegments: 6,
              tubularSegments: 14,
            ),
            const Color(0xFFFED7AA),
          )
          ..position.y = 1.05
          ..rotation.x = math.pi / 2,
      )
      ..add(_proxy(_rt_Geometry3D.sphere(1.1))..position.y = 0.5)
      ..add(_label('ayurveda', 0, 1.9, 0));
    _setHome(weight, 4.8, -4.2, 3.4);
    _root.add(_draggable('weight', weight));
  }

  /// Beam angle (positive: the Body side is down) and pans hanging below
  /// the ends (the source's cups were fixed to the beam).
  void _setBeam(double theta) {
    final beam = _beam;
    if (beam == null) return;
    beam.rotation.z = theta;
    final c = math.cos(theta), s = math.sin(theta);
    final pivot = beam.position;
    final l = pivot + _rt_V3(-_halfBeam * c, -_halfBeam * s, 0);
    final r = pivot + _rt_V3(_halfBeam * c, _halfBeam * s, 0);
    final hang = _rt_V3(0, -2.6, 0);
    _leftPan?.position.copy(l + hang);
    _rightPan?.position.copy(r + hang);
    _strings?.points = [
      for (final end in [l, r]) ...[
        end,
        end + hang + _rt_V3(-1.4, 0.6, 0),
        end,
        end + hang + _rt_V3(1.4, 0.6, 0),
      ],
    ];
  }

  /// S5: the diary as a clipboard; the entries mirror the panel.
  void _buildClipboard() {
    final board = _rt_Node3D()
      ..position.set(0, 0.6, 0)
      ..rotation.x = -math.pi / 7;
    board
      ..add(
        _mesh(_rt_Geometry3D.box(8, 10, 0.25), const Color(0xFF8B4513))
          ..depthBias = 10,
      )
      ..add(
        _mesh(_rt_Geometry3D.plane(7.2, 9.0), const Color(0xFFF8FAFC))
          ..position.set(0, -0.3, 0.14)
          ..depthBias = 5,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.box(3, 1, 0.4),
          const Color(0xFFCBD5E1),
          shininess: 0.8,
        )..position.set(0, 4.8, 0.15),
      );
    for (var i = 0; i < 9; i++) {
      board.add(
        _rt_Line3D(
          [
            _rt_V3(-3.3, 3.2 - i * 0.85, 0.16),
            _rt_V3(3.3, 3.2 - i * 0.85, 0.16),
          ],
          color: const Color(0xFFBFDBFE),
          width: 1,
        ),
      );
    }
    _root
      ..add(board)
      ..add(_label('diary', 0, 7.0, -1.5));
    const pillars = [
      'food',
      'hygiene',
      'exercise',
      'sleep',
      'screen',
      'emotion',
    ];
    for (final (i, p) in pillars.indexed) {
      // Points on the tilted paper (rotation about x).
      final y = 3.0 - i * 1.25, a = -math.pi / 7;
      final label = _rawLabel(0, 0.6 + y * math.cos(a), y * math.sin(a) + 0.4);
      _diaryLabels[p] = label;
      _root.add(label);
    }
  }

  /// Diary entries on the clipboard.
  void _updateDiaryLabels() {
    if (_diaryLabels.isEmpty) return;
    String v(String pillar) => switch (pillar) {
      'food' => _food == null ? _tx.s('unset') : _tx.s(_food!),
      'hygiene' => _hygiene ? _tx.s('done') : _tx.s('unset'),
      'exercise' => _tx.s('mins').replaceAll('{v}', '${_exercise.round()}'),
      'sleep' => _tx.s('hrs').replaceAll('{v}', _num(_sleep)),
      'screen' => _tx.s('hrs').replaceAll('{v}', _num(_screen)),
      _ => _emotion == null ? _tx.s('unset') : _tx.s('emo.$_emotion'),
    };
    for (final MapEntry(key: p, value: label) in _diaryLabels.entries) {
      label.text = '${_tx.s('pillar.$p')}: ${v(p)}';
    }
  }

  /// 7.5 -> "7.5", 8.0 -> "8".
  String _num(double x) =>
      x == x.roundToDouble() ? '${x.round()}' : (x + 1e-6).toStringAsFixed(1);

  // ------------------------------------------------------------ camera ---
  /// Points that must stay on screen in the current scenario.
  List<_rt_V3> get _framePoints => switch (_scenario) {
    1 => [
      _rt_V3(-7.8, -3.5, -0.6),
      _rt_V3(7.8, -3.5, -0.4),
      _rt_V3(-6.0, 4.6, -0.6),
      _rt_V3(6.2, 3.8, -0.4),
      _rt_V3(0, 4.9, 0),
      _rt_V3(0, -3.5, 3.4),
    ],
    2 => [
      _rt_V3(-10.3, -3.5, -5),
      _rt_V3(10.3, -3.5, -5),
      _rt_V3(-10.3, -3.5, 5),
      _rt_V3(10.3, -3.5, 5),
      _rt_V3(-5.25, 0.8, -4.6),
      _rt_V3(5.25, 0.8, -4.6),
    ],
    3 => [
      _rt_V3(-8.2, -4.2, 0),
      _rt_V3(8.2, -4.2, 0),
      _rt_V3(-7.8, 1.6, 0),
      _rt_V3(7.8, 3.6, 0),
      _rt_V3(0, _pivotY + 3.6, 0),
      _rt_V3(0, -4.2, 4.6),
    ],
    5 => [
      _rt_V3(-4.2, -4.4, 2.2),
      _rt_V3(4.2, -4.4, 2.2),
      _rt_V3(-4.2, 5.8, -2.2),
      _rt_V3(4.2, 5.8, -2.2),
      _rt_V3(0, 7.6, -1.5),
    ],
    _ => [_rt_V3(-4, -2, 0), _rt_V3(4, 2, 0)],
  };

  double get _elevation => switch (_scenario) {
    2 => 0.62,
    3 => 0.15,
    5 => 0.12,
    _ => 0.12,
  };

  /// Width of the chalkboard (step 1) or the step panel on the left.
  double _boardWidth(Size size, bool compact) =>
      math.min(compact ? 270.0 : 420.0, size.width * 0.5);

  double _panelWidth(Size size, bool compact) => math.min(
    compact ? 220.0 : (_scenario == 5 ? 360.0 : 320.0),
    size.width * 0.48,
  );

  /// True for steps that show a panel on the left of the 3D view.
  bool get _hasSidePanel => switch ((_scenario, _step)) {
    (1, 2) || (1, 3) || (2, 2) || (2, 3) || (5, 2) => true,
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
      _foundSymptoms.clear();
      _counselled = _befriended = false;
      _placedItems.clear();
      _sickA = _sickB = 50;
      _verified = _balanced = false;
      _sorted.clear();
      _pledge = null;
      _signed = false;
      _food = _emotion = null;
      _hygiene = _logged = _trendDone = false;
      _exercise = 0;
      _sleep = 4;
      _screen = 0;
      _selectedChip = null;
      _wrongZone = null;
      _dragId = null;
    });
    _trendT.value = 0;
    _buildScenario();
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
      // Every scenario shows its summary (the source skipped S5's).
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

  void _flashZone(String zone) {
    setState(() => _wrongZone = zone);
    _after(600, () => setState(() => _wrongZone = null));
  }

  // ------------------------------------------------------------ 3D drags ---
  /// Only the S3 weight is dragged in 3D.
  bool _grabbable(String id) =>
      !_busy &&
      !_scenarioDone &&
      _scenario == 3 &&
      _step == 2 &&
      id == 'weight' &&
      !_balanced;

  /// Ids that can be dragged right now (for the grab / target markers).
  List<String> get _grabbableIds => [
    for (final id in _objects.keys)
      if (_grabbable(id) && _objects[id]!.isVisibleInTree) id,
  ];

  _rt_V3 _handleLocal(String id) => _rt_V3();

  _rt_V3 _handleWorld(String id) =>
      _objects[id]!.localTransform.apply(_handleLocal(id));

  /// The raised pan is right, the lower pan left, the pivot between.
  List<(String, _DropWindow)> _targets(String id) {
    if (_scenario != 3) return const [];
    final r = _rightPan!.position, l = _leftPan!.position;
    return [
      ('raised', _DropWindow(r + _rt_V3(0, 0.5, 0), 2.0, 0.9, 1.6)),
      ('low', _DropWindow(l + _rt_V3(0, 0.5, 0), 2.0, 0.9, 1.6)),
      ('pivot', _DropWindow(_rt_V3(0, _pivotY, 0), 1.2, 1.2, 1.4)),
    ];
  }

  Iterable<String> _ringTargets(String id) =>
      _scenario == 3 ? const ['raised'] : const [];

  double _floorY(String id) => -4.2;

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
    if (_dragTravel < 12) {
      _snapBack(id);
      return;
    }
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
    switch (hit) {
      case 'raised':
        _balanceScale();
      case 'low':
        _miss(id, 'fbLowPan');
      case 'pivot':
        _miss(id, 'fbPivot');
      default:
        _miss(id, 'fbWeightMiss');
    }
  }

  void _miss(String id, String key) {
    _toast(key, good: false, ms: 3500);
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
  void _addSymptom(String id) {
    if (_scenario != 1 || _step != 2 || _busy || _foundSymptoms.contains(id)) {
      return;
    }
    setState(() => _selectedChip = null);
    if (_symptoms[id] != true) {
      _flashZone('rohan');
      _toast(id == 'fever' ? 'fbFever' : 'fbBroken', good: false, ms: 4000);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _foundSymptoms.add(id));
    if (_foundSymptoms.length == _symptoms.values.where((v) => v).length) {
      _rohanMat?.color = const Color(0xFFEF4444);
      setState(() => _busy = true);
      _toast('fbUnwell', ms: 2500);
      _after(1500, _advance);
    }
  }

  /// The counsellor first, then new friends (content fix: in the source the
  /// counsellor only gave a hint and the friends could come first).
  Future<void> _intervene(String id) async {
    if (_scenario != 1 || _step != 3 || _busy || _befriended) return;
    setState(() => _selectedChip = null);
    final run = _run;
    if (id == 'counsellor') {
      if (_counselled) return;
      setState(() {
        _counselled = true;
        _busy = true;
      });
      _rt_playSfx(_rt_Sfx.pop);
      _shell.showToast(
        _tx.s('fbCounsellor'),
        color: _accent,
        icon: Icons.record_voice_over,
        ms: 3500,
      );
      _rohanMat?.color = const Color(0xFFF59E0B);
      await _grow(_counsellor!);
      if (!_alive(run)) return;
      setState(() => _busy = false);
      return;
    }
    if (!_counselled) {
      _flashZone('rohan');
      _toast('fbCounsellorFirst', good: false);
      return;
    }
    setState(() {
      _befriended = true;
      _busy = true;
    });
    _rohanMat?.color = const Color(0xFF22C55E);
    _rt_playSfx(_rt_Sfx.success);
    for (final f in _friends) {
      unawaited(_grow(f, ms: 600, to: 0.9));
    }
    for (final l in _labels) {
      if (l.userData['key'] == 'friends') _showLabel(l, true);
    }
    _toast('fbHealthy', ms: 3000);
    _after(3500, _completeScenario);
  }

  // ------------------------------------------------- scenario 2 actions ---
  void _placeItem(String id, String zone) {
    if (_scenario != 2 || _step != 2 || _busy || _placedItems.containsKey(id)) {
      return;
    }
    setState(() => _selectedChip = null);
    if (_items[id] != zone) {
      _flashZone('zone$zone');
      _toast(zone == 'A' ? 'fbKeepClean' : 'fbCleanItem', good: false);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _placedItems[id] = zone);
    final prop = _zoneProps[id];
    if (prop != null) {
      prop.scale.set(0.01, 0.01, 0.01);
      unawaited(_grow(prop));
    }
    if (_placedItems.length == _items.length) {
      setState(() => _busy = true);
      _toast('fbSorted', ms: 2000);
      _after(1000, _advance);
    }
  }

  void _setSick(bool zoneA, double v) {
    if (_scenario != 2 || _step != 3 || _verified) return;
    final value = ((v / 5).round() * 5).clamp(0, 100).toDouble();
    setState(() {
      if (zoneA) {
        _sickA = value;
      } else {
        _sickB = value;
      }
    });
  }

  void _verify() {
    if (_scenario != 2 || _step != 3 || _verified || _busy) return;
    if (!(_sickA < 20 && _sickB > 80)) {
      _toast('fbSickWrong', good: false, ms: 4500);
      return;
    }
    setState(() {
      _verified = true;
      _busy = true;
    });
    _toast('fbSickOk');
    _after(800, _completeScenario);
  }

  // ------------------------------------------------- scenario 3 actions ---
  /// The weight on the raised pan levels the beam (content fix: the source
  /// put it on the fulcrum, where it cannot turn the beam).
  Future<void> _balanceScale() async {
    if (_busy || _balanced || _scenario != 3 || _step != 2) return;
    final run = _run;
    setState(() {
      _busy = true;
      _balanced = true;
    });
    final weight = _objects['weight']!;
    final pan = _rightPan!;
    await _tweenNode(weight, pan.position + _rt_V3(0, 0.6, 0), 500);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    final offset = weight.position - pan.position;
    await _tweens.run(1000, (t) {
      _setBeam(_tilt * (1 - t));
      weight.position.copy(pan.position + offset);
    }, ease: _rt_Ease.outQuad);
    if (!_alive(run)) return;
    _toast('fbBalanced', ms: 2000);
    _after(1500, _advance);
  }

  /// S3 routines and S4 habits: card -> bin.
  void _sortCard(String card, String bin) {
    final answers = _scenario == 3 ? _routines : _habits;
    final step = _scenario == 3 ? 3 : 2;
    if ((_scenario != 3 && _scenario != 4) ||
        _step != step ||
        _busy ||
        _sorted.containsKey(card)) {
      return;
    }
    setState(() => _selectedChip = null);
    if (answers[card] != bin) {
      _flashZone(bin);
      _toast(_scenario == 3 ? 'fbRoutineWrong' : 'fbHabitWrong', good: false);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _sorted[card] = bin);
    if (_sorted.length == answers.length) {
      setState(() => _busy = true);
      _after(_scenario == 3 ? 1000 : 1500, _advance);
    }
  }

  // ------------------------------------------------- scenario 4 actions ---
  void _pick(String habit) {
    if (_scenario != 4 || _step != 3 || _signed) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _pledge = habit);
  }

  /// Latched (the source could sign again during its delay).
  void _sign() {
    if (_scenario != 4 || _step != 3 || _signed || _busy) return;
    final habit = _pledge;
    if (habit == null) {
      _toast('fbPickHabit', good: false);
      return;
    }
    setState(() {
      _signed = true;
      _busy = true;
    });
    _toastText(
      _tx.s('fbPledge').replaceAll('{habit}', _tx.s('hb.$habit')),
      ms: 3000,
    );
    _after(1500, _completeScenario);
  }

  // ------------------------------------------------- scenario 5 actions ---
  void _setDiary(VoidCallback change) {
    if (_scenario != 5 || _step != 2 || _logged) return;
    setState(change);
    _updateDiaryLabels();
  }

  /// Any emotion counts (content fix: the source accepted only "Happy");
  /// targets: 60+ min exercise, 8-10 h sleep, 2 h or less screen time.
  void _completeDay() {
    if (_scenario != 5 || _step != 2 || _logged || _busy) return;
    if (_food == null || _emotion == null) {
      _toast('fbFillAll', good: false);
      return;
    }
    final ok =
        _food == 'healthy' &&
        _hygiene &&
        _exercise >= 60 &&
        _sleep >= 8 &&
        _sleep <= 10 &&
        _screen <= 2;
    if (!ok) {
      _toast('fbTargets', good: false, ms: 5000);
      return;
    }
    setState(() {
      _logged = true;
      _busy = true;
    });
    _toast('fbLogged', ms: 2000);
    _after(900, _advance);
  }

  /// A smooth, labelled-illustrative curve (the source drew random noise).
  Future<void> _generateTrend() async {
    if (_scenario != 5 || _step != 3 || _trendDone || _busy) return;
    final run = _run;
    setState(() {
      _trendDone = true;
      _busy = true;
    });
    _rt_playSfx(_rt_Sfx.magic);
    await _tweens.run(1500, (t) => _trendT.value = t, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    _after(1200, _completeScenario);
  }

  /// Health score on day [i] (0-30) of the illustrative projection; more
  /// exercise lifts it a little.
  double _trendScore(double i) {
    final lift = 30 + ((_exercise - 60) / 3).clamp(0, 10);
    return 50 + lift * (1 - math.exp(-i / 9));
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

  /// Sidebar twin of the one 3D drag.
  List<(String, String, VoidCallback?, bool)> get _twins =>
      _scenario == 3 && _step == 2
      ? [
          (
            'twin-weight',
            _tx.s('twWeight'),
            !_balanced && !_busy ? _balanceScale : null,
            _balanced,
          ),
        ]
      : const <(String, String, VoidCallback?, bool)>[];

  /// No 3D taps in this activity.
  List<(String, _rt_V3)> get _tapSpots => const [];

  void _onCanvasTap(_rt_SceneEvent e) {}

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _syncLabels();
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('appTitle'),
            subtitle: _tx.s('appSubtitle'),
            canvasBackground: _rt_Tw.slate950,
            theme: const _rt_ShellTheme(
              accent: _accent,
              headerGradient: [_rt_Tw.slate900, Color(0xFF1E3A8A)],
              headerSubtitleColor: Color(0xFFBFDBFE),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('appSubtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.self_improvement,
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
    final zones =
        !_scenarioDone &&
        ((_scenario == 1 && _step > 1) || (_scenario == 2 && _step == 2));
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
        if (zones)
          Positioned.fill(
            child: ValueListenableBuilder<int>(
              valueListenable: _frameTick,
              builder: (context, _, _) => _projectedZones(size, compact),
            ),
          ),
        if (_panelMode)
          Positioned.fill(
            child: switch ((_scenario, _step)) {
              (3, _) => _routineBoard(compact),
              (4, 2) => _habitBoard(compact),
              (4, _) => _pledgeBoard(compact),
              _ => _trendBoard(compact),
            },
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

  /// Screen rectangle around world corners (null if one is behind the
  /// camera).
  Rect? _screenRect(Size size, List<_rt_V3> corners) {
    final frame = _camera.frame(size);
    final pts = [for (final c in corners) frame.project(c)];
    if (pts.any((p) => p == null)) return null;
    final xs = pts.map((p) => p!.dx), ys = pts.map((p) => p!.dy);
    return Rect.fromLTRB(
      xs.reduce(math.min),
      ys.reduce(math.min),
      xs.reduce(math.max),
      ys.reduce(math.max),
    );
  }

  Widget _tag(String text, Color color, bool compact) => Container(
    margin: const EdgeInsets.only(top: 3),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 9.5 : 11,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
  );

  /// Drop zones laid over the 3D scene: Rohan (S1) or the two playground
  /// halves (S2).
  Widget _projectedZones(Size size, bool compact) {
    final children = <Widget>[];
    if (_scenario == 1) {
      final rect = _screenRect(size, [
        _rt_V3(-1.8, -3.6, 0),
        _rt_V3(1.8, -3.6, 0),
        _rt_V3(-1.8, 3.4, 0),
        _rt_V3(1.8, 3.4, 0),
      ]);
      if (rect != null) {
        final unwell = _foundSymptoms.length == 4 && !_befriended;
        children.add(
          Positioned.fromRect(
            rect: rect,
            child: _dropZone(
              key: 'zone-rohan',
              zone: 'rohan',
              idle: _befriended
                  ? _rt_Tw.green500
                  : (unwell ? _rt_Tw.red500 : Colors.white54),
              onDrop: (id) => _step == 2 ? _addSymptom(id) : _intervene(id),
              builder: (hover, c) => CustomPaint(
                painter: _DashedPainter(c, fill: hover),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  // Tags shrink to fit the zone (it is small on phones).
                  child: Stack(
                    children: [
                      if (_step == 3)
                        Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _tag(
                              _tx.s(_befriended ? 'goodHealth' : 'poorHealth'),
                              _befriended ? _rt_Tw.green600 : _rt_Tw.red500,
                              compact,
                            ),
                          ),
                        ),
                      if (_step == 2)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final id in _foundSymptoms)
                                  _tag(
                                    _tx.s('sym.$id'),
                                    _rt_Tw.red500,
                                    compact,
                                  ),
                                if (_foundSymptoms.isEmpty)
                                  Text(
                                    _tx.s('dropRohan'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: compact ? 9.5 : 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white70,
                                    ),
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
          ),
        );
      }
    } else {
      for (final (zone, x0, x1) in const [
        ('A', -10.25, -0.25),
        ('B', 0.25, 10.25),
      ]) {
        final rect = _screenRect(size, [
          _rt_V3(x0, -3.5, -5),
          _rt_V3(x1, -3.5, -5),
          _rt_V3(x0, -3.5, 5),
          _rt_V3(x1, -3.5, 5),
        ]);
        if (rect == null) continue;
        children.add(
          Positioned.fromRect(
            rect: rect.deflate(6),
            child: _dropZone(
              key: 'zone-zone$zone',
              zone: 'zone$zone',
              idle: Colors.white38,
              onDrop: (id) => _placeItem(id, zone),
              builder: (hover, c) => CustomPaint(
                painter: _DashedPainter(c, fill: hover),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final MapEntry(key: id, value: z)
                              in _placedItems.entries)
                            if (z == zone)
                              _tag(
                                _tx.s('item.$id'),
                                zone == 'A'
                                    ? _rt_Tw.green600
                                    : const Color(0xFF92400E),
                                compact,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return Stack(children: children);
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

  // ------------------------------------------------------- step panels ---
  Widget _sidePanel(Size size, bool compact) {
    final Widget content = switch ((_scenario, _step)) {
      (1, 2) => _chipPanel('symTitle', 'symDesc', [
        for (final id in _symptoms.keys)
          if (!_foundSymptoms.contains(id))
            _draggableChip(id, 'sym.$id', _accentSoft, compact),
      ], compact),
      (1, 3) => _interventionPanel(compact),
      (2, 2) => _chipPanel('sortTitle', 'sortDesc', [
        for (final id in _items.keys)
          if (!_placedItems.containsKey(id))
            _draggableChip(id, 'item.$id', _accentSoft, compact),
      ], compact),
      (2, 3) => _sicknessPanel(compact),
      (5, 2) => _diaryPanel(compact),
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

  Widget _panelText(String text, bool compact, {Color? color, Key? key}) =>
      Padding(
        padding: EdgeInsets.only(bottom: compact ? 4 : 8),
        child: Text(
          text,
          key: key,
          style: TextStyle(
            fontSize: compact ? 11.5 : 13,
            fontWeight: FontWeight.w700,
            color: color ?? Colors.white,
            height: 1.3,
          ),
        ),
      );

  Widget _chipPanel(
    String titleKey,
    String descKey,
    List<Widget> chips,
    bool compact,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s(titleKey)),
        _panelText(_tx.s(descKey), compact),
        Wrap(spacing: 6, runSpacing: 6, children: chips),
      ],
    );
  }

  Widget _interventionPanel(bool compact) {
    if (_befriended) {
      Widget fx(IconData icon, String key, Color color) => Row(
        children: [
          Icon(icon, size: compact ? 22 : 30, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _tx.s(key),
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      );
      return Column(
        key: const ValueKey('healthy-fx'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelTitle(_tx.s('goodHealth')),
          fx(Icons.bedtime, 'sleep8', _rt_Tw.green500),
          const SizedBox(height: 8),
          fx(Icons.phonelink_erase, 'phoneOff', _accentSoft),
        ],
      );
    }
    return _chipPanel('intTitle', 'intDesc', [
      if (!_counselled)
        _draggableChip(
          'counsellor',
          'int.counsellor',
          _accentSoft,
          compact,
          icon: const Icon(Icons.support_agent, size: 16, color: _accentSoft),
        ),
      _draggableChip(
        'friends',
        'int.friends',
        _accentSoft,
        compact,
        icon: const Icon(Icons.groups, size: 16, color: _accentSoft),
      ),
    ], compact);
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

  /// A labelled value row above a slider.
  Widget _valueRow(String label, String value, bool compact, {Key? key}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11.5 : 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value,
          key: key,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w900,
            color: _accentSoft,
          ),
        ),
      ],
    );
  }

  Widget _hint(String key, bool compact) => Text(
    _tx.s(key),
    style: TextStyle(
      fontSize: compact ? 10 : 11,
      fontWeight: FontWeight.w700,
      color: Colors.white54,
    ),
  );

  /// One sickness bar per zone (the source's single "Health Meter" rose as
  /// sickness rose).
  Widget _sicknessPanel(bool compact) {
    Widget zone(String id, double value, String targetKey) {
      final a = id == 'A';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _valueRow(
            _tx.s(a ? 'zoneA' : 'zoneB'),
            '${value.round()}%',
            compact,
            key: ValueKey('sick$id-value'),
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _rt_Tw.red500,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          _valueSlider(
            key: 'sick$id',
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            step: 5,
            onChanged: _verified ? null : (v) => _setSick(a, v),
          ),
          _hint(targetKey, compact),
          SizedBox(height: compact ? 6 : 10),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('sickTitle')),
        zone('A', _sickA, 'targetLow'),
        zone('B', _sickB, 'targetHigh'),
        _rt_ActionButton(
          key: const ValueKey('btn-verify'),
          label: _tx.s('verify'),
          icon: Icons.fact_check,
          color: _accent,
          expand: true,
          done: _verified,
          onPressed: _verified || _busy ? null : _verify,
        ),
      ],
    );
  }

  Widget _diaryPanel(bool compact) {
    Widget section(String pillar, Widget child) => Padding(
      padding: EdgeInsets.only(bottom: compact ? 6 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('pillar.$pillar'),
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w900,
              color: _accentSoft,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
    Widget choice(String key, String label, bool selected, VoidCallback fn) =>
        _rt_ChoiceButton(
          key: ValueKey(key),
          label: label,
          state: selected ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
          onTap: _logged ? null : fn,
        );
    final locked = _logged || _busy;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle('${_tx.s('diaryTitle')} - ${_tx.s('day1')}'),
        section(
          'food',
          Row(
            children: [
              Expanded(
                child: choice(
                  'food-healthy',
                  _tx.s('healthy'),
                  _food == 'healthy',
                  () => _setDiary(() => _food = 'healthy'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: choice(
                  'food-junk',
                  _tx.s('junk'),
                  _food == 'junk',
                  () => _setDiary(() => _food = 'junk'),
                ),
              ),
            ],
          ),
        ),
        section(
          'hygiene',
          choice(
            'hyg',
            _tx.s('bathed'),
            _hygiene,
            () => _setDiary(() => _hygiene = !_hygiene),
          ),
        ),
        section(
          'exercise',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _valueRow(
                _tx.s('tExercise'),
                _tx.s('mins').replaceAll('{v}', '${_exercise.round()}'),
                compact,
                key: const ValueKey('exe-value'),
              ),
              _valueSlider(
                key: 'exe',
                value: _exercise,
                min: 0,
                max: 90,
                divisions: 18,
                step: 5,
                onChanged: locked
                    ? null
                    : (v) => _setDiary(
                        () => _exercise = ((v / 5).round() * 5).toDouble(),
                      ),
              ),
            ],
          ),
        ),
        section(
          'sleep',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _valueRow(
                _tx.s('tSleep'),
                _tx.s('hrs').replaceAll('{v}', _num(_sleep)),
                compact,
                key: const ValueKey('slp-value'),
              ),
              _valueSlider(
                key: 'slp',
                value: _sleep,
                min: 4,
                max: 12,
                divisions: 16,
                step: 0.5,
                onChanged: locked
                    ? null
                    : (v) => _setDiary(() => _sleep = (v * 2).round() / 2),
              ),
            ],
          ),
        ),
        section(
          'screen',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _valueRow(
                _tx.s('tScreen'),
                _tx.s('hrs').replaceAll('{v}', _num(_screen)),
                compact,
                key: const ValueKey('scr-value'),
              ),
              _valueSlider(
                key: 'scr',
                value: _screen,
                min: 0,
                max: 8,
                divisions: 16,
                step: 0.5,
                onChanged: locked
                    ? null
                    : (v) => _setDiary(() => _screen = (v * 2).round() / 2),
              ),
            ],
          ),
        ),
        section(
          'emotion',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in const ['happy', 'neutral', 'sad', 'angry'])
                    SizedBox(
                      width: compact ? 92 : 150,
                      child: choice(
                        'emo-$e',
                        _tx.s('emo.$e'),
                        _emotion == e,
                        () => _setDiary(() => _emotion = e),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              _hint('emoNote', compact),
            ],
          ),
        ),
        _rt_ActionButton(
          key: const ValueKey('btn-complete-day'),
          label: _tx.s('completeDay'),
          icon: Icons.event_available,
          color: _accent,
          expand: true,
          done: _logged,
          onPressed: _logged || _busy ? null : _completeDay,
        ),
      ],
    );
  }

  // ------------------------------------------------------- 2D boards ---
  Widget _board({required bool compact, required List<Widget> children}) {
    return Container(
      color: const Color(0xF20F172A),
      // 24 px on the left: the sidebar's edge overlaps the canvas a little.
      padding: EdgeInsets.fromLTRB(24, compact ? 6 : 14, 12, compact ? 70 : 88),
      child: Column(children: children),
    );
  }

  /// A bin for sorted cards (S3 routines, S4 habits).
  Widget _sortBin(
    String bin,
    String title,
    Color color,
    bool compact,
    String Function(String) cardLabel,
  ) {
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
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              SizedBox(height: compact ? 4 : 8),
              for (final MapEntry(key: card, value: b) in _sorted.entries)
                if (b == bin)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cardLabel(card),
                      style: TextStyle(
                        fontSize: compact ? 10.5 : 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortBoard({
    required bool compact,
    required String titleKey,
    required List<Widget> bins,
    required List<Widget> cards,
  }) {
    return _board(
      compact: compact,
      children: [
        _boardTitle(titleKey, compact),
        SizedBox(height: compact ? 6 : 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: bins[0]),
              SizedBox(width: compact ? 8 : 16),
              Expanded(child: bins[1]),
            ],
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: cards,
        ),
      ],
    );
  }

  Widget _routineBoard(bool compact) => _sortBoard(
    compact: compact,
    titleKey: 'routineTitle',
    bins: [
      _sortBin(
        'dina',
        _tx.s('bin.dina'),
        _rt_Tw.amber400,
        compact,
        (c) => _tx.s('habit.$c'),
      ),
      _sortBin(
        'ritu',
        _tx.s('bin.ritu'),
        _rt_Tw.sky400,
        compact,
        (c) => _tx.s('habit.$c'),
      ),
    ],
    cards: [
      for (final id in _routines.keys)
        if (!_sorted.containsKey(id))
          _draggableChip(id, 'habit.$id', _accentSoft, compact),
    ],
  );

  Widget _habitBoard(bool compact) => _sortBoard(
    compact: compact,
    titleKey: 'habitTitle',
    bins: [
      _sortBin(
        'adopt',
        _tx.s('adopt'),
        _rt_Tw.green500,
        compact,
        (c) => _tx.s('hb.$c'),
      ),
      _sortBin(
        'avoid',
        _tx.s('avoid'),
        _rt_Tw.red500,
        compact,
        (c) => _tx.s('hb.$c'),
      ),
    ],
    cards: [
      for (final id in _habits.keys)
        if (!_sorted.containsKey(id))
          _draggableChip(
            id,
            'hb.$id',
            _accentSoft,
            compact,
            icon: Icon(_habitIcons[id], size: 16, color: _accentSoft),
          ),
    ],
  );

  Widget _pledgeBoard(bool compact) {
    return _board(
      compact: compact,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _glass(
                  padding: EdgeInsets.all(compact ? 10 : 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _boardTitle('pledgeTitle', compact),
                      SizedBox(height: compact ? 6 : 10),
                      _panelText(_tx.s('pledgeQ'), compact),
                      for (final h in const ['listen', 'eat'])
                        Padding(
                          padding: EdgeInsets.only(bottom: compact ? 4 : 6),
                          child: _rt_ChoiceButton(
                            key: ValueKey('pledge-$h'),
                            label: _tx.s('hb.$h'),
                            state: _pledge == h
                                ? (_signed
                                      ? _rt_ChoiceState.correct
                                      : _rt_ChoiceState.selected)
                                : _rt_ChoiceState.idle,
                            onTap: _signed ? null : () => _pick(h),
                          ),
                        ),
                      SizedBox(height: compact ? 4 : 8),
                      _hint('signHint', compact),
                      const SizedBox(height: 6),
                      _rt_ActionButton(
                        key: const ValueKey('btn-sign'),
                        label: _tx.s('sign'),
                        icon: Icons.draw,
                        color: _accent,
                        expand: true,
                        done: _signed,
                        onPressed: _signed || _busy ? null : _sign,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// S5 step 3: the 30-day calendar and the illustrative trend.
  Widget _trendBoard(bool compact) {
    final days = _tx.list('calDays');
    final cell = compact ? 18.0 : 30.0;
    final calendar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in days)
              SizedBox(
                width: cell + 4,
                child: Text(
                  '$d',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white60,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          width: (cell + 4) * 7,
          child: Wrap(
            children: [
              for (var i = 1; i <= 30; i++)
                Container(
                  width: cell,
                  height: cell,
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == 1 ? _rt_Tw.blue500 : _rt_Tw.green600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$i',
                    style: TextStyle(
                      fontSize: compact ? 8 : 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    final scores = [for (var i = 0; i <= 30; i++) _trendScore(i.toDouble())];
    final chart = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            RotatedBox(quarterTurns: 3, child: _hint('healthScore', compact)),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: compact ? 110 : 200,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(
                    left: BorderSide(color: Colors.white54, width: 2),
                    bottom: BorderSide(color: Colors.white54, width: 2),
                  ),
                ),
                child: CustomPaint(
                  key: const ValueKey('trend-chart'),
                  painter: _TrendPainter(_trendT, scores),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Center(child: _hint('time30', compact)),
        Center(
          child: Text(
            _tx.s('illustrative'),
            style: TextStyle(
              fontSize: compact ? 9.5 : 11,
              fontStyle: FontStyle.italic,
              color: _rt_Tw.amber400,
            ),
          ),
        ),
      ],
    );
    return _board(
      compact: compact,
      children: [
        _boardTitle('projTitle', compact),
        _panelText(_tx.s('projDesc'), compact, color: Colors.white70),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                calendar,
                SizedBox(width: compact ? 10 : 24),
                Expanded(child: chart),
              ],
            ),
          ),
        ),
        _rt_ActionButton(
          key: const ValueKey('btn-generate'),
          label: _tx.s('generate'),
          icon: Icons.show_chart,
          color: _accent,
          done: _trendDone,
          onPressed: _trendDone || _busy ? null : _generateTrend,
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

/// S5: the illustrative 30-day health score, drawn up to [progress].
class _TrendPainter extends CustomPainter {
  _TrendPainter(this.progress, this.scores) : super(repaint: progress);

  final ValueNotifier<double> progress;
  final List<double> scores;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;
    for (var k = 1; k < 4; k++) {
      final y = size.height * k / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final t = progress.value;
    if (t <= 0) return;
    final path = Path();
    for (final (i, s) in scores.indexed) {
      final p = Offset(
        i / (scores.length - 1) * size.width,
        size.height - s / 100 * size.height,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * t.clamp(0.0, 1.0)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.scores != scores;
}
