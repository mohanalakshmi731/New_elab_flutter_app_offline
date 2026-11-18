// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 3.1: Physical Properties Lab
// Converted from Cl10S-Ch3-A1-PhysicalProperties.html (React + Motion -> Flutter widgets).
//
// A 2D DOM simulation, so the canvas is a widget tree rather than a mini3d
// scene. Four stations test one physical property each against nine
// materials: lustre & hardness (sandpaper / knife), malleability & ductility
// (hammer on an anvil / die plate and pull handle), conductivity (burner on a
// rod carrying a wax-stuck pin / bulb circuit) and sonority (striker on a
// hanging plate). Every drag in the source is kept and mirrored by a button;
// the four-item mission log ticks itself off and ends in a summary popup.

// --- TRANSLATION DATA (content) ---

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
  static const gray400 = Color(0xFF9CA3AF);
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal600 = Color(0xFF0D9488);
  static const teal900 = Color(0xFF134E4A);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const orange400 = Color(0xFFFB923C);
  static const orange600 = Color(0xFFEA580C);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green50 = Color(0xFFF0FDF4);
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
    this.expand = false,
    this.sound = _rt_Sfx.click,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done = false;
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
      'title': 'Physical Properties _rt_Lab',
      'subtitle': 'Class 10 • Metals and Non-Metals',
      'button': 'Enter _rt_Lab',
      'footnote': 'Hardness • Malleability • Ductility • Conductivity',
    },
    'headerTitle': 'Physical Properties _rt_Lab',
    'headerSubtitle': 'NCERT Class 10 • Metals and Non-Metals',
    'tabs': {'explore': 'Mission Log', 'notes': 'Properties'},
    'ui': {
      'select': 'Select Material',
      'properties': 'Properties',
      'type': 'Type',
      'density': 'Density',
      'malleable': 'Malleable',
      'ductile': 'Ductile',
      'sonorous': 'Sonorous',
      'conductor': 'Conductor',
      'hard': 'Hard',
      'exception': 'Exception',
      'station': 'Test Station',
      'observation': 'Observation',
      'action': 'Action',
      'toggleLabels': 'Toggle Labels',
    },
    'types': {
      'metal': 'Metal',
      'non-metal': 'Non-metal',
      'insulator': 'Insulator',
    },
    'modes': {
      'appearance': 'Lustre & Hardness',
      'forge': 'Malleability (Hammer)',
      'duct': 'Ductility (Extruder)',
      'cond': 'Conductivity',
      'son': 'Sonority',
      'heat': 'Heat',
      'elec': 'Electricity',
    },
    'labels': {
      'sample': 'Sample',
      'hammer': 'Hammer',
      'anvil': 'Anvil',
      'die': 'Die Plate',
      'handle': 'Pull Handle',
      'bulb': 'Bulb',
      'battery': 'Battery',
      'switch': 'Switch',
      'clips': 'Test Gap (Clips)',
      'stand': 'Stand',
      'wax': 'Wax',
      'pin': 'Pin',
      'burner': 'Burner',
      'striker': 'Strike',
      'plate': 'Plate',
      'knife': 'Knife',
      'sandpaper': 'Sandpaper',
      'endA': 'End A',
      'endB': 'End B',
    },
    'materials': {
      'iron': 'Iron',
      'copper': 'Copper',
      'aluminium': 'Aluminium',
      'gold': 'Gold',
      'sodium': 'Sodium',
      'coal': 'Coal',
      'graphite': 'Graphite',
      'wood': 'Wood',
      'rubber': 'Rubber',
    },
    'exceptions': {
      'sodium': 'Soft Metal',
      'graphite': 'Conductive Non-Metal',
      'gold': 'Most Ductile',
    },
    'missionBrief': 'Main Objective',
    'dropHere': 'Drop Material Here',
    'removeSample': 'Remove Sample',
    'flattened': 'Flattened Sheet',
    'deforming': 'Deforming...',
    'drawnWire': 'Drawn Wire',
    'goldWire': '2 km wire (from 1 g)',
    'shattered': 'Shattered',
    'cutLabel': 'Cut',
    'applyBurner': 'Apply Burner to End A',
    'placeSample': 'Place Sample in Circuit',
    'tapOrDrag': 'Tap a tool, or drag it onto the sample.',
    'freshCut': 'Shiny Lustrous Surface!',
    'waxMelted': 'Wax melted – the pin dropped!',
    'dragHammer': 'Drag the hammer onto the anvil, or tap HAMMER.',
    'dragSample': 'Drag the sample into the test gap, or tap the button.',
    'explore': {
      'objective':
          "Your goal is to test and classify materials based on their physical properties by completing the scientist's checklist.",
      'steps': [
        {
          'title': 'Test Hardness',
          'do': 'Try to cut Iron and Sodium with the Knife.',
          'focus': 'Iron is hard (clink sound), Sodium is soft (cuts easily).',
        },
        {
          'title': 'Test Malleability',
          'do': 'Hit the Aluminium sample 3 times with the Hammer.',
          'focus': 'It flattens into a thin sheet.',
        },
        {
          'title': 'Test Ductility',
          'do': 'Select Gold and pull the Draw Handle.',
          'focus': 'Gold stretches endlessly into a wire.',
        },
        {
          'title': 'Test Conductivity',
          'do': 'Apply the Burner to End A of the Copper rod.',
          'focus': 'Heat travels, melting the wax at End B.',
        },
      ],
    },
    'messages': {
      'cut_soft':
          'Observation: Knife cuts through. Conclusion: Sodium is soft (Alkali Metal).',
      'cut_hard': 'Observation: Knife cannot cut. Conclusion: Metals are hard.',
      'cut_fail':
          'Observation: Material breaks/cuts. Conclusion: Non-metals are soft/brittle.',
      'lustre_metal':
          'Observation: Shiny surface. Conclusion: Metals have Metallic Lustre.',
      'lustre_nonmetal':
          'Observation: Dull surface. Conclusion: Non-metals lack Lustre.',
      'shatter': 'Observation: Shattered! Conclusion: Non-metals are Brittle.',
      'flatten_metal':
          'Observation: Flattened! Conclusion: Metals are Malleable.',
      'flatten_progress': 'Mission: Hit {n} more times to flatten!',
      'wire_gold':
          'Observation: Gold wire! Conclusion: Most Ductile Metal (2 km from 1 g).',
      'wire_metal': 'Observation: Wire drawn. Conclusion: Metals are Ductile.',
      'wire_break':
          'Observation: Broke. Conclusion: Non-metals are not Ductile.',
      'cond_insulator': 'Observation: Heat does not travel through insulator.',
      'cond_nonmetal_exc':
          'Observation: Bulb glows! Conclusion: Exception (Graphite) conducts electricity.',
      'cond_metal':
          'Observation: Bulb glows! Conclusion: Metals are Good Conductors.',
      'cond_fail': 'Observation: Bulb OFF. Conclusion: Insulator.',
      'cond_heat': 'Observation: Heat Conducted. Wax Melted.',
      'sonorous_metal':
          'Observation: Ringing Sound produced! Conclusion: Metals are Sonorous.',
      'sonorous_nonmetal':
          'Observation: Dull Thud. Conclusion: Non-metals are Non-Sonorous.',
      'heat_popup': 'Drag the Burner to End A to heat the rod',
      'die_tooltip': 'Metal is drawn through this hole to make wire.',
      'textbook_gold':
          'Textbook Fact: Gold is the most ductile metal. A wire of about 2 km length can be drawn from 1 g of gold.',
    },
  },
  'hi': {
    'intro': {
      'title': 'भौतिक गुण प्रयोगशाला',
      'subtitle': 'कक्षा 10 • धातु और अधातु',
      'button': 'प्रयोगशाला में प्रवेश करें',
      'footnote': 'कठोरता • आघातवर्ध्यता • तन्यता • चालकता',
    },
    'headerTitle': 'भौतिक गुण प्रयोगशाला',
    'headerSubtitle': 'एनसीईआरटी कक्षा 10 • धातु और अधातु',
    'tabs': {'explore': 'मिशन लॉग', 'notes': 'गुण'},
    'ui': {
      'select': 'सामग्री चुनें',
      'properties': 'गुण',
      'type': 'प्रकार',
      'density': 'घनत्व',
      'malleable': 'आघातवर्ध्य',
      'ductile': 'तन्य',
      'sonorous': 'ध्वानिक',
      'conductor': 'चालक',
      'hard': 'कठोर',
      'exception': 'अपवाद',
      'station': 'परीक्षण केंद्र',
      'observation': 'अवलोकन',
      'action': 'कार्य',
      'toggleLabels': 'लेबल टॉगल करें',
    },
    'types': {
      'metal': 'धातु',
      'non-metal': 'अधातु',
      'insulator': 'विद्युतरोधी',
    },
    'modes': {
      'appearance': 'चमक और कठोरता',
      'forge': 'आघातवर्ध्यता (हथौड़ा)',
      'duct': 'तन्यता (एक्सट्रूडर)',
      'cond': 'चालकता',
      'son': 'ध्वानिकता',
      'heat': 'ऊष्मा',
      'elec': 'विद्युत',
    },
    'labels': {
      'sample': 'नमूना',
      'hammer': 'हथौड़ा',
      'anvil': 'निहाई',
      'die': 'डाई प्लेट (सांचा)',
      'handle': 'हैंडल खींचें',
      'bulb': 'बल्ब',
      'battery': 'बैटरी',
      'switch': 'स्विच',
      'clips': 'टेस्ट गैप (क्लिप्स)',
      'stand': 'स्टैंड',
      'wax': 'मोम',
      'pin': 'पिन',
      'burner': 'बर्नर',
      'striker': 'प्रहार करें',
      'plate': 'प्लेट',
      'knife': 'चाकू',
      'sandpaper': 'रेगमाल',
      'endA': 'सिरा A',
      'endB': 'सिरा B',
    },
    'materials': {
      'iron': 'लोहा',
      'copper': 'तांबा',
      'aluminium': 'एल्युमीनियम',
      'gold': 'सोना',
      'sodium': 'सोडियम',
      'coal': 'कोयला',
      'graphite': 'ग्रेफाइट',
      'wood': 'लकड़ी',
      'rubber': 'रबर',
    },
    'exceptions': {
      'sodium': 'नरम धातु',
      'graphite': 'चालक अधातु',
      'gold': 'सर्वाधिक तन्य',
    },
    'missionBrief': 'मुख्य उद्देश्य',
    'dropHere': 'सामग्री यहाँ डालें',
    'removeSample': 'नमूना हटाएँ',
    'flattened': 'चपटी शीट',
    'deforming': 'विरूपण...',
    'drawnWire': 'खिंचा हुआ तार',
    'goldWire': '2 किमी तार (1 ग्राम से)',
    'shattered': 'बिखर गया',
    'cutLabel': 'कटा हुआ',
    'applyBurner': 'बर्नर को सिरे A पर लगाएं',
    'placeSample': 'नमूने को परिपथ में रखें',
    'tapOrDrag': 'उपकरण पर टैप करें, या उसे नमूने पर खींचें।',
    'freshCut': 'चमकदार धात्विक सतह!',
    'waxMelted': 'मोम पिघल गया – पिन गिर गई!',
    'dragHammer': 'हथौड़े को निहाई पर खींचें, या हथौड़ा बटन दबाएँ।',
    'dragSample': 'नमूने को टेस्ट गैप में खींचें, या बटन दबाएँ।',
    'explore': {
      'objective':
          'आपका लक्ष्य वैज्ञानिक चेकलिस्ट को पूरा करके उनके भौतिक गुणों के आधार पर सामग्रियों का परीक्षण और वर्गीकरण करना है।',
      'steps': [
        {
          'title': 'कठोरता का परीक्षण करें',
          'do': 'चाकू से लोहे और सोडियम को काटने का प्रयास करें।',
          'focus':
              'लोहा कठोर है (क्लिंक ध्वनि), सोडियम नरम है (आसानी से कट जाता है)।',
        },
        {
          'title': 'आघातवर्ध्यता का परीक्षण करें',
          'do': 'एल्युमीनियम के नमूने को हथौड़े से 3 बार मारें।',
          'focus': 'यह एक पतली शीट में चपटा हो जाता है।',
        },
        {
          'title': 'तन्यता का परीक्षण करें',
          'do': 'सोना चुनें और ड्रॉ हैंडल खींचें।',
          'focus': 'सोना अंतहीन रूप से एक तार में खींचता है।',
        },
        {
          'title': 'चालकता का परीक्षण करें',
          'do': 'बर्नर को तांबे की छड़ के सिरे A पर लगाएं।',
          'focus': 'ऊष्मा सिरे B पर मोम को पिघलाते हुए यात्रा करती है।',
        },
      ],
    },
    'messages': {
      'cut_soft': 'अवलोकन: चाकू आसानी से काटता है। निष्कर्ष: सोडियम नरम है।',
      'cut_hard': 'अवलोकन: चाकू नहीं काट सकता। निष्कर्ष: धातुएँ कठोर होती हैं।',
      'cut_fail':
          'अवलोकन: सामग्री टूट/कट जाती है। निष्कर्ष: अधातुएँ नरम/भंगुर होती हैं।',
      'lustre_metal':
          'अवलोकन: चमकदार सतह। निष्कर्ष: धातुओं में धात्विक चमक होती है।',
      'lustre_nonmetal':
          'अवलोकन: सुस्त सतह। निष्कर्ष: अधातुओं में चमक की कमी होती है।',
      'shatter': 'अवलोकन: बिखर गया! निष्कर्ष: अधातुएँ भंगुर होती हैं।',
      'flatten_metal':
          'अवलोकन: चपटा हो गया! निष्कर्ष: धातुएँ आघातवर्ध्य होती हैं।',
      'flatten_progress': 'मिशन: चपटा करने के लिए {n} बार और मारें!',
      'wire_gold': 'अवलोकन: सोने का तार! निष्कर्ष: सबसे तन्य धातु (1g से 2km)।',
      'wire_metal': 'अवलोकन: तार खींचा गया। निष्कर्ष: धातुएँ तन्य होती हैं।',
      'wire_break': 'अवलोकन: टूट गया। निष्कर्ष: अधातुएँ तन्य नहीं होती हैं।',
      'cond_insulator':
          'अवलोकन: कुचालक के माध्यम से ऊष्मा यात्रा नहीं करती है।',
      'cond_nonmetal_exc':
          'अवलोकन: बल्ब जलता है! निष्कर्ष: अपवाद (ग्रेफाइट) बिजली का संचालन करता है।',
      'cond_metal':
          'अवलोकन: बल्ब जलता है! निष्कर्ष: धातुएँ अच्छी संवाहक होती हैं।',
      'cond_fail': 'अवलोकन: बल्ब बंद। निष्कर्ष: कुचालक।',
      'cond_heat': 'अवलोकन: ऊष्मा संचालित हुई। मोम पिघल गया।',
      'sonorous_metal':
          'अवलोकन: बजने वाली ध्वनि उत्पन्न हुई! निष्कर्ष: धातुएँ ध्वानिक होती हैं।',
      'sonorous_nonmetal':
          'अवलोकन: सुस्त धप। निष्कर्ष: अधातुएँ ध्वानिक नहीं होती हैं।',
      'heat_popup': 'छड़ को गर्म करने के लिए बर्नर को सिरे A तक खींचें',
      'die_tooltip':
          'तार बनाने के लिए धातु को इस छेद के माध्यम से खींचा जाता है।',
      'textbook_gold':
          'पाठ्यपुस्तक तथ्य: सोना सबसे तन्य धातु है। 1 ग्राम सोने से लगभग 2 किमी लंबा तार खींचा जा सकता है।',
    },
  },
});

/// One row of the source's `MATERIALS` table, with its CSS gradient.
class _Mat {
  const _Mat(
    this.id,
    this.type,
    this.density, {
    required this.hard,
    required this.malleable,
    required this.ductile,
    required this.conductor,
    required this.sonorous,
    required this.colors,
    required this.border,
  });

  final String id;
  final String type; // metal | non-metal | insulator
  final double density;
  final bool hard, malleable, ductile, conductor, sonorous;
  final List<Color> colors;
  final Color border;

  bool get isMetal => type == 'metal';
}

const _materials = <_Mat>[
  _Mat(
    'iron',
    'metal',
    7.8,
    hard: true,
    malleable: true,
    ductile: true,
    conductor: true,
    sonorous: true,
    colors: [Color(0xFF788289), Color(0xFFAAB5BC), Color(0xFF646D75)],
    border: Color(0xFF545E65),
  ),
  _Mat(
    'copper',
    'metal',
    8.9,
    hard: true,
    malleable: true,
    ductile: true,
    conductor: true,
    sonorous: true,
    colors: [Color(0xFFB87333), Color(0xFFE6AC7F), Color(0xFF8C4A16)],
    border: Color(0xFF8C4A16),
  ),
  _Mat(
    'aluminium',
    'metal',
    2.7,
    hard: true,
    malleable: true,
    ductile: true,
    conductor: true,
    sonorous: true,
    colors: [Color(0xFFD3DBE0), Color(0xFFF5F7FA), Color(0xFFB0BEC5)],
    border: Color(0xFF90A4AE),
  ),
  _Mat(
    'gold',
    'metal',
    19.3,
    hard: true,
    malleable: true,
    ductile: true,
    conductor: true,
    sonorous: true,
    colors: [Color(0xFFE6B800), Color(0xFFFFE96B), Color(0xFFBF9B30)],
    border: Color(0xFFB8860B),
  ),
  _Mat(
    'sodium',
    'metal',
    0.97,
    hard: false,
    malleable: true,
    ductile: false,
    conductor: true,
    sonorous: false,
    colors: [Color(0xFFCFD8DC), Color(0xFFDDE4E7), Color(0xFFB9C4C9)],
    border: Color(0xFFB0BEC5),
  ),
  _Mat(
    'coal',
    'non-metal',
    1.3,
    hard: false,
    malleable: false,
    ductile: false,
    conductor: false,
    sonorous: false,
    colors: [Color(0xFF2E2E2E), Color(0xFF212121), Color(0xFF121212)],
    border: Color(0xFF000000),
  ),
  _Mat(
    'graphite',
    'non-metal',
    2.2,
    hard: false,
    malleable: false,
    ductile: false,
    conductor: true,
    sonorous: false,
    colors: [Color(0xFF374151), Color(0xFF4B5563), Color(0xFF374151)],
    border: Color(0xFF1F2937),
  ),
  _Mat(
    'wood',
    'non-metal',
    0.7,
    hard: false,
    malleable: false,
    ductile: false,
    conductor: false,
    sonorous: false,
    colors: [Color(0xFFD4A373), Color(0xFFC08552), Color(0xFFA0522D)],
    border: Color(0xFF8B4513),
  ),
  _Mat(
    'rubber',
    'insulator',
    1.1,
    hard: false,
    malleable: false,
    ductile: false,
    conductor: false,
    sonorous: false,
    colors: [Color(0xFFC0392B), Color(0xFFB33426), Color(0xFF96281B)],
    border: Color(0xFF96281B),
  ),
];

/// Materials that carry an `exception` note in the source table.
const _exceptionIds = {'sodium', 'graphite', 'gold'};

/// Fixed scatter for the 12 fragments of a shattered sample (the source
/// uses `Math.random()` per render; a seeded list keeps snapshots stable).
final List<(Offset, double)> _shards = () {
  final r = math.Random(7);
  return List.generate(12, (_) {
    final dx = (r.nextDouble() - 0.5) * 300;
    final dy = (r.nextDouble() - 0.5) * 300 + 100;
    return (Offset(dx, dy), r.nextDouble() * 4 * math.pi);
  });
}();

enum _Station { appearance, forge, conductivity, sonority }

class Cl10SCh03A1PhysicalPropertiesPage extends StatefulWidget {
  const Cl10SCh03A1PhysicalPropertiesPage({super.key});

  @override
  State<Cl10SCh03A1PhysicalPropertiesPage> createState() =>
      _Cl10SCh03A1PhysicalPropertiesPageState();
}

class _Cl10SCh03A1PhysicalPropertiesPageState
    extends State<Cl10SCh03A1PhysicalPropertiesPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();
  final ScrollController _modeBar = ScrollController();

  // --- SIM STATE (simState in the source; reset when the material changes) ---
  int _matIndex = 0;
  _Station _station = _Station.appearance;
  bool _extruder = false; // forge sub-mode (HAMMER / EXTRUDER)
  bool _electric = false; // conductivity sub-mode (HEAT / ELEC)
  bool _showLabels = true; // the source's "Toggle Labels" tool

  bool _polished = false;
  bool _cut = false;
  bool _flattened = false;
  int _flattenLevel = 0;
  bool _shattered = false;
  bool _wire = false;
  double _heat = 0;
  bool _waxFell = false;
  bool _burnerAtA = false;
  bool _insulatorWarned = false;
  bool _inCircuit = false;

  String? _message;
  Timer? _messageTimer;
  Timer? _heatTimer;

  // Created in initState, not lazily: dispose() disposes all of them, and a
  // lazy controller first touched there looks up the already-unmounted
  // element and throws when the lab is closed.
  late final AnimationController _ripple, _shine, _wireAnim, _shardAnim;
  late final AnimationController _flash;
  bool _striking = false;

  /// Sticky across material changes, like the source's `missions` map.
  final List<bool> _checklist = [false, false, false, false];

  _Mat get _mat => _materials[_matIndex];
  String get _matName => _tx.s('materials.${_mat.id}');
  List<dynamic> get _steps => _tx.list('explore.steps');

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _wireAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _shardAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
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
    _messageTimer?.cancel();
    _zoom.dispose();
    _modeBar.dispose();
    _heatTimer?.cancel();
    _ripple.dispose();
    _shine.dispose();
    _wireAnim.dispose();
    _shardAnim.dispose();
    _flash.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ helpers ---
  /// Shows an observation for 6 s (the source's message timeout).
  void _say(String key, {Map<String, String>? vars}) {
    var msg = _tx.s('messages.$key');
    vars?.forEach((k, v) => msg = msg.replaceAll('{$k}', v));
    setState(() => _message = msg);
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _message = null);
    });
  }

  /// Clears the sample back to a fresh block (source: `useEffect [material]`).
  void _resetSample() {
    _heatTimer?.cancel();
    _polished = false;
    _cut = false;
    _flattened = false;
    _flattenLevel = 0;
    _shattered = false;
    _wire = false;
    _heat = 0;
    _waxFell = false;
    _burnerAtA = false;
    _insulatorWarned = false;
    _inCircuit = false;
    _message = null;
    _wireAnim.reset();
    _shardAnim.reset();
  }

  void _selectMaterial(int i) {
    // Source: playSimSound('pop') on every material button.
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _matIndex = i;
      _resetSample();
    });
  }

  void _setStation(_Station s) {
    // Source: playSimSound('pop') on the mode bar; a station is a mode.
    _rt_playSfx(_rt_Sfx.scenario);
    _heatTimer?.cancel();
    setState(() {
      _station = s;
      // Each station remounts in the source, so its local sub-mode resets.
      _extruder = false;
      _electric = false;
      _burnerAtA = false;
      _inCircuit = false;
    });
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  /// Objectives are sticky once earned, so this only ever sets flags.
  void _checkMissions() {
    final was = List.of(_checklist);
    _checklist[0] |= _cut;
    _checklist[1] |= _flattened;
    _checklist[2] |= _wire;
    _checklist[3] |= _heat > 50;
    if (_checklist.toString() == was.toString()) return;
    // Source: playSuccessSound() when a mission ticks off. The source has no
    // completion text, so the last tick gets no popup (QA C10-3.1-04).
    _rt_playSfx(_rt_Sfx.success);
  }

  // ------------------------------------------------- station 1: lustre ---
  void _useKnife() {
    if (_cut) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    if (_mat.hard) {
      // Source: playSimSound('clang') -- the blade bounces off.
      _rt_playSfx(_rt_Sfx.wrong);
      _say('cut_hard');
      return;
    }
    // Source: playSimSound('cut').
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _cut = true);
    _say(_mat.isMetal ? 'cut_soft' : 'cut_fail');
    _checkMissions();
  }

  void _useSandpaper() {
    if (_polished) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    // Silent in the source; the lustre reveal gets a sound here.
    _rt_playSfx(_mat.isMetal ? _rt_Sfx.magic : _rt_Sfx.tap);
    setState(() => _polished = true);
    _say(_mat.isMetal ? 'lustre_metal' : 'lustre_nonmetal');
  }

  // -------------------------------------------------- station 2: forge ---
  void _strikeHammer() {
    _flash.forward(from: 0);
    if (_shattered || _flattened) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    if (!_mat.malleable) {
      // Source: playSimSound('thud') for a non-metal, then SHATTER.
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() => _shattered = true);
      _shardAnim.forward(from: 0);
      _say('shatter');
      return;
    }
    // Source: playSimSound('clang') on every blow to a metal.
    _rt_playSfx(_rt_Sfx.pop);
    // The source reads the pre-increment level: 3 strikes flatten the sample.
    final before = _flattenLevel;
    setState(() {
      _flattenLevel = before + 1;
      _flattened = _flattenLevel > 2;
    });
    if (before >= 2) {
      _say('flatten_metal');
      _checkMissions();
    } else {
      _say('flatten_progress', vars: {'n': '${3 - before}'});
    }
  }

  void _drawWire() {
    if (_wire || _shattered) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    if (_mat.id == 'gold') {
      // Source: playSimSound('cut'); the 4 s gold draw is the lab's big reveal.
      _rt_playSfx(_rt_Sfx.magic);
      setState(() => _wire = true);
      _wireAnim
        ..duration = const Duration(seconds: 4)
        ..forward(from: 0);
      _say('wire_gold');
    } else if (_mat.ductile) {
      // Source: playSimSound('cut').
      _rt_playSfx(_rt_Sfx.pop);
      setState(() => _wire = true);
      _wireAnim
        ..duration = const Duration(seconds: 2)
        ..forward(from: 0);
      _say('wire_metal');
    } else {
      // Source: playSimSound('thud').
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() => _shattered = true);
      _shardAnim.forward(from: 0);
      _say('wire_break');
      return;
    }
    _checkMissions();
  }

  // ------------------------------------------- station 3: conductivity ---
  /// One HEAT_INC (+2, capped at 100) -- per drag frame in the source.
  void _addHeat() {
    if (!_mat.conductor) {
      if (!_insulatorWarned) {
        _insulatorWarned = true;
        _rt_playSfx(_rt_Sfx.wrong);
        _say('cond_insulator');
      }
      return;
    }
    if (_heat >= 100) return;
    setState(() => _heat = (_heat + 2).clamp(0, 100));
    if (_heat > 50) _checkMissions();
    if (_heat >= 90 && !_waxFell) {
      // The wax gives way and the pin drops off End B.
      _rt_playSfx(_rt_Sfx.pop);
      setState(() => _waxFell = true);
      _say('cond_heat');
    }
  }

  /// Parks the burner under End A and keeps heating (button or drop).
  void _applyBurner() {
    if (_heatTimer?.isActive ?? false) return;
    _insulatorWarned = false;
    setState(() => _burnerAtA = true);
    if (!_mat.conductor) {
      _addHeat();
      return;
    }
    // Ignition.
    _rt_playSfx(_rt_Sfx.magic);
    _heatTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _addHeat();
      if (_heat >= 100) t.cancel();
    });
  }

  void _placeInCircuit() {
    if (_inCircuit) return;
    setState(() => _inCircuit = true);
    if (!_mat.conductor) {
      // Silent in the source: the bulb stays dark.
      _rt_playSfx(_rt_Sfx.wrong);
      _say('cond_fail');
    } else {
      // The bulb lights up.
      _rt_playSfx(_rt_Sfx.magic);
      _say(_mat.isMetal ? 'cond_metal' : 'cond_nonmetal_exc');
    }
  }

  void _removeFromCircuit() {
    setState(() => _inCircuit = false);
  }

  // ----------------------------------------------- station 4: sonority ---
  Future<void> _strikePlate() async {
    if (_striking) return;
    setState(() => _striking = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    if (_mat.sonorous) {
      // Source: playSimSound('metal-hit') -- a long ringing ding.
      _rt_playSfx(_rt_Sfx.correct);
      _ripple.forward(from: 0);
      _say('sonorous_metal');
    } else {
      // Source: playSimSound('thud').
      _rt_playSfx(_rt_Sfx.wrong);
      _say('sonorous_nonmetal');
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _striking = false);
  }

  void _restart() {
    // The shell already plays the restart sound.
    _heatTimer?.cancel();
    _ripple.reset();
    _flash.reset();
    _zoom.reset();
    if (_modeBar.hasClients) _modeBar.jumpTo(0);
    setState(() {
      _matIndex = 0;
      _station = _Station.appearance;
      _extruder = false;
      _electric = false;
      _showLabels = true;
      _striking = false;
      _resetSample();
      for (var i = 0; i < _checklist.length; i++) {
        _checklist[i] = false;
      }
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
          final next = _checklist.indexWhere((c) => !c);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.cyan500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF164E63)],
              headerSubtitleColor: Color(0xFFA5F3FC),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.hardware,
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
            hint: next == -1
                ? null
                : _rt_StepHint(
                    number: '${next + 1}',
                    text: (_steps[next] as Map)['do'] as String,
                    label: (_steps[next] as Map)['title'] as String,
                  ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.checklist,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: CustomPaint(
              painter: _DotGridPainter(_rt_Lab.border),
              child: _rt_ZoomableCanvas(
                controller: _zoom,
                child: _stationCanvas(),
              ),
            ),
            canvasOverlays: [
              if (_message != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: IgnorePointer(child: _observationBanner(_message!)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _observationBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: _rt_Tw.cyan500, width: 5)),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, size: 18, color: _rt_Tw.cyan500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.text,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- stations ---
  Widget _stationCanvas() {
    return Column(
      children: [
        // The source's bottom mode bar, as one scrollable row of tabs. The
        // side padding keeps it clear of the shell's menu / back buttons.
        SingleChildScrollView(
          controller: _modeBar,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(70, 12, 60, 4),
          child: Row(
            children: [
              for (final (s, key) in [
                (_Station.appearance, 'modes.appearance'),
                (_Station.forge, 'modes.forge'),
                (_Station.conductivity, 'modes.cond'),
                (_Station.sonority, 'modes.son'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _stationChip(s, _tx.s(key)),
                ),
            ],
          ),
        ),
        // Stations are laid out at their natural height and scroll when the
        // canvas is shorter than they are (phone landscape).
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              // Bottom padding keeps the controls clear of the observation
              // banner, which floats over the canvas.
              padding: const EdgeInsets.only(top: 8, bottom: 70),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, c.maxHeight - 78),
                ),
                child: Center(
                  child: switch (_station) {
                    _Station.appearance => _appearanceStation(),
                    _Station.forge => _forgeStation(),
                    _Station.conductivity => _conductivityStation(),
                    _Station.sonority => _sonorityStation(),
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stationChip(_Station s, String label) {
    final on = _station == s;
    return GestureDetector(
      onTap: () => _setStation(s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.cyan600 : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: on ? _rt_Tw.cyan500 : _rt_Lab.border,
            width: 2,
          ),
          boxShadow: on
              ? [
                  BoxShadow(
                    color: _rt_Tw.cyan500.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: on ? Colors.white : _rt_Lab.text,
          ),
        ),
      ),
    );
  }

  /// White `.comp-label` tag the source pins to every piece of apparatus.
  Widget _compLabel(String text) {
    if (!_showLabels) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _rt_Tw.slate400),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  /// The sample block itself, deformed according to what has been done to it.
  Widget _sample({double size = 130, double wireWidth = 300}) {
    if (_shattered) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 12 fragments fly out and fade (source: SHATTER burst).
            AnimatedBuilder(
              animation: _shardAnim,
              builder: (context, _) {
                if (!_shardAnim.isAnimating) return const SizedBox.shrink();
                final t = Curves.easeOut.transform(_shardAnim.value);
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    for (final (off, rot) in _shards)
                      Transform.translate(
                        offset: off * t,
                        child: Transform.rotate(
                          angle: rot * t,
                          child: Opacity(
                            opacity: 1 - t,
                            child: Container(
                              width: 16 * (1 - t) + 1,
                              height: 16 * (1 - t) + 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: _mat.colors),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Text(
              _tx.s('shattered'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: _rt_Tw.red500,
              ),
            ),
          ],
        ),
      );
    }
    if (_wire) {
      final gold = _mat.id == 'gold';
      return AnimatedBuilder(
        animation: Listenable.merge([_wireAnim, _shine]),
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_wireAnim.value);
          final w = 40 + (wireWidth - 40) * t;
          final h = 40 + (3 - 40) * t;
          // The label fades in 2 s into the draw, like the source.
          final ms =
              (_wireAnim.duration?.inMilliseconds ?? 2000) * _wireAnim.value;
          final showTag = !_wireAnim.isAnimating || ms >= 2000;
          return SizedBox(
            width: wireWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Container(
                      width: w,
                      height: h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1 - 2 * _shine.value, 0),
                          end: Alignment(3 - 2 * _shine.value, 0),
                          colors: gold
                              ? const [
                                  Color(0xFFFCD34D),
                                  Colors.white,
                                  Color(0xFFFCD34D),
                                ]
                              : _mat.colors,
                          tileMode: TileMode.mirror,
                        ),
                        borderRadius: BorderRadius.circular(h / 2),
                        boxShadow: gold
                            ? const [
                                BoxShadow(
                                  color: Color(0x99FBBF24),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: showTag ? 1 : 0,
                  child: _chipLabel(
                    gold ? _tx.s('goldWire') : _tx.s('drawnWire'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    if (_cut) {
      // Two halves pulled apart, with a bright fresh face if it is a metal.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_mat.isMetal)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _freshCutTag(),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: -0.09,
                child: _block(
                  width: size * 0.42,
                  height: size,
                  radius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Transform.rotate(
                angle: 0.09,
                child: Stack(
                  children: [
                    _block(
                      width: size * 0.42,
                      height: size,
                      radius: const BorderRadius.horizontal(
                        right: Radius.circular(10),
                      ),
                      shine: _mat.isMetal,
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: _mat.isMetal ? Colors.white : Colors.black26,
                          boxShadow: _mat.isMetal
                              ? const [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _chipLabel('${_tx.s('cutLabel')} $_matName'),
        ],
      );
    }

    final scaleX = _flattened ? 2.0 : 1 + _flattenLevel * 0.5;
    final scaleY = _flattened
        ? 0.12
        : (1 - _flattenLevel * 0.3).clamp(0.1, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          child: Center(
            child: TweenAnimationBuilder<Offset>(
              duration: const Duration(milliseconds: 250),
              tween: Tween(end: Offset(scaleX, scaleY.toDouble())),
              builder: (context, s, child) => Transform(
                // Squash towards the anvil face rather than the middle.
                alignment: Alignment.bottomCenter,
                transform: Matrix4.diagonal3Values(s.dx, s.dy, 1),
                child: child,
              ),
              child: _block(
                width: size,
                height: size,
                radius: BorderRadius.circular(_flattened ? 4 : size / 2),
                shine: _mat.isMetal && (_polished || _mat.id == 'gold'),
                // Unpolished metal carries a dull, dotted oxide layer.
                dull: _mat.isMetal && !_polished,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _chipLabel(
          _flattened
              ? _tx.s('flattened')
              : (_flattenLevel > 0 ? _tx.s('deforming') : _matName),
        ),
      ],
    );
  }

  Widget _freshCutTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF08A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEAB308)),
      ),
      child: Text(
        _tx.s('freshCut'),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF854D0E),
        ),
      ),
    );
  }

  Widget _block({
    required double width,
    required double height,
    BorderRadius? radius,
    bool shine = false,
    bool dull = false,
  }) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _mat.colors,
        ),
        borderRadius: radius,
        border: Border.all(color: _mat.border),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      // Heat tint while the conductivity rod warms up.
      foregroundDecoration: _heat > 0
          ? BoxDecoration(
              color: _rt_Tw.red500.withValues(alpha: (_heat / 100) * 0.55),
              borderRadius: radius,
            )
          : null,
    );
    if (!shine && !dull) return box;
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: Stack(
        children: [
          box,
          if (dull)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _DullDotsPainter()),
              ),
            ),
          // Lustre sweep across a polished metal face.
          if (shine)
            AnimatedBuilder(
              animation: _shine,
              builder: (context, _) => Positioned(
                left: width * (_shine.value * 3 - 1),
                top: 0,
                bottom: 0,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    width: width * 0.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x99FFFFFF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chipLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: _rt_Lab.text,
        ),
      ),
    );
  }

  /// Station 1: drag (or tap) the sandpaper and knife onto the sample.
  Widget _appearanceStation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (d) =>
              d.data == 'knife' || d.data == 'sandpaper',
          onAcceptWithDetails: (d) =>
              d.data == 'knife' ? _useKnife() : _useSandpaper(),
          builder: (context, cand, _) => Container(
            key: const ValueKey('sample-target'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cand.isNotEmpty ? _rt_Tw.cyan500 : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sample(size: 120),
                const SizedBox(height: 4),
                _compLabel(_tx.s('labels.sample')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 40,
          children: [
            _tool('sandpaper', const _SandpaperSwatch(), _useSandpaper),
            _tool(
              'knife',
              const CustomPaint(size: Size(46, 40), painter: _KnifePainter()),
              _useKnife,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _tx.s('tapOrDrag'),
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: _rt_Lab.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _tool(String id, Widget art, VoidCallback onTap) {
    final chip = Container(
      key: ValueKey('tool-$id'),
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.borderStrong, width: 2),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 42, child: Center(child: art)),
          const SizedBox(height: 4),
          Text(
            _tx.s('labels.$id'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.text,
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: Draggable<String>(
        hitTestBehavior: HitTestBehavior.opaque,
        data: id,
        onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
        feedback: Material(color: Colors.transparent, child: chip),
        childWhenDragging: Opacity(opacity: 0.3, child: chip),
        child: chip,
      ),
    );
  }

  /// Station 2: hammer on an anvil, or a die plate that draws wire.
  Widget _forgeStation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _subModeRow(
          leftLabel: _tx.s('modes.forge'),
          rightLabel: _tx.s('modes.duct'),
          rightSelected: _extruder,
          leftColor: _rt_Tw.orange600,
          rightColor: _rt_Tw.purple600,
          onLeft: () => setState(() => _extruder = false),
          onRight: () => setState(() => _extruder = true),
        ),
        const SizedBox(height: 10),
        if (_extruder) _extruderRig() else _anvilRig(),
      ],
    );
  }

  Widget _anvilRig() {
    final showBrief = _flattenLevel == 0 && !_shattered && !_flattened;
    final sample = _sample(size: 100);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBrief)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _brief(
              _tx.s('messages.flatten_progress').replaceAll('{n}', '3'),
              Icons.hardware,
              _rt_Tw.yellow500,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            DragTarget<String>(
              onWillAcceptWithDetails: (d) => d.data == 'hammer',
              onAcceptWithDetails: (_) => _strikeHammer(),
              builder: (context, cand, _) => Container(
                key: const ValueKey('anvil-target'),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cand.isNotEmpty
                        ? _rt_Tw.yellow400
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // Pulsing dashed target ring around the sample block.
                        Positioned(
                          top: -6,
                          child: AnimatedBuilder(
                            animation: _shine,
                            builder: (context, _) => Opacity(
                              opacity:
                                  0.35 +
                                  0.25 *
                                      math
                                          .sin(_shine.value * math.pi * 4)
                                          .abs(),
                              child: CustomPaint(
                                size: const Size(112, 112),
                                painter: _DashedCirclePainter(_rt_Tw.yellow400),
                              ),
                            ),
                          ),
                        ),
                        sample,
                        // Impact flash (source: hammerAnimate).
                        Positioned(
                          top: 0,
                          child: IgnorePointer(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: OverflowBox(
                                maxWidth: 200,
                                maxHeight: 200,
                                child: AnimatedBuilder(
                                  animation: _flash,
                                  builder: (context, _) {
                                    if (!_flash.isAnimating) {
                                      return const SizedBox.shrink();
                                    }
                                    final t = _flash.value;
                                    return Opacity(
                                      opacity: 1 - t,
                                      child: Container(
                                        width: 40 + 80 * t,
                                        height: 40 + 80 * t,
                                        decoration: const BoxDecoration(
                                          color: Color(0xAAFACC15),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // The anvil: a heavy block on a narrower base.
                    Container(
                      width: 190,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6B7280), width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 10),
                        ],
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFF374151),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _compLabel(_tx.s('labels.anvil')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 18),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Draggable<String>(
                  hitTestBehavior: HitTestBehavior.opaque,
                  key: const ValueKey('hammer'),
                  data: 'hammer',
                  onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
                  feedback: Transform.rotate(
                    angle: -0.5,
                    child: const _HammerArt(size: 84),
                  ),
                  childWhenDragging: const Opacity(
                    opacity: 0.3,
                    child: _HammerArt(size: 72),
                  ),
                  child: GestureDetector(
                    onTap: _strikeHammer,
                    child: const _HammerArt(
                      key: ValueKey('hammer-art'),
                      size: 72,
                    ),
                  ),
                ),
                _compLabel(_tx.s('labels.hammer')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 220,
          child: _rt_ActionButton(
            label: _tx.s('labels.hammer'),
            icon: Icons.hardware,
            color: _rt_Tw.orange600,
            expand: true,
            sound: null,
            onPressed: _strikeHammer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _tx.s('dragHammer'),
          style: TextStyle(
            fontSize: 10.5,
            fontStyle: FontStyle.italic,
            color: _rt_Lab.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _extruderRig() {
    final goldWire = _wire && _mat.id == 'gold';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9CA3AF), width: 4),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Die plate with the drawing hole.
              Tooltip(
                message: _tx.s('messages.die_tooltip'),
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  width: 70,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2937),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    border: Border(
                      right: BorderSide(color: Color(0xFF4B5563), width: 4),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4B5563),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x804B5563),
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          _tx.s('labels.die').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Drawing chamber.
              Container(
                width: 190,
                height: 100,
                color: Colors.white,
                alignment: Alignment.center,
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _sample(size: 64, wireWidth: 186),
                  ),
                ),
              ),
              // Pull handle.
              GestureDetector(
                key: const ValueKey('pull-handle'),
                onTap: () {
                  _rt_playSfx(_rt_Sfx.click);
                  _drawWire();
                },
                child: Container(
                  width: 46,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(8),
                    ),
                    border: Border(
                      left: BorderSide(color: Color(0xFF991B1B), width: 4),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 110,
          children: [
            _compLabel(_tx.s('labels.die')),
            _compLabel(_tx.s('labels.handle')),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 320,
          child: Text(
            _tx.s('messages.die_tooltip'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              color: _rt_Lab.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 220,
          child: _rt_ActionButton(
            label: _tx.s('labels.handle'),
            icon: Icons.arrow_forward,
            color: _rt_Tw.purple600,
            expand: true,
            onPressed: _drawWire,
          ),
        ),
        if (goldWire) ...[
          const SizedBox(height: 10),
          Container(
            key: const ValueKey('gold-fact'),
            width: 340,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(const Color(0xFFF3E8FF), _rt_Tw.purple500),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.purple500)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 20,
                  color: _rt_Lab.onTinted(_rt_Tw.purple500, _rt_Tw.purple600),
                ),
                const SizedBox(height: 6),
                Text(
                  _tx.s('messages.textbook_gold'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Bouncing instruction card (the source's `animate-bounce` popups).
  Widget _brief(String text, IconData icon, Color accent) {
    return AnimatedBuilder(
      animation: _shine,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * math.sin(_shine.value * math.pi * 5).abs()),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _rt_Lab.tinted(
            Color.lerp(accent, Colors.white, 0.85)!,
            accent,
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: accent, width: 4)),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subModeRow({
    required String leftLabel,
    required String rightLabel,
    required bool rightSelected,
    required Color leftColor,
    required Color rightColor,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) {
    Widget btn(
      String label,
      bool on,
      VoidCallback tap,
      Color color,
    ) => GestureDetector(
      onTap: () {
        _rt_playSfx(_rt_Sfx.toggle);
        tap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: on ? color : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? color : _rt_Lab.borderStrong,
            width: 2,
          ),
          boxShadow: on
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: on ? Colors.white : _rt_Lab.text,
          ),
        ),
      ),
    );
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        btn(leftLabel, !rightSelected, onLeft, leftColor),
        btn(rightLabel, rightSelected, onRight, rightColor),
      ],
    );
  }

  /// Station 3: heat travelling along a rod, or a bulb circuit.
  Widget _conductivityStation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _subModeRow(
          leftLabel: _tx.s('modes.heat'),
          rightLabel: _tx.s('modes.elec'),
          rightSelected: _electric,
          leftColor: _rt_Tw.red600,
          rightColor: _rt_Tw.yellow500,
          onLeft: () {
            _heatTimer?.cancel();
            setState(() {
              _electric = false;
              _inCircuit = false;
              _burnerAtA = false;
            });
          },
          onRight: () {
            _heatTimer?.cancel();
            setState(() {
              _electric = true;
              _inCircuit = false;
              _burnerAtA = false;
            });
          },
        ),
        const SizedBox(height: 10),
        _electric ? _circuit() : _heatRig(),
      ],
    );
  }

  Widget _heatRig() {
    const w = 380.0, h = 190.0;
    const rodLeft = 40.0, rodTop = 52.0, rodW = 250.0, rodH = 20.0;
    final heating = _heatTimer?.isActive ?? false;
    final burner = _BurnerArt(flicker: _shine, lit: heating || _burnerAtA);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _brief(
          _tx.s('messages.heat_popup'),
          Icons.local_fire_department,
          _rt_Tw.blue600,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Retort stand: base, upright, arm and clamp holding End B.
              Positioned(
                right: 4,
                bottom: 0,
                child: Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                top: 20,
                bottom: 8,
                child: Container(
                  width: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4B5563),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 36,
                top: rodTop + 4,
                child: Container(
                  width: 60,
                  height: 10,
                  color: const Color(0xFF4B5563),
                ),
              ),
              Positioned(
                left: rodLeft + rodW - 6,
                top: rodTop - 10,
                child: Container(
                  width: 16,
                  height: rodH + 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 24,
                child: _compLabel(_tx.s('labels.stand')),
              ),
              // The rod: a heat front sweeps from End A towards End B.
              Positioned(
                left: rodLeft,
                top: rodTop,
                child: Container(
                  width: rodW,
                  height: rodH,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _mat.colors,
                    ),
                    border: Border.all(color: _mat.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _mat.conductor
                          ? (_heat / 100).clamp(0.0, 1.0)
                          : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xCCDC2626), Color(0x00DC2626)],
                            stops: [0.6, 1],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: rodLeft - 20,
                top: rodTop - 26,
                child: _compLabel('${_tx.s('labels.endA')}: $_matName'),
              ),
              Positioned(
                left: rodLeft + rodW - 60,
                top: rodTop - 26,
                child: _compLabel(_tx.s('labels.endB')),
              ),
              // Wax bead holding a pin under End B; both drop once heat arrives.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                left: rodLeft + rodW - 36,
                top: _waxFell ? h - 30 : rodTop + rodH,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  turns: _waxFell ? 0.125 : 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _waxFell ? 0 : 1,
                    child: Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE047),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFEAB308)),
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 30,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_waxFell) ...[
                Positioned(
                  left: rodLeft + rodW - 8,
                  top: rodTop + rodH + 2,
                  child: _compLabel(_tx.s('labels.wax')),
                ),
                Positioned(
                  left: rodLeft + rodW - 8,
                  top: rodTop + rodH + 30,
                  child: _compLabel(_tx.s('labels.pin')),
                ),
              ] else
                Positioned(
                  // Right of the parked burner, clear of the stand.
                  left: rodLeft + 88,
                  top: rodTop + rodH + 44,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      _tx.s('waxMelted'),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ),
              // Heating zone under End A: hovering the burner here adds heat.
              Positioned(
                left: 0,
                top: rodTop - 8,
                width: 130,
                height: h - rodTop + 8,
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (d) => d.data == 'burner',
                  onMove: (d) {
                    if (d.data == 'burner') _addHeat();
                  },
                  onAcceptWithDetails: (_) => _applyBurner(),
                  builder: (context, cand, _) => Container(
                    key: const ValueKey('burner-zone'),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: cand.isNotEmpty
                            ? _rt_Tw.orange400
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // The burner itself (draggable), parked under End A while heating.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                left: _burnerAtA ? rodLeft + 10 : 170,
                top: _burnerAtA ? rodTop + rodH + 2 : h - 104,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Draggable<String>(
                      hitTestBehavior: HitTestBehavior.opaque,
                      key: const ValueKey('burner'),
                      data: 'burner',
                      onDragStarted: () {
                        _insulatorWarned = false;
                        _rt_playSfx(_rt_Sfx.tap);
                      },
                      feedback: _BurnerArt(flicker: _shine, lit: true),
                      childWhenDragging: Opacity(opacity: 0.3, child: burner),
                      child: burner,
                    ),
                    _compLabel(_tx.s('labels.burner')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 250,
          child: _rt_ActionButton(
            label: _tx.s('applyBurner'),
            icon: Icons.local_fire_department,
            color: _rt_Tw.red600,
            expand: true,
            onPressed: _applyBurner,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_tx.s('modes.heat')}: ${_heat.round()}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _rt_Lab.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _circuit() {
    final glowing = _inCircuit && _mat.conductor;
    final sampleBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 130,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _mat.colors),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _rt_Tw.slate400),
          ),
          child: Text(
            '$_matName (${_tx.s('labels.sample')})',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The circuit board: battery, switch, bulb and a gap closed by clips.
        Container(
          width: 380,
          height: 196,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD1D5DB), width: 4),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 14)],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Wire loop.
              Positioned.fill(
                top: 26,
                bottom: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: Colors.black, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Bulb (top centre).
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: glowing
                                ? _rt_Tw.yellow400
                                : const Color(0xFFD1D5DB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: glowing
                                ? const [
                                    BoxShadow(
                                      color: Color(0xDDFFD700),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 8,
                          color: const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    _compLabel(_tx.s('labels.bulb')),
                  ],
                ),
              ),
              // Battery (left).
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(width: 5, height: 26, color: Colors.black),
                          const SizedBox(width: 3),
                          Container(
                            width: 5,
                            height: 18,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 3),
                          Container(width: 5, height: 26, color: Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    _compLabel(_tx.s('labels.battery')),
                  ],
                ),
              ),
              // Switch (right).
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                        width: 30,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _compLabel(_tx.s('labels.switch')),
                  ],
                ),
              ),
              // The gap the sample is clipped into.
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _compLabel(_tx.s('labels.clips')),
                    const SizedBox(height: 2),
                    DragTarget<String>(
                      onWillAcceptWithDetails: (d) => d.data == 'sample',
                      onAcceptWithDetails: (_) => _placeInCircuit(),
                      builder: (context, cand, _) => CustomPaint(
                        key: const ValueKey('circuit-gap'),
                        painter: _DashedRectPainter(
                          cand.isNotEmpty ? _rt_Tw.blue600 : _rt_Tw.blue400,
                        ),
                        child: Container(
                          width: 200,
                          height: 58,
                          alignment: Alignment.center,
                          color: cand.isNotEmpty
                              ? const Color(0xFFDBEAFE)
                              : Colors.white,
                          child: _inCircuit
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _mat.colors,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: _mat.border),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '$_matName (${_tx.s('labels.sample')})',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _tx.s('dropHere'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _rt_Tw.blue500,
                                  ),
                                ),
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
        Wrap(
          spacing: 18,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            if (!_inCircuit)
              Draggable<String>(
                hitTestBehavior: HitTestBehavior.opaque,
                key: const ValueKey('sample-bar'),
                data: 'sample',
                onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
                feedback: Material(color: Colors.transparent, child: sampleBar),
                childWhenDragging: Opacity(opacity: 0.3, child: sampleBar),
                child: sampleBar,
              ),
            SizedBox(
              width: 220,
              child: _inCircuit
                  ? _rt_ActionButton(
                      label: _tx.s('removeSample'),
                      icon: Icons.undo,
                      color: _rt_Tw.red600,
                      expand: true,
                      onPressed: _removeFromCircuit,
                    )
                  : _rt_ActionButton(
                      label: _tx.s('placeSample'),
                      icon: Icons.input,
                      expand: true,
                      onPressed: _placeInCircuit,
                    ),
            ),
          ],
        ),
        if (!_inCircuit) ...[
          const SizedBox(height: 4),
          Text(
            _tx.s('dragSample'),
            style: TextStyle(
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              color: _rt_Lab.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  /// Station 4: strike the hanging plate and watch for ringing.
  Widget _sonorityStation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 210,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Suspension string.
              Positioned(
                top: 0,
                child: Container(width: 3, height: 44, color: _rt_Tw.slate500),
              ),
              Positioned(
                top: 40,
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Expanding rings when the plate rings.
                      AnimatedBuilder(
                        animation: _ripple,
                        builder: (context, _) {
                          if (_ripple.value == 0 || _ripple.isCompleted) {
                            return const SizedBox.shrink();
                          }
                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              for (final delay in [0.0, 0.25])
                                Builder(
                                  builder: (context) {
                                    final t =
                                        ((_ripple.value - delay) / (1 - delay))
                                            .clamp(0.0, 1.0);
                                    if (t == 0) return const SizedBox.shrink();
                                    return Container(
                                      width: 140 + t * 210,
                                      height: 140 + t * 210,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _rt_Tw.blue500.withValues(
                                            alpha: (1 - t) * 0.8,
                                          ),
                                          width: 4 * (1 - t) + 0.1,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _mat.colors,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          '$_matName\n${_tx.s('labels.plate')}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -56,
                        top: 60,
                        child: _compLabel(_tx.s('labels.plate')),
                      ),
                    ],
                  ),
                ),
              ),
              // The striker swings in on each hit.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                right: _striking ? 58 : 6,
                top: 56,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: _striking ? -0.12 : 0,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 90,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF713F12),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: const Color(0xFF422006),
                            width: 2,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -14),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB91C1C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -8,
                top: 160,
                child: _compLabel(_tx.s('labels.striker')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 200,
          child: _rt_ActionButton(
            label: _tx.s('labels.striker'),
            icon: Icons.campaign,
            color: _rt_Tw.green600,
            expand: true,
            onPressed: _strikePlate,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionBrief'),
          desc: _tx.s('explore.objective'),
          accent: _rt_Tw.cyan500,
          icon: Icons.rocket_launch,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('ui.select'), icon: Icons.category),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < _materials.length; i++) _materialChip(i),
                ],
              ),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('ui.properties'), icon: Icons.fact_check),
              _propertyCard(),
              const SizedBox(height: 14),
              _rt_SectionLabel(_tx.s('tabs.explore'), icon: Icons.checklist),
              for (var i = 0; i < _steps.length; i++) _taskRow(i),
            ],
          ),
        ),
      ],
    );
  }

  Widget _materialChip(int i) {
    final m = _materials[i];
    final on = _matIndex == i;
    return GestureDetector(
      key: ValueKey('mat-${m.id}'),
      onTap: () => _selectMaterial(i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.cyan600 : _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: on ? _rt_Tw.cyan500 : _rt_Lab.border,
            width: on ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: m.colors),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              _tx.s('materials.${m.id}'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: on ? Colors.white : _rt_Lab.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _propertyCard() {
    Widget badge(String label, bool on) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: on
            ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
            : _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: on ? _rt_Tw.green500 : _rt_Lab.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            on ? Icons.check : Icons.close,
            size: 12,
            color: on ? _rt_Tw.green500 : _rt_Lab.textFaint,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: on
                  ? _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)
                  : _rt_Lab.textMuted,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 2,
            children: [
              Text(
                '${_tx.s('ui.type')}: ${_tx.s('types.${_mat.type}')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                ),
              ),
              Text(
                '${_tx.s('ui.density')}: ${_mat.density} g/cm³',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              badge(_tx.s('ui.hard'), _mat.hard),
              badge(_tx.s('ui.malleable'), _mat.malleable),
              badge(_tx.s('ui.ductile'), _mat.ductile),
              badge(_tx.s('ui.conductor'), _mat.conductor),
              badge(_tx.s('ui.sonorous'), _mat.sonorous),
            ],
          ),
          if (_exceptionIds.contains(_mat.id)) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _rt_Lab.tintedBorder(_rt_Tw.amber500),
                ),
              ),
              child: Text(
                '${_tx.s('ui.exception')}: ${_tx.s('exceptions.${_mat.id}')}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.onTinted(_rt_Tw.amber400, _rt_Tw.amber700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _taskRow(int i) {
    final step = _steps[i] as Map;
    final done = _checklist[i];
    final active = i == _checklist.indexWhere((c) => !c);
    Widget line(
      String tag,
      Color tagColor,
      String text, {
      bool italic = false,
    }) => Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                color: _rt_Lab.textMuted,
                height: 1.25,
                fontStyle: italic ? FontStyle.italic : null,
              ),
            ),
          ),
        ],
      ),
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: done
            ? _rt_Lab.tinted(_rt_Tw.green50, _rt_Tw.green500)
            : (active
                  ? _rt_Lab.tinted(const Color(0xFFECFEFF), _rt_Tw.cyan500)
                  : _rt_Lab.surface),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done
              ? _rt_Lab.tintedBorder(_rt_Tw.green500)
              : (active ? _rt_Tw.cyan500 : _rt_Lab.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step['title'] as String,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: done
                        ? _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)
                        : _rt_Lab.text,
                  ),
                ),
              ),
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: done
                    ? _rt_Tw.green500
                    : (active ? _rt_Tw.cyan500 : _rt_Lab.textFaint),
              ),
            ],
          ),
          line(_tx.s('ui.action'), _rt_Tw.cyan600, step['do'] as String),
          line(
            _tx.s('ui.observation'),
            _rt_Tw.amber500,
            step['focus'] as String,
            italic: true,
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- widgets ---

/// Round toggle for the canvas toolbar (the source's "Toggle Labels" tool).
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
            color: active ? _rt_Tw.cyan600 : _rt_Lab.surface,
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

/// Tan square of grit (the source's `.sandpaper-texture`).
class _SandpaperSwatch extends StatelessWidget {
  const _SandpaperSwatch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFD2B48C),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFFA16207)),
      ),
      child: const CustomPaint(painter: _GritPainter()),
    );
  }
}

class _GritPainter extends CustomPainter {
  const _GritPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(3);
    final p = Paint()..color = const Color(0x55000000);
    for (var i = 0; i < 90; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        0.7,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KnifePainter extends CustomPainter {
  const _KnifePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final blade = Path()
      ..moveTo(w * 0.02, h * 0.5)
      ..quadraticBezierTo(w * 0.25, h * 0.28, w * 0.6, h * 0.34)
      ..lineTo(w * 0.6, h * 0.6)
      ..lineTo(w * 0.1, h * 0.58)
      ..close();
    canvas.drawPath(
      blade,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F5F9), Color(0xFF94A3B8)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      blade,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF64748B),
    );
    final handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.6, h * 0.34, w * 0.38, h * 0.26),
      const Radius.circular(4),
    );
    canvas.drawRRect(handle, Paint()..color = const Color(0xFF3F2A1D));
    final rivet = Paint()..color = const Color(0xFFD1D5DB);
    canvas.drawCircle(Offset(w * 0.72, h * 0.47), 1.6, rivet);
    canvas.drawCircle(Offset(w * 0.88, h * 0.47), 1.6, rivet);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A claw hammer, head up, tilted like the source's rotated emoji.
class _HammerArt extends StatelessWidget {
  const _HammerArt({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _HammerPainter());
}

class _HammerPainter extends CustomPainter {
  const _HammerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(-math.pi / 5);
    canvas.translate(-w / 2, -h / 2);
    // Wooden handle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.26, w * 0.12, h * 0.7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF92400E),
    );
    // Steel head.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.08, w * 0.64, h * 0.2),
        const Radius.circular(3),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5E7EB), Color(0xFF6B7280)],
        ).createShader(Rect.fromLTWH(0, h * 0.08, w, h * 0.2)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bunsen burner with a flickering blue flame.
class _BurnerArt extends StatelessWidget {
  const _BurnerArt({required this.flicker, required this.lit});

  final Animation<double> flicker;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 86,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: flicker,
            builder: (context, _) {
              final s = 1 + 0.2 * math.sin(flicker.value * math.pi * 50).abs();
              return Transform.scale(
                scaleY: s,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 22,
                  height: lit ? 40 : 30,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(99),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF60A5FA),
                        Color(0x0060A5FA),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 14,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF9CA3AF),
              border: Border.symmetric(
                vertical: BorderSide(color: Color(0xFF6B7280)),
              ),
            ),
          ),
          Container(
            width: 52,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint dot grid behind the stations (`.sim-stage` background).
class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var y = 10.0; y < size.height; y += 20) {
      for (var x = 10.0; x < size.width; x += 20) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => old.color != color;
}

/// Dull oxide speckle on an unpolished metal sample.
class _DullDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x66000000);
    for (var y = 4.0; y < size.height; y += 8) {
      for (var x = 4.0; x < size.width; x += 8) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final rect = Offset.zero & size;
    const n = 24;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(
        rect.deflate(2),
        i * 2 * math.pi / n,
        math.pi / n,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.color != color;
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2;
    void dashes(Offset a, Offset b) {
      final len = (b - a).distance;
      final dir = (b - a) / len;
      for (var d = 0.0; d < len; d += 10) {
        canvas.drawLine(a + dir * d, a + dir * math.min(d + 5, len), p);
      }
    }

    final w = size.width, h = size.height;
    dashes(Offset.zero, Offset(w, 0));
    dashes(Offset(w, 0), Offset(w, h));
    dashes(Offset(w, h), Offset(0, h));
    dashes(Offset(0, h), Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) => old.color != color;
}
