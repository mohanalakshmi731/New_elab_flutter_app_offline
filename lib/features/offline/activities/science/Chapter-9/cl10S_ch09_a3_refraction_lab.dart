// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 9.3: Refraction of Light (Glass Slab)
// Converted from Cl10S-Ch9-A3-REfractionLab.html (three.js scene -> 2D
// top-view CustomPainter in a ZoomableCanvas; the source's rays all lie in
// one horizontal plane and its camera has a dedicated "Top View" button, so
// the flat ray diagram IS the scene).
//
// A laser fires at a rectangular slab of a selectable medium (Table 9.3:
// water, kerosene, benzene, crown glass, dense flint glass, diamond). The
// angle-of-incidence slider drives Snell's law exactly as the source
// (sin r = n1 sin i / n2, e = i, d = t sin(i-r)/cos r with t = 20 cm), the
// HUD shows n / r / e / d, the "Textbook Calculation" notebook rebuilds the
// worked example live, and three missions tick off into a completion popup.

// --- CONSTANTS (source header) ---

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
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const violet600 = Color(0xFF7C3AED);
  static const purple500 = Color(0xFFA855F7);
  static const red500 = Color(0xFFEF4444);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green500 = Color(0xFF22C55E);
  static const emerald500 = Color(0xFF10B981);
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
    this.tag,
    this.color = _rt_Tw.teal600,
    this.icon,
    this.child,
    this.leftBorder = false,
  });

  final String? title;
  final String? body;
  final String? hint = null;
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
    this.canvasOverlays = const [],
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

const double _kSlabWidth = 20; // cm, the optical thickness t
const double _kSlabDepth = 30; // top-view length of the slab
const double _kCLight = 3.00; // speed of light x 10^8 m/s

/// Table 9.3 media: refractive index + the source's hard-coded slab colours.
const List<double> _kMatN = [1.33, 1.44, 1.50, 1.52, 1.65, 2.42];
const List<Color> _kMatColors = [
  Color(0xFFBFDBFE), // Water (blue)
  Color(0xFFFEF3C7), // Kerosene (yellow)
  Color(0xFFF1F5F9), // Benzene (gray)
  Color(0xFFA5F3FC), // Crown Glass (cyan)
  Color(0xFF94A3B8), // Dense Flint (dark)
  Color(0xFFFFFFFF), // Diamond (white)
];

// --- TRANSLATION DATA (the source's i18n block; te: ignored) ---
final _tx = _rt_Tx({
  'en': {
    'title': 'Refraction of Light',
    'sub': 'Class 10 • Light - Reflection and Refraction',
    'intro': {
      'button': 'Enter _rt_Lab',
      'footnote': 'Snell’s Law • Glass Slab • Lateral Shift',
    },
    'power': 'Laser Power',
    'on': 'ON',
    'off': 'OFF',
    'medium': 'Medium (Table 9.3)',
    'refIndex': 'Refractive Index:',
    'angle': 'Angle of Incidence (i)',
    'nudgeMinus': '−5°',
    'nudgePlus': '+5°',
    'r': 'Refraction (r)',
    'e': 'Emergence (e)',
    'd': 'Lat. Shift (d)',
    'n': 'Index (n)',
    'options': 'Options:',
    'normals': 'Normals',
    'incident': 'Incident Path',
    'toggleLabels': 'Toggle Labels',
    'notebook': 'Textbook Calculation',
    'probTitle': 'Textbook Example (9.3)',
    'expand': 'Expand All',
    'collapse': 'Collapse All',
    'laserOff': 'Turn ON the Laser to start.',
    'materials': [
      {'name': 'Water (n=1.33)'},
      {'name': 'Kerosene (n=1.44)'},
      {'name': 'Benzene (n=1.50)'},
      {'name': 'Crown Glass (n=1.52)'},
      {'name': 'Dense Flint Glass (n=1.65)'},
      {'name': 'Diamond (n=2.42)'},
    ],
    'steps': {
      'speed': 'Speed of Light',
      'snell': 'Snell’s Law',
      'shift': 'Lateral Shift',
    },
    'templates': {
      'prob':
          'Light enters from air (n₁ = 1.00) into {mat} (n₂ = {n}) at an angle of incidence i = {i}°. Calculate the speed of light in the medium and the lateral displacement if the slab is {t} cm thick.',
    },
    'tabs': {
      'context': 'Concepts',
      'guide': 'Teacher Guide',
      'explore': 'Mission Log',
      'analysis': 'Outcomes',
    },
    'missionObj': 'Mission Objective',
    'missionDesc':
        'Investigate the laws of refraction and lateral displacement.',
    'mission': 'Mission',
    'missionToast': 'Mission {n} Complete!',
    'missions': [
      'Set Incident Angle > 30°',
      'Verify angle i = angle e (Move slider)',
      'Observe Max Lateral Shift (Diamond)',
    ],
    'context': {
      'why': 'Why Learn This?',
      'whyText':
          'Refraction is the bending of light when it passes from one medium to another. It explains why stars twinkle, why diamonds sparkle, and how lenses work! (Page 141)',
      'examplesTitle': 'Real Life Examples',
      'examples': [
        {
          't': 'Bent Pencil',
          'd': 'A pencil in water looks broken due to light bending.',
        },
        {
          't': 'Twinkling Stars',
          'd': 'Atmospheric refraction makes stars appear to twinkle.',
        },
        {
          't': 'Rainbows',
          'd': 'Refraction and dispersion of sunlight by raindrops.',
        },
      ],
    },
    'guide': {
      'title': 'Teacher’s Guide: Activity 9.10',
      'phases': [
        {
          't': 'Phase 1: Discovery',
          'd':
              'Show the glass slab. Identify the interface between Air and Glass. Discuss optical density.',
        },
        {
          't': 'Phase 2: Interaction',
          'd':
              'Ask students to change the Angle of Incidence (i). Observe how the ray bends towards the normal in glass.',
        },
        {
          't': 'Phase 3: Observation',
          'd':
              'Note that the emergent ray is parallel to the incident ray (i = e), but shifted laterally.',
        },
      ],
    },
    'explore': {
      'objTitle': 'Main Objective',
      'objective':
          '"To trace the path of a ray of light passing through a rectangular glass slab for different angles of incidence."',
      'stepsTitle': 'Steps',
      'steps': [
        'Set the Incident Angle (i) using the slider.',
        'Observe the Refracted Angle (r) inside the slab.',
        'Verify that the Emergent Angle (e) equals i.',
        'Measure the Lateral Shift (d) for different materials.',
      ],
    },
    'analysis': {
      'obsTitle': 'Key Observations',
      'obs': [
        'Light bends towards the normal when entering a denser medium (Air → Glass).',
        'Light bends away from the normal when entering a rarer medium (Glass → Air).',
        'The Emergent ray is parallel to the Incident ray.',
      ],
      'outTitle': 'Learning Outcomes',
      'outText':
          'Students verified Snell’s Law and understood that lateral displacement depends on:',
      'outList': [
        'Thickness of the slab',
        'Angle of incidence',
        'Refractive index of material',
      ],
    },
    'complete': {
      'title': 'Mission Accomplished!',
      'msg':
          'You traced the path of light through a rectangular glass slab: the ray bends towards the normal on entering, away on leaving, and the emergent ray comes out parallel to the incident ray, shifted sideways by the lateral displacement d.',
    },
    'sceneLabels': {'laser': 'Laser', 'normal': 'Normal'},
  },
  'hi': {
    'title': 'प्रकाश का अपवर्तन',
    'sub': 'कक्षा 10 • प्रकाश – परावर्तन तथा अपवर्तन',
    'intro': {
      'button': 'प्रयोगशाला में प्रवेश करें',
      'footnote': 'स्नेल का नियम • कांच की सिल्ली • पार्श्व विस्थापन',
    },
    'power': 'लेज़र पावर',
    'on': 'चालू',
    'off': 'बंद',
    'medium': 'माध्यम (तालिका 9.3)',
    'refIndex': 'अपवर्तनांक:',
    'angle': 'आपतन कोण (i)',
    'nudgeMinus': '−5°',
    'nudgePlus': '+5°',
    'r': 'अपवर्तन (r)',
    'e': 'निर्गत (e)',
    'd': 'पार्श्व विस्थापन (d)',
    'n': 'अपवर्तनांक (n)',
    'options': 'विकल्प:',
    'normals': 'अभिलंब',
    'incident': 'आपतित पथ',
    'toggleLabels': 'लेबल टॉगल करें',
    'notebook': 'पाठ्यपुस्तक गणना',
    'probTitle': 'पाठ्यपुस्तक उदाहरण (9.3)',
    'expand': 'विस्तार करें',
    'collapse': 'संक्षिप्त करें',
    'laserOff': 'शुरू करने के लिए लेज़र चालू करें।',
    'materials': [
      {'name': 'जल (n=1.33)'},
      {'name': 'मिट्टी का तेल (n=1.44)'},
      {'name': 'बेंजीन (n=1.50)'},
      {'name': 'क्राउन काँच (n=1.52)'},
      {'name': 'सघन फ्लिंट काँच (n=1.65)'},
      {'name': 'हीरा (n=2.42)'},
    ],
    'steps': {
      'speed': 'प्रकाश की चाल',
      'snell': 'स्नेल का नियम',
      'shift': 'पार्श्व विस्थापन',
    },
    'templates': {
      'prob':
          'प्रकाश वायु (n₁ = 1.00) से {mat} (n₂ = {n}) में i = {i}° के आपतन कोण पर प्रवेश करता है। माध्यम में प्रकाश की चाल और पार्श्व विस्थापन की गणना करें यदि स्लैब {t} सेमी मोटा है।',
    },
    'tabs': {
      'context': 'अवधारणा',
      'guide': 'शिक्षक गाइड',
      'explore': 'मिशन लॉग',
      'analysis': 'विश्लेषण',
    },
    'missionObj': 'मिशन का उद्देश्य',
    'missionDesc': 'अपवर्तन के नियमों और पार्श्व विस्थापन की जांच करें।',
    'mission': 'मिशन',
    'missionToast': 'मिशन {n} पूरा हुआ!',
    'missions': [
      'आपतन कोण > 30° सेट करें',
      'सत्यापित करें कोण i = कोण e (स्लाइडर ले जाएँ)',
      'अधिकतम पार्श्व विस्थापन देखें (हीरा)',
    ],
    'context': {
      'why': 'यह क्यों सीखें?',
      'whyText':
          'अपवर्तन वह घटना है जिसमें प्रकाश एक माध्यम से दूसरे माध्यम में जाने पर मुड़ जाता है। यह बताता है कि तारे क्यों टिमटिमाते हैं, हीरे क्यों चमकते हैं, और लेंस कैसे काम करते हैं! (पृष्ठ 141)',
      'examplesTitle': 'वास्तविक जीवन के उदाहरण',
      'examples': [
        {
          't': 'मुड़ी हुई पेंसिल',
          'd':
              'पानी में पेंसिल प्रकाश के मुड़ने के कारण टूटी हुई दिखाई देती है।',
        },
        {
          't': 'तारों का टिमटिमाना',
          'd': 'वायुमंडलीय अपवर्तन के कारण तारे टिमटिमाते हुए दिखाई देते हैं।',
        },
        {
          't': 'इंद्रधनुष',
          'd': 'वर्षा की बूंदों द्वारा सूर्य के प्रकाश का अपवर्तन और विक्षेपण।',
        },
      ],
    },
    'guide': {
      'title': 'शिक्षक गाइड: गतिविधि 9.10',
      'phases': [
        {
          't': 'चरण 1: खोज (Discovery)',
          'd':
              'कांच की सिल्ली दिखाएं। वायु और कांच के बीच की सीमा (interface) की पहचान करें।',
        },
        {
          't': 'चरण 2: बातचीत (Interaction)',
          'd':
              'छात्रों से आपतन कोण (i) बदलने को कहें। देखें कि किरण अभिलंब की ओर कैसे झुकती है।',
        },
        {
          't': 'चरण 3: अवलोकन (Observation)',
          'd':
              'नोट करें कि निर्गत किरण आपतित किरण के समानांतर है (i = e), लेकिन पार्श्व रूप से विस्थापित है।',
        },
      ],
    },
    'explore': {
      'objTitle': 'मुख्य उद्देश्य',
      'objective':
          '"विभिन्न आपतन कोणों के लिए आयताकार कांच की सिल्ली से गुजरने वाली प्रकाश की किरण के पथ का पता लगाना।"',
      'stepsTitle': 'चरण',
      'steps': [
        'स्लाइडर का उपयोग करके आपतन कोण (i) सेट करें।',
        'सिल्ली के अंदर अपवर्तन कोण (r) का निरीक्षण करें।',
        'सत्यापित करें कि निर्गत कोण (e) आपतन कोण (i) के बराबर है।',
        'विभिन्न सामग्रियों के लिए पार्श्व विस्थापन (d) मापें।',
      ],
    },
    'analysis': {
      'obsTitle': 'प्रमुख अवलोकन',
      'obs': [
        'सघन माध्यम (वायु → कांच) में प्रवेश करते समय प्रकाश अभिलंब की ओर झुकता है।',
        'विरल माध्यम (कांच → वायु) में प्रवेश करते समय प्रकाश अभिलंब से दूर हटता है।',
        'निर्गत किरण आपतित किरण के समानांतर होती है।',
      ],
      'outTitle': 'सीखने के परिणाम',
      'outText':
          'छात्रों ने स्नेल का नियम सत्यापित किया और समझा कि पार्श्व विस्थापन इन पर निर्भर करता है:',
      'outList': ['सिल्ली की मोटाई', 'आपतन कोण', 'पदार्थ का अपवर्तनांक'],
    },
    'complete': {
      'title': 'मिशन पूरा हुआ!',
      'msg':
          'आपने आयताकार कांच की सिल्ली से प्रकाश का पथ ज्ञात किया: किरण प्रवेश पर अभिलंब की ओर, निकलते समय अभिलंब से दूर मुड़ती है, और निर्गत किरण आपतित किरण के समानांतर, पार्श्व विस्थापन d से खिसकी हुई निकलती है।',
    },
    'sceneLabels': {'laser': 'लेज़र', 'normal': 'अभिलंब'},
  },
});

enum _Section { context, guide, explore, analysis }

class Cl10SCh09A3RefractionLabPage extends StatefulWidget {
  const Cl10SCh09A3RefractionLabPage({super.key});

  @override
  State<Cl10SCh09A3RefractionLabPage> createState() =>
      _Cl10SCh09A3RefractionLabPageState();
}

class _Cl10SCh09A3RefractionLabPageState
    extends State<Cl10SCh09A3RefractionLabPage> {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();

  // --- STATE (source header block) ---
  double _angle = 0; // starts at 0 to avoid auto-completing missions
  int _matIndex = 3; // Crown Glass n = 1.52
  bool _laserOn = true;
  bool _showNormals = true;
  bool _showExtend = true;
  bool _labelsVisible = true;
  _Section _section = _Section.context;
  bool _stepsExpanded = true;
  final Set<int> _openSteps = {0, 1, 2};
  final List<bool> _missions = [false, false, false];
  bool _completed = false;

  // --- PHYSICS (exactly the source's updatePhysics) ---
  double get _n2 => _kMatN[_matIndex];
  double get _radI => _angle * (math.pi / 180);
  double get _radR => math.asin((1.00 * math.sin(_radI)) / _n2);
  double get _rDeg => _radR * (180 / math.pi);
  double get _latShift =>
      (_kSlabWidth * math.sin(_radI - _radR)) / math.cos(_radR);
  double get _speed => _kCLight / _n2;

  String get _matName => _tx.s('materials.$_matIndex.name');
  String get _matPlainName => _matName.split(' (')[0];

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

  // ---------------------------------------------------------- missions ----
  /// The source's checkMissions: fires a toast per newly earned mission and,
  /// once all three are done, a completion popup (the source stops at the
  /// third toast; the popup matches the other converted labs).
  void _checkMissions() {
    if (!_laserOn) return;
    void earn(int idx) {
      if (_missions[idx]) return;
      _missions[idx] = true;
      _rt_playSfx(_rt_Sfx.correct);
      _shell.showToast(_tx.s('missionToast').replaceAll('{n}', '${idx + 1}'));
    }

    if (_angle > 30) earn(0);
    if (_angle > 10 && _angle < 80) earn(1);
    if (_n2 > 2.0 && _angle > 60) earn(2);

    if (!_completed && _missions.every((m) => m)) {
      _completed = true;
      _shell.showSuccess(
        title: _tx.s('complete.title'),
        message: _tx.s('complete.msg'),
      );
    }
  }

  // ---------------------------------------------------------- handlers ----
  void _setAngle(double v) {
    setState(() => _angle = v.clamp(0, 85).roundToDouble());
    _checkMissions();
  }

  void _nudgeAngle(double delta) {
    _rt_playSfx(_rt_Sfx.tap);
    _setAngle(_angle + delta);
  }

  void _togglePower() {
    // Light switched on -> magic; off -> plain toggle.
    _rt_playSfx(_laserOn ? _rt_Sfx.toggle : _rt_Sfx.magic);
    setState(() => _laserOn = !_laserOn);
    _checkMissions();
  }

  void _selectMaterial(int i) {
    if (i == _matIndex) return;
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() => _matIndex = i);
    _checkMissions();
  }

  void _toggleNormals() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showNormals = !_showNormals);
  }

  void _toggleExtend() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showExtend = !_showExtend);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labelsVisible = !_labelsVisible);
  }

  void _setSection(_Section s) {
    if (s == _section) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _section = s);
  }

  void _toggleAllSteps() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _stepsExpanded = !_stepsExpanded;
      _openSteps
        ..clear()
        ..addAll(_stepsExpanded ? [0, 1, 2] : []);
    });
  }

  void _toggleStep(int i) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      if (!_openSteps.remove(i)) _openSteps.add(i);
      _stepsExpanded = _openSteps.length == 3;
    });
  }

  void _restart() {
    // Shell already plays the restart sound.
    _zoom.reset();
    setState(() {
      _angle = 0;
      _matIndex = 3;
      _laserOn = true;
      _showNormals = true;
      _showExtend = true;
      _labelsVisible = true;
      _section = _Section.context;
      _stepsExpanded = true;
      _openSteps
        ..clear()
        ..addAll([0, 1, 2]);
      _missions.fillRange(0, 3, false);
      _completed = false;
    });
  }

  // --------------------------------------------------------------- UI -----
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('sub'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.cyan500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF164E63)],
              headerSubtitleColor: Color(0xFFA5F3FC),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('sub'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.light_mode,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _labelsVisible,
                icon: _labelsVisible ? Icons.label : Icons.label_off,
                tooltip: _tx.s('toggleLabels'),
                onTap: _toggleLabels,
              ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.science,
                builder: (_) => _sidebarBody(),
              ),
            ],
            canvas: LayoutBuilder(
              builder: (context, c) => _rt_ZoomableCanvas(
                controller: _zoom,
                child: SizedBox(
                  width: c.maxWidth,
                  height: c.maxHeight,
                  child: CustomPaint(
                    painter: _RayDiagramPainter(
                      angleDeg: _angle,
                      n2: _n2,
                      matIndex: _matIndex,
                      matName: _matPlainName,
                      laserOn: _laserOn,
                      showNormals: _showNormals,
                      showExtend: _showExtend,
                      showLabels: _labelsVisible,
                      laserLabel: _tx.s('sceneLabels.laser'),
                    ),
                  ),
                ),
              ),
            ),
            canvasOverlays: [
              // n / r / e / d read-outs (the source's data strip).
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _rt_HudCard(
                          value: _n2.toStringAsFixed(2),
                          label: _tx.s('n'),
                          color: _rt_Tw.violet600,
                        ),
                        _rt_HudCard(
                          value: _laserOn
                              ? '${_rDeg.toStringAsFixed(1)}°'
                              : '--',
                          label: _tx.s('r'),
                          color: _rt_Tw.emerald600,
                        ),
                        _rt_HudCard(
                          value: _laserOn
                              ? '${_angle.toStringAsFixed(1)}°'
                              : '--',
                          label: _tx.s('e'),
                          color: _rt_Tw.cyan600,
                        ),
                        _rt_HudCard(
                          value: _laserOn
                              ? '${_latShift.toStringAsFixed(2)} cm'
                              : '--',
                          label: _tx.s('d'),
                          color: _rt_Tw.amber600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom-left ray options (the source's #ray-toolbar).
              Positioned(left: 12, bottom: 12, child: _optionsBar()),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------ canvas overlay ---
  Widget _optionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('options').toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.textFaint,
            ),
          ),
          const SizedBox(width: 8),
          _optionCheck(
            'cb-normals',
            _tx.s('normals'),
            _showNormals,
            _toggleNormals,
          ),
          const SizedBox(width: 8),
          _optionCheck(
            'cb-extend',
            _tx.s('incident'),
            _showExtend,
            _toggleExtend,
          ),
        ],
      ),
    );
  }

  Widget _optionCheck(String key, String label, bool on, VoidCallback onTap) {
    return InkWell(
      key: ValueKey(key),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              on ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: on ? _rt_Tw.cyan500 : _rt_Lab.textFaint,
            ),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _sidebarBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObj'),
          desc: _tx.s('missionDesc'),
          accent: _rt_Tw.cyan500,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _controlsCard(),
              const SizedBox(height: 12),
              _sectionChips(),
              const SizedBox(height: 10),
              switch (_section) {
                _Section.context => _contextSection(),
                _Section.guide => _guideSection(),
                _Section.explore => _exploreSection(),
                _Section.analysis => _analysisSection(),
              },
              const SizedBox(height: 14),
              _notebook(),
            ],
          ),
        ),
      ],
    );
  }

  // The source's top toolbar: power, medium select + n, angle slider.
  Widget _controlsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Power
          Row(
            children: [
              Expanded(
                child: _rt_SectionLabel(
                  _tx.s('power'),
                  icon: Icons.power_settings_new,
                ),
              ),
              Material(
                color: _laserOn ? _rt_Tw.emerald500 : _rt_Tw.red500,
                shape: const StadiumBorder(),
                child: InkWell(
                  key: const ValueKey('power-btn'),
                  customBorder: const StadiumBorder(),
                  onTap: _togglePower,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.power_settings_new,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _laserOn ? _tx.s('on') : _tx.s('off'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Medium (Table 9.3)
          _rt_SectionLabel(_tx.s('medium'), icon: Icons.science_outlined),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _kMatN.length; i++) _materialChip(i),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _tx.s('refIndex'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _n2.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: _rt_Lab.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Angle of incidence (0-85, step 1 like the source slider)
          _rt_LabeledSlider(
            label: _tx.s('angle'),
            value: _angle,
            min: 0,
            max: 85,
            divisions: 85,
            valueText: '${_angle.round()}°',
            color: _rt_Tw.red500,
            onChanged: _laserOn ? _setAngle : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _nudgeButton('angle-minus', _tx.s('nudgeMinus'), -5),
              const SizedBox(width: 10),
              _nudgeButton('angle-plus', _tx.s('nudgePlus'), 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nudgeButton(String key, String label, double delta) {
    final enabled = _laserOn;
    return Material(
      color: enabled
          ? _rt_Lab.overlay
          : _rt_Lab.overlay.withValues(alpha: 0.03),
      shape: StadiumBorder(side: BorderSide(color: _rt_Lab.borderStrong)),
      child: InkWell(
        key: ValueKey(key),
        customBorder: const StadiumBorder(),
        onTap: enabled ? () => _nudgeAngle(delta) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: enabled ? _rt_Lab.text : _rt_Lab.textFaint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _materialChip(int i) {
    final on = i == _matIndex;
    return GestureDetector(
      key: ValueKey('mat-$i'),
      onTap: () => _selectMaterial(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.cyan600 : _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? _rt_Tw.cyan400 : _rt_Lab.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _kMatColors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                _tx.s('materials.$i.name'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: on ? Colors.white : _rt_Lab.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The drawer's four tabs, as chips inside the single shell tab.
  Widget _sectionChips() {
    const icons = {
      _Section.context: Icons.lightbulb_outline,
      _Section.guide: Icons.menu_book,
      _Section.explore: Icons.task_alt,
      _Section.analysis: Icons.insights,
    };
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in _Section.values)
          GestureDetector(
            key: ValueKey('sec-${s.name}'),
            onTap: () => _setSection(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _section == s ? _rt_Tw.sky500 : _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _section == s ? _rt_Tw.sky400 : _rt_Lab.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[s],
                    size: 13,
                    color: _section == s ? Colors.white : _rt_Lab.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _tx.s('tabs.${s.name}'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _section == s ? Colors.white : _rt_Lab.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _contextSection() {
    final examples = _tx.list('context.examples');
    const icons = [Icons.edit, Icons.star, Icons.looks];
    const colors = [_rt_Tw.yellow400, _rt_Tw.blue400, _rt_Tw.purple500];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(_tx.s('context.why'), color: _rt_Tw.cyan500),
        _rt_InfoCard(body: _tx.s('context.whyText'), color: _rt_Tw.cyan500),
        _rt_SectionLabel(_tx.s('context.examplesTitle'), color: _rt_Tw.cyan500),
        for (var i = 0; i < examples.length; i++)
          _rt_InfoCard(
            title: (examples[i] as Map)['t'] as String,
            body: (examples[i] as Map)['d'] as String,
            icon: icons[i],
            color: colors[i],
            leftBorder: true,
          ),
      ],
    );
  }

  Widget _guideSection() {
    final phases = _tx.list('guide.phases');
    const colors = [_rt_Tw.emerald500, _rt_Tw.yellow500, _rt_Tw.blue500];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(_tx.s('guide.title'), color: _rt_Tw.cyan500),
        for (var i = 0; i < phases.length; i++)
          _rt_InfoCard(
            tag: (phases[i] as Map)['t'] as String,
            body: (phases[i] as Map)['d'] as String,
            color: colors[i],
          ),
      ],
    );
  }

  Widget _exploreSection() {
    final missions = _tx.list('missions');
    final steps = _tx.list('explore.steps');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_InfoCard(
          tag: _tx.s('explore.objTitle'),
          body: _tx.s('explore.objective'),
          color: _rt_Tw.cyan500,
        ),
        _rt_SectionLabel(_tx.s('explore.stepsTitle'), color: _rt_Tw.cyan500),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.cyan500,
                  ),
                ),
                Expanded(
                  child: Text(
                    steps[i] as String,
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
        const SizedBox(height: 4),
        for (var i = 0; i < missions.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _missions[i] ? _rt_Tw.green500 : _rt_Lab.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _missions[i]
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: _missions[i] ? _rt_Tw.green500 : _rt_Lab.textFaint,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_tx.s('mission')} ${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _missions[i] ? _rt_Tw.green500 : _rt_Lab.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        missions[i] as String,
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
          ),
      ],
    );
  }

  Widget _analysisSection() {
    final obs = _tx.list('analysis.obs');
    final outList = _tx.list('analysis.outList');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(_tx.s('analysis.obsTitle'), color: _rt_Tw.cyan500),
        for (final o in obs)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.circle, size: 6, color: _rt_Tw.cyan500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    o as String,
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
        const SizedBox(height: 4),
        _rt_SectionLabel(_tx.s('analysis.outTitle'), color: _rt_Tw.cyan500),
        _rt_InfoCard(
          body: _tx.s('analysis.outText'),
          color: _rt_Tw.emerald500,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final o in outList)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '▪  $o',
                      style: TextStyle(
                        fontSize: 11.5,
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

  // ----------------------------------------------------------- notebook ---
  /// The right-hand "Textbook Calculation" panel, at the foot of the sidebar.
  Widget _notebook() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _rt_SectionLabel(
                _tx.s('notebook'),
                icon: Icons.book_outlined,
                color: _rt_Tw.amber500,
              ),
            ),
            Material(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                key: const ValueKey('notes-toggle-all'),
                borderRadius: BorderRadius.circular(6),
                onTap: _toggleAllSteps,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    (_stepsExpanded ? _tx.s('collapse') : _tx.s('expand'))
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: _rt_Lab.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 8),
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
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: _rt_Lab.textFaint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _laserOn ? _probText() : _tx.s('laserOff'),
                style: TextStyle(
                  fontSize: 12,
                  color: _rt_Lab.text,
                  height: 1.4,
                  fontStyle: _laserOn ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (_laserOn) ...[
          _notebookStep(
            0,
            _tx.s('steps.speed'),
            _rt_Tw.cyan500,
            _speedFormula(),
          ),
          _notebookStep(
            1,
            _tx.s('steps.snell'),
            _rt_Tw.emerald500,
            _snellFormula(),
          ),
          _notebookStep(
            2,
            _tx.s('steps.shift'),
            _rt_Tw.yellow500,
            _shiftFormula(),
          ),
        ],
      ],
    );
  }

  String _probText() => _tx
      .s('templates.prob')
      .replaceAll('{mat}', _matPlainName)
      .replaceAll('{n}', _n2.toStringAsFixed(2))
      .replaceAll('{i}', _angle.toStringAsFixed(1))
      .replaceAll('{t}', _kSlabWidth.toStringAsFixed(0));

  String _speedFormula() =>
      'v = c / nₘ = 3×10⁸ / ${_n2.toStringAsFixed(2)}\n'
      '  = ${_speed.toStringAsFixed(2)} × 10⁸ m/s';

  String _snellFormula() =>
      'sin r = sin i / n\n'
      '  = sin ${_angle.toStringAsFixed(1)}° / ${_n2.toStringAsFixed(2)}\n'
      '⇒ r = ${_rDeg.toStringAsFixed(1)}°';

  String _shiftFormula() =>
      'd = t·sin(i − r) / cos r\n'
      '  = ${_latShift.toStringAsFixed(2)} cm';

  Widget _notebookStep(int i, String title, Color color, String body) {
    final open = _openSteps.contains(i);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: ValueKey('step-$i'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggleStep(i),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _rt_Lab.tinted(
                        Color.lerp(color, Colors.white, 0.85)!,
                        color,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _rt_Lab.onTinted(
                          color,
                          Color.lerp(color, Colors.black, 0.3)!,
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
                          color,
                          Color.lerp(color, Colors.black, 0.3)!,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: _rt_Lab.textFaint,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                border: Border(top: BorderSide(color: _rt_Lab.border)),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                body,
                style: TextStyle(
                  fontSize: 11.5,
                  fontFamily: 'monospace',
                  color: _rt_Lab.text,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Round toolbar toggle (labels on/off) matching the shell's buttons.
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

// --------------------------------------------------------------- painter ---
/// Top-view ray diagram: laser, slab, incident / refracted / emergent beams,
/// faded straight-through incident path, dashed normals, lateral-shift marker
/// and scene labels. Physics values match the page's Snell computation; the
/// refracted ray is drawn bending towards the normal (the source's three.js
/// geometry mirrored it to the wrong side of the normal).
class _RayDiagramPainter extends CustomPainter {
  _RayDiagramPainter({
    required this.angleDeg,
    required this.n2,
    required this.matIndex,
    required this.matName,
    required this.laserOn,
    required this.showNormals,
    required this.showExtend,
    required this.showLabels,
    required this.laserLabel,
  });

  final double angleDeg;
  final double n2;
  final int matIndex;
  final String matName;
  final bool laserOn;
  final bool showNormals;
  final bool showExtend;
  final bool showLabels;
  final String laserLabel;

  @override
  void paint(Canvas canvas, Size size) {
    // Dark blue optical-table background (the source's table texture).
    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bg,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF020617)],
        ).createShader(bg),
    );

    // World units: x right (light direction), z up on screen. Slab occupies
    // x in [-10, 10], z in [-15, 15]; the ray hits the left face at z = 0.
    final s = math.min(size.width / 95, size.height / 68);
    // The +8 px drop keeps the laser clear of the HUD row at steep angles.
    Offset pt(double x, double z) =>
        Offset(size.width / 2 + (x + 3) * s, size.height / 2 + 8 - z * s);

    final radI = angleDeg * math.pi / 180;
    final radR = math.asin(math.sin(radI) / n2);

    final hit = pt(-_kSlabWidth / 2, 0);
    // Incident direction on screen: down-right at angle i below horizontal.
    final dir = Offset(math.cos(radI) * s, math.sin(radI) * s) / s;
    final srcW = 25.0; // source distance, world units
    final source = hit - dir * (srcW * s);

    // Slab.
    final slabRect = Rect.fromPoints(
      pt(-_kSlabWidth / 2, _kSlabDepth / 2),
      pt(_kSlabWidth / 2, -_kSlabDepth / 2),
    );
    canvas.drawRect(
      slabRect,
      Paint()
        ..color = _kMatColors[matIndex].withValues(
          alpha: matIndex == 5 ? 0.55 : 0.30,
        ),
    );
    canvas.drawRect(
      slabRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.5),
    );

    // Refraction geometry.
    final distInside = _kSlabWidth / math.cos(radR);
    final refDir = Offset(math.cos(radR), math.sin(radR)); // screen: down-right
    final exit = hit + refDir * (distInside * s);
    final emergentEnd = exit + dir * (28 * s);
    final extEnd = hit + dir * (55 * s);

    if (laserOn) {
      // Faded straight-through incident path.
      if (showExtend) {
        _beam(canvas, hit, extEnd, alpha: 0.28);
      }
      // Incident, refracted, emergent beams.
      _beam(canvas, source, hit);
      _beam(canvas, hit, exit);
      _beam(canvas, exit, emergentEnd);

      // Lateral-shift marker: perpendicular from the emergent ray to the
      // extended incident path (only meaningful once the ray bends).
      if (showExtend && angleDeg >= 5) {
        final p1 = exit + dir * (10 * s);
        final w = p1 - hit;
        final along = w.dx * dir.dx + w.dy * dir.dy;
        final p2 = hit + dir * along;
        _dashedLine(canvas, p1, p2, const Color(0xFFFBBF24), width: 1.4);
        if (showLabels) {
          _angleLabel(canvas, (p1 + p2) / 2 + const Offset(10, 0), 'd');
        }
      }

      // Normals: dashed lines through both interfaces, along the x axis.
      if (showNormals) {
        final white = Colors.white.withValues(alpha: 0.85);
        _dashedLine(
          canvas,
          pt(-_kSlabWidth / 2 - 6, 0),
          pt(-_kSlabWidth / 2 + 6, 0),
          white,
        );
        final exitZ = -(exit.dy - size.height / 2 - 8) / s; // back to world z
        _dashedLine(
          canvas,
          pt(_kSlabWidth / 2 - 6, exitZ),
          pt(_kSlabWidth / 2 + 6, exitZ),
          white,
        );
      }

      // Angle letters i / r / e (amber, like the source's angle labels).
      if (showLabels) {
        _angleLabel(canvas, hit + Offset(-16 * 1, -14), 'i');
        _angleLabel(canvas, hit + const Offset(20, 10), 'r');
        _angleLabel(canvas, exit + const Offset(18, 12), 'e');
      }
    }

    // Laser body: drawn even when the beam is off, aimed at the hit point.
    _drawLaser(canvas, source, dir, s, laserOn);

    // Slab label always visible (the source exempts it from both toggles).
    // Pinned under the slab, clear of the HUD row above it.
    _chipLabel(canvas, pt(0, -_kSlabDepth / 2) + const Offset(0, 14), matName);
    if (showLabels) {
      _chipLabel(canvas, source + Offset(0, -14 - 2 * s), laserLabel);
    }
  }

  void _beam(Canvas canvas, Offset a, Offset b, {double alpha = 0.9}) {
    // Soft glow underneath the core beam.
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = const Color(0xFFFF0000).withValues(alpha: alpha * 0.25)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = const Color(0xFFFF3B30).withValues(alpha: alpha)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color, {
    double width = 1.6,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;
    final total = (b - a).distance;
    if (total < 1e-3) return;
    final step = (b - a) / total;
    const dash = 6.0, gap = 5.0;
    var t = 0.0;
    while (t < total) {
      final end = math.min(t + dash, total);
      canvas.drawLine(a + step * t, a + step * end, paint);
      t = end + gap;
    }
  }

  void _drawLaser(Canvas canvas, Offset source, Offset dir, double s, bool on) {
    final angle = math.atan2(dir.dy, dir.dx);
    canvas.save();
    canvas.translate(source.dx, source.dy);
    canvas.rotate(angle);
    // Body behind the emitting tip.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(-9.5 * s, -1.1 * s, 8 * s, 2.2 * s),
      Radius.circular(0.8 * s),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF334155));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF64748B),
    );
    // Tip cone.
    final tip = Path()
      ..moveTo(-1.5 * s, -1.4 * s)
      ..lineTo(0.6 * s, 0)
      ..lineTo(-1.5 * s, 1.4 * s)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFF94A3B8));
    // Power lamp on the body.
    canvas.drawCircle(
      Offset(-8 * s, 0),
      0.5 * s,
      Paint()..color = on ? const Color(0xFF34D399) : const Color(0xFFEF4444),
    );
    canvas.restore();
  }

  void _chipLabel(Canvas canvas, Offset center, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 12,
        height: tp.height + 6,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xF20F172A));
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF475569),
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _angleLabel(Canvas canvas, Offset center, String letter) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFBBF24),
          shadows: [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_RayDiagramPainter old) =>
      old.angleDeg != angleDeg ||
      old.n2 != n2 ||
      old.matIndex != matIndex ||
      old.matName != matName ||
      old.laserOn != laserOn ||
      old.showNormals != showNormals ||
      old.showExtend != showExtend ||
      old.showLabels != showLabels;
}
