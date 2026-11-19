// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 9.4: Solubility of Gases
// Converted from Cl8S-Ch9-A1-Solubility_of_Gases_Simulation_Strategy.html
// (Tailwind DOM + CSS keyframes -> Flutter widgets + CustomPainters,
// zoom/pan via InteractiveViewer).
//
// Two scenarios chosen from the sidebar. 1: Fizzy Drink Pressure Lab --
// observe the CO2 dots dissolved in a sealed soda bottle, pop the cap (the
// pressure gauge drops and the gas escapes as rising bubbles), then open a
// cold and a warm bottle side by side (slow fizz vs fast fizz). 2: Dissolved
// Oxygen and Heating -- raise an aquarium's temperature until the oxygen
// meter falls and the fish is stressed, heat a beaker on a hot plate to watch
// dissolved air bubble out before boiling, then drag "High Pressure" and
// "High Temperature" onto their effect on gas solubility. Observation log,
// current-task HUD, instructions panel, labels / pan toggles, every source
// string (EN/HI; the source's TE block is dropped like every other page) and
// confetti are ported.

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
    'title': 'Gas Solubility Explorer',
    'subtitle':
        'Class 8: THE AMAZING WORLD OF SOLUTES, SOLVENTS, AND SOLUTIONS',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Pressure • Temperature • Dissolved Gases',
    'tabGuide': 'Lab Guide',
    'carbonatedDrink': 'Carbonated Drink (Liquid)',
    'pressureGauge': 'Pressure Gauge',
    'pressureHigh': 'High (Sealed)',
    'pressureLow': 'Low (Open)',
    'capOpen': 'OPEN',
    'instructions': 'Instructions',
    'instructionsText':
        'Observe the dissolved carbon dioxide particles in the sealed bottle.',
    'nextStep': 'Next Step',
    'continueStep2': 'Continue to Step 2',
    'compareTemps': 'Compare Temperatures',
    'coldWater': 'Cold Water',
    'warmWater': 'Warm Water',
    'openBottle': 'Open Bottle',
    'slowFuzz': 'Slow Fuzz',
    'fastFuzz': 'Fast Fuzz & Gas Loss',
    'waterTemp': 'Water Temperature:',
    'dissolvedOxygen': 'Dissolved Oxygen',
    'nextPhase': 'Next Phase',
    'hotPlate': 'HOT PLATE',
    'turnOnHeat': 'Turn On Heat',
    'nextChallenge': 'Next Challenge',
    'matchRules': 'Match the Rules',
    'matchDesc':
        'Drag the condition on the left to its effect on gas solubility on the right.',
    'highPressure': 'High Pressure',
    'highTemp': 'High Temperature',
    'moreGas': 'More Dissolved Gas',
    'lessGas': 'Less Dissolved Gas (Escapes)',
    'selectScenario': 'Select Scenario',
    'missionObjective': 'Mission Objective',
    'explorationSteps': 'Exploration Steps',
    'step': 'Step',
    'focus': 'Focus',
    'action': 'Action',
    'observation': 'Observation',
    'keyTakeaway': 'Key Takeaway',
    'scenarioComplete': 'Scenario Complete!',
    'success': 'Success!',
    'currentTask': 'Current Task',
    'obsLog': 'Observation Log',
    'clear': 'Clear',
    'result': 'Result',
    'noObs': 'No observations yet.',
    'nextScenario': 'Next Scenario',
    'restartLab': 'Restart Lab',
    'logObserveSealed': 'Observe sealed bottle',
    'logObserveSealedRes': 'High pressure, gas particles dissolved.',
    'logOpenCap': 'Open bottle cap',
    'logOpenCapRes': 'Pressure drops, dissolved gas escapes as bubbles.',
    'toastPressure': 'Pressure dropped! Bubbles escaping.',
    'logOpenCold': 'Open cold bottle',
    'logOpenColdRes': 'Gas escapes slowly.',
    'logOpenWarm': 'Open warm bottle',
    'logOpenWarmRes': 'Gas escapes rapidly.',
    'logAquarium': 'Increase temperature to 35°C',
    'logAquariumRes': 'Oxygen level drops significantly, fish stressed.',
    'toastOxygen': 'Oxygen depleted due to high temperature.',
    'logHeat60': 'Water reaches 60°C',
    'logHeat60Res': 'Tiny dissolved air bubbles escape before boiling.',
    'toastHeat': 'Look! Dissolved air escaping before boiling.',
    'logMatchPressure': 'Match: High Pressure',
    'logMatchPressureRes': 'Keeps more gas dissolved.',
    'logMatchTemp': 'Match: High Temperature',
    'logMatchTempRes': 'Reduces gas solubility.',
    'incorrectMatch': 'Incorrect match! Try again.',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'scenarios': {
      '1': {
        'title': 'Scenario 1: Fizzy Drink Pressure Lab',
        'objective':
            'To show how pressure keeps carbon dioxide dissolved and how opening the bottle releases gas.',
        'hud': [
          '',
          'OBSERVE the sealed soda bottle and inspect the particle view.',
          'CLICK the cap to open the bottle and observe the pressure drop.',
          'COMPARE the cold and warm fizzy drink bottles.',
        ],
        'steps': [
          {
            'concept': 'High Pressure',
            'action': 'OBSERVE the sealed bottle.',
            'observation':
                'Many carbon dioxide particles are dissolved in the liquid under high pressure.',
          },
          {
            'concept': 'Pressure Drop',
            'action': 'CLICK to open cap.',
            'observation':
                'Pressure drops, bubbles form rapidly, and carbon dioxide escapes.',
          },
          {
            'concept': 'Temperature Effect',
            'action': 'COMPARE warm and cold bottles.',
            'observation':
                'The warm bottle loses gas faster. Higher temperature reduces gas solubility.',
          },
        ],
        'summaryLead': 'Gas Solubility!',
        'summary':
            'Pressure keeps gases dissolved in liquids. Opening the bottle reduces pressure, letting the gas escape as bubbles. Warmer liquids hold less dissolved gas.',
      },
      '2': {
        'title': 'Scenario 2: Dissolved Oxygen and Heating',
        'objective':
            'To connect dissolved gases in water with aquatic life and heating observations.',
        'hud': [
          '',
          'ADJUST the aquarium temperature slider and watch the oxygen meter.',
          'HEAT the beaker of water and observe the tiny bubbles.',
          'MATCH the cause and effect cards to complete the challenge.',
        ],
        'steps': [
          {
            'concept': 'Aquatic Life',
            'action': 'ADJUST temperature.',
            'observation':
                'As temperature increases, dissolved oxygen decreases, stressing the fish.',
          },
          {
            'concept': 'Heating Water',
            'action': 'CLICK Heat on the hot plate.',
            'observation':
                'Tiny dissolved air bubbles escape before the water reaches boiling point.',
          },
          {
            'concept': 'Conclusion',
            'action': 'DRAG AND DROP the matching cards.',
            'observation':
                'High pressure = More dissolved gas. High temperature = Less dissolved gas.',
          },
        ],
        'summaryLead': 'Temperature Matters!',
        'summary':
            'As liquid temperature rises, gas solubility decreases. This is why warm water holds less oxygen for fish, and why air bubbles appear before water boils.',
      },
    },
  },
  'hi': {
    'title': 'गैस घुलनशीलता अन्वेषक',
    'subtitle': 'कक्षा 8: विलेय, विलायक और विलयन की अद्भुत दुनिया',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'दबाव • तापमान • घुली हुई गैसें', // added
    'tabGuide': 'लैब गाइड', // added
    'carbonatedDrink': 'कार्बोनेटेड पेय (तरल)',
    'pressureGauge': 'दबाव नापने का यंत्र',
    'pressureHigh': 'उच्च (सील)',
    'pressureLow': 'कम (खुला)',
    'capOpen': 'खोलें', // added
    'instructions': 'निर्देश',
    'instructionsText':
        'सीलबंद बोतल में घुले हुए कार्बन डाइऑक्साइड कणों को देखें।', // added
    'nextStep': 'अगला कदम',
    'continueStep2': 'चरण 2 पर जारी रखें',
    'compareTemps': 'तापमान की तुलना करें',
    'coldWater': 'ठंडा पानी',
    'warmWater': 'गर्म पानी',
    'openBottle': 'बोतल खोलें',
    'slowFuzz': 'धीमी फ़िज़',
    'fastFuzz': 'तेज फ़िज़ और गैस का नुकसान',
    'waterTemp': 'पानी का तापमान:',
    'dissolvedOxygen': 'घुलित ऑक्सीजन',
    'nextPhase': 'अगला चरण',
    'hotPlate': 'हॉट प्लेट',
    'turnOnHeat': 'हीट चालू करें',
    'nextChallenge': 'अगली चुनौती',
    'matchRules': 'नियमों का मिलान करें',
    'matchDesc':
        'गैस की घुलनशीलता पर इसके प्रभाव के लिए बाईं ओर की स्थिति को दाईं ओर खींचें।',
    'highPressure': 'उच्च दबाव',
    'highTemp': 'उच्च तापमान',
    'moreGas': 'अधिक घुली हुई गैस',
    'lessGas': 'कम घुली हुई गैस (निकल जाती है)',
    'selectScenario': 'परिदृश्य चुनें',
    'missionObjective': 'मिशन का उद्देश्य',
    'explorationSteps': 'अन्वेषण के चरण',
    'step': 'चरण',
    'focus': 'मुख्य विचार',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'keyTakeaway': 'मुख्य निष्कर्ष',
    'scenarioComplete': 'परिदृश्य पूर्ण!',
    'success': 'सफलता!',
    'currentTask': 'वर्तमान कार्य',
    'obsLog': 'अवलोकन लॉग',
    'clear': 'साफ़ करें',
    'result': 'परिणाम',
    'noObs': 'अभी तक कोई अवलोकन नहीं।',
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'लैब पुनः आरंभ करें',
    'logObserveSealed': 'सीलबंद बोतल देखें',
    'logObserveSealedRes': 'उच्च दबाव, गैस कण घुले हुए हैं।',
    'logOpenCap': 'बोतल का ढक्कन खोलें',
    'logOpenCapRes':
        'दबाव गिरता है, घुली हुई गैस बुलबुले के रूप में निकल जाती है।',
    'toastPressure': 'दबाव गिर गया! बुलबुले निकल रहे हैं।',
    'logOpenCold': 'ठंडी बोतल खोलें',
    'logOpenColdRes': 'गैस धीरे-धीरे निकलती है।',
    'logOpenWarm': 'गर्म बोतल खोलें',
    'logOpenWarmRes': 'गैस तेजी से निकलती है।',
    'logAquarium': 'तापमान 35°C तक बढ़ाएँ',
    'logAquariumRes': 'ऑक्सीजन का स्तर काफी गिर जाता है, मछली तनाव में।',
    'toastOxygen': 'उच्च तापमान के कारण ऑक्सीजन समाप्त हो गई।',
    'logHeat60': 'पानी 60°C तक पहुँचता है',
    'logHeat60Res': 'उबलने से पहले छोटी हवा के बुलबुले निकल जाते हैं।',
    'toastHeat': 'देखो! उबलने से पहले घुली हुई हवा निकल रही है।',
    'logMatchPressure': 'मिलान: उच्च दबाव',
    'logMatchPressureRes': 'अधिक गैस को घुलाए रखता है।',
    'logMatchTemp': 'मिलान: उच्च तापमान',
    'logMatchTempRes': 'गैस की घुलनशीलता को कम करता है।',
    'incorrectMatch': 'गलत मिलान! पुन: प्रयास करें।',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
    'scenarios': {
      '1': {
        'title': 'परिदृश्य 1: फ़िज़ी ड्रिंक दबाव लैब',
        'objective':
            'यह प्रदर्शित करने के लिए कि कैसे दबाव कार्बन डाइऑक्साइड को घुलाए रखता है और बोतल खोलने से गैस कैसे निकलती है।',
        'hud': [
          '',
          'सीलबंद सोडा बोतल को देखें और कणों का निरीक्षण करें।',
          'बोतल खोलने के लिए कैप पर क्लिक करें और दबाव में गिरावट देखें।',
          'ठंडी और गर्म फ़िज़ी ड्रिंक की बोतलों की तुलना करें।',
        ],
        'steps': [
          {
            'concept': 'उच्च दबाव',
            'action': 'सीलबंद बोतल को देखें।',
            'observation':
                'उच्च दबाव के तहत तरल में कई कार्बन डाइऑक्साइड कण घुले होते हैं।',
          },
          {
            'concept': 'दबाव में गिरावट',
            'action': 'कैप खोलने के लिए क्लिक करें।',
            'observation':
                'दबाव गिरता है, बुलबुले तेजी से बनते हैं, और कार्बन डाइऑक्साइड निकल जाती है।',
          },
          {
            'concept': 'तापमान का प्रभाव',
            'action': 'गर्म और ठंडी बोतलों की तुलना करें।',
            'observation':
                'गर्म बोतल तेजी से गैस खोती है। उच्च तापमान गैस की घुलनशीलता को कम कर देता है।',
          },
        ],
        'summaryLead': 'गैस घुलनशीलता!',
        'summary':
            'दबाव गैसों को तरल पदार्थों में घुलाए रखता है। बोतल खोलने से दबाव कम हो जाता है, जिससे गैस बुलबुले के रूप में निकल जाती है। गर्म तरल पदार्थ में कम घुली हुई गैस होती है।',
      },
      '2': {
        'title': 'परिदृश्य 2: घुलित ऑक्सीजन और ताप',
        'objective':
            'जलीय जीवन और ताप संबंधी टिप्पणियों के साथ पानी में घुली हुई गैसों को जोड़ने के लिए।',
        'hud': [
          '',
          'मछलीघर तापमान स्लाइडर को समायोजित करें और ऑक्सीजन मीटर देखें।',
          'पानी के बीकर को गर्म करें और छोटे बुलबुले देखें।',
          'चुनौती को पूरा करने के लिए कारण और प्रभाव कार्ड का मिलान करें।',
        ],
        'steps': [
          {
            'concept': 'जलीय जीवन',
            'action': 'तापमान समायोजित करें।',
            'observation':
                'जैसे-जैसे तापमान बढ़ता है, घुली हुई ऑक्सीजन कम होती जाती है, जिससे मछलियों पर तनाव पड़ता है।',
          },
          {
            'concept': 'पानी गर्म करना',
            'action': 'हॉट प्लेट पर हीट को क्लिक करें।',
            'observation':
                'पानी के क्वथनांक तक पहुंचने से पहले ही घुली हुई हवा के छोटे बुलबुले निकल जाते हैं।',
          },
          {
            'concept': 'निष्कर्ष',
            'action': 'मिलान कार्ड को खींचें और छोड़ें।',
            'observation':
                'उच्च दबाव = अधिक घुली हुई गैस। उच्च तापमान = कम घुली हुई गैस।',
          },
        ],
        'summaryLead': 'तापमान मायने रखता है!',
        'summary':
            'जैसे-जैसे तरल का तापमान बढ़ता है, गैस की घुलनशीलता कम होती जाती है। यही कारण है कि गर्म पानी मछलियों के लिए कम ऑक्सीजन रखता है, और पानी उबलने से पहले हवा के बुलबुले क्यों दिखाई देते हैं।',
      },
    },
  },
});

// ------------------------------------------------------------- constants ----

/// Design sizes of the fixed-size stages (scaled to fit, zoomable).
const Size _kSodaStage = Size(520, 470);
const Size _kCompareStage = Size(520, 350);
const Size _kAquariumStage = Size(500, 300);
const Size _kBeakerStage = Size(460, 300);

/// The main `.soda-bottle` (sm breakpoint size) inside its stage.
const Rect _kBottleRect = Rect.fromLTWH(190, 140, 140, 300);

/// How far a bubble travels in the source's `rise` keyframes.
///
/// Capped at 1.15x the container height when painting: the source's fixed
/// 300 px overshot the small bottles' clipped liquid, so most dots were
/// invisible at any moment and the warm bottle barely looked fizzier.
const double _kRiseDistance = 300;
const double _kRiseHeightFactor = 1.15;

/// Steps per scenario.
const int _kStepCount = 3;

/// Size of the dissolved-oxygen dot pool shown in the aquarium.
const int _kOxygenDots = 24;

/// The source's `confetti({colors: [...]})` palette.
const List<Color> _kConfettiColors = [
  _rt_Tw.blue500,
  _rt_Tw.blue400,
  Colors.white,
];

const Color _kSoda = Color(0xCCB43232); // rgba(180, 50, 50, 0.8)
const Color _kRose600 = Color(0xFFE11D48);
const Color _kRose800 = Color(0xFF9F1239);
const Color _kBlue200 = Color(0xFFBFDBFE);
const Color _kBlue300 = Color(0xFF93C5FD);
const Color _kRed300 = Color(0xFFFCA5A5);
const Color _kRed900 = Color(0xFF7F1D1D);
const Color _kCyan100 = Color(0xFFCFFAFE);

// ------------------------------------------------------------------ model ----

/// One `.particle` dot. Static dots sit still; rising ones replay the source's
/// `rise` keyframes (up 300 px, grow to 1.5x, fade in and out).
class _Bubble {
  const _Bubble({
    required this.x,
    required this.bottom,
    required this.size,
    this.duration,
    this.start = 0,
    this.loop = true,
  });

  /// CSS `left`, as a fraction of the container width.
  final double x;

  /// CSS `bottom`, as a fraction of the container height (may be negative).
  final double bottom;
  final double size;

  /// Seconds per rise; null for a static dot.
  final double? duration;

  /// Clock time (seconds) the rise began.
  final double start;

  /// `infinite` vs a single run.
  final bool loop;

  bool finishedAt(double now) =>
      !loop && duration != null && now - start > duration!;
}

enum _MatchCard { highPressure, highTemp }

enum _MatchZone { more, less }

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result);

  final String Function() action;
  final String Function() result;
}

// ------------------------------------------------------------------- page ----

class Cl8Ch09A4SolubilityOfGasesPage extends StatefulWidget {
  const Cl8Ch09A4SolubilityOfGasesPage({super.key});

  @override
  State<Cl8Ch09A4SolubilityOfGasesPage> createState() =>
      _Cl8Ch09A4SolubilityOfGasesPageState();
}

class _Cl8Ch09A4SolubilityOfGasesPageState
    extends State<Cl8Ch09A4SolubilityOfGasesPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.5,
    max: 2.5,
  );
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();

  /// Seconds since the page opened; drives every bubble and the fish.
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _clock.value = elapsed.inMicroseconds / 1e6,
  );

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  final List<Timer> _timers = [];
  Timer? _heatTimer;
  DateTime _lastSliderTick = DateTime.fromMillisecondsSinceEpoch(0);

  // Shared (source `State`).
  int _scenario = 1;
  int _step = 1;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  Size _stageViewport = Size.zero;

  // Scenario 1.
  bool _capPopped = false;
  bool _s1NextVisible = true;
  List<_Bubble> _sodaBubbles = const [];
  List<_Bubble> _coldBubbles = const [];
  List<_Bubble> _warmBubbles = const [];
  bool _coldOpened = false;
  bool _warmOpened = false;

  // Scenario 2.
  double _aquariumTemp = 20;
  bool _aquariumObserved = false;
  late final List<_Bubble> _oxygenBubbles = List.generate(_kOxygenDots, (_) {
    final duration = _random.nextDouble() * 4 + 4;
    return _Bubble(
      x: _random.nextDouble() * 0.95,
      bottom: -0.03,
      size: _random.nextDouble() * 3 + 3,
      duration: duration,
      start: -_random.nextDouble() * duration,
    );
  });
  bool _heating = false;
  bool _heatDone = false;
  int _beakerTemp = 20;
  final List<_Bubble> _beakerBubbles = [];
  final Set<_MatchCard> _matched = {};

  // Overlays.
  final List<_LogEntry> _log = [];
  bool? _logOpen;
  Offset _logOffset = Offset.zero;
  Offset _instructionsOffset = Offset.zero;

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
    _heatTimer?.cancel();
    _confettiEntry?.remove();
    _confettiEntry = null;
    _ticker.dispose();
    _clock.dispose();
    _confetti.dispose();
    _zoom.dispose();
    _logScroll.dispose();
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
  double get _now => _clock.value;

  /// The source's `spawnParticles(..., moving = false)`.
  List<_Bubble> _staticBubbles(int count) => List.generate(
    count,
    (_) => _Bubble(
      x: _random.nextDouble(),
      bottom: _random.nextDouble(),
      size: _random.nextDouble() * 6 + 3,
    ),
  );

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

  /// The source's `setupS1` (state only).
  void _resetScenario1() {
    _capPopped = false;
    _s1NextVisible = true;
    _sodaBubbles = _staticBubbles(50);
    _coldBubbles = const [];
    _warmBubbles = const [];
    _coldOpened = false;
    _warmOpened = false;
  }

  /// The source's `setupS2` (state only).
  void _resetScenario2() {
    _heatTimer?.cancel();
    _heatTimer = null;
    _aquariumTemp = 20;
    _aquariumObserved = false;
    _heating = false;
    _heatDone = false;
    _beakerTemp = 20;
    _beakerBubbles.clear();
    _matched.clear();
  }

  /// The source's `changeScenario` (state only; call inside `setState`).
  void _enterScenario(int scenario) {
    _scenario = scenario;
    _step = 1;
    _toggledTiles.clear();
    _log.clear();
    _resetScenario1();
    _resetScenario2();
    if (scenario == 1) {
      _pushLog(
        () => _tx.s('logObserveSealed'),
        () => _tx.s('logObserveSealedRes'),
      );
    }
  }

  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() => _enterScenario(scenario));
    _zoom.reset();
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

  /// The source's `progressStep`.
  void _progressStep() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _step++;
      _toggledTiles.clear();
      if (_scenario == 1 && _step == 2) _s1NextVisible = false;
      if (_scenario == 1 && _step == 3) {
        _coldBubbles = _staticBubbles(30);
        _warmBubbles = _staticBubbles(30);
      }
    });
    if (_step > _kStepCount) _showSummary();
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
  /// The source's `showSummary` (Key Takeaway modal + confetti).
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
  /// The source's `openSodaBottle`.
  void _openSodaBottle() {
    if (_scenario != 1 || _step != 2 || _capPopped) return;
    _rt_playSfx(_rt_Sfx.magic);
    final now = _now;
    setState(() {
      _capPopped = true;
      _sodaBubbles = List.generate(
        80,
        (_) => _Bubble(
          x: _random.nextDouble(),
          bottom: -0.1,
          size: _random.nextDouble() * 6 + 3,
          duration: _random.nextDouble() * 2 + 1,
          start: now,
        ),
      );
      _pushLog(() => _tx.s('logOpenCap'), () => _tx.s('logOpenCapRes'));
    });
    _shell.showToast(
      _tx.s('toastPressure'),
      color: _rt_Tw.blue500,
      icon: Icons.bubble_chart,
    );
    _after(2000, () => setState(() => _s1NextVisible = true));
  }

  /// The source's `openCompareBottle`. Each bottle opens once (the source
  /// counted repeat clicks, so opening one bottle twice ended the step).
  void _openCompareBottle({required bool warm}) {
    if (_scenario != 1 || _step != 3) return;
    if (warm ? _warmOpened : _coldOpened) return;
    _rt_playSfx(_rt_Sfx.magic);
    final now = _now;
    final speed = warm ? 1.0 : 3.0;
    final bubbles = List.generate(
      warm ? 100 : 40,
      (_) => _Bubble(
        x: _random.nextDouble(),
        bottom: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 2,
        duration: _random.nextDouble() * speed + speed / 2,
        start: now,
      ),
    );
    setState(() {
      if (warm) {
        _warmOpened = true;
        _warmBubbles = bubbles;
      } else {
        _coldOpened = true;
        _coldBubbles = bubbles;
      }
      _pushLog(
        () => _tx.s(warm ? 'logOpenWarm' : 'logOpenCold'),
        () => _tx.s(warm ? 'logOpenWarmRes' : 'logOpenColdRes'),
      );
    });
    if (_coldOpened && _warmOpened) {
      _after(3000, () {
        if (_scenario == 1 && _step == 3) _progressStep();
      });
    }
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// The source's `o2Level`, in percent.
  double get _oxygenLevel => 100 - (_aquariumTemp - 10) / 30 * 80;

  /// The source's `updateAquarium` (slider `oninput`).
  void _onAquariumChanged(double value) {
    final now = DateTime.now();
    if (now.difference(_lastSliderTick).inMilliseconds > 50) {
      _rt_playSfx(_rt_Sfx.tap);
      _lastSliderTick = now;
    }
    var observed = false;
    setState(() {
      _aquariumTemp = value.roundToDouble();
      if (_aquariumTemp >= 35 && _step == 1 && !_aquariumObserved) {
        _aquariumObserved = true;
        observed = true;
        _pushLog(() => _tx.s('logAquarium'), () => _tx.s('logAquariumRes'));
      }
    });
    if (observed) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('toastOxygen'),
        color: _rt_Tw.red500,
        icon: Icons.warning_amber_rounded,
      );
    }
  }

  /// The source's `startHeating`. Runs once (the source started another
  /// interval on every click).
  void _startHeating() {
    if (_scenario != 2 || _step != 2 || _heating) return;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _heating = true);
    _heatTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final temp = _beakerTemp + 5;
      final burst = temp == 40 || temp == 60 || temp == 80;
      final now = _now;
      setState(() {
        _beakerTemp = temp;
        if (burst) {
          _beakerBubbles
            ..removeWhere((bubble) => bubble.finishedAt(now))
            ..addAll(
              List.generate(
                5,
                (_) => _Bubble(
                  x: _random.nextDouble(),
                  bottom: 0,
                  size: 4,
                  duration: _random.nextDouble() + 1,
                  start: now,
                  loop: false,
                ),
              ),
            );
        }
        if (temp == 60) {
          _pushLog(() => _tx.s('logHeat60'), () => _tx.s('logHeat60Res'));
        }
        if (temp >= 100) _heatDone = true;
      });
      if (burst) _rt_playSfx(_rt_Sfx.magic);
      if (temp == 60) {
        _shell.showToast(
          _tx.s('toastHeat'),
          color: _rt_Tw.blue500,
          icon: Icons.bubble_chart,
        );
      }
      if (temp >= 100) {
        timer.cancel();
        _heatTimer = null;
      }
    });
  }

  /// The source's `handleMatchDrop`.
  void _dropCard(_MatchCard card, _MatchZone zone) {
    if (_scenario != 2 || _step != 3 || _matched.contains(card)) return;
    final correct =
        (card == _MatchCard.highPressure && zone == _MatchZone.more) ||
        (card == _MatchCard.highTemp && zone == _MatchZone.less);
    if (!correct) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('incorrectMatch'),
        color: _rt_Tw.red500,
        icon: Icons.close,
      );
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    final pressure = card == _MatchCard.highPressure;
    setState(() {
      _matched.add(card);
      _pushLog(
        () => _tx.s(pressure ? 'logMatchPressure' : 'logMatchTemp'),
        () => _tx.s(pressure ? 'logMatchPressureRes' : 'logMatchTempRes'),
      );
    });
    if (_matched.length == _MatchCard.values.length) {
      _after(1000, () {
        if (_scenario == 2 && _step == 3) _progressStep();
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
            icon: Icons.waves,
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
            if (_step <= _kStepCount)
              Positioned(
                top: 8,
                left: 72,
                right: 72,
                child: Center(child: _hud()),
              ),
            if (_scenario == 1 && _step <= 2) _instructionsPanel(context),
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
              for (var i = 1; i <= _kStepCount; i++)
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

  /// The source's draggable `#instructions-panel` (scenario 1, steps 1-2).
  Widget _instructionsPanel(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Positioned(
      left: 12 + _instructionsOffset.dx,
      bottom: 16 - _instructionsOffset.dy,
      // 180 keeps it clear of the centred bottle on phones.
      width: compact ? 180 : 260,
      child: Container(
        key: const ValueKey('instructions-panel'),
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 10),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _rt_Tw.blue500.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) => setState(() {
                final next = _instructionsOffset + details.delta;
                _instructionsOffset = Offset(
                  next.dx.clamp(-10.0, 1600.0),
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
                    Icons.info_outline,
                    size: 14,
                    color: _rt_Tw.blue500,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _tx.s('instructions'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 10, color: _rt_Lab.border),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                _tx.s('instructionsText'),
                style: TextStyle(
                  fontSize: compact ? 10.5 : 12,
                  fontWeight: FontWeight.w600,
                  color: _rt_Lab.textMuted,
                  height: 1.3,
                ),
              ),
            ),
            if (_s1NextVisible) ...[
              const SizedBox(height: 8),
              _GradientButton(
                key: const ValueKey('btn-s1-next'),
                label: _tx.s(_step == 1 ? 'continueStep2' : 'nextStep'),
                onTap: _progressStep,
              ),
            ],
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
  /// The source's `#interactive-ui-layer`: one view per scenario step.
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Clear the HUD (top), the toolbar strip (right) and the floating
        // panels (bottom).
        final contentWidth = math.max(0.0, constraints.maxWidth - 12 - 60);
        final stageHeight = math.max(220.0, constraints.maxHeight - 150);
        return SingleChildScrollView(
          key: const ValueKey('workspace'),
          padding: const EdgeInsets.fromLTRB(12, 100, 60, 170),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: _stepView(contentWidth, stageHeight),
            ),
          ),
        );
      },
    );
  }

  Widget _stepView(double width, double stageHeight) {
    if (_scenario == 1) {
      return _step <= 2
          ? _sodaView(width, stageHeight)
          : _compareView(width, stageHeight);
    }
    if (_step <= 1) return _aquariumView(width, stageHeight);
    if (_step == 2) return _heatingView(width, stageHeight);
    return _matchView(width);
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

  /// Fades the source's `.dynamic-label` callouts with the labels toggle.
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

  /// Glass outline that stays visible on the light canvas too.
  Color get _glassOutline => _rt_appTheme.isDark
      ? Colors.white.withValues(alpha: 0.4)
      : _rt_Tw.slate400;

  // -------------------------------------------------------- scenario 1 UI --
  Widget _sodaView(double width, double stageHeight) {
    return _stageBox(_sodaStage(), _kSodaStage, width, stageHeight);
  }

  /// `#sc1-step12`: the sealed bottle, its cap and the two callouts.
  Widget _sodaStage() {
    const bottle = _kBottleRect;
    const capWidth = 56.0;
    const capHeight = 20.0;
    const hitPad = 16.0;
    final capLeft = bottle.center.dx - capWidth / 2 + (_capPopped ? 60 : 0);
    final capTop = bottle.top - 55 + (_capPopped ? -80 : 0);
    const capCurve = Cubic(0.25, 1, 0.5, 1);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // `.bottle-neck`
        Positioned(
          left: bottle.center.dx - 25,
          top: bottle.top - 40,
          width: 50,
          height: 46,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.symmetric(
                vertical: BorderSide(color: _glassOutline, width: 6),
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: bottle,
          child: _sodaBottle(
            key: const ValueKey('soda-bottle'),
            bubbles: _sodaBubbles,
            outline: _glassOutline,
          ),
        ),
        // `.bottle-cap` (+ `.popped`), with a finger-sized hit area.
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: capCurve,
          left: capLeft - hitPad,
          top: capTop - hitPad,
          width: capWidth + hitPad * 2,
          height: capHeight + hitPad * 2,
          child: GestureDetector(
            key: const ValueKey('soda-cap'),
            behavior: HitTestBehavior.opaque,
            onTap: _openSodaBottle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Center(
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  curve: capCurve,
                  turns: _capPopped ? 0.125 : 0,
                  child: Container(
                    width: capWidth,
                    height: capHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_kRose600, _kRose600, _kRose800, _kRose800],
                        stops: [0, 0.85, 0.85, 1],
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _tx.s('capOpen'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // "Carbonated Drink (Liquid)"
        Positioned(
          left: bottle.left - 128,
          top: bottle.top + bottle.height / 2,
          width: 112,
          child: _label(
            _GlassLabel(
              borderColor: _rt_Tw.blue400.withValues(alpha: 0.5),
              child: Text(
                _tx.s('carbonatedDrink'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _rt_Tw.blue500,
                ),
              ),
            ),
          ),
        ),
        // "Pressure Gauge"
        Positioned(
          left: bottle.right + 16,
          top: bottle.top + bottle.height / 4,
          width: 128,
          child: _label(_pressureGauge()),
        ),
      ],
    );
  }

  Widget _pressureGauge() {
    return _GlassLabel(
      borderColor: _rt_Tw.slate400.withValues(alpha: 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('pressureGauge'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.slate500,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              color: _rt_Tw.slate200,
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                key: const ValueKey('pressure-meter'),
                duration: const Duration(milliseconds: 1000),
                widthFactor: _capPopped ? 0.1 : 1,
                heightFactor: 1,
                child: Container(color: _rt_Tw.red500),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s(_capPopped ? 'pressureLow' : 'pressureHigh'),
            key: const ValueKey('pressure-lbl'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.slate500,
            ),
          ),
        ],
      ),
    );
  }

  /// `.soda-bottle`: glass body, drink in the lower 60 %, CO2 dots in it.
  Widget _sodaBottle({
    Key? key,
    required List<_Bubble> bubbles,
    required Color outline,
  }) {
    const radius = BorderRadius.vertical(
      top: Radius.circular(30),
      bottom: Radius.circular(10),
    );
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: outline, width: 6),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.1),
            _kSoda,
            _kSoda,
          ],
          stops: const [0, 0.4, 0.4, 1],
        ),
      ),
      // The source's inset shadows: a glassy highlight left, shade right.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.16),
          ],
          stops: const [0, 0.18, 0.82, 1],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.6,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
            child: CustomPaint(
              painter: _BubblesPainter(bubbles, _clock),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  /// `#sc1-step3`: cold vs warm bottles.
  Widget _compareView(double width, double stageHeight) {
    return Column(
      children: [
        Text(
          _tx.s('compareTemps'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _rt_Lab.text,
          ),
        ),
        const SizedBox(height: 12),
        _stageBox(_compareStage(), _kCompareStage, width, stageHeight - 40),
      ],
    );
  }

  Widget _compareStage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_compareColumn(warm: false), _compareColumn(warm: true)],
    );
  }

  Widget _compareColumn({required bool warm}) {
    final accent = warm ? _rt_Tw.red500 : _rt_Tw.blue500;
    final opened = warm ? _warmOpened : _coldOpened;
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                warm ? Icons.thermostat : Icons.ac_unit,
                size: 22,
                color: accent,
              ),
              const SizedBox(width: 6),
              Text(
                _tx.s(warm ? 'warmWater' : 'coldWater'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 180,
            child: _sodaBottle(
              key: ValueKey(warm ? 'bottle-warm' : 'bottle-cold'),
              bubbles: warm ? _warmBubbles : _coldBubbles,
              outline: warm ? _kRed300 : _kBlue300,
            ),
          ),
          const SizedBox(height: 16),
          _ChunkyButton(
            key: ValueKey(warm ? 'btn-open-warm' : 'btn-open-cold'),
            label: _tx.s('openBottle'),
            color: _rt_Tw.slate800,
            borderColor: _rt_Tw.slate950,
            onPressed: opened || _step != 3
                ? null
                : () => _openCompareBottle(warm: warm),
          ),
          const SizedBox(height: 10),
          Text(
            opened ? _tx.s(warm ? 'fastFuzz' : 'slowFuzz') : '',
            key: ValueKey(warm ? 'res-warm' : 'res-cold'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.slate500,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- scenario 2 UI --
  /// `#sc2-step1`: temperature slider, oxygen meter and the aquarium.
  Widget _aquariumView(double width, double stageHeight) {
    return Column(
      children: [
        _aquariumControls(width),
        const SizedBox(height: 14),
        _stageBox(
          _aquariumStage(),
          _kAquariumStage,
          width,
          stageHeight - 70,
          maxScale: 1.2,
        ),
        if (_aquariumObserved) ...[
          const SizedBox(height: 14),
          _ChunkyButton(
            key: const ValueKey('btn-s2-next-1'),
            label: _tx.s('nextPhase'),
            color: _rt_Tw.blue600,
            borderColor: _rt_Tw.blue800,
            onPressed: _step == 1 ? _progressStep : null,
          ),
        ],
      ],
    );
  }

  Widget _aquariumControls(double width) {
    final temperature = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${_tx.s('waterTemp')} '),
          TextSpan(
            text: '${_aquariumTemp.round()}°C',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _rt_Tw.blue500,
            ),
          ),
        ],
      ),
      key: const ValueKey('aq-temp-lbl'),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.textMuted,
      ),
    );
    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: _rt_Tw.blue500,
        inactiveTrackColor: _rt_appTheme.isDark
            ? _rt_Tw.slate600
            : _rt_Tw.slate300,
        thumbColor: _rt_Tw.blue500,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
      ),
      child: Slider(
        key: const ValueKey('aq-temp-slider'),
        value: _aquariumTemp,
        min: 10,
        max: 40,
        divisions: 30,
        onChanged: _onAquariumChanged,
      ),
    );
    final oxygen = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _tx.s('dissolvedOxygen').toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: _rt_Tw.slate500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 110,
          height: 12,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _rt_Tw.slate200,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _rt_Tw.slate300),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            key: const ValueKey('aq-o2-meter'),
            duration: const Duration(milliseconds: 300),
            widthFactor: _oxygenLevel / 100,
            heightFactor: 1,
            child: Container(color: _rt_Tw.cyan400),
          ),
        ),
      ],
    );
    final wide = width >= 560;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: _GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: wide
            ? Row(
                children: [
                  temperature,
                  const SizedBox(width: 8),
                  Expanded(child: slider),
                  Container(
                    width: 1,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: _rt_Lab.borderStrong,
                  ),
                  oxygen,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: temperature),
                  slider,
                  Center(child: oxygen),
                ],
              ),
      ),
    );
  }

  /// The aquarium tank: tinted water, O2 dots (as many as the oxygen level
  /// allows) and the swimming fish, faded when it is stressed.
  Widget _aquariumStage() {
    final temperature = _aquariumTemp;
    final tint = Color.fromRGBO(
      (59 + temperature * 2).round(),
      (130 - temperature).round(),
      246,
      0.2,
    );
    final dots = (_kOxygenDots * _oxygenLevel / 100).round();
    const inner = Size(492, 292); // inside the 4 px border
    return Container(
      key: const ValueKey('aquarium'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.slate400, width: 4),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kCyan100, _kBlue200],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: tint,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _BubblesPainter(
                  _oxygenBubbles.take(dots).toList(),
                  _clock,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            Positioned(
              left: inner.width * 0.2,
              top: inner.height * 0.4,
              child: AnimatedBuilder(
                animation: _clock,
                builder: (context, child) {
                  // `swim`: up 10 px and tilted -5 deg at the 1 s midpoint.
                  final phase = (_clock.value % 2) / 2;
                  final k = (1 - math.cos(phase * 2 * math.pi)) / 2;
                  return Transform.translate(
                    offset: Offset(0, -10 * k),
                    child: Transform.rotate(
                      angle: -5 * math.pi / 180 * k,
                      child: child,
                    ),
                  );
                },
                child: AnimatedOpacity(
                  key: const ValueKey('aq-fish'),
                  duration: const Duration(milliseconds: 500),
                  opacity: temperature >= 35 ? 0.5 : 1,
                  child: const CustomPaint(
                    size: Size(64, 40),
                    painter: _FishPainter(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `#sc2-step2`: beaker on the hot plate.
  Widget _heatingView(double width, double stageHeight) {
    return Column(
      children: [
        _stageBox(_beakerStage(), _kBeakerStage, width, stageHeight - 60),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _ChunkyButton(
              key: const ValueKey('btn-heat'),
              label: _tx.s('turnOnHeat'),
              color: _rt_Tw.red600,
              borderColor: _kRose800,
              onPressed: _heating || _step != 2 ? null : _startHeating,
            ),
            if (_heatDone)
              _ChunkyButton(
                key: const ValueKey('btn-s2-next-2'),
                label: _tx.s('nextChallenge'),
                color: _rt_Tw.blue600,
                borderColor: _rt_Tw.blue800,
                onPressed: _step == 2 ? _progressStep : null,
              ),
          ],
        ),
      ],
    );
  }

  Widget _beakerStage() {
    const beaker = Rect.fromLTWH(150, 20, 160, 200);
    const plate = Rect.fromLTWH(134, 228, 192, 48);
    const wall = 4.0;
    final outline = _rt_appTheme.isDark
        ? Colors.white.withValues(alpha: 0.6)
        : _rt_Tw.slate400;
    const waterHeight = (200 - wall) * 0.7;
    return Stack(
      children: [
        Positioned.fromRect(
          rect: beaker,
          child: CustomPaint(
            painter: _BeakerPainter(outline: outline, wall: wall, radius: 20),
            child: Stack(
              children: [
                Positioned(
                  left: wall,
                  right: wall,
                  bottom: wall,
                  height: waterHeight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: Container(
                      color: _rt_Tw.blue500.withValues(alpha: 0.4),
                      child: CustomPaint(
                        painter: _BubblesPainter(_beakerBubbles, _clock),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                // Graduation marks at 20 / 40 / 60 %.
                for (final (level, length) in const [
                  (0.2, 12.0),
                  (0.4, 16.0),
                  (0.6, 12.0),
                ])
                  Positioned(
                    left: wall,
                    bottom: wall + (200 - wall) * level,
                    width: length,
                    height: 2,
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Hot plate (darker 4 px bottom edge).
        Positioned.fromRect(
          rect: plate,
          child: Container(
            decoration: BoxDecoration(
              color: _rt_Tw.slate900,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              decoration: BoxDecoration(
                color: _rt_Tw.slate800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    key: const ValueKey('hotplate-led'),
                    duration: const Duration(milliseconds: 300),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _heating ? _rt_Tw.red500 : _kRed900,
                      boxShadow: _heating
                          ? const [
                              BoxShadow(color: _rt_Tw.red500, blurRadius: 10),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _tx.s('hotPlate'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: 3,
                      color: _rt_Tw.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Thermometer callout.
        Positioned(
          right: 6,
          top: 40,
          child: _label(
            _GlassLabel(
              borderColor: _rt_Tw.slate300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thermostat, size: 24, color: _rt_Tw.red500),
                  const SizedBox(height: 4),
                  Text(
                    '$_beakerTemp°C',
                    key: const ValueKey('beaker-temp'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// `#sc2-step3`: drag each condition onto its effect.
  Widget _matchView(double width) {
    final stacked = width < 560;
    final cards = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final card in _MatchCard.values)
          if (!_matched.contains(card))
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _draggableCard(card),
            ),
      ],
    );
    final zones = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dropZone(_MatchZone.more),
        const SizedBox(height: 14),
        _dropZone(_MatchZone.less),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: _GlassPanel(
        padding: EdgeInsets.all(stacked ? 16 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _tx.s('matchRules').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: stacked ? 18 : 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: _rt_Lab.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tx.s('matchDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _rt_Lab.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            if (stacked) ...[
              cards,
              const SizedBox(height: 10),
              zones,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards),
                  const SizedBox(width: 28),
                  Expanded(child: zones),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _matchCardFace(_MatchCard card, {bool lifted = false}) {
    final pressure = card == _MatchCard.highPressure;
    final accent = pressure ? _rt_Tw.blue500 : _rt_Tw.red500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(
          pressure ? _rt_Tw.blue100 : _rt_Tw.red100,
          accent,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.3 : 0.12),
            blurRadius: lifted ? 16 : 6,
            offset: Offset(0, lifted ? 6 : 2),
          ),
        ],
      ),
      child: Text(
        _tx.s(pressure ? 'highPressure' : 'highTemp'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _rt_Lab.text,
        ),
      ),
    );
  }

  Widget _draggableCard(_MatchCard card) {
    return LayoutBuilder(
      builder: (context, constraints) => Draggable<_MatchCard>(
        key: ValueKey(card == _MatchCard.highPressure ? 'card-hp' : 'card-ht'),
        data: card,
        onDragStarted: () => _rt_playSfx(_rt_Sfx.pop),
        onDraggableCanceled: (_, _) => _rt_playSfx(_rt_Sfx.wrong),
        feedback: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Transform.scale(
              scale: 1.05,
              child: _matchCardFace(card, lifted: true),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: _matchCardFace(card)),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: _matchCardFace(card),
        ),
      ),
    );
  }

  Widget _dropZone(_MatchZone zone) {
    final more = zone == _MatchZone.more;
    final placed = more ? _MatchCard.highPressure : _MatchCard.highTemp;
    return DragTarget<_MatchCard>(
      key: ValueKey(more ? 'drop-more' : 'drop-less'),
      onWillAcceptWithDetails: (details) => !_matched.contains(details.data),
      onAcceptWithDetails: (details) => _dropCard(details.data, zone),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return CustomPaint(
          painter: _DashedRRectPainter(
            color: hovering
                ? _rt_Tw.blue500
                : (_rt_appTheme.isDark ? _rt_Tw.slate600 : _rt_Tw.slate400),
            radius: 12,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hovering
                  ? _rt_Tw.blue500.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _tx.s(more ? 'moreGas' : 'lessGas'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.slate500,
                  ),
                ),
                if (_matched.contains(placed)) ...[
                  const SizedBox(height: 10),
                  _matchCardFace(placed),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------- widgets ----

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: child,
    );
  }
}

/// The source's small `.glass-panel` callouts on the stage.
class _GlassLabel extends StatelessWidget {
  const _GlassLabel({required this.child, required this.borderColor});

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
      ),
      child: child,
    );
  }
}

/// `bg-gradient-to-r from-blue-600 to-blue-500` button with a trailing arrow.
class _GradientButton extends StatelessWidget {
  const _GradientButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [_rt_Tw.blue600, _rt_Tw.blue500],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
              ],
            ),
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

/// Draws [_Bubble]s inside their container (the source's `.particle` divs).
class _BubblesPainter extends CustomPainter {
  _BubblesPainter(this.bubbles, this.clock, {Color? color})
    : color = color ?? Colors.white.withValues(alpha: 0.9),
      super(repaint: clock);

  final List<_Bubble> bubbles;
  final ValueNotifier<double> clock;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final now = clock.value;
    final paint = Paint();
    final rise = math.min(_kRiseDistance, size.height * _kRiseHeightFactor);
    for (final bubble in bubbles) {
      var centre = Offset(
        bubble.x * size.width + bubble.size / 2,
        size.height - bubble.bottom * size.height - bubble.size / 2,
      );
      var radius = bubble.size / 2;
      var opacity = 1.0;
      final duration = bubble.duration;
      if (duration != null) {
        final elapsed = now - bubble.start;
        if (elapsed < 0 && !bubble.loop) continue;
        if (bubble.finishedAt(now)) continue;
        final phase = bubble.loop
            ? (elapsed / duration) % 1
            : (elapsed / duration).clamp(0.0, 1.0);
        centre = centre.translate(0, -rise * phase);
        radius *= 1 + 0.5 * phase;
        // 0 % opacity 0 -> 10 % 1 -> 90 % 1 -> 100 % 0.
        opacity = phase < 0.1
            ? phase / 0.1
            : (phase > 0.9 ? (1 - phase) / 0.1 : 1.0);
      }
      if (centre.dy < -radius) continue;
      paint.color = color.withValues(alpha: color.a * opacity);
      canvas.drawCircle(centre, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter old) =>
      old.bubbles != bubbles || old.color != color;
}

/// `.beaker`: open-topped glass with a rounded bottom.
class _BeakerPainter extends CustomPainter {
  const _BeakerPainter({
    required this.outline,
    required this.wall,
    required this.radius,
  });

  final Color outline;
  final double wall;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final glass = RRect.fromRectAndCorners(
      Offset.zero & size,
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
    canvas.drawRRect(
      glass,
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );
    final half = wall / 2;
    final r = radius - half;
    final path = Path()
      ..moveTo(half, 0)
      ..lineTo(half, size.height - half - r)
      ..arcToPoint(
        Offset(half + r, size.height - half),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(size.width - half - r, size.height - half)
      ..arcToPoint(
        Offset(size.width - half, size.height - half - r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(size.width - half, 0);
    canvas.drawPath(
      path,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = wall,
    );
  }

  @override
  bool shouldRepaint(_BeakerPainter old) =>
      old.outline != outline || old.wall != wall || old.radius != radius;
}

/// The orange aquarium fish (Phosphor `ph-fish`), facing right.
class _FishPainter extends CustomPainter {
  const _FishPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()..color = _rt_Tw.orange500;
    final darker = Paint()..color = _rt_Tw.orange600;

    canvas.drawShadow(
      Path()..addOval(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.75, h * 0.6)),
      Colors.black,
      3,
      false,
    );
    // Tail.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.3, h * 0.5)
        ..lineTo(0, h * 0.12)
        ..quadraticBezierTo(w * 0.08, h * 0.5, 0, h * 0.88)
        ..close(),
      darker,
    );
    // Dorsal and belly fins.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.45, h * 0.25)
        ..quadraticBezierTo(w * 0.55, 0, w * 0.72, h * 0.24)
        ..close(),
      darker,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.75)
        ..quadraticBezierTo(w * 0.56, h * 0.98, w * 0.68, h * 0.76)
        ..close(),
      darker,
    );
    // Body.
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.78, h * 0.6), body);
    // Gill line.
    canvas.drawArc(
      Rect.fromLTWH(w * 0.62, h * 0.32, w * 0.14, h * 0.36),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = _rt_Tw.orange600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Eye.
    canvas.drawCircle(
      Offset(w * 0.84, h * 0.42),
      h * 0.09,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.855, h * 0.42),
      h * 0.045,
      Paint()..color = _rt_Tw.slate900,
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

/// `border-2 border-dashed` drop zone outline.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          Radius.circular(radius),
        ),
      );
    _drawDashedPath(
      canvas,
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      6,
      4,
    );
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
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
