// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 4.5: Manufacturing Soap
// Converted from Cl10S-Ch4-A5-ManufacturingSoap.html (three.js -> mini3d).
//
// Four guided steps: pour castor oil and sodium hydroxide into a beaker
// (immiscible layers), carry the beaker onto a tripod and stir and heat it
// (saponification), add a spatula of salt (salting out, soap curds), and
// touch red litmus paper to the solid soap (it turns blue).

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
    'headerTitle': 'Manufacturing Soap',
    'headerSubtitle': 'Class 10: Carbon and its Compounds',
    'intro': {
      'title': 'Manufacturing Soap',
      'subtitle': 'Class 10: Carbon and its Compounds',
      'button': 'Enter Laboratory',
      'footnote': 'Saponification & Salting Out',
    },
    'tabs': {'explore': 'Exploration'},
    'mission_obj': 'Mission Objective',
    'objective':
        'To synthesize soap using castor oil and sodium hydroxide, precipitate it using the salting-out method, and verify its basic nature.',
    'board_desc':
        "Large oil molecules react with strong bases to form soap and glycerol. Let's make some traditional soap and understand the 'salting out' process.",
    'board_btn': 'Start Observation',
    'concept_exp': 'Exploration Steps',
    'exploration': 'Step',
    'action': 'Action',
    'observation': 'Observation',
    'curr_obj': 'Current Task',
    'item_oil': 'Castor Oil',
    'item_naoh': 'NaOH',
    'item_beaker': 'Beaker',
    'item_nacl': 'NaCl Spatula',
    'item_litmus': 'Red Litmus',
    'drag_beaker': 'Drag to Beaker',
    'drag_tripod': 'Drag to Tripod',
    'drag_soap': 'Drag to Solid Soap',
    'btn_stir': 'Stir & Heat',
    'drop_liquids': 'Drop Liquids Here',
    'drop_beaker': 'Drop Beaker Here',
    'drop_nacl': 'Drop NaCl Here',
    'drop_litmus': 'Drop Litmus Here',
    'err_miss': 'Missed! Drop it inside the dashed circle.',
    'reaction': 'Reaction occurring',
    'eq_word': 'Ester + Base (Heat) → Soap + Alcohol',
    'eq_chem': '(Oil) + NaOH → C₁₇H₃₅COONa + Glycerol',
    'btn_continue': 'Continue',
    'data_log': 'Observation Log',
    'btn_clear': 'Clear',
    'th_action': 'Action',
    'th_result': 'Result',
    'no_data': 'No observations yet.',
    'log_mix_act': 'Mixed Oil and NaOH',
    'log_mix_res': 'Formed immiscible layers',
    'log_heat_act': 'Heated and stirred',
    'log_heat_res': 'Saponification occurred (Milky)',
    'log_salt_act': 'Added NaCl',
    'log_salt_res': 'Soap precipitated (Salting Out)',
    'log_litmus_act': 'Litmus test',
    'log_litmus_res': 'Red litmus turned blue (Basic)',
    'msg_oil': 'Castor Oil (Triglycerides) added.',
    'msg_naoh': 'Sodium Hydroxide (Strong Base) added.',
    'msg_layers':
        'Notice the layers. The thick, pale yellow oil is immiscible in the base solution.',
    'msg_beaker':
        'Beaker placed on tripod. Now TAP the Stir & Heat button to initiate saponification.',
    'msg_opaque':
        'The heat speeds up alkaline hydrolysis, breaking ester bonds to form soap and glycerol.',
    'msg_salt':
        'Salting Out: The added NaCl decreases the solubility of soap, causing it to precipitate as solid curds.',
    'msg_blue':
        'Basic Nature Confirmed! Soap turns red litmus blue because it is the salt of a strong base and a weak acid.',
    'lbl_beaker': 'Beaker',
    'lbl_beaker_mix': 'Beaker (Oil + NaOH)',
    'lbl_beaker_soap': 'Beaker (Soap + Glycerol)',
    'lbl_tripod': 'Tripod Stand',
    'lbl_burner': 'Bunsen Burner',
    'tool_labels': 'Show / hide labels',
    'tool_lock': 'Lock / unlock camera',
    'btn_restart': 'Restart Virtual Lab',
    'hud': [
      'DRAG Castor Oil and DROP it onto the beaker, then repeat for NaOH.',
      'DRAG the beaker onto the Tripod Stand, and TAP the Stir & Heat button.',
      'DRAG a spatula of Sodium Chloride (NaCl) and DROP it onto the beaker.',
      'DRAG the Red Litmus Paper onto the solid soap.',
    ],
    'steps': [
      {
        'concept': 'Reactants Preparation',
        'action':
            'DRAG and DROP Castor Oil (Triglyceride) and strong NaOH base.',
        'observation':
            'Forms distinct immiscible layers. The oil, having lower density and being non-polar, floats on the polar base.',
      },
      {
        'concept': 'Saponification Reaction',
        'action': 'DRAG the beaker to the burner, TAP Stir & Heat.',
        'observation':
            'Heat speeds up alkaline hydrolysis. Ester bonds in oil break, forming Sodium salts of fatty acids (Soap) and Glycerol. The mixture turns opaque.',
      },
      {
        'concept': 'Salting Out',
        'action': 'DRAG and DROP the NaCl spatula.',
        'observation':
            'Adding NaCl increases ionic strength, severely decreasing the solubility of the soap molecules. Solid white soap curds precipitate.',
      },
      {
        'concept': 'Verification',
        'action': 'DRAG Red Litmus Paper to soap.',
        'observation':
            'Red litmus turns blue. Soap is alkaline because it is formed from a strong base (NaOH) and a weak fatty acid.',
      },
    ],
    'summary': {
      'title': 'Experiment Complete!',
      'msg':
          'You synthesized soap through saponification, used salting out to separate the solid micelle-forming curds, and chemically proved its alkaline nature!',
    },
  },
  'hi': {
    'headerTitle': 'साबुन का निर्माण',
    'headerSubtitle': 'कक्षा 10: कार्बन और उसके यौगिक',
    'intro': {
      'title': 'साबुन का निर्माण',
      'subtitle': 'कक्षा 10: कार्बन और उसके यौगिक',
      'button': 'प्रयोगशाला में प्रवेश करें',
      'footnote': 'साबुनीकरण और साल्टिंग आउट',
    },
    'tabs': {'explore': 'अन्वेषण'},
    'mission_obj': 'मिशन का उद्देश्य',
    'objective':
        'अरंडी का तेल और सोडियम हाइड्रॉक्साइड का उपयोग करके साबुन का संश्लेषण करना, साल्टिंग-आउट विधि का उपयोग करके इसे अवक्षेपित करना, और इसकी क्षारीय प्रकृति को सत्यापित करना।',
    'board_desc':
        "बड़े तेल के अणु साबुन और ग्लिसरॉल बनाने के लिए प्रबल क्षारों के साथ अभिक्रिया करते हैं। आइए कुछ पारंपरिक साबुन बनाएँ और 'साल्टिंग आउट' प्रक्रिया को समझें।",
    'board_btn': 'अवलोकन शुरू करें',
    'concept_exp': 'अन्वेषण चरण',
    'exploration': 'चरण',
    'action': 'कार्रवाई',
    'observation': 'अवलोकन',
    'curr_obj': 'वर्तमान कार्य',
    'item_oil': 'अरंडी का तेल',
    'item_naoh': 'NaOH',
    'item_beaker': 'बीकर',
    'item_nacl': 'NaCl चम्मच',
    'item_litmus': 'लाल लिटमस',
    'drag_beaker': 'बीकर पर खींचें',
    'drag_tripod': 'ट्राइपॉड पर खींचें',
    'drag_soap': 'ठोस साबुन पर खींचें',
    'btn_stir': 'हिलाएँ और गर्म करें',
    'drop_liquids': 'द्रव यहाँ छोड़ें',
    'drop_beaker': 'बीकर यहाँ छोड़ें',
    'drop_nacl': 'NaCl यहाँ छोड़ें',
    'drop_litmus': 'लिटमस यहाँ छोड़ें',
    'err_miss': 'चूक गए! इसे बिंदीदार घेरे के अंदर छोड़ें।',
    'reaction': 'अभिक्रिया हो रही है',
    'eq_word': 'एस्टर + क्षारक (ऊष्मा) → साबुन + ऐल्कोहॉल',
    'eq_chem': '(तेल) + NaOH → C₁₇H₃₅COONa + ग्लिसरॉल',
    'btn_continue': 'जारी रखें',
    'data_log': 'अवलोकन लॉग',
    'btn_clear': 'साफ़ करें',
    'th_action': 'कार्रवाई',
    'th_result': 'परिणाम',
    'no_data': 'अभी तक कोई अवलोकन नहीं।',
    'log_mix_act': 'तेल और NaOH मिलाया गया',
    'log_mix_res': 'अमिश्रणीय परतें बनीं',
    'log_heat_act': 'गर्म किया गया और हिलाया गया',
    'log_heat_res': 'साबुनीकरण हुआ (दूधिया)',
    'log_salt_act': 'NaCl मिलाया गया',
    'log_salt_res': 'साबुन अवक्षेपित हुआ (साल्टिंग आउट)',
    'log_litmus_act': 'लिटमस परीक्षण',
    'log_litmus_res': 'लाल लिटमस नीला हो गया (क्षारीय)',
    'msg_oil': 'अरंडी का तेल (ट्राइग्लिसराइड्स) डाला गया।',
    'msg_naoh': 'सोडियम हाइड्रॉक्साइड (प्रबल क्षार) डाला गया।',
    'msg_layers':
        'परतों पर ध्यान दें। गाढ़ा पीला तेल क्षार के घोल में अमिश्रणीय है।',
    'msg_beaker':
        "बीकर को ट्राइपॉड पर रखा गया। साबुनीकरण शुरू करने के लिए 'हिलाएँ और गर्म करें' पर टैप करें।",
    'msg_opaque':
        'ऊष्मा क्षारीय जल-अपघटन को तेज़ करती है, जिससे एस्टर बंध टूटकर साबुन और ग्लिसरॉल बनते हैं।',
    'msg_salt':
        'साल्टिंग आउट: NaCl मिलाने से साबुन की घुलनशीलता कम हो जाती है, जिससे यह ठोस अवक्षेप बन जाता है।',
    'msg_blue':
        'क्षारीय प्रकृति की पुष्टि! साबुन लाल लिटमस को नीला कर देता है क्योंकि यह प्रबल क्षार और दुर्बल अम्ल का लवण है।',
    'lbl_beaker': 'बीकर',
    'lbl_beaker_mix': 'बीकर (तेल + NaOH)',
    'lbl_beaker_soap': 'बीकर (साबुन + ग्लिसरॉल)',
    'lbl_tripod': 'ट्राइपॉड स्टैंड',
    'lbl_burner': 'बुन्सेन बर्नर',
    'tool_labels': 'लेबल दिखाएँ / छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक करें',
    'btn_restart': 'वर्चुअल लैब को फिर से शुरू करें',
    'hud': [
      'अरंडी के तेल को खींचकर बीकर पर छोड़ें, फिर NaOH के लिए यही दोहराएँ।',
      "बीकर को खींचकर ट्राइपॉड स्टैंड पर रखें, फिर 'हिलाएँ और गर्म करें' बटन पर टैप करें।",
      'सोडियम क्लोराइड (NaCl) से भरे चम्मच को खींचकर बीकर पर छोड़ें।',
      'लाल लिटमस पेपर को खींचकर ठोस साबुन पर रखें।',
    ],
    'steps': [
      {
        'concept': 'अभिकारक तैयार करना',
        'action':
            'अरंडी का तेल (ट्राइग्लिसराइड) और प्रबल NaOH क्षार को खींचकर बीकर में छोड़ें।',
        'observation':
            'अमिश्रणीय परतें बनती हैं। कम घनत्व वाला और अध्रुवीय तेल ध्रुवीय क्षार पर तैरता है।',
      },
      {
        'concept': 'साबुनीकरण अभिक्रिया',
        'action':
            "बीकर को खींचकर बर्नर पर रखें, फिर 'हिलाएँ और गर्म करें' पर टैप करें।",
        'observation':
            'ऊष्मा क्षारीय जल-अपघटन को तेज़ करती है। एस्टर बंध टूटते हैं, जिससे वसा अम्लों के सोडियम लवण (साबुन) और ग्लिसरॉल बनते हैं। मिश्रण अपारदर्शी हो जाता है।',
      },
      {
        'concept': 'साल्टिंग आउट',
        'action': 'NaCl चम्मच को खींचकर बीकर में छोड़ें।',
        'observation':
            'NaCl मिलाने से आयनिक शक्ति बढ़ती है, जिससे साबुन के अणुओं की घुलनशीलता कम हो जाती है। ठोस सफेद साबुन अवक्षेपित होता है।',
      },
      {
        'concept': 'सत्यापन',
        'action': 'लाल लिटमस पेपर को खींचकर साबुन पर रखें।',
        'observation':
            'लाल लिटमस नीला हो जाता है। साबुन क्षारीय है क्योंकि यह एक प्रबल क्षार (NaOH) और एक दुर्बल वसा अम्ल से बनता है।',
      },
    ],
    'summary': {
      'title': 'प्रयोग पूरा हुआ!',
      'msg':
          'आपने साबुनीकरण के माध्यम से साबुन का संश्लेषण किया, साल्टिंग आउट का उपयोग करके ठोस साबुन को अलग किया, और इसकी क्षारीय प्रकृति को सिद्ध किया!',
    },
  },
});

const _blue = Color(0xFF3B82F6);
const _blueDark = Color(0xFF2563EB);
const _cyan = Color(0xFF22D3EE);
const _yellow = Color(0xFFFACC15);
const _yellowDark = Color(0xFFCA8A04);
const _red = Color(0xFFF87171);

const _oilColor = Color(0xFFFACC15);
const _naohColor = Color(0xFF7DD3FC);
const _soapColor = Color(0xFFF8FAFC);
const _brineColor = Color(0xFFE0F2FE);
const _litmusRed = Color(0xFFFF4444);
const _litmusBlue = Color(0xFF1A33E6);

/// Steps 1-4 are tasks; 0 is the objective board, 5 the finished lab.
const _lastStep = 4;

/// Draggable tool ids (the HTML `startPointerDrag` names).
const _oilTool = 'oil', _naohTool = 'naoh', _beakerTool = 'beaker';
const _naclTool = 'nacl', _litmusTool = 'litmus';

/// Bench and tripod x positions, and the beaker's heights while it is lifted
/// across and once it rests on the wire gauze.
const _benchX = -1.6, _tripodX = 1.6;
const _liftY = 2.3, _onTripodY = 2.07;

/// Liquid levels inside the beaker (beaker-local y): each layer is 0.8 deep.
const _layerBottom = 0.05, _layerDepth = 0.8, _soapTop = 1.65;

/// Height the litmus strip's lower end rests at, on top of the soap curds.
const _litmusRestY = 1.8;

/// 3D label keys and positions. The beaker's label follows the beaker and
/// its contents; the tripod and burner labels sit beside them (the HTML
/// tripod label ended up inside the beaker once it was placed).
const _labelKeys = ['lbl_beaker', 'lbl_tripod', 'lbl_burner'];
const _labelPos = [
  (_benchX, 2.85, 0.0),
  (_tripodX + 1.55, 1.3, 0.6),
  (_tripodX, 0.35, 0.85),
];

double _mix(double a, double b, double t) => a + (b - a) * t;

/// Progress 0..1 of a phase that starts at [start] and lasts [length].
double _phase(double t, double start, double length) =>
    ((t - start) / length).clamp(0.0, 1.0);

class Cl10SCh04A5ManufacturingSoapPage extends StatefulWidget {
  const Cl10SCh04A5ManufacturingSoapPage({super.key});

  @override
  State<Cl10SCh04A5ManufacturingSoapPage> createState() => _SoapState();
}

class _SoapState extends State<Cl10SCh04A5ManufacturingSoapPage> {
  final _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E293B), Color(0xFF020617)],
  );
  final _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 4, 10))
    ..minDistance = 3
    ..maxDistance = 15
    ..maxPolarAngle = math.pi / 2 + 0.1;
  final _viewCtrl = _rt_Scene3DController();
  final _shell = _rt_ShellController();

  /// Ticks every frame so the drop circle can follow its object on screen.
  final _frameTick = ValueNotifier<int>(0);

  late final _rt_Node3D _beaker, _tripod, _curds, _rod, _litmus;
  late final _rt_Mesh3D _naohLayer, _oilLayer, _soap, _stream;
  late final _rt_Mesh3D _flameCore, _flameOuter;
  late final _rt_Material3D _naohMat, _oilMat, _soapMat, _streamMat;
  late final _rt_Material3D _litmusMat, _flameCoreMat, _flameOuterMat;
  late final _rt_Points3D _grains;
  late final List<double> _grainDelay;
  final List<_rt_Sphere3D> _curdList = [];
  final List<double> _curdY = [];
  final List<_rt_Label3D> _labels = [];

  int _step = 0;
  bool _boardVisible = false;
  bool _camLocked = true;
  bool _labelsVisible = true;
  double? _oilT, _naohT; // pour progress 0..1; null until dropped (step 1)
  bool _beakerDropped = false; // beaker accepted on the tripod (step 2)
  double? _moveT; // beaker move progress; null when idle
  bool _beakerPlaced = false;
  bool _heating = false; // Stir & Heat pressed
  double? _heatT; // stir & heat timeline in seconds; null when idle
  bool _heated = false; // saponification finished
  bool _eqVisible = false, _eqDone = false; // reaction card
  bool _saltAdded = false;
  double? _saltT; // salting-out timeline in seconds; null when idle
  bool _litmusAdded = false;
  double? _litmusT; // litmus timeline in seconds; null when idle
  double? _camT; // camera move progress; null when idle
  final _camFromPos = _rt_V3(), _camFromTarget = _rt_V3();
  final _camToPos = _rt_V3(), _camToTarget = _rt_V3();
  double _time = 0;
  bool _compactView = false; // short phone; refreshed by every build
  bool _logShown = false;
  bool? _logOpen; // null: full on large screens, latest row on phones
  final List<(String, String)> _log = [];
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
    _frameBench();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _viewCtrl.dispose();
    _frameTick.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------------------------------------------------------- scene

  void _initScene() {
    _scene.setLights([
      _rt_Light3D.hemisphere(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(5, 10, 5), intensity: 1.2),
      _rt_Light3D.directional(
        _rt_V3(-5, 3, -5),
        color: const Color(0xFF90B0D0),
        intensity: 0.4,
      ),
    ]);
    _scene.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(8, 8, 0.5, segments: 64),
          _rt_Material3D(color: const Color(0xFF1E293B), metalness: 0.1),
        )
        ..position.y = -0.25
        ..pickable = false
        // The bench is always drawn first, so it never paints over the
        // tripod's back leg or the beaker's back wall standing on it.
        ..depthBias = 100,
    );

    final rng = math.Random(4);
    _rt_Mesh3D mesh(
      _rt_Geometry3D g,
      _rt_Material3D m, [
      double x = 0,
      double y = 0,
      double z = 0,
    ]) => _rt_Mesh3D(g, m)
      ..position.set(x, y, z)
      ..pickable = false;

    // Steps 1-4: a beaker of castor oil over sodium hydroxide solution. Each
    // layer is a unit cylinder stretched to its depth, so the oil always
    // floats on the base whichever is poured first (in the HTML the oil hung
    // in mid-beaker when it was added first).
    final glass = _rt_Material3D(
      color: const Color(0xFFCCFBF1),
      opacity: 0.3,
      doubleSided: true,
      shininess: 0.9,
    );
    final layerGeo = _rt_Geometry3D.cylinder(0.97, 0.97, 1, segments: 32);
    _naohMat = _rt_Material3D(color: _naohColor, opacity: 0.45, shininess: 0.5);
    _oilMat = _rt_Material3D(color: _oilColor, opacity: 0.85, shininess: 0.5);
    _soapMat = _rt_Material3D(color: _soapColor, opacity: 0.95, shininess: 0.1);
    _naohLayer = mesh(layerGeo, _naohMat);
    _oilLayer = mesh(layerGeo, _oilMat);
    _soap = mesh(
      _rt_Geometry3D.cylinder(
        0.97,
        0.97,
        _soapTop - _layerBottom,
        segments: 32,
      ),
      _soapMat,
      0,
      (_soapTop + _layerBottom) / 2,
    );
    // The liquid runs in as a stream while a layer fills.
    _streamMat = _rt_Material3D(color: _oilColor, opacity: 0.9);
    _stream = mesh(
      _rt_Geometry3D.cylinder(0.05, 0.05, 1, segments: 10),
      _streamMat,
    );

    // Step 2: a glass rod stirs while the burner heats. Its upper half is
    // drawn in front of the liquid surface it rises out of.
    final rodMat = _rt_Material3D(
      color: const Color(0xFFE0F2FE),
      opacity: 0.75,
      shininess: 0.9,
    );
    _rod = _rt_Node3D()
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(0.035, 0.035, 1.4, segments: 8),
          rodMat,
          0,
          0.9,
        ),
      )
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(0.035, 0.035, 1.5, segments: 8),
          rodMat,
          0,
          2.35,
        )..depthBias = -0.8,
      );

    // Step 3: salt grains fall in and soap curds float up on the surface.
    // The curds draw above the liquid surface (in the HTML half of them were
    // hidden under it).
    _grainDelay = [for (var i = 0; i < 40; i++) rng.nextDouble() * 0.35];
    _grains =
        _rt_Points3D([
            for (var i = 0; i < 40; i++)
              _rt_V3(
                (rng.nextDouble() - 0.5) * 0.5,
                3.4,
                (rng.nextDouble() - 0.5) * 0.5,
              ),
          ])
          ..color = Colors.white
          ..size = 0.5
          ..pickable = false;
    final curdMat = _rt_Material3D(color: Colors.white, shininess: 0.1);
    _curds = _rt_Node3D();
    for (var i = 0; i < 25; i++) {
      final r = math.sqrt(rng.nextDouble()) * 0.72;
      final a = rng.nextDouble() * math.pi * 2;
      final y = _soapTop + 0.03 + rng.nextDouble() * 0.06;
      _curdY.add(y);
      _curdList.add(
        _curds.add(
          _rt_Sphere3D(0.12, curdMat)
            ..position.set(math.cos(a) * r, y, math.sin(a) * r)
            ..pickable = false
            ..depthBias = -1,
        ),
      );
    }

    // Step 4: a red litmus strip, pivoted at its lower end, that comes down
    // to rest on the curds (the HTML strip sank into the liquid).
    _litmusMat = _rt_Material3D(color: _litmusRed)..unlit = true;
    _litmus = _rt_Node3D()
      ..rotation.x = -0.5
      ..add(
        mesh(_rt_Geometry3D.box(0.3, 1.2, 0.012), _litmusMat, 0, 0.6)
          ..depthBias = -1,
      );

    _beaker = _scene.add(_rt_Node3D(name: 'Beaker')..visible = false)
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(1, 1, 2.5, segments: 32, openEnded: true),
          glass,
          0,
          1.25,
        ),
      )
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(1, 1, 0.05, segments: 32),
          glass,
          0,
          0.025,
        ),
      )
      // Thicker rim so the mouth of the beaker reads clearly.
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(
            1.02,
            1.02,
            0.06,
            segments: 32,
            openEnded: true,
          ),
          _rt_Material3D(
            color: const Color(0xFFCCFBF1),
            opacity: 0.55,
            doubleSided: true,
            shininess: 0.9,
          ),
          0,
          2.47,
        ),
      )
      ..add(_naohLayer)
      ..add(_oilLayer)
      ..add(_soap)
      ..add(_stream)
      ..add(_rod)
      ..add(_curds)
      ..add(_grains)
      ..add(_litmus);

    // Step 2: tripod stand with wire gauze over a Bunsen burner. It stands
    // beside the beaker from the start of step 2, so there is something to
    // drag the beaker onto (the HTML showed it only after the drop, right
    // where the beaker already stood).
    final iron = _rt_Material3D(
      color: const Color(0xFF3F3F46),
      metalness: 0.5,
      shininess: 0.3,
    );
    _tripod = _scene.add(
      _rt_Node3D(name: 'Tripod')
        ..position.x = _tripodX
        ..visible = false,
    );
    // Legs splay outwards (the HTML tilted them sideways). Two legs stand in
    // front, so the flame shows between them; they draw under the gauze.
    for (final deg in const [30.0, 150.0, 270.0]) {
      final a = _rt_degToRad(deg);
      final top = _rt_V3(math.cos(a) * 1.2, 2.0, math.sin(a) * 1.2);
      final foot = _rt_V3(math.cos(a) * 1.45, 0, math.sin(a) * 1.45);
      final dir = top - foot;
      _tripod.add(
        mesh(_rt_Geometry3D.cylinder(0.04, 0.04, dir.length, segments: 8), iron)
          ..position.copy(foot.lerp(top, 0.5))
          ..rotationMatrix = _rt_M3.fromUnitVectors(_rt_V3(0, 1, 0), dir)
          ..depthBias = 1.0,
      );
    }
    _flameCoreMat = _rt_Material3D(color: const Color(0xFF00FFFF))
      ..unlit = true;
    _flameOuterMat = _rt_Material3D(color: const Color(0xFF0055FF))
      ..unlit = true;
    _flameOuter = mesh(
      _rt_Geometry3D.cylinder(0, 0.3, 0.8, segments: 16),
      _flameOuterMat,
      0,
      1.5,
    );
    _flameCore = mesh(
      _rt_Geometry3D.cylinder(0, 0.2, 0.6, segments: 16),
      _flameCoreMat,
      0,
      1.4,
    );
    _tripod
      // The ring sits under the gauze, so it is drawn before it.
      ..add(
        mesh(
            _rt_Geometry3D.torus(
              1.2,
              0.04,
              radialSegments: 6,
              tubularSegments: 32,
            ),
            iron,
            0,
            2.0,
          )
          ..rotation.x = math.pi / 2
          ..depthBias = 1.6,
      )
      // Square wire gauze with its ceramic centre, resting on the ring.
      ..add(
        mesh(
          _rt_Geometry3D.box(2.5, 0.02, 2.5),
          _rt_Material3D(
            color: const Color(0xFF71717A),
            metalness: 0.4,
            shininess: 0.3,
          ),
          0,
          2.05,
        ),
      )
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(0.65, 0.65, 0.022, segments: 24),
          _rt_Material3D(color: const Color(0xFFE7E5E4)),
          0,
          2.05,
        ),
      )
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(0.5, 0.5, 0.2, segments: 24),
          _rt_Material3D(
            color: const Color(0xFF444455),
            metalness: 0.8,
            shininess: 0.6,
          ),
          0,
          0.1,
        ),
      )
      ..add(
        mesh(
          _rt_Geometry3D.cylinder(0.15, 0.15, 1, segments: 16),
          _rt_Material3D(
            color: const Color(0xFFAAAAAA),
            metalness: 0.9,
            shininess: 0.6,
          ),
          0,
          0.6,
        ),
      )
      ..add(_flameOuter)
      ..add(_flameCore);

    for (var i = 0; i < _labelKeys.length; i++) {
      final (x, y, z) = _labelPos[i];
      _labels.add(
        _scene.add(
          _rt_Label3D(
              _tx.s(_labelKeys[i]),
              position: _rt_V3(x, y, z),
              worldHeight: 0.28,
              background: const Color(0xD90F172A),
            )
            ..visible = false
            ..pickable = false,
        ),
      );
    }
    _resetApparatus();
  }

  /// Puts every animated object back where the lab starts.
  void _resetApparatus() {
    _beaker.position.set(_benchX, 0, 0);
    _naohMat
      ..color = _naohColor
      ..opacity = 0.45;
    _oilMat
      ..color = _oilColor
      ..opacity = 0.85;
    _soapMat
      ..color = _soapColor
      ..opacity = 0.95;
    _setLayers();
    _soap.visible = false;
    _stream.visible = false;
    _rod.visible = false;
    _grains.visible = false;
    _curds.visible = false;
    _litmus.visible = false;
    _litmusMat.color = _litmusRed;
    _setFlame(0);
    _moveBeakerLabel();
  }

  /// Fills the NaOH layer and the oil floating on it from the pour progress.
  void _setLayers() {
    final naoh = Curves.easeOut.transform(_naohT ?? 0) * _layerDepth;
    final oil = Curves.easeOut.transform(_oilT ?? 0) * _layerDepth;
    _setColumn(_naohLayer, _layerBottom, naoh);
    _setColumn(_oilLayer, _layerBottom + naoh, oil);
  }

  /// Stretches a unit-height cylinder from [bottom] up by [height].
  void _setColumn(_rt_Mesh3D m, double bottom, double height) {
    m
      ..visible = height > 0.005
      ..position.y = bottom + height / 2
      ..scale.y = math.max(height, 0.005);
  }

  void _setFlame(double strength) {
    _flameCore.visible = strength > 0.01;
    _flameOuter.visible = strength > 0.01;
    _flameCoreMat.opacity = 0.85 * strength;
    _flameOuterMat.opacity = 0.55 * strength;
  }

  void _moveBeakerLabel() =>
      _labels[0].position.set(_beaker.position.x, _beaker.position.y + 2.85, 0);

  String get _beakerLabelKey => _heated
      ? 'lbl_beaker_soap'
      : (_oilT != null && _naohT != null ? 'lbl_beaker_mix' : 'lbl_beaker');

  void _frame(_rt_V3 pos, _rt_V3 target) {
    _camT = null;
    _camera.position.copy(pos);
    _camera.target.copy(target);
    _camera.zoom = 1;
    _camera.saveHome();
  }

  /// Glides the camera to a new view over a second (the HTML camera stayed
  /// put while the beaker moved half off-screen onto the tripod).
  void _glide(_rt_V3 pos, _rt_V3 target) {
    _camFromPos.copy(_camera.position);
    _camFromTarget.copy(_camera.target);
    _camToPos.copy(pos);
    _camToTarget.copy(target);
    _camera.zoom = 1;
    _camT = 0;
  }

  void _view(_rt_V3 pos, _rt_V3 target, bool animate) =>
      animate ? _glide(pos, target) : _frame(pos, target);

  /// Camera views: the beaker on the bench (step 1), bench and tripod side by
  /// side (step 2), and the beaker on the tripod (steps 2-4). Short phones
  /// look from further back so the HUD and the tool bar do not hide them.
  /// The tripod view leaves room on the right for the observation log; on
  /// short phones the log sits at the left, so both later views keep the
  /// beaker right of it.
  void _frameBench({bool animate = false}) => _view(
    _compactView ? _rt_V3(_benchX, 3.9, 8.0) : _rt_V3(_benchX, 3.6, 7.2),
    _rt_V3(_benchX, _compactView ? 1.2 : 1.25, 0),
    animate,
  );

  void _frameBoth({bool animate = false}) => _view(
    _compactView ? _rt_V3(_benchX, 5.3, 11.6) : _rt_V3(0, 4.4, 9.0),
    _rt_V3(_compactView ? _benchX : 0, _compactView ? 1.6 : 1.5, 0),
    animate,
  );

  void _frameTripod({bool animate = false}) => _view(
    _compactView
        ? _rt_V3(_tripodX - 0.4, 7.0, 9.4)
        : _rt_V3(_tripodX + 0.7, 6.0, 8.4),
    _rt_V3(
      _compactView ? _tripodX - 0.4 : _tripodX + 0.7,
      _compactView ? 3.4 : 2.8,
      0,
    ),
    animate,
  );

  void _syncScene() {
    _beaker.visible = _step >= 1;
    _tripod.visible = _step >= 2;
    for (var i = 0; i < _labels.length; i++) {
      _labels[i].visible = _labelsVisible && _step >= (i == 0 ? 1 : 2);
    }
  }

  // ---------------------------------------------------------------- flow

  void _begin() {
    _boardVisible = false;
    _advance();
  }

  void _advance() {
    _advanceTimer?.cancel();
    if (_step >= _lastStep) {
      _conclude();
      return;
    }
    setState(() {
      _step++;
      _openSteps.clear();
    });
    _syncScene();
    switch (_step) {
      case 1:
        _frameBench();
      case 2:
        _frameBoth(animate: true);
    }
  }

  void _advanceAfter(Duration delay) {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(delay, () {
      if (mounted) _advance();
    });
  }

  /// Marks every step done and opens the summary (the HTML
  /// `triggerConclusionState`).
  void _conclude() {
    setState(() {
      _step = _lastStep + 1;
      _openSteps.clear();
    });
    _syncScene();
    _advanceTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      _shell.showSuccess(
        title: _tx.s('summary.title'),
        message: _tx.s('summary.msg'),
        icon: Icons.check_circle,
        color: _blueDark,
        sound: _rt_Sfx.curtain,
        buttonLabel: _tx.s('btn_restart'),
        onConfirm: _restart,
      );
    });
  }

  void _logRow(String action, String result) {
    setState(() {
      _logShown = true;
      _log.add((action, result));
    });
  }

  /// Toasts leave early on short phones, where they cover the beaker.
  void _toast(String key, IconData icon, {int ms = 3000}) => _shell.showToast(
    _tx.s(key),
    color: _blue,
    icon: icon,
    ms: _compactView ? math.min(ms, 2500) : ms,
  );

  void _restart() {
    _advanceTimer?.cancel();
    setState(() {
      _step = 0;
      _boardVisible = true;
      _oilT = _naohT = null;
      _beakerDropped = false;
      _moveT = null;
      _beakerPlaced = false;
      _heating = false;
      _heatT = null;
      _heated = false;
      _eqVisible = false;
      _eqDone = false;
      _saltAdded = false;
      _saltT = null;
      _litmusAdded = false;
      _litmusT = null;
      _logShown = false;
      _logOpen = null;
      _log.clear();
      _openSteps.clear();
    });
    _resetApparatus();
    _syncScene();
    _frameBench();
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _rt_playSfx(_rt_Sfx.scenario);
  }

  void _onFrame(double dt) {
    _time += dt;
    _frameTick.value++;
    _tickCamera(dt);
    _tickPour(dt);
    _tickMove(dt);
    _tickHeat(dt);
    _tickSalt(dt);
    _tickLitmus(dt);
    if (_flameCore.visible) {
      // Flickering flame standing on the burner tube (top at y = 1.1).
      final core = 1 + 0.1 * math.sin(_time * 15);
      final outer = 1 + 0.1 * math.cos(_time * 12);
      _flameCore
        ..scale.y = core
        ..position.y = 1.1 + 0.3 * core;
      _flameOuter
        ..scale.y = outer
        ..position.y = 1.1 + 0.4 * outer;
    }
    if (_curds.visible) {
      for (var i = 0; i < _curdList.length; i++) {
        _curdList[i].position.y = _curdY[i] + 0.02 * math.sin(_time * 3 + i);
      }
    }
  }

  void _tickCamera(double dt) {
    final c = _camT;
    if (c == null) return;
    final p = math.min(1.0, c + dt / 1.2);
    final e = Curves.easeInOut.transform(p);
    _camera.position.copy(_camFromPos.lerp(_camToPos, e));
    _camera.target.copy(_camFromTarget.lerp(_camToTarget, e));
    _camT = p;
    if (p >= 1) {
      _camT = null;
      _camera.saveHome();
    }
  }

  // ------------------------------------------------- drops (steps 1, 3, 4)

  void _onDrop(String tool) {
    switch ((_step, tool)) {
      case (1, _oilTool) when _oilT == null:
        _rt_playSfx(_rt_Sfx.correct);
        _toast('msg_oil', Icons.water_drop);
        setState(() => _oilT = 0);
        _checkReactants();
      case (1, _naohTool) when _naohT == null:
        _rt_playSfx(_rt_Sfx.correct);
        _toast('msg_naoh', Icons.science);
        setState(() => _naohT = 0);
        _checkReactants();
      case (2, _beakerTool) when !_beakerDropped:
        _rt_playSfx(_rt_Sfx.correct);
        setState(() {
          _beakerDropped = true;
          _moveT = 0;
        });
        _frameTripod(animate: true);
      case (3, _naclTool) when !_saltAdded:
        _rt_playSfx(_rt_Sfx.magic);
        setState(() {
          _saltAdded = true;
          _saltT = 0;
        });
        _grains.visible = true;
        _logRow('log_salt_act', 'log_salt_res');
        _toast('msg_salt', Icons.grain, ms: 5000);
        _advanceAfter(const Duration(seconds: 4));
      case (4, _litmusTool) when !_litmusAdded:
        _rt_playSfx(_rt_Sfx.correct);
        _litmus
          ..visible = true
          ..position.set(0.1, 4.2, 0.3);
        setState(() {
          _litmusAdded = true;
          _litmusT = 0;
        });
        _logRow('log_litmus_act', 'log_litmus_res');
        _toast('msg_blue', Icons.check_circle, ms: 5000);
        _advanceAfter(const Duration(seconds: 4));
    }
  }

  /// A tool released away from its drop circle.
  void _missed() {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(
      _tx.s('err_miss'),
      color: _rt_Tw.red500,
      icon: Icons.error_outline,
    );
  }

  // ----------------------------------------------- step 1: the reactants

  void _checkReactants() {
    if (_oilT == null || _naohT == null) return;
    _logRow('log_mix_act', 'log_mix_res');
    _toast('msg_layers', Icons.layers, ms: 5000);
    _advanceAfter(const Duration(seconds: 4));
  }

  void _tickPour(double dt) {
    final o = _oilT, n = _naohT;
    final oil = o != null && o < 1, naoh = n != null && n < 1;
    if (!oil && !naoh) return;
    if (oil) _oilT = math.min(1.0, o + dt);
    if (naoh) _naohT = math.min(1.0, n + dt);
    _setLayers();
    final surface =
        _layerBottom +
        (Curves.easeOut.transform(_naohT ?? 0) +
                Curves.easeOut.transform(_oilT ?? 0)) *
            _layerDepth;
    final pouring = (_oilT ?? 1) < 1 || (_naohT ?? 1) < 1;
    _streamMat.color = (_oilT ?? 1) < 1 ? _oilColor : _naohColor;
    _stream
      ..visible = pouring
      ..position.set(0.3, (3.1 + surface) / 2, 0.2)
      ..scale.y = 3.1 - surface;
  }

  // --------------------------------------- step 2: tripod and saponification

  /// Lifts the beaker, carries it across and lowers it onto the gauze.
  void _tickMove(double dt) {
    final m = _moveT;
    if (m == null) return;
    final p = math.min(1.0, m + dt / 1.6);
    _moveT = p;
    final lift = Curves.easeInOut.transform(_phase(p, 0, 0.3));
    final slide = Curves.easeInOut.transform(_phase(p, 0.3, 0.4));
    final lower = Curves.easeInOut.transform(_phase(p, 0.7, 0.3));
    _beaker.position
      ..x = _mix(_benchX, _tripodX, slide)
      ..y = _liftY * lift - (_liftY - _onTripodY) * lower;
    _moveBeakerLabel();
    if (p >= 1) {
      _moveT = null;
      setState(() => _beakerPlaced = true);
      _toast('msg_beaker', Icons.local_fire_department, ms: 4000);
    }
  }

  void _stirAndHeat() {
    if (_step != 2 || !_beakerPlaced || _heating) return;
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _heating = true;
      _heatT = 0;
    });
  }

  /// The flame comes up, the rod stirs and both layers turn into milky soap,
  /// then the flame dies down and the reaction card opens.
  void _tickHeat(double dt) {
    final h = _heatT;
    if (h == null) return;
    final t = h + dt;
    _heatT = t;
    _setFlame(t < 4 ? math.min(1.0, t) : math.max(0.0, 5 - t));
    final mix = Curves.easeInOut.transform(_phase(t, 1, 3));
    _naohMat
      ..color = Color.lerp(_naohColor, _soapColor, mix)!
      ..opacity = _mix(0.45, 0.95, mix);
    _oilMat
      ..color = Color.lerp(_oilColor, _soapColor, mix)!
      ..opacity = _mix(0.85, 0.95, mix);
    final stirring = t > 0.3 && t < 4.3;
    _rod.visible = stirring;
    if (stirring) {
      final a = t * 4;
      _rod
        ..position.set(math.cos(a) * 0.4, 0, math.sin(a) * 0.4)
        // Leans out towards the rim it is circling.
        ..rotationMatrix = _rt_M3.axisAngle(
          _rt_V3(math.sin(a), 0, -math.cos(a)),
          0.15,
        );
    }
    if (t >= 4 && !_heated) {
      _naohLayer.visible = false;
      _oilLayer.visible = false;
      _soap.visible = true;
      setState(() => _heated = true);
      _logRow('log_heat_act', 'log_heat_res');
      _toast('msg_opaque', Icons.science);
    }
    if (t >= 5) {
      _heatT = null;
      _setFlame(0);
      setState(() => _eqVisible = true);
    }
  }

  void _finishStep2() {
    // A second tap on Continue skipped step 3 in the HTML.
    if (_eqDone) return;
    setState(() {
      _eqDone = true;
      _eqVisible = false;
    });
    _advance();
  }

  // --------------------------------------------------- step 3: salting out

  void _tickSalt(double dt) {
    final s = _saltT;
    if (s == null) return;
    final t = s + dt;
    _saltT = t;
    _grains.visible = t < 1;
    for (var i = 0; i < _grains.points.length; i++) {
      final f = Curves.easeIn.transform(_phase(t, _grainDelay[i], 0.55));
      _grains.points[i].y = _mix(3.4, _soapTop + 0.02, f);
    }
    if (t >= 0.5) {
      _curds.visible = true;
      final g = 0.1 + 0.9 * Curves.easeOutBack.transform(_phase(t, 0.5, 1.5));
      for (final c in _curdList) {
        c.scale.set(g, g, g);
      }
    }
    // The soap leaves the solution, so the liquid below clears.
    final clear = _phase(t, 0.6, 1.4);
    _soapMat
      ..color = Color.lerp(_soapColor, _brineColor, clear)!
      ..opacity = _mix(0.95, 0.6, clear);
    if (t >= 2.1) _saltT = null;
  }

  // ------------------------------------------------- step 4: litmus test

  void _tickLitmus(double dt) {
    final l = _litmusT;
    if (l == null) return;
    final t = l + dt;
    _litmusT = t;
    _litmus.position.y = _mix(
      4.2,
      _litmusRestY,
      Curves.bounceOut.transform(_phase(t, 0, 1)),
    );
    _litmusMat.color = Color.lerp(
      _litmusRed,
      _litmusBlue,
      _phase(t, 0.8, 1.5),
    )!;
    if (t >= 2.3) _litmusT = null;
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
          _labels[0].text = _tx.s(_beakerLabelKey);
          for (var i = 1; i < _labels.length; i++) {
            _labels[i].text = _tx.s(_labelKeys[i]);
          }
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _blueDark,
              headerGradient: [_rt_Tw.slate900, Color(0xFF1E3A8A)],
              headerSubtitleColor: Color(0xFF93C5FD),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.science,
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
              _rt_RotatePanToggle(controller: _viewCtrl, accent: _blueDark),
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
              cameraControls: !_camLocked,
            ),
            canvasOverlays: [
              if (_step >= 1 && _step <= _lastStep) _hudOverlay(),
              if (_logShown) _logOverlay(),
              if (_drop != null) _dropTargetOverlay(),
              if (_hasTask) _taskOverlay(),
              if (_eqVisible) _reactionOverlay(),
              if (_step == 0 && _boardVisible) _boardOverlay(),
            ],
          );
        },
      ),
    );
  }

  /// The active drop circle: its label key, the 3D point it sits over and
  /// the tools it accepts; null while no drop is expected.
  (String, _rt_V3, Set<String>)? get _drop => switch (_step) {
    1 when _oilT == null || _naohT == null => (
      'drop_liquids',
      _rt_V3(_benchX, 1.1, 0),
      const {_oilTool, _naohTool},
    ),
    2 when !_beakerDropped => (
      'drop_beaker',
      _rt_V3(_tripodX, 1.7, 0),
      const {_beakerTool},
    ),
    3 when !_saltAdded => (
      'drop_nacl',
      _rt_V3(_tripodX, _onTripodY + 1.3, 0),
      const {_naclTool},
    ),
    4 when !_litmusAdded => (
      'drop_litmus',
      _rt_V3(_tripodX, _onTripodY + 1.5, 0),
      const {_litmusTool},
    ),
    _ => null,
  };

  bool get _hasTask => switch (_step) {
    1 => _oilT == null || _naohT == null,
    2 => !_beakerDropped || (_beakerPlaced && !_heating),
    3 => !_saltAdded,
    4 => !_litmusAdded,
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
            color: on ? _blueDark : _rt_Lab.surface,
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
    return Positioned(
      key: const ValueKey('hud'),
      top: 14,
      left: 70,
      right: 70,
      child: IgnorePointer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: _cardDecoration(_blue),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 15, color: _blue),
                    const SizedBox(width: 6),
                    Text(
                      _tx.s('curr_obj').toUpperCase(),
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _tx.s('hud.${_step - 1}'),
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
    // Short phones: a slimmer log at the top-left that shows only the latest
    // row until expanded, so it covers little of the apparatus.
    final compact = _compact;
    final open = _logOpen ?? !compact;
    final rows = open || _log.isEmpty ? _log : [_log.last];
    final head = TextStyle(
      color: _rt_Lab.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w900,
    );
    final cell = TextStyle(color: _rt_Lab.text, fontSize: compact ? 10 : 11);
    return Positioned(
      key: const ValueKey('log'),
      top: compact ? 100 : 110,
      left: compact ? 8 : null,
      right: compact ? null : 66,
      child: Container(
        width: compact ? 200 : 260,
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: _cardDecoration(_blue),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.table_chart_outlined, size: 16, color: _blue),
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
                    setState(() => _logOpen = !open);
                  },
                  child: Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _rt_playSfx(_rt_Sfx.click);
                    setState(_log.clear);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _rt_Tw.red500,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
                    minimumSize: Size(compact ? 40 : 64, 32),
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
                      if (open)
                        TableRow(
                          children: [
                            Text(_tx.s('th_action').toUpperCase(), style: head),
                            Text(_tx.s('th_result').toUpperCase(), style: head),
                          ],
                        ),
                      for (final (action, result) in rows)
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
    // A full-canvas layer stays fixed in the shell, so the tool bar cannot
    // be dragged away: a slightly wobbly finger press on a phone used to move
    // the bar instead of pressing its button. Empty space still reaches the
    // 3D view underneath.
    return Positioned.fill(
      key: const ValueKey('task'),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(_compact ? 10 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: switch (_step) {
              // One row that shrinks its cards: wrapped onto two rows, the
              // upper card floated over the scene on short phones.
              1 => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_oilT == null)
                    Flexible(
                      child: _toolCard(
                        _oilTool,
                        Icons.water_drop,
                        _yellow,
                        'item_oil',
                        'drag_beaker',
                      ),
                    ),
                  if (_oilT == null && _naohT == null)
                    const SizedBox(width: 12),
                  if (_naohT == null)
                    Flexible(
                      child: _toolCard(
                        _naohTool,
                        Icons.science,
                        _cyan,
                        'item_naoh',
                        'drag_beaker',
                      ),
                    ),
                ],
              ),
              2 when !_beakerDropped => _toolCard(
                _beakerTool,
                Icons.science_outlined,
                _blue,
                'item_beaker',
                'drag_tripod',
              ),
              2 => _pillButton(
                Icons.auto_fix_high,
                _tx.s('btn_stir'),
                _yellowDark,
                _stirAndHeat,
              ),
              3 => _toolCard(
                _naclTool,
                Icons.grain,
                _rt_Tw.slate400,
                'item_nacl',
                'drag_beaker',
              ),
              _ => _toolCard(
                _litmusTool,
                Icons.receipt_long,
                _red,
                'item_litmus',
                'drag_soap',
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
    // heightFactor keeps a lone pill at the bottom of the action bar instead
    // of centring it over the 3D scene.
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

  Widget _toolChip(IconData icon, Color color, {bool dragging = false}) {
    final s = _compact ? 50.0 : 64.0;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dragging ? 0.9 : 0.15),
        borderRadius: BorderRadius.circular(s / 4),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: s / 2, color: dragging ? Colors.white : color),
    );
  }

  /// Draggable tool card (the HTML `startPointerDrag` tiles).
  Widget _toolCard(
    String tool,
    IconData icon,
    Color color,
    String titleKey,
    String instKey,
  ) {
    return Container(
      key: ValueKey('tool_$tool'),
      padding: EdgeInsets.all(_compact ? 8 : 12),
      decoration: _cardDecoration(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Draggable<String>(
            data: tool,
            onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
            // Released away from the drop circle.
            onDraggableCanceled: (_, _) => _missed(),
            feedback: Material(
              color: Colors.transparent,
              child: _toolChip(icon, color, dragging: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _toolChip(icon, color),
            ),
            child: _toolChip(icon, color),
          ),
          SizedBox(width: _compact ? 8 : 12),
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

  Widget _dropTargetOverlay() {
    final (textKey, world, accepts) = _drop!;
    final d = _compact ? 140.0 : 190.0;
    return Positioned.fill(
      key: const ValueKey('drop'),
      child: LayoutBuilder(
        builder: (context, box) => ValueListenableBuilder<int>(
          valueListenable: _frameTick,
          builder: (context, _, target) {
            // The circle follows its object on screen (the HTML ring sat
            // mid-canvas wherever the beaker or tripod was), kept clear of
            // the canvas edges.
            final size = box.biggest;
            final p =
                _camera.frame(size).project(world) ?? size.center(Offset.zero);
            final half = d / 2 + 6;
            final x = p.dx.clamp(half, math.max(half, size.width - half));
            final y = p.dy.clamp(half, math.max(half, size.height - half));
            return Stack(
              children: [
                Positioned(
                  left: x - half,
                  top: y - half,
                  width: half * 2,
                  height: half * 2,
                  child: target!,
                ),
              ],
            );
          },
          child: Center(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (det) => accepts.contains(det.data),
              onAcceptWithDetails: (det) => _onDrop(det.data),
              builder: (context, candidates, _) {
                final hot = candidates.isNotEmpty;
                return AnimatedContainer(
                  key: const ValueKey('dropCircle'),
                  duration: const Duration(milliseconds: 150),
                  width: hot ? d + 10 : d,
                  height: hot ? d + 10 : d,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blue.withValues(alpha: hot ? 0.3 : 0.1),
                    border: Border.all(
                      color: hot ? _blue : Colors.white,
                      width: 3,
                    ),
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
                      shadows: [Shadow(blurRadius: 4)],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The HTML "Reaction occurring" card shown after saponification.
  Widget _reactionOverlay() {
    final compact = _compact;
    return Positioned.fill(
      key: const ValueKey('reaction'),
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: EdgeInsets.all(compact ? 16 : 24),
              decoration: _cardDecoration(_blue),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tx.s('reaction').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _blue,
                      fontSize: compact ? 16 : 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 18),
                  Text(
                    _tx.s('eq_word'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.text,
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tx.s('eq_chem'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rt_Lab.onTinted(_blue, _blueDark),
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 22),
                  _pillButton(
                    Icons.arrow_forward,
                    _tx.s('btn_continue'),
                    _blueDark,
                    _finishStep2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _boardOverlay() {
    // Compact variant so the start button fits on short landscape phones.
    final compact = _compact;
    return Positioned.fill(
      key: const ValueKey('board'),
      child: Container(
        color: _rt_Lab.base.withValues(alpha: 0.9),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 8 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: EdgeInsets.all(compact ? 14 : 24),
              decoration: _cardDecoration(_blue),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.science, size: compact ? 36 : 56, color: _blue),
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
                    color: _blueDark,
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
          accent: _blueDark,
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
    Widget detail(String label, Object? text) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: _blueDark,
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
            ? _rt_Lab.tinted(const Color(0xFFEFF6FF), _blue)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? _blue
              : (done ? _blue.withValues(alpha: 0.5) : _rt_Lab.border),
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
                      color: current || done ? _blue : _rt_Lab.overlay,
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
