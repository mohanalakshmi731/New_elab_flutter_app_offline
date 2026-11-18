// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 11.4: Resistance in a Wire (The Resistivity Workshop)
// Converted from Cl10S-Ch11-A4-TheResistivityWorkshop.html (SVG circuit sim -> CustomPainter).
//
// A live circuit drives a test conductor between two connecting wires: the
// student picks a material (copper / nichrome / glass), then drags the Length
// and Area sliders while an ammeter gauge and electron flow react. Physics is
// exactly the source's: R = rho * (L/10) / A, I = min(1.5 V / R, 10 A).
// Three missions (one per material) each unlock an observation popup once
// BOTH sliders have been moved; finishing the glass mission shows the
// completion popup. Context, Teacher Guide and Analysis notes sit at the
// foot of the sidebar.

// --- TRANSLATION DATA (the source's `content` block; te: ignored) ---

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
  static const gray200 = Color(0xFFE5E7EB);
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
  static const blue900 = Color(0xFF1E3A8A);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const green400 = Color(0xFF4ADE80);
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

  void setSidebarOpen(bool open) => _state?._setSidebar(open);

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
    this.onStart,
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
  final VoidCallback? onStart;

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

  void _setSidebar(bool open) {
    if (open == _isSidebarOpen) return;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _isSidebarOpen = open);
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
      'title': 'Resistivity Workshop',
      'subtitle': 'Class 10 • Electricity',
      'button': 'Enter _rt_Lab',
      'footnote': 'Length • Area • Material — what changes Resistance?',
    },
    'header': {
      'title': 'Resistance in a Wire',
      'subtitle': 'Class 10 • Electricity',
    },
    'ctrl': {
      'nature': 'Nature (ρ)',
      'length': 'Length (L)',
      'area': 'Area (A)',
    },
    'lbl': {
      'battery': 'Battery (Source)',
      'connWire': 'Connecting Wire',
      'testCond': 'Test Conductor',
      'eflow': 'e⁻ Flow',
      'do': 'Do',
      'focus': 'Focus',
      'observation': 'Observation',
      'completion': 'Completion',
      'completeTitle': 'Workshop Completed!',
      'completeMsg':
          'You have successfully explored how Length, Area, and Material affect Resistance.',
    },
    'btn': {
      'restart': 'Restart _rt_Lab',
      'next': 'Next',
      'prev': 'Prev',
      'finish': 'Finish',
    },
    'msg': {
      'lenInc': 'Length ↑ increases Resistance (R ∝ L)',
      'lenDec': 'Length ↓ decreases Resistance',
      'areaInc': 'Area ↑ decreases Resistance (R ∝ 1/A)',
      'areaDec': 'Area ↓ increases Resistance',
    },
    'mat': {'copper': 'Copper', 'nichrome': 'Nichrome', 'glass': 'Glass'},
    'ui': {
      'ammeter': 'Ammeter',
      'controlDeck': 'Control Deck',
      'toggleLabels': 'Toggle Labels',
    },
    'tabs': {
      'context': 'Why Learn?',
      'guide': 'Teacher Guide',
      'explore': 'Explore',
      'analysis': 'Analysis',
    },
    'explore': {
      'title': 'Explore',
      'objective': 'Main Objective: Discover the factors affecting Resistance.',
    },
    'context': {
      'intro':
          'Understanding resistivity is crucial for electrical engineering. It helps us choose the right materials for specific tasks—like copper for transmitting power efficiently or nichrome for generating heat in appliances. Without this knowledge, circuits would be inefficient or dangerous.',
      'apps': [
        {
          't': 'Power Transmission',
          'd':
              'High tension cables are thick to reduce resistance and minimize heat loss.',
        },
        {
          't': 'Electric Heaters',
          'd': 'Nichrome has high resistance to generate heat without melting.',
        },
        {
          't': 'Fuse Wire',
          'd': 'Fuses melt if current surges due to high resistance.',
        },
      ],
    },
    'guide': {
      'intro':
          "Objective: To empirically demonstrate how Length, Area, and Material Nature affect Resistance. This bridges the gap between Ohm's Law and material science. Why? To clarify that Resistance is geometric, while Resistivity is intrinsic.",
      'phases': [
        {
          't': '1. DISCOVERY Phase',
          'd':
              "Encourage students to predict the outcome before changing variables. Ask 'Does length affect flow?'",
        },
        {
          't': '2. INTERACTION Phase',
          'd':
              'Have students actively manipulate the sliders. Ensure they note the Ammeter reading changes.',
        },
        {
          't': '3. OBSERVATION Phase',
          'd':
              'Conclude by comparing the three materials. Discuss why Glass has zero current.',
        },
      ],
    },
    'analysis': {
      'colObs': 'Observation',
      'colOutcome': 'Learning Outcome',
      'rows': [
        {
          'obs': 'R increases with Length',
          'res': 'Resistance is directly proportional to Length (R ∝ L).',
        },
        {
          'obs': 'R decreases with Area',
          'res': 'Resistance is inversely proportional to Area (R ∝ 1/A).',
        },
        {
          'obs': 'Different materials, different R',
          'res': 'Resistivity (ρ) is a fundamental property of the material.',
        },
      ],
    },
    'missions': [
      {
        'obj': 'Step 1: Analyze Copper (Metal)',
        'do': 'Select Copper and adjust Length/Area.',
        'focus': 'Observe low Resistance and High Current.',
        'hudDo': 'Action: Move BOTH Length and Area sliders to test Copper.',
        'hudFocus':
            'Focus: Copper has very low resistance, allowing high current.',
        'obs':
            'Observation: Copper is an excellent conductor. Changes in geometry affect R, but current remains relatively high due to low ρ.',
      },
      {
        'obj': 'Step 2: Analyze Nichrome (Alloy)',
        'do': 'Switch material to Nichrome.',
        'focus': 'Observe moderate Resistance and Current.',
        'hudDo': 'Action: Move BOTH Length and Area sliders to test Nichrome.',
        'hudFocus':
            'Focus: Resistance increases significantly compared to Copper.',
        'obs':
            'Observation: Nichrome has higher resistivity than Copper. It restricts flow more, generating heat (glows at high current).',
      },
      {
        'obj': 'Step 3: Analyze Glass (Insulator)',
        'do': 'Switch material to Glass.',
        'focus': 'Observe infinite Resistance (Zero Current).',
        'hudDo': 'Action: Move BOTH Length and Area sliders to test Glass.',
        'hudFocus': 'Focus: Glass is an insulator; current drops to zero.',
        'obs':
            'Observation: Glass is an insulator with extremely high resistivity. No free electrons are available to carry current.',
      },
    ],
  },
  'hi': {
    'intro': {
      'title': 'प्रतिरोधकता कार्यशाला',
      'subtitle': 'कक्षा 10 • विद्युत',
      'button': 'लैब में प्रवेश करें',
      'footnote': 'लम्बाई • क्षेत्रफल • पदार्थ — प्रतिरोध किससे बदलता है?',
    },
    'header': {'title': 'तार में प्रतिरोध', 'subtitle': 'कक्षा 10 • विद्युत'},
    'ctrl': {
      'nature': 'प्रकृति (ρ)',
      'length': 'लम्बाई (L)',
      'area': 'क्षेत्रफल (A)',
    },
    'lbl': {
      'battery': 'बैटरी (स्रोत)',
      'connWire': 'संयोजक तार',
      'testCond': 'परीक्षण चालक',
      'eflow': 'e⁻ प्रवाह',
      'do': 'करें',
      'focus': 'ध्यान दें',
      'observation': 'अवलोकन',
      'completion': 'समापन',
      'completeTitle': 'कार्यशाला पूर्ण!',
      'completeMsg':
          'आपने सफलतापूर्वक पता लगाया है कि लंबाई, क्षेत्रफल और सामग्री प्रतिरोध को कैसे प्रभावित करते हैं।',
    },
    'btn': {
      'restart': 'लैब पुनः आरंभ करें',
      'next': 'अगला',
      'prev': 'पिछला',
      'finish': 'समाप्त',
    },
    'msg': {
      'lenInc': 'लंबाई ↑ प्रतिरोध बढ़ाती है (R ∝ L)',
      'lenDec': 'लंबाई ↓ प्रतिरोध घटाती है',
      'areaInc': 'क्षेत्रफल ↑ प्रतिरोध घटाता है (R ∝ 1/A)',
      'areaDec': 'क्षेत्रफल ↓ प्रतिरोध बढ़ाता है',
    },
    'mat': {'copper': 'तांबा', 'nichrome': 'नाइक्रोम', 'glass': 'कांच'},
    'ui': {
      'ammeter': 'एमीटर',
      'controlDeck': 'कंट्रोल डेक',
      'toggleLabels': 'लेबल दिखाएँ/छिपाएँ',
    },
    'tabs': {
      'context': 'संदर्भ',
      'guide': 'शिक्षक गाइड',
      'explore': 'अन्वेषण',
      'analysis': 'विश्लेषण',
    },
    'explore': {
      'title': 'अन्वेषण',
      'objective':
          'मुख्य उद्देश्य: प्रतिरोध को प्रभावित करने वाले कारकों की खोज करें।',
    },
    'context': {
      'intro':
          'विद्युत इंजीनियरिंग के लिए प्रतिरोधकता को समझना अत्यंत महत्वपूर्ण है। यह हमें विशिष्ट कार्यों के लिए सही सामग्री चुनने में मदद करता है—जैसे बिजली को कुशलतापूर्वक संचारित करने के लिए तांबा, या हीटर और टोस्टर जैसे उपकरणों में गर्मी उत्पन्न करने के लिए नाइक्रोम। इस ज्ञान के बिना, विद्युत परिपथ या तो अक्षम होंगे या खतरनाक हो सकते हैं।',
      'apps': [
        {
          't': 'विद्युत संचरण',
          'd': 'बिजली के तार मोटे होते हैं ताकि प्रतिरोध कम हो।',
        },
        {
          't': 'विद्युत हीटर',
          'd': 'नाइक्रोम का उच्च प्रतिरोध गर्मी पैदा करता है।',
        },
        {'t': 'फ्यूज वायर', 'd': 'उच्च धारा पर फ्यूज पिघल जाता है।'},
      ],
    },
    'guide': {
      'intro':
          'उद्देश्य: यह प्रदर्शित करना कि लंबाई, क्षेत्रफल और सामग्री की प्रकृति प्रतिरोध को कैसे प्रभावित करती है। यह ओम के नियम और भौतिक विज्ञान के बीच की खाई को पाटता है। क्यों? यह स्पष्ट करने के लिए कि प्रतिरोध एक ज्यामितीय गुण है, जबकि प्रतिरोधकता सामग्री का आंतरिक गुण है।',
      'phases': [
        {
          't': '1. खोज चरण',
          'd':
              "छात्रों को भविष्यवाणी करने के लिए प्रोत्साहित करें। पूछें 'क्या लंबाई प्रवाह को प्रभावित करती है?'",
        },
        {
          't': '2. अंतक्रिया चरण',
          'd':
              'छात्रों से स्लाइडर्स को सक्रिय रूप से हेरफेर करने के लिए कहें। एमीटर रीडिंग में बदलाव नोट करें।',
        },
        {
          't': '3. अवलोकन चरण',
          'd':
              'तीन सामग्रियों की तुलना करके निष्कर्ष निकालें। चर्चा करें कि कांच में शून्य धारा क्यों है।',
        },
      ],
    },
    'analysis': {
      'colObs': 'अवलोकन',
      'colOutcome': 'सीखने का परिणाम',
      'rows': [
        {
          'obs': 'R लंबाई के साथ बढ़ता है',
          'res': 'प्रतिरोध लंबाई के सीधे समानुपाती होता है (R ∝ L)।',
        },
        {
          'obs': 'R क्षेत्रफल के साथ घटता है',
          'res': 'प्रतिरोध क्षेत्रफल के व्युत्क्रमानुपाती होता है (R ∝ 1/A)।',
        },
        {
          'obs': 'विभिन्न सामग्री, अलग R',
          'res': 'प्रतिरोधकता (ρ) सामग्री का एक मूलभूत गुण है।',
        },
      ],
    },
    'missions': [
      {
        'obj': 'चरण 1: तांबे का विश्लेषण',
        'do': 'तांबा चुनें और स्लाइडर्स को समायोजित करें।',
        'focus': 'कम प्रतिरोध और उच्च धारा का निरीक्षण करें।',
        'hudDo':
            'क्रिया: तांबे का परीक्षण करने के लिए दोनों स्लाइडर्स को हिलाएं।',
        'hudFocus': 'ध्यान दें: तांबे में बहुत कम प्रतिरोध होता है।',
        'obs':
            'अवलोकन: तांबा एक उत्कृष्ट चालक है। ज्यामिति में परिवर्तन R को प्रभावित करते हैं, लेकिन कम ρ के कारण धारा उच्च रहती है।',
      },
      {
        'obj': 'चरण 2: नाइक्रोम का विश्लेषण',
        'do': 'सामग्री को नाइक्रोम में बदलें।',
        'focus': 'मध्यम प्रतिरोध का निरीक्षण करें।',
        'hudDo':
            'क्रिया: नाइक्रोम का परीक्षण करने के लिए दोनों स्लाइडर्स को हिलाएं।',
        'hudFocus': 'ध्यान दें: प्रतिरोध काफी बढ़ जाता है।',
        'obs':
            'अवलोकन: नाइक्रोम की प्रतिरोधकता तांबे से अधिक है। यह प्रवाह को रोकता है, गर्मी पैदा करता है।',
      },
      {
        'obj': 'चरण 3: कांच का विश्लेषण',
        'do': 'सामग्री को कांच में बदलें।',
        'focus': 'शून्य धारा का निरीक्षण करें।',
        'hudDo':
            'क्रिया: कांच का परीक्षण करने के लिए दोनों स्लाइडर्स को हिलाएं।',
        'hudFocus': 'ध्यान दें: कांच एक कुचालक है।',
        'obs':
            'अवलोकन: कांच एक कुचालक है। धारा ले जाने के लिए कोई मुक्त इलेक्ट्रॉन उपलब्ध नहीं हैं।',
      },
    ],
  },
});

/// Mission order: material analysed at each step (the source's `missions`).
const List<String> _missionMats = ['copper', 'nichrome', 'glass'];

/// Resistivities from the source's `materials` map (relative units).
const Map<String, double> _rhoOf = {
  'copper': 0.05,
  'nichrome': 1.0,
  'glass': 99999.0,
};

const double _voltage = 1.5;

class Cl10SCh11A4ResistivityWorkshopPage extends StatefulWidget {
  const Cl10SCh11A4ResistivityWorkshopPage({super.key});

  @override
  State<Cl10SCh11A4ResistivityWorkshopPage> createState() =>
      _Cl10SCh11A4ResistivityWorkshopPageState();
}

class _Cl10SCh11A4ResistivityWorkshopPageState
    extends State<Cl10SCh11A4ResistivityWorkshopPage>
    with SingleTickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();

  // --- Physics state (the source's `state`) ---
  double _length = 10; // cm, 1..100
  double _area = 1.0; // cm^2, 0.1..15
  String _material = 'copper';

  // --- Mission state ---
  int _step = 0;
  bool _movedLen = false;
  bool _movedArea = false;
  final Set<int> _doneSteps = {};
  Timer? _obsTimer;
  bool _obsShowing = false;

  // --- HUD flash (yellow slider feedback, 2 s) ---
  String? _flashMsg;
  Timer? _flashTimer;

  bool _showLabels = true;
  bool _wasGlowing = false;
  bool _wasFlowing = true;

  /// Drives electron drift + heat pulse repaints.
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();
  final Stopwatch _clock = Stopwatch()..start();

  double get _resistance => (_rhoOf[_material]! * (_length / 10)) / _area;

  double get _current {
    final r = _resistance;
    return r < 0.01 ? 10.0 : math.min(_voltage / r, 10.0);
  }

  bool get _glowing => _material == 'nichrome' && _current > 2.0;

  double get _glowOpacity =>
      _glowing ? math.min((_current - 2.0) / 4, 0.8) : 0.0;

  Map<String, dynamic> _mission(int i) =>
      (_tx.list('missions')[i] as Map).cast<String, dynamic>();

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
    _obsTimer?.cancel();
    _flashTimer?.cancel();
    _ticker.dispose();
    _zoom.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- logic ---

  /// Audible cues for scene changes (heat glow ignites, current dies).
  void _sceneSounds() {
    final glowing = _glowing;
    if (glowing && !_wasGlowing) _rt_playSfx(_rt_Sfx.magic, volume: 0.7);
    _wasGlowing = glowing;
    final flowing = _current >= 0.01;
    if (!flowing && _wasFlowing) _rt_playSfx(_rt_Sfx.pop, volume: 0.8);
    _wasFlowing = flowing;
  }

  void _flash(String msg) {
    _flashTimer?.cancel();
    setState(() => _flashMsg = msg);
    _flashTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _flashMsg = null);
    });
  }

  void _onLengthChanged(double v) {
    if (v == _length) return;
    final inc = v > _length;
    setState(() => _length = v);
    _flash(_tx.s(inc ? 'msg.lenInc' : 'msg.lenDec'));
    _sceneSounds();
    _markMoved(len: true);
  }

  void _onAreaChanged(double v) {
    if (v == _area) return;
    final inc = v > _area;
    setState(() => _area = v);
    _flash(_tx.s(inc ? 'msg.areaInc' : 'msg.areaDec'));
    _sceneSounds();
    _markMoved(area: true);
  }

  /// The source's `handleSliderInteraction` + `triggerStepTimer`: once BOTH
  /// sliders have been moved, (re)start the 3 s countdown to the popup.
  void _markMoved({bool len = false, bool area = false}) {
    if (len) _movedLen = true;
    if (area) _movedArea = true;
    if (_movedLen && _movedArea) {
      _obsTimer?.cancel();
      _obsTimer = Timer(const Duration(seconds: 3), _showObservation);
    }
  }

  Future<void> _showObservation() async {
    if (!mounted || _obsShowing) return;
    _obsShowing = true;
    _doneSteps.add(_step);
    setState(() {});
    final step = _step;
    _rt_playSfx(_rt_Sfx.success);
    await _rt_showShellPopup(
      context,
      title: _tx.s('lbl.observation'),
      message: _mission(step)['obs'] as String,
      icon: Icons.visibility,
      color: _rt_Tw.blue500,
      actions: [
        if (step > 0)
          _rt_ActionButton(
            key: const ValueKey('obs-prev'),
            label: _tx.s('btn.prev'),
            icon: Icons.arrow_back,
            color: _rt_Tw.slate600,
            onPressed: () {
              Navigator.of(context).pop();
              _goToStep(step - 1);
            },
          ),
        if (step < 2)
          _rt_ActionButton(
            key: const ValueKey('obs-next'),
            label: _tx.s('btn.next'),
            icon: Icons.arrow_forward,
            color: _rt_Tw.blue600,
            onPressed: () {
              Navigator.of(context).pop();
              _goToStep(step + 1);
            },
          )
        else
          _rt_ActionButton(
            key: const ValueKey('obs-finish'),
            label: _tx.s('btn.finish'),
            icon: Icons.check,
            color: _rt_Tw.green600,
            onPressed: () {
              Navigator.of(context).pop();
              _finishLab();
            },
          ),
      ],
    );
    _obsShowing = false;
  }

  Future<void> _finishLab() async {
    _rt_playSfx(_rt_Sfx.success);
    await _rt_showShellPopup(
      context,
      title: _tx.s('lbl.completeTitle'),
      message: _tx.s('lbl.completeMsg'),
      icon: Icons.emoji_events,
      color: _rt_Tw.green500,
      actions: [
        _rt_ActionButton(
          key: const ValueKey('complete-restart'),
          label: _tx.s('btn.restart'),
          icon: Icons.replay,
          color: _rt_Tw.blue600,
          onPressed: () {
            Navigator.of(context).pop();
            _goToStep(0);
          },
        ),
        // The source's popup X jumps to the Analysis tab; here the notes live
        // at the foot of the sidebar, so this button opens it.
        _rt_ActionButton(
          key: const ValueKey('complete-analysis'),
          label: _tx.s('tabs.analysis'),
          icon: Icons.table_chart,
          color: _rt_Tw.slate600,
          onPressed: () {
            Navigator.of(context).pop();
            _shell.setSidebarOpen(true);
          },
        ),
      ],
    );
  }

  /// The source's `goToStep`: selects the mission, its material, and resets
  /// the both-sliders requirement.
  void _goToStep(int i, {bool silent = false}) {
    _obsTimer?.cancel();
    _flashTimer?.cancel();
    setState(() {
      _step = i;
      _movedLen = false;
      _movedArea = false;
      _flashMsg = null;
      _material = _missionMats[i];
    });
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    _sceneSounds();
    _shell.setSidebarOpen(true);
  }

  void _onMaterialTap(String mat) {
    if (mat == _material) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    // Material is bound to the mission analysing it (as in the source, where
    // `setMaterial` only ever runs through `goToStep`).
    _goToStep(_missionMats.indexOf(mat));
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  /// HARD RESET (the source's reset button).
  void _restart() {
    _obsTimer?.cancel();
    _flashTimer?.cancel();
    setState(() {
      _length = 10;
      _area = 1.0;
      _material = 'copper';
      _step = 0;
      _movedLen = false;
      _movedArea = false;
      _doneSteps.clear();
      _flashMsg = null;
      _showLabels = true;
      _wasGlowing = false;
      _wasFlowing = true;
    });
    _zoom.reset();
  }

  // ---------------------------------------------------------------- UI ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final m = _mission(_step);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('header.title'),
            subtitle: _tx.s('header.subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.blue500,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
              headerSubtitleColor: _rt_Tw.blue100,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.memory,
            ),
            onStart: () => _goToStep(0, silent: true),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: _showLabels ? Icons.visibility : Icons.visibility_off,
                tooltip: _tx.s('ui.toggleLabels'),
                onTap: _toggleLabels,
              ),
            ],
            hint: _rt_StepHint(
              number: '${_step + 1}',
              label: m['obj'] as String,
              text: m['hudDo'] as String,
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('explore.title'),
                icon: Icons.checklist,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: CustomPaint(
              painter: _DotGridPainter(_rt_Lab.border),
              child: LayoutBuilder(
                builder: (context, c) => _rt_ZoomableCanvas(
                  controller: _zoom,
                  child: SizedBox(
                    width: c.maxWidth,
                    height: c.maxHeight,
                    child: CustomPaint(
                      painter: _CircuitPainter(
                        length: _length,
                        area: _area,
                        material: _material,
                        current: _current,
                        glowOpacity: _glowOpacity,
                        showLabels: _showLabels,
                        time: () => _clock.elapsedMilliseconds / 1000.0,
                        lblBattery: _tx.s('lbl.battery'),
                        lblConnWire: _tx.s('lbl.connWire'),
                        lblTestCond: _tx.s('lbl.testCond'),
                        lblEFlow: _tx.s('lbl.eflow'),
                        repaint: _ticker,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            canvasOverlays: [
              // Ammeter (the source's top-left glass panel).
              Positioned(top: 10, left: 66, child: _ammeterPanel()),
              // Guidance HUD (top centre pill).
              Positioned(top: 10, left: 218, right: 64, child: _guidanceHud(m)),
            ],
          );
        },
      ),
    );
  }

  Widget _guidanceHud(Map<String, dynamic> m) {
    final flash = _flashMsg;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _rt_Tw.slate900.withValues(alpha: 0.93),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _rt_Tw.blue500.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: _rt_Lab.shadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _rt_Tw.blue500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      m['hudDo'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Tw.blue100,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                flash ?? m['hudFocus'] as String,
                textAlign: TextAlign.center,
                style: flash != null
                    ? const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Tw.amber400,
                      )
                    : const TextStyle(
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                        color: _rt_Tw.slate400,
                        height: 1.25,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ammeterPanel() {
    return Container(
      key: const ValueKey('ammeter'),
      width: 140,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: _rt_Tw.slate900.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: _rt_Tw.blue500, width: 4)),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('ui.ammeter').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.slate400,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Icon(Icons.speed, size: 13, color: _rt_Tw.blue400),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: CustomPaint(painter: _GaugePainter(current: _current)),
          ),
          Center(
            child: Text(
              '${_current.toStringAsFixed(2)} A',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'R = ${_resistance.toStringAsFixed(2)} Ω',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _rt_Tw.blue100,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ sidebar ---

  Widget _exploreTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rt_ObjectiveCard(
            title: _tx.s('explore.title'),
            desc: _tx.s('explore.objective'),
            accent: _rt_Tw.blue500,
            icon: Icons.bolt,
          ),
          const SizedBox(height: 14),
          _rt_SectionLabel(
            _tx.s('ui.controlDeck'),
            icon: Icons.tune,
            color: _rt_Tw.blue400,
          ),
          const SizedBox(height: 8),
          _controlDeck(),
          const SizedBox(height: 16),
          _rt_SectionLabel(
            _tx.s('tabs.explore'),
            icon: Icons.flag,
            color: _rt_Tw.blue400,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++) ...[
            _missionCard(i),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          Divider(color: _rt_Lab.border),
          const SizedBox(height: 8),
          // --- Notes: Context / Teacher Guide / Analysis (source tabs 0,1,3) ---
          _rt_SectionLabel(
            _tx.s('tabs.context'),
            icon: Icons.lightbulb,
            color: _rt_Tw.amber400,
          ),
          const SizedBox(height: 8),
          _rt_InfoCard(body: _tx.s('context.intro'), color: _rt_Tw.blue500),
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++) ...[
            _rt_InfoCard(
              title: _tx.s('context.apps.$i.t'),
              body: _tx.s('context.apps.$i.d'),
              icon: const [
                Icons.cell_tower,
                Icons.local_fire_department,
                Icons.electrical_services,
              ][i],
              color: const [
                _rt_Tw.amber500,
                _rt_Tw.orange500,
                _rt_Tw.red500,
              ][i],
              leftBorder: true,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _rt_SectionLabel(
            _tx.s('tabs.guide'),
            icon: Icons.school,
            color: _rt_Tw.green400,
          ),
          const SizedBox(height: 8),
          _rt_InfoCard(body: _tx.s('guide.intro'), color: _rt_Tw.slate500),
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++) ...[
            _rt_InfoCard(
              title: _tx.s('guide.phases.$i.t'),
              body: _tx.s('guide.phases.$i.d'),
              color: const [
                _rt_Tw.blue500,
                _rt_Tw.green500,
                _rt_Tw.orange500,
              ][i],
              leftBorder: true,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _rt_SectionLabel(
            _tx.s('tabs.analysis'),
            icon: Icons.table_chart,
            color: _rt_Tw.blue400,
          ),
          const SizedBox(height: 8),
          _analysisTable(),
        ],
      ),
    );
  }

  Widget _controlDeck() {
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
          Text(
            _tx.s('ctrl.nature').toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final mat in _missionMats) ...[
                Expanded(child: _matChip(mat)),
                if (mat != 'glass') const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _rt_LabeledSlider(
            key: const ValueKey('len-slider'),
            label: _tx.s('ctrl.length'),
            value: _length,
            min: 1,
            max: 100,
            valueText: '${_length.toStringAsFixed(1)} cm',
            color: _rt_Tw.blue500,
            onChanged: _onLengthChanged,
          ),
          _rt_LabeledSlider(
            key: const ValueKey('area-slider'),
            label: _tx.s('ctrl.area'),
            value: _area,
            min: 0.1,
            max: 15,
            valueText: '${_area.toStringAsFixed(1)} cm²',
            color: _rt_Tw.blue500,
            onChanged: _onAreaChanged,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _readoutChip(
                'R = ${_resistance.toStringAsFixed(2)} Ω',
                _rt_Tw.blue400,
              ),
              const SizedBox(width: 6),
              _readoutChip(
                'I = ${_current.toStringAsFixed(2)} A',
                _rt_Tw.green400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readoutChip(String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _matChip(String mat) {
    final active = _material == mat;
    return GestureDetector(
      key: ValueKey('mat-$mat'),
      onTap: () => _onMaterialTap(mat),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _rt_Tw.blue600 : _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _rt_Tw.blue400 : _rt_Lab.border),
        ),
        child: Text(
          _tx.s('mat.$mat'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _missionCard(int i) {
    final m = _mission(i);
    final active = _step == i;
    final done = _doneSteps.contains(i);
    return GestureDetector(
      key: ValueKey('mission-$i'),
      onTap: () => _goToStep(i),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: active ? 1 : 0.62,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active
                ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
                : _rt_Lab.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? _rt_Lab.tintedBorder(_rt_Tw.blue500)
                  : _rt_Lab.border,
              width: active ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done
                          ? _rt_Tw.green500
                          : active
                          ? _rt_Tw.blue500
                          : _rt_Lab.overlay,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: active ? Colors.white : _rt_Lab.textMuted,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m['obj'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: active
                            ? _rt_Lab.onTinted(_rt_Tw.blue100, _rt_Tw.blue700)
                            : _rt_Lab.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _missionLine(
                Icons.touch_app,
                _rt_Tw.blue400,
                _tx.s('lbl.do'),
                m['do'] as String,
              ),
              const SizedBox(height: 3),
              _missionLine(
                Icons.visibility,
                _rt_Tw.amber400,
                _tx.s('lbl.focus'),
                m['focus'] as String,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missionLine(IconData icon, Color color, String tag, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 28),
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$tag: ',
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                TextSpan(text: text),
              ],
            ),
            style: TextStyle(
              fontSize: 10.5,
              color: _rt_Lab.textMuted,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _analysisTable() {
    final colors = [_rt_Tw.blue400, _rt_Tw.green400, _rt_Tw.orange400];
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _tx.s('analysis.colObs').toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.textFaint,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _tx.s('analysis.colOutcome').toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.textFaint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < 3; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
                      _tx.s('analysis.rows.$i.obs'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: colors[i],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _tx.s('analysis.rows.$i.res'),
                      style: TextStyle(
                        fontSize: 10.5,
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
    );
  }
}

// ---------------------------------------------------------------- widgets ---

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
}

// ---------------------------------------------------------------- painters ---

/// Faint dot grid behind the circuit (the source's radial-gradient background).
class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withValues(alpha: 0.35);
    for (double x = 12; x < size.width; x += 24) {
      for (double y = 12; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

/// Ammeter dial: semicircular scale with an animated needle
/// (angle = -90° + I/10 * 180°, capped at +90°, as in the source).
class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.current});

  final double current;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height - 4);
    final r = math.min(size.width / 2 - 8, size.height - 10);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = _rt_Tw.slate700;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi,
      math.pi,
      false,
      arc,
    );

    // Ticks: start (grey), mid (grey), end (red).
    void tick(double deg, Color color) {
      final a = deg * math.pi / 180;
      final dir = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(
        c + dir * r,
        c + dir * (r - 5),
        Paint()
          ..color = color
          ..strokeWidth = 1.6,
      );
    }

    tick(-90, _rt_Tw.slate400);
    tick(0, _rt_Tw.slate400);
    tick(90, _rt_Tw.red500);

    final angle = math.min(-90 + (current / 10) * 180, 90.0) * math.pi / 180;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    canvas.drawLine(
      c,
      c + dir * (r - 4),
      Paint()
        ..color = _rt_Tw.red400
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 2.6, Paint()..color = _rt_Tw.slate300);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.current != current;
}

/// The circuit scene: battery loop, dynamic test wire (width from L, height
/// from sqrt(A)), material gradients, heat glow, drifting electrons, labels.
/// Geometry mirrors the source SVG (viewBox -200 -200 1400 700, circuit group
/// at +100,+180).
class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.length,
    required this.area,
    required this.material,
    required this.current,
    required this.glowOpacity,
    required this.showLabels,
    required this.time,
    required this.lblBattery,
    required this.lblConnWire,
    required this.lblTestCond,
    required this.lblEFlow,
    super.repaint,
  });

  final double length;
  final double area;
  final String material;
  final double current;
  final double glowOpacity;
  final bool showLabels;
  final double Function() time;
  final String lblBattery;
  final String lblConnWire;
  final String lblTestCond;
  final String lblEFlow;

  static const _designW = 1400.0;
  static const _designH = 700.0;

  List<Color> get _wireColors {
    switch (material) {
      case 'copper':
        return const [Color(0xFFFDBA74), Color(0xFFFB923C), Color(0xFFC2410C)];
      case 'glass':
        return const [Color(0x80BFDBFE), Color(0x4D60A5FA), Color(0x803B82F6)];
      default: // nichrome
        return const [Color(0xFFCBD5E1), Color(0xFF94A3B8), Color(0xFF64748B)];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _designW, size.height / _designH);
    canvas.save();
    canvas.translate(
      (size.width - _designW * s) / 2 + 200 * s,
      (size.height - _designH * s) / 2 + 200 * s,
    );
    canvas.scale(s);
    canvas.translate(100, 180); // circuit group

    final t = time();
    // Wire geometry (the source's updateVisuals).
    final w = 100 + (length / 100) * 900;
    final h = 20 + math.sqrt(area) * 15;
    final startX = (1000 - w) / 2;
    const wireY = 30.0; // test-wire group offset

    final loop = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _rt_Tw.slate400;

    // Base wiring: full loop down to the battery.
    canvas.drawPath(
      Path()
        ..moveTo(0, wireY)
        ..lineTo(0, 300)
        ..lineTo(420, 300),
      loop,
    );
    canvas.drawPath(
      Path()
        ..moveTo(580, 300)
        ..lineTo(1000, 300)
        ..lineTo(1000, wireY),
      loop,
    );
    // Dynamic leads up to the test wire caps.
    canvas.drawLine(Offset(0, wireY), Offset(startX, wireY), loop);
    canvas.drawLine(Offset(startX + w, wireY), Offset(1000, wireY), loop);

    _drawBattery(canvas);

    // Heat aura (nichrome at high current), pulsing like `heatPulse`.
    if (glowOpacity > 0) {
      final pulse = 0.65 + 0.35 * math.sin(t * 7);
      final glow = Paint()
        ..color = _rt_Tw.red500.withValues(
          alpha: (glowOpacity * pulse).clamp(0.0, 1.0),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawRect(
        Rect.fromLTWH(startX - 10, wireY - h / 2 - 10, w + 20, h + 20),
        glow,
      );
    }

    // Test wire body with the material gradient.
    final bodyRect = Rect.fromLTWH(startX, wireY - h / 2, w, h);
    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _wireColors,
        ).createShader(bodyRect),
    );
    canvas.drawRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _rt_Tw.slate600,
    );

    // Electrons drifting through the wire (speed ∝ current).
    if (current >= 0.01) {
      canvas.save();
      canvas.clipRect(bodyRect);
      final dot = Paint()..color = _rt_Tw.blue400.withValues(alpha: 0.85);
      const n = 20;
      final speed = current * 0.5;
      for (var i = 0; i < n; i++) {
        final offset = (i / n) * w;
        final x = (offset + t * speed * 100) % w;
        final y = wireY + math.sin(t * 2 + i) * h / 3;
        canvas.drawCircle(Offset(startX + x, y), 4, dot);
      }
      canvas.restore();
    }

    // End caps.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(startX, wireY), width: 16, height: h),
      Paint()..color = _rt_Tw.slate500,
    );
    final rightCap = Rect.fromCenter(
      center: Offset(startX + w, wireY),
      width: 16,
      height: h,
    );
    canvas.drawOval(rightCap, Paint()..color = _rt_Tw.slate300);
    canvas.drawOval(
      rightCap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _rt_Tw.slate600,
    );

    // L measurement label below the wire.
    final lY = wireY + h / 2 + 26;
    _dashedLine(
      canvas,
      Offset(100, lY - 12),
      Offset(900, lY - 12),
      _rt_Tw.blue400.withValues(alpha: 0.45),
      2,
      8,
      8,
    );
    _text(
      canvas,
      'L = ${length.toStringAsFixed(1)} cm',
      Offset(500, lY),
      color: _rt_Tw.blue400,
      size: 22,
      bold: true,
      align: TextAlign.center,
    );

    // Descriptive labels (the source's toggleLabels group).
    if (showLabels) {
      _text(
        canvas,
        lblBattery,
        const Offset(500, 246),
        color: _rt_Tw.slate400,
        size: 17,
        bold: true,
        align: TextAlign.center,
        caps: true,
      );
      _text(
        canvas,
        lblConnWire,
        const Offset(980, 190),
        color: _rt_Tw.slate400,
        size: 17,
        bold: true,
        align: TextAlign.right,
        caps: true,
      );
      _text(
        canvas,
        lblTestCond,
        const Offset(500, -42),
        color: _rt_Tw.blue400,
        size: 17,
        bold: true,
        align: TextAlign.center,
        caps: true,
      );
      _text(
        canvas,
        lblEFlow,
        const Offset(24, 2),
        color: _rt_Tw.blue400,
        size: 13,
        bold: true,
        align: TextAlign.left,
      );
    }

    canvas.restore();
  }

  void _drawBattery(Canvas canvas) {
    canvas.save();
    canvas.translate(500, 300);
    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 28), width: 90, height: 20),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    // Terminals.
    final term = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = _rt_Tw.slate400;
    canvas.drawLine(const Offset(-44, 0), const Offset(-80, 0), term);
    canvas.drawLine(const Offset(48, 0), const Offset(80, 0), term);
    // Main body (metallic vertical gradient).
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-40, -25, 80, 50),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.3, 0.6, 1],
          colors: [
            _rt_Tw.slate700,
            _rt_Tw.slate400,
            _rt_Tw.slate600,
            _rt_Tw.slate800,
          ],
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _rt_Tw.slate900,
    );
    // Positive nub.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, -10, 8, 20),
        const Radius.circular(2),
      ),
      Paint()..color = _rt_Tw.gray200,
    );
    // Negative cap.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-44, -20, 4, 40),
        const Radius.circular(1),
      ),
      Paint()..color = _rt_Tw.slate500.withValues(alpha: 0.6),
    );
    canvas.restore();
  }

  void _dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color,
    double width,
    double dash,
    double gap,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final e = math.min(d + dash, total);
      canvas.drawLine(a + dir * d, a + dir * e, paint);
      d = e + gap;
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset pos, {
    required Color color,
    required double size,
    bool bold = false,
    bool caps = false,
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: caps ? text.toUpperCase() : text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          letterSpacing: caps ? 0.8 : 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = pos.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CircuitPainter old) =>
      old.length != length ||
      old.area != area ||
      old.material != material ||
      old.current != current ||
      old.glowOpacity != glowOpacity ||
      old.showLabels != showLabels ||
      old.lblBattery != lblBattery;
}
