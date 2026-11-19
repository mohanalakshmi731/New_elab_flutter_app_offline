// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 6.2: Liquid Pressure
// Converted from Cl8S-Ch6-A2-Liquid_Pressure.html
// (DOM/SVG scene + GSAP tweens -> CustomPainter canvas with raw pointer drags).
//
// Two scenarios chosen from the sidebar. 1: Height vs Diameter — set up a
// narrow (d = 2 cm) and a wide (d = 10 cm) pipe with balloons underneath, fill
// Pipe A with the pitcher, hold-to-pour Pipe B to exactly h = 15 cm (releasing
// early is an error), measure both bulges with draggable calipers (22 mm each)
// and read the P = ρ×g×h conclusion. 2: Lateral Pressure — place a bottle,
// puncture 4 holes with the heated spike exactly on the h = 5 cm line, hold
// the tap open so the jets shoot sideways, then place collection troughs to
// see every jet land at the same distance d. Every canvas drag also has a
// sidebar button so the lab is usable on small screens.






// --- TRANSLATION DATA (source `locales` en/hi; te: block dropped) ---

import 'dart:async';
import 'dart:math' as math;


import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
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

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'title': 'Liquid Pressure',
    'sub': 'Class 8 • Pressure, Winds, Storms, and Cyclones',
    'enterLab': 'Enter _rt_Lab',
    'interactiveTask': 'Interactive Task',
    'observationComplete': 'Observation Complete',
    'missionObj': 'Mission Objective',
    'lbl_select_scenario': 'Select Scenario',
    'lbl_controls': '_rt_Lab Controls',
    'lbl_task': 'Task',
    'lbl_progress': 'Progress',
    'stepText': 'Step',
    'obsLbl': 'Observation',
    'concLbl': 'Conclusion',
    'tool_labels': 'Toggle Labels',
    'tool_pan': 'Pan Mode',
    'complete': 'Activity Complete!',
    'svg': {
      'setupApparatus': 'SETUP APPARATUS',
      'placeBottle': 'PLACE BOTTLE',
      'equalHeight': 'Equal Height (h = 15 cm)',
      'identicalBulge': 'Identical Bulge (22 mm)',
      'clickHoldPour': 'Press & hold to Pour',
      'record': 'Record',
      'dragNearBalloon': 'Drag near balloon',
      'distanceD': 'Distance d',
      'troughs': 'Troughs',
      'heatedSpike': 'Heated Spike',
      'dragDown': 'Drag Down',
      'h5cm': 'h = 5 cm',
      'bowl': 'Bowl',
      'dA': 'd = 2 cm',
      'dB': 'd = 10 cm',
      'cm15L': '15 cm →',
      'cm15R': '← 15 cm',
      'reading22': '22 mm',
    },
    'toasts': {
      'errHeight': 'Height is incorrect (needs exactly 15cm). Try again!',
      'measureB': 'Measure Balloon B now.',
      'recorded22A': 'Reading: 22 mm for Pipe A',
      'recorded22B': 'Reading: 22 mm for Pipe B',
      'errPuncture': 'Puncture EXACTLY on the 5 cm dotted line!',
      'errPitcher': 'You moved the pitcher! Hold it steady.',
    },
    's1_name': 'Height vs Diameter',
    's2_name': 'Lateral Pressure',
    's1_obj':
        'To demonstrate that liquid pressure at a given depth depends on the height of the liquid column, not the volume or diameter of the container.',
    's2_obj':
        'To demonstrate that liquids exert equal pressure in all lateral directions at a given depth.',
    's1_titles': [
      'Theory & Setup',
      'Filling Pipe A',
      'The Comparative Fill',
      'Observation & Measure',
      'Conclusion',
    ],
    's1_theory': [
      'Formula for liquid pressure:\nP = ρ × g × h\nNotice that Area (A) or Diameter (d) is NOT in the equation. Students often mistakenly think a wider pipe creates more pressure because it holds "more water."',
      'Pipe A is narrow (d = 2 cm). Pipe B is wide (d = 10 cm).\nBoth have identical deflated rubber balloons attached.',
      'Pipe A is filled. The balloon bulged due to the pressure of the water column.',
      'Both pipes are filled to h = 15 cm. Pipe B holds much more water.',
      'Measurements reveal the bulge is exactly the same (22 mm) for both balloons.',
    ],
    's1_inst': [
      'Click SETUP APPARATUS on the canvas.',
      'Drag the Pitcher to Pipe A to fill it to h = 15 cm.',
      'Drag the Pitcher to Pipe B. Then press and hold to pour water. It will automatically stop at exactly 15 cm.',
      'Drag the Calipers under Balloon A, click Record. Repeat for Balloon B.',
      'Activity Complete. Review the Observation.',
    ],
    's1_obs':
        'The water level is the same (15 cm), and the balloon bulge is identical (22 mm) in both pipes, despite Pipe B holding much more water.',
    's1_conc':
        'Liquid pressure (P = ρ × g × h) depends only on the height of the column, not the volume or diameter of the container.',
    's2_titles': [
      'Theory & Setup',
      'Creating Punctures',
      'Filling and Observation',
      'Measuring the Flow',
      'Conclusion',
    ],
    's2_theory': [
      'Liquids do not just exert pressure downwards; they exert pressure in all directions, including the walls of the container.',
      'We need to create holes in the bottle at the exact same height.',
      'Holes successfully created at h = 5 cm.',
      'Water is shooting out laterally.',
      'The water jets from all holes land at the exact same radial distance d.',
    ],
    's2_inst': [
      'Click PLACE BOTTLE to set up the experiment.',
      'Drag the Heated Spike to puncture holes exactly on the h = 5 cm dotted line.',
      'Pour water into the bottle to fill it completely. DRAG DOWN & HOLD the Tap Handle. You can drag it repeatedly to test.',
      'Drag the Collection Troughs to the table surface to catch the water.',
      'Activity Complete. Review the Observation.',
    ],
    's2_obs':
        'The water jets from all holes land at the exact same radial distance d from the bottle.',
    's2_conc':
        'Water flows out of all holes at the same depth with equal force, proving that lateral pressure is uniform at a constant height.',
    // Dart additions: canvas drags mirrored as sidebar buttons.
    'btn_setup': 'Setup Apparatus',
    'btn_fillA': 'Fill Pipe A',
    'btn_toB': 'Move Pitcher to Pipe B',
    'btn_pour': 'Hold to Pour',
    'btn_calA': 'Calipers to Balloon A',
    'btn_calB': 'Calipers to Balloon B',
    'btn_record': 'Record Reading',
    'btn_view': 'View Observation',
    'btn_bottle': 'Place Bottle',
    'btn_spike': 'Puncture on the Line',
    'btn_tap': 'Hold Tap Open',
    'btn_troughs': 'Place Troughs',
  },
  'hi': {
    'title': 'तरल दबाव',
    'sub': 'कक्षा 8 • दबाव, हवाएँ, तूफान और चक्रवात',
    'enterLab': 'लैब में प्रवेश करें',
    'interactiveTask': 'इंटरएक्टिव कार्य',
    'observationComplete': 'अवलोकन पूर्ण',
    'missionObj': 'मिशन का उद्देश्य',
    'lbl_select_scenario': 'परिदृश्य चुनें',
    'lbl_controls': 'प्रयोग नियंत्रण',
    'lbl_task': 'कार्य',
    'lbl_progress': 'प्रगति',
    'stepText': 'चरण',
    'obsLbl': 'अवलोकन',
    'concLbl': 'निष्कर्ष',
    'tool_labels': 'लेबल टॉगल करें',
    'tool_pan': 'पैन मोड',
    'complete': 'गतिविधि पूरी हुई!',
    'svg': {
      'setupApparatus': 'उपकरण सेट करें',
      'placeBottle': 'बोतल रखें',
      'equalHeight': 'समान ऊँचाई (h = 15 cm)',
      'identicalBulge': 'समान उभार (22 mm)',
      'clickHoldPour': 'डालने के लिए दबाकर रखें',
      'record': 'रिकॉर्ड करें',
      'dragNearBalloon': 'गुब्बारे के पास खींचें',
      'distanceD': 'दूरी d',
      'troughs': 'ट्रफ (गर्त)',
      'heatedSpike': 'गर्म कील',
      'dragDown': 'नीचे खींचें',
      'h5cm': 'h = 5 cm',
      'bowl': 'कटोरा',
      'dA': 'd = 2 cm',
      'dB': 'd = 10 cm',
      'cm15L': '15 cm →',
      'cm15R': '← 15 cm',
      'reading22': '22 mm',
    },
    'toasts': {
      'errHeight': 'ऊंचाई गलत है (ठीक 15 सेमी की आवश्यकता है)। पुनः प्रयास करें!',
      'measureB': 'अब गुब्बारा B को मापें।',
      'recorded22A': 'रिकॉर्ड किया गया: पाइप A के लिए 22 मिमी',
      'recorded22B': 'रिकॉर्ड किया गया: पाइप B के लिए 22 मिमी',
      'errPuncture': '5 सेमी बिंदीदार रेखा पर बिल्कुल सटीक छेद करें!',
      'errPitcher': 'आपने पिचर को हिला दिया! इसे स्थिर रखें।',
    },
    's1_name': 'ऊँचाई बनाम व्यास',
    's2_name': 'पार्श्व दाब',
    's1_obj':
        'यह प्रदर्शित करने के लिए कि किसी दी गई गहराई पर द्रव का दाब द्रव स्तंभ की ऊँचाई पर निर्भर करता है, न कि बर्तन के आयतन या व्यास पर।',
    's2_obj':
        'यह प्रदर्शित करने के लिए कि द्रव किसी दी गई गहराई पर सभी पार्श्व दिशाओं में समान दाब डालते हैं।',
    's1_titles': [
      'सिद्धांत और सेटअप',
      'पाइप A को भरना',
      'तुलनात्मक भराव',
      'अवलोकन और माप',
      'निष्कर्ष',
    ],
    's1_theory': [
      'द्रव दाब का सूत्र:\nP = ρ × g × h\nध्यान दें कि क्षेत्रफल (A) या व्यास (d) समीकरण में नहीं है। छात्र अक्सर गलती से सोचते हैं कि चौड़ा पाइप अधिक दाब बनाता है क्योंकि उसमें "अधिक पानी" होता है।',
      'पाइप A संकरा है (d = 2 cm)। पाइप B चौड़ा है (d = 10 cm)।\nदोनों में समान पिचके हुए रबर के गुब्बारे लगे हैं।',
      'पाइप A भर गया है। जल स्तंभ के दाब के कारण गुब्बारा फूल गया।',
      'दोनों पाइप h = 15 cm तक भरे हुए हैं। पाइप B में बहुत अधिक पानी है।',
      'माप से पता चलता है कि दोनों गुब्बारों का उभार बिल्कुल समान (22 mm) है।',
    ],
    's1_inst': [
      'कैनवास पर "उपकरण सेट करें" पर क्लिक करें।',
      'पिचर को पाइप A पर खींचें और इसे h = 15 cm तक भरें।',
      'पिचर को पाइप B पर खींचें और पानी डालने के लिए दबाकर रखें। यह 15 cm पर अपने आप रुक जाएगा।',
      'कैलिपर्स को गुब्बारे A के नीचे खींचें, रिकॉर्ड पर क्लिक करें। गुब्बारे B के लिए दोहराएं।',
      'गतिविधि पूरी हुई। अवलोकन की समीक्षा करें।',
    ],
    's1_obs':
        'पाइप B में बहुत अधिक पानी होने के बावजूद, दोनों पाइपों में जल स्तर समान (15 cm) है, और गुब्बारे का उभार भी समान (22 mm) है।',
    's1_conc':
        'द्रव दाब (P = ρ × g × h) केवल स्तंभ की ऊँचाई पर निर्भर करता है, बर्तन के आयतन या व्यास पर नहीं।',
    's2_titles': [
      'सिद्धांत और सेटअप',
      'छेद बनाना',
      'भरना और अवलोकन',
      'प्रवाह मापना',
      'निष्कर्ष',
    ],
    's2_theory': [
      'द्रव केवल नीचे की ओर दाब नहीं डालते; वे बर्तन की दीवारों सहित सभी दिशाओं में दाब डालते हैं।',
      'हमें बोतल में बिल्कुल समान ऊँचाई पर छेद बनाने की आवश्यकता है।',
      'h = 5 cm पर सफलतापूर्वक छेद बनाए गए।',
      'पानी पार्श्व रूप से (बगल में) बाहर निकल रहा है।',
      'सभी छेदों से पानी की धाराएं बिल्कुल समान त्रिज्यीय दूरी d पर गिरती हैं।',
    ],
    's2_inst': [
      'प्रयोग सेट करने के लिए "बोतल रखें" पर क्लिक करें।',
      'h = 5 cm बिंदीदार रेखा पर ठीक छेद करने के लिए गर्म कील को खींचें।',
      'बोतल को पूरी तरह भरने के लिए उसमें पानी डालें। नल के हैंडल को नीचे खींचें और पकड़ कर रखें। परीक्षण के लिए इसे बार-बार खींच सकते हैं।',
      'पानी को इकट्ठा करने के लिए कलेक्शन ट्रफ को टेबल पर खींचें।',
      'गतिविधि पूरी हुई। अवलोकन की समीक्षा करें।',
    ],
    's2_obs':
        'सभी छेदों से पानी की धाराएं बोतल से बिल्कुल समान त्रिज्यीय दूरी d पर गिरती हैं।',
    's2_conc':
        'समान गहराई पर सभी छेदों से पानी समान बल से बाहर निकलता है, जो यह साबित करता है कि समान ऊँचाई पर पार्श्व दाब एक समान होता है।',
    'btn_setup': 'उपकरण सेट करें',
    'btn_fillA': 'पाइप A भरें',
    'btn_toB': 'पिचर को पाइप B पर ले जाएँ',
    'btn_pour': 'डालने के लिए दबाकर रखें',
    'btn_calA': 'कैलिपर्स गुब्बारे A पर',
    'btn_calB': 'कैलिपर्स गुब्बारे B पर',
    'btn_record': 'रीडिंग रिकॉर्ड करें',
    'btn_view': 'अवलोकन देखें',
    'btn_bottle': 'बोतल रखें',
    'btn_spike': 'रेखा पर छेद करें',
    'btn_tap': 'नल खोलकर रखें',
    'btn_troughs': 'ट्रफ रखें',
  },
});

// --- Source colours (physical objects stay literal) ---
const _cAccent = _rt_Tw.amber500;
const _cWater = Color(0xFF38BDF8);
const _cPipeFill = Color(0x26E0F2FE); // rgba(224,242,254,0.15)
const _cPipeStroke = Color(0xFF7DD3FC);
const _cRulerFill = Color(0xFFFEF3C7);
const _cRulerStroke = Color(0xFFB45309);
const _cBalloon = Color(0xFFD4A373);
const _cBalloonStroke = Color(0xFF9A3412);
const _cBalloonNeck = Color(0xFFB45309);
const _cGreen = Color(0xFF22C55E);
const _cRed = Color(0xFFEF4444);
const _cYellow = Color(0xFFEAB308);
const _cTableTop = Color(0xFF475569);
const _cTableLeg = Color(0xFF334155);
const _cBowlRim = Color(0xFFCBD5E1);
const _cBowlBody = Color(0xFF94A3B8);
const _cBowlStroke = Color(0xFF475569);
const _cSpikeHandle = Color(0xFFFCD34D);
const _cSpikeTip = Color(0xFFEF4444);
const _cSpikeTipStroke = Color(0xFFB91C1C);
const _cTapBody = Color(0xFF64748B);
const _cTapStroke = Color(0xFF334155);
const _cTapSpout = Color(0xFF94A3B8);
const _cHandle = Color(0xFFEF4444);
const _cHandleStroke = Color(0xFF991B1B);
const _cCaliperBase = Color(0xFF94A3B8);
const _cCaliperJaw = Color(0xFF64748B);
const _cCaliperJawStroke = Color(0xFF334155);
const _cCaliperSlider = Color(0xFFCBD5E1);
const _cBeakerGlass = Color(0x80E0F2FE);
const _cBeakerStroke = Color(0xFF0284C7);
const _cBeakerHandle = Color(0xCCBAE6FD);

/// One running tween (the source's GSAP `.to()` equivalents).
class _Anim {
  _Anim(this.duration, this.onTick, this.onDone, this.curve);
  final double duration;
  final void Function(double t) onTick;
  final VoidCallback? onDone;
  final Curve curve;
  double elapsed = 0;
}

/// Ticker-driven tween list; replaces the GSAP timelines of the source.
class _Tweens {
  final List<_Anim> _list = [];

  bool get isBusy => _list.isNotEmpty;

  void run(double seconds, void Function(double t) onTick,
      {VoidCallback? onDone, Curve curve = Curves.easeOutCubic}) {
    if (seconds <= 0) {
      onTick(1);
      onDone?.call();
      return;
    }
    _list.add(_Anim(seconds, onTick, onDone, curve));
  }

  bool tick(double dt) {
    if (_list.isEmpty) return false;
    for (final a in List.of(_list)) {
      a.elapsed += dt;
      final p = (a.elapsed / a.duration).clamp(0.0, 1.0);
      a.onTick(a.curve.transform(p));
      if (p >= 1) {
        _list.remove(a);
        a.onDone?.call();
      }
    }
    return true;
  }

  void cancelAll() => _list.clear();
}

/// What the current pointer is holding on the canvas.
enum _Drag { none, pan, pitcher, pour, calipers, spike, tapHandle, troughs }

class Cl8Ch06A2LiquidPressurePage extends StatefulWidget {
  const Cl8Ch06A2LiquidPressurePage({super.key});

  @override
  State<Cl8Ch06A2LiquidPressurePage> createState() =>
      _Cl8Ch06A2LiquidPressurePageState();
}

class _Cl8Ch06A2LiquidPressurePageState extends State<Cl8Ch06A2LiquidPressurePage>
    with SingleTickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _Tweens _tweens = _Tweens();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  // --- camera (source pan/zoom; gestures are drags, so the camera is driven
  // by the toolbar: zoom buttons + a pan-mode toggle, like the source's
  // unlock + pan tools) ---
  double _zoom = 1;
  Offset _panOffset = Offset.zero;
  bool _panMode = false;
  bool _labelsOn = true;
  Size _canvasSize = const Size(600, 400);

  // --- lab state (source `state`) ---
  int _scenario = 0; // 0 = Height vs Diameter, 1 = Lateral Pressure
  int _step = 0;
  bool _completed = false;
  bool _conclusionShown = false;

  /// Bumped by restart / scenario change so delayed callbacks die.
  int _gen = 0;

  // Scenario 1.
  double _appT = 0; // apparatus fade-in
  Offset _pitcher = const Offset(500, 170);
  double _tilt = 0; // 0..1 -> -45deg
  double _streamH = 0;
  double _waterA = 0; // 0..150 (px of the 15 cm column)
  double _waterB = 0;
  double _bulbA = 16;
  double _bulbB = 16;
  bool _busy = false; // auto-fill A sequence running
  bool _pitcherParkedB = false;
  bool _holdTooltip = false;
  bool _pouringB = false;
  Offset _calipers = const Offset(500, 720);
  double _jawT = 0; // 0 open .. 1 closed
  bool _measuredA = false;
  bool _measuredB = false;
  String? _recordFor; // 'A' | 'B' -> record button visible
  bool _showReading = false;
  double _markerT = 0;

  // Scenario 2.
  double _app2T = 0;
  double _guideT = 0;
  bool _holes = false;
  Offset _spike = const Offset(850, 580);
  double _botWater = 0; // 0..250
  bool _tapFlowing = false;
  bool _draining = false;
  bool _jetsOn = false;
  double _tapHandleY = 0; // 0..40
  double _tapStreamH = 0;
  Offset _troughsDrag = const Offset(850, 450);
  bool _troughsPlaced = false;

  // Pointer/drag bookkeeping.
  _Drag _drag = _Drag.none;
  Offset _downLocal = Offset.zero;
  Offset _grabOffset = Offset.zero;
  double _handleY0 = 0;
  double _downSceneY = 0;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  bool _alive(int gen) => mounted && gen == _gen;

  // ---------------------------------------------------------- animation ---
  void _onTick(Duration now) {
    final dt =
        ((now - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.1).toDouble();
    _lastTick = now;
    var dirty = _tweens.tick(dt);

    // Source manualFillLoop: 1.5 px per 60fps frame = 90 px/s.
    if (_pouringB) {
      _waterB = math.min(150, _waterB + 90 * dt);
      _bulbB = 16 + math.min(10, _waterB / 150 * 10);
      if (_waterB >= 150) _validatePour(autoStop: true);
      dirty = true;
    }
    // Source bottleFillLoop.
    if (_tapFlowing) {
      _botWater = math.min(250, _botWater + 90 * dt);
      if (_botWater > 50 && !_jetsOn) {
        _jetsOn = true;
        _rt_playSfx(_rt_Sfx.magic); // jets burst out of the holes
      }
      if (_botWater >= 250) _stopTapFlow();
      dirty = true;
    }
    // Source drainBottleLoop (rate raised from 12 px/s so the wait stays
    // classroom-friendly; the physics of the jets is unchanged).
    if (_draining && !_tapFlowing) {
      _botWater = math.max(50, _botWater - 40 * dt);
      if (_botWater <= 50) {
        _draining = false;
        if (_jetsOn) {
          _jetsOn = false;
          if (_scenario == 1 && _step == 2) {
            _rt_playSfx(_rt_Sfx.correct); // source playSound('success')
            _toStep(3);
          }
        }
      }
      dirty = true;
    }

    if (dirty && mounted) setState(() {});
  }

  // ------------------------------------------------------------- toasts ---
  void _toastErr(String key) {
    _rt_playSfx(_rt_Sfx.wrong); // source playSound('error')
    _shell.showToast(_tx.s('toasts.$key'), color: _rt_Tw.red500, icon: Icons.cancel);
  }

  void _toastInfo(String key) {
    _shell.showToast(_tx.s('toasts.$key'), color: _rt_Tw.blue500, icon: Icons.info);
  }

  // ------------------------------------------------------ scenario flow ---
  void _loadScenario(int idx, {bool silent = false}) {
    _gen++;
    _tweens.cancelAll();
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _scenario = idx;
      _step = 0;
      _completed = false;
      _conclusionShown = false;
      _busy = false;
      // Scenario 1 state.
      _appT = 0;
      _pitcher = const Offset(500, 170);
      _tilt = 0;
      _streamH = 0;
      _waterA = _waterB = 0;
      _bulbA = _bulbB = 16;
      _pitcherParkedB = false;
      _holdTooltip = false;
      _pouringB = false;
      _calipers = const Offset(500, 720);
      _jawT = 0;
      _measuredA = _measuredB = false;
      _recordFor = null;
      _showReading = false;
      _markerT = 0;
      // Scenario 2 state.
      _app2T = 0;
      _guideT = 0;
      _holes = false;
      _spike = const Offset(850, 580);
      _botWater = 0;
      _tapFlowing = false;
      _draining = false;
      _jetsOn = false;
      _tapHandleY = 0;
      _tapStreamH = 0;
      _troughsDrag = const Offset(850, 450);
      _troughsPlaced = false;
      // Camera (source loadScenario -> resetCamera).
      _zoom = 1;
      _panOffset = Offset.zero;
      _drag = _Drag.none;
    });
  }

  void _restart() {
    setState(() {
      _panMode = false;
      _labelsOn = true;
    });
    _loadScenario(0, silent: true);
  }

  void _toStep(int step) {
    if (!mounted) return;
    setState(() => _step = step);
    if (step == 1 && _scenario == 1) {
      // Puncture step: guide line fades in (source updateHighlights).
      _tweens.run(0.5, (t) => _guideT = t);
    }
    if (step == 2 && _scenario == 1) {
      _tweens.run(0.5, (t) => _guideT = 1 - t);
    }
    if (step == 4) {
      // Source updateUI: the conclusion popup opens after a pause so the
      // student sees the final scene first (4.5 s in HTML, shortened here).
      final gen = _gen;
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (_alive(gen) && !_conclusionShown) _showConclusion();
      });
    }
  }

  void _showConclusion() {
    if (!mounted) return;
    setState(() {
      _conclusionShown = true;
      _completed = true;
    });
    _shell.setSidebarOpen(true);
    _rt_playSfx(_rt_Sfx.success); // source showConclusionPopup -> playSound('success')
    final s = _scenario == 0 ? 's1' : 's2';
    _rt_showShellPopup(
      context,
      title: _tx.s('observationComplete'),
      icon: Icons.check_circle,
      color: _cGreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tx.s('obsLbl'),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: _rt_Tw.amber600)),
          const SizedBox(height: 4),
          Text(_tx.s('${s}_obs'),
              style: TextStyle(fontSize: 13, height: 1.4, color: _rt_Lab.text)),
          const SizedBox(height: 12),
          Text(_tx.s('concLbl'),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: _rt_Tw.amber600)),
          const SizedBox(height: 4),
          Text(_tx.s('${s}_conc'),
              style: TextStyle(fontSize: 13, height: 1.4, color: _rt_Lab.text)),
        ],
      ),
    );
  }

  // ------------------------------------------- scenario 1: interactions ---
  void _setupApparatus() {
    if (_scenario != 0 || _step != 0) return;
    _rt_playSfx(_rt_Sfx.click); // source validateActionSVG click
    _tweens.run(1.0, (t) => _appT = t, curve: Curves.easeOut);
    _toStep(1);
  }

  /// Source autoFillPipeA: the whole GSAP timeline as chained tweens.
  void _runFillA() {
    if (_scenario != 0 || _step != 1 || _busy) return;
    setState(() => _busy = true);
    final gen = _gen;
    final from = _pitcher;
    _tweens.run(0.5, (t) {
      if (_alive(gen)) _pitcher = Offset.lerp(from, const Offset(250, 200), t)!;
    }, onDone: () {
      if (!_alive(gen)) return;
      _tweens.run(0.3, (t) => _tilt = t, onDone: () {
        if (!_alive(gen)) return;
        _rt_playSfx(_rt_Sfx.pop); // pour noise start (source startPourSound)
        _tweens.run(0.2, (t) => _streamH = 400 * t, onDone: () {
          if (!_alive(gen)) return;
          _tweens.run(1.5, (t) {
            _waterA = 150 * t;
            _bulbA = 16 + 10 * t;
          }, curve: Curves.linear, onDone: () {
            if (!_alive(gen)) return;
            _rt_playSfx(_rt_Sfx.pop); // pour noise stop
            _tweens.run(0.2, (t) => _streamH = 400 * (1 - t), onDone: () {
              if (!_alive(gen)) return;
              _tweens.run(0.3, (t) => _tilt = 1 - t, onDone: () {
                if (!_alive(gen)) return;
                final back = _pitcher;
                _tweens.run(0.5, (t) {
                  _pitcher =
                      Offset.lerp(back, const Offset(500, 170), t)!;
                }, onDone: () {
                  if (!_alive(gen)) return;
                  _rt_playSfx(_rt_Sfx.correct); // source playSound('success')
                  setState(() => _busy = false);
                  _toStep(2);
                });
              });
            });
          });
        });
      });
    });
  }

  /// Sidebar mirror of dragging the pitcher over Pipe B.
  void _parkPitcherAtB() {
    if (_scenario != 0 || _step != 2 || _pitcherParkedB || _pouringB) return;
    final gen = _gen;
    final from = _pitcher;
    _tweens.run(0.4, (t) {
      if (_alive(gen)) _pitcher = Offset.lerp(from, const Offset(700, 170), t)!;
    }, onDone: () {
      if (_alive(gen)) {
        setState(() {
          _pitcherParkedB = true;
          _holdTooltip = true;
        });
      }
    });
  }

  /// Source startManualFill (press-and-hold pour into Pipe B).
  void _startPourB() {
    if (_scenario != 0 || _step != 2 || !_pitcherParkedB || _pouringB) return;
    _rt_playSfx(_rt_Sfx.pop); // pour noise start
    setState(() {
      _pouringB = true;
      _holdTooltip = false;
    });
    final gen = _gen;
    final from = _pitcher;
    _tweens.run(0.2, (t) {
      if (!_alive(gen)) return;
      _pitcher = Offset.lerp(from, const Offset(700, 200), t)!;
      _tilt = t;
      _streamH = 400 * t;
    });
  }

  void _stopPourVisuals() {
    _tweens.run(0.2, (t) {
      _tilt = 1 - t;
      _streamH = 400 * (1 - t);
    });
  }

  /// Source validateManualFill.
  void _validatePour({bool autoStop = false}) {
    if (!_pouringB) return;
    _rt_playSfx(_rt_Sfx.pop); // pour noise stop
    setState(() => _pouringB = false);
    _stopPourVisuals();
    final gen = _gen;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_alive(gen)) return;
      final from = _pitcher;
      if (autoStop || (_waterB - 150).abs() < 5) {
        _rt_playSfx(_rt_Sfx.correct); // source playSound('success')
        setState(() {
          _waterB = 150;
          _bulbB = 26;
          _pitcherParkedB = false;
        });
        _tweens.run(0.5, (t) {
          _pitcher = Offset.lerp(from, const Offset(500, 170), t)!;
        });
        if (_step == 2) _toStep(3);
      } else {
        _toastErr('errHeight');
        setState(() => _pitcherParkedB = false);
        final w0 = _waterB, b0 = _bulbB;
        _tweens.run(0.5, (t) {
          _waterB = w0 * (1 - t);
          _bulbB = 16 + (b0 - 16) * (1 - t);
          _pitcher = Offset.lerp(from, const Offset(500, 170), t)!;
        });
      }
    });
  }

  /// Source checkCaliperPosition (after a drop or the sidebar buttons).
  void _caliperDropped() {
    final x = _calipers.dx;
    if (x > 150 && x < 350 && !_measuredA) {
      _rt_playSfx(_rt_Sfx.click);
      final gen = _gen;
      final from = _calipers;
      _tweens.run(0.2, (t) {
        if (_alive(gen)) {
          _calipers = Offset.lerp(from, const Offset(250, 700), t)!;
        }
      }, onDone: () {
        if (_alive(gen)) setState(() => _recordFor = 'A');
      });
    } else if (x > 600 && x < 800 && _measuredA && !_measuredB) {
      _rt_playSfx(_rt_Sfx.click);
      final gen = _gen;
      final from = _calipers;
      _tweens.run(0.2, (t) {
        if (_alive(gen)) {
          _calipers = Offset.lerp(from, const Offset(700, 700), t)!;
        }
      }, onDone: () {
        if (_alive(gen)) setState(() => _recordFor = 'B');
      });
    } else {
      setState(() => _recordFor = null);
      if (_measuredA && !_measuredB) {
        _rt_playSfx(_rt_Sfx.wrong);
        _toastInfo('measureB');
      }
    }
  }

  void _calipersToA() {
    if (_scenario != 0 || _step != 3 || _measuredA) return;
    setState(() => _calipers = const Offset(250, 720));
    _caliperDropped();
  }

  void _calipersToB() {
    if (_scenario != 0 || _step != 3 || _measuredB) return;
    if (!_measuredA) {
      // Same guidance as dropping the calipers at B too early.
      _rt_playSfx(_rt_Sfx.wrong);
      _toastInfo('measureB');
      return;
    }
    setState(() => _calipers = const Offset(700, 720));
    _caliperDropped();
  }

  /// Source recordMeasurement.
  void _record() {
    final pipe = _recordFor;
    if (pipe == null) return;
    _rt_playSfx(_rt_Sfx.correct); // source playSound('success')
    setState(() {
      _recordFor = null;
      _showReading = true;
    });
    _tweens.run(0.4, (t) => _jawT = t);
    _toastInfo(pipe == 'A' ? 'recorded22A' : 'recorded22B');
    final gen = _gen;
    if (pipe == 'A') {
      setState(() => _measuredA = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!_alive(gen)) return;
        final from = _calipers;
        setState(() => _showReading = false);
        _tweens.run(0.4, (t) {
          _calipers = Offset.lerp(from, const Offset(500, 720), t)!;
          _jawT = 1 - t;
        });
      });
    } else {
      setState(() => _measuredB = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!_alive(gen)) return;
        _rt_playSfx(_rt_Sfx.magic); // marker lines reveal
        _tweens.run(1.0, (t) => _markerT = t);
        _toStep(4);
      });
    }
  }

  // ------------------------------------------- scenario 2: interactions ---
  void _placeBottle() {
    if (_scenario != 1 || _step != 0) return;
    _rt_playSfx(_rt_Sfx.click);
    _tweens.run(1.0, (t) => _app2T = t, curve: Curves.easeOut);
    _toStep(1);
  }

  /// Source checkSpikePuncture on drop (also the sidebar button, which aims
  /// straight at the dotted line).
  void _spikeDropped() {
    final ok = _spike.dx > 350 &&
        _spike.dx < 650 &&
        (_spike.dy - 600).abs() < 25;
    final gen = _gen;
    if (ok) {
      _rt_playSfx(_rt_Sfx.click);
      final from = _spike;
      _tweens.run(0.2, (t) {
        if (_alive(gen)) _spike = Offset.lerp(from, const Offset(440, 600), t)!;
      }, onDone: () {
        if (!_alive(gen)) return;
        _rt_playSfx(_rt_Sfx.pop); // holes punched
        _rt_playSfx(_rt_Sfx.correct); // source playSound('success')
        setState(() => _holes = true);
        final back = _spike;
        _tweens.run(0.5, (t) {
          _spike = Offset.lerp(back, const Offset(850, 580), t)!;
        }, onDone: () {
          if (_alive(gen) && _step == 1) _toStep(2);
        });
      });
    } else {
      _toastErr('errPuncture');
      final from = _spike;
      _tweens.run(0.5, (t) {
        if (_alive(gen)) _spike = Offset.lerp(from, const Offset(850, 580), t)!;
      });
    }
  }

  void _spikeAuto() {
    if (_scenario != 1 || _step != 1 || _holes) return;
    setState(() => _spike = const Offset(500, 600));
    _spikeDropped();
  }

  /// Source startTapFlow.
  void _startTapFlow() {
    // The source keeps the tap usable from step 2 on ("drag it repeatedly
    // to test"), including after the conclusion.
    if (_scenario != 1 || _step < 2 || _tapFlowing) return;
    _rt_playSfx(_rt_Sfx.pop); // pour noise start
    setState(() {
      _tapFlowing = true;
      _draining = false;
    });
    _tweens.run(0.2, (t) => _tapStreamH = 80 * t);
  }

  /// Source stopTapFlow.
  void _stopTapFlow() {
    if (!_tapFlowing) return;
    _rt_playSfx(_rt_Sfx.pop); // pour noise stop
    setState(() => _tapFlowing = false);
    _tweens.run(0.2, (t) {
      _tapStreamH = 80 * (1 - t);
      _tapHandleY = _tapHandleY * (1 - t);
    });
    if (_botWater > 50) setState(() => _draining = true);
  }

  /// Source troughs placement (drop on table, table click, or button).
  void _placeTroughs() {
    if (_scenario != 1 || _step != 3 || _troughsPlaced) return;
    _rt_playSfx(_rt_Sfx.pop); // set down
    _rt_playSfx(_rt_Sfx.correct); // source playSound('success')
    setState(() => _troughsPlaced = true);
    _toStep(4);
  }

  // --------------------------------------------------- canvas transform ---
  double get _fitScale =>
      math.min(_canvasSize.width / 1000, _canvasSize.height / 800);

  Offset _toScene(Offset local) {
    final k = _fitScale * _zoom;
    final c = _canvasSize.center(Offset.zero) + _panOffset;
    return Offset((local.dx - c.dx) / k + 500, (local.dy - c.dy) / k + 400);
  }

  void _zoomBy(double f) {
    setState(() => _zoom = (_zoom * f).clamp(0.4, 3.0));
  }

  void _resetView() {
    setState(() {
      _zoom = 1;
      _panOffset = Offset.zero;
    });
  }

  // ------------------------------------------------------ pointer input ---
  Rect get _pitcherRect =>
      Rect.fromLTWH(_pitcher.dx - 25, _pitcher.dy - 25, 110, 150);
  Rect get _calipersRect => Rect.fromCenter(
      center: _calipers.translate(0, -10), width: 170, height: 130);
  Rect get _spikeRect =>
      Rect.fromLTWH(_spike.dx - 50, _spike.dy - 55, 160, 100);
  Rect get _tapHandleRect =>
      Rect.fromLTWH(515, 270 + _tapHandleY, 90, 40);
  Rect get _troughsRect =>
      Rect.fromCenter(center: _troughsDrag, width: 150, height: 110);
  Rect get _recordBtnRect =>
      Rect.fromLTWH(_calipers.dx + 135, _calipers.dy - 22, 115, 45);
  Rect get _setupBtnRect => const Rect.fromLTWH(370, 415, 260, 70);
  Rect get _bottleBtnRect => const Rect.fromLTWH(390, 415, 220, 70);
  Rect get _tableRect => const Rect.fromLTWH(150, 650, 700, 180);

  void _onPointerDown(PointerDownEvent e) {
    final sp = _toScene(e.localPosition);
    _downLocal = e.localPosition;
    _moved = false;
    _drag = _Drag.none;
    if (_panMode) {
      _drag = _Drag.pan;
      return;
    }
    if (_scenario == 0) {
      if (_step == 2 && _pitcherParkedB && !_busy) {
        // Source: any press while the pitcher waits at Pipe B pours.
        _startPourB();
        _drag = _Drag.pour;
      } else if ((_step == 1 || _step == 2) &&
          !_busy &&
          _pitcherRect.contains(sp)) {
        _rt_playSfx(_rt_Sfx.tap); // source playSound('click') on drag pickup
        _drag = _Drag.pitcher;
        _grabOffset = sp - _pitcher;
      } else if (_step == 3 && _calipersRect.contains(sp)) {
        _rt_playSfx(_rt_Sfx.tap);
        _drag = _Drag.calipers;
        _grabOffset = sp - _calipers;
        setState(() => _recordFor = null);
      }
    } else {
      if (_step == 1 && !_holes && _spikeRect.contains(sp)) {
        _rt_playSfx(_rt_Sfx.tap);
        _drag = _Drag.spike;
        _grabOffset = sp - _spike;
      } else if (_step >= 2 && _tapHandleRect.contains(sp)) {
        _rt_playSfx(_rt_Sfx.tap);
        _drag = _Drag.tapHandle;
        _handleY0 = _tapHandleY;
        _downSceneY = sp.dy;
        _startTapFlow();
      } else if (_step == 3 && !_troughsPlaced && _troughsRect.contains(sp)) {
        _rt_playSfx(_rt_Sfx.tap);
        _drag = _Drag.troughs;
        _grabOffset = sp - _troughsDrag;
      }
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    if ((e.localPosition - _downLocal).distance > 6) _moved = true;
    final sp = _toScene(e.localPosition);
    switch (_drag) {
      case _Drag.pan:
        setState(() => _panOffset += e.delta);
      case _Drag.pitcher:
        setState(() => _pitcher = sp - _grabOffset);
      case _Drag.pour:
        // Source: moving the pitcher while pouring spills — stop + toast.
        if ((e.localPosition - _downLocal).distance > 14 && _pouringB) {
          setState(() => _pouringB = false);
          _stopPourVisuals();
          _toastErr('errPitcher');
          final gen = _gen;
          final from = _pitcher, w0 = _waterB, b0 = _bulbB;
          setState(() => _pitcherParkedB = false);
          _tweens.run(0.5, (t) {
            if (!_alive(gen)) return;
            _waterB = w0 * (1 - t);
            _bulbB = 16 + (b0 - 16) * (1 - t);
            _pitcher = Offset.lerp(from, const Offset(500, 170), t)!;
          });
          _drag = _Drag.none;
        }
      case _Drag.calipers:
        setState(() => _calipers = sp - _grabOffset);
      case _Drag.spike:
        setState(() => _spike = sp - _grabOffset);
      case _Drag.tapHandle:
        setState(() =>
            _tapHandleY = (_handleY0 + sp.dy - _downSceneY).clamp(0.0, 40.0));
      case _Drag.troughs:
        setState(() => _troughsDrag = sp - _grabOffset);
      case _Drag.none:
        break;
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    final sp = _toScene(e.localPosition);
    final drag = _drag;
    _drag = _Drag.none;

    // Click detection (source handleStopDrag dx<5 branch).
    if (!_moved && (drag == _Drag.none || drag == _Drag.pan)) {
      if (_scenario == 0 && _step == 0 && _setupBtnRect.contains(sp)) {
        _setupApparatus();
        return;
      }
      if (_scenario == 1 && _step == 0 && _bottleBtnRect.contains(sp)) {
        _placeBottle();
        return;
      }
      if (_scenario == 0 &&
          _step == 3 &&
          _recordFor != null &&
          _recordBtnRect.contains(sp)) {
        _record();
        return;
      }
      if (_scenario == 1 && _step == 3 && _tableRect.contains(sp)) {
        // Source: clicking the table also validates the troughs step.
        _placeTroughs();
        return;
      }
      return;
    }

    switch (drag) {
      case _Drag.pour:
        _validatePour();
      case _Drag.pitcher:
        if (_step == 1) {
          if (_pitcher.dx > 150 && _pitcher.dx < 350) {
            _runFillA();
          } else {
            final from = _pitcher;
            _tweens.run(0.5,
                (t) => _pitcher = Offset.lerp(from, const Offset(500, 170), t)!);
          }
        } else if (_step == 2) {
          if (_pitcher.dx > 600 && _pitcher.dx < 850) {
            final from = _pitcher;
            _tweens.run(0.3, (t) {
              _pitcher = Offset.lerp(from, const Offset(700, 170), t)!;
            }, onDone: () {
              setState(() {
                _pitcherParkedB = true;
                _holdTooltip = true;
              });
            });
          } else {
            setState(() {
              _pitcherParkedB = false;
              _holdTooltip = false;
            });
            final from = _pitcher;
            _tweens.run(0.5,
                (t) => _pitcher = Offset.lerp(from, const Offset(500, 170), t)!);
          }
        }
      case _Drag.calipers:
        _caliperDropped();
      case _Drag.spike:
        if (!_moved) {
          final from = _spike;
          _tweens.run(0.3,
              (t) => _spike = Offset.lerp(from, const Offset(850, 580), t)!);
        } else {
          _spikeDropped();
        }
      case _Drag.tapHandle:
        _stopTapFlow();
      case _Drag.troughs:
        if (_troughsDrag.dx > 300 &&
            _troughsDrag.dx < 700 &&
            _troughsDrag.dy > 500 &&
            _troughsDrag.dy < 750) {
          _placeTroughs();
        } else {
          final from = _troughsDrag;
          _tweens.run(0.5, (t) =>
              _troughsDrag = Offset.lerp(from, const Offset(850, 450), t)!);
        }
      case _Drag.pan:
      case _Drag.none:
        break;
    }
  }

  void _onPointerCancel(PointerCancelEvent e) {
    final drag = _drag;
    _drag = _Drag.none;
    if (drag == _Drag.pour) _validatePour();
    if (drag == _Drag.tapHandle) _stopTapFlow();
  }

  // ----------------------------------------------------------------- UI ---
  double get _progress => _completed ? 1 : (_step / 4).clamp(0.0, 1.0);

  String get _instText =>
      _tx.s('${_scenario == 0 ? 's1' : 's2'}_inst.$_step');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(builder: (context, lang) {
        return _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('title'),
          subtitle: _tx.s('sub'),
          canvasBackground: _rt_Tw.slate900,
          theme: const _rt_ShellTheme(
            accent: _cAccent,
            headerGradient: [_rt_Tw.slate900, Color(0xFF4C0519)],
            headerSubtitleColor: _rt_Tw.amber200,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('sub'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.water_drop,
          ),
          onRestart: _restart,
          onZoomIn: () => _zoomBy(1.2),
          onZoomOut: () => _zoomBy(1 / 1.2),
          onResetView: _resetView,
          toolbarExtras: [
            _toolToggle(
              key: 'pan-toggle',
              active: _panMode,
              icon: Icons.pan_tool_alt,
              tooltip: _tx.s('tool_pan'),
              onTap: () => setState(() => _panMode = !_panMode),
            ),
            const SizedBox(height: 4),
            _toolToggle(
              key: 'labels-toggle',
              active: _labelsOn,
              icon: Icons.label,
              tooltip: _tx.s('tool_labels'),
              onTap: () => setState(() => _labelsOn = !_labelsOn),
            ),
          ],
          hint: _rt_StepHint(
            number: _completed ? '✓' : '${_step + 1}',
            label: _tx.s('lbl_task'),
            text: _completed ? _tx.s('complete') : _instText,
          ),
          sidebarTop: _scenarioSelector(),
          tabs: [
            _rt_ShellTab(
              label: _tx.s('lbl_task'),
              icon: Icons.science,
              builder: (_) => _sidebar(),
            ),
          ],
          canvas: LayoutBuilder(builder: (context, c) {
            _canvasSize = Size(c.maxWidth, c.maxHeight);
            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              child: CustomPaint(
                size: Size.infinite,
                painter: _LiquidLabPainter(this),
              ),
            );
          }),
          canvasOverlays: [
            Positioned(
              top: 12,
              left: 70,
              right: 70,
              child: IgnorePointer(child: Center(child: _hudBanner())),
            ),
          ],
        );
      }),
    );
  }

  Widget _toolToggle({
    required String key,
    required bool active,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        key: ValueKey(key),
        radius: 22,
        onTap: () {
          _rt_playSfx(_rt_Sfx.toggle);
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _cAccent : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
        ),
      ),
    );
  }

  Widget _hudBanner() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 8),
      decoration: BoxDecoration(
        color: _rt_Tw.slate900.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.slate700),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12)
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: _cAccent, borderRadius: BorderRadius.circular(8)),
          child: Text(_tx.s('interactiveTask'),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: _rt_Tw.slate900)),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_completed ? _tx.s('complete') : _instText,
                  key: const ValueKey('hud-instruction'),
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25)),
              const SizedBox(height: 5),
              Row(children: [
                Text(_tx.s('lbl_progress').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: _rt_Tw.slate400)),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      height: 5,
                      color: _rt_Tw.slate700,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progress,
                        child: Container(color: _cAccent),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  // ----------------------------------------------------------- sidebar ----
  Widget _scenarioSelector() {
    return Container(
      color: _rt_Lab.base,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('lbl_select_scenario'), icon: Icons.tune),
          for (var i = 0; i < 2; i++)
            KeyedSubtree(
              key: ValueKey('scen-$i'),
              child: _rt_ChoiceButton(
                label: _tx.s(i == 0 ? 's1_name' : 's2_name'),
                state: _scenario == i ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
                onTap: _scenario == i ? null : () => _loadScenario(i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebar() {
    final s = _scenario == 0 ? 's1' : 's2';
    final titles = _tx.list('${s}_titles');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObj'),
          desc: _tx.s('${s}_obj'),
          accent: _rt_Tw.amber600,
          icon: Icons.flag,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < titles.length; i++)
                _stepRow(i, titles[i] as String),
              const SizedBox(height: 10),
              _rt_SectionLabel(
                  '${_tx.s('stepText')} ${_step + 1}: ${_tx.s('${s}_titles.$_step')}',
                  icon: Icons.menu_book),
              Text(_tx.s('${s}_theory.$_step'),
                  style: TextStyle(fontSize: 12, height: 1.45, color: _rt_Lab.textMuted)),
              const SizedBox(height: 8),
              if (!_completed)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _rt_Lab.tinted(const Color(0xFFFEF9C3), _rt_Tw.amber600),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                        left: BorderSide(color: _cAccent, width: 3)),
                  ),
                  child: Text(_instText,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: _rt_Lab.text)),
                )
              else
                _rt_InfoCard(
                  title: _tx.s('complete'),
                  body: _tx.s('${s}_conc'),
                  color: _rt_Tw.green600,
                  icon: Icons.emoji_events,
                ),
              const SizedBox(height: 10),
              _rt_SectionLabel(_tx.s('lbl_controls'), icon: Icons.videogame_asset),
              ..._controlButtons(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepRow(int i, String title) {
    final done = _completed || _step > i;
    final current = !_completed && _step == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
          done
              ? Icons.check_circle
              : (current ? Icons.pending : Icons.circle_outlined),
          size: 16,
          color: done ? _rt_Tw.green500 : (current ? _cAccent : _rt_Lab.textFaint),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                color: done ? _rt_Lab.textFaint : _rt_Lab.text,
                decoration: done ? TextDecoration.lineThrough : null,
              )),
        ),
      ]),
    );
  }

  /// Every canvas drag mirrored as a sidebar control (small-screen + test
  /// accessibility, per project convention).
  List<Widget> _controlButtons() {
    Widget btn(String key, String label, IconData icon, bool enabled,
        VoidCallback onTap,
        {bool done = false, Color color = _rt_Tw.amber600}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _rt_ActionButton(
          key: ValueKey(key),
          label: label,
          icon: icon,
          color: color,
          expand: true,
          done: done,
          onPressed: enabled ? onTap : null,
        ),
      );
    }

    if (_scenario == 0) {
      return [
        btn('btn-setup', _tx.s('btn_setup'), Icons.build, _step == 0,
            _setupApparatus,
            done: _step > 0),
        btn('btn-fillA', _tx.s('btn_fillA'), Icons.local_drink,
            _step == 1 && !_busy, _runFillA,
            done: _step > 1, color: _rt_Tw.blue600),
        btn('btn-toB', _tx.s('btn_toB'), Icons.swap_horiz,
            _step == 2 && !_pitcherParkedB && !_pouringB, _parkPitcherAtB,
            done: _step > 2, color: _rt_Tw.blue600),
        if (_step == 2 && _pitcherParkedB)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HoldButton(
              key: const ValueKey('btn-pour'),
              label: _tx.s('btn_pour'),
              icon: Icons.touch_app,
              color: _rt_Tw.sky500,
              onDown: _startPourB,
              onUp: () => _validatePour(),
            ),
          ),
        btn('btn-calA', _tx.s('btn_calA'), Icons.straighten,
            _step == 3 && !_measuredA && !_showReading, _calipersToA,
            done: _measuredA, color: _rt_Tw.teal600),
        btn('btn-record', _tx.s('btn_record'), Icons.fiber_manual_record,
            _step == 3 && _recordFor != null, _record,
            done: _measuredB, color: _rt_Tw.green600),
        btn('btn-calB', _tx.s('btn_calB'), Icons.straighten,
            _step == 3 && !_measuredB && !_showReading, _calipersToB,
            done: _measuredB, color: _rt_Tw.teal600),
        if (_step == 4)
          btn('btn-view', _tx.s('btn_view'), Icons.visibility, true,
              _showConclusion, color: _rt_Tw.green600),
      ];
    }
    return [
      btn('btn-bottle', _tx.s('btn_bottle'), Icons.liquor, _step == 0,
          _placeBottle,
          done: _step > 0),
      btn('btn-spike', _tx.s('btn_spike'), Icons.push_pin, _step == 1 && !_holes,
          _spikeAuto,
          done: _holes, color: _rt_Tw.red600),
      if (_step >= 2)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _HoldButton(
            key: const ValueKey('btn-tap'),
            label: _tx.s('btn_tap'),
            icon: Icons.touch_app,
            color: _rt_Tw.sky500,
            onDown: _startTapFlow,
            onUp: _stopTapFlow,
          ),
        ),
      btn('btn-troughs', _tx.s('btn_troughs'), Icons.soup_kitchen,
          _step == 3 && !_troughsPlaced, _placeTroughs,
          done: _troughsPlaced, color: _rt_Tw.teal600),
      if (_step == 4)
        btn('btn-view', _tx.s('btn_view'), Icons.visibility, true,
            _showConclusion, color: _rt_Tw.green600),
    ];
  }
}

/// Press-and-hold pill button (the source's "hold mouse to pour" gesture).
class _HoldButton extends StatefulWidget {
  const _HoldButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onDown,
    required this.onUp,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  bool _pressed = false;

  // The button can leave the tree mid-press (a successful pour advances the
  // step and removes it), so every pointer callback checks `mounted`.
  void _release() {
    if (!_pressed) return;
    _pressed = false;
    if (mounted) setState(() {});
    widget.onUp();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (!mounted) return;
        _rt_playSfx(_rt_Sfx.tap);
        setState(() => _pressed = true);
        widget.onDown();
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: Material(
        color: _pressed
            ? Color.lerp(widget.color, Colors.black, 0.25)
            : widget.color,
        shape: const StadiumBorder(),
        elevation: _pressed ? 0 : 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
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
          ),
        ),
      ),
    );
  }
}

/// Paints the 1000×800 SVG scene of the source.
class _LiquidLabPainter extends CustomPainter {
  _LiquidLabPainter(this.s);

  final _Cl8Ch06A2LiquidPressurePageState s;

  @override
  void paint(Canvas canvas, Size size) {
    // Background: navy -> dark maroon gradient (source --bg-start/--bg-end).
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF4C0519)],
        ).createShader(Offset.zero & size),
    );

    final k = s._fitScale * s._zoom;
    final c = size.center(Offset.zero) + s._panOffset;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(k);
    canvas.translate(-500, -400);

    _grid(canvas);
    if (s._scenario == 0) {
      _scene1(canvas);
    } else {
      _scene2(canvas);
    }
    canvas.restore();
  }

  // ------------------------------------------------------------ helpers ---
  void _grid(Canvas canvas) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.5;
    for (var x = -500.0; x <= 1500; x += 50) {
      canvas.drawLine(Offset(x, -400), Offset(x, 1200), p);
    }
    for (var y = -400.0; y <= 1200; y += 50) {
      canvas.drawLine(Offset(-500, y), Offset(1500, y), p);
    }
  }

  void _text(Canvas canvas, String text, Offset at,
      {double size = 16,
      Color color = Colors.white,
      FontWeight weight = FontWeight.bold,
      TextAlign align = TextAlign.center,
      double opacity = 1}) {
    if (opacity <= 0.02) return;
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: size,
              fontWeight: weight,
              color: color.withValues(alpha: color.a * opacity))),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      TextAlign.left => at.dx,
      TextAlign.right => at.dx - tp.width,
      _ => at.dx - tp.width / 2,
    };
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint,
      {double dash = 8, double gap = 8}) {
    final total = (b - a).distance;
    if (total <= 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final e = math.min(d + dash, total);
      canvas.drawLine(a + dir * d, a + dir * e, paint);
      d = e + gap;
    }
  }

  void _yellowPill(Canvas canvas, Rect r, String label) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r.inflate(6), Radius.circular(r.height)),
      Paint()
        ..color = _cYellow.withValues(alpha: 0.35)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(r.height / 2)),
      Paint()..color = _cYellow,
    );
    _text(canvas, label, r.center,
        size: 19, color: Colors.black, weight: FontWeight.w900);
  }

  // ------------------------------------------------------- scenario 1 ---
  void _scene1(Canvas canvas) {
    if (s._step == 0) {
      _yellowPill(canvas, const Rect.fromLTWH(370, 415, 260, 70),
          _tx.s('svg.setupApparatus'));
      return;
    }
    final op = s._appT;
    if (op > 0) {
      _pipe(canvas, op,
          pipeX: 230,
          pipeW: 40,
          rulerX: 180,
          ticksRight: true,
          water: s._waterA,
          waterX: 232,
          waterW: 36,
          shineX: 240,
          shineW: 2,
          labelD: _tx.s('svg.dA'),
          labelDAt: const Offset(250, 220),
          label15: _tx.s('svg.cm15L'),
          label15At: const Offset(110, 450),
          label15Align: TextAlign.left);
      _balloon(canvas, const Offset(250, 600), 20, s._bulbA, op);

      _pipe(canvas, op,
          pipeX: 640,
          pipeW: 120,
          rulerX: 780,
          ticksRight: false,
          water: s._waterB,
          waterX: 642,
          waterW: 116,
          shineX: 655,
          shineW: 4,
          labelD: _tx.s('svg.dB'),
          labelDAt: const Offset(700, 220),
          label15: _tx.s('svg.cm15R'),
          label15At: const Offset(890, 450),
          label15Align: TextAlign.right);
      _balloon(canvas, const Offset(700, 600), 60, s._bulbB, op);

      // Marker lines (green equal-height, red identical-bulge).
      if (s._markerT > 0.02) {
        final m = s._markerT;
        final green = Paint()
          ..color = _cGreen.withValues(alpha: m)
          ..strokeWidth = 3;
        _dashedLine(canvas, const Offset(180, 450), const Offset(850, 450), green);
        _text(canvas, _tx.s('svg.equalHeight'), const Offset(500, 435),
            size: 20, color: _cGreen, opacity: m);
        final red = Paint()
          ..color = _cRed.withValues(alpha: m)
          ..strokeWidth = 3;
        _dashedLine(canvas, const Offset(220, 685), const Offset(730, 685), red);
        _text(canvas, _tx.s('svg.identicalBulge'), const Offset(475, 668),
            size: 20, color: _cRed, opacity: m);
      }
    }

    if (s._step >= 3) _calipersDraw(canvas);
    if (s._step == 1 || s._step == 2) _pitcherDraw(canvas);
  }

  void _pipe(Canvas canvas, double op,
      {required double pipeX,
      required double pipeW,
      required double rulerX,
      required bool ticksRight,
      required double water,
      required double waterX,
      required double waterW,
      required double shineX,
      required double shineW,
      required String labelD,
      required Offset labelDAt,
      required String label15,
      required Offset label15At,
      required TextAlign label15Align}) {
    // Ruler body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(rulerX, 250, 30, 350), const Radius.circular(3)),
      Paint()..color = _cRulerFill.withValues(alpha: op),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(rulerX, 250, 30, 350), const Radius.circular(3)),
      Paint()
        ..color = _cRulerStroke.withValues(alpha: op)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Ticks (source generateRulers): every cm from the bottom, red 15 cm mark.
    final tickX = ticksRight ? rulerX : rulerX + 30;
    final dir = ticksRight ? 1.0 : -1.0;
    for (var i = 0; i <= 35; i++) {
      final y = 600.0 - i * 10;
      final major = i % 5 == 0;
      canvas.drawLine(
        Offset(tickX, y),
        Offset(tickX + dir * (major ? 14 : 7), y),
        Paint()
          ..color = _cRulerStroke.withValues(alpha: op)
          ..strokeWidth = major ? 2 : 1,
      );
    }
    canvas.drawLine(
      Offset(tickX, 450),
      Offset(tickX + dir * 30, 450),
      Paint()
        ..color = _cRed.withValues(alpha: op)
        ..strokeWidth = 3,
    );
    // Pipe walls + water column + shine line.
    final pipeRect = Rect.fromLTWH(pipeX, 250, pipeW, 350);
    canvas.drawRRect(
        RRect.fromRectAndRadius(pipeRect, const Radius.circular(2)),
        Paint()..color = _cPipeFill.withValues(alpha: _cPipeFill.a * op));
    canvas.drawRRect(
      RRect.fromRectAndRadius(pipeRect, const Radius.circular(2)),
      Paint()
        ..color = _cPipeStroke.withValues(alpha: op)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    if (water > 0) {
      canvas.drawRect(
        Rect.fromLTWH(waterX, 600 - water, waterW, water),
        Paint()..color = _cWater.withValues(alpha: 0.85 * op),
      );
    }
    canvas.drawLine(
      Offset(shineX, 255),
      Offset(shineX, 595),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * op)
        ..strokeWidth = shineW,
    );
    if (s._labelsOn) {
      _text(canvas, labelD, labelDAt, size: 20, opacity: op);
      _text(canvas, label15, label15At,
          size: 16, align: label15Align, opacity: op);
    }
  }

  void _balloon(
      Canvas canvas, Offset at, double halfW, double bulb, double op) {
    final fill = Paint()..color = _cBalloon.withValues(alpha: op);
    final stroke = Paint()
      ..color = _cBalloonStroke.withValues(alpha: op)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final funnel = Path()
      ..moveTo(at.dx - halfW, at.dy)
      ..lineTo(at.dx + halfW, at.dy)
      ..lineTo(at.dx + 6, at.dy + 25)
      ..lineTo(at.dx - 6, at.dy + 25)
      ..close();
    canvas.drawPath(funnel, fill);
    canvas.drawPath(funnel, stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(at.dx - 8, at.dy + 25, 16, 8),
          const Radius.circular(3)),
      Paint()..color = _cBalloonNeck.withValues(alpha: op),
    );
    canvas.drawCircle(Offset(at.dx, at.dy + 50), bulb, fill);
    canvas.drawCircle(Offset(at.dx, at.dy + 50), bulb, stroke);
  }

  void _pitcherDraw(Canvas canvas) {
    final at = s._pitcher;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    // Falling stream (unrotated, from the spout at the local origin).
    if (s._streamH > 0) {
      canvas.drawRect(Rect.fromLTWH(-4, 0, 8, s._streamH),
          Paint()..color = _cWater.withValues(alpha: 0.9));
    }
    canvas.save();
    canvas.rotate(-math.pi / 4 * s._tilt);
    // Handle.
    final handle = Path()
      ..moveTo(60, 30)
      ..cubicTo(90, 30, 90, 55, 90, 70)
      ..cubicTo(90, 90, 75, 90, 60, 90);
    canvas.drawPath(
        handle,
        Paint()
          ..color = _cBeakerHandle
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round);
    // Body (spout at origin).
    final body = Path()
      ..moveTo(0, 0)
      ..lineTo(15, 20)
      ..lineTo(70, 20)
      ..lineTo(70, 120)
      ..lineTo(10, 120)
      ..lineTo(10, 20)
      ..close();
    canvas.drawPath(body, Paint()..color = _cBeakerGlass);
    canvas.drawPath(
        body,
        Paint()
          ..color = _cBeakerStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    // Water inside (level falls while pouring B, like the source's morphs).
    final lvl = 40 + (s._waterB / 150 * 40).clamp(0.0, 40.0);
    canvas.drawPath(
        Path()
          ..moveTo(12, lvl)
          ..lineTo(68, lvl)
          ..lineTo(68, 118)
          ..lineTo(12, 118)
          ..close(),
        Paint()..color = _cWater.withValues(alpha: 0.8));
    canvas.restore();
    canvas.restore();
    // "Hold to pour" tooltip bubble.
    if (s._holdTooltip) {
      // Below the cup: the shell's floating HUD covers the area above it.
      final r = Rect.fromCenter(
          center: at.translate(40, 165), width: 230, height: 34);
      final tip = Path()
        ..moveTo(r.center.dx - 5, r.top)
        ..lineTo(r.center.dx + 5, r.top)
        ..lineTo(r.center.dx, r.top - 8)
        ..close();
      canvas.drawPath(tip, Paint()..color = _cRed);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(17)),
          Paint()..color = _cRed);
      _text(canvas, _tx.s('svg.clickHoldPour'), r.center, size: 14);
    }
  }

  void _calipersDraw(Canvas canvas) {
    final at = s._calipers;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    // Jaws slide inwards as jawT closes on the 22 mm bulge.
    final jawX = ui.lerpDouble(60, 30, s._jawT)!;
    for (final side in [-1.0, 1.0]) {
      final outer = side * jawX;
      final inner = side * (jawX - 15);
      final jaw = Path()
        ..moveTo(outer, -15)
        ..lineTo(outer, -70)
        ..lineTo(inner, -70)
        ..lineTo(inner, -15)
        ..close();
      canvas.drawPath(jaw, Paint()..color = _cCaliperJaw);
      canvas.drawPath(
          jaw,
          Paint()
            ..color = _cCaliperJawStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-60, -15, 120, 30), const Radius.circular(5)),
      Paint()..color = _cCaliperBase,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-60, -15, 120, 30), const Radius.circular(5)),
      Paint()
        ..color = _cBowlStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-40, -4, 80, 8), const Radius.circular(4)),
      Paint()..color = _cCaliperSlider,
    );
    if (s._labelsOn) {
      _text(
          canvas,
          s._showReading
              ? _tx.s('svg.reading22')
              : _tx.s('svg.dragNearBalloon'),
          const Offset(0, 38),
          size: 16);
    }
    canvas.restore();
    // Record button next to the calipers.
    if (s._recordFor != null) {
      final r = Rect.fromLTWH(at.dx + 140, at.dy - 15, 105, 32);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(16)),
          Paint()..color = _cGreen);
      _text(canvas, _tx.s('svg.record'), r.center, size: 15);
    }
  }

  // ------------------------------------------------------- scenario 2 ---
  void _scene2(Canvas canvas) {
    if (s._step == 0) {
      _yellowPill(canvas, const Rect.fromLTWH(390, 415, 220, 70),
          _tx.s('svg.placeBottle'));
      return;
    }
    final op = s._app2T;
    if (op <= 0) return;

    // Table + legs.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(150, 650, 700, 30), const Radius.circular(6)),
      Paint()..color = _cTableTop.withValues(alpha: op),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(150, 650, 700, 30), const Radius.circular(6)),
      Paint()
        ..color = _cTableLeg.withValues(alpha: op)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRect(const Rect.fromLTWH(200, 680, 30, 120),
        Paint()..color = _cTableLeg.withValues(alpha: op));
    canvas.drawRect(const Rect.fromLTWH(770, 680, 30, 120),
        Paint()..color = _cTableLeg.withValues(alpha: op));

    // Bottle (source path, translated to x = 500).
    final bottle = Path()
      ..moveTo(480, 350)
      ..lineTo(520, 350)
      ..lineTo(520, 390)
      ..quadraticBezierTo(560, 420, 560, 450)
      ..lineTo(560, 650)
      ..lineTo(440, 650)
      ..lineTo(440, 450)
      ..quadraticBezierTo(440, 420, 480, 390)
      ..close();
    // Water clipped inside the bottle.
    if (s._botWater > 0) {
      canvas.save();
      canvas.clipPath(bottle);
      canvas.drawRect(
        Rect.fromLTWH(440, 650 - s._botWater, 120, s._botWater),
        Paint()..color = _cWater.withValues(alpha: 0.85 * op),
      );
      canvas.restore();
    }
    canvas.drawPath(
        bottle, Paint()..color = _cPipeFill.withValues(alpha: _cPipeFill.a * op));
    canvas.drawPath(
        bottle,
        Paint()
          ..color = _cPipeStroke.withValues(alpha: op)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);

    // h = 5 cm guide line.
    if (s._guideT > 0.02) {
      final g = s._guideT;
      _dashedLine(
          canvas,
          const Offset(400, 600),
          const Offset(600, 600),
          Paint()
            ..color = _cRed.withValues(alpha: g)
            ..strokeWidth = 3);
      if (s._labelsOn) {
        _text(canvas, _tx.s('svg.h5cm'), const Offset(655, 602),
            size: 20, color: _cRed, opacity: g);
      }
    }

    // Holes.
    if (s._holes) {
      for (final dx in [-58.0, -20.0, 20.0, 58.0]) {
        canvas.drawCircle(Offset(500 + dx, 600), 5,
            Paint()..color = Colors.black.withValues(alpha: op));
      }
    }

    // Jets (progress from the fill level, exactly the source's dash offset).
    final jetP = ((s._botWater - 50) * 1.75 / 350).clamp(0.0, 1.0);
    if (s._jetsOn && jetP > 0) {
      final jets = <(Path, double)>[
        (
          Path()
            ..moveTo(442, 600)
            ..quadraticBezierTo(350, 600, 250, 640),
          8
        ),
        (
          Path()
            ..moveTo(558, 600)
            ..quadraticBezierTo(650, 600, 750, 640),
          8
        ),
        (
          Path()
            ..moveTo(480, 600)
            ..quadraticBezierTo(420, 600, 350, 660),
          6
        ),
        (
          Path()
            ..moveTo(520, 600)
            ..quadraticBezierTo(580, 600, 650, 660),
          6
        ),
      ];
      for (final (path, w) in jets) {
        for (final metric in path.computeMetrics()) {
          canvas.drawPath(
            metric.extractPath(0, metric.length * jetP),
            Paint()
              ..color = _cWater
              ..style = PaintingStyle.stroke
              ..strokeWidth = w
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }

    // Placed troughs + distance markers.
    if (s._troughsPlaced) {
      _bowl(canvas, const Offset(250, 640), 1, true);
      _bowl(canvas, const Offset(750, 640), 1, true);
      _bowl(canvas, const Offset(350, 660), 0.7, true);
      _bowl(canvas, const Offset(650, 660), 0.7, true);
      final green = Paint()
        ..color = _cGreen
        ..strokeWidth = 4;
      canvas.drawLine(const Offset(250, 695), const Offset(500, 695), green);
      canvas.drawLine(const Offset(500, 695), const Offset(750, 695), green);
      if (s._labelsOn) {
        _text(canvas, _tx.s('svg.distanceD'), const Offset(375, 720),
            size: 20, color: _cGreen);
        _text(canvas, _tx.s('svg.distanceD'), const Offset(625, 720),
            size: 20, color: _cGreen);
      }
    }

    // Tap (visible once punctured).
    if (s._step >= 2) _tapDraw(canvas);

    // Draggable spike tool.
    if (s._step >= 1 && !s._troughsPlaced) _spikeDraw(canvas);

    // Draggable troughs tool.
    if (s._step == 3 && !s._troughsPlaced) {
      final at = s._troughsDrag;
      _bowl(canvas, at.translate(-25, 0), 0.6, false);
      _bowl(canvas, at.translate(25, 0), 0.6, false);
      if (s._labelsOn) {
        _text(canvas, _tx.s('svg.troughs'), at.translate(0, -38),
            size: 16, color: _cYellow);
      }
    }
  }

  void _bowl(Canvas canvas, Offset at, double scale, bool withWater) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(scale);
    final stroke = Paint()
      ..color = _cBowlStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    // Bowl body (lower half-ellipse) + rim.
    final body = Path()
      ..moveTo(-45, 0)
      ..arcTo(Rect.fromCenter(
              center: Offset.zero, width: 90, height: 70),
          math.pi, -math.pi, false)
      ..close();
    canvas.drawPath(body, Paint()..color = _cBowlBody);
    canvas.drawPath(body, stroke);
    final rim = Rect.fromCenter(center: Offset.zero, width: 90, height: 20);
    canvas.drawOval(rim, Paint()..color = _cBowlRim);
    canvas.drawOval(rim, stroke);
    if (withWater) {
      canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, 4), width: 70, height: 12),
          Paint()..color = _cWater.withValues(alpha: 0.6));
    }
    if (s._labelsOn) {
      _text(canvas, _tx.s('svg.bowl'), const Offset(0, 24),
          size: 13, color: const Color(0xFF0F172A));
    }
    canvas.restore();
  }

  void _spikeDraw(Canvas canvas) {
    final at = s._spike;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.save();
    canvas.rotate(-15 * math.pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, -10, 100, 20), const Radius.circular(4)),
      Paint()..color = _cSpikeHandle,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, -10, 100, 20), const Radius.circular(4)),
      Paint()
        ..color = _cRulerStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tip = Path()
      ..moveTo(0, -6)
      ..lineTo(-40, 0)
      ..lineTo(0, 6)
      ..close();
    canvas.drawPath(tip, Paint()..color = _cSpikeTip);
    canvas.drawPath(
        tip,
        Paint()
          ..color = _cSpikeTipStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.restore();
    if (s._labelsOn) {
      _text(canvas, _tx.s('svg.heatedSpike'), const Offset(30, -34),
          size: 14, color: _cYellow);
    }
    canvas.restore();
  }

  void _tapDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(500, 200);
    // Stream.
    if (s._tapStreamH > 0) {
      canvas.drawRect(Rect.fromLTWH(-10, 180, 20, s._tapStreamH),
          Paint()..color = _cWater.withValues(alpha: 0.85));
    }
    // Pipe body + spout.
    canvas.drawRect(const Rect.fromLTWH(-20, 0, 40, 150),
        Paint()..color = _cTapBody);
    canvas.drawRect(
        const Rect.fromLTWH(-20, 0, 40, 150),
        Paint()
          ..color = _cTapStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    final spout = Path()
      ..moveTo(-25, 150)
      ..lineTo(25, 150)
      ..lineTo(15, 180)
      ..lineTo(-15, 180)
      ..close();
    canvas.drawPath(spout, Paint()..color = _cTapSpout);
    canvas.drawPath(
        spout,
        Paint()
          ..color = _cBowlStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    // Handle (drags down 0..40).
    final hr = Rect.fromLTWH(20, 80 + s._tapHandleY, 70, 16);
    canvas.drawRRect(RRect.fromRectAndRadius(hr, const Radius.circular(4)),
        Paint()..color = _cHandle);
    canvas.drawRRect(
        RRect.fromRectAndRadius(hr, const Radius.circular(4)),
        Paint()
          ..color = _cHandleStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    if (s._labelsOn) {
      _text(canvas, _tx.s('svg.dragDown'), Offset(100, 88 + s._tapHandleY),
          size: 14, align: TextAlign.left);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidLabPainter oldDelegate) => true;
}
