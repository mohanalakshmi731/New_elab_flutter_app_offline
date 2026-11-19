// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 5 • Activity 4
/// Combined Physical and Chemical Changes.
///
/// Native Flutter port of `Cl7S-Ch5-A4-Combined_Physical_and_Chemical_Changes.html`.
///
/// Scenario 1 (Chemical History of a Candle): strike a match from the
/// matchbox and drag it to the candle, HOLD fast-forward to melt the wax
/// (pool + solidifying drip), drag the magnifier to see capillary action in
/// the wick, then place the gas funnel over the flame so the gas bubbles
/// through limewater and turns it milky. Labels and a summary popup follow.
///
/// Scenario 2 (The Slow Transformation of a Rock): rain → snow → sun three
/// times (cracks fill with water, freeze and widen, thaw) until a piece
/// breaks off, HOLD time-lapse to rust the rock, then chip the crust with the
/// hammer to reveal the dark basalt underneath.
class Ch5A4CombinedPhysicalAndChemicalChangesPage extends StatefulWidget {
  const Ch5A4CombinedPhysicalAndChemicalChangesPage({super.key});

  @override
  State<Ch5A4CombinedPhysicalAndChemicalChangesPage> createState() =>
      _Ch5A4CombinedPhysicalAndChemicalChangesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, bubble 732,
/// splash 1311, spark 2365, fire 1348.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer.
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / success popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),
  pop('pop.mp3'),
  drop('drop.mp3'),
  pickup('pickup.mp3'),
  bubble('bubble.mp3'),
  splash('splash.mp3'),
  spark('spark.mp3'),
  fire('fire.mp3');

  const _Sound(this.file);
  final String file;

  @override
  void play() => _Audio.play(this);
}

/// Fire-and-forget player for this lab's tones. A small pool lets tones
/// overlap; it is created on the first tone and freed when the lab closes.
abstract final class _Audio {
  static const int _poolSize = 4;
  static final List<AudioPlayer> _players = [];
  static int _next = 0;

  /// Plays [sound] without blocking. Silent under `flutter test`, which has
  /// no audio plugin. Errors (missing plugin, unsupported platform) are
  /// swallowed so audio never breaks the lab.
  static void play(_Sound sound, {double volume = 0.6}) {
    if (WidgetsBinding.instance is! WidgetsFlutterBinding) return;
    unawaited(_play(sound, volume));
  }

  static Future<void> _play(_Sound sound, double volume) async {
    try {
      if (_players.isEmpty) await _createPlayers();
      final player = _players[_next];
      _next = (_next + 1) % _players.length;
      await player.stop();
      await player.play(
        AssetSource('audio/class7/${sound.file}'),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Audio: could not play ${sound.name}: $e');
    }
  }

  static Future<void> _createPlayers() async {
    for (var i = 0; i < _poolSize; i++) {
      _players.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
    }
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
    } catch (_) {
      // Not supported on every platform; tones still play.
    }
  }

  /// Frees the players; called by the controller when the lab closes.
  static void release() {
    for (final player in _players) {
      unawaited(player.dispose());
    }
    _players.clear();
    _next = 0;
  }
}

// ===================================================================== THEME

/// Brand and Tailwind colours used by this lab.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static LabPalette of(bool isDark) => isDark ? dark : light;
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 24,
);

/// This lab's tones, palettes and font, handed to the shared shell.
const _style = LabStyle(
  click: _Sound.click,
  toggle: _Sound.toggle,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.scenario,
  curtain: _Sound.curtain,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);

/// Part of the design space shown on the stage (crops the empty wall above
/// the scene and leaves room for the tool column on the right). Scene code
/// works in design coordinates; pointer positions are offset by its origin.
const Rect _crop = Rect.fromLTRB(60, 70, 990, 548);

/// Projects the HTML world coordinates (table top y = 0, tray at z = 2,
/// candle / rock / beaker at z = -1) into the 1000×560 design space.
Offset _p3(double x, double y, double z) => Offset(560 + x * 52, 420 - y * 50 + z * 28);

enum _Tool { matchbox, matchstick, magnifier, funnel, cloud, snow, sun, hammer }

/// Short visual effects shown when a tool is applied.
enum _Fx { none, strike, rain, frost, sunshine, impact }

/// Resting places of the tools on the inventory tray.
const Map<_Tool, Offset> _home = {
  _Tool.matchbox: Offset(170, 466),
  _Tool.matchstick: Offset(170, 466),
  _Tool.magnifier: Offset(274, 466),
  _Tool.funnel: Offset(378, 462),
  _Tool.cloud: Offset(170, 464),
  _Tool.snow: Offset(274, 464),
  _Tool.sun: Offset(378, 464),
  _Tool.hammer: Offset(482, 466),
};

/// Hit boxes (the HTML used generous invisible hitbox meshes).
const Map<_Tool, Size> _hitSize = {
  _Tool.matchbox: Size(112, 84),
  _Tool.matchstick: Size(64, 116),
  _Tool.magnifier: Size(100, 84),
  _Tool.funnel: Size(112, 84),
  _Tool.cloud: Size(104, 84),
  _Tool.snow: Size(100, 84),
  _Tool.sun: Size(100, 84),
  _Tool.hammer: Size(100, 84),
};

/// Inverted funnel over the flame: centre of the cone/stem joint.
const Offset _funnelPlaced = Offset(456, 142);

/// Animated move of a tool (e.g. back to the tray). The tool stays at
/// [from] until [start], then eases to [to] over [dur] seconds.
class _ToolMove {
  const _ToolMove(this.from, this.to, this.start, this.dur);
  final Offset from, to;
  final double start, dur;

  Offset at(double t) {
    final v = dur <= 0 ? 1.0 : ((t - start) / dur).clamp(0.0, 1.0);
    return Offset.lerp(from, to, Curves.easeInOutCubic.transform(v))!;
  }
}

/// Mutable scene read by the painter every frame.
class _A4Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  // Dragging.
  _Tool? drag;
  Offset dragPos = Offset.zero;
  final Map<_Tool, _ToolMove> moves = {};

  // Effects.
  _Fx fx = _Fx.none;
  double fxStart = -10;

  // Hint: which tool / button the current step expects (pulsing glow).
  bool idle = true;

  // ---- Scenario 1: candle.
  int matchState = 0; // 0 in the box, 1 rising, 2 lit
  double matchStart = 0;
  bool matchHidden = false;
  bool candleLit = false;
  double candleLitAt = 0;
  double melt = 0; // hold progress 0..1
  bool meltLabels = false;
  bool funnelPlaced = false;
  double limeStart = -1;
  bool limeDone = false;
  bool summary = false;

  // ---- Scenario 2: rock.
  int crack = 0; // 0 dry, 1 water, 2 ice
  bool expanded = false;
  int cycle = 0;
  double rust = 0; // hold progress 0..1
  bool rustLabel = false;
  bool broken = false;
  double brokenAt = 0;
  bool chipped = false;
  double chippedAt = 0;

  bool get isCandle => scenario == 0;
  bool get holdStep => (scenario == 0 && step == 2) || (scenario == 1 && step == 4);

  /// Match rise 0..1 (HTML: 20 ticks × 30 ms, y = 0.5 + sin(p·π/2)·1.5).
  double get matchRise {
    if (matchState == 0) return 0;
    if (matchState == 2) return 1;
    return math.sin(((time - matchStart) / 0.6).clamp(0.0, 1.0) * math.pi / 2);
  }

  /// Limewater cloudiness 0..1 (HTML: p += 0.015 every 50 ms ≈ 3.35 s).
  double get lime => limeStart < 0 ? 0 : ((time - limeStart) / 3.35).clamp(0.0, 1.0);

  double get fxAge => time - fxStart;

  Rect get targetZone => isCandle
      ? const Rect.fromLTRB(266, 40, 646, 432)
      : const Rect.fromLTRB(460, 150, 840, 440);

  List<_Tool> get tools => isCandle
      ? const [_Tool.matchbox, _Tool.magnifier, _Tool.funnel, _Tool.matchstick]
      : const [_Tool.cloud, _Tool.snow, _Tool.sun, _Tool.hammer];

  bool visible(_Tool t) {
    if (t == _Tool.matchstick) return matchState > 0 && !matchHidden;
    return true;
  }

  Offset homeOf(_Tool t) {
    if (t == _Tool.matchstick) {
      return _home[_Tool.matchbox]! + Offset(0, -16 - 76 * matchRise);
    }
    if (t == _Tool.funnel && funnelPlaced) return _funnelPlaced;
    return _home[t]!;
  }

  Offset toolPos(_Tool t) {
    if (drag == t) return dragPos;
    final m = moves[t];
    if (m != null) return m.at(time);
    return homeOf(t);
  }

  Rect hitRect(_Tool t) => Rect.fromCenter(
        center: toolPos(t),
        width: _hitSize[t]!.width,
        height: _hitSize[t]!.height,
      );

  /// Top-most tool under [p] (draw order reversed).
  _Tool? toolAt(Offset p) {
    for (final t in tools.reversed) {
      if (!visible(t)) continue;
      if (t == _Tool.funnel && funnelPlaced) continue;
      if (hitRect(t).contains(p)) return t;
    }
    return null;
  }

  void reset() {
    drag = null;
    moves.clear();
    fx = _Fx.none;
    fxStart = -10;
    idle = true;
    matchState = 0;
    matchHidden = false;
    candleLit = false;
    melt = 0;
    meltLabels = false;
    funnelPlaced = false;
    limeStart = -1;
    limeDone = false;
    summary = false;
    crack = 0;
    expanded = false;
    cycle = 0;
    rust = 0;
    rustLabel = false;
    broken = false;
    chipped = false;
  }
}

/// Pan recogniser that only claims pointers starting on a tool that may be
/// dragged now, so empty-canvas drags still pan an unlocked camera.
class _ToolPanRecognizer extends PanGestureRecognizer {
  _ToolPanRecognizer({required this.canStart});

  bool Function(Offset global) canStart;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && canStart(event.position);
}

// ================================================================== STATE

class _Ch5A4CombinedPhysicalAndChemicalChangesPageState
    extends State<Ch5A4CombinedPhysicalAndChemicalChangesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A4Scene _scene = _A4Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();

  late final Ticker _ticker;

  // Hold-to-fast-forward (HTML setInterval 50 ms, progress += 0.02).
  Timer? _holdTimer;
  int _holdTicks = 0;
  bool _holdDone = false;

  // Pointer / drag state.
  _Tool? _pressTool;
  bool _dragging = false;
  Offset _grab = Offset.zero;

  /// True between a successful action and the step advancing (prevents the
  /// HTML double-trigger when a tool is dropped twice).
  bool _busy = false;
  bool _zoomOpen = false;

  /// Latest UI scale (the popup builder has no context).
  double _uiScale = 1;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _frame.value = _scene.time;
    })..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _holdTimer?.cancel();
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ scenario

  /// HTML `buildScene()` + `loadScenario()`.
  void _buildScenario() {
    _lab.cancelPending();
    _holdStop();
    _holdTicks = 0;
    _holdDone = false;
    _busy = false;
    _zoomOpen = false;
    _pressTool = null;
    _dragging = false;
    _scene.reset();
    _lab.resetView(sound: false);
  }

  /// HTML `switchScenario(val)`.
  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _scene.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  /// HTML `resetActivity()` (shell already restored language/theme/etc).
  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _scene.step = 1;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`; the last step auto-triggers the summary after 5 s.
  void _advanceStep() {
    if (!mounted) return;
    final maxSteps = _scenario == 0 ? 5 : 6;
    setState(() {
      _busy = false;
      if (_step < maxSteps) {
        _scene.step++;
        if (_step == maxSteps) {
          _lab.after(const Duration(milliseconds: 5000), _autoSummary);
        }
      }
    });
  }

  /// HTML `executeStepAction('auto-summary')`.
  void _autoSummary() {
    if (!mounted) return;
    setState(() => _scene.summary = true);
    _lab.showToast(_t('fb_exp_done'));
    final sc = _scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 3000),
      title: () => _t('obs_title'),
      body: () => _t('sum${sc + 1}_intro'),
      extra: () => _summaryExtra(sc),
    );
  }

  // ------------------------------------------------------------- pointer

  bool _isValid(_Tool t) {
    if (_busy || _zoomOpen || !_lab.isLabActive) return false;
    if (_scenario == 0) {
      if (_step == 1 && !_scene.candleLit) {
        if (t == _Tool.matchbox) return true;
        if (t == _Tool.matchstick) return _scene.matchState == 2 && !_scene.matchHidden;
      }
      if (_step == 3 && t == _Tool.magnifier) return true;
      if (_step == 4 && t == _Tool.funnel && !_scene.funnelPlaced) return true;
      return false;
    }
    return (_step == 1 && t == _Tool.cloud) ||
        (_step == 2 && t == _Tool.snow) ||
        (_step == 3 && t == _Tool.sun) ||
        (_step == 5 && t == _Tool.hammer);
  }

  bool _canStartAt(Offset global) {
    final local = labGlobalToLocal(_stageKey, global);
    if (local == null) return false;
    final tool = _scene.toolAt(local + _crop.topLeft);
    return tool != null && _isValid(tool);
  }

  /// HTML `DragLogic.onDown`: valid tools are picked up, others give the
  /// "wrong tool" feedback (the matchbox / match never do).
  void _onPointerDown(PointerDownEvent e) {
    if (_pressTool != null || _dragging) return;
    if (_busy || _zoomOpen || !_lab.isLabActive) return;
    final tool = _scene.toolAt(e.localPosition + _crop.topLeft);
    if (tool == null) return;
    if (_isValid(tool)) {
      _pressTool = tool;
      _Audio.play(_Sound.pickup);
    } else if (tool != _Tool.matchbox && tool != _Tool.matchstick) {
      _lab.showToast(_t('fb_wrong_tool'), isError: true);
    }
  }

  /// A press that never became a drag (HTML `onUp` with dragDist < 0.5).
  void _onPointerUp(PointerUpEvent e) {
    final tool = _pressTool;
    if (tool == null || _dragging) return;
    _pressTool = null;
    if (tool == _Tool.matchbox && _scenario == 0 && _step == 1 && _scene.matchState == 0) {
      setState(_strikeMatch);
      return;
    }
    _lab.showToast(_t('fb_drop_closer'), isError: true);
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (!_dragging) _pressTool = null;
  }

  void _onDragStart(DragStartDetails d) {
    final at = d.localPosition + _crop.topLeft;
    final tool = _pressTool ?? _scene.toolAt(at);
    if (tool == null || !_isValid(tool)) return;
    _pressTool = tool;
    _dragging = true;
    final pos = _scene.toolPos(tool);
    _grab = pos - at;
    setState(() {
      _scene.moves.remove(tool);
      _scene.drag = tool;
      _scene.dragPos = pos;
    });
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_scene.drag == null) return;
    final p = d.localPosition + _crop.topLeft + _grab;
    _scene.dragPos = Offset(
      p.dx.clamp(_crop.left + 20, _crop.right - 20),
      p.dy.clamp(_crop.top + 20, _crop.bottom - 10),
    );
  }

  void _onDragEnd(DragEndDetails d) => _drop();

  void _onDragCancel() {
    final tool = _scene.drag;
    _dragging = false;
    _pressTool = null;
    if (tool == null) return;
    setState(() {
      _scene.drag = null;
      _returnTool(tool, _scene.dragPos);
    });
  }

  /// HTML `DragLogic.onUp`.
  void _drop() {
    final tool = _scene.drag;
    _dragging = false;
    _pressTool = null;
    if (tool == null) return;
    final pos = _scene.dragPos;
    final moved = (pos - _scene.homeOf(tool)).distance;
    setState(() {
      _scene.drag = null;
      var placed = false;
      if (tool == _Tool.matchbox && moved < 26 && _step == 1 && _scene.matchState == 0) {
        _returnTool(tool, pos);
        _strikeMatch();
        placed = true;
      } else if (_scene.targetZone.contains(pos)) {
        if (tool == _Tool.matchbox && _scene.matchState == 0) {
          // Matchbox dragged straight to the candle: strike a match.
          _returnTool(tool, pos);
          _strikeMatch();
          placed = true;
        } else {
          placed = _execute(tool, pos);
        }
      }
      if (!placed) {
        _returnTool(tool, pos);
        _lab.showToast(_t('fb_drop_closer'), isError: true);
      }
    });
  }

  void _returnTool(_Tool tool, Offset from, {double delay = 0}) {
    if (tool == _Tool.matchstick) return;
    _scene.moves[tool] = _ToolMove(from, _scene.homeOf(tool), _scene.time + delay, 0.35);
  }

  void _fx(_Fx fx) {
    _scene.fx = fx;
    _scene.fxStart = _scene.time;
  }

  // -------------------------------------------------------- step actions

  /// HTML `executeStepAction('tool-matchbox-click')`: a match rises out of
  /// the box (600 ms), its head turns black and it catches fire.
  void _strikeMatch() {
    _scene.matchState = 1;
    _scene.matchStart = _scene.time;
    _fx(_Fx.strike);
    _Audio.play(_Sound.spark);
    _lab.after(const Duration(milliseconds: 600), () {
      if (!mounted || _scene.matchState != 1) return;
      setState(() => _scene.matchState = 2);
      _Audio.play(_Sound.fire, volume: 0.35);
      _lab.showToast(_t('fb_match_lit'));
    });
  }

  /// HTML `executeStepAction(toolId)` for dragged tools. Returns true when
  /// the drop did something.
  bool _execute(_Tool tool, Offset pos) {
    if (_scenario == 0) {
      if (_step == 1 && (tool == _Tool.matchstick || tool == _Tool.matchbox) && !_scene.candleLit) {
        _busy = true;
        _scene.matchHidden = true;
        _scene.candleLit = true;
        _scene.candleLitAt = _scene.time;
        _returnTool(_Tool.matchbox, tool == _Tool.matchbox ? pos : _scene.homeOf(_Tool.matchbox));
        _lab.showToast(_t('fb_candle_lit'));
        _lab.after(const Duration(milliseconds: 2000), _advanceStep);
        return true;
      }
      if (_step == 3 && tool == _Tool.magnifier) {
        _busy = true;
        _zoomOpen = true;
        _returnTool(tool, pos);
        _lab.showToast(_t('fb_capillary'));
        return true;
      }
      if (_step == 4 && tool == _Tool.funnel && !_scene.funnelPlaced) {
        _busy = true;
        _scene.funnelPlaced = true;
        _scene.moves[tool] = _ToolMove(pos, _funnelPlaced, _scene.time, 0.35);
        _scene.limeStart = _scene.time;
        _Audio.play(_Sound.bubble);
        _lab.after(const Duration(milliseconds: 3350), () {
          if (!mounted) return;
          setState(() => _scene.limeDone = true);
          _lab.showToast(_t('fb_chem_lime'));
          _lab.after(const Duration(milliseconds: 3000), _advanceStep);
        });
        return true;
      }
      return false;
    }

    // Scenario 2: the rock.
    if (_step == 1 && tool == _Tool.cloud) {
      _busy = true;
      _scene.crack = 1;
      _fx(_Fx.rain);
      _Audio.play(_Sound.splash, volume: 0.4);
      _returnTool(tool, pos, delay: 0.9);
      _lab.showToast(_t('fb_water_seep'));
      _lab.after(const Duration(milliseconds: 1500), _advanceStep);
      return true;
    }
    if (_step == 2 && tool == _Tool.snow) {
      _busy = true;
      _scene.crack = 2;
      _scene.expanded = true;
      _fx(_Fx.frost);
      _returnTool(tool, pos, delay: 0.9);
      _lab.showToast(_t('fb_water_freeze'));
      _lab.after(const Duration(milliseconds: 1500), _advanceStep);
      return true;
    }
    if (_step == 3 && tool == _Tool.sun) {
      _busy = true;
      _scene.cycle++;
      _scene.crack = 0;
      _scene.expanded = false;
      _fx(_Fx.sunshine);
      _returnTool(tool, pos, delay: 0.9);
      if (_scene.cycle < 3) {
        _lab.showToast(labFormat(_t('fb_cycle'), {'n': _scene.cycle}));
        _lab.after(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _scene.step = 1;
          });
        });
      } else {
        _scene.broken = true;
        _scene.brokenAt = _scene.time;
        _Audio.play(_Sound.drop);
        _lab.showToast(_t('fb_rock_broke'));
        _lab.after(const Duration(milliseconds: 2000), _advanceStep);
      }
      return true;
    }
    if (_step == 5 && tool == _Tool.hammer) {
      _busy = true;
      _scene.chipped = true;
      _scene.chippedAt = _scene.time;
      _fx(_Fx.impact);
      _Audio.play(_Sound.pop);
      _returnTool(tool, pos, delay: 0.5);
      _lab.showToast(_t('fb_chip'));
      _lab.after(const Duration(milliseconds: 2500), _advanceStep);
      return true;
    }
    return false;
  }

  /// HTML `closeZoom()`.
  void _closeZoom() {
    setState(() => _zoomOpen = false);
    if (_scenario == 0 && _step == 3) _advanceStep();
  }

  // ------------------------------------------------------- hold button

  void _holdStart() {
    if (!_scene.holdStep || _holdDone || _holdTimer != null || !_lab.isLabActive) return;
    _Audio.play(_Sound.click);
    _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _holdTick());
    setState(() {});
  }

  void _holdStop() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  /// Button released (HTML `onpointerup` / `onpointerleave`): pause.
  void _holdRelease() {
    if (_holdTimer == null) return;
    _holdStop();
    if (mounted) setState(() {});
  }

  void _holdTick() {
    if (!mounted || !_scene.holdStep) {
      _holdStop();
      return;
    }
    setState(() {
      _holdTicks++;
      final p = (_holdTicks / 50).clamp(0.0, 1.0);
      if (_scenario == 0) {
        _scene.melt = p;
      } else {
        _scene.rust = p;
      }
    });
    if (_holdTicks >= 50) {
      _holdStop();
      _holdDone = true;
      _onHoldComplete();
    }
  }

  /// HTML `executeStepAction('btn-hold')`.
  void _onHoldComplete() {
    setState(() {
      _busy = true;
      if (_scenario == 0) {
        _scene.meltLabels = true;
      } else {
        _scene.rustLabel = true;
      }
    });
    _lab.showToast(_t(_scenario == 0 ? 'fb_phys_wax' : 'fb_chem_rust'));
    _lab.after(const Duration(milliseconds: 2500), _advanceStep);
  }

  List<LabAction> _actions() {
    if (_zoomOpen) {
      return [
        LabAction(
          label: _t('btn_close_zoom'),
          icon: Icons.close_fullscreen,
          highlight: true,
          onTap: _closeZoom,
        ),
      ];
    }
    return const [];
  }

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        _uiScale = s;
        final data = _data;
        final pad = MediaQuery.paddingOf(context);
        _scene.idle = !_busy && !_zoomOpen && _lab.isLabActive;
        final holdVisible = _scene.holdStep && !_holdDone && _lab.isLabActive;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          sidebarExtra: _sidebarExtra(p, s),
          onReset: _fullReset,
          showHud: !_zoomOpen,
          overlays: [
            if (holdVisible)
              Positioned(
                left: 12 * s,
                // Top-left while the HUD occupies the bottom; bottom-left when
                // the floating mission card occupies the top-left corner.
                top: _lab.isSidebarOpen ? 56 * s + pad.top : null,
                bottom: _lab.isSidebarOpen ? null : 14 * s + pad.bottom,
                child: _HoldButton(
                  label: _t('btn_hold'),
                  progress: _scenario == 0 ? _scene.melt : _scene.rust,
                  pressed: _holdTimer != null,
                  onDown: _holdStart,
                  onUp: _holdRelease,
                  palette: p,
                  scale: s,
                  width: 214 * s,
                ),
              ),
            if (_zoomOpen) Positioned.fill(child: _zoomOverlay(s)),
          ],
          stage: LabStage(designSize: _crop.size, child: _stageChild()),
        );
      },
    );
  }

  Widget _stageChild() {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: RawGestureDetector(
        key: _stageKey,
        behavior: HitTestBehavior.opaque,
        gestures: {
          _ToolPanRecognizer: GestureRecognizerFactoryWithHandlers<_ToolPanRecognizer>(
            () => _ToolPanRecognizer(canStart: _canStartAt),
            (r) {
              r
                ..canStart = _canStartAt
                ..dragStartBehavior = DragStartBehavior.down
                ..gestureSettings = const DeviceGestureSettings(touchSlop: 8)
                ..onStart = _onDragStart
                ..onUpdate = _onDragUpdate
                ..onEnd = _onDragEnd
                ..onCancel = _onDragCancel;
            },
          ),
        },
        child: CustomPaint(
          size: _crop.size,
          painter: _A4Painter(
            scene: _scene,
            repaint: _frame,
            isDark: _lab.isDark,
            showLabels: _lab.showLabels,
            lang: _lab.lang,
          ),
        ),
      ),
    );
  }

  Widget? _sidebarExtra(LabPalette p, double s) {
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    final progress = _scenario == 0 ? _scene.melt : _scene.rust;
    final showHold = _scene.holdStep && !_holdDone;
    final rows = <Widget>[
      if (showHold) ...[
        _HoldButton(
          label: _t('btn_hold'),
          progress: progress,
          pressed: _holdTimer != null,
          onDown: _holdStart,
          onUp: _holdRelease,
          palette: p,
          scale: s,
        ),
        SizedBox(height: 8 * s),
      ],
      if (_scene.holdStep || progress > 0)
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('ctl_time_lapse'),
          value: '${(progress * 100).round()}%',
          valueColor: const Color(0xFFFB923C),
        ),
      if (_scenario == 1)
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('ctl_cycles'),
          value: '${math.min(_scene.cycle, 3)} / 3',
          valueColor: const Color(0xFF38BDF8),
        ),
    ];
    if (rows.isEmpty) return null;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  /// HTML `#zoom-overlay` (capillary action in the wick).
  Widget _zoomOverlay(double s) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.9),
        child: LayoutBuilder(
          builder: (context, c) {
            final circle = math.min(300 * s, math.min(c.maxHeight * 0.4, c.maxWidth * 0.45));
            return Center(
              child: SingleChildScrollView(
                // Room for the toast above and the tool column on the right.
                padding: EdgeInsets.fromLTRB(16 * s, 46 * s, 60 * s, 12 * s),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: math.max(120, math.min(520 * s, c.maxWidth - 80 * s))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('zoom_title'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Container(
                        width: circle,
                        height: circle,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF111111),
                          border: Border.all(color: _Colors.zslYellow, width: 4),
                          boxShadow: [
                            BoxShadow(color: _Colors.zslYellow.withValues(alpha: 0.4), blurRadius: 40),
                          ],
                        ),
                        child: ClipOval(
                          child: CustomPaint(
                            size: Size.square(circle),
                            painter: _WickZoomPainter(scene: _scene, repaint: _frame),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(text: _t('zoom_desc_pre')),
                          TextSpan(
                            text: _t('zoom_desc_bold'),
                            style: const TextStyle(color: Color(0xFFFACC15), fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: _t('zoom_desc_post')),
                        ]),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16 * s),
                      FilledButton(
                        onPressed: () {
                          _Audio.play(_Sound.click);
                          _closeZoom();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _Colors.zslYellow,
                          foregroundColor: _Colors.slate900,
                          shape: const StadiumBorder(),
                          padding: EdgeInsets.symmetric(horizontal: 28 * s, vertical: 12 * s),
                          textStyle: TextStyle(
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w800,
                            fontFamily: LabFont.active.family,
                            fontFamilyFallback: LabFont.active.fallback,
                          ),
                        ),
                        child: Text(_t('btn_close_zoom')),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// HTML `summary` blocks shown in the observation popup.
  Widget _summaryExtra(int sc) {
    final p = _Theme.of(_lab.isDark);
    final s = _uiScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final k = 'sum${sc + 1}';
    Widget box({
      required Color accent,
      required Color titleColor,
      required String part,
      required int bullets,
    }) {
      return Container(
        padding: EdgeInsets.all(12 * s),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('${k}_${part}_title'),
              style: TextStyle(color: titleColor, fontWeight: FontWeight.w800, fontSize: 14.5 * f),
            ),
            SizedBox(height: 4 * s),
            for (var i = 1; i <= bullets; i++)
              Padding(
                padding: EdgeInsets.only(top: 3 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: TextStyle(color: titleColor, fontSize: 12.5 * f, height: 1.4)),
                    Expanded(
                      child: Text(
                        _t('${k}_${part}_b$i'),
                        style: TextStyle(color: p.text, fontSize: 12.5 * f, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 6 * s),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '${_t('${k}_${part}_res_lbl')} ',
                  style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: _t('${k}_${part}_res')),
              ]),
              style: TextStyle(color: p.text.withValues(alpha: 0.8), fontSize: 11.5 * f, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        box(
          accent: _Colors.blue,
          titleColor: p.isDark ? const Color(0xFF60A5FA) : _Colors.blue600,
          part: 'phys',
          bullets: 3,
        ),
        SizedBox(height: 10 * s),
        box(
          accent: _Colors.red,
          titleColor: p.isDark ? const Color(0xFFF87171) : _Colors.red600,
          part: 'chem',
          bullets: 2,
        ),
      ],
    );
  }
}

// ======================================================== HOLD BUTTON

/// HTML `#btn-action-hold` (orange glass button). Hold it down to run the
/// time-lapse; releasing pauses it. Shows the progress as a bar.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.progress,
    required this.pressed,
    required this.onDown,
    required this.onUp,
    required this.palette,
    required this.scale,
    this.width,
  });

  final String label;
  final double progress;
  final bool pressed;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final LabPalette palette;
  final double scale;
  final double? width;

  static const Color _orange = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: AnimatedScale(
        scale: pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: width,
          padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 14 * s, 10 * s),
          decoration: BoxDecoration(
            color: pressed ? Color.alphaBlend(_orange.withValues(alpha: 0.16), palette.panel) : palette.panel,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: _orange.withValues(alpha: pressed ? 0.85 : 0.4), width: 2),
            boxShadow: [
              const BoxShadow(color: Color(0x4D000000), blurRadius: 18, offset: Offset(0, 8)),
              if (pressed) BoxShadow(color: _orange.withValues(alpha: 0.35), blurRadius: 18),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.fast_forward_rounded, color: _orange, size: 26 * s),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: _orange,
                        fontWeight: FontWeight.w800,
                        fontSize: 14 * s,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * s),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5 * s,
                  backgroundColor: _orange.withValues(alpha: 0.15),
                  color: _orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================ STRINGS
//
// Copied from the HTML `Translations` / `ScenariosDataTranslated` tables
// (Telugu dropped). `<br>` became `\n` and `<b>…</b>` became `**…**` (the
// painter draws those parts bold, like the HTML `.custom-label b`).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Combined Physical and Chemical Changes',
    'app_subtitle': 'Class 7 • Changes Around Us: Physical and Chemical',
    'header_subtitle': 'Class 7 • Changes Around Us',
    'obs_title': 'Observation & Analysis',
    'btn_hold': 'Hold to Fast Forward',
    'zoom_title': 'Capillary Action in Wick',
    'zoom_desc_pre': 'Liquid wax is drawn up the porous wick. This movement is a ',
    'zoom_desc_bold': 'Physical Change',
    'zoom_desc_post': '.',
    'btn_close_zoom': 'Close View',
    'sc1_title': '1. Chemical History of a Candle',
    'sc2_title': '2. The Slow Transformation of a Rock',

    'lbl_inventory': 'INVENTORY',
    'lbl_matchbox': 'Matchbox',
    'lbl_magnifier': 'Magnifier',
    'lbl_funnel': 'Gas Funnel',
    'lbl_limewater': 'Limewater',
    'lbl_rain_cloud': 'Rain Cloud',
    'lbl_snowflake': 'Snowflake',
    'lbl_sun': 'Sun',
    'lbl_hammer': 'Hammer',

    'dyn_molten': 'Molten Liquid Wax\n(State Change, Physical)',
    'dyn_drip': 'Solidifying Drip',
    'dyn_substance': 'New Substance Formed\n(Precipitate)',
    'dyn_gas': 'Transparent Gas Bubbles',
    'dyn_phys1':
        '**Physical Change**: Wax changes state\n(solid → liquid → solid) but is still wax.\nNo new substance is formed.',
    'dyn_chem1':
        '**Chemical Change**: Wax vapor burns (combustion)\nwith oxygen to form new substances like Carbon\nDioxide (CO₂) and water. This is irreversible.',
    'dyn_broken': 'Broken piece of rock',
    'dyn_iron': 'Iron Oxide Crust (Chemical)',
    'dyn_basalt': 'Inner Basalt Revealed',
    'dyn_phys2':
        '**Physical Change (Weathering)**:\nRock is broken into smaller pieces by ice.\nIt is still the same rock material, just smaller.',
    'dyn_chem2':
        "**Chemical Change (Weathering)**:\nIron in the rock reacted with water and oxygen\nover time to form a new substance, Iron Oxide (rust).\nThis changed the rock's chemical composition and color.",

    'fb_wrong_tool': 'Not the right tool for this step!',
    'fb_drop_closer': 'Drop it closer to the target object!',
    'fb_match_lit': 'Match lit! Now DRAG it to the candle.',
    'fb_candle_lit': 'Candle lit! Heat begins to melt wax.',
    'fb_phys_wax': 'Physical Change: Wax changed state but identity is preserved.',
    'fb_capillary': 'Capillary action observed.',
    'fb_chem_lime': 'Chemical Change: Limewater turned milky!',
    'fb_exp_done': 'Experiment Concluded!',
    'fb_water_seep': 'Water seeps into rock cracks.',
    'fb_water_freeze': 'Water freezes and expands (Ice Wedging).',
    'fb_rock_broke': 'Rock broke! Physical Change complete.',
    'fb_chem_rust': 'Chemical Change: Oxidation (Rusting) occurred.',
    'fb_chip': 'Chipped revealing original dark rock!',
    'fb_cycle': 'Cycle {n}/3 complete. Repeat Rain!',

    // Sidebar readouts (not in the HTML UI, shown for clarity).
    'ctl_time_lapse': 'Time-lapse progress',
    'ctl_cycles': 'Freeze–thaw cycles',

    // Observation popup (HTML `summary` blocks).
    'sum1_intro': 'When a candle burns, multiple changes occur simultaneously:',
    'sum1_phys_title': 'Physical Change:',
    'sum1_phys_b1': 'Heat melts the solid wax into a liquid.',
    'sum1_phys_b2': 'The liquid is drawn up the wick (Capillary Action).',
    'sum1_phys_b3': 'Excess liquid drips and solidifies.',
    'sum1_phys_res_lbl': 'Result:',
    'sum1_phys_res': 'The material remains Wax. No new substance is formed.',
    'sum1_chem_title': 'Chemical Change:',
    'sum1_chem_b1': 'The vaporized wax reacts with Oxygen (Combustion).',
    'sum1_chem_b2': 'Produces Carbon Dioxide (CO₂) & Water.',
    'sum1_chem_res_lbl': 'Proof:',
    'sum1_chem_res': 'The clear limewater turned milky white, confirming a new substance.',
    'sum2_intro': 'Weathering forces change rocks continuously:',
    'sum2_phys_title': 'Physical Weathering:',
    'sum2_phys_b1': 'Water seeps into cracks.',
    'sum2_phys_b2': 'Water freezes into ice, expanding and widening cracks.',
    'sum2_phys_b3': 'Repeated cycles break the rock.',
    'sum2_phys_res_lbl': 'Result:',
    'sum2_phys_res': 'The rock changes size and shape, but remains basalt.',
    'sum2_chem_title': 'Chemical Weathering:',
    'sum2_chem_b1': 'Iron in the basalt reacts with water and oxygen over long periods.',
    'sum2_chem_b2': 'Oxidation forms a red crust (Rust).',
    'sum2_chem_res_lbl': 'Proof:',
    'sum2_chem_res':
        'Breaking the crust reveals a new reddish substance on the outside, different from the inner rock.',
  },
  'hi': {
    'app_title': 'संयुक्त भौतिक और रासायनिक परिवर्तन',
    'app_subtitle': 'कक्षा 7 • हमारे आस-पास के परिवर्तन: भौतिक और रासायनिक',
    'header_subtitle': 'कक्षा 7 • हमारे आस-पास के परिवर्तन',
    'obs_title': 'अवलोकन और विश्लेषण',
    'btn_hold': 'तेज़ करने के लिए दबाकर रखें',
    'zoom_title': 'बत्ती में केशिका क्रिया',
    'zoom_desc_pre': 'तरल मोम छिद्रपूर्ण बत्ती के ऊपर खिंच जाता है। यह गति एक ',
    'zoom_desc_bold': 'भौतिक परिवर्तन',
    'zoom_desc_post': ' है।',
    'btn_close_zoom': 'दृश्य बंद करें',
    'sc1_title': '1. मोमबत्ती का रासायनिक इतिहास',
    'sc2_title': '2. एक चट्टान का धीमा परिवर्तन',

    'lbl_inventory': 'सामग्री (INVENTORY)',
    'lbl_matchbox': 'माचिस',
    'lbl_magnifier': 'आवर्धक लेंस',
    'lbl_funnel': 'गैस कीप',
    'lbl_limewater': 'चूने का पानी',
    'lbl_rain_cloud': 'बारिश का बादल',
    'lbl_snowflake': 'बर्फ का टुकड़ा',
    'lbl_sun': 'सूरज',
    'lbl_hammer': 'हथौड़ा',

    'dyn_molten': 'पिघला हुआ तरल मोम\n(अवस्था परिवर्तन, भौतिक)',
    'dyn_drip': 'जमने वाली बूँद',
    'dyn_substance': 'नया पदार्थ बना\n(अवक्षेप)',
    'dyn_gas': 'पारदर्शी गैस के बुलबुले',
    'dyn_phys1':
        '**भौतिक परिवर्तन**: मोम अवस्था बदलता है\n(ठोस → तरल → ठोस) लेकिन अभी भी मोम है।\nकोई नया पदार्थ नहीं बनता है।',
    'dyn_chem1':
        '**रासायनिक परिवर्तन**: मोम का वाष्प ऑक्सीजन के साथ जलता है (दहन)\nऔर कार्बन डाइऑक्साइड (CO₂) तथा पानी जैसे नए पदार्थ बनाता है।\nयह अपरिवर्तनीय है।',
    'dyn_broken': 'चट्टान का टूटा हुआ टुकड़ा',
    'dyn_iron': 'आयरन ऑक्साइड परत (रासायनिक)',
    'dyn_basalt': 'भीतरी बेसाल्ट चट्टान दिखाई दी',
    'dyn_phys2':
        '**भौतिक परिवर्तन (अपक्षय)**:\nचट्टान बर्फ द्वारा छोटे टुकड़ों में टूट जाती है।\nयह अभी भी वही चट्टान सामग्री है, बस छोटी है।',
    'dyn_chem2':
        '**रासायनिक परिवर्तन (अपक्षय)**:\nचट्टान में मौजूद लोहे ने समय के साथ पानी और ऑक्सीजन के साथ\nप्रतिक्रिया करके एक नया पदार्थ, आयरन ऑक्साइड (जंग) बनाया।\nइससे चट्टान की रासायनिक संरचना और रंग बदल गया।',

    'fb_wrong_tool': 'इस चरण के लिए सही उपकरण नहीं है!',
    'fb_drop_closer': 'इसे लक्ष्य वस्तु के करीब छोड़ें!',
    'fb_match_lit': 'माचिस जल गई! अब इसे मोमबत्ती तक खींचें।',
    'fb_candle_lit': 'मोमबत्ती जल गई! गर्मी मोम को पिघलाना शुरू करती है।',
    'fb_phys_wax': 'भौतिक परिवर्तन: मोम ने अवस्था बदल ली लेकिन उसकी पहचान बनी हुई है।',
    'fb_capillary': 'केशिका क्रिया देखी गई।',
    'fb_chem_lime': 'रासायनिक परिवर्तन: चूने का पानी दूधिया हो गया!',
    'fb_exp_done': 'प्रयोग संपन्न हुआ!',
    'fb_water_seep': 'पानी चट्टान की दरारों में रिसता है।',
    'fb_water_freeze': 'पानी जमता है और फैलता है (बर्फ का फलाव)।',
    'fb_rock_broke': 'चट्टान टूट गई! भौतिक परिवर्तन पूरा हुआ।',
    'fb_chem_rust': 'रासायनिक परिवर्तन: ऑक्सीकरण (जंग लगना) हुआ।',
    'fb_chip': 'परत हटने से असली गहरी चट्टान दिखाई दी!',
    'fb_cycle': 'चक्र {n}/3 पूरा हुआ। फिर से बारिश करें!',

    'ctl_time_lapse': 'टाइम-लैप्स प्रगति',
    'ctl_cycles': 'जमने-पिघलने के चक्र',

    'sum1_intro': 'जब कोई मोमबत्ती जलती है, तो एक साथ कई परिवर्तन होते हैं:',
    'sum1_phys_title': 'भौतिक परिवर्तन (Physical Change):',
    'sum1_phys_b1': 'गर्मी से ठोस मोम पिघलकर तरल बन जाता है।',
    'sum1_phys_b2': 'तरल मोम बत्ती (धागे) के ऊपर खिंच जाता है (केशिका क्रिया)।',
    'sum1_phys_b3': 'अतिरिक्त तरल मोम नीचे टपकता है और जम जाता है।',
    'sum1_phys_res_lbl': 'परिणाम:',
    'sum1_phys_res': 'पदार्थ मोम ही रहता है। कोई नया पदार्थ नहीं बनता है।',
    'sum1_chem_title': 'रासायनिक परिवर्तन (Chemical Change):',
    'sum1_chem_b1': 'वाष्पीकृत मोम ऑक्सीजन के साथ प्रतिक्रिया करता है (दहन)।',
    'sum1_chem_b2': 'कार्बन डाइऑक्साइड (CO₂) और पानी उत्पन्न करता है।',
    'sum1_chem_res_lbl': 'प्रमाण:',
    'sum1_chem_res': 'साफ चूने का पानी दूधिया सफेद हो गया, जिससे एक नए पदार्थ की पुष्टि हुई।',
    'sum2_intro': 'अपक्षय की ताकतें चट्टानों को लगातार बदलती रहती हैं:',
    'sum2_phys_title': 'भौतिक अपक्षय (Physical Weathering):',
    'sum2_phys_b1': 'पानी दरारों में रिसता है।',
    'sum2_phys_b2': 'पानी जमकर बर्फ बन जाता है, जिससे दरारें फैलती और चौड़ी होती हैं।',
    'sum2_phys_b3': 'बार-बार होने वाले चक्र चट्टान को तोड़ देते हैं।',
    'sum2_phys_res_lbl': 'परिणाम:',
    'sum2_phys_res': 'चट्टान का आकार और रूप बदल जाता है, लेकिन वह बेसाल्ट ही रहती है।',
    'sum2_chem_title': 'रासायनिक अपक्षय (Chemical Weathering):',
    'sum2_chem_b1': 'बेसाल्ट में मौजूद लोहा लंबे समय तक पानी और ऑक्सीजन के साथ प्रतिक्रिया करता है।',
    'sum2_chem_b2': 'ऑक्सीकरण से लाल पपड़ी (जंग) बनती है।',
    'sum2_chem_res_lbl': 'प्रमाण:',
    'sum2_chem_res':
        'पपड़ी तोड़ने पर बाहर एक नया लाल पदार्थ दिखाई देता है, जो भीतरी चट्टान से अलग होता है।',
  },
};

// HTML `ScenariosDataTranslated`: title → concept, task → action,
// theory → observation (kept as data; the teacher accordion is removed).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'Dissect the process of a burning candle to identify distinct physical and chemical changes occurring simultaneously.',
      steps: [
        LabStep(
          concept: 'Light Candle',
          action: 'DRAG the Matchbox or lit match directly to the candle wick.',
          observation:
              'Lighting the wick provides thermal energy. This begins to melt the solid wax right beneath the flame.',
        ),
        LabStep(
          concept: 'Time-Lapse Melting',
          action: 'CLICK and HOLD the Fast Forward button on the left to accelerate melting.',
          observation:
              'As heat is applied, a liquid pool forms. Wax drips down and solidifies. This change of state is a Physical Change.',
        ),
        LabStep(
          concept: 'Magnifying Wick Action',
          action: 'DRAG the Magnifier from the tray to the melted wax pool.',
          observation:
              'Capillary action draws liquid wax up the wick where it will vaporize. This is another Physical Change.',
        ),
        LabStep(
          concept: 'Gas Collection Funnel',
          action:
              'DRAG the Gas Collection Funnel from the tray and PLACE it directly over the candle flame.',
          observation:
              'Combustion of wax vapor creates new substances. Passing the gas through limewater turns it milky, confirming Carbon Dioxide. This is a Chemical Change.',
        ),
        LabStep(
          concept: 'Final Summary',
          action: 'Observing results. Generating conclusion...',
          observation: 'Melting wax is physical. Burning vapor is chemical.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To observe how long-term natural forces cause both physical and chemical weathering in a rock.',
      steps: [
        LabStep(
          concept: 'Apply Moisture',
          action: 'DRAG the Rain Cloud from the tray and DROP it over the rock.',
          observation:
              'Rainwater naturally seeps into the tiny cracks and pores of rocks exposed to the environment.',
        ),
        LabStep(
          concept: 'Freeze Cycle',
          action: 'DRAG the Snowflake to the wet rock to freeze the water.',
          observation:
              "When temperature drops, water turns to ice and expands. This 'ice wedging' pushes cracks wider. This is a Physical Change.",
        ),
        LabStep(
          concept: 'Thaw and Repeat',
          action:
              'DRAG the Sun icon over the rock to melt the ice. REPEAT the Rain-Snow-Sun cycle 3 times.',
          observation: 'Ice melts. Repeated cycles break the rock.',
        ),
        LabStep(
          concept: 'Time-Lapse Weathering',
          action: 'CLICK and HOLD the Time Lapse button to simulate years of weathering.',
          observation:
              'Over decades, oxygen and water react with iron in the rock, causing oxidation (rusting). This forms a new substance—a Chemical Change.',
        ),
        LabStep(
          concept: 'Inspect the Crust',
          action:
              "DRAG the Geologist's Hammer tool and CLICK on the red-brown surface of the rock.",
          observation:
              'Chipping away the outer layer reveals that the red rust is a new chemical compound on the surface, while the inside remains basalt.',
        ),
        LabStep(
          concept: 'Result Conclusion',
          action: 'Observing results. Generating conclusion...',
          observation: 'Physical vs Chemical Weathering.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'मोमबत्ती के जलने की प्रक्रिया का विश्लेषण करके एक साथ होने वाले विभिन्न भौतिक और रासायनिक परिवर्तनों की पहचान करें।',
      steps: [
        LabStep(
          concept: 'मोमबत्ती जलाएं',
          action: 'माचिस को खींचकर सीधे मोमबत्ती की बत्ती पर लाएं।',
          observation:
              'बत्ती को जलाने से तापीय ऊर्जा मिलती है। इससे लौ के ठीक नीचे का ठोस मोम पिघलने लगता है।',
        ),
        LabStep(
          concept: 'पिघलने का टाइम-लैप्स',
          action:
              'पिघलने की गति बढ़ाने के लिए बाईं ओर फ़ास्ट फ़ॉरवर्ड बटन को क्लिक करके दबाए रखें।',
          observation:
              'जैसे-जैसे गर्मी लगती है, तरल मोम का एक कुंड बन जाता है। मोम नीचे टपकता है और जम जाता है। यह अवस्था परिवर्तन एक भौतिक परिवर्तन है।',
        ),
        LabStep(
          concept: 'बत्ती की क्रिया (आवर्धक लेंस)',
          action: 'ट्रे से आवर्धक लेंस खींचकर पिघले हुए मोम के कुंड पर लाएं।',
          observation:
              'केशिका क्रिया तरल मोम को बत्ती के ऊपर खींचती है जहाँ यह वाष्पीकृत हो जाएगा। यह एक और भौतिक परिवर्तन है।',
        ),
        LabStep(
          concept: 'गैस संग्रह कीप',
          action: 'ट्रे से गैस कीप खींचें और इसे सीधे मोमबत्ती की लौ के ऊपर रखें।',
          observation:
              'मोम वाष्प के दहन से नए पदार्थ बनते हैं। गैस को चूने के पानी से गुजारने पर वह दूधिया हो जाती है, जो कार्बन डाइऑक्साइड की पुष्टि करता है। यह एक रासायनिक परिवर्तन है।',
        ),
        LabStep(
          concept: 'अंतिम सारांश',
          action: 'परिणामों का अवलोकन। निष्कर्ष निकाला जा रहा है...',
          observation: 'मोम का पिघलना भौतिक है। वाष्प का जलना रासायनिक है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह देखने के लिए कि कैसे दीर्घकालिक प्राकृतिक ताकतें चट्टान में भौतिक और रासायनिक दोनों तरह के अपक्षय का कारण बनती हैं।',
      steps: [
        LabStep(
          concept: 'नमी लागू करें',
          action: 'ट्रे से बारिश के बादल को खींचकर चट्टान के ऊपर छोड़ दें।',
          observation:
              'बारिश का पानी प्राकृतिक रूप से पर्यावरण के संपर्क में आने वाली चट्टानों की छोटी दरारों और छिद्रों में रिसता है।',
        ),
        LabStep(
          concept: 'फ्रीज चक्र',
          action: 'पानी को जमाने के लिए बर्फ के टुकड़े को गीली चट्टान पर खींचें।',
          observation:
              "जब तापमान गिरता है, तो पानी बर्फ में बदल जाता है और फैलता है। यह 'आइस वेजिंग' दरारों को चौड़ा करती है। यह एक भौतिक परिवर्तन है।",
        ),
        LabStep(
          concept: 'पिघलना और दोहराना',
          action:
              'बर्फ पिघलाने के लिए सूरज आइकन को चट्टान के ऊपर खींचें। बारिश-बर्फ-सूरज चक्र को 3 बार दोहराएं।',
          observation: 'बर्फ पिघलती है। बार-बार होने वाले चक्र चट्टान को तोड़ देते हैं।',
        ),
        LabStep(
          concept: 'टाइम-लैप्स अपक्षय',
          action:
              'वर्षों के अपक्षय का अनुकरण करने के लिए टाइम लैप्स बटन को क्लिक करके दबाए रखें।',
          observation:
              'दशकों तक, ऑक्सीजन और पानी चट्टान में लोहे के साथ प्रतिक्रिया करते हैं, जिससे ऑक्सीकरण (जंग) होता है। यह एक नया पदार्थ बनाता है—एक रासायनिक परिवर्तन।',
        ),
        LabStep(
          concept: 'पपड़ी का निरीक्षण',
          action: 'भूविज्ञानी के हथौड़े को खींचें और चट्टान की लाल-भूरी सतह पर क्लिक करें।',
          observation:
              'बाहरी परत को तोड़ने से पता चलता है कि लाल जंग सतह पर एक नया रासायनिक यौगिक है, जबकि अंदर बेसाल्ट ही रहता है।',
        ),
        LabStep(
          concept: 'परिणाम निष्कर्ष',
          action: 'परिणामों का अवलोकन। निष्कर्ष निकाला जा रहा है...',
          observation: 'भौतिक बनाम रासायनिक अपक्षय।',
        ),
      ],
    ),
  ],
};

// ================================================================ PAINTER
//
// 2.5D illustration of the Three.js scene: wooden table, inventory tray,
// the candle on a petri dish with funnel / tube / limewater beaker
// (scenario 1) or the basalt boulder (scenario 2). Colours are the HTML hex
// values.

const Color _cTray = Color(0xFF64748B);
const Color _cCandle = Color(0xFF4ADE80);
const Color _cPetri = Color(0xFFCCFBF1);
const Color _cFunnel = Color(0xFF94A3B8);
const Color _cFunnelRim = Color(0xFFE2E8F0);
const Color _cBeakerGlass = Color(0xFFCCFBF1);
const Color _cBeakerRim = Color(0xFFA5F3FC);
const Color _cLime = Color(0xFFE0F2FE);
const Color _cRock = Color(0xFF334155);
const Color _cRust = Color(0xFF854D0E);
const Color _cChunkRust = Color(0xFF993312); // rgb(0.6, 0.2, 0.07)
const Color _cCore = Color(0xFF1E293B);
const Color _cChip = Color(0xFF9A3412);
const Color _cYellow = Color(0xFFEAB308);

const double _candleX = 456;
const double _candleBaseY = 384;
const Offset _beakerBottom = Offset(768, 392);
const double _beakerHalfW = 82;
const double _beakerH = 175;
const Offset _rockC = Offset(650, 326);

/// Beaker bubbles (HTML: 25 spheres with random start, speed and offset).
final List<List<double>> _bubbleSeeds = () {
  final r = math.Random(7);
  return List.generate(
    25,
    (_) => [r.nextDouble(), 1.5 + r.nextDouble(), (r.nextDouble() - 0.5) * 1.5, (r.nextDouble() - 0.5) * 1.5],
  );
}();

/// Rock speckles (stand-in for the procedural canvas texture).
final List<List<double>> _speckles = () {
  final r = math.Random(11);
  return List.generate(70, (_) => [r.nextDouble() * 2 - 1, r.nextDouble() * 2 - 1, r.nextDouble()]);
}();

class _A4Painter extends CustomPainter {
  _A4Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
  }) : super(repaint: repaint);

  final _A4Scene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  String _tr(String key) => labTr(_i18n, lang, key);
  double get _time => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-_crop.left, -_crop.top);
    _paintScene(canvas);
    canvas.restore();
  }

  void _paintScene(Canvas canvas) {
    _background(canvas, _design);
    _tray(canvas);
    if (scene.isCandle) {
      _candleScene(canvas);
    } else {
      _rockScene(canvas);
    }
    _hint(canvas);
    for (final t in scene.tools) {
      if (scene.drag == t || !scene.visible(t)) continue;
      _tool(canvas, t, scene.toolPos(t));
    }
    if (scene.isCandle && scene.funnelPlaced && scene.drag != _Tool.funnel) {
      // Inverted funnel sits in front of the flame.
      _funnel(canvas, scene.toolPos(_Tool.funnel), -math.pi / 2);
    }
    _effects(canvas);
    if (showLabels) _labels(canvas);
    final d = scene.drag;
    if (d != null) {
      _targetHighlight(canvas);
      final p = scene.dragPos;
      labGroundShadow(canvas, Offset(p.dx + 10, math.max(p.dy + 46, 250)), 90, 20, opacity: 0.28);
      _tool(canvas, d, p);
    }
  }

  // ---------------------------------------------------------- backdrop

  void _background(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    const tableY = 236.0;
    final wallTop = isDark ? const Color(0xFF020617) : const Color(0xFFE2E8F0);
    final wallLow = isDark ? const Color(0xFF111B33) : const Color(0xFFCBD5E1);
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, tableY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [wallTop, wallTop, wallLow],
          stops: const [0, 0.55, 1],
        ).createShader(const Rect.fromLTRB(0, -120, 1000, tableY)),
    );
    // Wooden table (HTML 0xaa7c50).
    final table = Rect.fromLTRB(bleed.left, tableY, bleed.right, bleed.bottom);
    canvas.drawRect(
      table,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8C6340), Color(0xFFAA7C50), Color(0xFFB98B5E)],
          stops: [0, 0.45, 1],
        ).createShader(const Rect.fromLTRB(0, tableY, 1000, 600)),
    );
    // Wood grain.
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF5C3B1E).withValues(alpha: 0.12);
    var y = tableY + 10;
    var gap = 9.0;
    while (y < 620) {
      final path = Path()..moveTo(bleed.left, y);
      for (var x = -400.0; x <= 1400; x += 40) {
        path.lineTo(x, y + 2.5 * math.sin(x / 90 + y / 13));
      }
      canvas.drawPath(path, grain);
      y += gap;
      gap *= 1.12;
    }
    // Back edge highlight and soft light pool from the key light.
    canvas.drawLine(
      Offset(bleed.left, tableY),
      Offset(bleed.right, tableY),
      Paint()
        ..strokeWidth = 2
        ..color = const Color(0xFFD2A679).withValues(alpha: 0.7),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, tableY - 26, bleed.right, tableY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: isDark ? 0.35 : 0.12)],
        ).createShader(const Rect.fromLTRB(0, tableY - 26, 1000, tableY)),
    );
    canvas.drawCircle(
      const Offset(560, 380),
      460,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFF5E6).withValues(alpha: 0.14),
          const Color(0xFFFFF5E6).withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: const Offset(560, 380), radius: 460)),
    );
  }

  /// Inventory tray (HTML 8.5 × 0.2 × 3 box with 0.4 high borders, 0x64748b).
  void _tray(Canvas canvas) {
    const top = Rect.fromLTRB(105, 424, 547, 508);
    labGroundShadow(canvas, const Offset(330, 520), 480, 30, opacity: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(105, 500, 547, 524),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()..color = labShade(_cTray, -0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(top, const Radius.circular(5)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cTray, 0.18), labShade(_cTray, 0.02)],
        ).createShader(top),
    );
    final inner = top.deflate(7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cTray, -0.32), labShade(_cTray, -0.12)],
        ).createShader(inner),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(top, const Radius.circular(5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = labShade(_cTray, 0.4).withValues(alpha: 0.8),
    );
  }

  // ------------------------------------------------------------ labels

  /// HTML `.custom-label` (black glass box, yellow left border, bold parts
  /// in yellow). [yellow] is the `.yellow-text` variant (yellow text, green
  /// border). [leader] draws a pointer line to the labelled object.
  Rect _label(
    Canvas canvas,
    String text,
    Offset anchor, {
    bool yellow = false,
    Alignment align = Alignment.bottomCenter,
    double size = 13,
    Offset? leader,
    double maxWidth = 430,
  }) {
    final base = TextStyle(
      color: yellow ? _cYellow : Colors.white,
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.4,
      fontFamily: LabFont.active.family,
      fontFamilyFallback: LabFont.active.fallback,
    );
    final parts = text.split('**');
    final spans = <TextSpan>[
      for (var i = 0; i < parts.length; i++)
        if (parts[i].isNotEmpty)
          TextSpan(
            text: parts[i],
            style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w800, color: _cYellow) : null,
          ),
    ];
    final tp = TextPainter(
      text: TextSpan(style: base, children: spans),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    const padH = 11.0, padV = 6.0, bar = 4.0;
    final w = tp.width + padH * 2 + bar;
    final h = tp.height + padV * 2;
    final double left =
        (anchor.dx - (align.x + 1) / 2 * w).clamp(_crop.left + 6, math.max(_crop.left + 6, _crop.right - 6 - w));
    final double top =
        (anchor.dy - (align.y + 1) / 2 * h).clamp(_crop.top + 6, math.max(_crop.top + 6, _crop.bottom - 6 - h));
    final rect = Rect.fromLTWH(left, top, w, h);
    if (leader != null) {
      final from = Offset(leader.dx.clamp(rect.left + 8, rect.right - 8), leader.dy.clamp(rect.top, rect.bottom));
      final lp = Paint()
        ..strokeWidth = 1.6
        ..color = (yellow ? const Color(0xFF4ADE80) : _cYellow).withValues(alpha: 0.85);
      canvas.drawLine(from, leader, lp);
      canvas.drawCircle(leader, 4, lp);
      canvas.drawCircle(leader, 2, Paint()..color = Colors.white);
    }
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(
      rr.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawRRect(rr, Paint()..color = const Color(0xD9000000));
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(
      Rect.fromLTWH(left, top, bar, h),
      Paint()..color = yellow ? const Color(0xFF4ADE80) : _cYellow,
    );
    canvas.restore();
    tp.paint(canvas, Offset(left + bar + padH, top + padV));
    return rect;
  }

  // ------------------------------------------------------ scenario 1

  void _candleScene(Canvas canvas) {
    final m = scene.melt;
    // HTML: candle top / wick / pool / flame move down by meltAmount = 1.5·p.
    final topY = _p3(-2, 3.6 - 1.5 * m, -1).dy;
    _petri(canvas);
    _candle(canvas, topY, m);
    if (scene.candleLit) _candleFlame(canvas, topY);
    _beaker(canvas);
  }

  /// Petri dish under the candle (0xccfbf1, 50% opacity).
  void _petri(Canvas canvas) {
    const c = Offset(_candleX, 388);
    labGroundShadow(canvas, c.translate(4, 10), 224, 40, opacity: 0.28);
    final top = Rect.fromCenter(center: c, width: 206, height: 56);
    final bottom = top.shift(const Offset(0, 9));
    final side = Path()
      ..addArc(bottom, 0, math.pi)
      ..lineTo(top.left, top.center.dy)
      ..arcTo(top, math.pi, -math.pi, false)
      ..close();
    canvas.drawPath(side, Paint()..color = _cPetri.withValues(alpha: 0.6));
    canvas.drawOval(top, Paint()..color = _cPetri.withValues(alpha: 0.42));
    canvas.drawOval(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.65),
    );
    canvas.drawArc(
      top.deflate(6),
      math.pi * 1.1,
      math.pi * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  /// Green candle (CylinderGeometry 0.6 / 0.7 × 3.5, 0x4ade80) with molten
  /// pool, solidifying drip and wick.
  void _candle(Canvas canvas, double topY, double m) {
    const baseY = _candleBaseY;
    const rTop = 31.0, rBot = 36.0;
    labGroundShadow(canvas, const Offset(_candleX + 8, baseY + 2), 96, 18, opacity: 0.35);
    final body = Path()
      ..moveTo(_candleX - rTop, topY)
      ..lineTo(_candleX - rBot, baseY)
      ..arcTo(Rect.fromCenter(center: const Offset(_candleX, baseY), width: rBot * 2, height: 18), math.pi,
          -math.pi, false)
      ..lineTo(_candleX + rTop, topY)
      ..close();
    final rect = Rect.fromLTRB(_candleX - rBot, topY, _candleX + rBot, baseY);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_cCandle, -0.4),
          labShade(_cCandle, 0.25),
          _cCandle,
          labShade(_cCandle, -0.45),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(rect),
    );
    if (scene.candleLit) {
      // Flame light (PointLight 0xffcc00) warming the upper body.
      canvas.drawPath(
        body,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x66FFCC00), Color(0x00FFCC00)],
          ).createShader(Rect.fromLTRB(rect.left, topY, rect.right, topY + 100)),
      );
    }
    final cap = Rect.fromCenter(center: Offset(_candleX, topY), width: rTop * 2, height: 16);
    canvas.drawOval(cap, Paint()..color = labShade(_cCandle, 0.3));
    canvas.drawOval(
      cap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(_cCandle, -0.3).withValues(alpha: 0.5),
    );

    // Molten pool (HTML pool scale 1 + 0.2·p).
    if (m > 0) {
      final k = 1 + 0.2 * m;
      final pool = Rect.fromCenter(center: Offset(_candleX, topY), width: 56 * k, height: 14 * k);
      canvas.drawOval(
        pool,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.4),
            colors: [Color(0xFFDCFCE7), Color(0xFF86EFAC), Color(0xFF3FCF73)],
          ).createShader(pool),
      );
      canvas.drawOval(
        pool,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.55),
      );
      canvas.drawOval(
        Rect.fromCenter(center: pool.center.translate(-10, -2), width: 14, height: 3.5),
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }

    // Solidifying drip (visible once p > 0.4).
    if (m > 0.4) {
      final dripWorldY = (3.0 - 1.5 * m) - (m - 0.4) * 2.5;
      final dripY = math.min(_p3(-1.3, dripWorldY, -0.6).dy, baseY - 8);
      double sideX(double y) => _candleX + rTop + (rBot - rTop) * ((y - topY) / (baseY - topY)).clamp(0.0, 1.0);
      final a = Offset(sideX(topY + 3) - 2, topY + 3);
      final b = Offset(sideX(dripY) + 1, dripY);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF86EFAC), labShade(_cCandle, -0.12)],
          ).createShader(Rect.fromPoints(a, b.translate(1, 1))),
      );
      final blob = Path()
        ..moveTo(b.dx - 5, b.dy - 4)
        ..quadraticBezierTo(b.dx - 7, b.dy + 7, b.dx, b.dy + 9)
        ..quadraticBezierTo(b.dx + 7, b.dy + 7, b.dx + 5, b.dy - 4)
        ..close();
      canvas.drawPath(blob, Paint()..color = labShade(_cCandle, -0.12));
      canvas.drawLine(
        a.translate(-1.5, 3),
        b.translate(-2, -4),
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.45),
      );
    }

    // Wick (0x111111).
    final wickTop = topY - 15;
    canvas.drawLine(
      Offset(_candleX, topY + 3),
      Offset(_candleX + 1, wickTop),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF111111),
    );
    if (scene.candleLit) {
      canvas.drawCircle(Offset(_candleX + 1, wickTop), 2.4, Paint()..color = const Color(0xFFFF7A1A));
    }
  }

  void _candleFlame(Canvas canvas, double topY) {
    final grow = Curves.easeOut.transform(((_time - scene.candleLitAt) / 0.5).clamp(0.0, 1.0));
    final flick = math.sin(_time * 25) * 0.05 + math.cos(_time * 18) * 0.05;
    final base = Offset(_candleX + 1, topY - 8);
    labGlow(canvas, base.translate(0, -28), 150 * (1 + flick), const Color(0xFFFFCC00), intensity: 0.3 * grow);
    labGlow(canvas, const Offset(_candleX, 390), 120, const Color(0xFFFFCC00), intensity: 0.12 * grow);
    labFlame(canvas, base, 64 * (1 + flick * 2) * (0.35 + 0.65 * grow), _time);
  }

  /// Funnel-to-limewater tube (CatmullRomCurve3 through the HTML points).
  Path _tubePath() {
    final pts = [
      _p3(-2, 5.5, -1),
      _p3(-0.5, 5.0, -1),
      _p3(2.5, 4.0, -1),
      _p3(4, 3.5, -1),
      Offset(_beakerBottom.dx, _beakerBottom.dy - 14),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[math.max(i - 1, 0)];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = pts[math.min(i + 2, pts.length - 1)];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  /// Limewater beaker (open cylinder r 1.6 × 3.5, glass 0xccfbf1 @ 0.3,
  /// rim 0xa5f3fc) with tube, gas bubbles and milky precipitate.
  void _beaker(Canvas canvas) {
    const b = _beakerBottom;
    const hw = _beakerHalfW;
    const topY = 392.0 - _beakerH;
    const eh = 26.0;
    final rimRect = Rect.fromCenter(center: const Offset(768, topY), width: hw * 2, height: eh);
    final baseRect = Rect.fromCenter(center: b, width: hw * 2, height: eh);
    labGroundShadow(canvas, b.translate(10, 4), hw * 2 + 30, 26, opacity: 0.3);

    final body = Path()
      ..moveTo(b.dx - hw, topY)
      ..lineTo(b.dx - hw, b.dy)
      ..arcTo(baseRect, math.pi, -math.pi, false)
      ..lineTo(b.dx + hw, topY)
      ..arcTo(rimRect, 0, -math.pi, false)
      ..close();
    canvas.drawPath(body, Paint()..color = _cBeakerGlass.withValues(alpha: 0.10));

    // Tube (behind the liquid so milky water hides its lower part).
    final tube = _tubePath();
    if (scene.funnelPlaced) {
      canvas.drawPath(
        tube,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = _cFunnel.withValues(alpha: 0.8),
      );
      canvas.drawPath(
        tube,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35),
      );
    }

    // Limewater: clear (0xe0f2fe @ 0.2) → milky white (@ 0.9).
    final lime = scene.lime;
    const waterTop = 392.0 - 100;
    final waterColor = Color.lerp(
      const Color(0xFF7DD3FC).withValues(alpha: 0.16),
      Colors.white.withValues(alpha: 0.92),
      lime,
    )!;
    final waterInset = baseRect.deflate(4);
    final water = Path()
      ..moveTo(b.dx - hw + 4, waterTop)
      ..lineTo(b.dx - hw + 4, b.dy)
      ..arcTo(waterInset, math.pi, -math.pi, false)
      ..lineTo(b.dx + hw - 4, waterTop)
      ..close();
    canvas.drawPath(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(waterColor, 0.1), waterColor],
        ).createShader(Rect.fromLTRB(b.dx - hw, waterTop, b.dx + hw, b.dy + 12)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(768, waterTop), width: hw * 2 - 8, height: eh - 6),
      Paint()..color = Color.lerp(_cLime.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.95), lime)!,
    );
    if (lime > 0) {
      // Suspended precipitate (CaCO₃) specks.
      final r = math.Random(5);
      final speck = Paint()..color = Colors.white.withValues(alpha: 0.9 * lime);
      for (var i = 0; i < 40; i++) {
        final x = b.dx + (r.nextDouble() - 0.5) * (hw * 2 - 20);
        final y = waterTop + 10 + r.nextDouble() * 86 + 2 * math.sin(_time * 1.5 + i);
        canvas.drawCircle(Offset(x, y), 1.2 + r.nextDouble() * 1.6, speck);
      }
    }

    // Gas bubbles rising through the limewater.
    if (scene.funnelPlaced) {
      final t0 = scene.limeStart < 0 ? 0.0 : scene.limeStart;
      for (final s in _bubbleSeeds) {
        final yLocal = -1.6 + ((s[0] + s[1] * (_time - t0)) % 1.4);
        final worldY = 1.75 + yLocal;
        final c = Offset(b.dx + s[2] * 46, b.dy - worldY * 50 + s[3] * 8);
        labSphere(canvas, c, 6.5, Colors.white, shade: 0.25);
      }
      // Flowing tube bubbles (3, phase 0 / 0.33 / 0.66, speed 0.4).
      final metric = tube.computeMetrics().first;
      for (var k = 0; k < 3; k++) {
        final f = (_time * 0.4 + k * 0.33) % 1;
        final tan = metric.getTangentForOffset(metric.length * f);
        if (tan != null) {
          canvas.drawCircle(tan.position, 4, Paint()..color = Colors.white.withValues(alpha: 0.85));
        }
      }
    }

    // Front glass, rim and highlights.
    final front = Path()
      ..moveTo(b.dx - hw, topY)
      ..lineTo(b.dx - hw, b.dy)
      ..arcTo(baseRect, math.pi, -math.pi, false)
      ..lineTo(b.dx + hw, topY);
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _cBeakerGlass.withValues(alpha: 0.8),
    );
    canvas.drawOval(
      rimRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _cBeakerRim,
    );
    canvas.drawLine(
      Offset(b.dx - hw + 14, topY + 18),
      Offset(b.dx - hw + 14, b.dy - 14),
      Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  // ------------------------------------------------------ scenario 2

  /// Flattened boulder (DodecahedronGeometry(2, 2) scaled 1.3 × 0.8 × 1.1).
  Path _rockPath(double k) {
    final pts = <Offset>[];
    const n = 48;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final r = 1 + 0.045 * math.sin(3 * a + 0.6) + 0.03 * math.sin(5 * a + 2.1) + 0.02 * math.sin(8 * a + 0.3);
      final sy = math.sin(a) > 0 ? 0.92 : 1.0;
      pts.add(Offset(_rockC.dx + math.cos(a) * 136 * k * r, _rockC.dy + math.sin(a) * 84 * k * r * sy));
    }
    final path = Path();
    for (var i = 0; i < n; i++) {
      final p = pts[i];
      final q = pts[(i + 1) % n];
      final mid = (p + q) / 2;
      if (i == 0) path.moveTo(mid.dx, mid.dy);
      final next = pts[(i + 1) % n];
      final mid2 = (next + pts[(i + 2) % n]) / 2;
      path.quadraticBezierTo(next.dx, next.dy, mid2.dx, mid2.dy);
    }
    return path..close();
  }

  Offset _tex(double u, double v) => Offset(_rockC.dx + (u - 256) * 0.5, _rockC.dy + 4 + (v - 270) * 0.34);

  /// The HTML crack texture: main vertical crack with four branches.
  void _cracks(Canvas canvas) {
    final color = switch (scene.crack) {
      1 => const Color(0xFF3B82F6),
      2 => Colors.white,
      _ => const Color(0xFF0F172A),
    };
    final w = switch (scene.crack) {
      1 => 5.0,
      2 => 6.5,
      _ => 4.5,
    };
    const segs = [
      [256.0, 100.0, 256.0, 300.0],
      [256.0, 200.0, 150.0, 150.0],
      [256.0, 250.0, 380.0, 350.0],
      [256.0, 300.0, 200.0, 450.0],
      [256.0, 300.0, 350.0, 420.0],
    ];
    final path = Path();
    var seed = 3;
    for (final s in segs) {
      final a = _tex(s[0], s[1]);
      final b = _tex(s[2], s[3]);
      path.moveTo(a.dx, a.dy);
      const parts = 6;
      final d = b - a;
      final nrm = Offset(-d.dy, d.dx) / d.distance;
      for (var i = 1; i <= parts; i++) {
        seed = (seed * 37 + 11) % 97;
        final j = i == parts ? 0.0 : (seed / 97 - 0.5) * 7;
        final p = a + d * (i / parts) + nrm * j;
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w + 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  Path _blob(Offset c, double rx, double ry, int seed, {double rot = 0}) {
    final r = math.Random(seed);
    final path = Path();
    const n = 9;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2 + rot;
      final k = 0.78 + r.nextDouble() * 0.3;
      final p = c + Offset(math.cos(a) * rx * k, math.sin(a) * ry * k);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  void _rockScene(Canvas canvas) {
    final k = scene.expanded ? 1.015 : 1.0; // HTML rock.scale 1.32 / 1.3
    final base = Color.lerp(_cRock, _cRust, scene.rust)!;
    labGroundShadow(canvas, Offset(_rockC.dx + 14, 404), 330, 46, opacity: 0.45);
    final rock = _rockPath(k);
    final bounds = rock.getBounds();
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(-2000, -2000, 3000, 404));
    canvas.drawPath(
      rock,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.55),
          radius: 0.95,
          colors: [labShade(base, 0.3), base, labShade(base, -0.5)],
          stops: const [0, 0.5, 1],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipPath(rock);
    for (final s in _speckles) {
      final p = _rockC + Offset(s[0] * 128, s[1] * 78);
      canvas.drawCircle(
        p,
        1.4 + s[2] * 2.4,
        Paint()..color = (s[2] > 0.5 ? Colors.white : Colors.black).withValues(alpha: 0.10 + 0.08 * s[2]),
      );
    }
    // Soft facets of the dodecahedron.
    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawArc(bounds.deflate(18).shift(const Offset(-30, 10)), math.pi * 1.1, 0.9, false, facet);
    canvas.drawArc(bounds.deflate(26).shift(const Offset(40, 18)), math.pi * 1.6, 0.8, false, facet);
    if (scene.rust > 0) {
      // Rust patches (iron oxide) growing during the time-lapse.
      for (var i = 0; i < 7; i++) {
        final c = _rockC + Offset(math.cos(i * 1.7) * 80, math.sin(i * 2.3) * 45 - 12);
        canvas.drawPath(
          _blob(c, 30, 18, 20 + i),
          Paint()
            ..color = _cChip.withValues(alpha: 0.35 * scene.rust)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }
    _cracks(canvas);
    if (scene.broken) {
      // Scar where the piece broke off.
      final scar = _blob(_rockC + const Offset(110, 20), 34, 24, 4);
      canvas.drawPath(scar, Paint()..color = labShade(base, -0.45));
      canvas.drawPath(
        scar,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = labShade(base, 0.25).withValues(alpha: 0.6),
      );
    }
    if (scene.chipped) _darkCore(canvas);
    canvas.restore();
    canvas.drawPath(
      rock,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = labShade(base, -0.55).withValues(alpha: 0.7),
    );
    canvas.restore();
    // Contact line on the table.
    canvas.drawLine(
      _rockC + const Offset(-115, 77),
      _rockC + const Offset(120, 77),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    _chunk(canvas);
    if (scene.chipped) _rustChip(canvas);
  }

  /// Exposed inner dark basalt (CylinderGeometry r 0.5, 0x1e293b).
  void _darkCore(Canvas canvas) {
    final c = (_rockC + const Offset(0, -37));
    final crater = _blob(c, 30, 19, 9);
    canvas.drawPath(
      crater,
      Paint()
        ..shader = RadialGradient(colors: [
          labShade(_cCore, -0.4),
          _cCore,
          labShade(_cCore, 0.2),
        ], stops: const [0, 0.6, 1]).createShader(Rect.fromCenter(center: c, width: 60, height: 38)),
    );
    canvas.drawPath(
      crater,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _cChip,
    );
  }

  /// The piece of rock at the right edge; falls off after 3 freeze–thaw
  /// cycles (HTML chunk 0x334155 → rusted colour during the time-lapse).
  void _chunk(Canvas canvas) {
    final col = Color.lerp(_cRock, _cChunkRust, scene.rust)!;
    final attached = (_rockC + const Offset(104, 20)) + Offset(scene.expanded ? 2.6 : 0, 0);
    var c = attached;
    var rot = 0.0;
    if (scene.broken) {
      final v = ((_time - scene.brokenAt) / 0.7).clamp(0.0, 1.0);
      final dest = (_rockC + const Offset(104, 84)) + const Offset(16, 0);
      c = Offset(
        attached.dx + (dest.dx - attached.dx) * Curves.easeOut.transform(v),
        attached.dy + (dest.dy - attached.dy) * Curves.bounceOut.transform(v),
      );
      rot = math.pi / 4 * Curves.easeOut.transform(v);
      labGroundShadow(canvas, Offset(c.dx, 418), 80 * v, 14, opacity: 0.35 * v);
    }
    final path = _blob(Offset.zero, 37, 25, 2);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [labShade(col, 0.3), col, labShade(col, -0.45)],
        ).createShader(const Rect.fromLTRB(-37, -25, 37, 25)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = labShade(col, -0.6),
    );
    canvas.restore();
  }

  /// Rust chip knocked off by the hammer (0x9a3412) dropping to the table.
  void _rustChip(Canvas canvas) {
    final v = ((_time - scene.chippedAt) / 0.5).clamp(0.0, 1.0);
    final from = (_rockC + const Offset(0, -42));
    final to = (_rockC + const Offset(0, 78)) + const Offset(-22, 6);
    final c = Offset(
      from.dx + (to.dx - from.dx) * v,
      from.dy + (to.dy - from.dy) * Curves.bounceOut.transform(v),
    );
    if (v > 0.5) labGroundShadow(canvas, Offset(c.dx, to.dy + 8), 34, 8, opacity: 0.4);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(v * 2.2);
    final chip = _blob(Offset.zero, 17, 13, 15);
    canvas.drawPath(
      chip,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [labShade(_cChip, 0.3), _cChip, labShade(_cChip, -0.4)],
        ).createShader(const Rect.fromLTRB(-17, -13, 17, 13)),
    );
    canvas.drawPath(
      chip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = labShade(_cChip, -0.5),
    );
    canvas.restore();
  }

  // -------------------------------------------------------------- tools

  /// Lifted tools are drawn upright (the HTML resets the rotation while a
  /// tool is dragged); tools resting on the tray lie flat.
  bool _lifted(_Tool t) {
    if (scene.drag == t) return true;
    final m = scene.moves[t];
    return m != null && _time < m.start + m.dur;
  }

  void _tool(Canvas canvas, _Tool t, Offset c) {
    final lifted = _lifted(t);
    switch (t) {
      case _Tool.matchbox:
        _matchbox(canvas, c, lifted);
      case _Tool.matchstick:
        _matchstick(canvas, c);
      case _Tool.magnifier:
        _magnifier(canvas, c, lifted);
      case _Tool.funnel:
        if (scene.funnelPlaced && scene.drag != t) return;
        if (!lifted) labGroundShadow(canvas, c.translate(0, 30), 120, 20, opacity: 0.3);
        _funnel(canvas, c, lifted ? math.pi / 2 : 0, radius: lifted ? 40 : 34);
      case _Tool.cloud:
        _icon(canvas, c, 98, lifted, _drawCloud);
      case _Tool.snow:
        _icon(canvas, c, 86, lifted, _drawSnow);
      case _Tool.sun:
        _icon(canvas, c, 84, lifted, _drawSun);
      case _Tool.hammer:
        _hammer(canvas, c, lifted);
    }
  }

  /// Red matchbox (outer 0xcc2222, inner drawer 0xeebb99, strike strip 0x221111).
  void _matchbox(Canvas canvas, Offset c, bool lifted) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (lifted) canvas.scale(1.08);
    if (!lifted) labGroundShadow(canvas, const Offset(4, 24), 100, 18, opacity: 0.4);
    const red = Color(0xFFCC2222);
    const drawer = Color(0xFFEEBB99);
    const strike = Color(0xFF221111);
    canvas.drawRect(const Rect.fromLTRB(-40, 8, 40, 24), Paint()..color = labShade(red, -0.35));
    canvas.drawRect(const Rect.fromLTRB(-33, 10, 33, 27), Paint()..color = drawer);
    canvas.drawRect(const Rect.fromLTRB(-33, 10, 33, 13), Paint()..color = labShade(drawer, -0.25));
    final top = Path()
      ..moveTo(-35, -24)
      ..lineTo(35, -24)
      ..lineTo(40, 8)
      ..lineTo(-40, 8)
      ..close();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(red, 0.18), red],
        ).createShader(const Rect.fromLTRB(-40, -24, 40, 8)),
    );
    final stripL = Path()
      ..moveTo(-35, -24)
      ..lineTo(-29, -24)
      ..lineTo(-33, 8)
      ..lineTo(-40, 8)
      ..close();
    final stripR = Path()
      ..moveTo(35, -24)
      ..lineTo(29, -24)
      ..lineTo(33, 8)
      ..lineTo(40, 8)
      ..close();
    canvas.drawPath(stripL, Paint()..color = strike);
    canvas.drawPath(stripR, Paint()..color = strike);
    // Label on the lid: a little flame in a yellow disc.
    canvas.drawCircle(const Offset(0, -8), 10, Paint()..color = const Color(0xFFFACC15));
    final logo = Path()
      ..moveTo(0, -16)
      ..quadraticBezierTo(6, -8, 3, -3)
      ..quadraticBezierTo(0, -1, -3, -3)
      ..quadraticBezierTo(-6, -8, 0, -16)
      ..close();
    canvas.drawPath(logo, Paint()..color = red);
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(red, -0.5),
    );
    canvas.restore();
  }

  /// Matchstick (0xddccaa stick, 0xcc2222 head → 0x111111 when lit) with
  /// its small flickering flame.
  void _matchstick(Canvas canvas, Offset c) {
    final inBox = scene.drag != _Tool.matchstick;
    canvas.save();
    if (inBox) {
      // Emerges from the matchbox.
      canvas.clipRect(Rect.fromLTRB(-2000, -2000, 3000, _home[_Tool.matchbox]!.dy - 6));
    }
    canvas.drawLine(
      c.translate(0, 38),
      c.translate(0, -31),
      Paint()
        ..strokeWidth = 5
        ..color = const Color(0xFFDDCCAA),
    );
    canvas.drawLine(
      c.translate(-1.2, 38),
      c.translate(-1.2, -31),
      Paint()
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.4),
    );
    final lit = scene.matchState == 2;
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, -35), width: 9, height: 12),
      Paint()..color = lit ? const Color(0xFF111111) : const Color(0xFFCC2222),
    );
    canvas.restore();
    if (lit) {
      final flick = math.sin(_time * 35) * 0.05;
      labFlame(canvas, c.translate(0, -37), 30 * (1 + flick), _time + 1.3);
    }
  }

  /// Magnifier (rim 0x333333, handle 0x111111, clear glass).
  void _magnifier(Canvas canvas, Offset c, bool lifted) {
    const rim = Color(0xFF333333);
    const handle = Color(0xFF111111);
    final glass = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [Colors.white.withValues(alpha: 0.45), const Color(0xFFBFDBFE).withValues(alpha: 0.18)],
      ).createShader(Rect.fromCircle(center: c, radius: 28));
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = rim;
    if (lifted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(c.dx - 4.5, c.dy + 25, c.dx + 4.5, c.dy + 72), const Radius.circular(4)),
        Paint()..color = handle,
      );
      canvas.drawCircle(c, 27, glass);
      canvas.drawCircle(c, 27, rimPaint);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: 19),
        math.pi * 1.1,
        math.pi * 0.4,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.7),
      );
    } else {
      labGroundShadow(canvas, c.translate(8, 10), 92, 20, opacity: 0.35);
      canvas.drawLine(
        c.translate(20, -9),
        c.translate(44, -28),
        Paint()
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = handle,
      );
      final ring = Rect.fromCenter(center: c, width: 56, height: 26);
      canvas.drawOval(ring, glass);
      canvas.drawOval(ring, rimPaint);
      canvas.drawArc(
        ring.deflate(7),
        math.pi * 1.05,
        math.pi * 0.45,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  /// Glass funnel (open cone 0.8 → 0.1 + stem, 0x94a3b8, rim 0xe2e8f0).
  /// [angle] turns the mouth → stem axis: 0 lying on the tray, π/2 upright
  /// while dragged, −π/2 inverted over the flame.
  void _funnel(Canvas canvas, Offset joint, double angle, {double radius = 40}) {
    final big = radius;
    const r = 5.0, l1 = 50.0, l2 = 50.0;
    canvas.save();
    canvas.translate(joint.dx, joint.dy);
    canvas.rotate(angle);
    final across = Rect.fromLTRB(-l1, -big, l2, big);
    final shade = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        labShade(_cFunnel, -0.3).withValues(alpha: 0.92),
        labShade(_cFunnel, 0.4).withValues(alpha: 0.92),
        _cFunnel.withValues(alpha: 0.9),
        labShade(_cFunnel, -0.4).withValues(alpha: 0.92),
      ],
      stops: const [0, 0.3, 0.6, 1],
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, -r, l2, r),
      Paint()..shader = shade.createShader(const Rect.fromLTRB(0, -r, l2, r)),
    );
    final cone = Path()
      ..moveTo(-l1, -big)
      ..lineTo(0, -r)
      ..lineTo(0, r)
      ..lineTo(-l1, big)
      ..close();
    canvas.drawPath(cone, Paint()..shader = shade.createShader(across));
    final mouth = Rect.fromCenter(center: const Offset(-l1, 0), width: big * 0.5, height: big * 2);
    canvas.drawOval(mouth, Paint()..color = labShade(_cFunnel, -0.45).withValues(alpha: 0.85));
    canvas.drawOval(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = _cFunnelRim,
    );
    canvas.drawLine(
      Offset(-l1 + 6, -big * 0.55),
      const Offset(-4, -r + 1),
      Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.restore();
  }

  /// SVG icons from the HTML (100 × 100 viewBox). Lying flat on the tray
  /// they are squashed vertically; lifted they face the viewer.
  void _icon(Canvas canvas, Offset c, double size, bool lifted, void Function(Canvas) draw) {
    if (!lifted) labGroundShadow(canvas, c.translate(4, size * 0.2), size * 0.95, 18, opacity: 0.3);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    final k = size / 100;
    canvas.scale(k, lifted ? k : k * 0.62);
    canvas.translate(-50, -52);
    draw(canvas);
    canvas.restore();
  }

  void _drawCloud(Canvas canvas) {
    const blue = Color(0xFF60A5FA);
    final body = Path()
      ..moveTo(25, 65)
      ..cubicTo(15, 65, 10, 55, 15, 45)
      ..cubicTo(15, 35, 25, 30, 35, 35)
      ..cubicTo(40, 20, 60, 20, 70, 35)
      ..cubicTo(85, 35, 90, 50, 85, 60)
      ..cubicTo(80, 70, 65, 65, 65, 65)
      ..lineTo(25, 65)
      ..close();
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black;
    for (final x0 in const [30.0, 50.0, 70.0]) {
      final drop = Path()
        ..moveTo(x0, 75)
        ..quadraticBezierTo(x0, 85, x0 + 5, 85)
        ..quadraticBezierTo(x0 + 10, 85, x0 + 10, 75)
        ..quadraticBezierTo(x0 + 5, 65, x0, 75)
        ..close();
      canvas.drawPath(drop, Paint()..color = blue);
      canvas.drawPath(drop, outline..strokeWidth = 3);
    }
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF93C5FD), blue],
        ).createShader(const Rect.fromLTRB(10, 22, 90, 66)),
    );
    canvas.drawPath(body, outline..strokeWidth = 4);
  }

  void _drawSnow(Canvas canvas) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF38BDF8);
    final path = Path()
      ..moveTo(50, 10)
      ..lineTo(50, 90)
      ..moveTo(15, 30)
      ..lineTo(85, 70)
      ..moveTo(15, 70)
      ..lineTo(85, 30)
      ..moveTo(50, 30)..lineTo(40, 20)..moveTo(50, 30)..lineTo(60, 20)
      ..moveTo(50, 70)..lineTo(40, 80)..moveTo(50, 70)..lineTo(60, 80)
      ..moveTo(32, 40)..lineTo(20, 40)..moveTo(32, 40)..lineTo(25, 30)
      ..moveTo(68, 60)..lineTo(80, 60)..moveTo(68, 60)..lineTo(75, 70)
      ..moveTo(32, 60)..lineTo(20, 60)..moveTo(32, 60)..lineTo(25, 70)
      ..moveTo(68, 40)..lineTo(80, 40)..moveTo(68, 40)..lineTo(75, 30);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawPath(path, p);
  }

  void _drawSun(Canvas canvas) {
    const amber = Color(0xFFFBBF24);
    final rays = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = amber;
    const lines = [
      [50.0, 10.0, 50.0, 20.0], [50.0, 80.0, 50.0, 90.0], [10.0, 50.0, 20.0, 50.0], [80.0, 50.0, 90.0, 50.0], //
      [22.0, 22.0, 29.0, 29.0], [78.0, 78.0, 71.0, 71.0], [22.0, 78.0, 29.0, 71.0], [78.0, 22.0, 71.0, 29.0],
    ];
    for (final l in lines) {
      canvas.drawLine(Offset(l[0], l[1]), Offset(l[2], l[3]), rays);
    }
    labGlow(canvas, const Offset(50, 50), 34, amber, intensity: 0.35);
    labSphere(canvas, const Offset(50, 50), 22, amber, shade: 0.3);
  }

  /// Geologist's hammer (handle 0x854d0e, head 0x666666).
  void _hammer(Canvas canvas, Offset c, bool lifted) {
    const wood = Color(0xFF854D0E);
    const steel = Color(0xFF666666);
    Paint woodPaint(Rect r) => Paint()
      ..shader = LinearGradient(colors: [labShade(wood, -0.2), labShade(wood, 0.3), labShade(wood, -0.25)])
          .createShader(r);
    if (lifted) {
      final h = Rect.fromLTRB(c.dx - 5, c.dy - 30, c.dx + 5, c.dy + 46);
      canvas.drawRRect(RRect.fromRectAndRadius(h, const Radius.circular(4)), woodPaint(h));
      labBox3D(canvas, Rect.fromCenter(center: c.translate(-3, -36), width: 46, height: 17), 7, steel);
    } else {
      labGroundShadow(canvas, c.translate(4, 12), 70, 30, opacity: 0.35);
      final h = Rect.fromLTRB(c.dx - 4.5, c.dy - 30, c.dx + 4.5, c.dy + 10);
      canvas.drawRRect(RRect.fromRectAndRadius(h, const Radius.circular(4)), woodPaint(h));
      labBox3D(canvas, Rect.fromCenter(center: c.translate(-3, 16), width: 46, height: 12), 9, steel, angle: -1.2);
    }
  }

  // ------------------------------------------------------ guidance

  _Tool? get _expectedTool {
    if (!scene.idle || scene.drag != null) return null;
    final st = scene.step;
    if (scene.isCandle) {
      if (st == 1 && !scene.candleLit) {
        if (scene.matchState == 2 && !scene.matchHidden) return _Tool.matchstick;
        if (scene.matchState == 0) return _Tool.matchbox;
        return null;
      }
      if (st == 3) return _Tool.magnifier;
      if (st == 4 && !scene.funnelPlaced) return _Tool.funnel;
      return null;
    }
    return switch (st) {
      1 => _Tool.cloud,
      2 => _Tool.snow,
      3 => _Tool.sun,
      5 => _Tool.hammer,
      _ => null,
    };
  }

  /// Soft pulsing glow under the tool the current step needs.
  void _hint(Canvas canvas) {
    final t = _expectedTool;
    if (t == null) return;
    final p = scene.toolPos(t);
    final pulse = 0.5 + 0.5 * math.sin(_time * 4);
    final rect = Rect.fromCenter(center: p.translate(0, t == _Tool.matchstick ? 0 : 6), width: 116, height: t == _Tool.matchstick ? 110 : 64);
    canvas.drawOval(
      rect,
      Paint()
        ..color = _cYellow.withValues(alpha: 0.16 + 0.18 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawOval(
      rect.deflate(4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _cYellow.withValues(alpha: 0.35 + 0.4 * pulse),
    );
  }

  /// Drop target ring while a tool is dragged.
  void _targetHighlight(Canvas canvas) {
    final inside = scene.targetZone.contains(scene.dragPos);
    final rect = scene.isCandle
        ? Rect.fromCenter(center: const Offset(_candleX, 300), width: 250, height: 260)
        : Rect.fromCenter(center: _rockC, width: 340, height: 220);
    if (inside) {
      canvas.drawOval(rect, Paint()..color = _cYellow.withValues(alpha: 0.08));
    }
    labDashedPath(
      canvas,
      Path()..addOval(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = inside ? 3.5 : 2
        ..color = _cYellow.withValues(alpha: inside ? 0.95 : 0.5),
      dash: 12,
      gap: 8,
      phase: _time * 30,
    );
  }

  // ------------------------------------------------------- effects

  void _effects(Canvas canvas) {
    final age = scene.fxAge;
    switch (scene.fx) {
      case _Fx.none:
        return;
      case _Fx.strike:
        if (age > 0.5) return;
        final o = _home[_Tool.matchbox]!.translate(0, -26);
        for (var i = 0; i < 10; i++) {
          final a = -math.pi / 2 + (i - 4.5) * 0.3;
          final d = 10 + age * 90;
          canvas.drawCircle(
            o + Offset(math.cos(a), math.sin(a)) * d,
            2.2 * (1 - age / 0.5),
            Paint()..color = Color.lerp(const Color(0xFFFFF3B0), const Color(0xFFF97316), age * 2)!,
          );
        }
      case _Fx.rain:
        if (age > 1.4) return;
        final fade = (1 - age / 1.4).clamp(0.0, 1.0);
        final cloud = scene.toolPos(_Tool.cloud);
        final drop = Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF60A5FA).withValues(alpha: 0.9 * fade);
        for (var i = 0; i < 22; i++) {
          final x = cloud.dx + ((i * 37) % 84) - 42;
          final ph = (age * 2.4 + i * 0.137) % 1;
          final y = cloud.dy + 26 + ph * 110;
          canvas.drawLine(Offset(x, y), Offset(x - 2, y + 11), drop);
        }
      case _Fx.frost:
        if (age > 1.4) return;
        final fade = (1 - age / 1.4).clamp(0.0, 1.0);
        canvas.drawOval(
          Rect.fromCenter(center: _rockC, width: 270, height: 160),
          Paint()
            ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.18 * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        );
        for (var i = 0; i < 14; i++) {
          final p = _tex(150 + (i * 53) % 240, 110 + (i * 71) % 330);
          final tw = 0.5 + 0.5 * math.sin(_time * 9 + i);
          final r = (3 + 4 * tw) * fade;
          final sp = Paint()
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.95 * fade);
          canvas.drawLine(p.translate(-r, 0), p.translate(r, 0), sp);
          canvas.drawLine(p.translate(0, -r), p.translate(0, r), sp);
        }
      case _Fx.sunshine:
        if (age > 1.4) return;
        final fade = math.sin((age / 1.4).clamp(0.0, 1.0) * math.pi);
        labGlow(canvas, _rockC.translate(0, -30), 220, const Color(0xFFFBBF24), intensity: 0.4 * fade);
        final steam = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35 * fade);
        for (var i = 0; i < 5; i++) {
          final x0 = _rockC.dx - 60 + i * 30.0;
          final y0 = 262 - age * 40;
          final path = Path()..moveTo(x0, y0);
          for (var k = 1; k <= 6; k++) {
            path.lineTo(x0 + 6 * math.sin(k + _time * 4 + i), y0 - k * 9);
          }
          canvas.drawPath(path, steam);
        }
      case _Fx.impact:
        if (age > 0.6) return;
        final o = (_rockC + const Offset(0, -42));
        final f = age / 0.6;
        labGlow(canvas, o, 40 * (1 - f) + 10, Colors.white, intensity: 0.8 * (1 - f));
        for (var i = 0; i < 9; i++) {
          final a = -math.pi + i * math.pi / 8;
          final p = o + Offset(math.cos(a), math.sin(a)) * (12 + f * 55) + Offset(0, f * f * 30);
          canvas.drawCircle(p, 3 * (1 - f) + 1, Paint()..color = (i.isEven ? _cChip : const Color(0xFF94A3B8)));
        }
    }
  }

  // -------------------------------------------------------- labels

  void _labels(Canvas canvas) {
    _label(canvas, _tr('lbl_inventory'), const Offset(326, 528), align: Alignment.center, size: 13);
    if (scene.isCandle) {
      final topY = _p3(-2, 3.6 - 1.5 * scene.melt, -1).dy;
      _label(canvas, _tr('lbl_matchbox'), const Offset(170, 432), size: 15);
      _label(canvas, _tr('lbl_magnifier'), const Offset(276, 432), size: 15);
      _label(canvas, _tr('lbl_funnel'), const Offset(392, 416), size: 15);
      _label(canvas, _tr(scene.limeDone ? 'dyn_substance' : 'lbl_limewater'), const Offset(768, 204), size: 15);
      if (scene.limeDone) _label(canvas, _tr('dyn_gas'), const Offset(768, 300), size: 13.5, maxWidth: 170);
      if (scene.meltLabels) {
        _label(canvas, _tr('dyn_molten'), const Offset(300, 270), size: 15, leader: Offset(_candleX - 20, topY));
        final m = scene.melt;
        final dripWorldY = (3.0 - 1.5 * m) - (m - 0.4) * 2.5;
        final dripY = math.min(_p3(-1.3, dripWorldY, -0.6).dy, _candleBaseY - 8);
        _label(canvas, _tr('dyn_drip'), const Offset(528, 326),
            size: 15, align: Alignment.centerLeft, maxWidth: 140, leader: Offset(_candleX + 40, dripY + 4));
      }
      if (scene.summary) {
        _label(canvas, _tr('dyn_phys1'), const Offset(230, 200), yellow: true, size: 14, maxWidth: 360);
        _label(canvas, _tr('dyn_chem1'), const Offset(724, 76),
            yellow: true, size: 13.5, align: Alignment.topCenter, maxWidth: 400);
      }
      return;
    }
    _label(canvas, _tr('lbl_rain_cloud'), const Offset(170, 432), size: 15);
    _label(canvas, _tr('lbl_snowflake'), const Offset(276, 400), size: 15);
    _label(canvas, _tr('lbl_sun'), const Offset(380, 432), size: 15);
    _label(canvas, _tr('lbl_hammer'), const Offset(484, 400), size: 15);
    if (scene.broken) _label(canvas, _tr('dyn_broken'), const Offset(778, 388), size: 15);
    if (scene.rustLabel) {
      _label(canvas, _tr('dyn_iron'), const Offset(684, 232), size: 15, leader: const Offset(684, 262));
    }
    if (scene.chipped) {
      _label(canvas, _tr('dyn_basalt'), const Offset(534, 262),
          size: 15, align: Alignment.centerRight, leader: (_rockC + const Offset(0, -37)).translate(-20, 0));
    }
    if (scene.summary) {
      _label(canvas, _tr('dyn_phys2'), const Offset(700, 430),
          yellow: true, size: 14, align: Alignment.topCenter, maxWidth: 360);
      _label(canvas, _tr('dyn_chem2'), const Offset(350, 196), yellow: true, size: 14, maxWidth: 440);
    }
  }

  @override
  bool shouldRepaint(covariant _A4Painter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

// ===================================================== WICK ZOOM PAINTER

/// HTML `.wick-zoom-container`: braided wick (repeating 45° stripes
/// 0x8B4513 / 0xA0522D), liquid wax flowing up (blue gradient, 1.5 s loop)
/// and three rising arrows (staggered by 0.5 s).
class _WickZoomPainter extends CustomPainter {
  _WickZoomPainter({required this.scene, required Listenable repaint}) : super(repaint: repaint);

  final _A4Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 300;
    final t = scene.time;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF111111));
    final strands = Rect.fromLTWH(size.width / 2 - 40 * k, size.height + 50 * k - 400 * k, 80 * k, 400 * k);
    final rr = RRect.fromRectAndRadius(strands, Radius.circular(40 * k));
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(
      strands,
      Paint()
        ..shader = ui.Gradient.linear(
          strands.topLeft,
          strands.topLeft + Offset(20 * k / math.sqrt2, -20 * k / math.sqrt2),
          const [Color(0xFF8B4513), Color(0xFF8B4513), Color(0xFFA0522D), Color(0xFFA0522D)],
          const [0, 0.5, 0.5, 1],
          TileMode.repeated,
        ),
    );
    // Liquid wax flowing up (translateY 100% → -100%, screen blend).
    final phase = (t % 1.5) / 1.5;
    final flow = strands.shift(Offset(0, strands.height * (1 - 2 * phase)));
    canvas.drawRect(
      flow,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC60A5FA), Color(0x0060A5FA)],
        ).createShader(flow),
    );
    // Shading across the wick for roundness.
    canvas.drawRect(
      strands,
      Paint()
        ..shader = LinearGradient(colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.4),
        ]).createShader(strands),
    );
    canvas.restore();
    // Arrows (bottom 10% → 80% of the strands, fading out).
    for (var i = 0; i < 3; i++) {
      final p = ((t - i * 0.5) % 1.5) / 1.5;
      final bottom = strands.bottom - (0.1 + 0.7 * p) * strands.height;
      final op = (1 - p).clamp(0.0, 1.0);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF60A5FA).withValues(alpha: op);
      final cx = size.width / 2;
      final tip = Offset(cx, bottom - 38 * k);
      canvas.drawLine(Offset(cx, bottom - 4 * k), tip, paint);
      canvas.drawPath(
        Path()
          ..moveTo(cx - 14 * k, tip.dy + 14 * k)
          ..lineTo(cx, tip.dy)
          ..lineTo(cx + 14 * k, tip.dy + 14 * k),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WickZoomPainter old) => old.scene != scene;
}

// ============================================================= LAB FRAMEWORK
// The lab screen used by every activity: shell (sidebar, curtain, canvas
// tools, popups, settings), controller, widgets, painting helpers and shell
// strings. Kept in this file so the activity stands alone.

// =========================================================== LAB STYLE TYPES

// The shapes of a lab's audio, theme and font. The values themselves (which
// tones, which colours, which font) live in every activity file, in its
// AUDIO / THEME / FONT sections; the shared shell only reads them.

/// A sound effect. Each activity declares its own tones (an enum that
/// implements this) and plays them with its own player.
abstract interface class LabTone {
  void play();
}

/// One lab's light or dark palette (the HTML `:root` / `.dark` variables).
@immutable
class LabPalette {
  const LabPalette({
    required this.isDark,
    required this.bg,
    required this.panel,
    required this.border,
    required this.card,
    required this.cardBorder,
    required this.canvasBg,
    required this.text,
    required this.textStrong,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.danger,
    required this.onDanger,
    required this.info,
    required this.popupBg,
    required this.popupHeader,
    required this.dialogBg,
    required this.toastBg,
    required this.toastText,
    required this.curtainBg,
    required this.curtainGlow,
    required this.curtainText,
    required this.curtainMuted,
    required this.curtainIcon,
    required this.buttonBg,
    required this.buttonIcon,
    required this.buttonBorder,
    required this.readoutBg,
    required this.readoutBorder,
    required this.readoutIcon,
    required this.labelBg,
    required this.labelText,
  });

  final bool isDark;

  /// Page background (`--bg-primary`).
  final Color bg;

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  final Color panel;
  final Color border;

  /// Inset cards inside panels.
  final Color card;
  final Color cardBorder;

  /// Canvas background (`bg-slate-100 dark:bg-slate-900`).
  final Color canvasBg;

  final Color text;
  final Color textStrong;
  final Color textMuted;

  /// Brand colour (ZSL yellow) and the text drawn on it.
  final Color accent;
  final Color onAccent;

  /// Secondary buttons (e.g. "Continue") and their text.
  final Color primary;
  final Color onPrimary;

  /// Completed scenario, error toast (and its text), completed step.
  final Color success;
  final Color danger;
  final Color onDanger;
  final Color info;

  /// Success popup body and header, settings dialog.
  final Color popupBg;
  final Color popupHeader;
  final Color dialogBg;

  /// Feedback toast.
  final Color toastBg;
  final Color toastText;

  /// Intro curtain with "Enter Lab".
  final Color curtainBg;
  final Color curtainGlow;
  final Color curtainText;
  final Color curtainMuted;
  final Color curtainIcon;

  /// Fixed menu and back buttons.
  final Color buttonBg;
  final Color buttonIcon;
  final Color buttonBorder;

  /// Dark HUD readouts (clocks, meters, timers).
  final Color readoutBg;
  final Color readoutBorder;
  final Color readoutIcon;

  /// Dark chip used for floating object labels in the scenes.
  final Color labelBg;
  final Color labelText;

  /// Material theme for the lab's widgets, in [font].
  ThemeData theme(LabFont font) => ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        useMaterial3: true,
        fontFamily: font.family,
        fontFamilyFallback: font.fallback,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: accent,
        ),
        scaffoldBackgroundColor: bg,
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          thumbColor: accent,
        ),
      );
}

/// One lab's font: family (`null` = the app's font, which on devices is the
/// platform font with Devanagari for Hindi) and the sidebar text size
/// setting (px).
@immutable
class LabFont {
  const LabFont({
    this.family,
    this.fallback,
    this.size = 15,
    this.minSize = 12,
    this.maxSize = 24,
  });

  final String? family;
  final List<String>? fallback;

  /// Default, smallest and largest sidebar text size (HTML
  /// `--sidebar-font-size`).
  final double size;
  final double minSize;
  final double maxSize;

  /// This font, or the app's font from [ambient] when [family] is null.
  LabFont orAmbient(TextStyle? ambient) => family != null
      ? this
      : LabFont(
          family: ambient?.fontFamily,
          fallback: fallback ?? ambient?.fontFamilyFallback,
          size: size,
          minSize: minSize,
          maxSize: maxSize,
        );

  /// The font of the lab on screen, used for canvas text. Set by the shell
  /// from the lab's [LabStyle].
  static LabFont active = const LabFont();
}

/// What an activity hands the shared shell: the tones it plays for shell
/// events, its light / dark palettes and its font.
@immutable
class LabStyle {
  const LabStyle({
    required this.click,
    required this.toggle,
    required this.correct,
    required this.wrong,
    required this.success,
    required this.scenario,
    required this.curtain,
    required this.dark,
    required this.light,
    this.font = const LabFont(),
    this.releaseAudio,
  });

  /// Button click, sidebar toggle, right / wrong feedback, success popup,
  /// scenario change and the intro curtain.
  final LabTone click;
  final LabTone toggle;
  final LabTone correct;
  final LabTone wrong;
  final LabTone success;
  final LabTone scenario;
  final LabTone curtain;

  final LabPalette dark;
  final LabPalette light;
  final LabFont font;

  /// Frees the lab's audio players; called when the lab closes.
  final VoidCallback? releaseAudio;

  LabPalette palette(bool isDark) => isDark ? dark : light;
}

/// Gives the shell's widgets the open lab's style and current palette.
class LabStyleScope extends InheritedWidget {
  const LabStyleScope({
    super.key,
    required this.style,
    required this.palette,
    required super.child,
  });

  final LabStyle style;
  final LabPalette palette;

  static LabStyleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LabStyleScope>();

  static LabStyleScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No LabStyleScope: build lab widgets inside a LabShell.');
    return scope!;
  }

  @override
  bool updateShouldNotify(LabStyleScope oldWidget) =>
      style != oldWidget.style || palette != oldWidget.palette;
}

/// Responsive helpers for landscape phones through to tablets.
extension LabResponsive on BuildContext {
  /// UI scale: ~0.8 on small landscape phones, 1.0 at 400dp short side,
  /// capped at 1.45 on large tablets.
  double get labScale {
    final shortest = MediaQuery.sizeOf(this).shortestSide;
    return (shortest / 400).clamp(0.8, 1.45);
  }
}

// ================================================================ LAB MODELS

/// One step of a scenario (matches the HTML `steps: [{id, concept, action,
/// observation}]` entries). Steps are numbered from 1 by their position.
@immutable
class LabStep {
  const LabStep({
    required this.concept,
    required this.action,
    this.observation = '',
  });

  final String concept;
  final String action;
  final String observation;
}

/// A scenario's mission objective and steps for one language.
@immutable
class LabScenarioData {
  const LabScenarioData({
    required this.objective,
    required this.steps,
    this.title = '',
  });

  final String title;
  final String objective;
  final List<LabStep> steps;
}

/// A dynamic action button. Shown in the sidebar's action area and, while
/// the sidebar is collapsed, inside the floating mission card.
@immutable
class LabAction {
  const LabAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.foreground,
    this.enabled = true,
    this.highlight = false,
    this.sound,
    this.silent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Button fill. Defaults to the ZSL yellow.
  final Color? color;

  /// Text / icon colour. Defaults to a readable colour for [color].
  final Color? foreground;
  final bool enabled;

  /// Pulsing glow, like the HTML `.action-btn` animation.
  final bool highlight;

  /// Played on tap; `null` plays the lab's click tone.
  final LabTone? sound;

  /// No tap sound (when [onTap] plays its own).
  final bool silent;
}

/// Content of the draggable, scrollable success / observation popup.
@immutable
class LabPopupContent {
  const LabPopupContent({
    required this.title,
    this.heading,
    this.body,
    this.extra,
    this.actions = const [],
    this.icon = Icons.check_circle,
    this.accent,
  });

  final String title;

  /// Small uppercase heading above [body] (e.g. "Observation").
  final String? heading;
  final String? body;

  /// Optional extra widget (tables, result chips...) below [body].
  final Widget? extra;
  final List<LabAction> actions;
  final IconData icon;
  final Color? accent;
}

/// Popup content is rebuilt on every frame so that a language switch
/// re-translates an open popup.
typedef LabPopupBuilder = LabPopupContent Function();

// ========================================================= LAB SHELL STRINGS

// English / Hindi localisation helpers.

enum LabLang {
  en('EN'),
  hi('हि');

  const LabLang(this.badge);

  /// Short text shown on the language toggle button.
  final String badge;

  /// Key used in the `{'en': {...}, 'hi': {...}}` string tables.
  String get code => name;

  LabLang get next => this == LabLang.en ? LabLang.hi : LabLang.en;
}

/// A string table in the same shape as the HTML `i18n` objects:
/// `{'en': {'key': 'text'}, 'hi': {'key': 'पाठ'}}`.
typedef LabStringTable = Map<String, Map<String, String>>;

/// Looks [key] up in [table] for [lang], falling back to English, then to
/// the key itself so a missing translation is visible but never crashes.
String labTr(LabStringTable table, LabLang lang, String key) {
  return table[lang.code]?[key] ?? table['en']?[key] ?? key;
}

/// Replaces `{name}` placeholders in [template] with [values].
String labFormat(String template, Map<String, Object> values) {
  var out = template;
  values.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
  return out;
}

/// Strings used by the shared lab shell (header, sidebar, tools, settings,
/// popups, footer). Activity specific strings live in each activity file.
const LabStringTable kLabCommonStrings = {
  'en': {
    'enter_lab': 'Enter Lab',
    'select_scenario': 'Select Scenario',
    'mission_obj': 'Mission Objective',
    'target_output': 'Target Output',
    'curr_obj': 'Current Objective',
    'step': 'Step',
    'of': 'of',
    'concept_focus': 'Concept Focus:',
    'action': 'Action:',
    'actions': 'Actions',
    'controls': 'Lab Controls',
    'settings': 'Settings',
    'theme': 'Theme',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'font_size': 'Font Size',
    'on': 'On',
    'off': 'Off',
    'toggle_language': 'Toggle Language',
    'reset_lab': 'Reset Lab',
    'back_home': 'Back to Home',
    'menu': 'Menu',
    'tool_labels': 'Toggle Labels',
    'tool_lock': 'Lock / Unlock Camera',
    'tool_pan': 'Pan Mode',
    'tool_reset_view': 'Reset View',
    'tool_zoom_in': 'Zoom In',
    'tool_zoom_out': 'Zoom Out',
    'close': 'Close',
    'btn_continue': 'Continue',
    'btn_restart': 'Restart Lab',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Scientific Conclusion',
    'lbl_observation': 'Observation',
    'success': 'Success!',
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario.',
    'msg_all_complete': 'All scenarios complete! Great work.',
    'completed': 'Completed',
    'minimize': 'Minimize',
    'expand': 'Expand',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
  },
  'hi': {
    'enter_lab': 'लैब में प्रवेश करें',
    'select_scenario': 'परिदृश्य चुनें',
    'mission_obj': 'मिशन का उद्देश्य',
    'target_output': 'लक्ष्य परिणाम',
    'curr_obj': 'वर्तमान उद्देश्य',
    'step': 'चरण',
    'of': 'में से',
    'concept_focus': 'अवधारणा:',
    'action': 'कार्य:',
    'actions': 'कार्य',
    'controls': 'लैब नियंत्रण',
    'settings': 'सेटिंग्स',
    'theme': 'थीम',
    'light_mode': 'लाइट मोड',
    'dark_mode': 'डार्क मोड',
    'font_size': 'फ़ॉन्ट का आकार',
    'on': 'चालू',
    'off': 'बंद',
    'toggle_language': 'भाषा बदलें',
    'reset_lab': 'लैब रीसेट करें',
    'back_home': 'होम पर वापस जाएँ',
    'menu': 'मेनू',
    'tool_labels': 'लेबल दिखाएँ / छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक',
    'tool_pan': 'पैन मोड',
    'tool_reset_view': 'दृश्य रीसेट करें',
    'tool_zoom_in': 'ज़ूम इन',
    'tool_zoom_out': 'ज़ूम आउट',
    'close': 'बंद करें',
    'btn_continue': 'जारी रखें',
    'btn_restart': 'लैब फिर से शुरू करें',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'वैज्ञानिक निष्कर्ष',
    'lbl_observation': 'अवलोकन',
    'success': 'सफलता!',
    'msg_scenario_complete': 'परिदृश्य पूर्ण! कृपया अगला परिदृश्य चुनें।',
    'msg_all_complete': 'सभी परिदृश्य पूर्ण! बहुत बढ़िया।',
    'completed': 'पूर्ण',
    'minimize': 'छोटा करें',
    'expand': 'बड़ा करें',
    'footer': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
  },
};

// ============================================================ LAB CONTROLLER

/// Transient feedback message (the HTML `#feedback-toast`).
@immutable
class LabToast {
  const LabToast(this.text, {this.isError = false, required this.id});
  final String text;
  final bool isError;
  final int id;
}

/// Shared UI state for one lab: language, theme, sidebar, labels, camera
/// tools, toast and popup. Owned by the activity's State and passed to
/// [LabShell]. Activities rebuild on changes with a `ListenableBuilder`.
class LabController extends ChangeNotifier {
  LabController({required this.style, this.camLocked = false})
      : fontSize = style.font.size;

  static const double minZoom = 0.5;
  static const double maxZoom = 5;

  /// The activity's own tones, palettes and font.
  final LabStyle style;

  LabLang lang = LabLang.en;
  bool isDark = true;

  /// Sidebar font size in px (HTML `--sidebar-font-size`), within the
  /// lab font's range.
  double fontSize;
  bool showLabels = true;
  bool isSidebarOpen = true;

  /// Sidebar width as a fraction of the screen; drag its edge to resize.
  static const double defaultSidebarFraction = 0.30;
  double sidebarFraction = defaultSidebarFraction;

  /// How far the user dragged each floating card, by card id (see
  /// [LabMovable]).
  final Map<String, Offset> cardOffsets = {};

  /// True once the curtain has lifted (HTML `State.isLabActive`).
  bool isLabActive = false;

  /// Locked: pinch / drag do not move the canvas (zoom buttons still work).
  bool camLocked;

  /// Pan mode: drags move the canvas instead of interacting with the scene.
  bool panMode = false;
  bool settingsOpen = false;

  /// Scenarios finished in this session (HTML `completedScenarios`).
  final Set<int> completedScenarios = {};

  /// Zoom / pan of the canvas (driven by InteractiveViewer and tool buttons).
  final TransformationController transform = TransformationController();

  LabToast? toast;
  LabPopupBuilder? popup;

  Timer? _toastTimer;
  int _toastId = 0;
  bool _disposed = false;
  final Set<Timer> _timers = {};

  // Hooks registered by the shell / zoom viewer.
  void Function(double factor)? _zoomHook;
  VoidCallback? _resetViewHook;
  VoidCallback? _fullResetHook;

  /// Common (shell) string for the current language.
  String t(String key) => labTr(kLabCommonStrings, lang, key);

  /// Activity string from [table] for the current language.
  String tr(LabStringTable table, String key) => labTr(table, lang, key);

  double get fontScale => fontSize / style.font.size;

  /// The lab's palette for the current theme.
  LabPalette get palette => style.palette(isDark);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool get isDisposed => _disposed;

  /// Runs [fn] after [delay] (the HTML `setTimeout`). Pending callbacks are
  /// cancelled when the lab is disposed, so they never touch a dead State.
  Timer after(Duration delay, VoidCallback fn) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      if (!_disposed) fn();
    });
    _timers.add(timer);
    return timer;
  }

  /// Cancels every pending [after] callback (e.g. on scenario change).
  void cancelPending() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  // ---------------------------------------------------------------- settings

  void toggleLanguage() {
    style.click.play();
    lang = lang.next;
    _notify();
  }

  void setLanguage(LabLang value) {
    if (lang == value) return;
    lang = value;
    _notify();
  }

  void toggleTheme() {
    style.click.play();
    isDark = !isDark;
    _notify();
  }

  void setFontSize(double value) {
    fontSize = value.clamp(style.font.minSize, style.font.maxSize).toDouble();
    _notify();
  }

  void toggleSettings() {
    style.click.play();
    settingsOpen = !settingsOpen;
    _notify();
  }

  // ----------------------------------------------------------------- sidebar

  void toggleSidebar() {
    style.toggle.play();
    isSidebarOpen = !isSidebarOpen;
    _notify();
  }

  void openSidebar() {
    if (isSidebarOpen) return;
    style.toggle.play();
    isSidebarOpen = true;
    _notify();
  }

  // ------------------------------------------------------------ canvas tools

  void toggleLabels() {
    style.click.play();
    showLabels = !showLabels;
    _notify();
  }

  void toggleCamLock() {
    style.click.play();
    camLocked = !camLocked;
    _notify();
  }

  void togglePanMode() {
    style.click.play();
    panMode = !panMode;
    _notify();
  }

  void zoomIn() {
    style.click.play();
    _zoomHook?.call(1.25);
  }

  void zoomOut() {
    style.click.play();
    _zoomHook?.call(0.8);
  }

  /// Animates the canvas back to 100% zoom, centred.
  void resetView({bool sound = true}) {
    if (sound) style.click.play();
    if (_resetViewHook != null) {
      _resetViewHook!();
    } else {
      transform.value = Matrix4.identity();
    }
  }

  // ---------------------------------------------------------------- feedback

  /// Shows the floating feedback toast for 3 seconds. Plays the lab's
  /// "correct" / "wrong" tone unless [sound] is false.
  void showToast(String text, {bool isError = false, bool sound = true}) {
    if (sound) (isError ? style.wrong : style.correct).play();
    _toastTimer?.cancel();
    toast = LabToast(text, isError: isError, id: ++_toastId);
    _notify();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toast = null;
      _notify();
    });
  }

  /// Opens the draggable, scrollable popup. [builder] runs on every rebuild
  /// so it should read strings through [tr] / [t] to follow language changes.
  /// Plays [sound] (default: the lab's success tone) unless [silent].
  void showPopup(LabPopupBuilder builder, {LabTone? sound, bool silent = false}) {
    if (!silent) (sound ?? style.success).play();
    popup = builder;
    _notify();
  }

  void hidePopup({bool sound = true}) {
    if (popup == null) return;
    if (sound) style.click.play();
    popup = null;
    _notify();
  }

  /// The standard end-of-scenario flow from the HTML `showConclusion()`:
  /// marks the scenario complete, re-opens the sidebar and shows the
  /// conclusion popup. When every scenario is done the popup offers
  /// "Restart Lab"; otherwise "Continue" closes it and shows the
  /// "Scenario Complete" toast.
  void showScenarioConclusion({
    required int scenarioIndex,
    required int totalScenarios,
    required String Function() body,
    String Function()? title,
    String Function()? heading,
    Widget Function()? extra,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    completedScenarios.add(scenarioIndex);
    final allDone = completedScenarios.length >= totalScenarios;
    after(delay, () {
      if (!isSidebarOpen) {
        isSidebarOpen = true;
        style.toggle.play();
      }
      showPopup(() => LabPopupContent(
            title: title?.call() ?? t('success'),
            heading: heading?.call() ?? t('lbl_observation'),
            body: body(),
            extra: extra?.call(),
            actions: [
              if (allDone)
                LabAction(
                  label: t('btn_restart'),
                  icon: Icons.restart_alt,
                  onTap: requestFullReset,
                )
              else
                LabAction(
                  label: t('btn_continue'),
                  icon: Icons.arrow_forward,
                  color: palette.primary,
                  foreground: palette.onPrimary,
                  onTap: () {
                    hidePopup(sound: false);
                    showToast(t('msg_scenario_complete'));
                  },
                ),
            ],
          ));
    });
  }

  /// Full "Reset Lab" (HTML `resetApp(false)`): closes the curtain, resets
  /// language, theme, font size, labels and sidebar, then calls the
  /// activity's `onReset`.
  void requestFullReset() => _fullResetHook?.call();

  /// Restores the shell defaults. Called by the shell during a full reset.
  void resetShellState() {
    cancelPending();
    _toastTimer?.cancel();
    toast = null;
    popup = null;
    settingsOpen = false;
    lang = LabLang.en;
    isDark = true;
    fontSize = style.font.size;
    showLabels = true;
    isSidebarOpen = true;
    sidebarFraction = defaultSidebarFraction;
    cardOffsets.clear();
    panMode = false;
    completedScenarios.clear();
    transform.value = Matrix4.identity();
    _notify();
  }

  void markLabActive(bool active) {
    isLabActive = active;
    _notify();
  }

  // ------------------------------------------------------- shell internals

  // ignore: use_setters_to_change_properties
  void attachZoomHooks({
    required void Function(double factor) zoom,
    required VoidCallback resetView,
  }) {
    _zoomHook = zoom;
    _resetViewHook = resetView;
  }

  void detachZoomHooks() {
    _zoomHook = null;
    _resetViewHook = null;
  }

  // ignore: use_setters_to_change_properties
  void attachResetHook(VoidCallback hook) => _fullResetHook = hook;

  void detachResetHook() => _fullResetHook = null;

  @override
  void dispose() {
    _disposed = true;
    style.releaseAudio?.call();
    _toastTimer?.cancel();
    cancelPending();
    transform.dispose();
    super.dispose();
  }
}

// ================================================================= LAB STAGE

/// Key of the design-size box inside [LabStage] (used by tests to convert
/// design coordinates to screen positions).
const ValueKey<String> labStageDesignKey = ValueKey('lab-stage-design');

/// A fixed "design size" scene that is scaled to fit the available canvas
/// area (BoxFit.contain) and centred. Everything inside [child] is laid out,
/// painted and hit-tested in design coordinates, so a `CustomPainter` can
/// draw at e.g. 1000x560 and `GestureDetector.localPosition` values come
/// back in the same coordinates at any screen size.
///
/// [background] fills the whole canvas area (including letterbox space)
/// behind the scaled scene.
class LabStage extends StatelessWidget {
  const LabStage({
    super.key,
    required this.designSize,
    required this.child,
    this.background,
  });

  final Size designSize;
  final Widget child;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ?background,
        FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            key: labStageDesignKey,
            width: designSize.width,
            height: designSize.height,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A rect that extends well past the design area. The stage is letterboxed
/// when the canvas aspect ratio differs from the design size, and nothing
/// clips the painter there, so fill sky / ground / water with this rect
/// (and extend tracks, tables, horizons) to avoid visible seams.
Rect labBleed(Size size) =>
    Rect.fromLTRB(-size.width * 1.5, -size.height * 1.5, size.width * 2.5, size.height * 2.5);

/// Converts a global position (e.g. `DragTargetDetails.offset`) into the
/// local coordinates of the widget owning [key] (e.g. a LabStage child),
/// accounting for zoom, pan and stage scaling.
Offset? labGlobalToLocal(GlobalKey key, Offset global) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.globalToLocal(global);
}

/// Zoomable / pannable canvas used by [LabShell]. Pinch and drag move the
/// canvas unless the camera is locked; in pan mode the scene ignores
/// touches so every drag pans. Tool buttons zoom about the centre.
class LabZoomViewer extends StatefulWidget {
  const LabZoomViewer({super.key, required this.controller, required this.child});

  final LabController controller;
  final Widget child;

  @override
  State<LabZoomViewer> createState() => _LabZoomViewerState();
}

class _LabZoomViewerState extends State<LabZoomViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Matrix4Tween? _tween;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(_onTick);
    widget.controller.attachZoomHooks(zoom: _zoomBy, resetView: _reset);
  }

  @override
  void didUpdateWidget(covariant LabZoomViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachZoomHooks();
      widget.controller.attachZoomHooks(zoom: _zoomBy, resetView: _reset);
    }
  }

  @override
  void dispose() {
    widget.controller.detachZoomHooks();
    _anim.dispose();
    super.dispose();
  }

  void _onTick() {
    final tween = _tween;
    if (tween == null) return;
    widget.controller.transform.value =
        tween.transform(Curves.easeOutCubic.transform(_anim.value));
  }

  void _animateTo(Matrix4 target) {
    _tween = Matrix4Tween(
      begin: widget.controller.transform.value.clone(),
      end: target,
    );
    _anim.forward(from: 0);
  }

  void _zoomBy(double factor) {
    if (_viewport.isEmpty) return;
    final current = widget.controller.transform.value;
    final scale = current.getMaxScaleOnAxis();
    final target =
        (scale * factor).clamp(LabController.minZoom, LabController.maxZoom);
    final f = target / scale;
    final cx = _viewport.width / 2;
    final cy = _viewport.height / 2;
    // Scale about the viewport centre: x' = f * x + c * (1 - f).
    final about = Matrix4.identity()
      ..setEntry(0, 0, f)
      ..setEntry(1, 1, f)
      ..setEntry(0, 3, cx * (1 - f))
      ..setEntry(1, 3, cy * (1 - f));
    _animateTo(about.multiplied(current));
  }

  void _reset() => _animateTo(Matrix4.identity());

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final gesturesOn = c.panMode || !c.camLocked;
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return InteractiveViewer(
          transformationController: c.transform,
          minScale: LabController.minZoom,
          maxScale: LabController.maxZoom,
          boundaryMargin: const EdgeInsets.all(400),
          panEnabled: gesturesOn,
          scaleEnabled: gesturesOn,
          child: IgnorePointer(
            ignoring: c.panMode,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ========================================================= LAB PAINT HELPERS

/// Painting helpers that stand in for the Three.js meshes and HTML labels of
/// the original labs. All take design-space coordinates.

/// Lightens (amount > 0) or darkens (amount < 0) [c] by mixing with white
/// or black.
Color labShade(Color c, double amount) {
  if (amount >= 0) return Color.lerp(c, Colors.white, amount.clamp(0, 1))!;
  return Color.lerp(c, Colors.black, (-amount).clamp(0, 1))!;
}

/// Draws [text] anchored at [at]. [anchor] picks which point of the text box
/// sits on [at] (centre by default). With [background] the text is drawn
/// inside a rounded pill (the HTML floating labels / distance badges).
/// Returns the painted rect.
Rect labText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 14,
  Color color = Colors.white,
  FontWeight weight = FontWeight.w600,
  Alignment anchor = Alignment.center,
  TextAlign align = TextAlign.center,
  double? maxWidth,
  Color? background,
  Color? border,
  double borderWidth = 1.5,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  double radius = 999,
  double opacity = 1,
  String? fontFamily,
  List<Shadow>? shadows,
  double letterSpacing = 0,
}) {
  if (opacity <= 0) return Rect.zero;
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        color: color.withValues(alpha: color.a * opacity),
        fontWeight: weight,
        fontFamily: fontFamily ?? LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
        shadows: shadows,
        letterSpacing: letterSpacing,
        height: 1.2,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth ?? double.infinity);

  final pad = background != null || border != null ? padding : EdgeInsets.zero;
  final w = tp.width + pad.horizontal;
  final h = tp.height + pad.vertical;
  final left = at.dx - (anchor.x + 1) / 2 * w;
  final top = at.dy - (anchor.y + 1) / 2 * h;
  final rect = Rect.fromLTWH(left, top, w, h);

  if (background != null || border != null) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(radius, h / 2)));
    if (background != null) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(rr, Paint()..color = background.withValues(alpha: background.a * opacity));
    }
    if (border != null) {
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = border.withValues(alpha: border.a * opacity),
      );
    }
  }
  tp.paint(canvas, Offset(left + pad.left, top + pad.top));
  return rect;
}

/// Floating object label like the HTML `.object-label` chips
/// (dark pill, white bold text).
Rect labPill(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 13,
  Color background = const Color(0xE61E293B),
  Color color = Colors.white,
  Color? border = const Color(0xFF475569),
  Alignment anchor = Alignment.center,
  double opacity = 1,
}) {
  return labText(
    canvas,
    text,
    at,
    size: size,
    color: color,
    weight: FontWeight.w700,
    background: background,
    border: border,
    borderWidth: 1,
    anchor: anchor,
    opacity: opacity,
  );
}

/// Straight arrow with a filled head.
void labArrow(
  Canvas canvas,
  Offset from,
  Offset to, {
  Color color = Colors.white,
  double width = 3,
  double head = 12,
  bool dashed = false,
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final dir = to - from;
  final len = dir.distance;
  if (len < 0.001) return;
  final u = dir / len;
  final base = to - u * head;
  if (dashed) {
    labDashedLine(canvas, from, base, paint);
  } else {
    canvas.drawLine(from, base, paint);
  }
  final n = Offset(-u.dy, u.dx);
  final path = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(base.dx + n.dx * head * 0.55, base.dy + n.dy * head * 0.55)
    ..lineTo(base.dx - n.dx * head * 0.55, base.dy - n.dy * head * 0.55)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
}

/// Dashed straight line.
void labDashedLine(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 8,
  double gap = 6,
  double phase = 0,
}) {
  final total = (b - a).distance;
  if (total <= 0) return;
  final u = (b - a) / total;
  var d = -(phase % (dash + gap));
  while (d < total) {
    final s = math.max(d, 0.0);
    final e = math.min(d + dash, total);
    if (e > s) canvas.drawLine(a + u * s, a + u * e, paint);
    d += dash + gap;
  }
}

/// Dashed version of any [path] (e.g. orbits, light rays).
void labDashedPath(Canvas canvas, Path path, Paint paint,
    {double dash = 8, double gap = 6, double phase = 0}) {
  for (final metric in path.computeMetrics()) {
    var d = -(phase % (dash + gap));
    while (d < metric.length) {
      final s = math.max(d, 0.0);
      final e = math.min(d + dash, metric.length);
      if (e > s) canvas.drawPath(metric.extractPath(s, e), paint);
      d += dash + gap;
    }
  }
}

/// Lit sphere (MeshStandardMaterial look) with a soft drop shadow option.
void labSphere(
  Canvas canvas,
  Offset c,
  double r,
  Color color, {
  Offset light = const Offset(-0.35, -0.4),
  double highlight = 0.45,
  double shade = 0.55,
  bool outline = false,
  double opacity = 1,
}) {
  final rect = Rect.fromCircle(center: c, radius: r);
  final paint = Paint()
    ..shader = RadialGradient(
      center: Alignment(light.dx, light.dy),
      radius: 1.05,
      colors: [
        labShade(color, highlight).withValues(alpha: opacity),
        color.withValues(alpha: opacity),
        labShade(color, -shade).withValues(alpha: opacity),
      ],
      stops: const [0, 0.5, 1],
    ).createShader(rect);
  canvas.drawCircle(c, r, paint);
  if (outline) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(color, -0.6).withValues(alpha: 0.6 * opacity),
    );
  }
}

/// Additive-looking radial glow (light bulbs, flames, sun, hot spots).
void labGlow(Canvas canvas, Offset c, double r, Color color, {double intensity = 1}) {
  if (intensity <= 0 || r <= 0) return;
  final rect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: (0.85 * intensity).clamp(0, 1)),
        color.withValues(alpha: (0.35 * intensity).clamp(0, 1)),
        color.withValues(alpha: 0),
      ], stops: const [0, 0.35, 1]).createShader(rect),
  );
}

/// Soft elliptical contact shadow under an object.
void labGroundShadow(Canvas canvas, Offset c, double w, double h, {double opacity = 0.3}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.35),
  );
}

/// Oblique "2.5D" cuboid: [front] face plus top and right faces receding by
/// [depth] towards the upper right. Approximates a Three.js BoxGeometry.
void labBox3D(
  Canvas canvas,
  Rect front,
  double depth,
  Color color, {
  double angle = -0.6,
  bool stroke = true,
  double opacity = 1,
  double radius = 0,
}) {
  final d = Offset(math.cos(angle), math.sin(angle)) * depth;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  final top = Path()
    ..moveTo(front.left, front.top)
    ..lineTo(front.left + d.dx, front.top + d.dy)
    ..lineTo(front.right + d.dx, front.top + d.dy)
    ..lineTo(front.right, front.top)
    ..close();
  final side = Path()
    ..moveTo(front.right, front.top)
    ..lineTo(front.right + d.dx, front.top + d.dy)
    ..lineTo(front.right + d.dx, front.bottom + d.dy)
    ..lineTo(front.right, front.bottom)
    ..close();
  canvas.drawPath(top, Paint()..color = a(labShade(color, 0.25)));
  canvas.drawPath(side, Paint()..color = a(labShade(color, -0.3)));
  final frontPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [a(labShade(color, 0.08)), a(labShade(color, -0.12))],
    ).createShader(front);
  if (radius > 0) {
    canvas.drawRRect(RRect.fromRectAndRadius(front, Radius.circular(radius)), frontPaint);
  } else {
    canvas.drawRect(front, frontPaint);
  }
  if (stroke) {
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = a(labShade(color, -0.45).withValues(alpha: 0.6));
    canvas.drawPath(top, edge);
    canvas.drawPath(side, edge);
    canvas.drawRect(front, edge);
  }
}

/// Upright cylinder seen slightly from above (CylinderGeometry look).
/// [rect] is the bounding box of the side; the top ellipse height is
/// `rect.width * tilt`.
void labCylinder(
  Canvas canvas,
  Rect rect,
  Color color, {
  double tilt = 0.28,
  double opacity = 1,
  bool drawTop = true,
}) {
  final eh = rect.width * tilt;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  final body = Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.left, rect.bottom)
    ..arcTo(Rect.fromLTWH(rect.left, rect.bottom - eh / 2, rect.width, eh), math.pi, -math.pi, false)
    ..lineTo(rect.right, rect.top)
    ..close();
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        a(labShade(color, -0.35)),
        a(labShade(color, 0.25)),
        a(color),
        a(labShade(color, -0.45)),
      ], stops: const [0, 0.3, 0.6, 1]).createShader(rect),
  );
  if (drawTop) {
    canvas.drawOval(
      Rect.fromLTWH(rect.left, rect.top - eh / 2, rect.width, eh),
      Paint()..color = a(labShade(color, 0.3)),
    );
  }
}

/// Glass beaker with optional liquid. [fill] is 0..1 of the inner height.
void labBeaker(
  Canvas canvas,
  Rect rect, {
  double fill = 0,
  Color liquid = const Color(0xFF60A5FA),
  Color glass = const Color(0xFFBFDBFE),
  bool graduations = true,
  double liquidOpacity = 0.75,
}) {
  final r = rect.width * 0.08;
  final inner = rect.deflate(3);
  if (fill > 0) {
    final h = inner.height * fill.clamp(0, 1);
    final lr = Rect.fromLTRB(inner.left, inner.bottom - h, inner.right, inner.bottom);
    canvas.drawRRect(
      RRect.fromRectAndCorners(lr, bottomLeft: Radius.circular(r), bottomRight: Radius.circular(r)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(liquid, 0.15).withValues(alpha: liquidOpacity),
            labShade(liquid, -0.2).withValues(alpha: liquidOpacity),
          ],
        ).createShader(lr),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(lr.center.dx, lr.top), width: lr.width, height: lr.width * 0.12),
      Paint()..color = labShade(liquid, 0.3).withValues(alpha: liquidOpacity),
    );
  }
  final glassPath = Path()
    ..moveTo(rect.left - 4, rect.top)
    ..lineTo(rect.left, rect.top + 6)
    ..lineTo(rect.left, rect.bottom - r)
    ..quadraticBezierTo(rect.left, rect.bottom, rect.left + r, rect.bottom)
    ..lineTo(rect.right - r, rect.bottom)
    ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - r)
    ..lineTo(rect.right, rect.top);
  canvas.drawPath(glassPath, Paint()..color = glass.withValues(alpha: 0.12));
  canvas.drawPath(
    glassPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = glass.withValues(alpha: 0.85),
  );
  // Glass highlight.
  canvas.drawLine(
    Offset(rect.left + rect.width * 0.12, rect.top + 12),
    Offset(rect.left + rect.width * 0.12, rect.bottom - 12),
    Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.25),
  );
  if (graduations) {
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = glass.withValues(alpha: 0.7);
    for (var i = 1; i <= 4; i++) {
      final y = rect.bottom - rect.height * i / 5;
      canvas.drawLine(Offset(rect.right - rect.width * 0.25, y), Offset(rect.right - 3, y), g);
    }
  }
}

/// Test tube (rounded bottom) with optional liquid.
void labTestTube(
  Canvas canvas,
  Rect rect, {
  double fill = 0,
  Color liquid = const Color(0xFF60A5FA),
  Color glass = const Color(0xFFBFDBFE),
}) {
  final r = rect.width / 2;
  final path = Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.left, rect.bottom - r)
    ..arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r), clockwise: false)
    ..lineTo(rect.right, rect.top);
  if (fill > 0) {
    canvas.save();
    canvas.clipPath(Path()..addPath(path, Offset.zero)..close());
    final h = rect.height * fill.clamp(0, 1);
    canvas.drawRect(
      Rect.fromLTRB(rect.left, rect.bottom - h, rect.right, rect.bottom),
      Paint()..color = liquid.withValues(alpha: 0.8),
    );
    canvas.restore();
  }
  canvas.drawPath(path, Paint()..color = glass.withValues(alpha: 0.12));
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = glass.withValues(alpha: 0.85),
  );
  canvas.drawLine(
    Offset(rect.left - 3, rect.top),
    Offset(rect.right + 3, rect.top),
    Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = glass,
  );
}

/// Flickering flame (candle / burner / combustion). [t] is time in seconds.
void labFlame(Canvas canvas, Offset base, double height, double t, {double intensity = 1}) {
  if (intensity <= 0) return;
  final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
  final h = height * flick * intensity;
  final w = height * 0.42 * intensity;
  labGlow(canvas, base.translate(0, -h * 0.45), h * 1.1, const Color(0xFFF97316), intensity: 0.55 * intensity);
  Path flame(double sx, double sy) => Path()
    ..moveTo(base.dx, base.dy - h * sy)
    ..cubicTo(base.dx + w * sx, base.dy - h * sy * 0.55, base.dx + w * sx * 0.9, base.dy,
        base.dx, base.dy)
    ..cubicTo(base.dx - w * sx * 0.9, base.dy, base.dx - w * sx, base.dy - h * sy * 0.55,
        base.dx, base.dy - h * sy)
    ..close();
  canvas.drawPath(flame(1, 1), Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.9));
  canvas.drawPath(flame(0.7, 0.75), Paint()..color = const Color(0xFFFACC15));
  canvas.drawPath(flame(0.35, 0.4), Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.9));
}

/// Wavy heat / airflow arrow (convection, breezes).
void labWavyArrow(Canvas canvas, Offset from, Offset to, double t,
    {Color color = const Color(0xFFF97316), double amp = 6, double width = 3}) {
  final dir = to - from;
  final len = dir.distance;
  if (len < 1) return;
  final u = dir / len;
  final n = Offset(-u.dy, u.dx);
  final path = Path()..moveTo(from.dx, from.dy);
  for (var d = 0.0; d <= len - 10; d += 4) {
    final p = from + u * d + n * (amp * math.sin(d / 14 - t * 6));
    path.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color,
  );
  labArrow(canvas, from + u * (len - 14), to, color: color, width: width, head: 11);
}

/// Minimal 3D -> 2D projector for orbit-style scenes (Earth / Sun / Moon,
/// rotating globes). Rotates by [yaw] about Y, then [pitch] about X, then
/// applies a perspective divide with camera distance [distance].
class LabProjector {
  const LabProjector({
    required this.center,
    this.scale = 1,
    this.yaw = 0,
    this.pitch = 0.35,
    this.distance = 900,
  });

  final Offset center;
  final double scale;
  final double yaw;
  final double pitch;
  final double distance;

  /// Returns the projected point and its depth (larger = closer to viewer).
  ({Offset p, double depth, double k}) project(double x, double y, double z) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = x * cy + z * sy;
    final z1 = -x * sy + z * cy;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final y2 = y * cp - z1 * sp;
    final z2 = y * sp + z1 * cp;
    final k = distance / (distance - z2 * scale);
    return (
      p: Offset(center.dx + x1 * scale * k, center.dy - y2 * scale * k),
      depth: z2,
      k: k,
    );
  }

  Offset point(double x, double y, double z) => project(x, y, z).p;
}

// =============================================================== LAB WIDGETS

/// Picks the palette's dark text or white for a coloured button fill.
Color labOnColor(Color fill, LabPalette palette) =>
    fill.computeLuminance() > 0.45 ? palette.onAccent : Colors.white;

/// Button for a [LabAction]; pulses when `action.highlight` is set.
class LabActionButton extends StatefulWidget {
  const LabActionButton({
    super.key,
    required this.action,
    this.scale = 1,
    this.expand = true,
    this.dense = false,
  });

  final LabAction action;
  final double scale;
  final bool expand;
  final bool dense;

  @override
  State<LabActionButton> createState() => _LabActionButtonState();
}

class _LabActionButtonState extends State<LabActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant LabActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final on = widget.action.highlight && widget.action.enabled;
    if (on && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!on && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    final s = widget.scale;
    final scope = LabStyleScope.of(context);
    final fill = a.color ?? scope.palette.accent;
    final fg = a.foreground ?? labOnColor(fill, scope.palette);
    final enabled = a.enabled && a.onTap != null;
    final vPad = (widget.dense ? 7.0 : 10.0) * s;

    final button = Material(
      color: enabled ? fill : fill.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * s),
        onTap: enabled
            ? () {
                if (!a.silent) (a.sound ?? scope.style.click).play();
                a.onTap!();
              }
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: vPad),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (a.icon != null) ...[
                Icon(a.icon, size: 16 * s, color: fg.withValues(alpha: enabled ? 1 : 0.6)),
                SizedBox(width: 6 * s),
              ],
              Flexible(
                child: Text(
                  a.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fg.withValues(alpha: enabled ? 1 : 0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: (widget.dense ? 11.5 : 13) * s,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = a.highlight && enabled;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            boxShadow: [
              if (glow)
                BoxShadow(
                  color: fill.withValues(alpha: 0.35 + 0.4 * _pulse.value),
                  blurRadius: (12 + 12 * _pulse.value) * s,
                ),
            ],
          ),
          child: child,
        );
      },
      child: button,
    );
  }
}

/// Lays out a list of actions as full-width buttons (sidebar) or a wrap.
class LabActionList extends StatelessWidget {
  const LabActionList({
    super.key,
    required this.actions,
    this.scale = 1,
    this.dense = false,
  });

  final List<LabAction> actions;
  final double scale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(height: 8 * scale),
          LabActionButton(action: actions[i], scale: scale, dense: dense),
        ],
      ],
    );
  }
}

/// A floating card the user can drag anywhere inside the area it fills.
/// Use it as `Positioned.fill(child: LabMovable(...))`: the card is placed
/// by [left] / [top] / [right] / [bottom] / [width] / [height] like a
/// [Positioned] (centred when none is set), then shifted by the drag. The
/// card itself moves, so it can be grabbed again wherever it is; taps on the
/// empty rest of the area pass through. Taps, sliders and drags on controls
/// inside the card still work; a drag that starts on the card moves it. The
/// card stays inside the area, and its position is kept per [id] in the
/// controller, so it comes back where it was left.
class LabMovable extends StatefulWidget {
  const LabMovable({
    super.key,
    required this.controller,
    required this.id,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.margin = const EdgeInsets.all(4),
  });

  final LabController controller;
  final String id;
  final Widget child;

  /// Space kept clear inside the area's edges (e.g. the canvas tool column).
  final EdgeInsets margin;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  @override
  State<LabMovable> createState() => _LabMovableState();
}

class _LabMovableState extends State<LabMovable> {
  final GlobalKey _cardKey = GlobalKey();
  bool _moving = false;
  Offset _startOffset = Offset.zero;
  Offset _startPointer = Offset.zero;

  /// The card's box without any drag, in area coordinates (taken at the
  /// start of each drag).
  Rect? _home;

  Offset get _offset => widget.controller.cardOffsets[widget.id] ?? Offset.zero;

  // Measured from the touch-down point, so the card follows the finger
  // exactly instead of lagging by the drag slop.
  void _down(DragDownDetails d) => _startPointer = d.globalPosition;

  void _start(DragStartDetails _) {
    _startOffset = _offset;
    final area = context.findRenderObject();
    final card = _cardKey.currentContext?.findRenderObject();
    _home = area is RenderBox && card is RenderBox && card.hasSize
        ? (card.localToGlobal(Offset.zero, ancestor: area) - _startOffset) & card.size
        : null;
    setState(() => _moving = true);
  }

  void _update(DragUpdateDetails d) {
    var offset = _startOffset + d.globalPosition - _startPointer;
    final area = context.findRenderObject();
    final home = _home;
    if (home != null && area is RenderBox && area.hasSize) {
      final bounds = widget.margin.deflateRect(Offset.zero & area.size);
      offset = Offset(
        _keepInside(offset.dx, home.left, home.right, bounds.left, bounds.right),
        _keepInside(offset.dy, home.top, home.bottom, bounds.top, bounds.bottom),
      );
    }
    setState(() => widget.controller.cardOffsets[widget.id] = offset);
  }

  /// Shift along one axis that keeps [start, end] inside [lo, hi]. A card
  /// bigger than the area may slide until its edges meet the area's.
  static double _keepInside(double shift, double start, double end, double lo, double hi) {
    final a = lo - start;
    final b = hi - end;
    return a <= b ? shift.clamp(a, b) : shift.clamp(b, a);
  }

  void _end() {
    if (_moving) setState(() => _moving = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final o = _offset;
    Widget grab(Widget card) => GestureDetector(
          key: _cardKey,
          onPanDown: _down,
          onPanStart: _start,
          onPanUpdate: _update,
          onPanEnd: (_) => _end(),
          onPanCancel: _end,
          child: AnimatedScale(
            scale: _moving ? 1.03 : 1,
            duration: const Duration(milliseconds: 120),
            child: card,
          ),
        );
    // Move the card itself, not a full-width Center / Align around it.
    final child = w.child;
    final placed = child is Align && child.child != null
        ? Align(
            key: child.key,
            alignment: child.alignment,
            widthFactor: child.widthFactor,
            heightFactor: child.heightFactor,
            child: grab(child.child!),
          )
        : grab(child);

    if (w.left == null && w.top == null && w.right == null && w.bottom == null) {
      return Center(child: Transform.translate(offset: o, child: placed));
    }
    final noX = w.left == null && w.right == null;
    final noY = w.top == null && w.bottom == null;
    return Stack(
      children: [
        Positioned(
          left: noX ? o.dx : (w.left == null ? null : w.left! + o.dx),
          right: w.right == null ? null : w.right! - o.dx,
          top: noY ? o.dy : (w.top == null ? null : w.top! + o.dy),
          bottom: w.bottom == null ? null : w.bottom! - o.dy,
          width: w.width,
          height: w.height,
          child: placed,
        ),
      ],
    );
  }
}

/// Frosted panel matching the HTML `.glass-panel`.
class LabGlassCard extends StatelessWidget {
  const LabGlassCard({
    super.key,
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 14,
    this.borderColor,
    this.color,
    this.shadow = true,
  });

  final LabPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? palette.panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? palette.border),
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}

/// Small uppercase section heading (HTML `uppercase tracking-widest`).
class LabSectionLabel extends StatelessWidget {
  const LabSectionLabel(this.text, {super.key, this.color, this.size = 11, this.icon});

  final String text;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LabStyleScope.of(context).palette.accent;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: size * 1.3, color: c),
          SizedBox(width: size * 0.45),
        ],
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: c,
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Labelled slider for sidebar controls (HTML `<input type="range">`).
class LabSliderControl extends StatelessWidget {
  const LabSliderControl({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueText,
    this.divisions,
    this.scale = 1,
    this.onChangeEnd,
    this.enabled = true,
    this.activeColor,
  });

  final LabPalette palette;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String? valueText;
  final int? divisions;
  final double scale;
  final bool enabled;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (valueText != null)
              Text(
                valueText!,
                style: TextStyle(
                  color: activeColor ?? palette.accent,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4 * scale,
            activeTrackColor: activeColor ?? palette.accent,
            thumbColor: activeColor ?? palette.accent,
            inactiveTrackColor: palette.cardBorder,
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * scale),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8 * scale),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}

/// A row of selectable chips (mode / material / option pickers).
class LabChoiceChips<T> extends StatelessWidget {
  const LabChoiceChips({
    super.key,
    required this.palette,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scale = 1,
    this.enabled = true,
  });

  final LabPalette palette;

  /// value -> label
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final double scale;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6 * scale,
      runSpacing: 6 * scale,
      children: [
        for (final e in options.entries)
          ChoiceChip(
            label: Text(
              e.value,
              style: TextStyle(
                fontSize: 11.5 * scale,
                fontWeight: FontWeight.w700,
                color: e.key == selected ? palette.onAccent : palette.text,
              ),
            ),
            selected: e.key == selected,
            selectedColor: palette.accent,
            backgroundColor: palette.card,
            side: BorderSide(color: palette.cardBorder),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: enabled
                ? (_) {
                    LabStyleScope.of(context).style.click.play();
                    onSelected(e.key);
                  }
                : null,
          ),
      ],
    );
  }
}

/// "Label ........ value" row for sidebar readouts.
class LabInfoRow extends StatelessWidget {
  const LabInfoRow({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    this.valueColor,
    this.scale = 1,
  });

  final LabPalette palette;
  final String label;
  final String value;
  final Color? valueColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: palette.textMuted, fontSize: 12 * scale, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? palette.textStrong,
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark rounded display used for HUD readouts (clocks, meters, timers).
class LabReadout extends StatelessWidget {
  const LabReadout({
    super.key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF4ADE80),
    this.scale = 1,
    this.fontSize = 22,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final double scale;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Scales down instead of overflowing while the canvas resizes.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: _box(LabStyleScope.of(context).palette),
    );
  }

  Widget _box(LabPalette p) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: p.readoutBg,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: p.readoutBorder, width: 2.5 * scale),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: p.readoutIcon, size: fontSize * scale),
            SizedBox(width: 10 * scale),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              color: color,
              fontSize: fontSize * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================= LAB SHELL

/// The common screen used by every Class 7 Science lab:
///
/// * intro curtain with "Enter Lab" (animated, with sound),
/// * collapsible, scrollable left sidebar (30% of the width; drag its right
///   edge to resize it between 20% and half the screen) holding the
///   header (title, language, reset, settings), scenario selector,
///   target output (mission objective + current step), all action buttons,
///   optional activity controls and the footer,
/// * a fixed menu button (top-left) that expands / collapses the sidebar,
///   and a back button (top-right, above everything, also on the curtain)
///   that returns to the home page,
/// * a floating mission card with the dynamic action buttons while the
///   sidebar is collapsed,
/// * the zoomable canvas with tool buttons (labels, lock, pan, reset view,
///   zoom in / out), feedback toast, HUD objective and activity overlays,
/// * the scrollable success popup and the settings dialog.
///
/// Every floating card (popup, settings, mission card, HUD objective and the
/// activity's overlay cards) can be dragged anywhere on screen ([LabMovable]).
///
/// Tones, colours and font come from the activity's [LabStyle] (via the
/// controller), so every lab sounds and looks the way its own file says.
class LabShell extends StatefulWidget {
  const LabShell({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stage,
    this.scenarioNames = const [],
    this.scenarioIndex = 0,
    this.onScenarioChanged,
    this.objective = '',
    this.steps = const [],
    this.currentStep = 1,
    this.instruction,
    this.actions = const [],
    this.sidebarExtra,
    this.sidebarExtraTitle,
    this.overlays = const [],
    this.onEnterLab,
    this.onReset,
    this.showHud = true,
    this.showTools = true,
  });

  final LabController controller;
  final IconData icon;
  final String title;
  final String subtitle;

  /// The scene, usually a [LabStage]. Wrapped in the zoomable viewer.
  final Widget stage;

  /// Localised scenario names (the HTML `<select>` options).
  final List<String> scenarioNames;
  final int scenarioIndex;

  /// Called with the new index. The shell plays the scenario sound.
  final ValueChanged<int>? onScenarioChanged;

  /// Localised mission objective for the current scenario.
  final String objective;

  /// Localised steps of the current scenario.
  final List<LabStep> steps;

  /// 1-based current step (may be steps.length + 1 when finished).
  final int currentStep;

  /// Overrides the current objective text (defaults to the step's action).
  final String? instruction;

  /// Dynamic action buttons for the current state.
  final List<LabAction> actions;

  /// Extra activity controls / readouts shown in the sidebar.
  final Widget? sidebarExtra;
  final String? sidebarExtraTitle;

  /// Positioned widgets drawn above the canvas (not zoomed): readouts,
  /// trays, result panels...
  final List<Widget> overlays;

  /// Called once the curtain has lifted (HTML `enterLab()` / `initThreeJS`).
  final VoidCallback? onEnterLab;

  /// Called on a full reset (HTML `resetApp(false)`) after the shell state
  /// has been restored; the activity resets its scenario / step / scene.
  final VoidCallback? onReset;

  /// Shows the "Current Objective" HUD at the bottom of the canvas while
  /// the sidebar is open.
  final bool showHud;
  final bool showTools;

  @override
  State<LabShell> createState() => _LabShellState();
}

class _LabShellState extends State<LabShell> with TickerProviderStateMixin {
  late final AnimationController _curtain = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
    value: widget.controller.isLabActive ? 1 : 0,
  );
  late final AnimationController _iconPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  /// True while the sidebar's edge is being dragged (no width animation).
  bool _resizing = false;
  double _resizeStartX = 0;
  double _resizeStartWidth = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.attachResetHook(_fullReset);
    // The "Enter Lab" button is built outside the curtain's AnimatedBuilder,
    // so rebuild when the curtain starts or stops moving; otherwise it stays
    // disabled after a full reset.
    _curtain.addStatusListener(_onCurtainStatus);
  }

  void _onCurtainStatus(AnimationStatus _) {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant LabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachResetHook();
      widget.controller.attachResetHook(_fullReset);
    }
  }

  @override
  void dispose() {
    widget.controller.detachResetHook();
    _curtain.dispose();
    _iconPulse.dispose();
    super.dispose();
  }

  void _enterLab() {
    if (_curtain.isAnimating) return;
    widget.controller.style.curtain.play();
    _curtain.forward().whenComplete(() {
      if (!mounted) return;
      _iconPulse.stop();
      widget.controller.markLabActive(true);
      widget.onEnterLab?.call();
    });
  }

  void _fullReset() {
    final c = widget.controller;
    c.style.curtain.play();
    c.resetShellState();
    c.markLabActive(false);
    _iconPulse.repeat(reverse: true);
    _curtain.reverse();
    widget.onReset?.call();
  }

  void _exit() {
    widget.controller.style.click.play();
    Navigator.of(context).maybePop();
  }

  /// Narrowest and widest sidebar for a screen of [width].
  (double, double) _sidebarRange(double width) {
    final min = math.max(180.0, width * 0.2);
    return (min, math.max(min, width * 0.5));
  }

  double _sidebarWidth(double width) {
    final (min, max) = _sidebarRange(width);
    return (width * widget.controller.sidebarFraction).clamp(min, max);
  }

  /// Grip on the sidebar's right edge: drag it to resize the sidebar.
  Widget _resizeHandle(LabPalette p, double width) {
    final c = widget.controller;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragDown: (d) {
          _resizeStartX = d.globalPosition.dx;
          _resizeStartWidth = _sidebarWidth(width);
        },
        onHorizontalDragStart: (_) => setState(() => _resizing = true),
        onHorizontalDragUpdate: (d) => setState(() {
          final (min, max) = _sidebarRange(width);
          final w = _resizeStartWidth + d.globalPosition.dx - _resizeStartX;
          c.sidebarFraction = w.clamp(min, max) / width;
        }),
        onHorizontalDragEnd: (_) => setState(() => _resizing = false),
        onHorizontalDragCancel: () => setState(() => _resizing = false),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 4,
            height: _resizing ? 64 : 40,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: _resizing ? 0.9 : 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  /// Room kept clear of canvas cards: the tool column on the right.
  EdgeInsets _canvasMargin(EdgeInsets pad) =>
      EdgeInsets.fromLTRB(4, 4, widget.showTools ? 56 + pad.right : 4, 4);

  /// Activity overlay cards can be dragged anywhere on the canvas. Full-size
  /// layers (Positioned.fill) stay put.
  Widget _movableOverlay(Widget overlay, int index, EdgeInsets margin) {
    if (overlay is! Positioned) return overlay;
    if (overlay.left == 0 && overlay.top == 0 && overlay.right == 0 && overlay.bottom == 0) {
      return overlay;
    }
    return Positioned.fill(
      key: overlay.key,
      child: LabMovable(
        controller: widget.controller,
        id: 'overlay-$index-${overlay.child.runtimeType}',
        margin: margin,
        left: overlay.left,
        top: overlay.top,
        right: overlay.right,
        bottom: overlay.bottom,
        width: overlay.width,
        height: overlay.height,
        child: overlay.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final p = c.palette;
        // Canvas text (labText) follows the lab's font.
        final font = c.style.font.orAmbient(Theme.of(context).textTheme.bodyMedium);
        LabFont.active = font;
        final size = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final s = context.labScale;
        final sidebarW = _sidebarWidth(size.width);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          },
          child: Theme(
            data: p.theme(font),
            child: LabStyleScope(
              style: c.style,
              palette: p,
              child: Scaffold(
                backgroundColor: p.bg,
                body: Stack(
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: _resizing ? Duration.zero : const Duration(milliseconds: 380),
                          curve: Curves.easeInOutCubic,
                          width: c.isSidebarOpen ? sidebarW : 0,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: sidebarW,
                                    maxWidth: sidebarW,
                                    child: _Sidebar(shell: widget, palette: p, scale: s),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                width: 10,
                                child: _resizeHandle(p, size.width),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildCanvas(context, p, s, pad)),
                      ],
                    ),
                    if (!c.isSidebarOpen && c.isLabActive)
                      Positioned.fill(
                        child: LabMovable(
                          controller: c,
                          id: 'mission',
                          top: 12 + pad.top,
                          left: 76 + pad.left,
                          child: _FloatingMissionCard(shell: widget, palette: p, scale: s),
                        ),
                      ),
                    // Menu button: fixed position, won't slide with the sidebar,
                    // always in front of the sidebar and canvas.
                    Positioned(
                      top: 16 + pad.top,
                      left: 16 + pad.left,
                      child: _fixedButton(
                        p,
                        tooltip: c.t('menu'),
                        icon: c.isSidebarOpen ? Icons.menu_open : Icons.menu,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          c.toggleSidebar();
                        },
                      ),
                    ),
                    if (c.popup != null) _PopupLayer(controller: c, palette: p, scale: s),
                    if (c.settingsOpen) _SettingsLayer(controller: c, palette: p, scale: s),
                    _buildCurtain(context, p, s, pad),
                    // Back button: top-right, above the tool column, in front of
                    // everything (curtain included) so it is always reachable.
                    Positioned(
                      top: 16 + pad.top,
                      right: 8 + pad.right,
                      child: _fixedButton(
                        p,
                        tooltip: c.t('back_home'),
                        icon: Icons.arrow_back_rounded,
                        onPressed: _exit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The menu / back button (48 px tap target).
  Widget _fixedButton(
    LabPalette p, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      color: p.buttonIcon,
      iconSize: 28,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: p.buttonBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.buttonBorder),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    final w = widget;
    final instruction = _currentInstruction(w);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: p.canvasBg),
          LabZoomViewer(controller: c, child: w.stage),
          for (var i = 0; i < w.overlays.length; i++) _movableOverlay(w.overlays[i], i, _canvasMargin(pad)),
          if (w.showHud && c.isSidebarOpen && instruction.isNotEmpty)
            Positioned.fill(
              child: LabMovable(
                controller: c,
                id: 'hud',
                margin: _canvasMargin(pad),
                left: 12,
                right: 60 + pad.right,
                bottom: 8 + pad.bottom,
                child: Center(
                  child: _HudChip(text: instruction, palette: p, scale: s, label: c.t('curr_obj')),
                ),
              ),
            ),
          if (w.showTools)
            Positioned(
              right: 8 + pad.right,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ToolsPanel(controller: c, palette: p, scale: s),
              ),
            ),
          // Kept clear of the floating mission card and the tool column.
          Positioned(
            top: 10 + pad.top,
            left: labOverlayInsets(context, c).left + 4,
            right: labOverlayInsets(context, c).right,
            child: Center(
              child: _ToastView(toast: c.toast, palette: p, scale: s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurtain(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: _curtain,
      builder: (context, child) {
        if (_curtain.value >= 1) return const SizedBox.shrink();
        final dy = Curves.easeInOutCubic.transform(_curtain.value);
        return FractionalTranslation(translation: Offset(0, -dy), child: child);
      },
      child: Material(
        color: p.curtainBg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [p.curtainGlow, p.curtainBg.withValues(alpha: 0)], radius: 0.9),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32 * s, vertical: 24 * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween(begin: 0.55, end: 1.0).animate(_iconPulse),
                            child: Icon(widget.icon, size: 56 * s, color: p.accent),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainText,
                              fontSize: 30 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: p.curtainMuted, fontSize: 15 * s, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 24 * s),
                          FilledButton.icon(
                            onPressed: _curtain.isAnimating ? null : _enterLab,
                            icon: Icon(Icons.play_arrow_rounded, size: 22 * s),
                            label: Text(c.t('enter_lab')),
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: p.onAccent,
                              padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 14 * s),
                              textStyle: TextStyle(fontSize: 17 * s, fontWeight: FontWeight.w800),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Left of the back button, which the shell draws above the curtain.
            Positioned(
              top: 20 + pad.top,
              right: 64 + pad.right,
              child: TextButton.icon(
                onPressed: c.toggleLanguage,
                icon: const Icon(Icons.translate, size: 18),
                label: Text(c.lang.badge, style: const TextStyle(fontWeight: FontWeight.w800)),
                style: TextButton.styleFrom(foregroundColor: p.curtainIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Width of the floating mission card shown while the sidebar is collapsed.
double _missionCardWidth(Size size, double s) => (size.width * 0.36).clamp(200.0, 380.0 * s);

/// Insets (relative to the canvas area) that keep activity overlays clear
/// of the shell's own canvas UI: the tool column on the right and, while
/// the sidebar is collapsed, the menu button + floating mission card on the
/// left. Use `left`/`right` for overlays placed along the top edge, e.g.
/// `Positioned(top: 10, left: i.left, right: i.right, child: Center(...))`.
EdgeInsets labOverlayInsets(BuildContext context, LabController c) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final s = context.labScale;
  final left = c.isSidebarOpen ? 8.0 : 76 + pad.left + _missionCardWidth(size, s) + 8;
  return EdgeInsets.fromLTRB(left, 8 + pad.top, 56 + pad.right, 8 + pad.bottom);
}

String _currentInstruction(LabShell w) {
  if (w.instruction != null) return w.instruction!;
  if (w.steps.isEmpty) return '';
  final i = (w.currentStep - 1).clamp(0, w.steps.length - 1);
  return w.steps[i].action;
}

// ============================================================== SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.shell, required this.palette, required this.scale});

  final LabShell shell;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = shell.controller;
    final p = palette;
    final s = scale;
    final f = s * c.fontScale;
    final pad = MediaQuery.paddingOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(right: BorderSide(color: p.border)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(4, 0))],
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(12 * s + pad.left, 12 + pad.top, 12 * s, 8 * s),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _header(context, p, s),
                SizedBox(height: 12 * s),
                if (shell.scenarioNames.length > 1) ...[_scenarioSelector(p, s, f), SizedBox(height: 12 * s)],
                _targetOutput(p, s, f),
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(c.t('actions'), size: 10.5 * s, icon: Icons.touch_app),
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s),
                ],
                if (shell.sidebarExtra != null) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(shell.sidebarExtraTitle ?? c.t('controls'), size: 10.5 * s, icon: Icons.tune),
                  SizedBox(height: 8 * s),
                  shell.sidebarExtra!,
                ],
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10 * s + pad.left, 10 * s, 10 * s, 10 * s + pad.bottom),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: Text(
                  c.t('footer'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text.withValues(alpha: 0.85),
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, LabPalette p, double s) {
    final c = shell.controller;
    Widget headerBtn(IconData icon, String tip, VoidCallback onTap, {String? text}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17 * s, color: p.textStrong),
                if (text != null) ...[
                  SizedBox(width: 4 * s),
                  Text(
                    text,
                    style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12 * s),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Leaves room for the fixed menu button at top-left.
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Container(
                  width: 34 * s,
                  height: 34 * s,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(shell.icon, color: p.accent, size: 20 * s),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shell.title,
                        style: TextStyle(
                          color: p.textStrong,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5 * s,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        shell.subtitle,
                        style: TextStyle(color: p.textMuted, fontSize: 10 * s, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Wrap(
          spacing: 6 * s,
          runSpacing: 6 * s,
          alignment: WrapAlignment.center,
          children: [
            headerBtn(Icons.translate, c.t('toggle_language'), c.toggleLanguage, text: c.lang.badge),
            headerBtn(Icons.restart_alt, c.t('reset_lab'), () {
              c.style.click.play();
              c.requestFullReset();
            }),
            headerBtn(Icons.settings, c.t('settings'), c.toggleSettings),
          ],
        ),
      ],
    );
  }

  Widget _scenarioSelector(LabPalette p, double s, double f) {
    final c = shell.controller;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c.t('select_scenario').toUpperCase(),
            style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          SizedBox(height: 6 * s),
          for (var i = 0; i < shell.scenarioNames.length; i++) ...[
            if (i > 0) SizedBox(height: 6 * s),
            _scenarioTile(p, s, f, i),
          ],
        ],
      ),
    );
  }

  Widget _scenarioTile(LabPalette p, double s, double f, int i) {
    final c = shell.controller;
    final selected = i == shell.scenarioIndex;
    final done = c.completedScenarios.contains(i);
    return Material(
      color: selected ? p.accent.withValues(alpha: 0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: selected || shell.onScenarioChanged == null
            ? null
            : () {
                c.style.scenario.play();
                shell.onScenarioChanged!(i);
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.accent : p.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : (selected ? Icons.menu_book : Icons.radio_button_unchecked),
                size: 16 * s,
                color: done ? p.success : (selected ? p.accent : p.textMuted),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  shell.scenarioNames[i],
                  style: TextStyle(
                    color: selected ? p.textStrong : p.text,
                    fontSize: 11.5 * f,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetOutput(LabPalette p, double s, double f) {
    final c = shell.controller;
    final steps = shell.steps;
    final hasSteps = steps.isNotEmpty;
    final cur = shell.currentStep;
    final idx = hasSteps ? (cur - 1).clamp(0, steps.length - 1) : 0;
    final step = hasSteps ? steps[idx] : null;
    final instruction = _currentInstruction(shell);

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabSectionLabel(c.t('target_output'), size: 10.5 * s, icon: Icons.track_changes),
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              c.t('mission_obj'),
              style: TextStyle(color: p.textMuted, fontSize: 10 * f, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3 * s),
            Text(
              shell.objective,
              style: TextStyle(color: p.text, fontSize: 12.5 * f, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ],
          if (hasSteps) ...[
            SizedBox(height: 10 * s),
            Row(
              children: [
                Text(
                  '${c.t('step')} ${cur.clamp(1, steps.length)} ${c.t('of')} ${steps.length}',
                  style: TextStyle(color: p.textStrong, fontSize: 11 * f, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Wrap(
                    spacing: 4 * s,
                    runSpacing: 4 * s,
                    alignment: WrapAlignment.end,
                    children: [
                      for (var i = 1; i <= steps.length; i++)
                        Container(
                          width: 16 * s,
                          height: 16 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < cur
                                ? p.info.withValues(alpha: 0.25)
                                : (i == cur ? p.accent : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(color: i < cur ? p.info : (i == cur ? p.accent : p.cardBorder)),
                          ),
                          child: i < cur
                              ? Icon(Icons.check, size: 10 * s, color: p.info)
                              : Text(
                                  '$i',
                                  style: TextStyle(
                                    fontSize: 8.5 * s,
                                    fontWeight: FontWeight.w800,
                                    color: i == cur ? p.onAccent : p.textMuted,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (instruction.isNotEmpty) ...[
            SizedBox(height: 10 * s),
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.accent.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 14 * s, color: p.accent),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          c.t('curr_obj').toUpperCase(),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 9.5 * f,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step != null && step.concept.isNotEmpty && shell.instruction == null) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      '${c.t('concept_focus')} ${step.concept}',
                      style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w700),
                    ),
                  ],
                  SizedBox(height: 4 * s),
                  Text(
                    instruction,
                    style: TextStyle(color: p.textStrong, fontSize: 12.5 * f, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================= FLOATING MISSION CARD

class _FloatingMissionCard extends StatefulWidget {
  const _FloatingMissionCard({required this.shell, required this.palette, required this.scale});

  final LabShell shell;
  final LabPalette palette;
  final double scale;

  @override
  State<_FloatingMissionCard> createState() => _FloatingMissionCardState();
}

class _FloatingMissionCardState extends State<_FloatingMissionCard> {
  bool _minimized = false;

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    final c = shell.controller;
    final p = widget.palette;
    final s = widget.scale;
    final size = MediaQuery.sizeOf(context);
    final width = _missionCardWidth(size, s);
    final instruction = _currentInstruction(shell);
    final steps = shell.steps;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: size.height - 24),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(10 * s),
        borderColor: p.accent.withValues(alpha: 0.6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, size: 15 * s, color: p.accent),
                  SizedBox(width: 5 * s),
                  Expanded(
                    child: Text(
                      c.t('mission_obj').toUpperCase(),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      c.style.click.play();
                      setState(() => _minimized = !_minimized);
                    },
                    child: Tooltip(
                      message: _minimized ? c.t('expand') : c.t('minimize'),
                      child: Icon(_minimized ? Icons.expand_more : Icons.expand_less, size: 20 * s, color: p.textMuted),
                    ),
                  ),
                ],
              ),
              if (!_minimized) ...[
                if (shell.objective.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Text(
                    shell.objective,
                    style: TextStyle(color: p.text, fontSize: 11.5 * s, height: 1.35, fontWeight: FontWeight.w500),
                  ),
                ],
                if (instruction.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: p.accent.withValues(alpha: 0.5)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (steps.isNotEmpty)
                            TextSpan(
                              text: '${c.t('step')} ${shell.currentStep.clamp(1, steps.length)}/${steps.length} • ',
                              style: TextStyle(color: p.accent, fontWeight: FontWeight.w800),
                            ),
                          TextSpan(text: instruction),
                        ],
                      ),
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 11.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s, dense: true),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================ CANVAS UI

class _HudChip extends StatelessWidget {
  const _HudChip({required this.text, required this.palette, required this.scale, required this.label});

  final String text;
  final String label;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520 * s),
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        borderColor: palette.accent.withValues(alpha: 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, size: 12 * s, color: palette.accent),
                SizedBox(width: 4 * s),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 9 * s,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2 * s),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textStrong, fontWeight: FontWeight.w700, fontSize: 11 * s, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale.clamp(0.85, 1.25);
    Widget tool(IconData icon, String tip, VoidCallback onTap, {bool active = false}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 34 * s,
            height: 34 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: active ? p.accent.withValues(alpha: 0.18) : Colors.transparent,
            ),
            child: Icon(icon, size: 19 * s, color: active ? p.accent : p.textMuted),
          ),
        ),
      );
    }

    final divider = Container(
      width: 24 * s,
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 3 * s),
      color: p.cardBorder,
    );

    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.all(4 * s),
      radius: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tool(c.showLabels ? Icons.label : Icons.label_off, c.t('tool_labels'), c.toggleLabels, active: c.showLabels),
          divider,
          tool(c.camLocked ? Icons.lock : Icons.lock_open, c.t('tool_lock'), c.toggleCamLock, active: c.camLocked),
          tool(Icons.pan_tool_alt, c.t('tool_pan'), c.togglePanMode, active: c.panMode),
          tool(Icons.center_focus_strong, c.t('tool_reset_view'), c.resetView),
          tool(Icons.zoom_in, c.t('tool_zoom_in'), c.zoomIn),
          tool(Icons.zoom_out, c.t('tool_zoom_out'), c.zoomOut),
        ],
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.toast, required this.palette, required this.scale});

  final LabToast? toast;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = toast;
    final s = scale;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: t == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(t.id),
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                  color: t.isError ? palette.danger : palette.toastBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.isError ? Icons.error : Icons.info,
                      size: 16 * s,
                      color: t.isError ? palette.onDanger : palette.toastText,
                    ),
                    SizedBox(width: 6 * s),
                    Flexible(
                      child: Text(
                        t.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.isError ? palette.onDanger : palette.toastText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5 * s,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ==================================================================== POPUP

class _PopupLayer extends StatelessWidget {
  const _PopupLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final builder = c.popup;
    if (builder == null) return const SizedBox.shrink();
    final content = builder();
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final accent = content.accent ?? p.accent;
    final width = (size.width * 0.6).clamp(260.0, 470.0 * s);

    return Positioned.fill(
      child: LabMovable(
        controller: c,
        id: 'popup',
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(scale: v, child: child),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: size.height * 0.86),
              decoration: BoxDecoration(
                color: p.popupBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (drag anywhere on the card to move it).
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                    decoration: BoxDecoration(
                      color: p.popupHeader,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Icon(content.icon, color: accent, size: 18 * s),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            content.title,
                            style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 14 * s),
                          ),
                        ),
                        Icon(Icons.drag_indicator, size: 18 * s, color: p.textMuted),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: c.t('close'),
                          onPressed: () => c.hidePopup(),
                          icon: Icon(Icons.close, size: 18 * s, color: p.text),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(14 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (content.heading != null) ...[
                            Container(
                              padding: EdgeInsets.only(bottom: 4 * s),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: p.cardBorder)),
                              ),
                              child: Text(
                                content.heading!.toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5 * s,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: 8 * s),
                          ],
                          if (content.body != null)
                            Text(
                              content.body!,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13 * s * c.fontScale.clamp(0.9, 1.4),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          if (content.extra != null) ...[SizedBox(height: 10 * s), content.extra!],
                          if (content.actions.isNotEmpty) ...[
                            SizedBox(height: 14 * s),
                            LabActionList(actions: content.actions, scale: s),
                          ],
                        ],
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
}

// ================================================================= SETTINGS

class _SettingsLayer extends StatelessWidget {
  const _SettingsLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final label = TextStyle(color: p.textStrong, fontSize: 13 * s, fontWeight: FontWeight.w600);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: c.toggleSettings,
              child: const ColoredBox(color: Color(0x80000000)),
            ),
          ),
          Positioned.fill(
            child: LabMovable(
              controller: c,
              id: 'settings',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: (size.width * 0.5).clamp(260.0, 360.0 * s),
                  constraints: BoxConstraints(maxHeight: size.height * 0.88),
                  decoration: BoxDecoration(
                    color: p.dialogBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(18 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.t('settings'),
                                style: TextStyle(color: p.textStrong, fontSize: 17 * s, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: c.toggleSettings,
                              tooltip: c.t('close'),
                              icon: Icon(Icons.close, color: p.text),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('theme'), style: label)),
                            FilledButton.tonalIcon(
                              onPressed: c.toggleTheme,
                              icon: Icon(c.isDark ? Icons.dark_mode : Icons.light_mode, size: 18 * s),
                              label: Text(c.isDark ? c.t('light_mode') : c.t('dark_mode')),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('font_size'), style: label)),
                            Text(
                              '${c.fontSize.round()}px',
                              style: TextStyle(color: p.textMuted, fontSize: 12 * s),
                            ),
                          ],
                        ),
                        Slider(
                          value: c.fontSize,
                          min: c.style.font.minSize,
                          max: c.style.font.maxSize,
                          divisions: (c.style.font.maxSize - c.style.font.minSize).round(),
                          onChanged: c.setFontSize,
                        ),
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
}
