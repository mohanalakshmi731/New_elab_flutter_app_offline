// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 5.1: Excretion in Plants
// Converted from Cl10S-Ch5-A8-ExcretionInPlants.html (Tailwind + inline SVG +
// GSAP + canvas-confetti -> Flutter widgets + CustomPainter).
//
// A 2D DOM lab on one tree scene (980 x 640 design units, scaled to fit the
// canvas like the source's #scene-content), split into the three modules of
// the sidebar's Module Select:
//   1. Gas & water wastes - tap the Sun (an O₂ bubble rises from the canopy),
//      drag the Gas Sensor onto the bubble, drag the Condensation Jar over the
//      leaf canopy;
//   2. Waste in the living body - drag the Magnifier to the stem, tap the
//      Plant Cell inset, drag the Waste Crystals into its vacuole, tap the
//      yellow leaf to shed it;
//   3. Resins, gums & soil excretion - drag the Sectioning Tool to the trunk,
//      drag the Amber Resin into the old xylem of the cross-section inset,
//      drag the Soil Probe into the root zone.
// Each module ends in the source's Scientific Conclusion card (OK / close);
// OK on the last of the three opens the "What We Understand & What We Have
// Learnt" summary with Restart. The draggable action HUD shows the current
// step's instruction, the feedback pill and the step counter; the sidebar
// carries the module select, the mission objective and the steps accordion.

// --- TRANSLATION DATA (source `locales`; `te` dropped) ---
// The conclusion cards are the source's HTML split into title / intro / items /
// takeaway; inside an item, <e>..</e> etc. mark the source's coloured bold
// spans (see _spanColors). The source's `hud.h_*` strings are never displayed
// by it (updateHUD always prefers the step instruction), so they are omitted.

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
  static const sky400 = Color(0xFF38BDF8);
  static const blue400 = Color(0xFF60A5FA);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);
  static const indigo900 = Color(0xFF312E81);
  static const orange600 = Color(0xFFEA580C);
  static const amber200 = Color(0xFFFDE68A);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green500 = Color(0xFF22C55E);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
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
  final VoidCallback? onStart;

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
    'title': 'Excretion in Plants',
    'subtitle': 'Class 10 • Life Processes',
    'enterLab': 'Enter Virtual _rt_Lab',
    'moduleSel': 'Module Select',
    'sciObs': 'Scientific Conclusion',
    'missionReady': 'Mission Status',
    'missionObj': 'Mission Objective',
    'taskInstr': 'Task Instructions:',
    'expOut': 'Expected Outcome:',
    'btnOk': 'OK',
    'btnRestartLab': 'Restart Virtual _rt_Lab',
    'finalTitle': 'What We Understand & What We Have Learnt',
    's1_title': '1. Gas & Water Wastes (Oxygen & Transpiration)',
    's2_title': '2. Waste in Living Body (Vacuoles & Leaf Fall)',
    's3_title': '3. Resins, Gums & Soil Excretion',
    's1_obj':
        'To investigate how plants release oxygen as a waste product of photosynthesis and eliminate excess water through transpiration.',
    's2_obj':
        'To demonstrate how plants use dead-cell tissues to store wastes in cellular vacuoles and safely shed accumulated wastes via falling leaves.',
    's3_obj':
        'To explore how permanent wastes are sealed as resins and gums in old xylem and excreted directly into surrounding soil.',
    's1_steps': [
      {
        't': 'Step 1: Photosynthetic Oxygen Generation',
        'i':
            'CLICK the Sun on the top-left to trigger photosynthesis in the leaf canopy.',
        'o':
            'Sunlight activates chlorophyll; oxygen (O₂) gas bubbles emerge from the leaves as a photosynthetic waste byproduct.',
      },
      {
        't': 'Step 2: Oxygen Gas Collection',
        'i':
            'DRAG the Gas Sensor Collector onto the glowing oxygen bubble in the canopy.',
        'o':
            'The sensor analyzes and collects oxygen (O₂) released from the green leaves.',
      },
      {
        't': 'Step 3: Excess Water Transpiration',
        'i':
            'DRAG the Condensation Jar over the leafy branch to test for water loss.',
        'o':
            'Excess water transpires through the leaves and condenses as clear water droplets on the glass walls.',
      },
      {
        't': 'Step 4: Conclusion',
        'i': 'Observe the summary panel and click OK.',
        'o':
            'Confirmation that plants eliminate oxygen and excess water easily.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Dead Cell Examination',
        'i':
            'DRAG the Magnifier to the stem trunk to inspect plant tissue anatomy.',
        'o':
            'Magnified view demonstrates that many plant tissues consist of dead cells that safely store wastes.',
      },
      {
        't': 'Step 2: Cellular Vacuole Storage',
        'i': 'CLICK the Magnified Plant Cell Inset on the right.',
        'o':
            'Cellular anatomy reveals the prominent central vacuole designed for metabolic storage.',
      },
      {
        't': 'Step 3: Loading Metabolic Wastes',
        'i': 'DRAG the Waste Crystals into the plant cell\'s central vacuole.',
        'o':
            'Metabolic waste crystals are safely sequestered inside the vacuole without harming the cell.',
      },
      {
        't': 'Step 4: Leaf Shedding Disposal',
        'i': 'CLICK the yellow ageing leaf on the left branch to detach it.',
        'o':
            'The tree sheds the waste-filled leaf, safely eliminating accumulated wastes as it falls to the soil.',
      },
      {
        't': 'Step 5: Conclusion',
        'i': 'Observe the summary panel and click OK.',
        'o': 'Confirmation of vacuole storage and leaf-shedding excretion.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: Wood Sectioning',
        'i':
            'DRAG the Sectioning Tool to the tree trunk to reveal annual wood rings.',
        'o':
            'Wood cross-section reveals outer pale young xylem and inner dark old xylem.',
      },
      {
        't': 'Step 2: Resins in Old Xylem',
        'i': 'DRAG the Amber Resin Droplets into the dark inner Old Xylem.',
        'o':
            'Resins and gums are permanently sealed away in non-functional old xylem wood.',
      },
      {
        't': 'Step 3: Root Soil Excretion',
        'i': 'DRAG the Soil Chemical Probe into the ground around the roots.',
        'o':
            'Roots actively discharge secondary waste substances directly into the surrounding soil bed.',
      },
      {
        't': 'Step 4: Conclusion',
        'i': 'Observe the summary panel and click OK.',
        'o':
            'Confirmation of permanent storage in old xylem and root soil excretion.',
      },
    ],
    's1_conclusion': {
      'title': 'Gas & Water Excretion Verified',
      'intro':
          'Plants eliminate gaseous and liquid byproducts without complex organs:',
      'items': [
        '1. <e>Oxygen (O₂):</e> Generated as a waste byproduct during photosynthesis and released into the atmosphere.',
        '2. <b>Excess Water:</b> Constantly removed through <b3>transpiration</b3> from aerial leaf surfaces.',
      ],
      'takeaway':
          'Key Takeaway: Photosynthesis release and transpiration serve as effortless waste routes.',
    },
    's2_conclusion': {
      'title': 'Internal Storage & Leaf Fall Verified',
      'intro': 'Because plant physiology differs fundamentally from animals:',
      'items': [
        '• <e>Dead Tissues:</e> Many plant tissues consist of non-living dead cells, allowing safe waste accumulation without physiological injury.',
        '• <i>Cellular Vacuoles:</i> Large central vacuoles act as secure internal storage lockers for metabolic wastes.',
        '• <a>Falling Leaves:</a> Plants store wastes in ageing leaves and discard them simply by shedding.',
      ],
      'takeaway':
          'Key Takeaway: Vacuole storage and leaf shedding allow low-energy waste disposal.',
    },
    's3_conclusion': {
      'title': 'Resins, Gums & Soil Excretion Verified',
      'intro':
          'For complex metabolic byproducts, plants use two specialized disposal strategies:',
      'items': [
        '• <a>Resins & Gums:</a> Stored permanently in the innermost rings of <a3>old xylem</a3> (heartwood) that no longer transports water.',
        '• <e>Soil Excretion:</e> Some waste substances are excreted directly into the surrounding soil via root systems.',
      ],
      'takeaway':
          'Key Takeaway: Old xylem sequestration and soil excretion complete plant waste management.',
    },
    'final_summary': [
      {
        'title': '1. Gaseous & Water Wastes',
        'text':
            'Oxygen (O₂) is released from photosynthesis, and excess water is lost via transpiration.',
      },
      {
        'title': '2. Storage in Vacuoles & Dead Cells',
        'text':
            'Many tissues have dead cells; wastes are safely stored inside cellular vacuoles.',
      },
      {
        'title': '3. Leaf Shedding',
        'text':
            'Wastes stored in ageing leaves are discarded when the leaves fall off.',
      },
      {
        'title': '4. Resins, Gums & Soil Excretion',
        'text':
            'Resins are sealed in old xylem (heartwood), and some wastes are excreted into soil.',
      },
    ],
    'lbl': {
      'sun': 'Sun',
      'canopy': 'Leaf Canopy',
      'sensor': 'Gas Sensor',
      'jar': 'Condensation Jar',
      'mag': 'Magnifier',
      'cell': 'Plant Cell',
      'crystals': 'Waste Crystals',
      'leaf': 'Yellowing Leaf',
      'saw': 'Sectioning Tool',
      'trunk': 'Wood Cross-Section',
      'resin': 'Resin & Gum',
      'probe': 'Soil Probe',
    },
  },
  'hi': {
    'title': 'पौधों में उत्सर्जन',
    'subtitle': 'कक्षा 10 • जीवन प्रक्रियाएं',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'moduleSel': 'मॉड्यूल का चयन करें',
    'sciObs': 'वैज्ञानिक निष्कर्ष',
    'missionReady': 'मिशन स्थिति',
    'missionObj': 'मिशन उद्देश्य',
    'taskInstr': 'कार्य निर्देश:',
    'expOut': 'अपेक्षित परिणाम:',
    'btnOk': 'ठीक है',
    'btnRestartLab': 'वर्चुअल लैब पुनः आरंभ करें',
    'finalTitle': 'हमने इस अवधारणा में क्या समझा और क्या सीखा',
    's1_title': '1. गैस और जल अपशिष्ट (ऑक्सीजन और वाष्पोत्सर्जन)',
    's2_title': '2. सजीव शरीर में अपशिष्ट (रिक्तिकाएं और पत्ती गिरना)',
    's3_title': '3. रेजिन, गोंद और मिट्टी में उत्सर्जन',
    's1_obj':
        'यह प्रदर्शित करना कि पौधे प्रकाश संश्लेषण के अपशिष्ट के रूप में ऑक्सीजन छोड़ते हैं और वाष्पोत्सर्जन द्वारा अतिरिक्त जल निकालते हैं।',
    's2_obj':
        'यह समझना कि मृत कोशिकाओं के कारण पौधे रिक्तिकाओं में अपशिष्ट संचित कर सकते हैं और अपशिष्ट से भरी पत्तियों को गिरा सकते हैं।',
    's3_obj':
        'यह खोजना कि स्थायी अपशिष्ट पुराने जाइलम में रेजिन व गोंद के रूप में कैसे संचित होते हैं और मिट्टी में उत्सर्जित होते हैं।',
    's1_steps': [
      {
        't': 'कदम 1: प्रकाश संश्लेषण सक्रिय करना',
        'i':
            'पत्तियों के वितान में प्रकाश संश्लेषण शुरू करने के लिए ऊपर बाईं ओर सूर्य पर क्लिक करें।',
        'o':
            'क्लोरोफिल सक्रिय होता है; ऑक्सीजन (O₂) गैस के बुलबुले प्रकाश संश्लेषण के अपशिष्ट के रूप में निकलते हैं।',
      },
      {
        't': 'कदम 2: ऑक्सीजन गैस का संचयन',
        'i': 'वितान में चमकते ऑक्सीजन के बुलबुले पर गैस सेंसर खींचें।',
        'o':
            'पत्तियों से निकलने वाली ऑक्सीजन (O₂) गैस की पहचान और सुरक्षित संचयन।',
      },
      {
        't': 'कदम 3: अतिरिक्त जल का वाष्पोत्सर्जन',
        'i':
            'जल हानि का परीक्षण करने के लिए संघनन जार को पत्तियों के ऊपर खींचें।',
        'o':
            'वाष्पोत्सर्जन द्वारा जलवाष्प कांच की दीवारों पर बूंदों के रूप में जमा हो जाती है।',
      },
      {
        't': 'कदम 4: निष्कर्ष',
        'i': 'सारांश पैनल देखें और \'ठीक है\' पर क्लिक करें।',
        'o': 'पुष्टि कि पौधे ऑक्सीजन और अतिरिक्त जल आसानी से निकालते हैं।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: मृत कोशिकाओं का निरीक्षण',
        'i': 'ऊतक संरचना का निरीक्षण करने के लिए आवर्धक को तने पर खींचें।',
        'o':
            'प्रवर्धित दृश्य साबित करता है कि कई ऊतक मृत कोशिकाओं से बने हैं जो अपशिष्ट सहन करते हैं।',
      },
      {
        't': 'कदम 2: पादप कोशिका रिक्तिका',
        'i': 'दाईं ओर प्रवर्धित पादप कोशिका इनसेट पर क्लिक करें।',
        'o': 'कोशिका संरचना केंद्रीय रिक्तिका को प्रकट करती है।',
      },
      {
        't': 'कदम 3: अपशिष्ट क्रिस्टल संचय',
        'i': 'अपशिष्ट क्रिस्टल को पादप कोशिका की केंद्रीय रिक्तिका में खींचें।',
        'o':
            'अपशिष्ट उत्पाद बिना किसी नुकसान के रिक्तिका में सुरक्षित बंद हो जाते हैं।',
      },
      {
        't': 'कदम 4: पत्ती गिराना',
        'i': 'अपशिष्ट से भरी पीली पत्ती को अलग करने के लिए उस पर क्लिक करें।',
        'o':
            'वृक्ष पत्ती को गिराकर संचित अपशिष्ट को सुरक्षित रूप से बाहर निकालता है।',
      },
      {
        't': 'कदम 5: निष्कर्ष',
        'i': 'सारांश पैनल देखें और \'ठीक है\' पर क्लिक करें।',
        'o': 'रिक्तिकाओं में संचय और पत्ती त्याग की पुष्टि।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: तने का क्रॉस-सेक्शन',
        'i': 'लकड़ी के वार्षिक छल्ले देखने के लिए तने पर कटिंग टूल खींचें।',
        'o': 'क्रॉस-सेक्शन बाहरी युवा जाइलम और आंतरिक पुराना जाइलम दिखाता है।',
      },
      {
        't': 'कदम 2: पुराने जाइलम में रेजिन',
        'i': 'रेजिन बूंदों को गहरे आंतरिक पुराने जाइलम में खींचें।',
        'o':
            'रेजिन और गोंद पुराने अक्रियाशील जाइलम में स्थायी रूप से बंद हो जाते हैं।',
      },
      {
        't': 'कदम 3: मिट्टी में उत्सर्जन',
        'i': 'जड़ों के आसपास की जमीन में मिट्टी जांच प्रोब खींचें।',
        'o':
            'जड़ें कुछ अपशिष्ट पदार्थ सीधे आसपास की मिट्टी में निकाल देती हैं।',
      },
      {
        't': 'कदम 4: निष्कर्ष',
        'i': 'सारांश पैनल देखें और \'ठीक है\' पर क्लिक करें।',
        'o': 'पुराने जाइलम और मिट्टी में उत्सर्जन की पुष्टि।',
      },
    ],
    's1_conclusion': {
      'title': 'गैस और जल अपशिष्ट सत्यापन',
      'intro':
          'पौधों में फेफड़े या वृक्क नहीं होते, फिर भी वे अपशिष्ट निकालते हैं:',
      'items': [
        '1. <e>ऑक्सीजन (O₂):</e> प्रकाश संश्लेषण के दौरान अपशिष्ट उत्पाद के रूप में बनती है और वायुमंडल में छोड़ दी जाती है।',
        '2. <b>अतिरिक्त जल:</b> पत्तियों की सतह से <b3>वाष्पोत्सर्जन</b3> द्वारा लगातार बाहर निकाला जाता है।',
      ],
      'takeaway':
          'मुख्य निष्कर्ष: प्रकाश संश्लेषण और वाष्पोत्सर्जन पौधों के सरल अपशिष्ट मार्ग हैं।',
    },
    's2_conclusion': {
      'title': 'आंतरिक संचय और पत्ती त्याग सत्यापन',
      'intro': 'पौधों की शारीरिक रचना जंतुओं से पूरी तरह भिन्न होती है:',
      'items': [
        '• <e>मृत ऊतक:</e> कई ऊतक मृत कोशिकाओं से बने होते हैं, जिससे बिना नुकसान के अपशिष्ट संचित किया जा सकता है।',
        '• <i>कोशिकीय रिक्तिकाएं:</i> बड़ी केंद्रीय रिक्तिकाएं अपशिष्ट पदार्थों के सुरक्षित लॉकर के रूप में कार्य करती हैं।',
        '• <a>पत्तियां गिरना:</a> पौधे पुरानी पत्तियों में अपशिष्ट भरकर उन्हें आसानी से गिरा देते हैं।',
      ],
      'takeaway':
          'मुख्य निष्कर्ष: रिक्तिकाओं में संचय और पत्ती त्याग कम ऊर्जा में अपशिष्ट निपटाते हैं।',
    },
    's3_conclusion': {
      'title': 'रेजिन, गोंद और मिट्टी में उत्सर्जन सत्यापन',
      'intro': 'जटिल उपापचयी अपशिष्टों के लिए पौधे दो विशेष तरीके अपनाते हैं:',
      'items': [
        '• <a>रेजिन और गोंद:</a> आंतरिक <a3>पुराने जाइलम</a3> (हार्टवुड) में स्थायी रूप से बंद होते हैं।',
        '• <e>मिट्टी में उत्सर्जन:</e> जड़ें कुछ अपशिष्ट सीधे आसपास की मिट्टी में उत्सर्जित करती हैं।',
      ],
      'takeaway':
          'मुख्य निष्कर्ष: पुराने जाइलम और मिट्टी में उत्सर्जन पौधों के अपशिष्ट निपटान को पूरा करते हैं।',
    },
    'final_summary': [
      {
        'title': '1. गैस और जल अपशिष्ट',
        'text':
            'प्रकाश संश्लेषण से ऑक्सीजन (O₂) निकलती है और वाष्पोत्सर्जन से अतिरिक्त जल बाहर होता है।',
      },
      {
        'title': '2. रिक्तिकाओं और मृत कोशिकाओं में संचय',
        'text':
            'कई ऊतक मृत कोशिकाओं से बने हैं; अपशिष्ट रिक्तिकाओं में सुरक्षित बंद रहते हैं।',
      },
      {
        'title': '3. पत्तियां गिरना',
        'text':
            'पुरानी पत्तियों में भरा अपशिष्ट पत्ती के गिरने के साथ ही पौधे से बाहर हो जाता है।',
      },
      {
        'title': '4. रेजिन, गोंद और मिट्टी में उत्सर्जन',
        'text':
            'रेजिन पुराने जाइलम में बंद होते हैं और कुछ अपशिष्ट जड़ों द्वारा मिट्टी में उत्सर्जित होते हैं।',
      },
    ],
    'lbl': {
      'sun': 'सूरज',
      'canopy': 'पत्तियों का वितान',
      'sensor': 'गैस सेंसर',
      'jar': 'संघनन जार',
      'mag': 'आवर्धक',
      'cell': 'पादप कोशिका',
      'crystals': 'अपशिष्ट क्रिस्टल',
      'leaf': 'पीली पत्ती',
      'saw': 'सेक्शनिंग टूल',
      'trunk': 'लकड़ी क्रॉस-सेक्शन',
      'resin': 'रेजिन और गोंद',
      'probe': 'मिट्टी प्रोब',
    },
  },
});

// Text the source hard-codes in its markup in English only (no hi/te entry).
// It stays English in both languages, exactly as the source shows it.
const _srcO2Zone = 'O₂ ZONE';
const _srcStemTissues = 'STEM TISSUES';
const _srcDropVacuole = 'DROP IN VACUOLE';
const _srcCutTrunk = 'CUT TRUNK';
const _srcSealOldXylem = 'SEAL IN OLD XYLEM';
const _srcRootSoil = 'ROOT & SOIL ZONE';
const _srcClick = 'CLICK';
const _srcShedLeaf = 'SHED LEAF';
const _srcStep = 'Step';
const _srcReady = 'Ready';
const _srcStageComplete = 'Stage Complete';
const _srcTipLock = 'Lock / Unlock Pan';
const _srcTipPan = 'Pan Mode Toggle';
const _srcTipLabels = 'Toggle Labels';

// --- Scene geometry (source #scene-content is 980 x 640) ---
const double _kW = 980;
const double _kH = 640;

/// Width kept clear on the right for the shell's vertical canvas toolbar.
const double _kGutter = 56;

// Tailwind colours the shared palette lacks.
const _emerald300 = Color(0xFF6EE7B7);
const _emerald950 = Color(0xFF022C22);
const _indigo300 = Color(0xFFA5B4FC);
const _indigo400 = Color(0xFF818CF8);
const _indigo950 = Color(0xFF1E1B4B);
const _amber300 = Color(0xFFFCD34D);
const _amber950 = Color(0xFF451A03);
const _blue300 = Color(0xFF93C5FD);
const _purple400 = Color(0xFFC084FC);
const _teal950 = Color(0xFF042F2E);

/// Source colour classes of the bold spans inside the conclusion cards.
const _spanColors = {
  'e': _rt_Tw.emerald400,
  'b': _rt_Tw.blue400,
  'b3': _blue300,
  'i': _indigo400,
  'a': _rt_Tw.amber400,
  'a3': _amber300,
};

/// A draggable lab tool (source `.draggable`), in scene units.
class _ToolSpec {
  const _ToolSpec(this.id, this.rect, {this.labelColor});

  /// Also the source element id and its `lbl` key.
  final String id;
  final Rect rect;
  final Color? labelColor;
}

const _tSensor = _ToolSpec('sensor', Rect.fromLTWH(450, 140, 75, 100));
const _tJar = _ToolSpec('jar', Rect.fromLTWH(480, 150, 90, 120));
const _tMag = _ToolSpec('mag', Rect.fromLTWH(480, 160, 90, 90));
const _tCrystals = _ToolSpec(
  'crystals',
  Rect.fromLTWH(470, 180, 65, 65),
  labelColor: _indigo300,
);
const _tSaw = _ToolSpec(
  'saw',
  Rect.fromLTWH(490, 160, 100, 45),
  labelColor: _amber300,
);
const _tResin = _ToolSpec(
  'resin',
  Rect.fromLTWH(480, 170, 65, 65),
  labelColor: _rt_Tw.amber400,
);
const _tProbe = _ToolSpec(
  'probe',
  Rect.fromLTWH(480, 170, 65, 100),
  labelColor: _rt_Tw.emerald400,
);

/// A drop zone (source `.dropzone`). [rect] is in scene units; the two that
/// live inside an inset card also carry their position inside it.
class _ZoneSpec {
  const _ZoneSpec(
    this.id,
    this.rect, {
    required this.radius,
    required this.color,
    required this.fill,
    this.label,
    this.labelKey,
    this.labelBg,
    this.labelFg,
    this.labelBorder,
    this.inInset,
  });

  final String id;
  final Rect rect;
  final double radius;
  final Color color;
  final Color fill;
  final String? label;
  final String? labelKey;
  final Color? labelBg;
  final Color? labelFg;
  final Color? labelBorder;
  final Offset? inInset;
}

const _zO2 = _ZoneSpec(
  'zoneO2',
  Rect.fromLTWH(245, 75, 100, 100),
  radius: 50,
  color: Color(0xB334D399),
  fill: Color(0x1A10B981),
  label: _srcO2Zone,
);
const _zCanopy = _ZoneSpec(
  'zoneCanopy',
  Rect.fromLTWH(120, 80, 150, 150),
  radius: 24,
  color: Color(0xB338BDF8),
  fill: Color(0x1A0EA5E9),
  labelKey: 'canopy',
);
const _zTrunk2 = _ZoneSpec(
  'zoneTrunk',
  Rect.fromLTWH(390, 260, 85, 120),
  radius: 16,
  color: Color(0xB334D399),
  fill: Color(0x1A10B981),
  label: _srcStemTissues,
);
// Inside the cell inset (715, 35) + its 1 px border + left/top 45.
const _zVacuole = _ZoneSpec(
  'zoneVacuole',
  Rect.fromLTWH(761, 81, 140, 120),
  radius: 60,
  color: Color(0xB3818CF8),
  fill: Color(0x336366F1),
  label: _srcDropVacuole,
  labelBg: _indigo950,
  labelFg: _indigo300,
  labelBorder: Color(0x806366F1),
  inInset: Offset(45, 45),
);
const _zTrunk3 = _ZoneSpec(
  'zoneTrunk',
  Rect.fromLTWH(390, 270, 85, 115),
  radius: 16,
  color: Color(0xB3FBBF24),
  fill: Color(0x1AF59E0B),
  label: _srcCutTrunk,
  labelFg: _amber300,
);
// Inside the trunk inset (715, 35) + its 1 px border + left/top 68.
const _zOldXylem = _ZoneSpec(
  'zoneOldXylem',
  Rect.fromLTWH(784, 104, 95, 95),
  radius: 47.5,
  color: Color(0xCCFBBF24),
  fill: Color(0x33F59E0B),
  label: _srcSealOldXylem,
  labelBg: _amber950,
  labelFg: _amber300,
  inInset: Offset(68, 68),
);
const _zSoil = _ZoneSpec(
  'zoneSoil',
  Rect.fromLTWH(320, 460, 270, 115),
  radius: 24,
  color: Color(0xB334D399),
  fill: Color(0x1A10B981),
  label: _srcRootSoil,
  labelFg: _emerald300,
);

/// One confetti piece (canvas-confetti's physics, evaluated in closed form).
class _Fetti {
  const _Fetti(
    this.angle,
    this.v0,
    this.color,
    this.wobble,
    this.wobbleSpeed,
    this.tilt,
    this.circle,
  );
  final double angle;
  final double v0;
  final Color color;
  final double wobble;
  final double wobbleSpeed;
  final double tilt;
  final bool circle;
}

const _fettiColors = [
  Color(0xFF26CCFF),
  Color(0xFFA25AFD),
  Color(0xFFFF5E7E),
  Color(0xFF88FF5A),
  Color(0xFFFCFF42),
  Color(0xFFFFA62D),
  Color(0xFFFF36FF),
];

// --- Source CSS keyframe curves (t in seconds) ---
/// `pulse-interactive` (2 s): 0 -> 1 -> 0.
double _pulse(double t) {
  final p = (t % 2.0) / 2.0;
  return Curves.easeInOut.transform(p < 0.5 ? p * 2 : 2 - p * 2);
}

/// Tailwind `animate-pulse` opacity (2 s): 1 -> 0.5 -> 1.
double _pulseOpacity(double t) {
  final p = (t % 2.0) / 2.0;
  return 1 -
      0.5 * const Cubic(0.4, 0, 0.6, 1).transform(p < 0.5 ? p * 2 : 2 - p * 2);
}

/// Tailwind `animate-bounce`: translateY as a fraction of the element height.
double _bounce(double t) {
  final p = t % 1.0;
  return p < 0.5
      ? -0.25 * (1 - const Cubic(0.8, 0, 1, 1).transform(p * 2))
      : -0.25 * const Cubic(0, 0, 0.2, 1).transform((p - 0.5) * 2);
}

/// `foliage-sway` (4.5 s): 0 -> 1 -> 0.
double _sway(double t) {
  final p = (t % 4.5) / 4.5;
  return Curves.easeInOut.transform(p < 0.5 ? p * 2 : 2 - p * 2);
}

class Cl10SCh05A8ExcretionInPlantsPage extends StatefulWidget {
  const Cl10SCh05A8ExcretionInPlantsPage({super.key});

  @override
  State<Cl10SCh05A8ExcretionInPlantsPage> createState() =>
      _Cl10SCh05A8ExcretionInPlantsPageState();
}

class _Cl10SCh05A8ExcretionInPlantsPageState
    extends State<Cl10SCh05A8ExcretionInPlantsPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();

  /// Seconds since the page opened; drives the source's looping CSS animations.
  final ValueNotifier<double> _time = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (e) => _time.value = e.inMicroseconds / 1e6,
  );
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();
  late final AnimationController _leafFall = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );
  // canvas-confetti: 200 ticks at 60 fps.
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3333),
  );
  final math.Random _rng = math.Random(10);
  List<_Fetti> _fetti = const [];
  double _fettiY = 0.6;

  // --- LAB STATE (source `state`) ---
  int _scenario = 1;
  int _step = 0;
  final List<bool> _completed = [false, false, false];

  // prog1 / prog2 / prog3 (the source's prog2.cellZoomed is never read).
  bool _sun = false, _o2Collected = false, _jarPlaced = false;
  bool _magChecked = false, _crystalsStored = false, _leafFell = false;
  bool _sawCut = false, _resinSealed = false, _probeSoil = false;

  // cam
  double _camX = 0, _camY = 0, _camScale = 1;
  bool _locked = true, _panMode = false, _labels = true;

  // Pointer drag & drop / panning.
  final Map<String, Offset> _toolOff = {};
  String? _dragId;
  int? _pointer;
  Offset _dragStartPointer = Offset.zero, _dragStartOff = Offset.zero;
  Set<String> _hover = const {};
  bool _panning = false;
  Offset _panStartPointer = Offset.zero, _panStartCam = Offset.zero;

  // Canvas layout (written while laying out the canvas, read by the pointer
  // handlers).
  double _base = 0.5;
  Offset _center = Offset.zero;

  // HUD.
  String? _feedback;
  String _fbText = _srcReady;
  Offset _hudOff = Offset.zero;

  // Step conclusion card and final mastery card (both draggable, like the source).
  bool _obs = false;
  Offset _obsOff = Offset.zero;
  bool _final = false;
  Offset _finalOff = Offset.zero;

  /// Expanded accordion item (the source re-opens the active step on render).
  int? _open = 0;

  /// Bumped on every module load so delayed callbacks of an old run bail out.
  int _gen = 0;
  final List<Timer> _timers = [];

  List<dynamic> get _steps => _tx.list('s${_scenario}_steps');
  int get _lastStep => _steps.length - 1;
  double get _scale => _base * _camScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker.start();
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
    _spin.dispose();
    _leafFall.dispose();
    _confetti.dispose();
    _time.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- flow ---
  void _later(int ms, VoidCallback fn) {
    final g = _gen;
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (!mounted || g != _gen) return;
        fn();
      }),
    );
  }

  void _setFeedback(String? f) {
    _feedback = f;
    if (f != null) _fbText = f;
  }

  /// Source `completeStep` + the conclusion branch of `render2DScene`.
  void _completeStep(int next) {
    setState(() {
      _step = next;
      _open = next;
      _setFeedback(null);
      _toolOff.clear();
    });
    if (next == _lastStep) {
      _completed[_scenario - 1] = true;
      _later(800, _showObservation);
    }
  }

  /// Source `loadScenario`: every module starts fresh; completions are kept.
  void _loadScenario(int n) {
    _gen++;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _leafFall.reset();
    setState(() {
      _scenario = n;
      _step = 0;
      _open = 0;
      _obs = false;
      _final = false;
      _camX = 0;
      _camY = 0;
      _camScale = 1;
      _sun = _o2Collected = _jarPlaced = false;
      _magChecked = _crystalsStored = _leafFell = false;
      _sawCut = _resinSealed = _probeSoil = false;
      _toolOff.clear();
      _dragId = null;
      _pointer = null;
      _panning = false;
      _hover = const {};
      _setFeedback(null);
    });
  }

  void _selectModule(int n) {
    // A <select> only fires onchange when the value changes.
    if (n == _scenario) return;
    _rt_playSfx(_rt_Sfx.scenario);
    _loadScenario(n);
  }

  /// Source `fullRestartLab` (the shell already plays its restart sound).
  void _restart() {
    _confetti.reset();
    setState(() {
      for (var i = 0; i < _completed.length; i++) {
        _completed[i] = false;
      }
      _locked = true;
      _panMode = false;
      _labels = true;
    });
    _loadScenario(1);
  }

  void _showObservation() {
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _obs = true;
      _obsOff = Offset.zero;
    });
    _burst(_scenario == 3 ? 120 : 90, _scenario == 3 ? 80 : 70, 0.6);
  }

  void _closeObservation() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _obs = false);
  }

  /// Source `confirmStepObservation` (the OK button).
  void _confirmObservation() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _obs = false);
    if (_completed.every((c) => c)) {
      _later(500, _showFinal);
    } else {
      setState(() => _setFeedback(_srcStageComplete));
    }
  }

  void _showFinal() {
    _rt_playSfx(_rt_Sfx.success);
    _burst(160, 90, 0.5);
    setState(() {
      _final = true;
      _finalOff = Offset.zero;
    });
  }

  void _closeFinal() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _final = false);
  }

  void _burst(int count, double spread, double originY) {
    _fettiY = originY;
    _fetti = [
      for (var i = 0; i < count; i++)
        _Fetti(
          (90 + spread * (_rng.nextDouble() - 0.5)) * math.pi / 180,
          22.5 + _rng.nextDouble() * 45,
          _fettiColors[_rng.nextInt(_fettiColors.length)],
          _rng.nextDouble() * 10,
          math.min(0.11, _rng.nextDouble() * 0.1 + 0.05),
          (_rng.nextDouble() * 0.5 + 0.25) * math.pi,
          _rng.nextBool(),
        ),
    ];
    _confetti.forward(from: 0);
  }

  // ------------------------------------------------------ interactions ---
  /// Source `handleDirectClick('sun')`.
  void _clickSun() {
    if (_scenario != 1 || _step != 0 || _sun) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _sun = true;
      _setFeedback('Photosynthesis Active');
    });
    _later(600, () => _completeStep(1));
  }

  /// Source `handleDirectClick('cell-inset')`: the step advances at once, so
  /// its feedback pill is replaced in the same frame (as in the source).
  void _clickCell() {
    if (_scenario != 2 || _step != 1) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _setFeedback('Cell Vacuole Exposed'));
    _completeStep(2);
  }

  /// Source `handleDirectClick('yellow-leaf')` and its GSAP fall.
  void _clickLeaf() {
    if (_scenario != 2 || _step != 3 || _leafFell) return;
    _rt_playSfx(_rt_Sfx.pop); // source 'leaf-fall'
    setState(() {
      _leafFell = true;
      _setFeedback('Leaf Shedding Verified');
    });
    _leafFall.forward(from: 0);
    _later(1000, () => _completeStep(4));
  }

  /// Source `handleOrganicDrop`. Returns false when the pair does not match.
  bool _drop(String tool, String zone) {
    void ok(_rt_Sfx sfx, VoidCallback mark, String feedback, int next) {
      _rt_playSfx(sfx);
      setState(() {
        mark();
        _setFeedback(feedback);
      });
      _later(900, () => _completeStep(next));
    }

    switch ((_scenario, _step, tool, zone)) {
      case (1, 1, 'sensor', 'zoneO2'):
        ok(_rt_Sfx.magic, () => _o2Collected = true, 'Oxygen Verified', 2);
      case (1, 2, 'jar', 'zoneCanopy'):
        ok(_rt_Sfx.magic, () => _jarPlaced = true, 'Transpiration Verified', 3);
      case (2, 0, 'mag', 'zoneTrunk'):
        ok(_rt_Sfx.magic, () => _magChecked = true, 'Dead Tissues Verified', 1);
      case (2, 2, 'crystals', 'zoneVacuole'):
        ok(
          _rt_Sfx.magic,
          () => _crystalsStored = true,
          'Vacuole Storage Verified',
          3,
        );
      case (3, 0, 'saw', 'zoneTrunk'):
        ok(
          _rt_Sfx.pop,
          () => _sawCut = true,
          'Wood Rings Revealed',
          1,
        ); // source 'slice'
      case (3, 1, 'resin', 'zoneOldXylem'):
        ok(_rt_Sfx.magic, () => _resinSealed = true, 'Resins & Gums Sealed', 2);
      case (3, 2, 'probe', 'zoneSoil'):
        ok(
          _rt_Sfx.magic,
          () => _probeSoil = true,
          'Soil Excretion Verified',
          3,
        );
      default:
        return false;
    }
    return true;
  }

  List<_ToolSpec> get _tools => switch (_scenario) {
    1 => [
      if (_step == 1 && !_o2Collected) _tSensor,
      if (_step == 2 && !_jarPlaced) _tJar,
    ],
    2 => [
      if (_step == 0 && !_magChecked) _tMag,
      if (_step == 2 && !_crystalsStored) _tCrystals,
    ],
    _ => [
      if (_step == 0 && !_sawCut) _tSaw,
      if (_step == 1 && !_resinSealed) _tResin,
      if (_step == 2 && !_probeSoil) _tProbe,
    ],
  };

  /// Zones in source DOM order (the last overlapping one takes the drop).
  List<_ZoneSpec> get _zones => switch (_scenario) {
    1 => [if (_sun) _zO2, if (_step >= 2) _zCanopy],
    2 => [if (_step == 0) _zTrunk2, if (_step == 2) _zVacuole],
    _ => [
      if (_step == 0 && !_sawCut) _zTrunk3,
      if (_step == 1) _zOldXylem,
      if (_step == 2) _zSoil,
    ],
  };

  _ToolSpec? _toolById(String id) {
    for (final t in _tools) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Source pointer test: the tool's box against each zone grown by 25 px.
  List<_ZoneSpec> _overlapping(_ToolSpec t, Offset off) {
    final r = t.rect.shift(off);
    final pad = 25 / _scale;
    return [
      for (final z in _zones)
        if (r.overlaps(z.rect.inflate(pad))) z,
    ];
  }

  Offset _toScene(Offset local) =>
      (local - _center - Offset(_camX, _camY)) / _scale +
      const Offset(_kW / 2, _kH / 2);

  void _onDown(PointerDownEvent e) {
    if (_pointer != null) return;
    if (e.kind == PointerDeviceKind.mouse && e.buttons != kPrimaryButton) {
      return;
    }
    final p = _toScene(e.localPosition);
    // A few px of slack around each tool for fingers.
    final slack = 6 / _scale;
    for (final t in _tools.reversed) {
      if (t.rect
          .shift(_toolOff[t.id] ?? Offset.zero)
          .inflate(slack)
          .contains(p)) {
        _pointer = e.pointer;
        _rt_playSfx(_rt_Sfx.tap); // source 'drag'
        setState(() {
          _dragId = t.id;
          _dragStartPointer = e.localPosition;
          _dragStartOff = _toolOff[t.id] ?? Offset.zero;
        });
        return;
      }
    }
    if (!_locked || _panMode) {
      _pointer = e.pointer;
      _panning = true;
      _panStartPointer = e.localPosition;
      _panStartCam = Offset(_camX, _camY);
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final id = _dragId;
    if (id != null) {
      final t = _toolById(id);
      if (t == null) return;
      final off =
          _dragStartOff + (e.localPosition - _dragStartPointer) / _scale;
      setState(() {
        _toolOff[id] = off;
        _hover = {for (final z in _overlapping(t, off)) z.id};
      });
    } else if (_panning) {
      final d = e.localPosition - _panStartPointer;
      setState(() {
        _camX = _panStartCam.dx + d.dx;
        _camY = _panStartCam.dy + d.dy;
      });
    }
  }

  void _onUp(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (_panning) {
      _panning = false;
      return;
    }
    final id = _dragId;
    if (id == null) return;
    final t = _toolById(id);
    final zones = (t == null || e is PointerCancelEvent)
        ? const <_ZoneSpec>[]
        : _overlapping(t, _toolOff[id] ?? Offset.zero);
    setState(() {
      _dragId = null;
      _hover = const {};
      // Dropped on no zone: back to where the drag began (0.2 s, as the
      // source's transform transition).
      if (zones.isEmpty) _toolOff[id] = _dragStartOff;
    });
    if (zones.isEmpty) return;
    // Dropped on a zone it does not belong to: the source leaves it there,
    // silently; the sound is the only addition.
    if (!_drop(id, zones.last.id)) _rt_playSfx(_rt_Sfx.wrong);
  }

  void _onSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      _zoom(e.scrollDelta.dy > 0 ? -0.08 : 0.08, sound: true);
    }
  }

  void _zoom(double d, {bool sound = false}) {
    if (sound) _rt_playSfx(_rt_Sfx.tap);
    setState(() => _camScale = (_camScale + d).clamp(0.6, 2.5));
  }

  void _resetCam() => setState(() {
    _camX = 0;
    _camY = 0;
    _camScale = 1;
  });

  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _locked = !_locked);
  }

  void _togglePan() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _panMode = !_panMode;
      if (_panMode) _locked = false;
    });
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labels = !_labels);
  }

  void _toggleAccordion(int i) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _open = _open == i ? null : i);
  }

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) => _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('title'),
          subtitle: _tx.s('subtitle'),
          theme: const _rt_ShellTheme(
            accent: _rt_Tw.emerald500,
            headerGradient: [_rt_Tw.slate900, Color(0xFF064E3B)],
            headerSubtitleColor: _rt_Tw.emerald400,
          ),
          canvasBackground: _rt_Lab.canvas,
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.eco,
            buttonIcon: Icons.arrow_forward,
          ),
          // Source enterLab: the success chime once the curtain is up.
          onStart: () => _rt_playSfx(_rt_Sfx.success),
          onRestart: _restart,
          onZoomIn: () => _zoom(0.12),
          onZoomOut: () => _zoom(-0.12),
          onResetView: _resetCam,
          toolbarExtras: [
            _ToolBtn(
              key: const ValueKey('tool-lock'),
              icon: _locked ? Icons.lock : Icons.lock_open,
              tip: _srcTipLock,
              color: _locked ? _rt_Tw.emerald400 : _rt_Tw.amber400,
              active: !_locked,
              onTap: _toggleLock,
            ),
            const SizedBox(height: 4),
            _ToolBtn(
              key: const ValueKey('tool-pan'),
              icon: Icons.pan_tool,
              tip: _srcTipPan,
              color: _rt_Tw.emerald400,
              active: _panMode,
              onTap: _togglePan,
            ),
            const SizedBox(height: 4),
            _ToolBtn(
              key: const ValueKey('tool-labels'),
              icon: _labels ? Icons.label : Icons.label_off,
              tip: _srcTipLabels,
              color: _rt_Lab.text,
              active: false,
              onTap: _toggleLabels,
            ),
          ],
          tabs: [
            _rt_ShellTab(
              label: _tx.s('moduleSel'),
              icon: Icons.science,
              builder: (_) => _sidebar(),
            ),
          ],
          canvas: _rt_MinWidthGate(
            child: LayoutBuilder(
              builder: (context, c) => _canvasArea(c.biggest),
            ),
          ),
          canvasOverlays: [
            Positioned.fill(
              child: _rt_MinWidthGate(
                child: LayoutBuilder(
                  builder: (context, c) =>
                      Stack(children: _overlays(c.biggest)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------- canvas ---
  Widget _canvasArea(Size size) {
    final fitW = math.max(120.0, size.width - _kGutter);
    // Source calculateBaseScale: min(w / 980, h / 640) * 0.95.
    _base = math.min(fitW / _kW, size.height / _kH) * 0.95;
    _center = Offset(fitW / 2, size.height / 2);
    final c = _center + Offset(_camX, _camY);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onUp,
      onPointerSignal: _onSignal,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _BackdropPainter()),
          ),
          Positioned(
            left: c.dx - _kW / 2,
            top: c.dy - _kH / 2,
            width: _kW,
            height: _kH,
            child: Transform.scale(scale: _scale, child: _scene()),
          ),
        ],
      ),
    );
  }

  Widget _scene() {
    return SizedBox(
      width: _kW,
      height: _kH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _PlantPainter(_time))),
          ...switch (_scenario) {
            1 => _s1(),
            2 => _s2(),
            _ => _s3(),
          },
          ..._toolWidgets(),
        ],
      ),
    );
  }

  /// Gas & water wastes. Order follows the source's z-index layers.
  List<Widget> _s1() => [
    if (_sun) _zone(_zO2),
    if (_step >= 2) _zone(_zCanopy, extra: _vapor()),
    Positioned(left: 40, top: 30, width: 110, height: 110, child: _sunWidget()),
    Positioned(
      left: 40,
      top: 20,
      width: 110,
      child: IgnorePointer(child: _pill(_tx.s('lbl.sun'), block: true)),
    ),
    if (_sun)
      Positioned(
        left: 260,
        top: 90,
        width: 70,
        height: 70,
        child: IgnorePointer(child: _o2Bubble()),
      ),
    if (_jarPlaced)
      Positioned(
        left: 150,
        top: 95,
        width: 90,
        height: 120,
        child: IgnorePointer(child: CustomPaint(painter: _JarPainter(_time))),
      ),
  ];

  /// Waste in the living body.
  List<Widget> _s2() => [
    if (_step == 0) _zone(_zTrunk2),
    Positioned(
      left: 715,
      top: 35,
      width: 230,
      height: 210,
      child: _cellInset(),
    ),
    Positioned(
      left: 160,
      top: 260,
      width: 115,
      height: 115,
      child: _leafWidget(),
    ),
  ];

  /// Resins, gums & soil excretion.
  List<Widget> _s3() => [
    if (_step == 0 && !_sawCut) _zone(_zTrunk3),
    if (_step == 2)
      _zone(
        _zSoil,
        extra: Positioned.fill(
          child: CustomPaint(painter: _RipplePainter(_time)),
        ),
      ),
    Positioned(
      left: 715,
      top: 35,
      width: 230,
      height: 230,
      child: _trunkInset(),
    ),
  ];

  /// The source's `.label-text` pill (hidden by the Toggle Labels tool).
  Widget _pill(
    String text, {
    Color? bg,
    Color? fg,
    Color? border,
    bool block = false,
  }) {
    return AnimatedOpacity(
      opacity: _labels ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: bg ?? const Color(0xEB0F172A),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border ?? const Color(0xD9334155)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x73000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          textAlign: block ? TextAlign.center : null,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.27,
            height: 1.35,
            color: fg ?? const Color(0xFFF8FAFC),
          ),
        ),
      ),
    );
  }

  /// Bouncing call-to-action badge (source "CLICK" / "SHED LEAF").
  Widget _badge(
    String text,
    double t, {
    required Color bg,
    required Color fg,
    required Color border,
    IconData? icon,
  }) {
    const h = 26.0;
    return Transform.translate(
      offset: Offset(0, _bounce(t) * h),
      child: Container(
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 5),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoneBox(_ZoneSpec z, {Widget? extra}) {
    final over = _hover.contains(z.id);
    return IgnorePointer(
      child: AnimatedScale(
        scale: over ? 1.05 : 1,
        duration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          key: ValueKey('zone-${z.id}'),
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: over ? const Color(0x4D10B981) : z.fill,
            borderRadius: BorderRadius.circular(z.radius),
            boxShadow: over
                ? const [BoxShadow(color: Color(0x8010B981), blurRadius: 30)]
                : null,
          ),
          child: CustomPaint(
            foregroundPainter: _DashPainter(
              over ? _rt_Tw.emerald500 : z.color,
              z.radius,
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                ?extra,
                OverflowBox(
                  maxWidth: 600,
                  child: _pill(
                    z.label ?? _tx.s('lbl.${z.labelKey}'),
                    bg: z.labelBg,
                    fg: z.labelFg,
                    border: z.labelBorder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _zone(_ZoneSpec z, {Widget? extra}) => Positioned.fromRect(
    rect: z.rect,
    child: _zoneBox(z, extra: extra),
  );

  Widget _sunWidget() {
    final active = _step == 0;
    return GestureDetector(
      key: const ValueKey('sun'),
      behavior: HitTestBehavior.opaque,
      onTap: active ? _clickSun : null,
      child: ValueListenableBuilder<double>(
        valueListenable: _time,
        builder: (context, t, _) {
          final p = active ? _pulse(t) : 0.0;
          return Transform.scale(
            scale: 1 + 0.08 * p,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SunPainter(t, active ? p : null),
                  ),
                ),
                if (active && !_sun)
                  Positioned(
                    left: 120,
                    top: 55,
                    child: _badge(
                      _srcClick,
                      t,
                      bg: _rt_Tw.emerald400,
                      fg: _emerald950,
                      border: _rt_Tw.emerald600,
                      icon: Icons.arrow_back,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// `animate-o2-float` (2.2 s). The source puts its bubble `<circle>` straight
  /// in a `<div>`, where it does not render; it is drawn here.
  Widget _o2Bubble() {
    return ValueListenableBuilder<double>(
      valueListenable: _time,
      builder: (context, t, _) {
        final p = (t % 2.2) / 2.2;
        double y, s, o, glow;
        if (p < 0.5) {
          final e = Curves.easeOut.transform(p * 2);
          y = -18 * e;
          s = 0.9 + 0.25 * e;
          o = 0.4 + 0.6 * e;
          glow = e;
        } else {
          final e = Curves.easeOut.transform((p - 0.5) * 2);
          y = -18 - 20 * e;
          s = 1.15 + 0.1 * e;
          o = 1 - e;
          glow = 1 - e;
        }
        return Opacity(
          opacity: o.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, y),
            child: Transform.scale(
              scale: s,
              child: CustomPaint(
                painter: _BubblePainter(glow),
                child: const Center(
                  child: Text(
                    'O₂',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _emerald300,
                      shadows: [
                        Shadow(
                          color: Color(0x80000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// `animate-vapor` water drop inside the canopy zone (2.4 s).
  Widget _vapor() {
    return Positioned.fill(
      child: ValueListenableBuilder<double>(
        valueListenable: _time,
        builder: (context, t, _) {
          final p = (t % 2.4) / 2.4;
          double y, s, o;
          if (p < 0.5) {
            final e = Curves.easeOut.transform(p * 2);
            y = -20 * e;
            s = 0.85 + 0.25 * e;
            o = 0.2 + 0.65 * e;
          } else {
            final e = Curves.easeOut.transform((p - 0.5) * 2);
            y = -20 - 25 * e;
            s = 1.1 + 0.2 * e;
            o = 0.85 * (1 - e);
          }
          return Opacity(
            opacity: o.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, y),
              child: Transform.scale(
                scale: s,
                child: Center(
                  child: Icon(
                    Icons.water_drop,
                    size: 26,
                    color: _rt_Tw.sky400.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The source's `.station-card` inset (Plant Cell / Wood Cross-Section).
  BoxDecoration _station({bool glowing = false, double pulse = 0}) =>
      BoxDecoration(
        color: const Color(0xBF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: glowing ? _rt_Tw.emerald400 : const Color(0xB3334155),
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
          if (glowing)
            BoxShadow(
              color: _rt_Tw.emerald500.withValues(alpha: 0.5 + 0.4 * pulse),
              blurRadius: 12 + 14 * pulse,
            ),
        ],
      );

  Widget _cellInset() {
    final active = _step == 1;
    return GestureDetector(
      key: const ValueKey('cell-inset'),
      behavior: HitTestBehavior.opaque,
      onTap: active ? _clickCell : null,
      child: ValueListenableBuilder<double>(
        valueListenable: _time,
        builder: (context, t, _) {
          final p = active ? _pulse(t) : 0.0;
          return Transform.scale(
            scale: 1 + 0.08 * p,
            child: Container(
              decoration: _station(glowing: active, pulse: p),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: CustomPaint(
                        painter: _CellPainter(_pulseOpacity(t)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -14,
                    left: 16,
                    child: _pill(
                      _tx.s('lbl.cell'),
                      bg: _emerald950,
                      fg: _emerald300,
                      border: const Color(0x8010B981),
                    ),
                  ),
                  if (active)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _badge(
                        _srcClick,
                        t,
                        bg: _rt_Tw.emerald400,
                        fg: _emerald950,
                        border: _rt_Tw.emerald600,
                      ),
                    ),
                  if (_step == 2)
                    Positioned(
                      left: _zVacuole.inInset!.dx,
                      top: _zVacuole.inInset!.dy,
                      width: _zVacuole.rect.width,
                      height: _zVacuole.rect.height,
                      child: _zoneBox(_zVacuole),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _trunkInset() {
    return AnimatedOpacity(
      opacity: _step >= 1 ? 1 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: const ValueKey('trunk-inset'),
        decoration: _station(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(11),
                child: CustomPaint(painter: _TrunkPainter()),
              ),
            ),
            Positioned(
              top: -14,
              left: 16,
              child: _pill(
                _tx.s('lbl.trunk'),
                bg: _amber950,
                fg: _amber300,
                border: const Color(0x80F59E0B),
              ),
            ),
            if (_step == 1)
              Positioned(
                left: _zOldXylem.inInset!.dx,
                top: _zOldXylem.inInset!.dy,
                width: _zOldXylem.rect.width,
                height: _zOldXylem.rect.height,
                child: _zoneBox(_zOldXylem),
              ),
          ],
        ),
      ),
    );
  }

  /// The yellow ageing leaf. Source GSAP: x +65, y +195, rotation 95°,
  /// 0.95 s power2.inOut. Once shed it stays on the soil.
  Widget _leafWidget() {
    final active = _step == 3 && !_leafFell;
    return AnimatedBuilder(
      animation: Listenable.merge([_leafFall, _time]),
      builder: (context, _) {
        final f = _leafFell
            ? Curves.easeInOutQuad.transform(_leafFall.value)
            : 0.0;
        final p = active ? _pulse(_time.value) : 0.0;
        return Transform.translate(
          offset: Offset(65 * f, 195 * f),
          child: Transform.rotate(
            angle: 95 * math.pi / 180 * f,
            child: Transform.scale(
              scale: 1 + 0.08 * p,
              child: GestureDetector(
                key: const ValueKey('yellow-leaf'),
                behavior: HitTestBehavior.opaque,
                onTap: active ? _clickLeaf : null,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LeafPainter(active ? p : null),
                      ),
                    ),
                    Positioned(
                      top: -24,
                      left: -100,
                      right: -100,
                      child: Center(
                        child: _pill(_tx.s('lbl.leaf'), fg: _amber300),
                      ),
                    ),
                    if (active)
                      Positioned(
                        top: -8,
                        right: -16,
                        child: _badge(
                          _srcShedLeaf,
                          _time.value,
                          bg: _rt_Tw.amber400,
                          fg: _amber950,
                          border: _rt_Tw.amber600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The z-50 tools; the one being dragged is drawn on top (z-1000).
  List<Widget> _toolWidgets() {
    final list = _tools.toList();
    final i = list.indexWhere((t) => t.id == _dragId);
    if (i >= 0) list.add(list.removeAt(i));
    return [for (final t in list) _tool(t)];
  }

  Widget _tool(_ToolSpec t) {
    final dragging = _dragId == t.id;
    final r = t.rect.shift(_toolOff[t.id] ?? Offset.zero);
    Widget art = CustomPaint(painter: _toolPainter(t.id));
    if (dragging) {
      // `.is-dragging`: brightness(1.25).
      art = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          1.25, 0, 0, 0, 0, //
          0, 1.25, 0, 0, 0,
          0, 0, 1.25, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: art,
      );
    }
    return AnimatedPositioned(
      key: ValueKey('pos-${t.id}'),
      duration: dragging ? Duration.zero : const Duration(milliseconds: 200),
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: IgnorePointer(
        child: Stack(
          key: ValueKey('tool-${t.id}'),
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: art),
            Positioned(
              top: -24,
              left: -100,
              right: -100,
              child: Center(
                child: _pill(_tx.s('lbl.${t.id}'), fg: t.labelColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomPainter _toolPainter(String id) => switch (id) {
    'sensor' => _SensorPainter(_time),
    'jar' => _JarPainter(_time),
    'mag' => const _MagnifierPainter(),
    'crystals' => const _CrystalsPainter(),
    'saw' => const _SawPainter(),
    'resin' => _ResinPainter(_time),
    _ => _ProbePainter(_time),
  };

  // --------------------------------------------------------- overlays ---
  List<Widget> _overlays(Size size) {
    final hudW = (size.width * 0.4).clamp(190.0, 360.0);
    final free = size.width - _kGutter - 10;
    final popW = math.min(600.0, free - 16);
    final finW = math.min(640.0, free - 16);
    final top = size.height * 0.12;
    final maxH = math.max(160.0, size.height - top - 8);
    return [
      // Source: bottom 24 / left 35. Docked bottom-right here, left of the
      // toolbar: on a phone the bottom-left corner holds the soil zone and
      // the fallen leaf. Still draggable by its header.
      Positioned(
        right: _kGutter + 10,
        bottom: 10,
        width: hudW,
        child: Transform.translate(offset: _hudOff, child: _hud(size, hudW)),
      ),
      if (_obs)
        Positioned(
          left: math.max(8.0, (free - popW) / 2),
          top: top,
          width: popW,
          child: Transform.translate(
            offset: _obsOff,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: _obsCard(size, popW),
            ),
          ),
        ),
      if (_final)
        Positioned(
          left: math.max(8.0, (free - finW) / 2),
          top: top,
          width: finW,
          child: Transform.translate(
            offset: _finalOff,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: _finalCard(size, finW),
            ),
          ),
        ),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(_confetti, _fetti, _fettiY),
          ),
        ),
      ),
    ];
  }

  /// Keeps a dragged card's header reachable inside the canvas.
  Offset _clampDrag(
    Offset o,
    Size canvas, {
    required double left,
    required double width,
    required double top,
  }) {
    return Offset(
      o.dx.clamp(-left - width + 60, canvas.width - left - 60),
      o.dy.clamp(-top, math.max(0.0, canvas.height - top - 50)),
    );
  }

  Widget _hud(Size canvas, double w) {
    final steps = _steps;
    final step = steps[_step] as Map;
    final hudLeft = canvas.width - _kGutter - 10 - w;
    return Container(
      key: const ValueKey('hud'),
      decoration: BoxDecoration(
        color: _rt_Lab.base.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: _rt_Tw.emerald500),
          GestureDetector(
            key: const ValueKey('hud-handle'),
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => setState(() {
              // The HUD is anchored bottom-right; its height is roughly 120.
              final o = _hudOff + d.delta;
              _hudOff = Offset(
                o.dx.clamp(-hudLeft, _kGutter + 4),
                o.dy.clamp(-(canvas.height - 60), 4.0),
              );
            }),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
              decoration: BoxDecoration(
                color: _rt_Lab.canvas.withValues(alpha: 0.7),
                border: Border(bottom: BorderSide(color: _rt_Lab.border)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: _rt_Lab.textMuted,
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.science, size: 13, color: _rt_Tw.emerald400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _tx.s('missionReady').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: _rt_Tw.emerald400,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Tw.emerald500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: _rt_Tw.emerald500.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$_srcStep ${math.min(_step + 1, steps.length)}/${steps.length}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Tw.emerald400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step['i'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: _rt_Lab.text,
                  ),
                ),
                AnimatedOpacity(
                  opacity: _feedback == null ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Tw.emerald500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _fbText,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _rt_Tw.emerald400,
                      ),
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

  /// Renders the `<e>..</e>`-style coloured bold spans (the source's inline HTML).
  static final _spanRe = RegExp(r'<(e|b3|b|i|a3|a)>(.*?)</\1>');

  Widget _rich(String s, TextStyle base) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in _spanRe.allMatches(s)) {
      if (m.start > last) spans.add(TextSpan(text: s.substring(last, m.start)));
      spans.add(
        TextSpan(
          text: m.group(2),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _spanColors[m.group(1)],
          ),
        ),
      );
      last = m.end;
    }
    if (last < s.length) spans.add(TextSpan(text: s.substring(last)));
    return Text.rich(TextSpan(style: base, children: spans));
  }

  Widget _closeX(String key, VoidCallback onTap) => InkResponse(
    key: ValueKey(key),
    radius: 18,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(Icons.close, size: 18, color: _rt_Lab.textMuted),
    ),
  );

  /// Emerald pill button with dark text (source OK / Restart buttons).
  Widget _greenButton(
    String key,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: _rt_Tw.emerald500,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey(key),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: _rt_Tw.slate950),
              const SizedBox(width: 7),
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

  /// Source #observation-popup with the step conclusion.
  Widget _obsCard(Size canvas, double w) {
    final c = _tx.map('s${_scenario}_conclusion');
    final items = (c['items'] as List).cast<String>();
    final left = math.max(8.0, (canvas.width - _kGutter - 10 - w) / 2);
    final top = canvas.height * 0.12;
    return Container(
      key: const ValueKey('obs-card'),
      decoration: BoxDecoration(
        color: _rt_Lab.canvas,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _rt_Tw.emerald500.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 50,
            offset: Offset(0, 24),
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
              () => _obsOff = _clampDrag(
                _obsOff + d.delta,
                canvas,
                left: left,
                width: w,
                top: top,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_emerald950.withValues(alpha: 0.9), _rt_Tw.slate900],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _rt_Tw.emerald500.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 22,
                    color: _rt_Tw.emerald400,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _tx.s('sciObs'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _rt_Tw.emerald400,
                      ),
                    ),
                  ),
                  _closeX('obs-close', _closeObservation),
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    c['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _rt_Tw.emerald400,
                    ),
                  ),
                  Container(
                    height: 1,
                    color: _rt_Lab.border,
                    margin: const EdgeInsets.only(top: 7, bottom: 11),
                  ),
                  Text(
                    c['intro'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: _rt_Lab.text,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    decoration: BoxDecoration(
                      color: _rt_Lab.canvas,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _rt_Lab.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final it in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _rich(
                              it,
                              TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: _rt_Lab.text,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: _rt_Tw.emerald500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _rt_Tw.emerald500.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      c['takeaway'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: _rt_Tw.emerald400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _rt_Lab.border)),
            ),
            alignment: Alignment.centerRight,
            child: _greenButton(
              'obs-ok',
              Icons.check,
              _tx.s('btnOk'),
              _confirmObservation,
            ),
          ),
        ],
      ),
    );
  }

  /// Source #final-mastery-modal.
  Widget _finalCard(Size canvas, double w) {
    final items = _tx.list('final_summary');
    const looks = [
      (Icons.air, _rt_Tw.emerald400, Color(0x4D10B981)),
      (Icons.bubble_chart, _purple400, Color(0x4DA855F7)),
      (Icons.eco, _rt_Tw.amber400, Color(0x4DF59E0B)),
      (Icons.account_tree, _rt_Tw.amber500, Color(0x4DD97706)),
    ];
    final left = math.max(8.0, (canvas.width - _kGutter - 10 - w) / 2);
    final top = canvas.height * 0.12;
    final cols = w >= 440 ? 2 : 1;
    Widget card(int i) {
      final it = items[i] as Map;
      final (icon, color, border) = looks[i];
      return Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xE60F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    it['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    it['text'] as String,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: _rt_Tw.slate300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey('final-card'),
      decoration: BoxDecoration(
        color: _rt_Lab.canvas,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _rt_Tw.emerald500.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xCC000000),
            blurRadius: 60,
            offset: Offset(0, 28),
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
              () => _finalOff = _clampDrag(
                _finalOff + d.delta,
                canvas,
                left: left,
                width: w,
                top: top,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_emerald950, _rt_Tw.slate900, _teal950],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _rt_Tw.emerald500.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _rt_Tw.emerald500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _rt_Tw.emerald400),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 22,
                      color: _emerald300,
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
                            fontSize: 15.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tx.s('subtitle'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _rt_Tw.emerald400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _closeX('final-close', _closeFinal),
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (var r = 0; r < items.length; r += cols)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: r + cols < items.length ? 10 : 0,
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var c = 0; c < cols; c++) ...[
                              if (c > 0) const SizedBox(width: 10),
                              Expanded(
                                child: r + c < items.length
                                    ? card(r + c)
                                    : const SizedBox(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
            decoration: BoxDecoration(
              color: _rt_Lab.base,
              border: Border(top: BorderSide(color: _rt_Lab.border)),
            ),
            alignment: Alignment.center,
            child: _greenButton(
              'final-restart',
              Icons.replay,
              _tx.s('btnRestartLab'),
              () {
                _rt_playSfx(_rt_Sfx.click);
                _restart();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _sideLabel(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Icon(icon, size: 13, color: _rt_Tw.emerald400),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: _rt_Tw.emerald400,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sidebar() {
    final steps = _steps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sideLabel(Icons.science, _tx.s('moduleSel')),
          Container(
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: BoxDecoration(
              color: _rt_Lab.base,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.borderStrong, width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const ValueKey('module-select'),
                value: _scenario,
                isExpanded: true,
                onTap: () => _rt_playSfx(_rt_Sfx.dropdown),
                itemHeight: null,
                dropdownColor: _rt_Lab.surface,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(Icons.expand_more, color: _rt_Lab.textMuted),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.text,
                ),
                items: [
                  for (var n = 1; n <= 3; n++)
                    DropdownMenuItem(
                      value: n,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _tx.s('s${n}_title'),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _rt_Lab.text,
                          ),
                        ),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) _selectModule(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sideLabel(Icons.track_changes, _tx.s('missionObj')),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _rt_Lab.canvas,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Text(
              _tx.s('s${_scenario}_obj'),
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: _rt_Lab.text,
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            _accordionItem(i, steps[i] as Map),
        ],
      ),
    );
  }

  Widget _accordionItem(int i, Map step) {
    final active = i == _step;
    final past = i < _step;
    final open = _open == i;
    final Widget status = past
        ? const Icon(Icons.check_circle, size: 18, color: _rt_Tw.emerald400)
        : active
        ? RotationTransition(
            turns: _spin,
            child: const Icon(
              Icons.autorenew,
              size: 18,
              color: _rt_Tw.emerald400,
            ),
          )
        : Icon(
            Icons.radio_button_unchecked,
            size: 18,
            color: _rt_Lab.textMuted,
          );
    return Opacity(
      opacity: past ? 0.7 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          color: _rt_Lab.canvas.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? _rt_Tw.emerald500 : _rt_Lab.border,
          ),
          boxShadow: [
            BoxShadow(
              color: _rt_Lab.shadow,
              blurRadius: active ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              key: ValueKey('acc-$i'),
              onTap: () => _toggleAccordion(i),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 11, 9, 11),
                child: Row(
                  children: [
                    status,
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        step['t'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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
              duration: const Duration(milliseconds: 350),
              curve: const Cubic(0.4, 0, 0.2, 1),
              alignment: Alignment.topCenter,
              child: open
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                      decoration: BoxDecoration(
                        color: _rt_Lab.base,
                        border: Border(top: BorderSide(color: _rt_Lab.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _accHeading(
                            Icons.play_arrow,
                            _tx.s('taskInstr'),
                            _rt_Tw.emerald400,
                          ),
                          Text(
                            step['i'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: _rt_Lab.text,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _accHeading(
                            Icons.visibility,
                            _tx.s('expOut'),
                            _rt_Tw.blue400,
                          ),
                          Text(
                            step['o'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.45,
                              color: _rt_Lab.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accHeading(IconData icon, String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------ widgets ---

/// Round canvas-toolbar toggle (the source's viewport tools).
class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    super.key,
    required this.icon,
    required this.tip,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tip;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        radius: 22,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.18) : _rt_Lab.surface,
            shape: BoxShape.circle,
            border: active
                ? Border.all(color: color.withValues(alpha: 0.6))
                : null,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- painters ---

/// Draws an SVG viewBox [vw] x [vh] centred in [size] (`xMidYMid meet`).
void _fit(Canvas c, Size size, double vw, double vh) {
  final k = math.min(size.width / vw, size.height / vh);
  c.translate((size.width - vw * k) / 2, (size.height - vh * k) / 2);
  c.scale(k);
}

Paint _fill(Color c) => Paint()..color = c;

Paint _line(Color c, double w, {StrokeCap cap = StrokeCap.butt}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..color = c
  ..strokeCap = cap
  ..strokeJoin = StrokeJoin.round;

/// SVG `<text text-anchor="middle">` at baseline [y].
void _svgText(
  Canvas c,
  String s,
  double x,
  double y,
  double size,
  FontWeight w,
  Color color,
) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(fontSize: size, fontWeight: w, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final base = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  tp.paint(c, Offset(x - tp.width / 2, y - base));
}

Path _poly(List<double> xy) {
  final p = Path()..moveTo(xy[0], xy[1]);
  for (var i = 2; i < xy.length; i += 2) {
    p.lineTo(xy[i], xy[i + 1]);
  }
  return p..close();
}

Path _dashed(Path src, double dash, double gap) {
  final out = Path();
  for (final m in src.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

/// #scene-wrapper backdrop: two soft radial washes over the dark canvas.
class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, _fill(_rt_Lab.canvas));
    canvas.drawRect(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.5),
          radius: 0.95,
          colors: [Color(0x1F10B981), Color(0x0010B981)],
          stops: [0, 0.65],
        ).createShader(r),
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.7),
          radius: 0.8,
          colors: [Color(0x14D97706), Color(0x00D97706)],
          stops: [0, 0.6],
        ).createShader(r),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _bark = LinearGradient(
  colors: [
    Color(0xFF2D150B),
    Color(0xFF4A2818),
    Color(0xFF3B1D10),
    Color(0xFF1F0C05),
  ],
  stops: [0, 0.3, 0.7, 1],
);
const _canopy1 = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF15803D)],
  stops: [0, 0.4, 1],
);
const _canopy2 = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4ADE80), Color(0xFF16A34A), Color(0xFF052E16)],
  stops: [0, 0.5, 1],
);

/// SVGS.masterPlant: soil horizons, roots, trunk and the swaying canopy.
class _PlantPainter extends CustomPainter {
  _PlantPainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;

  static Path _q(
    double x0,
    double y0,
    double cx,
    double cy,
    double x1,
    double y1,
  ) => Path()
    ..moveTo(x0, y0)
    ..quadraticBezierTo(cx, cy, x1, y1);

  static Path _c(List<double> v) {
    final p = Path()..moveTo(v[0], v[1]);
    for (var i = 2; i + 5 < v.length; i += 6) {
      p.cubicTo(v[i], v[i + 1], v[i + 2], v[i + 3], v[i + 4], v[i + 5]);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _kW, size.height / _kH);

    // Layered soil horizons.
    const soil = Rect.fromLTWH(0, 450, 980, 190);
    canvas.drawRect(
      soil,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF452414), Color(0xFF2D160B), Color(0xFF180A04)],
          stops: [0, 0.3, 1],
        ).createShader(soil),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 450)
        ..quadraticBezierTo(250, 445, 500, 450)
        ..quadraticBezierTo(750, 455, 980, 448),
      _line(const Color(0xFF663920), 8),
    );
    final granule = _fill(const Color(0xBF522B17));
    for (final (x, y, r) in const [
      (110.0, 490.0, 10.0),
      (280.0, 530.0, 14.0),
      (460.0, 480.0, 12.0),
      (690.0, 540.0, 16.0), //
      (840.0, 500.0, 12.0),
      (360.0, 580.0, 16.0),
      (180.0, 570.0, 14.0),
      (560.0, 590.0, 13.0),
    ]) {
      canvas.drawCircle(Offset(x, y), r, granule);
    }

    // Roots.
    const root = Color(0xFF8D6E63);
    void drawRoot(Path p, double w, [Color c = root]) =>
        canvas.drawPath(p, _line(c, w, cap: StrokeCap.round));
    drawRoot(_q(450, 450, 440, 520, 430, 600), 18, const Color(0xFF5D4037));
    drawRoot(_q(430, 600, 425, 625, 420, 638), 9, const Color(0xFF4E342E));
    drawRoot(_q(445, 470, 370, 495, 290, 535), 12);
    drawRoot(_q(290, 535, 230, 565, 170, 590), 6);
    drawRoot(_q(370, 495, 340, 545, 310, 605), 7);
    drawRoot(_q(450, 470, 540, 500, 620, 545), 12);
    drawRoot(_q(620, 545, 690, 570, 760, 600), 6);
    drawRoot(_q(540, 500, 570, 550, 590, 610), 7);

    // Trunk with bark contours.
    final trunk = Path()
      ..moveTo(430, 455)
      ..quadraticBezierTo(420, 340, 410, 240)
      ..lineTo(470, 240)
      ..quadraticBezierTo(465, 340, 470, 455)
      ..close();
    canvas.drawPath(
      trunk,
      Paint()..shader = _bark.createShader(trunk.getBounds()),
    );
    canvas.drawPath(trunk, _line(const Color(0xFF1A0A04), 2.5));
    final contour = _line(const Color(0x991F0C05), 3);
    canvas.drawPath(_q(438, 430, 430, 330, 425, 250), contour);
    canvas.drawPath(_q(455, 435, 450, 340, 452, 250), contour);

    // Branches + canopy sway about the bottom centre (490, 640).
    final f = _sway(time.value);
    canvas.save();
    canvas.translate(490, 640);
    canvas.rotate(1.2 * math.pi / 180 * f);
    canvas.translate(0, -2 * f);
    canvas.translate(-490, -640);

    for (final (p, w) in [
      (_q(420, 310, 330, 270, 240, 190), 16.0),
      (_q(270, 210, 190, 160, 130, 110), 10.0),
      (_q(455, 290, 550, 250, 630, 170), 15.0),
      (_q(440, 240, 430, 160, 420, 80), 13.0),
    ]) {
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..shader = _bark.createShader(p.getBounds().inflate(w / 2)),
      );
    }

    final leaves = <(Path, LinearGradient, Color, double)>[
      (
        _c([
          110,
          110,
          70,
          70,
          90,
          20,
          150,
          30,
          210,
          40,
          230,
          100,
          190,
          130,
          150,
          150,
          130,
          130,
          110,
          110,
        ]),
        _canopy2,
        const Color(0xFF052E16),
        2,
      ),
      (
        _c([
          160,
          150,
          110,
          150,
          120,
          210,
          180,
          220,
          240,
          230,
          270,
          170,
          230,
          140,
        ]),
        _canopy1,
        const Color(0xFF0F5132),
        1.5,
      ),
      (
        _c([50, 130, 20, 100, 40, 50, 90, 60, 130, 70, 140, 130, 90, 150]),
        _canopy1,
        const Color(0xFF0F5132),
        1.5,
      ),
      (
        _c([
          390,
          70,
          340,
          20,
          410,
          -10,
          470,
          10,
          530,
          30,
          550,
          90,
          490,
          110,
          440,
          120,
          410,
          100,
          390,
          70,
        ]),
        _canopy1,
        const Color(0xFF0F5132),
        2,
      ),
      (
        _c([320, 90, 280, 70, 300, 20, 350, 30, 400, 40, 400, 100, 360, 110]),
        _canopy2,
        const Color(0xFF052E16),
        1.5,
      ),
      (
        _c([
          530,
          150,
          480,
          130,
          560,
          60,
          620,
          90,
          670,
          110,
          650,
          180,
          590,
          180,
        ]),
        _canopy2,
        const Color(0xFF052E16),
        1.5,
      ),
    ];
    // drop-shadow(0 6px 14px rgba(0,0,0,0.35)) on the foliage group.
    final shadow = Paint()
      ..color = const Color(0x59000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    for (final l in leaves) {
      canvas.drawPath(l.$1.shift(const Offset(0, 6)), shadow);
    }
    for (final (p, g, stroke, w) in leaves) {
      canvas.drawPath(p, Paint()..shader = g.createShader(p.getBounds()));
      canvas.drawPath(p, _line(stroke, w));
    }

    // Sunlight streams (group opacity 0.35).
    for (final p in [
      _poly([160, 0, 230, 0, 340, 240, 240, 240]),
      _poly([300, 0, 380, 0, 460, 200, 360, 200]),
    ]) {
      canvas.drawPath(
        p,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.4, -0.6),
            radius: 0.7,
            colors: [Color(0x27FACC15), Color(0x00FACC15)],
          ).createShader(p.getBounds()),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) => false;
}

/// SVGS.sun; [pulse] adds the `pulse-interactive` emerald glow.
class _SunPainter extends CustomPainter {
  _SunPainter(this.t, this.pulse);
  final double t;
  final double? pulse;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 100, 100);
    const c = Offset(50, 50);
    if (pulse != null) {
      canvas.drawCircle(
        c,
        38,
        Paint()
          ..color = _rt_Tw.emerald500.withValues(alpha: 0.5 + 0.4 * pulse!)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 7 * pulse!),
      );
    }
    // drop-shadow-[0_0_35px_rgba(250,204,21,0.85)]
    canvas.drawCircle(
      c,
      30,
      Paint()
        ..color = const Color(0xD9FACC15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(c, 26, _fill(_rt_Tw.yellow400));
    canvas.drawCircle(c, 21, _fill(const Color(0xFFFEF08A)));
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(t / 25 * 2 * math.pi); // sun-rays-spin, 25 s
    canvas.translate(-50, -50);
    final ray = _line(_rt_Tw.yellow400, 5, cap: StrokeCap.round);
    for (final (x0, y0, x1, y1) in const [
      (50.0, 8.0, 50.0, 18.0),
      (50.0, 82.0, 50.0, 92.0),
      (8.0, 50.0, 18.0, 50.0),
      (82.0, 50.0, 92.0, 50.0), //
      (20.0, 20.0, 28.0, 28.0),
      (72.0, 72.0, 80.0, 80.0),
      (20.0, 80.0, 28.0, 72.0),
      (72.0, 28.0, 80.0, 20.0),
    ]) {
      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), ray);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunPainter old) =>
      old.t != t || old.pulse != pulse;
}

/// The O₂ bubble the source meant to draw (r 30, green fill and stroke).
class _BubblePainter extends CustomPainter {
  _BubblePainter(this.glow);
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 70, 70);
    const c = Offset(35, 35);
    if (glow > 0) {
      canvas.drawCircle(
        c,
        32,
        Paint()
          ..color = _rt_Tw.green500.withValues(alpha: 0.6 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
    canvas.drawCircle(c, 30, _fill(const Color(0x5922C55E)));
    canvas.drawCircle(c, 30, _line(_rt_Tw.green500, 3));
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.glow != glow;
}

/// SVGS.gasCollector.
class _SensorPainter extends CustomPainter {
  _SensorPainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 85, 115);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, 24, 40, 70),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xBFFFFFFF), Color(0x33FFFFFF), Color(0xA6FFFFFF)],
          stops: [0, 0.4, 1],
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(body, _line(_rt_Tw.sky400, 3));
    final cap = RRect.fromRectAndRadius(
      const Rect.fromLTWH(30, 8, 24, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(cap, _fill(_rt_Tw.slate900));
    canvas.drawRRect(cap, _line(_rt_Tw.sky400, 2));
    canvas.drawCircle(const Offset(42, 56), 14, _fill(const Color(0x4D22C55E)));
    canvas.drawCircle(const Offset(42, 56), 14, _line(_rt_Tw.green500, 2));
    _svgText(canvas, 'O₂', 42, 60, 11, FontWeight.w900, _rt_Tw.green500);
    canvas.drawCircle(
      const Offset(42, 17),
      3,
      _fill(_rt_Tw.sky400.withValues(alpha: _pulseOpacity(time.value))),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.condensationJar.
class _JarPainter extends CustomPainter {
  _JarPainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 100, 135);
    final jar = Path()
      ..moveTo(30, 15)
      ..lineTo(70, 15)
      ..lineTo(88, 118)
      ..arcToPoint(const Offset(78, 130), radius: const Radius.circular(10))
      ..lineTo(22, 130)
      ..arcToPoint(const Offset(12, 118), radius: const Radius.circular(10))
      ..close();
    canvas.drawPath(
      jar,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xA6FFFFFF),
            Color(0x1AFFFFFF),
            Color(0x1AFFFFFF),
            Color(0x8CFFFFFF),
          ],
          stops: [0, 0.25, 0.75, 1],
        ).createShader(jar.getBounds()),
    );
    canvas.drawPath(jar, _line(_blue300, 3));
    final pulse = _pulseOpacity(time.value);
    for (final (x, y, r, c, pulsing) in [
      (34.0, 55.0, 4.5, _rt_Tw.blue400, true),
      (68.0, 70.0, 5.5, _blue300, true),
      (46.0, 90.0, 6.0, _rt_Tw.sky400, false),
      (72.0, 102.0, 5.0, _rt_Tw.blue400, false),
      (28.0, 110.0, 5.5, _blue300, false),
    ]) {
      canvas.drawCircle(
        Offset(x, y),
        r,
        _fill(c.withValues(alpha: pulsing ? pulse : 0.85)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.magnifier.
class _MagnifierPainter extends CustomPainter {
  const _MagnifierPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 100, 100);
    canvas.translate(10, 10);
    canvas.save();
    canvas.translate(53, 65);
    canvas.rotate(-45 * math.pi / 180);
    canvas.translate(-53, -65);
    final handle = RRect.fromRectAndRadius(
      const Rect.fromLTWH(45, 45, 16, 42),
      const Radius.circular(6),
    );
    canvas.drawRRect(handle, _fill(_rt_Tw.slate700));
    canvas.drawRRect(handle, _line(_rt_Tw.slate900, 2));
    canvas.restore();
    canvas.drawCircle(const Offset(35, 35), 32, _line(_rt_Tw.emerald500, 7));
    canvas.drawCircle(const Offset(35, 35), 28, _fill(const Color(0x40FFFFFF)));
    canvas.drawCircle(const Offset(35, 35), 28, _line(_emerald300, 2));
    canvas.drawPath(
      Path()
        ..moveTo(16, 22)
        ..quadraticBezierTo(30, 10, 50, 20),
      _line(const Color(0xD9FFFFFF), 4, cap: StrokeCap.round),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.wasteCrystals.
class _CrystalsPainter extends CustomPainter {
  const _CrystalsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 70, 70);
    for (final (pts, fill, stroke, w) in const [
      (
        [35.0, 8.0, 52.0, 24.0, 46.0, 58.0, 24.0, 58.0, 18.0, 24.0],
        _indigo400,
        _rt_Tw.indigo600,
        2.0,
      ),
      (
        [18.0, 28.0, 35.0, 18.0, 30.0, 48.0, 14.0, 42.0],
        _indigo300,
        _rt_Tw.indigo500,
        1.5,
      ),
      (
        [42.0, 24.0, 58.0, 34.0, 50.0, 60.0, 36.0, 52.0],
        _rt_Tw.indigo500,
        _rt_Tw.indigo700,
        1.5,
      ),
    ]) {
      final p = _poly(pts);
      canvas.drawPath(p, _fill(fill));
      canvas.drawPath(p, _line(stroke, w));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.yellowLeaf; [pulse] adds the `pulse-interactive` glow.
class _LeafPainter extends CustomPainter {
  _LeafPainter(this.pulse);
  final double? pulse;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 115, 115);
    final leaf = Path()
      ..moveTo(15, 55)
      ..cubicTo(15, 20, 55, 10, 100, 20)
      ..cubicTo(110, 60, 90, 100, 45, 100)
      ..cubicTo(25, 100, 15, 75, 15, 55)
      ..close();
    if (pulse != null) {
      canvas.drawPath(
        leaf,
        Paint()
          ..color = _rt_Tw.emerald500.withValues(alpha: 0.5 + 0.4 * pulse!)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 7 * pulse!),
      );
    }
    canvas.drawPath(
      leaf.shift(const Offset(0, 6)),
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      leaf,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF08A), _rt_Tw.yellow500, _rt_Tw.amber700],
          stops: [0, 0.5, 1],
        ).createShader(leaf.getBounds()),
    );
    canvas.drawPath(leaf, _line(const Color(0xFF92400E), 2.5));
    canvas.drawPath(
      Path()
        ..moveTo(15, 55)
        ..quadraticBezierTo(55, 50, 100, 20),
      _line(const Color(0xFF78350F), 3),
    );
    final spot = _fill(const Color(0xD978350F));
    canvas.drawCircle(const Offset(52, 38), 4, spot);
    canvas.drawCircle(const Offset(72, 62), 5, spot);
    canvas.drawCircle(const Offset(42, 74), 3.5, spot);
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.pulse != pulse;
}

/// SVGS.sawTool (the svg itself is rotated -15°).
class _SawPainter extends CustomPainter {
  const _SawPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-15 * math.pi / 180);
    canvas.translate(-size.width / 2, -size.height / 2);
    _fit(canvas, size, 105, 45);
    final grip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 12, 32, 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(grip, _fill(_rt_Tw.amber600));
    canvas.drawRRect(grip, _line(const Color(0xFF92400E), 2));
    final blade = _poly([36, 14, 100, 14, 90, 30, 36, 30]);
    canvas.drawPath(blade, _fill(_rt_Tw.slate300));
    canvas.drawPath(blade, _line(_rt_Tw.slate500, 1.5));
    final teeth = Path()..moveTo(40, 30);
    for (var x = 44.0; x <= 84; x += 4) {
      teeth.lineTo(x, (x - 40) % 8 == 0 ? 30 : 35);
    }
    canvas.drawPath(teeth, _line(_rt_Tw.slate600, 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.amberResin with its `resin-sparkle` glow (2 s).
class _ResinPainter extends CustomPainter {
  _ResinPainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 65, 65);
    final drop = Path()
      ..moveTo(32, 5)
      ..cubicTo(48, 5, 58, 22, 58, 38)
      ..cubicTo(58, 52, 46, 60, 32, 60)
      ..cubicTo(18, 60, 6, 52, 6, 38)
      ..cubicTo(6, 22, 16, 5, 32, 5)
      ..close();
    final g = _pulse(time.value);
    canvas.drawPath(
      drop,
      Paint()
        ..color = Color.lerp(
          _rt_Tw.amber500,
          _rt_Tw.amber400,
          g,
        )!.withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 8 * g),
    );
    canvas.drawPath(
      drop,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.6,
          colors: [Color(0xFFFEF08A), _rt_Tw.amber500, _rt_Tw.amber700],
          stops: [0, 0.5, 1],
        ).createShader(drop.getBounds()),
    );
    canvas.drawPath(drop, _line(const Color(0xFF78350F), 2.5));
    canvas.drawCircle(const Offset(24, 24), 5, _fill(const Color(0xB3FFFFFF)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.soilProbe.
class _ProbePainter extends CustomPainter {
  _ProbePainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 65, 105);
    final rod = RRect.fromRectAndRadius(
      const Rect.fromLTWH(27, 10, 10, 75),
      const Radius.circular(3),
    );
    canvas.drawRRect(rod, _fill(_rt_Tw.slate400));
    canvas.drawRRect(rod, _line(_rt_Tw.slate600, 2));
    canvas.drawPath(_poly([27, 85, 37, 85, 32, 100]), _fill(_rt_Tw.slate500));
    final head = RRect.fromRectAndRadius(
      const Rect.fromLTWH(18, 10, 28, 26),
      const Radius.circular(6),
    );
    canvas.drawRRect(head, _fill(_rt_Tw.slate900));
    canvas.drawRRect(head, _line(_rt_Tw.emerald500, 2));
    canvas.drawCircle(
      const Offset(32, 23),
      6,
      _fill(_rt_Tw.emerald500.withValues(alpha: _pulseOpacity(time.value))),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SVGS.cellDetail; [vacuoleOpacity] is the vacuole's `animate-pulse`.
class _CellPainter extends CustomPainter {
  _CellPainter(this.vacuoleOpacity);
  final double vacuoleOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 210, 190);
    final wall = _poly([105, 8, 198, 48, 198, 142, 105, 182, 12, 142, 12, 48]);
    canvas.drawPath(wall, _fill(const Color(0xFF052E16)));
    canvas.drawPath(
      wall,
      _line(_rt_Tw.green500, 6)..strokeJoin = StrokeJoin.miter,
    );
    final inner = _poly([
      105,
      15,
      190,
      52,
      190,
      138,
      105,
      174,
      20,
      138,
      20,
      52,
    ]);
    canvas.drawPath(inner, _fill(const Color(0xFF14532D)));
    canvas.drawPath(inner, _line(const Color(0xFF86EFAC), 1.5));
    final vac = Rect.fromCenter(
      center: const Offset(103, 102),
      width: 128,
      height: 104,
    );
    canvas.drawOval(
      vac,
      _fill(const Color(0xFFC7D2FE).withValues(alpha: vacuoleOpacity)),
    );
    canvas.drawOval(
      vac,
      _line(_rt_Tw.indigo600.withValues(alpha: vacuoleOpacity), 3),
    );
    _svgText(
      canvas,
      'VACUOLE',
      103,
      105,
      12,
      FontWeight.w900,
      _rt_Tw.indigo900,
    );
    _svgText(
      canvas,
      '(Waste Storage)',
      103,
      120,
      9,
      FontWeight.w700,
      _rt_Tw.indigo700,
    );
    canvas.drawCircle(const Offset(50, 60), 15, _fill(const Color(0xFF7C2D12)));
    canvas.drawCircle(const Offset(50, 60), 15, _line(_rt_Tw.orange600, 1.5));
  }

  @override
  bool shouldRepaint(covariant _CellPainter old) =>
      old.vacuoleOpacity != vacuoleOpacity;
}

/// SVGS.trunkDetail (wood cross-section with young / old xylem).
class _TrunkPainter extends CustomPainter {
  const _TrunkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 210, 210);
    const c = Offset(105, 105);
    final disc = Rect.fromCircle(center: c, radius: 100);
    canvas.drawCircle(
      c,
      100,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFF2D1305),
            Color(0xFF451A03),
            Color(0xFF78350F),
            _rt_Tw.amber600,
            Color(0xFF1C0F0A),
          ],
          stops: [0, 0.35, 0.4, 0.85, 1],
        ).createShader(disc),
    );
    canvas.drawCircle(c, 100, _line(const Color(0xFF1C0F0A), 5));
    canvas.drawCircle(c, 80, _line(const Color(0x9992400E), 1.5));
    canvas.drawCircle(c, 44, _fill(const Color(0xFF3B1604)));
    canvas.drawPath(
      _dashed(Path()..addOval(Rect.fromCircle(center: c, radius: 44)), 3, 2),
      _line(_rt_Tw.amber600, 2.5),
    );
    _svgText(
      canvas,
      'YOUNG XYLEM',
      105,
      48,
      9.5,
      FontWeight.bold,
      _rt_Tw.amber200,
    );
    _svgText(
      canvas,
      'OLD XYLEM',
      105,
      108,
      10.5,
      FontWeight.w900,
      _rt_Tw.amber400,
    );
    _svgText(
      canvas,
      '(Resins & Gums)',
      105,
      122,
      8.5,
      FontWeight.w700,
      _rt_Tw.amber500,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `animate-soil-ripple` circle (2.6 s) at (135, 57) of the soil zone.
class _RipplePainter extends CustomPainter {
  _RipplePainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final e = Curves.easeOut.transform((time.value % 2.6) / 2.6);
    canvas.drawCircle(
      const Offset(135, 57),
      6 + 36 * e,
      _line(_rt_Tw.emerald500.withValues(alpha: 0.95 * (1 - e)), 3 - 2 * e),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2 px dashed border of a `.dropzone` (Tailwind `border-dashed`).
class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      Radius.circular(radius - 1),
    );
    canvas.drawPath(_dashed(Path()..addRRect(r), 6, 4), _line(color, 2));
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) =>
      old.color != color || old.radius != radius;
}

/// canvas-confetti burst (angle 90°, decay 0.9, gravity 1, 200 ticks).
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.fetti, this.originY) : super(repaint: anim);
  final Animation<double> anim;
  final List<_Fetti> fetti;
  final double originY;

  @override
  void paint(Canvas canvas, Size size) {
    final v = anim.value;
    if (v <= 0 || v >= 1 || fetti.isEmpty) return;
    final n = v * 200;
    // Distances in the source are CSS px of a full window; keep the feel on
    // a phone-sized canvas.
    final k = (size.height / 700).clamp(0.45, 1.0);
    final travel = (1 - math.pow(0.9, n)) / 0.1;
    final ox = size.width / 2, oy = size.height * originY;
    final alpha = 1 - n / 200;
    for (final f in fetti) {
      final x = ox + math.cos(f.angle) * f.v0 * travel * k;
      final y = oy - math.sin(f.angle) * f.v0 * travel * k + 3 * n * k;
      final wob = f.wobble + f.wobbleSpeed * n;
      final tilt = f.tilt + 0.1 * n;
      final wx = x + 10 * k * math.cos(wob), wy = y + 10 * k * math.sin(wob);
      final rr = 2.5 * k;
      final x1 = x + rr * math.cos(tilt), y1 = y + rr * math.sin(tilt);
      final x2 = wx + rr * math.cos(tilt), y2 = wy + rr * math.sin(tilt);
      final paint = _fill(f.color.withValues(alpha: alpha));
      if (f.circle) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: math.max(1.5, (x2 - x1).abs() * 0.8),
            height: math.max(1.5, (y2 - y1).abs() * 0.8),
          ),
          paint,
        );
      } else {
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(wx, y1)
            ..lineTo(x2, y2)
            ..lineTo(x1, wy)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.fetti != fetti;
}
