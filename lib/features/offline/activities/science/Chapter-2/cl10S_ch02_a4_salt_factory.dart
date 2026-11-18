// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 2.4: The Salt Factory
// Converted from Cl10S-Ch2-A4-The_Salt_Factory.html (three.js -> mini3d).
//
// Five guided phases of the chlor-alkali process: dissolve salt in a water
// tank to make brine, wire the electrodes to a battery and switch on the
// electrolysis, label the gases bubbling at the anode (Cl₂) and the cathode
// (H₂), test the solution with an indicator and explain why it turns pink
// (NaOH), and match the three products to their industrial uses.

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

  /// THREE.TubeGeometry along the polyline [path].
  factory _rt_Geometry3D.tube(
    List<_rt_V3> path,
    double radius, {
    int radialSegments = 8,
    bool closed = false,
  }) {
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    var prevNormal = _rt_V3(0, 1, 0);
    for (var i = 0; i < path.length; i++) {
      final prev = path[i == 0 ? (closed ? path.length - 1 : 0) : i - 1];
      final next = path[i == path.length - 1 ? (closed ? 0 : i) : i + 1];
      var tangent = (next - prev).normalized();
      if (tangent.lengthSq == 0) tangent = _rt_V3(1, 0, 0);
      var normal = prevNormal - tangent * prevNormal.dot(tangent);
      if (normal.lengthSq < 1e-8) {
        normal = _rt_V3(0, 0, 1).cross(tangent);
        if (normal.lengthSq < 1e-8) normal = _rt_V3(1, 0, 0).cross(tangent);
      }
      normal.normalize();
      prevNormal = normal;
      final binormal = tangent.cross(normal);
      for (var j = 0; j < radialSegments; j++) {
        final a = j / radialSegments * math.pi * 2;
        verts.add(
          path[i] +
              normal * (radius * math.cos(a)) +
              binormal * (radius * math.sin(a)),
        );
      }
    }
    final rings = closed ? path.length : path.length - 1;
    for (var i = 0; i < rings; i++) {
      final i2 = (i + 1) % path.length;
      for (var j = 0; j < radialSegments; j++) {
        final j2 = (j + 1) % radialSegments;
        faces.add([
          i * radialSegments + j,
          i * radialSegments + j2,
          i2 * radialSegments + j2,
          i2 * radialSegments + j,
        ]);
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
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.cameraControls = true,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
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
    'headerTitle': 'The Salt Factory',
    'headerSubtitle': 'Class 10: Acids, Bases and Salts',
    'intro': {
      'title': 'The Salt Factory',
      'subtitle': 'Class 10 • Acids, Bases and Salts',
      'button': 'Enter Plant',
      'footnote': 'The Chlor-Alkali Process',
    },
    'tabs': {'explore': 'Explore'},
    'lab_mission': 'Mission: Electrolysis',
    'lab_desc': 'Produce NaOH, Chlorine & Hydrogen.',
    'objective':
        'To pass electricity through brine (a concentrated solution of sodium chloride) and obtain sodium hydroxide, chlorine and hydrogen – the chlor-alkali process.',
    'ctx_title': 'Why Learn This?',
    'ctx': [
      {
        't': 'Sanitation',
        'd': 'Chlorine kills bacteria in pools and drinking water.',
      },
      {
        't': 'Everyday Clean',
        'd': 'NaOH is a key ingredient in soaps and detergents.',
      },
      {'t': 'Infrastructure', 'd': 'PVC pipes are made using Chlorine.'},
    ],
    'board_btn': 'Start Production',
    'concept_exp': 'Exploration Steps',
    'phase': 'Phase',
    'action': 'Action',
    'observation': 'Observation',
    'tip': 'Tip',
    'hud_mission': 'Current Objective',
    'hud': [
      'Drag the Salt Sack (NaCl) into the water tank.',
      'Connect the Electrodes to the Battery terminals using the wires.',
      'Identify the gases produced at each electrode.',
      'Use the indicator to check if the solution has become basic.',
      'Match the chemical products to their real-world applications.',
    ],
    'hud_fill': 'Filling the tank with water...',
    'hud_stir': 'Tap Stir Solution to dissolve the salt.',
    'hud_switch': 'Circuit complete! Tap Switch ON to start the electrolysis.',
    'hud_quiz': 'The solution turned pink. Answer the question.',
    'steps': [
      {
        'concept': 'Brine Preparation',
        'desc': 'Create a saltwater solution.',
        'tip': 'Drag the Salt Sack to the tank, then tap Stir Solution.',
        'action': 'Drag the Salt Sack (NaCl) into the water tank and stir.',
        'observation':
            'The salt dissolves to form brine – a concentrated solution of sodium chloride (NaCl) in water.',
      },
      {
        'concept': 'Electrification',
        'desc': 'Connect the power source.',
        'tip':
            'Drag from an electrode connector (silver ball) to a battery terminal, or tap one and then the other. Red is (+), blue is (−).',
        'action':
            'Wire the anode to the (+) terminal and the cathode to the (−) terminal, then switch ON.',
        'observation':
            'Electric current passes through the brine and it starts to decompose: gas bubbles appear at both electrodes.',
      },
      {
        'concept': 'Gas Identification',
        'desc': 'Analyse the reaction products.',
        'tip':
            'Drag the gas labels to the bubbling electrodes. Greenish gas is Chlorine.',
        'action':
            'Drag the Cl₂ and H₂ labels to the electrodes where they are produced.',
        'observation':
            'Chlorine gas (Cl₂) is released at the anode (+) and hydrogen gas (H₂) at the cathode (−).',
      },
      {
        'concept': 'The Alkali Check',
        'desc': 'Test for Sodium Hydroxide.',
        'tip': 'Drag the dropper to the solution.',
        'action':
            'Add the indicator to the solution and explain the colour change.',
        'observation':
            'The indicator (phenolphthalein) turns pink: sodium hydroxide (NaOH), a strong base, has formed near the cathode.',
      },
      {
        'concept': 'Industrial Map',
        'desc': 'Connect science to industry.',
        'tip': 'Select a product, then select its use.',
        'action': 'Match each product to its real-world use.',
        'observation':
            'Chlorine → water treatment, hydrogen → fuels, NaOH → soaps and detergents.',
      },
    ],
    'salt_tool': 'Salt Sack (NaCl)',
    'salt_inst': 'Drag into the water tank.',
    'drop_salt': 'Drop the salt into the tank',
    'btn_stir': 'Stir Solution',
    'btn_switch': 'Switch ON',
    'gas_tool': 'Gas Labels',
    'gas_inst': 'Drag each label to its bubbling electrode.',
    'lbl_cl2': 'Cl₂ Gas',
    'lbl_h2': 'H₂ Gas',
    'lbl_indicator': 'Indicator',
    'indicator_inst': 'Drag the dropper into the solution.',
    'drop_indicator': 'Drop the indicator into the solution',
    's5_btn': 'Start Matching',
    'lbl_anode': 'Anode (+)',
    'lbl_cathode': 'Cathode (−)',
    'lbl_battery': 'Battery',
    'quiz_title': 'Concept Check',
    'quiz_q': 'Why did the solution turn pink?',
    'quiz_a': 'Acid formed',
    'quiz_b': 'Base (NaOH) formed',
    'quiz_correct': 'Correct! NaOH is a strong base.',
    'err_quiz':
        'Not quite. This indicator turns pink in a basic solution, not in an acidic one.',
    'err_wire':
        'Wrong connection! Join the anode to the red (+) terminal and the cathode to the blue (−) terminal.',
    'err_gas':
        'Not this electrode! Greenish chlorine forms at the anode (+), hydrogen at the cathode (−).',
    'err_match': 'Not a match. Think about where each product is used.',
    'msg_wired': 'Wire connected!',
    'msg_brine': 'Brine is ready! Advancing...',
    'msg_gases': 'Both gases identified! Advancing...',
    'map_title': 'Industrial Map: Match Products to Uses',
    'map_instr': 'Select a product, then select its use.',
    'map_products': 'Products',
    'map_uses': 'Uses',
    'map_done': 'All products matched!',
    'map_chlorine': 'Chlorine',
    'map_hydrogen': 'Hydrogen',
    'map_naoh': 'NaOH',
    'map_water': 'Water Treatment',
    'map_fuel': 'Fuels',
    'map_soap': 'Soaps & Detergents',
    'data_log': 'Observation Log',
    'btn_clear': 'Clear',
    'th_action': 'Action',
    'th_result': 'Result',
    'no_data': 'No observations yet.',
    'log_salt_act': 'Salt added to water',
    'log_salt_res': 'Brine (NaCl solution)',
    'log_power_act': 'Current switched ON',
    'log_power_res': 'Bubbles at both electrodes',
    'log_anode_act': 'Gas at anode (+)',
    'log_anode_res': 'Chlorine (Cl₂)',
    'log_cathode_act': 'Gas at cathode (−)',
    'log_cathode_res': 'Hydrogen (H₂)',
    'log_ind_act': 'Indicator added',
    'log_ind_res': 'Turned pink – basic',
    'log_quiz_act': 'Concept answered',
    'log_quiz_res': 'NaOH (base) formed',
    'tool_labels': 'Show / hide labels',
    'tool_lock': 'Lock / unlock camera',
    's6_t': 'Activity Complete',
    's6_d': 'Process Successful.',
    'btn_outcomes': 'View Outcomes',
    'btn_restart': 'Restart Activity',
    'badge_title': 'Chemical Engineer',
    'summary_msg':
        'Badge Unlocked! You have successfully separated Brine into useful products.',
    'reaction_title': 'Reaction Formula',
    'reaction': '2NaCl(aq) + 2H₂O(l) → 2NaOH(aq) + Cl₂(g) + H₂(g)',
    'key_title': 'Key Takeaways',
    'keys': [
      {'k': 'Anode (+):', 'v': 'Chlorine gas (Cl₂) is released.'},
      {'k': 'Cathode (−):', 'v': 'Hydrogen gas (H₂) is released.'},
      {'k': 'Solution:', 'v': 'NaOH is formed near the cathode.'},
    ],
    'out_title': 'Learning Outcomes',
    'outs': [
      'Understand electrolytic decomposition of Brine.',
      'Identify products: Chlorine, Hydrogen, NaOH.',
      'Connect chemical properties to industrial uses.',
    ],
    'guide_title': "Teacher's Guide",
    'guide': [
      {'k': 'Anode (+):', 'v': 'Attracts Cl⁻ ions → Chlorine gas.'},
      {'k': 'Cathode (−):', 'v': 'Attracts H⁺ ions → Hydrogen gas.'},
      {
        'k': 'Solution:',
        'v': 'The remaining Na⁺ and OH⁻ ions form Sodium Hydroxide.',
      },
    ],
  },
  'hi': {
    'headerTitle': 'नमक का कारखाना',
    'headerSubtitle': 'कक्षा 10: अम्ल, क्षार और लवण',
    'intro': {
      'title': 'नमक का कारखाना',
      'subtitle': 'कक्षा 10 • अम्ल, क्षार और लवण',
      'button': 'कारखाने में प्रवेश करें',
      'footnote': 'क्लोर-क्षार प्रक्रिया',
    },
    'tabs': {'explore': 'प्रयोग'},
    'lab_mission': 'मिशन: विद्युत अपघटन',
    'lab_desc': 'NaOH, क्लोरीन और हाइड्रोजन का उत्पादन।',
    'objective':
        'ब्राइन (सोडियम क्लोराइड का सांद्र विलयन) में विद्युत धारा प्रवाहित करके सोडियम हाइड्रॉक्साइड, क्लोरीन और हाइड्रोजन प्राप्त करना – क्लोर-क्षार प्रक्रिया।',
    'ctx_title': 'क्यों सीखें?',
    'ctx': [
      {'t': 'स्वच्छता', 'd': 'क्लोरीन पानी में बैक्टीरिया को मारता है।'},
      {'t': 'सफाई', 'd': 'NaOH साबुन बनाने में उपयोग होता है।'},
      {'t': 'इन्फ्रास्ट्रक्चर', 'd': 'PVC पाइप क्लोरीन से बनते हैं।'},
    ],
    'board_btn': 'उत्पादन शुरू करें',
    'concept_exp': 'अन्वेषण चरण',
    'phase': 'चरण',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'tip': 'सुझाव',
    'hud_mission': 'वर्तमान लक्ष्य',
    'hud': [
      'नमक की बोरी (NaCl) को पानी के टैंक में खींचें।',
      'तारों का उपयोग करके इलेक्ट्रोड को बैटरी टर्मिनलों से कनेक्ट करें।',
      'प्रत्येक इलेक्ट्रोड पर उत्पन्न गैसों की पहचान करें।',
      'सूचक का उपयोग करके जांचें कि क्या घोल क्षारीय हो गया है।',
      'रासायनिक उत्पादों को उनके वास्तविक दुनिया के उपयोगों से मिलाएं।',
    ],
    'hud_fill': 'टैंक में पानी भरा जा रहा है...',
    'hud_stir': 'नमक घोलने के लिए हिलाओ बटन पर टैप करें।',
    'hud_switch':
        'परिपथ पूरा! विद्युत अपघटन शुरू करने के लिए स्विच ऑन पर टैप करें।',
    'hud_quiz': 'घोल गुलाबी हो गया। प्रश्न का उत्तर दें।',
    'steps': [
      {
        'concept': 'ब्राइन तैयारी',
        'desc': 'नमक का घोल तैयार करें।',
        'tip': 'नमक की बोरी को टैंक तक खींचें, फिर हिलाओ पर टैप करें।',
        'action':
            'नमक की बोरी (NaCl) को पानी के टैंक में डालें और घोल को हिलाएँ।',
        'observation':
            'नमक घुलकर ब्राइन बनाता है – पानी में सोडियम क्लोराइड (NaCl) का सांद्र विलयन।',
      },
      {
        'concept': 'विद्युतीकरण',
        'desc': 'बिजली स्रोत को जोड़ें।',
        'tip':
            'इलेक्ट्रोड के कनेक्टर (चांदी का गोला) से बैटरी टर्मिनल तक खींचें, या एक पर और फिर दूसरे पर टैप करें। लाल (+) है, नीला (−) है।',
        'action':
            'एनोड को (+) टर्मिनल से और कैथोड को (−) टर्मिनल से जोड़ें, फिर स्विच ऑन करें।',
        'observation':
            'ब्राइन में विद्युत धारा प्रवाहित होती है और उसका अपघटन होने लगता है: दोनों इलेक्ट्रोड पर गैस के बुलबुले बनते हैं।',
      },
      {
        'concept': 'गैस पहचान',
        'desc': 'प्रतिक्रिया उत्पादों का विश्लेषण करें।',
        'tip':
            'गैस लेबल को बुलबुले वाले इलेक्ट्रोड तक खींचें। हरे रंग की गैस क्लोरीन है।',
        'action': 'Cl₂ और H₂ लेबल को उन इलेक्ट्रोड पर खींचें जहाँ वे बनती हैं।',
        'observation':
            'एनोड (+) पर क्लोरीन गैस (Cl₂) और कैथोड (−) पर हाइड्रोजन गैस (H₂) निकलती है।',
      },
      {
        'concept': 'क्षार जाँच',
        'desc': 'सोडियम हाइड्रोक्साइड के लिए परीक्षण।',
        'tip': 'ड्रॉपर को घोल तक खींचें।',
        'action': 'घोल में सूचक डालें और रंग बदलने का कारण बताएँ।',
        'observation':
            'सूचक (फ़ीनॉल्फ़्थेलिन) गुलाबी हो जाता है: कैथोड के पास सोडियम हाइड्रॉक्साइड (NaOH), एक प्रबल क्षार, बना है।',
      },
      {
        'concept': 'औद्योगिक मानचित्र',
        'desc': 'विज्ञान को उद्योग से जोड़ें।',
        'tip': 'एक उत्पाद चुनें, फिर उसका उपयोग चुनें।',
        'action': 'प्रत्येक उत्पाद को उसके वास्तविक उपयोग से मिलाएँ।',
        'observation':
            'क्लोरीन → जल उपचार, हाइड्रोजन → ईंधन, NaOH → साबुन और डिटर्जेंट।',
      },
    ],
    'salt_tool': 'नमक की बोरी (NaCl)',
    'salt_inst': 'खींचकर पानी के टैंक में डालें।',
    'drop_salt': 'नमक को टैंक में छोड़ें',
    'btn_stir': 'हिलाओ',
    'btn_switch': 'स्विच ऑन',
    'gas_tool': 'गैस लेबल',
    'gas_inst': 'प्रत्येक लेबल को उसके बुलबुले वाले इलेक्ट्रोड पर खींचें।',
    'lbl_cl2': 'Cl₂ गैस',
    'lbl_h2': 'H₂ गैस',
    'lbl_indicator': 'सूचक',
    'indicator_inst': 'ड्रॉपर को खींचकर घोल में डालें।',
    'drop_indicator': 'सूचक को घोल में छोड़ें',
    's5_btn': 'मिलान शुरू करें',
    'lbl_anode': 'एनोड (+)',
    'lbl_cathode': 'कैथोड (−)',
    'lbl_battery': 'बैटरी',
    'quiz_title': 'अवधारणा जाँच',
    'quiz_q': 'घोल गुलाबी क्यों हो गया?',
    'quiz_a': 'अम्ल बना',
    'quiz_b': 'क्षार (NaOH) बना',
    'quiz_correct': 'सही! NaOH एक प्रबल क्षार है।',
    'err_quiz':
        'सही नहीं। यह सूचक अम्लीय नहीं, बल्कि क्षारीय घोल में गुलाबी होता है।',
    'err_wire':
        'गलत कनेक्शन! एनोड को लाल (+) टर्मिनल से और कैथोड को नीले (−) टर्मिनल से जोड़ें।',
    'err_gas':
        'यह इलेक्ट्रोड नहीं! हरी क्लोरीन एनोड (+) पर और हाइड्रोजन कैथोड (−) पर बनती है।',
    'err_match': 'मेल नहीं खाता। सोचिए कि प्रत्येक उत्पाद कहाँ उपयोग होता है।',
    'msg_wired': 'तार जुड़ गया!',
    'msg_brine': 'ब्राइन तैयार! आगे बढ़ रहे हैं...',
    'msg_gases': 'दोनों गैसों की पहचान हो गई! आगे बढ़ रहे हैं...',
    'map_title': 'औद्योगिक मानचित्र: उपयोग मिलाएं',
    'map_instr': 'एक उत्पाद चुनें, फिर उसका उपयोग चुनें।',
    'map_products': 'उत्पाद',
    'map_uses': 'उपयोग',
    'map_done': 'सभी उत्पादों का मिलान हो गया!',
    'map_chlorine': 'क्लोरीन',
    'map_hydrogen': 'हाइड्रोजन',
    'map_naoh': 'NaOH',
    'map_water': 'जल उपचार',
    'map_fuel': 'ईंधन',
    'map_soap': 'साबुन और डिटर्जेंट',
    'data_log': 'अवलोकन लॉग',
    'btn_clear': 'साफ़ करें',
    'th_action': 'क्रिया',
    'th_result': 'परिणाम',
    'no_data': 'अभी तक कोई अवलोकन नहीं।',
    'log_salt_act': 'पानी में नमक डाला',
    'log_salt_res': 'ब्राइन (NaCl विलयन)',
    'log_power_act': 'धारा चालू की',
    'log_power_res': 'दोनों इलेक्ट्रोड पर बुलबुले',
    'log_anode_act': 'एनोड (+) पर गैस',
    'log_anode_res': 'क्लोरीन (Cl₂)',
    'log_cathode_act': 'कैथोड (−) पर गैस',
    'log_cathode_res': 'हाइड्रोजन (H₂)',
    'log_ind_act': 'सूचक डाला',
    'log_ind_res': 'गुलाबी हुआ – क्षारीय',
    'log_quiz_act': 'अवधारणा का उत्तर दिया',
    'log_quiz_res': 'NaOH (क्षार) बना',
    'tool_labels': 'लेबल दिखाएँ / छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक करें',
    's6_t': 'गतिविधि पूर्ण',
    's6_d': 'प्रक्रिया सफल रही।',
    'btn_outcomes': 'परिणाम देखें',
    'btn_restart': 'पुनः आरंभ करें',
    'badge_title': 'केमिकल इंजीनियर',
    'summary_msg':
        'बैज खुला! आपने ब्राइन को उपयोगी उत्पादों में सफलतापूर्वक अलग कर दिया है।',
    'reaction_title': 'अभिक्रिया सूत्र',
    'reaction': '2NaCl(aq) + 2H₂O(l) → 2NaOH(aq) + Cl₂(g) + H₂(g)',
    'key_title': 'मुख्य बिंदु',
    'keys': [
      {'k': 'एनोड (+):', 'v': 'क्लोरीन गैस (Cl₂) निकलती है।'},
      {'k': 'कैथोड (−):', 'v': 'हाइड्रोजन गैस (H₂) निकलती है।'},
      {'k': 'घोल:', 'v': 'कैथोड के पास NaOH बनता है।'},
    ],
    'out_title': 'सीखने के परिणाम',
    'outs': [
      'ब्राइन के विद्युत अपघटन को समझें।',
      'उत्पादों की पहचान: क्लोरीन, हाइड्रोजन, NaOH।',
      'रासायनिक गुणों को औद्योगिक उपयोगों से जोड़ें।',
    ],
    'guide_title': 'शिक्षक गाइड',
    'guide': [
      {'k': 'एनोड (+):', 'v': 'Cl⁻ आयनों को आकर्षित करता है → क्लोरीन गैस।'},
      {'k': 'कैथोड (−):', 'v': 'H⁺ आयनों को आकर्षित करता है → हाइड्रोजन गैस।'},
      {
        'k': 'घोल:',
        'v': 'बचे हुए Na⁺ और OH⁻ आयन सोडियम हाइड्रॉक्साइड बनाते हैं।',
      },
    ],
  },
});

const _indigo = Color(0xFF6366F1);
const _indigoDark = Color(0xFF4F46E5);
const _indigoLight = Color(0xFF818CF8);
const _sky = Color(0xFF38BDF8);
const _emerald = Color(0xFF10B981);
const _blue = Color(0xFF3B82F6);
const _pink = Color(0xFFEC4899);
const _purple = Color(0xFFA855F7);
const _gasGreen = Color(0xFF4ADE80);
const _silver = Color(0xFFCBD5E1);

const _waterCyan = Color(0xFF00FFFF);
const _brineBlue = Color(0xFF3399CC);
const _pinkWater = Color(0xFFFF66B3);
const _waterGlow = Color(0xFF004444);
const _pinkGlow = Color(0xFF4D1029);

/// Phases 1-5 are tasks; 0 is the objective board, 6 the finished plant.
const _lastStep = 5;

/// Draggable tool ids (the HTML `.draggable-item` elements).
const _saltTool = 'salt', _indicatorTool = 'indicator';
const _cl2Tool = 'cl2', _h2Tool = 'h2';

/// Wire connectors: the two electrode tops and the two battery terminals
/// (the HTML `.wire-node` circles, now anchored to the 3D objects).
const _anode = 'anode', _cathode = 'cathode', _pos = 'pos', _neg = 'neg';
const _nodePos = {
  _anode: (-1.5, 3.5, 0.0),
  _cathode: (1.5, 3.5, 0.0),
  _pos: (-0.7, -0.72, 4.0),
  _neg: (0.7, -0.72, 4.0),
};

/// Each electrode belongs to exactly one terminal (anode (+), cathode (−)).
const _partner = {_anode: _pos, _pos: _anode, _cathode: _neg, _neg: _cathode};

/// Industrial map: product -> its use (HTML `selectMatch` pairs).
const _mapPairs = {
  'map_chlorine': 'map_water',
  'map_hydrogen': 'map_fuel',
  'map_naoh': 'map_soap',
};

/// Uses in a different order from the products, so a row never sits next to
/// its own answer.
const _mapUses = ['map_fuel', 'map_soap', 'map_water'];

/// 3D label keys and positions.
const _labelKeys = [
  'lbl_anode',
  'lbl_cathode',
  'lbl_battery',
  'lbl_cl2',
  'lbl_h2',
];
const _labelPos = [
  (-1.5, 4.15, 0.0),
  (1.5, 4.15, 0.0),
  (0.0, -1.5, 4.62),
  (-2.45, 2.65, 0.0),
  (2.45, 2.65, 0.0),
];
const _labelBg = Color(0xD90F172A);

class Cl10SCh02A4SaltFactoryPage extends StatefulWidget {
  const Cl10SCh02A4SaltFactoryPage({super.key});

  @override
  State<Cl10SCh02A4SaltFactoryPage> createState() => _SaltFactoryState();
}

class _SaltFactoryState extends State<Cl10SCh02A4SaltFactoryPage> {
  final _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E293B), Color(0xFF020617)],
  );
  final _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 5.5, 12.5))
    ..minDistance = 5
    ..maxDistance = 30
    ..maxPolarAngle = math.pi / 2 - 0.1;
  final _viewCtrl = _rt_Scene3DController();
  final _shell = _rt_ShellController();
  final _gasTargetKey = GlobalKey();
  final _rng = math.Random(11);

  late final _rt_Mesh3D _water;
  late final _rt_Material3D _waterMat, _cloudMat;
  late final _rt_Sphere3D _cloud;
  late final _rt_Points3D _salt, _drops, _bubblesCl, _bubblesH;
  late final List<_rt_V3> _saltLand;
  late final List<double> _saltDelay;
  final List<double> _bubbleSpeed = [];
  final Map<String, _rt_Sphere3D> _nodes = {};
  final Map<String, _rt_Mesh3D> _wires = {};
  final List<_rt_Label3D> _labels = [];

  int _step = 0;
  bool _boardVisible = false;
  bool _camLocked = true;
  bool _labelsVisible = true;
  bool? _compact; // short landscape phone; set by the first build
  double _time = 0;
  double? _fillT; // tank filling progress; null when idle
  bool _saltAdded = false;
  double? _saltT; // salt sinking / brine tint progress
  double? _stirT; // stirring progress
  bool _brineReady = false;
  final Set<String> _wired = {}; // electrodes already wired
  String? _wireStart, _pendingNode;
  Offset? _wireDown, _wireFrom, _wireTo;
  bool _powerOn = false;
  final Set<String> _gasPlaced = {};
  String? _gasHover; // electrode under a dragged gas label
  bool _indicatorAdded = false;
  double? _pinkT; // indicator colour change progress
  bool _pinkDone = false;
  String? _quizPick;
  bool _quizSolved = false;
  bool _mapOpen = false;
  String? _selProduct, _selUse;
  final Set<String> _matched = {};
  bool _logShown = false;
  bool? _logOpen; // null: expanded on tall screens, collapsed on phones
  final List<(String, String)> _log = [];
  final Set<int> _openSteps = {};
  bool _guideOpen = false;
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
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _viewCtrl.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------------------------------------------------------- scene

  void _initScene() {
    _scene.setLights([
      _rt_Light3D.hemisphere(intensity: 0.55),
      _rt_Light3D.directional(_rt_V3(5, 10, 5), intensity: 1.1),
      _rt_Light3D.directional(
        _rt_V3(-10, 5, -10),
        color: _indigo,
        intensity: 0.5,
      ),
    ]);

    // Lab bench and its floor grid (THREE.GridHelper). Everything stands on
    // the bench, so it is always painted first.
    _scene.add(
      _rt_Mesh3D(
          _rt_Geometry3D.box(20, 0.3, 14),
          _rt_Material3D(color: _rt_Tw.slate800, metalness: 0.2),
        )
        ..position.set(0, -2.15, 1)
        ..depthBias = 1000
        ..pickable = false,
    );
    bool covered(double x, double z) =>
        (x.abs() < 3.3 && z.abs() < 1.8) ||
        (x.abs() < 1.4 && (z - 4).abs() < 0.8);
    final grid = <_rt_V3>[];
    for (var g = -10.0; g <= 10; g += 2) {
      for (var t = -6.0; t < 8; t++) {
        if (covered(g, t + 0.5)) continue;
        grid.addAll([_rt_V3(g, -1.99, t), _rt_V3(g, -1.99, t + 1)]);
      }
    }
    for (var g = -6.0; g <= 8; g += 2) {
      for (var t = -10.0; t < 10; t++) {
        if (covered(t + 0.5, g)) continue;
        grid.addAll([_rt_V3(t, -1.99, g), _rt_V3(t + 1, -1.99, g)]);
      }
    }
    _scene.add(
      _rt_Line3D(grid)
        ..segments = true
        ..color = _rt_Tw.slate700
        ..width = 1
        ..depthBias = 999,
    );

    // Open glass tank (the HTML box also had a glass lid the electrodes
    // passed through).
    final box = _rt_Geometry3D.box(6, 4, 3);
    _scene.add(
      _rt_Mesh3D(
        _rt_Geometry3D(box.vertices, [
          for (var i = 0; i < box.faces.length; i++)
            if (i != 2) box.faces[i],
        ]),
        _rt_Material3D(
          color: Colors.white,
          opacity: 0.15,
          shininess: 0.8,
          doubleSided: true,
        )..edgeColor = Colors.white.withValues(alpha: 0.35),
      )..pickable = false,
    );

    // Water (later brine): a unit-high box scaled to the filling level.
    _waterMat = _rt_Material3D(color: _waterCyan, opacity: 0.5, shininess: 0.9)
      ..emissive = _waterGlow;
    _water = _scene.add(
      _rt_Mesh3D(_rt_Geometry3D.box(5.8, 1, 2.8), _waterMat)..pickable = false,
    );
    _setWater(0.1);

    // Electrodes, split at the brine surface so the submerged part is
    // painted behind the water and the dry part in front of it.
    for (final (x, color) in [(-1.5, _rt_Tw.red500), (1.5, _blue)]) {
      final mat = _rt_Material3D(color: color, metalness: 0.4, shininess: 0.7);
      _scene
        ..add(
          _rt_Mesh3D(_rt_Geometry3D.cylinder(0.2, 0.2, 3, openEnded: true), mat)
            ..position.set(x, 0, 0)
            ..pickable = false,
        )
        ..add(
          _rt_Mesh3D(_rt_Geometry3D.cylinder(0.2, 0.2, 2), mat)
            ..position.set(x, 2.5, 0)
            ..pickable = false,
        );
    }

    // DC battery in front of the tank with its red (+) and blue (−) posts.
    _scene.add(_rt_Node3D(name: 'battery')..position.set(0, -1.5, 4))
      ..add(
        _rt_Mesh3D(
          _rt_Geometry3D.box(2.2, 1, 1),
          _rt_Material3D(color: _rt_Tw.slate600, shininess: 0.3)
            ..edgeColor = _rt_Tw.slate400,
        )..pickable = false,
      )
      ..add(
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.12, 0.12, 0.5, segments: 16),
            _rt_Material3D(color: _rt_Tw.red500, shininess: 0.5)
              ..emissive = const Color(0xFF7F1D1D),
          )
          ..position.set(-0.7, 0.5, 0)
          ..pickable = false,
      )
      ..add(
        _rt_Mesh3D(
            _rt_Geometry3D.cylinder(0.12, 0.12, 0.5, segments: 16),
            _rt_Material3D(color: _blue, shininess: 0.5)
              ..emissive = const Color(0xFF1E3A8A),
          )
          ..position.set(0.7, 0.5, 0)
          ..pickable = false,
      );

    // Wire connectors (phase 2) and the wires they create.
    for (final MapEntry(key: id, value: (x, y, z)) in _nodePos.entries) {
      _nodes[id] = _scene.add(
        _rt_Sphere3D(
            0.22,
            _rt_Material3D(color: _nodeColor(id), shininess: 0.6)
              ..edgeColor = Colors.white
              ..edgeWidth = 2,
          )
          ..position.set(x, y, z)
          ..visible = false
          ..pickable = false,
      );
    }
    for (final (from, to) in [(_anode, _pos), (_cathode, _neg)]) {
      final (x1, y1, z1) = _nodePos[from]!;
      final (x2, y2, z2) = _nodePos[to]!;
      final a = _rt_V3(x1, y1, z1), b = _rt_V3(x2, y2, z2);
      final c = _rt_V3(x1, 4, 2); // HTML QuadraticBezierCurve3 control point
      _wires[from] = _scene.add(
        _rt_Mesh3D(
            _rt_Geometry3D.tube([
              for (var i = 0; i <= 24; i++) _bezier(a, c, b, i / 24),
            ], 0.06),
            _rt_Material3D(color: _indigo, shininess: 0.6)
              ..emissive = const Color(0xFF312E81),
          )
          ..visible = false
          ..pickable = false,
      );
    }

    // Salt crystals: they rain into the tank, settle and dissolve on stirring.
    _saltLand = [
      for (var i = 0; i < 40; i++)
        _rt_V3(
          (_rng.nextDouble() - 0.5) * 4.8,
          -1.85,
          (_rng.nextDouble() - 0.5) * 2.2,
        ),
    ];
    _saltDelay = [for (var i = 0; i < 40; i++) _rng.nextDouble() * 0.45];
    _salt = _scene.add(
      _rt_Points3D([for (final p in _saltLand) p.clone()])
        ..color = Colors.white
        ..size = 1.6
        ..visible = false
        ..pickable = false,
    );

    // Gas bubbles: greenish chlorine at the anode, hydrogen at the cathode.
    _rt_Points3D bubbles(Color color, double opacity) => _scene.add(
      _rt_Points3D([for (var i = 0; i < 16; i++) _rt_V3()])
        ..color = color
        ..opacity = opacity
        ..size = 2
        ..visible = false
        ..pickable = false,
    );
    _bubblesCl = bubbles(_gasGreen, 0.85);
    _bubblesH = bubbles(Colors.white, 0.7);
    for (var i = 0; i < 32; i++) {
      _bubbleSpeed.add(2.4 + _rng.nextDouble() * 1.2);
    }

    // Phase 4: indicator drops and the pink cloud around the cathode.
    _drops = _scene.add(
      _rt_Points3D([for (var i = 0; i < 5; i++) _rt_V3()])
        ..color = _pink
        ..size = 2.6
        ..visible = false
        ..pickable = false,
    );
    _cloudMat = _rt_Material3D(color: const Color(0xFFFF69B4), opacity: 0)
      ..unlit = true;
    _cloud = _scene.add(
      _rt_Sphere3D(0.9, _cloudMat)
        ..position.set(1.5, -0.95, 0)
        ..visible = false
        ..pickable = false,
    );

    for (var i = 0; i < _labelKeys.length; i++) {
      final (x, y, z) = _labelPos[i];
      _labels.add(
        _scene.add(
          _rt_Label3D(
              _tx.s(_labelKeys[i]),
              position: _rt_V3(x, y, z),
              worldHeight: 0.32,
              background: _labelBg,
            )
            ..visible = false
            ..pickable = false,
        ),
      );
    }
    _styleLabels();
  }

  static _rt_V3 _bezier(_rt_V3 a, _rt_V3 c, _rt_V3 b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * t * (1 - t)) + b * (t * t);

  static Color _nodeColor(String id) => switch (id) {
    _pos => _rt_Tw.red500,
    _neg => _blue,
    _ => _silver,
  };

  void _setWater(double h) {
    _water
      ..scale.y = h
      ..position.y = -1.99 + h / 2;
  }

  /// One view of the whole plant. Short landscape phones get a wider view so
  /// the HUD and the action bar do not cover the apparatus; in phases 3-4
  /// (no battery work) they look slightly higher so the electrodes sit
  /// between the HUD and the bottom bar.
  void _frame() {
    final compact = _compact ?? false;
    final low = compact && (_step == 3 || _step == 4);
    _camera.position.set(0, 5.5, 12.5);
    _camera.target.set(0, low ? 1.7 : 1, 0.8);
    _camera.zoom = compact ? (low ? 0.9 : 0.88) : 0.95;
    _camera.saveHome();
  }

  void _syncScene() {
    for (final n in _nodes.values) {
      n.visible = _step == 2;
    }
    final shown = {
      if (_step >= 1) ...[0, 1, 2],
      if (_gasPlaced.contains(_cl2Tool)) 3,
      if (_gasPlaced.contains(_h2Tool)) 4,
    };
    for (var i = 0; i < _labels.length; i++) {
      _labels[i].visible = _labelsVisible && shown.contains(i);
    }
    _bubblesCl.visible = _bubblesH.visible = _powerOn;
  }

  /// Electrode labels light up while a gas label hovers over them; placed
  /// gas labels take the colour of their gas.
  void _styleLabels() {
    for (final (i, id, color) in [
      (0, _anode, _rt_Tw.red500),
      (1, _cathode, _blue),
    ]) {
      final hot = _gasHover == id;
      _labels[i]
        ..background = hot ? color.withValues(alpha: 0.85) : _labelBg
        ..borderColor = hot ? Colors.white : color;
    }
    _labels[2].borderColor = _rt_Tw.slate400;
    _labels[3]
      ..borderColor = _gasGreen
      ..color = _gasGreen;
    _labels[4]
      ..borderColor = _sky
      ..color = const Color(0xFFBAE6FD);
  }

  void _spawnBubble(_rt_V3 b, double x, {bool anywhere = false}) {
    final a = _rng.nextDouble() * math.pi * 2;
    final r = 0.24 + _rng.nextDouble() * 0.1;
    b.set(
      x + math.cos(a) * r,
      anywhere ? -1.5 + _rng.nextDouble() * 2.9 : -1.5,
      math.sin(a) * r,
    );
  }

  // ---------------------------------------------------------------- flow

  void _begin() {
    _boardVisible = false;
    _advance();
  }

  void _advance() {
    _advanceTimer?.cancel();
    setState(() {
      _step++;
      _openSteps.clear();
      if (_step == 1) _fillT = 0;
    });
    _syncScene();
    if (_step == 3 || _step == 5) _frame();
  }

  void _advanceAfter(Duration delay, {String? toastKey}) {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(delay, () {
      if (!mounted) return;
      if (toastKey != null) {
        _shell.showToast(_tx.s(toastKey), color: _indigo);
      }
      _advance();
    });
  }

  void _logRow(String action, String result) {
    setState(() {
      _logShown = true;
      _log.add((action, result));
    });
  }

  void _restart() {
    _advanceTimer?.cancel();
    _setWater(0.1);
    _waterMat
      ..color = _waterCyan
      ..emissive = _waterGlow;
    _salt
      ..visible = false
      ..opacity = 1;
    _drops.visible = false;
    _cloud.visible = false;
    _cloudMat.opacity = 0;
    for (final w in _wires.values) {
      w.visible = false;
    }
    setState(() {
      _step = 0;
      _boardVisible = true;
      _fillT = _saltT = _stirT = _pinkT = null;
      _saltAdded = _brineReady = false;
      _wired.clear();
      _wireStart = _pendingNode = null;
      _wireDown = _wireFrom = _wireTo = null;
      _powerOn = false;
      _gasPlaced.clear();
      _gasHover = null;
      _indicatorAdded = _pinkDone = false;
      _quizPick = null;
      _quizSolved = false;
      _mapOpen = false;
      _selProduct = _selUse = null;
      _matched.clear();
      _logShown = false;
      _logOpen = null;
      _log.clear();
      _openSteps.clear();
    });
    _styleLabels();
    _syncScene();
    _frame();
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _rt_playSfx(_rt_Sfx.scenario);
  }

  void _onFrame(double dt) {
    _time += dt;

    final fill = _fillT;
    if (fill != null) {
      final p = math.min(1.0, fill + dt / 2);
      _setWater(0.1 + 3.4 * Curves.easeInOut.transform(p));
      if (p >= 1) {
        setState(() => _fillT = null);
      } else {
        _fillT = p;
      }
    }

    final salt = _saltT;
    if (salt != null) {
      final p = math.min(1.0, salt + dt / 1.4);
      _waterMat.color = Color.lerp(_waterCyan, _brineBlue, p)!;
      for (var i = 0; i < _saltLand.length; i++) {
        final land = _saltLand[i];
        final k = Curves.easeIn.transform(
          ((p - _saltDelay[i]) / 0.55).clamp(0.0, 1.0),
        );
        _salt.points[i].copy(
          _rt_V3(land.x * 0.25, 2.6, land.z * 0.25).lerp(land, k),
        );
      }
      if (p >= 1) {
        setState(() => _saltT = null);
      } else {
        _saltT = p;
      }
    }

    final stir = _stirT;
    if (stir != null) {
      final p = math.min(1.0, stir + dt / 1.5);
      for (var i = 0; i < _saltLand.length; i++) {
        final land = _saltLand[i];
        final a = p * math.pi * (3 + (i % 3));
        final c = math.cos(a), s = math.sin(a);
        _salt.points[i].set(
          land.x * c - land.z * s,
          land.y + p * (0.5 + (i % 5) * 0.4),
          land.x * s + land.z * c,
        );
      }
      _salt.opacity = 1 - p;
      _stirT = p;
      if (p >= 1) {
        _stirT = null;
        _salt.visible = false;
        _rt_playSfx(_rt_Sfx.success);
        setState(() => _brineReady = true);
        _advanceAfter(const Duration(milliseconds: 500), toastKey: 'msg_brine');
      }
    }

    if (_step == 2) _pulseNodes();

    if (_powerOn) {
      for (var i = 0; i < 16; i++) {
        for (final (cloud, x, k) in [
          (_bubblesCl, -1.5, i),
          (_bubblesH, 1.5, i + 16),
        ]) {
          final b = cloud.points[i];
          b.y += _bubbleSpeed[k] * dt;
          if (b.y > 1.45) _spawnBubble(b, x);
        }
      }
    }

    final pink = _pinkT;
    if (pink != null) {
      final p = math.min(1.0, pink + dt / 2);
      for (var i = 0; i < _drops.points.length; i++) {
        final k = ((p - i * 0.05) / 0.25).clamp(0.0, 1.0);
        _drops.points[i].set(0.9 + (i % 2) * 0.15, 3.3 - k * 1.8, 0.3);
      }
      _drops.visible = p < 0.45;
      _cloudMat.opacity = 0.5 * Curves.easeOut.transform(p);
      final w = Curves.easeInOut.transform(((p - 0.2) / 0.8).clamp(0.0, 1.0));
      _waterMat
        ..color = Color.lerp(_brineBlue, _pinkWater, w)!
        ..emissive = Color.lerp(_waterGlow, _pinkGlow, w);
      if (p >= 1) {
        setState(() {
          _pinkT = null;
          _pinkDone = true;
        });
        _logRow('log_ind_act', 'log_ind_res');
      } else {
        _pinkT = p;
      }
    }
  }

  // ------------------------------------------- phases 1 & 4: tool drops

  void _onDrop(String tool) {
    switch ((_step, tool)) {
      case (1, _saltTool) when !_saltAdded:
        _rt_playSfx(_rt_Sfx.correct);
        _salt
          ..visible = true
          ..opacity = 1;
        setState(() {
          _saltAdded = true;
          _saltT = 0;
        });
        _logRow('log_salt_act', 'log_salt_res');
      case (4, _indicatorTool) when !_indicatorAdded:
        _rt_playSfx(_rt_Sfx.magic);
        _drops.visible = true;
        _cloud.visible = true;
        setState(() {
          _indicatorAdded = true;
          _pinkT = 0;
        });
    }
  }

  void _stir() {
    if (_saltT != null || _stirT != null) return;
    setState(() => _stirT = 0);
  }

  // ------------------------------------------------ phase 2: wiring

  bool _isWired(String id) =>
      _wired.contains(id) || _wired.contains(_partner[id]);

  void _pulseNodes() {
    final s = 1 + 0.15 * math.sin(_time * 5);
    for (final MapEntry(key: id, value: n) in _nodes.entries) {
      final active = id == _wireStart || id == _pendingNode;
      if (_isWired(id)) {
        n
          ..material.color = _emerald
          ..radius = 0.2;
      } else {
        n
          ..material.color = active ? _indigoLight : _nodeColor(id)
          ..radius = active ? 0.3 : 0.22 * s;
      }
    }
  }

  /// Nearest free connector to the pointer, with a finger-sized catch radius.
  String? _nodeAt(_rt_SceneEvent e, {String? except}) {
    String? best;
    var bestD = double.infinity;
    for (final MapEntry(key: id, value: n) in _nodes.entries) {
      if (id == except || _isWired(id)) continue;
      final c = n.worldPosition;
      final s = e.frame.project(c);
      if (s == null) continue;
      final r = n.radius * e.frame.pixelsPerUnit(e.frame.depthOf(c));
      final d = (s - e.position).distance;
      if (d < math.max(34.0, r + 14) && d < bestD) {
        best = id;
        bestD = d;
      }
    }
    return best;
  }

  bool _onPointerDown(_rt_SceneEvent e) {
    if (_step != 2 || _powerOn) return false;
    final id = _nodeAt(e);
    if (id == null) return false;
    final pending = _pendingNode;
    if (pending != null && pending != id) {
      // Second tap of a tap-then-tap connection.
      setState(() => _pendingNode = null);
      _connect(pending, id);
      return true;
    }
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _pendingNode = null;
      _wireStart = id;
      _wireDown = e.position;
      _wireFrom = e.frame.project(_nodes[id]!.worldPosition);
      _wireTo = e.position;
    });
    return true;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    if (_wireStart == null) return;
    setState(() => _wireTo = e.position);
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final start = _wireStart;
    if (start == null) return;
    final end = _nodeAt(e, except: start);
    final tapped = (e.position - (_wireDown ?? e.position)).distance < 12;
    setState(() {
      _wireStart = null;
      _wireDown = _wireFrom = _wireTo = null;
      // A tap without dragging selects the connector for a second tap.
      if (end == null && tapped) _pendingNode = start;
    });
    if (end != null) _connect(start, end);
  }

  void _connect(String a, String b) {
    if (_partner[a] != b) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('err_wire'),
        color: _rt_Tw.red500,
        icon: Icons.error_outline,
      );
      return;
    }
    final electrode = a == _anode || a == _cathode ? a : b;
    _rt_playSfx(_rt_Sfx.correct);
    _wires[electrode]!.visible = true;
    setState(() => _wired.add(electrode));
    if (_wired.length < 2) {
      _shell.showToast(_tx.s('msg_wired'), color: _emerald);
    }
  }

  void _switchOn() {
    if (_powerOn) return;
    _rt_playSfx(_rt_Sfx.success);
    for (var i = 0; i < 16; i++) {
      _spawnBubble(_bubblesCl.points[i], -1.5, anywhere: true);
      _spawnBubble(_bubblesH.points[i], 1.5, anywhere: true);
    }
    setState(() => _powerOn = true);
    _syncScene();
    _logRow('log_power_act', 'log_power_res');
    _advanceAfter(const Duration(milliseconds: 1200));
  }

  // ------------------------------------------------ phase 3: gas labels

  static double _segmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.distanceSquared;
    final t = len2 == 0
        ? 0.0
        : (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }

  /// The electrode nearest to a dragged label (projected from the 3D rods,
  /// so it follows the camera), or null when the label is far from both.
  String? _electrodeAt(Offset global) {
    final box = _gasTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final p = box.globalToLocal(global);
    final f = _camera.frame(box.size);
    String? best;
    var bestD = math.max(60.0, box.size.height * 0.2);
    for (final (id, x) in [(_anode, -1.5), (_cathode, 1.5)]) {
      final a = f.project(_rt_V3(x, -1.5, 0));
      final b = f.project(_rt_V3(x, 3.5, 0));
      if (a == null || b == null) continue;
      final d = _segmentDistance(p, a, b);
      if (d < bestD) {
        best = id;
        bestD = d;
      }
    }
    return best;
  }

  void _hoverGas(Offset? global) {
    final hover = global == null ? null : _electrodeAt(global);
    if (hover == _gasHover) return;
    _gasHover = hover;
    _styleLabels();
  }

  void _dropGas(String tool, Offset global) {
    final at = _electrodeAt(global);
    _hoverGas(null);
    if (at == null || _gasPlaced.contains(tool)) return;
    final ok =
        (tool == _cl2Tool && at == _anode) ||
        (tool == _h2Tool && at == _cathode);
    if (!ok) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('err_gas'),
        color: _rt_Tw.red500,
        icon: Icons.error_outline,
      );
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _gasPlaced.add(tool));
    _syncScene();
    if (tool == _cl2Tool) {
      _logRow('log_anode_act', 'log_anode_res');
    } else {
      _logRow('log_cathode_act', 'log_cathode_res');
    }
    if (_gasPlaced.length == 2) {
      _advanceAfter(const Duration(seconds: 1), toastKey: 'msg_gases');
    }
  }

  // ---------------------------------------------------- phase 4: quiz

  void _verifyQuiz() {
    if (_quizPick == 'b') {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _quizSolved = true);
      _shell.showToast(_tx.s('quiz_correct'), color: _emerald);
      _logRow('log_quiz_act', 'log_quiz_res');
      _advanceAfter(const Duration(seconds: 1));
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('err_quiz'),
        color: _rt_Tw.red500,
        icon: Icons.error_outline,
      );
    }
  }

  // --------------------------------------------- phase 5: industrial map

  void _pickMap(String id, {required bool product}) {
    if (_matched.contains(id) || _matched.length == 6) return;
    setState(() {
      if (product) {
        _selProduct = id;
      } else {
        _selUse = id;
      }
    });
    final p = _selProduct, u = _selUse;
    if (p == null || u == null) {
      _rt_playSfx(_rt_Sfx.tap);
      return;
    }
    if (_mapPairs[p] != u) {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() => _selProduct = _selUse = null);
      _shell.showToast(
        _tx.s('err_match'),
        color: _rt_Tw.red500,
        icon: Icons.error_outline,
      );
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() {
      _matched.addAll([p, u]);
      _selProduct = _selUse = null;
    });
    _logRow(p, u);
    if (_matched.length == 6) _finish();
  }

  void _finish() {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _mapOpen = false;
        _step = _lastStep + 1;
      });
      _syncScene();
      _showSummary(_rt_Sfx.curtain);
    });
  }

  void _showSummary(_rt_Sfx sound) {
    _shell.showSuccess(
      title: _tx.s('badge_title'),
      message: _tx.s('summary_msg'),
      body: _summaryBody(),
      icon: Icons.military_tech,
      color: _indigo,
      sound: sound,
      buttonLabel: _tx.s('btn_restart'),
      onConfirm: _restart,
    );
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 480;
    if (compact != _compact) {
      _compact = compact;
      _frame();
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          for (var i = 0; i < _labels.length; i++) {
            _labels[i].text = _tx.s(_labelKeys[i]);
          }
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _indigoDark,
              headerGradient: [_rt_Tw.slate900, Color(0xFF312E81)],
              headerSubtitleColor: Color(0xFFC7D2FE),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.factory,
              buttonIcon: Icons.play_arrow,
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
              _rt_RotatePanToggle(controller: _viewCtrl, accent: _indigoDark),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.science,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              onFrame: _onFrame,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              cameraControls: !_camLocked,
            ),
            canvasOverlays: [
              if (_step >= 1 && _step <= _lastStep) _hudOverlay(),
              if (_logShown) _logOverlay(),
              if (_wireFrom != null && _wireTo != null) _wireOverlay(),
              if (_dropKey != null) _dropTargetOverlay(_dropKey!),
              if (_step == 3) _gasTargetOverlay(),
              if (_hasTask) _taskOverlay(),
              if (_step == 4 && _pinkDone) _quizOverlay(),
              if (_step == 5 && _mapOpen) _mapOverlay(),
              if (_step == 0 && _boardVisible) _boardOverlay(),
            ],
          );
        },
      ),
    );
  }

  /// The tool expected on the central drop target, or null when it is hidden.
  String? get _dropKey => switch (_step) {
    1 when _fillT == null && !_saltAdded => _saltTool,
    4 when !_indicatorAdded => _indicatorTool,
    _ => null,
  };

  bool get _hasTask => switch (_step) {
    1 => _fillT == null && !_brineReady,
    2 => _wired.length == 2 && !_powerOn,
    3 => _gasPlaced.length < 2,
    4 => !_indicatorAdded,
    5 => !_mapOpen,
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
            color: on ? _indigoDark : _rt_Lab.surface,
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
    final compact = _compact ?? false;
    final concept = (_tx.list('steps')[_step - 1] as Map)['concept'];
    final instruction = switch (_step) {
      1 when _fillT != null => _tx.s('hud_fill'),
      1 when _saltAdded => _tx.s('hud_stir'),
      2 when _wired.length == 2 => _tx.s('hud_switch'),
      4 when _pinkDone => _tx.s('hud_quiz'),
      _ => _tx.s('hud.${_step - 1}'),
    };
    return Positioned(
      key: const ValueKey('hud'),
      top: compact ? 8 : 14,
      left: 70,
      right: compact ? 56 : 70,
      child: IgnorePointer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 6 : 10,
            ),
            decoration: _cardDecoration(_indigo),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!compact)
                  Text(
                    _tx.s('hud_mission').toUpperCase(),
                    style: TextStyle(
                      color: _rt_Lab.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 15, color: _indigo),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${_tx.s('phase')} $_step: $concept'.toUpperCase(),
                        style: TextStyle(
                          color: _indigo,
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rt_Lab.text,
                    fontSize: compact ? 11.5 : 13,
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
    final open = _logOpen ?? !(_compact ?? false);
    final head = TextStyle(
      color: _rt_Lab.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w900,
    );
    final cell = TextStyle(color: _rt_Lab.text, fontSize: 11);
    // Collapsed, the log is a small icon chip with the row count, so on a
    // phone it never covers the electrodes or the battery.
    final header = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        _rt_playSfx(_rt_Sfx.tap);
        setState(() => _logOpen = !open);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.table_chart_outlined, size: 16, color: _indigo),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                open ? _tx.s('data_log') : '${_log.length}',
                style: TextStyle(
                  color: _rt_Lab.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              open ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: _rt_Lab.textMuted,
            ),
          ],
        ),
      ),
    );
    return Positioned(
      key: const ValueKey('log'),
      top: (_compact ?? false) ? 92 : 110,
      left: 12,
      child: Container(
        width: open ? 250 : null,
        padding: EdgeInsets.all(open ? 12 : 6),
        decoration: _cardDecoration(_indigo),
        child: !open
            ? header
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: header),
                      TextButton(
                        onPressed: () {
                          _rt_playSfx(_rt_Sfx.click);
                          setState(_log.clear);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _rt_Tw.red500,
                          visualDensity: VisualDensity.compact,
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
                      constraints: const BoxConstraints(maxHeight: 190),
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(color: _rt_Lab.border),
                          ),
                          children: [
                            TableRow(
                              children: [
                                Text(
                                  _tx.s('th_action').toUpperCase(),
                                  style: head,
                                ),
                                Text(
                                  _tx.s('th_result').toUpperCase(),
                                  style: head,
                                ),
                              ],
                            ),
                            for (final (action, result) in _log)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(_tx.s(action), style: cell),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
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

  /// Rubber-band wire while a connector is being dragged (HTML `#temp-wire`).
  Widget _wireOverlay() {
    return Positioned.fill(
      key: const ValueKey('wire'),
      child: IgnorePointer(
        child: CustomPaint(painter: _WirePainter(_wireFrom!, _wireTo!)),
      ),
    );
  }

  Widget _taskOverlay() {
    // A full-canvas layer stays fixed in the shell, so the action bar cannot
    // be dragged away: a slightly wobbly finger press on a phone used to move
    // the bar instead of pressing its button. Empty space still reaches the
    // 3D view underneath.
    return Positioned.fill(
      key: const ValueKey('task'),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all((_compact ?? false) ? 10 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: switch (_step) {
              1 when !_saltAdded => _toolTray(
                _saltTool,
                Icons.shopping_bag,
                _silver,
                'salt_tool',
                'salt_inst',
                caption: 'NaCl',
              ),
              1 => _pillButton(
                Icons.autorenew,
                _tx.s('btn_stir'),
                _indigoDark,
                _saltT == null && _stirT == null ? _stir : null,
              ),
              2 => _pillButton(
                Icons.power_settings_new,
                _tx.s('btn_switch'),
                _emerald,
                _switchOn,
              ),
              3 => _gasTray(),
              4 => _toolTray(
                _indicatorTool,
                Icons.colorize,
                _pink,
                'lbl_indicator',
                'indicator_inst',
              ),
              _ => _pillButton(
                Icons.map_outlined,
                _tx.s('s5_btn'),
                _indigoDark,
                () => setState(() => _mapOpen = true),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _pillButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    // heightFactor 1: inside the pinned bottom bar a plain Center would take
    // the full canvas height and float the pill over the middle of the scene.
    return Center(
      heightFactor: 1,
      child: _PressButton(
        onPressed: onTap == null
            ? null
            : () {
                _rt_playSfx(_rt_Sfx.click);
                onTap();
              },
        child: Material(
          color: onTap == null ? color.withValues(alpha: 0.45) : color,
          elevation: 6,
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      fontSize: 12,
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
    );
  }

  Widget _toolChip(
    IconData icon,
    Color color, {
    String? caption,
    bool dragging = false,
  }) {
    final size = (_compact ?? false) ? 54.0 : 64.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dragging ? 0.9 : 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: caption == null ? size / 2 : size * 0.4,
            color: dragging
                ? (color.computeLuminance() > 0.5
                      ? _rt_Tw.slate900
                      : Colors.white)
                : color,
          ),
          if (caption != null)
            Text(
              caption,
              style: TextStyle(
                color: dragging ? _rt_Tw.slate900 : color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }

  /// Draggable tool card (the HTML salt sack and indicator dropper).
  Widget _toolTray(
    String tool,
    IconData icon,
    Color color,
    String titleKey,
    String instKey, {
    String? caption,
  }) {
    return Container(
      padding: EdgeInsets.all((_compact ?? false) ? 9 : 12),
      decoration: _cardDecoration(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Draggable<String>(
            data: tool,
            onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
            feedback: Material(
              color: Colors.transparent,
              child: _toolChip(icon, color, caption: caption, dragging: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _toolChip(icon, color, caption: caption),
            ),
            child: _toolChip(icon, color, caption: caption),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s(titleKey).toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _tx.s(instKey),
                  style: TextStyle(color: _rt_Lab.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gasChip(String tool, {bool dragging = false}) {
    final cl = tool == _cl2Tool;
    final color = cl ? _gasGreen : _sky;
    final compact = _compact ?? false;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: dragging
            ? color
            : (cl ? const Color(0xE614532D) : const Color(0xE61E3A8A)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        _tx.s(cl ? 'lbl_cl2' : 'lbl_h2'),
        style: TextStyle(
          color: dragging
              ? _rt_Tw.slate900
              : (cl ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD)),
          fontSize: compact ? 13 : 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  /// The two draggable gas labels (HTML `#lbl-cl2` / `#lbl-h2`).
  Widget _gasTray() {
    // On short phones the HUD already gives the instruction: keep the tray
    // a slim row of labels so the electrodes stay in view.
    final compact = _compact ?? false;
    return Container(
      padding: EdgeInsets.all(compact ? 7 : 12),
      decoration: _cardDecoration(_indigo),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tool in const [_cl2Tool, _h2Tool])
            if (!_gasPlaced.contains(tool))
              Padding(
                padding: compact
                    ? const EdgeInsets.symmetric(horizontal: 5)
                    : const EdgeInsets.only(right: 10),
                child: Draggable<String>(
                  data: tool,
                  // The drop point is the finger itself, centred under the
                  // label, so it can be compared with the projected rods.
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
                  onDragEnd: (_) => _hoverGas(null),
                  feedback: Material(
                    color: Colors.transparent,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, -0.5),
                      child: _gasChip(tool, dragging: true),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _gasChip(tool),
                  ),
                  child: _gasChip(tool),
                ),
              ),
          if (!compact)
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tx.s('gas_tool').toUpperCase(),
                    style: const TextStyle(
                      color: _indigo,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _tx.s('gas_inst'),
                    style: TextStyle(color: _rt_Lab.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _dropTargetOverlay(String tool) {
    final (textKey, color) = tool == _saltTool
        ? ('drop_salt', _silver)
        : ('drop_indicator', _pink);
    final size = (_compact ?? false) ? 150.0 : 190.0;
    return Positioned.fill(
      key: const ValueKey('drop'),
      child: Center(
        child: DragTarget<String>(
          onWillAcceptWithDetails: (d) => d.data == tool,
          onAcceptWithDetails: (d) => _onDrop(d.data),
          builder: (context, candidates, _) {
            final hot = candidates.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: hot ? size + 20 : size,
              height: hot ? size + 20 : size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: hot ? 0.3 : 0.1),
                border: Border.all(color: color, width: 3),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Text(
                _tx.s(textKey).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Invisible full-canvas target for the gas labels; the drop point is
  /// matched against the projected electrodes in [_dropGas].
  Widget _gasTargetOverlay() {
    return Positioned.fill(
      key: const ValueKey('gas'),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (d) => d.data == _cl2Tool || d.data == _h2Tool,
        onMove: (d) => _hoverGas(d.offset),
        onLeave: (_) => _hoverGas(null),
        onAcceptWithDetails: (d) => _dropGas(d.data, d.offset),
        builder: (context, _, _) => SizedBox.expand(key: _gasTargetKey),
      ),
    );
  }

  Widget _quizOverlay() {
    return Positioned.fill(
      key: const ValueKey('quiz'),
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(_pink),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline, color: _pink),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tx.s('quiz_title').toUpperCase(),
                          style: const TextStyle(
                            color: _pink,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tx.s('quiz_q'),
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final o in const ['a', 'b']) _quizOption(o),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Answer tile; like the HTML quiz buttons, a tap answers at once.
  Widget _quizOption(String o) {
    final picked = _quizPick == o;
    final color = picked
        ? (_quizSolved ? _emerald : _rt_Tw.red500)
        : _rt_Lab.border;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: picked ? color.withValues(alpha: 0.15) : _rt_Lab.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: picked ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _quizSolved
              ? null
              : () {
                  setState(() => _quizPick = o);
                  _verifyQuiz();
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  picked
                      ? (_quizSolved ? Icons.check_circle : Icons.cancel)
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: picked ? color : _rt_Lab.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tx.s('quiz_$o'),
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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

  /// Industrial map modal (HTML `#modal-map`): pick a product, then its use.
  Widget _mapOverlay() {
    final compact = _compact ?? false;
    Widget column(String headKey, List<String> ids, {required bool product}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s(headKey).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _rt_Lab.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          for (final id in ids) _mapCard(id, product: product),
        ],
      );
    }

    return Positioned.fill(
      key: const ValueKey('map'),
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 8 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: EdgeInsets.all(compact ? 14 : 22),
              decoration: _cardDecoration(_indigo),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map_outlined, color: _indigo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tx.s('map_title'),
                          style: TextStyle(
                            color: _rt_Lab.text,
                            fontSize: compact ? 15 : 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 10 : 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: column(
                          'map_products',
                          _mapPairs.keys.toList(),
                          product: true,
                        ),
                      ),
                      SizedBox(width: compact ? 12 : 24),
                      Expanded(
                        child: column('map_uses', _mapUses, product: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tx.s(_matched.length == 6 ? 'map_done' : 'map_instr'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _matched.length == 6
                          ? _emerald
                          : _rt_Lab.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
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

  Widget _mapCard(String id, {required bool product}) {
    final compact = _compact ?? false;
    final matched = _matched.contains(id);
    final selected = (product ? _selProduct : _selUse) == id;
    final accent = matched ? _emerald : _indigo;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 6 : 10),
      child: Material(
        color: matched || selected
            ? _rt_Lab.tinted(
                matched ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF),
                accent,
              )
            : _rt_Lab.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: matched || selected ? accent : _rt_Lab.border,
            width: matched || selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: matched ? null : () => _pickMap(id, product: product),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: compact ? 10 : 14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (matched) ...[
                  const Icon(Icons.check_circle, size: 16, color: _emerald),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    _tx.s(id),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: matched ? _emerald : _rt_Lab.text,
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w800,
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

  Widget _boardOverlay() {
    // Compact variant so the start button fits on short landscape phones.
    final compact = MediaQuery.sizeOf(context).height < 480;
    final ctx = _tx.list('ctx');
    const icons = [Icons.water_drop, Icons.soap, Icons.layers];
    const colors = [Color(0xFF22D3EE), _purple, Color(0xFFFB923C)];
    return Positioned.fill(
      key: const ValueKey('board'),
      child: Container(
        color: _rt_Lab.base.withValues(alpha: 0.9),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 8 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: EdgeInsets.all(compact ? 14 : 24),
              decoration: _cardDecoration(_indigo),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!compact) ...[
                    const Icon(Icons.factory, size: 54, color: _indigo),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (compact) ...[
                        const Icon(Icons.factory, size: 20, color: _indigo),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          _tx.s('lab_mission').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _indigo,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 4 : 8),
                  Text(
                    _tx.s('objective'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: compact ? 12.5 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 16),
                  Text(
                    _tx.s('ctx_title').toUpperCase(),
                    style: TextStyle(
                      color: _rt_Lab.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < ctx.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _contextCard(
                            icons[i],
                            colors[i],
                            ctx[i] as Map,
                            compact,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: compact ? 12 : 20),
                  _rt_ActionButton(
                    label: _tx.s('board_btn'),
                    icon: Icons.play_arrow,
                    color: _indigoDark,
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

  /// "Why learn this?" card (HTML context tab).
  Widget _contextCard(IconData icon, Color color, Map data, bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        children: [
          if (!compact) ...[
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (compact) ...[
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  '${data['t']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rt_Lab.text,
                    fontSize: compact ? 11 : 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${data['d']}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _rt_Lab.textMuted,
              fontSize: compact ? 10 : 11,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// Outcomes shown in the final popup (HTML "Outcomes" tab).
  Widget _summaryBody() {
    Widget heading(IconData icon, Color color, String key) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            _tx.s(key),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
    const borders = [_rt_Tw.red500, _blue, _purple];
    final keys = _tx.list('keys');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _reactionBox(),
        const SizedBox(height: 12),
        heading(Icons.lightbulb_outline, _sky, 'key_title'),
        for (var i = 0; i < keys.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: borders[i], width: 4)),
            ),
            child: _keyValue(keys[i] as Map),
          ),
        const SizedBox(height: 8),
        heading(Icons.school, _indigo, 'out_title'),
        for (final o in _tx.list('outs'))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 16, color: _emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$o',
                    style: TextStyle(color: _rt_Lab.text, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _keyValue(Map data) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '${data['k']} ',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        TextSpan(text: '${data['v']}'),
      ],
    ),
    style: TextStyle(color: _rt_Lab.text, fontSize: 12, height: 1.35),
  );

  Widget _reactionBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('reaction_title'),
            style: const TextStyle(
              color: _indigoLight,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s('reaction'),
            style: TextStyle(
              color: _rt_Lab.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
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
          title: _tx.s('lab_mission'),
          desc: _tx.s('lab_desc'),
          accent: _indigoDark,
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
              if (_step > _lastStep) _completeTile(),
              _guideTile(),
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
              color: _indigoLight,
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
            ? _rt_Lab.tinted(const Color(0xFFEEF2FF), _indigo)
            : (done
                  ? _rt_Lab.tinted(const Color(0xFFECFDF5), _emerald)
                  : _rt_Lab.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? _indigo
              : (done ? _emerald.withValues(alpha: 0.5) : _rt_Lab.border),
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
                      color: done
                          ? _emerald
                          : (current ? _indigo : _rt_Lab.overlay),
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
                      '${_tx.s('phase')} $n: ${data['concept']}',
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
                  Text(
                    '${data['desc']}',
                    style: TextStyle(
                      color: _rt_Lab.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  detail(_tx.s('action'), data['action']),
                  const SizedBox(height: 6),
                  // The observation is the answer: reveal it once the phase
                  // is done; the current phase shows the HTML tip instead.
                  if (done)
                    detail(_tx.s('observation'), data['observation'])
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: Color(0xFFFACC15),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_tx.s('tip')}: ${data['tip']}',
                            style: TextStyle(
                              color: _rt_Lab.textMuted,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// HTML phase 6 card: outcomes + restart.
  Widget _completeTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(const Color(0xFFECFDF5), _emerald),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _emerald, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 18, color: _emerald),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s('s6_t'),
                  style: TextStyle(
                    color: _rt_Lab.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s('s6_d'),
            style: TextStyle(color: _rt_Lab.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _rt_ActionButton(
                label: _tx.s('btn_outcomes'),
                icon: Icons.school,
                color: _indigoDark,
                onPressed: () => _showSummary(_rt_Sfx.success),
              ),
              _rt_ActionButton(
                label: _tx.s('btn_restart'),
                icon: Icons.refresh,
                color: _rt_Tw.slate600,
                onPressed: _restart,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// HTML "Teacher's Guide" tab, folded into the experiment sidebar.
  Widget _guideTile() {
    const badges = [('A', _gasGreen), ('C', _sky), ('S', _pink)];
    final guide = _tx.list('guide');
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() => _guideOpen = !_guideOpen);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.cast_for_education, size: 18, color: _sky),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tx.s('guide_title'),
                      style: TextStyle(
                        color: _rt_Lab.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _guideOpen ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: _rt_Lab.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_guideOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reactionBox(),
                  const SizedBox(height: 8),
                  for (var i = 0; i < guide.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: badges[i].$2.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              badges[i].$1,
                              style: TextStyle(
                                color: badges[i].$2,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _keyValue(guide[i] as Map)),
                        ],
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

/// Rubber-band wire from the pressed connector to the finger.
class _WirePainter extends CustomPainter {
  _WirePainter(this.from, this.to);

  final Offset from, to;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawLine(
        from,
        to,
        Paint()
          ..color = _indigo.withValues(alpha: 0.35)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(
        from,
        to,
        Paint()
          ..color = _indigo
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_WirePainter old) => old.from != from || old.to != to;
}

/// Button that fires when the finger is lifted inside it, like a browser
/// click. A normal Flutter tap is cancelled once the finger rolls past the
/// phone's ~8 dp touch slop, which made a child's slightly wobbly press on
/// an action button do nothing.
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
