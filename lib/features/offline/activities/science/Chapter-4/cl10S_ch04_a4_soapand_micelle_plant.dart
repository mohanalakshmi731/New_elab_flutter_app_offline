// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 4.4: Soap & Micelle Lab
// Converted from Cl10S-Ch4-A4-TheSoapandMicellePlant .html (React + canvas-2D ->
// Flutter widgets + CustomPainter particle simulations driven by a Ticker).
//
// Four zones, each closed by an observation popup that ticks off one mission:
// 1 Structure - drag the hydrophobic tail onto the Na⁺ head (or tap Connect),
// then test the molecule in water and in oil; 2 Micelle - add soap and scrub
// until the molecules cluster radially round the grease and lift it off a dirty
// shirt; 3 Hard Water - soap foams in distilled water but meets Ca²⁺ ions in
// hard water and turns into rising scum; 4 Detergent - soap vs detergent in hard
// water. The sidebar carries the missions, relevance, teacher's guide and the
// outcomes table; the canvas toolbar adds the source's labels toggle to zoom.

// --- TRANSLATION DATA (source `content`, Telugu dropped) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);
  static const violet500 = Color(0xFF8B5CF6);
  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const green50 = Color(0xFFF0FDF4);
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
    this.done = false,
    this.expand = false,
    this.sound = _rt_Sfx.click,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done;
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
  final List<Widget> canvasOverlays = const [];

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
  _rt_CanvasZoomController({this.min = 0.6, this.max = 3.0, this.step = 1.25});

  final double min;
  final double max;
  final double step;

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
    'title': 'Soap & Micelle _rt_Lab',
    'subtitle': 'Class 10 • Carbon and its Compounds',
    'enterLab': 'Enter _rt_Lab',
    'tabs': {
      'context': 'Relevance',
      'guide': 'Guide',
      'explore': 'Missions',
      'analysis': 'Outcomes',
    },
    'contextTitle': 'Relevance in Daily Life',
    'contextDesc':
        'Understanding the chemistry of cleaning is essential. Soaps are sodium or potassium salts of long-chain carboxylic acids. Their unique structure allows them to clean dirt, which is mostly oily in nature.',
    'apps': [
      {
        'title': 'Hygiene',
        'desc':
            'Soap molecules disrupt the lipid membranes of viruses and bacteria, washing them away.',
      },
      {
        'title': 'Laundry',
        'desc':
            'Detergents are ammonium or sulphonate salts that work effectively even in hard water.',
      },
      {
        'title': 'Environment',
        'desc':
            'Emulsifiers are used to clean oil spills in oceans by breaking oil into smaller droplets.',
      },
    ],
    'guideTitle': "Teacher's Guide / Procedure",
    'guideContext': 'Follow this step-by-step scientific method:',
    'phases': [
      {
        'name': '1. Structure',
        'desc':
            "Understand the 'Amphiphilic' nature. Connect the Hydrophilic Ionic Head (Na+) to the Hydrophobic Carbon Chain Tail.",
      },
      {
        'name': '2. Micelle Formation',
        'desc':
            'Observe how soap molecules arrange themselves radially with the hydrocarbon tail pointing towards the oil.',
      },
      {
        'name': '3. Hard Water Effect',
        'desc':
            "Test soap in water containing Calcium (Ca²⁺) ions. Observe the formation of insoluble 'Scum'.",
      },
      {
        'name': '4. Detergent Action',
        'desc':
            'Compare soap with detergent. Note that detergents remain soluble and foam well in hard water.',
      },
    ],
    'missionTitle': '_rt_Lab Missions',
    'missionObj': 'Complete these tasks to master the topic:',
    'missions': [
      {
        'task': 'Construct Molecule',
        'hint': 'Drag the Hydrophobic Tail to the Ionic Head.',
      },
      {
        'task': 'Form Micelles',
        'hint': 'Add soap and agitate to trap oil in the center.',
      },
      {
        'task': 'Identify Scum',
        'hint': 'Add soap to Hard Water and observe the white precipitate.',
      },
      {
        'task': 'Compare Agents',
        'hint': 'Verify that detergents do not form scum in hard water.',
      },
    ],
    'outcomesTitle': 'Scientific Outcomes',
    'analysisData': [
      {
        'obs': 'Head dissolves in water',
        'learn': 'Ionic part is Hydrophilic (Water-loving).',
      },
      {
        'obs': 'Tail dissolves in oil',
        'learn': 'Carbon chain is Hydrophobic (Water-fearing).',
      },
      {
        'obs': 'Spherical Cluster (Micelle)',
        'learn': 'Emulsion is formed, lifting dirt off fabric.',
      },
      {
        'obs': 'White Precipitate',
        'learn': 'Ca²⁺ ions react with soap to form insoluble Scum.',
      },
      {
        'obs': 'Detergent Lather',
        'learn': 'Sulphonate salts do not precipitate with Ca²⁺/Mg²⁺.',
      },
    ],
    'buttons': {
      'testWater': 'Test in Water',
      'testOil': 'Test in Oil',
      'reset': 'Reset Test',
      'addSoap': '+ Add Soap Solution',
      'agitate': 'Agitate / Scrub',
      'soapA': '+ Soap to Beaker A',
      'soapB': '+ Soap to Beaker B',
      'soap': 'Soap',
      'detergent': 'Detergent',
      'add': 'Add',
      // Additions for the native port.
      'addTpl': 'Add {x}',
      'connect': 'Connect Tail to Head',
    },
    'labels': {
      'head': 'Head',
      'heads': 'Heads',
      'hydrophilic': 'Hydrophilic',
      'tail': 'Hydrophobic Tail',
      'water': 'Water',
      'oil': 'Oil',
      'immediateObs': 'Immediate Observation:',
      'obsWater':
          'The Hydrophilic Head dissolves in water, while the Hydrophobic Tail stays away.',
      'obsOil':
          'The Hydrophobic Tail dissolves in oil, while the Head stays away.',
      'waterMedium': 'Water Medium',
      'dirtyShirt': 'DIRTY T-SHIRT',
      'oilGrease': 'Oil / Grease',
      'distilled': 'A: Distilled Water',
      'hardWater': 'B: Hard Water',
      'massiveFoam': 'Massive Foam',
      'whiteScum': 'White Scum',
      'noFoam': 'No Foam',
      'hardEnv': 'Hard Water Environment (Ca²⁺)',
      'selectAgent': 'Select Cleaning Agent:',
    },
    'toasts': {
      'zone1': 'Drag the Tail. Connect it to the Head to build the molecule.',
      'zone2': 'Add soap, then scrub the cloth to form micelles.',
      'zone3': 'Add soap to both beakers to see the reaction with Hard Water.',
      'zone4': 'Now try Detergent. Does it form scum like soap?',
    },
    'popups': {
      'zone1': {
        'title': 'Observation: Structure of Soap',
        'p1': 'Sodium Stearate (Soap Molecule):',
        'l1': 'Ionic Head (Na⁺): This part is Hydrophilic (Loves Water).',
        'l2': 'Carbon Chain Tail: This part is Hydrophobic (Hates Water).',
        'conc':
            'Conclusion: This dual nature allows soap to bridge the gap between oil and water.',
      },
      'zone2': {
        'title': 'Observation: Micelle Formation',
        'p1': 'Mechanism of Cleansing:',
        'l1': 'Hydrophobic tails attach to the oil/dirt.',
        'l2': 'Hydrophilic heads face outwards into the water.',
        'conc':
            "Result: This forms a spherical structure called a 'Micelle'. The dirt is entrapped in the center and washed away.",
      },
      'zone3': {
        'title': 'Observation: Scum Formation',
        'p1': 'Why did soap fail?',
        'p2':
            "Hard water contains Calcium (Ca²⁺) and Magnesium (Mg²⁺) ions. Soap reacts with them to form an insoluble substance called 'Scum'.",
        'conc':
            'Conclusion: Soap is wasted in hard water and cleaning is difficult.',
      },
      'zone4': {
        'title': 'Observation: Detergent Action',
        'p1': 'Why did Detergent work?',
        'p2':
            'Detergents use ammonium or sulphonate groups (-SO₃Na) instead of carboxylate groups.',
        'conc':
            'Result: These charged ends do not form precipitates with Calcium ions. They remain effective and create lather even in hard water.',
      },
    },
    'nav': {
      'construct': 'Structure',
      'micelle': 'Micelle',
      'hardwater': 'Hard Water',
      'detergent': 'Detergent',
    },
    // Additions for the native port (outcome table headers were hard-coded
    // English in the source; the rest is new chrome).
    'ui': {
      'observation': 'Observation',
      'inference': 'Inference',
      'labelsToggle': 'Toggle Labels',
      'missionDone': 'Mission complete',
      'progress': 'Missions completed',
    },
    'complete': {
      'title': 'All Missions Complete!',
      'msg':
          'You built a soap molecule, trapped grease inside a micelle, saw soap turn into scum in hard water and watched detergent keep working. That is why detergents are used for washing clothes in hard water.',
    },
  },
  'hi': {
    'title': 'साबुन और मिसेल लैब',
    'subtitle': 'कक्षा 10 • कार्बन और उसके यौगिक',
    'enterLab': 'लैब शुरू करें',
    'tabs': {
      'context': 'महत्व',
      'guide': 'गाइड',
      'explore': 'मिशन',
      'analysis': 'परिणाम',
    },
    'contextTitle': 'दैनिक जीवन में महत्व',
    'contextDesc':
        'सफाई के रसायन विज्ञान को समझना आवश्यक है। साबुन लंबी श्रृंखला वाले कार्बोक्जिलिक एसिड के सोडियम या पोटेशियम लवण होते हैं। अपनी विशेष संरचना के कारण ये उस मैल को साफ कर पाते हैं जो अधिकतर तैलीय प्रकृति का होता है।',
    'apps': [
      {
        'title': 'स्वच्छता',
        'desc':
            'साबुन के अणु वायरस और बैक्टीरिया की बाहरी परत को नष्ट करके उन्हें धो देते हैं।',
      },
      {
        'title': 'कपड़े धोना',
        'desc':
            'डिटर्जेंट अमोनियम या सल्फोनेट लवण होते हैं जो कठोर पानी में भी काम करते हैं।',
      },
      {
        'title': 'पर्यावरण',
        'desc':
            'इमल्सीफायर तेल को छोटी बूंदों में तोड़कर समुद्र में तेल के रिसाव को साफ करने में उपयोग किए जाते हैं।',
      },
    ],
    'guideTitle': 'शिक्षक गाइड / प्रक्रिया',
    'guideContext': 'इस चरण-दर-चरण वैज्ञानिक विधि का पालन करें:',
    'phases': [
      {
        'name': '1. संरचना',
        'desc':
            'उभयधर्मी प्रकृति को समझें। जलरागी (Hydrophilic) सिर को जलविरागी (Hydrophobic) पूंछ से जोड़ें।',
      },
      {
        'name': '2. मिसेल निर्माण',
        'desc':
            'देखें कि कैसे साबुन के अणु तेल की ओर अपनी पूंछ करके व्यवस्थित होते हैं।',
      },
      {
        'name': '3. कठोर जल',
        'desc':
            "कैल्शियम (Ca²⁺) आयनों वाले पानी में साबुन का परीक्षण करें और 'मैल' (Scum) का बनना देखें।",
      },
      {
        'name': '4. डिटर्जेंट क्रिया',
        'desc':
            'साबुन की तुलना डिटर्जेंट से करें। डिटर्जेंट कठोर पानी में भी झाग देते हैं।',
      },
    ],
    'missionTitle': 'लैब मिशन',
    'missionObj': 'विषय में महारत हासिल करने के लिए ये कार्य करें:',
    'missions': [
      {'task': 'अणु बनाएं', 'hint': 'जलविरागी पूंछ को खींचकर सिर से जोड़ें।'},
      {
        'task': 'मिसेल बनाएं',
        'hint': 'साबुन डालें और तेल को फंसाने के लिए हिलाएं।',
      },
      {
        'task': 'मैल पहचानें',
        'hint': 'कठोर पानी में साबुन डालें और सफेद अवक्षेप देखें।',
      },
      {
        'task': 'तुलना करें',
        'hint': 'पुष्टि करें कि डिटर्जेंट मैल नहीं बनाते हैं।',
      },
    ],
    'outcomesTitle': 'वैज्ञानिक परिणाम',
    'analysisData': [
      {
        'obs': 'सिर पानी में घुलता है',
        'learn': 'आयनिक भाग जलरागी (पानी से प्यार) है।',
      },
      {
        'obs': 'पूंछ तेल में घुलती है',
        'learn': 'कार्बन श्रृंखला जलविरागी (पानी से नफरत) है।',
      },
      {
        'obs': 'गोलाकार गुच्छा (मिसेल)',
        'learn': 'पायस बनता है, जिससे गंदगी कपड़े से निकल जाती है।',
      },
      {
        'obs': 'सफेद अवक्षेप',
        'learn': 'Ca²⁺ आयन साबुन के साथ मिलकर अघुलनशील मैल बनाते हैं।',
      },
      {
        'obs': 'डिटर्जेंट झाग',
        'learn': 'सल्फोनेट लवण Ca²⁺ के साथ अवक्षेप नहीं बनाते।',
      },
    ],
    'buttons': {
      'testWater': 'पानी में टेस्ट करें',
      'testOil': 'तेल में टेस्ट करें',
      'reset': 'रीसेट करें',
      'addSoap': '+ साबुन का घोल डालें',
      'agitate': 'हिलाएं / रगड़ें',
      'soapA': '+ बीकर A में साबुन',
      'soapB': '+ बीकर B में साबुन',
      'soap': 'साबुन',
      'detergent': 'डिटर्जेंट',
      'add': 'डालें',
      'addTpl': '{x} डालें',
      'connect': 'पूंछ को सिर से जोड़ें',
    },
    'labels': {
      'head': 'सिर (Head)',
      'heads': 'सिर (Heads)',
      'hydrophilic': 'जलरागी (Hydrophilic)',
      'tail': 'जलविरागी पूंछ',
      'water': 'पानी',
      'oil': 'तेल',
      'immediateObs': 'तत्काल अवलोकन:',
      'obsWater':
          'जलरागी सिर पानी में घुल जाता है, जबकि जलविरागी पूंछ दूर रहती है।',
      'obsOil': 'जलविरागी पूंछ तेल में घुल जाती है, जबकि सिर दूर रहता है।',
      'waterMedium': 'पानी का माध्यम',
      'dirtyShirt': 'गंदा टी-शर्ट',
      'oilGrease': 'तेल / ग्रीस',
      'distilled': 'A: आसुत जल',
      'hardWater': 'B: कठोर जल',
      'massiveFoam': 'अत्यधिक झाग',
      'whiteScum': 'सफेद मैल (Scum)',
      'noFoam': 'कोई झाग नहीं',
      'hardEnv': 'कठोर जल (Ca²⁺)',
      'selectAgent': 'सफाई एजेंट चुनें:',
    },
    'toasts': {
      'zone1': 'पूंछ को खींचें। अणु बनाने के लिए इसे सिर से जोड़ें।',
      'zone2': 'साबुन डालें, फिर मिसेल बनाने के लिए कपड़े को रगड़ें।',
      'zone3':
          'कठोर जल के साथ प्रतिक्रिया देखने के लिए दोनों बीकर में साबुन डालें।',
      'zone4':
          'अब डिटर्जेंट का प्रयास करें। क्या यह साबुन की तरह मैल बनाता है?',
    },
    'popups': {
      'zone1': {
        'title': 'अवलोकन: साबुन की संरचना',
        'p1': 'सोडियम स्टीयरेट (साबुन का अणु):',
        'l1': 'आयनिक सिर (Na⁺): यह भाग जलरागी है (पानी को आकर्षित करता है)।',
        'l2':
            'कार्बन श्रृंखला पूंछ: यह भाग जलविरागी है (पानी को प्रतिकर्षित करता है)।',
        'conc':
            'निष्कर्ष: यह दोहरी प्रकृति साबुन को तेल और पानी के बीच पुल बनाने की अनुमति देती है।',
      },
      'zone2': {
        'title': 'अवलोकन: मिसेल निर्माण',
        'p1': 'सफाई की क्रियाविधि:',
        'l1': 'जलविरागी पूंछ तेल/गंदगी से चिपक जाती हैं।',
        'l2': 'जलरागी सिर बाहर पानी की ओर होते हैं।',
        'conc':
            "परिणाम: यह 'मिसेल' नामक एक गोलाकार संरचना बनाता है। गंदगी केंद्र में फंस जाती है और पानी के साथ बह जाती है।",
      },
      'zone3': {
        'title': 'अवलोकन: मैल (Scum) निर्माण',
        'p1': 'साबुन विफल क्यों हुआ?',
        'p2':
            "कठोर पानी में कैल्शियम (Ca²⁺) और मैग्नीशियम (Mg²⁺) आयन होते हैं। साबुन उनके साथ प्रतिक्रिया करके 'मैल' नामक अघुलनशील पदार्थ बनाता है।",
        'conc':
            'निष्कर्ष: कठोर पानी में साबुन बर्बाद हो जाता है और सफाई मुश्किल होती है।',
      },
      'zone4': {
        'title': 'अवलोकन: डिटर्जेंट क्रिया',
        'p1': 'डिटर्जेंट ने काम क्यों किया?',
        'p2':
            'डिटर्जेंट कार्बोक्सिलेट समूहों के बजाय अमोनियम या सल्फोनेट समूहों (-SO₃Na) का उपयोग करते हैं।',
        'conc':
            'परिणाम: ये आवेशित सिरे कैल्शियम आयनों के साथ अवक्षेप नहीं बनाते हैं। वे घुलनशील रहते हैं और कठोर पानी में भी झाग बनाते हैं।',
      },
    },
    'nav': {
      'construct': 'संरचना',
      'micelle': 'मिसेल',
      'hardwater': 'कठोर जल',
      'detergent': 'डिटर्जेंट',
    },
    'ui': {
      'observation': 'अवलोकन',
      'inference': 'निष्कर्ष',
      'labelsToggle': 'लेबल दिखाएँ / छिपाएँ',
      'missionDone': 'मिशन पूरा',
      'progress': 'पूरे किए गए मिशन',
    },
    'complete': {
      'title': 'सभी मिशन पूरे!',
      'msg':
          'आपने साबुन का अणु बनाया, तेल को मिसेल के अंदर फँसाया, कठोर जल में साबुन को मैल बनते देखा और डिटर्जेंट को काम करते देखा। इसी कारण कठोर जल में कपड़े धोने के लिए डिटर्जेंट का उपयोग किया जाता है।',
    },
  },
});

// --- SCENE CONSTANTS (source CONSTANTS, tuned for the dark lab) ---
const _oilColor = Color(0xFFD97706);
const _oilEdge = Color(0xFFB45309);
const _tailColor = Color(0xFFF59E0B);
const _calciumColor = Color(0xFFEF4444);
const _scumColor = Color(0xFFCBD5E1);
const _labelInk = Color(0xFF1E293B);
const _frameMs = 1000 / 60;

const _navKeys = ['construct', 'micelle', 'hardwater', 'detergent'];
const _navIcons = [Icons.build, Icons.water_drop, Icons.science, Icons.shield];
const _appIcons = [Icons.clean_hands, Icons.checkroom, Icons.waves];

// ---------------------------------------------------------------------------
// Particle simulations. Each runs one source `requestAnimationFrame` step per
// 1/60 s in a fixed virtual canvas; the painters scale that to fit.
// ---------------------------------------------------------------------------
class _Mol {
  _Mol(this.x, this.y, {this.vx = 0, this.vy = 0, this.angle = 0});
  double x, y, vx, vy, angle;
  bool active = true;
}

class _Blob {
  _Blob(this.x, this.y, this.r);
  double x, y;
  final double r;
}

/// Source `Zone2Micelles`.
class _MicelleSim {
  static const w = 520.0, h = 440.0;
  static const cx = w / 2, cy = h / 2;
  static const ring = 55.0;

  final List<_Mol> mols = [];
  bool soapAdded = false;
  bool success = false;
  double agitation = 0;
  double oilY = cy + 20;

  void reset() {
    mols.clear();
    soapAdded = false;
    success = false;
    agitation = 0;
    oilY = cy + 20;
  }

  void addSoap(math.Random rng) {
    soapAdded = true;
    if (mols.isNotEmpty) return;
    for (var i = 0; i < 60; i++) {
      mols.add(
        _Mol(
          rng.nextDouble() * w,
          rng.nextDouble() * h,
          vx: (rng.nextDouble() - 0.5) * 2,
          vy: (rng.nextDouble() - 0.5) * 2,
          angle: rng.nextDouble() * 6,
        ),
      );
    }
  }

  /// One frame. Returns true on the frame the micelle succeeds.
  bool step(math.Random rng) {
    if (success && oilY > 100) {
      oilY -= 1.5;
    } else if (!success) {
      oilY = cy + 20;
    }
    if (soapAdded) {
      for (final p in mols) {
        final dx = cx - p.x, dy = oilY - p.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        final a = math.atan2(dy, dx);
        if (agitation > 0) {
          p.vx += (rng.nextDouble() - 0.5) * agitation * 0.2;
          p.vy += (rng.nextDouble() - 0.5) * agitation * 0.2;
        }
        if (dist > ring) {
          p.vx += math.cos(a) * 0.1;
          p.vy += math.sin(a) * 0.1;
          p.angle += 0.05;
        } else {
          // Locked on the micelle: tail points into the oil, head outwards.
          p.angle = a + math.pi;
          p.vx = 0;
          p.vy = 0;
          p.x = cx - math.cos(a) * ring;
          p.y = oilY - math.sin(a) * ring;
        }
        p.x += p.vx;
        p.y += p.vy;
        p.vx *= 0.95;
        p.vy *= 0.95;
      }
    }
    if (!success && agitation > 5 && mols.length > 50) {
      success = true;
      return true;
    }
    return false;
  }
}

/// Source `Zone3HardWater`.
class _HardWaterSim {
  static const w = 480.0, h = 400.0;
  static const beakerW = 160.0, beakerH = 250.0;
  static const beakerY = h - beakerH - 50;
  static const xA = w * 0.25 - beakerW / 2;
  static const xB = w * 0.75 - beakerW / 2;
  static const liquidTop = beakerY + beakerH * 0.3;

  final List<_Mol> a = [], b = [], ions = [];
  final List<_Blob> scums = [];
  bool addedA = false, addedB = false;
  double time = 0;

  void reset(math.Random rng) {
    a.clear();
    b.clear();
    scums.clear();
    ions.clear();
    addedA = false;
    addedB = false;
    for (var i = 0; i < 20; i++) {
      ions.add(
        _Mol(
          xB + 20 + rng.nextDouble() * (beakerW - 40),
          beakerY + 100 + rng.nextDouble() * (beakerH - 120),
          vx: rng.nextDouble() - 0.5,
          vy: rng.nextDouble() - 0.5,
        ),
      );
    }
  }

  void addSoap(bool toA, math.Random rng) {
    final startX = toA ? w * 0.25 : w * 0.75;
    final list = toA ? a : b;
    for (var i = 0; i < 50; i++) {
      list.add(
        _Mol(
          startX + (rng.nextDouble() - 0.5) * 100,
          -20 - rng.nextDouble() * 100,
          vx: rng.nextDouble() - 0.5,
          vy: 2 + rng.nextDouble() * 3,
        ),
      );
    }
    if (toA) {
      addedA = true;
    } else {
      addedB = true;
    }
  }

  void step(math.Random rng) {
    for (final p in a) {
      p.y += p.vy;
      p.x += p.vx;
      if (p.y > liquidTop) {
        p.vy *= 0.9;
        if (p.vy < 0.1 && p.y < liquidTop + 20) p.vy = -0.5;
      }
      if (p.x < xA || p.x > xA + beakerW) p.vx *= -1;
      p.angle = rng.nextDouble() * 6; // dissolved soap tumbles freely
    }
    a.removeWhere((p) => p.y < -150); // bubbles that floated away
    for (final ion in ions) {
      ion.x += ion.vx;
      ion.y += ion.vy;
      if (ion.x < xB + 10 || ion.x > xB + beakerW - 10) ion.vx *= -1;
      if (ion.y < liquidTop || ion.y > beakerY + beakerH - 10) ion.vy *= -1;
    }
    for (final p in b) {
      if (!p.active) continue;
      p.y += p.vy;
      if (p.y > liquidTop) {
        p.vy *= 0.9;
        for (final ion in ions) {
          final dx = p.x - ion.x, dy = p.y - ion.y;
          if (math.sqrt(dx * dx + dy * dy) < 30) {
            p.active = false;
            scums.add(_Blob(p.x, p.y, 8));
            break;
          }
        }
      }
    }
    for (final s in scums) {
      s.y -= 0.5;
      if (s.y < liquidTop + 10) s.y = liquidTop + 10;
    }
  }
}

/// Source `Zone4Detergent`.
class _DetergentSim {
  static const w = 520.0, h = 440.0;
  static const cx = w / 2;
  static const ring = 35.0;

  String mode = 'soap';
  bool added = false;
  double oilY = h / 2 + 20;
  final List<_Mol> mols = [], ions = [];
  final List<_Blob> scums = [];

  bool get isDetergent => mode == 'detergent';

  void reset(math.Random rng) {
    mode = 'soap';
    added = false;
    oilY = h / 2 + 20;
    mols.clear();
    scums.clear();
    ions.clear();
    for (var i = 0; i < 25; i++) {
      ions.add(
        _Mol(
          rng.nextDouble() * w,
          rng.nextDouble() * h,
          vx: rng.nextDouble() - 0.5,
          vy: rng.nextDouble() - 0.5,
        ),
      );
    }
  }

  void setMode(String m) {
    mode = m;
    added = false;
    mols.clear();
    scums.clear();
  }

  void add(math.Random rng) {
    added = true;
    mols.clear();
    scums.clear();
    for (var i = 0; i < 60; i++) {
      mols.add(
        _Mol(
          rng.nextDouble() * w,
          -20 - rng.nextDouble() * 100,
          vx: (rng.nextDouble() - 0.5) * 2,
          vy: 2 + rng.nextDouble() * 2,
          angle: rng.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void step() {
    if (isDetergent && added && oilY > 100) {
      oilY -= 1.5;
    } else if (!added) {
      oilY = h / 2 + 20;
    }
    for (final ion in ions) {
      ion.x += ion.vx;
      ion.y += ion.vy;
      if (ion.x < 0 || ion.x > w) ion.vx *= -1;
      if (ion.y < 0 || ion.y > h) ion.vy *= -1;
    }
    for (final p in mols) {
      if (!p.active) continue;
      p.x += p.vx;
      p.y += p.vy;
      if (!isDetergent) {
        for (final ion in ions) {
          final dx = p.x - ion.x, dy = p.y - ion.y;
          if (math.sqrt(dx * dx + dy * dy) < 20) {
            p.active = false;
            scums.add(_Blob(p.x, p.y, 6));
            break;
          }
        }
      } else {
        final dx = cx - p.x, dy = oilY - p.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        final a = math.atan2(dy, dx);
        if (dist < ring) {
          p.vx = 0;
          p.vy = 0;
          p.angle = a + math.pi;
          p.x = cx - math.cos(a) * ring;
          p.y = oilY - math.sin(a) * ring;
        } else if (dist < 150) {
          p.vx += math.cos(a) * 0.5;
          p.vy += math.sin(a) * 0.5;
          p.vx *= 0.9;
          p.vy *= 0.9;
        }
      }
    }
    for (final s in scums) {
      s.y -= 0.5;
    }
    mols.removeWhere((p) => !p.active || p.y > h + 60);
    scums.removeWhere((s) => s.y < -20);
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class Cl10SCh04A4SoapandMicellePlantPage extends StatefulWidget {
  const Cl10SCh04A4SoapandMicellePlantPage({super.key});

  @override
  State<Cl10SCh04A4SoapandMicellePlantPage> createState() =>
      _Cl10SCh04A4SoapandMicellePlantPageState();
}

class _Cl10SCh04A4SoapandMicellePlantPageState
    extends State<Cl10SCh04A4SoapandMicellePlantPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  // Source ToolsPanel: zoom 0.5 .. 2.
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.5,
    max: 2.0,
    step: 1.2,
  );
  final math.Random _rng = math.Random(44);
  final ValueNotifier<int> _frame = ValueNotifier(0);

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _acc = 0;

  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);

  int _zone = 0;
  final Set<int> _completed = {};
  bool _labels = true;
  bool _toastVisible = true;
  bool _popupOpen = false;
  Timer? _popupTimer;
  Timer? _scumTimer;

  // Zone 1: structure builder.
  bool _assembled = false;
  Offset? _tailAnchor; // right-hand (joining) end of the tail, scene px
  String? _testState; // 'water' | 'oil'

  // Zones 2-4.
  final _MicelleSim _micelle = _MicelleSim();
  final _HardWaterSim _hard = _HardWaterSim();
  final _DetergentSim _det = _DetergentSim();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _hard.reset(_rng);
    _det.reset(_rng);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _popupTimer?.cancel();
    _scumTimer?.cancel();
    _ticker.dispose();
    _bounce.dispose();
    _frame.dispose();
    _zoom.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation ---
  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1000.0;
    _lastTick = elapsed;
    _hard.time = elapsed.inMicroseconds / 1e6;
    _acc += dt;
    var n = 0;
    while (_acc >= _frameMs && n < 4) {
      _stepZone();
      _acc -= _frameMs;
      n++;
    }
    if (n == 4) _acc = 0;
    if (n > 0) _frame.value++;
  }

  void _stepZone() {
    switch (_zone) {
      case 1:
        if (_micelle.step(_rng)) _onMicelleFormed();
      case 2:
        _hard.step(_rng);
      case 3:
        _det.step();
    }
  }

  // ------------------------------------------------------------- helpers ---
  void _cancelTimers() {
    _popupTimer?.cancel();
    _scumTimer?.cancel();
    _popupTimer = null;
    _scumTimer = null;
  }

  /// Fresh state for [zone] (the source remounts a zone on every visit).
  void _resetZone(int zone) {
    switch (zone) {
      case 0:
        _assembled = false;
        _tailAnchor = null;
        _testState = null;
      case 1:
        _micelle.reset();
      case 2:
        _hard.reset(_rng);
      default:
        _det.reset(_rng);
    }
  }

  void _setZone(int zone) {
    if (zone == _zone) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    _rt_playSfx(_rt_Sfx.scenario);
    _cancelTimers();
    setState(() {
      _zone = zone;
      _toastVisible = true;
      _resetZone(zone);
    });
  }

  void _restart() {
    _cancelTimers();
    _zoom.reset();
    setState(() {
      _zone = 0;
      _completed.clear();
      _labels = true;
      _toastVisible = true;
      for (var z = 0; z < 4; z++) {
        _resetZone(z);
      }
    });
  }

  void _schedulePopup(int zone, int ms) {
    _popupTimer?.cancel();
    _popupTimer = Timer(
      Duration(milliseconds: ms),
      () => _showObservation(zone),
    );
  }

  Future<void> _showObservation(int zone) async {
    if (!mounted || _zone != zone || _popupOpen) return;
    _popupOpen = true;
    _rt_playSfx(_rt_Sfx.magic);
    await _rt_showShellPopup(
      context,
      title: _tx.s('popups.zone${zone + 1}.title'),
      icon: Icons.biotech,
      color: _rt_Tw.blue600,
      body: _rt_LangBuilder(builder: (_, _) => _popupBody(zone)),
    );
    _popupOpen = false;
    if (!mounted) return;
    _completeMission(zone);
  }

  void _completeMission(int zone) {
    if (_completed.contains(zone)) return;
    setState(() => _completed.add(zone));
    if (_completed.length == 4) {
      _shell.showSuccess(
        title: _tx.s('complete.title'),
        message: _tx.s('complete.msg'),
        color: _rt_Tw.green600,
      );
    } else {
      _rt_playSfx(_rt_Sfx.correct);
      _shell.showToast(
        '${_tx.s('ui.missionDone')}: ${_tx.s('missions.$zone.task')}',
        icon: Icons.task_alt,
      );
    }
  }

  // -------------------------------------------------- zone 1: structure ---
  Offset _defaultAnchor(double w, double h) =>
      Offset(math.max(140.0, w * 0.5 - 140), math.max(60.0, h * 0.5 - 90));

  void _dragTail(Offset delta, double w, double h) {
    if (_assembled) return;
    final cur = _tailAnchor ?? _defaultAnchor(w, h);
    final next = Offset(
      (cur.dx + delta.dx).clamp(40.0, w + 90),
      (cur.dy + delta.dy).clamp(0.0, h),
    );
    setState(() => _tailAnchor = next);
    // Source: the joining end must come within 40 px of the head's centre.
    if ((next - Offset(w / 2, h / 2)).distance < 40) _assemble();
  }

  void _assemble() {
    if (_assembled) return;
    setState(() {
      _assembled = true;
      _tailAnchor = null;
    });
    _rt_playSfx(_rt_Sfx.success);
  }

  void _runTest(String kind) {
    setState(() => _testState = kind);
    // Source: only the oil test raises the structure observation, 4 s later.
    if (kind == 'oil') _schedulePopup(0, 4000);
  }

  // ---------------------------------------------------- zone 2: micelle ---
  void _addSoapToCloth() => setState(() => _micelle.addSoap(_rng));

  void _onMicelleFormed() {
    setState(() {});
    _rt_playSfx(_rt_Sfx.success);
    _schedulePopup(1, 3000);
  }

  // ------------------------------------------------- zone 3: hard water ---
  void _addSoapToBeaker(bool toA) {
    setState(() => _hard.addSoap(toA, _rng));
    if (toA) return;
    _scumTimer?.cancel();
    _scumTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted || _zone != 2) return;
      _rt_playSfx(_rt_Sfx.wrong); // source playSound('scum')
      _schedulePopup(2, 2500);
    });
  }

  // -------------------------------------------------- zone 4: detergent ---
  void _setAgent(String mode) {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _det.setMode(mode));
  }

  void _addAgent() {
    setState(() => _det.add(_rng));
    if (_det.isDetergent) {
      _rt_playSfx(_rt_Sfx.success);
      _schedulePopup(3, 1500);
    } else {
      _rt_playSfx(_rt_Sfx.wrong); // source playSound('scum')
    }
  }

  // ------------------------------------------------------------------ UI ---
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
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.blue600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
              headerSubtitleColor: Color(0xFFBFDBFE),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              footnote: [for (final k in _navKeys) _tx.s('nav.$k')].join(' • '),
              icon: Icons.soap,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [_labelsToggle()],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.rocket_launch,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _rt_MinWidthGate(child: _canvas()), // QA C10-4.4-20
          );
        },
      ),
    );
  }

  Widget _labelsToggle() {
    return Tooltip(
      message: _tx.s('ui.labelsToggle'),
      child: InkResponse(
        key: const ValueKey('labelsToggle'),
        radius: 22,
        onTap: () {
          _rt_playSfx(_rt_Sfx.toggle);
          setState(() => _labels = !_labels);
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _labels ? _rt_Tw.blue600 : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _labels ? Icons.label : Icons.label_off,
            size: 18,
            color: _labels ? Colors.white : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _canvas() {
    return Column(
      children: [
        _navBar(),
        Expanded(
          child: Padding(
            // Right gutter keeps the scene clear of the shell's toolbar.
            padding: const EdgeInsets.fromLTRB(8, 0, 58, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 178, child: _panel()),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _rt_ZoomableCanvas(
                      controller: _zoom,
                      child: _scene(),
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

  /// Source bottom navigation (Structure / Micelle / Hard Water / Detergent).
  Widget _navBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 16, 72, 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [for (var i = 0; i < 4; i++) _navChip(i)],
      ),
    );
  }

  Widget _navChip(int i) {
    final on = _zone == i;
    final done = _completed.contains(i);
    return GestureDetector(
      key: ValueKey('nav-$i'),
      onTap: () => _setZone(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.blue600 : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? _rt_Tw.blue600 : _rt_Lab.border,
            width: 1.5,
          ),
          boxShadow: on
              ? [
                  BoxShadow(
                    color: _rt_Tw.blue600.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              done ? Icons.check_circle : _navIcons[i],
              size: 14,
              color: on
                  ? Colors.white
                  : (done ? _rt_Tw.green500 : _rt_Lab.textMuted),
            ),
            const SizedBox(width: 6),
            Text(
              _tx.s('nav.${_navKeys[i]}'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: on ? Colors.white : _rt_Lab.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------- control panel ---
  Widget _panel() {
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _rt_SectionLabel(
              '${_zone + 1}. ${_tx.s('missions.$_zone.task')}',
              color: _rt_Tw.blue400,
              icon: _navIcons[_zone],
            ),
            if (_toastVisible) _toastCard(_tx.s('toasts.zone${_zone + 1}')),
            ...switch (_zone) {
              0 => _structureControls(),
              1 => _micelleControls(),
              2 => _hardWaterControls(),
              _ => _detergentControls(),
            },
            if (_completed.contains(_zone)) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: _rt_Tw.green500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _tx.s('ui.missionDone'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.onTinted(
                          _rt_Tw.green400,
                          _rt_Tw.green700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Source `Toast`: the zone instruction, closable.
  Widget _toastCard(String message) {
    return Container(
      key: const ValueKey('zoneToast'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue500)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: _rt_Tw.blue500,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _rt_Lab.text,
                height: 1.3,
              ),
            ),
          ),
          InkResponse(
            key: const ValueKey('toastClose'),
            radius: 14,
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() => _toastVisible = false);
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 16, color: _rt_Lab.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _structureControls() => [
    _rt_ActionButton(
      key: const ValueKey('connectBtn'),
      label: _tx.s('buttons.connect'),
      icon: Icons.link,
      color: _rt_Tw.amber600,
      expand: true,
      sound: null, // _assemble plays the source's success chime
      done: _assembled,
      onPressed: _assemble,
    ),
  ];

  List<Widget> _micelleControls() => [
    _rt_ActionButton(
      label: _tx.s('buttons.addSoap'),
      icon: Icons.water_drop,
      color: _rt_Tw.green600,
      expand: true,
      sound: _rt_Sfx.pop, // source playSound('splash')
      onPressed: _micelle.soapAdded ? null : _addSoapToCloth,
    ),
    const SizedBox(height: 12),
    Opacity(
      opacity: _micelle.soapAdded ? 1 : 0.5,
      child: _rt_LabeledSlider(
        label: _tx.s('buttons.agitate'),
        value: _micelle.agitation,
        min: 0,
        max: 10,
        divisions: 10,
        valueText: '${_micelle.agitation.round()}',
        color: _rt_Tw.blue500,
        onChanged: (v) => setState(() => _micelle.agitation = v),
      ),
    ),
  ];

  List<Widget> _hardWaterControls() => [
    _rt_ActionButton(
      label: _tx.s('buttons.soapA'),
      icon: Icons.water_drop,
      color: _rt_Tw.green600,
      expand: true,
      sound: _rt_Sfx.pop, // source playSound('splash')
      onPressed: _hard.addedA ? null : () => _addSoapToBeaker(true),
    ),
    const SizedBox(height: 8),
    _rt_ActionButton(
      label: _tx.s('buttons.soapB'),
      icon: Icons.water_drop,
      color: _rt_Tw.green600,
      expand: true,
      sound: _rt_Sfx.pop,
      onPressed: _hard.addedB ? null : () => _addSoapToBeaker(false),
    ),
  ];

  List<Widget> _detergentControls() {
    Widget chip(String mode, Color accent, Color light) {
      final on = _det.mode == mode;
      return Expanded(
        child: GestureDetector(
          key: ValueKey('agent-$mode'),
          onTap: () => _setAgent(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? _rt_Lab.tinted(light, accent) : _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: on ? accent : _rt_Lab.border,
                width: on ? 2 : 1,
              ),
            ),
            child: Text(
              _tx.s('buttons.$mode'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: on ? FontWeight.w900 : FontWeight.w600,
                color: on
                    ? _rt_Lab.onTinted(accent, accent)
                    : _rt_Lab.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    return [
      Text(
        _tx.s('labels.selectAgent'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _rt_Lab.text,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          chip('soap', _rt_Tw.red500, _rt_Tw.red100),
          const SizedBox(width: 6),
          chip('detergent', _rt_Tw.blue500, _rt_Tw.blue100),
        ],
      ),
      const SizedBox(height: 10),
      _rt_ActionButton(
        key: const ValueKey('addAgent'),
        label: _tx
            .s('buttons.addTpl')
            .replaceAll('{x}', _tx.s('buttons.${_det.mode}')),
        icon: Icons.water_drop,
        color: _rt_Tw.green600,
        expand: true,
        sound: _rt_Sfx.pop, // source playSound('splash')
        onPressed: _addAgent,
      ),
    ];
  }

  // ---------------------------------------------------------------- scene ---
  Widget _scene() {
    Widget paint(CustomPainter p) => RepaintBoundary(
      child: SizedBox.expand(child: CustomPaint(painter: p)),
    );
    switch (_zone) {
      case 0:
        return _structureScene();
      case 1:
        return paint(
          _MicellePainter(
            sim: _micelle,
            showLabels: _labels,
            waterLabel: _tx.s('labels.waterMedium'),
            shirtLabel: _tx.s('labels.dirtyShirt'),
            oilLabel: _tx.s('labels.oilGrease'),
            repaint: _frame,
          ),
        );
      case 2:
        return paint(
          _HardWaterPainter(
            sim: _hard,
            showLabels: _labels,
            labelA: _tx.s('labels.distilled'),
            labelB: _tx.s('labels.hardWater'),
            foamLabel: _tx.s('labels.massiveFoam'),
            scumLabel: _tx.s('labels.whiteScum'),
            noFoamLabel: _tx.s('labels.noFoam'),
            repaint: _frame,
          ),
        );
      default:
        return paint(
          _DetergentPainter(
            sim: _det,
            showLabels: _labels,
            envLabel: _tx.s('labels.hardEnv'),
            repaint: _frame,
          ),
        );
    }
  }

  /// Source `Zone1Builder` (DOM): head in the middle, draggable tail, then the
  /// water / oil solubility test.
  Widget _structureScene() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        return Container(
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
            border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue500)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _testState == null ? _builderStage(w, h) : _testStage(w, h),
        );
      },
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(6),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
    ),
  );

  Widget _builderStage(double w, double h) {
    final c = Offset(w / 2, h / 2);
    final anchor = _assembled ? c : (_tailAnchor ?? _defaultAnchor(w, h));
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Hydrophobic carbon-chain tail; its right-hand end joins the head.
        Positioned(
          left: anchor.dx - 132,
          top: anchor.dy - 36,
          child: GestureDetector(
            key: const ValueKey('soapTail'),
            behavior: HitTestBehavior.opaque,
            // Count the touch slop too, so the tail tracks the finger 1:1.
            dragStartBehavior: DragStartBehavior.down,
            onPanStart: _assembled ? null : (_) => _rt_playSfx(_rt_Sfx.tap),
            onPanUpdate: _assembled ? null : (d) => _dragTail(d.delta, w, h),
            child: const SizedBox(
              width: 132,
              height: 72,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CustomPaint(painter: _TailPainter()),
              ),
            ),
          ),
        ),
        if (!_assembled && _labels)
          Positioned(
            left: math.max(4.0, anchor.dx - 128),
            top: anchor.dy + 20,
            child: IgnorePointer(
              child: _pill(_tx.s('labels.tail'), const Color(0xFFA16207)),
            ),
          ),
        // Hydrophilic ionic head (Na⁺).
        Positioned(
          left: c.dx - 32,
          top: c.dy - 32,
          child: IgnorePointer(
            child: Container(
              key: const ValueKey('soapHead'),
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_rt_Tw.blue400, _rt_Tw.blue700],
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Na⁺',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
        if (_labels)
          Positioned(
            left: 0,
            right: 0,
            top: c.dy + 40,
            child: IgnorePointer(
              child: Center(
                child: _pill(_tx.s('labels.hydrophilic'), _rt_Tw.blue800),
              ),
            ),
          ),
        if (_assembled)
          Positioned(
            left: 8,
            right: 8,
            top: c.dy + 74,
            child: AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -6 * Curves.easeOut.transform(_bounce.value)),
                child: child,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  _rt_ActionButton(
                    key: const ValueKey('testWater'),
                    label: _tx.s('buttons.testWater'),
                    icon: Icons.water_drop,
                    color: _rt_Tw.green600,
                    sound: _rt_Sfx.pop,
                    onPressed: () => _runTest('water'),
                  ),
                  _rt_ActionButton(
                    key: const ValueKey('testOil'),
                    label: _tx.s('buttons.testOil'),
                    icon: Icons.opacity,
                    color: _rt_Tw.green600,
                    sound: _rt_Sfx.pop,
                    onPressed: () => _runTest('oil'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _testStage(double w, double h) {
    final water = _testState == 'water';
    final box = math.min(200.0, math.min(w - 32, h - 150)).clamp(110.0, 200.0);
    final boxView = TweenAnimationBuilder<double>(
      key: ValueKey(_testState),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, p, _) => CustomPaint(
        size: Size(box, box),
        painter: _TestBoxPainter(
          water: water,
          progress: p,
          mediumLabel: _tx.s(water ? 'labels.water' : 'labels.oil'),
        ),
      ),
    );
    final info = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500),
            borderRadius: BorderRadius.circular(6),
            border: const Border(
              left: BorderSide(color: _rt_Tw.amber400, width: 4),
            ),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_tx.s('labels.immediateObs')} ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: _tx.s(water ? 'labels.obsWater' : 'labels.obsOil'),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: _rt_Lab.onTinted(_rt_Tw.amber400, const Color(0xFF854D0E)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          key: const ValueKey('resetTest'),
          onPressed: () {
            _rt_playSfx(_rt_Sfx.tap);
            setState(() => _testState = null);
          },
          child: Text(
            _tx.s('buttons.reset'),
            style: const TextStyle(
              color: _rt_Tw.blue400,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationColor: _rt_Tw.blue400,
            ),
          ),
        ),
      ],
    );
    if (w >= 540) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            boxView,
            const SizedBox(width: 18),
            SizedBox(width: math.min(280.0, w - box - 60), child: info),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          boxView,
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: info,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- popups ---
  Widget _popupBody(int zone) {
    final k = 'popups.zone${zone + 1}';
    final base = TextStyle(fontSize: 13, color: _rt_Lab.text, height: 1.4);
    Widget p(String text, {bool bold = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: bold ? base.copyWith(fontWeight: FontWeight.w900) : base,
      ),
    );
    Widget bullet(String head, String text) => Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: base),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: head,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: ' $text'),
                ],
              ),
              style: base.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
    Widget conclusion(Color c, Color light) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(light, c),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rt_Lab.tintedBorder(c)),
      ),
      child: Text(
        _tx.s('$k.conc'),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1.35,
          color: _rt_Lab.onTinted(c, Color.lerp(c, Colors.black, 0.25)!),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: switch (zone) {
        0 => [
          p(_tx.s('$k.p1'), bold: true),
          bullet('${_tx.s('labels.head')}:', _tx.s('$k.l1')),
          bullet('${_tx.s('labels.tail')}:', _tx.s('$k.l2')),
          conclusion(_rt_Tw.blue600, _rt_Tw.blue50),
        ],
        1 => [
          p(_tx.s('$k.p1'), bold: true),
          bullet(_tx.s('labels.tail'), _tx.s('$k.l1')),
          bullet(_tx.s('labels.heads'), _tx.s('$k.l2')),
          conclusion(_rt_Tw.green600, _rt_Tw.green50),
        ],
        2 => [
          p(_tx.s('$k.p1'), bold: true),
          p(_tx.s('$k.p2')),
          conclusion(_rt_Tw.red600, _rt_Tw.red50),
        ],
        _ => [
          p(_tx.s('$k.p1'), bold: true),
          p(_tx.s('$k.p2')),
          conclusion(_rt_Tw.green600, _rt_Tw.green50),
        ],
      },
    );
  }

  // -------------------------------------------------------------- sidebar ---
  Widget _sidebar() {
    final apps = _tx.list('apps');
    final phases = _tx.list('phases');
    final rows = _tx.list('analysisData');
    final heading = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w900,
      color: _rt_Lab.text,
    );
    final body = TextStyle(fontSize: 12, color: _rt_Lab.textMuted, height: 1.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionTitle'),
          desc: _tx.s('missionObj'),
          accent: _rt_Tw.blue600,
          icon: Icons.rocket_launch,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.checklist),
              for (var i = 0; i < 4; i++) _missionRow(i),
              const SizedBox(height: 4),
              _progressBar(),
              const SizedBox(height: 18),

              // Relevance (source "context" tab).
              _rt_SectionLabel(
                _tx.s('tabs.context'),
                icon: Icons.lightbulb_outline,
              ),
              Text(_tx.s('contextTitle'), style: heading),
              const SizedBox(height: 4),
              Text(_tx.s('contextDesc'), style: body),
              const SizedBox(height: 10),
              for (var i = 0; i < apps.length; i++)
                _appCard(apps[i] as Map, _appIcons[i]),
              const SizedBox(height: 14),

              // Teacher's guide (source "guide" tab).
              _rt_SectionLabel(_tx.s('tabs.guide'), icon: Icons.co_present),
              Text(_tx.s('guideTitle'), style: heading),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500),
                  border: const Border(
                    left: BorderSide(color: _rt_Tw.amber400, width: 4),
                  ),
                ),
                child: Text(
                  _tx.s('guideContext'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _rt_Lab.onTinted(_rt_Tw.amber400, _rt_Tw.amber700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final ph in phases) _phaseRow(ph as Map),
              const SizedBox(height: 14),

              // Outcomes (source "analysis" tab).
              _rt_SectionLabel(
                _tx.s('tabs.analysis'),
                icon: Icons.pie_chart_outline,
              ),
              Text(_tx.s('outcomesTitle'), style: heading),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _rt_Lab.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rt_Lab.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1.25),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: _rt_Lab.border),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: _rt_Lab.overlay),
                      children: [
                        _cell(_tx.s('ui.observation'), bold: true),
                        _cell(_tx.s('ui.inference'), bold: true),
                      ],
                    ),
                    for (final r in rows)
                      TableRow(
                        children: [
                          _cell((r as Map)['obs'] as String, strong: true),
                          _cell(r['learn'] as String),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, {bool bold = false, bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: bold ? 11 : 11.5,
            fontWeight: bold
                ? FontWeight.w900
                : (strong ? FontWeight.w700 : FontWeight.w500),
            color: bold || strong ? _rt_Lab.text : _rt_Lab.textMuted,
            height: 1.3,
          ),
        ),
      );

  Widget _missionRow(int i) {
    final m = _tx.list('missions')[i] as Map;
    final done = _completed.contains(i);
    final active = _zone == i;
    return GestureDetector(
      key: ValueKey('mission-$i'),
      onTap: () => _setZone(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: done
              ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
              : (active
                    ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
                    : _rt_Lab.surface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: done
                ? _rt_Lab.tintedBorder(_rt_Tw.green500)
                : (active ? _rt_Tw.blue500 : _rt_Lab.border),
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? _rt_Tw.green500 : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: done ? _rt_Tw.green500 : _rt_Lab.borderStrong,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m['task'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: done
                          ? _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)
                          : _rt_Lab.text,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: _rt_Tw.green500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m['hint'] as String,
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
    );
  }

  Widget _progressBar() {
    final n = _completed.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _tx.s('ui.progress'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.textMuted,
                ),
              ),
            ),
            Text(
              '$n / 4',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _rt_Tw.green500,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: n / 4,
            minHeight: 6,
            backgroundColor: _rt_Lab.overlay,
            color: _rt_Tw.green500,
          ),
        ),
      ],
    );
  }

  Widget _appCard(Map app, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  app['desc'] as String,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _rt_Lab.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseRow(Map ph) {
    return Container(
      margin: const EdgeInsets.only(left: 6, bottom: 2),
      padding: const EdgeInsets.fromLTRB(14, 0, 0, 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _rt_Lab.border, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _rt_Tw.blue500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ph['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            ph['desc'] as String,
            style: TextStyle(
              fontSize: 11.5,
              color: _rt_Lab.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drawing helpers (source DRAWING FUNCTIONS)
// ---------------------------------------------------------------------------

/// Source `drawSoapMolecule`: zig-zag hydrocarbon tail + ionic head.
void _drawMolecule(
  Canvas canvas,
  double x,
  double y,
  double angle, {
  bool detergent = false,
  double scale = 1,
}) {
  canvas.save();
  canvas.translate(x, y);
  canvas.rotate(angle);
  canvas.scale(scale);
  final tail = Path()
    ..moveTo(0, 0)
    ..lineTo(-5, 3)
    ..lineTo(-10, -3)
    ..lineTo(-15, 3)
    ..lineTo(-20, 0);
  canvas.drawPath(
    tail,
    Paint()
      ..color = detergent ? _rt_Tw.violet500 : _tailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  final colors = detergent
      ? const [Color(0xFFC4B5FD), Color(0xFF7C3AED)]
      : const [Color(0xFF60A5FA), Color(0xFF1D4ED8)];
  canvas.drawCircle(
    Offset.zero,
    5,
    Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: const [0.17, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 6)),
  );
  canvas.drawCircle(
    Offset.zero,
    5,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
  canvas.restore();
}

/// Fixed stains (the source re-randomised them every frame, which flickered).
const _stains = [
  (Offset(-30, 12), 7.0),
  (Offset(24, 42), 9.0),
  (Offset(-8, -16), 6.0),
  (Offset(42, 2), 8.0),
  (Offset(-44, 56), 10.0),
];

/// Source `drawShirt`.
void _drawShirt(Canvas canvas, double x, double y, double scale) {
  canvas.save();
  canvas.translate(x, y);
  canvas.scale(scale);
  final path = Path()
    ..moveTo(0, -60)
    ..quadraticBezierTo(20, -50, 45, -65)
    ..lineTo(90, -45)
    ..lineTo(110, -10)
    ..lineTo(80, 10)
    ..lineTo(80, 110)
    ..lineTo(-80, 110)
    ..lineTo(-80, 10)
    ..lineTo(-110, -10)
    ..lineTo(-90, -45)
    ..lineTo(-45, -65)
    ..quadraticBezierTo(-20, -50, 0, -60)
    ..close();
  canvas.drawPath(path, Paint()..color = const Color(0xFFFBCFE8));
  canvas.drawPath(
    path,
    Paint()
      ..color = const Color(0xFFDB2777)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round,
  );
  final stain = Paint()
    ..color = const Color(0xFFB45309).withValues(alpha: 0.18);
  for (final (o, r) in _stains) {
    canvas.drawCircle(o, r, stain);
  }
  canvas.restore();
}

/// Source `drawHandkerchief`.
void _drawHandkerchief(Canvas canvas, double x, double y, double scale) {
  canvas.save();
  canvas.translate(x, y);
  canvas.scale(scale);
  final path = Path()
    ..moveTo(0, -70)
    ..lineTo(70, 0)
    ..lineTo(0, 70)
    ..lineTo(-70, 0)
    ..close();
  canvas.drawPath(path, Paint()..color = const Color(0xFFE2E8F0));
  canvas.drawPath(
    path,
    Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  final fold = Paint()
    ..color = Colors.black.withValues(alpha: 0.1)
    ..strokeWidth = 2;
  canvas.drawLine(const Offset(-70, 0), const Offset(70, 0), fold);
  canvas.drawLine(const Offset(0, -70), const Offset(0, 70), fold);
  final weave = TextPainter(
    text: TextSpan(
      text: '///',
      style: TextStyle(
        fontSize: 10,
        color: const Color(0xFF64748B).withValues(alpha: 0.35),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  weave.paint(canvas, Offset(30 - weave.width / 2, 30 - weave.height));
  weave.paint(canvas, Offset(-30 - weave.width / 2, -30 - weave.height));
  canvas.restore();
}

/// Source `drawBeaker` (glass outline + liquid at [level]).
void _drawBeaker(
  Canvas canvas,
  double x,
  double y,
  double w,
  double h,
  double level,
) {
  final glass = Paint()
    ..color = _rt_Tw.slate400
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  final liquidY = y + h - h * level;
  final liquid = Path()
    ..moveTo(x + 2, liquidY)
    ..lineTo(x + 2, y + h - 20)
    ..quadraticBezierTo(x + 2, y + h - 2, x + 20, y + h - 2)
    ..lineTo(x + w - 20, y + h - 2)
    ..quadraticBezierTo(x + w - 2, y + h - 2, x + w - 2, y + h - 20)
    ..lineTo(x + w - 2, liquidY)
    ..close();
  final waterPaint = Paint()..color = const Color(0x7338BDF8);
  canvas.drawPath(liquid, waterPaint);
  final surface = Rect.fromCenter(
    center: Offset(x + w / 2, liquidY),
    width: w - 4,
    height: 16,
  );
  canvas.drawOval(surface, waterPaint);
  canvas.drawOval(
    surface,
    Paint()..color = Colors.white.withValues(alpha: 0.3),
  );
  // Glass drawn last so the rim stays crisp over the liquid.
  canvas.drawOval(
    Rect.fromCenter(center: Offset(x + w / 2, y), width: w, height: 20),
    glass,
  );
  final body = Path()
    ..moveTo(x, y)
    ..lineTo(x, y + h - 20)
    ..quadraticBezierTo(x, y + h, x + 20, y + h)
    ..lineTo(x + w - 20, y + h)
    ..quadraticBezierTo(x + w, y + h, x + w, y + h - 20)
    ..lineTo(x + w, y);
  canvas.drawPath(body, glass);
}

/// Source `drawLabel`: a white rounded tag, drawn at screen size so it stays
/// readable however small the scene is scaled. [left] anchors its left edge.
void _drawPill(
  Canvas canvas,
  Size bounds,
  String text,
  Offset at, {
  Color color = _labelInk,
  bool left = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout(maxWidth: math.max(40.0, bounds.width - 16));
  final w = tp.width + 12, h = tp.height + 8;
  var cx = left ? at.dx + w / 2 : at.dx;
  cx = cx
      .clamp(w / 2 + 4, math.max(w / 2 + 4, bounds.width - w / 2 - 4))
      .toDouble();
  final cy = at.dy
      .clamp(h / 2 + 4, math.max(h / 2 + 4, bounds.height - h / 2 - 4))
      .toDouble();
  final r = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
    const Radius.circular(6),
  );
  canvas.drawRRect(
    r.shift(const Offset(0, 1)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  canvas.drawRRect(r, Paint()..color = Colors.white.withValues(alpha: 0.92));
  tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
}

/// Calcium ions: red dots tagged "Ca" (source: r=4 dot + 8px white text),
/// drawn at screen size so the tag stays legible when the scene is scaled.
void _drawIons(
  Canvas canvas,
  List<_Mol> ions,
  Offset Function(double, double) scr,
) {
  final dot = Paint()..color = _calciumColor;
  final rim = Paint()
    ..color = Colors.white.withValues(alpha: 0.75)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final ca = TextPainter(
    text: const TextSpan(
      text: 'Ca',
      style: TextStyle(
        fontSize: 7,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  for (final i in ions) {
    final p = scr(i.x, i.y);
    canvas.drawCircle(p, 6.5, dot);
    canvas.drawCircle(p, 6.5, rim);
    ca.paint(canvas, p - Offset(ca.width / 2, ca.height / 2));
  }
}

/// Fits a virtual [vw] x [vh] canvas into [size]: returns (scale, offset).
(double, Offset) _fit(Size size, double vw, double vh) {
  final s = math.min(size.width / vw, size.height / vh);
  return (s, Offset((size.width - vw * s) / 2, (size.height - vh * s) / 2));
}

class _TailPainter extends CustomPainter {
  const _TailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Source SVG path in a 100 x 40 box.
    final path = Path()
      ..moveTo(95, 20)
      ..lineTo(85, 10)
      ..lineTo(75, 30)
      ..lineTo(65, 10)
      ..lineTo(55, 30)
      ..lineTo(45, 10)
      ..lineTo(35, 30)
      ..lineTo(25, 10)
      ..lineTo(15, 30)
      ..lineTo(5, 20);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      stroke
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      path,
      stroke
        ..maskFilter = null
        ..color = _tailColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Zone 1 solubility test: half water (or oil) box with the molecule turning
/// head-down into water / tail-down into oil.
class _TestBoxPainter extends CustomPainter {
  _TestBoxPainter({
    required this.water,
    required this.progress,
    required this.mediumLabel,
  });

  final bool water;
  final double progress;
  final String mediumLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 256;
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.save();
    canvas.clipRRect(r);
    final half = size.height / 2;
    canvas.drawRect(
      Rect.fromLTWH(0, half, size.width, half),
      Paint()
        ..color = water ? const Color(0xFFBFDBFE) : const Color(0xFFFEF3C7),
    );
    canvas.drawLine(
      Offset(0, half),
      Offset(size.width, half),
      Paint()
        ..color = _rt_Tw.gray400
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: mediumLabel,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _labelInk,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, half - tp.height - 4));

    final sign = water ? 1.0 : -1.0;
    canvas.translate(size.width / 2, half + sign * 32 * k * progress);
    canvas.rotate(sign * math.pi / 2 * progress);
    canvas.scale(k);
    // Tail: source SVG `M50 5 L40 0 ... L0 5`, tucked 8px under the head.
    final tail = Path()
      ..moveTo(50, 5)
      ..lineTo(40, 0)
      ..lineTo(30, 10)
      ..lineTo(20, 0)
      ..lineTo(10, 10)
      ..lineTo(0, 5);
    canvas.drawPath(
      tail.shift(const Offset(-58, -5)),
      Paint()
        ..color = _tailColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(Offset.zero, 16, Paint()..color = _rt_Tw.blue600);
    canvas.drawCircle(
      Offset.zero,
      16,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
    canvas.drawRRect(
      r.deflate(2),
      Paint()
        ..color = _rt_Tw.slate300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant _TestBoxPainter old) =>
      old.progress != progress ||
      old.water != water ||
      old.mediumLabel != mediumLabel;
}

/// Zone 2 canvas: dirty T-shirt, oil blob and the soap swarm forming a micelle.
class _MicellePainter extends CustomPainter {
  _MicellePainter({
    required this.sim,
    required this.showLabels,
    required this.waterLabel,
    required this.shirtLabel,
    required this.oilLabel,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _MicelleSim sim;
  final bool showLabels;
  final String waterLabel, shirtLabel, oilLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12507A), Color(0xFF0B2B48)],
        ).createShader(rect),
    );
    final (s, off) = _fit(size, _MicelleSim.w, _MicelleSim.h);
    Offset scr(double x, double y) => off + Offset(x, y) * s;
    const cx = _MicelleSim.cx, cy = _MicelleSim.cy;

    canvas.save();
    canvas.translate(off.dx, off.dy);
    canvas.scale(s);
    _drawShirt(canvas, cx, cy + 20, 1.6);
    canvas.drawCircle(Offset(cx, sim.oilY), 45, Paint()..color = _oilColor);
    canvas.drawCircle(
      Offset(cx, sim.oilY),
      45,
      Paint()
        ..color = _oilEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(cx - 15, sim.oilY - 15),
      10,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    if (sim.soapAdded) {
      for (final p in sim.mols) {
        _drawMolecule(canvas, p.x, p.y, p.angle, scale: 1.4);
      }
    }
    canvas.restore();

    if (showLabels) {
      _drawPill(canvas, size, waterLabel, const Offset(8, 18), left: true);
      _drawPill(
        canvas,
        size,
        shirtLabel,
        scr(cx, cy + 20 + 110 * 1.6 + 10),
        color: const Color(0xFFDB2777),
      );
      _drawPill(
        canvas,
        size,
        oilLabel,
        scr(cx, sim.oilY + 76),
        color: const Color(0xFF92400E),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MicellePainter old) => true;
}

/// Zone 3 canvas: beaker A (distilled) vs beaker B (hard water with Ca²⁺).
class _HardWaterPainter extends CustomPainter {
  _HardWaterPainter({
    required this.sim,
    required this.showLabels,
    required this.labelA,
    required this.labelB,
    required this.foamLabel,
    required this.scumLabel,
    required this.noFoamLabel,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _HardWaterSim sim;
  final bool showLabels;
  final String labelA, labelB, foamLabel, scumLabel, noFoamLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const w = _HardWaterSim.w, h = _HardWaterSim.h;
    const bw = _HardWaterSim.beakerW,
        bh = _HardWaterSim.beakerH,
        by = _HardWaterSim.beakerY;
    const xA = _HardWaterSim.xA,
        xB = _HardWaterSim.xB,
        top = _HardWaterSim.liquidTop;
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15233B), Color(0xFF0B1324)],
        ).createShader(rect),
    );
    final (s, off) = _fit(size, w, h);
    Offset scr(double x, double y) => off + Offset(x, y) * s;
    // Bench (source floor strip) runs the full width of the view.
    final benchTop = scr(0, h - 50).dy;
    canvas.drawRect(
      Rect.fromLTRB(0, benchTop, size.width, size.height),
      Paint()..color = _rt_Tw.slate700,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, benchTop, size.width, benchTop + 3),
      Paint()..color = _rt_Tw.slate500,
    );

    canvas.save();
    canvas.translate(off.dx, off.dy);
    canvas.scale(s);
    _drawBeaker(canvas, xA, by, bw, bh, 0.7);
    _drawBeaker(canvas, xB, by, bw, bh, 0.7);
    for (final p in sim.a) {
      _drawMolecule(canvas, p.x, p.y, p.angle);
    }
    if (sim.addedA) {
      final t = sim.time;
      final fill = Paint()..color = Colors.white;
      final edge = Paint()
        ..color = _rt_Tw.slate400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (var i = 0; i < 15; i++) {
        final c = Offset(
          xA + 30 + i * 10 + math.sin(t * 2 + i) * 5,
          top - 10 + math.sin(t * 3.33 + i) * 5,
        );
        final r = 9 + math.sin(t * 7 + i * 1.3);
        canvas.drawCircle(c, r, fill);
        canvas.drawCircle(c, r, edge);
      }
    }
    canvas.restore();

    _drawIons(canvas, sim.ions, scr);

    canvas.save();
    canvas.translate(off.dx, off.dy);
    canvas.scale(s);
    for (final p in sim.b) {
      if (p.active) _drawMolecule(canvas, p.x, p.y, 0);
    }
    final scum = Paint()..color = _scumColor;
    final scumEdge = Paint()
      ..color = _rt_Tw.slate500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final sc in sim.scums) {
      canvas.drawCircle(Offset(sc.x, sc.y), sc.r, scum);
      canvas.drawCircle(Offset(sc.x, sc.y), sc.r, scumEdge);
    }
    canvas.restore();

    if (showLabels) {
      _drawPill(canvas, size, labelA, scr(xA + bw / 2, by + bh + 25));
      _drawPill(canvas, size, labelB, scr(xB + bw / 2, by + bh + 25));
      if (sim.addedA) {
        _drawPill(canvas, size, foamLabel, scr(xA + bw / 2, top - 50));
      }
      if (sim.scums.length > 5) {
        _drawPill(
          canvas,
          size,
          scumLabel,
          scr(xB + bw / 2, top + 50),
          color: _rt_Tw.slate600,
        );
        _drawPill(
          canvas,
          size,
          noFoamLabel,
          scr(xB + bw / 2, top - 20),
          color: _rt_Tw.red500,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HardWaterPainter old) => true;
}

/// Zone 4 canvas: handkerchief with grease in hard water; soap vs detergent.
class _DetergentPainter extends CustomPainter {
  _DetergentPainter({
    required this.sim,
    required this.showLabels,
    required this.envLabel,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _DetergentSim sim;
  final bool showLabels;
  final String envLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const w = _DetergentSim.w, h = _DetergentSim.h, cx = _DetergentSim.cx;
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF173B63), Color(0xFF0D2440)],
        ).createShader(rect),
    );
    final (s, off) = _fit(size, w, h);
    Offset scr(double x, double y) => off + Offset(x, y) * s;

    canvas.save();
    canvas.translate(off.dx, off.dy);
    canvas.scale(s);
    _drawHandkerchief(canvas, cx, h / 2 + 20, 1.6);
    canvas.drawCircle(Offset(cx, sim.oilY), 30, Paint()..color = _oilColor);
    canvas.restore();

    _drawIons(canvas, sim.ions, scr);

    canvas.save();
    canvas.translate(off.dx, off.dy);
    canvas.scale(s);
    for (final p in sim.mols) {
      if (p.active) {
        _drawMolecule(
          canvas,
          p.x,
          p.y,
          p.angle,
          detergent: sim.isDetergent,
          scale: 1.2,
        );
      }
    }
    final scum = Paint()..color = _scumColor;
    for (final sc in sim.scums) {
      canvas.drawCircle(Offset(sc.x, sc.y), sc.r, scum);
    }
    canvas.restore();

    if (showLabels) {
      _drawPill(canvas, size, envLabel, const Offset(8, 18), left: true);
    }
  }

  @override
  bool shouldRepaint(covariant _DetergentPainter old) => true;
}
