// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 12.5: The Domestic Safety Hub
// Converted from Cl10S-Ch12-A5-TheDomesticSafetyHub.html (three.js + OrbitControls -> mini3d).
//
// A domestic wiring room: electric meter, main fuse, switch board and three
// parallel appliances (bulb, fan, heater) fed by live/neutral wires. Three
// steps: (1) switch ON the mains and watch parallel appliances work
// independently; (2) overload the circuit with the load slider until the 5 A
// fuse blows (spark burst, replace-fuse flow); (3) simulate an insulation
// fault on the heater and compare earthing OFF (body live, DANGER flash) vs
// ON (current leaks to ground and blows the fuse safely). The Why?, Guide
// and Outcomes panels plus the Finish button follow the step list.

// --- TRANSLATION DATA (source `TEXT` block; `te:` ignored) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

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
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const teal900 = Color(0xFF134E4A);
  static const blue600 = Color(0xFF2563EB);
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);
  static const indigo900 = Color(0xFF312E81);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
}

/// Pill action button (the HTML `.action-btn`). Plays a click sound.
class _rt_ActionButton extends StatelessWidget {
  const _rt_ActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.color = _rt_Tw.teal600,
    this.expand = false,
    this.sound = _rt_Sfx.click,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done = false;
  final bool expand;
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
    this.tag,
    this.color = _rt_Tw.teal600,
    this.icon,
    this.leftBorder = false,
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag;
  final Color color;
  final IconData? icon;
  final Widget? child = null;
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
    this.canvasOverlays = const [],
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.toolbarExtras = const [],
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

  final _rt_StepHint? hint = null;

  /// Optional content above the tabs (e.g. scenario selector).
  final Widget? sidebarTop = null;
  final Color? canvasBackground;

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

/// Mutable 3D vector (mirrors the parts of THREE.Vector3 the activities use).
class _rt_V3 {
  _rt_V3([this.x = 0, this.y = 0, this.z = 0]);

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
  _rt_V3 scaleBy(double s) => set(x * s, y * s, z * s);

  double dot(_rt_V3 o) => x * o.x + y * o.y + z * o.z;
  _rt_V3 cross(_rt_V3 o) =>
      _rt_V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

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
            m[i * 3] * o.m[j] +
            m[i * 3 + 1] * o.m[3 + j] +
            m[i * 3 + 2] * o.m[6 + j];
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

  /// THREE.BoxGeometry(w, h, d). Face groups: 0 +x, 1 -x, 2 +y, 3 -y, 4 +z, 5 -z
  /// (the three.js material-array order).
  factory _rt_Geometry3D.box(double w, double h, double d) {
    final x = w / 2, y = h / 2, z = d / 2;
    final v = [
      _rt_V3(-x, -y, -z),
      _rt_V3(x, -y, -z),
      _rt_V3(x, y, -z),
      _rt_V3(-x, y, -z), //
      _rt_V3(-x, -y, z), _rt_V3(x, -y, z), _rt_V3(x, y, z), _rt_V3(-x, y, z),
    ];
    return _rt_Geometry3D(
      v,
      [
        [5, 1, 2, 6], // +x
        [0, 4, 7, 3], // -x
        [7, 6, 2, 3], // +y
        [0, 1, 5, 4], // -y
        [4, 5, 6, 7], // +z
        [1, 0, 3, 2], // -z
      ],
      [0, 1, 2, 3, 4, 5],
    );
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
      verts.add(
        _rt_V3(radiusBottom * s, -hy, radiusBottom * c),
      ); // bottom -> 2i+1
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

  /// THREE.PlaneGeometry(width, height, wSegs, hSegs) in the XY plane facing +Z.
  factory _rt_Geometry3D.plane(
    double width,
    double height, {
    int widthSegments = 1,
    int heightSegments = 1,
  }) {
    final verts = <_rt_V3>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      for (var ix = 0; ix <= widthSegments; ix++) {
        verts.add(
          _rt_V3(
            -width / 2 + ix / widthSegments * width,
            -height / 2 + iy / heightSegments * height,
            0,
          ),
        );
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

  /// THREE.RingGeometry(innerRadius, outerRadius, segments, ...), XY plane.
  factory _rt_Geometry3D.ring(
    double innerRadius,
    double outerRadius, {
    int segments = 32,
    double thetaStart = 0,
    double thetaLength = math.pi * 2,
  }) {
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

  void clear() {
    for (final c in children) {
      c.parent = null;
    }
    children.clear();
  }

  _rt_Xf get localTransform {
    final r =
        rotationMatrix ?? _rt_M3.eulerXYZ(rotation.x, rotation.y, rotation.z);
    return _rt_Xf(r.scaled(scale), position.clone());
  }

  _rt_Xf get worldTransform {
    final local = localTransform;
    return parent == null ? local : parent!.worldTransform * local;
  }

  _rt_V3 get worldPosition => worldTransform.t;

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
  _rt_Mesh3D(this.geometry, this.material, {super.name});

  _rt_Geometry3D geometry;
  _rt_Material3D material;
}

/// Smooth sphere drawn as a shaded disc (fast and perfectly round). Use
/// `_rt_Mesh3D(_rt_Geometry3D.sphere(...))` for partial spheres.
class _rt_Sphere3D extends _rt_Node3D {
  _rt_Sphere3D(this.radius, this.material);

  double radius;
  _rt_Material3D material;
}

/// Polyline in 3D (THREE.Line / LineSegments). Width is in screen pixels.
class _rt_Line3D extends _rt_Node3D {
  _rt_Line3D(
    this.points, {
    this.color = const Color(0xFFFFFFFF),
    this.width = 2,
    this.segments = false,
  });

  List<_rt_V3> points;
  Color color;
  double width;
  double opacity = 1;
  bool dashed = false;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments;
  bool closed = false;
}

/// Point cloud (THREE.Points). Size is in screen pixels, scaled by
/// perspective when [sizeAttenuation] is true.
class _rt_Points3D extends _rt_Node3D {
  _rt_Points3D(this.points);

  List<_rt_V3> points;
  Color color = const Color(0xFFFFFFFF);
  List<Color>? colors;
  double size = 4;
  double opacity = 1;
  bool sizeAttenuation = true;
}

/// Billboard text (THREE.Sprite with a canvas texture, or CSS2D labels).
class _rt_Label3D extends _rt_Node3D {
  _rt_Label3D(
    this.text, {
    super.position,
    this.pixelHeight,
    this.color = const Color(0xFFFFFFFF),
    this.background,
    this.borderColor,
    this.alwaysOnTop = true,
  });

  String text;

  /// Text height in world units (scales with distance like a sprite).
  double worldHeight = 1.0;

  /// If set, fixed on-screen font size instead of [worldHeight].
  double? pixelHeight;
  Color color;
  Color? background;
  Color? borderColor;
  bool bold = true;

  /// THREE `depthTest: false` — drawn above all geometry.
  bool alwaysOnTop;
}

/// Lights. Ambient + directional + point lights are supported (Lambert).
class _rt_Light3D {
  _rt_Light3D.ambient({this.intensity = 0.6})
    : kind = _rt_LightKind.ambient,
      position = _rt_V3();
  _rt_Light3D.directional(this.position, {this.intensity = 0.8})
    : kind = _rt_LightKind.directional;
  _rt_Light3D.point(
    this.position, {
    this.color = const Color(0xFFFFFFFF),
    this.intensity = 1.0,
    this.distance = 0,
  }) : kind = _rt_LightKind.point;

  final _rt_LightKind kind;
  _rt_V3 position;
  Color color = const Color(0xFFFFFFFF);
  Color groundColor = const Color(0xFF444444);
  double intensity;
  double distance = 0;
  bool enabled = true;
}

enum _rt_LightKind { ambient, directional, point, hemisphere }

/// Root container: node tree + lights + background.
class _rt_Scene3D {
  _rt_Scene3D({this.backgroundGradient}) {
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
  _rt_Camera3D({this.fov = 45, _rt_V3? position, _rt_V3? target})
    : position = position ?? _rt_V3(0, 10, 30),
      target = target ?? _rt_V3() {
    saveHome();
  }

  /// Vertical field of view in degrees.
  double fov;
  final _rt_V3 position;

  /// OrbitControls.target (the point the camera looks at).
  final _rt_V3 target;
  double near = 0.1;

  /// THREE camera.zoom (scales the image without moving the camera).
  double zoom = 1;

  bool orthographic = false;

  /// Visible world height for the orthographic camera at zoom 1.
  double orthoHeight = 20;

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
      _fromSpherical(
        r,
        (theta + dTheta).clamp(minAzimuthAngle, maxAzimuthAngle),
        (phi + dPhi).clamp(minPolarAngle, maxPolarAngle),
      );
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
  _rt_ProjectionFrame._(
    this.camera,
    this.size,
    this.right,
    this.up,
    this.fwd,
    this.focal,
  ) : eye = camera.position.clone(),
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
                atten = math
                    .pow(math.max(0.0, 1 - dist / l.distance), 2)
                    .toDouble();
              }
            }
            final ndl = math.max(0.0, n.dot(dir)) * l.intensity * atten;
            r += lc.r * ndl;
            g += lc.g * ndl;
            b += lc.b * ndl;
            if (m.shininess > 0 && ndl > 0) {
              final h = (dir + view).normalized();
              final spec =
                  math.pow(math.max(0.0, n.dot(h)), 8 + m.shininess * 56) *
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
  void _mesh(
    _rt_Mesh3D n,
    _rt_Xf xf,
    _rt_ProjectionFrame pf,
    List<_Item> items,
    List<_Pickable> picks,
  ) {
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
      var nx = 0.0,
          ny = 0.0,
          nz = 0.0,
          cx = 0.0,
          cy = 0.0,
          cz = 0.0,
          depth = 0.0;
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
      final view = camera.orthographic
          ? -pf.fwd
          : (pf.eye - center).normalize();
      final facing = normal.dot(view) >= 0;
      if (!facing && !m.doubleSided && !m.wireframe) continue;
      if (!facing) normal = -normal;

      final gi = g.faceGroups != null && fi < g.faceGroups!.length
          ? g.faceGroups![fi]
          : 0;
      final base = (m.faceColors != null && gi < m.faceColors!.length)
          ? m.faceColors![gi]
          : m.color;
      final color = _shade(m, base, normal, center, view);

      final path = Path()..addPolygon(pts, true);

      final d = depth + n.depthBias;
      items.add(
        _Item(d, (c) {
          if (m.wireframe) {
            c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = m.edgeWidth
                ..color = color,
            );
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
                ..strokeWidth = 0.7,
            );
          }
          if (m.edgeColor != null) {
            c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = m.edgeWidth
                ..color = m.edgeColor!,
            );
          }
        }),
      );
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
  void _sphere(
    _rt_Sphere3D n,
    _rt_Xf xf,
    _rt_ProjectionFrame pf,
    List<_Item> items,
    List<_Pickable> picks,
  ) {
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

    items.add(
      _Item(d, (canvas) {
        if (m.wireframe) {
          canvas.drawCircle(
            sp,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = lit,
          );
          return;
        }
        if (m.unlit) {
          canvas.drawCircle(sp, r, Paint()..color = lit);
        } else {
          final hi = Color.lerp(
            lit,
            Colors.white.withValues(alpha: lit.a),
            0.35 + m.shininess * 0.4,
          )!;
          final lo = Color.lerp(
            lit,
            Colors.black.withValues(alpha: lit.a),
            0.45,
          )!;
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
              ..color = m.edgeColor!,
          );
        }
      }),
    );
    if (n.pickable && n.isVisibleInTree) {
      picks.add(_Pickable.circle(n, sp, r, d));
    }
  }

  // --------------------------------------------------------------- lines ---
  void _line(
    _rt_Line3D n,
    _rt_Xf xf,
    _rt_ProjectionFrame pf,
    List<_Item> items,
  ) {
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
      items.add(
        _Item(d, (c) {
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
        }),
      );
    }
  }

  // -------------------------------------------------------------- points ---
  void _points(
    _rt_Points3D n,
    _rt_Xf xf,
    _rt_ProjectionFrame pf,
    List<_Item> items,
  ) {
    for (var i = 0; i < n.points.length; i++) {
      final w = xf.apply(n.points[i]);
      final s = pf.project(w);
      if (s == null) continue;
      final z = pf.depthOf(w);
      final base = n.colors != null && i < n.colors!.length
          ? n.colors![i]
          : n.color;
      final col = base.withValues(alpha: base.a * n.opacity);
      final r = n.sizeAttenuation
          ? math.max(0.5, n.size * pf.pixelsPerUnit(z) * 0.05)
          : n.size / 2;
      items.add(
        _Item(z + n.depthBias, (c) => c.drawCircle(s, r, Paint()..color = col)),
      );
    }
  }

  // -------------------------------------------------------------- labels ---
  void _label(
    _rt_Label3D n,
    _rt_Xf xf,
    _rt_ProjectionFrame pf,
    List<_Item> items,
    List<_Pickable> picks,
  ) {
    if (n.text.isEmpty) return;
    final w = xf.t;
    final s = pf.project(w);
    if (s == null) return;
    final z = pf.depthOf(w);
    final fontSize =
        (n.pixelHeight ??
                n.worldHeight * xf.maxScale * pf.pixelsPerUnit(z) * 0.6)
            .clamp(5.0, 72.0);
    final key =
        '${n.text}|${fontSize.toStringAsFixed(1)}|${n.color.toARGB32()}|${n.bold}';
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
      center: s,
      width: tp.width + padH * 2,
      height: tp.height + padV * 2,
    );
    final d = z + n.depthBias;
    items.add(
      _Item(d, (c) {
        if (n.background != null) {
          final rr = RRect.fromRectAndRadius(
            rect,
            Radius.circular(fontSize * 0.35),
          );
          c.drawRRect(rr, Paint()..color = n.background!);
          if (n.borderColor != null) {
            c.drawRRect(
              rr,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2
                ..color = n.borderColor!,
            );
          }
        }
        tp.paint(c, s - Offset(tp.width / 2, tp.height / 2));
      }),
    );
    if (n.pickable && n.isVisibleInTree) {
      picks.add(
        _Pickable.path(n, Path()..addRect(rect), n.alwaysOnTop ? -1e9 : d),
      );
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
    required this.scene,
    required this.camera,
    this.controller,
    this.onFrame,
    this.onTap,
    this.cameraControls = true,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
  final void Function(_rt_SceneEvent e)? onTap;
  final bool Function(_rt_SceneEvent e)? onPointerDown = null;
  final void Function(_rt_SceneEvent e)? onPointerMove = null;
  final void Function(_rt_SceneEvent e)? onPointerUp = null;
  final void Function(_rt_SceneEvent e)? onHover = null;

  /// Set false to disable orbit/pan/zoom gestures entirely.
  final bool cameraControls;

  @override
  State<_rt_Scene3DView> createState() => _Scene3DViewState();
}

class _Scene3DViewState extends State<_rt_Scene3DView>
    with SingleTickerProviderStateMixin {
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
    return _rt_SceneEvent(
      p,
      hits.isEmpty ? null : hits.first,
      frame.ray(p),
      frame,
      hits,
    );
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

    final panMode =
        (widget.controller?.mode == _rt_DragMode.pan) ||
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
    return LayoutBuilder(
      builder: (context, c) {
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
      },
    );
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
  _rt_TweenRunner();

  final bool resumeOnCancel = true;
  final List<_Tween> _active = [];

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
  const _rt_RotatePanToggle({
    required this.controller,
    this.accent = _rt_Tw.teal600,
  });

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
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            b(
              _rt_DragMode.rotate,
              Icons.threesixty,
              _rt_tr('Rotate', 'घुमाएँ'),
            ),
            const SizedBox(height: 4),
            b(
              _rt_DragMode.pan,
              Icons.pan_tool_outlined,
              _rt_tr('Pan', 'खिसकाएँ'),
            ),
          ],
        );
      },
    );
  }
}

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'intro': {
      'title': 'The Domestic Safety Hub',
      'subtitle': 'Class 10 • Magnetic Effects of Electric Current',
      'button': 'Enter Hub',
      'footnote': 'Live • Neutral • Earth • Fuse',
    },
    'headerTitle': 'The Domestic Safety Hub',
    'headerSubtitle': 'Class 10 • Magnetic Effects & Circuits',
    'mission': {
      'label': 'Mission Objective',
      'text':
          'Wire the house, prevent fire using a fuse, and protect users with earthing.',
    },
    'procedure': 'Procedure',
    'steps': [
      {
        't': '1. Domestic Circuit',
        'd': 'Switch ON Mains. Observe parallel appliances.',
      },
      {
        't': '2. Overloading (Fuse)',
        'd': 'Increase load. Watch current rise and Fuse blow.',
      },
      {
        't': '3. Short Circuit (Earthing)',
        'd': 'Simulate leakage. Compare Earth OFF vs ON.',
      },
    ],
    'deck': {
      'title': 'Circuit Board',
      'main': 'Main Supply',
      'load': 'Load (Amp)',
      'current': 'Current',
      'fault': 'Simulate Fault',
      'earthing': 'Earthing',
      'repair': 'Replace Fuse',
      'bulb': 'Bulb',
      'fan': 'Fan',
      'heater': 'Heater',
    },
    'toasts': [
      'Step 1: Switch ON the Main Supply to power the house.',
      'Step 2: Turn on Appliances, then use the slider to OVERLOAD the circuit!',
      "Step 3: Click 'Simulate Fault'. Heater Glows Red = DANGER! Toggle Earthing to fix.",
    ],
    'warn': 'Warning: Turn ON the Main Supply first!',
    'fault':
        'Fault Simulated: Insulation failure! Live wire is touching the metal body.',
    'blow':
        'Earthing Active! Current leaked to ground -> Fuse Blown (Safe). Replace Fuse to restore.',
    'msgs': [
      'The Red wire is Live (220V), Black is Neutral (0V). They enter the Electric Meter and pass through the Main Fuse.',
      'When too many appliances are connected, the current increases. If it crosses the Fuse Rating (5A), the fuse wire melts to break the circuit.',
      'Earthing connects the metal body to the ground. In a fault, current flows to earth instead of through you, blowing the fuse instantly.',
    ],
    'obs': {'title': 'Observation', 'next': 'Next Step'},
    'why': {
      'label': 'Why?',
      'coreT': 'Core Concept',
      'coreD':
          'Electricity enters our home via Live and Neutral wires (Potential Diff: 220V). A Fuse protects against high current (overloading). Earthing prevents shock by leaking current to ground.',
      'link': 'Real World Link',
      'ctxT': 'Why Electrical Safety?',
      'ctxD':
          'Electricity powers our lives, but improper handling can lead to fires and shocks. Understanding circuits saves lives.',
      'ex': [
        {
          't': 'Overloading',
          'd':
              'Connecting too many appliances to one socket can melt wires and cause fire. The Fuse is our first line of defense.',
        },
        {
          't': 'Earthing',
          'd':
              'Ever felt a shock from a metal fridge? Earthing provides a safe path for leaked current, protecting you.',
        },
        {
          't': 'Short Circuit',
          'd':
              'When Live and Neutral wires touch directly, current skyrockets. Insulation prevents this dangerous event.',
        },
      ],
    },
    'guide': {
      'label': 'Guide',
      'intro':
          'In our homes, we receive electric power through a main supply. It involves three wires:',
      'wires': [
        {'t': 'Live Wire (Red)', 'd': 'Positive (220V)'},
        {'t': 'Neutral Wire (Black)', 'd': 'Negative (0V)'},
        {'t': 'Earth Wire (Green)', 'd': 'Safety'},
      ],
      'steps': [
        {
          't': 'Step 1: Parallel Circuits',
          'd':
              "Observe how appliances work independently. Turning off one doesn't affect others. This is the advantage of parallel connection in homes.",
        },
        {
          't': 'Step 2: The Fuse',
          'd':
              'We will simulate overloading. Watch the fuse wire melt when current exceeds the safe limit (5A). This prevents fire damage.',
        },
        {
          't': 'Step 3: Earthing',
          'd':
              'Simulate a leakage fault. Without Earth wire, the body becomes live (Shock risk). With Earth wire, current flows to ground, blowing the fuse.',
        },
      ],
    },
    'outcomes': {
      'label': 'Outcomes',
      'list': [
        {
          't': 'Color Coding & Wiring',
          'd':
              'We observed that the Red wire is Live (bringing potential), Black is Neutral (return path), and Green is Earth (safety). The Live and Neutral wires enter the meter and pass through the main fuse before distribution.',
        },
        {
          't': 'Function of Fuse',
          'd':
              'We saw that when the total current exceeded 5A (Overloading), the fuse wire heated up and melted. This broke the circuit, proving the fuse protects domestic appliances from fire damage caused by high current.',
        },
        {
          't': 'Role of Earthing',
          'd':
              'During a leakage fault, we observed that without earthing, the appliance body remained live (danger). With earthing connected, the current found a low-resistance path to ground, causing a surge that blew the fuse, instantly making the appliance safe to touch.',
        },
      ],
      'finish': 'Finish Activity',
    },
    'success': {
      'title': 'Mission Accomplished!',
      'msg': 'You have mastered domestic circuits and safety.',
    },
    'lbl': {
      'meter': 'Electric Meter',
      'fuse': 'Main Fuse',
      'board': 'Switch Board',
      'heater': 'Heater',
      'bulb': 'Bulb',
      'fan': 'Fan',
      'live': 'Live (Red)',
      'neutral': 'Neutral (Black)',
      'earth': 'Earth (Green)',
      'danger': 'DANGER!',
    },
    'hud': {'volt': 'Voltage', 'curr': 'Current'},
    'tipLabels': 'Show / hide labels',
    'tipLock': 'Lock / unlock view',
  },
  'hi': {
    'intro': {
      'title': 'घरेलू सुरक्षा हब',
      'subtitle': 'कक्षा 10 • विद्युत धारा के चुंबकीय प्रभाव',
      'button': 'हब में प्रवेश करें',
      'footnote': 'लाइव • न्यूट्रल • अर्थ • फ्यूज',
    },
    'headerTitle': 'घरेलू सुरक्षा हब',
    'headerSubtitle': 'कक्षा 10 • चुंबकीय प्रभाव और सर्किट',
    'mission': {
      'label': 'मिशन उद्देश्य',
      'text':
          'घर को तार दें, फ्यूज का उपयोग करके आग रोकें, और अर्थिंग के साथ उपयोगकर्ताओं की रक्षा करें।',
    },
    'procedure': 'प्रक्रिया',
    'steps': [
      {
        't': '1. घरेलू सर्किट',
        'd': 'मुख्य आपूर्ति चालू करें। समानांतर उपकरणों का निरीक्षण करें।',
      },
      {
        't': '2. ओवरलोडिंग (फ्यूज)',
        'd': 'लोड बढ़ाएं। करंट बढ़ते हुए और फ्यूज उड़ते हुए देखें।',
      },
      {
        't': '3. शॉर्ट सर्किट (अर्थिंग)',
        'd': 'लीकेज का अनुकरण करें। अर्थ बंद बनाम चालू की तुलना करें।',
      },
    ],
    'deck': {
      'title': 'सर्किट बोर्ड',
      'main': 'मुख्य आपूर्ति',
      'load': 'लोड (Amp)',
      'current': 'धारा',
      'fault': 'दोष अनुकरण',
      'earthing': 'अर्थिंग',
      'repair': 'फ्यूज बदलें',
      'bulb': 'बल्ब',
      'fan': 'पंखा',
      'heater': 'हीटर',
    },
    'toasts': [
      'चरण 1: घर को बिजली देने के लिए मुख्य आपूर्ति चालू करें।',
      'चरण 2: उपकरण चालू करें, फिर सर्किट को ओवरलोड करने के लिए स्लाइडर का उपयोग करें!',
      "चरण 3: 'दोष अनुकरण' पर क्लिक करें। लाल=खतरा देखें। फिर अर्थिंग टॉगल करें।",
    ],
    'warn': 'चेतावनी: पहले मुख्य आपूर्ति चालू करें!',
    'fault': 'दोष अनुकरण: इन्सुलेशन विफलता! लाइव तार धातु शरीर को छू रहा है।',
    'blow':
        'अर्थिंग सक्रिय! करंट जमीन पर लीक हो गया -> फ्यूज उड़ गया (सुरक्षित)। फ्यूज बदलें।',
    'msgs': [
      'लाल तार लाइव (220V), काला न्यूट्रल (0V) है। वे इलेक्ट्रिक मीटर में प्रवेश करते हैं और मेन फ्यूज से गुजरते हैं।',
      'जब बहुत अधिक उपकरण जुड़े होते हैं, तो करंट बढ़ जाता है। यदि यह फ्यूज रेटिंग (5A) को पार करता है, तो सर्किट तोड़ने के लिए फ्यूज तार पिघल जाता है।',
      'अर्थिंग धातु शरीर को जमीन से जोड़ता है। गलती होने पर, करंट आपके बजाय जमीन में बहता है, जिससे फ्यूज तुरंत उड़ जाता है।',
    ],
    'obs': {'title': 'अवलोकन', 'next': 'अगला चरण'},
    'why': {
      'label': 'क्यों?',
      'coreT': 'मुख्य अवधारणा',
      'coreD':
          'बिजली लाइव और न्यूट्रल तारों (संभावित अंतर: 220V) के माध्यम से हमारे घर में प्रवेश करती है। एक फ्यूज उच्च धारा (ओवरलोडिंग) से बचाता है। अर्थिंग करंट को जमीन पर लीक करके झटके से बचाता है।',
      'link': 'वास्तविक जीवन से जुड़ाव',
      'ctxT': 'विद्युत सुरक्षा क्यों?',
      'ctxD':
          'बिजली हमारे जीवन को शक्ति देती है, लेकिन अनुचित प्रबंधन से आग और झटके लग सकते हैं। सर्किट को समझना जीवन बचाता है।',
      'ex': [
        {
          't': 'ओवरलोडिंग',
          'd':
              'एक सॉकेट से बहुत अधिक उपकरण जोड़ने से तार पिघल सकते हैं और आग लग सकती है। फ्यूज हमारी पहली रक्षा पंक्ति है।',
        },
        {
          't': 'अर्थिंग',
          'd':
              'क्या कभी धातु के फ्रिज से झटका लगा है? अर्थिंग लीक हुए करंट के लिए एक सुरक्षित रास्ता प्रदान करता है, जो आपकी रक्षा करता है।',
        },
        {
          't': 'शॉर्ट सर्किट',
          'd':
              'जब लाइव और न्यूट्रल तार सीधे छूते हैं, तो करंट आसमान छू जाता है। इन्सुलेशन इस खतरनाक घटना को रोकता है।',
        },
      ],
    },
    'guide': {
      'label': 'गाइड',
      'intro':
          'हमारे घरों में, हमें मुख्य आपूर्ति के माध्यम से बिजली मिलती है। इसमें तीन तार शामिल हैं:',
      'wires': [
        {'t': 'लाइव वायर (लाल)', 'd': 'सकारात्मक (220V)'},
        {'t': 'न्यूट्रल वायर (काला)', 'd': 'नकारात्मक (0V)'},
        {'t': 'अर्थ वायर (हरा)', 'd': 'सुरक्षा'},
      ],
      'steps': [
        {
          't': 'चरण 1: समानांतर सर्किट',
          'd':
              'देखें कि उपकरण स्वतंत्र रूप से कैसे काम करते हैं। एक को बंद करने से दूसरों पर कोई प्रभाव नहीं पड़ता है। यह घरों में समानांतर कनेक्शन का लाभ है।',
        },
        {
          't': 'चरण 2: फ्यूज',
          'd':
              'हम ओवरलोडिंग का अनुकरण करेंगे। देखें कि जब करंट सुरक्षित सीमा (5A) से अधिक हो जाता है तो फ्यूज तार पिघल जाता है। यह आग से होने वाले नुकसान को रोकता है।',
        },
        {
          't': 'चरण 3: अर्थिंग',
          'd':
              'एक लीकेज फॉल्ट का अनुकरण करें। अर्थ वायर के बिना, शरीर लाइव हो जाता है (झटके का खतरा)। अर्थ वायर के साथ, करंट जमीन में बहता है, जिससे फ्यूज उड़ जाता है।',
        },
      ],
    },
    'outcomes': {
      'label': 'परिणाम',
      'list': [
        {
          't': 'रंग कोडिंग और वायरिंग',
          'd':
              'हमने देखा कि लाल तार लाइव (क्षमता लाने वाला), काला न्यूट्रल (वापसी पथ), और हरा अर्थ (सुरक्षा) है। वितरण से पहले लाइव और न्यूट्रल तार मीटर में प्रवेश करते हैं और मुख्य फ्यूज से गुजरते हैं।',
        },
        {
          't': 'फ्यूज का कार्य',
          'd':
              'हमने देखा कि जब कुल करंट 5A (ओवरलोडिंग) से अधिक हो गया, तो फ्यूज तार गर्म हो गया और पिघल गया। इसने सर्किट को तोड़ दिया, यह साबित करते हुए कि फ्यूज घरेलू उपकरणों को उच्च धारा के कारण होने वाली आग से बचाता है।',
        },
        {
          't': 'अर्थिंग की भूमिका',
          'd':
              'लीकेज फॉल्ट के दौरान, हमने देखा कि अर्थिंग के बिना, उपकरण का शरीर लाइव रहा (खतरा)। अर्थिंग कनेक्ट होने के साथ, करंट को जमीन का कम प्रतिरोध वाला रास्ता मिल गया, जिससे उछाल आया और फ्यूज उड़ गया, जिससे उपकरण तुरंत छूने के लिए सुरक्षित हो गया।',
        },
      ],
      'finish': 'गतिविधि समाप्त करें',
    },
    'success': {
      'title': 'मिशन सफल!',
      'msg': 'आपने घरेलू सर्किट और सुरक्षा में महारत हासिल कर ली है।',
    },
    'lbl': {
      'meter': 'विद्युत मीटर',
      'fuse': 'मुख्य फ्यूज',
      'board': 'स्विच बोर्ड',
      'heater': 'हीटर',
      'bulb': 'बल्ब',
      'fan': 'पंखा',
      'live': 'लाइव (लाल)',
      'neutral': 'न्यूट्रल (काला)',
      'earth': 'अर्थ (हरा)',
      'danger': 'खतरा!',
    },
    'hud': {'volt': 'वोल्टेज', 'curr': 'धारा'},
    'tipLabels': 'लेबल दिखाएँ / छिपाएँ',
    'tipLock': 'दृश्य लॉक / अनलॉक करें',
  },
});

/// Yellow debris flying out of the fuse when it blows.
class _Spark {
  _Spark(this.mesh, this.vel);
  final _rt_Sphere3D mesh;
  final _rt_V3 vel;
  double ttl = 1.0;
}

class Cl10SCh12A5DomesticSafetyHubPage extends StatefulWidget {
  const Cl10SCh12A5DomesticSafetyHubPage({super.key});

  @override
  State<Cl10SCh12A5DomesticSafetyHubPage> createState() =>
      _Cl10SCh12A5DomesticSafetyHubPageState();
}

class _Cl10SCh12A5DomesticSafetyHubPageState
    extends State<Cl10SCh12A5DomesticSafetyHubPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 4, 11.5),
    target: _rt_V3(0, 0.8, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final math.Random _rng = math.Random(12);

  // Scene nodes / materials mutated at runtime.
  late final _rt_Material3D _meterMat;
  late final _rt_Label3D _meterReadout;
  late final _rt_Mesh3D _fuseWire;
  late final _rt_Node3D _heaterGroup;
  late final _rt_Material3D _heaterBodyMat;
  late final _rt_Material3D _coilMat;
  late final _rt_Label3D _dangerLabel;
  late final _rt_Mesh3D _strayWire;
  late final _rt_Line3D _sparkLine;
  late final List<_rt_Mesh3D> _heatRings;
  late final _rt_Node3D _fanMotor;
  late final _rt_Material3D _bulbMat;
  late final _rt_Sphere3D _bulbGlow;
  late final _rt_Light3D _bulbLight;
  late final _rt_Line3D _wireLive;
  late final _rt_Line3D _wireNeutral;
  late final _rt_Node3D _earthGroup;
  final Map<String, _rt_Material3D> _swMats = {};
  final List<(_rt_Label3D, String)> _sceneLabels = [];
  final List<_Spark> _sparks = [];

  // --- LAB STATE (threeApp.state / lab in the HTML) ---
  int _step = 1; // 1..3 (source lab.step 0..2)
  bool _mainOn = false;
  bool _fuseIntact = true;
  bool _bulbOn = false;
  bool _fanOn = false;
  bool _heaterOn = false;
  bool _fault = false;
  bool _earth = false;
  double _load = 0;
  bool _danger = false;
  bool _blowScheduled = false;
  bool _showLabels = true;
  bool _viewLocked = false;
  final Set<int> _seenObs = {};
  double _clock = 0;

  /// Bumped by restart so pending delayed callbacks die.
  int _gen = 0;

  /// Total current on the meter (appliances flow only while powered).
  double get _amps {
    if (!_mainOn || !_fuseIntact) return 0;
    var a = _load;
    if (_bulbOn) a += 0.5;
    if (_fanOn) a += 1.0;
    if (_heaterOn) a += 4.0;
    return a;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _camera
      ..maxPolarAngle = math.pi / 1.8
      ..minDistance = 4
      ..maxDistance = 50;
    _initScene();
    _updateSystem();
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

  // ------------------------------------------------------------ scene ---
  void _initScene() {
    _bulbLight = _rt_Light3D.point(
      _rt_V3(4.3, 3.0, 1.8),
      color: const Color(0xFFFFAA00),
      intensity: 0,
      distance: 12,
    );
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.65),
      _rt_Light3D.directional(_rt_V3(5, 10, 8), intensity: 0.85),
      _bulbLight,
    ]);

    // --- Room (open-fronted: back wall, floor, ceiling, two sides) ---
    _rt_Mesh3D plane(double w, double h, Color c) => _rt_Mesh3D(
      _rt_Geometry3D.plane(w, h, widthSegments: 4, heightSegments: 3),
      _rt_Material3D(color: c, doubleSided: true),
    )..pickable = false;
    _scene.add(
      plane(16, 12, const Color(0xFFCBD5E1))..position.set(0, 2, -1.85),
    ); // back
    _scene.add(
      plane(16, 10, const Color(0xFF64748B))
        ..rotation.x = -math.pi / 2
        ..position.set(0, -3.75, 1),
    ); // floor
    _scene.add(
      plane(16, 10, const Color(0xFFE2E8F0))
        ..rotation.x = math.pi / 2
        ..position.set(0, 5.8, 1),
    ); // ceiling
    _scene.add(
      plane(10, 12, const Color(0xFF94A3B8))
        ..rotation.y = math.pi / 2
        ..position.set(-8, 2, 1),
    ); // left
    _scene.add(
      plane(10, 12, const Color(0xFF94A3B8))
        ..rotation.y = -math.pi / 2
        ..position.set(8, 2, 1),
    ); // right

    // --- Electric meter ---
    final meter = _rt_Node3D(name: 'meter')..position.set(-3, 1, -1.6);
    _meterMat = _rt_Material3D(color: const Color(0xFF334155), shininess: 0.3);
    meter.add(_rt_Mesh3D(_rt_Geometry3D.box(1.5, 2, 0.5), _meterMat));
    meter.add(
      _rt_Mesh3D(
        _rt_Geometry3D.plane(1.2, 0.8),
        _rt_Material3D(color: const Color(0xFF0B1120), unlit: true),
      )..position.set(0, 0.2, 0.26),
    );
    _meterReadout = _rt_Label3D(
      '0.0 A',
      position: _rt_V3(0, 0.2, 0.3),
      pixelHeight: 9,
      color: const Color(0xFF4ADE80),
      background: const Color(0xE60B1120),
      alwaysOnTop: false,
    );
    meter.add(_meterReadout);
    _scene.add(meter);
    _addLabel(meter, _rt_V3(0, 1.6, 0.3), 'meter');

    // --- Main fuse ---
    final fuse = _rt_Node3D(name: 'fuse')..position.set(-1.5, 1, -1.6);
    fuse.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(1, 0.5, 0.5),
        _rt_Material3D(color: const Color(0xFF475569)),
      ),
    );
    fuse.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.1, 0.1, 0.84, segments: 12),
          _rt_Material3D(color: Colors.white, opacity: 0.22, shininess: 0.6),
        )
        ..rotation.z = math.pi / 2
        ..position.z = 0.32,
    );
    _fuseWire =
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.025, 0.025, 0.8, segments: 8),
            _rt_Material3D(color: const Color(0xFFB45309), unlit: true),
          )
          ..rotation.z = math.pi / 2
          ..position.z = 0.32;
    fuse.add(_fuseWire);
    _scene.add(fuse);
    _addLabel(fuse, _rt_V3(0, 1.05, 0.3), 'fuse');

    // --- Switch board with three tappable switches ---
    final board = _rt_Node3D(name: 'board')..position.set(2, 1, -1.6);
    board.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(4, 1.5, 0.2),
        _rt_Material3D(color: Colors.white),
      ),
    );
    const dots = {
      'bulb': (Color(0xFFFBBF24), -1.2),
      'fan': (Color(0xFF38BDF8), 0.0),
      'heater': (Color(0xFFF97316), 1.2),
    };
    dots.forEach((type, spec) {
      final mat = _rt_Material3D(
        color: const Color(0xFF94A3B8),
        shininess: 0.3,
      );
      _swMats[type] = mat;
      board.add(
        _rt_Mesh3D(_rt_Geometry3D.box(0.6, 0.6, 0.12), mat, name: 'sw3d-$type')
          ..position.set(spec.$2, 0, 0.15),
      );
      board.add(
        _rt_Sphere3D(0.11, _rt_Material3D(color: spec.$1, unlit: true))
          ..position.set(spec.$2, 0, 0.26)
          ..pickable = false,
      );
    });
    _scene.add(board);
    _addLabel(board, _rt_V3(0, 1.2, 0.3), 'board');

    // --- Bulb on the right side ---
    final bulb = _rt_Node3D(name: 'bulb')..position.set(4.6, 3.0, 0.5);
    bulb.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.12, 0.18, 0.35, segments: 10),
          _rt_Material3D(color: const Color(0xFF555555)),
        )
        ..rotation.z = math.pi / 2
        ..position.x = 0.4,
    );
    _bulbMat = _rt_Material3D(color: const Color(0xFF52525B), shininess: 0.5);
    bulb.add(_rt_Sphere3D(0.42, _bulbMat));
    _bulbGlow =
        _rt_Sphere3D(
            0.85,
            _rt_Material3D(
              color: const Color(0xFFFDE68A),
              opacity: 0.3,
              unlit: true,
            ),
          )
          ..visible = false
          ..pickable = false;
    bulb.add(_bulbGlow);
    _scene.add(bulb);
    _addLabel(bulb, _rt_V3(0, 0.85, 0), 'bulb');

    // --- Ceiling fan (right of the top HUD cards) ---
    final fan = _rt_Node3D(name: 'fan')..position.set(3.4, 4.4, 0.5);
    fan.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.08, 0.08, 1.4, segments: 8),
        _rt_Material3D(color: const Color(0xFF333333)),
      )..position.y = 0.7,
    );
    _fanMotor = _rt_Node3D(name: 'fanMotor');
    _fanMotor.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.4, 0.4, 0.3, segments: 14),
        _rt_Material3D(color: const Color(0xFFCBD5E1), shininess: 0.4),
      ),
    );
    final bladeMat = _rt_Material3D(color: const Color(0xFF64748B));
    _fanMotor.add(_rt_Mesh3D(_rt_Geometry3D.box(0.22, 0.05, 3), bladeMat));
    _fanMotor.add(
      _rt_Mesh3D(_rt_Geometry3D.box(0.22, 0.05, 3), bladeMat)
        ..rotation.y = math.pi / 2,
    );
    fan.add(_fanMotor);
    _scene.add(fan);
    _addLabel(fan, _rt_V3(0, 0.55, 0), 'fan');

    // --- Heater on the left side ---
    _heaterGroup = _rt_Node3D(name: 'heater')..position.set(-5.5, -3, 0.4);
    _heaterBodyMat = _rt_Material3D(
      color: const Color(0xFF94A3B8),
      shininess: 0.4,
    );
    _heaterGroup.add(
      _rt_Mesh3D(_rt_Geometry3D.box(1.2, 1.6, 0.7), _heaterBodyMat),
    );
    _coilMat = _rt_Material3D(color: const Color(0xFF330000));
    _heaterGroup.add(
      _rt_Mesh3D(_rt_Geometry3D.plane(0.9, 1.3), _coilMat)
        ..rotation.y = math.pi / 2
        ..position.x = 0.37,
    );
    _heatRings = [
      for (var i = 0; i < 3; i++)
        _rt_Mesh3D(
            _rt_Geometry3D.ring(0.42, 0.55, segments: 18),
            _rt_Material3D(
              color: const Color(0xFFFF4500),
              opacity: 0,
              unlit: true,
              doubleSided: true,
            ),
          )
          ..rotation.y = math.pi / 2
          ..position.x = 0.65 + i * 0.35
          ..visible = false
          ..pickable = false,
    ];
    _heaterGroup.addAll(_heatRings);
    _dangerLabel = _rt_Label3D(
      'DANGER!',
      position: _rt_V3(0, 1.9, 0),
      pixelHeight: 15,
      color: Colors.white,
      background: const Color(0xFFDC2626),
      borderColor: Colors.white,
    )..visible = false;
    _heaterGroup.add(_dangerLabel);
    _strayWire =
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.035, 0.035, 0.6, segments: 6),
            _rt_Material3D(color: const Color(0xFFFF0000), unlit: true),
          )
          ..rotation.z = math.pi / 4
          ..position.set(0.6, 0.65, 0.4)
          ..visible = false;
    _heaterGroup.add(_strayWire);
    _sparkLine = _rt_Line3D(
      [for (var i = 0; i < 6; i++) _rt_V3(0.65, 0.5, 0.45)],
      color: const Color(0xFFFFFF00),
      width: 2.5,
    )..visible = false;
    _heaterGroup.add(_sparkLine);
    _scene.add(_heaterGroup);
    _addLabel(_heaterGroup, _rt_V3(0, 1.15, 0.5), 'heater');

    // --- Earth wire + ground symbol (visible only when earthing is ON) ---
    _earthGroup = _rt_Node3D(name: 'earth')..visible = false;
    _earthGroup.add(
      _rt_Line3D(
        [_rt_V3(-5.15, -2.4, 0.85), _rt_V3(-5.15, -3.7, 0.85)],
        color: const Color(0xFF22C55E),
        width: 4,
      ),
    );
    _earthGroup.add(
      _rt_Line3D(
        [
          _rt_V3(-5.55, -3.4, 0.85), _rt_V3(-4.75, -3.4, 0.85), //
          _rt_V3(-5.4, -3.55, 0.85), _rt_V3(-4.9, -3.55, 0.85),
          _rt_V3(-5.25, -3.7, 0.85), _rt_V3(-5.05, -3.7, 0.85),
        ],
        color: const Color(0xFF22C55E),
        width: 3,
        segments: true,
      ),
    );
    _scene.add(_earthGroup);
    _addLabel(_earthGroup, _rt_V3(-4.35, -1.75, 0.9), 'earth');

    // --- Live and neutral supply wires into the board ---
    _wireLive = _rt_Line3D(
      [_rt_V3(-3.8, 1, -1.55), _rt_V3(0.05, 1, -1.55)],
      color: const Color(0xFF7F1D1D),
      width: 5,
    );
    _scene.add(_wireLive);
    _wireNeutral = _rt_Line3D(
      [_rt_V3(-3.8, 0.7, -1.55), _rt_V3(0.05, 0.7, -1.55)],
      color: const Color(0xFF1E293B),
      width: 5,
    );
    _scene.add(_wireNeutral);
    _scene.add(_addFloating(_rt_V3(-0.6, 1.55, -1.5), 'live'));
    _scene.add(_addFloating(_rt_V3(-2.4, 0.2, -1.5), 'neutral'));
  }

  /// Scene label attached to [parent] at a local offset (the HTML's
  /// `.scene-label` divs projected over the canvas).
  void _addLabel(_rt_Node3D parent, _rt_V3 offset, String key) {
    final l = _rt_Label3D(
      _tx.s('lbl.$key'),
      position: offset,
      pixelHeight: 10,
      color: const Color(0xFF0F172A),
      background: const Color(0xF2FFFFFF),
      borderColor: const Color(0xFF475569),
    );
    parent.add(l);
    _sceneLabels.add((l, key));
  }

  _rt_Label3D _addFloating(_rt_V3 pos, String key) {
    final l = _rt_Label3D(
      _tx.s('lbl.$key'),
      position: pos,
      pixelHeight: 10,
      color: const Color(0xFF0F172A),
      background: const Color(0xF2FFFFFF),
      borderColor: const Color(0xFF475569),
    );
    _sceneLabels.add((l, key));
    return l;
  }

  // ------------------------------------------------------------ frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);

    // Fan spins while powered and on (stops during a danger flash).
    if (_fanOn && _mainOn && _fuseIntact && !_danger) {
      _fanMotor.rotation.y += (12 + _load * 6) * dt;
    }

    // Expanding heat rings while the heater runs normally.
    final heat = _mainOn && _fuseIntact && _heaterOn && !_danger;
    for (final r in _heatRings) {
      r.visible = heat;
      if (!heat) continue;
      final s = r.scale.x + (1.0 + _load * 0.12) * dt;
      final ns = s > 2.6 ? 1.0 : s;
      r.scale.set(ns, ns, ns);
      (r.material).opacity = (1 - ns / 2.6).clamp(0.0, 0.8);
    }

    // Danger: heater shakes and the spark line jitters (animate loop).
    if (_danger) {
      _heaterGroup.position.x = -5.5 + (_rng.nextDouble() - 0.5) * 0.18;
      _sparkLine.points = [
        for (var i = 0; i < 6; i++)
          _rt_V3(
            0.65 + (_rng.nextDouble() - 0.5) * 0.9,
            0.5 + (_rng.nextDouble() - 0.5) * 0.9,
            0.45 + (_rng.nextDouble() - 0.5) * 0.4,
          ),
      ];
      final pulse = 1.4 + math.sin(_clock * 14) * 0.7;
      _coilMat.emissiveIntensity = pulse;
    } else {
      _heaterGroup.position.x = -5.5;
    }

    // Fuse debris.
    for (final s in List.of(_sparks)) {
      s.ttl -= dt;
      if (s.ttl <= 0) {
        _scene.remove(s.mesh);
        _sparks.remove(s);
        continue;
      }
      s.mesh.position.add(s.vel * dt);
      s.vel.y -= 8 * dt;
      s.mesh.material.opacity = s.ttl.clamp(0.0, 1.0);
    }
  }

  // ----------------------------------------------------------- helpers ---
  void _later(int ms, VoidCallback fn) {
    final gen = _gen;
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted && gen == _gen) fn();
    });
  }

  void _toast(
    String key, {
    Color color = _rt_Tw.indigo500,
    IconData icon = Icons.info_outline,
  }) {
    _shell.showToast(_tx.s(key), color: color, icon: icon, ms: 4000);
  }

  // ----------------------------------------------------- system update ---
  /// Mirrors threeApp.updateSystem: recolours every node from the state.
  void _updateSystem() {
    final power = _mainOn && _fuseIntact;
    final boost = _load / 10 * 1.5;

    // Wire glow.
    _wireLive.color = _mainOn
        ? const Color(0xFFFF3B3B)
        : const Color(0xFF7F1D1D);
    _wireNeutral.color = _mainOn
        ? const Color(0xFF475569)
        : const Color(0xFF1E293B);
    _meterMat.emissive = _mainOn ? const Color(0xFF166534) : null;
    _meterMat.emissiveIntensity = 0.35;

    // Switch buttons on the 3D board.
    _swMats['bulb']!.color = _bulbOn
        ? const Color(0xFF22C55E)
        : const Color(0xFF94A3B8);
    _swMats['fan']!.color = _fanOn
        ? const Color(0xFF22C55E)
        : const Color(0xFF94A3B8);
    _swMats['heater']!.color = _heaterOn
        ? const Color(0xFF22C55E)
        : const Color(0xFF94A3B8);

    // FAULT STATE: live wire touching the heater body, no earth path.
    _danger = _fault && _mainOn && _fuseIntact && !_earth;
    _dangerLabel.visible = _danger;
    _sparkLine.visible = _danger;
    _strayWire.visible = _danger;

    // Heater coil + body (the whole appliance becomes live in a fault).
    _heaterBodyMat.color = _danger
        ? const Color(0xFFB91C1C)
        : const Color(0xFF94A3B8);
    _heaterBodyMat.emissive = _danger ? const Color(0xFFEF4444) : null;
    _heaterBodyMat.emissiveIntensity = 0.7;
    if (_danger) {
      _coilMat.color = const Color(0xFFFF0000);
      _coilMat.emissive = const Color(0xFFFF0000);
      _coilMat.emissiveIntensity = 2.0;
    } else if (power && _heaterOn) {
      _coilMat.color = const Color(0xFFFF4400);
      _coilMat.emissive = const Color(0xFFFF4400);
      _coilMat.emissiveIntensity = 0.5 + boost;
    } else {
      _coilMat.color = const Color(0xFF330000);
      _coilMat.emissive = null;
    }

    // Bulb.
    final lit = power && _bulbOn;
    _bulbMat.color = lit ? const Color(0xFFFFF3B0) : const Color(0xFF52525B);
    _bulbMat.emissive = lit ? const Color(0xFFFFC53D) : null;
    _bulbMat.emissiveIntensity = 0.8 + boost;
    _bulbGlow.visible = lit;
    _bulbLight.intensity = lit ? 0.7 + boost * 0.5 : 0;

    // Meter readout.
    final amps = _amps;
    _meterReadout.text = '${amps.toStringAsFixed(1)} A';
    _meterReadout.color = amps > 5
        ? const Color(0xFFF87171)
        : const Color(0xFF4ADE80);
  }

  // ------------------------------------------------------------- steps ---
  /// The HTML lab.setStep: free navigation with per-step housekeeping.
  void _setStep(int n) {
    _rt_playSfx(_rt_Sfx.scenario);
    if (n == 1 && _step != 1) {
      _powerReset(); // threeApp.reset()
    } else if (n != 1) {
      if (!_fuseIntact) {
        _fuseIntact = true;
        _fuseWire.visible = true;
      }
      _fault = false;
      if (n == 2) {
        _bulbOn = _fanOn = _heaterOn = false;
        _load = 0;
      }
      if (n == 3) _load = 0;
    }
    _blowScheduled = false;
    setState(() => _step = n);
    _updateSystem();
    _toast('toasts.${n - 1}');
  }

  /// threeApp.reset(): everything off, fuse whole, camera home.
  void _powerReset() {
    _mainOn = false;
    _bulbOn = _fanOn = _heaterOn = false;
    _fault = false;
    _earth = false;
    _earthGroup.visible = false;
    _load = 0;
    _fuseIntact = true;
    _fuseWire.visible = true;
    _blowScheduled = false;
    for (final s in _sparks) {
      _scene.remove(s.mesh);
    }
    _sparks.clear();
    _camera.reset();
    _updateSystem();
  }

  void _restart() {
    _gen++;
    _tweens.cancelAll();
    _powerReset();
    setState(() {
      _step = 1;
      _seenObs.clear();
      _showLabels = true;
      _viewLocked = false;
    });
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _toast('toasts.0');
  }

  // ---------------------------------------------------------- controls ---
  void _toggleMain() {
    _rt_playSfx(_rt_Sfx.toggle); // HTML toggleMain: audio.playClick()
    setState(() => _mainOn = !_mainOn);
    _updateSystem();
    if (_mainOn && _step == 1) {
      // Source: setTimeout(() => ui.showPopup(0), 1500).
      _later(1500, () {
        if (_mainOn && _step == 1) _showObservation(0);
      });
    }
  }

  void _toggleAppliance(String type) {
    if (!_mainOn) {
      _rt_playSfx(_rt_Sfx.wrong);
      _toast('warn', color: _rt_Tw.amber500, icon: Icons.warning_amber);
      return;
    }
    _rt_playSfx(_rt_Sfx.toggle); // HTML toggleAppliance: audio.playClick()
    setState(() {
      switch (type) {
        case 'bulb':
          _bulbOn = !_bulbOn;
        case 'fan':
          _fanOn = !_fanOn;
        case 'heater':
          _heaterOn = !_heaterOn;
      }
    });
    _updateSystem();
  }

  void _setLoad(double v) {
    setState(() => _load = v);
    _updateSystem();
    // Source lab.updateLoad: load above the 5 A rating blows the fuse 800 ms later.
    if (_load > 5 && _fuseIntact && _mainOn && !_blowScheduled) {
      _blowScheduled = true;
      _later(800, () {
        _blowScheduled = false;
        if (_load > 5 && _fuseIntact && _mainOn) _blowFuse(viaEarth: false);
      });
    }
  }

  void _blowFuse({required bool viaEarth}) {
    if (!_fuseIntact) return;
    _rt_playSfx(_rt_Sfx.wrong); // HTML blowFuse: audio.playZap()
    _fuseIntact = false;
    _fuseWire.visible = false;
    _spawnSparks();
    // QA C10-12.5-01: the 'Earthing Active!' text is only true for an
    // earth-fault blow; an overload blow is explained by popup 1 alone.
    if (viaEarth) _toast('blow', color: _rt_Tw.red500, icon: Icons.power_off);
    setState(() {});
    _updateSystem();
    if (!viaEarth && _step == 2) _later(1000, () => _showObservation(1));
    if (viaEarth && _step == 3) _later(1000, () => _showObservation(2));
  }

  void _spawnSparks() {
    for (var i = 0; i < 22; i++) {
      final m =
          _rt_Sphere3D(
              0.1,
              _rt_Material3D(color: const Color(0xFFFFE45C), unlit: true),
            )
            ..position.set(-1.5, 1, -1.2)
            ..pickable = false;
      _scene.add(m);
      _sparks.add(
        _Spark(
          m,
          _rt_V3(
            (_rng.nextDouble() - 0.5) * 6,
            _rng.nextDouble() * 4 + 1.5,
            (_rng.nextDouble() - 0.5) * 4,
          ),
        ),
      );
    }
  }

  void _repairFuse() {
    // _rt_ActionButton already plays the click (HTML repairFuse: audio.playClick()).
    _fuseIntact = true;
    _fuseWire.visible = true;
    setState(() => _load = 0);
    _updateSystem();
  }

  void _toggleFault() {
    if (!_mainOn) {
      _rt_playSfx(_rt_Sfx.wrong);
      _toast('warn', color: _rt_Tw.amber500, icon: Icons.warning_amber);
      return;
    }
    setState(() => _fault = !_fault);
    if (_fault) {
      _rt_playSfx(_rt_Sfx.magic); // spark / insulation failure reveal
      _toast('fault', color: _rt_Tw.red500, icon: Icons.flash_on);
      _checkSafety();
    } else {
      _rt_playSfx(_rt_Sfx.toggle);
    }
    _updateSystem();
  }

  void _toggleEarth() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _earth = !_earth);
    _earthGroup.visible = _earth;
    _checkSafety();
    _updateSystem();
  }

  /// threeApp.checkSafety: fault + earth = surge to ground, fuse blows.
  void _checkSafety() {
    if (!_mainOn) return;
    if (_fault && _earth && _fuseIntact) {
      _later(300, () {
        if (_fault && _earth && _mainOn && _fuseIntact) {
          _blowFuse(viaEarth: true);
        }
      });
    }
  }

  // ------------------------------------------------------ observations ---
  Future<void> _showObservation(int idx) async {
    if (!mounted) return;
    _rt_playSfx(_rt_Sfx.pop);
    var next = false;
    await _rt_showShellPopup(
      context,
      title: _tx.s('obs.title'),
      message: _tx.s('msgs.$idx'),
      icon: Icons.info_outline,
      color: _rt_Tw.indigo500,
      actions: [
        _rt_ActionButton(
          label: _tx.s('obs.next'),
          icon: Icons.arrow_forward,
          color: _rt_Tw.indigo600,
          onPressed: () {
            next = true;
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    if (!mounted) return;
    setState(() => _seenObs.add(idx));
    if (next) {
      if (_step < 3) {
        _setStep(_step + 1);
      } else {
        _finish();
      }
    }
  }

  void _finish() {
    _shell.showSuccess(
      title: _tx.s('success.title'),
      message: _tx.s('success.msg'),
      icon: Icons.emoji_events,
    );
  }

  // ---------------------------------------------------------- 3D input ---
  void _onSceneTap(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => (n.name ?? '').startsWith('sw3d-'));
    if (hit != null) _toggleAppliance(hit.name!.substring(5));
  }

  // ---------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _syncLabels();
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            canvasBackground: _rt_Tw.slate950,
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.indigo600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.indigo900],
              headerSubtitleColor: _rt_Tw.indigo100,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.verified_user,
            ),
            onStart: () =>
                _toast('toasts.0'), // source shows t_s0 after the curtain
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              _toolButton(
                key: const ValueKey('toggle-labels'),
                icon: _showLabels ? Icons.visibility : Icons.visibility_off,
                tip: _tx.s('tipLabels'),
                active: _showLabels,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _showLabels = !_showLabels);
                },
              ),
              const SizedBox(height: 4),
              _rt_RotatePanToggle(
                controller: _viewCtrl,
                accent: _rt_Tw.indigo600,
              ),
              const SizedBox(height: 4),
              _toolButton(
                key: const ValueKey('lock-view'),
                icon: _viewLocked ? Icons.lock : Icons.lock_open,
                tip: _tx.s('tipLock'),
                active: _viewLocked,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _viewLocked = !_viewLocked);
                },
              ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('deck.title'),
                icon: Icons.electrical_services,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              onFrame: _onFrame,
              onTap: _onSceneTap,
              cameraControls: !_viewLocked,
            ),
            canvasOverlays: [
              // Voltage / current HUD (the meter's canvas texture in the source).
              Positioned(
                top: 14,
                left: 70,
                right: 70,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _rt_HudCard(
                        value: '220 V',
                        label: _tx.s('hud.volt'),
                        color: _rt_Tw.green600,
                      ),
                      const SizedBox(width: 10),
                      _rt_HudCard(
                        value: '${_amps.toStringAsFixed(1)} A',
                        label: _tx.s('hud.curr'),
                        color: _amps > 5 ? _rt_Tw.red500 : _rt_Tw.amber600,
                      ),
                    ],
                  ),
                ),
              ),
              // The HTML body flash-red while the fault is live.
              if (_danger)
                const Positioned.fill(
                  child: IgnorePointer(child: _DangerFlash()),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Refresh scene-label text / visibility on rebuilds (language toggles).
  void _syncLabels() {
    for (final (label, key) in _sceneLabels) {
      label.text = _tx.s('lbl.$key');
      label.visible = _showLabels;
    }
    _dangerLabel.text = _tx.s('lbl.danger');
  }

  Widget _toolButton({
    required Key key,
    required IconData icon,
    required String tip,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        key: key,
        radius: 22,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _rt_Tw.indigo600 : _rt_Lab.surface,
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

  // ----------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('mission.label'),
          desc: _tx.s('mission.text'),
          accent: _rt_Tw.indigo600,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _controlDeck(),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('procedure'), icon: Icons.checklist),
              for (var i = 1; i <= 3; i++) _stepCard(i),
              const SizedBox(height: 6),
              // The shell renders only the first tab, so the Why? / Guide /
              // Outcomes drawers live at the foot of the step list.
              _rt_SectionLabel(
                _tx.s('why.label'),
                icon: Icons.lightbulb_outline,
              ),
              _rt_InfoCard(
                title: _tx.s('why.coreT'),
                body: _tx.s('why.coreD'),
                icon: Icons.bolt,
                color: _rt_Tw.blue600,
              ),
              _rt_InfoCard(
                tag: _tx.s('why.link'),
                title: _tx.s('why.ctxT'),
                body: _tx.s('why.ctxD'),
                color: _rt_Tw.indigo600,
              ),
              for (final (i, ex) in _tx.list('why.ex').indexed)
                _rt_InfoCard(
                  title: ((ex as Map)['t']) as String,
                  body: ex['d'] as String,
                  icon: const [
                    Icons.electric_bolt,
                    Icons.power,
                    Icons.dangerous,
                  ][i],
                  color: const [
                    _rt_Tw.amber600,
                    _rt_Tw.green600,
                    _rt_Tw.red600,
                  ][i],
                  leftBorder: true,
                ),
              _rt_SectionLabel(_tx.s('guide.label'), icon: Icons.menu_book),
              _rt_InfoCard(body: _tx.s('guide.intro'), color: _rt_Tw.indigo600),
              _wireRow(0, _rt_Tw.red500),
              _wireRow(1, const Color(0xFF0F172A)),
              _wireRow(2, _rt_Tw.green500),
              const SizedBox(height: 8),
              for (final g in _tx.list('guide.steps'))
                _rt_InfoCard(
                  title: ((g as Map)['t']) as String,
                  body: g['d'] as String,
                  icon: Icons.school,
                  color: _rt_Tw.indigo600,
                  leftBorder: true,
                ),
              _rt_SectionLabel(
                _tx.s('outcomes.label'),
                icon: Icons.workspace_premium,
              ),
              for (final o in _tx.list('outcomes.list'))
                _rt_InfoCard(
                  title: ((o as Map)['t']) as String,
                  body: o['d'] as String,
                  icon: Icons.check_circle,
                  color: _rt_Tw.green600,
                ),
              const SizedBox(height: 4),
              _rt_ActionButton(
                label: _tx.s('outcomes.finish'),
                icon: Icons.emoji_events,
                color: _rt_Tw.indigo600,
                expand: true,
                onPressed: _finish,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wireRow(int i, Color dot) {
    final w = _tx.list('guide.wires')[i] as Map;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              border: Border.all(color: _rt_Lab.borderStrong),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              w['t'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ),
          Text(
            w['d'] as String,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: _rt_Lab.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Step selector card: the whole card is tappable like the HTML .step-card.
  Widget _stepCard(int n) {
    final s = _tx.list('steps')[n - 1] as Map;
    final active = _step == n;
    final done = _seenObs.contains(n - 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active
            ? _rt_Lab.tinted(_rt_Tw.indigo50, _rt_Tw.indigo500)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('step-$n'),
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (_step != n) _setStep(n);
          },
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? _rt_Tw.indigo500 : _rt_Lab.border,
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done
                        ? _rt_Tw.green600
                        : (active ? _rt_Tw.indigo600 : _rt_Lab.overlay),
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : Text(
                          '$n',
                          style: TextStyle(
                            fontSize: 13,
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
                        s['t'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: active
                              ? _rt_Lab.onTinted(
                                  _rt_Tw.indigo100,
                                  _rt_Tw.indigo700,
                                )
                              : _rt_Lab.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s['d'] as String,
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
        ),
      ),
    );
  }

  // ------------------------------------------------------ control deck ---
  Widget _controlDeck() {
    final amps = _amps;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('deck.title').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _mainOn ? _rt_Tw.green500 : _rt_Tw.slate500,
                  shape: BoxShape.circle,
                  boxShadow: _mainOn
                      ? [
                          const BoxShadow(
                            color: Color(0x8022C55E),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
          Divider(color: _rt_Lab.border, height: 18),
          // Main supply toggle.
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('deck.main'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                  ),
                ),
              ),
              _switchWidget(const ValueKey('sw-main'), _mainOn, _toggleMain),
            ],
          ),
          const SizedBox(height: 10),
          // Appliance buttons.
          Row(
            children: [
              _applianceBtn('bulb', Icons.lightbulb_outline, _bulbOn),
              const SizedBox(width: 6),
              _applianceBtn('fan', Icons.wind_power, _fanOn),
              const SizedBox(width: 6),
              _applianceBtn('heater', Icons.local_fire_department, _heaterOn),
            ],
          ),
          const SizedBox(height: 8),
          // Load slider (step 2 only).
          Opacity(
            opacity: _step == 2 ? 1 : 0.45,
            child: _rt_LabeledSlider(
              label: _tx.s('deck.load'),
              value: _load,
              min: 0,
              max: 10,
              divisions: 20,
              valueText: '${_load.toStringAsFixed(1)} A',
              color: _rt_Tw.amber600,
              onChanged: _step == 2 ? _setLoad : null,
            ),
          ),
          // Live current readout (the deck's #val-current).
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('deck.current'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              Text(
                '${amps.toStringAsFixed(1)} A',
                key: const ValueKey('val-current'),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  color: amps > 5 ? _rt_Tw.red500 : _rt_Tw.amber600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Safety controls (step 3 only).
          Opacity(
            opacity: _step == 3 ? 1 : 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _fault
                        ? [
                            const BoxShadow(
                              color: Color(0x80EF4444),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: _rt_ActionButton(
                    label: _tx.s('deck.fault'),
                    icon: _fault ? Icons.flash_on : Icons.flash_off,
                    color: _fault ? _rt_Tw.red500 : _rt_Tw.red600,
                    expand: true,
                    sound:
                        null, // handled in _toggleFault (magic / wrong / toggle)
                    onPressed: _step == 3 ? _toggleFault : null,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _rt_Lab.overlay,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _rt_Lab.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.public,
                        size: 13,
                        color: _rt_Tw.green500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _tx.s('deck.earthing'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _rt_Tw.green500,
                          ),
                        ),
                      ),
                      _switchWidget(
                        const ValueKey('sw-earth'),
                        _earth,
                        _step == 3 ? _toggleEarth : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Replace-fuse button appears only when the fuse has blown.
          if (!_fuseIntact)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _rt_ActionButton(
                label: _tx.s('deck.repair'),
                icon: Icons.build,
                color: _rt_Tw.indigo600,
                expand: true,
                onPressed: _repairFuse,
              ),
            ),
        ],
      ),
    );
  }

  Widget _switchWidget(Key key, bool value, VoidCallback? onTap) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 46,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value
                ? _rt_Tw.green600.withValues(alpha: 0.35)
                : _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? _rt_Tw.green500 : _rt_Lab.borderStrong,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? _rt_Tw.green500 : _rt_Tw.slate400,
                shape: BoxShape.circle,
                boxShadow: value
                    ? [const BoxShadow(color: Color(0x8022C55E), blurRadius: 6)]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _applianceBtn(String type, IconData icon, bool on) {
    final enabled = _mainOn;
    return Expanded(
      child: Material(
        color: on
            ? _rt_Lab.tinted(_rt_Tw.indigo100, _rt_Tw.indigo500)
            : _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: ValueKey('app-$type'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _toggleAppliance(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: on ? _rt_Tw.indigo500 : _rt_Lab.border,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: on
                      ? _rt_Tw.indigo500
                      : (enabled ? _rt_Lab.text : _rt_Lab.textFaint),
                ),
                const SizedBox(height: 3),
                Text(
                  _tx.s('deck.$type'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: on
                        ? _rt_Lab.onTinted(_rt_Tw.indigo100, _rt_Tw.indigo700)
                        : (enabled ? _rt_Lab.text : _rt_Lab.textFaint),
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

/// The HTML body.animate-flash-red: pulsing red vignette during a live fault.
class _DangerFlash extends StatefulWidget {
  const _DangerFlash();

  @override
  State<_DangerFlash> createState() => _DangerFlashState();
}

class _DangerFlashState extends State<_DangerFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _rt_Tw.red500.withValues(alpha: 0.35 + 0.45 * _c.value),
            width: 6,
          ),
          gradient: RadialGradient(
            radius: 1.2,
            colors: [
              Colors.transparent,
              _rt_Tw.red500.withValues(alpha: 0.08 + 0.14 * _c.value),
            ],
            stops: const [0.55, 1],
          ),
        ),
      ),
    );
  }
}
