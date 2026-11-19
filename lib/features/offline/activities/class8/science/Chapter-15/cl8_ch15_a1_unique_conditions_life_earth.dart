// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 15.1: Unique Conditions for Life on Earth
// Converted from Cl8S-Ch15-A1-UniqueConditionsForLifeOnEarth.html
// (Tailwind DOM + one 2D canvas -> Flutter widgets + CustomPainters, zoom /
// pan via InteractiveViewer).
//
// Five scenarios chosen from the sidebar, each opened by a setup board and
// run as three steps with a current-task HUD and a summary:
// 1: The Venus Atmosphere Puzzle -- follow a sunbeam (the surface gives off
// infrared), add CO2 in amounts of air up to Venus's real ~90 times Earth's
// (the temperature follows the CO2 only, ~50 -> ~465 °C), then explain why
// Venus beats Mercury (shown on a card: up to 430 °C by day, -180 °C at
// night). 2: The Goldilocks Distance -- move Earth until its water boils,
// then until it freezes (T = 288 K / sqrt(d)), then back into the green
// liquid-water zone, a range of distances. 3: The Magnetic Shield -- look
// inside Earth (solid inner core, liquid outer core of molten iron), then
// set the iron flowing; one threshold drives the field loops (all round
// Earth), the share of solar wind steered away and success. 4: Gravity and
// the Air -- measure gravity, then lower the mass of an Earth-sized planet
// (g = 9.8 M, v = 11.2 sqrt(M)) with Moon / Mars / Earth markers; molecules
// fall toward the centre and, near Mars' mass, lighter gases slowly leak
// away; then explain why. 5: Life Without a Field -- switch the field off,
// fast-forward time (a slow "protection level" meter), then drag or
// tap-place consequences onto neutral events A-D (air worn away, radiation,
// lost birds and turtles, damaged satellites; two distractors), ending with
// the source's report, now fed by every scenario. EN/HI (the source's TE
// block is dropped like on every other page); every rate uses real time,
// not frames; the language survives Restart.

import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

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

  /// The activity (usually a Scene3DView). Fills the area right of the
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


/// Pan + zoom for a 2D activity canvas.
///
/// The 3D activities drive the toolbar through [Camera3D]; a 2D station has no
/// camera, so this wraps the canvas in an [InteractiveViewer] and exposes the
/// same `zoomIn` / `zoomOut` / `reset` callbacks the shell's toolbar expects.
class _rt_CanvasZoomController {
  _rt_CanvasZoomController({this.min = 0.6, this.max = 3.0, this.step = 1.25});

  final double min;
  final double max;
  final double step;

  final TransformationController transform = TransformationController();

  double get scale => transform.value.getMaxScaleOnAxis();

  void _scaleBy(double factor) {
    final target = (scale * factor).clamp(min, max);
    if ((target - scale).abs() < 1e-6) return;
    // Zoom about the centre of the viewport, like the 3D camera dolly.
    final m = Matrix4.identity()..scaleByDouble(target, target, target, 1);
    transform.value = m;
  }

  void zoomIn() => _scaleBy(step);
  void zoomOut() => _scaleBy(1 / step);
  void reset() => transform.value = Matrix4.identity();

  void dispose() => transform.dispose();
}

/// Wraps [child] so it can be pinched, dragged and driven by
/// [_rt_CanvasZoomController].
class _rt_ZoomableCanvas extends StatelessWidget {
  const _rt_ZoomableCanvas({super.key, required this.controller, required this.child});

  final _rt_CanvasZoomController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: controller.transform,
      minScale: controller.min,
      maxScale: controller.max,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      child: child,
    );
  }
}

// END ACTIVITY-LOCAL RUNTIME
// ------------------------------------------------------------------ i18n ----
// From the source's DICTIONARY (EN + HI; TE dropped like every other page),
// rewritten where the source's science or wording was wrong (see the file
// header). The source's Hindi was abridged in places; the missing ideas are
// restored here.
final _tx = _rt_Tx({
  'en': {
    'title': 'Unique Conditions for Life on Earth',
    'subtitle': 'Class 8 • Our Home: Earth, a Unique Life Sustaining Planet',
    'enterLab': 'Start Mission',
    'footnote':
        'Venus • Goldilocks Distance • Magnetic Shield • Gravity • Field Loss',
    'tabGuide': 'Mission Guide',
    'selectScenario': 'Select Scenario',
    'missionObjective': 'Mission Objective',
    'explorationSteps': 'Exploration Steps',
    'step': 'Step',
    'focus': 'Focus',
    'action': 'Action',
    'observation': 'Observation',
    'keyTakeaway': 'What We Learnt',
    'scenarioComplete': 'Scenario Complete!',
    'success': 'Success!',
    'currentTask': 'Current Task',
    'hint': 'Evidence / Hint',
    'learnt': 'Learnt Conclusion',
    'nextScenario': 'Next Scenario',
    'restartLab': 'Restart Lab',
    'doneHud': 'Scenario complete! Go on to the next one.',
    'allDone': 'All scenarios complete! Restart the lab any time.',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'notToScale': 'Not to scale',
    'sun': 'Sun',
    'earth': 'Earth',
    'quizTitle': 'Your Answer',
    'report': {
      'title': 'Exploration Report',
      'mastered': 'Concepts Mastered',
      'review': 'Concepts to Review',
      'masteredNone': 'None yet - finish the scenarios.',
      'reviewNone': 'Excellent! Nothing to review.',
      'concepts': [
        'Greenhouse Effect (Venus)',
        'Habitable Zone (Liquid Water)',
        'Magnetic Dynamo and Shield',
        'Gravity Holding the Air',
        'Consequences of Losing the Field',
      ],
    },
    's1': {
      'venus': 'Venus',
      'venusDist': '108 million km from the Sun',
      'mercury': 'Mercury',
      'mercuryLines': [
        '58 million km from the Sun',
        'Up to 430 °C by day',
        'About −180 °C at night',
      ],
      'sunlight': 'Sunlight',
      'infrared': 'Infrared (heat)',
      'follow': 'Follow the Sunlight',
      'add': 'Add CO₂',
      'remove': 'Remove CO₂',
      'co2Label': 'Amount of CO₂ in the air',
      'levels': [
        'None',
        "As much as all of Earth's air",
        "10 times Earth's air",
        "30 times Earth's air",
        "About 90 times Earth's air (real Venus)",
      ],
      'temp': 'Venus: {t} °C',
      'followed':
          'Sunlight warms the surface; the warm surface gives off infrared (heat) rays.',
      'real':
          "Venus now has its real, thick air: about 465 °C - hotter than Mercury's 430 °C!",
      'quizQ':
          'Venus is almost twice as far from the Sun as Mercury. Why is Venus hotter?',
      'options': [
        'Venus is closer to the Sun.',
        "Venus's thick CO₂ air lets very little heat escape.",
        'Venus is bigger than Mercury.',
      ],
      'feedback': [
        'Check the cards: Venus (108 million km) is farther from the Sun than Mercury (58 million km).',
        'Correct! The thick CO₂ air works like a very thick blanket.',
        "Size does not trap heat - think about what you added to Venus's air.",
      ],
    },
    's2': {
      'distance': 'Distance from the Sun',
      'au': '{d} AU',
      'temp': 'Temperature: {t} °C',
      'water': 'Water',
      'states': {
        'steam': 'Steam (boiling)',
        'liquid': 'Liquid water',
        'ice': 'Ice (frozen)',
      },
      'zone': 'Liquid water zone',
      'model': 'Simple model: only the distance changes.',
      'boiled': 'Too close! At {d} AU the water boils away into steam.',
      'frozen': 'Too far! At {d} AU the water freezes into ice.',
      'liquid': 'Just right: liquid water! Earth (1.0 AU) is inside this zone.',
    },
    's3': {
      'inside': 'Look Inside Earth',
      'innerCore': 'Inner core (solid)',
      'outerCore': 'Outer core (molten iron)',
      'solarWind': 'Solar wind',
      'field': 'Magnetic field',
      'flow': 'Flow of molten iron (outer core)',
      'deflected': 'Particles steered away: {p}%',
      'insideToast':
          'Inside Earth: a solid inner core, surrounded by a liquid outer core of molten iron.',
      'fieldOn': 'The moving iron is making a magnetic field!',
      'shield': 'The field now steers the solar wind around Earth.',
    },
    's4': {
      'measure': 'Measure Gravity',
      'massLabel': 'Planet mass (same size)',
      'mass': "{m}% of Earth's mass",
      'gravity': 'Gravity: {g} m/s²',
      'escape': 'Escape speed: {v} km/s',
      'escaped': 'Escaped: {l} lighter, {h} heavier',
      'light': 'Lighter gas',
      'heavy': 'Heavier gas',
      'markers': {'moon': 'Moon', 'mars': 'Mars', 'earth': 'Earth'},
      'slowMotion': 'Slow motion',
      'pull': 'Gravity pulls toward the centre',
      'measured':
          "Earth's gravity pulls every gas molecule back toward its centre, so the air stays.",
      'leaking':
          "At about Mars' mass, the lighter gases slowly leak away into space.",
      'quizQ': 'The planet kept its size. Why did gases escape?',
      'options': [
        'Its gravity got weaker, so the fastest molecules could escape.',
        'The planet became smaller.',
        'The Sun pulled the gases away.',
      ],
      'feedback': [
        'Correct! Weaker gravity means a lower escape speed.',
        'Look again: the size stayed the same - only the mass changed.',
        "The Sun did not move. What changed was the planet's own pull.",
      ],
    },
    's5': {
      'field': 'Magnetic field',
      'on': 'ON',
      'off': 'OFF',
      'ff': 'Fast-Forward Time',
      'protection': 'Protection level',
      'longTime': 'over a very long time',
      'placeHint': 'Tap a consequence, then tap its event (or drag it there).',
      'chips': {
        'air': 'Air is slowly worn away',
        'radiation': 'More radiation reaches the ground',
        'navigation': 'Birds and turtles lose their way',
        'satellites': 'Satellites and power grids are damaged',
        'oceans': 'Oceans freeze',
        'gravity': 'Gravity gets stronger',
      },
      'right': {
        'air': 'Correct: the solar wind slowly wears away the upper air (A).',
        'radiation':
            'Correct: more harmful radiation gets through to the ground (B).',
        'navigation':
            'Correct: birds and turtles that sense the field lose their way (C).',
        'satellites':
            'Correct: particle storms damage satellites and power grids (D).',
      },
      'wrongEvent': 'Not this event - look at what is happening there.',
      'distractor': {
        'oceans':
            "That would not happen: the oceans' warmth comes from the Sun, not from the magnetic field.",
        'gravity':
            'That would not happen: gravity depends on mass, not on the magnetic field.',
      },
      'fieldOff': 'The field is off! Particles now reach the upper air.',
      'ffDone': 'The protection level has fallen. Now match the consequences.',
      'allMatched': 'All four events explained!',
      'pickFirst': 'Tap a consequence first.',
    },
    'scenarios': {
      '1': {
        'title': 'Scenario 1: The Venus Atmosphere Puzzle',
        'objective': 'Investigate why Venus is hotter than Mercury.',
        'boardDesc':
            "Mercury is the planet closest to the Sun, yet Venus is the hottest planet. Add carbon dioxide (CO₂) to Venus's air and find out why.",
        'boardBtn': 'Start Investigation',
        'hud': [
          '',
          "Tap Venus (or 'Follow the Sunlight') to see what happens to sunlight.",
          "Press 'Add CO₂' until Venus has its real, thick air (about 90 times Earth's).",
          'Compare with Mercury: answer the question in the panel.',
        ],
        'steps': [
          {
            'concept': 'Sunlight and Infrared',
            'action': 'Tap Venus to follow the sunlight.',
            'observation':
                'Sunlight warms the surface, which then gives off infrared (heat) rays.',
          },
          {
            'concept': 'Adding CO₂',
            'action': "Add CO₂ step by step, up to Venus's real amount.",
            'observation':
                'The more CO₂, the less heat escapes: Venus heats from about 50 °C to about 465 °C.',
          },
          {
            'concept': 'Venus vs Mercury',
            'action': 'Answer: why is Venus hotter than Mercury?',
            'observation':
                'Venus is farther from the Sun, but its thick CO₂ air traps heat.',
          },
        ],
        'hint':
            'Mercury: 58 million km from the Sun, up to 430 °C by day, about −180 °C at night. Venus: 108 million km from the Sun, temperature = ?',
        'summaryLead': 'Greenhouse Effect Found!',
        'summary':
            "Venus's air is mostly carbon dioxide and about 90 times thicker than Earth's. It lets very little heat escape - a very strong greenhouse effect - so Venus stays near 465 °C day and night: hotter than Mercury, even though Mercury is closer to the Sun.",
      },
      '2': {
        'title': 'Scenario 2: The Goldilocks Distance',
        'objective':
            'Find the range of distances from the Sun where water stays liquid.',
        'boardDesc':
            'Earth is at just the right distance from the Sun - not too hot and not too cold. Move Earth closer and farther, and watch what happens to its water.',
        'boardBtn': 'Start Orbit Test',
        'hud': [
          '',
          'Move Earth closer to the Sun until its water boils (try 0.5 AU).',
          'Now move Earth far from the Sun until its water freezes (try 1.5 AU).',
          'Bring Earth back into the green zone, where water stays liquid.',
        ],
        'steps': [
          {
            'concept': 'Too Close',
            'action': 'Move Earth to 0.5 AU.',
            'observation':
                'Close to the Sun it is about 134 °C: the water boils away into steam.',
          },
          {
            'concept': 'Too Far',
            'action': 'Move Earth to 1.5 AU.',
            'observation':
                'Far from the Sun it is below 0 °C: the water freezes into ice.',
          },
          {
            'concept': 'Just Right',
            'action': 'Move Earth back into the green zone.',
            'observation':
                'From about 0.6 to 1.1 AU water stays liquid. Earth is at 1.0 AU.',
          },
        ],
        'hint':
            "At normal air pressure, water boils at 100 °C and freezes at 0 °C. 1 AU is Earth's distance from the Sun (about 150 million km).",
        'summaryLead': 'Habitable Zone Found!',
        'summary':
            'The habitable zone is the range of distances from a star where a planet can have liquid water on its surface. Earth (1.0 AU) lies inside it. Distance is not the only thing that matters: liquid water also needs enough air above it - and Venus (0.7 AU) shows that too much CO₂ can make a planet far too hot.',
      },
      '3': {
        'title': 'Scenario 3: The Magnetic Shield',
        'objective':
            "Find out how Earth's magnetic field shields it from the solar wind.",
        'boardDesc':
            'The Sun sends out a stream of charged particles called the solar wind. Look inside Earth, then set its molten iron flowing and watch what happens.',
        'boardBtn': 'Start Shield Test',
        'hud': [
          '',
          "Tap Earth's centre (or 'Look Inside Earth') to see its core.",
          'Use the slider to set the molten iron in the outer core flowing.',
          'Increase the flow until the field steers all the particles around Earth.',
        ],
        'steps': [
          {
            'concept': 'Inside Earth',
            'action': "Tap Earth's centre to look inside.",
            'observation':
                'A solid inner core sits inside a liquid outer core of molten iron.',
          },
          {
            'concept': 'The Dynamo',
            'action': 'Start the molten iron flowing.',
            'observation':
                'Moving molten iron produces a magnetic field around Earth.',
          },
          {
            'concept': 'The Shield',
            'action': 'Increase the flow until every particle is steered away.',
            'observation': 'A strong field steers the solar wind around Earth.',
          },
        ],
        'hint':
            "A dynamo needs moving molten metal. Earth's spin helps to organise the flow.",
        'summaryLead': 'Shield Activated!',
        'summary':
            "Moving molten iron in Earth's outer core produces Earth's magnetic field. The field steers most of the solar wind around Earth, so these particles do not reach the ground, and it helps protect the air from being slowly worn away over a very long time.",
      },
      '4': {
        'title': 'Scenario 4: Gravity and the Air',
        'objective':
            "Find out how a planet's mass affects its hold on its air.",
        'boardDesc':
            'Gravity pulls the gas molecules of the air toward the planet. What if Earth had much less mass, but stayed the same size?',
        'boardBtn': 'Start Gravity Test',
        'hud': [
          '',
          "Tap the planet (or 'Measure Gravity') to read its gravity.",
          "Lower the planet's mass to about Mars' mass.",
          'Answer the question in the panel.',
        ],
        'steps': [
          {
            'concept': 'Holding the Air',
            'action': 'Tap the planet to measure its gravity.',
            'observation':
                "Earth's gravity pulls every molecule back, so the air stays.",
          },
          {
            'concept': 'Less Mass',
            'action': "Lower the mass to about Mars' mass.",
            'observation':
                'Gravity and escape speed fall; the lighter gases slowly leak away.',
          },
          {
            'concept': 'Why?',
            'action': 'Answer: why did the gases escape?',
            'observation':
                'With weaker gravity, the fastest molecules can reach escape speed.',
          },
        ],
        'hint':
            'For a planet of the same size, surface gravity is proportional to its mass. Escape speed is the speed a molecule needs to get away for good.',
        'summaryLead': 'Gravity Holds the Air!',
        'summary':
            "A planet needs enough mass, and so enough gravity, to hold on to its air. With much less mass, the fastest molecules - lighter gases first - slowly escape into space. Mars (about 11% of Earth's mass) has only very thin air, and the Moon (about 1%) has almost none.",
      },
      '5': {
        'title': 'Scenario 5: Life Without a Field',
        'objective':
            "Find out what could happen if Earth's magnetic field disappeared.",
        'boardDesc':
            "Unsolved challenge: imagine Earth's magnetic field suddenly disappeared. What problems could this cause for life on Earth?",
        'boardBtn': 'Start Challenge',
        'hud': [
          '',
          "Switch Earth's magnetic field off.",
          "Press 'Fast-Forward Time' and watch the protection level.",
          'Drag each consequence onto the event it explains (A-D). Two of them fit nowhere.',
        ],
        'steps': [
          {
            'concept': 'Field Off',
            'action': 'Switch the magnetic field off.',
            'observation':
                'Particles from the Sun and from space now reach the upper air.',
          },
          {
            'concept': 'A Long Time Later',
            'action': 'Fast-forward time and watch.',
            'observation': 'Over a very long time, the protection level falls.',
          },
          {
            'concept': 'Consequences',
            'action': 'Drag each consequence onto its event.',
            'observation':
                'The air is slowly worn away, more radiation gets through, animals lose their way and satellites are damaged.',
          },
        ],
        'hint':
            'Look at what the particles reach at each letter: the upper air, the ground, a migrating bird and a satellite.',
        'summaryLead': 'Consequences Identified!',
        'summary':
            'Without the magnetic field, particles from the Sun would slowly wear away the upper air over a very long time, and more harmful radiation would get through. Animals that navigate by the field, such as birds and turtles, could lose their way, and satellites and power grids would be damaged more often.',
      },
    },
  },
  'hi': {
    'title': 'पृथ्वी पर जीवन की अनोखी परिस्थितियाँ',
    'subtitle':
        'कक्षा 8 • हमारा घर: पृथ्वी, जीवन को सहारा देने वाला एक अनोखा ग्रह',
    'enterLab': 'मिशन शुरू करें',
    'footnote':
        'शुक्र • गोल्डीलॉक्स दूरी • चुंबकीय कवच • गुरुत्व • क्षेत्र का लोप',
    'tabGuide': 'मिशन गाइड',
    'selectScenario': 'परिदृश्य चुनें',
    'missionObjective': 'मिशन का उद्देश्य',
    'explorationSteps': 'खोज के चरण',
    'step': 'चरण',
    'focus': 'मुख्य बिंदु',
    'action': 'कार्य',
    'observation': 'अवलोकन',
    'keyTakeaway': 'हमने क्या सीखा',
    'scenarioComplete': 'परिदृश्य पूर्ण!',
    'success': 'सफलता!',
    'currentTask': 'वर्तमान कार्य',
    'hint': 'प्रमाण / संकेत',
    'learnt': 'सीखा गया निष्कर्ष',
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'लैब फिर से शुरू करें',
    'doneHud': 'परिदृश्य पूर्ण! अगले परिदृश्य पर चलें।',
    'allDone': 'सभी परिदृश्य पूर्ण! लैब को कभी भी फिर से शुरू करें।',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ',
    'panMode': 'पैन मोड',
    'notToScale': 'पैमाने के अनुसार नहीं',
    'sun': 'सूर्य',
    'earth': 'पृथ्वी',
    'quizTitle': 'आपका उत्तर',
    'report': {
      'title': 'खोज रिपोर्ट',
      'mastered': 'जिन अवधारणाओं में महारत मिली',
      'review': 'दोबारा देखने योग्य अवधारणाएँ',
      'masteredNone': 'अभी कोई नहीं - परिदृश्य पूरे करें।',
      'reviewNone': 'बहुत बढ़िया! दोबारा देखने को कुछ नहीं।',
      'concepts': [
        'ग्रीनहाउस प्रभाव (शुक्र)',
        'जीवन-योग्य क्षेत्र (द्रव जल)',
        'चुंबकीय डायनेमो और कवच',
        'गुरुत्व द्वारा वायु को थामे रखना',
        'चुंबकीय क्षेत्र के लोप के परिणाम',
      ],
    },
    's1': {
      'venus': 'शुक्र',
      'venusDist': 'सूर्य से 10.8 करोड़ किमी',
      'mercury': 'बुध',
      'mercuryLines': [
        'सूर्य से 5.8 करोड़ किमी',
        'दिन में 430 °C तक',
        'रात में लगभग −180 °C',
      ],
      'sunlight': 'सूर्य का प्रकाश',
      'infrared': 'अवरक्त (ऊष्मा)',
      'follow': 'सूर्य के प्रकाश का पीछा करें',
      'add': 'CO₂ डालें',
      'remove': 'CO₂ हटाएँ',
      'co2Label': 'वायु में CO₂ की मात्रा',
      'levels': [
        'कुछ नहीं',
        'पृथ्वी की पूरी वायु जितनी',
        'पृथ्वी की वायु का 10 गुना',
        'पृथ्वी की वायु का 30 गुना',
        'पृथ्वी की वायु का लगभग 90 गुना (असली शुक्र)',
      ],
      'temp': 'शुक्र: {t} °C',
      'followed':
          'सूर्य का प्रकाश सतह को गर्म करता है; गर्म सतह अवरक्त (ऊष्मा) किरणें छोड़ती है।',
      'real':
          'अब शुक्र की वायु असली जितनी मोटी है: लगभग 465 °C - बुध के 430 °C से भी अधिक!',
      'quizQ':
          'शुक्र, बुध की तुलना में सूर्य से लगभग दोगुनी दूरी पर है। फिर भी शुक्र अधिक गर्म क्यों है?',
      'options': [
        'शुक्र सूर्य के अधिक निकट है।',
        'शुक्र की मोटी CO₂ वायु बहुत कम ऊष्मा को बाहर जाने देती है।',
        'शुक्र, बुध से बड़ा है।',
      ],
      'feedback': [
        'कार्ड देखें: शुक्र (10.8 करोड़ किमी) बुध (5.8 करोड़ किमी) की तुलना में सूर्य से अधिक दूर है।',
        'सही! मोटी CO₂ वायु एक बहुत मोटे कंबल की तरह काम करती है।',
        'आकार ऊष्मा को नहीं रोकता - सोचें कि आपने शुक्र की वायु में क्या डाला।',
      ],
    },
    's2': {
      'distance': 'सूर्य से दूरी',
      'au': '{d} AU',
      'temp': 'तापमान: {t} °C',
      'water': 'पानी',
      'states': {
        'steam': 'भाप (उबलता हुआ)',
        'liquid': 'द्रव जल',
        'ice': 'बर्फ़ (जमा हुआ)',
      },
      'zone': 'द्रव जल क्षेत्र',
      'model': 'सरल मॉडल: केवल दूरी बदलती है।',
      'boiled': 'बहुत पास! {d} AU पर पानी उबलकर भाप बन जाता है।',
      'frozen': 'बहुत दूर! {d} AU पर पानी जमकर बर्फ़ बन जाता है।',
      'liquid': 'बिल्कुल सही: द्रव जल! पृथ्वी (1.0 AU) इसी क्षेत्र के अंदर है।',
    },
    's3': {
      'inside': 'पृथ्वी के अंदर देखें',
      'innerCore': 'आंतरिक क्रोड (ठोस)',
      'outerCore': 'बाहरी क्रोड (पिघला लोहा)',
      'solarWind': 'सौर पवन',
      'field': 'चुंबकीय क्षेत्र',
      'flow': 'पिघले लोहे का प्रवाह (बाहरी क्रोड)',
      'deflected': 'दूर मुड़े कण: {p}%',
      'insideToast':
          'पृथ्वी के अंदर: एक ठोस आंतरिक क्रोड, जिसके चारों ओर पिघले लोहे का द्रव बाहरी क्रोड है।',
      'fieldOn': 'बहता हुआ लोहा चुंबकीय क्षेत्र बना रहा है!',
      'shield': 'अब क्षेत्र सौर पवन को पृथ्वी के चारों ओर मोड़ रहा है।',
    },
    's4': {
      'measure': 'गुरुत्व मापें',
      'massLabel': 'ग्रह का द्रव्यमान (आकार वही)',
      'mass': 'पृथ्वी के द्रव्यमान का {m}%',
      'gravity': 'गुरुत्व: {g} m/s²',
      'escape': 'पलायन वेग: {v} km/s',
      'escaped': 'निकल गए: {l} हल्के, {h} भारी',
      'light': 'हल्की गैस',
      'heavy': 'भारी गैस',
      'markers': {'moon': 'चंद्रमा', 'mars': 'मंगल', 'earth': 'पृथ्वी'},
      'slowMotion': 'धीमी गति',
      'pull': 'गुरुत्व केंद्र की ओर खींचता है',
      'measured':
          'पृथ्वी का गुरुत्व हर गैस अणु को उसके केंद्र की ओर वापस खींचता है, इसलिए वायु बनी रहती है।',
      'leaking':
          'लगभग मंगल जितने द्रव्यमान पर हल्की गैसें धीरे-धीरे अंतरिक्ष में निकलने लगती हैं।',
      'quizQ': 'ग्रह का आकार वही रहा। फिर गैसें क्यों निकल गईं?',
      'options': [
        'उसका गुरुत्व कमज़ोर हो गया, इसलिए सबसे तेज़ अणु निकल सके।',
        'ग्रह छोटा हो गया।',
        'सूर्य ने गैसों को खींच लिया।',
      ],
      'feedback': [
        'सही! कमज़ोर गुरुत्व का अर्थ है कम पलायन वेग।',
        'फिर से देखें: आकार वही रहा - केवल द्रव्यमान बदला।',
        'सूर्य अपनी जगह से नहीं हिला। बदला तो ग्रह का अपना खिंचाव।',
      ],
    },
    's5': {
      'field': 'चुंबकीय क्षेत्र',
      'on': 'चालू',
      'off': 'बंद',
      'ff': 'समय आगे बढ़ाएँ',
      'protection': 'सुरक्षा स्तर',
      'longTime': 'बहुत लंबे समय में',
      'placeHint':
          'किसी परिणाम पर टैप करें, फिर उसकी घटना पर टैप करें (या उसे वहाँ खींचें)।',
      'chips': {
        'air': 'वायुमंडल का धीरे-धीरे छिनना',
        'radiation': 'सतह पर विकिरण का बढ़ना',
        'navigation': 'पक्षी और कछुए रास्ता भटकते हैं',
        'satellites': 'उपग्रह और बिजली ग्रिड खराब होते हैं',
        'oceans': 'महासागर जम जाते हैं',
        'gravity': 'गुरुत्व बढ़ जाता है',
      },
      'right': {
        'air': 'सही: सौर पवन ऊपरी वायु को धीरे-धीरे घिसती है (A)।',
        'radiation': 'सही: अधिक हानिकारक विकिरण ज़मीन तक पहुँचता है (B)।',
        'navigation':
            'सही: क्षेत्र को महसूस करने वाले पक्षी और कछुए रास्ता भटकते हैं (C)।',
        'satellites':
            'सही: कणों के तूफ़ान उपग्रहों और बिजली ग्रिड को नुकसान पहुँचाते हैं (D)।',
      },
      'wrongEvent': 'यह घटना नहीं - देखें कि वहाँ क्या हो रहा है।',
      'distractor': {
        'oceans':
            'ऐसा नहीं होगा: महासागरों की गर्मी सूर्य से आती है, चुंबकीय क्षेत्र से नहीं।',
        'gravity':
            'ऐसा नहीं होगा: गुरुत्व द्रव्यमान पर निर्भर करता है, चुंबकीय क्षेत्र पर नहीं।',
      },
      'fieldOff': 'क्षेत्र बंद है! अब कण ऊपरी वायु तक पहुँच रहे हैं।',
      'ffDone': 'सुरक्षा स्तर घट गया है। अब परिणामों का मिलान करें।',
      'allMatched': 'चारों घटनाएँ समझा दी गईं!',
      'pickFirst': 'पहले किसी परिणाम पर टैप करें।',
    },
    'scenarios': {
      '1': {
        'title': 'परिदृश्य 1: शुक्र के वायुमंडल की पहेली',
        'objective': 'पता लगाएँ कि शुक्र, बुध से अधिक गर्म क्यों है।',
        'boardDesc':
            'बुध सूर्य के सबसे निकट का ग्रह है, फिर भी शुक्र सबसे गर्म ग्रह है। शुक्र की वायु में कार्बन डाइऑक्साइड (CO₂) डालें और कारण पता करें।',
        'boardBtn': 'जाँच शुरू करें',
        'hud': [
          '',
          "सूर्य के प्रकाश का क्या होता है, यह देखने के लिए शुक्र पर (या 'सूर्य के प्रकाश का पीछा करें' पर) टैप करें।",
          "'CO₂ डालें' दबाते रहें, जब तक शुक्र की वायु असली जितनी मोटी (पृथ्वी की वायु का लगभग 90 गुना) न हो जाए।",
          'बुध से तुलना करें: पैनल में दिए प्रश्न का उत्तर दें।',
        ],
        'steps': [
          {
            'concept': 'सूर्य का प्रकाश और अवरक्त किरणें',
            'action': 'सूर्य के प्रकाश का पीछा करने के लिए शुक्र पर टैप करें।',
            'observation':
                'सूर्य का प्रकाश सतह को गर्म करता है, फिर गर्म सतह अवरक्त (ऊष्मा) किरणें छोड़ती है।',
          },
          {
            'concept': 'CO₂ डालना',
            'action': 'CO₂ को चरण-दर-चरण शुक्र की असली मात्रा तक डालें।',
            'observation':
                'जितनी अधिक CO₂, उतनी कम ऊष्मा बाहर निकल पाती है: शुक्र लगभग 50 °C से लगभग 465 °C तक गर्म हो जाता है।',
          },
          {
            'concept': 'शुक्र बनाम बुध',
            'action': 'उत्तर दें: शुक्र, बुध से अधिक गर्म क्यों है?',
            'observation':
                'शुक्र सूर्य से अधिक दूर है, पर उसकी मोटी CO₂ वायु ऊष्मा को रोक लेती है।',
          },
        ],
        'hint':
            'बुध: सूर्य से 5.8 करोड़ किमी, दिन में 430 °C तक, रात में लगभग −180 °C। शुक्र: सूर्य से 10.8 करोड़ किमी, तापमान = ?',
        'summaryLead': 'ग्रीनहाउस प्रभाव मिल गया!',
        'summary':
            'शुक्र की वायु मुख्य रूप से कार्बन डाइऑक्साइड है और पृथ्वी की वायु से लगभग 90 गुना अधिक घनी है। यह बहुत कम ऊष्मा को बाहर जाने देती है - एक बहुत प्रबल ग्रीनहाउस प्रभाव - इसलिए शुक्र दिन-रात लगभग 465 °C पर रहता है: बुध से भी अधिक गर्म, जबकि बुध सूर्य के अधिक निकट है।',
      },
      '2': {
        'title': 'परिदृश्य 2: गोल्डीलॉक्स दूरी (न बहुत गर्म, न बहुत ठंडा)',
        'objective':
            'सूर्य से दूरियों की वह सीमा खोजें जहाँ पानी द्रव बना रहता है।',
        'boardDesc':
            'पृथ्वी सूर्य से बिल्कुल सही दूरी पर है - न बहुत गर्म, न बहुत ठंडी। पृथ्वी को पास और दूर ले जाएँ, और देखें कि उसके पानी का क्या होता है।',
        'boardBtn': 'कक्षा परीक्षण शुरू करें',
        'hud': [
          '',
          'पृथ्वी को सूर्य के पास ले जाएँ, जब तक उसका पानी उबल न जाए (0.5 AU आज़माएँ)।',
          'अब पृथ्वी को सूर्य से दूर ले जाएँ, जब तक उसका पानी जम न जाए (1.5 AU आज़माएँ)।',
          'पृथ्वी को वापस हरे क्षेत्र में लाएँ, जहाँ पानी द्रव बना रहता है।',
        ],
        'steps': [
          {
            'concept': 'बहुत पास',
            'action': 'पृथ्वी को 0.5 AU पर ले जाएँ।',
            'observation':
                'सूर्य के पास तापमान लगभग 134 °C है: पानी उबलकर भाप बन जाता है।',
          },
          {
            'concept': 'बहुत दूर',
            'action': 'पृथ्वी को 1.5 AU पर ले जाएँ।',
            'observation':
                'सूर्य से दूर तापमान 0 °C से नीचे है: पानी जमकर बर्फ़ बन जाता है।',
          },
          {
            'concept': 'बिल्कुल सही',
            'action': 'पृथ्वी को वापस हरे क्षेत्र में लाएँ।',
            'observation':
                'लगभग 0.6 से 1.1 AU तक पानी द्रव रहता है। पृथ्वी 1.0 AU पर है।',
          },
        ],
        'hint':
            'सामान्य वायुदाब पर पानी 100 °C पर उबलता है और 0 °C पर जमता है। 1 AU = सूर्य से पृथ्वी की दूरी (लगभग 15 करोड़ किमी)।',
        'summaryLead': 'जीवन-योग्य क्षेत्र मिल गया!',
        'summary':
            'जीवन-योग्य क्षेत्र किसी तारे से दूरियों की वह सीमा है जहाँ किसी ग्रह की सतह पर द्रव जल रह सकता है। पृथ्वी (1.0 AU) इसके अंदर है। केवल दूरी ही सब कुछ नहीं है: द्रव जल के लिए ऊपर पर्याप्त वायु भी चाहिए - और शुक्र (0.7 AU) दिखाता है कि बहुत अधिक CO₂ किसी ग्रह को बहुत अधिक गर्म बना सकती है।',
      },
      '3': {
        'title': 'परिदृश्य 3: चुंबकीय कवच',
        'objective':
            'पता लगाएँ कि पृथ्वी का चुंबकीय क्षेत्र उसे सौर पवन से कैसे बचाता है।',
        'boardDesc':
            'सूर्य आवेशित कणों की एक धारा भेजता है, जिसे सौर पवन कहते हैं। पृथ्वी के अंदर देखें, फिर उसके पिघले लोहे को बहाएँ और देखें कि क्या होता है।',
        'boardBtn': 'कवच परीक्षण शुरू करें',
        'hud': [
          '',
          "पृथ्वी का क्रोड (कोर) देखने के लिए उसके केंद्र पर (या 'पृथ्वी के अंदर देखें' पर) टैप करें।",
          'स्लाइडर से बाहरी क्रोड का पिघला लोहा बहाना शुरू करें।',
          'प्रवाह तब तक बढ़ाएँ जब तक क्षेत्र सभी कणों को पृथ्वी के चारों ओर न मोड़ दे।',
        ],
        'steps': [
          {
            'concept': 'पृथ्वी के अंदर',
            'action': 'अंदर देखने के लिए पृथ्वी के केंद्र पर टैप करें।',
            'observation':
                'ठोस आंतरिक क्रोड, पिघले लोहे के द्रव बाहरी क्रोड के अंदर है।',
          },
          {
            'concept': 'डायनेमो',
            'action': 'पिघले लोहे को बहाना शुरू करें।',
            'observation':
                'बहता हुआ पिघला लोहा पृथ्वी के चारों ओर चुंबकीय क्षेत्र बनाता है।',
          },
          {
            'concept': 'कवच',
            'action': 'प्रवाह तब तक बढ़ाएँ जब तक हर कण दूर न मुड़ जाए।',
            'observation':
                'प्रबल क्षेत्र सौर पवन को पृथ्वी के चारों ओर मोड़ देता है।',
          },
        ],
        'hint':
            'डायनेमो के लिए बहती हुई पिघली धातु चाहिए। पृथ्वी का घूर्णन इस प्रवाह को व्यवस्थित करने में मदद करता है।',
        'summaryLead': 'कवच सक्रिय!',
        'summary':
            'पृथ्वी के बाहरी क्रोड में बहता पिघला लोहा पृथ्वी का चुंबकीय क्षेत्र बनाता है। यह क्षेत्र अधिकांश सौर पवन को पृथ्वी के चारों ओर मोड़ देता है, जिससे ये कण ज़मीन तक नहीं पहुँचते, और यह वायु को बहुत लंबे समय में धीरे-धीरे घिसकर कम होने से बचाने में मदद करता है।',
      },
      '4': {
        'title': 'परिदृश्य 4: गुरुत्व और वायुमंडल',
        'objective':
            'पता लगाएँ कि किसी ग्रह का द्रव्यमान उसकी वायु को थामे रखने को कैसे प्रभावित करता है।',
        'boardDesc':
            'गुरुत्व वायु के गैस अणुओं को ग्रह की ओर खींचता है। क्या होगा यदि पृथ्वी का आकार वही रहे, पर उसका द्रव्यमान बहुत कम हो जाए?',
        'boardBtn': 'गुरुत्व परीक्षण शुरू करें',
        'hud': [
          '',
          "ग्रह का गुरुत्व पढ़ने के लिए उस पर (या 'गुरुत्व मापें' पर) टैप करें।",
          'ग्रह का द्रव्यमान घटाकर लगभग मंगल के द्रव्यमान जितना करें।',
          'पैनल में दिए प्रश्न का उत्तर दें।',
        ],
        'steps': [
          {
            'concept': 'वायु को थामे रखना',
            'action': 'गुरुत्व मापने के लिए ग्रह पर टैप करें।',
            'observation':
                'पृथ्वी का गुरुत्व हर अणु को वापस खींच लेता है, इसलिए वायु बनी रहती है।',
          },
          {
            'concept': 'कम द्रव्यमान',
            'action': 'द्रव्यमान घटाकर लगभग मंगल जितना करें।',
            'observation':
                'गुरुत्व और पलायन वेग घटते हैं; हल्की गैसें धीरे-धीरे निकल जाती हैं।',
          },
          {
            'concept': 'क्यों?',
            'action': 'उत्तर दें: गैसें क्यों निकल गईं?',
            'observation':
                'कमज़ोर गुरुत्व में सबसे तेज़ अणु पलायन वेग तक पहुँच सकते हैं।',
          },
        ],
        'hint':
            'एक ही आकार के ग्रह के लिए, सतह का गुरुत्व उसके द्रव्यमान के समानुपाती होता है। पलायन वेग वह वेग है जिससे कोई अणु हमेशा के लिए दूर जा सकता है।',
        'summaryLead': 'गुरुत्व वायु को थामे रखता है!',
        'summary':
            'किसी ग्रह को अपनी वायु थामे रखने के लिए पर्याप्त द्रव्यमान, और इसलिए पर्याप्त गुरुत्व, चाहिए। बहुत कम द्रव्यमान होने पर सबसे तेज़ अणु - पहले हल्की गैसें - धीरे-धीरे अंतरिक्ष में निकल जाते हैं। मंगल (पृथ्वी के द्रव्यमान का लगभग 11%) की वायु बहुत पतली है, और चंद्रमा (लगभग 1%) पर लगभग कोई वायु नहीं है।',
      },
      '5': {
        'title': 'परिदृश्य 5: चुंबकीय क्षेत्र के बिना जीवन',
        'objective':
            'पता लगाएँ कि पृथ्वी का चुंबकीय क्षेत्र गायब हो जाए तो क्या हो सकता है।',
        'boardDesc':
            'अनसुलझी चुनौती: कल्पना करें कि पृथ्वी का चुंबकीय क्षेत्र अचानक गायब हो गया। इससे पृथ्वी पर जीवन के लिए कौन-सी समस्याएँ हो सकती हैं?',
        'boardBtn': 'चुनौती शुरू करें',
        'hud': [
          '',
          'पृथ्वी का चुंबकीय क्षेत्र बंद करें।',
          "'समय आगे बढ़ाएँ' दबाएँ और सुरक्षा स्तर देखें।",
          'हर परिणाम को उस घटना (A-D) पर खींचें जिसे वह समझाता है। इनमें से दो कहीं फिट नहीं होते।',
        ],
        'steps': [
          {
            'concept': 'क्षेत्र बंद',
            'action': 'चुंबकीय क्षेत्र बंद करें।',
            'observation':
                'सूर्य और अंतरिक्ष से आए कण अब ऊपरी वायु तक पहुँचते हैं।',
          },
          {
            'concept': 'बहुत समय बाद',
            'action': 'समय आगे बढ़ाएँ और देखें।',
            'observation': 'बहुत लंबे समय में सुरक्षा स्तर घट जाता है।',
          },
          {
            'concept': 'परिणाम',
            'action': 'हर परिणाम को उसकी घटना पर खींचें।',
            'observation':
                'वायु धीरे-धीरे घिसती है, अधिक विकिरण भीतर आता है, जीव रास्ता भटकते हैं और उपग्रह खराब होते हैं।',
          },
        ],
        'hint':
            'देखें कि हर अक्षर पर कण कहाँ तक पहुँचते हैं: ऊपरी वायु, ज़मीन, एक प्रवासी पक्षी और एक उपग्रह।',
        'summaryLead': 'परिणाम पहचाने गए!',
        'summary':
            'चुंबकीय क्षेत्र के बिना सूर्य से आए कण बहुत लंबे समय में ऊपरी वायु को धीरे-धीरे घिसकर कम कर देंगे, और अधिक हानिकारक विकिरण भीतर आएगा। क्षेत्र की मदद से रास्ता खोजने वाले जीव, जैसे पक्षी और कछुए, रास्ता भटक सकते हैं, और उपग्रह तथा बिजली ग्रिड अधिक बार खराब होंगे।',
      },
    },
  },
});

// ------------------------------------------------------------- constants ----

/// Design size of every scenario's stage (the source's full-window canvas).
const Size _kStage = Size(760, 340);

/// Canvases shorter than this (phone landscape) get a tighter top inset.
const double _kShortHeight = 500;

/// Content at least this wide gets the control panel beside the stage
/// (desktops, and phones with the sidebar closed).
const double _kSideBySideWidth = 640;

/// Width of that side panel.
const double _kPanelWidth = 260;

const Color _kAccent = _rt_Tw.indigo500;
const Color _kAccentDark = _rt_Tw.indigo700;
const Color _kAccentSoft = Color(0xFFA5B4FC); // indigo-300

// Scenario 1: Venus.
const Offset _kS1Sun = Offset(-50, 175);
const double _kS1SunRadius = 120;
const Offset _kVenus = Offset(440, 190);
const double _kVenusRadius = 62;

/// Venus's settled temperature for each amount of CO₂ (none ... real
/// Venus). With no air at all, a bare rock at Venus's distance would sit
/// near 50 °C; the real, thick CO₂ air keeps it near 465 °C.
const List<double> _kVenusTemps = [50, 110, 230, 340, 465];
const int _kCo2Max = 4;

/// The temperature eases to its new value over this many seconds.
const double _kTempEase = 1.6;

/// Shell thickness of the CO₂ air for each level.
const List<double> _kCo2Shell = [0, 10, 20, 30, 42];

/// How many of the seven infrared rays the air sends back, per level.
const List<int> _kTrapped = [0, 2, 4, 5, 6];

// Scenario 2: distance from the Sun.
const Offset _kS2Sun = Offset(60, 170);
const double _kS2SunRadius = 40;
const double _kAuPx = 320;
const double _kMinAu = 0.5;
const double _kMaxAu = 2.0;
const double _kStartAu = 1.0;

/// Liquid-water range of the model below (0 °C < T < 100 °C).
const double _kZoneInner = 0.6;
const double _kZoneOuter = 1.1;

/// T(K) = 288 / √d: the planet keeps Earth's air and only its distance d
/// (AU) changes. The source's straight lines (+200 °C per AU inward, -120
/// outward) are replaced by this simple energy balance.
double _earthTempC(double au) => 288 / math.sqrt(au) - 273;

// Scenario 3: the magnetic shield.
const Offset _kS3Sun = Offset(-50, 170);
const double _kS3SunRadius = 125;
const Offset _kS3Earth = Offset(520, 175);
const double _kS3EarthRadius = 64;

/// Flow (%) at which the field first shows (finishes step 2).
const double _kFieldStart = 20;

/// Flow (%) at which every particle is steered away (finishes step 3). The
/// field's strength and the share of particles steered away both grow up to
/// this one value (the source used 10, 50 and 80 %).
const double _kShieldFlow = 70;

// Scenario 4: gravity and the air.
const Offset _kS4Planet = Offset(380, 176);
const double _kS4Radius = 66;
const double _kMarsMass = 11;
const double _kMoonMass = 1.2;

/// Step 2 is done at or below this mass (% of Earth's).
const double _kLeakMass = 15;
const int _kMoleculesPerKind = 16;

/// Highest hop drawn, so every molecule stays on the stage.
const double _kMaxHop = 96;

// Scenario 5: losing the field.
const Offset _kS5Earth = Offset(500, 182);
const double _kS5EarthRadius = 66;
const double _kProtectionEnd = 40;
const double _kFastForward = 3;

/// Where each event (A-D) is drawn and where its drop badge sits.
const Map<String, Offset> _kEventSpot = {
  'A': Offset(447, 128),
  'B': Offset(452, 230),
  'C': Offset(668, 118),
  'D': Offset(596, 50),
};
const Map<String, Offset> _kEventBadge = {
  'A': Offset(392, 92),
  'B': Offset(400, 270),
  'C': Offset(706, 168),
  'D': Offset(650, 36),
};

/// The event each correct consequence explains; the other two chips are
/// distractors that fit nowhere.
const Map<String, String> _kChipEvent = {
  'air': 'A',
  'radiation': 'B',
  'navigation': 'C',
  'satellites': 'D',
};
const List<String> _kChips = [
  'radiation',
  'oceans',
  'satellites',
  'air',
  'gravity',
  'navigation',
];

/// Colour of scenario 4's lighter gas molecules.
const Color _kLightGas = Color(0xFF67E8F9);

/// [from] easing to [to] over [seconds] from clock time [startedAt].
double _eased(
  double from,
  double to,
  double startedAt,
  double seconds,
  double now,
) {
  final k = ((now - startedAt) / seconds).clamp(0.0, 1.0);
  return from + (to - from) * Curves.easeInOut.transform(k);
}

/// Scenario 5's protection level: 100 % until time is fast-forwarded at
/// [startedAt] (infinity: not yet), then falling slowly to
/// [_kProtectionEnd].
double _protectionAt(double startedAt, double now) =>
    _eased(100, _kProtectionEnd, startedAt, _kFastForward, now);

const List<Color> _kConfettiColors = [
  Color(0xFF6366F1),
  Color(0xFF38BDF8),
  Color(0xFF4ADE80),
  Colors.white,
];

// ------------------------------------------------------------------ model ----

/// One gas molecule of scenario 4. It hops from the surface and falls back
/// toward the planet's centre; on each landing it may leave for good.
class _Molecule {
  _Molecule({required this.light, required this.angle}) : nextAngle = angle;

  final bool light;

  /// Where the current hop took off / lands, radians round the planet.
  double angle;
  double nextAngle;

  /// Height of the current hop (px) and its timing (clock seconds).
  double apex = 0;
  double hopStart = 0;
  double period = 1;

  /// Clock time it escaped (null while it is still held).
  double? escapedAt;

  /// Distance above the surface at [now] (escaping molecules fly straight
  /// out), or null once it has left the stage.
  double? altitude(double now) {
    final gone = escapedAt;
    if (gone != null) {
      final out = 150 * (now - gone);
      return out > 420 ? null : out;
    }
    final s = ((now - hopStart) / period).clamp(0.0, 1.0);
    return apex * 4 * s * (1 - s);
  }

  double angleAt(double now) {
    if (escapedAt != null) return nextAngle;
    final s = ((now - hopStart) / period).clamp(0.0, 1.0);
    return angle + (nextAngle - angle) * s;
  }
}

// ------------------------------------------------------------------- page ----

class Cl8Ch15A1UniqueConditionsLifeEarthPage extends StatefulWidget {
  const Cl8Ch15A1UniqueConditionsLifeEarthPage({super.key});

  @override
  State<Cl8Ch15A1UniqueConditionsLifeEarthPage> createState() =>
      _Cl8Ch15A1UniqueConditionsLifeEarthPageState();
}

class _Cl8Ch15A1UniqueConditionsLifeEarthPageState
    extends State<Cl8Ch15A1UniqueConditionsLifeEarthPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.5,
    max: 2.5,
  );
  final math.Random _random = math.Random();
  final ScrollController _workspaceScroll = ScrollController();

  /// Seconds since the page opened; every animation is driven by real time
  /// (the source's rates were per frame).
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker = createTicker(_onTick);

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  final List<Timer> _timers = [];

  // Shared. Step 0 = the setup board; past step 3 the scenario is done.
  int _scenario = 1;
  int _step = 0;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  Size _stageViewport = Size.zero;

  /// Set when an action has started a timed step change; blocks repeats.
  bool _busy = false;

  /// Wrong answers per scenario and the scenarios finished, for the final
  /// report (the source counted mistakes in scenario 5 only).
  final List<int> _mistakes = List.filled(6, 0);
  final Set<int> _completed = {};

  // Scenarios 1 and 4: the step-3 question.
  int? _quizPick;
  bool _quizSolved = false;

  // Scenario 1.
  bool _followed = false;
  int _co2 = 0;
  double _tempFrom = _kVenusTemps[0];
  double _tempTo = _kVenusTemps[0];
  double _tempAt = 0;

  // Scenario 2.
  double _au = _kStartAu;

  // Scenario 3.
  bool _inside = false;
  double _flow = 0;

  // Scenario 4.
  bool _measured = false;
  double _mass = 100;
  final List<_Molecule> _molecules = [];
  int _escapedLight = 0;
  int _escapedHeavy = 0;
  math.Random _gasRandom = math.Random(4);

  // Scenario 5.
  bool _fieldOn = true;
  bool _fastForwarded = false;
  double _protectAt = double.infinity;
  String? _selectedChip;
  final Map<String, String> _placed = {};

  // ------------------------------------------------------------ lifecycle --
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker.start();
    _enterScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cancelTimers();
    _confettiEntry?.remove();
    _confettiEntry = null;
    _ticker.dispose();
    _clock.dispose();
    _confetti.dispose();
    _zoom.dispose();
    _workspaceScroll.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    if (_scenario == 4 && _step >= 1) _stepGas(now);
    _clock.value = now;
  }

  // ---------------------------------------------------------------- timers --
  void _after(int ms, VoidCallback action) {
    late final Timer timer;
    timer = Timer(Duration(milliseconds: ms), () {
      _timers.remove(timer);
      if (mounted) action();
    });
    _timers.add(timer);
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  // ---------------------------------------------------------- shared state --
  /// Every scenario has three steps.
  int get _stepCount => 3;

  bool get _boardOpen => _step == 0;

  bool get _done => _step > _stepCount;

  /// Runs [action] after [ms] if the lab is still in scenario [scenario],
  /// step [step] (a scenario switch or restart cancels it).
  void _afterStep(int ms, int scenario, int step, VoidCallback action) {
    _after(ms, () {
      if (_scenario == scenario && _step == step) action();
    });
  }

  void _info(String text) {
    _shell.showToast(text, color: _rt_Tw.blue600, icon: Icons.info_outline);
  }

  void _good(String text) {
    _rt_playSfx(_rt_Sfx.correct);
    _shell.showToast(text, color: _rt_Tw.green600, icon: Icons.check_circle);
  }

  void _bad(String text) {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(
      text,
      color: _rt_Tw.red500,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// The source's `loadScenario` (state only; call inside `setState`).
  void _enterScenario(int scenario) {
    _scenario = scenario;
    _step = 0;
    _toggledTiles.clear();
    _busy = false;
    _quizPick = null;
    _quizSolved = false;
    _followed = false;
    _co2 = 0;
    _tempFrom = _kVenusTemps[0];
    _tempTo = _kVenusTemps[0];
    _tempAt = 0;
    _au = _kStartAu;
    _inside = false;
    _flow = 0;
    _measured = false;
    _mass = 100;
    _seedGas();
    _fieldOn = true;
    _fastForwarded = false;
    _protectAt = double.infinity;
    _selectedChip = null;
    _placed.clear();
  }

  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() => _enterScenario(scenario));
    _zoom.reset();
    if (_workspaceScroll.hasClients) _workspaceScroll.jumpTo(0);
  }

  /// The source's `resetApp`, minus its bugs: the language stays as it is
  /// and every timer is cancelled.
  void _restart() {
    _changeScenario(1);
    setState(() {
      _showLabels = true;
      _panMode = false;
      _mistakes.fillRange(0, _mistakes.length, 0);
      _completed.clear();
    });
  }

  void _startFromBoard() {
    if (!_boardOpen) return;
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _step = 1;
      if (_scenario == 4) _seedGas();
    });
    _revealPanel();
  }

  /// Moves to [step]; past the last step the summary follows.
  void _advanceTo(int step) {
    setState(() {
      _step = step;
      _toggledTiles.clear();
      _busy = false;
      if (step > _stepCount) _completed.add(_scenario);
    });
    if (step > _stepCount) {
      _rt_playSfx(_rt_Sfx.success);
      _afterStep(600, _scenario, step, _showSummary);
    } else {
      _revealPanel();
    }
  }

  /// Leaves a finished scenario (summary button or the HUD button).
  void _goOn() {
    _rt_playSfx(_rt_Sfx.click);
    if (_scenario >= 5) {
      _restart();
    } else {
      _changeScenario(_scenario + 1);
    }
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  void _togglePanMode() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _panMode = !_panMode);
  }

  /// Zooms the stage about its centre, keeping any pan.
  void _zoomBy(double factor) {
    final current = _zoom.scale;
    final target = (current * factor).clamp(_zoom.min, _zoom.max);
    final relative = target / current;
    if ((relative - 1).abs() < 1e-6) return;
    final centre = _stageViewport.center(Offset.zero);
    final step = Matrix4.identity()
      ..translateByDouble(centre.dx, centre.dy, 0, 1)
      ..scaleByDouble(relative, relative, relative, 1)
      ..translateByDouble(-centre.dx, -centre.dy, 0, 1);
    _zoom.transform.value = step.multiplied(_zoom.transform.value);
  }

  // --------------------------------------------------------------- dialogs --
  /// The source's completion overlay, now with a button that moves on (the
  /// source pointed at a dropdown hidden on phones). Scenario 5 adds the
  /// source's diagnostics report.
  void _showSummary() {
    final scenario = _scenario;
    final last = scenario >= 5;
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _kAccent,
      buttonLabel: _tx.s(last ? 'restartLab' : 'nextScenario'),
      body: _SummaryBody(
        heading: _tx.s('keyTakeaway'),
        lead: _tx.s('scenarios.$scenario.summaryLead'),
        text: _tx.s('scenarios.$scenario.summary'),
        footer: _tx.s('scenarioComplete'),
        report: last ? _report() : null,
      ),
      onConfirm: () {
        if (_scenario == scenario && _done) _goOn();
      },
    );
    _launchConfetti();
  }

  /// A scenario is mastered when it was finished with at most one wrong
  /// answer (the source's rule); unfinished ones are to review.
  Widget _report() {
    final mastered = <String>[];
    final review = <String>[];
    for (var s = 1; s <= 5; s++) {
      final name = _tx.s('report.concepts.${s - 1}');
      (_completed.contains(s) && _mistakes[s] <= 1 ? mastered : review).add(
        name,
      );
    }
    return _ReportCard(
      title: _tx.s('report.title'),
      masteredTitle: _tx.s('report.mastered'),
      reviewTitle: _tx.s('report.review'),
      mastered: mastered,
      review: review,
      masteredNone: _tx.s('report.masteredNone'),
      reviewNone: _tx.s('report.reviewNone'),
    );
  }

  void _launchConfetti() {
    _confettiEntry?.remove();
    final pieces = List.generate(100, (_) => _ConfettiPiece.random(_random));
    final entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: CustomPaint(
          painter: _ConfettiPainter(_confetti, pieces),
          child: const SizedBox.expand(),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    _confettiEntry = entry;
    _confetti.forward(from: 0).whenCompleteOrCancel(() {
      if (_confettiEntry == entry) {
        entry.remove();
        _confettiEntry = null;
      }
    });
  }

  // ---------------------------------------------------- step-3 questions --
  /// Scenarios 1 and 4 end with a question; the right option.
  int get _quizAnswer => _scenario == 1 ? 1 : 0;

  void _answer(int option) {
    if ((_scenario != 1 && _scenario != 4) || _step != 3 || _quizSolved) {
      return;
    }
    final text = _tx.s('s$_scenario.feedback.$option');
    if (option != _quizAnswer) {
      _mistakes[_scenario]++;
      setState(() => _quizPick = option);
      _bad(text);
      return;
    }
    setState(() {
      _quizPick = option;
      _quizSolved = true;
    });
    _good(text);
    _afterStep(1400, _scenario, 3, () => _advanceTo(4));
  }

  // ------------------------------------------------------ scenario 1 logic --
  /// Venus's temperature at clock time [now], easing to the new level.
  double _venusTemp(double now) =>
      _eased(_tempFrom, _tempTo, _tempAt, _kTempEase, now);

  /// Step 1: follow one sunbeam to the surface and back out as infrared.
  void _followSunlight() {
    if (_scenario != 1 || _step != 1 || _followed) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _followed = true);
    _info(_tx.s('s1.followed'));
    _afterStep(1800, 1, 1, () => _advanceTo(2));
  }

  /// Step 2: the source's "Inject CO₂" (+20 %), now in amounts of air. The
  /// temperature follows the CO₂ only (the source heated Venus to 470 °C
  /// even with no CO₂ at all).
  void _changeCo2(int delta) {
    if (_scenario != 1 || _step != 2 || _busy) return;
    final level = (_co2 + delta).clamp(0, _kCo2Max);
    if (level == _co2) return;
    _rt_playSfx(_rt_Sfx.pop);
    final now = _clock.value;
    setState(() {
      _tempFrom = _venusTemp(now);
      _tempTo = _kVenusTemps[level];
      _tempAt = now;
      _co2 = level;
    });
    if (level == _kCo2Max) {
      _busy = true;
      _afterStep((_kTempEase * 1000).round() + 300, 1, 2, () {
        _good(_tx.s('s1.real'));
        _advanceTo(3);
      });
    }
  }

  // ------------------------------------------------------ scenario 2 logic --
  double get _earthTemp => _earthTempC(_au);

  String get _waterState {
    final t = _earthTemp;
    if (t >= 100) return 'steam';
    if (t <= 0) return 'ice';
    return 'liquid';
  }

  /// The source's distance slider, rounded to 0.1 AU (it compared floats
  /// with `===`).
  void _setAu(double au) {
    if (_scenario != 2 || _step < 1 || _done) return;
    final d = ((au * 10).round() / 10).clamp(_kMinAu, _kMaxAu).toDouble();
    if (d == _au) return;
    setState(() => _au = d);
    _checkWater();
  }

  /// Step 1 needs the boiling side and step 2 the frozen side before step 3
  /// (back to liquid) can finish: the source finished as soon as the slider
  /// crossed 1.0 AU, before either extreme was seen.
  void _checkWater() {
    if (_busy || _scenario != 2 || _step < 1 || _done) return;
    final (want, toast) = switch (_step) {
      1 => ('steam', 'boiled'),
      2 => ('ice', 'frozen'),
      _ => ('liquid', 'liquid'),
    };
    if (_waterState != want) return;
    _busy = true;
    final step = _step;
    final text = _tx.s('s2.$toast').replaceAll('{d}', _au.toStringAsFixed(1));
    if (step == 3) {
      _good(text);
    } else {
      _info(text);
    }
    _afterStep(1400, 2, step, () {
      _advanceTo(step + 1);
      // Earth may already be where the next step wants it.
      _checkWater();
    });
  }

  // ------------------------------------------------------ scenario 3 logic --
  /// Share of the solar wind the field steers away (0-1).
  double get _deflected => (_flow / _kShieldFlow).clamp(0.0, 1.0);

  void _lookInside() {
    if (_scenario != 3 || _step != 1 || _inside) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _inside = true);
    _info(_tx.s('s3.insideToast'));
    _afterStep(1800, 3, 1, () => _advanceTo(2));
  }

  void _setFlow(double flow) {
    if (_scenario != 3 || (_step != 2 && _step != 3)) return;
    final value = flow.clamp(0.0, 100.0).roundToDouble();
    if (value == _flow) return;
    setState(() => _flow = value);
    _checkFlow();
  }

  void _checkFlow() {
    if (_busy) return;
    if (_step == 2 && _flow >= _kFieldStart) {
      _busy = true;
      _good(_tx.s('s3.fieldOn'));
      _afterStep(1500, 3, 2, () {
        _advanceTo(3);
        _checkFlow();
      });
    } else if (_step == 3 && _flow >= _kShieldFlow) {
      _busy = true;
      _good(_tx.s('s3.shield'));
      _afterStep(1500, 3, 3, () {
        if (_flow >= _kShieldFlow) {
          _advanceTo(4);
        } else {
          _busy = false;
        }
      });
    }
  }

  // ------------------------------------------------------ scenario 4 logic --
  /// Earth's 9.8 m/s² and 11.2 km/s for a planet of Earth's size with
  /// [_mass] % of its mass: g ∝ M and v ∝ √M (the source used 11.2 × M and
  /// shrank the planet too, so its gravity barely changed).
  double get _gravity => 9.8 * _mass / 100;
  double get _escapeSpeed => 11.2 * math.sqrt(_mass / 100);

  void _seedGas() {
    _gasRandom = math.Random(4);
    _molecules.clear();
    _escapedLight = 0;
    _escapedHeavy = 0;
    final now = _clock.value;
    for (var i = 0; i < _kMoleculesPerKind * 2; i++) {
      final molecule = _Molecule(
        light: i.isEven,
        angle: i / (_kMoleculesPerKind * 2) * math.pi * 2,
      );
      _hop(molecule, now);
      molecule.hopStart = now - _gasRandom.nextDouble() * molecule.period;
      _molecules.add(molecule);
    }
  }

  /// Chance that a molecule leaving the surface escapes: tiny for a planet
  /// as massive as Earth, larger for lighter gases on lighter planets (a
  /// simple Jeans-escape picture: thermal speed against escape speed).
  double _escapeChance(bool light) {
    if (_mass >= 50) return 0;
    final spread = light ? 0.2 : 0.1;
    return math.exp(-(_mass / 100) / (2 * spread * spread));
  }

  /// Starts the next hop: weaker gravity means higher, slower hops.
  void _hop(_Molecule molecule, double now) {
    final g = _mass / 100;
    final base = molecule.light
        ? 18 + _gasRandom.nextDouble() * 42
        : 8 + _gasRandom.nextDouble() * 22;
    molecule
      ..angle = molecule.nextAngle
      ..nextAngle = molecule.angle + (_gasRandom.nextDouble() - 0.5) * 0.5
      ..apex = math.min(_kMaxHop, base / math.sqrt(g))
      ..hopStart = now;
    molecule.period = 0.5 + molecule.apex / 60;
  }

  void _stepGas(double now) {
    var escaped = false;
    for (final molecule in _molecules) {
      if (molecule.escapedAt != null) continue;
      if (now < molecule.hopStart + molecule.period) continue;
      if (_gasRandom.nextDouble() < _escapeChance(molecule.light)) {
        molecule
          ..angle = molecule.nextAngle
          ..escapedAt = now;
        if (molecule.light) {
          _escapedLight++;
        } else {
          _escapedHeavy++;
        }
        escaped = true;
      } else {
        _hop(molecule, now);
      }
    }
    if (escaped) setState(() {});
  }

  void _measureGravity() {
    if (_scenario != 4 || _step != 1 || _measured) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _measured = true);
    _info(_tx.s('s4.measured'));
    _afterStep(1800, 4, 1, () => _advanceTo(2));
  }

  void _setMass(double mass) {
    if (_scenario != 4 || (_step != 2 && _step != 3)) return;
    final value = mass.clamp(1.0, 100.0).toDouble();
    if (value == _mass) return;
    setState(() => _mass = value);
    if (_step == 2 && !_busy && _mass <= _kLeakMass) {
      _busy = true;
      _info(_tx.s('s4.leaking'));
      _afterStep(3500, 4, 2, () => _advanceTo(3));
    }
  }

  // ------------------------------------------------------ scenario 5 logic --
  /// The protection level: 100 % with the field, then falling slowly to
  /// [_kProtectionEnd] while time is fast-forwarded (the source's "life
  /// health" fell to 0 in seconds, at a frame-rate dependent speed).
  double _protection(double now) => _protectionAt(_protectAt, now);

  void _switchFieldOff() {
    if (_scenario != 5 || _step != 1 || !_fieldOn) return;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _fieldOn = false);
    _info(_tx.s('s5.fieldOff'));
    _afterStep(1500, 5, 1, () => _advanceTo(2));
  }

  void _fastForward() {
    if (_scenario != 5 || _step != 2 || _fastForwarded) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _fastForwarded = true;
      _protectAt = _clock.value;
    });
    _afterStep((_kFastForward * 1000).round() + 300, 5, 2, () {
      _info(_tx.s('s5.ffDone'));
      _advanceTo(3);
    });
  }

  void _selectChip(String chip) {
    if (_scenario != 5 || _step != 3 || _placed.containsKey(chip)) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _selectedChip = _selectedChip == chip ? null : chip);
  }

  void _tapEvent(String event) {
    if (_scenario != 5 || _step != 3 || _placed.containsValue(event)) return;
    final chip = _selectedChip;
    if (chip == null) {
      _info(_tx.s('s5.pickFirst'));
      return;
    }
    _place(chip, event);
  }

  /// Drops consequence [chip] on [event]; distractors and wrong events are
  /// explained in a toast (the source only buzzed).
  void _place(String chip, String event) {
    if (_scenario != 5 || _step != 3 || _busy) return;
    if (_placed.containsKey(chip) || _placed.containsValue(event)) return;
    final target = _kChipEvent[chip];
    if (target != event) {
      _mistakes[5]++;
      setState(() => _selectedChip = null);
      _bad(
        target == null ? _tx.s('s5.distractor.$chip') : _tx.s('s5.wrongEvent'),
      );
      return;
    }
    setState(() {
      _placed[chip] = event;
      _selectedChip = null;
    });
    _good(_tx.s('s5.right.$chip'));
    if (_placed.length == _kChipEvent.length) {
      _busy = true;
      _afterStep(1500, 5, 3, () {
        _good(_tx.s('s5.allMatched'));
        _advanceTo(4);
      });
    }
  }

  // ----------------------------------------------------------------- build --
  final GlobalKey _panelKey = GlobalKey();

  /// On phones the panel sits under the stage: bring it into view when a
  /// step changes so its controls are never off screen.
  void _revealPanel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _panelKey.currentContext;
      if (!mounted || context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, _) => _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('title'),
          subtitle: _tx.s('subtitle'),
          theme: const _rt_ShellTheme(
            accent: _kAccent,
            headerGradient: [_rt_Tw.slate950, _rt_Tw.indigo900],
            headerSubtitleColor: _rt_Tw.indigo100,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.public,
            footnote: _tx.s('footnote'),
          ),
          onRestart: _restart,
          onZoomIn: () => _zoomBy(1.25),
          onZoomOut: () => _zoomBy(0.8),
          onResetView: _zoom.reset,
          toolbarExtras: [
            _ToolbarToggle(
              key: const ValueKey('labels-toggle'),
              active: _showLabels,
              icon: _showLabels ? Icons.label : Icons.label_off,
              tooltip: _tx.s('toggleLabels'),
              onTap: _toggleLabels,
            ),
            const SizedBox(height: 4),
            _ToolbarToggle(
              key: const ValueKey('pan-toggle'),
              active: _panMode,
              icon: _panMode ? Icons.pan_tool : Icons.pan_tool_outlined,
              tooltip: _tx.s('panMode'),
              onTap: _togglePanMode,
            ),
          ],
          tabs: [
            _rt_ShellTab(
              label: _tx.s('tabGuide'),
              icon: Icons.menu_book,
              builder: (_) => _sidebar(),
            ),
          ],
          canvas: _workspace(),
          canvasOverlays: [
            if (_step >= 1)
              Positioned(
                top: 8,
                left: 72,
                right: 72,
                child: Center(child: _hud()),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- sidebar --
  Widget _sidebar() {
    final done = _done;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObjective'),
          desc: _tx.s('scenarios.$_scenario.objective'),
          accent: _kAccent,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('selectScenario'),
                icon: Icons.public,
                color: _kAccent,
              ),
              for (var scenario = 1; scenario <= 5; scenario++)
                _rt_ChoiceButton(
                  key: ValueKey('scn$scenario'),
                  label: _tx.s('scenarios.$scenario.title'),
                  state: _scenario == scenario
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: _scenario == scenario
                      ? null
                      : () {
                          _rt_playSfx(_rt_Sfx.click);
                          _changeScenario(scenario);
                        },
                ),
              const SizedBox(height: 10),
              _rt_SectionLabel(
                _tx.s('explorationSteps'),
                icon: Icons.format_list_numbered,
              ),
              for (var i = 1; i <= _stepCount; i++)
                _StepTile(
                  key: ValueKey('tile-$_scenario-$i'),
                  number: i,
                  title: '${_tx.s('step')} $i',
                  focusLabel: _tx.s('focus'),
                  focus: _tx.s('scenarios.$_scenario.steps.${i - 1}.concept'),
                  actionLabel: _tx.s('action'),
                  action: _tx.s('scenarios.$_scenario.steps.${i - 1}.action'),
                  observationLabel: _tx.s('observation'),
                  // Shown once the step is done, so the sidebar never
                  // answers a step before it is tried.
                  observation: i < _step
                      ? _tx.s('scenarios.$_scenario.steps.${i - 1}.observation')
                      : null,
                  status: i < _step
                      ? _TileStatus.done
                      : (i == _step
                            ? _TileStatus.active
                            : _TileStatus.upcoming),
                  expanded: (i == _step) != _toggledTiles.contains(i),
                  onToggle: () {
                    _rt_playSfx(_rt_Sfx.tap);
                    setState(() {
                      if (!_toggledTiles.remove(i)) _toggledTiles.add(i);
                    });
                  },
                ),
              const SizedBox(height: 4),
              // The source's "Evidence / Hint" box, swapped for the learnt
              // conclusion once the scenario is solved.
              _rt_InfoCard(
                key: const ValueKey('hint-card'),
                title: _tx.s(done ? 'learnt' : 'hint'),
                body: _tx.s(
                  done
                      ? 'scenarios.$_scenario.summary'
                      : 'scenarios.$_scenario.hint',
                ),
                color: done ? _rt_Tw.green600 : _rt_Tw.amber500,
                icon: done ? Icons.school : Icons.lightbulb,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ HUD --
  /// The current task (the source showed none on phones). Once the scenario
  /// is done it keeps a Next / Restart button, so closing the summary is
  /// never a dead end.
  Widget _hud() {
    final done = _done;
    final last = _scenario >= 5;
    final accent = _rt_Lab.onTinted(_kAccentSoft, _rt_Tw.indigo600);
    final card = Container(
      key: const ValueKey('hud'),
      constraints: const BoxConstraints(maxWidth: 540),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAccent.withValues(alpha: 0.45)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                _tx.s('currentTask').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            done
                ? _tx.s(last ? 'allDone' : 'doneHud')
                : _tx.s('scenarios.$_scenario.hud.$_step'),
            key: const ValueKey('hud-text'),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _rt_Lab.text,
              height: 1.3,
            ),
          ),
          if (done) ...[
            const SizedBox(height: 6),
            _rt_ActionButton(
              key: const ValueKey('btn-hud-next'),
              label: _tx.s(last ? 'restartLab' : 'nextScenario'),
              icon: last ? Icons.replay : Icons.arrow_forward,
              color: _kAccent,
              onPressed: _goOn,
            ),
          ],
        ],
      ),
    );
    return done ? card : IgnorePointer(child: card);
  }

  // -------------------------------------------------------------- workspace --
  /// The setup board, then the scenario's stage and its control panel
  /// (beside the stage on wide screens, under it on phones).
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight < _kShortHeight;
        if (_boardOpen) {
          return Center(
            child: SingleChildScrollView(
              key: const ValueKey('board-scroll'),
              padding: const EdgeInsets.fromLTRB(16, 16, 60, 16),
              child: _setupBoard(short: short),
            ),
          );
        }
        final topInset = short ? 84.0 : 104.0;
        final width = math.max(0.0, constraints.maxWidth - 12 - 60);
        final available = constraints.maxHeight - topInset - 16;
        final side = width >= _kSideBySideWidth;
        final panelWidth = width >= 900 ? _kPanelWidth : 220.0;
        final Widget content = side
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _stageBox(width - panelWidth - 16, available),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: panelWidth,
                    child: Padding(
                      // Clear of the shell's toast (top 140 of the canvas).
                      padding: EdgeInsets.only(top: short ? 0 : 126),
                      child: _panel(compact: short),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _stageBox(width, math.max(150.0, available - 76)),
                  const SizedBox(height: 10),
                  _panel(compact: true),
                ],
              );
        return SingleChildScrollView(
          key: const ValueKey('workspace'),
          controller: _workspaceScroll,
          padding: EdgeInsets.fromLTRB(12, topInset, 60, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: content,
            ),
          ),
        );
      },
    );
  }

  /// Scales the fixed-size stage to fit; zoom / pan only in pan mode, so
  /// the workspace still scrolls.
  Widget _stageBox(double width, double maxHeight) {
    final aspect = _kStage.width / _kStage.height;
    final fitWidth = math.max(
      0.0,
      math.min(math.min(width, _kStage.width * 1.2), maxHeight * aspect),
    );
    final size = Size(fitWidth, fitWidth / aspect);
    _stageViewport = size;
    return Center(
      child: SizedBox.fromSize(
        size: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: InteractiveViewer(
            transformationController: _zoom.transform,
            panEnabled: _panMode,
            scaleEnabled: _panMode,
            minScale: _zoom.min,
            maxScale: _zoom.max,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox.fromSize(
                key: ValueKey('stage-$_scenario'),
                size: _kStage,
                child: _stage(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fades a stage label with the labels toggle.
  Widget _label(Widget child) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showLabels ? 1 : 0,
        child: child,
      ),
    );
  }

  /// A small stage label centred on [at] (design px).
  Widget _tag(
    Offset at,
    String text, {
    Color color = Colors.white,
    double width = 160,
    double size = 13,
    Key? key,
  }) {
    return Positioned(
      left: at.dx - width / 2,
      top: at.dy - 10,
      width: width,
      child: _label(
        Text(
          text,
          key: key,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1.2,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _stage() {
    final CustomPainter painter = switch (_scenario) {
      1 => _VenusPainter(
        clock: _clock,
        co2: _co2,
        followed: _followed,
        tempFrom: _tempFrom,
        tempTo: _tempTo,
        tempAt: _tempAt,
      ),
      2 => _OrbitPainter(clock: _clock, au: _au, showZone: _step >= 3),
      3 => _ShieldPainter(
        clock: _clock,
        earth: _kS3Earth,
        radius: _kS3EarthRadius,
        sun: _kS3Sun,
        sunRadius: _kS3SunRadius,
        field: _deflected,
        deflected: _deflected,
        inside: _inside,
        flow: _flow / 100,
      ),
      4 => _GravityPainter(
        clock: _clock,
        molecules: _molecules,
        gravity: _mass / 100,
      ),
      _ => _ShieldPainter(
        clock: _clock,
        earth: _kS5Earth,
        radius: _kS5EarthRadius,
        sun: _kS3Sun,
        sunRadius: _kS3SunRadius,
        field: _fieldOn ? 1 : 0,
        deflected: _fieldOn ? 1 : 0,
        events: !_fieldOn,
        protectAt: _protectAt,
      ),
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _onStageTap(details.localPosition),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: painter)),
          ),
          ...switch (_scenario) {
            1 => _venusTags(),
            2 => _orbitTags(),
            3 => _shieldTags(),
            4 => _gravityTags(),
            _ => _fieldLossTags(),
          },
        ],
      ),
    );
  }

  /// Taps on the planet stand in for the panel buttons (the source had no
  /// tap targets on its canvas except in scenario 5).
  void _onStageTap(Offset at) {
    if (_scenario == 1 && (at - _kVenus).distance <= _kVenusRadius + 24) {
      _followSunlight();
    } else if (_scenario == 3 && (at - _kS3Earth).distance <= _kS3EarthRadius) {
      _lookInside();
    } else if (_scenario == 4 &&
        (at - _kS4Planet).distance <= _kS4Radius + 10) {
      _measureGravity();
    }
  }

  // ------------------------------------------------------------ stage tags --
  List<Widget> _venusTags() {
    final shell = _kCo2Shell[_co2];
    return [
      _tag(const Offset(70, 30), _tx.s('sun'), color: _rt_Tw.amber200),
      _tag(
        Offset(_kVenus.dx, _kVenus.dy + _kVenusRadius + 16),
        '${_tx.s('s1.venus')}\n${_tx.s('s1.venusDist')}',
        width: 220,
      ),
      Positioned(
        left: _kVenus.dx - 60,
        top: _kVenus.dy - _kVenusRadius - shell - 40,
        width: 120,
        child: Center(
          child: ValueListenableBuilder<double>(
            valueListenable: _clock,
            builder: (context, now, _) {
              final temp = _venusTemp(now);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    _rt_Tw.orange600,
                    _rt_Tw.red600,
                    ((temp - 50) / 415).clamp(0.0, 1.0),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white54),
                ),
                child: Text(
                  '${temp.round()} °C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      _tag(
        const Offset(235, 138),
        _tx.s('s1.sunlight'),
        color: _rt_Tw.yellow400,
      ),
      _tag(const Offset(660, 300), _tx.s('s1.infrared'), color: _rt_Tw.red400),
      // Content fix: the source never showed Mercury; its numbers were
      // only in the hint (and "430 °C" was its daytime maximum).
      Positioned(
        right: 12,
        top: 12,
        width: 196,
        child: _label(
          Container(
            key: const ValueKey('mercury-card'),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: _rt_Tw.slate900.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Tw.slate500),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFD6D3D1), Color(0xFF57534E)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tx.s('s1.mercury'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                for (final line in _tx.list('s1.mercuryLines'))
                  Text(
                    '• $line',
                    style: const TextStyle(
                      color: _rt_Tw.slate200,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      _tag(
        const Offset(80, 322),
        _tx.s('notToScale'),
        color: _rt_Tw.slate400,
        size: 11,
      ),
    ];
  }

  double _auX(double au) => _kS2Sun.dx + au * _kAuPx;

  List<Widget> _orbitTags() {
    final x = _auX(_au);
    final state = _waterState;
    return [
      _tag(
        Offset(_kS2Sun.dx, _kS2Sun.dy + _kS2SunRadius + 22),
        _tx.s('sun'),
        color: _rt_Tw.amber200,
        width: 100,
      ),
      _tag(
        Offset(x, _kS2Sun.dy - 46),
        '${_earthTemp.round()} °C',
        color: switch (state) {
          'steam' => _rt_Tw.red400,
          'ice' => const Color(0xFFBAE6FD),
          _ => _rt_Tw.green400,
        },
        size: 15,
        width: 110,
      ),
      _tag(Offset(x, _kS2Sun.dy + 34), _tx.s('earth'), width: 110, size: 12),
      for (final d in const [0.5, 1.0, 1.5, 2.0])
        _tag(
          Offset(_auX(d), 300),
          _tx.s('s2.au').replaceAll('{d}', d.toStringAsFixed(1)),
          color: _rt_Tw.slate300,
          size: 11.5,
          width: 70,
        ),
      if (_step >= 3)
        _tag(
          Offset((_auX(_kZoneInner) + _auX(_kZoneOuter)) / 2, 26),
          _tx.s('s2.zone'),
          color: _rt_Tw.green400,
          width: 200,
        ),
      // The source's "WATER STATE" box.
      Positioned(
        right: 12,
        top: 12,
        width: 150,
        child: _label(
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            decoration: BoxDecoration(
              color: _rt_Tw.slate900.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Tw.slate600),
            ),
            child: Column(
              children: [
                Text(
                  _tx.s('s2.water').toUpperCase(),
                  style: const TextStyle(
                    color: _rt_Tw.slate300,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(
                  height: 46,
                  width: 90,
                  child: CustomPaint(
                    painter: _WaterDotsPainter(clock: _clock, state: state),
                  ),
                ),
                Text(
                  _tx.s('s2.states.$state'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      _tag(
        const Offset(170, 322),
        '${_tx.s('notToScale')} • ${_tx.s('s2.model')}',
        color: _rt_Tw.slate400,
        size: 11,
        width: 330,
      ),
    ];
  }

  List<Widget> _shieldTags() {
    final c = _kS3Earth;
    return [
      _tag(const Offset(70, 30), _tx.s('sun'), color: _rt_Tw.amber200),
      _tag(const Offset(250, 30), _tx.s('s3.solarWind'), color: _rt_Tw.red400),
      if (_inside) ...[
        _tag(
          Offset(c.dx + 150, c.dy - 64),
          _tx.s('s3.outerCore'),
          color: _rt_Tw.orange400,
          width: 170,
        ),
        _tag(
          Offset(c.dx + 150, c.dy + 64),
          _tx.s('s3.innerCore'),
          color: _rt_Tw.amber200,
          width: 170,
        ),
      ],
      if (_deflected > 0)
        _tag(
          Offset(c.dx, c.dy - _kS3EarthRadius * 2.2 - 6),
          _tx.s('s3.field'),
          color: _rt_Tw.sky400,
        ),
      _tag(
        const Offset(80, 322),
        _tx.s('notToScale'),
        color: _rt_Tw.slate400,
        size: 11,
      ),
    ];
  }

  List<Widget> _gravityTags() {
    Widget dot(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    TextStyle style(Color color) =>
        TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w800);
    return [
      Positioned(
        left: 12,
        top: 12,
        child: _label(
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            decoration: BoxDecoration(
              color: _rt_Tw.slate900.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Tw.slate600),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    dot(_kLightGas, 8),
                    const SizedBox(width: 6),
                    Text(_tx.s('s4.light'), style: style(_kLightGas)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    dot(Colors.white, 10),
                    const SizedBox(width: 5),
                    Text(_tx.s('s4.heavy'), style: style(Colors.white)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _tx.s('s4.slowMotion'),
                  style: style(_rt_Tw.slate400).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
      _tag(
        Offset(_kS4Planet.dx + 250, 318),
        _tx.s('s4.pull'),
        color: _rt_Tw.amber200,
        size: 11.5,
        width: 220,
      ),
    ];
  }

  List<Widget> _fieldLossTags() {
    return [
      _tag(const Offset(70, 30), _tx.s('sun'), color: _rt_Tw.amber200),
      _tag(const Offset(250, 30), _tx.s('s3.solarWind'), color: _rt_Tw.red400),
      if (!_fieldOn) ...[
        for (final event in _kEventBadge.keys) _eventBadge(event),
        for (final entry in _placed.entries) _placedTag(entry.key, entry.value),
      ],
    ];
  }

  /// The neutral drop target of event [event] (the source's targets were
  /// labelled with the answers).
  Widget _eventBadge(String event) {
    final centre = _kEventBadge[event]!;
    final solved = _placed.containsValue(event);
    final open = _step == 3 && !solved && !_busy;
    return Positioned(
      left: centre.dx - 26,
      top: centre.dy - 26,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => open,
        onAcceptWithDetails: (details) => _place(details.data, event),
        builder: (context, candidates, _) {
          final hover = candidates.isNotEmpty;
          return GestureDetector(
            key: ValueKey('event-$event'),
            onTap: () => _tapEvent(event),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: solved
                    ? _rt_Tw.green600
                    : (hover ? _kAccent : Colors.black.withValues(alpha: 0.55)),
                border: Border.all(
                  color: solved
                      ? _rt_Tw.green400
                      : (open && _selectedChip != null
                            ? _rt_Tw.yellow400
                            : Colors.white70),
                  width: open ? 3 : 2,
                ),
              ),
              child: solved
                  ? const Icon(Icons.check, color: Colors.white, size: 26)
                  : Text(
                      event,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /// The placed consequence, written next to its event in green (the source
  /// wiped these labels once solved).
  Widget _placedTag(String chip, String event) {
    final badge = _kEventBadge[event]!;
    final below = event != 'A';
    return Positioned(
      left: (badge.dx - 75).clamp(4.0, _kStage.width - 154),
      top: below ? badge.dy + 30 : badge.dy - 64,
      width: 150,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _tx.s('s5.chips.$chip'),
          key: ValueKey('placed-$chip'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _rt_Tw.green400,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- setup board --
  static const List<IconData> _boardIcons = [
    Icons.thermostat,
    Icons.water_drop,
    Icons.shield,
    Icons.public,
    Icons.flash_on,
  ];

  Widget _setupBoard({required bool short}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('board-$_scenario'),
      tween: Tween(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: ((scale - 0.8) / 0.2).clamp(0, 1),
          child: child,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 576),
        child: Container(
          key: const ValueKey('board'),
          padding: EdgeInsets.symmetric(
            horizontal: short ? 20 : 32,
            vertical: short ? 18 : 30,
          ),
          decoration: BoxDecoration(
            color: _rt_Lab.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _kAccent.withValues(alpha: 0.5),
              width: 4,
            ),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _boardIcons[_scenario - 1],
                size: short ? 40 : 56,
                color: _kAccent,
              ),
              SizedBox(height: short ? 8 : 14),
              Text(
                _tx.s('scenarios.$_scenario.title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 17 : 23,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                  height: 1.35,
                ),
              ),
              SizedBox(height: short ? 8 : 12),
              Text(
                _tx.s('scenarios.$_scenario.boardDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 12.5 : 15,
                  fontWeight: FontWeight.w600,
                  color: _rt_Lab.onTinted(_rt_Tw.indigo100, _rt_Tw.slate600),
                  height: 1.4,
                ),
              ),
              SizedBox(height: short ? 14 : 24),
              _ChunkyButton(
                key: const ValueKey('board-btn'),
                label: _tx.s('scenarios.$_scenario.boardBtn'),
                color: _rt_Tw.indigo600,
                borderColor: _rt_Tw.indigo900,
                onPressed: _startFromBoard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- panel --
  /// The source's bottom HUD controls, one panel per scenario.
  Widget _panel({required bool compact}) {
    final children = switch (_scenario) {
      1 => _venusPanel(compact),
      2 => _orbitPanel(compact),
      3 => _shieldPanel(compact),
      4 => _gravityPanel(compact),
      _ => _fieldLossPanel(compact),
    };
    return Container(
      key: _panelKey,
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _caption(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: _rt_Lab.textMuted,
      ),
    ),
  );

  Widget _value(String text, {Key? key, Color? color, double size = 15}) =>
      Text(
        text,
        key: key,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          color: color ?? _rt_Lab.onTinted(_kAccentSoft, _rt_Tw.indigo600),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );

  /// A round − / + button (the touch-friendly twin of a slider).
  Widget _roundButton(String key, IconData icon, VoidCallback? onTap) {
    return InkResponse(
      key: ValueKey(key),
      radius: 22,
      onTap: onTap == null
          ? null
          : () {
              _rt_playSfx(_rt_Sfx.tap);
              onTap();
            },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap == null ? _rt_Lab.overlay : _kAccent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? _rt_Lab.textFaint : Colors.white,
        ),
      ),
    );
  }

  Widget _sliderRow({
    required String key,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required double step,
    required ValueChanged<double>? onChanged,
  }) {
    final live = onChanged != null;
    return Row(
      children: [
        _roundButton(
          '$key-minus',
          Icons.remove,
          live && value > min ? () => onChanged(value - step) : null,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: _kAccent,
              thumbColor: _kAccent,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              key: ValueKey('$key-slider'),
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        _roundButton(
          '$key-plus',
          Icons.add,
          live && value < max ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }

  /// The question that ends scenarios 1 and 4.
  List<Widget> _quiz(bool compact) {
    return [
      SizedBox(height: compact ? 6 : 10),
      _caption(_tx.s('quizTitle')),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          _tx.s('s$_scenario.quizQ'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.text,
            height: 1.3,
          ),
        ),
      ),
      for (var i = 0; i < 3; i++)
        _rt_ChoiceButton(
          key: ValueKey('quiz-$i'),
          label: _tx.s('s$_scenario.options.$i'),
          state: _quizPick != i
              ? _rt_ChoiceState.idle
              : (_quizSolved ? _rt_ChoiceState.correct : _rt_ChoiceState.wrong),
          onTap: _quizSolved ? null : () => _answer(i),
        ),
    ];
  }

  /// Read-outs side by side (phones) or stacked (side panel).
  Widget _readouts(bool compact, List<Widget> items) {
    if (!compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 2), child: item),
        ],
      );
    }
    return Wrap(spacing: 14, runSpacing: 2, children: items);
  }

  List<Widget> _venusPanel(bool compact) {
    final live = _step == 2 && !_busy;
    final temp = ValueListenableBuilder<double>(
      valueListenable: _clock,
      builder: (context, now, _) => _value(
        _tx.s('s1.temp').replaceAll('{t}', '${_venusTemp(now).round()}'),
        key: const ValueKey('temp-text'),
        color: _rt_Tw.orange400,
        size: compact ? 13.5 : 15,
      ),
    );
    final level = Text(
      _tx.s('s1.levels.$_co2'),
      key: const ValueKey('co2-text'),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.text,
      ),
    );
    return [
      if (_step == 1) ...[
        _rt_ActionButton(
          key: const ValueKey('btn-follow'),
          label: _tx.s('s1.follow'),
          icon: Icons.wb_sunny,
          color: _kAccent,
          expand: true,
          done: _followed,
          onPressed: _followed ? null : _followSunlight,
        ),
        const SizedBox(height: 8),
        temp,
      ],
      if (_step >= 2) ...[
        if (!compact) _caption(_tx.s('s1.co2Label')),
        if (compact)
          Wrap(spacing: 14, runSpacing: 2, children: [level, temp])
        else
          level,
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _rt_ActionButton(
                key: const ValueKey('co2-remove'),
                label: _tx.s('s1.remove'),
                icon: Icons.remove,
                color: _rt_Tw.slate600,
                expand: true,
                onPressed: live && _co2 > 0 ? () => _changeCo2(-1) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _rt_ActionButton(
                key: const ValueKey('co2-add'),
                label: _tx.s('s1.add'),
                icon: Icons.add,
                color: _kAccent,
                expand: true,
                onPressed: live && _co2 < _kCo2Max ? () => _changeCo2(1) : null,
              ),
            ),
          ],
        ),
        if (!compact) ...[const SizedBox(height: 8), temp],
      ],
      if (_step == 3) ..._quiz(compact),
    ];
  }

  List<Widget> _orbitPanel(bool compact) {
    final live = _step >= 1 && !_done;
    final size = compact ? 13.0 : 13.5;
    return [
      if (!compact) _caption(_tx.s('s2.distance')),
      _readouts(compact, [
        _value(
          _tx.s('s2.au').replaceAll('{d}', _au.toStringAsFixed(1)),
          key: const ValueKey('au-text'),
          size: compact ? 13 : 15,
        ),
        _value(
          _tx.s('s2.temp').replaceAll('{t}', '${_earthTemp.round()}'),
          key: const ValueKey('au-temp'),
          color: _rt_Tw.orange400,
          size: size,
        ),
        _value(
          '${_tx.s('s2.water')}: ${_tx.s('s2.states.$_waterState')}',
          key: const ValueKey('water-text'),
          color: switch (_waterState) {
            'steam' => _rt_Tw.red400,
            'ice' => const Color(0xFFBAE6FD),
            _ => _rt_Tw.green400,
          },
          size: size,
        ),
      ]),
      _sliderRow(
        key: 'au',
        value: _au,
        min: _kMinAu,
        max: _kMaxAu,
        divisions: 15,
        step: 0.1,
        onChanged: live ? _setAu : null,
      ),
    ];
  }

  List<Widget> _shieldPanel(bool compact) {
    final live = _step == 2 || _step == 3;
    return [
      if (_step == 1)
        _rt_ActionButton(
          key: const ValueKey('btn-inside'),
          label: _tx.s('s3.inside'),
          icon: Icons.search,
          color: _kAccent,
          expand: true,
          done: _inside,
          onPressed: _inside ? null : _lookInside,
        ),
      if (_step >= 2) ...[
        _caption(_tx.s('s3.flow')),
        _readouts(compact, [
          _value(
            '${_flow.round()}%',
            key: const ValueKey('flow-text'),
            size: compact ? 13 : 15,
          ),
          _value(
            _tx
                .s('s3.deflected')
                .replaceAll('{p}', '${(_deflected * 100).round()}'),
            key: const ValueKey('deflect-text'),
            color: _rt_Tw.sky400,
            size: 13,
          ),
        ]),
        _sliderRow(
          key: 'flow',
          value: _flow,
          min: 0,
          max: 100,
          divisions: 100,
          step: 10,
          onChanged: live ? _setFlow : null,
        ),
      ],
    ];
  }

  List<Widget> _gravityPanel(bool compact) {
    final live = _step == 2 || _step == 3;
    String fixed(double v) => _measured ? v.toStringAsFixed(1) : '?';
    String percent(double mass) =>
        mass < 10 ? mass.toStringAsFixed(1) : mass.round().toString();
    Widget marker(String id, double mass) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _rt_ChoiceButton(
          key: ValueKey('mass-$id'),
          label: '${_tx.s('s4.markers.$id')} ${percent(mass)}%',
          state: (_mass - mass).abs() < 0.05
              ? _rt_ChoiceState.selected
              : _rt_ChoiceState.idle,
          onTap: live ? () => _setMass(mass) : null,
        ),
      ),
    );
    final markers = [
      marker('moon', _kMoonMass),
      marker('mars', _kMarsMass),
      marker('earth', 100),
    ];
    final readouts = [
      _value(
        _tx.s('s4.gravity').replaceAll('{g}', fixed(_gravity)),
        key: const ValueKey('gravity-text'),
        size: 13,
      ),
      _value(
        _tx.s('s4.escape').replaceAll('{v}', fixed(_escapeSpeed)),
        key: const ValueKey('escape-text'),
        color: _rt_Tw.orange400,
        size: 13,
      ),
      if (_step >= 2) ...[
        _value(
          _tx.s('s4.mass').replaceAll('{m}', percent(_mass)),
          key: const ValueKey('mass-text'),
          size: 13,
        ),
        _value(
          _tx
              .s('s4.escaped')
              .replaceAll('{l}', '$_escapedLight')
              .replaceAll('{h}', '$_escapedHeavy'),
          key: const ValueKey('escaped-text'),
          color: _kLightGas,
          size: 12.5,
        ),
      ],
    ];
    return [
      if (_step == 1) ...[
        _rt_ActionButton(
          key: const ValueKey('btn-measure'),
          label: _tx.s('s4.measure'),
          icon: Icons.speed,
          color: _kAccent,
          expand: true,
          done: _measured,
          onPressed: _measured ? null : _measureGravity,
        ),
        const SizedBox(height: 8),
      ],
      if (_step >= 2 && !compact) _caption(_tx.s('s4.massLabel')),
      _readouts(compact, readouts),
      if (_step >= 2) ...[
        const SizedBox(height: 4),
        // Phones: the planet markers stand in for the slider, with - / +.
        if (compact)
          Row(
            children: [
              _roundButton(
                'mass-minus',
                Icons.remove,
                live && _mass > 1 ? () => _setMass(_mass - 5) : null,
              ),
              ...markers,
              _roundButton(
                'mass-plus',
                Icons.add,
                live && _mass < 100 ? () => _setMass(_mass + 5) : null,
              ),
            ],
          )
        else ...[
          _sliderRow(
            key: 'mass',
            value: _mass,
            min: 1,
            max: 100,
            step: 5,
            onChanged: live ? _setMass : null,
          ),
          Row(children: markers),
        ],
      ],
      if (_step == 3) ..._quiz(compact),
    ];
  }

  Widget _protectionMeter() {
    return ValueListenableBuilder<double>(
      valueListenable: _clock,
      builder: (context, now, _) {
        final level = _protection(now);
        final color = level >= 60
            ? _rt_Tw.green500
            : (level >= 30 ? _rt_Tw.amber500 : _rt_Tw.red500);
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: level / 100,
                  minHeight: 10,
                  color: color,
                  backgroundColor: _rt_Lab.overlay,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _value(
              '${level.round()}%',
              key: const ValueKey('protect-text'),
              color: color,
              size: 14,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _fieldLossPanel(bool compact) {
    final longTime = Text(
      _tx.s('s5.longTime'),
      style: TextStyle(
        fontSize: 11,
        fontStyle: FontStyle.italic,
        color: _rt_Lab.textMuted,
      ),
    );
    final ff = _rt_ActionButton(
      key: const ValueKey('btn-ff'),
      label: _tx.s('s5.ff'),
      icon: Icons.fast_forward,
      color: _kAccent,
      expand: !compact,
      done: _fastForwarded,
      onPressed: _fastForwarded ? null : _fastForward,
    );
    return [
      if (_step == 1)
        Row(
          children: [
            Expanded(child: _caption(_tx.s('s5.field'))),
            _fieldSwitch(),
          ],
        ),
      if (_step == 2) ...[
        _caption(_tx.s('s5.protection')),
        if (compact)
          Row(
            children: [
              Expanded(child: _protectionMeter()),
              const SizedBox(width: 10),
              ff,
            ],
          )
        else ...[
          _protectionMeter(),
          longTime,
          const SizedBox(height: 8),
          ff,
        ],
        if (compact) longTime,
      ],
      // Phones: one scrolling row of chips, so the events stay in view.
      if (_step >= 3 && compact)
        SizedBox(
          height: 40,
          child: SingleChildScrollView(
            key: const ValueKey('chip-row'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final chip in _kChips)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _chip(chip),
                  ),
              ],
            ),
          ),
        ),
      if (_step >= 3 && !compact) ...[
        _caption(_tx.s('s5.protection')),
        _protectionMeter(),
        longTime,
        const SizedBox(height: 8),
        Text(
          _tx.s('s5.placeHint'),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _rt_Lab.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final chip in _kChips) _chip(chip)],
        ),
      ],
    ];
  }

  /// The source's "Magnetic Field Status" pill. It only switches off: the
  /// scenario imagines the field gone (the source's redrawn pill showed ON
  /// while the field was off after a language change).
  Widget _fieldSwitch() {
    final enabled = _scenario == 5 && _step == 1 && _fieldOn;
    return GestureDetector(
      key: const ValueKey('field-switch'),
      onTap: enabled ? _switchFieldOff : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 86,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _fieldOn ? _rt_Tw.green600 : _rt_Tw.red600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment: _fieldOn
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: _fieldOn
                  ? const Alignment(-0.45, 0)
                  : const Alignment(0.5, 0),
              child: Text(
                _tx.s(_fieldOn ? 's5.on' : 's5.off'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A consequence chip: drag it onto an event, or tap it and then the
  /// event (the source was tap-tap only while its text said "drag").
  Widget _chip(String chip) {
    final placed = _placed.containsKey(chip);
    final selected = _selectedChip == chip;
    final active = _step == 3 && !placed && !_busy;
    final face = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: placed
            ? _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500)
            : (selected
                  ? _rt_Lab.tinted(_rt_Tw.indigo100, _rt_Tw.indigo500)
                  : _rt_Lab.overlay),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: placed
              ? _rt_Tw.green500
              : (selected ? _kAccent : _rt_Lab.borderStrong),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            placed ? Icons.check : Icons.drag_indicator,
            size: 14,
            color: placed ? _rt_Tw.green500 : _rt_Lab.textMuted,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _tx.s('s5.chips.$chip'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ],
      ),
    );
    if (!active) {
      return KeyedSubtree(
        key: ValueKey('chip-$chip'),
        child: Opacity(opacity: placed ? 0.6 : 0.8, child: face),
      );
    }
    return Draggable<String>(
      key: ValueKey('chip-$chip'),
      data: chip,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: face,
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: face),
      child: GestureDetector(onTap: () => _selectChip(chip), child: face),
    );
  }
}

// --------------------------------------------------------------- widgets ----

class _ToolbarToggle extends StatelessWidget {
  const _ToolbarToggle({
    super.key,
    required this.active,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        radius: 22,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _kAccent : _rt_Lab.surface,
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
}

/// Tailwind "chunky" button: solid fill, darker 4 px bottom edge that
/// collapses while pressed. Dimmed and inert when [onPressed] is null.
class _ChunkyButton extends StatefulWidget {
  const _ChunkyButton({
    super.key,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback? onPressed;

  @override
  State<_ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<_ChunkyButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: MouseRegion(
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                bottom: BorderSide(
                  color: widget.borderColor,
                  width: _pressed ? 1 : 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TileStatus { done, active, upcoming }

/// One collapsible "Step n" card (the source's three static instructions).
class _StepTile extends StatelessWidget {
  const _StepTile({
    super.key,
    required this.number,
    required this.title,
    required this.focusLabel,
    required this.focus,
    required this.actionLabel,
    required this.action,
    required this.observationLabel,
    required this.observation,
    required this.status,
    required this.expanded,
    required this.onToggle,
  });

  final int number;
  final String title;
  final String focusLabel;
  final String focus;
  final String actionLabel;
  final String action;
  final String observationLabel;

  /// Null until the step is done.
  final String? observation;
  final _TileStatus status;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final active = status == _TileStatus.active;
    final done = status == _TileStatus.done;
    final accentText = _rt_Lab.onTinted(_kAccentSoft, _rt_Tw.indigo600);
    final titleColor = active
        ? accentText
        : (done
              ? _rt_Lab.onTinted(_kAccentSoft, _rt_Tw.indigo700)
              : _rt_Lab.textMuted);

    final Widget badge = Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? _kAccent
            : (done ? _kAccent.withValues(alpha: 0.2) : _rt_Lab.overlay),
        border: Border.all(
          color: active
              ? _kAccentSoft
              : (done ? _kAccent.withValues(alpha: 0.4) : _rt_Tw.slate400),
        ),
      ),
      child: Text(
        done ? '✓' : '$number',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: active ? Colors.white : (done ? accentText : _rt_Lab.text),
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? _kAccent
              : (done ? _kAccent.withValues(alpha: 0.5) : _rt_Lab.border),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _kAccent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: active
                ? _rt_Lab.tinted(_rt_Tw.indigo50, _kAccent)
                : _rt_Lab.overlay,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    badge,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: done ? FontWeight.w700 : FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: titleColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _rt_Lab.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${focusLabel.toUpperCase()}:',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: _kAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    focus,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _rt_Lab.tinted(_rt_Tw.indigo100, _kAccent),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _rt_Lab.tintedBorder(_kAccent)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$actionLabel:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _rt_Lab.onTinted(
                              _kAccentSoft,
                              _rt_Tw.indigo700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          action,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _rt_Lab.text,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (observation != null) ...[
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$observationLabel: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _rt_Lab.text,
                            ),
                          ),
                          TextSpan(text: observation),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: _rt_Lab.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "What We Learnt" body of the summary popup.
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.heading,
    required this.lead,
    required this.text,
    required this.footer,
    this.report,
  });

  final String heading;
  final String lead;
  final String text;
  final String footer;
  final Widget? report;

  @override
  Widget build(BuildContext context) {
    final accent = _rt_Lab.onTinted(_kAccentSoft, _rt_Tw.indigo600);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 16, color: accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                heading.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$lead\n',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(text: text),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _rt_Lab.text,
              height: 1.45,
            ),
          ),
        ),
        ?report,
        const SizedBox(height: 12),
        Text(
          footer,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: accent,
          ),
        ),
      ],
    );
  }
}

/// The source's diagnostics report, now fed by every scenario (the source
/// counted mistakes in scenario 5 only, so 1-4 always read "mastered").
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.masteredTitle,
    required this.reviewTitle,
    required this.mastered,
    required this.review,
    required this.masteredNone,
    required this.reviewNone,
  });

  final String title;
  final String masteredTitle;
  final String reviewTitle;
  final List<String> mastered;
  final List<String> review;
  final String masteredNone;
  final String reviewNone;

  @override
  Widget build(BuildContext context) {
    TextStyle head(Color color) =>
        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color);
    final item = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: _rt_Lab.text,
      height: 1.4,
    );
    final none = TextStyle(
      fontSize: 12,
      fontStyle: FontStyle.italic,
      color: _rt_Lab.textMuted,
    );
    return Container(
      key: const ValueKey('report'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, size: 16, color: _kAccent),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: head(_rt_Lab.text))),
            ],
          ),
          const SizedBox(height: 8),
          Text(masteredTitle, style: head(_rt_Tw.green500)),
          if (mastered.isEmpty) Text(masteredNone, style: none),
          for (final name in mastered) Text('✓ $name', style: item),
          const SizedBox(height: 8),
          Text(reviewTitle, style: head(_rt_Tw.amber500)),
          if (review.isEmpty) Text(reviewNone, style: none),
          for (final name in review) Text('• $name', style: item),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- painters ----

/// Fixed star field (the source's twinkling stars).
final List<(Offset, double, double)> _kStars = List.generate(110, (i) {
  final random = math.Random(i * 7919 + 13);
  return (
    Offset(
      random.nextDouble() * _kStage.width,
      random.nextDouble() * _kStage.height,
    ),
    0.4 + random.nextDouble() * 1.1,
    random.nextDouble() * math.pi * 2,
  );
});

/// Repeatable pseudo-random number in [0, 1) for particle [i].
double _hash(int i, int salt) {
  final v = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

void _paintSpace(Canvas canvas, Size size, double t) {
  final rect = Offset.zero & size;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF020617), Colors.black],
      ).createShader(rect),
  );
  final star = Paint();
  for (final (at, radius, phase) in _kStars) {
    star.color = Colors.white.withValues(
      alpha: 0.3 + 0.5 * (0.5 + 0.5 * math.sin(t * 1.3 + phase)),
    );
    canvas.drawCircle(at, radius, star);
  }
}

/// The source's sun: white-hot core, orange glow and slowly turning rays.
void _paintSun(Canvas canvas, Offset c, double r, double t) {
  canvas.drawCircle(
    c,
    r * 2.1,
    Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.45),
          const Color(0x00F97316),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r * 2.1)),
  );
  final ray = Paint()
    ..color = const Color(0xFFFDE047).withValues(alpha: 0.4)
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 12; i++) {
    final a = t * 0.15 + i * math.pi / 6;
    final d = Offset(math.cos(a), math.sin(a));
    canvas.drawLine(
      c + d * (r * 1.08),
      c + d * (r * 1.32 + 6 * math.sin(t * 2 + i)),
      ray,
    );
  }
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Color(0xFFFEF08A), Color(0xFFEA580C)],
        stops: [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: c, radius: r)),
  );
}

/// Earth: ocean, land, clouds, an air halo of strength [air] and a night
/// side away from the Sun (on the left).
void _paintEarth(Canvas canvas, Offset c, double r, {double air = 1}) {
  if (air > 0) {
    canvas.drawCircle(
      c,
      r * 1.18,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF7DD3FC).withValues(alpha: 0.6 * air),
            const Color(0x007DD3FC),
          ],
          stops: const [0.82, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.18)),
    );
  }
  final disc = Rect.fromCircle(center: c, radius: r);
  canvas.save();
  canvas.clipPath(Path()..addOval(disc));
  canvas.drawRect(disc, Paint()..color = const Color(0xFF0284C7));
  final land = Paint()..color = const Color(0xFF4ADE80);
  final forest = Paint()..color = const Color(0xFF166534);
  Rect blob(double x, double y, double w, double h) => Rect.fromCenter(
    center: c + Offset(x * r, y * r),
    width: w * r,
    height: h * r,
  );
  canvas.drawOval(blob(-0.35, -0.3, 0.75, 0.5), land);
  canvas.drawOval(blob(-0.25, 0.2, 0.35, 0.65), land);
  canvas.drawOval(blob(0.4, 0.35, 0.6, 0.45), forest);
  canvas.drawOval(blob(0.45, -0.45, 0.4, 0.3), land);
  final cloud = Paint()..color = Colors.white.withValues(alpha: 0.7);
  canvas.drawOval(blob(0.05, -0.62, 0.8, 0.14), cloud);
  canvas.drawOval(blob(-0.1, 0.55, 0.7, 0.12), cloud);
  canvas.drawRect(
    disc,
    Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
        stops: const [0.45, 1],
      ).createShader(disc),
  );
  canvas.restore();
}

/// A wavy (infrared) stroke from [a] to [b].
void _drawWave(Canvas canvas, Offset a, Offset b, Paint paint, double phase) {
  final d = b - a;
  final length = d.distance;
  if (length < 1) return;
  final u = d / length;
  final n = Offset(-u.dy, u.dx);
  final path = Path()..moveTo(a.dx, a.dy);
  for (var s = 2.0; s <= length; s += 2) {
    final p = a + u * s + n * (3 * math.sin(s / 4 + phase));
    path.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(path, paint);
}

/// Scenario 1: sunlight in, infrared out, and the CO₂ air sending some of
/// the infrared back (the source showed the surface "reflecting" sunlight
/// as infrared and heated Venus with or without CO₂).
class _VenusPainter extends CustomPainter {
  _VenusPainter({
    required this.clock,
    required this.co2,
    required this.followed,
    required this.tempFrom,
    required this.tempTo,
    required this.tempAt,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final int co2;
  final bool followed;
  final double tempFrom;
  final double tempTo;
  final double tempAt;

  /// Order in which the air starts sending the seven rays back.
  static const List<int> _trapOrder = [3, 1, 5, 0, 6, 2, 4];

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    _paintSpace(canvas, size, t);
    _paintSun(canvas, _kS1Sun, _kS1SunRadius, t);
    const c = _kVenus;
    const r = _kVenusRadius;
    final shell = _kCo2Shell[co2];
    final temp = _eased(tempFrom, tempTo, tempAt, _kTempEase, t);
    final heat = ((temp - 50) / 415).clamp(0.0, 1.0);

    // The CO₂ air: thicker and denser with every level.
    if (shell > 0) {
      final outer = r + shell;
      final rect = Rect.fromCircle(center: c, radius: outer);
      canvas.drawCircle(
        c,
        outer,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: 0.2 + 0.08 * co2),
              const Color(0xFFD6D3D1).withValues(alpha: 0.1 + 0.07 * co2),
              const Color(0x00D6D3D1),
            ],
            stops: [r / outer, (r + shell * 0.7) / outer, 1],
          ).createShader(rect),
      );
      canvas.drawCircle(
        c,
        outer,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFFDE68A).withValues(alpha: 0.3),
      );
    }

    // Venus, glowing as it heats up.
    final disc = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          colors: [Color(0xFFF2C38A), Color(0xFFC2410C), Color(0xFF431407)],
          stops: [0, 0.55, 1],
        ).createShader(disc),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(disc));
    final band = Paint()
      ..color = const Color(0xFF7C2D12).withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, -18), width: r * 2.4, height: 12),
      band,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 16), width: r * 2.4, height: 16),
      band,
    );
    canvas.restore();
    if (heat > 0) {
      canvas.drawCircle(
        c,
        r * 1.04,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFF7849).withValues(alpha: 0.6 * heat),
              const Color(0x00FF7849),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 1.04)),
      );
    }

    // Seven sunbeams in (yellow); the warm surface gives off infrared
    // (red) from its far side, and the CO₂ air sends some of it back.
    final startX = _kS1Sun.dx + _kS1SunRadius + 6;
    final trapped = _kTrapped[co2];
    for (var i = 0; i < 7; i++) {
      final y = c.dy + (i - 3) * 15.0;
      final dy = y - c.dy;
      final hit = Offset(c.dx - math.sqrt(r * r - dy * dy), y);
      final focus = followed && i == 3;
      final width = focus ? 4.5 : 2.5;
      final alpha = followed && !focus ? 0.4 : 1.0;
      canvas.drawLine(
        Offset(startX, y),
        hit,
        Paint()
          ..color = const Color(
            0xFFFEF08A,
          ).withValues(alpha: focus ? 0.35 : 0.08)
          ..strokeWidth = focus ? 2 : 1,
      );
      final p = (t / 2.6 + i * 0.37) % 1.0;
      if (p < 0.5) {
        final head = startX + (hit.dx - startX) * (p / 0.5);
        canvas.drawLine(
          Offset(math.max(startX, head - 46), y),
          Offset(head, y),
          Paint()
            ..color = const Color(0xFFFEF08A).withValues(alpha: alpha)
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      final angle = (-60 + i * 20) * math.pi / 180;
      final normal = Offset(math.cos(angle), math.sin(angle));
      final from = c + normal * r;
      final out = 170 * (p - 0.5) / 0.5;
      final ir = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: alpha)
        ..strokeWidth = width - 0.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final sentBack = _trapOrder.indexOf(i) < trapped;
      if (!sentBack || out < shell) {
        _drawWave(
          canvas,
          from + normal * math.max(0.0, out - 40),
          from + normal * out,
          ir,
          t * 8,
        );
      } else {
        final back = shell - (out - shell);
        if (back > -40) {
          _drawWave(
            canvas,
            from + normal * math.min(shell, back + 40),
            from + normal * math.max(0.0, back),
            ir,
            t * 8,
          );
        }
      }
    }
    if (followed) {
      canvas.drawCircle(
        Offset(c.dx - r, c.dy),
        7,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void _dashedCircle(Canvas canvas, Offset c, double radius, Paint paint) {
  final n = math.max(12, (2 * math.pi * radius / 14).floor());
  final sweep = math.pi * 2 / n;
  final rect = Rect.fromCircle(center: c, radius: radius);
  for (var k = 0; k < n; k++) {
    canvas.drawArc(rect, k * sweep, sweep * 0.55, false, paint);
  }
}

/// Scenario 2: the Sun, Earth's orbit at [au], the distance axis and the
/// green liquid-water zone (a range, not the source's "exactly 1.0 AU").
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.clock, required this.au, required this.showZone})
    : super(repaint: clock);

  final ValueNotifier<double> clock;
  final double au;
  final bool showZone;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    _paintSpace(canvas, size, t);
    const sun = _kS2Sun;
    if (showZone) {
      final zone = Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(Rect.fromCircle(center: sun, radius: _kAuPx * _kZoneOuter))
        ..addOval(Rect.fromCircle(center: sun, radius: _kAuPx * _kZoneInner));
      canvas.drawPath(
        zone,
        Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.2),
      );
      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF4ADE80).withValues(alpha: 0.6);
      canvas.drawCircle(sun, _kAuPx * _kZoneOuter, edge);
      canvas.drawCircle(sun, _kAuPx * _kZoneInner, edge);
    }
    _dashedCircle(
      canvas,
      sun,
      _kAuPx * au,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    _paintSun(canvas, sun, _kS2SunRadius, t);

    // The distance axis, 0.5-2.0 AU.
    const axisY = 282.0;
    final axis = Paint()
      ..color = _rt_Tw.slate500
      ..strokeWidth = 1.5;
    double x(double d) => sun.dx + d * _kAuPx;
    canvas.drawLine(Offset(x(_kMinAu), axisY), Offset(x(_kMaxAu), axisY), axis);
    for (var k = 5; k <= 20; k++) {
      final tall = k % 5 == 0;
      canvas.drawLine(
        Offset(x(k / 10), axisY - (tall ? 7 : 4)),
        Offset(x(k / 10), axisY + (tall ? 7 : 4)),
        axis,
      );
    }
    final marker = Path()
      ..moveTo(x(au), axisY - 9)
      ..lineTo(x(au) - 6, axisY - 18)
      ..lineTo(x(au) + 6, axisY - 18)
      ..close();
    canvas.drawPath(marker, Paint()..color = const Color(0xFF38BDF8));

    // Earth, with its water boiling or frozen.
    final e = Offset(x(au), sun.dy);
    final temp = _earthTempC(au);
    _paintEarth(canvas, e, 18);
    if (temp >= 100) {
      canvas.drawCircle(
        e,
        18,
        Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.3),
      );
      for (var k = 0; k < 5; k++) {
        final phase = (t * 0.8 + k / 5) % 1;
        canvas.drawCircle(
          e + Offset(-10 + k * 5.0, -22 - phase * 26),
          4 + phase * 5,
          Paint()..color = Colors.white.withValues(alpha: (1 - phase) * 0.55),
        );
      }
    } else if (temp <= 0) {
      canvas.drawCircle(
        e,
        18,
        Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.7),
      );
      final crack = Paint()
        ..color = Colors.white
        ..strokeWidth = 1;
      canvas.drawLine(e.translate(-8, -6), e.translate(4, 2), crack);
      canvas.drawLine(e.translate(4, 2), e.translate(10, -4), crack);
      canvas.drawLine(e.translate(-2, 8), e.translate(6, 12), crack);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// The water-state box: steam molecules jitter, liquid ones drift, ice
/// ones sit still in a lattice.
class _WaterDotsPainter extends CustomPainter {
  _WaterDotsPainter({required this.clock, required this.state})
    : super(repaint: clock);

  final ValueNotifier<double> clock;
  final String state;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    final points = <Offset>[];
    for (var i = 0; i < 9; i++) {
      final base = Offset(
        (i % 3 + 1) * size.width / 4,
        (i ~/ 3 + 0.6) * size.height / 3.2,
      );
      final shift = switch (state) {
        'steam' => Offset(
          math.sin(t * 13 + i * 2.1) * 7,
          math.cos(t * 11 + i * 1.7) * 5,
        ),
        'liquid' => Offset(math.cos(t * 2 + i), math.sin(t * 2 + i)) * 4,
        _ => Offset.zero,
      };
      points.add(base + shift);
    }
    if (state == 'ice') {
      final bond = Paint()
        ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.5)
        ..strokeWidth = 1;
      for (var i = 0; i < 9; i++) {
        if (i % 3 < 2) canvas.drawLine(points[i], points[i + 1], bond);
        if (i < 6) canvas.drawLine(points[i], points[i + 3], bond);
      }
    }
    final dot = Paint()
      ..color = switch (state) {
        'steam' => const Color(0xFFF87171),
        'liquid' => const Color(0xFF38BDF8),
        _ => const Color(0xFFE0F2FE),
      };
    for (final p in points) {
      canvas.drawCircle(p, 4.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Scenarios 3 and 5: the solar wind, Earth's magnetic field and (in 3)
/// a look inside Earth, or (in 5) the four events once the field is gone.
class _ShieldPainter extends CustomPainter {
  _ShieldPainter({
    required this.clock,
    required this.earth,
    required this.radius,
    required this.sun,
    required this.sunRadius,
    required this.field,
    required this.deflected,
    this.inside = false,
    this.flow = 0,
    this.events = false,
    this.protectAt = double.infinity,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final Offset earth;
  final double radius;
  final Offset sun;
  final double sunRadius;

  /// Field strength and share of particles steered away (0-1).
  final double field;
  final double deflected;

  /// Scenario 3: draw Earth cut open, with molten iron flowing at [flow].
  final bool inside;
  final double flow;

  /// Scenario 5: draw events A-D; the air thins as protection falls.
  final bool events;
  final double protectAt;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    _paintSpace(canvas, size, t);
    _paintSun(canvas, sun, sunRadius, t);
    final air = events ? _protectionAt(protectAt, t) / 100 : 1.0;
    if (field > 0) _paintField(canvas);
    if (inside) {
      _paintCore(canvas, t);
    } else {
      _paintEarth(canvas, earth, radius, air: air);
    }
    if (events) _paintEvents(canvas, t);
    _paintWind(canvas, size, t);
  }

  /// Dipole loops all round Earth, squashed on the day side and stretched
  /// on the night side (the source drew half-ellipses on the day side only).
  void _paintField(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 + 1.2 * field
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.2 + 0.65 * field);
    for (final shell in const [1.5, 2.0, 2.7, 3.6]) {
      final latMax = math.acos(math.sqrt(1 / shell));
      for (final side in const [-1.0, 1.0]) {
        final stretch = side < 0 ? 0.7 : 1.6;
        final path = Path();
        for (var k = 0; k <= 48; k++) {
          final lat = -latMax + 2 * latMax * k / 48;
          final cos = math.cos(lat);
          final along = shell * radius * cos * cos;
          final reach = radius + (along - radius) * stretch;
          final p = Offset(
            earth.dx + side * reach * cos,
            earth.dy - reach * math.sin(lat),
          );
          if (k == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Earth cut open: crust, mantle, a liquid outer core of molten iron
  /// (with flow arrows) and a solid inner core (the source drew one
  /// spinning "core").
  void _paintCore(Canvas canvas, double t) {
    final c = earth;
    final r = radius;
    canvas.drawCircle(
      c,
      r * 1.12,
      Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: 0.25),
    );
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF57534E));
    canvas.drawCircle(
      c,
      r * 0.94,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFC2410C), Color(0xFF7C2D12)],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.94)),
    );
    final outer = r * 0.52;
    canvas.drawCircle(
      c,
      outer,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFEA580C)],
        ).createShader(Rect.fromCircle(center: c, radius: outer)),
    );
    if (flow > 0) {
      final spin = t * (0.6 + 4 * flow);
      final arrow = Paint()
        ..color = Colors.white.withValues(alpha: 0.45 + 0.45 * flow)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final ring = outer * 0.74;
      for (var k = 0; k < 4; k++) {
        final a = spin + k * math.pi / 2;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: ring),
          a,
          0.9,
          false,
          arrow,
        );
        final end = a + 0.9;
        final out = Offset(math.cos(end), math.sin(end));
        final along = Offset(-math.sin(end), math.cos(end));
        final tip = c + out * ring;
        canvas.drawLine(tip, tip - along * 5 + out * 4, arrow);
        canvas.drawLine(tip, tip - along * 5 - out * 4, arrow);
      }
    }
    canvas.drawCircle(
      c,
      r * 0.24,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0xFFFDE047)],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.24)),
    );
    final line = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;
    canvas.drawLine(
      c + Offset(outer * 0.7, -outer * 0.6),
      Offset(c.dx + 66, c.dy - 62),
      line,
    );
    canvas.drawLine(
      c + Offset(r * 0.16, r * 0.16),
      Offset(c.dx + 66, c.dy + 62),
      line,
    );
  }

  /// Scenario 5's events, drawn without names (A: the upper air, B: the
  /// ground, C: a migrating bird, D: a satellite).
  void _paintEvents(Canvas canvas, double t) {
    // A: the upper air glows and gas drifts away.
    final a = _kEventSpot['A']!;
    canvas.drawCircle(
      a,
      26,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(
              0xFFF0ABFC,
            ).withValues(alpha: 0.55 + 0.2 * math.sin(t * 3)),
            const Color(0x00F0ABFC),
          ],
        ).createShader(Rect.fromCircle(center: a, radius: 26)),
    );
    for (var k = 0; k < 5; k++) {
      final phase = (t * 0.6 + k / 5) % 1;
      canvas.drawCircle(
        a + const Offset(-0.8, -0.6) * (8 + phase * 40) + Offset(k * 4.0, 0),
        2,
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 1 - phase),
      );
    }

    // B: a tree on the ground, with radiation getting through to it.
    final b = _kEventSpot['B']!;
    final up = (b - earth) / (b - earth).distance;
    canvas.save();
    canvas.translate(b.dx, b.dy);
    canvas.rotate(math.atan2(up.dy, up.dx) + math.pi / 2);
    canvas.drawRect(
      const Rect.fromLTWH(-2, -12, 4, 12),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawCircle(
      const Offset(0, -16),
      8,
      Paint()..color = const Color(0xFF22C55E),
    );
    canvas.restore();
    final zap = Paint()
      ..color = const Color(
        0xFFA3E635,
      ).withValues(alpha: 0.5 + 0.5 * (0.5 + 0.5 * math.sin(t * 9)))
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final start in const [Offset(-70, -10), Offset(-62, 22)]) {
      final from = b + start;
      final to = b + up * 26;
      final path = Path()..moveTo(from.dx, from.dy);
      for (var k = 1; k <= 6; k++) {
        final p = Offset.lerp(from, to, k / 6)!;
        path.lineTo(p.dx + (k.isOdd ? 4 : -4), p.dy + (k.isOdd ? -4 : 4));
      }
      canvas.drawPath(path, zap);
    }

    // C: a migrating bird flying in lost loops.
    final cc = _kEventSpot['C']!;
    final trail = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (var k = 0; k < 18; k++) {
      final angle = k / 18 * math.pi * 2;
      canvas.drawCircle(
        cc + Offset(math.cos(angle) * 22, math.sin(angle) * 13),
        1.2,
        trail,
      );
    }
    final bird = cc + Offset(math.cos(t * 1.6) * 22, math.sin(t * 1.6) * 13);
    final wing = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final flap = 3 * math.sin(t * 10);
    canvas.drawPath(
      Path()
        ..moveTo(bird.dx - 8, bird.dy - 3 - flap)
        ..lineTo(bird.dx, bird.dy + 2)
        ..lineTo(bird.dx + 8, bird.dy - 3 - flap),
      wing,
    );

    // D: a satellite hit by a storm of particles.
    final d = _kEventSpot['D']!;
    canvas.drawRect(
      Rect.fromCenter(center: d, width: 14, height: 11),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    final panel = Paint()..color = const Color(0xFF2563EB);
    canvas.drawRect(
      Rect.fromCenter(center: d.translate(-17, 0), width: 18, height: 7),
      panel,
    );
    canvas.drawRect(
      Rect.fromCenter(center: d.translate(17, 0), width: 18, height: 7),
      panel,
    );
    if ((t * 2) % 1 < 0.55) {
      final spark = Paint()
        ..color = const Color(0xFFFDE047)
        ..strokeWidth = 1.6;
      for (var k = 0; k < 4; k++) {
        final angle = k * math.pi / 2 + t;
        final dir = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(d + dir * 9, d + dir * 16, spark);
      }
    }
  }

  /// The solar wind: steered round Earth by [deflected] of the particles,
  /// splashing into the upper air otherwise.
  void _paintWind(Canvas canvas, Size size, double t) {
    final c = earth;
    final length = size.width + 140;
    final bow = radius * (1.5 + 0.9 * field);
    final hitRadius = radius * 1.12;
    final streak = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 28; i++) {
      final y0 = c.dy + (_hash(i, 1) - 0.5) * 300;
      final speed = 210 + _hash(i, 2) * 110;
      final x = -70 + (t * speed + _hash(i, 3) * length) % length;
      final steered = _hash(i, 4) < deflected;
      final dy = y0 - c.dy;
      Offset at(double px) {
        if (!steered) return Offset(px, y0);
        final ex = (px - c.dx) / (bow * 1.5);
        if (ex.abs() >= 1) return Offset(px, y0);
        final keep = bow * math.sqrt(1 - ex * ex);
        if (dy.abs() >= keep) return Offset(px, y0);
        return Offset(px, c.dy + (dy >= 0 ? keep : -keep));
      }

      if (!steered && dy.abs() < hitRadius) {
        final hitX = c.dx - math.sqrt(hitRadius * hitRadius - dy * dy);
        if (x > hitX) {
          final k = (x - hitX) / 50;
          if (k < 1) {
            canvas.drawCircle(
              Offset(hitX, y0),
              4 + 8 * k,
              Paint()
                ..color = const Color(
                  0xFFF0ABFC,
                ).withValues(alpha: 0.7 * (1 - k)),
            );
          }
          continue;
        }
      }
      canvas.drawLine(at(x - 18), at(x), streak);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Scenario 4: gas molecules hopping above a planet of fixed size, pulled
/// back toward its centre (the source pulled them down the screen, so they
/// slid off the sides even at full mass).
class _GravityPainter extends CustomPainter {
  _GravityPainter({
    required this.clock,
    required this.molecules,
    required this.gravity,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final List<_Molecule> molecules;

  /// Surface gravity relative to Earth's.
  final double gravity;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    _paintSpace(canvas, size, t);
    const c = _kS4Planet;
    const r = _kS4Radius;

    // Gravity arrows toward the centre, shorter as gravity weakens.
    final pull = Paint()
      ..color = _rt_Tw.amber200.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final length = 8 + 26 * math.sqrt(gravity);
    for (var k = 0; k < 8; k++) {
      final angle = k * math.pi / 4 + math.pi / 8;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final start = c + dir * (r + 100);
      final end = start - dir * length;
      final side = Offset(-dir.dy, dir.dx);
      canvas.drawLine(start, end, pull);
      canvas.drawLine(end, end + dir * 5 + side * 4, pull);
      canvas.drawLine(end, end + dir * 5 - side * 4, pull);
    }

    _paintEarth(canvas, c, r, air: 0.35);

    final light = Paint()..color = _kLightGas;
    final heavy = Paint()..color = Colors.white;
    final glow = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.25);
    for (final molecule in molecules) {
      final altitude = molecule.altitude(t);
      if (altitude == null) continue;
      final angle = molecule.angleAt(t);
      final dir = Offset(math.cos(angle), math.sin(angle));
      final p = c + dir * (r + 4 + altitude);
      if (molecule.escapedAt != null) {
        canvas.drawLine(
          p - dir * 16,
          p,
          Paint()
            ..color = (molecule.light ? _kLightGas : Colors.white).withValues(
              alpha: 0.5,
            )
            ..strokeWidth = 2,
        );
      }
      canvas.drawCircle(p, molecule.light ? 6 : 7.5, glow);
      canvas.drawCircle(
        p,
        molecule.light ? 3.4 : 4.6,
        molecule.light ? light : heavy,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConfettiPiece {
  _ConfettiPiece.random(math.Random random)
    : angle = (-90 + (random.nextDouble() - 0.5) * 70) * math.pi / 180,
      speed = 450 + random.nextDouble() * 450,
      color = _kConfettiColors[random.nextInt(_kConfettiColors.length)],
      width = 6 + random.nextDouble() * 4,
      height = 4 + random.nextDouble() * 3,
      spin = (random.nextDouble() - 0.5) * 12,
      wobble = random.nextDouble() * math.pi * 2;

  final double angle;
  final double speed;
  final Color color;
  final double width;
  final double height;
  final double spin;
  final double wobble;
}

/// One confetti burst from 60 % down the screen.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress, this.pieces) : super(repaint: progress);

  final Animation<double> progress;
  final List<_ConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    final seconds = t * 1.8;
    final origin = Offset(size.width / 2, size.height * 0.6);
    const drag = 2.2;
    final travel = (1 - math.exp(-drag * seconds)) / drag;
    final opacity = (1 - t * t).clamp(0.0, 1.0);
    for (final piece in pieces) {
      final x =
          origin.dx +
          math.cos(piece.angle) * piece.speed * travel +
          math.sin(seconds * 4 + piece.wobble) * 8;
      final y =
          origin.dy +
          math.sin(piece.angle) * piece.speed * travel +
          260 * seconds * seconds;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.spin * seconds);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.width,
          height: piece.height,
        ),
        Paint()..color = piece.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
