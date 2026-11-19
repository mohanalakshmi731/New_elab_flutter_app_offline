// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 7.1: Particulate Nature of Matter
// Converted from Cl8S-Ch7-A1-Particulate_Nature_of_Matter.html
// (three.js + OrbitControls -> mini3d Scene3DView).
//
// Five investigation protocols picked from the sidebar. 1: Breaking Chalk —
// hammer shatters a chalk stick, chunks go into the mortar, the pestle grinds
// them to powder, the magnifier zooms in and a tap identifies the grains.
// 2: Sugar in Water — mark the 100 mL level, spoon in sugar and stir it away,
// then tap 3 sugar molecules into the voids of the molecular view. 3: KMnO4
// Diffusion — forceps drop the crystal, a time-lapse slider spreads the purple
// colour, then an observation quiz. 4: Piling Stones vs Water — pour each
// bucket three times, then drag the "Locked Grid"/"Sliding" labels onto the
// matching material. 5: Salty Ocean Water — magnifier + confirm button, heat
// the beaker on the tripod until only salt remains, tap the residue and fill
// the two-gap conclusion from a word bank. Each drag also has a sidebar
// "Do This Step" fallback button; completed steps can be tapped to review
// their 3D state, and every scenario ends in the Final Observation popup.




// --- TRANSLATION DATA (source `window.TRANSLATIONS`, te: block dropped) ---

import 'dart:async';
import 'dart:math' as math;


import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
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

  /// The activity (usually a _rt_Scene3DView). Fills the area right of the
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


/// Mutable 3D vector (mirrors the parts of THREE.Vector3 the activities use).
class _rt_V3 {
  _rt_V3([this.x = 0, this.y = 0, this.z = 0]);

  factory _rt_V3.zero() => _rt_V3();
  factory _rt_V3.all(double v) => _rt_V3(v, v, v);

  double x, y, z;

  _rt_V3 clone() => _rt_V3(x, y, z);

  _rt_V3 set(double nx, double ny, double nz) {
    x = nx;
    y = ny;
    z = nz;
    return this;
  }

  _rt_V3 copy(_rt_V3 o) => set(o.x, o.y, o.z);

  _rt_V3 operator +(_rt_V3 o) => _rt_V3(x + o.x, y + o.y, z + o.z);
  _rt_V3 operator -(_rt_V3 o) => _rt_V3(x - o.x, y - o.y, z - o.z);
  _rt_V3 operator *(double s) => _rt_V3(x * s, y * s, z * s);
  _rt_V3 operator /(double s) => _rt_V3(x / s, y / s, z / s);
  _rt_V3 operator -() => _rt_V3(-x, -y, -z);

  _rt_V3 add(_rt_V3 o) => set(x + o.x, y + o.y, z + o.z);
  _rt_V3 sub(_rt_V3 o) => set(x - o.x, y - o.y, z - o.z);
  _rt_V3 scaleBy(double s) => set(x * s, y * s, z * s);
  _rt_V3 addScaled(_rt_V3 o, double s) => set(x + o.x * s, y + o.y * s, z + o.z * s);

  double dot(_rt_V3 o) => x * o.x + y * o.y + z * o.z;
  _rt_V3 cross(_rt_V3 o) => _rt_V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => math.sqrt(x * x + y * y + z * z);
  double get lengthSq => x * x + y * y + z * z;
  double distanceTo(_rt_V3 o) => (this - o).length;

  _rt_V3 normalized() {
    final l = length;
    return l == 0 ? _rt_V3() : _rt_V3(x / l, y / l, z / l);
  }

  _rt_V3 normalize() {
    final l = length;
    if (l != 0) scaleBy(1 / l);
    return this;
  }

  _rt_V3 lerp(_rt_V3 to, double t) =>
      _rt_V3(x + (to.x - x) * t, y + (to.y - y) * t, z + (to.z - z) * t);

  _rt_V3 lerpTo(_rt_V3 to, double t) =>
      set(x + (to.x - x) * t, y + (to.y - y) * t, z + (to.z - z) * t);

  @override
  String toString() =>
      '_rt_V3(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})';
}

/// 3x3 matrix, row-major.
class _rt_M3 {
  _rt_M3(this.m);

  factory _rt_M3.identity() => _rt_M3([1, 0, 0, 0, 1, 0, 0, 0, 1]);

  /// Rotation matching THREE.Euler order 'XYZ': R = Rx * Ry * Rz.
  factory _rt_M3.eulerXYZ(double ax, double ay, double az) {
    final a = math.cos(ax), b = math.sin(ax);
    final c = math.cos(ay), d = math.sin(ay);
    final e = math.cos(az), f = math.sin(az);
    final ae = a * e, af = a * f, be = b * e, bf = b * f;
    return _rt_M3([
      c * e, -c * f, d, //
      af + be * d, ae - bf * d, -b * c,
      bf - ae * d, be + af * d, a * c,
    ]);
  }

  /// Rotation around an arbitrary unit [axis] by [angle].
  factory _rt_M3.axisAngle(_rt_V3 axis, double angle) {
    final n = axis.normalized();
    final c = math.cos(angle), s = math.sin(angle), t = 1 - c;
    final x = n.x, y = n.y, z = n.z;
    return _rt_M3([
      t * x * x + c, t * x * y - s * z, t * x * z + s * y, //
      t * x * y + s * z, t * y * y + c, t * y * z - s * x,
      t * x * z - s * y, t * y * z + s * x, t * z * z + c,
    ]);
  }

  /// Rotation that maps the unit vector [from] onto [to]
  /// (like THREE.Quaternion.setFromUnitVectors).
  factory _rt_M3.fromUnitVectors(_rt_V3 from, _rt_V3 to) {
    final f = from.normalized(), t = to.normalized();
    final d = f.dot(t);
    if (d > 0.999999) return _rt_M3.identity();
    if (d < -0.999999) {
      var axis = _rt_V3(1, 0, 0).cross(f);
      if (axis.length < 1e-6) axis = _rt_V3(0, 1, 0).cross(f);
      return _rt_M3.axisAngle(axis, math.pi);
    }
    return _rt_M3.axisAngle(f.cross(t), math.acos(d.clamp(-1.0, 1.0)));
  }

  final List<double> m;

  _rt_M3 operator *(_rt_M3 o) {
    final r = List<double>.filled(9, 0);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        r[i * 3 + j] =
            m[i * 3] * o.m[j] + m[i * 3 + 1] * o.m[3 + j] + m[i * 3 + 2] * o.m[6 + j];
      }
    }
    return _rt_M3(r);
  }

  _rt_V3 apply(_rt_V3 v) => _rt_V3(
        m[0] * v.x + m[1] * v.y + m[2] * v.z,
        m[3] * v.x + m[4] * v.y + m[5] * v.z,
        m[6] * v.x + m[7] * v.y + m[8] * v.z,
      );

  _rt_M3 scaled(_rt_V3 s) => _rt_M3([
        m[0] * s.x, m[1] * s.y, m[2] * s.z, //
        m[3] * s.x, m[4] * s.y, m[5] * s.z,
        m[6] * s.x, m[7] * s.y, m[8] * s.z,
      ]);
}

/// Affine transform: p' = m * p + t.
class _rt_Xf {
  _rt_Xf(this.m, this.t);

  factory _rt_Xf.identity() => _rt_Xf(_rt_M3.identity(), _rt_V3());

  final _rt_M3 m;
  final _rt_V3 t;

  _rt_V3 apply(_rt_V3 p) {
    final r = m.apply(p);
    return r..add(t);
  }

  _rt_Xf operator *(_rt_Xf o) => _rt_Xf(m * o.m, m.apply(o.t)..add(t));

  /// Approximate uniform scale factor (used for sphere / label sizes).
  double get maxScale {
    final sx = math.sqrt(m.m[0] * m.m[0] + m.m[3] * m.m[3] + m.m[6] * m.m[6]);
    final sy = math.sqrt(m.m[1] * m.m[1] + m.m[4] * m.m[4] + m.m[7] * m.m[7]);
    final sz = math.sqrt(m.m[2] * m.m[2] + m.m[5] * m.m[5] + m.m[8] * m.m[8]);
    return math.max(sx, math.max(sy, sz));
  }
}

double _rt_degToRad(double d) => d * math.pi / 180;
double _rt_radToDeg(double r) => r * 180 / math.pi;

/// Easing helpers matching the curves used in the HTML activities.
class _rt_Ease {
  static double linear(double t) => t;
  static double outCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
  static double inCubic(double t) => t * t * t;
  static double inOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;
  static double inOutQuad(double t) =>
      t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2).toDouble() / 2;
  static double outQuad(double t) => 1 - (1 - t) * (1 - t);
  static double inQuad(double t) => t * t;
  static double outBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  static double outBounce(double t) {
    const n1 = 7.5625, d1 = 2.75;
    if (t < 1 / d1) return n1 * t * t;
    if (t < 2 / d1) return n1 * (t -= 1.5 / d1) * t + 0.75;
    if (t < 2.5 / d1) return n1 * (t -= 2.25 / d1) * t + 0.9375;
    return n1 * (t -= 2.625 / d1) * t + 0.984375;
  }

  static double outElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    if (t == 0 || t == 1) return t;
    return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }
}




/// Polygon mesh. Faces are lists of vertex indices wound counter-clockwise
/// when viewed from the outside (same convention as three.js), so the face
/// normal points outward.
///
/// Builders mirror the three.js geometry constructors and their axes:
/// cylinders/cones/lathes stand on the Y axis, planes/circles/rings/torus lie
/// in the XY plane facing +Z.
class _rt_Geometry3D {
  _rt_Geometry3D(this.vertices, this.faces, [this.faceGroups]);

  final List<_rt_V3> vertices;
  final List<List<int>> faces;

  /// Optional material index per face (for per-face colours, e.g. dice/boxes).
  final List<int>? faceGroups;

  /// Merges several geometries, each placed with its own transform.
  factory _rt_Geometry3D.merge(List<(_rt_Geometry3D, _rt_Xf)> parts) {
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    for (final (g, xf) in parts) {
      final base = verts.length;
      verts.addAll(g.vertices.map(xf.apply));
      faces.addAll(g.faces.map((f) => f.map((i) => i + base).toList()));
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.BoxGeometry(w, h, d). Face groups: 0 +x, 1 -x, 2 +y, 3 -y, 4 +z, 5 -z
  /// (the three.js material-array order).
  factory _rt_Geometry3D.box(double w, double h, double d) {
    final x = w / 2, y = h / 2, z = d / 2;
    final v = [
      _rt_V3(-x, -y, -z), _rt_V3(x, -y, -z), _rt_V3(x, y, -z), _rt_V3(-x, y, -z), //
      _rt_V3(-x, -y, z), _rt_V3(x, -y, z), _rt_V3(x, y, z), _rt_V3(-x, y, z),
    ];
    return _rt_Geometry3D(v, [
      [5, 1, 2, 6], // +x
      [0, 4, 7, 3], // -x
      [7, 6, 2, 3], // +y
      [0, 1, 5, 4], // -y
      [4, 5, 6, 7], // +z
      [1, 0, 3, 2], // -z
    ], [0, 1, 2, 3, 4, 5]);
  }

  /// THREE.CylinderGeometry(radiusTop, radiusBottom, height, radialSegments,
  /// heightSegments=1, openEnded, thetaStart, thetaLength).
  factory _rt_Geometry3D.cylinder(
    double radiusTop,
    double radiusBottom,
    double height, {
    int segments = 24,
    bool openEnded = false,
    double thetaStart = 0,
    double thetaLength = math.pi * 2,
  }) {
    final hy = height / 2;
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    final full = (thetaLength - math.pi * 2).abs() < 1e-6;
    final count = full ? segments : segments + 1;
    for (var i = 0; i < count; i++) {
      final th = thetaStart + i / segments * thetaLength;
      final s = math.sin(th), c = math.cos(th);
      verts.add(_rt_V3(radiusTop * s, hy, radiusTop * c)); // top i -> 2i
      verts.add(_rt_V3(radiusBottom * s, -hy, radiusBottom * c)); // bottom -> 2i+1
    }
    for (var i = 0; i < segments; i++) {
      final a = i, b = full ? (i + 1) % segments : i + 1;
      faces.add([2 * a + 1, 2 * b + 1, 2 * b, 2 * a]);
    }
    if (!openEnded) {
      if (radiusTop > 0) {
        final top = [for (var i = 0; i < count; i++) 2 * i];
        if (!full) {
          verts.add(_rt_V3(0, hy, 0));
          top.insert(0, verts.length - 1);
        }
        faces.add(top);
      }
      if (radiusBottom > 0) {
        final bottom = [for (var i = count - 1; i >= 0; i--) 2 * i + 1];
        if (!full) {
          verts.add(_rt_V3(0, -hy, 0));
          bottom.add(verts.length - 1);
        }
        faces.add(bottom);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.ConeGeometry(radius, height, radialSegments).
  factory _rt_Geometry3D.cone(double radius, double height,
          {int segments = 24, bool openEnded = false}) =>
      _rt_Geometry3D.cylinder(0, radius, height, segments: segments, openEnded: openEnded);

  /// THREE.SphereGeometry(radius, widthSegments, heightSegments, phiStart,
  /// phiLength, thetaStart, thetaLength). Use for partial spheres (bowls,
  /// domes); full spheres render faster and smoother with [_rt_Sphere3D].
  factory _rt_Geometry3D.sphere(
    double radius, {
    int widthSegments = 20,
    int heightSegments = 14,
    double phiStart = 0,
    double phiLength = math.pi * 2,
    double thetaStart = 0,
    double thetaLength = math.pi,
  }) {
    final verts = <_rt_V3>[];
    final grid = <List<int>>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      final row = <int>[];
      final v = iy / heightSegments;
      for (var ix = 0; ix <= widthSegments; ix++) {
        final u = ix / widthSegments;
        final phi = phiStart + u * phiLength;
        final theta = thetaStart + v * thetaLength;
        verts.add(_rt_V3(
          -radius * math.cos(phi) * math.sin(theta),
          radius * math.cos(theta),
          radius * math.sin(phi) * math.sin(theta),
        ));
        row.add(verts.length - 1);
      }
      grid.add(row);
    }
    final faces = <List<int>>[];
    for (var iy = 0; iy < heightSegments; iy++) {
      for (var ix = 0; ix < widthSegments; ix++) {
        final a = grid[iy][ix + 1], b = grid[iy][ix];
        final c = grid[iy + 1][ix], d = grid[iy + 1][ix + 1];
        final theta0 = thetaStart + iy / heightSegments * thetaLength;
        final theta1 = thetaStart + (iy + 1) / heightSegments * thetaLength;
        if (theta0.abs() < 1e-9) {
          faces.add([a, c, d]); // top pole
        } else if ((theta1 - math.pi).abs() < 1e-9) {
          faces.add([a, b, c]); // bottom pole
        } else {
          faces.add([a, b, c, d]);
        }
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.TorusGeometry(radius, tube, radialSegments, tubularSegments, arc).
  factory _rt_Geometry3D.torus(
    double radius,
    double tube, {
    int radialSegments = 10,
    int tubularSegments = 36,
    double arc = math.pi * 2,
  }) {
    final verts = <_rt_V3>[];
    for (var j = 0; j <= radialSegments; j++) {
      for (var i = 0; i <= tubularSegments; i++) {
        final u = i / tubularSegments * arc;
        final v = j / radialSegments * math.pi * 2;
        verts.add(_rt_V3(
          (radius + tube * math.cos(v)) * math.cos(u),
          (radius + tube * math.cos(v)) * math.sin(u),
          tube * math.sin(v),
        ));
      }
    }
    final faces = <List<int>>[];
    for (var j = 1; j <= radialSegments; j++) {
      for (var i = 1; i <= tubularSegments; i++) {
        final a = (tubularSegments + 1) * j + i - 1;
        final b = (tubularSegments + 1) * (j - 1) + i - 1;
        final c = (tubularSegments + 1) * (j - 1) + i;
        final d = (tubularSegments + 1) * j + i;
        faces.add([a, b, c, d]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.PlaneGeometry(width, height, wSegs, hSegs) in the XY plane facing +Z.
  factory _rt_Geometry3D.plane(double width, double height,
      {int widthSegments = 1, int heightSegments = 1}) {
    final verts = <_rt_V3>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      for (var ix = 0; ix <= widthSegments; ix++) {
        verts.add(_rt_V3(-width / 2 + ix / widthSegments * width,
            -height / 2 + iy / heightSegments * height, 0));
      }
    }
    final faces = <List<int>>[];
    final w = widthSegments + 1;
    for (var iy = 0; iy < heightSegments; iy++) {
      for (var ix = 0; ix < widthSegments; ix++) {
        final a = iy * w + ix;
        faces.add([a, a + 1, a + 1 + w, a + w]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.CircleGeometry(radius, segments, thetaStart, thetaLength), XY plane.
  factory _rt_Geometry3D.circle(double radius,
      {int segments = 32, double thetaStart = 0, double thetaLength = math.pi * 2}) {
    final full = (thetaLength - math.pi * 2).abs() < 1e-6;
    final verts = <_rt_V3>[];
    if (!full) verts.add(_rt_V3());
    final count = full ? segments : segments + 1;
    for (var i = 0; i < count; i++) {
      final th = thetaStart + i / segments * thetaLength;
      verts.add(_rt_V3(radius * math.cos(th), radius * math.sin(th), 0));
    }
    return _rt_Geometry3D(verts, [List.generate(verts.length, (i) => i)]);
  }

  /// THREE.RingGeometry(innerRadius, outerRadius, segments, ...), XY plane.
  factory _rt_Geometry3D.ring(double innerRadius, double outerRadius,
      {int segments = 32, double thetaStart = 0, double thetaLength = math.pi * 2}) {
    final verts = <_rt_V3>[];
    for (var i = 0; i <= segments; i++) {
      final th = thetaStart + i / segments * thetaLength;
      final c = math.cos(th), s = math.sin(th);
      verts.add(_rt_V3(outerRadius * c, outerRadius * s, 0)); // 2i
      verts.add(_rt_V3(innerRadius * c, innerRadius * s, 0)); // 2i+1
    }
    final faces = <List<int>>[];
    for (var i = 0; i < segments; i++) {
      faces.add([2 * i, 2 * (i + 1), 2 * (i + 1) + 1, 2 * i + 1]);
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.LatheGeometry(points, segments, phiStart, phiLength). Each point is
  /// (radius, y); list them bottom -> top for outward-facing normals.
  factory _rt_Geometry3D.lathe(List<Offset> points,
      {int segments = 24, double phiStart = 0, double phiLength = math.pi * 2}) {
    final verts = <_rt_V3>[];
    for (var i = 0; i <= segments; i++) {
      final phi = phiStart + i / segments * phiLength;
      final s = math.sin(phi), c = math.cos(phi);
      for (final p in points) {
        verts.add(_rt_V3(p.dx * s, p.dy, p.dx * c));
      }
    }
    final n = points.length;
    final faces = <List<int>>[];
    for (var i = 0; i < segments; i++) {
      for (var j = 0; j < n - 1; j++) {
        final a = i * n + j, b = a + n, c = a + n + 1, d = a + 1;
        faces.add([a, b, c, d]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// Capsule standing on Y: total height = length + 2 * radius.
  factory _rt_Geometry3D.capsule(double radius, double length,
      {int segments = 16, int capSegments = 6}) {
    final pts = <Offset>[];
    for (var i = 0; i <= capSegments; i++) {
      final a = -math.pi / 2 + i / capSegments * math.pi / 2;
      pts.add(Offset(radius * math.cos(a), -length / 2 + radius * math.sin(a)));
    }
    for (var i = 0; i <= capSegments; i++) {
      final a = i / capSegments * math.pi / 2;
      pts.add(Offset(radius * math.cos(a), length / 2 + radius * math.sin(a)));
    }
    return _rt_Geometry3D.lathe(pts, segments: segments);
  }

  /// Extrudes a 2D polygon (XY, counter-clockwise) along +Z from 0 to [depth]
  /// (THREE.ExtrudeGeometry without bevel).
  factory _rt_Geometry3D.extrude(List<Offset> shape, double depth) {
    final n = shape.length;
    final verts = <_rt_V3>[
      for (final p in shape) _rt_V3(p.dx, p.dy, 0),
      for (final p in shape) _rt_V3(p.dx, p.dy, depth),
    ];
    final faces = <List<int>>[
      [for (var i = n - 1; i >= 0; i--) i], // back
      [for (var i = 0; i < n; i++) n + i], // front
      for (var i = 0; i < n; i++) [i, (i + 1) % n, n + (i + 1) % n, n + i],
    ];
    return _rt_Geometry3D(verts, faces);
  }

  /// Round tube following a polyline (THREE.TubeGeometry for wires, pipes).
  factory _rt_Geometry3D.tube(List<_rt_V3> path, double radius,
      {int radialSegments = 8, bool closed = false}) {
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    var prevNormal = _rt_V3(0, 1, 0);
    for (var i = 0; i < path.length; i++) {
      final prev = path[i == 0 ? (closed ? path.length - 1 : 0) : i - 1];
      final next = path[i == path.length - 1 ? (closed ? 0 : i) : i + 1];
      var tangent = (next - prev).normalized();
      if (tangent.lengthSq == 0) tangent = _rt_V3(1, 0, 0);
      var normal = prevNormal - tangent * prevNormal.dot(tangent);
      if (normal.lengthSq < 1e-8) {
        normal = _rt_V3(0, 0, 1).cross(tangent);
        if (normal.lengthSq < 1e-8) normal = _rt_V3(1, 0, 0).cross(tangent);
      }
      normal.normalize();
      prevNormal = normal;
      final binormal = tangent.cross(normal);
      for (var j = 0; j < radialSegments; j++) {
        final a = j / radialSegments * math.pi * 2;
        verts.add(path[i] +
            normal * (radius * math.cos(a)) +
            binormal * (radius * math.sin(a)));
      }
    }
    final rings = closed ? path.length : path.length - 1;
    for (var i = 0; i < rings; i++) {
      final i2 = (i + 1) % path.length;
      for (var j = 0; j < radialSegments; j++) {
        final j2 = (j + 1) % radialSegments;
        faces.add([
          i * radialSegments + j,
          i * radialSegments + j2,
          i2 * radialSegments + j2,
          i2 * radialSegments + j,
        ]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.OctahedronGeometry(radius).
  factory _rt_Geometry3D.octahedron(double r) {
    final v = [_rt_V3(r, 0, 0), _rt_V3(-r, 0, 0), _rt_V3(0, r, 0), _rt_V3(0, -r, 0), _rt_V3(0, 0, r), _rt_V3(0, 0, -r)];
    return _rt_Geometry3D(v, [
      [0, 2, 4], [0, 4, 3], [0, 3, 5], [0, 5, 2], //
      [1, 2, 5], [1, 5, 3], [1, 3, 4], [1, 4, 2],
    ]);
  }

  /// THREE.TetrahedronGeometry(radius).
  factory _rt_Geometry3D.tetrahedron(double r) {
    final k = r / math.sqrt(3);
    final v = [_rt_V3(k, k, k), _rt_V3(-k, -k, k), _rt_V3(-k, k, -k), _rt_V3(k, -k, -k)];
    return _rt_Geometry3D(v, [
      [2, 1, 0], [0, 3, 2], [1, 3, 0], [2, 3, 1],
    ]);
  }

  /// THREE.IcosahedronGeometry(radius) (detail 0).
  factory _rt_Geometry3D.icosahedron(double r) {
    final t = (1 + math.sqrt(5)) / 2;
    final raw = [
      _rt_V3(-1, t, 0), _rt_V3(1, t, 0), _rt_V3(-1, -t, 0), _rt_V3(1, -t, 0), //
      _rt_V3(0, -1, t), _rt_V3(0, 1, t), _rt_V3(0, -1, -t), _rt_V3(0, 1, -t),
      _rt_V3(t, 0, -1), _rt_V3(t, 0, 1), _rt_V3(-t, 0, -1), _rt_V3(-t, 0, 1),
    ];
    final v = raw.map((p) => p.normalized()..scaleBy(r)).toList();
    return _rt_Geometry3D(v, [
      [0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11], //
      [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
      [3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
      [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
    ]);
  }
}





/// Surface appearance (covers MeshBasic / Lambert / Phong / Standard /
/// Physical materials closely enough for the activities).
class _rt_Material3D {
  _rt_Material3D({
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 1.0,
    this.unlit = false,
    this.doubleSided = false,
    this.emissive,
    this.emissiveIntensity = 1.0,
    this.shininess = 0.0,
    this.metalness = 0.0,
    this.wireframe = false,
    this.edgeColor,
    this.edgeWidth = 1.0,
    this.faceColors,
    this.visible = true,
  });

  /// Base colour (THREE `color`).
  Color color;

  /// 0..1 (THREE `opacity` with `transparent: true`).
  double opacity;

  /// MeshBasicMaterial: ignores lights.
  bool unlit;

  /// THREE.DoubleSide.
  bool doubleSided;

  /// Glow colour added regardless of lighting.
  Color? emissive;
  double emissiveIntensity;

  /// 0..1 highlight strength (Phong/Standard shine; also sphere gloss).
  double shininess;

  /// 0..1 (MeshStandardMaterial `metalness`): darkens diffuse lighting.
  double metalness;

  /// Draws only polygon outlines.
  bool wireframe;

  /// Optional outline drawn around every face (EdgesGeometry look).
  Color? edgeColor;
  double edgeWidth;

  /// Per-face-group colours, e.g. box sides (THREE material arrays).
  List<Color>? faceColors;

  /// THREE `material.visible`.
  bool visible;

  _rt_Material3D copyWith({Color? color, double? opacity}) => _rt_Material3D(
        color: color ?? this.color,
        opacity: opacity ?? this.opacity,
        unlit: unlit,
        doubleSided: doubleSided,
        emissive: emissive,
        emissiveIntensity: emissiveIntensity,
        shininess: shininess,
        metalness: metalness,
        wireframe: wireframe,
        edgeColor: edgeColor,
        edgeWidth: edgeWidth,
        faceColors: faceColors,
        visible: visible,
      );
}

/// Scene-graph node (THREE.Object3D / THREE.Group).
class _rt_Node3D {
  _rt_Node3D({this.name, _rt_V3? position, _rt_V3? rotation, _rt_V3? scale})
      : position = position ?? _rt_V3(),
        rotation = rotation ?? _rt_V3(),
        scale = scale ?? _rt_V3(1, 1, 1);

  String? name;
  final _rt_V3 position;

  /// Euler angles in radians, order XYZ (THREE default).
  final _rt_V3 rotation;
  final _rt_V3 scale;

  /// When set, replaces [rotation] (use for arbitrary orientations, e.g.
  /// [pointAlong] or quaternion-driven code).
  _rt_M3? rotationMatrix;

  bool visible = true;

  /// Can be returned by hit tests (raycasting).
  bool pickable = true;

  /// Added to the sort depth; negative values draw on top (render order).
  double depthBias = 0;

  /// Arbitrary data (THREE `userData`).
  Map<String, dynamic> userData = {};

  _rt_Node3D? parent;
  final List<_rt_Node3D> children = [];

  T add<T extends _rt_Node3D>(T child) {
    child.parent?.children.remove(child);
    child.parent = this;
    children.add(child);
    return child;
  }

  void addAll(Iterable<_rt_Node3D> nodes) => nodes.forEach(add);

  void remove(_rt_Node3D child) {
    if (children.remove(child)) child.parent = null;
  }

  void removeFromParent() => parent?.remove(this);

  void clear() {
    for (final c in children) {
      c.parent = null;
    }
    children.clear();
  }

  _rt_Xf get localTransform {
    final r = rotationMatrix ?? _rt_M3.eulerXYZ(rotation.x, rotation.y, rotation.z);
    return _rt_Xf(r.scaled(scale), position.clone());
  }

  _rt_Xf get worldTransform {
    final local = localTransform;
    return parent == null ? local : parent!.worldTransform * local;
  }

  _rt_V3 get worldPosition => worldTransform.t;

  /// Rotates so the local +Y axis points along [dir] (cylinders, arrows).
  void pointAlong(_rt_V3 dir) {
    rotationMatrix = _rt_M3.fromUnitVectors(_rt_V3(0, 1, 0), dir);
  }

  /// Rotates so the local +Z axis faces [target] (THREE Object3D.lookAt).
  void lookAt(_rt_V3 target) {
    final wp = worldPosition;
    rotationMatrix = _rt_M3.fromUnitVectors(_rt_V3(0, 0, 1), target - wp);
  }

  /// True if this node and all its ancestors are visible.
  bool get isVisibleInTree => visible && (parent?.isVisibleInTree ?? true);

  /// Depth-first search by [name].
  _rt_Node3D? find(String n) {
    if (name == n) return this;
    for (final c in children) {
      final r = c.find(n);
      if (r != null) return r;
    }
    return null;
  }

  void traverse(void Function(_rt_Node3D) fn) {
    fn(this);
    for (final c in List.of(children)) {
      c.traverse(fn);
    }
  }
}

/// Polygon mesh (THREE.Mesh).
class _rt_Mesh3D extends _rt_Node3D {
  _rt_Mesh3D(this.geometry, this.material, {super.name, super.position, super.rotation, super.scale});

  _rt_Geometry3D geometry;
  _rt_Material3D material;
}

/// Smooth sphere drawn as a shaded disc (fast and perfectly round). Use
/// `_rt_Mesh3D(_rt_Geometry3D.sphere(...))` for partial spheres.
class _rt_Sphere3D extends _rt_Node3D {
  _rt_Sphere3D(this.radius, this.material, {super.name, super.position});

  double radius;
  _rt_Material3D material;
}

/// Polyline in 3D (THREE.Line / LineSegments). Width is in screen pixels.
class _rt_Line3D extends _rt_Node3D {
  _rt_Line3D(this.points,
      {this.color = const Color(0xFFFFFFFF),
      this.width = 2,
      this.opacity = 1,
      this.dashed = false,
      this.segments = false,
      this.closed = false,
      super.name});

  List<_rt_V3> points;
  Color color;
  double width;
  double opacity;
  bool dashed;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments;
  bool closed;
}

/// Point cloud (THREE.Points). Size is in screen pixels, scaled by
/// perspective when [sizeAttenuation] is true.
class _rt_Points3D extends _rt_Node3D {
  _rt_Points3D(this.points,
      {this.color = const Color(0xFFFFFFFF),
      this.size = 4,
      this.opacity = 1,
      this.sizeAttenuation = true,
      this.colors,
      super.name});

  List<_rt_V3> points;
  Color color;
  List<Color>? colors;
  double size;
  double opacity;
  bool sizeAttenuation;
}

/// Billboard text (THREE.Sprite with a canvas texture, or CSS2D labels).
class _rt_Label3D extends _rt_Node3D {
  _rt_Label3D(
    this.text, {
    super.position,
    super.name,
    this.worldHeight = 1.0,
    this.pixelHeight,
    this.color = const Color(0xFFFFFFFF),
    this.background,
    this.borderColor,
    this.bold = true,
    this.alwaysOnTop = true,
  });

  String text;

  /// Text height in world units (scales with distance like a sprite).
  double worldHeight;

  /// If set, fixed on-screen font size instead of [worldHeight].
  double? pixelHeight;
  Color color;
  Color? background;
  Color? borderColor;
  bool bold;

  /// THREE `depthTest: false` — drawn above all geometry.
  bool alwaysOnTop;
}

/// THREE.ArrowHelper: shaft + cone head from [origin] along [dir].
class _rt_Arrow3D extends _rt_Node3D {
  _rt_Arrow3D({
    required _rt_V3 dir,
    required double length,
    _rt_V3? origin,
    Color color = const Color(0xFFFFFF00),
    double? headLength,
    double? headWidth,
    this.shaftRadius = 0.06,
    super.name,
  }) : _color = color {
    if (origin != null) position.copy(origin);
    _shaft = add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1, 1, 1, segments: 10), _rt_Material3D(color: color)));
    _head = add(_rt_Mesh3D(_rt_Geometry3D.cone(1, 1, segments: 14), _rt_Material3D(color: color)));
    setDirection(dir);
    setLength(length, headLength: headLength, headWidth: headWidth);
  }

  late final _rt_Mesh3D _shaft;
  late final _rt_Mesh3D _head;
  Color _color;
  double shaftRadius;
  double _length = 1;

  double get length => _length;
  Color get color => _color;

  void setDirection(_rt_V3 dir) {
    if (dir.lengthSq == 0) return;
    pointAlong(dir);
  }

  void setLength(double length, {double? headLength, double? headWidth}) {
    _length = length;
    final visibleArrow = length.abs() > 1e-4;
    _shaft.visible = visibleArrow;
    _head.visible = visibleArrow;
    final hl = headLength ?? math.min(0.2 * length.abs(), 1.2);
    final hw = headWidth ?? hl * 0.5;
    final shaftLen = math.max(length.abs() - hl, 0.0001);
    _shaft.scale.set(shaftRadius, shaftLen, shaftRadius);
    _shaft.position.set(0, shaftLen / 2, 0);
    _head.scale.set(hw, hl, hw);
    _head.position.set(0, shaftLen + hl / 2, 0);
  }

  void setColor(Color c) {
    _color = c;
    _shaft.material.color = c;
    _head.material.color = c;
  }
}

/// Lights. Ambient + directional + point lights are supported (Lambert).
class _rt_Light3D {
  _rt_Light3D.ambient({this.color = const Color(0xFFFFFFFF), this.intensity = 0.6})
      : kind = _rt_LightKind.ambient,
        position = _rt_V3();
  _rt_Light3D.directional(this.position,
      {this.color = const Color(0xFFFFFFFF), this.intensity = 0.8})
      : kind = _rt_LightKind.directional;
  _rt_Light3D.point(this.position,
      {this.color = const Color(0xFFFFFFFF), this.intensity = 1.0, this.distance = 0})
      : kind = _rt_LightKind.point;
  _rt_Light3D.hemisphere(
      {this.color = const Color(0xFFFFFFFF),
      this.groundColor = const Color(0xFF444444),
      this.intensity = 0.6})
      : kind = _rt_LightKind.hemisphere,
        position = _rt_V3(0, 1, 0);

  final _rt_LightKind kind;
  _rt_V3 position;
  Color color;
  Color groundColor = const Color(0xFF444444);
  double intensity;
  double distance = 0;
  bool enabled = true;
}

enum _rt_LightKind { ambient, directional, point, hemisphere }

/// Root container: node tree + lights + background.
class _rt_Scene3D {
  _rt_Scene3D({this.background, this.backgroundGradient}) {
    lights.addAll([
      _rt_Light3D.ambient(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(10, 20, 10), intensity: 0.8),
    ]);
  }

  final _rt_Node3D root = _rt_Node3D(name: 'root');
  final List<_rt_Light3D> lights = [];

  /// Solid background; null = transparent.
  Color? background;

  /// Radial gradient [centre, edge] (the CSS backgrounds of #canvas-container).
  List<Color>? backgroundGradient;

  T add<T extends _rt_Node3D>(T n) => root.add(n);
  void remove(_rt_Node3D n) => root.remove(n);
  void clear() => root.clear();
  _rt_Node3D? find(String name) => root.find(name);

  /// Replaces the default lights.
  void setLights(List<_rt_Light3D> l) {
    lights
      ..clear()
      ..addAll(l);
  }
}




/// Perspective (or orthographic) camera with built-in OrbitControls
/// behaviour: drag to rotate, two fingers to pan, pinch / wheel / buttons to
/// zoom. Mirrors THREE.PerspectiveCamera + THREE.OrbitControls.
class _rt_Camera3D {
  _rt_Camera3D({
    this.fov = 45,
    _rt_V3? position,
    _rt_V3? target,
    this.near = 0.1,
    this.far = 5000,
    this.orthographic = false,
    this.orthoHeight = 20,
  })  : position = position ?? _rt_V3(0, 10, 30),
        target = target ?? _rt_V3() {
    saveHome();
  }

  /// Vertical field of view in degrees.
  double fov;
  final _rt_V3 position;

  /// OrbitControls.target (the point the camera looks at).
  final _rt_V3 target;
  double near;
  double far;

  /// THREE camera.zoom (scales the image without moving the camera).
  double zoom = 1;

  bool orthographic;

  /// Visible world height for the orthographic camera at zoom 1.
  double orthoHeight;

  // --- OrbitControls settings ---
  bool enableRotate = true;
  bool enablePan = true;
  bool enableZoom = true;
  double rotateSpeed = 1;
  double minDistance = 0.5;
  double maxDistance = 2000;
  double minPolarAngle = 0.001;
  double maxPolarAngle = math.pi - 0.001;
  double minAzimuthAngle = double.negativeInfinity;
  double maxAzimuthAngle = double.infinity;
  double minZoom = 0.2;
  double maxZoom = 8;

  /// OrbitControls.autoRotate / autoRotateSpeed (2.0 = one turn per 30 s).
  bool autoRotate = false;
  double autoRotateSpeed = 2.0;

  late _rt_V3 _homePos;
  late _rt_V3 _homeTarget;
  late double _homeZoom;
  late double _homeFov;

  /// Remembers the current view for [reset] (call after positioning).
  void saveHome() {
    _homePos = position.clone();
    _homeTarget = target.clone();
    _homeZoom = zoom;
    _homeFov = fov;
  }

  /// Restores the view saved by [saveHome] (the "reset camera" button).
  void reset() {
    position.copy(_homePos);
    target.copy(_homeTarget);
    zoom = _homeZoom;
    fov = _homeFov;
  }

  void lookAt(_rt_V3 t) => target.copy(t);

  double get distance => position.distanceTo(target);

  // ---------------------------------------------------------------- basis ---
  late _rt_V3 _right, _up, _fwd;

  void _basis() {
    _fwd = (target - position).normalized();
    if (_fwd.lengthSq == 0) _fwd = _rt_V3(0, 0, -1);
    var worldUp = _rt_V3(0, 1, 0);
    if (_fwd.cross(worldUp).lengthSq < 1e-8) worldUp = _rt_V3(0, 0, -1);
    _right = _fwd.cross(worldUp).normalized();
    _up = _right.cross(_fwd);
  }

  double _focal(Size size) => orthographic
      ? size.height / (orthoHeight / zoom)
      : (size.height / 2) / math.tan(_rt_degToRad(fov) / 2) * zoom;

  /// Prepares the per-frame projection (called by the renderer).
  _rt_ProjectionFrame frame(Size size) {
    _basis();
    return _rt_ProjectionFrame._(this, size, _right, _up, _fwd, _focal(size));
  }

  // --------------------------------------------------------- orbit / pan ---
  void _toSpherical(void Function(double r, double theta, double phi) fn) {
    final off = position - target;
    final r = off.length;
    final theta = math.atan2(off.x, off.z);
    final phi = math.acos((off.y / (r == 0 ? 1 : r)).clamp(-1.0, 1.0));
    fn(r, theta, phi);
  }

  void _fromSpherical(double r, double theta, double phi) {
    final s = math.sin(phi);
    position.set(
      target.x + r * s * math.sin(theta),
      target.y + r * math.cos(phi),
      target.z + r * s * math.cos(theta),
    );
  }

  /// Rotates around the target by a screen drag of ([dx], [dy]) pixels.
  void orbit(double dx, double dy, double viewportHeight) {
    if (!enableRotate) return;
    _toSpherical((r, theta, phi) {
      theta -= 2 * math.pi * dx / viewportHeight * rotateSpeed;
      phi -= 2 * math.pi * dy / viewportHeight * rotateSpeed;
      theta = theta.clamp(minAzimuthAngle, maxAzimuthAngle);
      phi = phi.clamp(minPolarAngle, maxPolarAngle);
      _fromSpherical(r, theta, phi);
    });
  }

  /// Rotates by angles directly (radians).
  void rotateBy(double dTheta, double dPhi) {
    _toSpherical((r, theta, phi) {
      _fromSpherical(r, (theta + dTheta).clamp(minAzimuthAngle, maxAzimuthAngle),
          (phi + dPhi).clamp(minPolarAngle, maxPolarAngle));
    });
  }

  /// Moves camera + target by a screen drag of ([dx], [dy]) pixels.
  void pan(double dx, double dy, Size size) {
    if (!enablePan) return;
    _basis();
    final worldPerPixel = orthographic
        ? (orthoHeight / zoom) / size.height
        : 2 * distance * math.tan(_rt_degToRad(fov) / 2) / size.height / zoom;
    final move = _right * (-dx * worldPerPixel) + _up * (dy * worldPerPixel);
    position.add(move);
    target.add(move);
  }

  /// Zoom by [factor] (< 1 zooms in). Perspective cameras dolly toward the
  /// target; orthographic cameras change [zoom].
  void dolly(double factor) {
    if (!enableZoom) return;
    if (orthographic) {
      zoom = (zoom / factor).clamp(minZoom, maxZoom);
      return;
    }
    final off = position - target;
    final r = (off.length * factor).clamp(minDistance, maxDistance);
    position.copy(target + off.normalized() * r);
  }

  void zoomIn() => dolly(0.85);
  void zoomOut() => dolly(1 / 0.85);

  /// Per-frame update (auto-rotate).
  void update(double dt) {
    if (autoRotate) rotateBy(-2 * math.pi / 60 * autoRotateSpeed * dt, 0);
  }
}

/// Screen projection for one frame.
class _rt_ProjectionFrame {
  _rt_ProjectionFrame._(this.camera, this.size, this.right, this.up, this.fwd, this.focal)
      : eye = camera.position.clone(),
        cx = size.width / 2,
        cy = size.height / 2;

  final _rt_Camera3D camera;
  final Size size;
  final _rt_V3 right, up, fwd, eye;
  final double focal, cx, cy;

  /// Camera-space depth (distance along view direction).
  double depthOf(_rt_V3 p) =>
      (p.x - eye.x) * fwd.x + (p.y - eye.y) * fwd.y + (p.z - eye.z) * fwd.z;

  /// Projects a world point; null if behind the near plane.
  Offset? project(_rt_V3 p) {
    final dx = p.x - eye.x, dy = p.y - eye.y, dz = p.z - eye.z;
    final z = dx * fwd.x + dy * fwd.y + dz * fwd.z;
    if (!camera.orthographic && z < camera.near) return null;
    final x = dx * right.x + dy * right.y + dz * right.z;
    final y = dx * up.x + dy * up.y + dz * up.z;
    final k = camera.orthographic ? focal : focal / z;
    return Offset(cx + x * k, cy - y * k);
  }

  /// Screen pixels per world unit at depth [z].
  double pixelsPerUnit(double z) =>
      camera.orthographic ? focal : focal / math.max(z, camera.near);

  /// World-space ray through a screen point (for raycasting / dragging).
  _rt_Ray3 ray(Offset screen) {
    final x = (screen.dx - cx) / focal;
    final y = -(screen.dy - cy) / focal;
    if (camera.orthographic) {
      final origin = eye + right * x + up * y;
      return _rt_Ray3(origin, fwd.clone());
    }
    final dir = (fwd + right * x + up * y).normalized();
    return _rt_Ray3(eye.clone(), dir);
  }
}

class _rt_Ray3 {
  _rt_Ray3(this.origin, this.direction);

  final _rt_V3 origin;
  final _rt_V3 direction;

  _rt_V3 at(double t) => origin + direction * t;

  /// Intersection with the plane through [point] with [normal]; null if
  /// parallel or behind the ray.
  _rt_V3? intersectPlane(_rt_V3 point, _rt_V3 normal) {
    final denom = normal.dot(direction);
    if (denom.abs() < 1e-9) return null;
    final t = (point - origin).dot(normal) / denom;
    if (t < 0) return null;
    return at(t);
  }

  /// Intersection with the horizontal plane y = [y].
  _rt_V3? intersectY(double y) => intersectPlane(_rt_V3(0, y, 0), _rt_V3(0, 1, 0));

  /// Intersection with the vertical plane z = [z].
  _rt_V3? intersectZ(double z) => intersectPlane(_rt_V3(0, 0, z), _rt_V3(0, 0, 1));
}







/// Pick record kept from the last painted frame (used for raycast hits).
class _Pickable {
  _Pickable.path(this.node, this.path, this.depth) : center = null, radius = 0;
  _Pickable.circle(this.node, Offset c, this.radius, this.depth)
      : center = c,
        path = null;

  final _rt_Node3D node;
  final Path? path;
  final Offset? center;
  final double radius;
  final double depth;

  bool contains(Offset p) =>
      path != null ? path!.contains(p) : (p - center!).distance <= radius;
}

/// Shared state between the painter and the view (projection + picking).
class _rt_RenderState {
  _rt_ProjectionFrame? frame;
  List<_Pickable> _picks = const [];

  /// Nearest pickable node under [p] in the last frame.
  _rt_Node3D? hitTest(Offset p) {
    _Pickable? best;
    for (final k in _picks) {
      if (k.contains(p) && (best == null || k.depth < best.depth)) best = k;
    }
    return best?.node;
  }

  /// All pickable nodes under [p], nearest first.
  List<_rt_Node3D> hitTestAll(Offset p) {
    final hits = _picks.where((k) => k.contains(p)).toList()
      ..sort((a, b) => a.depth.compareTo(b.depth));
    return [for (final h in hits) h.node];
  }
}

class _Item {
  _Item(this.depth, this.draw);
  final double depth;
  final void Function(Canvas c) draw;
}

class _LabelCache {
  _LabelCache(this.key, this.painter);
  final String key;
  final TextPainter painter;
}

final Expando<_LabelCache> _labelCache = Expando();

/// Paints a [_rt_Scene3D] from a [_rt_Camera3D]. Repaints whenever [repaint] ticks.
class _rt_ScenePainter extends CustomPainter {
  _rt_ScenePainter({
    required this.scene,
    required this.camera,
    required this.state,
    super.repaint,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_RenderState state;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _paintBackground(canvas, size);

    final pf = camera.frame(size);
    state.frame = pf;
    final items = <_Item>[];
    final overlay = <_Item>[];
    final picks = <_Pickable>[];

    void visit(_rt_Node3D n, _rt_Xf parentXf) {
      if (!n.visible) return;
      final xf = parentXf * n.localTransform;
      if (n is _rt_Mesh3D) {
        _mesh(n, xf, pf, items, picks);
      } else if (n is _rt_Sphere3D) {
        _sphere(n, xf, pf, items, picks);
      } else if (n is _rt_Line3D) {
        _line(n, xf, pf, items);
      } else if (n is _rt_Points3D) {
        _points(n, xf, pf, items);
      } else if (n is _rt_Label3D) {
        _label(n, xf, pf, n.alwaysOnTop ? overlay : items, picks);
      }
      for (final c in n.children) {
        visit(c, xf);
      }
    }

    visit(scene.root, _rt_Xf.identity());

    items.sort((a, b) => b.depth.compareTo(a.depth));
    for (final it in items) {
      it.draw(canvas);
    }
    overlay.sort((a, b) => b.depth.compareTo(a.depth));
    for (final it in overlay) {
      it.draw(canvas);
    }
    state._picks = picks;
    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final g = scene.backgroundGradient;
    if (g != null && g.length >= 2) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            size.center(Offset.zero),
            math.max(size.width, size.height) * 0.75,
            g,
          ),
      );
    } else if (scene.background != null) {
      canvas.drawRect(rect, Paint()..color = scene.background!);
    }
  }

  // ------------------------------------------------------------ shading ---
  Color _shade(_rt_Material3D m, Color base, _rt_V3 n, _rt_V3 p, _rt_V3 view) {
    var r = 0.0, g = 0.0, b = 0.0;
    var sr = 0.0, sg = 0.0, sb = 0.0;
    if (m.unlit) {
      r = g = b = 1;
    } else {
      for (final l in scene.lights) {
        if (!l.enabled) continue;
        final lc = l.color;
        switch (l.kind) {
          case _rt_LightKind.ambient:
            r += lc.r * l.intensity;
            g += lc.g * l.intensity;
            b += lc.b * l.intensity;
          case _rt_LightKind.hemisphere:
            final w = 0.5 * n.y + 0.5;
            final gc = l.groundColor;
            r += (gc.r + (lc.r - gc.r) * w) * l.intensity;
            g += (gc.g + (lc.g - gc.g) * w) * l.intensity;
            b += (gc.b + (lc.b - gc.b) * w) * l.intensity;
          case _rt_LightKind.directional:
          case _rt_LightKind.point:
            _rt_V3 dir;
            var atten = 1.0;
            if (l.kind == _rt_LightKind.directional) {
              dir = l.position.normalized();
            } else {
              final d = l.position - p;
              final dist = d.length;
              dir = d / (dist == 0 ? 1 : dist);
              if (l.distance > 0) {
                atten = math.pow(math.max(0.0, 1 - dist / l.distance), 2).toDouble();
              }
            }
            final ndl = math.max(0.0, n.dot(dir)) * l.intensity * atten;
            r += lc.r * ndl;
            g += lc.g * ndl;
            b += lc.b * ndl;
            if (m.shininess > 0 && ndl > 0) {
              final h = (dir + view).normalized();
              final spec = math.pow(math.max(0.0, n.dot(h)), 8 + m.shininess * 56) *
                  m.shininess *
                  l.intensity *
                  atten;
              sr += lc.r * spec;
              sg += lc.g * spec;
              sb += lc.b * spec;
            }
        }
      }
    }
    final diffuse = 1 - 0.6 * m.metalness;
    var cr = base.r * r * diffuse + sr,
        cg = base.g * g * diffuse + sg,
        cb = base.b * b * diffuse + sb;
    final e = m.emissive;
    if (e != null) {
      cr += e.r * m.emissiveIntensity;
      cg += e.g * m.emissiveIntensity;
      cb += e.b * m.emissiveIntensity;
    }
    return Color.from(
      alpha: (base.a * m.opacity).clamp(0.0, 1.0),
      red: cr.clamp(0.0, 1.0),
      green: cg.clamp(0.0, 1.0),
      blue: cb.clamp(0.0, 1.0),
    );
  }

  // -------------------------------------------------------------- meshes ---
  void _mesh(_rt_Mesh3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items, List<_Pickable> picks) {
    final m = n.material;
    if (!m.visible) return;
    final g = n.geometry;
    final world = [for (final v in g.vertices) xf.apply(v)];
    final screen = [for (final v in world) pf.project(v)];
    final depths = [for (final v in world) pf.depthOf(v)];
    final pickable = n.pickable && n.isVisibleInTree;

    for (var fi = 0; fi < g.faces.length; fi++) {
      final f = g.faces[fi];
      if (f.length < 3) continue;
      var clipped = false;
      for (final i in f) {
        if (screen[i] == null) {
          clipped = true;
          break;
        }
      }
      // Faces crossing the near plane are clipped instead of dropped, so big
      // floors/tables never vanish when the camera gets close.
      final List<Offset> pts;
      if (clipped) {
        pts = _clipNear([for (final i in f) world[i]], pf);
        if (pts.length < 3) continue;
      } else {
        pts = [for (final i in f) screen[i]!];
      }

      // Newell normal (robust for quads and degenerate polygons).
      var nx = 0.0, ny = 0.0, nz = 0.0, cx = 0.0, cy = 0.0, cz = 0.0, depth = 0.0;
      for (var k = 0; k < f.length; k++) {
        final a = world[f[k]], b = world[f[(k + 1) % f.length]];
        nx += (a.y - b.y) * (a.z + b.z);
        ny += (a.z - b.z) * (a.x + b.x);
        nz += (a.x - b.x) * (a.y + b.y);
        cx += a.x;
        cy += a.y;
        cz += a.z;
        depth += depths[f[k]];
      }
      final inv = 1 / f.length;
      final center = _rt_V3(cx * inv, cy * inv, cz * inv);
      depth *= inv;
      var normal = _rt_V3(nx, ny, nz).normalize();
      final view = camera.orthographic ? -pf.fwd : (pf.eye - center).normalize();
      final facing = normal.dot(view) >= 0;
      if (!facing && !m.doubleSided && !m.wireframe) continue;
      if (!facing) normal = -normal;

      final gi = g.faceGroups != null && fi < g.faceGroups!.length ? g.faceGroups![fi] : 0;
      final base = (m.faceColors != null && gi < m.faceColors!.length)
          ? m.faceColors![gi]
          : m.color;
      final color = _shade(m, base, normal, center, view);

      final path = Path()..addPolygon(pts, true);

      final d = depth + n.depthBias;
      items.add(_Item(d, (c) {
        if (m.wireframe) {
          c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = m.edgeWidth
                ..color = color);
          return;
        }
        final fill = Paint()
          ..color = color
          ..isAntiAlias = true;
        c.drawPath(path, fill);
        if (color.a >= 0.99) {
          // Hide hairline seams between neighbouring opaque faces.
          c.drawPath(
              path,
              fill
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.7);
        }
        if (m.edgeColor != null) {
          c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = m.edgeWidth
                ..color = m.edgeColor!);
        }
      }));
      if (pickable) picks.add(_Pickable.path(n, path, d));
    }
  }

  /// Sutherland–Hodgman clip of a world-space polygon against the near
  /// plane, returning projected screen points.
  List<Offset> _clipNear(List<_rt_V3> poly, _rt_ProjectionFrame pf) {
    final near = camera.near * 1.01;
    final out = <_rt_V3>[];
    for (var k = 0; k < poly.length; k++) {
      final a = poly[k], b = poly[(k + 1) % poly.length];
      final da = pf.depthOf(a) - near, db = pf.depthOf(b) - near;
      if (da >= 0) out.add(a);
      if ((da >= 0) != (db >= 0)) out.add(a.lerp(b, da / (da - db)));
    }
    final res = <Offset>[];
    for (final p in out) {
      final s = pf.project(p);
      if (s != null) res.add(s);
    }
    return res;
  }

  // ------------------------------------------------------------- spheres ---
  void _sphere(_rt_Sphere3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items, List<_Pickable> picks) {
    final m = n.material;
    if (!m.visible) return;
    final c = xf.t;
    final z = pf.depthOf(c);
    if (!camera.orthographic && z < camera.near) return;
    final sp = pf.project(c);
    if (sp == null) return;
    final r = n.radius * xf.maxScale * pf.pixelsPerUnit(z);
    if (r < 0.3) return;
    final view = camera.orthographic ? -pf.fwd : (pf.eye - c).normalize();
    final lit = _shade(m, m.color, view, c, view);
    final d = z + n.depthBias;

    items.add(_Item(d, (canvas) {
      if (m.wireframe) {
        canvas.drawCircle(
            sp,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = lit);
        return;
      }
      if (m.unlit) {
        canvas.drawCircle(sp, r, Paint()..color = lit);
      } else {
        final hi = Color.lerp(lit, Colors.white.withValues(alpha: lit.a),
            0.35 + m.shininess * 0.4)!;
        final lo = Color.lerp(lit, Colors.black.withValues(alpha: lit.a), 0.45)!;
        canvas.drawCircle(
          sp,
          r,
          Paint()
            ..shader = ui.Gradient.radial(
              sp + Offset(-r * 0.35, -r * 0.4),
              r * 1.35,
              [hi, lit, lo],
              const [0.0, 0.45, 1.0],
            ),
        );
      }
      if (m.edgeColor != null) {
        canvas.drawCircle(
            sp,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = m.edgeWidth
              ..color = m.edgeColor!);
      }
    }));
    if (n.pickable && n.isVisibleInTree) picks.add(_Pickable.circle(n, sp, r, d));
  }

  // --------------------------------------------------------------- lines ---
  void _line(_rt_Line3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items) {
    if (n.points.length < 2) return;
    final world = [for (final p in n.points) xf.apply(p)];
    final color = n.color.withValues(alpha: n.color.a * n.opacity);
    final pairs = <(int, int)>[];
    if (n.segments) {
      for (var i = 0; i + 1 < world.length; i += 2) {
        pairs.add((i, i + 1));
      }
    } else {
      for (var i = 0; i + 1 < world.length; i++) {
        pairs.add((i, i + 1));
      }
      if (n.closed) pairs.add((world.length - 1, 0));
    }
    for (final (i, j) in pairs) {
      final a = pf.project(world[i]), b = pf.project(world[j]);
      if (a == null || b == null) continue;
      final d = (pf.depthOf(world[i]) + pf.depthOf(world[j])) / 2 + n.depthBias;
      items.add(_Item(d, (c) {
        final p = Paint()
          ..color = color
          ..strokeWidth = n.width
          ..strokeCap = StrokeCap.round;
        if (!n.dashed) {
          c.drawLine(a, b, p);
        } else {
          final len = (b - a).distance;
          const dash = 8.0, gap = 6.0;
          final dir = (b - a) / (len == 0 ? 1 : len);
          for (var t = 0.0; t < len; t += dash + gap) {
            c.drawLine(a + dir * t, a + dir * math.min(t + dash, len), p);
          }
        }
      }));
    }
  }

  // -------------------------------------------------------------- points ---
  void _points(_rt_Points3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items) {
    for (var i = 0; i < n.points.length; i++) {
      final w = xf.apply(n.points[i]);
      final s = pf.project(w);
      if (s == null) continue;
      final z = pf.depthOf(w);
      final base = n.colors != null && i < n.colors!.length ? n.colors![i] : n.color;
      final col = base.withValues(alpha: base.a * n.opacity);
      final r = n.sizeAttenuation
          ? math.max(0.5, n.size * pf.pixelsPerUnit(z) * 0.05)
          : n.size / 2;
      items.add(_Item(z + n.depthBias, (c) => c.drawCircle(s, r, Paint()..color = col)));
    }
  }

  // -------------------------------------------------------------- labels ---
  void _label(_rt_Label3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items, List<_Pickable> picks) {
    if (n.text.isEmpty) return;
    final w = xf.t;
    final s = pf.project(w);
    if (s == null) return;
    final z = pf.depthOf(w);
    final fontSize = (n.pixelHeight ?? n.worldHeight * xf.maxScale * pf.pixelsPerUnit(z) * 0.6)
        .clamp(5.0, 72.0);
    final key = '${n.text}|${fontSize.toStringAsFixed(1)}|${n.color.toARGB32()}|${n.bold}';
    var cache = _labelCache[n];
    if (cache == null || cache.key != key) {
      final tp = TextPainter(
        text: TextSpan(
          text: n.text,
          style: TextStyle(
            color: n.color,
            fontSize: fontSize,
            fontWeight: n.bold ? FontWeight.w800 : FontWeight.w500,
            height: 1.1,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      cache = _LabelCache(key, tp);
      _labelCache[n] = cache;
    }
    final tp = cache.painter;
    final padH = fontSize * 0.45, padV = fontSize * 0.25;
    final rect = Rect.fromCenter(
        center: s, width: tp.width + padH * 2, height: tp.height + padV * 2);
    final d = z + n.depthBias;
    items.add(_Item(d, (c) {
      if (n.background != null) {
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(fontSize * 0.35));
        c.drawRRect(rr, Paint()..color = n.background!);
        if (n.borderColor != null) {
          c.drawRRect(
              rr,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2
                ..color = n.borderColor!);
        }
      }
      tp.paint(c, s - Offset(tp.width / 2, tp.height / 2));
    }));
    if (n.pickable && n.isVisibleInTree) {
      picks.add(_Pickable.path(n, Path()..addRect(rect), n.alwaysOnTop ? -1e9 : d));
    }
  }

  @override
  bool shouldRepaint(covariant _rt_ScenePainter old) =>
      old.scene != scene || old.camera != camera;
}









/// Pointer info handed to activity callbacks (THREE.Raycaster equivalent).
class _rt_SceneEvent {
  _rt_SceneEvent(this.position, this.hit, this.ray, this.frame, this.hits);

  /// Local position inside the view.
  final Offset position;

  /// Nearest node under the pointer (mesh / sphere / label), if any.
  final _rt_Node3D? hit;

  /// All nodes under the pointer, nearest first.
  final List<_rt_Node3D> hits;

  /// World-space ray through the pointer.
  final _rt_Ray3 ray;
  final _rt_ProjectionFrame frame;

  /// Walks up from [hit] to the first node matching [test] (e.g. a named
  /// group), like checking `object.parent` chains after raycasting.
  _rt_Node3D? hitWhere(bool Function(_rt_Node3D n) test) {
    for (final h in hits) {
      _rt_Node3D? n = h;
      while (n != null) {
        if (test(n)) return n;
        n = n.parent;
      }
    }
    return null;
  }

  _rt_Node3D? hitNamed(String name) => hitWhere((n) => n.name == name);
}

enum _rt_DragMode { rotate, pan }

/// Controller so parents (e.g. zoom buttons) can talk to the view.
class _rt_Scene3DController extends ChangeNotifier {
  _rt_DragMode mode = _rt_DragMode.rotate;
  void setMode(_rt_DragMode m) {
    mode = m;
    notifyListeners();
  }
}

/// Interactive 3D viewport: renders [scene] through [camera] every frame
/// (like three.js' `requestAnimationFrame` render loop) and provides
/// OrbitControls-style gestures:
///
/// * one finger / left mouse drag: rotate (or pan in [_rt_DragMode.pan])
/// * two fingers: pinch to zoom, drag to pan
/// * mouse wheel / trackpad: zoom; right mouse drag: pan
///
/// If [onPointerDown] returns true, that gesture is captured by the activity
/// (for dragging objects) and the camera does not move.
class _rt_Scene3DView extends StatefulWidget {
  const _rt_Scene3DView({
    super.key,
    required this.scene,
    required this.camera,
    this.controller,
    this.onFrame,
    this.onTap,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onHover,
    this.cameraControls = true,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
  final void Function(_rt_SceneEvent e)? onTap;
  final bool Function(_rt_SceneEvent e)? onPointerDown;
  final void Function(_rt_SceneEvent e)? onPointerMove;
  final void Function(_rt_SceneEvent e)? onPointerUp;
  final void Function(_rt_SceneEvent e)? onHover;

  /// Set false to disable orbit/pan/zoom gestures entirely.
  final bool cameraControls;

  @override
  State<_rt_Scene3DView> createState() => _Scene3DViewState();
}

class _Scene3DViewState extends State<_rt_Scene3DView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _tick = ValueNotifier(0);
  final _rt_RenderState _render = _rt_RenderState();
  Duration _last = Duration.zero;
  Size _size = Size.zero;

  final Map<int, Offset> _pointers = {};
  int? _captured;
  Offset? _downPos;
  DateTime? _downTime;
  double _moved = 0;
  double? _pinchDist;
  Offset? _pinchCenter;
  int _buttons = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    var dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt > 0.1) dt = 0.1; // clamp after pauses
    widget.camera.update(dt);
    widget.onFrame?.call(dt);
    _tick.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  _rt_SceneEvent _event(Offset p) {
    final frame = _render.frame ?? widget.camera.frame(_size);
    final hits = _render.hitTestAll(p);
    return _rt_SceneEvent(p, hits.isEmpty ? null : hits.first, frame.ray(p), frame, hits);
  }

  void _down(PointerDownEvent e) {
    _pointers[e.pointer] = e.localPosition;
    _buttons = e.buttons;
    if (_pointers.length == 1) {
      _downPos = e.localPosition;
      _downTime = DateTime.now();
      _moved = 0;
      if (widget.onPointerDown?.call(_event(e.localPosition)) ?? false) {
        _captured = e.pointer;
      }
    } else {
      _startPinch();
    }
  }

  void _startPinch() {
    if (_pointers.length < 2) return;
    final ps = _pointers.values.take(2).toList();
    _pinchDist = (ps[0] - ps[1]).distance;
    _pinchCenter = (ps[0] + ps[1]) / 2;
  }

  void _move(PointerMoveEvent e) {
    final prev = _pointers[e.pointer];
    if (prev == null) return;
    _pointers[e.pointer] = e.localPosition;
    final delta = e.localPosition - prev;
    _moved += delta.distance;

    if (_captured == e.pointer) {
      widget.onPointerMove?.call(_event(e.localPosition));
      return;
    }
    if (_captured != null || !widget.cameraControls) return;
    final cam = widget.camera;

    if (_pointers.length >= 2) {
      final ps = _pointers.values.take(2).toList();
      final dist = (ps[0] - ps[1]).distance;
      final center = (ps[0] + ps[1]) / 2;
      if (_pinchDist != null && dist > 0) cam.dolly(_pinchDist! / dist);
      if (_pinchCenter != null) {
        final d = center - _pinchCenter!;
        cam.pan(d.dx, d.dy, _size);
      }
      _pinchDist = dist;
      _pinchCenter = center;
      return;
    }

    final panMode = (widget.controller?.mode == _rt_DragMode.pan) ||
        (_buttons & kSecondaryMouseButton) != 0 ||
        (_buttons & kMiddleMouseButton) != 0;
    if (panMode) {
      cam.pan(delta.dx, delta.dy, _size);
    } else {
      cam.orbit(delta.dx, delta.dy, _size.height);
    }
  }

  void _up(PointerEvent e, {bool cancelled = false}) {
    _pointers.remove(e.pointer);
    if (_captured == e.pointer) {
      _captured = null;
      widget.onPointerUp?.call(_event(e.localPosition));
    }
    if (!cancelled &&
        _pointers.isEmpty &&
        _downPos != null &&
        _moved < 10 &&
        DateTime.now().difference(_downTime!).inMilliseconds < 400) {
      widget.onTap?.call(_event(e.localPosition));
    }
    if (_pointers.length < 2) {
      _pinchDist = null;
      _pinchCenter = null;
    } else {
      _startPinch();
    }
    if (_pointers.isEmpty) _downPos = null;
  }

  void _signal(PointerSignalEvent e) {
    if (!widget.cameraControls) return;
    if (e is PointerScrollEvent) {
      GestureBinding.instance.pointerSignalResolver.register(e, (ev) {
        final dy = (ev as PointerScrollEvent).scrollDelta.dy;
        widget.camera.dolly(dy > 0 ? 1.08 : 1 / 1.08);
      });
    } else if (e is PointerScaleEvent) {
      widget.camera.dolly(1 / e.scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      _size = c.biggest;
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _up,
        onPointerCancel: (e) => _up(e, cancelled: true),
        onPointerSignal: _signal,
        onPointerHover: widget.onHover == null
            ? null
            : (e) => widget.onHover!(_event(e.localPosition)),
        onPointerPanZoomUpdate: (e) {
          if (!widget.cameraControls) return;
          if (e.scale != 1) widget.camera.dolly(1 / e.scale.clamp(0.9, 1.1));
        },
        child: RepaintBoundary(
          child: CustomPaint(
            size: c.biggest,
            painter: _rt_ScenePainter(
              scene: widget.scene,
              camera: widget.camera,
              state: _render,
              repaint: _tick,
            ),
          ),
        ),
      );
    });
  }
}

/// Simple tween runner for step animations (the HTML `animateProp` helper):
///
/// ```dart
/// await tweens.run(2000, (t) => water.scale.y = 0.01 + t * 0.99);
/// ```
///
/// Advance it from the view's `onFrame` callback: `tweens.update(dt)`.
class _rt_TweenRunner {
  /// [resumeOnCancel] false makes [cancelAll] abandon the awaiting code
  /// instead of resuming it, so a step interrupted by Restart or by leaving
  /// the page cannot finish later against the reset (or disposed) lab.
  _rt_TweenRunner({this.resumeOnCancel = true});

  final bool resumeOnCancel;
  final List<_Tween> _active = [];

  bool get isBusy => _active.isNotEmpty;

  /// Runs [update] with eased progress 0..1 over [ms] milliseconds.
  Future<void> run(int ms, void Function(double t) update,
      {double Function(double) ease = _rt_Ease.outCubic}) {
    final tw = _Tween(ms / 1000.0, update, ease);
    _active.add(tw);
    return tw.done.future;
  }

  /// Waits [ms] milliseconds (in animation time).
  Future<void> wait(int ms) => run(ms, (_) {}, ease: _rt_Ease.linear);

  void update(double dt) {
    for (final t in List.of(_active)) {
      t.elapsed += dt;
      final p = (t.elapsed / t.duration).clamp(0.0, 1.0);
      t.update(t.ease(p));
      if (p >= 1) {
        _active.remove(t);
        t.done.complete();
      }
    }
  }

  /// Stops all tweens. Their futures complete (so awaiting code resumes)
  /// only when [resumeOnCancel] is true; otherwise they never complete.
  void cancelAll() {
    if (resumeOnCancel) {
      for (final t in _active) {
        if (!t.done.isCompleted) t.done.complete();
      }
    }
    _active.clear();
  }
}

class _Tween {
  _Tween(this.duration, this.update, this.ease);
  final double duration;
  final void Function(double) update;
  final double Function(double) ease;
  double elapsed = 0;
  final Completer<void> done = Completer<void>();
}







/// Rotate / Pan mode buttons for the (vertical) canvas toolbar (HTML `setMode`).
class _rt_RotatePanToggle extends StatelessWidget {
  const _rt_RotatePanToggle({super.key, required this.controller, this.accent = _rt_Tw.teal600});

  final _rt_Scene3DController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        Widget b(_rt_DragMode m, IconData icon, String tip) {
          final active = controller.mode == m;
          return Tooltip(
            message: tip,
            child: InkResponse(
              radius: 22,
              onTap: () {
                _rt_playSfx(_rt_Sfx.tap);
                controller.setMode(m);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active ? accent : _rt_Lab.surface,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 6)]
                      : null,
                ),
                child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
              ),
            ),
          );
        }

        return Column(mainAxisSize: MainAxisSize.min, children: [
          b(_rt_DragMode.rotate, Icons.threesixty, _rt_tr('Rotate', 'घुमाएँ')),
          const SizedBox(height: 4),
          b(_rt_DragMode.pan, Icons.pan_tool_outlined, _rt_tr('Pan', 'खिसकाएँ')),
        ]);
      },
    );
  }
}

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'app_title': 'Particulate Nature of Matter',
    'class_chap': 'Class 8 • Particulate Nature of Matter',
    'enter_lab': 'Enter _rt_Lab',
    'inv_proto': 'Investigation Protocol',
    'mission_obj': 'Mission Objective',
    'active': 'ACTIVE',
    'pending': 'PENDING',
    'completed': 'COMPLETED',
    'final_obs': 'Final Observation',
    'select_new': 'Select a new protocol from the sidebar to continue.',
    'time_lapse': 'Time Lapse',
    'obs_quiz': 'Observation',
    's3_q': 'What causes the mixing against gravity?',
    's3_opt1': 'A: Gravity pulling color up',
    's3_opt2': 'B: Constant random motion',
    'btn_verify': 'Confirm No Particles Visible',
    'conclusion': 'Conclusion',
    's5_pt1': 'The salt broke down into individual ',
    's5_pt2': ' which were too ',
    's5_pt3': ' to be seen.',
    'drag_tap_inst': 'Tap words below to fill the gaps',
    'err_incorrect': 'Incorrect word.',
    'err_gravity': 'Incorrect. Gravity pulls downwards.',
    'msg_correct': 'Correct!',
    'msg_evap': 'Evaporation complete. Click the white residue.',
    'msg_residue': 'Residue Identified! Complete the conclusion.',
    'msg_setup': 'Setup complete. Click Burner base to ignite.',
    'msg_sugar': 'Sugar added. Now drag Stirring Rod in circles to dissolve.',
    'msg_clear': 'Clear view. Click Confirm Button.',
    'err_follow': 'Follow HUD instructions explicitly to proceed.',
    'err_try_again': 'Try again.',
    'viewing_past': 'Review: Viewing past step visual state.',
    'load_success': 'Investigation successful. Select a new protocol.',
    'view_locked': 'View Locked',
    'view_unlocked': 'View Unlocked',
    'labels_on': 'Labels ON',
    'labels_off': 'Labels OFF',
    'min_short': 'min',
    'btn_auto': 'Do This Step',
    'lbl_step': 'Step',
    'tool_labels': 'Toggle Labels',
    'tool_lock': 'Lock View',
    'word_molecules': 'molecules',
    'word_small': 'small',
    'word_drops': 'drops',
    'word_heavy': 'heavy',
    'lbl_chalk': 'Chalk Stick',
    'lbl_hammer': 'Hammer',
    'lbl_mortar': 'Mortar',
    'lbl_pestle': 'Pestle',
    'lbl_mag': 'Magnifier',
    'lbl_water_100': 'Water (100mL)',
    'lbl_marker': 'Marker Pen',
    'lbl_spoon': 'Spoon',
    'lbl_stir': 'Stirring Rod',
    'lbl_sugar_mol': 'Sugar Molecule',
    'lbl_water': 'Water',
    'lbl_forceps': 'Forceps',
    'lbl_stones': 'Stones Bucket',
    'lbl_water_bucket': 'Water Bucket',
    'lbl_locked_grid': 'Locked Grid',
    'lbl_sliding': 'Sliding Grid',
    'lbl_ocean': 'Ocean Water',
    'lbl_burner': 'Bunsen Burner',
    'lbl_salt': 'Salt Residue',
    's1_t': 'Breaking Chalk',
    's1_o': 'Demonstrate that matter which appears continuous is actually made of smaller particles.',
    's1_s': 'By breaking and grinding chalk, we successfully observed that continuous-looking solid matter is actually composed of distinct, microscopic grains.',
    's1_st1_t': 'Mechanical Breakdown',
    's1_st1_th': 'Matter may look like a single continuous block, but it is made of tiny particles. Let us investigate a stick of chalk.',
    's1_st1_h': 'Drag the Hammer onto the Chalk Stick to shatter it.',
    's1_st1_c': 'The solid chalk breaks into chunks, showing it is not a single indivisible object.',
    's1_st2_t': 'Collect Pieces',
    's1_st2_th': 'The broken chunks still represent the exact same matter, just broken into physically smaller macroscopic units.',
    's1_st2_h': 'Drag the Chalk Chunks into the Mortar.',
    's1_st2_c': 'Chunks are collected inside the mortar.',
    's1_st3_t': 'Grinding to Powder',
    's1_st3_th': 'Convert the chalk pieces into a fine powder by applying continuous mechanical force.',
    's1_st3_h': 'Drag the Pestle in continuous circles inside the Mortar.',
    's1_st3_c': 'The chalk is now a fine powder, appearing smooth.',
    's1_st4_t': 'Microscopic Observation',
    's1_st4_th': 'Observe the powder to see the smallest visible grains.',
    's1_st4_h': 'Drag the Magnifying Glass over the chalk powder.',
    's1_st4_c': 'Zooming in reveals distinct individual grains.',
    's1_st5_t': 'Identify Particles',
    's1_st5_th': 'Even the finest dust consists of distinct individual particles.',
    's1_st5_h': 'Click inside the mortar to confirm.',
    's1_st5_c': 'Particle identified! Matter is particulate.',
    's2_t': 'Sugar in Water',
    's2_o': 'Demonstrate that particles of matter have spaces between them (inter-particle spaces).',
    's2_s': 'By dissolving sugar in water, we proved that matter contains intermolecular spaces which particles of another substance can occupy without increasing volume.',
    's2_st1_t': 'Mark Initial Level',
    's2_st1_th': 'When a solid dissolves in a liquid, does the volume increase? Mark the level first.',
    's2_st1_h': 'Drag the Marker Pen to the Beaker to mark the 100 mL line.',
    's2_st1_c': 'Initial water level marked perfectly.',
    's2_st2_t': 'Dissolving Solute',
    's2_st2_th': 'Add the sugar and stir until completely dissolved. Watch the water level.',
    's2_st2_h': 'Drag Spoon to beaker, then drag Stirring Rod in circles inside beaker to dissolve.',
    's2_st2_c': 'Sugar dissolves. The total volume remains remarkably constant!',
    's2_st3_t': 'Molecular Observation',
    's2_st3_th': 'Switch to Molecular View to see where the sugar particles went.',
    's2_st3_h': 'Tap 3 orange sugar particles to fill the empty voids.',
    's2_st3_c': 'Sugar molecules occupy intermolecular spaces between water molecules.',
    's3_t': 'KMnO4 Diffusion',
    's3_o': 'Demonstrate that particles of matter are in constant motion (Diffusion).',
    's3_s': 'The unassisted spreading of highly colored KMnO4 proves that particles of matter possess kinetic energy and are in continuous random motion.',
    's3_st1_t': 'Introduction of Solute',
    's3_st1_th': 'Particles of matter are continuously moving. We will observe this using a colored crystal.',
    's3_st1_h': 'Drag the Forceps to the beaker to place the crystal.',
    's3_st1_c': 'The crystal sits at the bottom. Color begins to spread.',
    's3_st2_t': 'Observing Motion Over Time',
    's3_st2_th': 'Observe how the particles spread over time without any stirring.',
    's3_st2_h': 'Use the Time Slider at the bottom of the screen.',
    's3_st2_c': 'The entire bulk of water becomes uniformly purple.',
    's3_st3_t': 'Identify Phenomenon',
    's3_st3_th': 'Based on observation, what causes the mixing?',
    's3_st3_h': 'Select the correct option from the quiz overlay.',
    's3_st3_c': 'Correct! Constant random motion of particles causes diffusion.',
    's4_t': 'Piling Stones vs. Water',
    's4_o': 'Explain why solids can be piled (fixed shape) but liquids cannot (fluidity), based on particle arrangement.',
    's4_s': 'Solids can be piled due to strong forces locking their particles, whereas liquids flow because their particles slide past each other.',
    's4_st1_t': 'Piling Solids',
    's4_st1_th': 'Why is it possible to pile up stones or sand?',
    's4_st1_h': 'Click the Bucket of Stones 3 times to pour them.',
    's4_st1_c': 'Stones stack on top of each other forming a rigid pile.',
    's4_st2_t': 'Piling Liquids',
    's4_st2_th': 'Liquids behave differently under gravity due to their particulate nature.',
    's4_st2_h': 'Click the Bucket of Water 3 times to pour it.',
    's4_st2_c': 'Water pours out and immediately spreads flat. It does not stack.',
    's4_st3_t': 'Particle Arrangement',
    's4_st3_th': 'Match the internal particle arrangement to the macro behavior.',
    's4_st3_h': "Drag 'Locked Grid' to the Stones, and 'Sliding' to the Water puddle.",
    's4_st3_c': 'Water particles slide over each other freely, preventing a pile.',
    's5_t': 'Salty Ocean Water',
    's5_o': 'Explain that matter exists even when invisible (dissolved particles are too small to see).',
    's5_s': 'Evaporation successfully separated the liquid solvent from the solid solute, proving dissolved matter exists invisibly.',
    's5_st1_t': 'Verification of Invisibility',
    's5_st1_th': 'Why does ocean water taste salty even though salt is not visible?',
    's5_st1_h': "Drag Magnifier over water, then click 'Confirm No Particles Visible'.",
    's5_st1_c': 'No visible particles exist at standard magnification.',
    's5_st2_t': 'Proving Existence (Heating)',
    's5_st2_th': 'Heat the water to separate the components.',
    's5_st2_h': 'Drag Beaker to Tripod, then click Bunsen Burner base to ignite.',
    's5_st2_c': 'Water evaporates as gas, separating solvent from solute.',
    's5_st3_t': 'Identification & Conclusion',
    's5_st3_th': 'Identify the residue and explain the phenomenon.',
    's5_st3_h': 'Click the white Salt Residue, then complete the conclusion below.',
    's5_st3_c': 'Correct! The particles break down into molecules too small to see.',
  },
  'hi': {
    'app_title': 'पदार्थ की कणिकीय प्रकृति',
    'class_chap': 'कक्षा 8 • पदार्थ की कणिकीय प्रकृति',
    'enter_lab': 'लैब में प्रवेश करें',
    'inv_proto': 'जांच प्रोटोकॉल',
    'mission_obj': 'मिशन का उद्देश्य',
    'active': 'सक्रिय',
    'pending': 'लंबित',
    'completed': 'पूर्ण',
    'final_obs': 'अंतिम अवलोकन',
    'select_new': 'जारी रखने के लिए साइडबार से एक नया प्रोटोकॉल चुनें।',
    'time_lapse': 'टाइम लैप्स',
    'obs_quiz': 'अवलोकन',
    's3_q': 'गुरुत्वाकर्षण के विपरीत मिश्रण का क्या कारण है?',
    's3_opt1': 'A: गुरुत्वाकर्षण रंग को ऊपर खींच रहा है',
    's3_opt2': 'B: निरंतर यादृच्छिक गति',
    'btn_verify': 'पुष्टि करें: कोई कण नहीं दिख रहा है',
    'conclusion': 'निष्कर्ष',
    's5_pt1': 'नमक अलग-अलग ',
    's5_pt2': ' में टूट गया, जो देखने के लिए बहुत ',
    's5_pt3': ' थे।',
    'drag_tap_inst': 'रिक्त स्थान भरने के लिए नीचे दिए गए शब्दों पर टैप करें',
    'err_incorrect': 'गलत शब्द।',
    'err_gravity': 'गलत। गुरुत्वाकर्षण नीचे की ओर खींचता है।',
    'msg_correct': 'सही!',
    'msg_evap': 'वाष्पीकरण पूर्ण। सफेद अवशेष पर क्लिक करें।',
    'msg_residue': 'अवशेष की पहचान हो गई! निष्कर्ष पूरा करें।',
    'msg_setup': 'सेटअप पूर्ण। जलाने के लिए बर्नर बेस पर क्लिक करें।',
    'msg_sugar': 'चीनी डाली गई। अब घोलने के लिए सरगर्मी छड़ को गोल घुमाएं।',
    'msg_clear': 'साफ़ दृश्य। पुष्टि करें बटन पर क्लिक करें।',
    'err_follow': 'आगे बढ़ने के लिए HUD निर्देशों का स्पष्ट रूप से पालन करें।',
    'err_try_again': 'पुनः प्रयास करें।',
    'viewing_past': 'समीक्षा: पिछले चरण की दृश्य स्थिति देख रहे हैं।',
    'load_success': 'जांच सफल रही। एक नया प्रोटोकॉल चुनें।',
    'view_locked': 'दृश्य लॉक',
    'view_unlocked': 'दृश्य अनलॉक',
    'labels_on': 'लेबल चालू',
    'labels_off': 'लेबल बंद',
    'min_short': 'मिनट',
    'btn_auto': 'यह चरण करें',
    'lbl_step': 'चरण',
    'tool_labels': 'लेबल टॉगल करें',
    'tool_lock': 'दृश्य लॉक करें',
    'word_molecules': 'अणुओं',
    'word_small': 'छोटे',
    'word_drops': 'बूंदों',
    'word_heavy': 'भारी',
    'lbl_chalk': 'चाक स्टिक',
    'lbl_hammer': 'हथौड़ा',
    'lbl_mortar': 'खरल',
    'lbl_pestle': 'मूसल',
    'lbl_mag': 'आवर्धक लेंस',
    'lbl_water_100': 'पानी (100mL)',
    'lbl_marker': 'मार्कर पेन',
    'lbl_spoon': 'चम्मच',
    'lbl_stir': 'हिलाने वाली छड़',
    'lbl_sugar_mol': 'चीनी का अणु',
    'lbl_water': 'पानी',
    'lbl_forceps': 'चिमटी',
    'lbl_stones': 'पत्थरों की बाल्टी',
    'lbl_water_bucket': 'पानी की बाल्टी',
    'lbl_locked_grid': 'लॉक्ड ग्रिड',
    'lbl_sliding': 'स्लाइडिंग',
    'lbl_ocean': 'समुद्र का पानी',
    'lbl_burner': 'बुन्सेन बर्नर',
    'lbl_salt': 'नमक का अवशेष',
    's1_t': 'चाक तोड़ना',
    's1_o': 'प्रदर्शित करें कि जो पदार्थ निरंतर दिखाई देता है वह वास्तव में छोटे कणों से बना है।',
    's1_s': 'चाक को तोड़कर और पीसकर, हमने सफलतापूर्वक देखा कि निरंतर दिखने वाला ठोस पदार्थ वास्तव में अलग-अलग, सूक्ष्म कणों से बना है।',
    's1_st1_t': 'यांत्रिक टूटना',
    's1_st1_th': 'पदार्थ एक एकल निरंतर ब्लॉक की तरह लग सकता है, लेकिन यह छोटे कणों से बना है। आइए चाक की एक छड़ी की जांच करें।',
    's1_st1_h': 'हथौड़े को चाक स्टिक पर खींचकर उसे तोड़ दें।',
    's1_st1_c': 'ठोस चाक टुकड़ों में टूट जाता है, जिससे पता चलता है कि यह एक अविभाज्य वस्तु नहीं है।',
    's1_st2_t': 'टुकड़े इकट्ठा करें',
    's1_st2_th': 'टूटे हुए टुकड़े अभी भी उसी पदार्थ का प्रतिनिधित्व करते हैं, बस भौतिक रूप से छोटी स्थूल इकाइयों में टूट गए हैं।',
    's1_st2_h': 'चाक के टुकड़ों को खरल में खींचें।',
    's1_st2_c': 'टुकड़ों को खरल के अंदर एकत्र कर लिया गया है।',
    's1_st3_t': 'पीसकर पाउडर बनाना',
    's1_st3_th': 'लगातार यांत्रिक बल लगाकर चाक के टुकड़ों को महीन पाउडर में बदलें।',
    's1_st3_h': 'खरल के अंदर मूसल को लगातार गोल-गोल घुमाएं।',
    's1_st3_c': 'चाक अब एक महीन पाउडर है, जो चिकना दिखाई दे रहा है।',
    's1_st4_t': 'सूक्ष्मदर्शी से अवलोकन',
    's1_st4_th': 'सबसे छोटे दृश्यमान कणों को देखने के लिए पाउडर का निरीक्षण करें।',
    's1_st4_h': 'चाक पाउडर पर आवर्धक लेंस को खींचें।',
    's1_st4_c': 'ज़ूम इन करने से अलग-अलग कण दिखाई देते हैं।',
    's1_st5_t': 'कणों की पहचान करें',
    's1_st5_th': 'यहाँ तक कि सबसे महीन धूल भी अलग-अलग कणों से बनी होती है।',
    's1_st5_h': 'पुष्टि करने के लिए खरल के अंदर क्लिक करें।',
    's1_st5_c': 'कण की पहचान हो गई! पदार्थ कणिक है।',
    's2_t': 'पानी में चीनी',
    's2_o': 'प्रदर्शित करें कि पदार्थ के कणों के बीच रिक्त स्थान (अंतर-कणीय स्थान) होता है।',
    's2_s': 'पानी में चीनी घोलकर, हमने साबित किया कि पदार्थ में अंतर-आणविक स्थान होते हैं जिन्हें किसी अन्य पदार्थ के कण आयतन बढ़ाए बिना घेर सकते हैं।',
    's2_st1_t': 'प्रारंभिक स्तर चिह्नित करें',
    's2_st1_th': 'जब कोई ठोस किसी तरल में घुलता है, तो क्या आयतन बढ़ता है? पहले स्तर को चिह्नित करें।',
    's2_st1_h': '100 mL लाइन को चिह्नित करने के लिए मार्कर पेन को बीकर तक खींचें।',
    's2_st1_c': 'प्रारंभिक जल स्तर पूरी तरह से चिह्नित किया गया।',
    's2_st2_t': 'विलेय को घोलना',
    's2_st2_th': 'चीनी डालें और पूरी तरह घुलने तक हिलाएं। जल स्तर देखें।',
    's2_st2_h': 'चम्मच को बीकर में खींचें, फिर घोलने के लिए बीकर के अंदर सरगर्मी छड़ को गोल घुमाएं।',
    's2_st2_c': 'चीनी घुल जाती है। कुल आयतन स्थिर रहता है!',
    's2_st3_t': 'आणविक अवलोकन',
    's2_st3_th': 'चीनी के कण कहाँ गए, यह देखने के लिए आणविक दृश्य पर स्विच करें।',
    's2_st3_h': 'खाली स्थानों को भरने के लिए 3 चीनी कणों पर टैप करें।',
    's2_st3_c': 'चीनी के अणु पानी के अणुओं के बीच अंतर-आणविक स्थानों पर कब्जा कर लेते हैं।',
    's3_t': 'KMnO4 प्रसार',
    's3_o': 'प्रदर्शित करें कि पदार्थ के कण निरंतर गति में हैं (प्रसार)।',
    's3_s': 'अत्यधिक रंगीन KMnO4 का बिना सहायता के फैलना यह साबित करता है कि पदार्थ के कणों में गतिज ऊर्जा होती है और वे निरंतर यादृच्छिक गति में होते हैं।',
    's3_st1_t': 'विलेय का परिचय',
    's3_st1_th': 'पदार्थ के कण निरंतर गतिमान रहते हैं। हम एक रंगीन क्रिस्टल का उपयोग करके इसका निरीक्षण करेंगे।',
    's3_st1_h': 'क्रिस्टल को रखने के लिए चिमटी को बीकर तक खींचें।',
    's3_st1_c': 'क्रिस्टल तल पर बैठ जाता है। रंग फैलने लगता है।',
    's3_st2_t': 'समय के साथ गति का अवलोकन',
    's3_st2_th': 'ध्यान दें कि बिना हिलाए कण समय के साथ कैसे फैलते हैं।',
    's3_st2_h': 'स्क्रीन के नीचे टाइम स्लाइडर का उपयोग करें।',
    's3_st2_c': 'पानी का पूरा भाग समान रूप से बैंगनी हो जाता है।',
    's3_st3_t': 'घटना की पहचान',
    's3_st3_th': 'अवलोकन के आधार पर, मिश्रण का कारण क्या है?',
    's3_st3_h': 'क्विज़ ओवरले से सही विकल्प चुनें।',
    's3_st3_c': 'सही! कणों की निरंतर यादृच्छिक गति प्रसार का कारण बनती है।',
    's4_t': 'पत्थरों का ढेर बनाम पानी',
    's4_o': 'कण व्यवस्था के आधार पर समझाएं कि ठोस पदार्थों का ढेर क्यों लगाया जा सकता है लेकिन तरल पदार्थों का नहीं।',
    's4_s': 'ठोस पदार्थों का ढेर लगाया जा सकता है क्योंकि मजबूत बल उनके कणों को लॉक कर देते हैं, जबकि तरल पदार्थ बहते हैं क्योंकि उनके कण एक दूसरे पर फिसलते हैं।',
    's4_st1_t': 'ठोस का ढेर लगाना',
    's4_st1_th': 'पत्थरों या रेत का ढेर लगाना क्यों संभव है?',
    's4_st1_h': 'उन्हें डालने के लिए पत्थरों की बाल्टी पर 3 बार क्लिक करें।',
    's4_st1_c': 'पत्थर एक के ऊपर एक चढ़कर एक कठोर ढेर बनाते हैं।',
    's4_st2_t': 'तरल का ढेर लगाना',
    's4_st2_th': 'तरल पदार्थ अपनी कण प्रकृति के कारण गुरुत्वाकर्षण के तहत अलग व्यवहार करते हैं।',
    's4_st2_h': 'इसे डालने के लिए पानी की बाल्टी पर 3 बार क्लिक करें।',
    's4_st2_c': 'पानी बाहर निकलता है और तुरंत सपाट फैल जाता है। यह ढेर नहीं बनता है।',
    's4_st3_t': 'कणों की व्यवस्था',
    's4_st3_th': 'वृहद व्यवहार के साथ आंतरिक कण व्यवस्था का मिलान करें।',
    's4_st3_h': "'लॉक्ड ग्रिड' को पत्थरों पर और 'स्लाइडिंग' को पानी पर खींचें।",
    's4_st3_c': 'पानी के कण एक-दूसरे पर स्वतंत्र रूप से फिसलते हैं, जिससे ढेर नहीं बन पाता।',
    's5_t': 'खारा समुद्री जल',
    's5_o': 'स्पष्ट करें कि पदार्थ तब भी मौजूद रहता है जब वह अदृश्य होता है (घुले हुए कण देखने के लिए बहुत छोटे होते हैं)।',
    's5_s': 'वाष्पीकरण ने ठोस विलेय से तरल विलायक को सफलतापूर्वक अलग कर दिया, जिससे साबित होता है कि घुला हुआ पदार्थ अदृश्य रूप से मौजूद है।',
    's5_st1_t': 'अदृश्यता का सत्यापन',
    's5_st1_th': 'नमक न दिखने पर भी समुद्र का पानी खारा क्यों लगता है?',
    's5_st1_h': "पानी पर मैग्निफायर को खींचें, फिर 'पुष्टि करें' पर क्लिक करें।",
    's5_st1_c': 'मानक आवर्धन पर कोई दृश्य कण मौजूद नहीं हैं।',
    's5_st2_t': 'अस्तित्व सिद्ध करना (हीटिंग)',
    's5_st2_th': 'घटकों को अलग करने के लिए पानी को गर्म करें।',
    's5_st2_h': 'बीकर को ट्राइपॉड पर खींचें, फिर जलाने के लिए बुन्सेन बर्नर बेस पर क्लिक करें।',
    's5_st2_c': 'विलायक को विलेय से अलग करते हुए पानी गैस के रूप में वाष्पित हो जाता है।',
    's5_st3_t': 'पहचान और निष्कर्ष',
    's5_st3_th': 'अवशेष की पहचान करें और घटना की व्याख्या करें।',
    's5_st3_h': 'सफेद नमक अवशेष पर क्लिक करें, फिर नीचे निष्कर्ष पूरा करें।',
    's5_st3_c': 'सही! कण इतने छोटे अणुओं में टूट जाते हैं जिन्हें देखा नहीं जा सकता।',
  },
});

// Step id lists per protocol (source getScenarios()).
const List<List<String>> _stepIds = [
  ['s1_break', 's1_fill', 's1_grind', 's1_magnify', 's1_identify'],
  ['s2_mark', 's2_dissolve', 's2_view'],
  ['s3_drop', 's3_time', 's3_quiz'],
  ['s4_solid', 's4_liquid', 's4_explain'],
  ['s5_verify', 's5_evaporate', 's5_identify'],
];

// Which steps have a sidebar auto-action fallback button.
const Set<String> _autoSteps = {
  's1_break', 's1_fill', 's1_grind', 's1_magnify', 's1_identify',
  's2_mark', 's2_dissolve', 's2_view',
  's3_drop',
  's4_solid', 's4_liquid', 's4_explain',
  's5_verify', 's5_evaporate', 's5_identify',
};

// Interactive object names per protocol (for the source err_follow toast).
const List<Set<String>> _interactives = [
  {'chalk', 'hammer', 'chunk', 'mortar', 'pestle', 'magnifier'},
  {'marker', 'spoon', 'stir', 'beaker', 'mol'},
  {'forceps', 'beaker'},
  {'bucket_stones', 'bucket_water', 'diag1', 'diag2'},
  {'beaker', 'burner', 'magnifier', 'residue'},
];

const _cAccent = _rt_Tw.sky500;
const _cWater = Color(0xFF00D4FF);
const _cPurple = Color(0xFFA855F7);
const _cGlassTint = Color(0xFFE0F7FA);

class Cl8Ch07A1ParticulateNatureOfMatterPage extends StatefulWidget {
  const Cl8Ch07A1ParticulateNatureOfMatterPage({super.key});

  @override
  State<Cl8Ch07A1ParticulateNatureOfMatterPage> createState() =>
      _Cl8Ch07A1ParticulateNatureOfMatterPageState();
}

class _Cl8Ch07A1ParticulateNatureOfMatterPageState
    extends State<Cl8Ch07A1ParticulateNatureOfMatterPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(background: const Color(0xFF0F172A));
  final _rt_Camera3D _camera =
      _rt_Camera3D(fov: 40, position: _rt_V3(0, 6, 16), target: _rt_V3(0, 2, 0));
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  late final _rt_Node3D _world;

  // --- LAB STATE (source globals) ---
  int _scenario = 1;
  int _step = 0; // currentStepIndex
  int _viewStep = 0; // viewingStepIndex
  int _gen = 0;
  bool _labelsOn = true;
  bool _locked = true; // source screenLocked (camera orbit disabled)
  double _time = 0;
  final List<(_rt_Label3D, String)> _labels = [];

  // Drag state.
  _rt_Node3D? _drag;
  String _dragName = '';
  double _dragY = 0;
  final _rt_V3 _dragOrigin = _rt_V3();

  // Scenario 1.
  _rt_Node3D? _chalk, _hammer, _mortar, _pestle, _mag1;
  final List<_rt_Node3D> _chunks = [];
  _rt_Points3D? _powder;
  int _chunksIn = 0;
  double _grindAcc = 0;
  double? _lastGrindAngle;

  // Scenario 2.
  _rt_Node3D? _beaker2, _marker, _spoon, _stir, _molG;
  _rt_Mesh3D? _liquid2, _ring2, _cube;
  final List<_rt_Sphere3D> _mols = [];
  final List<_rt_Node3D> _voids = [];
  bool _sugarInWater = false;
  bool _dissolved = false;
  double _stirAcc = 0;
  double? _lastStirAngle;
  int _molsIn = 0;

  // Scenario 3.
  _rt_Node3D? _beaker3, _forceps;
  _rt_Mesh3D? _crystal;
  _rt_Material3D? _liquid3Mat;
  double _s3T = 0;

  // Scenario 4.
  _rt_Node3D? _bucketS, _bucketW, _pileG1, _pileG2, _diag1, _diag2;
  _rt_Mesh3D? _puddle;
  int _clicksS = 0, _clicksW = 0, _diagsPlaced = 0;

  // Scenario 5.
  _rt_Node3D? _beaker5, _tripod, _burner, _mag5, _steam;
  _rt_Mesh3D? _liquid5, _flame, _residue;
  bool _verifyOk = false, _tbSet = false, _evaporating = false;
  double _evap = 0;
  bool _drop1 = false, _drop2 = false;
  int _activeDrop = 1;
  final Set<String> _usedWords = {};

  List<String> get _steps => _stepIds[_scenario - 1];
  String get _stepId => _step < _steps.length ? _steps[_step] : '';
  String _base(int i) => 's${_scenario}_st${i + 1}';
  bool get _scenarioDone => _step >= _steps.length;
  bool get _interactable => _viewStep == _step && !_scenarioDone;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initStaticScene();
    _world = _scene.add(_rt_Node3D(name: 'world'));
    _loadScenario(1, silent: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _tweens.cancelAll();
    _viewCtrl.dispose();
    super.dispose();
  }

  bool _alive(int gen) => mounted && gen == _gen;

  // ------------------------------------------------------------- toasts ---
  void _toastOk(String key) {
    _shell.showToast(_tx.s(key), color: _rt_Tw.green500, icon: Icons.check_circle);
  }

  void _toastErr(String key) {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(_tx.s(key), color: _rt_Tw.red500, icon: Icons.cancel);
  }

  // -------------------------------------------------------------- scene ---
  void _initStaticScene() {
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.7),
      _rt_Light3D.directional(_rt_V3(5, 10, 8), intensity: 1.1),
    ]);
    // Source table: BoxGeometry(20, 0.5, 12) #334155. Rendered as a
    // subdivided plane so painter sorting never hides far objects under it.
    _scene.add(_rt_Mesh3D(
        _rt_Geometry3D.plane(20, 12, widthSegments: 10, heightSegments: 6),
        _rt_Material3D(color: const Color(0xFF334155)))
      ..rotation.x = -math.pi / 2
      ..pickable = false);
    // Thin visible front edge of the table top.
    _scene.add(_rt_Mesh3D(_rt_Geometry3D.plane(20, 0.5),
        _rt_Material3D(color: const Color(0xFF283548)))
      ..position.set(0, -0.25, 6)
      ..pickable = false);
  }

  _rt_Label3D _label(String key, _rt_Node3D parent, _rt_V3 offset) {
    final l = _rt_Label3D(_tx.s(key),
        position: offset,
        pixelHeight: 11,
        color: Colors.white,
        background: const Color(0xE60F172A),
        borderColor: _cAccent);
    l.pickable = false;
    parent.add(l);
    _labels.add((l, key));
    return l;
  }

  void _syncLabels() {
    for (final (l, key) in _labels) {
      l.text = _tx.s(key);
      l.visible = _labelsOn;
    }
  }

  _rt_Material3D _glassMat() => _rt_Material3D(
      color: _cGlassTint, opacity: 0.18, doubleSided: true, shininess: 0.4);

  /// Source createBeakerGroup: glass wall + bottom + rim + graduations +
  /// liquid. Returns (group, liquid mesh).
  (_rt_Node3D, _rt_Mesh3D) _buildBeaker({Color liquidColor = _cWater}) {
    final g = _rt_Node3D(name: 'beaker');
    g.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(2, 2, 5, segments: 20, openEnded: true), _glassMat())
      ..position.y = 2.5);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2, 2, 0.1, segments: 20), _glassMat())
      ..position.y = 0.05);
    g.add(_rt_Mesh3D(
        _rt_Geometry3D.torus(2, 0.1, radialSegments: 6, tubularSegments: 20),
        _rt_Material3D(color: _cGlassTint, opacity: 0.5, shininess: 0.5))
      ..rotation.x = math.pi / 2
      ..position.y = 5
      ..pickable = false);
    // Graduation marks, the 4th (100 mL) red.
    for (var i = 1; i < 5; i++) {
      g.add(_rt_Mesh3D(
          _rt_Geometry3D.plane(0.6, 0.08),
          _rt_Material3D(
              color: i == 4 ? _rt_Tw.red500 : Colors.white, unlit: true))
        ..position.set(0, i.toDouble(), 2.05)
        ..pickable = false);
    }
    final liquid = _rt_Mesh3D(_rt_Geometry3D.cylinder(1.9, 1.9, 3, segments: 18),
        _rt_Material3D(color: liquidColor, opacity: 0.85, shininess: 0.3))
      ..position.y = 1.55
      ..pickable = false;
    g.add(liquid);
    return (g, liquid);
  }

  /// Source createMagnifier: dark ring frame, translucent lens, handle.
  _rt_Node3D _buildMagnifier() {
    final mag = _rt_Node3D(name: 'magnifier');
    mag.add(_rt_Mesh3D(
        _rt_Geometry3D.torus(1.2, 0.25, radialSegments: 6, tubularSegments: 20),
        _rt_Material3D(color: const Color(0xFF1E293B))));
    mag.add(_rt_Mesh3D(_rt_Geometry3D.circle(1.1, segments: 20),
        _rt_Material3D(color: const Color(0xFFA5F3FC), opacity: 0.45, doubleSided: true)));
    mag.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.22, 0.22, 2.5, segments: 10),
        _rt_Material3D(color: const Color(0xFF0F172A)))
      ..rotation.z = math.pi / 4
      ..position.set(1.7, -1.7, 0));
    mag.rotation.x = -math.pi / 6;
    return mag;
  }

  void _clearWorld() {
    _world.clear();
    _labels.clear();
    _chalk = _hammer = _mortar = _pestle = _mag1 = null;
    _chunks.clear();
    _powder = null;
    _beaker2 = _marker = _spoon = _stir = _molG = null;
    _liquid2 = _ring2 = _cube = null;
    _mols.clear();
    _voids.clear();
    _beaker3 = _forceps = null;
    _crystal = null;
    _liquid3Mat = null;
    _bucketS = _bucketW = _pileG1 = _pileG2 = _diag1 = _diag2 = null;
    _puddle = null;
    _beaker5 = _tripod = _burner = _mag5 = _steam = null;
    _liquid5 = _flame = _residue = null;
    _drag = null;
  }

  // Source buildScenario1.
  void _buildS1() {
    _chalk = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.3, 0.3, 4, segments: 12),
        _rt_Material3D(color: Colors.white),
        name: 'chalk')
      ..rotation.z = math.pi / 2
      ..position.set(0, 0.3, 0));
    _label('lbl_chalk', _chalk!, _rt_V3(2.2, 0, 0));

    final h = _rt_Node3D(name: 'hammer');
    h.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.1, 0.1, 3, segments: 8),
        _rt_Material3D(color: const Color(0xFF8B4513)))
      ..position.y = 1.5);
    h.add(_rt_Mesh3D(_rt_Geometry3D.box(0.8, 0.6, 0.6),
        _rt_Material3D(color: const Color(0xFF64748B), metalness: 0.5, shininess: 0.5))
      ..position.y = 3);
    h.position.set(3, 0.5, 2);
    _hammer = _world.add(h);
    _label('lbl_hammer', _hammer!, _rt_V3(0, 3.9, 0));

    _mortar = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.lathe(const [
          Offset(0.02, 0),
          Offset(1.2, 0),
          Offset(1.5, 1),
          Offset(1.3, 1),
          Offset(1.0, 0.2),
          Offset(0.02, 0.2),
        ], segments: 20),
        _rt_Material3D(color: const Color(0xFF334155), doubleSided: true),
        name: 'mortar')
      ..position.set(0, 0.25, -3));
    _label('lbl_mortar', _mortar!, _rt_V3(0, 1.9, 0));

    _pestle = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.2, 0.4, 2, segments: 10),
        _rt_Material3D(color: const Color(0xFF94A3B8)),
        name: 'pestle')
      ..position.set(3, 1, -3)
      ..visible = false);
    _label('lbl_pestle', _pestle!, _rt_V3(0, 1.6, 0));

    _mag1 = _world.add(_buildMagnifier()
      ..position.set(-4, 1.5, 0)
      ..visible = false);
    _label('lbl_mag', _mag1!, _rt_V3(0, 1.8, 0));

    final rnd = math.Random(11);
    for (var i = 0; i < 3; i++) {
      final piece = _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.4, 0.4, 1.2, segments: 10),
          _rt_Material3D(color: Colors.white),
          name: 'chunk')
        ..position.set(-1.5 + i * 1.5, 0.4, 0)
        ..visible = false;
      piece.rotation.set(rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble());
      piece.userData['live'] = true;
      _chunks.add(_world.add(piece));
    }
  }

  void _ensurePowder() {
    if (_powder != null) return;
    final m = _mortar!.position;
    final rnd = math.Random(5);
    final pts = <_rt_V3>[];
    for (var i = 0; i < 450; i++) {
      final r = rnd.nextDouble() * 0.9;
      final t = rnd.nextDouble() * 2 * math.pi;
      pts.add(_rt_V3(m.x + r * math.cos(t),
          0.5 + math.max(0, (1 - r) * 0.25), m.z + r * math.sin(t)));
    }
    _powder = _world.add(_rt_Points3D(pts,
        color: Colors.white, size: 5, opacity: 0.9, name: 'powder')
      ..pickable = false);
  }

  // Source buildScenario2.
  void _buildS2() {
    final (g, liquid) = _buildBeaker();
    _beaker2 = _world.add(g..position.set(0, 0.5, 0));
    _liquid2 = liquid;
    _label('lbl_water_100', _beaker2!, _rt_V3(0, 5.6, 0));

    _marker = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.1, 0.1, 1.5, segments: 8),
        _rt_Material3D(color: _rt_Tw.red500),
        name: 'marker')
      ..rotation.x = math.pi / 2
      ..position.set(-4, 0.5, 2));
    _label('lbl_marker', _marker!, _rt_V3(0, 0, -1.8));

    _ring2 = _rt_Mesh3D(
        _rt_Geometry3D.torus(2.02, 0.06, radialSegments: 5, tubularSegments: 20),
        _rt_Material3D(color: _rt_Tw.red500, unlit: true))
      ..rotation.x = math.pi / 2
      ..position.y = 4.5
      ..visible = false
      ..pickable = false;
    _beaker2!.add(_ring2!);

    final sp = _rt_Node3D(name: 'spoon');
    sp.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.05, 0.05, 2, segments: 8),
        _rt_Material3D(color: const Color(0xFF94A3B8), metalness: 0.6, shininess: 0.5))
      ..rotation.z = math.pi / 2);
    sp.add(_rt_Sphere3D(0.24,
        _rt_Material3D(color: const Color(0xFF94A3B8), metalness: 0.5, shininess: 0.5))
      ..position.set(-1.15, 0.05, 0));
    _cube = _rt_Mesh3D(_rt_Geometry3D.box(0.32, 0.32, 0.32),
        _rt_Material3D(color: Colors.white))
      ..position.set(-1.15, 0.3, 0);
    sp.add(_cube!);
    sp.position.set(4, 0.5, 2);
    sp.visible = false;
    _spoon = _world.add(sp);
    _label('lbl_spoon', _spoon!, _rt_V3(0, 1.6, 0));

    _stir = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.06, 0.06, 4, segments: 8),
        _rt_Material3D(color: _rt_Tw.sky400, shininess: 0.4),
        name: 'stir')
      ..position.set(4, 2, -2)
      ..visible = false);
    _label('lbl_stir', _stir!, _rt_V3(0, 2.4, 0));

    // Molecular view group: 40 water spheres + 3 wireframe voids.
    final mg = _rt_Node3D(name: 'molG')..position.set(0, 0.5, 0);
    final rnd = math.Random(23);
    for (var i = 0; i < 40; i++) {
      final r = rnd.nextDouble() * 1.5;
      final th = rnd.nextDouble() * math.pi * 2;
      mg.add(_rt_Sphere3D(0.3,
          _rt_Material3D(color: _rt_Tw.sky400, opacity: 0.75, shininess: 0.4))
        ..position.set(r * math.cos(th), 0.3 + rnd.nextDouble() * 2.5,
            r * math.sin(th))
        ..pickable = false);
    }
    for (var i = 0; i < 3; i++) {
      final v = _rt_Mesh3D(
          _rt_Geometry3D.sphere(0.25, widthSegments: 8, heightSegments: 6),
          _rt_Material3D(
              color: Colors.white, wireframe: true, unlit: true, opacity: 0.6))
        ..position.set((rnd.nextDouble() - 0.5) * 1.5, 2.5,
            (rnd.nextDouble() - 0.5) * 1.5)
        ..pickable = false;
      v.userData['filled'] = false;
      _voids.add(v);
      mg.add(v);
    }
    mg.visible = false;
    _molG = _world.add(mg);

    for (var i = 0; i < 3; i++) {
      final m = _rt_Sphere3D(0.28, _rt_Material3D(color: _rt_Tw.orange500), name: 'mol')
        ..position.set(-3 + i * 3.0, 5, 0)
        ..visible = false;
      m.userData['live'] = true;
      _mols.add(_world.add(m));
      _label('lbl_sugar_mol', m, _rt_V3(0, 0.7, 0));
    }
  }

  // Source buildScenario3.
  void _buildS3() {
    final (g, liquid) = _buildBeaker();
    _beaker3 = _world.add(g..position.set(0, 0.5, 0));
    _liquid3Mat = liquid.material;
    _label('lbl_water', _beaker3!, _rt_V3(0, 5.6, 0));

    final f = _rt_Node3D(name: 'forceps');
    final fMat =
        _rt_Material3D(color: const Color(0xFF94A3B8), metalness: 0.6, shininess: 0.5);
    f.add(_rt_Mesh3D(_rt_Geometry3D.box(0.1, 3, 0.3), fMat)
      ..position.set(0.18, 1.5, 0)
      ..rotation.z = 0.08);
    f.add(_rt_Mesh3D(_rt_Geometry3D.box(0.1, 3, 0.3), fMat)
      ..position.set(-0.18, 1.5, 0)
      ..rotation.z = -0.08);
    f.add(_rt_Mesh3D(_rt_Geometry3D.box(0.6, 0.5, 0.4),
        _rt_Material3D(color: const Color(0xFF475569)))
      ..position.set(0, 3, 0));
    _crystal = _rt_Mesh3D(_rt_Geometry3D.icosahedron(0.28),
        _rt_Material3D(color: _cPurple, shininess: 0.5))
      ..position.set(0, 0.15, 0);
    f.add(_crystal!);
    f.position.set(4, 1, 0);
    _forceps = _world.add(f);
    _label('lbl_forceps', _forceps!, _rt_V3(0, 3.9, 0));
  }

  // Source buildScenario4.
  void _buildS4() {
    _bucketS = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(1, 0.8, 1.5, segments: 14),
        _rt_Material3D(color: const Color(0xFF64748B)),
        name: 'bucket_stones')
      ..position.set(-3, 1, -1));
    _label('lbl_stones', _bucketS!, _rt_V3(0, 1.5, 0));

    _bucketW = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(1, 0.8, 1.5, segments: 14),
        _rt_Material3D(color: _rt_Tw.sky400, opacity: 0.75),
        name: 'bucket_water')
      ..position.set(3, 1, -1));
    _label('lbl_water_bucket', _bucketW!, _rt_V3(0, 1.5, 0));

    final sMat = _rt_Material3D(color: const Color(0xFF78716C));
    final g1 = _rt_Node3D();
    for (final p in const [(-0.4, -0.4), (0.4, -0.4), (-0.4, 0.4), (0.4, 0.4)]) {
      g1.add(_rt_Mesh3D(_rt_Geometry3D.icosahedron(0.32), sMat)
        ..position.set(p.$1, 0, p.$2));
    }
    g1.position.set(-3, 0.3, 1.5);
    g1.visible = false;
    g1.pickable = false;
    _pileG1 = _world.add(g1);

    final g2 = _rt_Node3D();
    g2.add(_rt_Mesh3D(_rt_Geometry3D.icosahedron(0.32), sMat)..position.set(0, 0.5, 0));
    g2.position.set(-3, 0.3, 1.5);
    g2.visible = false;
    g2.pickable = false;
    _pileG2 = _world.add(g2);

    _puddle = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(1, 1, 0.06, segments: 18),
        _rt_Material3D(color: _cWater, opacity: 0.8, shininess: 0.4))
      ..position.set(3, 0.05, 1.5)
      ..visible = false
      ..pickable = false);

    _rt_Node3D diag(String name, String key, Color c, double x) {
      final d = _rt_Node3D(name: name);
      d.add(_rt_Mesh3D(_rt_Geometry3D.box(3.2, 0.14, 1.0),
          _rt_Material3D(color: c, opacity: 0.85)));
      _label(key, d, _rt_V3(0, 1.4, 0));
      d.position.set(x, 0.1, 4);
      d.visible = false;
      d.userData['live'] = true;
      return d;
    }

    _diag1 = _world.add(
        diag('diag1', 'lbl_locked_grid', const Color(0xFFB91C1C), -3));
    _diag2 = _world.add(
        diag('diag2', 'lbl_sliding', const Color(0xFF1E3A8A), 3));
  }

  // Source buildScenario5 (+ createTripodAndBurner).
  void _buildS5() {
    final (g, liquid) = _buildBeaker();
    _beaker5 = _world.add(g..position.set(3, 0.5, 0));
    _liquid5 = liquid;
    _label('lbl_ocean', _beaker5!, _rt_V3(0, 5.6, 0));

    _residue = _rt_Mesh3D(_rt_Geometry3D.cylinder(1.8, 1.8, 0.06, segments: 18),
        _rt_Material3D(color: Colors.white), name: 'residue')
      ..position.y = 0.15
      ..visible = false;
    _beaker5!.add(_residue!);
    _label('lbl_salt', _residue!, _rt_V3(0, 0.7, 0));

    final metal =
        _rt_Material3D(color: const Color(0xFF475569), metalness: 0.7, shininess: 0.4);
    final tri = _rt_Node3D(name: 'tripod');
    tri.add(_rt_Mesh3D(
        _rt_Geometry3D.torus(2.1, 0.15, radialSegments: 6, tubularSegments: 18),
        metal)
      ..rotation.x = math.pi / 2
      ..position.y = 1.5);
    for (var i = 0; i < 3; i++) {
      final a = i / 3 * math.pi * 2;
      tri.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.1, 0.1, 1.5, segments: 8), metal)
        ..position.set(math.cos(a) * 2.1, 0.75, math.sin(a) * 2.1));
    }
    tri.position.set(-3, 0, 0);
    tri.pickable = false;
    _tripod = _world.add(tri);

    _burner = _world.add(_rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.7, 0.8, 0.6, segments: 14),
        _rt_Material3D(color: const Color(0xFF94A3B8), metalness: 0.7, shininess: 0.5),
        name: 'burner')
      ..position.set(-3, 0.3, 0));
    _label('lbl_burner', _burner!, _rt_V3(0, 0.9, 0));

    _flame = _world.add(_rt_Mesh3D(_rt_Geometry3D.cone(0.5, 1.0, segments: 12),
        _rt_Material3D(color: _rt_Tw.sky400, unlit: true, opacity: 0.9))
      ..position.set(-3, 1.1, 0)
      ..visible = false
      ..pickable = false);

    _mag5 = _world.add(_buildMagnifier()..position.set(4, 1, 3));
    _label('lbl_mag', _mag5!, _rt_V3(0, 1.8, 0));

    final steam = _rt_Node3D(name: 'steam');
    final rnd = math.Random(31);
    for (var i = 0; i < 15; i++) {
      final p = _rt_Sphere3D(0.3,
          _rt_Material3D(color: Colors.white, unlit: true, opacity: 0))
        ..position.set((rnd.nextDouble() - 0.5) * 1.5, rnd.nextDouble() * 2,
            (rnd.nextDouble() - 0.5) * 1.5)
        ..pickable = false;
      p.userData['vy'] = 3.0 + rnd.nextDouble() * 3.0;
      steam.add(p);
    }
    steam.visible = false;
    steam.pickable = false;
    _steam = _world.add(steam);
  }

  // ------------------------------------------------------- scenario flow ---
  void _loadScenario(int id, {bool silent = false}) {
    _gen++;
    _tweens.cancelAll();
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _scenario = id;
      _step = 0;
      _viewStep = 0;
      _chunksIn = 0;
      _grindAcc = 0;
      _lastGrindAngle = null;
      _sugarInWater = false;
      _dissolved = false;
      _stirAcc = 0;
      _lastStirAngle = null;
      _molsIn = 0;
      _s3T = 0;
      _clicksS = _clicksW = _diagsPlaced = 0;
      _verifyOk = _tbSet = _evaporating = false;
      _evap = 0;
      _drop1 = _drop2 = false;
      _activeDrop = 1;
      _usedWords.clear();
    });
    _clearWorld();
    switch (id) {
      case 1:
        _buildS1();
      case 2:
        _buildS2();
      case 3:
        _buildS3();
      case 4:
        _buildS4();
      case 5:
        _buildS5();
    }
    _syncLabels();
    _camera.reset();
    _syncState(0);
  }

  void _restart() {
    _labelsOn = true;
    _locked = true;
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _loadScenario(1, silent: true); // shell already plays _rt_Sfx.scenario
  }

  /// Source selectStep: view a past step's 3D state or return to the live one.
  void _selectStep(int index) {
    if (index > _step) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _viewStep = index);
    _syncState(index);
  }

  /// Source completeStep.
  void _completeStep() {
    if (_scenarioDone) return;
    _rt_playSfx(_rt_Sfx.correct); // source playSuccessSound per completed step
    _drag = null;
    setState(() {
      _step++;
      _viewStep = _step;
    });
    if (_scenarioDone) {
      _showObservation();
    } else {
      _syncState(_step);
    }
  }

  /// Source showObservationPanel (draggable panel -> draggable shell popup).
  Future<void> _showObservation() async {
    _rt_playSfx(_rt_Sfx.success);
    _shell.setSidebarOpen(true);
    await _rt_showShellPopup(
      context,
      title: _tx.s('final_obs'),
      message: '${_tx.s('s${_scenario}_s')}\n\n${_tx.s('select_new')}',
      icon: Icons.lightbulb,
      color: _rt_Tw.green500,
    );
  }

  /// Source sync3DStateToStep: forces the scene into step [idx]'s visuals.
  void _syncState(int idx) {
    _camera.reset();
    switch (_scenario) {
      case 1:
        _chalk?.visible = idx == 0;
        _hammer?.visible = idx == 0;
        if (idx == 0) {
          _hammer?.position.set(3, 0.5, 2);
          _hammer?.rotation.z = 0;
        }
        final m = _mortar!.position;
        final rnd = math.Random(3);
        for (var i = 0; i < _chunks.length; i++) {
          final p = _chunks[i];
          p.visible = idx >= 1 && idx < 3;
          if (idx == 1) {
            p.position.set(-1.5 + i * 1.5, 0.4, 0);
          } else {
            p.position.set(m.x + (rnd.nextDouble() * 0.4 - 0.2), 0.6,
                m.z + (rnd.nextDouble() * 0.4 - 0.2));
          }
        }
        _pestle?.visible = idx == 2;
        if (idx == 2) _pestle?.position.set(3, 1, -3);
        _mag1?.visible = idx >= 3;
        if (idx == 3) _mag1?.position.set(-4, 1.5, 0);
        if (idx >= 3) {
          _ensurePowder();
        }
        _powder?.visible = idx >= 3;
        if (idx >= 4) {
          _camera.position.set(m.x, 3.5, m.z + 3.0);
          _camera.target.copy(m);
        }
      case 2:
        _stirAcc = 0;
        _lastStirAngle = null;
        _marker?.visible = idx == 0;
        if (idx == 0) _marker?.position.set(-4, 0.5, 2);
        _ring2?.visible = idx == 1;
        _spoon?.visible = idx == 1;
        _stir?.visible = idx == 1;
        _liquid2?.visible = idx < 2;
        _molG?.visible = idx >= 2;
        if (idx == 1 && _cube != null) {
          // Cube back on the spoon, everything ready to dissolve again.
          _cube!.removeFromParent();
          _spoon!.add(_cube!);
          _cube!.position.set(-1.15, 0.3, 0);
          _cube!.scale.set(1, 1, 1);
          _cube!.visible = true;
          _sugarInWater = false;
          _dissolved = false;
          _spoon!.position.set(4, 0.5, 2);
          _stir!.position.set(4, 2, -2);
        }
        for (var i = 0; i < _mols.length; i++) {
          final mol = _mols[i];
          mol.visible = idx >= 2;
          if (idx >= 2 && mol.userData['live'] == true) {
            mol.position.set(-3 + i * 3.0, 5, 0);
          }
        }
        if (idx >= 2) {
          _camera.position.set(0, 5, 12);
          _camera.target.set(0, 2.5, 0);
        }
      case 3:
        if (idx == 0) {
          _forceps?.visible = true;
          _forceps?.position.set(4, 1, 0);
          if (_crystal != null && _crystal!.parent != _forceps) {
            _crystal!.removeFromParent();
            _forceps!.add(_crystal!);
            _crystal!.position.set(0, 0.15, 0);
          }
          _crystal?.visible = true;
          _crystal?.scale.set(1, 1, 1);
          _liquid3Mat?.color = _cWater;
          _s3T = 0;
        } else if (idx == 1) {
          _forceps?.visible = false;
          if (_crystal != null && _crystal!.parent == _forceps) {
            _crystal!.removeFromParent();
            _world.add(_crystal!);
          }
          _crystal?.visible = true;
          _crystal?.position.set(0, 0.7, 0);
          _crystal?.scale.set(1, 1, 1);
          _liquid3Mat?.color = _cWater;
          _s3T = 0;
        } else {
          _forceps?.visible = false;
          _crystal?.visible = false;
          _liquid3Mat?.color = _cPurple;
          _s3T = 100;
        }
      case 4:
        if (idx == 0) {
          _pileG1?.visible = false;
          _pileG2?.visible = false;
          _puddle?.visible = false;
          _diag1?.visible = false;
          _diag2?.visible = false;
          _clicksS = 0;
          _clicksW = 0;
          _diagsPlaced = 0;
        } else if (idx == 1) {
          _pileG1?.visible = true;
          _pileG2?.visible = true;
          _puddle?.visible = false;
          _diag1?.visible = false;
          _diag2?.visible = false;
          _clicksS = 3;
          _clicksW = 0;
          _diagsPlaced = 0;
        } else {
          _pileG1?.visible = true;
          _pileG2?.visible = true;
          _puddle?.visible = true;
          _puddle?.scale.set(3.6, 1, 3.6);
          _diag1?.visible = true;
          _diag2?.visible = true;
          _clicksS = 3;
          _clicksW = 3;
          if (idx == 2) {
            _diag1?.position.set(-3, 0.1, 4);
            _diag2?.position.set(3, 0.1, 4);
            _diag1?.userData['live'] = true;
            _diag2?.userData['live'] = true;
            _diagsPlaced = 0;
          }
        }
        _camera.target.set(0, 1, 0);
      case 5:
        _evaporating = false;
        _flame?.visible = false;
        _steam?.visible = false;
        if (idx < 2) {
          _beaker5?.position.set(3, 0.5, 0);
          _liquid5?.visible = true;
          _liquid5?.scale.set(1, 1, 1);
          _liquid5?.position.y = 1.55;
          _residue?.visible = false;
          _evap = 0;
          if (idx == 0) {
            _mag5?.visible = true;
            _mag5?.position.set(4, 1, 3);
            _verifyOk = false;
          } else {
            _mag5?.visible = false;
            _tbSet = false;
          }
        } else {
          _beaker5?.position
              .set(_tripod!.position.x, 1.55, _tripod!.position.z);
          _mag5?.visible = false;
          _liquid5?.visible = true;
          _liquid5?.scale.set(1, 0.01, 1);
          _liquid5?.position.y = 0.05 + 0.01 * 1.5;
          _residue?.visible = true;
          _evap = 1;
          _tbSet = true;
        }
    }
    setState(() {});
  }

  // ------------------------------------------------------- step actions ---
  // Scenario 1.
  void _breakChalk() {
    if (_hammer == null || _stepId != 's1_break') return;
    final gen = _gen;
    final from = _hammer!.position.clone();
    final over = _rt_V3(_chalk!.position.x + 0.5, 1.6, _chalk!.position.z + 0.6);
    _tweens.run(350, (t) {
      if (_alive(gen)) _hammer!.position.copy(from + (over - from) * t);
    }).then((_) {
      if (!_alive(gen) || _stepId != 's1_break') return;
      _tweens.run(500, (t) {
        if (_alive(gen)) _hammer!.rotation.z = -math.sin(t * math.pi) * 1.2;
      }).then((_) {
        if (!_alive(gen) || _stepId != 's1_break') return;
        _rt_playSfx(_rt_Sfx.pop); // chalk shatters
        _hammer!.visible = false;
        _chalk!.visible = false;
        for (final c in _chunks) {
          c.visible = true;
        }
        _completeStep();
      });
    });
  }

  void _placeChunk(_rt_Node3D chunk) {
    final m = _mortar!.position;
    final rnd = math.Random(_chunksIn + 1);
    chunk.position.set(m.x + (rnd.nextDouble() * 0.4 - 0.2), 0.6,
        m.z + (rnd.nextDouble() * 0.4 - 0.2));
    chunk.userData['live'] = false;
    _chunksIn++;
    _rt_playSfx(_rt_Sfx.pop); // source playActionSound
    if (_chunksIn >= 3) {
      _pestle?.visible = true;
      _completeStep();
    } else {
      setState(() {});
    }
  }

  void _autoCollect() {
    final gen = _gen;
    final live =
        _chunks.where((c) => c.userData['live'] == true).toList();
    if (live.isEmpty) return;
    final m = _mortar!.position;
    final starts = [for (final c in live) c.position.clone()];
    _tweens.run(500, (t) {
      if (!_alive(gen)) return;
      for (var i = 0; i < live.length; i++) {
        final target = _rt_V3(m.x, 0.6 + (1 - t) * 2, m.z);
        live[i].position.copy(starts[i] + (target - starts[i]) * t);
      }
    }).then((_) {
      if (!_alive(gen) || _stepId != 's1_fill') return;
      for (final c in live) {
        _placeChunk(c);
      }
    });
  }

  void _grindComplete() {
    _rt_playSfx(_rt_Sfx.pop); // source playActionSound at grind completion
    _pestle?.visible = false;
    for (final c in _chunks) {
      c.visible = false;
    }
    _ensurePowder();
    _powder!.visible = true;
    _mag1?.visible = true;
    _drag = null;
    _completeStep();
  }

  void _autoGrind() {
    final gen = _gen;
    final m = _mortar!.position;
    _tweens.run(1100, (t) {
      if (!_alive(gen)) return;
      _pestle?.position.set(m.x + math.cos(t * math.pi * 6) * 0.8, 0.9,
          m.z + math.sin(t * math.pi * 6) * 0.8);
    }).then((_) {
      if (_alive(gen) && _stepId == 's1_grind') _grindComplete();
    });
  }

  void _magnifyDone() {
    _mag1?.visible = false;
    _rt_playSfx(_rt_Sfx.magic); // zoom-in reveal
    final gen = _gen;
    final m = _mortar!.position;
    final fromP = _camera.position.clone();
    final fromT = _camera.target.clone();
    final toP = _rt_V3(m.x, 3.5, m.z + 3.0);
    _tweens.run(700, (t) {
      if (!_alive(gen)) return;
      _camera.position.copy(fromP + (toP - fromP) * t);
      _camera.target.copy(fromT + (m - fromT) * t);
    }).then((_) {
      if (_alive(gen) && _stepId == 's1_magnify') _completeStep();
    });
  }

  void _autoMagnify() {
    final gen = _gen;
    final from = _mag1!.position.clone();
    final to = _rt_V3(_mortar!.position.x, 1.6, _mortar!.position.z + 0.4);
    _tweens.run(400, (t) {
      if (_alive(gen)) _mag1!.position.copy(from + (to - from) * t);
    }).then((_) {
      if (_alive(gen) && _stepId == 's1_magnify') _magnifyDone();
    });
  }

  // Scenario 2.
  void _markDone() {
    _marker?.visible = false;
    _ring2?.visible = true;
    _spoon?.visible = true;
    _stir?.visible = true;
    _rt_playSfx(_rt_Sfx.pop); // source playActionSound
    _completeStep();
  }

  void _autoMark() {
    final gen = _gen;
    final from = _marker!.position.clone();
    final to = _rt_V3(2.6, 4.5, 0.5);
    _tweens.run(450, (t) {
      if (_alive(gen)) _marker!.position.copy(from + (to - from) * t);
    }).then((_) {
      if (_alive(gen) && _stepId == 's2_mark') _markDone();
    });
  }

  void _dropSugar() {
    if (_sugarInWater || _cube == null) return;
    final gen = _gen;
    _spoon!.position.set(2.8, 0.5, 1.2);
    final wp = _cube!.worldPosition;
    _cube!.removeFromParent();
    _world.add(_cube!);
    _cube!.position.copy(wp);
    final from = wp.clone();
    final to = _rt_V3(0, 1.0, 0);
    _tweens.run(600, (t) {
      if (_alive(gen)) _cube!.position.copy(from + (to - from) * t);
    }).then((_) {
      if (!_alive(gen)) return;
      _sugarInWater = true;
      _rt_playSfx(_rt_Sfx.pop); // splash
      _toastOk('msg_sugar');
      setState(() {});
    });
  }

  void _dissolveDone() {
    _dissolved = true;
    _cube?.visible = false;
    _stir?.visible = false;
    _drag = null;
    _completeStep();
  }

  void _autoDissolve() {
    final gen = _gen;
    if (!_sugarInWater) {
      _dropSugar();
      Future.delayed(const Duration(milliseconds: 750), () {
        if (_alive(gen) && _stepId == 's2_dissolve') _autoDissolve();
      });
      return;
    }
    if (_dissolved) return;
    _stir!.position.set(0.8, 2.2, 0);
    _tweens.run(1100, (t) {
      if (!_alive(gen)) return;
      _stir!.position.set(math.cos(t * math.pi * 6) * 0.9, 2.2,
          math.sin(t * math.pi * 6) * 0.9);
      final s = math.max(0.01, 1 - t);
      _cube!.scale.set(s, s, s);
    }).then((_) {
      if (_alive(gen) && _stepId == 's2_dissolve' && !_dissolved) {
        _dissolveDone();
      }
    });
  }

  void _fillMol(_rt_Node3D mol) {
    if (mol.userData['live'] != true) return;
    final free = _voids.where((v) => v.userData['filled'] != true).toList();
    if (free.isEmpty) return;
    final v = free.first;
    v.userData['filled'] = true;
    mol.userData['live'] = false;
    _rt_playSfx(_rt_Sfx.pop); // source playActionSound
    final gen = _gen;
    final from = mol.position.clone();
    final to = v.worldPosition;
    _tweens.run(500, (t) {
      if (_alive(gen)) mol.position.copy(from + (to - from) * t);
    }).then((_) {
      if (!_alive(gen)) return;
      _molsIn++;
      setState(() {});
      if (_molsIn >= 3 && _stepId == 's2_view') {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_alive(gen) && _stepId == 's2_view') _completeStep();
        });
      }
    });
  }

  void _autoMol() {
    final next = _mols.where((m) => m.userData['live'] == true).toList();
    if (next.isNotEmpty) _fillMol(next.first);
  }

  // Scenario 3.
  void _crystalDropped() {
    _forceps!.visible = false;
    final wp = _crystal!.worldPosition;
    _crystal!.removeFromParent();
    _world.add(_crystal!);
    _crystal!.position.copy(wp);
    final gen = _gen;
    final from = wp.clone();
    final to = _rt_V3(0, 0.7, 0);
    _tweens.run(450, (t) {
      if (_alive(gen)) _crystal!.position.copy(from + (to - from) * t);
    }).then((_) {
      if (!_alive(gen)) return;
      _rt_playSfx(_rt_Sfx.pop); // crystal lands
      if (_stepId == 's3_drop') _completeStep();
    });
  }

  void _autoDropCrystal() {
    final gen = _gen;
    final from = _forceps!.position.clone();
    final to = _rt_V3(0, 1.2, 0);
    _tweens.run(450, (t) {
      if (_alive(gen)) _forceps!.position.copy(from + (to - from) * t);
    }).then((_) {
      if (_alive(gen) && _stepId == 's3_drop') _crystalDropped();
    });
  }

  void _onS3Slider(double v) {
    setState(() => _s3T = v);
    final p = v / 100;
    _liquid3Mat?.color = Color.lerp(_cWater, _cPurple, p)!;
    final s = math.max(0.01, 1 - p);
    _crystal?.scale.set(s, s, s);
    if (p >= 1 && _stepId == 's3_time') _completeStep();
  }

  // Scenario 4.
  void _tiltBucket(_rt_Node3D bucket, double dir) {
    final gen = _gen;
    _tweens.run(300, (t) {
      if (_alive(gen)) bucket.rotation.z = dir * 0.35 * math.sin(t * math.pi);
    });
  }

  void _pourStones() {
    if (_stepId != 's4_solid' || _clicksS >= 3) return;
    _clicksS++;
    _rt_playSfx(_rt_Sfx.pop); // source playActionSound per pour
    _tiltBucket(_bucketS!, -1);
    if (_clicksS == 1) _pileG1!.visible = true;
    if (_clicksS == 2) _pileG2!.visible = true;
    if (_clicksS >= 3) {
      _completeStep();
    } else {
      setState(() {});
    }
  }

  void _pourWater() {
    if (_stepId != 's4_liquid' || _clicksW >= 3) return;
    _clicksW++;
    _rt_playSfx(_rt_Sfx.pop);
    _tiltBucket(_bucketW!, 1);
    _puddle!.visible = true;
    _puddle!.scale.set(_clicksW * 1.2, 1, _clicksW * 1.2);
    if (_clicksW >= 3) {
      _diag1!.visible = true;
      _diag2!.visible = true;
      _completeStep();
    } else {
      setState(() {});
    }
  }

  void _placeDiag(_rt_Node3D d) {
    d.position.set(d.name == 'diag1' ? -3 : 3, 0.1, 2);
    d.userData['live'] = false;
    _diagsPlaced++;
    _rt_playSfx(_rt_Sfx.pop);
    if (_diagsPlaced >= 2) {
      _completeStep();
    } else {
      setState(() {});
    }
  }

  void _autoDiag() {
    final next = [_diag1, _diag2]
        .whereType<_rt_Node3D>()
        .where((d) => d.userData['live'] == true)
        .toList();
    if (next.isEmpty) return;
    final d = next.first;
    final gen = _gen;
    final from = d.position.clone();
    final to = _rt_V3(d.name == 'diag1' ? -3 : 3, 0.1, 2);
    _tweens.run(450, (t) {
      if (_alive(gen)) d.position.copy(from + (to - from) * t);
    }).then((_) {
      if (_alive(gen) && _stepId == 's4_explain' &&
          d.userData['live'] == true) {
        _placeDiag(d);
      }
    });
  }

  // Scenario 5.
  void _magOverWater() {
    setState(() => _verifyOk = true);
    _rt_playSfx(_rt_Sfx.pop);
    _toastOk('msg_clear');
  }

  void _autoVerify() {
    final gen = _gen;
    final from = _mag5!.position.clone();
    final to = _rt_V3(_beaker5!.position.x + 0.5, 5.6, _beaker5!.position.z + 1.2);
    _tweens.run(450, (t) {
      if (_alive(gen)) _mag5!.position.copy(from + (to - from) * t);
    }).then((_) {
      if (_alive(gen) && _stepId == 's5_verify' && !_verifyOk) _magOverWater();
    });
  }

  void _beakerPlaced() {
    _beaker5!.position.set(_tripod!.position.x, 1.55, _tripod!.position.z);
    _tbSet = true;
    _rt_playSfx(_rt_Sfx.pop);
    _toastOk('msg_setup');
    setState(() {});
  }

  void _ignite() {
    if (!_tbSet) {
      _toastErr('err_follow');
      return;
    }
    if (_evaporating || _residue!.visible) return;
    _rt_playSfx(_rt_Sfx.magic); // burner lights
    _flame!.visible = true;
    _steam!.visible = true;
    _steam!.position
        .set(_beaker5!.position.x, _beaker5!.position.y + 3.0, _beaker5!.position.z);
    setState(() => _evaporating = true);
  }

  void _autoEvaporate() {
    if (!_tbSet) {
      final gen = _gen;
      final from = _beaker5!.position.clone();
      final to = _rt_V3(_tripod!.position.x, 1.55, _tripod!.position.z);
      _tweens.run(500, (t) {
        if (_alive(gen)) _beaker5!.position.copy(from + (to - from) * t);
      }).then((_) {
        if (_alive(gen) && _stepId == 's5_evaporate') _beakerPlaced();
      });
    } else {
      _ignite();
    }
  }

  void _residueClicked() {
    if (_stepId != 's5_identify') return;
    _rt_playSfx(_rt_Sfx.magic); // residue identified
    _toastOk('msg_residue');
    _completeStep();
  }

  /// Source processWordPlacement (tap variant; drop-1 = molecules, drop-2 = small).
  void _tapWord(String w) {
    if (_stepId != 's5_identify') return;
    final target = _activeDrop;
    if ((target == 1 && _drop1) || (target == 2 && _drop2)) return;
    if ((target == 1 && w != 'molecules') || (target == 2 && w != 'small')) {
      _toastErr('err_incorrect');
      return;
    }
    _rt_playSfx(_rt_Sfx.pop); // source playActionSound
    setState(() {
      _usedWords.add(w);
      if (target == 1) {
        _drop1 = true;
        _activeDrop = 2;
      } else {
        _drop2 = true;
        _activeDrop = 1;
      }
    });
    if (_drop1 && _drop2) {
      final gen = _gen;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_alive(gen) && _stepId == 's5_identify') _completeStep();
      });
    }
  }

  /// Sidebar "Do This Step" fallback for the canvas interactions.
  void _autoAction() {
    if (!_interactable) return;
    _rt_playSfx(_rt_Sfx.tap);
    switch (_stepId) {
      case 's1_break':
        _breakChalk();
      case 's1_fill':
        _autoCollect();
      case 's1_grind':
        _autoGrind();
      case 's1_magnify':
        _autoMagnify();
      case 's1_identify':
        _completeStep();
      case 's2_mark':
        _autoMark();
      case 's2_dissolve':
        _autoDissolve();
      case 's2_view':
        _autoMol();
      case 's3_drop':
        _autoDropCrystal();
      case 's4_solid':
        _pourStones();
      case 's4_liquid':
        _pourWater();
      case 's4_explain':
        _autoDiag();
      case 's5_verify':
        _autoVerify();
      case 's5_evaporate':
        _autoEvaporate();
      case 's5_identify':
        _residueClicked();
    }
  }

  // --------------------------------------------------------- interaction ---
  bool _startDrag(_rt_Node3D n, double y) {
    _drag = n;
    _dragName = n.name ?? '';
    _dragY = y;
    _dragOrigin.copy(n.position);
    _lastGrindAngle = null;
    _lastStirAngle = null;
    _rt_playSfx(_rt_Sfx.tap); // grab feedback
    return true;
  }

  bool _onPointerDown(_rt_SceneEvent e) {
    if (!_interactable) return false;
    _rt_Node3D? pick(String name) => e.hitWhere((n) => n.name == name);

    switch (_stepId) {
      case 's1_break':
        final h = pick('hammer');
        if (h != null) return _startDrag(h, 0.5);
      case 's1_fill':
        final c = e.hitWhere(
            (n) => n.name == 'chunk' && n.userData['live'] == true);
        if (c != null) return _startDrag(c, 0.4);
      case 's1_grind':
        final p = pick('pestle');
        if (p != null) {
          _grindAcc = 0;
          return _startDrag(p, 1.0);
        }
      case 's1_magnify':
        final m = pick('magnifier');
        if (m != null) return _startDrag(m, 1.5);
      case 's2_mark':
        final m = pick('marker');
        if (m != null) return _startDrag(m, 0.5);
      case 's2_dissolve':
        if (!_sugarInWater) {
          final s = pick('spoon');
          if (s != null) return _startDrag(s, 0.5);
        }
        final st = pick('stir');
        if (st != null) return _startDrag(st, 2.0);
      case 's3_drop':
        final f = pick('forceps');
        if (f != null) return _startDrag(f, 1.0);
      case 's4_explain':
        final d = e.hitWhere((n) =>
            (n.name == 'diag1' || n.name == 'diag2') &&
            n.userData['live'] == true);
        if (d != null) return _startDrag(d, 0.1);
      case 's5_verify':
        final m = pick('magnifier');
        if (m != null) return _startDrag(m, 1.0);
      case 's5_evaporate':
        if (!_tbSet) {
          final b = pick('beaker');
          if (b != null) return _startDrag(b, 0.5);
        }
    }

    // Source: touching a known object out of turn -> err_follow.
    final other = e.hitWhere(
        (n) => _interactives[_scenario - 1].contains(n.name ?? ''));
    if (other != null && _drag == null) {
      final id = other.name ?? '';
      final clickIds = {
        'mortar', 'beaker', 'mol', 'bucket_stones', 'bucket_water', 'burner',
        'residue', 'chalk'
      };
      if (!clickIds.contains(id)) _toastErr('err_follow');
    }
    return false;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    final d = _drag;
    if (d == null) return;
    final p = e.ray.intersectY(_dragY);
    if (p == null) return;
    d.position.set(p.x.clamp(-9.0, 9.0), _dragY, p.z.clamp(-5.5, 5.5));

    // Grinding: accumulate circular motion around the mortar.
    if (_dragName == 'pestle' && _mortar != null) {
      final a = math.atan2(d.position.z - _mortar!.position.z,
          d.position.x - _mortar!.position.x);
      if (_lastGrindAngle != null) {
        var delta = a - _lastGrindAngle!;
        if (delta > math.pi) delta -= math.pi * 2;
        if (delta < -math.pi) delta += math.pi * 2;
        _grindAcc += delta.abs();
        if (_grindAcc > math.pi * 6 && _stepId == 's1_grind') {
          _grindComplete();
          return;
        }
      }
      _lastGrindAngle = a;
    }

    // Stirring: accumulate circles around the beaker, shrink the cube.
    if (_dragName == 'stir' &&
        _beaker2 != null &&
        _sugarInWater &&
        !_dissolved) {
      final a = math.atan2(d.position.z - _beaker2!.position.z,
          d.position.x - _beaker2!.position.x);
      if (_lastStirAngle != null) {
        var delta = a - _lastStirAngle!;
        if (delta > math.pi) delta -= math.pi * 2;
        if (delta < -math.pi) delta += math.pi * 2;
        _stirAcc += delta.abs();
        final progress = math.min(1.0, _stirAcc / (math.pi * 6));
        final s = math.max(0.01, 1 - progress);
        _cube?.scale.set(s, s, s);
        if (progress >= 1 && _stepId == 's2_dissolve') {
          _dissolveDone();
          return;
        }
      }
      _lastStirAngle = a;
    }
  }

  void _revertDrag(_rt_Node3D d) {
    d.position.copy(_dragOrigin);
    _toastErr('err_try_again'); // + source playErrorSound
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final d = _drag;
    _drag = null;
    if (d == null) return;
    double distXZ(_rt_V3 a, _rt_V3 b) =>
        math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.z - b.z, 2)).toDouble();

    switch (_stepId) {
      case 's1_break':
        if (d.position.distanceTo(_chalk!.position) < 3.5) {
          _breakChalk();
        } else {
          _revertDrag(d);
        }
      case 's1_fill':
        if (d.position.distanceTo(_mortar!.position) < 4.0) {
          _placeChunk(d);
        } else {
          _revertDrag(d);
        }
      case 's1_grind':
        d.position.set(3, 1, -3); // pestle rests again
      case 's1_magnify':
        if (d.position.distanceTo(_mortar!.position) < 4.0) {
          _magnifyDone();
        } else {
          _revertDrag(d);
        }
      case 's2_mark':
        if (d.position.distanceTo(_beaker2!.position) < 4.0) {
          _markDone();
        } else {
          _revertDrag(d);
        }
      case 's2_dissolve':
        if (_dragName == 'spoon') {
          if (d.position.distanceTo(_beaker2!.position) < 4.0) {
            _dropSugar();
          } else {
            _revertDrag(d);
          }
        } else if (_dragName == 'stir' && !_dissolved) {
          d.position.set(4, 2, -2); // source revert while cube visible
        }
      case 's3_drop':
        if (d.position.distanceTo(_beaker3!.position) < 4.0) {
          _crystalDropped();
        } else {
          _revertDrag(d);
        }
      case 's4_explain':
        final target =
            _rt_V3(_dragName == 'diag1' ? -3 : 3, 0.1, 2);
        if (distXZ(d.position, target) < 3.0) {
          _placeDiag(d);
        } else {
          _revertDrag(d);
        }
      case 's5_verify':
        if (distXZ(d.position, _beaker5!.position) < 4.0) {
          _magOverWater();
        } else {
          _revertDrag(d);
          setState(() => _verifyOk = false);
        }
      case 's5_evaporate':
        if (distXZ(d.position, _tripod!.position) < 4.0) {
          _beakerPlaced();
        } else {
          _revertDrag(d);
        }
    }
  }

  void _onTap(_rt_SceneEvent e) {
    if (!_interactable) return;
    switch (_stepId) {
      case 's1_identify':
        if (e.hitWhere((n) => n.name == 'mortar' || n.name == 'powder') !=
            null) {
          _completeStep();
        }
      case 's2_view':
        final mol = e.hitWhere(
            (n) => n.name == 'mol' && n.userData['live'] == true);
        if (mol != null) _fillMol(mol);
      case 's4_solid':
        if (e.hitNamed('bucket_stones') != null) {
          _pourStones();
        } else if (e.hitNamed('bucket_water') != null) {
          _toastErr('err_follow');
        }
      case 's4_liquid':
        if (e.hitNamed('bucket_water') != null) {
          _pourWater();
        } else if (e.hitNamed('bucket_stones') != null) {
          _toastErr('err_follow');
        }
      case 's5_evaporate':
        if (e.hitNamed('burner') != null) _ignite();
      case 's5_identify':
        if (e.hitNamed('residue') != null) _residueClicked();
    }
  }

  // ------------------------------------------------------------ animation ---
  void _onFrame(double dt) {
    _tweens.update(dt);
    _time += dt;

    // Evaporation (source animate() isEvaporating branch).
    if (_evaporating && _steam != null && _liquid5 != null) {
      for (final p in _steam!.children) {
        if (p is! _rt_Sphere3D) continue;
        p.position.y += (p.userData['vy'] as double) * dt;
        p.material.opacity =
            math.max(0, 0.5 - (p.position.y / 4)).toDouble();
        if (p.position.y > 4) {
          p.position.y = 0;
          p.material.opacity = 0.5;
        }
      }
      if (_evap < 1) {
        _evap += dt / 3.2;
        final sy = math.max(0.01, 1 - _evap);
        _liquid5!.scale.set(1, sy, 1);
        _liquid5!.position.y = 0.05 + sy * 1.5;
        if (_evap > 0.95 && !_residue!.visible) {
          _flame!.visible = false;
          _steam!.visible = false;
          _residue!.visible = true;
          _rt_playSfx(_rt_Sfx.magic); // salt appears
        }
      } else {
        _evaporating = false;
        _toastOk('msg_evap');
        if (_stepId == 's5_evaporate') _completeStep();
      }
    }

    // Idle flame flicker.
    if (_flame != null && _flame!.visible) {
      _flame!.scale.set(1, 1 + 0.12 * math.sin(_time * 18), 1);
    }
  }

  // ----------------------------------------------------------------- UI ---
  String get _hudText {
    if (_scenarioDone) return _tx.s('load_success');
    if (_viewStep < _step) return _tx.s('viewing_past');
    return _tx.s('${_base(_step)}_h');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(builder: (context, lang) {
        _syncLabels();
        return _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('app_title'),
          subtitle: _tx.s('class_chap'),
          canvasBackground: _rt_Tw.slate900,
          theme: const _rt_ShellTheme(
            accent: _cAccent,
            headerGradient: [_rt_Tw.slate900, Color(0xFF082F49)],
            headerSubtitleColor: Color(0xFF7DD3FC),
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('app_title'),
            subtitle: _tx.s('class_chap'),
            buttonLabel: _tx.s('enter_lab'),
            icon: Icons.grain,
          ),
          onRestart: _restart,
          onZoomIn: _camera.zoomIn,
          onZoomOut: _camera.zoomOut,
          onResetView: _camera.reset,
          toolbarExtras: [
            _rt_RotatePanToggle(controller: _viewCtrl, accent: _cAccent),
            const SizedBox(height: 4),
            _toolToggle('lock-toggle', Icons.lock, _locked, _tx.s('tool_lock'),
                () {
              setState(() => _locked = !_locked);
              _shell.showToast(
                  _tx.s(_locked ? 'view_locked' : 'view_unlocked'),
                  color: _rt_Tw.blue500,
                  icon: _locked ? Icons.lock : Icons.lock_open);
            }),
            const SizedBox(height: 4),
            _toolToggle('labels-toggle', Icons.label, _labelsOn,
                _tx.s('tool_labels'), () {
              setState(() => _labelsOn = !_labelsOn);
              _shell.showToast(
                  _tx.s(_labelsOn ? 'labels_on' : 'labels_off'),
                  color: _rt_Tw.blue500,
                  icon: Icons.label);
            }),
          ],
          hint: _rt_StepHint(
            number: _scenarioDone ? '✓' : '${_step + 1}',
            label: _tx.s('lbl_step'),
            text: _hudText,
          ),
          sidebarTop: _protocolSelector(),
          tabs: [
            _rt_ShellTab(
                label: _tx.s('inv_proto'),
                icon: Icons.science,
                builder: (_) => _sidebar()),
          ],
          canvas: _rt_Scene3DView(
            scene: _scene,
            camera: _camera,
            controller: _viewCtrl,
            cameraControls: !_locked,
            onFrame: _onFrame,
            onTap: _onTap,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
          ),
          canvasOverlays: [
            // Top HUD instruction panel (source #hud-panel).
            Positioned(
              top: 12,
              left: 70,
              right: 70,
              child: IgnorePointer(child: Center(child: _hudPanel())),
            ),
            // Bottom canvas-interactive overlays (source #canvas-ui-layer).
            if (_scenario == 3 && _interactable && _stepId == 's3_time')
              _bottomOverlay(_sliderOverlay()),
            if (_scenario == 3 && _interactable && _stepId == 's3_quiz')
              _bottomOverlay(_quizOverlay()),
            if (_scenario == 5 && _interactable && _stepId == 's5_verify')
              _bottomOverlay(_verifyOverlay()),
            if (_scenario == 5 && _interactable && _stepId == 's5_identify')
              _bottomOverlay(_wordOverlay()),
          ],
        );
      }),
    );
  }

  Widget _toolToggle(
      String key, IconData icon, bool active, String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
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
          child:
              Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
        ),
      ),
    );
  }

  Widget _hudPanel() {
    final active = !_scenarioDone && _viewStep == _step;
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _rt_Tw.slate900.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: active ? _cAccent : _rt_Tw.slate700, width: active ? 2 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12)
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_scenarioDone ? Icons.check_circle : Icons.info,
            size: 18, color: _scenarioDone ? _rt_Tw.green500 : _cAccent),
        const SizedBox(width: 8),
        Flexible(
          child: Text(_hudText,
              key: const ValueKey('hud-text'),
              maxLines: 3,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25)),
        ),
      ]),
    );
  }

  Widget _bottomOverlay(Widget child) {
    return Positioned(
      left: 70,
      right: 70,
      bottom: 12,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rt_Lab.tintedBorder(_cAccent)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4), blurRadius: 16)
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Source #ui-s3-slider.
  Widget _sliderOverlay() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _rt_SectionLabel(_tx.s('time_lapse'), icon: Icons.schedule, color: _cAccent),
      _rt_LabeledSlider(
        label: '0 ${_tx.s('min_short')} — 30 ${_tx.s('min_short')}',
        value: _s3T,
        min: 0,
        max: 100,
        valueText: '${(_s3T * 0.3).floor()} ${_tx.s('min_short')}',
        color: _cAccent,
        onChanged: _onS3Slider,
      ),
    ]);
  }

  // Source #ui-s3-quiz.
  Widget _quizOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(_tx.s('obs_quiz'), icon: Icons.quiz, color: _cAccent),
        Text(_tx.s('s3_q'),
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: _rt_Lab.text)),
        const SizedBox(height: 8),
        KeyedSubtree(
          key: const ValueKey('quiz-a'),
          child: _rt_ChoiceButton(
            label: _tx.s('s3_opt1'),
            onTap: () => _toastErr('err_gravity'),
          ),
        ),
        KeyedSubtree(
          key: const ValueKey('quiz-b'),
          child: _rt_ChoiceButton(
            label: _tx.s('s3_opt2'),
            onTap: () {
              _toastOk('msg_correct');
              _completeStep();
            },
          ),
        ),
      ],
    );
  }

  // Source #ui-s5-confirm.
  Widget _verifyOverlay() {
    return _rt_ActionButton(
      key: const ValueKey('btn-verify'),
      label: _tx.s('btn_verify'),
      icon: Icons.visibility_off,
      color: _cAccent,
      expand: true,
      onPressed: _verifyOk ? _completeStep : null,
    );
  }

  // Source #ui-s5-quiz: two-gap conclusion sentence + word bank.
  Widget _wordOverlay() {
    TextSpan gap(bool filled, String word) => TextSpan(
          text: filled ? ' ${_tx.s('word_$word')} ' : ' [ ____ ] ',
          style: TextStyle(
              color: filled ? _rt_Tw.green500 : _cAccent,
              fontWeight: FontWeight.w900),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(_tx.s('conclusion'), icon: Icons.menu_book, color: _cAccent),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.4),
            children: [
              TextSpan(text: _tx.s('s5_pt1')),
              gap(_drop1, 'molecules'),
              TextSpan(text: _tx.s('s5_pt2')),
              gap(_drop2, 'small'),
              TextSpan(text: _tx.s('s5_pt3')),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(_tx.s('drag_tap_inst'),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.textMuted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final w in const ['molecules', 'small', 'drops', 'heavy'])
              _wordChip(w),
          ],
        ),
      ],
    );
  }

  Widget _wordChip(String w) {
    final used = _usedWords.contains(w);
    return Opacity(
      opacity: used ? 0.35 : 1,
      child: Material(
        color: _rt_Lab.tinted(const Color(0xFFE0F2FE), _cAccent),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: ValueKey('word-$w'),
          borderRadius: BorderRadius.circular(8),
          onTap: used
              ? null
              : () {
                  _rt_playSfx(_rt_Sfx.tap);
                  _tapWord(w);
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cAccent),
            ),
            child: Text(_tx.s('word_$w'),
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: _rt_Lab.text)),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- sidebar ----
  Widget _protocolSelector() {
    return Container(
      color: _rt_Lab.base,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('inv_proto'), icon: Icons.tune, color: _cAccent),
          for (var i = 1; i <= 5; i++)
            KeyedSubtree(
              key: ValueKey('scen-$i'),
              child: _rt_ChoiceButton(
                label: '$i: ${_tx.s('s${i}_t')}',
                state: _scenario == i ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
                onTap: _scenario == i ? null : () => _loadScenario(i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('mission_obj'),
          desc: _tx.s('s${_scenario}_o'),
          accent: _cAccent,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _steps.length; i++) _stepCard(i),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  /// Source .step-card: badge, theory, HUD hint + auto button when active,
  /// conclusion box when completed. Tap a completed card to review its state.
  Widget _stepCard(int i) {
    final b = _base(i);
    final done = i < _step;
    final active = i == _step && !_scenarioDone;
    final viewing = i == _viewStep && _viewStep != _step;
    final borderColor =
        viewing ? _rt_Tw.blue500 : (done ? _rt_Tw.green500 : (active ? _cAccent : _rt_Lab.border));
    final badgeColor = done ? _rt_Tw.green500 : (active ? _cAccent : _rt_Tw.slate500);
    final badgeText = _tx.s(done ? 'completed' : (active ? 'active' : 'pending'));
    return GestureDetector(
      key: ValueKey('card-$i'),
      onTap: i <= _step ? () => _selectStep(i) : null,
      child: Opacity(
        opacity: done || active ? 1 : 0.6,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: active
                ? _rt_Lab.tinted(const Color(0xFFE0F2FE), _cAccent)
                : _rt_Lab.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: active || viewing ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text('${i + 1}. ${_tx.s('${b}_t')}',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: _rt_Lab.onTinted(_cAccent, _rt_Tw.sky500))),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(badgeText.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 5),
              Text(_tx.s('${b}_th'),
                  style:
                      TextStyle(fontSize: 11.5, color: _rt_Lab.textMuted, height: 1.3)),
              if (active) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _rt_Lab.overlay,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _rt_Lab.tintedBorder(_cAccent)),
                  ),
                  child: Text(_tx.s('${b}_h'),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _rt_Lab.text,
                          height: 1.3)),
                ),
                if (_autoSteps.contains(_steps[i])) ...[
                  const SizedBox(height: 8),
                  _rt_ActionButton(
                    key: ValueKey('auto-$i'),
                    label: _tx.s('btn_auto'),
                    icon: Icons.play_circle,
                    color: _cAccent,
                    expand: true,
                    sound: null, // _autoAction plays its own tap
                    onPressed: _viewStep == _step ? _autoAction : null,
                  ),
                ],
              ],
              if (done) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _rt_Lab.tinted(const Color(0xFFDCFCE7), _rt_Tw.green500),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border(left: BorderSide(color: _rt_Tw.green500, width: 3)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle, size: 14, color: _rt_Tw.green500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_tx.s('${b}_c'),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _rt_Lab.onTinted(_rt_Tw.green500, _rt_Tw.green700),
                              height: 1.3)),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
