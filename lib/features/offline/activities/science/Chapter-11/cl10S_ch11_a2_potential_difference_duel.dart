// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 11.2: The Potential Difference Duel
// Converted from Cl10S-Ch11-A2-PotentialDifferenceDuel.html (canvas-2D -> CustomPainter stations).
//
// Three missions on a white grid canvas: Zone 1 is the water analogy (two
// tanks, valve, pipe, turbine; lifting Tank A creates the pressure difference
// that drives flow, with a "morph to electricity" overlay), Zone 2 is the
// chemical lift inside a battery (a worker carries +Q charge bags up the ramp;
// each deposit adds W = 1.5 J and Q = 1 C so V = W/Q = 1.50 V), Zone 3 is the
// parallel-probe voltmeter game (drag the red/black probes to the dots; a
// parallel connection reads 1.5 V, a series connection kills the bulb).
// Completing a mission raises the source's observation popup with a
// "what we learned" box and Prev / Next Mission navigation; Finish on the
// last one opens the Lab Complete modal.

// --- TRANSLATION DATA (source CONTENT block, en + hi; te ignored) ---

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
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const teal900 = Color(0xFF134E4A);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const blue500 = Color(0xFF3B82F6);
  static const indigo500 = Color(0xFF6366F1);
  static const purple600 = Color(0xFF9333EA);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const orange500 = Color(0xFFF97316);
  static const amber600 = Color(0xFFD97706);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
}

/// Pill action button (the HTML `.action-btn`). Plays a click sound.
class _rt_ActionButton extends StatelessWidget {
  const _rt_ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = _rt_Tw.teal600,
    this.sound = _rt_Sfx.click,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done = false;
  final bool expand = false;
  final _rt_Sfx? sound;

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
    this.child,
    this.leftBorder = false,
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag = null;
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

/// HUD read-out card shown over the 3D view (the HTML `.hud-card`).
class _rt_HudCard extends StatelessWidget {
  const _rt_HudCard({
    super.key,
    required this.value,
    required this.label,
    this.color = _rt_Tw.teal700,
  });

  final String value;
  final String label;
  final Color color;
  final double minWidth = 90;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _rt_Lab.onTinted(color, color),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small section heading inside the sidebar.
class _rt_SectionLabel extends StatelessWidget {
  const _rt_SectionLabel(this.text, {this.color, this.icon});

  final String text;

  /// Defaults to the theme's muted text colour.
  final Color? color;
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
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueText,
    this.color = _rt_Tw.teal600,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions = null;
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
  void showToast(
    String message, {
    Color color = _rt_Tw.green500,
    IconData icon = Icons.check,
    int ms = 3000,
  }) {
    _state?._showToast(message, color, icon, ms);
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
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.toolbarExtras = const [],
    this.hint,
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
  final VoidCallback? onStart = null;

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final List<Widget> toolbarExtras;

  final _rt_StepHint? hint;

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

/// Pan + zoom for a 2D activity canvas.
///
/// The 3D activities drive the toolbar through [Camera3D]; a 2D station has no
/// camera, so this wraps the canvas in an [InteractiveViewer] and exposes the
/// same `zoomIn` / `zoomOut` / `reset` callbacks the shell's toolbar expects.
class _rt_CanvasZoomController {
  _rt_CanvasZoomController();

  final double min = 0.6;
  final double max = 3.0;
  final double step = 1.25;

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
  const _rt_ZoomableCanvas({required this.controller, required this.child});

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
    'title': 'POTENTIAL DIFFERENCE DUEL',
    'subtitle': 'Class 10 • Electricity',
    'intro': {
      'title': 'POTENTIAL DIFFERENCE',
      'subtitle': 'Class 10 • Electricity',
      'button': 'Enter _rt_Lab',
      'footnote': 'Water • Work • Voltmeter',
    },
    'mainObj':
        'Explore the definition of Potential Difference (Voltage) and understand how work done per unit charge creates the pressure needed to drive current flow in a circuit.',
    'do': 'DO',
    'focus': 'FOCUS',
    'tabs': {
      'context': 'WHY LEARN?',
      'guide': "TEACHER'S GUIDE",
      'explore': '_rt_Lab',
      'analysis': 'OUTCOMES',
    },
    'ui': {
      'whyTitle': 'Why does this matter?',
      'whyBody':
          'Potential Difference isn\'t just an abstract number on a battery. It\'s the "push" that makes everything happen. Without it, energy cannot be transferred, and work cannot be done.',
      'conceptTitle': 'Concept Overview:',
      'conceptBody':
          'Teach Potential Difference as a "Driver". Just as pressure difference drives water, potential difference drives charge. Use the analogy to anchor the concept, then math to define it.',
      'objTitle': 'Objective',
      'outcomesTitle': 'Detailed Learning Outcomes',
      'guideTitle': 'Guidance',
      'controls': 'Controls',
      'openValve': 'Open Valve',
      'closeValve': 'Close Valve',
      'diffActive': 'Difference Active! Flowing.',
      'valveClosed': 'Valve Closed. No Flow.',
      'levelsEqual': 'Levels Equal. No Potential Difference.',
      'tankA': 'Tank A (High Potential)',
      'tankB': 'Tank B (Low Potential)',
      'switch': 'Switch (Valve)',
      'wire': 'Conductor (Wire)',
      'loadFan': 'Load (Bulb/Fan)',
      'posTerm': 'Positive Terminal (+)',
      'negTerm': 'Negative Terminal (-)',
      'work': 'Work (W)',
      'charge': 'Charge (Q)',
      'voltage': 'Voltage (V)',
      'doingWork': 'Doing Work!',
      'gradient': 'Electric Potential Gradient',
      'sourceBatt': 'Source (Battery)',
      'loadBulb': 'Load (Bulb)',
      'voltmeter': 'Voltmeter',
      'parallel': 'Parallel',
      'seriesBad': 'Series (Bad)',
      'connectProbes': 'Connect Probes.',
      'correctParallel': 'Correct! Parallel Connection.',
      'incorrectSeries': 'INCORRECT! SERIES CONNECTION BLOCKS CURRENT!',
      'labComplete': '_rt_Lab Complete!',
      'mastered': 'You have mastered the concept of Potential Difference.',
      'close': 'Close',
      'restart': 'Restart _rt_Lab',
      'm1SuccessToast':
          'Outcome: Just as water needs a pressure difference, electricity needs a Potential Difference.',
      'dragProbes': 'Drag probes to the dots on bulb.',
      'trySeries': 'Try Series (Wrong)',
      'detach': 'Detach Probes',
      'toggleLabels': 'Show / Hide Labels',
    },
    'controls': {
      'height': 'Lift Tank A',
      'valve': 'Open Valve',
      'work': 'Generate Power',
      'morph': 'Switch to Electricity',
    },
    'obsModal': {
      'title': 'Observation',
      'learned': 'What we learned:',
      'prev': 'Prev',
      'next': 'Next Mission',
      'finish': 'Finish',
    },
    'missions': [
      {
        'title': 'Zone 1: The Water Analogy',
        'do':
            '1. Open Valve.\n2. Observe: Before Lifting, water is level, No Flow.\n3. Action: Drag Slider to Lift Tank A.',
        'observe':
            'Gravity creates a pressure difference. This difference drives the flow from High to Low potential.',
        'learn':
            'No difference in level = No Flow. Difference drives Flow. This is like Potential Difference (Voltage).',
      },
      {
        'title': 'Zone 2: The Chemical Lift',
        'do':
            "Hold 'Generate Power'. Watch the Worker carry charge bags up the ramp.",
        'observe':
            "The worker struggles (sweats) to lift charges against gravity. This 'Work' is stored as Potential Energy.",
        'learn':
            'Voltage (V) = Work Done (W) / Charge (Q). 1 Volt = 1 Joule/Coulomb.',
      },
      {
        'title': 'Zone 3: The Parallel Probe',
        'do': 'Measure Voltage. Avoid Series connection!',
        'observe':
            'Connecting in Series (Top Wire) breaks the circuit (Bulb OFF). Connecting in Parallel (Across Bulb) works (Bulb ON).',
        'learn':
            'Voltmeters have high resistance. Connecting in series blocks current. Always connect in Parallel.',
      },
    ],
    'context': [
      {
        'title': 'Power Source for Life',
        'text':
            'Just as a pump lifts water to create flow, batteries lift charges to power our devices. Without potential difference, our phones, cars, and pacemakers would stop.',
      },
      {
        'title': "Nature's Voltage",
        'text':
            'Lightning is a massive discharge caused by a huge potential difference (millions of volts) between clouds and the ground.',
      },
      {
        'title': 'Bio-Electricity',
        'text':
            "Your nerve cells maintain a potential difference across their membranes. This 'action potential' allows your brain to send signals to your muscles.",
      },
    ],
    'guide': [
      {
        'phase': 'Phase 1: Discovery',
        'steps': [
          "Start with the Water Analogy. Ask students: 'Why isn't the water moving?'",
          "Have a student lift Tank A. Discuss how 'height difference' creates pressure.",
          "Relate this to 'Potential Difference' in circuits.",
        ],
      },
      {
        'phase': 'Phase 2: Interaction',
        'steps': [
          'Switch to Zone 2. Explain the battery is not a magical box, but a chemical factory doing WORK.',
          "Show the 'Worker' lifting charges. The higher he lifts, the more potential energy they have.",
          'Define Volt: 1 Joule of Work for 1 Coulomb of Charge.',
        ],
      },
      {
        'phase': 'Phase 3: Observation',
        'steps': [
          "Move to Zone 3. Challenge students to measure the 'Push' across the bulb.",
          'Demonstrate the wrong way (Series) - Bulb turns OFF due to high resistance.',
          'Demonstrate the correct way (Parallel) - Bulb stays ON, meter gives reading.',
        ],
      },
    ],
    'outcomes': [
      'Concept Mastery: Students will define Electric Potential Difference as the work done to move a unit charge from one point to another.',
      'Mathematical Fluency: Students will be able to apply the formula V = W/Q and understand the units (Volts, Joules, Coulombs).',
      'Practical Skill: Students will demonstrate the correct technique for connecting a voltmeter in a circuit (Parallel connection) and explain why series connection is incorrect.',
      'Analogy Mapping: Students will successfully map hydraulic variables (Pressure Diff, Water Flow) to electrical variables (Voltage, Current).',
    ],
  },
  'hi': {
    'title': 'विभवांतर द्वंद्व (Potential Difference)',
    'subtitle': 'कक्षा 10 • विद्युत',
    'intro': {
      'title': 'विभवांतर',
      'subtitle': 'कक्षा 10 • विद्युत',
      'button': 'लैब में प्रवेश करें',
      'footnote': 'जल • कार्य • वोल्टमीटर',
    },
    'mainObj':
        'विभवांतर (वोल्टेज) की परिभाषा का अन्वेषण करें और समझें कि प्रति इकाई आवेश पर किया गया कार्य सर्किट में करंट प्रवाह को चलाने के लिए आवश्यक दबाव कैसे बनाता है।',
    'do': 'करें',
    'focus': 'ध्यान दें',
    'tabs': {
      'context': 'क्यों सीखें?',
      'guide': 'शिक्षक गाइड',
      'explore': 'लैब',
      'analysis': 'परिणाम',
    },
    'ui': {
      'whyTitle': 'यह क्यों मायने रखता है?',
      'whyBody':
          "विभवांतर बैटरी पर केवल एक अमूर्त संख्या नहीं है। यह वह 'धक्का' है जो सब कुछ संभव बनाता है। इसके बिना, ऊर्जा स्थानांतरित नहीं की जा सकती, और कार्य नहीं किया जा सकता है।",
      'conceptTitle': 'अवधारणा अवलोकन:',
      'conceptBody':
          "विभवांतर को 'चालक' के रूप में पढ़ाएं। जैसे दबाव का अंतर पानी को चलाता है, वैसे ही विभवांतर आवेश को चलाता है। अवधारणा को जोड़ने के लिए सादृश्य का उपयोग करें, फिर इसे परिभाषित करने के लिए गणित का उपयोग करें।",
      'objTitle': 'उद्देश्य',
      'outcomesTitle': 'विस्तृत सीखने के परिणाम',
      'guideTitle': 'मार्गदर्शन',
      'controls': 'नियंत्रण',
      'openValve': 'वाल्व खोलें',
      'closeValve': 'वाल्व बंद करें',
      'diffActive': 'अंतर सक्रिय! प्रवाह जारी।',
      'valveClosed': 'वाल्व बंद। कोई प्रवाह नहीं।',
      'levelsEqual': 'स्तर समान। कोई विभवांतर नहीं।',
      'tankA': 'टैंक A (उच्च विभव)',
      'tankB': 'टैंक B (निम्न विभव)',
      'switch': 'स्विच (वाल्व)',
      'wire': 'चालक (तार)',
      'loadFan': 'लोड (बल्ब/पंखा)',
      'posTerm': 'धनात्मक टर्मिनल (+)',
      'negTerm': 'ऋणात्मक टर्मिनल (-)',
      'work': 'कार्य (W)',
      'charge': 'आवेश (Q)',
      'voltage': 'वोल्टेज (V)',
      'doingWork': 'कार्य हो रहा है!',
      'gradient': 'विद्युत विभव प्रवणता',
      'sourceBatt': 'स्रोत (बैटरी)',
      'loadBulb': 'लोड (बल्ब)',
      'voltmeter': 'वोल्टमीटर',
      'parallel': 'समानांतर',
      'seriesBad': 'श्रृंखला (गलत)',
      'connectProbes': 'जांच कनेक्ट करें।',
      'correctParallel': 'सही! समानांतर कनेक्शन।',
      'incorrectSeries': 'गलत! श्रृंखला कनेक्शन करंट को रोकता है!',
      'labComplete': 'लैब पूर्ण!',
      'mastered': 'आपने विभवांतर की अवधारणा में महारत हासिल कर ली है।',
      'close': 'बंद करें',
      'restart': 'लैब पुनः आरंभ करें',
      'm1SuccessToast':
          'परिणाम: जैसे पानी को दबाव अंतर की आवश्यकता होती है, बिजली को विभवांतर की आवश्यकता होती है।',
      'dragProbes': 'जांच को बल्ब पर बिंदुओं तक खींचें।',
      'trySeries': 'श्रृंखला आज़माएं (गलत)',
      'detach': 'जांच हटाएं',
      'toggleLabels': 'लेबल दिखाएँ / छिपाएँ',
    },
    'controls': {
      'height': 'टैंक A उठाएं',
      'valve': 'वाल्व खोलें',
      'work': 'पावर उत्पन्न करें',
      'morph': 'बिजली में बदलें',
    },
    'obsModal': {
      'title': 'अवलोकन',
      'learned': 'हमने क्या सीखा:',
      'prev': 'पिछला',
      'next': 'अगला मिशन',
      'finish': 'समाप्त करें',
    },
    'missions': [
      {
        'title': 'जोन 1: जल सादृश्य',
        'do':
            '1. वाल्व खोलें।\n2. अवलोकन करें: उठाने से पहले, पानी का स्तर बराबर है, कोई प्रवाह नहीं।\n3. क्रिया: टैंक A को उठाने के लिए स्लाइडर खींचें।',
        'observe':
            'गुरुत्वाकर्षण दबाव अंतर पैदा करता है। यह अंतर प्रवाह को उच्च से निम्न क्षमता की ओर ले जाता है।',
        'learn':
            'स्तर में कोई अंतर नहीं = कोई प्रवाह नहीं। अंतर प्रवाह को चलाता है। यह विभवांतर (वोल्टेज) की तरह है।',
      },
      {
        'title': 'जोन 2: रासायनिक लिफ्ट',
        'do':
            "'पावर उत्पन्न करें' दबाए रखें। कार्यकर्ता को रैंप पर आवेश बैग ले जाते हुए देखें।",
        'observe':
            "कार्यकर्ता गुरुत्वाकर्षण के विरुद्ध आवेश उठाने के लिए संघर्ष (पसीना) करता है। यह 'कार्य' स्थितिज ऊर्जा के रूप में संग्रहीत होता है।",
        'learn':
            'वोल्टेज (V) = किया गया कार्य (W) / आवेश (Q)। 1 वोल्ट = 1 जूल/कूलम्ब।',
      },
      {
        'title': 'जोन 3: समानांतर जांच',
        'do': 'वोल्टेज मापें। श्रृंखला कनेक्शन से बचें!',
        'observe':
            'श्रृंखला में जोड़ने पर (शीर्ष तार) सर्किट टूट जाता है (बल्ब बंद)। समानांतर में जोड़ने पर (बल्ब के आर-पार) काम करता है (बल्ब चालू)।',
        'learn':
            'वोल्टमीटर का प्रतिरोध उच्च होता है। श्रृंखला में जोड़ने पर करंट रुक जाता है। हमेशा समानांतर में जोड़ें।',
      },
    ],
    'context': [
      {
        'title': 'जीवन के लिए ऊर्जा स्रोत',
        'text':
            'जैसे पंप प्रवाह बनाने के लिए पानी उठाता है, बैटरी हमारे उपकरणों को शक्ति देने के लिए आवेश उठाती है। विभवांतर के बिना, हमारे फोन, कार और पेसमेकर रुक जाएंगे।',
      },
      {
        'title': 'प्रकृति का वोल्टेज',
        'text':
            'बिजली एक विशाल निर्वहन है जो बादलों और जमीन के बीच भारी विभवांतर (लाखों वोल्ट) के कारण होता है।',
      },
      {
        'title': 'जैव-विद्युत',
        'text':
            "आपकी तंत्रिका कोशिकाएं अपनी झिल्लियों के पार विभवांतर बनाए रखती हैं। यह 'एक्शन पोटेंशियल' आपके मस्तिष्क को मांसपेशियों को संकेत भेजने की अनुमति देता है।",
      },
    ],
    'guide': [
      {
        'phase': 'चरण 1: खोज',
        'steps': [
          "जल सादृश्य के साथ शुरू करें। छात्रों से पूछें: 'पानी क्यों नहीं चल रहा है?'",
          "एक छात्र से टैंक A उठाने को कहें। चर्चा करें कि 'ऊंचाई अंतर' दबाव कैसे बनाता है।",
          "इसे सर्किट में 'विभवांतर' से जोड़ें।",
        ],
      },
      {
        'phase': 'चरण 2: बातचीत',
        'steps': [
          "जोन 2 पर जाएं। समझाएं कि बैटरी कोई जादुई डिब्बा नहीं है, बल्कि एक रासायनिक कारखाना है जो 'कार्य' कर रहा है।",
          'कार्यकर्ता को आवेश उठाते हुए दिखाएं। वह जितना ऊंचा उठाता है, उतनी ही अधिक स्थितिज ऊर्जा उनके पास होती है।',
          'वोल्ट को परिभाषित करें: 1 कूलम्ब आवेश के लिए 1 जूल कार्य।',
        ],
      },
      {
        'phase': 'चरण 3: अवलोकन',
        'steps': [
          "जोन 3 पर जाएं। छात्रों को बल्ब के पार 'पुश' मापने की चुनौती दें।",
          'गलत तरीका (श्रृंखला) प्रदर्शित करें - उच्च प्रतिरोध के कारण बल्ब बंद हो जाता है।',
          'सही तरीका (समानांतर) प्रदर्शित करें - बल्ब चालू रहता है, मीटर रीडिंग देता है।',
        ],
      },
    ],
    'outcomes': [
      'अवधारणा महारत: छात्र विद्युत विभवांतर को एक बिंदु से दूसरे बिंदु तक इकाई आवेश को ले जाने के लिए किए गए कार्य के रूप में परिभाषित करेंगे।',
      'गणितीय प्रवाह: छात्र सूत्र V = W/Q लागू करने और इकाइयों (वोल्ट, जूल, कूलम्ब) को समझने में सक्षम होंगे।',
      'व्यावहारिक कौशल: छात्र सर्किट में वोल्टमीटर जोड़ने की सही तकनीक (समानांतर कनेक्शन) प्रदर्शित करेंगे और समझाएंगे कि श्रृंखला कनेक्शन गलत क्यों है।',
      'सादृश्य मानचित्रण: छात्र हाइड्रोलिक चर (दबाव अंतर, जल प्रवाह) को विद्युत चर (वोल्टेज, करंट) में सफलतापूर्वक मैप करेंगे।',
    ],
  },
});

// --- Zone geometry (design units of the 500-wide stages) ---
const Size _z1Size = Size(500, 300);
const Size _z2Size = Size(500, 300);
const Size _z3Size = Size(500, 310);

// Zone 2 waypoints (source rampBottom/rampTop/pilePos, scaled).
const Offset _rampBottom = Offset(170, 235);
const Offset _rampTop = Offset(322, 64);
const Offset _pilePos = Offset(140, 232);

// Zone 3 probe targets (source parallelL/R at the bulb wire, seriesL/R on the
// top wire) and rest positions.
const Map<String, Offset> _probeSpots = {
  'pL': Offset(210, 240),
  'pR': Offset(440, 240),
  'sL': Offset(210, 60),
  'sR': Offset(440, 60),
};
const Offset _redRest = Offset(60, 288);
const Offset _blackRest = Offset(105, 288);

class _FlowDrop {
  _FlowDrop(this.p, this.lane, this.seed);
  double p; // 0..1 progress along the pipe
  final double lane; // perpendicular offset
  final double seed; // jiggle phase
}

class _Sweat {
  _Sweat(this.x, this.y) : life = 0.45;
  double x, y, life;
}

class _Worker {
  double x = _rampBottom.dx;
  double y = _rampBottom.dy;
  String state = 'idle'; // idle | picking | lifting | depositing | returning

  void reset() {
    x = _rampBottom.dx;
    y = _rampBottom.dy;
    state = 'idle';
  }
}

class Cl10SCh11A2PotentialDifferenceDuelPage extends StatefulWidget {
  const Cl10SCh11A2PotentialDifferenceDuelPage({super.key});

  @override
  State<Cl10SCh11A2PotentialDifferenceDuelPage> createState() =>
      _Cl10SCh11A2PotentialDifferenceDuelPageState();
}

class _Cl10SCh11A2PotentialDifferenceDuelPageState
    extends State<Cl10SCh11A2PotentialDifferenceDuelPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();
  final ScrollController _chipBar = ScrollController();
  final math.Random _rng = math.Random(11);

  int _mission = 0;
  final List<bool> _done = [false, false, false];
  bool _showLabels = true; // source default: labels ON

  // Zone 1 state (source app.z1).
  double _hA = 0;
  bool _valveOpen = false;
  bool _morph = false;
  double _turbine = 0;
  late final List<_FlowDrop> _drops = List.generate(
    36,
    (i) => _FlowDrop(
      _rng.nextDouble(),
      (_rng.nextDouble() - 0.5) * 8,
      _rng.nextDouble() * 6.28,
    ),
  );

  // Zone 2 state (source app.z2).
  double _work = 0;
  double _charge = 0;
  bool _isWorking = false;
  final _Worker _worker = _Worker();
  final List<bool> _bags = List<bool>.filled(9, true);
  final List<_Sweat> _sweat = [];

  // Zone 3 state (source app.z3): where each probe is anchored.
  String _redAnchor = 'rest';
  String _blackAnchor = 'rest';
  String _connection = 'none'; // none | parallel | series

  Timer? _obsTimer;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _time = 0;

  /// Bumped every ticker frame; painters listen so the canvas animates
  /// without a setState per frame.
  final ValueNotifier<int> _frame = ValueNotifier(0);

  double get _flow => _valveOpen ? _hA * 0.1 : 0.0;

  String get _volt =>
      _charge > 0 ? (_work / _charge).toStringAsFixed(2) : '0.00';

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
    _obsTimer?.cancel();
    _ticker.dispose();
    _frame.dispose();
    _zoom.dispose();
    _chipBar.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- simulation ---
  void _onTick(Duration elapsed) {
    double dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.25) dt = 0.016;
    _time += dt;

    if (_mission == 0) {
      final flow = _flow;
      if (flow > 0.1) {
        for (final d in _drops) {
          d.p += flow * 0.2 * dt;
          if (d.p > 1) d.p -= 1;
        }
        _turbine += flow * 1.4 * dt;
      }
      // Source setInterval poll: flow > 2 && hA > 50 completes mission 1.
      if (!_done[0] && _flow > 2 && _hA > 50) _completeMission(0);
    } else if (_mission == 1) {
      _tickWorker(dt);
    }
    _frame.value++;
  }

  void _tickWorker(double dt) {
    final w = _worker;
    switch (w.state) {
      case 'idle':
        if (_isWorking) w.state = 'picking';
      case 'picking':
        if (w.x > _pilePos.dx) {
          w.x -= 60 * dt;
        } else {
          // Hide one bag from the pile (source: bag.visible = false).
          final i = _bags.indexOf(true);
          if (i >= 0) _bags[i] = false;
          w.state = 'lifting';
        }
      case 'lifting':
        final dx = _rampTop.dx - w.x;
        final dy = _rampTop.dy - w.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist > 4) {
          w.x += dx / dist * 75 * dt;
          w.y += dy / dist * 75 * dt;
          if (_rng.nextDouble() > 0.88) {
            _sweat.add(_Sweat(w.x + (_rng.nextDouble() - 0.5) * 12, w.y - 30));
          }
        } else {
          w.state = 'depositing';
          _deposit();
        }
      case 'depositing':
        w.state = 'returning';
      default: // returning
        final dx = _rampBottom.dx - w.x;
        final dy = _rampBottom.dy - w.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist > 4) {
          w.x += dx / dist * 210 * dt;
          w.y += dy / dist * 210 * dt;
        } else {
          w.state = _isWorking ? 'picking' : 'idle';
        }
    }
    for (final s in _sweat) {
      s.y += 55 * dt;
      s.life -= dt;
    }
    _sweat.removeWhere((s) => s.life <= 0);
  }

  /// Source: AudioEngine.playTone('click') + work/charge increments at ramp top.
  void _deposit() {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _work += 1.5;
      _charge += 1.0;
    });
    if (!_done[1] && _work >= 1.5) _completeMission(1);
  }

  // -------------------------------------------------------------- missions ---
  void _completeMission(int i) {
    if (_done[i]) return;
    setState(() => _done[i] = true);
    // Source: AudioEngine.playTone('success').
    _rt_playSfx(_rt_Sfx.success);
    if (i == 0) {
      _shell.showToast(
        _tx.s('ui.m1SuccessToast'),
        color: _rt_Tw.cyan500,
        icon: Icons.check_circle,
      );
    }
    _obsTimer?.cancel();
    // Source delays the observation card 2500 ms after the M1 toast, 500 ms otherwise.
    _obsTimer = Timer(Duration(milliseconds: i == 0 ? 2500 : 500), () {
      if (mounted) _showObservation(i);
    });
  }

  Future<void> _showObservation(int i) async {
    final m = _tx.list('missions')[i] as Map;
    final nav = Navigator.of(context);
    await _rt_showShellPopup(
      context,
      title: _tx.s('obsModal.title'),
      message: m['observe'] as String,
      icon: Icons.fact_check,
      color: _rt_Tw.cyan500,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _rt_Lab.tinted(const Color(0xFFECFEFF), _rt_Tw.cyan500),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.cyan500)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tx.s('obsModal.learned').toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: _rt_Lab.onTinted(_rt_Tw.cyan400, _rt_Tw.cyan600),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              m['learn'] as String,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: _rt_Lab.text,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (i > 0)
          _rt_ActionButton(
            key: const ValueKey('obs-prev'),
            label: _tx.s('obsModal.prev'),
            icon: Icons.chevron_left,
            color: _rt_Tw.slate500,
            onPressed: () {
              nav.pop();
              _setMission(i - 1);
            },
          ),
        _rt_ActionButton(
          key: const ValueKey('obs-next'),
          label: i == 2 ? _tx.s('obsModal.finish') : _tx.s('obsModal.next'),
          icon: i == 2 ? Icons.flag : Icons.arrow_forward,
          color: _rt_Tw.cyan600,
          onPressed: () {
            nav.pop();
            if (i == 2) {
              _showComplete();
            } else {
              _setMission(i + 1);
            }
          },
        ),
      ],
    );
  }

  /// Source success modal (_rt_Lab Complete / Close / Restart _rt_Lab).
  void _showComplete() {
    _rt_playSfx(_rt_Sfx.success);
    final nav = Navigator.of(context);
    _rt_showShellPopup(
      context,
      title: _tx.s('ui.labComplete'),
      message: _tx.s('ui.mastered'),
      icon: Icons.emoji_events,
      color: _rt_Tw.green500,
      actions: [
        _rt_ActionButton(
          key: const ValueKey('complete-close'),
          label: _tx.s('ui.close'),
          icon: Icons.close,
          color: _rt_Tw.slate500,
          onPressed: nav.pop,
        ),
        _rt_ActionButton(
          key: const ValueKey('complete-restart'),
          label: _tx.s('ui.restart'),
          icon: Icons.refresh,
          color: _rt_Tw.cyan600,
          onPressed: () {
            nav.pop();
            _rt_playSfx(_rt_Sfx.scenario);
            _restart();
          },
        ),
      ],
    );
  }

  /// Source setActiveMission: switching also re-arms the mission
  /// (resetMissionState clears its status so it is played from the start).
  void _setMission(int i) {
    _rt_playSfx(_rt_Sfx.scenario);
    _obsTimer?.cancel();
    setState(() {
      _mission = i;
      _done[i] = false;
      _resetMissionState(i);
    });
  }

  void _resetMissionState(int i) {
    if (i == 0) {
      _hA = 0;
      _valveOpen = false;
      _morph = false;
      _turbine = 0;
    } else if (i == 1) {
      _work = 0;
      _charge = 0;
      _isWorking = false;
      _worker.reset();
      _sweat.clear();
      for (var b = 0; b < _bags.length; b++) {
        _bags[b] = true;
      }
    } else {
      _redAnchor = 'rest';
      _blackAnchor = 'rest';
      _connection = 'none';
    }
  }

  /// Source hardReset (the shell already plays the restart sound).
  void _restart() {
    _obsTimer?.cancel();
    _zoom.reset();
    if (_chipBar.hasClients) _chipBar.jumpTo(0);
    setState(() {
      _mission = 0;
      _showLabels = true;
      for (var i = 0; i < _done.length; i++) {
        _done[i] = false;
      }
      for (final z in [0, 1, 2]) {
        _resetMissionState(z);
      }
    });
  }

  // ----------------------------------------------------------- zone 1 ops ---
  void _toggleValve() {
    setState(() => _valveOpen = !_valveOpen);
  }

  void _toggleMorph() {
    setState(() => _morph = !_morph);
  }

  // ----------------------------------------------------------- zone 3 ops ---
  void _placeProbe(String probe, String anchor) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      if (probe == 'red') {
        _redAnchor = anchor;
        if (_blackAnchor == anchor) _blackAnchor = 'rest';
      } else {
        _blackAnchor = anchor;
        if (_redAnchor == anchor) _redAnchor = 'rest';
      }
    });
    _recomputeConnection();
  }

  void _connectSeries() {
    setState(() => _redAnchor = 'sL');
    _recomputeConnection();
  }

  void _detachProbes() {
    setState(() {
      _redAnchor = 'rest';
      _blackAnchor = 'rest';
    });
    _recomputeConnection();
  }

  /// Source renderZone3 checks: red+black across the bulb = parallel; any
  /// probe on the top wire = series (bulb goes off).
  void _recomputeConnection() {
    String conn = 'none';
    if ((_redAnchor == 'pL' && _blackAnchor == 'pR') ||
        (_redAnchor == 'pR' && _blackAnchor == 'pL')) {
      conn = 'parallel';
    } else if (_redAnchor == 'sL' ||
        _redAnchor == 'sR' ||
        _blackAnchor == 'sL' ||
        _blackAnchor == 'sR') {
      conn = 'series';
    }
    if (conn == _connection) return;
    setState(() => _connection = conn);
    if (conn == 'parallel') {
      _rt_playSfx(_rt_Sfx.correct);
      if (!_done[2]) _completeMission(2);
    } else if (conn == 'series') {
      _rt_playSfx(_rt_Sfx.wrong);
    }
  }

  Offset _probePos(String probe) {
    final anchor = probe == 'red' ? _redAnchor : _blackAnchor;
    if (anchor == 'rest') return probe == 'red' ? _redRest : _blackRest;
    return _probeSpots[anchor]!;
  }

  // ------------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final m = _tx.list('missions')[_mission] as Map;
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.cyan500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF164E63)],
              headerSubtitleColor: Color(0xFFA5F3FC),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.water_drop,
              buttonIcon: Icons.bolt,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: Icons.sell,
                tooltip: _tx.s('ui.toggleLabels'),
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _showLabels = !_showLabels);
                },
              ),
            ],
            hint: _rt_StepHint(
              number: '${_mission + 1}',
              text: m['do'] as String,
              label: m['title'] as String,
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.science,
                builder: (_) => _sidebarTab(),
              ),
            ],
            canvas: _rt_ZoomableCanvas(controller: _zoom, child: _canvasBody()),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------- canvas ---
  Widget _canvasBody() {
    final missions = _tx.list('missions');
    return Column(
      children: [
        SingleChildScrollView(
          controller: _chipBar,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(70, 12, 60, 2),
          child: Row(
            children: [
              for (var i = 0; i < missions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _missionChip(
                    i,
                    (missions[i] as Map)['title'] as String,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 8, 56, 70),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, c.maxHeight - 78),
                ),
                child: Center(
                  child: switch (_mission) {
                    0 => _zone1Stage(),
                    1 => _zone2Stage(),
                    _ => _zone3Stage(),
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionChip(int i, String label) {
    final on = _mission == i;
    return GestureDetector(
      key: ValueKey('chip-$i'),
      onTap: () => _setMission(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.cyan600 : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? _rt_Tw.cyan400 : _rt_Lab.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_done[i]) ...[
              Icon(
                Icons.check_circle,
                size: 13,
                color: on ? Colors.white : _rt_Tw.green500,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: on ? Colors.white : _rt_Lab.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rounded card each zone's white grid canvas sits on.
  Widget _stage({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _rt_Lab.base,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _rt_Lab.border),
      boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );

  Map<String, String> _painterLabels() => {
    'tankA': _tx.s('ui.tankA'),
    'tankB': _tx.s('ui.tankB'),
    'switch': _tx.s('ui.switch'),
    'wire': _tx.s('ui.wire'),
    'loadFan': _tx.s('ui.loadFan'),
    'posTerm': _tx.s('ui.posTerm'),
    'negTerm': _tx.s('ui.negTerm'),
    'doingWork': _tx.s('ui.doingWork'),
    'gradient': _tx.s('ui.gradient'),
    'sourceBatt': _tx.s('ui.sourceBatt'),
    'loadBulb': _tx.s('ui.loadBulb'),
    'voltmeter': _tx.s('ui.voltmeter'),
    'parallel': _tx.s('ui.parallel'),
    'seriesBad': _tx.s('ui.seriesBad'),
  };

  // --------------------------------------------------------------- zone 1 ---
  Widget _zone1Stage() {
    final String status;
    final Color statusColor;
    if (!_valveOpen) {
      status = _tx.s('ui.valveClosed');
      statusColor = _rt_Tw.red500;
    } else if (_hA < 5) {
      status = _tx.s('ui.levelsEqual');
      statusColor = _rt_Tw.blue500;
    } else {
      status = _tx.s('ui.diffActive');
      statusColor = _rt_Tw.green500;
    }
    return _stage(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: _z1Size.width,
            height: _z1Size.height,
            child: CustomPaint(
              painter: _Zone1Painter(
                repaint: _frame,
                hA: _hA,
                valveOpen: _valveOpen,
                morph: _morph,
                flow: _flow,
                turbine: () => _turbine,
                drops: _drops,
                time: () => _time,
                showLabels: _showLabels,
                labels: _painterLabels(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          key: const ValueKey('z1-status'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: _z1Size.width,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              _rt_ActionButton(
                key: const ValueKey('valve-btn'),
                label: _valveOpen
                    ? _tx.s('ui.closeValve')
                    : _tx.s('ui.openValve'),
                icon: Icons.water,
                color: _valveOpen ? _rt_Tw.green600 : _rt_Tw.red600,
                sound: _rt_Sfx.toggle,
                onPressed: _toggleValve,
              ),
              _rt_ActionButton(
                key: const ValueKey('morph-btn'),
                label: _tx.s('controls.morph'),
                icon: Icons.bolt,
                color: _morph ? _rt_Tw.amber600 : _rt_Tw.slate600,
                sound: _rt_Sfx.magic,
                onPressed: _toggleMorph,
              ),
              SizedBox(
                width: 240,
                child: _rt_LabeledSlider(
                  label: _tx.s('controls.height'),
                  value: _hA,
                  min: 0,
                  max: 150,
                  color: _rt_Tw.cyan500,
                  valueText: '${_hA.round()}',
                  onChanged: (v) => setState(() => _hA = v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- zone 2 ---
  Widget _zone2Stage() {
    return _stage(
      children: [
        // Source stats panel: Work / Charge = Voltage.
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              _rt_HudCard(
                value: '${_work.toStringAsFixed(1)} J',
                label: _tx.s('ui.work'),
                color: _rt_Tw.cyan600,
              ),
              Text(
                '/',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.textMuted,
                ),
              ),
              _rt_HudCard(
                value: '${_charge.toStringAsFixed(1)} C',
                label: _tx.s('ui.charge'),
                color: _rt_Tw.purple600,
              ),
              Text(
                '=',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.textMuted,
                ),
              ),
              _rt_HudCard(
                key: const ValueKey('volt-hud'),
                value: '$_volt V',
                label: _tx.s('ui.voltage'),
                color: _rt_Tw.green600,
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: _z2Size.width,
            height: _z2Size.height,
            child: CustomPaint(
              painter: _Zone2Painter(
                repaint: _frame,
                worker: _worker,
                bags: _bags,
                sweat: _sweat,
                charge: () => _charge,
                time: () => _time,
                showLabels: _showLabels,
                labels: _painterLabels(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _holdToWorkButton(),
      ],
    );
  }

  /// Source: press-and-hold "Generate Power" (onmousedown/onmouseup).
  Widget _holdToWorkButton() {
    return Listener(
      onPointerDown: (_) {
        _rt_playSfx(_rt_Sfx.tap);
        setState(() => _isWorking = true);
      },
      onPointerUp: (_) => setState(() => _isWorking = false),
      onPointerCancel: (_) => setState(() => _isWorking = false),
      child: AnimatedContainer(
        key: const ValueKey('work-btn'),
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: _isWorking ? _rt_Tw.cyan400 : _rt_Tw.cyan600,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: _rt_Tw.cyan400, width: 2),
          boxShadow: _isWorking
              ? const [BoxShadow(color: Color(0x8022D3EE), blurRadius: 14)]
              : [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings, size: 15, color: Colors.white),
            const SizedBox(width: 7),
            Text(
              _tx.s('controls.work').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- zone 3 ---
  Widget _zone3Stage() {
    final String msg;
    final Color msgColor;
    if (_connection == 'parallel') {
      msg = _tx.s('ui.correctParallel');
      msgColor = _rt_Tw.green500;
    } else if (_connection == 'series') {
      msg = _tx.s('ui.incorrectSeries');
      msgColor = _rt_Tw.red500;
    } else {
      msg = _tx.s('ui.connectProbes');
      msgColor = _rt_Lab.textMuted;
    }
    final reading = _connection == 'none' ? '0.00' : '1.50';
    return _stage(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _tx.s('ui.dragProbes'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.textMuted,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: _z3Size.width,
            height: _z3Size.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _Zone3Painter(
                      repaint: _frame,
                      connection: _connection,
                      reading: reading,
                      redPos: _probePos('red'),
                      blackPos: _probePos('black'),
                      showLabels: _showLabels,
                      labels: _painterLabels(),
                    ),
                  ),
                ),
                for (final spot in _probeSpots.entries)
                  _probeTarget(spot.key, spot.value),
                _probeDraggable('red', const Color(0xFFEF4444)),
                _probeDraggable('black', const Color(0xFF1E293B)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          msg,
          key: const ValueKey('z3-msg'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _connection == 'series' ? 14 : 13,
            fontWeight: FontWeight.w900,
            color: msgColor,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: _z3Size.width,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            // QA C10-11.2-01: no one-tap parallel twin; the parallel
            // connection is made only by dragging both probes (as the source).
            children: [
              _rt_ActionButton(
                key: const ValueKey('probe-series'),
                label: _tx.s('ui.trySeries'),
                icon: Icons.warning_amber,
                color: _rt_Tw.red600,
                onPressed: _connectSeries,
              ),
              _rt_ActionButton(
                key: const ValueKey('probe-detach'),
                label: _tx.s('ui.detach'),
                icon: Icons.link_off,
                color: _rt_Tw.slate500,
                sound: _rt_Sfx.toggle,
                onPressed: _detachProbes,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _probeTarget(String id, Offset pos) {
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: DragTarget<String>(
        key: ValueKey('dot-$id'),
        onWillAcceptWithDetails: (d) => d.data == 'red' || d.data == 'black',
        onAcceptWithDetails: (d) => _placeProbe(d.data, id),
        builder: (context, cand, _) => Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: cand.isNotEmpty ? 34 : 22,
            height: cand.isNotEmpty ? 34 : 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cand.isNotEmpty ? _rt_Tw.cyan400 : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _probeDraggable(String id, Color color) {
    final pos = _probePos(id);
    final probe = _ProbeBody(color: color);
    return Positioned(
      left: pos.dx - 10,
      top: pos.dy - 56,
      child: Draggable<String>(
        key: ValueKey('probe-$id'),
        data: id,
        hitTestBehavior: HitTestBehavior.opaque,
        onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
        feedback: Material(color: Colors.transparent, child: probe),
        childWhenDragging: Opacity(opacity: 0.3, child: probe),
        child: probe,
      ),
    );
  }

  // --------------------------------------------------------------- sidebar ---
  Widget _sidebarTab() {
    final missions = _tx.list('missions');
    final contextCards = _tx.list('context');
    final guide = _tx.list('guide');
    final outcomes = _tx.list('outcomes');
    const contextIcons = [
      Icons.battery_charging_full,
      Icons.bolt,
      Icons.monitor_heart,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('ui.objTitle'),
          desc: _tx.s('mainObj'),
          accent: _rt_Tw.cyan600,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < missions.length; i++)
                _missionCard(i, missions[i] as Map),
              const SizedBox(height: 10),
              _rt_SectionLabel(
                _tx.s('tabs.context'),
                icon: Icons.lightbulb,
                color: _rt_Tw.cyan400,
              ),
              _rt_InfoCard(
                title: _tx.s('ui.whyTitle'),
                body: _tx.s('ui.whyBody'),
                icon: Icons.help_outline,
                color: _rt_Tw.cyan600,
              ),
              for (var i = 0; i < contextCards.length; i++)
                _rt_InfoCard(
                  title: (contextCards[i] as Map)['title'] as String,
                  body: (contextCards[i] as Map)['text'] as String,
                  icon: contextIcons[i],
                  color: _rt_Tw.cyan600,
                  leftBorder: true,
                ),
              _rt_SectionLabel(
                _tx.s('tabs.guide'),
                icon: Icons.co_present,
                color: _rt_Tw.indigo500,
              ),
              _rt_InfoCard(
                title: _tx.s('ui.conceptTitle'),
                body: _tx.s('ui.conceptBody'),
                icon: Icons.psychology,
                color: _rt_Tw.indigo500,
              ),
              for (final g in guide)
                _rt_InfoCard(
                  title: (g as Map)['phase'] as String,
                  color: _rt_Tw.indigo500,
                  leftBorder: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final s in g['steps'] as List)
                          _bullet(s as String, _rt_Tw.indigo500),
                      ],
                    ),
                  ),
                ),
              _rt_SectionLabel(
                _tx.s('tabs.analysis'),
                icon: Icons.flag,
                color: _rt_Tw.green500,
              ),
              _rt_InfoCard(
                title: _tx.s('ui.outcomesTitle'),
                color: _rt_Tw.green600,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final o in outcomes)
                        _bullet(o as String, _rt_Tw.green600),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.chevron_right, size: 14, color: color),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, height: 1.35, color: _rt_Lab.text),
          ),
        ),
      ],
    ),
  );

  /// Source `.step-card`: title + check circle, DO and FOCUS blocks.
  Widget _missionCard(int i, Map m) {
    final active = _mission == i;
    final done = _done[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: active
            ? _rt_Lab.tinted(const Color(0xFFECFEFF), _rt_Tw.cyan500)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('mission-$i'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => _setMission(i),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? _rt_Tw.cyan500 : _rt_Lab.border,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _rt_Lab.text,
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? _rt_Tw.green500 : Colors.transparent,
                        border: Border.all(
                          color: done
                              ? _rt_Tw.green500
                              : (active
                                    ? _rt_Tw.cyan400
                                    : _rt_Lab.borderStrong),
                          width: 2,
                        ),
                      ),
                      child: done
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _missionBlock(_tx.s('do'), _rt_Tw.cyan500, m['do'] as String),
                const SizedBox(height: 6),
                _missionBlock(
                  _tx.s('focus'),
                  _rt_Tw.orange500,
                  m['observe'] as String,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _missionBlock(String tag, Color color, String text) => Container(
    padding: const EdgeInsets.only(left: 8),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: color, width: 2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tag.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: _rt_Lab.onTinted(
              color,
              Color.lerp(color, Colors.black, 0.25)!,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            height: 1.35,
            color: _rt_Lab.textMuted,
          ),
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------ probe widget ---
class _ProbeBody extends StatelessWidget {
  const _ProbeBody({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 60,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 3),
              ],
            ),
          ),
          Container(width: 16, height: 4, color: color),
          CustomPaint(size: const Size(8, 14), painter: _ProbeTipPainter()),
        ],
      ),
    );
  }
}

class _ProbeTipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFCBD5E1));
  }

  @override
  bool shouldRepaint(covariant _ProbeTipPainter oldDelegate) => false;
}

// ------------------------------------------------------------ painter base ---
/// White grid background of the source's `#sim-canvas`.
void _paintGrid(Canvas c, Size s) {
  c.drawRect(Offset.zero & s, Paint()..color = Colors.white);
  final p = Paint()
    ..color = const Color(0xFFE2E8F0)
    ..strokeWidth = 1;
  for (double x = 0; x <= s.width; x += 40) {
    c.drawLine(Offset(x, 0), Offset(x, s.height), p);
  }
  for (double y = 0; y <= s.height; y += 40) {
    c.drawLine(Offset(0, y), Offset(s.width, y), p);
  }
}

/// Source drawLabel: dark slate pill with cyan border and white text.
void _paintLabel(Canvas c, Offset center, String text) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final r = RRect.fromRectAndRadius(
    Rect.fromCenter(center: center, width: tp.width + 14, height: 18),
    const Radius.circular(5),
  );
  c.drawRRect(r, Paint()..color = const Color(0xE61E293B));
  c.drawRRect(
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF22D3EE),
  );
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

void _paintText(
  Canvas c,
  Offset center,
  String text, {
  Color color = Colors.white,
  double size = 10,
  FontWeight weight = FontWeight.w800,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

// ------------------------------------------------------- zone 1: water tanks ---
class _Zone1Painter extends CustomPainter {
  _Zone1Painter({
    required Listenable repaint,
    required this.hA,
    required this.valveOpen,
    required this.morph,
    required this.flow,
    required this.turbine,
    required this.drops,
    required this.time,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final double hA;
  final bool valveOpen;
  final bool morph;
  final double flow;
  final double Function() turbine;
  final List<_FlowDrop> drops;
  final double Function() time;
  final bool showLabels;
  final Map<String, String> labels;

  @override
  void paint(Canvas c, Size s) {
    _paintGrid(c, s);
    final lift = hA * 0.5;
    final topA = 110.0 - lift;
    const topB = 110.0;
    final alpha = morph ? 0.25 : 1.0;

    // Tanks (faded to 25% in electricity morph mode, like the source).
    _tank(c, 50, topA, alpha);
    _tank(c, 380, topB, alpha);

    // Pipe from the base of Tank A down to Tank B.
    final start = Offset(85, topA + 138);
    const end = Offset(415, 248);
    final outer = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    final inner = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    c.drawLine(start, end, outer);
    c.drawLine(start, end, inner);

    // Water / charge particles inside the pipe.
    final t = time();
    final dir = (end - start) / (end - start).distance;
    final normal = Offset(-dir.dy, dir.dx);
    final dotPaint = Paint()
      ..color = morph ? const Color(0xFFFACC15) : Colors.white;
    for (var i = 0; i < drops.length; i++) {
      final d = drops[i];
      var pos = start + (end - start) * d.p + normal * (d.lane * 0.5);
      if (flow <= 0.1) {
        pos += Offset(
          math.sin(t * 5 + d.seed) * 2,
          math.cos(t * 4 + d.seed) * 2,
        );
      }
      c.drawCircle(pos, 3, dotPaint);
    }

    // Valve at the middle of the pipe.
    final mid = (start + end) / 2;
    c.save();
    c.translate(mid.dx, mid.dy);
    c.drawRect(
      const Rect.fromLTWH(-7, -18, 14, 36),
      Paint()..color = const Color(0xFF64748B),
    );
    c.drawCircle(
      const Offset(0, -18),
      10,
      Paint()
        ..color = valveOpen ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
    );
    c.restore();
    _paintText(
      c,
      mid + const Offset(0, -18),
      valveOpen ? 'ON' : 'OFF',
      size: 7,
    );

    // Turbine (load) a little downstream of the valve.
    final f = ((mid.dx + 48) - start.dx) / (end.dx - start.dx);
    final turbPos = start + (end - start) * f;
    c.save();
    c.translate(turbPos.dx, turbPos.dy);
    c.rotate(turbine());
    c.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFFDC2626));
    final blade = Paint()..color = const Color(0xFFEF4444);
    for (var i = 0; i < 4; i++) {
      c.rotate(math.pi / 2);
      c.drawRect(const Rect.fromLTWH(-3.5, -18, 7, 13), blade);
    }
    c.restore();

    // Electricity morph overlay: + and - terminals over the tanks.
    if (morph) {
      final aCenter = Offset(85, topA + 74);
      const bCenter = Offset(415, topB + 74);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white;
      c.drawCircle(aCenter, 30, Paint()..color = const Color(0xFFEF4444));
      c.drawCircle(aCenter, 30, stroke);
      _paintText(c, aCenter, '+', size: 34, weight: FontWeight.w900);
      c.drawCircle(bCenter, 30, Paint()..color = const Color(0xFF3B82F6));
      c.drawCircle(bCenter, 30, stroke);
      _paintText(c, bCenter, '-', size: 34, weight: FontWeight.w900);
    }

    if (showLabels) {
      _paintLabel(c, Offset(95, math.max(12, topA - 16)), labels['tankA']!);
      _paintLabel(c, const Offset(402, topB - 16), labels['tankB']!);
      _paintLabel(c, mid + const Offset(-52, -46), labels['switch']!);
      _paintLabel(c, mid + const Offset(-60, 36), labels['wire']!);
      _paintLabel(c, turbPos + const Offset(64, -30), labels['loadFan']!);
    }
  }

  /// Source drawTank: glass cylinder with a fixed-height water column.
  void _tank(Canvas c, double x, double top, double alpha) {
    final grad = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0EA5E9).withValues(alpha: alpha),
          const Color(0xFF0284C7).withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromLTWH(x, top, 70, 148));
    final body = RRect.fromLTRBAndCorners(
      x + 3,
      top + 12,
      x + 67,
      top + 146,
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );
    c.drawRRect(body, grad);
    // Water surface.
    c.drawOval(
      Rect.fromCenter(center: Offset(x + 35, top + 14), width: 62, height: 12),
      Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: alpha),
    );
    // Glass outline.
    final glass = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF94A3B8).withValues(alpha: alpha);
    c.drawRRect(
      RRect.fromLTRBAndCorners(
        x,
        top + 4,
        x + 70,
        top + 150,
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      ),
      glass,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(x + 35, top + 4), width: 70, height: 14),
      glass,
    );
  }

  @override
  bool shouldRepaint(covariant _Zone1Painter old) => true;
}

// ---------------------------------------------------- zone 2: chemical lift ---
class _Zone2Painter extends CustomPainter {
  _Zone2Painter({
    required Listenable repaint,
    required this.worker,
    required this.bags,
    required this.sweat,
    required this.charge,
    required this.time,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final _Worker worker;
  final List<bool> bags;
  final List<_Sweat> sweat;
  final double Function() charge;
  final double Function() time;
  final bool showLabels;
  final Map<String, String> labels;

  @override
  void paint(Canvas c, Size s) {
    _paintGrid(c, s);

    // Battery interior.
    const box = Rect.fromLTWH(120, 18, 260, 264);
    c.drawRect(box, Paint()..color = const Color(0xFFE2E8F0));
    c.drawRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF475569),
    );
    // Terminals.
    c.drawRect(
      const Rect.fromLTWH(120, 18, 260, 22),
      Paint()..color = const Color(0xFFEF4444),
    );
    _paintText(c, const Offset(250, 29), labels['posTerm']!, size: 9.5);
    c.drawRect(
      const Rect.fromLTWH(120, 260, 260, 22),
      Paint()..color = const Color(0xFF3B82F6),
    );
    _paintText(c, const Offset(250, 271), labels['negTerm']!, size: 9.5);

    // Ramp with tick marks.
    final ramp = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;
    c.drawLine(_rampBottom, _rampTop, ramp);
    final tick = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.6;
    for (var i = 1; i < 10; i++) {
      final p = _rampBottom + (_rampTop - _rampBottom) * (i / 10);
      c.drawLine(p + const Offset(-8, 0), p + const Offset(8, 0), tick);
    }

    // Charge bags waiting at the bottom pile.
    final bagFill = Paint()..color = const Color(0xFFF59E0B);
    final bagEdge = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFB45309);
    for (var i = 0; i < bags.length; i++) {
      if (!bags[i]) continue;
      final r = Rect.fromLTWH(
        126.0 + (i % 3) * 12,
        226.0 - (i ~/ 3) * 12,
        11,
        11,
      );
      c.drawRect(r, bagFill);
      c.drawRect(r, bagEdge);
    }
    // Accumulated bags at the + terminal.
    final n = math.min(charge(), 20).toInt();
    for (var i = 0; i < n; i++) {
      final r = Rect.fromLTWH(
        330.0 + (i % 5) * 12,
        52.0 - (i ~/ 5) * 12,
        11,
        11,
      );
      c.drawRect(r, bagFill);
      c.drawRect(r, bagEdge);
    }

    _paintLabel(c, const Offset(250, 205), labels['gradient']!);

    // Sweat drops.
    final sweatPaint = Paint()..color = const Color(0xFF3B82F6);
    for (final drop in sweat) {
      c.drawCircle(Offset(drop.x, drop.y), 2, sweatPaint);
    }

    _drawWorker(c);

    if (showLabels && worker.state == 'lifting') {
      _paintLabel(c, Offset(worker.x, worker.y - 54), labels['doingWork']!);
    }
  }

  void _drawWorker(Canvas c) {
    final carrying = worker.state == 'lifting' || worker.state == 'depositing';
    c.save();
    c.translate(worker.x, worker.y);
    if (worker.state == 'lifting') c.rotate(0.15);

    final walk = math.sin(time() * 9);
    final legs = Paint()..color = const Color(0xFF0F172A);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-6, 4, 5, 15 + walk * 3),
        const Radius.circular(2),
      ),
      legs,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 4, 5, 15 - walk * 3),
        const Radius.circular(2),
      ),
      legs,
    );
    // Torso.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -20, 16, 26),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    // Head.
    final skin = Paint()..color = const Color(0xFFFCA5A5);
    c.drawCircle(const Offset(0, -26), 7, skin);
    // Back arm.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -15, 6, 18),
        const Radius.circular(3),
      ),
      skin,
    );
    if (carrying) {
      // Charge bag held overhead.
      const bag = Rect.fromLTWH(-5.5, -42, 11, 11);
      c.drawRect(bag, Paint()..color = const Color(0xFFF59E0B));
      c.drawRect(
        bag,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFB45309),
      );
      _paintText(
        c,
        const Offset(0, -36.5),
        '+Q',
        color: Colors.black,
        size: 6.5,
      );
      // Front arm raised.
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, -26, 6, 15),
          const Radius.circular(3),
        ),
        skin,
      );
    } else {
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, -15, 6, 18),
          const Radius.circular(3),
        ),
        skin,
      );
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _Zone2Painter old) => true;
}

// --------------------------------------------------- zone 3: parallel probe ---
class _Zone3Painter extends CustomPainter {
  _Zone3Painter({
    required Listenable repaint,
    required this.connection,
    required this.reading,
    required this.redPos,
    required this.blackPos,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final String connection;
  final String reading;
  final Offset redPos;
  final Offset blackPos;
  final bool showLabels;
  final Map<String, String> labels;

  @override
  void paint(Canvas c, Size s) {
    _paintGrid(c, s);
    final isSeries = connection == 'series';
    final bulbOn = !isSeries;

    // Top wire (turns red when a probe breaks it in series).
    _wire(
      c,
      const Offset(210, 60),
      const Offset(440, 60),
      outerColor: isSeries ? const Color(0xFFEF4444) : const Color(0xFFB45309),
    );
    // Side wires and the bulb branch.
    _wire(c, const Offset(210, 60), const Offset(210, 240));
    _wire(c, const Offset(440, 60), const Offset(440, 240));
    _wire(c, const Offset(210, 240), const Offset(300, 240));
    _wire(c, const Offset(340, 240), const Offset(440, 240));

    // Battery on the top wire.
    c.drawRect(
      const Rect.fromLTWH(295, 45, 60, 30),
      Paint()..color = const Color(0xFF222222),
    );
    c.drawRect(
      const Rect.fromLTWH(315, 45, 5, 30),
      Paint()..color = const Color(0xFFF97316),
    );
    _paintText(c, const Offset(337, 60), '1.5V', size: 8.5);

    // Bulb: glow when the circuit is intact.
    c.drawRect(
      const Rect.fromLTWH(305, 240, 30, 16),
      Paint()..color = const Color(0xFF94A3B8),
    );
    const bulbCenter = Offset(320, 214);
    if (bulbOn) {
      c.drawCircle(
        bulbCenter,
        38,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFF00), Color(0x00FFFF00)],
            stops: [0.0, 0.35, 1.0],
          ).createShader(Rect.fromCircle(center: bulbCenter, radius: 38)),
      );
    } else {
      c.drawCircle(bulbCenter, 22, Paint()..color = const Color(0x1FFFFFFF));
    }
    c.drawCircle(
      bulbCenter,
      22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF94A3B8),
    );

    // Probe targets: cyan = parallel (correct), red = series (wrong).
    final cyanDot = Paint()..color = const Color(0xFF22D3EE);
    final redDot = Paint()..color = const Color(0xFFEF4444);
    c.drawCircle(_probeSpots['pL']!, 6, cyanDot);
    c.drawCircle(_probeSpots['pR']!, 6, cyanDot);
    c.drawCircle(_probeSpots['sL']!, 6, redDot);
    c.drawCircle(_probeSpots['sR']!, 6, redDot);

    // Voltmeter body + LCD reading.
    final meter = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15, 35, 120, 175),
      const Radius.circular(10),
    );
    c.drawRRect(meter, Paint()..color = const Color(0xFFFACC15));
    c.drawRRect(
      meter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFB45309),
    );
    c.drawRect(
      const Rect.fromLTWH(28, 52, 94, 50),
      Paint()..color = const Color(0xFF334155),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: reading,
        style: const TextStyle(
          color: Color(0xFFA3E635),
          fontSize: 26,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(112 - tp.width, 63));
    _paintText(
      c,
      const Offset(120, 80),
      'V',
      color: const Color(0xFFA3E635),
      size: 13,
    );

    // Probe cables from the voltmeter to wherever each probe sits.
    _cable(c, const Offset(55, 208), redPos, const Color(0xFFEF4444));
    _cable(c, const Offset(95, 208), blackPos, const Color(0xFF1E293B));

    if (showLabels) {
      _paintLabel(c, const Offset(325, 28), labels['sourceBatt']!);
      _paintLabel(c, const Offset(320, 178), labels['loadBulb']!);
      _paintLabel(c, const Offset(75, 22), labels['voltmeter']!);
      _paintText(
        c,
        const Offset(440, 262),
        labels['parallel']!,
        color: const Color(0xFF0891B2),
        size: 10,
      );
      _paintText(
        c,
        const Offset(210, 40),
        labels['seriesBad']!,
        color: const Color(0xFFEF4444),
        size: 10,
      );
    }
  }

  void _wire(
    Canvas c,
    Offset a,
    Offset b, {
    Color outerColor = const Color(0xFFB45309),
  }) {
    c.drawLine(
      a,
      b,
      Paint()
        ..color = outerColor
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    c.drawLine(
      a,
      b,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _cable(Canvas c, Offset from, Offset probeTip, Color color) {
    final target = probeTip - const Offset(0, 52);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx,
        from.dy + 60,
        target.dx,
        target.dy - 60,
        target.dx,
        target.dy,
      );
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _Zone3Painter old) => true;
}

// -------------------------------------------------------------- toolbar bits ---
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
            color: active ? _rt_Tw.cyan500 : _rt_Lab.surface,
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
