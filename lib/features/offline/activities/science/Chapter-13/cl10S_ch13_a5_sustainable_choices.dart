// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 13.5: Sustainable Choices
// Converted from Cl10S-Ch13-A5-SustainableChoices.html (three.js -> mini3d).
//
// Four guided steps: audit a shopping basket and tap the non-biodegradable
// packaging (plastic bottle, chips packet) apart from the biodegradable
// apple, test plastic cups, kulhads and paper cups (waste piles vs. lost
// fertile topsoil), drop a plastic bag and a cloth bag into a street drain
// (clogging and waterlogging vs. decomposition), and build an eco-friendly
// school kit by choosing the reusable item from each pair (the 3Rs).

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

  /// THREE.SphereGeometry; [thetaLength] < π gives a dome.
  factory _rt_Geometry3D.sphere(
    double radius, {
    int widthSegments = 20,
    int heightSegments = 14,
    double thetaLength = math.pi,
  }) {
    final verts = <_rt_V3>[];
    final grid = <List<int>>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      final row = <int>[];
      final theta = iy / heightSegments * thetaLength;
      for (var ix = 0; ix <= widthSegments; ix++) {
        final phi = ix / widthSegments * math.pi * 2;
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
        final theta1 = (iy + 1) / heightSegments * thetaLength;
        if (iy == 0) {
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

  /// THREE.CircleGeometry(radius, segments), XY plane.
  factory _rt_Geometry3D.circle(double radius, {int segments = 32}) {
    final verts = <_rt_V3>[
      for (var i = 0; i < segments; i++)
        _rt_V3(
          radius * math.cos(i / segments * math.pi * 2),
          radius * math.sin(i / segments * math.pi * 2),
          0,
        ),
    ];
    return _rt_Geometry3D(verts, [List.generate(verts.length, (i) => i)]);
  }

  /// THREE.RingGeometry(innerRadius, outerRadius, segments), XY plane.
  factory _rt_Geometry3D.ring(
    double innerRadius,
    double outerRadius, {
    int segments = 32,
  }) {
    final verts = <_rt_V3>[];
    for (var i = 0; i <= segments; i++) {
      final th = i / segments * math.pi * 2;
      final c = math.cos(th), s = math.sin(th);
      verts.add(_rt_V3(outerRadius * c, outerRadius * s, 0)); // 2i
      verts.add(_rt_V3(innerRadius * c, innerRadius * s, 0)); // 2i+1
    }
    final faces = <List<int>>[];
    for (var i = 0; i < segments; i++) {
      faces.add([2 * i, 2 * (i + 1), 2 * (i + 1) + 1, 2 * i + 1]);
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
    this.doubleSided = false,
    this.shininess = 0.0,
    this.metalness = 0.0,
  });

  /// Base colour (THREE `color`).
  Color color;

  /// 0..1 (THREE `opacity` with `transparent: true`).
  double opacity;

  /// MeshBasicMaterial: ignores lights.
  bool unlit = false;

  /// THREE.DoubleSide.
  bool doubleSided;

  /// Glow colour added regardless of lighting.
  Color? emissive;
  double emissiveIntensity = 1.0;

  /// 0..1 highlight strength (Phong/Standard shine; also sphere gloss).
  double shininess;

  /// 0..1 (MeshStandardMaterial `metalness`): darkens diffuse lighting.
  double metalness;

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

/// Smooth sphere drawn as a shaded disc (fast and perfectly round). Use
/// `_rt_Mesh3D(_rt_Geometry3D.sphere(...))` for partial spheres.
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
  _rt_Label3D(
    this.text, {
    super.position,
    this.worldHeight = 1.0,
    this.background,
  });

  String text;

  /// Text height in world units (scales with distance like a sprite).
  double worldHeight;

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
    this.onTap,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
  final void Function(_rt_SceneEvent e)? onTap;
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
    'headerTitle': 'Sustainable Choices',
    'headerSubtitle': 'Class 10: Our Environment',
    'intro': {
      'title': 'Our Environment - Sustainable Choices',
      'subtitle': 'Class 10 • Our Environment',
      'footnote': 'Biodegradable • Kulhads & Paper Cups • The 3Rs',
    },
    'tabs': {'explore': 'Exploration'},
    'mission_obj': 'Mission Objective',
    'objective':
        'Identify non-biodegradable packaging, evaluate cup materials, test bag hazards, and build an eco-friendly lifestyle.',
    'board_desc':
        "Every choice we make impacts the environment. Let's audit our waste and explore better alternatives for a sustainable future.",
    'board_btn': 'Start Audit',
    'concept_exp': 'Exploration Steps',
    'exploration': 'Step',
    'action': 'Action',
    'observation': 'Observation',
    'curr_obj': 'Current Task',
    'hud': [
      'TAP the Plastic Bottle and the Chips Packet to identify the non-biodegradable waste.',
      'TEST each cup below to see the environmental impact of its material.',
      'DROP each bag into the street drain to see what happens to it.',
      'PICK the reusable (eco-friendly) item from each pair, then tap Complete Lifestyle.',
    ],
    'steps': [
      {
        'concept': 'The Packaging Audit',
        'action': 'Tap the non-biodegradable packaging items in the basket.',
        'observation':
            'Changes in packaging have made much of our waste non-biodegradable.',
      },
      {
        'concept': 'The Cup Dilemma',
        'action': 'Test the Plastic Cup, the Kulhad and the Paper Cup.',
        'observation':
            'Plastic cups pile up as waste for years. Making kulhads on a large scale destroys fertile topsoil. Disposable paper cups are biodegradable and the better alternative.',
      },
      {
        'concept': 'The Bag Duel',
        'action': 'Drop the plastic bag and the cloth bag into the drain.',
        'observation':
            'Plastic bags clog drains, cause waterlogging and harm stray animals that eat them. Cloth bags are reused many times and are biodegradable.',
      },
      {
        'concept': 'Eco-Lifestyle Builder',
        'action': 'Choose the reusable item from each pair.',
        'observation':
            'Reusable items apply the 3Rs (Reduce, Reuse, Recycle) and cut down the waste we produce.',
      },
    ],
    // 3D labels
    'lbl_bottle': 'Plastic Bottle',
    'lbl_packet': 'Chips Packet',
    'lbl_apple': 'Fresh Apple',
    'lbl_nonbio': 'Non-biodegradable',
    'lbl_bio': 'Biodegradable',
    'lbl_pcup': 'Plastic Cup',
    'lbl_kulhad': 'Kulhad',
    'lbl_paper': 'Paper Cup',
    'lbl_topsoil': 'Fertile Topsoil',
    'lbl_topsoil_lost': 'Topsoil Lost!',
    'lbl_waste': 'Waste Pile (lasts for years)',
    'lbl_drain': 'Street Drain',
    'lbl_water': 'Waterlogging!',
    'lbl_decompose': 'Microbes at work…',
    'lbl_slot0': 'Lunch',
    'lbl_slot1': 'Water',
    'lbl_slot2': 'Carry Bag',
    // controls
    'btn_bottle': 'Plastic Bottle',
    'btn_packet': 'Chips Packet',
    'btn_apple': 'Fresh Apple',
    'btn_plastic': 'Plastic Cup',
    'btn_kulhad': 'Kulhad (Clay)',
    'btn_paper': 'Paper Cup',
    'lbl_plastic_bag': 'Plastic Bag',
    'lbl_cloth_bag': 'Cloth Bag',
    'lifestyle_title': 'Choose your daily items for school:',
    'btn_foil': 'Aluminium Foil',
    'btn_box': 'Reusable Box',
    'btn_pbottle': 'Plastic Bottle',
    'btn_sbottle': 'Steel Flask',
    'btn_pbag': 'Polythene',
    'btn_jbag': 'Jute Bag',
    'btn_submit': 'Complete Lifestyle',
    'btn_restart': 'Restart Virtual Lab',
    'topsoil': 'Topsoil',
    'audit_title': 'Packaging Audit',
    'audit_found': 'Non-biodegradable found: {n}/2',
    'audit_hint': 'Tap an item in the basket, or use the buttons.',
    'cup_title': 'The Cup Dilemma',
    'cup_tested': 'Cups tested: {n}/3',
    'bag_title': 'The Bag Duel',
    'drain_idle': 'Drain: water flowing',
    'drain_block': 'Drain: blocked!',
    'drain_flow': 'Drain: flowing again',
    'bag_tested': 'Bags tested: {n}/2',
    'tool_labels': 'Toggle Labels',
    'tool_lock': 'Lock / Unlock Camera',
    // toasts
    'msg_found': 'Identified: non-biodegradable plastic packaging.',
    'msg_found_again': 'Already identified. Find the other one!',
    'msg_apple':
        'Fresh apple: biodegradable (natural, no packaging). Microbes can break it down.',
    'msg_packaging':
        'Changes in packaging have resulted in much of our waste becoming non-biodegradable.',
    'msg_plastic_cup':
        'Plastic cup: non-biodegradable. It persists for years and builds up huge waste piles.',
    'msg_kulhad':
        'Warning! Making kulhads on a large scale strips away fertile topsoil. Agriculture suffers.',
    'msg_paper':
        'Paper cups are biodegradable and do not destroy topsoil. They are the better alternative.',
    'msg_plastic_bag':
        'The plastic bag clogs the drain and causes waterlogging. Stray animals that eat plastic bags can die.',
    'msg_cloth_bag':
        'A cloth bag is reused many times. If thrown away, microbes break it down, so it does not block the drain for good.',
    'err_pick_all': 'Pick one item from every pair first.',
    'err_life':
        'Try again: {n} of 3 choices are reusable. Think about the 3Rs: Reduce, Reuse, Recycle.',
    'msg_life_ok': 'Great choices! Your school kit now follows the 3Rs.',
    // log
    'data_log': 'Observation Log',
    'btn_clear': 'Clear',
    'th_action': 'Action',
    'th_result': 'Result',
    'no_data': 'No observations yet.',
    'log_apple_act': 'Checked Apple',
    'log_apple_res': 'Biodegradable',
    'log_audit_act': 'Audited Cart',
    'log_audit_res': 'Found non-biodegradable waste',
    'log_pcup_act': 'Plastic Cup',
    'log_pcup_res': 'Non-biodegradable, piles up',
    'log_kulhad_act': 'Kulhad',
    'log_kulhad_res': 'Fertile topsoil lost',
    'log_paper_act': 'Paper Cup',
    'log_paper_res': 'Biodegradable, better choice',
    'log_pbag_act': 'Plastic Bag',
    'log_pbag_res': 'Blocks the drain',
    'log_cbag_act': 'Cloth Bag',
    'log_cbag_res': 'Reusable, decomposes',
    'log_life_act': 'Built Lifestyle',
    'log_life_res': 'Applied 3Rs',
    'summary': {
      'title': 'Audit Complete!',
      'msg':
          'You have successfully applied the 3Rs and learned how daily choices impact our environment.\n\n'
          '• Plastic packaging is non-biodegradable and piles up.\n'
          '• Large-scale kulhad making strips fertile topsoil; paper cups are biodegradable.\n'
          '• Plastic bags clog drains and harm animals; cloth bags are reusable.\n'
          '• Reduce, Reuse, Recycle: choose reusable items.',
    },
  },
  'hi': {
    'headerTitle': 'संधारणीय विकल्प',
    'headerSubtitle': 'कक्षा 10: हमारा पर्यावरण',
    'intro': {
      'title': 'हमारा पर्यावरण - संधारणीय विकल्प',
      'subtitle': 'कक्षा 10 • हमारा पर्यावरण',
      'footnote': 'जैव निम्नीकरणीय • कुल्हड़ और कागज़ के कप • 3R',
    },
    'tabs': {'explore': 'अन्वेषण'},
    'mission_obj': 'मिशन का उद्देश्य',
    'objective':
        'गैर-बायोडिग्रेडेबल पैकेजिंग की पहचान करें, कप सामग्री का मूल्यांकन करें, बैग के खतरों का परीक्षण करें और एक इको-फ्रेंडली जीवन शैली बनाएं।',
    'board_desc':
        'हमारा हर विकल्प पर्यावरण को प्रभावित करता है। आइए अपने कचरे का ऑडिट करें और एक संधारणीय भविष्य के लिए बेहतर विकल्पों का पता लगाएं।',
    'board_btn': 'ऑडिट शुरू करें',
    'concept_exp': 'अन्वेषण चरण',
    'exploration': 'चरण',
    'action': 'कार्रवाई',
    'observation': 'अवलोकन',
    'curr_obj': 'वर्तमान कार्य',
    'hud': [
      'गैर-बायोडिग्रेडेबल कचरे की पहचान करने के लिए प्लास्टिक की बोतल और चिप्स पैकेट पर टैप करें।',
      'प्रत्येक कप सामग्री के पर्यावरणीय प्रभाव का मूल्यांकन करने के लिए नीचे दिए गए बटनों पर टैप करें।',
      'यह जांचने के लिए कि सड़क की नाली में जाने पर क्या होता है, प्रत्येक बैग पर टैप करें।',
      "हर जोड़ी में से पुन: प्रयोज्य (इको-फ्रेंडली) वस्तु चुनें, फिर 'जीवन शैली पूर्ण करें' पर टैप करें।",
    ],
    'steps': [
      {
        'concept': 'पैकेजिंग ऑडिट',
        'action': 'टोकरी में गैर-बायोडिग्रेडेबल पैकेजिंग आइटम पर टैप करें।',
        'observation': 'पैकेजिंग में बदलाव से गैर-बायोडिग्रेडेबल कचरा बढ़ा है।',
      },
      {
        'concept': 'कप की दुविधा',
        'action': 'प्लास्टिक कप, कुल्हड़ और कागज़ के कप का परीक्षण करें।',
        'observation':
            'प्लास्टिक के कप वर्षों तक कचरे के ढेर बनाते हैं। बड़े पैमाने पर कुल्हड़ बनाने से उपजाऊ ऊपरी मिट्टी नष्ट होती है। डिस्पोजेबल कागज़ के कप बायोडिग्रेडेबल हैं और बेहतर विकल्प हैं।',
      },
      {
        'concept': 'बैग द्वंद्व',
        'action': 'प्लास्टिक बैग और कपड़े के बैग को नाली में डालें।',
        'observation':
            'प्लास्टिक बैग नालियों को रोकते हैं, जलभराव करते हैं और उन्हें खाने वाले आवारा जानवरों को नुकसान पहुंचाते हैं। कपड़े के बैग कई बार दोबारा उपयोग होते हैं और बायोडिग्रेडेबल हैं।',
      },
      {
        'concept': 'इको-लाइफस्टाइल',
        'action': 'हर जोड़ी में से पुन: प्रयोज्य वस्तु चुनें।',
        'observation':
            'पुन: प्रयोज्य वस्तुएं 3R (कम करें, पुन: उपयोग करें, पुनर्चक्रण करें) लागू करती हैं और हमारा कचरा घटाती हैं।',
      },
    ],
    'lbl_bottle': 'प्लास्टिक की बोतल',
    'lbl_packet': 'चिप्स पैकेट',
    'lbl_apple': 'ताज़ा सेब',
    'lbl_nonbio': 'गैर-बायोडिग्रेडेबल',
    'lbl_bio': 'बायोडिग्रेडेबल',
    'lbl_pcup': 'प्लास्टिक कप',
    'lbl_kulhad': 'कुल्हड़',
    'lbl_paper': 'कागज़ कप',
    'lbl_topsoil': 'उपजाऊ ऊपरी मिट्टी',
    'lbl_topsoil_lost': 'ऊपरी मिट्टी नष्ट!',
    'lbl_waste': 'कचरे का ढेर (वर्षों तक)',
    'lbl_drain': 'सड़क की नाली',
    'lbl_water': 'जलभराव!',
    'lbl_decompose': 'सूक्ष्मजीव काम पर…',
    'lbl_slot0': 'दोपहर का भोजन',
    'lbl_slot1': 'पानी',
    'lbl_slot2': 'थैला',
    'btn_bottle': 'प्लास्टिक की बोतल',
    'btn_packet': 'चिप्स पैकेट',
    'btn_apple': 'ताज़ा सेब',
    'btn_plastic': 'प्लास्टिक कप',
    'btn_kulhad': 'कुल्हड़',
    'btn_paper': 'कागज कप',
    'lbl_plastic_bag': 'प्लास्टिक बैग',
    'lbl_cloth_bag': 'कपड़े का बैग',
    'lifestyle_title': 'स्कूल के लिए अपने दैनिक आइटम चुनें:',
    'btn_foil': 'एल्युमिनियम फॉयल',
    'btn_box': 'पुन: प्रयोज्य बॉक्स',
    'btn_pbottle': 'प्लास्टिक की बोतल',
    'btn_sbottle': 'स्टील फ्लास्क',
    'btn_pbag': 'पॉलिथीन',
    'btn_jbag': 'जूट बैग',
    'btn_submit': 'जीवन शैली पूर्ण करें',
    'btn_restart': 'वर्चुअल लैब पुनरारंभ करें',
    'topsoil': 'ऊपरी मिट्टी',
    'audit_title': 'पैकेजिंग ऑडिट',
    'audit_found': 'गैर-बायोडिग्रेडेबल मिले: {n}/2',
    'audit_hint': 'टोकरी में किसी वस्तु पर या बटनों पर टैप करें।',
    'cup_title': 'कप की दुविधा',
    'cup_tested': 'परखे गए कप: {n}/3',
    'bag_title': 'बैग द्वंद्व',
    'drain_idle': 'नाली: पानी बह रहा है',
    'drain_block': 'नाली: बंद!',
    'drain_flow': 'नाली: फिर से बह रही है',
    'bag_tested': 'परखे गए बैग: {n}/2',
    'tool_labels': 'लेबल दिखाएँ/छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक',
    'msg_found': 'पहचाना गया: गैर-बायोडिग्रेडेबल प्लास्टिक पैकेजिंग।',
    'msg_found_again': 'यह पहले ही पहचाना जा चुका है। दूसरा खोजें!',
    'msg_apple':
        'ताज़ा सेब: बायोडिग्रेडेबल (प्राकृतिक, बिना पैकेजिंग)। सूक्ष्मजीव इसे विघटित कर सकते हैं।',
    'msg_packaging':
        'पैकेजिंग में बदलाव के कारण हमारा अधिकांश कचरा गैर-बायोडिग्रेडेबल हो गया है।',
    'msg_plastic_cup':
        'प्लास्टिक कप: गैर-बायोडिग्रेडेबल। यह वर्षों तक बना रहता है और कचरे के बड़े ढेर बनाता है।',
    'msg_kulhad':
        'चेतावनी! बड़े पैमाने पर कुल्हड़ बनाने से उपजाऊ ऊपरी मिट्टी नष्ट होती है। कृषि को नुकसान होता है।',
    'msg_paper':
        'कागज़ के कप बायोडिग्रेडेबल हैं और ऊपरी मिट्टी को नष्ट नहीं करते। ये बेहतर विकल्प हैं।',
    'msg_plastic_bag':
        'प्लास्टिक बैग नाली को रोक देता है और जलभराव होता है। प्लास्टिक बैग खाने वाले आवारा जानवर मर सकते हैं।',
    'msg_cloth_bag':
        'कपड़े का बैग कई बार दोबारा उपयोग होता है। फेंके जाने पर सूक्ष्मजीव इसे विघटित कर देते हैं, इसलिए यह नाली को हमेशा के लिए नहीं रोकता।',
    'err_pick_all': 'पहले हर जोड़ी में से एक वस्तु चुनें।',
    'err_life':
        'फिर से प्रयास करें: 3 में से {n} विकल्प पुन: प्रयोज्य हैं। 3R के बारे में सोचें: कम करें, पुन: उपयोग करें, पुनर्चक्रण करें।',
    'msg_life_ok': 'बढ़िया विकल्प! आपकी स्कूल किट अब 3R का पालन करती है।',
    'data_log': 'अवलोकन लॉग',
    'btn_clear': 'साफ़ करें',
    'th_action': 'कार्रवाई',
    'th_result': 'परिणाम',
    'no_data': 'अभी तक कोई अवलोकन नहीं।',
    'log_apple_act': 'सेब की जाँच',
    'log_apple_res': 'बायोडिग्रेडेबल',
    'log_audit_act': 'कार्ट का ऑडिट किया',
    'log_audit_res': 'गैर-बायोडिग्रेडेबल कचरा मिला',
    'log_pcup_act': 'प्लास्टिक कप',
    'log_pcup_res': 'गैर-बायोडिग्रेडेबल, ढेर बनता है',
    'log_kulhad_act': 'कुल्हड़',
    'log_kulhad_res': 'उपजाऊ मिट्टी नष्ट',
    'log_paper_act': 'कागज़ कप',
    'log_paper_res': 'बायोडिग्रेडेबल, बेहतर विकल्प',
    'log_pbag_act': 'प्लास्टिक बैग',
    'log_pbag_res': 'नाली को रोकता है',
    'log_cbag_act': 'कपड़े का बैग',
    'log_cbag_res': 'पुन: प्रयोज्य, विघटित होता है',
    'log_life_act': 'जीवन शैली बनाई',
    'log_life_res': '3R लागू किया',
    'summary': {
      'title': 'ऑडिट पूरा हुआ!',
      'msg':
          'आपने सफलतापूर्वक 3R लागू किया है और सीखा है कि दैनिक विकल्प हमारे पर्यावरण को कैसे प्रभावित करते हैं।\n\n'
          '• प्लास्टिक पैकेजिंग गैर-बायोडिग्रेडेबल है और इसका ढेर बढ़ता है।\n'
          '• बड़े पैमाने पर कुल्हड़ बनाने से उपजाऊ ऊपरी मिट्टी नष्ट होती है; कागज़ के कप बायोडिग्रेडेबल हैं।\n'
          '• प्लास्टिक बैग नालियाँ रोकते हैं और जानवरों को नुकसान पहुँचाते हैं; कपड़े के बैग पुन: प्रयोज्य हैं।\n'
          '• कम करें, पुन: उपयोग करें, पुनर्चक्रण करें: पुन: प्रयोज्य वस्तुएँ चुनें।',
    },
  },
});

const _green = Color(0xFF10B981);
const _greenDark = Color(0xFF047857);
const _emerald = Color(0xFF059669);
const _red = Color(0xFFEF4444);
const _amber = Color(0xFFF59E0B);
const _blue = Color(0xFF3B82F6);
const _brown = Color(0xFFB45309);
const _labelBg = Color(0xD90F172A);

const _lastStep = 4;

/// Step 1 basket items: the two non-biodegradable targets and the apple.
const _auditItems = ['bottle', 'packet', 'apple'];

/// Step 2 cups and step 3 bags, in button order.
const _cupIds = ['plastic', 'kulhad', 'paper'];
const _bagIds = ['plastic', 'cloth'];

/// Step 4 pairs: (wasteful, reusable). The second item of each is correct.
const _pairs = [('foil', 'box'), ('pbottle', 'sbottle'), ('pbag', 'jbag')];

/// Topsoil left after the kulhad test (the HTML meter drops to 30 %).
const _soilAfterKulhad = 0.3;

/// Bag drop: falls from this height onto the grate (bounce-out, 0.6 s).
const _dropFrom = 4.0, _dropTime = 0.6;

/// Cloth bag: starts decomposing after it lands, gone after this long.
const _rotStart = 1.2, _rotTime = 2.4;

double _bounceOut(double t) {
  const n1 = 7.5625, d1 = 2.75;
  if (t < 1 / d1) return n1 * t * t;
  if (t < 2 / d1) {
    t -= 1.5 / d1;
    return n1 * t * t + 0.75;
  }
  if (t < 2.5 / d1) {
    t -= 2.25 / d1;
    return n1 * t * t + 0.9375;
  }
  t -= 2.625 / d1;
  return n1 * t * t + 0.984375;
}

double _backOut(double t) {
  const c1 = 1.70158, c3 = c1 + 1;
  final u = t - 1;
  return 1 + c3 * u * u * u + c1 * u * u;
}

class Cl10SCh13A5SustainableChoicesPage extends StatefulWidget {
  const Cl10SCh13A5SustainableChoicesPage({super.key});

  @override
  State<Cl10SCh13A5SustainableChoicesPage> createState() => _EcoState();
}

class _EcoState extends State<Cl10SCh13A5SustainableChoicesPage> {
  final _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E293B), Color(0xFF020617)],
  );
  final _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 5, 12))
    ..minDistance = 4
    ..maxDistance = 30
    ..maxPolarAngle = math.pi / 2 - 0.05;
  final _viewCtrl = _rt_Scene3DController();
  final _shell = _rt_ShellController();
  final _rng = math.Random(13);

  // One station per step.
  final _cart = _rt_Node3D(name: 'cart');
  final _cupStage = _rt_Node3D(name: 'cups');
  final _drain = _rt_Node3D(name: 'drain');
  final _desk = _rt_Node3D(name: 'desk');

  // Step 1: the shopping basket.
  final Map<String, _rt_Node3D> _auditNodes = {};
  final Map<String, List<_rt_Material3D>> _auditMats = {};
  final Map<String, _rt_Mesh3D> _auditRings = {};
  final Map<String, _rt_Label3D> _auditLabels = {};

  // Step 2: the cups and the field of topsoil behind them.
  final Map<String, _rt_Node3D> _cupNodes = {};
  final Map<String, double> _cupScale = {for (final c in _cupIds) c: 1.0};
  late final _rt_Material3D _paperMat, _cropMat;
  late final _rt_Node3D _wastePile, _topsoil, _cropRow;
  late final _rt_Label3D _soilLabel, _wasteLabel;
  double _soilShown = 1, _wasteShown = 0;

  // Step 3: the street drain.
  late final _rt_Points3D _water, _microbes;
  final List<double> _waterVel = [];
  final List<_rt_V3> _microbeBase = [];
  late final _rt_Mesh3D _plasticBag, _puddle;
  late final _rt_Node3D _clothBag;
  late final _rt_Material3D _clothMat;
  late final _rt_Label3D _waterLabel, _rotLabel;
  double _puddleShown = 0;
  double _bagT = 0; // seconds since the current bag was dropped
  double _rotK = 0; // cloth bag decomposition 0..1

  // Step 4: the school desk.
  final Map<String, _rt_Node3D> _lifeNodes = {};
  final Map<String, double> _lifePop = {};
  final List<_rt_Label3D> _slotLabels = [];
  final List<_rt_Material3D> _slotMats = [];

  /// Labels whose text is a fixed translation key.
  final List<(_rt_Label3D, String)> _labels = [];

  int _step = 0;
  bool _boardVisible = false;
  bool _camLocked = true;
  bool _labelsVisible = true;
  bool _compactView = false; // short phone; refreshed by every build
  Size _canvasSize = Size.zero;
  double _clock = 0;
  bool _busy = false; // the step is finishing (HTML isTransitioning)

  final Set<String> _found = {};
  bool _appleChecked = false;
  final Set<String> _cupsTested = {};
  String? _activeCup;
  final Set<String> _bagsTested = {};
  String? _activeBag;
  final List<String?> _picks = [null, null, null];

  bool _logShown = false;
  bool? _logOpen; // null: open on large screens, collapsed on phones
  final List<(String, String)> _log = [];
  final Set<int> _openSteps = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScene();
    _syncScene();
    _frame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _viewCtrl.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------------------------------------------------------- scene

  _rt_Material3D _mat(
    Color c, {
    double opacity = 1,
    double metal = 0,
    double shine = 0,
    bool both = false,
  }) => _rt_Material3D(
    color: c,
    opacity: opacity,
    metalness: metal,
    shininess: shine,
    doubleSided: both,
  );

  _rt_Mesh3D _box(
    double w,
    double h,
    double d,
    _rt_Material3D m, [
    double x = 0,
    double y = 0,
    double z = 0,
  ]) => _rt_Mesh3D(_rt_Geometry3D.box(w, h, d), m)..position.set(x, y, z);

  _rt_Mesh3D _cyl(
    double rt,
    double rb,
    double h,
    _rt_Material3D m, {
    double y = 0,
    int seg = 20,
    bool open = false,
  }) => _rt_Mesh3D(
    _rt_Geometry3D.cylinder(rt, rb, h, segments: seg, openEnded: open),
    m,
  )..position.y = y;

  /// Flat ring lying on the XZ plane (selection marker).
  _rt_Mesh3D _flatRing(double r0, double r1, _rt_Material3D m) =>
      _rt_Mesh3D(_rt_Geometry3D.ring(r0, r1, segments: 36), m)
        ..rotation.x = -math.pi / 2
        ..pickable = false;

  _rt_Label3D _label(
    String key,
    double x,
    double y,
    double z, {
    bool pickable = false,
  }) {
    // The HTML text sprites are 0.45 units tall; on screen a fixed pixel
    // size keeps them readable on phones.
    final l =
        _rt_Label3D(
            '',
            position: _rt_V3(x, y, z),
            worldHeight: 0.45,
            background: _labelBg,
          )
          ..pixelHeight = 12
          ..pickable = pickable;
    if (key.isNotEmpty) _labels.add((l, key));
    return l;
  }

  /// Flat disc on the XZ plane at height [y] (drink surface, cup bottom).
  _rt_Mesh3D _disc(double r, double y, _rt_Material3D m) =>
      _rt_Mesh3D(_rt_Geometry3D.circle(r, segments: 22), m)
        ..rotation.x = -math.pi / 2
        ..position.y = y
        ..pickable = false;

  void _initScene() {
    // The HTML lights: a hemisphere sky light and a directional key light.
    _scene.setLights([
      _rt_Light3D.hemisphere(intensity: 0.8),
      _rt_Light3D.directional(
        _rt_V3(5, 10, 5),
        color: Colors.white,
        intensity: 0.8,
      ),
    ]);
    _scene
      ..add(_cart)
      ..add(_cupStage)
      ..add(_drain)
      ..add(_desk);
    _buildCart();
    _buildCups();
    _buildDrain();
    _buildDesk();
  }

  void _buildCart() {
    final wood = _mat(const Color(0xFF8B4513));
    final counter = _mat(const Color(0xFF475569), metal: 0.3, shine: 0.2);
    _cart.addAll([
      _box(7, 0.3, 4.4, counter, 0, -0.25, 0)
        ..pickable = false
        ..depthBias = 20,
      _box(5, 0.2, 3, wood)..depthBias = 10,
      _box(5.2, 0.4, 0.2, wood, 0, 0.2, 1.5),
      _box(5.2, 0.4, 0.2, wood, 0, 0.2, -1.5),
      _box(0.2, 0.4, 3, wood, 2.5, 0.2, 0),
      _box(0.2, 0.4, 3, wood, -2.5, 0.2, 0),
    ]);

    // Plastic bottle (translucent body, white wrapper, blue cap).
    final bottleMat = _mat(const Color(0xFF22D3EE), opacity: 0.6, shine: 0.6);
    final wrapMat = _mat(Colors.white);
    final bottle = _rt_Node3D()..position.set(-1.5, 0.9, -0.2);
    bottle.addAll([
      _cyl(0.4, 0.4, 1.6, bottleMat, seg: 24),
      _cyl(0.17, 0.4, 0.3, bottleMat, y: 0.95, seg: 24),
      _cyl(0.15, 0.15, 0.2, _mat(const Color(0xFF1D4ED8)), y: 1.2),
      _cyl(0.41, 0.41, 0.6, wrapMat, seg: 24),
    ]);
    _addAuditItem('bottle', bottle, [bottleMat, wrapMat], 1.95, 0.75);

    // Chips packet: a metallic pillow pack, leaning back.
    final packMat = _mat(const Color(0xFFEF4444), metal: 0.3, shine: 0.5);
    final stripeMat = _mat(const Color(0xFFFACC15));
    final crimp = _mat(const Color(0xFFCBD5E1), metal: 0.6, shine: 0.6);
    final packet = _rt_Node3D()..position.set(1.5, 1.0, -0.2);
    final body = _rt_Node3D()..rotation.set(math.pi / 6, math.pi / 8, 0);
    body.addAll([
      _box(1.6, 2.0, 0.2, packMat),
      _box(1.62, 0.42, 0.22, stripeMat, 0, 0.3, 0),
      _box(1.7, 0.12, 0.14, crimp, 0, 1.0, 0),
      _box(1.7, 0.12, 0.14, crimp, 0, -1.0, 0),
    ]);
    packet.add(body);
    _addAuditItem('packet', packet, [packMat, stripeMat], 1.75, 0.95);

    // Fresh apple: no packaging at all.
    final appleMat = _mat(const Color(0xFF22C55E), shine: 0.4);
    final apple = _rt_Node3D()..position.set(0, 0.6, 0.8);
    apple.addAll([
      _rt_Sphere3D(0.5, appleMat),
      _cyl(0.025, 0.025, 0.22, _mat(const Color(0xFF4D2900)), y: 0.55),
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(0.12, widthSegments: 8, heightSegments: 6),
          _mat(const Color(0xFF15803D)),
        )
        ..position.set(0.13, 0.58, 0)
        ..scale.set(1, 0.25, 0.55),
    ]);
    _addAuditItem('apple', apple, [appleMat], 1.25, 0.65);
  }

  void _addAuditItem(
    String id,
    _rt_Node3D node,
    List<_rt_Material3D> glow,
    double labelY,
    double ringR,
  ) {
    final ringMat = _mat(
      id == 'apple' ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
      both: true,
    )..unlit = true;
    final ring = _flatRing(ringR, ringR + 0.14, ringMat)
      ..position.set(node.position.x, 0.12, node.position.z)
      ..visible = false;
    final label = _label('', 0, labelY, 0, pickable: true);
    node.add(label);
    _cart
      ..add(ring)
      ..add(node);
    _auditNodes[id] = node;
    _auditMats[id] = glow;
    _auditRings[id] = ring;
    _auditLabels[id] = label;
  }

  void _buildCups() {
    _cupStage.add(
      _cyl(
          4,
          4,
          0.2,
          _mat(const Color(0xFF94A3B8), metal: 0.6, shine: 0.3),
          seg: 40,
        )
        ..pickable = false
        ..depthBias = 20,
    );

    // A bed of fertile topsoil with young crops behind the cups.
    _cupStage.add(
      _box(5.2, 0.35, 1.2, _mat(const Color(0xFF9A7B4F)), 0, 0.275, -2.4)
        ..depthBias = 3,
    );
    _topsoil = _rt_Node3D()..position.set(0, 0.45, -2.4);
    _topsoil.add(
      _box(5.2, 0.4, 1.2, _mat(const Color(0xFF3F2A14)), 0, 0.2, 0)
        ..depthBias = 3,
    );
    _cupStage.add(_topsoil);
    _cropMat = _mat(const Color(0xFF16A34A), shine: 0.2);
    final stem = _mat(const Color(0xFF15803D));
    _cropRow = _rt_Node3D()..position.set(0, 0.85, -2.4);
    for (var i = 0; i < 7; i++) {
      final x = -2.1 + i * 0.7;
      _cropRow.add(
        _rt_Node3D()
          ..position.set(x, 0, i.isEven ? 0.25 : -0.2)
          ..addAll([
            _cyl(0.03, 0.04, 0.35, stem, y: 0.17, seg: 6),
            _rt_Sphere3D(0.17, _cropMat)..position.y = 0.4,
          ]),
      );
    }
    _cupStage.add(_cropRow);
    _soilLabel = _label('', 0, 1.75, -2.4);
    _cupStage.add(_soilLabel);

    // The three cups stand on the front of the platform. Each node sits at
    // the platform top so "testing" a cup scales it up from its base.
    // Open cups (drink inside), so their walls are double-sided.
    final plasticMat = _mat(
      const Color(0xFFEF4444),
      opacity: 0.6,
      shine: 0.6,
      both: true,
    );
    final plastic = _rt_Node3D()..position.set(-2, 0.1, 0.9);
    plastic.addAll([
      _cyl(0.4, 0.3, 1, plasticMat, y: 0.5, seg: 22, open: true),
      _disc(0.3, 0.3, _mat(const Color(0xFF78350F), opacity: 0.8)),
      _disc(0.38, 0.88, _mat(const Color(0xFF7F1D1D), opacity: 0.7)),
    ]);
    final kulhadMat = _mat(const Color(0xFFC2410C), both: true);
    final kulhad = _rt_Node3D()..position.set(0, 0.1, 0.9);
    kulhad.addAll([
      _cyl(0.45, 0.28, 0.8, kulhadMat, y: 0.4, seg: 22, open: true),
      _disc(0.28, 0.01, kulhadMat),
      _disc(0.42, 0.7, _mat(const Color(0xFFA16207))),
    ]);
    _paperMat = _mat(const Color(0xFFF8FAFC), both: true);
    final paper = _rt_Node3D()..position.set(2, 0.1, 0.9);
    paper.addAll([
      _cyl(0.4, 0.3, 1, _paperMat, y: 0.5, seg: 22, open: true),
      _cyl(
        0.38,
        0.355,
        0.25,
        _mat(const Color(0xFF16A34A), both: true),
        y: 0.5,
        seg: 22,
        open: true,
      ),
      _flatRing(0.37, 0.44, _paperMat)..position.y = 1.0,
      _disc(0.3, 0.01, _paperMat),
      _disc(0.37, 0.88, _mat(const Color(0xFF78350F))),
    ]);
    final cupLabels = {
      'plastic': ('lbl_pcup', 1.65),
      'kulhad': ('lbl_kulhad', 1.45),
      'paper': ('lbl_paper', 1.65),
    };
    for (final (id, node) in [
      ('plastic', plastic),
      ('kulhad', kulhad),
      ('paper', paper),
    ]) {
      final (key, y) = cupLabels[id]!;
      node.add(_label(key, 0, y, 0));
      _cupNodes[id] = node;
      _cupStage.add(node);
    }

    // Non-biodegradable waste that piles up (shown after the plastic test).
    _wastePile = _rt_Node3D()..position.set(-1.8, 0.1, 2.4);
    final grey = _mat(const Color(0xFF64748B));
    _wastePile.add(_cyl(0, 0.8, 0.5, grey, y: 0.25, seg: 9));
    const junk = [
      (Color(0xFFEF4444), -0.35, 0.3, 0.35, 0.9),
      (Color(0xFF3B82F6), 0.3, 0.32, 0.2, -0.6),
      (Color(0xFFF8FAFC), 0.05, 0.5, -0.25, 1.4),
      (Color(0xFF22D3EE), -0.1, 0.42, -0.45, 0.3),
      (Color(0xFFFACC15), 0.45, 0.2, -0.3, 2.2),
    ];
    for (final (c, x, y, z, a) in junk) {
      _wastePile.add(
        _cyl(0.14, 0.1, 0.35, _mat(c, opacity: 0.85), seg: 10)
          ..position.set(x, y, z)
          ..rotation.set(a, a * 0.7, math.pi / 2),
      );
    }
    _wasteLabel = _label('lbl_waste', 0, 0.9, 0);
    _wastePile.add(_wasteLabel);
    _cupStage.add(_wastePile);
  }

  void _buildDrain() {
    final asphalt = _mat(const Color(0xFF374151));
    final kerb = _mat(const Color(0xFF9CA3AF));
    final wall = _mat(const Color(0xFF1F2937), both: true);
    final metal = _mat(const Color(0xFF334155), metal: 0.9, shine: 0.5);
    _drain.addAll([
      // Road around the drain opening (x and z within +-2 stay open).
      _box(2.6, 0.2, 6.4, asphalt, -3.3, -0.1, 0)..depthBias = 20,
      _box(2.6, 0.2, 6.4, asphalt, 3.3, -0.1, 0)..depthBias = 20,
      _box(4.0, 0.2, 1.2, asphalt, 0, -0.1, 2.6)..depthBias = 20,
      _box(4.0, 0.2, 1.2, asphalt, 0, -0.1, -2.6)..depthBias = 20,
      _box(9.2, 0.35, 0.4, kerb, 0, 0.075, -3.4)..depthBias = 15,
      for (final x in [-3.6, 3.6])
        _box(0.9, 0.02, 0.14, _mat(const Color(0xFFF8FAFC)), x, 0.01, 2.6)
          ..depthBias = 15,
      // The drain pit below the grate.
      _box(4.0, 1.5, 0.1, wall, 0, -0.75, -2.0)..depthBias = 30,
      _box(4.0, 1.5, 0.1, wall, 0, -0.75, 2.0)..depthBias = 30,
      _box(0.1, 1.5, 4.0, wall, -2.0, -0.75, 0)..depthBias = 30,
      _box(0.1, 1.5, 4.0, wall, 2.0, -0.75, 0)..depthBias = 30,
      _box(4.0, 0.1, 4.0, _mat(const Color(0xFF0B1120)), 0, -1.5, 0)
        ..depthBias = 30,
      // The grate.
      for (var i = 0; i < 7; i++)
        _box(0.1, 0.2, 3.8, metal, -1.5 + i * 0.5, -0.05, 0)..depthBias = 5,
      _box(4.0, 0.2, 0.2, metal, 0, -0.05, 1.9)..depthBias = 5,
      _box(4.0, 0.2, 0.2, metal, 0, -0.05, -1.9)..depthBias = 5,
      _box(0.2, 0.2, 4.0, metal, 1.9, -0.05, 0)..depthBias = 5,
      _box(0.2, 0.2, 4.0, metal, -1.9, -0.05, 0)..depthBias = 5,
    ]);
    for (final n in _drain.children) {
      n.pickable = false;
    }

    // Runoff water pouring through the grate.
    final pts = <_rt_V3>[];
    for (var i = 0; i < 140; i++) {
      pts.add(
        _rt_V3(
          (_rng.nextDouble() - 0.5) * 3,
          -1.4 + _rng.nextDouble() * 3.8,
          (_rng.nextDouble() - 0.5) * 3,
        ),
      );
      _waterVel.add(1.2 + _rng.nextDouble() * 2.4);
    }
    _water = _rt_Points3D(pts)
      ..color = const Color(0xFF3B82F6)
      ..size = 4
      ..opacity = 0.85
      ..sizeAttenuation = false
      ..pickable = false;
    _drain.add(_water);

    // Water standing on the road when the drain is blocked.
    _puddle =
        _box(
            9.0,
            0.04,
            6.2,
            _mat(const Color(0xFF3B82F6), opacity: 0.45, shine: 0.6),
          )
          ..pickable = false
          ..depthBias = 2
          ..visible = false;
    _drain.add(_puddle);

    // Plastic bag: a crumpled, see-through lump.
    _plasticBag =
        _rt_Mesh3D(
            _rt_Geometry3D.sphere(0.8, widthSegments: 7, heightSegments: 5),
            _mat(const Color(0xFFEEEEEE), opacity: 0.75, both: true),
          )
          ..scale.set(1.5, 0.6, 1.2)
          ..pickable = false
          ..visible = false;
    _drain.add(_plasticBag);

    // Cloth bag with two handles.
    _clothMat = _mat(const Color(0xFF8B5A2B));
    _clothBag = _rt_Node3D()..visible = false;
    _clothBag.addAll([
      _box(1.2, 1.2, 0.5, _clothMat, 0, 0.6, 0),
      for (final z in [0.15, -0.15])
        _rt_Mesh3D(
          _rt_Geometry3D.ring(0.24, 0.32, segments: 18),
          _clothMat..doubleSided = true,
        )..position.set(0, 1.2, z),
    ]);
    _drain.add(_clothBag);

    // Decomposers breaking the cloth bag down.
    for (var i = 0; i < 36; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final r = 0.4 + _rng.nextDouble() * 0.6;
      _microbeBase.add(
        _rt_V3(math.cos(a) * r, 0.1 + _rng.nextDouble() * 1.0, math.sin(a) * r),
      );
    }
    _microbes = _rt_Points3D([for (final b in _microbeBase) b.clone()])
      ..color = const Color(0xFFA3E635)
      ..size = 3.5
      ..sizeAttenuation = false
      ..pickable = false
      ..visible = false;
    _drain.add(_microbes);

    _drain.add(_label('lbl_drain', 0, 1.2, -2.6));
    _waterLabel = _label('lbl_water', 2.6, 0.9, 1.6);
    _rotLabel = _label('lbl_decompose', 0, 2.0, 0);
    _drain
      ..add(_waterLabel)
      ..add(_rotLabel);
    for (final l in [_waterLabel, _rotLabel]) {
      l.background = l == _waterLabel
          ? const Color(0xE01D4ED8)
          : const Color(0xE04D7C0F);
    }
  }

  void _buildDesk() {
    _desk.add(
      _box(7, 0.2, 4, _mat(const Color(0xFF4D2900)))
        ..pickable = false
        ..depthBias = 20,
    );
    const slotX = [-2.3, 0.0, 2.3];
    for (var i = 0; i < 3; i++) {
      final m = _mat(const Color(0xFF94A3B8), both: true)..unlit = true;
      _slotMats.add(m);
      _desk.add(_flatRing(0.78, 0.88, m)..position.set(slotX[i], 0.11, 0));
      final l = _label('', slotX[i], 2.25, 0);
      _slotLabels.add(l);
      _desk.add(l);
    }

    _rt_Node3D item(String id, int slot) {
      final n = _rt_Node3D()
        ..position.set(slotX[slot], 0.1, 0)
        ..visible = false;
      _lifeNodes[id] = n;
      _desk.add(n);
      return n;
    }

    final silver = _mat(const Color(0xFFE2E8F0), metal: 0.8, shine: 0.7);
    item('foil', 0).addAll([
      _cyl(0.42, 0.42, 1.4, silver, seg: 18)
        ..position.y = 0.42
        ..rotation.z = math.pi / 2,
      _box(1.4, 0.02, 0.8, silver, 0, 0.01, 0.75),
    ]);
    item('box', 0).addAll([
      _box(1.3, 0.5, 1.0, _mat(const Color(0xFF3B82F6), shine: 0.4), 0, 0.25),
      _box(1.36, 0.12, 1.06, _mat(const Color(0xFF1D4ED8)), 0, 0.56),
    ]);
    final pet = _mat(const Color(0xFF22D3EE), opacity: 0.6, shine: 0.6);
    item('pbottle', 1).addAll([
      _cyl(0.3, 0.3, 1.3, pet, y: 0.65, seg: 20),
      _cyl(0.13, 0.3, 0.25, pet, y: 1.425, seg: 20),
      _cyl(0.12, 0.12, 0.15, _mat(const Color(0xFF1D4ED8)), y: 1.62),
      _cyl(0.31, 0.31, 0.4, _mat(Colors.white), y: 0.6, seg: 20),
    ]);
    final steel = _mat(const Color(0xFF94A3B8), metal: 0.9, shine: 0.8);
    item('sbottle', 1).addAll([
      _cyl(0.35, 0.35, 1.4, steel, y: 0.7, seg: 20),
      _cyl(0.25, 0.35, 0.15, steel, y: 1.475, seg: 20),
      _cyl(0.26, 0.26, 0.25, _mat(const Color(0xFF334155)), y: 1.675),
    ]);
    final poly = _mat(Colors.white, opacity: 0.7, both: true);
    item('pbag', 2).addAll([
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(0.6, widthSegments: 8, heightSegments: 6),
          poly,
        )
        ..position.y = 0.3
        ..scale.set(1.1, 0.5, 1.0),
      for (final x in [-0.25, 0.25])
        _rt_Mesh3D(_rt_Geometry3D.ring(0.1, 0.16, segments: 12), poly)
          ..position.set(x, 0.66, 0),
    ]);
    final jute = _mat(_brown);
    item('jbag', 2).addAll([
      _box(1.2, 1.4, 0.45, jute, 0, 0.7),
      _box(1.22, 0.15, 0.47, _mat(const Color(0xFF92400E)), 0, 1.1),
      for (final z in [0.12, -0.12])
        _rt_Mesh3D(
          _rt_Geometry3D.ring(0.26, 0.33, segments: 18),
          _mat(_brown, both: true),
        )..position.set(0, 1.55, z),
    ]);
  }

  /// Visibility and step-driven state of every node (cheap: also runs every
  /// frame after the animations).
  void _syncScene() {
    final s = _step;
    _cart.visible = s <= 1;
    _cupStage.visible = s == 2;
    _drain.visible = s == 3;
    _desk.visible = s >= 4;

    for (final id in _auditItems) {
      _auditRings[id]!.visible = _isFound(id);
    }

    _wastePile
      ..visible = _wasteShown > 0.01
      ..scale.set(_wasteShown, _wasteShown, _wasteShown);
    _topsoil.scale.y = _soilShown;
    final health = ((_soilShown - _soilAfterKulhad) / (1 - _soilAfterKulhad))
        .clamp(0.0, 1.0);
    _cropRow.position.y = 0.45 + 0.4 * _soilShown;
    for (final c in _cropRow.children) {
      final k = 0.45 + 0.55 * health;
      c.scale.set(k, k, k);
    }
    _cropMat.color = Color.lerp(
      const Color(0xFFA16207),
      const Color(0xFF16A34A),
      health,
    )!;

    for (var i = 0; i < _pairs.length; i++) {
      final (a, b) = _pairs[i];
      for (final id in [a, b]) {
        final n = _lifeNodes[id]!;
        n.visible = _picks[i] == id;
        final k = _backOut(_lifePop[id] ?? 1);
        n.scale.set(k, k, k);
      }
      _slotMats[i].color = _picks[i] == null
          ? const Color(0xFF94A3B8)
          : const Color(0xFFF8FAFC);
    }

    for (final (l, _) in _labels) {
      l.visible = _labelsVisible;
    }
    for (final l in [..._auditLabels.values, ..._slotLabels, _soilLabel]) {
      l.visible = _labelsVisible;
    }
    _waterLabel.visible = _labelsVisible && _puddleShown > 0.5;
    _rotLabel.visible = _labelsVisible && _rotK > 0 && _rotK < 1;
  }

  /// Label texts for the current language and screen (run from build).
  void _syncLabels() {
    final px = _compactView ? 10.0 : 12.0;
    for (final (l, key) in _labels) {
      l
        ..text = _tx.s(key)
        ..pixelHeight = px;
    }
    for (final id in _auditItems) {
      final hit = _isFound(id);
      final name = _tx.s('lbl_$id');
      final kind = _tx.s(id == 'apple' ? 'lbl_bio' : 'lbl_nonbio');
      _auditLabels[id]!
        ..text = hit ? '$name\n$kind' : name
        ..pixelHeight = px
        ..background = !hit
            ? _labelBg
            : (id == 'apple'
                  ? const Color(0xE0047857)
                  : const Color(0xE0B91C1C));
    }
    final lost = _cupsTested.contains('kulhad');
    _soilLabel
      ..text = _tx.s(lost ? 'lbl_topsoil_lost' : 'lbl_topsoil')
      ..pixelHeight = px
      ..background = lost ? const Color(0xE0B91C1C) : const Color(0xE0065F46);
    for (var i = 0; i < _slotLabels.length; i++) {
      final pick = _picks[i];
      _slotLabels[i]
        ..text = pick == null ? _tx.s('lbl_slot$i') : _tx.s('btn_$pick')
        ..pixelHeight = px;
    }
  }

  bool _isFound(String id) =>
      id == 'apple' ? _appleChecked : _found.contains(id);

  // -------------------------------------------------------------- camera

  void _frame() {
    final (pos, target) = _viewFor();
    _camera.position.copy(pos);
    _camera.target.copy(target);
    _camera.zoom = 1;
    _camera.maxDistance = math.max(30.0, pos.distanceTo(target) * 1.6);
    _camera.saveHome();
  }

  /// Camera fitted to the free part of the canvas (below the HUD, above the
  /// bottom task bar, clear of the toolbar and the log) for this station.
  (_rt_V3, _rt_V3) _viewFor() {
    final size = _canvasSize.isEmpty ? const Size(980, 640) : _canvasSize;
    final compact = size.height < 480;
    // Points to keep in view. Labels are drawn at a fixed pixel size, so
    // they carry a half-size in pixels around their anchor.
    final lw = compact ? 50.0 : 62.0, lh = compact ? 14.0 : 17.0;
    final pts = <(_rt_V3, double, double)>[];
    void corners(double x, double y, double z) {
      for (final sx in [-x, x]) {
        for (final sz in [-z, z]) {
          pts.add((_rt_V3(sx, y, sz), 0, 0));
        }
      }
    }

    void label(double x, double y, double z) =>
        pts.add((_rt_V3(x, y, z), lw, lh));
    final double pitch;
    switch (_step) {
      case 0 || 1:
        pitch = 0.6;
        corners(3.5, -0.4, 2.2); // the counter under the basket
        label(-1.5, 2.85, -0.2);
        label(1.5, 2.75, -0.2);
        label(0, 1.85, 0.8);
      case 2:
        pitch = 0.8;
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi / 6;
          pts.add((_rt_V3(4 * math.cos(a), 0, 4 * math.sin(a)), 0, 0));
        }
        label(-2, 2.4, 0.9); // a tested cup grows 1.4x
        label(0, 2.1, 0.9);
        label(2, 2.4, 0.9);
        label(0, 1.75, -2.4);
        label(-1.8, 1.0, 2.4);
      case 3:
        pitch = 0.7;
        corners(4.6, 0, 3.2);
        corners(4.6, 0.25, 3.6);
        label(0, 1.2, -2.6);
        label(0, 2.0, 0);
        label(2.6, 0.9, 1.6);
      default:
        pitch = 0.6;
        corners(3.5, -0.1, 2.0);
        label(-2.3, 2.25, 0);
        label(2.3, 2.25, 0);
    }
    // Room for the log: a column on the right of large screens, the small
    // log button at the top-left of phones.
    final logRoom = _step >= 1
        ? (compact ? 52.0 : (size.width >= 760 ? 270.0 : 0.0))
        : 0.0;
    final bar = _step >= 1 && _step <= _lastStep;
    final top = compact ? 54.0 : (_step == 0 ? 40.0 : 100.0);
    final barH = compact
        ? (_step == 4 ? 114.0 : 84.0)
        : (_step == 4 ? 236.0 : 162.0);
    final bottom = size.height - (bar ? barH : 24.0);
    final left = 12.0 + (compact ? logRoom : 0);
    final rightEdge = size.width - 62 - (compact ? 0 : logRoom);
    final focal = size.height / 2 / math.tan(_rt_degToRad(_camera.fov) / 2);
    final dir = _rt_V3(0, math.sin(pitch), math.cos(pitch));
    final right = _rt_V3(1, 0, 0);
    final up = _rt_V3(0, math.cos(pitch), -math.sin(pitch));
    var target = _rt_V3(0, 0.6, 0);
    var dist = 12.0;
    // Perspective enlarges what is near the camera, so refine a few times.
    for (var i = 0; i < 10; i++) {
      var x0 = double.infinity, x1 = -double.infinity;
      var y0 = double.infinity, y1 = -double.infinity;
      for (final (p, px, py) in pts) {
        final q = p - target;
        final k = focal / math.max(0.5, dist - q.dot(dir));
        final sx = q.dot(right) * k, sy = -q.dot(up) * k;
        x0 = math.min(x0, sx - px);
        x1 = math.max(x1, sx + px);
        y0 = math.min(y0, sy - py);
        y1 = math.max(y1, sy + py);
      }
      final ppu = focal / dist;
      final bx = (x0 + x1) / 2 - ((left + rightEdge) / 2 - size.width / 2);
      final by = (y0 + y1) / 2 - ((top + bottom) / 2 - size.height / 2);
      target = target + right * (bx / ppu) - up * (by / ppu);
      final fit = math.min(
        math.max(40.0, rightEdge - left) / (x1 - x0),
        math.max(40.0, bottom - top) / (y1 - y0),
      );
      dist = (dist / fit).clamp(4.0, 60.0);
    }
    return (target + dir * dist, target);
  }

  // ---------------------------------------------------------------- flow

  void _begin() {
    if (_step != 0) return;
    setState(() => _boardVisible = false);
    _advance();
  }

  void _advance() {
    _timer?.cancel();
    setState(() {
      _step++;
      _busy = false;
      _openSteps.clear();
    });
    _rt_playSfx(_rt_Sfx.scenario);
    if (_step == 3) _resetDrain();
    _syncScene();
    _frame();
  }

  void _advanceAfter(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (mounted) _advance();
    });
  }

  void _toast(String text, Color color, IconData icon, int phoneMs, int ms) =>
      _shell.showToast(
        text,
        color: color,
        icon: icon,
        ms: _compactView ? phoneMs : ms,
      );

  void _logRow(String action, String result) {
    setState(() {
      _logShown = true;
      _log.add((action, result));
    });
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _step = 0;
      _boardVisible = true;
      _busy = false;
      _found.clear();
      _appleChecked = false;
      _cupsTested.clear();
      _activeCup = null;
      _bagsTested.clear();
      for (var i = 0; i < _picks.length; i++) {
        _picks[i] = null;
      }
      _lifePop.clear();
      _logShown = false;
      _logOpen = null;
      _log.clear();
      _openSteps.clear();
    });
    _soilShown = 1;
    _wasteShown = 0;
    for (final id in _cupIds) {
      _cupScale[id] = 1;
      _cupNodes[id]!.scale.set(1, 1, 1);
    }
    _paperMat.emissive = null;
    for (final mats in _auditMats.values) {
      for (final m in mats) {
        m.emissive = null;
      }
    }
    _resetDrain();
    _syncScene();
    _frame();
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _rt_playSfx(_rt_Sfx.scenario);
  }

  void _resetDrain() {
    _activeBag = null;
    _bagT = 0;
    _rotK = 0;
    _puddleShown = 0;
    _plasticBag.visible = false;
    _clothBag.visible = false;
    _microbes.visible = false;
    _puddle.visible = false;
  }

  void _finish() {
    if (!mounted) return;
    setState(() => _step = _lastStep + 1);
    _shell.showSuccess(
      title: _tx.s('summary.title'),
      message: _tx.s('summary.msg'),
      icon: Icons.recycling,
      color: _emerald,
      sound: _rt_Sfx.curtain,
      buttonLabel: _tx.s('btn_restart'),
      onConfirm: _restart,
    );
  }

  // ------------------------------------------------------------ animation

  double _ease(double v, double target, double dt, double tau) {
    final n = v + (target - v) * (1 - math.exp(-dt / tau));
    return (n - target).abs() < 0.001 ? target : n;
  }

  void _onFrame(double dt) {
    _clock += dt;
    final pulse = 0.5 + 0.5 * math.sin(_clock * 5);

    // Step 1: identified items glow (red: non-biodegradable, green: apple).
    for (final id in _auditItems) {
      final glow = id == 'apple'
          ? const Color(0xFF22C55E)
          : const Color(0xFFFF2020);
      for (final m in _auditMats[id]!) {
        m.emissive = _isFound(id) ? glow : null;
        m.emissiveIntensity = 0.2 + 0.25 * pulse;
      }
    }

    // Step 2: the tested cup grows; waste piles up; topsoil is lost.
    if (_step == 2) {
      for (final id in _cupIds) {
        final s = _ease(_cupScale[id]!, id == _activeCup ? 1.4 : 1.0, dt, 0.15);
        _cupScale[id] = s;
        _cupNodes[id]!.scale.set(s, s, s);
      }
      _paperMat
        ..emissive = _activeCup == 'paper' ? const Color(0xFF15803D) : null
        ..emissiveIntensity = 0.25 + 0.3 * pulse;
      _soilShown = _ease(
        _soilShown,
        _cupsTested.contains('kulhad') ? _soilAfterKulhad : 1,
        dt,
        0.6,
      );
      _wasteShown = _ease(
        _wasteShown,
        _cupsTested.contains('plastic') ? 1 : 0,
        dt,
        0.25,
      );
    }

    if (_step == 3) _tickDrain(dt);

    // Step 4: a chosen item pops onto the desk.
    for (final id in _lifePop.keys.toList()) {
      final t = _lifePop[id]!;
      if (t < 1) _lifePop[id] = math.min(1.0, t + dt / 0.3);
    }
    _syncScene();
  }

  void _tickDrain(double dt) {
    final blocked = _activeBag == 'plastic' && _bagT > _dropTime * 0.8;
    final pts = _water.points;
    for (var i = 0; i < pts.length; i++) {
      final p = pts[i];
      p.y -= _waterVel[i] * dt;
      if (blocked && p.y < 0.3 && p.y > 0) {
        // The bag seals the grate: water collects on top of it.
        p.y = 0.22 + _rng.nextDouble() * 0.3;
      } else if (p.y < -1.4) {
        p.y = 2.4;
      }
    }

    final bag = _activeBag;
    if (bag != null) _bagT += dt;
    final fall = _bounceOut((_bagT / _dropTime).clamp(0.0, 1.0));
    _plasticBag.visible = bag == 'plastic';
    if (bag == 'plastic') {
      _plasticBag.position.y = _dropFrom + (0.28 - _dropFrom) * fall;
      final f = ((_bagT - 0.5) / 1.0).clamp(0.0, 1.0);
      _plasticBag.scale.set(1.5 + 0.4 * f, 0.6 - 0.2 * f, 1.2 + 0.4 * f);
    }
    _rotK = bag == 'cloth'
        ? ((_bagT - _rotStart) / _rotTime).clamp(0.0, 1.0)
        : 0.0;
    _clothBag.visible = bag == 'cloth' && _rotK < 1;
    if (bag == 'cloth') {
      final y = _dropFrom + (0.05 - _dropFrom) * fall - 0.25 * _rotK;
      final s = 1 - 0.85 * _rotK;
      _clothBag.position.y = y;
      _clothBag.scale.set(s, s, s);
      _clothMat.color = Color.lerp(
        const Color(0xFF8B5A2B),
        const Color(0xFF3F2A14),
        _rotK,
      )!;
      _microbes.visible = _rotK > 0 && _rotK < 1;
      for (var i = 0; i < _microbeBase.length; i++) {
        final b = _microbeBase[i];
        final w = _clock * 3 + i;
        _microbes.points[i].set(
          b.x * (0.4 + 0.6 * s) + 0.08 * math.sin(w),
          y + b.y * s + 0.08 * math.cos(w * 1.3),
          b.z * (0.4 + 0.6 * s) + 0.08 * math.sin(w * 0.7),
        );
      }
    } else {
      _microbes.visible = false;
    }

    _puddleShown = _ease(
      _puddleShown,
      blocked ? 1 : 0,
      dt,
      blocked ? 1.0 : 0.5,
    );
    _puddle.visible = _puddleShown > 0.02;
    final spread = 0.3 + 0.7 * _puddleShown;
    _puddle
      ..position.y = 0.02 + 0.2 * _puddleShown
      ..scale.set(spread, 1, spread);
  }

  // ------------------------------------------------------ step actions

  void _onSceneTap(_rt_SceneEvent e) {
    if (_step != 1 || _busy) return;
    for (final n in e.hits) {
      final id = _auditIdOf(n);
      if (id != null) {
        _audit(id);
        return;
      }
    }
  }

  String? _auditIdOf(_rt_Node3D n) {
    for (_rt_Node3D? c = n; c != null; c = c.parent) {
      for (final e in _auditNodes.entries) {
        if (e.value == c) return e.key;
      }
    }
    return null;
  }

  /// Step 1: one basket item was tapped (in 3D or with its button).
  void _audit(String id) {
    if (_step != 1 || _busy) return;
    if (id == 'apple') {
      _rt_playSfx(_rt_Sfx.tap);
      if (!_appleChecked) {
        setState(() => _appleChecked = true);
        _logRow('log_apple_act', 'log_apple_res');
      }
      _toast(_tx.s('msg_apple'), _green, Icons.eco, 3000, 3500);
      return;
    }
    if (_found.contains(id)) {
      _rt_playSfx(_rt_Sfx.tap);
      _toast(_tx.s('msg_found_again'), _amber, Icons.info_outline, 2000, 2500);
      return;
    }
    setState(() => _found.add(id));
    _rt_playSfx(_rt_Sfx.correct);
    _toast(_tx.s('msg_found'), _red, Icons.delete_outline, 2000, 2500);
    if (_found.length < 2) return;
    setState(() => _busy = true);
    _logRow('log_audit_act', 'log_audit_res');
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _toast(_tx.s('msg_packaging'), _amber, Icons.inventory_2, 3500, 4000);
      _advanceAfter(Duration(milliseconds: _compactView ? 3500 : 4000));
    });
  }

  /// Step 2: test one cup material.
  void _testCup(String id) {
    if (_step != 2 || _busy) return;
    final first = !_cupsTested.contains(id);
    setState(() {
      _cupsTested.add(id);
      _activeCup = id;
    });
    switch (id) {
      case 'plastic':
        _rt_playSfx(_rt_Sfx.wrong);
        _toast(_tx.s('msg_plastic_cup'), _red, Icons.delete_sweep, 3500, 4000);
      case 'kulhad':
        _rt_playSfx(_rt_Sfx.wrong);
        _toast(_tx.s('msg_kulhad'), _amber, Icons.warning_amber, 3500, 4000);
      default:
        _rt_playSfx(_rt_Sfx.correct);
        _toast(_tx.s('msg_paper'), _green, Icons.eco, 3500, 4000);
    }
    if (first) {
      final key = switch (id) {
        'plastic' => 'pcup',
        'kulhad' => 'kulhad',
        _ => 'paper',
      };
      _logRow('log_${key}_act', 'log_${key}_res');
    }
    if (_cupsTested.length == _cupIds.length) {
      setState(() => _busy = true);
      _advanceAfter(const Duration(milliseconds: 4500));
    }
  }

  /// Step 3: drop one bag into the drain.
  void _testBag(String id) {
    if (_step != 3 || _busy) return;
    final first = !_bagsTested.contains(id);
    setState(() {
      _bagsTested.add(id);
      _activeBag = id;
    });
    _bagT = 0;
    _rotK = 0;
    if (id == 'plastic') {
      _rt_playSfx(_rt_Sfx.wrong);
      _toast(_tx.s('msg_plastic_bag'), _red, Icons.water_damage, 4000, 5000);
      if (first) _logRow('log_pbag_act', 'log_pbag_res');
    } else {
      _rt_playSfx(_rt_Sfx.correct);
      _toast(_tx.s('msg_cloth_bag'), _green, Icons.shopping_bag, 4000, 5000);
      if (first) _logRow('log_cbag_act', 'log_cbag_res');
    }
    if (_bagsTested.length == _bagIds.length) {
      setState(() => _busy = true);
      _advanceAfter(Duration(milliseconds: id == 'cloth' ? 4300 : 5000));
    }
  }

  /// Step 4: choose one item of a pair.
  void _pick(int pair, String id) {
    if (_step != 4 || _busy || _picks[pair] == id) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _picks[pair] = id);
    _lifePop[id] = 0;
  }

  void _checkLifestyle() {
    if (_step != 4 || _busy) return;
    if (_picks.contains(null)) {
      _rt_playSfx(_rt_Sfx.wrong);
      _toast(_tx.s('err_pick_all'), _red, Icons.error_outline, 2500, 3000);
      return;
    }
    var good = 0;
    for (var i = 0; i < _pairs.length; i++) {
      if (_picks[i] == _pairs[i].$2) good++;
    }
    if (good < _pairs.length) {
      _rt_playSfx(_rt_Sfx.wrong);
      _toast(
        _tx.s('err_life').replaceAll('{n}', '$good'),
        _red,
        Icons.error_outline,
        3500,
        4000,
      );
      return;
    }
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.success);
    _logRow('log_life_act', 'log_life_res');
    _toast(_tx.s('msg_life_ok'), _green, Icons.eco, 2500, 3000);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1800), _finish);
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
          _syncLabels();
          _scene.backgroundGradient = _rt_appTheme.isDark
              ? const [Color(0xFF1E293B), Color(0xFF020617)]
              : const [Color(0xFFF8FAFC), Color(0xFFCBD5E1)];
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _emerald,
              headerGradient: [_rt_Tw.slate900, Color(0xFF064E3B)],
              headerSubtitleColor: Color(0xFF6EE7B7),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _rt_CommonStrings.enterLab,
              footnote: _tx.s('intro.footnote'),
              icon: Icons.recycling,
              buttonIcon: Icons.play_arrow,
            ),
            onStart: () => setState(() => _boardVisible = true),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              _roundToggle(
                key: const ValueKey('toolLabels'),
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
                key: const ValueKey('toolLock'),
                tip: _tx.s('tool_lock'),
                icon: _camLocked ? Icons.lock : Icons.lock_open,
                on: _camLocked,
                onTap: () => setState(() => _camLocked = !_camLocked),
              ),
              const SizedBox(height: 4),
              _rt_RotatePanToggle(controller: _viewCtrl, accent: _emerald),
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
                  if (_camLocked) _frame();
                }
                return _rt_Scene3DView(
                  scene: _scene,
                  camera: _camera,
                  controller: _viewCtrl,
                  onFrame: _onFrame,
                  onTap: _onSceneTap,
                  cameraControls: !_camLocked,
                );
              },
            ),
            canvasOverlays: [
              if (_step >= 1 && _step <= _lastStep) _hudOverlay(),
              if (_logShown) _logOverlay(),
              if (_step >= 1 && _step <= _lastStep) _taskOverlay(),
              if (_step == 0 && _boardVisible) _boardOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _roundToggle({
    required Key key,
    required String tip,
    required IconData icon,
    required bool on,
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
            color: on ? _emerald : _rt_Lab.surface,
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

  TextStyle _titleStyle(Color color, {double size = 12}) => TextStyle(
    color: color,
    fontSize: size,
    fontWeight: FontWeight.w900,
    letterSpacing: 1,
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
            constraints: const BoxConstraints(maxWidth: 480),
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: _cardDecoration(_green),
            // One block of text on short phones so the scene stays visible.
            child: compact
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${_tx.s('curr_obj').toUpperCase()}: ',
                          style: const TextStyle(
                            color: _green,
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
                          const Icon(
                            Icons.info_outline,
                            size: 15,
                            color: _green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _tx.s('curr_obj').toUpperCase(),
                            style: _titleStyle(_greenDark, size: 11),
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

  Widget _logOverlay() {
    // Short phones: a small button with the row count at the top-left that
    // opens the log on demand, so it covers little of the scene.
    final compact = _compactView;
    final open = _logOpen ?? !compact;
    if (!open) {
      return Positioned(
        key: const ValueKey('log'),
        top: compact ? 74 : 110,
        left: compact ? 8 : null,
        right: compact ? null : 66,
        child: Tooltip(
          message: _tx.s('data_log'),
          child: Material(
            color: _rt_Lab.surface.withValues(alpha: 0.96),
            shape: StadiumBorder(
              side: BorderSide(color: _green.withValues(alpha: 0.6), width: 2),
            ),
            child: InkWell(
              key: const ValueKey('logToggle'),
              customBorder: const StadiumBorder(),
              onTap: () {
                _rt_playSfx(_rt_Sfx.toggle);
                setState(() => _logOpen = true);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.table_chart_outlined,
                      size: 16,
                      color: _green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_log.length}',
                      style: TextStyle(
                        color: _rt_Lab.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(Icons.expand_more, size: 18, color: _rt_Lab.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final head = TextStyle(
      color: _rt_Lab.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w900,
    );
    final cell = TextStyle(color: _rt_Lab.text, fontSize: compact ? 10 : 11);
    return Positioned(
      key: const ValueKey('log'),
      top: compact ? 74 : 110,
      left: compact ? 8 : null,
      right: compact ? null : 66,
      child: Container(
        width: compact ? 196 : 260,
        padding: EdgeInsets.all(compact ? 6 : 12),
        decoration: _cardDecoration(_green),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.table_chart_outlined, size: 16, color: _green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tx.s('data_log'),
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                InkResponse(
                  key: const ValueKey('logToggle'),
                  radius: 18,
                  onTap: () {
                    _rt_playSfx(_rt_Sfx.toggle);
                    setState(() => _logOpen = false);
                  },
                  child: Icon(
                    Icons.expand_less,
                    size: 20,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                // Phones: an icon, so a long translation never squeezes the
                // narrow card's title.
                if (compact)
                  Tooltip(
                    message: _tx.s('btn_clear'),
                    child: InkResponse(
                      key: const ValueKey('logClear'),
                      radius: 18,
                      onTap: () {
                        _rt_playSfx(_rt_Sfx.click);
                        setState(_log.clear);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: _rt_Tw.red500,
                        ),
                      ),
                    ),
                  )
                else
                  TextButton(
                    key: const ValueKey('logClear'),
                    onPressed: () {
                      _rt_playSfx(_rt_Sfx.click);
                      setState(_log.clear);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _rt_Tw.red500,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(64, 32),
                    ),
                    child: Text(_tx.s('btn_clear')),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (_log.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _tx.s('no_data'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rt_Lab.textFaint,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: compact ? 96 : 190),
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: _rt_Lab.border),
                    ),
                    children: [
                      TableRow(
                        children: [
                          Text(_tx.s('th_action').toUpperCase(), style: head),
                          Text(_tx.s('th_result').toUpperCase(), style: head),
                        ],
                      ),
                      for (final (action, result) in _log)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(_tx.s(action), style: cell),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _tx.s(result),
                                style: cell.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _taskOverlay() {
    // A full-canvas layer stays fixed in the shell, so pressing a button can
    // never drag its card away. Empty space still reaches the 3D view. On
    // phones the toolbar runs down to the bottom edge, so the bar keeps
    // clear of it.
    final compact = _compactView;
    return Positioned.fill(
      key: const ValueKey('task'),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: compact
              ? const EdgeInsets.fromLTRB(12, 0, 60, 8)
              : const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 480 : 600),
            child: switch (_step) {
              1 => _auditCard(),
              2 => _cupCard(),
              3 => _bagCard(),
              _ => _lifeCard(),
            },
          ),
        ),
      ),
    );
  }

  /// One option button of a task bar. It fires on pointer-up inside the
  /// button, so a slightly wobbly touch still counts.
  Widget _option({
    required String id,
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool selected,
    required Color accent,
    required VoidCallback? onTap,
    bool check = false,
    bool wide = true,
  }) {
    final compact = _compactView;
    final enabled = onTap != null;
    // Phones: wide buttons put the icon beside the label to save height.
    final inline = compact && wide;
    final overlay = _rt_Lab.overlay;
    final iconRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 16 : 22, color: iconColor),
        if (check) ...[
          const SizedBox(width: 2),
          Icon(Icons.check_circle, size: compact ? 12 : 14, color: accent),
        ],
      ],
    );
    final text = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: inline ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        color: _rt_Lab.text,
        fontSize: compact ? (inline ? 10.5 : 9.5) : 12,
        height: 1.1,
        fontWeight: FontWeight.w800,
      ),
    );
    return Center(
      heightFactor: 1,
      child: _PressButton(
        key: ValueKey(id),
        onPressed: onTap,
        child: Opacity(
          opacity: enabled || selected ? 1 : 0.55,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: inline ? 34 : 0),
            padding: compact
                ? EdgeInsets.symmetric(horizontal: inline ? 8 : 4, vertical: 5)
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? accent.withValues(alpha: 0.18) : overlay,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? accent : _rt_Lab.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: inline
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconRow,
                      const SizedBox(width: 6),
                      Flexible(child: text),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      iconRow,
                      SizedBox(height: compact ? 2 : 4),
                      text,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Card header: icon, title (large screens) and a status on the right.
  Widget _cardHead(IconData icon, Color color, String title, Widget status) {
    final compact = _compactView;
    return Row(
      children: [
        Icon(icon, size: compact ? 16 : 18, color: color),
        const SizedBox(width: 6),
        if (!compact) ...[
          Flexible(
            child: Text(
              title.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: _titleStyle(color),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Align(
            alignment: compact ? Alignment.centerLeft : Alignment.centerRight,
            child: status,
          ),
        ),
      ],
    );
  }

  Widget _statusText(String text, Color color) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: color,
      fontSize: _compactView ? 11 : 12,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _row(List<Widget> children) {
    final gap = _compactView ? 6.0 : 8.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: children[i]),
        ],
      ],
    );
  }

  EdgeInsets get _cardPad => _compactView
      ? const EdgeInsets.fromLTRB(10, 7, 10, 8)
      : const EdgeInsets.fromLTRB(16, 12, 16, 14);

  /// Step 1: how many non-biodegradable items are found, with a button per
  /// basket item as a touch-friendly alternative to tapping the 3D model.
  Widget _auditCard() {
    const icons = {
      'bottle': (Icons.local_drink, Color(0xFF22D3EE)),
      'packet': (Icons.fastfood, _red),
      'apple': (Icons.eco, Color(0xFF22C55E)),
    };
    return Container(
      key: const ValueKey('auditCard'),
      padding: _cardPad,
      decoration: _cardDecoration(_red),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(
            Icons.manage_search,
            _red,
            _tx.s('audit_title'),
            _statusText(
              _tx.s('audit_found').replaceAll('{n}', '${_found.length}'),
              _found.length == 2 ? _green : _rt_Lab.text,
            ),
          ),
          if (!_compactView) ...[
            const SizedBox(height: 2),
            Text(
              _tx.s('audit_hint'),
              style: TextStyle(color: _rt_Lab.textMuted, fontSize: 11),
            ),
          ],
          SizedBox(height: _compactView ? 6 : 10),
          _row([
            for (final id in _auditItems)
              _option(
                id: 'audit_$id',
                icon: icons[id]!.$1,
                iconColor: icons[id]!.$2,
                label: _tx.s('btn_$id'),
                selected: _isFound(id),
                check: _isFound(id),
                accent: id == 'apple' ? _green : _red,
                onTap: _busy ? null : () => _audit(id),
              ),
          ]),
        ],
      ),
    );
  }

  /// Step 2: one button per cup and the topsoil gauge.
  Widget _cupCard() {
    final compact = _compactView;
    const icons = {
      'plastic': (Icons.local_cafe, _red),
      'kulhad': (Icons.emoji_food_beverage, Color(0xFFEA580C)),
      'paper': (Icons.coffee, _green),
    };
    final soil = _cupsTested.contains('kulhad') ? _soilAfterKulhad : 1.0;
    final gauge = TweenAnimationBuilder<double>(
      tween: Tween(end: soil),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeInOut,
      builder: (context, v, _) {
        final c = Color.lerp(
          _red,
          _green,
          ((v - _soilAfterKulhad) / (1 - _soilAfterKulhad)).clamp(0.0, 1.0),
        )!;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grass, size: compact ? 14 : 16, color: c),
            const SizedBox(width: 4),
            Text(
              _tx.s('topsoil'),
              style: TextStyle(
                color: _rt_Lab.textMuted,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: compact ? 56 : 110,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  key: const ValueKey('topsoilBar'),
                  value: v,
                  minHeight: compact ? 6 : 8,
                  color: c,
                  backgroundColor: _rt_Lab.overlay,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${(v * 100).round()}%',
              style: TextStyle(
                color: c,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        );
      },
    );
    return Container(
      key: const ValueKey('cupCard'),
      padding: _cardPad,
      decoration: _cardDecoration(_amber),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHead(
                  Icons.coffee,
                  _amber,
                  _tx.s('cup_title'),
                  _statusText(
                    _tx
                        .s('cup_tested')
                        .replaceAll('{n}', '${_cupsTested.length}'),
                    _rt_Lab.text,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              gauge,
            ],
          ),
          SizedBox(height: compact ? 6 : 10),
          _row([
            for (final id in _cupIds)
              _option(
                id: 'cup_$id',
                icon: icons[id]!.$1,
                iconColor: icons[id]!.$2,
                label: _tx.s('btn_$id'),
                selected: _activeCup == id,
                check: _cupsTested.contains(id),
                accent: id == 'paper' ? _green : _red,
                onTap: _busy ? null : () => _testCup(id),
              ),
          ]),
        ],
      ),
    );
  }

  /// Step 3: one button per bag and the state of the drain.
  Widget _bagCard() {
    final bag = _activeBag;
    final (status, color) = switch (bag) {
      null => (_tx.s('drain_idle'), _blue),
      'plastic' => (_tx.s('drain_block'), _red),
      _ => (_tx.s('drain_flow'), _green),
    };
    return Container(
      key: const ValueKey('bagCard'),
      padding: _cardPad,
      decoration: _cardDecoration(_blue),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHead(
                  Icons.water_drop,
                  _blue,
                  _tx.s('bag_title'),
                  _statusText(status, color),
                ),
              ),
              const SizedBox(width: 10),
              _statusText(
                _tx.s('bag_tested').replaceAll('{n}', '${_bagsTested.length}'),
                _rt_Lab.textMuted,
              ),
            ],
          ),
          SizedBox(height: _compactView ? 6 : 10),
          _row([
            _option(
              id: 'bag_plastic',
              icon: Icons.shopping_bag_outlined,
              iconColor: _red,
              label: _tx.s('lbl_plastic_bag'),
              selected: bag == 'plastic',
              check: _bagsTested.contains('plastic'),
              accent: _red,
              onTap: _busy ? null : () => _testBag('plastic'),
            ),
            _option(
              id: 'bag_cloth',
              icon: Icons.shopping_bag,
              iconColor: _brown,
              label: _tx.s('lbl_cloth_bag'),
              selected: bag == 'cloth',
              check: _bagsTested.contains('cloth'),
              accent: _green,
              onTap: _busy ? null : () => _testBag('cloth'),
            ),
          ]),
        ],
      ),
    );
  }

  static const _lifeIcons = {
    'foil': (Icons.lunch_dining, Color(0xFF94A3B8)),
    'box': (Icons.inventory_2, _blue),
    'pbottle': (Icons.local_drink, Color(0xFF22D3EE)),
    'sbottle': (Icons.water_drop, Color(0xFF94A3B8)),
    'pbag': (Icons.shopping_bag_outlined, Color(0xFFCBD5E1)),
    'jbag': (Icons.shopping_bag, _brown),
  };

  /// Step 4: the three pairs and the submit button.
  Widget _lifeCard() {
    final compact = _compactView;
    Widget pair(int i) {
      final (a, b) = _pairs[i];
      Widget opt(String id) => _option(
        id: 'life_$id',
        icon: _lifeIcons[id]!.$1,
        iconColor: _lifeIcons[id]!.$2,
        label: _tx.s('btn_$id'),
        selected: _picks[i] == id,
        accent: _emerald,
        wide: false,
        onTap: _busy ? null : () => _pick(i, id),
      );
      return Container(
        padding: EdgeInsets.all(compact ? 3 : 6),
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!compact) ...[
              Text(
                _tx.s('lbl_slot$i').toUpperCase(),
                textAlign: TextAlign.center,
                style: _titleStyle(_rt_Lab.textMuted, size: 10),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: opt(a)),
                SizedBox(width: compact ? 3 : 6),
                Expanded(child: opt(b)),
              ],
            ),
          ],
        ),
      );
    }

    final submit = Center(
      heightFactor: 1,
      child: _PressButton(
        key: const ValueKey('lifeSubmit'),
        onPressed: _busy
            ? null
            : () {
                _rt_playSfx(_rt_Sfx.click);
                _checkLifestyle();
              },
        child: Material(
          color: _busy ? _emerald.withValues(alpha: 0.45) : _emerald,
          elevation: 4,
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: compact ? 15 : 20,
                ),
                SizedBox(width: compact ? 6 : 8),
                Flexible(
                  child: Text(
                    _tx.s('btn_submit').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10.5 : 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: compact ? 0.3 : 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Phones: the pairs fill the width (room for two-word labels) with the
    // submit button on a short second row.
    return Container(
      key: const ValueKey('lifeCard'),
      padding: compact ? const EdgeInsets.all(6) : _cardPad,
      decoration: _cardDecoration(_emerald),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            Row(
              children: [
                const Icon(Icons.backpack, size: 18, color: _emerald),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tx.s('lifestyle_title'),
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          _row([for (var i = 0; i < 3; i++) pair(i)]),
          SizedBox(height: compact ? 5 : 10),
          submit,
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
          // Phones: clear of the toolbar on the right.
          padding: compact
              ? const EdgeInsets.fromLTRB(8, 8, 56, 8)
              : const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: EdgeInsets.all(compact ? 14 : 24),
              decoration: _cardDecoration(_green),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.recycling, size: compact ? 36 : 56, color: _green),
                  SizedBox(height: compact ? 6 : 12),
                  Text(
                    _tx.s('objective'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: compact ? 14 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  Text(
                    _tx.s('board_desc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.textMuted,
                      fontSize: compact ? 12 : 15,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 20),
                  _rt_ActionButton(
                    label: _tx.s('board_btn'),
                    icon: Icons.play_arrow,
                    color: _emerald,
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
          accent: _emerald,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _tx.s('concept_exp').toUpperCase(),
                style: _titleStyle(_rt_Lab.textMuted, size: 11),
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
    Widget detail(String label, Object? text) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: _greenDark,
              fontWeight: FontWeight.w900,
            ),
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
            ? _rt_Lab.tinted(const Color(0xFFECFDF5), _green)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? _green
              : (done ? _green.withValues(alpha: 0.5) : _rt_Lab.border),
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
                      color: current || done ? _green : _rt_Lab.overlay,
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
                  detail(_tx.s('action'), data['action']),
                  const SizedBox(height: 6),
                  detail(_tx.s('observation'), data['observation']),
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
/// phone's ~8 dp touch slop, which made a child's slightly wobbly press do
/// nothing.
class _PressButton extends StatefulWidget {
  const _PressButton({super.key, required this.onPressed, required this.child});

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
