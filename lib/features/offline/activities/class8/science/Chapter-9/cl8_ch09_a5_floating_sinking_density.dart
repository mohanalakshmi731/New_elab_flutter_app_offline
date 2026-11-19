// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 9.5: Floating, Sinking and Density Effects
// Converted from
// Cl8S-Ch9-A2-Floating_Sinking_and_Density_Effects_Simulation_Strategy.html
// (Tailwind DOM + GSAP + canvas-confetti -> Flutter widgets +
// CustomPainters, zoom/pan via InteractiveViewer).
//
// Two scenarios chosen from the sidebar. 1: Float or Sink Tank -- drag a
// wood block, stone, coin, plastic bottle and clay ball into a water tank
// (floaters ride at the waterline, sinkers drop to the bottom) and onto a
// digital balance, then reshape the clay ball into a boat and watch it float.
// 2: Temperature and Pressure -- heat air particles with a slider (they spread
// out and a hot-air balloon rises), then compress gas with a piston (it gets
// denser and a submarine dives). Observation log, current-task HUD, labels /
// pan toggles, every source string (EN/HI; the source's TE block is dropped
// like every other page) and confetti are ported. Balance masses use
// density x volume instead of the source's density x 20 g, which made the
// large bottle lighter than the coin and changed the clay's mass on
// reshaping.

import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart' as ap;
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
// Copied from the source's `i18n` and `ScenariosData` blocks (EN + HI; TE
// dropped). `<b>` / `<strong>` markup is stripped: the summaries' bold
// opening line is kept as `summaryLead`. Keys marked "added" had no
// translation in the source.
final _tx = _rt_Tx({
  'en': {
    'title': 'Density Lab',
    'subtitle':
        'Class 8: THE AMAZING WORLD OF SOLUTES, SOLVENTS, AND SOLUTIONS',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Float • Sink • Temperature • Pressure',
    'tabGuide': 'Lab Guide',
    'selectScenario': 'Select Scenario',
    'missionObjective': 'Mission Objective',
    'explorationSteps': 'Exploration Steps',
    'step': 'Step',
    'focus': 'Focus',
    'action': 'Action',
    'observation': 'Observation',
    'currentTask': 'Current Task',
    'obsLog': 'Observation Log',
    'clear': 'Clear',
    'result': 'Result',
    'noObs': 'No observations yet.',
    'success': 'Success!',
    'keyTakeaway': 'Key Takeaway',
    'scenarioComplete': 'Scenario Complete!',
    'nextScenario': 'Next Scenario',
    'restartLab': 'Reset Entire Lab',
    'materials': {
      'wood': 'Wood Block',
      'stone': 'Stone',
      'coin': 'Coin',
      'bottle': 'Plastic Bottle',
      'clayBall': 'Clay Ball',
      'clayBoat': 'Clay Boat',
    },
    'waterTank': 'Water Tank',
    'balance': 'Digital Balance',
    'reshape': 'Reshape Clay to Boat',
    'tempEffect': 'Heat & Buoyancy',
    'pressEffect': 'Pressure & Density',
    'density': 'Density',
    'balloon': 'Hot Air Balloon',
    'submarine': 'Submarine',
    'denHigh': 'High (Dense)',
    'denMedium': 'Medium',
    'denLow': 'Low (Spread)',
    'denNormal': 'Normal',
    'denHighComp': 'High (Compressed)',
    'compress': 'Fill Tanks (Compress)',
    'release': 'Empty Tanks (Release)',
    'causes': 'Causes',
    'obsFloated': 'Floated',
    'obsSank': 'Sank',
    'obsMass': 'Mass',
    'obsVolIncDenDec': 'Vol Increased, Den Decreased',
    'obsVolExpDenDec': 'Heated: Expanded & Rose',
    'obsVolDecDenInc': 'Compressed: Denser & Sank',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'scenarios': {
      '1': {
        'title': 'Scenario 1: Float or Sink Tank',
        'objective':
            'Understand the relationship between density, mass, volume, and buoyancy to predict whether an object will float or sink in water.',
        'hud': [
          '',
          'DRAG objects into the water tank to see if they float or sink.',
          'DRAG objects to the Digital Balance to measure mass.',
          'RESHAPE the clay ball into a boat and test it again.',
        ],
        'steps': [
          {
            'concept': 'Density Prediction',
            'action':
                'Drag and drop various objects (wood, stone, coin, bottle) into the water tank.',
            'observation':
                'Objects with a density less than water (< 1.0 g/cm³) float, while objects with a density greater than water (> 1.0 g/cm³) sink.',
          },
          {
            'concept': 'Measurement vs. Buoyancy',
            'action':
                'Drag objects onto the Digital Balance to measure their mass.',
            'observation':
                'Heavy objects like the large plastic bottle can float, while a lighter object like a small coin sinks. Mass alone does not determine buoyancy; volume is equally important.',
          },
          {
            'concept': 'Shape & Average Density',
            'action':
                "Click 'Reshape Clay to Boat' to alter the solid clay ball's shape and test it.",
            'observation':
                'The hollow boat shape traps air, significantly increasing its total volume. This decreases the overall average density to less than 1.0 g/cm³, allowing it to float despite being made of dense clay.',
          },
        ],
        'summaryLead': 'Density determines Buoyancy!',
        'summary':
            'An object floats if its average density is less than water. Shape matters because a hollow shape increases volume, lowering average density.',
      },
      '2': {
        'title': 'Scenario 2: Temp & Pressure',
        'objective':
            'Explore how temperature and pressure changes affect the density of substances in real-world scenarios.',
        'hud': [
          '',
          'HEAT the air (slider) to see particles expand and balloon rise.',
          'COMPRESS the gas (button) to see particles densify and sub dive.',
        ],
        'steps': [
          {
            'concept': 'Temperature Effect',
            'action': 'Use the temperature slider to heat the air particles.',
            'observation':
                'Heating adds energy, causing particles to spread apart rapidly. This increases volume and decreases density, explaining why the hot air balloon becomes lighter than the surrounding air and rises.',
          },
          {
            'concept': 'Pressure Effect',
            'action':
                "Click 'Fill Tanks (Compress)' to apply pressure to the gas/liquid.",
            'observation':
                'Applying pressure forces particles closer together, decreasing volume and increasing density. Submarines dive by taking in water to increase their overall density and weight.',
          },
        ],
        'summaryLead': 'Temperature and Pressure control Density!',
        'summary':
            'Heating generally expands substances (lowers density). Pressure compresses gases/liquids (increases density). These principles control balloons and submarines.',
      },
    },
  },
  'hi': {
    'title': 'घनत्व लैब',
    'subtitle': 'कक्षा 8: विलेय, विलायक और विलयन की अद्भुत दुनिया',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'तैरना • डूबना • तापमान • दबाव', // added
    'tabGuide': 'लैब गाइड', // added
    'selectScenario': 'परिदृश्य चुनें',
    'missionObjective': 'मिशन का उद्देश्य',
    'explorationSteps': 'खोज के चरण',
    'step': 'चरण', // added
    'focus': 'मुख्य विचार', // added
    'action': 'कार्रवाई',
    'observation': 'अवलोकन',
    'currentTask': 'वर्तमान कार्य',
    'obsLog': 'अवलोकन लॉग',
    'clear': 'साफ़ करें',
    'result': 'परिणाम',
    'noObs': 'अभी तक कोई अवलोकन नहीं।',
    'success': 'सफलता!',
    'keyTakeaway': 'मुख्य निष्कर्ष',
    'scenarioComplete': 'परिदृश्य पूर्ण!', // added
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'संपूर्ण लैब रीसेट करें',
    'materials': {
      'wood': 'लकड़ी का ब्लॉक',
      'stone': 'पत्थर',
      'coin': 'सिक्का',
      'bottle': 'प्लास्टिक की बोतल',
      'clayBall': 'मिट्टी की गेंद',
      'clayBoat': 'मिट्टी की नाव',
    },
    'waterTank': 'पानी की टंकी',
    'balance': 'डिजिटल बैलेंस',
    'reshape': 'मिट्टी को नाव का आकार दें',
    'tempEffect': 'गर्मी और उछाल',
    'pressEffect': 'दबाव और घनत्व',
    'density': 'घनत्व',
    'balloon': 'गर्म हवा का गुब्बारा',
    'submarine': 'पनडुब्बी',
    'denHigh': 'उच्च (सघन)',
    'denMedium': 'मध्यम',
    'denLow': 'निम्न (फैला हुआ)',
    'denNormal': 'सामान्य',
    'denHighComp': 'उच्च (संपीड़ित)',
    'compress': 'टैंक भरें (संपीड़ित करें)',
    'release': 'टैंक खाली करें (छोड़ें)',
    'causes': 'कारण बनता है', // added
    'obsFloated': 'तैरा',
    'obsSank': 'डूब गया',
    'obsMass': 'द्रव्यमान',
    'obsVolIncDenDec': 'आयतन बढ़ा, घनत्व कम हुआ',
    'obsVolExpDenDec': 'गर्म किया: फैला और ऊपर उठा',
    'obsVolDecDenInc': 'संपीड़ित: सघन और डूब गया',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
    'scenarios': {
      '1': {
        'title': 'परिदृश्य 1: तैरने या डूबने का टैंक',
        'objective':
            'तैरने या डूबने की भविष्यवाणी करने के लिए घनत्व, द्रव्यमान, आयतन और उछाल के बीच के संबंध को समझें।',
        'hud': [
          '',
          'वस्तुओं को पानी के टैंक में खींचें यह देखने के लिए कि वे तैरती हैं या डूबती हैं।',
          'द्रव्यमान मापने के लिए वस्तुओं को डिजिटल बैलेंस पर खींचें।',
          'मिट्टी की गेंद को नाव में बदलें और फिर से परीक्षण करें।',
        ],
        'steps': [
          {
            'concept': 'घनत्व की भविष्यवाणी',
            'action':
                'विभिन्न वस्तुओं (लकड़ी, पत्थर, सिक्का, बोतल) को पानी के टैंक में खींचें और छोड़ें।',
            'observation':
                'पानी से कम घनत्व (< 1 g/cm³) वाली वस्तुएं तैरती हैं, जबकि अधिक घनत्व (> 1 g/cm³) वाली वस्तुएं डूब जाती हैं।',
          },
          {
            'concept': 'मापन और उछाल',
            'action':
                'वस्तुओं का द्रव्यमान मापने के लिए उन्हें डिजिटल बैलेंस पर रखें।',
            'observation':
                'प्लास्टिक की बोतल जैसी भारी वस्तुएं तैर सकती हैं, जबकि छोटा सिक्का डूब जाता है। केवल द्रव्यमान उछाल का निर्धारण नहीं करता; आयतन भी महत्वपूर्ण है।',
          },
          {
            'concept': 'आकार और औसत घनत्व',
            'action':
                "ठोस मिट्टी की गेंद का आकार बदलने के लिए 'मिट्टी को नाव में बदलें' पर क्लिक करें।",
            'observation':
                'नाव का आकार हवा को फंसाता है, जिससे कुल आयतन काफी बढ़ जाता है। इससे औसत घनत्व 1 g/cm³ से कम हो जाता है, जिससे घनी मिट्टी से बने होने के बावजूद यह तैरने लगती है।',
          },
        ],
        'summaryLead': 'घनत्व उछाल निर्धारित करता है!',
        'summary':
            'वस्तु तैरती है यदि औसत घनत्व पानी से कम है। आकार मायने रखता है क्योंकि खोखला आकार आयतन बढ़ाता है, जिससे घनत्व कम हो जाता है।',
      },
      '2': {
        'title': 'परिदृश्य 2: तापमान और दबाव',
        'objective':
            'जानें कि वास्तविक दुनिया के परिदृश्यों में तापमान और दबाव में परिवर्तन पदार्थों के घनत्व को कैसे प्रभावित करते हैं।',
        'hud': [
          '',
          'हवा को गर्म करें (स्लाइडर) और देखें गुब्बारा ऊपर उठता है।',
          'गैस को संपीड़ित करें (बटन) और देखें पनडुब्बी गोता लगाती है।',
        ],
        'steps': [
          {
            'concept': 'तापमान प्रभाव',
            'action':
                'हवा के कणों को गर्म करने के लिए तापमान स्लाइडर का उपयोग करें।',
            'observation':
                'गर्म करने से ऊर्जा जुड़ती है, जिससे कण दूर-दूर फैल जाते हैं। इससे आयतन बढ़ता है और घनत्व कम होता है, यही कारण है कि हॉट एयर बैलून ऊपर उठते हैं।',
          },
          {
            'concept': 'दबाव प्रभाव',
            'action':
                "दबाव लागू करने के लिए 'टैंक भरें (संपीड़ित करें)' पर क्लिक करें।",
            'observation':
                'दबाव डालने से कण एक साथ करीब आते हैं, आयतन कम होता है और घनत्व बढ़ता है। पनडुब्बियां अपना समग्र घनत्व बढ़ाने के लिए पानी अंदर लेकर गोता लगाती हैं।',
          },
        ],
        'summaryLead': 'तापमान और दबाव घनत्व को नियंत्रित करते हैं!',
        'summary':
            'गर्म करने से पदार्थों का विस्तार होता है। दबाव गैसों को संपीड़ित करता है। ये सिद्धांत गुब्बारों और पनडुब्बियों को नियंत्रित करते हैं।',
      },
    },
  },
});

// ------------------------------------------------------------- constants ----

/// Design sizes of the fixed-size stages (scaled to fit, zoomable).
const Size _kTankStage = Size(670, 300);
const Size _kAirStageWide = Size(1000, 370);
const Size _kAirStageNarrow = Size(500, 760);

/// Canvas widths below this stack scenario 2's two halves (the source's
/// `lg:flex-row` breakpoint) and shrink the tray cards.
const double _kNarrowWidth = 700;

/// Canvases shorter than this (phone landscape) get a tighter top inset and
/// compact tray cards, so the tray and the tank fit on one screen.
const double _kShortHeight = 500;

/// Fixed tray card heights (room for a two-line label).
const double _kTrayCardHeight = 118;
const double _kTrayCardHeightCompact = 88;

/// `#water-tank` (outer box, with its `border-4` wall) inside the stage.
const Rect _kTankRect = Rect.fromLTWH(10, 20, 400, 264);
const double _kTankWall = 4;

/// `h-[65%]`: the share of the tank filled with water.
const double _kWaterFraction = 0.65;

/// `#digital-balance` column inside the stage.
const double _kBalanceLeft = 440;
const double _kBalanceWidth = 220;

/// Scenario 2 boxes (`w-48`, `h-40` / `h-48`, `sm:w-40 sm:h-64`).
const double _kTheoryWidth = 200;
const double _kHeatChamberHeight = 160;
const double _kPistonChamberHeight = 192;
const Size _kSceneBox = Size(170, 256);

/// `#piston` slides 90 px down when compressed (`sm` breakpoint).
const double _kPistonTravel = 90;
const double _kPistonHeight = 40;
const int _kGasParticles = 35;
const int _kHeatParticles = 25;

/// `#hot-air-balloon`: `bottom = 16 + t / 100 * 160` px.
const Size _kBalloonSize = Size(56, 74);
const double _kBalloonRise = 160;

/// `#submarine`: `top` surfaced vs dived (`sm` breakpoint).
const Size _kSubmarineSize = Size(80, 44);
const double _kSubSurfaced = 8;
const double _kSubDived = 90;

/// The source's `confetti({colors: [...]})` palette.
const List<Color> _kConfettiColors = [
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
];

const Color _kWood = Color(0xFF92400E);
const Color _kWoodDark = Color(0xFF713F12);
const Color _kRed300 = Color(0xFFFCA5A5);
const Color _kRed700 = Color(0xFFB91C1C);
const Color _kRed900 = Color(0xFF7F1D1D);
const Color _kSky200 = Color(0xFFBAE6FD);
const Color _kSky300 = Color(0xFF7DD3FC);
const Color _kSky900 = Color(0xFF0C4A6E);
const Color _kBlue300 = Color(0xFF93C5FD);
const Color _kPurple800 = Color(0xFF6B21A8);

// ------------------------------------------------------------------ model ----

/// The tray objects (`data-mat` / `data-den`).
///
/// [volume] is added so the balance reads mass = density × volume: the
/// source's `density × 20 g` made the large bottle lighter than the coin and
/// changed the clay's mass when it was reshaped, contradicting its own text.
enum _Material {
  wood(density: 0.6, volume: 50, lane: 0.13, size: Size(48, 48)),
  stone(density: 2.5, volume: 20, lane: 0.31, size: Size(48, 44)),
  coin(density: 7.8, volume: 0.7, lane: 0.5, size: Size(34, 34)),
  bottle(density: 0.2, volume: 250, lane: 0.68, size: Size(26, 52)),
  clayBall(density: 2.0, volume: 25, lane: 0.87, size: Size(46, 46)),
  clayBoat(density: 0.8, volume: 62.5, lane: 0.87, size: Size(62, 24));

  const _Material({
    required this.density,
    required this.volume,
    required this.lane,
    required this.size,
  });

  /// g/cm³.
  final double density;

  /// cm³.
  final double volume;

  /// Horizontal slot in the tank (fraction of its width), so objects dropped
  /// in never overlap (the source used a random `left`).
  final double lane;

  /// Drawn size in the tank and on the balance.
  final Size size;

  double get mass => density * volume;
  bool get floats => density < 1.0;
  bool get isClay => this == clayBall || this == clayBoat;
  String get label => _tx.s('materials.$name');
  String get massLabel => '${mass.toStringAsFixed(1)} g';
}

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result);

  final String Function() action;
  final String Function() result;
}

// ------------------------------------------------------------------- page ----

class Cl8Ch09A5FloatingSinkingDensityPage extends StatefulWidget {
  const Cl8Ch09A5FloatingSinkingDensityPage({super.key});

  @override
  State<Cl8Ch09A5FloatingSinkingDensityPage> createState() =>
      _Cl8Ch09A5FloatingSinkingDensityPageState();
}

class _Cl8Ch09A5FloatingSinkingDensityPageState
    extends State<Cl8Ch09A5FloatingSinkingDensityPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.5,
    max: 2.5,
  );
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();
  final ScrollController _workspaceScroll = ScrollController();

  /// Seconds since the page opened; drives the water wave, the particles and
  /// the pulsing "Causes" arrows.
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _clock.value = elapsed.inMicroseconds / 1e6,
  );

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  /// Piston position: 0 released, 1 compressed (`transition-all
  /// duration-500`).
  late final AnimationController _piston = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _pistonTravel = CurvedAnimation(
    parent: _piston,
    curve: Curves.easeInOut,
  );

  final List<Timer> _timers = [];
  DateTime _lastSliderTick = DateTime.fromMillisecondsSinceEpoch(0);

  // Shared (source `State`).
  int _scenario = 1;
  int _step = 1;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  Size _stageViewport = Size.zero;

  // Scenario 1 (source `s1Progress` + the tank / balance DOM).
  /// Objects in the tank, each with the serial of its latest drop (a new
  /// serial replays the fall).
  final Map<_Material, int> _tankDrops = {};
  int _dropSerial = 0;
  final Set<_Material> _tested = {};
  bool _clayIsBoat = false;
  _Material? _onBalance;
  bool _balanceFlash = false;

  // Scenario 2 (source `s2Progress` + `isCompressed`).
  double _temperature = 20;
  bool _heated = false;
  bool _compressed = false;
  bool _pressureTested = false;

  // Overlays.
  final List<_LogEntry> _log = [];
  bool? _logOpen;
  Offset _logOffset = Offset.zero;

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
    _piston.dispose();
    _zoom.dispose();
    _logScroll.dispose();
    _workspaceScroll.dispose();
    super.dispose();
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
  /// Scenario 1 has three steps, scenario 2 two.
  int get _stepCount => _scenario == 1 ? 3 : 2;

  /// Appends a log row; call inside `setState`.
  void _pushLog(String Function() action, String Function() result) {
    _log.add(_LogEntry(action, result));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _logScroll.hasClients) {
        _logScroll.jumpTo(_logScroll.position.maxScrollExtent);
      }
    });
  }

  void _clearLog() {
    _rt_playSfx(_rt_Sfx.click);
    setState(_log.clear);
  }

  /// The source's `setupScenario` (state only; call inside `setState`).
  void _enterScenario(int scenario) {
    _scenario = scenario;
    _step = 1;
    _toggledTiles.clear();
    _log.clear();
    _tankDrops.clear();
    _tested.clear();
    _clayIsBoat = false;
    _onBalance = null;
    _balanceFlash = false;
    _temperature = 20;
    _heated = false;
    _compressed = false;
    _pressureTested = false;
    _piston.value = 0;
  }

  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() => _enterScenario(scenario));
    _zoom.reset();
    // The two scenarios lay out differently: start each at the top.
    if (_workspaceScroll.hasClients) _workspaceScroll.jumpTo(0);
  }

  /// The source's `resetApp` (minus the page reload; the shell owns the
  /// shutter).
  void _restart() {
    _changeScenario(1);
    setState(() {
      _showLabels = true;
      _panMode = false;
    });
  }

  /// Moves to [step] with the source's success chime. Past the last step the
  /// HUD hides and the summary follows 1.5 s later (source
  /// `setTimeout(completeScenario, 1500)`).
  void _advanceTo(int step) {
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _step = step;
      _toggledTiles.clear();
    });
    if (step > _stepCount) {
      final scenario = _scenario;
      _after(1500, () {
        if (_scenario == scenario && _step > _stepCount) _showSummary();
      });
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

  /// Zooms the stage about its centre, keeping any pan (source `zoomCam`).
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
  /// The source's `completeScenario` (Key Takeaway modal + confetti).
  void _showSummary() {
    final scenario = _scenario;
    final last = scenario >= 2;
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _rt_Tw.blue600,
      buttonLabel: _tx.s(last ? 'restartLab' : 'nextScenario'),
      body: _SummaryBody(
        heading: _tx.s('keyTakeaway'),
        lead: _tx.s('scenarios.$scenario.summaryLead'),
        text: _tx.s('scenarios.$scenario.summary'),
        footer: _tx.s('scenarioComplete'),
      ),
      onConfirm: () {
        _rt_playSfx(_rt_Sfx.click);
        _changeScenario(last ? 1 : scenario + 1);
      },
    );
    _launchConfetti();
  }

  void _launchConfetti() {
    _confettiEntry?.remove();
    final pieces = List.generate(150, (_) => _ConfettiPiece.random(_random));
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

  // ------------------------------------------------------ scenario 1 logic --
  /// The source's `handleDrop(item, 'water-tank')`.
  void _dropInTank(_Material material) {
    if (_scenario != 1) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _tankDrops[material] = ++_dropSerial;
      _tested.add(material);
      _pushLog(
        () => material.label,
        () => _tx.s(material.floats ? 'obsFloated' : 'obsSank'),
      );
    });
    // Source `checkS1Progress`: three different objects finish step 1, the
    // clay boat finishes step 3.
    if (_step == 1 && _tested.length >= 3) {
      _advanceTo(2);
    } else if (_step == 3 && material == _Material.clayBoat) {
      _advanceTo(4);
    }
  }

  /// The source's `handleDrop(item, 'digital-balance')`. Only a measurement
  /// made during step 2 finishes it (in the source a step-1 measurement let
  /// the next, unrelated drop finish step 2).
  void _dropOnBalance(_Material material) {
    if (_scenario != 1) return;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _onBalance = material;
      _balanceFlash = true;
      _pushLog(
        () => material.label,
        () => '${_tx.s('obsMass')}: ${material.massLabel}',
      );
    });
    _after(300, () => setState(() => _balanceFlash = false));
    if (_step == 2) _advanceTo(3);
  }

  /// `#btn-reshape` shows once the clay ball has been tested in the tank (as
  /// in the source) and, so step 3 can always be done, from step 3 on.
  bool get _canReshape =>
      _scenario == 1 &&
      !_clayIsBoat &&
      _step <= _stepCount &&
      (_step == 3 || _tested.contains(_Material.clayBall));

  /// The source's `reshapeClay`. The clay keeps its mass; it no longer skips
  /// the balance step.
  void _reshapeClay() {
    if (!_canReshape) return;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _clayIsBoat = true;
      // The sunk ball *is* the clay that became the boat.
      _tankDrops.remove(_Material.clayBall);
      if (_onBalance == _Material.clayBall) _onBalance = null;
      _pushLog(() => _tx.s('reshape'), () => _tx.s('obsVolIncDenDec'));
    });
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// `#temp-density`.
  String get _heatDensityKey => _temperature < 40
      ? 'denHigh'
      : (_temperature < 70 ? 'denMedium' : 'denLow');

  /// The source's `updateTempAndBalloon` (slider `oninput`).
  void _onTemperatureChanged(double value) {
    if (_scenario != 2) return;
    final now = DateTime.now();
    if (now.difference(_lastSliderTick).inMilliseconds > 100) {
      _rt_playSfx(_rt_Sfx.tap);
      _lastSliderTick = now;
    }
    var heatedNow = false;
    setState(() {
      _temperature = value.roundToDouble();
      if (_temperature > 80 && !_heated) {
        _heated = true;
        heatedNow = true;
        _pushLog(() => _tx.s('tempEffect'), () => _tx.s('obsVolExpDenDec'));
      }
    });
    if (heatedNow) _syncScenario2Step();
  }

  /// The source's `togglePressureAndSub`.
  void _togglePressure() {
    if (_scenario != 2) return;
    _rt_playSfx(_rt_Sfx.toggle);
    final compress = !_compressed;
    var firstTime = false;
    setState(() {
      _compressed = compress;
      if (compress) {
        _pushLog(() => _tx.s('pressEffect'), () => _tx.s('obsVolDecDenInc'));
        if (!_pressureTested) {
          _pressureTested = true;
          firstTime = true;
        }
      }
    });
    if (compress) {
      _piston.forward();
    } else {
      _piston.reverse();
    }
    if (firstTime) _syncScenario2Step();
  }

  /// The source's `checkS2Progress`, plus the step it never reached: heating
  /// moves on to step 2 ("COMPRESS ..."), and both tests finish the scenario,
  /// in either order.
  void _syncScenario2Step() {
    final step = !_heated ? 1 : (!_pressureTested ? 2 : 3);
    if (step != _step) {
      _advanceTo(step);
    } else {
      _rt_playSfx(_rt_Sfx.success);
    }
  }

  // ----------------------------------------------------------------- build --
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
            accent: _rt_Tw.blue500,
            headerGradient: [_rt_Tw.slate950, _rt_Tw.blue900],
            headerSubtitleColor: _rt_Tw.blue100,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.science,
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
            if (_step <= _stepCount)
              Positioned(
                top: 8,
                left: 72,
                right: 72,
                child: Center(child: _hud()),
              ),
            _observationLog(context),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- sidebar --
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObjective'),
          desc: _tx.s('scenarios.$_scenario.objective'),
          accent: _rt_Tw.blue500,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('selectScenario'),
                icon: Icons.menu_book,
                color: _rt_Tw.blue500,
              ),
              for (var scenario = 1; scenario <= 2; scenario++)
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
                  observation: _tx.s(
                    'scenarios.$_scenario.steps.${i - 1}.observation',
                  ),
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
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- overlays --
  /// The source's `#hud-container` ("Current Task").
  Widget _hud() {
    return IgnorePointer(
      child: Container(
        key: const ValueKey('hud'),
        constraints: const BoxConstraints(maxWidth: 512),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _rt_Tw.blue500.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info,
                  size: 14,
                  color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600),
                ),
                const SizedBox(width: 6),
                Text(
                  _tx.s('currentTask').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              _tx.s('scenarios.$_scenario.hud.$_step'),
              key: const ValueKey('hud-text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.text,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The source's draggable, collapsible `#observation-table`.
  ///
  /// Anchored bottom-right rather than the source's top-right: the shell's
  /// toolbar owns that corner here.
  Widget _observationLog(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final open = _logOpen ?? !compact;
    final width = compact ? 200.0 : 280.0;
    final muted = _rt_Lab.textMuted;
    return Positioned(
      bottom: 16 - _logOffset.dy,
      right: 62 - _logOffset.dx,
      width: width,
      child: Container(
        key: const ValueKey('obs-log'),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _rt_Lab.borderStrong),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) => setState(() {
                final next = _logOffset + details.delta;
                _logOffset = Offset(
                  next.dx.clamp(-1600.0, 50.0),
                  next.dy.clamp(-800.0, 10.0),
                );
              }),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: _rt_Lab.textFaint,
                  ),
                  const Icon(
                    Icons.table_chart,
                    size: 14,
                    color: _rt_Tw.blue500,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _tx.s('obsLog'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const ValueKey('obs-clear'),
                    borderRadius: BorderRadius.circular(6),
                    onTap: _clearLog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _rt_Lab.tintedBorder(_rt_Tw.red500),
                        ),
                      ),
                      child: Text(
                        _tx.s('clear').toUpperCase(),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: _rt_Lab.onTinted(_rt_Tw.red400, _rt_Tw.red600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  InkResponse(
                    key: const ValueKey('obs-toggle'),
                    radius: 14,
                    onTap: () {
                      _rt_playSfx(_rt_Sfx.click);
                      setState(() => _logOpen = !open);
                    },
                    child: Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            if (open) ...[
              Divider(height: 10, color: _rt_Lab.border),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: compact ? 110 : 190),
                child: _logTable(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _logTable() {
    final cellStyle = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      color: _rt_Lab.text,
    );
    final resultStyle = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600),
    );
    final headStyle = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      color: _rt_Lab.text,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 5, child: Text(_tx.s('action'), style: headStyle)),
            const SizedBox(width: 6),
            Expanded(flex: 6, child: Text(_tx.s('result'), style: headStyle)),
          ],
        ),
        const SizedBox(height: 4),
        if (_log.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _tx.s('noObs'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontStyle: FontStyle.italic,
                color: _rt_Lab.textMuted,
              ),
            ),
          )
        else
          Flexible(
            child: SingleChildScrollView(
              controller: _logScroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in _log)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: _rt_Lab.border),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(entry.action(), style: cellStyle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 6,
                            child: Text(entry.result(), style: resultStyle),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // -------------------------------------------------------------- workspace --
  /// The source's `#interactive-ui-layer`: one view per scenario.
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Clear the HUD (top), the toolbar strip (right) and the floating
        // log (bottom).
        const maxContentWidth = 1040.0;
        final short = constraints.maxHeight < _kShortHeight;
        final topInset = short ? 84.0 : 100.0;
        final contentWidth = math.min(
          maxContentWidth,
          math.max(0.0, constraints.maxWidth - 12 - 60),
        );
        // Height left under the HUD.
        final available = constraints.maxHeight - topInset - 16;
        return SingleChildScrollView(
          key: const ValueKey('workspace'),
          controller: _workspaceScroll,
          padding: EdgeInsets.fromLTRB(12, topInset, 60, 170),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: _scenario == 1
                  ? _floatSinkView(contentWidth, available, short: short)
                  : _airView(contentWidth, available),
            ),
          ),
        );
      },
    );
  }

  /// Wraps a fixed-size stage so it scales to fit and can be zoomed / panned
  /// (pan only in pan mode, so the workspace still scrolls).
  Widget _stageBox(
    Widget stage,
    Size design,
    double width,
    double maxHeight, {
    double maxScale = 1.3,
  }) {
    final aspect = design.width / design.height;
    final fitWidth = math.min(
      math.min(width, design.width * maxScale),
      maxHeight * aspect,
    );
    final size = Size(fitWidth, fitWidth / aspect);
    _stageViewport = size;
    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InteractiveViewer(
            transformationController: _zoom.transform,
            panEnabled: _panMode,
            scaleEnabled: _panMode,
            minScale: _zoom.min,
            maxScale: _zoom.max,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox.fromSize(size: design, child: stage),
            ),
          ),
        ),
      ),
    );
  }

  /// Fades the source's `.label-text` elements with the labels toggle.
  Widget _label(Widget child) {
    return IgnorePointer(
      ignoring: !_showLabels,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showLabels ? 1 : 0,
        child: child,
      ),
    );
  }

  /// Uppercase `tracking-widest` heading over a theory chamber.
  Widget _heading(String text, Color color) {
    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.visible,
      softWrap: false,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: color,
      ),
    );
  }

  /// Small grey caption under a scene or tray object.
  Widget _caption(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _rt_Tw.slate500,
      ),
    );
  }

  /// "Density: `value`" under each theory chamber.
  Widget _densityLine(String key, String valueKey) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${_tx.s('density')}: '),
          TextSpan(
            text: _tx.s(valueKey),
            style: TextStyle(color: _rt_Lab.text, fontWeight: FontWeight.w900),
          ),
        ],
      ),
      key: ValueKey(key),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _rt_Tw.slate500,
      ),
    );
  }

  // -------------------------------------------------------- scenario 1 UI --
  /// `#ui-sc1`: the object tray above the tank / balance stage.
  Widget _floatSinkView(double width, double available, {required bool short}) {
    final compact = short || width < _kNarrowWidth;
    final gap = compact ? 10.0 : 22.0;
    final trayHeight = compact ? _kTrayCardHeightCompact : _kTrayCardHeight;
    final tray = [
      _Material.wood,
      _Material.stone,
      _Material.coin,
      _Material.bottle,
      _clayIsBoat ? _Material.clayBoat : _Material.clayBall,
    ];
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: compact ? 8 : 18,
          runSpacing: 10,
          children: [
            for (final material in tray) _trayCard(material, compact: compact),
          ],
        ),
        SizedBox(height: gap),
        _stageBox(
          _tankStage(),
          _kTankStage,
          width,
          // Fit under the tray, so a card can be dragged into the tank
          // without scrolling.
          math.max(150.0, available - trayHeight - gap),
          maxScale: 1.15,
        ),
      ],
    );
  }

  /// One `.custom-draggable` tray card. It stays in the tray after a drop so
  /// the same object can be tested in the tank and on the balance.
  Widget _trayCard(_Material material, {required bool compact}) {
    final face = _trayCardFace(material, compact: compact);
    return Draggable<_Material>(
      key: ValueKey('mat-${material.isClay ? 'clay' : material.name}'),
      data: material,
      onDragStarted: () => _rt_playSfx(_rt_Sfx.pop),
      // Source: a click for a drop outside both drop zones.
      onDraggableCanceled: (_, _) => _rt_playSfx(_rt_Sfx.click),
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.scale(
          scale: 1.1,
          child: _trayCardFace(material, compact: compact, lifted: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: face),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
    );
  }

  Widget _trayCardFace(
    _Material material, {
    required bool compact,
    bool lifted = false,
  }) {
    final box = compact ? 36.0 : 48.0;
    final scale = box / 48;
    return Container(
      width: compact ? 76 : 108,
      height: compact ? _kTrayCardHeightCompact : _kTrayCardHeight,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: compact ? 8 : 12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.35 : 0.15),
            blurRadius: lifted ? 24 : 8,
            offset: Offset(0, lifted ? 10 : 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 52 * scale,
            child: Center(
              child: SizedBox.fromSize(
                size: material.size * scale,
                child: CustomPaint(painter: _MaterialPainter(material)),
              ),
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Flexible(
            child: _label(
              Text(
                material.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 9.5 : 11.5,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The tank, the balance and the reshape button.
  Widget _tankStage() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(rect: _kTankRect, child: _waterTank()),
        Positioned(
          left: _kBalanceLeft,
          top: 30,
          width: _kBalanceWidth,
          child: _balance(),
        ),
        if (_canReshape)
          Positioned(
            left: _kBalanceLeft,
            top: 232,
            width: _kBalanceWidth,
            child: _ChunkyButton(
              key: const ValueKey('btn-reshape'),
              label: _tx.s('reshape'),
              color: _rt_Tw.purple600,
              borderColor: _kPurple800,
              onPressed: _reshapeClay,
            ),
          ),
      ],
    );
  }

  /// `#water-tank` drop zone.
  Widget _waterTank() {
    return DragTarget<_Material>(
      key: const ValueKey('water-tank'),
      onAcceptWithDetails: (details) => _dropInTank(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: (_rt_appTheme.isDark ? _rt_Tw.slate900 : Colors.white)
                .withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            border: Border.all(
              color: hovering ? _rt_Tw.blue500 : _rt_Tw.slate400,
              width: _kTankWall,
            ),
            boxShadow: [
              BoxShadow(
                color: _rt_Lab.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: LayoutBuilder(
              builder: (context, box) => _tankContents(box.biggest),
            ),
          ),
        );
      },
    );
  }

  Widget _tankContents(Size tank) {
    final waterTop = tank.height * (1 - _kWaterFraction);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _WaterPainter(_clock, waterTop: waterTop, front: false),
          ),
        ),
        for (final entry in _tankDrops.entries)
          _tankObject(entry.key, entry.value, tank, waterTop),
        // A thin front layer tints the submerged part of each object.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WaterPainter(_clock, waterTop: waterTop, front: true),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: _label(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _rt_Lab.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 4)],
                ),
                child: Text(
                  _tx.s('waterTank'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// A dropped object falling in with a bounce (GSAP `bounce.out`, 1 s).
  /// Sinkers rest on the bottom; floaters ride at the waterline with the
  /// share of their height equal to their density under water.
  Widget _tankObject(
    _Material material,
    int serial,
    Size tank,
    double waterTop,
  ) {
    final size = material.size;
    final left = material.lane * tank.width - size.width / 2;
    final rest = material.floats
        ? waterTop - size.height * (1 - material.density)
        : tank.height - size.height - 6;
    const start = 4.0;
    return TweenAnimationBuilder<double>(
      key: ValueKey('drop-${material.name}-$serial'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.bounceOut,
      builder: (context, t, child) => Positioned(
        left: left,
        top: start + (rest - start) * t,
        width: size.width,
        height: size.height,
        child: child!,
      ),
      child: CustomPaint(
        key: ValueKey('tank-${material.name}'),
        painter: _MaterialPainter(material),
      ),
    );
  }

  /// `#digital-balance` drop zone: pan, the weighed object and the readout.
  Widget _balance() {
    final weighed = _onBalance;
    return DragTarget<_Material>(
      key: const ValueKey('balance'),
      onAcceptWithDetails: (details) => _dropOnBalance(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: _balanceFlash
                ? _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500)
                : _rt_Lab.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hovering ? _rt_Tw.blue500 : _rt_Tw.slate400,
              width: hovering ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _rt_Lab.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _label(
                Text(
                  _tx.s('balance'),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.slate500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 150,
                height: 72,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (weighed != null)
                      Positioned(
                        bottom: 11,
                        child: SizedBox.fromSize(
                          size: weighed.size,
                          child: CustomPaint(
                            key: ValueKey('balance-${weighed.name}'),
                            painter: _MaterialPainter(weighed),
                          ),
                        ),
                      ),
                    // `#balance-pan`
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_rt_Tw.slate400, _rt_Tw.slate300],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // `#balance-display`
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _rt_Tw.slate800,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rt_Tw.slate600, width: 2),
                ),
                child: Text(
                  weighed?.massLabel ?? '0.0 g',
                  key: const ValueKey('balance-display'),
                  textAlign: TextAlign.center,
                  // `font-mono` digits, without relying on a platform font.
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: _rt_Tw.green400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------- scenario 2 UI --
  /// `#ui-sc2`: heat (left / top) and pressure (right / bottom), each a
  /// theory chamber "causing" a real-world scene.
  Widget _airView(double width, double available) {
    final narrow = width < _kNarrowWidth;
    return narrow
        ? _stageBox(
            _airStage(narrow: true),
            _kAirStageNarrow,
            width,
            double.infinity,
            maxScale: 1,
          )
        : _stageBox(
            _airStage(narrow: false),
            _kAirStageWide,
            width,
            math.max(200.0, available),
            maxScale: 1.15,
          );
  }

  Widget _airStage({required bool narrow}) {
    final heat = _effectGroup(
      theory: _heatColumn(),
      arrowColor: _rt_Tw.orange400,
      scene: _balloonScene(),
    );
    final pressure = _effectGroup(
      theory: _pressureColumn(),
      arrowColor: _rt_Tw.blue400,
      scene: _submarineScene(),
    );
    final divider = Container(
      width: narrow ? 380 : 1,
      height: narrow ? 1 : 260,
      margin: narrow
          ? const EdgeInsets.symmetric(vertical: 22)
          : const EdgeInsets.symmetric(horizontal: 26),
      color: _rt_Lab.borderStrong,
    );
    return Center(
      child: narrow
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [heat, divider, pressure],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [heat, divider, pressure],
            ),
    );
  }

  Widget _effectGroup({
    required Widget theory,
    required Color arrowColor,
    required Widget scene,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        theory,
        const SizedBox(width: 12),
        _causesArrow(arrowColor),
        const SizedBox(width: 12),
        scene,
      ],
    );
  }

  /// Pulsing "→ Causes" between a chamber and its scene (`animate-pulse`).
  Widget _causesArrow(Color color) {
    return SizedBox(
      width: 66,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _clock,
            builder: (context, seconds, child) => Opacity(
              opacity: 0.75 + 0.25 * math.cos(seconds * math.pi),
              child: child,
            ),
            child: Icon(Icons.arrow_forward, size: 32, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s('causes').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// "Heat & Buoyancy": particle box, burner, slider, density.
  Widget _heatColumn() {
    return SizedBox(
      width: _kTheoryWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(_heading(_tx.s('tempEffect'), _rt_Tw.orange500)),
          const SizedBox(height: 10),
          Container(
            height: _kHeatChamberHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _rt_Tw.slate900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Tw.slate400, width: 2),
              boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
            ),
            child: CustomPaint(
              key: const ValueKey('particle-box'),
              painter: _HeatChamberPainter(_clock, temperature: _temperature),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _rt_Lab.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Lab.borderStrong),
            ),
            child: Row(
              children: [
                const Icon(Icons.thermostat, size: 18, color: _rt_Tw.blue500),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: _rt_Tw.orange500,
                      inactiveTrackColor: _rt_appTheme.isDark
                          ? _rt_Tw.slate600
                          : _rt_Tw.slate300,
                      thumbColor: _rt_Tw.orange500,
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9,
                      ),
                    ),
                    child: Slider(
                      key: const ValueKey('temp-slider'),
                      value: _temperature,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: _onTemperatureChanged,
                    ),
                  ),
                ),
                const Icon(Icons.thermostat, size: 18, color: _rt_Tw.red500),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _label(_densityLine('temp-density', _heatDensityKey)),
        ],
      ),
    );
  }

  /// "Pressure & Density": piston chamber, Fill / Empty button, density.
  Widget _pressureColumn() {
    return SizedBox(
      width: _kTheoryWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(_heading(_tx.s('pressEffect'), _rt_Tw.blue500)),
          const SizedBox(height: 10),
          Container(
            height: _kPistonChamberHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _rt_Tw.slate800,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              border: Border.all(color: _rt_Tw.slate500, width: 4),
              boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
            ),
            child: CustomPaint(
              key: const ValueKey('piston-chamber'),
              painter: _PistonPainter(_clock, _pistonTravel),
            ),
          ),
          const SizedBox(height: 10),
          _ChunkyButton(
            key: const ValueKey('btn-compress'),
            label: _tx.s(_compressed ? 'release' : 'compress'),
            color: _rt_Tw.blue600,
            borderColor: _rt_Tw.blue800,
            onPressed: _togglePressure,
          ),
          const SizedBox(height: 8),
          _label(
            _densityLine(
              'press-density',
              _compressed ? 'denHighComp' : 'denNormal',
            ),
          ),
        ],
      ),
    );
  }

  /// Sky box with the hot-air balloon (the source's 🎈 emoji, painted).
  Widget _balloonScene() {
    final dark = _rt_appTheme.isDark;
    final inner = Size(_kSceneBox.width - 4, _kSceneBox.height - 4);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _kSceneBox.width,
          height: _kSceneBox.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: dark ? _kSky900 : _kSky200,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? _rt_Tw.slate700 : _rt_Tw.slate300,
              width: 2,
            ),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _CloudsPainter(dark: dark)),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                left: (inner.width - _kBalloonSize.width) / 2,
                bottom: 16 + _temperature / 100 * _kBalloonRise,
                width: _kBalloonSize.width,
                height: _kBalloonSize.height,
                child: const CustomPaint(
                  key: ValueKey('hot-air-balloon'),
                  painter: _BalloonPainter(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _label(_caption(_tx.s('balloon'))),
      ],
    );
  }

  /// Sea box with the submarine (the source's 🤿 emoji, painted).
  Widget _submarineScene() {
    final dark = _rt_appTheme.isDark;
    final inner = Size(_kSceneBox.width - 4, _kSceneBox.height - 4);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _kSceneBox.width,
          height: _kSceneBox.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? _rt_Tw.slate700 : _rt_Tw.slate300,
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? [_rt_Tw.blue900, _rt_Tw.slate950]
                  : [_rt_Tw.blue400, _rt_Tw.blue900.withValues(alpha: 0.9)],
            ),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
          ),
          child: Stack(
            children: [
              // Dashed surface line at 25 %.
              Positioned(
                left: 0,
                right: 0,
                top: inner.height * 0.25,
                height: 1,
                child: const CustomPaint(painter: _DashedLinePainter()),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                left: (inner.width - _kSubmarineSize.width) / 2,
                top: _compressed ? _kSubDived : _kSubSurfaced,
                width: _kSubmarineSize.width,
                height: _kSubmarineSize.height,
                child: const CustomPaint(
                  key: ValueKey('submarine'),
                  painter: _SubmarinePainter(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _label(_caption(_tx.s('submarine'))),
      ],
    );
  }
}

// -------------------------------------------------------------- widgets ----

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
            color: active ? _rt_Tw.blue500 : _rt_Lab.surface,
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

enum _TileStatus { done, active, upcoming }

/// One collapsible "Step n" card of the source's teacher board.
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
  final String observation;
  final _TileStatus status;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final active = status == _TileStatus.active;
    final done = status == _TileStatus.done;
    final accentText = _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600);
    final titleColor = active
        ? accentText
        : (done
              ? _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700)
              : _rt_Lab.textMuted);

    final Widget badge = Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? _rt_Tw.blue500
            : (done ? _rt_Tw.blue500.withValues(alpha: 0.2) : _rt_Lab.overlay),
        border: Border.all(
          color: active
              ? _rt_Tw.blue400
              : (done
                    ? _rt_Tw.blue500.withValues(alpha: 0.4)
                    : _rt_Tw.slate400),
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
              ? _rt_Tw.blue500
              : (done ? _rt_Tw.blue500.withValues(alpha: 0.5) : _rt_Lab.border),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _rt_Tw.blue500.withValues(alpha: 0.2),
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
                ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
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
                      color: _rt_Tw.blue500,
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
                      color: _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _rt_Lab.tintedBorder(_rt_Tw.blue500),
                      ),
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
                              _rt_Tw.blue400,
                              _rt_Tw.blue700,
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
              ),
            ),
        ],
      ),
    );
  }
}

/// "Key Takeaway" body of the summary popup.
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.heading,
    required this.lead,
    required this.text,
    required this.footer,
  });

  final String heading;
  final String lead;
  final String text;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final accent = _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              heading.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: accent,
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

// ------------------------------------------------------------- painters ----

/// The source's `.mat-3d-cube` blocks, one look per [_Material], with the
/// inset light / shade of their `box-shadow`.
class _MaterialPainter extends CustomPainter {
  const _MaterialPainter(this.material);

  final _Material material;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / material.size.width;
    final rect = Offset.zero & size;
    final shape = _outline(size, scale);
    final clear = material == _Material.bottle;

    canvas.drawShadow(shape, Colors.black, 3 * scale, clear);
    canvas.drawPath(shape, Paint()..shader = _fill().createShader(rect));

    canvas.save();
    canvas.clipPath(shape);
    switch (material) {
      case _Material.coin:
        canvas.drawCircle(
          rect.center,
          size.width * 0.36,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 * scale
            ..color = _kWood.withValues(alpha: 0.5),
        );
      case _Material.clayBoat:
        // The hollow that traps air.
        canvas.drawOval(
          Rect.fromLTWH(
            size.width * 0.06,
            -size.height * 0.2,
            size.width * 0.88,
            size.height * 0.55,
          ),
          Paint()..color = _kRed900.withValues(alpha: 0.5),
        );
      case _Material.bottle:
        // Label band.
        canvas.drawRect(
          Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.18),
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
      case _Material.wood:
      case _Material.stone:
      case _Material.clayBall:
        break;
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: clear ? 0.4 : 0.35),
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: clear ? 0.1 : 0.3),
          ],
          stops: const [0, 0.35, 0.6, 1],
        ).createShader(rect),
    );
    canvas.restore();

    if (material == _Material.bottle) {
      canvas.drawPath(
        shape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = scale
          ..color = _kSky200,
      );
      // Cap.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.26,
            0,
            size.width * 0.48,
            size.height * 0.1,
          ),
          Radius.circular(2 * scale),
        ),
        Paint()..color = _rt_Tw.blue500,
      );
    }
  }

  Path _outline(Size size, double scale) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    switch (material) {
      case _Material.wood:
        return Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)));
      case _Material.stone:
        // `border-radius: 10px 18px 8px 16px`.
        return Path()..addRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: Radius.circular(10 * scale),
            topRight: Radius.circular(18 * scale),
            bottomRight: Radius.circular(8 * scale),
            bottomLeft: Radius.circular(16 * scale),
          ),
        );
      case _Material.coin:
      case _Material.clayBall:
        return Path()..addOval(rect);
      case _Material.bottle:
        return Path()
          ..addRRect(
            RRect.fromLTRBAndCorners(
              0,
              h * 0.24,
              w,
              h,
              topLeft: Radius.circular(8 * scale),
              topRight: Radius.circular(8 * scale),
              bottomLeft: Radius.circular(4 * scale),
              bottomRight: Radius.circular(4 * scale),
            ),
          )
          ..addRRect(
            RRect.fromLTRBR(
              w * 0.3,
              h * 0.08,
              w * 0.7,
              h * 0.3,
              Radius.circular(3 * scale),
            ),
          );
      case _Material.clayBoat:
        // `clip-path: polygon(0 0, 100% 0, 80% 100%, 20% 100%)`.
        return Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w * 0.8, h)
          ..lineTo(w * 0.2, h)
          ..close();
    }
  }

  Gradient _fill() {
    switch (material) {
      case _Material.wood:
        // `repeating-linear-gradient(45deg, ... 4px, ... 8px)`: 8 px bands
        // along the diagonal (0.2357 alignment units on a 48 px block).
        return const LinearGradient(
          begin: Alignment(-1, 1),
          end: Alignment(-1 + 0.2357, 1 - 0.2357),
          colors: [_kWood, _kWood, _kWoodDark, _kWoodDark],
          stops: [0, 0.5, 0.5, 1],
          tileMode: TileMode.repeated,
        );
      case _Material.stone:
        return const RadialGradient(
          center: Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: [_rt_Tw.slate300, _rt_Tw.slate500, _rt_Tw.slate700],
        );
      case _Material.coin:
        return const RadialGradient(
          center: Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: [_rt_Tw.amber400, _rt_Tw.amber600, _kWood],
        );
      case _Material.bottle:
        return LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.6),
            _kSky300.withValues(alpha: 0.8),
          ],
        );
      case _Material.clayBall:
      case _Material.clayBoat:
        return const RadialGradient(
          center: Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: [_kRed300, _rt_Tw.red500, _kRed700],
        );
    }
  }

  @override
  bool shouldRepaint(_MaterialPainter old) => old.material != material;
}

/// The tank's water with its moving `.water-wave` crest. The back layer is
/// the water itself; the [front] layer is a faint tint drawn over the
/// dropped objects so their submerged part looks under water.
class _WaterPainter extends CustomPainter {
  _WaterPainter(this.clock, {required this.waterTop, required this.front})
    : super(repaint: clock);

  final ValueNotifier<double> clock;
  final double waterTop;
  final bool front;

  @override
  void paint(Canvas canvas, Size size) {
    // `wave-anim`: 32 px waves sliding left by one wave every 2 s.
    final phase = clock.value * math.pi;
    double crest(double x) =>
        waterTop + 3 * math.sin(x * 2 * math.pi / 32 + phase);

    final line = Path()..moveTo(0, crest(0));
    for (var x = 4.0; x < size.width; x += 4) {
      line.lineTo(x, crest(x));
    }
    line.lineTo(size.width, crest(size.width));
    final body = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    if (!front) {
      final water = Rect.fromLTRB(0, waterTop - 4, size.width, size.height);
      canvas.drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _rt_Tw.blue400.withValues(alpha: 0.5),
              _rt_Tw.blue600.withValues(alpha: 0.8),
            ],
          ).createShader(water),
      );
      return;
    }
    canvas.drawPath(
      body,
      Paint()..color = _rt_Tw.blue500.withValues(alpha: 0.16),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_WaterPainter old) =>
      old.waterTop != waterTop || old.front != front || old.clock != clock;
}

/// `#particle-box` + `#burner-flame`: 25 air particles whose spacing and
/// jiggle grow with the temperature over a burner glow.
class _HeatChamberPainter extends CustomPainter {
  _HeatChamberPainter(this.clock, {required this.temperature})
    : super(repaint: clock);

  final ValueNotifier<double> clock;
  final double temperature;

  @override
  void paint(Canvas canvas, Size size) {
    final heat = temperature / 100;

    // Burner: opacity 0.2-1.0, `scaleY(1 + t / 50)` about its centre.
    final glow = heat * 0.8 + 0.2;
    final flame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 10),
      width: 40,
      height: 40 * (1 + temperature / 50),
    );
    canvas.drawOval(
      flame,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _rt_Tw.orange600.withValues(alpha: glow),
            _rt_Tw.yellow400.withValues(alpha: glow),
            _rt_Tw.yellow400.withValues(alpha: 0),
          ],
        ).createShader(flame),
    );

    // The source widened a flex `gap` from 1 to 6 px; here the 5 x 5 grid
    // spreads from 10 to 28 px and the particles jiggle faster when hot.
    const columns = 5;
    final spacing = 10 + 18 * heat;
    final amplitude = 0.6 + 3.4 * heat;
    final speed = 2 + 10 * heat;
    final seconds = clock.value;
    final centre = Offset(size.width / 2, size.height / 2 - 8);
    final paint = Paint()..color = _rt_Tw.red500;
    for (var i = 0; i < _kHeatParticles; i++) {
      final row = i ~/ columns;
      final column = i % columns;
      final seed = i * 2.399;
      final jiggle =
          Offset(
            math.sin(seconds * speed + seed),
            math.cos(seconds * speed * 0.87 + seed * 1.7),
          ) *
          amplitude;
      canvas.drawCircle(
        centre + Offset((column - 2) * spacing, (row - 2) * spacing) + jiggle,
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeatChamberPainter old) =>
      old.temperature != temperature || old.clock != clock;
}

/// `#piston-chamber`: the gas fills whatever room the piston leaves, so it
/// visibly packs together when compressed. The rod shows once the piston
/// moves in (the chamber clips it, like the source's `overflow-hidden`).
class _PistonPainter extends CustomPainter {
  _PistonPainter(this.clock, this.travel)
    : super(repaint: Listenable.merge([clock, travel]));

  final ValueNotifier<double> clock;
  final Animation<double> travel;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final top = travel.value * _kPistonTravel;
    final head = Rect.fromLTWH(0, top, w, _kPistonHeight);

    // Gas: 9 x 4 slots, 35 used.
    const columns = 9;
    const rows = 4;
    final room = Rect.fromLTRB(8, head.bottom + 4, w - 8, size.height - 4);
    final seconds = clock.value;
    final gas = Paint()..color = _kBlue300.withValues(alpha: 0.75);
    for (var i = 0; i < _kGasParticles; i++) {
      final column = i % columns;
      final row = i ~/ columns;
      final seed = i * 2.399;
      final jiggle =
          Offset(
            math.sin(seconds * 3 + seed),
            math.cos(seconds * 2.6 + seed * 1.7),
          ) *
          1.5;
      canvas.drawCircle(
        Offset(
              room.left + (column + 0.5) / columns * room.width,
              room.top + (row + 0.5) / rows * room.height,
            ) +
            jiggle,
        4.5,
        gas,
      );
    }

    // Rod.
    final rod = Rect.fromLTWH(w / 2 - 16, top - 80, 32, 80);
    canvas.drawRect(rod, Paint()..color = _rt_Tw.slate400);
    canvas.drawRect(
      rod,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _rt_Tw.slate500,
    );
    // Head.
    canvas.drawRect(
      head,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_rt_Tw.slate400, _rt_Tw.slate600],
        ).createShader(head),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, head.bottom - 4, w, 4),
      Paint()..color = _rt_Tw.slate800,
    );
  }

  @override
  bool shouldRepaint(_PistonPainter old) =>
      old.clock != clock || old.travel != travel;
}

/// A striped hot-air balloon with ropes and a basket.
class _BalloonPainter extends CustomPainter {
  const _BalloonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final envelope = Path()
      ..moveTo(w * 0.32, h * 0.7)
      ..cubicTo(-w * 0.06, h * 0.48, -w * 0.02, 0, w * 0.5, 0)
      ..cubicTo(w * 1.02, 0, w * 1.06, h * 0.48, w * 0.68, h * 0.7)
      ..close();
    canvas.drawShadow(envelope, Colors.black, 3, false);

    canvas.save();
    canvas.clipPath(envelope);
    canvas.drawRect(Offset.zero & size, Paint()..color = _rt_Tw.red500);
    final middle = Offset(w / 2, h * 0.36);
    canvas.drawOval(
      Rect.fromCenter(center: middle, width: w * 0.62, height: h * 0.95),
      Paint()..color = _rt_Tw.yellow400,
    );
    canvas.drawOval(
      Rect.fromCenter(center: middle, width: w * 0.24, height: h * 0.95),
      Paint()..color = _rt_Tw.red500,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.6),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.2),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();

    final rope = Paint()
      ..color = _kWoodDark
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(w * 0.34, h * 0.69),
      Offset(w * 0.39, h * 0.84),
      rope,
    );
    canvas.drawLine(
      Offset(w * 0.66, h * 0.69),
      Offset(w * 0.61, h * 0.84),
      rope,
    );
    final basket = RRect.fromLTRBR(
      w * 0.36,
      h * 0.84,
      w * 0.64,
      h,
      const Radius.circular(2),
    );
    canvas.drawRRect(basket, Paint()..color = _kWood);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, h * 0.84, w * 0.28, h * 0.04),
      Paint()..color = _kWoodDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A yellow submarine facing right, with tower, periscope and portholes.
class _SubmarinePainter extends CustomPainter {
  const _SubmarinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _rt_Tw.amber700;

    // Periscope.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.52, h * 0.2)
        ..lineTo(w * 0.52, h * 0.03)
        ..lineTo(w * 0.62, h * 0.03),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = _rt_Tw.slate600,
    );
    // Propeller.
    final tail = Path()
      ..moveTo(w * 0.12, h * 0.55)
      ..lineTo(0, h * 0.42)
      ..lineTo(0, h * 0.95)
      ..lineTo(w * 0.12, h * 0.82)
      ..close();
    canvas.drawPath(tail, Paint()..color = _rt_Tw.amber600);

    final tower = RRect.fromLTRBR(
      w * 0.4,
      h * 0.18,
      w * 0.66,
      h * 0.5,
      const Radius.circular(4),
    );
    final hull = RRect.fromLTRBR(
      w * 0.08,
      h * 0.42,
      w * 0.98,
      h * 0.96,
      Radius.circular(h * 0.27),
    );
    final body = Path()
      ..addRRect(tower)
      ..addRRect(hull);
    canvas.drawShadow(body, Colors.black, 3, false);
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_rt_Tw.yellow400, _rt_Tw.amber500],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(tower, fill);
    canvas.drawRRect(tower, outline);
    canvas.drawRRect(hull, fill);
    canvas.drawRRect(hull, outline);

    for (final x in const [0.32, 0.53, 0.74]) {
      final centre = Offset(w * x, h * 0.68);
      canvas.drawCircle(centre, h * 0.085, Paint()..color = _kSky200);
      canvas.drawCircle(
        centre,
        h * 0.085,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _rt_Tw.slate600,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Soft clouds in the balloon's sky (the source's faint cloud texture).
class _CloudsPainter extends CustomPainter {
  const _CloudsPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: dark ? 0.12 : 0.6);
    for (final (x, y) in const [(0.28, 0.14), (0.74, 0.34), (0.34, 0.58)]) {
      final centre = Offset(size.width * x, size.height * y);
      canvas.drawCircle(centre.translate(-12, 3), 9, paint);
      canvas.drawCircle(centre, 13, paint);
      canvas.drawCircle(centre.translate(13, 3), 9, paint);
    }
  }

  @override
  bool shouldRepaint(_CloudsPainter old) => old.dark != dark;
}

/// `border-t border-dashed border-white/30`: the sea's surface line.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawDashedPath(
      canvas,
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.4),
      5,
      4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawDashedPath(
  Canvas canvas,
  Path path,
  Paint paint,
  double dash,
  double gap,
) {
  final period = dash + gap;
  for (final metric in path.computeMetrics()) {
    var start = 0.0;
    while (start < metric.length) {
      final to = math.min(metric.length, start + dash);
      canvas.drawPath(metric.extractPath(start, to), paint);
      start += period;
    }
  }
}

class _ConfettiPiece {
  _ConfettiPiece.random(math.Random random)
    : angle = (-90 + (random.nextDouble() - 0.5) * 80) * math.pi / 180,
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

/// One burst like `confetti({particleCount: 150, spread: 80, origin: {y: 0.6}})`.
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
    // Velocity decays exponentially (air drag), gravity pulls down.
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
