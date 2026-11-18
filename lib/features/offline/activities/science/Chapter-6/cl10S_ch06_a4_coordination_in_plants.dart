// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 6.1: Co-Ordination in Plants
// Converted from Cl10S-Ch6-A4-CoordinationInPlants.html (Tailwind + GSAP +
// inline SVG -> Flutter widgets + CustomPainter).
//
// Four modules picked from the sidebar's Module Select (the source's
// <select>), each a 2D scene with numbered target pins and tappable hotspots:
// (1) Immediate response - pin 1 / the hand / the touch card fold the Mimosa,
//     pin 2 / the pulvinus / the water card verify the water change;
// (2) Phototropism - the window (pin 1) lights the seedling, which bends to
//     the light while its root bends away; the auxin lens (pin 2) shows auxin
//     diffusing to the shady side;
// (3) Other tropisms - geotropism, hydrotropism, chemotropism and tendril
//     cards (pins 1-4);
// (4) Sort & compare - tap the four specimen tokens into the growth-
//     independent / growth-dependent pots and run the live speed race.
// Each module ends in the "Scientific Conclusion" card (OK opens the next
// module); all four lead to the "What We Understand" card, whose Restart
// button (like the header's) brings the intro curtain back.
//
// Source fixes (all listed in the conversion report):
// * The growth lane raced 7 s although its labels, step text and timer cap
//   all say 10 s (L494, L546, L445, L1158 vs L1174); it now takes 10 s.
// * Step 1 says "CLICK on the Mimosa leaflets or Hand" but the leaflets had no
//   click handler; they now trigger pin 1 like the hand.
// * Module 2 refers to "Pin 2 (Auxin Lens)" and the code marks `s2-pin2`
//   placed, but no pin 2 was drawn; the lens card now carries a 2 badge.
// * `placed` styling only reached the HTML-span pins of module 3; every pin
//   now fills in once used.
// * The GRAVITY label used an undefined `svg-text-muted` class (black text on
//   the dark card); it is drawn in the muted text colour.
// * The phototropism arrow referenced an undefined `#arrowhead` marker; the
//   head is drawn.

// --- TRANSLATION DATA (source `locales`; `te:` ignored) ---------------------
// Rich runs: `[e]..[/]` emerald-400, `[E]` emerald-300, `[s]` sky-300,
// `[S]` sky-400, `[a]` amber-300, `[A]` amber-400, `[p]` pink-400,
// `[i]` italic (the source's dark-mode <strong>/<em> colours).

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
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal900 = Color(0xFF134E4A);
  static const cyan400 = Color(0xFF22D3EE);
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
  static const emerald400 = Color(0xFF34D399);
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
  const _rt_MinWidthGate({this.minWidth = 200, required this.child});

  final double minWidth;
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
    this.buttonIcon = Icons.fingerprint,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final IconData buttonIcon;
  final String? footnote = null;
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

  bool get isSidebarOpen => _state?._isSidebarOpen ?? true;

  /// Switches the sidebar to tab [index] (HTML `switchTab`).
}

class _DraggablePopup extends StatefulWidget {
  const _DraggablePopup({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final String? message = null;
  final Widget? body = null;
  final IconData icon;
  final Color color;
  final String? buttonLabel = null;
  final List<Widget>? actions = null;

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
    super.key,
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

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'title': 'Co-Ordination in Plants',
    'subtitle': 'Class 10 • Control and Coordination',
    'enterLab': 'Enter Virtual _rt_Lab',
    'moduleSel': 'Module Select',
    'sciObs': 'Scientific Conclusion',
    'settings': 'Settings',
    'txtScale': 'Text Scaling',
    'missionReady': 'Mission Active',
    'missionObj': 'Mission Objective',
    'taskInstr': 'Task Instructions:',
    'expOut': 'Expected Outcome:',
    'btnOk': 'OK',
    'btnRestartLab': 'Restart Virtual _rt_Lab',
    'finalTitle': 'What We Understand & What We Have Learnt',
    'startSpeedRaceBtn': 'START SPEED RACE',
    'tooltips': {'toggleLock': 'Toggle Lock', 'toggleLabels': 'Toggle Labels'},
    'titles': [
      '1. STEP 1: IMMEDIATE RESPONSE (MIMOSA)',
      '2. STEP 2: PHOTOTROPISM (GROWTH-DEPENDENT)',
      '3. STEP 3: OTHER TROPISMS & TENDRIL',
      '4. STEP 4: SORT & COMPARE',
    ],
    'objs': [
      'To investigate how sensitive plant leaflets fold rapidly on touch without growth, communicating signals cell-to-cell via water-driven shape changes.',
      'To demonstrate phototropism and observe how auxin made at the shoot tip diffuses to the shady side causing bending toward light.',
      'To examine directional tropic growth in response to gravity, water, chemicals (pollen tube), and touch-sensitive differential growth in tendrils.',
      'To classify plant movements into growth-independent vs growth-dependent types and rank their relative speeds.',
    ],
    'steps': [
      [
        {
          't': 'Step 1: Touch Stimulus',
          'i':
              'CLICK on the Mimosa leaflets or Hand (Target ①) to trigger realistic folding and drooping.',
          'o':
              'Leaflets immediately fold up and the petiole droops without any plant growth.',
        },
        {
          't': 'Step 2: Water-Change Mechanism',
          'i':
              'CLICK Target ② on the pulvinus base to verify cell turgor water loss.',
          'o':
              'Cells change shape by changing the amount of water in them (swelling/shrinking).',
        },
      ],
      [
        {
          't': 'Step 1: Light Stimulus',
          'i': 'CLICK Target ① at the Window to illuminate the seedling shoot.',
          'o':
              'Unilateral light from the window illuminates the shoot, causing it to bend toward light.',
        },
        {
          't': 'Step 2: Auxin Diffusion',
          'i':
              'CLICK Target ② at the Auxin lens to observe hormone diffusion to the shady side.',
          'o':
              'Auxin synthesised at shoot tip diffuses to the shady side, stimulating cell elongation.',
        },
      ],
      [
        {
          't': 'Step 1: Geotropism (Gravity)',
          'i':
              'CLICK Target ① to tilt the seedling and watch root down / shoot up.',
          'o':
              'Roots grow downwards (toward gravity); shoots grow upwards (away from gravity).',
        },
        {
          't': 'Step 2: Hydro & Chemotropism',
          'i':
              'CLICK Target ② for water-seeking roots and Target ③ for pollen tube growth to ovule.',
          'o':
              'Roots seek water; pollen tube grows toward chemical stimulus from ovule.',
        },
        {
          't': 'Step 3: Tendril Differential Growth',
          'i':
              'CLICK Target ④ to watch tendril coil 360° around the support stick.',
          'o':
              'Contact side grows slower than the far side, causing the tendril to circle and cling.',
        },
      ],
      [
        {
          't': 'Step 1: Type Sorting',
          'i':
              'CLICK on specimen tokens to sort them into Growth-Independent vs Growth-Dependent pots.',
          'o':
              'Mimosa is Growth-Independent (Fast); Phototropism, Geotropism, and Tendril are Growth-Dependent.',
        },
        {
          't': 'Step 2: Live Speed Race',
          'i':
              "CLICK 'START SPEED RACE' to watch all 3 movements race with active timers.",
          'o':
              'Sensitive-plant touch (0.5s Fast) → Sunflower day/night (3s) → Growth movement (10s Slowest).',
        },
      ],
    ],
    'conclusions': [
      {
        'h': 'Immediate Response (Mimosa)',
        'p':
            'The sensitive plant (chhui-mui) touch response operates completely [e]without growth[/]. Electrical-chemical signals communicate information cell-to-cell, and cells alter their shape by rapidly [s]changing water content[/] (swelling or shrinking).',
      },
      {
        'h': 'Phototropism Verified',
        'p':
            'Shoots bend [s]towards light[/] while roots bend [a]away from light[/]. The plant hormone [A]Auxin[/] synthesised at the shoot tip diffuses to the shady side, stimulating cells to grow longer on that side.',
      },
      {
        'h': 'Directional Tropisms & Tendrils',
        'p':
            'Plants show directional growth: [e]Geotropism[/] (gravity), [s]Hydrotropism[/] (water), and [p]Chemotropism[/] (pollen tube to ovule). Tendrils coil because the side in contact with support grows slower than the outer side.',
      },
      {
        'h': 'Movement Classification & Speed',
        'p':
            'Plant movements are either [S]Growth-Independent[/] (immediate, e.g. Mimosa) or [e]Growth-Dependent[/] (directional, e.g. tropisms). Speeds range from fastest (Mimosa touch ~0.5s) to slowest (growth tropisms ~days).',
      },
    ],
    'final': {
      'p':
          'Plants coordinate responses through two main mechanisms: [S]immediate growth-independent movements[/] driven by cellular water turgor changes (e.g., sensitive plant [i]Mimosa[/]), and [e]slow growth-dependent directional movements (tropisms)[/] mediated by plant hormones like [a]Auxin[/].',
      'b': [
        '• [s]No Nervous System:[/] Information is conveyed cell-to-cell via electrical-chemical pulses.',
        '• [a]Hormonal Control:[/] Auxin (elongation), Gibberellins (stem growth), Cytokinins (cell division), and Abscisic acid (growth inhibition).',
        '• [E]Speed Hierarchy:[/] Mimosa leaf folding (fastest, ~0.5s) → Sunflower tracking → Directional growth tropisms (slowest).',
      ],
    },
    'hud': {
      's1_ready':
          'Click Target Pins ①② on the Mimosa plant to observe immediate touch response.',
      's2_ready':
          'Click Target Pin ① (Window) and Pin ② (Auxin Lens) to observe Phototropism.',
      's3_ready':
          'Click Target Pins ①②③④ to observe Geotropism, Hydrotropism, Chemotropism, and Tendril.',
      's4_ready':
          'Click specimen tokens to classify into pots and run the Live Speed Race.',
      'touchVerified':
          'Touch Stimulus Verified: Leaflets folded and petiole drooped without growth!',
      'waterVerified':
          'Water-Change Verified: Cells change shape by shrinking/swelling!',
      'photoVerified':
          'Light Stimulus Active: Shoot curves toward light, root bends away!',
      'auxinVerified':
          'Auxin Hormone Verified: Diffuses to shady side stimulating elongation!',
      'geoVerified': 'Geotropism Verified: Root down / Shoot up vs Gravity.',
      'hydroVerified':
          'Hydrotropism Verified: Root curves toward water stimulus.',
      'chemoVerified':
          'Chemotropism Verified: Pollen tube grows through style to ovule.',
      'tendrilVerified':
          'Tendril Verified: Contact side grows slower causing 360° coiling.',
      'allClassified': 'All movements correctly classified!',
      'fb_folded': 'Folded',
      'fb_waterLoss': 'Water Loss Verified',
      'fb_photoActive': 'Phototropism Active',
      'fb_auxinDiffused': 'Auxin Diffused',
      'fb_gravity': 'Gravity Verified',
      'fb_moisture': 'Moisture Seeking',
      'fb_chemical': 'Chemical Response',
      'fb_differential': 'Differential Growth',
      'fb_classified': 'All Classified!',
      'fb_ready': 'Ready',
      'race_ready_mimosa': 'Ready (0.5s Fast)',
      'race_ready_sunflower': 'Ready (3.0s Daily)',
      'race_ready_growth': 'Ready (10.0s Tropism)',
      'race_done_mimosa': 'FINISHED (0.5s - Fast!)',
      'race_done_sunflower': 'FINISHED (3.0s - Daily)',
      'race_done_growth': 'FINISHED (Days - Growth)',
    },
    'canvas': {
      'c_module1_bottom':
          'Click Target Pins ①② Or Plant Hotspots to Observe Immediate Response',
      'c_module2_bottom':
          'Click Window (Pin ①) or Auxin Lens (Pin ②) to Observe Phototropism',
      'c_module3_bottom':
          'Click Any Of The 4 Target Pins to Observe Directional Tropic Growth',
      'c_module4_bottom':
          'Classify Specimens into Pots and Run the Live Speed Race Track',
      'c_touchStim': 'TOUCH STIMULUS',
      'c_leafletsFold': 'LEAFLETS FOLD/DROOP (FAST)',
      'c_noGrowthInv': 'NO GROWTH INVOLVED',
      'c_infoComm':
          'INFORMATION COMMUNICATED CELL-TO-CELL (ELECTRICAL-CHEMICAL)',
      'c_infoCommDesc':
          'Plants convey electrical-chemical information cell-to-cell without specialized nerve tissue.',
      'c_cellsChangeWater': 'CELLS CHANGE SHAPE BY CHANGING WATER CONTENT',
      'c_cellsChangeWaterDesc':
          'Cells change shape by swelling (taking in water) or shrinking (losing water).',
      'c_lightStim': 'LIGHT STIMULUS',
      'c_lightAtSource': 'LIGHT AT SOURCE',
      'c_shootBends': 'SHOOT BENDS TOWARD LIGHT',
      'c_rootBendsAway': 'ROOT BENDS AWAY',
      'c_auxinHormone':
          'AUXIN HORMONE (DIFFUSES TO SHADY SIDE, STIMULATES ELONGATION)',
      'c_shadySide': 'SHADY SIDE',
      'c_geotropism': '1) Geotropism',
      'c_gravity': 'GRAVITY',
      'c_shootUp': 'SHOOT UP',
      'c_hydrotropism': '2) Hydrotropism',
      'c_waterStim': 'WATER STIMULUS',
      'c_rootGrowsWater': 'ROOT GROWS TOWARD WATER',
      'c_chemotropism': '3) Chemotropism',
      'c_chemStim': 'CHEMICAL STIMULUS',
      'c_pollenTubeOvule': 'POLLEN TUBE GROWS TOWARD OVULE',
      'c_tendrilTitle': '4) Tendril',
      'c_diffGrowth': 'DIFFERENTIAL GROWTH',
      'c_contactSlower': 'CONTACT SIDE GROWS MORE SLOWLY THAN FAR SIDE',
      'c_typeSorting': '1) Type Sorting',
      'c_growthIndep': 'GROWTH-INDEPENDENT (FAST)',
      'c_growthDep': 'GROWTH-DEPENDENT (SLOW/DIRECTIONAL)',
      'c_mimosaFold': 'MIMOSA LEAFLET FOLD',
      'c_photoBend': 'PHOTOTROPIC BEND',
      'c_geoRoot': 'GEOTROPIC ROOT',
      'c_tendrilCoilToken': 'TENDRIL COIL',
      'c_clickMimosaPlaceholder': 'Click Mimosa Token',
      'c_clickTropicPlaceholder': 'Click Tropic Tokens',
      'c_speedOrderTitle': '2) Speed Order',
      'c_touchMeNotChip': 'TOUCH-ME-NOT TOUCH',
      'c_sunflowerChip': 'SUNFLOWER DAY/NIGHT',
      'c_growthMovChip': 'GROWTH MOVEMENT',
    },
  },
  'hi': {
    'title': 'पौधों में समन्वय',
    'subtitle': 'कक्षा 10 • नियंत्रण एवं समन्वय',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'moduleSel': 'मॉड्यूल का चयन करें',
    'sciObs': 'वैज्ञानिक निष्कर्ष',
    'settings': 'सेटिंग्स',
    'txtScale': 'टेक्स्ट स्केलिंग',
    'missionReady': 'मिशन सक्रिय',
    'missionObj': 'मिशन उद्देश्य',
    'taskInstr': 'कार्य निर्देश:',
    'expOut': 'अपेक्षित परिणाम:',
    'btnOk': 'ठीक है',
    'btnRestartLab': 'वर्चुअल लैब पुनः आरंभ करें',
    'finalTitle': 'हमने इस अवधारणा में क्या समझा और क्या सीखा',
    'startSpeedRaceBtn': 'गति रेस शुरू करें',
    'tooltips': {
      'toggleLock': 'लॉक टॉगल करें',
      'toggleLabels': 'लेबल टॉगल करें',
    },
    'titles': [
      '1. STEP 1: तत्काल अनुक्रिया (छुई-मुई)',
      '2. STEP 2: प्रकाशानुवर्तन (वृद्धि पर निर्भर)',
      '3. STEP 3: अन्य अनुवर्तन एवं प्रतान',
      '4. STEP 4: वर्गीकरण एवं तुलना',
    ],
    'objs': [
      'यह समझना कि छुई-मुई की पत्तियां बिना वृद्धि के स्पर्श पर कैसे झुकती हैं और जल परिवर्तन द्वारा संदेश कैसे भेजा जाता है।',
      'प्रकाशानुवर्तन का प्रदर्शन करना और यह देखना कि प्ररोह शीर्ष पर बना ऑक्सिन छाया वाले भाग में विसरित होकर मुड़ने में कैसे मदद करता है।',
      'गुरुत्वानुवर्तन, जलानुवर्तन, रसायनानुवर्तन (पराग नलिका) और प्रतान में स्पर्श-संवेदी असमान वृद्धि का अध्ययन करना।',
      'पादप गतियों को वृद्धि पर निर्भर एवं वृद्धि से मुक्त श्रेणियों में वर्गीकृत करना तथा उनकी गति को क्रमबद्ध करना।',
    ],
    'steps': [
      [
        {
          't': 'Step 1: स्पर्श उद्दीपन',
          'i':
              'पिन ① (या हाथ) पर क्लिक करके पत्तियों को मुड़ते और झुकते देखें।',
          'o':
              'पत्तियां बिना किसी वृद्धि के तुरंत मुड़ जाती हैं और पर्णवृंत झुक जाता है।',
        },
        {
          't': 'Step 2: जल परिवर्तन क्रियाविधि',
          'i': 'पिन ② पर क्लिक करके पर्णाधार में जल परिवर्तन देखें।',
          'o': 'कोशिकाएं जल की मात्रा बदलकर फूलती या सिकुड़ती हैं।',
        },
      ],
      [
        {
          't': 'Step 1: प्रकाश उद्दीपन',
          'i': 'खिड़की (पिन ①) पर क्लिक करके प्ररोह पर प्रकाश डालें।',
          'o':
              'खिड़की से आने वाला एकतरफा प्रकाश प्ररोह पर पड़ता है, जिससे वह मुड़ता है।',
        },
        {
          't': 'Step 2: ऑक्सिन विसरण',
          'i':
              'ऑक्सिन लेंस (पिन ②) पर क्लिक करके छाया वाले भाग में ऑक्सिन देखें।',
          'o':
              'शीर्ष पर बना ऑक्सिन छाया वाले भाग में विसरित होकर कोशिकाओं को लंबा करता है।',
        },
      ],
      [
        {
          't': 'Step 1: गुरुत्वानुवर्तन',
          'i': 'पिन ① पर क्लिक करके गमले को झुकाएं।',
          'o': 'जड़ नीचे की ओर और प्ररोह ऊपर की ओर बढ़ता है।',
        },
        {
          't': 'Step 2: जल व रसायनानुवर्तन',
          'i': 'पिन ② (जल) और पिन ③ (रसायन/बीजांड) पर क्लिक करें।',
          'o': 'जड़ जल की ओर तथा पराग नलिका बीजांड की ओर बढ़ती है।',
        },
        {
          't': 'Step 3: प्रतान का लिपटना',
          'i': 'पिन ④ पर क्लिक करके प्रतान को लिपटते देखें।',
          'o':
              'सहारे के संपर्क वाला भाग कम तेजी से बढ़ता है, जिससे प्रतान लिपट जाता है।',
        },
      ],
      [
        {
          't': 'Step 1: प्रकार वर्गीकरण',
          'i': 'टोकनों पर क्लिक करके उन्हें सही गमले में वर्गीकृत करें।',
          'o':
              'छुई-मुई वृद्धि से मुक्त है; प्रकाशानुवर्तन, गुरुत्वानुवर्तन और प्रतान वृद्धि पर निर्भर हैं।',
        },
        {
          't': 'Step 2: गति रेस',
          'i': "'START SPEED RACE' पर क्लिक करके सजीव रेस चलाएं।",
          'o':
              'छुई-मुई (0.5s अति तीव्र) → सूरजमुखी (3s) → वृद्धि गतियां (10s सर्वाधिक धीमी)।',
        },
      ],
    ],
    'conclusions': [
      {
        'h': 'तत्काल अनुक्रिया (छुई-मुई)',
        'p':
            'छुई-मुई की स्पर्श अनुक्रिया पूरी तरह [e]वृद्धि से मुक्त[/] होती है। सूचना विद्युत-रासायनिक माध्यम से पहुंचती है और कोशिकाएं [s]जल की मात्रा बदलकर[/] आकार बदलती हैं।',
      },
      {
        'h': 'प्रकाशानुवर्तन सत्यापन',
        'p':
            'प्ररोह [s]प्रकाश की ओर[/] तथा जड़ें [a]प्रकाश से दूर[/] मुड़ती हैं। प्ररोह शीर्ष पर बना [A]ऑक्सिन हॉर्मोन[/] छाया वाले भाग में विसरित होकर कोशिकाओं को लंबा करता है।',
      },
      {
        'h': 'दैशिक अनुवर्तन एवं प्रतान',
        'p':
            'पौधे दैशिक वृद्धि दर्शाते हैं: [e]गुरुत्वानुवर्तन[/] (गुरुत्व), [s]जलानुवर्तन[/] (जल), एवं [p]रसायनानुवर्तन[/] (बीजांड की ओर पराग नलिका)। प्रतान का संपर्क भाग धीमा बढ़ता है जिससे वह लिपट जाता है।',
      },
      {
        'h': 'पादप गतियों का वर्गीकरण एवं गति',
        'p':
            'पादप गतियां [S]वृद्धि से मुक्त[/] (जैसे छुई-मुई) या [e]वृद्धि पर निर्भर[/] (अनुवर्तन) होती हैं। गति दर छुई-मुई (तीव्रतम ~0.5s) से लेकर वृद्धि गतियों (दिनों में) तक होती है।',
      },
    ],
    'final': {
      'p':
          'पौधे दो मुख्य प्रणालियों द्वारा समन्वय स्थापित करते हैं: [S]वृद्धि से मुक्त तत्काल गतियां[/] जो कोशिकीय जल परिवर्तन द्वारा संचालित होती हैं (जैसे छुई-मुई), और [e]वृद्धि पर निर्भर दैशिक गतियां (अनुवर्तन)[/] जो [a]ऑक्सिन[/] जैसे पादप हॉर्मोन द्वारा नियंत्रित होती हैं।',
      'b': [
        '• [s]तंत्रिका ऊतक का अभाव:[/] सूचना विद्युत-रासायनिक माध्यम द्वारा कोशिका-दर-कोशिका पहुंचती है।',
        '• [a]पादप हॉर्मोन:[/] ऑक्सिन (दीर्घीकरण), जिब्बेरेलिन (तना वृद्धि), साइटोकाइनिन (कोशिका विभाजन), एब्सिसिक अम्ल (वृद्धि संदमन)।',
        '• [E]गति पदानुक्रम:[/] छुई-मुई मुड़ना (तीव्रतम, ~0.5s) → सूरजमुखी → दैशिक वृद्धि (धीमी)।',
      ],
    },
    'hud': {
      's1_ready':
          'छुई-मुई के पौधे पर पिन ①② पर क्लिक करके तत्काल स्पर्श अनुक्रिया देखें।',
      's2_ready':
          'प्रकाशानुवर्तन देखने के लिए पिन ① (खिड़की) और पिन ② (ऑक्सिन लेंस) पर क्लिक करें।',
      's3_ready':
          'गुरुत्वानुवर्तन, जलानुवर्तन, रसायनानुवर्तन और प्रतान देखने के लिए पिन ①②③④ पर क्लिक करें।',
      's4_ready': 'टोकनों को गमलों में वर्गीकृत करें और सजीव गति रेस चलाएं।',
      'touchVerified':
          'स्पर्श उद्दीपन सत्यापित: बिना वृद्धि के पत्तियां मुड़ गईं और पर्णवृंत झुक गया!',
      'waterVerified':
          'जल परिवर्तन सत्यापित: जल की मात्रा बदलकर कोशिकाओं ने आकार बदला!',
      'photoVerified':
          'प्रकाश उद्दीपन सक्रिय: प्ररोह प्रकाश की ओर तथा जड़ प्रकाश से दूर मुड़ती है!',
      'auxinVerified':
          'ऑक्सिन हॉर्मोन सत्यापित: छाया वाले भाग में विसरित होकर कोशिकाओं को लंबा करता है!',
      'geoVerified':
          'गुरुत्वानुवर्तन सत्यापित: जड़ गुरुत्व की ओर (नीचे) / प्ररोह ऊपर बढ़ता है।',
      'hydroVerified': 'जलानुवर्तन सत्यापित: जड़ जल स्रोत की ओर मुड़ती है।',
      'chemoVerified':
          'रसायनानुवर्तन सत्यापित: पराग नलिका बीजांड की ओर बढ़ती है।',
      'tendrilVerified':
          'प्रतान सत्यापित: संपर्क भाग धीमा बढ़ने से प्रतान 360° लिपट जाता है।',
      'allClassified': 'सभी पादप गतियां सही ढंग से वर्गीकृत!',
      'fb_folded': 'मुड़ गई',
      'fb_waterLoss': 'जल परिवर्तन सत्यापित',
      'fb_photoActive': 'प्रकाशानुवर्तन सक्रिय',
      'fb_auxinDiffused': 'ऑक्सिन विसरित',
      'fb_gravity': 'गुरुत्वानुवर्तन सत्यापित',
      'fb_moisture': 'जल की ओर',
      'fb_chemical': 'रासायनिक अनुक्रिया',
      'fb_differential': 'असमान वृद्धि',
      'fb_classified': 'सभी वर्गीकृत!',
      'fb_ready': 'तैयार',
      'race_ready_mimosa': 'तैयार (0.5s तीव्र)',
      'race_ready_sunflower': 'तैयार (3.0s दैनिक)',
      'race_ready_growth': 'तैयार (10.0s वृद्धि)',
      'race_done_mimosa': 'समाप्त (0.5s - अति तीव्र!)',
      'race_done_sunflower': 'समाप्त (3.0s - दैनिक)',
      'race_done_growth': 'समाप्त (दिनों में - वृद्धि)',
    },
    'canvas': {
      'c_module1_bottom':
          'तत्काल अनुक्रिया देखने के लिए पिन ①② या पौधे के हॉटस्पॉट पर क्लिक करें',
      'c_module2_bottom':
          'प्रकाशानुवर्तन देखने के लिए खिड़की (पिन ①) या ऑक्सिन लेंस (पिन ②) पर क्लिक करें',
      'c_module3_bottom':
          'दैशिक अनुवर्तन देखने के लिए चारों में से किसी भी पिन पर क्लिक करें',
      'c_module4_bottom':
          'नमूनों को गमलों में वर्गीकृत करें और सजीव गति रेस ट्रैक चलाएं',
      'c_touchStim': 'स्पर्श उद्दीपन',
      'c_leafletsFold': 'पत्तियां मुड़ती/झुकती हैं (तीव्र)',
      'c_noGrowthInv': 'वृद्धि से मुक्त',
      'c_infoComm': 'सूचना का संवहन कोशिका-दर-कोशिका (विद्युत-रासायनिक)',
      'c_infoCommDesc':
          'पौधे तंत्रिका ऊतक के बिना कोशिका-दर-कोशिका विद्युत-रासायनिक संदेश भेजते हैं।',
      'c_cellsChangeWater': 'जल की मात्रा बदलकर कोशिकाओं के आकार में परिवर्तन',
      'c_cellsChangeWaterDesc':
          'कोशिकाएं जल लेकर फूलती हैं या जल खोकर सिकुड़ती हैं।',
      'c_lightStim': 'प्रकाश उद्दीपन',
      'c_lightAtSource': 'स्रोत पर प्रकाश',
      'c_shootBends': 'प्ररोह प्रकाश की ओर मुड़ता है',
      'c_rootBendsAway': 'जड़ प्रकाश से दूर मुड़ती है',
      'c_auxinHormone':
          'ऑक्सिन हॉर्मोन (छाया वाले भाग में विसरित होकर वृद्धि करता है)',
      'c_shadySide': 'छाया वाला भाग',
      'c_geotropism': '1) गुरुत्वानुवर्तन',
      'c_gravity': 'गुरुत्वाकर्षण',
      'c_shootUp': 'प्ररोह ऊपर',
      'c_hydrotropism': '2) जलानुवर्तन',
      'c_waterStim': 'जल उद्दीपन',
      'c_rootGrowsWater': 'जड़ जल की ओर बढ़ती है',
      'c_chemotropism': '3) रसायनानुवर्तन',
      'c_chemStim': 'रासायनिक उद्दीपन',
      'c_pollenTubeOvule': 'पराग नलिका बीजांड की ओर बढ़ती है',
      'c_tendrilTitle': '4) प्रतान',
      'c_diffGrowth': 'असमान वृद्धि',
      'c_contactSlower': 'संपर्क वाला भाग दूर वाले भाग से धीमा बढ़ता है',
      'c_typeSorting': '1) प्रकार वर्गीकरण',
      'c_growthIndep': 'वृद्धि से मुक्त (तीव्र)',
      'c_growthDep': 'वृद्धि पर निर्भर (धीमी/दैशिक)',
      'c_mimosaFold': 'छुई-मुई पत्ती का मुड़ना',
      'c_photoBend': 'प्रकाशानुवर्ती मुड़ाव',
      'c_geoRoot': 'गुरुत्वानुवर्ती जड़',
      'c_tendrilCoilToken': 'प्रतान का लिपटना',
      'c_clickMimosaPlaceholder': 'छुई-मुई टोकन पर क्लिक करें',
      'c_clickTropicPlaceholder': 'अनुवर्ती टोकन पर क्लिक करें',
      'c_speedOrderTitle': '2) गति क्रम',
      'c_touchMeNotChip': 'छुई-मुई स्पर्श',
      'c_sunflowerChip': 'सूरजमुखी दिन/रात',
      'c_growthMovChip': 'वृद्धि गति',
    },
  },
});

String _c(String key) => _tx.s('canvas.$key');
String _h(String key) => _tx.s('hud.$key');

// --- Source CSS variables / Tailwind colours (dark theme) -------------------
const _accent = _rt_Tw.sky400; // --accent
const _accentHover = Color(0xFF0284C7); // --accent-hover
const _panel = Color(0xFF0B152D); // --bg-panel (SVG fills)
const _cardBg = Color(0xBF0F172A); // --bg-card rgba(15,23,42,.75)
const _border = Color(0xFF1E293B); // --border
const _svgText = Color(0xFFF8FAFC); // --svg-text / --text-main
const _muted = Color(0xFF94A3B8); // --text-muted
const _svgCardBg = Color(0xFF0F172A); // --svg-card-bg
const _sky300 = Color(0xFF7DD3FC);
const _amber300 = Color(0xFFFCD34D);
const _emerald300 = Color(0xFF6EE7B7);
const _pink400 = Color(0xFFF472B6);
const _purple300 = Color(0xFFD8B4FE);
const _purple400 = Color(0xFFC084FC);

/// Lane durations of the speed race in seconds (mimosa, sunflower, growth).
const _raceDur = [0.5, 3.0, 10.0];

/// canvas-confetti's default palette.
const _confettiColors = [
  Color(0xFF26CCFF),
  Color(0xFFA25AFD),
  Color(0xFFFF5E7E),
  Color(0xFF88FF5A),
  Color(0xFFFCFF42),
  Color(0xFFFFA62D),
  Color(0xFFFF36FF),
];

/// HUD feedback pill style (source `updateHUD` type).
enum _Fb { info, success }

/// What the current scene render shows. The source re-renders the scene from
/// scratch on every module load, so this is reset there while the progress
/// flags (`prog1..4`, `completedModules`) persist.
class _Vis {
  double? fold, wave, pulv; // module 1 tween start times (s)
  double? light, auxin, shady; // module 2
  double? geo, hydro, chemo, tendril; // module 3
  final Set<String> placed = {}; // pins drawn as used
  final Set<String> hiddenTokens = {}; // module 4 tokens already sorted
  bool mimosaInPot = false;
  final List<String> depChips = [];
}

class Cl10SCh06A4CoordinationInPlantsPage extends StatefulWidget {
  const Cl10SCh06A4CoordinationInPlantsPage({super.key});

  @override
  State<Cl10SCh06A4CoordinationInPlantsPage> createState() =>
      _Cl10SCh06A4CoordinationInPlantsPageState();
}

class _Cl10SCh06A4CoordinationInPlantsPageState
    extends State<Cl10SCh06A4CoordinationInPlantsPage>
    with SingleTickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final TransformationController _cam = TransformationController();
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker;
  final GlobalKey _hudKey = GlobalKey();
  final List<Timer> _timers = [];

  /// Bumped on restart so pending delayed callbacks bail out.
  int _gen = 0;

  /// Re-keys the shell on restart so its intro curtain shows again (the
  /// source's `resetLab` brings the curtain back down).
  int _shellGen = 0;

  // --- source `state` ---
  int _scenario = 1;
  final Map<int, bool> _completed = {1: false, 2: false, 3: false, 4: false};
  bool _touched = false, _water = false; // prog1
  bool _light = false, _auxin = false; // prog2
  bool _geo = false, _hydro = false, _chemo = false, _tendril = false; // prog3
  final Map<String, bool> _sorted = {
    'mimosa': false,
    'photo': false,
    'geo': false,
    'tendril': false,
  };

  _Vis _vis = _Vis();
  final Set<int> _collapsed = {};

  // Speed race. Like the GSAP tweens, a race keeps running when the scene is
  // re-rendered; the lanes on screen only follow a race started in this render.
  double? _raceT0;
  List<bool> _raceFired = [false, false, false];
  bool _raceShown = false;
  List<bool> _laneDone = [false, false, false];

  // HUD (`#action-hud`).
  String _hudInstr = 's1_ready', _hudFb = 'fb_ready';
  _Fb _hudType = _Fb.info;
  Offset? _hudPos;
  double _hudH = 104;
  bool _hudMeasureQueued = false;

  // Popups and confetti.
  int? _obs;
  Offset _obsOff = Offset.zero;
  bool _final = false;
  Offset _finalOff = Offset.zero;
  final List<_Burst> _bursts = [];
  int _burstSeed = 1;

  // Viewport tools and settings.
  int _zoomStep = 10; // scale x10 (source 0.7 .. 2.0 in 0.1 steps)
  bool _locked = true;
  bool _labels = true;
  Size _canvasSize = const Size(615, 412);
  double _fontPx = 18;

  static const double _barH = 28;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    for (final t in _timers) {
      t.cancel();
    }
    _ticker.dispose();
    _cam.dispose();
    _clock.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ clock ---
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    _clock.value = now;
    final t0 = _raceT0;
    if (t0 != null) {
      for (var i = 0; i < 3; i++) {
        if (_raceFired[i] || now - t0 < _raceDur[i]) continue;
        _raceFired[i] = true;
        _rt_playSfx(
          _rt_Sfx.pop,
        ); // silent in the source: a lane crossing the line
        if (_raceShown) setState(() => _laneDone[i] = true);
        if (i == 2) {
          _completed[4] = true;
          _later(1000, () {
            _showObs(4);
            _confetti(150, 90, 0.5);
          });
        }
      }
    }
    if (_bursts.isNotEmpty && _bursts.any((b) => now - b.t0 > 3.5)) {
      setState(() => _bursts.removeWhere((b) => now - b.t0 > 3.5));
    }
  }

  void _later(int ms, VoidCallback fn) {
    final g = _gen;
    late final Timer t;
    t = Timer(Duration(milliseconds: ms), () {
      _timers.remove(t);
      if (!mounted || g != _gen) return;
      fn();
    });
    _timers.add(t);
  }

  void _confetti(int count, double spread, double originY) {
    setState(
      () => _bursts.add(
        _Burst(_clock.value, count, spread, originY, _burstSeed++),
      ),
    );
  }

  // -------------------------------------------------------------- HUD ---
  void _setHud(String instr, String fb, [_Fb type = _Fb.success]) {
    _hudInstr = instr;
    _hudFb = fb;
    _hudType = type;
  }

  void _measureHud() {
    _hudMeasureQueued = false;
    if (!mounted) return;
    final box = _hudKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final h = box.size.height;
    if ((h - _hudH).abs() > 0.5) setState(() => _hudH = h);
  }

  // ---------------------------------------------------------- modules ---
  /// Source `loadScenario`: closes the popups, resets the camera, re-renders
  /// the scene and the teacher board, and shows the module's ready HUD.
  void _loadScenario(int n, {bool silent = false}) {
    if (!silent) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _scenario = n;
      _obs = null;
      _final = false;
      _resetCamValues();
      _vis = _Vis();
      _collapsed.clear();
      _raceShown = false;
      _laneDone = [false, false, false];
      _setHud('s${n}_ready', 'fb_ready', _Fb.info);
    });
  }

  /// Source `triggerNeutralPin`.
  void _pin(int pin) {
    final now = _clock.value;
    final v = _vis;
    switch (_scenario) {
      case 1:
        if (pin == 1) {
          _rt_playSfx(_rt_Sfx.pop); // source 'fold'
          _touched = true;
          setState(() {
            v.fold ??= now;
            v.wave = now;
            v.placed.add('s1-1');
            _setHud('touchVerified', 'fb_folded');
          });
        } else {
          _rt_playSfx(_rt_Sfx.magic);
          _water = true;
          setState(() {
            v.pulv ??= now;
            v.placed.add('s1-2');
            _setHud('waterVerified', 'fb_waterLoss');
          });
        }
        if (_touched && _water) _moduleDone(1);
      case 2:
        if (pin == 1) {
          _rt_playSfx(_rt_Sfx.correct); // source 'growth'
          _light = true;
          setState(() {
            v.light ??= now;
            v.placed.add('s2-1');
            _setHud('photoVerified', 'fb_photoActive');
          });
        } else {
          _rt_playSfx(_rt_Sfx.magic);
          _auxin = true;
          setState(() {
            v.auxin = now;
            v.shady ??= now;
            v.placed.add('s2-2');
            _setHud('auxinVerified', 'fb_auxinDiffused');
          });
        }
        if (_light && _auxin) _moduleDone(2);
      case 3:
        _rt_playSfx(_rt_Sfx.magic);
        setState(() {
          switch (pin) {
            case 1:
              _geo = true;
              v.geo ??= now;
              _setHud('geoVerified', 'fb_gravity');
            case 2:
              _hydro = true;
              v.hydro ??= now;
              _setHud('hydroVerified', 'fb_moisture');
            case 3:
              _chemo = true;
              v.chemo = now;
              _setHud('chemoVerified', 'fb_chemical');
            default:
              _tendril = true;
              v.tendril = now;
              _setHud('tendrilVerified', 'fb_differential');
          }
          v.placed.add('s3-$pin');
        });
        if (_geo && _hydro && _chemo && _tendril) _moduleDone(3);
    }
  }

  /// Source `checkModuleNComplete`: fires on every pin tap once all of the
  /// module's pins are done, so a later tap shows the conclusion again.
  void _moduleDone(int n) {
    _completed[n] = true;
    _later(800, () {
      _showObs(n);
      _confetti(90, 70, 0.6);
    });
  }

  /// Source `clickToken`: any tap sorts the token into its own pot.
  void _clickToken(String type) {
    _rt_playSfx(_rt_Sfx.pop); // source 'click'
    _sorted[type] = true;
    setState(() {
      _vis.hiddenTokens.add(type);
      if (type == 'mimosa') {
        _vis.mimosaInPot = true;
      } else {
        _vis.depChips.add(type);
      }
    });
    if (_sorted.values.every((s) => s)) {
      _rt_playSfx(_rt_Sfx.correct); // source 'success'
      setState(() => _setHud('allClassified', 'fb_classified'));
    }
  }

  /// Source `startSpeedRace` (any time; it restarts the lanes from zero).
  void _startRace() {
    _rt_playSfx(_rt_Sfx.magic); // source 'success'
    setState(() {
      _raceT0 = _clock.value;
      _raceFired = [false, false, false];
      _raceShown = true;
    });
  }

  // ------------------------------------------------------------ popups ---
  void _showObs(int n) {
    _rt_playSfx(_rt_Sfx.success);
    setState(() => _obs = n);
  }

  void _closeObs() {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _obs = null);
  }

  /// Source `confirmStepObservation`.
  void _confirmObs() {
    setState(() => _obs = null);
    if (_completed.values.every((d) => d)) {
      _rt_playSfx(_rt_Sfx.tap);
      _later(500, _showFinal);
    } else if (_scenario < 4) {
      _loadScenario(_scenario + 1);
    } else {
      _rt_playSfx(_rt_Sfx.tap);
    }
  }

  void _showFinal() {
    _rt_playSfx(_rt_Sfx.success);
    _confetti(160, 90, 0.5);
    setState(() => _final = true);
  }

  void _closeFinal() {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _final = false);
  }

  // ------------------------------------------------------------- tools ---
  void _zoomBy(int d) {
    final next = (_zoomStep + d).clamp(7, 20);
    if (next == _zoomStep) return;
    final f = next / _zoomStep;
    final c = _canvasSize.center(Offset.zero);
    _cam.value = Matrix4.translationValues(c.dx, c.dy, 0)
        .multiplied(Matrix4.diagonal3Values(f, f, 1))
        .multiplied(Matrix4.translationValues(-c.dx, -c.dy, 0))
        .multiplied(_cam.value);
    _zoomStep = next;
  }

  void _resetCamValues() {
    _cam.value = Matrix4.identity();
    _zoomStep = 10;
  }

  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _locked = !_locked);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labels = !_labels);
  }

  /// Source `resetLab` (header reset and the final card's Restart button).
  /// The app's language is a global setting, so it is not forced back to
  /// English here.
  void _restart() {
    _gen++;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    setState(() {
      _shellGen++;
      _fontPx = 18;
      _locked = true;
      _labels = true;
      _resetCamValues();
      _completed.updateAll((_, _) => false);
      _touched = _water = _light = _auxin = false;
      _geo = _hydro = _chemo = _tendril = false;
      _sorted.updateAll((_, _) => false);
      _raceT0 = null;
      _raceFired = [false, false, false];
      _bursts.clear();
      _obs = null;
      _final = false;
      _hudPos = null;
      _scenario = 1;
      _vis = _Vis();
      _collapsed.clear();
      _raceShown = false;
      _laneDone = [false, false, false];
      _setHud('s1_ready', 'fb_ready', _Fb.info);
    });
  }

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          if (!_hudMeasureQueued) {
            _hudMeasureQueued = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => _measureHud());
          }
          return _rt_ActivityShell(
            key: ValueKey('shell-$_shellGen'),
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.sky500,
              headerGradient: [_rt_Tw.slate950, Color(0xFF0C4A6E)],
              headerSubtitleColor: _rt_Tw.sky400,
            ),
            canvasBackground: const Color(0xFF020617),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.eco,
              buttonIcon: Icons.arrow_forward,
            ),
            onRestart: _restart,
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
            onResetView: _resetCamValues,
            toolbarExtras: [
              _toolBtn(
                key: const ValueKey('tool-lock'),
                icon: _locked ? Icons.lock : Icons.lock_open,
                tip: _tx.s('tooltips.toggleLock'),
                color: _locked ? _accent : _rt_Tw.amber400,
                active: !_locked,
                onTap: _toggleLock,
              ),
              const SizedBox(height: 4),
              _toolBtn(
                key: const ValueKey('tool-labels'),
                icon: _labels ? Icons.label : Icons.label_off_outlined,
                tip: _tx.s('tooltips.toggleLabels'),
                color: _labels ? _accent : _rt_Lab.textMuted,
                active: _labels,
                onTap: _toggleLabels,
              ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('moduleSel'),
                icon: Icons.science,
                builder: _sidebar,
              ),
            ],
            canvas: _canvas(),
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
    required Color color,
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
            color: active ? color.withValues(alpha: 0.16) : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ canvas ---
  Widget _canvas() {
    return LayoutBuilder(
      builder: (context, c) {
        _canvasSize = c.biggest;
        return Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _BackdropPainter()),
            ),
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _cam,
                // The source's lock defaults on; unlocked, the scene pans and pinches.
                panEnabled: !_locked,
                scaleEnabled: !_locked,
                minScale: 0.7,
                maxScale: 2.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                onInteractionEnd: (_) => _zoomStep =
                    (_cam.value.getMaxScaleOnAxis() * 10).round().clamp(7, 20),
                child: _rt_MinWidthGate(minWidth: 280, child: _scene()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _scene() {
    // The menu button floats over the canvas' top-left once the sidebar closes.
    final leftPad = _shell.isSidebarOpen ? 16.0 : 72.0;
    final bottoms = [
      'c_module1_bottom',
      'c_module2_bottom',
      'c_module3_bottom',
      'c_module4_bottom',
    ];
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(leftPad, 10, 64, 0),
          child: _sceneHeader(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Container(height: 1, color: _border),
        ),
        Expanded(
          child: Padding(
            // Right: the canvas toolbar. Bottom: room for the floating HUD.
            padding: EdgeInsets.fromLTRB(16, 8, 60, _hudH + 12),
            // Each module is laid out at a design width and fitted into the
            // space left (shrunk on phones, grown up to 1.3x on tablets).
            child: LayoutBuilder(
              builder: (context, b) {
                final dw = b.maxWidth.clamp(560.0, 760.0);
                return Center(
                  child: SizedBox(
                    width: math.min(b.maxWidth, dw * 1.3),
                    height: b.maxHeight,
                    child: FittedBox(
                      child: SizedBox(width: dw, child: _body()),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          height: _barH,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Text(
            _c(bottoms[_scenario - 1]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: _muted,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sceneHeader() {
    const badges = [
      ('MODULE 1', _rt_Tw.sky400),
      ('MODULE 2', _rt_Tw.amber400),
      ('MODULE 3', _rt_Tw.cyan400),
      ('MODULE 4', _purple400),
    ];
    final (badge, color) = badges[_scenario - 1];
    return Row(
      children: [
        _pinBadge('$_scenario', size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _tx.s('titles.${_scenario - 1}').toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: _svgText,
              letterSpacing: 0.4,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// The source's `.neutral-target-pin` (filled once `.placed`).
  static Widget _pinBadge(String n, {bool placed = false, double size = 28}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: placed ? _accent : _panel,
        shape: BoxShape.circle,
        border: Border.all(color: placed ? _accentHover : _accent, width: 2.5),
        boxShadow: [
          BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 15),
        ],
      ),
      child: Text(
        n,
        style: TextStyle(
          fontSize: size * 0.46,
          fontWeight: FontWeight.w900,
          color: placed ? Colors.white : _accent,
          height: 1,
        ),
      ),
    );
  }

  Widget _body() {
    return switch (_scenario) {
      1 => _s1(),
      2 => _s2(),
      3 => _s3(),
      _ => _s4(),
    };
  }

  // ---------------------------------------------- module 1: the Mimosa ---
  Widget _s1() {
    void p1() => _pin(1);
    void p2() => _pin(2);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 250,
            child: _SvgBox(
              vb: const Size(520, 440),
              painter: _S1Painter(_vis, _clock),
              showLabels: _labels,
              labels: [
                _SvgLabel(_c('c_touchStim'), 145, 165, size: 12),
                _SvgLabel(
                  _c('c_leafletsFold'),
                  325,
                  105,
                  size: 11.5,
                  color: _accent,
                  anchor: _Anchor.middle,
                ),
                _SvgLabel(_c('c_noGrowthInv'), 255, 228, size: 12),
              ],
              hits: [
                // Step 1 names the leaflets as a touch target (no handler in the source).
                _SvgHit(
                  's1-leaf-left',
                  const Rect.fromLTRB(73, 78, 226, 155),
                  p1,
                ),
                _SvgHit(
                  's1-leaf-top',
                  const Rect.fromLTRB(203, 0, 248, 121),
                  p1,
                ),
                _SvgHit(
                  's1-leaf-right',
                  const Rect.fromLTRB(225, 142, 384, 192),
                  p1,
                ),
                _SvgHit('s1-node', const Rect.fromLTRB(212, 139, 238, 161), p2),
                _SvgHit('s1-hand', const Rect.fromLTRB(0, 86, 152, 204), p1),
                _SvgHit('s1-pin1', const Rect.fromLTRB(63, 28, 107, 72), p1),
                _SvgHit('s1-pin2', const Rect.fromLTRB(208, 298, 252, 342), p2),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _fitColumn(
            250,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _calloutCard(
                  key: 's1-card-info',
                  border: _rt_Tw.sky500,
                  titleColor: _sky300,
                  icon: Icons.bolt,
                  iconColor: _accent,
                  title: _c('c_infoComm'),
                  desc: _c('c_infoCommDesc'),
                  onTap: p1,
                ),
                const SizedBox(height: 12),
                _calloutCard(
                  key: 's1-card-water',
                  border: _rt_Tw.amber500,
                  titleColor: _amber300,
                  icon: Icons.water_drop,
                  iconColor: _rt_Tw.amber400,
                  title: _c('c_cellsChangeWater'),
                  desc: _c('c_cellsChangeWaterDesc'),
                  onTap: p2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Lays [child] out at the column's width; shrinks it if taller than
  /// [height], so long text never shrinks the scene next to it.
  static Widget _fitColumn(double height, Widget child) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) => Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(width: c.maxWidth, child: child),
          ),
        ),
      ),
    );
  }

  Widget _calloutCard({
    required String key,
    required Color border,
    required Color titleColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: ValueKey(key),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: _muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------ module 2: phototropism ---
  static final Path _beamPath = Path()
    ..moveTo(140, 85)
    ..lineTo(340, 50)
    ..lineTo(340, 310)
    ..lineTo(140, 185)
    ..close();

  Widget _s2() {
    void p1() => _pin(1);
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: SizedBox(
            height: 240,
            child: _SvgBox(
              vb: const Size(520, 380),
              painter: _S2Painter(_vis, _clock),
              showLabels: _labels,
              labels: [
                _SvgLabel(
                  _c('c_lightStim'),
                  175,
                  95,
                  size: 12,
                  color: _rt_Tw.amber500,
                ),
                _SvgLabel(
                  _c('c_lightAtSource'),
                  185,
                  240,
                  size: 11,
                  weight: FontWeight.w800,
                  anchor: _Anchor.middle,
                ),
                _SvgLabel(_c('c_shootBends'), 330, 215, size: 12),
                _SvgLabel(_c('c_rootBendsAway'), 405, 350, size: 12),
              ],
              hits: [
                // The window group includes the (invisible) light-beam polygon.
                _SvgHit('s2-beam', _beamPath.getBounds(), p1, path: _beamPath),
                _SvgHit('s2-window', const Rect.fromLTRB(66, 76, 144, 194), p1),
                _SvgHit('s2-pin1', const Rect.fromLTRB(364, 159, 406, 201), p1),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: _fitColumn(
            240,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _lensCard(),
                const SizedBox(height: 10),
                Text(
                  _c('c_auxinHormone'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _amber300,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _lensCard() {
    return GestureDetector(
      key: const ValueKey('s2-lens'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _pin(2),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _rt_Tw.amber500.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: _SvgBox(
                    vb: const Size(110, 110),
                    painter: _Lens1Painter(_vis, _clock),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: _SvgBox(
                    vb: const Size(110, 110),
                    painter: _Lens2Painter(_vis, _clock),
                    showLabels: _labels,
                    labels: [
                      _SvgLabel(
                        _c('c_shadySide'),
                        77,
                        60,
                        size: 9.5,
                        color: _rt_Tw.amber500,
                        rotate: 90,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Pin 2: named by the HUD / steps and styled by the source code, never drawn.
          Positioned(
            left: 6,
            top: 6,
            child: _pinBadge(
              '2',
              placed: _vis.placed.contains('s2-2'),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------- module 3: tropisms ---
  Widget _s3() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tropCard(
              1,
              'c_geotropism',
              _SvgBox(
                vb: const Size(200, 130),
                painter: _GeoPainter(_vis, _clock),
                showLabels: _labels,
                labels: [
                  // Source class `svg-text-muted` is undefined (black on dark): muted colour.
                  _SvgLabel(
                    _c('c_gravity'),
                    35,
                    28,
                    size: 9.5,
                    color: _muted,
                    anchor: _Anchor.middle,
                  ),
                  _SvgLabel(
                    _c('c_shootUp'),
                    165,
                    18,
                    size: 9.5,
                    color: _rt_Tw.green500,
                    anchor: _Anchor.middle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _tropCard(
              2,
              'c_hydrotropism',
              _SvgBox(
                vb: const Size(200, 130),
                painter: _HydroPainter(_vis, _clock),
                showLabels: _labels,
                labels: [
                  _SvgLabel(
                    _c('c_waterStim'),
                    55,
                    40,
                    size: 10,
                    color: _accent,
                  ),
                  _SvgLabel(
                    _c('c_rootGrowsWater'),
                    120,
                    118,
                    size: 10,
                    anchor: _Anchor.middle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tropCard(
              3,
              'c_chemotropism',
              _SvgBox(
                vb: const Size(200, 130),
                painter: _ChemoPainter(_vis, _clock),
                showLabels: _labels,
                labels: [
                  _SvgLabel(
                    _c('c_chemStim'),
                    145,
                    32,
                    size: 9,
                    color: _pink400,
                  ),
                  _SvgLabel(
                    _c('c_pollenTubeOvule'),
                    100,
                    122,
                    size: 9.5,
                    anchor: _Anchor.middle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _tropCard(
              4,
              'c_tendrilTitle',
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 78,
                    height: 78,
                    child: _SvgBox(
                      vb: const Size(120, 120),
                      painter: _TendrilPainter(_vis, _clock),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: _fitColumn(
                        78,
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _c('c_diffGrowth'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: _amber300,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _c('c_contactSlower'),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _muted,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tropCard(int n, String titleKey, Widget art) {
    return Expanded(
      child: GestureDetector(
        key: ValueKey('s3-card-$n'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _pin(n),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _c(titleKey),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: _svgText,
                      ),
                    ),
                  ),
                  _pinBadge(
                    '$n',
                    placed: _vis.placed.contains('s3-$n'),
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(height: 78, child: art),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------- module 4: sort & race ---
  Widget _s4() {
    const tokens = [
      (
        'mimosa',
        'c_mimosaFold',
        Color(0xCC064E3B),
        _rt_Tw.emerald400,
        _emerald300,
      ),
      ('photo', 'c_photoBend', Color(0xCC0C4A6E), _rt_Tw.sky400, _sky300),
      ('geo', 'c_geoRoot', Color(0xCC78350F), _rt_Tw.amber400, _amber300),
      (
        'tendril',
        'c_tendrilCoilToken',
        Color(0xCC581C87),
        _purple400,
        _purple300,
      ),
    ];
    const chipKey = {
      'photo': 'c_photoBend',
      'geo': 'c_geoRoot',
      'tendril': 'c_tendrilCoilToken',
    };
    final v = _vis;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.touch_app, size: 15, color: _accent),
            const SizedBox(width: 6),
            Text(
              _c('c_typeSorting').toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: _accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final (id, key, bg, border, fg) in tokens)
              if (!v.hiddenTokens.contains(id))
                _token(id, _c(key), bg, border, fg),
          ],
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _pot(
                  key: 'pot-indep',
                  title: _c('c_growthIndep'),
                  titleColor: _rt_Tw.emerald400,
                  content: v.mimosaInPot
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xCC022C22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _rt_Tw.emerald400),
                          ),
                          child: Text(
                            _c('c_mimosaFold'),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _emerald300,
                            ),
                          ),
                        )
                      : _placeholder(_c('c_clickMimosaPlaceholder')),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _pot(
                  key: 'pot-dep',
                  title: _c('c_growthDep'),
                  titleColor: _accent,
                  content: v.depChips.isEmpty
                      ? _placeholder(_c('c_clickTropicPlaceholder'))
                      : Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final id in v.depChips)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020617),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: Text(
                                  _c(chipKey[id]!),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _svgText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _racePanel(),
      ],
    );
  }

  Widget _token(String id, String label, Color bg, Color border, Color fg) {
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      elevation: 3,
      child: InkWell(
        key: ValueKey('token-$id'),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => _clickToken(id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: _muted,
    ),
  );

  Widget _pot({
    required String key,
    required String title,
    required Color titleColor,
    required Widget content,
  }) {
    return CustomPaint(
      key: ValueKey(key),
      foregroundPainter: const _DashedRRectPainter(color: _border, radius: 22),
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: Center(child: content)),
          ],
        ),
      ),
    );
  }

  Widget _racePanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: ValueListenableBuilder<double>(
        valueListenable: _clock,
        builder: (context, now, _) {
          final t0 = _raceShown ? _raceT0 : null;
          final e = t0 == null ? 0.0 : now - t0;
          // The source's 100 ms interval, stopped when the growth lane finishes.
          final timer = t0 == null
              ? '0.0s'
              : '${math.min((e * 10).floor() / 10, 10.0).toStringAsFixed(1)}s';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    _c('c_speedOrderTitle').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: _rt_Tw.amber400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    key: const ValueKey('race-timer'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Tw.amber400,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      timer,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: _rt_Tw.slate950,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: _rt_Tw.amber400,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 4,
                    child: InkWell(
                      key: const ValueKey('race-start'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: _startRace,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        child: Text(
                          _tx.s('startSpeedRaceBtn'),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: _rt_Tw.slate950,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _lane(
                0,
                '1. ${_c('c_touchMeNotChip')}',
                _emerald300,
                _rt_Tw.emerald400,
                'mimosa',
                e,
                t0 != null,
              ),
              const SizedBox(height: 6),
              _lane(
                1,
                '2. ${_c('c_sunflowerChip')}',
                _amber300,
                _rt_Tw.amber400,
                'sunflower',
                e,
                t0 != null,
              ),
              const SizedBox(height: 6),
              _lane(
                2,
                '3. ${_c('c_growthMovChip')}',
                _purple300,
                _purple400,
                'growth',
                e,
                t0 != null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _lane(
    int i,
    String label,
    Color labelColor,
    Color bar,
    String id,
    double e,
    bool running,
  ) {
    final p = running ? (e / _raceDur[i]).clamp(0.0, 1.0) : 0.0;
    final w = i == 0 ? _p1o(p) : p; // mimosa: power1.out, the others linear
    final done = _laneDone[i];
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: w,
                heightFactor: 1,
                child: ColoredBox(color: bar),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          child: Text(
            _h(done ? 'race_done_$id' : 'race_ready_$id'),
            key: ValueKey('lane-$id'),
            textAlign: TextAlign.right,
            maxLines: 2,
            style: done
                ? TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: bar,
                  )
                : const TextStyle(fontSize: 10, color: _muted),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------- overlays ---
  List<Widget> _overlays(Size size) {
    if (size.width < 280) return const [];
    final compact = size.height < 380;
    final hudW = math.min(340.0, size.width - 24);
    final hudLeft = (size.width - hudW) / 2;
    final pos = _hudPos;
    return [
      if (pos == null)
        Positioned(
          left: hudLeft,
          bottom: _barH + 6,
          width: hudW,
          child: _hudPanel(size, hudW, compact),
        )
      else
        Positioned(
          left: pos.dx.clamp(10.0, math.max(10.0, size.width - hudW - 10)),
          top: pos.dy.clamp(10.0, math.max(10.0, size.height - _hudH - 10)),
          width: hudW,
          child: _hudPanel(size, hudW, compact),
        ),
      if (_obs != null) _obsPopup(size),
      if (_final) _finalPopup(size),
      for (final b in _bursts)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ConfettiPainter(b, _clock)),
          ),
        ),
    ];
  }

  /// The source's draggable floating action HUD.
  Widget _hudPanel(Size size, double w, bool compact) {
    final (pillBg, pillFg) = _hudType == _Fb.success
        ? (_rt_Tw.sky500.withValues(alpha: 0.2), _accent)
        : (_rt_Tw.blue500.withValues(alpha: 0.2), _rt_Tw.blue400);
    return Container(
      key: _hudKey,
      decoration: BoxDecoration(
        color: _rt_Lab.base,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 4, color: _accent),
          GestureDetector(
            key: const ValueKey('hud-handle'),
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) {
              if (_hudPos != null) return;
              _hudPos = Offset(
                (size.width - w) / 2,
                size.height - _barH - 6 - _hudH,
              );
            },
            onPanUpdate: (d) => setState(() {
              final p = _hudPos! + d.delta;
              _hudPos = Offset(
                p.dx.clamp(10.0, math.max(10.0, size.width - w - 10)),
                p.dy.clamp(10.0, math.max(10.0, size.height - _hudH - 10)),
              );
            }),
            child: Container(
              height: compact ? 18 : 22,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _border.withValues(alpha: 0.6)),
                ),
              ),
              child: RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: _rt_Lab.textMuted,
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                compact ? 5 : 8,
                12,
                compact ? 6 : 9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: 0.75,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, size: 13, color: _accent),
                        const SizedBox(width: 5),
                        Text(
                          _tx.s('missionReady').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _h(_hudInstr),
                    key: const ValueKey('hud-instruction'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _h(_hudFb),
                      key: const ValueKey('hud-feedback'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: pillFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Place a draggable card: [base] is its resting top-left, [off] the drag.
  static Offset _placed(Size size, double w, Offset base, Offset off) {
    final minL = math.min(10.0, base.dx);
    final maxL = math.max(base.dx, size.width - w - 10);
    return Offset(
      (base.dx + off.dx).clamp(minL, maxL),
      (base.dy + off.dy).clamp(10.0, math.max(10.0, size.height - 80)),
    );
  }

  /// The source's "Scientific Conclusion" popup.
  Widget _obsPopup(Size size) {
    final n = _obs!;
    final w = math.min(600.0, size.width * 0.9);
    final base = Offset((size.width - w) / 2, size.height * 0.15);
    final at = _placed(size, w, base, _obsOff);
    return Positioned(
      left: at.dx,
      top: at.dy,
      width: w,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(120.0, size.height - at.dy - 10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _rt_Lab.base,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 50,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => setState(
                  () => _obsOff =
                      _placed(size, w, base, _obsOff + d.delta) - base,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 9, 8, 9),
                  decoration: BoxDecoration(
                    color: _rt_Lab.base,
                    border: Border(bottom: BorderSide(color: _rt_Lab.border)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment, size: 18, color: _accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tx.s('sciObs'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: _accent,
                          ),
                        ),
                      ),
                      InkResponse(
                        key: const ValueKey('obs-close'),
                        radius: 18,
                        onTap: _closeObs,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
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
              ),
              Flexible(
                child: Container(
                  color: _rt_Lab.canvas,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 7),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: _rt_Lab.border),
                            ),
                          ),
                          child: Text(
                            _tx.s('conclusions.${n - 1}.h'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: _rich(_tx.s('conclusions.${n - 1}.p')),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _rt_Lab.text,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: _rt_Lab.border),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          child: _pillButton(
                            const ValueKey('obs-ok'),
                            Icons.check,
                            _tx.s('btnOk'),
                            _confirmObs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The source's final mastery card.
  Widget _finalPopup(Size size) {
    final w = math.min(580.0, size.width * 0.9);
    final base = Offset((size.width - w) / 2, size.height * 0.10);
    final at = _placed(size, w, base, _finalOff);
    final bullets = _tx.list('final.b');
    return Positioned(
      left: at.dx,
      top: at.dy,
      width: w,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(160.0, size.height - at.dy - 10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _rt_Lab.base,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _rt_Tw.sky500.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.9),
                blurRadius: 70,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => setState(
                  () => _finalOff =
                      _placed(size, w, base, _finalOff + d.delta) - base,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF082F49),
                        _rt_Tw.slate900,
                        Color(0xFF1E1B4B),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: _rt_Tw.sky500.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _rt_Tw.sky500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _rt_Tw.sky400),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 21,
                          color: _sky300,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tx.s('finalTitle'),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _tx.s('subtitle'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _rt_Tw.sky400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkResponse(
                        key: const ValueKey('final-close'),
                        radius: 18,
                        onTap: _closeFinal,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: _rt_Tw.slate400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  color: _rt_Lab.canvas,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text.rich(
                          TextSpan(children: _rich(_tx.s('final.p'))),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _rt_Lab.text,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _rt_Lab.base,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _rt_Lab.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < bullets.length; i++) ...[
                                if (i > 0) const SizedBox(height: 6),
                                Text.rich(
                                  TextSpan(
                                    children: _rich(bullets[i] as String),
                                  ),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: _rt_Lab.text,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _rt_Lab.base,
                  border: Border(top: BorderSide(color: _rt_Lab.border)),
                ),
                alignment: Alignment.center,
                child: _pillButton(
                  const ValueKey('final-restart'),
                  Icons.replay,
                  _tx.s('btnRestartLab'),
                  () {
                    _rt_playSfx(_rt_Sfx.scenario);
                    _restart();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _pillButton(
    Key key,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: _rt_Tw.sky500,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: _rt_Tw.sky500.withValues(alpha: 0.3),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: _rt_Tw.slate950),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.slate950,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Turns the table's `[x]..[/]` runs into coloured bold spans.
  static List<InlineSpan> _rich(String s) {
    const colors = {
      'e': _rt_Tw.emerald400,
      'E': _emerald300,
      's': _sky300,
      'S': _rt_Tw.sky400,
      'a': _amber300,
      'A': _rt_Tw.amber400,
      'p': _pink400,
    };
    final out = <InlineSpan>[];
    var last = 0;
    for (final m in RegExp(r'\[(\w)\](.*?)\[/\]').allMatches(s)) {
      if (m.start > last) out.add(TextSpan(text: s.substring(last, m.start)));
      final code = m.group(1)!;
      out.add(
        TextSpan(
          text: m.group(2),
          style: code == 'i'
              ? const TextStyle(fontStyle: FontStyle.italic)
              : TextStyle(fontWeight: FontWeight.w800, color: colors[code]),
        ),
      );
      last = m.end;
    }
    if (last < s.length) out.add(TextSpan(text: s.substring(last)));
    return out;
  }

  // ----------------------------------------------------------- sidebar ---
  Widget _sidebar(BuildContext context) {
    final steps = _tx.list('steps.${_scenario - 1}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            border: Border(bottom: BorderSide(color: _rt_Lab.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.science, size: 13, color: _accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _tx.s('moduleSel').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                        color: _accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _moduleSelect(),
            ],
          ),
        ),
        // The source's Text Scaling setting scales the teacher content only.
        MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_fontPx / 18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 12, color: _accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _tx.s('missionObj').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          color: _accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _rt_Lab.canvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _rt_Lab.border),
                  ),
                  child: Text(
                    _tx.s('objs.${_scenario - 1}'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _rt_Lab.text,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < steps.length; i++)
                  _stepItem(i, steps[i] as Map),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('settings'), icon: Icons.tune),
              _rt_LabeledSlider(
                key: const ValueKey('font-slider'),
                label: _tx.s('txtScale').toUpperCase(),
                value: _fontPx,
                min: 16,
                max: 32,
                divisions: 16,
                valueText: '${_fontPx.round()}px',
                color: _rt_Tw.sky500,
                onChanged: (v) => setState(() => _fontPx = v.roundToDouble()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moduleSelect() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: const ValueKey('module-select'),
          value: _scenario,
          isExpanded: true,
          onTap: () => _rt_playSfx(_rt_Sfx.dropdown),
          dropdownColor: _rt_Lab.surface,
          iconEnabledColor: _rt_Lab.textMuted,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.text,
          ),
          items: [
            for (var n = 1; n <= 4; n++)
              DropdownMenuItem(
                value: n,
                child: Text(
                  _tx.s('titles.${n - 1}'),
                  key: ValueKey('module-item-$n'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          // An HTML <select> fires `change` only for a different option.
          onChanged: (n) {
            if (n != null && n != _scenario) _loadScenario(n);
          },
        ),
      ),
    );
  }

  /// One teacher-board accordion item (open by default, like the source).
  Widget _stepItem(int i, Map step) {
    final open = !_collapsed.contains(i);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: ValueKey('step-$i'),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap); // source 'click'
              setState(() => open ? _collapsed.add(i) : _collapsed.remove(i));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 17, color: _accent),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      step['t'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: _rt_Lab.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Container(
                    padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                    decoration: BoxDecoration(
                      color: _rt_Lab.surface,
                      border: Border(top: BorderSide(color: _rt_Lab.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _stepHead(
                          Icons.play_arrow,
                          _tx.s('taskInstr'),
                          _accent,
                        ),
                        Text(
                          step['i'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _rt_Lab.text,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _stepHead(
                          Icons.visibility,
                          _tx.s('expOut'),
                          _rt_Tw.blue400,
                        ),
                        Text(
                          step['o'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: _rt_Lab.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _stepHead(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================ SVG helpers ===

enum _Anchor { start, middle }

/// An SVG `<text>` (baseline at [y]); the `.label-text` ones fade with the
/// labels tool.
class _SvgLabel {
  const _SvgLabel(
    this.text,
    this.x,
    this.y, {
    this.size = 12,
    this.color = _svgText,
    this.weight = FontWeight.w900,
    this.anchor = _Anchor.start,
    this.rotate = 0,
  });

  final String text;
  final double x, y, size, rotate;
  final Color color;
  final FontWeight weight;
  final _Anchor anchor;
}

/// A tappable region in viewBox units (optionally clipped to [path]).
class _SvgHit {
  const _SvgHit(this.key, this.rect, this.onTap, {this.path});

  final String key;
  final Rect rect;
  final VoidCallback onTap;
  final Path? path;
}

/// An inline `<svg viewBox>` with the default `xMidYMid meet` fit: a painter,
/// text labels and hit regions all mapped through the same transform.
class _SvgBox extends StatelessWidget {
  const _SvgBox({
    required this.vb,
    required this.painter,
    this.labels = const [],
    this.hits = const [],
    this.showLabels = true,
  });

  final Size vb;
  final CustomPainter painter;
  final List<_SvgLabel> labels;
  final List<_SvgHit> hits;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        final s = math.min(w / vb.width, h / vb.height);
        final ox = (w - vb.width * s) / 2, oy = (h - vb.height * s) / 2;
        return Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: painter)),
            for (final l in labels) _label(l, s, ox, oy),
            for (final hit in hits)
              Positioned(
                left: ox + hit.rect.left * s,
                top: oy + hit.rect.top * s,
                width: hit.rect.width * s,
                height: hit.rect.height * s,
                child: _hitArea(hit, s),
              ),
          ],
        );
      },
    );
  }

  Widget _hitArea(_SvgHit hit, double s) {
    final tap = GestureDetector(
      key: ValueKey(hit.key),
      behavior: HitTestBehavior.opaque,
      onTap: hit.onTap,
    );
    final p = hit.path;
    if (p == null) return tap;
    final local = p
        .shift(-hit.rect.topLeft)
        .transform(Matrix4.diagonal3Values(s, s, 1).storage);
    return ClipPath(clipper: _PathClip(local), child: tap);
  }

  Widget _label(_SvgLabel l, double s, double ox, double oy) {
    final fs = l.size * s;
    Widget t = Text(
      l.text,
      softWrap: false,
      style: TextStyle(
        fontSize: fs,
        fontWeight: l.weight,
        color: l.color,
        height: 1,
      ),
    );
    if (l.anchor == _Anchor.middle) {
      t = FractionalTranslation(translation: const Offset(-0.5, 0), child: t);
    }
    if (l.rotate != 0) {
      t = Transform(
        transform: Matrix4.rotationZ(l.rotate * math.pi / 180),
        origin: Offset(0, fs * 0.8),
        child: t,
      );
    }
    return Positioned(
      left: ox + l.x * s,
      top: oy + l.y * s - fs * 0.8,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: showLabels ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: t,
        ),
      ),
    );
  }
}

class _PathClip extends CustomClipper<Path> {
  const _PathClip(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _PathClip old) => old.path != path;
}

/// Applies the viewBox fit to [c]; returns the scale.
double _fitVb(Canvas c, Size size, Size vb) {
  final s = math.min(size.width / vb.width, size.height / vb.height);
  c.translate(
    (size.width - vb.width * s) / 2,
    (size.height - vb.height * s) / 2,
  );
  c.scale(s);
  return s;
}

Paint _fill(Color c) => Paint()..color = c;

Paint _line(Color c, double w, {bool round = false}) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = round ? StrokeCap.round : StrokeCap.butt;

/// Parsed path data (absolute M / L / Q / Z only, which is all the source uses).
class _Seg {
  const _Seg(this.cmd, this.v);
  final String cmd;
  final List<double> v;
}

final Map<String, List<_Seg>> _segCache = {};

List<_Seg> _segs(String d) => _segCache.putIfAbsent(d, () {
  final out = <_Seg>[];
  String? cmd;
  var nums = <double>[];
  for (final m in RegExp(r'[MLQZ]|-?\d*\.?\d+').allMatches(d)) {
    final tok = m.group(0)!;
    if ('MLQZ'.contains(tok)) {
      if (cmd != null) out.add(_Seg(cmd, nums));
      cmd = tok;
      nums = [];
    } else {
      nums.add(double.parse(tok));
    }
  }
  if (cmd != null) out.add(_Seg(cmd, nums));
  return out;
});

/// Builds [a], or the GSAP `attr: {d}` tween from [a] to [b] at [t].
Path _path(String a, [String? b, double t = 0]) {
  final sa = _segs(a);
  final sb = b == null ? null : _segs(b);
  final p = Path();
  for (var i = 0; i < sa.length; i++) {
    var v = sa[i].v;
    if (sb != null) {
      v = [for (var k = 0; k < v.length; k++) v[k] + (sb[i].v[k] - v[k]) * t];
    }
    switch (sa[i].cmd) {
      case 'M':
        p.moveTo(v[0], v[1]);
        for (var k = 2; k + 1 < v.length; k += 2) {
          p.lineTo(v[k], v[k + 1]);
        }
      case 'L':
        for (var k = 0; k + 1 < v.length; k += 2) {
          p.lineTo(v[k], v[k + 1]);
        }
      case 'Q':
        for (var k = 0; k + 3 < v.length; k += 4) {
          p.quadraticBezierTo(v[k], v[k + 1], v[k + 2], v[k + 3]);
        }
      case 'Z':
        p.close();
    }
  }
  return p;
}

/// SVG `stroke-dasharray: on, off` with `stroke-dashoffset`.
Path _dash(Path src, double on, double off, double offset) {
  final out = Path();
  final period = on + off;
  final phase = ((offset % period) + period) % period;
  for (final m in src.computeMetrics()) {
    var d = -phase;
    while (d < m.length) {
      final a = math.max(d, 0.0), b = math.min(d + on, m.length);
      if (b > a) out.addPath(m.extractPath(a, b), Offset.zero);
      d += period;
    }
  }
  return out;
}

void _ellipse(
  Canvas c,
  double cx,
  double cy,
  double rx,
  double ry,
  double rotDeg,
  Paint fill, [
  Paint? stroke,
]) {
  c.save();
  c.translate(cx, cy);
  c.rotate(rotDeg * math.pi / 180);
  final r = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
  c.drawOval(r, fill);
  if (stroke != null) c.drawOval(r, stroke);
  c.restore();
}

void _rotateAbout(Canvas c, double x, double y, double deg) {
  c.translate(x, y);
  c.rotate(deg * math.pi / 180);
  c.translate(-x, -y);
}

/// An SVG target pin (circle + number); filled once used.
void _svgPin(
  Canvas c,
  Offset at,
  double r,
  String n,
  bool placed,
  double fontSize,
) {
  c.drawCircle(at, r, _fill(placed ? _accent : _panel));
  c.drawCircle(at, r, _line(placed ? _accentHover : _accent, 3));
  final tp = TextPainter(
    text: TextSpan(
      text: n,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: placed ? Colors.white : _accent,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, at - Offset(tp.width / 2, tp.height / 2));
}

// --- GSAP eases ---
double _p1o(double t) => 1 - (1 - t) * (1 - t); // power1.out (GSAP default)
double _p2o(double t) => 1 - math.pow(1 - t, 3).toDouble(); // power2.out
double _p2io(double t) =>
    t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2; // power2.inOut
double _backOut(double t, [double s = 2]) {
  final u = t - 1;
  return u * u * ((s + 1) * u + s) + 1;
}

double _bounceOut(double t) {
  const n = 7.5625, d = 2.75;
  if (t < 1 / d) return n * t * t;
  if (t < 2 / d) return n * (t -= 1.5 / d) * t + 0.75;
  if (t < 2.5 / d) return n * (t -= 2.25 / d) * t + 0.9375;
  return n * (t -= 2.625 / d) * t + 0.984375;
}

/// Linear progress of a tween started at [t0] (0 before / when never started).
double _prog(double? t0, double now, double dur, {double delay = 0}) =>
    t0 == null ? 0 : ((now - t0 - delay) / dur).clamp(0.0, 1.0);

/// CSS `ease-in-out` keyframes 0% -> 50% -> 100% over [period]: 0..1..0.
double _pingPong(double now, double period) {
  final q = (now % period) / period;
  return q < 0.5
      ? Curves.easeInOut.transform(q * 2)
      : 1 - Curves.easeInOut.transform(q * 2 - 1);
}

/// The source's `.animate-electrical` (1.2 s linear): dash offset 40 -> -40,
/// opacity .3 -> 1 -> .3 with a sky glow at the midpoint.
({double off, double op, double glow}) _electrical(double now) {
  final ph = (now % 1.2) / 1.2;
  final peak = 1 - (2 * ph - 1).abs();
  return (off: 40 - 80 * ph, op: 0.3 + 0.7 * peak, glow: 14 * peak);
}

void _glowStroke(
  Canvas c,
  Path p,
  Color color,
  double w,
  double op,
  double glow,
) {
  if (glow > 0.5) {
    c.drawPath(
      p,
      _line(_accent.withValues(alpha: 0.8 * op), w)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow / 2),
    );
  }
  c.drawPath(p, _line(color.withValues(alpha: op), w));
}

// ================================================================ painters ===

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, _fill(const Color(0xFF020617)));
    void glow(Offset at, Color color, double stop) {
      final far = [
        r.topLeft,
        r.topRight,
        r.bottomLeft,
        r.bottomRight,
      ].map((p) => (p - at).distance).reduce(math.max);
      canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(
              at.dx / size.width * 2 - 1,
              at.dy / size.height * 2 - 1,
            ),
            radius: far / size.shortestSide,
            colors: [color, color.withValues(alpha: 0)],
            stops: [0, stop],
          ).createShader(r),
      );
    }

    glow(
      Offset(size.width * 0.5, size.height * 0.15),
      const Color(0x1F0EA5E9),
      0.7,
    );
    glow(
      Offset(size.width * 0.85, size.height * 0.85),
      const Color(0x1AA855F7),
      0.65,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Module 1: the Mimosa (viewBox 520 x 440).
class _S1Painter extends CustomPainter {
  _S1Painter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  // (cx, cy, rx, ry, rotate) of each leaflet ellipse.
  static const _left = [
    (170.0, 130.0, 16.0, 8.0, -30.0),
    (182.0, 144.0, 16.0, 8.0, -30.0),
    (130.0, 108.0, 16.0, 8.0, -30.0),
    (142.0, 122.0, 16.0, 8.0, -30.0),
    (90.0, 88.0, 17.0, 8.0, -35.0),
    (102.0, 102.0, 17.0, 8.0, -35.0),
  ];
  static const _top = [
    (210.0, 75.0, 15.0, 7.0, -70.0),
    (240.0, 75.0, 15.0, 7.0, 70.0),
    (210.0, 40.0, 15.0, 7.0, -70.0),
    (240.0, 40.0, 15.0, 7.0, 70.0),
    (225.0, 12.0, 16.0, 7.0, 0.0),
  ];
  static const _right = [
    (265.0, 152.0, 16.0, 8.0, 25.0),
    (272.0, 172.0, 16.0, 8.0, 25.0),
    (315.0, 155.0, 16.0, 8.0, 25.0),
    (322.0, 175.0, 16.0, 8.0, 25.0),
    (358.0, 162.0, 17.0, 8.0, 30.0),
    (365.0, 182.0, 17.0, 8.0, 30.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(520, 440));
    final now = clock.value;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(230, 390), width: 260, height: 52),
      _fill(const Color(0xFF78350F).withValues(alpha: 0.65)),
    );
    canvas.drawPath(
      _path(
        'M 230 380 Q 200 410, 170 425 M 230 380 Q 255 410, 280 425 M 230 385 Q 225 415, 225 435',
      ),
      _line(const Color(0xFFB45309), 3.5, round: true),
    );
    canvas.drawPath(
      _path('M 230 385 Q 230 260, 225 120'),
      _line(const Color(0xFF15803D), 10, round: true),
    );

    // Pulvinus (pin 2: scale .55, yoyo, repeat 2 -> ends shrunk).
    var pulv = 1.0;
    if (v.pulv != null) {
      final e = now - v.pulv!;
      if (e >= 1.2) {
        pulv = 0.55;
      } else {
        final leg = (e / 0.4).floor();
        final f = (e % 0.4) / 0.4;
        pulv = 1 - 0.45 * _p1o(leg.isEven ? f : 1 - f);
      }
    }
    _node(canvas, 225, 150, pulv);
    _node(canvas, 225, 170, 1);
    _node(canvas, 230, 270, 1);

    // Leaves (pin 1 folds them about their bases; leaflets close up).
    final squeeze = 1 - 0.8 * _p2o(_prog(v.fold, now, 0.4));
    _leaf(
      canvas,
      const Offset(225, 150),
      40 * _p2o(_prog(v.fold, now, 0.6)),
      'M 225 150 Q 150 125, 90 90',
      5.5,
      _left,
      squeeze,
    );
    _leaf(
      canvas,
      const Offset(225, 120),
      -25 * _p2o(_prog(v.fold, now, 0.5)),
      'M 225 120 Q 225 65, 225 20',
      5,
      _top,
      squeeze,
    );
    _leaf(
      canvas,
      const Offset(225, 170),
      45 * _bounceOut(_prog(v.fold, now, 0.7)),
      'M 225 170 Q 295 160, 365 170',
      5.5,
      _right,
      squeeze,
    );

    // Electrical-chemical signal (CSS loop; pin 1 adds four 0.5 s pulses).
    var (:off, :op, :glow) = _electrical(now);
    if (v.wave != null && now - v.wave! < 2.0) {
      final q = _p1o(((now - v.wave!) % 0.5) / 0.5);
      off = 40 - 40 * q;
      op = 0.2 + 0.8 * q;
    }
    _glowStroke(
      canvas,
      _dash(
        _path('M 225 150 L 218 168 L 235 180 L 220 192 L 232 205 L 225 218'),
        8,
        4,
        off,
      ),
      _accent,
      4,
      op,
      glow,
    );

    // The hand (CSS float 2 s).
    final k = _pingPong(now, 2.0);
    canvas.save();
    canvas.translate(12 * k, -8 * k);
    final palm = _path(
      'M 0 200 Q 55 180, 85 160 L 115 145 Q 128 138, 120 125 Q 112 118, 100 125 L 75 145 Q 50 160, 0 175 Z',
    );
    canvas.drawPath(palm, _fill(const Color(0xFFFED7AA)));
    canvas.drawPath(palm, _line(const Color(0xFFC2410C), 2.5));
    final finger = _path(
      'M 85 160 L 138 118 Q 150 108, 142 98 Q 130 92, 118 105 L 75 145',
    );
    canvas.drawPath(finger, _fill(const Color(0xFFFCD34D)));
    canvas.drawPath(finger, _line(const Color(0xFFB45309), 2.5));
    _ellipse(
      canvas,
      138,
      105,
      4,
      6,
      -35,
      _fill(const Color(0xFFFFF1F2).withValues(alpha: 0.8)),
    );
    final thumb = _path('M 85 165 Q 110 160, 118 148 Q 115 138, 102 142 Z');
    canvas.drawPath(thumb, _fill(const Color(0xFFFDE68A)));
    canvas.drawPath(thumb, _line(const Color(0xFFD97706), 2));
    canvas.restore();

    _svgPin(
      canvas,
      const Offset(85, 50),
      15,
      '1',
      v.placed.contains('s1-1'),
      14,
    );
    _svgPin(
      canvas,
      const Offset(230, 320),
      15,
      '2',
      v.placed.contains('s1-2'),
      14,
    );
  }

  void _node(Canvas c, double x, double y, double s) {
    final r = Rect.fromCenter(
      center: Offset(x, y),
      width: 18 * s,
      height: 14 * s,
    );
    c.drawOval(r, _fill(_rt_Tw.green500));
    c.drawOval(r, _line(const Color(0xFF14532D), 2));
  }

  void _leaf(
    Canvas c,
    Offset pivot,
    double deg,
    String rachis,
    double w,
    List<(double, double, double, double, double)> leaflets,
    double squeeze,
  ) {
    c.save();
    _rotateAbout(c, pivot.dx, pivot.dy, deg);
    c.drawPath(_path(rachis), _line(_rt_Tw.green600, w));
    final fill = _fill(_rt_Tw.green400);
    final stroke = _line(const Color(0xFF14532D), 1.8);
    for (final (cx, cy, rx, ry, rot) in leaflets) {
      c.save();
      c.translate(cx, cy);
      c.scale(squeeze, 1);
      _ellipse(c, 0, 0, rx, ry, rot, fill, stroke);
      c.restore();
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 2: the room, window and two seedlings (viewBox 520 x 380).
class _S2Painter extends CustomPainter {
  _S2Painter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  static Path _poly(List<double> p) {
    final path = Path()..moveTo(p[0], p[1]);
    for (var i = 2; i + 1 < p.length; i += 2) {
      path.lineTo(p[i], p[i + 1]);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(520, 380));
    final now = clock.value;
    const wallStroke = _rt_Tw.slate600;
    final left = _poly([50, 60, 210, 25, 210, 310, 50, 335]);
    canvas.drawPath(left, _fill(_svgCardBg));
    canvas.drawPath(left, _line(wallStroke, 3.5));
    final right = _poly([210, 25, 470, 60, 470, 335, 210, 310]);
    canvas.drawPath(right, _fill(_panel));
    canvas.drawPath(right, _line(wallStroke, 3.5));
    canvas.drawPath(
      _poly([50, 335, 210, 310, 470, 335, 300, 370]),
      _fill(const Color(0xFF78350F).withValues(alpha: 0.65)),
    );

    // Window (pin 1 lights it and the beam at once).
    final lit = v.light != null;
    const win = Rect.fromLTWH(70, 80, 70, 110);
    if (lit) {
      canvas.drawRect(
        win.inflate(4),
        _fill(_rt_Tw.amber500.withValues(alpha: 0.85))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 17),
      );
    }
    canvas.drawRect(
      win,
      _fill(lit ? const Color(0xFFFEF08A) : _rt_Tw.slate600),
    );
    canvas.drawRect(win, _line(_rt_Tw.amber600, 3.5));
    canvas.drawLine(
      const Offset(105, 80),
      const Offset(105, 190),
      _line(_rt_Tw.amber600, 2.5),
    );
    canvas.drawLine(
      const Offset(70, 135),
      const Offset(140, 135),
      _line(_rt_Tw.amber600, 2.5),
    );
    if (lit) {
      canvas.drawPath(
        _poly([140, 85, 340, 50, 340, 310, 140, 185]),
        _fill(const Color(0xFFFEF08A).withValues(alpha: 0.4 * 0.45)),
      );
    }

    // Straight seedling (translate 150, 160).
    canvas.save();
    canvas.translate(150, 160);
    canvas.drawPath(
      _path('M 35 160 Q 35 80, 35 30'),
      _line(_rt_Tw.green500, 7, round: true),
    );
    _ellipse(canvas, 25, 24, 16, 8, -30, _fill(_rt_Tw.green400));
    _ellipse(canvas, 45, 24, 16, 8, 30, _fill(_rt_Tw.green400));
    canvas.drawPath(
      _path('M 35 160 Q 28 185, 32 205 M 35 160 Q 42 185, 40 205'),
      _line(_rt_Tw.amber700, 3),
    );
    canvas.restore();

    // Arrow (the source's `#arrowhead` marker is never defined; head drawn here).
    canvas.drawLine(
      const Offset(245, 200),
      const Offset(271, 200),
      _line(_accent, 5),
    );
    canvas.drawPath(_poly([268, 193, 282, 200, 268, 207]), _fill(_accent));

    // Bending seedling (translate 300, 110).
    final t = _p2io(_prog(v.light, now, 1.4));
    final tl = _p1o(_prog(v.light, now, 1.4));
    canvas.save();
    canvas.translate(300, 110);
    canvas.drawPath(
      _path('M 60 180 Q 60 110, 60 40', 'M 60 180 Q 75 110, 10 45', t),
      _line(_rt_Tw.green500, 9, round: true),
    );
    _ellipse(
      canvas,
      60 - 50 * tl,
      35 + 5 * tl,
      18,
      9,
      -40 * tl,
      _fill(const Color(0xFF86EFAC)),
      _line(_rt_Tw.green700, 1.8),
    );
    _ellipse(
      canvas,
      60 - 35 * tl,
      35 + 15 * tl,
      16,
      8,
      -15 * tl,
      _fill(_rt_Tw.green400),
      _line(_rt_Tw.green700, 1.8),
    );
    canvas.drawPath(
      _path('M 60 180 Q 60 210, 60 230', 'M 60 180 Q 70 205, 90 225', t),
      _line(_rt_Tw.amber700, 3.5, round: true),
    );
    _svgPin(
      canvas,
      const Offset(85, 70),
      14,
      '1',
      v.placed.contains('s2-1'),
      13,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 2 lens 1: the shoot tip making auxin (viewBox 110).
class _Lens1Painter extends CustomPainter {
  _Lens1Painter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(110, 110));
    final now = clock.value;
    canvas.drawCircle(const Offset(55, 55), 50, _fill(_panel));
    canvas.drawCircle(const Offset(55, 55), 50, _line(_accent, 3.5));
    final tip = _path(
      'M 35 95 L 35 60 Q 35 30, 55 30 Q 75 30, 75 60 L 75 95 Z',
    );
    canvas.drawPath(tip, _fill(_rt_Tw.green500));
    canvas.drawPath(tip, _line(_rt_Tw.green700, 2.5));
    const dots = [
      Offset(55, 38),
      Offset(48, 45),
      Offset(62, 45),
      Offset(55, 52),
    ];
    for (var i = 0; i < dots.length; i++) {
      var op = 1.0, sc = 1.0;
      if (v.auxin != null) {
        // fromTo {opacity 0, scale .5} -> {1, 1.2}, 0.6 s, stagger 0.1.
        final p = _p1o(_prog(v.auxin, now, 0.6, delay: 0.1 * i));
        op = p;
        sc = 0.5 + 0.7 * p;
      }
      if (op > 0) {
        canvas.drawCircle(
          dots[i],
          3 * sc,
          _fill(_rt_Tw.amber500.withValues(alpha: op)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 2 lens 2: elongating cells on the shady side (viewBox 110).
class _Lens2Painter extends CustomPainter {
  _Lens2Painter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(110, 110));
    final now = clock.value;
    canvas.clipRect(const Rect.fromLTWH(0, 0, 110, 110));
    canvas.drawCircle(
      const Offset(55, 55),
      50,
      _line(_rt_Tw.amber500, 4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(const Offset(55, 55), 50, _fill(_panel));
    canvas.drawCircle(const Offset(55, 55), 50, _line(_rt_Tw.amber500, 4));
    final stroke = _line(const Color(0xFF14532D), 1.8);
    for (final y in [24.0, 48.0, 72.0]) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(24, y, 18, 20),
        const Radius.circular(3),
      );
      canvas.drawRRect(r, _fill(_rt_Tw.green400));
      canvas.drawRRect(r, stroke);
    }
    // `.animate-auxin-pulse` (1.8 s) and pin 2's scaleY 1.4 from the top.
    final k = _pingPong(now, 1.8);
    final fill = Color.lerp(_rt_Tw.amber500, _rt_Tw.amber400, k)!;
    final glowC = Color.lerp(_rt_Tw.amber400, _rt_Tw.amber500, k)!;
    final sy = v.shady == null
        ? 1.0
        : 1 + 0.4 * _backOut(_prog(v.shady, now, 0.8));
    for (final (y, h) in [(18.0, 36.0), (58.0, 38.0)]) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(48, y, 25, h * sy),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        r,
        _fill(glowC)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, (4 + 12 * k) / 2),
      );
      canvas.drawRRect(r, _fill(fill));
      canvas.drawRRect(r, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 3 card 1: geotropism (viewBox 200 x 130).
class _GeoPainter extends CustomPainter {
  _GeoPainter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(200, 130));
    final now = clock.value;
    final pot = 90 * _p2o(_prog(v.geo, now, 0.8));
    final tip = -90 * _p1o(_prog(v.geo, now, 0.9, delay: 0.2));
    canvas.save();
    _rotateAbout(canvas, 100, 75, pot);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 60, 140, 55),
        const Radius.circular(10),
      ),
      _fill(const Color(0xFF78350F).withValues(alpha: 0.6)),
    );
    canvas.save();
    _rotateAbout(canvas, 100, 45, tip);
    canvas.drawLine(
      const Offset(100, 60),
      const Offset(100, 20),
      _line(_rt_Tw.green500, 6, round: true),
    );
    canvas.restore();
    _ellipse(canvas, 88, 18, 12, 6, -30, _fill(_rt_Tw.green400));
    _ellipse(canvas, 112, 18, 12, 6, 30, _fill(_rt_Tw.green400));
    canvas.save();
    _rotateAbout(canvas, 100, 85, tip);
    canvas.drawPath(
      _path('M 100 60 L 100 105 M 100 75 L 88 95 M 100 80 L 112 100'),
      _line(_rt_Tw.amber700, 3.5, round: true),
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 3 card 2: hydrotropism (viewBox 200 x 130).
class _HydroPainter extends CustomPainter {
  _HydroPainter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(200, 130));
    final now = clock.value;
    canvas.drawPath(
      _path('M 10 60 L 70 60 Q 60 95, 25 95 L 10 95 Z'),
      _fill(_accentHover.withValues(alpha: 0.85)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 60, 120, 65),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFF78350F).withValues(alpha: 0.45)),
    );
    canvas.drawLine(
      const Offset(135, 60),
      const Offset(135, 25),
      _line(_rt_Tw.green500, 5),
    );
    _ellipse(canvas, 125, 22, 12, 6, -30, _fill(_rt_Tw.green400));
    _ellipse(canvas, 145, 22, 12, 6, 30, _fill(_rt_Tw.green400));
    canvas.drawPath(
      _path(
        'M 135 60 Q 110 75, 45 82',
        'M 135 60 Q 95 75, 25 82',
        _p2o(_prog(v.hydro, now, 1.0)),
      ),
      _line(_rt_Tw.amber700, 4, round: true),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 3 card 3: chemotropism, the pollen tube (viewBox 200 x 130).
class _ChemoPainter extends CustomPainter {
  _ChemoPainter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(200, 130));
    final now = clock.value;
    for (final d in [
      'M 15 45 Q 55 15, 80 65 Q 35 95, 15 45 Z',
      'M 185 45 Q 145 15, 120 65 Q 165 95, 185 45 Z',
    ]) {
      canvas.drawPath(_path(d), _fill(_rt_Tw.yellow400));
      canvas.drawPath(_path(d), _line(const Color(0xFFCA8A04), 2));
    }
    final pistil = _path('M 90 90 Q 100 105, 110 90 L 105 38 L 95 38 Z');
    canvas.drawPath(pistil, _fill(_rt_Tw.green500));
    canvas.drawPath(pistil, _line(_rt_Tw.green700, 2.5));
    canvas.drawCircle(const Offset(100, 85), 9, _fill(const Color(0xFF86EFAC)));
    canvas.drawCircle(
      const Offset(100, 85),
      9,
      _line(const Color(0xFF166534), 2),
    );
    // `.animate-electrical`; pin 3's fromTo (offset 60 -> 0, opacity .2 -> 1).
    var (:off, :op, :glow) = _electrical(now);
    if (v.chemo != null && now - v.chemo! < 1.2) {
      final q = _p1o((now - v.chemo!) / 1.2);
      off = 60 - 60 * q;
      op = 0.2 + 0.8 * q;
    }
    _glowStroke(
      canvas,
      _dash(_path('M 100 38 L 100 76'), 8, 4, off),
      _rt_Tw.amber500,
      3.5,
      op,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Module 3 card 4: the tendril on its support (viewBox 120).
class _TendrilPainter extends CustomPainter {
  _TendrilPainter(this.v, this.clock) : super(repaint: clock);

  final _Vis v;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    _fitVb(canvas, size, const Size(120, 120));
    final now = clock.value;
    canvas.drawLine(
      const Offset(85, 10),
      const Offset(72, 115),
      _line(const Color(0xFF92400E), 9, round: true),
    );
    var sc = 1.0, rot = 0.0;
    if (v.tendril != null) {
      // fromTo {scale .7, rotation -30} -> {1.15, 0}, back.out(2), 0.9 s.
      final p = _backOut(_prog(v.tendril, now, 0.9));
      sc = 0.7 + 0.45 * p;
      rot = -30 + 30 * p;
    }
    canvas.save();
    canvas.translate(75, 60);
    canvas.rotate(rot * math.pi / 180);
    canvas.scale(sc);
    canvas.translate(-75, -60);
    canvas.drawPath(
      _path(
        'M 25 110 Q 45 65, 55 45 Q 85 28, 76 60 Q 68 82, 86 78 Q 105 72, 88 100',
      ),
      _line(_rt_Tw.green500, 5.5, round: true),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Dashed `border-2 border-dashed rounded-3xl` of the module 4 pots.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      Radius.circular(radius),
    );
    canvas.drawPath(_dash(Path()..addRRect(rr), 6, 4, 0), _line(color, 2));
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

// ================================================================ confetti ===

/// One canvas-confetti burst (default options: startVelocity 45, decay 0.9,
/// gravity 1, 200 ticks, square + circle shapes).
class _Burst {
  _Burst(this.t0, int count, double spreadDeg, this.originY, int seed) {
    final r = math.Random(seed);
    final spread = spreadDeg * math.pi / 180;
    for (var i = 0; i < count; i++) {
      parts.add((
        angle: -math.pi / 2 + 0.5 * spread - r.nextDouble() * spread,
        v: 22.5 + r.nextDouble() * 45,
        color: _confettiColors[r.nextInt(_confettiColors.length)],
        wobble: r.nextDouble() * 10,
        wobbleSpeed: math.min(0.11, r.nextDouble() * 0.1 + 0.05),
        tilt: (r.nextDouble() * 0.5 + 0.25) * math.pi,
        circle: r.nextBool(),
      ));
    }
  }

  final double t0;
  final double originY;
  final List<
    ({
      double angle,
      double v,
      Color color,
      double wobble,
      double wobbleSpeed,
      double tilt,
      bool circle,
    })
  >
  parts = [];
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.b, this.clock) : super(repaint: clock);

  final _Burst b;
  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final n = (clock.value - b.t0) * 60; // ticks
    if (n < 0 || n > 200) return;
    // The source fires over the whole browser window; scale to this canvas.
    final k = (size.height / 700).clamp(0.45, 1.0);
    final travel = (1 - math.pow(0.9, n)) / 0.1;
    final alpha = (1 - n / 200).clamp(0.0, 1.0);
    final ox = size.width * 0.5, oy = size.height * b.originY;
    for (final p in b.parts) {
      final x = ox + math.cos(p.angle) * p.v * travel * k;
      final y = oy + (math.sin(p.angle) * p.v * travel + 3 * n) * k;
      final wob = p.wobble + n * p.wobbleSpeed;
      final tilt = p.tilt + 0.1 * n;
      final wx = x + 10 * k * math.cos(wob), wy = y + 10 * k * math.sin(wob);
      final tc = 2.5 * k * math.cos(tilt), ts = 2.5 * k * math.sin(tilt);
      final paint = _fill(p.color.withValues(alpha: alpha));
      if (p.circle) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(math.pi / 10 * wob);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: math.max(1.0, (wx - x).abs() * 1.2),
            height: math.max(1.0, (wy - y).abs() * 1.2),
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(wx, y + ts)
            ..lineTo(wx + tc, wy + ts)
            ..lineTo(x + tc, wy)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
