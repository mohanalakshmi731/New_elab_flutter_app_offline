// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 10.4: Spherical Mirrors and Sunlight Focus
// Converted from
// Cl8S-Ch10-A1-Spherical_Mirrors_and_Sunlight_Focus_Simulation_Strategy.html
// ("Mirror Beam Explorer"; Tailwind DOM + inline SVG + GSAP +
// canvas-confetti -> Flutter widgets + CustomPainters, zoom/pan via
// InteractiveViewer).
//
// Two scenarios chosen from the sidebar, each opened by a setup board.
// 1: Parallel Beams and Mirrors -- drag (or tap, then tap the stand) a comb
// in front of a torch to split its beam into five parallel rays, then mount a
// plane, a concave and a convex mirror in turn: the rays reflect parallel,
// converge on a focus F, or spread out. 2: Concave Mirror Sunlight Focus --
// slide a paper screen until the reflected sunlight shrinks to a white-hot
// spot at F, hold it there while it heats up and catches fire, then tick the
// safety checklist. Observation log, current-task HUD, labels / pan toggles,
// every source string (EN/HI; the source's TE block is dropped like every
// other page) and confetti are ported. The mirrors are drawn with the correct
// curvature and the rays reflect off the drawn curve (the source drew the
// concave and convex shapes swapped and bounced its rays off points that
// were not on the mirror).

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
    'title': 'Mirror Beam Explorer',
    'subtitle': 'Class 8: MIRRORS AND LENSES',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Plane • Concave • Convex • Focus',
    'tabGuide': 'Lab Guide',
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
    'items': {
      'comb': 'Comb',
      'plane': 'Plane Mirror',
      'concave': 'Concave Mirror',
      'convex': 'Convex Mirror',
    },
    'placeMirror': 'Place Mirror',
    'paperScreen': 'Paper Screen',
    'closerSun': 'Closer to Sun',
    'closerMirror': 'Closer to Mirror',
    'safetyTitle': 'Safety Checklist',
    'checks': [
      'Do not look directly at the Sun',
      "Do not reflect sunlight into anyone's eyes",
      'Perform only under teacher supervision',
    ],
    'complete': 'Complete Activity',
    'heating': 'Heating...',
    'cannotPlace': 'Cannot place that here!',
    'combFirst': 'Place the comb first!',
    'checkRules': 'Please review and check all safety rules!',
    'logs': {
      'comb': ['Placed Comb', 'Created multiple thin parallel beams.'],
      'plane': ['Plane Mirror', 'Beams reflect parallel.'],
      'concave': ['Concave Mirror', 'Beams converge to a focus.'],
      'convex': ['Convex Mirror', 'Beams diverge (spread out).'],
      'focus': ['Found Focal Point', 'A tiny, intense bright spot formed.'],
      'hold': ['Held at focus', 'Intense heat generated (burning).'],
      'check': ['Completed Checklist', 'Safety rules acknowledged.'],
    },
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'scenarios': {
      '1': {
        'title': 'Scenario 1: Parallel Beams and Mirrors',
        'objective':
            'Investigate how plane, concave, and convex mirrors reflect multiple parallel light beams.',
        'boardDesc':
            "Using a comb and a torch, we can create parallel beams of light. Let's see what happens when these beams hit different types of curved mirrors.",
        'boardBtn': 'Start Experiment',
        'hud': [
          '',
          'STEP 1: Drag or tap the Comb onto the dropzone to create parallel light beams.',
          'STEP 2: Drag or tap the Plane Mirror onto the stand to see how a flat surface reflects light.',
          'STEP 3: Drag or tap the Concave Mirror onto the stand to see how it bends the parallel beams inward.',
          'STEP 4: Drag or tap the Convex Mirror onto the stand to see how it spreads the beams outward.',
        ],
        'steps': [
          {
            'concept': 'Creating Parallel Beams',
            'action': 'PLACE the comb on the dropzone.',
            'observation':
                "The comb's teeth block light, creating distinct, parallel light beams.",
          },
          {
            'concept': 'Plane Mirror',
            'action': 'TEST the Plane Mirror.',
            'observation':
                'The flat surface reflects light evenly; beams remain perfectly parallel.',
          },
          {
            'concept': 'Concave Mirror',
            'action': 'TEST the Concave Mirror.',
            'observation':
                'The curved-in surface reflects beams inward, converging them to a single focal point.',
          },
          {
            'concept': 'Convex Mirror',
            'action': 'TEST the Convex Mirror.',
            'observation':
                'The curved-out surface reflects beams outward, spreading them apart.',
          },
        ],
        'summaryLead': 'Mirrors Behave Differently!',
        'summary':
            'Plane mirrors keep parallel rays parallel. Concave mirrors converge rays to a point. Convex mirrors diverge rays.',
      },
      '2': {
        'title': 'Scenario 2: Concave Mirror Sunlight Focus',
        'objective':
            'Safely investigate how a concave mirror concentrates sunlight.',
        'boardDesc':
            "Solar cookers use concave reflectors to concentrate sunlight and produce heat. Let's find the focal point of a concave mirror.",
        'boardBtn': 'Enter Setup',
        'hud': [
          '',
          'FIND FOCUS: Slowly drag the slider left/right until the bright yellow spot on the paper becomes perfectly small and sharp.',
          'WAIT & OBSERVE: Hold the paper exactly at the focal point without moving it to see the heat buildup.',
          'SAFETY FIRST: Concentrated sunlight is dangerous. Review and check all safety rules below.',
        ],
        'steps': [
          {
            'concept': 'Finding the Focus',
            'action': 'SLIDE the paper screen slowly.',
            'observation':
                'At the exact focal distance, the mirror concentrates all sunlight into a tiny, intensely bright spot.',
          },
          {
            'concept': 'Heating Effect',
            'action': 'WAIT at the focal point.',
            'observation':
                'The concentrated solar energy generates intense heat, enough to ignite the paper.',
          },
          {
            'concept': 'Safety First',
            'action': 'COMPLETE the safety checklist.',
            'observation':
                'Always use caution: concentrated sunlight can damage eyes or cause accidental fires.',
          },
        ],
        'summaryLead': 'Focus Achieved!',
        'summary':
            'A concave mirror focuses parallel rays of sunlight to a single point, generating enough heat to burn paper. This principle is used in solar cookers.',
      },
    },
  },
  'hi': {
    'title': 'दर्पण किरण अन्वेषक',
    'subtitle': 'कक्षा 8: दर्पण और लेंस',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'समतल • अवतल • उत्तल • फोकस', // added
    'tabGuide': 'लैब गाइड', // added
    'selectScenario': 'परिदृश्य चुनें',
    'missionObjective': 'उद्देश्य',
    'explorationSteps': 'चरण',
    'step': 'चरण',
    'focus': 'अवधारणा',
    'action': 'कार्रवाई',
    'observation': 'अवलोकन',
    'keyTakeaway': 'निष्कर्ष',
    'scenarioComplete': 'पूरा हुआ!',
    'success': 'सफलता!',
    'currentTask': 'वर्तमान कार्य',
    'obsLog': 'लॉग',
    'clear': 'साफ़ करें',
    'result': 'परिणाम',
    'noObs': 'कोई डेटा नहीं।',
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'रीसेट करें',
    'items': {
      'comb': 'कंघी',
      'plane': 'समतल दर्पण',
      'concave': 'अवतल दर्पण',
      'convex': 'उत्तल दर्पण',
    },
    'placeMirror': 'दर्पण रखें',
    'paperScreen': 'कागज का पर्दा',
    'closerSun': 'सूर्य के करीब',
    'closerMirror': 'दर्पण के करीब',
    'safetyTitle': 'सुरक्षा चेकलिस्ट',
    'checks': [
      'सूर्य को सीधे न देखें',
      'किसी की आंखों में सूरज की रोशनी न डालें',
      'केवल शिक्षक की देखरेख में करें',
    ],
    'complete': 'गतिविधि पूरी करें',
    'heating': 'गर्म हो रहा है...', // added
    'cannotPlace': 'इसे यहाँ नहीं रखा जा सकता!', // added
    'combFirst': 'पहले कंघी रखें!',
    'checkRules': 'कृपया सभी सुरक्षा नियमों की समीक्षा करें और जांचें!',
    'logs': {
      'comb': ['कंघी रखी', 'कई पतली समानांतर किरणें बनीं।'],
      'plane': ['समतल दर्पण', 'किरणें समानांतर परावर्तित होती हैं।'],
      'concave': ['अवतल दर्पण', 'किरणें एक फोकस पर अभिसरित होती हैं।'],
      'convex': ['उत्तल दर्पण', 'किरणें फैलती (अपसरित) हैं।'],
      'focus': ['फोकस बिंदु मिला', 'एक छोटा, तीव्र चमकीला बिंदु बना।'],
      'hold': ['फोकस पर रखा', 'अत्यधिक गर्मी उत्पन्न हुई (जलन)।'],
      'check': ['चेकलिस्ट पूरी की', 'सुरक्षा नियमों को स्वीकार किया गया।'],
    },
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
    'scenarios': {
      '1': {
        'title': 'परिदृश्य 1: समानांतर किरणें और दर्पण',
        'objective':
            'जांच करें कि समतल, अवतल और उत्तल दर्पण समानांतर प्रकाश किरणों को कैसे परावर्तित करते हैं।',
        'boardDesc':
            'कंघी और टॉर्च का उपयोग करके, हम प्रकाश की समानांतर किरणें बना सकते हैं। आइए देखें कि क्या होता है जब ये किरणें विभिन्न दर्पणों से टकराती हैं।',
        'boardBtn': 'प्रयोग शुरू करें',
        'hud': [
          '',
          'चरण 1: समानांतर किरणें बनाने के लिए ड्रॉपज़ोन पर कंघी खींचें या टैप करें।',
          'चरण 2: समतल दर्पण को स्टैंड पर खींचें या टैप करें।',
          'चरण 3: अवतल दर्पण को स्टैंड पर खींचें या टैप करें।',
          'चरण 4: उत्तल दर्पण को स्टैंड पर खींचें या टैप करें।',
        ],
        'steps': [
          {
            'concept': 'समानांतर किरणें',
            'action': 'कंघी रखें।',
            'observation': 'कंघी समानांतर किरणें बनाती है।',
          },
          {
            'concept': 'समतल दर्पण',
            'action': 'समतल दर्पण का परीक्षण करें।',
            'observation': 'परावर्तित किरणें समानांतर रहती हैं।',
          },
          {
            'concept': 'अवतल दर्पण',
            'action': 'अवतल दर्पण का परीक्षण करें।',
            'observation':
                'दर्पण किरणों को एक बिंदु पर केंद्रित (अभिसरण) करता है।',
          },
          {
            'concept': 'उत्तल दर्पण',
            'action': 'उत्तल दर्पण का परीक्षण करें।',
            'observation': 'दर्पण किरणों को फैलाता (अपसरण) है।',
          },
        ],
        'summaryLead': 'दर्पण अलग तरह से व्यवहार करते हैं!',
        'summary':
            'समतल दर्पण समानांतर किरणों को समानांतर रखते हैं। अवतल दर्पण प्रकाश को केंद्रित करता है, जबकि उत्तल दर्पण प्रकाश को फैलाता है।',
      },
      '2': {
        'title': 'परिदृश्य 2: सूर्य के प्रकाश का फोकस',
        'objective':
            'जांच करें कि अवतल दर्पण सूर्य के प्रकाश को कैसे केंद्रित करता है।',
        'boardDesc':
            'सौर कुकर गर्मी पैदा करने के लिए अवतल परावर्तकों का उपयोग करते हैं।',
        'boardBtn': 'सेटअप दर्ज करें',
        'hud': [
          '',
          'फोकस खोजें: सबसे चमकीला बिंदु खोजने के लिए पेपर स्लाइडर ले जाएँ।',
          'प्रतीक्षा करें और देखें: गर्मी का निर्माण देखने के लिए फोकस बिंदु पर रुकें।',
          'सुरक्षा पहले: केंद्रित धूप खतरनाक है। सुरक्षा चेकलिस्ट पूरी करें।',
        ],
        'steps': [
          {
            'concept': 'फोकस खोजना',
            'action': 'पेपर को स्लाइड करें।',
            'observation': 'फोकस दूरी पर एक छोटा चमकीला बिंदु दिखाई देता है।',
          },
          {
            'concept': 'हीटिंग प्रभाव',
            'action': 'प्रतीक्षा करें।',
            'observation': 'केंद्रित प्रकाश अत्यधिक गर्मी पैदा करता है।',
          },
          {
            'concept': 'सुरक्षा',
            'action': 'चेकलिस्ट पूरी करें।',
            'observation':
                'सूर्य के प्रकाश को परावर्तित करते समय हमेशा सावधान रहें।',
          },
        ],
        'summaryLead': 'फोकस प्राप्त हुआ!',
        'summary':
            'अवतल दर्पण सूर्य के प्रकाश को एक बिंदु पर केंद्रित कर सकता है, जिससे अत्यधिक गर्मी पैदा होती है।',
      },
    },
  },
});

// ------------------------------------------------------------- constants ----

/// Design sizes of the two stages: the source's SVG `viewBox`es.
const Size _kBeamStage = Size(1000, 450);
const Size _kSunStage = Size(1000, 400);

/// Canvases shorter than this (phone landscape) get a tighter top inset.
const double _kShortHeight = 500;

/// Height of the scenario-1 tray row and of the scenario-2 slider panel.
const double _kTrayHeight = 46;
const double _kSliderPanelHeight = 92;

// Scenario 1 geometry (source SVG coordinates).
const Rect _kTorchRect = Rect.fromLTWH(20, 180, 150, 90);
const Rect _kCombZone = Rect.fromLTWH(200, 135, 80, 180);
const Rect _kMirrorZone = Rect.fromLTWH(650, 112.5, 160, 225);

/// The comb itself: 60 % x 95 % of its drop zone.
const Rect _kCombRect = Rect.fromLTWH(216, 139.5, 48, 171);
const double _kBeamAxis = 225;
const List<double> _kBeamOffsets = [-40, -20, 0, 20, 40];

/// Every mirror spans the beam axis +-70 (y 155-295), centred on x 730.
const double _kMirrorTop = 155;
const double _kMirrorBottom = 295;

/// The concave mirror's focus. Its curve is the parabola that sends
/// horizontal rays through this point: x = 802.5 - (y - 80)^2 / 290.
const Offset _kConcaveFocus = Offset(730, 80);

/// The convex mirror's virtual focus behind it. Its curve sends horizontal
/// rays straight away from this point: x = 657.5 + (y - 370)^2 / 290.
const Offset _kConvexFocus = Offset(730, 370);

// Scenario 2 geometry.
const Offset _kSunFocus = Offset(450, 200);
const double _kSunMirrorVertex = 800;
const List<double> _kSunOffsets = [-150, -75, 0, 75, 150];

/// Paper screen: `w-[3%]`, `top-[5%] bottom-[5%]`.
const double _kPaperWidth = 30;
const double _kPaperTop = 20;
const double _kPaperBottom = 380;

/// The paper counts as "at the focus" within this many design px.
const double _kFocusTolerance = 5;

/// The source's `confetti({colors: [...]})` palette.
const List<Color> _kConfettiColors = [
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
];

const Color _kYellow100 = Color(0xFFFEF9C3);
const Color _kYellow200 = Color(0xFFFEF08A);
const Color _kYellow300 = Color(0xFFFDE047);
const Color _kYellow700 = Color(0xFFA16207);
const Color _kAmber800 = Color(0xFF92400E);
const Color _kRed950 = Color(0xFF450A0A);
const Color _kRed800 = Color(0xFF991B1B);
const Color _kBlue300 = Color(0xFF93C5FD);
const Color _kSky900 = Color(0xFF0C4A6E);

// ------------------------------------------------------------------ model ----

/// The tray pieces of scenario 1, in the order they appear.
enum _Item {
  comb(Icons.view_week, _rt_Tw.yellow500),
  plane(Icons.horizontal_rule, _rt_Tw.blue500),
  concave(Icons.nightlight_round, _rt_Tw.blue500),
  convex(Icons.circle_outlined, _rt_Tw.blue500);

  const _Item(this.icon, this.color);

  final IconData icon;
  final Color color;

  bool get isMirror => this != comb;
  String get label => _tx.s('items.$name');
}

/// The two drop zones of scenario 1.
enum _Zone { comb, mirror }

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result);

  final String Function() action;
  final String Function() result;
}

// ------------------------------------------------------------- geometry ----

/// The plane mirror: the 45 degree line through (730, 225).
double _planeX(double y) => 730 - (y - _kBeamAxis);

double _concaveX(double y) => 802.5 - (y - 80) * (y - 80) / 290;

double _convexX(double y) => 657.5 + (y - 370) * (y - 370) / 290;

/// x of [mirror]'s surface at height [y].
double _mirrorX(_Item mirror, double y) => switch (mirror) {
  _Item.plane => _planeX(y),
  _Item.concave => _concaveX(y),
  _Item.convex => _convexX(y),
  _Item.comb => throw ArgumentError.value(mirror),
};

/// Where a horizontal ray at height [y] leaves the 1000 x 450 stage after
/// reflecting off [mirror] at [hit].
Offset _reflectedEnd(_Item mirror, Offset hit) {
  switch (mirror) {
    case _Item.plane:
      return Offset(hit.dx, 0);
    case _Item.concave:
      // Through the focus and on to the top edge.
      final t = hit.dy / (hit.dy - _kConcaveFocus.dy);
      return hit + (_kConcaveFocus - hit) * t;
    case _Item.convex:
      // Straight away from the virtual focus, up to the top edge.
      final t = hit.dy / (_kConvexFocus.dy - hit.dy);
      return hit + (hit - _kConvexFocus) * t;
    case _Item.comb:
      throw ArgumentError.value(mirror);
  }
}

/// Scenario 2's concave mirror: x = 800 - (y - 200)^2 / 1400 has its focus
/// at (450, 200).
double _sunMirrorX(double y) =>
    _kSunMirrorVertex - (y - _kSunFocus.dy) * (y - _kSunFocus.dy) / 1400;

// ------------------------------------------------------------------- page ----

class Cl8Ch10A4SphericalMirrorsSunlightFocusPage extends StatefulWidget {
  const Cl8Ch10A4SphericalMirrorsSunlightFocusPage({super.key});

  @override
  State<Cl8Ch10A4SphericalMirrorsSunlightFocusPage> createState() =>
      _Cl8Ch10A4SphericalMirrorsSunlightFocusPageState();
}

class _Cl8Ch10A4SphericalMirrorsSunlightFocusPageState
    extends State<Cl8Ch10A4SphericalMirrorsSunlightFocusPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.5,
    max: 2.5,
  );
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();
  final ScrollController _workspaceScroll = ScrollController();
  final GlobalKey _checklistKey = GlobalKey();

  /// Seconds since the page opened; drives the flame's flicker.
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _clock.value = elapsed.inMicroseconds / 1e6,
  );

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  /// The 1.5 s heat bar of scenario 2 (the source's `focusTimer`).
  late final AnimationController _heat =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finishHeating();
      });

  final List<Timer> _timers = [];
  DateTime _lastSliderTick = DateTime.fromMillisecondsSinceEpoch(0);

  // Shared (source `State`). Step 0 = the setup board is showing.
  int _scenario = 1;
  int _step = 0;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  Size _stageViewport = Size.zero;

  // Scenario 1 (source `s1State` + `activeSelection`).
  bool _combPlaced = false;
  _Item? _mirror;
  _Item? _selected;

  // Scenario 2 (source `s2State`).
  int _paperPercent = 25;
  bool _burned = false;
  final List<bool> _checks = [false, false, false];

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
    _heat.dispose();
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
  /// Scenario 1 has four steps, scenario 2 three.
  int get _stepCount => _scenario == 1 ? 4 : 3;

  bool get _boardOpen => _step == 0;

  /// Appends a log row from the `logs.<key>` pair; call inside `setState`.
  void _pushLog(String key) {
    _log.add(_LogEntry(() => _tx.s('logs.$key.0'), () => _tx.s('logs.$key.1')));
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

  void _toast(String key) {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(
      _tx.s(key),
      color: _rt_Tw.red500,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// The source's `changeScenario` + `setupS1` / `setupS2` (state only; call
  /// inside `setState`).
  void _enterScenario(int scenario) {
    _scenario = scenario;
    _step = 0;
    _toggledTiles.clear();
    _log.clear();
    _combPlaced = false;
    _mirror = null;
    _selected = null;
    _paperPercent = 25;
    _burned = false;
    _checks.fillRange(0, _checks.length, false);
    _heat.stop();
    _heat.value = 0;
  }

  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() => _enterScenario(scenario));
    _zoom.reset();
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

  /// The source's `startActivityFromBoard`.
  void _startFromBoard() {
    if (!_boardOpen) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _step = 1);
  }

  /// The source's `updateHUD(step)`. Past the last step the HUD hides and the
  /// summary follows after [summaryDelay] ms.
  void _advanceTo(int step, {int summaryDelay = 1500}) {
    setState(() {
      _step = step;
      _toggledTiles.clear();
    });
    if (step > _stepCount) {
      final scenario = _scenario;
      _after(summaryDelay, () {
        if (_scenario == scenario && _step > _stepCount) {
          _rt_playSfx(_rt_Sfx.success);
          _showSummary();
        }
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
  /// The one tray piece on offer: each appears after the previous one is
  /// placed (source `display: flex/none`).
  _Item? get _trayItem =>
      _scenario == 1 && _step >= 1 && _step <= _Item.values.length
      ? _Item.values[_step - 1]
      : null;

  /// The source's `selectPart`: tap a piece, then tap where it goes.
  void _toggleSelected(_Item item) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selected = _selected == item ? null : item);
  }

  /// The source's `handleDropZone`.
  void _tapZone(_Zone zone) {
    final item = _selected;
    if (item != null) _place(item, zone);
  }

  /// The source's `s1Drop` / `s1DropLogic`.
  void _place(_Item item, _Zone zone) {
    if (_scenario != 1 || _boardOpen) return;
    setState(() => _selected = null);
    final fits = zone == _Zone.comb ? item == _Item.comb : item.isMirror;
    if (!fits) {
      _toast('cannotPlace');
      return;
    }
    if (item.isMirror && !_combPlaced) {
      _toast('combFirst');
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      if (item == _Item.comb) {
        _combPlaced = true;
      } else {
        _mirror = item;
      }
      _pushLog(item.name);
    });
    // Each piece finishes the step that offered it.
    final step = item.index + 1;
    if (_step == step) _advanceTo(step + 1);
  }

  // ------------------------------------------------------ scenario 2 logic --
  double get _paperX => _paperPercent * 10.0;
  double get _focusDistance => (_paperX - _kSunFocus.dx).abs();
  bool get _atFocus => _focusDistance < _kFocusTolerance;

  /// The source's `s2UpdatePaper` (slider `oninput`).
  void _onPaperChanged(double value) {
    if (_scenario != 2 || _step < 1 || _step > 2) return;
    final percent = value.round();
    if (percent == _paperPercent) return;
    final now = DateTime.now();
    if (now.difference(_lastSliderTick).inMilliseconds > 60) {
      _rt_playSfx(_rt_Sfx.tap);
      _lastSliderTick = now;
    }
    setState(() => _paperPercent = percent);
    if (!_atFocus) {
      // Moving off the focus cancels the heating (source `clearTimeout`).
      if (_heat.value > 0) {
        _heat.stop();
        _heat.value = 0;
      }
      return;
    }
    if (_step == 1) {
      _rt_playSfx(_rt_Sfx.success);
      setState(() => _pushLog('focus'));
      _advanceTo(2);
    }
    if (_step == 2 && !_heat.isAnimating && !_burned) {
      _rt_playSfx(_rt_Sfx.magic);
      _heat.forward(from: 0);
    }
  }

  /// The source's `focusTimer` callback: the paper catches fire and the
  /// safety checklist replaces the slider.
  void _finishHeating() {
    if (_scenario != 2 || _step != 2 || !_atFocus || _burned) return;
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _burned = true;
      _pushLog('hold');
    });
    _advanceTo(3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checklist = _checklistKey.currentContext;
      if (mounted && checklist != null) {
        // Scrolls only if the checklist (and the room kept under it for the
        // log) is not already in view.
        Scrollable.ensureVisible(
          checklist,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  /// The source's `s2Checklist`.
  void _completeChecklist() {
    if (_scenario != 2 || _step != 3) return;
    _rt_playSfx(_rt_Sfx.click);
    if (_checks.contains(false)) {
      _toast('checkRules');
      return;
    }
    setState(() => _pushLog('check'));
    _advanceTo(4, summaryDelay: 0);
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
            icon: Icons.flashlight_on,
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
            if (_step >= 1 && _step <= _stepCount)
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
  /// The source's `#interactive-ui-layer`: the setup board, then the
  /// scenario's view.
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
        final gap = short ? 10.0 : 18.0;
        if (_boardOpen) {
          // The board is centred in the canvas (it scrolls on tiny screens).
          return Center(
            child: SingleChildScrollView(
              key: const ValueKey('board-scroll'),
              padding: const EdgeInsets.fromLTRB(16, 16, 60, 16),
              child: _setupBoard(short: short),
            ),
          );
        }
        return SingleChildScrollView(
          key: const ValueKey('workspace'),
          controller: _workspaceScroll,
          padding: EdgeInsets.fromLTRB(12, topInset, 60, 170),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: _scenario == 1
                  ? _beamView(contentWidth, available, gap)
                  : _sunView(contentWidth, available, gap),
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
    double maxScale = 1,
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
              child: SizedBox.fromSize(size: design, child: stage),
            ),
          ),
        ),
      ),
    );
  }

  /// Fades the source's `.dynamic-label` / `label-*` elements with the labels
  /// toggle.
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

  /// The source's `#ui-setup-board`: objective, description and the button
  /// that starts step 1 (scaled in like its GSAP `back.out`).
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
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          key: const ValueKey('board'),
          padding: EdgeInsets.symmetric(
            horizontal: short ? 20 : 36,
            vertical: short ? 18 : 32,
          ),
          decoration: BoxDecoration(
            color: _rt_Lab.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _rt_Tw.blue500.withValues(alpha: 0.5),
              width: 4,
            ),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.track_changes,
                size: short ? 40 : 60,
                color: _rt_Tw.blue500,
              ),
              SizedBox(height: short ? 8 : 16),
              Text(
                _tx.s('scenarios.$_scenario.objective'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 16 : 24,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                  height: 1.4,
                ),
              ),
              SizedBox(height: short ? 8 : 16),
              Text(
                _tx.s('scenarios.$_scenario.boardDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 12.5 : 16,
                  fontWeight: FontWeight.w600,
                  color: _rt_Lab.onTinted(_rt_Tw.blue100, _rt_Tw.slate600),
                  height: 1.4,
                ),
              ),
              SizedBox(height: short ? 14 : 28),
              _ChunkyButton(
                key: const ValueKey('board-btn'),
                label: _tx.s('scenarios.$_scenario.boardBtn'),
                color: _rt_Tw.blue600,
                borderColor: _rt_Tw.blue800,
                onPressed: _startFromBoard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------- scenario 1 UI --
  /// `#ui-sc1`: the tray chip above the torch / comb / mirror stage.
  Widget _beamView(double width, double available, double gap) {
    final item = _trayItem;
    return Column(
      children: [
        SizedBox(
          height: _kTrayHeight,
          child: Center(child: item == null ? null : _trayChip(item)),
        ),
        SizedBox(height: gap),
        _stageBox(
          _beamStage(),
          _kBeamStage,
          width,
          math.max(150.0, available - _kTrayHeight - gap),
        ),
      ],
    );
  }

  /// A tray piece: tap to select it, or drag it straight onto a zone.
  Widget _trayChip(_Item item) {
    final face = _chipFace(item, selected: _selected == item);
    return TweenAnimationBuilder<double>(
      // Pops in like the source's GSAP `back.out`.
      key: ValueKey('chip-in-${item.name}'),
      tween: Tween(begin: 0.5, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Draggable<_Item>(
        key: ValueKey('item-${item.name}'),
        data: item,
        onDragStarted: () => _rt_playSfx(_rt_Sfx.pop),
        feedback: Material(
          type: MaterialType.transparency,
          child: Transform.scale(
            scale: 1.08,
            child: _chipFace(item, selected: true, lifted: true),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: face),
        child: GestureDetector(
          onTap: () => _toggleSelected(item),
          child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
        ),
      ),
    );
  }

  Widget _chipFace(_Item item, {required bool selected, bool lifted = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      transform: Matrix4.diagonal3Values(
        selected ? 1.05 : 1,
        selected ? 1.05 : 1,
        1,
      ),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _rt_Tw.blue500 : _rt_Lab.borderStrong,
          width: selected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? _rt_Tw.blue500.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: lifted ? 0.35 : 0.2),
            blurRadius: selected || lifted ? 20 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 20, color: item.color),
          const SizedBox(width: 8),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.text,
            ),
          ),
        ],
      ),
    );
  }

  /// The dark bench: torch, comb, mirror and rays (painted), with the two
  /// drop zones on top.
  Widget _beamStage() {
    final mirror = _mirror;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rt_Tw.slate900, Colors.black],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.slate700, width: 4),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              key: const ValueKey('beam-canvas'),
              painter: _BeamPainter(combPlaced: _combPlaced, mirror: mirror),
            ),
          ),
          Positioned.fromRect(rect: _kCombZone, child: _dropZone(_Zone.comb)),
          Positioned.fromRect(
            rect: _kMirrorZone,
            child: _dropZone(_Zone.mirror),
          ),
          if (mirror != null)
            Positioned(
              left: _kMirrorZone.left - 40,
              width: _kMirrorZone.width + 80,
              // Under the stand: above it the badge would hide the focus F.
              top: _kMirrorZone.bottom + 2,
              child: Center(
                child: _label(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Tw.blue600,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _rt_Tw.blue400),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      mirror.label,
                      key: const ValueKey('mirror-badge'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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

  /// `#s1-comb-drop` / `#s1-mirror-drop`: accepts drags and, with a piece
  /// selected, taps.
  Widget _dropZone(_Zone zone) {
    final isComb = zone == _Zone.comb;
    final filled = isComb ? _combPlaced : _mirror != null;
    final accent = isComb ? _rt_Tw.yellow400 : _rt_Tw.blue400;
    final selected = _selected;
    final invited =
        selected != null &&
        (isComb ? selected == _Item.comb : selected.isMirror);
    return DragTarget<_Item>(
      key: ValueKey('zone-${zone.name}'),
      onAcceptWithDetails: (details) => _place(details.data, zone),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        final highlight = hovering || invited;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _tapZone(zone),
          child: MouseRegion(
            cursor: selected != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: CustomPaint(
              painter: filled && !highlight
                  ? null
                  : _DashedRRectPainter(
                      color: highlight ? accent : _rt_Tw.slate500,
                      radius: isComb ? 4 : 12,
                    ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.transparent
                      : _rt_Tw.slate800.withValues(
                          alpha: highlight ? 0.75 : 0.5,
                        ),
                  borderRadius: BorderRadius.circular(isComb ? 4 : 12),
                ),
                alignment: Alignment.center,
                child: filled
                    ? null
                    : _label(
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            _tx
                                .s(isComb ? 'items.comb' : 'placeMirror')
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isComb ? 12 : 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: highlight ? accent : _rt_Tw.slate400,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------- scenario 2 UI --
  /// `#ui-sc2`: the sun / mirror / paper stage, then the slider or, once the
  /// paper has burned, the safety checklist.
  Widget _sunView(double width, double available, double gap) {
    return Column(
      children: [
        _stageBox(
          _sunStage(),
          _kSunStage,
          width,
          math.max(150.0, available - _kSliderPanelHeight - gap),
        ),
        SizedBox(height: gap),
        if (_step >= 3)
          // The padding keeps room under the checklist, so scrolling it into
          // view also lifts its button clear of the observation log.
          Padding(
            key: _checklistKey,
            padding: const EdgeInsets.only(bottom: 56),
            child: _checklist(),
          )
        else
          _sliderPanel(),
      ],
    );
  }

  Widget _sunStage() {
    final x = _paperX;
    final distance = _focusDistance;
    final focused = _atFocus;
    final spotWidth = math.max(5.0, distance * 0.4);
    final spotHeight = spotWidth * 1.8;
    final intensity = math.max(0.1, 1 - distance / 150);
    final axis = _kSunFocus.dy;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kSky900, _rt_Tw.slate900]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.slate700, width: 4),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: CustomPaint(
              key: ValueKey('sun-canvas'),
              painter: _SunPainter(),
            ),
          ),
          // `#s2-paper`
          Positioned(
            key: const ValueKey('paper'),
            left: x - _kPaperWidth / 2,
            top: _kPaperTop,
            width: _kPaperWidth,
            height: _kPaperBottom - _kPaperTop,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_rt_Tw.slate50, _rt_Tw.slate300, _rt_Tw.slate400],
                ),
                border: Border.all(color: _rt_Tw.slate600),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(5, 5),
                  ),
                ],
              ),
            ),
          ),
          // `#s2-spot`
          Positioned(
            left: x - spotWidth / 2,
            top: axis - spotHeight / 2,
            width: spotWidth,
            height: spotHeight,
            child: Opacity(
              opacity: intensity,
              child: DecoratedBox(
                key: const ValueKey('spot'),
                decoration: BoxDecoration(
                  color: focused ? Colors.white : _kYellow300,
                  borderRadius: BorderRadius.circular(spotHeight),
                  boxShadow: focused
                      ? const [
                          BoxShadow(color: Colors.white, blurRadius: 20),
                          BoxShadow(color: _rt_Tw.yellow400, blurRadius: 50),
                        ]
                      : [
                          BoxShadow(
                            color: _rt_Tw.yellow400,
                            blurRadius: spotWidth,
                          ),
                        ],
                ),
              ),
            ),
          ),
          // "Heating..." badge with its 1.5 s bar.
          AnimatedBuilder(
            animation: _heat,
            builder: (context, _) {
              if (_heat.value <= 0 || _burned) return const SizedBox.shrink();
              return Positioned(
                left: x - 60,
                top: axis - 70,
                width: 120,
                child: _heatingBadge(_heat.value),
              );
            },
          ),
          if (_burned)
            Positioned(
              left: x - 28,
              top: axis - 74,
              width: 56,
              height: 56,
              child: _flame(),
            ),
          Positioned(
            left: x - 70,
            width: 140,
            top: _kPaperBottom - 26,
            child: Center(
              child: _label(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _rt_Tw.slate800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _rt_Tw.slate600),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    _tx.s('paperScreen'),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  Widget _heatingBadge(double progress) {
    return Container(
      key: const ValueKey('heating-badge'),
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
      decoration: BoxDecoration(
        color: _rt_Tw.slate900,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _rt_Tw.slate700),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _clock,
            builder: (context, seconds, child) => Opacity(
              opacity: 0.6 + 0.4 * math.cos(seconds * math.pi * 2).abs(),
              child: child,
            ),
            child: Text(
              _tx.s('heating').toUpperCase(),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: _rt_Tw.orange400,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 7,
              color: _rt_Tw.slate800,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _rt_Tw.yellow400,
                        _rt_Tw.orange500,
                        _rt_Tw.red600,
                      ],
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

  /// The burning paper (the source's bouncing 🔥 emoji).
  Widget _flame() {
    return ValueListenableBuilder<double>(
      valueListenable: _clock,
      builder: (context, seconds, child) => Transform.translate(
        offset: Offset(0, -6 * math.sin(seconds * math.pi * 2).abs()),
        child: child,
      ),
      child: const Icon(
        Icons.local_fire_department,
        key: ValueKey('flame'),
        size: 56,
        color: _rt_Tw.orange500,
        shadows: [Shadow(color: _rt_Tw.red600, blurRadius: 16)],
      ),
    );
  }

  /// `#s2-slider-box`.
  Widget _sliderPanel() {
    final edgeLabel = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
      color: _rt_Lab.text,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: Container(
        height: _kSliderPanelHeight,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: _rt_Tw.slate800,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _rt_Tw.slate600),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
        ),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz, size: 26, color: _rt_Tw.blue400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label(
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _tx.s('closerSun').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: edgeLabel.copyWith(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _tx.s('closerMirror').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: edgeLabel.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: _rt_Tw.blue500,
                      inactiveTrackColor: _rt_Tw.slate600,
                      thumbColor: _rt_Tw.blue500,
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                    ),
                    child: Slider(
                      key: const ValueKey('s2-slider'),
                      value: _paperPercent.toDouble(),
                      min: 15,
                      max: 65,
                      divisions: 50,
                      onChanged: _onPaperChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `#s2-safety`.
  Widget _checklist() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _rt_Tw.slate900.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _rt_Tw.red500.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_rt_Tw.red500, _rt_Tw.orange500],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Column(
                key: const ValueKey('checklist'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: _rt_Tw.red400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tx.s('safetyTitle').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: _rt_Tw.red400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _checks.length; i++)
                    InkWell(
                      key: ValueKey('chk-${i + 1}'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        _rt_playSfx(_rt_Sfx.click);
                        setState(() => _checks[i] = !_checks[i]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            IgnorePointer(
                              child: Checkbox(
                                value: _checks[i],
                                // The whole row is the tap target.
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                activeColor: _rt_Tw.red500,
                                side: const BorderSide(
                                  color: _rt_Tw.slate400,
                                  width: 1.5,
                                ),
                                onChanged: (_) {},
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _tx.s('checks.$i'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _ChunkyButton(
                    key: const ValueKey('btn-complete'),
                    label: _tx.s('complete'),
                    color: _rt_Tw.red600,
                    borderColor: _kRed800,
                    onPressed: _step == 3 ? _completeChecklist : null,
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

/// The source's `.ray` stroke: a soft yellow glow under a bright core.
void _drawRay(Canvas canvas, Path path, {double opacity = 0.9}) {
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = _kYellow300.withValues(alpha: 0.55 * opacity),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _kYellow300.withValues(alpha: opacity),
  );
}

/// A focus marker: a yellow dot with an "F" under it.
void _drawFocus(Canvas canvas, Offset focus) {
  canvas.drawCircle(focus, 6, Paint()..color = _kYellow300);
  canvas.drawCircle(
    focus,
    6,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black,
  );
  final label = TextPainter(
    text: const TextSpan(
      text: 'F',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: _kYellow300,
        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  label.paint(canvas, focus + Offset(-label.width / 2, 10));
}

/// A curved mirror along [xOf] from [top] to [bottom], with the source's
/// dark drop shadow and silvery gradient.
void _drawMirror(
  Canvas canvas,
  double Function(double y) xOf,
  double top,
  double bottom, {
  double width = 16,
  List<Color> colors = const [
    _rt_Tw.slate300,
    Colors.white,
    _rt_Tw.slate400,
    _rt_Tw.slate600,
  ],
}) {
  final path = Path()..moveTo(xOf(top), top);
  for (var y = top + 4; y < bottom; y += 4) {
    path.lineTo(xOf(y), y);
  }
  path.lineTo(xOf(bottom), bottom);
  final bounds = path.getBounds().inflate(width);
  canvas.drawPath(
    path.shift(const Offset(8, 8)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = Colors.black.withValues(alpha: 0.6),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 8
      ..strokeCap = StrokeCap.round
      ..color = _rt_Tw.slate900,
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: colors,
        stops: const [0, 0.3, 0.6, 1],
      ).createShader(bounds),
  );
}

/// Scenario 1's bench: torch, light beam, comb, mounted mirror and the five
/// reflected rays (the source's `renderS1Rays`).
class _BeamPainter extends CustomPainter {
  const _BeamPainter({required this.combPlaced, required this.mirror});

  final bool combPlaced;
  final _Item? mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final blur = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = _kYellow300.withValues(alpha: 0.15);
    const lensX = 165.0;
    if (!combPlaced) {
      // The torch's wide beam.
      canvas.drawPath(
        Path()
          ..moveTo(lensX, 185)
          ..lineTo(lensX, 265)
          ..lineTo(900, 325)
          ..lineTo(900, 125)
          ..close(),
        blur,
      );
    } else {
      // Wide beam up to the comb, then five thin rays through its gaps.
      canvas.drawPath(
        Path()
          ..moveTo(lensX, 185)
          ..lineTo(lensX, 265)
          ..lineTo(_kCombRect.left, 270)
          ..lineTo(_kCombRect.left, 180)
          ..close(),
        blur,
      );
      final mirror = this.mirror;
      if (mirror != null) _drawStand(canvas);
      for (final offset in _kBeamOffsets) {
        final y = _kBeamAxis + offset;
        final start = Offset(_kCombRect.right, y);
        final path = Path()..moveTo(start.dx, start.dy);
        if (mirror == null) {
          path.lineTo(size.width, y);
        } else {
          final hit = Offset(_mirrorX(mirror, y), y);
          final end = _reflectedEnd(mirror, hit);
          path
            ..lineTo(hit.dx, hit.dy)
            ..lineTo(end.dx, end.dy);
        }
        _drawRay(canvas, path);
      }
      if (mirror != null) {
        _drawMirror(
          canvas,
          (y) => _mirrorX(mirror, y),
          _kMirrorTop,
          _kMirrorBottom,
        );
        if (mirror == _Item.concave) _drawFocus(canvas, _kConcaveFocus);
      }
    }
    _drawTorch(canvas);
    if (combPlaced) _drawComb(canvas);
  }

  /// The `.obj-3d-mirror-stand`: a post and foot behind the mirror.
  void _drawStand(Canvas canvas) {
    final metal = Paint()
      ..shader = const LinearGradient(
        colors: [_rt_Tw.slate300, _rt_Tw.slate500, _rt_Tw.slate700],
      ).createShader(const Rect.fromLTWH(720, 225, 20, 110));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(722, 228, 16, 100),
        const Radius.circular(3),
      ),
      metal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(690, 324, 80, 10),
        const Radius.circular(4),
      ),
      Paint()..color = _rt_Tw.slate600,
    );
  }

  /// The torch: dark grip with vents, red head with a glowing lens.
  void _drawTorch(Canvas canvas) {
    const r = _kTorchRect;
    final body = RRect.fromRectAndCorners(
      r,
      topLeft: const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      topRight: const Radius.circular(24),
      bottomRight: const Radius.circular(24),
    );
    canvas.drawShadow(Path()..addRRect(body), Colors.black, 10, false);
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_rt_Tw.slate400, _rt_Tw.slate600, _rt_Tw.slate900],
        ).createShader(r),
    );
    final grip = Rect.fromLTWH(r.left, r.top, r.width / 2, r.height);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        grip,
        topLeft: const Radius.circular(16),
        bottomLeft: const Radius.circular(16),
      ),
      Paint()..color = _rt_Tw.slate900,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            grip.left + 6,
            grip.top + 16 + i * 24,
            grip.width - 12,
            9,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.8),
      );
    }
    final head = Rect.fromLTRB(grip.right + 2, r.top, r.right, r.bottom);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        head,
        topRight: const Radius.circular(24),
        bottomRight: const Radius.circular(24),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_rt_Tw.red500, _rt_Tw.red700, _kRed950],
        ).createShader(head),
    );
    final lens = Rect.fromLTWH(
      head.right - 6 - head.width * 0.2,
      head.top + head.height * 0.075,
      head.width * 0.2,
      head.height * 0.85,
    );
    canvas.drawOval(
      lens.inflate(10),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
        ..color = _kYellow300.withValues(alpha: 0.8),
    );
    canvas.drawOval(lens, Paint()..color = _kYellow100);
  }

  /// `.obj-3d-comb`, with its gaps lit where the five rays pass.
  void _drawComb(Canvas canvas) {
    const r = _kCombRect;
    final comb = RRect.fromRectAndRadius(r, const Radius.circular(4));
    canvas.drawShadow(Path()..addRRect(comb), Colors.black, 6, false);
    canvas.drawRRect(
      comb,
      Paint()
        ..shader = const LinearGradient(
          colors: [_rt_Tw.amber400, _rt_Tw.amber600, _kAmber800],
        ).createShader(r),
    );
    // Teeth edges: dark grooves above and below each gap.
    final groove = Paint()..color = Colors.black.withValues(alpha: 0.45);
    for (final offset in _kBeamOffsets) {
      final y = _kBeamAxis + offset;
      canvas.drawRect(Rect.fromLTRB(r.left, y - 4, r.right, y + 4), groove);
      canvas.drawRect(
        Rect.fromLTRB(r.left, y - 1.5, r.right, y + 1.5),
        Paint()..color = _kYellow300.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_BeamPainter old) =>
      old.combPlaced != combPlaced || old.mirror != mirror;
}

/// Scenario 2's sky: the sun, the concave mirror, the reflected rays and F.
class _SunPainter extends CustomPainter {
  const _SunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final axis = _kSunFocus.dy;
    for (final offset in _kSunOffsets) {
      final y = axis + offset;
      final hit = Offset(_sunMirrorX(y), y);
      // Through F and on to the left edge.
      final t = hit.dx / (hit.dx - _kSunFocus.dx);
      final end = hit + (_kSunFocus - hit) * t;
      _drawRay(
        canvas,
        Path()
          ..moveTo(-20, y)
          ..lineTo(hit.dx, hit.dy)
          ..lineTo(end.dx, end.dy),
        opacity: 0.8,
      );
    }
    _drawMirror(
      canvas,
      _sunMirrorX,
      axis - 175,
      axis + 175,
      width: 12,
      colors: const [_kBlue300, Colors.white, _kBlue300, _rt_Tw.slate500],
    );
    _drawFocus(canvas, _kSunFocus);

    // `.obj-3d-sun`, half off the left edge.
    final sun = Offset(0, axis);
    canvas.drawCircle(
      sun,
      90,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
        ..color = _rt_Tw.yellow500.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      sun,
      62,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
        ..color = _rt_Tw.yellow400.withValues(alpha: 0.9),
    );
    final disc = Rect.fromCircle(center: sun, radius: 50);
    canvas.drawCircle(
      sun,
      50,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Colors.white, _kYellow200, _rt_Tw.yellow500, _kYellow700],
          stops: [0, 0.2, 0.6, 1],
        ).createShader(disc),
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
