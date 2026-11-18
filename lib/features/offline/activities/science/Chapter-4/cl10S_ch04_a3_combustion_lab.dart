// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 4.3: Carbon Chemical Processing Plant
// Converted from Cl10S-Ch4-A3-CombustionLab.html (React + Tailwind + SVG -> Flutter widgets + CustomPainter).
//
// The source is a 2D DOM lab split into five "zones" of a carbon plant, each with an on-canvas
// control panel, a molecular-view card, an instruction toast and an observation panel that pops up
// after 3 s of idling: combustion (fuel + air hole -> clean blue flame vs sooty yellow flame that
// blackens a metal plate), oxidation of ethanol by alkaline KMnO4 on a heated water bath,
// hydrogenation of oil over a nickel catalyst, substitution of methane by chlorine in sunlight,
// and esterification (plus the bonus sodium test). Here the zone nav sits at the top of the canvas,
// the controls + molecular view in a left column, and each zone's apparatus is painted by its own
// CustomPainter inside a zoom / pan viewport (toolbar: pan mode, label toggle, zoom, reset). One
// mission per zone is ticked off in the sidebar; completing all five raises the completion popup.

// --- TRANSLATION DATA (source `content`; `ui`, `complete` and the substitution mission added) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void toggle() =>
      value = value == _rt_AppLang.en ? _rt_AppLang.hi : _rt_AppLang.en;
}

_rt_AppLanguage get _rt_appLanguage => _rt_AppLanguage.instance;

/// Picks the string for the current language from an `{en, hi}` pair.
String _rt_tr(String en, String hi) => _rt_appLanguage.isHindi ? hi : en;

/// Rebuilds [builder] whenever the language *or* the theme changes.
///
/// Every activity already wraps its `build` in this, so hooking the theme in
/// here is what makes a dark/light toggle reach all of them.
class _rt_LangBuilder extends StatelessWidget {
  const _rt_LangBuilder({required this.builder});

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
}

/// Dark / light appearance, mirroring the `--bg-*` / `--text-*` CSS custom
/// properties every source activity defines. The HTML labs open in dark, so
/// that is the default here too.
enum _rt_LabThemeMode { dark, light }

class _rt_AppTheme extends ValueNotifier<_rt_LabThemeMode> {
  _rt_AppTheme._() : super(_rt_LabThemeMode.dark);

  static final _rt_AppTheme instance = _rt_AppTheme._();

  bool get isDark => value == _rt_LabThemeMode.dark;

  void toggle() =>
      value = isDark ? _rt_LabThemeMode.light : _rt_LabThemeMode.dark;
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
  static Color tintedBorder(Color accent) => _d
      ? accent.withValues(alpha: 0.45)
      : Color.lerp(accent, Colors.white, 0.8)!;

  /// Foreground for text sitting on a [tinted] background.
  static Color onTinted(Color darkAccent, Color lightAccent) =>
      _d ? Color.lerp(darkAccent, Colors.white, 0.45)! : lightAccent;

  /// Shadow strength; dark surfaces need a heavier, flatter shadow.
  static Color get shadow => Colors.black.withValues(alpha: _d ? 0.45 : 0.16);
}

/// Strings used by the shared shell and home screen (not activity content).
class _rt_CommonStrings {
  static String get footer => _rt_tr(
    '© ZeroScienceLab - Fall in love with math and Science',
    '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
  );
  static String get langButton => _rt_tr('EN', 'हि');
  static String get switchLanguage =>
      _rt_tr('Switch to Hindi', 'अंग्रेज़ी में बदलें');
  static String get restart => _rt_tr('Restart', 'पुनः आरंभ');
  static String get done => _rt_tr('Done', 'पूर्ण');
  static String get currentStep => _rt_tr('Current Step', 'वर्तमान चरण');
  static String get zoomIn => _rt_tr('Zoom in', 'ज़ूम इन');
  static String get zoomOut => _rt_tr('Zoom out', 'ज़ूम आउट');
  static String get resetView => _rt_tr('Reset view', 'दृश्य रीसेट करें');
  static String get close => _rt_tr('Close', 'बंद करें');
  static String get enterLab => _rt_tr('Enter Lab', 'लैब में प्रवेश करें');
  static String get continueLabel => _rt_tr('Continue', 'जारी रखें');
  static String get resizeSidebar => _rt_tr(
    'Drag to resize • double-tap to reset',
    'आकार बदलने के लिए खींचें • रीसेट के लिए डबल-टैप',
  );
}

// ---------------------------------------------------------------------------
// Activity sound effects streamed via audioplayers.
enum _rt_Sfx {
  click,
  tap,
  toggle,
  scenario,
  correct,
  wrong,
  success,
  curtain,
  pop,
  magic,
  dropdown,
}

class _rt_SoundService {
  _rt_SoundService._();
  static final _rt_SoundService instance = _rt_SoundService._();
  bool enabled = true;

  // Independent players so different sound categories can overlap.
  AudioPlayer? _click;
  AudioPlayer? _page;
  AudioPlayer? _dropdown;

  // Lazily (re)created so the singleton survives an activity being disposed.
  AudioPlayer get _clickPlayer => _click ??= AudioPlayer();
  AudioPlayer get _pagePlayer => _page ??= AudioPlayer();
  AudioPlayer get _dropdownPlayer => _dropdown ??= AudioPlayer();

  // 1. Play on UI clicks, sliders, and standard button presses
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/science/click.mp3'));
  }

  // 2. Play on success panels, app resets, and phase transitions
  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/science/page_open.mp3'));
  }

  // 3. Play when scrolling through the wheel pickers
  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(AssetSource('audio/science/dropdown.mp3'));
  }

  // 4. Play on calibration mismatch / errors
  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/science/error.mp3'));
  }

  // 5. Play when transitioning from the Curtain Screen or doing Final Submission
  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/science/curtain.mp3'));
  }

  AudioPlayer? _playerFor(_rt_Sfx sfx) => switch (sfx) {
    _rt_Sfx.click ||
    _rt_Sfx.tap ||
    _rt_Sfx.toggle ||
    _rt_Sfx.pop ||
    _rt_Sfx.wrong => _click,
    _rt_Sfx.scenario ||
    _rt_Sfx.correct ||
    _rt_Sfx.success ||
    _rt_Sfx.magic ||
    _rt_Sfx.curtain => _page,
    _rt_Sfx.dropdown => _dropdown,
  };

  // [volume] is accepted for call-site compatibility; the clips play at full volume.
  Future<void> play(_rt_Sfx sfx, {double volume = 1.0}) async {
    if (!enabled) return;
    try {
      await switch (sfx) {
        _rt_Sfx.click ||
        _rt_Sfx.tap ||
        _rt_Sfx.toggle ||
        _rt_Sfx.pop => playClick(),
        _rt_Sfx.scenario ||
        _rt_Sfx.correct ||
        _rt_Sfx.success ||
        _rt_Sfx.magic => playPageOpen(),
        _rt_Sfx.dropdown => playDropdown(),
        _rt_Sfx.wrong => playError(),
        _rt_Sfx.curtain => curtainScreen(),
      };
    } catch (error, stack) {
      // Audio playback may fail; never let that break the lab.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'activity audio',
          context: ErrorDescription('while playing ${sfx.name}'),
        ),
      );
    }
  }

  Future<void> stop(_rt_Sfx sfx) async => _playerFor(sfx)?.stop();
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
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal900 = Color(0xFF134E4A);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue900 = Color(0xFF1E3A8A);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const pink500 = Color(0xFFEC4899);
  static const rose500 = Color(0xFFF43F5E);
  static const red50 = Color(0xFFFEF2F2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red700 = Color(0xFFB91C1C);
  static const orange500 = Color(0xFFF97316);
  static const orange600 = Color(0xFFEA580C);
  static const amber400 = Color(0xFFFBBF24);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green50 = Color(0xFFF0FDF4);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
}

/// Pill action button (the HTML `.action-btn`). Plays a click sound.
class _rt_ActionButton extends StatelessWidget {
  const _rt_ActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.color = _rt_Tw.teal600,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done = false;
  final bool expand = false;
  final _rt_Sfx? sound = _rt_Sfx.click;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !done;
    final bg = done
        ? _rt_Tw.slate400
        : (enabled ? color : color.withValues(alpha: 0.45));
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          done ? Icons.check : (icon ?? Icons.play_arrow),
          size: 14,
          color: Colors.white,
        ),
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
    required this.title,
    required this.desc,
    this.accent = _rt_Tw.teal600,
  });

  final String title;
  final String desc;
  final Color accent;
  final IconData icon = Icons.gps_fixed;
  final Widget? trailing = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.92)!, accent),
        border: Border(bottom: BorderSide(color: _rt_Lab.tintedBorder(accent))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: _rt_Lab.onTinted(
                      accent,
                      Color.lerp(accent, Colors.black, 0.35)!,
                    ),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _rt_Lab.text,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic content card (challenges, explainers, definitions, outcomes).
class _rt_InfoCard extends StatelessWidget {
  const _rt_InfoCard({
    this.title,
    this.body,
    this.color = _rt_Tw.teal600,
    this.icon,
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag = null;
  final Color color;
  final IconData? icon;
  final Widget? child = null;
  final bool leftBorder = false;

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
        boxShadow: leftBorder
            ? [BoxShadow(color: _rt_Lab.shadow, blurRadius: 4)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tag != null)
            Text(
              tag!.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          if (title != null)
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.onTinted(
                        color,
                        Color.lerp(color, Colors.black, 0.35)!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              style: TextStyle(
                fontSize: 12.5,
                color: _rt_Lab.text,
                height: 1.4,
              ),
            ),
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
              child: Text(
                hint!,
                style: TextStyle(
                  fontSize: 11.5,
                  color: _rt_Lab.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          ?child,
        ],
      ),
    );
  }
}

/// Small section heading inside the sidebar.
class _rt_SectionLabel extends StatelessWidget {
  const _rt_SectionLabel(this.text, {this.icon});

  final String text;

  /// Defaults to the theme's muted text colour.
  final Color? color = null;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? _rt_Lab.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: color,
              ),
            ),
          ),
        ],
      ),
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
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.textMuted,
                ),
              ),
            ),
            Text(
              valueText ?? value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
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
            onChangeEnd: onChanged == null
                ? null
                : (_) => _rt_playSfx(_rt_Sfx.tap, volume: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Builds [child] only once the available width reaches [minWidth].
///
/// The app starts in portrait and activity pages switch to landscape in
/// initState, so their first frames are laid out with the portrait width
/// minus the sidebar (about 110 dp on a phone). Wrapping a landscape-only
/// layout in this gate skips those frames instead of overflowing.
class _rt_MinWidthGate extends StatelessWidget {
  const _rt_MinWidthGate({required this.child});

  final double minWidth = 200;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth < minWidth ? const SizedBox.shrink() : child,
  );
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
  const _rt_ShellTab({
    required this.label,
    required this.icon,
    required this.builder,
  });

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
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final IconData buttonIcon = Icons.fingerprint;
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
  const _rt_StepHint({required this.number, required this.text});

  final String number;
  final String text;
  final String? label = null;
}

/// Lets an activity show toasts and popups through the shell.
class _rt_ShellController {
  _ActivityShellState? _state;

  /// Top-right toast (the HTML `showToast`).
  void showToast(
    String message, {
    Color color = _rt_Tw.green500,
    IconData icon = Icons.check,
    int ms = 3000,
  }) {
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
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _rt_Lab.text,
                          ),
                        ),
                        if (widget.message != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: _rt_Lab.textMuted,
                              height: 1.4,
                            ),
                          ),
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
                            children: widget.actions!,
                          )
                        else
                          _rt_ActionButton(
                            label:
                                widget.buttonLabel ?? _rt_CommonStrings.close,
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
    required this.title,
    required this.subtitle,
    required this.tabs,
    required this.canvas,
    required this.onRestart,
    this.controller,
    this.theme = const _rt_ShellTheme(),
    this.intro,
    this.onStart,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.toolbarExtras = const [],
  });

  final String title;
  final String subtitle;
  final List<_rt_ShellTab> tabs;

  /// The activity (usually a Scene3DView). Fills the area right of the
  /// sidebar and resizes responsively when the sidebar opens/closes.
  final Widget canvas;

  /// Extra widgets stacked over the canvas (HUD, legends, overlays). Use
  /// Positioned / Align children.
  final List<Widget> canvasOverlays = const [];

  final VoidCallback onRestart;
  final _rt_ShellController? controller;
  final _rt_ShellTheme theme;
  final _rt_IntroConfig? intro;
  final VoidCallback? onStart;

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final List<Widget> toolbarExtras;

  final _rt_StepHint? hint = null;

  /// Optional content above the tabs (e.g. scenario selector).
  final Widget? sidebarTop = null;
  final Color? canvasBackground = null;

  @override
  State<_rt_ActivityShell> createState() => _ActivityShellState();
}

class _ActivityShellState extends State<_rt_ActivityShell>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  double _sidebarWidth = _rt_rememberedSidebarWidth;
  bool _isResizing = false;
  final GlobalKey _canvasKey = GlobalKey();

  late bool _introVisible = widget.intro != null;
  late final AnimationController _curtain = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final AnimationController _introContent = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

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
    final sidebarWidth = isNarrow
        ? size.width
        : _sidebarWidth.clamp(_rt_kSidebarMinWidth, maxWidth);
    // Follow the finger exactly while dragging; animate only open/close.
    final dur = _isResizing ? Duration.zero : const Duration(milliseconds: 300);
    const curve = Curves.easeOutCubic;

    return _KeyboardLift(
      child: Scaffold(
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
                    side: BorderSide(
                      color: Colors.orange.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),

            if (_introVisible && widget.intro != null)
              _buildIntro(widget.intro!),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ canvas ----
  Widget _buildCanvasArea() {
    final hasToolbar =
        widget.onZoomIn != null ||
        widget.onZoomOut != null ||
        widget.onResetView != null ||
        widget.toolbarExtras.isNotEmpty;
    return Stack(
      key: _canvasKey,
      children: [
        Positioned.fill(child: widget.canvas),
        for (final o in widget.canvasOverlays)
          _rt_movableOverlay(o, _canvasKey),
        if (hasToolbar)
          // Top-right of the canvas, low enough to clear the read-out strips
          // some labs draw across the top.
          // On short landscape phones the strip shrinks to fit the canvas
          // instead of running its last buttons off the bottom edge.
          Positioned(
            top: 68,
            right: 10,
            bottom: 8,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: _buildToolbar(),
            ),
          ),
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
          decoration: BoxDecoration(
            color: _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
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
          if (widget.onZoomIn != null)
            btn(Icons.add, _rt_CommonStrings.zoomIn, widget.onZoomIn),
          if (widget.onZoomOut != null) ...[
            const SizedBox(height: 4),
            btn(Icons.remove, _rt_CommonStrings.zoomOut, widget.onZoomOut),
          ],
          if (widget.onResetView != null) ...[
            _divider(),
            btn(
              Icons.center_focus_strong,
              _rt_CommonStrings.resetView,
              widget.onResetView,
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 24,
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 6),
    color: _rt_Lab.border,
  );

  Widget _buildToast() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _toastColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _toastColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_toastIcon, size: 16, color: _toastColor),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _toast ?? '',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ],
      ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(
                Color.lerp(widget.theme.accent, Colors.white, 0.85)!,
                widget.theme.accent,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: _rt_Lab.tintedBorder(widget.theme.accent),
                width: 2,
              ),
            ),
            child: Text(
              h.number,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: widget.theme.accent,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (h.label ?? _rt_CommonStrings.currentStep).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: widget.theme.accent,
                  ),
                ),
                Text(
                  h.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _rt_Lab.text,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          _sidebarWidth = (_sidebarWidth + d.delta.dx).clamp(
            _rt_kSidebarMinWidth,
            maxWidth,
          );
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
          setState(
            () => _sidebarWidth = _rt_kSidebarDefaultWidth.clamp(
              _rt_kSidebarMinWidth,
              maxWidth,
            ),
          );
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
                color: _isResizing
                    ? widget.theme.accent
                    : _rt_Tw.gray400.withValues(alpha: 0.55),
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
                      border: Border(
                        bottom: BorderSide(color: t.accent, width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: t.headerSubtitleColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  ?widget.sidebarTop,
                  // Active tab body
                  Container(
                    color: _rt_Lab.base,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height * 0.4,
                    ),
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
      color: filled
          ? widget.theme.accent
          : Colors.white.withValues(alpha: 0.12),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
      constraints: BoxConstraints(
        maxWidth: compact ? 420 : 460,
        maxHeight: size.height - 16,
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(compact ? 22 : 30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 50,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 22 : 28,
            vertical: compact ? 14 : 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: -0.1,
                child: Container(
                  width: compact ? 52 : 76,
                  height: compact ? 52 : 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, _rt_Tw.slate800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(compact ? 16 : 22),
                    border: Border.all(
                      color: Colors.white,
                      width: compact ? 3 : 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    intro.icon,
                    color: Colors.white,
                    size: compact ? 28 : 40,
                  ),
                ),
              ),
              SizedBox(height: gap),
              Text(
                intro.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 21 : 26,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                intro.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  color: _rt_Tw.slate500,
                ),
              ),
              SizedBox(height: gap + 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _rt_Tw.slate900,
                    padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _introContent.isAnimating ? null : _start,
                  icon: Icon(intro.buttonIcon, color: _rt_Tw.teal400),
                  label: Text(
                    _rt_CommonStrings.enterLab,
                    style: TextStyle(
                      fontSize: compact ? 15 : 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (intro.footnote != null) ...[
                SizedBox(height: compact ? 8 : 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 12,
                      color: _rt_Tw.slate400,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        intro.footnote!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: _rt_Tw.slate400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Makes a floating canvas card draggable; full-canvas layers stay fixed.
Widget _rt_movableOverlay(Widget overlay, GlobalKey bounds) {
  Widget movable(Widget child) => _rt_Movable(bounds: bounds, child: child);
  if (overlay is Align) {
    return Align(
      key: overlay.key,
      alignment: overlay.alignment,
      child: overlay.child == null ? null : movable(overlay.child!),
    );
  }
  if (overlay is! Positioned) return overlay;
  final p = overlay;
  if (p.left != null && p.right != null && p.top != null && p.bottom != null) {
    return p;
  }
  // Shrink the grab area to the card itself so the rest of the band still
  // reaches the 3D view underneath.
  var alignment = Alignment(
    p.left != null && p.right != null ? 0 : (p.right != null ? 1 : -1),
    p.top != null && p.bottom != null ? 0 : (p.bottom != null ? 1 : -1),
  );
  var child = p.child;
  if (child is Align && child.child != null && child.alignment is Alignment) {
    alignment = child.alignment as Alignment;
    child = child.child!;
  } else if (child is IgnorePointer) {
    final inner = child.child;
    if (inner is Align && inner.child != null && inner.alignment is Alignment) {
      alignment = inner.alignment as Alignment;
      child = IgnorePointer(child: inner.child);
    }
  }
  return Positioned(
    key: p.key,
    left: p.left,
    top: p.top,
    right: p.right,
    bottom: p.bottom,
    width: p.width,
    height: p.height,
    child: Align(alignment: alignment, child: movable(child)),
  );
}

/// Drag wrapper that keeps its card inside [bounds].
class _rt_Movable extends StatefulWidget {
  const _rt_Movable({required this.bounds, required this.child});

  final GlobalKey bounds;
  final Widget child;

  @override
  State<_rt_Movable> createState() => _MovableState();
}

class _MovableState extends State<_rt_Movable> {
  Offset _offset = Offset.zero;

  void _drag(DragUpdateDetails d) {
    var next = _offset + d.delta;
    final box = context.findRenderObject() as RenderBox?;
    final area = widget.bounds.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && area != null && box.hasSize && area.hasSize) {
      // Untranslated origin: the translation applies to children only.
      final origin = box.localToGlobal(Offset.zero, ancestor: area);
      double fit(double v, double lo, double hi) =>
          lo <= hi ? v.clamp(lo, hi) : v.clamp(hi, lo);
      next = Offset(
        fit(next.dx, -origin.dx, area.size.width - box.size.width - origin.dx),
        fit(
          next.dy,
          -origin.dy,
          area.size.height - box.size.height - origin.dy,
        ),
      );
    }
    setState(() => _offset = next);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: _drag,
          child: widget.child,
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

  void _schedule() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

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
      lift = (r.bottom + _buttonRoom - keyboardTop).clamp(
        0.0,
        math.max(0.0, r.top - 8),
      );
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
    return SizedBox.expand(child: CustomPaint(painter: _ShutterPainter()));
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
            colors: [
              _rt_Tw.slate900,
              _rt_Tw.slate800,
              _rt_Tw.slate700,
              _rt_Tw.slate950,
            ],
            stops: [0, 0.48, 0.96, 1],
          ).createShader(band),
      );
    }
    // Side shading.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.4),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'title': 'Carbon Chemical Processing Plant',
    'subtitle': 'Class 10 • Carbon and its Compounds',
    'enterLab': 'Enter _rt_Lab',
    'tabs': {
      'context': 'Why Learn This?',
      'teacher': 'Teacher Guide',
      'explore': 'Mission Log',
      'analysis': 'Outcomes',
    },
    'context': {
      'title': 'Why Learn Carbon Chemistry?',
      'desc':
          'Carbon is the basis of all life and a key element in modern industry. Understanding its reactions is essential for:',
      'cards': [
        {
          'title': 'Energy & Fuels',
          'text':
              'Understanding combustion helps us design cleaner engines and efficient fuels.',
        },
        {
          'title': 'Medicine & Health',
          'text':
              'Organic compounds like ethanoic acid are foundations for pharmaceuticals.',
        },
        {
          'title': 'Industrial Products',
          'text':
              'Soaps, detergents, and perfumes (esters) are all carbon-based innovations.',
        },
      ],
    },
    'teacher': {
      'intro':
          'This simulation allows students to virtually perform hazardous or complex carbon reactions safely.',
      'phases': [
        {
          'title': 'Discovery',
          'text':
              'Start with the Combustion Zone. Ask students to predict what happens when the air hole is closed.',
        },
        {
          'title': 'Interaction',
          'text':
              'Have students manipulate variables (Temperature, Catalysts) to observe chemical changes in real-time.',
        },
        {
          'title': 'Observation',
          'text':
              'Focus on color changes (Oxidation) and physical state changes (Hydrogenation) as key indicators.',
        },
      ],
    },
    'explore': {
      'objective':
          'Master the four major chemical properties of carbon compounds.',
      'steps': [
        {
          'do': 'Combustion: Toggle Air Hole',
          'focus': 'Observe the change in flame color and soot production.',
        },
        {
          'do': 'Oxidation: Add KMnO4 drops',
          'focus':
              'Watch the purple color disappear until the reaction saturates.',
        },
        {
          'do': 'Hydrogenation: Add Catalyst',
          'focus': 'Note the phase change from liquid oil to solid fat.',
        },
        {
          'do': 'Substitution: Open the Sunlight Shutters',
          'focus':
              'Chlorine replaces a hydrogen of methane only when sunlight falls on the jar.',
        },
        {
          'do': 'Esterification: Heat Mixture',
          'focus':
              'Wait for the dehydration process and the fruity scent signal.',
        },
      ],
    },
    'analysis': {
      'columns': ['Key Observations', 'Learning Outcomes'],
      'rows': [
        {
          'obs': 'Blue flame vs Yellow sooty flame',
          'out': 'Complete vs Incomplete combustion.',
        },
        {
          'obs': 'Disappearance of purple color',
          'out': 'Oxidation of Ethanol to Ethanoic Acid.',
        },
        {
          'obs': 'Liquid oil becomes solid',
          'out': 'Addition reaction (Hydrogenation) of unsaturated fats.',
        },
        {
          'obs': 'Reaction only in sunlight',
          'out':
              'Substitution of Hydrogen by Chlorine in saturated hydrocarbons.',
        },
        {
          'obs': 'Sweet fruity smell',
          'out': 'Formation of Ester from Acid + Alcohol.',
        },
      ],
    },
    'zones': {
      'nav': {
        'combustion': 'Combustion Chamber',
        'oxidation': 'Oxidation Tank',
        'hydrogenation': 'Hydrogenation Unit',
        'substitution': 'Substitution Sunroom',
        'ester': 'Ester Perfumery',
      },
      'combustion': {
        'instr_start': 'Start by selecting a Fuel.',
        'instr_clean': 'Observe the Blue Flame. Try closing the Air Hole.',
        'instr_soot':
            'Notice the Yellow Flame and Black Smoke (Soot) coating the plate.',
        'instr_ignite': "Click 'Ignite Burner' to start the reaction.",
        'label_plate': 'Metal Plate (Collecting Soot)',
        'label_air_open': 'Air: Open',
        'label_air_closed': 'Air: Closed',
        'label_burner': 'Bunsen Burner',
        'label_inlet': 'Gas Inlet Tube',
        'label_fuel': 'Fuel',
        'micro_saturated': 'Methane (Saturated)',
        'micro_unsaturated': 'Naphthalene (Unsaturated)',
        'ctrl_title': '⚙️ Burner Control',
        'ctrl_select': '1. Select Fuel',
        'ctrl_air': '2. Air Supply',
        'btn_open': '◎ OPEN (Clean Air)',
        'btn_closed': '⊗ CLOSED (Limited Air)',
        'btn_ignite': 'Ignite Burner',
        'btn_extinguish': 'Extinguish Flame',
        'obs_clean': 'Blue flame produced (Clean Burn).',
        'conc_clean': 'Sufficient oxygen leads to complete combustion.',
        'obs_soot': 'Yellow flame produced with black smoke (Soot).',
        'conc_soot':
            'Limited oxygen leads to incomplete combustion (producing carbon/soot).',
      },
      'oxidation': {
        'instr_heat': 'Set the Water Bath temperature above 60°C.',
        'instr_add': 'Now add KMnO4 drops slowly.',
        'instr_reacting': 'Observe the pink color disappearing.',
        'instr_excess': 'Reaction complete! Color persists.',
        'micro_title': 'Reaction Logic',
        'label_alkaline': 'Alkaline KMnO₄',
        'label_ethanol': 'Ethanol',
        'label_bath': 'Water Bath',
        'label_burner': 'Bunsen Burner',
        'ctrl_title': '⚙️ Oxidation Controls',
        'ctrl_heat': '1. Heat Mixture',
        'btn_add': '💧 Add KMnO₄ Drop',
        'btn_reset': 'Reset',
        'obs_text': 'The purple color of KMnO₄ fades and disappears.',
        'conc_text':
            'KMnO₄ oxidizes Ethanol into Ethanoic Acid. As KMnO₄ loses oxygen, it loses its color.',
      },
      'hydrogenation': {
        'instr_load': 'Load the Nickel Catalyst first.',
        'instr_inject': 'Now Inject Hydrogen Gas.',
        'instr_progress': 'Reaction in progress...',
        'instr_success': 'Success! Liquid Oil became Solid Fat.',
        'micro_title': 'Molecular Change',
        'label_before': 'Before (Oil)',
        'label_after': 'After (Fat)',
        'label_catalyst': 'Ni CATALYST',
        'label_solid': 'Solid (Ghee)',
        'label_liquid': 'Liquid (Oil)',
        'label_reactor': 'Industrial Reactor',
        'label_intake': 'Oil Intake',
        'label_h2inlet': 'H₂ Gas Inlet',
        'label_bed': 'Catalyst Bed',
        'ctrl_title': '⚙️ Reactor Controls',
        'btn_load': 'Load Nickel Catalyst',
        'btn_loaded': 'Catalyst Loaded (Ni)',
        'btn_inject': 'Inject Hydrogen Gas (H₂)',
        'btn_reset': 'Reset System',
        'obs_text': 'Liquid vegetable oil turns into solid fat.',
        'conc_text':
            'Hydrogenation adds hydrogen to double bonds, straightening the molecular chains and causing them to solidify.',
      },
      'substitution': {
        'instr_active': 'UV Active. Chlorine is substituting Hydrogen.',
        'instr_start': 'Open the Sunlight Shutters to start.',
        'label_jar': 'Glass Bell Jar',
        'label_methane': 'Methane (CH₄)',
        'label_chloro': 'Chloromethane',
        'label_cl2': 'Chlorine (Cl₂)',
        'label_hcl': 'HCl Gas',
        'ctrl_title': '⚙️ Light Control',
        'btn_open': '☀️ SHUTTERS OPEN',
        'btn_closed': '🌑 SHUTTERS CLOSED',
        'obs_text': 'Reaction occurs only when sunlight hits the jar.',
        'conc_text':
            'UV light breaks Chlorine bonds, allowing it to substitute Hydrogen in Methane.',
      },
      'ester': {
        'instr_mix': 'Step 1: Mix Acid, Alcohol & H2SO4.',
        'instr_heat': 'Step 2: Heat the mixture to dehydrate it.',
        'instr_dehydrating':
            'Heating... Removing water molecules (Dehydration)...',
        'instr_smell':
            'Smell the sweet fruity ester! Try the Bonus Sodium Test.',
        'instr_pop': 'POP! Hydrogen gas released.',
        'micro_wait': 'Waiting for Reaction...',
        'micro_ester': 'Ethyl Ethanoate (Ester)',
        'micro_h2': 'Hydrogen Gas (H₂)',
        'label_removed': 'H₂O Removed',
        'label_dehydration': 'Dehydration',
        'label_bath': 'Warm Water Bath',
        'label_tube': 'Reaction Tube',
        'label_burner': 'Bunsen Burner',
        'ctrl_title': '⚙️ _rt_Lab Bench',
        'btn_step1': '1. Add Reactants (Acid + Alc + Cat)',
        'btn_step2': '2. Heat Mixture (Dehydration)',
        'btn_bonus': 'Bonus: Sodium Test',
        'btn_reset': 'Reset',
        'obs_pop': "Vigorous bubbling and 'POP' sound.",
        'conc_pop': 'Sodium reacts with alcohol to release Hydrogen gas.',
        'obs_ester': 'A sweet, fruity smell is produced.',
        'conc_ester':
            'Acid and Alcohol undergo dehydration to form an Ester (used in perfumes).',
      },
    },
    'ui': {
      'introFootnote':
          'Combustion • Oxidation • Addition • Substitution • Esterification',
      'objective': 'Objective',
      'focus': 'Focus',
      'keyObs': '📝 Key Observations',
      'observation': 'Observation',
      'conclusion': 'Conclusion',
      'obsLog': 'Observation Log',
      'molecularView': 'Molecular View',
      'microscopicView': 'Microscopic View',
      'panMode': 'Pan Mode',
      'toggleLabels': 'Toggle Labels',
      'missionDone': 'Mission complete: {name}',
      'fuels': {'methane': 'Methane', 'naphthalene': 'Naphthalene'},
      'ethanol': 'Ethanol',
      'ethanoicAcid': 'Ethanoic Acid',
      'acid': 'Acid',
      'alc': 'Alc',
    },
    'complete': {
      'title': 'Plant Fully Operational!',
      'msg':
          'All five units are running. You saw complete vs incomplete combustion, oxidation of ethanol, hydrogenation of oil, substitution in methane and the formation of an ester.',
    },
  },
  'hi': {
    'title': 'कार्बन रासायनिक प्रसंस्करण संयंत्र',
    'subtitle': 'कक्षा 10 • कार्बन और उसके यौगिक',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'tabs': {
      'context': 'यह क्यों सीखें?',
      'teacher': 'शिक्षक गाइड',
      'explore': 'मिशन लॉग',
      'analysis': 'परिणाम',
    },
    'context': {
      'title': 'कार्बन रसायन विज्ञान क्यों सीखें?',
      'desc':
          'कार्बन सभी जीवन का आधार है। इसकी प्रतिक्रियाओं को समझना आवश्यक है:',
      'cards': [
        {
          'title': 'ऊर्जा और ईंधन',
          'text': 'दहन को समझने से हमें स्वच्छ इंजन बनाने में मदद मिलती है।',
        },
        {
          'title': 'चिकित्सा',
          'text': 'एथेनोइक एसिड जैसे कार्बनिक यौगिक दवाओं का आधार हैं।',
        },
        {
          'title': 'औद्योगिक उत्पाद',
          'text': 'साबुन और इत्र (एस्टर) सभी कार्बन-आधारित नवाचार हैं।',
        },
      ],
    },
    'teacher': {
      'intro':
          'यह सिमुलेशन छात्रों को कार्बन प्रतिक्रियाओं को सुरक्षित रूप से करने की अनुमति देता है।',
      'phases': [
        {
          'title': 'खोज',
          'text':
              'दहन क्षेत्र से शुरू करें। छात्रों से पूछें कि वायु छिद्र बंद होने पर क्या होता है।',
        },
        {
          'title': 'बातचीत',
          'text':
              'छात्रों को वास्तविक समय में रासायनिक परिवर्तनों को देखने के लिए चर बदलने दें।',
        },
        {
          'title': 'अवलोकन',
          'text':
              'रंग परिवर्तन (ऑक्सीकरण) और अवस्था परिवर्तन (हाइड्रोजनीकरण) पर ध्यान दें।',
        },
      ],
    },
    'explore': {
      'objective':
          'कार्बन यौगिकों के चार प्रमुख रासायनिक गुणों में महारत हासिल करें।',
      'steps': [
        {
          'do': 'दहन: वायु छिद्र बदलें',
          'focus': 'लौ के रंग और कालिख उत्पादन में परिवर्तन देखें।',
        },
        {
          'do': 'ऑक्सीकरण: KMnO4 डालें',
          'focus': 'बैंगनी रंग के गायब होने का निरीक्षण करें।',
        },
        {
          'do': 'हाइड्रोजनीकरण: उत्प्रेरक जोड़ें',
          'focus': 'तरल तेल से ठोस वसा में परिवर्तन नोट करें।',
        },
        {
          'do': 'प्रतिस्थापन: सूर्य के प्रकाश के शटर खोलें',
          'focus':
              'सूर्य का प्रकाश जार पर पड़ने पर ही क्लोरीन मीथेन के एक हाइड्रोजन को प्रतिस्थापित करता है।',
        },
        {
          'do': 'एस्टरीकरण: मिश्रण को गर्म करें',
          'focus': 'निर्जलीकरण प्रक्रिया और फलों की गंध का इंतजार करें।',
        },
      ],
    },
    'analysis': {
      'columns': ['मुख्य अवलोकन', 'सीखने के परिणाम'],
      'rows': [
        {'obs': 'नीली लौ बनाम पीली लौ', 'out': 'पूर्ण बनाम अपूर्ण दहन।'},
        {
          'obs': 'बैंगनी रंग का गायब होना',
          'out': 'इथेनॉल का एथेनोइक एसिड में ऑक्सीकरण।',
        },
        {
          'obs': 'तरल तेल ठोस हो जाता है',
          'out': 'असंतृप्त वसा की संकलन अभिक्रिया (हाइड्रोजनीकरण)।',
        },
        {
          'obs': 'केवल सूर्य के प्रकाश में प्रतिक्रिया',
          'out':
              'संतृप्त हाइड्रोकार्बन में क्लोरीन द्वारा हाइड्रोजन का प्रतिस्थापन।',
        },
        {
          'obs': 'मीठी फलों की गंध',
          'out': 'एसिड + अल्कोहल से एस्टर का निर्माण।',
        },
      ],
    },
    'zones': {
      'nav': {
        'combustion': 'दहन कक्ष',
        'oxidation': 'ऑक्सीकरण टैंक',
        'hydrogenation': 'हाइड्रोजनीकरण इकाई',
        'substitution': 'प्रतिस्थापन कक्ष',
        'ester': 'एस्टर इत्रशाला',
      },
      'combustion': {
        'instr_start': 'ईंधन चुनकर शुरुआत करें।',
        'instr_clean':
            'नीली लौ का निरीक्षण करें। वायु छिद्र बंद करने का प्रयास करें।',
        'instr_soot': 'प्लेट पर पीली लौ और काला धुआं (कालिख) देखें।',
        'instr_ignite':
            "प्रतिक्रिया शुरू करने के लिए 'बर्नर जलाएं' पर क्लिक करें।",
        'label_plate': 'धातु प्लेट (कालिख संग्रह)',
        'label_air_open': 'वायु: खुली',
        'label_air_closed': 'वायु: बंद',
        'label_burner': 'बुनसेन बर्नर',
        'label_inlet': 'गैस इनलेट ट्यूब',
        'label_fuel': 'ईंधन',
        'micro_saturated': 'मीथेन (संतृप्त)',
        'micro_unsaturated': 'नेफ़थलीन (असंतृप्त)',
        'ctrl_title': '⚙️ बर्नर नियंत्रण',
        'ctrl_select': '1. ईंधन चुनें',
        'ctrl_air': '2. वायु आपूर्ति',
        'btn_open': '◎ खुली (स्वच्छ हवा)',
        'btn_closed': '⊗ बंद (सीमित हवा)',
        'btn_ignite': 'बर्नर जलाएं',
        'btn_extinguish': 'लौ बुझाएं',
        'obs_clean': 'नीली लौ उत्पन्न हुई (स्वच्छ दहन)।',
        'conc_clean': 'पर्याप्त ऑक्सीजन से पूर्ण दहन होता है।',
        'obs_soot': 'काले धुएं (कालिख) के साथ पीली लौ उत्पन्न हुई।',
        'conc_soot':
            'सीमित ऑक्सीजन से अपूर्ण दहन होता है (कार्बन/कालिख का उत्पादन)।',
      },
      'oxidation': {
        'instr_heat': 'जल स्नान का तापमान 60°C से ऊपर सेट करें।',
        'instr_add': 'अब धीरे-धीरे KMnO4 की बूंदें डालें।',
        'instr_reacting': 'गुलाबी रंग गायब होते हुए देखें।',
        'instr_excess': 'प्रतिक्रिया पूर्ण! रंग बना रहता है।',
        'micro_title': 'प्रतिक्रिया तर्क',
        'label_alkaline': 'क्षारीय KMnO₄',
        'label_ethanol': 'इथेनॉल',
        'label_bath': 'जल स्नान',
        'label_burner': 'बुनसेन बर्नर',
        'ctrl_title': '⚙️ ऑक्सीकरण नियंत्रण',
        'ctrl_heat': '1. मिश्रण गर्म करें',
        'btn_add': '💧 KMnO₄ बूंद डालें',
        'btn_reset': 'रीसेट',
        'obs_text': 'KMnO₄ का बैंगनी रंग फीका पड़ जाता है और गायब हो जाता है।',
        'conc_text':
            'KMnO₄ इथेनॉल को एथेनोइक एसिड में ऑक्सीकृत करता है। जैसे ही KMnO₄ ऑक्सीजन खो देता है, यह अपना रंग खो देता है।',
      },
      'hydrogenation': {
        'instr_load': 'पहले निकल उत्प्रेरक लोड करें।',
        'instr_inject': 'अब हाइड्रोजन गैस इंजेक्ट करें।',
        'instr_progress': 'प्रतिक्रिया चल रही है...',
        'instr_success': 'सफलता! तरल तेल ठोस वसा बन गया।',
        'micro_title': 'आणविक परिवर्तन',
        'label_before': 'पहले (तेल)',
        'label_after': 'बाद में (वसा)',
        'label_catalyst': 'Ni उत्प्रेरक',
        'label_solid': 'ठोस (घी)',
        'label_liquid': 'तरल (तेल)',
        'label_reactor': 'औद्योगिक रिएक्टर',
        'label_intake': 'तेल इनलेट',
        'label_h2inlet': 'H₂ गैस इनलेट',
        'label_bed': 'उत्प्रेरक बिस्तर',
        'ctrl_title': '⚙️ रिएक्टर नियंत्रण',
        'btn_load': 'निकल उत्प्रेरक लोड करें',
        'btn_loaded': 'उत्प्रेरक लोडेड (Ni)',
        'btn_inject': 'हाइड्रोजन गैस (H₂) इंजेक्ट करें',
        'btn_reset': 'सिस्टम रीसेट करें',
        'obs_text': 'तरल वनस्पति तेल ठोस वसा में बदल जाता है।',
        'conc_text':
            'हाइड्रोजनीकरण दोहरे बंधों में हाइड्रोजन जोड़ता है, जिससे आणविक श्रृंखलाएं सीधी हो जाती हैं और वे ठोस हो जाती हैं।',
      },
      'substitution': {
        'instr_active':
            'UV सक्रिय। क्लोरीन हाइड्रोजन को प्रतिस्थापित कर रहा है।',
        'instr_start': 'शुरू करने के लिए सूर्य के प्रकाश के शटर खोलें।',
        'label_jar': 'कांच का जार',
        'label_methane': 'मीथेन (CH₄)',
        'label_chloro': 'क्लोरोमीथेन',
        'label_cl2': 'क्लोरीन (Cl₂)',
        'label_hcl': 'HCl गैस',
        'ctrl_title': '⚙️ प्रकाश नियंत्रण',
        'btn_open': '☀️ शटर खुले',
        'btn_closed': '🌑 शटर बंद',
        'obs_text':
            'प्रतिक्रिया केवल तभी होती है जब सूर्य का प्रकाश जार पर पड़ता है।',
        'conc_text':
            'UV प्रकाश क्लोरीन बंधों को तोड़ता है, जिससे यह मीथेन में हाइड्रोजन को प्रतिस्थापित कर सकता है।',
      },
      'ester': {
        'instr_mix': 'चरण 1: एसिड, अल्कोहल और H2SO4 मिलाएं।',
        'instr_heat': 'चरण 2: मिश्रण को निर्जलित करने के लिए गर्म करें।',
        'instr_dehydrating':
            'गर्म हो रहा है... पानी के अणु हट रहे हैं (निर्जलीकरण)...',
        'instr_smell': 'मीठी फलों की गंध सूंघें! बोनस सोडियम टेस्ट आज़माएं।',
        'instr_pop': 'POP! हाइड्रोजन गैस निकली।',
        'micro_wait': 'प्रतिक्रिया की प्रतीक्षा है...',
        'micro_ester': 'एथिल एथेनोएट (एस्टर)',
        'micro_h2': 'हाइड्रोजन गैस (H₂)',
        'label_removed': 'H₂O हटाया गया',
        'label_dehydration': 'निर्जलीकरण',
        'label_bath': 'गर्म जल स्नान',
        'label_tube': 'प्रतिक्रिया ट्यूब',
        'label_burner': 'बुनसेन बर्नर',
        'ctrl_title': '⚙️ लैब बेंच',
        'btn_step1': '1. अभिकारक डालें (एसिड + अल्कोहल + उत्प्रेरक)',
        'btn_step2': '2. मिश्रण गर्म करें (निर्जलीकरण)',
        'btn_bonus': 'बोनस: सोडियम टेस्ट',
        'btn_reset': 'रीसेट',
        'obs_pop': "जोरदार बुलबुले और 'POP' ध्वनि।",
        'conc_pop':
            'सोडियम अल्कोहल के साथ प्रतिक्रिया करके हाइड्रोजन गैस छोड़ता है।',
        'obs_ester': 'एक मीठी, फलों की गंध उत्पन्न होती है।',
        'conc_ester':
            'एसिड और अल्कोहल निर्जलीकरण से गुजरकर एस्टर बनाते हैं (इत्र में उपयोग किया जाता है)।',
      },
    },
    'ui': {
      'introFootnote': 'दहन • ऑक्सीकरण • संकलन • प्रतिस्थापन • एस्टरीकरण',
      'objective': 'उद्देश्य',
      'focus': 'ध्यान दें',
      'keyObs': '📝 मुख्य अवलोकन',
      'observation': 'अवलोकन',
      'conclusion': 'निष्कर्ष',
      'obsLog': 'अवलोकन लॉग',
      'molecularView': 'आणविक दृश्य',
      'microscopicView': 'सूक्ष्म दृश्य',
      'panMode': 'पैन मोड',
      'toggleLabels': 'लेबल दिखाएँ/छिपाएँ',
      'missionDone': 'मिशन पूर्ण: {name}',
      'fuels': {'methane': 'मीथेन', 'naphthalene': 'नेफ़थलीन'},
      'ethanol': 'इथेनॉल',
      'ethanoicAcid': 'एथेनोइक एसिड',
      'acid': 'एसिड',
      'alc': 'अल्कोहल',
    },
    'complete': {
      'title': 'संयंत्र पूरी तरह चालू!',
      'msg':
          'पाँचों इकाइयाँ चल रही हैं। आपने पूर्ण बनाम अपूर्ण दहन, इथेनॉल का ऑक्सीकरण, तेल का हाइड्रोजनीकरण, मीथेन में प्रतिस्थापन और एस्टर का बनना देखा।',
    },
  },
});

/// Source zone ids, in nav order. Mission `i` belongs to zone `i`.
const _zoneIds = [
  'combustion',
  'oxidation',
  'hydrogenation',
  'substitution',
  'ester',
];

/// Source nav emoji 🔥 🧪 🏭 ☀️ 🌹 as Material icons.
const _zoneIcons = [
  Icons.local_fire_department,
  Icons.science,
  Icons.factory,
  Icons.wb_sunny,
  Icons.local_florist,
];
const _zoneTints = [
  _rt_Tw.orange500,
  _rt_Tw.pink500,
  _rt_Tw.slate400,
  _rt_Tw.yellow400,
  _rt_Tw.rose500,
];

/// Source context-card icons (fa-gas-pump, fa-pills, fa-pump-soap).
const _contextIcons = [Icons.local_gas_station, Icons.medication, Icons.soap];

/// Oxidation: drops of KMnO4 the ethanol can decolourise before it saturates.
const _saturation = 6;

class Cl10SCh04A3CombustionLabPage extends StatefulWidget {
  const Cl10SCh04A3CombustionLabPage({super.key});

  @override
  State<Cl10SCh04A3CombustionLabPage> createState() =>
      _Cl10SCh04A3CombustionLabPageState();
}

class _Cl10SCh04A3CombustionLabPageState
    extends State<Cl10SCh04A3CombustionLabPage>
    with SingleTickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _SceneZoom _zoom = _SceneZoom();

  /// Bumped every frame; the scene painters repaint on it.
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  _Anim _anim = _Anim();

  int _zone = 0;
  final List<bool> _missions = List<bool>.filled(5, false);
  bool _completionShown = false;
  Timer? _missionTimer;

  // --- shared view state (source: showLabels / isPanMode / per-zone showObs + Toast) ---
  bool _showLabels = true;
  bool _panMode = false;
  bool _showObs = false;
  bool _started = false;
  String? _bannerClosedFor;
  String? _obsDismissedFor;
  Timer? _idleTimer;

  // --- Zone 1: combustion ---
  String _fuel = 'methane';
  bool _airOpen = true;
  bool _burning = false;
  bool _plateSooty = false;
  bool _sawClean = false; // methane, air open: blue flame
  bool _sawUnsaturated = false; // naphthalene, air open: yellow flame + soot
  bool _sawAirLimited = false; // methane, air closed: yellow flame + soot
  Timer? _sootTimer;

  // --- Zone 2: oxidation ---
  int _drops = 0;
  double _temp = 25;
  double _dropAt = -10;

  // --- Zone 3: hydrogenation ---
  bool _hasNickel = false;
  bool _hasHydrogen = false;
  bool _isReacted = false;
  Timer? _reactTimer;

  // --- Zone 4: substitution ---
  bool _sunlight = false;
  int _subStep = 0;
  Timer? _subTimer;

  // --- Zone 5: esterification ---
  int _esterStep = 0;
  Timer? _esterTimer;

  bool get _isClean => _fuel == 'methane' && _airOpen;
  bool get _heated => _temp > 60;
  bool get _oxReacting => _drops > 0 && _drops < _saturation && _heated;
  bool get _oxExcess => _drops >= _saturation && _heated;
  String get _zoneId => _zoneIds[_zone];

  /// Text of the active zone (`t` in the source's zone components).
  String _z(String key) => _tx.s('zones.$_zoneId.$key');

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cancelZoneTimers();
    _idleTimer?.cancel();
    _missionTimer?.cancel();
    _ticker.dispose();
    _frame.dispose();
    _zoom.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation ---
  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastTick = elapsed;
    _anim.t = elapsed.inMicroseconds / 1e6;
    _stepAnim(dt);
    _frame.value++;
  }

  /// Eases the painted values towards the state, standing in for the source's
  /// CSS transitions (plate colour 1 s, collar 0.5 s, tube level 1 s, ...).
  void _stepAnim(double dt) {
    double k(double tau) => 1 - math.exp(-dt / tau);
    final a = _anim;
    a.soot += ((_plateSooty ? 1 : 0) - a.soot) * k(0.35);
    a.collar += ((_airOpen ? 0 : 1) - a.collar) * k(0.15);
    a.hole += ((_airOpen ? 1 : 0) - a.hole) * k(0.1);
    final level = (20 + math.min(_drops * 5, 70)) / 100;
    a.tubeLevel += (level - a.tubeLevel) * k(0.3);
    final tint = _oxReacting
        ? Colors.white.withValues(alpha: 0.4)
        : (_drops > 0
              ? const Color(0x99FF00FF)
              : Colors.white.withValues(alpha: 0.2));
    a.tubeColor = Color.lerp(a.tubeColor, tint, k(0.3))!;
    a.oxFlame += ((_temp - 20) / 70 - a.oxFlame) * k(0.15);
    a.oil += ((_isReacted ? 1 : 0) - a.oil) * k(0.6);
    a.sun += ((_sunlight ? 1 : 0) - a.sun) * k(0.3);
    a.chlorine += ((_subStep == 1 ? 0 : 1) - a.chlorine) * k(0.3);
    a.esterLiquid += ((_esterStep >= 1 ? 1 : 0) - a.esterLiquid) * k(0.3);
  }

  // ------------------------------------------------- idle observation log ---
  void _onStart() {
    _started = true;
    _bumpIdle();
  }

  /// Source `useIdleTimer(() => setShowObs(true), 3000)`: any interaction
  /// restarts the clock; 3 s of quiet opens the observation panel.
  void _bumpIdle() {
    if (!_started) return;
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 3), () {
      // Touch screens have no mouse-move to keep resetting the clock, so an
      // observation the student closed stays closed until it changes.
      if (!mounted || _showObs || _obsDismissedFor == _obsKey) return;
      _rt_playSfx(_rt_Sfx.pop, volume: 0.5);
      setState(() => _showObs = true);
    });
  }

  // ------------------------------------------------------------ missions ---
  /// Ticks off every mission whose goal is now met. Call inside setState.
  void _checkMissions() {
    final now = [
      // QA C10-4.3-02: the Runbook's three flame tests, saturated fuel,
      // unsaturated fuel and limited air (R:L3157-3182).
      _sawClean && _sawUnsaturated && _sawAirLimited,
      _oxExcess,
      _isReacted,
      _subStep == 1,
      _esterStep == 3,
    ];
    final fresh = <int>[];
    for (var i = 0; i < now.length; i++) {
      if (now[i] && !_missions[i]) {
        _missions[i] = true;
        fresh.add(i);
      }
    }
    if (fresh.isEmpty) return;
    _missionTimer?.cancel();
    if (_missions.every((m) => m) && !_completionShown) {
      _completionShown = true;
      _missionTimer = Timer(const Duration(milliseconds: 1200), _showComplete);
      return;
    }
    final name = _tx.s('zones.nav.${_zoneIds[fresh.last]}');
    _missionTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _rt_playSfx(_rt_Sfx.correct);
      _shell.showToast(
        _tx.s('ui.missionDone').replaceAll('{name}', name),
        icon: Icons.task_alt,
      );
    });
  }

  void _showComplete() {
    if (!mounted) return;
    _shell.showSuccess(
      title: _tx.s('complete.title'),
      message: _tx.s('complete.msg'),
      icon: Icons.factory,
      color: _rt_Tw.blue600,
      body: _outcomesTable(),
    );
  }

  // --------------------------------------------------------------- zones ---
  void _cancelZoneTimers() {
    _sootTimer?.cancel();
    _reactTimer?.cancel();
    _subTimer?.cancel();
    _esterTimer?.cancel();
    _sootTimer = null;
    _reactTimer = null;
    _subTimer = null;
    _esterTimer = null;
  }

  /// Each source zone is its own component, so switching remounts it with
  /// fresh state. Missions are kept.
  void _resetZoneState() {
    _cancelZoneTimers();
    _fuel = 'methane';
    _airOpen = true;
    _burning = false;
    _plateSooty = false;
    _sawClean = false;
    _sawUnsaturated = false;
    _sawAirLimited = false;
    _drops = 0;
    _temp = 25;
    _dropAt = -10;
    _hasNickel = false;
    _hasHydrogen = false;
    _isReacted = false;
    _sunlight = false;
    _subStep = 0;
    _esterStep = 0;
    _anim = _Anim()..t = _anim.t;
  }

  void _setZone(int i) {
    _rt_playSfx(_rt_Sfx.scenario);
    _zoom.reset(); // source: resetView() on every nav click
    if (i == _zone) return;
    setState(() {
      _resetZoneState();
      _zone = i;
      _showObs = false;
      _bannerClosedFor = null;
      _obsDismissedFor = null;
    });
    _bumpIdle();
  }

  void _restart() {
    _missionTimer?.cancel();
    _zoom.reset();
    setState(() {
      _resetZoneState();
      _zone = 0;
      for (var i = 0; i < _missions.length; i++) {
        _missions[i] = false;
      }
      _completionShown = false;
      _showLabels = true;
      _panMode = false;
      _showObs = false;
      _bannerClosedFor = null;
      _obsDismissedFor = null;
    });
    _bumpIdle();
  }

  // ------------------------------------------------ zone 1: combustion ---
  void _selectFuel(String fuel) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _fuel = fuel;
      _syncCombustion();
    });
  }

  void _toggleAir() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _airOpen = !_airOpen;
      _syncCombustion();
    });
  }

  void _toggleBurner() {
    _rt_playSfx(_burning ? _rt_Sfx.click : _rt_Sfx.magic);
    setState(() {
      _burning = !_burning;
      _syncCombustion();
    });
  }

  /// Source effect on [isBurning, isClean]: a sooty flame blackens the plate
  /// after 2 s; a clean flame (or none) shows the clean plate again.
  void _syncCombustion() {
    if (_burning && _isClean) _sawClean = true;
    if (_burning && !_isClean) {
      if (!_plateSooty && _sootTimer == null) {
        _sootTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          _rt_playSfx(_rt_Sfx.pop);
          setState(() {
            _sootTimer = null;
            _plateSooty = true;
            _noteSoot();
            _checkMissions();
          });
        });
      }
      if (_plateSooty) _noteSoot();
    } else {
      _sootTimer?.cancel();
      _sootTimer = null;
      _plateSooty = false;
    }
    _checkMissions();
  }

  /// Records which sooty flame test the blackened plate now shows. A sooty
  /// naphthalene flame with the air closed counts as neither.
  void _noteSoot() {
    if (_fuel == 'naphthalene' && _airOpen) _sawUnsaturated = true;
    if (_fuel == 'methane' && !_airOpen) _sawAirLimited = true;
  }

  // ------------------------------------------------- zone 2: oxidation ---
  void _setTemp(double v) {
    final wasHeated = _heated;
    setState(() {
      _temp = v.roundToDouble();
      _checkMissions();
    });
    // The bath starts bubbling once it passes 60 °C.
    if (!wasHeated && _heated) _rt_playSfx(_rt_Sfx.pop);
  }

  void _addDrop() {
    // A drop into cold ethanol does nothing: the buzz says "heat it first".
    _rt_playSfx(_heated ? _rt_Sfx.pop : _rt_Sfx.wrong);
    setState(() {
      _drops++;
      _dropAt = _anim.t;
      _checkMissions();
    });
  }

  void _resetOxidation() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _drops = 0;
      _temp = 25;
      _dropAt = -10;
    });
  }

  // --------------------------------------------- zone 3: hydrogenation ---
  void _toggleNickel() {
    _rt_playSfx(_hasNickel ? _rt_Sfx.toggle : _rt_Sfx.pop);
    setState(() {
      _hasNickel = !_hasNickel;
      _syncReactor();
    });
  }

  void _injectHydrogen() {
    if (_hasHydrogen) return;
    // Without the nickel bed nothing reacts.
    _rt_playSfx(_hasNickel ? _rt_Sfx.pop : _rt_Sfx.wrong);
    setState(() {
      _hasHydrogen = true;
      _syncReactor();
    });
  }

  /// Source effect on [hasNickel, hasHydrogen]: both present for 2.5 s -> fat.
  void _syncReactor() {
    if (_hasNickel && _hasHydrogen) {
      if (_reactTimer == null && !_isReacted) {
        _reactTimer = Timer(const Duration(milliseconds: 2500), () {
          if (!mounted) return;
          _rt_playSfx(_rt_Sfx.magic);
          setState(() {
            _reactTimer = null;
            _isReacted = true;
            _checkMissions();
          });
        });
      }
    } else {
      _reactTimer?.cancel();
      _reactTimer = null;
    }
  }

  void _resetReactor() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _reactTimer?.cancel();
      _reactTimer = null;
      _hasNickel = false;
      _hasHydrogen = false;
      _isReacted = false;
    });
  }

  // ---------------------------------------------- zone 4: substitution ---
  void _toggleShutters() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _sunlight = !_sunlight;
      _subTimer?.cancel();
      _subTimer = null;
      if (_sunlight) {
        // Source: step 1 one second after the light comes in.
        _subTimer = Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          _rt_playSfx(_rt_Sfx.magic);
          setState(() {
            _subTimer = null;
            _subStep = 1;
            _checkMissions();
          });
        });
      } else {
        _subStep = 0;
      }
    });
  }

  // ----------------------------------------------------- zone 5: ester ---
  void _esterAddReactants() {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _esterStep = 1);
  }

  void _esterHeat() {
    _rt_playSfx(_rt_Sfx.magic);
    _esterTimer?.cancel();
    setState(() => _esterStep = 2);
    _esterTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _rt_playSfx(_rt_Sfx.magic);
      setState(() {
        _esterTimer = null;
        _esterStep = 3;
        _checkMissions();
      });
    });
  }

  /// Source `sodiumTest`: playSound('pop') and jump to the POP step.
  void _sodiumTest() {
    _rt_playSfx(_rt_Sfx.pop);
    _esterTimer?.cancel();
    setState(() {
      _esterTimer = null;
      _esterStep = 4;
    });
  }

  void _esterReset() {
    _rt_playSfx(_rt_Sfx.click);
    _esterTimer?.cancel();
    setState(() {
      _esterTimer = null;
      _esterStep = 0;
    });
  }

  // -------------------------------------------------------- derived text ---
  /// The source Toast message for the active zone.
  String get _instrKey {
    switch (_zone) {
      case 0:
        if (!_burning) return 'instr_ignite';
        return _isClean ? 'instr_clean' : 'instr_soot';
      case 1:
        if (!_heated) return 'instr_heat';
        if (_drops == 0) return 'instr_add';
        return _oxReacting ? 'instr_reacting' : 'instr_excess';
      case 2:
        if (_isReacted) return 'instr_success';
        if (_hasNickel && _hasHydrogen) return 'instr_progress';
        if (_hasNickel) return 'instr_inject';
        // (The source says "in progress" even with no catalyst; ask for it.)
        return 'instr_load';
      case 3:
        return _sunlight ? 'instr_active' : 'instr_start';
      default:
        return switch (_esterStep) {
          1 => 'instr_heat',
          2 => 'instr_dehydrating',
          3 => 'instr_smell',
          4 => 'instr_pop',
          _ => 'instr_mix',
        };
    }
  }

  (String, String) get _observation {
    switch (_zone) {
      case 0:
        return _isClean
            ? (_z('obs_clean'), _z('conc_clean'))
            : (_z('obs_soot'), _z('conc_soot'));
      case 4:
        return _esterStep == 4
            ? (_z('obs_pop'), _z('conc_pop'))
            : (_z('obs_ester'), _z('conc_ester'));
      default:
        return (_z('obs_text'), _z('conc_text'));
    }
  }

  bool get _bannerVisible => _bannerClosedFor != '$_zone.$_instrKey';

  String get _obsKey => '$_zone.${_observation.$1}';

  // ------------------------------------------------------------------ UI ---
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _bumpIdle(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: _rt_LangBuilder(
          builder: (context, lang) {
            return _rt_ActivityShell(
              controller: _shell,
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              theme: const _rt_ShellTheme(
                accent: _rt_Tw.blue600,
                headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
                headerSubtitleColor: Color(0xFF93C5FD),
              ),
              intro: _rt_IntroConfig(
                title: _tx.s('title'),
                subtitle: _tx.s('subtitle'),
                buttonLabel: _tx.s('enterLab'),
                footnote: _tx.s('ui.introFootnote'),
                icon: Icons.science,
              ),
              onStart: _onStart,
              onRestart: _restart,
              onZoomIn: _zoom.zoomIn,
              onZoomOut: _zoom.zoomOut,
              onResetView: _zoom.reset,
              toolbarExtras: [
                _toolToggle(
                  key: const ValueKey('tool-pan'),
                  icon: Icons.pan_tool_outlined,
                  tip: _tx.s('ui.panMode'),
                  on: _panMode,
                  onTap: () => setState(() => _panMode = !_panMode),
                ),
                const SizedBox(height: 4),
                _toolToggle(
                  key: const ValueKey('tool-labels'),
                  icon: Icons.label_outline,
                  tip: _tx.s('ui.toggleLabels'),
                  on: _showLabels,
                  onTap: () => setState(() => _showLabels = !_showLabels),
                ),
              ],
              tabs: [
                _rt_ShellTab(
                  label: _tx.s('tabs.explore'),
                  icon: Icons.checklist,
                  builder: (_) => _sidebar(),
                ),
              ],
              canvas: _rt_MinWidthGate(child: _canvas()), // QA C10-4.3-31
            );
          },
        ),
      ),
    );
  }

  Widget _toolToggle({
    required Key key,
    required IconData icon,
    required String tip,
    required bool on,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        key: key,
        radius: 22,
        onTap: () {
          _rt_playSfx(_rt_Sfx.toggle);
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: on ? _rt_Tw.blue600 : _rt_Lab.surface,
            shape: BoxShape.circle,
            boxShadow: on
                ? [
                    BoxShadow(
                      color: _rt_Tw.blue600.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: on ? Colors.white : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- canvas ---
  static const double _leftWidth = 224;
  static const double _toolbarGutter = 56;

  Widget _canvas() {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _Backdrop(a: _anim, zone: _zone, repaint: _frame),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, c) {
            // Sidebar open on a phone leaves ~340 px for the scene: the
            // observation log then docks under the controls instead of
            // squeezing the apparatus. With the sidebar closed it sits beside
            // the scene.
            final wide = c.maxWidth - _leftWidth - _toolbarGutter >= 540;
            return Column(
              children: [
                _zoneNav(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: _leftWidth,
                        child: _leftColumn(dockObs: !wide),
                      ),
                      // The shell's vertical toolbar floats over the right 56 px.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: _toolbarGutter),
                          child: _sceneArea(sideObs: wide),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Source bottom nav bar (🔥 🧪 🏭 ☀️ 🌹), moved to the top of the canvas.
  /// The side insets sit outside the scroll view so a chip never slides under
  /// the shell's menu or back button.
  Widget _zoneNav() {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _zoneIds.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _zoneChip(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _zoneChip(int i) {
    final on = _zone == i;
    final done = _missions[i];
    return GestureDetector(
      key: ValueKey('zone-$i'),
      onTap: () => _setZone(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.blue600 : _rt_Lab.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? _rt_Tw.blue400 : _rt_Lab.border,
            width: 1.5,
          ),
          boxShadow: on
              ? [
                  BoxShadow(
                    color: _rt_Tw.blue600.withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ]
              : [BoxShadow(color: _rt_Lab.shadow, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              done ? Icons.check_circle : _zoneIcons[i],
              size: 15,
              color: on
                  ? Colors.white
                  : (done ? _rt_Tw.green500 : _zoneTints[i]),
            ),
            const SizedBox(width: 5),
            Text(
              _tx.s('zones.nav.${_zoneIds[i]}'),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: on ? Colors.white : _rt_Lab.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftColumn({required bool dockObs}) {
    final controls = SingleChildScrollView(
      // A fresh scroll position per zone; the top inset keeps the panel clear
      // of the shell's menu button when the sidebar is collapsed.
      key: ValueKey('left-$_zone'),
      padding: const EdgeInsets.fromLTRB(10, 20, 4, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _controls(),
          if (_zone != 3) ...[const SizedBox(height: 10), _microCard()],
        ],
      ),
    );
    if (!dockObs || !_showObs) return controls;
    final (obs, conc) = _observation;
    return LayoutBuilder(
      builder: (context, c) {
        return Column(
          children: [
            Expanded(child: controls),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: c.maxHeight * 0.55),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 4),
                child: _obsPanel(obs, conc),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sceneArea({required bool sideObs}) {
    final scene = Stack(
      children: [
        Positioned.fill(child: _sceneViewport()),
        if (!_showObs) Positioned(right: 4, bottom: 8, child: _obsButton()),
      ],
    );
    final banner = _bannerVisible ? _banner() : const SizedBox(height: 8);
    final column = Column(
      children: [
        banner,
        Expanded(child: scene),
      ],
    );
    if (!sideObs || !_showObs) return column;
    final (obs, conc) = _observation;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: column),
        SizedBox(
          width: 236,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 22, 0, 8),
            child: _obsPanel(obs, conc),
          ),
        ),
      ],
    );
  }

  Widget _sceneViewport() {
    return LayoutBuilder(
      builder: (context, c) {
        _zoom.viewport = c.biggest;
        return ClipRect(
          child: InteractiveViewer(
            transformationController: _zoom.transform,
            minScale: _SceneZoom.minScale,
            maxScale: _SceneZoom.maxScale,
            panEnabled: _panMode,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: SizedBox(
              width: c.maxWidth,
              height: c.maxHeight,
              child: RepaintBoundary(
                child: CustomPaint(
                  key: ValueKey('scene-$_zone'),
                  painter: _scenePainter(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  CustomPainter _scenePainter() {
    final a = _anim;
    final l = _showLabels;
    switch (_zone) {
      case 0:
        return _CombustionScene(
          a: a,
          labels: l,
          repaint: _frame,
          burning: _burning,
          clean: _isClean,
          texts: {
            'plate': _z('label_plate'),
            'air': _z(_airOpen ? 'label_air_open' : 'label_air_closed'),
            'burner': _z('label_burner'),
            'inlet': _z('label_inlet'),
            'fuel': '${_z('label_fuel')}: ${_tx.s('ui.fuels.$_fuel')}',
          },
        );
      case 1:
        return _OxidationScene(
          a: a,
          labels: l,
          repaint: _frame,
          heated: _heated,
          reacting: _oxReacting,
          dropAt: _dropAt,
          texts: {
            'alkaline': _z('label_alkaline'),
            'ethanol': _z('label_ethanol'),
            'bath': '${_z('label_bath')}: ${_temp.round()}°C',
            'burner': _z('label_burner'),
          },
        );
      case 2:
        return _HydrogenationScene(
          a: a,
          labels: l,
          repaint: _frame,
          nickel: _hasNickel,
          hydrogen: _hasHydrogen,
          reacted: _isReacted,
          texts: {
            'reactor': _z('label_reactor'),
            'intake': _z('label_intake'),
            'h2inlet': _z('label_h2inlet'),
            'bed': _z('label_bed'),
            'catalyst': _z('label_catalyst'),
            'state': _z(_isReacted ? 'label_solid' : 'label_liquid'),
          },
        );
      case 3:
        return _SubstitutionScene(
          a: a,
          labels: l,
          repaint: _frame,
          step: _subStep,
          texts: {
            'jar': _z('label_jar'),
            'molecule': _z(_subStep == 0 ? 'label_methane' : 'label_chloro'),
            'cl2': _z('label_cl2'),
            'hcl': _z('label_hcl'),
          },
        );
      default:
        return _EsterScene(
          a: a,
          labels: l,
          repaint: _frame,
          step: _esterStep,
          texts: {
            'removed': _z('label_removed'),
            'dehydration': _z('label_dehydration'),
            'bath': _z('label_bath'),
            'tube': _z('label_tube'),
            'burner': _z('label_burner'),
            'acid': _tx.s('ui.acid'),
            'alc': _tx.s('ui.alc'),
          },
        );
    }
  }

  Widget _closeButton(String key, VoidCallback onTap) {
    return InkResponse(
      key: ValueKey(key),
      radius: 16,
      onTap: () {
        _rt_playSfx(_rt_Sfx.tap);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.close, size: 15, color: _rt_Lab.textMuted),
      ),
    );
  }

  /// The source `<Toast>`: current instruction with a dismiss button; a new
  /// message brings it back.
  Widget _banner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      child: Container(
        key: const ValueKey('instruction'),
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: const Border(
            left: BorderSide(color: _rt_Tw.blue500, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _rt_Lab.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, size: 18, color: _rt_Tw.amber400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _z(_instrKey),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.text,
                  height: 1.25,
                ),
              ),
            ),
            _closeButton('close-banner', () {
              setState(() => _bannerClosedFor = '$_zone.$_instrKey');
            }),
          ],
        ),
      ),
    );
  }

  /// The source ObservationPanel ("📝 Key Observations").
  Widget _obsPanel(String obs, String conc) {
    final strong = TextStyle(fontWeight: FontWeight.w900, color: _rt_Lab.text);
    return Container(
      key: const ValueKey('obs-panel'),
      margin: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('ui.keyObs'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.text,
                  ),
                ),
              ),
              _closeButton('close-obs', () {
                setState(() {
                  _showObs = false;
                  _obsDismissedFor = _obsKey;
                });
              }),
            ],
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${_tx.s('ui.observation')}: ', style: strong),
                TextSpan(text: obs),
              ],
            ),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${_tx.s('ui.conclusion')}: ', style: strong),
                TextSpan(text: conc),
              ],
            ),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Source 📝 button that reopens the observation log.
  Widget _obsButton() {
    return Tooltip(
      message: _tx.s('ui.obsLog'),
      child: InkResponse(
        key: const ValueKey('open-obs'),
        radius: 24,
        onTap: () {
          _rt_playSfx(_rt_Sfx.tap);
          setState(() => _showObs = true);
        },
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _rt_Tw.slate800,
            shape: BoxShape.circle,
            border: Border.all(color: _rt_Lab.borderStrong),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
          ),
          child: const Icon(Icons.edit_note, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // ------------------------------------------------------ control panels ---
  Widget _panel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.text,
            ),
          ),
          Container(
            height: 1,
            color: _rt_Lab.border,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.textMuted,
      ),
    ),
  );

  Widget _gap([double h = 8]) => SizedBox(height: h);

  Widget _controls() {
    switch (_zone) {
      case 0:
        return _panel(
          title: _z('ctrl_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fieldLabel(_z('ctrl_select')),
              Row(
                children: [
                  Expanded(child: _fuelChoice('methane', _rt_Tw.blue600)),
                  const SizedBox(width: 6),
                  Expanded(child: _fuelChoice('naphthalene', _rt_Tw.orange600)),
                ],
              ),
              _gap(10),
              _fieldLabel(_z('ctrl_air')),
              _airButton(),
              _gap(10),
              _PanelButton(
                key: const ValueKey('burner-btn'),
                label: _z(_burning ? 'btn_extinguish' : 'btn_ignite'),
                icon: _burning
                    ? Icons.fire_extinguisher
                    : Icons.local_fire_department,
                color: _burning ? _rt_Tw.red500 : _rt_Tw.blue600,
                onTap: _toggleBurner,
              ),
            ],
          ),
        );
      case 1:
        return _panel(
          title: _z('ctrl_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_LabeledSlider(
                key: const ValueKey('heat-slider'),
                label: _z('ctrl_heat'),
                value: _temp,
                min: 20,
                max: 90,
                divisions: 70,
                valueText: '${_temp.round()}°C',
                color: _rt_Tw.orange500,
                onChanged: _setTemp,
              ),
              _gap(6),
              _PanelButton(
                key: const ValueKey('add-drop'),
                label: _z('btn_add'),
                color: const Color(0xFFDB2777),
                onTap: _addDrop,
              ),
              _gap(),
              _PanelButton(
                key: const ValueKey('ox-reset'),
                label: _z('btn_reset'),
                icon: Icons.refresh,
                color: _rt_Tw.slate500,
                onTap: _resetOxidation,
              ),
            ],
          ),
        );
      case 2:
        return _panel(
          title: _z('ctrl_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelButton(
                key: const ValueKey('load-ni'),
                label: _z(_hasNickel ? 'btn_loaded' : 'btn_load'),
                icon: _hasNickel ? Icons.check_circle : Icons.grid_on,
                color: _hasNickel ? _rt_Tw.green600 : _rt_Tw.slate500,
                onTap: _toggleNickel,
              ),
              _gap(),
              _PanelButton(
                key: const ValueKey('inject-h2'),
                label: _z('btn_inject'),
                icon: Icons.bubble_chart,
                color: _rt_Tw.blue600,
                onTap: _hasHydrogen ? null : _injectHydrogen,
              ),
              _gap(),
              _PanelButton(
                key: const ValueKey('reactor-reset'),
                label: _z('btn_reset'),
                icon: Icons.refresh,
                color: _rt_Tw.gray500,
                onTap: _resetReactor,
              ),
            ],
          ),
        );
      case 3:
        return _panel(
          title: _z('ctrl_title'),
          child: _PanelButton(
            key: const ValueKey('shutters'),
            label: _z(_sunlight ? 'btn_open' : 'btn_closed'),
            color: _sunlight ? _rt_Tw.yellow500 : _rt_Tw.slate700,
            textColor: _sunlight ? const Color(0xFF713F12) : Colors.white,
            big: true,
            onTap: _toggleShutters,
          ),
        );
      default:
        return _panel(
          title: _z('ctrl_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelButton(
                key: const ValueKey('ester-step1'),
                label: _z('btn_step1'),
                color: _rt_Tw.blue600,
                onTap: _esterStep > 0 ? null : _esterAddReactants,
              ),
              _gap(),
              _PanelButton(
                key: const ValueKey('ester-step2'),
                label: _z('btn_step2'),
                color: _rt_Tw.orange600,
                onTap: _esterStep != 1 ? null : _esterHeat,
              ),
              _gap(),
              _PanelButton(
                key: const ValueKey('ester-bonus'),
                label: _z('btn_bonus'),
                icon: Icons.bolt,
                color: _rt_Tw.slate500,
                onTap: (_esterStep == 0 || _esterStep == 3)
                    ? _sodiumTest
                    : null,
              ),
              _gap(),
              _PanelButton(
                key: const ValueKey('ester-reset'),
                label: _z('btn_reset'),
                icon: Icons.refresh,
                color: _rt_Tw.gray500,
                onTap: _esterReset,
              ),
            ],
          ),
        );
    }
  }

  Widget _fuelChoice(String id, Color color) {
    final on = _fuel == id;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: on ? color : _rt_Lab.border),
    );
    return Material(
      key: ValueKey('fuel-$id'),
      color: on ? color : _rt_Lab.overlay,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: () => _selectFuel(id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            _tx.s('ui.fuels.$id'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: on ? Colors.white : _rt_Lab.text,
            ),
          ),
        ),
      ),
    );
  }

  /// Source air-hole toggle: green outline when open, red when closed.
  Widget _airButton() {
    final open = _airOpen;
    final accent = open ? _rt_Tw.green500 : _rt_Tw.red500;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: accent, width: 2),
    );
    return Material(
      key: const ValueKey('air-toggle'),
      color: _rt_Lab.tinted(open ? _rt_Tw.green50 : _rt_Tw.red50, accent),
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: _toggleAir,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          child: Text(
            _z(open ? 'btn_open' : 'btn_closed'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.onTinted(
                open ? _rt_Tw.green400 : _rt_Tw.red400,
                open ? _rt_Tw.green700 : _rt_Tw.red700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------- micro views ---
  Widget _molecule(String type, double w, double h) => CustomPaint(
    size: Size(w, h),
    painter: _MoleculePainter(type, _anim, _frame),
  );

  Widget _formulaBox(String name, String formula) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.text,
            ),
          ),
          Text(
            formula,
            style: TextStyle(fontSize: 11.5, color: _rt_Lab.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _microCaption(String text, Color color, [double size = 11.5]) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: color),
  );

  /// The source MicroscopicCard for the active zone.
  Widget _microCard() {
    final String title;
    final Widget body;
    switch (_zone) {
      case 0:
        title = _tx.s('ui.molecularView');
        body = Column(
          children: [
            _molecule(_fuel, 100, 100),
            _gap(4),
            _microCaption(
              _z(_fuel == 'methane' ? 'micro_saturated' : 'micro_unsaturated'),
              _rt_Lab.text,
              12,
            ),
          ],
        );
      case 1:
        title = _z('micro_title');
        body = Column(
          children: [
            _formulaBox(_tx.s('ui.ethanol'), 'CH₃CH₂OH'),
            _microCaption(
              '↓ + [O]',
              _rt_Lab.onTinted(_rt_Tw.pink500, _rt_Tw.pink500),
              18,
            ),
            _formulaBox(_tx.s('ui.ethanoicAcid'), 'CH₃COOH'),
          ],
        );
      case 2:
        title = _z('micro_title');
        body = Column(
          children: [
            _microCaption(_z('label_before'), _rt_Lab.textMuted, 10.5),
            _molecule('oil', 130, 64),
            _microCaption(
              '↓ + H₂ / Ni',
              _rt_Lab.onTinted(_rt_Tw.blue500, _rt_Tw.blue600),
              16,
            ),
            _molecule('fat', 130, 64),
            _microCaption(_z('label_after'), _rt_Lab.textMuted, 10.5),
          ],
        );
      default:
        title = _tx.s('ui.microscopicView');
        body = switch (_esterStep) {
          3 => Column(
            children: [
              _molecule('ester', 120, 72),
              _microCaption(
                _z('micro_ester'),
                _rt_Lab.onTinted(_rt_Tw.purple500, _rt_Tw.purple600),
              ),
            ],
          ),
          4 => Column(
            children: [
              _molecule('hydrogen', 120, 72),
              _microCaption(
                _z('micro_h2'),
                _rt_Lab.onTinted(_rt_Tw.green500, _rt_Tw.green600),
              ),
            ],
          ),
          _ => Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: _microCaption(_z('micro_wait'), _rt_Lab.textFaint, 12),
          ),
        };
    }
    return Container(
      key: const ValueKey('micro-card'),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: _rt_Lab.textMuted,
            ),
          ),
          _gap(6),
          body,
        ],
      ),
    );
  }

  // ------------------------------------------------------------- sidebar ---
  /// The source's four drawer tabs (Mission Log, Outcomes, Why Learn This?,
  /// Teacher Guide) stacked in the one tab the shell shows.
  Widget _sidebar() {
    final cards = _tx.list('context.cards');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('ui.objective'),
          desc: _tx.s('explore.objective'),
          accent: _rt_Tw.blue600,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.checklist),
              for (var i = 0; i < _zoneIds.length; i++) _missionRow(i),
              _gap(12),
              _rt_SectionLabel(_tx.s('tabs.analysis'), icon: Icons.science),
              _outcomesTable(),
              _gap(14),
              _rt_SectionLabel(_tx.s('tabs.context'), icon: Icons.menu_book),
              _rt_InfoCard(
                title: _tx.s('context.title'),
                body: _tx.s('context.desc'),
                color: _rt_Tw.blue500,
                icon: Icons.lightbulb_outline,
              ),
              for (var i = 0; i < cards.length; i++)
                _contextCard(i, cards[i] as Map),
              _gap(10),
              _rt_SectionLabel(_tx.s('tabs.teacher'), icon: Icons.school),
              _rt_InfoCard(
                body: _tx.s('teacher.intro'),
                color: _rt_Tw.purple500,
              ),
              _teacherPhases(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _missionRow(int i) {
    final step = _tx.list('explore.steps')[i] as Map;
    final done = _missions[i];
    final active = _zone == i;
    final accent = done
        ? _rt_Tw.green500
        : (active ? _rt_Tw.blue500 : _rt_Lab.border);
    return GestureDetector(
      key: ValueKey('mission-$i'),
      onTap: () => _setZone(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        decoration: BoxDecoration(
          color: done
              ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
              : (active
                    ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue600)
                    : _rt_Lab.surface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent, width: active ? 2 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? _rt_Tw.green600
                    : (active ? _rt_Tw.blue600 : _rt_Lab.overlay),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: active ? Colors.white : _rt_Lab.textMuted,
                      ),
                    ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['do'] as String,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${_tx.s('ui.focus').toUpperCase()}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _rt_Lab.onTinted(
                              _rt_Tw.yellow500,
                              _rt_Tw.amber700,
                            ),
                          ),
                        ),
                        TextSpan(text: step['focus'] as String),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: _rt_Lab.textMuted,
                      height: 1.3,
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

  /// Source "Outcomes" table; rows light up as their mission is finished.
  Widget _outcomesTable() {
    final cols = _tx.list('analysis.columns');
    final rows = _tx.list('analysis.rows');
    final head = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w900,
      color: _rt_Lab.textMuted,
    );
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Expanded(child: Text(cols[0] as String, style: head)),
                const SizedBox(width: 8),
                Expanded(child: Text(cols[1] as String, style: head)),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              decoration: BoxDecoration(
                color: _missions[i]
                    ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
                    : null,
                border: Border(top: BorderSide(color: _rt_Lab.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      (rows[i] as Map)['obs'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _rt_Lab.text,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (rows[i] as Map)['out'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _contextCard(int i, Map card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_contextIcons[i], size: 22, color: _rt_Tw.blue400),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['title'] as String,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card['text'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: _rt_Lab.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherPhases() {
    final phases = _tx.list('teacher.phases');
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 2),
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _rt_Lab.border, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final p in phases)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ((p as Map)['title'] as String).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: _rt_Lab.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p['text'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
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

// ======================================================================
// Helpers private to this page.
// ======================================================================

/// Source `<Button>` look (not upper-cased, so KMnO₄ / H₂ stay correct).
/// Sounds are played by the handlers, which know what the press means.
class _PanelButton extends StatelessWidget {
  const _PanelButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.textColor = Colors.white,
    this.big = false,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color textColor;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    final fg = on ? textColor : _rt_Tw.slate400;
    return Material(
      color: on ? color : _rt_Tw.slate600,
      borderRadius: BorderRadius.circular(10),
      elevation: on ? 2 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: big ? 14 : 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: big ? 18 : 15, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: big ? 14 : 12,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    height: 1.2,
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

/// Zoom / pan for the scene viewport. Like the source's `scale(zoom)` with
/// `transform-origin: center`, toolbar zoom keeps the viewport centre fixed.
class _SceneZoom {
  static const minScale = 0.5;
  static const maxScale = 2.0;
  static const step = 0.1;

  final TransformationController transform = TransformationController();
  Size viewport = Size.zero;

  double get scale => transform.value.getMaxScaleOnAxis();

  void _zoomTo(double target) {
    final t = target.clamp(minScale, maxScale);
    final k = t / scale;
    if ((k - 1).abs() < 1e-6) return;
    final c = viewport.center(Offset.zero);
    final m = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(k, k, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
    transform.value = m.multiplied(transform.value);
  }

  void zoomIn() => _zoomTo(scale + step);
  void zoomOut() => _zoomTo(scale - step);
  void reset() => transform.value = Matrix4.identity();
  void dispose() => transform.dispose();
}

/// Painted values that ease towards the state every frame.
class _Anim {
  double t = 0;
  double soot = 0;
  double collar = 0;
  double hole = 1;
  double tubeLevel = 0.2;
  Color tubeColor = Colors.white.withValues(alpha: 0.2);
  double oxFlame = 5 / 70;
  double oil = 0;
  double sun = 0;
  double chlorine = 1;
  double esterLiquid = 0;
}

// ---------------------------------------------------------------- painting ---
enum _TagStyle { card, light, plain }

class _Tag {
  const _Tag(
    this.text,
    this.at,
    this.align,
    this.style,
    this.color,
    this.size,
    this.mono,
  );

  final String text;
  final Offset at;
  final Alignment align;
  final _TagStyle style;
  final Color? color;
  final double size;
  final bool mono;
}

/// Base for the zone scenes: apparatus is drawn in a fixed design space that
/// is scaled to fit; labels are drawn afterwards at a readable fixed size and
/// kept inside the viewport.
abstract class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.a,
    required this.labels,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _Anim a;
  final bool labels;
  final List<_Tag> _tags = [];

  Size get design;
  void paintScene(Canvas c);

  /// The source `<Label>` callout: hidden when labels are toggled off.
  void label(String text, Offset at, [Alignment align = Alignment.center]) {
    if (labels) {
      _tags.add(_Tag(text, at, align, _TagStyle.card, null, 10, false));
    }
  }

  /// Always-visible text (source spans that are not `<Label>`s).
  void caption(
    String text,
    Offset at, {
    Alignment align = Alignment.center,
    _TagStyle style = _TagStyle.plain,
    Color? color,
    double size = 10,
    bool mono = false,
  }) {
    _tags.add(_Tag(text, at, align, style, color, size, mono));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final d = design;
    final s = math.min(size.width / d.width, size.height / d.height);
    final ox = (size.width - d.width * s) / 2;
    final oy = (size.height - d.height * s) / 2;
    _tags.clear();
    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(s);
    paintScene(canvas);
    canvas.restore();
    // Labels keep a readable size but shrink a little on a small scene so
    // they crowd the apparatus less.
    final f = (s / 0.7).clamp(0.85, 1.05).toDouble();
    for (final t in _tags) {
      _paintTag(canvas, size, t, Offset(ox + t.at.dx * s, oy + t.at.dy * s), f);
    }
  }

  void _paintTag(Canvas c, Size bounds, _Tag t, Offset at, double f) {
    final color =
        t.color ??
        (t.style == _TagStyle.light ? _rt_Tw.slate900 : _rt_Lab.text);
    final tp = TextPainter(
      text: TextSpan(
        text: t.text,
        style: TextStyle(
          fontSize: t.size * f,
          fontWeight: FontWeight.w800,
          color: color,
          fontFamily: t.mono ? 'monospace' : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final plain = t.style == _TagStyle.plain;
    final padX = plain ? 0.0 : 6.0;
    final padY = plain ? 0.0 : 3.0;
    final w = tp.width + padX * 2;
    final h = tp.height + padY * 2;
    final left = (at.dx - (t.align.x + 1) / 2 * w)
        .clamp(2.0, math.max(2.0, bounds.width - w - 2))
        .toDouble();
    final top = (at.dy - (t.align.y + 1) / 2 * h)
        .clamp(2.0, math.max(2.0, bounds.height - h - 2))
        .toDouble();
    if (!plain) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, h),
        const Radius.circular(5),
      );
      c.drawRRect(
        rr.shift(const Offset(0, 1.5)),
        Paint()..color = Colors.black.withValues(alpha: 0.28),
      );
      c.drawRRect(
        rr,
        Paint()
          ..color = t.style == _TagStyle.light
              ? Colors.white.withValues(alpha: 0.88)
              : _rt_Lab.surface.withValues(alpha: 0.94),
      );
      c.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = t.style == _TagStyle.light
              ? _rt_Tw.slate300
              : _rt_Lab.borderStrong,
      );
    }
    tp.paint(c, Offset(left + padX, top + padY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- shared apparatus -------------------------------------------------------

void _text(
  Canvas c,
  String s,
  Offset center,
  double size,
  Color color, [
  FontWeight weight = FontWeight.w800,
]) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(fontSize: size, fontWeight: weight, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

/// _rt_Lab bench the apparatus stands on.
void _bench(Canvas c, double y) {
  final r = Rect.fromLTRB(-2000, y, 2400, y + 16);
  c.drawRect(
    r,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF475569), Color(0xFF1E293B)],
      ).createShader(r),
  );
  c.drawLine(
    Offset(-2000, y),
    Offset(2400, y),
    Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.5,
  );
}

/// Source `.flame-blue` / `.flame-yellow`: egg-shaped gradient with a glow,
/// flickering in height, skew and opacity.
void _flame(
  Canvas c,
  Offset base,
  double w,
  double h, {
  required bool blue,
  required double t,
  double opacity = 1,
  double blur = 0,
}) {
  final sy = 1 + 0.07 * math.sin(t * 29) + 0.03 * math.sin(t * 47);
  final skew = 0.035 * math.sin(t * 37);
  final op = (opacity * (0.9 + 0.1 * math.sin(t * 23))).clamp(0.0, 1.0);
  c.save();
  c.translate(base.dx, base.dy);
  c.skew(skew, 0);
  c.scale(1, sy);
  final r = RRect.fromLTRBAndCorners(
    -w / 2,
    -h,
    w / 2,
    0,
    topLeft: Radius.elliptical(w / 2, h * 0.6),
    topRight: Radius.elliptical(w / 2, h * 0.6),
    bottomLeft: Radius.elliptical(w / 2, h * 0.4),
    bottomRight: Radius.elliptical(w / 2, h * 0.4),
  );
  final glow = blue ? const Color(0xFF00FFFF) : const Color(0xFFFF4500);
  c.drawRRect(
    r,
    Paint()
      ..color = glow.withValues(alpha: 0.5 * op)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blue ? 10 : 13),
  );
  final colors = blue
      ? [
          const Color(0xFF0055FF),
          const Color(0xFF00FFFF),
          Colors.white.withValues(alpha: 0.8),
        ]
      : [
          const Color(0xFFFF4500),
          const Color(0xFFFFFF00),
          Colors.white.withValues(alpha: 0.6),
        ];
  final paint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [for (final col in colors) col.withValues(alpha: col.a * op)],
    ).createShader(r.outerRect);
  if (blur > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
  c.drawRRect(r, paint);
  c.restore();
}

/// Bunsen burner: gas inlet, chimney with the air-hole collar, heavy base.
void _burner(
  Canvas c, {
  required double cx,
  required double top,
  required double chimneyW,
  required double chimneyH,
  required double baseW,
  required double baseH,
  double holeDark = 1,
  double collarTurn = 0,
}) {
  final chimBottom = top + chimneyH;
  final baseBottom = chimBottom + baseH;
  // Gas inlet tube (yellow rubber), behind the base.
  final y0 = baseBottom - baseH * 0.72;
  final y1 = y0 + baseH * 0.5;
  final x1 = cx - baseW * 0.1;
  final x0 = x1 - baseW * 0.85;
  final sk = (y1 - y0) * 0.21;
  final tube = Path()
    ..moveTo(x0 + sk, y0)
    ..lineTo(x1 + sk, y0)
    ..lineTo(x1, y1)
    ..lineTo(x0, y1)
    ..close();
  c.drawPath(tube, Paint()..color = const Color(0xFFCA8A04));
  c.drawPath(
    tube,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF854D0E),
  );
  // Chimney.
  final chim = Rect.fromLTRB(
    cx - chimneyW / 2,
    top,
    cx + chimneyW / 2,
    chimBottom,
  );
  c.drawRect(
    chim,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD1D5DB), Color(0xFFF3F4F6), Color(0xFFD1D5DB)],
      ).createShader(chim),
  );
  final side = Paint()
    ..color = const Color(0xFF9CA3AF)
    ..strokeWidth = 1.2;
  c.drawLine(chim.topLeft, chim.bottomLeft, side);
  c.drawLine(chim.topRight, chim.bottomRight, side);
  // Air-hole collar (turns 45° when closed, like the source).
  final collarH = chimneyW * 0.75;
  final cc = Offset(cx, chimBottom - chimneyW * 0.35 - collarH / 2);
  c.save();
  c.translate(cc.dx, cc.dy);
  c.rotate(collarTurn * math.pi / 4);
  final collar = Rect.fromCenter(
    center: Offset.zero,
    width: chimneyW,
    height: collarH,
  );
  c.drawRect(collar, Paint()..color = const Color(0xFF9CA3AF));
  final edge = Paint()
    ..color = const Color(0xFF6B7280)
    ..strokeWidth = 1.2;
  c.drawLine(collar.topLeft, collar.topRight, edge);
  c.drawLine(collar.bottomLeft, collar.bottomRight, edge);
  c.restore();
  c.drawCircle(
    cc,
    chimneyW * 0.2,
    Paint()
      ..color = Color.lerp(
        const Color(0xFF9CA3AF),
        const Color(0xFF1E293B),
        holeDark,
      )!,
  );
  c.drawCircle(
    cc,
    chimneyW * 0.2,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF4B5563),
  );
  // Base.
  final base = RRect.fromLTRBAndCorners(
    cx - baseW / 2,
    chimBottom,
    cx + baseW / 2,
    baseBottom,
    topLeft: const Radius.circular(8),
    topRight: const Radius.circular(8),
  );
  c.drawRRect(base, Paint()..color = const Color(0xFF374151));
  c.drawLine(
    Offset(cx - baseW / 2 + 6, chimBottom + 0.5),
    Offset(cx + baseW / 2 - 6, chimBottom + 0.5),
    Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 1.5,
  );
}

/// Tripod stand with wire gauze (source `TripodStand`).
void _tripod(
  Canvas c, {
  required double cx,
  required double top,
  required double bottom,
  required double width,
}) {
  final leg = Paint()
    ..color = const Color(0xFF6B7280)
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round;
  c.drawLine(
    Offset(cx - width * 0.38, top + 8),
    Offset(cx - width * 0.52, bottom - 3),
    leg,
  );
  c.drawLine(
    Offset(cx + width * 0.38, top + 8),
    Offset(cx + width * 0.52, bottom - 3),
    leg,
  );
  final ring = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(cx, top + 8),
      width: width * 0.86,
      height: 10,
    ),
    const Radius.circular(5),
  );
  c.drawRRect(ring, Paint()..color = const Color(0xFF6B7280));
  final g = Rect.fromCenter(
    center: Offset(cx, top + 4),
    width: width,
    height: 9,
  );
  const sk = 4.0;
  final gauze = Path()
    ..moveTo(g.left + sk, g.top)
    ..lineTo(g.right + sk, g.top)
    ..lineTo(g.right - sk, g.bottom)
    ..lineTo(g.left - sk, g.bottom)
    ..close();
  c.drawPath(
    gauze,
    Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.9),
  );
  c.save();
  c.clipPath(gauze);
  final dot = Paint()..color = const Color(0xFF334155);
  for (var x = g.left - sk; x < g.right + sk; x += 4) {
    for (var y = g.top + 2; y < g.bottom; y += 4) {
      c.drawCircle(Offset(x, y), 0.8, dot);
    }
  }
  c.restore();
  c.drawPath(
    gauze,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF64748B),
  );
}

/// Test tube with a liquid column filling [level] of its height.
void _tube(
  Canvas c,
  Rect r, {
  double level = 0,
  Color? liquid,
  double pulse = 0,
}) {
  final rr = RRect.fromRectAndCorners(
    r,
    bottomLeft: Radius.circular(r.width / 2),
    bottomRight: Radius.circular(r.width / 2),
  );
  c.drawRRect(rr, Paint()..color = Colors.white.withValues(alpha: 0.08));
  if (level > 0.001 && liquid != null) {
    c.save();
    c.clipRRect(rr);
    final lr = Rect.fromLTRB(
      r.left,
      r.bottom - r.height * level,
      r.right,
      r.bottom,
    );
    c.drawRect(lr, Paint()..color = liquid);
    if (pulse > 0) {
      c.drawRect(lr, Paint()..color = Colors.white.withValues(alpha: pulse));
    }
    c.drawLine(
      lr.topLeft,
      lr.topRight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.5,
    );
    c.restore();
  }
  c.drawLine(
    Offset(r.left + r.width * 0.22, r.top + 8),
    Offset(r.left + r.width * 0.22, r.bottom - r.width * 0.6),
    Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round,
  );
  c.drawRRect(
    rr,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85),
  );
  c.drawLine(
    Offset(r.left - 3, r.top),
    Offset(r.right + 3, r.top),
    Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round,
  );
}

RRect _bathShape(Rect r, double rad) => RRect.fromRectAndCorners(
  r,
  bottomLeft: Radius.circular(rad),
  bottomRight: Radius.circular(rad),
);

/// Water bath, back half: the water the tube stands in.
void _bathBack(
  Canvas c,
  Rect r,
  double rad,
  Color water, {
  double waterTop = 16,
}) {
  final shape = _bathShape(r, rad);
  c.drawRRect(shape, Paint()..color = Colors.white.withValues(alpha: 0.04));
  c.save();
  c.clipRRect(shape);
  final w = Rect.fromLTRB(r.left, r.top + waterTop, r.right, r.bottom);
  c.drawRect(w, Paint()..color = water);
  c.drawLine(
    w.topLeft,
    w.topRight,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5,
  );
  c.restore();
}

/// Water bath, front half: glass tint and the open-topped rim.
void _bathFront(Canvas c, Rect r, double rad, Color border) {
  c.drawRRect(
    _bathShape(r, rad),
    Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.06),
  );
  final u = Path()
    ..moveTo(r.left, r.top)
    ..lineTo(r.left, r.bottom - rad)
    ..quadraticBezierTo(r.left, r.bottom, r.left + rad, r.bottom)
    ..lineTo(r.right - rad, r.bottom)
    ..quadraticBezierTo(r.right, r.bottom, r.right, r.bottom - rad)
    ..lineTo(r.right, r.top);
  c.drawPath(
    u,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..color = border,
  );
}

/// Rising bath bubbles (source `.bubble`, 1 s loop with random delays).
void _bubbles(
  Canvas c,
  _Anim a,
  Rect area,
  int n,
  int seed, {
  double rise = 50,
  double r = 3,
}) {
  final rnd = math.Random(seed);
  for (var i = 0; i < n; i++) {
    final x = area.left + rnd.nextDouble() * area.width;
    final delay = rnd.nextDouble();
    final p = (a.t + delay) % 1;
    final op = p < 0.5 ? p * 2 : (1 - p) * 2;
    c.drawCircle(
      Offset(x, area.bottom - rise * p),
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.8 * op),
    );
  }
}

/// Source `<Dropper>`: red bulb, glass barrel (here holding KMnO₄), tip.
void _dropper(Canvas c, double cx, double top) {
  final barrel = Rect.fromLTWH(cx - 6, top + 24, 12, 72);
  c.drawRect(
    barrel,
    Paint()..color = const Color(0xFFEFF6FF).withValues(alpha: 0.3),
  );
  c.drawRect(
    Rect.fromLTRB(
      barrel.left + 1,
      barrel.top + 30,
      barrel.right - 1,
      barrel.bottom,
    ),
    Paint()..color = const Color(0xFFC026D3).withValues(alpha: 0.7),
  );
  final side = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..strokeWidth = 1;
  c.drawLine(barrel.topLeft, barrel.bottomLeft, side);
  c.drawLine(barrel.topRight, barrel.bottomRight, side);
  final tip = Path()
    ..moveTo(cx - 6, top + 96)
    ..lineTo(cx + 6, top + 96)
    ..lineTo(cx, top + 108)
    ..close();
  c.drawPath(
    tip,
    Paint()..color = const Color(0xFFC026D3).withValues(alpha: 0.6),
  );
  c.drawPath(
    tip,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.4),
  );
  final bulb = RRect.fromRectAndCorners(
    Rect.fromLTWH(cx - 12, top, 24, 30),
    topLeft: const Radius.circular(12),
    topRight: const Radius.circular(12),
    bottomLeft: const Radius.circular(6),
    bottomRight: const Radius.circular(6),
  );
  c.drawRRect(bulb, Paint()..color = const Color(0xFFDC2626));
  c.drawRRect(
    bulb,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF991B1B),
  );
}

void _clAtom(Canvas c, Offset p, double r, [double op = 1]) {
  c.drawCircle(
    p,
    r,
    Paint()..color = const Color(0xFF22C55E).withValues(alpha: op),
  );
  c.drawCircle(
    p,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF15803D).withValues(alpha: op),
  );
  _text(c, 'Cl', p, r * 0.75, Colors.white.withValues(alpha: op));
}

// --- molecules (source `Molecule2D` SVGs, recoloured for the dark theme) -----
const _kBond = Color(0xFFCBD5E1);
const _kCarbon = Color(0xFF475569);
const _kCarbonRim = Color(0xFFE2E8F0);
const _kHydrogen = Color(0xFFF8FAFC);
const _kHydrogenRim = Color(0xFF64748B);

/// Draws [type] in its SVG viewBox units (100×100, or 120×60 / 100×60).
void _drawMolecule(Canvas c, String type, {Color bond = _kBond}) {
  void line(double x1, double y1, double x2, double y2, double w) => c.drawLine(
    Offset(x1, y1),
    Offset(x2, y2),
    Paint()
      ..color = bond
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round,
  );
  void atom(
    double x,
    double y,
    double r,
    Color fill,
    Color rim, [
    double sw = 1,
  ]) {
    c.drawCircle(Offset(x, y), r, Paint()..color = fill);
    c.drawCircle(
      Offset(x, y),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..color = rim,
    );
  }

  void carbon(double x, double y, double r) =>
      atom(x, y, r, _kCarbon, _kCarbonRim, 1.2);
  void hydrogen(double x, double y, [double r = 8]) =>
      atom(x, y, r, _kHydrogen, _kHydrogenRim);
  const oxygen = Color(0xFFEF4444);
  const oxygenRim = Color(0xFF991B1B);

  switch (type) {
    case 'methane':
    case 'chloromethane':
      line(50, 35, 50, 28, 4);
      line(59, 59, 74, 74, 4);
      line(41, 59, 26, 74, 4);
      line(40, 40, 25, 33, 4);
      carbon(50, 50, 15);
      if (type == 'methane') {
        hydrogen(50, 20);
      } else {
        atom(50, 20, 10, const Color(0xFF22C55E), const Color(0xFF15803D), 2);
      }
      hydrogen(80, 80);
      hydrogen(20, 80);
      hydrogen(20, 30);
    case 'naphthalene':
      final ring = Path()
        ..moveTo(30, 40)
        ..lineTo(50, 30)
        ..lineTo(70, 40)
        ..lineTo(70, 60)
        ..lineTo(50, 70)
        ..lineTo(30, 60)
        ..close();
      c.drawPath(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = bond,
      );
      for (var y = 30.0; y < 70; y += 8) {
        line(50, y, 50, y + 4, 1);
      }
      for (final p in const [
        (30.0, 40.0),
        (50.0, 30.0),
        (70.0, 40.0),
        (70.0, 60.0),
        (50.0, 70.0),
        (30.0, 60.0),
      ]) {
        carbon(p.$1, p.$2, 6);
      }
    case 'oil':
      final chain = Path()
        ..moveTo(10, 30)
        ..quadraticBezierTo(30, 10, 50, 30)
        ..quadraticBezierTo(70, 50, 90, 30);
      c.drawPath(
        chain,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = bond,
      );
      line(45, 25, 55, 35, 2);
    case 'fat':
      line(10, 30, 110, 30, 4);
      line(40, 30, 40, 24, 2);
      line(60, 30, 60, 36, 2);
      hydrogen(40, 20, 4);
      hydrogen(60, 40, 4);
    case 'ester':
      final carbonPaint = Paint()..color = _kCarbon;
      final rim = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _kCarbonRim;
      for (final x in const [20.0, 60.0]) {
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 25, 20, 10),
          const Radius.circular(2),
        );
        c.drawRRect(r, carbonPaint);
        c.drawRRect(r, rim);
      }
      atom(50, 30, 8, oxygen, oxygenRim);
      atom(30, 15, 8, oxygen, oxygenRim);
      line(30, 25, 30, 15, 3);
    case 'hydrogen':
      atom(35, 30, 15, _kHydrogen, const Color(0xFF334155), 2);
      atom(65, 30, 15, _kHydrogen, const Color(0xFF334155), 2);
      _text(c, 'H-H', const Offset(50, 53), 12, bond);
  }
}

class _MoleculePainter extends CustomPainter {
  _MoleculePainter(this.type, this.a, Listenable repaint)
    : super(repaint: repaint);

  final String type;
  final _Anim a;

  @override
  void paint(Canvas canvas, Size size) {
    final vb = switch (type) {
      'oil' || 'fat' => const Size(120, 60),
      'ester' || 'hydrogen' => const Size(100, 60),
      _ => const Size(100, 100),
    };
    final s = math.min(size.width / vb.width, size.height / vb.height);
    // Source `.floating`: 5 px bob over 3 s.
    final bob = -5 * (0.5 - 0.5 * math.cos(a.t * 2 * math.pi / 3));
    canvas.save();
    canvas.translate(
      (size.width - vb.width * s) / 2,
      (size.height - vb.height * s) / 2 + bob,
    );
    canvas.scale(s);
    _drawMolecule(canvas, type);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter old) => old.type != type;
}

/// Canvas backdrop: dark lab with a soft spotlight; the substitution sunroom
/// floods with sunlight (source bg-slate-900 -> bg-yellow-50 + sun glow).
class _Backdrop extends CustomPainter {
  _Backdrop({required this.a, required this.zone, required Listenable repaint})
    : super(repaint: repaint);

  final _Anim a;
  final int zone;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ).createShader(r),
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.3, 0.05),
          radius: 0.75,
          colors: [
            const Color(0xFF64748B).withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(r),
    );
    if (zone == 3 && a.sun > 0.01) {
      final sun = a.sun.clamp(0.0, 1.0);
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: sun),
              const Color(0xFFFEFCE8).withValues(alpha: sun),
            ],
          ).createShader(r),
      );
      canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(1.0, -1.0),
            radius: 0.7,
            colors: [
              const Color(0xFFFACC15).withValues(alpha: 0.85 * sun),
              const Color(0xFFFACC15).withValues(alpha: 0),
            ],
          ).createShader(r),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Backdrop old) => old.zone != zone || old.a != a;
}

// --- zone scenes --------------------------------------------------------------

/// Zone 1: metal plate over a Bunsen burner; sooty flames blacken the plate.
class _CombustionScene extends _ScenePainter {
  _CombustionScene({
    required super.a,
    required super.labels,
    required super.repaint,
    required this.burning,
    required this.clean,
    required this.texts,
  });

  final bool burning;
  final bool clean;
  final Map<String, String> texts;

  @override
  Size get design => const Size(380, 446);

  @override
  void paintScene(Canvas c) {
    const cx = 190.0;
    _bench(c, 420);

    // Soot particles rise from the flame and pass behind the plate.
    if (burning && !clean) {
      final rnd = math.Random(42);
      for (var i = 0; i < 30; i++) {
        final x0 = cx + (rnd.nextDouble() - 0.5) * 76;
        final y0 = 150 + rnd.nextDouble() * 100;
        final d = 8 + rnd.nextDouble() * 8;
        final delay = rnd.nextDouble();
        final p = ((a.t + delay) % 2) / 2;
        final (dx, sc, op) = p < 0.5
            ? (20 * p, 1 + 0.4 * p, 0.8 - 0.4 * p)
            : (
                10 - 40 * (p - 0.5),
                1.2 + 0.6 * (p - 0.5),
                0.6 * (1 - (p - 0.5) * 2),
              );
        c.drawCircle(
          Offset(x0 + dx, y0 - 110 * p),
          d / 2 * sc,
          Paint()
            ..color = const Color(0xFF0A0A0A).withValues(alpha: op)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
        );
      }
    }

    // Metal plate collecting soot.
    final plate = Rect.fromCenter(
      center: const Offset(cx, 56),
      width: 256,
      height: 24,
    );
    final rr = RRect.fromRectAndRadius(plate, const Radius.circular(4));
    const zinc = Color(0xFF18181B);
    c.drawRRect(
      rr.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    c.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFE5E7EB), zinc, a.soot)!,
            Color.lerp(const Color(0xFF9CA3AF), zinc, a.soot)!,
          ],
        ).createShader(plate),
    );
    if (a.soot < 0.98) {
      c.save();
      c.clipRRect(rr);
      final shine = Path()
        ..moveTo(plate.left + 96, plate.top)
        ..lineTo(plate.left + 150, plate.top)
        ..lineTo(plate.left + 144, plate.bottom)
        ..lineTo(plate.left + 90, plate.bottom)
        ..close();
      c.drawPath(
        shine,
        Paint()..color = Colors.white.withValues(alpha: 0.3 * (1 - a.soot)),
      );
      c.restore();
    }
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF6B7280),
    );

    // Flame first: the chimney top covers its base (source mb-[-10px]).
    if (burning) _flame(c, const Offset(cx, 244), 38, 112, blue: clean, t: a.t);
    _burner(
      c,
      cx: cx,
      top: 232,
      chimneyW: 46,
      chimneyH: 152,
      baseW: 150,
      baseH: 36,
      holeDark: a.hole,
      collarTurn: a.collar,
    );

    label(texts['plate']!, const Offset(cx, 26));
    label(texts['air']!, const Offset(cx + 38, 346), Alignment.centerLeft);
    label(texts['burner']!, const Offset(cx, 402));
    label(texts['fuel']!, const Offset(160, 362), Alignment.bottomRight);
    label(texts['inlet']!, const Offset(80, 436));
  }
}

/// Zone 2: KMnO₄ dropper over ethanol in a tube, standing in a water bath on
/// a tripod over a burner whose flame follows the temperature slider.
class _OxidationScene extends _ScenePainter {
  _OxidationScene({
    required super.a,
    required super.labels,
    required super.repaint,
    required this.heated,
    required this.reacting,
    required this.dropAt,
    required this.texts,
  });

  final bool heated;
  final bool reacting;
  final double dropAt;
  final Map<String, String> texts;

  @override
  Size get design => const Size(380, 486);

  @override
  void paintScene(Canvas c) {
    const cx = 190.0;
    _bench(c, 470);
    _tripod(c, cx: cx, top: 316, bottom: 470, width: 150);
    // Source flame physics: height and opacity scale with (temp - 20) / 70.
    final fl = a.oxFlame.clamp(0.0, 1.0);
    _flame(
      c,
      const Offset(cx, 384),
      24 * (1 + fl * 0.5),
      math.max(8.0, fl * 64),
      blue: true,
      t: a.t,
      opacity: math.max(0.2, fl),
      blur: 2,
    );
    _burner(
      c,
      cx: cx,
      top: 380,
      chimneyW: 30,
      chimneyH: 66,
      baseW: 100,
      baseH: 24,
    );

    final bath = const Rect.fromLTRB(100, 196, 280, 316);
    _bathBack(
      c,
      bath,
      24,
      const Color(0xFF93C5FD).withValues(alpha: 0.22),
      waterTop: 18,
    );
    if (heated) _bubbles(c, a, const Rect.fromLTRB(108, 250, 272, 312), 10, 11);
    _tube(
      c,
      const Rect.fromLTWH(168, 140, 44, 170),
      level: a.tubeLevel,
      liquid: a.tubeColor,
      pulse: reacting ? 0.1 + 0.1 * math.sin(a.t * 4) : 0,
    );
    _bathFront(c, bath, 24, const Color(0xFF3B82F6).withValues(alpha: 0.4));

    _dropper(c, cx, 0);
    // Source keyframes dropFallToTube: dropper tip -> tube mouth, then dissolve.
    final p = a.t - dropAt;
    if (p >= 0 && p < 1) {
      final y = p < 0.8 ? 104 + 46 * p / 0.8 : 150 + 12 * (p - 0.8) / 0.2;
      final op = p < 0.8 ? 1.0 : 1 - (p - 0.8) / 0.2;
      final sc = p < 0.8 ? 1 - 0.1 * p / 0.8 : 0.9 - 0.4 * (p - 0.8) / 0.2;
      c.drawCircle(
        Offset(cx, y),
        6 * sc,
        Paint()
          ..color = const Color(
            0xFFDB2777,
          ).withValues(alpha: op.clamp(0.0, 1.0)),
      );
    }

    label(texts['alkaline']!, const Offset(cx - 18, 16), Alignment.centerRight);
    label(texts['ethanol']!, const Offset(220, 162), Alignment.centerLeft);
    label(texts['bath']!, const Offset(286, 214), Alignment.centerLeft);
    label(texts['burner']!, const Offset(cx, 458));
  }
}

/// Zone 3: steel reactor with a sight glass onto oil -> fat over a Ni bed.
class _HydrogenationScene extends _ScenePainter {
  _HydrogenationScene({
    required super.a,
    required super.labels,
    required super.repaint,
    required this.nickel,
    required this.hydrogen,
    required this.reacted,
    required this.texts,
  });

  final bool nickel;
  final bool hydrogen;
  final bool reacted;
  final Map<String, String> texts;

  @override
  Size get design => const Size(420, 462);

  @override
  void paintScene(Canvas c) {
    const cx = 280.0;
    _bench(c, 446);
    // Feed pipes on the left.
    final pipe = Paint()..color = const Color(0xFF64748B);
    final flange = Paint()..color = const Color(0xFF475569);
    for (final y in const [96.0, 184.0]) {
      c.drawRect(Rect.fromLTWH(108, y, 56, 16), pipe);
      c.drawRect(Rect.fromLTWH(104, y - 4, 7, 24), flange);
    }
    // Body with domed caps.
    const body = Rect.fromLTRB(160, 56, 400, 416);
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF94A3B8), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
        ).createShader(body),
    );
    final edge = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2;
    c.drawLine(body.topLeft, body.bottomLeft, edge);
    c.drawLine(body.topRight, body.bottomRight, edge);
    for (final y in const [108.0, 372.0]) {
      c.drawRect(
        Rect.fromLTWH(body.left, y, body.width, 5),
        Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.55),
      );
    }
    final dome = Paint()..color = const Color(0xFF64748B);
    c.drawRRect(
      RRect.fromLTRBAndCorners(
        160,
        28,
        400,
        72,
        topLeft: const Radius.elliptical(120, 30),
        topRight: const Radius.elliptical(120, 30),
      ),
      dome,
    );
    c.drawRRect(
      RRect.fromLTRBAndCorners(
        160,
        400,
        400,
        444,
        bottomLeft: const Radius.elliptical(120, 30),
        bottomRight: const Radius.elliptical(120, 30),
      ),
      dome,
    );

    // Sight glass.
    const wc = Offset(cx, 200);
    const wr = 73.0;
    c.drawCircle(wc, 80, Paint()..color = const Color(0xFFCBD5E1));
    c.drawCircle(wc, wr, Paint()..color = const Color(0xFF1E293B));
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: wc, radius: wr)));
    c.drawRect(
      Rect.fromCircle(center: wc, radius: wr),
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFEF08A).withValues(alpha: 0.8),
          Colors.white,
          a.oil,
        )!,
    );
    if (nickel) {
      c.drawRect(
        Rect.fromLTRB(wc.dx - wr, wc.dy + wr - 30, wc.dx + wr, wc.dy + wr),
        Paint()..color = const Color(0xFF4B5563),
      );
    }
    if (hydrogen && !reacted) {
      // Source: 12 pinging H₂ dots.
      final rnd = math.Random(5);
      for (var i = 0; i < 12; i++) {
        final x = wc.dx - wr + (0.1 + rnd.nextDouble() * 0.8) * wr * 2;
        final y = wc.dy - wr + (0.1 + rnd.nextDouble() * 0.8) * wr * 2;
        final dur = 1 + rnd.nextDouble();
        final p = (a.t / dur + rnd.nextDouble()) % 1;
        c.drawCircle(
          Offset(x, y),
          4 * (1 + p),
          Paint()
            ..color = const Color(0xFF3B82F6).withValues(alpha: 0.75 * (1 - p)),
        );
      }
    }
    c.restore();
    c.drawArc(
      Rect.fromCircle(center: wc, radius: 62),
      -2.6,
      0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    c.drawCircle(
      wc,
      76.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF94A3B8),
    );

    if (nickel) {
      caption(
        texts['catalyst']!,
        Offset(wc.dx, wc.dy + wr - 15),
        color: Colors.white,
        size: 8,
        mono: true,
      );
    }
    caption(texts['state']!, wc, style: _TagStyle.light, size: 10);
    label(texts['reactor']!, const Offset(cx, 12));
    label(texts['intake']!, const Offset(100, 104), Alignment.centerRight);
    if (hydrogen) {
      label(texts['h2inlet']!, const Offset(100, 192), Alignment.centerRight);
    }
    if (nickel) label(texts['bed']!, const Offset(cx, 336));
  }
}

/// Zone 4: bell jar of CH₄ + Cl₂; sunlight swaps in CH₃Cl + HCl.
class _SubstitutionScene extends _ScenePainter {
  _SubstitutionScene({
    required super.a,
    required super.labels,
    required super.repaint,
    required this.step,
    required this.texts,
  });

  final int step;
  final Map<String, String> texts;

  @override
  Size get design => const Size(440, 392);

  @override
  void paintScene(Canvas c) {
    const cx = 220.0;
    final sun = a.sun.clamp(0.0, 1.0);
    final ink = Color.lerp(
      const Color(0xFFE2E8F0),
      const Color(0xFF1E293B),
      sun,
    )!;
    _text(
      c,
      step == 0 ? 'CH₄ + Cl₂' : 'CH₃Cl + HCl',
      const Offset(cx, 26),
      34,
      ink,
    );

    // Glass bell jar.
    final jar = Path()
      ..moveTo(70, 368)
      ..lineTo(70, 220)
      ..arcToPoint(const Offset(370, 220), radius: const Radius.circular(150))
      ..lineTo(370, 368)
      ..quadraticBezierTo(370, 380, 358, 380)
      ..lineTo(82, 380)
      ..quadraticBezierTo(70, 380, 70, 368)
      ..close();
    c.drawPath(jar, Paint()..color = Colors.white.withValues(alpha: 0.05));
    c.drawPath(
      jar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Color.lerp(
          Colors.white.withValues(alpha: 0.25),
          const Color(0xFF64748B).withValues(alpha: 0.5),
          sun,
        )!,
    );
    c.save();
    c.translate(318, 170);
    c.rotate(0.21);
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 44, height: 110),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    c.restore();

    // Methane / chloromethane, scaled up 1.5x and floating.
    final bond = Color.lerp(_kBond, const Color(0xFF334155), sun)!;
    final bob = -5 * (0.5 - 0.5 * math.cos(a.t * 2 * math.pi / 3));
    c.save();
    c.translate(cx - 75, 190 + bob);
    c.scale(1.5);
    _drawMolecule(c, step == 0 ? 'methane' : 'chloromethane', bond: bond);
    c.restore();

    // Cl₂ drifts away (fade + scale + slide) once it has reacted.
    final cl = a.chlorine.clamp(0.0, 1.0);
    if (cl > 0.02) {
      c.save();
      c.translate(300 + 80 * (1 - cl), 136);
      c.scale(1 + 0.5 * (1 - cl));
      c.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 18, height: 4),
        Paint()..color = const Color(0xFF15803D).withValues(alpha: cl),
      );
      _clAtom(c, const Offset(-24, 0), 16, cl);
      _clAtom(c, const Offset(24, 0), 16, cl);
      c.restore();
      if (cl > 0.5) label(texts['cl2']!, const Offset(300, 170));
    }
    if (step == 1) {
      final b = -8 * math.sin(a.t * math.pi).abs();
      c.save();
      c.translate(292, 136 + b);
      c.drawCircle(const Offset(-18, 0), 12, Paint()..color = Colors.white);
      c.drawCircle(
        const Offset(-18, 0),
        12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF9CA3AF),
      );
      _text(c, 'H', const Offset(-18, 0), 10, _rt_Tw.slate900);
      _clAtom(c, const Offset(12, 0), 16);
      c.restore();
      caption(
        texts['hcl']!,
        Offset(292, 166 + b),
        color: Color.lerp(_rt_Tw.green400, _rt_Tw.green700, sun),
        size: 10.5,
      );
    }

    label(texts['jar']!, const Offset(cx, 92));
    label(texts['molecule']!, const Offset(cx, 356));
  }
}

/// Zone 5: acid + alcohol + H₂SO₄ in a tube on a warm water bath; heating
/// releases water and the fruity ester; the sodium test pops out H₂.
class _EsterScene extends _ScenePainter {
  _EsterScene({
    required super.a,
    required super.labels,
    required super.repaint,
    required this.step,
    required this.texts,
  });

  final int step;
  final Map<String, String> texts;

  /// Headroom above the tube for the scent, the H₂ bubbles and the
  /// dehydration marker.
  static const _dy = 60.0;

  @override
  Size get design => const Size(400, 482 + _dy);

  /// Design point shifted below the headroom (labels are placed unscaled).
  Offset _o(double x, double y) => Offset(x, y + _dy);

  @override
  void paintScene(Canvas c) {
    const cx = 200.0;
    c.translate(0, _dy);
    _bench(c, 470);
    _tripod(c, cx: cx, top: 258, bottom: 470, width: 160);
    if (step == 2) {
      _flame(
        c,
        const Offset(cx, 372),
        36,
        108,
        blue: true,
        t: a.t,
        opacity: 0.8,
      );
    }
    _burner(
      c,
      cx: cx,
      top: 368,
      chimneyW: 36,
      chimneyH: 74,
      baseW: 124,
      baseH: 28,
    );

    const bath = Rect.fromLTRB(90, 150, 310, 258);
    _bathBack(
      c,
      bath,
      30,
      const Color(0xFFBFDBFE).withValues(alpha: 0.35),
      waterTop: 14,
    );
    if (step == 2) {
      _bubbles(c, a, const Rect.fromLTRB(98, 196, 302, 254), 10, 23, rise: 44);
    }
    const tube = Rect.fromLTWH(175, 66, 50, 182);
    _tube(
      c,
      tube,
      level: 0.43 * a.esterLiquid,
      liquid: const Color(0xFFF3E8FF).withValues(alpha: 0.85),
    );
    if (step == 4) {
      // Sodium piece fizzing at the bottom of the tube, and the 💥.
      final op = 0.6 + 0.4 * math.sin(a.t * 6).abs();
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, tube.bottom - 16),
            width: 14,
            height: 14,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF9CA3AF).withValues(alpha: op),
      );
      final p = a.t % 1;
      _burst(c, Offset(cx, tube.bottom - 50), 14 * (1 + p), 1 - p);
    }
    _bathFront(c, bath, 30, const Color(0xFF60A5FA).withValues(alpha: 0.5));

    if (step == 1) {
      // Acid, alcohol and the H₂SO₄ catalyst bouncing in.
      const colors = [Color(0xFFF87171), Color(0xFF60A5FA), Color(0xFFFACC15)];
      final names = [texts['acid']!, texts['alc']!, 'H₂SO₄'];
      for (var i = 0; i < 3; i++) {
        final x = cx - 60 + i * 60.0;
        final b = -10 * math.sin((a.t + i * 0.1) * math.pi).abs();
        c.drawCircle(Offset(x, -20 + b), 6, Paint()..color = colors[i]);
        caption(names[i], _o(x, -4 + b), size: 8.5, color: _rt_Lab.text);
      }
    }
    if (step == 2) {
      final p = a.t % 1;
      c.drawCircle(
        const Offset(cx, -36),
        10 * (1 + p),
        Paint()
          ..color = const Color(0xFF60A5FA).withValues(alpha: 0.75 * (1 - p)),
      );
      c.drawCircle(
        const Offset(cx, -36),
        8,
        Paint()..color = const Color(0xFF60A5FA),
      );
      caption(
        texts['removed']!,
        _o(cx, -14),
        style: _TagStyle.light,
        color: _rt_Tw.blue600,
        size: 10,
      );
      caption(
        texts['dehydration']!,
        _o(cx, 6),
        color: _rt_Lab.textMuted,
        size: 9,
        mono: true,
      );
    }
    if (step == 3) {
      // Source .scent-particle 🌺 x25: rise and fan out over 3 s.
      final rnd = math.Random(31);
      for (var i = 0; i < 25; i++) {
        final txs = (rnd.nextDouble() - 0.5) * 20;
        final txe = (rnd.nextDouble() - 0.5) * 240;
        // Delays spread over the whole 3 s loop give a steady stream of scent.
        final delay = rnd.nextDouble() * 3;
        final p = ((a.t + delay) % 3) / 3;
        final Offset pos;
        final double sc;
        final double op;
        if (p < 0.2) {
          final q = p / 0.2;
          pos = Offset(txs * q, -40 * q);
          sc = 0.2 + 0.6 * q;
          op = q;
        } else {
          final q = (p - 0.2) / 0.8;
          pos = Offset(txs + (txe - txs) * q, -40 - 140 * q);
          sc = 0.8 + 0.7 * q;
          op = 1 - q;
        }
        _flower(c, const Offset(cx, 76) + pos, 12 * sc, op);
      }
    }
    if (step == 4) {
      // Source: 15 bouncing "H₂" bubbles.
      final rnd = math.Random(17);
      for (var i = 0; i < 15; i++) {
        final x = cx + (rnd.nextDouble() - 0.5) * 90;
        final y0 = 18 + rnd.nextDouble() * 96;
        final delay = rnd.nextDouble() * 0.5;
        final b = -8 * math.sin((a.t + delay) / 0.8 * math.pi).abs();
        final pos = Offset(x, y0 + b);
        c.drawCircle(pos, 9, Paint()..color = Colors.white);
        c.drawCircle(
          pos,
          9,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFF4B5563),
        );
        _text(c, 'H₂', pos, 7.5, _rt_Tw.slate900);
      }
    }

    label(texts['bath']!, _o(84, 236), Alignment.centerRight);
    label(texts['tube']!, _o(318, 136), Alignment.centerLeft);
    label(texts['burner']!, _o(cx, 456));
  }
}

void _flower(Canvas c, Offset p, double r, double op) {
  final petal = Paint()
    ..color = const Color(0xFFF472B6).withValues(alpha: op.clamp(0.0, 1.0));
  for (var k = 0; k < 5; k++) {
    final ang = k * 2 * math.pi / 5 - math.pi / 2;
    c.drawCircle(
      p + Offset(math.cos(ang), math.sin(ang)) * r * 0.55,
      r * 0.45,
      petal,
    );
  }
  c.drawCircle(
    p,
    r * 0.3,
    Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: op.clamp(0.0, 1.0)),
  );
}

void _burst(Canvas c, Offset p, double r, double op) {
  final path = Path();
  for (var k = 0; k < 16; k++) {
    final ang = k * math.pi / 8;
    final rr = k.isEven ? r : r * 0.5;
    final pt = p + Offset(math.cos(ang), math.sin(ang)) * rr;
    if (k == 0) {
      path.moveTo(pt.dx, pt.dy);
    } else {
      path.lineTo(pt.dx, pt.dy);
    }
  }
  path.close();
  c.drawPath(
    path,
    Paint()
      ..color = const Color(0xFFF97316).withValues(alpha: op.clamp(0.0, 1.0)),
  );
  c.drawCircle(
    p,
    r * 0.35,
    Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: op.clamp(0.0, 1.0)),
  );
}
