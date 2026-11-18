// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 9.5: The Speed Trap
// Converted from Cl10S-Ch9-A5-TheSpeedTrap.html (three.js -> mini3d).
//
// Four guided phases: race photons through Air, Water and Glass tracks,
// build n = c/v for glass from the speeds c and v and type the result,
// calculate the speed of light in diamond (v = c/n) and race it against the
// other media, then sort the materials from optically rare to optically
// dense. A did-you-know popup (kerosene vs water) closes the lab.

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
  static const red500 = Color(0xFFEF4444);
  static const green500 = Color(0xFF22C55E);
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
    this.buttonIcon = Icons.fingerprint,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final IconData buttonIcon;
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
    this.onStart,
    this.canvasOverlays = const [],
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.toolbarExtras = const [],
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
  final VoidCallback? onStart;

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    // The user may leave the page while the curtain is still animating.
    if (!mounted) return;
    setState(() => _introVisible = false);
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
  _rt_Geometry3D(this.vertices, this.faces);

  final List<_rt_V3> vertices;
  final List<List<int>> faces;

  /// Optional material index per face (for per-face colours, e.g. dice/boxes).
  final List<int>? faceGroups = null;

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
    return _rt_Geometry3D(v, [
      [5, 1, 2, 6], // +x
      [0, 4, 7, 3], // -x
      [7, 6, 2, 3], // +y
      [0, 1, 5, 4], // -y
      [4, 5, 6, 7], // +z
      [1, 0, 3, 2], // -z
    ]);
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

  /// THREE.OctahedronGeometry(radius).
  factory _rt_Geometry3D.octahedron(double r) {
    final v = [
      _rt_V3(r, 0, 0),
      _rt_V3(-r, 0, 0),
      _rt_V3(0, r, 0),
      _rt_V3(0, -r, 0),
      _rt_V3(0, 0, r),
      _rt_V3(0, 0, -r),
    ];
    return _rt_Geometry3D(v, [
      [0, 2, 4], [0, 4, 3], [0, 3, 5], [0, 5, 2], //
      [1, 2, 5], [1, 5, 3], [1, 3, 4], [1, 4, 2],
    ]);
  }
}

/// Surface appearance (covers MeshBasic / Lambert / Phong / Standard /
/// Physical materials closely enough for the activities).
class _rt_Material3D {
  _rt_Material3D({
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 1.0,
    this.shininess = 0.0,
  });

  /// Base colour (THREE `color`).
  Color color;

  /// 0..1 (THREE `opacity` with `transparent: true`).
  double opacity;

  /// MeshBasicMaterial: ignores lights.
  bool unlit = false;

  /// THREE.DoubleSide.
  bool doubleSided = false;

  /// Glow colour added regardless of lighting.
  Color? emissive;
  double emissiveIntensity = 1.0;

  /// 0..1 highlight strength (Phong/Standard shine; also sphere gloss).
  double shininess;

  /// 0..1 (MeshStandardMaterial `metalness`): darkens diffuse lighting.
  double metalness = 0.0;

  /// Draws only polygon outlines.
  bool wireframe = false;

  /// Optional outline drawn around every face (EdgesGeometry look).
  Color? edgeColor;
  double edgeWidth = 1.0;

  /// Per-face-group colours, e.g. box sides (THREE material arrays).
  List<Color>? faceColors;

  /// THREE `material.visible`.
  bool visible = true;
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

  void removeFromParent() => parent?.remove(this);

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
  _rt_Mesh3D(this.geometry, this.material);

  _rt_Geometry3D geometry;
  _rt_Material3D material;
}

/// Smooth sphere drawn as a shaded disc (fast and perfectly round).
class _rt_Sphere3D extends _rt_Node3D {
  _rt_Sphere3D(this.radius, this.material);

  double radius;
  _rt_Material3D material;
}

/// Polyline in 3D (THREE.Line / LineSegments). Width is in screen pixels.
class _rt_Line3D extends _rt_Node3D {
  _rt_Line3D(this.points);

  List<_rt_V3> points;
  Color color = const Color(0xFFFFFFFF);
  double width = 2;
  double opacity = 1;
  bool dashed = false;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments = false;
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
  _rt_Label3D(this.text, {super.position, this.background});

  String text;

  /// Text height in world units (scales with distance like a sprite).
  double worldHeight = 1.0;

  /// If set, fixed on-screen font size instead of [worldHeight].
  double? pixelHeight;
  Color color = const Color(0xFFFFFFFF);
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
  _rt_Light3D.directional(
    this.position, {
    this.color = const Color(0xFFFFFFFF),
    this.intensity = 0.8,
  }) : kind = _rt_LightKind.directional;
  _rt_Light3D.hemisphere({this.intensity = 0.6})
    : kind = _rt_LightKind.hemisphere,
      position = _rt_V3(0, 1, 0);

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
    this.cameraControls = true,
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
    'headerTitle': 'The Speed Trap',
    'headerSubtitle': 'Class 10: Light – Reflection and Refraction',
    'intro': {
      'title': 'The Speed Trap',
      'subtitle': 'Class 10 • Light – Reflection and Refraction',
      'footnote': 'Optical Density & The Speed of Light',
    },
    'tabs': {'explore': 'Exploration'},
    'mission_obj': 'Mission Objective',
    'objective':
        'To race photons through different media to visualize optical density, calculate the exact refractive index of glass and diamond, and successfully sort materials by their optical density.',
    'board_desc':
        "Light travels at 3 × 10⁸ m/s in a vacuum. Let's explore how it slows down in different materials due to their optical density.",
    'board_btn': 'Start Experiment',
    'concept_exp': 'Exploration Steps',
    'exploration': 'Phase',
    'action': 'Action',
    'observation': 'Observation',
    'curr_obj': 'Current Objective',
    'start_race': 'Launch Photons',
    'finish': 'Finish',
    'calc_glass': 'Glass Refractive Index',
    'drop_c': "Drop 'c'",
    'drop_v': "Drop 'v'",
    'result': 'Result',
    'btn_check': 'Check',
    'calc_diamond': 'Diamond Challenge (n = 2.42)',
    'submit': 'Verify & Launch',
    'submit_short': 'Verify',
    'sorting': 'Sorting Phase',
    'fastest': 'Optically Rare',
    'slowest': 'Optically Dense',
    'mat_air': 'Air',
    'mat_water': 'Water',
    'mat_glass': 'Glass',
    'mat_diamond': 'Diamond',
    'teacher': 'System AI',
    'panda_step1':
        'Telemetry acquired: Light slows down significantly when entering a denser medium. It travels fastest in a vacuum.',
    'panda_step2':
        'Calculation Verified. Glass has a Refractive Index of 1.5. Light travels 1.5x slower in glass compared to a vacuum.',
    'panda_step3':
        'Calculation Verified. Diamond is highly optically dense, drastically reducing photon velocity.',
    'did_you_know': 'The Anomaly',
    'dyk_text':
        'Optical density is NOT the same as mass density. Kerosene floats on water because its mass density is lower, but it actually has a HIGHER refractive index (n = 1.44 vs n = 1.33). It is optically denser than water!',
    'kerosene': 'Kerosene',
    'water': 'Water',
    'continue': 'Acknowledge & Continue',
    'success': 'Mission Success',
    'observation_title': 'Key Takeaway',
    'summary_head': 'Experiment Complete!',
    'summary':
        'You successfully visualized optical density, calculated refractive index using the formula n = c/v, and sorted materials accurately based on their optical properties!',
    'btn_restart': 'Reboot Simulation',
    'err_slot':
        'Wrong slot! In n = c/v the speed in vacuum (c) goes on top and the speed in glass (v) goes below.',
    'err_empty': 'Type your answer first.',
    'err_n': 'Not quite. Divide c by v: (3 × 10⁸) ÷ (2 × 10⁸).',
    'err_v':
        'Not quite. Use v = c/n = (3 × 10⁸) ÷ 2.42 and give the answer in × 10⁸ m/s.',
    'err_sort':
        '{m} does not go here. Arrange the blocks by refractive index, lowest first.',
    'tool_labels': 'Show / hide labels',
    'tool_lock': 'Lock / unlock camera',
    'hud': [
      "Observe the three tracks (Air, Water, Glass). Click 'Launch Photons' to start the race.",
      'Drag the speed of light in vacuum (c) and in glass (v) to the correct slots, then enter the refractive index and tap Check.',
      'Diamond is highly dense. Calculate the speed of light in diamond (v) using v = c/n and verify to launch.',
      'Compare the refractive indices. Drag the blocks to sort them from Optically Rare to Optically Dense.',
    ],
    'steps': [
      {
        'concept': 'Visualizing Optical Density',
        'action':
            "Observe the three optical media tracks (Air, Water, and Glass). Click the 'Launch Photons' button to release the photons simultaneously.",
        'observation':
            'The photon in Air (n = 1.0) reaches the finish line first. The photon in Glass (n = 1.5) is the slowest. This visually proves that light travels slower in an optically denser medium.',
      },
      {
        'concept': 'Calculating Refractive Index',
        'action':
            'Use the formula n = c/v to calculate the refractive index of glass. Drag the speed of light in vacuum (c = 3 × 10⁸) and speed in glass (v = 2 × 10⁸) to the designated target zones, then enter the result.',
        'observation':
            '(3 × 10⁸) / (2 × 10⁸) = 1.5. The calculated refractive index is 1.5, meaning light is exactly 1.5 times slower in glass than in a vacuum.',
      },
      {
        'concept': "Diamond's Extreme Density",
        'action':
            'Diamond is highly dense with n = 2.42. Calculate its speed using the formula v = c/n (3 × 10⁸ / 2.42). Enter the resulting value and verify the calculation.',
        'observation':
            '(3 × 10⁸) / 2.42 ≈ 1.24 × 10⁸ m/s. Notice how extremely slow the photon moves in the diamond track compared to the other media due to its extreme optical density.',
      },
      {
        'concept': 'Sorting by Optical Density',
        'action':
            'Arrange the materials from Optically Rare (fastest light speed) to Optically Dense (slowest light speed) by dragging the structural blocks into the correct slots.',
        'observation':
            'Air (1.0) → Water (1.33) → Glass (1.5) → Diamond (2.42). A higher refractive index always implies a higher optical density, resulting in slower light speed.',
      },
    ],
  },
  'hi': {
    'headerTitle': 'द स्पीड ट्रैप',
    'headerSubtitle': 'कक्षा 10: प्रकाश – परावर्तन तथा अपवर्तन',
    'intro': {
      'title': 'द स्पीड ट्रैप',
      'subtitle': 'कक्षा 10 • प्रकाश – परावर्तन तथा अपवर्तन',
      'footnote': 'प्रकाशीय घनत्व और प्रकाश की चाल',
    },
    'tabs': {'explore': 'अन्वेषण'},
    'mission_obj': 'मिशन का उद्देश्य',
    'objective':
        'प्रकाशीय घनत्व की कल्पना करने के लिए विभिन्न माध्यमों के माध्यम से फोटॉनों की दौड़ लगाना, कांच और हीरे के सटीक अपवर्तनांक की गणना करना, और सामग्री को उनके प्रकाशीय घनत्व द्वारा सफलतापूर्वक क्रमबद्ध करना।',
    'board_desc':
        'प्रकाश निर्वात में 3 × 10⁸ m/s की गति से यात्रा करता है। आइए जानें कि यह अपने प्रकाशीय घनत्व के कारण विभिन्न सामग्रियों में कैसे धीमा हो जाता है।',
    'board_btn': 'प्रयोग शुरू करें',
    'concept_exp': 'अन्वेषण चरण',
    'exploration': 'चरण',
    'action': 'कार्रवाई',
    'observation': 'अवलोकन',
    'curr_obj': 'वर्तमान कार्य',
    'start_race': 'फोटॉन लॉन्च करें',
    'finish': 'फिनिश',
    'calc_glass': 'कांच का अपवर्तनांक',
    'drop_c': "'c' यहाँ छोड़ें",
    'drop_v': "'v' यहाँ छोड़ें",
    'result': 'परिणाम',
    'btn_check': 'जाँचें',
    'calc_diamond': 'डायमंड चैलेंज (n = 2.42)',
    'submit': 'सत्यापित करें और लॉन्च करें',
    'submit_short': 'सत्यापित करें',
    'sorting': 'छँटाई चरण',
    'fastest': 'प्रकाशीय विरल',
    'slowest': 'प्रकाशीय सघन',
    'mat_air': 'हवा',
    'mat_water': 'पानी',
    'mat_glass': 'कांच',
    'mat_diamond': 'हीरा',
    'teacher': 'सिस्टम AI',
    'panda_step1':
        'टेलीमेट्री प्राप्त: सघन माध्यम में प्रवेश करने पर प्रकाश धीमा हो जाता है। यह निर्वात में सबसे तेज गति से यात्रा करता है।',
    'panda_step2':
        'गणना सत्यापित। कांच का अपवर्तनांक 1.5 है। कांच में प्रकाश निर्वात की तुलना में 1.5 गुना धीमा चलता है।',
    'panda_step3':
        'गणना सत्यापित। हीरा प्रकाशीय रूप से बहुत सघन होता है, जो फोटॉन के वेग को काफी कम कर देता है।',
    'did_you_know': 'क्या आप जानते हैं?',
    'dyk_text':
        'प्रकाशीय घनत्व और द्रव्यमान घनत्व समान नहीं हैं। मिट्टी का तेल पानी पर तैरता है (कम द्रव्यमान घनत्व), लेकिन इसका अपवर्तनांक अधिक (n = 1.44) होता है, जबकि पानी का n = 1.33 है! यह पानी से प्रकाशीय रूप से सघन है।',
    'kerosene': 'मिट्टी का तेल',
    'water': 'पानी',
    'continue': 'स्वीकार करें और जारी रखें',
    'success': 'मिशन सफल',
    'observation_title': 'मुख्य निष्कर्ष',
    'summary_head': 'प्रयोग पूरा हुआ!',
    'summary':
        'आपने सफलतापूर्वक प्रकाशीय घनत्व की कल्पना की, n = c/v सूत्र का उपयोग करके अपवर्तनांक की गणना की, और सामग्रियों को उनके प्रकाशीय गुणों के आधार पर सटीक रूप से क्रमबद्ध किया!',
    'btn_restart': 'सिमुलेशन रिबूट करें',
    'err_slot':
        'गलत स्लॉट! n = c/v में निर्वात में चाल (c) ऊपर और कांच में चाल (v) नीचे आती है।',
    'err_empty': 'पहले अपना उत्तर लिखें।',
    'err_n': 'सही नहीं। c को v से भाग दें: (3 × 10⁸) ÷ (2 × 10⁸)।',
    'err_v':
        'सही नहीं। v = c/n = (3 × 10⁸) ÷ 2.42 का उपयोग करें और उत्तर × 10⁸ m/s में दें।',
    'err_sort':
        '{m} यहाँ नहीं आएगा। ब्लॉकों को अपवर्तनांक के क्रम में लगाएँ, सबसे कम पहले।',
    'tool_labels': 'लेबल दिखाएँ / छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक करें',
    'hud': [
      "तीनों ट्रैकों (हवा, पानी, कांच) को देखें। दौड़ शुरू करने के लिए 'फोटॉन लॉन्च करें' पर क्लिक करें।",
      "अपवर्तनांक की गणना करने के लिए 'c' और 'v' के मानों को सही स्लॉट में खींचें, फिर परिणाम लिखकर 'जाँचें' दबाएँ।",
      'हीरा बहुत सघन है। v = c/n का उपयोग करके हीरे में प्रकाश की गति निकालें और सत्यापित करें।',
      'अपवर्तनांक की तुलना करें। सामग्री ब्लॉक को प्रकाशीय विरल से प्रकाशीय सघन तक व्यवस्थित करें।',
    ],
    'steps': [
      {
        'concept': 'प्रकाशीय घनत्व की कल्पना',
        'action':
            "तीनों प्रकाशीय माध्यम ट्रैकों (हवा, पानी, और कांच) को ध्यान से देखें। एक साथ फोटॉनों को लॉन्च करने के लिए 'फोटॉन लॉन्च करें' बटन पर क्लिक करें।",
        'observation':
            'हवा (n = 1.0) में फोटॉन फिनिश लाइन पर सबसे पहले पहुँचता है। कांच (n = 1.5) में फोटॉन सबसे धीमा है। यह स्पष्ट रूप से साबित करता है कि सघन माध्यम में प्रकाश धीमा चलता है।',
      },
      {
        'concept': 'अपवर्तनांक की गणना',
        'action':
            'कांच के अपवर्तनांक की गणना करने के लिए n = c/v सूत्र का उपयोग करें। निर्वात में प्रकाश की गति (c) और कांच में गति (v) को सही स्लॉट में खींचें और छोड़ें, फिर परिणाम लिखें।',
        'observation':
            '(3 × 10⁸) / (2 × 10⁸) = 1.5। गणना किया गया अपवर्तनांक 1.5 है, जिसका अर्थ है कि कांच में प्रकाश निर्वात की तुलना में ठीक 1.5 गुना धीमा है।',
      },
      {
        'concept': 'हीरे का चरम घनत्व',
        'action':
            'हीरा n = 2.42 के साथ अत्यधिक सघन है। सूत्र v = c/n का उपयोग करके इसकी गति की गणना करें। परिणामी मान दर्ज करें और सत्यापन के लिए सबमिट करें।',
        'observation':
            '(3 × 10⁸) / 2.42 ≈ 1.24 × 10⁸ m/s। ध्यान दें कि अपनी चरम प्रकाशीय घनत्व के कारण अन्य माध्यमों की तुलना में हीरे के ट्रैक में फोटॉन कितनी धीमी गति से चलता है।',
      },
      {
        'concept': 'प्रकाशीय घनत्व द्वारा छँटाई',
        'action':
            'सामग्रियों को प्रकाशीय विरल (सबसे तेज गति) से प्रकाशीय सघन (सबसे धीमी गति) तक व्यवस्थित करने के लिए ब्लॉकों को सही स्लॉट में खींचें और छोड़ें।',
        'observation':
            'हवा (1.0) → पानी (1.33) → कांच (1.5) → हीरा (2.42)। एक उच्च अपवर्तनांक का अर्थ हमेशा उच्च प्रकाशीय घनत्व होता है, जिसके परिणामस्वरूप प्रकाश की गति धीमी होती है।',
      },
    ],
  },
});

const _cyan = Color(0xFF06B6D4);
const _cyanDark = Color(0xFF0891B2);
const _cyanLight = Color(0xFF22D3EE);
const _orange = Color(0xFFF59E0B);
const _orangeDark = Color(0xFFD97706);
const _green = Color(0xFF22C55E);
const _yellow = Color(0xFFEAB308);

/// Phases 1-4 are tasks; 0 is the objective board, 5 the finished lab.
const _lastStep = 4;

/// The four media in order of increasing refractive index, which is also the
/// correct sort order. A photon needs [_baseTime] × n seconds for one track,
/// so its speed is v = c/n and the finishing times are proportional to n.
const _media = [
  (id: 'air', n: 1.0003, shown: '1.0', color: Color(0xFF94A3B8)),
  (id: 'water', n: 1.33, shown: '1.33', color: Color(0xFF3B82F6)),
  (id: 'glass', n: 1.5, shown: '1.5', color: Color(0xFF10B981)),
  (id: 'diamond', n: 2.42, shown: '2.42', color: Color(0xFF818CF8)),
];
const _mediaIcons = [
  Icons.air,
  Icons.water_drop,
  Icons.view_in_ar,
  Icons.diamond,
];

/// Seconds the air photon needs for one track (the HTML `baseDur`).
const _baseTime = 2.5;

/// Photons run from [_startX] to [_finishX]; track i lies at z = i × [_gap].
const _startX = -9.5, _finishX = 9.5, _gap = 1.75;

/// Order the sorting tray deals the blocks in. The HTML dealt them already
/// sorted (air, water, glass, diamond), which gave the answer away.
const _trayOrder = [2, 3, 0, 1];

/// Formula tokens of phase 2; each one names the slot it belongs in.
const _tokC = 'c', _tokV = 'v';

class Cl10SCh09A5SpeedTrapPage extends StatefulWidget {
  const Cl10SCh09A5SpeedTrapPage({super.key});

  @override
  State<Cl10SCh09A5SpeedTrapPage> createState() => _SpeedTrapState();
}

class _SpeedTrapState extends State<Cl10SCh09A5SpeedTrapPage> {
  final _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF0B2236), Color(0xFF040B16)],
  );
  final _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 12, 20))
    ..minDistance = 4
    ..maxDistance = 60
    ..maxPolarAngle = math.pi / 2 + 0.1;
  final _viewCtrl = _rt_Scene3DController();
  final _shell = _rt_ShellController();
  final _nCtrl = TextEditingController();
  final _vCtrl = TextEditingController();
  final _nFocus = FocusNode();
  final _vFocus = FocusNode();

  late final _rt_Node3D _tracks, _blocksGroup;
  late final _rt_Mesh3D _startLine, _finishLine, _postA, _postB, _bar;
  late final _rt_Label3D _finishLabel;
  final List<_rt_Node3D> _lanes = [];
  final List<_rt_Mesh3D> _trackMeshes = [];
  final List<_rt_Sphere3D> _photons = [];
  final List<_rt_Sphere3D> _halos = [];
  final List<_rt_Line3D> _trails = [];
  final List<_rt_Label3D> _trackLabels = [];
  final List<_rt_Mesh3D> _blocks = [];
  final List<_rt_Label3D> _blockLabels = [];

  int _step = 0;
  bool _boardVisible = false;
  bool _camLocked = true;
  bool _labelsVisible = true;
  bool _compactView = false; // short phone; refreshed by every build
  Size _canvasSize = Size.zero;

  double? _raceT; // race clock in seconds; null when no race is running
  int _racers = 3; // tracks taking part in the current race
  bool _raceDone = false; // the phase 1 race has finished
  String? _aiKey; // System AI message on screen
  final Map<String, String> _slots = {}; // phase 2: slot -> token
  String? _pickedToken; // tap-to-select fallback for the formula tokens
  bool _glassSolved = false, _diamondSolved = false;
  final Set<int> _placed = {}; // phase 4: media already in their slots
  int? _pickedBlock; // tap-to-select fallback for the material blocks
  bool _anomalyOpen = false; // the did-you-know card is showing
  double? _flyT; // camera flight progress; null when idle
  final _flyPos = _rt_V3(), _flyTarget = _rt_V3();
  final List<double?> _hopT = List.filled(4, null);
  final List<_rt_V3> _hopFrom = List.generate(4, (_) => _rt_V3());
  double _time = 0;
  final Set<int> _openSteps = {};
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScene();
    _frame(_viewFor(1));
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _viewCtrl.dispose();
    _nCtrl.dispose();
    _vCtrl.dispose();
    _nFocus.dispose();
    _vFocus.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------------------------------------------------------- scene

  void _initScene() {
    _scene.setLights([
      _rt_Light3D.hemisphere(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(5, 12, 8), intensity: 1.2),
      _rt_Light3D.directional(_rt_V3(-5, 5, -5), color: _cyan, intensity: 0.5),
    ]);

    // Sci-fi grid floor (THREE.GridHelper), cut into short pieces so lines
    // running past the camera are clipped instead of vanishing. Always
    // painted first.
    final grid = <_rt_V3>[];
    for (var g = -16.0; g <= 16; g += 2) {
      for (var t = -10.0; t < 12; t += 2) {
        grid.addAll([_rt_V3(g, -0.5, t), _rt_V3(g, -0.5, t + 2)]);
      }
    }
    for (var g = -10.0; g <= 12; g += 2) {
      for (var t = -16.0; t < 16; t += 2) {
        grid.addAll([_rt_V3(t, -0.5, g), _rt_V3(t + 2, -0.5, g)]);
      }
    }
    _scene.add(
      _rt_Line3D(grid)
        ..segments = true
        ..color = const Color(0xFF0E3B4D)
        ..width = 1
        ..depthBias = 1000,
    );

    // Phases 1-3: one glassy lane per medium, each with its photon, a light
    // trail behind it and a name tag before the start line.
    _tracks = _scene.add(_rt_Node3D(name: 'tracks'));
    for (var i = 0; i < _media.length; i++) {
      final m = _media[i];
      final z = i * _gap;
      final lane = _tracks.add(_rt_Node3D());
      _lanes.add(lane);
      _trackMeshes.add(
        lane.add(
          _rt_Mesh3D(
              _rt_Geometry3D.box(20, 0.15, 1.2),
              _rt_Material3D(color: m.color, opacity: 0.45, shininess: 0.8)
                ..edgeColor = m.color.withValues(alpha: 0.8)
                ..edgeWidth = 1.5,
            )
            ..position.z = z
            ..pickable = false,
        ),
      );
      _trails.add(
        lane.add(
          _rt_Line3D([_rt_V3(_startX, 0.3, z), _rt_V3(_startX, 0.3, z)])
            ..color = m.color
            ..width = 3
            ..opacity = 0.6
            ..depthBias = -40,
        ),
      );
      // Photons float above their lanes, so they are drawn over the tracks.
      final photon = lane.add(
        _rt_Sphere3D(
            0.22,
            _rt_Material3D(color: Color.lerp(Colors.white, m.color, 0.25)!)
              ..unlit = true,
          )
          ..position.set(_startX, 0.3, z)
          ..depthBias = -50
          ..pickable = false,
      );
      _photons.add(photon);
      _halos.add(
        photon.add(
          _rt_Sphere3D(
              0.35,
              _rt_Material3D(color: m.color, opacity: 0.4)..unlit = true,
            )
            ..depthBias = -49
            ..pickable = false,
        ),
      );
      _trackLabels.add(
        lane.add(
          _rt_Label3D(
              '',
              position: _rt_V3(-12, 0.1, z),
              background: const Color(0xE60A192F),
            )
            ..color = _cyan
            ..borderColor = _cyan.withValues(alpha: 0.5)
            ..pickable = false,
        ),
      );
    }

    // Start and finish lines with a finish gate (the HTML had none, although
    // its observation talks about the finish line).
    _startLine = _tracks.add(
      _rt_Mesh3D(
          _rt_Geometry3D.box(0.1, 0.18, 1),
          _rt_Material3D(color: Colors.white, opacity: 0.85)..unlit = true,
        )
        ..position.x = _startX + 0.3
        ..pickable = false,
    );
    _finishLine = _tracks.add(
      _rt_Mesh3D(
          _rt_Geometry3D.box(0.14, 0.18, 1),
          _rt_Material3D(color: _cyanLight)..unlit = true,
        )
        ..position.x = _finishX - 0.3
        ..pickable = false,
    );
    final postMat = _rt_Material3D(color: _rt_Tw.slate300, shininess: 0.6);
    _rt_Mesh3D post() => _tracks.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.06, 0.06, 1.6, segments: 10),
          postMat,
        )
        ..position.set(_finishX - 0.3, 0.3, 0)
        ..pickable = false,
    );
    _postA = post();
    _postB = post();
    _bar = _tracks.add(
      _rt_Mesh3D(
          _rt_Geometry3D.box(0.1, 0.1, 1),
          _rt_Material3D(color: _cyanLight)..unlit = true,
        )
        ..position.set(_finishX - 0.3, 1.1, 0)
        ..pickable = false,
    );
    _finishLabel = _tracks.add(
      _rt_Label3D(
          '',
          position: _rt_V3(_finishX - 0.3, 1.6, -0.95),
          background: const Color(0xE60A192F),
        )
        ..color = _cyanLight
        ..borderColor = _cyan.withValues(alpha: 0.5)
        ..pickable = false,
    );

    // Phase 4: one block per material (the HTML only showed an empty grid).
    // Each hops from the tray row at the back to its place in the sorted
    // row once the student puts its tile in the right slot.
    _blocksGroup = _scene.add(_rt_Node3D(name: 'blocks')..visible = false);
    const opacity = [0.2, 0.55, 0.45, 0.85];
    for (var i = 0; i < _media.length; i++) {
      final m = _media[i];
      _blocks.add(
        _blocksGroup.add(
          _rt_Mesh3D(
            i == 3
                ? _rt_Geometry3D.octahedron(0.95)
                : _rt_Geometry3D.box(1.4, 1.4, 1.4),
            _rt_Material3D(
                color: i == 0 ? _rt_Tw.slate200 : m.color,
                opacity: opacity[i],
                shininess: 0.3 + i * 0.2,
              )
              ..edgeColor = (i == 3 ? Colors.white : m.color).withValues(
                alpha: 0.85,
              )
              ..edgeWidth = 1.5,
          )..pickable = false,
        ),
      );
      _blockLabels.add(
        _blocksGroup.add(
          _rt_Label3D('', background: const Color(0xE60A192F))
            ..color = _cyan
            ..borderColor = _cyan.withValues(alpha: 0.5)
            ..pickable = false,
        ),
      );
    }
    // Arrow in front of the sorted row: optically rare -> optically dense.
    _blocksGroup.add(
      _rt_Line3D([
          _rt_V3(-6, -0.48, 2.3),
          _rt_V3(6, -0.48, 2.3),
          _rt_V3(6, -0.48, 2.3),
          _rt_V3(5.5, -0.48, 2.0),
          _rt_V3(6, -0.48, 2.3),
          _rt_V3(5.5, -0.48, 2.6),
        ])
        ..segments = true
        ..color = _cyan
        ..width = 2.5
        ..opacity = 0.8
        ..depthBias = 500,
    );
    _placeBlocks();
    _syncScene();
  }

  /// Where block [i] rests: in the tray row, or in its sorted slot.
  _rt_V3 _blockHome(int i, {required bool sorted}) {
    final slot = sorted ? i : _trayOrder.indexOf(i);
    return _rt_V3(-4.5 + 3.0 * slot, i == 3 ? 0.45 : 0.2, sorted ? 1.1 : -1.8);
  }

  void _placeBlocks() {
    for (var i = 0; i < _blocks.length; i++) {
      _blocks[i].position.copy(_blockHome(i, sorted: _placed.contains(i)));
      _blocks[i].material.emissive = _placed.contains(i)
          ? _media[i].color
          : null;
    }
    _moveBlockLabels();
  }

  void _moveBlockLabels() {
    for (var i = 0; i < _blocks.length; i++) {
      _blockLabels[i].position
        ..copy(_blocks[i].position)
        ..y += 1.3;
    }
  }

  /// Puts photon [i] at fraction [f] of its track and stretches its trail.
  void _setPhoton(int i, double f) {
    final x = _startX + (_finishX - _startX) * f;
    _photons[i].position.x = x;
    _trails[i].points[1].x = x;
  }

  /// Fits the start/finish lines and the gate around [count] lanes.
  void _setLaneCount(int count) {
    final zMax = (count - 1) * _gap;
    final mid = zMax / 2;
    for (final line in [_startLine, _finishLine]) {
      line
        ..position.z = mid
        ..scale.z = zMax + 1.6;
    }
    _postA.position.z = -0.95;
    _postB.position.z = zMax + 0.95;
    _bar
      ..position.z = mid
      ..scale.z = zMax + 1.9;
  }

  void _frame((_rt_V3, _rt_V3) view) {
    _camera.position.copy(view.$1);
    _camera.target.copy(view.$2);
    _camera.zoom = 1;
    _camera.saveHome();
  }

  /// Camera for [step], fitted to the free part of the current canvas:
  /// below the HUD, above the bottom card and left of the toolbar. The
  /// tracks are long and flat, so this keeps both ends on screen on a short
  /// phone as well as on a wide monitor.
  (_rt_V3, _rt_V3) _viewFor(int step) {
    final size = _canvasSize.isEmpty ? const Size(980, 720) : _canvasSize;
    final compact = size.height < 480;
    final blocks = step >= 4;
    // World box to show. x0 is the centre of the lane tags, which are
    // [tagHalf] pixels wide on each side; h is the tallest prop.
    final x0 = blocks ? -5.3 : -12.0;
    final x1 = blocks ? 5.3 : 10.0;
    final z0 = blocks ? -2.6 : -0.9;
    final z1 = blocks ? 2.6 : (step == 3 ? 3 : 2) * _gap + 0.9;
    final h = blocks ? 2.6 : 2.2;
    final tagHalf = blocks ? 0.0 : (compact ? 38.0 : 46.0);
    // A steep view spreads the flat lanes apart on screen.
    final elev = blocks ? 0.85 : (compact ? 1.05 : 0.9);
    final top = compact ? 68.0 : 128.0;
    final bottom = size.height - _bottomRoom(step, compact);
    const left = 14.0;
    final right = size.width - 66;
    final s = math.sin(elev), c = math.cos(elev);
    // Scale needed at the front edge, the part nearest the camera.
    final ppuNear = math.max(
      4.0,
      math.min(
        (right - left - tagHalf) / (x1 - x0),
        (bottom - top) / ((z1 - z0) * s + h * c),
      ),
    );
    final focal = size.height / 2 / math.tan(_rt_degToRad(_camera.fov) / 2);
    final dist = focal / ppuNear + (z1 - z0) / 2 * c + (blocks ? h / 2 * s : 0);
    final ppu = focal / dist; // scale at the target
    final target = _rt_V3((x0 + x1) / 2, h / 2 - 0.5, (z0 + z1) / 2)
      ..add(_rt_V3((size.width - left - tagHalf - right) / 2 / ppu, 0, 0))
      ..add(_rt_V3(0, c, -s) * (((top + bottom) - size.height) / 2 / ppu));
    return (target + _rt_V3(0, s, c) * dist, target);
  }

  /// Height of the bottom card (or System AI bubble) in [step].
  double _bottomRoom(int step, bool compact) => switch (step) {
    2 => compact ? 118 : 232,
    3 => compact ? 125 : 180,
    >= 4 => compact ? 124 : 262,
    _ => compact ? 96 : 120,
  };

  /// Starts a smooth camera flight to the view of the current step.
  void _fly() {
    _flyPos.copy(_camera.position);
    _flyTarget.copy(_camera.target);
    _flyT = 0;
  }

  void _syncScene() {
    _tracks.visible = _step <= 3;
    _lanes[3].visible = _step >= 3;
    _blocksGroup.visible = _step >= 4;
    _setLaneCount(_step >= 3 ? 4 : 3);
    // Phase 2 is about glass, so its lane glows.
    _trackMeshes[2].material
      ..emissive = _step == 2 ? _media[2].color : null
      ..emissiveIntensity = 0.3;
    for (final l in [..._trackLabels, ..._blockLabels, _finishLabel]) {
      l.visible = _labelsVisible;
    }
  }

  // ---------------------------------------------------------------- flow

  void _begin() {
    _boardVisible = false;
    _advance();
  }

  void _advance() {
    _advanceTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _step++;
      _aiKey = null;
      _openSteps.clear();
    });
    _syncScene();
    if (_step == 3) {
      // Line every photon up again for the four-lane race.
      for (var i = 0; i < _photons.length; i++) {
        _setPhoton(i, 0);
      }
    }
    if (_step == 1) {
      _frame(_viewFor(1));
    } else {
      _fly();
    }
  }

  void _advanceAfter(Duration delay) {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(delay, () {
      if (mounted) _advance();
    });
  }

  void _restart() {
    _advanceTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    _nCtrl.clear();
    _vCtrl.clear();
    for (var i = 0; i < _photons.length; i++) {
      _setPhoton(i, 0);
      _hopT[i] = null;
    }
    setState(() {
      _step = 0;
      _boardVisible = true;
      _raceT = null;
      _raceDone = false;
      _aiKey = null;
      _slots.clear();
      _pickedToken = null;
      _glassSolved = _diamondSolved = false;
      _placed.clear();
      _pickedBlock = null;
      _anomalyOpen = false;
      _flyT = null;
      _openSteps.clear();
    });
    _placeBlocks();
    _syncScene();
    _frame(_viewFor(1));
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _rt_playSfx(_rt_Sfx.scenario);
  }

  void _onFrame(double dt) {
    _time += dt;
    // Halo pulse (the HTML yoyo tween: 1 -> 1.3 -> 1 every 1.6 s).
    final pulse = 1 + 0.15 * (1 - math.cos(_time * math.pi / 0.8));
    for (final h in _halos) {
      h.radius = 0.35 * pulse;
    }

    final race = _raceT;
    if (race != null) {
      final t = race + dt;
      var done = true;
      for (var i = 0; i < _racers; i++) {
        final f = math.min(1.0, t / (_baseTime * _media[i].n));
        _setPhoton(i, f);
        if (f < 1) done = false;
      }
      _raceT = done ? null : t;
      if (done) _raceFinished();
    }

    final fly = _flyT;
    if (fly != null) {
      final p = math.min(1.0, fly + dt / 1.5);
      final e = Curves.easeInOut.transform(p);
      final (pos, target) = _viewFor(_step);
      _camera.position.copy(_flyPos.lerp(pos, e));
      _camera.target.copy(_flyTarget.lerp(target, e));
      _flyT = p < 1 ? p : null;
      if (p >= 1) _frame((pos, target));
    }

    if (_blocksGroup.visible) {
      for (var i = 0; i < _blocks.length; i++) {
        final hop = _hopT[i];
        if (hop == null) continue;
        final p = math.min(1.0, hop + dt / 0.6);
        // Hop over the other blocks on the way to the sorted row.
        _blocks[i].position
          ..copy(
            _hopFrom[i].lerp(
              _blockHome(i, sorted: true),
              Curves.easeInOut.transform(p),
            ),
          )
          ..y += 1.8 * math.sin(math.pi * p);
        _hopT[i] = p < 1 ? p : null;
      }
      _blocks[3].rotation.y = _time * 0.6;
      _moveBlockLabels();
    }
  }

  // ------------------------------------------------------- phases 1 and 3

  /// Lines every photon up and races the first [racers] lanes together.
  void _race(int racers) {
    for (var i = 0; i < _photons.length; i++) {
      _setPhoton(i, 0);
    }
    _racers = racers;
    _raceT = 0;
  }

  void _launchRace() {
    if (_step != 1 || _raceT != null || _raceDone) return;
    _rt_playSfx(_rt_Sfx.magic);
    _race(3);
    setState(() => _aiKey = 'panda_step1');
  }

  void _raceFinished() {
    if (_step == 1) {
      setState(() => _raceDone = true);
      _advanceAfter(const Duration(milliseconds: 1250));
    } else if (_step == 3) {
      _advanceAfter(const Duration(milliseconds: 1500));
    }
  }

  /// Reads a typed number; accepts a comma as decimal separator.
  double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  void _toastError(String message) {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(message, color: _rt_Tw.red500, icon: Icons.error_outline);
  }

  // ------------------------------------------------- phase 2: n = c / v

  void _pickToken(String id) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _pickedToken = _pickedToken == id ? null : id);
  }

  void _placeToken(String slot, String token) {
    if (_step != 2 || _slots.containsKey(slot)) return;
    if (_slots.containsValue(token)) return;
    if (slot != token) {
      setState(() => _pickedToken = null);
      _toastError(_tx.s('err_slot'));
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() {
      _slots[slot] = token;
      _pickedToken = null;
    });
  }

  void _checkGlass() {
    // The HTML checked on every keystroke, buzzing while "1.5" was still
    // being typed, and could advance twice; now it is one explicit check.
    if (_step != 2 || _glassSolved || _slots.length < 2) return;
    _nFocus.unfocus();
    final n = _parse(_nCtrl.text);
    if (n == null) {
      _toastError(_tx.s('err_empty'));
    } else if ((n - 1.5).abs() > 0.011) {
      _toastError(_tx.s('err_n'));
    } else {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() {
        _glassSolved = true;
        _aiKey = 'panda_step2';
      });
      _advanceAfter(const Duration(seconds: 4));
    }
  }

  // ------------------------------------------------ phase 3: v = c / n

  void _checkDiamond() {
    if (_step != 3 || _diamondSolved) return;
    _vFocus.unfocus();
    var v = _parse(_vCtrl.text);
    // Also accept the full speed, e.g. 124000000.
    if (v != null && v >= 1e6) v /= 1e8;
    if (v == null) {
      _toastError(_tx.s('err_empty'));
    } else if (v < 1.23 || v > 1.25) {
      _toastError(_tx.s('err_v'));
    } else {
      _rt_playSfx(_rt_Sfx.correct);
      _race(4);
      setState(() {
        _diamondSolved = true;
        _aiKey = 'panda_step3';
      });
    }
  }

  // ------------------------------------------------- phase 4: sorting

  void _pickBlock(int i) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _pickedBlock = _pickedBlock == i ? null : i);
  }

  void _placeBlock(int slot, int medium) {
    if (_step != 4 || _placed.contains(slot) || _placed.contains(medium)) {
      return;
    }
    if (slot != medium) {
      setState(() => _pickedBlock = null);
      _toastError(
        _tx.s('err_sort').replaceAll('{m}', _tx.s('mat_${_media[medium].id}')),
      );
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    _hopFrom[medium].copy(_blocks[medium].position);
    _hopT[medium] = 0;
    _blocks[medium].material
      ..emissive = _media[medium].color
      ..emissiveIntensity = 0.25;
    setState(() {
      _placed.add(medium);
      _pickedBlock = null;
    });
    if (_placed.length == _media.length) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 900), _showAnomaly);
    }
  }

  /// Opens the HTML "The Anomaly" did-you-know card; the summary follows.
  void _showAnomaly() {
    if (!mounted) return;
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _step = _lastStep + 1;
      _anomalyOpen = true;
    });
    _syncScene();
  }

  void _closeAnomaly() {
    setState(() => _anomalyOpen = false);
    _showSummary();
  }

  void _showSummary() {
    if (!mounted) return;
    // Short phones get the takeaway as plain text so the restart button
    // fits without scrolling.
    final compact = _compactView;
    _shell.showSuccess(
      title: _tx.s('success'),
      message: compact ? '${_tx.s('summary_head')} ${_tx.s('summary')}' : null,
      body: compact ? null : _summaryCard(),
      icon: Icons.emoji_events,
      color: _cyanDark,
      sound: _rt_Sfx.curtain,
      buttonLabel: _tx.s('btn_restart'),
      onConfirm: _restart,
    );
  }

  // ---------------------------------------------------------------- build

  bool get _compact => MediaQuery.sizeOf(context).height < 480;

  @override
  Widget build(BuildContext context) {
    _compactView = _compact;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          final px = _compactView ? 9.0 : 12.0;
          for (var i = 0; i < _media.length; i++) {
            final tag =
                '${_tx.s('mat_${_media[i].id}').toUpperCase()}\nn = ${_media[i].shown}';
            _trackLabels[i]
              ..text = tag
              ..pixelHeight = px;
            _blockLabels[i]
              ..text = tag
              ..pixelHeight = px;
            // Bigger photons on short phones, where the lanes are thin.
            final s = _compactView ? 1.5 : 1.2;
            _photons[i].scale.set(s, s, s);
          }
          _finishLabel
            ..text = _tx.s('finish').toUpperCase()
            ..pixelHeight = px;
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _cyanDark,
              headerGradient: [_rt_Tw.slate900, Color(0xFF164E63)],
              headerSubtitleColor: Color(0xFFA5F3FC),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _rt_CommonStrings.enterLab,
              footnote: _tx.s('intro.footnote'),
              icon: Icons.speed,
              buttonIcon: Icons.power_settings_new,
            ),
            onStart: () => setState(() => _boardVisible = true),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              _roundToggle(
                tip: _tx.s('tool_labels'),
                icon: Icons.label_outline,
                on: _labelsVisible,
                onTap: () {
                  setState(() => _labelsVisible = !_labelsVisible);
                  _syncScene();
                },
              ),
              const SizedBox(height: 4),
              _roundToggle(
                tip: _tx.s('tool_lock'),
                icon: _camLocked ? Icons.lock : Icons.lock_open,
                on: _camLocked,
                onTap: () => setState(() => _camLocked = !_camLocked),
              ),
              const SizedBox(height: 4),
              _rt_RotatePanToggle(controller: _viewCtrl, accent: _cyanDark),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.science,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: LayoutBuilder(
              builder: (context, box) {
                // Refit the locked camera when the canvas changes size (the
                // sidebar opening or closing, a rotated window).
                if (box.biggest != _canvasSize) {
                  _canvasSize = box.biggest;
                  if (_camLocked && _flyT == null) _frame(_viewFor(_step));
                }
                return _rt_Scene3DView(
                  scene: _scene,
                  camera: _camera,
                  controller: _viewCtrl,
                  onFrame: _onFrame,
                  cameraControls: !_camLocked,
                );
              },
            ),
            canvasOverlays: [
              if (_step >= 1 && _step <= _lastStep) _hudOverlay(),
              if (_aiKey != null) _aiOverlay(),
              if (_hasTask) _taskOverlay(),
              if (_anomalyOpen) _anomalyOverlay(),
              if (_step == 0 && _boardVisible) _boardOverlay(),
            ],
          );
        },
      ),
    );
  }

  bool get _hasTask => switch (_step) {
    1 => _raceT == null && !_raceDone,
    2 => !_glassSolved,
    3 => !_diamondSolved,
    4 => _placed.length < _media.length,
    _ => false,
  };

  Widget _roundToggle({
    required String tip,
    required IconData icon,
    required bool on,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        radius: 22,
        onTap: () {
          _rt_playSfx(_rt_Sfx.toggle);
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: on ? _cyanDark : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: on ? Colors.white : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(Color accent) => BoxDecoration(
    color: _rt_Lab.surface.withValues(alpha: 0.96),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
    boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 18)],
  );

  // ------------------------------------------------------------- overlays

  Widget _hudOverlay() {
    final compact = _compactView;
    final task = _tx.s('hud.${_step - 1}');
    return Positioned(
      key: const ValueKey('hud'),
      top: compact ? 8 : 14,
      left: 70,
      right: 70,
      child: IgnorePointer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: _cardDecoration(_cyan),
            // One block of text on short phones so the tracks stay visible.
            child: compact
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${_tx.s('curr_obj').toUpperCase()}: ',
                          style: const TextStyle(
                            color: _cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        TextSpan(text: task),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gps_fixed, size: 15, color: _cyan),
                          const SizedBox(width: 6),
                          Text(
                            _tx.s('curr_obj').toUpperCase(),
                            style: const TextStyle(
                              color: _cyanDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _rt_Lab.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// The HTML "System AI" teacher bubble (bottom right, movable).
  Widget _aiOverlay() {
    final compact = _compactView;
    return Positioned(
      key: const ValueKey('ai'),
      right: compact ? 60 : 70,
      bottom: compact ? 8 : 20,
      child: Container(
        constraints: BoxConstraints(maxWidth: compact ? 250 : 340),
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: _cardDecoration(_cyan).copyWith(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 30 : 42,
              height: compact ? 30 : 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withValues(alpha: 0.18),
                border: Border.all(color: _cyan, width: 2),
              ),
              child: Icon(
                Icons.smart_toy,
                color: _cyan,
                size: compact ? 16 : 22,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.memory, size: 12, color: _cyan),
                      const SizedBox(width: 4),
                      Text(
                        _tx.s('teacher').toUpperCase(),
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tx.s(_aiKey!),
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: compact ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
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

  Widget _taskOverlay() {
    final compact = _compactView;
    // A full-canvas layer stays fixed in the shell, so the action bar cannot
    // be dragged away: a slightly wobbly finger press on a phone used to move
    // the bar instead of pressing its button. Empty space still reaches the
    // 3D view underneath.
    return Positioned.fill(
      key: const ValueKey('task'),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          // Compact: keep clear of the vertical toolbar on the right.
          padding: compact
              ? const EdgeInsets.fromLTRB(12, 8, 60, 8)
              : const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _step == 4 ? 600 : 560),
            child: switch (_step) {
              1 => _pillButton(
                const ValueKey('launchBtn'),
                Icons.rocket_launch,
                _tx.s('start_race'),
                _cyanDark,
                _launchRace,
              ),
              2 => _formulaCard(),
              3 => _diamondCard(),
              _ => _sortCard(),
            },
          ),
        ),
      ),
    );
  }

  Widget _pillButton(
    Key key,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    // heightFactor 1: a plain Center would fill the bar's full-canvas height
    // and float the pill in the middle of the 3D view.
    return Center(
      heightFactor: 1,
      child: KeyedSubtree(
        key: key,
        child: _PressButton(
          onPressed: () {
            _rt_playSfx(_rt_Sfx.click);
            onTap();
          },
          child: Material(
            color: color,
            elevation: 6,
            shape: StadiumBorder(
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22,
                vertical: _compactView ? 9 : 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Small caption pill at the top of a card (the HTML border labels).
  Widget _cardTag(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: _compactView ? 9 : 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _math(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: _compactView ? 17 : 24,
      fontWeight: FontWeight.w900,
    ),
  );

  /// Numeric answer box. It lives in the fixed bottom layer; the shell lifts
  /// the whole lab above the soft keyboard while it has focus.
  Widget _answerField(
    Key key,
    TextEditingController ctrl,
    FocusNode focus,
    Color color, {
    required bool enabled,
    required VoidCallback onSubmit,
  }) {
    final compact = _compactView;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: 2),
    );
    return SizedBox(
      key: key,
      width: compact ? 60 : 88,
      child: TextField(
        controller: ctrl,
        focusNode: focus,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: compact ? 15 : 19,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: '?',
          hintStyle: TextStyle(color: _rt_Lab.textFaint),
          filled: true,
          fillColor: _rt_Lab.overlay,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: compact ? 9 : 13,
          ),
          enabledBorder: border(_rt_Lab.borderStrong),
          focusedBorder: border(color),
          disabledBorder: border(_rt_Lab.border),
        ),
        onSubmitted: (_) => onSubmit(),
        onTapOutside: (_) => focus.unfocus(),
      ),
    );
  }

  /// Check / verify button next to an answer box. Counted as part of the
  /// text field's tap region, so pressing it does not first close the
  /// keyboard and slide the button away from under the finger.
  Widget _verifyButton(
    Key key,
    String? label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final compact = _compactView;
    final enabled = onTap != null;
    return TextFieldTapRegion(
      child: KeyedSubtree(
        key: key,
        child: _PressButton(
          onPressed: onTap == null
              ? null
              : () {
                  _rt_playSfx(_rt_Sfx.click);
                  onTap();
                },
          child: Material(
            color: enabled ? color : color.withValues(alpha: 0.4),
            elevation: enabled ? 3 : 0,
            shape: const StadiumBorder(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 11 : 16,
                vertical: compact ? 9 : 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 17, color: Colors.white),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Phase 2: the HTML formula card n = c / v with its two draggable values.
  Widget _formulaCard() {
    final compact = _compactView;
    final filled = _slots.length == 2;
    final tokens = [
      if (!_slots.containsValue(_tokC)) _token(_tokC, 'c = 3 × 10⁸', _cyan),
      if (!_slots.containsValue(_tokV)) _token(_tokV, 'v = 2 × 10⁸', _orange),
    ];
    final muted = _rt_Lab.textMuted;
    final card = Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 18,
        compact ? 7 : 12,
        compact ? 10 : 18,
        compact ? 8 : 14,
      ),
      decoration: _cardDecoration(_cyan),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cardTag(_tx.s('calc_glass'), _cyan),
          SizedBox(height: compact ? 4 : 8),
          // Shrinks instead of overflowing if a translation runs long.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _math('n', _cyan),
                _math(' = ', muted),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _slot(_tokC),
                    Container(
                      width: compact ? 72 : 128,
                      height: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: muted,
                    ),
                    _slot(_tokV),
                  ],
                ),
                _math(' = ', muted),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!compact) ...[
                      Text(
                        _tx.s('result').toUpperCase(),
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    _answerField(
                      const ValueKey('nField'),
                      _nCtrl,
                      _nFocus,
                      _cyan,
                      enabled: filled && !_glassSolved,
                      onSubmit: _checkGlass,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                _verifyButton(
                  const ValueKey('nCheck'),
                  compact ? null : _tx.s('btn_check'),
                  Icons.check,
                  _cyanDark,
                  filled ? _checkGlass : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tokens.isNotEmpty) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < tokens.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  tokens[i],
                ],
              ],
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: card),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tokens.isNotEmpty) ...[
          Wrap(spacing: 16, runSpacing: 8, children: tokens),
          const SizedBox(height: 12),
        ],
        card,
      ],
    );
  }

  /// Draggable formula value; tap to select it, then tap a slot.
  Widget _token(String id, String label, Color color) {
    final compact = _compactView;
    Widget chip({bool dragging = false}) => Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 18,
        vertical: compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: dragging ? color : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _pickedToken == id && !dragging ? Colors.white : color,
          width: _pickedToken == id ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dragging ? Colors.white : color,
          fontSize: compact ? 13 : 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    return KeyedSubtree(
      key: ValueKey('token-$id'),
      child: _PressButton(
        onPressed: () => _pickToken(id),
        child: Draggable<String>(
          data: id,
          onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
          feedback: Material(
            color: Colors.transparent,
            child: chip(dragging: true),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: chip()),
          child: chip(),
        ),
      ),
    );
  }

  /// Formula slot: drop its token on it, or tap it with that token selected.
  /// A wrong token is refused with a hint instead of silently bouncing back.
  Widget _slot(String id) {
    final compact = _compactView;
    final placed = _slots[id];
    final pick = _pickedToken;
    final color = id == _tokC ? _cyan : _orange;
    return KeyedSubtree(
      key: ValueKey('slot-$id'),
      child: _PressButton(
        onPressed: placed == null && pick != null
            ? () => _placeToken(id, pick)
            : null,
        child: DragTarget<String>(
          onWillAcceptWithDetails: (d) =>
              placed == null && (d.data == _tokC || d.data == _tokV),
          onAcceptWithDetails: (d) => _placeToken(id, d.data),
          builder: (context, candidates, _) {
            final hot =
                candidates.isNotEmpty || (placed == null && pick != null);
            return Container(
              width: compact ? 72 : 128,
              height: compact ? 30 : 44,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: placed != null
                    ? color.withValues(alpha: 0.18)
                    : (hot ? _orange.withValues(alpha: 0.18) : _rt_Lab.overlay),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: placed != null
                      ? color
                      : (hot ? _orange : _rt_Lab.borderStrong),
                  width: 2,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  placed == null
                      ? _tx.s('drop_$id').toUpperCase()
                      : (id == _tokC ? '3 × 10⁸' : '2 × 10⁸'),
                  maxLines: 1,
                  style: TextStyle(
                    color: placed == null ? _rt_Lab.textMuted : _rt_Lab.text,
                    fontSize: placed == null ? 11 : (compact ? 14 : 18),
                    fontWeight: FontWeight.w900,
                    letterSpacing: placed == null ? 1 : 0,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Phase 3: the HTML diamond challenge card, v = c / n.
  Widget _diamondCard() {
    final compact = _compactView;
    final muted = _rt_Lab.textMuted;
    final given = TextStyle(
      color: muted,
      fontSize: compact ? 10 : 12,
      fontWeight: FontWeight.w800,
    );
    final verify = _verifyButton(
      const ValueKey('vVerify'),
      _tx.s(compact ? 'submit_short' : 'submit'),
      Icons.rocket_launch,
      _orangeDark,
      _checkDiamond,
    );
    final answer = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _answerField(
          const ValueKey('vField'),
          _vCtrl,
          _vFocus,
          _orange,
          enabled: !_diamondSolved,
          onSubmit: _checkDiamond,
        ),
        const SizedBox(width: 6),
        Text(
          '× 10⁸ m/s',
          style: TextStyle(
            color: _rt_Lab.text,
            fontSize: compact ? 12 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 18,
        compact ? 7 : 12,
        compact ? 10 : 18,
        compact ? 8 : 14,
      ),
      decoration: _cardDecoration(_orange),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cardTag(_tx.s('calc_diamond'), _orange),
          SizedBox(height: compact ? 5 : 10),
          // Wraps instead of overflowing when space runs out; the answer box
          // and its button always stay on one line, so both remain above the
          // soft keyboard.
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: compact ? 10 : 16,
            runSpacing: 6,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('c = 3.0 × 10⁸ m/s', style: given),
                  Text('n = 2.42', style: given),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _math('v', _orange),
                  _math(' = ', muted),
                  _math('c / n', _cyan),
                  _math(' =', muted),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  answer,
                  SizedBox(width: compact ? 8 : 12),
                  Flexible(child: verify),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Phase 4: draggable material blocks and the rare -> dense slot row.
  Widget _sortCard() {
    final compact = _compactView;
    final label = TextStyle(
      fontSize: compact ? 9 : 11,
      fontWeight: FontWeight.w900,
      letterSpacing: 1,
    );
    final tiles = [
      for (final i in _trayOrder)
        if (!_placed.contains(i)) _blockTile(i),
    ];
    final card = Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 14,
        compact ? 6 : 10,
        compact ? 8 : 14,
        compact ? 8 : 14,
      ),
      decoration: _cardDecoration(_cyan),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cardTag(_tx.s('sorting'), _cyan),
          SizedBox(height: compact ? 4 : 8),
          // Long captions shrink to an ellipsis instead of overflowing.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  _tx.s('fastest').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: label.copyWith(color: _green),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(left: 8),
                  color: _cyan.withValues(alpha: 0.35),
                ),
              ),
              const Icon(
                Icons.keyboard_double_arrow_right,
                size: 16,
                color: _cyan,
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 2,
                child: Text(
                  _tx.s('slowest').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: label.copyWith(color: _orange),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 5 : 8),
          Row(
            children: [
              for (var s = 0; s < _media.length; s++) ...[
                if (s > 0) SizedBox(width: compact ? 6 : 12),
                Expanded(child: _sortSlot(s)),
              ],
            ],
          ),
        ],
      ),
    );
    // Short phones: the tiles sit in a 2 x 2 grid beside the slots, which
    // leaves more of the screen to the blocks above.
    if (compact) {
      return Row(
        children: [
          if (tiles.isNotEmpty) ...[
            SizedBox(
              width: 106,
              child: Wrap(spacing: 6, runSpacing: 6, children: tiles),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: card),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 8,
          children: tiles,
        ),
        const SizedBox(height: 12),
        card,
      ],
    );
  }

  Widget _blockChip(int i, {bool dragging = false, double? side}) {
    final m = _media[i];
    final size = side ?? (_compactView ? 50.0 : 74.0);
    final selected = _pickedBlock == i && !dragging;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(m.color.withValues(alpha: 0.35), _rt_Lab.surface),
            Color.alphaBlend(m.color.withValues(alpha: 0.12), _rt_Lab.surface),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected || dragging ? Colors.white : m.color,
          width: selected ? 3 : 2,
        ),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_mediaIcons[i], size: 24, color: m.color),
            Text(
              _tx.s('mat_${m.id}').toUpperCase(),
              style: TextStyle(
                color: _rt_Lab.text,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              m.shown,
              style: const TextStyle(
                color: _cyan,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Draggable material block; tap to select it, then tap a slot.
  Widget _blockTile(int i) {
    return KeyedSubtree(
      key: ValueKey('tile-${_media[i].id}'),
      child: _PressButton(
        onPressed: () => _pickBlock(i),
        child: Draggable<String>(
          data: _media[i].id,
          onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
          feedback: Material(
            color: Colors.transparent,
            child: _blockChip(i, dragging: true),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: _blockChip(i)),
          child: _blockChip(i),
        ),
      ),
    );
  }

  /// Sorting slot [s] takes the medium with the (s + 1)-th lowest index.
  Widget _sortSlot(int s) {
    final compact = _compactView;
    final filled = _placed.contains(s);
    final pick = _pickedBlock;
    final height = compact ? 54.0 : 80.0;
    return KeyedSubtree(
      key: ValueKey('sort-$s'),
      child: _PressButton(
        onPressed: !filled && pick != null ? () => _placeBlock(s, pick) : null,
        child: DragTarget<String>(
          onWillAcceptWithDetails: (d) =>
              !filled && _media.any((m) => m.id == d.data),
          onAcceptWithDetails: (d) =>
              _placeBlock(s, _media.indexWhere((m) => m.id == d.data)),
          builder: (context, candidates, _) {
            final hot = !filled && (candidates.isNotEmpty || pick != null);
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: filled
                    ? _cyan.withValues(alpha: 0.12)
                    : (hot ? _orange.withValues(alpha: 0.15) : _rt_Lab.overlay),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled
                      ? _cyan
                      : (hot ? _orange : _rt_Lab.borderStrong),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (filled)
                    _blockChip(s, side: height - 8)
                  else
                    Text(
                      '${s + 1}',
                      style: TextStyle(
                        color: _rt_Lab.textFaint,
                        fontSize: compact ? 16 : 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  if (filled)
                    const Positioned(
                      top: 2,
                      right: 2,
                      child: Icon(Icons.check_circle, size: 16, color: _green),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// The HTML "The Anomaly" modal: a beaker beside the explanation. It is a
  /// canvas layer like the source's, which keeps it compact enough for a
  /// short phone without scrolling.
  Widget _anomalyOverlay() {
    final compact = _compactView;
    return Positioned.fill(
      key: const ValueKey('anomaly'),
      child: Container(
        color: _rt_Lab.base.withValues(alpha: 0.88),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          // Compact: keep clear of the vertical toolbar on the right.
          padding: compact
              ? const EdgeInsets.fromLTRB(8, 8, 60, 8)
              : const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: EdgeInsets.all(compact ? 14 : 28),
              decoration: _cardDecoration(_cyan),
              child: Row(
                children: [
                  _beaker(),
                  SizedBox(width: compact ? 14 : 28),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tx.s('did_you_know').toUpperCase(),
                          style: TextStyle(
                            color: _cyan,
                            fontSize: compact ? 15 : 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 12),
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: _cyan, width: 4),
                            ),
                          ),
                          child: Text(
                            _tx.s('dyk_text'),
                            style: TextStyle(
                              color: _rt_Lab.textMuted,
                              fontSize: compact ? 11.5 : 15,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 18),
                        _rt_ActionButton(
                          label: _tx.s('continue'),
                          icon: Icons.check,
                          color: _cyanDark,
                          onPressed: _closeAnomaly,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kerosene floating on water (the HTML beaker graphic).
  Widget _beaker() {
    final compact = _compactView;
    Widget layer(String key, String n, Color color) => Expanded(
      child: Container(
        width: double.infinity,
        color: color.withValues(alpha: 0.4),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${_tx.s(key)}\nn = $n',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _rt_Lab.text,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    return Container(
      width: compact ? 92 : 128,
      height: compact ? 118 : 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        border: Border.all(color: _cyan.withValues(alpha: 0.4), width: 3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Column(
        children: [
          layer('kerosene', '1.44', _yellow),
          Container(height: 1, color: _yellow),
          layer('water', '1.33', _media[1].color),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(const Color(0xFFECFEFF), _cyan),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 16, color: _cyanDark),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _tx.s('observation_title').toUpperCase(),
                  style: const TextStyle(
                    color: _cyanDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tx.s('summary_head'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _rt_Lab.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tx.s('summary'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _rt_Lab.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _boardOverlay() {
    // Compact variant so the start button fits on short landscape phones.
    final compact = _compactView;
    return Positioned.fill(
      key: const ValueKey('board'),
      child: Container(
        color: _rt_Lab.base.withValues(alpha: 0.9),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          // Compact: keep clear of the vertical toolbar on the right.
          padding: compact
              ? const EdgeInsets.fromLTRB(8, 8, 60, 8)
              : const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: EdgeInsets.all(compact ? 14 : 24),
              decoration: _cardDecoration(_cyan),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: compact ? 36 : 56,
                    color: _cyan,
                  ),
                  SizedBox(height: compact ? 6 : 12),
                  Text(
                    _tx.s('objective'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: compact ? 14 : 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  Text(
                    _tx.s('board_desc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _rt_Lab.textMuted, fontSize: 13),
                  ),
                  SizedBox(height: compact ? 12 : 20),
                  _rt_ActionButton(
                    label: _tx.s('board_btn'),
                    icon: Icons.play_arrow,
                    color: _cyanDark,
                    onPressed: _begin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- sidebar

  Widget _sidebar() {
    final steps = _tx.list('steps');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('mission_obj'),
          desc: _tx.s('objective'),
          accent: _cyanDark,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _tx.s('concept_exp').toUpperCase(),
                style: TextStyle(
                  color: _rt_Lab.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < steps.length; i++)
                _stepTile(i + 1, steps[i] as Map),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepTile(int n, Map data) {
    final current = n == _step || (_step == 0 && n == 1);
    final done = _step > n;
    final open = current || _openSteps.contains(n);
    Widget detail(String label, Object? text, Color color) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          TextSpan(text: '$text'),
        ],
      ),
      style: TextStyle(color: _rt_Lab.text, fontSize: 12, height: 1.4),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: current
            ? _rt_Lab.tinted(const Color(0xFFECFEFF), _cyan)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? _cyan
              : (done ? _cyan.withValues(alpha: 0.5) : _rt_Lab.border),
          width: current ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: done
                ? () {
                    _rt_playSfx(_rt_Sfx.tap);
                    setState(() {
                      if (!_openSteps.remove(n)) _openSteps.add(n);
                    });
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: current || done ? _cyan : _rt_Lab.overlay,
                    ),
                    child: Text(
                      done ? '✓' : '$n',
                      style: TextStyle(
                        color: current || done
                            ? Colors.white
                            : _rt_Lab.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_tx.s('exploration')} $n: ${data['concept']}',
                      style: TextStyle(
                        color: current || done
                            ? _rt_Lab.text
                            : _rt_Lab.textFaint,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (done)
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: _rt_Lab.textMuted,
                    ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  detail(_tx.s('action'), data['action'], _cyanDark),
                  const SizedBox(height: 6),
                  detail(
                    _tx.s('observation'),
                    data['observation'],
                    _orangeDark,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Button that fires when the finger is lifted inside it, like a browser
/// click. A normal Flutter tap is cancelled once the finger rolls past the
/// phone's ~8 dp touch slop, which made a child's slightly wobbly press on
/// "Taste Test" do nothing.
class _PressButton extends StatefulWidget {
  const _PressButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<_PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<_PressButton> {
  int? _pointer;

  void _release(PointerEvent e, {required bool inside}) {
    if (e.pointer != _pointer) return;
    setState(() => _pointer = null);
    final box = context.findRenderObject() as RenderBox?;
    if (inside && box != null && box.size.contains(e.localPosition)) {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Listener(
      onPointerDown: enabled && _pointer == null
          ? (e) => setState(() => _pointer = e.pointer)
          : null,
      onPointerUp: (e) => _release(e, inside: true),
      onPointerCancel: (e) => _release(e, inside: false),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: AnimatedScale(
          scale: _pointer != null ? 0.95 : 1,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
