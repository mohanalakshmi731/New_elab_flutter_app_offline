// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 4.4: Electromagnets and Lifting Cranes
// Converted from Cl8S-Ch4-A1-Electromagnets_and_Lifting_Cranes_Simulation_Strategy.html
// (Tailwind DOM + CSS 3D tilt + SVG -> Flutter widgets + CustomPainters,
// tilted with Matrix4 perspective, zoom/pan via InteractiveViewer).
//
// Two scenarios chosen from the sidebar. 1: Build & Test Electromagnet --
// wrap at least 10 coil turns, connect the wires and switch ON, lower the
// magnet over 20 iron clips (strength = cells x turns x core factor), cycle a
// compass past End A / End B to read the poles, then experiment with cells,
// turns, core and current direction and Finish. 2: Lifting Crane -- power the
// crane magnet over mixed scrap (only iron/steel lift), move to the steel bin,
// power OFF to release, then diagnose the overheated-coil fault. Observation
// log, current-task HUD, labels / pan toggles, every source string (EN/HI;
// the source's TE block is dropped like every other page) and confetti are
// ported.

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
// Copied from the source's `const i18n = {...}` block (EN + HI; TE dropped).
// Keys marked "added" had no translation in the source.
final _tx = _rt_Tx({
  'en': {
    'title': 'Electromagnet Builder',
    'fullTitle': 'Electromagnet Builder & Lifting Crane',
    'subtitle': 'Class 8: Electricity: Magnetic and Heating Effects',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Electromagnets • Lifting Cranes',
    'tabGuide': 'Lab Guide',
    'obsLog': 'Observation Log',
    'clear': 'Clear',
    'action': 'Action',
    'result': 'Result',
    'noObs': 'No observations yet.',
    'currentTask': 'Current Task',
    'variablesPanel': 'Variables Panel',
    'coreMaterial': 'Core Material',
    'ironNail': 'Iron Nail',
    'paperCylinder': 'Paper Cylinder',
    'coilTurns': 'Coil Turns',
    'numCells': 'Number of Cells',
    'currentDir': 'Current Direction',
    'dirForward': 'A ➔ B (Forward)',
    'dirReverse': 'B ➔ A (Reverse)',
    'endA': 'End A',
    'endB': 'End B',
    'switchOff': 'SWITCH OFF',
    'switchOn': 'SWITCH ON',
    'btnConnect': '1. Connect Wires',
    'wiresConnected': 'Wires Connected',
    'btnTestClips': '2. Test Clips',
    'returnMagnet': 'Return Magnet',
    'btnTestPoles': '3. Test Poles',
    'btnFinish': '4. Finish',
    'measurements': 'Measurements',
    'fieldStrength': 'Field Strength',
    'clipsLifted': 'Clips Lifted',
    'powerOff': 'POWER OFF',
    'powerOn': 'POWER ON',
    'moveToBin': 'MOVE TO BIN',
    'moveToPile': 'MOVE TO PILE',
    'diagnoseFault': '⚠️ DIAGNOSE FAULT',
    'mixedScrap': 'Mixed Scrap',
    'steelBin': 'Steel Bin',
    'scrapIron': 'iron',
    'scrapSteel': 'steel',
    'scrapPlastic': 'plastic',
    'scrapWood': 'wood',
    'scrapAluminium': 'aluminium',
    'selectScenario': 'Select Scenario',
    'scenario1': '1. Build & Test Electromagnet',
    'scenario2': '2. Lifting Crane Simulation',
    'faultTitle': 'System Fault Diagnostic',
    'faultDesc':
        'The crane stopped lifting after long continuous use. The electromagnet coil feels unusually warm.',
    'coilTemp': 'Coil Temp',
    'high': 'HIGH',
    'battery': 'Battery',
    'ok': 'OK',
    'field': 'Field',
    'weak': 'WEAK',
    'observationLbl': 'Observation:',
    'heatingNote':
        'Heating a wire increases its electrical resistance. Higher resistance lowers current, which weakens the magnetic field. You must break the circuit to let it cool.',
    'selectFix': 'Select action to fix:',
    'optA': 'A. Replace battery.',
    'optB': 'B. Open switch to cool coil.',
    'optC': 'C. Reverse current.',
    'success': 'Success!',
    'keyTakeaway': 'Key Takeaway',
    'continue': 'Continue',
    'missionObjective': 'Mission Objective',
    'mission1':
        'Build the electromagnet, investigate its magnetic poles, and discover how current and turns affect its strength.',
    'mission2':
        'Apply the electromagnet principle to a crane that lifts and releases iron/steel objects.',
    'exploration': 'Exploration',
    'focus': 'FOCUS:',
    'actionLbl': 'Action:',
    's1f1': 'Making a coil',
    's1b1':
        'Take around 100 cm long flexible insulated wire and a piece of chart paper. Tightly wind around 50 turns of the insulated wire on the cylinder.',
    's1a1': 'Drag the turns slider to wrap wire around the core.',
    's1f2': 'Completing the circuit',
    's1b2':
        'Connect the two ends of the coil with the terminals of the cell. A current-carrying coil that behaves as a magnet is called an electromagnet.',
    's1a2': 'Click Connect Wires and turn on the switch.',
    's1f3': 'Magnetic Attraction',
    's1b3':
        'Insert an iron nail in the paper cylinder. When an iron nail is inserted in the core of the coil, the coil becomes a stronger magnet. It attracts iron clips.',
    's1a3': 'Click Test Clips to move the electromagnet.',
    's1f4': 'Magnetic Poles',
    's1b4':
        'Place compasses near the two ends. Unlike poles (North–South) attract each other. If the North pole of the compass is attracted to end A, then end A is the South pole.',
    's1a4': 'Click Test Poles to place the compass.',
    's1f5': 'Variables',
    's1b5':
        'Think like a scientist! A battery with more cells gives a larger current, creating a stronger magnetic field. More turns also make it stronger. Its poles can be reversed by changing the direction of the current.',
    's1a5': 'Change cells, turns, and current direction.',
    's2f1': 'Magnetic Separation',
    's2b1':
        'Lifting electromagnets are strong electromagnets hung on cranes. Widely used in factories and scrap yards to move and sort heavy metal items efficiently.',
    's2a1': 'Click POWER ON above the mixed scrap pile.',
    's2f2': 'Releasing the Load',
    's2b2':
        'The crane operator controls the magnet. When the current is switched OFF, the magnetic field disappears, and the objects are released into the bin.',
    's2a2': 'Move crane to the bin and click POWER OFF.',
    's2f3': 'Fault Diagnosis',
    's2b3':
        'Heating a wire increases its electrical resistance. Higher resistance lowers current, which weakens the magnetic field. You must break the circuit to let it cool.',
    's2a3': 'Wait for the fault case and click DIAGNOSE FAULT.',
    'hud1Step1':
        "Step 1 Action: Drag the 'Coil Turns' slider to at least 10 turns to wrap the wire.",
    'hud1Step2':
        "Step 2 Action: Click the '1. Connect Wires' button, then click 'SWITCH ON'.",
    'hud1Step3':
        "Step 3 Action: Click '2. Test Clips' to observe magnetic attraction. Try changing the number of cells or turns!",
    'hud1Step4':
        "Step 4 Action: Click '3. Test Poles' to place the compass. Observe the needle.",
    'hud1Step5':
        "Step 5 Action: Experiment with the 'Number of Cells' slider, 'Coil Turns' slider, or 'Current Direction' button to observe their effects. Then click '4. Finish' to complete the scenario.",
    'hud2Step1':
        "Step 1 Action: Click 'POWER ON' above the mixed scrap pile to energize the electromagnet.",
    'hud2Step2':
        "Step 2 Action: Click 'MOVE TO BIN', and then click 'POWER OFF' to release the load into the bin.",
    'hud2Step3':
        "Step 3 Action: Wait for the fault to occur, then click 'DIAGNOSE FAULT' and select the correct solution.",
    'hudSwitchOn': "Action required: Click 'SWITCH ON' to energize the coil.",
    'hudCircuitOff': "Circuit is OFF. Click 'SWITCH ON' to restore magnetism.",
    'hudTestEither':
        "Action required: Click '2. Test Clips' to test strength or '3. Test Poles' to test poles.",
    'hudPaper':
        'Notice that without the iron core, the strength is very weak and few/no clips are lifted.',
    'hudCompassA':
        "Action required: Compass is near End A. Notice the needle deflection. Click '3. Test Poles' again.",
    'hudCompassB':
        'Action required: Compass is near End B. The opposite pole is shown. Click again to center.',
    'hudAttracted':
        "Action required: Magnetic items are attracted! Click 'MOVE TO BIN'.",
    'hudReleased': 'Success! Objects released into the steel bin!',
    'hudFault':
        "ACTION REQUIRED: Crane stopped responding! Click 'DIAGNOSE FAULT'.",
    'hudDroppedBack': 'Objects dropped back. Power ON to lift again.',
    'hudAtBin':
        "Action required: Crane moved to bin. Click 'POWER OFF' to release the load.",
    'hudAtPile':
        "Action required: Crane moved to pile. Click 'POWER ON' to lift.",
    'wrapFirst': 'Wrap at least 10 turns first!',
    'summary1':
        "Excellent! You observed that an electromagnet's strength depends on the core, number of turns, and current. Its poles can be identified with a compass and reversed by changing the current direction.",
    'summary2':
        'Correct! By opening the switch, you break the circuit. The coil will stop generating heat and cool down, restoring its normal resistance and magnetic strength.',
    'incorrect': 'Incorrect. Think about how to solve the HIGH coil temp.',
    'obsTurnedOn': 'Turned ON',
    'obsTurnedOff': 'Turned OFF',
    'obsChangedDir': 'Changed Direction',
    'obsTestedStrength': 'Tested Strength',
    'obsTestedPoles': 'Tested Poles',
    'obsSetVars': 'Set Variables',
    'obsConnectedCircuit': 'Connected Circuit',
    'obsToggleSwitch': 'Toggle Switch',
    'obsWiresToBattery': 'Wires connected to battery',
    'obsForward': 'Forward (A ➔ B)',
    'obsReverse': 'Reverse (B ➔ A)',
    'right': 'Right',
    'left': 'Left',
    'obsVarsResult': '{t} turns, {c} cells',
    'obsLiftedClips': 'Lifted {n} clips (Strength: {s}%)',
    'obsCompassA': 'Compass at End A (Needle: {d})',
    'obsCompassB': 'Compass at End B (Needle: {d})',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
  },
  'hi': {
    'title': 'इलेक्ट्रोमैग्नेट बिल्डर',
    'fullTitle': 'इलेक्ट्रोमैग्नेट बिल्डर और लिफ्टिंग क्रेन',
    'subtitle': 'कक्षा 8: विद्युत: चुंबकीय और ऊष्मीय प्रभाव',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'विद्युत चुंबक • लिफ्टिंग क्रेन', // added
    'tabGuide': 'लैब गाइड', // added
    'obsLog': 'अवलोकन लॉग',
    'clear': 'साफ करें',
    'action': 'कार्रवाई',
    'result': 'परिणाम',
    'noObs': 'अभी तक कोई अवलोकन नहीं।',
    'currentTask': 'वर्तमान कार्य',
    'variablesPanel': 'चर पैनल',
    'coreMaterial': 'कोर सामग्री',
    'ironNail': 'लोहे की कील',
    'paperCylinder': 'कागज का सिलेंडर',
    'coilTurns': 'कुंडल के फेरे',
    'numCells': 'सेल की संख्या',
    'currentDir': 'विद्युत धारा की दिशा',
    'dirForward': 'A ➔ B (आगे)',
    'dirReverse': 'B ➔ A (उलटा)',
    'endA': 'सिरा A',
    'endB': 'सिरा B',
    'switchOff': 'स्विच ऑफ',
    'switchOn': 'स्विच ऑन',
    'btnConnect': '1. तार जोड़ें',
    'wiresConnected': 'तार जुड़ गए', // added
    'btnTestClips': '2. क्लिप परीक्षण',
    'returnMagnet': 'चुंबक वापस लाएँ', // added
    'btnTestPoles': '3. ध्रुव परीक्षण',
    'btnFinish': '4. समाप्त करें',
    'measurements': 'माप',
    'fieldStrength': 'क्षेत्र शक्ति',
    'clipsLifted': 'उठाई गई क्लिप',
    'powerOff': 'पावर ऑफ',
    'powerOn': 'पावर ऑन',
    'moveToBin': 'डस्टबिन में ले जाएँ',
    'moveToPile': 'ढेर पर ले जाएँ', // added
    'diagnoseFault': '⚠️ त्रुटि का निदान करें',
    'mixedScrap': 'मिश्रित कबाड़',
    'steelBin': 'स्टील बिन',
    'scrapIron': 'लोहा', // added
    'scrapSteel': 'स्टील', // added
    'scrapPlastic': 'प्लास्टिक', // added
    'scrapWood': 'लकड़ी', // added
    'scrapAluminium': 'एल्युमिनियम', // added
    'selectScenario': 'परिदृश्य चुनें',
    'scenario1': '1. इलेक्ट्रोमैग्नेट बनाएँ और परखें',
    'scenario2': '2. लिफ्टिंग क्रेन सिमुलेशन',
    'faultTitle': 'सिस्टम त्रुटि निदान',
    'faultDesc':
        'लंबे समय तक लगातार उपयोग के बाद क्रेन ने उठाना बंद कर दिया। इलेक्ट्रोमैग्नेट कुंडल असामान्य रूप से गर्म लगता है।',
    'coilTemp': 'कुंडल का तापमान',
    'high': 'उच्च',
    'battery': 'बैटरी',
    'ok': 'ठीक',
    'field': 'क्षेत्र', // added
    'weak': 'कमजोर',
    'observationLbl': 'अवलोकन:',
    'heatingNote':
        'तार को गर्म करने से उसका विद्युत प्रतिरोध बढ़ जाता है। उच्च प्रतिरोध धारा को कम करता है, जिससे चुंबकीय क्षेत्र कमजोर हो जाता है। इसे ठंडा होने देने के लिए आपको परिपथ को तोड़ना होगा।',
    'selectFix': 'ठीक करने के लिए कार्रवाई चुनें:',
    'optA': 'A. बैटरी बदलें।',
    'optB': 'B. कुंडल को ठंडा करने के लिए स्विच खोलें।',
    'optC': 'C. धारा उलट दें।',
    'success': 'सफलता!',
    'keyTakeaway': 'मुख्य निष्कर्ष',
    'continue': 'जारी रखें',
    'missionObjective': 'मिशन का उद्देश्य',
    'mission1':
        'इलेक्ट्रोमैग्नेट बनाएं, इसके चुंबकीय ध्रुवों की जांच करें, और पता लगाएं कि विद्युत धारा और टर्न इसकी शक्ति को कैसे प्रभावित करते हैं।',
    'mission2':
        'लोहे/स्टील की वस्तुओं को उठाने और छोड़ने वाली क्रेन पर इलेक्ट्रोमैग्नेट के सिद्धांत को लागू करें।',
    'exploration': 'अन्वेषण',
    'focus': 'ध्यान दें:',
    'actionLbl': 'कार्रवाई:',
    's1f1': 'कुंडल बनाना',
    's1b1':
        'लगभग 100 सेमी लंबा लचीला इंसुलेटेड तार और चार्ट पेपर का एक टुकड़ा लें। सिलेंडर पर इंसुलेटेड तार के लगभग 50 टर्न कसकर लपेटें।',
    's1a1': 'कोर के चारों ओर तार लपेटने के लिए टर्न स्लाइडर को खींचें।',
    's1f2': 'परिपथ पूरा करना',
    's1b2':
        'कुंडल के दोनों सिरों को सेल के टर्मिनलों से जोड़ें। एक धारावाही कुंडल जो चुंबक की तरह व्यवहार करता है, इलेक्ट्रोमैग्नेट कहलाता है।',
    's1a2': "'कनेक्ट वायर्स' पर क्लिक करें और स्विच चालू करें।",
    's1f3': 'चुंबकीय आकर्षण',
    's1b3':
        'कागज के सिलेंडर में लोहे की कील डालें। जब कुंडल के कोर में लोहे की कील डाली जाती है, तो कुंडल एक मजबूत चुंबक बन जाता है। यह लोहे की क्लिप को आकर्षित करता है।',
    's1a3': "इलेक्ट्रोमैग्नेट को ले जाने के लिए 'क्लिप्स परखें' पर क्लिक करें।",
    's1f4': 'चुंबकीय ध्रुव',
    's1b4':
        'दोनों सिरों के पास कंपास रखें। असमान ध्रुव (उत्तर-दक्षिण) एक दूसरे को आकर्षित करते हैं। यदि कंपास का उत्तरी ध्रुव सिरा A की ओर आकर्षित होता है, तो सिरा A दक्षिणी ध्रुव है।',
    's1a4': "कंपास रखने के लिए 'पोल्स परखें' पर क्लिक करें।",
    's1f5': 'चर',
    's1b5':
        'एक वैज्ञानिक की तरह सोचें! अधिक सेल वाली बैटरी अधिक धारा देती है, जिससे एक मजबूत चुंबकीय क्षेत्र बनता है। अधिक टर्न भी इसे मजबूत बनाते हैं। धारा की दिशा बदलकर इसके ध्रुवों को उलटा जा सकता है।',
    's1a5': 'सेल, टर्न और धारा की दिशा बदलें।',
    's2f1': 'चुंबकीय पृथक्करण',
    's2b1':
        'लिफ्टिंग इलेक्ट्रोमैग्नेट क्रेन पर लटके मजबूत इलेक्ट्रोमैग्नेट होते हैं। भारी धातु की वस्तुओं को कुशलतापूर्वक ले जाने और छांटने के लिए कारखानों और कबाड़खानों में व्यापक रूप से उपयोग किया जाता है।',
    's2a1': "मिश्रित कबाड़ के ढेर के ऊपर 'पावर ऑन' पर क्लिक करें।",
    's2f2': 'भार छोड़ना',
    's2b2':
        'क्रेन ऑपरेटर चुंबक को नियंत्रित करता है। जब करंट बंद कर दिया जाता है, तो चुंबकीय क्षेत्र गायब हो जाता है, और वस्तुएं बिन में गिर जाती हैं।',
    's2a2': "क्रेन को बिन तक ले जाएं और 'पावर ऑफ' पर क्लिक करें।",
    's2f3': 'त्रुटि निदान',
    's2b3':
        'तार को गर्म करने से उसका विद्युत प्रतिरोध बढ़ जाता है। उच्च प्रतिरोध धारा को कम करता है, जिससे चुंबकीय क्षेत्र कमजोर हो जाता है। इसे ठंडा होने देने के लिए आपको परिपथ को तोड़ना होगा।',
    's2a3':
        "त्रुटि मामले की प्रतीक्षा करें और 'त्रुटि का निदान करें' पर क्लिक करें।",
    'hud1Step1':
        "चरण 1 कार्रवाई: तार लपेटने के लिए 'कॉइल टर्न्स' स्लाइडर को कम से कम 10 टर्न तक खींचें।",
    'hud1Step2':
        "चरण 2 कार्रवाई: '1. कनेक्ट वायर्स' बटन पर क्लिक करें, फिर 'स्विच ऑन' पर क्लिक करें।",
    'hud1Step3':
        "चरण 3 कार्रवाई: चुंबकीय आकर्षण देखने के लिए '2. क्लिप्स परखें' पर क्लिक करें। सेल या टर्न की संख्या बदलने का प्रयास करें!",
    'hud1Step4':
        "चरण 4 कार्रवाई: कंपास रखने के लिए '3. पोल्स परखें' पर क्लिक करें। सूई का निरीक्षण करें।",
    'hud1Step5':
        "चरण 5 कार्रवाई: उनके प्रभावों को देखने के लिए 'सेल की संख्या' स्लाइडर, 'कॉइल टर्न्स' स्लाइडर, या 'करंट डायरेक्शन' बटन के साथ प्रयोग करें। फिर परिदृश्य को पूरा करने के लिए '4. समाप्त करें' पर क्लिक करें।",
    'hud2Step1':
        "चरण 1 कार्रवाई: इलेक्ट्रोमैग्नेट को सक्रिय करने के लिए मिश्रित स्क्रैप पाइल के ऊपर 'पावर ऑन' पर क्लिक करें।",
    'hud2Step2':
        "चरण 2 कार्रवाई: 'डस्टबिन में ले जाएँ' पर क्लिक करें, और फिर भार को बिन में छोड़ने के लिए 'पावर ऑफ' पर क्लिक करें।",
    'hud2Step3':
        "चरण 3 कार्रवाई: त्रुटि होने की प्रतीक्षा करें, फिर 'त्रुटि का निदान करें' पर क्लिक करें और सही समाधान चुनें।",
    'hudSwitchOn':
        "कार्रवाई आवश्यक: कुंडल को सक्रिय करने के लिए 'स्विच ऑन' पर क्लिक करें।",
    'hudCircuitOff':
        "परिपथ बंद है। चुंबकत्व को बहाल करने के लिए 'स्विच ऑन' पर क्लिक करें।",
    'hudTestEither':
        "कार्रवाई आवश्यक: शक्ति का परीक्षण करने के लिए '2. क्लिप परखें' या ध्रुवों का परीक्षण करने के लिए '3. पोल परखें' पर क्लिक करें।",
    'hudPaper':
        'ध्यान दें कि लोहे के कोर के बिना, शक्ति बहुत कमजोर होती है और कुछ/कोई क्लिप नहीं उठाई जाती है।',
    'hudCompassA':
        "कार्रवाई आवश्यक: कंपास सिरा ए के पास है। सुई के विक्षेपण पर ध्यान दें। फिर से '3. पोल परखें' पर क्लिक करें।",
    'hudCompassB':
        'कार्रवाई आवश्यक: कंपास सिरा बी के पास है। विपरीत ध्रुव दिखाया गया है। केंद्र में वापस जाने के लिए फिर से क्लिक करें।',
    'hudAttracted':
        "कार्रवाई आवश्यक: चुंबकीय वस्तुएं आकर्षित होती हैं! 'बिन में ले जाएं' पर क्लिक करें।",
    'hudReleased': 'सफलता! वस्तुओं को स्टील बिन में छोड़ दिया गया!',
    'hudFault':
        "कार्रवाई आवश्यक: क्रेन ने काम करना बंद कर दिया! 'त्रुटि का निदान करें' पर क्लिक करें।",
    'hudDroppedBack':
        'वस्तुएं वापस गिर गईं। फिर से उठाने के लिए पावर चालू करें।',
    'hudAtBin':
        "कार्रवाई आवश्यक: क्रेन बिन में चली गई। भार छोड़ने के लिए 'पावर ऑफ' पर क्लिक करें।",
    'hudAtPile':
        "कार्रवाई आवश्यक: क्रेन ढेर में चली गई। उठाने के लिए 'पावर ऑन' पर क्लिक करें।",
    'wrapFirst': 'पहले कम से कम 10 टर्न लपेटें!',
    'summary1':
        'बहुत बढ़िया! आपने देखा कि इलेक्ट्रोमैग्नेट की शक्ति कोर, टर्न की संख्या और धारा पर निर्भर करती है। इसके ध्रुवों को कंपास से पहचाना जा सकता है और धारा की दिशा बदलकर उलटा जा सकता है।',
    'summary2':
        'सही! स्विच खोलकर, आप परिपथ को तोड़ते हैं। कुंडल गर्मी पैदा करना बंद कर देगा और ठंडा हो जाएगा, जिससे इसका सामान्य प्रतिरोध और चुंबकीय शक्ति बहाल हो जाएगी।',
    'incorrect': 'गलत। सोचें कि उच्च कुंडल तापमान को कैसे हल किया जाए।',
    'obsTurnedOn': 'चालू किया',
    'obsTurnedOff': 'बंद किया',
    'obsChangedDir': 'दिशा बदल दी गई',
    'obsTestedStrength': 'शक्ति का परीक्षण किया',
    'obsTestedPoles': 'ध्रुवों का परीक्षण किया',
    'obsSetVars': 'चर सेट करें',
    'obsConnectedCircuit': 'परिपथ जोड़ा गया',
    'obsToggleSwitch': 'स्विच टॉगल किया',
    'obsWiresToBattery': 'बैटरी से जुड़े तार',
    'obsForward': 'आगे (A ➔ B)',
    'obsReverse': 'पीछे (B ➔ A)',
    'right': 'दाएं',
    'left': 'बाएं',
    'obsVarsResult': '{t} टर्न, {c} सेल',
    'obsLiftedClips': 'उठाई गई {n} क्लिप (शक्ति: {s}%)',
    'obsCompassA': 'सिरा A पर कंपास (सूई: {d})',
    'obsCompassB': 'सिरा B पर कंपास (सूई: {d})',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
  },
});

/// `_tx.s(key)` with `{name}` placeholders filled from [args].
String _fmt(String key, Map<String, Object> args) {
  var text = _tx.s(key);
  args.forEach((name, value) => text = text.replaceAll('{$name}', '$value'));
  return text;
}

// ------------------------------------------------------------- constants ----

/// Design sizes of the two stages (the source's fixed-size scale containers).
const double _kSc1Width = 450;
const double _kSc1Height = 350;
const double _kSc2Width = 800;
const double _kSc2Height = 500;

/// Number of paper clips in the source's `initClips` pile.
const int _kClipCount = 20;

/// Scenario 2 geometry, in stage units (the source's Tailwind offsets plus
/// the 8 px stage border).
const double _kCraneHomeX = 112; // crane magnet centre over the scrap pile
const double _kCraneTravel =
    488; // ... and the move that centres it over the bin
const double _kMagnetFaceY = 360; // underside of the crane magnet
const Rect _kPileRect = Rect.fromLTWH(72, 284, 224, 128);
const Rect _kBinRect = Rect.fromLTWH(504, 284, 192, 128);

/// The source's `scrapItems`: (label key, colour, magnetic).
const List<(String, Color, bool)> _kScrapDefinitions = [
  ('scrapIron', _rt_Tw.slate500, true),
  ('scrapIron', _rt_Tw.slate600, true),
  ('scrapSteel', _rt_Tw.slate400, true),
  ('scrapPlastic', _rt_Tw.red500, false),
  ('scrapWood', _rt_Tw.amber700, false),
  ('scrapAluminium', _rt_Tw.slate300, false),
  ('scrapSteel', _rt_Tw.slate400, true),
];

/// Where attached scrap hangs below the crane magnet (centre offsets).
const List<(double, double)> _kAttachOffsets = [
  (-24, 12),
  (24, 12),
  (0, 18),
  (-12, 36),
  (12, 36),
  (0, 50),
];

/// Where released scrap rests in the bin (centre x offset, top offset).
const List<(double, double)> _kBinOffsets = [
  (-54, 0),
  (-18, 4),
  (18, 0),
  (54, 4),
  (-36, -6),
  (36, -6),
  (0, -8),
];

const Color _kPurple800 = Color(0xFF6B21A8);
const Color _kGreen800 = Color(0xFF166534);
const Color _kRed800 = Color(0xFF991B1B);
const Color _kYellow600 = Color(0xFFCA8A04);
const Color _kYellow700 = Color(0xFFA16207);
const Color _kYellow800 = Color(0xFF854D0E);
const Color _kAmber900 = Color(0xFF78350F);
const Color _kAmber300 = Color(0xFFFCD34D);

// ------------------------------------------------------------------ model ----

enum _CoreMaterial { iron, paper }

enum _CompassSpot { center, endA, endB }

enum _ScrapSpot { pile, attached, bin }

class _ScrapItem {
  _ScrapItem(this.labelKey, this.color, this.magnetic);

  final String labelKey;
  final Color color;
  final bool magnetic;

  /// Rest position inside the pile and its random rotation (source dataset).
  double pileX = 0;
  double pileY = 0;
  double rotation = 0;

  /// Small tilt used once the item is stuck to the magnet or lies in the bin.
  double tilt = 0;

  _ScrapSpot spot = _ScrapSpot.pile;

  /// Order among the attached / binned items, for stacking.
  int slot = 0;
}

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result);

  final String Function() action;
  final String Function() result;
}

// ------------------------------------------------------------------- page ----

class Cl8Ch04A4ElectromagnetsLiftingCranesPage extends StatefulWidget {
  const Cl8Ch04A4ElectromagnetsLiftingCranesPage({super.key});

  @override
  State<Cl8Ch04A4ElectromagnetsLiftingCranesPage> createState() =>
      _Cl8Ch04A4ElectromagnetsLiftingCranesPageState();
}

class _Cl8Ch04A4ElectromagnetsLiftingCranesPageState
    extends State<Cl8Ch04A4ElectromagnetsLiftingCranesPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.5,
    max: 3.0,
  );
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();

  /// Current flow along the wire (the source's 0.5 s `flow` keyframes).
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  /// Bounce of the DIAGNOSE FAULT button (`animate-bounce`).
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  final List<Timer> _timers = [];

  // Shared (source `State`).
  int _scenario = 1;
  int _step = 1;
  String _hudKey = 'hud1Step1';
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  Size _stageViewport = Size.zero;

  // Scenario 1 (source `sc1State`).
  _CoreMaterial _core = _CoreMaterial.iron;
  int _turns = 0;
  int _cells = 1;
  bool _dirForward = true;
  bool _connected = false;
  bool _switchOn = false;
  bool _magnetDown = false;
  _CompassSpot _compass = _CompassSpot.center;
  int _clipsLifted = 0;
  final List<double> _clipRestRotation = [];
  final List<double> _clipLiftRotation = [];

  // Scenario 2 (source `sc2State`).
  bool _craneOn = false;
  bool _craneAtBin = false;
  bool _moveEnabled = false;
  bool _faultTriggered = false;
  bool _faultVisible = false;
  final List<_ScrapItem> _scrap = [];

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
    _resetScenario1();
    _resetScenario2();
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
    _flow.dispose();
    _bounce.dispose();
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
  /// The source's `calculateStrength`, in percent.
  int get _strength {
    if (!_switchOn || _turns == 0) return 0;
    final coreFactor = _core == _CoreMaterial.iron ? 1.0 : 0.1;
    const maxStrength = 3 * 50 * 1.0;
    return (_cells * _turns * coreFactor / maxStrength * 100).round();
  }

  /// Compass needle angle in degrees (0 = north tip up).
  ///
  /// Forward current makes End A a South pole and End B a North pole. The
  /// north tip points along the field: into End A beside it, away from End B
  /// beside it, and from B back towards A above the middle of the coil.
  double get _needleDegrees {
    if (_strength <= 0) return 0;
    final pointsRight = _compass != _CompassSpot.center;
    return pointsRight == _dirForward ? 90 : -90;
  }

  String get _stepHudKey => 'hud${_scenario}Step$_step';

  /// The source's `progressStep`.
  void _progressStep() {
    _rt_playSfx(_rt_Sfx.correct);
    setState(() {
      _step++;
      _toggledTiles.clear();
      _hudKey = _stepHudKey;
    });
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

  /// The source's `resetSc1` (state only; call inside `setState`).
  void _resetScenario1() {
    _core = _CoreMaterial.iron;
    _turns = 0;
    _cells = 1;
    _dirForward = true;
    _connected = false;
    _switchOn = false;
    _magnetDown = false;
    _compass = _CompassSpot.center;
    _clipsLifted = 0;
    _clipRestRotation
      ..clear()
      ..addAll(List.generate(_kClipCount, (_) => _random.nextDouble() * 180));
    _clipLiftRotation
      ..clear()
      ..addAll(
        List.generate(_kClipCount, (_) => _random.nextDouble() * 90 - 45),
      );
    _flow
      ..stop()
      ..value = 0;
  }

  /// The source's `resetSc2` (state only; call inside `setState`).
  void _resetScenario2() {
    _craneOn = false;
    _craneAtBin = false;
    _moveEnabled = false;
    _faultTriggered = false;
    _faultVisible = false;
    _bounce
      ..stop()
      ..value = 0;
    _scrap
      ..clear()
      ..addAll([
        for (final (labelKey, color, magnetic) in _kScrapDefinitions)
          _ScrapItem(labelKey, color, magnetic)
            ..pileX = _random.nextDouble() * 160 + 10
            ..pileY = _random.nextDouble() * 40 + 60
            ..rotation = _random.nextDouble() * 360
            ..tilt = _random.nextDouble() * 30 - 15,
      ]);
  }

  /// The source's `initScenario` / `changeScenario`.
  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() {
      _scenario = scenario;
      _step = 1;
      _toggledTiles.clear();
      _hudKey = _stepHudKey;
      _resetScenario1();
      _resetScenario2();
    });
    _zoom.reset();
  }

  /// The source's `triggerSoftReset` (minus the shutter, which the shell owns).
  void _restart() {
    _changeScenario(1);
    setState(() {
      _log.clear();
      _showLabels = true;
      _panMode = false;
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

  /// The source's `showSummary` (Key Takeaway modal + confetti).
  void _showSummary(String text, VoidCallback next) {
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _rt_Tw.green600,
      buttonLabel: _tx.s('continue'),
      body: _SummaryBody(heading: _tx.s('keyTakeaway'), text: text),
      onConfirm: () {
        _rt_playSfx(_rt_Sfx.click);
        next();
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
  /// The source's `animateClips`: clip count follows the magnet and field.
  /// With [commit], also plays the lift sound, logs the test and shows the
  /// paper-core notice (live slider drags only refresh the count).
  void _refreshClips({bool commit = false}) {
    final strength = _strength;
    if (_magnetDown && strength > 0) {
      final lifted = (strength / 100 * _kClipCount).round();
      _clipsLifted = lifted;
      if (commit) {
        if (lifted > 0) _rt_playSfx(_rt_Sfx.magic);
        if (_step >= 3) {
          _pushLog(
            () => _tx.s('obsTestedStrength'),
            () => _fmt('obsLiftedClips', {'n': lifted, 's': strength}),
          );
        }
      }
    } else {
      _clipsLifted = 0;
    }
    if (commit && _magnetDown && _core == _CoreMaterial.paper && _switchOn) {
      _hudKey = 'hudPaper';
    }
  }

  /// The source's `logVariableChange`; call inside `setState`.
  void _logVariables() {
    if (_step < 3) return;
    final turns = _turns;
    final cells = _cells;
    _pushLog(
      () => _tx.s('obsSetVars'),
      () => _fmt('obsVarsResult', {'t': turns, 'c': cells}),
    );
  }

  void _selectCore(_CoreMaterial core) {
    if (core == _core) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _core = core;
      _refreshClips(commit: true);
    });
  }

  void _onTurnsChanged(double value) => setState(() {
    _turns = value.round();
    _refreshClips();
  });

  void _onTurnsReleased(double value) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _turns = value.round());
    if (_turns >= 10 && _step == 1) _progressStep();
    setState(() {
      _refreshClips(commit: true);
      _logVariables();
    });
  }

  void _onCellsChanged(double value) => setState(() {
    _cells = value.round();
    _refreshClips();
  });

  void _onCellsReleased(double value) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _cells = value.round();
      _refreshClips(commit: true);
      _logVariables();
    });
  }

  void _toggleDirection() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _dirForward = !_dirForward;
      _refreshClips(commit: true);
      if (_step >= 4) {
        final forward = _dirForward;
        _pushLog(
          () => _tx.s('obsChangedDir'),
          () => _tx.s(forward ? 'obsForward' : 'obsReverse'),
        );
      }
    });
  }

  void _connectCircuit() {
    if (_turns < 10) {
      _showMessage(_tx.s('wrapFirst'), error: true);
      return;
    }
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _connected = true;
      _pushLog(
        () => _tx.s('obsConnectedCircuit'),
        () => _tx.s('obsWiresToBattery'),
      );
      _hudKey = 'hudSwitchOn';
    });
  }

  void _toggleSwitch() {
    if (!_connected) return;
    final on = !_switchOn;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _switchOn = on;
      _pushLog(
        () => _tx.s('obsToggleSwitch'),
        () => _tx.s(on ? 'obsTurnedOn' : 'obsTurnedOff'),
      );
    });
    if (on) {
      if (_step == 2) _progressStep();
      _flow.repeat();
    } else {
      _flow.stop();
    }
    setState(() {
      _hudKey = on ? 'hudTestEither' : 'hudCircuitOff';
      _refreshClips(commit: true);
    });
  }

  /// The source's `moveMagnet` (Test Clips / Return Magnet).
  void _moveMagnet() {
    _rt_playSfx(_rt_Sfx.tap);
    if (!_magnetDown) {
      setState(() => _magnetDown = true);
      if (_step == 3) _progressStep();
      _after(500, () => setState(() => _refreshClips(commit: true)));
    } else {
      setState(() => _magnetDown = false);
      _after(100, () => setState(() => _refreshClips(commit: true)));
    }
  }

  /// The source's `moveCompass`: centre -> End A -> End B -> centre.
  void _moveCompass() {
    _rt_playSfx(_rt_Sfx.tap);
    final forward = _dirForward;
    setState(() {
      switch (_compass) {
        case _CompassSpot.center:
          _compass = _CompassSpot.endA;
          _hudKey = 'hudCompassA';
          if (_step >= 4) {
            _pushLog(
              () => _tx.s('obsTestedPoles'),
              () =>
                  _fmt('obsCompassA', {'d': _tx.s(forward ? 'right' : 'left')}),
            );
          }
        case _CompassSpot.endA:
          _compass = _CompassSpot.endB;
          _hudKey = 'hudCompassB';
          if (_step >= 4) {
            _pushLog(
              () => _tx.s('obsTestedPoles'),
              () =>
                  _fmt('obsCompassB', {'d': _tx.s(forward ? 'right' : 'left')}),
            );
          }
        case _CompassSpot.endB:
          _compass = _CompassSpot.center;
          if (_step == 4) {
            _after(1000, () {
              if (_step == 4) _progressStep();
            });
          }
      }
      _refreshClips(commit: true);
    });
  }

  void _finishScenario1() {
    _rt_playSfx(_rt_Sfx.click);
    _showSummary(_tx.s('summary1'), () => _changeScenario(2));
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// The source's `toggleCranePower`.
  void _toggleCranePower() {
    final on = !_craneOn;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _craneOn = on);

    if (on && !_craneAtBin) {
      var lifted = false;
      setState(() {
        var slot = 0;
        for (final item in _scrap) {
          if (item.magnetic && item.spot == _ScrapSpot.pile) {
            item
              ..spot = _ScrapSpot.attached
              ..slot = slot++;
            lifted = true;
          }
        }
        _moveEnabled = true;
        _hudKey = 'hudAttracted';
      });
      if (lifted) _rt_playSfx(_rt_Sfx.magic);
      if (_step == 1) {
        _after(1500, () {
          if (_step == 1) _progressStep();
        });
      }
    } else if (!on && _craneAtBin) {
      var dropped = false;
      setState(() {
        var slot = _scrap.where((item) => item.spot == _ScrapSpot.bin).length;
        for (final item in _scrap) {
          if (item.spot == _ScrapSpot.attached) {
            item
              ..spot = _ScrapSpot.bin
              ..slot = slot++;
            dropped = true;
          }
        }
        _hudKey = 'hudReleased';
      });
      if (dropped) _rt_playSfx(_rt_Sfx.pop);
      _shell.showToast(_tx.s('hudReleased'), icon: Icons.check_circle);
      if (_step == 2) _progressStep();
      if (!_faultTriggered) {
        _faultTriggered = true;
        _after(2000, () {
          setState(() {
            _faultVisible = true;
            _hudKey = 'hudFault';
          });
          _bounce.repeat(reverse: true);
          _rt_playSfx(_rt_Sfx.wrong);
        });
      }
    } else if (!on && !_craneAtBin) {
      setState(() {
        _resetScenario2();
        _hudKey = 'hudDroppedBack';
      });
      _rt_playSfx(_rt_Sfx.pop);
    }
  }

  /// The source's `moveCrane`.
  void _moveCrane() {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      if (!_craneAtBin) {
        _craneAtBin = true;
        _hudKey = 'hudAtBin';
      } else {
        _craneAtBin = false;
        _moveEnabled = false;
        _hudKey = 'hudAtPile';
      }
    });
  }

  /// The source's fault modal + `resolveFault`.
  Future<void> _showFaultDialog() async {
    _rt_playSfx(_rt_Sfx.wrong);
    final wrongPicks = <String>{};
    final solved = await _rt_showShellPopup(
      context,
      title: _tx.s('faultTitle'),
      icon: Icons.warning_amber_rounded,
      color: _rt_Tw.red600,
      actions: const [],
      body: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Widget option(String id, String labelKey, bool correct) =>
              _rt_ChoiceButton(
                key: ValueKey('fault-opt-$id'),
                label: _tx.s(labelKey),
                state: wrongPicks.contains(id)
                    ? _rt_ChoiceState.wrong
                    : _rt_ChoiceState.idle,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.click);
                  if (correct) {
                    Navigator.of(dialogContext).pop(true);
                  } else {
                    setDialogState(() => wrongPicks.add(id));
                    _showMessage(_tx.s('incorrect'), error: true);
                  }
                },
              );
          return _FaultBody(
            options: [
              option('a', 'optA', false),
              option('b', 'optB', true),
              option('c', 'optC', false),
            ],
          );
        },
      ),
    );
    if (!mounted || !solved) return;
    _after(
      300,
      () => _showSummary(_tx.s('summary2'), () => _changeScenario(1)),
    );
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
          title: _tx.s('fullTitle'),
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
            icon: Icons.electric_bolt,
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
                      : () {
                          _rt_playSfx(_rt_Sfx.click);
                          _changeScenario(scenario);
                        },
                ),
              const SizedBox(height: 10),
              for (var i = 1; i <= tileCount; i++)
                _ExplorationTile(
                  key: ValueKey('tile-$_scenario-$i'),
                  number: i,
                  title: '${_tx.s('exploration')} $i',
                  focusLabel: _tx.s('focus'),
                  focus: _tx.s('s${_scenario}f$i'),
                  body: _tx.s('s${_scenario}b$i'),
                  actionLabel: _tx.s('actionLbl'),
                  action: _tx.s('s${_scenario}a$i'),
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

  /// The source's draggable, collapsible `#observation-table`.
  ///
  /// Anchored bottom-right rather than the source's top-right: the shell's
  /// toolbar owns that corner here, and up there the log would cover the
  /// Measurements panel on wide screens.
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
  /// The source's `#scrollable-workspace`.
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Clear the HUD (top), the toolbar strip (right) and the menu button.
        final contentWidth = math.max(0.0, constraints.maxWidth - 12 - 60);
        return SingleChildScrollView(
          key: const ValueKey('workspace'),
          padding: const EdgeInsets.fromLTRB(12, 100, 60, 32),
          child: _scenario == 1
              ? _scenario1Layout(contentWidth)
              : _scenario2Layout(contentWidth),
        );
      },
    );
  }

  /// Wraps a fixed-size stage so it scales to [width] and can be zoomed /
  /// panned (pan only in pan mode, so the workspace still scrolls).
  Widget _stageBox(
    Widget stage,
    double designWidth,
    double designHeight,
    double width,
  ) {
    final height = width * designHeight / designWidth;
    _stageViewport = Size(width, height);
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InteractiveViewer(
            transformationController: _zoom.transform,
            panEnabled: _panMode,
            scaleEnabled: _panMode,
            minScale: _zoom.min,
            maxScale: _zoom.max,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: FittedBox(fit: BoxFit.contain, child: stage),
          ),
        ),
      ),
    );
  }

  /// CSS `perspective` on the parent + `rotateX rotateZ translateY` on the
  /// 3D wrapper.
  static Matrix4 _tilt({
    required double perspective,
    required double rotateXDegrees,
    double rotateZDegrees = 0,
    double translateY = 0,
  }) {
    return Matrix4.identity()
      ..setEntry(3, 2, -1 / perspective)
      ..rotateX(rotateXDegrees * math.pi / 180)
      ..rotateZ(rotateZDegrees * math.pi / 180)
      ..translateByDouble(0, translateY, 0, 1);
  }

  Widget _stageLabel(String text, {double fontSize = 10}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showLabels ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (_rt_appTheme.isDark ? _rt_Tw.slate900 : Colors.white)
              .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: _rt_Tw.slate500,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------- scenario 1 UI --
  Widget _scenario1Layout(double width) {
    if (width >= 900) {
      final middle = width - 240 - 200 - 32;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 240, child: _variablesPanel()),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _stageBox(
                  _scenario1Stage(),
                  _kSc1Width,
                  _kSc1Height,
                  math.min(middle, _kSc1Width * 1.3),
                ),
                const SizedBox(height: 16),
                _scenario1Buttons(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 200, child: _measurementsPanel(vertical: true)),
        ],
      );
    }
    if (width >= 560) {
      final middle = width - 220 - 16;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 220, child: _variablesPanel()),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _stageBox(
                  _scenario1Stage(),
                  _kSc1Width,
                  _kSc1Height,
                  math.min(middle, _kSc1Width * 1.3),
                ),
                const SizedBox(height: 14),
                _scenario1Buttons(),
                const SizedBox(height: 14),
                _measurementsPanel(vertical: false),
              ],
            ),
          ),
        ],
      );
    }
    // Phones: the source's stacked column order.
    return Column(
      children: [
        _variablesPanel(),
        const SizedBox(height: 14),
        _stageBox(
          _scenario1Stage(),
          _kSc1Width,
          _kSc1Height,
          math.min(width, _kSc1Width * 1.3),
        ),
        const SizedBox(height: 14),
        _scenario1Buttons(),
        const SizedBox(height: 14),
        _measurementsPanel(vertical: false),
      ],
    );
  }

  Widget _scenario1Buttons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _ChunkyButton(
          key: const ValueKey('btn-connect'),
          label: _tx.s(_connected ? 'wiresConnected' : 'btnConnect'),
          color: _rt_Tw.blue600,
          borderColor: _rt_Tw.blue800,
          onPressed: (!_connected && _step <= 2) ? _connectCircuit : null,
        ),
        _ChunkyButton(
          key: const ValueKey('btn-test-clips'),
          label: _tx.s(_magnetDown ? 'returnMagnet' : 'btnTestClips'),
          color: _rt_Tw.purple600,
          borderColor: _kPurple800,
          onPressed: _step >= 3 ? _moveMagnet : null,
        ),
        _ChunkyButton(
          key: const ValueKey('btn-test-poles'),
          label: _tx.s('btnTestPoles'),
          color: _rt_Tw.orange600,
          borderColor: _rt_Tw.orange800,
          onPressed: _step >= 4 ? _moveCompass : null,
        ),
        if (_step == 5)
          _ChunkyButton(
            key: const ValueKey('btn-finish'),
            label: _tx.s('btnFinish'),
            color: _rt_Tw.green600,
            borderColor: _kGreen800,
            onPressed: _finishScenario1,
          ),
      ],
    );
  }

  /// The source's left "Variables Panel".
  Widget _variablesPanel() {
    final directionEnabled = _step >= 4;
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelTitle(_tx.s('variablesPanel')),
          _FieldLabel(_tx.s('coreMaterial')),
          Row(
            children: [
              Expanded(
                child: _SegmentOption(
                  key: const ValueKey('core-iron'),
                  label: _tx.s('ironNail'),
                  selected: _core == _CoreMaterial.iron,
                  onTap: () => _selectCore(_CoreMaterial.iron),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SegmentOption(
                  key: const ValueKey('core-paper'),
                  label: _tx.s('paperCylinder'),
                  selected: _core == _CoreMaterial.paper,
                  onTap: () => _selectCore(_CoreMaterial.paper),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PanelSlider(
            sliderKey: const ValueKey('turns-slider'),
            label: _tx.s('coilTurns'),
            valueText: '$_turns',
            value: _turns.toDouble(),
            min: 0,
            max: 50,
            divisions: 50,
            enabled: true,
            onChanged: _onTurnsChanged,
            onReleased: _onTurnsReleased,
          ),
          const SizedBox(height: 6),
          _PanelSlider(
            sliderKey: const ValueKey('cells-slider'),
            label: _tx.s('numCells'),
            valueText: '$_cells',
            value: _cells.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            enabled: _step >= 3,
            onChanged: _onCellsChanged,
            onReleased: _onCellsReleased,
          ),
          const SizedBox(height: 6),
          _FieldLabel(_tx.s('currentDir')),
          Opacity(
            opacity: directionEnabled ? 1 : 0.5,
            child: Material(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: const ValueKey('btn-direction'),
                borderRadius: BorderRadius.circular(12),
                onTap: directionEnabled ? _toggleDirection : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rt_Lab.borderStrong),
                  ),
                  child: Text(
                    _tx.s(_dirForward ? 'dirForward' : 'dirReverse'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
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

  /// The source's right "Measurements" panel.
  Widget _measurementsPanel({required bool vertical}) {
    final strength = _strength;
    final dark = _rt_appTheme.isDark;
    final strengthBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(_tx.s('fieldStrength'), center: true),
        Container(
          width: 120,
          height: 14,
          decoration: BoxDecoration(
            color: dark ? _rt_Tw.slate700 : _rt_Tw.slate300,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: dark ? _rt_Tw.slate600 : _rt_Tw.slate400),
          ),
          clipBehavior: Clip.antiAlias,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: strength / 100),
            duration: const Duration(milliseconds: 300),
            builder: (context, fraction, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_rt_Tw.green500, _rt_Tw.red500],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$strength%',
          key: const ValueKey('strength-val'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _rt_Lab.text,
          ),
        ),
      ],
    );
    final clipsBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(_tx.s('clipsLifted'), center: true),
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? _rt_Tw.slate800 : _rt_Tw.blue100,
            shape: BoxShape.circle,
            border: Border.all(color: _rt_Tw.blue500, width: 4),
          ),
          child: Text(
            '$_clipsLifted',
            key: const ValueKey('clip-count'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: dark ? _rt_Tw.blue400 : _rt_Tw.blue600,
            ),
          ),
        ),
      ],
    );
    return _GlassPanel(
      child: vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PanelTitle(_tx.s('measurements')),
                strengthBlock,
                const SizedBox(height: 18),
                clipsBlock,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(child: strengthBlock),
                Flexible(child: clipsBlock),
              ],
            ),
    );
  }

  /// The source's `#sc1-canvas-bounds`: a 450 x 350 table tilted in 3D.
  Widget _scenario1Stage() {
    final dark = _rt_appTheme.isDark;
    final strength = _strength;
    const compassCentres = {
      _CompassSpot.endA: 60.0,
      _CompassSpot.center: 225.0,
      _CompassSpot.endB: 390.0,
    };
    return Container(
      width: _kSc1Width,
      height: _kSc1Height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? _rt_Tw.slate800 : _rt_Tw.slate200,
        borderRadius: BorderRadius.circular(24),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? _rt_Tw.slate700 : _rt_Tw.slate400,
          width: 4,
        ),
      ),
      child: Transform(
        alignment: Alignment.center,
        transform: _tilt(
          perspective: 1000,
          rotateXDegrees: 45,
          rotateZDegrees: -10,
          translateY: 20,
        ),
        child: SizedBox(
          width: _kSc1Width,
          height: _kSc1Height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Magnetic field rings.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: strength > 0 ? math.max(0.2, strength / 100) : 0,
                    child: const CustomPaint(painter: _FieldRingsPainter()),
                  ),
                ),
              ),
              // Wire + moving current.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CircuitPainter(
                      flow: _flow,
                      connected: _connected,
                      on: _switchOn,
                      forward: _dirForward,
                    ),
                  ),
                ),
              ),
              // Electromagnet: End A label, core with coil, End B label.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
                left: 129 - 80,
                top: 171 + (_magnetDown ? 100 : 0),
                width: 192 + 160,
                height: 32,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _stageLabel(_tx.s('endA')),
                        ),
                      ),
                    ),
                    _coreWidget(),
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: _stageLabel(_tx.s('endB')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Battery stack (one cell per slider step).
              Positioned(
                left: 40,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _cells; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
                        child: _cellWidget(),
                      ),
                  ],
                ),
              ),
              // Compass.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: compassCentres[_compass]! - 28,
                top: 32,
                width: 56,
                height: 56,
                child: _compassWidget(),
              ),
              // Paper clip pile.
              Positioned(
                right: 32,
                bottom: 24,
                width: 112,
                height: 56,
                child: _clipPile(),
              ),
              // Switch.
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(child: _switchButton()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coreWidget() {
    final iron = _core == _CoreMaterial.iron;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 192,
      height: 32,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: iron
              ? const [_rt_Tw.slate300, _rt_Tw.slate400, _rt_Tw.slate500]
              : const [_rt_Tw.amber100, _rt_Tw.amber200, _kAmber300],
        ),
        borderRadius: iron
            ? const BorderRadius.horizontal(right: Radius.circular(16))
            : BorderRadius.circular(2),
        border: Border.all(color: iron ? _rt_Tw.slate400 : _rt_Tw.amber400),
      ),
      child: CustomPaint(painter: _CoilPainter(turns: _turns)),
    );
  }

  Widget _cellWidget() {
    final labelOpacity = _showLabels ? 1.0 : 0.0;
    const style = TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w800,
    );
    return Container(
      width: 48,
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _rt_Tw.red600,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kRed800, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: labelOpacity,
            child: const Text('+', style: style),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: labelOpacity,
            child: const Text('-', style: style),
          ),
        ],
      ),
    );
  }

  Widget _compassWidget() {
    const letterStyle = TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w800,
      color: _rt_Tw.slate900,
    );
    final labelOpacity = _showLabels ? 1.0 : 0.0;
    return Container(
      key: const ValueKey('compass'),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _rt_Tw.slate300, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _rt_Tw.slate200),
              ),
            ),
          ),
          Positioned(
            top: 1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: labelOpacity,
              child: const Text('N', style: letterStyle),
            ),
          ),
          Positioned(
            bottom: 1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: labelOpacity,
              child: const Text('S', style: letterStyle),
            ),
          ),
          AnimatedRotation(
            turns: _needleDegrees / 360,
            duration: const Duration(milliseconds: 500),
            curve: const Cubic(0.4, 0, 0.2, 1),
            child: const CustomPaint(
              size: Size(8, 40),
              painter: _NeedlePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clipPile() {
    final dark = _rt_appTheme.isDark;
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: _rt_Tw.slate500.withValues(alpha: 0.5),
        radius: 12,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (dark ? _rt_Tw.slate700 : _rt_Tw.slate300).withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.end,
          spacing: 4,
          runSpacing: 4,
          children: [
            for (var i = 0; i < _kClipCount; i++)
              AnimatedSlide(
                // -60 px for a 6 px tall clip (the source's translateY(-60px)).
                offset: Offset(0, i < _clipsLifted ? -10 : 0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: AnimatedRotation(
                  turns:
                      (i < _clipsLifted
                          ? _clipLiftRotation[i]
                          : _clipRestRotation[i]) /
                      360,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 16,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _rt_Tw.slate400,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _rt_Tw.slate500),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _switchButton() {
    final dark = _rt_appTheme.isDark;
    final (String label, Color color, Color border) = !_connected
        ? (
            _tx.s('switchOff'),
            dark ? _rt_Tw.slate600 : _rt_Tw.slate400,
            dark ? _rt_Tw.slate800 : _rt_Tw.slate500,
          )
        : _switchOn
        ? (
            _tx.s('switchOff'),
            dark ? _rt_Tw.green600 : _rt_Tw.green500,
            dark ? _kGreen800 : _rt_Tw.green700,
          )
        : (
            _tx.s('switchOn'),
            dark ? _rt_Tw.red600 : _rt_Tw.red500,
            dark ? _kRed800 : _rt_Tw.red700,
          );
    return _ChunkyButton(
      key: const ValueKey('btn-switch'),
      label: label,
      color: color,
      borderColor: border,
      fontSize: 14,
      onPressed: _connected ? _toggleSwitch : null,
    );
  }

  // -------------------------------------------------------- scenario 2 UI --
  Widget _scenario2Layout(double width) {
    return Column(
      children: [
        _scenario2Buttons(),
        const SizedBox(height: 16),
        _stageBox(
          _scenario2Stage(),
          _kSc2Width,
          _kSc2Height,
          math.min(width, _kSc2Width * 1.1),
        ),
      ],
    );
  }

  Widget _scenario2Buttons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _ChunkyButton(
          key: const ValueKey('btn-crane-power'),
          label: _tx.s(_craneOn ? 'powerOff' : 'powerOn'),
          color: _craneOn ? _rt_Tw.green600 : _rt_Tw.red600,
          borderColor: _craneOn ? _kGreen800 : _kRed800,
          fontSize: 14,
          onPressed: _toggleCranePower,
        ),
        _ChunkyButton(
          key: const ValueKey('btn-crane-move'),
          label: _tx.s(_craneAtBin ? 'moveToPile' : 'moveToBin'),
          color: _rt_Tw.blue600,
          borderColor: _rt_Tw.blue800,
          fontSize: 14,
          onPressed: _moveEnabled ? _moveCrane : null,
        ),
        if (_faultVisible)
          AnimatedBuilder(
            animation: _bounce,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -8 * Curves.easeOut.transform(_bounce.value)),
              child: child,
            ),
            child: _ChunkyButton(
              key: const ValueKey('btn-fault'),
              label: _tx.s('diagnoseFault'),
              color: _rt_Tw.yellow500,
              borderColor: _kYellow700,
              textColor: _rt_Tw.slate900,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              onPressed: _showFaultDialog,
            ),
          ),
      ],
    );
  }

  double get _craneCentreX => _kCraneHomeX + (_craneAtBin ? _kCraneTravel : 0);

  /// Where a scrap item sits: (left, top, rotation in degrees).
  (double, double, double) _scrapPose(_ScrapItem item) {
    switch (item.spot) {
      case _ScrapSpot.pile:
        return (
          _kPileRect.left + item.pileX,
          _kPileRect.top + item.pileY,
          item.rotation,
        );
      case _ScrapSpot.attached:
        final (dx, dy) = _kAttachOffsets[item.slot % _kAttachOffsets.length];
        return (_craneCentreX + dx - 20, _kMagnetFaceY + dy - 12, item.tilt);
      case _ScrapSpot.bin:
        final (dx, dy) = _kBinOffsets[item.slot % _kBinOffsets.length];
        return (
          _kBinRect.center.dx + dx - 20,
          _kBinRect.top - 18 + dy,
          item.tilt,
        );
    }
  }

  Widget _scrapWidget(int index, _ScrapItem item) {
    final (left, top, angle) = _scrapPose(item);
    return AnimatedPositioned(
      key: ValueKey('scrap-$index'),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      left: left,
      top: top,
      width: 40,
      height: 24,
      child: AnimatedRotation(
        turns: angle / 360,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(4),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showLabels ? 1 : 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _tx.s(item.labelKey).toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The source's `#sc2-canvas-bounds`: scrap yard with gantry crane.
  Widget _scenario2Stage() {
    final dark = _rt_appTheme.isDark;
    final looseScrap = <Widget>[];
    final attachedScrap = <Widget>[];
    for (var i = 0; i < _scrap.length; i++) {
      final scrapWidget = _scrapWidget(i, _scrap[i]);
      (_scrap[i].spot == _ScrapSpot.attached ? attachedScrap : looseScrap).add(
        scrapWidget,
      );
    }
    const labelDuration = Duration(milliseconds: 300);
    final labelOpacity = _showLabels ? 1.0 : 0.0;

    return Container(
      width: _kSc2Width,
      height: _kSc2Height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? _rt_Tw.slate800 : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _rt_Tw.slate400, width: 8),
      ),
      child: Transform(
        alignment: Alignment.center,
        transform: _tilt(perspective: 1200, rotateXDegrees: 20, translateY: 20),
        child: SizedBox(
          width: _kSc2Width,
          height: _kSc2Height,
          // Every child is keyed: scrap items hop between the "loose" and
          // "attached" layers, and keys keep their animations running.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Ground.
              Positioned(
                key: const ValueKey('ground'),
                left: 0,
                right: 0,
                top: 412,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: dark ? _rt_Tw.slate700 : _rt_Tw.slate300,
                    border: Border(
                      top: BorderSide(
                        color: dark ? _rt_Tw.slate600 : _rt_Tw.slate400,
                        width: 4,
                      ),
                    ),
                  ),
                ),
              ),
              // Mixed scrap pile.
              Positioned.fromRect(
                key: const ValueKey('pile'),
                rect: _kPileRect,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: _kAmber900.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: AnimatedOpacity(
                    duration: labelDuration,
                    opacity: labelOpacity,
                    child: Text(
                      _tx.s('mixedScrap').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: (dark ? _rt_Tw.amber200 : _kAmber900).withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bin rim (behind the bin body and the scrap resting in it).
              Positioned(
                key: const ValueKey('bin-rim'),
                left: _kBinRect.left - 10,
                top: _kBinRect.top - 16,
                width: _kBinRect.width + 20,
                height: 32,
                child: const DecoratedBox(
                  decoration: ShapeDecoration(
                    color: _rt_Tw.slate700,
                    shape: OvalBorder(
                      side: BorderSide(color: _rt_Tw.slate800, width: 4),
                    ),
                  ),
                ),
              ),
              ...looseScrap,
              // Steel bin body.
              Positioned.fromRect(
                key: const ValueKey('bin'),
                rect: _kBinRect,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: _rt_Tw.slate600,
                    border: Border.all(color: _rt_Tw.slate800, width: 4),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: AnimatedOpacity(
                    duration: labelDuration,
                    opacity: labelOpacity,
                    child: Container(
                      width: double.infinity,
                      color: _rt_Tw.slate900,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _tx.s('steelBin').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Gantry rail.
              Positioned(
                key: const ValueKey('rail'),
                left: 0,
                right: 0,
                top: 8,
                height: 24,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: _rt_Tw.slate800,
                    border: Border(
                      bottom: BorderSide(color: _rt_Tw.slate900, width: 2),
                    ),
                  ),
                ),
              ),
              // Crane: trolley, cable, magnet and its field.
              AnimatedPositioned(
                key: const ValueKey('crane'),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                left: _craneCentreX - 96,
                top: 8,
                width: 192,
                height: 512,
                child: _crane(),
              ),
              ...attachedScrap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _crane() {
    Widget wheel() => Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _rt_Tw.slate800,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: _rt_Tw.slate400,
          shape: BoxShape.circle,
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cable.
        const Positioned(
          left: 92,
          top: 48,
          width: 8,
          height: 256,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _rt_Tw.slate500,
              border: Border(right: BorderSide(color: _rt_Tw.slate400)),
            ),
          ),
        ),
        // Trolley.
        Positioned(
          left: 48,
          top: 0,
          width: 96,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              color: _kYellow600,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _kYellow800, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [wheel(), wheel()],
            ),
          ),
        ),
        // Field lines below the magnet while powered.
        Positioned(
          left: 0,
          top: 352,
          width: 192,
          height: 160,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _craneOn ? 0.6 : 0,
              child: const CustomPaint(painter: _CraneFieldPainter()),
            ),
          ),
        ),
        // Lifting magnet.
        Positioned(
          left: 48,
          top: 304,
          width: 96,
          height: 48,
          child: Container(
            key: const ValueKey('crane-magnet'),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _rt_Tw.slate700,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Tw.slate900, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              width: 64,
              height: 8,
              decoration: BoxDecoration(
                color: _rt_Tw.yellow400,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
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
        border: Border.all(color: _rt_Lab.borderStrong),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: _rt_Tw.slate500,
        ),
      ),
    );
  }
}

/// One half of the core-material selector (the source's `<select>`).
class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
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
          : _rt_Lab.overlay,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _rt_Tw.blue500 : _rt_Lab.borderStrong,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: selected
                  ? _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700)
                  : _rt_Lab.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// Range input that commits on release (the source's `oninput` / `onchange`).
class _PanelSlider extends StatelessWidget {
  const _PanelSlider({
    required this.sliderKey,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.enabled,
    required this.onChanged,
    required this.onReleased,
  });

  final Key sliderKey;
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onReleased;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: _rt_Tw.slate500,
                  ),
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _rt_Tw.blue500,
                ),
              ),
            ],
          ),
          SliderTheme(
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
              key: sliderKey,
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
              onChangeEnd: enabled ? onReleased : null,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

/// One collapsible "Exploration n" card of the source's teacher board.
class _ExplorationTile extends StatelessWidget {
  const _ExplorationTile({
    super.key,
    required this.number,
    required this.title,
    required this.focusLabel,
    required this.focus,
    required this.body,
    required this.actionLabel,
    required this.action,
    required this.status,
    required this.expanded,
    required this.onToggle,
  });

  final int number;
  final String title;
  final String focusLabel;
  final String focus;
  final String body;
  final String actionLabel;
  final String action;
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
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 12,
                      color: _rt_Lab.textMuted,
                      height: 1.35,
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
                          actionLabel,
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

/// Body of the "System Fault Diagnostic" popup.
class _FaultBody extends StatelessWidget {
  const _FaultBody({required this.options});

  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    Widget stat(IconData icon, Color color, String label, String value) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Column(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _tx.s('faultDesc'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _rt_Lab.textMuted, height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            stat(
              Icons.thermostat,
              _rt_Tw.red500,
              _tx.s('coilTemp'),
              _tx.s('high'),
            ),
            const SizedBox(width: 8),
            stat(
              Icons.battery_full,
              _rt_Tw.green500,
              _tx.s('battery'),
              _tx.s('ok'),
            ),
            const SizedBox(width: 8),
            stat(
              Icons.blur_circular,
              _rt_Tw.red500,
              _tx.s('field'),
              _tx.s('weak'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue500)),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_tx.s('observationLbl')} ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(text: _tx.s('heatingNote')),
              ],
            ),
            style: TextStyle(fontSize: 12, color: _rt_Lab.text, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _tx.s('selectFix'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.text,
          ),
        ),
        const SizedBox(height: 8),
        ...options,
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

/// The three dashed ellipses of the source's `#mag-field` SVG.
class _FieldRingsPainter extends CustomPainter {
  const _FieldRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const centre = Offset(225, 175);
    const rings = [(140.0, 60.0, 3.0), (170.0, 90.0, 2.0), (200.0, 120.0, 1.5)];
    for (final (rx, ry, width) in rings) {
      final paint = Paint()
        ..color = _rt_Tw.blue500
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
      final path = Path()
        ..addOval(
          Rect.fromCenter(center: centre, width: rx * 2, height: ry * 2),
        );
      _drawDashedPath(canvas, path, paint, 10, 10);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The source's `#circuit-wire` (yellow) and `#current-dots` (red, flowing).
class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.flow,
    required this.connected,
    required this.on,
    required this.forward,
  }) : super(repaint: flow);

  final Animation<double> flow;
  final bool connected;
  final bool on;
  final bool forward;

  static final Path _wire = Path()
    ..moveTo(75, 275)
    ..lineTo(75, 175)
    ..lineTo(175, 175)
    ..lineTo(275, 175)
    ..lineTo(375, 175)
    ..lineTo(375, 275)
    ..lineTo(275, 275);

  @override
  void paint(Canvas canvas, Size size) {
    if (!connected) return;
    canvas.drawPath(
      _wire,
      Paint()
        ..color = _rt_Tw.yellow500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (!on) return;
    final shift = flow.value * 20;
    _drawDashedPath(
      canvas,
      _wire,
      Paint()
        ..color = _rt_Tw.red500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
      5,
      15,
      phase: forward ? shift : -shift,
    );
  }

  @override
  bool shouldRepaint(_CircuitPainter old) =>
      old.connected != connected || old.on != on || old.forward != forward;
}

/// Copper turns wound over the core (the source's skewed `coils-container`
/// bars, `justify-evenly`, shrinking to fit once they no longer do).
class _CoilPainter extends CustomPainter {
  const _CoilPainter({required this.turns});

  final int turns;

  @override
  void paint(Canvas canvas, Size size) {
    if (turns <= 0) return;
    canvas.clipRect(Offset.zero & size);
    const padding = 8.0;
    final inner = size.width - padding * 2;
    final double barWidth;
    final double gap;
    if (turns * 6 <= inner) {
      barWidth = 6;
      gap = (inner - turns * 6) / (turns + 1);
    } else {
      barWidth = inner / turns;
      gap = 0;
    }
    final skew = math.tan(15 * math.pi / 180) * size.height / 2;
    final fill = Paint()..color = _rt_Tw.orange600.withValues(alpha: 0.9);
    final edge = Paint()
      ..color = _rt_Tw.orange800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < turns; i++) {
      final left = padding + gap * (i + 1) + barWidth * i;
      final bar = Path()
        ..moveTo(left + skew, 0)
        ..lineTo(left + barWidth + skew, 0)
        ..lineTo(left + barWidth - skew, size.height)
        ..lineTo(left - skew, size.height)
        ..close();
      canvas.drawPath(bar, fill);
      canvas.drawPath(bar, edge);
    }
  }

  @override
  bool shouldRepaint(_CoilPainter old) => old.turns != turns;
}

/// Compass needle: red north half on top, blue south half below.
class _NeedlePainter extends CustomPainter {
  const _NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(0, h / 2)
        ..lineTo(w / 2, 0)
        ..lineTo(w, h / 2)
        ..close(),
      Paint()..color = _rt_Tw.red500,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h / 2)
        ..lineTo(w, h / 2)
        ..lineTo(w / 2, h)
        ..close(),
      Paint()..color = _rt_Tw.blue500,
    );
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      1.6,
      Paint()..color = _rt_Tw.slate700,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dashed outline of the clip tray (`border-2 border-dashed`).
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

/// Field lines fanning out below the crane magnet (the source's SVG, viewBox
/// 100 x 100 stretched with `preserveAspectRatio="none"`).
class _CraneFieldPainter extends CustomPainter {
  const _CraneFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const lines = [
      (10.0, -10.0),
      (30.0, 20.0),
      (50.0, 50.0),
      (70.0, 80.0),
      (90.0, 110.0),
    ];
    final sx = size.width / 100;
    final sy = size.height / 100;
    final paint = Paint()
      ..color = _rt_Tw.blue500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final (top, bottom) in lines) {
      final path = Path()
        ..moveTo(top * sx, 0)
        ..lineTo(bottom * sx, 100 * sy);
      _drawDashedPath(canvas, path, paint, 8, 8);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
