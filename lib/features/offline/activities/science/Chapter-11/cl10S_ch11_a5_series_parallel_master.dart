// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 11.5: Series & Parallel Master
// Converted from Cl10S-Ch11-A5-SeriesParallelMaster.html (canvas-2D circuit
// simulator -> CustomPainter workbench + widget overlays).
//
// A circuit-building bench with the source's iterative node-voltage relaxation
// solver (25 sweeps per frame, same component resistances: wire 0.05 Ω, switch
// 0.05/1e8 Ω, battery 0.5 Ω internal + V source, bulb 5/1e8 Ω, resistor 5 Ω).
// Three mission zones - Zone 1 fairy chain (series bulbs: dim glow, one break
// kills all), Zone 2 smart home (parallel bulbs: bright, independent branches,
// main/branch wire currents), Zone 3 resistance puzzle (series vs parallel
// resistors with the live Req math panel). Components are added from the
// palette, dragged on the canvas with node snapping, tapped to select /
// toggle / break / inspect; sidebar buttons mirror the break / inspect taps.
// The wiring itself is always done by the student (QA C10-11.5-01).

// --- TRANSLATION DATA (source `CONTENT`, `te:` block dropped) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
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
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo900 = Color(0xFF312E81);
  static const violet500 = Color(0xFF8B5CF6);
  static const red500 = Color(0xFFEF4444);
  static const orange500 = Color(0xFFF97316);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const yellow400 = Color(0xFFFACC15);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const emerald500 = Color(0xFF10B981);
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
    this.icon = Icons.gps_fixed,
  });

  final String title;
  final String desc;
  final Color accent;
  final IconData icon;
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
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag = null;
  final Color color;
  final IconData? icon;
  final Widget? child;
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

/// HUD read-out card shown over the 3D view (the HTML `.hud-card`).
class _rt_HudCard extends StatelessWidget {
  const _rt_HudCard({
    required this.value,
    required this.label,
    this.color = _rt_Tw.teal700,
    this.minWidth = 90,
  });

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
  const _rt_StepHint({required this.number, required this.text, this.label});

  final String number;
  final String text;
  final String? label;
}

/// Lets an activity show toasts and popups through the shell.
class _rt_ShellController {
  _ActivityShellState? _state;

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
    this.canvasOverlays = const [],
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
    _curtain.dispose();
    _introContent.dispose();
    _rt_SoundService.instance.stop(_rt_Sfx.curtain);
    super.dispose();
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
    'title': 'SERIES & PARALLEL MASTER',
    'subtitle': 'Class 10 • Electricity',
    'intro': {
      'button': 'Enter _rt_Lab',
      'footnote': 'Series • Parallel • Resistance',
    },
    'mainObjTitle': 'Main Objective',
    'objDesc':
        'Investigate how component arrangement changes Current (I), Voltage (V), and Total Resistance (R).',
    'do': 'DO',
    'observe': 'OBSERVE',
    'controls': 'Controls',
    'voltage': 'Voltage',
    'load': 'Total Current',
    'bill': 'Resistance',
    'thermal': 'THERMAL',
    'realistic': 'REALISTIC',
    'schematic': 'SCHEMATIC',
    'stepOf': 'Step {a} of {b}',
    'tabs': {'explore': 'Explore'},
    'obsModal': {
      'title': 'Observation',
      'learned': 'What we learned:',
      'prev': 'Prev Step',
      'next': 'Next Step',
    },
    'successModal': {
      'title': 'Simulation Complete!',
      'body':
          'You have successfully mastered the concepts of Series and Parallel circuits.',
      'close': 'Close',
      'restart': 'Restart _rt_Lab',
    },
    'ui': {
      'delete': 'Delete',
      'currentAction': 'Current Action',
      'thermalMsg':
          'Thermal View ON: visualizes heat generation. Use this to identify components drawing too much current.',
      'resCalc': 'Resistance Calculation',
      'addRes': 'Add more resistors to see calculation.',
      'atomicTitle': 'ATOMIC VIEW',
      'atomicDesc': 'Visualizing electron collisions.',
      'finish': 'Finish',
      'series': 'SERIES',
      'parallel': 'PARALLEL',
      'currLow': 'Current LOW',
      'currHigh': 'Current HIGH',
      'req': 'Req',
      'break': 'Break',
      'repair': 'Repair',
      'selection': 'Selection',
      'breakBulb': 'Break a Bulb',
      'inspectNext': 'Inspect Component',
      'labelsToggle': 'Show / Hide Labels',
      'palette': 'Parts',
      'current': 'Current',
      'voltageLbl': 'Voltage',
      'power': 'Power',
      'main': 'MAIN',
      'branch': 'BRANCH',
      'mainWire': 'MAIN WIRE',
      'branchWire': 'BRANCH WIRE',
    },
    'components': {
      'wire': 'Wire',
      'battery': 'Battery',
      'switch': 'Switch',
      'bulb': 'Bulb',
      'resistor': 'Resistor',
    },
    'notes': {
      'whyLearn': 'Why Learn?',
      'guide': "Teacher's Guide",
      'outcomes': 'Outcomes',
      'outcomesTitle': 'Simulation Outcomes',
    },
    'context': [
      {
        'title': 'Understanding Circuits',
        'text':
            'Why learn this? Knowing how circuits work helps us understand how our homes are powered and how electronic devices function safely.',
      },
      {
        'title': 'Series Circuit Example',
        'text':
            'Old decorative fairy lights. One bulb breaks, the whole string goes dark!',
      },
      {
        'title': 'Parallel Circuit Example',
        'text':
            "Your home wiring. Turning off the kitchen light doesn't turn off the TV.",
      },
      {
        'title': 'Car Headlights',
        'text':
            'Connected in parallel so if one headlight fails, you can still see the road.',
      },
    ],
    'teacherGuide': [
      {
        'phase': 'MAIN GOAL',
        'steps': [
          'Students should intuitively understand the difference between Series (Voltage Split) and Parallel (Current Split) circuits.',
        ],
      },
      {
        'phase': 'Zone 1: Series Circuits',
        'steps': [
          'Students observe that adding bulbs in series dims them.',
          "Demonstrate the 'all-or-nothing' nature of series circuits.",
        ],
      },
      {
        'phase': 'Zone 2: Parallel Circuits',
        'steps': [
          'Students see that parallel bulbs stay bright.',
          'Show that branches act independently.',
        ],
      },
      {
        'phase': 'Zone 3: Resistance Math',
        'steps': [
          'Visual proof that Parallel lowers total resistance, while Series increases it.',
        ],
      },
    ],
    'outcomes': [
      'We learned that in a Series circuit, Voltage divides among components, causing bulbs to glow dimmer as more are added.',
      'We achieved the understanding that Series circuits have a single point of failure; if one component breaks, the entire circuit stops.',
      'We learned that in a Parallel circuit, every branch receives the full battery Voltage, so all bulbs glow brightly regardless of how many are added.',
      'We observed that Parallel branches operate independently; breaking one bulb does not affect the others, which is ideal for home wiring.',
      'We calculated that Series connection increases Total Resistance (Req = R1 + R2), resulting in lower total current flow.',
      'We calculated that Parallel connection decreases Total Resistance (1/Req = 1/R1 + 1/R2), allowing for higher total current flow.',
    ],
    'missions': [
      {
        'title': 'Zone 1: The Fairy Chain (Series)',
        'steps': [
          {
            'action':
                'Drag Battery, Switch, and 3 Bulbs. Connect them in a single loop (Series).',
            'observe': 'All 3 bulbs glow dimly because Voltage (V) splits.',
            'learn':
                'In series, voltage is shared (V_total = V1+V2+V3), making bulbs dim.',
          },
          {
            'action': 'Click directly on any bulb to Break it.',
            'observe':
                'The broken bulb goes black. Crucially, ALL other bulbs go black too.',
            'learn':
                'One failure breaks the entire circuit. Current stops everywhere.',
          },
          {
            'action':
                'Click on each bulb to see its details in a large tooltip.',
            'observe': 'Voltage across broken bulb = Source. Others = 0V.',
            'learn':
                'The break acts as infinite resistance, taking all voltage.',
          },
        ],
      },
      {
        'title': 'Zone 2: The Smart Home (Parallel)',
        'steps': [
          {
            'action':
                'Connect Battery -> 3 Bulbs. Each bulb needs its own wire loop to the battery.',
            'observe': 'Bulbs connect to battery directly. They glow bright!',
            'learn':
                'In parallel, each branch gets full voltage. Current divides.',
          },
          {
            'action': 'Click any bulb to Break it.',
            'observe':
                'Only the broken bulb turns off. Others stay ON and BRIGHT.',
            'learn':
                "Branches are independent. This is why house lights don't all fail at once.",
          },
          {
            'action':
                "Inspect the wires. We've highlighted the Main vs Branch wires. Click them!",
            'observe':
                'Main wire has high current. Branches have lower current.',
            'learn': 'I_total = I1 + I2 + I3. Current splits at junctions.',
          },
        ],
      },
      {
        'title': 'Zone 3: Resistance Puzzle',
        'steps': [
          {
            'action': 'Connect 2 Resistors end-to-end (Series) to the Battery.',
            'observe': 'Traffic Jam! Current is very low.',
            'learn': 'Series: R_eq = R1 + R2 (10Ω). Max Resistance.',
          },
          {
            'action':
                'Connect 2 Resistors side-by-side (Parallel) to the Battery.',
            'observe': 'Highway Expansion! Current is very high.',
            'learn':
                'Parallel: R_eq = 2.5Ω. Min Resistance (less than smallest resistor).',
          },
        ],
      },
    ],
  },
  'hi': {
    'title': 'श्रृंखला और समानांतर मास्टर',
    'subtitle': 'कक्षा 10 • विद्युत',
    'intro': {
      'button': 'लैब में प्रवेश करें',
      'footnote': 'श्रेणीक्रम • पार्श्वक्रम • प्रतिरोध',
    },
    'mainObjTitle': 'मुख्य उद्देश्य',
    'objDesc':
        'जांच करें कि घटक व्यवस्था कैसे करंट (I), वोल्टेज (V), और कुल प्रतिरोध (R) को बदलती है।',
    'do': 'करें',
    'observe': 'देखें',
    'controls': 'नियंत्रण',
    'voltage': 'वोल्टेज',
    'load': 'कुल करंट',
    'bill': 'प्रतिरोध',
    'thermal': 'थर्मल',
    'realistic': 'वास्तविक',
    'schematic': 'योजनाबद्ध',
    'stepOf': 'चरण {a} / {b}',
    'tabs': {'explore': 'अन्वेषण'},
    'obsModal': {
      'title': 'अवलोकन',
      'learned': 'हमने क्या सीखा:',
      'prev': 'पीछे',
      'next': 'आगे',
    },
    'successModal': {
      'title': 'सिमुलेशन पूर्ण!',
      'body':
          'आपने श्रृंखला और समानांतर सर्किट की अवधारणाओं में महारत हासिल कर ली है।',
      'close': 'बंद करें',
      'restart': 'लैब पुनरारंभ करें',
    },
    'ui': {
      'delete': 'हटाएं',
      'currentAction': 'वर्तमान कार्य',
      'thermalMsg':
          'थर्मल व्यू चालू: गर्मी उत्पादन को विज़ुअलाइज़ करता है। इसका उपयोग उन घटकों को पहचानने के लिए करें जो बहुत अधिक करंट खींच रहे हैं।',
      'resCalc': 'प्रतिरोध गणना',
      'addRes': 'गणना देखने के लिए और प्रतिरोधक जोड़ें।',
      'atomicTitle': 'परमाणु दृश्य',
      'atomicDesc': 'इलेक्ट्रॉन टकराव की कल्पना।',
      'finish': 'समाप्त',
      'series': 'श्रृंखला',
      'parallel': 'समानांतर',
      'currLow': 'करंट कम',
      'currHigh': 'करंट उच्च',
      'req': 'कुल प्रतिरोध',
      'break': 'तोड़ें',
      'repair': 'मरम्मत करें',
      'selection': 'चयन',
      'breakBulb': 'एक बल्ब तोड़ें',
      'inspectNext': 'घटक का निरीक्षण करें',
      'labelsToggle': 'लेबल दिखाएँ / छिपाएँ',
      'palette': 'घटक',
      'current': 'धारा',
      'voltageLbl': 'वोल्टेज',
      'power': 'शक्ति',
      'main': 'मुख्य',
      'branch': 'शाखा',
      'mainWire': 'मुख्य तार',
      'branchWire': 'शाखा तार',
    },
    'components': {
      'wire': 'तार',
      'battery': 'बैटरी',
      'switch': 'स्विच',
      'bulb': 'बल्ब',
      'resistor': 'प्रतिरोधक',
    },
    'notes': {
      'whyLearn': 'यह क्यों सीखें?',
      'guide': 'शिक्षक मार्गदर्शिका',
      'outcomes': 'परिणाम',
      'outcomesTitle': 'सिमुलेशन परिणाम',
    },
    'context': [
      {
        'title': 'सर्किट को समझना',
        'text':
            'यह क्यों सीखें? यह जानने से हमें यह समझने में मदद मिलती है कि हमारे घर कैसे संचालित होते हैं।',
      },
      {
        'title': 'श्रृंखला सर्किट उदाहरण',
        'text':
            'पुरानी सजावटी रोशनी। एक बल्ब टूटता है, पूरी लड़ी काली हो जाती है!',
      },
      {
        'title': 'समानांतर सर्किट उदाहरण',
        'text':
            'आपके घर की वायरिंग। रसोई की लाइट बंद करने से टीवी बंद नहीं होता।',
      },
      {
        'title': 'कार हेडलाइट्स',
        'text':
            'समानांतर में जुड़े हुए ताकि एक हेडलाइट खराब हो जाए, तो भी आप सड़क देख सकें।',
      },
    ],
    'teacherGuide': [
      {
        'phase': 'मुख्य लक्ष्य',
        'steps': [
          'छात्रों को श्रृंखला (वोल्टेज विभाजन) और समानांतर (करंट विभाजन) सर्किट के बीच अंतर को सहजता से समझना चाहिए।',
        ],
      },
      {
        'phase': 'ज़ोन 1: श्रृंखला सर्किट',
        'steps': [
          'छात्र देखते हैं कि श्रृंखला में बल्ब जोड़ने से वे मंद हो जाते हैं।',
          "श्रृंखला सर्किट की 'सब कुछ या कुछ नहीं' प्रकृति का प्रदर्शन करें।",
        ],
      },
      {
        'phase': 'ज़ोन 2: समानांतर सर्किट',
        'steps': [
          'छात्र देखते हैं कि समानांतर बल्ब उज्ज्वल रहते हैं।',
          'दिखाएं कि शाखाएं स्वतंत्र रूप से कार्य करती हैं।',
        ],
      },
      {
        'phase': 'ज़ोन 3: प्रतिरोध गणित',
        'steps': [
          'दृश्य प्रमाण कि समानांतर कुल प्रतिरोध को कम करता है, जबकि श्रृंखला इसे बढ़ाती है।',
        ],
      },
    ],
    'outcomes': [
      'हमने सीखा कि सीरीज (श्रृंखला) सर्किट में, वोल्टेज घटकों के बीच विभाजित हो जाता है, जिसके कारण जैसे-जैसे अधिक बल्ब जोड़े जाते हैं, वे मंद (धीमे) जलने लगते हैं।',
      'हमने यह समझा कि सीरीज सर्किट में विफलता का एक ही बिंदु होता है; यदि एक घटक (component) खराब हो जाता है या टूट जाता है, तो पूरा सर्किट काम करना बंद कर देता है।',
      'हमने सीखा कि समानांतर (Parallel) सर्किट में, प्रत्येक शाखा (branch) को पूरी बैटरी वोल्टेज मिलती है, इसलिए चाहे कितने भी बल्ब जोड़े जाएं, सभी बल्ब तेज चमकते हैं।',
      'हमने देखा कि समानांतर शाखाएं स्वतंत्र रूप से काम करती हैं; एक बल्ब के टूटने या खराब होने से दूसरों पर कोई प्रभाव नहीं पड़ता, जो घरेलू वायरिंग के लिए आदर्श है।',
      'हमने गणना की कि सीरीज कनेक्शन कुल प्रतिरोध (Total Resistance) को बढ़ाता है (Req = R1 + R2), जिसके परिणामस्वरूप कुल करंट का प्रवाह कम हो जाता है।',
      'हमने गणना की कि समानांतर कनेक्शन कुल प्रतिरोध को कम करता है (1/Req = 1/R1 + 1/R2), जिससे उच्च कुल करंट प्रवाह की अनुमति मिलती है।',
    ],
    'missions': [
      {
        'title': 'चरण 1: परी श्रृंखला (श्रेणीक्रम)',
        'steps': [
          {
            'action':
                'श्रृंखला सर्किट बनाएं: बैटरी + स्विच + 3 बल्ब। स्विच ऑन करें।',
            'observe': 'सभी 3 बल्ब मंद चमकते हैं। करंट एक रास्ते में बहता है।',
            'learn': 'श्रृंखला में वोल्टेज बंट जाता है।',
          },
          {
            'action': 'तोड़ने के लिए सीधे किसी भी बल्ब पर क्लिक करें।',
            'observe':
                'टूटा हुआ बल्ब काला हो जाता है। अन्य सभी भी बंद हो जाते हैं।',
            'learn': 'एक विफलता पूरे सर्किट को रोक देती है।',
          },
          {
            'action': 'विवरण देखने के लिए प्रत्येक बल्ब पर क्लिक करें।',
            'observe': 'टूटे हुए बल्ब पर पूरा वोल्टेज है। अन्य = 0V।',
            'learn': 'टूटा हुआ हिस्सा अनंत प्रतिरोध की तरह कार्य करता है।',
          },
        ],
      },
      {
        'title': 'चरण 2: स्मार्ट होम (पार्श्वक्रम)',
        'steps': [
          {
            'action':
                'समानांतर सर्किट बनाएं: बैटरी + 3 बल्ब। प्रत्येक बल्ब का अपना तार लूप होना चाहिए।',
            'observe': 'बल्ब सीधे बैटरी से जुड़ते हैं। वे तेज चमकते हैं!',
            'learn': 'समानांतर में, प्रत्येक शाखा को पूरा वोल्टेज मिलता है।',
          },
          {
            'action': 'तोड़ने के लिए किसी भी बल्ब पर क्लिक करें।',
            'observe': 'केवल टूटा हुआ बल्ब बंद होता है। अन्य चालू रहते हैं।',
            'learn':
                'शाखाएँ स्वतंत्र हैं। घर की लाइटें एक साथ खराब नहीं होतीं।',
          },
          {
            'action':
                'तारों का निरीक्षण करें। मुख्य बनाम शाखा तारों पर क्लिक करें!',
            'observe': 'मुख्य तार में उच्च करंट है। शाखाओं में कम करंट है।',
            'learn': 'करंट जंक्शनों पर विभाजित होता है (I_total = I1+I2)।',
          },
        ],
      },
      {
        'title': 'चरण 3: प्रतिरोध पहेली',
        'steps': [
          {
            'action': 'बैटरी से 2 प्रतिरोधक (श्रृंखला) कनेक्ट करें।',
            'observe': 'ट्रैफ़िक जाम! करंट बहुत कम है।',
            'learn': 'श्रृंखला: अधिकतम प्रतिरोध (R1 + R2)।',
          },
          {
            'action': 'बैटरी से 2 प्रतिरोधक (समानांतर) कनेक्ट करें।',
            'observe': 'राजमार्ग विस्तार! करंट बहुत अधिक है।',
            'learn': 'समानांतर: न्यूनतम प्रतिरोध।',
          },
        ],
      },
    ],
  },
});

// ------------------------------------------------------------------ model ---

enum _CompType { wire, battery, sw, bulb, resistor }

class _Node {
  _Node(this.x, this.y);
  double x, y;
  double voltage = 0;
}

/// One circuit element between two nodes (the source `Component`).
class _Comp {
  _Comp(this.type, double x, double y)
    : n1 = _Node(x, y),
      n2 = _Node(x + 80, y);

  final _CompType type;
  _Node n1, n2;
  double value = 6; // battery EMF
  double current = 0, power = 0;
  bool isBlown = false, isOpen = false;

  /// Source `getResistance()`.
  double get resistance => switch (type) {
    _CompType.wire => 0.05,
    _CompType.sw => isOpen ? 1e8 : 0.05,
    _CompType.battery => 0.5,
    _CompType.bulb => isBlown ? 1e8 : 5.0,
    _CompType.resistor => 5.0,
  };

  double get sourceV => type == _CompType.battery ? value : 0;

  /// Key into the `components` translation map.
  String get txKey => type == _CompType.sw ? 'switch' : type.name;
}

class _DragState {
  _DragState.node(this.node)
    : comp = null,
      off1 = Offset.zero,
      off2 = Offset.zero;
  _DragState.comp(this.comp, this.off1, this.off2) : node = null;

  final _Node? node;
  final _Comp? comp;
  final Offset off1, off2;
}

// ------------------------------------------------------------------- page ---

class Cl10SCh11A5SeriesParallelMasterPage extends StatefulWidget {
  const Cl10SCh11A5SeriesParallelMasterPage({super.key});

  @override
  State<Cl10SCh11A5SeriesParallelMasterPage> createState() =>
      _Cl10SCh11A5SeriesParallelMasterPageState();
}

class _Cl10SCh11A5SeriesParallelMasterPageState
    extends State<Cl10SCh11A5SeriesParallelMasterPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();

  // Circuit.
  final List<_Comp> _comps = [];
  final List<_Node> _nodes = [];
  _Comp? _sel;
  _DragState? _drag;

  // Viewport (the source only zooms, never pans).
  double _zoom = 1.0;
  Size _canvasSize = Size.zero;

  // Mission state.
  int _zone = 0, _step = 0;
  final Set<String> _missionDone = {};
  bool _inspected = false;
  bool _started = false;
  bool _dialogOpen = false;

  // Controls.
  double _voltage = 6;
  bool _thermal = false;
  bool _schematic = false;
  bool _showLabels = true;

  // Aggregated simulation state (source `simulationState`).
  double _totalCurrent = 0;
  int _bulbs = 0, _resistors = 0;
  bool _isSeries = false, _hasBroken = false;

  // Big tooltip.
  _Comp? _tip;
  Offset _tipPos = Offset.zero;
  int _inspectIdx = 0;

  // Non-modal observation card of the inspect steps (QA C10-11.5-02).
  bool _obsCard = false;
  Offset _obsOffset = Offset.zero;
  final GlobalKey _obsKey = GlobalKey();

  double _time = 0;
  String _hudSig = '';

  late final AnimationController _clock =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..addListener(_tick)
        ..repeat();

  static const List<int> _stepsPerZone = [3, 3, 2];

  List<dynamic> get _missions => _tx.list('missions');
  Map<String, dynamic> _stepData(int z, int s) =>
      ((_missions[z] as Map)['steps'] as List)[s] as Map<String, dynamic>;

  String _key(int z, int s) => 'z${z}_s$s';
  bool get _isLastStep => _zone == 2 && _step == _stepsPerZone[2] - 1;
  bool get _isBreakStep => (_zone == 0 || _zone == 1) && _step == 1;
  bool get _isInspectStep => (_zone == 0 || _zone == 1) && _step == 2;

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
    _clock.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- physics ---

  /// The source's per-frame loop: 25 relaxation sweeps, then aggregates.
  void _tick() {
    _time += 0.016;
    if (_comps.isNotEmpty) {
      for (var k = 0; k < 25; k++) {
        for (final n in _nodes) {
          var num = 0.0, den = 0.0;
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
              final target = other.voltage + c.sourceV * (isN1 ? -1 : 1);
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
    }

    var totalP = 0.0;
    var bulbs = 0, resistors = 0;
    var hasBroken = false;
    final degrees = <_Node, int>{};
    for (final c in _comps) {
      final v = (c.n2.voltage - c.n1.voltage - c.sourceV).abs();
      c.current = v / c.resistance;
      c.power = c.current * c.current * c.resistance;
      if (c.type == _CompType.bulb) bulbs++;
      if (c.type == _CompType.resistor) resistors++;
      if (c.type == _CompType.bulb && c.isBlown) hasBroken = true;
      if (c.type == _CompType.battery) totalP += c.current.abs();
      degrees[c.n1] = (degrees[c.n1] ?? 0) + 1;
      degrees[c.n2] = (degrees[c.n2] ?? 0) + 1;
    }
    var maxDegree = 0;
    for (final d in degrees.values) {
      maxDegree = math.max(maxDegree, d);
    }
    _totalCurrent = totalP;
    _bulbs = bulbs;
    _resistors = resistors;
    _hasBroken = hasBroken;
    _isSeries = maxDegree <= 2;

    // Mission check (source `setInterval` watcher).
    if (_started && !_dialogOpen) {
      final key = _key(_zone, _step);
      if (!_missionDone.contains(key) && _checkStep(_zone, _step)) {
        _missionDone.add(key);
        _rt_playSfx(_rt_Sfx.correct);
        if (mounted) setState(() {});
        _showObservation();
      }
    }

    // Rebuild HUD widgets only when a displayed value changes.
    final sig =
        '${_hudCurrent()}|${_hudResistance()}|$_bulbs|$_resistors|'
        '$_isSeries|$_hasBroken|${_selStats() ?? ''}|${_tipSig()}';
    if (sig != _hudSig) {
      _hudSig = sig;
      if (mounted) setState(() {});
    }
  }

  bool _checkStep(int z, int s) {
    final t = _totalCurrent;
    switch (z) {
      case 0:
        return switch (s) {
          0 => _bulbs >= 3 && _isSeries && t > 0,
          1 => _hasBroken && t < 0.001,
          _ => _inspected,
        };
      case 1:
        return switch (s) {
          0 => _bulbs >= 3 && !_isSeries && t > 0,
          1 => _bulbs >= 3 && !_isSeries && _hasBroken && t > 0,
          _ => _inspected,
        };
      default:
        return switch (s) {
          0 => _resistors >= 2 && _isSeries && t > 0,
          _ => _resistors >= 2 && !_isSeries && t > 1.0,
        };
    }
  }

  String _hudCurrent() => _totalCurrent.toStringAsFixed(2);
  String _hudResistance() => _totalCurrent > 0.01
      ? (_voltage / _totalCurrent).toStringAsFixed(1)
      : '∞';

  String? _selStats() {
    final s = _sel;
    if (s == null) return null;
    final vDrop = (s.n1.voltage - s.n2.voltage).abs().toStringAsFixed(2);
    final r = s.resistance > 1000 ? '∞' : s.resistance.toStringAsFixed(1);
    return 'V: ${vDrop}V   I: ${s.current.toStringAsFixed(2)}A   R: $rΩ';
  }

  String _tipSig() {
    final t = _tip;
    if (t == null) return '';
    return '${t.current.toStringAsFixed(2)}|${(t.n1.voltage - t.n2.voltage).abs().toStringAsFixed(2)}';
  }

  // ------------------------------------------------------------- building ---

  /// Palette tap: add a component at the canvas centre (source `addComponent`).
  void _addComp(_CompType t) {
    if (_canvasSize == Size.zero) return;
    final j = (_comps.length % 5) * 14.0;
    final cx = _canvasSize.width / 2 / _zoom,
        cy = _canvasSize.height / 2 / _zoom;
    final c = _Comp(t, cx - 40 + j, cy + j)..value = _voltage.roundToDouble();
    _comps.add(c);
    _nodes.add(c.n1);
    _nodes.add(c.n2);
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {});
  }

  // ------------------------------------------------------------- gestures ---

  Offset _toWorld(Offset local) => Offset(local.dx / _zoom, local.dy / _zoom);

  _Comp? _hitComp(Offset w, double thresh) {
    _Comp? hit;
    for (final c in _comps) {
      final dx = c.n2.x - c.n1.x, dy = c.n2.y - c.n1.y;
      final l2 = dx * dx + dy * dy;
      var t = l2 == 0
          ? 0.0
          : ((w.dx - c.n1.x) * dx + (w.dy - c.n1.y) * dy) / l2;
      t = t.clamp(0.0, 1.0);
      final px = c.n1.x + t * dx, py = c.n1.y + t * dy;
      final d = math.sqrt(math.pow(w.dx - px, 2) + math.pow(w.dy - py, 2));
      if (d < thresh) hit = c;
    }
    return hit;
  }

  void _onTapUp(TapUpDetails d) {
    final world = _toWorld(d.localPosition);
    final thresh = 20 / _zoom;
    _tip = null;
    final c = _hitComp(world, thresh);
    if (c == null) {
      setState(() => _sel = null);
      return;
    }
    _sel = c;
    var played = false;
    // Zone 1/2 step 2: tap a bulb to break it.
    if (_isBreakStep && c.type == _CompType.bulb && !c.isBlown) {
      c.isBlown = true;
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() {});
      return;
    }
    // Zone 1/2 step 3: tap components to inspect them.
    if (_isInspectStep) {
      _inspected = true;
      _tip = c;
      _tipPos = d.localPosition;
      _rt_playSfx(_rt_Sfx.tap);
      played = true;
    }
    if (c.type == _CompType.sw) {
      c.isOpen = !c.isOpen;
      _rt_playSfx(_rt_Sfx.toggle);
      played = true;
    }
    if (c.type == _CompType.wire && _zone != 1) {
      _openAtomicView();
      played = true;
    }
    if (!played) _rt_playSfx(_rt_Sfx.tap);
    setState(() {});
  }

  void _onPanStart(DragStartDetails d) {
    final world = _toWorld(d.localPosition);
    final thresh = 20 / _zoom;
    _Node? hitN;
    var minD = 100.0;
    for (final n in _nodes) {
      final dist = math.sqrt(
        math.pow(n.x - world.dx, 2) + math.pow(n.y - world.dy, 2),
      );
      if (dist < thresh && dist < minD) {
        minD = dist;
        hitN = n;
      }
    }
    if (hitN != null) {
      _drag = _DragState.node(hitN);
      return;
    }
    final c = _hitComp(world, thresh);
    if (c != null) {
      _sel = c;
      _drag = _DragState.comp(
        c,
        Offset(c.n1.x - world.dx, c.n1.y - world.dy),
        Offset(c.n2.x - world.dx, c.n2.y - world.dy),
      );
      _rt_playSfx(_rt_Sfx.tap);
      setState(() {});
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final drag = _drag;
    if (drag == null) return;
    final world = _toWorld(d.localPosition);
    if (drag.node != null) {
      drag.node!.x = world.dx;
      drag.node!.y = world.dy;
    } else if (drag.comp != null) {
      final c = drag.comp!;
      c.n1.x = world.dx + drag.off1.dx;
      c.n1.y = world.dy + drag.off1.dy;
      c.n2.x = world.dx + drag.off2.dx;
      c.n2.y = world.dy + drag.off2.dy;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    final drag = _drag;
    _drag = null;
    if (drag == null) return;
    final moved = drag.node != null
        ? [drag.node!]
        : [drag.comp!.n1, drag.comp!.n2];
    for (final n in moved) {
      for (final o in List<_Node>.of(_nodes)) {
        if (!identical(o, n) &&
            math.sqrt(math.pow(o.x - n.x, 2) + math.pow(o.y - n.y, 2)) < 20) {
          n.x = o.x;
          n.y = o.y;
          for (final c in _comps) {
            if (identical(c.n1, n)) c.n1 = o;
            if (identical(c.n2, n)) c.n2 = o;
          }
          _nodes.remove(n);
          _rt_playSfx(_rt_Sfx.pop); // snap
          break;
        }
      }
    }
    setState(() {});
  }

  // ------------------------------------------------------- component acts ---

  void _deleteSelection() {
    final s = _sel;
    if (s == null) return;
    _comps.remove(s);
    if (identical(_tip, s)) _tip = null;
    final used = <_Node>{};
    for (final c in _comps) {
      used.add(c.n1);
      used.add(c.n2);
    }
    _nodes.removeWhere((n) => !used.contains(n));
    _sel = null;
    _rt_playSfx(_rt_Sfx.wrong); // source 'delete' buzz
    setState(() {});
  }

  void _breakBulb([_Comp? target]) {
    final bulb =
        target ??
        _comps.where((c) => c.type == _CompType.bulb && !c.isBlown).firstOrNull;
    if (bulb == null) return;
    bulb.isBlown = true;
    _sel = bulb;
    _rt_playSfx(_rt_Sfx.wrong);
    setState(() {});
  }

  void _repairBulb() {
    final s = _sel;
    if (s == null || s.type != _CompType.bulb) return;
    s.isBlown = false;
    setState(() {});
  }

  /// Sidebar mirror of the inspect-taps: cycles components, showing the big
  /// tooltip for each and marking the step's `inspected` flag.
  void _inspectNext() {
    if (_comps.isEmpty) return;
    _inspectIdx = (_inspectIdx + 1) % _comps.length;
    final c = _comps[_inspectIdx];
    _sel = c;
    _inspected = true;
    _tip = c;
    _tipPos = Offset(
      (c.n1.x + c.n2.x) / 2 * _zoom,
      (c.n1.y + c.n2.y) / 2 * _zoom,
    );
    setState(() {});
  }

  Future<void> _openAtomicView() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    _rt_playSfx(_rt_Sfx.magic);
    await _rt_showShellPopup(
      context,
      title: _tx.s('ui.atomicTitle'),
      message: _tx.s('ui.atomicDesc'),
      icon: Icons.blur_on,
      color: _rt_Tw.indigo500,
      body: const _AtomicView(),
    );
    _dialogOpen = false;
  }

  // -------------------------------------------------------------- mission ---

  void _afterMissionChange() {
    _obsCard = false;
    _voltage = 6;
    for (final c in _comps) {
      if (c.type == _CompType.battery) c.value = 6;
    }
    if (!_missionDone.contains(_key(_zone, _step))) {
      _inspected = false;
    } else {
      // Source re-shows the observation for an already-completed step.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _showObservation();
      });
    }
  }

  void _setZone(int z) {
    if (z == _zone) return;
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _zone = z;
      _step = 0;
      _tip = null;
    });
    _afterMissionChange();
  }

  Future<void> _showObservation() async {
    if (_dialogOpen || !mounted) return;
    // QA C10-11.5-02: the inspect steps use the source's non-modal corner card
    // so more parts can still be tapped and compared before Next.
    if (_isInspectStep) {
      setState(() {
        _obsCard = true;
        _obsOffset = Offset.zero; // source resets the popup to its corner
      });
      return;
    }
    _dialogOpen = true;
    final step = _stepData(_zone, _step);
    var act = '';
    await _rt_showShellPopup(
      context,
      title: _tx.s('obsModal.title'),
      message: step['observe'] as String,
      icon: Icons.fact_check,
      color: _rt_Tw.blue500,
      body: _learnBox(step),
      actions: _obsButtons(
        onPrev: () {
          act = 'prev';
          Navigator.of(context).pop();
        },
        onNext: () {
          act = 'next';
          Navigator.of(context).pop();
        },
      ),
    );
    _dialogOpen = false;
    if (!mounted) return;
    if (act == 'next') _goNext();
    if (act == 'prev') _goPrev();
  }

  /// "What we learned" box shared by the observation dialog and card.
  Widget _learnBox(Map<String, dynamic> step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue500)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('obsModal.learned'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step['learn'] as String,
            style: TextStyle(fontSize: 12, height: 1.35, color: _rt_Lab.text),
          ),
        ],
      ),
    );
  }

  List<Widget> _obsButtons({
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return [
      _rt_ActionButton(
        key: const ValueKey('obs-prev'),
        label: _tx.s('obsModal.prev'),
        icon: Icons.chevron_left,
        color: _rt_Tw.slate500,
        onPressed: onPrev,
      ),
      _rt_ActionButton(
        key: const ValueKey('obs-next'),
        label: _isLastStep ? _tx.s('ui.finish') : _tx.s('obsModal.next'),
        icon: Icons.arrow_forward,
        color: _rt_Tw.blue600,
        onPressed: onNext,
      ),
    ];
  }

  /// Drag via the card header, keeping the card on the canvas and left of the
  /// shell's zoom strip (it rests at right 80, bottom 88).
  void _dragObsCard(DragUpdateDetails d) {
    final size = _obsKey.currentContext?.size ?? const Size(300, 180);
    final minDx = -math.max(0.0, _canvasSize.width - 80 - size.width - 8);
    final minDy = -math.max(0.0, _canvasSize.height - 88 - size.height - 8);
    setState(() {
      _obsOffset = Offset(
        (_obsOffset.dx + d.delta.dx).clamp(minDx, 14.0),
        (_obsOffset.dy + d.delta.dy).clamp(minDy, 80.0),
      );
    });
  }

  void _goNext() {
    _missionDone.add(_key(_zone, _step));
    if (_step < _stepsPerZone[_zone] - 1) {
      setState(() => _step++);
    } else if (_zone < 2) {
      _rt_playSfx(_rt_Sfx.scenario); // source plays 'startup' on a zone change
      setState(() {
        _zone++;
        _step = 0;
        _comps.clear();
        _nodes.clear();
        _sel = null;
        _tip = null;
      });
    } else {
      _finish();
      return;
    }
    _afterMissionChange();
  }

  void _goPrev() {
    setState(() {
      if (_step > 0) {
        _step--;
      } else if (_zone > 0) {
        _zone--;
        _step = _stepsPerZone[_zone] - 1;
      }
      _tip = null;
    });
    _afterMissionChange();
  }

  Future<void> _finish() async {
    if (_dialogOpen || !mounted) return;
    _dialogOpen = true;
    _rt_playSfx(_rt_Sfx.success);
    await _rt_showShellPopup(
      context,
      title: _tx.s('successModal.title'),
      message: _tx.s('successModal.body'),
      icon: Icons.emoji_events,
      color: _rt_Tw.green500,
      actions: [
        _rt_ActionButton(
          key: const ValueKey('success-close'),
          label: _tx.s('successModal.close'),
          icon: Icons.close,
          color: _rt_Tw.slate500,
          onPressed: () => Navigator.of(context).pop(),
        ),
        _rt_ActionButton(
          key: const ValueKey('success-restart'),
          label: _tx.s('successModal.restart'),
          icon: Icons.refresh,
          color: _rt_Tw.green600,
          onPressed: () {
            Navigator.of(context).pop();
            _restart();
          },
        ),
      ],
    );
    _dialogOpen = false;
  }

  /// Full reset (source `hardReset`, minus the global language).
  void _restart() {
    setState(() {
      _comps.clear();
      _nodes.clear();
      _missionDone.clear();
      _zone = 0;
      _step = 0;
      _voltage = 6;
      _thermal = false;
      _schematic = false;
      _showLabels = true;
      _zoom = 1;
      _sel = null;
      _tip = null;
      _drag = null;
      _inspected = false;
      _obsCard = false;
      _inspectIdx = 0;
      _time = 0;
      _totalCurrent = 0;
      _bulbs = 0;
      _resistors = 0;
      _isSeries = false;
      _hasBroken = false;
    });
  }

  void _zoomBy(double f) => setState(() => _zoom = (_zoom * f).clamp(0.5, 3.0));

  // ------------------------------------------------------------------- UI ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final step = _stepData(_zone, _step);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.indigo500,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.indigo900],
              headerSubtitleColor: Color(0xFFC7D2FE),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.account_tree,
            ),
            onStart: () => _started = true,
            onRestart: _restart,
            onZoomIn: () => _zoomBy(1.1),
            onZoomOut: () => _zoomBy(0.9),
            onResetView: () => setState(() => _zoom = 1),
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: Icons.sell,
                tooltip: _tx.s('ui.labelsToggle'),
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _showLabels = !_showLabels);
                },
              ),
            ],
            hint: _rt_StepHint(
              number: '${_zone + 1}.${_step + 1}',
              text: step['action'] as String,
              label: ((_missions[_zone] as Map)['title'] as String)
                  .split(':')
                  .first
                  .trim(),
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.electric_bolt,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvasOverlays: _overlays(step),
            canvas: _circuitCanvas(),
          );
        },
      ),
    );
  }

  Widget _circuitCanvas() {
    return LayoutBuilder(
      builder: (context, c) {
        _canvasSize = Size(c.maxWidth, c.maxHeight);
        return GestureDetector(
          key: const ValueKey('circuit-canvas'),
          behavior: HitTestBehavior.opaque,
          // Hit-test the pan from the touch-down point, as the HTML
          // mousedown does, not after the touch slop (QA C10-11.5-14).
          dragStartBehavior: DragStartBehavior.down,
          onTapUp: _onTapUp,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: ClipRect(
            child: CustomPaint(
              painter: _CircuitPainter(this, repaint: _clock),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _overlays(Map<String, dynamic> step) {
    return [
      // HUD action message (top centre) and stats HUD (top right). QA
      // C10-11.5-10: the row stops at right 76 so the stats clear the shell's
      // back button (top 16, right 16); the message takes the space left.
      Positioned(
        top: 8,
        left: 60,
        right: 76,
        child: IgnorePointer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Lab.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _rt_Tw.amber400, width: 1.4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info,
                            color: _rt_Tw.amber500,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _tx.s('ui.currentAction'),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: _rt_Tw.amber500,
                                  ),
                                ),
                                Text(
                                  _thermal
                                      ? _tx.s('ui.thermalMsg')
                                      : step['action'] as String,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: _rt_Lab.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                key: const ValueKey('hud-stats'),
                children: [
                  _rt_HudCard(
                    value: '${_hudCurrent()} A',
                    label: _tx.s('load'),
                    color: _rt_Tw.blue500,
                    minWidth: 78,
                  ),
                  const SizedBox(width: 6),
                  _rt_HudCard(
                    value: '${_hudResistance()} Ω',
                    label: _tx.s('bill'),
                    color: _rt_Tw.emerald500,
                    minWidth: 78,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Palette (left).
      Positioned(top: 56, left: 8, child: _palette()),
      // Math panel (zone 3 only, bottom left).
      if (_zone == 2)
        Positioned(
          left: 8,
          bottom: 14,
          child: IgnorePointer(
            child: Container(
              key: const ValueKey('math-panel'),
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(maxWidth: 230),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_rt_Tw.slate800, _rt_Tw.slate900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: _rt_Tw.blue500, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tx.s('ui.resCalc'),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xFF93C5FD),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mathText(),
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (_obsCard) _observationCard(step),
      // Big tooltip (above the card, as the source's z-index 200 vs 100).
      if (_tip != null) _bigTooltip(),
    ];
  }

  /// The source's draggable observation popup (H:L117-127, 379-401): a 300 px
  /// corner card that leaves the canvas live. It sits above the shell's step
  /// hint strip, which shows along the bottom when the sidebar is closed.
  Widget _observationCard(Map<String, dynamic> step) {
    return Positioned(
      right: 80,
      bottom: 88,
      width: 300,
      child: Transform.translate(
        offset: _obsOffset,
        child: KeyedSubtree(
          key: _obsKey,
          child: Container(
            key: const ValueKey('obs-card'),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
              boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header doubles as the drag handle (source #obs-header).
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: _dragObsCard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Lab.overlay,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fact_check,
                          size: 15,
                          color: _rt_Tw.blue500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tx.s('obsModal.title'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _rt_Lab.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        step['observe'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: _rt_Lab.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _learnBox(step),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 8,
                        children: _obsButtons(onPrev: _goPrev, onNext: _goNext),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Source Zone 3 math panel content.
  String _mathText() {
    final ui = 'ui';
    final req = _tx.s('$ui.req');
    if (_resistors >= 2) {
      if (_isSeries) {
        return '${_tx.s('$ui.series')}:\n$req = R1 + R2\n$req = ${5 * _resistors}Ω\n${_tx.s('$ui.currLow')}';
      }
      final v = (5 / _resistors).toStringAsFixed(1);
      return '${_tx.s('$ui.parallel')}:\n1/$req = 1/R1 + 1/R2\n$req = $vΩ\n${_tx.s('$ui.currHigh')}';
    }
    return _tx.s('$ui.addRes');
  }

  Widget _bigTooltip() {
    final c = _tip!;
    final i = c.current.toStringAsFixed(2);
    final v = (c.n1.voltage - c.n2.voltage).abs().toStringAsFixed(2);
    final p = c.power.toStringAsFixed(2);
    String? extra;
    if (_zone == 1 && c.type == _CompType.wire) {
      final ratio = c.current.abs() / (_totalCurrent == 0 ? 1 : _totalCurrent);
      extra = ratio > 0.9 ? _tx.s('ui.mainWire') : _tx.s('ui.branchWire');
    }
    final left = _tipPos.dx
        .clamp(10.0, math.max(10.0, _canvasSize.width - 190))
        .toDouble();
    final top = (_tipPos.dy - 110)
        .clamp(10.0, math.max(10.0, _canvasSize.height - 130))
        .toDouble();
    Widget row(String k, String val) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 10, color: _rt_Tw.slate400)),
        Text(
          val,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      ],
    );
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          key: const ValueKey('big-tooltip'),
          width: 175,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _rt_Tw.slate900.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tx.s('components.${c.txKey}').toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF93C5FD),
                ),
              ),
              if (extra != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    extra,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _rt_Tw.yellow400,
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              row('${_tx.s('ui.current')}:', '$i A'),
              row('${_tx.s('ui.voltageLbl')}:', '$v V'),
              row('${_tx.s('ui.power')}:', '$p W'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _palette() {
    final items = <_CompType>[
      _CompType.wire,
      _CompType.battery,
      _CompType.sw,
      if (_zone != 2) _CompType.bulb,
      if (_zone == 2) _CompType.resistor,
    ];
    IconData iconOf(_CompType t) => switch (t) {
      _CompType.wire => Icons.horizontal_rule,
      _CompType.battery => Icons.battery_full,
      _CompType.sw => Icons.toggle_off,
      _CompType.bulb => Icons.lightbulb,
      _CompType.resistor => Icons.memory,
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final t in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: InkWell(
                key: ValueKey(
                  'palette-${t == _CompType.sw ? 'switch' : t.name}',
                ),
                borderRadius: BorderRadius.circular(8),
                onTap: () => _addComp(t),
                child: SizedBox(
                  width: 52,
                  height: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(iconOf(t), size: 17, color: _rt_Tw.amber400),
                      Text(
                        _tx.s(
                          'components.${t == _CompType.sw ? 'switch' : t.name}',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: _rt_Lab.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- sidebar ---

  Widget _exploreTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_ObjectiveCard(
            title: _tx.s('mainObjTitle'),
            desc: _tx.s('objDesc'),
            accent: _rt_Tw.blue500,
            icon: Icons.bolt,
          ),
          for (var z = 0; z < 3; z++) _zoneCard(z),
          const SizedBox(height: 8),
          _rt_SectionLabel(
            _tx.s('controls'),
            icon: Icons.tune,
            color: _rt_Tw.blue400,
          ),
          _controlsCard(),
          if (_sel != null) ...[const SizedBox(height: 8), _selectionCard()],
          const SizedBox(height: 16),
          _notes(),
        ],
      ),
    );
  }

  Widget _zoneCard(int z) {
    final zone = _missions[z] as Map;
    final steps = zone['steps'] as List;
    final active = z == _zone;
    final allDone = List.generate(
      steps.length,
      (s) => _missionDone.contains(_key(z, s)),
    ).every((d) => d);
    final dispIdx = active ? _step : 0;
    final dispStep = steps[dispIdx] as Map;
    final title = (zone['title'] as String).split(':');
    final Widget status;
    if (allDone) {
      status = const CircleAvatar(
        radius: 10,
        backgroundColor: _rt_Tw.green500,
        child: Icon(Icons.check, size: 13, color: Colors.white),
      );
    } else if (active) {
      status = const CircleAvatar(
        radius: 10,
        backgroundColor: _rt_Tw.blue500,
        child: Icon(Icons.circle, size: 8, color: Colors.white),
      );
    } else {
      status = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _rt_Lab.borderStrong, width: 2),
        ),
      );
    }
    return GestureDetector(
      key: ValueKey('zone-$z'),
      onTap: () => _setZone(z),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _rt_Lab.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _rt_Tw.blue500 : _rt_Lab.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.first.trim(),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
                status,
              ],
            ),
            if (title.length > 1)
              Text(
                title.sublist(1).join(':').trim(),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.textMuted,
                ),
              ),
            const SizedBox(height: 6),
            if (active)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _tx
                      .s('stepOf')
                      .replaceFirst('{a}', '${_step + 1}')
                      .replaceFirst('{b}', '${steps.length}'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.blue400,
                  ),
                ),
              ),
            _instr(_tx.s('do'), dispStep['action'] as String, _rt_Tw.blue500),
            const SizedBox(height: 4),
            _instr(
              _tx.s('observe'),
              dispStep['observe'] as String,
              _rt_Tw.amber500,
            ),
            // No build shortcut: the student wires every circuit (QA C10-11.5-01).
            if (active && (_isBreakStep || _isInspectStep)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_isBreakStep)
                    _rt_ActionButton(
                      key: const ValueKey('act-break'),
                      label: _tx.s('ui.breakBulb'),
                      icon: Icons.gavel,
                      color: _rt_Tw.amber600,
                      sound: null,
                      onPressed: _breakBulb,
                    ),
                  if (_isInspectStep)
                    _rt_ActionButton(
                      key: const ValueKey('act-inspect'),
                      label: _tx.s('ui.inspectNext'),
                      icon: Icons.search,
                      color: _rt_Tw.violet500,
                      sound: _rt_Sfx.tap,
                      onPressed: _inspectNext,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _instr(String tag, String text, Color color) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$tag: ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: _rt_Lab.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn({
    required Key key,
    required bool active,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        key: key,
        color: active ? _rt_Lab.tinted(_rt_Tw.blue100, color) : _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _rt_playSfx(_rt_Sfx.toggle);
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? color : _rt_Lab.border,
                width: active ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlsCard() {
    return _rt_InfoCard(
      color: _rt_Tw.blue500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_LabeledSlider(
            label: _tx.s('voltage'),
            value: _voltage,
            min: 0,
            max: 24,
            divisions: 24,
            valueText: '${_voltage.round()}V',
            color: _rt_Tw.blue500,
            onChanged: (v) => setState(() {
              _voltage = v;
              for (final c in _comps) {
                if (c.type == _CompType.battery) c.value = v.roundToDouble();
              }
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _toggleBtn(
                key: const ValueKey('toggle-thermal'),
                active: _thermal,
                icon: Icons.local_fire_department,
                label: _tx.s('thermal'),
                color: _rt_Tw.orange500,
                onTap: () => setState(() => _thermal = !_thermal),
              ),
              const SizedBox(width: 8),
              _toggleBtn(
                key: const ValueKey('toggle-style'),
                active: !_schematic,
                icon: _schematic ? Icons.design_services : Icons.visibility,
                label: _schematic ? _tx.s('schematic') : _tx.s('realistic'),
                color: _rt_Tw.blue500,
                onTap: () => setState(() => _schematic = !_schematic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectionCard() {
    final s = _sel!;
    final isBulb = s.type == _CompType.bulb;
    return _rt_InfoCard(
      title: _tx.s('ui.selection'),
      color: _rt_Tw.blue500,
      icon: Icons.touch_app,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('components.${s.txKey}'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              color: _rt_Lab.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selStats() ?? '',
            key: const ValueKey('sel-stats'),
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: _rt_Lab.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _rt_ActionButton(
                key: const ValueKey('btn-delete'),
                label: _tx.s('ui.delete'),
                icon: Icons.delete,
                color: _rt_Tw.red500,
                sound: null,
                onPressed: _deleteSelection,
              ),
              if (isBulb && !s.isBlown)
                _rt_ActionButton(
                  key: const ValueKey('btn-break'),
                  label: _tx.s('ui.break'),
                  icon: Icons.gavel,
                  color: _rt_Tw.amber600,
                  sound: null,
                  onPressed: () => _breakBulb(s),
                ),
              if (isBulb && s.isBlown)
                _rt_ActionButton(
                  key: const ValueKey('btn-fix'),
                  label: _tx.s('ui.repair'),
                  icon: Icons.build,
                  color: _rt_Tw.green600,
                  onPressed: _repairBulb,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notes() {
    final context4 = _tx.list('context');
    final guide = _tx.list('teacherGuide');
    final outcomes = _tx.list('outcomes');
    const ctxColors = [
      _rt_Tw.indigo500,
      _rt_Tw.green500,
      _rt_Tw.blue500,
      _rt_Tw.orange500,
    ];
    const ctxIcons = [
      Icons.menu_book,
      Icons.park,
      Icons.house,
      Icons.directions_car,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(
          _tx.s('notes.whyLearn'),
          icon: Icons.menu_book,
          color: _rt_Tw.indigo500,
        ),
        for (var i = 0; i < context4.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _rt_InfoCard(
              title: (context4[i] as Map)['title'] as String,
              body: (context4[i] as Map)['text'] as String,
              icon: ctxIcons[i % ctxIcons.length],
              color: ctxColors[i % ctxColors.length],
            ),
          ),
        const SizedBox(height: 8),
        _rt_SectionLabel(
          _tx.s('notes.guide'),
          icon: Icons.school,
          color: _rt_Tw.blue400,
        ),
        for (final p in guide)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _rt_InfoCard(
              title: (p as Map)['phase'] as String,
              color: _rt_Tw.blue500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final s in p['steps'] as List)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.chevron_right,
                            size: 13,
                            color: _rt_Lab.textFaint,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              s as String,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: _rt_Lab.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        _rt_SectionLabel(
          _tx.s('notes.outcomes'),
          icon: Icons.insights,
          color: _rt_Tw.green500,
        ),
        _rt_InfoCard(
          title: _tx.s('notes.outcomesTitle'),
          color: _rt_Tw.green500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final o in outcomes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 13, color: _rt_Tw.green500),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          o as String,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: _rt_Lab.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- painter ---

class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.st, {super.repaint});

  final _Cl10SCh11A5SeriesParallelMasterPageState st;

  @override
  void paint(Canvas canvas, Size size) {
    // Board background + dotted grid (the source #sim-canvas CSS).
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F172A),
    );
    final dot = Paint()..color = const Color(0xFF334155);
    for (var x = 12.0; x < size.width; x += 24) {
      for (var y = 12.0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }

    canvas.save();
    canvas.scale(st._zoom);

    for (final c in st._comps) {
      if (c.type == _CompType.wire) _drawComp(canvas, c);
    }
    final nodePaint = Paint()..color = const Color(0xFF94A3B8);
    for (final n in st._nodes) {
      canvas.drawCircle(Offset(n.x, n.y), 6, nodePaint);
    }
    for (final c in st._comps) {
      if (c.type != _CompType.wire) _drawComp(canvas, c);
    }

    // Electron flow dots (realistic style only).
    if (!st._schematic) {
      final e = Paint()..color = const Color(0xFF60A5FA);
      for (final c in st._comps) {
        if (c.current.abs() > 0.01 && !c.isBlown && !c.isOpen) {
          final len = _len(c);
          if (len < 12) continue;
          final angle = math.atan2(c.n2.y - c.n1.y, c.n2.x - c.n1.x);
          canvas.save();
          canvas.translate(c.n1.x, c.n1.y);
          canvas.rotate(angle);
          final speed = math.min(c.current * 0.5, 10.0);
          final dir = c.n1.voltage > c.n2.voltage ? -1 : 1;
          final phase = st._time * 30 * speed * dir;
          for (var i = 0; i < (len / 20).floor(); i++) {
            var pos = (i * 20 + phase) % len;
            if (pos < 0) pos += len;
            if (pos > 5 && pos < len - 5) {
              canvas.drawCircle(Offset(pos, 0), 3, e);
            }
          }
          canvas.restore();
        }
      }
    }

    canvas.restore();
  }

  double _len(_Comp c) =>
      math.sqrt(math.pow(c.n2.x - c.n1.x, 2) + math.pow(c.n2.y - c.n1.y, 2));

  void _drawComp(Canvas canvas, _Comp c) {
    final len = _len(c);
    final angle = math.atan2(c.n2.y - c.n1.y, c.n2.x - c.n1.x);

    // Selection halo / thermal glow along the segment.
    if (identical(st._sel, c) || (st._thermal && c.power > 0.05)) {
      final thermal = st._thermal && c.power > 0.05;
      final heat = math.min(c.power, 1.0);
      final glow = Paint()
        ..color = thermal
            ? Color.fromRGBO(255, 60, 0, 0.25 + 0.35 * heat)
            : const Color(0x593B82F6)
        ..strokeWidth = thermal ? 16 : 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawLine(Offset(c.n1.x, c.n1.y), Offset(c.n2.x, c.n2.y), glow);
    }

    canvas.save();
    canvas.translate(c.n1.x, c.n1.y);
    canvas.rotate(angle);
    if (st._schematic) {
      _drawSchematic(canvas, c, len);
    } else {
      _drawRealistic(canvas, c, len);
    }
    canvas.restore();

    if (st._showLabels) {
      final mx = (c.n1.x + c.n2.x) / 2, my = (c.n1.y + c.n2.y) / 2;
      _text(
        canvas,
        _tx.s('components.${c.txKey}'),
        Offset(mx, my - 25),
        size: 11,
        color: Colors.white,
      );
      if (c.type == _CompType.battery) {
        _text(
          canvas,
          '${c.value.round()}V',
          Offset(mx, my + 25),
          size: 11,
          color: Colors.white,
        );
      }
    }
  }

  void _drawRealistic(Canvas canvas, _Comp c, double len) {
    final mid = len / 2;
    final lead = Paint()
      ..color = const Color(0xFFEAB308)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    switch (c.type) {
      case _CompType.wire:
        var color = const Color(0xFFEAB308);
        // Zone 2 step 3: main (red) vs branch (blue) highlighting.
        final z2s3 = st._zone == 1 && st._step == 2;
        double ratio = 0;
        if (z2s3) {
          ratio =
              c.current.abs() / (st._totalCurrent == 0 ? 1 : st._totalCurrent);
          if (ratio > 0.9) {
            color = const Color(0xFFEF4444);
          } else if (ratio > 0.1) {
            color = const Color(0xFF3B82F6);
          }
        }
        canvas.drawLine(
          Offset.zero,
          Offset(len, 0),
          Paint()
            ..color = color
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          const Offset(0, -2),
          Offset(len, -2),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.4)
            ..strokeWidth = 2,
        );
        if (z2s3 && len > 30) {
          if (ratio > 0.9) {
            _text(
              canvas,
              _tx.s('ui.main'),
              Offset(mid, 12),
              size: 9,
              color: Colors.white,
              mono: true,
            );
          } else if (ratio > 0.1) {
            _text(
              canvas,
              _tx.s('ui.branch'),
              Offset(mid, 12),
              size: 9,
              color: Colors.white,
              mono: true,
            );
          }
        }
      case _CompType.battery:
        canvas.drawLine(Offset.zero, Offset(mid - 32, 0), lead);
        canvas.drawLine(Offset(mid + 35, 0), Offset(len, 0), lead);
        canvas.drawRect(
          Rect.fromLTWH(mid - 30, -15, 60, 30),
          Paint()..color = const Color(0xFF0F172A),
        );
        final amber = Paint()..color = const Color(0xFFD97706);
        canvas.drawRect(Rect.fromLTWH(mid + 15, -15, 15, 30), amber);
        canvas.drawRect(Rect.fromLTWH(mid + 25, -8, 10, 16), amber);
        canvas.drawRect(
          Rect.fromLTWH(mid - 32, -10, 4, 20),
          Paint()..color = const Color(0xFFCBD5E1),
        );
        // Lightning bolt glyph.
        final bolt = Path()
          ..moveTo(mid - 3, -8)
          ..lineTo(mid - 9, 2)
          ..lineTo(mid - 4, 2)
          ..lineTo(mid - 7, 9)
          ..lineTo(mid + 1, -1)
          ..lineTo(mid - 4, -1)
          ..close();
        canvas.drawPath(bolt, Paint()..color = const Color(0xFFFACC15));
      case _CompType.bulb:
        canvas.drawLine(Offset.zero, Offset(mid - 10, 0), lead);
        canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), lead);
        canvas.drawRect(
          Rect.fromLTWH(mid - 10, -10, 20, 20),
          Paint()..color = const Color(0xFF94A3B8),
        );
        // Source glow: vDrop = |I * 5|, b = clamp((vDrop - 0.5) / 5, 0, 1).
        final vDrop = (c.current * 5).abs();
        final b = ((vDrop - 0.5) / 5).clamp(0.0, 1.0);
        final glass = Offset(mid, -25);
        canvas.drawCircle(
          glass,
          20,
          Paint()
            ..color = c.isBlown
                ? const Color(0x80323232)
                : (b > 0
                      ? Color.fromRGBO(255, 255, 100, 0.3 + b * 0.7)
                      : Colors.white.withValues(alpha: 0.2)),
        );
        canvas.drawCircle(
          glass,
          20,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFFCBD5E1),
        );
        if (c.isBlown) {
          final shatter = Paint()
            ..color = const Color(0xFF475569)
            ..strokeWidth = 2;
          canvas.drawLine(
            Offset(mid - 10, -30),
            Offset(mid + 10, -20),
            shatter,
          );
          canvas.drawLine(Offset(mid + 5, -35), Offset(mid - 5, -15), shatter);
        } else {
          final filament = Paint()
            ..color = b > 0 ? const Color(0xFFFEF08A) : const Color(0xFF475569)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          final path = Path()
            ..moveTo(mid - 5, -10)
            ..lineTo(mid - 5, -25)
            ..lineTo(mid + 5, -25)
            ..lineTo(mid + 5, -10);
          canvas.drawPath(path, filament);
          if (b > 0) {
            final r = 30 + b * 20;
            canvas.drawCircle(
              glass,
              50,
              Paint()
                ..shader = RadialGradient(
                  colors: [
                    Color.fromRGBO(255, 255, 200, 0.8 * b),
                    const Color(0x00FFFF00),
                  ],
                ).createShader(Rect.fromCircle(center: glass, radius: r)),
            );
          }
        }
      case _CompType.sw:
        canvas.drawLine(Offset.zero, Offset(mid - 20, 0), lead);
        canvas.drawLine(Offset(mid + 20, 0), Offset(len, 0), lead);
        canvas.drawRect(
          Rect.fromLTWH(mid - 20, -10, 40, 20),
          Paint()..color = const Color(0xFF334155),
        );
        final contact = Paint()..color = const Color(0xFFFBBF24);
        canvas.drawCircle(Offset(mid - 12, 0), 4, contact);
        canvas.drawCircle(Offset(mid + 12, 0), 4, contact);
        final lever = Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(mid - 12, 0),
          c.isOpen ? Offset(mid + 10, -25) : Offset(mid + 12, 0),
          lever,
        );
      case _CompType.resistor:
        canvas.drawLine(Offset.zero, Offset(mid - 15, 0), lead);
        canvas.drawLine(Offset(mid + 15, 0), Offset(len, 0), lead);
        canvas.drawRect(
          Rect.fromLTWH(mid - 15, -15, 30, 30),
          Paint()..color = const Color(0xFFF1F5F9),
        );
        canvas.drawRect(
          Rect.fromLTWH(mid - 15, -15, 30, 30),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFFCBD5E1),
        );
        final zig = Path()..moveTo(mid - 11, 0);
        for (var i = 0; i < 4; i++) {
          zig.lineTo(mid - 11 + i * 5.5 + 2.75, i.isEven ? -7 : 7);
        }
        zig.lineTo(mid + 11, 0);
        canvas.drawPath(
          zig,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = const Color(0xFF475569),
        );
    }
  }

  void _drawSchematic(Canvas canvas, _Comp c, double len) {
    final mid = len / 2;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    switch (c.type) {
      case _CompType.wire:
        canvas.drawLine(Offset.zero, Offset(len, 0), p);
      case _CompType.battery:
        canvas.drawLine(Offset.zero, Offset(mid - 5, 0), p);
        canvas.drawLine(Offset(mid + 5, 0), Offset(len, 0), p);
        canvas.drawLine(Offset(mid - 5, -10), Offset(mid - 5, 10), p);
        canvas.drawLine(
          Offset(mid + 5, -5),
          Offset(mid + 5, 5),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 4,
        );
      case _CompType.bulb:
        canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
        canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
        canvas.drawCircle(Offset(mid, 0), 10, p);
        final f = Path()
          ..moveTo(mid - 7, 0)
          ..lineTo(mid - 3, -7)
          ..lineTo(mid + 3, 7)
          ..lineTo(mid + 7, 0);
        canvas.drawPath(f, p);
        if (c.isBlown) {
          canvas.drawLine(Offset(mid - 8, -8), Offset(mid + 8, 8), p);
        }
      case _CompType.sw:
        canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
        canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
        canvas.drawLine(
          Offset(mid - 10, 0),
          c.isOpen ? Offset(mid + 8, -8) : Offset(mid + 10, 0),
          p,
        );
        canvas.drawCircle(Offset(mid - 10, 0), 2, p);
      case _CompType.resistor:
        canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
        canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
        final zig = Path()..moveTo(mid - 10, 0);
        for (var i = 0; i < 4; i++) {
          zig.lineTo(mid - 10 + i * 5 + 2.5, i.isEven ? -6 : 6);
        }
        zig.lineTo(mid + 10, 0);
        canvas.drawPath(zig, p);
    }
  }

  void _text(
    Canvas canvas,
    String s,
    Offset at, {
    double size = 12,
    Color color = Colors.white,
    bool mono = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w800,
          fontFamily: mono ? 'monospace' : null,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter old) => true;
}

// ------------------------------------------------------------ atomic view ---

/// The source's atomic modal: fixed lattice atoms vibrating, free electrons
/// drifting through and flashing white when they collide.
class _AtomicView extends StatefulWidget {
  const _AtomicView();

  @override
  State<_AtomicView> createState() => _AtomicViewState();
}

class _AtomicViewState extends State<_AtomicView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 400,
        height: 190,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 460,
            height: 220,
            child: CustomPaint(
              painter: _AtomicPainter(repaint: _c, anim: _c),
            ),
          ),
        ),
      ),
    );
  }
}

class _AtomicPainter extends CustomPainter {
  _AtomicPainter({super.repaint, required this.anim});

  final Animation<double> anim;
  final math.Random _rng = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF020617),
    );
    final t = anim.value;
    final atom = Paint()..color = const Color(0xFF334155);
    final atoms = <Offset>[];
    for (var i = 0; i < 24; i++) {
      final bx = 40.0 + (i % 6) * 76, by = 30.0 + (i ~/ 6) * 52;
      final vx = (_rng.nextDouble() - 0.5) * 3,
          vy = (_rng.nextDouble() - 0.5) * 3;
      final p = Offset(bx + vx, by + vy);
      atoms.add(Offset(bx, by));
      canvas.drawCircle(p, 14, atom);
    }
    final ePaint = Paint()..color = const Color(0xFFFACC15);
    for (var i = 0; i < 14; i++) {
      final y = 15.0 + i * 14.5;
      final x = (i * 37.0 + t * 460 * (1 + i % 3)) % 460;
      var hit = false;
      for (final a in atoms) {
        if ((Offset(x, y) - a).distance < 19) hit = true;
      }
      if (hit && ((t * 40 + i) % 5) < 1) {
        canvas.drawCircle(Offset(x, y), 8, Paint()..color = Colors.white);
      }
      canvas.drawCircle(Offset(x, y), 4, ePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtomicPainter old) => true;
}

// ------------------------------------------------------------------ misc ---

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
