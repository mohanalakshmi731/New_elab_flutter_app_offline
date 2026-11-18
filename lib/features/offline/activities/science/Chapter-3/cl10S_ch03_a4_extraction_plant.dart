// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 3.4: The Extraction Plant
// Converted from Cl10S-Ch3-A4-TheExtractionPlant.html (React + three.js -> mini3d).
//
// Four zones, each its own scene group: the roasting pit (HgS -> Hg by heat
// alone), the reduction furnace (route ZnS/ZnCO3 correctly, then reduce with
// coke), electrolytic refining of copper, and alloying 24K gold down to 22K.

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
  static const teal500 = Color(0xFF14B8A6);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const teal900 = Color(0xFF134E4A);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red700 = Color(0xFFB91C1C);
  static const orange600 = Color(0xFFEA580C);
  static const amber600 = Color(0xFFD97706);
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
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? valueText;
  final ValueChanged<double>? onChanged;
  final Color color = _rt_Tw.teal600;

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
  static double outBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }
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

  /// THREE.TorusGeometry(radius, tube, radialSegments, tubularSegments, arc).
  factory _rt_Geometry3D.torus(
    double radius,
    double tube, {
    int radialSegments = 10,
    int tubularSegments = 36,
    double arc = math.pi * 2,
  }) {
    final verts = <_rt_V3>[];
    for (var j = 0; j <= radialSegments; j++) {
      for (var i = 0; i <= tubularSegments; i++) {
        final u = i / tubularSegments * arc;
        final v = j / radialSegments * math.pi * 2;
        verts.add(
          _rt_V3(
            (radius + tube * math.cos(v)) * math.cos(u),
            (radius + tube * math.cos(v)) * math.sin(u),
            tube * math.sin(v),
          ),
        );
      }
    }
    final faces = <List<int>>[];
    for (var j = 1; j <= radialSegments; j++) {
      for (var i = 1; i <= tubularSegments; i++) {
        final a = (tubularSegments + 1) * j + i - 1;
        final b = (tubularSegments + 1) * (j - 1) + i - 1;
        final c = (tubularSegments + 1) * (j - 1) + i;
        final d = (tubularSegments + 1) * j + i;
        faces.add([a, b, c, d]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.OctahedronGeometry(radius).
  factory _rt_Geometry3D.octahedron(double r) {
    final v = [
      _rt_V3(r, 0, 0),
      _rt_V3(-r, 0, 0),
      _rt_V3(0, r, 0),
      _rt_V3(0, -r, 0),
      _rt_V3(0, 0, r),
      _rt_V3(0, 0, -r),
    ];
    return _rt_Geometry3D(v, [
      [0, 2, 4], [0, 4, 3], [0, 3, 5], [0, 5, 2], //
      [1, 2, 5], [1, 5, 3], [1, 3, 4], [1, 4, 2],
    ]);
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
  _rt_Mesh3D(this.geometry, this.material);

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
  _rt_Line3D(this.points);

  List<_rt_V3> points;
  Color color = const Color(0xFFFFFFFF);
  double width = 2;
  double opacity = 1;
  bool dashed = false;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments = false;
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
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
  final void Function(_rt_SceneEvent e)? onTap = null;
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
      'title': 'Extraction Plant',
      'subtitle': 'Class 10 • Metals and Non-metals',
      'button': 'Initialize Simulation',
      'footnote': 'Roast • Reduce • Refine • Alloy',
    },
    'headerTitle': 'Extraction Plant',
    'headerSubtitle': 'NCERT Class 10 • Metals and Non-metals',
    'tabs': {'explore': 'Mission Objectives', 'analysis': 'Assessment'},
    'nav': ['Roasting Pit', 'Reduction', 'Refining', 'Alloying'],
    'objLabel': 'Mission Objective',
    'objDesc':
        'Process different ores based on their chemical reactivity to extract pure metal, then modify their physical properties through alloying.',
    'missionsLabel': 'Follow the production line carefully:',
    'ui': {
      'nextStation': 'Next Station',
      'processComplete': 'Process Complete',
      'processLog': 'Process Log',
      'heat': 'Burner Heat',
      'high': 'High',
      'low': 'Low',
      'testOtherOre': 'Test Other Ore',
      'awaiting': 'Awaiting',
      'purification': 'Purification Progress',
      'exam': "The Metallurgist's Exam",
      'tryAgain': 'Try Again',
      'correct': 'Correct!',
      'incorrect': 'Incorrect.',
      'check': 'Submit Answer',
      'finish': 'Finish Experiment',
      'toggleLabels': 'Toggle Labels',
    },
    'missions': [
      {
        'text': 'Zone 1: Extract Mercury from Cinnabar',
        'sub':
            'ACTION: Heat Cinnabar (HgS). OBSERVE: red ore darkens to the oxide, then silver liquid mercury pools. Note the SO₂ fumes.',
      },
      {
        'text': 'Zone 2: Route and Extract Zinc',
        'sub':
            'ACTION: Choose Roasting for the sulphide and Calcination for the carbonate to get ZnO, then reduce with coke.',
      },
      {
        'text': 'Zone 3: Purify Copper via Electrolysis',
        'sub':
            'ACTION: Turn on the power. OBSERVE: the thick impure anode shrinks, the cathode grows, anode mud settles.',
      },
      {
        'text': 'Zone 4: Forge 22-Carat Gold',
        'sub':
            'ACTION: Test 24K gold (it will fail). Melt it, mix in 2 parts copper, and test the 22K alloy.',
      },
    ],
    's1': {
      'title': 'Zone 1: The Roasting Pit',
      'desc': 'Extract Mercury from Cinnabar (HgS) by heating alone.',
      'toast': 'Slide the heat dial to High to start roasting the ore.',
      'eq0': '2HgS(s) + 3O₂(g) → ?',
      'eq1': '2HgS(s) + 3O₂(g) → 2HgO(s) + 2SO₂↑',
      'eq2': '2HgO(s) → 2Hg(l) + O₂↑',
      'labels': {
        'ore': 'Cinnabar (HgS)',
        'oxide': 'Mercuric Oxide',
        'metal': 'Mercury (Hg)',
        'gas': 'SO₂ Fumes',
      },
      'obs':
          'Learning outcome: oxides of metals low in the reactivity series can be reduced to the metal by heating alone — no reducing agent is needed.',
    },
    's2': {
      'title': 'Zone 2: Reduction Furnace',
      'desc':
          'Zinc sits in the middle of the reactivity series. Convert ore to oxide, then reduce.',
      'oreA': 'Zinc Blende (ZnS)',
      'oreB': 'Calamine (ZnCO₃)',
      'air': 'Roasting (Excess Air)',
      'noAir': 'Calcination (Limited Air)',
      'process': 'Process Ore',
      'coke': 'Add Coke & Reduce',
      'eqRoast': '2ZnS + 3O₂ → 2ZnO + 2SO₂',
      'eqCalc': 'ZnCO₃ → ZnO + CO₂',
      'eqReduce': 'ZnO + C → Zn + CO',
      'step1': 'Step 1: select an ore and the correct processing method.',
      'step2':
          "Step 2: the ore is now Zinc Oxide. Add coke to extract the liquid metal.",
      'wrong':
          'Incorrect logic! Sulphide (ZnS) requires excess air (Roasting). Carbonate (ZnCO₃) requires limited air (Calcination).',
      'obsRoast':
          'Roasting complete: the sulphide ore heated in excess air became the oxide.',
      'obsCalc':
          'Calcination complete: the carbonate ore heated in limited air became the oxide.',
      'obsReduce':
          'Reduction complete: carbon grabbed the oxygen from zinc oxide.',
      'allDone': 'All ores processed successfully. Move to the next station.',
      'labels': {
        'zno': 'ZnO (White Powder)',
        'zn': 'Molten Zinc (Zn)',
        'coke': 'Coke (Carbon)',
      },
    },
    's3': {
      'title': 'Zone 3: Electrolytic Refinery',
      'desc': 'Turn Blister Copper (98%) into Electric Grade Copper (99.99%).',
      'switch': 'Power Supply',
      'toast': 'Turn on the power supply to start the current flow.',
      'eqAnode': 'Anode: Cu → Cu²⁺ + 2e⁻',
      'eqCathode': 'Cathode: Cu²⁺ + 2e⁻ → Cu',
      'labels': {
        'anode': 'Impure Anode (+)',
        'cathode': 'Pure Cathode (−)',
        'mud': 'Anode Mud',
        'ions': 'Cu²⁺ Ions',
      },
      'obs':
          'Process complete: copper ions migrated to the cathode, thickening it with 99.99% pure copper. The insoluble impurities settle below the anode as anode mud.',
    },
    's4': {
      'title': 'Zone 4: The Alloy Smith',
      'desc':
          'Pure gold (24 carat) is very soft. It must be alloyed with silver or copper to make usable jewellery.',
      'testSoft': 'Mold Ring (24K Gold)',
      'mix': 'Melt & Mix (Add Copper)',
      'testHard': 'Mold Ring (22K Alloy)',
      'toast':
          'Step 1: the softness test — try to mold the pure 24K gold bar into a ring.',
      'obsSoft':
          'Too soft! It bent out of shape instantly. Pure gold cannot hold its shape.',
      'obsHard':
          'Perfect! The 22K gold holds its shape. 22 parts of pure gold are alloyed with 2 parts of either copper or silver.',
      'labels': {
        'gold24': '24K Pure Gold Bar',
        'gold22': '22K Gold Alloy',
        'copper': 'Copper (2 parts)',
        'ring': 'Jewellery Ring',
      },
    },
    'analysisTitle': 'Assessment',
    'analysisHeaders': [
      'Industrial Process',
      'Core Scientific Principle / Equation',
    ],
    'contextTitle': 'Theory',
    'contextIntro':
        "Metals don't just pop out of the ground as shiny bars. They are locked away in rocks called ores. The method of extraction strictly depends on the metal's position in the Activity Series.",
    'contextApps': [
      {
        'title': 'Low Reactivity (Mercury)',
        'desc':
            'Metals low in the activity series are very unreactive. Their oxides can be reduced to metals by heating alone. Example: Cinnabar (HgS) to Mercury (Hg).',
      },
      {
        'title': 'Middle Reactivity (Zinc)',
        'desc':
            "These metals (Fe, Zn, Pb) occur as sulphides or carbonates. It's easier to obtain a metal from its oxide, so sulphides are Roasted and carbonates are Calcinated before reduction with carbon.",
      },
      {
        'title': 'High Reactivity (Copper Refining)',
        'desc':
            "To get 99.99% pure metal for electric wires we use electrolytic refining. Pure metal deposits at the cathode while impurities fall as 'anode mud'.",
      },
      {
        'title': 'Corrosion & Alloying',
        'desc':
            'Pure 24-carat gold is too soft for jewellery. It is alloyed with silver or copper (22 parts gold to 2 parts copper) to make it hard and durable.',
      },
    ],
    'teacherTitle': 'Teacher Guide',
    'teacherIntro':
        'This interactive simulation covers the extraction of metals based on their reactivity and the modification of properties through alloying. The student acts as the Plant Manager, making process-routing decisions.',
    'teacherPhases': [
      {
        'title': 'Phase 1: The Roasting Pit',
        'desc':
            'Students observe that low-reactivity metal ores (HgS) need no reducing agent. High heat alone drives the sequence Sulphide → Oxide → Liquid Metal.',
      },
      {
        'title': 'Phase 2: The Reduction Furnace',
        'desc':
            'Students must route the ores logically: Zinc Blende (ZnS) is roasted in excess air, Calamine (ZnCO₃) is calcinated in limited air. Both yield ZnO, which coke then reduces to molten zinc.',
      },
      {
        'title': 'Phase 3: Electrolytic Refinery',
        'desc':
            'A micro-view of electrolysis. Emphasise the half-reactions: the thick impure anode dissolves (Cu → Cu²⁺ + 2e⁻) and deposits on the thin pure cathode. Reinforce the idea of anode mud.',
      },
      {
        'title': 'Phase 4: Alloying',
        'desc':
            'A practical demonstration of changing physical properties: students fail to mold 24K gold, forcing them to melt and mix it with copper into a workable 22K alloy.',
      },
    ],
    'rows': [
      {
        'obs': 'Roasting (ZnS / HgS)',
        'out':
            'Sulphide ores are converted into oxides by heating strongly in excess air. (2ZnS + 3O₂ → 2ZnO + 2SO₂)',
      },
      {
        'obs': 'Calcination (ZnCO₃)',
        'out':
            'Carbonate ores become oxides by heating strongly in limited air. (ZnCO₃ → ZnO + CO₂)',
      },
      {
        'obs': 'Reduction (with Carbon)',
        'out':
            'Metal oxides are reduced using a reducing agent like carbon. (ZnO + C → Zn + CO)',
      },
      {
        'obs': 'Electrolytic Refining',
        'out':
            'Impure metal is the anode, pure metal the cathode. Current dissolves the anode into solution, which deposits on the cathode.',
      },
      {
        'obs': 'Alloying',
        'out':
            'A homogeneous mixture of two or more metals. It changes physical properties, making soft metals like pure gold hard and durable.',
      },
    ],
    'exam': {
      'question':
          'You are given a carbonate ore (MCO₃) of a middle-reactivity metal. How do you extract the pure metal?',
      'options': [
        'Heat it strongly with excess air (Roasting), then electrolyse it.',
        'Heat it strongly with limited air (Calcination), then reduce it with carbon.',
        'Heat it alone without any reducing agent.',
        'Dissolve it in acid and use electrolytic refining.',
      ],
      'reason':
          'Carbonate ores require calcination (heating in limited air) to drive off carbon dioxide and form the metal oxide. A middle-reactivity metal oxide is then reduced using carbon (coke).',
    },
    'complete': {
      'title': 'Plant Manager Certified!',
      'msg':
          'You extracted mercury by heat alone, routed and reduced both zinc ores, refined copper to 99.99%, and alloyed gold into workable 22K.',
    },
  },
  'hi': {
    'intro': {
      'title': 'निष्कर्षण संयंत्र',
      'subtitle': 'कक्षा 10 • धातु और अधातु',
      'button': 'सिमुलेशन शुरू करें',
      'footnote': 'भर्जन • अपचयन • शोधन • मिश्रातु',
    },
    'headerTitle': 'निष्कर्षण संयंत्र',
    'headerSubtitle': 'एनसीईआरटी कक्षा 10 • धातु और अधातु',
    'tabs': {'explore': 'मिशन उद्देश्य', 'analysis': 'मूल्यांकन'},
    'nav': ['भर्जन कुंड', 'अपचयन', 'शोधन', 'मिश्रातु'],
    'objLabel': 'मिशन का उद्देश्य',
    'objDesc':
        'अयस्कों की रासायनिक अभिक्रियाशीलता के अनुसार उनका प्रसंस्करण करके शुद्ध धातु निकालें, फिर मिश्रातु बनाकर उनके भौतिक गुण बदलें।',
    'missionsLabel': 'उत्पादन लाइन का ध्यानपूर्वक पालन करें:',
    'ui': {
      'nextStation': 'अगला स्टेशन',
      'processComplete': 'प्रक्रिया पूर्ण',
      'processLog': 'प्रक्रिया लॉग',
      'heat': 'बर्नर ऊष्मा',
      'high': 'उच्च',
      'low': 'निम्न',
      'testOtherOre': 'दूसरा अयस्क जांचें',
      'awaiting': 'प्रतीक्षारत',
      'purification': 'शोधन प्रगति',
      'exam': 'धातुकर्मी परीक्षा',
      'tryAgain': 'पुनः प्रयास करें',
      'correct': 'सही!',
      'incorrect': 'गलत।',
      'check': 'उत्तर जमा करें',
      'finish': 'प्रयोग समाप्त करें',
      'toggleLabels': 'लेबल टॉगल करें',
    },
    'missions': [
      {
        'text': 'क्षेत्र 1: सिनेबार से पारा निकालें',
        'sub':
            'करें: सिनेबार (HgS) गर्म करें। देखें: लाल अयस्क काला ऑक्साइड बनता है, फिर चांदी जैसा तरल पारा जमा होता है। SO₂ धुआं देखें।',
      },
      {
        'text': 'क्षेत्र 2: जिंक का मार्गन और निष्कर्षण',
        'sub':
            'करें: सल्फाइड के लिए भर्जन और कार्बोनेट के लिए निस्तापन चुनें ताकि ZnO बने, फिर कोक से अपचयन करें।',
      },
      {
        'text': 'क्षेत्र 3: विद्युत अपघटन से तांबा शोधन',
        'sub':
            'करें: बिजली चालू करें। देखें: अशुद्ध एनोड घटता है, कैथोड बढ़ता है, एनोड मड नीचे बैठता है।',
      },
      {
        'text': 'क्षेत्र 4: 22 कैरेट सोना बनाएं',
        'sub':
            'करें: 24K सोना जांचें (विफल होगा)। उसे पिघलाकर 2 भाग तांबा मिलाएं और 22K मिश्रातु जांचें।',
      },
    ],
    's1': {
      'title': 'क्षेत्र 1: भर्जन कुंड',
      'desc': 'केवल गर्म करके सिनेबार (HgS) से पारा निकालें।',
      'toast': 'अयस्क का भर्जन शुरू करने के लिए ऊष्मा डायल को उच्च पर ले जाएं।',
      'eq0': '2HgS(s) + 3O₂(g) → ?',
      'eq1': '2HgS(s) + 3O₂(g) → 2HgO(s) + 2SO₂↑',
      'eq2': '2HgO(s) → 2Hg(l) + O₂↑',
      'labels': {
        'ore': 'सिनेबार (HgS)',
        'oxide': 'मर्क्यूरिक ऑक्साइड',
        'metal': 'पारा (Hg)',
        'gas': 'SO₂ धुआं',
      },
      'obs':
          'सीख: अभिक्रियाशीलता श्रेणी में नीचे की धातुओं के ऑक्साइड केवल गर्म करने से ही धातु में अपचयित हो जाते हैं — किसी अपचायक की आवश्यकता नहीं।',
    },
    's2': {
      'title': 'क्षेत्र 2: अपचयन भट्ठी',
      'desc':
          'जिंक अभिक्रियाशीलता श्रेणी के मध्य में है। अयस्क को ऑक्साइड बनाएं, फिर अपचयन करें।',
      'oreA': 'जिंक ब्लेंड (ZnS)',
      'oreB': 'कैलामाइन (ZnCO₃)',
      'air': 'भर्जन (अधिक वायु)',
      'noAir': 'निस्तापन (सीमित वायु)',
      'process': 'अयस्क संसाधित करें',
      'coke': 'कोक डालें और अपचयन करें',
      'eqRoast': '2ZnS + 3O₂ → 2ZnO + 2SO₂',
      'eqCalc': 'ZnCO₃ → ZnO + CO₂',
      'eqReduce': 'ZnO + C → Zn + CO',
      'step1': 'चरण 1: एक अयस्क और सही प्रसंस्करण विधि चुनें।',
      'step2':
          'चरण 2: अयस्क अब जिंक ऑक्साइड है। तरल धातु निकालने के लिए कोक डालें।',
      'wrong':
          'गलत तर्क! सल्फाइड (ZnS) के लिए अधिक वायु (भर्जन) चाहिए। कार्बोनेट (ZnCO₃) के लिए सीमित वायु (निस्तापन) चाहिए।',
      'obsRoast':
          'भर्जन पूर्ण: सल्फाइड अयस्क अधिक वायु में गर्म होकर ऑक्साइड बन गया।',
      'obsCalc':
          'निस्तापन पूर्ण: कार्बोनेट अयस्क सीमित वायु में गर्म होकर ऑक्साइड बन गया।',
      'obsReduce': 'अपचयन पूर्ण: कार्बन ने जिंक ऑक्साइड से ऑक्सीजन ले ली।',
      'allDone': 'सभी अयस्क सफलतापूर्वक संसाधित। अगले स्टेशन पर जाएं।',
      'labels': {
        'zno': 'ZnO (सफेद चूर्ण)',
        'zn': 'पिघला जिंक (Zn)',
        'coke': 'कोक (कार्बन)',
      },
    },
    's3': {
      'title': 'क्षेत्र 3: विद्युत अपघटनी शोधनशाला',
      'desc': 'ब्लिस्टर कॉपर (98%) को विद्युत ग्रेड कॉपर (99.99%) में बदलें।',
      'switch': 'विद्युत आपूर्ति',
      'toast': 'धारा प्रवाह शुरू करने के लिए विद्युत आपूर्ति चालू करें।',
      'eqAnode': 'एनोड: Cu → Cu²⁺ + 2e⁻',
      'eqCathode': 'कैथोड: Cu²⁺ + 2e⁻ → Cu',
      'labels': {
        'anode': 'अशुद्ध एनोड (+)',
        'cathode': 'शुद्ध कैथोड (−)',
        'mud': 'एनोड मड',
        'ions': 'Cu²⁺ आयन',
      },
      'obs':
          'प्रक्रिया पूर्ण: कॉपर आयन कैथोड पर जाकर 99.99% शुद्ध तांबे की परत बनाते हैं। अघुलनशील अशुद्धियाँ एनोड के नीचे एनोड मड के रूप में बैठ जाती हैं।',
    },
    's4': {
      'title': 'क्षेत्र 4: मिश्रातु कर्मशाला',
      'desc':
          'शुद्ध सोना (24 कैरेट) बहुत नरम होता है। उपयोगी आभूषण के लिए उसमें चांदी या तांबा मिलाना पड़ता है।',
      'testSoft': 'अंगूठी ढालें (24K सोना)',
      'mix': 'पिघलाएं और मिलाएं (तांबा डालें)',
      'testHard': 'अंगूठी ढालें (22K मिश्रातु)',
      'toast':
          'चरण 1: कोमलता परीक्षण — शुद्ध 24K सोने की छड़ को अंगूठी में ढालने का प्रयास करें।',
      'obsSoft':
          'बहुत नरम! यह तुरंत मुड़ गया। शुद्ध सोना अपना आकार नहीं रख पाता।',
      'obsHard':
          'उत्तम! 22K सोना अपना आकार बनाए रखता है। 22 भाग शुद्ध सोने में 2 भाग तांबा या चांदी मिलाई जाती है।',
      'labels': {
        'gold24': '24K शुद्ध सोने की छड़',
        'gold22': '22K सोना मिश्रातु',
        'copper': 'तांबा (2 भाग)',
        'ring': 'आभूषण अंगूठी',
      },
    },
    'analysisTitle': 'मूल्यांकन',
    'analysisHeaders': [
      'औद्योगिक प्रक्रिया',
      'मूल वैज्ञानिक सिद्धांत / समीकरण',
    ],
    'contextTitle': 'सिद्धांत',
    'contextIntro':
        'धातुएँ जमीन से चमकदार छड़ों के रूप में नहीं निकलतीं। वे अयस्क नामक चट्टानों में बंद होती हैं। निष्कर्षण की विधि सक्रियता श्रेणी में धातु की स्थिति पर निर्भर करती है।',
    'contextApps': [
      {
        'title': 'कम अभिक्रियाशीलता (पारा)',
        'desc':
            'सक्रियता श्रेणी में नीचे की धातुएँ बहुत कम अभिक्रियाशील होती हैं। इनके ऑक्साइड केवल गर्म करने से धातु में अपचयित हो जाते हैं। उदाहरण: सिनेबार (HgS) से पारा (Hg)।',
      },
      {
        'title': 'मध्य अभिक्रियाशीलता (जिंक)',
        'desc':
            'ये धातुएँ सल्फाइड या कार्बोनेट रूप में मिलती हैं। सल्फाइड का भर्जन और कार्बोनेट का निस्तापन करके ऑक्साइड बनाया जाता है, फिर कार्बन से अपचयन होता है।',
      },
      {
        'title': 'उच्च शुद्धिकरण (तांबा)',
        'desc':
            'बिजली के तारों के लिए 99.99% शुद्ध धातु पाने के लिए विद्युत अपघटनी शोधन किया जाता है। शुद्ध धातु कैथोड पर जमती है और अशुद्धियाँ एनोड मड बनकर बैठ जाती हैं।',
      },
      {
        'title': 'संक्षारण और मिश्रातु',
        'desc':
            'शुद्ध 24-कैरेट सोना आभूषण के लिए बहुत नरम है। इसे कठोर और टिकाऊ बनाने के लिए चांदी या तांबे (22 भाग सोना, 2 भाग तांबा) के साथ मिश्रित किया जाता है।',
      },
    ],
    'teacherTitle': 'शिक्षक गाइड',
    'teacherIntro':
        'यह सिमुलेशन अभिक्रियाशीलता के आधार पर धातुओं के निष्कर्षण और मिश्रातु द्वारा गुण-परिवर्तन को कवर करता है। छात्र संयंत्र प्रबंधक बनकर प्रक्रिया-मार्गन के निर्णय लेता है।',
    'teacherPhases': [
      {
        'title': 'चरण 1: भर्जन कुंड',
        'desc':
            'छात्र देखते हैं कि कम अभिक्रियाशील अयस्कों (HgS) को अपचायक की आवश्यकता नहीं — केवल उच्च ताप से सल्फाइड → ऑक्साइड → द्रव धातु बनता है।',
      },
      {
        'title': 'चरण 2: अपचयन भट्ठी',
        'desc':
            'जिंक ब्लेंड (ZnS) का अधिक वायु में भर्जन और कैलामाइन (ZnCO₃) का सीमित वायु में निस्तापन आवश्यक है। दोनों से ZnO मिलता है, जिसे कोक पिघले जिंक में अपचयित करता है।',
      },
      {
        'title': 'चरण 3: विद्युत अपघटनी शोधनशाला',
        'desc':
            'विद्युत अपघटन का सूक्ष्म दृश्य। अर्ध-अभिक्रियाओं पर जोर दें: मोटा अशुद्ध एनोड घुलता है (Cu → Cu²⁺ + 2e⁻) और पतले शुद्ध कैथोड पर जमा होता है। एनोड मड की अवधारणा दोहराएँ।',
      },
      {
        'title': 'चरण 4: मिश्रातु',
        'desc':
            'भौतिक गुण बदलने का व्यावहारिक प्रदर्शन: 24K सोना ढालने में विफल होकर छात्र उसे तांबे के साथ पिघलाकर उपयोगी 22K मिश्रातु बनाते हैं।',
      },
    ],
    'rows': [
      {
        'obs': 'भर्जन (ZnS / HgS)',
        'out':
            'सल्फाइड अयस्क अधिक वायु में तेज गर्म करने पर ऑक्साइड बन जाते हैं। (2ZnS + 3O₂ → 2ZnO + 2SO₂)',
      },
      {
        'obs': 'निस्तापन (ZnCO₃)',
        'out':
            'कार्बोनेट अयस्क सीमित वायु में तेज गर्म करने पर ऑक्साइड बनते हैं। (ZnCO₃ → ZnO + CO₂)',
      },
      {
        'obs': 'कार्बन द्वारा अपचयन',
        'out':
            'धातु ऑक्साइड कार्बन जैसे अपचायक से धातु में अपचयित होते हैं। (ZnO + C → Zn + CO)',
      },
      {
        'obs': 'विद्युत अपघटनी शोधन',
        'out':
            'अशुद्ध धातु एनोड और शुद्ध धातु कैथोड बनाई जाती है। धारा एनोड को घोलती है और धातु कैथोड पर जमा होती है।',
      },
      {
        'obs': 'मिश्रातु बनाना',
        'out':
            'दो या अधिक धातुओं का समांगी मिश्रण। यह भौतिक गुण बदलकर शुद्ध सोने जैसी नरम धातु को कठोर और टिकाऊ बनाता है।',
      },
    ],
    'exam': {
      'question':
          'आपको मध्यम अभिक्रियाशीलता वाली धातु का कार्बोनेट अयस्क (MCO₃) दिया गया है। शुद्ध धातु कैसे निकालेंगे?',
      'options': [
        'अधिक वायु में तेज गर्म करें (भर्जन), फिर विद्युत अपघटन करें।',
        'सीमित वायु में तेज गर्म करें (निस्तापन), फिर कार्बन से अपचयन करें।',
        'बिना किसी अपचायक के केवल गर्म करें।',
        'अम्ल में घोलकर विद्युत अपघटनी शोधन करें।',
      ],
      'reason':
          'कार्बोनेट अयस्कों के लिए निस्तापन (सीमित वायु में गर्म करना) आवश्यक है ताकि कार्बन डाइऑक्साइड निकल जाए और धातु ऑक्साइड बने। मध्यम अभिक्रियाशीलता वाली धातु के ऑक्साइड को फिर कार्बन (कोक) से अपचयित किया जाता है।',
    },
    'complete': {
      'title': 'संयंत्र प्रबंधक प्रमाणित!',
      'msg':
          'आपने केवल ऊष्मा से पारा निकाला, दोनों जिंक अयस्कों का सही मार्गन और अपचयन किया, तांबे को 99.99% तक शोधित किया, और सोने को उपयोगी 22K मिश्रातु बनाया।',
    },
  },
});

const _cinnabar = Color(0xFFDC2626);
const _mercuricOxide = Color(0xFF1F2937);
const _mercury = Color(0xFFD1D5DB);
const _znS = Color(0xFF9CA3AF);
const _znCO3 = Color(0xFFD6C7A1);
const _znO = Color(0xFFF8FAFC);
const _moltenZn = Color(0xFFFBBF24);
const _copper = Color(0xFFB87333);
const _gold = Color(0xFFE6B800);
const _anodeMud = Color(0xFF78350F);

enum _Zone { roasting, reduction, refining, alloying }

class Cl10SCh03A4ExtractionPlantPage extends StatefulWidget {
  const Cl10SCh03A4ExtractionPlantPage({super.key});

  @override
  State<Cl10SCh03A4ExtractionPlantPage> createState() =>
      _Cl10SCh03A4ExtractionPlantPageState();
}

class _Cl10SCh03A4ExtractionPlantPageState
    extends State<Cl10SCh03A4ExtractionPlantPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1B1A2E), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 5, 24),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final math.Random _rng = math.Random(13);

  late final _rt_Node3D _gRoast;
  late final _rt_Node3D _gReduce;
  late final _rt_Node3D _gRefine;
  late final _rt_Node3D _gAlloy;

  /// Every scene label, so the toolbar's tag button can hide them all
  /// (the source's Toggle Labels tool).
  final List<_rt_Label3D> _labels = [];
  bool _showLabels = true;

  // Zone 1.
  final _rt_Material3D _oreMat = _rt_Material3D(
    color: _cinnabar,
    shininess: 0.35,
  );
  late final _rt_Node3D _mercuryPool;
  late final _rt_Node3D _oreHeap;
  final List<_rt_Node3D> _fumes = [];
  late final _rt_Node3D _pitFlame;
  late final _rt_Label3D _roastLabel;
  late final _rt_Label3D _gasLabel;
  bool _roastObsShown = false;

  // Zone 2.
  final _rt_Material3D _chargeMat = _rt_Material3D(
    color: _znS,
    shininess: 0.35,
  );
  late final _rt_Node3D _charge;
  late final _rt_Node3D _cokePile;
  late final _rt_Node3D _zincPool;

  // Zone 3.
  late final _rt_Node3D _anode;
  late final _rt_Node3D _cathode;
  late final _rt_Node3D _mud;
  final List<({_rt_Node3D node, double phase})> _cuIons = [];

  // Zone 4.
  late final _rt_Node3D _goldBar;
  late final _rt_Node3D _copperBits;
  late final _rt_Node3D _ring;
  final _rt_Material3D _goldMat = _rt_Material3D(
    color: _gold,
    shininess: 0.85,
    metalness: 0.7,
  );
  late final _rt_Label3D _goldLabel;
  late final _rt_Label3D _copperLabel;
  late final _rt_Label3D _ringLabel;
  late final _rt_Label3D _cokeLabel;
  late final _rt_Label3D _znLabel;

  double _lastZap = -1;

  // --- LAB STATE ---
  _Zone _zone = _Zone.roasting;
  bool _busy = false;
  double _clock = 0;

  double _heat = 0;
  int _roastStage = 0; // 0 ore, 1 oxide, 2 mercury

  int? _ore; // 0 = ZnS, 1 = ZnCO3
  int? _method; // 0 = roasting, 1 = calcination
  bool _oxideMade = false;
  bool _zincMade = false;
  final Set<int> _oresDone = {};

  bool _power = false;
  double _purity = 0;

  bool _softTested = false;
  bool _alloyed = false;
  bool _ringMade = false;

  int? _examChoice;
  bool _examChecked = false;

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
    _setZone(_Zone.roasting, silent: true);
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

  /// Adds a label to [group] and registers it for the visibility toggle.
  _rt_Label3D _mkLabel(
    _rt_Node3D group,
    String text,
    _rt_V3 pos, {
    double height = 0.85,
    Color background = const Color(0xE6334155),
  }) {
    final l = _rt_Label3D(
      text,
      position: pos,
      worldHeight: height,
      background: background,
      color: Colors.white,
    );
    group.add(l);
    _labels.add(l);
    return l;
  }

  // ------------------------------------------------------------ scene ---
  void _initScene() {
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(6, 12, 8), intensity: 0.85),
    ]);
    _gRoast = _rt_Node3D(name: 'roast');
    _gReduce = _rt_Node3D(name: 'reduce');
    _gRefine = _rt_Node3D(name: 'refine');
    _gAlloy = _rt_Node3D(name: 'alloy');
    for (final g in [_gRoast, _gReduce, _gRefine, _gAlloy]) {
      _scene.add(g);
    }
    _buildRoast();
    _buildReduce();
    _buildRefine();
    _buildAlloy();
  }

  void _buildRoast() {
    final brick = _rt_Material3D(
      color: const Color(0xFF7C2D12),
      shininess: 0.25,
    );
    // Open retort: a brick pit with the ore heaped inside.
    _gRoast.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(6, 5, 2, segments: 28), brick)
        ..position.y = -4
        ..pickable = false,
    );
    _gRoast.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(5.6, 5.6, 2.4, segments: 28, openEnded: true),
          _rt_Material3D(
            color: const Color(0xFF9A3412),
            shininess: 0.2,
            doubleSided: true,
          ),
        )
        ..position.y = -2.1
        ..pickable = false,
    );

    _oreHeap = _rt_Node3D(name: 'ore');
    for (var i = 0; i < 26; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final r = _rng.nextDouble() * 3.4;
      _oreHeap.add(
        _rt_Mesh3D(
            _rt_Geometry3D.octahedron(0.5 + _rng.nextDouble() * 0.3),
            _oreMat,
          )
          ..position.set(
            math.cos(a) * r,
            -2.6 + _rng.nextDouble() * 0.7,
            math.sin(a) * r,
          ),
      );
    }
    _gRoast.add(_oreHeap);

    // Mercury collects as a shallow silver pool.
    _mercuryPool = _rt_Mesh3D(
      _rt_Geometry3D.cylinder(3.6, 3.6, 0.5, segments: 28),
      _rt_Material3D(color: _mercury, shininess: 0.95, metalness: 0.9),
    )..position.y = -2.7;
    _mercuryPool.visible = false;
    _gRoast.add(_mercuryPool);

    _pitFlame = _rt_Node3D(name: 'pitFlame')..position.y = -5.4;
    _pitFlame.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cone(2.6, 2.2, segments: 20),
        _rt_Material3D(
          color: const Color(0xFFF97316),
          opacity: 0.75,
          unlit: true,
        ),
      ),
    );
    _pitFlame.visible = false;
    _gRoast.add(_pitFlame);

    final fumeMat = _rt_Material3D(
      color: const Color(0xFFD9F99D),
      opacity: 0.5,
      unlit: true,
    );
    for (var i = 0; i < 18; i++) {
      final f = _rt_Sphere3D(0.45, fumeMat);
      f.visible = false;
      f.pickable = false;
      _gRoast.add(f);
      _fumes.add(f);
    }
    _roastLabel = _mkLabel(
      _gRoast,
      _tx.s('s1.labels.ore'),
      _rt_V3(0, 4.4, 0),
      height: 0.9,
    );
    _gasLabel = _mkLabel(
      _gRoast,
      _tx.s('s1.labels.gas'),
      _rt_V3(3.2, 7.2, 0),
      height: 0.85,
    );
    _gasLabel.visible = false;
  }

  void _buildReduce() {
    final steel = _rt_Material3D(
      color: _rt_Tw.slate500,
      shininess: 0.6,
      metalness: 0.5,
    );
    // Conveyor into a furnace box.
    _gReduce.add(
      _rt_Mesh3D(_rt_Geometry3D.box(16, 0.6, 3), steel)
        ..position.set(-4, -3, 0)
        ..pickable = false,
    );
    final shell = _rt_Material3D(
      color: const Color(0xFF3F3F46),
      shininess: 0.3,
    );
    _gReduce.add(
      _rt_Mesh3D(_rt_Geometry3D.box(9, 8, 0.5), shell)
        ..position.set(7, 0.5, -3.3)
        ..pickable = false,
    );
    _gReduce.add(
      _rt_Mesh3D(_rt_Geometry3D.box(9, 0.5, 7), shell)
        ..position.set(7, 4.3, 0)
        ..pickable = false,
    );
    for (final x in [2.7, 11.3]) {
      _gReduce.add(
        _rt_Mesh3D(_rt_Geometry3D.box(0.5, 8, 7), shell)
          ..position.set(x, 0.5, 0)
          ..pickable = false,
      );
    }

    // The charge travelling on the belt: recoloured as it is processed.
    _charge = _rt_Node3D(name: 'charge')..position.set(-7, -2, 0);
    for (var i = 0; i < 16; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final r = _rng.nextDouble() * 1.2;
      _charge.add(
        _rt_Mesh3D(_rt_Geometry3D.octahedron(0.42), _chargeMat)
          ..position.set(
            math.cos(a) * r,
            _rng.nextDouble() * 0.7,
            math.sin(a) * r,
          ),
      );
    }
    _gReduce.add(_charge);

    _cokePile = _rt_Node3D(name: 'coke');
    for (var i = 0; i < 12; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final r = _rng.nextDouble() * 1.1;
      _cokePile.add(
        _rt_Mesh3D(
            _rt_Geometry3D.octahedron(0.38),
            _rt_Material3D(color: const Color(0xFF111827), shininess: 0.15),
          )
          ..position.set(
            math.cos(a) * r,
            _rng.nextDouble() * 0.6,
            math.sin(a) * r,
          ),
      );
    }
    _cokePile.position.set(7, 3.4, 0);
    _cokePile.visible = false;
    _gReduce.add(_cokePile);

    _zincPool = _rt_Mesh3D(
      _rt_Geometry3D.cylinder(2.4, 2.4, 0.6, segments: 24),
      _rt_Material3D(color: _moltenZn, unlit: true),
    )..position.set(7, -2.6, 0);
    _zincPool.visible = false;
    _gReduce.add(_zincPool);

    _cokeLabel = _mkLabel(_gReduce, _tx.s('s2.labels.coke'), _rt_V3(7, 6.2, 0));
    _cokeLabel.visible = false;
    _znLabel = _mkLabel(_gReduce, _tx.s('s2.labels.zn'), _rt_V3(7, -0.9, 0));
    _znLabel.visible = false;
  }

  void _buildRefine() {
    // Electrolysis tank of blue copper sulphate.
    _gRefine.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(7, 7, 8, segments: 30, openEnded: true),
          _rt_Material3D(
            color: const Color(0xFFBAE6FD),
            opacity: 0.2,
            doubleSided: true,
          ),
        )
        ..position.y = -2
        ..pickable = false,
    );
    _gRefine.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(6.8, 6.8, 6, segments: 30),
          _rt_Material3D(
            color: const Color(0xFF2563EB),
            opacity: 0.35,
            unlit: true,
          ),
        )
        ..position.y = -3
        ..pickable = false,
    );

    // Thick impure anode (right) and thin pure cathode (left).
    _anode = _rt_Mesh3D(
      _rt_Geometry3D.box(1.6, 8, 3),
      _rt_Material3D(color: const Color(0xFF8C4A16), shininess: 0.4),
    )..position.set(3.4, -0.5, 0);
    _cathode = _rt_Mesh3D(
      _rt_Geometry3D.box(0.5, 8, 3),
      _rt_Material3D(color: _copper, shininess: 0.8, metalness: 0.6),
    )..position.set(-3.4, -0.5, 0);
    _gRefine.addAll([_anode, _cathode]);

    _mud = _rt_Mesh3D(
      _rt_Geometry3D.cylinder(2.2, 2.6, 0.9, segments: 20),
      _rt_Material3D(color: _anodeMud, shininess: 0.2),
    )..position.set(3.4, -5.6, 0);
    _mud.scale.y = 0.01;
    _gRefine.add(_mud);

    final ionMat = _rt_Material3D(color: const Color(0xFF38BDF8), unlit: true);
    for (var i = 0; i < 22; i++) {
      final n = _rt_Sphere3D(0.34, ionMat);
      n.visible = false;
      n.pickable = false;
      _gRefine.add(n);
      _cuIons.add((node: n, phase: _rng.nextDouble()));
    }

    _mkLabel(
      _gRefine,
      _tx.s('s3.labels.cathode'),
      _rt_V3(-3.4, 4.6, 0),
      height: 0.8,
    );
    _mkLabel(
      _gRefine,
      _tx.s('s3.labels.anode'),
      _rt_V3(3.4, 4.6, 0),
      height: 0.8,
    );
    _mkLabel(
      _gRefine,
      _tx.s('s3.labels.mud'),
      _rt_V3(5.9, -5.4, 0),
      height: 0.7,
      background: const Color(0xE678350F),
    );
    _mkLabel(
      _gRefine,
      _tx.s('s3.labels.ions'),
      _rt_V3(0, -6.9, 0),
      height: 0.7,
      background: const Color(0xE60369A1),
    );
  }

  void _buildAlloy() {
    _gAlloy.add(
      _rt_Mesh3D(
          _rt_Geometry3D.box(18, 0.8, 8),
          _rt_Material3D(color: const Color(0xFF44403C), shininess: 0.2),
        )
        ..position.y = -4
        ..pickable = false,
    );

    // Trapezoid-ish gold bar.
    _goldBar = _rt_Mesh3D(_rt_Geometry3D.box(5, 1.8, 2.6), _goldMat)
      ..position.set(-4, -2.7, 0);
    _gAlloy.add(_goldBar);

    _copperBits = _rt_Node3D(name: 'copper')..position.set(4.5, -3.2, 0);
    for (var i = 0; i < 5; i++) {
      _copperBits.add(
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.75, 0.75, 0.25, segments: 18),
            _rt_Material3D(color: _copper, shininess: 0.7, metalness: 0.6),
          )
          ..rotation.x = math.pi / 2
          ..position.set(
            (i - 2) * 0.5,
            i * 0.28,
            (_rng.nextDouble() - 0.5) * 0.8,
          ),
      );
    }
    _gAlloy.add(_copperBits);

    // The moulded ring: a torus that starts deformed and ends perfect.
    _ring =
        _rt_Mesh3D(
            _rt_Geometry3D.torus(
              2.2,
              0.55,
              radialSegments: 10,
              tubularSegments: 28,
            ),
            _goldMat,
          )
          ..position.set(0, 1.5, 0)
          ..rotation.x = math.pi / 2;
    _ring.visible = false;
    _gAlloy.add(_ring);

    _goldLabel = _mkLabel(
      _gAlloy,
      _tx.s('s4.labels.gold24'),
      _rt_V3(-4, -0.9, 0),
    );
    _copperLabel = _mkLabel(
      _gAlloy,
      _tx.s('s4.labels.copper'),
      _rt_V3(4.5, -1.2, 0),
    );
    _ringLabel = _mkLabel(_gAlloy, _tx.s('s4.labels.ring'), _rt_V3(0, 4.6, 0));
    _ringLabel.visible = false;
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
    _syncLabels();
  }

  /// Applies the master switch on top of each label's own state condition.
  void _syncLabels() {
    for (final l in _labels) {
      l.visible = _showLabels;
    }
    if (!_showLabels) return;
    _gasLabel.visible = _roastStage == 1;
    _cokeLabel.visible = _cokePile.visible;
    _znLabel.visible = _zincPool.visible;
    _goldLabel.visible = _goldBar.visible;
    _goldLabel.text = _tx.s(_alloyed ? 's4.labels.gold22' : 's4.labels.gold24');
    _copperLabel.visible = _copperBits.visible;
    _ringLabel.visible = _ringMade && _ring.visible;
  }

  // ----------------------------------------------------------- frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);

    if (_zone == _Zone.roasting) {
      if (_pitFlame.visible) {
        final s = 1 + math.sin(_clock * 14) * 0.08;
        _pitFlame.scale.set(s, s, s);
      }
      // SO2 fumes rise only while the ore is converting to the oxide
      // (the source shows them for 40 <= heat < 70).
      final fuming = _roastStage == 1;
      for (var i = 0; i < _fumes.length; i++) {
        _fumes[i].visible = fuming;
        if (!fuming) continue;
        final t = (_clock * 0.35 + i / _fumes.length) % 1;
        final a = i / _fumes.length * math.pi * 2;
        _fumes[i].position.set(
          math.cos(a) * (1.4 + t * 2.6),
          -2 + t * 9,
          math.sin(a) * (1.4 + t * 2.6),
        );
      }
    }

    if (_zone == _Zone.refining && _power && _purity < 100) {
      // Source: playSFX('zap') every 0.8 s while current flows.
      if (_clock - _lastZap > 0.8) {
        _lastZap = _clock;
        _rt_playSfx(_rt_Sfx.tap, volume: 0.35);
      }
      for (final ion in _cuIons) {
        final t = (_clock * 0.3 + ion.phase) % 1;
        ion.node.position.set(
          3.4 - 6.8 * t,
          -4.5 + ((ion.phase * 9) % 7),
          math.sin((ion.phase + t) * math.pi * 2) * 1.4,
        );
      }
    }
  }

  // ----------------------------------------------------------- zones ---
  void _setZone(_Zone z, {bool silent = false}) {
    // Source: playSFX('click') on the zone nav; a zone is a stage change.
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _zone = z;
      _busy = false;
    });
    _gRoast.visible = z == _Zone.roasting;
    _gReduce.visible = z == _Zone.reduction;
    _gRefine.visible = z == _Zone.refining;
    _gAlloy.visible = z == _Zone.alloying;
    switch (z) {
      case _Zone.roasting:
        _camera.position.set(0, 9, 21);
        _camera.target.set(0, -1.5, 0);
      case _Zone.reduction:
        _camera.position.set(0, 4, 26);
        _camera.target.set(1, -1, 0);
      case _Zone.refining:
        _camera.position.set(0, 3, 24);
        _camera.target.set(0, -1, 0);
      case _Zone.alloying:
        _camera.position.set(0, 4, 22);
        _camera.target.set(0, -1, 0);
    }
    if (silent) return;
    final toast = switch (z) {
      _Zone.roasting => _tx.s('s1.toast'),
      _Zone.refining => _tx.s('s3.toast'),
      _Zone.alloying => _tx.s('s4.toast'),
      _Zone.reduction => _tx.s('s2.step1'),
    };
    _shell.showToast(toast, color: _rt_Tw.blue500, icon: Icons.info);
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

  // ------------------------------------------------- zone 1: roasting ---
  /// The whole roast is slider-driven and reversible, like the source's
  /// per-frame `update(heat)`: <40 red ore, 40-70 dark oxide with SO₂ fumes,
  /// >=70 mercury pooling, and the observation fires exactly at 100.
  void _setHeat(double v) {
    // Source: playSFX('fire') on every 10% tick of the dial.
    if ((v / 10).floor() != (_heat / 10).floor()) {
      _rt_playSfx(_rt_Sfx.tap, volume: 0.5);
    }
    setState(() => _heat = v);
    _pitFlame.visible = _heat > 10;
    _applyRoast();
  }

  void _applyRoast() {
    final h = _heat;
    final stage = h < 40 ? 0 : (h < 70 ? 1 : 2);
    if (stage != _roastStage) {
      // Transformation moments: darkening to the oxide / mercury appearing.
      if (stage > _roastStage) _rt_playSfx(_rt_Sfx.magic);
      setState(() => _roastStage = stage);
      if (stage == 1) _shell.showToast(_tx.s('s1.eq1'), ms: 4000);
    }
    // HgS -> HgO: the heap darkens across the oxide band.
    final ox = ((h - 35) / 30).clamp(0.0, 1.0);
    _oreMat.color = Color.lerp(_cinnabar, _mercuricOxide, ox)!;
    // HgO -> Hg: the heap shrinks as the silver pool spreads.
    final m = ((h - 70) / 30).clamp(0.0, 1.0);
    _mercuryPool.visible = m > 0.05;
    final ps = math.max(m, 0.01);
    _mercuryPool.scale.set(ps, 1, ps);
    final hs = 1 - 0.9 * m;
    _oreHeap.visible = hs > 0.12;
    _oreHeap.scale.set(hs, hs, hs);
    // Labels follow the state (ore / oxide / metal, plus the fume tag).
    _roastLabel.text = _tx.s(
      stage == 0
          ? 's1.labels.ore'
          : (stage == 1 ? 's1.labels.oxide' : 's1.labels.metal'),
    );
    _gasLabel.visible = _showLabels && stage == 1;
    if (h >= 100 && !_roastObsShown) {
      _roastObsShown = true;
      // Source: playSFX('success') exactly at 100% heat.
      _shell.showToast(_tx.s('s1.obs'), ms: 6000);
      _completeMission(0);
    } else if (h < 100) {
      _roastObsShown = false;
    }
  }

  // ------------------------------------------------ zone 2: reduction ---
  /// Sulphide must be roasted, carbonate calcined; anything else is refused.
  bool get _routingCorrect =>
      _ore != null && _method != null && _ore == _method;

  Future<void> _processOre() async {
    if (_busy || _ore == null || _method == null) return;
    if (!_routingCorrect) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('s2.wrong'),
        color: _rt_Tw.red500,
        icon: Icons.error,
        ms: 6000,
      );
      return;
    }
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);
    // Charge rides the belt into the furnace, then turns into white ZnO.
    await _tweens.run(1200, (t) => _charge.position.x = -7 + 14 * t);
    if (!mounted) return;
    await _tweens.run(1400, (t) {
      _chargeMat.color = Color.lerp(_ore == 0 ? _znS : _znCO3, _znO, t)!;
    });
    if (!mounted) return;
    setState(() {
      _oxideMade = true;
      _busy = false;
    });
    // Source: playSFX('success') when the conversion lands.
    _rt_playSfx(_rt_Sfx.correct);
    _shell.showToast(
      _ore == 0 ? _tx.s('s2.obsRoast') : _tx.s('s2.obsCalc'),
      ms: 5000,
    );
  }

  Future<void> _reduceWithCoke() async {
    if (_busy || !_oxideMade || _zincMade) return;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.pop);
    _cokePile.visible = true;
    _syncLabels();
    await _tweens.run(900, (t) => _cokePile.position.y = 3.4 - 5.4 * t);
    if (!mounted) return;
    await _tweens.run(1600, (t) {
      _chargeMat.color = Color.lerp(_znO, _moltenZn, t)!;
      _charge.scale.set(1 - t * 0.85, 1 - t * 0.85, 1 - t * 0.85);
      _zincPool.visible = t > 0.2;
      _zincPool.scale.set(t, 1, t);
    });
    if (!mounted) return;
    _cokePile.visible = false;
    setState(() {
      _zincMade = true;
      _oresDone.add(_ore!);
      _busy = false;
    });
    _syncLabels();
    _shell.showToast(_tx.s('s2.obsReduce'), ms: 5000);
    if (_oresDone.length >= 2) {
      _shell.showToast(_tx.s('s2.allDone'), ms: 5000);
      _completeMission(1);
    } else {
      // Source: playSFX('success') for the first ore too.
      _rt_playSfx(_rt_Sfx.correct);
    }
  }

  void _testOtherOre() {
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _ore = _ore == 0 ? 1 : 0;
      _method = null;
      _oxideMade = false;
      _zincMade = false;
    });
    _charge.position.set(-7, -2, 0);
    _charge.scale.set(1, 1, 1);
    _chargeMat.color = _ore == 0 ? _znS : _znCO3;
    _zincPool.visible = false;
    _cokePile.position.set(7, 3.4, 0);
    _syncLabels();
  }

  void _selectOre(int i) {
    if (_busy || _oxideMade) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _ore = i);
    _chargeMat.color = i == 0 ? _znS : _znCO3;
  }

  void _selectMethod(int i) {
    if (_busy) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _method = i);
  }

  // ------------------------------------------------- zone 3: refining ---
  Future<void> _togglePower() async {
    if (_busy) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _power = !_power);
    for (final ion in _cuIons) {
      ion.node.visible = _power;
    }
    if (!_power || _purity >= 100) return;
    // Current starts to flow (the source's first zap).
    _rt_playSfx(_rt_Sfx.magic);

    setState(() => _busy = true);
    // The anode dissolves, the cathode thickens and the mud builds up.
    await _tweens.run(5000, (t) {
      setState(() => _purity = t * 100);
      _anode.scale.x = 1 - t * 0.6;
      _cathode.scale.x = 1 + t * 2.4;
      _mud.scale.y = 0.01 + t * 0.99;
    });
    if (!mounted) return;
    for (final ion in _cuIons) {
      ion.node.visible = false;
    }
    setState(() {
      _purity = 100;
      _busy = false;
    });
    _shell.showToast(_tx.s('s3.obs'), ms: 6000);
    _completeMission(2);
  }

  // ------------------------------------------------- zone 4: alloying ---
  Future<void> _moldSoft() async {
    if (_busy || _softTested) return;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.wrong);
    _ring.visible = true;
    // 24K is too soft: the ring sags out of shape.
    await _tweens.run(1200, (t) {
      _ring.scale.set(1 + t * 0.35, 1 - t * 0.6, 1);
      _ring.rotation.z = t * 0.5;
    });
    if (!mounted) return;
    _ring.visible = false;
    _ring.scale.set(1, 1, 1);
    _ring.rotation.z = 0;
    setState(() {
      _softTested = true;
      _busy = false;
    });
    _shell.showToast(
      _tx.s('s4.obsSoft'),
      color: _rt_Tw.red500,
      icon: Icons.warning,
      ms: 5000,
    );
  }

  Future<void> _meltAndMix() async {
    if (_busy || _alloyed) return;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);
    await _tweens.run(1400, (t) {
      _copperBits.position.x = 4.5 - 8.5 * t;
      _copperBits.position.y = -3.2 + math.sin(t * math.pi) * 3;
    });
    if (!mounted) return;
    _copperBits.visible = false;
    // 22 parts gold to 2 parts copper: the bar takes a warmer tone.
    await _tweens.run(1400, (t) {
      _goldMat.color = Color.lerp(_gold, const Color(0xFFD9A441), t)!;
    });
    if (!mounted) return;
    setState(() {
      _alloyed = true;
      _busy = false;
    });
    // Source: playSFX('success') once the alloy is mixed.
    _rt_playSfx(_rt_Sfx.correct);
    _syncLabels();
  }

  Future<void> _moldHard() async {
    if (_busy || !_alloyed || _ringMade) return;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.success);
    _goldBar.visible = false;
    _ring.visible = true;
    _ring.scale.set(0.1, 0.1, 0.1);
    await _tweens.run(
      1100,
      (t) => _ring.scale.set(t, t, t),
      ease: _rt_Ease.outBack,
    );
    if (!mounted) return;
    setState(() {
      _ringMade = true;
      _busy = false;
    });
    _syncLabels();
    _shell.showToast(_tx.s('s4.obsHard'), ms: 6000);
    _completeMission(3);
  }

  void _checkExam() {
    setState(() => _examChecked = true);
    _rt_playSfx(_examChoice == 1 ? _rt_Sfx.success : _rt_Sfx.wrong);
  }

  void _restart() {
    _rt_playSfx(_rt_Sfx.scenario);
    _tweens.cancelAll();
    setState(() {
      _heat = 0;
      _roastStage = 0;
      _ore = null;
      _method = null;
      _oxideMade = false;
      _zincMade = false;
      _oresDone.clear();
      _power = false;
      _purity = 0;
      _softTested = false;
      _alloyed = false;
      _ringMade = false;
      _examChoice = null;
      _examChecked = false;
      _busy = false;
      for (var i = 0; i < _missions.length; i++) {
        _missions[i] = false;
      }
    });
    _roastObsShown = false;
    _lastZap = -1;
    _showLabels = true;
    _oreMat.color = _cinnabar;
    _roastLabel.text = _tx.s('s1.labels.ore');
    _oreHeap
      ..visible = true
      ..scale.set(1, 1, 1);
    _mercuryPool.visible = false;
    _pitFlame.visible = false;
    for (final f in _fumes) {
      f.visible = false;
    }
    _charge
      ..position.set(-7, -2, 0)
      ..scale.set(1, 1, 1);
    _chargeMat.color = _znS;
    _cokePile
      ..visible = false
      ..position.set(7, 3.4, 0);
    _zincPool.visible = false;
    _anode.scale.x = 1;
    _cathode.scale.x = 1;
    _mud.scale.y = 0.01;
    for (final ion in _cuIons) {
      ion.node.visible = false;
    }
    _goldMat.color = _gold;
    _goldBar.visible = true;
    _copperBits
      ..visible = true
      ..position.set(4.5, -3.2, 0);
    _ring
      ..visible = false
      ..scale.set(1, 1, 1)
      ..rotation.z = 0;
    _syncLabels();
    _setZone(_Zone.roasting, silent: true);
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
              icon: Icons.factory,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: () => _setZone(_zone, silent: true),
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: Icons.sell,
                tooltip: _tx.s('ui.toggleLabels'),
                onTap: _toggleLabels,
              ),
              const SizedBox(height: 4),
              _rt_RotatePanToggle(controller: _viewCtrl),
            ],
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
                      if (_zone == _Zone.roasting)
                        _rt_HudCard(
                          value: '${_heat.round()}%',
                          label: _tx.s('ui.heat'),
                        ),
                      if (_zone == _Zone.refining)
                        _rt_HudCard(
                          value: '${_purity.round()}%',
                          label: _tx.s('ui.purification'),
                          color: _purity >= 100
                              ? _rt_Tw.green500
                              : _rt_Tw.teal700,
                        ),
                      _rt_HudCard(
                        value: _stateLabel,
                        label: _tx.s('ui.processLog'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_equation != null)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _rt_Tw.teal500.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Text(
                          _equation!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
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

  String get _stateLabel => switch (_zone) {
    _Zone.roasting => switch (_roastStage) {
      0 => _tx.s('s1.labels.ore'),
      1 => _tx.s('s1.labels.oxide'),
      _ => _tx.s('s1.labels.metal'),
    },
    _Zone.reduction =>
      _zincMade
          ? _tx.s('s2.labels.zn')
          : (_oxideMade ? _tx.s('s2.labels.zno') : _tx.s('ui.awaiting')),
    _Zone.refining => _purity >= 100 ? '99.99% Cu' : '98% Cu',
    _Zone.alloying =>
      _ringMade
          ? _tx.s('s4.labels.ring')
          : (_alloyed ? _tx.s('s4.labels.gold22') : _tx.s('s4.labels.gold24')),
  };

  String? get _equation => switch (_zone) {
    _Zone.roasting => switch (_roastStage) {
      0 => _tx.s('s1.eq0'),
      1 => _tx.s('s1.eq1'),
      _ => _tx.s('s1.eq2'),
    },
    _Zone.reduction =>
      _zincMade
          ? _tx.s('s2.eqReduce')
          : (_oxideMade
                ? (_ore == 0 ? _tx.s('s2.eqRoast') : _tx.s('s2.eqCalc'))
                : null),
    _Zone.refining =>
      _power ? '${_tx.s('s3.eqAnode')}   •   ${_tx.s('s3.eqCathode')}' : null,
    _Zone.alloying => null,
  };

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
                    _zoneChip(_Zone.values[i], nav[i] as String, i),
                ],
              ),
              const SizedBox(height: 14),
              ..._zoneControls(),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.checklist),
              for (var i = 0; i < _missionList.length; i++) _missionRow(i),
              const SizedBox(height: 14),
              // The shell renders only the first tab, so the source's
              // Assessment / Theory / Teacher Guide tabs live at the foot.
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
              _rt_SectionLabel(_tx.s('ui.exam'), icon: Icons.school),
              ..._examCard(),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('contextTitle'), icon: Icons.lightbulb),
              _rt_InfoCard(
                body: _tx.s('contextIntro'),
                leftBorder: true,
                color: _rt_Tw.blue500,
              ),
              for (final a in _tx.list('contextApps'))
                _rt_InfoCard(
                  title: (a as Map)['title'] as String,
                  body: a['desc'] as String,
                  icon: Icons.auto_awesome,
                  color: _rt_Tw.blue500,
                ),
              const SizedBox(height: 8),
              _rt_SectionLabel(
                _tx.s('teacherTitle'),
                icon: Icons.school_outlined,
              ),
              _rt_InfoCard(
                body: _tx.s('teacherIntro'),
                leftBorder: true,
                color: _rt_Tw.amber600,
              ),
              for (final ph in _tx.list('teacherPhases'))
                _rt_InfoCard(
                  title: (ph as Map)['title'] as String,
                  body: ph['desc'] as String,
                  icon: Icons.menu_book,
                  color: _rt_Tw.amber600,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _zoneChip(_Zone z, String label, int index) {
    final on = _zone == z;
    return GestureDetector(
      onTap: () => _setZone(z),
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

  List<Widget> _zoneControls() {
    switch (_zone) {
      case _Zone.roasting:
        return [
          _rt_SectionLabel(
            _tx.s('s1.title'),
            icon: Icons.local_fire_department,
          ),
          Text(
            _tx.s('s1.desc'),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _rt_LabeledSlider(
            label: _tx.s('ui.heat'),
            value: _heat,
            min: 0,
            max: 100,
            divisions: 20,
            valueText: _heat >= 80 ? _tx.s('ui.high') : '${_heat.round()}%',
            onChanged: _busy ? null : _setHeat,
          ),
          if (_missions[0]) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('ui.processComplete'),
              body: _tx.s('s1.obs'),
              icon: Icons.science,
              leftBorder: true,
            ),
            _rt_ActionButton(
              label: _tx.s('ui.nextStation'),
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: () => _setZone(_Zone.reduction),
            ),
          ],
        ];
      case _Zone.reduction:
        return [
          _rt_SectionLabel(_tx.s('s2.title'), icon: Icons.factory),
          Text(
            _oxideMade ? _tx.s('s2.step2') : _tx.s('s2.step1'),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _rt_ChoiceButton(
            label: _tx.s('s2.oreA'),
            state: _ore == 0 ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
            onTap: () => _selectOre(0),
          ),
          _rt_ChoiceButton(
            label: _tx.s('s2.oreB'),
            state: _ore == 1 ? _rt_ChoiceState.selected : _rt_ChoiceState.idle,
            onTap: () => _selectOre(1),
          ),
          const SizedBox(height: 6),
          _rt_ChoiceButton(
            label: _tx.s('s2.air'),
            state: _method == 0
                ? _rt_ChoiceState.selected
                : _rt_ChoiceState.idle,
            onTap: _oxideMade ? null : () => _selectMethod(0),
          ),
          _rt_ChoiceButton(
            label: _tx.s('s2.noAir'),
            state: _method == 1
                ? _rt_ChoiceState.selected
                : _rt_ChoiceState.idle,
            onTap: _oxideMade ? null : () => _selectMethod(1),
          ),
          const SizedBox(height: 6),
          _rt_ActionButton(
            label: _tx.s('s2.process'),
            icon: Icons.whatshot,
            expand: true,
            done: _oxideMade,
            onPressed: (_busy || _oxideMade || _ore == null || _method == null)
                ? null
                : _processOre,
          ),
          const SizedBox(height: 6),
          _rt_ActionButton(
            label: _tx.s('s2.coke'),
            icon: Icons.grain,
            color: _rt_Tw.slate600,
            expand: true,
            done: _zincMade,
            onPressed: (_busy || !_oxideMade || _zincMade)
                ? null
                : _reduceWithCoke,
          ),
          if (_zincMade && _oresDone.length < 2) ...[
            const SizedBox(height: 6),
            _rt_ActionButton(
              label: _tx.s('ui.testOtherOre'),
              icon: Icons.swap_horiz,
              color: _rt_Tw.blue600,
              expand: true,
              onPressed: _busy ? null : _testOtherOre,
            ),
          ],
          if (_oresDone.length >= 2) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('ui.processComplete'),
              body: _tx.s('s2.allDone'),
              icon: Icons.check_circle,
              leftBorder: true,
            ),
            _rt_ActionButton(
              label: _tx.s('ui.nextStation'),
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: () => _setZone(_Zone.refining),
            ),
          ],
        ];
      case _Zone.refining:
        return [
          _rt_SectionLabel(_tx.s('s3.title'), icon: Icons.bolt),
          Text(
            _tx.s('s3.desc'),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _rt_ActionButton(
            label: _tx.s('s3.switch'),
            icon: _power ? Icons.toggle_on : Icons.toggle_off,
            color: _power ? _rt_Tw.green600 : _rt_Tw.slate500,
            expand: true,
            onPressed: _busy ? null : _togglePower,
          ),
          if (_purity >= 100) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('ui.processComplete'),
              body: _tx.s('s3.obs'),
              icon: Icons.verified,
              leftBorder: true,
            ),
            _rt_ActionButton(
              label: _tx.s('ui.nextStation'),
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: () => _setZone(_Zone.alloying),
            ),
          ],
        ];
      case _Zone.alloying:
        return [
          _rt_SectionLabel(_tx.s('s4.title'), icon: Icons.diamond),
          Text(
            _tx.s('s4.desc'),
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _rt_ActionButton(
            label: _tx.s('s4.testSoft'),
            icon: Icons.pan_tool,
            color: _rt_Tw.amber600,
            expand: true,
            done: _softTested,
            onPressed: (_busy || _softTested) ? null : _moldSoft,
          ),
          const SizedBox(height: 6),
          _rt_ActionButton(
            label: _tx.s('s4.mix'),
            icon: Icons.merge,
            color: _rt_Tw.orange600,
            expand: true,
            done: _alloyed,
            onPressed: (_busy || !_softTested || _alloyed) ? null : _meltAndMix,
          ),
          const SizedBox(height: 6),
          _rt_ActionButton(
            label: _tx.s('s4.testHard'),
            icon: Icons.check_circle,
            expand: true,
            done: _ringMade,
            onPressed: (_busy || !_alloyed || _ringMade) ? null : _moldHard,
          ),
          if (_ringMade) ...[
            const SizedBox(height: 8),
            _rt_InfoCard(
              title: _tx.s('ui.processComplete'),
              body: _tx.s('s4.obsHard'),
              icon: Icons.emoji_events,
              leftBorder: true,
            ),
          ],
        ];
    }
  }

  List<Widget> _examCard() {
    final options = _tx.list('exam.options');
    return [
      _rt_InfoCard(
        body: _tx.s('exam.question'),
        icon: Icons.help_outline,
        leftBorder: true,
      ),
      for (var i = 0; i < options.length; i++)
        _rt_ChoiceButton(
          label: '${String.fromCharCode(65 + i)}) ${options[i]}',
          state: _examChoice != i
              ? _rt_ChoiceState.idle
              : (!_examChecked
                    ? _rt_ChoiceState.selected
                    : (i == 1
                          ? _rt_ChoiceState.correct
                          : _rt_ChoiceState.wrong)),
          onTap: _examChecked
              ? null
              : () {
                  _rt_playSfx(_rt_Sfx.tap);
                  setState(() => _examChoice = i);
                },
        ),
      const SizedBox(height: 6),
      _rt_ActionButton(
        label: _examChecked
            ? (_examChoice == 1 ? _tx.s('ui.correct') : _tx.s('ui.tryAgain'))
            : _tx.s('ui.check'),
        icon: Icons.check,
        color: _examChecked && _examChoice == 1
            ? _rt_Tw.green600
            : _rt_Tw.teal600,
        expand: true,
        onPressed: _examChoice == null
            ? null
            : (_examChecked
                  ? (_examChoice == 1
                        ? null
                        : () => setState(() {
                            _examChecked = false;
                            _examChoice = null;
                          }))
                  : _checkExam),
      ),
      if (_examChecked && _examChoice == 1) ...[
        const SizedBox(height: 8),
        _rt_InfoCard(
          body: _tx.s('exam.reason'),
          icon: Icons.lightbulb,
          leftBorder: true,
        ),
      ],
    ];
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

// ------------------------------------------------------------- widgets ---

/// Round toggle for the canvas toolbar (the source's Toggle Labels tool).
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
            color: active ? _rt_Tw.teal600 : _rt_Lab.surface,
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
