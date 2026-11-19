// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 8.5: Alloys, Metals, Non-metals and Minerals
// Converted from
// Cl8S-Ch8-A2-Alloys_Metals_Nonmetals_and_Minerals_Simulation_Strategy.html
// ("Alloy Forge & Mineral Explorer"; Tailwind DOM + GSAP + canvas-confetti
// -> Flutter widgets + CustomPainters; drag-and-drop via Draggable /
// DragTarget plus tap-to-place).
//
// Two scenarios chosen from the sidebar, each opened by a setup board.
// 1: Alloy Forge & Sorter -- drop iron, chromium, nickel and carbon into the
// forge and melt them into stainless steel, probe the bar at left, centre
// and right (the same composition everywhere: a uniform mixture), then sort
// eight elements into metals and non-metals. 2: Mineral Explorer -- find
// the five glowing mineral grains in a rock, sort seven minerals into native
// elements and compounds, then match calcite, talc and iron ore to cement,
// talcum powder and tools. Every step ends with its key-takeaway summary.
// Observation log, current-task HUD, labels / pan / zoom tools, every source
// string (EN/HI; the source's TE block is dropped like every other page) and
// confetti are ported. Fixes: the probe reads Fe 73.9 % (the source's Fe 74 %
// summed to 100.1 %); a step summary moves on however it is closed (the
// source's ✕ stranded the lab); every drag can also be done by tapping; and
// the unfound grains glow as the task text says.

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
// Copied from the source's `i18n` and `config` blocks (EN + HI; TE dropped).
// Keys marked "added" had no translation in the source. Log rows that the
// source glued together from word fragments are whole templates here, so the
// Hindi reads naturally.
final _tx = _rt_Tx({
  'en': {
    'title': 'Alloy Forge & Mineral Explorer',
    'subtitle':
        'Class 8: Nature of matter, classifying it into elements, compounds, and mixtures',
    'enterLab': 'Enter Laboratory',
    'footnote': 'Alloys • Metals • Non-Metals • Minerals',
    'tabGuide': 'Lab Guide',
    'selectScenario': 'Select Scenario',
    'missionObjective': 'Mission Objective',
    'explorationSteps': 'Exploration Steps',
    'exploration': 'Step',
    'focus': 'Focus',
    'action': 'Action',
    'observation': 'Observation',
    'keyTakeaway': 'Key Takeaway',
    'stepComplete': 'Step Complete!',
    'success': 'Success!',
    'currentTask': 'Current Task',
    'obsLog': 'Observation Log',
    'clear': 'Clear',
    'result': 'Result',
    'noObs': 'No observations yet.',
    'nextStep': 'Next Step',
    'nextScenario': 'Next Scenario',
    'begin': 'Begin',
    'restartLab': 'Restart Lab',
    'toggleLabels': 'Toggle Labels',
    'panMode': 'Pan Mode',
    'tapHint': 'Drag an item, or tap it and then tap where it goes.',
    'alloy': {
      'iron': 'Iron',
      'chromium': 'Chromium',
      'nickel': 'Nickel',
      'carbon': 'Carbon',
    },
    'elements': {
      'gold': 'Gold',
      'silver': 'Silver',
      'magnesium': 'Magnesium',
      'iron': 'Iron',
      'carbon': 'Carbon',
      'sulfur': 'Sulfur',
      'oxygen': 'Oxygen',
      'mercury': 'Mercury (L)',
    },
    'minerals': {
      'gold': 'Gold',
      'silver': 'Silver',
      'copper': 'Copper',
      'sulfur': 'Sulfur',
      'quartz': 'Quartz',
      'calcite': 'Calcite',
      'mica': 'Mica',
    },
    'grains': {
      'quartz': 'Quartz',
      'calcite': 'Calcite',
      'mica': 'Mica',
      'pyroxene': 'Pyroxene',
      'olivine': 'Olivine',
    },
    'matches': {'calcite': 'Calcite', 'talc': 'Talc', 'ironOre': 'Iron Ore'},
    'meltButton': 'MELT INTO ALLOY',
    'forge': 'Forge',
    'addedCount': '{n} / 4 Added',
    'barTitle': 'Test Stainless Steel Bar',
    'barDesc': 'Click different parts of the bar with the probe.',
    'positions': {'left': 'Left', 'center': 'Center', 'right': 'Right'},
    'zones': {
      'metal': 'Metals',
      'nonMetal': 'Non-Metals',
      'native': 'Native Element Minerals',
      'compound': 'Compound Minerals',
      'cement': 'Cement',
      'talcum': 'Talcum Powder',
      'tools': 'Tools/Wires',
    },
    'nativeDesc': '(Made of only ONE element)',
    'compoundDesc': '(Made of TWO OR MORE elements)',
    'rockTitle': 'Inspect Rock Sample',
    'rockDesc': 'Click on glowing mineral grains to identify them.',
    'notebook': 'Mineral Notebook',
    'matchTitle': 'Minerals in Daily Life',
    'matchDesc': 'Drag minerals to their everyday uses.',
    'hudClickMelt': 'Click MELT INTO ALLOY',
    // Observation log.
    'logAdded': 'Added {item}',
    'logDroppedFurnace': 'Dropped in furnace',
    'logStartMelt': 'Started melting',
    'logComponentsMixing': 'Components mixing',
    'logProbed': 'Probed {pos} of bar',
    'logComposition': 'Composition: Fe, Cr, Ni, C',
    'logSorted': 'Sorted {item}',
    'logCorrect': 'Correct',
    'logIncorrectCategory': 'Incorrect Category',
    'logInspectedGrain': 'Inspected grain',
    'logFound': 'Found {item}',
    'logMatched': 'Matched {item}',
    'logCorrectUse': 'Correct use',
    'logIncorrectUse': 'Incorrect use',
    'scenarios': {
      '1': {
        'title': 'Scenario 1: Alloy Forge & Sorter',
        'objective':
            'Create an alloy and compare metals with non-metals using observable properties.',
        'steps': [
          {
            'concept': 'Alloy Formation',
            'action':
                'Drag iron, chromium, nickel, and carbon into the furnace.',
            'observation':
                'The components melt, mix uniformly, and solidify into stainless steel.',
          },
          {
            'concept': 'Uniform Mixing',
            'action': 'Test the alloy bar at left, centre, and right.',
            'observation':
                'Each region shows similar composition, proving an alloy is a uniform mixture.',
          },
          {
            'concept': 'Classification',
            'action': 'Sort elements into metals and non-metals.',
            'observation':
                'Metals generally have lustre and conduct electricity. Non-metals differ.',
          },
        ],
      },
      '2': {
        'title': 'Scenario 2: Mineral Explorer',
        'objective':
            'Identify common minerals and connect them to rocks and everyday materials.',
        'steps': [
          {
            'concept': 'Rock Composition',
            'action': 'Inspect rock sample using magnifying lens.',
            'observation':
                'Rocks are naturally occurring mixtures of different minerals.',
          },
          {
            'concept': 'Mineral Types',
            'action': 'Sort minerals into native or compound.',
            'observation':
                'Some minerals are pure elements (Native), while most are chemical compounds.',
          },
          {
            'concept': 'Daily Uses',
            'action': 'Match minerals to everyday uses.',
            'observation':
                'Minerals are essential raw materials for cement, powders, tools, and construction.',
          },
        ],
      },
    },
  },
  'hi': {
    'title': 'मिश्र धातु और खनिज',
    'subtitle':
        'कक्षा 8: पदार्थ की प्रकृति, इसे तत्वों, यौगिकों और मिश्रणों में वर्गीकृत करना',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'footnote': 'मिश्र धातु • धातु • अधातु • खनिज', // added
    'tabGuide': 'लैब गाइड', // added
    'selectScenario': 'परिदृश्य चुनें',
    'missionObjective': 'मिशन का उद्देश्य',
    'explorationSteps': 'खोज के चरण',
    'exploration': 'चरण',
    'focus': 'ध्यान',
    'action': 'कार्य',
    'observation': 'अवलोकन',
    'keyTakeaway': 'मुख्य सीख',
    'stepComplete': 'चरण पूरा हुआ!',
    'success': 'सफलता!',
    'currentTask': 'वर्तमान कार्य',
    'obsLog': 'अवलोकन लॉग',
    'clear': 'साफ़ करें',
    'result': 'परिणाम',
    'noObs': 'अभी तक कोई अवलोकन नहीं।',
    'nextStep': 'अगला चरण',
    'nextScenario': 'अगला परिदृश्य', // added
    'begin': 'शुरू करें',
    'restartLab': 'प्रयोगशाला पुनः आरंभ करें',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ', // added
    'panMode': 'पैन मोड', // added
    'tapHint':
        'किसी वस्तु को खींचें, या उस पर टैप करके फिर उसकी सही जगह पर टैप करें।', // added
    'alloy': {
      'iron': 'लोहा',
      'chromium': 'क्रोमियम',
      'nickel': 'निकल',
      'carbon': 'कार्बन',
    },
    'elements': {
      'gold': 'सोना',
      'silver': 'चांदी',
      'magnesium': 'मैग्नीशियम',
      'iron': 'लोहा',
      'carbon': 'कार्बन',
      'sulfur': 'सल्फर',
      'oxygen': 'ऑक्सीजन',
      'mercury': 'पारा (L)',
    },
    'minerals': {
      'gold': 'सोना',
      'silver': 'चांदी',
      'copper': 'तांबा',
      'sulfur': 'सल्फर',
      'quartz': 'क्वार्ट्ज',
      'calcite': 'कैल्साइट',
      'mica': 'अभ्रक (Mica)',
    },
    'grains': {
      'quartz': 'क्वार्ट्ज',
      'calcite': 'कैल्साइट',
      'mica': 'अभ्रक (Mica)',
      'pyroxene': 'पायरोक्सिन',
      'olivine': 'ओलिविन',
    },
    'matches': {'calcite': 'कैल्साइट', 'talc': 'टैल्क', 'ironOre': 'लौह अयस्क'},
    'meltButton': 'मिश्र धातु बनाएं',
    'forge': 'भट्ठी (Forge)',
    'addedCount': '{n} / 4 जोड़ा गया',
    'barTitle': 'स्टेनलेस स्टील बार का परीक्षण करें',
    'barDesc': 'जांच के साथ बार के विभिन्न हिस्सों पर क्लिक करें।',
    'positions': {'left': 'बायां', 'center': 'मध्य', 'right': 'दायां'},
    'zones': {
      'metal': 'धातु',
      'nonMetal': 'अधातु',
      'native': 'मूल तत्व खनिज',
      'compound': 'यौगिक खनिज',
      'cement': 'सीमेंट',
      'talcum': 'टैल्कम पाउडर',
      'tools': 'उपकरण/तार',
    },
    'nativeDesc': '(केवल एक तत्व से बना)',
    'compoundDesc': '(दो या अधिक तत्वों से बना)',
    'rockTitle': 'चट्टान के नमूने का निरीक्षण करें',
    'rockDesc': 'खनिज कणों की पहचान करने के लिए उन पर क्लिक करें।',
    'notebook': 'खनिज नोटबुक',
    'matchTitle': 'दैनिक जीवन में खनिज',
    'matchDesc': 'खनिजों को उनके दैनिक उपयोगों तक खींचें।',
    'hudClickMelt': "'मिश्र धातु बनाएं' पर क्लिक करें",
    'logAdded': '{item} जोड़ा गया',
    'logDroppedFurnace': 'भट्टी में डाला गया',
    'logStartMelt': 'पिघलना शुरू हुआ',
    'logComponentsMixing': 'घटक मिल रहे हैं',
    'logProbed': 'बार के {pos} भाग का परीक्षण किया',
    'logComposition': 'संरचना: Fe, Cr, Ni, C',
    'logSorted': '{item} छांटा गया',
    'logCorrect': 'सही',
    'logIncorrectCategory': 'गलत श्रेणी',
    'logInspectedGrain': 'कण का निरीक्षण किया',
    'logFound': '{item} प्राप्त किया',
    'logMatched': '{item} का मिलान किया',
    'logCorrectUse': 'सही उपयोग',
    'logIncorrectUse': 'गलत उपयोग',
    'scenarios': {
      '1': {
        'title': 'परिदृश्य 1: मिश्र धातु फोर्ज और सॉर्टर',
        'objective':
            'मिश्र धातु बनाएं और अवलोकनीय गुणों का उपयोग करके धातुओं और अधातुओं की तुलना करें।',
        'steps': [
          {
            'concept': 'मिश्र धातु निर्माण',
            'action': 'लोहा, क्रोमियम, निकल और कार्बन को भट्टी में खींचें।',
            'observation':
                'घटक पिघलते हैं, समान रूप से मिलते हैं, और स्टेनलेस स्टील में ठोस हो जाते हैं।',
          },
          {
            'concept': 'समान मिश्रण',
            'action': 'बाईं, मध्य और दाईं ओर मिश्र धातु बार का परीक्षण करें।',
            'observation':
                'प्रत्येक क्षेत्र समान संरचना दिखाता है, यह साबित करते हुए कि मिश्र धातु एक समान मिश्रण है।',
          },
          {
            'concept': 'वर्गीकरण',
            'action': 'तत्वों को धातुओं और अधातुओं में छाँटें।',
            'observation':
                'धातुओं में आम तौर पर चमक होती है और वे बिजली का संचालन करती हैं। अधातुएं अलग होती हैं।',
          },
        ],
      },
      '2': {
        'title': 'परिदृश्य 2: खनिज एक्सप्लोरर',
        'objective':
            'सामान्य खनिजों की पहचान करें और उन्हें चट्टानों और रोजमर्रा की सामग्रियों से जोड़ें।',
        'steps': [
          {
            'concept': 'चट्टान संरचना',
            'action':
                'आवर्धक लेंस का उपयोग करके चट्टान के नमूने का निरीक्षण करें।',
            'observation':
                'चट्टानें विभिन्न खनिजों का प्राकृतिक रूप से पाया जाने वाला मिश्रण हैं।',
          },
          {
            'concept': 'खनिज प्रकार',
            'action': 'खनिजों को मूल तत्व या यौगिक में छाँटें।',
            'observation':
                'कुछ खनिज शुद्ध तत्व (मूल) हैं, जबकि अधिकांश रासायनिक यौगिक हैं।',
          },
          {
            'concept': 'दैनिक उपयोग',
            'action': 'खनिजों को उनके दैनिक उपयोगों से मिलाएँ।',
            'observation':
                'खनिज सीमेंट, पाउडर, उपकरण और निर्माण के लिए आवश्यक कच्चे माल हैं।',
          },
        ],
      },
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

/// Content widths below this get compact cards and bins.
const double _kNarrowWidth = 700;

/// Canvases shorter than this (phone landscape) get a tighter top inset and
/// put the furnace beside its button.
const double _kShortHeight = 500;

const double _kMaxContentWidth = 1000;

/// The source's `zoomCam` limits and step.
const double _kZoomMin = 0.5;
const double _kZoomMax = 3;
const double _kZoomStep = 0.1;

/// The probe readout. The source showed Fe 74 %, which made 100.1 %.
const String _kComposition = 'Fe 73.9%, Cr 18%, Ni 8%, C 0.1%';

/// The source's `confetti({colors: [...]})` palette.
const List<Color> _kConfettiColors = [
  _rt_Tw.blue500,
  _rt_Tw.emerald500,
  _rt_Tw.amber500,
];

const Color _kOrange900 = Color(0xFF7C2D12);
const Color _kPurple800 = Color(0xFF6B21A8);
const Color _kStone500 = Color(0xFF78716C);
const Color _kStone700 = Color(0xFF44403C);
const Color _kStone900 = Color(0xFF1C1917);

// ------------------------------------------------------------------ model ----

/// Every place a card can be dropped.
enum _Zone { furnace, metal, nonMetal, native, compound, cement, talcum, tools }

/// What a card looks like: the source's `.mat-cube` colours for the alloy
/// ingredients, and a drawn sample for the elements and minerals (the
/// source's cards only had a name).
enum _Look {
  cubeIron,
  cubeChromium,
  cubeNickel,
  cubeCarbon,
  goldIngot,
  silverIngot,
  magnesiumRibbon,
  ironNail,
  carbonLumps,
  sulfurPowder,
  oxygenBubbles,
  mercuryDrop,
  goldNugget,
  silverNugget,
  copperNugget,
  sulfurCrystals,
  quartzCrystal,
  calciteRhomb,
  micaSheets,
  talcLump,
  ironOre;

  bool get isCube => index <= _Look.cubeCarbon.index;
}

/// One draggable card: an alloy ingredient, an element, a mineral or a
/// mineral to match with its use.
class _Card {
  const _Card(this.group, this.id, this.look, this.target, {this.symbol});

  /// i18n table: `alloy`, `elements`, `minerals` or `matches`.
  final String group;
  final String id;
  final _Look look;

  /// Where it belongs.
  final _Zone target;
  final String? symbol;

  String get key => '$group-$id';
  String get label => _tx.s('$group.$id');
}

/// `#alloy-materials`.
const List<_Card> _kAlloy = [
  _Card('alloy', 'iron', _Look.cubeIron, _Zone.furnace, symbol: 'Fe'),
  _Card('alloy', 'chromium', _Look.cubeChromium, _Zone.furnace, symbol: 'Cr'),
  _Card('alloy', 'nickel', _Look.cubeNickel, _Zone.furnace, symbol: 'Ni'),
  _Card('alloy', 'carbon', _Look.cubeCarbon, _Zone.furnace, symbol: 'C'),
];

/// The source's `elementsData`.
const List<_Card> _kElements = [
  _Card('elements', 'gold', _Look.goldIngot, _Zone.metal, symbol: 'Au'),
  _Card('elements', 'silver', _Look.silverIngot, _Zone.metal, symbol: 'Ag'),
  _Card(
    'elements',
    'magnesium',
    _Look.magnesiumRibbon,
    _Zone.metal,
    symbol: 'Mg',
  ),
  _Card('elements', 'iron', _Look.ironNail, _Zone.metal, symbol: 'Fe'),
  _Card('elements', 'carbon', _Look.carbonLumps, _Zone.nonMetal, symbol: 'C'),
  _Card('elements', 'sulfur', _Look.sulfurPowder, _Zone.nonMetal, symbol: 'S'),
  _Card('elements', 'oxygen', _Look.oxygenBubbles, _Zone.nonMetal, symbol: 'O'),
  _Card('elements', 'mercury', _Look.mercuryDrop, _Zone.metal, symbol: 'Hg'),
];

/// The source's `mineralsData`.
const List<_Card> _kMinerals = [
  _Card('minerals', 'gold', _Look.goldNugget, _Zone.native),
  _Card('minerals', 'silver', _Look.silverNugget, _Zone.native),
  _Card('minerals', 'copper', _Look.copperNugget, _Zone.native),
  _Card('minerals', 'sulfur', _Look.sulfurCrystals, _Zone.native),
  _Card('minerals', 'quartz', _Look.quartzCrystal, _Zone.compound),
  _Card('minerals', 'calcite', _Look.calciteRhomb, _Zone.compound),
  _Card('minerals', 'mica', _Look.micaSheets, _Zone.compound),
];

/// The source's `matchMinerals`.
const List<_Card> _kMatches = [
  _Card('matches', 'calcite', _Look.calciteRhomb, _Zone.cement),
  _Card('matches', 'talc', _Look.talcLump, _Zone.talcum),
  _Card('matches', 'ironOre', _Look.ironOre, _Zone.tools),
];

/// The three `.probe-point`s on the steel bar.
enum _Probe { left, center, right }

/// The source's `.mineral-grain`s: position (fraction of the rock) and size.
enum _Grain {
  quartz(Offset(0.30, 0.20), Size(25, 25)),
  calcite(Offset(0.20, 0.60), Size(25, 25)),
  mica(Offset(0.60, 0.40), Size(30, 10)),
  pyroxene(Offset(0.70, 0.70), Size(25, 25)),
  olivine(Offset(0.80, 0.30), Size(25, 25));

  const _Grain(this.position, this.size);

  /// Top-left corner (`top` / `left` percentages).
  final Offset position;
  final Size size;

  String get label => _tx.s('grains.$name');
}

/// The source's `logObservation` types: the result is blue, green or red.
enum _Tone { info, success, error }

/// One observation-log row. Builders, so rows re-translate with the language.
class _LogEntry {
  const _LogEntry(this.action, this.result, this.tone);

  final String Function() action;
  final String Function() result;
  final _Tone tone;
}

// ------------------------------------------------------------------- page ----

class Cl8Ch08A5AlloysMetalsMineralsPage extends StatefulWidget {
  const Cl8Ch08A5AlloysMetalsMineralsPage({super.key});

  @override
  State<Cl8Ch08A5AlloysMetalsMineralsPage> createState() =>
      _Cl8Ch08A5AlloysMetalsMineralsPageState();
}

class _Cl8Ch08A5AlloysMetalsMineralsPageState
    extends State<Cl8Ch08A5AlloysMetalsMineralsPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _random = math.Random();
  final ScrollController _logScroll = ScrollController();
  final ScrollController _workspaceScroll = ScrollController();

  /// Seconds since the page opened; drives the furnace glow, the pulsing
  /// Melt button and the glowing grains.
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

  // Shared (source `state`). Step 0 = the setup board is showing.
  int _scenario = 1;
  int _step = 0;
  final Set<int> _toggledTiles = {};
  bool _showLabels = true;
  bool _panMode = false;
  double _zoom = 1;
  Offset _pan = Offset.zero;

  /// Cards placed correctly (furnace, bins, uses) in this scenario.
  final Set<_Card> _placed = {};
  _Card? _selected;
  _Zone? _flashZone;
  _Card? _shakeCard;
  int _shakeSerial = 0;

  // Scenario 1.
  bool _melting = false;
  final Set<_Probe> _probed = {};
  _Probe? _lastProbe;

  // Scenario 2.
  final List<_Grain> _found = [];

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
  /// Both scenarios have three steps.
  static const int _stepCount = 3;

  bool get _boardOpen => _step == 0;

  int _placedIn(String group) =>
      _placed.where((card) => card.group == group).length;

  /// Appends a log row; call inside `setState`.
  void _pushLog(
    String Function() action,
    String Function() result, {
    _Tone tone = _Tone.info,
  }) {
    _log.add(_LogEntry(action, result, tone));
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

  /// The source's `loadScenario` (state only; call inside `setState`): every
  /// scenario starts afresh at its setup board with an empty log.
  void _enterScenario(int scenario) {
    _scenario = scenario;
    _step = 0;
    _toggledTiles.clear();
    _log.clear();
    _placed.clear();
    _selected = null;
    _flashZone = null;
    _shakeCard = null;
    _melting = false;
    _probed.clear();
    _lastProbe = null;
    _found.clear();
    _zoom = 1;
    _pan = Offset.zero;
  }

  void _changeScenario(int scenario) {
    _cancelTimers();
    setState(() => _enterScenario(scenario));
    _scrollToTop();
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
    _rt_playSfx(_rt_Sfx.scenario);
    _goToStep(1);
  }

  /// The source's `loadStep`.
  void _goToStep(int step) {
    setState(() {
      _step = step;
      _toggledTiles.clear();
      _selected = null;
      _flashZone = null;
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

  /// The source's `zoomCam` (the whole interactive layer scales).
  void _zoomBy(double delta) =>
      setState(() => _zoom = (_zoom + delta).clamp(_kZoomMin, _kZoomMax));

  void _resetView() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

  // --------------------------------------------------------------- dialogs --
  /// The source's `showSummary`: the finished step's observation as the key
  /// takeaway. Within a scenario the lab moves to the next step however the
  /// popup is closed (in the source, ✕ left it stranded); the last step's
  /// Next Scenario / Restart Lab acts on its button only.
  void _showStepSummary() {
    final scenario = _scenario;
    final step = _step;
    final lastStep = step == _stepCount;
    final lastScenario = scenario == 2;
    _shell.showSuccess(
      title: _tx.s('success'),
      icon: Icons.check_circle,
      color: _rt_Tw.blue600,
      buttonLabel: _tx.s(
        !lastStep ? 'nextStep' : (lastScenario ? 'restartLab' : 'nextScenario'),
      ),
      body: _SummaryBody(
        heading: _tx.s('keyTakeaway'),
        text: _tx.s('scenarios.$scenario.steps.${step - 1}.observation'),
        footer: _tx.s('stepComplete'),
      ),
      onClose: lastStep
          ? null
          : () {
              if (mounted && _scenario == scenario && _step == step) {
                _goToStep(step + 1);
              }
            },
      onConfirm: !lastStep
          ? null
          : () {
              _rt_playSfx(_rt_Sfx.click);
              if (lastScenario) {
                _restart();
              } else {
                _changeScenario(2);
              }
            },
    );
    _launchConfetti();
  }

  /// Shows the summary [ms] later, if the lab is still on this step.
  void _summaryAfter(int ms) {
    final scenario = _scenario;
    final step = _step;
    _after(ms, () {
      if (_scenario == scenario && _step == step) _showStepSummary();
    });
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

  // ----------------------------------------------------- cards and zones --
  void _selectCard(_Card card) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selected = _selected == card ? null : card);
  }

  /// Tap-to-place: drops the selected card on [zone].
  void _tapZone(_Zone zone) {
    final card = _selected;
    if (card == null) return;
    setState(() => _selected = null);
    _dropCard(card, zone);
  }

  /// The source's `dropAlloyMat`, `dropElement`, `dropMineral` and
  /// `dropMatch`.
  void _dropCard(_Card card, _Zone zone) {
    if (_boardOpen || _placed.contains(card)) return;
    if (card.target != zone) {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() {
        _flashZone = zone;
        _shakeCard = card;
        _shakeSerial++;
        _pushLog(
          () => _fmt(card.group == 'matches' ? 'logMatched' : 'logSorted', {
            'item': card.label,
          }),
          () => _tx.s(
            card.group == 'matches'
                ? 'logIncorrectUse'
                : 'logIncorrectCategory',
          ),
          tone: _Tone.error,
        );
      });
      _after(700, () {
        if (_flashZone == zone) setState(() => _flashZone = null);
      });
      return;
    }
    _rt_playSfx(card.group == 'alloy' ? _rt_Sfx.pop : _rt_Sfx.correct);
    setState(() {
      _placed.add(card);
      switch (card.group) {
        case 'alloy':
          _pushLog(
            () => _fmt('logAdded', {'item': card.label}),
            () => _tx.s('logDroppedFurnace'),
          );
        case 'matches':
          _pushLog(
            () => _fmt('logMatched', {'item': card.label}),
            () => _tx.s('logCorrectUse'),
            tone: _Tone.success,
          );
        default:
          _pushLog(
            () => _fmt('logSorted', {'item': card.label}),
            () => _tx.s('logCorrect'),
            tone: _Tone.success,
          );
      }
    });
    if (card.group == 'elements' &&
        _placedIn('elements') == _kElements.length) {
      _summaryAfter(500);
    } else if (card.group == 'minerals' &&
        _placedIn('minerals') == _kMinerals.length) {
      _summaryAfter(500);
    } else if (card.group == 'matches' &&
        _placedIn('matches') == _kMatches.length) {
      _summaryAfter(1000);
    }
  }

  // ------------------------------------------------------ scenario 1 logic --
  bool get _allAdded => _placedIn('alloy') == _kAlloy.length;

  /// The source's `meltAlloy`.
  void _melt() {
    if (_scenario != 1 || _step != 1 || !_allAdded || _melting) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _melting = true;
      _pushLog(() => _tx.s('logStartMelt'), () => _tx.s('logComponentsMixing'));
    });
    _summaryAfter(2000);
  }

  /// The source's `probeBar`.
  void _probe(_Probe probe) {
    if (_scenario != 1 || _step != 2 || _probed.contains(probe)) return;
    _rt_playSfx(_rt_Sfx.correct);
    setState(() {
      _probed.add(probe);
      _lastProbe = probe;
      _pushLog(
        () => _fmt('logProbed', {'pos': _tx.s('positions.${probe.name}')}),
        () => _tx.s('logComposition'),
        tone: _Tone.success,
      );
    });
    if (_probed.length == _Probe.values.length) _summaryAfter(1000);
  }

  // ------------------------------------------------------ scenario 2 logic --
  /// The source's `findMineral`.
  void _findGrain(_Grain grain) {
    if (_scenario != 2 || _step != 1 || _found.contains(grain)) return;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _found.add(grain);
      _pushLog(
        () => _tx.s('logInspectedGrain'),
        () => _fmt('logFound', {'item': grain.label}),
      );
    });
    if (_found.length == _Grain.values.length) _summaryAfter(1000);
  }

  // ----------------------------------------------------------------- build --
  String get _hudText {
    if (_scenario == 1 && _step == 1 && _allAdded && !_melting) {
      return _tx.s('hudClickMelt');
    }
    return _tx.s('scenarios.$_scenario.steps.${_step - 1}.action');
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
            accent: _rt_Tw.orange500,
            headerGradient: [_rt_Tw.slate950, _kOrange900],
            headerSubtitleColor: _rt_Tw.orange100,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.local_fire_department,
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
            _observationLog(context),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- sidebar --
  /// The source's `renderTeacherBoard`.
  Widget _sidebar() {
    final current = math.max(_step, 1);
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
                  status: i < current
                      ? _TileStatus.done
                      : (i == current
                            ? _TileStatus.active
                            : _TileStatus.upcoming),
                  expanded: (i == current) != _toggledTiles.contains(i),
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
              _hudText,
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
    TextStyle resultStyle(_Tone tone) => TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      color: switch (tone) {
        _Tone.info => _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600),
        _Tone.success => _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green600),
        _Tone.error => _rt_Lab.onTinted(_rt_Tw.red400, _rt_Tw.red600),
      },
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
                            child: Text(
                              entry.result(),
                              style: resultStyle(entry.tone),
                            ),
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
  /// The source's `#interactive-ui-layer`: the setup board, then one view per
  /// step, zoomed and panned as a whole like the source's transform layer.
  Widget _workspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight < _kShortHeight;
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
              // GSAP's step entrance: fade in while rising 20 px.
              child: TweenAnimationBuilder<double>(
                key: ValueKey('view-$_scenario-$_step'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - t)),
                    child: child,
                  ),
                ),
                child: _stepView(width, narrow: narrow, short: short),
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
      (1, 1) => _forgeView(narrow: narrow, short: short),
      (1, 2) => _barView(width),
      (1, _) => _sortView(
        _kElements,
        _Zone.metal,
        _Zone.nonMetal,
        narrow: narrow,
      ),
      (2, 1) => _rockView(narrow: narrow),
      (2, 2) => _sortView(
        _kMinerals,
        _Zone.native,
        _Zone.compound,
        narrow: narrow,
      ),
      _ => _matchView(narrow: narrow),
    };
  }

  /// The source's `#ui-setup-board`: the scenario title, its objective and
  /// the button that starts step 1.
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
              color: _rt_Tw.orange500.withValues(alpha: 0.5),
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
                color: _rt_Tw.orange500,
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
                _tx.s('scenarios.$_scenario.objective'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: short ? 12.5 : 15,
                  fontWeight: FontWeight.w600,
                  color: _rt_Lab.onTinted(_rt_Tw.blue100, _rt_Tw.slate600),
                  height: 1.4,
                ),
              ),
              SizedBox(height: short ? 14 : 24),
              _ChunkyButton(
                key: const ValueKey('board-btn'),
                label: _tx.s('begin'),
                color: _rt_Tw.orange600,
                borderColor: _kOrange900,
                onPressed: _startFromBoard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String desc) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.text,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: _rt_Tw.slate500),
        ),
      ],
    );
  }

  /// The blue "tap or drag" strip over the drag-and-drop steps.
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

  /// Fades labels with the labels tool.
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

  /// A tray card: tap to select or drag onto a zone. A wrong drop shakes it
  /// (GSAP `x: [-10, 10, -10, 10, 0]`).
  Widget _card(_Card card, {required bool compact}) {
    final face = _CardFace(
      card: card,
      compact: compact,
      selected: _selected == card,
      showLabel: _showLabels,
    );
    return _Shake(
      serial: _shakeCard == card ? _shakeSerial : 0,
      child: Draggable<_Card>(
        data: card,
        onDragStarted: () {
          _rt_playSfx(_rt_Sfx.pop);
          setState(() => _selected = null);
        },
        feedback: Material(
          type: MaterialType.transparency,
          child: _CardFace(
            card: card,
            compact: compact,
            selected: false,
            showLabel: _showLabels,
            lifted: true,
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: face),
        child: GestureDetector(
          key: ValueKey('card-${card.key}'),
          onTap: () => _selectCard(card),
          child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
        ),
      ),
    );
  }

  Widget _tray(List<_Card> cards, {required bool compact}) {
    return Wrap(
      key: const ValueKey('tray'),
      alignment: WrapAlignment.center,
      spacing: compact ? 8 : 12,
      runSpacing: 10,
      children: [
        for (final card in cards)
          if (!_placed.contains(card)) _card(card, compact: compact),
      ],
    );
  }

  /// Wraps a drop zone: drag target plus tap-to-place.
  Widget _zone(_Zone zone, Widget Function(bool hovering, bool armed) builder) {
    return DragTarget<_Card>(
      onWillAcceptWithDetails: (details) => !_placed.contains(details.data),
      onAcceptWithDetails: (details) => _dropCard(details.data, zone),
      builder: (context, candidates, _) => GestureDetector(
        key: ValueKey('zone-${zone.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _tapZone(zone),
        child: builder(candidates.isNotEmpty, _selected != null),
      ),
    );
  }

  // -------------------------------------------------------- scenario 1 UI --
  /// `#sc1-step1`: the ingredient tray, the forge and the Melt button. On a
  /// short (phone) canvas the tray sits beside the forge, so dragging a card
  /// in needs no scrolling.
  Widget _forgeView({required bool narrow, required bool short}) {
    final furnace = _zone(
      _Zone.furnace,
      (hovering, armed) => _furnace(short ? 130 : 200, hovering || armed),
    );
    final melt = _melting
        ? const SizedBox.shrink()
        : ValueListenableBuilder<double>(
            valueListenable: _clock,
            // `animate-pulse` once all four are in.
            builder: (context, t, child) => Transform.scale(
              scale: _allAdded ? 1 + 0.04 * math.sin(t * math.pi * 2) : 1,
              child: child,
            ),
            child: _ChunkyButton(
              key: const ValueKey('btn-melt'),
              label: _tx.s('meltButton'),
              icon: Icons.local_fire_department,
              color: _rt_Tw.orange600,
              borderColor: _kOrange900,
              onPressed: _allAdded ? _melt : null,
            ),
          );
    if (short) {
      return Column(
        children: [
          _hintBox(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Two compact cards per row.
              SizedBox(width: 160, child: _tray(_kAlloy, compact: true)),
              const SizedBox(width: 16),
              // Flexible, so a long button label wraps instead of
              // overflowing.
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [furnace, const SizedBox(height: 8), melt],
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        _hintBox(),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: narrow ? 92 : 112),
          child: _tray(_kAlloy, compact: narrow),
        ),
        const SizedBox(height: 22),
        furnace,
        const SizedBox(height: 16),
        melt,
      ],
    );
  }

  /// The `.furnace` (a 200 px design scaled to [size]) with the chunks
  /// dropped in, the glow while melting, the label and the counter.
  Widget _furnace(double size, bool highlight) {
    final added = [
      for (final card in _kAlloy)
        if (_placed.contains(card)) card,
    ];
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _FurnacePainter(
                    clock: _clock,
                    added: [for (final card in added) card.look],
                    melting: _melting,
                    highlight: highlight,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Text(
                  _fmt('addedCount', {'n': added.length}),
                  key: const ValueKey('furnace-counter'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.orange400,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: _label(
                  Text(
                    _tx.s('forge').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: _rt_Tw.slate400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `#sc1-step2`: the stainless steel bar and its three probe points.
  Widget _barView(double width) {
    final barWidth = math.min(360.0, width - 16);
    final probe = _lastProbe;
    return Column(
      children: [
        _sectionTitle(_tx.s('barTitle'), _tx.s('barDesc')),
        const SizedBox(height: 28),
        // `#probe-tooltip`: the latest reading.
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: probe == null ? 0 : 1,
          child: Container(
            key: const ValueKey('probe-readout'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _rt_Tw.slate900.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Tw.blue500),
            ),
            child: Text(
              probe == null
                  ? _kComposition
                  : '${_tx.s('positions.${probe.name}')}: $_kComposition',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: barWidth,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_rt_Tw.slate100, _rt_Tw.slate400, _rt_Tw.slate600],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _rt_Tw.slate300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final point in _Probe.values) _probePoint(point)],
          ),
        ),
        const SizedBox(height: 8),
        // Lined up under the probe points (border 2 + padding 14 + half of
        // the 44 px target = the 64 px label's centre at 6 + 32).
        Container(
          width: barWidth,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _label(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final point in _Probe.values)
                  SizedBox(
                    width: 64,
                    child: Text(
                      _tx.s('positions.${point.name}'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _probePoint(_Probe point) {
    final tested = _probed.contains(point);
    return GestureDetector(
      key: ValueKey('probe-${point.name}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _probe(point),
      child: MouseRegion(
        cursor: tested ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(painter: _ProbeRingPainter(tested: tested)),
            ),
          ),
        ),
      ),
    );
  }

  /// `#sc1-step3` / `#sc2-step2`: a card tray over two bins.
  Widget _sortView(
    List<_Card> cards,
    _Zone left,
    _Zone right, {
    required bool narrow,
  }) {
    return Column(
      children: [
        _hintBox(),
        const SizedBox(height: 12),
        _tray(cards, compact: narrow),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _bin(left, cards, narrow: narrow)),
              SizedBox(width: narrow ? 10 : 24),
              Expanded(child: _bin(right, cards, narrow: narrow)),
            ],
          ),
        ),
      ],
    );
  }

  ({String? subtitle, Color accent}) _binStyle(_Zone zone) {
    return switch (zone) {
      _Zone.metal => (subtitle: null, accent: _rt_Tw.blue500),
      _Zone.nonMetal => (subtitle: null, accent: _rt_Tw.green500),
      _Zone.native => (subtitle: _tx.s('nativeDesc'), accent: _rt_Tw.purple500),
      _ => (subtitle: _tx.s('compoundDesc'), accent: _rt_Tw.orange500),
    };
  }

  /// A dashed `ondrop` bin holding its sorted chips.
  Widget _bin(_Zone zone, List<_Card> cards, {required bool narrow}) {
    final style = _binStyle(zone);
    return _zone(zone, (hovering, armed) {
      final flashing = _flashZone == zone;
      final border = flashing
          ? _rt_Tw.red500
          : (hovering
                ? _rt_Tw.blue400
                : (armed
                      ? _rt_Tw.blue500
                      : style.accent.withValues(alpha: 0.75)));
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(narrow ? 8 : 12),
        decoration: BoxDecoration(
          color: flashing
              ? _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500)
              : (hovering
                    ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
                    : _rt_Lab.tinted(_rt_Tw.slate50, style.accent)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: border,
            width: hovering || flashing ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              _tx.s('zones.${zone.name}').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: narrow ? 11.5 : 13,
                fontWeight: FontWeight.w900,
                letterSpacing: narrow ? 0.8 : 1.6,
                color: _rt_Lab.onTinted(style.accent, style.accent),
              ),
            ),
            if (style.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  style.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: _rt_Lab.textMuted),
                ),
              ),
            Divider(height: 14, color: style.accent.withValues(alpha: 0.3)),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: narrow ? 64 : 120),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final card in cards)
                      if (card.target == zone && _placed.contains(card))
                        _CardChip(
                          key: ValueKey('placed-${card.key}'),
                          card: card,
                          showLabel: _showLabels,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // -------------------------------------------------------- scenario 2 UI --
  /// `#sc2-step1`: the rock with its grains and the Mineral Notebook.
  Widget _rockView({required bool narrow}) {
    final rockWidth = narrow ? 210.0 : 300.0;
    return Column(
      children: [
        _sectionTitle(_tx.s('rockTitle'), _tx.s('rockDesc')),
        SizedBox(height: narrow ? 12 : 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: rockWidth,
              height: rockWidth * 250 / 300,
              child: FittedBox(
                child: SizedBox(width: 300, height: 250, child: _rock()),
              ),
            ),
            SizedBox(width: narrow ? 14 : 40),
            _notebook(width: narrow ? 150 : 192),
          ],
        ),
      ],
    );
  }

  Widget _rock() {
    return Stack(
      key: const ValueKey('rock'),
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: CustomPaint(painter: _RockPainter())),
        for (final grain in _Grain.values) _grainWidget(grain),
      ],
    );
  }

  /// One `.mineral-grain`, with a larger tap target. Unfound grains glow;
  /// found ones dim, get a green ring and their name.
  Widget _grainWidget(_Grain grain) {
    const hit = 44.0;
    final found = _found.contains(grain);
    final centre = Offset(
      grain.position.dx * 300 + grain.size.width / 2,
      grain.position.dy * 250 + grain.size.height / 2,
    );
    return Positioned(
      left: centre.dx - hit / 2,
      top: centre.dy - hit / 2,
      width: hit,
      height: hit,
      child: GestureDetector(
        key: ValueKey('grain-${grain.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _findGrain(grain),
        child: MouseRegion(
          cursor: found ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(hit),
                painter: _GrainPainter(
                  grain: grain,
                  clock: _clock,
                  found: found,
                ),
              ),
              if (found)
                Positioned(
                  top: hit - 4,
                  child: _label(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Tw.slate900.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        grain.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// `#mineral-list` in the Mineral Notebook.
  Widget _notebook({required double width}) {
    return Container(
      key: const ValueKey('notebook'),
      width: width,
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Tw.blue500.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('notebook'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.text,
            ),
          ),
          Divider(height: 14, color: _rt_Lab.border),
          for (final grain in _found)
            Container(
              key: ValueKey('notebook-${grain.name}'),
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _rt_Lab.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      grain.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                  const Icon(Icons.check, size: 14, color: _rt_Tw.green500),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// `#sc2-step3`: three minerals over three everyday uses.
  Widget _matchView({required bool narrow}) {
    return Column(
      children: [
        _sectionTitle(_tx.s('matchTitle'), _tx.s('matchDesc')),
        const SizedBox(height: 10),
        _hintBox(),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: narrow ? 92 : 112),
          child: _tray(_kMatches, compact: narrow),
        ),
        SizedBox(height: narrow ? 12 : 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: narrow ? 10 : 24,
          runSpacing: 12,
          children: [
            for (final zone in const [_Zone.cement, _Zone.talcum, _Zone.tools])
              _useZone(zone, width: narrow ? 124 : 160),
          ],
        ),
      ],
    );
  }

  /// One use card (`.dropzone`) with its icon and slot.
  Widget _useZone(_Zone zone, {required double width}) {
    final (icon, color) = switch (zone) {
      _Zone.cement => (Icons.apartment, _rt_Tw.slate400),
      _Zone.talcum => (Icons.child_care, _rt_Tw.pink500),
      _ => (Icons.build, _rt_Tw.blue400),
    };
    final matched = [
      for (final card in _kMatches)
        if (card.target == zone && _placed.contains(card)) card,
    ];
    return _zone(zone, (hovering, armed) {
      final flashing = _flashZone == zone;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: flashing
              ? _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500)
              : (hovering
                    ? _rt_Tw.blue500.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: flashing
                ? _rt_Tw.red500
                : (hovering || armed
                      ? _rt_Tw.blue500
                      : color.withValues(alpha: 0.7)),
            width: hovering || flashing ? 2.5 : 1.5,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 6),
            Text(
              _tx.s('zones.${zone.name}'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
            const SizedBox(height: 8),
            // `.match-slot`.
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _rt_Tw.slate800.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: matched.isEmpty
                      ? _rt_Tw.slate500.withValues(alpha: 0.7)
                      : _rt_Tw.green500,
                  width: 2,
                ),
              ),
              child: Center(
                child: matched.isEmpty
                    ? null
                    : _CardChip(
                        key: ValueKey('placed-${matched.first.key}'),
                        card: matched.first,
                        showLabel: true,
                        inline: true,
                      ),
              ),
            ),
          ],
        ),
      );
    });
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

/// A card's sample: the ingredient cube with its symbol, or a drawn sample.
class _CardArt extends StatelessWidget {
  const _CardArt({required this.card, required this.size});

  final _Card card;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (card.look.isCube) {
      final (light, dark) = switch (card.look) {
        _Look.cubeIron => (_rt_Tw.slate400, _rt_Tw.slate600),
        _Look.cubeChromium => (_rt_Tw.slate200, _rt_Tw.slate400),
        _Look.cubeNickel => (const Color(0xFFFCD34D), _rt_Tw.amber700),
        _ => (_rt_Tw.slate700, _rt_Tw.slate900),
      };
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.2),
          gradient: RadialGradient(
            center: const Alignment(-0.4, -0.4),
            radius: 0.95,
            colors: [light, dark],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Text(
          card.symbol ?? '',
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SamplePainter(card.look)),
    );
  }
}

/// A tray card (`.glass-card`) or its drag feedback.
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.compact,
    required this.selected,
    required this.showLabel,
    this.lifted = false,
  });

  final _Card card;
  final bool compact;
  final bool selected;
  final bool showLabel;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final symbol = card.look.isCube ? null : card.symbol;
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: selected || lifted ? 1.06 : 1,
      child: Container(
        width: compact ? 72 : 92,
        height: compact ? 84 : 104,
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
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
                _CardArt(card: card, size: compact ? 38 : 48),
                const SizedBox(height: 4),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showLabel ? 1 : 0,
                    child: Text(
                      card.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 9.5 : 11,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (symbol != null)
              Positioned(
                top: -4,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _rt_Tw.slate700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A correctly placed card, shrunk into its bin or slot (green, like the
/// source's `bg-green-500/20 border-green-500`).
class _CardChip extends StatelessWidget {
  const _CardChip({
    super.key,
    required this.card,
    required this.showLabel,
    this.inline = false,
  });

  final _Card card;
  final bool showLabel;

  /// One row (art beside the name), for a use slot.
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final name = AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: showLabel ? 1 : 0,
      child: Text(
        card.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: inline ? 11 : 9.5,
          fontWeight: FontWeight.w800,
          color: _rt_Lab.text,
        ),
      ),
    );
    return Container(
      width: inline ? null : 66,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: _rt_Tw.green500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rt_Tw.green500),
      ),
      child: inline
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardArt(card: card, size: 24),
                const SizedBox(width: 5),
                Flexible(child: name),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardArt(card: card, size: 30),
                const SizedBox(height: 2),
                name,
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

/// "Key Takeaway" body of the summary popup.
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.heading,
    required this.text,
    required this.footer,
  });

  final String heading;
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

/// The `.furnace` in its 200 × 200 design box: steel body, dark mouth with
/// the ingredients dropped in, and the pulsing `.melt-glow` while melting.
class _FurnacePainter extends CustomPainter {
  _FurnacePainter({
    required this.clock,
    required this.added,
    required this.melting,
    required this.highlight,
  }) : super(repaint: melting ? clock : null);

  final ValueNotifier<double> clock;
  final List<_Look> added;
  final bool melting;

  /// A card is hovering over it or selected for tap-to-place.
  final bool highlight;

  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.fromLTWH(0, 0, 200, 200);
    final body = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: const Radius.circular(50),
      bottomRight: const Radius.circular(50),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rt_Tw.slate600, _rt_Tw.slate800],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      const Rect.fromLTWH(0, 140, 200, 60),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
        ).createShader(const Rect.fromLTWH(0, 140, 200, 60)),
    );
    canvas.restore();
    canvas.drawRRect(
      body.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _rt_Tw.slate700,
    );

    // `.furnace-opening`.
    final mouth = Rect.fromCenter(
      center: const Offset(100, 44),
      width: 160,
      height: 60,
    );
    canvas.drawOval(mouth, Paint()..color = Colors.black);
    canvas.save();
    canvas.clipPath(Path()..addOval(mouth));
    if (melting) {
      final t = clock.value;
      // `pulse-fire`: 1 s alternate, scale 1 → 1.1, opacity 0.8 → 1.
      final pulse = 0.5 + 0.5 * math.sin(t * math.pi);
      // The CSS gradient covers the whole 160 × 60 opening, so stretch a
      // circular one to the ellipse.
      final radius = mouth.height / 2 * (1.25 + 0.12 * pulse);
      canvas.save();
      canvas.translate(mouth.center.dx, mouth.center.dy);
      canvas.scale(mouth.width / mouth.height, 1);
      final glow = Rect.fromCircle(center: Offset.zero, radius: radius);
      canvas.drawOval(
        glow,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _rt_Tw.yellow400.withValues(alpha: 0.85 + 0.15 * pulse),
              _rt_Tw.orange500.withValues(alpha: 0.85 + 0.15 * pulse),
              _rt_Tw.red500.withValues(alpha: 0.8),
              Colors.transparent,
            ],
            stops: const [0, 0.35, 0.75, 1],
          ).createShader(glow),
      );
      canvas.restore();
    } else {
      for (var i = 0; i < added.length; i++) {
        final chunk = Rect.fromCenter(
          center: Offset(58 + i * 28.0, 50 + (i.isEven ? 0 : -6)),
          width: 18,
          height: 13,
        );
        final (light, dark) = switch (added[i]) {
          _Look.cubeIron => (_rt_Tw.slate400, _rt_Tw.slate600),
          _Look.cubeChromium => (_rt_Tw.slate200, _rt_Tw.slate400),
          _Look.cubeNickel => (const Color(0xFFFCD34D), _rt_Tw.amber700),
          _ => (_rt_Tw.slate700, _rt_Tw.slate900),
        };
        canvas.drawRRect(
          RRect.fromRectAndRadius(chunk, const Radius.circular(3)),
          Paint()
            ..shader = LinearGradient(
              colors: [light, dark],
            ).createShader(chunk),
        );
      }
    }
    canvas.restore();
    canvas.drawOval(
      mouth.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = highlight ? _rt_Tw.blue500 : _rt_Tw.slate500,
    );
  }

  @override
  bool shouldRepaint(covariant _FurnacePainter oldDelegate) =>
      oldDelegate.melting != melting ||
      oldDelegate.highlight != highlight ||
      oldDelegate.added.length != added.length;
}

/// A `.probe-point`: dashed red until tested, then solid green.
class _ProbeRingPainter extends CustomPainter {
  const _ProbeRingPainter({required this.tested});

  final bool tested;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2 - 1.5;
    if (tested) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()..color = _rt_Tw.green500.withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _rt_Tw.green500,
      );
      return;
    }
    canvas.drawCircle(
      centre,
      radius,
      Paint()..color = _rt_Tw.red500.withValues(alpha: 0.12),
    );
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = _rt_Tw.red500;
    const dashes = 10;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        i * 2 * math.pi / dashes,
        math.pi / dashes,
        false,
        dash,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProbeRingPainter oldDelegate) =>
      oldDelegate.tested != tested;
}

/// `.rock-sample` in its 300 × 250 design box: the irregular `border-radius`
/// outline, the radial shading and some speckle.
class _RockPainter extends CustomPainter {
  const _RockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rect = Rect.fromLTWH(0, 0, 300, 250);
    // `border-radius: 40% 60% 50% 40% / 50% 40% 60% 50%`.
    final outline = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.elliptical(120, 125),
      topRight: const Radius.elliptical(180, 100),
      bottomRight: const Radius.elliptical(150, 150),
      bottomLeft: const Radius.elliptical(120, 125),
    );
    canvas.drawRRect(
      outline.shift(const Offset(10, 15)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(
      outline,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.2),
          radius: 0.75,
          colors: [_kStone500, _kStone700, _kStone900],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRRect(outline);
    final random = math.Random(11);
    for (var i = 0; i < 140; i++) {
      final light = random.nextBool();
      canvas.drawCircle(
        Offset(random.nextDouble() * 300, random.nextDouble() * 250),
        random.nextDouble() * 1.8 + 0.4,
        Paint()
          ..color = (light ? Colors.white : Colors.black).withValues(
            alpha: light ? 0.08 : 0.25,
          ),
      );
    }
    canvas.restore();
    canvas.drawRRect(
      outline.deflate(4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _RockPainter oldDelegate) => false;
}

/// One `.mineral-grain` centred in its tap target: a pulsing glow while it
/// is unfound, dimmed with a green ring once found.
class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.grain, required this.clock, required this.found})
    : super(repaint: found ? null : clock);

  final _Grain grain;
  final ValueNotifier<double> clock;
  final bool found;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    if (!found) {
      final pulse = 0.5 + 0.5 * math.sin(clock.value * math.pi * 2);
      canvas.drawCircle(
        centre,
        14 + 3 * pulse,
        Paint()
          ..color = _rt_Tw.amber400.withValues(alpha: 0.25 + 0.3 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    final rect = Rect.fromCenter(
      center: centre,
      width: grain.size.width,
      height: grain.size.height,
    );
    final (color, path) = _shape(rect);
    canvas.save();
    if (found) {
      canvas.saveLayer(
        rect.inflate(4),
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
    }
    canvas.drawPath(
      path.shift(const Offset(2, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    if (found) canvas.restore();
    canvas.restore();
    if (found) {
      canvas.drawCircle(
        centre,
        math.max(rect.width, rect.height) / 2 + 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _rt_Tw.green500,
      );
    }
  }

  /// The source's `clip-path` / `border-radius` shape and colour.
  (Color, Path) _shape(Rect r) {
    Offset at(double x, double y) =>
        Offset(r.left + r.width * x, r.top + r.height * y);
    switch (grain) {
      case _Grain.quartz:
        return (
          _rt_Tw.slate50,
          Path()..addPolygon([
            at(0.5, 0),
            at(1, 0.25),
            at(1, 0.75),
            at(0.5, 1),
            at(0, 0.75),
            at(0, 0.25),
          ], true),
        );
      case _Grain.calcite:
        return (
          const Color(0xFFFEF08A),
          Path()
            ..addPolygon([at(0.2, 0), at(0.8, 0), at(1, 1), at(0, 1)], true),
        );
      case _Grain.mica:
        return (
          _rt_Tw.slate700,
          Path()
            ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(2))),
        );
      case _Grain.pyroxene:
        return (
          const Color(0xFF14532D),
          Path()..addPolygon([
            at(0, 0),
            at(1, 0.2),
            at(0.8, 1),
            at(0.2, 0.8),
          ], true),
        );
      case _Grain.olivine:
        return (
          _rt_Tw.lime500,
          Path()..addRRect(
            RRect.fromRectAndCorners(
              r,
              topLeft: Radius.elliptical(r.width * 0.4, r.height * 0.4),
              topRight: Radius.elliptical(r.width * 0.6, r.height * 0.6),
              bottomRight: Radius.elliptical(r.width * 0.3, r.height * 0.3),
              bottomLeft: Radius.elliptical(r.width * 0.7, r.height * 0.7),
            ),
          ),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      oldDelegate.found != found || oldDelegate.grain != grain;
}

/// A drawn sample of an element or mineral in a 48 × 48 design box.
class _SamplePainter extends CustomPainter {
  const _SamplePainter(this.look);

  final _Look look;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 48;
    canvas.save();
    canvas.translate(
      (size.width - 48 * scale) / 2,
      (size.height - 48 * scale) / 2,
    );
    canvas.scale(scale);
    switch (look) {
      case _Look.goldIngot:
        _ingot(
          canvas,
          const Color(0xFFFEF3C7),
          _rt_Tw.amber400,
          _rt_Tw.amber700,
        );
      case _Look.silverIngot:
        _ingot(canvas, _rt_Tw.slate50, _rt_Tw.slate300, _rt_Tw.slate500);
      case _Look.magnesiumRibbon:
        _ribbon(canvas);
      case _Look.ironNail:
        _nail(canvas);
      case _Look.carbonLumps:
        _lumps(canvas);
      case _Look.sulfurPowder:
        _powder(canvas);
      case _Look.oxygenBubbles:
        _bubbles(canvas);
      case _Look.mercuryDrop:
        _drop(canvas);
      case _Look.goldNugget:
        _nugget(canvas, const [
          Color(0xFFFEF3C7),
          _rt_Tw.amber400,
          _rt_Tw.amber700,
        ]);
      case _Look.silverNugget:
        _nugget(canvas, const [
          _rt_Tw.slate50,
          _rt_Tw.slate300,
          _rt_Tw.slate500,
        ]);
      case _Look.copperNugget:
        _nugget(canvas, const [
          Color(0xFFFDBA74),
          Color(0xFFC2410C),
          _kOrange900,
        ]);
      case _Look.sulfurCrystals:
        _crystals(canvas);
      case _Look.quartzCrystal:
        _quartz(canvas);
      case _Look.calciteRhomb:
        _rhomb(canvas);
      case _Look.micaSheets:
        _sheets(canvas);
      case _Look.talcLump:
        _nugget(canvas, const [
          _rt_Tw.slate50,
          Color(0xFFD1FAE5),
          Color(0xFF94A3A0),
        ], shine: false);
      case _Look.ironOre:
        _nugget(
          canvas,
          const [Color(0xFFB45309), Color(0xFF7C2D12), Color(0xFF431407)],
          shine: false,
          specks: true,
        );
      case _Look.cubeIron:
      case _Look.cubeChromium:
      case _Look.cubeNickel:
      case _Look.cubeCarbon:
        break;
    }
    canvas.restore();
  }

  void _shadow(Canvas canvas, Rect rect) {
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  /// A metal bar: lit top face over a shaded front.
  void _ingot(Canvas canvas, Color light, Color mid, Color dark) {
    _shadow(canvas, const Rect.fromLTWH(4, 36, 40, 6));
    final front = Path()
      ..moveTo(6, 22)
      ..lineTo(42, 22)
      ..lineTo(46, 38)
      ..lineTo(2, 38)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [mid, dark],
        ).createShader(const Rect.fromLTWH(2, 22, 44, 16)),
    );
    final top = Path()
      ..moveTo(11, 12)
      ..lineTo(37, 12)
      ..lineTo(42, 22)
      ..lineTo(6, 22)
      ..close();
    canvas.drawPath(top, Paint()..color = light);
    // Lustre.
    canvas.drawLine(
      const Offset(14, 15),
      const Offset(26, 15),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  /// A coiled strip of magnesium ribbon.
  void _ribbon(Canvas canvas) {
    final path = Path()..moveTo(4, 30);
    for (var x = 4.0; x <= 44; x += 2) {
      path.lineTo(x, 26 + 9 * math.sin((x - 4) / 40 * math.pi * 2.5));
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = _rt_Tw.slate500,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = _rt_Tw.slate200,
    );
  }

  /// An iron nail.
  void _nail(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(10, 42, 28, 4));
    final shine = Paint()
      ..shader = const LinearGradient(
        colors: [_rt_Tw.slate400, _rt_Tw.slate600, _rt_Tw.slate700],
      ).createShader(const Rect.fromLTWH(12, 4, 24, 40));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 5, 24, 6),
        const Radius.circular(2),
      ),
      shine,
    );
    canvas.drawRect(const Rect.fromLTWH(21, 11, 6, 26), shine);
    canvas.drawPath(
      Path()
        ..moveTo(21, 37)
        ..lineTo(27, 37)
        ..lineTo(24, 45)
        ..close(),
      shine,
    );
    canvas.drawLine(
      const Offset(22.5, 12),
      const Offset(22.5, 35),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
  }

  /// Dull black lumps of carbon (no lustre).
  void _lumps(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(4, 38, 40, 6));
    for (final (points, color) in const [
      (
        [
          Offset(6, 38),
          Offset(9, 26),
          Offset(18, 22),
          Offset(24, 30),
          Offset(22, 40),
        ],
        Color(0xFF1F2937),
      ),
      (
        [
          Offset(20, 40),
          Offset(22, 24),
          Offset(32, 16),
          Offset(40, 24),
          Offset(38, 40),
        ],
        Color(0xFF111827),
      ),
      (
        [Offset(30, 42), Offset(33, 32), Offset(42, 30), Offset(45, 41)],
        Color(0xFF374151),
      ),
    ]) {
      final lump = Path()..addPolygon(points, true);
      canvas.drawPath(lump, Paint()..color = color);
      // A grey edge so the black lumps read on the dark card.
      canvas.drawPath(
        lump,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeJoin = StrokeJoin.round
          ..color = _rt_Tw.slate500,
      );
    }
  }

  /// A heap of yellow sulfur powder.
  void _powder(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(4, 38, 40, 6));
    final heap = Path()
      ..moveTo(4, 41)
      ..quadraticBezierTo(24, 6, 44, 41)
      ..close();
    canvas.drawPath(
      heap,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDE047), Color(0xFFCA8A04)],
        ).createShader(const Rect.fromLTWH(4, 18, 40, 23)),
    );
    final grain = Paint()..color = const Color(0xFFFEF08A);
    final random = math.Random(3);
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(12 + random.nextDouble() * 24, 28 + random.nextDouble() * 11),
        0.9,
        grain,
      );
    }
  }

  /// Gas bubbles: oxygen is a gas.
  void _bubbles(Canvas canvas) {
    for (final (centre, radius) in const [
      (Offset(17, 31), 9.0),
      (Offset(31, 20), 7.0),
      (Offset(33, 36), 5.5),
      (Offset(19, 14), 4.0),
    ]) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFF7DD3FC),
      );
      canvas.drawCircle(
        centre - Offset(radius * 0.4, radius * 0.4),
        radius * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  /// A shiny liquid drop over a puddle: mercury is a liquid metal.
  void _drop(Canvas canvas) {
    const puddle = Rect.fromLTWH(6, 34, 36, 10);
    canvas.drawOval(
      puddle,
      Paint()
        ..shader = const LinearGradient(
          colors: [_rt_Tw.slate300, _rt_Tw.slate500, _rt_Tw.slate300],
        ).createShader(puddle),
    );
    const ball = Rect.fromLTWH(14, 12, 20, 22);
    canvas.drawOval(
      ball,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [Colors.white, _rt_Tw.slate400, _rt_Tw.slate600],
        ).createShader(ball),
    );
    canvas.drawCircle(
      const Offset(20, 18),
      2.6,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  /// An irregular lump, optionally with a highlight (lustre) or specks.
  void _nugget(
    Canvas canvas,
    List<Color> colors, {
    bool shine = true,
    bool specks = false,
  }) {
    _shadow(canvas, const Rect.fromLTWH(6, 37, 36, 6));
    const radii = [15.0, 17.0, 13.5, 16.0, 14.0, 17.5, 12.5, 15.5];
    final path = Path();
    for (var i = 0; i <= radii.length; i++) {
      final angle = i / radii.length * math.pi * 2;
      final radius = radii[i % radii.length];
      final point = Offset(
        24 + radius * math.cos(angle),
        26 + radius * 0.8 * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: colors,
        ).createShader(const Rect.fromLTWH(6, 12, 36, 28)),
    );
    if (shine) {
      canvas.drawCircle(
        const Offset(18, 20),
        2.4,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
    if (specks) {
      final speck = Paint()..color = _rt_Tw.slate400.withValues(alpha: 0.8);
      for (final point in const [
        Offset(16, 28),
        Offset(26, 22),
        Offset(31, 31),
        Offset(21, 33),
        Offset(33, 24),
      ]) {
        canvas.drawCircle(point, 1.1, speck);
      }
    }
  }

  /// Pointed yellow sulfur crystals.
  void _crystals(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(6, 38, 36, 6));
    for (final (points, color) in const [
      ([Offset(8, 41), Offset(12, 22), Offset(18, 41)], Color(0xFFEAB308)),
      ([Offset(15, 41), Offset(24, 8), Offset(32, 41)], Color(0xFFFACC15)),
      ([Offset(28, 41), Offset(37, 18), Offset(42, 41)], Color(0xFFCA8A04)),
    ]) {
      canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = color);
    }
    canvas.drawLine(
      const Offset(24, 10),
      const Offset(24, 40),
      Paint()
        ..color = const Color(0xFFFEF08A)
        ..strokeWidth = 1,
    );
  }

  /// A clear six-sided quartz crystal.
  void _quartz(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(10, 40, 28, 5));
    final body = Path()
      ..addPolygon(const [
        Offset(16, 42),
        Offset(16, 18),
        Offset(24, 5),
        Offset(32, 18),
        Offset(32, 42),
      ], true);
    canvas.drawPath(
      body,
      Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.85),
    );
    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _rt_Tw.slate400;
    canvas.drawPath(body, facet);
    canvas.drawLine(const Offset(24, 5), const Offset(24, 42), facet);
    canvas.drawLine(const Offset(16, 18), const Offset(32, 18), facet);
    canvas.drawLine(
      const Offset(19, 22),
      const Offset(19, 38),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.4,
    );
  }

  /// A calcite rhombohedron.
  void _rhomb(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(8, 39, 34, 5));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFFCA8A04).withValues(alpha: 0.6);
    for (final (points, color) in const [
      (
        [Offset(8, 20), Offset(28, 20), Offset(34, 40), Offset(14, 40)],
        Color(0xFFFEF08A),
      ),
      (
        [Offset(8, 20), Offset(16, 9), Offset(36, 9), Offset(28, 20)],
        Color(0xFFFEFCE8),
      ),
      (
        [Offset(28, 20), Offset(36, 9), Offset(42, 29), Offset(34, 40)],
        Color(0xFFFDE68A),
      ),
    ]) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, edge);
    }
  }

  /// Stacked thin sheets of mica.
  void _sheets(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(6, 38, 36, 6));
    for (var i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(7.0 + i, 34.0 - i * 5, 34, 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = i.isEven ? _kStone700 : _kStone500,
      );
      canvas.drawLine(
        rect.topLeft + const Offset(2, 0.5),
        rect.topRight - const Offset(2, -0.5),
        Paint()
          ..color = const Color(0xFFD6D3D1).withValues(alpha: 0.8)
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SamplePainter oldDelegate) =>
      oldDelegate.look != look;
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
