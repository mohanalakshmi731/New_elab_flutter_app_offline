// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 10.2: Laws of Reflection
// Converted from Cl8S-Ch10-A2-LawsofReflection.html
// (three.js orthographic 2D-in-3D -> CustomPainter in a ZoomableCanvas).
//
// Two guided scenarios picked from the sidebar:
// (1) Measuring Angles - drag the orange ruler to the mirror centre to draw
//     the Normal, aim the flashlight, drop the protractor on Point O and
//     click the incident / reflected beams to capture angle i and angle r,
//     then verify i = r (First Law).
// (2) Plane of Reflection - power on the laser over a flat sheet of paper,
//     bend the lower half of the paper down (the reflected ray vanishes),
//     flatten it again (the ray reappears) and conclude that the incident
//     ray, normal and reflected ray share one plane (Second Law).
//
// Every canvas drag/click has a sidebar button twin; the flashlight also has
// a beam-angle slider. The geometry mirrors the source exactly: the beam
// pivots on Point O at radius 10, i = |theta - 90deg|, and the reflected ray
// leaves at the mirrored angle (pi - theta) about the normal.




// --- TRANSLATION DATA (source `tDict`, en + hi; te ignored) ---
// Keys keep the source names. `tab`, `controls`, `gotIt`, `twinTip`,
// `angleLabel` and the `btn*` sidebar twins have no source key (the HTML
// relies on raw canvas drags); their Hindi is written to match. LaTeX
// fragments ($i = r$, $90^{\circ}$, $\angle$) are rendered as plain unicode.

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

final _tx = _rt_Tx({
  'en': {
    'app': 'Laws of Reflection',
    'subtitle': 'Class 8 • Light',
    'enter': 'Enter _rt_Lab',
    'tab': 'Teacher Board',
    'active_exp': 'Active Experiment',
    'proc_steps': 'Procedural Steps',
    'controls': 'Controls',
    'follow_inst': 'Follow the instructions to begin',
    'obs_analysis': 'Observation Analysis',
    'gotIt': 'Got it!',
    'ttLabels': 'Toggle Labels',
    'scen1_title': '1. Measuring Angles',
    'scen2_title': '2. Plane of Reflection',
    'plane_mirror': 'Plane Mirror',
    'normal_n': 'Normal (N)',
    'point_o': 'Point O',
    'inc_ray': 'Incident Ray',
    'ref_ray': 'Reflected Ray',
    'setup_act': 'Setup Activity',
    'power_on': 'Power On',
    's1_btn_verify': 'Verify ∠i = ∠r',
    'angleLabel': 'Beam Angle (i)',
    'btnPlaceRuler': 'Place Ruler at O',
    'btnAlignProt': 'Align Protractor',
    'btnCaptureI': 'Capture ∠i',
    'btnCaptureR': 'Capture ∠r',
    'btnLockRay': 'Lock Beam Angle',
    'btnBend': 'Bend Paper Down',
    'btnFlatten': 'Flatten Paper',
    'twinTip': 'Drag the tools on the canvas, or use these buttons.',

    // Scenario 1 theory + tags + HUD.
    's1_st1_t': 'Step 1: Theory & Setup',
    's1_st1_d':
        'The First Law of Reflection states that the angle of incidence is always strictly equal to the angle of reflection (i = r). In this activity, we will empirically prove this by measuring both angles relative to a perpendicular normal line using a virtual protractor.',
    's1_st2_t': 'Step 2: Establishing the Normal',
    's1_st2_d':
        "The Normal is an imaginary reference line drawn perfectly perpendicular (90°) to the mirror's surface at the exact point of incidence (Point O). All angles in optics are measured relative to this Normal, not the mirror's surface.",
    's1_st3_t': 'Step 3: Setting the Incident Ray',
    's1_st3_d':
        'The incident ray is the incoming beam of light striking the mirror. By moving the flashlight, you can change the angle at which the light hits the mirror. Ensure you choose a clear, non-zero angle to accurately observe the reflection.',
    's1_st4_t': 'Step 4: Measuring Incidence (i)',
    's1_st4_d':
        'The Angle of Incidence (i) is defined strictly as the geometric angle between the incoming Incident Ray and the perpendicular Normal line. Use the protractor to capture this exact measurement.',
    's1_st5_t': 'Step 5: Measuring Reflection (r)',
    's1_st5_d':
        'The Angle of Reflection (r) is the geometric angle between the outgoing Reflected Ray and the perpendicular Normal line. Click the reflected beam to let the system measure this angle for comparison.',
    's1_st6_t': 'Step 6: Verification',
    's1_st6_d':
        'Examine the two captured measurements on the HUD. Are they identical? If the measured angle of incidence exactly matches the angle of reflection, you have successfully verified the First Law of Reflection.',
    's1_tags': ['Setup', 'Draw Normal', 'Set Ray', 'Measure i', 'Measure r', 'Verify'],
    's1_h1_inst': 'Law 1: Measuring Angles',
    's1_h1_sub': 'Read the Teacher Board, then click to begin',
    's1_h2_inst': 'Drag the Orange RULER to the mirror center (Point O).',
    's1_h2_sub': 'This draws the perpendicular Normal line.',
    's1_h3_inst': 'Drag the grey FLASHLIGHT to aim the beam.',
    's1_h3_sub': 'Avoid setting it exactly at 0°. Release to lock.',
    's1_h4_inst': '1. Drag PROTRACTOR to center. 2. Click the highlighted INCIDENT beam.',
    's1_h4_sub': 'This captures the Angle of Incidence (i).',
    's1_h5_inst': 'Now, CLICK the highlighted REFLECTED beam.',
    's1_h5_sub': 'This captures the Angle of Reflection (r).',
    's1_h6_inst': 'Measurements Locked.',
    's1_h6_sub': 'Values: i={i}°, r={r}°',

    // Scenario 2 theory + tags + HUD.
    's2_st1_t': 'Step 1: Theory & Setup',
    's2_st1_d':
        'The Second Law of Reflection states that the incident ray, the normal at the point of incidence, and the reflected ray must all lie completely within the exact same flat 2D plane (like a single sheet of paper).',
    's2_st2_t': 'Step 2: Visualizing Plane',
    's2_st2_d':
        "When the laser beam travels across the perfectly flat paper, the entire path of the light (incident and reflected) remains clearly visible because the paper's surface acts as that single geometric plane.",
    's2_st3_t': 'Step 3: Breaking the Plane',
    's2_st3_d':
        'By physically bending the paper downwards, you are forcing the surface out of the original 2D plane. Notice what happens to the reflected ray when its required plane is suddenly removed.',
    's2_st4_t': 'Step 4: Restore Plane',
    's2_st4_d':
        'When the paper is bent, the reflected ray seems to disappear from the surface. This happens because the light continues to travel in the original invisible flat plane, hovering in the empty space above the bent paper.',
    's2_st5_t': 'Step 5: Conclusion',
    's2_st5_d':
        'Drag the paper back up to its original flat state. The reflected ray instantly reappears on the surface. This demonstrates that light requires a continuous, unbroken plane to reflect along its natural path.',
    's2_tags': ['Setup', 'Cast Beam', 'Bend Plane', 'Restore Plane', 'Conclusion'],
    's2_h1_inst': 'Law 2: Plane of Light',
    's2_h2_inst': 'Click POWER ON.',
    's2_h2_sub': 'Observe the path on the flat surface.',
    's2_h3_inst': 'Immediately DRAG the paper DOWNWARD using the YELLOW handle.',
    's2_h3_sub': 'Watch the reflected ray.',
    's2_h4_inst': 'Drag the paper back up to the flat position.',
    's2_h4_sub': 'Observe how the plane restores the ray.',
    's2_h5_inst': 'Conclusion: What does this indicate?',
    's2_h5_sub': 'Select your answer below.',
    's2_opt_1': 'Rays require a single plane',
    's2_opt_2': 'Rays move in 3D curves',

    // Toasts & completion.
    't_norm': 'Normal Established! (90°)',
    't_prot': 'Protractor Aligned.',
    't_inc': 'Angle of Incidence Captured!',
    't_ref': 'Angle of Reflection Captured!',
    't_ver_s1': 'VERIFIED: Angle of Incidence = Angle of Reflection!',
    't_err_match': "Values don't match. Please re-measure.",
    't_ver_s2': 'Coplanarity successfully demonstrated.',
    't_err_obs': 'Incorrect. Observe the ray behavior again.',
    't_bent': 'Paper bent! Reflected ray path broken.',
    't_flat': 'Paper flattened! Ray reappears.',
    'm_accomp': 'Mission Accomplished!',
    'l1_ver': 'Law 1 verified.',
    'e_comp': 'Experiment Complete!',
    'l2_ver': 'Law 2 verified.',
    'obs_l1_t': 'Law of Reflection Verified',
    'obs_l1_c':
        'Empirical measurement proves that the angle at which light strikes a surface (i) is mathematically equal to the angle at which it bounces off (r). This fundamental property of optics is known as the First Law of Reflection.',
    'obs_l2_t': 'Coplanarity Verified',
    'obs_l2_c':
        'By breaking the physical plane (bending the paper), the reflected ray disappeared from the surface. This proves Law 2: The incident ray, the normal, and the reflected ray must all lie in the exact same geometric plane.',
  },
  'hi': {
    'app': 'परावर्तन के नियम',
    'subtitle': 'कक्षा 8 • प्रकाश',
    'enter': 'लैब में प्रवेश करें',
    'tab': 'टीचर बोर्ड',
    'active_exp': 'सक्रिय प्रयोग',
    'proc_steps': 'प्रक्रियात्मक चरण',
    'controls': 'नियंत्रण',
    'follow_inst': 'शुरू करने के लिए निर्देशों का पालन करें',
    'obs_analysis': 'अवलोकन विश्लेषण',
    'gotIt': 'समझ गया!',
    'ttLabels': 'लेबल टॉगल करें',
    'scen1_title': '1. कोण मापना',
    'scen2_title': '2. परावर्तन का तल',
    'plane_mirror': 'समतल दर्पण',
    'normal_n': 'अभिलंब (N)',
    'point_o': 'बिंदु O',
    'inc_ray': 'आपतित किरण',
    'ref_ray': 'परावर्तित किरण',
    'setup_act': 'गतिविधि सेटअप करें',
    'power_on': 'पावर ऑन',
    's1_btn_verify': 'सत्यापित करें ∠i = ∠r',
    'angleLabel': 'किरण कोण (i)',
    'btnPlaceRuler': 'पैमाने को O पर रखें',
    'btnAlignProt': 'चांदा संरेखित करें',
    'btnCaptureI': '∠i कैप्चर करें',
    'btnCaptureR': '∠r कैप्चर करें',
    'btnLockRay': 'किरण कोण लॉक करें',
    'btnBend': 'कागज नीचे मोड़ें',
    'btnFlatten': 'कागज समतल करें',
    'twinTip': 'कैनवास पर उपकरण खींचें, या इन बटनों का उपयोग करें।',

    's1_st1_t': 'चरण 1: सिद्धांत और सेटअप',
    's1_st1_d':
        'परावर्तन का प्रथम नियम कहता है कि आपतन कोण हमेशा परावर्तन कोण के ठीक बराबर होता है (i = r)। इस गतिविधि में, हम एक आभासी चांदे का उपयोग करके अभिलंब रेखा के सापेक्ष दोनों कोणों को मापकर इसे अनुभवजन्य रूप से सिद्ध करेंगे।',
    's1_st2_t': 'चरण 2: अभिलंब स्थापित करना',
    's1_st2_d':
        'अभिलंब एक काल्पनिक संदर्भ रेखा है जो आपतन बिंदु (बिंदु O) पर दर्पण की सतह के बिल्कुल लंबवत (90°) खींची जाती है। प्रकाशिकी में सभी कोण इसी अभिलंब के सापेक्ष मापे जाते हैं, न कि दर्पण की सतह से।',
    's1_st3_t': 'चरण 3: आपतित किरण सेट करना',
    's1_st3_d':
        'आपतित किरण दर्पण से टकराने वाली आने वाली प्रकाश की किरण है। फ्लैशलाइट को घुमाकर, आप वह कोण बदल सकते हैं जिस पर प्रकाश दर्पण से टकराता है। सटीक परावर्तन देखने के लिए सुनिश्चित करें कि आप एक स्पष्ट कोण (शून्य नहीं) चुनें।',
    's1_st4_t': 'चरण 4: आपतन मापना (i)',
    's1_st4_d':
        'आपतन कोण (i) को आने वाली आपतित किरण और लंबवत अभिलंब रेखा के बीच के ज्यामितीय कोण के रूप में परिभाषित किया जाता है। इस सटीक माप को कैप्चर करने के लिए चांदे का उपयोग करें।',
    's1_st5_t': 'चरण 5: परावर्तन मापना (r)',
    's1_st5_d':
        'परावर्तन कोण (r) बाहर जाने वाली परावर्तित किरण और लंबवत अभिलंब रेखा के बीच का ज्यामितीय कोण है। सिस्टम द्वारा इस कोण को मापने और तुलना करने के लिए परावर्तित किरण पर क्लिक करें।',
    's1_st6_t': 'चरण 6: सत्यापन',
    's1_st6_d':
        'HUD पर कैप्चर किए गए दोनों मापों की जाँच करें। क्या वे समान हैं? यदि मापा गया आपतन कोण बिल्कुल परावर्तन कोण से मेल खाता है, तो आपने परावर्तन के प्रथम नियम को सफलतापूर्वक सत्यापित कर लिया है।',
    's1_tags': ['सेटअप', 'अभिलंब बनाएं', 'किरण सेट करें', 'i मापें', 'r मापें', 'सत्यापित करें'],
    's1_h1_inst': 'नियम 1: कोण मापना',
    's1_h1_sub': 'टीचर बोर्ड पढ़ें, फिर शुरू करने के लिए क्लिक करें',
    's1_h2_inst': 'नारंगी पैमाने (RULER) को दर्पण के केंद्र (बिंदु O) तक खींचें।',
    's1_h2_sub': 'यह लंबवत अभिलंब रेखा खींचता है।',
    's1_h3_inst': 'किरण को लक्षित करने के लिए ग्रे टॉर्च (FLASHLIGHT) को खींचें।',
    's1_h3_sub': 'इसे ठीक 0° पर सेट करने से बचें। लॉक करने के लिए छोड़ें।',
    's1_h4_inst': '1. चांदे (PROTRACTOR) को केंद्र में खींचें। 2. हाइलाइट की गई आपतित किरण पर क्लिक करें।',
    's1_h4_sub': 'यह आपतन कोण (i) को कैप्चर करता है।',
    's1_h5_inst': 'अब, हाइलाइट की गई परावर्तित किरण पर क्लिक करें।',
    's1_h5_sub': 'यह परावर्तन कोण (r) को कैप्चर करता है।',
    's1_h6_inst': 'माप लॉक हो गए।',
    's1_h6_sub': 'मान: i={i}°, r={r}°',

    's2_st1_t': 'चरण 1: सिद्धांत और सेटअप',
    's2_st1_d':
        'परावर्तन का द्वितीय नियम कहता है कि आपतित किरण, आपतन बिंदु पर अभिलंब, और परावर्तित किरण सभी एक ही समतल 2D तल (जैसे कागज की एक शीट) में पूरी तरह से स्थित होने चाहिए।',
    's2_st2_t': 'चरण 2: तल की कल्पना',
    's2_st2_d':
        'जब लेजर बीम पूरी तरह से समतल कागज पर यात्रा करती है, तो प्रकाश का पूरा पथ (आपतित और परावर्तित) स्पष्ट रूप से दिखाई देता है क्योंकि कागज की सतह उसी एक ज्यामितीय तल के रूप में कार्य करती है।',
    's2_st3_t': 'चरण 3: तल को तोड़ना',
    's2_st3_d':
        'कागज को भौतिक रूप से नीचे की ओर मोड़कर, आप सतह को मूल 2D तल से बाहर कर रहे हैं। ध्यान दें कि जब इसका आवश्यक तल अचानक हटा दिया जाता है तो परावर्तित किरण का क्या होता है।',
    's2_st4_t': 'चरण 4: तल को पुनर्स्थापित करना',
    's2_st4_d':
        'जब कागज मुड़ जाता है, तो परावर्तित किरण सतह से गायब होती प्रतीत होती है। ऐसा इसलिए होता है क्योंकि प्रकाश मुड़े हुए कागज के ऊपर खाली स्थान में, मूल अदृश्य समतल तल में यात्रा करना जारी रखता है।',
    's2_st5_t': 'चरण 5: निष्कर्ष',
    's2_st5_d':
        'कागज को वापस उसकी मूल समतल स्थिति में खींचें। परावर्तित किरण तुरंत सतह पर फिर से दिखाई देती है। यह दर्शाता है कि प्रकाश को अपने प्राकृतिक पथ पर परावर्तित होने के लिए एक निरंतर, अखंड तल की आवश्यकता होती है।',
    's2_tags': ['सेटअप', 'किरण डालें', 'तल मोड़ें', 'तल पुनर्स्थापित करें', 'निष्कर्ष'],
    's2_h1_inst': 'नियम 2: प्रकाश का तल',
    's2_h2_inst': 'POWER ON पर क्लिक करें।',
    's2_h2_sub': 'समतल सतह पर पथ का निरीक्षण करें।',
    's2_h3_inst': 'तुरंत पीले हैंडल का उपयोग करके कागज को नीचे की ओर खींचें।',
    's2_h3_sub': 'परावर्तित किरण देखें।',
    's2_h4_inst': 'कागज को वापस समतल स्थिति में खींचें।',
    's2_h4_sub': 'देखें कि तल किरण को कैसे पुनर्स्थापित करता है।',
    's2_h5_inst': 'निष्कर्ष: यह क्या दर्शाता है?',
    's2_h5_sub': 'नीचे अपना उत्तर चुनें।',
    's2_opt_1': 'किरणों को एक ही तल की आवश्यकता होती है',
    's2_opt_2': 'किरणें 3D वक्रों में चलती हैं',

    't_norm': 'अभिलंब स्थापित! (90°)',
    't_prot': 'चांदा संरेखित।',
    't_inc': 'आपतन कोण कैप्चर किया गया!',
    't_ref': 'परावर्तन कोण कैप्चर किया गया!',
    't_ver_s1': 'सत्यापित: आपतन कोण = परावर्तन कोण!',
    't_err_match': 'मान मेल नहीं खाते। कृपया फिर से मापें।',
    't_ver_s2': 'समतलीयता सफलतापूर्वक प्रदर्शित की गई।',
    't_err_obs': 'गलत। किरण व्यवहार का फिर से निरीक्षण करें।',
    't_bent': 'कागज मुड़ गया! परावर्तित किरण का पथ टूट गया।',
    't_flat': 'कागज समतल! किरण फिर से दिखाई देती है।',
    'm_accomp': 'मिशन पूरा हुआ!',
    'l1_ver': 'नियम 1 सत्यापित।',
    'e_comp': 'प्रयोग पूरा हुआ!',
    'l2_ver': 'नियम 2 सत्यापित।',
    'obs_l1_t': 'परावर्तन का नियम सत्यापित',
    'obs_l1_c':
        'अनुभवजन्य माप साबित करता है कि जिस कोण पर प्रकाश सतह (i) से टकराता है, वह गणितीय रूप से उस कोण के बराबर होता है जिस पर वह वापस उछलता है (r)। प्रकाशिकी के इस मूलभूत गुण को परावर्तन का प्रथम नियम कहा जाता है।',
    'obs_l2_t': 'समतलीयता सत्यापित',
    'obs_l2_c':
        'भौतिक तल को तोड़ने (कागज को मोड़ने) से, परावर्तित किरण सतह से गायब हो गई। यह नियम 2 को साबित करता है: आपतित किरण, अभिलंब और परावर्तित किरण सभी एक ही ज्यामितीय तल में होने चाहिए।',
  },
});

// --- COLOURS (source --zsl-yellow on the PhET radial-gradient canvas) ---
const _accent = Color(0xFFFACC15);
const _beamYellow = Color(0xFFFEF08A);
const _beamOrange = Color(0xFFF97316);

const _theme = _rt_ShellTheme(
  accent: _accent,
  headerGradient: [_rt_Tw.slate900, Color(0xFF1E3A8A)],
  headerSubtitleColor: Color(0xFFFDE68A),
);

// --- SCENE GEOMETRY (source: ortho half-height d = 16, originPoint (0,-4)) ---
const double _oX = 0, _oY = -4; // Point O (point of incidence)
const double _worldH = 32; // visible world height
const double _beamRadius = 10; // flashlight orbit radius (source `radius`)
const double _refLen = 25; // reflected beam length
const double _paperFlatY = _oY - 5; // lower paper centre, flat
const double _paperBentY = _oY - 9; // lower paper centre, bent

enum _DragTarget { none, ruler, flashlight, protractor, paper }

class Cl8Ch10A2LawsOfReflectionPage extends StatefulWidget {
  const Cl8Ch10A2LawsOfReflectionPage({super.key});

  @override
  State<Cl8Ch10A2LawsOfReflectionPage> createState() =>
      _Cl8Ch10A2LawsOfReflectionPageState();
}

class _Cl8Ch10A2LawsOfReflectionPageState
    extends State<Cl8Ch10A2LawsOfReflectionPage> {
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();
  final _rt_ShellController _shell = _rt_ShellController();

  // --- LAB STATE (source `state`) ---
  int _scenario = 1; // 1-based like the source
  int _step = 1;
  bool _laserOn = false;
  bool _normalDrawn = false;
  bool _isBent = false;
  bool _showLabels = true;
  bool _finished = false;
  int? _capturedI, _capturedR;

  // Tool positions in world units (source tools.* / bentPaperMesh).
  Offset _flPos = const Offset(-10, _oY + 10);
  Offset _rulerPos = const Offset(10, _oY + 6);
  Offset _protPos = const Offset(12, _oY + 6);
  bool _rulerVisible = true;
  bool _rulerSnapped = false;
  bool _protSnapped = false;
  double _paperY = _paperFlatY;

  _DragTarget _drag = _DragTarget.none;
  Offset _lastWorld = Offset.zero;

  /// Bumped on restart / scenario change so pending timers are dropped.
  int _gen = 0;

  // ------------------------------------------------------------ optics ---
  /// Flashlight angle around Point O, degrees in (0, 180); 90 = straight up.
  double get _thetaDeg {
    final d = _flPos - const Offset(_oX, _oY);
    return math.atan2(d.dy, d.dx) * 180 / math.pi;
  }

  /// Angle of incidence i = |90 - |laserAngle|| (source updateOptics).
  int get _currentI => (_thetaDeg - 90).abs().round();

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
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _zoom.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- logic ---
  /// loadScenario(): tool + state reset shared by scenario switch & restart.
  void _resetScenarioState(int s) {
    _scenario = s;
    _step = 1;
    _laserOn = false;
    _normalDrawn = false;
    _isBent = false;
    _finished = false;
    _capturedI = _capturedR = null;
    _flPos = const Offset(-10, _oY + 10);
    _rulerPos = const Offset(10, _oY + 6);
    _protPos = const Offset(12, _oY + 6);
    _rulerVisible = s == 1;
    _rulerSnapped = false;
    _protSnapped = false;
    _paperY = _paperFlatY;
    _drag = _DragTarget.none;
  }

  void _loadScenario(int s) {
    if (s == _scenario && _step == 1 && !_finished) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    _rt_playSfx(_rt_Sfx.scenario);
    _gen++;
    setState(() => _resetScenarioState(s));
    _zoom.reset();
  }

  /// resetLab(): everything back to scenario 1 step 1 (shell plays the sfx).
  void _restart() {
    _gen++;
    setState(() {
      _resetScenarioState(1);
      _showLabels = true;
    });
    _zoom.reset();
  }

  void _nextStep() {
    setState(() {
      _step++;
      // Source updateUI: entering scenario-1 step 3 switches the laser on.
      if (_scenario == 1 && _step == 3) _laserOn = true;
    });
  }

  /// checkRulerSnap(): ruler locks vertical on O, draws the Normal, then
  /// disappears after 600 ms.
  void _placeRuler() {
    if (_scenario != 1 || _step != 2 || _normalDrawn) return;
    _rt_playSfx(_rt_Sfx.correct);
    setState(() {
      _rulerPos = const Offset(_oX, _oY);
      _rulerSnapped = true;
      _normalDrawn = true;
      _drag = _DragTarget.none;
    });
    _shell.showToast(_tx.s('t_norm'), color: _rt_Tw.green500, icon: Icons.check_circle);
    final gen = _gen;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && gen == _gen) setState(() => _rulerVisible = false);
    });
    _nextStep();
  }

  /// checkProtractorSnap().
  void _alignProtractor() {
    if (_scenario != 1 || _step < 4 || _protSnapped) return;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _protPos = const Offset(_oX, _oY);
      _protSnapped = true;
      _drag = _DragTarget.none;
    });
    _shell.showToast(_tx.s('t_prot'), color: _rt_Tw.green500, icon: Icons.check_circle);
  }

  /// Sidebar twin of releasing the flashlight (source auto-advances step 3
  /// on pointerup once the laser is on).
  void _lockRay() {
    if (_scenario != 1 || _step != 3) return;
    setState(() => _laserOn = true);
    _nextStep();
  }

  /// Slider twin of the flashlight drag; keeps the beam on its current side
  /// of the Normal (theta = 90 + i on the left, 90 - i on the right).
  void _setAngle(double raw) {
    final i = raw.clamp(6.0, 80.0);
    final side = _thetaDeg >= 90 ? 1.0 : -1.0;
    final theta = (90 + side * i) * math.pi / 180;
    setState(() {
      _flPos = Offset(
        _oX + math.cos(theta) * _beamRadius,
        _oY + math.sin(theta) * _beamRadius,
      );
      if (_scenario == 1 && _step == 3) _laserOn = true;
    });
  }

  /// captureMeasurement('i' / 'r'). The source also bailed out whenever the
  /// canvas labels were hidden (`if (!state.labelsVisible) return`) - that
  /// guard is an unrelated UI quirk and is dropped here.
  void _captureI() {
    if (_scenario != 1 || _step != 4 || !_laserOn) return;
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _capturedI = _currentI);
    _shell.showToast(_tx.s('t_inc'), color: _rt_Tw.green500, icon: Icons.check_circle);
    _nextStep();
  }

  void _captureR() {
    if (_scenario != 1 || _step != 5 || !_laserOn) return;
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _capturedR = _currentI); // currentR === currentI in source
    _shell.showToast(_tx.s('t_ref'), color: _rt_Tw.green500, icon: Icons.check_circle);
    _nextStep();
  }

  /// validateInvestigation() for scenario 1. SOURCE BUG FIX: on a mismatch
  /// the HTML showed "please re-measure" but left the lab stuck on step 6
  /// (beam clicks only work on steps 4-5); here the captures are cleared and
  /// the lab returns to step 4 so re-measuring is actually possible.
  void _verify() {
    if (_capturedI != null && _capturedI == _capturedR) {
      _finish();
      return;
    }
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(_tx.s('t_err_match'), color: _rt_Tw.red500, icon: Icons.warning);
    setState(() {
      _capturedI = _capturedR = null;
      _step = 4;
    });
  }

  /// Scenario-2 paper bend / restore (thresholds match the source drag).
  void _bendPaper() {
    if (_scenario != 2 || _step != 3 || _isBent) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _isBent = true;
      _paperY = _paperBentY;
      _drag = _DragTarget.none;
    });
    _shell.showToast(_tx.s('t_bent'), color: _rt_Tw.green500, icon: Icons.check_circle);
    _nextStep();
  }

  void _flattenPaper() {
    if (_scenario != 2 || _step != 4 || !_isBent) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _isBent = false;
      _paperY = _paperFlatY;
      _drag = _DragTarget.none;
    });
    _shell.showToast(_tx.s('t_flat'), color: _rt_Tw.green500, icon: Icons.check_circle);
    _nextStep();
  }

  /// concludePlane().
  void _conclude(int opt) {
    if (opt != 0) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(_tx.s('t_err_obs'), color: _rt_Tw.red500, icon: Icons.warning);
      return;
    }
    _finish();
  }

  void _finish() {
    _rt_playSfx(_rt_Sfx.success);
    setState(() => _finished = true);
    _shell.showToast(
      _tx.s(_scenario == 1 ? 't_ver_s1' : 't_ver_s2'),
      color: _rt_Tw.green500,
      icon: Icons.star,
    );
    final gen = _gen;
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && gen == _gen && _finished) {
        _shell.setSidebarOpen(true);
        _showObservation();
      }
    });
  }

  /// triggerObservation(): the draggable popup becomes a shell popup.
  void _showObservation() {
    _rt_playSfx(_rt_Sfx.pop);
    final law = _scenario == 1 ? 'l1' : 'l2';
    _rt_showShellPopup(
      context,
      title: _tx.s('obs_analysis'),
      icon: Icons.science,
      color: _rt_Tw.green500,
      buttonLabel: _tx.s('gotIt'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('obs_${law}_t'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: _accent),
          ),
          const SizedBox(height: 8),
          Text(
            _tx.s('obs_${law}_c'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.45),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------- canvas gestures ---
  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 < 1e-9) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }

  Offset _reflEnd() {
    final refAng = (180 - _thetaDeg) * math.pi / 180;
    return Offset(
      _oX + math.cos(refAng) * _refLen,
      _oY + math.sin(refAng) * _refLen,
    );
  }

  void _onTapUp(Offset w) {
    if (_scenario != 1 || !_laserOn) return;
    if (_step == 4 &&
        _distToSegment(w, _flPos, const Offset(_oX, _oY)) < 1.6) {
      _captureI();
    } else if (_step == 5 &&
        _distToSegment(w, const Offset(_oX, _oY), _reflEnd()) < 1.6) {
      _captureR();
    }
  }

  void _onPanStart(Offset w) {
    _drag = _DragTarget.none;
    if (_finished) return;
    if (_scenario == 1) {
      if (_step == 2 &&
          _rulerVisible &&
          !_rulerSnapped &&
          (w.dx - _rulerPos.dx).abs() < 6 &&
          (w.dy - _rulerPos.dy).abs() < 2.2) {
        _drag = _DragTarget.ruler;
      } else if (_step >= 4 &&
          !_protSnapped &&
          (w - _protPos).distance < 7.2) {
        _drag = _DragTarget.protractor;
      } else if (_step >= 3 && _step <= 5 && (w - _flPos).distance < 3.6) {
        _drag = _DragTarget.flashlight;
      }
    }
    if (_scenario == 2 && (_step == 3 || _step == 4)) {
      final h = _isBent ? 1.4 : 3.6; // half-height of the draggable sheet
      if (w.dx.abs() < 8.5 && (w.dy - _paperY).abs() < h + 1) {
        _drag = _DragTarget.paper;
      }
    }
    if (_drag != _DragTarget.none) {
      _lastWorld = w;
      _rt_playSfx(_rt_Sfx.tap);
      setState(() {});
    }
  }

  void _onPanUpdate(Offset w) {
    if (_drag == _DragTarget.none) return;
    final delta = w - _lastWorld;
    _lastWorld = w;
    switch (_drag) {
      case _DragTarget.ruler:
        setState(() => _rulerPos += delta);
        if (_rulerPos.dx.abs() < 5 && (_rulerPos.dy - _oY).abs() < 5) {
          _placeRuler();
        }
      case _DragTarget.protractor:
        setState(() => _protPos += delta);
        if (_protPos.dx.abs() < 5 && (_protPos.dy - _oY).abs() < 5) {
          _alignProtractor();
        }
      case _DragTarget.flashlight:
        // Source: the flashlight orbits Point O at radius 10, clamped away
        // from the mirror plane (0.1 rad) and from the Normal (0.08 rad).
        var ang = math.atan2(w.dy - _oY, w.dx - _oX);
        if (ang < 0.1) ang = 0.1;
        if (ang > math.pi - 0.1) ang = math.pi - 0.1;
        if ((ang - math.pi / 2).abs() < 0.08) {
          ang = math.pi / 2 + 0.1 * (ang >= math.pi / 2 ? 1 : -1);
        }
        setState(() {
          _flPos = Offset(
            _oX + math.cos(ang) * _beamRadius,
            _oY + math.sin(ang) * _beamRadius,
          );
          if (_scenario == 1 && _step == 3) _laserOn = true;
        });
      case _DragTarget.paper:
        setState(() => _paperY = (_paperY + delta.dy).clamp(_oY - 10, _oY - 4.5));
        if (_step == 3 && _paperY < _oY - 7) _bendPaper();
        if (_step == 4 && _paperY > _oY - 5.5) _flattenPaper();
      case _DragTarget.none:
        break;
    }
  }

  void _onPanEnd() {
    if (_drag == _DragTarget.none) return;
    final wasFlashlight = _drag == _DragTarget.flashlight;
    _drag = _DragTarget.none;
    if (wasFlashlight && _scenario == 1 && _step == 3 && _laserOn) {
      _rt_playSfx(_rt_Sfx.click);
      _nextStep(); // release locks the incident ray
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {});
  }

  // ----------------------------------------------------------- HUD text ---
  String _inst() {
    if (_finished) return _tx.s(_scenario == 1 ? 'm_accomp' : 'e_comp');
    final s = _scenario == 1 ? _step.clamp(1, 6) : _step.clamp(1, 5);
    return _tx.s('s${_scenario}_h${s}_inst');
  }

  String _sub() {
    if (_finished) return _tx.s(_scenario == 1 ? 'l1_ver' : 'l2_ver');
    if (_scenario == 2 && _step == 1) return _tx.s('follow_inst');
    if (_scenario == 1 && _step >= 6) {
      return _tx
          .s('s1_h6_sub')
          .replaceFirst('{i}', '${_capturedI ?? '?'}')
          .replaceFirst('{r}', '${_capturedR ?? '?'}');
    }
    final s = _scenario == 1 ? _step.clamp(1, 6) : _step.clamp(2, 5);
    return _tx.s('s${_scenario}_h${s}_sub');
  }

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(builder: (context, lang) {
        return _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('app'),
          subtitle: _tx.s('subtitle'),
          theme: _theme,
          canvasBackground: const Color(0xFF0F172A),
          intro: _rt_IntroConfig(
            title: _tx.s('app'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enter'),
            icon: Icons.flare,
          ),
          onRestart: _restart,
          onZoomIn: _zoom.zoomIn,
          onZoomOut: _zoom.zoomOut,
          onResetView: _zoom.reset,
          toolbarExtras: [
            Tooltip(
              message: _tx.s('ttLabels'),
              child: InkResponse(
                key: const ValueKey('btn-labels'),
                radius: 22,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _showLabels = !_showLabels);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _showLabels ? _accent : _rt_Lab.surface,
                    shape: BoxShape.circle,
                    boxShadow: _showLabels
                        ? [BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 6)]
                        : null,
                  ),
                  child: Icon(Icons.sell,
                      size: 18, color: _showLabels ? Colors.black : _rt_Lab.textMuted),
                ),
              ),
            ),
          ],
          hint: _rt_StepHint(
            number: _finished ? '✓' : '$_step',
            text: _inst(),
            label: _tx.s('tab'),
          ),
          tabs: [
            _rt_ShellTab(
                label: _tx.s('tab'), icon: Icons.menu_book, builder: (_) => _sidebar()),
          ],
          canvas: _rt_ZoomableCanvas(controller: _zoom, child: _sceneCanvas()),
          canvasOverlays: [
            Positioned(left: 60, right: 60, bottom: 8, child: Center(child: _hud())),
          ],
        );
      }),
    );
  }

  // ----------------------------------------------------------- canvas ---
  Widget _sceneCanvas() {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final scale = size.height / _worldH;
      Offset toWorld(Offset local) => Offset(
            (local.dx - size.width / 2) / scale,
            (size.height / 2 - local.dy) / scale,
          );
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => _onTapUp(toWorld(d.localPosition)),
        onPanStart: (d) => _onPanStart(toWorld(d.localPosition)),
        onPanUpdate: (d) => _onPanUpdate(toWorld(d.localPosition)),
        onPanEnd: (_) => _onPanEnd(),
        onPanCancel: _onPanEnd,
        child: CustomPaint(
          size: size,
          painter: _ReflectionPainter(
            scenario: _scenario,
            step: _step,
            flPos: _flPos,
            rulerPos: _rulerPos,
            rulerVisible: _scenario == 1 && _rulerVisible,
            rulerSnapped: _rulerSnapped,
            protPos: _protPos,
            protVisible: _scenario == 1,
            normalDrawn: _normalDrawn,
            laserOn: _laserOn,
            isBent: _isBent,
            paperY: _paperY,
            labels: _canvasLabels(),
          ),
        ),
      );
    });
  }

  /// updateLabels(): floating chips, in the current language.
  List<(String, Offset)> _canvasLabels() {
    if (!_showLabels) return const [];
    final labels = <(String, Offset)>[
      (_tx.s('plane_mirror'), const Offset(-8, _oY - 1.2)),
    ];
    if (_normalDrawn) {
      labels.add((_tx.s('normal_n'), const Offset(0, _oY + 10)));
      labels.add((_tx.s('point_o'), const Offset(0, _oY - 1.5)));
    }
    if (_laserOn) {
      final midI = Offset(
        (_flPos.dx + _oX) / 2,
        (_flPos.dy + _oY) / 2 + 1.5,
      );
      labels.add((_tx.s('inc_ray'), midI));
      if (!(_isBent && _scenario == 2)) {
        final end = _reflEnd();
        labels.add((
          _tx.s('ref_ray'),
          Offset((_oX + end.dx) / 2, (_oY + end.dy) / 2 + 1.5),
        ));
      }
    }
    return labels;
  }

  // -------------------------------------------------------------- HUD ---
  /// The bottom glass panel (#hud-instruction / #hud-sub / readouts / actions).
  Widget _hud() {
    final showReadouts = _scenario == 1 && (_step >= 4 || _finished);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xE60F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.5), width: 1.4),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            _inst(),
            key: const ValueKey('hud-inst'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _finished ? _rt_Tw.green400 : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1.2),
          ),
          const SizedBox(height: 3),
          Text(
            _sub(),
            key: const ValueKey('hud-sub'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _accent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1),
          ),
          if (showReadouts) ...[
            const SizedBox(height: 7),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _readoutPill('∠i =', _capturedI, 'val-i',
                  active: _capturedI != null && _capturedR == null),
              const SizedBox(width: 10),
              _readoutPill('∠r =', _capturedR, 'val-r', active: _capturedR != null),
            ]),
          ],
          ..._hudActions(),
        ]),
      ),
    );
  }

  Widget _readoutPill(String label, int? value, String key, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: active ? _accent : Colors.white.withValues(alpha: 0.25), width: 2),
        boxShadow: active
            ? [BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 10)]
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(width: 5),
        Text(
          value == null ? '?' : '$value°',
          key: ValueKey(key),
          style: const TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace'),
        ),
      ]),
    );
  }

  List<Widget> _hudActions() {
    if (_finished) return const [];
    if (_step == 1) {
      return [
        const SizedBox(height: 8),
        _rt_ActionButton(
          key: const ValueKey('btn-setup'),
          label: _tx.s('setup_act'),
          icon: Icons.rocket_launch,
          color: _accent,
          onPressed: _nextStep,
        ),
      ];
    }
    if (_scenario == 1 && _step >= 6) {
      return [
        const SizedBox(height: 8),
        _rt_ActionButton(
          key: const ValueKey('btn-verify'),
          label: _tx.s('s1_btn_verify'),
          icon: Icons.balance,
          color: _accent,
          sound: null,
          onPressed: _verify,
        ),
      ];
    }
    if (_scenario == 2 && _step == 2) {
      return [
        const SizedBox(height: 8),
        _rt_ActionButton(
          key: const ValueKey('btn-power'),
          label: _tx.s('power_on'),
          icon: Icons.power_settings_new,
          color: _accent,
          onPressed: () {
            setState(() => _laserOn = true); // lockIncidentRay()
            _nextStep();
          },
        ),
      ];
    }
    if (_scenario == 2 && _step >= 5) {
      return [
        const SizedBox(height: 8),
        _rt_ChoiceButton(
          key: const ValueKey('concl-0'),
          label: _tx.s('s2_opt_1'),
          onTap: () => _conclude(0),
        ),
        _rt_ChoiceButton(
          key: const ValueKey('concl-1'),
          label: _tx.s('s2_opt_2'),
          onTap: () => _conclude(1),
        ),
      ];
    }
    return const [];
  }

  // ----------------------------------------------------------- sidebar ---
  Widget _sidebar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('active_exp'), icon: Icons.science, color: _accent),
          for (var s = 1; s <= 2; s++)
            _rt_ChoiceButton(
              key: ValueKey('scen-$s'),
              label: _tx.s('scen${s}_title'),
              state: _scenario == s ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
              onTap: () => _loadScenario(s),
            ),
          const SizedBox(height: 6),
          _theoryBox(),
          ..._controls(),
          const SizedBox(height: 10),
          _rt_SectionLabel(_tx.s('proc_steps'), icon: Icons.checklist, color: _accent),
          ..._stepCards(),
        ],
      ),
    );
  }

  /// The yellow-edged theory box (source #theory-container).
  Widget _theoryBox() {
    final count = _scenario == 1 ? 6 : 5;
    final idx = (_step).clamp(1, count);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius:
            const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        border: const Border(left: BorderSide(color: _accent, width: 4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          _tx.s('s${_scenario}_st${idx}_t'),
          key: const ValueKey('theory-title'),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _accent),
        ),
        const SizedBox(height: 5),
        Text(
          _tx.s('s${_scenario}_st${idx}_d'),
          style: TextStyle(fontSize: 11.5, color: _rt_Lab.text, height: 1.4),
        ),
      ]),
    );
  }

  /// Sidebar twins for every canvas drag / beam click (accessibility +
  /// testability; the HTML had canvas-only interactions).
  List<Widget> _controls() {
    final items = <Widget>[];
    if (_finished) return items;
    if (_scenario == 1) {
      if (_step == 2) {
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-place-ruler'),
          label: _tx.s('btnPlaceRuler'),
          icon: Icons.straighten,
          color: _beamOrange,
          expand: true,
          sound: null,
          onPressed: _placeRuler,
        ));
      }
      if (_step >= 3 && _step <= 5) {
        items.add(_rt_LabeledSlider(
          key: const ValueKey('angle-slider'),
          label: _tx.s('angleLabel'),
          value: _currentI.toDouble().clamp(6, 80),
          min: 6,
          max: 80,
          divisions: 74,
          valueText: '$_currentI°',
          color: _accent,
          onChanged: _setAngle,
        ));
      }
      if (_step == 3) {
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-lock-ray'),
          label: _tx.s('btnLockRay'),
          icon: Icons.lock,
          color: _accent,
          expand: true,
          onPressed: _lockRay,
        ));
      }
      if (_step >= 4 && _step <= 5 && !_protSnapped) {
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-align-protractor'),
          label: _tx.s('btnAlignProt'),
          icon: Icons.architecture,
          color: _rt_Tw.blue500,
          expand: true,
          sound: null,
          onPressed: _alignProtractor,
        ));
      }
      if (_step == 4) {
        items.add(const SizedBox(height: 4));
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-capture-i'),
          label: _tx.s('btnCaptureI'),
          icon: Icons.center_focus_strong,
          color: _rt_Tw.green500,
          expand: true,
          sound: null,
          onPressed: _captureI,
        ));
      }
      if (_step == 5) {
        items.add(const SizedBox(height: 4));
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-capture-r'),
          label: _tx.s('btnCaptureR'),
          icon: Icons.center_focus_weak,
          color: _rt_Tw.green500,
          expand: true,
          sound: null,
          onPressed: _captureR,
        ));
      }
    } else {
      if (_step == 3) {
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-bend-paper'),
          label: _tx.s('btnBend'),
          icon: Icons.south,
          color: _accent,
          expand: true,
          sound: null,
          onPressed: _bendPaper,
        ));
      }
      if (_step == 4) {
        items.add(_rt_ActionButton(
          key: const ValueKey('btn-flatten-paper'),
          label: _tx.s('btnFlatten'),
          icon: Icons.north,
          color: _accent,
          expand: true,
          sound: null,
          onPressed: _flattenPaper,
        ));
      }
    }
    if (items.isEmpty) return items;
    return [
      const SizedBox(height: 10),
      _rt_SectionLabel(_tx.s('controls'), icon: Icons.tune, color: _accent),
      ...items,
      const SizedBox(height: 2),
      Text(_tx.s('twinTip'),
          style: TextStyle(fontSize: 10.5, color: _rt_Lab.textMuted, height: 1.3)),
    ];
  }

  /// renderSteps(): the tag chips with active / complete states.
  List<Widget> _stepCards() {
    final tags = _tx.list('s${_scenario}_tags');
    return [
      for (var i = 0; i < tags.length; i++)
        Builder(builder: (context) {
          final num = i + 1;
          final done = _finished || num < _step;
          final active = !_finished && num == _step.clamp(1, tags.length);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active ? _accent.withValues(alpha: 0.14) : _rt_Lab.surface,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
              border: Border(
                left: BorderSide(
                  color: active ? _accent : (done ? _rt_Tw.green500 : _rt_Lab.border),
                  width: 4,
                ),
              ),
            ),
            child: Row(children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? _rt_Tw.green500 : _rt_Lab.overlay,
                ),
                child: done
                    ? const Icon(Icons.check, size: 13, color: Colors.black)
                    : Text('$num',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: _rt_Lab.textMuted)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (tags[i] as String).toUpperCase(),
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: active
                          ? _accent
                          : (done ? _rt_Tw.green500 : _rt_Lab.textMuted)),
                ),
              ),
            ]),
          );
        }),
    ];
  }
}

// ========================================================================
// PAINTER: the orthographic three.js scene redrawn in 2D world units.
// ========================================================================
class _ReflectionPainter extends CustomPainter {
  _ReflectionPainter({
    required this.scenario,
    required this.step,
    required this.flPos,
    required this.rulerPos,
    required this.rulerVisible,
    required this.rulerSnapped,
    required this.protPos,
    required this.protVisible,
    required this.normalDrawn,
    required this.laserOn,
    required this.isBent,
    required this.paperY,
    required this.labels,
  });

  final int scenario;
  final int step;
  final Offset flPos;
  final Offset rulerPos;
  final bool rulerVisible;
  final bool rulerSnapped;
  final Offset protPos;
  final bool protVisible;
  final bool normalDrawn;
  final bool laserOn;
  final bool isBent;
  final double paperY;
  final List<(String, Offset)> labels;

  late double _s;
  late Offset _c;

  Offset _p(double wx, double wy) => Offset(_c.dx + wx * _s, _c.dy - wy * _s);
  Offset _po(Offset w) => _p(w.dx, w.dy);

  @override
  void paint(Canvas canvas, Size size) {
    _s = size.height / _worldH;
    _c = Offset(size.width / 2, size.height / 2);

    _background(canvas, size);
    if (scenario == 2) _paper(canvas);
    _mirror(canvas);
    if (normalDrawn) _normal(canvas);
    if (laserOn) _beams(canvas);
    if (protVisible) _protractor(canvas);
    _flashlight(canvas);
    if (rulerVisible) _ruler(canvas);
    for (final (text, pos) in labels) {
      _chip(canvas, text, _po(pos));
    }
  }

  /// #canvas-wrapper radial gradient (dark theme).
  void _background(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF0284C7), Color(0xFF1E3A8A), Color(0xFF0F172A)],
          stops: [0, 0.6, 1],
          radius: 1.0,
        ).createShader(rect),
    );
  }

  /// White & blue PhET-style mirror with the Point-O dot.
  void _mirror(Canvas canvas) {
    final base = Rect.fromPoints(_p(-12, _oY), _p(12, _oY - 2));
    canvas.drawRect(base, Paint()..color = Colors.white);
    final glass = Rect.fromPoints(_p(-12, _oY + 0.3), _p(12, _oY - 0.3));
    canvas.drawRect(
        glass, Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.9));
    canvas.drawCircle(_p(0, _oY + 0.3), 0.3 * _s, Paint()..color = Colors.white);
  }

  /// Dashed white Normal from O to O+15.
  void _normal(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(1.5, 0.09 * _s)
      ..strokeCap = StrokeCap.round;
    const dash = 0.5, gap = 0.3;
    var y = _oY;
    while (y < _oY + 15) {
      final y2 = math.min(y + dash, _oY + 15);
      canvas.drawLine(_p(0, y), _p(0, y2), paint);
      y = y2 + gap;
    }
  }

  /// Thick translucent beam + black centre line + arrow (source beam groups).
  void _beam(Canvas canvas, Offset a, Offset b,
      {required Color fill, required double opacity}) {
    final dir = b - a;
    final len = dir.distance;
    if (len < 1e-6) return;
    final u = dir / len;
    final n = Offset(-u.dy, u.dx) * 0.4; // half beam width (0.8 world)
    final path = Path()
      ..moveTo(_po(a + n).dx, _po(a + n).dy)
      ..lineTo(_po(b + n).dx, _po(b + n).dy)
      ..lineTo(_po(b - n).dx, _po(b - n).dy)
      ..lineTo(_po(a - n).dx, _po(a - n).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = fill.withValues(alpha: opacity));
    canvas.drawLine(
      _po(a),
      _po(b),
      Paint()
        ..color = Colors.black.withValues(alpha: math.min(1, opacity + 0.2))
        ..strokeWidth = math.max(1, 0.06 * _s),
    );
    // Arrow head at the midpoint, pointing along the travel direction.
    final mid = a + u * (len / 2);
    final tip = mid + u * 0.6;
    final back = mid - u * 0.2;
    final side = Offset(-u.dy, u.dx) * 0.3;
    final arrow = Path()
      ..moveTo(_po(tip).dx, _po(tip).dy)
      ..lineTo(_po(back + side).dx, _po(back + side).dy)
      ..lineTo(_po(back - side).dx, _po(back - side).dy)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.black.withValues(alpha: 0.9));
  }

  void _beams(Canvas canvas) {
    const o = Offset(_oX, _oY);
    // Highlighting: step 4 emphasises the incident beam, step 5 the
    // reflected one (yellow -> orange, opacity swap), matching updateOptics.
    var incColor = _beamYellow;
    var incOp = 0.5;
    var refColor = _beamYellow;
    var refOp = 0.5;
    if (scenario == 1 && step == 4) {
      incColor = _beamOrange;
      incOp = 0.8;
      refOp = 0.2;
    } else if (scenario == 1 && step == 5) {
      incOp = 0.2;
      refColor = _beamOrange;
      refOp = 0.8;
    }
    _beam(canvas, flPos, o, fill: incColor, opacity: incOp);
    final bent = scenario == 2 && isBent;
    if (!bent) {
      final d = o - flPos;
      final refAng = math.atan2(-d.dy, d.dx);
      final end =
          o + Offset(math.cos(refAng), math.sin(refAng)) * _refLen;
      _beam(canvas, o, end, fill: refColor, opacity: refOp);
    }
  }

  /// Grey flashlight box with red button and dark head, aimed at O.
  void _flashlight(Canvas canvas) {
    final d = Offset(_oX, _oY) - flPos;
    final ang = math.atan2(d.dy, d.dx);
    canvas.save();
    final centre = _po(flPos);
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-ang); // screen y is flipped vs world y
    Rect r(double cx, double cy, double w, double h) => Rect.fromCenter(
        center: Offset(cx * _s, -cy * _s), width: w * _s, height: h * _s);
    if (scenario == 1 && step == 3) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r(0, 0, 5.2, 2.6), Radius.circular(0.4 * _s)),
        Paint()
          ..color = _accent.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, 0.18 * _s),
      );
    }
    canvas.drawRect(r(0, 0, 4, 1.5), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(r(-0.5, 0, 0.8, 0.4), Paint()..color = const Color(0xFFEF4444));
    canvas.drawRect(r(2.4, 0, 0.8, 1.4), Paint()..color = const Color(0xFF1E293B));
    canvas.restore();
  }

  /// Wood-yellow ruler with tick marks; vertical once snapped on O.
  void _ruler(Canvas canvas) {
    canvas.save();
    final centre = _po(rulerPos);
    canvas.translate(centre.dx, centre.dy);
    if (rulerSnapped) canvas.rotate(-math.pi / 2);
    final body = Rect.fromCenter(center: Offset.zero, width: 10 * _s, height: 1.5 * _s);
    if (!rulerSnapped && step == 2) {
      canvas.drawRect(
        body.inflate(0.3 * _s),
        Paint()
          ..color = _beamOrange.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, 0.18 * _s),
      );
    }
    canvas.drawRect(body, Paint()..color = const Color(0xFFFCD34D));
    canvas.drawRect(
      body,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 0.08 * _s),
    );
    final tick = Paint()
      ..color = Colors.black
      ..strokeWidth = math.max(1, 0.04 * _s);
    for (var x = -5.0; x <= 5.0; x += 0.5) {
      final major = (x * 2).round() % 2 == 0;
      canvas.drawLine(
        Offset(x * _s, -0.75 * _s),
        Offset(x * _s, (-0.75 + (major ? 0.55 : 0.3)) * _s),
        tick,
      );
    }
    canvas.restore();
  }

  /// Semi-circular translucent protractor (source canvas texture): outline,
  /// baseline, vertical, 5-degree ticks and |90 - a| labels every 30 degrees.
  void _protractor(Canvas canvas) {
    const r = 6.8;
    final centre = _po(protPos);
    final rect = Rect.fromCircle(center: centre, radius: r * _s);
    final fill = Paint()..color = _accent.withValues(alpha: 0.38);
    final line = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, 0.08 * _s);
    final half = Path()
      ..moveTo(centre.dx - r * _s, centre.dy)
      ..arcTo(rect, math.pi, math.pi, false)
      ..close();
    canvas.drawPath(half, fill);
    canvas.drawPath(half, line);
    canvas.drawLine(Offset(centre.dx - r * _s, centre.dy),
        Offset(centre.dx + r * _s, centre.dy), line);
    canvas.drawLine(centre, Offset(centre.dx, centre.dy - r * _s), line);
    canvas.drawCircle(centre, 0.18 * _s, Paint()..color = Colors.black);
    for (var a = 0; a <= 180; a += 5) {
      final rad = a * math.pi / 180;
      final isTen = a % 10 == 0;
      final dir = Offset(-math.cos(rad), -math.sin(rad)); // screen coords
      final outer = centre + dir * (r * _s);
      final inner = centre + dir * ((isTen ? r - 0.9 : r - 0.45) * _s);
      canvas.drawLine(
        outer,
        inner,
        Paint()
          ..color = Colors.black
          ..strokeWidth = math.max(1, (isTen ? 0.06 : 0.03) * _s),
      );
      if (a % 30 == 0) {
        final lp = centre + dir * ((r - 1.7) * _s);
        _text(canvas, '${(90 - a).abs()}', lp, 0.75 * _s, Colors.black);
      }
    }
    if (scenario == 1 && step == 4 && protPos != const Offset(_oX, _oY)) {
      canvas.drawPath(
        half,
        Paint()
          ..color = _accent.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, 0.16 * _s),
      );
    }
  }

  /// Scenario 2 paper sheets: static upper half + draggable lower half with
  /// the yellow bend handle (scale.y = 0.2 when bent, like the source).
  void _paper(Canvas canvas) {
    final paper = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRect(
        Rect.fromPoints(_p(-8, _oY + 6), _p(8, _oY - 2)), paper);
    final halfH = (isBent ? 0.6 : 3.0);
    canvas.drawRect(
        Rect.fromPoints(_p(-8, paperY + halfH), _p(8, paperY - halfH)), paper);
    final handleY = paperY - (isBent ? 0.5 : 2.5);
    final handle = Rect.fromPoints(
        _p(-4, handleY + 0.2), _p(4, handleY - 0.2));
    canvas.drawRect(handle, Paint()..color = _accent);
    if (step == 3 || step == 4) {
      canvas.drawRect(
        handle.inflate(0.15 * _s),
        Paint()
          ..color = _accent.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, 0.14 * _s),
      );
    }
  }

  /// Floating HTML-style label chip.
  void _chip(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: Colors.white,
            fontSize: math.max(9, 0.75 * _s),
            fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pad = Offset(6, 3);
    final rect = Rect.fromCenter(
        center: at, width: tp.width + pad.dx * 2, height: tp.height + pad.dy * 2);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rr, Paint()..color = const Color(0xE60F172A));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = _accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, rect.topLeft + pad);
  }

  void _text(Canvas canvas, String s, Offset centre, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style:
              TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ReflectionPainter old) =>
      old.scenario != scenario ||
      old.step != step ||
      old.flPos != flPos ||
      old.rulerPos != rulerPos ||
      old.rulerVisible != rulerVisible ||
      old.rulerSnapped != rulerSnapped ||
      old.protPos != protPos ||
      old.protVisible != protVisible ||
      old.normalDrawn != normalDrawn ||
      old.laserOn != laserOn ||
      old.isBent != isBent ||
      old.paperY != paperY ||
      !_sameLabels(old.labels, labels);

  static bool _sameLabels(List<(String, Offset)> a, List<(String, Offset)> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].$1 != b[i].$1 || a[i].$2 != b[i].$2) return false;
    }
    return true;
  }
}
