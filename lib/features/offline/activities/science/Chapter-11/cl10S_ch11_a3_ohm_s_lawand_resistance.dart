// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 11.3: Ohm's Law Verifier
// Converted from Cl10S-Ch11-A3-Ohm_sLawandResistance.html (React + canvas-2D
// circuit sim -> widget tree + CustomPainter in a ZoomableCanvas).
//
// Four missions: (1) The Architect - drag battery, key, nichrome wire, ammeter
// and voltmeter into dotted slots (with series/parallel error protection) and
// close the knife switch; (2) Voltage Step - vary cells 1-4, record 3 V-I
// readings in the lab notebook; (3) The Analyst - plot the V-I graph and click
// a point to compute R = V/I = 4 ohm; (4) Rheostat Run - slide a rheostat to
// control a motor's speed (I = V/R). Physics is exactly the source's:
// V = cells*1.5 (6 V in mission 4), R = 4 ohm fixed (2 + rheostat in mission
// 4), I = V/R. Sidebar carries objective, mission cards, Why Learn?, Teacher
// Guide and Outcomes; the completion popup offers "Restart Lab".

// --- TRANSLATION DATA (the source's TRANSLATIONS block; TE ignored) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
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
  static const teal900 = Color(0xFF134E4A);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue900 = Color(0xFF1E3A8A);
  static const purple500 = Color(0xFFA855F7);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const emerald400 = Color(0xFF34D399);
}

/// Pill action button (the HTML `.action-btn`). Plays a click sound.
class _rt_ActionButton extends StatelessWidget {
  const _rt_ActionButton({
    super.key,
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

/// Numbered step card with action button (the HTML `.step-card`).
class _rt_StepCard extends StatelessWidget {
  const _rt_StepCard({
    super.key,
    required this.number,
    required this.title,
    required this.desc,
    required this.actionLabel,
    required this.onAction,
    this.active = false,
    this.accent = _rt_Tw.teal600,
    this.actionIcon,
    this.extra,
  });

  final int number;
  final String title;
  final String desc;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool active;
  final bool done = false;
  final bool locked = false;
  final Color accent;
  final IconData? actionIcon;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final dim = !active && !done;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: active
            ? _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.93)!, accent)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? accent : _rt_Lab.border, width: 2),
        boxShadow: active
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Opacity(
        opacity: dim ? 0.65 : 1,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _rt_Lab
                      .tinted(Color.lerp(accent, Colors.white, 0.8)!, accent)
                      .withValues(alpha: active ? 1 : 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.onTinted(
                      accent,
                      Color.lerp(accent, Colors.black, 0.3)!,
                    ),
                    height: 1,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 34),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: _rt_Lab.textMuted,
                      height: 1.3,
                    ),
                  ),
                  ?extra,
                  const SizedBox(height: 10),
                  _rt_ActionButton(
                    label: actionLabel,
                    icon: actionIcon,
                    color: accent,
                    done: done,
                    onPressed: locked ? null : onAction,
                  ),
                ],
              ),
            ),
          ],
        ),
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
    'intro': {
      'title': "Ohm's Law Verifier",
      'subtitle': 'Class 10 • Electricity',
      'button': 'Enter _rt_Lab',
      'footnote': "V = I × R • Verify Ohm's Law",
    },
    'headerTitle': "Ohm's Law Verifier",
    'headerSubtitle': 'Class 10 • Electricity',
    'tabs': {
      'why': 'Why Learn?',
      'guide': 'Teacher Guide',
      'explore': 'Explore',
      'analysis': 'Outcomes',
    },
    'components': {
      'battery': 'Battery',
      'switch': 'Key',
      'ammeter': 'Ammeter',
      'voltmeter': 'Voltmeter',
      'bulb': 'Nichrome',
      'wire': 'Wire',
      'motor': 'Motor',
      'rheostat': 'Rheostat',
    },
    'ui': {
      'notebook': '_rt_Lab Notebook',
      'readings': 'Readings',
      'volt_ctrl': 'Voltage Control',
      'rheo_ctrl': 'Rheostat Control',
      'calc': 'Calculation',
      'conc': 'Conclusion',
      'finish': 'Finish',
      'next': 'Next',
      'inst': 'Instruction',
      'instruments': 'Instruments',
      'cells_label': 'Cells (1.5V each)',
      'record_btn': 'Record Reading',
      'plot_btn': 'Plot Data',
      'step_label': 'Step',
      'voltage_axis': 'Voltage (V)',
      'current_axis': 'Current (I)',
      'graph_hint_plot': 'Plot the data to begin analysis',
      'graph_hint_click': 'Click on a blue point to calculate R',
      'resistance_label': 'Resistance (Ω)',
      'motor_current': 'Motor Current',
      'min_fast': 'Min (Fast)',
      'max_slow': 'Max (Slow)',
      'v_head': 'V (Volts)',
      'i_head': 'I (Amps)',
      'open_step': 'Open Step',
      'completed': 'Completed',
      'prev_step': 'Previous step',
      'toggleLabels': 'Toggle Labels',
      'inv_hint': 'Tap a component to place it, or drag it to its dotted slot.',
    },
    'actions': {'do': 'DO', 'observe': 'OBSERVE'},
    'pop': {
      'title': '_rt_Lab Completed!',
      'desc':
          "You have successfully verified Ohm's Law and explored variable resistance.",
      'btn': 'Restart _rt_Lab',
    },
    'explore': {
      'objective_title': 'Main Objective',
      'objective_desc':
          "Construct a circuit to experimentally verify Ohm's Law (V ∝ I) and understand how variable resistance controls current in appliances.",
      'steps': [
        {
          'title': 'The Architect',
          'desc': 'Connect Meters',
          'do':
              'Drag the Battery, Switch, Nichrome Wire, Ammeter, and Voltmeter to their dotted slots.',
          'observe':
              'Ensure Ammeter is Series (Right) and Voltmeter is Parallel (Top). Close the switch to test.',
        },
        {
          'title': 'Voltage Step',
          'desc': 'Data Collection',
          'do':
              "Use the slider to change voltage. Click 'RECORD' to save 3 different readings.",
          'observe':
              'Notice how the Ammeter reading (Current) changes as you increase the Voltage.',
        },
        {
          'title': 'The Analyst',
          'desc': 'V-I Graph Plotting',
          'do': "Click 'PLOT DATA' then click points on the graph.",
          'observe':
              'Verify that the graph is a straight line passing through the origin.',
        },
        {
          'title': 'Rheostat Run',
          'desc': 'Application',
          'do': 'Move the Rheostat Slider to control the Motor speed.',
          'observe':
              'Increasing Resistance decreases Current (Inverse relationship).',
        },
      ],
    },
    'why': {
      'intro':
          'Ohm\'s Law is the bedrock of modern electronics. It explains how voltage pushes current through resistance, governing everything from the brightness of a bulb to the speed of a fan.',
      'cards': [
        {
          'title': 'Power Transmission',
          'desc':
              'High voltage is used to reduce current and minimize heat loss (I²R) in long-distance cables.',
        },
        {
          'title': 'Electronics Design',
          'desc':
              'Resistors are used to limit current and protect sensitive components like LEDs and microchips.',
        },
        {
          'title': 'Electrical Safety',
          'desc':
              'Circuit breakers cut power when current exceeds safe limits due to low resistance (short circuits).',
        },
      ],
    },
    'guide': {
      'intro':
          'This simulation helps students visualize the abstract relationship between Voltage, Current, and Resistance.',
      'steps': [
        {
          'title': 'Phase 1: Discovery',
          'desc':
              'Students construct the circuit. Challenge them to predict what happens if meters are swapped.',
        },
        {
          'title': 'Phase 2: Interaction',
          'desc':
              'Data collection. Students observe that as Voltage increases, Current increases proportionally.',
        },
        {
          'title': 'Phase 3: Observation',
          'desc':
              'Graphing analysis. The straight line passing through the origin proves linearity.',
        },
        {
          'title': 'Phase 4: Application',
          'desc':
              'Real-world application using a Rheostat to control motor speed by varying resistance.',
        },
      ],
    },
    'analysis': {
      'def_title': 'Definition',
      'def_text':
          '"Ohm\'s Law states that the current (I) flowing through a conductor is directly proportional to the potential difference (V) across its ends, provided the temperature remains constant."',
      'table_head': ['Observation', 'Learning Outcome'],
      'table_rows': [
        {
          'obs': 'Current rises with Voltage',
          'out': 'Verified V ∝ I (Linear Relationship)',
        },
        {
          'obs': 'Graph is a straight line',
          'out': 'The slope represents Resistance (R = V/I)',
        },
        {'obs': 'Rheostat changes Current', 'out': 'Inverse relation: I = V/R'},
      ],
    },
    'messages': {
      'step1_start':
          'Step 1: Drag components to the dotted slots. (Hint: Try swapping meters to see error protection!)',
      'step1_ready':
          'Circuit Complete! Now click the KNIFE SWITCH (Left) to close the circuit.',
      'step1_success':
          'Circuit Closed! Current flows. Meters show values. Click Next.',
      'step1_error_series':
          'Voltmeters have high resistance. Connect in Parallel!',
      'step1_error_parallel':
          'Ammeters have low resistance. Connect in Series!',
      'step1_error_incomplete': 'Place all components first!',
      'step2_start':
          "Step 2: Change Voltage using the slider. Click 'RECORD' to save 3 readings.",
      'step2_recorded':
          'Recorded V={v}V. Change voltage slider and record {n} more.',
      'step2_duplicate': 'Value already recorded. Change voltage first.',
      'step2_success':
          'OBSERVATION: Current rises proportionally with Voltage. V ∝ I. Click Next.',
      'step3_start':
          "Step 3: Click 'PLOT DATA' to visualize the V-I relationship.",
      'step3_plotted':
          'Graph Plotted! Click ANY point on the line to calculate slope.',
      'step3_success':
          'OBSERVATION: The ratio V/I is constant (Resistance). Ohm\'s Law verified. Click Next.',
      'step4_start':
          'Step 4: Application. Move the Rheostat Slider to control the Motor speed.',
      'step4_decrease':
          'Resistance Decreased ↓ Current Increases ↑ (Motor Speeds Up!)',
      'step4_increase':
          'Resistance Increased ↑ Current Decreases ↓ (Motor Slows Down!)',
      'step4_success':
          'OBSERVATION: Rheostat changes Current (I) by varying Resistance (R). _rt_Lab Complete!',
    },
  },
  'hi': {
    'intro': {
      'title': 'ओम नियम सत्यापन',
      'subtitle': 'कक्षा 10 • विद्युत',
      'button': 'प्रवेश करें',
      'footnote': 'V = I × R • ओम के नियम का सत्यापन',
    },
    'headerTitle': 'ओम नियम सत्यापन',
    'headerSubtitle': 'कक्षा 10 • विद्युत',
    'tabs': {
      'why': 'संदर्भ',
      'guide': 'शिक्षक गाइड',
      'explore': 'अन्वेषण',
      'analysis': 'परिणाम',
    },
    'components': {
      'battery': 'बैटरी',
      'switch': 'कुंजी',
      'ammeter': 'एमीटर',
      'voltmeter': 'वोल्टमीटर',
      'bulb': 'नाइक्रोम',
      'wire': 'तार',
      'motor': 'मोटर',
      'rheostat': 'रियोस्टेट',
    },
    'ui': {
      'notebook': 'लैब नोटबुक',
      'readings': 'रीडिंग',
      'volt_ctrl': 'वोल्टेज नियंत्रण',
      'rheo_ctrl': 'रियोस्टेट नियंत्रण',
      'calc': 'गणना',
      'conc': 'निष्कर्ष',
      'finish': 'समाप्त',
      'next': 'अगला',
      'inst': 'निर्देश',
      'instruments': 'यंत्र',
      'cells_label': 'सेल (1.5V प्रत्येक)',
      'record_btn': 'रीडिंग रिकॉर्ड करें',
      'plot_btn': 'डेटा प्लॉट करें',
      'step_label': 'चरण',
      'voltage_axis': 'वोल्टेज (V)',
      'current_axis': 'धारा (I)',
      'graph_hint_plot': 'विश्लेषण शुरू करने के लिए डेटा प्लॉट करें',
      'graph_hint_click': 'R की गणना करने के लिए नीले बिंदु पर क्लिक करें',
      'resistance_label': 'प्रतिरोध (Ω)',
      'motor_current': 'मोटर धारा',
      'min_fast': 'न्यूनतम (तेज़)',
      'max_slow': 'अधिकतम (धीमा)',
      'v_head': 'V (वोल्ट)',
      'i_head': 'I (ऐम्पियर)',
      'open_step': 'चरण खोलें',
      'completed': 'पूर्ण',
      'prev_step': 'पिछला चरण',
      'toggleLabels': 'लेबल दिखाएँ/छिपाएँ',
      'inv_hint':
          'किसी घटक को रखने के लिए उस पर टैप करें, या उसे बिंदीदार स्लॉट तक खींचें।',
    },
    'actions': {'do': 'करें', 'observe': 'अवलोकन'},
    'pop': {
      'title': 'लैब पूर्ण!',
      'desc': 'आपने ओम के नियम को सफलतापूर्वक सत्यापित किया है।',
      'btn': 'पुनः आरंभ करें',
    },
    'explore': {
      'objective_title': 'मुख्य उद्देश्य',
      'objective_desc':
          'ओम के नियम (V ∝ I) को सत्यापित करने के लिए एक सर्किट का निर्माण करें और समझें कि रियोस्टेट धारा को कैसे नियंत्रित करता है।',
      'steps': [
        {
          'title': 'वास्तुकार',
          'desc': 'सर्किट निर्माण',
          'do':
              'बैटरी, स्विच, तार, एमीटर और वोल्टमीटर को बिंदीदार स्थानों पर खींचें।',
          'observe': 'एमीटर श्रेणी में और वोल्टमीटर समानांतर में होना चाहिए।',
        },
        {
          'title': 'वोल्टेज चरण',
          'desc': 'डेटा संग्रह',
          'do':
              "वोल्टेज बदलने के लिए स्लाइडर का उपयोग करें। 3 रीडिंग सहेजने के लिए 'रिकॉर्ड' पर क्लिक करें।",
          'observe': 'देखें कि वोल्टेज बढ़ने पर धारा कैसे बदलती है।',
        },
        {
          'title': 'विश्लेषक',
          'desc': 'V-I ग्राफ',
          'do': "'प्लॉट डेटा' पर क्लिक करें और फिर बिंदुओं पर क्लिक करें।",
          'observe': 'सत्यापित करें कि ग्राफ एक सीधी रेखा है।',
        },
        {
          'title': 'रियोस्टेट रन',
          'desc': 'अनुप्रयोग',
          'do':
              'मोटर की गति को नियंत्रित करने के लिए रियोस्टेट स्लाइडर को हिलाएं।',
          'observe': 'प्रतिरोध बढ़ने पर धारा घटती है।',
        },
      ],
    },
    'why': {
      'intro':
          'ओम का नियम आधुनिक इलेक्ट्रॉनिक्स की नींव है। यह बताता है कि वोल्टेज प्रतिरोध के माध्यम से धारा को कैसे धकेलता है।',
      'cards': [
        {
          'title': 'विद्युत संचरण',
          'desc':
              'लंबी दूरी के केबलों में ऊष्मा हानि (I²R) को कम करने के लिए उच्च वोल्टेज का उपयोग किया जाता है।',
        },
        {
          'title': 'इलेक्ट्रॉनिक्स डिजाइन',
          'desc':
              'प्रतिरोधक धारा को सीमित करने और संवेदनशील घटकों की रक्षा करने के लिए उपयोग किए जाते हैं।',
        },
        {
          'title': 'विद्युत सुरक्षा',
          'desc':
              'सर्किट ब्रेकर तब बिजली काट देते हैं जब धारा सुरक्षित सीमा से अधिक हो जाती है।',
        },
      ],
    },
    'guide': {
      'intro':
          'यह सिमुलेशन छात्रों को वोल्टेज, धारा और प्रतिरोध के बीच संबंध की कल्पना करने में मदद करता है।',
      'steps': [
        {
          'title': 'चरण 1: खोज',
          'desc':
              'छात्र सर्किट का निर्माण करते हैं। चुनौती: मीटरों की अदला-बदली करें।',
        },
        {
          'title': 'चरण 2: अन्योन्यक्रिया',
          'desc':
              'डेटा संग्रह। छात्र देखते हैं कि वोल्टेज बढ़ने पर धारा बढ़ती है।',
        },
        {
          'title': 'चरण 3: अवलोकन',
          'desc': 'ग्राफ विश्लेषण। सीधी रेखा आनुपातिकता सिद्ध करती है।',
        },
        {
          'title': 'चरण 4: अनुप्रयोग',
          'desc': 'मोटर की गति को नियंत्रित करने के लिए रियोस्टेट का उपयोग।',
        },
      ],
    },
    'analysis': {
      'def_title': 'परिभाषा',
      'def_text':
          '"ओम का नियम बताता है कि किसी चालक से प्रवाहित धारा (I) उसके सिरों के बीच विभवांतर (V) के अनुक्रमानुपाती होती है, बशर्ते ताप स्थिर रहे।"',
      'table_head': ['अवलोकन', 'सीखने का परिणाम'],
      'table_rows': [
        {
          'obs': 'वोल्टेज के साथ धारा बढ़ती है',
          'out': 'V ∝ I (रैखिक संबंध) सत्यापित',
        },
        {
          'obs': 'ग्राफ एक सीधी रेखा है',
          'out': 'ढलान प्रतिरोध को दर्शाता है (R = V/I)',
        },
        {'obs': 'रियोस्टेट धारा बदलता है', 'out': 'व्युत्क्रम संबंध: I = V/R'},
      ],
    },
    'messages': {
      'step1_start': 'चरण 1: घटकों को बिंदीदार स्लॉट में खींचें।',
      'step1_ready':
          'सर्किट तैयार! अब सर्किट बंद करने के लिए स्विच (बाएं) पर क्लिक करें।',
      'step1_success': "सर्किट बंद! धारा बह रही है। 'अगला' पर क्लिक करें।",
      'step1_error_series':
          'वोल्टमीटर का प्रतिरोध उच्च होता है। समानांतर में कनेक्ट करें!',
      'step1_error_parallel':
          'एमीटर का प्रतिरोध कम होता है। श्रेणी में कनेक्ट करें!',
      'step1_error_incomplete': 'पहले सभी घटकों को रखें!',
      'step2_start':
          "चरण 2: वोल्टेज बदलें। 3 रीडिंग सहेजने के लिए 'रिकॉर्ड' पर क्लिक करें।",
      'step2_recorded':
          'रिकॉर्ड किया गया V={v}V. वोल्टेज बदलें और {n} और रिकॉर्ड करें।',
      'step2_duplicate': 'मान पहले से रिकॉर्ड है। पहले वोल्टेज बदलें।',
      'step2_success':
          "अवलोकन: वोल्टेज के साथ धारा आनुपातिक रूप से बढ़ती है। 'अगला' पर क्लिक करें।",
      'step3_start': "चरण 3: 'प्लॉट डेटा' पर क्लिक करें।",
      'step3_plotted':
          'ग्राफ प्लॉट हो गया! ढलान की गणना के लिए किसी भी बिंदु पर क्लिक करें।',
      'step3_success':
          "अवलोकन: अनुपात V/I स्थिर है। ओम का नियम सत्यापित। 'अगला' पर क्लिक करें।",
      'step4_start':
          'चरण 4: मोटर की गति को नियंत्रित करने के लिए स्लाइडर को हिलाएं।',
      'step4_decrease': 'प्रतिरोध कम ↓ धारा बढ़ी ↑ (मोटर तेज़!)',
      'step4_increase': 'प्रतिरोध बढ़ा ↑ धारा घटी ↓ (मोटर धीमी!)',
      'step4_success':
          'अवलोकन: रियोस्टेट प्रतिरोध (R) बदलकर धारा (I) को बदलता है। लैब पूर्ण!',
    },
  },
});

// Circuit layout constants (the source's ZONES, in a 660x560 board whose
// electrical centre sits at (330, 320)).
const double _boardW = 660;
const double _boardH = 560;
const double _cx = 330;
const double _cy = 320;
const double _fixedR = 4.0;

class Cl10SCh11A3OhmSLawandResistancePage extends StatefulWidget {
  const Cl10SCh11A3OhmSLawandResistancePage({super.key});

  @override
  State<Cl10SCh11A3OhmSLawandResistancePage> createState() =>
      _Cl10SCh11A3OhmSLawandResistancePageState();
}

class _Cl10SCh11A3OhmSLawandResistancePageState
    extends State<Cl10SCh11A3OhmSLawandResistancePage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();

  // Wall clock for the render loop (electron dots, placeholder pulse, motor).
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker;

  // --- NAVIGATION STATE ---
  int _mission = 0;
  int _maxMission = 0;
  bool _canAdvance = false;

  // --- SIMULATION STATE ---
  final Map<String, bool> _placed = {
    'bat': false,
    'switch': false,
    'wire': false,
    'ammeter': false,
    'voltmeter': false,
  };
  bool _switchClosed = false;
  int _cells = 1;
  int _rheostatR = 10;
  List<({double v, double i})> _dataLog = [];

  // --- GRAPH STATE ---
  bool _plotted = false;
  int? _selectedPoint;

  // --- UI STATE ---
  bool _showLabels = true;
  String _msgKey = 'step1_start';
  Map<String, String> _msgParams = {};
  Timer? _rheoTimer;
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  bool _flashWhite = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker((e) => _clock.value = e.inMicroseconds / 1e6)
      ..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _rheoTimer?.cancel();
    _ticker.dispose();
    _clock.dispose();
    _flash.dispose();
    _zoom.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------- physics ----
  bool get _isComplete => _placed.values.every((p) => p);

  ({double v, double i, double r}) get _physics {
    // Mission 4 assumes the circuit is pre-built, exactly like the source.
    final built = _mission == 3 || _isComplete;
    if (!built || !_switchClosed) {
      return (v: _mission == 3 ? 6.0 : 0.0, i: 0.0, r: _fixedR);
    }
    final v = _mission == 3 ? 6.0 : _cells * 1.5;
    final r = _mission == 3 ? (2 + _rheostatR).toDouble() : _fixedR;
    return (v: v, i: v / r, r: r);
  }

  double _round2(double x) => double.parse(x.toStringAsFixed(2));

  // ------------------------------------------------------- navigation ----
  void _goToStep(int id, {bool sound = true}) {
    _rheoTimer?.cancel();
    // Source: AudioEngine.click() on every goToStep; step changes map to the
    // scenario chime here.
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _canAdvance = false;
      _msgParams = {};
      _msgKey = 'step${id + 1}_start';
      _mission = id;
      switch (id) {
        case 0:
          _placed.updateAll((k, v) => false);
          _switchClosed = false;
        case 1:
          _placed.updateAll((k, v) => true);
          _switchClosed = true;
          _cells = 1;
          _dataLog = [];
        case 2:
          _plotted = false;
          _selectedPoint = null;
          // Dummy data if the collection step was skipped (source behaviour).
          if (_dataLog.length < 3) {
            _dataLog = [
              (v: 1.5, i: 0.38),
              (v: 3.0, i: 0.75),
              (v: 4.5, i: 1.12),
              (v: 6.0, i: 1.50),
            ];
          }
        case 3:
          _switchClosed = true;
          _cells = 4;
          _rheostatR = 10;
      }
    });
    // Source: useEffect auto-records the first reading on entering step 2.
    if (id == 1) _autoRecordFirst();
  }

  void _autoRecordFirst() {
    final p = _physics;
    setState(() {
      _dataLog = [(v: p.v, i: _round2(p.i))];
      _msgKey = 'step2_recorded';
      _msgParams = {'v': p.v.toStringAsFixed(1), 'n': '2'};
    });
    _rt_playSfx(_rt_Sfx.correct); // source: AudioEngine.success()
  }

  void _nextStep() {
    if (!_canAdvance) return;
    _rt_playSfx(_rt_Sfx.click);
    final next = _mission + 1;
    if (next < 4) {
      if (next > _maxMission) _maxMission = next;
      _goToStep(next, sound: false);
    } else {
      setState(() => _maxMission = 4);
      // showSuccess plays the success chime (source: AudioEngine.success()).
      _shell.showSuccess(
        title: _tx.s('pop.title'),
        message: _tx.s('pop.desc'),
        icon: Icons.emoji_events,
        buttonLabel: _tx.s('pop.btn'),
        onClose: () {
          if (mounted) _goToStep(0, sound: false);
        },
      );
    }
  }

  void _prevStep() {
    if (_mission == 0) return;
    _rt_playSfx(_rt_Sfx.click);
    _goToStep(_mission - 1, sound: false);
  }

  void _restart() {
    _rheoTimer?.cancel();
    setState(() {
      _maxMission = 0;
      _plotted = false;
      _selectedPoint = null;
      _dataLog = [];
      _cells = 1;
      _rheostatR = 10;
      _showLabels = true;
    });
    _zoom.reset();
    _goToStep(0, sound: false); // the shell already played the restart sound
  }

  // ------------------------------------------------------ interactions ----
  void _error(String key, {bool short = false}) {
    // Source: AudioEngine.error() / AudioEngine.shortCircuit() + flash overlay.
    _rt_playSfx(_rt_Sfx.wrong);
    _flashWhite = short;
    _flash.forward(from: 0);
    _shell.showToast(
      _tx.s('messages.$key'),
      color: _rt_Tw.red500,
      icon: Icons.warning_amber_rounded,
    );
  }

  String? _slotFor(String type) => switch (type) {
    'battery' => 'bat',
    'switch' => 'switch',
    'bulb' || 'wire' => 'wire',
    'ammeter' => 'ammeter',
    'voltmeter' => 'voltmeter',
    _ => null,
  };

  void _place(String slot) {
    if (_placed[slot] ?? false) return;
    _rt_playSfx(_rt_Sfx.pop); // source: AudioEngine.snap()
    setState(() {
      _placed[slot] = true;
      if (_isComplete) _msgKey = 'step1_ready';
    });
  }

  /// Tap on a battery / key / nichrome / wire chip: places the component into
  /// its only slot (the twin of the source's drag, per project convention).
  /// The meters have no tap twin (see _invChip).
  void _tapPlace(String type) {
    final slot = _slotFor(type);
    if (slot == null || (_placed[slot] ?? false)) return;
    _place(slot);
  }

  void _dropOnSeriesZone(String type) {
    if (_mission != 0) return;
    if (type == 'voltmeter') {
      _error('step1_error_series'); // red flash
    } else if (type == 'ammeter') {
      _place('ammeter');
    }
  }

  void _dropOnParallelZone(String type) {
    if (_mission != 0) return;
    if (type == 'ammeter') {
      _error('step1_error_parallel', short: true); // white "short" flash
    } else if (type == 'voltmeter') {
      _place('voltmeter');
    }
  }

  void _toggleSwitch() {
    if (!(_placed['switch'] ?? false) && _mission != 3) return;
    if (_mission == 0 && !_isComplete) {
      _error('step1_error_incomplete');
      return;
    }
    _rt_playSfx(_rt_Sfx.toggle); // source: AudioEngine.click()
    final closing = !_switchClosed;
    setState(() {
      _switchClosed = closing;
      if (closing && _isComplete && _mission == 0) {
        _msgKey = 'step1_success';
        _canAdvance = true;
      }
    });
    if (closing && _isComplete && _mission == 0) {
      _rt_playSfx(_rt_Sfx.correct); // source: AudioEngine.success()
    }
  }

  void _recordData() {
    final p = _physics;
    if (_dataLog.any((d) => (d.v - p.v).abs() < 0.1)) {
      _error('step2_duplicate');
      return;
    }
    _rt_playSfx(_rt_Sfx.correct); // source: AudioEngine.success()
    setState(() {
      _dataLog = [..._dataLog, (v: p.v, i: _round2(p.i))]
        ..sort((a, b) => a.v.compareTo(b.v));
      if (_dataLog.length < 3) {
        _msgKey = 'step2_recorded';
        _msgParams = {
          'v': p.v.toStringAsFixed(1),
          'n': '${3 - _dataLog.length}',
        };
      } else {
        _msgKey = 'step2_success';
        _msgParams = {};
        _canAdvance = true;
      }
    });
  }

  void _plotGraph() {
    _rt_playSfx(
      _rt_Sfx.magic,
    ); // line-reveal moment (source: AudioEngine.click())
    setState(() {
      _plotted = true;
      _msgKey = 'step3_plotted';
    });
  }

  void _selectPoint(int i) {
    _rt_playSfx(
      _rt_Sfx.correct,
    ); // verification moment (source: AudioEngine.click())
    setState(() {
      _selectedPoint = i;
      _msgKey = 'step3_success';
      _canAdvance = true;
    });
  }

  void _onCells(double v) {
    final nv = v.round();
    if (nv == _cells) return;
    _rt_playSfx(
      _rt_Sfx.tap,
      volume: 0.4,
    ); // source: AudioEngine.click() per change
    setState(() => _cells = nv);
  }

  void _onRheostat(double v) {
    final nv = v.round();
    if (nv == _rheostatR) return;
    _rt_playSfx(
      _rt_Sfx.tap,
      volume: 0.4,
    ); // source: AudioEngine.click() per change
    final increased = nv > _rheostatR;
    setState(() {
      _rheostatR = nv;
      _msgKey = increased ? 'step4_increase' : 'step4_decrease';
    });
    if (!_canAdvance && (nv == 0 || nv == 20)) {
      setState(() => _canAdvance = true);
      _rheoTimer?.cancel();
      _rheoTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() => _msgKey = 'step4_success');
        _rt_playSfx(_rt_Sfx.success); // source: AudioEngine.success()
      });
    }
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  String get _guideText {
    var t = _tx.s('messages.$_msgKey');
    _msgParams.forEach((k, v) => t = t.replaceAll('{$k}', v));
    return t;
  }

  // ----------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final step = _tx.list('explore.steps')[_mission] as Map;
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.blue600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
              headerSubtitleColor: Color(0xFFBFDBFE),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.electric_bolt,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: _showLabels ? Icons.label : Icons.label_off,
                tooltip: _tx.s('ui.toggleLabels'),
                onTap: _toggleLabels,
              ),
            ],
            hint: _rt_StepHint(
              number: '${_mission + 1}',
              text: step['do'] as String,
              label: step['title'] as String,
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.science,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _rt_ZoomableCanvas(
              controller: _zoom,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _mission == 0 ? 104 : 10,
                  6,
                  (_mission == 1 || _mission == 3) ? 235 : 10,
                  86,
                ),
                child: Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: _boardW,
                      height: _boardH,
                      child: _circuitBoard(),
                    ),
                  ),
                ),
              ),
            ),
            canvasOverlays: [
              // Error / short-circuit flash (the source's flash overlays).
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _flash,
                    builder: (_, _) {
                      final v = _flash.value;
                      final o = _flash.isAnimating
                          ? (_flashWhite
                                ? math.sin(3 * math.pi * v).abs() * 0.6
                                : math.sin(math.pi * v) * 0.4)
                          : 0.0;
                      return o == 0
                          ? const SizedBox.shrink()
                          : Container(
                              color:
                                  (_flashWhite ? Colors.white : _rt_Tw.red500)
                                      .withValues(alpha: o),
                            );
                    },
                  ),
                ),
              ),
              if (_mission == 0) _inventoryPanel(),
              if (_mission == 1) ...[
                Positioned(top: 56, right: 60, width: 198, child: _voltPanel()),
                Positioned(
                  top: 56,
                  left: 8,
                  width: 150,
                  child: _notebookPanel(),
                ),
              ],
              if (_mission == 3)
                Positioned(top: 56, right: 60, width: 198, child: _rheoPanel()),
              if (_mission == 2) _graphOverlay(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                // QA C10-11.3-17: skip the first portrait-width frames.
                child: Center(child: _rt_MinWidthGate(child: _guideBar())),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------ circuit board ---
  Widget _circuitBoard() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CircuitPainter(
              clock: _clock,
              mission: _mission,
              placed: Map.of(_placed),
              switchClosed: _switchClosed,
              cells: _cells,
              rheostatR: _rheostatR,
              volts: _physics.v,
              amps: _physics.i,
              complete: _isComplete,
              showLabels: _showLabels,
              labels: {
                for (final k in [
                  'battery',
                  'switch',
                  'ammeter',
                  'voltmeter',
                  'bulb',
                  'motor',
                  'rheostat',
                ])
                  k: _tx.s('components.$k'),
              },
            ),
          ),
        ),
        // Drop zones (mission 1 only; the source's handleDrop zones).
        if (_mission == 0) ...[
          _zone(
            'zone-top',
            const Rect.fromLTWH(210, 120, 240, 100),
            (t) => t == 'bulb' || t == 'wire',
            (t) => _place('wire'),
          ),
          _zone(
            'zone-parallel',
            const Rect.fromLTWH(220, 10, 220, 120),
            (t) => t == 'voltmeter' || t == 'ammeter',
            _dropOnParallelZone,
          ),
          _zone(
            'zone-right',
            const Rect.fromLTWH(510, 245, 140, 150),
            (t) => t == 'ammeter' || t == 'voltmeter',
            _dropOnSeriesZone,
          ),
          _zone(
            'zone-bottom',
            const Rect.fromLTWH(235, 420, 190, 100),
            (t) => t == 'battery',
            (t) => _place('bat'),
          ),
        ],
        // Switch slot: drop target in mission 1, tap target in every mission.
        Positioned(
          left: 20,
          top: 280,
          width: 120,
          height: 140,
          child: DragTarget<String>(
            onWillAcceptWithDetails: (d) => _mission == 0 && d.data == 'switch',
            onAcceptWithDetails: (d) => _place('switch'),
            builder: (_, cand, _) => GestureDetector(
              key: const ValueKey('switch-hit'),
              behavior: HitTestBehavior.opaque,
              onTap: _toggleSwitch,
              child: Container(
                color: cand.isNotEmpty
                    ? _rt_Tw.blue500.withValues(alpha: 0.12)
                    : Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _zone(
    String key,
    Rect r,
    bool Function(String) will,
    void Function(String) onDrop,
  ) {
    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: DragTarget<String>(
        key: ValueKey(key),
        onWillAcceptWithDetails: (d) => will(d.data),
        onAcceptWithDetails: (d) => onDrop(d.data),
        builder: (_, cand, _) => Container(
          color: cand.isNotEmpty
              ? _rt_Tw.blue500.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
      ),
    );
  }

  // ---------------------------------------------------------- overlays ----
  Widget _glass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(10),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
      ),
      child: child,
    );
  }

  Widget _panelHeader(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: _rt_Lab.textMuted,
              ),
            ),
          ),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }

  /// Mission 1: the source's left inventory panel, as a compact left column.
  Widget _inventoryPanel() {
    const items = [
      ('ammeter', Icons.speed, _rt_Tw.blue400),
      ('voltmeter', Icons.av_timer, _rt_Tw.orange400),
      ('battery', Icons.battery_charging_full, _rt_Tw.yellow400),
      ('switch', Icons.toggle_off, _rt_Tw.slate400),
      ('bulb', Icons.lightbulb, _rt_Tw.red400),
      ('wire', Icons.horizontal_rule, _rt_Tw.slate300),
    ];
    return Positioned(
      left: 8,
      top: 56,
      width: 96,
      child: _glass(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: Text(
                _tx.s('ui.instruments').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: _rt_Lab.textMuted,
                ),
              ),
            ),
            for (final (id, icon, color) in items) _invChip(id, icon, color),
          ],
        ),
      ),
    );
  }

  Widget _invChip(String id, IconData icon, Color color) {
    final used = _placed[_slotFor(id) ?? ''] ?? false;
    final label = _tx.s('components.$id');
    Widget chip(bool ghost) => Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: ghost ? _rt_Tw.blue900.withValues(alpha: 0.9) : _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ghost ? _rt_Tw.blue400 : _rt_Lab.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: ghost ? Colors.white : _rt_Lab.text,
              ),
            ),
          ),
        ],
      ),
    );
    if (used) {
      return Opacity(
        key: ValueKey('inv-$id'),
        opacity: 0.3,
        child: chip(false),
      );
    }
    // QA C10-11.3-01: the meters are drag-only (as in the source), so the
    // series/parallel choice and its error protection stay with the student.
    final tapPlaces = id != 'ammeter' && id != 'voltmeter';
    return Draggable<String>(
      key: ValueKey('inv-$id'),
      data: id,
      onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 96, child: chip(true)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip(false)),
      child: tapPlaces
          ? Tooltip(
              message: _tx.s('ui.inv_hint'),
              child: GestureDetector(
                onTap: () => _tapPlace(id),
                child: chip(false),
              ),
            )
          : chip(false),
    );
  }

  /// Mission 2: the source's right-hand voltage control deck.
  Widget _voltPanel() {
    return _glass(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelHeader(_tx.s('ui.volt_ctrl'), Icons.bolt, _rt_Tw.yellow400),
          _rt_LabeledSlider(
            key: const ValueKey('cells-slider'),
            label: _tx.s('ui.cells_label'),
            value: _cells.toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            valueText: '$_cells',
            color: _rt_Tw.blue500,
            onChanged: _onCells,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.5V',
                style: TextStyle(fontSize: 9, color: _rt_Lab.textFaint),
              ),
              Text(
                '6.0V',
                style: TextStyle(fontSize: 9, color: _rt_Lab.textFaint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _rt_ActionButton(
            key: const ValueKey('record-btn'),
            label: _tx.s('ui.record_btn'),
            icon: Icons.edit_note,
            color: _rt_Tw.blue600,
            expand: true,
            onPressed: _recordData,
          ),
        ],
      ),
    );
  }

  /// Mission 2: the source's left-hand floating lab notebook.
  Widget _notebookPanel() {
    return _glass(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('ui.notebook').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              Text(
                '${_dataLog.length} ${_tx.s('ui.readings')}',
                style: TextStyle(fontSize: 9, color: _rt_Lab.textFaint),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _rt_Lab.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _tx.s('ui.v_head'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: _rt_Lab.textFaint,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    _tx.s('ui.i_head'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: _rt_Lab.textFaint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final d in _dataLog)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d.v.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _rt_Lab.text,
                    ),
                  ),
                  Text(
                    d.i.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _rt_Lab.text,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Mission 4: rheostat control panel.
  Widget _rheoPanel() {
    return _glass(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelHeader(_tx.s('ui.rheo_ctrl'), Icons.speed, _rt_Tw.orange400),
          _rt_LabeledSlider(
            key: const ValueKey('rheo-slider'),
            label: _tx.s('ui.resistance_label'),
            value: _rheostatR.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            valueText: '$_rheostatR Ω',
            color: _rt_Tw.orange500,
            onChanged: _onRheostat,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _tx.s('ui.min_fast'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: _rt_Lab.textFaint),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _tx.s('ui.max_slow'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: _rt_Lab.textFaint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${_tx.s('ui.motor_current')}:',
                    style: TextStyle(fontSize: 10.5, color: _rt_Lab.textMuted),
                  ),
                ),
                Text(
                  '${_physics.i.toStringAsFixed(2)}A',
                  key: const ValueKey('motor-current'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.blue400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mission 3: the interactive V-I graph (replaces the circuit view).
  Widget _graphOverlay() {
    return Positioned.fill(
      left: 14,
      right: 60,
      top: 10,
      bottom: 92,
      child: Center(
        child: _glass(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _graphArea()),
              const SizedBox(width: 10),
              SizedBox(width: 168, child: _graphInfo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _graphArea() {
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        border: Border(
          left: BorderSide(color: _rt_Lab.borderStrong, width: 2),
          bottom: BorderSide(color: _rt_Lab.borderStrong, width: 2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (!_plotted)
                Center(
                  child: _rt_ActionButton(
                    key: const ValueKey('plot-btn'),
                    label: _tx.s('ui.plot_btn'),
                    icon: Icons.show_chart,
                    color: _rt_Tw.blue600,
                    onPressed: _plotGraph,
                  ),
                )
              else ...[
                // Line of best fit: V = 4I maps exactly corner to corner.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _BestFitLinePainter()),
                  ),
                ),
                for (final (i, d) in _dataLog.indexed)
                  Positioned(
                    left: (d.i / 2) * w - 9,
                    top: h - (d.v / 8) * h - 9,
                    child: GestureDetector(
                      key: ValueKey('pt-$i'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectPoint(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _selectedPoint == i
                              ? _rt_Tw.yellow400
                              : _rt_Tw.blue500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              Positioned(
                right: 6,
                bottom: 4,
                child: Text(
                  '${_tx.s('ui.current_axis')} →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              Positioned(
                left: 6,
                top: 4,
                child: Text(
                  '${_tx.s('ui.voltage_axis')} ↑',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _graphInfo() {
    if (_selectedPoint == null) {
      return Center(
        child: Text(
          _plotted ? _tx.s('ui.graph_hint_click') : _tx.s('ui.graph_hint_plot'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontStyle: FontStyle.italic,
            color: _rt_Lab.textFaint,
          ),
        ),
      );
    }
    final d = _dataLog[_selectedPoint!];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('ui.calc').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _rt_Lab.textFaint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R = ${d.v.toStringAsFixed(1)}V / ${d.i.toStringAsFixed(2)}A',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontFamily: 'monospace',
                    color: _rt_Lab.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '4.0 Ω',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.emerald400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue500)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('ui.conc'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tx.s('analysis.table_rows.1.out'),
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom-centre guide bar: prev | instruction | next (the source's
  /// navigation strip).
  Widget _guideBar() {
    final canPrev = _mission > 0;
    return Container(
      constraints: const BoxConstraints(maxWidth: 470),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            key: const ValueKey('nav-prev'),
            onTap: canPrev ? _prevStep : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 62,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: _rt_Lab.border)),
              ),
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: canPrev ? _rt_Lab.text : _rt_Lab.textFaint,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_tx.s('ui.inst').toUpperCase()} • ${_tx.s('ui.step_label').toUpperCase()} ${_mission + 1}/4',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: _rt_Tw.blue400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _guideText,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: _rt_Lab.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            key: const ValueKey('nav-next'),
            onTap: _canAdvance ? _nextStep : null,
            child: Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: _canAdvance ? _rt_Tw.blue600 : Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (_mission == 3 ? _tx.s('ui.finish') : _tx.s('ui.next'))
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: _canAdvance ? Colors.white : _rt_Lab.textFaint,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _mission == 3 ? Icons.flag : Icons.chevron_right,
                    size: 16,
                    color: _canAdvance ? Colors.white : _rt_Lab.textFaint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _exploreTab() {
    final steps = _tx.list('explore.steps');
    final whyCards = _tx.list('why.cards');
    final guideSteps = _tx.list('guide.steps');
    final rows = _tx.list('analysis.table_rows');
    const whyColors = [_rt_Tw.yellow400, _rt_Tw.blue400, _rt_Tw.red400];
    const whyIcons = [
      Icons.cell_tower,
      Icons.memory,
      Icons.warning_amber_rounded,
    ];
    const guideColors = [
      _rt_Tw.blue500,
      _rt_Tw.green500,
      _rt_Tw.yellow500,
      _rt_Tw.purple500,
    ];
    const rowColors = [_rt_Tw.blue400, _rt_Tw.green400, _rt_Tw.orange400];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('explore.objective_title'),
          desc: _tx.s('explore.objective_desc'),
          accent: _rt_Tw.blue600,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.science),
              for (final (i, s) in steps.indexed)
                _rt_StepCard(
                  key: ValueKey('step-card-$i'),
                  number: i + 1,
                  title: '${(s as Map)['title']} • ${s['desc']}',
                  desc:
                      '${_tx.s('actions.do')}: ${s['do']}\n${_tx.s('actions.observe')}: ${s['observe']}',
                  actionLabel: _tx.s('ui.open_step'),
                  actionIcon: Icons.play_arrow,
                  accent: _rt_Tw.blue600,
                  active: _mission == i,
                  onAction: () => _goToStep(i),
                  extra: i < _maxMission
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: _rt_Tw.emerald400,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _tx.s('ui.completed'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _rt_Tw.emerald400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              const SizedBox(height: 8),
              _rt_SectionLabel(_tx.s('tabs.why'), icon: Icons.lightbulb),
              _rt_InfoCard(
                body: _tx.s('why.intro'),
                color: _rt_Tw.blue500,
                leftBorder: true,
              ),
              for (final (i, c) in whyCards.indexed)
                _rt_InfoCard(
                  title: (c as Map)['title'] as String,
                  body: c['desc'] as String,
                  icon: whyIcons[i],
                  color: whyColors[i],
                ),
              const SizedBox(height: 8),
              _rt_SectionLabel(_tx.s('tabs.guide'), icon: Icons.school),
              _rt_InfoCard(
                body: _tx.s('guide.intro'),
                color: _rt_Tw.slate500,
                leftBorder: true,
              ),
              for (final (i, g) in guideSteps.indexed)
                _rt_InfoCard(
                  title: (g as Map)['title'] as String,
                  body: g['desc'] as String,
                  color: guideColors[i],
                  leftBorder: true,
                ),
              const SizedBox(height: 8),
              _rt_SectionLabel(_tx.s('tabs.analysis'), icon: Icons.insights),
              _rt_InfoCard(
                title: _tx.s('analysis.def_title'),
                body: _tx.s('analysis.def_text'),
                icon: Icons.menu_book,
                color: _rt_Tw.blue500,
              ),
              Container(
                decoration: BoxDecoration(
                  color: _rt_Lab.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rt_Lab.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Lab.overlay,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _tx.s('analysis.table_head.0').toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: _rt_Lab.textFaint,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _tx.s('analysis.table_head.1').toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: _rt_Lab.textFaint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final (i, r) in rows.indexed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: i == 0
                              ? null
                              : Border(top: BorderSide(color: _rt_Lab.border)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                (r as Map)['obs'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: rowColors[i],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r['out'] as String,
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar toggle button (labels on/off), matching the shell's round buttons.
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
            color: _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? _rt_Tw.yellow400 : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The V-I best-fit line (source: SVG line, slope R = 4 -> corner to corner).
class _BestFitLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      Paint()
        ..color = _rt_Tw.yellow500
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BestFitLinePainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Circuit painter: a faithful port of the source's canvas render loop.
class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.clock,
    required this.mission,
    required this.placed,
    required this.switchClosed,
    required this.cells,
    required this.rheostatR,
    required this.volts,
    required this.amps,
    required this.complete,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: clock);

  final ValueListenable<double> clock;
  final int mission;
  final Map<String, bool> placed;
  final bool switchClosed;
  final int cells;
  final int rheostatR;
  final double volts;
  final double amps;
  final bool complete;
  final bool showLabels;
  final Map<String, String> labels;

  static const _labelColor = Color(0xFF94A3B8);
  static const double _lx = -250, _rx = 250, _ty = -150, _by = 150;

  bool _has(String k) => mission == 3 || (placed[k] ?? false);

  @override
  void paint(Canvas canvas, Size size) {
    _grid(canvas, size);
    if (mission == 2) return; // graph overlay replaces the circuit
    final t = clock.value;
    canvas.save();
    canvas.translate(_cx, _cy);

    final built = mission == 3 || complete;
    final flowing = built && switchClosed && amps > 0;

    // WIRES
    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = flowing ? const Color(0xFFF59E0B) : const Color(0xFF64748B);
    final wp = Path();
    if (_has('switch')) {
      wp.moveTo(_lx, _ty);
      wp.lineTo(_lx, 0);
      wp.moveTo(_lx, 60);
      wp.lineTo(_lx, _by);
    }
    if (_has('bat')) {
      wp.moveTo(_lx, _by);
      wp.lineTo(-40, _by);
      wp.moveTo(40, _by);
      wp.lineTo(_rx, _by);
    }
    if (_has('ammeter')) {
      wp.moveTo(_rx, _by);
      wp.lineTo(_rx, 40);
      wp.moveTo(_rx, -40);
      wp.lineTo(_rx, _ty);
    }
    if (_has('wire')) {
      wp.moveTo(_rx, _ty);
      wp.lineTo(60, _ty);
      wp.moveTo(-60, _ty);
      wp.lineTo(_lx, _ty);
    }
    canvas.drawPath(wp, wire);

    _battery(canvas, t);
    _switchOrRheostat(canvas, t);
    _ammeter(canvas, t);
    _resistorOrMotor(canvas, t);
    _voltmeter(canvas, t);
    if (flowing) _electrons(canvas, t);

    canvas.restore();
  }

  void _grid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y <= size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  // 1. BATTERY --------------------------------------------------------------
  void _battery(Canvas canvas, double t) {
    if (_has('bat')) {
      final count = mission == 1 ? cells : (mission == 3 ? 4 : 1);
      canvas.save();
      canvas.translate(0, _by);
      for (var i = 0; i < count; i++) {
        final x = (i - (count - 1) / 2) * 25;
        final rect = Rect.fromLTWH(x - 12, -18, 24, 36);
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E293B), Color(0xFF64748B), Color(0xFF1E293B)],
            ).createShader(rect),
        );
        canvas.drawRect(
          Rect.fromLTWH(x + 12, -8, 6, 16),
          Paint()..color = const Color(0xFFEAB308),
        );
      }
      if (showLabels) _text(canvas, labels['battery']!, const Offset(0, 40));
      canvas.restore();
    } else if (mission == 0) {
      _placeholder(
        canvas,
        t,
        const Offset(0, _by),
        const Size(80, 50),
        labels['battery']!,
      );
    }
  }

  // 2. SWITCH / RHEOSTAT ----------------------------------------------------
  void _switchOrRheostat(Canvas canvas, double t) {
    if (mission == 3) {
      canvas.save();
      canvas.translate(_lx, 30);
      canvas.drawRect(
        const Rect.fromLTWH(-20, -30, 40, 60),
        Paint()..color = const Color(0xFF334155),
      );
      final coil = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFEAB308);
      for (var j = 0; j < 8; j++) {
        canvas.drawLine(
          Offset(-15, -25 + j * 7.0),
          Offset(15, -25 + j * 7.0),
          coil,
        );
      }
      final slideY = -25 + (rheostatR / 20) * 50;
      canvas.drawRect(
        Rect.fromLTWH(-25, slideY - 3, 10, 6),
        Paint()..color = const Color(0xFFEF4444),
      );
      if (showLabels) _text(canvas, labels['rheostat']!, const Offset(0, 48));
      canvas.restore();
      return;
    }
    if (placed['switch'] ?? false) {
      canvas.save();
      canvas.translate(_lx, 30);
      canvas.drawRect(
        const Rect.fromLTWH(-15, -40, 30, 80),
        Paint()..color = const Color(0xFF475569),
      );
      final pivot = Paint()..color = const Color(0xFFCBD5E1);
      canvas.drawCircle(const Offset(0, -25), 6, pivot);
      canvas.drawCircle(const Offset(0, 25), 6, pivot);
      canvas.drawLine(
        const Offset(0, 25),
        switchClosed ? const Offset(0, -25) : const Offset(-25, -10),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      // Tap invitation ring once the circuit is complete but still open.
      if (mission == 0 && complete && !switchClosed) {
        canvas.drawCircle(
          Offset.zero,
          40,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = _rt_Tw.blue500.withValues(
              alpha: 0.35 + 0.25 * math.sin(t * 4).abs(),
            ),
        );
      }
      if (showLabels) _text(canvas, labels['switch']!, const Offset(-45, 0));
      canvas.restore();
    } else if (mission == 0) {
      _placeholder(
        canvas,
        t,
        const Offset(_lx, 30),
        const Size(40, 80),
        labels['switch']!,
      );
    }
  }

  // 3. AMMETER ----------------------------------------------------------
  void _ammeter(Canvas canvas, double t) {
    if (_has('ammeter')) {
      canvas.save();
      canvas.translate(_rx, 0);
      final body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -30, 60, 60),
        const Radius.circular(8),
      );
      canvas.drawRRect(body, Paint()..color = const Color(0xFFF1F5F9));
      canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF334155),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-22, -15, 44, 20),
        Paint()..color = const Color(0xFFE2E8F0),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-22, -15, 44, 20),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF334155),
      );
      _text(
        canvas,
        '${amps.toStringAsFixed(2)}A',
        const Offset(0, -5),
        color: const Color(0xFF0F172A),
        mono: true,
      );
      final term = Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 4;
      canvas.drawLine(const Offset(0, -30), const Offset(0, -40), term);
      canvas.drawLine(const Offset(0, 30), const Offset(0, 40), term);
      if (showLabels) _text(canvas, labels['ammeter']!, const Offset(0, 52));
      canvas.restore();
    } else if (mission == 0) {
      _placeholder(
        canvas,
        t,
        const Offset(_rx, 0),
        const Size(60, 60),
        labels['ammeter']!,
      );
    }
  }

  // 4. RESISTOR / MOTOR ---------------------------------------------------
  void _resistorOrMotor(Canvas canvas, double t) {
    if (_has('wire')) {
      canvas.save();
      canvas.translate(0, _ty);
      if (mission == 3) {
        // Motor disc + spinning blades.
        final disc = Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.15, -0.15),
            colors: [Color(0xFFE2E8F0), Color(0xFF64748B)],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 40));
        canvas.drawCircle(Offset.zero, 40, disc);
        canvas.drawCircle(
          Offset.zero,
          40,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF334155),
        );
        final flowing = switchClosed && amps > 0;
        final speed = flowing ? amps * 15 : 0.0;
        canvas.save();
        canvas.rotate(t * speed * 5);
        final blade = Paint()..color = _rt_Tw.blue500.withValues(alpha: 0.9);
        for (var i = 0; i < 3; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: const Offset(0, -45),
              width: 24,
              height: 90,
            ),
            blade,
          );
          canvas.rotate(math.pi * 2 / 3);
        }
        canvas.restore();
        canvas.drawCircle(
          Offset.zero,
          6,
          Paint()..color = const Color(0xFF334155),
        );
        if (showLabels) _text(canvas, labels['motor']!, const Offset(0, 55));
      } else {
        // Nichrome zig-zag; glows red when I > 0.5 A.
        final hot = amps > 0.5;
        final zig = Path()..moveTo(-60, 0);
        for (var i = 0; i < 12; i++) {
          zig.lineTo(-50 + i * 10.0, i.isOdd ? -12 : 12);
        }
        zig.lineTo(60, 0);
        if (hot) {
          canvas.drawPath(
            zig,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 10
              ..strokeCap = StrokeCap.round
              ..color = const Color(0xFFEF4444).withValues(alpha: 0.4)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, amps * 4 + 4),
          );
        }
        canvas.drawPath(
          zig,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = hot ? const Color(0xFFEF4444) : const Color(0xFFB45309),
        );
        if (showLabels) _text(canvas, labels['bulb']!, const Offset(0, -30));
      }
      canvas.restore();
    } else if (mission == 0) {
      _placeholder(
        canvas,
        t,
        const Offset(0, _ty),
        const Size(120, 30),
        labels['bulb']!,
      );
    }
  }

  // 5. VOLTMETER ------------------------------------------------------------
  void _voltmeter(Canvas canvas, double t) {
    if ((placed['voltmeter'] ?? false) && mission != 3) {
      canvas.save();
      canvas.translate(0, -250);
      final body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-50, -40, 100, 80),
        const Radius.circular(10),
      );
      canvas.drawRRect(body, Paint()..color = const Color(0xFFFACC15));
      canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFA16207),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-35, -30, 70, 30),
        Paint()..color = const Color(0xFF1E293B),
      );
      _textRight(
        canvas,
        volts.toStringAsFixed(2),
        const Offset(15, -15),
        color: const Color(0xFF4ADE80),
        size: 18,
      );
      _text(
        canvas,
        'V',
        const Offset(28, -15),
        color: const Color(0xFF4ADE80),
        size: 10,
      );
      // Leads down to the top wire.
      final black = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF1E293B);
      final red = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFEF4444);
      canvas.drawPath(
        Path()
          ..moveTo(-20, 40)
          ..cubicTo(-20, 100, -100, 50, -100, 100),
        black,
      );
      canvas.drawPath(
        Path()
          ..moveTo(20, 40)
          ..cubicTo(20, 100, 100, 50, 100, 100),
        red,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-103, 90, 6, 20),
        Paint()..color = const Color(0xFFCBD5E1),
      );
      canvas.drawRect(
        const Rect.fromLTWH(97, 90, 6, 20),
        Paint()..color = const Color(0xFFCBD5E1),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-103, 110, 6, 10),
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawRect(
        const Rect.fromLTWH(97, 110, 6, 10),
        Paint()..color = const Color(0xFFEF4444),
      );
      if (showLabels) {
        _text(
          canvas,
          labels['voltmeter']!,
          const Offset(0, -52),
          color: const Color(0xFFD97706),
        );
      }
      canvas.restore();
    } else if (mission == 0) {
      _placeholder(
        canvas,
        t,
        const Offset(0, -250),
        const Size(100, 80),
        labels['voltmeter']!,
      );
    }
  }

  // 6. ELECTRONS --------------------------------------------------------
  void _electrons(Canvas canvas, double t) {
    final speed = amps * 80;
    final offset = (t * speed) % 40;
    final dot = Paint()..color = _rt_Tw.blue500;
    const segs = [
      (_lx, _ty, _rx, _ty),
      (_rx, _ty, _rx, _by),
      (_rx, _by, _lx, _by),
      (_lx, _by, _lx, _ty),
    ];
    for (final (x1, y1, x2, y2) in segs) {
      final len = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
      final dx = (x2 - x1) / len;
      final dy = (y2 - y1) / len;
      for (var d = 0.0; d < len; d += 40) {
        final px = x1 + dx * ((d + offset) % len);
        final py = y1 + dy * ((d + offset) % len);
        // Skip dots crossing the battery / resistor bodies (source check).
        if (px.abs() < 30 && ((py - _by).abs() < 10 || (py - _ty).abs() < 10)) {
          continue;
        }
        canvas.drawCircle(Offset(px, py), 4, dot);
      }
    }
  }

  // ------------------------------------------------------------ helpers ---
  void _placeholder(
    Canvas canvas,
    double t,
    Offset center,
    Size s,
    String label,
  ) {
    final scale = 1 + math.sin(t * 1000 / 300) * 0.03;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _rt_Tw.blue500;
    _dashPath(
      canvas,
      Path()..addRect(
        Rect.fromCenter(center: Offset.zero, width: s.width, height: s.height),
      ),
      paint,
    );
    _text(
      canvas,
      label,
      const Offset(0, 0),
      color: _rt_Tw.blue400,
      bold: false,
    );
    canvas.restore();
  }

  void _dashPath(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 5, m.length)), paint);
        d += 10;
      }
    }
  }

  TextPainter _tp(
    String s, {
    Color color = _labelColor,
    double size = 12,
    bool bold = true,
    bool mono = false,
  }) {
    return TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          fontFamily: mono ? 'monospace' : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _text(
    Canvas canvas,
    String s,
    Offset center, {
    Color color = _labelColor,
    double size = 12,
    bool bold = true,
    bool mono = false,
  }) {
    final tp = _tp(s, color: color, size: size, bold: bold, mono: mono);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _textRight(
    Canvas canvas,
    String s,
    Offset right, {
    Color color = _labelColor,
    double size = 12,
  }) {
    final tp = _tp(s, color: color, size: size, mono: true);
    tp.paint(canvas, right - Offset(tp.width, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter old) =>
      old.mission != mission ||
      old.switchClosed != switchClosed ||
      old.cells != cells ||
      old.rheostatR != rheostatR ||
      old.volts != volts ||
      old.amps != amps ||
      old.complete != complete ||
      old.showLabels != showLabels ||
      !mapEquals(old.placed, placed) ||
      !mapEquals(old.labels, labels);
}
