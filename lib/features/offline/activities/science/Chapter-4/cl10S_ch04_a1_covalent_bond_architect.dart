// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 4.1: Atomic Architect Studio
// Converted from Cl10S-Ch4-A1-CovalentBondArchitect.html (React + three.js -> mini3d).
//
// Four stations, each its own scene group, picked from the sidebar (the
// source's bottom nav bar): the Sharing Station (slide two H / O / N atoms
// together until their shells overlap -> single, double, triple bond), the
// Carbon Dilemma (gaining 4 e⁻ collapses, losing 4 e⁻ overloads, sharing with
// four H atoms builds methane), the Chain Builder (catenation up to hexane, an
// isobutane branch and the cyclohexane ring) and the Allotrope Vault (diamond
// under pressure, graphite layers sliding and conducting), which ends in the
// "Master Architect" finale.

// --- TRANSLATION DATA (source `content`; `**x**` = <strong>, `\n` = <br/>) ---

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
  static const gray500 = Color(0xFF6B7280);
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal900 = Color(0xFF134E4A);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue900 = Color(0xFF1E3A8A);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red700 = Color(0xFFB91C1C);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
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
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done = false;
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
    this.valueText,
    this.color = _rt_Tw.teal600,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions = null;
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

  /// Rotates so the local +Y axis points along [dir] (cylinders, arrows).
  void pointAlong(_rt_V3 dir) {
    rotationMatrix = _rt_M3.fromUnitVectors(_rt_V3(0, 1, 0), dir);
  }

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
  _rt_Sphere3D(this.radius, this.material, {super.position});

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
    this.pixelHeight,
    this.color = const Color(0xFFFFFFFF),
    this.background,
    this.borderColor,
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
      target = target ?? _rt_V3();

  /// Vertical field of view in degrees.
  double fov;
  final _rt_V3 position;

  /// OrbitControls.target (the point the camera looks at).
  final _rt_V3 target;
  double near = 0.1;
  double far = 5000;

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
    'title': 'Atomic Architect Studio',
    'subtitle': 'Carbon and its Compounds',
    'headerSubtitle': 'Class 10 • Carbon and its Compounds',
    'enterLab': 'INITIALIZE STUDIO',
    'footnote': 'Covalent Bonds • Tetravalency • Catenation • Allotropy',
    'reset': 'Reset',
    'nav': [
      'Sharing Station',
      'Carbon Dilemma',
      'Chain Builder',
      'Allotrope Vault',
    ],
    'formula': {'h2': 'H₂', 'o2': 'O₂', 'n2': 'N₂'},
    'legend': {
      'title': 'Particle Legend',
      'proton': 'Proton (p⁺)',
      'neutron': 'Neutron (n⁰)',
      'lonePair': 'Lone Pair (e⁻)',
      'sharedPair': 'Shared Pair (e⁻)',
    },
    'success': {
      'title': 'Master Architect!',
      'msg':
          'Brilliant! You have successfully mastered covalent bonding, tetravalency, catenation, and allotropy.',
      'btn': 'Restart Studio',
    },
    'ui': {
      'processComplete': 'Bond Formed!',
      'nextStep': 'Next Element',
      'nextStation': 'Next Station',
      'missionObjective': 'Mission Objective',
      'architectExam': "The Architect's Exam",
      'materialAnalysis': 'Material Analysis',
      'guide1':
          '**Mission:** Form a Single Bond (H₂).\n**Action:** Drag the slider to bring Hydrogen atoms closer until shells overlap.',
      'guide2':
          '**Mission:** Form a Double Bond (O₂).\n**Action:** Drag Oxygen atoms closer. Observe how they share 2 pairs of electrons to reach 8.',
      'guide3':
          '**Mission:** Form a Triple Bond (N₂).\n**Action:** Drag Nitrogen atoms. They must share 3 pairs (6 electrons) to be stable.',
      'distance': 'Atom Proximity',
      'addElectron': 'Add 4 Electrons (C⁴⁻)',
      'remElectron': 'Remove 4 Electrons (C⁴⁺)',
      'shareElectron': 'Share Electrons (Covalent)',
      'dilemmaGuide':
          '**The Carbon Dilemma:** Carbon has 4 valence electrons. It needs 8 for stability.\n1. Try to **Add 4 electrons** (C⁴⁻).\n2. Try to **Remove 4 electrons** (C⁴⁺).',
      'failGain':
          '**Result: Structure Collapsed (C⁴⁻)**\nThe nucleus (6 protons) shakes violently. It cannot hold 10 electrons due to inter-electronic repulsion. The structure collapses.',
      'failLose':
          '**Result: Energy Overload (C⁴⁺)**\nEnergy Meter spiked! The energy required to overcome the attractive force of the nucleus and remove 4 electrons is too high (High Ionization Energy).',
      'successCovalent':
          '**Stable Covalent Bond (CH₄)**\nCarbon shares its 4 valence electrons with 4 Hydrogen atoms. Now, Carbon has 8 electrons (Octet) and Hydrogen has 2 (Duplet). This is Methane.',
      'addCarbon': '+ Add Carbon Link',
      'addBranch': '+ Add Branch (Isobutane)',
      'makeRing': 'Form Ring (Cyclohexane)',
      'chainGuide':
          "**Mission:** Build long Carbon chains (Catenation).\n**Action:** Click **'+ Add Carbon Link'** repeatedly to create Ethane, Propane, and Butane.",
      'propButane':
          "**Observation:** You have built a long chain (Butane). Carbon's unique ability to link with itself is called **Catenation**.",
      'isoButane':
          '**Observation:** The structure rearranged! Carbon can also form **Branched Chains** (Isobutane).',
      'cycloHexane':
          '**Observation:** The head joined the tail! Carbon can form **Cyclic Rings** (Cyclohexane).',
      'applyPressure': 'Apply Pressure',
      'slideLayer': 'Slide Layers',
      'diamondGuide':
          'Diamond: A rigid 3D tetrahedral network. Apply pressure to test.',
      'graphiteGuide':
          'Graphite: Hexagonal layers bonded weakly. Try sliding them.',
      'diamondProp':
          'Diamond is extremely hard due to strong 3D covalent bonding. It does not budge under pressure.',
      'graphiteProp':
          'Graphite is soft and acts as a lubricant because its layers can slide over each other.',
      'conductTest': 'Turn on Electricity',
      'conductSuccess':
          'Success! Electrons flow through the layers because each carbon has one free electron.',
      'continueBtn': 'Continue',
      'finishExperiment': 'Finish Exploration',
      'tryAgain': 'Try Again',
      'correct': 'Correct!',
      'incorrect': 'Incorrect.',
      'panMode': 'Pan Mode',
      'rotateMode': 'Rotate Mode',
      'lockMode': 'Lock Rotation',
      'unlockMode': 'Unlock Rotation',
      'toggleLabels': 'Toggle Labels',
      'stations': 'Studio Stations',
    },
    'stations': {
      's1': {
        'title': 'The Sharing Station',
        'desc':
            'Atoms share electrons to achieve a stable noble gas configuration (Octet/Duplet).',
        'labels': {
          'hydrogen': 'Hydrogen',
          'oxygen': 'Oxygen',
          'nitrogen': 'Nitrogen',
          'single':
              '**Single Bond (H-H)**\nOverlap complete. 2 electrons now orbit both nuclei (Duplet).',
          'double':
              '**Double Bond (O=O)**\nOverlap complete. 4 electrons are shared between the atoms (Octet).',
          'triple':
              '**Triple Bond (N≡N)**\nOverlap complete. 6 electrons are shared. Nitrogen is very stable.',
        },
      },
      's2': {
        'title': 'The Carbon Dilemma',
        'desc':
            'Carbon (Atomic No: 6) has 4 valence electrons. How does it become stable?',
        'labels': {
          'c': 'Nucleus (6p⁺)',
          'ch4': 'Methane (CH₄)',
          'valence': 'Valence Shell (4e⁻)',
        },
      },
      's3': {
        'title': 'The Chain Builder',
        'desc':
            'Catenation is the unique ability of Carbon to form bonds with other Carbon atoms.',
        'labels': {
          'c1': 'Methane',
          'c2': 'Ethane',
          'c3': 'Propane',
          'c4': 'Butane',
          'c5': 'Pentane',
          'c6': 'Hexane',
          'iso': 'Isobutane (Branched)',
          'ring': 'Cyclohexane (Ring)',
        },
      },
      's4': {
        'title': 'The Allotrope Vault',
        'desc':
            'Different physical forms of the same element are called Allotropes. Compare Diamond and Graphite.',
        'optDiamond': 'Diamond Lattice',
        'optGraphite': 'Graphite Lattice',
      },
    },
    'tabs': {'explore': 'Mission Objectives'},
    'explore': {
      'objective':
          'Your Mission: Master the mechanics of the Covalent Bond and harness Carbon\'s unique properties to build stable structures.',
      'steps': 'Complete the following architectural challenges:',
      'missions': [
        {
          'text': 'Zone 1: Covalent Bonds',
          'sub':
              'ACTION: Bring H, O, and N atoms together. OBSERVE: Count the shared electrons to identify single, double, and triple bonds.',
        },
        {
          'text': 'Zone 2: Tetravalency',
          'sub':
              'ACTION: Try to force Carbon to gain or lose electrons. When it fails, use Hydrogen to form covalent bonds.',
        },
        {
          'text': 'Zone 3: Catenation',
          'sub':
              "ACTION: Use the 'Add Carbon' tool to build long chains. Then try creating a branch, and finally a closed ring.",
        },
        {
          'text': 'Zone 4: Allotropes',
          'sub':
              'ACTION: Test the physical properties of Diamond (pressure) and Graphite (sliding). Relate the property to the 3D structure.',
        },
      ],
    },
  },
  'hi': {
    'title': 'परमाणु वास्तुकार स्टूडियो',
    'subtitle': 'कार्बन और उसके यौगिक',
    'headerSubtitle': 'कक्षा 10 • कार्बन और उसके यौगिक',
    'enterLab': 'सिमुलेशन प्रारंभ करें',
    'footnote': 'सहसंयोजी आबंध • चतुःसंयोजकता • श्रृंखलन • अपररूपता',
    'reset': 'रीसेट',
    'nav': [
      'साझाकरण स्टेशन',
      'कार्बन की दुविधा',
      'श्रृंखला निर्माता',
      'अपररूप वॉल्ट',
    ],
    'legend': {
      'title': 'कण संकेत',
      'proton': 'प्रोटॉन (p⁺)',
      'neutron': 'न्यूट्रॉन (n⁰)',
      'lonePair': 'एकाकी युग्म (e⁻)',
      'sharedPair': 'साझा युग्म (e⁻)',
    },
    'success': {
      'title': 'मास्टर वास्तुकार!',
      'msg':
          'शानदार! आपने सहसंयोजक बंधन, चतुर्संयोजकता, श्रृंखलन और अपररूपता में सफलतापूर्वक महारत हासिल कर ली है।',
      'btn': 'सिमुलेशन फिर से शुरू करें',
    },
    'ui': {
      'processComplete': 'बंधन बन गया!',
      'nextStep': 'अगला तत्व',
      'nextStation': 'अगला स्टेशन',
      'missionObjective': 'मिशन का उद्देश्य',
      'architectExam': 'वास्तुकार की परीक्षा',
      'materialAnalysis': 'पदार्थ विश्लेषण',
      'guide1':
          '**मिशन:** एकल आबंध बनाएं (H₂)।\n**क्रिया:** स्लाइडर को खींचकर हाइड्रोजन परमाणुओं को तब तक करीब लाएं जब तक कि कक्ष अतिव्याप्त न हो जाएं।',
      'guide2':
          '**मिशन:** द्विआबंध बनाएं (O₂)।\n**क्रिया:** ऑक्सीजन परमाणुओं को करीब खींचें। देखें कि 8 इलेक्ट्रॉन पूरे करने के लिए वे इलेक्ट्रॉनों के 2 युग्म कैसे साझा करते हैं।',
      'guide3':
          '**मिशन:** त्रिआबंध बनाएं (N₂)।\n**क्रिया:** नाइट्रोजन परमाणुओं को खींचें। स्थायी होने के लिए उन्हें 3 युग्म (6 इलेक्ट्रॉन) साझा करने होंगे।',
      'distance': 'परमाणु निकटता',
      'addElectron': '4 इलेक्ट्रॉन जोड़ें (C⁴⁻)',
      'remElectron': '4 इलेक्ट्रॉन निकालें (C⁴⁺)',
      'shareElectron': 'इलेक्ट्रॉन साझा करें (सहसंयोजक)',
      'dilemmaGuide':
          '**कार्बन की दुविधा:** कार्बन में 4 संयोजी इलेक्ट्रॉन होते हैं। स्थिरता के लिए इसे 8 की आवश्यकता है।\n1. **4 इलेक्ट्रॉन जोड़ने** (C⁴⁻) का प्रयास करें।\n2. **4 इलेक्ट्रॉन निकालने** (C⁴⁺) का प्रयास करें।',
      'failGain':
          '**परिणाम: संरचना ढह गई (C⁴⁻)**\nनाभिक (6 प्रोटॉन) ज़ोर से काँपता है। अंतर-इलेक्ट्रॉनिक प्रतिकर्षण के कारण यह 10 इलेक्ट्रॉनों को नहीं थाम सकता। संरचना ढह जाती है।',
      'failLose':
          '**परिणाम: ऊर्जा अधिभार (C⁴⁺)**\nऊर्जा मीटर उछल गया! नाभिक के आकर्षण बल को पार करके 4 इलेक्ट्रॉन निकालने के लिए बहुत अधिक ऊर्जा चाहिए (उच्च आयनन ऊर्जा)।',
      'successCovalent':
          '**स्थिर सहसंयोजक बंधन (CH₄)**\nकार्बन अपने 4 संयोजी इलेक्ट्रॉन 4 हाइड्रोजन परमाणुओं के साथ साझा करता है। अब कार्बन के पास 8 इलेक्ट्रॉन (अष्टक) और हाइड्रोजन के पास 2 (द्विक) हैं। यह मीथेन है।',
      'addCarbon': '+ कार्बन कड़ी जोड़ें',
      'addBranch': '+ शाखा जोड़ें (आइसोब्यूटेन)',
      'makeRing': 'वलय बनाएं (साइक्लोहेक्सेन)',
      'chainGuide':
          "**मिशन:** लंबी कार्बन श्रृंखलाएं बनाएं (श्रृंखलन)।\n**क्रिया:** एथेन, प्रोपेन और ब्यूटेन बनाने के लिए बार-बार **'+ कार्बन कड़ी जोड़ें'** दबाएँ।",
      'propButane':
          '**अवलोकन:** आपने एक लंबी श्रृंखला (ब्यूटेन) बनाई है। कार्बन की स्वयं से जुड़ने की अनूठी क्षमता को **श्रृंखलन** कहते हैं।',
      'isoButane':
          '**अवलोकन:** संरचना पुनर्व्यवस्थित हो गई! कार्बन **शाखित श्रृंखलाएं** (आइसोब्यूटेन) भी बना सकता है।',
      'cycloHexane':
          '**अवलोकन:** सिर पूंछ से जुड़ गया! कार्बन **चक्रीय वलय** (साइक्लोहेक्सेन) भी बना सकता है।',
      'applyPressure': 'दबाव डालें',
      'slideLayer': 'परत खिसकाएं',
      'diamondGuide':
          'हीरा: एक कठोर 3D चतुष्फलकीय नेटवर्क। परीक्षण के लिए दबाव डालें।',
      'graphiteGuide':
          'ग्रेफाइट: षट्कोणीय परतें कमजोर रूप से बंधी होती हैं। इन्हें खिसकाकर देखें।',
      'diamondProp':
          'मजबूत 3D सहसंयोजक आबंधों के कारण हीरा बेहद कठोर होता है। यह दबाव में ज़रा भी नहीं दबता।',
      'graphiteProp':
          'ग्रेफाइट नरम होता है और स्नेहक के रूप में कार्य करता है क्योंकि इसकी परतें एक-दूसरे पर फिसल सकती हैं।',
      'conductTest': 'बिजली चालू करें',
      'conductSuccess':
          'सफल! इलेक्ट्रॉन परतों से होकर प्रवाहित होते हैं क्योंकि प्रत्येक कार्बन के पास एक मुक्त इलेक्ट्रॉन होता है।',
      'continueBtn': 'जारी रखें',
      'finishExperiment': 'अन्वेषण समाप्त करें',
      'tryAgain': 'पुनः प्रयास करें',
      'correct': 'सही!',
      'incorrect': 'गलत।',
      'panMode': 'पैन मोड',
      'rotateMode': 'घुमाव मोड',
      'lockMode': 'घुमाव लॉक करें',
      'unlockMode': 'घुमाव अनलॉक करें',
      'toggleLabels': 'लेबल दिखाएँ / छिपाएँ',
      'stations': 'स्टूडियो स्टेशन',
    },
    'stations': {
      's1': {
        'title': 'साझाकरण स्टेशन',
        'desc':
            'परमाणु एक स्थिर अक्रिय गैस विन्यास (अष्टक/द्विक) प्राप्त करने के लिए इलेक्ट्रॉनों को साझा करते हैं।',
        'labels': {
          'hydrogen': 'हाइड्रोजन',
          'oxygen': 'ऑक्सीजन',
          'nitrogen': 'नाइट्रोजन',
          'single':
              '**एकल आबंध (H-H)**\nअतिव्यापन पूर्ण। 2 इलेक्ट्रॉन अब दोनों नाभिकों के चारों ओर घूमते हैं (द्विक)।',
          'double':
              '**द्विआबंध (O=O)**\nअतिव्यापन पूर्ण। परमाणुओं के बीच 4 इलेक्ट्रॉन साझा होते हैं (अष्टक)।',
          'triple':
              '**त्रिआबंध (N≡N)**\nअतिव्यापन पूर्ण। 6 इलेक्ट्रॉन साझा होते हैं। नाइट्रोजन बहुत स्थायी है।',
        },
      },
      's2': {
        'title': 'कार्बन की दुविधा',
        'desc':
            'कार्बन (परमाणु क्रमांक: 6) में 4 संयोजी इलेक्ट्रॉन होते हैं। यह स्थायी कैसे बनता है?',
        'labels': {
          'c': 'नाभिक (6p⁺)',
          'ch4': 'मीथेन (CH₄)',
          'valence': 'संयोजी कोश (4e⁻)',
        },
      },
      's3': {
        'title': 'श्रृंखला निर्माता',
        'desc':
            'श्रृंखलन कार्बन की अन्य कार्बन परमाणुओं के साथ आबंध बनाने की अनूठी क्षमता है।',
        'labels': {
          'c1': 'मीथेन',
          'c2': 'एथेन',
          'c3': 'प्रोपेन',
          'c4': 'ब्यूटेन',
          'c5': 'पेंटेन',
          'c6': 'हेक्सेन',
          'iso': 'आइसोब्यूटेन (शाखित)',
          'ring': 'साइक्लोहेक्सेन (वलय)',
        },
      },
      's4': {
        'title': 'अपररूप वॉल्ट',
        'desc':
            'एक ही तत्व के विभिन्न भौतिक रूपों को अपररूप कहते हैं। हीरे और ग्रेफाइट की तुलना करें।',
        'optDiamond': 'हीरा (Diamond)',
        'optGraphite': 'ग्रेफाइट (Graphite)',
      },
    },
    'tabs': {'explore': 'मिशन के उद्देश्य'},
    'explore': {
      'objective':
          'आपका मिशन: सहसंयोजक बंधन की कार्यविधि में महारत हासिल करें और स्थिर संरचनाएं बनाने के लिए कार्बन के अनूठे गुणों का उपयोग करें।',
      'steps': 'निम्नलिखित वास्तु चुनौतियों को पूरा करें:',
      'missions': [
        {
          'text': 'ज़ोन 1: सहसंयोजक बंधन',
          'sub':
              'क्रिया: H, O और N परमाणुओं को एक साथ लाएं। अवलोकन: एकल, द्वि और त्रि आबंधों की पहचान के लिए साझा इलेक्ट्रॉनों को गिनें।',
        },
        {
          'text': 'ज़ोन 2: चतुर्संयोजकता',
          'sub':
              'क्रिया: कार्बन से इलेक्ट्रॉन प्राप्त कराने या खोने का प्रयास करें। विफल होने पर, सहसंयोजक आबंध बनाने के लिए हाइड्रोजन का उपयोग करें।',
        },
        {
          'text': 'ज़ोन 3: श्रृंखलन',
          'sub':
              "क्रिया: लंबी श्रृंखलाएं बनाने के लिए 'कार्बन जोड़ें' उपकरण का उपयोग करें। फिर एक शाखा बनाएं, और अंत में एक बंद वलय।",
        },
        {
          'text': 'ज़ोन 4: अपररूप',
          'sub':
              'क्रिया: हीरे (दबाव) और ग्रेफाइट (खिसकना) के भौतिक गुणों का परीक्षण करें। गुण को 3D संरचना से जोड़ें।',
        },
      ],
    },
  },
});

// --- Scene colours (source materials) ---
const _eYellow = Color(0xFFFDE047);
const _eCyan = Color(0xFF00FFFF);
const _protonRed = Color(0xFFEF4444);
const _neutronGray = Color(0xFF9CA3AF);
const _hElectronBlue = Color(0xFF3B82F6);
// The source's 0x333333 carbon vanishes on the dark canvas; lifted slightly
// and outlined so the skeletons stay readable.
const _carbon = Color(0xFF52525B);
const _carbonEdge = Color(0xFFA1A1AA);
const _orbitGray = Color(0xFF94A3B8);

/// Station 1 molecules (source `configs`).
enum _Mol { h2, o2, n2 }

class _MolConf {
  const _MolConf(this.id, this.color, this.size, this.electrons, this.shared);
  final String id;
  final Color color;
  final double size;
  final int electrons;

  /// Electrons per atom that join the shared orbit once bonded.
  final int shared;

  String get nameKey => switch (id) {
    'h2' => 'stations.s1.labels.hydrogen',
    'o2' => 'stations.s1.labels.oxygen',
    _ => 'stations.s1.labels.nitrogen',
  };
  String get guideKey => switch (id) {
    'h2' => 'ui.guide1',
    'o2' => 'ui.guide2',
    _ => 'ui.guide3',
  };
  String get obsKey => switch (id) {
    'h2' => 'stations.s1.labels.single',
    'o2' => 'stations.s1.labels.double',
    _ => 'stations.s1.labels.triple',
  };
}

const _mols = {
  _Mol.h2: _MolConf('h2', Color(0xFFFFFFFF), 0.8, 1, 1),
  _Mol.o2: _MolConf('o2', Color(0xFFEF4444), 1.2, 6, 2),
  _Mol.n2: _MolConf('n2', Color(0xFF3B82F6), 1.1, 5, 3),
};

/// Station 3 skeletons (source `structures`). C–C bonds are listed explicitly:
/// the source's "closer than 4 units" rule also bonded the outer carbons of
/// isobutane to each other, which drew a triangle instead of a branch.
typedef _Skeleton = ({
  List<List<double>> c,
  List<List<double>> h,
  List<(int, int)> bonds,
});

List<(int, int)> _chain(int n) => [for (var i = 0; i + 1 < n; i++) (i, i + 1)];

final Map<String, _Skeleton> _skeletons = {
  'c1': (
    c: [
      [0, 0, 0],
    ],
    h: [
      [1.5, 1.5, 1.5],
      [-1.5, -1.5, 1.5],
      [-1.5, 1.5, -1.5],
      [1.5, -1.5, -1.5], //
    ],
    bonds: _chain(1),
  ),
  'c2': (
    c: [
      [-1.5, 0, 0], [1.5, 0, 0], //
    ],
    h: [
      [-2.5, 1.5, 1.5], [-2.5, -1.5, 1.5], [-2.5, 1.5, -1.5], //
      [2.5, 1.5, 1.5], [2.5, -1.5, 1.5], [2.5, 1.5, -1.5],
    ],
    bonds: _chain(2),
  ),
  'c3': (
    c: [
      [-3, 0, 0], [0, 0, 0], [3, 0, 0], //
    ],
    h: [
      [-4, 1.5, 1.5], [-4, -1.5, 1.5], [-4, 1.5, -1.5], [0, 1.5, 1.5], //
      [0, -1.5, 1.5], [4, 1.5, 1.5], [4, -1.5, 1.5], [4, 1.5, -1.5],
    ],
    bonds: _chain(3),
  ),
  'c4': (
    c: [
      [-4.5, 0, 0], [-1.5, 0, 0], [1.5, 0, 0], [4.5, 0, 0], //
    ],
    h: [],
    bonds: _chain(4),
  ),
  'c5': (
    c: [
      [-6, 0, 0], [-3, 0, 0], [0, 0, 0], [3, 0, 0], [6, 0, 0], //
    ],
    h: [],
    bonds: _chain(5),
  ),
  'c6': (
    c: [
      [-7.5, 0, 0],
      [-4.5, 0, 0],
      [-1.5, 0, 0],
      [1.5, 0, 0],
      [4.5, 0, 0],
      [7.5, 0, 0], //
    ],
    h: [],
    bonds: _chain(6),
  ),
  // Spread from the source's 2-unit spacing (spheres touching) to the chains'
  // 3-unit C–C spacing, so the branch reads as a branch.
  'iso': (
    c: [
      [-3, 0, 0], [0, 0, 0], [3, 0, 0], [0, 3, 0], //
    ],
    h: [],
    bonds: [(0, 1), (1, 2), (1, 3)],
  ),
  'ring': (
    c: [
      [0, 3, 0],
      [2.5, 1.5, 0],
      [2.5, -1.5, 0],
      [0, -3, 0],
      [-2.5, -1.5, 0],
      [-2.5, 1.5, 0], //
    ],
    h: [],
    bonds: [..._chain(6), (5, 0)],
  ),
};

/// Station 2 animation phases (source `animState.phase`).
enum _P2 { idle, gain, lose, share }

/// Station 4 animation phases.
enum _P4 { idle, pressure, slide }

/// An observation card (title + body keys, so it follows the language).
class _Obs {
  const _Obs(
    this.titleKey,
    this.bodyKey, {
    this.bold = false,
    this.next = false,
  });
  final String titleKey;
  final String bodyKey;

  /// The Sharing Station wraps its whole observation in <strong>.
  final bool bold;

  /// Shows the "Next Station" button inside the card.
  final bool next;
}

class Cl10SCh04A1CovalentBondArchitectPage extends StatefulWidget {
  const Cl10SCh04A1CovalentBondArchitectPage({super.key});

  @override
  State<Cl10SCh04A1CovalentBondArchitectPage> createState() =>
      _Cl10SCh04A1CovalentBondArchitectPageState();
}

class _Cl10SCh04A1CovalentBondArchitectPageState
    extends State<Cl10SCh04A1CovalentBondArchitectPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E293B), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 40,
    position: _rt_V3(0, 0, 18),
    target: _rt_V3(),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final math.Random _rng = math.Random(7);

  late final _rt_Node3D _g1, _g1Atoms, _g2, _g3, _g3Mol, _g4, _g4Struct;
  late final _rt_Label3D _lblA,
      _lblB,
      _lblPair,
      _lblNucleus,
      _lblValence,
      _lblCh4,
      _lblStruct;
  final List<_rt_Node3D> _atoms = [];
  final List<List<_rt_Sphere3D>> _s1Electrons = [];

  // Station 2 nodes.
  late final _rt_Node3D _nucleus;
  final List<_rt_Sphere3D> _kE = [], _valE = [], _gainE = [];
  final List<_rt_Node3D> _hyd = [];
  final List<_rt_Sphere3D> _hydE = [];
  late final _rt_Mesh3D _flash;

  // Station 4 nodes.
  late final _rt_Node3D _diamond, _graphiteG, _flow;
  final List<_rt_Node3D> _layers = [];
  final List<({_rt_Sphere3D node, double speed})> _flowE = [];
  late final _rt_Mesh3D _plateTop, _plateBottom;

  // --- STATE ---
  int _station = 0;
  final Set<int> _completed = {};
  bool _showLabels = true;
  bool _locked = false;
  double _clock = 0;
  double _aspect = 615 / 412;

  /// Bumped whenever a station (re)starts so stale delayed callbacks bail out.
  int _gen = 0;
  Timer? _finishTimer;

  _Obs? _obs;
  Offset _obsOffset = Offset.zero;

  // Station 1.
  _Mol _mol = _Mol.h2;
  int _distance = 100;
  bool _bonded = false;

  // Station 2.
  _P2 _phase2 = _P2.idle;
  double _prog2 = 0;
  bool _mark2a = false, _mark2b = false;
  bool _ch4 = false;

  // Station 3.
  int _carbonCount = 1;
  String _structure = 'c1';

  // Station 4.
  bool _graphite = false;
  bool _conducting = false;
  _P4 _phase4 = _P4.idle;
  double _prog4 = 0;

  _MolConf get _conf => _mols[_mol]!;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScene();
    _goStation(0, silent: true, rebuild: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _finishTimer?.cancel();
    _tweens.cancelAll();
    _viewCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ scene ---
  static List<_rt_V3> _circle(double r, [int n = 64]) => [
    for (var i = 0; i < n; i++)
      _rt_V3(
        math.cos(i / n * math.pi * 2) * r,
        math.sin(i / n * math.pi * 2) * r,
        0,
      ),
  ];

  static _rt_Label3D _label(_rt_V3 pos) => _rt_Label3D(
    '',
    position: pos,
    pixelHeight: 11,
    color: const Color(0xFF1E3A8A),
    background: Colors.white,
    borderColor: const Color(0xFF3B82F6),
  );

  /// Bond cylinder between two atoms (source `createBondCylinder`). It runs
  /// surface to surface rather than centre to centre: the painter sorts whole
  /// faces, so a centre-to-centre rod would be drawn across the far atom.
  static _rt_Mesh3D _bond(
    _rt_V3 a,
    _rt_V3 b,
    Color color,
    double ra,
    double rb,
  ) {
    final dir = (b - a).normalized();
    final start = a + dir * (ra * 0.9);
    final end = b - dir * (rb * 0.9);
    final m = _rt_Mesh3D(
      _rt_Geometry3D.cylinder(0.1, 0.1, (end - start).length, segments: 8),
      _rt_Material3D(color: color, shininess: 0.3),
    );
    m.position.copy(start.lerp(end, 0.5));
    m.pointAlong(dir);
    m.pickable = false;
    return m;
  }

  void _initScene() {
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.7),
      _rt_Light3D.directional(_rt_V3(10, 20, 15), intensity: 0.6),
    ]);
    _g1 = _scene.add(_rt_Node3D(name: 's1'));
    _g2 = _scene.add(_rt_Node3D(name: 's2'));
    _g3 = _scene.add(_rt_Node3D(name: 's3'));
    _g4 = _scene.add(_rt_Node3D(name: 's4'));

    // Station 1: atoms are rebuilt per molecule; the labels persist.
    _g1Atoms = _g1.add(_rt_Node3D(name: 'atoms'));
    _lblA = _g1.add(_label(_rt_V3(-4, 2.2, 0)));
    _lblB = _g1.add(_label(_rt_V3(4, 2.2, 0)));
    _lblPair = _g1.add(_label(_rt_V3(-4, -1.5, 0)));

    _buildS2();

    _g3Mol = _g3.add(_rt_Node3D(name: 'molecule'));
    _lblStruct = _g3.add(_label(_rt_V3(0, -4, 0)));

    _buildS4();
  }

  void _buildS1() {
    _g1Atoms.clear();
    _atoms.clear();
    _s1Electrons.clear();
    final conf = _conf;
    for (var a = 0; a < 2; a++) {
      final atom = _g1Atoms.add(_rt_Node3D(name: 'atom$a'));
      atom.add(
        _rt_Sphere3D(
          conf.size,
          _rt_Material3D(color: conf.color, shininess: 0.4),
        )..pickable = false,
      );
      atom.add(
        _rt_Line3D(
          _circle(conf.size + 0.6),
          color: _orbitGray,
          width: 1.5,
          opacity: 0.5,
          closed: true,
        ),
      );
      final list = <_rt_Sphere3D>[];
      for (var i = 0; i < conf.electrons; i++) {
        final e =
            _rt_Sphere3D(0.15, _rt_Material3D(color: _eYellow, unlit: true))
              ..pickable = false
              ..depthBias = -0.6;
        // Glow halo for a shared electron (the source's emissive cyan).
        e.add(
          _rt_Sphere3D(
              0.34,
              _rt_Material3D(color: _eCyan, unlit: true, opacity: 0.35),
            )
            ..pickable = false
            ..depthBias = -0.55
            ..visible = false,
        );
        atom.add(e);
        list.add(e);
      }
      _atoms.add(atom);
      _s1Electrons.add(list);
    }
    _frameS1();
  }

  void _buildS2() {
    // Carbon: 6 protons + 6 neutrons packed in a 0.8-radius ball.
    _nucleus = _g2.add(_rt_Node3D(name: 'nucleus'));
    for (var i = 0; i < 12; i++) {
      final theta = _rng.nextDouble() * math.pi * 2;
      final phi = math.acos(2 * _rng.nextDouble() - 1);
      final r = math.pow(_rng.nextDouble(), 1 / 3) * 0.8;
      _nucleus.add(
        _rt_Sphere3D(
          0.35,
          _rt_Material3D(
            color: i < 6 ? _protonRed : _neutronGray,
            shininess: 0.4,
          ),
          position: _rt_V3(
            r * math.sin(phi) * math.cos(theta),
            r * math.sin(phi) * math.sin(theta),
            r * math.cos(phi),
          ),
        )..pickable = false,
      );
    }
    // K and L shells.
    for (final r in [1.42, 2.42]) {
      _g2.add(
        _rt_Line3D(
          _circle(r),
          color: _orbitGray,
          width: 1.5,
          opacity: 0.45,
          closed: true,
        ),
      );
    }
    for (var i = 0; i < 2; i++) {
      _kE.add(
        _g2.add(
          _rt_Sphere3D(0.15, _rt_Material3D(color: _eYellow, unlit: true))
            ..pickable = false,
        ),
      );
    }
    for (var i = 0; i < 4; i++) {
      _valE.add(
        _g2.add(
          _rt_Sphere3D(0.2, _rt_Material3D(color: _eYellow, unlit: true))
            ..pickable = false,
        ),
      );
    }
    for (var i = 0; i < 4; i++) {
      _gainE.add(
        _g2.add(
          _rt_Sphere3D(0.2, _rt_Material3D(color: _protonRed, unlit: true))
            ..pickable = false
            ..visible = false,
        ),
      );
    }
    for (var i = 0; i < 4; i++) {
      final h = _g2.add(_rt_Node3D(name: 'H$i'))..visible = false;
      h.add(
        _rt_Sphere3D(0.6, _rt_Material3D(color: Colors.white, shininess: 0.6))
          ..pickable = false,
      );
      final he = h.add(
        _rt_Sphere3D(0.15, _rt_Material3D(color: _hElectronBlue, unlit: true))
          ..pickable = false
          ..depthBias = -0.5,
      );
      _hyd.add(h);
      _hydE.add(he);
    }
    // White energy flash behind the atom ("Energy Overload").
    _flash = _g2.add(
      _rt_Mesh3D(
          _rt_Geometry3D.plane(100, 100),
          _rt_Material3D(
            color: Colors.white,
            opacity: 0,
            unlit: true,
            doubleSided: true,
          ),
        )
        ..position.z = -5
        ..pickable = false
        ..visible = false,
    );
    _lblNucleus = _g2.add(_label(_rt_V3(0, -3.5, 0)));
    _lblValence = _g2.add(_label(_rt_V3(2.5, 2.5, 0)));
    _lblCh4 = _g2.add(_label(_rt_V3(0, 4, 0)));
  }

  void _buildS3() {
    _g3Mol.clear();
    final s = _skeletons[_structure]!;
    final cPos = [for (final p in s.c) _rt_V3(p[0], p[1], p[2])];
    final cMat = _rt_Material3D(
      color: _carbon,
      shininess: 0.3,
      edgeColor: _carbonEdge,
      edgeWidth: 1.2,
    );
    final hMat = _rt_Material3D(color: Colors.white, shininess: 0.5);
    for (final p in cPos) {
      _g3Mol.add(
        _rt_Sphere3D(1.0, cMat, position: p.clone())..pickable = false,
      );
    }
    for (final (i, j) in s.bonds) {
      _g3Mol.add(_bond(cPos[i], cPos[j], const Color(0xFF94A3B8), 1.0, 1.0));
    }
    for (final p in s.h) {
      final hp = _rt_V3(p[0], p[1], p[2]);
      _g3Mol.add(
        _rt_Sphere3D(0.6, hMat, position: hp.clone())..pickable = false,
      );
      // Each H bonds to its nearest carbon.
      var best = cPos.first;
      for (final c in cPos) {
        if (c.distanceTo(hp) < best.distanceTo(hp)) best = c;
      }
      _g3Mol.add(_bond(hp, best, const Color(0xFFCCCCCC), 0.6, 1.0));
    }
  }

  void _buildS4() {
    _g4Struct = _g4.add(_rt_Node3D(name: 'structure'));

    // Diamond: one carbon bonded tetrahedrally to four others.
    _diamond = _g4Struct.add(_rt_Node3D(name: 'diamond'));
    final dMat = _rt_Material3D(color: const Color(0xFFAADDFF), shininess: 1.0);
    for (final p in [
      _rt_V3(0, 0, 0),
      _rt_V3(2, 2, 2),
      _rt_V3(-2, -2, 2),
      _rt_V3(-2, 2, -2),
      _rt_V3(2, -2, -2),
    ]) {
      _diamond.add(_rt_Sphere3D(0.5, dMat, position: p)..pickable = false);
      if (p.x != 0) _diamond.add(_bond(_rt_V3(), p, Colors.white, 0.5, 0.5));
    }

    // Graphite: three hexagonal sheets, 2.5 apart.
    _graphiteG = _g4Struct.add(_rt_Node3D(name: 'graphite'));
    final cMat = _rt_Material3D(
      color: _carbon,
      shininess: 0.5,
      metalness: 0.5,
      edgeColor: _carbonEdge,
      edgeWidth: 1,
    );
    for (var layer = 0; layer < 3; layer++) {
      final y = (layer - 1) * 2.5;
      final sheet = _graphiteG.add(_rt_Node3D(name: 'layer$layer'));
      final hex = [
        for (var i = 0; i < 6; i++)
          _rt_V3(
            math.cos(i * math.pi / 3) * 2,
            y,
            math.sin(i * math.pi / 3) * 2,
          ),
      ];
      for (var i = 0; i < 6; i++) {
        sheet.add(
          _rt_Sphere3D(0.5, cMat, position: hex[i].clone())..pickable = false,
        );
        sheet.add(
          _bond(hex[i], hex[(i + 1) % 6], const Color(0xFF6B7280), 0.5, 0.5),
        );
      }
      sheet.add(
        _rt_Sphere3D(0.5, cMat, position: _rt_V3(0, y, 0))..pickable = false,
      );
      for (var i = 0; i < 6; i += 2) {
        sheet.add(
          _bond(_rt_V3(0, y, 0), hex[i], const Color(0xFF6B7280), 0.5, 0.5),
        );
      }
      _layers.add(sheet);
    }
    // Delocalised electrons that stream along the layers when conducting.
    _flow = _graphiteG.add(_rt_Node3D(name: 'flow'))..visible = false;
    final eMat = _rt_Material3D(color: const Color(0xFFFFFF00), unlit: true);
    for (var i = 0; i < 20; i++) {
      final e = _flow.add(
        _rt_Sphere3D(
            0.12,
            eMat,
            position: _rt_V3(
              (_rng.nextDouble() - 0.5) * 6,
              (_rng.nextDouble() * 2 - 1) * 2.5,
              (_rng.nextDouble() - 0.5) * 6,
            ),
          )
          ..pickable = false
          ..depthBias = -0.4,
      );
      _flowE.add((node: e, speed: (_rng.nextDouble() + 0.5) * 0.1));
    }

    // Press plates for the diamond pressure test.
    final plateMat = _rt_Material3D(
      color: const Color(0xFF94A3B8),
      opacity: 0.55,
      shininess: 0.6,
      edgeColor: _rt_Tw.slate300,
    );
    _plateTop = _g4.add(
      _rt_Mesh3D(_rt_Geometry3D.box(5.5, 0.3, 5.5), plateMat)
        ..pickable = false
        ..visible = false,
    );
    _plateBottom = _g4.add(
      _rt_Mesh3D(_rt_Geometry3D.box(5.5, 0.3, 5.5), plateMat)
        ..pickable = false
        ..visible = false,
    );
  }

  // ------------------------------------------------------------ frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);
    switch (_station) {
      case 0:
        _frameS1();
      case 1:
        _frameS2(dt);
      case 3:
        _frameS4(dt);
    }
  }

  /// Station 1: atoms at the slider distance; bonded electrons orbit the
  /// bond midpoint in cyan.
  void _frameS1() {
    if (_atoms.length < 2) return;
    final conf = _conf;
    final minD = conf.size * 1.5;
    const maxD = 6.0;
    final x = minD + (maxD - minD) * _distance / 100;
    _atoms[0].position.x = -x;
    _atoms[1].position.x = x;
    final time = _clock * 2;
    final r = conf.size + 0.6;
    final n = conf.electrons;
    for (var a = 0; a < 2; a++) {
      final list = _s1Electrons[a];
      for (var i = 0; i < list.length; i++) {
        final shared = _bonded && i < conf.shared;
        final e = list[i];
        e.material.color = shared ? _eCyan : _eYellow;
        e.children.first.visible = shared;
        final offset = shared ? (a == 0 ? x : -x) : 0.0;
        final angle = a == 0
            ? time + i * math.pi * 2 / n
            : -time + i * math.pi * 2 / n + math.pi;
        e.position.set(offset + math.cos(angle) * r, math.sin(angle) * r, 0);
      }
    }
    final top = conf.size + 1.5;
    _lblA.position.set(-x, top, 0);
    _lblB.position.set(x, top, 0);
    if (_bonded) {
      _lblPair.position.set(0, -(conf.size + 1.7), 0);
    } else {
      _lblPair.position.set(-x, -top, 0);
    }
  }

  /// Station 2: the carbon's shells spin; gain / lose / share play out.
  void _frameS2(double dt) {
    final time = _clock * 2;
    for (var i = 0; i < _kE.length; i++) {
      final a = time * 2 + i * math.pi;
      _kE[i].position.set(math.cos(a) * 1.42, math.sin(a) * 1.42, 0);
    }
    for (var i = 0; i < _valE.length; i++) {
      final a = time + i * math.pi / 2;
      final r = _phase2 == _P2.lose
          ? 2.42 + (15 - 2.42) * math.min(1.0, _prog2)
          : 2.42;
      _valE[i].position.set(math.cos(a) * r, math.sin(a) * r, 0);
    }

    switch (_phase2) {
      case _P2.gain:
        _prog2 += 1.2 * dt;
        for (var i = 0; i < _gainE.length; i++) {
          final r = 10 + (2.42 - 10) * math.min(1.0, _prog2);
          final a = -time * 2 + i * math.pi / 2 + math.pi / 4;
          _gainE[i]
            ..visible = true
            ..position.set(math.cos(a) * r, math.sin(a) * r, 0);
        }
        if (_prog2 > 1) {
          if (!_mark2a) {
            _mark2a = true;
            _rt_playSfx(
              _rt_Sfx.pop,
            ); // the extra electrons crowd into the shell
          }
          _nucleus.position.set(
            (_rng.nextDouble() - 0.5) * 0.3,
            (_rng.nextDouble() - 0.5) * 0.3,
            0,
          );
        }
        if (_prog2 > 2.5) {
          _phase2 = _P2.idle;
          _nucleus.position.set(0, 0, 0);
          for (final e in _gainE) {
            e.visible = false;
          }
          _showObs(const _Obs('ui.tryAgain', 'ui.failGain'));
          _rt_playSfx(_rt_Sfx.wrong);
        }
      case _P2.lose:
        _prog2 += 1.2 * dt;
        if (_prog2 > 0.5) {
          if (!_mark2a) {
            _mark2a = true;
            _rt_playSfx(_rt_Sfx.pop); // energy spike
          }
          _flash.visible = true;
          _flash.material.opacity =
              math.max(0, math.sin((_prog2 - 0.5) * math.pi)) * 0.85;
        }
        if (_prog2 > 1.5) {
          _phase2 = _P2.idle;
          _flash
            ..visible = false
            ..material.opacity = 0;
          _showObs(const _Obs('ui.tryAgain', 'ui.failLose'));
          _rt_playSfx(_rt_Sfx.wrong);
        }
      case _P2.share:
        _prog2 += 0.6 * dt;
        _placeHydrogens();
        if (_prog2 >= 0.5 && !_mark2a) {
          _mark2a = true;
          _rt_playSfx(_rt_Sfx.pop); // the four H atoms dock
        }
        if (_prog2 >= 1.2 && !_mark2b) {
          _mark2b = true;
          _ch4 = true;
          _showObs(
            const _Obs('ui.processComplete', 'ui.successCovalent', next: true),
          );
          _rt_playSfx(_rt_Sfx.success);
          _complete(1);
        }
      case _P2.idle:
        break;
    }
  }

  static final List<_rt_V3> _tetra = [
    _rt_V3(2, 2, 2).normalized() * 3.0,
    _rt_V3(-2, -2, 2).normalized() * 3.0,
    _rt_V3(-2, 2, -2).normalized() * 3.0,
    _rt_V3(2, -2, -2).normalized() * 3.0,
  ];

  /// Hydrogens fly in flat (prog 0..0.5), then fold into the tetrahedron.
  void _placeHydrogens() {
    for (var i = 0; i < _hyd.length; i++) {
      final h = _hyd[i]..visible = true;
      final ang = i * math.pi / 2;
      final flat = _rt_V3(math.cos(ang) * 3.0, math.sin(ang) * 3.0, 0);
      final far = _rt_V3(math.cos(ang) * 10, math.sin(ang) * 10, 0);
      if (_prog2 < 0.5) {
        h.position.copy(far.lerp(flat, _prog2 * 2));
      } else {
        h.position.copy(
          flat.lerp(_tetra[i], math.min(1.0, (_prog2 - 0.5) * 2)),
        );
      }
      // Its electron sits on the side facing the carbon (the shared pair).
      _hydE[i].position.copy(-h.position.normalized() * 0.8);
    }
  }

  /// Station 4: electron stream, pressure test and layer slide.
  void _frameS4(double dt) {
    _flow.visible = _graphite && _conducting;
    if (_flow.visible) {
      for (final e in _flowE) {
        e.node.position.x += e.speed * 60 * dt;
        if (e.node.position.x > 4) e.node.position.x = -4;
      }
    }
    switch (_phase4) {
      case _P4.pressure:
        _prog4 += 3 * dt;
        final p = _prog4;
        final close = p < 0.6
            ? p / 0.6
            : (p < 1.4 ? 1.0 : math.max(0.0, (2 - p) / 0.6));
        final gap = 6 - (6 - 2.7) * close;
        _plateTop
          ..visible = true
          ..position.y = gap;
        _plateBottom
          ..visible = true
          ..position.y = -gap;
        _g4Struct.position.y = math.sin(p * 20) * 0.08;
        if (_prog4 > 2) {
          _phase4 = _P4.idle;
          _g4Struct.position.y = 0;
          _plateTop.visible = false;
          _plateBottom.visible = false;
          _showObs(const _Obs('ui.materialAnalysis', 'ui.diamondProp'));
          _rt_playSfx(_rt_Sfx.pop); // source 'clank': the press bounces off
        }
      case _P4.slide:
        _prog4 += 1.2 * dt;
        for (var i = 0; i < _layers.length; i++) {
          _layers[i].position.x = (i - 1) * math.sin(_prog4 * math.pi) * 2;
        }
        if (_prog4 > 1) {
          _phase4 = _P4.idle;
          for (final l in _layers) {
            l.position.x = 0;
          }
          _showObs(const _Obs('ui.materialAnalysis', 'ui.graphiteProp'));
          _rt_playSfx(_rt_Sfx.success);
          _complete(3);
        }
      case _P4.idle:
        break;
    }
  }

  // --------------------------------------------------------- stations ---
  /// Enters station [s]. Like the source (which unmounts the other stations),
  /// every station starts fresh; only the completed zones are kept.
  void _goStation(int s, {bool silent = false, bool rebuild = true}) {
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    _gen++;
    _tweens.cancelAll();
    void apply() {
      _station = s;
      _obs = null;
      _obsOffset = Offset.zero;
      _mol = _Mol.h2;
      _distance = 100;
      _bonded = false;
      _phase2 = _P2.idle;
      _prog2 = 0;
      _mark2a = _mark2b = false;
      _ch4 = false;
      _carbonCount = 1;
      _structure = 'c1';
      _graphite = false;
      _conducting = false;
      _phase4 = _P4.idle;
      _prog4 = 0;
    }

    if (rebuild) {
      setState(apply);
    } else {
      apply();
    }
    _buildS1();
    _resetS2Nodes();
    _buildS3();
    _resetS4Nodes();
    _g1.visible = s == 0;
    _g2.visible = s == 1;
    _g3.visible = s == 2;
    _g4.visible = s == 3;
    _camera.autoRotate = s == 2;
    _camera.autoRotateSpeed = 2.0;
    _fitCamera();
  }

  /// Source `fitCamera`: z = max(base, base / (aspect * 0.8)). The vault is
  /// seen from slightly above so the hexagonal sheets read without orbiting.
  void _fitCamera() {
    const bases = [18.0, 22.0, 22.0, 20.0];
    final base = bases[_station];
    final dist = math.max(base, base / (_aspect * 0.8));
    final elev = _station == 3 ? 0.26 : 0.0;
    final ty = _station == 1 ? -0.8 : -0.6;
    _camera.target.set(0, ty, 0);
    _camera.position.set(0, ty + dist * math.sin(elev), dist * math.cos(elev));
    _camera.zoom = 1;
  }

  void _complete(int i) {
    if (_completed.contains(i)) return;
    setState(() => _completed.add(i));
  }

  void _showObs(_Obs o) {
    setState(() {
      _obs = o;
      _obsOffset = Offset.zero;
    });
  }

  void _closeObs() {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _obs = null);
  }

  void _nextStation() {
    if (_station < 3) _goStation(_station + 1);
  }

  // ------------------------------------------------ station 1: sharing ---
  void _selectMol(_Mol m) {
    _rt_playSfx(_rt_Sfx.click);
    _gen++;
    _tweens.cancelAll();
    setState(() {
      _mol = m;
      _distance = 100;
      _bonded = false;
      _obs = null;
    });
    _buildS1();
  }

  void _setDistance(double v) {
    final d = v.round();
    if (d == _distance) return;
    setState(() => _distance = d);
    if (d == 0 && !_bonded) {
      setState(() => _bonded = true);
      _rt_playSfx(_rt_Sfx.pop); // source 'clank': the shells lock together
      final g = _gen;
      final conf = _conf;
      _tweens.wait(500).then((_) {
        if (!mounted || g != _gen || !_bonded) return;
        final last = _mol == _Mol.n2;
        _showObs(
          _Obs('ui.processComplete', conf.obsKey, bold: true, next: last),
        );
        if (last) {
          _rt_playSfx(_rt_Sfx.success);
          _complete(0);
        } else {
          _rt_playSfx(_rt_Sfx.correct);
        }
      });
    } else if (d > 0 && _bonded) {
      setState(() => _bonded = false);
    }
  }

  // ------------------------------------------------ station 2: dilemma ---
  void _resetS2Nodes() {
    _nucleus.position.set(0, 0, 0);
    for (final e in _gainE) {
      e.visible = false;
    }
    for (final h in _hyd) {
      h.visible = false;
    }
    _flash
      ..visible = false
      ..material.opacity = 0;
  }

  /// Source `triggerAction`: gain / lose play 'zap', share plays 'fire'.
  void _trigger(_P2 p) {
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _obs = null;
      _ch4 = false;
      _phase2 = p;
      _prog2 = 0;
      _mark2a = _mark2b = false;
    });
    _resetS2Nodes();
  }

  // -------------------------------------------------- station 3: chains ---
  void _addCarbon() {
    if (_carbonCount >= 6) return;
    final next = _carbonCount + 1;
    setState(() {
      _carbonCount = next;
      _structure = 'c$next';
      if (next == 4) {
        _obs = const _Obs('ui.processComplete', 'ui.propButane');
        _obsOffset = Offset.zero;
      }
    });
    _buildS3();
    _rt_playSfx(next == 4 ? _rt_Sfx.correct : _rt_Sfx.pop);
  }

  void _addBranch() {
    _rt_playSfx(_rt_Sfx.pop); // source 'clank'
    setState(() {
      _structure = 'iso';
      _obs = const _Obs('ui.processComplete', 'ui.isoButane');
      _obsOffset = Offset.zero;
    });
    _buildS3();
  }

  void _makeRing() {
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _structure = 'ring';
      _obs = const _Obs('ui.processComplete', 'ui.cycloHexane');
      _obsOffset = Offset.zero;
    });
    _buildS3();
    _complete(2);
  }

  // ------------------------------------------------ station 4: allotropes ---
  void _resetS4Nodes() {
    _diamond.visible = !_graphite;
    _graphiteG.visible = _graphite;
    _flow.visible = false;
    _g4Struct.position.y = 0;
    for (final l in _layers) {
      l.position.x = 0;
    }
    _plateTop.visible = false;
    _plateBottom.visible = false;
  }

  void _selectAllotrope(bool graphite) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _graphite = graphite;
      _obs = null;
      _conducting = false;
      _phase4 = _P4.idle;
      _prog4 = 0;
    });
    _resetS4Nodes();
  }

  void _interact() {
    setState(() {
      _obs = null;
      _phase4 = _graphite ? _P4.slide : _P4.pressure;
      _prog4 = 0;
    });
    // Pressure: source 'fire' rumble. Slide: its 'click' is the button's own.
    if (!_graphite) _rt_playSfx(_rt_Sfx.magic);
  }

  void _toggleConduct() {
    final on = !_conducting;
    setState(() {
      _conducting = on;
      _obs = on ? const _Obs('ui.materialAnalysis', 'ui.conductSuccess') : null;
      _obsOffset = Offset.zero;
    });
    if (on) {
      _rt_playSfx(_rt_Sfx.magic); // source 'zap'
      _finishTimer?.cancel();
      _finishTimer = Timer(const Duration(milliseconds: 4000), _finish);
    } else {
      _rt_playSfx(_rt_Sfx.toggle);
    }
  }

  void _finish() {
    if (!mounted) return;
    _rt_playSfx(_rt_Sfx.success);
    _rt_showShellPopup(
      context,
      title: _tx.s('success.title'),
      message: _tx.s('success.msg'),
      icon: Icons.military_tech,
      color: _rt_Tw.blue500,
      actions: [
        _rt_ActionButton(
          key: const ValueKey('restart-studio'),
          label: _tx.s('success.btn'),
          icon: Icons.replay,
          color: _rt_Tw.green600,
          onPressed: () {
            Navigator.of(context).pop();
            _rt_playSfx(_rt_Sfx.scenario);
            _restart();
          },
        ),
        _rt_ActionButton(
          label: _rt_CommonStrings.close,
          icon: Icons.close,
          color: _rt_Tw.slate500,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ tools ---
  void _toggleLock() {
    setState(() => _locked = !_locked);
    _camera.enableRotate = !_locked;
  }

  void _toggleLabels() => setState(() => _showLabels = !_showLabels);

  void _restart() {
    _finishTimer?.cancel();
    _finishTimer = null;
    _completed.clear();
    _showLabels = true;
    _locked = false;
    _camera.enableRotate = true;
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _goStation(0, silent: true);
  }

  /// Label texts follow the language; visibility follows the labels tool.
  void _syncLabels() {
    final name = _tx.s(_conf.nameKey);
    _lblA.text = name;
    _lblB.text = name;
    _lblPair.text = _tx.s(_bonded ? 'legend.sharedPair' : 'legend.lonePair');
    _lblNucleus.text = _tx.s('stations.s2.labels.c');
    _lblValence.text = _tx.s('stations.s2.labels.valence');
    _lblCh4.text = _tx.s('stations.s2.labels.ch4');
    _lblStruct.text = _tx.s('stations.s3.labels.$_structure');
    for (final l in [
      _lblA,
      _lblB,
      _lblPair,
      _lblNucleus,
      _lblValence,
      _lblStruct,
    ]) {
      l.visible = _showLabels;
    }
    _lblCh4.visible = _showLabels && _ch4;
  }

  // --------------------------------------------------------------- UI ---
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
            title: _tx.s('title'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.blue600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
              headerSubtitleColor: _rt_Tw.blue400,
            ),
            canvasBackground: _rt_Tw.slate950,
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('headerSubtitle'),
              buttonLabel: _tx.s('enterLab'),
              footnote: _tx.s('footnote'),
              icon: Icons.hub,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _fitCamera,
            toolbarExtras: [
              _rt_RotatePanToggle(
                controller: _viewCtrl,
                accent: _rt_Tw.blue600,
              ),
              const SizedBox(height: 4),
              _toolBtn(
                key: const ValueKey('tool-lock'),
                icon: _locked ? Icons.lock : Icons.lock_open,
                tip: _tx.s(_locked ? 'ui.unlockMode' : 'ui.lockMode'),
                active: _locked,
                onTap: _toggleLock,
              ),
              const SizedBox(height: 4),
              _toolBtn(
                key: const ValueKey('tool-labels'),
                icon: _showLabels ? Icons.label : Icons.label_off_outlined,
                tip: _tx.s('ui.toggleLabels'),
                active: _showLabels,
                onTap: _toggleLabels,
              ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.flag,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: LayoutBuilder(
              builder: (context, c) {
                if (c.maxHeight > 0 && c.maxWidth.isFinite) {
                  _aspect = c.maxWidth / c.maxHeight;
                }
                return _rt_Scene3DView(
                  scene: _scene,
                  camera: _camera,
                  controller: _viewCtrl,
                  onFrame: _onFrame,
                );
              },
            ),
            canvasOverlays: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, c) =>
                      Stack(children: _overlays(c.biggest)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toolBtn({
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
        onTap: () {
          _rt_playSfx(_rt_Sfx.toggle);
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _rt_Tw.blue600 : _rt_Lab.surface,
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

  // ------------------------------------------------------ canvas overlays ---
  /// The source's guide toast (Sharing Station and Allotrope Vault only),
  /// hidden while an observation card is open.
  String? get _guide {
    if (_obs != null) return null;
    if (_station == 0) return _tx.s(_conf.guideKey);
    if (_station == 3) {
      return _tx.s(_graphite ? 'ui.graphiteGuide' : 'ui.diamondGuide');
    }
    return null;
  }

  List<Widget> _overlays(Size size) {
    final guide = _guide;
    final noteW = math.max(160.0, math.min(310.0, size.width - 72));
    return [
      if (guide != null)
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: _guideToast(
              guide,
              math.max(140.0, math.min(420.0, size.width - 140)),
            ),
          ),
        ),
      // The source shows the legend on every station except the Chain Builder.
      if (_station != 2) Positioned(left: 10, bottom: 10, child: _legend()),
      if (_obs != null)
        Positioned(
          right: 62,
          bottom: 10,
          width: noteW,
          child: Transform.translate(
            offset: _obsOffset,
            child: GestureDetector(
              onPanUpdate: (d) => setState(() {
                _obsOffset = Offset(
                  (_obsOffset.dx + d.delta.dx).clamp(
                    math.min(0.0, -(size.width - 62 - noteW)),
                    40.0,
                  ),
                  (_obsOffset.dy + d.delta.dy).clamp(
                    math.min(0.0, -(size.height - 80)),
                    0.0,
                  ),
                );
              }),
              child: _obsNote(),
            ),
          ),
        ),
    ];
  }

  Widget _guideToast(String text, double maxW) {
    return IgnorePointer(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: _rt_Tw.amber500, width: 5),
          ),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.touch_app, size: 18, color: _rt_Tw.amber500),
            const SizedBox(width: 8),
            Flexible(
              child: _rich(
                text,
                TextStyle(
                  fontSize: 11.5,
                  color: _rt_Lab.text,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    Widget row(Color c, String label, {bool glow = false}) => Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              boxShadow: glow ? [BoxShadow(color: c, blurRadius: 6)] : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: _rt_Lab.text,
            ),
          ),
        ],
      ),
    );
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 7, 10, 8),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _rt_Lab.border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tx.s('legend.title').toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: _rt_Lab.textMuted,
              ),
            ),
            row(_protonRed, _tx.s('legend.proton')),
            row(_rt_Tw.gray500, _tx.s('legend.neutron')),
            row(_rt_Tw.yellow400, _tx.s('legend.lonePair')),
            row(_eCyan, _tx.s('legend.sharedPair'), glow: true),
          ],
        ),
      ),
    );
  }

  /// The source's draggable yellow observation card.
  Widget _obsNote() {
    final o = _obs!;
    const accent = _rt_Tw.amber500;
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.amber50, accent).withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 4, 4),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, size: 16, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tx.s(o.titleKey).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: _rt_Lab.onTinted(_rt_Tw.amber400, _rt_Tw.amber700),
                    ),
                  ),
                ),
                InkResponse(
                  key: const ValueKey('obs-close'),
                  radius: 16,
                  onTap: _closeObs,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: _rt_Lab.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _rt_Lab.tintedBorder(accent)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _rich(
                  _tx.s(o.bodyKey),
                  TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: _rt_Lab.text,
                    fontWeight: o.bold ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (o.next) ...[
                  const SizedBox(height: 8),
                  _rt_ActionButton(
                    key: const ValueKey('obs-next'),
                    label: _tx.s('ui.nextStation'),
                    icon: Icons.arrow_forward,
                    color: _rt_Tw.blue600,
                    expand: true,
                    onPressed: _nextStation,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Renders `**bold**` runs and line breaks (the source's inline HTML).
  static Widget _rich(String s, TextStyle base) {
    final parts = s.split('**');
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++)
            if (parts[i].isNotEmpty)
              TextSpan(
                text: parts[i],
                style: i.isOdd
                    ? const TextStyle(fontWeight: FontWeight.w900)
                    : null,
              ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _exploreTab() {
    final nav = _tx.list('nav');
    final missions = _tx.list('explore.missions');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('ui.missionObjective'),
          desc: _tx.s('explore.objective'),
          accent: _rt_Tw.blue600,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('ui.stations'), icon: Icons.apps),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < nav.length; i++)
                    _stationChip(i, nav[i] as String),
                ],
              ),
              const SizedBox(height: 12),
              _panel(),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.flag),
              Text(
                _tx.s('explore.steps'),
                style: TextStyle(
                  fontSize: 11.5,
                  color: _rt_Lab.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              for (var i = 0; i < missions.length; i++)
                _missionRow(i, missions[i] as Map),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stationChip(int i, String name) {
    final on = _station == i;
    final done = _completed.contains(i);
    return GestureDetector(
      key: ValueKey('station-$i'),
      onTap: () => on ? _rt_playSfx(_rt_Sfx.tap) : _goStation(i),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
        decoration: BoxDecoration(
          color: on
              ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
              : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? _rt_Tw.blue400 : _rt_Lab.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? _rt_Tw.green500 : _rt_Lab.overlay,
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: _rt_Lab.textMuted,
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: on
                    ? _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700)
                    : _rt_Lab.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The source's draggable station panel, docked in the sidebar.
  Widget _panel() {
    final key = 's${_station + 1}';
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border, width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            color: _rt_Lab.overlay,
            child: Text(
              _tx.s('stations.$key.title').toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: _rt_Lab.text,
              ),
            ),
          ),
          Container(height: 1, color: _rt_Lab.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _tx.s('stations.$key.desc'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _rt_Lab.textMuted,
                    height: 1.3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                ...switch (_station) {
                  0 => _panelS1(),
                  1 => _panelS2(),
                  2 => _panelS3(),
                  _ => _panelS4(),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _guideStyle => TextStyle(
    fontSize: 12,
    color: _rt_Lab.text,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  List<Widget> _panelS1() {
    return [
      _rich(_tx.s(_conf.guideKey), _guideStyle),
      const SizedBox(height: 10),
      Row(
        children: [
          for (final m in _Mol.values) ...[
            if (m != _Mol.h2) const SizedBox(width: 6),
            Expanded(
              child: _rt_ChoiceButton(
                key: ValueKey('mol-${m.name}'),
                label: _tx.s('formula.${m.name}'),
                state: _mol == m
                    ? _rt_ChoiceState.selected
                    : _rt_ChoiceState.idle,
                onTap: _mol == m ? null : () => _selectMol(m),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 6),
      _rt_LabeledSlider(
        label: '↔  ${_tx.s('ui.distance')}',
        value: _distance.toDouble(),
        min: 0,
        max: 100,
        valueText: '$_distance',
        color: _rt_Tw.blue500,
        onChanged: _setDistance,
      ),
    ];
  }

  List<Widget> _panelS2() {
    return [
      _rich(_tx.s('ui.dilemmaGuide'), _guideStyle),
      const SizedBox(height: 12),
      _rt_ActionButton(
        label: _tx.s('ui.addElectron'),
        icon: Icons.add_circle,
        color: _rt_Tw.red600,
        expand: true,
        onPressed: () => _trigger(_P2.gain),
      ),
      const SizedBox(height: 8),
      _rt_ActionButton(
        label: _tx.s('ui.remElectron'),
        icon: Icons.remove_circle,
        color: _rt_Tw.red600,
        expand: true,
        onPressed: () => _trigger(_P2.lose),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(height: 1, color: _rt_Lab.border),
      ),
      _rt_ActionButton(
        label: _tx.s('ui.shareElectron'),
        icon: Icons.handshake,
        color: _rt_Tw.green600,
        expand: true,
        onPressed: () => _trigger(_P2.share),
      ),
    ];
  }

  List<Widget> _panelS3() {
    return [
      _rich(_tx.s('ui.chainGuide'), _guideStyle),
      const SizedBox(height: 12),
      _rt_ActionButton(
        label: _tx.s('ui.addCarbon'),
        icon: Icons.add_link,
        color: _rt_Tw.green600,
        expand: true,
        onPressed: _carbonCount >= 6 ? null : _addCarbon,
      ),
      const SizedBox(height: 8),
      _rt_ActionButton(
        label: _tx.s('ui.addBranch'),
        icon: Icons.account_tree,
        color: _rt_Tw.blue600,
        expand: true,
        onPressed: _carbonCount == 4 ? _addBranch : null,
      ),
      const SizedBox(height: 8),
      _rt_ActionButton(
        label: _tx.s('ui.makeRing'),
        icon: Icons.donut_large,
        color: _rt_Tw.red600,
        expand: true,
        onPressed: _carbonCount == 6 ? _makeRing : null,
      ),
      if (_structure == 'ring') ...[
        const SizedBox(height: 14),
        _rt_ActionButton(
          key: const ValueKey('panel-next'),
          label: _tx.s('ui.nextStation'),
          icon: Icons.arrow_forward,
          color: _rt_Tw.blue600,
          expand: true,
          onPressed: _nextStation,
        ),
      ],
    ];
  }

  List<Widget> _panelS4() {
    return [
      Row(
        children: [
          Expanded(
            child: _rt_ChoiceButton(
              key: const ValueKey('allo-diamond'),
              label: _tx.s('stations.s4.optDiamond'),
              state: !_graphite
                  ? _rt_ChoiceState.selected
                  : _rt_ChoiceState.idle,
              onTap: () => _selectAllotrope(false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _rt_ChoiceButton(
              key: const ValueKey('allo-graphite'),
              label: _tx.s('stations.s4.optGraphite'),
              state: _graphite
                  ? _rt_ChoiceState.selected
                  : _rt_ChoiceState.idle,
              onTap: () => _selectAllotrope(true),
            ),
          ),
        ],
      ),
      _rich(
        _tx.s(_graphite ? 'ui.graphiteGuide' : 'ui.diamondGuide'),
        _guideStyle,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(height: 1, color: _rt_Lab.border),
      ),
      _rt_ActionButton(
        label: _tx.s(_graphite ? 'ui.slideLayer' : 'ui.applyPressure'),
        icon: _graphite ? Icons.swap_horiz : Icons.compress,
        color: _rt_Tw.red600,
        expand: true,
        onPressed: _interact,
      ),
      if (_graphite) ...[
        const SizedBox(height: 8),
        _rt_ActionButton(
          key: const ValueKey('conduct'),
          label: _tx.s('ui.conductTest'),
          icon: Icons.bolt,
          color: _conducting ? _rt_Tw.green600 : _rt_Tw.slate500,
          expand: true,
          onPressed: _toggleConduct,
        ),
      ],
    ];
  }

  Widget _missionRow(int i, Map m) {
    final done = _completed.contains(i);
    final active = _station == i;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: done
            ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
            : (active
                  ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
                  : _rt_Lab.surface),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done
              ? _rt_Tw.green500
              : (active ? _rt_Tw.blue400 : _rt_Lab.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? _rt_Tw.green500 : _rt_Lab.overlay,
              shape: BoxShape.circle,
            ),
            child: done
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _rt_Tw.emerald500,
                    ),
                  ),
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
