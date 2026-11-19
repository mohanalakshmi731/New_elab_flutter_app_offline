// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 4.5: Dry Cells and Rechargeable Batteries
// Converted from Cl8S-Ch4-A2-Dry_Cells_and_Rechargeable_Batteries_Simulation_Strategy.html
// (Tailwind DOM + SVG -> Flutter widgets + CustomPainters; drag-and-drop via
// Draggable / DragTarget with the source's tap-to-select fallback).
//
// Two scenarios chosen from the sidebar. 1: Build a Dry Cell -- place the zinc
// container (negative terminal), pour in the electrolyte paste, insert the
// carbon rod and cap it (positive terminal), then close the switch: current
// flows round the loop and the bulb glows. 2: Recharge, Reuse, Recycle --
// three freely selectable tabs: sort six devices by power source, run
// discharge/charge cycles while the battery's maximum capacity degrades, and
// dispose of the worn battery (garbage raises a toxic-chemicals warning,
// e-waste recycling completes the lab). Observation log, current-task HUD,
// labels / pan / zoom tools, every source string (EN/HI; the source's TE block
// is dropped like every other page) and confetti are ported.

import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
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
// Copied from the source's `const dict = {HI, TE}` block (TE dropped). Keys
// marked "added" had no Hindi in the source.
final _tx = _rt_Tx({
  'en': {
    'title': 'Inside Cells and Rechargeable Batteries',
    'introTitle': 'Inside Cells & Rechargeable Batteries',
    'subtitle': 'Class 8: Electricity: Magnetic and Heating Effects',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Dry Cells • Rechargeable Batteries',
    'tabGuide': 'Lab Guide',
    'obsLog': 'Observation Log',
    'clear': 'Clear',
    'action': 'Action',
    'result': 'Result',
    'noObs': 'No observations yet.',
    'currentTask': 'Current Task',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'selectScenario': 'Select Scenario',
    'scenario1': '1. Build a Dry Cell',
    'scenario2': '2. Recharge, Reuse, Recycle',
    'componentsBox': 'Components Box',
    'partZinc': 'Zinc Container',
    'partPaste': 'Paste Electrolyte',
    'partCarbon': 'Carbon Rod',
    'partCap': 'Metal Cap',
    'tapPartHint': 'Tap a part, then tap the assembly zone!',
    'dropHint': 'Tap/Drop Parts Here',
    'negTerminal': 'Negative Terminal (-)',
    'posTerminal': 'Positive Terminal (+)',
    'pasteLabel': 'Paste Electrolyte',
    'closeSwitch': 'CLOSE SWITCH',
    'openSwitch': 'OPEN SWITCH',
    'navSort': '1. Device Sorting',
    'navLife': '2. Battery Lifespan',
    'navRecycle': '3. Safe Recycling',
    'sortTitle': 'Sort devices by their power source',
    'sortHint': 'Tap a device below, then tap the correct bin above!',
    'binSingle': 'Single-use Dry Cell',
    'binRechargeable': 'Rechargeable Battery',
    'binMains': 'Mains Power / Other',
    'devClock': 'Wall Clock',
    'devRemote': 'TV Remote',
    'devPhone': 'Smartphone',
    'devLaptop': 'Laptop',
    'devEv': 'EV Car',
    'devToaster': 'Toaster',
    'lifeTitle': 'Simulate Recharge Cycles',
    'maxHealth': 'Max Capacity Health:',
    'chargeCycles': 'Charge Cycles:',
    'useDevice': 'Use Device (Discharge)',
    'plugIn': 'Plug In (Charge)',
    'lifeNote':
        'Notice how maximum capacity reduces slightly after multiple cycles.',
    'recycleTitle': 'Dispose of the old battery safely',
    'recycleHint': 'Tap the old battery, then tap a bin to dispose!',
    'garbage': 'Regular Garbage',
    'ewaste': 'E-Waste Recycling',
    'danger': 'DANGER: Batteries leak toxic chemicals!',
    'success': 'Success!',
    'keyTakeaway': 'Key Takeaway',
    'continue': 'Continue',
    'restartLab': 'Restart Lab',
    'ok': 'OK',
    'missionObjective': 'Mission Objective',
    'mission1':
        'Build a dry cell, identify its terminals, and understand how stored chemical energy is converted into electrical energy.',
    'mission2':
        'Understand the difference between single-use and rechargeable batteries, their lifespans, and how to safely dispose of them to protect the environment.',
    'exploration': 'Exploration',
    'focus': 'FOCUS:',
    'actionLbl': 'Action:',
    'observationLbl': 'Observation:',
    's1f1': 'Outer Shell',
    's1a1': 'Drag the Zinc Container (Negative Terminal) to the assembly zone.',
    's1o1':
        'A dry cell consists of a zinc container which acts as the negative terminal. It holds the chemical components.',
    's1f2': 'Chemical Energy',
    's1a2': 'Add Paste Electrolyte inside the container.',
    's1o2':
        'The container is filled with a moist paste of an electrolyte (like ammonium chloride). This paste contains the chemical energy.',
    's1f3': 'Positive Terminal',
    's1a3': 'Insert the Carbon Rod into the centre.',
    's1o3':
        'A carbon rod is inserted in the centre. The carbon rod acts as the positive terminal.',
    's1f4': 'Completing Assembly',
    's1a4': 'Place the Metal Cap on top of the rod.',
    's1o4':
        'A metal cap is placed on top of the carbon rod to provide a good contact point for the positive terminal.',
    's1f5': 'Circuit Test',
    's1a5': 'Click CLOSE SWITCH to test the cell.',
    's1o5':
        'When connected in a circuit, chemical reactions inside the cell generate electricity, powering the bulb until the chemicals are exhausted.',
    's2f1': 'Categorize Devices',
    's2a1': 'Sort devices by dragging them into the correct bins.',
    's2o1':
        'Some devices use single-use dry cells (like clocks), while others use rechargeable batteries (like phones) that can be replenished when empty.',
    's2f2': 'Battery Lifespan',
    's2a2': 'Simulate charge/discharge cycles using the buttons.',
    's2o2':
        'Unlike single-use cells, rechargeable batteries can be charged and discharged many times. However, over hundreds of cycles, their maximum capacity gradually degrades.',
    's2f3': 'Safe Disposal',
    's2a3': 'Drag the old battery to the safe recycling bin.',
    's2o3':
        'Old or dead batteries contain toxic chemicals and heavy metals. They must never be thrown in regular garbage. Always use designated E-Waste recycling bins.',
    'badgeSorted': '{n}/{total} devices sorted',
    'badgeHealth': 'Health: {h}%, Cycles: {c}',
    'badgeRecycled': 'Safely Recycled!',
    'hud1Step1': 'Step 1: Drag the Zinc Container to the assembly zone.',
    'hud1Step2':
        'Step 2: Drag the Paste Electrolyte inside the zinc container.',
    'hud1Step3': 'Step 3: Drag the Carbon Rod into the centre.',
    'hud1Step4': 'Step 4: Place the Metal Cap on top of the rod.',
    'hud1Step5':
        'Step 5: Connect the circuit and close the switch to test the cell.',
    'hud2Step1':
        'Step 1: Drag devices into the correct bins based on their power source.',
    'hud2Step2':
        'Step 2: Charge and use the battery to see how its capacity degrades over time.',
    'hud2Step3':
        'Step 3: Drag the degraded battery to the E-Waste Recycling bin.',
    'obsAddedZinc': 'Added Zinc Container',
    'obsNegTerminal': 'Forms the negative terminal.',
    'obsAddedPaste': 'Added Paste Electrolyte',
    'obsFills': 'Fills the container.',
    'obsInsertedCarbon': 'Inserted Carbon Rod',
    'obsCentre': 'Placed in centre.',
    'obsPlacedCap': 'Placed Metal Cap',
    'obsPosTerminal': 'Forms the positive terminal.',
    'obsClosedCircuit': 'Closed Circuit',
    'obsBulbGlows': 'Bulb glows using dry cell power.',
    'obsSorted': 'Sorted {d}',
    'obsIdentified': 'Correctly identified as {bin}',
    'obsDischarged': 'Discharged Battery',
    'obsCycleDone': 'Cycle {n} completed.',
    'obsCharged': 'Charged Battery',
    'obsCapacity': 'Max capacity reduced to {h}%.',
    'obsTrash': 'Attempted to trash battery',
    'obsToxic': 'Warning: Toxic chemicals!',
    'obsRecycled': 'Recycled Battery',
    'obsSafe': 'Safe disposal successful.',
    'msgSorted': "Great job! Now let's see how rechargeable batteries work.",
    'msgCapacity':
        'Notice how the max capacity is reducing! Eventually it will need to be recycled.',
    'summary1':
        "Dry cells use chemical paste to generate electricity and are portable because they don't spill liquid.",
    'summary2':
        'Used batteries contain toxic chemicals and valuable metals. Always recycle them safely instead of throwing them in regular garbage.',
  },
  'hi': {
    // The source's "कोशिकाओं" means biological cells; electric cells are "सेल".
    'title': 'सेल और रिचार्जेबल बैटरी के अंदर',
    'introTitle': 'सेल और रिचार्जेबल बैटरी के अंदर',
    'subtitle': 'कक्षा 8: विद्युत: चुंबकीय और ऊष्मीय प्रभाव',
    'enterLab': 'प्रयोगशाला में प्रवेश करें', // added
    'footnote': 'शुष्क सेल • रिचार्जेबल बैटरी', // added
    'tabGuide': 'लैब गाइड', // added
    'obsLog': 'अवलोकन लॉग',
    'clear': 'साफ करें',
    'action': 'कार्य',
    'result': 'परिणाम',
    'noObs': 'अभी तक कोई अवलोकन नहीं।',
    'currentTask': 'वर्तमान कार्य',
    'toggleLabels': 'लेबल टॉगल करें',
    'panMode': 'पैन मोड',
    'selectScenario': 'परिदृश्य चुनें',
    'scenario1': '1. एक शुष्क सेल इकट्ठा करें',
    'scenario2': '2. रिचार्ज, पुन: उपयोग, रीसायकल',
    'componentsBox': 'घटक बॉक्स',
    'partZinc': 'जिंक कंटेनर',
    'partPaste': 'इलेक्ट्रोलाइट पेस्ट',
    'partCarbon': 'कार्बन रॉड',
    'partCap': 'धातु की टोपी',
    'tapPartHint': 'एक भाग पर टैप करें, फिर असेंबली ज़ोन पर टैप करें!',
    'dropHint': 'भागों को यहाँ टैप करें/छोड़ें',
    'negTerminal': 'नकारात्मक टर्मिनल (-)',
    'posTerminal': 'सकारात्मक टर्मिनल (+)',
    'pasteLabel': 'इलेक्ट्रोलाइट पेस्ट',
    'closeSwitch': 'स्विच बंद करें',
    'openSwitch': 'स्विच खोलें',
    'navSort': '1. उपकरण छँटाई',
    'navLife': '2. बैटरी जीवनकाल',
    'navRecycle': '3. सुरक्षित रीसाइक्लिंग',
    'sortTitle': 'उपकरणों को उनके ऊर्जा स्रोत के अनुसार छाँटें',
    'sortHint': 'नीचे एक डिवाइस पर टैप करें, फिर ऊपर सही बिन पर टैप करें!',
    'binSingle': 'सिंगल-यूज़ शुष्क सेल',
    'binRechargeable': 'रिचार्जेबल बैटरी',
    'binMains': 'मुख्य पावर / अन्य',
    'devClock': 'दीवार घड़ी',
    'devRemote': 'टीवी रिमोट',
    'devPhone': 'स्मार्टफोन',
    'devLaptop': 'लैपटॉप',
    'devEv': 'ईवी कार',
    'devToaster': 'टोस्टर',
    'lifeTitle': 'रिचार्ज साइकिल का अनुकरण करें',
    'maxHealth': 'अधिकतम क्षमता स्वास्थ्य:',
    'chargeCycles': 'चार्ज चक्र:',
    'useDevice': 'बैटरी का उपयोग करें',
    'plugIn': 'बैटरी चार्ज करें',
    'lifeNote':
        'ध्यान दें कि कई चक्रों के बाद अधिकतम क्षमता कैसे कम हो जाती है।',
    'recycleTitle': 'पुरानी बैटरी का सुरक्षित रूप से निपटान करें',
    'recycleHint':
        'पुरानी बैटरी पर टैप करें, फिर निपटाने के लिए एक बिन पर टैप करें!',
    'garbage': 'सामान्य कचरा',
    'ewaste': 'ई-कचरा रीसाइक्लिंग',
    'danger': 'खतरा: बैटरियों से जहरीले रसायन रिसते हैं!',
    'success': 'सफलता!', // added
    'keyTakeaway': 'मुख्य निष्कर्ष',
    'continue': 'जारी रखें',
    'restartLab': 'प्रयोगशाला को पुनरारंभ करें',
    'ok': 'ठीक', // added
    'missionObjective': 'मिशन का उद्देश्य',
    'mission1':
        'एक शुष्क सेल बनाएं, इसके टर्मिनलों की पहचान करें, और समझें कि संग्रहीत रासायनिक ऊर्जा विद्युत ऊर्जा में कैसे परिवर्तित होती है।',
    'mission2':
        'सिंगल-यूज़ और रिचार्जेबल बैटरी के बीच के अंतर, उनके जीवनकाल, और पर्यावरण की रक्षा के लिए उन्हें सुरक्षित रूप से कैसे निपटाना है, यह समझें।',
    'exploration': 'अन्वेषण', // added
    'focus': 'ध्यान दें:', // added
    'actionLbl': 'कार्य:', // added
    'observationLbl': 'अवलोकन:', // added
    's1f1': 'बाहरी आवरण',
    's1a1': 'जिंक कंटेनर (नेगेटिव टर्मिनल) को असेंबली ज़ोन में खींचें।',
    's1o1':
        'एक शुष्क सेल में एक जिंक कंटेनर होता है जो नकारात्मक टर्मिनल के रूप में कार्य करता है। इसमें रासायनिक घटक होते हैं।',
    's1f2': 'रासायनिक ऊर्जा',
    's1a2': 'कंटेनर के अंदर इलेक्ट्रोलाइट पेस्ट डालें।',
    's1o2':
        'कंटेनर इलेक्ट्रोलाइट (जैसे अमोनियम क्लोराइड) के नम पेस्ट से भरा होता है। इस पेस्ट में रासायनिक ऊर्जा होती है।',
    's1f3': 'पॉजिटिव टर्मिनल',
    's1a3': 'कार्बन रॉड को केंद्र में डालें।',
    's1o3':
        'एक कार्बन रॉड को केंद्र में डाला जाता है। कार्बन रॉड सकारात्मक टर्मिनल के रूप में कार्य करती है।',
    's1f4': 'असेंबली पूरी करना',
    's1a4': 'रॉड के ऊपर धातु की टोपी रखें।',
    's1o4':
        'सकारात्मक टर्मिनल के लिए एक अच्छा संपर्क बिंदु प्रदान करने के लिए कार्बन रॉड के शीर्ष पर एक धातु की टोपी रखी जाती है।',
    's1f5': 'सर्किट परीक्षण',
    // The source kept the English button name here; use the Hindi label shown.
    's1a5': "सेल का परीक्षण करने के लिए 'स्विच बंद करें' पर क्लिक करें।",
    's1o5':
        'जब एक परिपथ में जोड़ा जाता है, तो सेल के अंदर रासायनिक प्रतिक्रियाएं बिजली उत्पन्न करती हैं, रसायनों के समाप्त होने तक बल्ब को शक्ति प्रदान करती हैं।',
    's2f1': 'उपकरणों को वर्गीकृत करें',
    's2a1': 'उपकरणों को सही डिब्बे में खींचकर छाँटें।',
    's2o1':
        'कुछ उपकरण सिंगल-यूज़ ड्राई सेल (जैसे घड़ियां) का उपयोग करते हैं, जबकि अन्य रिचार्जेबल बैटरी (जैसे फोन) का उपयोग करते हैं जिन्हें खाली होने पर फिर से भरा जा सकता है।',
    's2f2': 'बैटरी जीवनकाल',
    's2a2': 'बटन का उपयोग करके चार्ज/डिस्चार्ज चक्र का अनुकरण करें।',
    's2o2':
        'सिंगल-यूज़ सेल के विपरीत, रिचार्जेबल बैटरी को कई बार चार्ज और डिस्चार्ज किया जा सकता है। हालांकि, सैकड़ों चक्रों में, उनकी अधिकतम क्षमता धीरे-धीरे कम हो जाती है।',
    's2f3': 'सुरक्षित निपटान',
    's2a3': 'पुरानी बैटरी को सुरक्षित रीसाइक्लिंग बिन में खींचें।',
    's2o3':
        'पुरानी या मृत बैटरियों में जहरीले रसायन और भारी धातुएं होती हैं। उन्हें कभी भी नियमित कचरे में नहीं फेंकना चाहिए। हमेशा निर्दिष्ट ई-कचरा रीसाइक्लिंग डिब्बे का उपयोग करें।',
    'badgeSorted': '{n}/{total} उपकरण छाँटे गए', // added
    'badgeHealth': 'स्वास्थ्य: {h}%, चक्र: {c}', // added
    'badgeRecycled': 'सुरक्षित रूप से रीसायकल किया गया!', // added
    'hud1Step1': 'चरण 1: जिंक कंटेनर को असेंबली ज़ोन में खींचें।',
    'hud1Step2': 'चरण 2: कंटेनर में इलेक्ट्रोलाइट पेस्ट डालें।',
    'hud1Step3': 'चरण 3: कार्बन रॉड को केंद्र में खींचें।',
    'hud1Step4': 'चरण 4: धातु की टोपी को रॉड के ऊपर रखें।',
    'hud1Step5':
        'चरण 5: सर्किट को कनेक्ट करें और सेल का परीक्षण करने के लिए स्विच को बंद करें।',
    'hud2Step1':
        'चरण 1: उपकरणों को उनके ऊर्जा स्रोत के आधार पर सही डिब्बे में खींचें।',
    'hud2Step2':
        'चरण 2: बैटरी को चार्ज करें और उपयोग करें ताकि यह देखा जा सके कि समय के साथ इसकी क्षमता कैसे कम होती है।',
    'hud2Step3':
        'चरण 3: खराब हो चुकी बैटरी को ई-कचरा रीसाइक्लिंग बिन में खींचें।',
    'obsAddedZinc': 'जिंक कंटेनर जोड़ा गया',
    'obsNegTerminal': 'नकारात्मक टर्मिनल बनाता है।',
    'obsAddedPaste': 'इलेक्ट्रोलाइट पेस्ट डाला गया',
    'obsFills': 'कंटेनर को भरता है।',
    'obsInsertedCarbon': 'कार्बन रॉड डाला गया',
    'obsCentre': 'केंद्र में रखा गया।',
    'obsPlacedCap': 'धातु की टोपी रखी गई',
    'obsPosTerminal': 'पॉजिटिव टर्मिनल बनाता है।',
    'obsClosedCircuit': 'सर्किट बंद किया',
    'obsBulbGlows': 'सर्किट पूरा हुआ, बल्ब चमकता है।',
    'obsSorted': '{d} छाँटा गया', // added
    'obsIdentified': '{bin} के रूप में सही पहचाना गया',
    'obsDischarged': 'डिस्चार्ज की गई बैटरी',
    'obsCycleDone': 'चक्र {n} पूरा हुआ।',
    'obsCharged': 'चार्ज की गई बैटरी',
    'obsCapacity': 'अधिकतम क्षमता कम होकर {h}% हुई।',
    'obsTrash': 'बैटरी को कचरे में फेंकने का प्रयास किया',
    'obsToxic': 'चेतावनी: जहरीले रसायन!',
    'obsRecycled': 'पुनर्नवीनीकरण बैटरी',
    'obsSafe': 'सुरक्षित निपटान सफल।',
    'msgSorted':
        'बहुत बढ़िया! अब देखते हैं कि रिचार्जेबल बैटरी कैसे काम करती हैं।',
    'msgCapacity':
        'ध्यान दें कि अधिकतम क्षमता कैसे कम हो रही है! अंततः इसे रीसायकल करने की आवश्यकता होगी।',
    'summary1':
        'शुष्क सेल बिजली पैदा करने के लिए रासायनिक पेस्ट का उपयोग करते हैं और पोर्टेबल होते हैं क्योंकि वे तरल पदार्थ नहीं गिराते हैं।',
    'summary2':
        'प्रयुक्त बैटरियों में जहरीले रसायन और मूल्यवान धातुएं होती हैं। उन्हें नियमित कचरे में फेंकने के बजाय हमेशा सुरक्षित रूप से रीसायकल करें।',
  },
});

/// `_tx.s(key)` with `{name}` placeholders filled from [args].
String _fmt(String key, Map<String, Object> args) {
  var text = _tx.s(key);
  args.forEach((name, value) => text = text.replaceAll('{$name}', '$value'));
  return text;
}

// ------------------------------------------------------------- constants ----

/// Design size of the scenario 1 stage (assembly zone + test circuit).
const double _kStageWidth = 360;
const double _kStageHeight = 600;

/// The source's `#assembly-zone` (w-64 h-96) inside the stage.
const Rect _kZoneRect = Rect.fromLTWH(52, 16, 256, 384);

/// Camera zoom step and limits (the source's `zoomCam(±0.1)`).
const double _kZoomStep = 0.1;
const double _kZoomMin = 0.5;
const double _kZoomMax = 3.0;

const Color _kYellow300 = Color(0xFFFDE047);
const Color _kYellow600 = Color(0xFFCA8A04);
const Color _kYellow700 = Color(0xFFA16207);
const Color _kYellow800 = Color(0xFF854D0E);
const Color _kYellow900 = Color(0xFF713F12);
const Color _kGreen300 = Color(0xFF86EFAC);
const Color _kGreen800 = Color(0xFF166534);
const Color _kGreen900 = Color(0xFF14532D);
const Color _kRed200 = Color(0xFFFECACA);
const Color _kRed900 = Color(0xFF7F1D1D);

// ------------------------------------------------------------------ model ----

/// Dry-cell parts, in assembly order (the source's `sc1Progress`).
enum _CellPart { zinc, paste, carbon, cap }

enum _PowerSource { single, rechargeable, mains }

enum _WasteBin { garbage, recycle }

/// Drag payload for the old battery (keeps it apart from device drags).
enum _WasteToken { battery }

class _Device {
  const _Device(this.id, this.nameKey, this.source, this.icon);

  final String id;
  final String nameKey;
  final _PowerSource source;
  final IconData icon;
}

/// The source's `devices` list.
const List<_Device> _kDevices = [
  _Device('d1', 'devClock', _PowerSource.single, Icons.access_time_filled),
  _Device('d2', 'devRemote', _PowerSource.single, Icons.settings_remote),
  _Device('d3', 'devPhone', _PowerSource.rechargeable, Icons.smartphone),
  _Device('d4', 'devLaptop', _PowerSource.rechargeable, Icons.laptop),
  _Device('d5', 'devEv', _PowerSource.rechargeable, Icons.electric_car),
  _Device('d6', 'devToaster', _PowerSource.mains, Icons.breakfast_dining),
];

String _partLabelKey(_CellPart part) => switch (part) {
  _CellPart.zinc => 'partZinc',
  _CellPart.paste => 'partPaste',
  _CellPart.carbon => 'partCarbon',
  _CellPart.cap => 'partCap',
};

String _binLabelKey(_PowerSource source) => switch (source) {
  _PowerSource.single => 'binSingle',
  _PowerSource.rechargeable => 'binRechargeable',
  _PowerSource.mains => 'binMains',
};

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result);

  final String Function() action;
  final String Function() result;
}

// ------------------------------------------------------------------- page ----

class Cl8Ch04A5DryCellsRechargeableBatteriesPage extends StatefulWidget {
  const Cl8Ch04A5DryCellsRechargeableBatteriesPage({super.key});

  @override
  State<Cl8Ch04A5DryCellsRechargeableBatteriesPage> createState() =>
      _Cl8Ch04A5DryCellsRechargeableBatteriesPageState();
}

class _Cl8Ch04A5DryCellsRechargeableBatteriesPageState
    extends State<Cl8Ch04A5DryCellsRechargeableBatteriesPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();

  /// Current flow along the test circuit (the source's 0.5 s `flow`).
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  /// One-shot delays (popups, step changes); cancelled on scenario change.
  final List<Timer> _timers = [];

  /// The source's charge / discharge `interval`.
  Timer? _batteryTimer;
  Timer? _dangerTimer;

  // Shared (source `State`).
  int _scenario = 1;
  int _step = 1;
  final Set<int> _toggledTiles = {};
  final Set<int> _completedScenarios = {};
  bool _showLabels = true;
  bool _panMode = false;
  double _zoom = 1;
  Offset _pan = Offset.zero;

  // Scenario 1: dry cell.
  int _partsPlaced = 0;
  _CellPart? _selectedPart;
  bool _pasteLabelShown = false;
  bool _switchClosed = false;
  bool _cellSummaryShown = false;

  // Scenario 2: recharge, reuse, recycle.
  int _tab = 1;
  final Map<String, _PowerSource> _sorted = {};
  String? _selectedDevice;
  _PowerSource? _flashBin;
  double _batteryPct = 100;
  int _batteryHealth = 100;
  int _cycles = 0;
  bool _useEnabled = true;
  bool _chargeEnabled = false;
  bool _wasteSelected = false;
  bool _batteryRecycled = false;
  bool _dangerVisible = false;

  // Observation log.
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
    _batteryTimer?.cancel();
    _dangerTimer?.cancel();
    _confettiEntry?.remove();
    _confettiEntry = null;
    _flow.dispose();
    _confetti.dispose();
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
  String get _hudKey =>
      _scenario == 1 ? 'hud1Step${math.min(_step, 5)}' : 'hud2Step$_tab';

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

  /// The source's `changeScenario`. Like the source it keeps each scenario's
  /// progress; the sidebar step is derived from it so the two stay in sync.
  void _changeScenario(int scenario) {
    _rt_playSfx(_rt_Sfx.click);
    _cancelTimers();
    setState(() {
      _scenario = scenario;
      _toggledTiles.clear();
      _selectedPart = null;
      _selectedDevice = null;
      _wasteSelected = false;
      _flashBin = null;
      if (_partsPlaced >= 2) _pasteLabelShown = true;
      if (scenario == 1) {
        _step = _switchClosed ? 6 : _partsPlaced + 1;
      } else {
        _tab = 1;
        _step = 1;
      }
      _zoom = 1;
      _pan = Offset.zero;
    });
  }

  /// The source's `resetApp` (minus the shutter, which the shell owns).
  void _restart() {
    _cancelTimers();
    _batteryTimer?.cancel();
    _dangerTimer?.cancel();
    _flow
      ..stop()
      ..value = 0;
    setState(() {
      _scenario = 1;
      _step = 1;
      _toggledTiles.clear();
      _completedScenarios.clear();
      _zoom = 1;
      _pan = Offset.zero;
      _partsPlaced = 0;
      _selectedPart = null;
      _pasteLabelShown = false;
      _switchClosed = false;
      _cellSummaryShown = false;
      _tab = 1;
      _sorted.clear();
      _selectedDevice = null;
      _flashBin = null;
      _batteryPct = 100;
      _batteryHealth = 100;
      _cycles = 0;
      _useEnabled = true;
      _chargeEnabled = false;
      _wasteSelected = false;
      _batteryRecycled = false;
      _dangerVisible = false;
      _log.clear();
    });
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  void _togglePanMode() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _panMode = !_panMode);
  }

  void _zoomBy(double delta) =>
      setState(() => _zoom = (_zoom + delta).clamp(_kZoomMin, _kZoomMax));

  void _resetView() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

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

  /// The source's `showSummary`: Continue just closes it, until both
  /// scenarios are complete, when it offers Restart Lab instead.
  void _showSummary(int scenario, String text) {
    _completedScenarios.add(scenario);
    final allDone = _completedScenarios.containsAll(const {1, 2});
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _rt_Tw.green600,
      buttonLabel: _tx.s(allDone ? 'restartLab' : 'continue'),
      body: _SummaryBody(heading: _tx.s('keyTakeaway'), text: text),
      onConfirm: () {
        _rt_playSfx(_rt_Sfx.click);
        if (allDone) _restart();
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
  void _selectPart(_CellPart part) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selectedPart = _selectedPart == part ? null : part);
  }

  /// The source's `handleDropZoneClick`.
  void _tapZone() {
    final part = _selectedPart;
    if (part == null) return;
    setState(() => _selectedPart = null);
    _placePart(part);
  }

  /// The source's `processDrop`. Only the next part in order is accepted
  /// (the others are disabled, as in the source).
  void _placePart(_CellPart part) {
    if (part.index != _partsPlaced) return;
    _rt_playSfx(_rt_Sfx.pop);
    final (actionKey, resultKey) = switch (part) {
      _CellPart.zinc => ('obsAddedZinc', 'obsNegTerminal'),
      _CellPart.paste => ('obsAddedPaste', 'obsFills'),
      _CellPart.carbon => ('obsInsertedCarbon', 'obsCentre'),
      _CellPart.cap => ('obsPlacedCap', 'obsPosTerminal'),
    };
    setState(() {
      _partsPlaced++;
      _step = _partsPlaced + 1;
      _toggledTiles.clear();
      _selectedPart = null;
      _pushLog(() => _tx.s(actionKey), () => _tx.s(resultKey));
    });
    if (part == _CellPart.paste) {
      _after(1000, () => setState(() => _pasteLabelShown = true));
    }
  }

  /// The source's `toggleSwitch`. The summary opens on the first close only
  /// (the source reopened it every time the switch was closed again).
  void _toggleSwitch() {
    final closed = !_switchClosed;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _switchClosed = closed;
      if (closed) {
        _step = 6;
        _toggledTiles.clear();
        _pushLog(() => _tx.s('obsClosedCircuit'), () => _tx.s('obsBulbGlows'));
      }
    });
    if (closed) {
      _flow.repeat();
      if (!_cellSummaryShown) {
        _after(1500, () {
          if (_cellSummaryShown) return;
          _cellSummaryShown = true;
          _rt_playSfx(_rt_Sfx.success);
          _showSummary(1, _tx.s('summary1'));
        });
      }
    } else {
      _flow.stop();
    }
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// The source's `setSc2Step` (tab buttons and automatic advances).
  void _setTab(int tab, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _tab = tab;
      _step = tab;
      _toggledTiles.clear();
      _selectedDevice = null;
      _wasteSelected = false;
    });
  }

  void _selectDevice(String id) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selectedDevice = _selectedDevice == id ? null : id);
  }

  /// The source's `handleBinClick`.
  void _tapBin(_PowerSource bin) {
    final id = _selectedDevice;
    if (id == null) return;
    setState(() => _selectedDevice = null);
    _dropDevice(_kDevices.firstWhere((device) => device.id == id), bin);
  }

  /// The source's `processDeviceDrop`.
  void _dropDevice(_Device device, _PowerSource bin) {
    if (_sorted.containsKey(device.id)) return;
    if (device.source == bin) {
      _rt_playSfx(_rt_Sfx.pop);
      setState(() {
        _sorted[device.id] = bin;
        _pushLog(
          () => _fmt('obsSorted', {'d': _tx.s(device.nameKey)}),
          () => _fmt('obsIdentified', {'bin': _tx.s(_binLabelKey(bin))}),
        );
      });
      if (_sorted.length == _kDevices.length) {
        _rt_playSfx(_rt_Sfx.success);
        _after(1000, () {
          _setTab(2, sound: false);
          _showMessage(_tx.s('msgSorted'));
        });
      }
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() => _flashBin = bin);
      _after(500, () {
        if (_flashBin == bin) setState(() => _flashBin = null);
      });
    }
  }

  /// The source's `useBattery`: drain 5 % every 100 ms.
  void _useBattery() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _useEnabled = false);
    _batteryTimer?.cancel();
    _batteryTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        // Clamped: from 98 % the source's -5 steps ended at "-2%".
        _batteryPct = math.max(0.0, _batteryPct - 5);
        if (_batteryPct <= 0) {
          timer.cancel();
          _chargeEnabled = true;
          final cycle = _cycles + 1;
          _pushLog(
            () => _tx.s('obsDischarged'),
            () => _fmt('obsCycleDone', {'n': cycle}),
          );
        }
      });
    });
  }

  /// The source's `chargeBattery`: one more cycle, 2 % less capacity, refill
  /// 5 % every 100 ms up to the new maximum.
  void _chargeBattery() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _chargeEnabled = false;
      _cycles++;
      _batteryHealth -= 2;
    });
    _batteryTimer?.cancel();
    _batteryTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      var finished = false;
      setState(() {
        _batteryPct += 5;
        if (_batteryPct >= _batteryHealth) {
          timer.cancel();
          finished = true;
          _batteryPct = _batteryHealth.toDouble();
          _useEnabled = true;
          final health = _batteryHealth;
          _pushLog(
            () => _tx.s('obsCharged'),
            () => _fmt('obsCapacity', {'h': health}),
          );
        }
      });
      // Once, when the third cycle completes (the source repeated it after
      // every later charge too).
      if (finished && _cycles == 3) {
        _rt_playSfx(_rt_Sfx.success);
        _after(1000, () {
          _setTab(3, sound: false);
          _showMessage(_tx.s('msgCapacity'));
        });
      }
    });
  }

  void _selectWaste() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _wasteSelected = !_wasteSelected);
  }

  /// The source's `handleWasteBinClick`.
  void _tapWasteBin(_WasteBin bin) {
    if (!_wasteSelected || _batteryRecycled) return;
    setState(() => _wasteSelected = false);
    _disposeBattery(bin);
  }

  /// The source's `processWasteDrop`.
  void _disposeBattery(_WasteBin bin) {
    if (_batteryRecycled) return;
    if (bin == _WasteBin.garbage) {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() {
        _dangerVisible = true;
        _pushLog(() => _tx.s('obsTrash'), () => _tx.s('obsToxic'));
      });
      _dangerTimer?.cancel();
      _dangerTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _dangerVisible = false);
      });
    } else {
      _rt_playSfx(_rt_Sfx.pop);
      setState(() {
        _batteryRecycled = true;
        _step = 4;
        _toggledTiles.clear();
        _pushLog(() => _tx.s('obsRecycled'), () => _tx.s('obsSafe'));
      });
      _after(500, () {
        _rt_playSfx(_rt_Sfx.success);
        _showSummary(2, _tx.s('summary2'));
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
            title: _tx.s('introTitle'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.battery_charging_full,
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
  Widget _sidebar() {
    final tileCount = _scenario == 1 ? 5 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObjective'),
          desc: _tx.s('mission$_scenario'),
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
                  label: _tx.s('scenario$scenario'),
                  state: _scenario == scenario
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: _scenario == scenario
                      ? null
                      : () => _changeScenario(scenario),
                ),
              const SizedBox(height: 10),
              for (var i = 1; i <= tileCount; i++)
                _ExplorationTile(
                  key: ValueKey('tile-$_scenario-$i'),
                  number: i,
                  title: '${_tx.s('exploration')} $i',
                  focusLabel: _tx.s('focus'),
                  focus: _tx.s('s${_scenario}f$i'),
                  actionLabel: _tx.s('actionLbl'),
                  action: _tx.s('s${_scenario}a$i'),
                  observationLabel: _tx.s('observationLbl'),
                  observation: _tx.s('s${_scenario}o$i'),
                  badge: _tileBadge(i),
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

  /// Live progress badges under the scenario 2 explorations.
  Widget? _tileBadge(int tile) {
    if (_scenario != 2) return null;
    switch (tile) {
      case 1 when _sorted.isNotEmpty:
        return _ProgressBadge(
          icon: Icons.check_circle,
          color: _rt_Tw.blue500,
          text: _fmt('badgeSorted', {
            'n': _sorted.length,
            'total': _kDevices.length,
          }),
        );
      case 2 when _cycles > 0:
        return _ProgressBadge(
          icon: Icons.battery_alert,
          color: _rt_Tw.orange500,
          text: _fmt('badgeHealth', {'h': _batteryHealth, 'c': _cycles}),
        );
      case 3 when _batteryRecycled:
        return _ProgressBadge(
          icon: Icons.recycling,
          color: _rt_Tw.green500,
          text: _tx.s('badgeRecycled'),
        );
    }
    return null;
  }

  // -------------------------------------------------------------- overlays --
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
              _tx.s(_hudKey),
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
  /// toolbar owns that corner.
  Widget _observationLog(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final open = _logOpen ?? !compact;
    final width = compact ? 200.0 : 280.0;
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
                      color: _rt_Lab.textMuted,
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
  /// The source's `#scrollable-area`. Zoom and pan transform the whole
  /// workspace about its top centre, like the source's `updateCam`; in pan
  /// mode dragging empty space moves it instead of scrolling.
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.max(0.0, constraints.maxWidth - 12 - 60);
        final content = Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..translateByDouble(_pan.dx, _pan.dy, 0, 1)
            ..scaleByDouble(_zoom, _zoom, 1, 1),
          child: _scenario == 1
              ? _scenario1Layout(contentWidth)
              : _scenario2Layout(contentWidth),
        );
        return GestureDetector(
          onPanUpdate: _panMode
              ? (details) => setState(() => _pan += details.delta)
              : null,
          child: SingleChildScrollView(
            key: const ValueKey('workspace'),
            physics: _panMode ? const NeverScrollableScrollPhysics() : null,
            padding: const EdgeInsets.fromLTRB(12, 100, 60, 32),
            child: content,
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.text,
      ),
    );
  }

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

  // -------------------------------------------------------- scenario 1 UI --
  Widget _scenario1Layout(double width) {
    if (width >= 700) {
      final stageWidth = math.min(width - 260 - 24, _kStageWidth * 1.2);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 260, child: _componentsBox(cardWidth: null)),
          const SizedBox(width: 24),
          _stage(stageWidth),
        ],
      );
    }
    // Phones: the source's stacked column, parts two to a row.
    final cardWidth = math.max(140.0, (width - 32 - 10) / 2);
    return Column(
      children: [
        _componentsBox(cardWidth: cardWidth),
        const SizedBox(height: 16),
        _stage(math.min(width, _kStageWidth * 1.2)),
      ],
    );
  }

  Widget _stage(double width) {
    return SizedBox(
      width: width,
      height: width * _kStageHeight / _kStageWidth,
      child: FittedBox(
        child: SizedBox(
          width: _kStageWidth,
          height: _kStageHeight,
          child: _cellStage(),
        ),
      ),
    );
  }

  /// The source's left "Components Box".
  Widget _componentsBox({required double? cardWidth}) {
    final cards = [
      for (final part in _CellPart.values)
        if (part.index >= _partsPlaced) _partCard(part, cardWidth),
    ];
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelTitle(_tx.s('componentsBox')),
          if (cardWidth == null)
            for (final card in cards)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: card)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: cards,
            ),
          const SizedBox(height: 6),
          Center(child: _hintBox(_tx.s('tapPartHint'))),
        ],
      ),
    );
  }

  Widget _partCard(_CellPart part, double? width) {
    if (part.index < _partsPlaced) return const SizedBox.shrink();
    final enabled = part.index == _partsPlaced;
    final selected = _selectedPart == part;
    Widget card({bool lifted = false}) => _PartCard(
      visual: _partVisual(part),
      label: _tx.s(_partLabelKey(part)),
      selected: selected && !lifted,
      width: width ?? (lifted ? 228 : null),
    );
    final tappable = GestureDetector(
      key: ValueKey('part-${part.name}'),
      onTap: enabled ? () => _selectPart(part) : null,
      child: card(),
    );
    if (!enabled) return Opacity(opacity: 0.5, child: tappable);
    return Draggable<_CellPart>(
      data: part,
      onDragStarted: () => setState(() => _selectedPart = null),
      feedback: Material(color: Colors.transparent, child: card(lifted: true)),
      childWhenDragging: Opacity(opacity: 0.3, child: card()),
      child: tappable,
    );
  }

  /// Small pictures of the parts (the source's component swatches).
  Widget _partVisual(_CellPart part) {
    switch (part) {
      case _CellPart.zinc:
        return Container(
          width: 40,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_rt_Tw.slate400, _rt_Tw.slate200, _rt_Tw.slate500],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            border: Border.all(color: _rt_Tw.slate600, width: 2),
          ),
        );
      case _CellPart.paste:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kYellow700, _kYellow600, _kYellow800],
            ),
            border: Border.all(color: _kYellow900, width: 2),
          ),
        );
      case _CellPart.carbon:
        return Container(
          width: 12,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_rt_Tw.slate900, _rt_Tw.slate700, _rt_Tw.slate900],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
      case _CellPart.cap:
        return Container(
          width: 32,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_rt_Tw.slate200, _rt_Tw.slate400, _rt_Tw.slate500],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            border: Border.all(color: _rt_Tw.slate600, width: 2),
          ),
        );
    }
  }

  /// Assembly zone + test circuit, 360 x 600 design units.
  Widget _cellStage() {
    final circuitReady = _partsPlaced >= 4;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(rect: _kZoneRect, child: _assemblyZone()),
        // Wires lie over the zone so they visibly reach the cap and the can.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: circuitReady ? 1 : 0,
              child: CustomPaint(
                painter: _CircuitLoopPainter(
                  flow: _flow,
                  closed: _switchClosed,
                ),
              ),
            ),
          ),
        ),
        if (circuitReady) ...[
          Positioned(left: 70, top: 470, width: 48, height: 48, child: _bulb()),
          Positioned(
            left: 190,
            top: 474,
            width: 140,
            child: _ChunkyButton(
              key: const ValueKey('btn-switch'),
              label: _tx.s(_switchClosed ? 'openSwitch' : 'closeSwitch'),
              color: _switchClosed ? _rt_Tw.slate500 : _rt_Tw.red500,
              borderColor: _switchClosed ? _rt_Tw.slate700 : _rt_Tw.red700,
              onPressed: _toggleSwitch,
            ),
          ),
        ],
      ],
    );
  }

  Widget _assemblyZone() {
    final dark = _rt_appTheme.isDark;
    return DragTarget<_CellPart>(
      onWillAcceptWithDetails: (details) => details.data.index == _partsPlaced,
      onAcceptWithDetails: (details) => _placePart(details.data),
      builder: (context, candidates, _) {
        final active = candidates.isNotEmpty || _selectedPart != null;
        return GestureDetector(
          key: const ValueKey('assembly-zone'),
          onTap: _tapZone,
          child: CustomPaint(
            foregroundPainter: _DashedRRectPainter(
              color: active ? _rt_Tw.blue500 : _rt_Tw.slate400,
              radius: 24,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: active
                    ? _rt_Tw.blue500.withValues(alpha: 0.1)
                    : (dark
                          ? _rt_Tw.slate800.withValues(alpha: 0.5)
                          : _rt_Tw.slate100),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (_partsPlaced == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _tx.s('dropHint').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: _rt_Tw.slate400,
                          ),
                        ),
                      ),
                    ),
                  // Zinc container with the paste pouring in.
                  Positioned(
                    left: 32,
                    bottom: 40,
                    width: 192,
                    height: 288,
                    child: _appear(_partsPlaced >= 1, _zincCan()),
                  ),
                  // Carbon rod.
                  Positioned(
                    left: 108,
                    bottom: 48,
                    width: 40,
                    height: 256,
                    child: _appear(
                      _partsPlaced >= 3,
                      Container(
                        key: const ValueKey('asm-carbon'),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              _rt_Tw.slate900,
                              _rt_Tw.slate700,
                              _rt_Tw.slate900,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Metal cap.
                  Positioned(
                    left: 96,
                    bottom: 304,
                    width: 64,
                    height: 32,
                    child: _appear(
                      _partsPlaced >= 4,
                      Container(
                        key: const ValueKey('asm-cap'),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _rt_Tw.slate200,
                              _rt_Tw.slate400,
                              _rt_Tw.slate500,
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          border: Border.all(color: _rt_Tw.slate600, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Terminal / paste labels (hidden by the labels toggle).
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -14,
                    child: Center(
                      child: _labelPill(
                        'label-neg',
                        _tx.s('negTerminal'),
                        _rt_Tw.blue600,
                        _partsPlaced >= 1,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 8,
                    child: Center(
                      child: _labelPill(
                        'label-pos',
                        _tx.s('posTerminal'),
                        _rt_Tw.red600,
                        _partsPlaced >= 4,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 226,
                    child: Center(
                      child: _labelPill(
                        'label-paste',
                        _tx.s('pasteLabel'),
                        _rt_Tw.amber600,
                        _pasteLabelShown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _appear(bool visible, Widget child) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: visible ? 1 : 0,
        child: child,
      ),
    );
  }

  Widget _zincCan() {
    return Container(
      key: const ValueKey('asm-zinc'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_rt_Tw.slate400, _rt_Tw.slate200, _rt_Tw.slate500],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        border: Border.all(color: _rt_Tw.slate600, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          key: const ValueKey('paste-fill'),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: _partsPlaced >= 2 ? 280 : 0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                _kYellow900.withValues(alpha: 0.9),
                _kYellow800.withValues(alpha: 0.9),
                _kYellow700.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelPill(String key, String text, Color color, bool shown) {
    return IgnorePointer(
      child: AnimatedOpacity(
        key: ValueKey(key),
        duration: const Duration(milliseconds: 500),
        opacity: shown && _showLabels ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bulb() {
    return AnimatedContainer(
      key: const ValueKey('bulb'),
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _switchClosed ? _rt_Tw.yellow400 : _rt_Tw.slate300,
        border: Border.all(color: _rt_Tw.slate400, width: 4),
        boxShadow: _switchClosed
            ? [
                BoxShadow(
                  color: _rt_Tw.yellow400.withValues(alpha: 0.8),
                  blurRadius: 30,
                  spreadRadius: 6,
                ),
              ]
            : const [],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 14,
          height: 12,
          decoration: const BoxDecoration(
            color: _rt_Tw.slate500,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------- scenario 2 UI --
  Widget _scenario2Layout(double width) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          children: [
            _tabBar(),
            const SizedBox(height: 16),
            switch (_tab) {
              1 => _sortingTab(width),
              2 => _lifespanTab(width),
              _ => _recyclingTab(width),
            },
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    const labels = ['navSort', 'navLife', 'navRecycle'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        for (var i = 1; i <= 3; i++)
          Material(
            color: _tab == i ? _rt_Tw.blue600 : _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: ValueKey('tab-$i'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => _setTab(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Text(
                  _tx.s(labels[i - 1]),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _tab == i ? Colors.white : _rt_Lab.text,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Tab 1: device sorting ---------------------------------------------------
  Widget _sortingTab(double width) {
    final bins = [for (final source in _PowerSource.values) _deviceBin(source)];
    final dark = _rt_appTheme.isDark;
    return Column(
      children: [
        _sectionTitle(_tx.s('sortTitle')),
        const SizedBox(height: 8),
        _hintBox(_tx.s('sortHint')),
        const SizedBox(height: 16),
        if (width >= 640)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final bin in bins)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: bin,
                  ),
                ),
            ],
          )
        else
          Column(
            children: [
              for (final bin in bins)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: bin,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 20),
        Container(
          key: const ValueKey('device-pool'),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? const [_rt_Tw.slate800, _rt_Tw.slate900]
                  : const [_rt_Tw.slate200, _rt_Tw.slate300],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? _rt_Tw.slate700 : _rt_Tw.slate300),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final device in _kDevices)
                if (!_sorted.containsKey(device.id)) _deviceCard(device),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deviceCard(_Device device) {
    final selected = _selectedDevice == device.id;
    return Draggable<_Device>(
      data: device,
      onDragStarted: () => setState(() => _selectedDevice = null),
      feedback: Material(
        color: Colors.transparent,
        child: _DeviceTile(device: device),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _DeviceTile(device: device),
      ),
      child: GestureDetector(
        key: ValueKey('device-${device.id}'),
        onTap: () => _selectDevice(device.id),
        child: _DeviceTile(device: device, selected: selected),
      ),
    );
  }

  Widget _deviceBin(_PowerSource source) {
    final dark = _rt_appTheme.isDark;
    final titleColor = switch (source) {
      _PowerSource.single => dark ? _rt_Tw.blue400 : _rt_Tw.blue600,
      _PowerSource.rechargeable => dark ? _rt_Tw.green400 : _rt_Tw.green600,
      _PowerSource.mains => dark ? _rt_Tw.orange400 : _rt_Tw.orange600,
    };
    final flashing = _flashBin == source;
    return DragTarget<_Device>(
      onWillAcceptWithDetails: (details) =>
          !_sorted.containsKey(details.data.id),
      onAcceptWithDetails: (details) => _dropDevice(details.data, source),
      builder: (context, candidates, _) => GestureDetector(
        key: ValueKey('bin-${source.name}'),
        onTap: () => _tapBin(source),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: flashing
                  ? (dark
                        ? [
                            _kRed900.withValues(alpha: 0.6),
                            _kRed900.withValues(alpha: 0.4),
                          ]
                        : const [_rt_Tw.red100, _kRed200])
                  : (dark
                        ? const [_rt_Tw.slate700, _rt_Tw.slate800]
                        : const [_rt_Tw.slate100, _rt_Tw.slate200]),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidates.isNotEmpty
                  ? _rt_Tw.blue500
                  : (flashing
                        ? _rt_Tw.red500
                        : (dark ? _rt_Tw.slate600 : _rt_Tw.slate300)),
              width: candidates.isNotEmpty || flashing ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _rt_Lab.shadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _tx.s(_binLabelKey(source)),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final device in _kDevices)
                      if (_sorted[device.id] == source)
                        _DeviceTile(
                          key: ValueKey('sorted-${device.id}'),
                          device: device,
                          compact: true,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 2: battery lifespan -------------------------------------------------
  Widget _lifespanTab(double width) {
    final gauge = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _batteryGauge(),
        const SizedBox(height: 12),
        Text(
          '${_batteryPct.floor()}%',
          key: const ValueKey('battery-pct'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: _rt_Lab.text,
          ),
        ),
      ],
    );
    final stats = Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statRow(
            _tx.s('maxHealth'),
            '$_batteryHealth%',
            _rt_Tw.green500,
            'health-val',
          ),
          Divider(height: 22, color: _rt_Lab.border),
          _statRow(
            _tx.s('chargeCycles'),
            '$_cycles',
            _rt_Tw.blue500,
            'cycle-val',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _ChunkyButton(
              key: const ValueKey('btn-use'),
              label: _tx.s('useDevice'),
              color: _rt_Tw.orange500,
              borderColor: _rt_Tw.orange600,
              fontSize: 14,
              onPressed: _useEnabled ? _useBattery : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _ChunkyButton(
              key: const ValueKey('btn-charge'),
              label: _tx.s('plugIn'),
              color: _rt_Tw.green600,
              borderColor: _kGreen800,
              fontSize: 14,
              onPressed: _chargeEnabled ? _chargeBattery : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tx.s('lifeNote'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _rt_Lab.textMuted,
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        _sectionTitle(_tx.s('lifeTitle')),
        const SizedBox(height: 20),
        if (width >= 640)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              gauge,
              const SizedBox(width: 56),
              Flexible(child: stats),
            ],
          )
        else
          Column(children: [gauge, const SizedBox(height: 24), stats]),
      ],
    );
  }

  Widget _statRow(String label, String value, Color color, String valueKey) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.slate500,
            ),
          ),
        ),
        Text(
          value,
          key: ValueKey(valueKey),
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  /// The source's battery: dark case, terminal nub, level fill. The fill
  /// colour follows the level (the source set a colour that its gradient
  /// background hid, so it always looked green).
  Widget _batteryGauge() {
    final level = _batteryPct;
    final colors = level > 50
        ? const [_rt_Tw.green600, _rt_Tw.green500, _rt_Tw.green400]
        : (level > 20
              ? const [_kYellow600, _rt_Tw.yellow500, _rt_Tw.yellow400]
              : const [_rt_Tw.red600, _rt_Tw.red500, _rt_Tw.red400]);
    return SizedBox(
      width: 128,
      height: 272,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 40,
            top: 0,
            width: 48,
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_rt_Tw.slate400, _rt_Tw.slate600],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                border: Border.all(color: _rt_Tw.slate500, width: 2),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 16,
            width: 128,
            height: 256,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_rt_Tw.slate700, _rt_Tw.slate800, _rt_Tw.slate900],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _rt_Tw.slate600, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColoredBox(
                  color: _rt_Tw.slate900.withValues(alpha: 0.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: (level / 100).clamp(0.0, 1.0)),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, fraction, _) => FractionallySizedBox(
                        heightFactor: fraction,
                        widthFactor: 1,
                        child: AnimatedContainer(
                          key: const ValueKey('battery-fill'),
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: colors,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: safe recycling ---------------------------------------------------
  Widget _recyclingTab(double width) {
    final wide = width >= 560;
    final binHeight = wide ? 256.0 : 190.0;
    return Column(
      children: [
        _sectionTitle(_tx.s('recycleTitle')),
        const SizedBox(height: 8),
        _hintBox(_tx.s('recycleHint')),
        const SizedBox(height: 20),
        SizedBox(
          height: 136,
          child: Center(child: _batteryRecycled ? null : _wasteBatteryCard()),
        ),
        const SizedBox(height: 20),
        if (wide)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _wasteBin(_WasteBin.garbage, binHeight),
              const SizedBox(width: 48),
              _wasteBin(_WasteBin.recycle, binHeight),
            ],
          )
        else
          Column(
            children: [
              _wasteBin(_WasteBin.garbage, binHeight),
              const SizedBox(height: 20),
              _wasteBin(_WasteBin.recycle, binHeight),
            ],
          ),
      ],
    );
  }

  Widget _wasteBatteryCard() {
    return Draggable<_WasteToken>(
      data: _WasteToken.battery,
      onDragStarted: () => setState(() => _wasteSelected = false),
      feedback: const Material(color: Colors.transparent, child: _OldBattery()),
      childWhenDragging: const Opacity(opacity: 0.3, child: _OldBattery()),
      child: GestureDetector(
        key: const ValueKey('waste-battery'),
        onTap: _selectWaste,
        child: _OldBattery(selected: _wasteSelected),
      ),
    );
  }

  Widget _wasteBin(_WasteBin bin, double height) {
    final dark = _rt_appTheme.isDark;
    final garbage = bin == _WasteBin.garbage;
    final border = garbage ? _rt_Tw.slate600 : _rt_Tw.green600;
    final labelColor = garbage
        ? (dark ? _rt_Tw.slate400 : _rt_Tw.slate600)
        : (dark ? _kGreen300 : _rt_Tw.green700);
    return DragTarget<_WasteToken>(
      onAcceptWithDetails: (_) => _disposeBattery(bin),
      builder: (context, candidates, _) => GestureDetector(
        key: ValueKey('bin-${bin.name}'),
        onTap: () => _tapWasteBin(bin),
        child: Container(
          width: 200,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: garbage
                  ? (dark
                        ? const [_rt_Tw.slate800, _rt_Tw.slate700]
                        : const [_rt_Tw.slate200, _rt_Tw.slate100])
                  : (dark
                        ? const [_kGreen900, _kGreen800]
                        : const [_rt_Tw.green100, Colors.white]),
            ),
            border: Border.all(
              color: candidates.isNotEmpty ? _rt_Tw.blue500 : border,
              width: 4,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 16,
                child: ColoredBox(
                  color: garbage
                      ? (dark ? _rt_Tw.slate600 : _rt_Tw.slate300)
                      : (dark ? _rt_Tw.green700 : _kGreen300),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      garbage ? Icons.delete : Icons.recycling,
                      size: height > 200 ? 60 : 44,
                      color: garbage ? _rt_Tw.slate500 : _rt_Tw.green600,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _tx.s(garbage ? 'garbage' : 'ewaste').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (garbage && _dangerVisible)
                Positioned.fill(
                  child: Container(
                    key: const ValueKey('danger-overlay'),
                    color: _rt_Tw.red600.withValues(alpha: 0.92),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          size: 36,
                          color: _kYellow300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tx.s('danger'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
    );
  }
}

// ------------------------------------------------------------ small widgets --

/// The source's `.glass-panel` side cards.
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _rt_Lab.borderStrong, width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _rt_Lab.borderStrong)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: _rt_Lab.text,
        ),
      ),
    );
  }
}

/// A dry-cell part in the Components Box (`.part-draggable`, `.part-selected`).
class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.visual,
    required this.label,
    required this.selected,
    this.width,
  });

  final Widget visual;
  final String label;
  final bool selected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      transform: Matrix4.diagonal3Values(
        selected ? 1.05 : 1,
        selected ? 1.05 : 1,
        1,
      ),
      transformAlignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _rt_Tw.blue500 : _rt_Lab.border,
          width: selected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? _rt_Tw.blue500.withValues(alpha: 0.45)
                : _rt_Lab.shadow,
            blurRadius: selected ? 18 : 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          SizedBox(width: 40, height: 56, child: Center(child: visual)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A device card in the pool, or its smaller copy inside a bin.
class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    super.key,
    required this.device,
    this.selected = false,
    this.compact = false,
  });

  final _Device device;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = _rt_appTheme.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: compact ? 72 : 92,
      transform: Matrix4.diagonal3Values(
        selected ? 1.05 : 1,
        selected ? 1.05 : 1,
        1,
      ),
      transformAlignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: compact ? 6 : 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [_rt_Tw.slate600, _rt_Tw.slate700]
              : const [Colors.white, _rt_Tw.slate200],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? _rt_Tw.blue500
              : (dark ? _rt_Tw.slate500 : _rt_Tw.slate300),
          width: selected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? _rt_Tw.blue500.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: selected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            device.icon,
            size: compact ? 22 : 30,
            color: dark ? _rt_Tw.slate200 : _rt_Tw.slate700,
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s(device.nameKey),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: compact ? 9.5 : 11.5,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.text,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

/// The worn-out battery of the recycling tab.
class _OldBattery extends StatelessWidget {
  const _OldBattery({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 84,
      height: 128,
      transform: Matrix4.diagonal3Values(
        selected ? 1.05 : 1,
        selected ? 1.05 : 1,
        1,
      ),
      transformAlignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 26,
            top: 0,
            width: 32,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_rt_Tw.slate300, _rt_Tw.slate500],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
                border: Border.all(color: _rt_Tw.slate700, width: 2),
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 12,
            width: 80,
            height: 112,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_rt_Tw.slate400, _rt_Tw.slate600],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _rt_Tw.blue500 : _rt_Tw.slate700,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? _rt_Tw.blue500.withValues(alpha: 0.5)
                        : Colors.black38,
                    blurRadius: selected ? 20 : 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.battery_alert,
                size: 46,
                color: _rt_Tw.red700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live progress chip under a sidebar exploration.
class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(color, Colors.white, 0.88)!, color),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rt_Lab.tintedBorder(color)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.onTinted(
                  color,
                  Color.lerp(color, Colors.black, 0.3)!,
                ),
              ),
            ),
          ),
        ],
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
    this.textColor = Colors.white,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w800,
  });

  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback? onPressed;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
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

/// One collapsible "Exploration n" card of the source's teacher board
/// (`getStepHTML`): FOCUS, Action and Observation, plus a progress badge.
class _ExplorationTile extends StatelessWidget {
  const _ExplorationTile({
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
    this.badge,
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
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final active = status == _TileStatus.active;
    final done = status == _TileStatus.done;
    final titleColor = active
        ? _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600)
        : _rt_Lab.text;

    final Widget badgeIcon = Container(
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

    return Opacity(
      opacity: active ? 1 : 0.85,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _rt_Lab.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? _rt_Tw.blue500.withValues(alpha: 0.6)
                : _rt_Lab.border,
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
                      badgeIcon,
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
                      focusLabel.toUpperCase(),
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
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$actionLabel ',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _rt_Lab.onTinted(
                                _rt_Tw.blue400,
                                _rt_Tw.blue700,
                              ),
                            ),
                          ),
                          TextSpan(text: action),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: _rt_Lab.text,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$observationLabel ',
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
                    ?badge,
                  ],
                ),
              ),
          ],
        ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          heading.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green600),
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

// --------------------------------------------------------------- painters --

/// Draws [path] as dashes of [dash] separated by [gap], shifted along the
/// path by [phase] (positive = forward).
void _drawDashedPath(
  Canvas canvas,
  Path path,
  Paint paint,
  double dash,
  double gap, {
  double phase = 0,
}) {
  final period = dash + gap;
  for (final metric in path.computeMetrics()) {
    var start = (phase % period) - period;
    while (start < metric.length) {
      final from = math.max(0.0, start);
      final to = math.min(metric.length, start + dash);
      if (to > from) canvas.drawPath(metric.extractPath(from, to), paint);
      start += period;
    }
  }
}

/// Dashed outline of the assembly zone (`.drop-zone`).
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
      8,
      6,
    );
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// Test circuit, in stage units: one closed loop from the metal cap (+)
/// round the left side, through the bulb and the switch, and back up the
/// right side to the zinc can (−). Red dashes flow along it while closed.
class _CircuitLoopPainter extends CustomPainter {
  _CircuitLoopPainter({required this.flow, required this.closed})
    : super(repaint: flow);

  final Animation<double> flow;
  final bool closed;

  static const Offset _positive = Offset(172, 64);
  static const Offset _negative = Offset(276, 300);

  static final Path _loop = Path()
    ..moveTo(_positive.dx, _positive.dy)
    ..lineTo(172, 56)
    ..lineTo(20, 56)
    ..lineTo(20, 494)
    ..lineTo(340, 494)
    ..lineTo(340, 300)
    ..lineTo(_negative.dx, _negative.dy);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _loop,
      Paint()
        ..color = _rt_Tw.slate500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (closed) {
      _drawDashedPath(
        canvas,
        _loop,
        Paint()
          ..color = _rt_Tw.red500
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
        5,
        15,
        phase: flow.value * 20,
      );
    }
    canvas.drawCircle(_positive, 5, Paint()..color = _rt_Tw.red600);
    canvas.drawCircle(_negative, 5, Paint()..color = _rt_Tw.slate700);
  }

  @override
  bool shouldRepaint(_CircuitLoopPainter old) => old.closed != closed;
}

/// canvas-confetti's default palette.
const List<Color> _kConfettiColors = [
  Color(0xFF26CCFF),
  Color(0xFFA25AFD),
  Color(0xFFFF5E7E),
  Color(0xFF88FF5A),
  Color(0xFFFCFF42),
  Color(0xFFFFA62D),
  Color(0xFFFF36FF),
];

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
