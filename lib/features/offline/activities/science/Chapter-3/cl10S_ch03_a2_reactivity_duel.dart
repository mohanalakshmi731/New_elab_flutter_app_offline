// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 3.2: The Reactivity Duel
// Converted from Cl10S-Ch3-A2-TheReactivityDuel.html (React + Motion -> Flutter widgets).
//
// A 2D DOM simulation, so the canvas is a widget tree rather than a mini3d
// scene. Five zones, one per investigation step: burning in air (kerosene jar,
// burner over a ceramic tray, Mg ribbon / Al / Cu tray), the water bath
// (cold / hot beaker and the steam apparatus with a gas jar), the acid race
// (five HCl tubes with rate-true bubbling), the displacement duel (two tubes
// fast-forwarded 20 min) and the reactivity-series ranking game with the
// thermit rail weld. Each result opens the source's observation card with its
// equation; the sidebar is the source's step board (concept / do / observed).

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
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue400 = Color(0xFF60A5FA);
  static const blue600 = Color(0xFF2563EB);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const orange500 = Color(0xFFF97316);
  static const amber500 = Color(0xFFF59E0B);
  static const green50 = Color(0xFFF0FDF4);
  static const green500 = Color(0xFF22C55E);
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
      'title': 'The Reactivity Duel',
      'subtitle': 'Class 10 • Metals & Non-Metals',
      'button': 'Enter Arena',
      'footnote': 'Air • Water • Acid • Displacement',
    },
    'headerTitle': 'The Reactivity Duel',
    'headerSubtitle': 'NCERT Class 10 • Metals and Non-Metals',
    'tabs': {'explore': 'Investigation Steps', 'notes': 'Concept'},
    'objLabel': 'Main Objective',
    'objDesc':
        'Determine the order of reactivity by observing chemical battles in different environments.',
    'lblDo': 'What to do',
    'lblObs': 'What is observed',
    'lblConcept': 'Core Concept',
    'observation': 'Observation',
    'noReaction': 'No Reaction',
    'metals': {
      'K': 'Potassium',
      'Na': 'Sodium',
      'Ca': 'Calcium',
      'Mg': 'Magnesium',
      'Al': 'Aluminium',
      'Zn': 'Zinc',
      'Fe': 'Iron',
      'Pb': 'Lead',
      'Cu': 'Copper',
      'Ag': 'Silver',
      'Au': 'Gold',
      'MgRibbon': 'Magnesium Ribbon',
    },
    'zones': ['Fire', 'Water', 'Acid', 'Displacement', 'Final Rank'],
    'stepSelectLabel': 'Select Investigation Step',
    'stepN': 'Step {n}',
    'toggleLabels': 'Show / Hide Labels',
    'labels': {
      'kerosene': 'Kerosene Jar',
      'burner': 'Bunsen Burner',
      'samples': 'Samples',
      'tubeA': 'Tube A',
      'tubeB': 'Tube B',
      'cuso4': 'Blue CuSO₄',
      'feso4': 'Green FeSO₄',
      'nail': 'Iron Nail',
      'wire': 'Copper Wire',
      'leaderboard': 'Reactivity Series Game',
      'thermitZone': 'Bonus: Thermit Welding',
      'dispInst': "Tap 'Fast Forward' under each tube to see who wins.",
      'leaderInst': 'Tap a metal, then tap a rank slot (or drag it across).',
      'thermitInst': 'Railway track cracked! Mix Fe₂O₃ + Al and ignite.',
      'mostReactive': 'Most Reactive',
      'leastReactive': 'Least Reactive',
      'checkOrder': 'Check Order',
      'correct': 'Correct! You cracked the code.',
      'tryAgain': 'Not quite. Try again.',
      'showHint': 'Show Hint',
      'hint': 'Hint: K > Na > Ca > Mg > Al > Zn > Fe > Pb > Cu > Ag > Au',
      'dropHere': 'Drop Here',
      'reset': 'Reset Zone',
      'ceramicTray': 'Ceramic Tray',
      'glassWool': 'Glass Wool (Water)',
      'steam': 'Steam',
      'metalSample': 'Metal Sample',
      'deliveryTube': 'Delivery Tube',
      'hcl': 'Dilute HCl',
      'samplePalette': 'Metal Samples Palette',
      'waiting': 'Waiting...',
      'hot': 'HOT',
    },
    'sim': {
      'dragInstruction':
          'Tap a metal, or drag it onto the burner, to test reactivity.',
      'naPopupTitle': 'High Reactivity Alert!',
      'hydroTabs': ['Cold', 'Hot', 'Steam'],
      'hydroInst': 'Tap or drag a metal sample into the water.',
      'acidInst': 'Tap a sample below to drop it into dilute HCl.',
      'dispA': 'Tube A: Fe + CuSO₄',
      'dispB': 'Tube B: Cu + FeSO₄',
      'thermitBtn': 'Ignite Fuse',
      'fastForward': 'Fast Forward (20 min)',
      'burnNa':
          'Sodium reacts vigorously with oxygen and catches fire instantly in air.\nReason: Stored in kerosene to prevent fires.',
      'burnMg':
          'Magnesium burns with a dazzling white flame.\nReason: Forms white powder of Magnesium Oxide (MgO).',
      'burnAl':
          'Aluminium does not burn.\nReason: Forms a protective oxide layer (Al₂O₃) preventing further oxidation.',
      'burnCu':
          'Copper does not burn.\nReason: Coats with black Copper(II) Oxide.',
      'kReact': 'Violent and exothermic. Hydrogen catches fire.',
      'caReact': 'Calcium floats. Less violent.',
      'mgHotReact': 'Reacts with hot water. Floats.',
      'feSteamReact': 'Reacts only with steam.',
      'moreVigorous': 'Reacts even more vigorously.',
      'rateIncreases': 'Rate increases',
      'acidMg': 'Rapid bubble formation.',
      'acidFe': 'Slow bubble formation.',
      'acidCu': 'No bubbles. Copper is less reactive than Hydrogen.',
      'dispObsA': 'Blue fades to green (FeSO₄). Iron is more reactive.',
      'dispObsB': 'No reaction. Copper is less reactive than Iron.',
      'thermitSuccess': 'Violent reaction. Molten iron produced.',
      'obsNoCold': 'No Reaction in Cold Water',
      'obsNoHot': 'No Reaction in Hot Water',
      'obsNoSteam': 'No Reaction even with Steam',
      'obsH2': 'Bubbles of hydrogen observed.',
      'obsFloatsHot': 'Floats (Hot)',
    },
    'steps': [
      {
        'title': 'The Fire Test',
        'concept':
            'Metals react with oxygen to form metal oxides, but their reactivities vary. Highly reactive metals catch fire, while less reactive ones just get coated with oxide.',
        'action':
            'Take Sodium (Na) from the Kerosene jar to the burner. Then test Magnesium (Mg), Aluminium (Al) and Copper (Cu) from the tray.',
        'observation':
            'Sodium catches fire instantly. Magnesium burns with a dazzling white flame. Aluminium and Copper do not burn but get coated with their respective oxides.',
      },
      {
        'title': 'The Water Test',
        'concept':
            "Metals react with water to produce metal oxides/hydroxides and hydrogen gas. The temperature of water required indicates the metal's reactivity.",
        'action':
            'Select Cold, Hot or Steam, then put the available metals into the water.',
        'observation':
            'Potassium and Sodium react violently with cold water, catching fire. Calcium floats. Magnesium reacts only with hot water. Iron reacts only with steam.',
      },
      {
        'title': 'The Acid Race',
        'concept':
            'Metals above hydrogen in the reactivity series displace hydrogen from dilute acids, forming metal salts and hydrogen gas.',
        'action':
            'Tap a metal from the palette to drop it into the dilute HCl test tubes. Watch the bubble rate.',
        'observation':
            'Magnesium produces bubbles most rapidly, followed by Aluminium, Zinc and Iron. Copper produces no bubbles as it is less reactive than Hydrogen.',
      },
      {
        'title': 'The Displacement Duel',
        'concept':
            'A more reactive metal displaces a less reactive metal from its salt solution.',
        'action':
            "Tap 'Fast Forward' on Tube A (Fe + CuSO₄) and Tube B (Cu + FeSO₄) to see the final results.",
        'observation':
            'Iron displaces Copper, turning the blue solution green. Copper cannot displace Iron, resulting in no reaction.',
      },
      {
        'title': 'Final Rank',
        'concept':
            'The Reactivity Series ranks metals. We can use highly reactive metals like Aluminium to displace less reactive metals like Iron in highly exothermic reactions (Thermit process).',
        'action':
            'Put the metals into their correct reactivity order (high to low). Then ignite the Thermit mixture to fix the railway track.',
        'observation':
            'The correct order is K > Na > Ca > Mg > Al > Zn > Fe > Pb > Cu > Ag > Au. The Thermit reaction produces molten iron to join tracks.',
      },
    ],
  },
  'hi': {
    'intro': {
      'title': 'अभिक्रियाशीलता द्वंद्व',
      'subtitle': 'कक्षा 10 • धातु और अधातु',
      'button': 'अखाड़े में प्रवेश करें',
      'footnote': 'वायु • जल • अम्ल • विस्थापन',
    },
    'headerTitle': 'अभिक्रियाशीलता द्वंद्व',
    'headerSubtitle': 'एनसीईआरटी कक्षा 10 • धातु और अधातु',
    'tabs': {'explore': 'जांच के चरण', 'notes': 'अवधारणा'},
    'objLabel': 'मुख्य उद्देश्य',
    'objDesc':
        'विभिन्न वातावरणों में रासायनिक द्वंद्व देखकर अभिक्रियाशीलता का क्रम निर्धारित करें।',
    'lblDo': 'क्या करना है',
    'lblObs': 'क्या देखा गया',
    'lblConcept': 'मूल अवधारणा',
    'observation': 'अवलोकन',
    'noReaction': 'कोई अभिक्रिया नहीं',
    'metals': {
      'K': 'पोटैशियम',
      'Na': 'सोडियम',
      'Ca': 'कैल्शियम',
      'Mg': 'मैग्नीशियम',
      'Al': 'एल्युमीनियम',
      'Zn': 'जिंक',
      'Fe': 'लोहा',
      'Pb': 'सीसा',
      'Cu': 'तांबा',
      'Ag': 'चांदी',
      'Au': 'सोना',
      'MgRibbon': 'मैग्नीशियम रिबन',
    },
    'zones': ['अग्नि', 'जल', 'अम्ल', 'विस्थापन', 'अंतिम क्रम'],
    'stepSelectLabel': 'जांच चरण चुनें',
    'stepN': 'चरण {n}',
    'toggleLabels': 'लेबल दिखाएँ / छिपाएँ',
    'labels': {
      'kerosene': 'मिट्टी के तेल का जार',
      'burner': 'बन्सन बर्नर',
      'samples': 'नमूने',
      'tubeA': 'नली A',
      'tubeB': 'नली B',
      'cuso4': 'नीला CuSO₄',
      'feso4': 'हरा FeSO₄',
      'nail': 'लोहे की कील',
      'wire': 'तांबे का तार',
      'leaderboard': 'अभिक्रियाशीलता श्रेणी खेल',
      'thermitZone': 'बोनस: थर्मिट वेल्डिंग',
      'dispInst': 'परिणाम देखने के लिए हर नली के नीचे फास्ट फॉरवर्ड दबाएं।',
      'leaderInst': 'धातु पर टैप करें, फिर रैंक स्लॉट पर टैप करें (या खींचें)।',
      'thermitInst': 'रेल पटरी टूट गई! Fe₂O₃ + Al मिलाएं और प्रज्वलित करें।',
      'mostReactive': 'सर्वाधिक अभिक्रियाशील',
      'leastReactive': 'सबसे कम अभिक्रियाशील',
      'checkOrder': 'क्रम जांचें',
      'correct': 'सही! आपने कोड तोड़ दिया।',
      'tryAgain': 'बिल्कुल नहीं। पुनः प्रयास करें।',
      'showHint': 'संकेत दिखाएं',
      'hint': 'संकेत: K > Na > Ca > Mg > Al > Zn > Fe > Pb > Cu > Ag > Au',
      'dropHere': 'यहाँ डालें',
      'reset': 'ज़ोन रीसेट करें',
      'ceramicTray': 'सिरेमिक ट्रे',
      'glassWool': 'ग्लास वूल (जल)',
      'steam': 'भाप',
      'metalSample': 'धातु का नमूना',
      'deliveryTube': 'निकास नली',
      'hcl': 'तनु HCl',
      'samplePalette': 'धातु के नमूने',
      'waiting': 'प्रतीक्षा...',
      'hot': 'गर्म',
    },
    'sim': {
      'dragInstruction':
          'अभिक्रियाशीलता जांचने के लिए धातु पर टैप करें, या उसे बर्नर पर खींचें।',
      'naPopupTitle': 'उच्च अभिक्रियाशीलता चेतावनी!',
      'hydroTabs': ['ठंडा', 'गर्म', 'भाप'],
      'hydroInst': 'धातु के नमूने को पानी में टैप करें या खींचें।',
      'acidInst': 'तनु HCl में डालने के लिए नीचे किसी नमूने पर टैप करें।',
      'dispA': 'नली A: Fe + CuSO₄',
      'dispB': 'नली B: Cu + FeSO₄',
      'thermitBtn': 'फ्यूज़ प्रज्वलित करें',
      'fastForward': 'फास्ट फॉरवर्ड (20 मिनट)',
      'burnNa':
          'सोडियम ऑक्सीजन के साथ तीव्रता से अभिक्रिया करता है और हवा में तुरंत आग पकड़ लेता है।\nकारण: आग रोकने के लिए मिट्टी के तेल में रखा जाता है।',
      'burnMg':
          'मैग्नीशियम चमकदार सफेद लौ के साथ जलता है।\nकारण: मैग्नीशियम ऑक्साइड (MgO) का सफेद चूर्ण बनता है।',
      'burnAl':
          'एल्युमीनियम नहीं जलता।\nकारण: सुरक्षात्मक ऑक्साइड परत (Al₂O₃) बनती है जो आगे ऑक्सीकरण रोकती है।',
      'burnCu':
          'तांबा नहीं जलता।\nकारण: काले कॉपर(II) ऑक्साइड की परत चढ़ जाती है।',
      'kReact': 'प्रचंड और ऊष्माक्षेपी। हाइड्रोजन आग पकड़ लेती है।',
      'caReact': 'कैल्शियम तैरता है। कम प्रचंड।',
      'mgHotReact': 'गर्म पानी के साथ अभिक्रिया करता है। तैरता है।',
      'feSteamReact': 'केवल भाप के साथ अभिक्रिया करता है।',
      'moreVigorous': 'और भी तीव्रता से अभिक्रिया करता है।',
      'rateIncreases': 'दर बढ़ जाती है',
      'acidMg': 'तेजी से बुलबुले बनते हैं।',
      'acidFe': 'धीरे-धीरे बुलबुले बनते हैं।',
      'acidCu': 'कोई बुलबुला नहीं। तांबा हाइड्रोजन से कम अभिक्रियाशील है।',
      'dispObsA':
          'नीला रंग हरे (FeSO₄) में बदलता है। लोहा अधिक अभिक्रियाशील है।',
      'dispObsB': 'कोई अभिक्रिया नहीं। तांबा लोहे से कम अभिक्रियाशील है।',
      'thermitSuccess': 'प्रचंड अभिक्रिया। पिघला हुआ लोहा बना।',
      'obsNoCold': 'ठंडे पानी में कोई अभिक्रिया नहीं',
      'obsNoHot': 'गर्म पानी में कोई अभिक्रिया नहीं',
      'obsNoSteam': 'भाप के साथ भी कोई अभिक्रिया नहीं',
      'obsH2': 'हाइड्रोजन के बुलबुले देखे गए।',
      'obsFloatsHot': 'तैरता है (गर्म)',
    },
    'steps': [
      {
        'title': 'अग्नि परीक्षण',
        'concept':
            'धातुएँ ऑक्सीजन से अभिक्रिया करके धातु ऑक्साइड बनाती हैं, पर उनकी अभिक्रियाशीलता अलग-अलग होती है। अधिक अभिक्रियाशील धातुएँ आग पकड़ लेती हैं।',
        'action':
            'सोडियम (Na) को मिट्टी के तेल के जार से बर्नर तक ले जाएं। फिर ट्रे से मैग्नीशियम (Mg), एल्युमीनियम (Al) और तांबा (Cu) जांचें।',
        'observation':
            'सोडियम तुरंत आग पकड़ लेता है। मैग्नीशियम चमकदार सफेद लौ से जलता है। एल्युमीनियम और तांबा नहीं जलते पर उन पर ऑक्साइड की परत चढ़ जाती है।',
      },
      {
        'title': 'जल परीक्षण',
        'concept':
            'धातुएँ जल से अभिक्रिया करके ऑक्साइड/हाइड्रॉक्साइड और हाइड्रोजन गैस बनाती हैं। आवश्यक जल का तापमान अभिक्रियाशीलता दर्शाता है।',
        'action':
            'ठंडा, गर्म या भाप चुनें, फिर उपलब्ध धातुओं को पानी में डालें।',
        'observation':
            'पोटैशियम और सोडियम ठंडे पानी से प्रचंड अभिक्रिया करते हैं। कैल्शियम तैरता है। मैग्नीशियम केवल गर्म पानी से और लोहा केवल भाप से अभिक्रिया करता है।',
      },
      {
        'title': 'अम्ल दौड़',
        'concept':
            'अभिक्रियाशीलता श्रेणी में हाइड्रोजन से ऊपर की धातुएँ तनु अम्ल से हाइड्रोजन विस्थापित करती हैं।',
        'action':
            'तनु HCl की परखनलियों में डालने के लिए किसी धातु पर टैप करें। बुलबुलों की दर देखें।',
        'observation':
            'मैग्नीशियम सबसे तेज बुलबुले बनाता है, फिर एल्युमीनियम, जिंक और लोहा। तांबा कोई बुलबुला नहीं बनाता।',
      },
      {
        'title': 'विस्थापन द्वंद्व',
        'concept':
            'अधिक अभिक्रियाशील धातु कम अभिक्रियाशील धातु को उसके लवण विलयन से विस्थापित कर देती है।',
        'action':
            'नली A (Fe + CuSO₄) और नली B (Cu + FeSO₄) पर फास्ट फॉरवर्ड दबाएं।',
        'observation':
            'लोहा तांबे को विस्थापित करता है और नीला विलयन हरा हो जाता है। तांबा लोहे को विस्थापित नहीं कर सकता।',
      },
      {
        'title': 'अंतिम क्रम',
        'concept':
            'अभिक्रियाशीलता श्रेणी धातुओं का क्रम बताती है। एल्युमीनियम जैसी अधिक अभिक्रियाशील धातु लोहे को विस्थापित कर सकती है (थर्मिट प्रक्रिया)।',
        'action':
            'धातुओं को सही अभिक्रियाशीलता क्रम में रखें। फिर थर्मिट मिश्रण प्रज्वलित करें।',
        'observation':
            'सही क्रम है K > Na > Ca > Mg > Al > Zn > Fe > Pb > Cu > Ag > Au। थर्मिट अभिक्रिया पिघला लोहा बनाती है।',
      },
    ],
  },
});

/// Metal swatches for the blocks, tubes and ranking chips.
const _metalColors = {
  'K': Color(0xFFCBD5E1),
  'Na': Color(0xFFE2E8F0),
  'Ca': Color(0xFFDDE3E8),
  'Mg': Color(0xFFD1D5DB),
  'Al': Color(0xFFE5E9EC),
  'Zn': Color(0xFFB8C0C6),
  'Fe': Color(0xFF8A949B),
  'Pb': Color(0xFF6B7280),
  'Cu': Color(0xFFFB923C),
  'Ag': Color(0xFFD8DEE4),
  'Au': Color(0xFFE6B800),
};

const _correctOrder = [
  'K',
  'Na',
  'Ca',
  'Mg',
  'Al',
  'Zn',
  'Fe',
  'Pb',
  'Cu',
  'Ag',
  'Au',
];

/// Source `inventory`: the shuffled pile the ranking game starts from.
const _startInventory = [
  'Zn',
  'Cu',
  'K',
  'Ag',
  'Mg',
  'Au',
  'Na',
  'Fe',
  'Ca',
  'Pb',
  'Al',
];

/// Metals offered per water tab (cold / hot / steam).
const _hydroPalettes = [
  ['K', 'Na', 'Ca', 'Mg'],
  ['Mg', 'Fe'],
  ['Al', 'Fe', 'Zn', 'Pb', 'Cu', 'Ag'],
];

/// Source `reactivity`: bubble interval in seconds; 0 means no reaction.
const _acidInterval = {'Mg': 0.1, 'Al': 0.3, 'Zn': 0.6, 'Fe': 1.2, 'Cu': 0.0};
const _acidMetals = ['Mg', 'Al', 'Zn', 'Fe', 'Cu'];

/// Water-bath states (source `reactionState`).
enum _Hydro { idle, reacting, noReaction }

class Cl10SCh03A2ReactivityDuelPage extends StatefulWidget {
  const Cl10SCh03A2ReactivityDuelPage({super.key});

  @override
  State<Cl10SCh03A2ReactivityDuelPage> createState() =>
      _Cl10SCh03A2ReactivityDuelPageState();
}

class _Cl10SCh03A2ReactivityDuelPageState
    extends State<Cl10SCh03A2ReactivityDuelPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();
  final ScrollController _zoneBar = ScrollController();

  int _zone = 0;
  final List<bool> _done = [false, false, false, false, false];
  bool _busy = false;
  bool _showLabels = false; // source default: labels hidden
  Timer? _timer;

  // Zone 1: fire.
  bool _sodiumOut = false;
  String? _burning; // metal currently in the flame

  // Zone 2: water.
  int _waterTab = 0;
  String? _inWater;
  _Hydro _hydro = _Hydro.idle;

  // Zone 3: acid.
  final Map<String, double> _bubbles = {};
  String? _dropping;

  // Zone 4: displacement.
  String? _ffTube; // 'A' | 'B' while fast-forwarding
  final Set<String> _reactedTubes = {};

  // Zone 5: ranking game + thermit.
  final List<String?> _slots = List<String?>.filled(11, null);
  final List<String> _inventory = List<String>.of(_startInventory);
  String? _picked;
  bool? _orderCorrect;
  int _wrongAttempts = 0;
  bool _showHint = false;
  bool _thermit = false;

  /// Shared loop for flames, bubbles and steam (CSS `infinite` animations).
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  /// One-shot clocks: magnesium powder fall, water-bath motion, acid drop,
  /// thermit stream + sparks.
  late final AnimationController _powder = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  );
  late final AnimationController _bath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _spark = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  );

  List<dynamic> get _steps => _tx.list('steps');

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
    _timer?.cancel();
    _zoom.dispose();
    _zoneBar.dispose();
    _loop.dispose();
    _powder.dispose();
    _bath.dispose();
    _drop.dispose();
    _spark.dispose();
    super.dispose();
  }

  String _metalName(String symbol) => _tx.s('metals.$symbol');

  /// The source's ObservationModal: title, sentence(s) and the equation.
  /// [sound] plays as it opens (null when the event already made a sound).
  Future<void> _observe({
    required String title,
    required String message,
    required String equation,
    required bool isReaction,
    _rt_Sfx? sound,
  }) async {
    if (sound != null) _rt_playSfx(sound);
    await _rt_showShellPopup(
      context,
      title: title,
      message: message,
      icon: isReaction ? Icons.science : Icons.block,
      color: isReaction ? _rt_Tw.sky400 : _rt_Tw.slate500,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _rt_Lab.overlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _rt_Lab.border),
        ),
        child: Text(
          equation,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _rt_Lab.onTinted(_rt_Tw.sky400, _rt_Tw.sky500),
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  /// HTML completeStep only sets the zone's flag; there is no completion
  /// message (QA C10-3.2-01).
  void _completeStep(int zone) {
    if (_done[zone]) return;
    setState(() => _done[zone] = true);
  }

  void _setZone(int z) {
    // Source: AudioEngine.play('pop') on the step selector.
    _rt_playSfx(_rt_Sfx.scenario);
    _timer?.cancel();
    setState(() {
      _zone = z;
      _busy = false;
      // Each zone remounts in the source, so its visuals start fresh.
      _burning = null;
      _sodiumOut = false;
      _inWater = null;
      _hydro = _Hydro.idle;
      _dropping = null;
      _ffTube = null;
      _thermit = false;
    });
    _powder.reset();
    _bath.reset();
    _spark.reset();
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _showLabels = !_showLabels);
  }

  // -------------------------------------------------------- zone 1: fire ---
  Future<void> _burn(String metal) async {
    if (_busy) return;
    const zone = 0;
    setState(() {
      _busy = true;
      _burning = metal;
      if (metal == 'Na') _sodiumOut = true;
    });
    // Source: AudioEngine.play('fire') for every metal put in the flame.
    _rt_playSfx(_rt_Sfx.magic);
    if (metal == 'Mg') _powder.forward(from: 0);
    // Source waits 2.0 s for sodium and 2.5 s for the tray metals.
    await Future<void>.delayed(
      Duration(milliseconds: metal == 'Na' ? 2000 : 2500),
    );
    if (!mounted || _zone != zone || _burning != metal) return;
    final (msg, title) = switch (metal) {
      'Na' => (_tx.s('sim.burnNa'), _tx.s('sim.naPopupTitle')),
      'Mg' => (_tx.s('sim.burnMg'), _tx.s('observation')),
      'Al' => (_tx.s('sim.burnAl'), _tx.s('observation')),
      _ => (_tx.s('sim.burnCu'), _tx.s('observation')),
    };
    _completeStep(zone);
    await _observe(
      title: title,
      message: msg,
      equation: _burnEquation(metal),
      isReaction: true,
      sound: _rt_Sfx.correct,
    );
    if (!mounted || _zone != zone) return;
    // Source resetVisuals(): closing the card puts sodium back in the jar.
    _powder.reset();
    setState(() {
      _burning = null;
      _sodiumOut = false;
      _busy = false;
    });
  }

  String _burnEquation(String metal) => switch (metal) {
    'Na' => '4Na + O₂ → 2Na₂O',
    'Mg' => '2Mg + O₂ → 2MgO',
    'Al' => '4Al + 3O₂ → 2Al₂O₃',
    _ => '2Cu + O₂ → 2CuO',
  };

  // ------------------------------------------------------- zone 2: water ---
  void _setWaterTab(int i) {
    _rt_playSfx(_rt_Sfx.toggle);
    _timer?.cancel();
    _bath.reset();
    setState(() {
      _waterTab = i;
      _inWater = null;
      _hydro = _Hydro.idle;
      _busy = false;
    });
  }

  void _intoWater(String metal) {
    if (_busy) return;
    String msg, eq, title = _tx.s('observation');
    bool isReaction;

    switch (_waterTab) {
      case 0: // cold
        if (metal == 'K' || metal == 'Na') {
          isReaction = true;
          title = _tx.s('sim.naPopupTitle');
          msg = _tx.s('sim.kReact');
          eq = metal == 'K'
              ? '2K + 2H₂O → 2KOH + H₂ + Heat'
              : '2Na + 2H₂O → 2NaOH + H₂ + Heat';
        } else if (metal == 'Ca') {
          isReaction = true;
          msg = _tx.s('sim.caReact');
          eq = 'Ca + 2H₂O → Ca(OH)₂ + H₂';
        } else {
          isReaction = false;
          msg = _tx.s('sim.obsNoCold');
          eq = _tx.s('noReaction');
        }
      case 1: // hot
        if (metal == 'Mg') {
          isReaction = true;
          msg = _tx.s('sim.mgHotReact');
          eq = 'Mg + 2H₂O → Mg(OH)₂ + H₂';
        } else if (['K', 'Na', 'Ca'].contains(metal)) {
          isReaction = true;
          msg = _tx.s('sim.moreVigorous');
          eq = _tx.s('sim.rateIncreases');
        } else {
          isReaction = false;
          msg = _tx.s('sim.obsNoHot');
          eq = _tx.s('noReaction');
        }
      default: // steam
        if (['Al', 'Fe', 'Zn'].contains(metal)) {
          isReaction = true;
          msg = _tx.s('sim.feSteamReact');
          eq = switch (metal) {
            'Al' => '2Al + 3H₂O(g) → Al₂O₃ + 3H₂',
            'Fe' => '3Fe + 4H₂O(g) → Fe₃O₄ + 4H₂',
            _ => 'Zn + H₂O(g) → ZnO + H₂',
          };
        } else {
          isReaction = false;
          msg = _tx.s('sim.obsNoSteam');
          eq = _tx.s('noReaction');
        }
    }

    setState(() {
      _busy = true;
      _inWater = metal;
      _hydro = isReaction ? _Hydro.reacting : _Hydro.noReaction;
    });
    _bath.forward(from: 0);
    // Source: AudioEngine.play('bubble') when it reacts; a quiet plop otherwise.
    _rt_playSfx(isReaction ? _rt_Sfx.pop : _rt_Sfx.tap);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      _completeStep(1);
      await _observe(
        title: title,
        message: msg,
        equation: eq,
        isReaction: isReaction,
        sound: isReaction ? _rt_Sfx.correct : _rt_Sfx.toggle,
      );
      if (!mounted || _zone != 1) return;
      // Source: closing the card resets the bath.
      _bath.reset();
      setState(() {
        _inWater = null;
        _hydro = _Hydro.idle;
        _busy = false;
      });
    });
  }

  // -------------------------------------------------------- zone 3: acid ---
  Future<void> _intoAcid(String metal) async {
    if (_busy) return;
    // Source: AudioEngine.play('pop') on the palette click.
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _busy = true;
      _dropping = metal;
      _bubbles.remove(metal);
    });
    _drop.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || _zone != 2) return;
    setState(() {
      _bubbles[metal] = _acidInterval[metal]!;
      _dropping = null;
    });
    // Source: AudioEngine.play('bubble') if it fizzes.
    _rt_playSfx(_acidInterval[metal]! > 0 ? _rt_Sfx.pop : _rt_Sfx.tap);
    // Source waits 3 s here; shortened so the race stays watchable.
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted || _zone != 2) return;
    final (msg, eq) = switch (metal) {
      'Mg' => (_tx.s('sim.acidMg'), 'Mg + 2HCl → MgCl₂ + H₂'),
      'Fe' => (_tx.s('sim.acidFe'), 'Fe + 2HCl → FeCl₂ + H₂'),
      'Cu' => (_tx.s('sim.acidCu'), 'Cu + HCl → No Reaction'),
      _ => (_tx.s('sim.obsH2'), '$metal + HCl → ...'),
    };
    _completeStep(2);
    setState(() => _busy = false);
    await _observe(
      title: _tx.s('observation'),
      message: msg,
      equation: eq,
      isReaction: _acidInterval[metal]! > 0,
      sound: _acidInterval[metal]! > 0 ? _rt_Sfx.correct : _rt_Sfx.toggle,
    );
  }

  // ------------------------------------------------ zone 4: displacement ---
  Future<void> _fastForward(String tube) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _ffTube = tube;
      _reactedTubes.remove(tube); // re-runs start from fresh solution
    });
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted || _zone != 3) return;
    setState(() {
      _reactedTubes.add(tube);
      _ffTube = null;
    });
    // Source: AudioEngine.play('success') when the 20 minutes are up.
    _rt_playSfx(_rt_Sfx.success);
    _completeStep(3);
    final isA = tube == 'A';
    await _observe(
      title: _tx.s(isA ? 'labels.tubeA' : 'labels.tubeB'),
      message: _tx.s(isA ? 'sim.dispObsA' : 'sim.dispObsB'),
      equation: isA ? 'Fe + CuSO₄ → FeSO₄ + Cu' : 'Cu + FeSO₄ → No Reaction',
      isReaction: isA,
    );
    if (!mounted) return;
    setState(() => _busy = false);
  }

  // -------------------------------------------------- zone 5: final rank ---
  void _pick(String metal) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _picked = _picked == metal ? null : metal);
  }

  void _placeInSlot(int index, String metal) {
    setState(() {
      final previous = _slots[index];
      _slots[index] = metal;
      _inventory.remove(metal);
      // A metal moved from another slot leaves that slot empty.
      for (var i = 0; i < _slots.length; i++) {
        if (i != index && _slots[i] == metal) _slots[i] = null;
      }
      // A slot that already held something hands that metal back to the pile.
      if (previous != null && previous != metal) _inventory.add(previous);
      _picked = null;
      _orderCorrect = null;
    });
    _rt_playSfx(_rt_Sfx.pop);
  }

  void _returnToInventory(int index) {
    final metal = _slots[index];
    if (metal == null) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _slots[index] = null;
      _inventory.add(metal);
      _orderCorrect = null;
    });
  }

  void _checkOrder() {
    final correct = _slots.join(',') == _correctOrder.join(',');
    setState(() {
      _orderCorrect = correct;
      if (!correct) _wrongAttempts++;
    });
    // Source: AudioEngine.play('success' | 'wrong').
    _rt_playSfx(correct ? _rt_Sfx.success : _rt_Sfx.wrong);
  }

  Future<void> _ignite() async {
    if (_busy || _thermit) return;
    // Source: AudioEngine.play('fire').
    _rt_playSfx(_rt_Sfx.magic);
    setState(() {
      _busy = true;
      _thermit = true;
    });
    _spark.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted || _zone != 4) return;
    _completeStep(4);
    await _observe(
      title: _tx.s('labels.thermitZone'),
      message: _tx.s('sim.thermitSuccess'),
      equation: 'Fe₂O₃ + 2Al → 2Fe + Al₂O₃ + Heat',
      isReaction: true,
      sound: _rt_Sfx.correct,
    );
    if (!mounted) return;
    _spark.reset();
    setState(() {
      _thermit = false;
      _busy = false;
    });
  }

  /// Puts the current zone back to its opening state.
  void _resetZone() {
    _timer?.cancel();
    _powder.reset();
    _bath.reset();
    _drop.reset();
    _spark.reset();
    setState(() {
      _busy = false;
      switch (_zone) {
        case 0:
          _sodiumOut = false;
          _burning = null;
        case 1:
          _inWater = null;
          _hydro = _Hydro.idle;
        case 2:
          _bubbles.clear();
          _dropping = null;
        case 3:
          _reactedTubes.clear();
          _ffTube = null;
        default:
          for (var i = 0; i < _slots.length; i++) {
            _slots[i] = null;
          }
          _inventory
            ..clear()
            ..addAll(_startInventory);
          _picked = null;
          _orderCorrect = null;
          _wrongAttempts = 0;
          _showHint = false;
          _thermit = false;
      }
    });
  }

  void _restart() {
    // The shell already plays the restart sound.
    _timer?.cancel();
    _powder.reset();
    _bath.reset();
    _drop.reset();
    _spark.reset();
    _zoom.reset();
    if (_zoneBar.hasClients) _zoneBar.jumpTo(0);
    setState(() {
      _zone = 0;
      _busy = false;
      _showLabels = false;
      _sodiumOut = false;
      _burning = null;
      _waterTab = 0;
      _inWater = null;
      _hydro = _Hydro.idle;
      _bubbles.clear();
      _dropping = null;
      _reactedTubes.clear();
      _ffTube = null;
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = null;
      }
      _inventory
        ..clear()
        ..addAll(_startInventory);
      _picked = null;
      _orderCorrect = null;
      _wrongAttempts = 0;
      _showHint = false;
      _thermit = false;
      for (var i = 0; i < _done.length; i++) {
        _done[i] = false;
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
          final step = _steps[_zone] as Map;
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSubtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.sky500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF0C4A6E)],
              headerSubtitleColor: Color(0xFFBAE6FD),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              footnote: _tx.s('intro.footnote'),
              icon: Icons.science,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _ToolbarToggle(
                key: const ValueKey('labels-toggle'),
                active: _showLabels,
                icon: Icons.sell,
                tooltip: _tx.s('toggleLabels'),
                onTap: _toggleLabels,
              ),
            ],
            hint: _rt_StepHint(
              number: '${_zone + 1}',
              text: step['action'] as String,
              label: step['title'] as String,
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('tabs.explore'),
                icon: Icons.checklist,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _rt_ZoomableCanvas(controller: _zoom, child: _zoneCanvas()),
          );
        },
      ),
    );
  }

  Widget _zoneCanvas() {
    final zones = _tx.list('zones');
    return Column(
      children: [
        SingleChildScrollView(
          controller: _zoneBar,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(70, 12, 60, 2),
          child: Row(
            children: [
              for (var i = 0; i < zones.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _zoneChip(i, zones[i] as String),
                ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 8, 56, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, c.maxHeight - 24),
                ),
                child: Center(
                  child: switch (_zone) {
                    0 => _fireZone(),
                    1 => _waterZone(),
                    2 => _acidZone(),
                    3 => _displacementZone(),
                    _ => _rankZone(),
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _zoneChip(int i, String label) {
    final on = _zone == i;
    return GestureDetector(
      onTap: () => _setZone(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? _rt_Tw.sky500 : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: on ? _rt_Tw.sky400 : _rt_Lab.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_done[i]) ...[
              Icon(
                Icons.check_circle,
                size: 13,
                color: on ? Colors.white : _rt_Tw.green500,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: on ? Colors.white : _rt_Lab.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Name tag shown over a sample while labels are on (source MetalBlock hover tip).
  Widget _nameTag(String text) => Container(
    // Kept no wider than the sample below it, or the fire-zone row overflows
    // once labels are switched on.
    constraints: const BoxConstraints(maxWidth: 72),
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: _rt_Lab.surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _rt_Lab.border),
      boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 4)],
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _rt_Lab.text,
        ),
      ),
    ),
  );

  /// A metal sample: draggable onto a target and tappable as a fallback.
  Widget _metalBlock(
    String symbol, {
    double size = 46,
    VoidCallback? onTap,
    bool enabled = true,
    bool ribbon = false,
    String? name,
  }) {
    final Widget chip;
    if (ribbon) {
      // Magnesium ribbon: a thin, shiny strip with its symbol underneath.
      chip = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size * 1.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD1D5DB), Colors.white, Color(0xFFD1D5DB)],
              ),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            symbol,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.textMuted,
            ),
          ),
        ],
      );
    } else {
      chip = _plainBlock(symbol, size);
    }
    final tagged = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showLabels && enabled) _nameTag(name ?? _metalName(symbol)),
        chip,
      ],
    );
    if (!enabled) return Opacity(opacity: 0.45, child: chip);
    return GestureDetector(
      onTap: onTap,
      child: Draggable<String>(
        data: symbol,
        hitTestBehavior: HitTestBehavior.opaque,
        onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
        feedback: Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              chip,
              // The source picks samples up with forceps.
              const Positioned(left: -10, top: -44, child: _Forceps()),
            ],
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: tagged),
        child: tagged,
      ),
    );
  }

  /// The bare metal cube (source `.phet-block`).
  Widget _plainBlock(String symbol, double size) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(_metalColors[symbol]!, Colors.white, 0.35)!,
          _metalColors[symbol]!,
          Color.lerp(_metalColors[symbol]!, Colors.black, 0.28)!,
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black26),
      boxShadow: const [
        BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(2, 3)),
      ],
    ),
    child: Text(
      symbol,
      style: TextStyle(
        fontSize: size * 0.36,
        fontWeight: FontWeight.w900,
        color: _rt_Tw.slate800,
      ),
    ),
  );

  Widget _caption(String text, {Color? color, double size = 10}) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color ?? _rt_Lab.textMuted,
    ),
  );

  /// White call-out tag for apparatus parts (source's floating labels).
  Widget _partTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF9CA3AF)),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    ),
  );

  Widget _instructionPill(String text) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: _rt_Lab.surface,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: _rt_Lab.border),
      boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.text,
      ),
    ),
  );

  Widget _zoneResetButton() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(
      width: 170,
      child: _rt_ActionButton(
        label: _tx.s('labels.reset'),
        icon: Icons.refresh,
        color: _rt_Tw.slate500,
        expand: true,
        onPressed: _busy ? null : _resetZone,
      ),
    ),
  );

  /// Rounded "stage" panel each zone sits on (source: bg-panel-solid card).
  Widget _stage({required Widget child, Color? color}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color ?? _rt_Lab.base,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _rt_Lab.border),
      boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
    ),
    child: child,
  );

  // ------------------------------------------------------------- zone 1 ---
  Widget _fireZone() {
    return _stage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _instructionPill(_tx.s('sim.dragInstruction')),
          // Scales down slightly when the name tags widen the bench.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _keroseneJar(),
                const SizedBox(width: 18),
                DragTarget<String>(
                  onWillAcceptWithDetails: (d) =>
                      ['Na', 'Mg', 'Al', 'Cu'].contains(d.data),
                  onAcceptWithDetails: (d) => _burn(d.data),
                  builder: (context, cand, _) => Container(
                    key: const ValueKey('burner-zone'),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cand.isNotEmpty
                            ? _rt_Tw.orange500
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: _burnerRig(),
                  ),
                ),
                const SizedBox(width: 18),
                // Sample tray.
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  decoration: BoxDecoration(
                    color: _rt_Lab.overlay,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rt_Lab.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _metalBlock(
                            'Mg',
                            size: 34,
                            ribbon: true,
                            name: _tx.s('metals.MgRibbon'),
                            onTap: _busy ? null : () => _burn('Mg'),
                          ),
                          const SizedBox(width: 8),
                          _metalBlock(
                            'Al',
                            size: 38,
                            onTap: _busy ? null : () => _burn('Al'),
                          ),
                          const SizedBox(width: 8),
                          _metalBlock(
                            'Cu',
                            size: 38,
                            onTap: _busy ? null : () => _burn('Cu'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _caption(_tx.s('labels.samples')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _zoneResetButton(),
        ],
      ),
    );
  }

  Widget _keroseneJar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showLabels) _nameTag(_tx.s('labels.kerosene')),
        SizedBox(
          width: 96,
          height: 124,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Glass jar.
              Positioned.fill(
                top: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x3393C5FD),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF94A3B8),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Kerosene.
              Positioned(
                left: 6,
                right: 6,
                bottom: 4,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x663B82F6),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    border: const Border(
                      top: BorderSide(color: Color(0x4D60A5FA)),
                    ),
                  ),
                ),
              ),
              // Lid.
              Positioned(
                top: 0,
                left: -4,
                right: -4,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
                    ),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFF6B7280)),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _tx.s('labels.kerosene').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: _sodiumOut
                    ? const SizedBox(width: 30, height: 30)
                    : _metalBlock(
                        'Na',
                        size: 30,
                        onTap: _busy ? null : () => _burn('Na'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _burnerRig() {
    final burning = _burning;
    return SizedBox(
      width: 170,
      height: 236,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Ceramic tray under the burner (catches the MgO powder).
          Positioned(
            bottom: 0,
            child: Container(
              width: 166,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _caption(
                    _tx.s('labels.ceramicTray'),
                    color: const Color(0xFF64748B),
                    size: 9,
                  ),
                  // White MgO powder pile builds up as the ash falls.
                  AnimatedBuilder(
                    animation: _powder,
                    builder: (context, _) {
                      final pile = ((_powder.value * 3.5 - 1.2) / 2).clamp(
                        0.0,
                        1.0,
                      );
                      if (pile == 0) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 2,
                        child: Container(
                          width: 90 * pile,
                          height: 8 * pile,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [
                              BoxShadow(color: Colors.white70, blurRadius: 4),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Burner: base, barrel with air hole, blue flame.
          Positioned(
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _loop,
                  builder: (context, _) => Container(
                    width: 14,
                    height: 40 + 4 * math.sin(_loop.value * math.pi * 20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(99),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xCC93C5FD),
                          Color(0x0093C5FD),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF9CA3AF),
                        Color(0xFFE5E7EB),
                        Color(0xFF9CA3AF),
                      ],
                    ),
                    border: Border.symmetric(
                      vertical: BorderSide(color: Color(0xFF6B7280)),
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: 10,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF374151),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showLabels)
            Positioned(
              right: -6,
              bottom: 70,
              child: _partTag(_tx.s('labels.burner')),
            ),
          // The metal's own reaction above the burner.
          if (burning != null)
            Positioned(
              bottom: 130,
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, _) {
                  final (colors, w, h) = switch (burning) {
                    'Na' => (
                      const [
                        Color(0xFFEA580C),
                        Color(0xFFFBBF24),
                        Color(0x00FBBF24),
                      ],
                      70.0,
                      96.0,
                    ),
                    'Mg' => (
                      const [
                        Colors.white,
                        Color(0xFFDBEAFE),
                        Color(0x00DBEAFE),
                      ],
                      42.0,
                      90.0,
                    ),
                    'Al' => (
                      const [Color(0xFF9CA3AF), Color(0x009CA3AF)],
                      36.0,
                      50.0,
                    ),
                    _ => (
                      const [
                        Color(0xFF111827),
                        Color(0xFF000000),
                        Color(0x00000000),
                      ],
                      42.0,
                      62.0,
                    ),
                  };
                  final flick =
                      0.92 + 0.12 * math.sin(_loop.value * math.pi * 30).abs();
                  final dazzle = burning == 'Mg'
                      ? 0.7 + 0.3 * math.sin(_loop.value * math.pi * 6)
                      : 1.0;
                  return Opacity(
                    opacity: dazzle.clamp(0.0, 1.0),
                    child: Container(
                      width: w,
                      height: h * flick,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: colors,
                        ),
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: burning == 'Mg'
                            ? const [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 30,
                                  spreadRadius: 6,
                                ),
                              ]
                            : burning == 'Na'
                            ? const [
                                BoxShadow(
                                  color: Color(0xAAF97316),
                                  blurRadius: 24,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          // The metal held in the flame.
          if (burning != null)
            Positioned(
              bottom: 120,
              child: burning == 'Mg'
                  ? Container(width: 44, height: 8, color: Colors.white)
                  : Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: burning == 'Cu'
                            ? const Color(0xFF1F2937)
                            : _metalColors[burning],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
            ),
          // Magnesium's white ash drifting down onto the tray.
          if (burning == 'Mg')
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _powder,
                  builder: (context, _) =>
                      CustomPaint(painter: _PowderPainter(_powder.value * 3.5)),
                ),
              ),
            ),
          // Equation call-out over the flame (source reaction label).
          if (burning != null)
            Positioned(
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _burnEquation(burning),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFDE047),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- zone 2 ---
  Widget _waterZone() {
    final tabs = _tx.list('sim.hydroTabs');
    final tabColors = [_rt_Tw.blue600, _rt_Tw.orange500, _rt_Tw.slate600];
    return _stage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _instructionPill(_tx.s('sim.hydroInst')),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DragTarget<String>(
                onWillAcceptWithDetails: (d) =>
                    _hydroPalettes[_waterTab].contains(d.data),
                onAcceptWithDetails: (d) => _intoWater(d.data),
                builder: (context, cand, _) => Container(
                  key: const ValueKey('hydro-target'),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cand.isNotEmpty
                          ? _rt_Tw.sky400
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _waterTab < 2 ? _beaker() : _steamRig(),
                ),
              ),
              const SizedBox(width: 12),
              // Cold / Hot / Steam selector (source: vertical tab stack).
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _rt_Lab.overlay,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rt_Lab.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: GestureDetector(
                          onTap: () => _setWaterTab(i),
                          child: Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _waterTab == i
                                  ? tabColors[i]
                                  : _rt_Lab.surface,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: _waterTab == i
                                    ? tabColors[i]
                                    : _rt_Lab.border,
                              ),
                            ),
                            child: Text(
                              tabs[i] as String,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: _waterTab == i
                                    ? Colors.white
                                    : _rt_Lab.text,
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
          const SizedBox(height: 10),
          // Sample palette bar.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  _tx.s('labels.samples').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                for (final m in _hydroPalettes[_waterTab])
                  _metalBlock(
                    m,
                    size: 40,
                    onTap: _busy ? null : () => _intoWater(m),
                  ),
              ],
            ),
          ),
          _zoneResetButton(),
        ],
      ),
    );
  }

  /// Cold / hot water beaker with the metal's behaviour animated inside.
  Widget _beaker() {
    const w = 190.0, h = 170.0;
    final hot = _waterTab == 1;
    final metal = _inWater;
    final bubbling =
        _hydro == _Hydro.reacting &&
        metal != null &&
        (['K', 'Na', 'Ca'].contains(metal) || (hot && metal == 'Mg'));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glass and water.
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x33DBEAFE),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    border: const Border(
                      left: BorderSide(color: Color(0x99FFFFFF), width: 4),
                      right: BorderSide(color: Color(0x99FFFFFF), width: 4),
                      bottom: BorderSide(color: Color(0x99FFFFFF), width: 8),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 4,
                right: 4,
                bottom: 8,
                height: h * 0.72,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0x4D3B82F6),
                      border: Border(top: BorderSide(color: Color(0x8060A5FA))),
                    ),
                    child: bubbling
                        ? AnimatedBuilder(
                            animation: _loop,
                            builder: (context, _) => CustomPaint(
                              painter: _RisingBubbles(
                                _loop.value,
                                15,
                                seed: 11,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              if (hot)
                Center(
                  child: Text(
                    _tx.s('labels.hot'),
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: _rt_Tw.red500.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              if (metal != null) _metalInWater(metal, w, h),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _caption(_tx.list('sim.hydroTabs')[_waterTab] as String, size: 11),
        if (hot) ...[
          const SizedBox(height: 2),
          // Burner heating the hot bath.
          AnimatedBuilder(
            animation: _loop,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 22 + 3 * math.sin(_loop.value * math.pi * 24),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(99),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFFF97316),
                        Color(0xFFFDE047),
                        Color(0x00FDE047),
                      ],
                    ),
                  ),
                ),
                Container(width: 48, height: 8, color: const Color(0xFF374151)),
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _metalInWater(String metal, double w, double h) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bath, _loop]),
      builder: (context, _) {
        final t = _bath.value;
        final enter = Curves.easeOut.transform((t / 0.125).clamp(0.0, 1.0));
        final surface = h * 0.28;
        double y; // top of the metal piece
        double x = w / 2 - 14;
        double rot = 0;
        Widget? tag;
        Widget? extra;
        if (_hydro == _Hydro.noReaction) {
          // Sinks straight to the bottom.
          y = -30 + (h - 50) * enter;
          tag = _warnTag(_tx.s('noReaction'));
        } else if (metal == 'K' || metal == 'Na') {
          // Skates about on the surface, on fire.
          y = -30 + (surface - 10 + 30) * enter;
          final p = _loop.value * 2 * math.pi;
          x += 40 * math.sin(p * 1.33);
          rot = 0.35 * math.sin(p * 10);
          extra = const Icon(
            Icons.local_fire_department,
            color: Color(0xFFF97316),
            size: 30,
          );
        } else if (metal == 'Ca') {
          // Sinks, then the hydrogen bubbles lift it back up.
          final bottom = h - 50, top = surface - 6;
          y = t < 0.4
              ? -30 +
                    (bottom + 30) *
                        Curves.easeOut.transform((t / 0.4).clamp(0.0, 1.0))
              : bottom -
                    (bottom - top) *
                        Curves.easeInOut.transform(
                          ((t - 0.4) / 0.6).clamp(0.0, 1.0),
                        );
        } else {
          // Magnesium in hot water floats.
          y = -30 + (surface + 16 + 30) * enter;
          tag = _partTag(_tx.s('sim.obsFloatsHot'));
          extra = Opacity(
            opacity: 1 - (_loop.value * 2 % 1),
            child: Container(
              width: 28 + 16 * (_loop.value * 2 % 1),
              height: 28 + 16 * (_loop.value * 2 % 1),
              decoration: const BoxDecoration(
                color: Colors.white54,
                shape: BoxShape.circle,
              ),
            ),
          );
        }
        final piece = Transform.rotate(
          angle: rot,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (metal == 'K' || metal == 'Na')
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFF9CA3AF),
              shape: (metal == 'K' || metal == 'Na')
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: (metal == 'K' || metal == 'Na')
                  ? null
                  : BorderRadius.circular(4),
              border: Border.all(color: Colors.black54),
            ),
            child: Text(
              metal,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        );
        return Positioned(
          left: x,
          top: y,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (extra != null && metal != 'K' && metal != 'Na') extra,
              piece,
              if (extra != null && (metal == 'K' || metal == 'Na'))
                Positioned(top: -30, child: extra),
              if (tag != null) Positioned(top: -24, child: tag),
            ],
          ),
        );
      },
    );
  }

  Widget _warnTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF991B1B),
      ),
    ),
  );

  /// Steam apparatus: boiling tube with wet glass wool and the metal, delivery
  /// tube, and a gas jar collecting hydrogen over water.
  Widget _steamRig() {
    final metal = _inWater;
    final reacting = _hydro == _Hydro.reacting;
    final hot = reacting && ['Fe', 'Al', 'Zn'].contains(metal);
    return Container(
      width: 400,
      height: 190,
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Steam clouds rising while it reacts.
          if (reacting)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (context, _) =>
                      CustomPaint(painter: _SteamPainter(_loop.value)),
                ),
              ),
            ),
          // Boiling tube (horizontal).
          Positioned(
            left: 12,
            top: 78,
            child: Container(
              width: 190,
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                ),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0xFF4B5563), width: 2),
              ),
              child: Row(
                children: [
                  // Wet glass wool.
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEAB308)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_tx.s('labels.steam')} →',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Metal sample.
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _loop,
                      builder: (context, _) => Container(
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hot
                              ? Color.lerp(
                                  const Color(0xFFD1D5DB),
                                  const Color(0xFFEF4444),
                                  0.6 +
                                      0.4 *
                                          math
                                              .sin(_loop.value * math.pi * 4)
                                              .abs(),
                                )
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF9CA3AF)),
                          boxShadow: hot
                              ? const [
                                  BoxShadow(
                                    color: Color(0xAAEF4444),
                                    blurRadius: 14,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          metal ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Burner flame under the tube while heating.
          if (reacting)
            Positioned(
              left: 110,
              top: 122,
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, _) => Container(
                  width: 14,
                  height: 36 + 4 * math.sin(_loop.value * math.pi * 24),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(99),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00F97316),
                        Color(0xFFF97316),
                        Color(0x663B82F6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Delivery tube.
          Positioned(
            left: 200,
            top: 98,
            child: Container(
              width: 70,
              height: 6,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          Positioned(
            left: 266,
            top: 98,
            child: Container(
              width: 6,
              height: 60,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          // Trough of water with the inverted gas jar.
          Positioned(
            left: 236,
            bottom: 10,
            child: Container(
              width: 130,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x80BFDBFE),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                border: Border.all(color: const Color(0xFF60A5FA)),
              ),
            ),
          ),
          Positioned(
            left: 272,
            bottom: 26,
            child: Container(
              width: 62,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0x4DDBEAFE),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                border: Border.all(color: const Color(0xFF4B5563), width: 2),
              ),
              alignment: Alignment.topCenter,
              // Hydrogen collects from the top as it displaces the water.
              child: AnimatedBuilder(
                animation: _bath,
                builder: (context, _) => Container(
                  height: hot
                      ? 55 *
                            Curves.easeOut.transform(
                              (_bath.value * 1.3).clamp(0.0, 1.0),
                            )
                      : 0,
                  decoration: const BoxDecoration(
                    color: Color(0xCCFFFFFF),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Part labels.
          Positioned(
            left: 4,
            top: 50,
            child: _partTag(_tx.s('labels.glassWool')),
          ),
          Positioned(
            left: 110,
            top: 50,
            child: _partTag(_tx.s('labels.metalSample')),
          ),
          Positioned(
            left: 214,
            top: 70,
            child: _partTag(_tx.s('labels.deliveryTube')),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- zone 3 ---
  Widget _acidZone() {
    return _stage(
      color: const Color(0xFF1A202C),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _instructionPill(_tx.s('sim.acidInst')),
          SizedBox(
            width: 400,
            height: 190,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Wooden test-tube rack.
                Positioned(
                  bottom: 26,
                  left: 10,
                  right: 10,
                  child: Transform(
                    transform: Matrix4.skewX(-0.2),
                    alignment: Alignment.center,
                    child: Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xCC78350F),
                        borderRadius: BorderRadius.circular(4),
                        border: const Border(
                          top: BorderSide(color: Color(0xFFB45309)),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF92400E),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < _acidMetals.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: _acidTube(_acidMetals[i], first: i == 0),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _tx.s('labels.samplePalette').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final m in _acidMetals)
                      GestureDetector(
                        key: ValueKey('acid-$m'),
                        onTap: _busy ? null : () => _intoAcid(m),
                        child: Opacity(
                          opacity: _busy ? 0.5 : 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _plainBlock(m, 38),
                              const SizedBox(height: 3),
                              Text(
                                _metalName(m),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _rt_Lab.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _zoneResetButton(),
        ],
      ),
    );
  }

  /// One HCl tube; the bubble stream follows the source's per-metal rate, so
  /// the tubes visibly rank Mg > Al > Zn > Fe > Cu.
  Widget _acidTube(String metal, {bool first = false}) {
    final interval = _bubbles[metal];
    final dropping = _dropping == metal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 150,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Glass.
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x1AFFFFFF),
                        Color(0x66FFFFFF),
                        Color(0x1AFFFFFF),
                        Color(0x1AFFFFFF),
                      ],
                      stops: [0, 0.2, 0.4, 1],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(22),
                    ),
                    border: Border.all(
                      color: const Color(0x99FFFFFF),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Acid.
              Positioned(
                left: 2,
                right: 2,
                bottom: 2,
                height: 96,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0x33A855F7),
                      border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
                    ),
                    child: (interval != null && interval > 0)
                        ? AnimatedBuilder(
                            animation: _loop,
                            builder: (context, _) => CustomPaint(
                              painter: _AcidBubbles(
                                _loop.value,
                                interval,
                                seed: metal.hashCode,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // The metal piece resting at the bottom.
              if (interval != null)
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: 22,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B5563),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              // Falling piece.
              if (dropping)
                AnimatedBuilder(
                  animation: _drop,
                  builder: (context, _) => Positioned(
                    top: -40 + 170 * Curves.easeIn.transform(_drop.value),
                    child: Opacity(
                      opacity: _drop.value > 0.85 ? 0 : 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _metalColors[metal],
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                  ),
                ),
              if (first)
                Positioned(
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _rt_Lab.surface,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _rt_Lab.border),
                    ),
                    child: Text(
                      _tx.s('labels.hcl'),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(maxWidth: 58),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _rt_Lab.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _metalName(metal),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- zone 4 ---
  Widget _displacementZone() {
    return _stage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _instructionPill(_tx.s('labels.dispInst')),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dispTube('A'),
              const SizedBox(width: 24),
              _dispTube('B'),
            ],
          ),
          _zoneResetButton(),
        ],
      ),
    );
  }

  Widget _dispTube(String tube) {
    final isA = tube == 'A';
    final reacted = _reactedTubes.contains(tube);
    final waiting = _ffTube == tube;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Text(
            _tx.s(isA ? 'sim.dispA' : 'sim.dispB'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.text,
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 230,
          height: 150,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Glass tube.
              Container(
                width: 90,
                height: 150,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x1AFFFFFF),
                      Color(0x66FFFFFF),
                      Color(0x1AFFFFFF),
                      Color(0x1AFFFFFF),
                    ],
                    stops: [0, 0.2, 0.4, 1],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                  border: Border.all(color: const Color(0x99FFFFFF), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Solution: CuSO₄ blue fades to FeSO₄ green in tube A.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 127,
                      child: TweenAnimationBuilder<Color?>(
                        duration: const Duration(seconds: 2),
                        tween: ColorTween(
                          end: isA
                              ? (reacted
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF3B82F6))
                              : const Color(0xFFBBF7D0),
                        ),
                        builder: (context, c, _) => Container(color: c),
                      ),
                    ),
                    if (isA) ...[
                      // Iron nail: head and shaft, coated brown with copper after.
                      Positioned(
                        top: 24,
                        child: Container(
                          width: 14,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B5563),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 28,
                        child: TweenAnimationBuilder<Color?>(
                          duration: const Duration(seconds: 2),
                          tween: ColorTween(
                            end: reacted
                                ? const Color(0xFFB45309)
                                : const Color(0xFF6B7280),
                          ),
                          builder: (context, c, _) => Container(
                            width: 6,
                            height: 80,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (reacted)
                        const Positioned(
                          bottom: 10,
                          child: Text(
                            'FeSO₄',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                    ] else ...[
                      // Copper wire hanging into a coil.
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 2,
                          height: 110,
                          color: const Color(0xFFC2410C),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        child: Transform(
                          transform: Matrix4.skewY(0.2),
                          child: Container(
                            width: 34,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFEA580C),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (waiting)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _loop,
                          builder: (context, _) => Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity:
                                  0.5 +
                                  0.5 *
                                      math.sin(_loop.value * math.pi * 4).abs(),
                              child: Text(
                                _tx.s('labels.waiting'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Solution / metal call-outs either side of the tube.
              Positioned(
                left: 0,
                top: 80,
                child: _sideTag(
                  '${_tx.s(isA ? 'labels.cuso4' : 'labels.feso4')} →',
                ),
              ),
              Positioned(
                right: 0,
                top: 40,
                child: _sideTag(
                  '← ${_tx.s(isA ? 'labels.nail' : 'labels.wire')}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 150,
          child: _rt_ActionButton(
            key: ValueKey('ff-$tube'),
            label: _tx.s('sim.fastForward'),
            icon: Icons.fast_forward,
            color: _rt_Tw.sky500,
            expand: true,
            onPressed: _busy ? null : () => _fastForward(tube),
          ),
        ),
      ],
    );
  }

  Widget _sideTag(String text) => Container(
    constraints: const BoxConstraints(maxWidth: 68),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    decoration: BoxDecoration(
      color: _rt_Lab.surface,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: _rt_Lab.border),
      boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 3)],
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        color: _rt_Lab.text,
      ),
    ),
  );

  // ------------------------------------------------------------- zone 5 ---
  Widget _rankZone() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [_rankBoard(), _thermitPanel()],
    );
  }

  Widget _rankBoard() {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('labels.leaderboard'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.text,
            ),
          ),
          const SizedBox(height: 2),
          _caption(_tx.s('labels.leaderInst'), size: 10),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ranked column (most -> least reactive).
              SizedBox(
                width: 130,
                child: Column(
                  children: [
                    _caption(
                      _tx.s('labels.mostReactive'),
                      color: _rt_Tw.red500,
                      size: 10,
                    ),
                    const SizedBox(height: 3),
                    for (var i = 0; i < _slots.length; i++) _rankSlot(i),
                    const SizedBox(height: 3),
                    _caption(
                      _tx.s('labels.leastReactive'),
                      color: _rt_Tw.blue400,
                      size: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // The pile still to be ranked.
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 120),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _rt_Lab.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _rt_Lab.border),
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in _inventory)
                        _rankChip(m, picked: _picked == m),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _rt_ActionButton(
                  label: _tx.s('labels.checkOrder'),
                  icon: Icons.checklist,
                  color: _rt_Tw.sky500,
                  expand: true,
                  sound: null,
                  onPressed: _checkOrder,
                ),
              ),
              // Source: the hint button appears after two failed checks.
              if (_wrongAttempts >= 2 && _orderCorrect != true) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: _rt_ActionButton(
                    label: _tx.s('labels.showHint'),
                    icon: Icons.lightbulb,
                    color: _rt_Tw.amber500,
                    expand: true,
                    onPressed: () => setState(() => _showHint = !_showHint),
                  ),
                ),
              ],
            ],
          ),
          if (_orderCorrect != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _tx.s(_orderCorrect! ? 'labels.correct' : 'labels.tryAgain'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: _orderCorrect! ? _rt_Tw.green500 : _rt_Tw.red500,
                ),
              ),
            ),
          if (_showHint)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _rt_Lab.border),
              ),
              child: Text(
                _tx.s('labels.hint'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.text,
                ),
              ),
            ),
          _zoneResetButton(),
        ],
      ),
    );
  }

  Widget _rankChip(String metal, {bool picked = false}) {
    final chip = Container(
      key: ValueKey('pile-$metal'),
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: picked ? _rt_Tw.sky400 : const Color(0xFF9CA3AF),
          width: picked ? 3 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        metal,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: _rt_Tw.slate700,
        ),
      ),
    );
    return GestureDetector(
      onTap: () => _pick(metal),
      child: Draggable<String>(
        data: metal,
        hitTestBehavior: HitTestBehavior.opaque,
        onDragStarted: () => _rt_playSfx(_rt_Sfx.tap),
        feedback: Material(color: Colors.transparent, child: chip),
        childWhenDragging: Opacity(opacity: 0.3, child: chip),
        child: chip,
      ),
    );
  }

  Widget _rankSlot(int i) {
    final metal = _slots[i];
    return DragTarget<String>(
      onAcceptWithDetails: (d) => _placeInSlot(i, d.data),
      builder: (context, cand, _) => GestureDetector(
        onTap: () {
          if (_picked != null) {
            _placeInSlot(i, _picked!);
          } else if (metal != null) {
            _returnToInventory(i);
          }
        },
        child: CustomPaint(
          painter: metal == null
              ? _DashedBorder(
                  cand.isNotEmpty ? _rt_Tw.sky400 : _rt_Lab.borderStrong,
                )
              : null,
          child: Container(
            key: ValueKey('rank-$i'),
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: metal == null
                  ? (cand.isNotEmpty
                        ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.sky400)
                        : Colors.transparent)
                  : _rt_Lab.surface,
              borderRadius: BorderRadius.circular(5),
              border: metal == null
                  ? null
                  : Border.all(color: _rt_Tw.sky400, width: 2),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    metal ?? _tx.s('labels.dropHere'),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: metal == null ? 9.5 : 12,
                      fontWeight: FontWeight.w900,
                      color: metal == null ? _rt_Lab.textFaint : _rt_Lab.text,
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

  Widget _thermitPanel() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _rt_Tw.orange500,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _tx.s('labels.thermitZone'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tx.s('labels.thermitInst'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: _rt_Lab.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          _trackScene(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _rt_ActionButton(
              label: _tx.s('sim.thermitBtn'),
              icon: Icons.local_fire_department,
              color: _rt_Tw.red600,
              expand: true,
              onPressed: _busy ? null : _ignite,
            ),
          ),
        ],
      ),
    );
  }

  /// Cracked railway track with the thermit crucible above the gap.
  Widget _trackScene() {
    const w = 220.0, h = 146.0;
    final welded = _done[4] && !_thermit;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Ballast.
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF44403C),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF111827), width: 8),
                  ),
                ),
              ),
            ),
            // Sleepers.
            Positioned(
              left: 8,
              right: 8,
              top: h / 2 - 16,
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 6; i++)
                    Container(
                      width: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF78350F),
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
            // Rails.
            for (final y in [h * 0.4, h * 0.6])
              Positioned(
                left: 0,
                right: 0,
                top: y - 3,
                height: 6,
                child: Container(color: const Color(0xFF9CA3AF)),
              ),
            // The crack (or the weld once the job is done).
            Positioned(
              left: w / 2 - 7,
              top: h * 0.4 - 4,
              child: ClipPath(
                clipper: _CrackClipper(),
                child: Container(
                  width: 14,
                  height: h * 0.2 + 10,
                  color: welded ? const Color(0xFFB45309) : Colors.black,
                ),
              ),
            ),
            // Crucible on its tripod.
            Positioned(
              left: w / 2 - 28,
              top: 6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF78716C),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(99),
                      ),
                      border: Border.all(
                        color: const Color(0xFF57534E),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Fe₂O₃\n+ Al',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final dx in [-1.0, 1.0])
              Positioned(
                left: w / 2 - 1 + dx * 20,
                top: 44,
                child: Transform.rotate(
                  angle: -dx * 0.25,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 3,
                    height: 30,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            // Molten iron stream and glowing pool.
            if (_thermit)
              AnimatedBuilder(
                animation: Listenable.merge([_spark, _loop]),
                builder: (context, _) {
                  final grow = (_spark.value / 0.3).clamp(0.0, 1.0);
                  final pool = ((_spark.value - 0.2) / 0.2).clamp(0.0, 1.0);
                  return Stack(
                    children: [
                      Positioned(
                        left: w / 2 - 3,
                        top: 48,
                        child: Container(
                          width: 6,
                          height: 40 * grow,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFEF08A), Color(0xFFF97316)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF97316),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: w / 2 - 12 * pool,
                        top: h * 0.55,
                        child: Opacity(
                          opacity:
                              0.7 +
                              0.3 * math.sin(_loop.value * math.pi * 8).abs(),
                          child: Container(
                            width: 24 * pool,
                            height: 10 * pool,
                            decoration: BoxDecoration(
                              color: _rt_Tw.orange500,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFF97316),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            // Sparks (source: 50-particle canvas with gravity).
            if (_thermit)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _spark,
                    builder: (context, _) => CustomPaint(
                      painter: _SparkPainter(
                        _spark.value * 2.5,
                        Offset(w / 2, h * 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    final step = _steps[_zone] as Map;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('objLabel'),
          desc: _tx.s('objDesc'),
          accent: _rt_Tw.sky500,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Source: "Select Investigation Step" drop-down.
              _rt_SectionLabel(
                _tx.s('stepSelectLabel'),
                icon: Icons.format_list_numbered,
              ),
              for (var i = 0; i < _steps.length; i++) _stepRow(i),
              const SizedBox(height: 12),
              // Current step: title, core concept, what to do, what is observed.
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _rt_Tw.sky500,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_zone + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _rt_Lab.onTinted(_rt_Tw.sky400, _rt_Tw.sky500),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _boardCard(
                Icons.lightbulb,
                _tx.s('lblConcept'),
                step['concept'] as String,
              ),
              _boardCard(
                Icons.pan_tool_alt,
                _tx.s('lblDo'),
                step['action'] as String,
              ),
              if (_done[_zone])
                _boardCard(
                  Icons.visibility,
                  _tx.s('lblObs'),
                  step['observation'] as String,
                  accent: _rt_Tw.green500,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _boardCard(IconData icon, String label, String body, {Color? accent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent == null
            ? _rt_Lab.surface
            : _rt_Lab.tinted(_rt_Tw.green50, accent),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent == null ? _rt_Lab.border : _rt_Lab.tintedBorder(accent),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accent ?? _rt_Lab.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w900,
                    color: accent == null
                        ? _rt_Lab.textMuted
                        : _rt_Lab.onTinted(accent, _rt_Tw.green700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int i) {
    final step = _steps[i] as Map;
    final done = _done[i];
    final active = _zone == i;
    return GestureDetector(
      key: ValueKey('step-$i'),
      onTap: () => _setZone(i),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.sky500)
              : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? _rt_Tw.sky500 : _rt_Lab.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_tx.s('stepN').replaceAll('{n}', '${i + 1}')}: ${step['title']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? _rt_Lab.text : _rt_Lab.textMuted,
                ),
              ),
            ),
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: done ? _rt_Tw.green500 : _rt_Lab.textFaint,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- widgets ---

/// Round toggle for the canvas toolbar (the source's label tool).
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
            color: active ? _rt_Tw.sky500 : _rt_Lab.surface,
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

/// Forceps gripping a dragged sample (source `ForcepsHand`).
class _Forceps extends StatelessWidget {
  const _Forceps();

  @override
  Widget build(BuildContext context) {
    Widget arm(double angle) => Transform.rotate(
      angle: angle,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 5,
        height: 56,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(99)),
        ),
      ),
    );
    return SizedBox(
      width: 20,
      height: 56,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(left: 2, child: arm(-0.05)),
          Positioned(right: 2, child: arm(0.05)),
        ],
      ),
    );
  }
}

/// Bubbles rising through a water column (`animate-bubble-rise`).
class _RisingBubbles extends CustomPainter {
  _RisingBubbles(this.t, this.count, {required this.seed});

  final double t;
  final int count;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    final p = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 0; i < count; i++) {
      final x = r.nextDouble() * size.width;
      final phase = (t + r.nextDouble()) % 1;
      final a = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
      p.color = Colors.white.withValues(alpha: 0.6 * a);
      canvas.drawCircle(Offset(x + phase * 2, size.height * (1 - phase)), 4, p);
    }
  }

  @override
  bool shouldRepaint(covariant _RisingBubbles old) => old.t != t;
}

/// Bubbles in an acid tube; a shorter [interval] means a faster stream.
class _AcidBubbles extends CustomPainter {
  _AcidBubbles(this.t, this.interval, {required this.seed});

  final double t;
  final double interval;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    // 20 bubbles, each on its own cycle of interval*(1..2) s (loop is 2 s).
    final p = Paint();
    for (var i = 0; i < 20; i++) {
      final period = interval * (1 + r.nextDouble());
      final offset = r.nextDouble();
      final dx = r.nextDouble() * 20 - 10;
      // Slow tubes only show a few bubbles at a time.
      if (interval > 0.5 && i % (interval * 4).ceil() != 0) continue;
      final phase = ((t * 2) / period + offset) % 1;
      final a = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
      p.color = Colors.white.withValues(alpha: 0.7 * a);
      canvas.drawCircle(
        Offset(size.width / 2 + dx, size.height * (1 - phase)),
        2.5,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AcidBubbles old) =>
      old.t != t || old.interval != interval;
}

/// Steam clouds rising over the boiling tube (`animate-steam-rise`).
class _SteamPainter extends CustomPainter {
  _SteamPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final phase = (t + i * 0.25) % 1;
      final a = phase < 0.5 ? phase * 1.2 : (1 - phase) * 1.2;
      final p = Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.08), 90 - phase * 90),
        14 + 16 * phase,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter old) => old.t != t;
}

/// White MgO flakes drifting down from the flame (`animate-powder-fall`).
/// [seconds] is the time since the ribbon was lit.
class _PowderPainter extends CustomPainter {
  _PowderPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(5);
    final p = Paint();
    for (var i = 0; i < 20; i++) {
      final left = (r.nextDouble() - 0.5) * 40;
      final age = seconds - i * 0.1;
      if (age < 0 || age > 1.5) continue;
      final f = age / 1.5;
      final a = 1 - f;
      p.color = Colors.white.withValues(alpha: 0.9 * a);
      final wobble = f < 0.2
          ? 5 * f / 0.2
          : (f < 0.4 ? 5 - 10 * (f - 0.2) / 0.2 : 0.0);
      canvas.drawCircle(
        Offset(size.width / 2 + left + wobble, 110 + 120 * f * 0.9),
        2.5,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PowderPainter old) => old.seconds != seconds;
}

/// Thermit sparks: 50 particles from [origin] with gravity, as in the
/// source's canvas loop (60 fps steps; life drops 0.02 per frame).
class _SparkPainter extends CustomPainter {
  _SparkPainter(this.seconds, this.origin);

  final double seconds;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(9);
    final f = seconds * 60;
    final p = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < 50; i++) {
      final vx = (r.nextDouble() - 0.5) * 7;
      final vy = (r.nextDouble() - 0.5) * 7;
      final g = r.nextDouble() * 200;
      final rad = 1 + r.nextDouble() * 3;
      final life = 1 - 0.02 * f;
      if (life <= 0) continue;
      final pos = origin + Offset(vx * f, vy * f + 0.05 * f * f);
      p.color = Color.fromARGB(
        (255 * life.clamp(0.0, 1.0)).round(),
        255,
        g.round(),
        0,
      );
      canvas.drawCircle(pos, rad, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.seconds != seconds;
}

/// Dashed outline for an empty ranking slot.
class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1, 2.5, size.width - 2, size.height - 5);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)));
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, math.min(d + 4, m.length)), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder old) => old.color != color;
}

/// Tapered crack between the rail ends.
class _CrackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * 0.2, 0)
    ..lineTo(size.width * 0.8, 0)
    ..lineTo(size.width * 0.6, size.height)
    ..lineTo(size.width * 0.4, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
