// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 13.1: The Natural Pond
// Converted from Cl10S-Ch13-A1-TheNaturalPond.html (three.js emoji-sprite
// pond cross-section -> 2D CustomPainter station).
//
// A five-phase pond-ecosystem simulation: (1) stratification - drag (or
// tap-and-place) bacteria, phytoplankton, lotus and frog into their habitat
// zones; (2) food chain - tap Algae -> Protozoa -> Small Fish -> Large Fish
// while the sun streams energy particles down each link; (3) decomposition -
// fast-forward a week and watch bacteria recycle a dead fish into lotus
// nutrients; (4) interdependence - remove all frogs and the insect population
// explodes while the snake starves; (5) biomagnification - add pesticide and
// the ppm labels climb up the chain to the bird. Ends in the ECO EXPERT badge.

// --- TRANSLATION DATA (the source's I18N block; `te:` ignored) ---

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
  static const teal700 = Color(0xFF0F766E);
  static const teal900 = Color(0xFF134E4A);
  static const sky400 = Color(0xFF38BDF8);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue900 = Color(0xFF1E3A8A);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const pink500 = Color(0xFFEC4899);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const orange400 = Color(0xFFFB923C);
  static const orange600 = Color(0xFFEA580C);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
  static const emerald400 = Color(0xFF34D399);
  static const emerald600 = Color(0xFF059669);
  static const lime500 = Color(0xFF84CC16);
}

/// Pill action button (the HTML `.action-btn`). Plays a click sound.
class _rt_ActionButton extends StatelessWidget {
  const _rt_ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = _rt_Tw.teal600,
    this.done = false,
    this.expand = false,
    this.sound = _rt_Sfx.click,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done;
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

/// Generic content card (challenges, explainers, definitions, outcomes).
class _rt_InfoCard extends StatelessWidget {
  const _rt_InfoCard({
    this.title,
    this.body,
    this.tag,
    this.color = _rt_Tw.teal600,
    this.icon,
    this.leftBorder = false,
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag;
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
  const _rt_StepHint({required this.number, required this.text, this.label});

  final String number;
  final String text;
  final String? label;
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
  final List<Widget> toolbarExtras = const [];

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

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'app_title': 'THE NATURAL POND',
    'tagline': 'Class 10 • Our Environment',
    'init_btn': 'ENTER VIRTUAL LAB',
    'header_title': 'The Natural Pond',
    'header_subtitle': 'Class 10 • OUR ENVIRONMENT',
    'intro_foot': 'Trophic levels • Energy flow • Decomposition',
    'ctx_title': 'Why Learn This?',
    'guide_title': "Teacher's Guide",
    'post_title': 'Analysis & Outcomes',
    'btn_restart_caps': 'RESTART ACTIVITY',
    'hud_mission': 'CURRENT MISSION',
    'res_title': 'ECO EXPERT',
    'res_good': 'Ecosystem Balanced',
    'c1_t': 'Aquarium Maintenance',
    'c1_d':
        "Understand why artificial ponds need cleaning while natural ones don't.",
    'c2_t': 'Biological Control',
    'c2_d': 'Using frogs to control mosquitoes instead of chemicals.',
    'c3_t': 'Pollution Tracking',
    'c3_d': 'How toxins travel up the food chain (Biomagnification).',
    'g_intro':
        'This activity simulates a self-sustaining pond ecosystem. Students will build it layer by layer and disrupt it to see consequences.',
    'g_concept':
        'Key Concepts: Stratification, 10% Energy Law, Decomposition, Interdependence.',
    'g_steps':
        '1. Stratification: Place organisms in correct zones.\n'
        '2. Food Chain: Connect Producer → Consumers.\n'
        '3. Decomposition: Observe nutrient recycling.\n'
        '4. Balance: Remove a species and see the impact.\n'
        '5. Biomagnification: Observe pesticide concentration.',
    'lab_mission': 'Mission: Build the Ecosystem',
    'lab_desc': 'Construct a functional pond and test its limits.',
    'st1_t': 'Phase 1: Stratification',
    'st1_d': 'Drag each organism to its natural habitat to survive.',
    'st2_t': 'Phase 2: Food Chain',
    'st2_d':
        'Energy flows unidirectionally. Click organisms in order: Algae -> Protozoa -> Small Fish -> Large Fish.',
    'btn_reset_chain': 'Reset Chain',
    'chain_hint': 'Hint: Sun emits energy to Algae (Producer)...',
    'fb_100': 'Sun emits energy particles to Algae (100%).',
    'fb_10': 'Correct. 10% energy passed to next level.',
    'st3_t': 'Phase 3: Decomposition',
    'st3_d': 'A large fish has died. Observe how decomposers recycle it.',
    'btn_fast_forward': 'Fast Forward (1 Week)',
    'st4_t': 'Phase 4: Interdependence',
    'st4_d': 'Frogs control insects. What happens if we remove all frogs?',
    'btn_remove_frog': 'Remove All Frogs',
    'st5_t': 'Phase 5: Biomagnification',
    'st5_d': 'Observe how pesticide concentration increases up the food chain.',
    'btn_pesticide': 'Add Pesticide',
    'res_pt1': 'Nutrient Cycle',
    'res_pd1':
        'Decomposers recycle dead matter, making the pond self-sustaining.',
    'res_pt2': 'Ecological Balance',
    'res_pd2':
        'Removing one species causes population explosions/crashes in others.',
    'hud_ph1': 'ORGANIZE LAYERS',
    'hud_ph2': 'CONNECT CHAIN',
    'hud_ph3': 'OBSERVE DECAY',
    'hud_ph4': 'TEST BALANCE',
    'hud_ph5': 'BIOMAGNIFICATION',
    'msg_p1': 'Drag organisms to their natural habitat zones.',
    'msg_p1_done': 'Great! The pond is stratified.',
    'msg_p2':
        'Click organisms to trace the energy flow from Sun to Large Fish.',
    'msg_p2_done': 'Food chain established.',
    'msg_p3': 'Click Fast Forward to observe bacteria recycle the dead fish.',
    'msg_p4': 'Click Remove Frogs to see the impact on the web.',
    'msg_p4_done': 'Insect population exploded! Snakes starved.',
    'msg_p5': 'Add pesticide to observe biological magnification.',
    'msg_p5_done': 'Toxins concentrated at the top of the chain!',
    'lbl_algae': 'Algae',
    'lbl_proto': 'Protozoa',
    'lbl_fish_s': 'Small Fish',
    'lbl_fish_l': 'Large Fish',
    'lbl_dead_fish': 'Dead Fish',
    'lbl_insect': 'Insect',
    'lbl_frog': 'Frog',
    'lbl_bacteria': 'Bacteria',
    'lbl_lotus': 'Lotus',
    'lbl_phyto': 'Phytoplankton',
    'lbl_snake': 'Snake',
    'lbl_bird': 'Bird',
    'zone_mud': 'Benthic (Mud)',
    'zone_column': 'Water Column',
    'zone_surface': 'Surface Zone',
    'organisms_lbl': 'Organisms',
    'zones_lbl': 'Place in Zone',
    'chain_lbl': 'Tap in Order',
    'place_hint':
        'Tap an organism, then tap its habitat zone — or drag it on the pond.',
    'select_first': 'Tap an organism first.',
  },
  'hi': {
    'app_title': 'प्राकृतिक तालाब',
    'tagline': 'कक्षा 10 • हमारा पर्यावरण',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'प्राकृतिक तालाब',
    'header_subtitle': 'कक्षा 10 • हमारा पर्यावरण',
    'intro_foot': 'पोषी स्तर • ऊर्जा प्रवाह • अपघटन',
    'ctx_title': 'क्यों सीखें?',
    'guide_title': 'शिक्षक गाइड',
    'post_title': 'विश्लेषण और परिणाम',
    'btn_restart_caps': 'गतिविधि पुनः आरंभ करें',
    'hud_mission': 'वर्तमान मिशन',
    'res_title': 'इको एक्सपर्ट',
    'res_good': 'संतुलित पारिस्थितिकी तंत्र',
    'c1_t': 'एक्वेरियम रखरखाव',
    'c1_d': 'समझें कि कृत्रिम तालाबों को सफाई की आवश्यकता क्यों होती है।',
    'c2_t': 'जैविक नियंत्रण',
    'c2_d':
        'रसायनों के बजाय मच्छरों को नियंत्रित करने के लिए मेंढकों का उपयोग करना।',
    'c3_t': 'प्रदूषण ट्रैकिंग',
    'c3_d': 'विषाक्त पदार्थ खाद्य श्रृंखला में कैसे ऊपर जाते हैं।',
    'g_intro': 'यह गतिविधि एक तालाब पारिस्थितिकी तंत्र का अनुकरण करती है।',
    'g_concept':
        'मुख्य अवधारणाएँ: स्तरीकरण, 10% ऊर्जा नियम, अपघटन, परस्पर निर्भरता।',
    'g_steps':
        '1. स्तरीकरण: जीवों को सही क्षेत्रों में रखें।\n'
        '2. खाद्य श्रृंखला: उत्पादक → उपभोक्ता को जोड़ें।\n'
        '3. अपघटन: पोषक तत्व रीसाइक्लिंग देखें।\n'
        '4. संतुलन: एक प्रजाति को हटा दें और प्रभाव देखें।\n'
        '5. जैव आवर्धन: कीटनाशक सांद्रता देखें।',
    'lab_mission': 'मिशन: पारिस्थितिकी तंत्र का निर्माण',
    'lab_desc':
        'एक कार्यात्मक तालाब का निर्माण करें और इसकी सीमाओं का परीक्षण करें।',
    'st1_t': 'चरण 1: स्तरीकरण',
    'st1_d': 'जीवों को उनकी सही परतों पर खींचें: सतह, जल स्तंभ, या कीचड़।',
    'st2_t': 'चरण 2: खाद्य श्रृंखला',
    'st2_d':
        'ऊर्जा प्रवाह का पता लगाने के लिए जीवों पर क्लिक करें: शैवाल -> प्रोटोजोआ -> छोटी मछली -> बड़ी मछली।',
    'btn_reset_chain': 'श्रृंखला रीसेट करें',
    'chain_hint': 'संकेत: सूर्य शैवाल (उत्पादक) को ऊर्जा देता है...',
    'fb_100': 'सूर्य शैवाल को ऊर्जा कण (100%) उत्सर्जित करता है।',
    'fb_10': 'सही। 10% ऊर्जा अगले स्तर पर।',
    'st3_t': 'चरण 3: अपघटन',
    'st3_d':
        'एक बड़ी मछली मर गई है। देखें कि अपघटक इसे कैसे पुनर्चक्रित करते हैं।',
    'btn_fast_forward': 'फास्ट फॉरवर्ड (1 सप्ताह)',
    'st4_t': 'चरण 4: परस्पर निर्भरता',
    'st4_d':
        'मेंढक कीटों की आबादी को नियंत्रित करते हैं। सभी मेंढकों को हटा दें तो क्या होगा?',
    'btn_remove_frog': 'सभी मेंढकों को हटा दें',
    'st5_t': 'चरण 5: जैविक आवर्धन',
    'st5_d': 'देखें कि कैसे खाद्य श्रृंखला में कीटनाशकों की सांद्रता बढ़ती है।',
    'btn_pesticide': 'कीटनाशक डालें',
    'res_pt1': 'पोषक तत्व चक्र',
    'res_pd1': 'अपघटक मृत पदार्थों को रिसाइकिल करते हैं।',
    'res_pt2': 'पारिस्थितिक संतुलन',
    'res_pd2':
        'एक प्रजाति को हटाने से दूसरों में जनसंख्या विस्फोट/गिरावट होती है।',
    'hud_ph1': 'परतों को व्यवस्थित करें',
    'hud_ph2': 'श्रृंखला जोड़ें',
    'hud_ph3': 'क्षय का निरीक्षण करें',
    'hud_ph4': 'संतुलन का परीक्षण',
    'hud_ph5': 'जैविक आवर्धन',
    'msg_p1': 'जीवों को उनके प्राकृतिक आवास क्षेत्रों में खींचें।',
    'msg_p1_done': 'बहुत बढ़िया! तालाब स्तरीकृत है।',
    'msg_p2': 'सूर्य से ऊर्जा प्रवाह का पता लगाने के लिए जीवों पर क्लिक करें।',
    'msg_p2_done': 'खाद्य श्रृंखला स्थापित।',
    'msg_p3': 'देखें कि बैक्टीरिया मृत मछली को कैसे पुनर्चक्रित करते हैं।',
    'msg_p4': 'प्रभाव देखने के लिए मेंढकों को हटा दें।',
    'msg_p4_done': 'कीड़ों की आबादी बढ़ गई! संतुलन खो गया।',
    'msg_p5': 'जैविक आवर्धन का निरीक्षण करने के लिए कीटनाशक डालें।',
    'msg_p5_done': 'विषाक्त पदार्थ श्रृंखला के शीर्ष पर केंद्रित हो गए!',
    'lbl_algae': 'शैवाल',
    'lbl_proto': 'प्रोटोजोआ',
    'lbl_fish_s': 'छोटी मछली',
    'lbl_fish_l': 'बड़ी मछली',
    'lbl_dead_fish': 'मृत मछली',
    'lbl_insect': 'कीट',
    'lbl_frog': 'मेंढक',
    'lbl_bacteria': 'बैक्टीरिया',
    'lbl_lotus': 'कमल',
    'lbl_phyto': 'प्लवक',
    'lbl_snake': 'साँप',
    'lbl_bird': 'पक्षी',
    'zone_mud': 'कीचड़',
    'zone_column': 'पानी',
    'zone_surface': 'सतह',
    'organisms_lbl': 'जीव',
    'zones_lbl': 'क्षेत्र में रखें',
    'chain_lbl': 'क्रम में टैप करें',
    'place_hint':
        'किसी जीव पर टैप करें, फिर उसके आवास क्षेत्र पर टैप करें — या उसे तालाब पर खींचें।',
    'select_first': 'पहले किसी जीव पर टैप करें।',
  },
});

// ------------------------------------------------------------- models ---
/// One pond organism (the source's emoji sprite group).
class _Org {
  _Org(this.type, this.x, this.y, {this.locked = false}) : homeX = x, homeY = y;

  final String type;
  double x, y;
  final double homeX, homeY;
  bool locked;

  /// Lerp targets (gsap tweens in the source). `null` = not animating.
  double? tx, ty;
  double moveRate = 6; // lerp speed (1/s)

  double scale = 1;
  double? targetScale;
  double scaleRate = 4;

  double pulse = 0; // scale pop on a correct chain click
  double shake = 0; // horizontal shake on a wrong chain click
  double vx = 0; // fish swim velocity (world units/s)
  bool facingLeft = false;
  String suffix = ''; // ppm label suffix in phase 5
  bool visible = true;
}

/// Free particle (energy dot, decomposition bubble, toxin, swarm insect).
class _Particle {
  _Particle(this.kind, this.x, this.y, {this.delay = 0, this.color});
  final String kind; // energy | bubble | toxic | insect
  double x, y;
  double delay; // seconds before it becomes active (setTimeout stagger)
  double tx = 0, ty = 0; // energy target
  Color? color;
  double scale = 1;
  bool dead = false;
}

/// Food-chain / nutrient connection line.
class _Link {
  _Link(this.ax, this.ay, this.bx, this.by, this.color, {this.fades = false});
  final double ax, ay, bx, by;
  final Color color;
  final bool fades; // yellow energy links fade to 20% (heat loss)
  double age = 0;
}

class Cl10SCh13A1NaturalPondPage extends StatefulWidget {
  const Cl10SCh13A1NaturalPondPage({super.key});

  @override
  State<Cl10SCh13A1NaturalPondPage> createState() =>
      _Cl10SCh13A1NaturalPondPageState();
}

class _Cl10SCh13A1NaturalPondPageState extends State<Cl10SCh13A1NaturalPondPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();

  // ------------------------------------------------------- view state ---
  Size _canvasSize = Size.zero;
  double _zoomF = 1;
  Offset _panPx = Offset.zero;
  double _gestureBaseZoom = 1;

  double get _s0 => _canvasSize.isEmpty
      ? 1
      : math.min(_canvasSize.width / 24, _canvasSize.height / 12);
  double get _s => _s0 * _zoomF;

  Offset _toScreen(double x, double y) => Offset(
    _canvasSize.width / 2 + _panPx.dx + x * _s,
    _canvasSize.height / 2 + _panPx.dy - (y - 1.4) * _s,
  );

  Offset _toWorld(Offset p) => Offset(
    (p.dx - _canvasSize.width / 2 - _panPx.dx) / _s,
    1.4 - (p.dy - _canvasSize.height / 2 - _panPx.dy) / _s,
  );

  // -------------------------------------------------------- sim state ---
  bool _started = false;
  int _step = 1;
  String? _msgKey;
  String? _fbKey; // fb_100 / fb_10 chain feedback
  String? _selOrg; // organism picked in the sidebar (phase 1)
  int _placed = 0;
  final List<String> _chain = [];
  bool _decomposed = false;
  bool _frogsRemoved = false;
  bool _pesticideAdded = false;
  bool _celebrated = false;

  final List<_Org> _orgs = [];
  final List<_Particle> _particles = [];
  final List<_Link> _links = [];
  final List<Timer> _timers = [];
  _Org? _dragOrg;

  final math.Random _rand = math.Random();
  // Fixed scenery (rocks + plankton), like the source's random-but-static props.
  late final List<(double, double, double)> _rocks = _makeRocks();
  late final List<(double, double)> _plankton = _makePlankton();

  double _simT = 0;
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;
  final ValueNotifier<int> _frame = ValueNotifier(0);

  List<(double, double, double)> _makeRocks() {
    final r = math.Random(7);
    return [
      for (var i = 0; i < 5; i++)
        (
          -8.7 + r.nextDouble(),
          3 + r.nextDouble() * 0.8,
          0.5 + r.nextDouble() * 0.4,
        ),
      for (var i = 0; i < 5; i++)
        (
          8.7 - r.nextDouble(),
          3 + r.nextDouble() * 0.8,
          0.5 + r.nextDouble() * 0.4,
        ),
    ];
  }

  List<(double, double)> _makePlankton() {
    final r = math.Random(11);
    return [
      for (var i = 0; i < 60; i++)
        ((r.nextDouble() - 0.5) * 14, (r.nextDouble() - 0.5) * 5),
    ];
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadPhase1();
    _ticker.start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _cancelTimers();
    _frame.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------- helpers ---
  void _after(int ms, VoidCallback fn) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) fn();
      }),
    );
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  _Org? _findOrg(String type) {
    for (final o in _orgs) {
      if (o.type == type && o.visible) return o;
    }
    return null;
  }

  // -------------------------------------------------------- animation ---
  void _onTick(Duration elapsed) {
    var dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.25) dt = 0.05;
    _simT += dt;
    final t = _simT;

    for (var i = 0; i < _orgs.length; i++) {
      final o = _orgs[i];
      if (!o.visible) continue;
      // Tween toward targets (the source's gsap.to).
      if (o.tx != null) {
        o.x += (o.tx! - o.x) * math.min(1, dt * o.moveRate);
        if ((o.tx! - o.x).abs() < 0.02) o.tx = null;
      }
      if (o.ty != null) {
        o.y += (o.ty! - o.y) * math.min(1, dt * o.moveRate);
        if ((o.ty! - o.y).abs() < 0.02) o.ty = null;
      }
      if (o.targetScale != null) {
        o.scale += (o.targetScale! - o.scale) * math.min(1, dt * o.scaleRate);
        if ((o.targetScale! - o.scale).abs() < 0.01) {
          o.scale = o.targetScale!;
          if (o.scale <= 0.01) o.visible = false;
          o.targetScale = null;
        }
      }
      if (o.pulse > 0) o.pulse = math.max(0, o.pulse - dt * 2.5);
      if (o.shake > 0) o.shake = math.max(0, o.shake - dt * 3);

      // Fish swim horizontally between the banks (the source's velocity.x).
      final swims =
          (o.type == 'fish_s' || o.type == 'fish_l') &&
          o.vx != 0 &&
          o.tx == null &&
          !(_step == 3 && o.type == 'fish_l');
      if (swims && o != _dragOrg) {
        o.x += o.vx * dt;
        if (o.x > 7) {
          o.vx = -o.vx.abs();
          o.facingLeft = true;
        }
        if (o.x < -7) {
          o.vx = o.vx.abs();
          o.facingLeft = false;
        }
      }
    }

    // Particles.
    for (final p in _particles) {
      if (p.delay > 0) {
        p.delay -= dt;
        continue;
      }
      switch (p.kind) {
        case 'energy':
          final dx = p.tx - p.x, dy = p.ty - p.y;
          final d = math.sqrt(dx * dx + dy * dy);
          if (d < 0.25) {
            p.dead = true;
          } else {
            p.x += dx / d * 9 * dt;
            p.y += dy / d * 9 * dt;
          }
        case 'bubble':
          p.y += 1.8 * dt;
          p.x += math.sin(t * 5 + p.tx) * 0.01;
          if (p.y > 3) p.dead = true;
        case 'toxic':
          p.x += (_rand.nextDouble() - 0.5) * 0.1;
          p.y += (_rand.nextDouble() - 0.5) * 0.1;
        case 'insect':
          p.x += (_rand.nextDouble() - 0.5) * 0.2;
          p.y += (_rand.nextDouble() - 0.5) * 0.2;
          if (p.y < 0) p.y += 0.1;
          if (p.scale < 1) p.scale = math.min(1, p.scale + dt * 2);
      }
    }
    _particles.removeWhere((p) => p.dead);

    for (final l in _links) {
      l.age += dt;
    }

    _frame.value++;
  }

  // -------------------------------------------------------- lab logic ---
  void _setMsg(String key) => setState(() => _msgKey = key);

  void _gotoPhase(int n) {
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _step = n;
      _fbKey = null;
      _selOrg = null;
    });
    switch (n) {
      case 2:
        _loadPhase2();
        _setMsg('msg_p2');
      case 3:
        _loadPhase3();
        _setMsg('msg_p3');
      case 4:
        _loadPhase4();
        _setMsg('msg_p4');
      case 5:
        _loadPhase5();
        _setMsg('msg_p5');
    }
  }

  void _clearScene() {
    _orgs.clear();
    _particles.clear();
    _links.clear();
    _dragOrg = null;
  }

  // Phase 1 -- draggables spawn high above the pond (source loadPhase1).
  void _loadPhase1() {
    _clearScene();
    _placed = 0;
    _orgs.addAll([
      _Org('bacteria', -6, 6),
      _Org('phyto', -2, 6),
      _Org('lotus', 2, 6),
      _Org('frog', 6, 6),
    ]);
  }

  /// The source's checkPlacement zone rules.
  bool _placementCorrect(_Org o) => switch (o.type) {
    'lotus' => o.y > 2.0,
    'phyto' => o.y > -2.0 && o.y < 2.5,
    'bacteria' => o.y < -2.5,
    'frog' => o.y > 2.0,
    _ => false,
  };

  void _checkPlacement(_Org o) {
    if (o.locked || _step != 1) return;
    if (_placementCorrect(o)) {
      o.locked = true;
      // Source: sfx.play("bubble") -> pop.
      _rt_playSfx(_rt_Sfx.pop);
      // Snap tweens from the source.
      if (o.type == 'lotus') o.ty = 3.2;
      if (o.type == 'frog') o.ty = 3.0;
      if (o.type == 'bacteria') o.ty = -3.0;
      setState(() {
        _placed++;
        if (_selOrg == o.type) _selOrg = null;
      });
      if (_placed == 4) {
        _rt_playSfx(_rt_Sfx.success);
        _setMsg('msg_p1_done');
        _after(1500, () => _gotoPhase(2));
      }
    } else {
      // Springs back home (silent in the source; a buzz makes it audible).
      _rt_playSfx(_rt_Sfx.wrong);
      o.tx = o.homeX;
      o.ty = o.homeY;
      setState(() {});
    }
  }

  /// Sidebar alternative to the canvas drag: place the selected organism.
  void _placeSelectedInZone(double zoneY) {
    final sel = _selOrg == null ? null : _findOrg(_selOrg!);
    if (sel == null || sel.locked) {
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('select_first'),
        color: _rt_Tw.amber500,
        icon: Icons.touch_app,
      );
      return;
    }
    sel.x = sel.homeX;
    sel.y = zoneY;
    sel.tx = null;
    sel.ty = null;
    _checkPlacement(sel);
  }

  // Phase 2 -- sun + disconnected food chain (source loadPhase2).
  void _loadPhase2() {
    _clearScene();
    _chain.clear();
    _orgs.addAll([
      _Org('sun', -8, 6, locked: true),
      _Org('algae', -5, 0, locked: true),
      _Org('proto', -2, 2, locked: true),
      _Org('fish_s', 2, -1, locked: true),
      _Org('fish_l', 5, 1, locked: true),
    ]);
  }

  void _emitEnergy(_Org from, _Org to, Color color) {
    for (var i = 0; i < 15; i++) {
      _particles.add(
        _Particle('energy', from.x, from.y, delay: i * 0.05, color: color)
          ..tx = to.x
          ..ty = to.y,
      );
    }
  }

  void _handleChainTap(_Org o) {
    if (_step != 2) return;
    const expected = ['algae', 'proto', 'fish_s', 'fish_l'];
    final nextIdx = _chain.length;
    if (nextIdx >= expected.length) return;
    if (o.type == expected[nextIdx]) {
      _chain.add(o.type);
      o.pulse = 1;
      // Source: sfx.play("bubble") on a right link -> correct chime.
      _rt_playSfx(_rt_Sfx.correct);
      final prev = nextIdx == 0
          ? _findOrg('sun')!
          : _findOrg(expected[nextIdx - 1])!;
      _links.add(
        _Link(prev.x, prev.y, o.x, o.y, _rt_Tw.yellow400, fades: true),
      );
      _emitEnergy(prev, o, _rt_Tw.yellow400);
      setState(() => _fbKey = nextIdx == 0 ? 'fb_100' : 'fb_10');
      if (_chain.length == 4) {
        _rt_playSfx(_rt_Sfx.success);
        _setMsg('msg_p2_done');
        _after(3500, () => _gotoPhase(3));
      }
    } else {
      // Wrong order: the sprite shakes (silent in the source).
      _rt_playSfx(_rt_Sfx.wrong);
      o.shake = 1;
    }
  }

  void _resetChain() {
    if (_step != 2 || _chain.length == 4) return;
    _loadPhase2();
    setState(() => _fbKey = null);
    _setMsg('msg_p2');
  }

  // Phase 3 -- dead fish sinks onto the mud (source loadPhase3).
  void _loadPhase3() {
    _clearScene();
    _decomposed = false;
    _orgs.addAll([
      _Org('dead_fish', 0, 0, locked: true)
        ..ty = -2.2
        ..moveRate = 2,
      _Org('bacteria', -3, -3.2, locked: true),
      _Org('bacteria', 3, -3.2, locked: true),
      _Org('lotus', 0, 3.2, locked: true),
    ]);
  }

  void _triggerDecomposition() {
    if (_step != 3 || _decomposed) return;
    setState(() => _decomposed = true);
    final fish = _findOrg('dead_fish');
    if (fish != null) {
      fish.targetScale = 0;
      fish.scaleRate = 1; // ~3 s shrink, as in the source
    }
    // Bacteria get to work: bubbles rise off the mud.
    _rt_playSfx(_rt_Sfx.magic);
    for (var i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          'bubble',
          (_rand.nextDouble() - 0.5) * 2,
          -2.5,
          delay: i * 0.05,
        )..tx = _rand.nextDouble() * 6,
      );
    }
    // Nutrient recycling loop (blue) after 1.5 s; the lotus grows.
    _after(1500, () {
      final lotus = _findOrg('lotus');
      if (lotus == null) return;
      _rt_playSfx(_rt_Sfx.success);
      for (final b in _orgs.where((o) => o.type == 'bacteria')) {
        _links.add(_Link(b.x, b.y, lotus.x, lotus.y, _rt_Tw.blue500));
        _emitEnergy(b, lotus, _rt_Tw.blue500);
      }
      lotus.targetScale = 1.4;
      setState(() {});
    });
    _after(4000, () => _gotoPhase(4));
  }

  // Phase 4 -- frogs, insect, snake (source loadPhase4).
  void _loadPhase4() {
    _clearScene();
    _frogsRemoved = false;
    _orgs.addAll([
      _Org('frog', -4, -1, locked: true),
      _Org('frog', -2, -1.5, locked: true),
      _Org('insect', 2, 1, locked: true),
      _Org('snake', 5, -1, locked: true),
    ]);
  }

  void _removeFrogs() {
    if (_step != 4 || _frogsRemoved) return;
    setState(() => _frogsRemoved = true);
    // The frogs vanish; ecological alarm.
    _rt_playSfx(_rt_Sfx.wrong);
    for (final f in _orgs.where((o) => o.type == 'frog')) {
      f.targetScale = 0;
      f.scaleRate = 6;
    }
    // The snake starves (slow shrink, 1 s delay).
    _after(1000, () {
      final snake = _findOrg('snake');
      if (snake != null) {
        snake.targetScale = 0;
        snake.scaleRate = 1.5;
      }
    });
    _after(1000, () {
      // Insect swarm explosion.
      _rt_playSfx(_rt_Sfx.success);
      for (var i = 0; i < 30; i++) {
        _particles.add(
          _Particle(
            'insect',
            (_rand.nextDouble() - 0.5) * 12,
            _rand.nextDouble() * 4,
          )..scale = 0,
        );
      }
      _setMsg('msg_p4_done');
      _after(4000, () => _gotoPhase(5));
    });
  }

  // Phase 5 -- biomagnification chain (source loadPhase5).
  void _loadPhase5() {
    _clearScene();
    _pesticideAdded = false;
    _orgs.addAll([
      _Org('proto', -6, 0, locked: true),
      _Org('fish_s', -2, 0, locked: true),
      _Org('fish_l', 2, 0, locked: true),
      _Org('bird', 6, 3, locked: true),
    ]);
  }

  void _addPesticide() {
    if (_step != 5 || _pesticideAdded) return;
    setState(() => _pesticideAdded = true);
    // Toxic green particles rain through the water.
    _rt_playSfx(_rt_Sfx.magic);
    for (var i = 0; i < 50; i++) {
      _particles.add(
        _Particle(
          'toxic',
          (_rand.nextDouble() - 0.5) * 14,
          _rand.nextDouble() * 5,
          delay: i * 0.02,
        ),
      );
    }
    _after(1500, () {
      _rt_playSfx(_rt_Sfx.success);
      for (final o in _orgs) {
        o.suffix = switch (o.type) {
          'proto' => ' (0.01ppm)',
          'fish_s' => ' (0.1ppm)',
          'fish_l' => ' (1.0ppm)',
          'bird' => ' (10ppm)',
          _ => '',
        };
        if (o.suffix.isNotEmpty) o.pulse = 1;
      }
      _setMsg('msg_p5_done');
      _after(3000, _celebrate);
    });
  }

  void _celebrate() {
    if (_celebrated) return;
    setState(() => _celebrated = true);
    // showSuccess plays the success chime (source celebration sound).
    _shell.showSuccess(
      title: _tx.s('res_title'),
      message: _tx.s('res_good'),
      buttonLabel: _tx.s('btn_restart_caps'),
      icon: Icons.military_tech,
      color: _rt_Tw.amber500,
      onClose: _restart,
    );
  }

  void _restart() {
    // The shell already plays the restart sound.
    _cancelTimers();
    setState(() {
      _step = 1;
      _fbKey = null;
      _selOrg = null;
      _chain.clear();
      _decomposed = false;
      _frogsRemoved = false;
      _pesticideAdded = false;
      _celebrated = false;
      _zoomF = 1;
      _panPx = Offset.zero;
      _loadPhase1();
      _msgKey = _started ? 'msg_p1' : null;
    });
  }

  // ---------------------------------------------------------- gestures ---
  _Org? _hitOrg(Offset world) {
    _Org? best;
    var bestD = 1.4; // tap radius in world units
    for (final o in _orgs) {
      if (!o.visible || o.type == 'sun') continue;
      final d = (Offset(o.x, o.y) - world).distance;
      if (d < bestD) {
        bestD = d;
        best = o;
      }
    }
    return best;
  }

  void _onTapUp(TapUpDetails d) {
    if (!_started) return;
    final o = _hitOrg(_toWorld(d.localPosition));
    if (o == null) return;
    if (_step == 1 && !o.locked) {
      _rt_playSfx(_rt_Sfx.tap);
      setState(() => _selOrg = o.type);
    } else if (_step == 2) {
      _handleChainTap(o);
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    _gestureBaseZoom = _zoomF;
    _dragOrg = null;
    if (_started && _step == 1 && d.pointerCount == 1) {
      final o = _hitOrg(_toWorld(d.localFocalPoint));
      if (o != null && !o.locked) {
        _dragOrg = o;
        o.tx = null;
        o.ty = null;
        _rt_playSfx(_rt_Sfx.tap);
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final o = _dragOrg;
    if (o != null && d.pointerCount == 1) {
      final w = _toWorld(d.localFocalPoint);
      o.x = w.dx.clamp(-11.0, 11.0);
      o.y = w.dy.clamp(-4.2, 7.0);
      return;
    }
    setState(() {
      _zoomF = (_gestureBaseZoom * d.scale).clamp(0.6, 3.0);
      _panPx += d.focalPointDelta;
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final o = _dragOrg;
    _dragOrg = null;
    if (o != null) _checkPlacement(o);
  }

  // ---------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('header_title'),
            subtitle: _tx.s('header_subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.blue500,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
              headerSubtitleColor: Color(0xFF93C5FD),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('app_title'),
              subtitle: _tx.s('tagline'),
              buttonLabel: _tx.s('init_btn'),
              footnote: _tx.s('intro_foot'),
              icon: Icons.water,
              buttonIcon: Icons.eco,
            ),
            onStart: () {
              setState(() {
                _started = true;
                _msgKey = 'msg_p1';
              });
            },
            onRestart: _restart,
            onZoomIn: () =>
                setState(() => _zoomF = (_zoomF * 1.25).clamp(0.6, 3.0)),
            onZoomOut: () =>
                setState(() => _zoomF = (_zoomF / 1.25).clamp(0.6, 3.0)),
            onResetView: () => setState(() {
              _zoomF = 1;
              _panPx = Offset.zero;
            }),
            hint: _msgKey == null
                ? null
                : _rt_StepHint(
                    number: '$_step',
                    label: _tx.s('hud_ph$_step'),
                    text: _tx.s(_msgKey!),
                  ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('lab_mission'),
                icon: Icons.public,
                builder: (_) => _exploreTab(),
              ),
            ],
            canvas: _pondCanvas(),
            canvasOverlays: [
              // Mini HUD: current mission (top centre, clear of the corner buttons).
              Positioned(
                top: 12,
                left: 70,
                right: 70,
                child: IgnorePointer(child: Center(child: _missionHud())),
              ),
              // Canvas action button (the source's #canvas-actions).
              if (_canvasAction() != null)
                Positioned(
                  top: 58,
                  left: 70,
                  right: 70,
                  child: Center(child: _canvasAction()!),
                ),
              // On-screen message pill (the source's #screen-message).
              if (_msgKey != null)
                Positioned(
                  left: 60,
                  right: 60,
                  bottom: 14,
                  child: IgnorePointer(child: Center(child: _messagePill())),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _pondCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          key: const ValueKey('pond-canvas'),
          behavior: HitTestBehavior.opaque,
          onTapUp: _onTapUp,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: ClipRect(
            child: CustomPaint(size: _canvasSize, painter: _PondPainter(this)),
          ),
        );
      },
    );
  }

  Widget _missionHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: _rt_Tw.blue500, width: 4)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('hud_mission'),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: _rt_Tw.blue400,
            ),
          ),
          Text(
            _started ? _tx.s('hud_ph$_step') : '--',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messagePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _rt_Tw.blue500.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
      ),
      child: Text(
        _tx.s(_msgKey!),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: _rt_Lab.text,
        ),
      ),
    );
  }

  /// The source's per-phase #canvas-actions button.
  Widget? _canvasAction() {
    if (!_started) return null;
    return switch (_step) {
      2 => _rt_ActionButton(
        key: const ValueKey('canvas-reset-chain'),
        label: _tx.s('btn_reset_chain'),
        icon: Icons.rotate_right,
        color: _rt_Tw.slate600,
        onPressed: _chain.length == 4 ? null : _resetChain,
      ),
      3 => _rt_ActionButton(
        key: const ValueKey('canvas-fast-forward'),
        label: _tx.s('btn_fast_forward'),
        icon: Icons.fast_forward,
        color: _rt_Tw.green600,
        done: _decomposed,
        onPressed: _triggerDecomposition,
      ),
      4 => _rt_ActionButton(
        key: const ValueKey('canvas-remove-frogs'),
        label: _tx.s('btn_remove_frog'),
        icon: Icons.block,
        color: _rt_Tw.red600,
        done: _frogsRemoved,
        onPressed: _removeFrogs,
      ),
      5 => _rt_ActionButton(
        key: const ValueKey('canvas-pesticide'),
        label: _tx.s('btn_pesticide'),
        icon: Icons.science,
        color: _rt_Tw.purple600,
        done: _pesticideAdded,
        onPressed: _addPesticide,
      ),
      _ => null,
    };
  }

  // ----------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_ObjectiveCard(
            title: _tx.s('lab_mission'),
            desc: _tx.s('lab_desc'),
            accent: _rt_Tw.blue500,
            icon: Icons.public,
          ),
          const SizedBox(height: 12),
          for (var i = 1; i <= 5; i++) _stepTile(i),
          const SizedBox(height: 8),
          ..._phaseControls(),
          const SizedBox(height: 18),
          _notesFoot(),
        ],
      ),
    );
  }

  Widget _stepTile(int n) {
    final active = _step == n;
    final done = _step > n || _celebrated;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active
            ? _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? _rt_Tw.green500
              : (active ? _rt_Tw.blue500 : _rt_Lab.border),
          width: active || done ? 2 : 1,
        ),
      ),
      child: Opacity(
        opacity: active || done ? 1 : 0.55,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? _rt_Tw.green500
                    : (active ? _rt_Tw.blue500 : _rt_Lab.overlay),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '$n',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: active ? Colors.white : _rt_Lab.textMuted,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tx.s('st${n}_t'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tx.s('st${n}_d'),
                    style: TextStyle(
                      fontSize: 11,
                      color: _rt_Lab.textMuted,
                      height: 1.3,
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

  List<Widget> _phaseControls() {
    if (!_started && _step == 1) {
      // Same controls before the curtain opens; harmless.
    }
    switch (_step) {
      case 1:
        return [
          _rt_SectionLabel(
            _tx.s('organisms_lbl'),
            icon: Icons.pets,
            color: _rt_Tw.blue400,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in const ['bacteria', 'phyto', 'lotus', 'frog'])
                _orgChip(t),
            ],
          ),
          const SizedBox(height: 10),
          _rt_SectionLabel(
            _tx.s('zones_lbl'),
            icon: Icons.layers,
            color: _rt_Tw.blue400,
          ),
          Column(
            children: [
              _zoneButton('zone-surface', 'zone_surface', _rt_Tw.sky400, 3.1),
              const SizedBox(height: 6),
              _zoneButton('zone-column', 'zone_column', _rt_Tw.blue500, 0),
              const SizedBox(height: 6),
              _zoneButton('zone-mud', 'zone_mud', _rt_Tw.amber700, -3.0),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tx.s('place_hint'),
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: _rt_Lab.textMuted,
            ),
          ),
        ];
      case 2:
        return [
          _rt_SectionLabel(
            _tx.s('chain_lbl'),
            icon: Icons.link,
            color: _rt_Tw.blue400,
          ),
          Text(
            _tx.s('chain_hint'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _rt_Tw.yellow400,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in const ['algae', 'proto', 'fish_s', 'fish_l'])
                _chainChip(t),
            ],
          ),
          const SizedBox(height: 8),
          if (_fbKey != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _tx.s(_fbKey!),
                key: const ValueKey('hud-feedback'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _rt_Tw.amber400,
                ),
              ),
            ),
          _rt_ActionButton(
            key: const ValueKey('action-reset-chain'),
            label: _tx.s('btn_reset_chain'),
            icon: Icons.rotate_right,
            color: _rt_Tw.slate600,
            expand: true,
            onPressed: _chain.length == 4 ? null : _resetChain,
          ),
        ];
      case 3:
        return [
          _rt_ActionButton(
            key: const ValueKey('action-fast-forward'),
            label: _tx.s('btn_fast_forward'),
            icon: Icons.fast_forward,
            color: _rt_Tw.green600,
            expand: true,
            done: _decomposed,
            onPressed: _triggerDecomposition,
          ),
        ];
      case 4:
        return [
          _rt_ActionButton(
            key: const ValueKey('action-remove-frogs'),
            label: _tx.s('btn_remove_frog'),
            icon: Icons.block,
            color: _rt_Tw.red600,
            expand: true,
            done: _frogsRemoved,
            onPressed: _removeFrogs,
          ),
        ];
      default:
        return [
          _rt_ActionButton(
            key: const ValueKey('action-pesticide'),
            label: _tx.s('btn_pesticide'),
            icon: Icons.science,
            color: _rt_Tw.purple600,
            expand: true,
            done: _pesticideAdded,
            onPressed: _addPesticide,
          ),
        ];
    }
  }

  static const Map<String, Color> _orgColors = {
    'bacteria': _rt_Tw.lime500,
    'phyto': _rt_Tw.emerald400,
    'lotus': _rt_Tw.pink500,
    'frog': _rt_Tw.green500,
    'algae': _rt_Tw.green600,
    'proto': _rt_Tw.teal400,
    'fish_s': _rt_Tw.orange400,
    'fish_l': _rt_Tw.sky400,
    'snake': _rt_Tw.green700,
    'bird': _rt_Tw.amber600,
    'insect': _rt_Tw.slate400,
    'dead_fish': _rt_Tw.slate500,
  };

  Widget _orgChip(String type) {
    final o = _findOrg(type);
    final locked = o?.locked ?? false;
    final selected = _selOrg == type;
    final color = _orgColors[type]!;
    return GestureDetector(
      key: ValueKey('org-$type'),
      onTap: () {
        _rt_playSfx(_rt_Sfx.tap);
        if (!locked) setState(() => _selOrg = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500)
              : _rt_Lab.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: locked
                ? _rt_Tw.green500
                : (selected ? _rt_Tw.blue500 : _rt_Lab.border),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              _tx.s('lbl_$type'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
            if (locked) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                key: ValueKey('org-$type-done'),
                size: 14,
                color: _rt_Tw.green500,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _zoneButton(String key, String txKey, Color color, double y) {
    return _rt_ActionButton(
      key: ValueKey(key),
      label: _tx.s(txKey),
      icon: Icons.place,
      color: color,
      expand: true,
      onPressed: () => _placeSelectedInZone(y),
    );
  }

  Widget _chainChip(String type) {
    final inChain = _chain.contains(type);
    return _rt_ActionButton(
      key: ValueKey('chain-$type'),
      label: _tx.s('lbl_$type'),
      icon: inChain ? Icons.check : Icons.touch_app,
      color: inChain ? _rt_Tw.green600 : _rt_Tw.blue600,
      sound: null, // _handleChainTap plays correct/wrong itself
      onPressed: () {
        final o = _findOrg(type);
        if (o != null) _handleChainTap(o);
      },
    );
  }

  Widget _notesFoot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(
          _tx.s('ctx_title'),
          icon: Icons.lightbulb,
          color: _rt_Tw.blue400,
        ),
        _rt_InfoCard(
          title: _tx.s('c1_t'),
          body: _tx.s('c1_d'),
          icon: Icons.water,
          color: _rt_Tw.blue500,
        ),
        _rt_InfoCard(
          title: _tx.s('c2_t'),
          body: _tx.s('c2_d'),
          icon: Icons.pest_control,
          color: _rt_Tw.green600,
        ),
        _rt_InfoCard(
          title: _tx.s('c3_t'),
          body: _tx.s('c3_d'),
          icon: Icons.dangerous,
          color: _rt_Tw.red500,
        ),
        const SizedBox(height: 6),
        _rt_SectionLabel(
          _tx.s('guide_title'),
          icon: Icons.school,
          color: _rt_Tw.green500,
        ),
        _rt_InfoCard(body: _tx.s('g_intro'), color: _rt_Tw.slate600),
        _rt_InfoCard(body: _tx.s('g_concept'), color: _rt_Tw.blue500),
        _rt_InfoCard(body: _tx.s('g_steps'), color: _rt_Tw.slate600),
        const SizedBox(height: 6),
        _rt_SectionLabel(
          _tx.s('post_title'),
          icon: Icons.fact_check,
          color: _rt_Tw.purple500,
        ),
        _rt_InfoCard(
          title: _tx.s('res_good'),
          icon: Icons.verified,
          color: _rt_Tw.green500,
          leftBorder: true,
        ),
        _rt_InfoCard(
          tag: '1',
          title: _tx.s('res_pt1'),
          body: _tx.s('res_pd1'),
          color: _rt_Tw.blue500,
          leftBorder: true,
        ),
        _rt_InfoCard(
          tag: '2',
          title: _tx.s('res_pt2'),
          body: _tx.s('res_pd2'),
          color: _rt_Tw.blue500,
          leftBorder: true,
        ),
      ],
    );
  }
}

// ================================================================ painter ==
class _PondPainter extends CustomPainter {
  _PondPainter(this.st) : super(repaint: st._frame);

  final _Cl10SCh13A1NaturalPondPageState st;

  double get s => st._s;
  double get t => st._simT;

  Offset w2s(double x, double y) => st._toScreen(x, y);

  @override
  void paint(Canvas canvas, Size size) {
    _drawEnvironment(canvas, size);
    _drawZoneSeparators(canvas);
    _drawLinks(canvas);
    _drawOrganisms(canvas);
    _drawParticles(canvas);
    _drawZoneLabels(canvas);
  }

  // ----------------------------------------------------------- scenery ---
  void _drawEnvironment(Canvas canvas, Size size) {
    // Night-sky backdrop.
    final sky = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1120), Color(0xFF0F172A)],
        ).createShader(sky),
    );

    // Water body (x -8..8, y -3..3), translucent blue like the source's
    // transmission material.
    final wTL = w2s(-8, 3);
    final wBR = w2s(8, -3);
    final water = Rect.fromPoints(wTL, wBR);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1CA3EC).withValues(alpha: 0.55),
            const Color(0xFF0C4A6E).withValues(alpha: 0.75),
          ],
        ).createShader(water),
    );
    // Surface shimmer line.
    canvas.drawLine(
      w2s(-8, 3),
      w2s(8, 3),
      Paint()
        ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.8)
        ..strokeWidth = math.max(1.5, 0.06 * s),
    );

    // Mud bed with bumps.
    final mud = Path()
      ..moveTo(w2s(-8, -3).dx, w2s(-8, -3).dy)
      ..lineTo(w2s(8, -3).dx, w2s(8, -3).dy)
      ..lineTo(w2s(8, -4.3).dx, w2s(8, -4.3).dy)
      ..lineTo(w2s(-8, -4.3).dx, w2s(-8, -4.3).dy)
      ..close();
    canvas.drawPath(mud, Paint()..color = const Color(0xFF261410));
    final bump = Paint()..color = const Color(0xFF3A2018);
    for (var x = -7.0; x <= 7; x += 2) {
      canvas.drawOval(
        Rect.fromCenter(center: w2s(x, -3.05), width: 1.6 * s, height: 0.5 * s),
        bump,
      );
    }

    // Banks (brown wedges) + rocks.
    final bankPaint = Paint()..color = const Color(0xFF3E2723);
    final left = Path()
      ..moveTo(w2s(-12, 4.6).dx, w2s(-12, 4.6).dy)
      ..lineTo(w2s(-8.4, 3.2).dx, w2s(-8.4, 3.2).dy)
      ..lineTo(w2s(-7.7, -4.3).dx, w2s(-7.7, -4.3).dy)
      ..lineTo(w2s(-12, -4.3).dx, w2s(-12, -4.3).dy)
      ..close();
    final right = Path()
      ..moveTo(w2s(12, 4.6).dx, w2s(12, 4.6).dy)
      ..lineTo(w2s(8.4, 3.2).dx, w2s(8.4, 3.2).dy)
      ..lineTo(w2s(7.7, -4.3).dx, w2s(7.7, -4.3).dy)
      ..lineTo(w2s(12, -4.3).dx, w2s(12, -4.3).dy)
      ..close();
    canvas.drawPath(left, bankPaint);
    canvas.drawPath(right, bankPaint);
    final rockPaint = Paint()..color = const Color(0xFF607D8B);
    for (final (x, y, r) in st._rocks) {
      canvas.drawCircle(w2s(x, y), r * s * 0.5, rockPaint);
    }

    // Drifting plankton motes (the source's 200-point cloud).
    final mote = Paint()
      ..color = const Color(0xFF88CCAA).withValues(alpha: 0.5);
    for (var i = 0; i < st._plankton.length; i++) {
      final (bx, by) = st._plankton[i];
      final x = bx + math.sin(t * 0.7 + by * 2 + i) * 0.25;
      final y = by + math.cos(t * 0.6 + bx + i) * 0.2;
      canvas.drawCircle(w2s(x, y), math.max(1, 0.045 * s), mote);
    }
  }

  void _drawZoneSeparators(Canvas canvas) {
    if (st._step != 1) return;
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (final y in const [2.25, -2.25]) {
      for (var x = -8.0; x < 8; x += 0.7) {
        canvas.drawLine(w2s(x, y), w2s(x + 0.35, y), p);
      }
    }
  }

  void _drawZoneLabels(Canvas canvas) {
    const zones = [
      ('zone_surface', 3.5, Color(0xFF38BDF8)),
      ('zone_column', 0.0, Color(0xFF60A5FA)),
      ('zone_mud', -3.5, Color(0xFFA16207)),
    ];
    // Drawn over the left bank; the source's right-edge sprites would sit
    // under the shell's vertical toolbar here.
    for (final (key, y, color) in zones) {
      _pill(canvas, _tx.s(key), w2s(-9.3, y), color);
    }
  }

  void _pill(Canvas canvas, String text, Offset c, Color border) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: math.max(9, 0.42 * s),
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: tp.width + 14, height: tp.height + 8),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xE60F172A));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  // ------------------------------------------------------------- links ---
  void _drawLinks(Canvas canvas) {
    for (final l in st._links) {
      var alpha = 1.0;
      if (l.fades && l.age > 1) {
        alpha = (1 - (l.age - 1) / 2 * 0.8).clamp(0.2, 1.0);
      }
      canvas.drawLine(
        w2s(l.ax, l.ay),
        w2s(l.bx, l.by),
        Paint()
          ..color = l.color.withValues(alpha: alpha)
          ..strokeWidth = math.max(2, 0.08 * s),
      );
    }
  }

  // --------------------------------------------------------- particles ---
  void _drawParticles(Canvas canvas) {
    for (final p in st._particles) {
      if (p.delay > 0) continue;
      switch (p.kind) {
        case 'energy':
          canvas.drawCircle(
            w2s(p.x, p.y),
            0.16 * s,
            Paint()..color = p.color ?? _rt_Tw.yellow400,
          );
        case 'bubble':
          canvas.drawCircle(
            w2s(p.x, p.y),
            0.13 * s,
            Paint()..color = Colors.white.withValues(alpha: 0.6),
          );
        case 'toxic':
          canvas.drawCircle(
            w2s(p.x, p.y),
            0.14 * s,
            Paint()..color = _rt_Tw.lime500,
          );
        case 'insect':
          canvas.save();
          canvas.translate(w2s(p.x, p.y).dx, w2s(p.x, p.y).dy);
          canvas.scale(p.scale * 0.7);
          _glyphInsect(canvas);
          canvas.restore();
      }
    }
  }

  // --------------------------------------------------------- organisms ---
  void _drawOrganisms(Canvas canvas) {
    for (var i = 0; i < st._orgs.length; i++) {
      final o = st._orgs[i];
      if (!o.visible) continue;

      // Idle bobbing: skip unlocked phase-1 draggables (source rule).
      var bob = 0.0;
      if (!(st._step == 1 && !o.locked) &&
          o.type != 'sun' &&
          o.type != 'fish_s' &&
          o.type != 'fish_l') {
        bob = math.sin(t + i) * 0.06;
      }
      final shakeX = o.shake > 0 ? math.sin(o.shake * 25) * 0.15 : 0.0;
      final c = w2s(o.x + shakeX, o.y + bob);
      final pulseK = 1 + math.sin(o.pulse * math.pi) * 0.5;
      var k = o.scale * pulseK;
      if (o.type == 'bacteria') k *= 1 + 0.1 * math.sin(t * 3 + i);

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(s / 30 * k); // glyphs are drawn on a ~60px design grid
      if (o.facingLeft && (o.type == 'fish_s' || o.type == 'fish_l')) {
        canvas.scale(-1, 1);
      }
      _drawGlyph(canvas, o.type, i);
      canvas.restore();

      // Selection ring for the phase-1 pick.
      if (st._selOrg == o.type && !o.locked) {
        canvas.drawCircle(
          c,
          1.1 * s,
          Paint()
            ..color = _rt_Tw.blue400
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Name label below (the source's label sprite). The sun has none.
      if (o.type != 'sun' && o.scale > 0.35) {
        _pill(
          canvas,
          _tx.s('lbl_${o.type}') + o.suffix,
          w2s(o.x + shakeX, o.y + bob - 1.25),
          o.suffix.isNotEmpty ? _rt_Tw.lime500 : Colors.white24,
        );
      }
    }
  }

  void _drawGlyph(Canvas canvas, String type, int seed) {
    switch (type) {
      case 'sun':
        _glyphSun(canvas);
      case 'algae':
        _glyphAlgae(canvas);
      case 'phyto':
        _glyphPhyto(canvas);
      case 'lotus':
        _glyphLotus(canvas);
      case 'bacteria':
        _glyphBacteria(canvas);
      case 'proto':
        _glyphProto(canvas);
      case 'fish_s':
        _glyphFish(canvas, 0.8, _rt_Tw.orange400, _rt_Tw.orange600);
      case 'fish_l':
        _glyphFish(canvas, 1.15, _rt_Tw.sky400, _rt_Tw.blue600);
      case 'dead_fish':
        _glyphDeadFish(canvas);
      case 'frog':
        _glyphFrog(canvas);
      case 'insect':
        _glyphInsect(canvas);
      case 'snake':
        _glyphSnake(canvas);
      case 'bird':
        _glyphBird(canvas);
    }
  }

  // Glyphs are drawn in a local space where 30 units = 1 world unit.
  void _glyphSun(Canvas c) {
    final ray = Paint()
      ..color = _rt_Tw.amber400
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + t * 0.12;
      c.drawLine(
        Offset(math.cos(a) * 40, math.sin(a) * 40),
        Offset(math.cos(a) * 56, math.sin(a) * 56),
        ray,
      );
    }
    c.drawCircle(
      Offset.zero,
      36,
      Paint()..color = _rt_Tw.amber400.withValues(alpha: 0.35),
    );
    c.drawCircle(Offset.zero, 30, Paint()..color = _rt_Tw.yellow400);
  }

  void _glyphAlgae(Canvas c) {
    final p = Paint()
      ..color = _rt_Tw.green500
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final dx in const [-14.0, 0.0, 14.0]) {
      final path = Path()
        ..moveTo(dx, 22)
        ..quadraticBezierTo(dx - 10, 0, dx, -10)
        ..quadraticBezierTo(dx + 10, -20, dx, -26);
      c.drawPath(path, p);
    }
    c.drawOval(
      Rect.fromCenter(center: const Offset(0, 24), width: 44, height: 10),
      Paint()..color = _rt_Tw.green700,
    );
  }

  void _glyphPhyto(Canvas c) {
    final dot = Paint()..color = _rt_Tw.emerald400;
    const pts = [
      Offset(0, -16),
      Offset(-14, -2),
      Offset(14, -4),
      Offset(-6, 12),
      Offset(10, 12),
      Offset(0, 0),
    ];
    for (final p in pts) {
      c.drawCircle(p, 7, dot);
      c.drawCircle(p, 3, Paint()..color = _rt_Tw.emerald600);
    }
  }

  void _glyphLotus(Canvas c) {
    // Stem down toward the mud (drawn first, behind the flower).
    c.drawLine(
      const Offset(0, 16),
      const Offset(0, 150),
      Paint()
        ..color = _rt_Tw.green500
        ..strokeWidth = 3,
    );
    // Lily pad.
    c.drawOval(
      Rect.fromCenter(center: const Offset(6, 16), width: 60, height: 16),
      Paint()..color = _rt_Tw.green600,
    );
    // Petals.
    final petal = Paint()..color = _rt_Tw.pink500;
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + (i - 2) * 0.55;
      c.save();
      c.translate(math.cos(a) * 10, math.sin(a) * 10);
      c.rotate(a + math.pi / 2);
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 16, height: 30),
        petal,
      );
      c.restore();
    }
    c.drawCircle(const Offset(0, -6), 6, Paint()..color = _rt_Tw.amber400);
  }

  void _glyphBacteria(Canvas c) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 46, height: 24),
      const Radius.circular(12),
    );
    c.drawRRect(body, Paint()..color = _rt_Tw.lime500);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(-4, -2), width: 28, height: 12),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFA3E635).withValues(alpha: 0.8),
    );
    final flag = Paint()
      ..color = _rt_Tw.lime500
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    c.drawPath(
      Path()
        ..moveTo(23, 0)
        ..quadraticBezierTo(34, -8, 40, 2)
        ..quadraticBezierTo(45, 8, 52, 4),
      flag,
    );
    c.drawPath(
      Path()
        ..moveTo(-23, 4)
        ..quadraticBezierTo(-32, 10, -40, 4),
      flag,
    );
  }

  void _glyphProto(Canvas c) {
    final blob = Path()
      ..moveTo(-24, 0)
      ..quadraticBezierTo(-20, -20, 0, -18)
      ..quadraticBezierTo(24, -16, 22, 2)
      ..quadraticBezierTo(20, 18, -2, 16)
      ..quadraticBezierTo(-24, 16, -24, 0)
      ..close();
    c.drawPath(blob, Paint()..color = _rt_Tw.teal400.withValues(alpha: 0.85));
    c.drawCircle(const Offset(4, -2), 7, Paint()..color = _rt_Tw.teal700);
    final cil = Paint()
      ..color = _rt_Tw.teal200
      ..strokeWidth = 2;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * 2 * math.pi;
      final r0 = Offset(math.cos(a) * 23, math.sin(a) * 17);
      final r1 = Offset(math.cos(a) * 29, math.sin(a) * 21);
      c.drawLine(r0, r1, cil);
    }
  }

  void _glyphFish(Canvas c, double k, Color body, Color fin) {
    c.save();
    c.scale(k);
    // Tail.
    final tail = Path()
      ..moveTo(20, 0)
      ..lineTo(36, -12)
      ..lineTo(36, 12)
      ..close();
    c.drawPath(tail, Paint()..color = fin);
    // Body.
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 48, height: 24),
      Paint()..color = body,
    );
    // Dorsal fin.
    c.drawPath(
      Path()
        ..moveTo(-4, -10)
        ..lineTo(6, -20)
        ..lineTo(12, -9)
        ..close(),
      Paint()..color = fin,
    );
    // Eye.
    c.drawCircle(const Offset(-14, -3), 4, Paint()..color = Colors.white);
    c.drawCircle(const Offset(-14, -3), 2, Paint()..color = Colors.black);
    c.restore();
  }

  void _glyphDeadFish(Canvas c) {
    c.save();
    c.rotate(math.pi); // belly-up
    final grey = _rt_Tw.slate400;
    final tail = Path()
      ..moveTo(20, 0)
      ..lineTo(36, -12)
      ..lineTo(36, 12)
      ..close();
    c.drawPath(tail, Paint()..color = _rt_Tw.slate500);
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 48, height: 24),
      Paint()..color = grey,
    );
    c.restore();
    // X eye (drawn unrotated so it reads clearly).
    final x = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5;
    c.drawLine(const Offset(10, -1), const Offset(18, 7), x);
    c.drawLine(const Offset(18, -1), const Offset(10, 7), x);
  }

  void _glyphFrog(Canvas c) {
    // Body.
    c.drawOval(
      Rect.fromCenter(center: const Offset(0, 6), width: 46, height: 30),
      Paint()..color = _rt_Tw.green500,
    );
    c.drawOval(
      Rect.fromCenter(center: const Offset(0, 10), width: 30, height: 16),
      Paint()..color = const Color(0xFFBBF7D0),
    );
    // Eyes.
    for (final dx in const [-12.0, 12.0]) {
      c.drawCircle(Offset(dx, -10), 9, Paint()..color = _rt_Tw.green600);
      c.drawCircle(Offset(dx, -11), 5, Paint()..color = Colors.white);
      c.drawCircle(Offset(dx, -11), 2.5, Paint()..color = Colors.black);
    }
    // Legs.
    final leg = Paint()..color = _rt_Tw.green600;
    c.drawOval(
      Rect.fromCenter(center: const Offset(-20, 16), width: 16, height: 10),
      leg,
    );
    c.drawOval(
      Rect.fromCenter(center: const Offset(20, 16), width: 16, height: 10),
      leg,
    );
  }

  void _glyphInsect(Canvas c) {
    final wing = Paint()..color = Colors.white.withValues(alpha: 0.5);
    c.drawOval(
      Rect.fromCenter(center: const Offset(-8, -8), width: 20, height: 9),
      wing,
    );
    c.drawOval(
      Rect.fromCenter(center: const Offset(8, -8), width: 20, height: 9),
      wing,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 8, height: 20),
      Paint()..color = _rt_Tw.slate700,
    );
    c.drawCircle(const Offset(0, -12), 4, Paint()..color = _rt_Tw.slate800);
    final leg = Paint()
      ..color = _rt_Tw.slate500
      ..strokeWidth = 1.5;
    for (final dx in const [-1.0, 1.0]) {
      c.drawLine(Offset(dx * 3, 2), Offset(dx * 12, 10), leg);
      c.drawLine(Offset(dx * 3, 6), Offset(dx * 12, 16), leg);
    }
  }

  void _glyphSnake(Canvas c) {
    final body = Paint()
      ..color = _rt_Tw.green700
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(-28, 10);
    for (var i = 0; i <= 20; i++) {
      final x = -28 + i * 2.6;
      path.lineTo(x, 10 * math.sin(i / 20 * 2.5 * math.pi) * 0.8);
    }
    c.drawPath(path, body);
    // Head + tongue + eye.
    c.drawCircle(const Offset(26, -6), 8, Paint()..color = _rt_Tw.green600);
    c.drawLine(
      const Offset(33, -6),
      const Offset(41, -6),
      Paint()
        ..color = _rt_Tw.red500
        ..strokeWidth = 2,
    );
    c.drawCircle(const Offset(26, -9), 2, Paint()..color = Colors.black);
  }

  void _glyphBird(Canvas c) {
    // Spread wings.
    final wing = Paint()..color = const Color(0xFF92400E);
    c.drawPath(
      Path()
        ..moveTo(-6, -2)
        ..quadraticBezierTo(-30, -24, -46, -12)
        ..quadraticBezierTo(-30, -6, -8, 6)
        ..close(),
      wing,
    );
    c.drawPath(
      Path()
        ..moveTo(6, -2)
        ..quadraticBezierTo(30, -24, 46, -12)
        ..quadraticBezierTo(30, -6, 8, 6)
        ..close(),
      wing,
    );
    // Body + head.
    c.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 22, height: 30),
      Paint()..color = const Color(0xFF78350F),
    );
    c.drawCircle(const Offset(0, -12), 8, Paint()..color = Colors.white);
    c.drawCircle(const Offset(-2, -13), 2, Paint()..color = Colors.black);
    // Beak.
    c.drawPath(
      Path()
        ..moveTo(-8, -12)
        ..lineTo(-15, -9)
        ..lineTo(-8, -7)
        ..close(),
      Paint()..color = _rt_Tw.amber500,
    );
  }

  @override
  bool shouldRepaint(covariant _PondPainter old) => true;
}
