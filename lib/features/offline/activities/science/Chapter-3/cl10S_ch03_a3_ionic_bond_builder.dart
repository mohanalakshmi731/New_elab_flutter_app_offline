// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 3.3: Ionic Bond Builder
// Converted from Cl10S-Ch3-A3-IonicBondBuilder.html (React + three.js -> mini3d).
//
// Four stations, each its own scene group: electron exchange (NaCl / MgCl2),
// lattice aggregation, the stress tests (hammer + furnace) and the
// conductivity circuit.

// --- TRANSLATION DATA (content) ---

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
  static const teal50 = Color(0xFFF0FDFA);
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const teal900 = Color(0xFF134E4A);
  static const cyan500 = Color(0xFF06B6D4);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const violet500 = Color(0xFF8B5CF6);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red700 = Color(0xFFB91C1C);
  static const orange500 = Color(0xFFF97316);
  static const orange600 = Color(0xFFEA580C);
  static const amber500 = Color(0xFFF59E0B);
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
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
    this.done = false,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done;
  final bool expand;
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
  const _rt_ObjectiveCard({required this.title, required this.desc});

  final String title;
  final String desc;
  final Color accent = _rt_Tw.teal600;
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
    this.leftBorder = false,
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag = null;
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

/// Multiple-choice option button used in quizzes / challenges.
class _rt_ChoiceButton extends StatelessWidget {
  const _rt_ChoiceButton({
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
  const _rt_ShellTheme();

  final Color accent = _rt_Tw.teal600;
  final List<Color> headerGradient = const [_rt_Tw.slate900, _rt_Tw.teal900];
  final Color headerSubtitleColor = _rt_Tw.teal200;
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

  /// The activity (usually a _rt_Scene3DView). Fills the area right of the
  /// sidebar and resizes responsively when the sidebar opens/closes.
  final Widget canvas;

  /// Extra widgets stacked over the canvas (HUD, legends, overlays). Use
  /// Positioned / Align children.
  final List<Widget> canvasOverlays;

  final VoidCallback onRestart;
  final _rt_ShellController? controller;
  final _rt_ShellTheme theme = const _rt_ShellTheme();
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

/// Easing helpers matching the curves used in the HTML activities.
class _rt_Ease {
  static double outCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
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

  /// THREE.ConeGeometry(radius, height, radialSegments).
  factory _rt_Geometry3D.cone(
    double radius,
    double height, {
    int segments = 24,
    bool openEnded = false,
  }) => _rt_Geometry3D.cylinder(
    0,
    radius,
    height,
    segments: segments,
    openEnded: openEnded,
  );
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
  _rt_Mesh3D(this.geometry, this.material);

  _rt_Geometry3D geometry;
  _rt_Material3D material;
}

/// Smooth sphere drawn as a shaded disc (fast and perfectly round). Use
/// `_rt_Mesh3D(_rt_Geometry3D.sphere(...))` for partial spheres.
class _rt_Sphere3D extends _rt_Node3D {
  _rt_Sphere3D(this.radius, this.material, {super.name});

  double radius;
  _rt_Material3D material;
}

/// Polyline in 3D (THREE.Line / LineSegments). Width is in screen pixels.
class _rt_Line3D extends _rt_Node3D {
  _rt_Line3D(
    this.points, {
    this.color = const Color(0xFFFFFFFF),
    this.width = 2,
    this.opacity = 1,
    this.closed = false,
  });

  List<_rt_V3> points;
  Color color;
  double width;
  double opacity;
  bool dashed = false;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments = false;
  bool closed;
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
    this.worldHeight = 1.0,
    this.color = const Color(0xFFFFFFFF),
    this.background,
  });

  String text;

  /// Text height in world units (scales with distance like a sprite).
  double worldHeight;

  /// If set, fixed on-screen font size instead of [worldHeight].
  double? pixelHeight;
  Color color;
  Color? background;
  Color? borderColor;
  bool bold = true;

  /// THREE `depthTest: false` — drawn above all geometry.
  bool alwaysOnTop = true;
}

/// Lights. Ambient + directional + point lights are supported (Lambert).
class _rt_Light3D {
  _rt_Light3D.ambient({this.intensity = 0.6})
    : kind = _rt_LightKind.ambient,
      position = _rt_V3();
  _rt_Light3D.directional(this.position, {this.intensity = 0.8})
    : kind = _rt_LightKind.directional;

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
  final bool cameraControls = true;

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

  /// Runs [update] with eased progress 0..1 over [ms] milliseconds.
  Future<void> run(
    int ms,
    void Function(double t) update, {
    double Function(double) ease = _rt_Ease.outCubic,
  }) {
    final tw = _Tween(ms / 1000.0, update, ease);
    _active.add(tw);
    return tw.done.future;
  }

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
  const _rt_RotatePanToggle({required this.controller});

  final _rt_Scene3DController controller;
  final Color accent = _rt_Tw.teal600;

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
      'title': 'Ionic Bond Builder',
      'subtitle': 'Class 10 • Metals and Non-Metals',
      'button': 'Enter _rt_Lab',
      'footnote': 'Transfer • Lattice • Stress • Conductivity',
    },
    'headerTitle': 'Ionic Bond Builder',
    'headerSubtitle': 'NCERT Class 10 • Metals and Non-Metals',
    'tabs': {'explore': 'Mission Log', 'analysis': 'Outcomes'},
    'nav': ['Exchange', 'Lattice', 'Stress', 'Conductivity'],
    'objLabel': 'Main Objective',
    'objDesc':
        "Act as an 'Atomic Matchmaker': build stable ionic compounds by transferring electrons, then stress-test the crystals to determine their physical properties.",
    'missionsLabel': 'Complete the following missions:',
    'missions': [
      {
        'text': 'Station 1: Electron Transfer',
        'sub':
            'DO: Tap the glowing electron on Na. FOCUS: Watch Na become Na⁺ and Cl become Cl⁻.',
      },
      {
        'text': 'Station 2: Build Lattice',
        'sub':
            'DO: Increase quantity to 1 Mole. FOCUS: Observe the 3D grid structure forming.',
      },
      {
        'text': 'Station 3: Stress Test',
        'sub':
            'DO: Strike with the hammer. FOCUS: Shifting layers repel and shatter the crystal.',
      },
      {
        'text': 'Station 4: Conductivity',
        'sub':
            'DO: Add water to dissolve. FOCUS: Free ions let the bulb light up.',
      },
    ],
    's1': {
      'panelTitle': 'Mode Selection',
      'btnNaCl': 'Sodium Chloride',
      'btnMgCl2': 'Magnesium Chloride',
      'toast':
          'Mission: tap the glowing valence electron to start the transfer.',
      'obsTitle': 'Observation Report',
      'obsNaCl':
          'Sodium (Na) loses 1 electron to become an Na⁺ cation. Chlorine (Cl) accepts it to become a Cl⁻ anion. The electrostatic attraction between them is the ionic bond in NaCl.',
      'obsMg':
          'Magnesium (Mg) donates 2 valence electrons, giving Mg²⁺ and two Cl⁻ ions — the ionic compound MgCl₂.',
      'btnNext': 'Proceed to Crystal Lattice',
      'btnNextMg': 'Continue to Magnesium',
      'labels': {'nucleus': 'Nucleus', 'valence': 'Valence e⁻'},
    },
    's2': {
      'panelTitle': 'Aggregation',
      'qty': 'Quantity',
      'mole': '1 Mole',
      'molecules': 'Molecules',
      'desc':
          'Observe how inter-ionic attraction builds a close-packed cubic lattice.',
      'obsTitle': 'Crystal Formed',
      'obs':
          '1 Mole achieved: countless ions have aggregated into a macroscopic solid crystal. The strong forces between Na⁺ and Cl⁻ create a rigid cubic lattice — the white salt grain you can see.',
      'btnNext': 'Proceed to Stress Test',
    },
    's3': {
      'panelTitle': 'Properties Test',
      'btnHammer': 'Hammer',
      'btnFurnace': 'Furnace',
      'btnStrike': 'Strike',
      'btnHeat': 'Heat Crucible',
      'temp': 'Temperature',
      'obsHammerTitle': 'Brittleness',
      'obsHammer':
          'Brittle fracture: the blow shifted the crystal layers, aligning like charges (Na⁺ over Na⁺). The massive electrostatic repulsion shattered the crystal into cubes.',
      'obsFurnaceTitle': 'Melting Point',
      'obsFurnace':
          'Melting point reached (1074 K): thermal energy has overcome the electrostatic forces holding the lattice together. The solid collapses into a melt where ions move freely.',
      'btnNext': 'Go to Conductivity',
      'btnFurnaceLink': 'Go to Furnace',
      'scaleLow': '300K',
      'scaleMp': 'M.P. (1074K)',
      'scaleHigh': '1200K',
      'labels': {
        'hammer': 'Sledgehammer',
        'lattice': 'Salt Crystal',
        'crucible': 'Ceramic Crucible',
        'micro': 'Atomic View',
      },
    },
    's4': {
      'panelTitle': 'Circuit Control',
      'btnSwitch': 'Turn Switch',
      'btnAddWater': 'Add Water',
      'toastInit': 'Step 1: close the switch to test the solid crystal.',
      'toastSolid':
          'The bulb is OFF. Solid ionic compounds are insulators — the ions are locked in place. Step 2: add water to dissolve the lattice.',
      'toastLiquid':
          'Dissolved ions move freely to the electrodes, conducting electricity and lighting the bulb.',
      'obsTitle': 'Conductivity Analysis',
      'obs':
          'Solid state: ions are locked rigidly in the lattice, so the compound is an insulator. Aqueous state: water breaks the lattice down, the ions become mobile electrolytes and the bulb lights.',
      'btnFinish': 'Finish Experiment',
      'switchFirst': 'Turn on the switch first!',
      'labels': {
        'battery': 'Battery',
        'bulb': 'Bulb',
        'switchOn': 'Switch (ON)',
        'switchOff': 'Switch (OFF)',
        'cathode': 'Cathode (−)',
        'anode': 'Anode (+)',
        'solid': 'Solid Salt Block',
        'free': 'Free Ions',
        'cation': 'Cation (Na⁺)',
        'anion': 'Anion (Cl⁻)',
      },
    },
    'analysisTitle': 'Outcomes',
    'analysisHeaders': ['Property', 'Scientific Explanation'],
    'contextTitle': 'Why Learn This?',
    'contextIntro':
        'Understanding ionic bonds is understanding the glue that holds much of our world together. Ionic bonds are strong electrostatic forces between positive ions (cations) and negative ions (anions). This chemistry explains why salt is crystalline, why sports drinks replenish electrolytes, and how batteries power our lives.',
    'contextApps': [
      {
        'title': 'Nervous System',
        'desc':
            'Your body uses the movement of Na⁺ (sodium) and K⁺ (potassium) ions to send electrical signals through nerves.',
      },
      {
        'title': 'Table Salt (NaCl)',
        'desc':
            'The cubic crystal structure of salt is a direct result of the ionic lattice formed by sodium and chlorine.',
      },
      {
        'title': 'Batteries',
        'desc':
            'Electrolytes in batteries are ionic solutions that let charge flow between electrodes, powering your phone.',
      },
    ],
    'teacherTitle': 'Teacher Guide',
    'teacherIntro':
        'This interactive simulation helps students visualise the microscopic world of atomic bonding and its macroscopic physical consequences.',
    'teacherPhases': [
      {
        'title': 'Phase 1: Discovery (Electron Transfer)',
        'desc':
            'Guide students to Station 1. Explain how sodium (2,8,1) must lose an electron to achieve a stable octet, while chlorine (2,8,7) needs one. The transfer creates oppositely charged ions that act like magnets (electrostatic attraction).',
      },
      {
        'title': 'Phase 2: Interaction (Lattice Formation)',
        'desc':
            'In Station 2, show how a single Na⁺Cl⁻ pair is not enough. Millions of ions aggregate into a 3D alternating grid (lattice) to maximise attraction — this is why salt is found as solid crystals.',
      },
      {
        'title': 'Phase 3: Observation (Properties)',
        'desc':
            'Use Station 3 to demonstrate brittleness (repulsive layer shifting) and the melting point. Use Station 4 to prove that ions must be free to move (liquid or aqueous) to conduct electricity.',
      },
    ],
    'rows': [
      {
        'obs': 'High Melting Point (1074 K)',
        'out':
            'A considerable amount of energy is needed to break the strong inter-ionic attraction between the positive and negative ions.',
      },
      {
        'obs': 'Brittleness',
        'out':
            'When struck, the layers shift. Like charges align and violently repel, shattering the crystal.',
      },
      {
        'obs': 'Conductivity',
        'out':
            'Solid: ions are rigid and cannot move, so it insulates. Molten or aqueous: the lattice breaks down, ions move freely and conduct.',
      },
    ],
    'complete': {
      'title': 'Mission Accomplished!',
      'msg':
          'You built an ionic compound, grew its lattice, and showed why it is brittle, high-melting and conducts only when its ions are free to move.',
    },
  },
  'hi': {
    'intro': {
      'title': 'आयनिक बंध निर्माता',
      'subtitle': 'कक्षा 10 • धातु और अधातु',
      'button': 'प्रयोगशाला में प्रवेश करें',
      'footnote': 'स्थानांतरण • जालक • प्रतिबल • चालकता',
    },
    'headerTitle': 'आयनिक बंध निर्माता',
    'headerSubtitle': 'एनसीईआरटी कक्षा 10 • धातु और अधातु',
    'tabs': {'explore': 'मिशन लॉग', 'analysis': 'परिणाम'},
    'nav': ['विनिमय', 'जालक', 'प्रतिबल', 'चालकता'],
    'objLabel': 'मुख्य उद्देश्य',
    'objDesc':
        "'परमाणु मैचमेकर' बनकर इलेक्ट्रॉन स्थानांतरित करके स्थायी आयनिक यौगिक बनाएं, फिर क्रिस्टल के भौतिक गुणों की जांच करें।",
    'missionsLabel': 'निम्नलिखित मिशनों को पूरा करें:',
    'missions': [
      {
        'text': 'स्टेशन 1: इलेक्ट्रॉन स्थानांतरण',
        'sub':
            'करें: Na के चमकते इलेक्ट्रॉन पर टैप करें। देखें: Na → Na⁺ और Cl → Cl⁻।',
      },
      {
        'text': 'स्टेशन 2: जालक बनाएं',
        'sub': 'करें: मात्रा बढ़ाकर 1 मोल करें। देखें: 3D जालक संरचना बनती है।',
      },
      {
        'text': 'स्टेशन 3: प्रतिबल परीक्षण',
        'sub':
            'करें: हथौड़े से प्रहार करें। देखें: परतें खिसकने से प्रतिकर्षण और टूटना।',
      },
      {
        'text': 'स्टेशन 4: चालकता',
        'sub': 'करें: पानी डालकर घोलें। देखें: मुक्त आयन बल्ब जलाते हैं।',
      },
    ],
    's1': {
      'panelTitle': 'मोड चयन',
      'btnNaCl': 'सोडियम क्लोराइड',
      'btnMgCl2': 'मैग्नीशियम क्लोराइड',
      'toast':
          'मिशन: स्थानांतरण शुरू करने के लिए चमकते संयोजी इलेक्ट्रॉन पर टैप करें।',
      'obsTitle': 'अवलोकन रिपोर्ट',
      'obsNaCl':
          'सोडियम (Na) 1 इलेक्ट्रॉन खोकर Na⁺ धनायन बनता है। क्लोरीन (Cl) उसे लेकर Cl⁻ ऋणायन बनता है। दोनों के बीच स्थिरवैद्युत आकर्षण ही NaCl का आयनिक बंध है।',
      'obsMg':
          'मैग्नीशियम (Mg) 2 संयोजी इलेक्ट्रॉन देता है, जिससे Mg²⁺ और दो Cl⁻ आयन बनते हैं — यौगिक MgCl₂।',
      'btnNext': 'क्रिस्टल जालक पर जाएं',
      'btnNextMg': 'मैग्नीशियम जारी रखें',
      'labels': {'nucleus': 'नाभिक', 'valence': 'संयोजी e⁻'},
    },
    's2': {
      'panelTitle': 'एकत्रीकरण',
      'qty': 'मात्रा',
      'mole': '1 मोल',
      'molecules': 'अणु',
      'desc': 'देखें कि अंतर-आयनिक आकर्षण कैसे सघन घनीय जालक बनाता है।',
      'obsTitle': 'क्रिस्टल बना',
      'obs':
          '1 मोल: असंख्य आयन मिलकर ठोस क्रिस्टल बन गए हैं। Na⁺ और Cl⁻ के बीच प्रबल बल एक दृढ़ घनीय जालक बनाते हैं — यही सफेद नमक का दाना है।',
      'btnNext': 'प्रतिबल परीक्षण पर जाएं',
    },
    's3': {
      'panelTitle': 'गुण परीक्षण',
      'btnHammer': 'हथौड़ा',
      'btnFurnace': 'भट्ठी',
      'btnStrike': 'प्रहार करें',
      'btnHeat': 'क्रूसिबल गर्म करें',
      'temp': 'तापमान',
      'obsHammerTitle': 'भंगुरता',
      'obsHammer':
          'भंगुर विभंजन: प्रहार से परतें खिसक गईं और समान आवेश (Na⁺ के ऊपर Na⁺) आमने-सामने आ गए। प्रबल प्रतिकर्षण से क्रिस्टल टुकड़ों में बिखर गया।',
      'obsFurnaceTitle': 'गलनांक',
      'obsFurnace':
          'गलनांक (1074 K) पहुँच गया: ऊष्मीय ऊर्जा ने जालक को बांधे रखने वाले स्थिरवैद्युत बलों को पार कर लिया। ठोस संरचना पिघलकर द्रव बन जाती है जिसमें आयन मुक्त रूप से चलते हैं।',
      'btnNext': 'चालकता पर जाएं',
      'btnFurnaceLink': 'भट्ठी पर जाएं',
      'scaleLow': '300K',
      'scaleMp': 'गलनांक (1074K)',
      'scaleHigh': '1200K',
      'labels': {
        'hammer': 'घन (हथौड़ा)',
        'lattice': 'नमक क्रिस्टल',
        'crucible': 'सिरेमिक क्रूसिबल',
        'micro': 'परमाणु दृश्य',
      },
    },
    's4': {
      'panelTitle': 'परिपथ नियंत्रण',
      'btnSwitch': 'स्विच घुमाएं',
      'btnAddWater': 'पानी डालें',
      'toastInit': 'चरण 1: ठोस क्रिस्टल की जांच के लिए स्विच बंद करें।',
      'toastSolid':
          'बल्ब बंद है। ठोस आयनिक यौगिक विद्युतरोधी होते हैं — आयन अपनी जगह जकड़े रहते हैं। चरण 2: जालक घोलने के लिए पानी डालें।',
      'toastLiquid':
          'घुले हुए आयन इलेक्ट्रोड तक मुक्त रूप से जाते हैं, विद्युत प्रवाहित होती है और बल्ब जलता है।',
      'obsTitle': 'चालकता विश्लेषण',
      'obs':
          'ठोस अवस्था: आयन जालक में जकड़े रहते हैं, इसलिए यौगिक विद्युतरोधी है। जलीय अवस्था: पानी जालक को तोड़ देता है, आयन गतिशील विद्युत-अपघट्य बन जाते हैं और बल्ब जलता है।',
      'btnFinish': 'प्रयोग समाप्त करें',
      'switchFirst': 'पहले स्विच चालू करें!',
      'labels': {
        'battery': 'बैटरी',
        'bulb': 'बल्ब',
        'switchOn': 'स्विच (चालू)',
        'switchOff': 'स्विच (बंद)',
        'cathode': 'कैथोड (−)',
        'anode': 'एनोड (+)',
        'solid': 'ठोस नमक खंड',
        'free': 'मुक्त आयन',
        'cation': 'धनायन (Na⁺)',
        'anion': 'ऋणायन (Cl⁻)',
      },
    },
    'analysisTitle': 'परिणाम',
    'analysisHeaders': ['गुण', 'वैज्ञानिक व्याख्या'],
    'contextTitle': 'यह क्यों सीखें?',
    'contextIntro':
        "आयनिक बंधों को समझना उस 'गोंद' को समझना है जो हमारी दुनिया के बड़े हिस्से को जोड़े रखता है। आयनिक बंध धनायनों और ऋणायनों के बीच प्रबल स्थिरवैद्युत बल हैं। यही रसायन बताता है कि नमक क्रिस्टलीय क्यों है, स्पोर्ट्स ड्रिंक इलेक्ट्रोलाइट कैसे लौटाते हैं, और बैटरियाँ हमें ऊर्जा कैसे देती हैं।",
    'contextApps': [
      {
        'title': 'तंत्रिका तंत्र',
        'desc':
            'आपका शरीर नसों से विद्युत संकेत भेजने के लिए Na⁺ (सोडियम) और K⁺ (पोटैशियम) आयनों की गति का उपयोग करता है।',
      },
      {
        'title': 'नमक (NaCl)',
        'desc':
            'नमक की घनीय क्रिस्टल संरचना सोडियम और क्लोरीन के आयनिक जालक का सीधा परिणाम है।',
      },
      {
        'title': 'बैटरियाँ',
        'desc':
            'बैटरी में इलेक्ट्रोलाइट आयनिक विलयन होते हैं जो इलेक्ट्रोडों के बीच आवेश प्रवाह होने देते हैं, जिससे आपका फोन चलता है।',
      },
    ],
    'teacherTitle': 'शिक्षक गाइड',
    'teacherIntro':
        'यह इंटरैक्टिव सिमुलेशन छात्रों को परमाणु बंधन की सूक्ष्म दुनिया और उसके स्थूल भौतिक परिणामों की कल्पना करने में मदद करता है।',
    'teacherPhases': [
      {
        'title': 'चरण 1: खोज (इलेक्ट्रॉन स्थानांतरण)',
        'desc':
            'छात्रों को स्टेशन 1 पर ले जाएं। समझाएं कि सोडियम (2,8,1) को स्थायी अष्टक के लिए एक इलेक्ट्रॉन खोना होगा, जबकि क्लोरीन (2,8,7) को एक चाहिए। यह स्थानांतरण विपरीत आवेशित आयन बनाता है जो चुंबक की तरह आकर्षित होते हैं।',
      },
      {
        'title': 'चरण 2: अंतःक्रिया (जालक निर्माण)',
        'desc':
            'स्टेशन 2 में दिखाएं कि एक अकेला Na⁺Cl⁻ युग्म पर्याप्त नहीं है। असंख्य आयन आकर्षण अधिकतम करने के लिए 3D एकांतर ग्रिड (जालक) में एकत्र होते हैं — इसीलिए नमक ठोस क्रिस्टल में मिलता है।',
      },
      {
        'title': 'चरण 3: अवलोकन (गुण)',
        'desc':
            'भंगुरता (परतों के खिसकने से प्रतिकर्षण) और गलनांक दिखाने के लिए स्टेशन 3 का उपयोग करें। स्टेशन 4 से सिद्ध करें कि चालन के लिए आयनों का मुक्त (द्रव/जलीय) होना आवश्यक है।',
      },
    ],
    'rows': [
      {
        'obs': 'उच्च गलनांक (1074 K)',
        'out':
            'धन और ऋण आयनों के बीच प्रबल अंतर-आयनिक आकर्षण तोड़ने के लिए बहुत ऊर्जा चाहिए।',
      },
      {
        'obs': 'भंगुरता',
        'out':
            'प्रहार से परतें खिसकती हैं, समान आवेश आमने-सामने आकर प्रतिकर्षित होते हैं और क्रिस्टल टूट जाता है।',
      },
      {
        'obs': 'चालकता',
        'out':
            'ठोस: आयन स्थिर रहते हैं, चालन नहीं। पिघला या जलीय: जालक टूटता है, आयन मुक्त होकर विद्युत प्रवाहित करते हैं।',
      },
    ],
    'complete': {
      'title': 'मिशन पूर्ण!',
      'msg':
          'आपने आयनिक यौगिक बनाया, उसका जालक विकसित किया, और दिखाया कि वह भंगुर व उच्च गलनांक वाला है तथा केवल तभी चालन करता है जब उसके आयन मुक्त हों।',
    },
  },
});

const _naColor = Color(0xFFA855F7);
const _clColor = Color(0xFF22C55E);
const _mgColor = Color(0xFF94A3B8);
const _electronColor = Color(0xFF38BDF8);

/// Station 1 Bohr models in the source's units x2.4 (H:L756-795): Na/Mg
/// orbits 1.0 and 1.6, Cl orbits 1.2 and 2.0, shell electrons r = 0.12.
const _donorShells = [2.4, 3.84];
const _clShells = [2.88, 4.8];
const _shellElectronR = 0.29;
const _valenceElectronR = 0.5;

/// Lattice side length at full quantity. The HTML renders "a mole"; mini3d
/// rasterises on the CPU, so 5^3 = 125 ions is the visual stand-in.
const _latticeMax = 5;

enum _Station { exchange, lattice, stress, conductivity }

class Cl10SCh03A3IonicBondBuilderPage extends StatefulWidget {
  const Cl10SCh03A3IonicBondBuilderPage({super.key});

  @override
  State<Cl10SCh03A3IonicBondBuilderPage> createState() =>
      _Cl10SCh03A3IonicBondBuilderPageState();
}

class _Cl10SCh03A3IonicBondBuilderPageState
    extends State<Cl10SCh03A3IonicBondBuilderPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF13203B), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 4, 24),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final math.Random _rng = math.Random(11);

  late final _rt_Node3D _gExchange;
  late final _rt_Node3D _gLattice;
  late final _rt_Node3D _gStress;
  late final _rt_Node3D _gCircuit;

  // Station 1 nodes.
  late final _rt_Node3D _donor; // Na or Mg
  late final _rt_Node3D _acceptor1;
  late final _rt_Node3D _acceptor2;
  late final _rt_Node3D _electronA;
  late final _rt_Node3D _electronB;
  late final _rt_Sphere3D _donorCore;
  late final _rt_Node3D _clInnerShell;
  final List<_rt_Node3D> _clShellElectrons = [];
  late final _rt_Node3D _slot1; // empty outer-shell place on each acceptor
  late final _rt_Node3D _slot2;
  late final _rt_Label3D _nucleusLabel;
  late final _rt_Label3D _valenceLabel;
  final _rt_Material3D _donorMat = _rt_Material3D(
    color: _naColor,
    shininess: 0.6,
  );
  final _rt_Material3D _accept1Mat = _rt_Material3D(
    color: _clColor,
    shininess: 0.6,
  );
  final _rt_Material3D _accept2Mat = _rt_Material3D(
    color: _clColor,
    shininess: 0.6,
  );
  late final _rt_Label3D _donorLabel;
  late final _rt_Label3D _accept1Label;
  late final _rt_Label3D _accept2Label;

  // Station 2/3 lattice: one node per ion, plus its home position.
  final List<({_rt_Sphere3D node, _rt_V3 home, bool cation})> _ions = [];

  // Station 3 (hammer mode): sledgehammer, anvil, macro crystal and shards.
  late final _rt_Node3D _hammerPivot;
  late final _rt_Node3D _macroCrystal;
  late final _rt_Node3D _gStressHammer;
  late final _rt_Node3D _gStressFurnace;
  final List<({_rt_Node3D node, _rt_V3 vel})> _shards = [];
  late final _rt_Node3D _flame;

  // Station 4 nodes.
  late final _rt_Node3D _bulb;
  final _rt_Material3D _bulbMat = _rt_Material3D(
    color: _rt_Tw.slate600,
    unlit: true,
  );
  late final _rt_Node3D _saltBlock;
  late final _rt_Node3D _switchGroup;
  late final _rt_Node3D _switchLever;
  late final _rt_Label3D _switchLabel;
  late final _rt_Label3D _stateLabel; // "Solid Salt Block" / "Free Ions"
  late final _rt_Label3D _cationLabel;
  late final _rt_Label3D _anionLabel;
  final List<({_rt_Node3D node, bool cation, double phase})> _freeIons = [];

  // --- LAB STATE ---
  _Station _station = _Station.exchange;
  bool _busy = false;

  bool _mgMode = false;
  bool _transferred = false;

  int _quantity = 1;
  bool _stressHammer = true;
  bool _shattered = false;
  double _temperature = 300;
  bool _melted = false;

  bool _switchOn = false;
  bool _dissolved = false;

  double _clock = 0;

  final List<bool> _missions = [false, false, false, false];

  List<dynamic> get _missionList => _tx.list('missions');

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScene();
    _setStation(_Station.exchange, silent: true);
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
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.55),
      _rt_Light3D.directional(_rt_V3(6, 10, 8), intensity: 0.9),
    ]);
    _gExchange = _rt_Node3D(name: 'exchange');
    _gLattice = _rt_Node3D(name: 'lattice');
    _gStress = _rt_Node3D(name: 'stress');
    _gCircuit = _rt_Node3D(name: 'circuit');
    for (final g in [_gExchange, _gLattice, _gStress, _gCircuit]) {
      _scene.add(g);
    }
    _buildExchange();
    _buildLattice();
    _buildCircuit();
  }

  /// The source's createOrbit: a thin ring lying flat in the XZ plane.
  _rt_Line3D _orbit(double r) => _rt_Line3D(
    [
      for (var i = 0; i < 64; i++)
        _rt_V3(
          math.cos(i / 64 * math.pi * 2) * r,
          0,
          math.sin(i / 64 * math.pi * 2) * r,
        ),
    ],
    color: _rt_Tw.slate400,
    width: 1.2,
    opacity: 0.6,
    closed: true,
  )..pickable = false;

  /// Ghost outline of the empty outer-shell place (R:L2250).
  _rt_Sphere3D _ghostSlot(String name) => _rt_Sphere3D(
    _shellElectronR,
    _rt_Material3D(color: _electronColor, wireframe: true, opacity: 0.8),
    name: name,
  )..pickable = false;

  _rt_Sphere3D _shellElectron() => _rt_Sphere3D(
    _shellElectronR,
    _rt_Material3D(color: _electronColor, unlit: true),
    name: 'cl-electron',
  )..pickable = false;

  void _buildExchange() {
    // QA C10-3.3-04: Bohr models as the source draws them (H:L756-795):
    // nucleus, flat orbit rings and the electrons of the outer shell.
    _donor = _rt_Node3D(name: 'donor')..position.set(-6, 0, 0);
    _donorCore = _donor.add(_rt_Sphere3D(1.68, _donorMat));
    for (final r in _donorShells) {
      _donor.add(_orbit(r));
    }
    _gExchange.add(_donor);

    // Chlorine (2,8,7): 7 electrons on the outer ring, the 8th place empty.
    _acceptor1 = _rt_Node3D(name: 'acceptor1')..position.set(6, 0, 0);
    _acceptor1.add(_rt_Sphere3D(2.16, _accept1Mat));
    _clInnerShell = _acceptor1.add(_orbit(_clShells[0]));
    _acceptor1.add(_orbit(_clShells[1]));
    for (var i = 0; i < 7; i++) {
      final a = i / 8 * math.pi * 2;
      _clShellElectrons.add(
        _acceptor1.add(
          _shellElectron()
            ..position.set(
              math.cos(a) * _clShells[1],
              0,
              math.sin(a) * _clShells[1],
            ),
        ),
      );
    }
    _slot1 = _acceptor1.add(_ghostSlot('slot1'));
    _gExchange.add(_acceptor1);

    // The source's Mg-mode chlorines carry only the outer ring (H:L787-794).
    _acceptor2 = _rt_Node3D(name: 'acceptor2')..position.set(6, -6, 0);
    _acceptor2.add(_rt_Sphere3D(2.16, _accept2Mat));
    _acceptor2.add(_orbit(_clShells[1]));
    _slot2 = _acceptor2.add(
      _ghostSlot('slot2')..position.set(-_clShells[1], 0, 0),
    );
    _acceptor2.visible = false;
    _gExchange.add(_acceptor2);

    // Valence electrons on the donor's outer ring: the glowing ones are what
    // the student taps.
    _electronA = _rt_Sphere3D(
      _valenceElectronR,
      _rt_Material3D(color: _electronColor, unlit: true),
      name: 'electronA',
    );
    _electronB = _rt_Sphere3D(
      _valenceElectronR,
      _rt_Material3D(color: _electronColor, unlit: true),
      name: 'electronB',
    );

    _donorLabel = _rt_Label3D(
      '',
      position: _rt_V3(-6, 3.6, 0),
      worldHeight: 0.95,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _accept1Label = _rt_Label3D(
      '',
      position: _rt_V3(6, 4.0, 0),
      worldHeight: 0.95,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _accept2Label = _rt_Label3D(
      '',
      position: _rt_V3(6, -2.0, 0),
      worldHeight: 0.95,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _accept2Label.visible = false;
    // The source's Nucleus / Valence e- labels on sodium (H:L775-776); the
    // valence label sits just above the electron so it does not cover it.
    _nucleusLabel = _rt_Label3D(
      '',
      position: _rt_V3(-6, 0, 0),
      worldHeight: 0.7,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _valenceLabel = _rt_Label3D(
      '',
      position: _rt_V3(-6 + _donorShells[1], 1.5, 0),
      worldHeight: 0.7,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _gExchange.addAll([
      _donorLabel,
      _accept1Label,
      _accept2Label,
      _nucleusLabel,
      _valenceLabel,
    ]);
    _seatExchange();
  }

  void _buildLattice() {
    // A 5x5x5 alternating grid; `_quantity` controls how many are visible.
    const spacing = 2.2;
    const offset = (_latticeMax - 1) / 2 * spacing;
    for (var i = 0; i < _latticeMax; i++) {
      for (var j = 0; j < _latticeMax; j++) {
        for (var k = 0; k < _latticeMax; k++) {
          final cation = (i + j + k).isEven;
          final home = _rt_V3(
            i * spacing - offset,
            j * spacing - offset,
            k * spacing - offset,
          );
          final node = _rt_Sphere3D(
            cation ? 0.7 : 1.0,
            _rt_Material3D(
              color: cation ? _naColor : _clColor,
              shininess: 0.55,
            ),
          );
          node.position.copy(home);
          node.pickable = false;
          _gLattice.add(node);
          _ions.add((node: node, home: home, cation: cation));
        }
      }
    }
    // Stress station, hammer mode: anvil, macro salt crystal, shards and the
    // sledgehammer on its pivot (the source's swinging hammer).
    _gStressHammer = _rt_Node3D(name: 'stress-hammer');
    _gStress.add(_gStressHammer);
    _gStressHammer.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(11, 0.8, 7),
        _rt_Material3D(
          color: const Color(0xFF1F2937),
          shininess: 0.5,
          metalness: 0.4,
        ),
      )..position.y = -3.4,
    );
    _macroCrystal = _rt_Mesh3D(
      _rt_Geometry3D.box(3.6, 3.6, 3.6),
      _rt_Material3D(
        color: Colors.white,
        opacity: 0.95,
        shininess: 0.6,
        edgeColor: _rt_Tw.slate300,
      ),
    )..position.y = -1.2;
    _gStressHammer.add(_macroCrystal);
    final shardRng = math.Random(23);
    for (var i = 0; i < 12; i++) {
      final n =
          _rt_Mesh3D(
              _rt_Geometry3D.box(1.0, 1.0, 1.0),
              _rt_Material3D(
                color: Colors.white,
                opacity: 0.95,
                shininess: 0.5,
                edgeColor: _rt_Tw.slate300,
              ),
            )
            ..visible = false
            ..pickable = false;
      _gStressHammer.add(n);
      _shards.add((
        node: n,
        vel: _rt_V3(
          (shardRng.nextDouble() - .5) * 9,
          3 + shardRng.nextDouble() * 6,
          (shardRng.nextDouble() - .5) * 9,
        ),
      ));
    }
    _hammerPivot = _rt_Node3D(name: 'hammer')..position.set(5.4, 2.6, 0);
    final hammerMesh = _rt_Node3D()..rotation.z = math.pi / 8;
    hammerMesh.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.16, 0.16, 6, segments: 10),
        _rt_Material3D(color: const Color(0xFF8B5A2B), shininess: 0.2),
      )..position.y = 3,
    );
    hammerMesh.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.8, 0.8, 2.8, segments: 14),
          _rt_Material3D(
            color: const Color(0xFFCCCCCC),
            metalness: 0.8,
            shininess: 0.7,
          ),
        )
        ..position.y = 5.8
        ..rotation.z = math.pi / 2,
    );
    _hammerPivot.add(hammerMesh);
    _hammerPivot.rotation.z = math.pi / 4;
    _gStressHammer.add(_hammerPivot);
    _gStressHammer.add(
      _rt_Label3D(
        _tx.s('s3.labels.hammer'),
        position: _rt_V3(6.2, 7.2, 0),
        worldHeight: 0.85,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );
    _gStressHammer.add(
      _rt_Label3D(
        _tx.s('s3.labels.lattice'),
        position: _rt_V3(0, 1.6, 0),
        worldHeight: 0.85,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );

    // Stress station, furnace mode: crucible dish with a Bunsen flame below.
    _gStressFurnace = _rt_Node3D(name: 'stress-furnace');
    _gStress.add(_gStressFurnace);
    _gStressFurnace.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(7, 6, 1.2, segments: 28),
        _rt_Material3D(color: const Color(0xFF7C2D12), shininess: 0.3),
      )..position.y = -8,
    );
    _gStressFurnace.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.5, 0.5, 2.6, segments: 12),
        _rt_Material3D(color: const Color(0xFF64748B), shininess: 0.5),
      )..position.set(0, -13.1, 0),
    );
    _gStressFurnace.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(1.6, 2.0, 0.5, segments: 16),
        _rt_Material3D(color: const Color(0xFF334155), shininess: 0.4),
      )..position.set(0, -14.4, 0),
    );
    _flame = _rt_Node3D()..position.set(0, -11.8, 0);
    _flame.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cone(1.0, 2.2, segments: 14),
        _rt_Material3D(
          color: const Color(0xFFFF4500),
          opacity: 0.4,
          unlit: true,
          doubleSided: true,
        ),
      )..position.y = 1.1,
    );
    _flame.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cone(0.5, 1.3, segments: 12),
        _rt_Material3D(
          color: const Color(0xFF3B82F6),
          opacity: 0.65,
          unlit: true,
          doubleSided: true,
        ),
      )..position.y = 0.65,
    );
    _gStressFurnace.add(_flame);
    _gStressFurnace.add(
      _rt_Label3D(
        _tx.s('s3.labels.crucible'),
        position: _rt_V3(-8.2, -7.0, 0),
        worldHeight: 0.85,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );
  }

  void _buildCircuit() {
    final metal = _rt_Material3D(
      color: _rt_Tw.slate300,
      shininess: 0.7,
      metalness: 0.5,
    );

    // Beaker.
    _gCircuit.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(6, 6, 9, segments: 30, openEnded: true),
          _rt_Material3D(
            color: const Color(0xFFBAE6FD),
            opacity: 0.22,
            doubleSided: true,
          ),
        )
        ..position.y = -3
        ..pickable = false,
    );
    _gCircuit.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(6, 6, 0.3, segments: 30),
          _rt_Material3D(color: const Color(0xFFBAE6FD), opacity: 0.35),
        )
        ..position.y = -7.5
        ..pickable = false,
    );

    // Electrodes.
    for (final x in [-3.0, 3.0]) {
      _gCircuit.add(
        _rt_Mesh3D(_rt_Geometry3D.box(0.9, 8, 0.9), metal)
          ..position.set(x, -2.5, 0),
      );
    }
    _gCircuit.add(
      _rt_Label3D(
        _tx.s('s4.labels.cathode'),
        position: _rt_V3(-3.6, 3.2, 0),
        worldHeight: 0.8,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );
    _gCircuit.add(
      _rt_Label3D(
        _tx.s('s4.labels.anode'),
        position: _rt_V3(3.6, 3.2, 0),
        worldHeight: 0.8,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );

    // Solid salt block sitting between the electrodes.
    _saltBlock = _rt_Mesh3D(
      _rt_Geometry3D.box(4, 3, 3),
      _rt_Material3D(
        color: Colors.white,
        shininess: 0.4,
        edgeColor: _rt_Tw.slate400,
      ),
    )..position.y = -5.5;
    _gCircuit.add(_saltBlock);
    _stateLabel = _rt_Label3D(
      _tx.s('s4.labels.solid'),
      position: _rt_V3(0, -9.4, 0),
      worldHeight: 0.8,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _gCircuit.add(_stateLabel);
    _cationLabel = _rt_Label3D(
      _tx.s('s4.labels.cation'),
      position: _rt_V3(-4.6, -8.2, 0),
      worldHeight: 0.72,
      background: const Color(0xE67C3AED),
      color: Colors.white,
    )..visible = false;
    _anionLabel = _rt_Label3D(
      _tx.s('s4.labels.anion'),
      position: _rt_V3(4.6, -8.2, 0),
      worldHeight: 0.72,
      background: const Color(0xE615803D),
      color: Colors.white,
    )..visible = false;
    _gCircuit.addAll([_cationLabel, _anionLabel]);

    // Bulb above the beaker, wired to the battery.
    _bulb = _rt_Sphere3D(1.6, _bulbMat)..position.set(0, 8.5, 0);
    _gCircuit.add(_bulb);
    _gCircuit.add(
      _rt_Label3D(
        _tx.s('s4.labels.bulb'),
        position: _rt_V3(0, 10.8, 0),
        worldHeight: 0.8,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );
    _gCircuit.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(3.2, 1.6, 1.2),
        _rt_Material3D(color: const Color(0xFF334155), shininess: 0.3),
      )..position.set(0, 5.4, 0),
    );

    // Battery lying on the bench to the left of the beaker.
    final battery = _rt_Node3D()..position.set(-10.5, -6.6, 0);
    battery.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(1.0, 1.0, 4.2, segments: 16),
        _rt_Material3D(color: const Color(0xFF222222), shininess: 0.5),
      )..rotation.z = math.pi / 2,
    );
    battery.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.35, 0.35, 0.7, segments: 10),
          _rt_Material3D(
            color: const Color(0xFFAAAAAA),
            metalness: 0.7,
            shininess: 0.7,
          ),
        )
        ..position.set(2.3, 0, 0)
        ..rotation.z = math.pi / 2,
    );
    _gCircuit.add(battery);
    _gCircuit.add(
      _rt_Label3D(
        _tx.s('s4.labels.battery'),
        position: _rt_V3(-10.5, -3.9, 0),
        worldHeight: 0.8,
        background: const Color(0xE6334155),
        color: Colors.white,
      ),
    );

    // Knife switch on the right; tapping it in the scene closes the circuit.
    _switchGroup = _rt_Node3D(name: 'switch')..position.set(10.5, -6.6, 0);
    _switchGroup.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(3.4, 0.5, 2.2),
        _rt_Material3D(color: const Color(0xFF555555), shininess: 0.4),
      ),
    );
    for (final x in [-1.1, 1.1]) {
      _switchGroup.add(
        _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.25, 0.25, 0.7, segments: 8),
          _rt_Material3D(
            color: const Color(0xFF9CA3AF),
            metalness: 0.6,
            shininess: 0.6,
          ),
        )..position.set(x, 0.5, 0),
      );
    }
    _switchLever = _rt_Node3D()..position.set(-1.1, 0.6, 0);
    _switchLever.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(2.6, 0.18, 0.35),
        _rt_Material3D(
          color: const Color(0xFFB8860B),
          metalness: 0.5,
          shininess: 0.6,
        ),
      )..position.set(1.3, 0, 0),
    );
    _switchLever.rotation.z = math.pi / 5; // open
    _switchGroup.add(_switchLever);
    _gCircuit.add(_switchGroup);
    _switchLabel = _rt_Label3D(
      _tx.s('s4.labels.switchOff'),
      position: _rt_V3(10.5, -3.9, 0),
      worldHeight: 0.8,
      background: const Color(0xE6334155),
      color: Colors.white,
    );
    _gCircuit.add(_switchLabel);
    // Wires battery -> beaker -> switch (decorative loop like the source).
    _gCircuit.add(
      _rt_Line3D(
        [_rt_V3(-10.5, -5.6, 0), _rt_V3(-10.5, 1.5, 0), _rt_V3(-3, 1.5, 0)],
        color: const Color(0xFFEAB308),
        width: 2,
      ),
    );
    _gCircuit.add(
      _rt_Line3D(
        [_rt_V3(3, 1.5, 0), _rt_V3(10.5, 1.5, 0), _rt_V3(10.5, -5.6, 0)],
        color: const Color(0xFFEAB308),
        width: 2,
      ),
    );
    _gCircuit.add(
      _rt_Line3D(
        [_rt_V3(-3, 1.5, 0), _rt_V3(-3, 6.4, 0), _rt_V3(-1.6, 8.5, 0)],
        color: _rt_Tw.slate400,
        width: 2,
      ),
    );
    _gCircuit.add(
      _rt_Line3D(
        [_rt_V3(3, 1.5, 0), _rt_V3(3, 6.4, 0), _rt_V3(1.6, 8.5, 0)],
        color: _rt_Tw.slate400,
        width: 2,
      ),
    );

    // Free ions, revealed once the block dissolves.
    for (var i = 0; i < 26; i++) {
      final cation = i.isEven;
      final n = _rt_Sphere3D(
        cation ? 0.4 : 0.55,
        _rt_Material3D(color: cation ? _naColor : _clColor, unlit: true),
      );
      n.visible = false;
      n.pickable = false;
      _gCircuit.add(n);
      _freeIons.add((node: n, cation: cation, phase: _rng.nextDouble()));
    }
  }

  // ----------------------------------------------------------- frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);

    if (_station == _Station.exchange && !_transferred) {
      // The untransferred electrons pulse so they read as tappable.
      final s = 1 + math.sin(_clock * 5) * 0.25;
      _electronA.scale.set(s, s, s);
      _electronB.scale.set(s, s, s);
    }

    if (_station == _Station.stress && !_stressHammer) {
      // Flame grows with the temperature and flickers.
      final heat = ((_temperature - 300) / 900).clamp(0.0, 1.0);
      final f = 1 + heat * 0.5 + math.sin(_clock * 22) * 0.06;
      _flame.scale.set(f, 1 + math.sin(_clock * 30) * 0.08, f);
      // Below the melt the lattice vibrates harder as it heats.
      if (!_melted) {
        for (final ion in _ions) {
          if (!ion.node.visible) continue;
          final vib = heat * 0.18;
          ion.node.position.set(
            ion.home.x + (_rng.nextDouble() - 0.5) * vib,
            ion.home.y + (_rng.nextDouble() - 0.5) * vib,
            ion.home.z + (_rng.nextDouble() - 0.5) * vib,
          );
        }
      }
    }

    if (_station == _Station.stress && _melted) {
      // Molten: ions jitter around slumped positions.
      for (final ion in _ions) {
        if (!ion.node.visible) continue;
        final p = ion.node.position;
        p.x += (_rng.nextDouble() - 0.5) * 0.12;
        p.z += (_rng.nextDouble() - 0.5) * 0.12;
        p.x = p.x.clamp(-6.5, 6.5);
        p.z = p.z.clamp(-6.5, 6.5);
      }
    }

    if (_station == _Station.conductivity && _dissolved) {
      // Ions drift toward the electrode of opposite sign.
      for (final ion in _freeIons) {
        final t = (_clock * 0.25 + ion.phase) % 1;
        final targetX = ion.cation ? -3.0 : 3.0;
        final startX = ion.cation ? 3.5 : -3.5;
        ion.node.position.set(
          startX + (targetX - startX) * t,
          -6.5 + ((ion.phase * 7) % 5),
          math.sin((ion.phase + t) * math.pi * 2) * 2.2,
        );
      }
    }
  }

  // --------------------------------------------------------- stations ---
  void _setStation(_Station s, {bool silent = false}) {
    // Source: playSFX('click') on the nav bar; a station is a stage change.
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _station = s;
      _busy = false;
    });
    _gExchange.visible = s == _Station.exchange;
    _gCircuit.visible = s == _Station.conductivity;
    _applyLattice();
    _syncExchangeLabels();
    _syncStressMode();
    switch (s) {
      case _Station.exchange:
        // The source's view angle (camera (0, 2, 14), H:L672), so the flat
        // orbit rings and their electrons read as in the source.
        _camera.position.set(0, 3.7, 25.7);
        _camera.target.set(0, _mgMode ? -3 : 0, 0);
      case _Station.lattice:
        _camera.position.set(9, 8, 20);
        _camera.target.set(0, 0, 0);
      case _Station.stress:
        break; // camera + lattice handled by _syncStressMode
      case _Station.conductivity:
        _camera.position.set(0, 2, 28);
        _camera.target.set(0, 0, 0);
    }
    if (s == _Station.conductivity && !silent) {
      _shell.showToast(
        _tx.s('s4.toastInit'),
        color: _rt_Tw.blue500,
        icon: Icons.bolt,
      );
    }
  }

  /// Shows either the hammer bench or the crucible, like the source's
  /// mode-scoped Station-3 scenes. The ion lattice is only part of the
  /// furnace view; the hammer strikes the macroscopic crystal.
  void _syncStressMode() {
    final stress = _station == _Station.stress;
    _gStress.visible = stress;
    _gStressHammer.visible = stress && _stressHammer;
    _gStressFurnace.visible = stress && !_stressHammer;
    _gLattice.visible =
        _station == _Station.lattice || (stress && !_stressHammer);
    if (!stress) return;
    if (_stressHammer) {
      _camera.position.set(1, 4, 30);
      _camera.target.set(0, 0, 0);
      _macroCrystal.visible = !_shattered;
      for (final sh in _shards) {
        sh.node.visible = _shattered;
      }
    } else {
      _camera.position.set(9, 4, 26);
      _camera.target.set(0, -3, 0);
    }
  }

  void _completeMission(int i) {
    if (_missions[i]) return;
    setState(() => _missions[i] = true);
    _rt_playSfx(_rt_Sfx.correct);
    if (_missions.every((m) => m)) {
      _shell.showSuccess(
        title: _tx.s('complete.title'),
        message: _tx.s('complete.msg'),
      );
    }
  }

  // ------------------------------------------------ station 1: exchange ---
  void _syncExchangeLabels() {
    _donorLabel.text = _transferred
        ? (_mgMode ? 'Mg²⁺' : 'Na⁺')
        : (_mgMode ? 'Mg' : 'Na');
    _accept1Label.text = _transferred ? 'Cl⁻' : 'Cl';
    _accept2Label.text = _transferred ? 'Cl⁻' : 'Cl';
    _nucleusLabel.text = _tx.s('s1.labels.nucleus');
    _valenceLabel.text = _tx.s('s1.labels.valence');
    _donorMat.color = _mgMode ? _mgColor : _naColor;
  }

  void _setMode(bool mg) {
    if (_mgMode == mg) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _mgMode = mg;
      _transferred = false;
    });
    _resetExchange();
  }

  void _resetExchange() {
    _tweens.cancelAll();
    _donor.position.set(-6, _mgMode ? -3 : 0, 0);
    _acceptor1.position.set(6, _mgMode ? 0 : 0, 0);
    _acceptor2.position.set(6, -6, 0);
    _acceptor2.visible = _mgMode;
    _accept2Label.visible = _mgMode;
    _seatExchange();
    _donor.scale.set(1, 1, 1);
    _acceptor1.scale.set(1, 1, 1);
    _acceptor2.scale.set(1, 1, 1);
    _camera.target.set(0, _mgMode ? -3 : 0, 0);
    _syncExchangeLabels();
  }

  /// Puts the Bohr models in their untransferred state for the current mode,
  /// as the source's build(m) does (H:L756-795).
  void _seatExchange() {
    _donorCore.radius = _mgMode ? 1.92 : 1.68; // source cores: Mg 0.8, Na 0.7
    // Valence electrons back on the donor's outer ring (H:L760, L782-783).
    _donor.add(_electronA);
    _donor.add(_electronB);
    _electronA
      ..position.set(_donorShells[1], 0, 0)
      ..scale.set(1, 1, 1)
      ..visible = true;
    _electronB
      ..position.set(-_donorShells[1], 0, 0)
      ..scale.set(1, 1, 1)
      ..visible = _mgMode;
    // NaCl: the 8th place of chlorine's outer ring (H:L768). MgCl2: each
    // chlorine's place faces the magnesium (H:L789, L794).
    final a = 7 / 8 * math.pi * 2;
    _slot1
      ..position.set(
        _mgMode ? -_clShells[1] : math.cos(a) * _clShells[1],
        0,
        _mgMode ? 0 : math.sin(a) * _clShells[1],
      )
      ..visible = true;
    _slot2.visible = true;
    _clInnerShell.visible = !_mgMode;
    for (final e in _clShellElectrons) {
      e.visible = !_mgMode;
    }
    _nucleusLabel.visible = !_mgMode;
    _valenceLabel.visible = !_mgMode;
  }

  /// Tapping a glowing valence electron sends it across to the acceptor.
  void _onTap(_rt_SceneEvent e) {
    if (_station == _Station.conductivity) {
      // The source raycasts the knife switch: tapping it toggles the circuit.
      if (e.hitWhere((n) {
            for (_rt_Node3D? p = n; p != null; p = p.parent) {
              if (p == _switchGroup) return true;
            }
            return false;
          }) !=
          null) {
        _toggleSwitch();
      }
      return;
    }
    if (_station != _Station.exchange || _transferred || _busy) return;
    if (e.hitWhere((n) => n == _electronA || n == _electronB) == null) return;
    _rt_playSfx(_rt_Sfx.tap); // source: playSFX('click') on the electron
    _transferElectrons();
  }

  Future<void> _transferElectrons() async {
    if (_transferred || _busy) return;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);

    // Like the source's scene.attach(eObj), each electron leaves its atom and
    // flies in world space to the empty place on its acceptor (H:L828-834).
    final flights = [
      (e: _electronA, to: _acceptor1, slot: _slot1, arc: 2.5),
      if (_mgMode) (e: _electronB, to: _acceptor2, slot: _slot2, arc: -2.5),
    ];
    final starts = [for (final f in flights) f.e.worldPosition];
    final ends = [for (final f in flights) f.slot.worldPosition];
    for (var i = 0; i < flights.length; i++) {
      _gExchange.add(flights[i].e);
      flights[i].e.position.copy(starts[i]);
    }

    await _tweens.run(1100, (t) {
      for (var i = 0; i < flights.length; i++) {
        final s = starts[i], d = ends[i];
        flights[i].e.position.set(
          s.x + (d.x - s.x) * t,
          s.y + (d.y - s.y) * t + math.sin(t * math.pi) * flights[i].arc,
          s.z + (d.z - s.z) * t,
        );
      }
    });
    if (!mounted) return;

    // QA C10-3.3-04: the electron stays in the slot as an ordinary shell
    // electron; the source re-attaches it and switches its glow off
    // (H:L836-839), so chlorine now shows a full octet.
    for (final f in flights) {
      f.to.add(f.e);
      f.e.position.copy(f.slot.position);
      const s = _shellElectronR / _valenceElectronR;
      f.e.scale.set(s, s, s);
      f.slot.visible = false;
    }
    setState(() => _transferred = true);
    _syncExchangeLabels();

    // The cation shrinks, the anions swell, then they pull together.
    await _tweens.run(900, (t) {
      final shrink = 1 - 0.3 * t;
      final grow = 1 + 0.18 * t;
      _donor.scale.set(shrink, shrink, shrink);
      _acceptor1.scale.set(grow, grow, grow);
      _acceptor2.scale.set(grow, grow, grow);
      _donor.position.x = -6 + 1.8 * t;
      _acceptor1.position.x = 6 - 1.8 * t;
      _acceptor2.position.x = 6 - 1.8 * t;
    });
    if (!mounted) return;
    _rt_playSfx(_rt_Sfx.correct);
    _shell.showToast(
      _mgMode ? _tx.s('s1.obsMg') : _tx.s('s1.obsNaCl'),
      ms: 6000,
    );
    setState(() => _busy = false);
    _completeMission(0);
  }

  // ------------------------------------------------- station 2: lattice ---
  /// Shows the first `n^3` ions of the grid, where n grows with `_quantity`.
  void _applyLattice() {
    // The stress station always tests the full crystal (the source's
    // Station 3 builds its own 4x4x4 grid regardless of Station 2).
    final side = _station == _Station.stress ? _latticeMax : _quantity;
    const half = (_latticeMax - 1) / 2 * 2.2;
    final limit = (side - 1) / 2 * 2.2;
    for (final ion in _ions) {
      final inside =
          ion.home.x.abs() <= limit + 0.01 &&
          ion.home.y.abs() <= limit + 0.01 &&
          ion.home.z.abs() <= limit + 0.01;
      ion.node.visible = inside && !_shattered;
      if (!_melted && !_shattered) {
        ion.node.position.copy(ion.home);
        if (_station == _Station.stress) ion.node.position.y -= 0;
      }
    }
    if (half == 0) return;
  }

  void _setQuantity(double v) {
    setState(() => _quantity = v.round());
    _applyLattice();
    if (_quantity >= _latticeMax) {
      _rt_playSfx(_rt_Sfx.magic);
      _shell.showToast(_tx.s('s2.obs'), ms: 6000);
      _completeMission(1);
    }
  }

  // -------------------------------------------------- station 3: stress ---
  Future<void> _strike() async {
    if (_busy || _shattered) return;
    setState(() => _busy = true);
    // Source: playSFX('whoosh') as the hammer swings down.
    _rt_playSfx(_rt_Sfx.tap);
    await _tweens.run(300, (t) {
      _hammerPivot.rotation.z = math.pi / 4 - (math.pi / 4 + math.pi / 3) * t;
    });
    if (!mounted) return;
    // Impact: playSFX('clank') then the shatter noise burst.
    _rt_playSfx(_rt_Sfx.pop);
    _macroCrystal.visible = false;
    for (final sh in _shards) {
      sh.node.visible = true;
      sh.node.position.set(
        (_rng.nextDouble() - .5) * 1.5,
        -1.2 + (_rng.nextDouble() - .5) * 1.5,
        (_rng.nextDouble() - .5) * 1.5,
      );
    }
    _rt_playSfx(_rt_Sfx.wrong);
    final starts = [for (final sh in _shards) sh.node.position.clone()];
    // Shards fly out under gravity and settle on the anvil (recoil runs too).
    await _tweens.run(1200, (t) {
      _hammerPivot.rotation.z = -math.pi / 3 + (math.pi / 4 + math.pi / 3) * t;
      final ft = t * 1.2; // seconds of flight
      for (var i = 0; i < _shards.length; i++) {
        final sh = _shards[i];
        final s0 = starts[i];
        final y = s0.y + sh.vel.y * ft - 9.5 * ft * ft;
        sh.node.position.set(
          s0.x + sh.vel.x * ft,
          y < -2.5 ? -2.5 : y,
          s0.z + sh.vel.z * ft,
        );
        sh.node.rotation.x += 0.12;
        sh.node.rotation.y += 0.12;
      }
    });
    if (!mounted) return;
    setState(() {
      _shattered = true;
      _busy = false;
    });
    _shell.showToast(
      _tx.s('s3.obsHammer'),
      color: _rt_Tw.red500,
      icon: Icons.broken_image,
      ms: 6000,
    );
    _completeMission(2);
  }

  /// Source: the furnace is driven by a 300-1200 K temperature slider; the
  /// crystal melts (and the mission ticks) the moment it crosses 1074 K, and
  /// solidifies again if the slider drops back below.
  void _setTemperature(double t) {
    setState(() => _temperature = t);
    final ratio = ((t - 300) / 900).clamp(0.0, 1.0);
    for (final ion in _ions) {
      ion.node.material.color = Color.lerp(
        ion.cation ? _naColor : _clColor,
        const Color(0xFFF97316),
        ratio * 0.7,
      )!;
    }
    if (t >= 1074 && !_melted) {
      _melt();
    } else if (t < 1074 && _melted) {
      // Re-solidify.
      _rt_playSfx(_rt_Sfx.toggle);
      _tweens.cancelAll();
      setState(() => _melted = false);
      for (final ion in _ions) {
        ion.node.position.copy(ion.home);
      }
    }
  }

  Future<void> _melt() async {
    _rt_playSfx(_rt_Sfx.magic);
    setState(() => _melted = true);
    // The lattice slumps into a melt.
    await _tweens.run(1200, (t) {
      for (final ion in _ions) {
        if (!ion.node.visible) continue;
        ion.node.position.y = ion.home.y + (-6.6 - ion.home.y) * t * 0.85;
      }
    });
    if (!mounted) return;
    _shell.showToast(
      _tx.s('s3.obsFurnace'),
      color: _rt_Tw.orange500,
      icon: Icons.whatshot,
      ms: 6000,
    );
    _completeMission(2);
  }

  /// Sidebar shortcut that sweeps the slider up to the melting point.
  Future<void> _heat() async {
    if (_busy || _melted) return;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);
    await _tweens.run(3000, (t) {
      final temp = 300 + 774 * t;
      setState(() => _temperature = temp);
      final ratio = ((temp - 300) / 900).clamp(0.0, 1.0);
      for (final ion in _ions) {
        if (!ion.node.visible) continue;
        ion.node.material.color = Color.lerp(
          ion.cation ? _naColor : _clColor,
          const Color(0xFFF97316),
          ratio * 0.7,
        )!;
      }
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (!_melted) await _melt();
  }

  void _resetStress() {
    _rt_playSfx(_rt_Sfx.toggle);
    _tweens.cancelAll();
    setState(() {
      _shattered = false;
      _melted = false;
      _temperature = 300;
      _busy = false;
    });
    for (final ion in _ions) {
      ion.node.position.copy(ion.home);
      ion.node.material.color = ion.cation ? _naColor : _clColor;
    }
    _hammerPivot.rotation.z = math.pi / 4;
    _applyLattice();
    _syncStressMode();
  }

  void _setStressMode(bool hammer) {
    if (_stressHammer == hammer) return;
    _rt_playSfx(_rt_Sfx.toggle);
    _tweens.cancelAll();
    setState(() {
      _stressHammer = hammer;
      _busy = false;
    });
    _syncStressMode();
  }

  // -------------------------------------------- station 4: conductivity ---
  void _toggleSwitch() {
    // Source: playSFX('click') for the knife switch.
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _switchOn = !_switchOn);
    _syncBulb();
    if (_switchOn && !_dissolved) {
      _shell.showToast(
        _tx.s('s4.toastSolid'),
        color: _rt_Tw.red500,
        icon: Icons.highlight_off,
        ms: 6000,
      );
    }
  }

  void _addWater() {
    if (_dissolved) return;
    // Source gates Add Water behind the closed switch.
    if (!_switchOn) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('s4.switchFirst'),
        color: _rt_Tw.amber500,
        icon: Icons.warning_amber,
        ms: 3000,
      );
      return;
    }
    // Source: playSFX('splash').
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _dissolved = true);
    _saltBlock.visible = false;
    for (final ion in _freeIons) {
      ion.node.visible = true;
    }
    _syncBulb();
  }

  /// The bulb lights only when the circuit is closed *and* the ions are free.
  /// Once it does, the source shows the final Conductivity Analysis popup
  /// with the Finish Experiment button, which completes the last mission.
  void _syncBulb() {
    final lit = _switchOn && _dissolved;
    _bulbMat.color = lit ? const Color(0xFFFACC15) : _rt_Tw.slate600;
    _switchLever.rotation.z = _switchOn ? 0 : math.pi / 5;
    _switchLabel.text = _tx.s(
      _switchOn ? 's4.labels.switchOn' : 's4.labels.switchOff',
    );
    _stateLabel.text = _tx.s(_dissolved ? 's4.labels.free' : 's4.labels.solid');
    _cationLabel.visible = _dissolved;
    _anionLabel.visible = _dissolved;
    if (lit && !_missions[3]) {
      _rt_playSfx(_rt_Sfx.magic); // the bulb lights up
      _shell.showToast(_tx.s('s4.toastLiquid'), ms: 6000);
      Future<void>.delayed(const Duration(milliseconds: 1500), () async {
        if (!mounted || !_switchOn || !_dissolved || _missions[3]) return;
        await _rt_showShellPopup(
          context,
          title: _tx.s('s4.obsTitle'),
          message: _tx.s('s4.obs'),
          icon: Icons.insights,
          color: _rt_Tw.green500,
          buttonLabel: _tx.s('s4.btnFinish'),
        );
        if (mounted) _completeMission(3);
      });
    }
  }

  void _restart() {
    _rt_playSfx(_rt_Sfx.scenario);
    _tweens.cancelAll();
    setState(() {
      _mgMode = false;
      _transferred = false;
      _quantity = 1;
      _stressHammer = true;
      _shattered = false;
      _melted = false;
      _temperature = 300;
      _switchOn = false;
      _dissolved = false;
      _busy = false;
      for (var i = 0; i < _missions.length; i++) {
        _missions[i] = false;
      }
    });
    _resetExchange();
    for (final ion in _ions) {
      ion.node.position.copy(ion.home);
      ion.node.material.color = ion.cation ? _naColor : _clColor;
    }
    _hammerPivot.rotation.z = math.pi / 4;
    _saltBlock.visible = true;
    for (final ion in _freeIons) {
      ion.node.visible = false;
    }
    _syncBulb();
    _setStation(_Station.exchange, silent: true);
    _camera.reset();
  }

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _syncExchangeLabels(); // Nucleus / Valence labels follow the language
          final next = _missions.indexWhere((m) => !m);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.hub,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: () => _setStation(_station, silent: true),
            toolbarExtras: [_rt_RotatePanToggle(controller: _viewCtrl)],
            hint: next == -1
                ? null
                : _rt_StepHint(
                    number: '${next + 1}',
                    text: (_missionList[next] as Map)['sub'] as String,
                    label: (_missionList[next] as Map)['text'] as String,
                  ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.checklist,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              onFrame: _onFrame,
              onTap: _onTap,
            ),
            canvasOverlays: [
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      _rt_HudCard(value: _formulaLabel, label: _tx.s('nav.0')),
                      if (_station == _Station.lattice)
                        _rt_HudCard(
                          value: _quantity >= _latticeMax
                              ? _tx.s('s2.mole')
                              : '${_quantity * _quantity * _quantity}',
                          label: _tx.s('s2.qty'),
                        ),
                      if (_station == _Station.stress)
                        _rt_HudCard(
                          value: '${_temperature.round()} K',
                          label: _tx.s('s3.temp'),
                        ),
                      if (_station == _Station.conductivity)
                        _rt_HudCard(
                          value: _switchOn && _dissolved ? 'ON' : 'OFF',
                          label: _tx.s('s4.labels.bulb'),
                          color: _switchOn && _dissolved
                              ? _rt_Tw.green500
                              : _rt_Tw.red500,
                        ),
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

  String get _formulaLabel {
    if (!_transferred) return _mgMode ? 'Mg + 2Cl' : 'Na + Cl';
    return _mgMode ? 'MgCl₂' : 'NaCl';
  }

  Widget _exploreTab() {
    final nav = _tx.list('nav');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(title: _tx.s('objLabel'), desc: _tx.s('objDesc')),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('missionsLabel'), icon: Icons.flag),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < nav.length; i++)
                    _stationChip(_Station.values[i], nav[i] as String, i),
                ],
              ),
              const SizedBox(height: 14),
              ..._stationControls(),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.checklist),
              for (var i = 0; i < _missionList.length; i++) _missionRow(i),
              const SizedBox(height: 14),
              // The source's Outcomes tab, kept at the foot of the log.
              _rt_SectionLabel(_tx.s('analysisTitle'), icon: Icons.insights),
              Text(
                '${_tx.s('analysisHeaders.0')} • ${_tx.s('analysisHeaders.1')}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.textFaint,
                ),
              ),
              const SizedBox(height: 6),
              for (final r in _tx.list('rows'))
                _rt_InfoCard(
                  title: (r as Map)['obs'] as String,
                  body: r['out'] as String,
                  icon: Icons.science,
                  leftBorder: true,
                ),
              const SizedBox(height: 8),
              // The source's "Why Learn This?" tab.
              _rt_SectionLabel(_tx.s('contextTitle'), icon: Icons.lightbulb),
              _rt_InfoCard(
                body: _tx.s('contextIntro'),
                leftBorder: true,
                color: _rt_Tw.cyan500,
              ),
              for (final a in _tx.list('contextApps'))
                _rt_InfoCard(
                  title: (a as Map)['title'] as String,
                  body: a['desc'] as String,
                  icon: Icons.auto_awesome,
                  color: _rt_Tw.cyan500,
                ),
              const SizedBox(height: 8),
              // The source's Teacher Guide tab.
              _rt_SectionLabel(_tx.s('teacherTitle'), icon: Icons.school),
              _rt_InfoCard(
                body: _tx.s('teacherIntro'),
                leftBorder: true,
                color: _rt_Tw.violet500,
              ),
              for (final ph in _tx.list('teacherPhases'))
                _rt_InfoCard(
                  title: (ph as Map)['title'] as String,
                  body: ph['desc'] as String,
                  icon: Icons.menu_book,
                  color: _rt_Tw.violet500,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stationChip(_Station s, String label, int index) {
    final on = _station == s;
    return GestureDetector(
      onTap: () => _setStation(s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.teal600 : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? _rt_Tw.teal600 : _rt_Lab.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_missions[index]) ...[
              Icon(
                Icons.check_circle,
                size: 12,
                color: on ? Colors.white : _rt_Tw.green500,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: on ? Colors.white : _rt_Lab.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _stationControls() {
    switch (_station) {
      case _Station.exchange:
        return [
          _rt_SectionLabel(_tx.s('s1.panelTitle'), icon: Icons.tune),
          Row(
            children: [
              Expanded(
                child: _rt_ChoiceButton(
                  label: _tx.s('s1.btnNaCl'),
                  state: !_mgMode
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: () => _setMode(false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _rt_ChoiceButton(
                  label: _tx.s('s1.btnMgCl2'),
                  state: _mgMode
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: () => _setMode(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _rt_InfoCard(
            body: _tx.s('s1.toast'),
            icon: Icons.touch_app,
            leftBorder: true,
          ),
          // Sidebar equivalent of tapping the electron in the scene.
          _rt_ActionButton(
            label: _tx.s('s1.obsTitle'),
            icon: Icons.bolt,
            expand: true,
            done: _transferred,
            onPressed: (_busy || _transferred) ? null : _transferElectrons,
          ),
          if (_transferred) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('s1.obsTitle'),
              body: _mgMode ? _tx.s('s1.obsMg') : _tx.s('s1.obsNaCl'),
              icon: Icons.science,
              leftBorder: true,
            ),
            _rt_ActionButton(
              label: _mgMode ? _tx.s('s1.btnNext') : _tx.s('s1.btnNextMg'),
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: () =>
                  _mgMode ? _setStation(_Station.lattice) : _setMode(true),
            ),
            if (_mgMode)
              const SizedBox(height: 4)
            else
              _rt_ActionButton(
                label: _tx.s('s1.btnNext'),
                icon: Icons.grid_on,
                color: _rt_Tw.slate500,
                expand: true,
                onPressed: () => _setStation(_Station.lattice),
              ),
          ],
        ];
      case _Station.lattice:
        return [
          _rt_SectionLabel(_tx.s('s2.panelTitle'), icon: Icons.grid_4x4),
          Text(
            _tx.s('s2.desc'),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _rt_LabeledSlider(
            label: _tx.s('s2.qty'),
            value: _quantity.toDouble(),
            min: 1,
            max: _latticeMax.toDouble(),
            divisions: _latticeMax - 1,
            valueText: _quantity >= _latticeMax
                ? _tx.s('s2.mole')
                : '${_quantity * _quantity * _quantity} ${_tx.s('s2.molecules')}',
            onChanged: _setQuantity,
          ),
          if (_quantity >= _latticeMax) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('s2.obsTitle'),
              body: _tx.s('s2.obs'),
              icon: Icons.diamond,
              leftBorder: true,
            ),
            _rt_ActionButton(
              label: _tx.s('s2.btnNext'),
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: () => _setStation(_Station.stress),
            ),
          ],
        ];
      case _Station.stress:
        return [
          _rt_SectionLabel(_tx.s('s3.panelTitle'), icon: Icons.construction),
          Row(
            children: [
              Expanded(
                child: _rt_ChoiceButton(
                  label: _tx.s('s3.btnHammer'),
                  state: _stressHammer
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: () => _setStressMode(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _rt_ChoiceButton(
                  label: _tx.s('s3.btnFurnace'),
                  state: !_stressHammer
                      ? _rt_ChoiceState.selected
                      : _rt_ChoiceState.idle,
                  onTap: () => _setStressMode(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_stressHammer) ...[
            // The source's furnace control is a 300-1200 K temperature slider.
            _rt_LabeledSlider(
              label: _tx.s('s3.temp'),
              value: _temperature,
              min: 300,
              max: 1200,
              divisions: 90,
              valueText: '${_temperature.round()} K',
              color: _temperature >= 1074 ? _rt_Tw.red500 : _rt_Tw.teal600,
              onChanged: _busy ? null : _setTemperature,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final k in ['s3.scaleLow', 's3.scaleMp', 's3.scaleHigh'])
                  Text(
                    _tx.s(k),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: _rt_Lab.textFaint,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          _rt_ActionButton(
            label: _stressHammer ? _tx.s('s3.btnStrike') : _tx.s('s3.btnHeat'),
            icon: _stressHammer ? Icons.hardware : Icons.local_fire_department,
            color: _stressHammer ? _rt_Tw.orange600 : _rt_Tw.red600,
            expand: true,
            done: _stressHammer ? _shattered : _melted,
            onPressed: _busy ? null : (_stressHammer ? _strike : _heat),
          ),
          const SizedBox(height: 6),
          _rt_ActionButton(
            label: _rt_CommonStrings.restart,
            icon: Icons.refresh,
            color: _rt_Tw.slate500,
            expand: true,
            onPressed: _busy ? null : _resetStress,
          ),
          if (_shattered || _melted) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: (_stressHammer ? _shattered : false)
                  ? _tx.s('s3.obsHammerTitle')
                  : (_melted && !_stressHammer
                        ? _tx.s('s3.obsFurnaceTitle')
                        : (_shattered
                              ? _tx.s('s3.obsHammerTitle')
                              : _tx.s('s3.obsFurnaceTitle'))),
              body: (_stressHammer && _shattered) || (!_melted && _shattered)
                  ? _tx.s('s3.obsHammer')
                  : _tx.s('s3.obsFurnace'),
              icon: Icons.science,
              leftBorder: true,
            ),
            if (_shattered && _stressHammer)
              // The source's hammer popup offers "Go to Furnace" next.
              _rt_ActionButton(
                label: _tx.s('s3.btnFurnaceLink'),
                icon: Icons.local_fire_department,
                color: _rt_Tw.red600,
                expand: true,
                onPressed: () => _setStressMode(false),
              ),
            const SizedBox(height: 6),
            _rt_ActionButton(
              label: _tx.s('s3.btnNext'),
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: () => _setStation(_Station.conductivity),
            ),
          ],
        ];
      case _Station.conductivity:
        return [
          _rt_SectionLabel(
            _tx.s('s4.panelTitle'),
            icon: Icons.electrical_services,
          ),
          _rt_ActionButton(
            label: _tx.s('s4.btnSwitch'),
            icon: _switchOn ? Icons.toggle_on : Icons.toggle_off,
            color: _switchOn ? _rt_Tw.green600 : _rt_Tw.slate500,
            expand: true,
            onPressed: _toggleSwitch,
          ),
          const SizedBox(height: 6),
          _rt_ActionButton(
            label: _tx.s('s4.btnAddWater'),
            icon: Icons.water_drop,
            color: _rt_Tw.blue600,
            expand: true,
            done: _dissolved,
            // Enabled but guarded: pressing it early explains the gating,
            // exactly like the source's tooltip on the disabled button.
            onPressed: _dissolved ? null : _addWater,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final (color, label) in [
                (_naColor, 'Na⁺'),
                (_clColor, 'Cl⁻'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _rt_Lab.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_switchOn && _dissolved) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('s4.obsTitle'),
              body: _tx.s('s4.obs'),
              icon: Icons.insights,
              leftBorder: true,
            ),
          ],
        ];
    }
  }

  Widget _missionRow(int i) {
    final m = _missionList[i] as Map;
    final done = _missions[i];
    final active = i == _missions.indexWhere((x) => !x);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: done
            ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
            : (active
                  ? _rt_Lab.tinted(_rt_Tw.teal50, _rt_Tw.teal600)
                  : _rt_Lab.surface),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done
              ? _rt_Tw.green500
              : (active ? _rt_Tw.teal600 : _rt_Lab.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done
                ? _rt_Tw.green500
                : (active ? _rt_Tw.teal400 : _rt_Lab.textFaint),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m['text'] as String,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: done
                        ? _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)
                        : _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m['sub'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: _rt_Lab.textMuted,
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
}
