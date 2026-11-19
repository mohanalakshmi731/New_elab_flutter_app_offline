// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 11.4: Lunar, Solar Calendars and Festivals
// Converted from
// Cl8S-Ch11-A1-Lunar_Solar_Calendars_and_Festivals_Simulation_Strategy.html
// ("Calendar Cycles and Festival Timekeeper"; Tailwind DOM + SVG rings +
// GSAP + canvas-confetti -> Flutter widgets + CustomPainters; drag-and-drop
// via Draggable / DragTarget plus tap-to-place).
//
// A setup board, then two scenarios chosen from the sidebar.
// 1: Calendar Simulator -- run one year (solar ring 365 days, lunar ring 354:
// an 11-day gap) and three years (a 33-day gap), drop in an Adhika Maasa to
// close it, then compare the Indian National (Saka) calendar's normal and
// leap years. 2: Festival Sky Cycle Mapper -- match Diwali, Holi, Makar
// Sankranti and Baisakhi to their sky cues, then advance the year to watch
// the lunar festivals move on the Gregorian calendar while the solar ones
// stay put. Current-task HUD, toasts, labels / pan / zoom tools, every source
// string (EN/HI; the source's TE block is dropped like every other page) and
// confetti are ported. Fixes: the rings show the gap (the source's dash
// length made both rings always draw full); Baisakhi's marker reads
// "Seasonal Change (Harvest)" (it falls about three weeks after the
// equinox); the sidebar steps no longer jump ahead; selecting a festival
// card finishes the "select and inspect" step; scenario 1's summary has a
// Next Scenario button.

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
// Copied from the source's `i18n` block (EN + HI; TE dropped), including the
// toast texts the source hard-coded per language. Keys marked "added" had no
// translation in the source.
final _tx = _rt_Tx({
  'en': {
    'title': 'Calendar Cycles and Festival Timekeeper',
    'subtitle': 'Class 8: KEEPING TIME WITH THE SKIES',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Solar • Lunar • Adhika Maasa • Festivals',
    'tabGuide': 'Lab Guide',
    'missionTitle': 'Mission Objective',
    'missionDesc':
        'Compare lunar, solar, and luni-solar timekeeping, and connect festivals with Moon phases, seasons, and calendar alignment.',
    'begin': 'Begin',
    'selectScenario': 'Select Scenario',
    'explorationSteps': 'Exploration Steps',
    'step': 'Step',
    'focus': 'Focus',
    'action': 'Action',
    'observation': 'Observation',
    'currentTask': 'Current Task',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'tapHint': 'Drag a card, or tap it and then tap where it goes.',
    'run1': 'Run One Year',
    'run3': 'Run Three Years',
    'solar': 'Solar',
    'lunar': 'Lunar',
    'gap': 'Gap',
    'adhika': 'Adhika Maasa (Extra Month)',
    'dropAdhika': 'Drop Adhika Maasa Here',
    'adhikaAdded': 'Adhika Maasa Added!',
    'saka': 'Indian National Calendar (Saka)',
    'yearType': 'Year Type:',
    'normalYear': 'Normal Year',
    'leapYear': 'Leap Year',
    'gregStart': 'Gregorian Start',
    'mar22': '22 March',
    'mar21': '21 March',
    'sakaMonth': 'Saka Month',
    'chaitra1': 'Chaitra 1',
    'chaitraDays': 'Days in Chaitra',
    'days30': '30 Days',
    'days31': '31 Days',
    'completeScenario': 'Complete Scenario',
    'festivals': {
      'diwali': 'Diwali (New Moon)',
      'holi': 'Holi (Full Moon)',
      'makar': 'Makar Sankranti (Solar)',
      'baisakhi': 'Baisakhi (Season/Harvest)',
    },
    'cues': {
      'fullMoon': 'Full Moon',
      'newMoon': 'New Moon',
      'solar': 'Solar Date (Fixed)',
      // The source said "(Equinox)": Baisakhi is about three weeks after it.
      'season': 'Seasonal Change (Harvest)',
    },
    'advanceYear': 'Advance Year',
    'yearHint':
        'Notice how Lunar-linked festivals shift their Gregorian dates!',
    'finishLab': 'Finish Lab',
    'obsSc1':
        'The Indian National Calendar links lunar months with the solar year using leap mechanisms.',
    'obsSc1Sub': 'Scenario 1 complete. Please select next scenario.',
    'nextScenario': 'Next Scenario',
    'obsSc2':
        'Lunar-linked festivals shift dates on the Gregorian calendar, while solar festivals remain fixed.',
    'obsSc2Sub': 'You have successfully completed the laboratory.',
    'resetLab': 'Reset Entire Lab',
    'toastYear1':
        'Solar year completed 365 days. Lunar year completed 354 days.',
    'toastYear3': '3 years passed. Gap has grown to 33 days (approx 1 month).',
    'toastAdhika': 'Adhika Maasa (Intercalary Month) added!',
    'toastCorrect': 'Correct match!',
    'toastWrong': 'Incorrect match. Please try again.',
    'months': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
    'scenarios': {
      '1': {
        'title': 'Scenario 1: Calendar Simulator',
        'steps': [
          {
            'concept': 'Solar vs Lunar year difference',
            'action':
                "CLICK 'Run One Year' to animate a 365-day solar ring and a 354-day lunar ring.",
            'observation':
                'The lunar ring ends about 11 days before the solar ring.',
          },
          {
            'concept': 'Accumulated gap over 3 years',
            'action':
                "CLICK 'Run Three Years' and measure the accumulated lunar-solar gap.",
            'observation': 'The gap grows to about 33 days.',
          },
          {
            'concept': 'Intercalary month (Adhika Maasa)',
            'action': "DRAG the 'Adhika Maasa' block into the dropzone.",
            'observation':
                'The lunar timeline realigns closer to the solar year.',
          },
          {
            'concept': 'Indian National Calendar alignment',
            'action':
                'BUILD a normal-year and leap-year Indian National Calendar alignment.',
            'observation':
                'Chaitra starts on 22 March in a normal year and 21 March in a leap year.',
          },
        ],
      },
      '2': {
        'title': 'Scenario 2: Festival Sky Cycle Mapper',
        'steps': [
          {
            'concept': 'Astronomical Basis of Festivals',
            'action':
                'SELECT a festival card and inspect whether it is linked to a Moon phase, season, or solar date.',
            'observation':
                'Students see that some festivals are related to astronomical phenomena.',
          },
          {
            'concept': 'Mapping Festivals to Sky Cues',
            'action': 'DRAG the festival card onto the correct sky marker.',
            'observation':
                'Students classify festival timing by astronomical cue.',
          },
          {
            'concept': 'Date shifting on Gregorian calendar',
            'action': 'ADVANCE the year slider.',
            'observation':
                'Observe how some lunar-linked festival dates shift on the Gregorian calendar while solar ones remain fixed.',
          },
        ],
      },
    },
  },
  'hi': {
    'title': 'कैलेंडर चक्र और त्योहार टाइमकीपर',
    'subtitle': 'कक्षा 8: आसमान के साथ समय मापना',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'सौर • चंद्र • अधिक मास • त्योहार', // added
    'tabGuide': 'लैब गाइड', // added
    'missionTitle': 'मिशन का उद्देश्य',
    'missionDesc':
        'चंद्र, सौर और चंद्र-सौर समय निर्धारण की तुलना करें, और त्योहारों को चंद्रमा के चरणों, मौसम और कैलेंडर के साथ जोड़ें।',
    'begin': 'शुरू करें',
    'selectScenario': 'परिदृश्य चुनें',
    'explorationSteps': 'खोज के चरण',
    'step': 'चरण', // added
    'focus': 'फोकस', // added
    'action': 'कार्य', // added
    'observation': 'अवलोकन',
    'currentTask': 'वर्तमान कार्य',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
    'tapHint':
        'किसी कार्ड को खींचें, या उस पर टैप करके फिर उसकी सही जगह पर टैप करें।', // added
    'run1': 'एक वर्ष चलाएं',
    'run3': 'तीन वर्ष चलाएं',
    'solar': 'सौर',
    'lunar': 'चंद्र',
    'gap': 'अंतर',
    'adhika': 'अधिक मास (अतिरिक्त माह)',
    'dropAdhika': 'अधिक मास यहाँ छोड़ें',
    'adhikaAdded': 'अधिक मास जोड़ा गया!',
    'saka': 'भारतीय राष्ट्रीय कैलेंडर (शक)',
    'yearType': 'वर्ष का प्रकार:',
    'normalYear': 'सामान्य वर्ष',
    'leapYear': 'लीप वर्ष',
    'gregStart': 'ग्रेगोरियन शुरुआत',
    'mar22': '22 मार्च',
    'mar21': '21 मार्च',
    'sakaMonth': 'शक माह',
    'chaitra1': 'चैत्र 1',
    'chaitraDays': 'चैत्र में दिन',
    'days30': '30 दिन',
    'days31': '31 दिन',
    'completeScenario': 'परिदृश्य पूरा करें',
    'festivals': {
      'diwali': 'दिवाली (अमावस्या)',
      'holi': 'होली (पूर्णिमा)',
      'makar': 'मकर संक्रांति (सौर)',
      'baisakhi': 'बैसाखी (मौसम/फसल)',
    },
    'cues': {
      'fullMoon': 'पूर्णिमा',
      'newMoon': 'अमावस्या',
      'solar': 'सौर तिथि (निश्चित)',
      'season': 'मौसमी परिवर्तन (फसल)', // changed from "(विषुव)"
    },
    'advanceYear': 'वर्ष आगे बढ़ाएं',
    'yearHint':
        'ध्यान दें कि कैसे चंद्र से जुड़े त्योहार अपनी ग्रेगोरियन तिथियों को बदलते हैं!',
    'finishLab': 'लैब समाप्त करें',
    'obsSc1':
        'भारतीय राष्ट्रीय कैलेंडर लीप तंत्र का उपयोग करके चंद्र महीनों को सौर वर्ष से जोड़ता है।',
    'obsSc1Sub': 'परिदृश्य 1 पूरा हुआ। कृपया अगला परिदृश्य चुनें।',
    'nextScenario': 'अगला परिदृश्य',
    'obsSc2':
        'चंद्र-आधारित त्योहार ग्रेगोरियन कैलेंडर पर अपनी तिथियां बदलते हैं, जबकि सौर त्योहार निश्चित रहते हैं।',
    'obsSc2Sub': 'आपने सफलतापूर्वक प्रयोगशाला पूरी कर ली है।',
    'resetLab': 'पूरी लैब रीसेट करें',
    'toastYear1': 'सौर वर्ष 365 दिन पूरे। चंद्र वर्ष 354 दिन पूरे।',
    'toastYear3': '3 साल बीत गए। अंतर 33 दिन हो गया है।',
    'toastAdhika': 'अधिक मास जोड़ा गया!',
    'toastCorrect': 'सही मिलान!',
    'toastWrong': 'गलत मिलान। कृपया पुनः प्रयास करें।',
    'months': [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर',
    ],
    'scenarios': {
      '1': {
        'title': 'परिदृश्य 1: कैलेंडर सिम्युलेटर',
        'steps': [
          {
            'concept': 'सौर बनाम चंद्र वर्ष का अंतर',
            'action':
                "365-दिवसीय सौर रिंग और 354-दिवसीय चंद्र रिंग को एनिमेट करने के लिए 'एक वर्ष चलाएं' पर क्लिक करें।",
            'observation':
                'चंद्र रिंग सौर रिंग से लगभग 11 दिन पहले समाप्त होती है।',
          },
          {
            'concept': '3 वर्षों में संचित अंतर',
            'action':
                "'तीन वर्ष चलाएं' पर क्लिक करें और संचित चंद्र-सौर अंतर को मापें।",
            'observation': 'अंतर बढ़कर लगभग 33 दिन हो जाता है।',
          },
          {
            'concept': 'अधिक मास',
            'action': "ड्रॉपज़ोन में 'अधिक मास' ब्लॉक को खींचें।",
            'observation': 'चंद्र समयरेखा सौर वर्ष के करीब संरेखित होती है।',
          },
          {
            'concept': 'भारतीय राष्ट्रीय कैलेंडर संरेखण',
            'action':
                'एक सामान्य-वर्ष और लीप-वर्ष भारतीय राष्ट्रीय कैलेंडर संरेखण बनाएं।',
            'observation':
                'चैत्र एक सामान्य वर्ष में 22 मार्च को और लीप वर्ष में 21 मार्च को शुरू होता है।',
          },
        ],
      },
      '2': {
        'title': 'परिदृश्य 2: त्योहार स्काई साइकिल मैपर',
        'steps': [
          {
            'concept': 'त्योहारों का खगोलीय आधार',
            'action':
                'एक त्योहार कार्ड चुनें और जांचें कि क्या यह चंद्रमा के चरण, मौसम या सौर तिथि से जुड़ा है।',
            'observation':
                'छात्र देखते हैं कि कुछ त्योहार खगोलीय घटनाओं से संबंधित हैं।',
          },
          {
            'concept': 'त्योहारों को आकाश चिह्नों से मैप करना',
            'action': 'त्योहार कार्ड को सही आकाश मार्कर पर खींचें।',
            'observation':
                'छात्र खगोलीय संकेत द्वारा त्योहार के समय को वर्गीकृत करते हैं।',
          },
          {
            'concept': 'ग्रेगोरियन कैलेंडर पर तिथि बदलना',
            'action': 'वर्ष स्लाइडर को आगे बढ़ाएं।',
            'observation':
                'ध्यान दें कि कुछ चंद्र-आधारित त्योहारों की तिथियां ग्रेगोरियन कैलेंडर पर कैसे बदलती हैं।',
          },
        ],
      },
    },
  },
});

// ------------------------------------------------------------- constants ----

/// Content widths below this get compact cards.
const double _kNarrowWidth = 700;

/// Canvases shorter than this (phone landscape) get a tighter top inset and
/// side-by-side layouts.
const double _kShortHeight = 500;

const double _kMaxContentWidth = 1000;

/// The source's `zoomCam` limits and step.
const double _kZoomMin = 0.5;
const double _kZoomMax = 2;
const double _kZoomStep = 0.1;

/// Day counts.
const int _kSolarYear = 365;
const int _kLunarYear = 354;
const int _kAdhikaDays = 30;

/// The year slider's range (`min="2024" max="2034"`).
const int _kFirstYear = 2024;
const int _kLastYear = 2034;

const Color _kYellow500 = Color(0xFFEAB308);
const Color _kRose600 = Color(0xFFE11D48);
const Color _kFuchsia600 = Color(0xFFC026D3);
const Color _kPurple400 = Color(0xFFC084FC);

/// The source's default `confetti()` palette.
const List<Color> _kConfettiColors = [
  _rt_Tw.blue500,
  _rt_Tw.emerald500,
  _rt_Tw.amber500,
  _rt_Tw.pink500,
  _rt_Tw.violet500,
];

// ------------------------------------------------------------------ model ----

/// A sky cue: one of the festival drop zones.
enum _Cue { fullMoon, newMoon, solar, season }

/// The festival cards (`#fest-*`) with their cue and card colours.
enum _Festival {
  diwali(_Cue.newMoon, _rt_Tw.indigo500, _rt_Tw.indigo700),
  holi(_Cue.fullMoon, _rt_Tw.pink500, _kRose600),
  makar(_Cue.solar, _rt_Tw.orange400, _rt_Tw.orange600),
  baisakhi(_Cue.season, _rt_Tw.green500, _rt_Tw.emerald700);

  const _Festival(this.cue, this.light, this.dark);

  final _Cue cue;
  final Color light;
  final Color dark;

  String get label => _tx.s('festivals.$name');

  /// The source's `advanceYear`: lunar-linked festivals move 11 days earlier
  /// each year, jumping 30 days later whenever the drift reaches a month;
  /// solar ones keep their date.
  DateTime dateIn(int year) {
    DateTime lunar(DateTime base) {
      final drift = (year - _kFirstYear) * -11;
      final jumps = drift.abs() ~/ 29;
      final shifted = base.add(Duration(days: drift + jumps * 30));
      return DateTime.utc(year, shifted.month, shifted.day);
    }

    return switch (this) {
      _Festival.diwali => lunar(DateTime.utc(_kFirstYear, 10, 31)),
      _Festival.holi => lunar(DateTime.utc(_kFirstYear, 3, 25)),
      _Festival.makar => DateTime.utc(year, 1, 14),
      _Festival.baisakhi => DateTime.utc(year, 4, 13),
    };
  }

  /// "Oct 31, 2024" with the month in the current language.
  String dateLabel(int year) {
    final date = dateIn(year);
    return '${_tx.s('months.${date.month - 1}')} ${date.day}, $year';
  }
}

// ------------------------------------------------------------------- page ----

class Cl8Ch11A4LunarSolarCalendarsFestivalsPage extends StatefulWidget {
  const Cl8Ch11A4LunarSolarCalendarsFestivalsPage({super.key});

  @override
  State<Cl8Ch11A4LunarSolarCalendarsFestivalsPage> createState() =>
      _Cl8Ch11A4LunarSolarCalendarsFestivalsPageState();
}

class _Cl8Ch11A4LunarSolarCalendarsFestivalsPageState
    extends State<Cl8Ch11A4LunarSolarCalendarsFestivalsPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _random = math.Random();
  final ScrollController _workspaceScroll = ScrollController();

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  OverlayEntry? _confettiEntry;

  /// The rings' 2 s count-up (GSAP `power2.out`).
  late final AnimationController _rings = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
    value: 1,
  );

  final List<Timer> _timers = [];

  // Shared. The setup board shows until Begin (or a scenario is picked).
  bool _boardOpen = true;
  int _scenario = 1;
  int _step = 1;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  double _zoom = 1;
  Offset _pan = Offset.zero;

  // Scenario 1 (source `cumulativeGap` + the ring / Saka DOM).
  double _solarFrom = 0;
  double _solarTo = 0;
  double _lunarFrom = 0;
  double _lunarTo = 0;

  /// Days that make one full turn of the rings: one year, then three.
  double _ringScale = _kSolarYear.toDouble();
  int _gap = 0;
  bool _ranOneYear = false;
  bool _ranThreeYears = false;
  bool _adhikaSelected = false;
  bool _adhikaAdded = false;
  bool _adhikaFlash = false;
  bool _leapYear = false;

  // Scenario 2.
  final Set<_Festival> _placed = {};
  _Festival? _selected;
  _Cue? _flashCue;
  _Festival? _shakeCard;
  int _shakeSerial = 0;
  int _year = _kFirstYear;
  bool _finishQueued = false;

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
    _confettiEntry?.remove();
    _confettiEntry = null;
    _confetti.dispose();
    _rings.dispose();
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
  int get _stepCount => _scenario == 1 ? 4 : 3;

  void _scrollToTop() {
    if (_workspaceScroll.hasClients) _workspaceScroll.jumpTo(0);
  }

  void _toast(String key, {bool success = false, bool error = false}) {
    _shell.showToast(
      _tx.s(key),
      color: error
          ? _rt_Tw.red500
          : (success ? _rt_Tw.green600 : _rt_Tw.blue500),
      icon: error
          ? Icons.warning_amber_rounded
          : (success ? Icons.check_circle : Icons.info),
    );
  }

  /// The source's `resetSc1` and `resetSc2` (state only; call inside
  /// `setState`).
  void _resetScenarios() {
    _solarFrom = _solarTo = _lunarFrom = _lunarTo = 0;
    _ringScale = _kSolarYear.toDouble();
    _rings.value = 1;
    _gap = 0;
    _ranOneYear = false;
    _ranThreeYears = false;
    _adhikaSelected = false;
    _adhikaAdded = false;
    _adhikaFlash = false;
    _leapYear = false;
    _placed.clear();
    _selected = null;
    _flashCue = null;
    _shakeCard = null;
    _year = _kFirstYear;
    _finishQueued = false;
  }

  /// The source's `changeScenario`: hides the board and starts the scenario
  /// afresh at step 1.
  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() {
      _boardOpen = false;
      _scenario = scenario;
      _step = 1;
      _toggledTiles.clear();
      _resetScenarios();
      _zoom = 1;
      _pan = Offset.zero;
    });
    _scrollToTop();
  }

  /// The source's `fullReset` (minus the shutter, which the shell owns): back
  /// to the setup board.
  void _restart() {
    _cancelTimers();
    setState(() {
      _boardOpen = true;
      _scenario = 1;
      _step = 1;
      _toggledTiles.clear();
      _resetScenarios();
      _showLabels = true;
      _panMode = false;
      _zoom = 1;
      _pan = Offset.zero;
    });
    _scrollToTop();
  }

  /// The source's `startActivity`.
  void _begin() {
    _rt_playSfx(_rt_Sfx.scenario);
    _changeScenario(1);
  }

  /// The source's `activateStep` (driven by progress only: the sidebar cards
  /// no longer jump ahead).
  void _goToStep(int step) {
    setState(() {
      _step = step;
      _toggledTiles.clear();
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

  /// The source's `zoomCam` (the whole scene scales).
  void _zoomBy(double delta) =>
      setState(() => _zoom = (_zoom + delta).clamp(_kZoomMin, _kZoomMax));

  void _resetView() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

  // --------------------------------------------------------------- dialogs --
  /// The source's completion modal ("Observation"), with Next Scenario after
  /// scenario 1 (the source's had only ✕) and Reset Entire Lab after 2.
  void _showObservation() {
    final last = _scenario == 2;
    _shell.showSuccess(
      title: _tx.s('observation'),
      icon: Icons.school,
      color: _rt_Tw.blue600,
      buttonLabel: _tx.s(last ? 'resetLab' : 'nextScenario'),
      body: _SummaryBody(
        text: _tx.s(last ? 'obsSc2' : 'obsSc1'),
        subtext: _tx.s(last ? 'obsSc2Sub' : 'obsSc1Sub'),
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
  }

  void _launchConfetti({int count = 100}) {
    _confettiEntry?.remove();
    final pieces = List.generate(count, (_) => _ConfettiPiece.random(_random));
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
  double get _ringProgress => Curves.easeOutQuad.transform(_rings.value);

  double get _solarShown =>
      _solarFrom + (_solarTo - _solarFrom) * _ringProgress;

  double get _lunarShown =>
      _lunarFrom + (_lunarTo - _lunarFrom) * _ringProgress;

  /// The source's `updateRings`: count both rings up to the new totals.
  void _animateRings(double solar, double lunar, {required int gap}) {
    _solarFrom = _solarShown;
    _lunarFrom = _lunarShown;
    _solarTo = solar;
    _lunarTo = lunar;
    _gap = gap;
    _rings.forward(from: 0);
  }

  /// The source's `runOneYear` (it can be replayed during step 2).
  void _runOneYear() {
    if (_scenario != 1 || _step > 2 || _ranThreeYears) return;
    _rt_playSfx(_rt_Sfx.magic);
    final first = !_ranOneYear;
    setState(() {
      _ranOneYear = true;
      _ringScale = _kSolarYear.toDouble();
      _solarFrom = _lunarFrom = 0;
      _rings.value = 0;
      _animateRings(
        _kSolarYear.toDouble(),
        _kLunarYear.toDouble(),
        gap: _kSolarYear - _kLunarYear,
      );
    });
    _toast('toastYear1');
    if (first) _after(2500, () => _goToStep(2));
  }

  /// The source's `runThreeYears`.
  void _runThreeYears() {
    if (_scenario != 1 || _step != 2 || _ranThreeYears) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _ranThreeYears = true;
      _ringScale = 3.0 * _kSolarYear;
      _animateRings(
        3.0 * _kSolarYear,
        3.0 * _kLunarYear,
        gap: 3 * (_kSolarYear - _kLunarYear),
      );
    });
    _toast('toastYear3');
    _after(2500, () => _goToStep(3));
  }

  void _selectAdhika() {
    if (_adhikaAdded) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _adhikaSelected = !_adhikaSelected);
  }

  void _tapAdhikaZone() {
    if (_adhikaSelected) _dropAdhika();
  }

  /// The source's `dropAdhika`: one extra lunar month closes most of the gap.
  void _dropAdhika() {
    if (_scenario != 1 || _step != 3 || _adhikaAdded || _gap <= 20) return;
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _adhikaAdded = true;
      _adhikaSelected = false;
      _adhikaFlash = true;
      _animateRings(
        _solarTo,
        _lunarTo + _kAdhikaDays,
        gap: math.max(0, _gap - _kAdhikaDays),
      );
    });
    _toast('toastAdhika', success: true);
    // 2.5 s (the source's 2 s ended with the 2 s count-up, so the settled
    // ring vanished the moment it arrived).
    _after(2500, () {
      setState(() => _adhikaFlash = false);
      _goToStep(4);
    });
  }

  void _setLeapYear(bool leap) {
    if (_leapYear == leap) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _leapYear = leap);
  }

  /// The source's `completeScenario1`.
  void _completeScenario1() {
    if (_scenario != 1 || _step != 4) return;
    _rt_playSfx(_rt_Sfx.success);
    _launchConfetti();
    _after(1000, () {
      if (_scenario == 1) _showObservation();
    });
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// Selecting (or picking up) a card is the "inspect" of step 1.
  void _inspectCard() {
    if (_scenario == 2 && _step == 1) _goToStep(2);
  }

  void _selectCard(_Festival festival) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selected = _selected == festival ? null : festival);
    _inspectCard();
  }

  void _tapZone(_Cue cue) {
    final festival = _selected;
    if (festival == null) return;
    setState(() => _selected = null);
    _dropFestival(festival, cue);
  }

  /// The source's `dropFest`.
  void _dropFestival(_Festival festival, _Cue cue) {
    if (_scenario != 2 || _step > 2 || _placed.contains(festival)) return;
    if (festival.cue != cue) {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() {
        _flashCue = cue;
        _shakeCard = festival;
        _shakeSerial++;
      });
      _after(700, () {
        if (_flashCue == cue) setState(() => _flashCue = null);
      });
      _toast('toastWrong', error: true);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _placed.add(festival));
    _inspectCard();
    _toast('toastCorrect', success: true);
    if (_placed.length == _Festival.values.length) {
      _after(1000, () {
        if (_scenario == 2) _goToStep(3);
      });
    }
  }

  /// The source's `advanceYear`. Reaching the last year finishes the lab
  /// 1.5 s later (once).
  void _setYear(double value) {
    final year = value.round();
    if (year == _year) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _year = year);
    if (year == _kLastYear && !_finishQueued) {
      _finishQueued = true;
      _after(1500, _finishLab);
    }
  }

  /// The source's `finishLab`.
  void _finishLab() {
    if (_scenario != 2 || _step != 3) return;
    _rt_playSfx(_rt_Sfx.success);
    _launchConfetti(count: 200);
    _after(1000, () {
      if (_scenario == 2) _showObservation();
    });
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
            icon: Icons.calendar_month,
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
            if (!_boardOpen)
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
  /// The source's `#teacher-board`.
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionTitle'),
          desc: _tx.s('missionDesc'),
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
                  state: !_boardOpen && _scenario == scenario
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: !_boardOpen && _scenario == scenario
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
              _tx.s('scenarios.$_scenario.steps.${_step - 1}.action'),
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

  // -------------------------------------------------------------- workspace --
  /// The source's `#zoom-wrapper`: the setup board, then the scenario,
  /// zoomed and panned as a whole.
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
              // The source's `fade-in`: fade while rising 10 px.
              child: TweenAnimationBuilder<double>(
                key: ValueKey('view-$_scenario-$_step'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - t)),
                    child: child,
                  ),
                ),
                child: _scenario == 1
                    ? _calendarView(width, narrow: narrow, short: short)
                    : _festivalView(width, narrow: narrow),
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
            padding: EdgeInsets.fromLTRB(12, topInset, 60, 32),
            child: content,
          ),
        );
      },
    );
  }

  /// The source's `#ui-setup-board`.
  Widget _setupBoard({required bool short}) {
    return TweenAnimationBuilder<double>(
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_rt_Tw.slate900, _rt_Tw.slate800],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _rt_Tw.blue600.withValues(alpha: 0.5),
              width: 4,
            ),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.track_changes,
                size: short ? 40 : 56,
                color: _rt_Tw.blue500,
              ),
              SizedBox(height: short ? 8 : 14),
              Text(
                _tx.s('missionTitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 18 : 24,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                ),
              ),
              SizedBox(height: short ? 8 : 12),
              Text(
                _tx.s('missionDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 12.5 : 15,
                  fontWeight: FontWeight.w600,
                  color: _rt_Lab.onTinted(_rt_Tw.blue100, _rt_Tw.slate600),
                  height: 1.45,
                ),
              ),
              SizedBox(height: short ? 14 : 24),
              _ChunkyButton(
                key: const ValueKey('board-btn'),
                label: _tx.s('begin'),
                color: _rt_Tw.blue600,
                borderColor: _rt_Tw.blue800,
                onPressed: _begin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fades `.label-text` elements with the labels tool.
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

  /// The blue "tap or drag" strip.
  Widget _hintBox() {
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
              _tx.s('tapHint'),
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
  /// `#ui-sc1`: run buttons and rings (steps 1–2), rings and the Adhika
  /// Maasa drop (step 3), the Saka calendar (step 4).
  Widget _calendarView(
    double width, {
    required bool narrow,
    required bool short,
  }) {
    final ringSize = short ? 190.0 : 300.0;
    switch (_step) {
      case 1:
      case 2:
        return Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChunkyButton(
                  key: const ValueKey('btn-run1'),
                  label: _tx.s('run1'),
                  icon: Icons.play_arrow,
                  color: _rt_Tw.blue600,
                  borderColor: _rt_Tw.blue800,
                  onPressed: _ranThreeYears ? null : _runOneYear,
                ),
                if (_step == 2)
                  _ChunkyButton(
                    key: const ValueKey('btn-run3'),
                    label: _tx.s('run3'),
                    icon: Icons.fast_forward,
                    color: _rt_Tw.indigo600,
                    borderColor: _rt_Tw.indigo900,
                    onPressed: _ranThreeYears ? null : _runThreeYears,
                  ),
              ],
            ),
            SizedBox(height: short ? 12 : 28),
            _ringsBox(ringSize),
          ],
        );
      case 3:
        final adhika = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_adhikaAdded) _adhikaBlock(),
            if (!_adhikaAdded) const SizedBox(height: 12),
            _adhikaZone(width: short ? 220 : 256),
          ],
        );
        if (short) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ringsBox(170),
              const SizedBox(width: 20),
              Flexible(child: adhika),
            ],
          );
        }
        return Column(
          children: [_ringsBox(ringSize), const SizedBox(height: 24), adhika],
        );
      default:
        return _sakaPanel(narrow: narrow);
    }
  }

  /// `#sc1-rings-container`: the two rings and their day counts.
  Widget _ringsBox(double size) {
    return Container(
      key: const ValueKey('rings'),
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.05),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _rt_Tw.slate900,
        border: Border.all(color: _rt_Tw.slate700),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 30)],
      ),
      child: AnimatedBuilder(
        animation: _rings,
        builder: (context, _) {
          final solar = _solarShown;
          final lunar = _lunarShown;
          final font = size < 220 ? 11.5 : 15.0;
          return CustomPaint(
            painter: _RingsPainter(
              solar: solar / _ringScale,
              lunar: lunar / _ringScale,
            ),
            child: Center(
              child: _label(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_tx.s('solar')}: ${solar.round()}d',
                      key: const ValueKey('solar-days'),
                      style: TextStyle(
                        fontSize: font,
                        fontWeight: FontWeight.w900,
                        color: _kYellow500,
                      ),
                    ),
                    Text(
                      '${_tx.s('lunar')}: ${lunar.round()}d',
                      key: const ValueKey('lunar-days'),
                      style: TextStyle(
                        fontSize: font,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: size < 220 ? 4 : 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Tw.red500.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _rt_Tw.red500.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '${_tx.s('gap')}: ${_gap}d',
                        key: const ValueKey('gap-days'),
                        style: TextStyle(
                          fontSize: font,
                          fontWeight: FontWeight.w900,
                          color: _rt_Tw.red400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The purple "Adhika Maasa (Extra Month)" block.
  Widget _adhikaBlock() {
    final face = _AdhikaFace(selected: _adhikaSelected);
    return Draggable<String>(
      data: 'adhika',
      onDragStarted: () {
        _rt_playSfx(_rt_Sfx.pop);
        setState(() => _adhikaSelected = false);
      },
      feedback: const Material(
        type: MaterialType.transparency,
        child: _AdhikaFace(selected: false, lifted: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: face),
      child: GestureDetector(
        key: const ValueKey('adhika-block'),
        onTap: _selectAdhika,
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
      ),
    );
  }

  /// `#adhika-drop`.
  Widget _adhikaZone({required double width}) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !_adhikaAdded,
      onAcceptWithDetails: (_) => _dropAdhika(),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty || _adhikaSelected;
        return GestureDetector(
          key: const ValueKey('adhika-zone'),
          behavior: HitTestBehavior.opaque,
          onTap: _tapAdhikaZone,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: width,
            height: 60,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _adhikaAdded
                  ? _rt_Tw.purple500.withValues(
                      alpha: _adhikaFlash ? 0.3 : 0.15,
                    )
                  : (hovering
                        ? _rt_Tw.purple500.withValues(alpha: 0.12)
                        : _rt_Tw.slate800.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _adhikaAdded || hovering
                    ? _rt_Tw.purple500
                    : _rt_Tw.slate500,
                width: 2,
              ),
            ),
            child: Text(
              _tx.s(_adhikaAdded ? 'adhikaAdded' : 'dropAdhika'),
              key: const ValueKey('adhika-zone-text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _adhikaAdded ? 15 : 12.5,
                fontWeight: _adhikaAdded ? FontWeight.w900 : FontWeight.w600,
                color: _adhikaAdded ? _kPurple400 : _rt_Tw.slate400,
              ),
            ),
          ),
        );
      },
    );
  }

  /// `#sc1-saka`: the Indian National Calendar for a normal or leap year.
  Widget _sakaPanel({required bool narrow}) {
    Widget stat(String label, String value, Color color, {Key? key}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: narrow ? 9 : 10.5,
                  fontWeight: FontWeight.w800,
                  color: _rt_Tw.slate500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                key: key,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: narrow ? 14 : 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final divider = Container(width: 1, height: 44, color: _rt_Tw.slate700);
    return Center(
      child: Container(
        key: const ValueKey('saka-panel'),
        constraints: const BoxConstraints(maxWidth: 672),
        padding: EdgeInsets.all(narrow ? 12 : 20),
        decoration: BoxDecoration(
          color: _rt_Tw.slate800.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _rt_Tw.slate700),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag, size: 20, color: _rt_Tw.blue500),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _tx.s('saka'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: narrow ? 14 : 17,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: narrow ? 10 : 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  _tx.s('yearType'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.slate300,
                  ),
                ),
                _YearTypeChip(
                  key: const ValueKey('year-normal'),
                  label: _tx.s('normalYear'),
                  selected: !_leapYear,
                  onTap: () => _setLeapYear(false),
                ),
                _YearTypeChip(
                  key: const ValueKey('year-leap'),
                  label: _tx.s('leapYear'),
                  selected: _leapYear,
                  onTap: () => _setLeapYear(true),
                ),
              ],
            ),
            SizedBox(height: narrow ? 10 : 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _rt_Tw.slate900,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _rt_Tw.slate700),
              ),
              child: Row(
                children: [
                  stat(
                    _tx.s('gregStart'),
                    _tx.s(_leapYear ? 'mar21' : 'mar22'),
                    _rt_Tw.blue400,
                    key: const ValueKey('greg-start'),
                  ),
                  divider,
                  stat(_tx.s('sakaMonth'), _tx.s('chaitra1'), _rt_Tw.orange400),
                  divider,
                  stat(
                    _tx.s('chaitraDays'),
                    _tx.s(_leapYear ? 'days31' : 'days30'),
                    _rt_Tw.green400,
                    key: const ValueKey('chaitra-days'),
                  ),
                ],
              ),
            ),
            SizedBox(height: narrow ? 12 : 16),
            _ChunkyButton(
              key: const ValueKey('btn-complete'),
              label: _tx.s('completeScenario'),
              icon: Icons.arrow_forward,
              color: _rt_Tw.green500,
              borderColor: _rt_Tw.green700,
              onPressed: _completeScenario1,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------- scenario 2 UI --
  /// `#ui-sc2`: the card tray and sky markers (steps 1–2), then the year
  /// slider over the markers with their cards (step 3).
  Widget _festivalView(double width, {required bool narrow}) {
    final zones = _zonesGrid(width);
    if (_step < 3) {
      return Column(
        children: [
          _hintBox(),
          const SizedBox(height: 10),
          Wrap(
            key: const ValueKey('tray'),
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              for (final festival in _Festival.values)
                if (!_placed.contains(festival))
                  _festivalCard(festival, compact: narrow),
            ],
          ),
          const SizedBox(height: 14),
          zones,
        ],
      );
    }
    return Column(
      children: [
        _yearSlider(),
        const SizedBox(height: 14),
        zones,
        const SizedBox(height: 16),
        _ChunkyButton(
          key: const ValueKey('btn-finish'),
          label: _tx.s('finishLab'),
          icon: Icons.check_circle,
          color: _rt_Tw.green500,
          borderColor: _rt_Tw.green700,
          onPressed: _finishLab,
        ),
      ],
    );
  }

  Widget _festivalCard(_Festival festival, {required bool compact}) {
    final face = _FestivalFace(
      festival: festival,
      year: _year,
      compact: compact,
      selected: _selected == festival,
    );
    return _Shake(
      serial: _shakeCard == festival ? _shakeSerial : 0,
      child: Draggable<_Festival>(
        data: festival,
        onDragStarted: () {
          _rt_playSfx(_rt_Sfx.pop);
          setState(() => _selected = null);
          _inspectCard();
        },
        feedback: Material(
          type: MaterialType.transparency,
          child: _FestivalFace(
            festival: festival,
            year: _year,
            compact: compact,
            selected: false,
            lifted: true,
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: face),
        child: GestureDetector(
          key: ValueKey('card-${festival.name}'),
          onTap: () => _selectCard(festival),
          child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
        ),
      ),
    );
  }

  /// `#sc2-dropzones`: four across when there is room, else 2 × 2.
  Widget _zonesGrid(double width) {
    final cues = _Cue.values;
    if (width >= 420) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cues.length; i++) ...[
              if (i > 0) SizedBox(width: width < 700 ? 6 : 14),
              Expanded(child: _cueZone(cues[i], compact: width < 700)),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _cueZone(cues[row * 2], compact: true)),
                const SizedBox(width: 8),
                Expanded(child: _cueZone(cues[row * 2 + 1], compact: true)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// One `.dropzone` sky marker with the festivals placed on it.
  Widget _cueZone(_Cue cue, {required bool compact}) {
    return DragTarget<_Festival>(
      onWillAcceptWithDetails: (details) => !_placed.contains(details.data),
      onAcceptWithDetails: (details) => _dropFestival(details.data, cue),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        final armed = _selected != null;
        final flashing = _flashCue == cue;
        return GestureDetector(
          key: ValueKey('zone-${cue.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _tapZone(cue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            constraints: BoxConstraints(minHeight: compact ? 116 : 160),
            padding: EdgeInsets.all(compact ? 6 : 12),
            decoration: BoxDecoration(
              color: flashing
                  ? _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500)
                  : (hovering
                        ? _rt_Tw.blue500.withValues(alpha: 0.2)
                        : _rt_Tw.slate800.withValues(alpha: 0.7)),
              borderRadius: BorderRadius.circular(compact ? 16 : 24),
              border: Border.all(
                color: flashing
                    ? _rt_Tw.red500
                    : (hovering || armed ? _rt_Tw.blue500 : _rt_Tw.slate500),
                width: 2,
              ),
              boxShadow: hovering
                  ? [
                      BoxShadow(
                        color: _rt_Tw.blue500.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                SizedBox.square(
                  dimension: compact ? 30 : 46,
                  child: CustomPaint(painter: _CuePainter(cue)),
                ),
                SizedBox(height: compact ? 3 : 6),
                _label(
                  Text(
                    _tx.s('cues.${cue.name}'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 10 : 13,
                      fontWeight: FontWeight.w900,
                      color: _rt_Tw.slate300,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final festival in _Festival.values)
                      if (festival.cue == cue && _placed.contains(festival))
                        _FestivalFace(
                          key: ValueKey('placed-${festival.name}'),
                          festival: festival,
                          year: _year,
                          compact: true,
                          selected: false,
                          inZone: true,
                        ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// `#sc2-slider`.
  Widget _yearSlider() {
    return Container(
      key: const ValueKey('year-panel'),
      constraints: const BoxConstraints(maxWidth: 448),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: _rt_Tw.slate800.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.slate700),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('advanceYear'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.slate300,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _rt_Tw.blue500,
              thumbColor: _rt_Tw.blue500,
              inactiveTrackColor: _rt_Tw.slate600,
              overlayColor: _rt_Tw.blue500.withValues(alpha: 0.2),
            ),
            child: Slider(
              key: const ValueKey('year-slider'),
              value: _year.toDouble(),
              min: _kFirstYear.toDouble(),
              max: _kLastYear.toDouble(),
              divisions: _kLastYear - _kFirstYear,
              onChanged: _setYear,
            ),
          ),
          Text(
            '$_year',
            key: const ValueKey('year-value'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _rt_Tw.blue500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s('yearHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: _rt_Tw.slate400),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- widgets ----

/// Replays a short horizontal shake whenever [serial] changes.
class _Shake extends StatelessWidget {
  const _Shake({required this.serial, required this.child});

  final int serial;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(serial),
      tween: Tween(begin: serial == 0 ? 1.0 : 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, t, child) => Transform.translate(
        offset: Offset(math.sin(t * math.pi * 4) * 10 * (1 - t), 0),
        child: child,
      ),
      child: child,
    );
  }
}

/// The purple Adhika Maasa block (or its drag feedback).
class _AdhikaFace extends StatelessWidget {
  const _AdhikaFace({required this.selected, this.lifted = false});

  final bool selected;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: selected || lifted ? 1.06 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_rt_Tw.purple600, _kFuchsia600],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : _kPurple400,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (selected ? _rt_Tw.purple500 : Colors.black).withValues(
                alpha: lifted || selected ? 0.5 : 0.3,
              ),
              blurRadius: lifted || selected ? 18 : 8,
              offset: Offset(0, lifted ? 8 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _tx.s('adhika'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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

/// A festival card: its name and its date in the slider's year.
class _FestivalFace extends StatelessWidget {
  const _FestivalFace({
    super.key,
    required this.festival,
    required this.year,
    required this.compact,
    required this.selected,
    this.lifted = false,
    this.inZone = false,
  });

  final _Festival festival;
  final int year;
  final bool compact;
  final bool selected;
  final bool lifted;

  /// Shrunk inside a sky marker (the source's `p-1 text-[8px] scale-90`).
  final bool inZone;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: selected || lifted ? 1.06 : 1,
      child: Container(
        constraints: BoxConstraints(maxWidth: inZone ? 150 : 170),
        padding: EdgeInsets.symmetric(
          horizontal: inZone ? 6 : (compact ? 8 : 12),
          vertical: inZone ? 4 : (compact ? 6 : 9),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [festival.light, festival.dark],
          ),
          borderRadius: BorderRadius.circular(inZone ? 8 : 12),
          border: Border.all(
            color: selected
                ? Colors.white
                : festival.light.withValues(alpha: 0.8),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: lifted ? 0.45 : 0.25),
              blurRadius: lifted || selected ? 16 : 6,
              offset: Offset(0, lifted ? 8 : 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              festival.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: inZone ? 9.5 : (compact ? 11 : 13),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
              ),
            ),
            SizedBox(height: inZone ? 2 : 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                festival.dateLabel(year),
                key: ValueKey('date-${festival.name}'),
                style: TextStyle(
                  fontSize: inZone ? 9 : (compact ? 9.5 : 11),
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

/// Normal / Leap year choice (the source's `#leap-toggle` select).
class _YearTypeChip extends StatelessWidget {
  const _YearTypeChip({
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
      color: selected ? _rt_Tw.blue600 : _rt_Tw.slate700,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : _rt_Tw.slate300,
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

/// The completion modal's body: the observation and its subtext box.
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.text, required this.subtext});

  final String text;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.text,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Text(
            subtext,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _rt_Lab.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- painters ----

/// The solar (outer, yellow) and lunar (inner, grey) rings in the source's
/// 100-unit SVG box. [solar] and [lunar] are fractions of one turn; the part
/// of the lunar track the Moon's count has not reached yet is the gap, drawn
/// red (in the source both rings always rendered full, hiding the gap).
class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.solar, required this.lunar});

  final double solar;
  final double lunar;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 100;
    final centre = size.center(Offset.zero);
    final stroke = 6 * unit;
    final outer = Rect.fromCircle(center: centre, radius: 45 * unit);
    final inner = Rect.fromCircle(center: centre, radius: 35 * unit);
    const start = -math.pi / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = _rt_Tw.slate700;
    canvas.drawOval(outer, track);
    canvas.drawOval(inner, track);

    final solarSweep = 2 * math.pi * solar.clamp(0.0, 1.0);
    final lunarSweep = 2 * math.pi * lunar.clamp(0.0, 1.0);
    void arc(
      Rect rect,
      double from,
      double sweep,
      Color color, {
      bool glow = false,
    }) {
      if (sweep <= 0) return;
      if (glow) {
        canvas.drawArc(
          rect,
          from,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke * 1.6
            ..color = color.withValues(alpha: 0.35)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * unit),
        );
      }
      canvas.drawArc(
        rect,
        from,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..color = color,
      );
    }

    arc(outer, start, solarSweep, _kYellow500, glow: true);
    arc(inner, start, lunarSweep, _rt_Tw.slate300, glow: true);
    // The gap: where the lunar count falls short of the solar one.
    if (solarSweep > lunarSweep) {
      arc(
        inner,
        start + lunarSweep,
        solarSweep - lunarSweep,
        _rt_Tw.red500.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.solar != solar || oldDelegate.lunar != lunar;
}

/// A sky marker's icon: full Moon, new Moon, Sun or leaf.
class _CuePainter extends CustomPainter {
  const _CuePainter(this.cue);

  final _Cue cue;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide * 0.42;
    switch (cue) {
      case _Cue.fullMoon:
        canvas.drawCircle(
          centre,
          radius * 1.15,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.25)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.3),
        );
        canvas.drawCircle(
          centre,
          radius,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: const [Colors.white, _rt_Tw.slate300],
            ).createShader(Rect.fromCircle(center: centre, radius: radius)),
        );
        final crater = Paint()..color = _rt_Tw.slate400.withValues(alpha: 0.6);
        canvas.drawCircle(
          centre + Offset(-radius * 0.3, -radius * 0.2),
          radius * 0.18,
          crater,
        );
        canvas.drawCircle(
          centre + Offset(radius * 0.35, radius * 0.25),
          radius * 0.13,
          crater,
        );
        canvas.drawCircle(
          centre + Offset(-radius * 0.1, radius * 0.45),
          radius * 0.1,
          crater,
        );
      case _Cue.newMoon:
        canvas.drawCircle(centre, radius, Paint()..color = _rt_Tw.slate900);
        canvas.drawCircle(
          centre,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1, radius * 0.08)
            ..color = _rt_Tw.slate500,
        );
      case _Cue.solar:
        final ray = Paint()
          ..color = _rt_Tw.yellow400
          ..strokeWidth = math.max(1.5, radius * 0.14)
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          final direction = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(
            centre + direction * radius * 0.72,
            centre + direction * radius * 1.05,
            ray,
          );
        }
        canvas.drawCircle(centre, radius * 0.52, Paint()..color = _kYellow500);
      case _Cue.season:
        final leaf = Path()
          ..moveTo(centre.dx - radius * 0.8, centre.dy + radius * 0.8)
          ..quadraticBezierTo(
            centre.dx - radius * 0.9,
            centre.dy - radius * 0.9,
            centre.dx + radius * 0.9,
            centre.dy - radius * 0.9,
          )
          ..quadraticBezierTo(
            centre.dx + radius * 0.9,
            centre.dy + radius * 0.7,
            centre.dx - radius * 0.8,
            centre.dy + radius * 0.8,
          )
          ..close();
        canvas.drawPath(leaf, Paint()..color = _rt_Tw.emerald500);
        canvas.drawLine(
          Offset(centre.dx - radius * 0.8, centre.dy + radius * 0.8),
          Offset(centre.dx + radius * 0.5, centre.dy - radius * 0.5),
          Paint()
            ..color = _rt_Tw.emerald700
            ..strokeWidth = math.max(1, radius * 0.08),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _CuePainter oldDelegate) =>
      oldDelegate.cue != cue;
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

/// One burst like `confetti({particleCount, spread, origin: {y: 0.6}})`.
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
