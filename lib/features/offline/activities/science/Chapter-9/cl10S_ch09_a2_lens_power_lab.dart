// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 9.2: Power of Lens
// Converted from Cl10S-Ch9-A2-LensPowerLab.html (three.js optical bench -> 2D
// CustomPainter ray diagram in a ZoomableCanvas).
//
// An optical bench sends five parallel rays through a lens whose net power is
// set with the P1 slider (and, once "Combination" is on, P1 + P2). The net
// power decides the lens shape (convex / concave / plane plate), where the
// refracted rays go (through F, away from F, or straight on) and the focal
// marker + dashed f measurement, all computed exactly as the source:
// P = P1 + P2, f = 100 / P cm (infinity at P = 0). The sidebar carries the
// controls and readouts, the three missions (+5 D convex, -5 D concave,
// net 0 plate), the live "Textbook Solution" notebook with its collapsible
// steps, and the Concepts / Teacher Guide / Outcomes notes; ticking off all
// three missions ends the lab with a completion popup.

// --- TRANSLATION DATA (the source's i18n block; te: ignored) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

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
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const blue400 = Color(0xFF60A5FA);
  static const blue600 = Color(0xFF2563EB);
  static const red500 = Color(0xFFEF4444);
  static const amber400 = Color(0xFFFBBF24);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green50 = Color(0xFFF0FDF4);
  static const green500 = Color(0xFF22C55E);
  static const emerald400 = Color(0xFF34D399);
  static const emerald600 = Color(0xFF059669);
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
    'title': 'Power of Lens',
    'sub': 'Class 10 • Light - Reflection and Refraction',
    'enter': 'Enter _rt_Lab',
    'footnote': 'Dioptre • P = 1/f • Combinations',
    'powerTitle': 'Power',
    'combo': 'Combination',
    'p1': 'Power 1 (P₁)',
    'p2': 'Power 2 (P₂)',
    'pNet': 'Net Power (P)',
    'fNet': 'Focal Len (f)',
    'notebook': 'Textbook Solution',
    'probTitle': 'Problem Statement',
    'expand': 'Expand All',
    'collapse': 'Collapse All',
    'types': {
      'convex': 'Convex (Converging)',
      'concave': 'Concave (Diverging)',
      'plane': 'Plane Glass Plate',
    },
    'labels': {'lens': 'Lens', 'focus': 'Focus (F)'},
    'steps': {
      'netPower': 'Net Power',
      'focalLen': 'Focal Length',
      'concl': 'Conclusion',
      'signPos': 'Positive (+)',
      'signNeg': 'Negative (-)',
      'signZero': 'Zero',
    },
    'templates': {
      'single':
          'Calculate the focal length and nature of a lens with Power P₁ = {p1} D.',
      'combo':
          'Two lenses of Power P₁ = {p1} D and P₂ = {p2} D are placed in contact. Find the Net Power and Focal Length.',
      'conclText':
          'Sign of Power is {sign}. Therefore, it behaves as a {type}.',
    },
    'tabs': {
      'context': 'Concepts',
      'guide': 'Teacher Guide',
      'explore': 'Mission Log',
      'analysis': 'Outcomes',
    },
    'missionObj': 'Mission Objective',
    'missionDesc': 'Explore the Power of Lenses and their combinations.',
    'missions': [
      'Create a Convex Lens (+5.0 D)',
      'Create a Concave Lens (-5.0 D)',
      'Create a Plane Plate (Net 0.0 D)',
    ],
    'missionN': 'Mission {n}',
    'missionDone': 'Mission {n} Complete!',
    'ui': {'toggleLabels': 'Toggle Labels'},
    'context': {
      'whyTitle': 'Why Learn This?',
      'whyBody':
          'Understanding the Power of a Lens is crucial for correcting vision defects and designing optical instruments. It measures the degree of convergence or divergence of light rays falling on it (Page 157).',
      'appsTitle': 'Applications',
      'apps': [
        {
          't': 'Spectacles',
          'd':
              'Opticians prescribe corrective lenses based on power (e.g., +2.0D).',
        },
        {
          't': 'Optical Instruments',
          'd': 'Lens systems in microscopes & telescopes use additive power.',
        },
        {
          't': 'Contact Lenses',
          'd': 'Precise vision correction directly on the eye.',
        },
      ],
    },
    'guide': {
      'forTitle': 'For Teachers',
      'body':
          'This activity demonstrates the relationship between Power (P) and Focal Length (f): P = 1/f.',
      'unit': 'The SI unit of power is Dioptre (D). 1 D = 1 m⁻¹.',
      'flowTitle': 'Activity Flow',
      'flow': [
        'Set Power 1 (P₁) using the slider. Observe the ray bending.',
        'Toggle "Combination" to add a second lens (P₂).',
        'Verify the additive property: P = P₁ + P₂.',
        'Note the sign conventions: Convex (+), Concave (-).',
      ],
    },
    'analysis': {
      'title': 'Learning Outcomes',
      'items': [
        {
          't': '1. Inverse Relationship',
          'd':
              'Power is inversely proportional to focal length (P ∝ 1/f). Short focal length = High Power.',
        },
        {
          't': '2. Sign Convention',
          'd':
              'Convex lenses have Positive (+) power. Concave lenses have Negative (-) power.',
        },
        {
          't': '3. Additive Property',
          'd':
              'Net power of lenses in contact is the algebraic sum: P = P₁ + P₂ + P₃...',
        },
      ],
    },
    'complete': {
      'title': 'All Missions Complete!',
      'msg':
          'Power P = 1/f measures how strongly a lens bends light. A convex lens has positive power, a concave lens negative, and a plane plate zero. For lenses in contact the powers simply add: P = P₁ + P₂.',
    },
  },
  'hi': {
    'title': 'लेंस की क्षमता',
    'sub': 'कक्षा 10 • प्रकाश – परावर्तन तथा अपवर्तन',
    'enter': 'लैब में प्रवेश करें',
    'footnote': 'डायोप्टर • P = 1/f • संयोजन',
    'powerTitle': 'क्षमता',
    'combo': 'संयोजन',
    'p1': 'क्षमता 1 (P₁)',
    'p2': 'क्षमता 2 (P₂)',
    'pNet': 'कुल क्षमता (P)',
    'fNet': 'फोकस दूरी (f)',
    'notebook': 'पाठ्यपुस्तक हल',
    'probTitle': 'समस्या कथन',
    'expand': 'विस्तार करें',
    'collapse': 'संक्षिप्त करें',
    'types': {
      'convex': 'उत्तल (अभिसारी)',
      'concave': 'अवतल (अपसारी)',
      'plane': 'समतल कांच की प्लेट',
    },
    'labels': {'lens': 'लेंस', 'focus': 'फोकस (F)'},
    'steps': {
      'netPower': 'कुल क्षमता',
      'focalLen': 'फोकस दूरी',
      'concl': 'निष्कर्ष',
      'signPos': 'धनात्मक (+)',
      'signNeg': 'ऋणात्मक (-)',
      'signZero': 'शून्य',
    },
    'templates': {
      'single':
          'एक लेंस जिसकी क्षमता P₁ = {p1} D है, उसकी फोकस दूरी और प्रकृति की गणना करें।',
      'combo':
          'P₁ = {p1} D और P₂ = {p2} D क्षमता वाले दो लेंस संपर्क में रखे गए हैं। कुल क्षमता और फोकस दूरी ज्ञात करें।',
      'conclText':
          'क्षमता का चिन्ह {sign} है। अतः, यह {type} की तरह व्यवहार करता है।',
    },
    'tabs': {
      'context': 'अवधारणा',
      'guide': 'शिक्षक गाइड',
      'explore': 'मिशन लॉग',
      'analysis': 'निष्कर्ष / परिणाम',
    },
    'missionObj': 'मिशन का उद्देश्य',
    'missionDesc': 'लेंस की क्षमता और उनके संयोजन का अन्वेषण करें।',
    'missions': [
      'उत्तल लेंस बनाएं (+5.0 D)',
      'अवतल लेंस बनाएं (-5.0 D)',
      'समतल प्लेट बनाएं (0.0 D)',
    ],
    'missionN': 'मिशन {n}',
    'missionDone': 'मिशन {n} पूरा हुआ!',
    'ui': {'toggleLabels': 'लेबल टॉगल करें'},
    'context': {
      'whyTitle': 'यह क्यों सीखें?',
      'whyBody':
          'लेंस की क्षमता को समझना दृष्टि दोषों को ठीक करने और ऑप्टिकल उपकरणों को डिजाइन करने के लिए महत्वपूर्ण है। यह प्रकाश किरणों के अभिसरण या अपसरण की डिग्री को मापता है (पृष्ठ 157)।',
      'appsTitle': 'अनुप्रयोग',
      'apps': [
        {
          't': 'चश्मा (दृष्टि सुधार)',
          'd': 'डॉक्टर क्षमता के आधार पर लेंस लिखते हैं (जैसे, +2.0D)।',
        },
        {
          't': 'सूक्ष्मदर्शी और दूरबीन',
          'd': 'इनमें लेंसों के संयोजन (योगात्मक क्षमता) का उपयोग होता है।',
        },
        {'t': 'कॉन्टैक्ट लेंस', 'd': 'आंख पर सीधे सटीक दृष्टि सुधार।'},
      ],
    },
    'guide': {
      'forTitle': 'शिक्षकों के लिए',
      'body':
          'यह गतिविधि क्षमता (P) और फोकस दूरी (f) के बीच संबंध प्रदर्शित करती है: P = 1/f।',
      'unit': 'क्षमता का SI मात्रक डायोप्टर (D) है। 1 D = 1 m⁻¹।',
      'flowTitle': 'गतिविधि प्रवाह',
      'flow': [
        'स्लाइडर का उपयोग करके क्षमता 1 (P₁) सेट करें। किरणों का मुड़ना देखें।',
        'दूसरा लेंस (P₂) जोड़ने के लिए "संयोजन" टॉगल करें।',
        'योगात्मक गुण सत्यापित करें: P = P₁ + P₂।',
        'चिन्ह परिपाटी नोट करें: उत्तल (+), अवतल (-)।',
      ],
    },
    'analysis': {
      'title': 'सीखने के परिणाम',
      'items': [
        {
          't': '1. व्युत्क्रम संबंध',
          'd':
              'क्षमता फोकस दूरी के व्युत्क्रमानुपाती होती है (P ∝ 1/f)। कम फोकस दूरी = उच्च क्षमता।',
        },
        {
          't': '2. चिन्ह परिपाटी',
          'd':
              'उत्तल लेंस की क्षमता धनात्मक (+) होती है। अवतल लेंस की क्षमता ऋणात्मक (-) होती है।',
        },
        {
          't': '3. योगात्मक गुण',
          'd':
              'संपर्क में रखे लेंसों की कुल क्षमता उनका बीजगणितीय योग होती है: P = P₁ + P₂...',
        },
      ],
    },
    'complete': {
      'title': 'सभी मिशन पूरे हुए!',
      'msg':
          'लेंस की क्षमता P = 1/f यह मापती है कि लेंस प्रकाश को कितना मोड़ता है। उत्तल लेंस की क्षमता धनात्मक, अवतल की ऋणात्मक और समतल प्लेट की शून्य होती है। संपर्क में रखे लेंसों की क्षमताएँ जुड़ जाती हैं: P = P₁ + P₂।',
    },
  },
});

// --- COLOURS (the source's toolbar/tag classes) ---
const _accent = _rt_Tw.cyan500;
const _p1Color = _rt_Tw.emerald400;
const _p2Color = Color(0xFFC084FC); // purple-400
const _fColor = _rt_Tw.cyan400;

const _theme = _rt_ShellTheme(
  accent: _accent,
  headerGradient: [_rt_Tw.slate900, Color(0xFF164E63)],
  headerSubtitleColor: Color(0xFFA5F3FC),
);

/// JavaScript number-to-string: whole numbers print without a decimal part.
String _jsNum(double x) =>
    x == x.truncateToDouble() ? x.toInt().toString() : x.toString();

/// The `(p > 0 ? '+' : '') + p` the source puts in the problem statement.
String _plus(double x) => '${x > 0 ? '+' : ''}${_jsNum(x)}';

/// `(x > 0 ? "+" : "") + x.toFixed(1)` used by every readout.
String _signed1(double x) => '${x > 0 ? '+' : ''}${x.toStringAsFixed(1)}';

class Cl10SCh09A2LensPowerLabPage extends StatefulWidget {
  const Cl10SCh09A2LensPowerLabPage({super.key});

  @override
  State<Cl10SCh09A2LensPowerLabPage> createState() =>
      _Cl10SCh09A2LensPowerLabPageState();
}

class _Cl10SCh09A2LensPowerLabPageState
    extends State<Cl10SCh09A2LensPowerLabPage> {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();

  // --- STATE (P1 / P2 / isCombined / labelsVisible in the source) ---
  double _p1 = 2.0;
  double _p2 = 0.0;
  bool _combined = false;
  bool _labels = true;

  /// areStepsExpanded + the open/closed state of each notebook step.
  bool _stepsExpanded = true;
  final Map<String, bool> _open = {'net': true, 'focal': true, 'concl': true};

  final List<bool> _missions = [false, false, false];
  bool _completeShown = false;

  /// Bumped on restart so a pending completion popup is dropped.
  int _gen = 0;

  /// The last lens nature, to sound the convex/concave/plane transformation.
  late String _lastType = _typeKey;

  // --- PHYSICS (updatePhysics: P = P1 + P2, f = 100 / P cm) ---
  double get _pNet => _combined ? _p1 + _p2 : _p1;
  double get _fNet => _pNet != 0 ? 100 / _pNet : double.infinity;
  String get _typeKey =>
      _pNet > 0 ? 'convex' : (_pNet < 0 ? 'concave' : 'plane');

  String get _pNetText => '${_signed1(_pNet)} D';
  String get _fNetText =>
      _fNet.isInfinite ? '∞' : '${_fNet.toStringAsFixed(1)} cm';

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
    _zoom.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------- controls ---
  /// Runs after every power change: the nature-change reveal + checkMissions.
  void _afterPhysics() {
    if (_typeKey != _lastType) {
      // The lens morphs between convex / plate / concave.
      _rt_playSfx(_rt_Sfx.magic);
      _lastType = _typeKey;
    }
    _checkMissions();
  }

  /// Sliders run -10..+10 in 0.5 D steps, like the range inputs.
  void _setP1(double raw) {
    final v = ((raw * 2).roundToDouble() / 2).clamp(-10.0, 10.0);
    if (v == _p1) return;
    setState(() => _p1 = v);
    _afterPhysics();
  }

  void _setP2(double raw) {
    final v = ((raw * 2).roundToDouble() / 2).clamp(-10.0, 10.0);
    if (v == _p2) return;
    setState(() => _p2 = v);
    _afterPhysics();
  }

  /// combineToggle change: off resets P2 to 0, like the source.
  void _toggleCombine(bool on) {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _combined = on;
      if (!on) _p2 = 0;
    });
    _afterPhysics();
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labels = !_labels);
  }

  /// checkMissions(): +5 D, -5 D and |P| < 0.1, each once, with a toast.
  void _checkMissions() {
    final p = _pNet;
    void hit(int i) {
      if (_missions[i]) return;
      _missions[i] = true;
      _rt_playSfx(_rt_Sfx.correct);
      _shell.showToast(_tx.s('missionDone').replaceAll('{n}', '${i + 1}'));
    }

    if (p >= 5.0) hit(0);
    if (p <= -5.0) hit(1);
    if (p.abs() < 0.1) hit(2);

    if (_missions.every((m) => m) && !_completeShown) {
      _completeShown = true;
      final gen = _gen;
      // Let the last mission toast land before the popup covers it.
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || gen != _gen) return;
        _shell.showSuccess(
          title: _tx.s('complete.title'),
          message: _tx.s('complete.msg'),
        );
      });
    }
  }

  void _toggleAllSteps() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _stepsExpanded = !_stepsExpanded;
      for (final k in _open.keys) {
        _open[k] = _stepsExpanded;
      }
    });
  }

  void _toggleStep(String id) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _open[id] = !(_open[id] ?? true));
  }

  /// resetSimulation(): back to P1 = +2.0 D, single lens, everything cleared.
  void _restart() {
    _gen++;
    _zoom.reset();
    setState(() {
      _p1 = 2.0;
      _p2 = 0.0;
      _combined = false;
      _labels = true;
      _stepsExpanded = true;
      for (final k in _open.keys) {
        _open[k] = true;
      }
      for (var i = 0; i < _missions.length; i++) {
        _missions[i] = false;
      }
      _completeShown = false;
      _lastType = _typeKey;
    });
  }

  // ------------------------------------------------------------- build ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final next = _missions.indexWhere((m) => !m);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('sub'),
            theme: _theme,
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('sub'),
              buttonLabel: _tx.s('enter'),
              footnote: _tx.s('footnote'),
              icon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _labels,
                icon: _labels ? Icons.label : Icons.label_off,
                tooltip: _tx.s('ui.toggleLabels'),
                onTap: _toggleLabels,
              ),
            ],
            hint: next == -1
                ? null
                : _rt_StepHint(
                    number: '${next + 1}',
                    text: _tx.list('missions')[next] as String,
                    label: _tx.s('missionN').replaceAll('{n}', '${next + 1}'),
                  ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.task_alt,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _rt_ZoomableCanvas(
              controller: _zoom,
              child: LayoutBuilder(
                builder: (context, c) => CustomPaint(
                  size: Size(c.maxWidth, c.maxHeight),
                  painter: _BenchPainter(
                    pNet: _pNet,
                    fNet: _fNet,
                    labels: _labels,
                    lensLabel: _tx.s('labels.lens'),
                    focusLabel: _tx.s('labels.focus'),
                  ),
                ),
              ),
            ),
            canvasOverlays: [
              Positioned(
                top: 12,
                left: 72,
                right: 60,
                child: IgnorePointer(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _rt_HudCard(
                        value: _pNetText,
                        label: _tx.s('pNet'),
                        color: _rt_Tw.emerald600,
                      ),
                      _rt_HudCard(
                        value: _fNetText,
                        label: _tx.s('fNet'),
                        color: _rt_Tw.cyan600,
                      ),
                      _typeChip(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The `#lens-type` badge next to the readouts.
  Widget _typeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.borderStrong, width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
      ),
      child: Text(
        _tx.s('types.$_typeKey').toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: _rt_Lab.text,
        ),
      ),
    );
  }

  // ----------------------------------------------------------- sidebar ---
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObj'),
          desc: _tx.s('missionDesc'),
          accent: _accent,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('powerTitle'),
                icon: Icons.bolt,
                color: _accent,
              ),
              _controlsCard(),
              const SizedBox(height: 14),
              _rt_SectionLabel(
                _tx.s('tabs.explore'),
                icon: Icons.checklist,
                color: _accent,
              ),
              for (var i = 0; i < 3; i++) _missionRow(i),
              const SizedBox(height: 14),
              _notebookHeader(),
              const SizedBox(height: 8),
              _problemCard(),
              const SizedBox(height: 8),
              ..._stepCards(),
              const SizedBox(height: 16),
              // --- Notes at the foot: the drawer's Concepts / Guide / Outcomes ---
              _rt_SectionLabel(
                _tx.s('tabs.context'),
                icon: Icons.lightbulb,
                color: _rt_Tw.amber400,
              ),
              _rt_InfoCard(
                title: _tx.s('context.whyTitle'),
                body: _tx.s('context.whyBody'),
                color: _rt_Tw.cyan600,
                icon: Icons.psychology,
              ),
              _rt_SectionLabel(
                _tx.s('context.appsTitle'),
                color: _rt_Tw.amber400,
              ),
              for (final (i, app) in _tx.list('context.apps').indexed)
                _appRow(
                  const [
                    Icons.remove_red_eye,
                    Icons.biotech,
                    Icons.lens_blur,
                  ][i],
                  const [_rt_Tw.emerald400, _rt_Tw.blue400, _p2Color][i],
                  (app as Map)['t'] as String,
                  app['d'] as String,
                ),
              const SizedBox(height: 12),
              _rt_SectionLabel(
                _tx.s('tabs.guide'),
                icon: Icons.menu_book,
                color: _rt_Tw.amber400,
              ),
              _rt_InfoCard(
                title: _tx.s('guide.forTitle'),
                body: '${_tx.s('guide.body')}\n\n${_tx.s('guide.unit')}',
                color: _rt_Tw.blue600,
                icon: Icons.school,
              ),
              _rt_InfoCard(
                title: _tx.s('guide.flowTitle'),
                color: _rt_Tw.teal600,
                icon: Icons.format_list_numbered,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, step) in _tx.list('guide.flow').indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${i + 1}. $step',
                            style: TextStyle(
                              fontSize: 12,
                              color: _rt_Lab.text,
                              height: 1.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _rt_SectionLabel(
                _tx.s('analysis.title'),
                icon: Icons.insights,
                color: _rt_Tw.amber400,
              ),
              for (final (i, item) in _tx.list('analysis.items').indexed)
                _rt_InfoCard(
                  title: (item as Map)['t'] as String,
                  body: item['d'] as String,
                  color: const [
                    _rt_Tw.emerald600,
                    _rt_Tw.yellow500,
                    _rt_Tw.blue600,
                  ][i],
                  leftBorder: true,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  /// The toolbar block: combination toggle, both sliders and the readouts.
  Widget _controlsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('combo').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              Switch(
                key: const ValueKey('combine-toggle'),
                value: _combined,
                activeTrackColor: _rt_Tw.cyan600,
                onChanged: _toggleCombine,
              ),
            ],
          ),
          _rt_LabeledSlider(
            key: const ValueKey('p1-slider'),
            label: _tx.s('p1'),
            value: _p1,
            min: -10,
            max: 10,
            divisions: 40,
            valueText: '${_signed1(_p1)} D',
            color: _p1Color,
            onChanged: _setP1,
          ),
          Opacity(
            opacity: _combined ? 1 : 0.45,
            child: IgnorePointer(
              ignoring: !_combined,
              child: _rt_LabeledSlider(
                key: const ValueKey('p2-slider'),
                label: _tx.s('p2'),
                value: _p2,
                min: -10,
                max: 10,
                divisions: 40,
                valueText: '${_signed1(_p2)} D',
                color: _p2Color,
                onChanged: _combined ? _setP2 : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _readout('pNet', 'p-net', _pNetText, _p1Color),
                    ),
                    Expanded(
                      child: _readout('fNet', 'f-net', _fNetText, _fColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _rt_Lab.tinted(_rt_Tw.slate100, _rt_Tw.slate500),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _rt_Lab.borderStrong),
                  ),
                  child: Text(
                    _tx.s('types.$_typeKey').toUpperCase(),
                    key: const ValueKey('lens-type'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: _rt_Lab.text,
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

  Widget _readout(String labelKey, String valueKey, String value, Color color) {
    return Column(
      children: [
        Text(
          _tx.s(labelKey).toUpperCase(),
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.textMuted,
          ),
        ),
        Text(
          value,
          key: ValueKey(valueKey),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: _rt_Lab.onTinted(
              color,
              Color.lerp(color, Colors.black, 0.25)!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionRow(int i) {
    final done = _missions[i];
    return Container(
      key: ValueKey('mission-$i'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: done
            ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done ? _rt_Lab.tintedBorder(_rt_Tw.green500) : _rt_Lab.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: done ? _rt_Tw.green500 : _rt_Lab.textFaint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('missionN').replaceAll('{n}', '${i + 1}'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _tx.list('missions')[i] as String,
                  style: TextStyle(
                    fontSize: 11.5,
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

  // -------------------------------------------- notebook (updateNotebook) ---
  Widget _notebookHeader() {
    return Row(
      children: [
        const Icon(Icons.book, size: 15, color: _rt_Tw.yellow400),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _tx.s('notebook').toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: _rt_Tw.yellow400,
            ),
          ),
        ),
        InkWell(
          key: const ValueKey('expand-all'),
          onTap: _toggleAllSteps,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Text(
              (_stepsExpanded ? _tx.s('collapse') : _tx.s('expand'))
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: _rt_Lab.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The problem statement, from templates.single / templates.combo.
  String _problem() {
    if (_combined) {
      return _tx
          .s('templates.combo')
          .replaceAll('{p1}', _plus(_p1))
          .replaceAll('{p2}', _plus(_p2));
    }
    return _tx.s('templates.single').replaceAll('{p1}', _plus(_p1));
  }

  Widget _problemCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('probTitle').toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: _rt_Lab.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _problem(),
            key: const ValueKey('calc-problem'),
            style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.45),
          ),
        ],
      ),
    );
  }

  /// The three (or two) collapsible calculation steps, verbatim maths.
  List<Widget> _stepCards() {
    final p = _pNet, f = _fNet;
    var n = 0;
    final cards = <Widget>[];
    if (_combined) {
      cards.add(
        _stepCard('net', ++n, _tx.s('steps.netPower'), _rt_Tw.cyan400, [
          'P = P₁ + P₂',
          'P = (${_jsNum(_p1)}) + (${_jsNum(_p2)}) = ${p.toStringAsFixed(1)} D',
        ]),
      );
    }
    cards.add(
      _stepCard(
        'focal',
        ++n,
        _tx.s('steps.focalLen'),
        _rt_Tw.emerald400,
        p == 0
            ? ['f = 1/0 = ∞']
            : [
                'f = 1/P = 1/${p.toStringAsFixed(1)} = ${(1 / p).toStringAsFixed(3)} m',
                'f = ${(1 / p).toStringAsFixed(3)} × 100 = ${f.toStringAsFixed(1)} cm',
              ],
      ),
    );
    final sign = p > 0 ? 'signPos' : (p < 0 ? 'signNeg' : 'signZero');
    cards.add(
      _stepCard('concl', ++n, _tx.s('steps.concl'), _rt_Tw.yellow400, [
        _tx
            .s('templates.conclText')
            .replaceAll('{sign}', _tx.s('steps.$sign'))
            .replaceAll('{type}', _tx.s('types.$_typeKey')),
      ]),
    );
    return cards;
  }

  Widget _stepCard(
    String id,
    int n,
    String title,
    Color accent,
    List<String> lines,
  ) {
    final open = _open[id] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: ValueKey('step-$id'),
            onTap: () => _toggleStep(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _rt_Lab.onTinted(
                          accent,
                          Color.lerp(accent, Colors.black, 0.3)!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: _rt_Lab.onTinted(
                          accent,
                          Color.lerp(accent, Colors.black, 0.3)!,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: _rt_Lab.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Container(
              key: ValueKey('step-$id-body'),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                border: Border(top: BorderSide(color: _rt_Lab.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
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
    );
  }

  Widget _appRow(IconData icon, Color color, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
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
}

/// Round toolbar toggle button, matching the shell's zoom buttons.
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
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _rt_Tw.cyan600 : _rt_Lab.surface,
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

// ------------------------------------------------------------- painter ---
/// The optical bench, side on: table, ruler with ticks, the net-power lens on
/// its stand, five parallel incident rays, the refracted fan through (or away
/// from) the focus, the focal marker, the dashed f measurement with its tag,
/// and the Lens / Focus labels. Geometry matches the source: rays start at
/// x = -60 cm with a ±8 cm spread, the lens sits at x = 0 and the focus at
/// x = f = 100 / P cm.
class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.pNet,
    required this.fNet,
    required this.labels,
    required this.lensLabel,
    required this.focusLabel,
  });

  final double pNet;
  final double fNet; // cm; infinite when pNet == 0
  final bool labels;
  final String lensLabel;
  final String focusLabel;

  static const _rayColor = Color(0xFFFF5A5A);
  static const _glass = Color(0xFFBAE6FD);

  late double _s; // px per cm
  late double _axisY; // principal axis
  late double _rulerY; // top of the ruler bar
  late Size _size;

  double _x(double cm) => _size.width / 2 + cm * _s;
  Offset _pt(double xCm, double yCm) => Offset(_x(xCm), _axisY - yCm * _s);

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    _s = size.width / 150;
    _axisY = size.height * 0.40;
    _rulerY = math.min(size.height - 52, _axisY + 20 * _s);

    _background(canvas, size);
    _table(canvas, size);
    _ruler(canvas);
    _axis(canvas);
    _stand(canvas);
    _rays(canvas);
    _lens(canvas);
    _focusAndMeasure(canvas);
    if (labels) _labels(canvas);
  }

  void _background(Canvas c, Size size) {
    c.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C4A6E), Color(0xFF020617)],
        ).createShader(Offset.zero & size),
    );
  }

  void _table(Canvas c, Size size) {
    final top = _rulerY + 8;
    final rect = Rect.fromLTRB(0, top, size.width, size.height);
    c.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E3A8A), Color(0xFF0B1220)],
        ).createShader(rect),
    );
    c.drawLine(
      Offset(0, top),
      Offset(size.width, top),
      Paint()
        ..color = const Color(0xFF3B5BA9)
        ..strokeWidth = 1.5,
    );
  }

  void _ruler(Canvas c) {
    final bar = Rect.fromLTWH(_x(-70), _rulerY, 140 * _s, 8);
    c.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(2)),
      Paint()..color = const Color(0xFF0F172A),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Ticks every 2 cm, taller every 5, tallest every 10 (source ticksGroup).
    final minor = Paint()
      ..color = _rt_Tw.slate400
      ..strokeWidth = 1;
    final major = Paint()
      ..color = _rt_Tw.slate200
      ..strokeWidth = 1.6;
    for (var x = -60; x <= 60; x += 2) {
      final h = x % 10 == 0 ? 12.0 : (x % 5 == 0 ? 8.0 : 5.0);
      c.drawLine(
        Offset(_x(x.toDouble()), _rulerY),
        Offset(_x(x.toDouble()), _rulerY - h),
        x % 10 == 0 ? major : minor,
      );
    }
  }

  void _axis(Canvas c) {
    _dash(
      c,
      Offset(0, _axisY),
      Offset(_size.width, _axisY),
      Paint()
        ..color = _rt_Tw.slate400.withValues(alpha: 0.45)
        ..strokeWidth = 1,
      on: 5,
      off: 5,
    );
  }

  void _stand(Canvas c) {
    final holder = Paint()..color = const Color(0xFF334155);
    // Stem from the lens rim down to the ruler, plus a base plate.
    c.drawRect(
      Rect.fromLTRB(_x(0) - 2.5, _axisY + 10 * _s, _x(0) + 2.5, _rulerY),
      holder,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(_x(0), _rulerY - 2),
          width: 26,
          height: 7,
        ),
        const Radius.circular(3),
      ),
      holder,
    );
  }

  void _rays(Canvas c) {
    final inc = Paint()
      ..color = _rayColor.withValues(alpha: 0.85)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final ref = Paint()
      ..color = _rayColor.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final virtual = Paint()
      ..color = _rt_Tw.slate300.withValues(alpha: 0.6)
      ..strokeWidth = 1.4;

    for (var i = -2; i <= 2; i++) {
      final yOff = i * 4.0; // beamY_spread = 8 -> offsets -8..8 cm
      final start = _pt(-60, yOff);
      final hit = _pt(0, yOff);
      c.drawLine(start, hit, inc);
      _arrow(c, start, hit, 0.55, inc.color);

      Offset end;
      if (pNet == 0) {
        end = _pt(70, yOff);
      } else {
        final fPos = _pt(fNet, 0);
        var dir = fNet > 0 ? fPos - hit : hit - fPos;
        final len = dir.distance;
        if (len < 1e-6) {
          end = _pt(70, yOff);
        } else {
          dir = dir / len;
          end = hit + dir * (150 * _s);
          if (fNet < 0) {
            // Diverging: dashed virtual extension back to the focus.
            _dash(c, fPos, hit, virtual, on: 5, off: 4);
          }
        }
      }
      c.drawLine(hit, end, ref);
      _arrow(c, hit, end, 0.3, ref.color);
    }
  }

  void _lens(Canvas c) {
    final fill = Paint()..color = _glass.withValues(alpha: 0.30);
    final edge = Paint()
      ..color = _glass.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final hh = 10 * _s; // half height (lens radius 10 cm)

    if (pNet >= 0) {
      // Sphere scaled (thick, 1, 1): thick = max(0.05, P * 0.04) of radius 10.
      final halfW = math.max(0.05, pNet * 0.04) * 10 * _s;
      final rect = Rect.fromCenter(
        center: Offset(_x(0), _axisY),
        width: halfW * 2,
        height: hh * 2,
      );
      c.drawOval(rect, fill);
      c.drawOval(rect, edge);
    } else {
      // Concave: thin waist, edges thickening with |P|.
      final e = (0.6 + 0.25 * pNet.abs()) * _s * 2.2;
      const waistFrac = 0.28;
      final cx = _x(0);
      final top = _axisY - hh, bottom = _axisY + hh;
      final path = Path()
        ..moveTo(cx - e, top)
        ..lineTo(cx + e, top)
        ..quadraticBezierTo(
          cx + (2 * e * waistFrac - e),
          _axisY,
          cx + e,
          bottom,
        )
        ..lineTo(cx - e, bottom)
        ..quadraticBezierTo(cx - (2 * e * waistFrac - e), _axisY, cx - e, top)
        ..close();
      c.drawPath(path, fill);
      c.drawPath(path, edge);
    }
    // Holder ring around the glass.
    c.drawOval(
      Rect.fromCenter(
        center: Offset(_x(0), _axisY),
        width: math.max(10.0, 4 * _s) * 0.6,
        height: hh * 2 + 6,
      ),
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _focusAndMeasure(Canvas c) {
    if (pNet == 0 || !fNet.isFinite) return;
    final fPos = _pt(fNet, 0);
    // fMarker: red dot with glow.
    c.drawCircle(
      fPos,
      7,
      Paint()..color = _rt_Tw.red500.withValues(alpha: 0.25),
    );
    c.drawCircle(fPos, 3.5, Paint()..color = _rt_Tw.red500);

    // measF: dashed cyan line just above the ruler + the f tag.
    final y = _rulerY - 18;
    final meas = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 1.6;
    _dash(c, Offset(_x(0), y), Offset(_x(fNet), y), meas, on: 6, off: 3);
    c.drawLine(Offset(_x(0), y - 4), Offset(_x(0), y + 4), meas);
    c.drawLine(Offset(_x(fNet), y - 4), Offset(_x(fNet), y + 4), meas);
    _bubble(
      c,
      Offset(_x(fNet / 2), y - 14),
      'f = ${fNet.toStringAsFixed(1)} cm',
      bg: const Color(0xFFCFFAFE),
      fg: const Color(0xFF155E75),
      border: const Color(0xFF67E8F9),
    );
  }

  void _labels(Canvas c) {
    _bubble(
      c,
      Offset(_x(0), _rulerY + 22),
      lensLabel,
      bg: const Color(0xE61E293B),
      fg: Colors.white,
      border: _rt_Tw.slate400,
    );
    if (pNet != 0 && fNet.isFinite) {
      _bubble(
        c,
        Offset(_x(fNet), _rulerY + 40),
        focusLabel,
        bg: const Color(0xE61E293B),
        fg: Colors.white,
        border: _rt_Tw.slate400,
      );
    }
  }

  // ------------------------------------------------------------ helpers ---
  void _dash(
    Canvas c,
    Offset a,
    Offset b,
    Paint p, {
    double on = 6,
    double off = 4,
  }) {
    final d = b - a;
    final len = d.distance;
    if (len < 1e-3) return;
    final dir = d / len;
    var t = 0.0;
    while (t < len) {
      final e = math.min(t + on, len);
      c.drawLine(a + dir * t, a + dir * e, p);
      t = e + off;
    }
  }

  /// Small direction arrowhead at fraction [f] along a -> b.
  void _arrow(Canvas c, Offset a, Offset b, double f, Color color) {
    final d = b - a;
    final len = d.distance;
    if (len < 20) return;
    final dir = d / len;
    final tip = a + d * f;
    final n = Offset(-dir.dy, dir.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - dir.dx * 7 + n.dx * 3.5,
        tip.dy - dir.dy * 7 + n.dy * 3.5,
      )
      ..lineTo(
        tip.dx - dir.dx * 7 - n.dx * 3.5,
        tip.dy - dir.dy * 7 - n.dy * 3.5,
      )
      ..close();
    c.drawPath(path, Paint()..color = color);
  }

  void _bubble(
    Canvas c,
    Offset center,
    String text, {
    required Color bg,
    required Color fg,
    required Color border,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 12,
        height: tp.height + 6,
      ),
      const Radius.circular(4),
    );
    c.drawRRect(r, Paint()..color = bg);
    c.drawRRect(
      r,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_BenchPainter old) =>
      old.pNet != pNet ||
      old.fNet != fNet ||
      old.labels != labels ||
      old.lensLabel != lensLabel ||
      old.focusLabel != focusLabel;
}
