// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 11.1: The Charge Flow Station
// Converted from Cl10S-Ch11-A1-ChargeFlowandCircuits.html (canvas-2D -> CustomPainter).
//
// Three missions on one animated 2D canvas: (1) Loop Builder - a cell, ammeter,
// bulb and plug key in a square circuit; inserting the key closes the loop
// (bulb glows, 1 A flows, yellow arrows march) and cutting/repairing the top
// wire breaks/restores it. (2) Two Rivers - clicking the copper loop zooms into
// the lattice where red arrows (conventional current, + to -) and blue electron
// dots (- to +) stream opposite ways. (3) Electron Counter - a current slider
// (0.5-5 A), a spinning turnstile gate, a charge bucket that fills for exactly
// 1 s, tips onto a digital scale, and counts up to I x 6.242e18 electrons with
// the Q = I x t working shown. A quiz (Q and n for 0.5 A over 2 s) gates the
// final success popup. Fixed vs source: the painted timer was white-on-white
// in the HTML; it is drawn dark here so it is actually visible.

// --- TRANSLATION DATA (the HTML `CONTENT` block; `te:` ignored) -------------

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
  static const teal900 = Color(0xFF134E4A);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red700 = Color(0xFFB91C1C);
  static const orange500 = Color(0xFFF97316);
  static const amber500 = Color(0xFFF59E0B);
  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
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
      _rt_ChoiceState.correct => (
        _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500),
        _rt_Tw.green500,
        _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700),
      ),
      _rt_ChoiceState.wrong => (
        _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500),
        _rt_Tw.red500,
        _rt_Lab.onTinted(_rt_Tw.red400, _rt_Tw.red700),
      ),
      _rt_ChoiceState.selected => (
        _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500),
        _rt_Tw.blue500,
        _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700),
      ),
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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _rt_ChoiceState { idle, selected, correct, wrong }

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
    'title': 'CHARGE FLOW STATION',
    'subtitle': 'Class 10 • Electricity',
    'mainObj':
        'Understand electric current as the flow of charge, switch logic, and electron quantization.',
    'intro': {
      'title': 'Electric Current',
      'subtitle': 'Class 10 • Electricity',
      'button': 'Enter _rt_Lab',
      'footnote': 'Flow • Switch Logic • Quantization',
    },
    'whyTitle': 'Why Learn This?',
    'introText':
        'Electric current is the backbone of modern civilization. Understanding how charge flows allows us to harness energy for everything from lighting our homes to powering complex computers.',
    'do': 'DO',
    'focus': 'FOCUS',
    'ui': {
      'learningOutcomes': 'Learning Outcomes',
      'objective': 'Objective',
      'step': 'Step',
      'clickWire': 'Click the wire loop to Zoom.',
    },
    'tabs': {
      'context': 'WHY LEARN?',
      'guide': 'GUIDE',
      'explore': 'LAB',
      'analysis': 'OUTCOME',
    },
    'controls': {
      'title': 'Controls',
      'insertKey': 'Insert Key',
      'removeKey': 'Remove Key',
      'cutWire': 'Cut Wire',
      'repairWire': 'Repair Wire',
      'startCount': 'Start Count',
      'reset': 'Reset',
      'back': 'Back to Circuit',
      'currentLabel': 'Current (I):',
      'viewInside': 'Zoom Into Wire',
    },
    'obsModal': {
      'title': 'Observation',
      'learned': 'What we learned:',
      'prev': 'Prev',
      'next': 'Next Mission',
      'finish': 'Take Challenge',
    },
    'hud': {
      'guidance': 'Guidance',
      'z1_open': 'Status: Circuit Open. Bulb OFF. Insert Key to close loop.',
      'z1_closed': 'Status: Circuit Closed! Current Flowing (1A). Bulb ON.',
      'z1_broken': 'Status: Wire Broken! Circuit Incomplete. Current = 0.',
      'z2_macro': 'Click anywhere on the Copper Wire loop to see inside.',
      'z2_view':
          'Observe: Red arrows = Conventional Current. Blue dots = Electron Flow.',
      'z3_count': 'Status: Counting Charges...',
    },
    'labels': {
      'cell': 'Cell (1.5V)',
      'bulb': 'Bulb',
      'switch': 'Plug Key',
      'ammeter': 'Ammeter',
      'wire': 'Copper Wire',
      'electrons': 'Electrons (-)',
      'current': 'Conventional Current (+)',
      'gate': 'Turnstile Gate',
      'bucket': 'Charge Bucket',
      'scale': 'Digital Scale',
    },
    'quiz': {
      'question':
          'Challenge: If current is 0.5A for 2 seconds, what is the total charge (Q) and electron count?',
      'options': [
        {'text': '1 C (6 x 10^18 electrons)', 'correct': true},
        {'text': '0.5 C (3 x 10^18 electrons)', 'correct': false},
        {'text': '2 C (1.2 x 10^19 electrons)', 'correct': false},
        {'text': '4 C (2.4 x 10^19 electrons)', 'correct': false},
      ],
      'finish': 'Finish',
      'hint': 'Incorrect. Hint: Q = I × t',
    },
    'missions': [
      {
        'title': 'Step 1: The Loop Builder',
        'do':
            "1. Click 'Insert Key' to close the switch. 2. Click 'Cut Wire' to break the loop.",
        'observe':
            'The bulb only glows when the path is continuous and closed. A break stops everything instantly.',
        'learn':
            'A switch makes a conducting link. A closed loop is necessary for current.',
      },
      {
        'title': 'Step 2: The Two Rivers',
        'do': 'Click on the Copper Wire to zoom in.',
        'observe':
            'Red arrows flow + to -. Blue electrons flow - to +. They move in opposite directions.',
        'learn':
            'Conventionally, current flows + to -. Physically, electrons flow - to +.',
      },
      {
        'title': 'Step 3: The Electron Counter',
        'do': "Set Current to 1A using slider. Click 'Start Count'.",
        'observe':
            '1 Ampere means 1 Coulomb of charge passes per second. The scale weighs the massive count of electrons.',
        'learn':
            '1 Coulomb = 6 x 10^18 electrons. Current is the rate of flow of charge.',
      },
    ],
    'context': [
      {
        'title': 'Powering the World',
        'text':
            'Electric current powers everything from the tiniest LED to massive cities. It is the steady flow of electrons that carries energy through the grid to our homes and devices.',
      },
      {
        'title': 'Safety First',
        'text':
            "Knowing that a 'broken wire' stops current is how we design fuses. A fuse melts and breaks the circuit when current is too high, saving lives and equipment.",
      },
      {
        'title': 'Micro World',
        'text':
            'Inside every wire is a chaotic river of electrons. By controlling this river using components like resistors and transistors, we can perform calculations and transmit information.',
      },
    ],
    'guide': [
      {
        'phase': 'Main Concept',
        'steps': [
          'Electric current is the continuous flow of electrons through a closed circuit. It involves charge (Q) flowing over time (t), defined as I = Q/t.',
        ],
      },
      {
        'phase': 'Step 1: Discovery',
        'steps': [
          "Show the open circuit. Ask: 'Why is the bulb off?'",
          "Close the key. The bulb glows. 'The path is now complete.'",
          'Break the wire. The glow stops instantly.',
        ],
      },
      {
        'phase': 'Step 2: Interaction',
        'steps': [
          'Click the wire to Zoom inside.',
          'Point out the red arrows (Old Idea) vs Blue dots (Real Reality).',
          'Explain that we still draw arrows + to - out of tradition.',
        ],
      },
      {
        'phase': 'Step 3: Observation',
        'steps': [
          "Go to Zone 3. Ask: 'How many electrons are in 1 Ampere?'",
          'Run the counter. Watch the bucket fill.',
          'Show the massive number: 6 Billion Billion electrons!',
        ],
      },
    ],
    'outcomes': [
      {
        'head': '1. Circuit Logic:',
        'body':
            'Students understand that current requires a continuous, closed conducting path.',
      },
      {
        'head': '2. Switch Function:',
        'body':
            'Students can explain how a switch makes or breaks a conducting link.',
      },
      {
        'head': '3. Flow Direction:',
        'body':
            'Students distinguish between conventional current direction (+ to -) and electron flow (- to +).',
      },
      {
        'head': '4. Quantization:',
        'body':
            'Students grasp the magnitude of 1 Ampere (1 Coulomb/sec = 6 x 10^18 electrons).',
      },
    ],
    'calc': {
      'title': 'Calculation',
      'electrons': 'electrons',
      'challenge': 'Challenge: At 0.5A for 2s, Q would also be 1C!',
    },
    'success': {
      'title': '_rt_Lab Complete!',
      'body':
          'You have mastered the concepts of Flow, Current, and Quantization.',
      'restart': 'Restart _rt_Lab',
    },
  },
  'hi': {
    'title': 'चार्ज फ्लो स्टेशन',
    'subtitle': 'कक्षा 10 • विद्युत',
    'mainObj':
        'विद्युत धारा को आवेश के प्रवाह, स्विच लॉजिक और इलेक्ट्रॉन परिमाणीकरण के रूप में समझें।',
    'intro': {
      'title': 'विद्युत धारा',
      'subtitle': 'कक्षा 10 • विद्युत',
      'button': 'प्रयोगशाला में प्रवेश करें',
      'footnote': 'प्रवाह • स्विच लॉजिक • परिमाणीकरण',
    },
    'whyTitle': 'यह क्यों सीखें?',
    'introText':
        'विद्युत धारा आधुनिक सभ्यता की रीढ़ है। आवेश कैसे प्रवाहित होता है, यह समझना हमें अपने घरों को रोशन करने से लेकर जटिल कंप्यूटरों को चलाने तक हर चीज के लिए ऊर्जा का उपयोग करने की अनुमति देता है।',
    'do': 'करें',
    'focus': 'ध्यान दें',
    'ui': {
      'learningOutcomes': 'सीखने के परिणाम',
      'objective': 'उद्देश्य',
      'step': 'चरण',
      'clickWire': 'ज़ूम करने के लिए तार पर क्लिक करें।',
    },
    'tabs': {
      'context': 'क्यों सीखें?',
      'guide': 'गाइड',
      'explore': 'लैब',
      'analysis': 'परिणाम',
    },
    'controls': {
      'title': 'नियंत्रण',
      'insertKey': 'कुंजी डालें (On)',
      'removeKey': 'कुंजी निकालें (Off)',
      'cutWire': 'तार काटें',
      'repairWire': 'तार जोड़ें',
      'startCount': 'गिनती शुरू करें',
      'reset': 'रीसेट',
      'back': 'सर्किट पर वापस',
      'currentLabel': 'विद्युत धारा (I):',
      'viewInside': 'तार के अंदर देखें',
    },
    'obsModal': {
      'title': 'अवलोकन',
      'learned': 'हमने क्या सीखा:',
      'prev': 'पिछला',
      'next': 'अगला मिशन',
      'finish': 'चुनौती लें',
    },
    'hud': {
      'guidance': 'मार्गदर्शन',
      'z1_open':
          'स्थिति: सर्किट खुला। बल्ब बंद। लूप बंद करने के लिए कुंजी डालें।',
      'z1_closed': 'स्थिति: सर्किट बंद! धारा बह रही है (1A)। बल्ब चालू।',
      'z1_broken': 'स्थिति: तार टूटा हुआ! सर्किट अधूरा। धारा = 0।',
      'z2_macro': 'अंदर देखने के लिए कॉपर वायर लूप पर कहीं भी क्लिक करें।',
      'z2_view':
          'देखें: लाल तीर = पारंपरिक धारा। नीले बिंदु = इलेक्ट्रॉन प्रवाह।',
      'z3_count': 'स्थिति: आवेशों की गिनती...',
    },
    'labels': {
      'cell': 'सेल (1.5V)',
      'bulb': 'बल्ब',
      'switch': 'प्लग कुंजी',
      'ammeter': 'एमीटर',
      'wire': 'तांबे का तार',
      'electrons': 'इलेक्ट्रॉन (-)',
      'current': 'पारंपरिक धारा (+)',
      'gate': '1 एम्पीयर गेट',
      'bucket': 'आवेश बाल्टी',
      'scale': 'डिजिटल तराजू',
    },
    'quiz': {
      'question':
          'चुनौती: यदि धारा 2 सेकंड के लिए 0.5A है, तो कुल आवेश (Q) और इलेक्ट्रॉन गणना क्या है?',
      'options': [
        {'text': '1 C (6 x 10^18 इलेक्ट्रॉन)', 'correct': true},
        {'text': '0.5 C (3 x 10^18 इलेक्ट्रॉन)', 'correct': false},
        {'text': '2 C (1.2 x 10^19 इलेक्ट्रॉन)', 'correct': false},
        {'text': '4 C (2.4 x 10^19 इलेक्ट्रॉन)', 'correct': false},
      ],
      'finish': 'समाप्त',
      'hint': 'गलत। संकेत: Q = I × t',
    },
    'missions': [
      {
        'title': 'चरण 1: लूप बिल्डर',
        'do':
            "1. स्विच बंद करने के लिए 'कुंजी डालें' पर क्लिक करें। 2. 'काटने' के लिए तार पर क्लिक करें।",
        'observe':
            'बल्ब तभी चमकता है जब रास्ता निरंतर और बंद होता है। एक रुकावट सब कुछ रोक देती है।',
        'learn':
            'स्विच एक संवाहक कड़ी बनाता है। धारा के लिए एक बंद लूप आवश्यक है।',
      },
      {
        'title': 'चरण 2: दो नदियाँ',
        'do': 'ज़ूम इन करने के लिए कॉपर वायर पर क्लिक करें।',
        'observe':
            'लाल तीर + से - बहते हैं। नीले इलेक्ट्रॉन - से + बहते हैं। वे विपरीत हैं।',
        'learn':
            'परंपरागत रूप से, धारा + से - बहती है। भौतिक रूप से, इलेक्ट्रॉन - से + बहते हैं।',
      },
      {
        'title': 'चरण 3: इलेक्ट्रॉन काउंटर',
        'do':
            "स्लाइडर का उपयोग करके करंट को 1A पर सेट करें। 'गिनती शुरू करें' पर क्लिक करें।",
        'observe':
            '1 एम्पीयर का मतलब है कि प्रति सेकंड 1 कूलॉम आवेश गुजरता है। तराजू इलेक्ट्रॉनों की भारी संख्या को तौलता है।',
        'learn':
            '1 कूलॉम = 6 x 10^18 इलेक्ट्रॉन। धारा आवेश के प्रवाह की दर है।',
      },
    ],
    'context': [
      {
        'title': 'दुनिया को शक्ति देना',
        'text':
            'विद्युत धारा सबसे छोटे एलईडी से लेकर विशाल शहरों तक सब कुछ शक्ति प्रदान करती है। यह इलेक्ट्रॉनों का स्थिर प्रवाह है जो ग्रिड के माध्यम से हमारे घरों और उपकरणों तक ऊर्जा ले जाता है।',
      },
      {
        'title': 'सुरक्षा पहले',
        'text':
            "यह जानना कि 'टूटा हुआ तार' करंट को रोकता है, हम फ़्यूज़ डिज़ाइन करते हैं। जब करंट बहुत अधिक होता है तो फ़्यूज़ पिघल जाता है और सर्किट को तोड़ देता है, जिससे जीवन और उपकरण बच जाते हैं।",
      },
      {
        'title': 'सूक्ष्म दुनिया',
        'text':
            'हर तार के अंदर इलेक्ट्रॉनों की एक अराजक नदी है। प्रतिरोधक और ट्रांजिस्टर जैसे घटकों का उपयोग करके इस नदी को नियंत्रित करके, हम गणना कर सकते हैं और जानकारी प्रसारित कर सकते हैं।',
      },
    ],
    'guide': [
      {
        'phase': 'मुख्य अवधारणा',
        'steps': [
          'विद्युत धारा एक बंद सर्किट के माध्यम से इलेक्ट्रॉनों का निरंतर प्रवाह है। इसमें समय (t) के साथ आवेश (Q) का प्रवाह शामिल है, जिसे I = Q/t के रूप में परिभाषित किया गया है।',
        ],
      },
      {
        'phase': 'चरण 1: खोज',
        'steps': [
          "खुला सर्किट दिखाएं। पूछें: 'बल्ब बंद क्यों है?'",
          "कुंजी बंद करें। बल्ब चमकता है। 'रास्ता अब पूरा हो गया है।'",
          'तार तोड़ो। चमक तुरंत बंद हो जाती है।',
        ],
      },
      {
        'phase': 'चरण 2: इंटरेक्शन',
        'steps': [
          'तार पर क्लिक करके ज़ूम करें (चरण 2)।',
          'लाल तीर (पुराना विचार) बनाम नीले बिंदु (वास्तविक वास्तविकता) को इंगित करें।',
          'समझाएं कि हम अभी भी परंपरा से तीर + से - खींचते हैं।',
        ],
      },
      {
        'phase': 'चरण 3: अवलोकन',
        'steps': [
          "चरण 3 पर जाएं। पूछें: '1 एम्पीयर में कितने इलेक्ट्रॉन होते हैं?'",
          'काउंटर चलाएं। बाल्टी भरते हुए देखें।',
          'विशाल संख्या दिखाएं: 6 बिलियन बिलियन इलेक्ट्रॉन!',
        ],
      },
    ],
    'outcomes': [
      {
        'head': '1. सर्किट लॉजिक:',
        'body':
            'छात्र समझते हैं कि धारा के लिए निरंतर, बंद संवाहक पथ की आवश्यकता होती है।',
      },
      {
        'head': '2. स्विच फ़ंक्शन:',
        'body':
            'छात्र समझा सकते हैं कि स्विच कैसे संवाहक लिंक बनाता या तोड़ता है।',
      },
      {
        'head': '3. प्रवाह दिशा:',
        'body':
            'छात्र पारंपरिक धारा दिशा (+ से -) और इलेक्ट्रॉन प्रवाह (- से +) के बीच अंतर करते हैं।',
      },
      {
        'head': '4. परिमाणीकरण:',
        'body':
            'छात्र 1 एम्पीयर (1 कूलॉम/सेकंड = 6 x 10^18 इलेक्ट्रॉन) के परिमाण को समझते हैं।',
      },
    ],
    'calc': {
      'title': 'गणना',
      'electrons': 'इलेक्ट्रॉन',
      'challenge': 'चुनौती: 0.5A पर 2 सेकंड में भी Q = 1C ही होगा!',
    },
    'success': {
      'title': 'लैब पूर्ण!',
      'body':
          'आपने प्रवाह, धारा और परिमाणीकरण की अवधारणाओं में महारत हासिल कर ली है।',
      'restart': 'लैब पुनः आरंभ करें',
    },
  },
});

/// Zone-3 counter phases (the HTML `z3.phase`).
enum _Z3Phase { idle, counting, dumping, scaling, complete }

/// One charge particle in zone 3 (coordinates relative to the gate centre).
class _Charge {
  _Charge(this.x, this.y, this.vx);
  double x, y, vx;
  double vy = 0;
}

class Cl10SCh11A1ChargeFlowandCircuitsPage extends StatefulWidget {
  const Cl10SCh11A1ChargeFlowandCircuitsPage({super.key});

  @override
  State<Cl10SCh11A1ChargeFlowandCircuitsPage> createState() =>
      _Cl10SCh11A1ChargeFlowandCircuitsPageState();
}

class _Cl10SCh11A1ChargeFlowandCircuitsPageState
    extends State<Cl10SCh11A1ChargeFlowandCircuitsPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();
  final ScrollController _deckScroll = ScrollController();

  // --- mission flow (currentMissionId / missionStatus / activeStepSuccess) ---
  int _mission = 0;
  final List<bool> _done = [false, false, false];
  bool _activeStepDone = false;
  Timer? _checkTimer; // the HTML setInterval(500)
  Timer? _z2Timer; // the 2.5 s zoom -> mission-complete delay

  // --- zone 1 state ---
  bool _keyIn = false;
  bool _wireBroken = false;
  double _flowOffset = 0;

  // --- zone 2 state ---
  bool _z2Zoomed = false;
  double _z2Level = 0;
  double _z2Off1 = 0;
  double _z2Off2 = 0;

  // --- zone 3 state ---
  double _current = 1.0;
  _Z3Phase _phase = _Z3Phase.idle;
  double _time = 1.0;
  final List<_Charge> _charges = [];
  double _electrons = 0;
  double _dumpAngle = 0;
  double _shake = 0;
  final math.Random _rng = math.Random();

  // --- view state ---
  bool _showLabels = true;
  double _clock = 0; // seconds since start (pulse / gate spin / shake)
  double _stepAcc = 0; // fixed 60 fps sub-stepping accumulator
  final ValueNotifier<int> _repaint = ValueNotifier(0);
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  // --- observation popup / quiz ---
  bool _obsVisible = false;
  int _obsMission = 0;
  bool _quizMode = false;
  late List<Map<String, dynamic>> _quizOptions = [];
  int? _quizWrong;
  bool _quizCorrect = false;
  bool _quizLocked = false;
  Timer? _quizTimer;

  bool get _isClosed => _keyIn && !_wireBroken;
  List<dynamic> get _missions => _tx.list('missions');

  // ----------------------------------------------------------- lifecycle ---
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker.start();
    // The HTML check loop: m1 completes while closed, m3 when counting ends.
    _checkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      if (_mission == 0 && !_activeStepDone && _isClosed) _completeMission(0);
      if (_mission == 2 && !_activeStepDone && _phase == _Z3Phase.complete) {
        _completeMission(2);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _checkTimer?.cancel();
    _z2Timer?.cancel();
    _quizTimer?.cancel();
    _zoom.dispose();
    _deckScroll.dispose();
    _repaint.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- animation ---
  void _onTick(Duration elapsed) {
    var dt = _lastTick == Duration.zero
        ? 1 / 60.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    dt = dt.clamp(0.0, 0.25);
    _clock += dt;

    // Run the source's per-frame maths in fixed 60 fps steps so speeds match.
    _stepAcc += dt;
    var steps = 0;
    while (_stepAcc >= 1 / 60 && steps < 30) {
      _stepAcc -= 1 / 60;
      steps++;
      _stepFrame();
    }
    _repaint.value++;
  }

  /// One 60 fps frame, exactly as the HTML `loop()` maths.
  void _stepFrame() {
    // Zone 1: marching arrows.
    if (_isClosed) _flowOffset = (_flowOffset + 2) % 20;

    // Zone 2: zoom transition + the two rivers.
    if (_z2Zoomed) {
      if (_z2Level < 1) _z2Level = math.min(1, _z2Level + 0.05);
    } else if (_z2Level > 0) {
      _z2Level = math.max(0, _z2Level - 0.05);
    }
    _z2Off1 += 2;
    _z2Off2 -= 1;

    // Zone 3 phases.
    if (_phase == _Z3Phase.counting) {
      _time -= 0.016;
      if (_time <= 0) {
        _time = 0;
        _phase = _Z3Phase.dumping;
        _rt_playSfx(_rt_Sfx.pop); // bucket tips over
      }
      // Spawn current*2 charges per frame (capped well below the HTML's).
      for (
        var i = 0;
        i < (_current * 2).round() && _charges.length < 240;
        i++
      ) {
        _charges.add(
          _Charge(
            -350,
            (_rng.nextDouble() - 0.5) * 20,
            5 + _rng.nextDouble() * 5,
          ),
        );
      }
    }
    if (_phase == _Z3Phase.dumping) {
      _dumpAngle += 0.05;
      if (_dumpAngle > math.pi / 2) {
        _dumpAngle = math.pi / 2;
        _phase = _Z3Phase.scaling;
      }
    }
    if (_phase == _Z3Phase.scaling) {
      _shake = math.sin(_clock * 20) * 2;
      _electrons += 0.5e18;
      final target = _current * 1.0 * 6.242e18;
      if (_electrons >= target) {
        _electrons = target;
        _phase = _Z3Phase.complete;
        _shake = 0;
        _rt_playSfx(_rt_Sfx.magic); // the huge number is revealed
        if (mounted) setState(() {}); // shows the calculation card
      }
    }

    // Particle motion (coordinates relative to the gate).
    for (final p in _charges) {
      if (_phase == _Z3Phase.counting) {
        p.x += p.vx;
        if (p.x > 0) {
          p.vx = 2;
          p.vy += 0.5;
          p.y += p.vy;
          if (p.x > 80) p.vx = 0;
          if (p.y > 90) {
            p.y = 90;
            p.vy = 0;
          }
        }
      } else if (_phase != _Z3Phase.idle) {
        if (p.x > 0) {
          p.x += 4;
          p.y += 8;
          // Land on the scale pan (scale at 200, 150).
          if (p.y > 145 && p.x > 150 && p.x < 250) {
            p.y = 145 - _rng.nextDouble() * 10;
            p.x = 200 + (_rng.nextDouble() - 0.5) * 80;
          }
        }
      }
    }
  }

  // -------------------------------------------------------------- actions ---
  void _setMission(int i, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    _z2Timer?.cancel();
    if (_deckScroll.hasClients) _deckScroll.jumpTo(0);
    setState(() {
      _mission = i;
      _activeStepDone = false;
      _obsVisible = false;
      _quizMode = false;
      if (i == 1) {
        _z2Zoomed = false;
        _z2Level = 0;
        _zoom.reset();
      }
    });
  }

  void _toggleKey() {
    _rt_playSfx(_rt_Sfx.toggle); // plug key in / out
    final wasClosed = _isClosed;
    setState(() => _keyIn = !_keyIn);
    if (!wasClosed && _isClosed) _rt_playSfx(_rt_Sfx.magic); // bulb lights up
  }

  void _toggleWire() {
    // Cutting kills the current (buzz); repairing snaps it back (pop).
    final wasClosed = _isClosed;
    _rt_playSfx(_wireBroken ? _rt_Sfx.pop : _rt_Sfx.wrong);
    setState(() => _wireBroken = !_wireBroken);
    if (!wasClosed && _isClosed) _rt_playSfx(_rt_Sfx.magic);
  }

  void _zoomInside() {
    if (_z2Zoomed) return;
    _rt_playSfx(_rt_Sfx.magic); // dive into the lattice
    setState(() => _z2Zoomed = true);
    _z2Timer?.cancel();
    _z2Timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _mission == 1) _completeMission(1);
    });
  }

  void _backToCircuit() {
    _z2Timer?.cancel();
    setState(() => _z2Zoomed = false);
  }

  void _startCount() {
    _rt_playSfx(_rt_Sfx.scenario); // the stopwatch run begins
    setState(() {
      _phase = _Z3Phase.counting;
      _time = 1.0;
      _charges.clear();
      _dumpAngle = 0;
      _electrons = 0;
    });
  }

  void _resetCounter() {
    setState(() {
      _phase = _Z3Phase.idle;
      _time = 1.0;
      _charges.clear();
      _dumpAngle = 0;
      _electrons = 0;
      _activeStepDone = false;
    });
  }

  void _completeMission(int i) {
    if (_activeStepDone) return;
    _activeStepDone = true;
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _done[i] = true;
      _obsVisible = true;
      _obsMission = i;
      _quizMode = false;
      _quizCorrect = false;
      _quizWrong = null;
      _quizLocked = false;
    });
  }

  void _closeObservation() {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _obsVisible = false);
  }

  void _nextMission() {
    if (_obsMission == 2) {
      // "Take Challenge" -> quiz inside the same panel.
      setState(() {
        _quizMode = true;
        _quizOptions = [
          for (final o in _tx.list('quiz.options'))
            (o as Map).cast<String, dynamic>(),
        ]..shuffle(_rng);
      });
      return;
    }
    setState(() => _obsVisible = false);
    _setMission(_obsMission + 1);
  }

  void _prevMission() {
    setState(() => _obsVisible = false);
    if (_obsMission > 0) _setMission(_obsMission - 1);
  }

  void _answerQuiz(int index) {
    if (_quizLocked || _quizCorrect) return;
    final correct = _quizOptions[index]['correct'] == true;
    if (correct) {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _quizCorrect = true);
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() {
        _quizWrong = index;
        _quizLocked = true;
      });
      _shell.showToast(
        _tx.s('quiz.hint'),
        color: _rt_Tw.red500,
        icon: Icons.close,
      );
      _quizTimer?.cancel();
      _quizTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _quizWrong = null;
            _quizLocked = false;
          });
        }
      });
    }
  }

  void _finishLab() {
    setState(() => _obsVisible = false);
    _shell.showSuccess(
      title: _tx.s('success.title'),
      message: _tx.s('success.body'),
      buttonLabel: _tx.s('success.restart'),
      icon: Icons.emoji_events,
      onClose: _restart,
    );
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  void _restart() {
    // The shell already plays the restart sound.
    _z2Timer?.cancel();
    _quizTimer?.cancel();
    _zoom.reset();
    if (_deckScroll.hasClients) _deckScroll.jumpTo(0);
    setState(() {
      _mission = 0;
      _activeStepDone = false;
      for (var i = 0; i < 3; i++) {
        _done[i] = false;
      }
      _keyIn = false;
      _wireBroken = false;
      _flowOffset = 0;
      _z2Zoomed = false;
      _z2Level = 0;
      _z2Off1 = 0;
      _z2Off2 = 0;
      _current = 1.0;
      _phase = _Z3Phase.idle;
      _time = 1.0;
      _charges.clear();
      _electrons = 0;
      _dumpAngle = 0;
      _shake = 0;
      _showLabels = true;
      _obsVisible = false;
      _quizMode = false;
      _quizCorrect = false;
      _quizWrong = null;
      _quizLocked = false;
    });
  }

  /// Taps forwarded from the sim canvas (break/repair the wire, zoom in).
  void _onCanvasTap(Offset local, Size size) {
    if (_mission == 0) {
      final s = math.min(size.width / 720, size.height / 470);
      final lx = (local.dx - size.width / 2) / s;
      final ly = (local.dy - size.height / 2) / s;
      if ((ly + 150).abs() < 25 && lx > 40 && lx < 200) {
        _rt_playSfx(_rt_Sfx.tap);
        _toggleWire();
      }
    } else if (_mission == 1 && !_z2Zoomed) {
      final d = math.max(
        (local.dx - size.width / 2).abs(),
        (local.dy - size.height / 2).abs(),
      );
      if (d < 250) _zoomInside();
    }
  }

  /// "1" for 1.0, "0.5" for 0.5 (matches the JS number formatting).
  static String _fmtI(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  // ------------------------------------------------------------------ UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final next = _done.indexWhere((d) => !d);
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
              icon: Icons.bolt,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: () {
              _zoom.reset();
              if (_mission == 1 && _z2Zoomed) _backToCircuit();
            },
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: _showLabels ? Icons.visibility : Icons.visibility_off,
                onTap: _toggleLabels,
              ),
            ],
            hint: next == -1
                ? null
                : _rt_StepHint(
                    number: '${next + 1}',
                    text: (_missions[next] as Map)['do'] as String,
                    label: (_missions[next] as Map)['title'] as String,
                  ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.science,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _rt_MinWidthGate(child: _canvasBody()), // QA C10-11.1-16
            canvasOverlays: [
              if (_obsVisible)
                Positioned(left: 12, bottom: 12, child: _observationPanel()),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------ canvas + panels ---
  Widget _canvasBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The guidance HUD stays pinned while the deck below scrolls.
        Padding(
          padding: const EdgeInsets.fromLTRB(64, 10, 56, 0),
          child: _hudBanner(),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              // Control deck beside the canvas on wide screens (the HTML has
              // it floating on the right); stacked below on narrow ones.
              final wide = c.maxWidth > 520;
              final sim = SizedBox(
                height: math.max(240, c.maxHeight - (wide ? 86 : 190)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _rt_ZoomableCanvas(
                    controller: _zoom,
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final size = Size(box.maxWidth, box.maxHeight);
                        return GestureDetector(
                          key: const ValueKey('sim-canvas'),
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (d) => _onCanvasTap(d.localPosition, size),
                          child: CustomPaint(
                            size: size,
                            painter: _StationPainter(this, _repaint),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
              final side = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _controlDeck(),
                  if (_mission == 2 && _phase == _Z3Phase.complete) ...[
                    const SizedBox(height: 8),
                    _calcCard(),
                  ],
                ],
              );
              return SingleChildScrollView(
                controller: _deckScroll,
                padding: const EdgeInsets.fromLTRB(12, 8, 56, 70),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: sim),
                          const SizedBox(width: 8),
                          SizedBox(width: 230, child: side),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [sim, const SizedBox(height: 8), side],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Top guidance banner (the HTML `#hud-message-container`).
  Widget _hudBanner() {
    String text;
    Color edge = _rt_Tw.cyan500;
    switch (_mission) {
      case 0:
        if (_wireBroken) {
          text = _tx.s('hud.z1_broken');
          edge = _rt_Tw.red500;
        } else if (_keyIn) {
          text = _tx.s('hud.z1_closed');
          edge = _rt_Tw.green500;
        } else {
          text = _tx.s('hud.z1_open');
        }
      case 1:
        text = _z2Zoomed ? _tx.s('hud.z2_view') : _tx.s('hud.z2_macro');
      default:
        text = _tx.s('hud.z3_count');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: edge, width: 3)),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _rt_Lab.tinted(const Color(0xFFCFFAFE), _rt_Tw.cyan500),
              border: Border.all(color: _rt_Tw.cyan500),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: _rt_Tw.cyan500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('hud.guidance').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: _rt_Tw.cyan500,
                  ),
                ),
                Text(
                  text,
                  key: const ValueKey('hud-text'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Right-hand control deck of the HTML, laid below the sim canvas.
  Widget _controlDeck() {
    final children = <Widget>[];
    switch (_mission) {
      case 0:
        children.addAll([
          _rt_ActionButton(
            key: const ValueKey('btn-key'),
            label: _tx.s(_keyIn ? 'controls.removeKey' : 'controls.insertKey'),
            icon: Icons.power_settings_new,
            color: _keyIn ? _rt_Tw.red500 : _rt_Tw.green600,
            sound: null, // _toggleKey plays the switch sound itself
            onPressed: _toggleKey,
          ),
          _rt_ActionButton(
            key: const ValueKey('btn-wire'),
            label: _tx.s(
              _wireBroken ? 'controls.repairWire' : 'controls.cutWire',
            ),
            icon: Icons.content_cut,
            color: _wireBroken ? _rt_Tw.blue600 : _rt_Tw.slate600,
            sound: null, // _toggleWire plays cut / repair sounds
            onPressed: _toggleWire,
          ),
        ]);
      case 1:
        if (!_z2Zoomed) {
          children.addAll([
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _rt_Lab.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.remove_red_eye,
                    size: 16,
                    color: _rt_Tw.cyan500,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _tx.s('ui.clickWire'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _rt_Lab.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _rt_ActionButton(
              key: const ValueKey('btn-inside'),
              label: _tx.s('controls.viewInside'),
              icon: Icons.zoom_in,
              color: _rt_Tw.cyan600,
              sound: null, // _zoomInside plays the reveal sound
              onPressed: _zoomInside,
            ),
          ]);
        } else {
          children.add(
            _rt_ActionButton(
              key: const ValueKey('btn-back'),
              label: _tx.s('controls.back'),
              icon: Icons.arrow_back,
              color: _rt_Tw.slate600,
              onPressed: _backToCircuit,
            ),
          );
        }
      default:
        children.addAll([
          SizedBox(
            width: 190,
            child: _rt_LabeledSlider(
              label: _tx.s('controls.currentLabel'),
              value: _current,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              valueText: '${_fmtI(_current)} A',
              color: _rt_Tw.cyan600,
              onChanged: _phase == _Z3Phase.idle || _phase == _Z3Phase.complete
                  ? (v) => setState(() => _current = (v * 2).round() / 2)
                  : null,
            ),
          ),
          _rt_ActionButton(
            key: const ValueKey('btn-count'),
            label: _tx.s('controls.startCount'),
            icon: Icons.timer,
            color: _rt_Tw.cyan600,
            sound: null, // _startCount plays the run sound
            onPressed: _phase == _Z3Phase.counting ? null : _startCount,
          ),
          _rt_ActionButton(
            key: const ValueKey('btn-reset3'),
            label: _tx.s('controls.reset'),
            icon: Icons.rotate_left,
            color: _rt_Tw.slate600,
            onPressed: _resetCounter,
          ),
        ]);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 14, color: _rt_Tw.cyan500),
              const SizedBox(width: 6),
              Text(
                _tx.s('controls.title').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: _rt_Lab.textMuted,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _rt_Tw.green500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }

  /// Zone-3 result card (the HTML `#stats-panel` formula block).
  Widget _calcCard() {
    final i = _fmtI(_current);
    final n = (_current * 6.242).toStringAsFixed(2);
    TextStyle mono(
      Color c, [
      double s = 12.5,
      FontWeight w = FontWeight.w700,
    ]) => TextStyle(
      fontFamily: 'monospace',
      fontSize: s,
      fontWeight: w,
      color: c,
    );
    return Container(
      key: const ValueKey('calc-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Tw.green500, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('calc.title').toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: _rt_Lab.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text('Q = I × t = $i × 1 = $i C', style: mono(_rt_Lab.text)),
          const SizedBox(height: 4),
          Text('n = Q / e = $i / 1.6×10⁻¹⁹', style: mono(_rt_Lab.text)),
          const SizedBox(height: 4),
          Text(
            'n = $n × 10¹⁸ ${_tx.s('calc.electrons')}',
            style: mono(_rt_Tw.cyan500, 16, FontWeight.w900),
          ),
          if (_current == 0.5) ...[
            const SizedBox(height: 6),
            Divider(height: 1, color: _rt_Lab.border),
            const SizedBox(height: 6),
            Text(
              _tx.s('calc.challenge'),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _rt_Tw.amber500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Observation / quiz panel (the HTML `#obs-modal`, bottom-left overlay).
  Widget _observationPanel() {
    final m = _missions[_obsMission] as Map;
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 330),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: _rt_Lab.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.fact_check, size: 16, color: _rt_Tw.cyan400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tx.s('obsModal.title').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('obs-close'),
                  icon: const Icon(Icons.close, size: 18),
                  color: _rt_Lab.textMuted,
                  visualDensity: VisualDensity.compact,
                  onPressed: _closeObservation,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _quizMode ? _quizBody() : _obsBody(m),
            ),
          ),
        ],
      ),
    );
  }

  Widget _obsBody(Map m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          m['observe'] as String,
          style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.35),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(const Color(0xFFECFEFF), _rt_Tw.cyan600),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.cyan600)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tx.s('obsModal.learned').toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: _rt_Tw.cyan500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m['learn'] as String,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.onTinted(_rt_Tw.cyan400, _rt_Tw.cyan600),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton.icon(
              key: const ValueKey('obs-prev'),
              onPressed: _obsMission == 0 ? null : _prevMission,
              icon: const Icon(Icons.chevron_left, size: 16),
              label: Text(
                _tx.s('obsModal.prev'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: _rt_Lab.textMuted),
            ),
            const Spacer(),
            _rt_ActionButton(
              key: const ValueKey('obs-next'),
              label: _tx.s(
                _obsMission == 2 ? 'obsModal.finish' : 'obsModal.next',
              ),
              icon: _obsMission == 2 ? Icons.quiz : Icons.arrow_forward,
              color: _rt_Tw.cyan600,
              onPressed: _nextMission,
            ),
          ],
        ),
      ],
    );
  }

  Widget _quizBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tx.s('quiz.question'),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.text,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < _quizOptions.length; i++)
          _rt_ChoiceButton(
            key: ValueKey('quiz-$i'),
            label: _quizOptions[i]['text'] as String,
            state: _quizCorrect && _quizOptions[i]['correct'] == true
                ? _rt_ChoiceState.correct
                : (_quizWrong == i
                      ? _rt_ChoiceState.wrong
                      : _rt_ChoiceState.idle),
            onTap: _quizLocked || _quizCorrect ? null : () => _answerQuiz(i),
          ),
        if (_quizCorrect) ...[
          const SizedBox(height: 6),
          Center(
            child: _rt_ActionButton(
              key: const ValueKey('quiz-finish'),
              label: _tx.s('quiz.finish'),
              icon: Icons.check,
              color: _rt_Tw.green600,
              onPressed: _finishLab,
            ),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('ui.objective'),
          desc: _tx.s('mainObj'),
          accent: _rt_Tw.cyan600,
          icon: Icons.electric_bolt,
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < _missions.length; i++) _missionCard(i),
        const SizedBox(height: 10),
        _rt_SectionLabel(
          _tx.s('tabs.context'),
          icon: Icons.lightbulb_outline,
          color: _rt_Tw.amber500,
        ),
        _rt_InfoCard(
          title: _tx.s('whyTitle'),
          body: _tx.s('introText'),
          color: _rt_Tw.cyan600,
          icon: Icons.help_outline,
        ),
        for (final c in _tx.list('context'))
          _rt_InfoCard(
            title: (c as Map)['title'] as String,
            body: c['body'] as String? ?? c['text'] as String,
            color: _rt_Tw.blue600,
            icon: Icons.bolt,
            leftBorder: true,
          ),
        const SizedBox(height: 6),
        _rt_SectionLabel(
          _tx.s('tabs.guide'),
          icon: Icons.school,
          color: _rt_Tw.cyan500,
        ),
        for (final g in _tx.list('guide'))
          _rt_InfoCard(
            title: (g as Map)['phase'] as String,
            color: _rt_Tw.cyan600,
            leftBorder: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                for (final s in (g['steps'] as List))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: _rt_Tw.cyan600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _rt_Lab.textMuted,
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
        const SizedBox(height: 6),
        _rt_SectionLabel(
          _tx.s('ui.learningOutcomes'),
          icon: Icons.emoji_events,
          color: _rt_Tw.green500,
        ),
        _rt_InfoCard(
          color: _rt_Tw.green600,
          leftBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final o in _tx.list('outcomes'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 14, color: _rt_Tw.green500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${(o as Map)['head']} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _rt_Lab.text,
                                ),
                              ),
                              TextSpan(text: o['body'] as String),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _rt_Lab.textMuted,
                            height: 1.4,
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

  Widget _missionCard(int i) {
    final m = _missions[i] as Map;
    final active = _mission == i;
    final complete = _done[i];
    return GestureDetector(
      key: ValueKey('mission-$i'),
      onTap: () => _setMission(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? _rt_Lab.tinted(const Color(0xFFECFEFF), _rt_Tw.cyan500)
              : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _rt_Tw.cyan500 : _rt_Lab.border,
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
                    m['title'] as String,
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
                    color: complete ? _rt_Tw.green500 : Colors.transparent,
                    border: Border.all(
                      color: complete ? _rt_Tw.green500 : _rt_Lab.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: complete
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: _rt_Tw.cyan500, width: 2),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_tx.s('do')}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _rt_Tw.cyan500,
                        fontSize: 9,
                      ),
                    ),
                    TextSpan(text: m['do'] as String),
                  ],
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: _rt_Lab.textMuted,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: _rt_Tw.orange500, width: 2),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_tx.s('focus')}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _rt_Tw.orange500,
                        fontSize: 9,
                      ),
                    ),
                    TextSpan(text: m['observe'] as String),
                  ],
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: _rt_Lab.textMuted,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- painter ---
/// Draws the active zone exactly like the HTML `renderZone1/2/3` canvas code.
class _StationPainter extends CustomPainter {
  _StationPainter(this.s, Listenable repaint) : super(repaint: repaint);

  final _Cl10SCh11A1ChargeFlowandCircuitsPageState s;

  @override
  void paint(Canvas canvas, Size size) {
    // White graph-paper background (the HTML #sim-canvas).
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final grid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    switch (s._mission) {
      case 0:
        _zone1(canvas, size);
      case 1:
        _zone2(canvas, size);
      default:
        _zone3(canvas, size);
    }
  }

  // ------------------------------------------------------------- helpers ---
  void _text(
    Canvas canvas,
    String str,
    Offset at,
    double fontSize,
    Color color, {
    FontWeight weight = FontWeight.w700,
    TextAlign align = TextAlign.center,
    String? family,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: str,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: weight,
          fontFamily: family,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      TextAlign.left => at.dx,
      TextAlign.right => at.dx - tp.width,
      _ => at.dx - tp.width / 2,
    };
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  /// Dark pill label (the HTML `drawLabel`); obeys the labels toggle.
  void _label(Canvas canvas, String key, Offset at) {
    if (!s._showLabels) return;
    final text = _tx.s('labels.$key');
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + 12;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: at, width: w, height: 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xCC0F172A));
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  // -------------------------------------------------------------- zone 1 ---
  void _zone1(Canvas canvas, Size size) {
    final scale = math.min(size.width / 720, size.height / 470);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);

    final isClosed = s._isClosed;

    // Board.
    canvas.drawRect(
      const Rect.fromLTWH(-300, -200, 600, 400),
      Paint()..color = const Color(0xFFCBD5E1),
    );

    _drawCell(canvas, const Offset(-200, 0));
    _label(canvas, 'cell', const Offset(-200, 60));
    _drawAmmeter(canvas, const Offset(0, -150), isClosed ? 1.0 : 0.0);
    _label(canvas, 'ammeter', const Offset(0, -200));
    _drawBulb(canvas, const Offset(200, 0), isClosed);
    _label(canvas, 'bulb', const Offset(200, 60));
    _drawSwitch(canvas, const Offset(0, 150), s._keyIn);
    _label(canvas, 'switch', const Offset(0, 190));

    final wirePaint = Paint()
      ..color = const Color(0xFFB45309)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const wires = [
      (Offset(-200, -40), Offset(-200, -150)),
      (Offset(-200, -150), Offset(-40, -150)),
      (Offset(200, 40), Offset(200, 150)),
      (Offset(200, 150), Offset(40, 150)),
      (Offset(-40, 150), Offset(-200, 150)),
      (Offset(-200, 150), Offset(-200, 40)),
    ];
    for (final (a, b) in wires) {
      canvas.drawLine(a, b, wirePaint);
      if (isClosed) _drawCurrentFlow(canvas, a, b);
    }

    if (!s._wireBroken) {
      canvas.drawLine(
        const Offset(40, -150),
        const Offset(200, -150),
        wirePaint,
      );
      canvas.drawLine(
        const Offset(200, -150),
        const Offset(200, -40),
        wirePaint,
      );
      if (isClosed) {
        _drawCurrentFlow(
          canvas,
          const Offset(40, -150),
          const Offset(200, -150),
        );
        _drawCurrentFlow(
          canvas,
          const Offset(200, -150),
          const Offset(200, -40),
        );
      }
    } else {
      canvas.drawLine(
        const Offset(40, -150),
        const Offset(100, -150),
        wirePaint,
      );
      canvas.drawLine(
        const Offset(140, -150),
        const Offset(200, -150),
        wirePaint,
      );
      canvas.drawLine(
        const Offset(200, -150),
        const Offset(200, -40),
        wirePaint,
      );
      _label(canvas, 'wire', const Offset(120, -120));
    }
    canvas.restore();
  }

  void _drawCurrentFlow(Canvas canvas, Offset a, Offset b) {
    final dist = (b - a).distance;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    canvas.save();
    canvas.translate(a.dx, a.dy);
    canvas.rotate(angle);
    final p = Paint()..color = const Color(0xFFFACC15);
    for (var i = s._flowOffset; i < dist; i += 20) {
      final path = Path()
        ..moveTo(i, 0)
        ..lineTo(i - 5, -3)
        ..lineTo(i - 5, 3)
        ..close();
      canvas.drawPath(path, p);
    }
    canvas.restore();
  }

  void _drawCell(Canvas canvas, Offset at) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    final body = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF1E293B),
          Color(0xFF475569),
          Color(0xFF1E293B),
          Color(0xFF0F172A),
        ],
        stops: [0, 0.2, 0.5, 1],
      ).createShader(const Rect.fromLTWH(-30, -35, 60, 70));
    canvas.drawRect(const Rect.fromLTWH(-30, -35, 60, 70), body);
    canvas.drawOval(
      const Rect.fromLTWH(-30, -45, 60, 20),
      Paint()..color = const Color(0xFF94A3B8),
    );
    // Positive nub.
    canvas.drawRect(
      const Rect.fromLTWH(-10, -46, 20, 10),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawOval(
      const Rect.fromLTWH(-10, -50, 20, 8),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    // Amber band + voltage.
    canvas.drawRect(
      const Rect.fromLTWH(-30, -10, 60, 20),
      Paint()..color = const Color(0xFFF59E0B),
    );
    _text(
      canvas,
      '1.5V',
      const Offset(0, 0),
      12,
      Colors.black,
      weight: FontWeight.w800,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-30, 27, 60, 16),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.restore();
  }

  void _drawBulb(Canvas canvas, Offset at, bool on) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.drawRect(
      const Rect.fromLTWH(-15, 20, 30, 20),
      Paint()..color = const Color(0xFF94A3B8),
    );
    if (on) {
      final glow = Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0xFFFACC15), Color(0x00FACC15)],
          stops: [0.1, 0.5, 1],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 40));
      canvas.drawCircle(Offset.zero, 40, glow);
    } else {
      canvas.drawCircle(
        Offset.zero,
        25,
        Paint()..color = const Color(0x80C8C8C8),
      );
    }
    canvas.drawCircle(
      Offset.zero,
      25,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final filament = Path()
      ..moveTo(-10, 20)
      ..lineTo(-5, 0)
      ..lineTo(5, 0)
      ..lineTo(10, 20);
    canvas.drawPath(
      filament,
      Paint()
        ..color = on ? Colors.white : const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _drawAmmeter(Canvas canvas, Offset at, double val) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    final face = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-40, -40, 80, 80),
      const Radius.circular(10),
    );
    canvas.drawRRect(face, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRRect(
      face,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 20), radius: 30),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.save();
    canvas.translate(0, 20);
    canvas.rotate(-math.pi / 4 + val * math.pi / 2);
    canvas.drawLine(
      Offset.zero,
      const Offset(0, -35),
      Paint()
        ..color = const Color(0xFFEF4444)
        ..strokeWidth = 3,
    );
    canvas.restore();
    _text(
      canvas,
      'A',
      const Offset(0, 8),
      10,
      Colors.black,
      weight: FontWeight.w800,
    );
    canvas.restore();
  }

  void _drawSwitch(Canvas canvas, Offset at, bool closed) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.drawRect(
      const Rect.fromLTWH(-40, -10, 80, 20),
      Paint()..color = const Color(0xFF1E293B),
    );
    final terminal = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(const Offset(-25, 0), 5, terminal);
    canvas.drawCircle(const Offset(25, 0), 5, terminal);
    final bar = Paint()..color = Colors.black;
    if (closed) {
      canvas.drawRect(const Rect.fromLTWH(-25, -5, 50, 10), bar);
    } else {
      canvas.save();
      canvas.translate(-25, 0);
      canvas.rotate(-0.5);
      canvas.drawRect(const Rect.fromLTWH(0, -5, 50, 10), bar);
      canvas.restore();
    }
    canvas.restore();
  }

  // -------------------------------------------------------------- zone 2 ---
  void _zone2(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final level = s._z2Level;

    // Macro view (fades and scales away as we zoom in).
    if (level < 0.99) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: 1 - level),
      );
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(1 + level * 3);
      canvas.translate(-cx, -cy);

      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFE2E8F0),
      );

      // Fit the loop + labels into short canvases (phone landscape).
      final fit = math.min(1.0, size.height / 340);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(fit);
      canvas.translate(-cx, -cy);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy), width: 300, height: 200),
        Paint()
          ..color = const Color(0xFFB45309)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
      canvas.save();
      canvas.translate(cx - 150, cy);
      canvas.scale(0.9);
      _drawCell(canvas, Offset.zero);
      canvas.restore();

      // Pulsing CLICK target on the top wire.
      final pulse = 1 + math.sin(s._clock * 5) * 0.1;
      canvas.save();
      canvas.translate(cx, cy - 100);
      canvas.scale(pulse);
      canvas.drawCircle(
        Offset.zero,
        30,
        Paint()..color = const Color(0x8022D3EE),
      );
      canvas.drawCircle(
        Offset.zero,
        30,
        Paint()
          ..color = const Color(0xFF22D3EE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _text(
        canvas,
        'CLICK',
        Offset.zero,
        12,
        Colors.white,
        weight: FontWeight.w800,
      );
      canvas.restore();
      _label(canvas, 'wire', Offset(cx, cy - 145));

      canvas.restore(); // fit
      canvas.restore();
      canvas.restore();
    }

    // Micro view (inside the copper wire).
    if (level > 0.01) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: level),
      );
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF451A03),
      );

      // Copper ion lattice.
      final ion = Paint()..color = const Color(0xFFB45309);
      for (double i = 0; i < size.width + 40; i += 60) {
        for (double j = 0; j < size.height + 40; j += 60) {
          canvas.drawCircle(Offset(i, j), 20, ion);
          _text(canvas, '+', Offset(i, j), 12, const Color(0x33000000));
        }
      }

      // Red arrows: conventional current, + to -.
      final arrow = Paint()..color = const Color(0xFFEF4444);
      for (var i = 0; i < 10; i++) {
        final x = (s._z2Off1 + i * 150) % size.width;
        final y = cy - 50 + math.sin(i.toDouble()) * 20;
        final path = Path()
          ..moveTo(x, y)
          ..lineTo(x - 40, y - 10)
          ..lineTo(x - 40, y + 10)
          ..close();
        canvas.drawPath(path, arrow);
      }
      _label(canvas, 'current', Offset(cx, cy - 100));

      // Blue electrons: - to +, the other way.
      final electron = Paint()..color = const Color(0xFF3B82F6);
      for (var i = 0; i < 50; i++) {
        var x = (s._z2Off2 + i * 80) % size.width;
        if (x < 0) x += size.width;
        final y = cy + 50 + math.cos(i * 32.0) * 40;
        canvas.drawCircle(Offset(x, y), 6, electron);
        _text(canvas, '-', Offset(x, y - 1), 10, Colors.white);
      }
      _label(canvas, 'electrons', Offset(cx, cy + 120));
      canvas.restore();
    }
  }

  // -------------------------------------------------------------- zone 3 ---
  void _zone3(Canvas canvas, Size size) {
    final scale = math.min(size.width / 880, size.height / 500);
    canvas.save();
    canvas.translate(size.width / 2 + 60 * scale, size.height / 2 - 10 * scale);
    canvas.scale(scale);

    // 1. Wire tube feeding the gate from the left.
    final tube = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF94A3B8), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      ).createShader(const Rect.fromLTWH(-400, -30, 400, 60));
    canvas.drawRect(const Rect.fromLTWH(-400, -30, 400, 60), tube);

    // 2. Turnstile gate.
    canvas.drawRect(
      const Rect.fromLTWH(-5, -45, 10, 90),
      Paint()..color = const Color(0xFF475569),
    );
    canvas.save();
    if (s._phase == _Z3Phase.counting) canvas.rotate(s._clock * 10);
    final arm = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRect(const Rect.fromLTWH(-2, -30, 4, 60), arm);
    canvas.drawRect(const Rect.fromLTWH(-30, -2, 60, 4), arm);
    canvas.restore();
    _label(canvas, 'gate', const Offset(0, -60));

    // 3. Charge bucket (tips when dumping).
    canvas.save();
    canvas.translate(100, 50);
    if (s._phase != _Z3Phase.idle && s._phase != _Z3Phase.counting) {
      canvas.rotate(s._dumpAngle);
    }
    final bucket = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFFBBF24), Color(0xFFD97706)],
      ).createShader(const Rect.fromLTWH(-50, -50, 100, 100));
    final bucketPath = Path()
      ..moveTo(-50, -50)
      ..lineTo(-40, 50)
      ..lineTo(40, 50)
      ..lineTo(50, -50)
      ..close();
    canvas.drawPath(bucketPath, bucket);
    canvas.drawPath(
      bucketPath,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (s._phase == _Z3Phase.idle || s._phase == _Z3Phase.counting) {
      final fill = math.min(1.0, (1 - s._time) * s._current / 3);
      canvas.drawRect(
        Rect.fromLTWH(-40, 50 - fill * 90, 80, fill * 90),
        Paint()..color = const Color(0xFF60A5FA),
      );
    }
    canvas.restore();
    _label(canvas, 'bucket', const Offset(100, 120));

    // 4. Digital scale.
    final shake = s._shake;
    const sx = 200.0;
    final sy = 150.0 + shake;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(sx, sy), width: 120, height: 20),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawRect(
      Rect.fromLTWH(sx - 50, sy, 100, 10),
      Paint()..color = const Color(0xFF4B5563),
    );
    canvas.drawRect(
      Rect.fromLTWH(sx - 60, sy + 10, 120, 40),
      Paint()..color = const Color(0xFF1F2937),
    );
    canvas.drawRect(
      Rect.fromLTWH(sx - 50, sy + 15, 100, 30),
      Paint()..color = const Color(0xFF064E3B),
    );
    var display = '0.00';
    if (s._phase == _Z3Phase.scaling || s._phase == _Z3Phase.complete) {
      display = '${(s._electrons / 1e18).toStringAsFixed(2)}E18';
    }
    _text(
      canvas,
      display,
      Offset(sx + 40, sy + 30),
      16,
      const Color(0xFF34D399),
      weight: FontWeight.w800,
      align: TextAlign.right,
      family: 'monospace',
    );
    _label(canvas, 'scale', Offset(sx, sy + 62));

    // 5. Shiny charge particles.
    for (final p in s._charges) {
      final grad = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.25),
          colors: [Colors.white, Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          stops: [0, 0.4, 1],
        ).createShader(Rect.fromCircle(center: Offset(p.x, p.y), radius: 4));
      canvas.drawCircle(Offset(p.x, p.y), 4, grad);
    }

    // Timer (drawn dark; the HTML painted it white-on-white by mistake).
    _text(
      canvas,
      '${s._time.toStringAsFixed(2)}s',
      const Offset(0, -100),
      40,
      const Color(0xFF0F172A),
      weight: FontWeight.w800,
      family: 'monospace',
    );
    _text(
      canvas,
      '${_tx.s('controls.currentLabel')} ${_Cl10SCh11A1ChargeFlowandCircuitsPageState._fmtI(s._current)} A',
      const Offset(-150, 80),
      20,
      _rt_Tw.cyan600,
      weight: FontWeight.w800,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StationPainter oldDelegate) => true;
}

// --------------------------------------------------------- toolbar toggle ---
/// Small square toolbar button matching the shell's zoom tools (the HTML
/// `#btn-labels` eye toggle).
class _ToolbarToggle extends StatelessWidget {
  const _ToolbarToggle({
    super.key,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? _rt_Lab.tinted(const Color(0xFFCFFAFE), _rt_Tw.cyan500)
          : _rt_Lab.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? _rt_Tw.cyan500 : _rt_Lab.border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? _rt_Tw.cyan500 : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }
}
