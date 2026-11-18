// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names, camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names
// Class 10, Activity 4.2: Hydrocarbon Chain
// Converted from Cl10S-Ch4-A2-HydrocarbonFactory.html (Tailwind + inline SVG -> CustomPainter + widgets).
//
// Grow a chain Meth- to Hex- (+/-), tap C-C bonds to cycle single/double/triple (H atoms are ejected
// or restored to keep carbon tetravalent), attach one functional group, run the combustion test and name
// the molecule in the Nomenclature Studio; observations pop up 2.5 s after each change, as in the source.

// --- TRANSLATION DATA (the source's `content` block; `te` dropped) ---

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue900 = Color(0xFF1E3A8A);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo900 = Color(0xFF312E81);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red700 = Color(0xFFB91C1C);
  static const orange500 = Color(0xFFF97316);
  static const orange600 = Color(0xFFEA580C);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const yellow500 = Color(0xFFEAB308);
  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
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

/// Multiple-choice option button used in quizzes / challenges.
class _rt_ChoiceButton extends StatelessWidget {
  const _rt_ChoiceButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;
  final _rt_ChoiceState state = _rt_ChoiceState.idle;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (state) {
      _rt_ChoiceState.correct => (
        _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500),
        _rt_Tw.green500,
        _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700),
      ),
      _rt_ChoiceState.wrong => (
        _rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500),
        _rt_Tw.red500,
        _rt_Lab.onTinted(_rt_Tw.red400, _rt_Tw.red700),
      ),
      _rt_ChoiceState.selected => (
        _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500),
        _rt_Tw.blue500,
        _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700),
      ),
      _rt_ChoiceState.idle => (_rt_Lab.surface, _rt_Lab.border, _rt_Lab.text),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 2),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _rt_ChoiceState { idle, selected, correct, wrong }

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

  bool get isSidebarOpen => _state?._isSidebarOpen ?? true;

  void setSidebarOpen(bool open) => _state?._setSidebar(open);

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
    this.canvasOverlays = const [],
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.toolbarExtras = const [],
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
    super.dispose();
  }

  void _setSidebar(bool open) {
    if (open == _isSidebarOpen) return;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _isSidebarOpen = open);
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
  _rt_CanvasZoomController({this.min = 0.6, this.max = 3.0});

  final double min;
  final double max;
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

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'appTitle': 'HYDROCARBON CHAIN',
    'shutterSub': 'Class 10 • Carbon and its Compounds',
    'enterBtn': 'Enter _rt_Lab',
    'introFoot': 'Catenation • Saturation • Functional Groups',
    'headerTitle': 'Hydrocarbon Chain',
    'headerSub': 'Class 10 • Carbon and its Compounds',
    // Tabs
    'tabWhy': 'Why Learn This?',
    'tabTeacher': 'Teacher Guide',
    'tabExplore': 'Explore',
    'tabOutcomes': 'Outcomes',
    // Why tab
    'ctxTitle': 'Why Learn This?',
    'ctxDesc':
        'Carbon is versatile! From the food we eat to the fuel we burn, Carbon chains and functional groups define chemical properties. Understanding these structures allows us to engineer new materials and medicines.',
    'ex1Title': 'Cooking Fuel (LPG)',
    'ex1Desc':
        'LPG consists of saturated hydrocarbons (Alkanes) like Propane and Butane. Their single bonds break easily, releasing energy with a clean blue flame.',
    'ex2Title': 'Vegetable Ghee',
    'ex2Desc':
        'Unsaturated vegetable oils (healthy) are converted into solid fats (like Vanaspati) by adding Hydrogen across double bonds. This is called Hydrogenation.',
    'ex3Title': 'Welding Torches',
    'ex3Desc':
        'Ethyne (Acetylene), an unsaturated hydrocarbon with a triple bond, burns with oxygen to produce temperatures over 3000°C, hot enough to melt steel.',
    // Teacher tab
    'tchContext':
        'In this lab, students explore the versatility of Carbon by building hydrocarbon chains. They will learn about Catenation (chain building), Valency (bonding), and Functional Groups.',
    'tchPhase1': 'Discovery',
    'tchPhase1Desc':
        'Start with Methane (CH4). Ask students to count the bonds around Carbon (Tetravalency). Explain that Carbon always forms 4 bonds.',
    'tchPhase2': 'Interaction',
    'tchPhase2Desc':
        "Guide them to build Ethane (C2H6), then remove Hydrogens to form Ethene (C2H4). Discuss 'Unsaturation' and how multiple bonds form to satisfy valency.",
    'tchPhase3': 'Observation',
    'tchPhase3Desc':
        'Perform the Combustion Test. Compare the clean blue flame of Alkanes (Saturated) vs. the sooty yellow flame of Alkenes/Alkynes (Unsaturated).',
    // Explore tab
    'expObj':
        'Main Objective: Master the assembly of Carbon compounds by manipulating bonds and atoms to understand Catenation and Valency.',
    'task1Do': 'DO: Add Carbon atoms (+)',
    'task1Focus':
        'FOCUS: Watch how a Hydrogen atom is removed (Ejected) to make space for the new Carbon-Carbon bond.',
    'task2Do': 'DO: Click a Bond Line',
    'task2Focus':
        "FOCUS: Observe how Single bonds become Double/Triple bonds, and how Hydrogen atoms are ejected to maintain Carbon's valency of 4.",
    'task3Do': 'DO: Add an -OH Group',
    'task3Focus':
        "FOCUS: Note that the Hydrogen is replaced by the Functional Group, and the molecule's name changes to end in '-ol'.",
    // Outcomes tab
    'outKey': 'Key Concept',
    'outLearn': 'What is Learnt',
    'row1Key': 'Catenation & Valency',
    'row1Learn':
        "Carbon atoms link together to form chains. Forming bonds requires satisfying Carbon's tetravalency (4 bonds).",
    'row2Key': 'Saturation',
    'row2Learn':
        'Single bonds = Saturated (Blue Flame). Double/Triple bonds = Unsaturated (Yellow Sooty Flame).',
    'row3Key': 'Functional Groups',
    'row3Learn':
        'Specific groups (like -OH, -Cl) replace Hydrogen and dictate the chemical properties of the molecule.',
    // Controls
    'ctrlHeader': 'Controls',
    'ctrlChain': '1. Chain Construction',
    'ctrlBond': '2. Bond Modification',
    'ctrlBondHint': 'Click bonds in diagram to change.',
    'ctrlGroup': '3. Functional Groups',
    'ctrlTools': '4. _rt_Lab Tools',
    'btnCombust': 'Combustion Test',
    'btnNomen': 'Nomenclature Studio',
    'lblCarbons': 'Carbons',
    'lblSingle': 'Single',
    'lblDouble': 'Double',
    'lblTriple': 'Triple',
    'btnCl': '-Cl (Chloro)',
    'btnOH': '-OH (Alcohol)',
    'btnCHO': '-CHO (Aldehyde)',
    'btnONE': '=O (Ketone)',
    'btnCOOH': '-COOH (Acid)',
    'lblFormula': 'Formula',
    'lblIUPAC': 'IUPAC Name',
    'bondChip': 'C{a} {s} C{b}',
    // Tooltips
    'tipToggleLabels': 'Toggle Labels',
    'tipPanMode': 'Pan Mode',
    'tipToggleControls': 'Toggle Controls',
    // Guide & popups
    'guideTitle': 'Instructor Guide',
    'guideStep1':
        'Step 1: Build Ethane.<br>Click <strong>(+)</strong> to add Carbon.',
    'guideStep2':
        'Step 2: Create Unsaturated Bonds.<br>Click the <strong>grey bond lines</strong>.',
    'guideStep3':
        'Step 3: Reactivity Check.<br>Run the <strong>Combustion Test</strong>.',
    'guideStep4':
        'Step 4: Add Functional Group.<br>Add an <strong>-OH</strong> or <strong>-Cl</strong>.',
    'guideFinal':
        'Final Step: Nomenclature.<br>Use the <strong>Studio</strong> to name your creation.',
    'obsTitle': 'Observation',
    'btnContinue': 'Continue',
    'popupLimit':
        'Factory limit is Hex- (6 Carbons). Try modifying the existing chain.',
    'obsLinkTitle': 'Observation: Catenation & Linking',
    'obsLinkBody':
        '<strong>C-C Bond Formation:</strong><br><br>To attach the new Carbon atom, a C-H bond on the terminal Carbon was <strong>broken</strong>. The Hydrogen atom was ejected to free up a valence electron.<br><br>This electron is now shared with the new Carbon atom to form a stable C-C covalent bond. This unique ability of Carbon to link with itself is called <strong>Catenation</strong>.',
    'obsUnsatDoubleTitle': 'Unsaturation: Double Bond',
    'obsUnsatDoubleBody':
        '<strong>Forming an Alkene (C=C):</strong><br><br>To create a double bond, one Hydrogen atom was removed from <strong>EACH</strong> of the adjacent Carbon atoms.<br><br>The two electrons that were holding the Hydrogens are now shared between the Carbons, forming the second bond of the double bond.',
    'obsUnsatTripleTitle': 'Unsaturation: Triple Bond',
    'obsUnsatTripleBody':
        '<strong>Forming an Alkyne (C≡C):</strong><br><br>Yet another Hydrogen was removed from each Carbon.<br><br>The Carbons now share 3 electron pairs (6 electrons total). This triple bond is shorter, stronger, and contains high potential energy.',
    'obsSatTitle': 'Saturation: Single Bond',
    'obsSatBody':
        "<strong>Restoring an Alkane (C-C):</strong><br><br>Hydrogen atoms have been re-added to the structure (Hydrogenation).<br><br>The Carbons now share only one electron pair. The molecule is 'Saturated' because it has the maximum possible number of Hydrogen atoms.",
    'errKetone':
        '<strong>Ketone Requirement:</strong> A Ketone group (=O) must be flanked by two carbons. Minimum chain length is 3 (Propanone).',
    'errValency':
        'Not allowed: a Carbon atom can form only 4 bonds (tetravalency).',
    'msgCl':
        '<strong>Substitution Reaction (Halogenation):</strong><br>A Hydrogen atom has been replaced by a highly electronegative Chlorine atom. This creates a polar bond.',
    'msgOH':
        '<strong>Alcohol Formation (-OH):</strong><br>The Hydroxyl group replaces a Hydrogen. This group introduces Hydrogen bonding capabilities, significantly increasing the boiling point compared to the parent alkane.',
    'msgCHO':
        '<strong>Aldehyde Group (-CHO):</strong><br>Notice that this group is always at the <strong>end</strong> of a carbon chain. The Carbon is double-bonded to Oxygen and single-bonded to a Hydrogen.',
    'msgONE':
        '<strong>Ketone Group (>C=O):</strong><br>The Carbonyl group is in the <strong>middle</strong> of the chain. This Carbon atom has no Hydrogens attached to it anymore.',
    'msgCOOH':
        '<strong>Carboxylic Acid (-COOH):</strong><br>This group combines a Carbonyl (C=O) and a Hydroxyl (OH) on the same Carbon. It can release an H+ ion, making the molecule acidic (like Vinegar).',
    'obsFuncTitle': 'Functional Group Attached',
    'obsFlameUnsatTitle': 'Combustion Result',
    'obsFlameUnsatBody':
        "<strong>Yellow Sooty Flame (Unsaturated):</strong><br><br>This happens due to <strong>Incomplete Combustion</strong>. Unsaturated hydrocarbons have a higher percentage of carbon. The oxygen in the air isn't sufficient to burn all the carbon, so unburnt carbon particles glow yellow (incandescence) and form soot.",
    'obsFlameSatTitle': 'Combustion Result',
    'obsFlameSatBody':
        '<strong>Clean Blue Flame (Saturated):</strong><br><br>This indicates <strong>Complete Combustion</strong>. Saturated hydrocarbons burn efficiently with sufficient oxygen, converting all carbon into Carbon Dioxide and heat, leaving no residue.',
    'flameBlue': 'Blue Flame',
    'flameSat': 'Saturated',
    'flameYellow': 'Yellow Sooty Flame',
    'flameUnsat': 'Unsaturated',
    'flameBurning': 'Burning...',
    // Nomenclature studio
    'quizTitle': 'Nomenclature Studio',
    'quizIntroTitle': 'Nomenclature Guide',
    'quizIntroBody': 'Prefix (Count) + Suffix (Bonds/Group)',
    'quizStart': 'Start Naming',
    'quizS1Title': 'Step 1: Prefix (Carbon Count)',
    'quizS1Verify': 'Verify',
    'quizS2Title': 'Step 2: Suffix (Bonds)',
    'quizS3Title': 'Step 3: Functional Group',
    'quizS3Detected': 'Detected',
    'quizS3Apply': 'Apply',
    'quizFinalTitle': 'Label Created!',
    'quizFinish': 'Finish',
    'qCorrect': 'Correct!',
    'qIncorrect': 'Incorrect.',
    'qSelect': 'Select...',
    'preMeth': 'Meth-',
    'preEth': 'Eth-',
    'preProp': 'Prop-',
    'preBut': 'But-',
    'prePent': 'Pent-',
    'preHex': 'Hex-',
    'sufAne': '-ane',
    'sufEne': '-ene',
    'sufYne': '-yne',
    'grpCl': 'Chloro-',
    'grpOl': '-ol',
    'grpAl': '-al',
    'grpOne': '-one',
    'grpAcid': '-oic acid',
    'grpNameCl': 'Chlorine',
    'grpNameOl': 'Hydroxyl',
    'grpNameAl': 'Aldehyde',
    'grpNameOne': 'Ketone',
    'grpNameAcid': 'Carboxyl',
    // Name builder: stem + suffix, or stem + suffix-stem + group ending.
    'nm': {
      'stems': ['Meth', 'Eth', 'Prop', 'But', 'Pent', 'Hex'],
      'ane': 'ane',
      'ene': 'ene',
      'yne': 'yne',
      'aneStem': 'an',
      'eneStem': 'en',
      'yneStem': 'yn',
      'OH': 'ol',
      'CHO': 'al',
      'ONE': 'one',
      'COOH': 'oic acid',
      'chloro': 'Chloro',
    },
  },
  'hi': {
    'appTitle': 'हाइड्रोकार्बन चेन',
    'shutterSub': 'कक्षा 10 • कार्बन और उसके यौगिक',
    'enterBtn': 'प्रवेश करें',
    'introFoot': 'श्रृंखलन • संतृप्ति • कार्यात्मक समूह',
    'headerTitle': 'हाइड्रोकार्बन चेन',
    'headerSub': 'कक्षा 10 • कार्बन और उसके यौगिक',
    'tabWhy': 'यह क्यों सीखें?',
    'tabTeacher': 'शिक्षक गाइड',
    'tabExplore': 'अन्वेषण',
    'tabOutcomes': 'परिणाम',
    'ctxTitle': 'यह क्यों सीखें?',
    'ctxDesc':
        'कार्बन बहुमुखी है! हम जो भोजन खाते हैं उससे लेकर हम जो ईंधन जलाते हैं, कार्बन श्रृंखलाएं और कार्यात्मक समूह रासायनिक गुणों को परिभाषित करते हैं। इन संरचनाओं को समझने से हमें नई सामग्री और दवाएं बनाने की अनुमति मिलती है।',
    'ex1Title': 'रसोई गैस (LPG)',
    'ex1Desc':
        'एलपीजी में प्रोपेन और ब्यूटेन जैसे संतृप्त हाइड्रोकार्बन (अल्केन्स) होते हैं। उनके एकल बंधन आसानी से टूट जाते हैं, जिससे एक साफ नीली लौ के साथ ऊर्जा निकलती है।',
    'ex2Title': 'वनस्पति घी',
    'ex2Desc':
        'असंतृप्त वनस्पति तेल (स्वस्थ) को दोहरे बंधनों में हाइड्रोजन जोड़कर ठोस वसा (जैसे वनस्पति) में परिवर्तित किया जाता है। इसे हाइड्रोजनीकरण कहा जाता है।',
    'ex3Title': 'वेल्डिंग टॉर्च',
    'ex3Desc':
        'इथाइन (एसिटिलीन), एक ट्रिपल बॉन्ड वाला असंतृप्त हाइड्रोकार्बन, ऑक्सीजन के साथ जलकर 3000°C से अधिक तापमान पैदा करता है, जो स्टील को पिघलाने के लिए पर्याप्त गर्म होता है।',
    'tchContext':
        'इस प्रयोगशाला में, छात्र हाइड्रोकार्बन श्रृंखलाएँ बनाकर कार्बन की बहुमुखी प्रतिभा का पता लगाते हैं। वे श्रृंखलन (चेन बिल्डिंग), संयोजकता (बॉन्डिंग), और कार्यात्मक समूहों के बारे में जानेंगे।',
    'tchPhase1': 'खोज',
    'tchPhase1Desc':
        'मीथेन (CH4) से शुरू करें। छात्रों से कार्बन के आसपास के बंधनों को गिनने के लिए कहें (चतुःसंयोजकता)। समझाएं कि कार्बन हमेशा 4 बंधन बनाता है।',
    'tchPhase2': 'बातचीत',
    'tchPhase2Desc':
        "उन्हें ईथेन (C2H6) बनाने के लिए मार्गदर्शन करें, फिर एथीन (C2H4) बनाने के लिए हाइड्रोजन हटा दें। 'असंतृप्ति' पर चर्चा करें और संयोजकता को संतुष्ट करने के लिए बहु-बंधन कैसे बनते हैं।",
    'tchPhase3': 'अवलोकन',
    'tchPhase3Desc':
        'दहन परीक्षण करें। एल्केन (संतृप्त) की साफ नीली लौ बनाम एल्कीन/एल्काइन (असंतृप्त) की कालिखयुक्त पीली लौ की तुलना करें।',
    'expObj':
        'मुख्य उद्देश्य: श्रृंखलन और संयोजकता को समझने के लिए बंधों और परमाणुओं में बदलाव करके कार्बन यौगिकों के निर्माण में महारत हासिल करें।',
    'task1Do': 'करें: कार्बन परमाणु जोड़ें (+)',
    'task1Focus':
        'ध्यान दें: देखें कि नए कार्बन-कार्बन बंधन के लिए जगह बनाने के लिए हाइड्रोजन परमाणु को कैसे हटाया (इजेक्ट) किया जाता है।',
    'task2Do': 'करें: बॉन्ड लाइन पर क्लिक करें',
    'task2Focus':
        'ध्यान दें: देखें कि एकल बंधन दोहरे/तिहरे बंधन कैसे बन जाते हैं, और कार्बन की 4 की संयोजकता बनाए रखने के लिए हाइड्रोजन परमाणुओं को कैसे बाहर निकाला जाता है।',
    'task3Do': 'करें: -OH समूह जोड़ें',
    'task3Focus':
        "ध्यान दें: हाइड्रोजन को कार्यात्मक समूह द्वारा प्रतिस्थापित किया जाता है, और अणु का नाम '-ol' (-ऑल) पर समाप्त होने लगता है।",
    'outKey': 'मुख्य अवधारणा',
    'outLearn': 'क्या सीखा',
    'row1Key': 'श्रृंखलन और संयोजकता',
    'row1Learn':
        'कार्बन परमाणु जंजीर बनाने के लिए एक साथ जुड़ते हैं। बंध बनाते समय कार्बन की चतुःसंयोजकता (4 बंध) को संतुष्ट करना आवश्यक है।',
    'row2Key': 'संतृप्ति',
    'row2Learn':
        'एकल बंधन = संतृप्त (नीली लौ)। द्वि/त्रि-बंध = असंतृप्त (कालिखयुक्त पीली लौ)।',
    'row3Key': 'कार्यात्मक समूह',
    'row3Learn':
        'विशिष्ट समूह (जैसे -OH, -Cl) हाइड्रोजन की जगह लेते हैं और अणु के रासायनिक गुणों को निर्धारित करते हैं।',
    'ctrlHeader': 'नियंत्रण',
    'ctrlChain': '1. श्रृंखला निर्माण',
    'ctrlBond': '2. बंध संशोधन',
    'ctrlBondHint': 'बदलने के लिए आरेख में बंध पर क्लिक करें।',
    'ctrlGroup': '3. कार्यात्मक समूह',
    'ctrlTools': '4. लैब टूल्स',
    'btnCombust': 'दहन परीक्षण',
    'btnNomen': 'नामकरण स्टूडियो',
    'lblCarbons': 'कार्बन',
    'lblSingle': 'एकल',
    'lblDouble': 'दोहरा',
    'lblTriple': 'तिहरा',
    'btnCl': '-Cl (क्लोरो)',
    'btnOH': '-OH (अल्कोहल)',
    'btnCHO': '-CHO (एल्डिहाइड)',
    'btnONE': '=O (कीटोन)',
    'btnCOOH': '-COOH (अम्ल)',
    'lblFormula': 'सूत्र',
    'lblIUPAC': 'IUPAC नाम',
    'bondChip': 'C{a} {s} C{b}',
    'tipToggleLabels': 'लेबल टॉगल करें',
    'tipPanMode': 'पैन मोड',
    'tipToggleControls': 'नियंत्रण टॉगल करें',
    'guideTitle': 'प्रशिक्षक गाइड',
    'guideStep1':
        'चरण 1: ईथेन बनाएं।<br>कार्बन जोड़ने के लिए <strong>(+)</strong> पर क्लिक करें।',
    'guideStep2':
        'चरण 2: असंतृप्त बंध बनाएं।<br><strong>ग्रे बंध रेखाओं</strong> पर क्लिक करें।',
    'guideStep3':
        'चरण 3: अभिक्रियाशीलता जांच।<br><strong>दहन परीक्षण</strong> चलाएं।',
    'guideStep4':
        'चरण 4: कार्यात्मक समूह जोड़ें।<br>एक <strong>-OH</strong> या <strong>-Cl</strong> जोड़ें।',
    'guideFinal':
        'अंतिम चरण: नामकरण।<br>अपनी रचना का नाम देने के लिए <strong>स्टूडियो</strong> का उपयोग करें।',
    'obsTitle': 'अवलोकन',
    'btnContinue': 'जारी रखें',
    'popupLimit':
        'फैक्टरी सीमा हेक्स- (6 कार्बन) है। मौजूदा श्रृंखला को संशोधित करने का प्रयास करें।',
    'obsLinkTitle': 'अवलोकन: श्रृंखलन और लिंकिंग',
    'obsLinkBody':
        '<strong>C-C बंध निर्माण:</strong><br><br>नए कार्बन परमाणु को जोड़ने के लिए, अंतिम कार्बन पर एक C-H बंध <strong>टूट गया</strong>। संयोजी इलेक्ट्रॉन को मुक्त करने के लिए हाइड्रोजन परमाणु को बाहर निकाल दिया गया।<br><br>यह इलेक्ट्रॉन अब नए कार्बन परमाणु के साथ साझा होकर एक स्थिर C-C सहसंयोजक बंध बनाता है। कार्बन की स्वयं से जुड़ने की इस अनूठी क्षमता को <strong>श्रृंखलन (Catenation)</strong> कहा जाता है।',
    'obsUnsatDoubleTitle': 'असंतृप्ति: द्वि-बंध',
    'obsUnsatDoubleBody':
        '<strong>एल्कीन (C=C) का निर्माण:</strong><br><br>द्वि-बंध बनाने के लिए, पास-पास के कार्बन परमाणुओं में से <strong>प्रत्येक</strong> से एक हाइड्रोजन परमाणु हटा दिया गया।<br><br>हाइड्रोजन को थामे रखने वाले दो इलेक्ट्रॉन अब कार्बनों के बीच साझा होते हैं, जिससे द्वि-बंध का दूसरा बंध बनता है।',
    'obsUnsatTripleTitle': 'असंतृप्ति: त्रि-बंध',
    'obsUnsatTripleBody':
        '<strong>एल्काइन (C≡C) का निर्माण:</strong><br><br>प्रत्येक कार्बन से एक और हाइड्रोजन हटा दिया गया।<br><br>कार्बन अब 3 इलेक्ट्रॉन युग्म (कुल 6 इलेक्ट्रॉन) साझा करते हैं। यह त्रि-बंध छोटा, मजबूत है और इसमें उच्च स्थितिज ऊर्जा होती है।',
    'obsSatTitle': 'संतृप्ति: एकल बंध',
    'obsSatBody':
        "<strong>एल्केन (C-C) की पुनः प्राप्ति:</strong><br><br>हाइड्रोजन परमाणुओं को संरचना में फिर से जोड़ा गया है (हाइड्रोजनीकरण)।<br><br>कार्बन अब अपने पड़ोसी के साथ केवल एक इलेक्ट्रॉन युग्म साझा करते हैं। अणु 'संतृप्त' है क्योंकि इसमें हाइड्रोजन परमाणुओं की अधिकतम संभव संख्या है।",
    'errKetone':
        '<strong>कीटोन आवश्यकता:</strong> कीटोन समूह (=O) के दोनों ओर कार्बन होने चाहिए। न्यूनतम श्रृंखला लंबाई 3 (प्रोपेनोन) है।',
    'errValency':
        'अनुमति नहीं: कार्बन परमाणु केवल 4 बंध बना सकता है (चतुःसंयोजकता)।',
    'msgCl':
        '<strong>प्रतिस्थापन अभिक्रिया (हैलोजनीकरण):</strong><br>एक हाइड्रोजन परमाणु को अत्यधिक विद्युत-ऋणात्मक क्लोरीन परमाणु द्वारा प्रतिस्थापित किया गया है। इससे एक ध्रुवीय बंध बनता है।',
    'msgOH':
        '<strong>अल्कोहल निर्माण (-OH):</strong><br>हाइड्रॉक्सिल समूह एक हाइड्रोजन की जगह लेता है। यह समूह हाइड्रोजन बंधन की क्षमता लाता है, जिससे मूल एल्केन की तुलना में क्वथनांक काफी बढ़ जाता है।',
    'msgCHO':
        '<strong>एल्डिहाइड समूह (-CHO):</strong><br>ध्यान दें कि यह समूह हमेशा कार्बन श्रृंखला के <strong>अंत</strong> में होता है। इसका कार्बन ऑक्सीजन से द्वि-बंध और हाइड्रोजन से एकल बंध द्वारा जुड़ा होता है।',
    'msgONE':
        '<strong>कीटोन समूह (>C=O):</strong><br>कार्बोनिल समूह श्रृंखला के <strong>मध्य</strong> में है। इस कार्बन परमाणु पर अब कोई हाइड्रोजन नहीं जुड़ा है।',
    'msgCOOH':
        '<strong>कार्बोक्सिलिक अम्ल (-COOH):</strong><br>यह समूह एक ही कार्बन पर कार्बोनिल (C=O) और हाइड्रॉक्सिल (OH) को जोड़ता है। यह H+ आयन छोड़ सकता है, जिससे अणु अम्लीय (सिरके की तरह) हो जाता है।',
    'obsFuncTitle': 'कार्यात्मक समूह जुड़ा',
    'obsFlameUnsatTitle': 'दहन परिणाम',
    'obsFlameUnsatBody':
        '<strong>कालिखयुक्त पीली लौ (असंतृप्त):</strong><br><br>यह <strong>अपूर्ण दहन</strong> के कारण होता है। असंतृप्त हाइड्रोकार्बन में कार्बन का प्रतिशत अधिक होता है। हवा की ऑक्सीजन सारे कार्बन को जलाने के लिए पर्याप्त नहीं होती, इसलिए बिना जले कार्बन के कण पीले चमकते हैं (तापदीप्ति) और कालिख बनाते हैं।',
    'obsFlameSatTitle': 'दहन परिणाम',
    'obsFlameSatBody':
        '<strong>साफ नीली लौ (संतृप्त):</strong><br><br>यह <strong>पूर्ण दहन</strong> को दर्शाता है। संतृप्त हाइड्रोकार्बन पर्याप्त ऑक्सीजन में कुशलता से जलते हैं, सारे कार्बन को कार्बन डाइऑक्साइड और ऊष्मा में बदल देते हैं और कोई अवशेष नहीं छोड़ते।',
    'flameBlue': 'नीली लौ',
    'flameSat': 'संतृप्त',
    'flameYellow': 'कालिखयुक्त पीली लौ',
    'flameUnsat': 'असंतृप्त',
    'flameBurning': 'जल रहा है...',
    'quizTitle': 'नामकरण स्टूडियो',
    'quizIntroTitle': 'नामकरण गाइड',
    'quizIntroBody': 'उपसर्ग (गिनती) + प्रत्यय (बंध/समूह)',
    'quizStart': 'नामकरण शुरू करें',
    'quizS1Title': 'चरण 1: उपसर्ग (कार्बन गिनती)',
    'quizS1Verify': 'सत्यापित करें',
    'quizS2Title': 'चरण 2: प्रत्यय (बंध)',
    'quizS3Title': 'चरण 3: कार्यात्मक समूह',
    'quizS3Detected': 'पता चला',
    'quizS3Apply': 'लागू करें',
    'quizFinalTitle': 'लेबल बनाया गया!',
    'quizFinish': 'समाप्त',
    'qCorrect': 'सही!',
    'qIncorrect': 'गलत।',
    'qSelect': 'चुनें...',
    'preMeth': 'मेथ-',
    'preEth': 'एथ-',
    'preProp': 'प्रोप-',
    'preBut': 'ब्यूट-',
    'prePent': 'पेंट-',
    'preHex': 'हेक्स-',
    'sufAne': '-एन',
    'sufEne': '-ईन',
    'sufYne': '-आइन',
    'grpCl': 'क्लोरो-',
    'grpOl': '-ऑल',
    'grpAl': '-अल',
    'grpOne': '-ओन',
    'grpAcid': '-ओइक अम्ल',
    'grpNameCl': 'क्लोरीन',
    'grpNameOl': 'हाइड्रॉक्सिल',
    'grpNameAl': 'एल्डिहाइड',
    'grpNameOne': 'कीटोन',
    'grpNameAcid': 'कार्बोक्सिल',
    // Devanagari endings are vowel signs so they join the stem: मेथ + ेन = मेथेन.
    'nm': {
      'stems': ['मेथ', 'एथ', 'प्रोप', 'ब्यूट', 'पेंट', 'हेक्स'],
      'ane': 'ेन',
      'ene': 'ीन',
      'yne': 'ाइन',
      'aneStem': 'ेन',
      'eneStem': 'ीन',
      'yneStem': 'ाइन',
      'OH': 'ॉल',
      'CHO': 'ैल',
      'ONE': 'ोन',
      'COOH': 'ॉइक अम्ल',
      'chloro': 'क्लोरो',
    },
  },
});

// ------------------------------------------------------------------ model ---

/// Valences a functional group takes from its carbon (C=O counts 2, -COOH 3).
int _groupValence(String? g) => switch (g) {
  null => 0,
  'OH' || 'Cl' => 1,
  'CHO' || 'ONE' => 2,
  _ => 3,
};

/// Every carbon keeps at most 4 bonds (tetravalency).
bool _validStructure(int chain, List<int> bonds, String? group, int groupAt) {
  for (var i = 0; i < chain; i++) {
    final used =
        (i > 0 ? bonds[i - 1] : 0) +
        (i < chain - 1 ? bonds[i] : 0) +
        (group != null && groupAt == i ? _groupValence(group) : 0);
    if (used > 4) return false;
  }
  return true;
}

String _sub(int n) {
  const digits = '₀₁₂₃₄₅₆₇₈₉';
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}

const _radius = {'C': 24.0, 'H': 14.0, 'O': 20.0, 'Cl': 20.0};

/// SVG radial gradients g-C / g-H / g-O / g-Cl.
const _atomColors = {
  'C': [Color(0xFF64748B), Color(0xFF0F172A)],
  'H': [Color(0xFFFFFFFF), Color(0xFFCBD5E1)],
  'O': [Color(0xFFF87171), Color(0xFF991B1B)],
  'Cl': [Color(0xFF86EFAC), Color(0xFF166534)],
};

class _AtomSpec {
  const _AtomSpec(this.id, this.el, this.label, this.pos, this.anchor);

  /// Stable id (`C1`, `H1@-90`, `GOH0`) so a redraw can animate what changed.
  final String id;
  final String el;
  final String label;
  final Offset pos;

  /// The carbon it hangs from; an ejected atom flies away from it.
  final Offset anchor;
}

class _BondSpec {
  const _BondSpec(this.id, this.a, this.b, this.order, {this.chainIndex});

  final String id;
  final String a;
  final String b;
  final int order;

  /// Index into the chain's bond list for tappable C-C bonds.
  final int? chainIndex;
}

class _Layout {
  _Layout(this.atoms, this.bonds)
    : atomById = {for (final a in atoms) a.id: a},
      bondById = {for (final b in bonds) b.id: b},
      bbox = _bounds(atoms);

  final List<_AtomSpec> atoms;
  final List<_BondSpec> bonds;
  final Map<String, _AtomSpec> atomById;
  final Map<String, _BondSpec> bondById;
  final Rect bbox;

  static Rect _bounds(List<_AtomSpec> atoms) {
    Rect box(_AtomSpec a) =>
        Rect.fromCircle(center: a.pos, radius: _radius[a.el]! + 6);
    var r = box(atoms.first);
    for (final a in atoms) {
      r = r.expandToInclude(box(a));
    }
    return r;
  }
}

/// The source's `getDirections`: free bond angles around carbon [i].
List<double> _directions(int chain, int i, int needed) {
  List<double> valid;
  if (chain == 1) {
    valid = [-90, 90, 180, 0];
  } else {
    final low = i.isOdd;
    if (i == 0) {
      valid = low ? [90, 180, -90] : [-90, 180, 90];
    } else if (i == chain - 1) {
      valid = low ? [90, 0, -90] : [-90, 0, 90];
    } else {
      valid = low ? [90, -90] : [-90, 90];
    }
  }
  return valid.take(needed).toList();
}

/// The source's `render()`: zig-zag carbons 70 px apart, hydrogens (and the
/// functional group) 50 px out along the free directions.
_Layout _layoutFor(int chain, List<int> bonds, String? group, int groupAt) {
  const startX = 150.0, startY = 250.0, bondLen = 70.0;
  final nodes = [
    for (var i = 0; i < chain; i++)
      Offset(startX + i * bondLen, startY + (i.isOdd ? 40 : -40)),
  ];
  final atoms = <_AtomSpec>[];
  final specs = <_BondSpec>[
    for (var i = 0; i < bonds.length; i++)
      _BondSpec('CC$i', 'C$i', 'C${i + 1}', bonds[i], chainIndex: i),
  ];
  for (var i = 0; i < chain; i++) {
    final c = nodes[i];
    final g = (group != null && groupAt == i) ? group : null;
    final used =
        (i > 0 ? bonds[i - 1] : 0) +
        (i < chain - 1 ? bonds[i] : 0) +
        _groupValence(g);
    final slots = math.max(0, 4 - used);
    // -COOH is drawn as its two atoms (=O and -OH); the rest are one atom.
    final parts = switch (g) {
      null => const <(String, String, int)>[],
      'Cl' => const [('Cl', 'Cl', 1)],
      'OH' => const [('O', 'OH', 1)],
      'CHO' || 'ONE' => const [('O', '=O', 2)],
      _ => const [('O', '=O', 2), ('O', 'OH', 1)],
    };
    final dirs = _directions(chain, i, slots + parts.length);
    Offset at(double deg) {
      final r = deg * math.pi / 180;
      return c + Offset(math.cos(r) * 50, math.sin(r) * 50);
    }

    for (var k = 0; k < parts.length; k++) {
      final dir = dirs.isNotEmpty ? dirs.removeLast() : -90.0;
      final id = 'G$g$k';
      atoms.add(_AtomSpec(id, parts[k].$1, parts[k].$2, at(dir), c));
      specs.add(_BondSpec('B$id', 'C$i', id, parts[k].$3));
    }
    for (final d in dirs) {
      final id = 'H$i@${d.round()}';
      atoms.add(_AtomSpec(id, 'H', 'H', at(d), c));
      specs.add(_BondSpec('B$id', 'C$i', id, 1));
    }
    atoms.add(_AtomSpec('C$i', 'C', 'C', c, c));
  }
  return _Layout(atoms, specs);
}

/// World -> canvas mapping that fits the molecule into the free area.
class _View {
  const _View(this.offset, this.scale);

  final Offset offset;
  final double scale;

  Offset map(Offset p) => offset + p * scale;

  static _View fit(Rect bbox, Rect area) {
    final s = math.min(
      1.25,
      math.min(area.width / bbox.width, area.height / bbox.height),
    );
    return _View(area.center - bbox.center * s, s);
  }

  static _View lerp(_View a, _View b, double t) => _View(
    Offset.lerp(a.offset, b.offset, t)!,
    a.scale + (b.scale - a.scale) * t,
  );
}

/// Renders `<br>` and `<strong>` from the source's HTML strings.
List<InlineSpan> _richSpans(String src, TextStyle base, Color strong) {
  final out = <InlineSpan>[];
  final re = RegExp(r'<br\s*/?>|</?strong>');
  var bold = false;
  var last = 0;
  void emit(String s) {
    if (s.isEmpty) return;
    out.add(
      TextSpan(
        text: s,
        style: bold
            ? base.copyWith(fontWeight: FontWeight.w900, color: strong)
            : base,
      ),
    );
  }

  for (final m in re.allMatches(src)) {
    emit(src.substring(last, m.start));
    final tag = m.group(0)!;
    if (tag.startsWith('<br')) {
      out.add(TextSpan(text: '\n', style: base));
    } else {
      bold = tag == '<strong>';
    }
    last = m.end;
  }
  emit(src.substring(last));
  return out;
}

Widget _rich(String src, TextStyle base, Color strong, {TextAlign? align}) =>
    Text.rich(
      TextSpan(children: _richSpans(src, base, strong)),
      textAlign: align,
    );

// ------------------------------------------------------------------- page ---

class Cl10SCh04A2HydrocarbonFactoryPage extends StatefulWidget {
  const Cl10SCh04A2HydrocarbonFactoryPage({super.key});

  @override
  State<Cl10SCh04A2HydrocarbonFactoryPage> createState() =>
      _Cl10SCh04A2HydrocarbonFactoryPageState();
}

class _Cl10SCh04A2HydrocarbonFactoryPageState
    extends State<Cl10SCh04A2HydrocarbonFactoryPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_CanvasZoomController _zoom = _rt_CanvasZoomController(
    min: 0.2,
    max: 3.0,
  );

  // --- Store (source) ---
  int _chain = 1;
  final List<int> _bonds = [];
  String? _group;
  int _groupAt = 0;

  late _Layout _prev = _layoutFor(1, const [], null, 0);
  late _Layout _cur = _prev;

  // --- Viewer / UI ---
  bool _labels = true;
  bool _panMode = false;
  bool _guideMin = false;
  Offset _guideOffset = Offset.zero;
  double _guideHeight = 84; // measured after layout
  String _info = 'why';

  // --- Guide progress & flame test ---
  bool _unsatDone = false;
  bool _flameDone = false;
  int _flamePhase = 0; // 0 hidden, 1 burning, 2 result
  bool _flameUnsat = false;
  bool _named = false;

  Timer? _obsTimer;
  bool _popupOpen = false;
  int _popupToken = 0;

  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  )..repeat(reverse: true);

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
    _obsTimer?.cancel();
    _zoom.dispose();
    _morph.dispose();
    _pulse.dispose();
    _flicker.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ derived ---
  bool get _unsaturated => _bonds.any((b) => b > 1);
  int get _maxBond => _bonds.contains(3) ? 3 : (_bonds.contains(2) ? 2 : 1);

  /// updateGuide(), made progress-based so step 3 no longer sticks while a
  /// double bond exists.
  String get _guideKey {
    if (_chain == 1) return 'guideStep1';
    if (!_unsatDone) return 'guideStep2';
    if (!_flameDone) return 'guideStep3';
    if (_group == null) return 'guideStep4';
    return 'guideFinal';
  }

  /// Molecular formula with subscripts (source `getFormula`).
  String _formula() {
    var h = 2 * _chain + 2;
    for (final b in _bonds) {
      h -= (b - 1) * 2;
    }
    var cl = 0, o = 0;
    switch (_group) {
      case 'Cl':
        h -= 1;
        cl = 1;
      case 'OH':
        o = 1;
      case 'CHO' || 'ONE':
        h -= 2;
        o = 1;
      case 'COOH':
        h -= 2;
        o = 2;
    }
    String part(String el, int n) =>
        n == 0 ? '' : (n == 1 ? el : '$el${_sub(n)}');
    return '${part('C', _chain)}${part('H', math.max(0, h))}${part('Cl', cl)}${part('O', o)}';
  }

  /// IUPAC name (source `getName`): prefix + bond suffix, or group ending.
  String _name() {
    final stem = _tx.list('nm.stems')[_chain - 1] as String;
    final b = _maxBond == 3 ? 'yne' : (_maxBond == 2 ? 'ene' : 'ane');
    final g = _group;
    if (g == null) return stem + _tx.s('nm.$b');
    if (g == 'Cl') {
      return _tx.s('nm.chloro') + (stem + _tx.s('nm.$b')).toLowerCase();
    }
    return stem + _tx.s('nm.${b}Stem') + _tx.s('nm.$g');
  }

  // ------------------------------------------------------------ helpers ---
  /// Rebuilds the drawing and animates from the previous one.
  void _commit() {
    _prev = _cur;
    _cur = _layoutFor(_chain, _bonds, _group, _groupAt);
    _flamePhase = 0; // a stale flame result would describe another molecule
    _morph.forward(from: 0);
  }

  /// The source's single observation popup: a new one replaces an open one.
  Future<void> _observe(
    String titleKey,
    String bodyKey, {
    IconData icon = Icons.visibility,
    Color color = _rt_Tw.blue600,
    _rt_Sfx sound = _rt_Sfx.magic,
  }) async {
    if (!mounted) return;
    if (_popupOpen) Navigator.of(context).pop();
    final token = ++_popupToken;
    _popupOpen = true;
    _rt_playSfx(sound);
    await _rt_showShellPopup(
      context,
      title: _tx.s(titleKey),
      icon: icon,
      color: color,
      buttonLabel: _tx.s('btnContinue'),
      body: SizedBox(
        width: double.infinity,
        child: _rich(
          _tx.s(bodyKey),
          TextStyle(fontSize: 13.5, color: _rt_Lab.text, height: 1.45),
          _rt_Tw.blue400,
        ),
      ),
    );
    if (token == _popupToken) _popupOpen = false;
  }

  /// setTimeout(showPopup, 2500) in the source.
  void _scheduleObservation(
    String titleKey,
    String bodyKey, {
    IconData icon = Icons.visibility,
    Color color = _rt_Tw.blue600,
  }) {
    _obsTimer?.cancel();
    _obsTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) _observe(titleKey, bodyKey, icon: icon, color: color);
    });
  }

  void _refuseValency() {
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(
      _tx.s('errValency'),
      color: _rt_Tw.red500,
      icon: Icons.block,
      ms: 3200,
    );
  }

  // ------------------------------------------------------------ actions ---
  void _addCarbon() {
    if (_chain >= 6) {
      _observe(
        'obsTitle',
        'popupLimit',
        icon: Icons.warning_amber_rounded,
        color: _rt_Tw.amber600,
        sound: _rt_Sfx.wrong,
      );
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      final terminal = _chain - 1;
      _chain++;
      _bonds.add(1);
      // An end group stays on the end: -OH, -CHO, -COOH and -Cl follow the chain.
      if (_group != null && _group != 'ONE' && _groupAt == terminal) {
        _groupAt = _chain - 1;
      }
      _commit();
    });
    _scheduleObservation('obsLinkTitle', 'obsLinkBody', icon: Icons.link);
  }

  void _removeCarbon() {
    if (_chain <= 1) {
      _rt_playSfx(_rt_Sfx.wrong);
      return;
    }
    _rt_playSfx(_rt_Sfx.tap);
    _obsTimer?.cancel();
    setState(() {
      final removed = _chain - 1;
      _chain--;
      _bonds.removeLast();
      if (_group == 'ONE') {
        if (_chain < 3) _group = null; // a ketone needs a carbon on each side
      } else if (_group != null && _groupAt == removed) {
        final end = _chain - 1;
        if (_validStructure(_chain, _bonds, _group, end)) {
          _groupAt = end;
        } else {
          _group = null;
        }
      }
      _commit();
    });
  }

  void _toggleBond(int i) {
    final current = _bonds[i];
    var next = current == 3 ? 1 : current + 1;
    final trial = [..._bonds]..[i] = next;
    if (!_validStructure(_chain, trial, _group, _groupAt)) {
      if (current == 1) {
        _refuseValency();
        return;
      }
      next = 1; // cannot go higher: continue the cycle back to single
    }
    _rt_playSfx(next > current ? _rt_Sfx.magic : _rt_Sfx.pop);
    setState(() {
      _bonds[i] = next;
      if (next > 1) _unsatDone = true;
      _commit();
    });
    if (next == 2) {
      _scheduleObservation(
        'obsUnsatDoubleTitle',
        'obsUnsatDoubleBody',
        icon: Icons.drag_handle,
      );
    } else if (next == 3) {
      _scheduleObservation(
        'obsUnsatTripleTitle',
        'obsUnsatTripleBody',
        icon: Icons.menu,
      );
    } else {
      _scheduleObservation('obsSatTitle', 'obsSatBody', icon: Icons.remove);
    }
  }

  void _setGroup(String type) {
    var target = _chain - 1;
    if (type == 'ONE') {
      if (_chain < 3) {
        _observe(
          'obsTitle',
          'errKetone',
          icon: Icons.warning_amber_rounded,
          color: _rt_Tw.amber600,
          sound: _rt_Sfx.wrong,
        );
        return;
      }
      target = 1;
      if (_group == 'ONE') {
        _rt_playSfx(_rt_Sfx.tap);
        return;
      }
    }
    if (!_validStructure(_chain, _bonds, type, target)) {
      _refuseValency();
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() {
      _group = type;
      _groupAt = target;
      _commit();
    });
    _scheduleObservation(
      'obsFuncTitle',
      'msg$type',
      icon: Icons.science,
      color: _rt_Tw.purple600,
    );
  }

  /// runFlameTest(): the card shows at once, the verdict 2.5 s later.
  void _runFlameTest() {
    final unsat = _unsaturated;
    _obsTimer?.cancel();
    setState(() {
      _flamePhase = 1;
      _flameUnsat = unsat;
    });
    _obsTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        _flamePhase = 2;
        if (_unsatDone) _flameDone = true;
      });
      _observe(
        unsat ? 'obsFlameUnsatTitle' : 'obsFlameSatTitle',
        unsat ? 'obsFlameUnsatBody' : 'obsFlameSatBody',
        icon: Icons.local_fire_department,
        color: unsat ? _rt_Tw.amber600 : _rt_Tw.blue600,
        sound: unsat ? _rt_Sfx.pop : _rt_Sfx.correct,
      );
    });
  }

  Future<void> _openStudio() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _NomenclatureStudio(
        chain: _chain,
        bond: _maxBond,
        group: _group,
        name: _name,
        onComplete: () {
          if (mounted) setState(() => _named = true);
        },
      ),
    );
  }

  void _restart() {
    _obsTimer?.cancel();
    _zoom.reset();
    setState(() {
      _chain = 1;
      _bonds.clear();
      _group = null;
      _groupAt = 0;
      _labels = true;
      _panMode = false;
      _guideMin = false;
      _guideOffset = Offset.zero;
      _info = 'why';
      _unsatDone = false;
      _flameDone = false;
      _flamePhase = 0;
      _flameUnsat = false;
      _named = false;
      _prev = _cur = _layoutFor(1, const [], null, 0);
      _morph.value = 1;
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
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('headerTitle'),
            subtitle: _tx.s('headerSub'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.blue600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.indigo900],
              headerSubtitleColor: _rt_Tw.blue100,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('shutterSub'),
              buttonLabel: _tx.s('enterBtn'),
              footnote: _tx.s('introFoot'),
              icon: Icons.hub,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            onZoomIn: _zoom.zoomIn,
            onZoomOut: _zoom.zoomOut,
            onResetView: _zoom.reset,
            toolbarExtras: [
              _toolButton(
                'tool-labels',
                _labels ? Icons.label : Icons.label_off,
                _tx.s('tipToggleLabels'),
                _labels,
                () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _labels = !_labels);
                },
              ),
              const SizedBox(height: 4),
              _toolButton(
                'tool-pan',
                Icons.pan_tool_outlined,
                _tx.s('tipPanMode'),
                _panMode,
                () {
                  _rt_playSfx(_rt_Sfx.toggle);
                  setState(() => _panMode = !_panMode);
                },
              ),
              const SizedBox(height: 4),
              // The source's right-hand controls panel lives in the sidebar here.
              _toolButton(
                'tool-controls',
                Icons.tune,
                _tx.s('tipToggleControls'),
                false,
                () => _shell.setSidebarOpen(!_shell.isSidebarOpen),
              ),
            ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('ctrlHeader'),
                icon: Icons.tune,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _PanZoomCanvas(
              controller: _zoom,
              panEnabled: _panMode,
              child: _moleculeCanvas(),
            ),
            // QA C10-4.2-16: skip the first portrait-width frames.
            canvasOverlays: [
              Positioned.fill(child: _rt_MinWidthGate(child: _overlays())),
            ],
          );
        },
      ),
    );
  }

  Widget _toolButton(
    String key,
    IconData icon,
    String tip,
    bool active,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        key: ValueKey(key),
        radius: 22,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _rt_Tw.blue600 : _rt_Lab.surface,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _rt_Tw.blue600.withValues(alpha: 0.4),
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

  // ------------------------------------------------------------ canvas ---
  /// Space left for the molecule once the guide, toolbar, flame card and
  /// read-out have taken theirs.
  double get _guideBottom => 12 + _guideHeight;

  Rect _fitArea(Size s) {
    final top = _guideBottom + 10;
    final right = 66.0 + (_flamePhase > 0 ? 168.0 : 0.0);
    const bottom = 66.0, left = 16.0;
    return Rect.fromLTWH(
      left,
      top,
      math.max(80.0, s.width - left - right),
      math.max(80.0, s.height - top - bottom),
    );
  }

  Widget _moleculeCanvas() {
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest;
        return AnimatedBuilder(
          animation: _morph,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_morph.value);
            final area = _fitArea(size);
            final view = _View.lerp(
              _View.fit(_prev.bbox, area),
              _View.fit(_cur.bbox, area),
              t,
            );
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MoleculePainter(
                      prev: _prev,
                      cur: _cur,
                      t: t,
                      raw: _morph.value,
                      view: view,
                      labels: _labels,
                      highlightChain: _guideKey == 'guideStep2',
                      pulse: _pulse,
                    ),
                  ),
                ),
                for (final b in _cur.bonds)
                  if (b.chainIndex != null) _bondHitBox(b, view),
              ],
            );
          },
        );
      },
    );
  }

  /// Invisible 30 px-wide strip along each C-C bond (the SVG's transparent
  /// hit line); tapping it cycles the bond.
  Widget _bondHitBox(_BondSpec b, _View view) {
    final a = view.map(_cur.atomById[b.a]!.pos);
    final c = view.map(_cur.atomById[b.b]!.pos);
    final d = c - a;
    final len = d.distance;
    final mid = (a + c) / 2;
    const h = 30.0;
    return Positioned(
      left: mid.dx - len / 2,
      top: mid.dy - h / 2,
      width: len,
      height: h,
      child: Transform.rotate(
        angle: d.direction,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: ValueKey('bond-hit-${b.chainIndex}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleBond(b.chainIndex!),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _overlays() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        final guideW = math.min(340.0, math.max(200.0, w - 150));
        final maxDx = math.max(0.0, (w - guideW) / 2 - 8);
        final maxDy = math.max(0.0, h - 120);
        final gx = _guideOffset.dx.clamp(-maxDx, maxDx);
        final gy = _guideOffset.dy.clamp(0.0, maxDy);
        return Stack(
          children: [
            Positioned(
              left: (w - guideW) / 2 + gx,
              top: 12 + gy,
              width: guideW,
              child: _MeasureSize(
                onChange: (size) {
                  if (mounted && (size.height - _guideHeight).abs() > 0.5) {
                    setState(() => _guideHeight = size.height);
                  }
                },
                child: _guideToast(maxDx, maxDy),
              ),
            ),
            // Below the guide, left of the toolbar (the source's top-right card).
            if (_flamePhase > 0)
              Positioned(
                top: math.max(68.0, _guideBottom + 10),
                right: 66,
                child: IgnorePointer(child: _flameCard()),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: IgnorePointer(child: Center(child: _readout())),
            ),
          ],
        );
      },
    );
  }

  /// The draggable "Instructor Guide" toast (#toast-guide).
  Widget _guideToast(double maxDx, double maxDy) {
    return Container(
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.borderStrong),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => _rt_playSfx(_rt_Sfx.tap),
            onPanUpdate: (d) => setState(() {
              final o = _guideOffset + d.delta;
              _guideOffset = Offset(
                o.dx.clamp(-maxDx, maxDx),
                o.dy.clamp(0.0, maxDy),
              );
            }),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: _guideMin
                    ? BorderRadius.circular(12)
                    : const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _rt_Tw.blue500.withValues(
                          alpha:
                              0.45 +
                              0.55 *
                                  (0.5 -
                                      0.5 *
                                          math.cos(_pulse.value * 2 * math.pi)),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tx.s('guideTitle').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _rt_Tw.blue400,
                      ),
                    ),
                  ),
                  InkResponse(
                    key: const ValueKey('guide-min'),
                    radius: 16,
                    onTap: () {
                      _rt_playSfx(_rt_Sfx.toggle);
                      setState(() => _guideMin = !_guideMin);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        _guideMin ? Icons.add : Icons.remove,
                        size: 16,
                        color: _rt_Lab.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_guideMin)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 9),
              child: _rich(
                _tx.s(_guideKey),
                TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.text,
                  height: 1.3,
                ),
                _rt_Tw.amber400,
              ),
            ),
        ],
      ),
    );
  }

  /// #flame-result: flame drawing + verdict.
  Widget _flameCard() {
    final burning = _flamePhase == 1;
    final title = burning
        ? _tx.s('flameBurning')
        : _tx.s(_flameUnsat ? 'flameYellow' : 'flameBlue');
    final sub = burning ? null : _tx.s(_flameUnsat ? 'flameUnsat' : 'flameSat');
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 76,
            child: CustomPaint(
              painter: _FlamePainter(
                mode: burning ? 0 : (_flameUnsat ? 2 : 1),
                flicker: _flicker,
                drift: _pulse,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.text,
            ),
          ),
          if (sub != null)
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  /// Formula + IUPAC name read-out (the controls panel footer), kept on the
  /// canvas so it stays visible with the sidebar closed.
  Widget _readout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _rt_Lab.tintedBorder(_rt_Tw.blue600),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tx.s('lblFormula').toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.textMuted,
                ),
              ),
              Text(
                _formula(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tx.s('lblIUPAC').toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.textMuted,
                ),
              ),
              Text(
                _name(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: _rt_Tw.blue400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- sidebar ---
  Widget _sidebar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _guideCard(),
          const SizedBox(height: 12),
          _rt_SectionLabel(_tx.s('ctrlChain'), icon: Icons.link),
          _chainControl(),
          const SizedBox(height: 14),
          _rt_SectionLabel(_tx.s('ctrlBond'), icon: Icons.drag_handle),
          _bondControl(),
          const SizedBox(height: 14),
          _rt_SectionLabel(_tx.s('ctrlGroup'), icon: Icons.science),
          _groupControl(),
          const SizedBox(height: 14),
          _rt_SectionLabel(_tx.s('ctrlTools'), icon: Icons.handyman),
          _rt_ActionButton(
            key: const ValueKey('btn-flame'),
            label: _tx.s('btnCombust'),
            icon: Icons.local_fire_department,
            color: _rt_Tw.orange600,
            expand: true,
            sound: _rt_Sfx.magic,
            onPressed: _runFlameTest,
          ),
          const SizedBox(height: 8),
          _rt_ActionButton(
            key: const ValueKey('btn-studio'),
            label: _tx.s('btnNomen'),
            icon: Icons.sell,
            color: _rt_Tw.blue600,
            expand: true,
            sound: _rt_Sfx.scenario,
            onPressed: _openStudio,
          ),
          const SizedBox(height: 14),
          _formulaFooter(),
          const SizedBox(height: 18),
          _infoChips(),
          const SizedBox(height: 10),
          _infoBody(),
        ],
      ),
    );
  }

  Widget _guideCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue600),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _rt_Tw.blue500, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 15, color: _rt_Tw.blue400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s('guideTitle').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: _rt_Tw.blue400,
                  ),
                ),
              ),
              if (_named)
                const Icon(Icons.verified, size: 16, color: _rt_Tw.green400),
            ],
          ),
          const SizedBox(height: 6),
          _rich(
            _tx.s(_guideKey),
            TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _rt_Lab.text,
              height: 1.3,
            ),
            _rt_Tw.amber400,
          ),
          if (_named) ...[
            const SizedBox(height: 6),
            Text(
              _tx.s('quizFinalTitle'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _rt_Tw.green400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chainControl() {
    Widget roundBtn(
      String key,
      IconData icon,
      bool primary,
      VoidCallback onTap,
    ) => Material(
      color: primary ? _rt_Tw.blue600 : _rt_Lab.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: primary ? _rt_Tw.blue700 : _rt_Lab.borderStrong,
        ),
      ),
      child: InkWell(
        key: ValueKey(key),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 40,
          child: Icon(icon, color: primary ? Colors.white : _rt_Lab.text),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue600),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.tintedBorder(_rt_Tw.blue600)),
      ),
      child: Row(
        children: [
          roundBtn('remove-carbon', Icons.remove, false, _removeCarbon),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$_chain',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.text,
                  ),
                ),
                Text(
                  _tx.s('lblCarbons').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _rt_Lab.textMuted,
                  ),
                ),
              ],
            ),
          ),
          roundBtn('add-carbon', Icons.add, true, _addCarbon),
        ],
      ),
    );
  }

  Widget _bondControl() {
    Widget legend(int order, String label) => Column(
      children: [
        SizedBox(
          height: 14,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var k = 0; k < order; k++)
                Container(
                  width: 26,
                  height: order == 1 ? 3 : 2,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  color: _rt_Tw.slate400,
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _rt_Lab.textMuted,
          ),
        ),
      ],
    );
    const symbols = ['', '—', '=', '≡'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _tx.s('ctrlBondHint'),
          style: TextStyle(fontSize: 12, color: _rt_Lab.textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            legend(1, _tx.s('lblSingle')),
            legend(2, _tx.s('lblDouble')),
            legend(3, _tx.s('lblTriple')),
          ],
        ),
        if (_bonds.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _bonds.length; i++)
                Material(
                  color: _bonds[i] > 1
                      ? _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500)
                      : _rt_Lab.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _bonds[i] > 1 ? _rt_Tw.amber500 : _rt_Lab.border,
                    ),
                  ),
                  child: InkWell(
                    key: ValueKey('bond-chip-$i'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _toggleBond(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        _tx
                            .s('bondChip')
                            .replaceAll('{a}', '${i + 1}')
                            .replaceAll('{b}', '${i + 2}')
                            .replaceAll('{s}', symbols[_bonds[i]]),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          color: _rt_Lab.text,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _groupControl() {
    Widget btn(String type, Color color) {
      final on = _group == type;
      return Material(
        color: on
            ? _rt_Lab.tinted(Color.lerp(color, Colors.white, 0.9)!, color)
            : _rt_Lab.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: on ? color : _rt_Lab.borderStrong,
            width: on ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: ValueKey('grp-$type'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => _setGroup(type),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
            child: Text(
              _tx.s('btn$type'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: btn('Cl', _rt_Tw.green500)),
            const SizedBox(width: 6),
            Expanded(child: btn('OH', _rt_Tw.red500)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: btn('CHO', _rt_Tw.purple500)),
            const SizedBox(width: 6),
            Expanded(child: btn('ONE', _rt_Tw.purple500)),
          ],
        ),
        const SizedBox(height: 6),
        btn('COOH', _rt_Tw.yellow500),
      ],
    );
  }

  Widget _formulaFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('lblFormula').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                Text(
                  _formula(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.text,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _tx.s('lblIUPAC').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.textMuted,
                  ),
                ),
                Text(
                  _name(),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.blue400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The source's left drawer tabs (Why / Teacher / Explore / Outcomes).
  Widget _infoChips() {
    const tabs = [
      ('why', 'tabWhy', Icons.lightbulb),
      ('teacher', 'tabTeacher', Icons.co_present),
      ('explore', 'tabExplore', Icons.explore),
      ('outcomes', 'tabOutcomes', Icons.fact_check),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (id, key, icon) in tabs)
          GestureDetector(
            key: ValueKey('info-$id'),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              setState(() => _info = id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _info == id ? _rt_Tw.blue600 : _rt_Lab.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: _info == id ? _rt_Tw.blue600 : _rt_Lab.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: _info == id ? Colors.white : _rt_Lab.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _tx.s(key),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _info == id ? Colors.white : _rt_Lab.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoBody() {
    return switch (_info) {
      'teacher' => _teacherTab(),
      'explore' => _exploreTab(),
      'outcomes' => _outcomesTab(),
      _ => _whyTab(),
    };
  }

  Widget _whyTab() {
    Widget example(IconData icon, Color color, String n) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(
                Color.lerp(color, Colors.white, 0.85)!,
                color,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('ex${n}Title'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tx.s('ex${n}Desc'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _rt_Lab.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(_rt_Tw.blue50, _rt_Tw.blue500),
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: _rt_Tw.blue500, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tx.s('ctxTitle'),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue900),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tx.s('ctxDesc'),
                style: TextStyle(
                  fontSize: 12,
                  color: _rt_Lab.text,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        example(Icons.local_fire_department, _rt_Tw.orange500, '1'),
        example(Icons.kitchen, _rt_Tw.yellow500, '2'),
        example(Icons.factory, _rt_Tw.red500, '3'),
      ],
    );
  }

  Widget _teacherTab() {
    Widget phase(Color color, String n) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: _rt_Lab.surface, width: 3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('tchPhase$n').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _rt_Lab.onTinted(color, color),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _rt_Lab.overlay,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _rt_Lab.border),
                  ),
                  child: Text(
                    _tx.s('tchPhase${n}Desc'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _rt_Lab.borderStrong, width: 2),
            ),
          ),
          child: Text(
            _tx.s('tchContext'),
            style: TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: _rt_Lab.textMuted,
              height: 1.4,
            ),
          ),
        ),
        phase(_rt_Tw.blue500, '1'),
        phase(_rt_Tw.indigo500, '2'),
        phase(_rt_Tw.purple500, '3'),
      ],
    );
  }

  Widget _exploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _rt_Tw.indigo900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.explore, size: 22, color: _rt_Tw.indigo100),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tx.s('tabExplore'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _tx.s('expObj'),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: _rt_Tw.indigo100,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        for (final n in ['1', '2', '3'])
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _rt_Lab.borderStrong, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s('task${n}Do'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: _rt_Tw.blue400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tx.s('task${n}Focus'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _rt_Tw.amber400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _outcomesTab() {
    TableRow row(String a, String b, {bool header = false}) => TableRow(
      decoration: BoxDecoration(color: header ? _rt_Lab.overlay : null),
      children: [
        Padding(
          padding: const EdgeInsets.all(9),
          child: Text(
            header ? a.toUpperCase() : a,
            style: TextStyle(
              fontSize: header ? 10 : 12,
              fontWeight: header ? FontWeight.w900 : FontWeight.w800,
              color: header ? _rt_Lab.textMuted : _rt_Lab.text,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(9),
          child: Text(
            header ? b.toUpperCase() : b,
            style: TextStyle(
              fontSize: header ? 10 : 11.5,
              fontWeight: header ? FontWeight.w900 : FontWeight.w500,
              color: _rt_Lab.textMuted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        border: TableBorder(
          top: BorderSide(color: _rt_Lab.border),
          bottom: BorderSide(color: _rt_Lab.border),
          left: BorderSide(color: _rt_Lab.border),
          right: BorderSide(color: _rt_Lab.border),
          horizontalInside: BorderSide(color: _rt_Lab.border),
        ),
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1.7)},
        children: [
          row(_tx.s('outKey'), _tx.s('outLearn'), header: true),
          row(_tx.s('row1Key'), _tx.s('row1Learn')),
          row(_tx.s('row2Key'), _tx.s('row2Learn')),
          row(_tx.s('row3Key'), _tx.s('row3Learn')),
        ],
      ),
    );
  }
}

/// Reports its child's laid-out size (used to keep the molecule clear of the
/// guide toast, whose height depends on language and font).
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureSize renderObject,
  ) => renderObject.onChange = onChange;
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _last) return;
    _last = size;
    final s = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(s));
  }
}

/// _rt_ZoomableCanvas with the source's Pan Mode switch: dragging only pans
/// while pan mode is on (pinch and the toolbar zoom always work).
class _PanZoomCanvas extends StatelessWidget {
  const _PanZoomCanvas({
    required this.controller,
    required this.panEnabled,
    required this.child,
  });

  final _rt_CanvasZoomController controller;
  final bool panEnabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: controller.transform,
      minScale: controller.min,
      maxScale: controller.max,
      panEnabled: panEnabled,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      child: child,
    );
  }
}

// ---------------------------------------------------------------- painters ---

class _MoleculePainter extends CustomPainter {
  _MoleculePainter({
    required this.prev,
    required this.cur,
    required this.t,
    required this.raw,
    required this.view,
    required this.labels,
    required this.highlightChain,
    required this.pulse,
  }) : super(repaint: highlightChain ? pulse : null); // only the halo animates

  final _Layout prev;
  final _Layout cur;

  /// Eased and linear progress of the morph from [prev] to [cur].
  final double t;
  final double raw;
  final _View view;
  final bool labels;
  final bool highlightChain;
  final Animation<double> pulse;

  static const _bondColor = _rt_Tw.slate400;

  Offset _ghost(_AtomSpec o) {
    final d = o.pos - o.anchor;
    if (d.distance < 1) return o.pos;
    return o.pos + d / d.distance * (90 * t);
  }

  Offset _pos(String id) {
    final n = cur.atomById[id];
    final o = prev.atomById[id];
    if (n != null && o != null) return Offset.lerp(o.pos, n.pos, t)!;
    if (n != null) return n.pos;
    return _ghost(o!);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Dotted lab-bench grid (the canvas background pattern).
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.07);
    for (var x = 20.0; x < size.width; x += 40) {
      for (var y = 20.0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1.2, dot);
      }
    }

    canvas.save();
    canvas.translate(view.offset.dx, view.offset.dy);
    canvas.scale(view.scale);

    // Pulsing halo on the C-C bonds while the guide asks to click them.
    if (highlightChain) {
      final wave = 0.5 - 0.5 * math.cos(pulse.value * 2 * math.pi);
      final glow = Paint()
        ..color = _rt_Tw.blue500.withValues(alpha: 0.15 + 0.3 * wave)
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;
      for (final b in cur.bonds) {
        if (b.chainIndex == null) continue;
        canvas.drawLine(_pos(b.a), _pos(b.b), glow);
      }
    }

    // Bonds: broken ones fade, surviving ones follow their atoms.
    final fadeOut = (1 - raw * 2.5).clamp(0.0, 1.0);
    for (final b in prev.bonds) {
      if (cur.bondById.containsKey(b.id)) continue;
      _bond(canvas, _pos(b.a), _pos(b.b), b.order, fadeOut);
    }
    for (final b in cur.bonds) {
      final old = prev.bondById[b.id];
      final a = _pos(b.a), c = _pos(b.b);
      if (old == null) {
        _bond(canvas, a, c, b.order, t);
      } else if (old.order != b.order && t < 1) {
        _bond(canvas, a, c, old.order, 1 - t);
        _bond(canvas, a, c, b.order, t);
      } else {
        _bond(canvas, a, c, b.order, 1);
      }
    }

    // Ejected atoms fly outwards and fade.
    for (final a in prev.atoms) {
      if (cur.atomById.containsKey(a.id)) continue;
      final shrink = a.el == 'C' ? 1 - 0.5 * t : 1.0;
      _atom(canvas, _ghost(a), a.el, a.label, 1 - raw, shrink);
    }
    // Peripheral atoms first, carbons on top (source draw order).
    for (final pass in [false, true]) {
      for (final a in cur.atoms) {
        if ((a.el == 'C') != pass) continue;
        final isNew = !prev.atomById.containsKey(a.id);
        _atom(
          canvas,
          _pos(a.id),
          a.el,
          a.label,
          isNew ? t : 1,
          isNew ? 0.4 + 0.6 * t : 1,
        );
      }
    }
    canvas.restore();
  }

  void _bond(Canvas canvas, Offset a, Offset b, int order, double opacity) {
    if (opacity <= 0.01) return;
    final d = b - a;
    if (d.distance < 0.1) return;
    final n = Offset(-d.dy, d.dx) / d.distance;
    final paint = Paint()
      ..color = _bondColor.withValues(alpha: opacity)
      ..strokeCap = StrokeCap.round;
    void line(double off, double w) {
      paint.strokeWidth = w;
      canvas.drawLine(a + n * off, b + n * off, paint);
    }

    if (order == 1) {
      line(0, 4);
    } else if (order == 2) {
      line(-4, 3);
      line(4, 3);
    } else {
      line(-6, 3);
      line(0, 3);
      line(6, 3);
    }
  }

  void _atom(
    Canvas canvas,
    Offset p,
    String el,
    String label,
    double opacity,
    double scale,
  ) {
    if (opacity <= 0.01) return;
    final r = _radius[el]! * scale;
    canvas.drawCircle(
      p + const Offset(2, 4),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    final colors = _atomColors[el]!;
    final rect = Rect.fromCircle(center: p, radius: r);
    canvas.drawCircle(
      p,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.5,
          colors: [
            colors[0].withValues(alpha: opacity),
            colors[1].withValues(alpha: opacity),
          ],
        ).createShader(rect),
    );
    if (el == 'C') {
      // Light rim so the dark carbon reads on the dark canvas.
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _rt_Tw.slate400.withValues(alpha: 0.6 * opacity),
      );
    }
    if (!labels) return;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w800,
          color: (el == 'H' ? _rt_Tw.slate500 : Colors.white).withValues(
            alpha: opacity,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter old) => true;
}

/// The flame SVG (`M50 100 C20 100 20 60 50 0 C80 60 80 100 50 100 Z`).
class _FlamePainter extends CustomPainter {
  _FlamePainter({
    required this.mode,
    required this.flicker,
    required this.drift,
  }) : super(repaint: Listenable.merge([flicker, drift]));

  /// 0 igniting, 1 blue (saturated), 2 yellow sooty (unsaturated).
  final int mode;
  final Animation<double> flicker;
  final Animation<double> drift;

  @override
  void paint(Canvas canvas, Size size) {
    // flicker: scale 1 -> 1.05 every 0.1 s, about the base of the flame.
    final s = (mode == 0 ? 0.7 : 1.0) * (1 + 0.05 * flicker.value);
    canvas.save();
    canvas.translate(size.width / 2, size.height);
    canvas.scale(s);
    canvas.translate(-size.width / 2, -size.height);

    final sx = size.width / 100, sy = size.height / 100;
    final path = Path()
      ..moveTo(50 * sx, 100 * sy)
      ..cubicTo(20 * sx, 100 * sy, 20 * sx, 60 * sy, 50 * sx, 0)
      ..cubicTo(80 * sx, 60 * sy, 80 * sx, 100 * sy, 50 * sx, 100 * sy)
      ..close();
    final (colors, stops) = switch (mode) {
      0 => (const [_rt_Tw.orange600, _rt_Tw.amber200], const [0.0, 1.0]),
      1 => (const [Color(0xFF2563EB), Color(0xFFBFDBFE)], const [0.0, 1.0]),
      _ => (
        const [Color(0xFFCA8A04), Color(0xFFFACC15), Color(0xFF451A03)],
        const [0.0, 0.6, 1.0],
      ),
    };
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: colors,
          stops: stops,
        ).createShader(Offset.zero & size),
    );
    canvas.restore();

    // Soot rising from the yellow flame.
    if (mode == 2) {
      final soot = Paint()
        ..color = const Color(0xFF292524).withValues(alpha: 0.85);
      for (var k = 0; k < 3; k++) {
        final v = (drift.value + k / 3) % 1;
        final x = size.width / 2 + math.sin(v * 2 * math.pi + k) * 7;
        canvas.drawCircle(
          Offset(x, 8 - v * 18),
          3.2 * (1 - v * 0.5),
          soot
            ..color = const Color(0xFF292524).withValues(alpha: 0.85 * (1 - v)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) => old.mode != mode;
}

// ------------------------------------------------------ nomenclature studio ---

class _NomenclatureStudio extends StatefulWidget {
  const _NomenclatureStudio({
    required this.chain,
    required this.bond,
    required this.group,
    required this.name,
    required this.onComplete,
  });

  final int chain;
  final int bond;
  final String? group;
  final String Function() name;
  final VoidCallback onComplete;

  @override
  State<_NomenclatureStudio> createState() => _NomenclatureStudioState();
}

class _NomenclatureStudioState extends State<_NomenclatureStudio> {
  int _step = 0;
  int? _count;
  String? _suffix;
  String? _feedback;
  bool _feedbackOk = false;

  static const _prefixKeys = [
    'preMeth',
    'preEth',
    'preProp',
    'preBut',
    'prePent',
    'preHex',
  ];
  static const _suffixOf = {
    'OH': 'ol',
    'CHO': 'al',
    'ONE': 'one',
    'COOH': 'oic acid',
    'Cl': 'chloro',
  };
  static const _suffixOptions = [
    ('ol', 'grpOl'),
    ('al', 'grpAl'),
    ('one', 'grpOne'),
    ('oic acid', 'grpAcid'),
    ('chloro', 'grpCl'),
  ];
  static const _groupNameKey = {
    'OH': 'grpNameOl',
    'Cl': 'grpNameCl',
    'CHO': 'grpNameAl',
    'ONE': 'grpNameOne',
    'COOH': 'grpNameAcid',
  };

  void _advance(int next) {
    if (next == 4) {
      _rt_playSfx(_rt_Sfx.success);
      widget.onComplete();
    } else {
      _rt_playSfx(_rt_Sfx.correct);
    }
    setState(() {
      _step = next;
      _feedback = next == 4 ? null : _tx.s('qCorrect');
      _feedbackOk = true;
    });
  }

  void _wrong() {
    _rt_playSfx(_rt_Sfx.wrong);
    setState(() {
      _feedback = _tx.s('qIncorrect');
      _feedbackOk = false;
    });
  }

  void _checkStep1() => _count == widget.chain ? _advance(2) : _wrong();

  void _checkStep2(int type) =>
      type == widget.bond ? _advance(widget.group != null ? 3 : 4) : _wrong();

  void _checkStep3() =>
      _suffix == _suffixOf[widget.group] ? _advance(4) : _wrong();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: _rt_Lab.surface,
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450,
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: _rt_Tw.slate950,
              padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
              child: Row(
                children: [
                  const Icon(Icons.sell, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tx.s('quizTitle'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('studio-close'),
                    icon: const Icon(
                      Icons.close,
                      color: _rt_Tw.slate400,
                      size: 20,
                    ),
                    onPressed: () {
                      _rt_playSfx(_rt_Sfx.tap);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w900,
      color: _rt_Lab.text,
    ),
  );

  Widget _feedbackLine() => SizedBox(
    height: 26,
    child: Center(
      child: Text(
        _feedback ?? '',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _feedbackOk ? _rt_Tw.green400 : _rt_Tw.red400,
        ),
      ),
    ),
  );

  Widget _option(String key, String label, bool on, VoidCallback onTap) {
    return Material(
      color: on
          ? _rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500)
          : _rt_Lab.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: on ? _rt_Tw.blue500 : _rt_Lab.border,
          width: on ? 2 : 1,
        ),
      ),
      child: InkWell(
        key: ValueKey(key),
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          _rt_playSfx(_rt_Sfx.tap);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tx.s('quizIntroTitle'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _rt_Lab.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tx.s('quizIntroBody'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _rt_Lab.textMuted),
            ),
            const SizedBox(height: 16),
            _rt_ActionButton(
              label: _tx.s('quizStart'),
              icon: Icons.play_arrow,
              color: _rt_Tw.blue600,
              expand: true,
              onPressed: () => setState(() => _step = 1),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(_tx.s('quizS1Title')),
            const SizedBox(height: 6),
            Text(
              'C${_sub(widget.chain)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: _rt_Lab.text,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _tx.s('qSelect'),
              style: TextStyle(fontSize: 11.5, color: _rt_Lab.textMuted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var n = 1; n <= 6; n++)
                  _option(
                    'q1-opt-$n',
                    '${_tx.s(_prefixKeys[n - 1])} ($n)',
                    _count == n,
                    () => setState(() => _count = n),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _rt_ActionButton(
              key: const ValueKey('q-verify'),
              label: _tx.s('quizS1Verify'),
              icon: Icons.check,
              color: _rt_Tw.blue600,
              expand: true,
              sound: null,
              onPressed: _checkStep1,
            ),
            _feedbackLine(),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _feedbackLine(),
            _title(_tx.s('quizS2Title')),
            const SizedBox(height: 10),
            _rt_ChoiceButton(
              key: const ValueKey('q2-opt-1'),
              label: '${_tx.s('sufAne')} (${_tx.s('lblSingle')})',
              onTap: () => _checkStep2(1),
            ),
            _rt_ChoiceButton(
              key: const ValueKey('q2-opt-2'),
              label: '${_tx.s('sufEne')} (${_tx.s('lblDouble')})',
              onTap: () => _checkStep2(2),
            ),
            _rt_ChoiceButton(
              key: const ValueKey('q2-opt-3'),
              label: '${_tx.s('sufYne')} (${_tx.s('lblTriple')})',
              onTap: () => _checkStep2(3),
            ),
          ],
        );
      case 3:
        final groupName = _tx.s(_groupNameKey[widget.group] ?? '');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _feedbackLine(),
            _title(_tx.s('quizS3Title')),
            const SizedBox(height: 6),
            Text(
              '${_tx.s('quizS3Detected')}: $groupName',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _rt_Lab.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tx.s('qSelect'),
              style: TextStyle(fontSize: 11.5, color: _rt_Lab.textMuted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (value, key) in _suffixOptions)
                  _option(
                    'q3-opt-$value',
                    _tx.s(key),
                    _suffix == value,
                    () => setState(() => _suffix = value),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _rt_ActionButton(
              key: const ValueKey('q-apply'),
              label: _tx.s('quizS3Apply'),
              icon: Icons.check,
              color: _rt_Tw.blue600,
              expand: true,
              sound: null,
              onPressed: _checkStep3,
            ),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tx.s('quizFinalTitle'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _rt_Tw.green400,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: _rt_Tw.slate950,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _rt_Lab.borderStrong),
              ),
              child: Text(
                widget.name(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _rt_ActionButton(
              label: _tx.s('quizFinish'),
              icon: Icons.check_circle,
              color: _rt_Tw.slate600,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
    }
  }
}
