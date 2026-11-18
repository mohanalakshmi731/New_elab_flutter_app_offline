// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 11.6: The Heat & Power Station
// Converted from Cl10S-Ch11-A6-HeatingEffectandPowerPlant.html
// (canvas-2D circuit sandbox -> CustomPainter + widget overlays).
//
// A free-build circuit sandbox with three missions: (1) The Glow Test -- wire
// a battery, switch and nichrome coil and watch it glow red in thermal view
// (Joule heating H = I²Rt); (2) The Safety Fuse -- overload a fused circuit
// until the 5 A fuse melts; (3) Meter Room -- run a bulb + fridge for hours
// and watch the kWh bill climb (Energy = P × t). Components come from a
// palette (tap to add or drag onto the canvas), can be dragged around with
// node snapping. As in the HTML, the student wires the circuit by dragging
// component ends onto each other (the Dart-only AUTO-CONNECT helper was
// removed: it decided the series/parallel layout for the student, QA
// C10-11.6-01).
// The nodal relaxation solver, resistances and billing match the source.

// --- TRANSLATION DATA (copied from the source CONTENT block; te ignored) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const blue50 = Color(0xFFEFF6FF);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const violet500 = Color(0xFF8B5CF6);
  static const violet600 = Color(0xFF7C3AED);
  static const red500 = Color(0xFFEF4444);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const green400 = Color(0xFF4ADE80);
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

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'title': 'HEAT & POWER STATION',
    'subtitle': 'Class 10 • Electricity',
    'intro': {
      'title': 'The Heat & Power Station',
      'subtitle': 'Class 10 • Electricity',
      'button': 'Enter Station',
      'footnote': "Joule's Law • H = I²Rt • Fuses • kWh",
    },
    'mainObj':
        "Investigate the heating effect of electric current (Joule's Law) and understand how fuses protect domestic circuits from overloading.",
    'mainObjTitle': 'Main Objective',
    'do': 'DO',
    'observe': 'OBSERVE',
    'controls': 'Controls',
    'voltage': 'Voltage',
    'time': 'Time (Hrs)',
    'load': 'Total Load',
    'bill': 'Bill',
    'thermal': 'THERMAL',
    'realistic': 'REALISTIC',
    'schematic': 'SCHEMATIC',
    'tabs': {
      'context': 'CONCEPT',
      'guide': 'GUIDE',
      'explore': 'LAB',
      'analysis': 'RESULT',
    },
    'obs': {
      'title': 'Observation',
      'learned': 'What we learned:',
      'prev': 'Prev',
      'next': 'Next Mission',
    },
    'successModal': {
      'title': 'Simulation Complete!',
      'body':
          'You have successfully mastered the concepts of heating effects and safety fuses.',
      'close': 'Close',
      'restart': 'Restart _rt_Lab',
    },
    'components': {
      'wire': 'Wire',
      'battery': 'Battery',
      'switch': 'Switch',
      'nichrome': 'Nichrome',
      'fuse': 'Fuse',
      'adapter': 'Adapter',
      'heater': 'Heater',
      'bulb': 'Bulb',
      'fridge': 'Fridge',
    },
    'ui': {
      'palette': 'Components',
      'emptyList': 'No components yet — tap the palette on the canvas.',
      'placed': 'Placed Components',
      'selection': 'Selection',
      'delete': 'Delete',
      'replaceFuse': 'Replace Fuse',
      'toggleSwitch': 'Toggle Switch',
      'atomicView': 'Atomic View',
      'toggleLabels': 'Toggle Labels',
      'fuseBlown': 'Fuse melted! Current exceeded 5 A.',
      'formulaTitle': 'Key Formulas',
      'formulas':
          'H = I²Rt   •   P = VI = I²R   •   Energy (kWh) = P(kW) × t(h)',
    },
    'atomic': {
      'title': 'ATOMIC VIEW',
      'desc': 'Visualizing electron collisions.',
    },
    'context': [
      {
        'title': '1. Why Learn?',
        'text':
            'Understanding the heating effect of electric current is crucial for both safety and utility in daily life. It explains how appliances work and how to prevent electrical fires.',
      },
      {
        'title': 'Example 1: Electric Iron',
        'text':
            'An electric iron uses a high-resistance coil (Nichrome) to convert electrical energy into heat energy (Joule\'s Heating) to press clothes, while the copper cord remains cool.',
      },
      {
        'title': 'Example 2: The Safety Fuse',
        'text':
            'A fuse uses a wire with a low melting point. If current exceeds a safe limit (e.g., 5A), the heat generated melts the wire, breaking the circuit and saving expensive devices.',
      },
      {
        'title': 'Example 3: Energy Efficiency',
        'text':
            'Old incandescent bulbs wasted 90% of energy as heat to produce light. Modern LEDs are more efficient because they minimize this heating effect.',
      },
    ],
    'guide': [
      {
        'phase': 'Phase 1: Context Setting (5 mins)',
        'steps': [
          "Start by asking: 'Why does the heater cord stay cool while the coil glows red?'",
          "Introduce Joule's Law: Heat produced (H) is directly proportional to Square of Current (I²), Resistance (R), and Time (t).",
          "Explain that Resistance is like 'friction' for electrons.",
        ],
      },
      {
        'phase': 'Phase 2: Virtual Experiment (15 mins)',
        'steps': [
          'Step 1: Have students build a simple circuit with a Battery and Copper wire. Note that it stays cool (Blue).',
          "Step 2: Replace Copper with 'Nichrome'. Turn on 'Thermal View'. Observe the red glow indicating heat generation due to high resistance.",
          'Step 3: Introduce the Fuse. Overload the circuit using the slider or by adding a heater. Watch the fuse melt and break the circuit.',
        ],
      },
      {
        'phase': 'Phase 3: Discussion & Billing (10 mins)',
        'steps': [
          'Discuss: Why is Nichrome used in heaters but Copper in wires?',
          'Discuss: How does a fuse act as a safety valve?',
          "Calculate: Show the 'Meter Room'. Explain that we pay for 'Units' of energy (kWh), not just power (kW).",
        ],
      },
    ],
    'outcomesTitle': 'Learning Outcomes',
    'outcomes': [
      'Students will be able to verify that heat produced is directly proportional to Resistance (R) and Current squared (I²).',
      'Students will understand the practical application of high-resistance materials (Nichrome) in heating appliances.',
      'Students will demonstrate how a fuse protects circuits by melting at specific current ratings.',
      'Students will be able to calculate commercial electrical energy consumption in kilowatt-hours (kWh).',
    ],
    'missions': [
      {
        'title': 'Zone 1: The Glow Test',
        'do': 'Drag Battery, Switch, and Nichrome Wire. Connect them.',
        'observe':
            'Nichrome glows RED due to high resistance. Copper stays cool.',
        'learn': 'Resistance converts electrical energy into Heat.',
      },
      {
        'title': 'Zone 2: The Safety Fuse',
        'do': 'Connect Battery -> Fuse -> Adapter. Then add Heater (Parallel).',
        'observe': 'Current > 5A! The Fuse melts instantly.',
        'learn':
            'Fuses have low melting points to break circuits during overload.',
      },
      {
        'title': 'Zone 3: Meter Room',
        'do': 'Connect Bulb + Fridge. Drag Time Slider to > 10 Hrs.',
        'observe': 'Energy Meter climbs. Cost increases over time.',
        'learn': 'We pay for Energy (kWh) = Power (kW) x Time (h).',
      },
    ],
  },
  'hi': {
    'title': 'हीट और पावर स्टेशन',
    'subtitle': 'कक्षा 10 • विद्युत',
    'intro': {
      'title': 'हीट और पावर स्टेशन',
      'subtitle': 'कक्षा 10 • विद्युत',
      'button': 'स्टेशन में प्रवेश करें',
      'footnote': 'जूल का नियम • H = I²Rt • फ्यूज • kWh',
    },
    'mainObj':
        'विद्युत प्रवाह के तापीय प्रभाव (जूल का नियम) की जांच करें और समझें कि फ्यूज घरेलू सर्किट को ओवरलोडिंग से कैसे बचाते हैं।',
    'mainObjTitle': 'मुख्य उद्देश्य',
    'do': 'करें',
    'observe': 'देखें',
    'controls': 'नियंत्रण',
    'voltage': 'वोल्टेज',
    'time': 'समय (घंटे)',
    'load': 'कुल लोड',
    'bill': 'बिल',
    'thermal': 'थर्मल',
    'realistic': 'वास्तविक',
    'schematic': 'योजनाबद्ध',
    'tabs': {
      'context': 'अवधारणा',
      'guide': 'गाइड',
      'explore': 'लैब',
      'analysis': 'परिणाम',
    },
    'obs': {
      'title': 'अवलोकन',
      'learned': 'हमने क्या सीखा:',
      'prev': 'पिछला',
      'next': 'अगला मिशन',
    },
    'successModal': {
      'title': 'सिमुलेशन पूर्ण!',
      'body':
          'आपने हीटिंग प्रभाव और सुरक्षा फ़्यूज़ की अवधारणाओं में महारत हासिल कर ली है।',
      'close': 'बंद करें',
      'restart': 'लैब पुनरारंभ करें',
    },
    'components': {
      'wire': 'तार',
      'battery': 'बैटरी',
      'switch': 'स्विच',
      'nichrome': 'नाइक्रोम',
      'fuse': 'फ्यूज',
      'adapter': 'एडाप्टर',
      'heater': 'हीटर',
      'bulb': 'बल्ब',
      'fridge': 'फ्रिज',
    },
    'ui': {
      'palette': 'घटक',
      'emptyList': 'अभी कोई घटक नहीं — कैनवास पर पैलेट टैप करें।',
      'placed': 'रखे गए घटक',
      'selection': 'चयन',
      'delete': 'हटाएँ',
      'replaceFuse': 'फ्यूज बदलें',
      'toggleSwitch': 'स्विच टॉगल करें',
      'atomicView': 'परमाणु दृश्य',
      'toggleLabels': 'लेबल दिखाएँ/छिपाएँ',
      'fuseBlown': 'फ्यूज पिघल गया! धारा 5 A से अधिक हो गई।',
      'formulaTitle': 'मुख्य सूत्र',
      'formulas':
          'H = I²Rt   •   P = VI = I²R   •   ऊर्जा (kWh) = P(kW) × t(h)',
    },
    'atomic': {'title': 'परमाणु दृश्य', 'desc': 'इलेक्ट्रॉन टकराव का चित्रण।'},
    'context': [
      {
        'title': '1. क्यों सीखें?',
        'text':
            'विद्युत धारा के तापीय प्रभाव को समझना दैनिक जीवन में सुरक्षा और उपयोगिता दोनों के लिए महत्वपूर्ण है। यह बताता है कि उपकरण कैसे काम करते हैं और बिजली की आग को कैसे रोका जाए।',
      },
      {
        'title': 'उदाहरण 1: इलेक्ट्रिक आयरन',
        'text':
            'एक इलेक्ट्रिक आयरन कपड़े प्रेस करने के लिए विद्युत ऊर्जा को ऊष्मा ऊर्जा (जूल हीटिंग) में बदलने के लिए उच्च-प्रतिरोध कुंडल (नाइक्रोम) का उपयोग करता है, जबकि तांबे की तार ठंडी रहती है।',
      },
      {
        'title': 'उदाहरण 2: सुरक्षा फ्यूज',
        'text':
            'फ्यूज कम गलनांक वाले तार का उपयोग करता है। यदि धारा सुरक्षित सीमा (जैसे, 5A) से अधिक हो जाती है, तो उत्पन्न गर्मी तार को पिघला देती है, सर्किट को तोड़ देती है और महंगे उपकरणों को बचाती है।',
      },
      {
        'title': 'उदाहरण 3: ऊर्जा दक्षता',
        'text':
            'पुराने बल्ब प्रकाश उत्पन्न करने के लिए गर्मी के रूप में 90% ऊर्जा बर्बाद करते थे। आधुनिक एल ई डी अधिक कुशल हैं क्योंकि वे इस हीटिंग प्रभाव को कम करते हैं।',
      },
    ],
    'guide': [
      {
        'phase': 'चरण 1: संदर्भ सेटिंग (5 मिनट)',
        'steps': [
          "पूछकर शुरुआत करें: 'हीटर की डोरी ठंडी क्यों रहती है जबकि कॉइल लाल चमकती है?'",
          'जूल का नियम परिचय: उत्पादित ऊष्मा (H) धारा के वर्ग (I²), प्रतिरोध (R), और समय (t) के सीधे समानुपाती होती है।',
          "समझाएं कि प्रतिरोध इलेक्ट्रॉनों के लिए 'घर्षण' की तरह है।",
        ],
      },
      {
        'phase': 'चरण 2: आभासी प्रयोग (15 मिनट)',
        'steps': [
          'चरण 1: छात्रों से बैटरी और तांबे के तार के साथ एक साधारण सर्किट बनाने को कहें। ध्यान दें कि यह ठंडा (नीला) रहता है।',
          "चरण 2: कॉपर को 'नाइक्रोम' से बदलें। 'थर्मल व्यू' चालू करें। उच्च प्रतिरोध के कारण गर्मी उत्पादन का संकेत देने वाली लाल चमक देखें।",
          'चरण 3: फ्यूज का परिचय दें। स्लाइडर का उपयोग करके या हीटर जोड़कर सर्किट को ओवरलोड करें। फ्यूज को पिघलते और सर्किट को तोड़ते हुए देखें।',
        ],
      },
      {
        'phase': 'चरण 3: चर्चा और बिलिंग (10 मिनट)',
        'steps': [
          'चर्चा करें: हीटर में नाइक्रोम का उपयोग क्यों किया जाता है लेकिन तारों में तांबे का?',
          'चर्चा करें: फ्यूज सुरक्षा वाल्व के रूप में कैसे कार्य करता है?',
          "गणना करें: 'मीटर रूम' दिखाएं। समझाएं कि हम ऊर्जा की 'इकाइयों' (kWh) के लिए भुगतान करते हैं, न कि केवल शक्ति (kW) के लिए।",
        ],
      },
    ],
    'outcomesTitle': 'सीखने के परिणाम',
    'outcomes': [
      'छात्र यह सत्यापित करने में सक्षम होंगे कि उत्पादित गर्मी प्रतिरोध (R) और धारा वर्ग (I²) के सीधे आनुपातिक है।',
      'छात्र हीटिंग उपकरणों में उच्च-प्रतिरोध सामग्री (नाइक्रोम) के व्यावहारिक अनुप्रयोग को समझेंगे।',
      'छात्र प्रदर्शित करेंगे कि विशिष्ट वर्तमान रेटिंग पर पिघलकर फ्यूज सर्किट की सुरक्षा कैसे करता है।',
      'छात्र किलोवाट-घंटे (kWh) में वाणिज्यिक विद्युत ऊर्जा खपत की गणना करने में सक्षम होंगे।',
    ],
    'missions': [
      {
        'title': 'Zone 1: ग्लो टेस्ट',
        'do': 'बैटरी, स्विच और नाइक्रोम तार को खींचें और जोड़ें।',
        'observe':
            'नाइक्रोम उच्च प्रतिरोध के कारण लाल चमकता है। तांबा ठंडा रहता है।',
        'learn': 'प्रतिरोध विद्युत ऊर्जा को ऊष्मा में परिवर्तित करता है।',
      },
      {
        'title': 'Zone 2: सुरक्षा वाल्व',
        'do':
            'बैटरी -> फ्यूज -> एडाप्टर को कनेक्ट करें। फिर हीटर (समानांतर) जोड़ें।',
        'observe': 'धारा > 5A! फ्यूज तुरंत पिघल जाता है।',
        'learn':
            'ओवरलोड के दौरान सर्किट को तोड़ने के लिए फ़्यूज़ में कम गलनांक होता है।',
      },
      {
        'title': 'Zone 3: मीटर रूम',
        'do': 'बल्ब + फ्रिज कनेक्ट करें। समय स्लाइडर को > 10 घंटे तक खींचें।',
        'observe': 'ऊर्जा मीटर चढ़ता है। समय के साथ लागत बढ़ती है।',
        'learn':
            'हम ऊर्जा (kWh) = शक्ति (kW) x समय (h) के लिए भुगतान करते हैं।',
      },
    ],
  },
});

const _missionIds = ['m1', 'm2', 'm3'];

// ------------------------------------------------------------ models ----

class _Node {
  _Node(this.x, this.y);
  double x, y;
  double voltage = 0;
}

/// Mirrors the source `Component` class.
class _Comp {
  _Comp(this.type, double x, double y)
    : n1 = _Node(x, y),
      n2 = _Node(x + 80, y);

  final String type; // wire | battery | switch | fuse | resistor | bulb
  _Node n1, n2;
  double value = 10;
  double power = 0;
  double current = 0;
  double rating = 5;
  String material = 'copper';
  bool isBlown = false;
  bool isOpen = false;
  double nominalPower = 0;
  String labelKey = '';

  bool get isNichrome => material == 'nichrome' || labelKey == 'nichrome';

  double get resistance {
    if (type == 'wire') return isNichrome ? 5 : 0.05;
    if (type == 'fuse') return isBlown ? 1e8 : 0.1;
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

class _AtomParticle {
  _AtomParticle.atom(this.baseX, this.baseY)
    : isElectron = false,
      x = baseX,
      y = baseY,
      vx = 0;
  _AtomParticle.electron(this.x, this.y)
    : isElectron = true,
      baseX = 0,
      baseY = 0,
      vx = 5;
  final bool isElectron;
  final double baseX, baseY;
  double x, y, vx;
  bool flash = false;
}

// -------------------------------------------------------------- page ----

class Cl10SCh11A6HeatingEffectandPowerPlantPage extends StatefulWidget {
  const Cl10SCh11A6HeatingEffectandPowerPlantPage({super.key});

  @override
  State<Cl10SCh11A6HeatingEffectandPowerPlantPage> createState() =>
      _Cl10SCh11A6HeatingEffectandPowerPlantPageState();
}

class _Cl10SCh11A6HeatingEffectandPowerPlantPageState
    extends State<Cl10SCh11A6HeatingEffectandPowerPlantPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final GlobalKey _canvasKey = GlobalKey();
  final _RepaintNotifier _repaint = _RepaintNotifier();
  final math.Random _rng = math.Random();

  late final Ticker _ticker = createTicker((_) => _tick());

  // Circuit state
  final List<_Comp> _comps = [];
  final List<_Node> _nodes = [];
  _Comp? _selection;
  double _time = 0;
  int _spawnN = 0;
  Size _canvasSize = const Size(600, 400);

  // View state
  double _zoomLv = 1;
  bool _thermal = false;
  bool _schematic = false;
  bool _showLabels = true;

  // Controls
  double _voltage = 10;
  int _hours = 0;

  // Missions
  String _activeMissionId = 'm1';
  final Map<String, bool> _missionDone = {
    'm1': false,
    'm2': false,
    'm3': false,
  };
  String? _obsMissionId; // observation popup showing for this mission

  // Simulation summary (recomputed each tick, drives HUD + mission checks)
  double _simPower = 0;
  bool _simHasNichrome = false;
  bool _simFuseBlown = false;
  bool _simClosed = false;

  // Atomic view
  bool _atomicOpen = false;
  final List<_AtomParticle> _atomicParticles = [];

  // Drag state
  _Node? _dragNode;
  _Comp? _dragComp;
  Offset _dragOff1 = Offset.zero, _dragOff2 = Offset.zero;

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
  /// One simulation frame: the source's `loop()` (relaxation solver, fuse
  /// check, HUD totals) minus the drawing, which the painter handles.
  void _tick() {
    if (!mounted) return;
    _time += 0.016;

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
            final r = c.resistance;
            final g = 1 / r;
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

    double totalWattage = 0;
    var hasNichrome = false, fuseBlown = false, isClosed = false;
    for (final c in _comps) {
      final v = (c.n2.voltage - c.n1.voltage - c.sourceVoltage).abs();
      c.current = v / c.resistance;
      c.power = c.current * c.current * c.resistance;

      if (c.nominalPower > 0 && c.current.abs() > 0.1) {
        totalWattage += c.nominalPower;
      } else if (c.type != 'wire' &&
          c.type != 'switch' &&
          c.type != 'battery' &&
          c.type != 'fuse') {
        totalWattage += c.power;
      }

      if (c.isNichrome) hasNichrome = true;
      if (c.type == 'fuse' && c.current > c.rating && !c.isBlown) {
        c.isBlown = true;
        _rt_playSfx(
          _rt_Sfx.wrong,
        ); // the source's 'delete' buzz when the fuse melts
        _shell.showToast(
          _tx.s('ui.fuseBlown'),
          color: _rt_Tw.red500,
          icon: Icons.bolt,
        );
      }
      if (c.isBlown) fuseBlown = true;
      if (c.current.abs() > 0.1) isClosed = true;
    }

    final double totalP = _activeMissionId == 'm3'
        ? totalWattage
        : _comps.fold(
            0.0,
            (acc, c) =>
                acc +
                (c.type != 'wire' && c.type != 'switch' && c.type != 'battery'
                    ? c.power
                    : 0),
          );

    // Atomic-view particles (only animate while the modal is open).
    if (_atomicOpen) {
      for (final p in _atomicParticles) {
        if (!p.isElectron) continue;
        p.x += p.vx;
        if (p.x > 600) p.x = 0;
        var hit = false;
        for (final a in _atomicParticles) {
          if (a.isElectron) continue;
          final dx = p.x - a.baseX, dy = p.y - a.baseY;
          if (math.sqrt(dx * dx + dy * dy) < 20) hit = true;
        }
        p.flash = hit && _rng.nextDouble() > 0.8;
      }
    }

    final changed =
        totalP.round() != _simPower.round() ||
        hasNichrome != _simHasNichrome ||
        fuseBlown != _simFuseBlown ||
        isClosed != _simClosed;
    _simPower = totalP;
    _simHasNichrome = hasNichrome;
    _simFuseBlown = fuseBlown;
    _simClosed = isClosed;
    if (changed) setState(() {});

    _checkActiveMission();
    _repaint.tick();
  }

  bool _missionSatisfied(String id) => switch (id) {
    'm1' => _thermal && _simHasNichrome && _simClosed,
    'm2' => _simFuseBlown,
    'm3' => _hours >= 10 && _simPower >= 500,
    _ => false,
  };

  /// The source's 1 s `setInterval` mission checker.
  void _checkActiveMission() {
    final id = _activeMissionId;
    if (_missionDone[id]! || !_missionSatisfied(id)) return;
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _missionDone[id] = true;
      _obsMissionId = id;
    });
  }

  String get _billText => ((_simPower / 1000) * _hours * 5).toStringAsFixed(
    2,
  ); // rate 5 per kWh, as source

  // -------------------------------------------------------- missions ----
  int _missionIndex(String id) => _missionIds.indexOf(id);

  void _setActiveMission(String id) {
    setState(() {
      _activeMissionId = id;
      if (id != 'm3') _hours = 0; // time control hidden outside the Meter Room
    });
  }

  /// Sidebar mission-card tap (source `handleStepClick`).
  void _handleMissionTap(String id) {
    _rt_playSfx(_rt_Sfx.scenario);
    _setActiveMission(id);
    if (_missionDone[id]!) {
      setState(() => _obsMissionId = id);
    }
  }

  void _closeObservation() {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _obsMissionId = null);
    final idx = _missionIndex(_activeMissionId);
    if (idx == _missionIds.length - 1 && _missionDone[_activeMissionId]!) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showFinalSuccess();
      });
    }
  }

  void _goToNextMission() {
    setState(() {
      _missionDone[_activeMissionId] = true;
      _obsMissionId = null;
    });
    final idx = _missionIndex(_activeMissionId);
    if (idx < _missionIds.length - 1) {
      _clearCircuit();
      _setActiveMission(_missionIds[idx + 1]);
      _rt_playSfx(
        _rt_Sfx.scenario,
      ); // the source's 'startup' sweep between zones
    }
  }

  void _goToPrevMission() {
    setState(() => _obsMissionId = null);
    final idx = _missionIndex(_activeMissionId);
    if (idx > 0) {
      final prevId = _missionIds[idx - 1];
      _setActiveMission(prevId);
      if (_missionDone[prevId]!) setState(() => _obsMissionId = prevId);
    }
  }

  void _showFinalSuccess() {
    _rt_playSfx(_rt_Sfx.success);
    _rt_showShellPopup(
      context,
      title: _tx.s('successModal.title'),
      message: _tx.s('successModal.body'),
      icon: Icons.emoji_events,
      color: _rt_Tw.green500,
      actions: [
        _rt_ActionButton(
          key: const ValueKey('btn-success-close'),
          label: _tx.s('successModal.close'),
          icon: Icons.close,
          color: _rt_Tw.slate500,
          onPressed: () => Navigator.of(context).pop(),
        ),
        _rt_ActionButton(
          key: const ValueKey('btn-success-restart'),
          label: _tx.s('successModal.restart'),
          icon: Icons.refresh,
          color: _rt_Tw.green600,
          onPressed: () {
            Navigator.of(context).pop();
            _hardReset();
          },
        ),
      ],
    );
  }

  void _hardReset() {
    setState(() {
      _clearCircuit();
      _time = 0;
      _spawnN = 0;
      _missionDone.updateAll((_, _) => false);
      _obsMissionId = null;
      _atomicOpen = false;
      _thermal = false;
      _schematic = false;
      _showLabels = true;
      _voltage = 10;
      _hours = 0;
      _zoomLv = 1;
      _activeMissionId = 'm1';
      _simPower = 0;
      _simHasNichrome = false;
      _simFuseBlown = false;
      _simClosed = false;
    });
  }

  void _clearCircuit() {
    _comps.clear();
    _nodes.clear();
    _selection = null;
    _dragNode = null;
    _dragComp = null;
  }

  // --------------------------------------------------------- palette ----
  List<_PalItem> get _palette {
    _Comp base(String type, String key, double x, double y) =>
        _Comp(type, x, y)..labelKey = key;
    final items = <_PalItem>[
      _PalItem(
        'wire',
        Icons.horizontal_rule,
        (x, y) => base('wire', 'wire', x, y),
      ),
      _PalItem(
        'battery',
        Icons.battery_full,
        (x, y) => base('battery', 'battery', x, y)..value = 10,
      ),
      _PalItem(
        'switch',
        Icons.toggle_off,
        (x, y) => base('switch', 'switch', x, y),
      ),
    ];
    switch (_activeMissionId) {
      case 'm1':
        items.add(
          _PalItem(
            'nichrome',
            Icons.waves,
            (x, y) => base('wire', 'nichrome', x, y)..material = 'nichrome',
          ),
        );
      case 'm2':
        items.addAll([
          _PalItem(
            'fuse',
            Icons.shield,
            (x, y) => base('fuse', 'fuse', x, y)..rating = 5,
          ),
          _PalItem(
            'adapter',
            Icons.power,
            (x, y) => base('resistor', 'adapter', x, y)..value = 5,
          ),
          _PalItem(
            'heater',
            Icons.local_fire_department,
            (x, y) => base('resistor', 'heater', x, y)..value = 2.5,
          ),
        ]);
      case 'm3':
        items.addAll([
          _PalItem(
            'bulb',
            Icons.lightbulb,
            (x, y) => base('bulb', 'bulb', x, y)
              ..value = 10
              ..nominalPower = 100,
          ),
          _PalItem(
            'fridge',
            Icons.ac_unit,
            (x, y) => base('resistor', 'fridge', x, y)
              ..value = 10
              ..nominalPower = 400,
          ),
        ]);
    }
    return items;
  }

  void _addFromPalette(_PalItem item, [Offset? world]) {
    final pos =
        world ??
        Offset(
          _canvasSize.width / 2 / _zoomLv,
          _canvasSize.height / 2 / _zoomLv + ((_spawnN % 5) - 2) * 36.0,
        );
    _spawnN++;
    final c = item.make(pos.dx - 40, pos.dy);
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _comps.add(c);
      _nodes.addAll([c.n1, c.n2]);
    });
  }

  // ---------------------------------------------------- canvas input ----
  Offset _toWorld(Offset local) => local / _zoomLv;

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

  _Comp? _hitComp(Offset world) {
    final thresh = 20 / _zoomLv;
    _Comp? hit;
    for (final c in _comps) {
      final a = Offset(c.n1.x, c.n1.y), b = Offset(c.n2.x, c.n2.y);
      final l2 = (b - a).distanceSquared;
      var t = l2 == 0
          ? 0.0
          : ((world - a).dx * (b - a).dx + (world - a).dy * (b - a).dy) / l2;
      t = t.clamp(0.0, 1.0);
      final d = (world - (a + (b - a) * t)).distance;
      if (d < thresh) hit = c;
    }
    return hit;
  }

  void _onTapUp(TapUpDetails d) {
    final world = _toWorld(d.localPosition);
    final hitN = _hitNode(world);
    if (hitN != null) return; // node tap: nothing (drag handles them)
    final hitC = _hitComp(world);
    if (hitC != null) {
      setState(() => _selection = hitC);
      if (hitC.type == 'switch') {
        hitC.isOpen = !hitC.isOpen;
        _rt_playSfx(_rt_Sfx.toggle);
      } else if (hitC.isNichrome) {
        _openAtomicView();
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
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final world = _toWorld(d.localPosition);
    if (_dragNode != null) {
      _dragNode!.x = world.dx;
      _dragNode!.y = world.dy;
    } else if (_dragComp != null) {
      final c = _dragComp!;
      c.n1.x = world.dx + _dragOff1.dx;
      c.n1.y = world.dy + _dragOff1.dy;
      c.n2.x = world.dx + _dragOff2.dx;
      c.n2.y = world.dy + _dragOff2.dy;
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
            math.sqrt((o.x - n.x) * (o.x - n.x) + (o.y - n.y) * (o.y - n.y)) <
                20) {
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
    _dragNode = null;
    _dragComp = null;
    setState(() {});
  }

  // ------------------------------------------------------- selection ----
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

  void _openAtomicView() {
    _rt_playSfx(_rt_Sfx.magic);
    _atomicParticles.clear();
    for (var i = 0; i < 30; i++) {
      _atomicParticles.add(
        _AtomParticle.atom(30.0 + (i % 6) * 80, 30.0 + (i ~/ 6) * 50),
      );
    }
    for (var i = 0; i < 15; i++) {
      _atomicParticles.add(
        _AtomParticle.electron(
          _rng.nextDouble() * 460,
          _rng.nextDouble() * 200,
        ),
      );
    }
    setState(() => _atomicOpen = true);
  }

  // -------------------------------------------------------------- UI ----
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final activeIdx = _missionIndex(_activeMissionId);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.orange500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF7C2D12)],
              headerSubtitleColor: Color(0xFFFDBA74),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.local_fire_department,
            ),
            onRestart: _hardReset,
            onZoomIn: () =>
                setState(() => _zoomLv = (_zoomLv * 1.1).clamp(0.5, 3.0)),
            onZoomOut: () =>
                setState(() => _zoomLv = (_zoomLv * 0.9).clamp(0.5, 3.0)),
            onResetView: () => setState(() => _zoomLv = 1),
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: _showLabels ? Icons.label : Icons.label_off,
                tooltip: _tx.s('ui.toggleLabels'),
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _showLabels = !_showLabels);
                },
              ),
            ],
            hint: _rt_StepHint(
              number: '${activeIdx + 1}',
              text: _tx.s('missions.$activeIdx.do'),
              label: _tx.s('missions.$activeIdx.title'),
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.bolt,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _buildCanvas(),
            canvasOverlays: [
              // Load + bill HUD (top centre; the source's top-right stats).
              Positioned(
                top: 10,
                left: 60,
                right: 60,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _rt_HudCard(
                        value: '${_simPower.round()} W',
                        label: _tx.s('load'),
                        color: _rt_Tw.blue500,
                      ),
                      const SizedBox(width: 10),
                      _rt_HudCard(
                        value: '\$$_billText',
                        label: _tx.s('bill'),
                        color: _rt_Tw.green500,
                      ),
                    ],
                  ),
                ),
              ),
              // Component palette (left, like the source).
              Positioned(
                left: 10,
                top: 64,
                bottom: 60,
                child: _paletteColumn(),
              ),
              // Observation popup (bottom-left, like the source obs modal).
              if (_obsMissionId != null)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _observationCard(_obsMissionId!),
                ),
              // Atomic view modal.
              if (_atomicOpen) Positioned.fill(child: _atomicOverlay()),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------- canvas ----
  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, c) {
        _canvasSize = Size(c.maxWidth, c.maxHeight);
        return DragTarget<int>(
          onAcceptWithDetails: (d) {
            final box =
                _canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(d.offset + const Offset(28, 20));
            _addFromPalette(_palette[d.data], _toWorld(local));
          },
          builder: (context, _, _) => GestureDetector(
            key: _canvasKey,
            behavior: HitTestBehavior.opaque,
            // Report the pan start where the finger lands, not after the
            // touch slop, so a 20 px component end can be picked up.
            dragStartBehavior: DragStartBehavior.down,
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
        width: 96,
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
            Text(
              _tx.s('ui.palette').toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: _rt_Lab.textFaint,
              ),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < items.length; i++) ...[
              Draggable<int>(
                data: i,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _rt_Tw.blue500.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(items[i].icon, size: 22, color: Colors.white),
                  ),
                ),
                child: _paletteChip(items[i], i),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _paletteChip(_PalItem item, int index) {
    return GestureDetector(
      key: ValueKey('pal-${item.labelKey}'),
      onTap: () => _addFromPalette(item),
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Column(
          children: [
            Icon(item.icon, size: 18, color: _rt_Tw.blue400),
            const SizedBox(height: 2),
            Text(
              _tx.s('components.${item.labelKey}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _observationCard(String id) {
    final idx = _missionIndex(id);
    final isLast = idx == _missionIds.length - 1;
    return Container(
      width: 340,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _rt_Tw.blue500.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check, size: 16, color: _rt_Tw.blue500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s('obs.title').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: _rt_Lab.text,
                  ),
                ),
              ),
              InkWell(
                key: const ValueKey('btn-obs-close'),
                onTap: _closeObservation,
                child: Icon(Icons.close, size: 18, color: _rt_Lab.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _tx.s('missions.$idx.observe'),
            style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.35),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue500)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('obs.learned').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tx.s('missions.$idx.learn'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _rt_Lab.text,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                key: const ValueKey('btn-obs-prev'),
                onPressed: idx == 0 ? null : _goToPrevMission,
                icon: Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: _rt_Lab.textMuted,
                ),
                label: Text(
                  _tx.s('obs.prev'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              if (!isLast)
                _rt_ActionButton(
                  key: const ValueKey('btn-obs-next'),
                  label: _tx.s('obs.next'),
                  icon: Icons.arrow_forward,
                  color: _rt_Tw.blue600,
                  sound: null,
                  onPressed: _goToNextMission,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _atomicOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: Container(
        width: 500,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _rt_Tw.slate900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _rt_Tw.slate700),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tx.s('atomic.title'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _tx.s('atomic.desc'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: _rt_Tw.slate400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  key: const ValueKey('btn-atomic-close'),
                  onTap: () {
                    _rt_playSfx(_rt_Sfx.tap);
                    setState(() => _atomicOpen = false);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20, color: _rt_Tw.slate400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                height: 210,
                child: CustomPaint(painter: _AtomicPainter(this, _repaint)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ----
  Widget _exploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('mainObjTitle'),
          desc: _tx.s('mainObj'),
          accent: _rt_Tw.orange500,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('tabs.explore'),
                icon: Icons.flag,
                color: _rt_Tw.orange400,
              ),
              for (var i = 0; i < _missionIds.length; i++) _missionCard(i),
              const SizedBox(height: 8),
              _rt_SectionLabel(
                _tx.s('controls'),
                icon: Icons.tune,
                color: _rt_Tw.blue400,
              ),
              _controlsCard(),
              const SizedBox(height: 8),
              _rt_SectionLabel(
                _tx.s('ui.placed'),
                icon: Icons.category,
                color: _rt_Tw.blue400,
              ),
              _placedComponents(),
              const SizedBox(height: 14),
              // ---- notes foot: concept, teacher guide, outcomes ----
              _rt_SectionLabel(
                _tx.s('tabs.context'),
                icon: Icons.menu_book,
                color: _rt_Tw.amber400,
              ),
              for (var i = 0; i < _tx.list('context').length; i++)
                _rt_InfoCard(
                  title: _tx.s('context.$i.title'),
                  body: _tx.s('context.$i.text'),
                  color: _rt_Tw.amber500,
                  icon: Icons.lightbulb_outline,
                ),
              _rt_InfoCard(
                title: _tx.s('ui.formulaTitle'),
                body: _tx.s('ui.formulas'),
                color: _rt_Tw.violet500,
                icon: Icons.functions,
              ),
              _rt_SectionLabel(
                _tx.s('tabs.guide'),
                icon: Icons.school,
                color: _rt_Tw.blue400,
              ),
              for (var i = 0; i < _tx.list('guide').length; i++)
                _rt_InfoCard(
                  title: _tx.s('guide.$i.phase'),
                  color: _rt_Tw.blue500,
                  icon: Icons.playlist_add_check,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      for (final s in _tx.list('guide.$i.steps'))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: _rt_Tw.blue400,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$s',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: _rt_Lab.text,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              _rt_SectionLabel(
                _tx.s('outcomesTitle'),
                icon: Icons.emoji_events,
                color: _rt_Tw.green400,
              ),
              _rt_InfoCard(
                color: _rt_Tw.green500,
                leftBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final o in _tx.list('outcomes'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 13,
                              color: _rt_Tw.green500,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$o',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _rt_Lab.text,
                                  height: 1.35,
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
          ),
        ),
      ],
    );
  }

  Widget _missionCard(int i) {
    final id = _missionIds[i];
    final active = _activeMissionId == id;
    final done = _missionDone[id]!;
    return GestureDetector(
      key: ValueKey('mission-$id'),
      onTap: () => _handleMissionTap(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: active
              ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
              : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _rt_Tw.blue500 : _rt_Lab.border,
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
                    _tx.s('missions.$i.title'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? _rt_Tw.green500 : Colors.transparent,
                    border: Border.all(
                      color: done ? _rt_Tw.green500 : _rt_Lab.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _doObserveLine(
              _tx.s('do'),
              _tx.s('missions.$i.do'),
              _rt_Tw.blue500,
            ),
            const SizedBox(height: 4),
            _doObserveLine(
              _tx.s('observe'),
              _tx.s('missions.$i.observe'),
              _rt_Tw.orange500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _doObserveLine(String tag, String text, Color color) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${tag.toUpperCase()}: ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 11,
                color: _rt_Lab.textMuted,
                height: 1.3,
              ),
            ),
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
            color: _rt_Tw.blue500,
            onChanged: (v) => setState(() {
              _voltage = v;
              for (final c in _comps) {
                if (c.type == 'battery') c.value = v;
              }
            }),
          ),
          if (_activeMissionId == 'm3')
            _rt_LabeledSlider(
              key: const ValueKey('slider-time'),
              label: _tx.s('time'),
              value: _hours.toDouble(),
              min: 0,
              max: 24,
              divisions: 24,
              valueText: '${_hours}h',
              color: _rt_Tw.green500,
              onChanged: (v) => setState(() => _hours = v.round()),
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
                  child: Text(
                    _tx.s('ui.selection').toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.textFaint,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _rt_Lab.overlay,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _tx.s('components.${sel.labelKey}') +
                        (sel.type == 'battery' ? ' ${sel.value.round()}V' : ''),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: _rt_Lab.text,
                    ),
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
                  label: _tx.s('ui.delete'),
                  icon: Icons.delete,
                  color: _rt_Tw.red500,
                  sound: _rt_Sfx.wrong,
                  onPressed: _deleteSelection,
                ),
                if (sel.type == 'switch')
                  _rt_ActionButton(
                    key: const ValueKey('btn-toggle-switch'),
                    label: _tx.s('ui.toggleSwitch'),
                    icon: Icons.toggle_on,
                    color: _rt_Tw.slate500,
                    sound: _rt_Sfx.toggle,
                    onPressed: () => setState(() => sel.isOpen = !sel.isOpen),
                  ),
                if (sel.isNichrome)
                  _rt_ActionButton(
                    key: const ValueKey('btn-atomic'),
                    label: _tx.s('ui.atomicView'),
                    icon: Icons.blur_on,
                    color: _rt_Tw.violet600,
                    sound: null,
                    onPressed: _openAtomicView,
                  ),
                if (sel.type == 'fuse' && sel.isBlown)
                  _rt_ActionButton(
                    key: const ValueKey('btn-reset-fuse'),
                    label: _tx.s('ui.replaceFuse'),
                    icon: Icons.build,
                    color: _rt_Tw.amber600,
                    onPressed: () => setState(() => sel.isBlown = false),
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
          color: active
              ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
              : _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? _rt_Tw.blue500 : _rt_Lab.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: _rt_Lab.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placedComponents() {
    final visible = _comps;
    if (visible.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Text(
          _tx.s('ui.emptyList'),
          style: TextStyle(
            fontSize: 11,
            color: _rt_Lab.textFaint,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < visible.length; i++)
          GestureDetector(
            key: ValueKey('sel-$i'),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() {
                _selection = visible[i];
                if (visible[i].type == 'battery') _voltage = visible[i].value;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: identical(_selection, visible[i])
                    ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
                    : _rt_Lab.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: identical(_selection, visible[i])
                      ? _rt_Tw.blue500
                      : _rt_Lab.border,
                  width: 1.5,
                ),
              ),
              child: Text(
                _tx.s('components.${visible[i].labelKey}') +
                    (visible[i].isBlown ? ' ✕' : ''),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.text,
                ),
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

/// Draws the whole circuit world: dotted background, wires, nodes,
/// components (realistic or schematic), thermal glow, electron flow and
/// labels -- a direct port of the source's `loop()` drawing section.
class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.s, Listenable repaint) : super(repaint: repaint);

  final _Cl10SCh11A6HeatingEffectandPowerPlantPageState s;

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
        if (c.current.abs() > 0.1 && !c.isBlown && !c.isOpen) {
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
            if (pos > 5 && pos < len - 5) {
              canvas.drawCircle(Offset(pos, 0), 3, ePaint);
            }
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

    // Selection glow.
    if (identical(s._selection, c)) {
      canvas.drawLine(
        Offset.zero,
        Offset(len, 0),
        Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: 0.55)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Thermal glow (H = I²Rt heating up the component).
    if (s._thermal && (c.power > 1 || c.labelKey == 'heater' || c.isNichrome)) {
      final heat = math.min(c.power / 50, 1.0);
      canvas.drawLine(
        Offset.zero,
        Offset(len, 0),
        Paint()
          ..color = Color.fromRGBO(
            255,
            (100 - heat * 100).round().clamp(0, 255),
            0,
            0.6,
          )
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
      _text(canvas, _tx.s('components.${c.labelKey}'), Offset(mx, my - 20));
      if (c.type == 'battery') {
        _text(canvas, '${c.value.round()}V', Offset(mx, my + 20));
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
        final coil = Path()..moveTo(0, 0);
        for (double i = 0; i <= len; i += 5) {
          coil.lineTo(i, (i.round() % 10 == 0) ? -8 : 8);
        }
        canvas.drawPath(
          coil,
          Paint()
            ..color = const Color(0xFF94A3B8)
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        if (c.current > 0.5) {
          canvas.drawPath(
            coil,
            Paint()
              ..color = Color.fromRGBO(239, 68, 68, math.min(1, c.current / 5))
              ..strokeWidth = 4
              ..style = PaintingStyle.stroke,
          );
        }
      } else {
        canvas.drawLine(
          Offset.zero,
          Offset(len, 0),
          Paint()
            ..color = const Color(0xFFEAB308)
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
      }
    } else if (c.type == 'battery') {
      canvas.drawLine(Offset.zero, Offset(mid - 32, 0), lead);
      canvas.drawLine(Offset(mid + 35, 0), Offset(len, 0), lead);
      canvas.drawRect(
        Rect.fromLTWH(mid - 30, -15, 60, 30),
        Paint()..color = const Color(0xFF0F172A),
      );
      final copper = Paint()..color = const Color(0xFFD97706);
      canvas.drawRect(Rect.fromLTWH(mid + 25, -8, 10, 16), copper);
      canvas.drawRect(Rect.fromLTWH(mid + 15, -15, 15, 30), copper);
      canvas.drawRect(
        Rect.fromLTWH(mid - 32, -10, 4, 20),
        Paint()..color = const Color(0xFFCBD5E1),
      );
      _icon(canvas, Icons.bolt, Offset(mid - 5, 0), 14, Colors.white);
    } else if (c.type == 'bulb') {
      canvas.drawLine(Offset.zero, Offset(mid - 10, 0), lead);
      canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), lead);
      canvas.drawRect(
        Rect.fromLTWH(mid - 10, -10, 20, 20),
        Paint()..color = const Color(0xFF94A3B8),
      );
      final b = math.min(c.power / 20, 1.0);
      if (b > 0.1) {
        canvas.drawCircle(
          Offset(mid, -25),
          22,
          Paint()
            ..color = const Color(0xFFFACC15).withValues(alpha: 0.5 * b)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * b + 4),
        );
      }
      canvas.drawCircle(
        Offset(mid, -25),
        20,
        Paint()
          ..color = b > 0.1
              ? Color.fromRGBO(255, 255, 100, 0.4 + b * 0.6)
              : Colors.white.withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        Offset(mid, -25),
        20,
        Paint()
          ..color = const Color(0xFFCBD5E1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final fil = Path()
        ..moveTo(mid - 5, -10)
        ..lineTo(mid - 5, -25)
        ..lineTo(mid + 5, -25)
        ..lineTo(mid + 5, -10);
      canvas.drawPath(
        fil,
        Paint()
          ..color = b > 0.1 ? const Color(0xFFFEF08A) : const Color(0xFF475569)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    } else if (c.type == 'fuse') {
      canvas.drawLine(Offset.zero, Offset(mid - 24, 0), lead);
      canvas.drawLine(Offset(mid + 24, 0), Offset(len, 0), lead);
      final tube = Rect.fromLTWH(mid - 20, -8, 40, 16);
      canvas.drawRect(
        tube,
        Paint()..color = const Color(0xFFC8E6FF).withValues(alpha: 0.3),
      );
      canvas.drawRect(
        tube,
        Paint()
          ..color = const Color(0xFFCBD5E1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final cap = Paint()..color = const Color(0xFF94A3B8);
      canvas.drawRect(Rect.fromLTWH(mid - 24, -8, 6, 16), cap);
      canvas.drawRect(Rect.fromLTWH(mid + 18, -8, 6, 16), cap);
      if (!c.isBlown) {
        canvas.drawLine(
          Offset(mid - 18, 0),
          Offset(mid + 18, 0),
          Paint()
            ..color = const Color(0xFFEF4444)
            ..strokeWidth = 1.5,
        );
      } else {
        final xp = Paint()
          ..color = const Color(0xFFEF4444)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(mid - 5, -5), Offset(mid + 5, 5), xp);
        canvas.drawLine(Offset(mid - 5, 5), Offset(mid + 5, -5), xp);
      }
    } else if (c.type == 'switch') {
      canvas.drawLine(Offset.zero, Offset(mid - 20, 0), lead);
      canvas.drawLine(Offset(mid + 20, 0), Offset(len, 0), lead);
      canvas.drawRect(
        Rect.fromLTWH(mid - 20, -10, 40, 20),
        Paint()..color = const Color(0xFF334155),
      );
      final term = Paint()..color = const Color(0xFFFBBF24);
      canvas.drawCircle(Offset(mid - 12, 0), 4, term);
      canvas.drawCircle(Offset(mid + 12, 0), 4, term);
      final lever = Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(mid - 12, 0),
        c.isOpen ? Offset(mid + 10, -25) : Offset(mid + 12, 0),
        lever,
      );
    } else if (c.type == 'resistor') {
      canvas.drawLine(Offset.zero, Offset(mid - 15, 0), lead);
      canvas.drawLine(Offset(mid + 15, 0), Offset(len, 0), lead);
      final body = Rect.fromLTWH(mid - 15, -15, 30, 30);
      canvas.drawRect(body, Paint()..color = const Color(0xFFF1F5F9));
      canvas.drawRect(
        body,
        Paint()
          ..color = const Color(0xFFCBD5E1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final icon = switch (c.labelKey) {
        'fridge' => Icons.ac_unit,
        'heater' => Icons.local_fire_department,
        _ => Icons.power,
      };
      _icon(canvas, icon, Offset(mid, 0), 16, const Color(0xFF475569));
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
      canvas.drawLine(
        Offset(mid + 5, -5),
        Offset(mid + 5, 5),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4,
      );
    } else if (c.type == 'bulb') {
      canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
      canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
      canvas.drawCircle(Offset(mid, 0), 10, p);
      final z = Path()
        ..moveTo(mid - 7, 0)
        ..lineTo(mid - 3, -7)
        ..lineTo(mid + 3, 7)
        ..lineTo(mid + 7, 0);
      canvas.drawPath(z, p);
    } else if (c.type == 'switch') {
      canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
      canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
      canvas.drawLine(
        Offset(mid - 10, 0),
        c.isOpen ? Offset(mid + 8, -8) : Offset(mid + 10, 0),
        p,
      );
      canvas.drawCircle(Offset(mid - 10, 0), 2, p);
    } else if (c.type == 'fuse') {
      canvas.drawLine(Offset.zero, Offset(len, 0), p);
      canvas.drawRect(Rect.fromLTWH(mid - 15, -6, 30, 12), p);
      if (!c.isBlown) {
        final s = Path()
          ..moveTo(mid - 15, 0)
          ..cubicTo(mid, -10, mid, 10, mid + 15, 0);
        canvas.drawPath(s, p);
      }
    } else if (c.type == 'resistor') {
      canvas.drawLine(Offset.zero, Offset(mid - 10, 0), p);
      canvas.drawLine(Offset(mid + 10, 0), Offset(len, 0), p);
      final z = Path()..moveTo(mid - 10, 0);
      for (var i = 0; i < 4; i++) {
        z.lineTo(mid - 10 + i * 5 + 2.5, (i % 2 == 0) ? -6 : 6);
      }
      z.lineTo(mid + 10, 0);
      canvas.drawPath(z, p);
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

  void _icon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) => true;
}

/// The "Atomic View" modal canvas: vibrating lattice atoms and drifting
/// electrons that flash white when they collide (Joule heating, up close).
class _AtomicPainter extends CustomPainter {
  _AtomicPainter(this.s, Listenable repaint) : super(repaint: repaint);

  final _Cl10SCh11A6HeatingEffectandPowerPlantPageState s;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF020617),
    );
    final sx = size.width / 600, sy = size.height / 300;
    canvas.save();
    canvas.scale(sx, sy);

    final atomPaint = Paint()..color = const Color(0xFF334155);
    for (final p in s._atomicParticles) {
      if (p.isElectron) continue;
      final vx = (s._rng.nextDouble() - 0.5) * 3,
          vy = (s._rng.nextDouble() - 0.5) * 3;
      canvas.drawCircle(Offset(p.baseX + vx, p.baseY + vy), 15, atomPaint);
    }
    final ePaint = Paint()..color = const Color(0xFFFACC15);
    final flashPaint = Paint()..color = Colors.white;
    for (final p in s._atomicParticles) {
      if (!p.isElectron) continue;
      if (p.flash) canvas.drawCircle(Offset(p.x, p.y), 8, flashPaint);
      canvas.drawCircle(Offset(p.x, p.y), 4, ePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AtomicPainter oldDelegate) => true;
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
            color: active ? _rt_Tw.orange500 : _rt_Lab.surface,
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
