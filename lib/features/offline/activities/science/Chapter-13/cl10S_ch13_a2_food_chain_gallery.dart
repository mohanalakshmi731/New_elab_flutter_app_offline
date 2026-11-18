// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 13.2: Food Chain Gallery
// Converted from Cl10S-Ch13-A2-Food_Chain_Gallery.html (three.js emoji-card
// tokens -> 2D widget canvas in a ZoomableCanvas; the source scene is flat
// cards on a gallery floor, so no mini3d is needed).
//
// Four missions run in sequence on the gallery floor: (1) Chain Builder --
// tap Sun -> Grass -> Deer -> Lion in energy-flow order (tapping the lion too
// early raises the source's "carnivores don't eat plants" error); (2) Energy
// Calculator -- type the energy at each trophic level from 1,000,000 J of
// sunlight (1% solar capture, then the 10% law); (3) Pyramid Architect --
// press the four trophic-group buttons in base-to-top order to fill the glass
// pyramid; (4) Toxin Tracker -- tap the organism with the highest DDT
// concentration (the eagle). Finishing awards the Eco-Expert badge and the
// analysis/outcomes notes, exactly as the source's celebration + post tab.

// --- TRANSLATION DATA (source I18N block; te ignored) ---

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
  static const sky400 = Color(0xFF38BDF8);
  static const indigo600 = Color(0xFF4F46E5);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green700 = Color(0xFF15803D);
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
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
    this.color = _rt_Tw.teal600,
    this.icon,
    this.child,
  });

  final String? title;
  final String? body;
  final String? hint = null;
  final String? tag = null;
  final Color color;
  final IconData? icon;
  final Widget? child;
  final bool leftBorder = false;

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
  final List<Widget> canvasOverlays = const [];

  final VoidCallback onRestart;
  final _rt_ShellController? controller;
  final _rt_ShellTheme theme;
  final _rt_IntroConfig? intro;
  final VoidCallback? onStart = null;

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
    'app_title': 'FOOD CHAIN GALLERY',
    'tagline': 'Class 10 • Our Environment',
    'init_btn': 'START LAB',
    'header_title': 'Food Chain Gallery',
    'header_subtitle': 'Class 10 • Our Environment',
    'ctx_title': 'Why Learn This?',
    'guide_title': "Teacher's Guide",
    'post_title': 'Analysis & Outcomes',
    'btn_restart': 'Restart Activity',
    'hud_mission': 'Current Mission',
    'lab_mission': 'Mission: Build the Chain',
    'lab_desc': 'Construct the trophic pyramid and observe energy loss.',
    'c1_t': 'Ecosystem Balance',
    'c1_d':
        'If top predators disappear, herbivores overpopulate and destroy forests.',
    'c2_t': 'Agriculture & Pests',
    'c2_d':
        'Understanding food chains helps farmers control pests using natural predators.',
    'c3_t': 'Biomagnification',
    'c3_d':
        'Toxins increase in concentration as they move up the food chain, affecting humans.',
    'g_intro':
        'This activity simulates the construction of food chains, energy transfer calculations, and biomagnification tracking.',
    'g_concept_title': 'Core Concepts',
    'g_concept': [
      'Unidirectional Flow: Sun → Plants → Herbivores → Carnivores.',
      '10% Law: Only 10% of energy transfers to the next level.',
      'Solar Capture: Plants capture 1% of solar energy.',
    ],
    'g_steps': [
      'Chain Builder: Construct a valid food chain (Sun → Grass → Deer → Lion).',
      'Energy Calculator: Calculate energy loss (1% Solar, 10% Trophic).',
      'Pyramid Architect: Stack trophic levels.',
      'Toxin Tracker: Identify max toxin concentration.',
    ],
    'p1_title': 'Phase 1: Chain Builder',
    'p1_desc':
        'Construct a Forest Food Chain. Click items in the correct order of Energy Flow.',
    'p1_err':
        "Incorrect! Remember: Food -> Eater. Carnivores don't eat plants.",
    'p2_title': 'Phase 2: Energy Calculator',
    'p2_desc':
        'Calculate the energy at each level starting from 1,000,000 J of Sunlight.',
    'p2_q1': 'Sun (1,000,000 J) -> Plants (1% Capture):',
    'p2_q2': 'Plants -> Deer (10% Transfer):',
    'p2_q3': 'Deer -> Lion (10% Transfer):',
    'p2_btn': 'Check Calculations',
    'p3_title': 'Phase 3: Pyramid Architect',
    'p3_desc':
        'Build the Ecological Pyramid. Place groups in the correct tier.',
    'p3_b1': 'Producers (Base)',
    'p3_b2': 'Herbivores',
    'p3_b3': 'Small Carnivores',
    'p3_b4': 'Top Carnivores',
    'p4_title': 'Phase 4: Toxin Tracker',
    'p4_desc':
        'Pesticides (DDT) have entered the water. Click the organism with the HIGHEST concentration.',
    'p4_success':
        'Correct! Biological Magnification causes toxins to accumulate at the top.',
    'res_good': 'Eco-Expert Badge Earned!',
    'res_title': 'ECO-EXPERT',
    'res_sub': 'Trophic Master Badge Awarded',
    'pt1': 'Energy Loss',
    'pd1':
        'Only 10% of energy reaches the next level. Food chains are short (3-4 steps) because energy runs out.',
    'pt2': 'Biomagnification',
    'pd2': 'Non-biodegradable toxins accumulate maximally in top consumers.',
    // Extra strings (not in the source, needed for the native UI).
    'names': {
      'sun': 'Sun',
      'grass': 'Grass',
      'deer': 'Deer',
      'lion': 'Lion',
      'water': 'Water',
      's_fish': 'Small Fish',
      'l_fish': 'Large Fish',
      'bird': 'Eagle',
    },
    'joule': 'J',
    'ppm': 'ppm',
    'tapHint': 'Tap the cards on the gallery floor.',
    'chainDone': 'Food chain complete! Energy flows one way.',
    'pyramidDone': 'Pyramid complete! Producers form the broad base.',
    'lockedUntil': 'Complete the previous phase first.',
    'intro_foot': 'Chains • Energy • Pyramid • Toxins',
  },
  'hi': {
    'app_title': 'खाद्य श्रृंखला गैलरी',
    'tagline': 'कक्षा 10 • हमारा पर्यावरण',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'खाद्य श्रृंखला गैलरी',
    'header_subtitle': 'कक्षा 10 • हमारा पर्यावरण',
    'ctx_title': 'क्यों सीखें?',
    'guide_title': 'शिक्षक गाइड',
    'post_title': 'विश्लेषण और परिणाम',
    'btn_restart': 'पुनः आरंभ करें',
    'hud_mission': 'वर्तमान मिशन',
    'lab_mission': 'मिशन: श्रृंखला बनाएं',
    'lab_desc': 'पोषी पिरामिड का निर्माण करें और ऊर्जा हानि देखें।',
    'c1_t': 'पारिस्थितिकी तंत्र संतुलन',
    'c1_d':
        'यदि शीर्ष शिकारी गायब हो जाते हैं, तो शाकाहारी बढ़ जाएंगे और जंगलों को नष्ट कर देंगे।',
    'c2_t': 'कृषि और कीट',
    'c2_d':
        'खाद्य श्रृंखला को समझने से किसानों को प्राकृतिक शिकारियों का उपयोग करके कीटों को नियंत्रित करने में मदद मिलती है।',
    'c3_t': 'जैव आवर्धन (Biomagnification)',
    'c3_d':
        'खाद्य श्रृंखला में ऊपर जाने पर विषाक्त पदार्थों की सांद्रता बढ़ जाती है, जो मनुष्यों को प्रभावित करती है।',
    'g_intro':
        'यह गतिविधि खाद्य श्रृंखला निर्माण, ऊर्जा हस्तांतरण गणना और जैव आवर्धन ट्रैकिंग का अनुकरण करती है।',
    'g_concept_title': 'मुख्य अवधारणाएँ',
    'g_concept': [
      'एकदिशीय प्रवाह: सूर्य → पौधे → शाकाहारी → मांसाहारी।',
      '10% नियम: केवल 10% ऊर्जा अगले स्तर पर स्थानांतरित होती है।',
      'सौर ग्रहण: पौधे सौर ऊर्जा का 1% ग्रहण करते हैं।',
    ],
    'g_steps': [
      'श्रृंखला निर्माता: एक मान्य खाद्य श्रृंखला (सूर्य → घास → हिरण → शेर) बनाएं।',
      'ऊर्जा कैलकुलेटर: ऊर्जा हानि (1% सौर, 10% पोषी) की गणना करें।',
      'पिरामिड वास्तुकार: पोषी स्तरों को ढेर करें।',
      'विषाक्तता ट्रैकर: अधिकतम विषाक्तता सांद्रता की पहचान करें।',
    ],
    'p1_title': 'चरण 1: श्रृंखला निर्माता',
    'p1_desc':
        'एक वन खाद्य श्रृंखला का निर्माण करें। ऊर्जा प्रवाह के सही क्रम में वस्तुओं पर क्लिक करें।',
    'p1_err': 'गलत! याद रखें: भोजन -> खाने वाला। मांसाहारी पौधे नहीं खाते हैं।',
    'p2_title': 'चरण 2: ऊर्जा कैलकुलेटर',
    'p2_desc':
        '1,000,000 J सूर्य के प्रकाश से शुरू करके प्रत्येक स्तर पर ऊर्जा की गणना करें।',
    'p2_q1': 'सूर्य (1,000,000 J) -> पौधे (1% ग्रहण):',
    'p2_q2': 'पौधे -> हिरण (10% स्थानांतरण):',
    'p2_q3': 'हिरण -> शेर (10% स्थानांतरण):',
    'p2_btn': 'गणना जांचें',
    'p3_title': 'चरण 3: पिरामिड वास्तुकार',
    'p3_desc':
        'पारिस्थितिक पिरामिड का निर्माण करें। समूहों को सही स्तर में रखें।',
    'p3_b1': 'उत्पादक (आधार)',
    'p3_b2': 'शाकाहारी',
    'p3_b3': 'छोटे मांसाहारी',
    'p3_b4': 'शीर्ष मांसाहारी',
    'p4_title': 'चरण 4: विषाक्तता ट्रैकर',
    'p4_desc':
        'कीटनाशक (DDT) पानी में प्रवेश कर चुके हैं। उच्चतम सांद्रता वाले जीव पर क्लिक करें।',
    'p4_success':
        'सही! जैव आवर्धन के कारण विषाक्त पदार्थ शीर्ष पर जमा हो जाते हैं।',
    'res_good': 'इको-एक्सपर्ट बैज अर्जित!',
    'res_title': 'इको-एक्सपर्ट',
    'res_sub': 'पोषी स्तर मास्टर बैज प्रदान किया गया',
    'pt1': 'ऊर्जा हानि',
    'pd1':
        'केवल 10% ऊर्जा अगले स्तर तक पहुँचती है। खाद्य श्रृंखलाएँ छोटी (3-4 चरण) होती हैं क्योंकि ऊर्जा समाप्त हो जाती है।',
    'pt2': 'जैव आवर्धन',
    'pd2':
        'अजैव निम्नीकरणीय विषाक्त पदार्थ शीर्ष उपभोक्ताओं में अधिकतम जमा होते हैं।',
    'names': {
      'sun': 'सूर्य',
      'grass': 'घास',
      'deer': 'हिरण',
      'lion': 'शेर',
      'water': 'जल',
      's_fish': 'छोटी मछली',
      'l_fish': 'बड़ी मछली',
      'bird': 'बाज़',
    },
    'joule': 'J',
    'ppm': 'ppm',
    'tapHint': 'गैलरी फर्श पर कार्डों को टैप करें।',
    'chainDone': 'खाद्य श्रृंखला पूरी! ऊर्जा एक ही दिशा में बहती है।',
    'pyramidDone': 'पिरामिड पूरा! उत्पादक चौड़ा आधार बनाते हैं।',
    'lockedUntil': 'पहले पिछला चरण पूरा करें।',
    'intro_foot': 'श्रृंखला • ऊर्जा • पिरामिड • विषाक्तता',
  },
});

// Design-space geometry (the FittedBox scales it to the visible canvas).
const double _designW = 720;
const double _designH = 348;
const double _tokenSize = 104;
const List<double> _slotX = [40, 216, 392, 568];

class _Organism {
  const _Organism(this.id, this.emoji, {this.ppm = 0});
  final String id;
  final String emoji;
  final double
  ppm; // phase-4 red-tint factor (the source's `ppm` key), not a concentration
}

const _p1Items = [
  _Organism('sun', '☀️'),
  _Organism('grass', '🌿'),
  _Organism('deer', '🦌'),
  _Organism('lion', '🦁'),
];

const _p4Items = [
  _Organism('water', '💧', ppm: 0.1),
  _Organism('s_fish', '🐟', ppm: 0.3),
  _Organism('l_fish', '🐠', ppm: 0.6),
  _Organism('bird', '🦅', ppm: 1.0),
];

/// DDT data shown after the correct pick: only the Runbook's values (water
/// R:L9096, bird R:L9104). The fish have none in the Runbook or the source,
/// so they get no caption (QA C10-13.2-02).
const Map<String, String> _runbookPpm = {'water': '0.01', 'bird': '1000'};

/// Fixed "random" scatter for phase 1 (the source randomises every run).
const Map<String, Offset> _scatter = {
  'sun': Offset(296, 12),
  'grass': Offset(70, 108),
  'deer': Offset(500, 44),
  'lion': Offset(210, 186),
};

// Phase-3 pyramid tiers (bottom -> top), matching the source colours.
const _tierColors = [
  Color(0xFF22C55E),
  Color(0xFFFACC15),
  Color(0xFFF97316),
  Color(0xFFEF4444),
];
const _tierTypes = ['prod', 'herb', 'scarn', 'tcarn'];
// Sidebar button order is deliberately jumbled, exactly as the source lists them.
const _tierButtonOrder = ['tcarn', 'herb', 'prod', 'scarn'];
const _tierLabelKeys = {
  'prod': 'p3_b1',
  'herb': 'p3_b2',
  'scarn': 'p3_b3',
  'tcarn': 'p3_b4',
};
const _tierColorOf = {
  'prod': Color(0xFF22C55E),
  'herb': Color(0xFFFACC15),
  'scarn': Color(0xFFF97316),
  'tcarn': Color(0xFFEF4444),
};

class Cl10SCh13A2FoodChainGalleryPage extends StatefulWidget {
  const Cl10SCh13A2FoodChainGalleryPage({super.key});

  @override
  State<Cl10SCh13A2FoodChainGalleryPage> createState() =>
      _Cl10SCh13A2FoodChainGalleryPageState();
}

class _Cl10SCh13A2FoodChainGalleryPageState
    extends State<Cl10SCh13A2FoodChainGalleryPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController();

  int _phase = 1;
  bool _transitioning = false;
  bool _completed = false;
  Timer? _timer;

  // Phase 1: chain builder.
  final List<String> _p1Seq = [];
  static const _p1Target = ['sun', 'grass', 'deer', 'lion'];
  String? _p1Error;
  Timer? _p1ErrTimer;

  // Phase 2: energy calculator.
  final List<TextEditingController> _p2Ctl = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<bool?> _p2Ok = [null, null, null];
  static const _p2Answers = [10000, 1000, 100];
  static const _p2Values = ['10,000', '1,000', '100'];

  // Phase 3: pyramid architect.
  int _p3Progress = 0;
  final Set<String> _p3Used = {};

  // Phase 4: toxin tracker.
  bool _p4Done = false;
  String? _p4Feedback;

  // Shared clocks: idle bob for tokens, shake on a wrong pick.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  String? _shaking;

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
    _p1ErrTimer?.cancel();
    for (final c in _p2Ctl) {
      c.dispose();
    }
    _zoom.dispose();
    _float.dispose();
    _shake.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic ---

  void _restart() {
    _timer?.cancel();
    _p1ErrTimer?.cancel();
    setState(() {
      _phase = 1;
      _transitioning = false;
      _completed = false;
      _p1Seq.clear();
      _p1Error = null;
      for (final c in _p2Ctl) {
        c.clear();
      }
      for (var i = 0; i < 3; i++) {
        _p2Ok[i] = null;
      }
      _p3Progress = 0;
      _p3Used.clear();
      _p4Done = false;
      _p4Feedback = null;
      _shaking = null;
    });
    _zoom.reset();
  }

  void _setPhase(int n) {
    if (!mounted) return;
    setState(() {
      _phase = n;
      _transitioning = false;
    });
    _rt_playSfx(_rt_Sfx.scenario); // stage change (source re-renders the scene)
  }

  void _shakeToken(String id) {
    setState(() => _shaking = id);
    _shake.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _shaking = null);
    });
  }

  void _handleP1Tap(String id) {
    if (_phase != 1 || _transitioning || _p1Seq.contains(id)) return;
    final currentStep = _p1Seq.length;
    final expected = _p1Target[currentStep];

    // Source special case: the lion cannot eat plants / absorb sunlight.
    if (id == 'lion' && (expected == 'sun' || expected == 'grass')) {
      _rt_playSfx(_rt_Sfx.wrong); // sfx.play('error')
      _showP1Error();
      return;
    }

    if (id == expected) {
      _rt_playSfx(_rt_Sfx.pop); // sfx.play('click') on placing a card
      setState(() => _p1Seq.add(id));
      if (_p1Seq.length == 4) {
        _rt_playSfx(_rt_Sfx.success); // sfx.play('success') on chain complete
        _shell.showToast(
          _tx.s('chainDone'),
          color: _rt_Tw.green500,
          icon: Icons.link,
        );
        _transitioning = true;
        _timer = Timer(const Duration(milliseconds: 1800), () => _setPhase(2));
      }
    } else {
      _rt_playSfx(_rt_Sfx.wrong); // sfx.play('error') + shake
      _shakeToken(id);
    }
  }

  void _showP1Error() {
    _p1ErrTimer?.cancel();
    setState(() => _p1Error = _tx.s('p1_err'));
    _shell.showToast(_tx.s('p1_err'), color: _rt_Tw.red500, icon: Icons.block);
    _p1ErrTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _p1Error = null);
    });
  }

  void _checkPhase2() {
    if (_phase != 2 || _transitioning) return;
    var correct = true;
    setState(() {
      for (var i = 0; i < 3; i++) {
        final v = int.tryParse(_p2Ctl[i].text.replaceAll(',', '').trim());
        _p2Ok[i] = v == _p2Answers[i];
        if (_p2Ok[i] != true) correct = false;
      }
    });
    if (correct) {
      _rt_playSfx(_rt_Sfx.success); // sfx.play('success') on all three right
      _transitioning = true;
      _timer = Timer(const Duration(milliseconds: 1500), () => _setPhase(3));
    } else {
      _rt_playSfx(_rt_Sfx.wrong); // sfx.play('error')
    }
  }

  void _handleP3Tap(String type) {
    if (_phase != 3 || _transitioning || _p3Used.contains(type)) return;
    if (type == _tierTypes[_p3Progress]) {
      _rt_playSfx(
        _rt_Sfx.pop,
      ); // sfx.play('click') + light burst on filling a tier
      setState(() {
        _p3Used.add(type);
        _p3Progress++;
      });
      if (_p3Progress == 4) {
        _rt_playSfx(_rt_Sfx.success); // sfx.play('success') on pyramid complete
        _shell.showToast(
          _tx.s('pyramidDone'),
          color: _rt_Tw.green500,
          icon: Icons.change_history,
        );
        _transitioning = true;
        _timer = Timer(const Duration(milliseconds: 1500), () => _setPhase(4));
      }
    } else {
      _rt_playSfx(_rt_Sfx.wrong); // sfx.play('error')
    }
  }

  void _handleP4Tap(String id) {
    if (_phase != 4 || _p4Done || _transitioning) return;
    if (id == 'bird') {
      _rt_playSfx(_rt_Sfx.correct); // right pick (celebration success follows)
      setState(() {
        _p4Done = true;
        _p4Feedback = _tx.s('p4_success');
      });
      _transitioning = true;
      _timer = Timer(const Duration(milliseconds: 1600), _finish);
    } else {
      _rt_playSfx(_rt_Sfx.wrong); // sfx.play('error') + shake
      _shakeToken(id);
    }
  }

  Future<void> _finish() async {
    if (!mounted) return;
    setState(() {
      _completed = true;
      _transitioning = false;
    });
    // The source's celebration overlay (medal + ECO-EXPERT) then the post tab.
    await _shell.showSuccess(
      title: _tx.s('res_title'),
      message: _tx.s('res_sub'),
      icon: Icons.military_tech,
      color: _rt_Tw.amber400,
      body: Column(
        children: [
          _rt_InfoCard(
            title: _tx.s('res_good'),
            color: _rt_Tw.green500,
            icon: Icons.verified,
          ),
          _rt_InfoCard(
            title: _tx.s('pt1'),
            body: _tx.s('pd1'),
            color: _rt_Tw.sky400,
            icon: Icons.bolt,
          ),
          _rt_InfoCard(
            title: _tx.s('pt2'),
            body: _tx.s('pd2'),
            color: _rt_Tw.red500,
            icon: Icons.dangerous,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- UI ---

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
              accent: _rt_Tw.green500,
              headerGradient: [_rt_Tw.slate900, Color(0xFF064E3B)],
              headerSubtitleColor: Color(0xFF86EFAC),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('app_title'),
              subtitle: _tx.s('tagline'),
              buttonLabel: _tx.s('init_btn'),
              footnote: _tx.s('intro_foot'),
              icon: Icons.eco,
              buttonIcon: Icons.play_arrow,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            hint: _rt_StepHint(
              number: '$_phase',
              label: _tx.s('hud_mission'),
              text: _tx.s('p${_phase}_title'),
            ),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('lab_mission'),
                icon: Icons.account_tree,
                builder: (_) => _missionTab(),
              ),
            ],
            canvas: _rt_ZoomableCanvas(controller: _zoom, child: _canvas()),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------ canvas ---

  Widget _canvas() {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(70, 12, 60, 0),
                child: _missionBar(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 52, 70),
                child: Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: _designW,
                      height: _designH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned.fill(
                            child: CustomPaint(painter: _GalleryFloorPainter()),
                          ),
                          ...switch (_phase) {
                            1 => _phase1Scene(),
                            2 => _phase2Scene(),
                            3 => _phase3Scene(),
                            _ => _phase4Scene(),
                          },
                        ],
                      ),
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

  /// The mini-HUD strip: mission number dots + current mission title.
  Widget _missionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: const Border(top: BorderSide(color: _rt_Tw.green500, width: 2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 4; i++) ...[
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < _phase || _completed
                    ? _rt_Tw.green500
                    : (i == _phase
                          ? _rt_Tw.green500.withValues(alpha: 0.25)
                          : _rt_Lab.overlay),
                border: Border.all(
                  color: i <= _phase ? _rt_Tw.green500 : _rt_Lab.border,
                ),
              ),
              child: i < _phase || _completed
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : Text(
                      '$i',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: i == _phase
                            ? _rt_Tw.green400
                            : _rt_Lab.textFaint,
                      ),
                    ),
            ),
            const SizedBox(width: 5),
          ],
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              _tx.s('p${_phase}_title'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One emoji "gallery card" token, matching the source's canvas texture:
  /// dark gradient card, neon-green border, soft glow, name plate.
  Widget _token(
    _Organism o, {
    required double x,
    required double y,
    VoidCallback? onTap,
    Color glow = _rt_Tw.green400,
    double glowStrength = 0.35,
    double emissive = 0,
    double bob = 0,
    double scale = 1,
  }) {
    final borderColor = Color.lerp(_rt_Tw.green400, _rt_Tw.red500, emissive)!;
    return AnimatedPositioned(
      key: ValueKey('tok-${o.id}'),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _shake]),
        builder: (context, child) {
          final dy = bob == 0
              ? 0.0
              : math.sin(_float.value * 2 * math.pi + bob) * 4;
          final dx = _shaking == o.id
              ? math.sin(_shake.value * math.pi * 6) * 6
              : 0.0;
          return Transform.translate(offset: Offset(dx, dy), child: child);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 400),
            scale: scale,
            child: Container(
              width: _tokenSize,
              height: _tokenSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_rt_Tw.slate800, _rt_Tw.slate900],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      glow,
                      _rt_Tw.red500,
                      emissive,
                    )!.withValues(alpha: glowStrength + emissive * 0.4),
                    blurRadius: 18 + emissive * 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    o.emoji,
                    style: const TextStyle(fontSize: 40, height: 1.1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tx.s('names.${o.id}'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _rt_Tw.slate100,
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

  Widget _pedestal(double slotCenterX, double y) {
    return Positioned(
      left: slotCenterX - 62,
      top: y,
      child: Container(
        width: 124,
        height: 16,
        decoration: BoxDecoration(
          color: _rt_Tw.slate700,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  // Phase 1: scattered cards; tapped-in-order cards fly to the bottom row.
  List<Widget> _phase1Scene() {
    const rowY = 218.0;
    final placed = _p1Seq.length;
    return [
      // Neon arrows appear between already-placed cards.
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _ArrowsPainter(
              count: math.max(0, placed - 1),
              y: rowY + _tokenSize / 2,
            ),
          ),
        ),
      ),
      for (var i = 0; i < _p1Items.length; i++)
        () {
          final o = _p1Items[i];
          final idx = _p1Seq.indexOf(o.id);
          final pos = idx >= 0 ? Offset(_slotX[idx], rowY) : _scatter[o.id]!;
          return _token(
            o,
            x: pos.dx,
            y: pos.dy,
            bob: idx >= 0 ? 0 : i * 1.6 + 0.5,
            onTap: () => _handleP1Tap(o.id),
          );
        }(),
    ];
  }

  // Phase 2: the finished chain on pedestals, arrows + transfer labels, and
  // energy read-outs that light up as each calculation is verified.
  List<Widget> _phase2Scene() {
    const rowY = 96.0;
    return [
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _ArrowsPainter(count: 3, y: rowY + _tokenSize / 2),
          ),
        ),
      ),
      for (var i = 0; i < _p1Items.length; i++) ...[
        _pedestal(_slotX[i] + _tokenSize / 2, rowY + _tokenSize + 4),
        _token(_p1Items[i], x: _slotX[i], y: rowY),
      ],
      // Transfer percentages above the arrows (1% capture, then the 10% law).
      for (var i = 0; i < 3; i++)
        Positioned(
          left: _slotX[i] + _tokenSize,
          top: rowY + _tokenSize / 2 - 34,
          width: _slotX[i + 1] - _slotX[i] - _tokenSize,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _rt_Tw.slate900.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _rt_Tw.green400.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                i == 0 ? '1%' : '10%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _rt_Tw.green400,
                ),
              ),
            ),
          ),
        ),
      // Energy plaques under the pedestals.
      for (var i = 0; i < 4; i++)
        Positioned(
          left: _slotX[i] + _tokenSize / 2 - 62,
          top: rowY + _tokenSize + 30,
          width: 124,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: i == 0 || _p2Ok[i - 1] == true
                    ? _rt_Tw.green500.withValues(alpha: 0.18)
                    : _rt_Tw.slate800.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: i == 0 || _p2Ok[i - 1] == true
                      ? _rt_Tw.green400
                      : _rt_Tw.slate600,
                ),
              ),
              child: Text(
                i == 0
                    ? '1,000,000 ${_tx.s('joule')}'
                    : (_p2Ok[i - 1] == true
                          ? '${_p2Values[i - 1]} ${_tx.s('joule')}'
                          : '? ${_tx.s('joule')}'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: i == 0 || _p2Ok[i - 1] == true
                      ? _rt_Tw.green400
                      : _rt_Tw.slate400,
                ),
              ),
            ),
          ),
        ),
    ];
  }

  // Phase 3: the glass pyramid; tiers fill bottom-up with the source colours.
  List<Widget> _phase3Scene() {
    const tierH = 62.0;
    const gap = 6.0;
    const baseBottom = 330.0;
    const widths = [440.0, 330.0, 220.0, 116.0];
    return [
      for (var i = 0; i < 4; i++)
        () {
          final filled = i < _p3Progress;
          final w = widths[i];
          final top = baseBottom - (i + 1) * tierH - i * gap;
          final color = _tierColors[i];
          final darkText = i == 1; // yellow tier needs dark text
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            left: _designW / 2 - w / 2,
            top: top,
            width: w,
            height: tierH,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filled
                    ? color.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: filled
                      ? color
                      : _rt_Tw.slate400.withValues(alpha: 0.6),
                  width: filled ? 2.5 : 1.5,
                ),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.55),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: filled
                  ? Text(
                      _tx.s(_tierLabelKeys[_tierTypes[i]]!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: darkText ? _rt_Tw.slate900 : Colors.white,
                      ),
                    )
                  : Text(
                      'L${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _rt_Tw.slate400.withValues(alpha: 0.8),
                      ),
                    ),
            ),
          );
        }(),
    ];
  }

  // Phase 4: the aquatic chain with rising DDT tint; a meter under each card
  // once the eagle has been picked.
  List<Widget> _phase4Scene() {
    const rowY = 78.0;
    return [
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _ArrowsPainter(count: 3, y: rowY + _tokenSize / 2),
          ),
        ),
      ),
      for (var i = 0; i < _p4Items.length; i++) ...[
        _token(
          _p4Items[i],
          x: _slotX[i],
          y: rowY,
          emissive:
              _p4Items[i].ppm *
              (_p4Done && _p4Items[i].id == 'bird' ? 1.2 : 0.9),
          scale: _p4Done && _p4Items[i].id == 'bird' ? 1.18 : 1,
          bob: i * 1.4 + 0.3,
          onTap: () => _handleP4Tap(_p4Items[i].id),
        ),
        // Post-answer data reveal (R:L9102-9104): the Runbook's DDT figures,
        // shown only after the correct pick (QA C10-13.2-01) and only for the
        // levels the Runbook gives (QA C10-13.2-02). No bar: a bar scaled to
        // the source's tint factors contradicted the 0.01 : 1000 ppm data.
        if (_p4Done && _runbookPpm.containsKey(_p4Items[i].id))
          Positioned(
            key: ValueKey('ddt-meter-${_p4Items[i].id}'),
            left: _slotX[i],
            top: rowY + _tokenSize + 16,
            width: _tokenSize,
            child: Text(
              '${_runbookPpm[_p4Items[i].id]} ${_tx.s('ppm')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: _rt_Tw.red400,
              ),
            ),
          ),
      ],
    ];
  }

  // ----------------------------------------------------------- sidebar ---

  Widget _missionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('lab_mission'),
          desc: _tx.s('lab_desc'),
          accent: _rt_Tw.green500,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var n = 1; n <= 4; n++) _phaseCard(n),
              const SizedBox(height: 8),
              if (_completed) ...[
                _rt_ActionButton(
                  key: const ValueKey('btn-restart-activity'),
                  label: _tx.s('btn_restart'),
                  icon: Icons.rotate_left,
                  color: _rt_Tw.emerald600,
                  expand: true,
                  sound: _rt_Sfx.scenario,
                  onPressed: _restart,
                ),
                const SizedBox(height: 12),
              ],
              // ---- Why Learn This? (source context tab) ----
              _rt_SectionLabel(
                _tx.s('ctx_title'),
                icon: Icons.lightbulb,
                color: _rt_Tw.green400,
              ),
              _rt_InfoCard(
                title: _tx.s('c1_t'),
                body: _tx.s('c1_d'),
                color: _rt_Tw.green500,
                icon: Icons.balance,
              ),
              _rt_InfoCard(
                title: _tx.s('c2_t'),
                body: _tx.s('c2_d'),
                color: _rt_Tw.amber500,
                icon: Icons.agriculture,
              ),
              _rt_InfoCard(
                title: _tx.s('c3_t'),
                body: _tx.s('c3_d'),
                color: _rt_Tw.red500,
                icon: Icons.dangerous,
              ),
              const SizedBox(height: 6),
              // ---- Teacher's Guide (source explainer tab) ----
              _rt_SectionLabel(
                _tx.s('guide_title'),
                icon: Icons.school,
                color: _rt_Tw.sky400,
              ),
              _rt_InfoCard(body: _tx.s('g_intro'), color: _rt_Tw.sky400),
              _rt_InfoCard(
                title: _tx.s('g_concept_title'),
                color: _rt_Tw.green500,
                icon: Icons.hub,
                child: _numberedLines(_tx.list('g_concept')),
              ),
              _rt_InfoCard(
                color: _rt_Tw.slate500,
                icon: Icons.format_list_numbered,
                title: _tx.s('lab_mission'),
                child: _numberedLines(_tx.list('g_steps')),
              ),
              const SizedBox(height: 6),
              // ---- Analysis & Outcomes (source post tab) ----
              _rt_SectionLabel(
                _tx.s('post_title'),
                icon: Icons.fact_check,
                color: _rt_Tw.amber400,
              ),
              if (_completed)
                _rt_InfoCard(
                  title: _tx.s('res_good'),
                  color: _rt_Tw.green500,
                  icon: Icons.military_tech,
                ),
              _rt_InfoCard(
                title: _tx.s('pt1'),
                body: _tx.s('pd1'),
                color: _rt_Tw.sky400,
                icon: Icons.bolt,
              ),
              _rt_InfoCard(
                title: _tx.s('pt2'),
                body: _tx.s('pd2'),
                color: _rt_Tw.red500,
                icon: Icons.warning_amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numberedLines(List<dynamic> lines) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.textMuted,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lines[i] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: _rt_Lab.text,
                        height: 1.35,
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

  Widget _phaseCard(int n) {
    final active = _phase == n && !_completed;
    final done = _phase > n || _completed;
    const accent = _rt_Tw.green500;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: done
            ? _rt_Lab
                  .tinted(_rt_Tw.emerald50, _rt_Tw.emerald500)
                  .withValues(alpha: 0.5)
            : (active
                  ? _rt_Lab.tinted(_rt_Tw.green50, accent)
                  : _rt_Lab.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? accent : (done ? _rt_Tw.emerald500 : _rt_Lab.border),
          width: 2,
        ),
      ),
      child: Opacity(
        opacity: active || done ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? _rt_Tw.emerald500
                          : _rt_Lab.tinted(_rt_Tw.green100, accent),
                      border: Border.all(
                        color: done
                            ? _rt_Tw.emerald500
                            : _rt_Lab.tintedBorder(accent),
                      ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : Text(
                            '$n',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _rt_Lab.onTinted(
                                _rt_Tw.green400,
                                _rt_Tw.green700,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tx.s('p${n}_title'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _tx.s('p${n}_desc'),
                style: TextStyle(
                  fontSize: 12,
                  color: _rt_Lab.textMuted,
                  height: 1.3,
                ),
              ),
              if (active) ...[
                const SizedBox(height: 8),
                switch (n) {
                  1 => _p1Controls(),
                  2 => _p2Controls(),
                  3 => _p3Controls(),
                  _ => _p4Controls(),
                },
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _p1Controls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tx.s('tapHint'),
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: _rt_Lab.textFaint,
          ),
        ),
        SizedBox(
          height: 30,
          child: _p1Error == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _p1Error!,
                    key: const ValueKey('p1-error'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _rt_Tw.red400,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _p2Controls() {
    final qs = [_tx.s('p2_q1'), _tx.s('p2_q2'), _tx.s('p2_q3')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 3; i++) ...[
          Text(
            qs[i],
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _rt_Lab.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            key: ValueKey('inp-p2-$i'),
            controller: _p2Ctl[i],
            enabled: !_transitioning,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              color: _rt_Lab.text,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '? ${_tx.s('joule')}',
              hintStyle: TextStyle(color: _rt_Lab.textFaint),
              filled: true,
              fillColor: _rt_Lab.overlay,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: switch (_p2Ok[i]) {
                    true => _rt_Tw.green400,
                    false => _rt_Tw.red500,
                    null => _rt_Lab.borderStrong,
                  },
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: switch (_p2Ok[i]) {
                    true => _rt_Tw.green400,
                    false => _rt_Tw.red500,
                    null => _rt_Tw.green400,
                  },
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _rt_Tw.green400, width: 2),
              ),
            ),
            onChanged: (_) {
              if (_p2Ok[i] != null) setState(() => _p2Ok[i] = null);
            },
          ),
          const SizedBox(height: 8),
        ],
        _rt_ActionButton(
          key: const ValueKey('btn-p2-check'),
          label: _tx.s('p2_btn'),
          icon: Icons.calculate,
          color: _rt_Tw.indigo600,
          expand: true,
          sound: null, // correct/wrong feedback plays instead
          onPressed: _transitioning ? null : _checkPhase2,
        ),
      ],
    );
  }

  Widget _p3Controls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in _tierButtonOrder)
          if (!_p3Used.contains(type))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _tierButton(type),
            ),
      ],
    );
  }

  Widget _tierButton(String type) {
    final color = _tierColorOf[type]!;
    return Material(
      key: ValueKey('btn-p3-$type'),
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _transitioning ? null : () => _handleP3Tap(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Text(
            _tx.s(_tierLabelKeys[type]!),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.onTinted(
                color,
                Color.lerp(color, Colors.black, 0.35)!,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _p4Controls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tx.s('tapHint'),
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: _rt_Lab.textFaint,
          ),
        ),
        if (_p4Feedback != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _p4Feedback!,
              key: const ValueKey('p4-feedback'),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _rt_Tw.green400,
              ),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------ painters ---

/// The source's dark gallery: slate backdrop, starfield, grid floor and a
/// green spotlight wash.
class _GalleryFloorPainter extends CustomPainter {
  const _GalleryFloorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_rt_Tw.slate950, _rt_Tw.slate900],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));

    // Starfield (deterministic pseudo-random).
    final star = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final rnd = math.Random(13);
    for (var i = 0; i < 70; i++) {
      final p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.55,
      );
      canvas.drawCircle(p, rnd.nextDouble() * 1.2 + 0.3, star);
    }

    // Green spotlight wash from the left (source SpotLight 0x4ade80).
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.7, -0.4),
          radius: 1.2,
          colors: [_rt_Tw.green400.withValues(alpha: 0.10), Colors.transparent],
        ).createShader(rect),
    );

    // Perspective grid floor on the lower third.
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.7)
      ..strokeWidth = 1;
    final horizon = size.height * 0.62;
    for (var i = 0; i <= 5; i++) {
      final y = horizon + (size.height - horizon) * (i * i / 25);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final cx = size.width / 2;
    for (var i = -8; i <= 8; i++) {
      canvas.drawLine(
        Offset(cx + i * size.width / 16, horizon),
        Offset(cx + i * size.width / 6, size.height),
        gridPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GalleryFloorPainter oldDelegate) => false;
}

/// Glowing neon arrows between chain slots (source ArrowHelper + tube).
class _ArrowsPainter extends CustomPainter {
  const _ArrowsPainter({required this.count, required this.y});

  final int count;
  final double y;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = _rt_Tw.green400.withValues(alpha: 0.25)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final core = Paint()
      ..color = _rt_Tw.green400
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count && i < 3; i++) {
      final x1 = _slotX[i] + _tokenSize + 8;
      final x2 = _slotX[i + 1] - 8;
      canvas.drawLine(Offset(x1, y), Offset(x2, y), glow);
      canvas.drawLine(Offset(x1, y), Offset(x2 - 6, y), core);
      final head = Path()
        ..moveTo(x2, y)
        ..lineTo(x2 - 12, y - 7)
        ..lineTo(x2 - 12, y + 7)
        ..close();
      canvas.drawPath(head, Paint()..color = _rt_Tw.green400);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowsPainter old) =>
      old.count != count || old.y != y;
}
