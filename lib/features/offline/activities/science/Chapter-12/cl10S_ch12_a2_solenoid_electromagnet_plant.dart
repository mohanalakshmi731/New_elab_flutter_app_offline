// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 12.2: The Solenoid & Electromagnet
// Converted from Cl10S-Ch12-A2-TheSolenoidElectromagnetPlant.html
// (three.js + GSAP -> mini3d Scene3DView).
//
// Four missions on one bench: (1) power the solenoid and watch its bar-magnet
// field pattern appear, (2) insert a soft iron core so paper clips fly onto
// the new electromagnet, (3) drag the compass to the poles and reverse the
// battery to flip N/S, (4) an auto-piloted scrapyard crane lifts iron scrap
// (never the plastic) and drops it in the recycling bin. A floating control
// deck (power switch, core button, reverse battery, current slider) mirrors
// the HTML's, and the Why / Guide / Outcomes tabs live at the foot of the
// sidebar with the Finish Activity button.

// --- TRANSLATION DATA (source `const TEXT`, te block dropped) ---

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
  static const blue600 = Color(0xFF2563EB);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo900 = Color(0xFF312E81);
  static const red500 = Color(0xFFEF4444);
  static const amber500 = Color(0xFFF59E0B);
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
    required this.number,
    required this.title,
    required this.desc,
    required this.actionLabel,
    required this.onAction,
    this.active = false,
    this.done = false,
    this.locked = false,
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
  final bool done;
  final bool locked;
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
  final VoidCallback? onStart = null;

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

  _rt_V3 lerpTo(_rt_V3 to, double t) =>
      set(x + (to.x - x) * t, y + (to.y - y) * t, z + (to.z - z) * t);

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
  static double linear(double t) => t;
  static double outCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
  static double inOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;
  static double inOutQuad(double t) =>
      t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2).toDouble() / 2;
  static double outQuad(double t) => 1 - (1 - t) * (1 - t);
  static double inQuad(double t) => t * t;
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

  /// THREE.CircleGeometry(radius, segments, thetaStart, thetaLength), XY plane.
  factory _rt_Geometry3D.circle(
    double radius, {
    int segments = 32,
    double thetaStart = 0,
    double thetaLength = math.pi * 2,
  }) {
    final full = (thetaLength - math.pi * 2).abs() < 1e-6;
    final verts = <_rt_V3>[];
    if (!full) verts.add(_rt_V3());
    final count = full ? segments : segments + 1;
    for (var i = 0; i < count; i++) {
      final th = thetaStart + i / segments * thetaLength;
      verts.add(_rt_V3(radius * math.cos(th), radius * math.sin(th), 0));
    }
    return _rt_Geometry3D(verts, [List.generate(verts.length, (i) => i)]);
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

  /// Arbitrary data (THREE `userData`).
  Map<String, dynamic> userData = {};

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
    this.opacity = 1,
    this.dashed = false,
    this.segments = false,
    this.closed = false,
  });

  List<_rt_V3> points;
  Color color;
  double width;
  double opacity;
  bool dashed;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments;
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
    this.pixelHeight,
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

  _rt_V3 at(double t) => origin + direction * t;

  /// Intersection with the plane through [point] with [normal]; null if
  /// parallel or behind the ray.
  _rt_V3? intersectPlane(_rt_V3 point, _rt_V3 normal) {
    final denom = normal.dot(direction);
    if (denom.abs() < 1e-9) return null;
    final t = (point - origin).dot(normal) / denom;
    if (t < 0) return null;
    return at(t);
  }

  /// Intersection with the horizontal plane y = [y].
  _rt_V3? intersectY(double y) =>
      intersectPlane(_rt_V3(0, y, 0), _rt_V3(0, 1, 0));
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
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.cameraControls = true,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
  final void Function(_rt_SceneEvent e)? onTap = null;
  final bool Function(_rt_SceneEvent e)? onPointerDown;
  final void Function(_rt_SceneEvent e)? onPointerMove;
  final void Function(_rt_SceneEvent e)? onPointerUp;
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

  /// Waits [ms] milliseconds (in animation time).
  Future<void> wait(int ms) => run(ms, (_) {}, ease: _rt_Ease.linear);

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
    'title': 'The Solenoid & Electromagnet',
    'subtitle': 'Class 10 - Chapter 12 : Magnetic Effects of Electric Current',
    'intro_title': 'The Solenoid _rt_Lab',
    'intro_button': 'Enter Laboratory',
    'intro_foot': 'Solenoid • Electromagnet • Field Lines',
    'tab_why': 'Why?',
    'tab_guide': 'Guide',
    'tab_lab': 'Explore',
    'tab_quiz': 'Outcomes',
    'tag_realworld': 'Real World Link',
    'ctx_title': 'Why Learn This?',
    'ctx_intro':
        'The solenoid is the heart of almost every machine that converts electricity into motion!',
    'ex_crane': 'Scrapyard Cranes',
    'ex_crane_sub': 'Heavy Lifting',
    'ex_crane_desc':
        'Giant electromagnets (solenoids with iron cores) are used to lift tons of scrap metal cars effortlessly.',
    'ex_bell': 'Electric Bells',
    'ex_bell_sub': 'Sound Generation',
    'ex_bell_desc':
        'Inside an electric bell, a solenoid acts as an electromagnet to pull the striker against the gong rapidly.',
    'ex_speaker': 'Loudspeakers',
    'ex_speaker_sub': 'Audio',
    'ex_speaker_desc':
        'A solenoid coil vibrates back and forth when music plays through it, pushing air to create sound.',
    'guide_title': 'Classroom Context',
    'guide_context_1':
        'A coil of many circular turns of insulated copper wire wrapped closely in the shape of a cylinder is called a Solenoid.',
    'guide_context_2':
        'The magnetic field produced by a solenoid is similar to that of a bar magnet. One end acts as the North pole, the other as the South pole.',
    'g_s1_title': 'Step 1: The Solenoid Field',
    'g_s1_action': 'Power ON the circuit.',
    'g_s1_focus':
        'Observe the parallel field lines inside the coil. This indicates a uniform magnetic field.',
    'g_s2_title': 'Step 2: Polarity Check',
    'g_s2_action': 'Use the compass near the ends. Then Reverse Battery.',
    'g_s2_focus':
        'The poles swap when current direction reverses. The compass needle flips 180 degrees.',
    'g_s3_title': 'Step 3: Making an Electromagnet',
    'g_s3_action': 'Insert the Soft Iron Core.',
    'g_s3_focus':
        'Notice the field lines becoming much brighter/denser. The iron core magnifies the magnetic effect significantly.',
    'lbl_action': 'Action:',
    'lbl_focus': 'Focus:',
    'lbl_mission': 'Mission Objective',
    'mission_text':
        'Verify the magnetic field pattern of a solenoid and transform it into a powerful electromagnet.',
    'lbl_procedure': 'Procedure',
    'proc_s1_title': '1. Activate Solenoid',
    'lbl_do': 'Do:',
    'proc_s1_do': 'Turn ON the Power Switch.',
    'lbl_observe': 'Observe:',
    'proc_s1_obs': 'Field lines appear. Parallel lines inside, curved outside.',
    'proc_s2_title': '2. Create Electromagnet',
    'proc_s2_do': 'Click "Insert Core" to add soft iron.',
    'proc_s2_focus': 'The magnetic field strength intensifies significantly.',
    'proc_s3_title': '3. Check Polarity',
    'proc_s3_do': 'Drag compass near ends & Reverse Battery.',
    'proc_s3_obs': 'Compass flips direction as poles swap.',
    'proc_s4_title': '4. Scrapyard Challenge',
    'proc_s4_do': 'Watch the Scrapyard Crane in action.',
    'proc_s4_target': 'Drop Iron in Green Bin.',
    'lbl_target': 'Target:',
    'info_control':
        'Use the Control Deck on the top-right of the 3D view to interact with the equipment.',
    'deck_title': '_rt_Lab Controls',
    'switch': 'Power Supply',
    'current': 'Current',
    'btn_core': 'Insert Iron Core',
    'btn_core_remove': 'Remove Iron Core',
    'reverse': 'Reverse Battery',
    'current_task': 'Current Mission',
    'out_title': 'Learning Outcomes',
    'out_subtitle': 'Based on Class 10 Science Textbook',
    'out_1_title': 'Bar Magnet Behavior',
    'out_1_desc':
        'A current-carrying solenoid behaves like a bar magnet, with fixed North and South poles at its ends.',
    'out_2_title': 'Uniform Field',
    'out_2_desc':
        'The field lines inside the solenoid are in the form of parallel straight lines. This indicates that the magnetic field is the same at all points inside the solenoid (Uniform).',
    'out_3_title': 'Electromagnet',
    'out_3_desc':
        'A strong magnetic field produced inside a solenoid can be used to magnetize a piece of magnetic material, like soft iron, when placed inside the coil. The magnet so formed is called an electromagnet.',
    'finish': 'Finish Activity',
    'success_title': 'Mission Accomplished!',
    'success_msg': 'You have successfully mastered the Electromagnet.',
    's0_do': 'Turn ON the Power Switch.',
    's0_obs': 'Observe parallel field lines inside.',
    's1_do': "Click 'Insert Iron Core'.",
    's1_obs': 'Field becomes stronger (brighter lines).',
    's2_do': 'Drag compass & Reverse Battery.',
    's2_obs': 'Compass flips as poles swap.',
    's3_do': 'Use Crane Controls or Watch Demo.',
    's3_obs': 'Iron sticks, Plastic stays.',
    'step_finish': 'Observation',
    'btn_continue': 'Next',
    'msg_s0':
        'When electric current flows through the solenoid coil, a magnetic field is created. The parallel field lines inside indicate a uniform magnetic field.',
    'msg_s1':
        'Inserting a Soft Iron Core concentrates the magnetic field lines significantly. This creates a powerful Electromagnet capable of attracting iron objects strongly.',
    'msg_s2':
        'Reversing the direction of current reverses the magnetic poles (North becomes South). This is confirmed by the compass needle flipping 180 degrees.',
    'label_clips': 'Paper Clips',
    'auto_pilot_move': 'Auto-Pilot: Moving to Scrap Pile...',
    'lifting_scrap': 'Lifting Iron Scrap...',
    'transporting': 'Transporting to Recycling Bin...',
    'deactivating': 'Deactivating Magnet (Drop)...',
    'label_solenoid': 'Solenoid Coil',
    'label_core': 'Iron Core',
    'label_compass': 'Compass',
    // Keys added for the Flutter port (buttons the HTML drives via the deck).
    'btn_power_on': 'Power ON',
    'btn_demo': 'Replay Crane Demo',
    'btn_move_compass': 'Move Compass',
    'state_on': 'ON',
    'state_off': 'OFF',
    'lbl_labels': 'Show / hide labels',
    'lockView': 'Lock / unlock view',
  },
  'hi': {
    'title': 'सोलनॉइड और विद्युत चुंबक',
    'subtitle': 'कक्षा 10 - अध्याय 12: विद्युत धारा के चुंबकीय प्रभाव',
    'intro_title': 'सोलनॉइड प्रयोगशाला',
    'intro_button': 'प्रयोगशाला में प्रवेश करें',
    'intro_foot': 'परिनालिका • विद्युत चुंबक • क्षेत्र रेखाएँ',
    'tab_why': 'क्यों?',
    'tab_guide': 'गाइड',
    'tab_lab': 'अन्वेषण',
    'tab_quiz': 'परिणाम',
    'tag_realworld': 'वास्तविक दुनिया',
    'ctx_title': 'यह क्यों सीखें?',
    'ctx_intro':
        'सोलनॉइड लगभग हर उस मशीन का दिल है जो बिजली को गति में बदलती है!',
    'ex_crane': 'स्क्रैपयार्ड क्रेन',
    'ex_crane_sub': 'भारी वजन उठाना',
    'ex_crane_desc':
        'विशाल विद्युत चुंबक (लोहे के कोर वाले सोलनॉइड) टन भर स्क्रैप धातु कारों को आसानी से उठाने के लिए उपयोग किए जाते हैं।',
    'ex_bell': 'विद्युत घंटी',
    'ex_bell_sub': 'ध्वनि उत्पादन',
    'ex_bell_desc':
        'विद्युत घंटी के अंदर, एक सोलनॉइड स्ट्राइकर को गोंग के खिलाफ तेजी से खींचने के लिए विद्युत चुंबक के रूप में कार्य करता है।',
    'ex_speaker': 'लाउडस्पीकर',
    'ex_speaker_sub': 'ऑडियो',
    'ex_speaker_desc':
        'जब संगीत इसके माध्यम से बजता है तो एक सोलनॉइड कॉइल आगे-पीछे कंपन करता है, ध्वनि बनाने के लिए हवा को धक्का देता है।',
    'guide_title': 'कक्षा संदर्भ',
    'guide_context_1':
        'बेलन के आकार में पास-पास लिपटे तांबे के तार के अनेक वृत्ताकार फेरों की कुंडली को परिनालिका (Solenoid) कहते हैं।',
    'guide_context_2':
        'सोलनॉइड द्वारा उत्पादित चुंबकीय क्षेत्र बार चुंबक के समान होता है। एक सिरा उत्तरी ध्रुव और दूसरा दक्षिणी ध्रुव के रूप में कार्य करता है।',
    'g_s1_title': 'चरण 1: सोलनॉइड क्षेत्र',
    'g_s1_action': 'सर्किट को पावर ऑन करें।',
    'g_s1_focus':
        'कोइल के अंदर समानांतर क्षेत्र रेखाओं का निरीक्षण करें। यह एक समान चुंबकीय क्षेत्र को इंगित करता है।',
    'g_s2_title': 'चरण 2: ध्रुवता जांच',
    'g_s2_action': 'सिरों के पास कम्पास का उपयोग करें। फिर बैटरी उलटें।',
    'g_s2_focus':
        'जब धारा की दिशा उलट जाती है तो ध्रुव बदल जाते हैं। कम्पास सुई 180 डिग्री पलट जाती है।',
    'g_s3_title': 'चरण 3: विद्युत चुंबक बनाना',
    'g_s3_action': 'सॉफ्ट आयरन कोर डालें।',
    'g_s3_focus':
        'क्षेत्र रेखाओं को बहुत अधिक चमकीला/सघन होते हुए देखें। लोहे का कोर चुंबकीय प्रभाव को काफी बढ़ाता है।',
    'lbl_action': 'क्रिया:',
    'lbl_focus': 'ध्यान दें:',
    'lbl_mission': 'मिशन उद्देश्य',
    'mission_text':
        'सोलनॉइड के चुंबकीय क्षेत्र पैटर्न को सत्यापित करें और इसे एक शक्तिशाली विद्युत चुंबक में बदलें।',
    'lbl_procedure': 'प्रक्रिया',
    'proc_s1_title': '1. सोलनॉइड सक्रिय करें',
    'lbl_do': 'करें:',
    'proc_s1_do': 'पावर स्विच चालू करें।',
    'lbl_observe': 'निरीक्षण करें:',
    'proc_s1_obs':
        'क्षेत्र रेखाएं दिखाई देती हैं। अंदर समानांतर, बाहर घुमावदार।',
    'proc_s2_title': '2. विद्युत चुंबक बनाएं',
    'proc_s2_do': 'सॉफ्ट आयरन जोड़ने के लिए "कोर डालें" पर क्लिक करें।',
    'proc_s2_focus': 'चुंबकीय क्षेत्र की शक्ति काफी बढ़ जाती है।',
    'proc_s3_title': '3. ध्रुवता जांचें',
    'proc_s3_do': 'सिरों के पास कम्पास खींचें और बैटरी उलटें।',
    'proc_s3_obs': 'ध्रुव बदलने पर कम्पास दिशा पलट जाती है।',
    'proc_s4_title': '4. कबाड़खाना चुनौती',
    'proc_s4_do': 'कबाड़खाना क्रेन को क्रियाशील देखें।',
    'proc_s4_target': 'लोहे को हरे डिब्बे में डालें।',
    'lbl_target': 'लक्ष्य:',
    'info_control':
        'उपकरण के साथ बातचीत करने के लिए 3D दृश्य के ऊपर-दाईं ओर कंट्रोल डेक का उपयोग करें।',
    'deck_title': 'लैब नियंत्रण',
    'switch': 'बिजली आपूर्ति',
    'current': 'धारा',
    'btn_core': 'आयरन कोर डालें',
    'btn_core_remove': 'आयरन कोर हटाएं',
    'reverse': 'बैटरी उलटें',
    'current_task': 'वर्तमान मिशन',
    'out_title': 'सीखने के परिणाम',
    'out_subtitle': 'कक्षा 10 विज्ञान पाठ्यपुस्तक पर आधारित',
    'out_1_title': 'बार चुंबक व्यवहार',
    'out_1_desc':
        'धारा प्रवाहित सोलनॉइड बार चुंबक की तरह व्यवहार करता है, जिसके सिरों पर निश्चित उत्तर और दक्षिण ध्रुव होते हैं।',
    'out_2_title': 'समान क्षेत्र',
    'out_2_desc':
        'सोलनॉइड के अंदर क्षेत्र रेखाएं समानांतर सीधी रेखाओं के रूप में होती हैं। यह इंगित करता है कि सोलनॉइड के अंदर सभी बिंदुओं पर चुंबकीय क्षेत्र समान है।',
    'out_3_title': 'विद्युत चुंबक',
    'out_3_desc':
        'सोलनॉइड के अंदर उत्पन्न एक मजबूत चुंबकीय क्षेत्र का उपयोग चुंबकीय सामग्री, जैसे सॉफ्ट आयरन, को चुंबकित करने के लिए किया जा सकता है। इस प्रकार बने चुंबक को विद्युत चुंबक कहते हैं।',
    'finish': 'गतिविधि समाप्त करें',
    'success_title': 'मिशन सफल!',
    'success_msg': 'आपने विद्युत चुंबक में महारत हासिल कर ली है।',
    's0_do': 'पावर स्विच चालू करें।',
    's0_obs': 'अंदर समानांतर क्षेत्र रेखाएं देखें।',
    's1_do': "'आयरन कोर डालें' पर क्लिक करें।",
    's1_obs': 'क्षेत्र मजबूत हो जाता है।',
    's2_do': 'कम्पास को सिरों के पास खींचें।',
    's2_obs': 'ध्रुव बदलने पर कम्पास पलट जाता है।',
    's3_do': 'क्रेन नियंत्रण का उपयोग करें।',
    's3_obs': 'लोहा चिपक जाता है, प्लास्टिक नहीं।',
    'step_finish': 'अवलोकन',
    'btn_continue': 'अगला',
    'msg_s0':
        'जब सोलनॉइड कॉइल से विद्युत धारा प्रवाहित होती है, तो एक चुंबकीय क्षेत्र बनता है। अंदर समानांतर क्षेत्र रेखाएं एक समान चुंबकीय क्षेत्र को दर्शाती हैं।',
    'msg_s1':
        'सॉफ्ट आयरन कोर डालने से चुंबकीय क्षेत्र रेखाएं काफी केंद्रित हो जाती हैं। यह लोहे की वस्तुओं को मजबूती से आकर्षित करने में सक्षम एक शक्तिशाली विद्युत चुंबक बनाता है।',
    'msg_s2':
        'धारा की दिशा को उलट देने से चुंबकीय ध्रुव उलट जाते हैं (उत्तर, दक्षिण बन जाता है)। कम्पास सुई के 180 डिग्री पलटने से इसकी पुष्टि होती है।',
    'label_clips': 'पेपर क्लिप',
    'auto_pilot_move': 'ऑटो-पायलट: कबाड़ के ढेर की ओर बढ़ रहा है...',
    'lifting_scrap': 'लोहे का कबाड़ उठाना...',
    'transporting': 'रीसाइक्लिंग बिन में ले जाना...',
    'deactivating': 'चुंबक को निष्क्रिय करना (छोड़ना)...',
    'label_solenoid': 'परिनालिका कुंडली',
    'label_core': 'लौह क्रोड',
    'label_compass': 'दिक्सूचक (कम्पास)',
    'btn_power_on': 'पावर चालू करें',
    'btn_demo': 'क्रेन डेमो फिर चलाएँ',
    'btn_move_compass': 'कम्पास घुमाएँ',
    'state_on': 'चालू',
    'state_off': 'बंद',
    'lbl_labels': 'लेबल दिखाएँ / छिपाएँ',
    'lockView': 'दृश्य लॉक / अनलॉक करें',
  },
});

// Source material colours.
const _copper = Color(0xFFB45309);
const _redPole = Color(0xFFEF4444);
const _bluePole = Color(0xFF3B82F6);

class Cl10SCh12A2SolenoidElectromagnetPlantPage extends StatefulWidget {
  const Cl10SCh12A2SolenoidElectromagnetPlantPage({super.key});

  @override
  State<Cl10SCh12A2SolenoidElectromagnetPlantPage> createState() =>
      _Cl10SCh12A2SolenoidElectromagnetPlantPageState();
}

class _Cl10SCh12A2SolenoidElectromagnetPlantPageState
    extends State<Cl10SCh12A2SolenoidElectromagnetPlantPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(12, 8, 12),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final math.Random _rng = math.Random(7);

  late final _rt_Node3D _magnetGroup;
  late final _rt_Mesh3D _core;
  late final _rt_Node3D _compass;
  late final _rt_Node3D _needle;
  late final _rt_Label3D _poleLeft;
  late final _rt_Label3D _poleRight;
  late final _rt_Label3D _lblSolenoid;
  late final _rt_Label3D _lblCore;
  late final _rt_Label3D _lblCompass;
  late final _rt_Label3D _lblClips;
  final _rt_Material3D _wireMat = _rt_Material3D(
    color: _copper,
    shininess: 0.5,
    metalness: 0.6,
  );
  final List<_rt_Line3D> _outerLoops = [];
  final List<_rt_Line3D> _innerLines = [];
  final List<_rt_Mesh3D> _clips = [];
  final List<_rt_Mesh3D> _trash = [];
  _rt_Node3D? _bin;

  // --- LAB STATE (threeApp.state + lab.currentStep in the HTML) ---
  int _step = 0;
  final Set<int> _done = {};
  bool _isOn = false;
  bool _hasCore = false;
  int _polarity = 1;
  double _current = 3;
  bool _showLabels = true;
  bool _viewLocked = false;
  bool _draggingCompass = false;
  bool _craneRunning = false;
  String? _craneMsgKey;
  bool _clipTimerArmed = false;
  bool _clipsAttachedSound = false;
  bool _trashAttachedSound = false;
  double _clock = 0;
  double _fieldTarget = 0;
  double _fieldShown = 0;
  Color _wireTarget = _copper;

  /// Bumped on restart so pending timers / crane sequences abort.
  int _gen = 0;

  bool _alive(int gen) => mounted && gen == _gen;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScene();
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
      _rt_Light3D.ambient(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(5, 10, 5), intensity: 0.8),
    ]);

    // Table (white mat) + grid, as in addObjects().
    _scene.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(14, 0.2, 14),
        _rt_Material3D(color: const Color(0xFFE2E8F0), shininess: 0.1),
      )..position.y = -2,
    );
    final grid = <_rt_V3>[];
    for (var i = -7; i <= 7; i++) {
      grid.addAll([_rt_V3(i.toDouble(), 0, -7), _rt_V3(i.toDouble(), 0, 7)]);
      grid.addAll([_rt_V3(-7, 0, i.toDouble()), _rt_V3(7, 0, i.toDouble())]);
    }
    _scene.add(
      _rt_Line3D(
          grid,
          color: const Color(0xFFCBD5E1),
          width: 1,
          opacity: 0.6,
          segments: true,
        )
        ..position.y = -1.88
        ..pickable = false,
    );

    _magnetGroup = _rt_Node3D(name: 'magnetGroup');
    _scene.add(_magnetGroup);

    // Solenoid coil: the source's 12-turn helix TubeGeometry(150x8) is far too
    // dense for the software renderer -- 10 shared low-poly torus turns give
    // the same silhouette at a fraction of the polygons.
    final turnGeo = _rt_Geometry3D.torus(
      1.5,
      0.11,
      radialSegments: 5,
      tubularSegments: 12,
    );
    const turns = 10;
    for (var i = 0; i < turns; i++) {
      final x = -3.6 + i * 7.2 / (turns - 1);
      _magnetGroup.add(
        _rt_Mesh3D(turnGeo, _wireMat, name: 'coil')
          ..rotation.y = math.pi / 2
          ..position.x = x,
      );
    }

    // Solenoid pole sprites (S/N canvas textures in the source).
    _poleLeft = _rt_Label3D(
      'S',
      position: _rt_V3(-4.6, 0, 0),
      worldHeight: 1.1,
      color: Colors.white,
      background: _bluePole,
    )..visible = false;
    _poleRight = _rt_Label3D(
      'N',
      position: _rt_V3(4.6, 0, 0),
      worldHeight: 1.1,
      color: Colors.white,
      background: _redPole,
    )..visible = false;
    _magnetGroup.add(_poleLeft);
    _magnetGroup.add(_poleRight);

    // Soft iron core, parked off-stage at x = -10 like the source.
    _core =
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(1.25, 1.25, 9, segments: 14),
            _rt_Material3D(
              color: const Color(0xFF64748B),
              metalness: 0.7,
              shininess: 0.4,
            ),
            name: 'core',
          )
          ..rotation.z = math.pi / 2
          ..position.x = -10;
    _magnetGroup.add(_core);

    _buildFieldLines();

    // Scene labels (the HTML #labels-container overlays).
    _lblSolenoid = _rt_Label3D(
      '',
      position: _rt_V3(0, 2.7, 0),
      pixelHeight: 11,
      background: const Color(0xCC0F172A),
    );
    _lblCore = _rt_Label3D(
      '',
      position: _rt_V3(-10, -2.7, 0),
      pixelHeight: 11,
      background: const Color(0xCC0F172A),
    );
    _magnetGroup.add(_lblSolenoid);
    _magnetGroup.add(_lblCore);

    _buildCompass();

    _lblClips = _rt_Label3D(
      '',
      position: _rt_V3(0, 0, 0),
      pixelHeight: 11,
      background: const Color(0xCC0F172A),
    )..visible = false;
    _scene.add(_lblClips);

    _updateField();
  }

  /// createFieldLines(): 8 outer loops rotated about the coil axis + 8 inner
  /// parallel lines, drawn as dashed polylines instead of textured tubes.
  void _buildFieldLines() {
    for (var r = 0; r < 8; r++) {
      final angle = r / 8 * math.pi;
      final scaleY = 2.5 + (r % 2);
      final pts = <_rt_V3>[];
      for (var i = 0; i < 36; i++) {
        final t = i / 36 * math.pi * 2;
        final x = 5 * math.cos(t) * (1 + 0.5 * math.cos(t).abs());
        final y = scaleY * math.sin(t);
        pts.add(_rt_V3(x, y * math.cos(angle), y * math.sin(angle)));
      }
      final loop = _rt_Line3D(
        pts,
        color: _bluePole,
        width: 2,
        opacity: 0,
        dashed: true,
        closed: true,
      )..pickable = false;
      _outerLoops.add(loop);
      _magnetGroup.add(loop);
    }
    for (var i = -1; i <= 1; i++) {
      for (var j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        final line = _rt_Line3D(
          [_rt_V3(-6, i * 0.5, j * 0.5), _rt_V3(6, i * 0.5, j * 0.5)],
          color: const Color(0xFFFF0000),
          width: 2,
          opacity: 0,
          dashed: true,
        )..pickable = false;
        _innerLines.add(line);
        _magnetGroup.add(line);
      }
    }
  }

  /// createCompass(): base + white face + red/blue needle, draggable in-scene.
  void _buildCompass() {
    _compass = _rt_Node3D(name: 'compass')..position.set(0, -1.8, 3.5);
    _compass.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.6, 0.6, 0.12, segments: 16),
        _rt_Material3D(color: const Color(0xFF334155), shininess: 0.4),
      ),
    );
    _compass.add(
      _rt_Mesh3D(
          _rt_Geometry3D.circle(0.5, segments: 16),
          _rt_Material3D(color: Colors.white, unlit: true),
        )
        ..rotation.x = -math.pi / 2
        ..position.y = 0.08,
    );
    _needle = _rt_Node3D(name: 'needle')..position.y = 0.16;
    _needle.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cone(0.1, 0.45, segments: 8),
          _rt_Material3D(color: _redPole, unlit: true),
        )
        ..rotation.x = -math.pi / 2
        ..position.z = -0.22,
    );
    _needle.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cone(0.1, 0.45, segments: 8),
          _rt_Material3D(color: _bluePole, unlit: true),
        )
        ..rotation.x = math.pi / 2
        ..position.z = 0.22,
    );
    _compass.add(_needle);
    _lblCompass = _rt_Label3D(
      '',
      position: _rt_V3(0, 1.0, 0),
      pixelHeight: 11,
      background: const Color(0xCC0F172A),
    );
    _compass.add(_lblCompass);
    _scene.add(_compass);
  }

  // ------------------------------------------------ clips & scrapyard ---
  /// spawnClips(): 60 tube-geometry clips in the source; 18 small red boxes
  /// here to keep the polygon count modest.
  void _spawnClips() {
    _clearClips();
    final geo = _rt_Geometry3D.box(0.42, 0.05, 0.16);
    for (var i = 0; i < 18; i++) {
      final clip =
          _rt_Mesh3D(
              geo,
              _rt_Material3D(
                color: const Color(0xFFEF4444),
                metalness: 0.6,
                shininess: 0.4,
              ),
              name: 'clip',
            )
            ..position.set(
              (_rng.nextDouble() - 0.5) * 12,
              -1.8,
              (_rng.nextDouble() - 0.5) * 10,
            )
            ..rotation.y = _rng.nextDouble() * math.pi;
      final angle = _rng.nextDouble() * math.pi * 2;
      const r = 1.8;
      clip.userData = {
        'attached': false,
        'offset': _rt_V3(
          (_rng.nextDouble() - 0.5) * 7,
          r * math.sin(angle),
          r * math.cos(angle),
        ),
      };
      clip.pickable = false;
      _scene.add(clip);
      _clips.add(clip);
    }
    _clipsAttachedSound = false;
    _clipTimerArmed = false;
  }

  void _clearClips() {
    for (final c in _clips) {
      _scene.remove(c);
    }
    _clips.clear();
    _clipTimerArmed = false;
    _lblClips.visible = false;
  }

  /// setupScrapyard(): magnet becomes a crane at y=5, core forced in, power
  /// off, compass hidden, scrap pile + green bin spawned.
  void _setupScrapyard() {
    // Pull the camera back and up so the elevated crane, the pile and the
    // bin all fit under the HUD overlays.
    _camera.position.set(15, 9, 15);
    _camera.target.set(0, 1.2, 0);
    _magnetGroup.position.set(0, 5, 0);
    _hasCore = true;
    _core.position.set(0, 0, 0);
    if (_isOn) _toggleSwitch();
    _updateField();
    _compass.visible = false;
    _spawnTrash();
  }

  void _spawnTrash() {
    _clearTrash();
    final nailGeo = _rt_Geometry3D.cylinder(0.04, 0.04, 0.6, segments: 5);
    final nailMat = _rt_Material3D(
      color: const Color(0xFF333333),
      metalness: 0.8,
      shininess: 0.4,
    );
    final plasticGeo = _rt_Geometry3D.box(0.5, 0.04, 0.5);
    final plasticMat = _rt_Material3D(color: _bluePole, shininess: 0.1);
    for (var i = 0; i < 20; i++) {
      final isIron = i.isEven;
      final mesh =
          _rt_Mesh3D(
              isIron ? nailGeo : plasticGeo,
              isIron ? nailMat : plasticMat,
              name: isIron ? 'iron' : 'plastic',
            )
            ..position.set(
              -6 + (_rng.nextDouble() - 0.5) * 3,
              -1.8,
              (_rng.nextDouble() - 0.5) * 3,
            )
            ..rotation.set(
              _rng.nextDouble() * math.pi,
              _rng.nextDouble() * math.pi,
              _rng.nextDouble() * math.pi,
            );
      mesh.userData = {
        'isIron': isIron,
        'offset': _rt_V3(
          (_rng.nextDouble() - 0.5) * 6,
          -1.5 - _rng.nextDouble(),
          (_rng.nextDouble() - 0.5) * 1.5,
        ),
      };
      mesh.pickable = false;
      _scene.add(mesh);
      _trash.add(mesh);
    }
    // Green recycling bin (open tray) at x = +6.
    final bin = _rt_Node3D(name: 'bin')..position.set(6, -1.9, 0);
    bin.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(4, 0.2, 4),
        _rt_Material3D(color: const Color(0xFF808080)),
      ),
    );
    final wallMat = _rt_Material3D(color: const Color(0xFF22C55E));
    bin.add(
      _rt_Mesh3D(_rt_Geometry3D.box(4, 1, 0.2), wallMat)
        ..position.set(0, 0.5, -1.9),
    );
    bin.add(
      _rt_Mesh3D(_rt_Geometry3D.box(4, 1, 0.2), wallMat)
        ..position.set(0, 0.5, 1.9),
    );
    bin.add(
      _rt_Mesh3D(_rt_Geometry3D.box(0.2, 1, 4), wallMat)
        ..position.set(-1.9, 0.5, 0),
    );
    bin.add(
      _rt_Mesh3D(_rt_Geometry3D.box(0.2, 1, 4), wallMat)
        ..position.set(1.9, 0.5, 0),
    );
    _scene.add(bin);
    _bin = bin;
    _trashAttachedSound = false;
  }

  void _clearTrash() {
    for (final t in _trash) {
      _scene.remove(t);
    }
    _trash.clear();
    if (_bin != null) {
      _scene.remove(_bin!);
      _bin = null;
    }
  }

  /// autoRunScrapyard(): the GSAP crane timeline.
  Future<void> _runCrane() async {
    if (_craneRunning) return;
    final g = _gen;
    setState(() => _craneRunning = true);
    final grp = _magnetGroup.position;
    grp.set(0, 5, 0);
    try {
      _setCraneMsg('auto_pilot_move');
      await _tweens.run(1500, (t) => grp.x = -6 * t, ease: _rt_Ease.inOutQuad);
      if (!_alive(g)) return;
      await _tweens.run(1000, (t) => grp.y = 5 - 3 * t, ease: _rt_Ease.outQuad);
      if (!_alive(g)) return;
      if (!_isOn) _toggleSwitch(); // magnet ON over the pile
      await _tweens.wait(1500); // wait for the scrap to attach
      if (!_alive(g)) return;
      _setCraneMsg('lifting_scrap');
      await _tweens.run(1000, (t) => grp.y = 2 + 3 * t, ease: _rt_Ease.inQuad);
      if (!_alive(g)) return;
      _setCraneMsg('transporting');
      await _tweens.run(
        2000,
        (t) => grp.x = -6 + 12 * t,
        ease: _rt_Ease.inOutQuad,
      );
      if (!_alive(g)) return;
      _setCraneMsg('deactivating');
      if (_isOn) _toggleSwitch(); // drop the load
      _rt_playSfx(_rt_Sfx.pop);
      await _tweens.wait(1000);
      if (!_alive(g)) return;
      _setCraneMsg(null);
      final first = !_done.contains(3);
      _done.add(3);
      setState(() {});
      if (first) {
        _shell.showSuccess(
          title: _tx.s('success_title'),
          message: _tx.s('success_msg'),
        );
      }
    } finally {
      if (_alive(g)) setState(() => _craneRunning = false);
    }
  }

  void _setCraneMsg(String? key) {
    if (!mounted) return;
    setState(() => _craneMsgKey = key);
  }

  // ----------------------------------------------------------- controls ---
  /// lab.toggleSwitch() -- audio.playSwitch() -> _rt_Sfx.toggle.
  void _toggleSwitch() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _isOn = !_isOn);
    if (_isOn) _rt_playSfx(_rt_Sfx.magic); // the field springs to life
    _updateField();
    if (_isOn && _step == 0 && !_done.contains(0)) {
      final g = _gen;
      // The source completes step 1 two seconds after power-on.
      Future.delayed(const Duration(seconds: 2), () {
        if (_alive(g) && _isOn && _step == 0) _completeStep(0);
      });
    }
  }

  /// lab.toggleCore() + threeApp.animateCore().
  void _toggleCore() {
    if (!_isOn) return;
    final inserting = !_hasCore;
    setState(() => _hasCore = inserting);
    _updateField();
    final g = _gen;
    final from = _core.position.x;
    final to = inserting ? 0.0 : -10.0;
    _tweens
        .run(
          1500,
          (t) => _core.position.x = from + (to - from) * t,
          ease: _rt_Ease.inOutCubic,
        )
        .then((_) {
          if (_alive(g)) {
            _rt_playSfx(
              inserting ? _rt_Sfx.pop : _rt_Sfx.tap,
            ); // core seats/leaves
          }
        });
  }

  /// lab.reverseBattery(): poles swap, wire flashes white.
  void _reverseBattery() {
    if (!_isOn) return;
    _rt_playSfx(_rt_Sfx.magic); // the zap of the swap
    setState(() => _polarity = -_polarity);
    _wireMat.color = Colors.white; // flash; eased back in _onFrame
    _updateField();
    if (_step == 2 && _isOn) _completeStep(2);
  }

  void _setCurrent(double v) {
    setState(() => _current = v);
    _updateField();
  }

  /// Sidebar fallback for the compass drag: cycles it around the poles.
  void _moveCompass() {
    _rt_playSfx(_rt_Sfx.pop);
    final p = _compass.position;
    if (p.x < 2 && p.z > 2.5) {
      p.set(4.8, -1.8, 2.1); // near the N end
    } else if (p.x > 2) {
      p.set(-4.8, -1.8, 2.1); // near the S end
    } else {
      p.set(0, -1.8, 3.5); // back to the front
    }
    setState(() {});
  }

  /// threeApp.updateFieldIntensity().
  void _updateField() {
    double intensity = 0;
    if (_isOn) {
      intensity = _current / 5 * 0.3;
      if (_hasCore) intensity *= 3;
    }
    _fieldTarget = math.min(0.9, intensity);
    final innerColor = _hasCore
        ? const Color(0xFFFF4D4D)
        : const Color(0xFFFF0000);
    final outerColor = _hasCore ? const Color(0xFF06B6D4) : _bluePole;
    for (final l in _innerLines) {
      l.color = innerColor;
    }
    for (final l in _outerLoops) {
      l.color = outerColor;
    }
    _wireTarget = _isOn
        ? (_hasCore ? const Color(0xFFFCD34D) : const Color(0xFFF97316))
        : _copper;
    _wireMat.emissive = _isOn ? const Color(0xFFFF4500) : null;
    _wireMat.emissiveIntensity = 0.2;
    final normal = _polarity > 0;
    _poleLeft
      ..text = normal ? 'S' : 'N'
      ..background = normal ? _bluePole : _redPole;
    _poleRight
      ..text = normal ? 'N' : 'S'
      ..background = normal ? _redPole : _bluePole;
    _poleLeft.visible = _isOn;
    _poleRight.visible = _isOn;
  }

  // -------------------------------------------------------------- steps ---
  void _completeStep(int idx) {
    if (_done.contains(idx)) return;
    setState(() => _done.add(idx));
    if (idx < 3) _showObservation(idx);
  }

  /// ui.showStepConclusion(): observation popup, then Next -> next scenario.
  Future<void> _showObservation(int idx) async {
    _rt_playSfx(_rt_Sfx.correct); // audio.playSuccess() on the step conclusion
    final g = _gen;
    await _rt_showShellPopup(
      context,
      title: _tx.s('step_finish'),
      message: _tx.s('msg_s$idx'),
      icon: Icons.lightbulb,
      color: _rt_Tw.indigo500,
      buttonLabel: _tx.s('btn_continue'),
    );
    if (_alive(g) && _step == idx) _setScenario(idx + 1);
  }

  /// lab.setScenario(idx).
  void _setScenario(int idx, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    final leavingScrap = _step == 3 && idx != 3;
    setState(() {
      _step = idx;
      _craneMsgKey = null;
    });
    if (leavingScrap) {
      _magnetGroup.position.set(0, 0, 0);
      _clearTrash();
      _compass.visible = true;
      _camera.reset();
    }
    switch (idx) {
      case 0:
        if (_isOn) _toggleSwitch();
        if (_hasCore) _toggleCore();
        _magnetGroup.position.set(0, 0, 0);
        _compass.position.set(0, -1.8, 3.5);
        _compass.visible = true;
        _clearClips();
        _clearTrash();
      case 1:
        _spawnClips();
      case 2:
        _clearClips();
      case 3:
        _setupScrapyard();
        _runCrane();
    }
  }

  /// The Outcomes tab's Finish Activity button (app.showSuccess()).
  void _finishActivity() {
    _shell.showSuccess(
      title: _tx.s('success_title'),
      message: _tx.s('success_msg'),
    );
  }

  void _restart() {
    _gen++;
    _tweens.cancelAll();
    _isOn = false;
    _hasCore = false;
    _polarity = 1;
    _current = 3;
    _core.position.set(-10, 0, 0);
    _magnetGroup.position.set(0, 0, 0);
    _compass.position.set(0, -1.8, 3.5);
    _compass.visible = true;
    _needle.rotation.y = 0;
    _clearClips();
    _clearTrash();
    _wireMat.color = _copper;
    setState(() {
      _step = 0;
      _done.clear();
      _craneMsgKey = null;
      _craneRunning = false;
      _showLabels = true;
      _viewLocked = false;
      _draggingCompass = false;
    });
    _updateField();
    _fieldShown = 0;
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _camera.reset();
  }

  // ------------------------------------------------------------ physics ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);

    // Field lines fade in/out (gsap opacity 0.5s) with a soft shimmer that
    // stands in for the scrolling dash texture.
    _fieldShown += (_fieldTarget - _fieldShown) * math.min(1, dt * 4);
    var k = 0;
    for (final l in _outerLoops) {
      l.opacity =
          (_fieldShown * (0.8 + 0.2 * math.sin(_clock * 3 * _polarity + k)))
              .clamp(0.0, 1.0);
      k++;
    }
    for (final l in _innerLines) {
      l.opacity =
          (_fieldShown * (0.8 + 0.2 * math.sin(_clock * 4 * _polarity + k)))
              .clamp(0.0, 1.0);
      k++;
    }

    // Wire glow easing (also recovers from the reverse-battery flash).
    _wireMat.color = Color.lerp(
      _wireMat.color,
      _wireTarget,
      math.min(1, dt * 5),
    )!;

    _compassLogic(dt);
    if (_step == 1) _clipsPhysics(dt);
    if (_step == 3) _trashPhysics(dt);

    // Labels follow their objects / language.
    _lblCore.position.set(_core.position.x, -2.7, 0);
    _lblSolenoid.visible = _showLabels;
    _lblCore.visible = _showLabels && (_hasCore || _core.position.x > -9);
    _lblCompass.visible = _showLabels && _compass.visible;
    if (_clips.isNotEmpty && _showLabels) {
      final mid = _clips[_clips.length ~/ 2];
      _lblClips.visible = true;
      _lblClips.position.set(
        mid.position.x,
        mid.position.y + 1.0,
        mid.position.z,
      );
    } else {
      _lblClips.visible = false;
    }
  }

  /// threeApp.updateCompassLogic(): simple dipole approximation in the XZ
  /// plane; inside the coil footprint the field is uniform along +X.
  void _compassLogic(double dt) {
    double targetAngle = 0;
    if (_isOn) {
      final magPos = _magnetGroup.worldPosition;
      final rel = _compass.position - magPos;
      final p1 = _rt_V3(-4, 0, 0);
      final p2 = _rt_V3(4, 0, 0);
      final d2 = math.max(0.1, math.pow(rel.distanceTo(p2), 2).toDouble());
      final d1 = math.max(0.1, math.pow(rel.distanceTo(p1), 2).toDouble());
      final push = (rel - p2).normalized() / d2;
      final pull = (p1 - rel).normalized() / d1;
      var field = (push + pull).normalized();
      if (rel.z.abs() < 1.5 && rel.x.abs() < 4) field = _rt_V3(1, 0, 0);
      if (_polarity < 0) field = field * -1;
      targetAngle = -math.atan2(field.z, field.x) - math.pi / 2;
    }
    var diff = targetAngle - _needle.rotation.y;
    while (diff > math.pi) {
      diff -= math.pi * 2;
    }
    while (diff < -math.pi) {
      diff += math.pi * 2;
    }
    _needle.rotation.y += diff * math.min(1, dt * 6);
  }

  /// threeApp.updateClipsPhysics().
  void _clipsPhysics(double dt) {
    if (_clips.isEmpty) return;
    final active = _isOn && _hasCore;
    final magnetPos = _magnetGroup.worldPosition;
    var attachedCount = 0;
    final lerp = 1 - math.pow(0.8, dt * 60).toDouble();
    for (final clip in _clips) {
      if (active && clip.position.distanceTo(magnetPos) < 8) {
        clip.userData['attached'] = true;
        final target = magnetPos + (clip.userData['offset'] as _rt_V3);
        if (clip.position.distanceTo(target) > 0.1) {
          clip.position.lerpTo(target, lerp);
          clip.rotation.x += 6 * dt;
          clip.rotation.z += 6 * dt;
        } else {
          clip.position.copy(target);
        }
      } else {
        clip.userData['attached'] = false;
        if (clip.position.y > -1.8) {
          clip.position.y = math.max(-1.8, clip.position.y - 12 * dt);
          clip.rotation.x += 6 * dt;
        }
      }
      if (clip.userData['attached'] == true && clip.position.y > -1.5) {
        attachedCount++;
      }
    }
    // Clatter of the clips jumping onto the electromagnet / dropping off.
    if (attachedCount > 0 && !_clipsAttachedSound) {
      _clipsAttachedSound = true;
      _rt_playSfx(_rt_Sfx.pop);
    } else if (attachedCount == 0 && _clipsAttachedSound) {
      _clipsAttachedSound = false;
      _rt_playSfx(_rt_Sfx.pop);
    }
    // Auto-progression: 1.5 s after enough clips are hanging on the coil.
    if (_step == 1 &&
        attachedCount > 6 &&
        !_clipTimerArmed &&
        !_done.contains(1)) {
      _clipTimerArmed = true;
      final g = _gen;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_alive(g) && _step == 1) _completeStep(1);
      });
    }
  }

  /// threeApp.updateTrashPhysics(): only iron responds to the crane magnet.
  void _trashPhysics(double dt) {
    if (_trash.isEmpty) return;
    final active = _isOn;
    final magnetPos = _magnetGroup.position;
    final lerp = 1 - math.pow(0.8, dt * 60).toDouble();
    var attached = 0;
    for (final item in _trash) {
      final isIron = item.userData['isIron'] == true;
      if (active && isIron && item.position.distanceTo(magnetPos) < 8) {
        attached++;
        final target = magnetPos + (item.userData['offset'] as _rt_V3);
        item.position.lerpTo(target, lerp);
        item.rotation.x += 3 * dt;
      } else {
        if (item.position.y > -1.8) {
          item.position.y = math.max(-1.8, item.position.y - 18 * dt);
          item.rotation.z += 6 * dt;
        }
      }
    }
    if (attached > 0 && !_trashAttachedSound) {
      _trashAttachedSound = true;
      _rt_playSfx(_rt_Sfx.pop); // scrap clangs onto the magnet
    } else if (attached == 0) {
      _trashAttachedSound = false;
    }
  }

  // ----------------------------------------------------- compass drag ---
  bool _onPointerDown(_rt_SceneEvent e) {
    if (_step == 3 || !_compass.visible) return false;
    if (e.hitWhere((n) => n == _compass) == null) return false;
    _draggingCompass = true;
    _rt_playSfx(_rt_Sfx.tap);
    return true;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    if (!_draggingCompass) return;
    final p = e.ray.intersectY(-1.8);
    if (p == null) return;
    final x = p.x.clamp(-6.0, 6.0);
    var z = p.z.clamp(-4.0, 4.0);
    if (z.abs() < 2) z = z >= 0 ? 2.1 : -2.1; // keep clear of the coil
    _compass.position.set(x, -1.8, z);
  }

  void _onPointerUp(_rt_SceneEvent e) {
    _draggingCompass = false;
  }

  // ----------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          // Keep the in-scene labels in the current language.
          _lblSolenoid.text = _tx.s('label_solenoid');
          _lblCore.text = _tx.s('label_core');
          _lblCompass.text = _tx.s('label_compass');
          _lblClips.text = _tx.s('label_clips');
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.indigo600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.indigo900],
              headerSubtitleColor: _rt_Tw.indigo100,
            ),
            canvasBackground: _rt_Tw.slate950,
            intro: _rt_IntroConfig(
              title: _tx.s('intro_title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('intro_button'),
              footnote: _tx.s('intro_foot'),
              icon: Icons.bolt,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              _rt_RotatePanToggle(
                controller: _viewCtrl,
                accent: _rt_Tw.indigo600,
              ),
              const SizedBox(height: 4),
              _toolButton(
                key: 'toggle-labels',
                tooltip: _tx.s('lbl_labels'),
                icon: _showLabels ? Icons.visibility : Icons.visibility_off,
                active: _showLabels,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _showLabels = !_showLabels);
                },
              ),
              const SizedBox(height: 4),
              _toolButton(
                key: 'lock-view',
                tooltip: _tx.s('lockView'),
                icon: _viewLocked ? Icons.lock : Icons.lock_open,
                active: _viewLocked,
                activeColor: _rt_Tw.red500,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _viewLocked = !_viewLocked);
                },
              ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tab_lab'),
                icon: Icons.science,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              onFrame: _onFrame,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              cameraControls: !_viewLocked,
            ),
            canvasOverlays: [
              // The HTML #mini-hud (Current Mission); it yields to the crane
              // auto-pilot narration so the demo stays unobscured.
              if (_craneMsgKey == null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: IgnorePointer(child: _missionHud()),
                ),
              // The HTML #control-deck, kept clear of the shell toolbar.
              Positioned(top: 10, right: 60, child: _controlDeck()),
              // The HTML #demo-overlay-msg during the crane auto-pilot.
              if (_craneMsgKey != null)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _rt_Tw.amber500.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Text(
                          _tx.s(_craneMsgKey!),
                          key: const ValueKey('crane-msg'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
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

  Widget _toolButton({
    required String key,
    required String tooltip,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    Color activeColor = _rt_Tw.indigo600,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        key: ValueKey(key),
        radius: 22,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? activeColor : _rt_Lab.surface,
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

  /// The HTML #mini-hud: current mission with Action / Focus lines.
  Widget _missionHud() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 235),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: _rt_Tw.indigo500, width: 4),
        ),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('current_task').toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: _rt_Tw.indigo500,
            ),
          ),
          const SizedBox(height: 3),
          _hudLine(
            _tx.s('lbl_action'),
            _tx.s('s${_step}_do'),
            _rt_Tw.indigo500,
            key: const ValueKey('hud-do'),
          ),
          const SizedBox(height: 2),
          _hudLine(_tx.s('lbl_focus'), _tx.s('s${_step}_obs'), _rt_Tw.amber500),
        ],
      ),
    );
  }

  Widget _hudLine(String label, String text, Color color, {Key? key}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            height: 1.25,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            key: key,
            style: TextStyle(fontSize: 11.5, height: 1.25, color: _rt_Lab.text),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------- control deck ---
  /// The HTML #control-deck: power switch, core, reverse battery, current.
  Widget _controlDeck() {
    final scrapyard = _step == 3;
    return Container(
      width: 178,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('deck_title').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isOn ? _rt_Tw.green500 : _rt_Tw.slate500,
                  shape: BoxShape.circle,
                  boxShadow: _isOn
                      ? [const BoxShadow(color: _rt_Tw.green500, blurRadius: 6)]
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('switch'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ),
              Text(
                _isOn ? _tx.s('state_on') : _tx.s('state_off'),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: _isOn ? _rt_Tw.green500 : _rt_Lab.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // The sliding power switch.
          GestureDetector(
            key: const ValueKey('deck-power'),
            onTap: _toggleSwitch,
            child: Container(
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: _isOn ? _rt_Tw.green500 : _rt_Lab.borderStrong,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _isOn
                              ? _rt_Tw.green500
                              : const Color(0xFF7F1D1D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: _isOn
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 42,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _isOn ? _rt_Tw.green500 : _rt_Tw.slate400,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Icon(
                        Icons.power_settings_new,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!scrapyard) ...[
            const SizedBox(height: 8),
            _deckButton(
              key: 'deck-core',
              label: _hasCore ? _tx.s('btn_core_remove') : _tx.s('btn_core'),
              icon: Icons.crop_16_9,
              enabled: _isOn,
              onTap: _toggleCore,
            ),
            const SizedBox(height: 6),
            _deckButton(
              key: 'deck-reverse',
              label: _tx.s('reverse'),
              icon: Icons.swap_horiz,
              enabled: _isOn,
              onTap: _reverseBattery,
            ),
          ],
          const SizedBox(height: 2),
          Opacity(
            opacity: _isOn ? 1 : 0.5,
            child: _rt_LabeledSlider(
              label: _tx.s('current'),
              value: _current,
              min: 1,
              max: 5,
              divisions: 4,
              valueText: '${_current.toStringAsFixed(1)} A',
              color: _rt_Tw.amber500,
              onChanged: _isOn ? _setCurrent : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deckButton({
    required String key,
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: ValueKey(key),
          borderRadius: BorderRadius.circular(8),
          onTap: enabled
              ? () {
                  _rt_playSfx(
                    _rt_Sfx.click,
                  ); // audio.playClick() on the deck buttons
                  onTap();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Lab.borderStrong),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: _rt_Lab.text),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: _rt_Lab.text,
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

  // ------------------------------------------------------------ sidebar ---
  Widget _exploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('lbl_mission'),
          desc: _tx.s('mission_text'),
          accent: _rt_Tw.indigo600,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('lbl_procedure'), icon: Icons.checklist),
              for (var i = 0; i < 4; i++) _stepCard(i),
              _rt_InfoCard(
                body: _tx.s('info_control'),
                icon: Icons.videogame_asset,
                color: _rt_Tw.blue600,
                leftBorder: true,
              ),
              const SizedBox(height: 6),
              // Guide tab content (the shell shows only one tab, so the
              // Why / Guide / Outcomes tabs stack below the procedure).
              _rt_SectionLabel(_tx.s('tab_guide'), icon: Icons.school),
              _rt_InfoCard(
                title: _tx.s('guide_title'),
                body:
                    '${_tx.s('guide_context_1')}\n\n${_tx.s('guide_context_2')}',
                icon: Icons.menu_book,
                color: _rt_Tw.indigo600,
              ),
              for (final g in ['g_s1', 'g_s2', 'g_s3'])
                _rt_InfoCard(
                  title: _tx.s('${g}_title'),
                  body:
                      '${_tx.s('lbl_action')} ${_tx.s('${g}_action')}\n${_tx.s('lbl_focus')} ${_tx.s('${g}_focus')}',
                  icon: Icons.looks_one,
                  color: _rt_Tw.indigo600,
                  leftBorder: true,
                ),
              const SizedBox(height: 6),
              // Why? tab content.
              _rt_SectionLabel(_tx.s('tab_why'), icon: Icons.lightbulb),
              _rt_InfoCard(
                tag: _tx.s('tag_realworld'),
                title: _tx.s('ctx_title'),
                body: _tx.s('ctx_intro'),
                icon: Icons.public,
                color: _rt_Tw.amber600,
              ),
              for (final ex in [
                ('ex_crane', '🏗️'),
                ('ex_bell', '🔔'),
                ('ex_speaker', '🔊'),
              ])
                _rt_InfoCard(
                  tag: _tx.s('${ex.$1}_sub'),
                  title: '${ex.$2}  ${_tx.s(ex.$1)}',
                  body: _tx.s('${ex.$1}_desc'),
                  color: _rt_Tw.amber600,
                  leftBorder: true,
                ),
              const SizedBox(height: 6),
              // Outcomes tab content + Finish Activity.
              _rt_SectionLabel(_tx.s('out_title'), icon: Icons.emoji_events),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _tx.s('out_subtitle'),
                  style: TextStyle(fontSize: 11, color: _rt_Lab.textMuted),
                ),
              ),
              for (var i = 1; i <= 3; i++)
                _rt_InfoCard(
                  title: _tx.s('out_${i}_title'),
                  body: _tx.s('out_${i}_desc'),
                  icon: Icons.check_circle,
                  color: _rt_Tw.green600,
                ),
              const SizedBox(height: 4),
              _rt_ActionButton(
                key: const ValueKey('btn-finish'),
                label: _tx.s('finish'),
                icon: Icons.emoji_events,
                color: _rt_Tw.indigo600,
                expand: true,
                onPressed: _finishActivity,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepCard(int idx) {
    final active = _step == idx;
    final done = _done.contains(idx);
    final (title, doText, obsLabel, obsText) = switch (idx) {
      0 => (
        _tx.s('proc_s1_title'),
        _tx.s('proc_s1_do'),
        _tx.s('lbl_observe'),
        _tx.s('proc_s1_obs'),
      ),
      1 => (
        _tx.s('proc_s2_title'),
        _tx.s('proc_s2_do'),
        _tx.s('lbl_focus'),
        _tx.s('proc_s2_focus'),
      ),
      2 => (
        _tx.s('proc_s3_title'),
        _tx.s('proc_s3_do'),
        _tx.s('lbl_observe'),
        _tx.s('proc_s3_obs'),
      ),
      _ => (
        _tx.s('proc_s4_title'),
        _tx.s('proc_s4_do'),
        _tx.s('lbl_target'),
        _tx.s('proc_s4_target'),
      ),
    };
    final (label, action) = switch (idx) {
      0 => (_tx.s('btn_power_on'), _isOn ? null : _toggleSwitch),
      1 => (
        _hasCore ? _tx.s('btn_core_remove') : _tx.s('btn_core'),
        _isOn ? _toggleCore : null,
      ),
      2 => (_tx.s('reverse'), _isOn ? _reverseBattery : null),
      _ => (_tx.s('btn_demo'), _craneRunning ? null : () => _runCrane()),
    };
    return GestureDetector(
      key: ValueKey('card-$idx'),
      onTap: () {
        if (_step != idx) _setScenario(idx);
      },
      child: _rt_StepCard(
        number: idx + 1,
        title: title,
        desc: doText,
        actionLabel: label,
        actionIcon: switch (idx) {
          0 => Icons.power_settings_new,
          1 => Icons.crop_16_9,
          2 => Icons.swap_horiz,
          _ => Icons.precision_manufacturing,
        },
        accent: _rt_Tw.indigo600,
        active: active,
        done: done,
        locked: !active,
        onAction: action,
        extra: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hudLine(obsLabel, obsText, _rt_Tw.amber600),
              // The compass shortcut for step 3 (fallback for the 3D drag).
              if (idx == 2 && active) ...[
                const SizedBox(height: 8),
                _rt_ActionButton(
                  key: const ValueKey('btn-compass'),
                  label: _tx.s('btn_move_compass'),
                  icon: Icons.explore,
                  color: _rt_Tw.blue600,
                  onPressed: _moveCompass,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
