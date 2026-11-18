// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 10.1: Defects of Vision
// Converted from Cl10S-Ch10-A1-DefectsOfVision.html (three.js -> mini3d).
//
// A cutaway model eye on an optical track: a candle (the object) slides from
// infinity to 15 cm while the crystalline lens bulges and the red ciliary
// ring contracts (accommodation). A defect selector switches between Normal
// Vision, Myopia and Hypermetropia, each with its own power range and a red
// far/near-point marker; a concave or convex spectacle lens with a 0-5 D
// power slider corrects the defect. The eye power, the two refracted rays and
// the blur in the circular Retina View PIP are computed exactly as the
// source's updatePhysics() does. The sidebar holds the controls, the live Lab
// Report (parameters + analysis), the three Explore goals (accommodation,
// myopia fix, hypermetropia fix - completing all three ends the lab), the
// Why-Learn cards, the Teacher Guide and the Learning Outcomes.

// --- TRANSLATION DATA (i18n) ---

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

  Map<String, dynamic> map(String path) =>
      (get(path) as Map?)?.cast<String, dynamic>() ?? const {};
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
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue700 = Color(0xFF1D4ED8);
  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red700 = Color(0xFFB91C1C);
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green700 = Color(0xFF15803D);
  static const emerald500 = Color(0xFF10B981);
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

  final _rt_StepHint? hint;

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

  /// THREE.SphereGeometry(radius, widthSegments, heightSegments, phiStart,
  /// phiLength, thetaStart, thetaLength). Use for partial spheres (bowls,
  /// domes); full spheres render faster and smoother with [_rt_Sphere3D].
  factory _rt_Geometry3D.sphere(
    double radius, {
    int widthSegments = 20,
    int heightSegments = 14,
    double phiStart = 0,
    double phiLength = math.pi * 2,
    double thetaStart = 0,
    double thetaLength = math.pi,
  }) {
    final verts = <_rt_V3>[];
    final grid = <List<int>>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      final row = <int>[];
      final v = iy / heightSegments;
      for (var ix = 0; ix <= widthSegments; ix++) {
        final u = ix / widthSegments;
        final phi = phiStart + u * phiLength;
        final theta = thetaStart + v * thetaLength;
        verts.add(
          _rt_V3(
            -radius * math.cos(phi) * math.sin(theta),
            radius * math.cos(theta),
            radius * math.sin(phi) * math.sin(theta),
          ),
        );
        row.add(verts.length - 1);
      }
      grid.add(row);
    }
    final faces = <List<int>>[];
    for (var iy = 0; iy < heightSegments; iy++) {
      for (var ix = 0; ix < widthSegments; ix++) {
        final a = grid[iy][ix + 1], b = grid[iy][ix];
        final c = grid[iy + 1][ix], d = grid[iy + 1][ix + 1];
        final theta0 = thetaStart + iy / heightSegments * thetaLength;
        final theta1 = thetaStart + (iy + 1) / heightSegments * thetaLength;
        if (theta0.abs() < 1e-9) {
          faces.add([a, c, d]); // top pole
        } else if ((theta1 - math.pi).abs() < 1e-9) {
          faces.add([a, b, c]); // bottom pole
        } else {
          faces.add([a, b, c, d]);
        }
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

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
    this.segments = false,
  });

  List<_rt_V3> points;
  Color color;
  double width;
  double opacity;
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
  _rt_Light3D.point(this.position, {this.intensity = 1.0})
    : kind = _rt_LightKind.point;

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

  /// Intersection with the vertical plane z = [z].
  _rt_V3? intersectZ(double z) =>
      intersectPlane(_rt_V3(0, 0, z), _rt_V3(0, 0, 1));
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
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.cameraControls = true,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame = null;
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
    'activity': 'Defects of Vision',
    'subtitle': 'Class 10 • The Human Eye and the Colourful World',
    'enter': 'Enter _rt_Lab',
    'footnote': 'Myopia • Hypermetropia • Accommodation',
    'defect': 'Vision Defect',
    'modes': {
      'normal': 'Normal Vision',
      'myopia': 'Myopia (Near-sighted)',
      'hypermetropia': 'Hypermetropia (Far-sighted)',
    },
    'drag': 'Drag Object',
    'retina': 'Retina View',
    'report': '_rt_Lab Report',
    'params': 'Parameters',
    'analysis': 'Analysis',
    'objU': 'Object (u)',
    'eyePower': 'Eye Power',
    'power': 'Power',
    'lens': {'concave': 'Concave', 'convex': 'Convex'},
    'lensFull': {'concave': 'Concave Lens', 'convex': 'Convex Lens'},
    'status': {'clear': 'Clear Vision', 'blurry': 'Blurry Vision'},
    'pip': {'clear': 'CLEAR', 'blurry': 'BLURRY'},
    'acc': {
      'relaxed': 'Relaxed',
      'accom': 'Accommodating',
      'strain': 'Max Strain',
    },
    'labels': {
      'obj': 'Object',
      'ciliary': 'Ciliary Muscles',
      'retina': 'Retina',
      'spec': 'Corrective Lens',
      'far': 'Far Point (66cm)',
      'near': 'Near Point (50cm)',
    },
    'an': {
      'normal': 'Normal Vision: The eye focuses correctly on the retina.',
      'normalWarn': 'Using lenses with normal vision distorts focus!',
      'myopiaT': 'Myopia (Near-sighted)',
      'myopiaB': 'Image forms in front of the retina.',
      'myopiaGood': 'Correct! Concave lens pushes focus back to retina.',
      'myopiaBad': 'Incorrect! Convex lens makes it worse.',
      'hyperT': 'Hypermetropia (Far-sighted)',
      'hyperB': 'Image forms behind the retina.',
      'hyperGood': 'Correct! Convex lens pulls focus forward.',
      'hyperBad': 'Incorrect! Concave lens makes it worse.',
    },
    'why': {
      'title': 'Why to Learn?',
      'cards': [
        {
          't': 'Corrective Spectacles',
          'd':
              'Millions of people wear glasses. Understanding lenses helps us prescribe the exact curve needed to fix blurry vision.',
        },
        {
          't': 'Camera Focus',
          'd':
              'Cameras work like eyes. Learning about focal length allows photographers to take sharp photos at any distance.',
        },
      ],
    },
    'teacher': {
      'title': 'Teacher Manual',
      'sections': [
        {
          't': '1. Pre-Activity Context',
          'points': [
            'Ensure students understand Refraction. Use the analogy of a Camera: the retina is the film/sensor, and the crystalline lens is the focusing mechanism.',
          ],
        },
        {
          't': '2. Focus Points (During Demo)',
          'points': [
            'Dynamic Accommodation: Drag the object in "Normal Vision". Ask students to watch the Ciliary Muscles (Red Ring). Notice how they contract (ring gets smaller) to make the lens thicker for near objects.',
            'The Defect Visual: Switch to Myopia. Show that the "Far Point" is no longer Infinity. Rays cross in front of the retina.',
            'Correction Logic: When applying a Concave lens, ask: "Does this lens bend light in or out?" (Out/Diverge). Explain how this "pre-bending" pushes the focal point back onto the retina.',
          ],
        },
        {
          't': '3. Observation Challenges',
          'points': [
            'The Near Point Limit: In Normal mode, drag the object closer than 25cm. Why does it blur? (Muscles cannot contract any further; max power reached).',
            'Hypermetropia vs. Reading: Show that a hypermetropic eye might see distant objects fine, but fails at 25cm (reading distance) because it lacks the power to converge diverging rays from nearby sources.',
          ],
        },
      ],
    },
    'explore': {
      'title': 'Explore Activity',
      'goalWord': 'Goal',
      'concepts': [
        {
          't': '1. Power of Accommodation',
          'goal': 'Demonstrate Ciliary Muscle Action',
          'steps': [
            'Set Vision Defect to Normal Vision.',
            'Drag the Candle from the far left (Infinity) towards the eye.',
            'Observe: Watch the Red Ciliary Muscles contract (ring shrinks) and the Lens bulge (get thicker) as the object gets closer.',
            'Note: The image stays sharp on the retina continuously.',
          ],
        },
        {
          't': '2. Myopia (Near-sightedness)',
          'goal': 'Fix Distant Blur with Concave Lens',
          'steps': [
            'Select Myopia from the selector.',
            'Move the object to Infinity. Notice the rays cross before the retina (Blurry).',
            'Drag the object closer to the Red Marker (Far Point). The image becomes clear here.',
            'Move object back to Infinity (where it is blurry).',
            'Tap the CONCAVE lens card.',
            'Adjust Power to approx -1.5 D. Diverging rays push the focus back.',
          ],
        },
        {
          't': '3. Hypermetropia (Far-sightedness)',
          'goal': 'Fix Near Blur with Convex Lens',
          'steps': [
            'Select Hypermetropia.',
            'Move object to 25cm (Normal Near Point). Rays hit the retina before converging (Blurry).',
            'Drag object away to the Red Marker (Defective Near Point). Image clears up.',
            'Return object to 25cm.',
            'Tap the CONVEX lens card.',
            'Adjust Power to approx +2.0 D. Converging rays bring the focus forward.',
          ],
        },
      ],
    },
    'outcomes': {
      'title': 'Outcomes',
      'items': [
        {
          't': 'Myopia Correction',
          'd':
              'Learned that nearsightedness is fixed with a Concave (Diverging) lens.',
        },
        {
          't': 'Hypermetropia Correction',
          'd':
              'Learned that farsightedness is fixed with a Convex (Converging) lens.',
        },
        {
          't': 'Accommodation',
          'd':
              'Visualized how the eye lens changes thickness for different distances.',
        },
      ],
    },
    'ui': {
      'controls': 'Controls',
      'goalDone': 'Goal {n} achieved!',
      'allDone': 'All goals achieved!',
      'labels': 'Labels',
      'lock': 'Lock rotation',
      'dragTip': 'Drag the candle along the track, or use the slider.',
      'powerOff': 'Select a lens card to enable the power slider.',
    },
    'complete': {
      'title': 'Vision Defects Mastered!',
      'msg':
          'Accommodation: the ciliary muscles thicken the eye lens for near objects. Myopia (image in front of the retina) is corrected with a concave (diverging) lens; Hypermetropia (image behind the retina) is corrected with a convex (converging) lens.',
    },
  },
  'hi': {
    'activity': 'दृष्टि दोष',
    'subtitle': 'कक्षा 10 • मानव नेत्र तथा रंगबिरंगा संसार',
    'enter': 'लैब में प्रवेश करें',
    'footnote': 'निकट दृष्टि • दीर्घ दृष्टि • समंजन',
    'defect': 'दृष्टि दोष',
    'modes': {
      'normal': 'सामान्य दृष्टि',
      'myopia': 'निकट दृष्टि दोष',
      'hypermetropia': 'दीर्घ दृष्टि दोष',
    },
    'drag': 'वस्तु को खींचें',
    'retina': 'रेटिना दृश्य',
    'report': 'लैब रिपोर्ट',
    'params': 'मापदंड',
    'analysis': 'विश्लेषण',
    'objU': 'वस्तु (u)',
    'eyePower': 'नेत्र क्षमता',
    'power': 'क्षमता',
    'lens': {'concave': 'अवतल', 'convex': 'उत्तल'},
    'lensFull': {'concave': 'अवतल लेंस', 'convex': 'उत्तल लेंस'},
    'status': {'clear': 'स्पष्ट दृष्टि', 'blurry': 'धुंधली दृष्टि'},
    'pip': {'clear': 'स्पष्ट', 'blurry': 'धुंधला'},
    'acc': {'relaxed': 'शिथिल', 'accom': 'समंजन जारी', 'strain': 'अधिकतम तनाव'},
    'labels': {
      'obj': 'वस्तु',
      'ciliary': 'सिलियरी मांसपेशियां',
      'retina': 'रेटिना',
      'spec': 'सुधारक लेंस',
      'far': 'दूर बिंदु (66cm)',
      'near': 'निकट बिंदु (50cm)',
    },
    'an': {
      'normal': 'सामान्य दृष्टि: आंख प्रतिबिंब को ठीक रेटिना पर फोकस करती है।',
      'normalWarn': 'सामान्य दृष्टि के साथ लेंस लगाने से फोकस बिगड़ जाता है!',
      'myopiaT': 'निकट दृष्टि दोष (Myopia)',
      'myopiaB': 'प्रतिबिंब रेटिना के सामने बनता है।',
      'myopiaGood': 'सही! अवतल लेंस फोकस को वापस रेटिना पर धकेलता है।',
      'myopiaBad': 'गलत! उत्तल लेंस इसे और बिगाड़ देता है।',
      'hyperT': 'दीर्घ दृष्टि दोष (Hypermetropia)',
      'hyperB': 'प्रतिबिंब रेटिना के पीछे बनता है।',
      'hyperGood': 'सही! उत्तल लेंस फोकस को आगे लाता है।',
      'hyperBad': 'गलत! अवतल लेंस इसे और बिगाड़ देता है।',
    },
    'why': {
      'title': 'क्यों सीखें?',
      'cards': [
        {
          't': 'सुधारात्मक चश्मा',
          'd':
              'लाखों लोग चश्मा पहनते हैं। लेंस को समझने से हमें धुंधली दृष्टि को ठीक करने के लिए सटीक वक्र निर्धारित करने में मदद मिलती है।',
        },
        {
          't': 'कैमरा फोकस',
          'd':
              'कैमरा आंखों की तरह काम करता है। फोकल लंबाई के बारे में जानने से फोटोग्राफरों को किसी भी दूरी पर स्पष्ट तस्वीरें लेने की अनुमति मिलती है।',
        },
      ],
    },
    'teacher': {
      'title': 'शिक्षक गाइड',
      'sections': [
        {
          't': '1. पूर्व-गतिविधि संदर्भ',
          'points': [
            'सुनिश्चित करें कि छात्र अपवर्तन (Refraction) को समझते हैं। कैमरे की सादृश्यता का उपयोग करें: रेटिना फिल्म/सेंसर है, और क्रिस्टलीय लेंस फोकस करने वाला तंत्र है।',
          ],
        },
        {
          't': '2. ध्यान देने योग्य बिंदु',
          'points': [
            "गतिशील समंजन: 'सामान्य दृष्टि' में वस्तु को खींचें। छात्रों से सिलियरी मांसपेशियों (लाल वलय) को देखने के लिए कहें। देखें कि कैसे वे पास की वस्तुओं के लिए लेंस को मोटा बनाने के लिए सिकुड़ती हैं (वलय छोटा हो जाता है)।",
            "दोष दृश्य: निकट दृष्टि दोष (Myopia) पर स्विच करें। दिखाएं कि 'दूर बिंदु' अब अनंत नहीं है। किरणें रेटिना के सामने मिलती हैं।",
            "सुधार तर्क: अवतल लेंस लगाते समय, पूछें: 'क्या यह लेंस प्रकाश को अंदर या बाहर मोड़ता है?' (बाहर/फैलाता है)। समझाएं कि यह 'पूर्व-मोड़' फोकस बिंदु को वापस रेटिना पर कैसे धकेलता है।",
          ],
        },
        {
          't': '3. अवलोकन चुनौतियां',
          'points': [
            'निकट बिंदु सीमा: सामान्य मोड में, वस्तु को 25 सेमी से करीब खींचें। यह धुंधला क्यों हो जाता है? (मांसपेशियां और अधिक नहीं सिकुड़ सकतीं; अधिकतम शक्ति तक पहुंच गई)।',
            'दीर्घ दृष्टि दोष बनाम पढ़ना: दिखाएं कि एक दीर्घ दृष्टि दोष वाली आंख दूर की वस्तुओं को ठीक देख सकती है, लेकिन 25 सेमी (पढ़ने की दूरी) पर विफल हो जाती है क्योंकि इसमें पास के स्रोतों से फैलने वाली किरणों को अभिसरित करने की शक्ति की कमी होती है।',
          ],
        },
      ],
    },
    'explore': {
      'title': 'अन्वेषण',
      'goalWord': 'लक्ष्य',
      'concepts': [
        {
          't': '1. समंजन क्षमता',
          'goal': 'सिलियरी मांसपेशी क्रिया का प्रदर्शन',
          'steps': [
            'दृष्टि दोष को सामान्य दृष्टि पर सेट करें।',
            'मोमबत्ती को दूर बाएं (अनंत) से आंख की ओर खींचें।',
            'निरीक्षण: देखें कि लाल सिलियरी मांसपेशियां सिकुड़ती हैं (वलय छोटा हो जाता है) और लेंस उभरता है (मोटा हो जाता है) जैसे-जैसे वस्तु करीब आती है।',
            'नोट: छवि लगातार रेटिना पर स्पष्ट रहती है।',
          ],
        },
        {
          't': '2. निकट दृष्टि दोष (Myopia)',
          'goal': 'अवतल लेंस के साथ दूर के धुंधलेपन को ठीक करना',
          'steps': [
            'चयनकर्ता से निकट दृष्टि दोष चुनें।',
            'वस्तु को अनंत पर ले जाएं। ध्यान दें कि किरणें रेटिना से पहले मिलती हैं (धुंधला)।',
            'वस्तु को लाल मार्कर (दूर बिंदु) के करीब खींचें। यहाँ छवि स्पष्ट हो जाती है।',
            'वस्तु को वापस अनंत पर ले जाएं (जहां यह धुंधला है)।',
            'अवतल (CONCAVE) लेंस कार्ड पर टैप करें।',
            'शक्ति को लगभग -1.5 D समायोजित करें। फैलने वाली किरणें फोकस को पीछे धकेलती हैं।',
          ],
        },
        {
          't': '3. दीर्घ दृष्टि दोष (Hypermetropia)',
          'goal': 'उत्तल लेंस के साथ पास के धुंधलेपन को ठीक करना',
          'steps': [
            'दीर्घ दृष्टि दोष चुनें।',
            'वस्तु को 25 सेमी (सामान्य निकट बिंदु) पर ले जाएं। किरणें अभिसरित होने से पहले रेटिना से टकराती हैं (धुंधला)।',
            'वस्तु को लाल मार्कर (दोषपूर्ण निकट बिंदु) से दूर खींचें। छवि साफ हो जाती है।',
            'वस्तु को 25 सेमी पर वापस लाएं।',
            'उत्तल (CONVEX) लेंस कार्ड पर टैप करें।',
            'शक्ति को लगभग +2.0 D समायोजित करें। अभिसारी किरणें फोकस को आगे लाती हैं।',
          ],
        },
      ],
    },
    'outcomes': {
      'title': 'सीखने के परिणाम',
      'items': [
        {
          't': 'निकट दृष्टि दोष सुधार',
          'd':
              'सीखा कि निकट दृष्टि दोष को अवतल (अपसारी) लेंस से ठीक किया जाता है।',
        },
        {
          't': 'दीर्घ दृष्टि दोष सुधार',
          'd':
              'सीखा कि दूर दृष्टि दोष को उत्तल (अभिसारी) लेंस से ठीक किया जाता है।',
        },
        {
          't': 'समंजन',
          'd':
              'देखा कि आंख का लेंस अलग-अलग दूरियों के लिए अपनी मोटाई कैसे बदलता है।',
        },
      ],
    },
    'ui': {
      'controls': 'नियंत्रण',
      'goalDone': 'लक्ष्य {n} पूरा हुआ!',
      'allDone': 'सभी लक्ष्य पूरे हुए!',
      'labels': 'लेबल',
      'lock': 'घुमाव लॉक करें',
      'dragTip': 'मोमबत्ती को पटरी पर खींचें, या स्लाइडर का उपयोग करें।',
      'powerOff': 'क्षमता स्लाइडर सक्रिय करने के लिए एक लेंस कार्ड चुनें।',
    },
    'complete': {
      'title': 'दृष्टि दोष में महारत!',
      'msg':
          'समंजन: सिलियरी मांसपेशियां पास की वस्तुओं के लिए नेत्र लेंस को मोटा बनाती हैं। निकट दृष्टि दोष (प्रतिबिंब रेटिना के सामने) अवतल (अपसारी) लेंस से ठीक होता है; दीर्घ दृष्टि दोष (प्रतिबिंब रेटिना के पीछे) उत्तल (अभिसारी) लेंस से ठीक होता है।',
    },
  },
});

// --- COLOURS (source Tailwind cyan accent + scene colours) ---
const _accent = Color(0xFF06B6D4);
const _rayColor = Color(0xFFFACC15);
const _candleYellow = Color(0xFFFFEA00);
const _flameRed = Color(0xFFFF2200);
const _ciliaryRed = Color(0xFFE11D48);
const _valGreen = Color(0xFF4ADE80);
const _valCyan = Color(0xFF22D3EE);
const _valYellow = Color(0xFFEAB308);

const _theme = _rt_ShellTheme(
  accent: _accent,
  headerGradient: [_rt_Tw.slate900, Color(0xFF155E75)],
  headerSubtitleColor: Color(0xFFA5F3FC),
);

// --- PHYSICS CONSTANTS (source) ---
const double _eyeLength = 25; // 3D units; retina at x = -25

/// Visual magnification of the eye anatomy (and of the ray geometry inside
/// it). The source draws the 2.5 cm eye 10x bigger than the track scale; on
/// a phone canvas that is still unreadably small, so it is doubled again.
const double _kEye = 2.0;
const double _pNormalMin = 40.0, _pNormalMax = 44.0;
const double _pMyopiaMin = 41.5, _pMyopiaMax = 45.5;
const double _pHyperMin = 38.0, _pHyperMax = 42.0;

enum _Mode { normal, myopia, hypermetropia }

enum _LensType { none, concave, convex }

/// Everything `updatePhysics()` derives from the current inputs.
class _Phys {
  _Phys({
    required this.uCm,
    required this.zPos,
    required this.pGlasses,
    required this.pAct,
    required this.pReq,
    required this.pMin,
    required this.pMax,
    required this.v3d,
    required this.blur,
  });

  final double uCm; // -infinity for slider < -190
  final double zPos; // candle x position (250 at infinity)
  final double pGlasses;
  final double pAct, pReq, pMin, pMax;
  final double v3d; // image distance in 3D units (retina at 25)
  final double blur;

  bool get clear => (pAct - pReq).abs() <= 0.1;
  String get accKey {
    if ((pAct - pMax).abs() < 0.1) return 'strain';
    if (pAct > pMin + 0.5) return 'accom';
    return 'relaxed';
  }

  double get accPct => (((pAct - 38) / (46 - 38)) * 100).clamp(0, 100);
}

/// updatePhysics(): the whole optics pipeline, exactly as the source.
_Phys _physics(_Mode mode, int sliderVal, _LensType lens, double power) {
  final uCm = sliderVal < -190 ? double.negativeInfinity : sliderVal.toDouble();
  final zPos = uCm.isInfinite ? 250.0 : uCm.abs();

  double pGlasses = 0;
  if (lens == _LensType.concave) pGlasses = -power;
  if (lens == _LensType.convex) pGlasses = power;

  // Spectacle lens first: its image becomes the eye's object.
  var uEyeCm = uCm.isInfinite ? double.negativeInfinity : -zPos;
  if (lens != _LensType.none && pGlasses.abs() > 0) {
    final invVSpec = pGlasses + (uEyeCm.isInfinite ? 0 : 1 / (uEyeCm / 100));
    final vSpecM = invVSpec.abs() < 0.001 ? double.infinity : 1 / invVSpec;
    uEyeCm = vSpecM.isInfinite ? double.negativeInfinity : vSpecM * 100;
  }

  final invUEye = uEyeCm.isInfinite ? 0.0 : 1 / (uEyeCm / 100);
  final pReq = 40.0 - invUEye;
  final (pMin, pMax) = switch (mode) {
    _Mode.normal => (_pNormalMin, _pNormalMax),
    _Mode.myopia => (_pMyopiaMin, _pMyopiaMax),
    _Mode.hypermetropia => (_pHyperMin, _pHyperMax),
  };
  final pAct = pReq.clamp(pMin, pMax).toDouble();
  final vCm = 100 / (pAct + invUEye);
  final v3d = vCm * 10;

  return _Phys(
    uCm: uCm,
    zPos: zPos,
    pGlasses: pGlasses,
    pAct: pAct,
    pReq: pReq,
    pMin: pMin,
    pMax: pMax,
    v3d: v3d,
    blur: (v3d - _eyeLength).abs() * 12,
  );
}

class Cl10SCh10A1DefectsOfVisionPage extends StatefulWidget {
  const Cl10SCh10A1DefectsOfVisionPage({super.key});

  @override
  State<Cl10SCh10A1DefectsOfVisionPage> createState() =>
      _Cl10SCh10A1DefectsOfVisionPageState();
}

class _Cl10SCh10A1DefectsOfVisionPageState
    extends State<Cl10SCh10A1DefectsOfVisionPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF10243E), Color(0xFF020617)],
  );
  // Source camera: side-on (theta 4.71, phi 1.45, radius 260) aimed at the
  // middle of the track; here the track runs along +x and the camera looks
  // down the z axis from slightly above.
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(78, 34, 295),
    target: _rt_V3(78, -2, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();

  late final _rt_Mesh3D _eyeLens;
  late final _rt_Mesh3D _ciliary;
  late final _rt_Node3D _objGroup;
  late final _rt_Node3D _glasses;
  late final _rt_Mesh3D _marker;
  late final _rt_Line3D _rayA, _rayB;
  late final _rt_Label3D _lblObj, _lblCiliary, _lblRetina, _lblSpec, _lblMarker;

  // --- LAB STATE (the toolbar inputs in the HTML) ---
  _Mode _mode = _Mode.normal;
  int _u = -100; // u-slider: -200..-15, < -190 means infinity
  _LensType _lens = _LensType.none;
  double _power = 0; // p-slider: 0..5 step 0.25
  bool _labels = true;
  bool _locked = true;
  bool _reportOpen = true;
  final List<bool> _goals = [false, false, false];
  bool _dragging = false;
  bool _wasClear = true;
  bool _completeShown = false;

  /// Bumped on restart so a pending completion popup is dropped.
  int _gen = 0;

  _Phys get _phys => _physics(_mode, _u, _lens, _power);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScene();
    _wasClear = _phys.clear;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _viewCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ scene ---
  void _initScene() {
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.5),
      _rt_Light3D.directional(_rt_V3(50, 50, 50), intensity: 1.1),
      _rt_Light3D.point(_rt_V3(-50, 20, 30), intensity: 0.5),
    ]);
    _camera
      ..minDistance = 60
      ..maxDistance = 480
      ..saveHome();

    // Track (the source's 300-unit rail with ticks every 10 units).
    _scene.add(
      _rt_Mesh3D(
          _rt_Geometry3D.box(300, 1, 4),
          _rt_Material3D(color: const Color(0xFF1E293B)),
        )
        ..position.set(100, -8, 0)
        ..depthBias = 800
        ..pickable = false,
    );
    final ticks = <_rt_V3>[];
    for (var i = 0; i <= 20; i++) {
      ticks.addAll([_rt_V3(i * 10, -7.4, -1.5), _rt_V3(i * 10, -7.4, 1.5)]);
    }
    _scene.add(
      _rt_Line3D(ticks, color: _rt_Tw.slate400, width: 1.4, segments: true)
        ..depthBias = 600,
    );

    // --- THE EYE (cutaway: the sclera is translucent so the rays and the
    // retina stay visible; the source hides them behind an opaque ball). ---
    final eye = _scene.add(
      _rt_Node3D(name: 'eye')..scale.set(_kEye, _kEye, _kEye),
    );
    // Sclera: partial sphere open towards the cornea (+x).
    eye.add(
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(
            13,
            widthSegments: 28,
            heightSegments: 18,
            thetaLength: 2.6,
          ),
          _rt_Material3D(
            color: const Color(0xFFF1F5F9),
            opacity: 0.22,
            shininess: 0.35,
            doubleSided: true,
          ),
        )
        ..rotation.z = math.pi / 2
        ..position.x = -13
        ..pickable = false,
    );
    // Retina: dark red inner cap at the back of the eye.
    eye.add(
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(
            12.6,
            widthSegments: 22,
            heightSegments: 8,
            thetaLength: 1.15,
          ),
          _rt_Material3D(
            color: const Color(0xFF7F1D1D),
            emissive: const Color(0xFF450A0A),
            doubleSided: true,
            shininess: 0.1,
          ),
        )
        ..rotation.z = math.pi / 2
        ..position.x = -13
        ..pickable = false,
    );
    // Cornea bulge.
    eye.add(
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(
            12.6,
            widthSegments: 20,
            heightSegments: 6,
            thetaStart: math.pi - 0.9,
            thetaLength: 0.9,
          ),
          _rt_Material3D(
            color: Colors.white,
            opacity: 0.14,
            shininess: 0.9,
            doubleSided: true,
          ),
        )
        ..rotation.z = math.pi / 2
        ..position.x = -13
        ..pickable = false,
    );
    // Iris ring + pupil just behind the cornea.
    eye.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(3, 11, 2, segments: 28, openEnded: true),
          _rt_Material3D(
            color: const Color(0xFF1E3A8A),
            doubleSided: true,
            shininess: 0.3,
          ),
        )
        ..rotation.z = math.pi / 2
        ..position.x = -1.5
        ..pickable = false,
    );
    // Crystalline lens: squashed sphere; its x-scale is the accommodation.
    _eyeLens = eye.add(
      _rt_Mesh3D(
        _rt_Geometry3D.sphere(6, widthSegments: 22, heightSegments: 14),
        _rt_Material3D(
          color: const Color(0xFFBFDBFE),
          opacity: 0.55,
          shininess: 0.85,
        ),
      )..pickable = false,
    );
    // Ciliary muscle: red ring round the lens.
    _ciliary = eye.add(
      _rt_Mesh3D(
          _rt_Geometry3D.torus(
            6.5,
            1.0,
            radialSegments: 10,
            tubularSegments: 36,
          ),
          _rt_Material3D(
            color: _ciliaryRed,
            emissive: const Color(0xFF881337),
            shininess: 0.25,
          ),
        )
        ..rotation.y = math.pi / 2
        ..pickable = false,
    );
    // Optic nerve poking out of the back.
    eye.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(1.6, 2.2, 14, segments: 12),
          _rt_Material3D(color: const Color(0xFFFECACA), shininess: 0.2),
        )
        ..position.set(-30, -2.5, 0)
        ..pointAlong(_rt_V3(-0.95, -0.3, 0.1).normalized())
        ..pickable = false,
    );

    // --- CANDLE (object) ---
    _objGroup = _scene.add(_rt_Node3D(name: 'object'));
    _objGroup.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(10, 22, 10),
        _rt_Material3D(opacity: 0, unlit: true),
      )..position.y = 0,
    );
    _objGroup.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(1.5, 1.5, 12, segments: 18),
        _rt_Material3D(
          color: _candleYellow,
          emissive: const Color(0xFF854D0E),
          shininess: 0.25,
        ),
      )..position.y = -1.5,
    );
    _objGroup.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cone(1.0, 4, segments: 14),
        _rt_Material3D(color: _flameRed, unlit: true),
      )..position.y = 6.5,
    );
    _objGroup.add(
      _rt_Sphere3D(
          1.4,
          _rt_Material3D(
            color: const Color(0xFFFB923C),
            opacity: 0.35,
            unlit: true,
          ),
        )
        ..position.y = 6.6
        ..pickable = false,
    );
    _objGroup.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(4, 4, 1.5, segments: 18),
        _rt_Material3D(color: const Color(0xFF334155)),
      )..position.y = -7.5,
    );

    // --- SPECTACLE LENS on its stand at x = 8 ---
    _glasses = _scene.add(
      _rt_Node3D(name: 'glasses')..scale.set(_kEye, _kEye, _kEye),
    );
    _glasses.position.x = 8;
    _glasses.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(8, 8, 0.5, segments: 32),
        _rt_Material3D(
          color: Colors.white,
          opacity: 0.18,
          shininess: 0.9,
          doubleSided: true,
        ),
      )..rotation.z = math.pi / 2,
    );
    _glasses.add(
      _rt_Mesh3D(
        _rt_Geometry3D.torus(8.2, 0.3, radialSegments: 8, tubularSegments: 36),
        _rt_Material3D(color: _valYellow, shininess: 0.5, metalness: 0.4),
      )..rotation.y = math.pi / 2,
    );
    _glasses.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.5, 0.8, 8, segments: 10),
        _rt_Material3D(color: const Color(0xFF334155)),
      )..position.y = -8,
    );
    _glasses.add(
      _rt_Mesh3D(
        _rt_Geometry3D.box(4, 1, 10),
        _rt_Material3D(color: const Color(0xFF334155)),
      )..position.y = -7.6,
    );
    _glasses.traverse((n) => n.pickable = false);
    _glasses.visible = false;

    // --- FAR/NEAR-POINT MARKER (red cone, apex down) ---
    _marker = _scene.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cone(3, 6, segments: 8),
          _rt_Material3D(
            color: const Color(0xFFFF0000),
            opacity: 0.6,
            unlit: true,
          ),
        )
        ..rotation.x = math.pi
        ..position.y = -4
        ..pickable = false,
    );
    _marker.visible = false;

    // --- RAYS (two converging yellow lines) ---
    // Drawn slightly on top (depthBias) so the focus point stays visible
    // through the translucent sclera.
    _rayA = _scene.add(
      _rt_Line3D([], color: _rayColor, width: 2.2, opacity: 0.9)
        ..depthBias = -150
        ..pickable = false,
    );
    _rayB = _scene.add(
      _rt_Line3D([], color: _rayColor, width: 2.2, opacity: 0.9)
        ..depthBias = -150
        ..pickable = false,
    );

    // --- OVERLAY LABELS ---
    _lblObj = _scene.add(_sceneLabel());
    _lblCiliary = _scene.add(_sceneLabel());
    _lblRetina = _scene.add(_sceneLabel());
    _lblSpec = _scene.add(_sceneLabel());
    _lblMarker = _scene.add(_sceneLabel());
  }

  _rt_Label3D _sceneLabel() => _rt_Label3D(
    '',
    pixelHeight: 10,
    color: Colors.white,
    background: const Color(0xE60F172A),
    borderColor: _rt_Tw.slate500,
  )..pickable = false;

  /// Splits a polyline into short chunks so the painter's depth sort
  /// interleaves it with the translucent eye parts.
  void _setPolyline(_rt_Line3D line, List<_rt_V3> pts) {
    final out = <_rt_V3>[];
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i], b = pts[i + 1];
      final n = (a.distanceTo(b) / 5).ceil().clamp(1, 60);
      for (var j = i == 0 ? 0 : 1; j <= n; j++) {
        out.add(a.lerp(b, j / n));
      }
    }
    line.points = out;
    line.visible = out.length > 1;
  }

  /// updateRays(zObj, zSpec, zImg, hasSpec), mapped to the x axis.
  void _updateRays(_Phys p) {
    final zObj = p.zPos;
    final hasSpec = _lens != _LensType.none;
    final zImg = p.v3d;
    const h = 10.0;

    List<_rt_V3> tail(double sign) {
      if (zImg < 24.8) {
        // Myopia look: rays cross in front of the retina, then diverge.
        return [
          _rt_V3(-zImg * _kEye, 0, 0),
          _rt_V3(-25 * _kEye, -3 * _kEye * sign, 0),
        ];
      } else if (zImg > 25.2) {
        // Hypermetropia look: rays hit the retina before crossing.
        final hRet = 3 * (zImg - 25) / zImg;
        return [_rt_V3(-25 * _kEye, hRet * _kEye * sign, 0)];
      }
      return [_rt_V3(-25 * _kEye, 0, 0)];
    }

    _setPolyline(_rayA, [
      _rt_V3(zObj, h, 0),
      if (hasSpec) _rt_V3(8, h, 0),
      _rt_V3(0, 3 * _kEye, 0),
      ...tail(1),
    ]);
    _setPolyline(_rayB, [
      _rt_V3(zObj, h, 0),
      _rt_V3(0, -3 * _kEye, 0),
      ...tail(-1),
    ]);
  }

  /// Repositions every node from the current state (updatePhysics visuals).
  void _syncScene() {
    final p = _phys;
    _objGroup.position.set(p.zPos, 0, 0);

    final thickness = 0.3 + (p.pAct - 38) * 0.08;
    _eyeLens.scale.set(thickness, 1, 1);
    final ms = 1.0 - (p.pAct - 38) * 0.02;
    _ciliary.scale.set(ms, ms, 1);

    final glassesOn = _lens != _LensType.none;
    _glasses.visible = glassesOn;

    _marker.visible = _mode != _Mode.normal;
    if (_mode == _Mode.myopia) _marker.position.x = 66;
    if (_mode == _Mode.hypermetropia) _marker.position.x = 50;

    _updateRays(p);

    _lblObj
      ..text = _tx.s('labels.obj')
      ..position.set(p.zPos, 14, 0)
      ..visible = _labels;
    _lblCiliary
      ..text = _tx.s('labels.ciliary')
      ..position.set(-2, 8.5 * _kEye, 0)
      ..visible = _labels;
    _lblRetina
      ..text = _tx.s('labels.retina')
      ..position.set(-24 * _kEye, -13 * _kEye, 0)
      ..visible = _labels;
    _lblSpec
      ..text = _tx.s('labels.spec')
      ..position.set(8, -11.5 * _kEye, 0)
      ..visible = _labels && glassesOn;
    _lblMarker
      ..text = _tx.s(_mode == _Mode.myopia ? 'labels.far' : 'labels.near')
      ..position.set(_marker.position.x, 1.5, 0)
      ..visible = _labels && _mode != _Mode.normal;
  }

  // ---------------------------------------------------------- controls ---
  /// A change that alters the optics: plays a magic cue when the vision
  /// snaps into focus, then checks the explore goals.
  void _afterPhysicsChange() {
    final clear = _phys.clear;
    if (clear && !_wasClear) _rt_playSfx(_rt_Sfx.magic);
    _wasClear = clear;
    _checkGoals();
  }

  void _setMode(_Mode m) {
    if (m == _mode) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _mode = m;
      // defect-select change: hypermetropia snaps the object to 15 cm,
      // the others to infinity, and the spectacle lens comes off.
      _u = m == _Mode.hypermetropia ? -15 : -200;
      _lens = _LensType.none;
    });
    _afterPhysicsChange();
  }

  void _setU(double raw) {
    final u = raw.round().clamp(-200, -15).toInt();
    if (u == _u) return;
    setState(() => _u = u);
    _afterPhysicsChange();
  }

  /// setLens(type): tapping the selected card deselects it.
  void _setLens(_LensType t) {
    final next = _lens == t ? _LensType.none : t;
    if (next == _LensType.none) {
      _rt_playSfx(_rt_Sfx.click);
    } else {
      final good =
          (_mode == _Mode.myopia && next == _LensType.concave) ||
          (_mode == _Mode.hypermetropia && next == _LensType.convex);
      _rt_playSfx(good ? _rt_Sfx.correct : _rt_Sfx.wrong);
    }
    setState(() => _lens = next);
    _afterPhysicsChange();
  }

  void _setPower(double raw) {
    final v = ((raw * 4).round() / 4).clamp(0.0, 5.0);
    if (v == _power) return;
    setState(() => _power = v);
    _afterPhysicsChange();
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labels = !_labels);
  }

  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _locked = !_locked);
  }

  /// The three Explore goals (the source's exploreContent "Goal:" lines).
  void _checkGoals() {
    final p = _phys;
    final newly = <int>[];
    if (!_goals[0] && _mode == _Mode.normal && !p.uCm.isInfinite && _u >= -35) {
      newly.add(0);
    }
    if (!_goals[1] &&
        _mode == _Mode.myopia &&
        p.uCm.isInfinite &&
        _lens == _LensType.concave &&
        p.clear) {
      newly.add(1);
    }
    if (!_goals[2] &&
        _mode == _Mode.hypermetropia &&
        !p.uCm.isInfinite &&
        _u >= -30 &&
        _lens == _LensType.convex &&
        p.clear) {
      newly.add(2);
    }
    if (newly.isEmpty) return;
    setState(() {
      for (final i in newly) {
        _goals[i] = true;
      }
    });
    _rt_playSfx(_rt_Sfx.correct);
    _shell.showToast(
      newly
          .map((i) => _tx.s('ui.goalDone').replaceAll('{n}', '${i + 1}'))
          .join('\n'),
      color: _rt_Tw.green500,
      icon: Icons.check_circle,
    );
    if (_goals.every((g) => g) && !_completeShown) {
      _completeShown = true;
      final gen = _gen;
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && gen == _gen) {
          _shell.showSuccess(
            title: _tx.s('complete.title'),
            message: _tx.s('complete.msg'),
          );
        }
      });
    }
  }

  void _restart() {
    _gen++;
    setState(() {
      _mode = _Mode.normal;
      _u = -100;
      _lens = _LensType.none;
      _power = 0;
      _labels = true;
      _locked = true;
      _reportOpen = true;
      for (var i = 0; i < _goals.length; i++) {
        _goals[i] = false;
      }
      _dragging = false;
      _completeShown = false;
    });
    _wasClear = _phys.clear;
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _camera.reset();
  }

  // -------------------------------------------------------- candle drag ---
  bool _onPointerDown(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n == _objGroup);
    if (hit == null) return false;
    _dragging = true;
    _rt_playSfx(_rt_Sfx.tap);
    return true;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    if (!_dragging) return;
    // The camera looks down the z axis, so the track lives in the z=0 plane.
    final p = e.ray.intersectZ(0);
    if (p == null) return;
    _setU(-p.x.clamp(15.0, 200.0).toDouble());
  }

  void _onPointerUp(_rt_SceneEvent e) {
    if (!_dragging) return;
    _dragging = false;
    _rt_playSfx(_rt_Sfx.pop);
  }

  // ---------------------------------------------------------- formatting ---
  String get _uText => _u < -190 ? '-∞' : '$_u cm';
  String _powText(double pGlasses) =>
      '${pGlasses > 0 ? '+' : ''}${pGlasses.toStringAsFixed(2)} D';

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _syncScene();
          final next = _goals.indexWhere((g) => !g);
          final concepts = _tx.list('explore.concepts');
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('activity'),
            subtitle: _tx.s('subtitle'),
            theme: _theme,
            canvasBackground: _rt_Tw.slate950,
            intro: _rt_IntroConfig(
              title: _tx.s('activity'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enter'),
              footnote: _tx.s('footnote'),
              icon: Icons.visibility,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              _rt_RotatePanToggle(controller: _viewCtrl, accent: _accent),
              const SizedBox(height: 4),
              _toolButton(
                key: const ValueKey('btn-lock'),
                icon: _locked ? Icons.lock : Icons.lock_open,
                tip: _tx.s('ui.lock'),
                active: _locked,
                onTap: _toggleLock,
              ),
              const SizedBox(height: 4),
              _toolButton(
                key: const ValueKey('btn-labels'),
                icon: Icons.sell,
                tip: _tx.s('ui.labels'),
                active: _labels,
                onTap: _toggleLabels,
              ),
            ],
            hint: _rt_StepHint(
              number: next == -1 ? '✓' : '${next + 1}',
              text: next == -1
                  ? _tx.s('ui.allDone')
                  : (concepts[next] as Map)['goal'] as String,
              label: _tx.s('explore.title'),
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('report'),
                icon: Icons.visibility,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              cameraControls: !_locked,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
            ),
            canvasOverlays: [
              Positioned(
                top: 10,
                left: 64,
                right: 64,
                child: IgnorePointer(
                  child: Center(
                    child: FittedBox(fit: BoxFit.scaleDown, child: _hud()),
                  ),
                ),
              ),
              Positioned(
                right: 64,
                bottom: 14,
                child: IgnorePointer(child: _retinaPip()),
              ),
            ],
          );
        },
      ),
    );
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
            color: active ? _accent : _rt_Lab.surface,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.4),
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

  /// Top-of-canvas read-outs: u, eye power + accommodation, vision status.
  Widget _hud() {
    final p = _phys;
    Widget cell(String label, String value, Color color, String key) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: _rt_Lab.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          key: ValueKey(key),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          cell(_tx.s('objU'), _uText, _valGreen, 'hud-u'),
          const SizedBox(width: 14),
          cell(
            _tx.s('eyePower'),
            '${p.pAct.toStringAsFixed(2)} D',
            _valCyan,
            'hud-p',
          ),
          const SizedBox(width: 14),
          cell(_tx.s('power'), _powText(p.pGlasses), _valYellow, 'hud-spec'),
          const SizedBox(width: 12),
          Container(width: 1, height: 30, color: _rt_Lab.border),
          const SizedBox(width: 12),
          _statusChip(p, const ValueKey('hud-status')),
        ],
      ),
    );
  }

  Widget _statusChip(_Phys p, Key key) {
    final clear = p.clear;
    final color = clear ? _rt_Tw.green500 : _rt_Tw.red500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(clear ? _rt_Tw.green50 : _rt_Tw.red50, color),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _rt_Lab.tintedBorder(color)),
      ),
      child: Text(
        _tx.s('status.${clear ? 'clear' : 'blurry'}').toUpperCase(),
        key: key,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          color: _rt_Lab.onTinted(
            color,
            clear ? _rt_Tw.green700 : _rt_Tw.red700,
          ),
        ),
      ),
    );
  }

  /// The circular "Retina View" picture-in-picture.
  Widget _retinaPip() {
    final p = _phys;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 108,
          height: 108,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF334155), width: 4),
            boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 14)],
          ),
          child: CustomPaint(
            painter: _RetinaPainter(
              blur: p.blur,
              distance: p.zPos,
              statusText: _tx.s('pip.${p.blur > 2 ? 'blurry' : 'clear'}'),
              statusColor: p.blur > 2 ? const Color(0xFFF87171) : _valGreen,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _tx.s('retina').toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: _rt_Tw.slate400,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('ui.controls'),
                icon: Icons.tune,
                color: _valCyan,
              ),
              _caption(_tx.s('defect')),
              for (final m in _Mode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _rt_ChoiceButton(
                    key: ValueKey('mode-${m.name}'),
                    label: _tx.s('modes.${m.name}'),
                    state: _mode == m
                        ? _rt_ChoiceState.selected
                        : _rt_ChoiceState.idle,
                    onTap: () => _setMode(m),
                  ),
                ),
              const SizedBox(height: 4),
              _rt_LabeledSlider(
                key: const ValueKey('u-slider'),
                label: '${_tx.s('drag')} (u)'.toUpperCase(),
                value: _u.toDouble(),
                min: -200,
                max: -15,
                divisions: 185,
                valueText: _uText,
                color: _valGreen,
                onChanged: _setU,
              ),
              Text(
                _tx.s('ui.dragTip'),
                style: TextStyle(
                  fontSize: 11,
                  color: _rt_Lab.textFaint,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _lensCard(_LensType.concave)),
                  const SizedBox(width: 8),
                  Expanded(child: _lensCard(_LensType.convex)),
                ],
              ),
              const SizedBox(height: 6),
              IgnorePointer(
                ignoring: _lens == _LensType.none,
                child: Opacity(
                  opacity: _lens == _LensType.none ? 0.5 : 1,
                  child: _rt_LabeledSlider(
                    key: const ValueKey('p-slider'),
                    label: _tx.s('power').toUpperCase(),
                    value: _power,
                    min: 0,
                    max: 5,
                    divisions: 20,
                    valueText: _powText(_phys.pGlasses),
                    color: _valYellow,
                    onChanged: _setPower,
                  ),
                ),
              ),
              if (_lens == _LensType.none)
                Text(
                  _tx.s('ui.powerOff'),
                  style: TextStyle(
                    fontSize: 11,
                    color: _rt_Lab.textFaint,
                    height: 1.3,
                  ),
                ),
              const SizedBox(height: 12),
              _reportSection(),
              const SizedBox(height: 12),
              _rt_SectionLabel(
                _tx.s('explore.title'),
                icon: Icons.explore,
                color: _valCyan,
              ),
              for (var i = 0; i < _goals.length; i++) _conceptCard(i),
              const SizedBox(height: 8),
              _rt_SectionLabel(
                _tx.s('why.title'),
                icon: Icons.lightbulb,
                color: _valCyan,
              ),
              for (final c in _tx.list('why.cards'))
                _plainCard(
                  title: (c as Map)['t'] as String,
                  child: Text(
                    c['d'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _rt_Lab.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _rt_SectionLabel(
                _tx.s('teacher.title'),
                icon: Icons.school,
                color: _valCyan,
              ),
              for (final s in _tx.list('teacher.sections'))
                _plainCard(
                  title: (s as Map)['t'] as String,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final pt in (s['points'] as List))
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '•  ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _rt_Lab.textMuted,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  pt as String,
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
              const SizedBox(height: 8),
              _rt_SectionLabel(
                _tx.s('outcomes.title'),
                icon: Icons.check_circle,
                color: _valCyan,
              ),
              _plainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final o in _tx.list('outcomes.items'))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check, size: 14, color: _valGreen),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${(o as Map)['t']}: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _rt_Lab.text,
                                      ),
                                    ),
                                    TextSpan(text: o['d'] as String),
                                  ],
                                ),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _caption(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 2),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: _rt_Lab.textMuted,
      ),
    ),
  );

  /// One of the source's `.lens-card` toggles, with its little lens glyph.
  Widget _lensCard(_LensType t) {
    final selected = _lens == t;
    final concave = t == _LensType.concave;
    final tint = concave ? const Color(0xFF60A5FA) : _valYellow;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('lens-${t.name}'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => _setLens(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? _rt_Lab.tinted(const Color(0xFFCFFAFE), _accent)
                : _rt_Lab.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _accent : _rt_Lab.border,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(26, 26),
                painter: _LensIconPainter(concave: concave, color: tint),
              ),
              const SizedBox(height: 3),
              Text(
                _tx.s('lens.${t.name}').toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: selected
                      ? _rt_Lab.onTinted(_accent, const Color(0xFF155E75))
                      : _rt_Lab.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The source's notes panel: Parameters + Analysis, collapsible like
  /// btn-toggle-notes.
  Widget _reportSection() {
    final p = _phys;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const ValueKey('report-toggle'),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() => _reportOpen = !_reportOpen);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, size: 15, color: _valCyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _tx.s('report').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _valCyan,
                      ),
                    ),
                  ),
                  _statusChip(p, const ValueKey('report-status')),
                  const SizedBox(width: 6),
                  Icon(
                    _reportOpen ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: _rt_Lab.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_reportOpen)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                border: Border(top: BorderSide(color: _rt_Lab.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _caption(_tx.s('params')),
                  _paramRow('${_tx.s('objU')}:', _uText, _valGreen, 'disp-u'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_tx.s('eyePower')}:',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _rt_Lab.textMuted,
                          ),
                        ),
                      ),
                      Text(
                        '${p.pAct.toStringAsFixed(2)} D',
                        key: const ValueKey('disp-p-eye'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _valCyan,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _tx.s('acc.${p.accKey}').toUpperCase(),
                        key: const ValueKey('disp-acc'),
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: _valYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Accommodation bar (acc-bar).
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 5,
                      color: _rt_Lab.base,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: p.accPct / 100,
                        child: Container(color: _accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _caption(_tx.s('analysis')),
                  _analysis(p),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _paramRow(String label, String value, Color color, String key) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: _rt_Lab.textMuted,
            ),
          ),
        ),
        Text(
          value,
          key: ValueKey(key),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  /// updateCalculationsPanel(): the textbook-content block.
  Widget _analysis(_Phys p) {
    final rows = <Widget>[];
    void feedback(String text, bool good) {
      final color = good ? _rt_Tw.green500 : _rt_Tw.red500;
      rows.add(
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(good ? _rt_Tw.green50 : _rt_Tw.red50, color),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _rt_Lab.tintedBorder(color)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                good ? Icons.check : Icons.warning_amber_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  key: const ValueKey('an-feedback'),
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: _rt_Lab.onTinted(
                      color,
                      good ? _rt_Tw.green700 : _rt_Tw.red700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final body = TextStyle(fontSize: 12, color: _rt_Lab.text, height: 1.35);
    switch (_mode) {
      case _Mode.normal:
        rows.insert(
          0,
          Text(_tx.s('an.normal'), key: const ValueKey('an-body'), style: body),
        );
        if (_lens != _LensType.none) feedback(_tx.s('an.normalWarn'), false);
      case _Mode.myopia:
        rows.insert(
          0,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_tx.s('an.myopiaT')}\n',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.red400,
                  ),
                ),
                TextSpan(text: _tx.s('an.myopiaB')),
              ],
            ),
            key: const ValueKey('an-body'),
            style: body,
          ),
        );
        if (_lens == _LensType.concave) feedback(_tx.s('an.myopiaGood'), true);
        if (_lens == _LensType.convex) feedback(_tx.s('an.myopiaBad'), false);
      case _Mode.hypermetropia:
        rows.insert(
          0,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_tx.s('an.hyperT')}\n',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.red400,
                  ),
                ),
                TextSpan(text: _tx.s('an.hyperB')),
              ],
            ),
            key: const ValueKey('an-body'),
            style: body,
          ),
        );
        if (_lens == _LensType.convex) feedback(_tx.s('an.hyperGood'), true);
        if (_lens == _LensType.concave) feedback(_tx.s('an.hyperBad'), false);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  /// One Explore concept: goal line, numbered steps, done tick.
  Widget _conceptCard(int i) {
    final c = (_tx.list('explore.concepts')[i] as Map).cast<String, dynamic>();
    final done = _goals[i];
    final accents = [_rt_Tw.emerald500, _rt_Tw.red500, _valYellow];
    return Container(
      key: ValueKey('goal-$i'),
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: done
            ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done ? _rt_Lab.tintedBorder(_rt_Tw.green500) : _rt_Lab.border,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The source's coloured `border-l-4` accent strip.
            Container(width: 4, color: accents[i]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _conceptBody(i, c, done, accents[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conceptBody(int i, Map<String, dynamic> c, bool done, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                c['t'] as String,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.text,
                ),
              ),
            ),
            Icon(
              done ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: done ? _rt_Tw.green500 : _rt_Lab.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${_tx.s('explore.goalWord')}: ${c['goal']}'.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        for (var s = 0; s < (c['steps'] as List).length; s++)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s + 1}. ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                Expanded(
                  child: Text(
                    (c['steps'] as List)[s] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: _rt_Lab.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _plainCard({String? title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _valCyan,
              ),
            ),
            const SizedBox(height: 4),
          ],
          child,
        ],
      ),
    );
  }
}

/// The `drawRetinaView(blur, brightness, distance)` canvas, on a circle.
class _RetinaPainter extends CustomPainter {
  _RetinaPainter({
    required this.blur,
    required this.distance,
    required this.statusText,
    required this.statusColor,
  });

  final double blur;
  final double distance;
  final String statusText;
  final Color statusColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    final k = size.width / 180; // source canvas is 180x180
    final scale = math.min(1.5, math.max(0.1, 25 / (distance + 0.1)));
    final w = 40 * scale * k;
    final h = 160 * scale * k;
    final sigma = (blur * k * 0.5).clamp(0.0, 14.0);
    final blurred = sigma > 0.3
        ? (MaskFilter.blur(BlurStyle.normal, sigma))
        : null;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    // Candle body (yellow) and flame (red), as in the 3D scene.
    canvas.drawRect(
      Rect.fromLTWH(-w / 2, -h / 2 + h * 0.25, w, h * 0.75),
      Paint()
        ..color = _candleYellow
        ..maskFilter = blurred,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -h / 2),
        width: w * 0.8,
        height: h * 0.3,
      ),
      Paint()
        ..color = _flameRed
        ..maskFilter = blurred,
    );
    canvas.restore();

    final tp = TextPainter(
      text: TextSpan(
        text: statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 11 * k * 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, 12 * k));
  }

  @override
  bool shouldRepaint(_RetinaPainter old) =>
      old.blur != blur ||
      old.distance != distance ||
      old.statusText != statusText ||
      old.statusColor != statusColor;
}

/// The little concave / convex glyph on a lens card (source inline SVG).
class _LensIconPainter extends CustomPainter {
  _LensIconPainter({required this.concave, required this.color});

  final bool concave;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final s = size.width / 24;
    final path = Path();
    if (concave) {
      path
        ..moveTo(6 * s, 2 * s)
        ..quadraticBezierTo(14 * s, 12 * s, 6 * s, 22 * s)
        ..moveTo(18 * s, 2 * s)
        ..quadraticBezierTo(10 * s, 12 * s, 18 * s, 22 * s);
    } else {
      path
        ..moveTo(9 * s, 2 * s)
        ..quadraticBezierTo(1 * s, 12 * s, 9 * s, 22 * s)
        ..moveTo(15 * s, 2 * s)
        ..quadraticBezierTo(23 * s, 12 * s, 15 * s, 22 * s);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_LensIconPainter old) =>
      old.concave != concave || old.color != color;
}
