// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 8.4: Pure in Science & Testing Air
// Converted from
// Cl8S-Ch8-A1-Pure_vs_Scientific_Pure_and_Air_Tests_Simulation_Strategy.html
// (Tailwind DOM + canvas + canvas-confetti -> Flutter widgets +
// CustomPainters; drag-and-drop via Draggable / DragTarget with the source's
// tap-to-select fallback).
//
// Two scenarios chosen from the sidebar. 1: Everyday Pure vs Scientific Pure
// -- sort seven products by whether they are sold as "pure", then inspect each
// one in a particle viewer and sort it as a pure substance (one type of
// particle) or a mixture. 2: Testing Air -- prepare clear lime water (add
// quick lime, stir, filter), leave it open until CO2 turns it milky, trap dust
// on black paper at three locations and study it with a magnifier, then
// classify CO2 and dust. Observation log, current-task HUD, step tabs, labels
// / pan / zoom tools, every source string (EN/HI; the source's TE block is
// dropped like every other page) and confetti are ported. Fixes: Common Salt
// has its own card (the source reused the cube labelled "SUGAR") and every
// card shows its name; filtering leaves clear lime water in the beaker (the
// source emptied it); tabs past the furthest step reached are locked (the
// source's led into dead ends); and a step summary moves on however it is
// closed.

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
// Copied from the source's `i18n` block (EN + HI; TE dropped). Keys marked
// "added" had no translation in the source. Log rows and messages that the
// source glued together from word fragments are whole templates here, so the
// Hindi reads naturally.
final _tx = _rt_Tx({
  'en': {
    'title': 'Pure in Science & Testing Air',
    'subtitle':
        'Class 8: Nature of matter, classifying it into elements, compounds, and mixtures',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Daily Pure • Scientific Pure • Lime Water • Dust',
    'tabGuide': 'Lab Guide',
    'selectScenario': 'Select Scenario',
    'missionObjective': 'Mission Objective',
    'explorationSteps': 'Exploration Steps',
    'exploration': 'Exploration',
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
    'continue': 'Continue',
    'nextScenario': 'Next Scenario',
    'restartLab': 'Restart Lab',
    'ok': 'OK',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'items': {
      'milk': 'Packaged Pure Milk',
      'ghee': 'Pure Ghee',
      'juice': 'Fresh Fruit Juice',
      'sugar': 'Sugar',
      'bakingSoda': 'Baking Soda',
      'soil': 'Soil',
      'salt': 'Common Salt',
    },
    'dailyTitle': 'Sort items by whether they are called "Pure" in daily life',
    'dailyHint': 'Tap an item, then tap the correct bin!',
    'binDailyPure': 'Marketed as "Pure"',
    'binDailyNotPure': 'Not Marketed as "Pure"',
    'scienceTitle': 'Sort items by their Scientific Composition',
    'scienceHint':
        'Tap an item, then tap the Lens to inspect. Finally, tap a bin.',
    'viewerHint': 'Tap item then tap here to inspect',
    'binPureSubstance': 'Pure Substance',
    'binPureSubstanceSub': '(1 type of particle)',
    'binMixture': 'Mixture',
    'binMixtureSub': '(Multiple types of particles)',
    'safetyTitle': 'Safety Warning',
    'safetyText':
        'Quick lime (Calcium Oxide) reaction is vigorous and produces heat. This step should be done under teacher supervision.',
    'calciumOxide': 'Calcium Oxide',
    'tapToAdd': 'Tap to add',
    'waterBeaker': 'Water Beaker',
    'clearLimeWater': 'Clear Lime Water',
    'stir': 'Stir',
    'filter': 'Filter',
    'exposeTitle': 'Leave Lime Water Exposed to Air',
    'exposeButton': 'Expose to Air (Speed up time)',
    'equation': 'CO₂ (gas) + Ca(OH)₂ (aq) → CaCO₃ (white ppt) + H₂O (l)',
    'dustTitle': 'Test Air for Suspended Particles',
    'locations': {
      'classroom': 'Classroom (Indoor)',
      'garden': 'Garden (Outdoor)',
      'roadside': 'Roadside (Heavy Traffic)',
    },
    'leaveTwoHours': 'Leave for 2 Hours',
    'cleanPaper': 'Clean Black Paper',
    'paperHint': 'Touch/Hover over the black paper to inspect closely.',
    'classifyTitle': 'Classify Air Components Based on Your Tests',
    'classifyHint': 'Tap a label below, then tap the correct bin!',
    'binGas': 'Gas Present in Air',
    'binSolid': 'Suspended Solid Pollutant',
    'airLabels': {'co2': 'Carbon Dioxide', 'dust': 'Dust Particles'},
    'pure': 'Pure',
    'notPure': 'Not Pure',
    'pureSubstance': 'Pure Substance',
    'mixture': 'Mixture',
    'gas': 'Gas',
    'solidPollutant': 'Solid Pollutant',
    // Observation log.
    'logSorted': 'Sorted {item}',
    'logClassifiedAs': 'Classified {bin}',
    'logIncorrectSorting': 'Incorrect Sorting',
    'logNotHere': '{item} does not belong here',
    'logInspected': 'Inspected {item}',
    'logObserved': 'Observed {n} type(s) of particles.',
    'logIncorrectScience': 'Incorrect Scientific Sorting',
    'logCheckParticles': 'Check the particle types again!',
    'logAddedCaO': 'Added Calcium Oxide',
    'logPowderSettles': 'Powder settles in water.',
    'logStirred': 'Stirred Solution',
    'logSuspension': 'Suspension formed (Lime water).',
    'logFiltered': 'Filtered Solution',
    'logClearObtained': 'Clear Lime Water obtained.',
    'logExposed': 'Exposed to Air',
    'logTurnedMilky': 'Lime water turned milky (CaCO3 formed).',
    'logTestedDust': 'Tested Air for Dust',
    'logDustResult': 'Location: {location}. Particles settled on paper.',
    'logClassifiedLabel': 'Classified {label}',
    'logIdentified': 'Correctly identified as {kind}',
    'logIncorrectClassification': 'Incorrect Classification',
    'logThinkState': 'Think about the state of matter.',
    // Popups.
    'errDaily':
        'Incorrect. {item} does not belong here based on daily meaning.',
    'errInspect':
        'Inspect the item in the particle viewer first to see its composition!',
    'errScience':
        'Incorrect Scientific Sorting. Check the particle types again!',
    'errClassify': 'Incorrect Classification. Think about the state of matter.',
    'dustHint':
        'Hover your mouse/finger over the black paper to inspect the dust particles closely.',
    // Teacher board answers.
    'ansSorted': '{n}/{total} items sorted',
    'ansClassified': '{n}/{total} classified',
    'ansLime': 'Lime water prepared',
    'ansCo2': 'CO2 Detected',
    'ansDust': 'Dust particles collected',
    'scenarios': {
      '1': {
        'title': '1. Everyday Pure vs Scientific Pure',
        'objective': 'Compare consumer use of "pure" with scientific purity.',
        'tabs': ['1. Daily Meaning', '2. Scientific Meaning'],
        'hud': [
          "Drag items into bins based on their everyday meaning of 'Pure'.",
          'Drag items into the Particle Viewer to inspect, then sort scientifically.',
        ],
        'steps': [
          {
            'concept': 'Daily Meaning',
            'action':
                'Drag products to classify them based on their everyday label.',
            'observation': 'Items called pure may not be scientifically pure.',
          },
          {
            'concept': 'Scientific Meaning',
            'action':
                'Inspect particles, then classify as pure substance or mixture.',
            'observation':
                'Pure substances have 1 type of particle. Mixtures have multiple.',
          },
        ],
      },
      '2': {
        'title': '2. Testing Air',
        'objective': 'Test air for carbon dioxide and suspended particles.',
        'tabs': [
          '1. Prep Lime Water',
          '2. CO2 Test',
          '3. Dust Trap',
          '4. Classify',
        ],
        'hud': [
          'Prepare clear lime water safely.',
          'Expose lime water to air to test for CO2.',
          'Place black paper in different locations to test for dust.',
          'Drag labels to classify the components found in air.',
        ],
        'steps': [
          {
            'concept': 'Preparation',
            'action': 'Add CaO, stir, and filter.',
            'observation': 'Clear lime water is obtained.',
          },
          {
            'concept': 'CO2 Test',
            'action': 'Expose lime water to air.',
            'observation': 'Lime water turns milky due to CO2.',
          },
          {
            'concept': 'Dust Trap',
            'action': 'Expose black paper.',
            'observation': 'Suspended solid particles settle on paper.',
          },
          {
            'concept': 'Classification',
            'action': 'Classify CO2 and dust.',
            'observation': 'Air contains gases and suspended solid pollutants.',
          },
        ],
      },
    },
    'summary': {
      'daily':
          "In daily life, we call things 'pure' if they are not adulterated (e.g., pure milk, pure ghee). But in science, 'pure' has a very different meaning!",
      'science':
          "Scientifically, a pure substance contains only ONE type of particle. Even 'Pure Milk' is a mixture of water, fat, and proteins!",
      'lime': "You have prepared clear Lime Water. Now let's test it with air.",
      'co2':
          'The lime water turns milky because Carbon Dioxide in the air reacts with it to form white Calcium Carbonate. This proves CO2 is in the air.',
      'dust':
          'Dust particles suspended in the air settle on surfaces over time. This proves that air contains suspended solid pollutants.',
      'air':
          'Air is a mixture of gases (like Oxygen and Carbon Dioxide) and can contain suspended solid pollutants (like dust).',
    },
  },
  'hi': {
    'title': 'विज्ञान में शुद्ध और वायु परीक्षण',
    'subtitle':
        'कक्षा 8: पदार्थ की प्रकृति, इसे तत्वों, यौगिकों और मिश्रणों में वर्गीकृत करना',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'दैनिक शुद्ध • वैज्ञानिक शुद्ध • चूने का पानी • धूल', // added
    'tabGuide': 'लैब गाइड', // added
    'selectScenario': 'परिदृश्य चुनें',
    'missionObjective': 'मिशन का उद्देश्य',
    'explorationSteps': 'अन्वेषण के चरण', // added
    'exploration': 'अन्वेषण',
    'focus': 'फोकस',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'currentTask': 'वर्तमान कार्य',
    'obsLog': 'अवलोकन लॉग',
    'clear': 'साफ करें',
    'result': 'परिणाम',
    'noObs': 'अभी तक कोई अवलोकन नहीं।',
    'success': 'सफलता!',
    'keyTakeaway': 'मुख्य निष्कर्ष',
    'continue': 'आगे बढ़ें',
    'nextScenario': 'अगला परिदृश्य', // added
    'restartLab': 'प्रयोगशाला को पुनरारंभ करें',
    'ok': 'ठीक है', // added
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
    'items': {
      'milk': 'पैकेज्ड शुद्ध दूध',
      'ghee': 'शुद्ध घी',
      'juice': 'ताज़ा फलों का रस',
      'sugar': 'चीनी',
      'bakingSoda': 'बेकिंग सोडा',
      'soil': 'मिट्टी',
      'salt': 'सामान्य नमक',
    },
    'dailyTitle':
        'वस्तुओं को इस आधार पर छाँटें कि क्या उन्हें दैनिक जीवन में "शुद्ध" कहा जाता है',
    'dailyHint': 'एक वस्तु पर टैप करें, फिर सही डिब्बे पर टैप करें!',
    'binDailyPure': '"शुद्ध" के रूप में बेचा गया',
    'binDailyNotPure': '"शुद्ध" के रूप में नहीं बेचा गया',
    'scienceTitle': 'वस्तुओं को उनकी वैज्ञानिक संरचना के आधार पर छाँटें',
    'scienceHint':
        'एक वस्तु पर टैप करें, फिर निरीक्षण के लिए लेंस पर टैप करें। अंत में, एक डिब्बे पर टैप करें।', // added
    'viewerHint': 'निरीक्षण करने के लिए वस्तु पर टैप करें फिर यहाँ टैप करें',
    'binPureSubstance': 'शुद्ध पदार्थ',
    'binPureSubstanceSub': '(1 प्रकार का कण)',
    'binMixture': 'मिश्रण',
    'binMixtureSub': '(कई प्रकार के कण)',
    'safetyTitle': 'सुरक्षा चेतावनी',
    'safetyText':
        'बिना बुझे चूने (कैल्शियम ऑक्साइड) की प्रतिक्रिया जोरदार होती है और गर्मी पैदा करती है। यह कदम शिक्षक की देखरेख में किया जाना चाहिए।',
    'calciumOxide': 'कैल्शियम ऑक्साइड',
    'tapToAdd': 'डालने के लिए टैप करें', // added
    'waterBeaker': 'पानी का बीकर',
    'clearLimeWater': 'साफ चूने का पानी', // added
    'stir': 'हिलाएं',
    'filter': 'छानें',
    'exposeTitle': 'चूने के पानी को हवा में खुला छोड़ दें',
    'exposeButton': 'हवा में खुला छोड़ें (समय तेज करें)',
    'equation': 'CO₂ (गैस) + Ca(OH)₂ (aq) → CaCO₃ (सफेद अवक्षेप) + H₂O (l)',
    'dustTitle': 'हवा में निलंबित कणों का परीक्षण करें',
    'locations': {
      'classroom': 'कक्षा (इनडोर)',
      'garden': 'बगीचा (आउटडोर)',
      'roadside': 'सड़क के किनारे (भारी यातायात)',
    },
    'leaveTwoHours': '2 घंटे के लिए छोड़ दें',
    'cleanPaper': 'साफ काला कागज',
    'paperHint': 'बारीकी से निरीक्षण करने के लिए काले कागज पर टच/होवर करें।',
    'classifyTitle': 'अपने परीक्षणों के आधार पर वायु घटकों को वर्गीकृत करें',
    'classifyHint': 'नीचे एक लेबल पर टैप करें, फिर सही डिब्बे पर टैप करें!',
    'binGas': 'हवा में मौजूद गैस',
    'binSolid': 'निलंबित ठोस प्रदूषक',
    'airLabels': {'co2': 'कार्बन डाइऑक्साइड', 'dust': 'धूल के कण'},
    'pure': 'शुद्ध',
    'notPure': 'शुद्ध नहीं',
    'pureSubstance': 'शुद्ध पदार्थ',
    'mixture': 'मिश्रण',
    'gas': 'गैस',
    'solidPollutant': 'ठोस प्रदूषक',
    'logSorted': '{item} छांटा गया',
    'logClassifiedAs': '{bin} के रूप में वर्गीकृत',
    'logIncorrectSorting': 'गलत छंटाई',
    'logNotHere': '{item} यहाँ नहीं आता है',
    'logInspected': '{item} का निरीक्षण किया गया',
    'logObserved': '{n} प्रकार के कण देखे गए।',
    'logIncorrectScience': 'गलत वैज्ञानिक छंटाई',
    'logCheckParticles': 'कण प्रकारों को फिर से जांचें!',
    'logAddedCaO': 'कैल्शियम ऑक्साइड मिलाया',
    'logPowderSettles': 'पाउडर पानी में बस जाता है।',
    'logStirred': 'घोल हिलाया',
    'logSuspension': 'निलंबन बना (चूने का पानी)।',
    'logFiltered': 'छना हुआ घोल',
    'logClearObtained': 'साफ चूने का पानी प्राप्त हुआ।',
    'logExposed': 'हवा में खुला छोड़ा गया',
    'logTurnedMilky': 'चूने का पानी दूधिया हो गया (CaCO3 बना)।',
    'logTestedDust': 'धूल के लिए हवा का परीक्षण किया',
    'logDustResult': 'स्थान: {location}। कण कागज पर बस गए।',
    'logClassifiedLabel': '{label} वर्गीकृत',
    'logIdentified': 'सही ढंग से {kind} के रूप में पहचाना गया',
    'logIncorrectClassification': 'गलत वर्गीकरण',
    'logThinkState': 'पदार्थ की अवस्था के बारे में सोचें।',
    'errDaily': 'गलत। दैनिक अर्थ के आधार पर {item} यहाँ नहीं आता है।', // added
    'errInspect':
        'इसकी संरचना देखने के लिए पहले वस्तु का पार्टिकल व्यूअर में निरीक्षण करें!', // added
    'errScience': 'गलत वैज्ञानिक छंटाई। कण प्रकारों को फिर से जांचें!',
    'errClassify': 'गलत वर्गीकरण। पदार्थ की अवस्था के बारे में सोचें।',
    'dustHint':
        'धूल के कणों का बारीकी से निरीक्षण करने के लिए अपने माउस/उंगली को काले कागज पर घुमाएँ।', // added
    'ansSorted': '{n}/{total} वस्तुएं छांटी गईं',
    'ansClassified': '{n}/{total} वर्गीकृत',
    'ansLime': 'चूने का पानी तैयार',
    'ansCo2': 'CO2 का पता चला',
    'ansDust': 'धूल के कण एकत्र हुए',
    'scenarios': {
      '1': {
        'title': '1. रोज़मर्रा का शुद्ध बनाम वैज्ञानिक शुद्ध',
        'objective':
            'वैज्ञानिक शुद्धता के साथ "शुद्ध" के उपभोक्ता उपयोग की तुलना करें।',
        'tabs': ['1. दैनिक अर्थ', '2. वैज्ञानिक अर्थ'],
        'hud': [
          "'शुद्ध' के उनके दैनिक अर्थ के आधार पर वस्तुओं को डिब्बे में खींचें।",
          'निरीक्षण करने के लिए वस्तुओं को पार्टिकल व्यूअर में खींचें, फिर वैज्ञानिक रूप से छाँटें।',
        ],
        'steps': [
          {
            'concept': 'दैनिक अर्थ',
            'action':
                'उत्पादों को उनके रोज़मर्रा के लेबल के आधार पर वर्गीकृत करने के लिए खींचें।',
            'observation':
                'जिन वस्तुओं को शुद्ध कहा जाता है वे वैज्ञानिक रूप से शुद्ध नहीं हो सकती हैं।',
          },
          {
            'concept': 'वैज्ञानिक अर्थ',
            'action':
                'कणों का निरीक्षण करें, फिर शुद्ध पदार्थ या मिश्रण के रूप में वर्गीकृत करें।',
            'observation':
                'शुद्ध पदार्थों में 1 प्रकार का कण होता है। मिश्रण में कई होते हैं।',
          },
        ],
      },
      '2': {
        'title': '2. वायु परीक्षण',
        'objective':
            'कार्बन डाइऑक्साइड और निलंबित कणों के लिए हवा का परीक्षण करें।',
        'tabs': [
          '1. चूने का पानी तैयार करें',
          '2. CO2 परीक्षण',
          '3. धूल का जाल',
          '4. वर्गीकृत करें',
        ],
        'hud': [
          'सुरक्षित रूप से साफ चूने का पानी तैयार करें।',
          'CO2 के परीक्षण के लिए चूने के पानी को हवा में खुला छोड़ दें।',
          'धूल का परीक्षण करने के लिए अलग-अलग स्थानों पर काला कागज रखें।',
          'हवा में पाए जाने वाले घटकों को वर्गीकृत करने के लिए लेबल खींचें।',
        ],
        'steps': [
          {
            'concept': 'तैयारी',
            'action': 'CaO डालें, हिलाएं, और छानें।',
            'observation': 'साफ चूने का पानी प्राप्त होता है।',
          },
          {
            'concept': 'CO2 परीक्षण', // added
            'action': 'चूने के पानी को हवा में खुला छोड़ दें।',
            'observation': 'CO2 के कारण चूने का पानी दूधिया हो जाता है।',
          },
          {
            'concept': 'धूल का जाल', // added
            'action': 'काला कागज खुला छोड़ें।',
            'observation': 'निलंबित ठोस कण कागज पर बस जाते हैं।',
          },
          {
            'concept': 'वर्गीकरण',
            'action': 'CO2 और धूल को वर्गीकृत करें।',
            'observation': 'हवा में गैसें और निलंबित ठोस प्रदूषक होते हैं।',
          },
        ],
      },
    },
    'summary': {
      'daily':
          "दैनिक जीवन में, हम उन चीजों को 'शुद्ध' कहते हैं यदि उनमें मिलावट नहीं होती है (उदा., शुद्ध दूध, शुद्ध घी)। लेकिन विज्ञान में, 'शुद्ध' का एक बहुत अलग अर्थ है!",
      'science':
          "वैज्ञानिक रूप से, एक शुद्ध पदार्थ में केवल एक प्रकार का कण होता है। यहां तक कि 'शुद्ध दूध' भी पानी, वसा और प्रोटीन का मिश्रण है!",
      'lime':
          'आपने साफ चूने का पानी तैयार कर लिया है। अब इसका हवा के साथ परीक्षण करें।',
      'co2':
          'चूने का पानी दूधिया हो जाता है क्योंकि हवा में मौजूद कार्बन डाइऑक्साइड इसके साथ प्रतिक्रिया करके सफेद कैल्शियम कार्बोनेट बनाती है। यह साबित करता है कि हवा में CO2 है।',
      'dust':
          'हवा में निलंबित धूल के कण समय के साथ सतहों पर बस जाते हैं। यह साबित करता है कि हवा में निलंबित ठोस प्रदूषक होते हैं।',
      'air':
          'हवा गैसों (जैसे ऑक्सीजन और कार्बन डाइऑक्साइड) का मिश्रण है और इसमें निलंबित ठोस प्रदूषक (जैसे धूल) हो सकते हैं।',
    },
  },
});

/// `_tx.s(key)` with `{name}` placeholders filled from [args].
String _fmt(String key, Map<String, Object> args) {
  var text = _tx.s(key);
  args.forEach((name, value) => text = text.replaceAll('{$name}', '$value'));
  return text;
}

// ------------------------------------------------------------- constants ----

/// Content widths below this stack the particle viewer above the bins and
/// shrink the item cards.
const double _kNarrowWidth = 700;

/// Canvases shorter than this (phone landscape) get a tighter top inset.
const double _kShortHeight = 500;

const double _kMaxContentWidth = 1000;

/// The source's `zoomInteractive` limits and step.
const double _kZoomMin = 0.5;
const double _kZoomMax = 3;
const double _kZoomStep = 0.1;

/// Particles drawn in the viewer (`for (let i = 0; i < 40; i++)`).
const int _kViewerParticles = 40;

/// `#dust-paper` design width (`max-w-[24rem]`): speck radii are in these
/// pixels and scale with the paper.
const double _kPaperWidth = 384;

/// The magnifier shows a third of its own width, three times larger.
const double _kLensZoom = 3;

/// The source's default `confetti()` palette.
const List<Color> _kConfettiColors = [
  _rt_Tw.blue500,
  _rt_Tw.emerald500,
  _rt_Tw.amber500,
  _rt_Tw.pink500,
  _rt_Tw.violet500,
];

const Color _kBlue300 = Color(0xFF93C5FD);
const Color _kPurple800 = Color(0xFF6B21A8);
const Color _kOrange300 = Color(0xFFFDBA74);
const Color _kSky100 = Color(0xFFE0F2FE);
const Color _kSky200 = Color(0xFFBAE6FD);
const Color _kSky300 = Color(0xFF7DD3FC);
const Color _kSky700 = Color(0xFF0369A1);

// ------------------------------------------------------------------ model ----

enum _Shape { circle, square, triangle, diamond }

/// One kind of particle in the viewer. Each kind also gets its own shape, so
/// two similar colours (ghee's yellows) still read as two types.
class _ParticleKind {
  const _ParticleKind(this.color, this.shape);

  final Color color;
  final _Shape shape;
}

/// The source's `items` (`dailyPure`, `sciPure`, `particles` colours).
enum _Item {
  milk(
    dailyPure: true,
    sciPure: false,
    particles: [
      _ParticleKind(Color(0xFFFFFFFF), _Shape.circle),
      _ParticleKind(Color(0xFFFEF08A), _Shape.square),
    ],
  ),
  ghee(
    dailyPure: true,
    sciPure: false,
    particles: [
      _ParticleKind(Color(0xFFFEF08A), _Shape.circle),
      _ParticleKind(Color(0xFFFBBF24), _Shape.diamond),
    ],
  ),
  juice(
    dailyPure: true,
    sciPure: false,
    particles: [
      _ParticleKind(Color(0xFFF97316), _Shape.circle),
      _ParticleKind(Color(0xFFEF4444), _Shape.square),
      _ParticleKind(Color(0xFFFFFFFF), _Shape.triangle),
    ],
  ),
  sugar(
    dailyPure: true,
    sciPure: true,
    particles: [_ParticleKind(Color(0xFFFFFFFF), _Shape.square)],
  ),
  bakingSoda(
    dailyPure: true,
    sciPure: true,
    particles: [_ParticleKind(Color(0xFFFFFFFF), _Shape.circle)],
  ),
  soil(
    dailyPure: false,
    sciPure: false,
    particles: [
      _ParticleKind(Color(0xFF78350F), _Shape.circle),
      _ParticleKind(Color(0xFF52525B), _Shape.square),
      _ParticleKind(Color(0xFF000000), _Shape.triangle),
      _ParticleKind(Color(0xFFF59E0B), _Shape.diamond),
    ],
  ),
  salt(
    dailyPure: true,
    sciPure: true,
    particles: [_ParticleKind(Color(0xFFE2E8F0), _Shape.square)],
  );

  const _Item({
    required this.dailyPure,
    required this.sciPure,
    required this.particles,
  });

  /// Sold / described as "pure" in everyday life.
  final bool dailyPure;

  /// A pure substance in the scientific sense (one type of particle).
  final bool sciPure;
  final List<_ParticleKind> particles;

  String get label => _tx.s('items.$name');
}

/// The six drop zones.
enum _Bin { dailyPure, dailyNotPure, sciPure, sciMixture, gas, solid }

/// Scenario 2's `#sc2-labels`.
enum _AirLabel {
  co2(isGas: true),
  dust(isGas: false);

  const _AirLabel({required this.isGas});

  final bool isGas;

  String get label => _tx.s('airLabels.$name');
}

/// `#location-select` with the source's speck counts.
enum _Location {
  classroom(50),
  garden(200),
  roadside(600);

  const _Location(this.specks);

  final int specks;

  String get label => _tx.s('locations.$name');
}

/// One jiggling particle in the viewer.
class _ViewerParticle {
  const _ViewerParticle({
    required this.kind,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.period,
    required this.phase,
  });

  /// 40 particles inside the lens circle. The first ones take one of each
  /// kind, so every type in the item is visible (the source picked colours
  /// at random and could miss one).
  static List<_ViewerParticle> generate(_Item item, math.Random random) {
    final kinds = item.particles.length;
    return List.generate(_kViewerParticles, (i) {
      final radius = 0.38 * math.sqrt(random.nextDouble());
      final angle = random.nextDouble() * math.pi * 2;
      return _ViewerParticle(
        kind: i < kinds ? i : random.nextInt(kinds),
        x: 0.5 + radius * math.cos(angle),
        y: 0.5 + radius * math.sin(angle),
        dx: random.nextDouble() * 6 - 3,
        dy: random.nextDouble() * 6 - 3,
        period: 1 + random.nextDouble(),
        phase: random.nextDouble(),
      );
    });
  }

  final int kind;

  /// Centre as a fraction of the viewer.
  final double x;
  final double y;

  /// Jiggle offset in px (`translate(±3px, ±3px)`).
  final double dx;
  final double dy;

  /// Seconds per jiggle (`duration: 1000 + random * 1000`).
  final double period;
  final double phase;
}

/// One dust speck on the black paper (the source's `ctx.arc` dots).
class _DustSpeck {
  const _DustSpeck(this.x, this.y, this.radius, this.color);

  static List<_DustSpeck> generate(int count, math.Random random) {
    int channel() => 100 + random.nextInt(100);
    return List.generate(
      count,
      (_) => _DustSpeck(
        random.nextDouble(),
        random.nextDouble(),
        random.nextDouble() * 2 + 0.5,
        Color.fromRGBO(
          channel(),
          channel(),
          channel(),
          random.nextDouble() * 0.5 + 0.3,
        ),
      ),
    );
  }

  /// Position as a fraction of the paper.
  final double x;
  final double y;

  /// Radius in [_kPaperWidth] pixels.
  final double radius;
  final Color color;
}

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result);

  final String Function() action;
  final String Function() result;
}

// ------------------------------------------------------------------- page ----

class Cl8Ch08A4PureInScienceTestingAirPage extends StatefulWidget {
  const Cl8Ch08A4PureInScienceTestingAirPage({super.key});

  @override
  State<Cl8Ch08A4PureInScienceTestingAirPage> createState() =>
      _Cl8Ch08A4PureInScienceTestingAirPageState();
}

class _Cl8Ch08A4PureInScienceTestingAirPageState
    extends State<Cl8Ch08A4PureInScienceTestingAirPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();
  final ScrollController _workspaceScroll = ScrollController();

  /// Seconds since the page opened; drives the viewer jiggle and the CO₂
  /// molecules drifting into the dish.
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _clock.value = elapsed.inMicroseconds / 1e6,
  );

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  /// Stirring the quick lime (the source's 1 s `animate-pulse`).
  late final AnimationController _stirring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  /// Filtering the suspension.
  late final AnimationController _filtering = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  /// The dish turning milky (`transition: background-color 3s`).
  late final AnimationController _milkiness = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  final List<Timer> _timers = [];

  // Shared (source `State`).
  int _scenario = 1;

  /// The step on screen (tab / HUD / active sidebar tile).
  int _step = 1;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  double _zoom = 1;
  Offset _pan = Offset.zero;

  // Scenario 1 (source `sc1DailySorted`, `sc1SciSorted`, `currentInspectItem`,
  // `activeSelection`).
  /// Items sorted by everyday meaning: true = "Marketed as Pure".
  final Map<_Item, bool> _dailyBins = {};

  /// Items sorted scientifically: true = pure substance.
  final Map<_Item, bool> _scienceBins = {};
  _Item? _selectedItem;
  _Item? _inspected;
  List<_ViewerParticle> _viewerParticles = const [];
  _Bin? _flashBin;

  // Scenario 2 (source `sc2PrepStep`, `dustTestCompleted`, `dustInspected`,
  // `sc2ClassifyCount`).
  /// 0 water, 1 quick lime added, 2 stirred, 3 filtered.
  int _prepStage = 0;
  bool _exposeStarted = false;
  bool _co2Detected = false;
  _Location _location = _Location.classroom;
  List<_DustSpeck> _dust = const [];
  bool _dustHintShown = false;

  /// Magnifier centre as a fraction of the paper, while it is shown.
  Offset? _lens;
  bool _dustInspected = false;
  final Set<_AirLabel> _classified = {};
  _AirLabel? _selectedLabel;

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
    _stirring.dispose();
    _filtering.dispose();
    _milkiness.dispose();
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
  int _stepCountOf(int scenario) => scenario == 1 ? 2 : 4;

  int get _stepCount => _stepCountOf(_scenario);

  /// Whether the work of [step] in [scenario] is finished.
  bool _isStepDone(int scenario, int step) {
    return switch ((scenario, step)) {
      (1, 1) => _dailyBins.length == _Item.values.length,
      (1, 2) => _scienceBins.length == _Item.values.length,
      (2, 1) => _prepStage >= 3,
      (2, 2) => _co2Detected,
      (2, 3) => _dustInspected,
      (2, 4) => _classified.length == _AirLabel.values.length,
      _ => false,
    };
  }

  /// The furthest step a student may open: the first unfinished one. Later
  /// steps stay locked (the source's tabs led into dead ends, e.g. the
  /// scientific sort with an empty item pool).
  int _reachedStep(int scenario) {
    final count = _stepCountOf(scenario);
    var step = 1;
    while (step < count && _isStepDone(scenario, step)) {
      step++;
    }
    return step;
  }

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

  void _scrollToTop() {
    if (_workspaceScroll.hasClients) _workspaceScroll.jumpTo(0);
  }

  /// Drops the pending tap-to-place selection and any bin flash.
  void _clearTransient() {
    _selectedItem = null;
    _selectedLabel = null;
    _flashBin = null;
    _lens = null;
  }

  /// The source's `changeScenario`. Like the source it keeps each scenario's
  /// progress; it opens the furthest step reached.
  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() {
      _scenario = scenario;
      _step = _reachedStep(scenario);
      _toggledTiles.clear();
      _clearTransient();
      _zoom = 1;
      _pan = Offset.zero;
    });
    _scrollToTop();
  }

  /// The source's `setSc1Step` / `setSc2Step` (tab buttons).
  void _selectStep(int step) {
    if (step > _reachedStep(_scenario) || step == _step) return;
    _rt_playSfx(_rt_Sfx.click);
    _goToStep(step);
  }

  void _goToStep(int step) {
    setState(() {
      _step = step;
      _toggledTiles.clear();
      _clearTransient();
    });
    _scrollToTop();
  }

  /// The source's `resetApp` (minus the page reload; the shell owns the
  /// shutter).
  void _restart() {
    _cancelTimers();
    _stirring.value = 0;
    _filtering.value = 0;
    _milkiness.value = 0;
    setState(() {
      _scenario = 1;
      _step = 1;
      _toggledTiles.clear();
      _clearTransient();
      _showLabels = true;
      _panMode = false;
      _zoom = 1;
      _pan = Offset.zero;
      _dailyBins.clear();
      _scienceBins.clear();
      _inspected = null;
      _viewerParticles = const [];
      _prepStage = 0;
      _exposeStarted = false;
      _co2Detected = false;
      _location = _Location.classroom;
      _dust = const [];
      _dustHintShown = false;
      _dustInspected = false;
      _classified.clear();
      _log.clear();
    });
    _scrollToTop();
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  void _togglePanMode() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _panMode = !_panMode);
  }

  /// The source's `zoomInteractive` (the whole interactive layer scales).
  void _zoomBy(double delta) =>
      setState(() => _zoom = (_zoom + delta).clamp(_kZoomMin, _kZoomMax));

  void _resetView() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

  /// Flashes [bin] red after a wrong drop.
  void _flash(_Bin bin) {
    setState(() => _flashBin = bin);
    _after(700, () {
      if (_flashBin == bin) setState(() => _flashBin = null);
    });
  }

  // --------------------------------------------------------------- dialogs --
  /// The source's `showMsg` mini popup.
  Future<void> _showMessage(String text, {bool error = false}) async {
    _rt_playSfx(error ? _rt_Sfx.wrong : _rt_Sfx.click);
    await _rt_showShellPopup(
      context,
      title: text,
      icon: error ? Icons.warning_amber_rounded : Icons.info_outline,
      color: error ? _rt_Tw.red500 : _rt_Tw.blue500,
      buttonLabel: _tx.s('ok'),
    );
  }

  /// A mid-scenario `showSummary` with Continue. However it is closed, the
  /// lab moves on to [nextStep] (in the source, closing it with ✕ skipped
  /// the callback and stranded the lab).
  void _showStepSummary(String summaryKey, {required int nextStep}) {
    final scenario = _scenario;
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _rt_Tw.green600,
      buttonLabel: _tx.s('continue'),
      body: _SummaryBody(
        heading: _tx.s('keyTakeaway'),
        text: _tx.s('summary.$summaryKey'),
      ),
      onClose: () {
        if (mounted && _scenario == scenario && _step < nextStep) {
          _goToStep(nextStep);
        }
      },
    );
    _launchConfetti();
  }

  /// The summary that ends a scenario: Next Scenario, or Restart Lab after
  /// the last one.
  void _showScenarioSummary(String summaryKey) {
    final last = _scenario == 2;
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _rt_Tw.green600,
      buttonLabel: _tx.s(last ? 'restartLab' : 'nextScenario'),
      body: _SummaryBody(
        heading: _tx.s('keyTakeaway'),
        text: _tx.s('summary.$summaryKey'),
      ),
      onConfirm: () {
        _rt_playSfx(_rt_Sfx.click);
        if (last) {
          _restart();
        } else {
          _changeScenario(2);
        }
      },
    );
    _launchConfetti();
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

  // ------------------------------------------------------ scenario 1 logic --
  /// The source's `selectPart` for an item card.
  void _selectItem(_Item item) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selectedItem = _selectedItem == item ? null : item);
  }

  /// The source's `handleZoneTap` on a sorting bin.
  void _tapItemBin(_Bin bin) {
    final item = _selectedItem;
    if (item == null) return;
    setState(() => _selectedItem = null);
    _dropItem(item, bin);
  }

  void _dropItem(_Item item, _Bin bin) {
    switch (bin) {
      case _Bin.dailyPure:
      case _Bin.dailyNotPure:
        _sortDaily(item, bin);
      case _Bin.sciPure:
      case _Bin.sciMixture:
        _sortScience(item, bin);
      case _Bin.gas:
      case _Bin.solid:
        break;
    }
  }

  /// The source's `processSc1DailyDrop`.
  void _sortDaily(_Item item, _Bin bin) {
    if (_scenario != 1 || _dailyBins.containsKey(item)) return;
    final pure = bin == _Bin.dailyPure;
    if (item.dailyPure != pure) {
      _flash(bin);
      setState(
        () => _pushLog(
          () => _tx.s('logIncorrectSorting'),
          () => _fmt('logNotHere', {'item': item.label}),
        ),
      );
      _showMessage(_fmt('errDaily', {'item': item.label}), error: true);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _dailyBins[item] = pure;
      _pushLog(
        () => _fmt('logSorted', {'item': item.label}),
        () =>
            _fmt('logClassifiedAs', {'bin': _tx.s(pure ? 'pure' : 'notPure')}),
      );
    });
    if (_isStepDone(1, 1)) {
      _rt_playSfx(_rt_Sfx.success);
      _after(1000, () => _showStepSummary('daily', nextStep: 2));
    }
  }

  /// Tapping the lens inspects the selected item and keeps it selected, so
  /// the next tap on a bin sorts it.
  void _tapViewer() {
    final item = _selectedItem;
    if (item != null) _inspect(item);
  }

  /// The source's `processViewerDrop`.
  void _inspect(_Item item) {
    if (_scenario != 1 || _step != 2 || _scienceBins.containsKey(item)) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _inspected = item;
      _viewerParticles = _ViewerParticle.generate(item, _random);
      _pushLog(
        () => _fmt('logInspected', {'item': item.label}),
        () => _fmt('logObserved', {'n': item.particles.length}),
      );
    });
  }

  /// The source's `processSc1ScienceDrop`.
  void _sortScience(_Item item, _Bin bin) {
    if (_scenario != 1 || _scienceBins.containsKey(item)) return;
    if (_inspected != item) {
      _flash(bin);
      _showMessage(_tx.s('errInspect'), error: true);
      return;
    }
    final pure = bin == _Bin.sciPure;
    if (item.sciPure != pure) {
      _flash(bin);
      setState(
        () => _pushLog(
          () => _tx.s('logIncorrectScience'),
          () => _tx.s('logCheckParticles'),
        ),
      );
      _showMessage(_tx.s('errScience'), error: true);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _scienceBins[item] = pure;
      _inspected = null;
      _viewerParticles = const [];
      _pushLog(
        () => _fmt('logSorted', {'item': item.label}),
        () => _fmt('logClassifiedAs', {
          'bin': _tx.s(pure ? 'pureSubstance' : 'mixture'),
        }),
      );
    });
    if (_isStepDone(1, 2)) {
      _rt_playSfx(_rt_Sfx.success);
      _after(1000, () {
        if (_scenario == 1) _showScenarioSummary('science');
      });
    }
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// The source's `addCaO`.
  void _addQuickLime() {
    if (_scenario != 2 || _prepStage != 0) return;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _prepStage = 1;
      _pushLog(() => _tx.s('logAddedCaO'), () => _tx.s('logPowderSettles'));
    });
  }

  /// The source's `stirSolution`: the powder disperses into a cloudy
  /// suspension over the 1 s stir.
  void _stir() {
    if (_prepStage != 1) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _prepStage = 2;
      _pushLog(() => _tx.s('logStirred'), () => _tx.s('logSuspension'));
    });
    _stirring.forward(from: 0).then((_) {
      if (mounted) setState(() {});
    });
  }

  /// The source's `filterSolution`.
  void _filter() {
    if (_prepStage != 2 || _stirring.isAnimating) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _prepStage = 3;
      _pushLog(() => _tx.s('logFiltered'), () => _tx.s('logClearObtained'));
    });
    _filtering.forward(from: 0);
    _after(2200, () {
      if (_scenario != 2) return;
      _rt_playSfx(_rt_Sfx.success);
      _showStepSummary('lime', nextStep: 2);
    });
  }

  /// The source's `exposeLimeWater`: 3 s to turn milky, then the equation,
  /// then the summary 2 s later.
  void _expose() {
    if (_exposeStarted || _prepStage < 3) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() => _exposeStarted = true);
    _milkiness.forward(from: 0).then((_) {
      if (!mounted || !_exposeStarted) return;
      setState(() {
        _co2Detected = true;
        _pushLog(() => _tx.s('logExposed'), () => _tx.s('logTurnedMilky'));
      });
      _after(2000, () {
        if (_scenario != 2) return;
        _rt_playSfx(_rt_Sfx.success);
        _showStepSummary('co2', nextStep: 3);
      });
    });
  }

  void _pickLocation(_Location location) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _location = location);
  }

  /// The source's `runDustTest`. It can be repeated to compare locations;
  /// the hover hint pops up after the first test only.
  void _runDustTest() {
    if (_scenario != 2) return;
    _rt_playSfx(_rt_Sfx.magic);
    final location = _location;
    setState(() {
      _dust = _DustSpeck.generate(location.specks, _random);
      _lens = null;
      _pushLog(
        () => _tx.s('logTestedDust'),
        () => _fmt('logDustResult', {'location': location.label}),
      );
    });
    if (!_dustHintShown) {
      _dustHintShown = true;
      _after(500, () => _showMessage(_tx.s('dustHint')));
    }
  }

  /// The source's `moveMagnifier`. The first look finishes the step.
  void _moveLens(Offset local, Size paper) {
    if (_dust.isEmpty) return;
    final lens = Offset(
      (local.dx / paper.width).clamp(0.0, 1.0),
      (local.dy / paper.height).clamp(0.0, 1.0),
    );
    final first = !_dustInspected;
    setState(() {
      _lens = lens;
      _dustInspected = true;
    });
    if (first) {
      _after(1500, () {
        if (_scenario != 2) return;
        _rt_playSfx(_rt_Sfx.success);
        _showStepSummary('dust', nextStep: 4);
      });
    }
  }

  void _hideLens() {
    if (_lens != null) setState(() => _lens = null);
  }

  void _selectLabel(_AirLabel label) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selectedLabel = _selectedLabel == label ? null : label);
  }

  void _tapAirBin(_Bin bin) {
    final label = _selectedLabel;
    if (label == null) return;
    setState(() => _selectedLabel = null);
    _classify(label, bin);
  }

  /// The source's `processSc2ClassifyDrop`.
  void _classify(_AirLabel label, _Bin bin) {
    if (_scenario != 2 || _classified.contains(label)) return;
    final gas = bin == _Bin.gas;
    if (label.isGas != gas) {
      _flash(bin);
      setState(
        () => _pushLog(
          () => _tx.s('logIncorrectClassification'),
          () => _tx.s('logThinkState'),
        ),
      );
      _showMessage(_tx.s('errClassify'), error: true);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _classified.add(label);
      _pushLog(
        () => _fmt('logClassifiedLabel', {'label': label.label}),
        () => _fmt('logIdentified', {
          'kind': _tx.s(gas ? 'gas' : 'solidPollutant'),
        }),
      );
    });
    if (_isStepDone(2, 4)) {
      _rt_playSfx(_rt_Sfx.success);
      _after(1000, () {
        if (_scenario == 2) _showScenarioSummary('air');
      });
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
          onZoomIn: () => _zoomBy(_kZoomStep),
          onZoomOut: () => _zoomBy(-_kZoomStep),
          onResetView: _resetView,
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
  /// The source's `#teacher-board`.
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
                  title: '${_tx.s('exploration')} $i',
                  focusLabel: _tx.s('focus'),
                  focus: _tx.s('scenarios.$_scenario.steps.${i - 1}.concept'),
                  actionLabel: _tx.s('action'),
                  action: _tx.s('scenarios.$_scenario.steps.${i - 1}.action'),
                  observationLabel: _tx.s('observation'),
                  observation: _tx.s(
                    'scenarios.$_scenario.steps.${i - 1}.observation',
                  ),
                  answer: _isStepDone(_scenario, i) ? _answer(i) : null,
                  status: i == _step
                      ? _TileStatus.active
                      : (_isStepDone(_scenario, i)
                            ? _TileStatus.done
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

  /// The green answer line a finished step shows in the source's board.
  String _answer(int step) {
    final total = _Item.values.length;
    return switch ((_scenario, step)) {
      (1, 1) => _fmt('ansSorted', {'n': _dailyBins.length, 'total': total}),
      (1, _) => _fmt('ansClassified', {
        'n': _scienceBins.length,
        'total': total,
      }),
      (2, 1) => _tx.s('ansLime'),
      (2, 2) => _tx.s('ansCo2'),
      (2, 3) => _tx.s('ansDust'),
      _ => _fmt('ansClassified', {
        'n': _classified.length,
        'total': _AirLabel.values.length,
      }),
    };
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
              _tx.s('scenarios.$_scenario.hud.${_step - 1}'),
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

  /// The source's draggable `#observation-table`, collapsible here.
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
  /// The source's `#interactive-ui-layer`: step tabs over one view per step,
  /// zoomed and panned as a whole like the source's transform layer.
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight < _kShortHeight;
        final compactLog = MediaQuery.sizeOf(context).width < 900;
        // Clear the HUD (top), the toolbar strip (right) and the log
        // (bottom).
        final topInset = short ? 84.0 : 100.0;
        final width = math.min(
          _kMaxContentWidth,
          math.max(0.0, constraints.maxWidth - 12 - 60),
        );
        final narrow = width < _kNarrowWidth;
        final content = Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..translateByDouble(_pan.dx, _pan.dy, 0, 1)
            ..scaleByDouble(_zoom, _zoom, 1, 1),
          child: Center(
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  _stepTabs(narrow: narrow),
                  SizedBox(height: short ? 8 : 14),
                  _stepView(width, narrow: narrow, short: short),
                ],
              ),
            ),
          ),
        );
        return GestureDetector(
          onPanUpdate: _panMode
              ? (details) => setState(() => _pan += details.delta)
              : null,
          child: SingleChildScrollView(
            key: const ValueKey('workspace'),
            controller: _workspaceScroll,
            physics: _panMode ? const NeverScrollableScrollPhysics() : null,
            padding: EdgeInsets.fromLTRB(
              12,
              topInset,
              60,
              compactLog ? 64 : 170,
            ),
            child: content,
          ),
        );
      },
    );
  }

  Widget _stepView(double width, {required bool narrow, required bool short}) {
    return switch ((_scenario, _step)) {
      (1, 1) => _dailyView(narrow: narrow),
      (1, _) => _scienceView(narrow: narrow),
      (2, 1) => _prepView(narrow: narrow),
      (2, 2) => _exposeView(narrow: narrow),
      (2, 3) => _dustView(width, narrow: narrow),
      _ => _classifyView(narrow: narrow),
    };
  }

  /// The source's `#nav-sc1-*` / `#nav-sc2-*` buttons, locked past the
  /// furthest step reached.
  Widget _stepTabs({required bool narrow}) {
    final reached = _reachedStep(_scenario);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: narrow ? 5 : 8,
      runSpacing: 6,
      children: [
        for (var i = 1; i <= _stepCount; i++)
          _StepTab(
            key: ValueKey('tab-$_scenario-$i'),
            label: _tx.s('scenarios.$_scenario.tabs.${i - 1}'),
            active: i == _step,
            done: _isStepDone(_scenario, i),
            locked: i > reached,
            compact: narrow,
            onTap: () => _selectStep(i),
          ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.text,
      ),
    );
  }

  /// The source's blue "Tap an item, then …" strip.
  Widget _hintBox(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app, size: 14, color: _rt_Tw.blue500),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fades the item names with the labels tool.
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

  /// Small grey caption under an apparatus.
  Widget _caption(String text, {Key? key}) {
    return Text(
      text,
      key: key,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.textMuted,
      ),
    );
  }

  // -------------------------------------------------------- scenario 1 UI --
  /// `#sc1-step1`: everyday "pure" bins over the item pool.
  Widget _dailyView({required bool narrow}) {
    return Column(
      children: [
        _sectionTitle(_tx.s('dailyTitle')),
        const SizedBox(height: 8),
        _hintBox(_tx.s('dailyHint')),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _itemBin(_Bin.dailyPure, narrow: narrow)),
              SizedBox(width: narrow ? 10 : 24),
              Expanded(child: _itemBin(_Bin.dailyNotPure, narrow: narrow)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _itemPool([
          for (final item in _Item.values)
            if (!_dailyBins.containsKey(item)) item,
        ], narrow: narrow),
      ],
    );
  }

  /// `#sc1-step2`: the particle viewer and the scientific bins.
  Widget _scienceView({required bool narrow}) {
    final pool = [
      for (final item in _Item.values)
        if (!_scienceBins.containsKey(item)) item,
    ];
    // The lens sits between the bins on every width, so on a phone the
    // bins stay on screen next to it.
    final gap = narrow ? 8.0 : 18.0;
    return Column(
      children: [
        _sectionTitle(_tx.s('scienceTitle')),
        const SizedBox(height: 8),
        _hintBox(_tx.s('scienceHint')),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _itemBin(_Bin.sciPure, narrow: narrow)),
              SizedBox(width: gap),
              Center(child: _viewer(narrow ? 100 : 150)),
              SizedBox(width: gap),
              Expanded(child: _itemBin(_Bin.sciMixture, narrow: narrow)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _itemPool(pool, narrow: narrow),
      ],
    );
  }

  /// `#sc1-pool-1` / `#sc1-pool-2`.
  Widget _itemPool(List<_Item> items, {required bool narrow}) {
    return Container(
      key: const ValueKey('item-pool'),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: narrow ? 96 : 124),
      padding: EdgeInsets.all(narrow ? 8 : 14),
      decoration: BoxDecoration(
        color: _rt_Tw.slate800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.slate700),
      ),
      child: items.isEmpty
          ? const Center(
              child: Icon(Icons.check_circle, size: 32, color: _rt_Tw.green500),
            )
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: narrow ? 8 : 12,
              runSpacing: 10,
              children: [
                for (final item in items) _itemCard(item, compact: narrow),
              ],
            ),
    );
  }

  /// One `.item-3d-wrapper` card: tap to select or drag onto a zone.
  Widget _itemCard(_Item item, {required bool compact}) {
    final inspected = _scenario == 1 && _step == 2 && _inspected == item;
    final face = _ItemCardFace(
      item: item,
      compact: compact,
      selected: _selectedItem == item,
      inspected: inspected,
      showLabel: _showLabels,
    );
    return Draggable<_Item>(
      data: item,
      onDragStarted: () {
        _rt_playSfx(_rt_Sfx.pop);
        setState(() => _selectedItem = null);
      },
      feedback: Material(
        type: MaterialType.transparency,
        child: _ItemCardFace(
          item: item,
          compact: compact,
          selected: false,
          inspected: false,
          showLabel: _showLabels,
          lifted: true,
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: face),
      child: GestureDetector(
        key: ValueKey('item-${item.name}'),
        onTap: () => _selectItem(item),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
      ),
    );
  }

  ({String title, String? subtitle, Color accent}) _binStyle(_Bin bin) {
    return switch (bin) {
      _Bin.dailyPure => (
        title: _tx.s('binDailyPure'),
        subtitle: null,
        accent: _rt_Tw.blue500,
      ),
      _Bin.dailyNotPure => (
        title: _tx.s('binDailyNotPure'),
        subtitle: null,
        accent: _rt_Tw.orange500,
      ),
      _Bin.sciPure => (
        title: _tx.s('binPureSubstance'),
        subtitle: _tx.s('binPureSubstanceSub'),
        accent: _rt_Tw.green500,
      ),
      _Bin.sciMixture => (
        title: _tx.s('binMixture'),
        subtitle: _tx.s('binMixtureSub'),
        accent: _rt_Tw.red500,
      ),
      _Bin.gas => (
        title: _tx.s('binGas'),
        subtitle: null,
        accent: _rt_Tw.blue500,
      ),
      _Bin.solid => (
        title: _tx.s('binSolid'),
        subtitle: null,
        accent: _rt_Tw.orange500,
      ),
    };
  }

  /// A scenario 1 `.drop-zone` bin holding its sorted item chips.
  Widget _itemBin(_Bin bin, {required bool narrow}) {
    final daily = bin == _Bin.dailyPure || bin == _Bin.dailyNotPure;
    final pure = bin == _Bin.dailyPure || bin == _Bin.sciPure;
    final sorted = daily ? _dailyBins : _scienceBins;
    return DragTarget<_Item>(
      onWillAcceptWithDetails: (details) => !sorted.containsKey(details.data),
      onAcceptWithDetails: (details) => _dropItem(details.data, bin),
      builder: (context, candidates, _) => GestureDetector(
        key: ValueKey('bin-${bin.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _tapItemBin(bin),
        child: _binFrame(
          bin,
          hovering: candidates.isNotEmpty,
          armed: _selectedItem != null,
          compact: narrow,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in sorted.entries)
                if (entry.value == pure)
                  _ItemChip(
                    key: ValueKey('sorted-${bin.name}-${entry.key.name}'),
                    item: entry.key,
                    showLabel: _showLabels,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// The visual of every bin: title, optional subtitle and a dark well
  /// ([compact] on phones, where height is short).
  Widget _binFrame(
    _Bin bin, {
    required bool hovering,
    required bool armed,
    required Widget child,
    bool compact = false,
  }) {
    final style = _binStyle(bin);
    final flashing = _flashBin == bin;
    final border = flashing
        ? _rt_Tw.red500
        : (hovering
              ? _rt_Tw.blue400
              : (armed ? _rt_Tw.blue500 : style.accent.withValues(alpha: 0.7)));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(compact ? 7 : 10),
      decoration: BoxDecoration(
        color: flashing
            ? _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500)
            : (hovering
                  ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
                  : _rt_Lab.tinted(_rt_Tw.slate50, style.accent)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: hovering || flashing ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            style.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12.5 : 13.5,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.onTinted(style.accent, style.accent),
            ),
          ),
          if (style.subtitle != null)
            Text(
              style.subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: _rt_Lab.textMuted),
            ),
          SizedBox(height: compact ? 5 : 8),
          Expanded(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: compact ? 56 : 76),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// `#particle-viewer`: a round lens of jiggling particles.
  Widget _viewer(double size) {
    final item = _inspected;
    return DragTarget<_Item>(
      onWillAcceptWithDetails: (details) =>
          !_scienceBins.containsKey(details.data),
      onAcceptWithDetails: (details) => _inspect(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        final armed = _selectedItem != null;
        return GestureDetector(
          key: const ValueKey('viewer'),
          behavior: HitTestBehavior.opaque,
          onTap: _tapViewer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _rt_Tw.slate700,
                  border: Border.all(
                    color: hovering
                        ? _rt_Tw.blue400
                        : (armed ? _rt_Tw.blue500 : _rt_Tw.slate500),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (armed || hovering)
                          ? _rt_Tw.blue500.withValues(alpha: 0.45)
                          : _rt_Lab.shadow,
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: item == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              _tx.s('viewerHint'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size < 130 ? 10 : 12,
                                fontWeight: FontWeight.w800,
                                color: _rt_Tw.slate400,
                              ),
                            ),
                          ),
                        )
                      : CustomPaint(
                          key: ValueKey('viewer-${item.name}'),
                          painter: _ViewerPainter(
                            _clock,
                            _viewerParticles,
                            item.particles,
                          ),
                          child: const SizedBox.expand(),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: size + 40,
                child: Text(
                  item?.label ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
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
  /// `#sc2-step1`: safety note, quick lime jar, beaker, Stir / Filter.
  Widget _prepView({required bool narrow}) {
    final scale = narrow ? 0.8 : 1.0;
    return Column(
      children: [
        _safetyWarning(),
        SizedBox(height: narrow ? 12 : 22),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: narrow ? 22 : 48,
          runSpacing: 14,
          children: [
            _quickLimeJar(scale),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 140 * scale,
                  height: 230 * scale,
                  child: CustomPaint(
                    key: const ValueKey('beaker'),
                    painter: _BeakerPainter(
                      stage: _prepStage,
                      stir: _stirring,
                      filter: _filtering,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _caption(
                  _tx.s(_prepStage >= 3 ? 'clearLimeWater' : 'waterBeaker'),
                  key: const ValueKey('beaker-caption'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: SizedBox(
                width: 130,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChunkyButton(
                      key: const ValueKey('btn-stir'),
                      label: _tx.s('stir'),
                      icon: Icons.sync,
                      color: _rt_Tw.blue500,
                      borderColor: _rt_Tw.blue700,
                      onPressed: _prepStage == 1 ? _stir : null,
                    ),
                    const SizedBox(height: 12),
                    _ChunkyButton(
                      key: const ValueKey('btn-filter'),
                      label: _tx.s('filter'),
                      icon: Icons.filter_alt,
                      color: _rt_Tw.blue500,
                      borderColor: _rt_Tw.blue700,
                      onPressed: _prepStage == 2 && !_stirring.isAnimating
                          ? _filter
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The source's red `border-l-4` safety box (the left bar is a separate
  /// strip: a rounded box needs one border colour).
  Widget _safetyWarning() {
    final text = _rt_Lab.onTinted(_rt_Tw.red400, _rt_Tw.red700);
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: _rt_Tw.red500),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: text,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tx.s('safetyTitle'),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tx.s('safetyText'),
                      style: TextStyle(fontSize: 12, color: text, height: 1.35),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The tappable CaO jar (the source's `onclick="addCaO()"`). It glows
  /// until the quick lime has been added.
  Widget _quickLimeJar(double scale) {
    final waiting = _scenario == 2 && _prepStage == 0;
    return GestureDetector(
      key: const ValueKey('cao-jar'),
      behavior: HitTestBehavior.opaque,
      onTap: _addQuickLime,
      child: MouseRegion(
        cursor: waiting ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (waiting)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _tx.s('tapToAdd'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.blue400,
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: waiting ? _rt_Tw.blue500 : Colors.transparent,
                  width: 2,
                ),
                boxShadow: waiting
                    ? [
                        BoxShadow(
                          color: _rt_Tw.blue500.withValues(alpha: 0.35),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: SizedBox(
                width: 64 * scale,
                height: 84 * scale,
                child: CustomPaint(
                  painter: _QuickLimeJarPainter(full: _prepStage == 0),
                ),
              ),
            ),
            const SizedBox(height: 6),
            _caption(_tx.s('calciumOxide')),
          ],
        ),
      ),
    );
  }

  /// `#sc2-step2`: the petri dish of lime water left open to the air.
  Widget _exposeView({required bool narrow}) {
    final scale = narrow ? 0.8 : 1.0;
    return Column(
      children: [
        _sectionTitle(_tx.s('exposeTitle')),
        const SizedBox(height: 10),
        SizedBox(
          width: 300 * scale,
          height: 170 * scale,
          child: CustomPaint(
            key: const ValueKey('petri-dish'),
            painter: _PetriDishPainter(
              milkiness: _milkiness,
              clock: _clock,
              exposing: _exposeStarted && !_co2Detected,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ChunkyButton(
          key: const ValueKey('btn-expose'),
          label: _tx.s('exposeButton'),
          icon: Icons.air,
          color: _rt_Tw.green500,
          borderColor: _rt_Tw.green700,
          onPressed: _exposeStarted ? null : _expose,
        ),
        if (_co2Detected) ...[
          const SizedBox(height: 14),
          Container(
            key: const ValueKey('equation'),
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Lab.borderStrong),
            ),
            child: Text(
              _tx.s('equation'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// `#sc2-step3`: location, the black paper and the magnifier.
  Widget _dustView(double width, {required bool narrow}) {
    final paperWidth = math.min(narrow ? 330.0 : _kPaperWidth, width);
    return Column(
      children: [
        _sectionTitle(_tx.s('dustTitle')),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final location in _Location.values)
              _LocationChip(
                key: ValueKey('loc-${location.name}'),
                label: location.label,
                selected: _location == location,
                onTap: () => _pickLocation(location),
              ),
            _ChunkyButton(
              key: const ValueKey('btn-dust'),
              label: _tx.s('leaveTwoHours'),
              icon: Icons.schedule,
              color: _rt_Tw.purple500,
              borderColor: _kPurple800,
              onPressed: _runDustTest,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _dustPaper(Size(paperWidth, paperWidth * 2 / 3), narrow: narrow),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mouse, size: 14, color: _rt_Lab.textMuted),
            const SizedBox(width: 6),
            Flexible(child: _caption(_tx.s('paperHint'))),
          ],
        ),
      ],
    );
  }

  /// `#dust-paper` with `#magnifier`: follows the mouse, or a finger while
  /// it is down (a claimed vertical drag keeps the workspace from scrolling).
  Widget _dustPaper(Size size, {required bool narrow}) {
    return MouseRegion(
      cursor: _dust.isEmpty
          ? SystemMouseCursors.basic
          : SystemMouseCursors.precise,
      onExit: (_) => _hideLens(),
      child: Listener(
        key: const ValueKey('dust-paper'),
        onPointerHover: (event) => _moveLens(event.localPosition, size),
        onPointerDown: (event) => _moveLens(event.localPosition, size),
        onPointerMove: (event) => _moveLens(event.localPosition, size),
        onPointerUp: (event) {
          if (event.kind != PointerDeviceKind.mouse) _hideLens();
        },
        onPointerCancel: (_) => _hideLens(),
        child: GestureDetector(
          onVerticalDragUpdate: _dust.isEmpty ? null : (_) {},
          onHorizontalDragUpdate: _dust.isEmpty ? null : (_) {},
          child: Container(
            width: size.width,
            height: size.height,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _rt_Tw.slate700, width: 4),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                painter: _DustPaperPainter(
                  dust: _dust,
                  lens: _lens,
                  lensRadius: narrow ? 44 : 56,
                  label: _tx.s('cleanPaper').toUpperCase(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `#sc2-step4`: gas / solid bins and the two labels.
  Widget _classifyView({required bool narrow}) {
    return Column(
      children: [
        _sectionTitle(_tx.s('classifyTitle')),
        const SizedBox(height: 8),
        _hintBox(_tx.s('classifyHint')),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _airBin(_Bin.gas, narrow: narrow)),
                SizedBox(width: narrow ? 10 : 24),
                Expanded(child: _airBin(_Bin.solid, narrow: narrow)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 10,
          children: [
            for (final label in _AirLabel.values)
              if (!_classified.contains(label)) _airLabelCard(label),
          ],
        ),
      ],
    );
  }

  Widget _airBin(_Bin bin, {required bool narrow}) {
    final gas = bin == _Bin.gas;
    return DragTarget<_AirLabel>(
      onWillAcceptWithDetails: (details) => !_classified.contains(details.data),
      onAcceptWithDetails: (details) => _classify(details.data, bin),
      builder: (context, candidates, _) => GestureDetector(
        key: ValueKey('bin-${bin.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _tapAirBin(bin),
        child: _binFrame(
          bin,
          hovering: candidates.isNotEmpty,
          armed: _selectedLabel != null,
          compact: narrow,
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final label in _AirLabel.values)
                  if (_classified.contains(label) && label.isGas == gas)
                    _AirLabelFace(
                      key: ValueKey('sorted-${bin.name}-${label.name}'),
                      label: label,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _airLabelCard(_AirLabel label) {
    final face = _AirLabelFace(label: label, selected: _selectedLabel == label);
    return Draggable<_AirLabel>(
      data: label,
      onDragStarted: () {
        _rt_playSfx(_rt_Sfx.pop);
        setState(() => _selectedLabel = null);
      },
      feedback: Material(
        type: MaterialType.transparency,
        child: _AirLabelFace(label: label, lifted: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: face),
      child: GestureDetector(
        key: ValueKey('label-${label.name}'),
        onTap: () => _selectLabel(label),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
      ),
    );
  }
}

// -------------------------------------------------------------- widgets ----

/// One `#nav-sc*-*` step button.
class _StepTab extends StatelessWidget {
  const _StepTab({
    super.key,
    required this.label,
    required this.active,
    required this.done,
    required this.locked,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool active;
  final bool done;
  final bool locked;
  final VoidCallback onTap;

  /// Tighter, so scenario 2's four tabs fit one row on a phone.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : _rt_Lab.text;
    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: Material(
        color: active ? _rt_Tw.blue600 : _rt_Tw.slate800,
        borderRadius: BorderRadius.circular(8),
        elevation: active ? 3 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: locked || active ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 12,
              vertical: compact ? 6 : 7,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locked || done) ...[
                  Icon(
                    locked ? Icons.lock : Icons.check_circle,
                    size: compact ? 11 : 13,
                    color: locked
                        ? _rt_Lab.textMuted
                        : (active ? Colors.white : _rt_Tw.green500),
                  ),
                  SizedBox(width: compact ? 3 : 5),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 10.5 : 12,
                    fontWeight: FontWeight.w800,
                    color: fg,
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

/// An item card in the pool (or its drag feedback).
class _ItemCardFace extends StatelessWidget {
  const _ItemCardFace({
    required this.item,
    required this.compact,
    required this.selected,
    required this.inspected,
    required this.showLabel,
    this.lifted = false,
  });

  final _Item item;
  final bool compact;
  final bool selected;
  final bool inspected;
  final bool showLabel;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final art = compact ? 44.0 : 56.0;
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: selected || lifted ? 1.06 : 1,
      child: Container(
        width: compact ? 74 : 92,
        height: compact ? 88 : 106,
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
        decoration: BoxDecoration(
          color: _rt_Lab.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _rt_Tw.blue500 : _rt_Lab.borderStrong,
            width: selected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _rt_Tw.blue500.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: lifted ? 0.4 : 0.2),
              blurRadius: selected || lifted ? 18 : 6,
              offset: Offset(0, lifted ? 10 : 3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                SizedBox(
                  width: art,
                  height: art,
                  child: CustomPaint(painter: _ItemPainter(item)),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showLabel ? 1 : 0,
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 9 : 10.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (inspected)
              Positioned(
                top: -4,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: _rt_Tw.blue500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A sorted item shrunk into its bin (the source's `scale(0.8)`).
class _ItemChip extends StatelessWidget {
  const _ItemChip({super.key, required this.item, required this.showLabel});

  final _Item item;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(painter: _ItemPainter(item)),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: showLabel ? 1 : 0,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `#lbl-co2` / `#lbl-dust`.
class _AirLabelFace extends StatelessWidget {
  const _AirLabelFace({
    super.key,
    required this.label,
    this.selected = false,
    this.lifted = false,
  });

  final _AirLabel label;
  final bool selected;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final accent = label.isGas ? _rt_Tw.blue500 : _rt_Tw.orange500;
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: selected || lifted ? 1.06 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: _rt_Lab.tinted(
            label.isGas ? _rt_Tw.blue100 : _rt_Tw.orange100,
            accent,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _rt_Tw.blue400 : accent.withValues(alpha: 0.7),
            width: selected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _rt_Tw.blue500.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: lifted ? 0.4 : 0.2),
              blurRadius: selected || lifted ? 16 : 6,
              offset: Offset(0, lifted ? 8 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label.isGas ? Icons.cloud : Icons.grain,
              size: 16,
              color: _rt_Lab.onTinted(accent, accent),
            ),
            const SizedBox(width: 6),
            // Wraps inside a narrow (phone) bin.
            Flexible(
              child: Text(
                label.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.onTinted(accent, accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One `#location-select` option as a chip.
class _LocationChip extends StatelessWidget {
  const _LocationChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500)
          : _rt_Lab.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _rt_Tw.blue500 : _rt_Lab.borderStrong,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.place,
                size: 14,
                color: selected ? _rt_Tw.blue400 : _rt_Lab.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700)
                      : _rt_Lab.text,
                ),
              ),
            ],
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
    this.icon,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback? onPressed;
  final IconData? icon;

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Flexible(
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
              ],
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

/// One collapsible "Exploration n" card of the source's teacher board.
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
    this.answer,
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

  /// The source's green answer line, once the step is finished.
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final active = status == _TileStatus.active;
    final done = status == _TileStatus.done;
    final accentText = _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600);
    final titleColor = active
        ? accentText
        : (done
              ? _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)
              : _rt_Lab.textMuted);

    final Widget badge = Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? _rt_Tw.blue500
            : (done ? _rt_Tw.green500 : _rt_Lab.overlay),
        border: Border.all(
          color: active
              ? _rt_Tw.blue400
              : (done ? _rt_Tw.green500 : _rt_Tw.slate400),
        ),
      ),
      child: Text(
        done ? '✓' : '$number',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: active || done ? Colors.white : _rt_Lab.text,
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
              : (done
                    ? _rt_Tw.green500.withValues(alpha: 0.5)
                    : _rt_Lab.border),
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
                  if (answer != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _rt_Lab.tintedBorder(_rt_Tw.green500),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: _rt_Lab.onTinted(
                              _rt_Tw.green400,
                              _rt_Tw.green700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              answer!,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _rt_Lab.onTinted(
                                  _rt_Tw.green400,
                                  _rt_Tw.green700,
                                ),
                              ),
                            ),
                          ),
                        ],
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

/// "Key Takeaway" body of the summary popup.
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.heading, required this.text});

  final String heading;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green600);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          heading.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: accent,
          ),
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
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _rt_Lab.text,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- painters ----

/// Centred bold text for packaging labels.
void _paintLabel(
  Canvas canvas,
  String text,
  Offset centre, {
  required double size,
  required Color color,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 0.3,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
  painter.dispose();
}

/// Soft contact shadow under a product.
void _paintShadow(Canvas canvas, Rect rect) {
  canvas.drawOval(
    rect,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
  );
}

/// The source's `.item-*-3d` products, drawn in a 56 × 56 design box. Salt
/// gets its own shaker (the source reused the cube labelled "SUGAR").
class _ItemPainter extends CustomPainter {
  const _ItemPainter(this.item);

  final _Item item;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 56;
    canvas.save();
    canvas.translate(
      (size.width - 56 * scale) / 2,
      (size.height - 56 * scale) / 2,
    );
    canvas.scale(scale);
    switch (item) {
      case _Item.milk:
        _milk(canvas);
      case _Item.ghee:
        _ghee(canvas);
      case _Item.juice:
        _juice(canvas);
      case _Item.sugar:
        _sugar(canvas);
      case _Item.bakingSoda:
        _bakingSoda(canvas);
      case _Item.soil:
        _soil(canvas);
      case _Item.salt:
        _salt(canvas);
    }
    canvas.restore();
  }

  void _milk(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(12, 51, 32, 5));
    const body = Rect.fromLTRB(14, 18, 42, 54);
    canvas.drawRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kSky100, _kSky200],
        ).createShader(body),
    );
    canvas.drawRect(
      const Rect.fromLTWH(36, 18, 6, 36),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );
    canvas.drawPath(
      Path()
        ..moveTo(14, 18)
        ..lineTo(28, 8)
        ..lineTo(42, 18)
        ..close(),
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawRect(
      const Rect.fromLTWH(25, 4, 6, 5),
      Paint()..color = const Color(0xFF0284C7),
    );
    canvas.drawRect(
      const Rect.fromLTWH(14, 18, 28, 5),
      Paint()..color = _rt_Tw.sky500,
    );
    canvas.drawRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _kSky300,
    );
    _paintLabel(
      canvas,
      'MILK',
      const Offset(28, 31),
      size: 7.5,
      color: _kSky700,
    );
    // A milk drop.
    canvas.drawPath(
      Path()
        ..moveTo(28, 37)
        ..quadraticBezierTo(32, 42, 32, 45)
        ..arcToPoint(const Offset(24, 45), radius: const Radius.circular(4))
        ..quadraticBezierTo(24, 42, 28, 37)
        ..close(),
      Paint()..color = _rt_Tw.sky500.withValues(alpha: 0.75),
    );
  }

  void _ghee(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(11, 51, 34, 5));
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 16, 32, 38),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFEF08A), _rt_Tw.yellow400],
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 22, 4, 26),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFCA8A04),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 9, 26, 9),
        const Radius.circular(3),
      ),
      Paint()..color = _rt_Tw.orange600,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 28, 26, 11),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    _paintLabel(
      canvas,
      'GHEE',
      const Offset(28, 33.5),
      size: 7,
      color: const Color(0xFF713F12),
    );
  }

  void _juice(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(13, 51, 30, 5));
    const body = Rect.fromLTRB(15, 14, 41, 54);
    canvas.drawRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rt_Tw.orange100, _kOrange300],
        ).createShader(body),
    );
    canvas.drawRect(
      const Rect.fromLTWH(15, 14, 26, 7),
      Paint()..color = _rt_Tw.orange600,
    );
    canvas.drawRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _rt_Tw.orange500,
    );
    canvas.drawLine(
      const Offset(34, 14),
      const Offset(38, 3),
      Paint()
        ..color = _rt_Tw.red500
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    _paintLabel(
      canvas,
      'JUICE',
      const Offset(28, 29),
      size: 6.5,
      color: _rt_Tw.orange800,
    );
    // An orange slice.
    const centre = Offset(28, 43);
    canvas.drawCircle(centre, 6, Paint()..color = _rt_Tw.orange400);
    canvas.drawCircle(centre, 4.8, Paint()..color = _kOrange300);
    final segment = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 0.6;
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(
        centre,
        centre + Offset(math.cos(angle), math.sin(angle)) * 4.8,
        segment,
      );
    }
  }

  void _sugar(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(11, 47, 34, 6));
    const top = Offset(28, 14);
    const right = Offset(44, 22);
    const front = Offset(28, 30);
    const left = Offset(12, 22);
    const down = Offset(0, 20);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _rt_Tw.slate400;
    final faces = [
      (Path()..addPolygon([top, right, front, left], true), _rt_Tw.slate50),
      (
        Path()..addPolygon([left, front, front + down, left + down], true),
        _rt_Tw.slate200,
      ),
      (
        Path()..addPolygon([front, right, right + down, front + down], true),
        _rt_Tw.slate300,
      ),
    ];
    for (final (path, color) in faces) {
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, edge);
    }
    // Crystal sparkle.
    final sparkle = Paint()..color = Colors.white;
    for (final point in const [
      Offset(20, 21),
      Offset(33, 19),
      Offset(18, 36),
      Offset(37, 38),
    ]) {
      canvas.drawCircle(point, 0.9, sparkle);
    }
    _paintLabel(
      canvas,
      'SUGAR',
      const Offset(20, 38),
      size: 5,
      color: _rt_Tw.slate600,
    );
  }

  void _bakingSoda(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(14, 50, 28, 5));
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(16, 12, 24, 41),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rt_Tw.slate50, _rt_Tw.slate300],
        ).createShader(body.outerRect),
    );
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      const Rect.fromLTWH(16, 40, 24, 13),
      Paint()..color = _rt_Tw.rose500,
    );
    canvas.restore();
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _rt_Tw.slate400,
    );
    _paintLabel(
      canvas,
      'SODA',
      const Offset(28, 25),
      size: 6.5,
      color: const Color(0xFF881337),
    );
    canvas.drawCircle(
      const Offset(28, 33),
      2.6,
      Paint()..color = _rt_Tw.rose500.withValues(alpha: 0.8),
    );
  }

  void _soil(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(5, 48, 46, 6));
    final mound = Path()
      ..moveTo(5, 50)
      ..quadraticBezierTo(10, 24, 28, 22)
      ..quadraticBezierTo(46, 24, 51, 50)
      ..close();
    canvas.drawPath(
      mound,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF92400E), Color(0xFF451A03)],
        ).createShader(const Rect.fromLTWH(5, 22, 46, 28)),
    );
    for (final (centre, radius, color) in const [
      (Offset(18, 42), 2.2, Color(0xFF52525B)),
      (Offset(30, 35), 1.8, Color(0xFFA8A29E)),
      (Offset(38, 45), 2.5, Color(0xFF1C1917)),
      (Offset(24, 47), 1.6, Color(0xFFF59E0B)),
      (Offset(35, 29), 1.4, Color(0xFFF59E0B)),
      (Offset(13, 47), 1.5, Color(0xFFA8A29E)),
      (Offset(43, 40), 1.3, Color(0xFF52525B)),
    ]) {
      canvas.drawCircle(centre, radius, Paint()..color = color);
    }
    // A sprout.
    final leaf = Paint()..color = _rt_Tw.green500;
    canvas.drawLine(
      const Offset(28, 22),
      const Offset(28, 13),
      Paint()
        ..color = _rt_Tw.green600
        ..strokeWidth = 1.6,
    );
    canvas.save();
    canvas.translate(24.5, 13);
    canvas.rotate(-0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 8, height: 4),
      leaf,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(31.5, 14);
    canvas.rotate(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 8, height: 4),
      leaf,
    );
    canvas.restore();
  }

  void _salt(Canvas canvas) {
    _paintShadow(canvas, const Rect.fromLTWH(12, 50, 32, 5));
    final body = Path()
      ..moveTo(17, 22)
      ..lineTo(39, 22)
      ..lineTo(42, 53)
      ..lineTo(14, 53)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            _rt_Tw.slate200.withValues(alpha: 0.9),
          ],
        ).createShader(const Rect.fromLTWH(14, 22, 28, 31)),
    );
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      const Rect.fromLTWH(10, 36, 36, 18),
      Paint()..color = _rt_Tw.slate100,
    );
    final grain = Paint()..color = _rt_Tw.slate300;
    for (var i = 0; i < 14; i++) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(17 + (i * 7) % 22, 39 + (i * 5) % 12),
          width: 1.4,
          height: 1.4,
        ),
        grain,
      );
    }
    canvas.restore();
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _rt_Tw.slate400,
    );
    final cap = RRect.fromRectAndRadius(
      const Rect.fromLTWH(16, 10, 24, 13),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      cap,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_rt_Tw.slate300, _rt_Tw.slate500],
        ).createShader(cap.outerRect),
    );
    final hole = Paint()..color = _rt_Tw.slate700;
    for (final point in const [
      Offset(22, 15),
      Offset(28, 14),
      Offset(34, 15),
    ]) {
      canvas.drawCircle(point, 1.1, hole);
    }
    _paintLabel(
      canvas,
      'SALT',
      const Offset(28, 29.5),
      size: 6.5,
      color: _rt_Tw.slate600,
    );
  }

  @override
  bool shouldRepaint(covariant _ItemPainter oldDelegate) =>
      oldDelegate.item != item;
}

/// Draws one particle of [kind] centred at [centre].
void _paintParticle(
  Canvas canvas,
  _ParticleKind kind,
  Offset centre,
  double radius,
) {
  final fill = Paint()..color = kind.color;
  final outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = kind.color.computeLuminance() > 0.35
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.55);
  final Path path;
  switch (kind.shape) {
    case _Shape.circle:
      canvas.drawCircle(centre, radius, fill);
      canvas.drawCircle(centre, radius, outline);
      return;
    case _Shape.square:
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: centre,
          width: radius * 1.75,
          height: radius * 1.75,
        ),
        Radius.circular(radius * 0.3),
      );
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, outline);
      return;
    case _Shape.triangle:
      path = Path()
        ..moveTo(centre.dx, centre.dy - radius * 1.1)
        ..lineTo(centre.dx + radius, centre.dy + radius * 0.8)
        ..lineTo(centre.dx - radius, centre.dy + radius * 0.8)
        ..close();
    case _Shape.diamond:
      path = Path()
        ..moveTo(centre.dx, centre.dy - radius * 1.15)
        ..lineTo(centre.dx + radius, centre.dy)
        ..lineTo(centre.dx, centre.dy + radius * 1.15)
        ..lineTo(centre.dx - radius, centre.dy)
        ..close();
  }
  canvas.drawPath(path, fill);
  canvas.drawPath(path, outline);
}

/// `#viewer-particles`: 40 particles jiggling in place.
class _ViewerPainter extends CustomPainter {
  _ViewerPainter(this.clock, this.particles, this.kinds)
    : super(repaint: clock);

  final ValueNotifier<double> clock;
  final List<_ViewerParticle> particles;
  final List<_ParticleKind> kinds;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [_rt_Tw.slate600, _rt_Tw.slate800],
        ).createShader(rect),
    );
    final t = clock.value;
    final radius = size.width * 0.055;
    final scale = size.width / 144;
    for (final particle in particles) {
      final wobble = math.sin(
        math.pi * ((t / particle.period + particle.phase) % 1),
      );
      _paintParticle(
        canvas,
        kinds[particle.kind],
        Offset(
          particle.x * size.width + particle.dx * wobble * scale,
          particle.y * size.height + particle.dy * wobble * scale,
        ),
        radius,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ViewerPainter oldDelegate) =>
      oldDelegate.particles != particles || oldDelegate.kinds != kinds;
}

/// The CaO jar, in a 64 × 84 design box.
class _QuickLimeJarPainter extends CustomPainter {
  const _QuickLimeJarPainter({required this.full});

  /// Still holding the scoop that goes into the beaker.
  final bool full;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64);
    _paintShadow(canvas, const Rect.fromLTWH(8, 76, 48, 6));
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 14, 48, 64),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()..color = _rt_Tw.slate300);
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTWH(8, full ? 50 : 60, 48, 30),
      Paint()..color = Colors.white,
    );
    canvas.restore();
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _rt_Tw.slate500,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 6, 40, 10),
        const Radius.circular(3),
      ),
      Paint()..color = _rt_Tw.slate600,
    );
    const label = Rect.fromLTWH(17, 28, 30, 15);
    canvas.drawRect(label, Paint()..color = Colors.white);
    canvas.drawRect(
      label,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _rt_Tw.slate400,
    );
    _paintLabel(canvas, 'CaO', label.center, size: 9, color: _rt_Tw.slate800);
  }

  @override
  bool shouldRepaint(covariant _QuickLimeJarPainter oldDelegate) =>
      oldDelegate.full != full;
}

/// `#beaker` in a 140 × 230 design box: the funnel space on top, the beaker
/// (`rounded-b-3xl`) below. Powder settles, stirring makes a cloudy
/// suspension, filtering leaves the residue on the filter paper and clear
/// lime water below (the source emptied the beaker instead).
class _BeakerPainter extends CustomPainter {
  _BeakerPainter({
    required this.stage,
    required this.stir,
    required this.filter,
  }) : super(repaint: Listenable.merge([stir, filter]));

  final int stage;
  final Animation<double> stir;
  final Animation<double> filter;

  static const Rect _glass = Rect.fromLTWH(6, 66, 128, 160);
  static const Rect _inner = Rect.fromLTWH(10, 70, 120, 152);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 140);
    final stirT = stir.value;
    final filterT = filter.value;
    final powder = switch (stage) {
      1 => 1.0,
      2 => 1 - stirT,
      _ => 0.0,
    };
    final cloudiness = switch (stage) {
      2 => stirT,
      3 => 1 - filterT,
      _ => 0.0,
    };

    final inner = RRect.fromRectAndCorners(
      _inner,
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
      bottomLeft: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
    );
    canvas.drawRRect(
      inner,
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );

    // Liquid: half full (`h-1/2`).
    final surface = _inner.top + _inner.height / 2;
    canvas.save();
    canvas.clipRRect(inner);
    final water = _kBlue300.withValues(alpha: stage >= 3 ? 0.22 : 0.3);
    final cloudy = _rt_Tw.slate200.withValues(alpha: 0.85);
    final liquid = Rect.fromLTRB(
      _inner.left,
      surface,
      _inner.right,
      _inner.bottom,
    );
    canvas.drawRect(
      liquid,
      Paint()..color = Color.lerp(water, cloudy, cloudiness)!,
    );
    canvas.drawLine(
      Offset(_inner.left, surface),
      Offset(_inner.right, surface),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1.5,
    );
    if (powder > 0) {
      canvas.drawRect(
        Rect.fromLTRB(
          _inner.left,
          _inner.bottom - 9,
          _inner.right,
          _inner.bottom,
        ),
        Paint()..color = Colors.white.withValues(alpha: powder),
      );
    }
    if (stirT > 0 && stirT < 1) {
      final centre = Offset(_inner.center.dx, (surface + _inner.bottom) / 2);
      final swirl = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55);
      for (var i = 0; i < 3; i++) {
        final radius = 14.0 + i * 14;
        canvas.drawArc(
          Rect.fromCenter(center: centre, width: radius * 2, height: radius),
          stirT * math.pi * 4 + i * 2.1,
          1.6,
          false,
          swirl,
        );
      }
    }
    canvas.restore();

    // Glass wall (`border-4`), rim and scale marks.
    final glass = RRect.fromRectAndCorners(
      _glass.deflate(2),
      topLeft: const Radius.circular(3),
      topRight: const Radius.circular(3),
      bottomLeft: const Radius.circular(22),
      bottomRight: const Radius.circular(22),
    );
    canvas.drawRRect(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _rt_Tw.blue700,
    );
    final mark = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (var y = 100.0; y <= 190; y += 22) {
      canvas.drawLine(
        Offset(_inner.left + 4, y),
        Offset(_inner.left + 14, y),
        mark,
      );
    }

    // Glass rod while stirring.
    if (stirT > 0 && stirT < 1) {
      final angle = stirT * math.pi * 4;
      canvas.drawLine(
        const Offset(112, 40),
        Offset(70 + 24 * math.cos(angle), 196 + 8 * math.sin(angle)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    if (stage >= 3) _paintFunnel(canvas, filterT, surface);
  }

  void _paintFunnel(Canvas canvas, double t, double surface) {
    final alpha = (t * 5).clamp(0.0, 1.0);
    final cone = Path()
      ..moveTo(30, 8)
      ..lineTo(110, 8)
      ..lineTo(75, 50)
      ..lineTo(65, 50)
      ..close();
    canvas.drawPath(
      cone,
      Paint()..color = Colors.white.withValues(alpha: 0.08 * alpha),
    );
    // Filter paper and the residue it keeps.
    canvas.drawPath(
      Path()
        ..moveTo(36, 11)
        ..lineTo(104, 11)
        ..lineTo(70, 48)
        ..close(),
      Paint()..color = _rt_Tw.slate50.withValues(alpha: 0.85 * alpha),
    );
    final residue = 16 * t;
    canvas.drawPath(
      Path()
        ..moveTo(70, 48)
        ..lineTo(70 - residue * 0.95, 48 - residue)
        ..lineTo(70 + residue * 0.95, 48 - residue)
        ..close(),
      Paint()..color = _rt_Tw.slate400.withValues(alpha: alpha),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _rt_Tw.slate300.withValues(alpha: alpha);
    canvas.drawPath(cone, edge);
    canvas.drawRect(const Rect.fromLTRB(66, 50, 74, 80), edge);
    // Filtrate dripping into the beaker.
    if (t > 0 && t < 1) {
      final drop = Paint()..color = _kBlue300.withValues(alpha: 0.85);
      for (var i = 0; i < 3; i++) {
        final p = (t * 5 + i / 3) % 1;
        canvas.drawCircle(Offset(70, 82 + p * (surface - 84)), 2.2, drop);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BeakerPainter oldDelegate) =>
      oldDelegate.stage != stage;
}

/// The petri dish of lime water in a 300 × 170 design box. While it is
/// exposed, CO₂ molecules drift in and the water turns milky with CaCO₃.
class _PetriDishPainter extends CustomPainter {
  _PetriDishPainter({
    required this.milkiness,
    required this.clock,
    required this.exposing,
  }) : super(repaint: Listenable.merge([milkiness, clock]));

  final Animation<double> milkiness;
  final ValueNotifier<double> clock;
  final bool exposing;

  /// Fixed precipitate specks (fractions of the liquid ellipse).
  static final List<Offset> _specks = () {
    final random = math.Random(7);
    return List.generate(40, (_) {
      final radius = math.sqrt(random.nextDouble()) * 0.9;
      final angle = random.nextDouble() * math.pi * 2;
      return Offset(radius * math.cos(angle), radius * math.sin(angle));
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 300);
    final milk = milkiness.value;
    const centre = Offset(150, 124);
    canvas.drawOval(
      Rect.fromCenter(
        center: centre + const Offset(0, 10),
        width: 240,
        height: 60,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    final dish = Rect.fromCenter(center: centre, width: 256, height: 76);
    canvas.drawOval(
      dish,
      Paint()..color = _rt_Tw.slate800.withValues(alpha: 0.7),
    );
    final liquid = Rect.fromCenter(center: centre, width: 232, height: 60);
    canvas.drawOval(
      liquid,
      Paint()
        ..color = Color.lerp(
          _kBlue300.withValues(alpha: 0.25),
          _rt_Tw.slate50.withValues(alpha: 0.92),
          milk,
        )!,
    );
    if (milk > 0.1) {
      final speck = Paint()..color = Colors.white.withValues(alpha: milk * 0.9);
      for (final point in _specks) {
        canvas.drawCircle(
          centre + Offset(point.dx * 116, point.dy * 30),
          1.6,
          speck,
        );
      }
    }
    canvas.drawArc(
      liquid.deflate(6),
      math.pi * 1.1,
      math.pi * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    canvas.drawOval(
      dish,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _rt_Tw.slate500,
    );

    if (!exposing) return;
    final t = clock.value;
    for (var i = 0; i < 12; i++) {
      final p = (t * (0.35 + 0.05 * (i % 4)) + i * 0.37) % 1;
      final alpha = p < 0.8 ? 1.0 : (1 - p) / 0.2;
      final x = 50 + (i * 53) % 200 + 6 * math.sin(t * 2 + i);
      _paintCo2(canvas, Offset(x, 6 + p * 104), alpha);
    }
  }

  /// A CO₂ molecule: carbon between two oxygens.
  void _paintCo2(Canvas canvas, Offset centre, double alpha) {
    final oxygen = Paint()..color = _rt_Tw.red500.withValues(alpha: alpha);
    canvas.drawCircle(centre - const Offset(5.5, 0), 2.8, oxygen);
    canvas.drawCircle(centre + const Offset(5.5, 0), 2.8, oxygen);
    canvas.drawCircle(
      centre,
      3.4,
      Paint()..color = _rt_Tw.slate400.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(covariant _PetriDishPainter oldDelegate) =>
      oldDelegate.exposing != exposing;
}

/// `#dust-canvas` plus `#magnifier`: specks on black paper and, while the
/// lens is out, the surrounding paper dimmed and the specks under it shown
/// [_kLensZoom] times larger.
class _DustPaperPainter extends CustomPainter {
  const _DustPaperPainter({
    required this.dust,
    required this.lens,
    required this.lensRadius,
    required this.label,
  });

  final List<_DustSpeck> dust;

  /// Lens centre as a fraction of the paper.
  final Offset? lens;
  final double lensRadius;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _rt_Tw.slate900);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: size.width < 360 ? 14 : 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
          color: _rt_Tw.slate600.withValues(alpha: 0.6),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 16);
    painter.paint(
      canvas,
      rect.center - Offset(painter.width / 2, painter.height / 2),
    );
    painter.dispose();

    final unit = size.width / _kPaperWidth;
    _paintDust(canvas, size, unit, Offset.zero, 1);

    final lens = this.lens;
    if (lens == null) return;
    final centre = Offset(lens.dx * size.width, lens.dy * size.height);
    final circle = Rect.fromCircle(center: centre, radius: lensRadius);
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect)
        ..addOval(circle),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(circle));
    canvas.drawRect(circle, Paint()..color = _rt_Tw.slate900);
    canvas.drawRect(
      circle,
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );
    _paintDust(canvas, size, unit, centre, _kLensZoom);
    canvas.restore();
    canvas.drawCircle(
      centre,
      lensRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white,
    );
    canvas.drawCircle(
      centre,
      lensRadius - 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(centre, 2, Paint()..color = _rt_Tw.red500);
  }

  /// Draws the specks scaled by [zoom] about [origin].
  void _paintDust(
    Canvas canvas,
    Size size,
    double unit,
    Offset origin,
    double zoom,
  ) {
    for (final speck in dust) {
      final point = Offset(speck.x * size.width, speck.y * size.height);
      canvas.drawCircle(
        origin + (point - origin) * zoom,
        speck.radius * unit * zoom,
        Paint()..color = speck.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPaperPainter oldDelegate) =>
      oldDelegate.dust != dust ||
      oldDelegate.lens != lens ||
      oldDelegate.lensRadius != lensRadius ||
      oldDelegate.label != label;
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

/// One burst like `confetti({particleCount: 100, spread: 70, origin: {y: 0.6}})`.
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
