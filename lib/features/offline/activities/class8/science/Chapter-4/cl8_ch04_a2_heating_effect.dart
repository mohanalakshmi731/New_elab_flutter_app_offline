// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 4.2: Heating Effect of Electric Current
// Converted from Cl8S-Ch4-A2-Heating_Effect_of_Electric_Current.html
// (canvas-2D circuit sim + DOM heater overlay -> CustomPainter + widgets).
//
// Two scenarios chosen from the sidebar. Scenario 1 "Nichrome Wire Circuit"
// (Activity 4.5): drag Battery, Switch and Nichrome wire from the palette,
// connect them into a loop, turn the switch ON, watch a 30 s timer while the
// wire heats from grey to red (heat-haze pulse at 30 s), then "touch" the
// wire to feel it hot. Scenario 2 "Household Heating Appliances": inspect
// appliances, pick the Room Heater, watch the grille drop, identify the
// tubular heating element, plug the cord into the wall socket and switch the
// heater ON so the element glows red. The nodal relaxation solver, component
// resistances, step validation and observation notes match the source.





// --- TRANSLATION DATA (copied from the source i18n block; te ignored) ---

import 'dart:async';
import 'dart:math' as math;


import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
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
    'main_title': 'Heating Effect of Electric Current',
    'main_subtitle': 'Class 8 • Electricity: Magnetic and Heating Effects',
    'enter_lab': 'Enter _rt_Lab',
    'controls': 'Controls',
    'voltage': 'Voltage',
    'thermal': 'THERMAL',
    'realistic': 'REALISTIC',
    'schematic': 'SCHEMATIC',
    'selection': 'Selection',
    'delete': 'Delete',
    'wire': 'Wire',
    'battery': 'Battery',
    'switch': 'Switch',
    'nichrome': 'Nichrome',
    'obs_complete': 'Observation Complete',
    'select_scenario': 'Select Scenario',
    'theory': 'Theory',
    'procedural_steps': 'Procedural Steps',
    'inv_complete': 'Investigation Complete! Check the observation notes.',
    'msg_hot': 'The wire feels extremely hot!',
    's1': {
      'title': 'Activity 4.5: Nichrome Wire Circuit',
      'theory':
          'When an electric current passes through a conductor, it faces some opposition or resistance. This resistance causes electrical energy to convert into heat energy. This is known as the heating effect of electric current.',
      'conclusion':
          'Activity Successful: The nichrome wire glowed red and felt very hot to the touch. This practically demonstrates that the flow of electric current generates heat due to resistance.',
      'steps': [
        {
          'desc':
              'Theory & Setup: We need to build a closed circuit to allow current to flow. The Nichrome wire acts as our high-resistance conductor.\nAction: Drag a Battery, a Switch, and a Nichrome wire onto the canvas from the left palette and connect them.',
          'hud': 'Drag Battery, Switch, and Nichrome Wire to the canvas.',
        },
        {
          'desc':
              'Circuit Assembly: A closed circuit is required for electricity to flow.\nAction: Ensure the components are connected in a loop. Leave the switch in the OFF position.',
          'hud': 'Connect the components together. Keep the switch OFF.',
        },
        {
          'desc':
              "Activation & Observation: The switch is currently in the OFF position. A digital timer reads 00:00.\nAction: Click the Switch to move it to the ON position.\nResponse: The timer auto-starts. Wait until 30s. At 30s, the Nichrome wire applies a subtle 'heat haze' visual effect.",
          'hud': 'Turn switch ON. Wait 30 seconds to observe the heat haze effect.',
        },
        {
          'desc':
              "Sensory Verification: If the heating effect occurred, the nichrome wire should now have an elevated temperature.\nAction: Click, tap, or hover your hand cursor over the wire to 'touch' it.",
          'hud': 'Click, tap, or hover over the wire to perform a sensory check.',
        },
      ],
    },
    's2': {
      'title': 'Household Heating Appliances',
      'theory':
          'Household appliances like room heaters, electric irons, and kettles contain a special coil of wire called a heating element. When electric current is switched on, this element glows red hot to provide heat.',
      'conclusion':
          'Observation Confirmed: The element is now visibly red hot due to the heating effect of electric current passing through the high-resistance coil.',
      'steps': [
        {
          'desc':
              "Theory & Setup: Appliances like electric room heaters contain a coil of wire called a heating element. When switched on, this element glows red hot.\nAction: Click the button labeled 'Inspect Appliances'.",
          'hud': "Click 'Inspect Appliances' to begin.",
        },
        {
          'desc':
              'Appliance Selection: Three common heating appliances are displayed: An Electric Iron, an Electric Room Heater, and an Electric Kettle.\nAction: Click the Electric Room Heater.',
          'hud': 'Select the Electric Room Heater from the options.',
        },
        {
          'desc':
              'Internal Inspection: The front grille of the heater drops away to reveal the internal heating components.\nAction: Identify the heating component by clicking on the metallic tubular coiled structure.',
          'hud': 'Click on the tubular heating coil inside the heater.',
        },
        {
          'desc':
              "Operation: A power plug is now visible near a wall socket.\nAction: Drag the plug into the socket and click the appliance's rotary switch.\nResponse: The identified Heating Element changes color from metallic grey to an intense glowing red/orange.",
          'hud': 'Drag the plug to the socket, then click the appliance switch to turn it ON.',
        },
      ],
      'btn_inspect': 'Inspect Appliances',
      'lbl_select': 'Select an Appliance',
      'iron': 'Electric Iron',
      'heater': 'Room Heater',
      'kettle': 'Electric Kettle',
      'msg_wrong': 'Try the Electric Room Heater.',
      'msg_element': 'Heating Element',
      'msg_plug': 'Plug it into the socket first!',
    },
    // Helper strings for controls the native port adds (drag alternatives).
    'ui': {
      'connect': 'Connect Circuit',
      'connected': 'Components connected in a loop!',
      'nothingToConnect': 'Add components first!',
      'toggle_switch': 'Toggle Switch',
      'touch_wire': 'Touch the Wire',
      'plug_in': 'Plug In',
      'placed': 'Placed Components',
      'empty': 'No components yet — tap the palette on the canvas.',
      'labels': 'Toggle Labels',
      'timer': 'Timer',
    },
  },
  'hi': {
    'main_title': 'विद्युत धारा का तापन प्रभाव',
    'main_subtitle': 'कक्षा 8 • विद्युत: चुंबकीय और तापीय प्रभाव',
    'enter_lab': 'प्रयोगशाला में प्रवेश करें',
    'controls': 'नियंत्रण',
    'voltage': 'वोल्टेज',
    'thermal': 'तापीय (THERMAL)',
    'realistic': 'वास्तविक (REAL)',
    'schematic': 'योजनाबद्ध (SCH)',
    'selection': 'चयन',
    'delete': 'हटाएं',
    'wire': 'तार',
    'battery': 'बैटरी',
    'switch': 'स्विच',
    'nichrome': 'नाइक्रोम',
    'obs_complete': 'अवलोकन पूरा हुआ',
    'select_scenario': 'परिदृश्य चुनें',
    'theory': 'सिद्धांत',
    'procedural_steps': 'प्रक्रियात्मक कदम',
    'inv_complete': 'जांच पूरी हुई! अवलोकन नोट्स जांचें।',
    'msg_hot': 'तार बहुत गर्म महसूस होता है!',
    's1': {
      'title': 'गतिविधि 4.5: नाइक्रोम तार सर्किट',
      'theory':
          'जब विद्युत धारा किसी चालक से गुजरती है, तो उसे कुछ विरोध या प्रतिरोध का सामना करना पड़ता है। इस प्रतिरोध के कारण विद्युत ऊर्जा ऊष्मा ऊर्जा में परिवर्तित हो जाती है। इसे विद्युत धारा का तापीय प्रभाव कहा जाता है।',
      'conclusion':
          'गतिविधि सफल: नाइक्रोम का तार लाल चमकने लगा और छूने पर बहुत गर्म महसूस हुआ। यह व्यावहारिक रूप से प्रदर्शित करता है कि विद्युत धारा का प्रवाह प्रतिरोध के कारण ऊष्मा उत्पन्न करता है।',
      'steps': [
        {
          'desc':
              'सिद्धांत और सेटअप: हमें धारा प्रवाहित होने देने के लिए एक बंद सर्किट बनाना होगा। नाइक्रोम तार हमारे उच्च-प्रतिरोध चालक के रूप में कार्य करता है।\nकार्रवाई: बाएं पैलेट से एक बैटरी, एक स्विच और एक नाइक्रोम तार को कैनवास पर खींचें और उन्हें कनेक्ट करें।',
          'hud': 'बैटरी, स्विच और नाइक्रोम तार को कैनवास पर खींचें।',
        },
        {
          'desc':
              'सर्किट असेंबली: बिजली प्रवाहित होने के लिए एक बंद सर्किट की आवश्यकता होती है।\nकार्रवाई: सुनिश्चित करें कि घटक एक लूप में जुड़े हुए हैं। स्विच को OFF स्थिति में छोड़ दें।',
          'hud': 'घटकों को एक साथ जोड़ें। स्विच को OFF रखें।',
        },
        {
          'desc':
              "सक्रियण और अवलोकन: स्विच वर्तमान में OFF स्थिति में है। एक डिजिटल टाइमर 00:00 पढ़ता है।\nकार्रवाई: स्विच को चालू (ON) स्थिति में ले जाने के लिए उस पर क्लिक करें।\nप्रतिक्रिया: टाइमर स्वतः प्रारंभ हो जाता है। 30 सेकंड तक प्रतीक्षा करें। 30 सेकंड पर, नाइक्रोम तार एक सूक्ष्म 'हीट हेज़' दृश्य प्रभाव लागू करता है।",
          'hud': 'स्विच चालू करें। हीट हेज़ प्रभाव देखने के लिए 30 सेकंड प्रतीक्षा करें।',
        },
        {
          'desc':
              "संवेदी सत्यापन: यदि तापन प्रभाव हुआ है, तो नाइक्रोम तार का तापमान अब बढ़ा हुआ होना चाहिए।\nकार्रवाई: तार को 'छूने' के लिए उस पर क्लिक करें, टैप करें या अपने हाथ के कर्सर को घुमाएं।",
          'hud': 'संवेदी जांच करने के लिए तार पर क्लिक करें, टैप करें या होवर करें।',
        },
      ],
    },
    's2': {
      'title': 'घरेलू तापन उपकरण',
      'theory':
          'रूम हीटर, इलेक्ट्रिक आयरन और केतली जैसे घरेलू उपकरणों में तार की एक विशेष कुंडली होती है जिसे हीटिंग तत्व कहा जाता है। जब विद्युत प्रवाह चालू किया जाता है, तो यह तत्व ऊष्मा प्रदान करने के लिए लाल गर्म हो जाता है।',
      'conclusion':
          'अवलोकन की पुष्टि: उच्च-प्रतिरोध कॉइल से गुजरने वाले विद्युत प्रवाह के तापन प्रभाव के कारण तत्व अब स्पष्ट रूप से लाल गर्म है।',
      'steps': [
        {
          'desc':
              "सिद्धांत और सेटअप: इलेक्ट्रिक रूम हीटर जैसे उपकरणों में तार की एक कुंडली होती है जिसे हीटिंग तत्व कहा जाता है। चालू होने पर, यह तत्व लाल गर्म चमकता है।\nकार्रवाई: 'उपकरणों का निरीक्षण करें' लेबल वाले बटन पर क्लिक करें।",
          'hud': "आरंभ करने के लिए 'उपकरणों का निरीक्षण करें' पर क्लिक करें।",
        },
        {
          'desc':
              'उपकरण चयन: तीन सामान्य तापन उपकरण प्रदर्शित किए गए हैं: एक इलेक्ट्रिक आयरन, एक इलेक्ट्रिक रूम हीटर, और एक इलेक्ट्रिक केतली।\nकार्रवाई: इलेक्ट्रिक रूम हीटर पर क्लिक करें।',
          'hud': 'विकल्पों में से इलेक्ट्रिक रूम हीटर का चयन करें।',
        },
        {
          'desc':
              'आंतरिक निरीक्षण: आंतरिक तापन घटकों को प्रकट करने के लिए हीटर की सामने की जाली नीचे गिर जाती है।\nकार्रवाई: धातु की ट्यूबलर कुंडलित संरचना पर क्लिक करके हीटिंग घटक को पहचानें।',
          'hud': 'हीटर के अंदर ट्यूबलर हीटिंग कॉइल पर क्लिक करें।',
        },
        {
          'desc':
              'संचालन: दीवार सॉकेट के पास अब एक पावर प्लग दिखाई दे रहा है।\nकार्रवाई: प्लग को सॉकेट में खींचें और उपकरण के रोटरी स्विच पर क्लिक करें।\nप्रतिक्रिया: पहचाना गया हीटिंग तत्व रंग में धातुई ग्रे से तीव्र चमकते लाल/नारंगी में बदल जाता है।',
          'hud': 'प्लग को सॉकेट तक खींचें, फिर इसे चालू करने के लिए उपकरण स्विच पर क्लिक करें।',
        },
      ],
      'btn_inspect': 'उपकरणों का निरीक्षण करें',
      'lbl_select': 'एक उपकरण चुनें',
      'iron': 'इलेक्ट्रिक आयरन',
      'heater': 'रूम हीटर',
      'kettle': 'इलेक्ट्रिक केतली',
      'msg_wrong': 'इलेक्ट्रिक रूम हीटर का प्रयास करें।',
      'msg_element': 'हीटिंग तत्व (Heating Element)',
      'msg_plug': 'इसे पहले सॉकेट में प्लग करें!',
    },
    'ui': {
      'connect': 'परिपथ जोड़ें',
      'connected': 'घटक एक लूप में जुड़ गए!',
      'nothingToConnect': 'पहले घटक जोड़ें!',
      'toggle_switch': 'स्विच दबाएँ',
      'touch_wire': 'तार को छुएँ',
      'plug_in': 'प्लग लगाएँ',
      'placed': 'रखे गए घटक',
      'empty': 'अभी कोई घटक नहीं — कैनवास पर पैलेट टैप करें।',
      'labels': 'लेबल टॉगल करें',
      'timer': 'टाइमर',
    },
  },
});

// ------------------------------------------------------------ models ----

class _Node {
  _Node(this.x, this.y);
  double x, y;
  double voltage = 0;
}

/// Mirrors the source `Component` class (wire | battery | switch; a nichrome
/// element is a wire with `material == 'nichrome'`).
class _Comp {
  _Comp(this.type, double x, double y)
      : n1 = _Node(x, y),
        n2 = _Node(x + 80, y);

  final String type;
  _Node n1, n2;
  double value = 10;
  double power = 0;
  double current = 0;
  String material = 'copper';
  bool isOpen = false;
  String labelKey = '';

  bool get isNichrome => material == 'nichrome';

  double get resistance {
    if (type == 'wire') return isNichrome ? 5 : 0.05;
    if (type == 'switch') return isOpen ? 1e8 : 0.05;
    if (type == 'battery') return 0.5;
    return value;
  }

  double get sourceVoltage => type == 'battery' ? value : 0;
}

class _PalItem {
  const _PalItem(this.labelKey, this.icon, this.make);
  final String labelKey;
  final IconData icon;
  final _Comp Function(double x, double y) make;
}

// -------------------------------------------------------------- page ----

class Cl8Ch04A2HeatingEffectPage extends StatefulWidget {
  const Cl8Ch04A2HeatingEffectPage({super.key});

  @override
  State<Cl8Ch04A2HeatingEffectPage> createState() => _Cl8Ch04A2HeatingEffectPageState();
}

class _Cl8Ch04A2HeatingEffectPageState extends State<Cl8Ch04A2HeatingEffectPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final GlobalKey _canvasKey = GlobalKey();
  final _RepaintNotifier _repaint = _RepaintNotifier();

  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastElapsed = Duration.zero;

  // Cancels pending delayed callbacks after a restart / scenario switch.
  int _epoch = 0;

  // --- global activity state (the source `State` object) ---
  int _scenario = 1;
  int _step = 1;
  bool _completed = false;
  double _heatTimer = 0; // seconds of real time; 10 s real = 30 s displayed
  bool _touched = false;
  bool _popupShown = false;
  bool _validating = false;
  bool _hazeOn = false;
  int _timerSec = 0; // displayed second value (drives rebuilds)

  // --- scenario 1: circuit state ---
  final List<_Comp> _comps = [];
  final List<_Node> _nodes = [];
  _Comp? _selection;
  double _time = 0;
  int _spawnN = 0;
  Size _canvasSize = const Size(600, 400);
  double _zoomLv = 1;
  Offset _viewOffset = Offset.zero;
  bool _thermal = false;
  bool _schematic = false;
  bool _showLabels = true;
  double _voltage = 10;
  bool _simClosed = false;

  // Drag state
  _Node? _dragNode;
  _Comp? _dragComp;
  Offset _dragOff1 = Offset.zero, _dragOff2 = Offset.zero;
  Offset? _panStartView;
  Offset _panStartLocal = Offset.zero;

  // --- scenario 2: heater state ---
  bool _s2GrilleOpen = false;
  bool _s2Plugged = false;
  bool _s2On = false;
  Offset? _s2PlugPos; // top-left of the plug inside the canvas stack

  // ------------------------------------------------------- lifecycle ----
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
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  // --------------------------------------------------------- physics ----
  /// One simulation frame: the source's `loop()` (relaxation solver, closed
  /// circuit detection, step-3 heat timer) minus drawing, which the painter
  /// handles through [_repaint].
  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastElapsed = elapsed;
    _time += dt;

    if (_scenario != 1) {
      _repaint.tick();
      return;
    }

    for (var k = 0; k < 25; k++) {
      for (final n in _nodes) {
        double num = 0, den = 0;
        for (final c in _comps) {
          _Node? other;
          var isN1 = false;
          if (identical(c.n1, n)) {
            other = c.n2;
            isN1 = true;
          } else if (identical(c.n2, n)) {
            other = c.n1;
          }
          if (other != null) {
            final g = 1 / c.resistance;
            final target = other.voltage + c.sourceVoltage * (isN1 ? -1 : 1);
            num += target * g;
            den += g;
          }
        }
        if (den > 1e-5) {
          n.voltage = num / den;
        } else {
          n.voltage *= 0.95;
        }
      }
    }

    var isClosed = false;
    for (final c in _comps) {
      final v = (c.n2.voltage - c.n1.voltage - c.sourceVoltage).abs();
      c.current = v / c.resistance;
      c.power = c.current * c.current * c.resistance;
      if (c.current.abs() > 0.1) isClosed = true;
    }

    if (isClosed != _simClosed) {
      _simClosed = isClosed;
      setState(() {});
    }

    // Step validation (the source's auto-validation hook).
    if (!_completed && !_validating) {
      if (_step == 1) {
        final hasBatt = _comps.any((c) => c.type == 'battery');
        final hasSwitch = _comps.any((c) => c.type == 'switch');
        final hasNichrome = _comps.any((c) => c.isNichrome);
        if (hasBatt && hasSwitch && hasNichrome) _passStep();
      } else if (_step == 2) {
        if (isClosed && _comps.any((c) => c.type == 'switch' && !c.isOpen)) _passStep();
      } else if (_step == 3) {
        if (isClosed) {
          _heatTimer += dt;
        } else {
          _heatTimer = 0;
        }
        final sec = math.min(30, (_heatTimer * 3).floor());
        if (sec != _timerSec) setState(() => _timerSec = sec);
        if (_heatTimer >= 10 && !_hazeOn) {
          _hazeOn = true; // heat haze appears at the 30 s mark
          _rt_playSfx(_rt_Sfx.magic);
        }
        if (_heatTimer > 10) _passStep(sound: null); // magic just played
      }
      // Step 4 passes through _touchWire (tap on the wire / sidebar button).
    }

    _repaint.tick();
  }

  /// Advances after the source's 1 s "register the outcome" delay.
  void _passStep({_rt_Sfx? sound = _rt_Sfx.correct}) {
    if (_validating || _completed) return;
    _validating = true;
    if (sound != null) _rt_playSfx(sound);
    final epoch = _epoch;
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted || epoch != _epoch) return;
      _validating = false;
      _advanceStep();
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
      if (_step > 4) {
        _completed = true;
      }
      if (_scenario == 2 && _step == 3) {
        // Grille animates away shortly after entering step 3.
        final epoch = _epoch;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted || epoch != _epoch) return;
          _rt_playSfx(_rt_Sfx.pop);
          setState(() => _s2GrilleOpen = true);
        });
      }
    });
    if (_completed) _schedulePopup();
  }

  /// Observation popup, delayed like the source (4 s scenario 1, 2 s scenario 2).
  void _schedulePopup() {
    if (_popupShown) return;
    _popupShown = true;
    final epoch = _epoch;
    final delay = _scenario == 2 ? 2000 : 4000;
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted || epoch != _epoch) return;
      _shell.showSuccess(
        title: _tx.s('obs_complete'),
        message: _tx.s(_scenario == 1 ? 's1.conclusion' : 's2.conclusion'),
        icon: Icons.check_circle,
        color: _rt_Tw.green500,
      );
    });
  }

  // ------------------------------------------------- scenario switch ----
  void _loadScenario(int id) {
    _epoch++;
    setState(() {
      _scenario = id;
      _step = 1;
      _completed = false;
      _heatTimer = 0;
      _timerSec = 0;
      _touched = false;
      _popupShown = false;
      _validating = false;
      _hazeOn = false;
      // Scenario 1 canvas.
      _comps.clear();
      _nodes.clear();
      _selection = null;
      _dragNode = null;
      _dragComp = null;
      _simClosed = false;
      _zoomLv = 1;
      _viewOffset = Offset.zero;
      // Scenario 2 heater.
      _s2GrilleOpen = false;
      _s2Plugged = false;
      _s2On = false;
      _s2PlugPos = null;
    });
  }

  void _hardReset() {
    _epoch++;
    setState(() {
      _thermal = false;
      _schematic = false;
      _showLabels = true;
      _voltage = 10;
      _spawnN = 0;
      _time = 0;
    });
    _loadScenario(1);
  }

  // --------------------------------------------------------- palette ----
  List<_PalItem> get _palette => [
        _PalItem('wire', Icons.horizontal_rule, (x, y) => _Comp('wire', x, y)..labelKey = 'wire'),
        _PalItem(
            'battery',
            Icons.battery_full,
            (x, y) => _Comp('battery', x, y)
              ..labelKey = 'battery'
              ..value = _voltage),
        _PalItem(
            'switch',
            Icons.toggle_off,
            (x, y) => _Comp('switch', x, y)
              ..labelKey = 'switch'
              ..isOpen = true),
        _PalItem(
            'nichrome',
            Icons.waves,
            (x, y) => _Comp('wire', x, y)
              ..labelKey = 'nichrome'
              ..material = 'nichrome'),
      ];

  void _addFromPalette(_PalItem item, [Offset? world]) {
    final pos = world ??
        _toWorld(Offset(_canvasSize.width / 2, _canvasSize.height / 2)) +
            Offset(0, ((_spawnN % 5) - 2) * 36.0);
    _spawnN++;
    final c = item.make(pos.dx - 40, pos.dy);
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _comps.add(c);
      _nodes.addAll([c.n1, c.n2]);
    });
  }

  /// Sidebar helper: joins every placed component into a series ring — the
  /// button equivalent of dragging the terminal nodes together on the canvas.
  void _connectCircuit() {
    if (_comps.isEmpty) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(_tx.s('ui.nothingToConnect'), color: _rt_Tw.red500, icon: Icons.error_outline);
      return;
    }
    _nodes.clear();
    const l = 130.0, t = 120.0, r = 500.0, b = 290.0;
    final w = r - l, h = b - t, per = 2 * (w + h);
    _Node at(double f) {
      var d = f * per;
      if (d < w) return _Node(l + d, t);
      d -= w;
      if (d < h) return _Node(r, t + d);
      d -= h;
      if (d < w) return _Node(r - d, b);
      d -= w;
      return _Node(l, b - d);
    }

    final pts = [for (var i = 0; i < _comps.length; i++) at(i / _comps.length)];
    for (var i = 0; i < _comps.length; i++) {
      _comps[i].n1 = pts[i];
      _comps[i].n2 = pts[(i + 1) % _comps.length];
    }
    _nodes.addAll(pts);
    for (final n in _nodes) {
      n.voltage = 0;
    }
    _rt_playSfx(_rt_Sfx.pop);
    _shell.showToast(_tx.s('ui.connected'), color: _rt_Tw.green500, icon: Icons.link);
    setState(() {});
  }

  void _toggleFirstSwitch() {
    final sw = _comps.where((c) => c.type == 'switch').toList();
    if (sw.isEmpty) return;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => sw.first.isOpen = !sw.first.isOpen);
  }

  /// Sensory check on the hot nichrome wire (source step 4 tap/hover).
  void _touchWire() {
    if (_scenario != 1 || _step != 4 || !_simClosed) return;
    _rt_playSfx(_rt_Sfx.pop);
    _shell.showToast(_tx.s('msg_hot'), color: _rt_Tw.orange500, icon: Icons.back_hand);
    if (!_touched) {
      _touched = true;
      final epoch = _epoch;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || epoch != _epoch) return;
        if (_step == 4 && !_completed) _passStep();
      });
    }
  }

  void _deleteSelection() {
    final sel = _selection;
    if (sel == null) return;
    setState(() {
      _comps.remove(sel);
      _selection = null;
      final used = <_Node>{};
      for (final c in _comps) {
        used.addAll([c.n1, c.n2]);
      }
      _nodes.removeWhere((n) => !used.contains(n));
    });
  }

  // ---------------------------------------------------- canvas input ----
  Offset _toWorld(Offset local) => (local - _viewOffset) / _zoomLv;

  _Node? _hitNode(Offset world) {
    final thresh = 20 / _zoomLv;
    _Node? hit;
    var minD = 100.0;
    for (final n in _nodes) {
      final d = (Offset(n.x, n.y) - world).distance;
      if (d < thresh && d < minD) {
        minD = d;
        hit = n;
      }
    }
    return hit;
  }

  _Comp? _hitComp(Offset world, {double slop = 20}) {
    final thresh = slop / _zoomLv;
    _Comp? hit;
    for (final c in _comps) {
      final a = Offset(c.n1.x, c.n1.y), b = Offset(c.n2.x, c.n2.y);
      final l2 = (b - a).distanceSquared;
      var t = l2 == 0 ? 0.0 : ((world - a).dx * (b - a).dx + (world - a).dy * (b - a).dy) / l2;
      t = t.clamp(0.0, 1.0);
      final d = (world - (a + (b - a) * t)).distance;
      if (d < thresh) hit = c;
    }
    return hit;
  }

  void _onTapUp(TapUpDetails d) {
    final world = _toWorld(d.localPosition);
    // Step 4: a generous-threshold tap on the nichrome wire = touching it.
    if (_step == 4 && !_completed) {
      final hot = _hitComp(world, slop: 35);
      if (hot != null && hot.isNichrome && _simClosed) {
        _touchWire();
        return;
      }
    }
    if (_hitNode(world) != null) return;
    final hitC = _hitComp(world);
    if (hitC != null) {
      setState(() => _selection = hitC);
      if (hitC.type == 'switch') {
        hitC.isOpen = !hitC.isOpen;
        _rt_playSfx(_rt_Sfx.toggle);
      } else {
        _rt_playSfx(_rt_Sfx.tap);
      }
    } else {
      setState(() => _selection = null);
    }
  }

  void _onPanStart(DragStartDetails d) {
    final world = _toWorld(d.localPosition);
    final hitN = _hitNode(world);
    if (hitN != null) {
      _dragNode = hitN;
      _rt_playSfx(_rt_Sfx.tap, volume: 0.5);
      return;
    }
    final hitC = _hitComp(world);
    if (hitC != null) {
      _dragComp = hitC;
      _dragOff1 = Offset(hitC.n1.x, hitC.n1.y) - world;
      _dragOff2 = Offset(hitC.n2.x, hitC.n2.y) - world;
      setState(() => _selection = hitC);
      _rt_playSfx(_rt_Sfx.tap, volume: 0.5);
      return;
    }
    // Background drag pans the viewport (source's pan mode).
    _panStartView = _viewOffset;
    _panStartLocal = d.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragNode != null) {
      final world = _toWorld(d.localPosition);
      _dragNode!.x = world.dx;
      _dragNode!.y = world.dy;
    } else if (_dragComp != null) {
      final world = _toWorld(d.localPosition);
      final c = _dragComp!;
      c.n1.x = world.dx + _dragOff1.dx;
      c.n1.y = world.dy + _dragOff1.dy;
      c.n2.x = world.dx + _dragOff2.dx;
      c.n2.y = world.dy + _dragOff2.dy;
    } else if (_panStartView != null) {
      _viewOffset = _panStartView! + (d.localPosition - _panStartLocal);
    }
  }

  void _onPanEnd(DragEndDetails d) {
    final toCheck = <_Node>[
      ?_dragNode,
      if (_dragComp != null) ...[_dragComp!.n1, _dragComp!.n2],
    ];
    for (final n in toCheck) {
      for (final o in _nodes) {
        if (!identical(o, n) &&
            math.sqrt((o.x - n.x) * (o.x - n.x) + (o.y - n.y) * (o.y - n.y)) < 20) {
          n.x = o.x;
          n.y = o.y;
          for (final c in _comps) {
            if (identical(c.n1, n)) c.n1 = o;
            if (identical(c.n2, n)) c.n2 = o;
          }
          _nodes.remove(n);
          _rt_playSfx(_rt_Sfx.pop); // node snap
          break;
        }
      }
    }
    _dragNode = null;
    _dragComp = null;
    _panStartView = null;
    setState(() {});
  }

  void _zoomBy(double factor) {
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final world = (center - _viewOffset) / _zoomLv;
    final target = (_zoomLv * factor).clamp(0.5, 3.0);
    setState(() {
      _zoomLv = target;
      _viewOffset = center - world * target;
    });
  }

  // ----------------------------------------------------- scenario 2 ----
  void _s2Inspect() {
    // _rt_ActionButton already played the click; advance like the source.
    _advanceStep();
  }

  void _s2WrongAppliance() {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(_tx.s('s2.msg_wrong'), color: _rt_Tw.red500, icon: Icons.block);
  }

  void _s2SelectHeater() {
    _rt_playSfx(_rt_Sfx.correct);
    _advanceStep();
  }

  void _s2TapCoil() {
    if (_scenario != 2 || _step != 3) return;
    _rt_playSfx(_rt_Sfx.correct);
    _shell.showToast(_tx.s('s2.msg_element'), color: _rt_Tw.yellow500, icon: Icons.bolt);
    _passStep(sound: null);
  }

  void _s2PlugIn(Rect socketRect) {
    if (_s2Plugged) return;
    _s2Plugged = true;
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s2PlugPos = Offset(socketRect.left - 44, socketRect.center.dy - 24);
    });
  }

  void _s2TapSwitch(Rect socketRect) {
    if (_scenario != 2 || _step != 4) return;
    if (!_s2Plugged) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(_tx.s('s2.msg_plug'), color: _rt_Tw.red500, icon: Icons.power_off);
      return;
    }
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _s2On = !_s2On);
    if (_s2On) {
      _rt_playSfx(_rt_Sfx.magic); // the coil ignites into a red glow
      final epoch = _epoch;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted || epoch != _epoch) return;
        if (_s2On && _step == 4 && !_completed) _passStep(sound: null);
      });
    }
  }

  // -------------------------------------------------------------- UI ----
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final sPre = _scenario == 1 ? 's1' : 's2';
          final hud = _completed
              ? _tx.s('inv_complete')
              : _tx.s('$sPre.steps.${math.min(_step, 4) - 1}.hud');
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('main_title'),
            subtitle: _tx.s('main_subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.yellow500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF4C0519)],
              headerSubtitleColor: _rt_Tw.amber200,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('main_title'),
              subtitle: _tx.s('main_subtitle'),
              buttonLabel: _tx.s('enter_lab'),
              icon: Icons.local_fire_department,
            ),
            onRestart: _hardReset,
            onZoomIn: _scenario == 1 ? () => _zoomBy(1.1) : null,
            onZoomOut: _scenario == 1 ? () => _zoomBy(0.9) : null,
            onResetView: _scenario == 1
                ? () => setState(() {
                      _zoomLv = 1;
                      _viewOffset = Offset.zero;
                    })
                : null,
            toolbarExtras: [
              if (_scenario == 1)
                _ToolbarToggle(
                  key: const ValueKey('labels-toggle'),
                  active: _showLabels,
                  icon: _showLabels ? Icons.label : Icons.label_off,
                  tooltip: _tx.s('ui.labels'),
                  onTap: () {
                    _rt_playSfx(_rt_Sfx.toggle);
                    setState(() => _showLabels = !_showLabels);
                  },
                ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('procedural_steps'),
                icon: Icons.bolt,
                builder: (_) => _sidebarTab(),
              ),
            ],
            sidebarTop: _scenarioSelector(),
            canvas: _scenario == 1 ? _buildCircuitCanvas() : _buildS2Canvas(),
            canvasOverlays: [
              // Top HUD instruction pill (the source `#hud-instruction`).
              Positioned(
                top: 10,
                left: 70,
                right: 70,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 560),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _rt_Lab.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(24),
                        border: const Border(
                            bottom: BorderSide(color: _rt_Tw.yellow500, width: 2)),
                        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _rt_Tw.yellow500.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.gps_fixed, size: 15, color: _rt_Tw.yellow500),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(hud,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _rt_Lab.text,
                                    height: 1.2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Digital timer (scenario 1, step 3, circuit closed).
              if (_scenario == 1 && _step == 3 && _simClosed)
                Positioned(
                  top: 58,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: _rt_Tw.slate900.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _rt_Tw.orange500.withValues(alpha: 0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: _rt_Tw.orange500.withValues(alpha: 0.3), blurRadius: 20),
                          ],
                        ),
                        child: Text(
                          '00:${_timerSec < 10 ? '0' : ''}$_timerSec',
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _rt_Tw.orange500),
                        ),
                      ),
                    ),
                  ),
                ),
              // Component palette (scenario 1 only; source `#tool-palette`).
              if (_scenario == 1) Positioned(left: 10, top: 64, bottom: 60, child: _paletteColumn()),
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------- scenario 1: canvas ----
  Widget _buildCircuitCanvas() {
    return LayoutBuilder(
      builder: (context, c) {
        _canvasSize = Size(c.maxWidth, c.maxHeight);
        return DragTarget<int>(
          onAcceptWithDetails: (d) {
            final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(d.offset + const Offset(28, 20));
            _addFromPalette(_palette[d.data], _toWorld(local));
          },
          builder: (context, _, _) => GestureDetector(
            key: _canvasKey,
            behavior: HitTestBehavior.opaque,
            onTapUp: _onTapUp,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: _CircuitPainter(this, _repaint),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }

  Widget _paletteColumn() {
    final items = _palette;
    return SingleChildScrollView(
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _rt_Lab.border),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Draggable<int>(
                data: i,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _rt_Tw.yellow500.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(items[i].icon, size: 22, color: _rt_Tw.slate900),
                  ),
                ),
                child: _paletteChip(items[i]),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _paletteChip(_PalItem item) {
    return GestureDetector(
      key: ValueKey('pal-${item.labelKey}'),
      onTap: () => _addFromPalette(item),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Column(
          children: [
            Icon(item.icon,
                size: 18, color: item.labelKey == 'nichrome' ? _rt_Tw.orange400 : _rt_Tw.yellow400),
            const SizedBox(height: 2),
            Text(
              _tx.s(item.labelKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _rt_Lab.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------- scenario 2: heater ----
  Widget _buildS2Canvas() {
    return Container(
      color: _rt_Tw.slate900,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return switch (_step) {
            1 => _s2Step1(),
            2 => _s2Step2(),
            _ => _s2Step34(size),
          };
        },
      ),
    );
  }

  Widget _s2Step1() {
    return Center(
      child: FilledButton.icon(
        key: const ValueKey('btn-inspect'),
        style: FilledButton.styleFrom(
          backgroundColor: _rt_Tw.yellow500,
          foregroundColor: _rt_Tw.slate900,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
        ),
        onPressed: () {
          _rt_playSfx(_rt_Sfx.click);
          _s2Inspect();
        },
        icon: const Icon(Icons.search),
        label: Text(_tx.s('s2.btn_inspect'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _s2Step2() {
    Widget card(String key, String label, IconData icon, Color iconColor, VoidCallback onTap) {
      return GestureDetector(
        key: ValueKey(key),
        onTap: onTap,
        child: Container(
          width: 130,
          height: 160,
          decoration: BoxDecoration(
            color: _rt_Tw.slate800,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rt_Tw.slate700, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 52, color: iconColor),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
      child: Column(
        children: [
          Text(_tx.s('s2.lbl_select'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              card('app-iron', _tx.s('s2.iron'), Icons.iron, _rt_Tw.purple500, _s2WrongAppliance),
              card('app-heater', _tx.s('s2.heater'), Icons.local_fire_department, _rt_Tw.orange500,
                  _s2SelectHeater),
              card('app-kettle', _tx.s('s2.kettle'), Icons.coffee, _rt_Tw.emerald400,
                  _s2WrongAppliance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _s2Step34(Size size) {
    final heaterH = math.min(300.0, size.height - 90);
    final heaterW = heaterH * 0.75;
    final heaterRect = Rect.fromLTWH(
        math.min(50.0, size.width * 0.06), math.max(56.0, (size.height - heaterH) / 2),
        heaterW, heaterH);
    final socketRect = Rect.fromLTWH(size.width - 100, size.height / 2 - 42, 60, 84);
    _s2PlugPos ??= Offset(size.width * 0.45, size.height * 0.78);
    final showPlug = _step >= 4;

    return Stack(
      children: [
        // Sagging power cord.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CordPainter(
                start: Offset(heaterRect.right - 24, heaterRect.bottom - 14),
                end: showPlug
                    ? _s2PlugPos! + const Offset(0, 24)
                    : Offset(heaterRect.right + 26, heaterRect.bottom + 36),
              ),
            ),
          ),
        ),
        // Heater device.
        Positioned.fromRect(rect: heaterRect, child: _heaterDevice()),
        // Wall socket (step 4 only, like the source).
        if (showPlug)
          Positioned.fromRect(
            rect: socketRect,
            child: Container(
              decoration: BoxDecoration(
                color: _rt_Tw.gray100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _rt_Tw.slate300),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socketHole(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_socketHole(), const SizedBox(width: 12), _socketHole()],
                  ),
                ],
              ),
            ),
          ),
        // Draggable plug (step 4 only).
        if (showPlug)
          Positioned(
            left: _s2PlugPos!.dx,
            top: _s2PlugPos!.dy,
            child: GestureDetector(
              key: const ValueKey('plug'),
              onPanStart: _s2Plugged ? null : (_) => _rt_playSfx(_rt_Sfx.tap, volume: 0.5),
              onPanUpdate: _s2Plugged
                  ? null
                  : (d) => setState(() => _s2PlugPos = _s2PlugPos! + d.delta),
              onPanEnd: _s2Plugged
                  ? null
                  : (_) {
                      final plugCenter = _s2PlugPos! + const Offset(28, 24);
                      if ((plugCenter - socketRect.center).distance < 80) {
                        _s2PlugIn(socketRect);
                      } else {
                        _rt_playSfx(_rt_Sfx.tap, volume: 0.5);
                        setState(() =>
                            _s2PlugPos = Offset(size.width * 0.45, size.height * 0.78));
                      }
                    },
              child: Container(
                width: 56,
                height: 48,
                decoration: BoxDecoration(
                  color: _rt_Tw.gray800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _rt_Tw.gray700),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: 14, height: 5, color: _rt_Tw.gray400),
                        const SizedBox(height: 6),
                        Container(width: 14, height: 5, color: _rt_Tw.gray400),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _socketHole() => Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(color: _rt_Tw.gray800, shape: BoxShape.circle),
      );

  Widget _heaterDevice() {
    return LayoutBuilder(builder: (context, c) {
      final socketRect = Rect.fromLTWH(
          _canvasSize.width - 100, _canvasSize.height / 2 - 42, 60, 84);
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_rt_Tw.gray100, _rt_Tw.slate300],
          ),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: _rt_Tw.gray200, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 12))],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Recessed carry handle.
            Container(
              width: 76,
              height: 14,
              decoration: BoxDecoration(
                color: _rt_Tw.slate300,
                borderRadius: BorderRadius.circular(99),
                border: const Border(bottom: BorderSide(color: Colors.white)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Controls: dummy knob • power LED • rotary switch.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _knob(mark: false, on: false),
                const SizedBox(width: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _s2On ? _rt_Tw.red500 : const Color(0xFF7F1D1D),
                    shape: BoxShape.circle,
                    border: Border.all(color: _rt_Tw.gray400),
                    boxShadow: _s2On
                        ? [BoxShadow(color: _rt_Tw.red500.withValues(alpha: 0.9), blurRadius: 8)]
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  key: const ValueKey('heater-switch'),
                  onTap: () => _s2TapSwitch(socketRect),
                  child: _knob(mark: true, on: _s2On),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reflector with coil + grille.
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_rt_Tw.gray400, _rt_Tw.gray200, _rt_Tw.gray500],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _rt_Tw.slate300, width: 6),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Intense reflector glow when running.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 2000),
                      opacity: _s2On ? 1 : 0,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(0xCCFF5500), Colors.transparent],
                            radius: 0.85,
                          ),
                        ),
                        child: SizedBox.expand(),
                      ),
                    ),
                    // Tubular heating coil.
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          key: const ValueKey('coil'),
                          behavior: HitTestBehavior.opaque,
                          onTap: _s2TapCoil,
                          child: CustomPaint(painter: _CoilPainter(on: _s2On)),
                        ),
                      ),
                    ),
                    // Front grille sliding away in step 3.
                    IgnorePointer(
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        offset: _s2GrilleOpen ? const Offset(0, 1.1) : Offset.zero,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 1500),
                          opacity: _s2GrilleOpen ? 0 : 1,
                          child: CustomPaint(
                            painter: _GrillePainter(),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
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

  Widget _knob({required bool mark, required bool on}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rt_Tw.gray200, _rt_Tw.gray400],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: _rt_Tw.gray400),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 300),
        turns: mark && on ? 0.25 : 0,
        child: const Align(
          alignment: Alignment(0, -0.62),
          child: SizedBox(
            width: 4,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _rt_Tw.gray500,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ----
  Widget _scenarioSelector() {
    Widget btn(int id, String key) {
      final active = _scenario == id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: active ? _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.yellow500) : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            key: ValueKey('scenario-$id'),
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (_scenario == id) return;
              _rt_playSfx(_rt_Sfx.scenario);
              _loadScenario(id);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? _rt_Tw.yellow500 : _rt_Lab.border, width: 2),
              ),
              child: Row(
                children: [
                  Icon(id == 1 ? Icons.electrical_services : Icons.fireplace,
                      size: 15, color: active ? _rt_Tw.yellow500 : _rt_Lab.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_tx.s('$key.title'),
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800, color: _rt_Lab.text)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: _rt_Lab.base,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('select_scenario'), icon: Icons.tune, color: _rt_Tw.yellow400),
          btn(1, 's1'),
          btn(2, 's2'),
        ],
      ),
    );
  }

  Widget _sidebarTab() {
    final sPre = _scenario == 1 ? 's1' : 's2';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('theory'),
          desc: _tx.s('$sPre.theory'),
          accent: _rt_Tw.yellow500,
          icon: Icons.menu_book,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('procedural_steps'),
                  icon: Icons.format_list_numbered, color: _rt_Tw.yellow400),
              for (var i = 0; i < 4; i++) _stepTile(i),
              if (_scenario == 1) ...[
                const SizedBox(height: 8),
                _rt_SectionLabel(_tx.s('controls'), icon: Icons.tune, color: _rt_Tw.amber400),
                _controlsCard(),
                const SizedBox(height: 8),
                _rt_SectionLabel(_tx.s('ui.placed'), icon: Icons.category, color: _rt_Tw.amber400),
                _placedComponents(),
              ],
              const SizedBox(height: 70),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepTile(int i) {
    final sPre = _scenario == 1 ? 's1' : 's2';
    final stepNo = i + 1;
    final done = _completed || stepNo < _step;
    final active = !_completed && stepNo == _step;
    final accent = done ? _rt_Tw.green500 : _rt_Tw.yellow500;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active
            ? _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.yellow500)
            : done
                ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
                : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: active
                ? _rt_Tw.yellow500
                : done
                    ? _rt_Tw.green500.withValues(alpha: 0.6)
                    : _rt_Lab.border,
            width: 2),
      ),
      child: Opacity(
        opacity: active || done ? 1 : 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? _rt_Tw.green500 : (active ? _rt_Tw.yellow500 : _rt_Tw.slate700),
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('$stepNo',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: active ? _rt_Tw.slate900 : Colors.white)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_tx.s('$sPre.steps.$i.desc'),
                      style: TextStyle(fontSize: 11.5, color: _rt_Lab.text, height: 1.35)),
                ),
              ],
            ),
            // Native helper buttons for the source's drag / canvas-tap steps.
            if (active) ...[
              if (_scenario == 1 && stepNo == 2) ...[
                const SizedBox(height: 8),
                _rt_ActionButton(
                  key: const ValueKey('btn-connect'),
                  label: _tx.s('ui.connect'),
                  icon: Icons.link,
                  color: accent,
                  sound: null,
                  onPressed: _connectCircuit,
                ),
              ],
              if (_scenario == 1 && (stepNo == 2 || stepNo == 3)) ...[
                const SizedBox(height: 8),
                _rt_ActionButton(
                  key: const ValueKey('btn-toggle-switch'),
                  label: _tx.s('ui.toggle_switch'),
                  icon: Icons.toggle_on,
                  color: accent,
                  sound: null,
                  onPressed: _comps.any((c) => c.type == 'switch') ? _toggleFirstSwitch : null,
                ),
              ],
              if (_scenario == 1 && stepNo == 4) ...[
                const SizedBox(height: 8),
                _rt_ActionButton(
                  key: const ValueKey('btn-touch-wire'),
                  label: _tx.s('ui.touch_wire'),
                  icon: Icons.back_hand,
                  color: _rt_Tw.orange500,
                  sound: null,
                  onPressed: _simClosed ? _touchWire : null,
                ),
              ],
              if (_scenario == 2 && stepNo == 4 && !_s2Plugged) ...[
                const SizedBox(height: 8),
                _rt_ActionButton(
                  key: const ValueKey('btn-plug-in'),
                  label: _tx.s('ui.plug_in'),
                  icon: Icons.power,
                  color: accent,
                  sound: null,
                  onPressed: () => _s2PlugIn(Rect.fromLTWH(
                      _canvasSize.width - 100, _canvasSize.height / 2 - 42, 60, 84)),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _controlsCard() {
    final sel = _selection;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_LabeledSlider(
            key: const ValueKey('slider-voltage'),
            label: _tx.s('voltage'),
            value: _voltage,
            min: 0,
            max: 120,
            divisions: 12,
            valueText: '${_voltage.round()}V',
            color: _rt_Tw.yellow500,
            onChanged: (v) => setState(() {
              _voltage = v;
              for (final c in _comps) {
                if (c.type == 'battery') c.value = v;
              }
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  key: const ValueKey('btn-thermal'),
                  label: _tx.s('thermal'),
                  icon: Icons.local_fire_department,
                  iconColor: _rt_Tw.orange500,
                  active: _thermal,
                  onTap: () => setState(() => _thermal = !_thermal),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _toggleChip(
                  key: const ValueKey('btn-style'),
                  label: _tx.s(_schematic ? 'schematic' : 'realistic'),
                  icon: _schematic ? Icons.design_services : Icons.visibility,
                  iconColor: _rt_Tw.blue500,
                  active: !_schematic,
                  onTap: () => setState(() => _schematic = !_schematic),
                ),
              ),
            ],
          ),
          if (sel != null) ...[
            const SizedBox(height: 10),
            Divider(color: _rt_Lab.border, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(_tx.s('selection').toUpperCase(),
                      style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w900, color: _rt_Lab.textFaint)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _rt_Lab.overlay,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _tx.s(sel.labelKey) + (sel.type == 'battery' ? ' ${sel.value.round()}V' : ''),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: _rt_Lab.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _rt_ActionButton(
                  key: const ValueKey('btn-delete'),
                  label: _tx.s('delete'),
                  icon: Icons.delete,
                  color: _rt_Tw.red500,
                  sound: _rt_Sfx.wrong,
                  onPressed: _deleteSelection,
                ),
                if (sel.type == 'switch')
                  _rt_ActionButton(
                    key: const ValueKey('btn-switch-sel'),
                    label: _tx.s('ui.toggle_switch'),
                    icon: Icons.toggle_on,
                    color: _rt_Tw.slate500,
                    sound: _rt_Sfx.toggle,
                    onPressed: () => setState(() => sel.isOpen = !sel.isOpen),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _toggleChip({
    required Key key,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: () {
        _rt_playSfx(_rt_Sfx.toggle);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.yellow500) : _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? _rt_Tw.yellow500 : _rt_Lab.border, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: _rt_Lab.text)),
          ],
        ),
      ),
    );
  }

  Widget _placedComponents() {
    if (_comps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Text(_tx.s('ui.empty'),
            style: TextStyle(fontSize: 11, color: _rt_Lab.textFaint, fontStyle: FontStyle.italic)),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < _comps.length; i++)
          GestureDetector(
            key: ValueKey('sel-$i'),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() {
                _selection = _comps[i];
                if (_comps[i].type == 'battery') _voltage = _comps[i].value;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: identical(_selection, _comps[i])
                    ? _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.yellow500)
                    : _rt_Lab.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: identical(_selection, _comps[i]) ? _rt_Tw.yellow500 : _rt_Lab.border,
                    width: 1.5),
              ),
              child: Text(
                _tx.s(_comps[i].labelKey) +
                    (_comps[i].type == 'switch' ? (_comps[i].isOpen ? ' ⏻✕' : ' ⏻✓') : ''),
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: _rt_Lab.text),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------- painters ----

class _RepaintNotifier extends ChangeNotifier {
  void tick() => notifyListeners();
}

/// Scenario 1 world: dotted background, wires, nodes, components (realistic
/// or schematic), thermal glow, heat haze, electron flow and labels — a
/// direct port of the source's `loop()` drawing section.
class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.s, Listenable repaint) : super(repaint: repaint);

  final _Cl8Ch04A2HeatingEffectPageState s;

  @override
  void paint(Canvas canvas, Size size) {
    // Background dot grid (#sim-canvas radial-gradient dots).
    final dot = Paint()..color = const Color(0xFF334155);
    for (double x = 12; x < size.width; x += 24) {
      for (double y = 12; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }

    canvas.save();
    canvas.translate(s._viewOffset.dx, s._viewOffset.dy);
    canvas.scale(s._zoomLv);

    for (final c in s._comps) {
      if (c.type == 'wire') _drawComponent(canvas, c);
    }
    final nodePaint = Paint()..color = const Color(0xFF94A3B8);
    for (final n in s._nodes) {
      canvas.drawCircle(Offset(n.x, n.y), 6, nodePaint);
    }
    for (final c in s._comps) {
      if (c.type != 'wire') _drawComponent(canvas, c);
    }

    // Electron flow (realistic style only, like the source).
    if (!s._schematic) {
      final ePaint = Paint()..color = const Color(0xFF60A5FA);
      for (final c in s._comps) {
        if (c.current.abs() > 0.1 && !c.isOpen) {
          final dx = c.n2.x - c.n1.x, dy = c.n2.y - c.n1.y;
          final len = math.sqrt(dx * dx + dy * dy);
          if (len < 10) continue;
          final angle = math.atan2(dy, dx);
          canvas.save();
          canvas.translate(c.n1.x, c.n1.y);
          canvas.rotate(angle);
          final speed = math.min(c.current * 0.5, 10.0);
          final dir = c.n1.voltage > c.n2.voltage ? -1 : 1;
          final phase = s._time * 30 * speed * dir;
          for (var i = 0; i < (len / 20).floor(); i++) {
            var pos = (i * 20 + phase) % len;
            if (pos < 0) pos += len;
            if (pos > 5 && pos < len - 5) canvas.drawCircle(Offset(pos, 0), 3, ePaint);
          }
          canvas.restore();
        }
      }
    }

    canvas.restore();
  }

  void _drawComponent(Canvas canvas, _Comp c) {
    final x1 = c.n1.x, y1 = c.n1.y, x2 = c.n2.x, y2 = c.n2.y;
    final len = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    if (len < 1) return;
    final angle = math.atan2(y2 - y1, x2 - x1);

    canvas.save();
    canvas.translate(x1, y1);
    canvas.rotate(angle);

    if (identical(s._selection, c)) {
      canvas.drawLine(
        Offset.zero,
        Offset(len, 0),
        Paint()
          ..color = const Color(0xFFEAB308).withValues(alpha: 0.5)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Thermal view glow (power dissipated as heat).
    if (s._thermal && (c.power > 1 || c.isNichrome)) {
      final heat = math.min(c.power / 50, 1.0);
      canvas.drawLine(
        Offset.zero,
        Offset(len, 0),
        Paint()
          ..color = Color.fromRGBO(255, (100 - heat * 100).round().clamp(0, 255), 0, 0.6)
          ..strokeWidth = 10 + 10 * heat
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 14 * heat),
      );
    }

    if (s._schematic) {
      _drawSchematic(canvas, c, len);
    } else {
      _drawRealistic(canvas, c, len);
    }
    canvas.restore();

    if (s._showLabels) {
      final mx = (x1 + x2) / 2, my = (y1 + y2) / 2;
      _text(canvas, _tx.s(c.labelKey), Offset(mx, my - 22));
      if (c.type == 'battery') {
        _text(canvas, '${c.value.round()}V', Offset(mx, my + 22));
      }
    }
  }

  void _drawRealistic(Canvas canvas, _Comp c, double len) {
    final mid = len / 2;
    final lead = Paint()
      ..color = const Color(0xFFEAB308)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (c.type == 'wire') {
      if (c.isNichrome) {
        // Heat ratio: while the assembled circuit is closed, driven by the
        // step-3 timer (10 s real = 30 s displayed); otherwise by power.
        double heatRatio = 0;
        if (s._scenario == 1 && s._simClosed) {
          heatRatio = math.min(1, s._heatTimer / 10);
        } else if (c.current > 0.5) {
          heatRatio = math.min(1, c.power / 20);
        }
        final red = math.min(255, (148 + heatRatio * 107).round());
        final green = math.max(50, (163 - heatRatio * 113).round());
        final blue = math.max(0, (184 - heatRatio * 184).round());

        final coil = Path()..moveTo(0, 0);
        for (double i = 0; i <= len; i += 5) {
          coil.lineTo(i, (i.round() % 10 == 0) ? -8 : 8);
        }
        canvas.drawPath(
            coil,
            Paint()
              ..color = Color.fromRGBO(red, green, blue, 1)
              ..strokeWidth = 8
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..style = PaintingStyle.stroke);

        // Pulsing heat haze once the 30 s mark is reached.
        if (s._scenario == 1 && s._heatTimer >= 10) {
          canvas.drawPath(
              coil,
              Paint()
                ..color = const Color.fromRGBO(255, 60, 0, 0.7)
                ..strokeWidth = 6 + math.sin(s._time * 15) * 3
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke
                ..maskFilter =
                    MaskFilter.blur(BlurStyle.normal, 10 + math.sin(s._time * 20) * 5));
        }
      } else {
        canvas.drawLine(
            Offset.zero,
            Offset(len, 0),
            Paint()
              ..color = const Color(0xFFEAB308)
              ..strokeWidth = 8
              ..strokeCap = StrokeCap.round);
        canvas.drawLine(
            const Offset(0, -2),
            Offset(len, -2),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.4)
              ..strokeWidth = 2);
      }
    } else if (c.type == 'battery') {
      canvas.drawLine(Offset.zero, Offset(mid - 32, 0), lead);
      canvas.drawLine(Offset(mid + 35, 0), Offset(len, 0), lead);
      canvas.drawRect(Rect.fromLTWH(mid - 30, -15, 60, 30), Paint()..color = const Color(0xFF0F172A));
      final copper = Paint()..color = const Color(0xFFD97706);
      canvas.drawRect(Rect.fromLTWH(mid + 25, -8, 10, 16), copper);
      canvas.drawRect(Rect.fromLTWH(mid + 15, -15, 15, 30), copper);
      canvas.drawRect(Rect.fromLTWH(mid - 32, -10, 4, 20), Paint()..color = const Color(0xFFCBD5E1));
      _icon(canvas, Icons.bolt, Offset(mid - 5, 0), 14, Colors.white);
    } else if (c.type == 'switch') {
      canvas.drawLine(Offset.zero, Offset(mid - 20, 0), lead);
      canvas.drawLine(Offset(mid + 20, 0), Offset(len, 0), lead);
      canvas.drawRect(Rect.fromLTWH(mid - 20, -10, 40, 20), Paint()..color = const Color(0xFF334155));
      final term = Paint()..color = const Color(0xFFFBBF24);
      canvas.drawCircle(Offset(mid - 12, 0), 4, term);
      canvas.drawCircle(Offset(mid + 12, 0), 4, term);
      final lever = Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(mid - 12, 0), c.isOpen ? Offset(mid + 10, -25) : Offset(mid + 12, 0), lever);
    }
  }

  void _drawSchematic(Canvas canvas, _Comp c, double len) {
    final mid = len / 2;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (c.type == 'wire') {
      if (c.isNichrome) {
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(mid - 15, 0);
        for (var i = 0; i < 6; i++) {
          path.lineTo(mid - 15 + i * 5 + 2.5, (i % 2 == 0) ? -5 : 5);
        }
        path
          ..lineTo(mid + 15, 0)
          ..lineTo(len, 0);
        canvas.drawPath(path, p);
      } else {
        canvas.drawLine(Offset.zero, Offset(len, 0), p);
      }
    } else if (c.type == 'battery') {
      canvas.drawLine(Offset.zero, Offset(mid - 5, 0), p);
      canvas.drawLine(Offset(mid + 5, 0), Offset(len, 0), p);
      canvas.drawLine(Offset(mid - 5, -10), Offset(mid - 5, 10), p);
      canvas.drawLine(Offset(mid + 5, -5), Offset(mid + 5, 5),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 4);
    } else if (c.type == 'switch') {
      canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
      canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
      canvas.drawLine(Offset(mid - 10, 0), c.isOpen ? Offset(mid + 8, -8) : Offset(mid + 10, 0), p);
      canvas.drawCircle(Offset(mid - 10, 0), 2, p);
    }
  }

  void _text(Canvas canvas, String t, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _icon(Canvas canvas, IconData icon, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontFamily: icon.fontFamily, fontSize: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) => true;
}

/// The heater's tubular coil (the source's `#coil-path` SVG in a 100×100
/// viewBox), grey when off, glowing red-orange when running.
class _CoilPainter extends CustomPainter {
  _CoilPainter({required this.on});

  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100, sy = size.height / 100;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final path = Path()
      ..moveTo(p(15, 90).dx, p(15, 90).dy)
      ..lineTo(p(15, 20).dx, p(15, 20).dy)
      ..quadraticBezierTo(p(15, 10).dx, p(15, 10).dy, p(25, 10).dx, p(25, 10).dy)
      ..quadraticBezierTo(p(35, 10).dx, p(35, 10).dy, p(35, 20).dx, p(35, 20).dy)
      ..lineTo(p(35, 80).dx, p(35, 80).dy)
      ..quadraticBezierTo(p(35, 90).dx, p(35, 90).dy, p(45, 90).dx, p(45, 90).dy)
      ..quadraticBezierTo(p(55, 90).dx, p(55, 90).dy, p(55, 80).dx, p(55, 80).dy)
      ..lineTo(p(55, 20).dx, p(55, 20).dy)
      ..quadraticBezierTo(p(55, 10).dx, p(55, 10).dy, p(65, 10).dx, p(65, 10).dy)
      ..quadraticBezierTo(p(75, 10).dx, p(75, 10).dy, p(75, 20).dx, p(75, 20).dy)
      ..lineTo(p(75, 80).dx, p(75, 80).dy)
      ..quadraticBezierTo(p(75, 90).dx, p(75, 90).dy, p(85, 90).dx, p(85, 90).dy)
      ..quadraticBezierTo(p(95, 90).dx, p(95, 90).dy, p(95, 80).dx, p(95, 80).dy)
      ..lineTo(p(95, 10).dx, p(95, 10).dy);

    final w = 5 * math.min(sx, sy).clamp(0.6, 2.5);
    if (on) {
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFF4500)
            ..strokeWidth = w * 2
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = on ? const Color(0xFFFF4500) : const Color(0xFF71717A)
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _CoilPainter old) => old.on != on;
}

/// The heater's protective front grille: a white wire mesh.
class _GrillePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    final shade = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 0.5;
    for (double x = 8; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), wire);
      canvas.drawLine(Offset(x + 1, 0), Offset(x + 1, size.height), shade);
    }
    for (double y = 8; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), wire);
      canvas.drawLine(Offset(0, y + 1), Offset(size.width, y + 1), shade);
    }
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(covariant _GrillePainter old) => false;
}

/// Sagging power cord from the heater base to the plug (source `s2DrawCord`).
class _CordPainter extends CustomPainter {
  _CordPainter({required this.start, required this.end});

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx, end.dy + 80, end.dx - 80, end.dy, end.dx, end.dy);
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF1F2937)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _CordPainter old) => old.start != start || old.end != end;
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
            color: active ? _rt_Tw.yellow500 : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: active ? _rt_Tw.slate900 : _rt_Lab.textMuted),
        ),
      ),
    );
  }
}
