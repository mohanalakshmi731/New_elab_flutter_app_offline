// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 5.2: Contact Forces (Muscular & Friction)
// Converted from Cl8S-Ch5-A2-ContactForces_MuscularandFriction.html
// (Tailwind DOM + SVG scenes -> Flutter widgets + CustomPainters in a
// ZoomableCanvas).
//
// Two scenarios driven from the sidebar. Scenario 1 (Muscular Force in
// Nature) tours three animated environments -- a horse & cart, a bird in the
// sky and a fish tank -- where the student drags (or taps) muscle labels onto
// each animal, then rotates a force arrow to show the horse pushing the
// ground backward. Scenario 2 (The Stopping Lunch Box) applies exactly 5 N to
// a lunch box that slides from x = 0 m to x = 1.5 m, then asks which arrow is
// the friction force. Each scenario ends in an Observation popup with its
// formula.





// ---------------------------------------------------------------- i18n ----
// Copied from the source's `const i18n = {en, hi, te}` block (te ignored).

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
    'title': 'Contact Forces (Muscular & Friction)',
    'subtitle': 'Class 8 • Exploring Forces',
    'enterLab': 'Enter _rt_Lab',
    'missionObjTitle': 'Mission Objective',
    'missionObjText':
        'Differentiating between contact forces (muscular & friction) and their opposing/propelling effects on motion.',
    'scenarioLabel': 'Scenario',
    'scenario1': 'Scenario 1: Muscular Force in Nature',
    'scenario2': 'Scenario 2: The Stopping Lunch Box',
    'setupBtn': 'Setup Activity',
    'understoodBtn': 'Understood',
    'obsTitle': 'Observation Outcome',
    'choose': 'Choose',
    'stepLabel': 'Step',
    'tabLab': '_rt_Lab Guide',
    'lblLegs': 'Legs',
    'lblWings': 'Wings',
    'lblTail': 'Fins/Tail',
    'lblGround': 'Ground (Reaction Force)',
    'lblCart': 'Cart (Load)',
    'lblAir': 'Air Resistance',
    'lblWater': 'Water Resistance',
    'lblTable': 'Table (Rough Surface)',
    'lblBox': 'Lunch Box (m = 0.5 kg)',
    'lblThigh': 'Thigh Muscles',
    'lblChest': 'Chest Muscles',
    'lblLateral': 'Lateral Muscles',
    'lblAngleSlider': 'Rotate Force Arrow',
    'lblForceSlider': 'Muscular Force',
    'toggleLabels': 'Toggle Labels',
    's1Title': 'Introduction to Muscular Force',
    's1T1':
        'Contact forces require physical interaction. Muscular Force is the force resulting from the action of muscles. Animals use it to push or pull against their environment to move.',
    's1G1Title': 'Observe the Environments',
    's1G1Text': 'Use the Choose selector below to explore.',
    's2Title': 'Identifying the Source',
    's2T1':
        "Different animals rely on different muscular structures to generate the primary force for their locomotion.\n\nLet's map the correct muscular forces to each animal.",
    's2G1Title': 'Identify the Muscles',
    's2G1Text':
        'Drag and drop (or tap) the correct label onto the animal. Complete all three.',
    's3Title': 'Force Vectors',
    's3T1':
        'Muscular force has a specific direction. To move forward, an animal must push backward against the ground, water, or air. This creates an equal and opposite reaction.',
    's3G1Title': 'Set the Force Vector',
    's3G1Text':
        'Use the slider to rotate the yellow arrow. Show the direction the horse pushes against the ground.',
    's4Title': 'Introduction to Friction',
    's4T1':
        'When you stop pushing an object, it eventually stops moving. There must be a force acting against the motion. This is Friction.',
    's4G1Title': 'Observe the Setup',
    's4G1Text': 'Notice the lunch box resting at x = 0 m.',
    's5Title': 'Applying Force',
    's5T1':
        'A stationary lunch box (m = 0.5 kg) is at x = 0. Apply a momentary muscular force to the lunch box. Drag the slider to 5 N and release.',
    's5G1Title': 'Apply Muscular Force',
    's5G1Text': 'Drag the Force Slider exactly to 5 N and release it.',
    's6Title': 'Identifying Friction',
    's6T1':
        'The box moved to the Right. Click the arrow representing the Direction of Friction while the box was sliding.',
    's6G1Title': 'Identify Friction Direction',
    's6G1Text': 'Click the arrow that represents the direction of the Frictional Force.',
    'fbHorse': "The horse's strong leg muscles contract to push backward against the ground.",
    'fbBird': "The bird's large chest muscles flap its wings down and back against the air.",
    'fbFish': "The fish's lateral muscles swish the tail side-to-side to push water backward.",
    'fbWrongAngle': 'Incorrect direction. The horse needs to push the ground backwards.',
    'fbRightAngle': 'Correct! The horse pushes backward (180°) to propel forward.',
    'fbWrongForce': 'Incorrect force. Read the instructions carefully!',
    'fbRightForce': 'Perfect force applied! The hand pushes the box.',
    'fbWrongFric': 'Wrong direction! Friction opposes motion.',
    'fbRightFric': 'Correct! Friction always acts opposite to motion.',
    'fbWrongDrop': 'Wrong muscle group for this animal!',
    'obs1Title': 'Observation: Scenario 1',
    'obs1Body':
        "Animals exert a muscular force backward against their environment (ground, water, air). According to Newton's Third Law, the environment exerts an equal and opposite force forward, propelling the animal:",
    'obs2Title': 'Observation: Scenario 2',
    'obs2Body':
        'Even when an object slides on a smooth-looking table, microscopic irregularities interlock. Friction is the contact force that opposes this relative motion, acting in the direction opposite to the movement until the object decelerates to rest:',
  },
  'hi': {
    'title': 'संपर्क बल (मांसपेशीय और घर्षण)',
    'subtitle': 'कक्षा 8 • बलों की खोज',
    'enterLab': 'लैब में प्रवेश करें',
    'missionObjTitle': 'मिशन उद्देश्य',
    'missionObjText':
        'संपर्क बलों (मांसपेशीय और घर्षण) और गति पर उनके विरोधी/प्रेरक प्रभावों के बीच अंतर करना।',
    'scenarioLabel': 'परिदृश्य',
    'scenario1': 'परिदृश्य 1: प्रकृति में पेशीय बल',
    'scenario2': 'परिदृश्य 2: रुकता हुआ लंच बॉक्स',
    'setupBtn': 'गतिविधि सेट करें',
    'understoodBtn': 'समझ गया',
    'obsTitle': 'अवलोकन परिणाम',
    'choose': 'चुनें',
    'stepLabel': 'चरण',
    'tabLab': 'लैब गाइड',
    'lblLegs': 'पैर',
    'lblWings': 'पंख',
    'lblTail': 'पूंछ / फिन',
    'lblGround': 'जमीन (प्रतिक्रिया बल)',
    'lblCart': 'गाड़ी (भार)',
    'lblAir': 'वायु प्रतिरोध',
    'lblWater': 'जल प्रतिरोध',
    'lblTable': 'मेज (खुरदरी सतह)',
    'lblBox': 'लंच बॉक्स (m = 0.5 kg)',
    'lblThigh': 'जांघ की मांसपेशियां',
    'lblChest': 'छाती की मांसपेशियां',
    'lblLateral': 'पार्श्व मांसपेशियां',
    'lblAngleSlider': 'बल तीर घुमाएँ',
    'lblForceSlider': 'पेशीय बल',
    'toggleLabels': 'लेबल दिखाएँ/छिपाएँ',
    's1Title': 'पेशीय बल का परिचय',
    's1T1':
        'संपर्क बलों के लिए भौतिक अंतःक्रिया की आवश्यकता होती है। पेशीय बल मांसपेशियों की क्रिया से उत्पन्न होने वाला बल है। जानवर चलने के लिए अपने पर्यावरण के विरुद्ध धकेलने या खींचने के लिए इसका उपयोग करते हैं।',
    's1G1Title': 'पर्यावरण का निरीक्षण करें',
    's1G1Text': "अन्वेषण करने के लिए नीचे दिए गए 'चुनें' का उपयोग करें।",
    's2Title': 'स्रोत की पहचान',
    's2T1':
        'विभिन्न जानवर अपनी गति के लिए प्राथमिक बल उत्पन्न करने के लिए विभिन्न मांसपेशीय संरचनाओं पर निर्भर करते हैं।\n\nआइए प्रत्येक जानवर के लिए सही पेशीय बलों का मिलान करें।',
    's2G1Title': 'मांसपेशियों को पहचानें',
    's2G1Text':
        'सही लेबल को खींचें (या टैप करें) और जानवर पर छोड़ें। तीनों को पूरा करें।',
    's3Title': 'बल के वैक्टर',
    's3T1':
        'पेशीय बल की एक विशिष्ट दिशा होती है। आगे बढ़ने के लिए, एक जानवर को जमीन, पानी या हवा के खिलाफ पीछे की ओर धकेलना चाहिए। यह एक समान और विपरीत प्रतिक्रिया बनाता है।',
    's3G1Title': 'बल वेक्टर सेट करें',
    's3G1Text':
        'पीले तीर को घुमाने के लिए स्लाइडर का उपयोग करें। वह दिशा दिखाएं जिसमें घोड़ा जमीन के खिलाफ धकेलता है।',
    's4Title': 'घर्षण का परिचय',
    's4T1':
        'जब आप किसी वस्तु को धकेलना बंद कर देते हैं, तो वह अंततः रुक जाती है। गति के विरुद्ध काम करने वाला कोई बल होना चाहिए। यही घर्षण है।',
    's4G1Title': 'सेटअप का निरीक्षण करें',
    's4G1Text': 'ध्यान दें कि लंच बॉक्स x = 0 m पर रखा है।',
    's5Title': 'बल लगाना',
    's5T1':
        'एक स्थिर लंच बॉक्स (m = 0.5 kg) x = 0 पर है। लंच बॉक्स पर एक क्षणिक पेशीय बल लागू करें। स्लाइडर को 5 N पर खींचें और छोड़ें।',
    's5G1Title': 'पेशीय बल लगाएँ',
    's5G1Text': 'बल स्लाइडर को ठीक 5 N पर खींचें और छोड़ें।',
    's6Title': 'घर्षण की पहचान',
    's6T1':
        'बॉक्स दाईं ओर चला गया। बॉक्स के खिसकने के दौरान घर्षण की दिशा दर्शाने वाले तीर पर क्लिक करें।',
    's6G1Title': 'घर्षण दिशा को पहचानें',
    's6G1Text': 'घर्षण बल की दिशा दर्शाने वाले तीर पर क्लिक करें।',
    'fbHorse': 'घोड़े की मजबूत पैर की मांसपेशियां जमीन के खिलाफ पीछे की ओर धकेलने के लिए सिकुड़ती हैं।',
    'fbBird': 'पक्षी की बड़ी छाती की मांसपेशियां हवा के खिलाफ अपने पंखों को नीचे और पीछे फड़फड़ाती हैं।',
    'fbFish': 'मछली की पार्श्व मांसपेशियां पानी को पीछे की ओर धकेलने के लिए पूंछ को अगल-बगल हिलाती हैं।',
    'fbWrongAngle': 'गलत दिशा। घोड़े को जमीन को पीछे की ओर धकेलना होगा।',
    'fbRightAngle': 'सही! घोड़ा आगे बढ़ने के लिए पीछे की ओर (180°) धकेलता है।',
    'fbWrongForce': 'गलत बल। निर्देशों को ध्यान से पढ़ें!',
    'fbRightForce': 'सही बल लगाया गया! हाथ बॉक्स को धकेलता है।',
    'fbWrongFric': 'गलत दिशा! घर्षण गति का विरोध करता है।',
    'fbRightFric': 'सही! घर्षण हमेशा गति के विपरीत कार्य करता है।',
    'fbWrongDrop': 'इस जानवर के लिए गलत मांसपेशी समूह!',
    'obs1Title': 'अवलोकन: परिदृश्य 1',
    'obs1Body':
        'जानवर अपने पर्यावरण (जमीन, पानी, हवा) के खिलाफ पीछे की ओर पेशीय बल लगाते हैं। न्यूटन के तीसरे नियम के अनुसार, पर्यावरण जानवर को आगे बढ़ाने के लिए एक समान और विपरीत बल आगे की ओर लगाता है:',
    'obs2Title': 'अवलोकन: परिदृश्य 2',
    'obs2Body':
        'यहां तक कि जब कोई वस्तु चिकनी दिखने वाली मेज पर फिसलती है, तो सूक्ष्म अनियमितताएं आपस में जुड़ जाती हैं। घर्षण वह संपर्क बल है जो इस सापेक्ष गति का विरोध करता है, गति के विपरीत दिशा में तब तक कार्य करता है जब तक वस्तु रुक न जाए:',
  },
});

// Animal roster, mirroring the source's ANIMALS array.
const _animalIds = ['horse', 'bird', 'fish'];
const _animalIcons = ['🐎', '🦅', '🐠'];
const _animalAccept = ['legs', 'wings', 'tail'];
const _animalFbKeys = ['fbHorse', 'fbBird', 'fbFish'];

class Cl8Ch05A2ContactForcesPage extends StatefulWidget {
  const Cl8Ch05A2ContactForcesPage({super.key});

  @override
  State<Cl8Ch05A2ContactForcesPage> createState() => _Cl8Ch05A2ContactForcesPageState();
}

class _Cl8Ch05A2ContactForcesPageState extends State<Cl8Ch05A2ContactForcesPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();

  // Continuous clock: one 10 s loop drives gallop / flap / swish / idle
  // float / to-and-fro travel (the CSS keyframe timings map onto it).
  late final AnimationController _ticker =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

  // Lunch box slide (the source's 2 s `anim-slide-box` transition).
  late final AnimationController _slide =
      AnimationController(vsync: this, duration: const Duration(seconds: 2));

  int _scenario = 1;
  int _step = 0;
  int _animal = 0;
  final Map<String, bool> _done = {'horse': false, 'bird': false, 'fish': false};

  // Per-animal travel start time (fraction of the 10 s clock) so the
  // to-and-fro run starts from the rest position when unlocked.
  final Map<String, double> _travelT0 = {};

  bool _showLabels = true;
  bool _guideDismissed = false;

  double _angle = 0;
  bool _angleLocked = false;

  double _force = 0;
  bool _forceLocked = false;

  bool _fricDone = false;
  bool _handVisible = false;
  bool _handPushing = false;

  String? _feedback;
  bool _feedbackError = false;

  Timer? _stepTimer;
  final List<Timer> _miscTimers = [];

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
    _stepTimer?.cancel();
    for (final t in _miscTimers) {
      t.cancel();
    }
    _ticker.dispose();
    _slide.dispose();
    _zoom.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ state ops --
  void _cancelTimers() {
    _stepTimer?.cancel();
    _stepTimer = null;
    for (final t in _miscTimers) {
      t.cancel();
    }
    _miscTimers.clear();
  }

  void _after(int ms, VoidCallback fn) {
    final t = Timer(Duration(milliseconds: ms), () {
      if (mounted) fn();
    });
    _miscTimers.add(t);
  }

  /// The source's `resetLab(n)`: full per-scenario reset.
  void _resetLab(int scenario, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    _cancelTimers();
    setState(() {
      _scenario = scenario;
      _step = 0;
      _animal = 0;
      _done.updateAll((_, _) => false);
      _travelT0.clear();
      _angle = 0;
      _angleLocked = false;
      _force = 0;
      _forceLocked = false;
      _fricDone = false;
      _handVisible = false;
      _handPushing = false;
      _feedback = null;
      _guideDismissed = false;
      _slide.value = 0;
    });
    _zoom.reset();
  }

  void _restart() => _resetLab(1, sound: false);

  void _advanceStep() {
    _stepTimer?.cancel();
    if (_step < 2) {
      _rt_playSfx(_rt_Sfx.scenario);
      setState(() {
        _step++;
        _feedback = null;
        _guideDismissed = false;
        if (_scenario == 1 && _step == 2) {
          // Step 3 forces the horse (the source's `forceAnimal: 0`).
          _animal = 0;
        }
      });
    } else {
      _showObservation();
    }
  }

  void _showObservation() {
    setState(() => _feedback = null);
    final n = _scenario;
    _shell.showSuccess(
      title: _tx.s('obs${n}Title'),
      message: _tx.s('obs${n}Body'),
      buttonLabel: _tx.s('understoodBtn'),
      icon: Icons.newspaper,
      color: _rt_Tw.blue600,
      body: _FormulaBox(
        spans: n == 1
            ? const [('F', 'propulsion'), (' = − ', ''), ('F', 'muscular')]
            : const [('v', 'final'), (' = 0   (due to ', ''), ('F', 'friction'), (')', '')],
      ),
    );
  }

  void _setFeedback(String key, {required bool error}) {
    setState(() {
      _feedback = _tx.s(key);
      _feedbackError = error;
    });
  }

  // ----------------------------------------------------- scenario 1 logic --
  void _selectAnimal(int delta) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _animal = (_animal + delta + 3) % 3;
      final id = _animalIds[_animal];
      if (_done[id]! && !_travelT0.containsKey(id)) _travelT0[id] = _ticker.value;
    });
  }

  /// Shared by the drag-drop and the tap-to-place path.
  void _tryPlaceMuscle(String type) {
    final id = _animalIds[_animal];
    if (_done[id]!) return;
    if (type == _animalAccept[_animal]) {
      _rt_playSfx(_rt_Sfx.correct);
      _rt_playSfx(_rt_Sfx.magic, volume: 0.6); // muscle glow + animation reveal
      setState(() {
        _done[id] = true;
        _travelT0[id] = _ticker.value;
      });
      _setFeedback(_animalFbKeys[_animal], error: false);
      if (_done.values.every((d) => d)) {
        _stepTimer = Timer(const Duration(milliseconds: 2500), () {
          if (mounted) _advanceStep();
        });
      }
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _setFeedback('fbWrongDrop', error: true);
    }
  }

  void _checkAngle(double v) {
    if (_angleLocked) return;
    _rt_playSfx(_rt_Sfx.tap, volume: 0.6);
    if (v >= 170 && v <= 190) {
      _rt_playSfx(_rt_Sfx.correct);
      _rt_playSfx(_rt_Sfx.magic, volume: 0.6); // horse gallops off
      setState(() {
        _angleLocked = true;
        _travelT0['horse'] = _ticker.value;
      });
      _setFeedback('fbRightAngle', error: false);
      _stepTimer = Timer(const Duration(milliseconds: 3500), () {
        if (mounted) _advanceStep();
      });
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _setFeedback('fbWrongAngle', error: true);
    }
  }

  // ----------------------------------------------------- scenario 2 logic --
  void _checkForce(double v) {
    if (_forceLocked) return;
    _rt_playSfx(_rt_Sfx.tap, volume: 0.6);
    if (v.round() == 5) {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() {
        _forceLocked = true;
        _handVisible = true;
        _handPushing = true;
      });
      _after(500, () {
        _rt_playSfx(_rt_Sfx.pop); // the hand strikes the box and it starts to slide
        setState(() => _handPushing = false);
        _slide.forward();
        _after(500, () => setState(() => _handVisible = false));
      });
      _setFeedback('fbRightForce', error: false);
      _stepTimer = Timer(const Duration(milliseconds: 3000), () {
        if (mounted) _advanceStep();
      });
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() => _force = 0);
      _setFeedback('fbWrongForce', error: true);
    }
  }

  void _pickFriction(bool left) {
    if (_fricDone) return;
    if (left) {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _fricDone = true);
      _setFeedback('fbRightFric', error: false);
      _stepTimer = Timer(const Duration(milliseconds: 3500), () {
        if (mounted) _advanceStep();
      });
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _setFeedback('fbWrongFric', error: true);
    }
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  // ---------------------------------------------------------------- build --
  (String, String) get _stepKeys {
    final base = _scenario == 1 ? _step + 1 : _step + 4;
    return ('s${base}Title', 's${base}T1');
  }

  (String, String) get _guideKeys {
    final base = _scenario == 1 ? _step + 1 : _step + 4;
    return ('s${base}G1Title', 's${base}G1Text');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final (guideTitleKey, guideTextKey) = _guideKeys;
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.yellow500,
              headerGradient: [_rt_Tw.slate950, Color(0xFF4C0519)],
              headerSubtitleColor: _rt_Tw.amber200,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.swap_horiz,
              footnote: 'Muscular Force • Friction',
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: _showLabels ? Icons.label : Icons.label_off,
                tooltip: _tx.s('toggleLabels'),
                onTap: _toggleLabels,
              ),
            ],
            hint: _rt_StepHint(
              number: '${_step + 1}',
              text: _tx.s(guideTextKey),
              label: _tx.s(guideTitleKey),
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabLab'),
                icon: Icons.menu_book,
                builder: (_) => _sidebarTab(),
              ),
            ],
            canvas: _rt_ZoomableCanvas(controller: _zoom, child: _sceneCanvas()),
            canvasOverlays: [
              // Top instruction HUD (the source's draggable #instruction-guide).
              if (!_guideDismissed)
                Positioned(
                  top: 8,
                  left: 72,
                  right: 60,
                  child: Center(
                    child: _instructionHud(_tx.s(guideTitleKey), _tx.s(guideTextKey)),
                  ),
                ),
              // Bottom HUD: feedback + animal selector + task controls.
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_feedback != null) _feedbackChip(),
                    if (_scenario == 1) ...[
                      const SizedBox(height: 6),
                      _animalSelector(),
                    ],
                    const SizedBox(height: 6),
                    _taskControls(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------- sidebar --
  Widget _sidebarTab() {
    final (titleKey, textKey) = _stepKeys;
    final (guideTitleKey, guideTextKey) = _guideKeys;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObjTitle'),
          desc: _tx.s('missionObjText'),
          accent: _rt_Tw.yellow500,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('scenarioLabel'), icon: Icons.tune),
              _rt_ChoiceButton(
                key: const ValueKey('scn1'),
                label: _tx.s('scenario1'),
                state: _scenario == 1 ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
                onTap: _scenario == 1 ? null : () => _resetLab(1),
              ),
              _rt_ChoiceButton(
                key: const ValueKey('scn2'),
                label: _tx.s('scenario2'),
                state: _scenario == 2 ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
                onTap: _scenario == 2 ? null : () => _resetLab(2),
              ),
              const SizedBox(height: 10),
              _rt_InfoCard(
                tag: '${_tx.s('stepLabel')} ${_step + 1} / 3',
                title: _tx.s(titleKey),
                body: _tx.s(textKey),
                color: _rt_Tw.blue600,
                icon: Icons.school,
              ),
              _rt_InfoCard(
                title: _tx.s(guideTitleKey),
                body: _tx.s(guideTextKey),
                color: _rt_Tw.yellow500,
                icon: Icons.touch_app,
                leftBorder: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ HUD parts --
  Widget _instructionHud(String title, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: const Border(top: BorderSide(color: _rt_Tw.yellow500, width: 3)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _rt_Lab.textMuted)),
                const SizedBox(height: 2),
                Text(text,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: _rt_Tw.yellow500)),
              ],
            ),
          ),
          GestureDetector(
            key: const ValueKey('guide-close'),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() => _guideDismissed = true);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.close, size: 16, color: _rt_Lab.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackChip() {
    final color = _feedbackError ? _rt_Tw.red500 : _rt_Tw.green500;
    return Container(
      key: const ValueKey('feedback'),
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_feedbackError ? Icons.cancel : Icons.check_circle, size: 15, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(_feedback!,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _rt_Lab.text)),
          ),
        ],
      ),
    );
  }

  Widget _animalSelector() {
    final locked = _step == 2; // step 3 pins the horse
    Widget chev(IconData icon, int delta, String keyName) => Opacity(
          opacity: locked ? 0.2 : 1,
          child: InkResponse(
            key: ValueKey(keyName),
            radius: 20,
            onTap: locked ? null : () => _selectAnimal(delta),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: _rt_Lab.textMuted),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: const Border(bottom: BorderSide(color: _rt_Tw.blue400, width: 3)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_tx.s('choose').toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: _rt_Lab.textMuted)),
          const SizedBox(width: 10),
          chev(Icons.chevron_left, -1, 'animal-prev'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(_animalIcons[_animal], style: const TextStyle(fontSize: 26)),
          ),
          chev(Icons.chevron_right, 1, 'animal-next'),
        ],
      ),
    );
  }

  /// The bottom `#task-controls` card, contents by scenario + step.
  Widget _taskControls() {
    Widget? inner;
    if (_step == 0) {
      inner = _rt_ActionButton(
        key: const ValueKey('setup-btn'),
        label: _tx.s('setupBtn'),
        icon: Icons.play_arrow,
        color: _rt_Tw.yellow500,
        onPressed: _advanceStep,
      );
    } else if (_scenario == 1 && _step == 1) {
      inner = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                _musclePill(_animalAccept[i], _tx.s(['lblLegs', 'lblWings', 'lblTail'][i]),
                    done: _done[_animalIds[i]]!),
            ],
          ),
        ],
      );
    } else if (_scenario == 1 && _step == 2) {
      inner = _HudSlider(
        key: const ValueKey('angle-slider'),
        label: _tx.s('lblAngleSlider'),
        value: _angle,
        min: 0,
        max: 360,
        divisions: 72,
        valueText: '${_angle.round()}°',
        enabled: !_angleLocked,
        onChanged: (v) => setState(() => _angle = v),
        onReleased: _checkAngle,
      );
    } else if (_scenario == 2 && _step == 1) {
      inner = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HudSlider(
            key: const ValueKey('force-slider'),
            label: _tx.s('lblForceSlider'),
            value: _force,
            min: 0,
            max: 10,
            divisions: 10,
            valueText: '${_force.round()} N',
            enabled: !_forceLocked,
            onChanged: (v) => setState(() => _force = v),
            onReleased: _checkForce,
          ),
        ],
      );
    }
    if (inner == null) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: inner,
    );
  }

  Widget _musclePill(String type, String label, {required bool done}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: done ? _rt_Lab.overlay : _rt_Lab.base,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: done ? _rt_Tw.green500 : _rt_Lab.borderStrong, width: 1.5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: done ? _rt_Tw.green400 : _rt_Lab.text)),
    );
    if (done) return Opacity(opacity: 0.45, child: chip);
    // Draggable pill (the source drag) + tap-to-place fallback for small
    // canvases and tests.
    return Draggable<String>(
      data: type,
      onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
      feedback: Material(color: Colors.transparent, child: chip),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: GestureDetector(
        key: ValueKey('pill-$type'),
        onTap: () {
          _rt_playSfx(_rt_Sfx.tap);
          _tryPlaceMuscle(type);
        },
        child: chip,
      ),
    );
  }

  // ---------------------------------------------------------------- scene --
  Widget _sceneCanvas() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        if (_scenario == 2) return _boxScene(w, h);
        return switch (_animal) {
          0 => _horseScene(w, h),
          1 => _birdScene(w, h),
          _ => _fishScene(w, h),
        };
      },
    );
  }

  /// Travel offset for a completed animal, mirroring the CSS to-fro
  /// keyframes: 10 s loop, out to one side, flip, back through to the other.
  /// [sign] is -1 for the horse (goes left first), +1 for bird/fish.
  (double, bool) _travel(String id, double amplitude, int sign) {
    if (!_done[id]!) return (0, false);
    if (_scenario == 1 && _step == 2 && !_angleLocked && id == 'horse') {
      // Step 3 starts with the horse standing still again.
      return (0, false);
    }
    final t0 = _travelT0[id] ?? 0;
    final p = (_ticker.value - t0 + 1) % 1;
    double x;
    bool flip;
    if (p < 0.25) {
      x = -(p / 0.25);
      flip = false;
    } else if (p < 0.75) {
      x = -1 + (p - 0.25) / 0.25;
      flip = true;
    } else {
      x = 1 - (p - 0.75) / 0.25;
      flip = false;
    }
    return (x * amplitude * sign, flip);
  }

  bool _animActive(String id) {
    if (!_done[id]!) return false;
    if (_scenario == 1 && _step == 2 && !_angleLocked && id == 'horse') return false;
    return true;
  }

  Widget _label(String text, {Key? key}) {
    if (!_showLabels) return const SizedBox.shrink();
    return IgnorePointer(
      child: Container(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: _rt_Lab.text)),
      ),
    );
  }

  /// Generous invisible drop zone + tap zone over the animal.
  Widget _dropZone(double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: DragTarget<String>(
        builder: (context, candidates, _) => Container(
          decoration: candidates.isEmpty
              ? null
              : BoxDecoration(
                  border: Border.all(color: _rt_Tw.yellow400, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
        ),
        onAcceptWithDetails: (d) => _tryPlaceMuscle(d.data),
      ),
    );
  }

  // Scene 1A: horse & cart --------------------------------------------------
  Widget _horseScene(double w, double h) {
    final s = math.min(w * 0.72 / 800, h * 0.52 / 350);
    final baseY = h * 0.84;
    final active = _animActive('horse');
    final glowOn = _done['horse']!;
    final interactive = _scenario == 1 && _step == 1 && !_done['horse']!;
    final showArrow = _scenario == 1 && _step == 2;

    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final (dx, flip) = _travel('horse', w * 0.30, -1);
        // Anchor of the horse's ground contact (viewBox x=256, wrapper centre 400).
        final anchorX = w / 2 + dx - 144 * s;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HorseScenePainter(
                  ticker: _ticker,
                  scale: s,
                  baseY: baseY,
                  dx: dx,
                  flip: flip,
                  active: active,
                  glow: glowOn ? 1 : 0,
                ),
              ),
            ),
            // Labels (ride along with the wrapper like the source's).
            Positioned(
              left: w / 2 + dx - 160 * s - 40,
              top: baseY - 210 * s,
              child: _label(_tx.s('lblThigh')),
            ),
            Positioned(
              left: w / 2 + dx + 175 * s - 40,
              top: baseY - 290 * s,
              child: _label(_tx.s('lblCart')),
            ),
            Positioned(
              left: 16,
              bottom: h * 0.03,
              child: _label(_tx.s('lblGround')),
            ),
            if (interactive) _dropZone(w / 2 + dx - 220 * s, baseY - 220 * s, 130),
            if (showArrow)
              Positioned(
                left: anchorX - 40,
                top: baseY - 240 * s - 46,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: _angle * math.pi / 180,
                    child: Icon(
                      Icons.east,
                      key: const ValueKey('force-arrow'),
                      size: 80,
                      color: _angleLocked ? _rt_Tw.green400 : _rt_Tw.yellow400,
                      shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Scene 1B: bird ----------------------------------------------------------
  Widget _birdScene(double w, double h) {
    final s = math.min(w * 0.36 / 300, h * 0.62 / 300);
    final active = _animActive('bird');
    final glowOn = _done['bird']!;
    final interactive = _scenario == 1 && _step == 1 && !_done['bird']!;
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final (dx, flip) = _travel('bird', w * 0.30, 1);
        final cx = w / 2 + dx;
        final cy = h * 0.42;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BirdScenePainter(
                  ticker: _ticker,
                  scale: s,
                  cx: cx,
                  cy: cy,
                  flip: flip,
                  active: active,
                  glow: glowOn ? 1 : 0,
                ),
              ),
            ),
            Positioned(
              left: w * 0.58,
              top: h * 0.24,
              child: _label(_tx.s('lblAir')),
            ),
            Positioned(
              left: cx - 45,
              top: cy + 60 * s,
              child: _label(_tx.s('lblChest')),
            ),
            if (interactive) _dropZone(cx - 70, cy - 70, 140),
          ],
        );
      },
    );
  }

  // Scene 1C: aquarium ------------------------------------------------------
  Widget _fishScene(double w, double h) {
    final active = _animActive('fish');
    final glowOn = _done['fish']!;
    final interactive = _scenario == 1 && _step == 1 && !_done['fish']!;
    // Tank geometry shared with the painter.
    final tankW = math.min(w * 0.78, 760.0);
    final tankH = h * 0.48;
    final tankLeft = (w - tankW) / 2;
    final tankTop = h * 0.66 - tankH;
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final (dxRaw, flip) = _travel('fish', tankW * 0.26, 1);
        final fx = tankLeft + tankW * 0.40 + dxRaw;
        final fy = tankTop + tankH * 0.38;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FishScenePainter(
                  ticker: _ticker,
                  tank: Rect.fromLTWH(tankLeft, tankTop, tankW, tankH),
                  fx: fx,
                  fy: fy,
                  flip: flip,
                  active: active,
                  glow: glowOn ? 1 : 0,
                ),
              ),
            ),
            Positioned(
              left: w * 0.56,
              top: h * 0.235,
              child: _label(_tx.s('lblWater')),
            ),
            Positioned(
              left: fx - 45,
              top: fy + 26,
              child: _label(_tx.s('lblLateral')),
            ),
            if (interactive) _dropZone(fx - 65, fy - 65, 130),
          ],
        );
      },
    );
  }

  // Scene 2: lunch box ------------------------------------------------------
  Widget _boxScene(double w, double h) {
    final tableTop = h * 0.66;
    final boxW = math.min(w * 0.18, 150.0);
    final boxH = boxW * 0.55;
    final startX = w * 0.16;
    final slideDist = w * 0.38;
    final showArrows = _step == 2;
    return AnimatedBuilder(
      animation: Listenable.merge([_slide, _ticker]),
      builder: (context, _) {
        final slid = _step == 2 ? 1.0 : Curves.easeOutCubic.transform(_slide.value);
        final boxX = startX + slideDist * slid;
        final endCx = startX + slideDist + boxW / 2;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _BoxScenePainter(tableTop: tableTop)),
            ),
            // Position markers.
            Positioned(
              left: startX + boxW / 2 - 30,
              top: tableTop + 14,
              child: _label('x = 0 m'),
            ),
            Positioned(
              left: endCx - 34,
              top: tableTop + 14,
              child: _label('x = 1.5 m'),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: tableTop + 44,
              child: Center(child: _label(_tx.s('lblTable'))),
            ),
            // Pushing hand.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              left: startX - boxW * 0.52 + (_handPushing ? 34 : 0),
              top: tableTop - boxH * 0.9,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _handVisible ? 1 : 0,
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: Icon(Icons.pan_tool,
                      size: boxH * 0.9,
                      color: const Color(0xFFEAC086),
                      shadows: const [Shadow(color: Colors.black45, blurRadius: 6)]),
                ),
              ),
            ),
            // The lunch box itself.
            Positioned(
              left: boxX,
              top: tableTop - boxH,
              width: boxW,
              height: boxH,
              child: _lunchBox(boxW, boxH),
            ),
            Positioned(
              left: boxX + boxW / 2 - 60,
              top: tableTop - boxH - 26,
              child: _label(_tx.s('lblBox')),
            ),
            // Friction arrows over the slid box.
            if (showArrows) ...[
              Positioned(
                left: endCx - boxW / 2 - 212,
                top: tableTop - boxH / 2 - 34,
                width: 200,
                child: _frictionArrow(left: true),
              ),
              if (!_fricDone)
                Positioned(
                  left: endCx + boxW / 2 + 24,
                  top: tableTop - boxH / 2 - 34,
                  child: _frictionArrow(left: false),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _lunchBox(double bw, double bh) {
    return Container(
      decoration: BoxDecoration(
        color: _rt_Tw.yellow500,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Tw.amber700, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(8, 8))],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: bw * 0.8,
          height: bh * 0.28,
          decoration: const BoxDecoration(
            color: _rt_Tw.yellow400,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border(bottom: BorderSide(color: _rt_Tw.amber600, width: 3)),
          ),
        ),
      ),
    );
  }

  Widget _frictionArrow({required bool left}) {
    final picked = _fricDone && left;
    return GestureDetector(
      key: ValueKey(left ? 'arrow-left' : 'arrow-right'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _pickFriction(left),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: left ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (picked)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _FrictionTag(),
            ),
          Icon(
            left ? Icons.west : Icons.east,
            size: 64,
            color: picked ? _rt_Tw.green400 : Colors.white.withValues(alpha: 0.9),
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ HUD widgets --

/// HUD slider with a release callback (the HTML sliders check on `change`).
class _HudSlider extends StatelessWidget {
  const _HudSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueText,
    required this.enabled,
    required this.onChanged,
    required this.onReleased,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueText;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onReleased;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: _rt_Lab.textMuted)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: _rt_Tw.yellow500,
              thumbColor: _rt_Tw.yellow500,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
              onChangeEnd: enabled ? onReleased : null,
            ),
          ),
          Text(valueText,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _rt_Tw.yellow500,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

/// "F_friction" tag shown once the left arrow is picked.
class _FrictionTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rt_Tw.green500, width: 2),
      ),
      child: Text.rich(
        TextSpan(children: [
          const TextSpan(
              text: 'F',
              style: TextStyle(
                  fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
          TextSpan(
              text: 'friction',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: _rt_Lab.textMuted)),
        ]),
        style: TextStyle(color: _rt_Tw.green400, fontFamily: 'serif', height: 1),
      ),
    );
  }
}

/// Serif formula card used in the Observation popups.
class _FormulaBox extends StatelessWidget {
  const _FormulaBox({required this.spans});

  /// (main, subscript) pairs, e.g. ('F', 'propulsion').
  final List<(String, String)> spans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Text.rich(
        TextSpan(children: [
          for (final (main, sub) in spans) ...[
            TextSpan(
                text: main,
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: main.length == 1 ? FontStyle.italic : FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: _rt_Lab.text)),
            if (sub.isNotEmpty)
              TextSpan(
                  text: sub,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _rt_Lab.textMuted)),
          ],
        ]),
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'serif'),
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
            color: active ? _rt_Tw.yellow500 : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: active ? _rt_Tw.slate900 : _rt_Lab.textMuted),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- painters --

double _deg(double d) => d * math.pi / 180;

/// Shared muscle glow (the SVG radial `muscle-glow` gradient).
void _paintGlow(Canvas canvas, Offset c, double rx, double ry, double opacity) {
  if (opacity <= 0) return;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(1, ry / rx);
  canvas.drawCircle(
    Offset.zero,
    rx,
    Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFEF4444).withValues(alpha: 0.9 * opacity),
        const Color(0xFFEF4444).withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: Offset.zero, radius: rx)),
  );
  canvas.restore();
}

/// Scene 1A -- sky, hills, dirt path and the horse + cart (SVG viewBox
/// 800x350 scaled by [scale], bottom edge on [baseY], centred + [dx]).
class _HorseScenePainter extends CustomPainter {
  _HorseScenePainter({
    required this.ticker,
    required this.scale,
    required this.baseY,
    required this.dx,
    required this.flip,
    required this.active,
    required this.glow,
  }) : super(repaint: ticker);

  final AnimationController ticker;
  final double scale;
  final double baseY;
  final double dx;
  final bool flip;
  final bool active;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final t = ticker.value * 10; // seconds

    // Sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DD3FC), Color(0xFFE0F2FE)],
        ).createShader(Offset.zero & size),
    );
    // Hills.
    canvas.drawOval(Rect.fromLTWH(-w * 0.2, h * 0.32, w * 1.4, h * 0.8),
        Paint()..color = const Color(0xFF4ADE80));
    canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.42, w * 1.0, h * 0.62),
        Paint()..color = const Color(0xFF22C55E));
    // Ground + path.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.70, w, h * 0.30), Paint()..color = const Color(0xFF16A34A));
    final path = Rect.fromLTWH(0, h * 0.73, w, h * 0.12);
    canvas.drawRect(path, Paint()..color = const Color(0xFFD97706));
    final edge = Paint()
      ..color = const Color(0xFFB45309)
      ..strokeWidth = 3;
    canvas.drawLine(path.topLeft, path.topRight, edge);
    canvas.drawLine(path.bottomLeft, path.bottomRight, edge);

    // Horse + cart wrapper (viewBox 800x350).
    canvas.save();
    canvas.translate(w / 2 + dx, baseY);
    if (flip) canvas.scale(-1, 1);
    canvas.scale(scale, scale);
    canvas.translate(-400, -350);
    _paintCart(canvas, t);
    _paintHorse(canvas, t);
    canvas.restore();
  }

  void _paintCart(Canvas canvas, double t) {
    // Body.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(420, 80, 310, 150), const Radius.circular(40)),
        Paint()..color = const Color(0xFFFFF8DC));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(420, 80, 310, 150), const Radius.circular(40)),
        Paint()
          ..color = const Color(0xFFDEB887)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
    // Base plank.
    canvas.drawRect(const Rect.fromLTWH(400, 230, 350, 40), Paint()..color = const Color(0xFF8B4513));
    canvas.drawRect(
        const Rect.fromLTWH(400, 230, 350, 40),
        Paint()
          ..color = const Color(0xFF5C4033)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    // Wheels (spin when galloping: 0.8 s per turn).
    final spin = active ? -(t / 0.8) * 2 * math.pi : 0.0;
    for (final cx in [470.0, 680.0]) {
      canvas.save();
      canvas.translate(cx, 270);
      canvas.rotate(spin);
      canvas.drawCircle(
          Offset.zero,
          40,
          Paint()
            ..color = const Color(0xFF3E2723)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12);
      final spoke = Paint()
        ..color = const Color(0xFFA0522D)
        ..strokeWidth = 4;
      canvas.drawLine(const Offset(-40, 0), const Offset(40, 0), spoke);
      canvas.drawLine(const Offset(0, -40), const Offset(0, 40), spoke);
      canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFF9CA3AF));
      canvas.restore();
    }
    // Shaft to the horse.
    canvas.drawLine(const Offset(200, 200), const Offset(400, 250),
        Paint()
          ..color = const Color(0xFF222222)
          ..strokeWidth = 6);
  }

  void _paintHorse(Canvas canvas, double t) {
    // Gallop leg angles (CSS gallop keyframes, 0.4 s cycle).
    double frontRot = 0, backRot = 0, frontRot2 = 0, backRot2 = 0;
    if (active) {
      double cyc(double phase) => 0.5 - 0.5 * math.cos(2 * math.pi * ((t / 0.4 + phase) % 1));
      frontRot = _deg(-30 + 50 * cyc(0));
      frontRot2 = _deg(-30 + 50 * cyc(0.5));
      backRot = _deg(20 - 50 * cyc(0));
      backRot2 = _deg(20 - 50 * cyc(0.5));
    }

    // Tail.
    final tail = Path()
      ..moveTo(280, 140)
      ..quadraticBezierTo(330, 160, 320, 220)
      ..quadraticBezierTo(290, 170, 270, 140)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFF3E2723));

    void leg(double x, double rot, Color color) {
      canvas.save();
      canvas.translate(x + 10, 160);
      canvas.rotate(rot);
      canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-10, 0, 20, 140), const Radius.circular(8)),
          Paint()..color = color);
      canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-12, 135, 24, 15), const Radius.circular(4)),
          Paint()..color = const Color(0xFF222222));
      canvas.restore();
    }

    // Back legs behind body.
    leg(210, backRot, const Color(0xFF6B3E11));
    leg(250, backRot2, const Color(0xFF8B4513));
    // Body.
    canvas.drawOval(Rect.fromCenter(center: const Offset(200, 160), width: 180, height: 100),
        Paint()..color = const Color(0xFFD2691E));
    // Front legs.
    leg(120, frontRot, const Color(0xFF8B4513));
    leg(160, frontRot2, const Color(0xFFA0522D));
    // Neck, snout, ear, mane, eye.
    final fill = Paint()..color = const Color(0xFFD2691E);
    canvas.drawPath(
        Path()
          ..moveTo(160, 130)
          ..lineTo(100, 40)
          ..lineTo(40, 70)
          ..lineTo(40, 100)
          ..lineTo(120, 180)
          ..close(),
        fill);
    canvas.drawPath(
        Path()
          ..moveTo(60, 60)
          ..lineTo(10, 80)
          ..lineTo(20, 110)
          ..lineTo(60, 100)
          ..close(),
        fill);
    canvas.drawPath(
        Path()
          ..moveTo(90, 35)
          ..lineTo(80, 10)
          ..lineTo(105, 25)
          ..close(),
        fill);
    canvas.drawPath(
        Path()
          ..moveTo(150, 120)
          ..lineTo(100, 20)
          ..lineTo(70, 40)
          ..lineTo(130, 140)
          ..close(),
        Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(const Offset(45, 75), 5, Paint()..color = Colors.black);

    // Thigh muscle glow.
    _paintGlow(canvas, const Offset(240, 150), 40, 30, glow);
  }

  @override
  bool shouldRepaint(covariant _HorseScenePainter old) =>
      old.scale != scale ||
      old.baseY != baseY ||
      old.dx != dx ||
      old.flip != flip ||
      old.active != active ||
      old.glow != glow;
}

/// Scene 1B -- sky, clouds and the flapping bird (SVG viewBox 300x300).
class _BirdScenePainter extends CustomPainter {
  _BirdScenePainter({
    required this.ticker,
    required this.scale,
    required this.cx,
    required this.cy,
    required this.flip,
    required this.active,
    required this.glow,
  }) : super(repaint: ticker);

  final AnimationController ticker;
  final double scale;
  final double cx;
  final double cy;
  final bool flip;
  final bool active;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final t = ticker.value * 10;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DD3FC), Color(0xFFE0F2FE)],
        ).createShader(Offset.zero & size),
    );
    // Soft clouds.
    final cloud = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(Rect.fromLTWH(w * 0.10, h * 0.15, w * 0.22, h * 0.10), cloud);
    canvas.drawOval(Rect.fromLTWH(w * 0.62, h * 0.35, w * 0.28, h * 0.12), cloud);
    canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.58, w * 0.18, h * 0.08), cloud);

    // Idle float: 3 s ease cycle, -15 px at mid.
    final float = -15 * (0.5 - 0.5 * math.cos(2 * math.pi * ((t / 3) % 1)));

    // Flap: 0.3 s cycle.
    double flapBack = _deg(-40), flapFront = _deg(30);
    if (active) {
      final c = 0.5 - 0.5 * math.cos(2 * math.pi * ((t / 0.3) % 1));
      flapBack = _deg(-40 + 70 * c);
      flapFront = _deg(30 - 70 * c);
    } else {
      flapBack = _deg(-10);
      flapFront = _deg(8);
    }

    canvas.save();
    canvas.translate(cx, cy + float * scale);
    if (flip) canvas.scale(-1, 1);
    canvas.scale(scale, scale);
    canvas.translate(-150, -150);

    // Back wing.
    canvas.save();
    canvas.translate(150, 140);
    canvas.rotate(flapBack);
    canvas.translate(-150, -140);
    canvas.drawPath(
        Path()
          ..moveTo(150, 140)
          ..quadraticBezierTo(120, 20, 220, 50)
          ..close(),
        Paint()..color = const Color(0xFF1874CD));
    canvas.restore();

    // Tail.
    canvas.drawPath(
        Path()
          ..moveTo(80, 160)
          ..lineTo(10, 120)
          ..lineTo(30, 190)
          ..close(),
        Paint()..color = const Color(0xFF1E90FF));
    // Body.
    canvas.drawOval(Rect.fromCenter(center: const Offset(150, 160), width: 160, height: 90),
        Paint()..color = const Color(0xFF1E90FF));
    // Chest glow.
    _paintGlow(canvas, const Offset(160, 160), 35, 25, glow);
    // Head + eye + beak.
    canvas.drawCircle(const Offset(210, 140), 35, Paint()..color = const Color(0xFF1E90FF));
    canvas.drawCircle(const Offset(225, 130), 6, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(227, 128), 2, Paint()..color = Colors.white);
    canvas.drawPath(
        Path()
          ..moveTo(240, 140)
          ..lineTo(290, 145)
          ..lineTo(240, 155)
          ..close(),
        Paint()..color = const Color(0xFFFF8C00));
    // Front wing.
    canvas.save();
    canvas.translate(140, 160);
    canvas.rotate(flapFront);
    canvas.translate(-140, -160);
    canvas.drawPath(
        Path()
          ..moveTo(140, 160)
          ..quadraticBezierTo(170, 290, 260, 230)
          ..close(),
        Paint()..color = const Color(0xFF4169E1));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BirdScenePainter old) =>
      old.scale != scale ||
      old.cx != cx ||
      old.cy != cy ||
      old.flip != flip ||
      old.active != active ||
      old.glow != glow;
}

/// Scene 1C -- room, table and aquarium with the main fish + two companions.
class _FishScenePainter extends CustomPainter {
  _FishScenePainter({
    required this.ticker,
    required this.tank,
    required this.fx,
    required this.fy,
    required this.flip,
    required this.active,
    required this.glow,
  }) : super(repaint: ticker);

  final AnimationController ticker;
  final Rect tank;
  final double fx;
  final double fy;
  final bool flip;
  final bool active;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final t = ticker.value * 10;

    // Wall + floor.
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF334155));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.70, w, h * 0.30), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.70, w, 5), Paint()..color = const Color(0xFF475569));
    // Table.
    canvas.drawRect(Rect.fromLTWH(w * 0.14, h * 0.70, w * 0.05, h * 0.30),
        Paint()..color = const Color(0xFF5C4033));
    canvas.drawRect(Rect.fromLTWH(w * 0.81, h * 0.70, w * 0.05, h * 0.30),
        Paint()..color = const Color(0xFF5C4033));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.08, h * 0.66, w * 0.84, h * 0.05), const Radius.circular(6)),
        Paint()..color = const Color(0xFF8B4513));
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.66, w * 0.84, 7),
        Paint()..color = const Color(0xFFA0522D));

    // Tank.
    final glass = RRect.fromRectAndRadius(tank, const Radius.circular(12));
    canvas.drawRRect(glass, Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.25));
    // Sand.
    canvas.save();
    canvas.clipRRect(glass);
    canvas.drawRect(
        Rect.fromLTWH(tank.left, tank.bottom - 34, tank.width, 34),
        Paint()..color = const Color(0xFFF5DEB3));
    canvas.drawRect(
        Rect.fromLTWH(tank.left, tank.bottom - 34, tank.width, 6),
        Paint()..color = const Color(0xFFDEB887));
    // Water sheen.
    canvas.drawRect(
      Rect.fromLTWH(tank.left, tank.top, tank.width, 24),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(tank.left, tank.top, tank.width, 24)),
    );

    // Companion fish (always swishing, to-and-fro on their own clocks).
    _companion(canvas, t, 14, -3, 0.62, 0.22, 0.55,
        const Color(0xFFFF1493), const Color(0xFFFF69B4));
    _companion(canvas, t, 18, -8, 0.22, 0.62, 0.45,
        const Color(0xFFEAB308), const Color(0xFFFDE047));

    // Main fish (viewBox 200x120 -> 160x100).
    final float = -10 * (0.5 - 0.5 * math.cos(2 * math.pi * ((t / 3) % 1)));
    canvas.save();
    canvas.translate(fx, fy + float);
    if (flip) canvas.scale(-1, 1);
    canvas.scale(0.8, 0.8);
    _fishShape(canvas, t,
        swish: active,
        body: const Color(0xFFFF8C00),
        tail: const Color(0xFFFFA500),
        glow: glow);
    canvas.restore();

    canvas.restore(); // tank clip
    // Frame drawn last, over the water.
    canvas.drawRRect(
        glass,
        Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10);
  }

  /// One small companion fish; [durS] to-fro duration, [delayS] phase shift.
  void _companion(Canvas canvas, double t, double durS, double delayS, double ux,
      double uy, double sc, Color body, Color tail) {
    final p = (((t - delayS) / durS) % 1 + 1) % 1;
    double x;
    bool flip;
    final amp = tank.width * 0.24;
    if (p < 0.25) {
      x = p / 0.25;
      flip = false;
    } else if (p < 0.75) {
      x = 1 - (p - 0.25) / 0.25;
      flip = true;
    } else {
      x = -1 + (p - 0.75) / 0.25;
      flip = false;
    }
    canvas.save();
    canvas.translate(tank.left + tank.width * ux + x * amp, tank.top + tank.height * uy);
    if (flip) canvas.scale(-1, 1);
    canvas.scale(sc, sc);
    _fishShape(canvas, t, swish: true, body: body, tail: tail, glow: 0);
    canvas.restore();
  }

  /// The 200x120 fish viewBox centred on its body ellipse (110, 60).
  void _fishShape(Canvas canvas, double t,
      {required bool swish, required Color body, required Color tail, required double glow}) {
    canvas.translate(-110, -60);
    // Tail swish: scaleX 1..0.7 + skewY about (50, 60), 0.3 s cycle.
    final c = swish ? 0.5 - 0.5 * math.cos(2 * math.pi * ((t / 0.3) % 1)) : 0.0;
    canvas.save();
    canvas.translate(50, 60);
    canvas.transform((Matrix4.identity()
          ..setEntry(1, 0, 0.35 * c) // skewY
          ..scaleByDouble(1 - 0.3 * c, 1, 1, 1))
        .storage);
    canvas.translate(-50, -60);
    canvas.drawPath(
        Path()
          ..moveTo(50, 60)
          ..lineTo(0, 20)
          ..lineTo(20, 60)
          ..lineTo(0, 100)
          ..close(),
        Paint()..color = tail);
    canvas.restore();
    canvas.drawOval(Rect.fromCenter(center: const Offset(110, 60), width: 130, height: 80),
        Paint()..color = body);
    _paintGlow(canvas, const Offset(90, 60), 30, 20, glow);
    canvas.drawCircle(const Offset(150, 45), 8, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(153, 42), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _FishScenePainter old) =>
      old.tank != tank ||
      old.fx != fx ||
      old.fy != fy ||
      old.flip != flip ||
      old.active != active ||
      old.glow != glow;
}

/// Scenario 2 background: wall, floor and a full-width wooden table.
class _BoxScenePainter extends CustomPainter {
  _BoxScenePainter({required this.tableTop});

  final double tableTop;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF334155));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, 5), Paint()..color = const Color(0xFF475569));
    // Legs.
    canvas.drawRect(
        Rect.fromLTWH(w * 0.18, tableTop, w * 0.045, h - tableTop), Paint()..color = const Color(0xFF5C4033));
    canvas.drawRect(
        Rect.fromLTWH(w * 0.77, tableTop, w * 0.045, h - tableTop), Paint()..color = const Color(0xFF5C4033));
    // Table top (full width, like the source's scene-2 table).
    canvas.drawRect(Rect.fromLTWH(0, tableTop, w, 26), Paint()..color = const Color(0xFF92400E));
    canvas.drawRect(Rect.fromLTWH(0, tableTop, w, 8), Paint()..color = const Color(0xFFD97706));
  }

  @override
  bool shouldRepaint(covariant _BoxScenePainter old) => old.tableTop != tableTop;
}
