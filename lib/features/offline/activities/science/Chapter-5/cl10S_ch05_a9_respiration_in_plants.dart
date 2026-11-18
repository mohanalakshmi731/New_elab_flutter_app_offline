// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 5.2: Respiration in Plants
// Converted from Cl10S-Ch5-A9-RespirationInPlants.html (Tailwind DOM + inline
// SVG -> 2D widget canvas in an InteractiveViewer; no 3D is needed).
//
// Three modules are picked from the sidebar's Module Select dropdown, as in
// the source: (1) Leaf Gas Exchange -- drag or tap the CO₂ token onto the
// night stoma, the O₂ token onto the day stoma, then tap the spongy mesophyll
// to inspect the air spaces; (2) Glucose Break-down Pathways (NCERT Fig. 5.8)
// -- glucose into the cytoplasm capsule, yeast onto Branch A, mitochondria
// onto Branch B, then tap the muscle-cell Branch C; (3) ATP: the Energy
// Currency -- Pi onto ADP, then water onto ATP's terminal bond. Each module
// ends in the source's "Scientific Conclusion" panel; pressing its OK after
// all three modules are complete opens the final "What We Understand & What We
// Have Learnt" summary with its Restart Virtual Lab button. The draggable
// action HUD, the step accordion, the lock / pan / zoom tools and the confetti
// bursts follow the source.

// --- TRANSLATION DATA (source `locales`; te dropped) ---
// Conclusion bullets use `{colour|text}` for the source's coloured <span>s.

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
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
  static const cyan500 = Color(0xFF06B6D4);
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const indigo500 = Color(0xFF6366F1);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const pink500 = Color(0xFFEC4899);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const amber200 = Color(0xFFFDE68A);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
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

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'title': 'Respiration in Plants',
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
    's1_title': '1. LEAF GAS EXCHANGE (Day/Night Toggle)',
    's2_title': '2. GLUCOSE BREAK-DOWN PATHWAYS (NCERT Fig 5.8)',
    's3_title': '3. ATP: THE ENERGY CURRENCY',
    's1_obj':
        'To observe how stomata and large inter-cellular air spaces enable diffusion of CO₂ and O₂, and why major gas exchange flips between day and night.',
    's2_obj':
        'To investigate the common first step of glucose breakdown in the cytoplasm and compare aerobic (mitochondria) vs anaerobic (yeast) pathways.',
    's3_obj':
        'To explore how respiration energy synthesizes ATP from ADP + Pi, and how breaking its terminal phosphate releases 30.5 kJ/mol for cellular work.',
    's1_steps': [
      {
        't': 'Step 1: Night Gas Exchange',
        'i': 'DRAG or CLICK Carbon Dioxide (CO₂) to the Night Stoma ① ②.',
        'o':
            'At night (no photosynthesis), CO₂ elimination from respiration is the major exchange activity.',
      },
      {
        't': 'Step 2: Day Gas Exchange',
        'i': 'DRAG or CLICK Oxygen (O₂) to the Day Stoma ①.',
        'o':
            'In daylight, CO₂ is used up for photosynthesis, so oxygen (O₂) release is the major event.',
      },
      {
        't': 'Step 3: Inter-Cellular Air Spaces',
        'i':
            'CLICK the Spongy Mesophyll layer to inspect the large air cavities.',
        'o':
            'Large inter-cellular spaces ensure all plant cells contact air directly for diffusion.',
      },
      {
        't': 'Step 4: Conclusion',
        'i': 'Observe the summary panel and click OK.',
        'o': 'Confirmation of stomatal diffusion and day/night direction flip.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Common Step in Cytoplasm',
        'i': 'DRAG or CLICK Glucose (6-carbon) into the Cytoplasm capsule.',
        'o':
            'In all organisms, glucose breaks down into two 3-carbon pyruvate molecules in the cytoplasm.',
      },
      {
        't': 'Step 2: Absence of Oxygen (Yeast)',
        'i': 'DRAG or CLICK Yeast onto Branch A (Anaerobic Fermentation).',
        'o':
            'Pyruvate converts into ethanol and carbon dioxide, releasing low energy.',
      },
      {
        't': 'Step 3: Presence of Oxygen (Mitochondria)',
        'i': 'DRAG or CLICK Mitochondria onto Branch B (Aerobic Respiration).',
        'o':
            'Pyruvate breaks down into 3 CO₂ molecules + water, releasing massive energy!',
      },
      {
        't': 'Step 4: Animal Reference (Muscle Cells)',
        'i':
            'CLICK Branch C to inspect anaerobic lactic acid formation in muscle cells.',
        'o':
            'Lack of oxygen in muscle cells converts pyruvate into 3-carbon lactic acid, causing cramps.',
      },
      {
        't': 'Step 5: Conclusion',
        'i': 'Observe the summary panel and click OK.',
        'o': 'Confirmation of Fig. 5.8 respiratory pathways.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: ATP Synthesis',
        'i':
            'DRAG or CLICK Inorganic Phosphate (Pi) to ADP with Respiration Energy.',
        'o':
            'Respiratory energy combines ADP and Pi into ATP (3-Phosphates) — the energy currency.',
      },
      {
        't': 'Step 2: Terminal Bond Cleavage',
        'i':
            'DRAG or CLICK Water (H₂O) to the terminal phosphate bond to release 30.5 kJ/mol.',
        'o':
            'Breaking the terminal phosphate linkage releases 30.5 kJ/mol to drive endothermic cell reactions.',
      },
      {
        't': 'Step 3: Conclusion',
        'i': 'Observe the summary panel and click OK.',
        'o': 'Confirmation of ATP energy storage and 30.5 kJ/mol release.',
      },
    ],
    's1_conclusion': {
      'h': 'Leaf Gas Exchange Verified',
      'p': 'Plants exchange gases through stomata by diffusion:',
      'items': [
        '{indigo|At Night:} No photosynthesis occurs; {pink|CO₂ elimination} is the major exchange activity.',
        '{emerald|During Day:} Respiration CO₂ is consumed by photosynthesis; {sky|Oxygen (O₂) release} is the major event.',
        '{blue|Air Spaces:} Large inter-cellular spaces ensure all cells contact air directly.',
      ],
      'key':
          'Key Takeaway: Direction of diffusion depends on environmental conditions and plant needs.',
    },
    's2_conclusion': {
      'h': 'Glucose Break-down Pathways Verified',
      'p': 'From NCERT Fig. 5.8 respiratory pathways:',
      'items': [
        '{emerald|Common Step:} Glucose (6-C) → Pyruvate (3-C) in the {sky|cytoplasm} of all cells.',
        '{amber|Anaerobic (Yeast):} Pyruvate → {amber3|Ethanol + CO₂} (absence of O₂).',
        '{blue|Aerobic (Mitochondria):} Pyruvate → {blue3|3 CO₂ + H₂O} (presence of O₂), releasing a lot greater energy.',
      ],
      'key':
          'Key Takeaway: Aerobic respiration releases far more energy than anaerobic fermentation.',
    },
    's3_conclusion': {
      'h': 'ATP Energy Currency Verified',
      'p': 'ATP powers cellular work like a biological battery:',
      'items': [
        '{emerald|Synthesis:} ADP + Inorganic Phosphate (Pi) + Energy → {sky|ATP}.',
        '{amber|Energy Release:} Breaking the terminal phosphate releases {amber3|30.5 kJ/mol}.',
        '{purple|Function:} Directly fuels endothermic reactions (protein synthesis, active work).',
      ],
      'key':
          'Key Takeaway: ATP is the universal energy currency of cellular life.',
    },
    'final_summary': [
      {
        'title': '1. Stomatal Diffusion (Day vs Night)',
        'text':
            'At night, CO₂ elimination is the major exchange. In daylight, oxygen release is the major event.',
      },
      {
        'title': '2. Common First Step (Cytoplasm)',
        'text':
            'Glucose (6-C) breaks down into Pyruvate (3-C) in the cytoplasm across all living cells.',
      },
      {
        'title': '3. Aerobic vs Anaerobic Pathways',
        'text':
            'Mitochondrial aerobic breakdown yields 3 CO₂ + H₂O and releases a lot greater energy than yeast fermentation.',
      },
      {
        'title': '4. ATP: 30.5 kJ/mol Energy Currency',
        'text':
            "Breaking ATP's terminal phosphate bond releases 30.5 kJ/mol to drive endothermic cell reactions.",
      },
    ],
    // Only the keys the HUD can show (the source's h_drag*/h_click* strings
    // are always overridden by the step instruction there too).
    'hud': {
      'h_nightCo2Done':
          'Night verified: CO₂ elimination is the major exchange activity.',
      'h_dayO2Done': 'Day verified: Oxygen (O₂) release is the major event.',
      'h_airSpacesDone': 'Large inter-cellular air spaces verified.',
      'h_glucoseDone':
          'Cytoplasm: Glucose broken down into Pyruvate (3-carbon) + Energy.',
      'h_yeastDone':
          'Anaerobic fermentation: Ethanol + CO₂ + low energy formed.',
      'h_mitoDone':
          'Aerobic respiration: 3 CO₂ + Water + massive energy release!',
      'h_muscleDone': 'Lactic acid cramps verified as an animal-specific case.',
      'h_atpDone': 'ATP (3-Phosphates) synthesized using respiratory energy.',
      'h_waterDone':
          '30.5 kJ/mol released to drive endothermic reactions in the cell!',
      'h_nextModuleHint':
          'Stage completed! Select the next module from the sidebar dropdown above.',
    },
    'canvas': {
      'c_day': 'DAY',
      'c_night': 'NIGHT',
      'c_spongyAirSpace': 'Spongy mesophyll air space',
      'c_spongyProminent': 'Spongy mesophyll prominent layer',
      'c_largeAirSpaces': 'Largely prominent large inter-cellular air spaces',
      'c_guardCell': 'Guard cell',
      'c_o2Released': 'Oxygen released',
      'c_co2Photo': 'CO₂ used in Photosynthesis',
      'c_co2Elim': 'Carbon dioxide eliminated',
      'c_glucose6c': 'GLUCOSE (6-carbon)',
      'c_cytoplasm': 'Cytoplasm',
      'c_pyruvate3c': 'PYRUVATE (3-carbon)',
      'c_energy': '+ Energy',
      'c_commonStep': 'Common first step breakdown in cytoplasm',
      'c_absenceO2': 'ABSENCE OF OXYGEN',
      'c_yeastFerm': '(Yeast - Fermentation)',
      'c_ethanolCo2': 'Ethanol + Carbon Dioxide',
      'c_lowEnergy': 'low energy',
      'c_presenceO2': 'PRESENCE OF OXYGEN',
      'c_mitoOrg': '(Mitochondria Organelle)',
      'c_co2Water': 'Three molecules of CO₂ + Water',
      'c_massiveEnergy': 'massive, energy release',
      'c_releasesMore': 'RELEASES A LOT MORE ENERGY',
      'c_lackO2': 'LACK OF OXYGEN',
      'c_muscleCell': 'in Muscle Cells (Animal Reference only)',
      'c_lacticAcid': 'Lactic acid (3-carbon)',
      'c_cramps': 'cramps',
      'c_synthesis': 'SYNTHESIS',
      'c_use': 'USE',
      'c_respEnergy': 'RESPIRATION ENERGY',
      'c_adp2p': 'ADP (2-Phosphates)',
      'c_piInorg': 'Pi (Inorganic Phosphate)',
      'c_atp3p': 'ATP (3-Phosphates)',
      'c_water': 'Water',
      'c_released30': '30.5 kJ/mol released',
      'c_drivesEndo': 'DRIVES ENDOTHERMIC REACTIONS IN CELL',
    },
  },
  'hi': {
    'title': 'पौधों में श्वसन',
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
    's1_title': '1. पत्ती में गैस विनिमय (दिन/रात टॉगल)',
    's2_title': '2. ग्लूकोज विखंडन के विभिन्न पथ (NCERT चित्र 5.8)',
    's3_title': '3. एटीपी (ATP): कोशिकीय ऊर्जा मुद्रा',
    's1_obj':
        'यह समझना कि रंध्र और बड़े अंतराकोशिकीय अवकाश विसरण को कैसे सुगम बनाते हैं और दिन व रात में मुख्य गैस विनिमय क्यों बदलता है।',
    's2_obj':
        'कोशिकाद्रव्य में ग्लूकोज के पाइरूवेट में विखंडन और वायवीय (माइटोकॉन्ड्रिया) बनाम अवायवीय (यीस्ट) पथों का अध्ययन करना।',
    's3_obj':
        'यह खोजना कि श्वसन से उत्पन्न ऊर्जा एटीपी का निर्माण कैसे करती है और फॉस्फेट बंध टूटने पर 30.5 kJ/mol ऊर्जा कैसे निकलती है।',
    's1_steps': [
      {
        't': 'कदम 1: रात में गैस विनिमय',
        'i':
            'कार्बन डाइऑक्साइड (CO₂) टोकन को रात के रंध्र ① ② में खींचें या क्लिक करें।',
        'o':
            'रात में (प्रकाश संश्लेषण न होने पर), श्वसन से CO₂ निष्कासन मुख्य विनिमय क्रिया है।',
      },
      {
        't': 'कदम 2: दिन में गैस विनिमय',
        'i': 'ऑक्सीजन (O₂) टोकन को दिन के रंध्र ① में खींचें या क्लिक करें।',
        'o':
            'दिन में, CO₂ प्रकाश संश्लेषण में प्रयुक्त हो जाती है, इसलिए ऑक्सीजन (O₂) का निकलना मुख्य घटना है।',
      },
      {
        't': 'कदम 3: अंतराकोशिकीय अवकाश',
        'i':
            'विशाल अंतराकोशिकीय अवकाशों का निरीक्षण करने के लिए स्पंजी पर्णमध्योतक परत पर क्लिक करें।',
        'o':
            'बड़े अंतराकोशिकीय अवकाश यह सुनिश्चित करते हैं कि सभी कोशिकाएं वायु के सीधे संपर्क में रहें।',
      },
      {
        't': 'कदम 4: निष्कर्ष',
        'i': "सारांश पैनल देखें और 'ठीक है' पर क्लिक करें।",
        'o': 'रंध्रीय विसरण और दिन/रात दिशा परिवर्तन की पुष्टि।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: कोशिकाद्रव्य में पहला कदम',
        'i':
            'ग्लूकोज (6-कार्बन) को कोशिकाद्रव्य कैप्सूल में खींचें या क्लिक करें।',
        'o':
            'सभी जीवों में, ग्लूकोज कोशिकाद्रव्य में 3-कार्बन पाइरूवेट में टूटता है।',
      },
      {
        't': 'कदम 2: ऑक्सीजन की अनुपस्थिति (यीस्ट)',
        'i': 'यीस्ट टोकन को शाखा A (अवायवीय किण्वन) पर खींचें या क्लिक करें।',
        'o':
            'पाइरूवेट एथेनॉल और कार्बन डाइऑक्साइड में परिवर्तित होता है तथा कम ऊर्जा देता है।',
      },
      {
        't': 'कदम 3: ऑक्सीजन की उपस्थिति (माइटोकॉन्ड्रिया)',
        'i':
            'माइटोकॉन्ड्रिया टोकन को शाखा B (वायवीय श्वसन) पर खींचें या क्लिक करें।',
        'o':
            'पाइरूवेट तीन CO₂ अणुओं और जल में टूटता है तथा अत्यधिक भारी ऊर्जा मुक्त करता है!',
      },
      {
        't': 'कदम 4: जंतु संदर्भ (पेशी कोशिकाएं)',
        'i':
            'जंतुओं में लैक्टिक अम्ल निर्माण देखने के लिए पेशी शाखा C पर क्लिक करें।',
        'o':
            'ऑक्सीजन की कमी में 3-कार्बन लैक्टिक अम्ल बनता है जिससे मांसपेशियों में ऐंठन (cramps) होती है।',
      },
      {
        't': 'कदम 5: निष्कर्ष',
        'i': "सारांश पैनल देखें और 'ठीक है' पर क्लिक करें।",
        'o': 'चित्र 5.8 श्वसन पथों की पुष्टि।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: एटीपी (ATP) का संश्लेषण',
        'i':
            'श्वसन ऊर्जा के साथ अकार्बनिक फॉस्फेट (Pi) को ADP में खींचें या क्लिक करें।',
        'o': 'श्वसन की ऊर्जा ADP और Pi को ATP (3-फॉस्फेट) में जोड़ती है।',
      },
      {
        't': 'कदम 2: अंतिम फॉस्फेट बंध का टूटना',
        'i':
            'जल (H₂O) को अंतिम फॉस्फेट बंध पर खींचें या क्लिक करके ऊर्जा मुक्त करें।',
        'o':
            'अंतिम फॉस्फेट बंध टूटने से 30.5 kJ/mol ऊर्जा मुक्त होती है जो कोशिकीय क्रियाओं को चलाती है।',
      },
      {
        't': 'कदम 3: निष्कर्ष',
        'i': "सारांश पैनल देखें और 'ठीक है' पर क्लिक करें।",
        'o': 'एटीपी ऊर्जा संचय और 30.5 kJ/mol निष्कासन की पुष्टि।',
      },
    ],
    's1_conclusion': {
      'h': 'रंध्रीय गैस विनिमय सत्यापन',
      'p': 'पौधे रंध्रों द्वारा विसरण से गैसों का विनिमय करते हैं:',
      'items': [
        '{indigo|रात में:} प्रकाश संश्लेषण नहीं होता; {pink|CO₂ का निष्कासन} मुख्य विनिमय गतिविधि है।',
        '{emerald|दिन में:} श्वसन की CO₂ प्रकाश संश्लेषण में उपयोग हो जाती है; {sky|ऑक्सीजन (O₂) का निकलना} मुख्य घटना है।',
        '{blue|अंतराकोशिकीय स्थान:} सभी कोशिकाओं को वायु के सीधे संपर्क में रखते हैं।',
      ],
      'key':
          'मुख्य निष्कर्ष: विसरण की दिशा पर्यावरण की परिस्थितियों और पौधे की आवश्यकता पर निर्भर करती है।',
    },
    's2_conclusion': {
      'h': 'ग्लूकोज विखंडन पथ सत्यापन',
      'p': 'एनसीईआरटी चित्र 5.8 श्वसन पथों के अनुसार:',
      'items': [
        '{emerald|पहला चरण:} सभी कोशिकाओं के {sky|कोशिकाद्रव्य} में ग्लूकोज (6-C) → पाइरूवेट (3-C)।',
        '{amber|अवायवीय (यीस्ट):} ऑक्सीजन की अनुपस्थिति में पाइरूवेट → {amber3|एथेनॉल + CO₂}।',
        '{blue|वायवीय (माइटोकॉन्ड्रिया):} ऑक्सीजन की उपस्थिति में पाइरूवेट → {blue3|3 CO₂ + जल} (अत्यधिक भारी ऊर्जा)।',
      ],
      'key':
          'मुख्य निष्कर्ष: वायवीय श्वसन अवायवीय किण्वन की तुलना में बहुत अधिक ऊर्जा देता है।',
    },
    's3_conclusion': {
      'h': 'एटीपी (ATP) ऊर्जा मुद्रा सत्यापन',
      'p': 'एटीपी एक बैटरी की तरह कोशिकीय कार्यों को ऊर्जा देती है:',
      'items': [
        '{emerald|संश्लेषण:} ADP + अकार्बनिक फॉस्फेट (Pi) + श्वसन ऊर्जा → {sky|ATP}।',
        '{amber|ऊर्जा निष्कासन:} अंतिम फॉस्फेट बंध टूटने पर {amber3|30.5 kJ/mol} ऊर्जा निकलती है।',
        '{purple|कार्य:} ऊष्माशोषी प्रक्रियाओं (प्रोटीन संश्लेषण आदि) को संचालित करना।',
      ],
      'key':
          'मुख्य निष्कर्ष: एटीपी सभी कोशिकीय प्रक्रियाओं की सार्वभौमिक ऊर्जा मुद्रा है।',
    },
    'final_summary': [
      {
        'title': '1. रंध्रीय विसरण (दिन बनाम रात)',
        'text':
            'रात में CO₂ का निष्कासन मुख्य विनिमय है। दिन में ऑक्सीजन का निकलना मुख्य घटना है।',
      },
      {
        'title': '2. पहला चरण (कोशिकाद्रव्य)',
        'text':
            'सभी कोशिकाओं के कोशिकाद्रव्य में ग्लूकोज (6-C) पाइरूवेट (3-C) में टूटता है।',
      },
      {
        'title': '3. वायवीय बनाम अवायवीय पथ',
        'text':
            'माइटोकॉन्ड्रिया में वायवीय विखंडन से 3 CO₂ + जल बनते हैं और बहुत अधिक ऊर्जा निकलती है।',
      },
      {
        'title': '4. एटीपी: 30.5 kJ/mol ऊर्जा मुद्रा',
        'text':
            'एटीपी का अंतिम फॉस्फेट बंध टूटने से 30.5 kJ/mol ऊर्जा मुक्त होती है जो कोशिकीय क्रियाओं को चलाती है।',
      },
    ],
    'hud': {
      'h_nightCo2Done': 'रात सत्यापित: CO₂ निष्कासन मुख्य विनिमय गतिविधि है।',
      'h_dayO2Done': 'दिन सत्यापित: ऑक्सीजन (O₂) का निकलना मुख्य घटना है।',
      'h_airSpacesDone': 'बड़े अंतराकोशिकीय अवकाश सत्यापित।',
      'h_glucoseDone':
          'कोशिकाद्रव्य: ग्लूकोज पाइरूवेट (3-कार्बन) + ऊर्जा में टूट गया।',
      'h_yeastDone': 'अवायवीय किण्वन: एथेनॉल + CO₂ + कम ऊर्जा बनी।',
      'h_mitoDone': 'वायवीय श्वसन: 3 CO₂ + जल बना और अत्यधिक भारी ऊर्जा निकली!',
      'h_muscleDone':
          'पेशी कोशिकाओं में लैक्टिक अम्ल और ऐंठन (cramps) सत्यापित।',
      'h_atpDone':
          'श्वसन ऊर्जा का उपयोग करके एटीपी (3-फॉस्फेट) का संश्लेषण हुआ।',
      'h_waterDone': 'कोशिकीय कार्यों के लिए 30.5 kJ/mol ऊर्जा मुक्त हुई!',
      'h_nextModuleHint':
          'चरण पूरा हुआ! ऊपर साइडबार ड्रॉपडाउन से अगला मॉड्यूल चुनें।',
    },
    'canvas': {
      'c_day': 'दिन (DAY)',
      'c_night': 'रात (NIGHT)',
      'c_spongyAirSpace': 'स्पंजी पर्णमध्योतक वायु अवकाश',
      'c_spongyProminent': 'स्पंजी पर्णमध्योतक की प्रमुख परत',
      'c_largeAirSpaces': 'विशाल प्रमुख अंतराकोशिकीय अवकाश',
      'c_guardCell': 'द्वार कोशिका',
      'c_o2Released': 'ऑक्सीजन मुक्त होती है',
      'c_co2Photo': 'CO₂ प्रकाश संश्लेषण में प्रयुक्त',
      'c_co2Elim': 'कार्बन डाइऑक्साइड का निष्कासन',
      'c_glucose6c': 'ग्लूकोज (6-कार्बन)',
      'c_cytoplasm': 'कोशिकाद्रव्य',
      'c_pyruvate3c': 'पाइरूवेट (3-कार्बन)',
      'c_energy': '+ ऊर्जा',
      'c_commonStep': 'कोशिकाद्रव्य में पहला सामान्य विखंडन',
      'c_absenceO2': 'ऑक्सीजन की अनुपस्थिति',
      'c_yeastFerm': '(यीस्ट - किण्वन)',
      'c_ethanolCo2': 'एथेनॉल + कार्बन डाइऑक्साइड',
      'c_lowEnergy': 'कम ऊर्जा',
      'c_presenceO2': 'ऑक्सीजन की उपस्थिति',
      'c_mitoOrg': '(माइटोकॉन्ड्रिया कोशिकांग)',
      'c_co2Water': 'CO₂ के तीन अणु + जल',
      'c_massiveEnergy': 'अत्यधिक, भारी ऊर्जा निष्कासन',
      'c_releasesMore': 'बहुत अधिक ऊर्जा मुक्त करता है',
      'c_lackO2': 'ऑक्सीजन का अभाव',
      'c_muscleCell': 'पेशी कोशिकाओं में (केवल जंतु संदर्भ)',
      'c_lacticAcid': 'लैक्टिक अम्ल (3-कार्बन)',
      'c_cramps': 'ऐंठन (क्रैम्प्स)',
      'c_synthesis': 'संश्लेषण (SYNTHESIS)',
      'c_use': 'उपयोग (USE)',
      'c_respEnergy': 'श्वसन ऊर्जा',
      'c_adp2p': 'ADP (2-फॉस्फेट)',
      'c_piInorg': 'Pi (अकार्बनिक फॉस्फेट)',
      'c_atp3p': 'ATP (3-फॉस्फेट)',
      'c_water': 'जल (Water)',
      'c_released30': '30.5 kJ/mol ऊर्जा मुक्त',
      'c_drivesEndo': 'कोशिका में ऊष्माशोषी अभिक्रियाओं को चलाता है',
    },
  },
});

// --- Scene colours (Tailwind shades the source uses that _rt_Tw lacks) ---
const _bgMain = Color(0xFF060D1F);
const _navy = Color(0xFF0B152D);
const _sky100 = Color(0xFFE0F2FE);
const _sky200 = Color(0xFFBAE6FD);
const _sky300 = Color(0xFF7DD3FC);
const _sky950 = Color(0xFF082F49);
const _pink300 = Color(0xFFF9A8D4);
const _pink400 = Color(0xFFF472B6);
const _pink600 = Color(0xFFDB2777);
const _pink950 = Color(0xFF500724);
const _amber100 = Color(0xFFFEF3C7);
const _amber300 = Color(0xFFFCD34D);
const _amber950 = Color(0xFF451A03);
const _emerald300 = Color(0xFF6EE7B7);
const _purple200 = Color(0xFFE9D5FF);
const _purple300 = Color(0xFFD8B4FE);
const _purple400 = Color(0xFFC084FC);
const _indigo300 = Color(0xFFA5B4FC);
const _indigo400 = Color(0xFF818CF8);
const _indigo950 = Color(0xFF1E1B4B);
const _blue300 = Color(0xFF93C5FD);
const _slateLine = Color(0x99334155); // slate-700/60

/// Colours of the conclusion `<span>`s, by markup name.
const _spanColors = <String, Color>{
  'indigo': _indigo400,
  'pink': _pink400,
  'emerald': _rt_Tw.emerald400,
  'sky': _sky300,
  'blue': _rt_Tw.blue400,
  'blue3': _blue300,
  'amber': _rt_Tw.amber400,
  'amber3': _amber300,
  'purple': _purple400,
};
final _spanRe = RegExp(r'\{(\w+)\|([^}]*)\}');

// --- Layout ---
/// Design size of every module scene (the source's fixed 1040×640
/// `#scene-content`, re-composed for a landscape phone and fit-scaled).
const double _dw = 600, _dh = 340;

/// Canvas height kept clear under the scene for the action HUD.
const double _hudReserve = 112;

/// Module 1 leaf diagram: SVG viewBox units -> design pixels.
const double _lk = 0.56, _lox = 20, _loy = 42, _ly0 = 25;
Offset _lm(double x, double y) =>
    Offset(_lox + x * _lk, _loy + (y - _ly0) * _lk);

/// The source's `.dropzone` elements (any token dropped near any of them is
/// handed to `handlePlacement` with the token's own action).
const _dropZones = [
  'day-stoma',
  'night-stoma',
  'cytoplasm',
  'yeast-branch',
  'mito-branch',
  'adp-synthesis',
  'terminal-bond',
];

/// One placement of `handlePlacement`: HUD message, feedback pill, delay
/// before the step advances, and the source sound.
class _Act {
  const _Act(
    this.doneKey,
    this.feedback, {
    this.delayMs = 900,
    this.sound = _rt_Sfx.magic,
  });
  final String doneKey;
  final String feedback;
  final int delayMs;
  final _rt_Sfx sound;
}

const Map<int, List<_Act>> _acts = {
  1: [
    _Act('h_nightCo2Done', 'CO₂ Elimination Verified'),
    _Act('h_dayO2Done', 'Oxygen Release Verified'),
    _Act('h_airSpacesDone', 'Air Spaces Inspected'),
  ],
  2: [
    _Act('h_glucoseDone', 'Pyruvate (3-C) + Energy Formed'),
    _Act('h_yeastDone', 'Ethanol + CO₂ + low energy'),
    _Act('h_mitoDone', '3 CO₂ + Water + massive energy!'),
    _Act('h_muscleDone', 'Animal Muscle Cramp Verified'),
  ],
  3: [
    _Act('h_atpDone', 'ATP (3-Phosphates) Synthesized'),
    // Source: playSound('energy') and a 950 ms delay for the hydrolysis.
    _Act(
      'h_waterDone',
      '30.5 kJ/mol Energy Released',
      delayMs: 950,
      sound: _rt_Sfx.correct,
    ),
  ],
};

enum _HudTone { info, success, error }

/// [v] limited to [lo, hi] (typed as double, unlike `num.clamp`).
double _clampD(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

/// 0 -> 1 -> 0 over [period] seconds (an ease-in-out keyframe loop).
double _wave(double t, double period) =>
    0.5 - 0.5 * math.cos(2 * math.pi * (t % period) / period);

class Cl10SCh05A9RespirationInPlantsPage extends StatefulWidget {
  const Cl10SCh05A9RespirationInPlantsPage({super.key});

  @override
  State<Cl10SCh05A9RespirationInPlantsPage> createState() =>
      _Cl10SCh05A9RespirationInPlantsPageState();
}

class _Cl10SCh05A9RespirationInPlantsPageState
    extends State<Cl10SCh05A9RespirationInPlantsPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  // Source zoomCam: ±0.12 per press, clamped to 0.6–2.5.
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.6,
    max: 2.5,
    step: 1.12,
  );

  /// Seconds since the page opened; drives every CSS keyframe loop.
  final ValueNotifier<double> _time = ValueNotifier(0);
  late final Ticker _ticker;
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  final GlobalKey _tokenKey = GlobalKey();
  final Map<String, GlobalKey> _zoneKeys = {
    for (final z in _dropZones) z: GlobalKey(),
  };

  // --- STATE (source `state`) ---
  int _module = 1;
  int _step = 0;

  /// Steps of the current module whose token has been placed (prog1/2/3).
  final Set<int> _done = {};

  /// completedModules.
  final Set<int> _completed = {};

  /// Open accordion item (the active step after every re-render).
  int? _openStep = 0;

  /// HUD: instruction override (hud.* key), feedback pill and its tone.
  String? _hudKey;
  String? _hudFb;
  _HudTone _hudTone = _HudTone.info;
  Offset _hudOffset = Offset.zero;

  bool _obsOpen = false;
  int _obsModule = 1;
  Offset _obsOffset = Offset.zero;
  bool _finalOpen = false;
  Offset _finalOffset = Offset.zero;
  _Burst? _burst;

  // Camera tools (cam.isLocked / cam.isPanMode).
  bool _locked = true;
  bool _panMode = false;

  // Token drag.
  bool _dragging = false;
  Offset _dragOffset = Offset.zero;
  Offset _snapFrom = Offset.zero;
  Set<String> _hover = {};

  Timer? _stepTimer;
  Timer? _concTimer;
  Timer? _finalTimer;

  List<dynamic> get _steps => _tx.list('s${_module}_steps');
  int get _last => _steps.length - 1;
  String _c(String key) => _tx.s('canvas.$key');
  double get _pulse =>
      0.75 + 0.25 * math.cos(2 * math.pi * (_time.value % 2) / 2);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker((elapsed) {
      _time.value = elapsed.inMicroseconds / 1e6;
      final b = _burst;
      if (b != null && _time.value - b.start > 3.6 && mounted) {
        setState(() => _burst = null);
      }
    })..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cancelTimers();
    _ticker.dispose();
    _snap.dispose();
    _zoom.dispose();
    _time.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic ---

  void _cancelTimers() {
    _stepTimer?.cancel();
    _concTimer?.cancel();
    _finalTimer?.cancel();
    _stepTimer = null;
    _concTimer = null;
    _finalTimer = null;
  }

  /// Source `loadScenario` body: step 0, every module's progress cleared,
  /// both popups closed. completedModules survives.
  void _resetModuleState() {
    _cancelTimers();
    _step = 0;
    _done.clear();
    _openStep = 0;
    _hudKey = null;
    _hudFb = null;
    _hudTone = _HudTone.info;
    _obsOpen = false;
    _finalOpen = false;
    _dragging = false;
    _dragOffset = Offset.zero;
    _hover = {};
    _snap.reset();
  }

  void _loadModule(int m) {
    // A <select> only fires onchange for a different option.
    if (m == _module) return;
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _module = m;
      _resetModuleState();
    });
    _zoom.reset();
  }

  void _restart() {
    // The shell (or the final panel's button) has already played the sound.
    setState(() {
      _module = 1;
      _resetModuleState();
      _completed.clear();
      _locked = true;
      _panMode = false;
      _burst = null;
    });
    _zoom.reset();
  }

  /// Source `handlePlacement` for the action of step [s].
  bool _place(int s) {
    if (_stepTimer != null || s != _step || s >= _last) return false;
    final act = _acts[_module]![s];
    _rt_playSfx(act.sound);
    setState(() {
      _done.add(s);
      _hudKey = 'hud.${act.doneKey}';
      _hudFb = act.feedback;
      _hudTone = _HudTone.success;
    });
    _stepTimer = Timer(Duration(milliseconds: act.delayMs), () {
      _stepTimer = null;
      if (mounted) _completeStep(s + 1);
    });
    return true;
  }

  /// A tap on a zone. The source ignores taps meant for another step; here
  /// they get a sound so the tap is not silent.
  void _tapZone(int s) {
    if (_place(s)) return;
    if (_stepTimer != null) return; // the last placement is still settling
    _rt_playSfx(_step >= _last ? _rt_Sfx.tap : _rt_Sfx.wrong);
  }

  /// Source `completeStep` + the final-step branch of `render2DScene`.
  void _completeStep(int n) {
    setState(() {
      _step = n;
      _openStep = n;
      _hudKey = null;
      _hudFb = null;
      _hudTone = _HudTone.info;
    });
    if (n == _last) {
      _completed.add(_module);
      final m = _module;
      _concTimer = Timer(const Duration(milliseconds: 800), () {
        _concTimer = null;
        if (mounted) _showConclusion(m);
      });
    }
  }

  void _showConclusion(int m) {
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _obsOpen = true;
      _obsModule = m;
      _burst = _Burst(
        start: _time.value,
        count: m == 3 ? 120 : 90,
        spread: m == 3 ? 80 : 70,
        originY: 0.6,
        seed: 17 * m,
      );
    });
  }

  /// The X on the conclusion panel: closes it only (no hint, no finale).
  void _closeObservation() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _obsOpen = false);
  }

  /// Source `confirmStepObservation` (the OK button).
  void _confirmObservation() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _obsOpen = false);
    if (_completed.length == 3) {
      _finalTimer = Timer(const Duration(milliseconds: 500), () {
        _finalTimer = null;
        if (mounted) _showFinal();
      });
    } else {
      setState(() {
        _hudKey = 'hud.h_nextModuleHint';
        _hudFb = 'Stage Complete';
        _hudTone = _HudTone.success;
      });
    }
  }

  void _showFinal() {
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _finalOpen = true;
      _burst = _Burst(
        start: _time.value,
        count: 160,
        spread: 90,
        originY: 0.5,
        seed: 99,
      );
    });
  }

  void _closeFinal() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _finalOpen = false);
  }

  void _toggleAccordion(int i) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _openStep = _openStep == i ? null : i);
  }

  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _locked = !_locked);
  }

  void _togglePanMode() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _panMode = !_panMode;
      if (_panMode) _locked = false;
    });
  }

  // --- token drag (source pointer drag & drop) ---

  void _dragStart() {
    _rt_playSfx(_rt_Sfx.tap); // source playSound('drag')
    _snap.reset();
    setState(() {
      _dragging = true;
      _dragOffset = Offset.zero;
    });
  }

  void _dragUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    setState(() {
      _dragOffset += d.delta;
      _hover = _zonesUnderToken();
    });
  }

  void _dragEnd(int step) {
    if (!_dragging) return;
    final dropped = _zonesUnderToken().isNotEmpty;
    final from = _dragOffset;
    setState(() {
      _dragging = false;
      _hover = {};
      _dragOffset = Offset.zero;
    });
    if (dropped) {
      _place(step);
    } else {
      // Back to its slot (the source's 0.2 s transform transition).
      _rt_playSfx(_rt_Sfx.pop);
      _snapFrom = from;
      _snap.forward(from: 0);
    }
  }

  void _dragCancel() {
    if (!_dragging) return;
    setState(() {
      _dragging = false;
      _hover = {};
      _dragOffset = Offset.zero;
    });
  }

  static Rect _globalRect(RenderBox b) =>
      MatrixUtils.transformRect(b.getTransformTo(null), Offset.zero & b.size);

  /// Dropzones whose screen rect, grown by the source's 35 px padding,
  /// overlaps the dragged token.
  Set<String> _zonesUnderToken() {
    final tb = _tokenKey.currentContext?.findRenderObject();
    if (tb is! RenderBox || !tb.hasSize) return {};
    final _rt_tr = _globalRect(tb);
    final out = <String>{};
    for (final e in _zoneKeys.entries) {
      final zb = e.value.currentContext?.findRenderObject();
      if (zb is! RenderBox || !zb.attached || !zb.hasSize) continue;
      if (_rt_tr.overlaps(_globalRect(zb).inflate(35))) out.add(e.key);
    }
    return out;
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
            accent: _rt_Tw.sky500,
            headerGradient: [_rt_Tw.slate900, Color(0xFF0C4A6E)],
            headerSubtitleColor: _sky200,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.air,
            buttonIcon: Icons.arrow_forward,
          ),
          // Source enterLab: playSound('success') once the shutter is up.
          onStart: () => _rt_playSfx(_rt_Sfx.success),
          onRestart: _restart,
          onZoomIn: _zoom.zoomIn,
          onZoomOut: _zoom.zoomOut,
          onResetView: _zoom.reset,
          toolbarExtras: [
            _ToolToggle(
              key: const ValueKey('tool-lock'),
              active: true,
              color: _locked ? _rt_Tw.sky400 : _rt_Tw.amber400,
              filled: !_locked,
              icon: _locked ? Icons.lock : Icons.lock_open,
              tooltip: 'Lock / Unlock Pan',
              onTap: _toggleLock,
            ),
            const SizedBox(height: 4),
            _ToolToggle(
              key: const ValueKey('tool-pan'),
              active: _panMode,
              color: _rt_Tw.sky400,
              filled: _panMode,
              icon: Icons.pan_tool,
              tooltip: 'Pan Mode Toggle',
              onTap: _togglePanMode,
            ),
          ],
          canvasBackground: _bgMain,
          tabs: [
            _rt_ShellTab(
              label: _tx.s('moduleSel'),
              icon: Icons.science,
              builder: (_) => _sidebar(),
            ),
          ],
          canvas: _canvas(),
          canvasOverlays: [
            Positioned.fill(
              child: _rt_MinWidthGate(minWidth: 200, child: _overlays()),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------- sidebar ---

  Widget _sideLabel(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: _rt_Tw.sky400),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: _rt_Tw.sky400,
          ),
        ),
      ),
    ],
  );

  Widget _sidebar() {
    final steps = _steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            border: Border(bottom: BorderSide(color: _rt_Lab.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sideLabel(Icons.science, _tx.s('moduleSel')),
              const SizedBox(height: 8),
              _moduleSelect(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sideLabel(Icons.gps_fixed, _tx.s('missionObj')),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _rt_Lab.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _rt_Lab.border),
                ),
                child: Text(
                  _tx.s('s${_module}_obj'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _rt_Lab.text,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < steps.length; i++)
                _stepItem(i, steps[i] as Map),
            ],
          ),
        ),
      ],
    );
  }

  /// The source's `<select id="scenario-select">`.
  Widget _moduleSelect() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.borderStrong, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: const ValueKey('module-select'),
          value: _module,
          isExpanded: true,
          itemHeight: null,
          dropdownColor: _rt_Lab.surface,
          borderRadius: BorderRadius.circular(12),
          iconEnabledColor: _rt_Lab.textMuted,
          icon: const Icon(Icons.keyboard_arrow_down),
          onTap: () => _rt_playSfx(_rt_Sfx.dropdown),
          onChanged: (v) {
            if (v != null) _loadModule(v);
          },
          items: [
            for (var m = 1; m <= 3; m++)
              DropdownMenuItem<int>(
                value: m,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _tx.s('s${m}_title'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// One `.accordion-item` (title row + Task Instructions / Expected Outcome).
  Widget _stepItem(int i, Map step) {
    final active = i == _step;
    final past = i < _step;
    final open = _openStep == i;
    final Widget status = past
        ? const Icon(Icons.check_circle, size: 18, color: _rt_Tw.sky400)
        : active
        ? AnimatedBuilder(
            animation: _time,
            builder: (_, child) => Transform.rotate(
              angle: 2 * math.pi * (_time.value % 1),
              child: child,
            ),
            child: const Icon(Icons.autorenew, size: 18, color: _rt_Tw.sky400),
          )
        : Icon(
            Icons.radio_button_unchecked,
            size: 18,
            color: _rt_Lab.textMuted,
          );
    Widget section(
      IconData icon,
      String label,
      Color color,
      String text,
      Color textColor,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: textColor, height: 1.4),
        ),
      ],
    );
    return Opacity(
      opacity: past ? 0.7 : 1,
      child: Container(
        key: ValueKey('step-$i'),
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? _rt_Tw.sky500 : _rt_Lab.border,
            width: active ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: _rt_Lab.shadow, blurRadius: active ? 8 : 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              key: ValueKey('step-head-$i'),
              onTap: () => _toggleAccordion(i),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                child: Row(
                  children: [
                    status,
                    const SizedBox(width: 8),
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
                        Icons.keyboard_arrow_down,
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
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: open
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: _rt_Lab.surface,
                        border: Border(top: BorderSide(color: _rt_Lab.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          section(
                            Icons.play_arrow,
                            _tx.s('taskInstr'),
                            _rt_Tw.sky400,
                            step['i'] as String,
                            _rt_Lab.text,
                          ),
                          const SizedBox(height: 10),
                          section(
                            Icons.visibility,
                            _tx.s('expOut'),
                            _rt_Tw.blue400,
                            step['o'] as String,
                            _rt_Lab.textMuted,
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

  // ------------------------------------------------------------ canvas ---

  Widget _canvas() {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _BgPainter())),
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _zoom.transform,
            minScale: _zoom.min,
            maxScale: _zoom.max,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            // Source: background drag pans only when unlocked or in pan mode.
            panEnabled: !_locked || _panMode,
            child: Padding(
              // Right: clear of the back button and the tool column.
              padding: const EdgeInsets.fromLTRB(12, 10, 66, _hudReserve),
              child: Center(
                child: FittedBox(
                  child: SizedBox(
                    width: _dw,
                    height: _dh,
                    child: KeyedSubtree(
                      key: ValueKey('module-$_module'),
                      child: switch (_module) {
                        1 => _module1(),
                        2 => _module2(),
                        _ => _module3(),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _overlays() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        // The shell's menu button floats over the canvas once the sidebar is shut.
        final sidebarClosed = w >= MediaQuery.sizeOf(context).width - 1;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _hudPositioned(w, h),
            if (_obsOpen) _observationPanel(w, h, sidebarClosed),
            if (_finalOpen) _finalPanel(w, h, sidebarClosed),
            if (_burst != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _ConfettiPainter(_burst!, _time)),
                ),
              ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------- HUD ---

  Widget _hudPositioned(double w, double h) {
    final hw = math.max(0.0, math.min(380.0, w - 78));
    final left = _clampD(12 + _hudOffset.dx, 0, math.max(0.0, w - hw));
    final bottom = _clampD(8 - _hudOffset.dy, 0, math.max(0.0, h - 60));
    return Positioned(
      left: left,
      bottom: bottom,
      width: hw,
      child: _hud(w, h, hw),
    );
  }

  void _moveHud(Offset delta, double w, double h, double hw) {
    setState(() {
      final left = _clampD(
        12 + _hudOffset.dx + delta.dx,
        0,
        math.max(0.0, w - hw),
      );
      final bottom = _clampD(
        8 - _hudOffset.dy - delta.dy,
        0,
        math.max(0.0, h - 60),
      );
      _hudOffset = Offset(left - 12, 8 - bottom);
    });
  }

  /// The draggable `#action-hud`.
  Widget _hud(double w, double h, double hw) {
    final steps = _steps;
    final n = steps.length;
    final instr = _hudKey != null
        ? _tx.s(_hudKey!)
        : (steps[_step] as Map)['i'] as String;
    final (fbBg, fbFg) = switch (_hudTone) {
      _HudTone.success => (_rt_Tw.sky500.withValues(alpha: 0.2), _rt_Tw.sky400),
      _HudTone.error => (_rt_Tw.red500.withValues(alpha: 0.2), _rt_Tw.red400),
      _HudTone.info => (_rt_Tw.blue500.withValues(alpha: 0.2), _rt_Tw.blue400),
    };
    return Container(
      key: const ValueKey('hud'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _rt_Tw.sky400.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3.5, color: _rt_Tw.sky400),
          GestureDetector(
            key: const ValueKey('hud-handle'),
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _moveHud(d.delta, w, h, hw),
            child: Container(
              color: _rt_Lab.base.withValues(alpha: 0.7),
              padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: _rt_Lab.textMuted,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.science, size: 12, color: _rt_Tw.sky400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _tx.s('missionReady').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _rt_Tw.sky400,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Tw.sky500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: _rt_Tw.sky500.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Step ${math.min(_step + 1, n)}/$n',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Tw.sky400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  instr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hudFb != null ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: fbBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _hudFb ?? 'Ready',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: fbFg,
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

  // ------------------------------------------------------------ panels ---

  /// Frame shared by the conclusion and final panels: top 8 %, centred,
  /// clear of the shell's corner buttons, dragged by its header.
  Widget _panelFrame({
    required double w,
    required double h,
    required bool sidebarClosed,
    required double maxW,
    required Offset offset,
    required ValueChanged<Offset> onOffset,
    required Color borderColor,
    required Widget header,
    required Widget body,
    Widget? footer,
  }) {
    final leftBound = sidebarClosed ? 70.0 : 12.0;
    final pw = math.max(
      0.0,
      math.min(maxW, math.min(w * 0.9, w - leftBound - 66)),
    );
    final left = _clampD(
      (w - pw) / 2,
      leftBound,
      math.max(leftBound, w - 66 - pw),
    );
    final top = h * 0.08;
    final maxH = math.max(120.0, h - top - 12);
    return Positioned(
      left: left + offset.dx,
      top: top + offset.dy,
      width: pw,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _rt_Lab.base,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) {
                    final l = _clampD(
                      left + offset.dx + d.delta.dx,
                      60 - pw,
                      w - 60,
                    );
                    final t = _clampD(
                      top + offset.dy + d.delta.dy,
                      0,
                      math.max(0.0, h - 50),
                    );
                    onOffset(Offset(l - left, t - top));
                  },
                  child: header,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: body,
                  ),
                ),
                ?footer,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _closeButton(String key, VoidCallback onTap) => IconButton(
    key: ValueKey(key),
    onPressed: onTap,
    icon: const Icon(Icons.close),
    iconSize: 18,
    color: _rt_Lab.textMuted,
    visualDensity: VisualDensity.compact,
    tooltip: _rt_CommonStrings.close,
  );

  /// Sky pill button (the source's OK / Restart Virtual _rt_Lab buttons).
  Widget _pillButton({
    required String key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _rt_Tw.sky500,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        key: ValueKey(key),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: _rt_Tw.slate950),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
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

  /// `#observation-popup` with the step conclusion and its OK button.
  Widget _observationPanel(double w, double h, bool sidebarClosed) {
    return _panelFrame(
      w: w,
      h: h,
      sidebarClosed: sidebarClosed,
      maxW: 620,
      offset: _obsOffset,
      onOffset: (o) => setState(() => _obsOffset = o),
      borderColor: _rt_Tw.sky500.withValues(alpha: 0.4),
      header: Container(
        key: const ValueKey('obs-panel'),
        padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xE6082F49), _rt_Tw.slate900],
          ),
          border: Border(
            bottom: BorderSide(color: _rt_Tw.sky500.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 20, color: _rt_Tw.sky400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _tx.s('sciObs'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: _rt_Tw.sky400,
                ),
              ),
            ),
            _closeButton('obs-close', _closeObservation),
          ],
        ),
      ),
      body: _conclusionBody(_obsModule),
    );
  }

  List<InlineSpan> _rich(String src) {
    final out = <InlineSpan>[];
    var i = 0;
    for (final m in _spanRe.allMatches(src)) {
      if (m.start > i) out.add(TextSpan(text: src.substring(i, m.start)));
      out.add(
        TextSpan(
          text: m.group(2),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _spanColors[m.group(1)],
          ),
        ),
      );
      i = m.end;
    }
    if (i < src.length) out.add(TextSpan(text: src.substring(i)));
    return out;
  }

  Widget _conclusionBody(int m) {
    final c = _tx.map('s${m}_conclusion');
    final items = (c['items'] as List).cast<String>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _rt_Lab.border)),
          ),
          child: Text(
            c['h'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _rt_Tw.sky400,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          c['p'] as String,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: _rt_Lab.text,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '• '),
                        ..._rich(items[i]),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: _rt_Lab.text,
                      height: 1.45,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _rt_Tw.sky500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _rt_Tw.sky500.withValues(alpha: 0.3)),
          ),
          child: Text(
            c['key'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.sky400,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: _rt_Lab.border)),
          ),
          alignment: Alignment.centerRight,
          child: _pillButton(
            key: 'obs-ok',
            icon: Icons.check,
            label: _tx.s('btnOk'),
            onTap: _confirmObservation,
          ),
        ),
      ],
    );
  }

  /// `#final-mastery-modal`.
  Widget _finalPanel(double w, double h, bool sidebarClosed) {
    final items = _tx.list('final_summary');
    // Source grid: one column, two from the md (768 px) breakpoint.
    final twoCol = MediaQuery.sizeOf(context).width >= 768;
    final cards = [
      for (var i = 0; i < items.length; i++) _summaryCard(i, items[i] as Map),
    ];
    return _panelFrame(
      w: w,
      h: h,
      sidebarClosed: sidebarClosed,
      maxW: 650,
      offset: _finalOffset,
      onOffset: (o) => setState(() => _finalOffset = o),
      borderColor: _rt_Tw.sky500.withValues(alpha: 0.5),
      header: Container(
        key: const ValueKey('final-panel'),
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_sky950, _rt_Tw.slate900, _indigo950],
          ),
          border: Border(
            bottom: BorderSide(color: _rt_Tw.sky500.withValues(alpha: 0.4)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _rt_Tw.sky500.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _rt_Tw.sky400),
              ),
              child: const Icon(Icons.emoji_events, size: 20, color: _sky300),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tx.s('finalTitle'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tx.s('subtitle'),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _rt_Tw.sky400,
                    ),
                  ),
                ],
              ),
            ),
            _closeButton('final-close', _closeFinal),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: twoCol
            ? [
                for (var i = 0; i < cards.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: cards[i]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: i + 1 < cards.length
                                ? cards[i + 1]
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ]
            : [
                for (var i = 0; i < cards.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                    child: cards[i],
                  ),
              ],
      ),
      footer: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _rt_Lab.surface,
          border: Border(top: BorderSide(color: _rt_Lab.border)),
        ),
        alignment: Alignment.center,
        child: _pillButton(
          key: 'final-restart',
          icon: Icons.refresh,
          label: _tx.s('btnRestartLab'),
          onTap: () {
            _rt_playSfx(
              _rt_Sfx.click,
            ); // source fullRestartLab: playSound('click')
            _restart();
          },
        ),
      ),
    );
  }

  Widget _summaryCard(int i, Map item) {
    const icons = [
      Icons.eco,
      Icons.call_split,
      Icons.local_fire_department,
      Icons.bolt,
    ];
    const colors = [
      _rt_Tw.sky400,
      _rt_Tw.cyan400,
      _rt_Tw.blue400,
      _rt_Tw.amber400,
    ];
    const borders = [
      _rt_Tw.sky500,
      _rt_Tw.cyan500,
      _rt_Tw.blue500,
      _rt_Tw.amber500,
    ];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borders[i].withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icons[i], size: 18, color: colors[i]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: colors[i],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['text'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _rt_Tw.slate300,
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

  // ------------------------------------------------------ scene pieces ---

  /// `.scene-container-box`.
  Widget _sceneFrame(Widget child) => Container(
    width: _dw,
    height: _dh,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xE00B152D),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _rt_Tw.sky400.withValues(alpha: 0.4), width: 2),
      boxShadow: [
        BoxShadow(color: _rt_Tw.sky400.withValues(alpha: 0.16), blurRadius: 24),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );

  /// Header banner: glowing dot, module title, MODULE n badge.
  Widget _sceneHeader(Color dot, String title, String badge) => Container(
    padding: const EdgeInsets.only(bottom: 6),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: _slateLine)),
    ),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dot,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: dot, blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: dot.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: dot.withValues(alpha: 0.3)),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: dot,
            ),
          ),
        ),
      ],
    ),
  );

  /// `.target-pin` (① ② ③ / A B C).
  Widget _pin(String s, {double size = 18}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _navy.withValues(alpha: 0.9),
      shape: BoxShape.circle,
      border: Border.all(color: _rt_Tw.sky400, width: 1.5),
      boxShadow: [
        BoxShadow(color: _rt_Tw.sky400.withValues(alpha: 0.5), blurRadius: 8),
      ],
    ),
    child: Text(
      s,
      style: TextStyle(
        fontSize: size * 0.5,
        fontWeight: FontWeight.w900,
        color: _rt_Tw.sky400,
        height: 1,
      ),
    ),
  );

  /// A `.dropzone` (tap target too). Lit while it is the current step's
  /// target (`active-target` + pulse) or while a token hovers it (`dragover`).
  Widget _dropZone({
    required String id,
    required int step,
    double? width,
    double? height,
    required double radius,
    required Color bg,
    Color? border,
    EdgeInsets padding = EdgeInsets.zero,
    required Widget child,
  }) {
    final active = _step == step;
    final lit = active || _hover.contains(id);
    Widget box = AnimatedContainer(
      key: _zoneKeys[id],
      duration: const Duration(milliseconds: 250),
      width: width,
      height: height,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: lit ? _rt_Tw.sky500.withValues(alpha: 0.35) : bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: _rt_Tw.sky400.withValues(alpha: 0.7),
                  blurRadius: 22,
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (border != null) {
      box = CustomPaint(
        foregroundPainter: _DashedRRectPainter(
          color: lit ? _rt_Tw.sky400 : border,
          radius: radius,
        ),
        child: box,
      );
    }
    return GestureDetector(
      key: ValueKey('zone-$id'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _tapZone(step),
      child: AnimatedScale(
        scale: lit ? 1.04 : 1,
        duration: const Duration(milliseconds: 250),
        child: AnimatedBuilder(
          animation: _time,
          builder: (_, child) =>
              Opacity(opacity: active ? _pulse : 1, child: child),
          child: box,
        ),
      ),
    );
  }

  /// A `.lab-token`: tap = click, drag = pointer drag onto any dropzone.
  Widget _token({
    required int step,
    required String id,
    required Color bg,
    required Color fg,
    required Color border,
    required IconData icon,
    required String label,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_time, _snap]),
      builder: (context, child) {
        Offset off = Offset.zero;
        if (_dragging) {
          off = _dragOffset;
        } else if (_snap.isAnimating) {
          off = Offset.lerp(
            _snapFrom,
            Offset.zero,
            Curves.easeOut.transform(_snap.value),
          )!;
        }
        // animate-bounce (paused while held).
        final c = math.cos(math.pi * (_time.value % 1));
        final bounce = _dragging ? 0.0 : -7 * c * c;
        return Transform.translate(
          offset: off + Offset(0, bounce),
          child: Transform.scale(scale: _dragging ? 1.06 : 1, child: child),
        );
      },
      child: GestureDetector(
        key: ValueKey('token-$id'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _place(step),
        onPanStart: (_) => _dragStart(),
        onPanUpdate: _dragUpdate,
        onPanEnd: (_) => _dragEnd(step),
        onPanCancel: _dragCancel,
        child: Container(
          key: _tokenKey,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _dragging ? 0.8 : 0.45),
                blurRadius: _dragging ? 22 : 12,
                offset: Offset(0, _dragging ? 12 : 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Coloured disc with a label (the P / Pi / ATP circles).
  Widget _ball(
    String label,
    double size,
    Color fill,
    Color border, {
    Color text = _rt_Tw.slate950,
    double? fontSize,
    Color? glow,
    Widget? child,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: size > 30 ? 2 : 1.2),
        boxShadow: [
          if (glow != null) BoxShadow(color: glow, blurRadius: 14),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          child ??
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? size * 0.34,
              fontWeight: FontWeight.w900,
              color: text,
              height: 1,
            ),
          ),
    );
  }

  Widget _pulsing(Widget child) => AnimatedBuilder(
    animation: _time,
    builder: (_, c) => Opacity(opacity: _pulse, child: c),
    child: child,
  );

  // ------------------------------------------------ module 1: leaf gas ---

  Widget _module1() {
    final s = _step;
    final annot = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w800,
      color: _rt_Tw.slate50,
      height: 1.2,
    );
    Widget slot(String text, double minH, {double size = 9}) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: minH),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: annot.copyWith(fontSize: size)),
      ),
    );
    return _sceneFrame(
      Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _LeafPainter(_time))),
          Positioned(
            left: 12,
            top: 8,
            right: 12,
            child: _sceneHeader(_rt_Tw.sky400, _tx.s('s1_title'), 'MODULE 1'),
          ),
          // Smiling sun (left) with the DAY caption.
          Positioned(
            left: 4,
            top: 46,
            width: 80,
            child: Column(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CustomPaint(painter: _SunPainter(_time)),
                ),
                const SizedBox(height: 2),
                Text(
                  _c('c_day'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: _rt_Tw.amber400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _c('c_spongyAirSpace'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: _rt_Tw.slate300,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          // Glowing moon (right) with the NIGHT caption.
          Positioned(
            left: 518,
            top: 46,
            width: 80,
            child: Column(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CustomPaint(painter: _MoonPainter(_time)),
                ),
                const SizedBox(height: 4),
                Text(
                  _c('c_night'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: _sky300,
                  ),
                ),
              ],
            ),
          ),
          // Bracket annotations of the day leaf (the SVG <text>s).
          Positioned(
            left: _lm(395, 0).dx,
            top: 128,
            width: 134,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                slot(_c('c_spongyProminent'), 30),
                slot(_c('c_largeAirSpaces'), 30),
                slot(_c('c_guardCell'), 14, size: 9.5),
              ],
            ),
          ),
          _airSpacesZone(),
          // ① Day stoma: oxygen released.
          Positioned(
            left: _lm(240, 0).dx - 30,
            top: _lm(0, 302).dy,
            child: _dropZone(
              id: 'day-stoma',
              step: 1,
              width: 60,
              height: 44,
              radius: 12,
              bg: _rt_Tw.sky500.withValues(alpha: 0.1),
              border: _rt_Tw.sky400.withValues(alpha: 0.8),
              // Shrinks to fit when large system text would overflow the
              // 60x44 zone.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _pin('①', size: 16),
                    const SizedBox(height: 2),
                    const Text(
                      'O₂ Release',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: _sky300,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ① ② Night stoma: carbon dioxide eliminated.
          Positioned(
            left: _lm(760, 0).dx - 30,
            top: _lm(0, 302).dy,
            child: _dropZone(
              id: 'night-stoma',
              step: 0,
              width: 60,
              height: 44,
              radius: 12,
              bg: _rt_Tw.pink500.withValues(alpha: 0.1),
              border: _pink400.withValues(alpha: 0.8),
              // Shrinks to fit when large system text would overflow the
              // 60x44 zone.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _pin('①', size: 16),
                        const SizedBox(width: 3),
                        _pin('②', size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'CO₂ Elim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: _pink300,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (s == 0 && !_done.contains(0))
            Positioned(
              right: 28,
              top: 266,
              child: _token(
                step: 0,
                id: 'co2-night',
                bg: _pink600,
                fg: Colors.white,
                border: _pink300,
                icon: Icons.air,
                label: _c('c_co2Elim'),
              ),
            ),
          if (s == 1 && !_done.contains(1))
            Positioned(
              left: 28,
              top: 266,
              child: _token(
                step: 1,
                id: 'o2-day',
                bg: _rt_Tw.sky500,
                fg: _rt_Tw.slate950,
                border: _sky200,
                icon: Icons.water_drop,
                label: _c('c_o2Released'),
              ),
            ),
          // Bottom legend.
          Positioned(
            left: 20,
            right: 20,
            top: 312,
            height: 18,
            child: _FitRow(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pulsing(_dot(_rt_Tw.sky400)),
                      const SizedBox(width: 6),
                      _legendText(_c('c_o2Released'), _sky300),
                      const SizedBox(width: 22),
                      _dot(_pink400),
                      const SizedBox(width: 6),
                      _legendText(_c('c_co2Photo'), _pink300),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pulsing(_dot(_rt_Tw.pink500)),
                      const SizedBox(width: 6),
                      _legendText(_c('c_co2Elim'), _pink400),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  Widget _legendText(String t, Color c) => Text(
    t,
    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c),
  );

  /// Step 3: `#click-airspaces` over the day leaf's spongy mesophyll.
  Widget _airSpacesZone() {
    final active = _step == 2;
    final tl = _lm(130, 172);
    final br = _lm(350, 262);
    return Positioned(
      left: tl.dx,
      top: tl.dy,
      width: br.dx - tl.dx,
      height: br.dy - tl.dy,
      child: IgnorePointer(
        ignoring: !active,
        child: GestureDetector(
          key: const ValueKey('zone-airspaces'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _tapZone(2),
          child: !active
              ? const SizedBox.expand()
              : AnimatedBuilder(
                  animation: _time,
                  builder: (_, child) {
                    final c = math.cos(math.pi * (_time.value % 1));
                    return Opacity(
                      opacity: _pulse,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(child: child!),
                          Positioned(
                            top: -9 - 5 * c * c,
                            left: -40,
                            right: -40,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _rt_Tw.sky400,
                                  borderRadius: BorderRadius.circular(99),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'CLICK TO INSPECT AIR SPACES',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                    color: _rt_Tw.slate950,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: CustomPaint(
                    foregroundPainter: const _DashedRRectPainter(
                      color: _rt_Tw.sky400,
                      radius: 18,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _rt_Tw.sky500.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // --------------------------------------------- module 2: glucose paths ---

  Widget _module2() {
    final s = _step;
    return _sceneFrame(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _sceneHeader(_rt_Tw.emerald400, _tx.s('s2_title'), 'MODULE 2'),
            const SizedBox(height: 6),
            _m2TopRow(),
            const SizedBox(
              height: 18,
              width: double.infinity,
              child: CustomPaint(painter: _BranchPainter(12)),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _branchA()),
                  const SizedBox(width: 12),
                  Expanded(child: _branchB()),
                  const SizedBox(width: 12),
                  Expanded(child: _branchC()),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: Center(
                child: switch (s) {
                  0 when !_done.contains(0) => _token(
                    step: 0,
                    id: 'glucose',
                    bg: _rt_Tw.purple500,
                    fg: Colors.white,
                    border: _purple200,
                    icon: Icons.view_in_ar,
                    label: _c('c_glucose6c'),
                  ),
                  1 when !_done.contains(1) => _token(
                    step: 1,
                    id: 'yeast',
                    bg: _rt_Tw.amber500,
                    fg: _rt_Tw.slate950,
                    border: _rt_Tw.amber200,
                    icon: Icons.science,
                    label: 'Yeast ${_c('c_absenceO2')}',
                  ),
                  2 when !_done.contains(2) => _token(
                    step: 2,
                    id: 'mito',
                    bg: _rt_Tw.sky500,
                    fg: _rt_Tw.slate950,
                    border: _sky200,
                    icon: Icons.blur_circular,
                    label: 'Mitochondria ${_c('c_presenceO2')}',
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Glucose -> [Cytoplasm] -> Pyruvate + Energy, with the ① caption.
  Widget _m2TopRow() {
    const label = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      height: 1.15,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Tw.slate950.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _slateLine),
      ),
      child: _FitRow(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _rt_Tw.purple600.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _purple400, width: 2),
                  ),
                  child: const Icon(Icons.hexagon, size: 20, color: _purple300),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: Text(_c('c_glucose6c'), style: label),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: _rt_Tw.emerald400,
                ),
                const SizedBox(width: 4),
                _dropZone(
                  id: 'cytoplasm',
                  step: 0,
                  radius: 99,
                  bg: _rt_Tw.slate800,
                  border: _rt_Tw.emerald400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  child: Text(
                    _c('c_cytoplasm'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _emerald300,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: _rt_Tw.emerald400,
                ),
              ],
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var r = 0; r < 2; r++)
                      Padding(
                        padding: EdgeInsets.only(top: r == 0 ? 0 : 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var k = 0; k < 3; k++)
                              Container(
                                width: 9,
                                height: 9,
                                margin: EdgeInsets.only(left: k == 0 ? 0 : 3),
                                decoration: const BoxDecoration(
                                  color: _purple400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 78,
                  child: Text(_c('c_pyruvate3c'), style: label),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _rt_Tw.amber500.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _rt_Tw.amber400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 12, color: _amber300),
                      const SizedBox(width: 2),
                      Text(
                        _c('c_energy'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: _amber300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    _c('c_commonStep'),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: _rt_Tw.slate400,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _pin('①', size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Body of one pathway card.
  Widget _branchCard({
    required String pin,
    required Widget icon,
    required String title,
    required Color titleColor,
    required String sub,
    double subSize = 9,
    required String product,
    required Widget energy,
    required Color divider,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: _Fit(
        fill: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _pin(pin, size: 20),
                const SizedBox(width: 6),
                icon,
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: TextStyle(
                          fontSize: subSize,
                          color: _rt_Tw.slate300,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 3,
                children: [
                  Text(
                    product,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  energy,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyTag(IconData icon, String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 2),
      Flexible(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    ],
  );

  /// Branch A: yeast, absence of oxygen (dropzone).
  Widget _branchA() {
    return _dropZone(
      id: 'yeast-branch',
      step: 1,
      radius: 20,
      bg: _amber950.withValues(alpha: 0.3),
      border: _rt_Tw.amber500.withValues(alpha: 0.6),
      child: _branchCard(
        pin: 'A',
        icon: SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.science, size: 26, color: _rt_Tw.amber400),
              // animate-yeast-bubble.
              AnimatedBuilder(
                animation: _time,
                builder: (_, _) {
                  final p = (_time.value % 1.8) / 1.8;
                  final rise = p < 0.5
                      ? 16 * Curves.easeOut.transform(p / 0.5)
                      : 16 + 16 * Curves.easeOut.transform((p - 0.5) / 0.5);
                  final op = p < 0.5
                      ? 0.3 + 0.7 * (p / 0.5)
                      : 1 - (p - 0.5) / 0.5;
                  final sc = p < 0.5
                      ? 0.8 + 0.35 * (p / 0.5)
                      : 1.15 + 0.15 * ((p - 0.5) / 0.5);
                  return Positioned(
                    top: -rise * 0.5,
                    right: 0,
                    child: Opacity(
                      opacity: _clampD(op, 0, 1),
                      child: Transform.scale(
                        scale: sc,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: _amber300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        title: _c('c_absenceO2'),
        titleColor: _amber300,
        sub: _c('c_yeastFerm'),
        product: _c('c_ethanolCo2'),
        energy: _energyTag(Icons.bolt, _c('c_lowEnergy'), _rt_Tw.amber400),
        divider: _rt_Tw.amber500.withValues(alpha: 0.3),
      ),
    );
  }

  /// Branch B: mitochondria, presence of oxygen (dropzone + badge).
  Widget _branchB() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _dropZone(
            id: 'mito-branch',
            step: 2,
            radius: 20,
            bg: _sky950.withValues(alpha: 0.4),
            border: _rt_Tw.sky400,
            child: _branchCard(
              pin: 'B',
              icon: AnimatedBuilder(
                animation: _time,
                builder: (_, _) => Icon(
                  Icons.blur_circular,
                  size: 26,
                  color: _rt_Tw.sky400,
                  shadows: [
                    Shadow(
                      color: _rt_Tw.sky400,
                      blurRadius: 6 + 10 * _wave(_time.value, 2.5),
                    ),
                  ],
                ),
              ),
              title: _c('c_presenceO2'),
              titleColor: _sky300,
              sub: _c('c_mitoOrg'),
              product: _c('c_co2Water'),
              energy: _pulsing(
                _energyTag(
                  Icons.local_fire_department,
                  _c('c_massiveEnergy'),
                  _amber300,
                ),
              ),
              divider: _rt_Tw.sky400.withValues(alpha: 0.3),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: 12,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: _rt_Tw.sky400,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                _c('c_releasesMore'),
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  color: _rt_Tw.slate950,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Branch C: muscle cells (tap target only on step 4; not a dropzone).
  Widget _branchC() {
    final active = _step == 3;
    return IgnorePointer(
      ignoring: !active,
      child: GestureDetector(
        key: const ValueKey('zone-muscle-branch'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _tapZone(3),
        child: AnimatedBuilder(
          animation: _time,
          builder: (_, child) =>
              Opacity(opacity: active ? _pulse : 1, child: child),
          child: Container(
            decoration: BoxDecoration(
              color: _pink950.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? _pink400
                    : _rt_Tw.pink500.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: _branchCard(
              pin: 'C',
              // animate-muscle-spasm.
              icon: AnimatedBuilder(
                animation: _time,
                builder: (_, child) {
                  final p = (_time.value % 2) / 2;
                  const rot = [0.0, -2.0, 2.0, -1.0, 1.0, 0.0];
                  const sc = [1.0, 1.05, 0.97, 1.04, 0.98, 1.0];
                  final seg = (p * 5).floor().clamp(0, 4);
                  final f = Curves.easeInOut.transform(p * 5 - seg);
                  final r = ui.lerpDouble(rot[seg], rot[seg + 1], f)!;
                  final s = ui.lerpDouble(sc[seg], sc[seg + 1], f)!;
                  return Transform.rotate(
                    angle: r * math.pi / 180,
                    child: Transform.scale(scale: s, child: child),
                  );
                },
                child: const Icon(
                  Icons.fitness_center,
                  size: 26,
                  color: _pink400,
                ),
              ),
              title: _c('c_lackO2'),
              titleColor: _pink300,
              sub: _c('c_muscleCell'),
              subSize: 8.8,
              product: _c('c_lacticAcid'),
              energy: _energyTag(Icons.warning_amber, _c('c_cramps'), _pink400),
              divider: _rt_Tw.pink500.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------- module 3: ATP cycle ---

  Widget _module3() {
    final s = _step;
    return _sceneFrame(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _sceneHeader(_rt_Tw.amber400, _tx.s('s3_title'), 'MODULE 3'),
            const SizedBox(height: 6),
            Expanded(
              child: _compartment(
                bg: _indigo950.withValues(alpha: 0.4),
                border: _rt_Tw.indigo500.withValues(alpha: 0.4),
                icon: Icons.add_circle,
                label: _c('c_synthesis'),
                labelColor: _indigo300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The "RESPIRATION ENERGY" arc chip.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _rt_Tw.amber500.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: _rt_Tw.amber400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 12, color: _amber300),
                          const SizedBox(width: 4),
                          Text(
                            _c('c_respEnergy'),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: _amber300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _FitRow(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _dropZone(
                            id: 'adp-synthesis',
                            step: 0,
                            radius: 14,
                            bg: Colors.transparent,
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 32,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        child: _ball(
                                          'P',
                                          32,
                                          _rt_Tw.purple600,
                                          _purple300,
                                          text: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Positioned(
                                        left: 24,
                                        child: _ball(
                                          'P',
                                          32,
                                          _rt_Tw.amber500,
                                          _rt_Tw.amber200,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _caption('ADP', _c('c_adp2p')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _rt_Tw.slate400,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _pulsing(
                                _ball(
                                  'Pi',
                                  32,
                                  _rt_Tw.amber400,
                                  _rt_Tw.amber200,
                                  fontSize: 11,
                                  glow: _rt_Tw.amber500.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _caption('Pi', _c('c_piInorg')),
                            ],
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: _rt_Tw.amber400,
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 40,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      child: _ball(
                                        'ATP',
                                        40,
                                        _rt_Tw.amber400,
                                        _amber100,
                                        fontSize: 10.5,
                                        glow: _rt_Tw.amber500.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 32,
                                      top: 6,
                                      child: _ball(
                                        'P',
                                        28,
                                        _rt_Tw.amber500,
                                        _rt_Tw.amber200,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                    Positioned(
                                      left: 52,
                                      top: 6,
                                      child: _ball(
                                        'P',
                                        28,
                                        _rt_Tw.amber500,
                                        _rt_Tw.amber200,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _caption('ATP', _c('c_atp3p')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _compartment(
                bg: _sky950.withValues(alpha: 0.4),
                border: _rt_Tw.sky500.withValues(alpha: 0.4),
                icon: Icons.arrow_circle_right,
                label: _c('c_use'),
                labelColor: _sky300,
                child: _FitRow(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dropZone(
                        id: 'terminal-bond',
                        step: 1,
                        radius: 14,
                        bg: Colors.transparent,
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 36,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: _ball(
                                      'ATP',
                                      36,
                                      _rt_Tw.amber400,
                                      _amber100,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Positioned(
                                    left: 30,
                                    top: 4,
                                    child: _ball(
                                      'P',
                                      28,
                                      _rt_Tw.amber500,
                                      _rt_Tw.amber200,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ATP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _rt_Tw.slate400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ball(
                            '',
                            28,
                            _rt_Tw.sky400,
                            _sky100,
                            child: const Icon(
                              Icons.water_drop,
                              size: 15,
                              color: _rt_Tw.slate950,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _c('c_water'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _sky300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: _rt_Tw.sky400,
                      ),
                      const SizedBox(width: 6),
                      // animate-30kj-burst.
                      AnimatedBuilder(
                        animation: _time,
                        builder: (_, child) {
                          final w = _wave(_time.value, 1.6);
                          return Transform.scale(
                            scale: 1 + 0.12 * w,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _rt_Tw.amber500,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _rt_Tw.amber200,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _rt_Tw.amber400.withValues(
                                      alpha: 0.6 + 0.3 * w,
                                    ),
                                    blurRadius: 12 + 14 * w,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt,
                              size: 15,
                              color: _rt_Tw.slate950,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _c('c_released30'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: _rt_Tw.slate950,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: _rt_Tw.amber400,
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 110,
                        child: Text(
                          _c('c_drivesEndo'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: _sky300,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: Center(
                child: switch (s) {
                  0 when !_done.contains(0) => _token(
                    step: 0,
                    id: 'pi-synthesis',
                    bg: _rt_Tw.amber400,
                    fg: _rt_Tw.slate950,
                    border: _amber100,
                    icon: Icons.circle,
                    label: _c('c_piInorg'),
                  ),
                  1 when !_done.contains(1) => _token(
                    step: 1,
                    id: 'water-use',
                    bg: _rt_Tw.sky400,
                    fg: _rt_Tw.slate950,
                    border: _sky100,
                    icon: Icons.water_drop,
                    label: '${_c('c_water')} (H₂O)',
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _caption(String title, String sub) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      Text(sub, style: const TextStyle(fontSize: 9.5, color: _rt_Tw.slate400)),
    ],
  );

  /// SYNTHESIS / USE box with its label and ① ② ③ pins.
  Widget _compartment({
    required Color bg,
    required Color border,
    required IconData icon,
    required String label,
    required Color labelColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: labelColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: labelColor,
                  ),
                ),
              ),
              for (final p in const ['①', '②', '③'])
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: _pin(p, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _Fit(child: Center(child: child)),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- widgets ---

/// Fits a column-like [child] to the available box: wraps it at the box
/// width, optionally stretches it to the box height ([fill]), and scales it
/// down only if it still does not fit.
class _Fit extends StatelessWidget {
  const _Fit({required this.child, this.fill = false});

  final Widget child;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        Widget inner = child;
        if (fill && c.hasBoundedHeight) {
          inner = ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: inner,
          );
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(width: c.maxWidth, child: inner),
        );
      },
    );
  }
}

/// Lays a row out at least as wide as the box (so spaceBetween / spaceAround
/// spread it) and scales it down if its natural width is larger.
class _FitRow extends StatelessWidget {
  const _FitRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: c.maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Round toggle for the canvas toolbar (lock / pan mode).
class _ToolToggle extends StatelessWidget {
  const _ToolToggle({
    super.key,
    required this.active,
    required this.color,
    required this.filled,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final bool active;
  final Color color;
  final bool filled;
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
            color: filled
                ? Color.alphaBlend(
                    color.withValues(alpha: 0.18),
                    _rt_Lab.surface,
                  )
                : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? color : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ painters ---

/// `#scene-wrapper` background: two soft radial glows on the dark base.
class _BgPainter extends CustomPainter {
  const _BgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = _bgMain);
    void glow(Offset c, Color col, double stop) {
      final far = [
        r.topLeft,
        r.topRight,
        r.bottomLeft,
        r.bottomRight,
      ].map((p) => (p - c).distance).reduce(math.max);
      canvas.drawRect(
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            c,
            far,
            [col, col.withValues(alpha: 0)],
            [0, stop],
          ),
      );
    }

    glow(
      Offset(size.width * 0.5, size.height * 0.1),
      _rt_Tw.sky500.withValues(alpha: 0.16),
      0.65,
    );
    glow(
      Offset(size.width * 0.85, size.height * 0.85),
      _rt_Tw.purple500.withValues(alpha: 0.14),
      0.6,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dashed rounded-rect outline (CSS `border-dashed`).
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const width = 2.0;
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(math.min(radius, size.shortestSide / 2)),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    for (final m in (Path()..addRRect(rr)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), paint);
      }
    }
  }

  @override
  bool? hitTest(Offset position) => false;

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// The branch lines of Fig. 5.8 joining the top row to the three cards.
class _BranchPainter extends CustomPainter {
  const _BranchPainter(this.gap);

  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final colW = (size.width - 2 * gap) / 3;
    final xs = [colW / 2, colW * 1.5 + gap, colW * 2.5 + 2 * gap];
    final mid = size.height / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = _rt_Tw.sky400;
    final path = Path()
      ..moveTo(xs[1], 0)
      ..lineTo(xs[1], size.height)
      ..moveTo(xs[0], size.height)
      ..lineTo(xs[0], mid)
      ..lineTo(xs[2], mid)
      ..lineTo(xs[2], size.height);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(xs[1], mid), 3.5, Paint()..color = _rt_Tw.sky400);
  }

  @override
  bool? hitTest(Offset position) => false;

  @override
  bool shouldRepaint(_BranchPainter old) => old.gap != gap;
}

/// `SVGS.leafPanelFull`: the day and night leaf cross-sections with their
/// light cones, gas streams and bracket annotations (text is drawn as
/// widgets on top). Paints in viewBox units through the `_lm` mapping.
class _LeafPainter extends CustomPainter {
  _LeafPainter(this.time) : super(repaint: time);

  final ValueNotifier<double> time;

  @override
  bool? hitTest(Offset position) => false;

  static Paint _line(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..color = c;

  static Paint _grad(Rect r, Color a, Color b, {bool diagonal = false}) =>
      Paint()
        ..shader = LinearGradient(
          begin: diagonal ? Alignment.topLeft : Alignment.topCenter,
          end: diagonal ? Alignment.bottomRight : Alignment.bottomCenter,
          colors: [a, b],
        ).createShader(r);

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    canvas.save();
    canvas.translate(_lox, _loy);
    canvas.scale(_lk);
    canvas.translate(0, -_ly0);
    _beams(canvas, t);
    _leaf(canvas, t, night: false);
    _dayStreams(canvas, t);
    _annotations(canvas);
    _leaf(canvas, t, night: true);
    _nightStream(canvas, t);
    canvas.restore();
  }

  /// Sun and moon light cones (animate-sun-beam).
  void _beams(Canvas c, double t) {
    final w = _wave(t, 3.5);
    final op = 0.35 + 0.35 * w;
    final sy = 1 + 0.08 * w;
    void beam(List<Offset> pts, Color col, bool fromRight) {
      final path = Path()..addPolygon(pts, true);
      final b = path.getBounds();
      c.save();
      c.translate(0, b.top);
      c.scale(1, sy);
      c.translate(0, -b.top);
      c.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: fromRight ? Alignment.topRight : Alignment.topLeft,
            end: fromRight ? Alignment.bottomLeft : Alignment.bottomRight,
            colors: [
              col.withValues(alpha: col.a * op / 0.7),
              col.withValues(alpha: 0),
            ],
          ).createShader(b),
      );
      c.restore();
    }

    beam(
      const [Offset(50, 40), Offset(120, 90), Offset(50, 220)],
      const Color.fromRGBO(251, 191, 36, 0.45),
      false,
    );
    beam(
      const [Offset(950, 40), Offset(880, 90), Offset(950, 220)],
      const Color.fromRGBO(56, 189, 248, 0.35),
      true,
    );
  }

  void _leaf(Canvas c, double t, {required bool night}) {
    final dx = night ? 520.0 : 0.0;
    final cuticle = night
        ? const [Color(0xFF38BDF8), Color(0xFF0284C7)]
        : const [Color(0xFFBEF264), Color(0xFF84CC16)];
    final cuticleStroke = night
        ? const Color(0xFF0369A1)
        : const Color(0xFF4D7C0F);
    final epi = night
        ? const [Color(0xFF334155), Color(0xFF1E293B)]
        : const [Color(0xFF86EFAC), Color(0xFF4ADE80)];
    final epiStroke = night ? const Color(0xFF334155) : const Color(0xFF166534);
    final pal = night
        ? const [Color(0xFF1E3A5F), Color(0xFF0F2540)]
        : const [Color(0xFF22C55E), Color(0xFF15803D)];
    final palStroke = night ? const Color(0xFF0F172A) : const Color(0xFF14532D);
    final spongy = night
        ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
        : const [Color(0xFF4ADE80), Color(0xFF16A34A)];
    final airFill = night
        ? const Color.fromRGBO(14, 165, 233, 0.18)
        : const Color.fromRGBO(255, 255, 255, 0.92);
    final airStroke = night ? const Color(0xFF38BDF8) : const Color(0xFF16A34A);

    // Cuticle.
    final cut = Path()
      ..moveTo(120 + dx, 70)
      ..quadraticBezierTo(240 + dx, 35, 360 + dx, 70)
      ..lineTo(360 + dx, 80)
      ..quadraticBezierTo(240 + dx, 45, 120 + dx, 80)
      ..close();
    c.drawPath(cut, _grad(cut.getBounds(), cuticle[0], cuticle[1]));
    c.drawPath(cut, _line(cuticleStroke, 2));

    void rect(
      double x,
      double y,
      double w,
      double h,
      double r,
      List<Color> g,
      Color stroke,
    ) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + dx, y, w, h),
        Radius.circular(r),
      );
      c.drawRRect(rr, _grad(rr.outerRect, g[0], g[1]));
      c.drawRRect(rr, _line(stroke, 2));
    }

    // Upper epidermis, palisade.
    for (final (x, y) in const [
      (125.0, 80.0),
      (172.0, 78.0),
      (219.0, 76.0),
      (266.0, 78.0),
      (313.0, 80.0),
    ]) {
      rect(x, y, 42, 24, 5, epi, epiStroke);
    }
    for (final (x, y) in const [
      (130.0, 110.0),
      (167.0, 108.0),
      (204.0, 106.0),
      (241.0, 106.0),
      (278.0, 108.0),
      (315.0, 110.0),
    ]) {
      rect(x, y, 32, 70, 8, pal, palStroke);
    }
    // Spongy cells.
    for (final (x, y, r) in const [
      (150.0, 195.0, 16.0),
      (190.0, 210.0, 17.0),
      (290.0, 205.0, 18.0),
      (330.0, 195.0, 16.0),
      (145.0, 245.0, 16.0),
      (335.0, 245.0, 16.0),
    ]) {
      final rc = Rect.fromCircle(center: Offset(x + dx, y), radius: r);
      c.drawOval(rc, _grad(rc, spongy[0], spongy[1], diagonal: true));
      c.drawOval(rc, _line(palStroke, 2));
    }
    // Large inter-cellular air space.
    final air = Path()
      ..moveTo(165 + dx, 185)
      ..cubicTo(205 + dx, 185, 215 + dx, 235, 185 + dx, 255)
      ..cubicTo(155 + dx, 265, 205 + dx, 280, 225 + dx, 260)
      ..cubicTo(260 + dx, 235, 280 + dx, 270, 315 + dx, 260)
      ..cubicTo(330 + dx, 235, 295 + dx, 185, 260 + dx, 190)
      ..cubicTo(235 + dx, 195, 225 + dx, 178, 190 + dx, 185)
      ..close();
    c.drawPath(air, Paint()..color = airFill);
    c.drawPath(air, _line(airStroke, 2.5));
    // Lower epidermis (gap for the stoma).
    for (final x in const [125.0, 172.0, 266.0, 313.0]) {
      rect(x, 270, 42, 22, 5, epi, epiStroke);
    }

    // Bean-shaped guard cells and the pore (animate-guard-cell).
    final s = 1 + 0.05 * _wave(t, 3);
    final pivot = Offset(240 + dx, 282);
    c.save();
    c.translate(pivot.dx, pivot.dy);
    c.scale(s);
    c.translate(-pivot.dx, -pivot.dy);
    final left = Path()
      ..moveTo(222 + dx, 265)
      ..cubicTo(200 + dx, 265, 200 + dx, 300, 222 + dx, 300)
      ..cubicTo(232 + dx, 300, 232 + dx, 265, 222 + dx, 265)
      ..close();
    final right = Path()
      ..moveTo(258 + dx, 265)
      ..cubicTo(280 + dx, 265, 280 + dx, 300, 258 + dx, 300)
      ..cubicTo(248 + dx, 300, 248 + dx, 265, 258 + dx, 265)
      ..close();
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: night ? 0.6 : 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final gFill = Paint()
      ..color = night ? const Color(0xFF64748B) : const Color(0xFF86EFAC);
    final gStroke = _line(
      night ? const Color(0xFF334155) : const Color(0xFF15803D),
      3,
    );
    for (final p in [left, right]) {
      c.drawPath(p.shift(const Offset(0, 3)), shadow);
    }
    for (final p in [left, right]) {
      c.drawPath(p, gFill);
      c.drawPath(p, gStroke);
    }
    final nucleus = Paint()
      ..color = night ? const Color(0xFF0F172A) : const Color(0xFF14532D);
    c.drawCircle(Offset(214 + dx, 282), 3, nucleus);
    c.drawCircle(Offset(266 + dx, 282), 3, nucleus);
    final pore = Rect.fromCenter(
      center: Offset(240 + dx, 282),
      width: 32,
      height: 20,
    );
    c.drawOval(pore, Paint()..color = night ? _rt_Tw.slate950 : _navy);
    c.drawOval(
      pore,
      _line(night ? const Color(0xFF38BDF8) : const Color(0xFF22C55E), 2),
    );
    c.restore();
  }

  /// One gas stream: a bubble and its trail, moved through three keyframes.
  void _stream(
    Canvas c, {
    required double p,
    required Curve curve,
    required List<double> tx,
    required List<double> ty,
    required List<double> sc,
    required List<double> op,
    required Color color,
    required Offset bubble,
    required double r,
    required Offset from,
    required Offset ctrl,
    required Offset to,
    required Offset pivot,
  }) {
    double kf(List<double> v) => p < 0.5
        ? ui.lerpDouble(v[0], v[1], curve.transform(p / 0.5))!
        : ui.lerpDouble(v[1], v[2], curve.transform((p - 0.5) / 0.5))!;
    final o = _clampD(kf(op), 0, 1);
    if (o < 0.01) return;
    final s = kf(sc);
    c.save();
    c.translate(kf(tx), kf(ty));
    c.translate(pivot.dx, pivot.dy);
    c.scale(s);
    c.translate(-pivot.dx, -pivot.dy);
    // The drop-shadow glow peaks at the 50 % keyframe.
    final glow = math.max(0.0, 1 - (p - 0.5).abs() * 4);
    if (glow > 0) {
      c.drawCircle(
        bubble,
        r + 5,
        Paint()
          ..color = color.withValues(alpha: 0.6 * glow * o)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    c.drawPath(
      Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, to.dx, to.dy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: o),
    );
    c.drawCircle(bubble, r, Paint()..color = color.withValues(alpha: o));
    c.drawCircle(bubble, r, _line(Colors.white.withValues(alpha: o), 2));
    c.restore();
  }

  void _dayStreams(Canvas c, double t) {
    final p = (t % 2.2) / 2.2;
    // Oxygen streaming out (animate-gas-out-left).
    _stream(
      c,
      p: p,
      curve: Curves.easeOut,
      tx: const [0, -12, -26],
      ty: const [0, 22, 45],
      sc: const [0.85, 1.15, 1.3],
      op: const [0.2, 1, 0],
      color: const Color(0xFF38BDF8),
      bubble: const Offset(215, 305),
      r: 7,
      from: const Offset(230, 290),
      ctrl: const Offset(200, 315),
      to: const Offset(180, 345),
      pivot: const Offset(205, 317),
    );
    // CO₂ going in (animate-gas-in-right).
    _stream(
      c,
      p: p,
      curve: Curves.easeIn,
      tx: const [18, 10, 0],
      ty: const [42, 20, 0],
      sc: const [1.2, 1.05, 0.85],
      op: const [0, 1, 0.2],
      color: const Color(0xFFF472B6),
      bubble: const Offset(275, 335),
      r: 6.5,
      from: const Offset(295, 345),
      ctrl: const Offset(270, 315),
      to: const Offset(250, 295),
      pivot: const Offset(272, 320),
    );
  }

  void _nightStream(Canvas c, double t) {
    // Night CO₂ elimination (animate-gas-night).
    _stream(
      c,
      p: (t % 2.2) / 2.2,
      curve: Curves.easeOut,
      tx: const [0, 12, 26],
      ty: const [0, 22, 45],
      sc: const [0.85, 1.15, 1.3],
      op: const [0.2, 1, 0],
      color: _rt_Tw.pink500,
      bubble: const Offset(800, 330),
      r: 7,
      from: const Offset(765, 295),
      ctrl: const Offset(785, 315),
      to: const Offset(810, 345),
      pivot: const Offset(787, 320),
    );
  }

  /// Bracket lines and the dashed guard-cell leader.
  void _annotations(Canvas c) {
    final white = _line(_rt_Tw.slate50, 2);
    c.drawPath(
      Path()..addPolygon(const [
        Offset(370, 185),
        Offset(380, 185),
        Offset(380, 205),
        Offset(388, 205),
        Offset(380, 205),
        Offset(380, 225),
        Offset(370, 225),
      ], false),
      white,
    );
    c.drawPath(
      Path()..addPolygon(const [
        Offset(370, 235),
        Offset(380, 235),
        Offset(380, 260),
        Offset(388, 260),
        Offset(380, 260),
        Offset(380, 285),
        Offset(370, 285),
      ], false),
      white,
    );
    final dash = _line(_rt_Tw.slate50, 1.5);
    for (var x = 275.0; x < 390; x += 6) {
      c.drawLine(Offset(x, 292), Offset(math.min(x + 3, 390), 292), dash);
    }
    c.drawCircle(const Offset(275, 292), 2.5, Paint()..color = _rt_Tw.slate50);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `SVGS.cuteSun` (viewBox 100) with the slowly turning rays.
class _SunPainter extends CustomPainter {
  _SunPainter(this.time) : super(repaint: time);

  final ValueNotifier<double> time;

  @override
  bool? hitTest(Offset position) => false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);
    final rays = Paint()..color = _rt_Tw.amber500;
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(2 * math.pi * (time.value % 22) / 22);
    canvas.translate(-50, -50);
    for (final tri in const [
      [Offset(50, 6), Offset(54, 20), Offset(46, 20)],
      [Offset(50, 94), Offset(54, 80), Offset(46, 80)],
      [Offset(6, 50), Offset(20, 54), Offset(20, 46)],
      [Offset(94, 50), Offset(80, 54), Offset(80, 46)],
      [Offset(19, 19), Offset(33, 26), Offset(26, 33)],
      [Offset(81, 81), Offset(67, 74), Offset(74, 67)],
      [Offset(19, 81), Offset(26, 67), Offset(33, 74)],
      [Offset(81, 19), Offset(74, 33), Offset(67, 26)],
    ]) {
      canvas.drawPath(Path()..addPolygon(tri, true), rays);
    }
    canvas.restore();
    const center = Offset(50, 50);
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFEF08A), _rt_Tw.amber500, _rt_Tw.amber600],
          stops: [0, 0.7, 1],
        ).createShader(Rect.fromCircle(center: center, radius: 28)),
    );
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _rt_Tw.amber700,
    );
    const ink = Color(0xFF451A03);
    canvas.drawCircle(const Offset(41, 46), 3.5, Paint()..color = ink);
    canvas.drawCircle(const Offset(59, 46), 3.5, Paint()..color = ink);
    canvas.drawPath(
      Path()
        ..moveTo(42, 56)
        ..quadraticBezierTo(50, 64, 58, 56),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = ink,
    );
    final cheek = Paint()..color = _rt_Tw.red400.withValues(alpha: 0.6);
    canvas.drawCircle(const Offset(36, 53), 3, cheek);
    canvas.drawCircle(const Offset(64, 53), 3, cheek);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `SVGS.glowingMoon` (viewBox 100) with pulsing stars.
class _MoonPainter extends CustomPainter {
  _MoonPainter(this.time) : super(repaint: time);

  final ValueNotifier<double> time;

  @override
  bool? hitTest(Offset position) => false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);
    const center = Offset(50, 50);
    canvas.drawCircle(
      center,
      40,
      Paint()
        ..color = _rt_Tw.sky400.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(center, 38, Paint()..color = _rt_Tw.slate800);
    canvas.drawCircle(
      center,
      38,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _rt_Tw.sky400,
    );
    canvas.drawPath(
      Path()
        ..moveTo(45, 22)
        ..cubicTo(32, 32, 32, 68, 48, 78)
        ..cubicTo(30, 78, 22, 55, 34, 32)
        ..cubicTo(38, 27, 42, 24, 45, 22)
        ..close(),
      Paint()..color = _rt_Tw.slate50,
    );
    // animate-pulse: opacity 1 -> 0.5 -> 1 over 2 s.
    final a = 0.75 + 0.25 * math.cos(2 * math.pi * (time.value % 2) / 2);
    canvas.drawCircle(
      const Offset(65, 35),
      2.5,
      Paint()..color = _rt_Tw.sky400.withValues(alpha: a),
    );
    canvas.drawCircle(
      const Offset(75, 52),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: a),
    );
    canvas.drawCircle(
      const Offset(62, 68),
      2,
      Paint()..color = _rt_Tw.sky400.withValues(alpha: a),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------------------------------------------------------------ confetti ---

class _Particle {
  const _Particle(
    this.angle,
    this.velocity,
    this.color,
    this.wobble,
    this.wobbleSpeed,
    this.tilt,
    this.round,
  );

  final double angle;
  final double velocity;
  final Color color;
  final double wobble;
  final double wobbleSpeed;
  final double tilt;
  final bool round;
}

/// One `confetti({particleCount, spread, origin})` call (canvas-confetti's
/// defaults: angle 90°, startVelocity 45, decay 0.9, gravity 1, 200 ticks).
class _Burst {
  _Burst({
    required this.start,
    required int count,
    required double spread,
    required this.originY,
    required int seed,
  }) : particles = _make(count, spread, seed);

  final double start;
  final double originY;
  final List<_Particle> particles;

  static const _colors = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];

  static List<_Particle> _make(int count, double spread, int seed) {
    final rnd = math.Random(seed);
    final rad = spread * math.pi / 180;
    return [
      for (var i = 0; i < count; i++)
        _Particle(
          -math.pi / 2 + (0.5 * rad - rnd.nextDouble() * rad),
          22.5 + rnd.nextDouble() * 45,
          _colors[rnd.nextInt(_colors.length)],
          rnd.nextDouble() * 10,
          math.min(0.11, rnd.nextDouble() * 0.1 + 0.05),
          (rnd.nextDouble() * 0.5 + 0.25) * math.pi,
          rnd.nextBool(),
        ),
    ];
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.burst, this.time) : super(repaint: time);

  final _Burst burst;
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final ticks = (time.value - burst.start) * 60;
    if (ticks < 0 || ticks > 200) return;
    // The source bursts over a desktop window; scale the throw to the canvas.
    final k = _clampD(size.height / 700, 0.35, 1.2);
    final origin = Offset(size.width * 0.5, size.height * burst.originY);
    final travel = (1 - math.pow(0.9, ticks).toDouble()) / 0.1;
    final alpha = _clampD(1 - ticks / 200, 0, 1);
    for (final p in burst.particles) {
      final d = p.velocity * travel * k;
      final wob = p.wobble + p.wobbleSpeed * ticks;
      final pos =
          origin +
          Offset(
            math.cos(p.angle) * d + 10 * k * math.cos(wob),
            math.sin(p.angle) * d + 3 * ticks * k + 10 * k * math.sin(wob),
          );
      final paint = Paint()..color = p.color.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.tilt + ticks * 0.1);
      canvas.scale(1, math.cos(wob).abs() * 0.8 + 0.2);
      if (p.round) {
        canvas.drawCircle(Offset.zero, 4 * k + 1.5, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: 9 * k + 3,
            height: 6 * k + 2,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.burst != burst;
}
