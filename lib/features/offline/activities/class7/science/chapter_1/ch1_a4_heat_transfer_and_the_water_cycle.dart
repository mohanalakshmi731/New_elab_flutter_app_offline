// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 1 • Activity 4
/// Heat Transfer & Water Cycle.
///
/// Native Flutter port of `Cl7S-Ch1-A4-Heat_Transfer_and_the_Water_Cycle.html`.
/// Scenario 1: drag a beaker, an ice cube and a sun lamp from the lab tray,
/// then press and hold "Hold Heat" until the ice melts (heat transfer).
/// Scenario 2: a 2D cross-section of the water cycle: place and raise the
/// Sun (evaporation), click the vapour (condensation), drag the cloud over
/// the land (movement) and click it until it rains (precipitation).
class Ch1A4HeatTransferAndTheWaterCyclePage extends StatefulWidget {
  const Ch1A4HeatTransferAndTheWaterCyclePage({super.key});

  @override
  State<Ch1A4HeatTransferAndTheWaterCyclePage> createState() =>
      _Ch1A4HeatTransferAndTheWaterCyclePageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, splash 1311,
/// switchTap 2585, fire 1348, magic 871, whoosh 1492.
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
  splash('splash.mp3'),
  switchTap('switch.mp3'),
  fire('fire.mp3'),
  magic('magic.mp3'),
  whoosh('whoosh.mp3');

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
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color amber = Color(0xFFF59E0B);
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

/// Minimal TWEEN.js replacement driven by the scene ticker.
class _Tw {
  _Tw(this.start, this.duration, this.curve, this.update, this.done);
  final double start; // scene seconds (includes any delay)
  final double duration; // seconds
  final Curve curve;
  final void Function(double v) update;
  final VoidCallback? done;
}

class _Ch1A4HeatTransferAndTheWaterCyclePageState
    extends State<Ch1A4HeatTransferAndTheWaterCyclePage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A4Scene _scene = _A4Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();
  final List<_Tw> _tweens = [];

  late final Ticker _ticker;
  double _lastTick = 0;

  int _step = 0; // 0-based, like `config.currentStep`
  bool _taskComplete = false;
  int? _pointer; // active pointer id on the stage
  double _stepStart = 0; // scene time when the current step was loaded

  int get _scenario => _scene.scenario;
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

    _ticker = createTicker(_onTick)..start();
    _loadScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _lastTick).clamp(0.0, 0.1);
    _lastTick = now;
    _scene.time = now;

    // Tweens (TWEEN.update()).
    if (_tweens.isNotEmpty) {
      for (final tw in List<_Tw>.of(_tweens)) {
        if (!_tweens.contains(tw)) continue;
        final p = (now - tw.start) / tw.duration;
        if (p < 0) continue;
        if (p >= 1) {
          tw.update(tw.curve.transform(1));
          _tweens.remove(tw);
          tw.done?.call();
        } else {
          tw.update(tw.curve.transform(p));
        }
      }
    }

    if (_scenario == 0) {
      _updateHoldSimulation(dt);
    } else {
      _scene.updateRain(dt);
    }
    _frame.value = now;
  }

  /// `new TWEEN.Tween(...).to(..., ms).delay(delay).easing(curve)`.
  void _tween(int ms, void Function(double v) update,
      {Curve curve = Curves.linear, int delay = 0, VoidCallback? done}) {
    _tweens.add(_Tw(_scene.time + delay / 1000, ms / 1000, curve, update, done));
  }

  double _lerp(double a, double b, double v) => a + (b - a) * v;

  // ------------------------------------------------------------ flow

  /// HTML `loadScenario(id)`: rebuilds the environment and loads step 0.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _tweens.clear();
    _pointer = null;
    _scene.build(index, _rng);
    _step = 0;
    _lab.hidePopup(sound: false);
    _lab.resetView(sound: false);
    _loadStep();
  }

  void _changeScenario(int index) {
    setState(() => _loadScenario(index));
  }

  void _fullReset() {
    setState(() => _loadScenario(0));
  }

  /// HTML `loadStep()`: runs the step's `onInit`.
  void _loadStep() {
    _taskComplete = false;
    _stepStart = _scene.time;
    final sc = _scene;
    if (_scenario == 0) {
      switch (_step) {
        case 0:
          sc.activateProxy('beaker');
        case 1:
          sc.activateProxy('ice');
        case 2:
          sc.activateProxy('lamp');
        case 3:
          sc.holdUi = true;
          sc.heat = 0;
        case 4:
          sc.arrow = true;
          sc.arrowSince = sc.time;
          _lab.after(const Duration(milliseconds: 3000), () {
            if (mounted) _validateStep();
          });
      }
    } else {
      switch (_step) {
        case 0:
          sc.activateProxy('sun');
        case 1:
          sc.sunDrag = true;
        case 2:
          sc.vaporClick = true;
          sc.vaporClicks = 0;
        case 3:
          sc.cloudDrag = true;
        case 4:
          sc.rainClick = true;
          sc.rainClicks = 0;
        case 5:
          _showCycleArrows();
          _lab.after(const Duration(milliseconds: 6000), () {
            if (mounted) _validateStep();
          });
      }
    }
  }

  /// HTML `validateStep()`: runs `onSuccess`, shows "Task Completed!" and
  /// moves on after 2 s.
  void _validateStep() {
    if (_taskComplete) return;
    setState(() {
      _taskComplete = true;
      _onSuccess();
    });
    _Audio.play(_Sound.correct);
    _lab.after(const Duration(milliseconds: 2000), _nextStep);
  }

  void _onSuccess() {
    final sc = _scene;
    if (_scenario == 0) {
      switch (_step) {
        case 0:
          _placeBeaker();
        case 1:
          _placeIce();
        case 2:
          _placeLamp();
        case 3:
          sc.holdUi = false;
          sc.holding = false;
      }
    } else {
      switch (_step) {
        case 0:
          _placeSun();
        case 1:
          sc.sunDrag = false;
        case 2:
          sc.lblCondensation = true;
        case 3:
          sc.cloudDrag = false;
        case 4:
          _startPuddle();
          sc.lblPrecipitation = true;
      }
    }
  }

  /// HTML `nextStep()`.
  void _nextStep() {
    if (!mounted) return;
    final count = _data.steps.length;
    if (_step < count - 1) {
      setState(() {
        _step++;
        _loadStep();
      });
    } else {
      final scenario = _scenario;
      _lab.showScenarioConclusion(
        scenarioIndex: scenario,
        totalScenarios: 2,
        delay: const Duration(milliseconds: 1000),
        title: () => _t('obs_title'),
        heading: () => _scenarios[_lab.lang.code]![scenario].title,
        body: () => _t('obs_${scenario + 1}'),
      );
    }
  }

  // ------------------------------------------------- scenario 1 actions

  /// HTML `placeBeaker()`: drops in from y = 5 with a bounce.
  void _placeBeaker() {
    final sc = _scene;
    sc.beaker = true;
    sc.beakerY = 5;
    _tween(800, (v) => sc.beakerY = _lerp(5, 0, v), curve: Curves.bounceOut,
        done: () => _Audio.play(_Sound.drop));
  }

  /// HTML `placeIce()`: falls into the beaker (clink) and the camera moves in.
  void _placeIce() {
    final sc = _scene;
    sc.ice = true;
    sc.iceY = 8;
    sc.iceScale = 1;
    sc.iceRot = [_rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble()];
    _tween(600, (v) => sc.iceY = _lerp(8, 0.95, v), curve: Curves.easeInQuad,
        done: () => _Audio.play(_Sound.pop));
    final from = sc.camZ;
    _tween(1000, (v) => sc.camZ = _lerp(from, 20, v), curve: Curves.easeOutCubic);
  }

  /// HTML `placeLamp()`: drops in at (-9.5, 0, 0), then aims at the beaker
  /// and switches on (light cone + spot light).
  void _placeLamp() {
    final sc = _scene;
    sc.lamp = true;
    sc.lampY = 5;
    _tween(800, (v) => sc.lampY = _lerp(5, 0, v), curve: Curves.bounceOut, done: () {
      _Audio.play(_Sound.switchTap);
      sc.lampLit = true;
      sc.heat = 0;
    });
  }

  /// HTML `updateHoldSimulation(delta)`: heat rises by 20 / s while held.
  void _updateHoldSimulation(double dt) {
    final sc = _scene;
    if (!sc.lampLit || sc.iceMelted || !sc.holding) return;
    sc.heat += dt * 20;
    if (sc.heat >= 100) {
      sc.heat = 100;
      sc.iceMelted = true;
      if (_step == 3) _validateStep();
    }
    sc.applyHeat();
  }

  void _holdStart() {
    if (!_scene.holdUi || _scene.holding) return;
    _Audio.play(_Sound.fire);
    setState(() => _scene.holding = true);
  }

  void _holdEnd() {
    if (!_scene.holding) return;
    setState(() => _scene.holding = false);
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML `placeSun()`: the real Sun appears at (-15, 12) and the sky brightens.
  void _placeSun() {
    final sc = _scene;
    sc.sun = true;
    sc.sunY = 12;
    final from = sc.skyT;
    _tween(1000, (v) => sc.skyT = _lerp(from, 1, v));
    _Audio.play(_Sound.magic);
  }

  /// HTML `updateEvaporation(intensity)`.
  void _updateEvaporation(double intensity) {
    final sc = _scene;
    sc.intensity = intensity;
    if (!sc.vapors && intensity > 0.1) sc.vapors = true;
    sc.seaDrop = intensity * 1.5;
    if (intensity > 0.9 && !sc.evaporationComplete) {
      sc.evaporationComplete = true;
      _validateStep();
    }
  }

  /// HTML `handleVaporClick()`: each click grows the cloud by 0.33.
  void _handleVaporClick() {
    final sc = _scene;
    _Audio.play(_Sound.pop);
    sc.vaporClicks++;
    sc.cloud = true;
    final from = sc.cloudScale;
    final to = sc.vaporClicks * 0.33;
    _tween(500, (v) => sc.cloudScale = _lerp(from, to, v), curve: Curves.elasticOut);
    if (sc.vaporClicks >= 3) {
      sc.vaporClick = false;
      _tween(500, (v) => sc.vaporFade = 1 - v);
      sc.cloudFormed = true;
      _validateStep();
    } else {
      setState(() {});
    }
  }

  /// HTML `handleRainClick()`: the cloud turns grey; rain after 3 clicks.
  void _handleRainClick() {
    final sc = _scene;
    _Audio.play(_Sound.pop);
    sc.rainClicks++;
    sc.cloudGrey = sc.cloudGrey + (1 - sc.cloudGrey) * 0.35;
    if (sc.rainClicks >= 3 && !sc.rainComplete) {
      sc.rainClick = false;
      sc.rainComplete = true;
      _startRaining();
      _validateStep();
    } else {
      setState(() {});
    }
  }

  /// HTML `startRaining()`: rain under the cloud, trees turn green (2 s).
  void _startRaining() {
    final sc = _scene;
    sc.startRain(_rng);
    _Audio.play(_Sound.splash);
    _tween(2000, (v) => sc.treeGreen = v);
  }

  /// HTML `startPuddle()`: a puddle spreads on the land, 15 drops trickle
  /// down into the sea and the sea level recovers.
  void _startPuddle() {
    final sc = _scene;
    sc.puddle = true;
    _tween(1000, (v) => sc.puddleScale = v);
    for (var i = 0; i < 15; i++) {
      final k = i;
      _tween(2000, (v) => sc.drops[k] = v,
          curve: Curves.easeInQuad, delay: 1000 + k * 150, done: () => sc.drops[k] = 2);
    }
    _lab.after(const Duration(milliseconds: 1000 + 15 * 150 + 1000), () {
      if (!mounted) return;
      final from = sc.seaDrop;
      _tween(1500, (v) => sc.seaDrop = _lerp(from, 0, v));
      _Audio.play(_Sound.splash);
    });
  }

  /// HTML `showCycleArrows()`: five arrows grow in one after another.
  void _showCycleArrows() {
    final sc = _scene;
    sc.cycle = true;
    for (var i = 0; i < 5; i++) {
      final k = i;
      _tween(500, (v) => sc.arrowScale[k] = v, curve: Curves.easeOutBack, delay: k * 600);
    }
    _Audio.play(_Sound.whoosh);
  }

  // ------------------------------------------------- pointer (raycaster)

  /// HTML `onPointerDown`: picks the active proxy, the Sun, the vapour,
  /// the cloud (drag) or the cloud (rain clicks).
  void _onDown(PointerDownEvent e) {
    if (_pointer != null || !_lab.isLabActive) return;
    final sc = _scene;
    final pos = e.localPosition;
    final proxy = sc.activeProxy;
    if (proxy != null && sc.hitProxy(proxy, pos)) {
      _pointer = e.pointer;
      sc.dragging = proxy;
      proxy.labelHidden = true;
      _Audio.play(_Sound.pickup);
      setState(() {});
      return;
    }
    if (_scenario != 1) return;
    if (sc.sunDrag && sc.hitSun(pos)) {
      _pointer = e.pointer;
      sc.draggingSun = true;
    } else if (sc.vaporClick && sc.hitVapor(pos)) {
      _handleVaporClick();
    } else if (sc.cloudDrag && sc.hitCloud(pos, 7.5, 5, 3)) {
      _pointer = e.pointer;
      sc.draggingCloud = true;
    } else if (sc.rainClick && sc.hitCloud(pos, 10, 7.5, 4)) {
      _handleRainClick();
    }
  }

  /// HTML `onPointerMove`.
  void _onMove(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final sc = _scene;
    final pos = e.localPosition;
    final proxy = sc.dragging;
    if (proxy != null) {
      if (_scenario == 0) {
        final w = sc.unprojectY(pos, 1.5);
        if (w != null) {
          proxy.pos = _V3(w.x.clamp(-16, 16), 1.5, w.z.clamp(-10, 10));
        }
      } else {
        final w = sc.unproject2(pos, 2);
        proxy.pos = _V3(w.dx.clamp(-35, 35), w.dy.clamp(-10, 35), 2);
      }
    } else if (sc.draggingSun) {
      if (!sc.sunDrag) return; // hit box removed once evaporation completed
      final w = sc.unproject2(pos, 2);
      final y = w.dy.clamp(12.0, 26.0);
      sc.sunY = y;
      _updateEvaporation((y - 12) / 14);
    } else if (sc.draggingCloud) {
      final w = sc.unproject2(pos, 3);
      final x = w.dx.clamp(-20.0, 24.0);
      sc.cloudX = x;
      if (x > 15 && !sc.cloudMoved) {
        sc.cloudMoved = true;
        _validateStep();
      }
    }
  }

  /// HTML `onPointerUp`: validates a proxy drop or sends it back to the tray.
  void _onUp(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    final sc = _scene;
    final proxy = sc.dragging;
    sc.draggingSun = false;
    sc.draggingCloud = false;
    if (proxy == null) return;
    sc.dragging = null;
    final drop = _scenario == 0 ? _V3(proxy.pos.x, 0, proxy.pos.z) : proxy.pos;
    if (_isValidDrop(proxy.type, drop)) {
      proxy.visible = false;
      proxy.active = false;
      _validateStep();
      return;
    }
    final from = proxy.pos;
    final to = proxy.home;
    if ((from - to).length > 0.6) {
      _lab.showToast(_t('msg_wrong_drop'), isError: true);
    }
    _tween(400, (v) => proxy.pos = _V3.lerp(from, to, v), curve: Curves.easeOutQuad, done: () {
      proxy.labelHidden = false;
    });
    setState(() {});
  }

  /// The `validate(dropPos, type)` rules of the drag steps.
  bool _isValidDrop(String type, _V3 d) {
    if (_scenario == 0) {
      switch (_step) {
        case 0:
          return type == 'beaker' && d.x.abs() < 5 && d.z.abs() < 5;
        case 1:
          return type == 'ice' && _scene.beaker && d.x.abs() < 4 && d.z.abs() < 4;
        case 2:
          return type == 'lamp' && d.x < -3 && d.z.abs() < 8;
      }
      return false;
    }
    return _step == 0 && type == 'sun' && d.y > 12;
  }

  /// Progress of the current task (the HTML `task-progress` bar).
  double _stepProgress() {
    if (_taskComplete) return 1;
    final sc = _scene;
    final since = sc.time - _stepStart;
    if (_scenario == 0) {
      if (_step == 3) return sc.heat / 100;
      if (_step == 4) return (since / 3).clamp(0.0, 1.0);
      return 0;
    }
    switch (_step) {
      case 1:
        return (sc.intensity / 0.9).clamp(0.0, 1.0);
      case 2:
        return sc.vaporClicks / 3;
      case 3:
        return ((sc.cloudX + 15) / 30).clamp(0.0, 1.0);
      case 4:
        return sc.rainClicks / 3;
      case 5:
        return (since / 6).clamp(0.0, 1.0);
    }
    return 0;
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step + 1,
          instruction: _taskComplete ? _t('completed') : null,
          sidebarExtraTitle: _t('int_task'),
          sidebarExtra: _taskCard(p, s),
          onReset: _fullReset,
          overlays: [
            if (_scenario == 0 && _scene.holdUi) _holdButton(s, inset),
          ],
          stage: LabStage(
            designSize: _kDesign,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onDown,
              onPointerMove: _onMove,
              onPointerUp: _onUp,
              onPointerCancel: _onUp,
              child: CustomPaint(
                size: _kDesign,
                painter: _A4Painter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  labels: {
                    for (final k in _kLabelKeys) k: _t('lbl_$k'),
                    for (final k in _kArrowKeys) 'arrow_$k': _t('arrow_$k'),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// "Interactive Task" card: the current step (HTML step card with its
  /// title, detailed instruction and Awaiting / Completed badge), the
  /// scenario context and a live task-progress bar.
  Widget _taskCard(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final done = _taskComplete;
    final accent = done ? _Colors.green : _Colors.blue;
    final steps = _data.steps;
    final idx = _step.clamp(0, steps.length - 1);
    final title = '${_lab.t('step')} ${idx + 1}: ${steps[idx].concept}';
    final task = _tasks[_lab.lang.code]![_scenario][idx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t('ctx_${_scenario + 1}'),
          style: TextStyle(color: p.textMuted, fontSize: 11.5 * f, height: 1.45, fontStyle: FontStyle.italic),
        ),
        SizedBox(height: 10 * s),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(11 * s),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: done ? const Color(0xFF4ADE80) : const Color(0xFF60A5FA),
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5 * f,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * s),
                  Icon(done ? Icons.check_circle : Icons.circle, size: (done ? 16 : 10) * s, color: accent),
                ],
              ),
              SizedBox(height: 6 * s),
              Text.rich(
                _richTask(task, p.text),
                style: TextStyle(fontSize: 11.5 * f, height: 1.5, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10 * s),
              ValueListenableBuilder<double>(
                valueListenable: _frame,
                builder: (context, _, _) => _progressRow(p, s, f, accent),
              ),
              SizedBox(height: 10 * s),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
                  decoration: BoxDecoration(
                    color: done ? const Color(0xCC14532D) : const Color(0xCC1E3A8A),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(done ? Icons.check_circle : Icons.hourglass_top, size: 13 * s,
                          color: done ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD)),
                      SizedBox(width: 5 * s),
                      Flexible(
                        child: Text(
                          done ? _t('completed') : _t('awaiting'),
                          style: TextStyle(
                            color: done ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD),
                            fontSize: 11 * f,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressRow(LabPalette p, double s, double f, Color accent) {
    final v = _stepProgress().clamp(0.0, 1.0);
    final heatStep = _scenario == 0 && _step == 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                heatStep ? _t('heat_transferred') : _t('task_progress'),
                style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${(v * 100).round()}%',
              style: TextStyle(color: accent, fontSize: 11 * f, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 6 * s,
            backgroundColor: p.cardBorder,
            color: heatStep ? Color.lerp(_Colors.amber, _Colors.red, v) : accent,
          ),
        ),
      ],
    );
  }

  /// HTML `#special-action-ui`: the big red "Hold Heat" button, fixed to
  /// the bottom-right of the canvas. Heat is applied while it is pressed.
  Widget _holdButton(double s, EdgeInsets inset) {
    final size = 92 * s;
    final pressed = _scene.holding;
    return Positioned(
      right: inset.right + 12 * s,
      bottom: inset.bottom + 58 * s,
      child: Listener(
        onPointerDown: (_) => _holdStart(),
        onPointerUp: (_) => _holdEnd(),
        onPointerCancel: (_) => _holdEnd(),
        child: AnimatedScale(
          scale: pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pressed ? const Color(0xFFB91C1C) : const Color(0xFFDC2626),
              border: Border.all(color: const Color(0xFF991B1B), width: 4 * s),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: pressed ? 0.95 : 0.7),
                  blurRadius: (pressed ? 48 : 36) * s,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8 * s),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 30 * s),
                    Text(
                      _t('hold_heat').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12 * s,
                        height: 1.15,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the HTML `<b>` / `<br>` markup of a task instruction.
TextSpan _richTask(String html, Color color) {
  final text = html.replaceAll('<br>', '\n');
  final spans = <TextSpan>[];
  var bold = false;
  for (final part in text.split(RegExp(r'</?b>'))) {
    if (part.isNotEmpty) {
      spans.add(TextSpan(
        text: part,
        style: TextStyle(
          color: bold ? _Colors.zslYellow : color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ));
    }
    bold = !bold;
  }
  return TextSpan(children: spans);
}

// ============================================================ STRINGS
// Copied verbatim from Cl7S-Ch1-A4-Heat_Transfer_and_the_Water_Cycle.html
// (`window.translations`), Telugu dropped. Strings that the HTML hard-coded
// or only had in English were added in both languages.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Heat Transfer & Water Cycle',
    'app_subtitle': 'Class 7 • The Ever-Evolving World of Science',
    'scen_1': '1: The Melting Ice Cube',
    'scen_2': '2: The Sun, The Sea, and The Rain',
    'curr_scenario': 'Current Scenario',
    'int_task': 'Interactive Task',
    'awaiting': 'Awaiting Action...',
    'completed': 'Task Completed!',
    'welcome_hud': 'Welcome! The sidebar contains your instructions.',
    'obs_title': 'Observation',
    'hold_heat': 'Hold\nHeat',
    // Canvas labels (`labels`).
    'lbl_beaker': 'Glass Beaker',
    'lbl_ice': 'Ice Cube',
    'lbl_lamp': 'Sun Lamp',
    'lbl_table': 'Lab Table',
    'lbl_tray': 'Lab Tray',
    'lbl_thermometer': 'Thermometer',
    'lbl_sea': 'The Sea',
    'lbl_land': 'Landmass',
    'lbl_sun': 'Solar Energy',
    'lbl_condensation': 'Condensation',
    'lbl_precipitation': 'Precipitation & Collection',
    // Scenario context (`ctx`).
    'ctx_1':
        "Before we begin, remember that matter exists in different states (solid, liquid, gas). Energy, in the form of heat, is needed to change a substance from one state to another. Let's observe this at a microscopic level first.",
    'ctx_2':
        "The same principle of heat transfer we just saw in the beaker drives the entire planet's weather system. Let's see how the Sun acts as our giant heat source.",
    // Observation popups (`obs`, HTML tags removed).
    'obs_1':
        'Observation: Heat energy from the Sun Lamp transferred to the Ice Cube.\n\nThis added energy caused the water molecules to vibrate faster, breaking their rigid bonds and changing the state from Solid (Ice) to Liquid (Water).',
    'obs_2':
        "Observation: The Sun's heat caused ocean water to Evaporate (Liquid to Gas).\n\nThe vapor rose, cooled, and condensed to form clouds (Condensation).\n\nFinally, gravity pulled the heavy water back to Earth as rain (Precipitation), trickling back into the sea and completing the Water Cycle.",
    // Added: feedback and readouts that the HTML did not show as text.
    'msg_wrong_drop': "That's not the right spot. Try again!",
    'task_progress': 'Task Progress',
    'heat_transferred': 'Heat transferred',
    'arrow_heat': 'Heat',
    'arrow_evap': 'Evaporation',
    'arrow_move': 'Wind Movement',
    'arrow_rain': 'Precipitation',
    'arrow_collect': 'Collection',
  },
  'hi': {
    'app_title': 'ऊष्मा स्थानांतरण और जल चक्र',
    'app_subtitle': 'कक्षा 7 • विज्ञान की निरंतर विकसित होती दुनिया',
    'scen_1': '1: पिघलता हुआ आइस क्यूब',
    'scen_2': '2: सूरज, समुद्र और बारिश',
    'curr_scenario': 'वर्तमान परिदृश्य',
    'int_task': 'इंटरएक्टिव कार्य',
    'awaiting': 'कार्रवाई की प्रतीक्षा है...',
    'completed': 'कार्य पूर्ण!',
    'welcome_hud': 'स्वागत है! साइडबार में आपके निर्देश हैं।',
    'obs_title': 'अवलोकन',
    'hold_heat': 'गर्मी\nबढ़ाएं',
    'lbl_beaker': 'कांच का बीकर',
    'lbl_ice': 'बर्फ का टुकड़ा',
    'lbl_lamp': 'सन लैंप',
    'lbl_table': 'लैब टेबल',
    'lbl_tray': 'लैब ट्रे',
    'lbl_thermometer': 'थर्मामीटर',
    'lbl_sea': 'समुद्र',
    'lbl_land': 'भूमि',
    'lbl_sun': 'सौर ऊर्जा',
    'lbl_condensation': 'संघनन (बादल)',
    'lbl_precipitation': 'वर्षा और संचय',
    'ctx_1':
        'शुरू करने से पहले, याद रखें कि पदार्थ विभिन्न अवस्थाओं (ठोस, तरल, गैस) में मौजूद है। किसी पदार्थ को एक अवस्था से दूसरी अवस्था में बदलने के लिए ऊष्मा के रूप में ऊर्जा की आवश्यकता होती है। आइए पहले इसे सूक्ष्म स्तर पर देखें।',
    'ctx_2':
        'ऊष्मा स्थानांतरण का वही सिद्धांत जो हमने अभी बीकर में देखा, पूरे ग्रह की मौसम प्रणाली को चलाता है। आइए देखें कि सूर्य हमारे विशाल ऊष्मा स्रोत के रूप में कैसे कार्य करता है।',
    'obs_1':
        'अवलोकन: सन लैंप से ऊष्मा ऊर्जा बर्फ के टुकड़े में स्थानांतरित हो गई।\n\nइस अतिरिक्त ऊर्जा ने पानी के अणुओं को तेजी से कंपन कराया, जिससे उनके कठोर बंधन टूट गए और अवस्था ठोस (बर्फ) से तरल (पानी) में बदल गई।',
    'obs_2':
        'अवलोकन: सूर्य की गर्मी के कारण समुद्र का पानी वाष्पीकृत (तरल से गैस) हो गया।\n\nवाष्प ऊपर उठी, ठंडी हुई और बादलों के रूप में संघनीकृत हो गई।\n\nअंततः, गुरुत्वाकर्षण ने भारी पानी को वर्षा (वर्षा) के रूप में वापस समुद्र में खींच लिया, जिससे जल चक्र पूरा हो गया।',
    'msg_wrong_drop': 'यह सही जगह नहीं है। फिर से प्रयास करें!',
    'task_progress': 'कार्य प्रगति',
    'heat_transferred': 'स्थानांतरित ऊष्मा',
    'arrow_heat': 'ऊष्मा',
    'arrow_evap': 'वाष्पीकरण',
    'arrow_move': 'हवा की गति',
    'arrow_rain': 'वर्षा',
    'arrow_collect': 'संचय',
  },
};

/// Mission objective + steps. `concept` is the HTML step title `t` without
/// its "Step n:" prefix, `action` is the HUD hint `m`.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: '1: The Melting Ice Cube',
      objective:
          'To visually demonstrate that heat energy transfers from a warmer source to a colder object, causing a change of state from solid to liquid.',
      steps: [
        LabStep(concept: 'Setup the Container', action: 'Drag the Beaker from the right tray to the center.'),
        LabStep(concept: 'Add the Solid', action: 'Drag the Ice Cube and drop it into the beaker.'),
        LabStep(concept: 'Introduce Heat Source', action: 'Drag the Sun Lamp and place it to the left of the beaker.'),
        LabStep(concept: 'Apply Heat', action: "Press and hold the red 'Hold Heat' button."),
        LabStep(concept: 'Energy Flow', action: 'Observe the energy flow arrow.'),
      ],
    ),
    LabScenarioData(
      title: '2: The Sun, The Sea, and The Rain',
      objective:
          'To construct a working model of the water cycle, demonstrating evaporation, condensation, and precipitation driven by solar energy.',
      steps: [
        LabStep(
          concept: 'Solar Energy',
          action: 'Concept: Solar Energy. Drag the Sun high above the ocean to provide heat.',
        ),
        LabStep(
          concept: 'Evaporation',
          action: 'Concept: Evaporation. Drag the Sun higher to heat the ocean and turn water into rising vapor.',
        ),
        LabStep(
          concept: 'Condensation',
          action: 'Concept: Condensation. Click the rising vapor to cool it down and form a solid cloud.',
        ),
        LabStep(
          concept: 'Movement',
          action: 'Concept: Wind Movement. Drag the cloud to the right, over the dry land.',
        ),
        LabStep(
          concept: 'Precipitation & Collection',
          action: 'Concept: Precipitation. Click the cloud to make it heavy so it releases rain.',
        ),
        LabStep(concept: 'The Cycle', action: 'Observe the continuous loop of the Water Cycle.'),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: '1: पिघलता हुआ आइस क्यूब',
      objective:
          'यह प्रदर्शित करने के लिए कि ऊष्मा ऊर्जा गर्म स्रोत से ठंडी वस्तु में स्थानांतरित होती है, जिससे ठोस से तरल में अवस्था परिवर्तन होता है।',
      steps: [
        LabStep(concept: 'कंटेनर सेट करें', action: 'बीकर को दाईं ट्रे से खींचकर बीच में लाएं।'),
        LabStep(concept: 'ठोस पदार्थ डालें', action: 'बर्फ के टुकड़े को खींचें और बीकर में डालें।'),
        LabStep(concept: 'ऊष्मा स्रोत लाएं', action: 'सन लैंप को खींचें और बीकर के बाईं ओर रखें।'),
        LabStep(concept: 'ऊष्मा लागू करें', action: "लाल 'होल्ड हीट' बटन को दबाकर रखें।"),
        LabStep(concept: 'ऊर्जा प्रवाह', action: 'ऊर्जा प्रवाह तीर का निरीक्षण करें।'),
      ],
    ),
    LabScenarioData(
      title: '2: सूरज, समुद्र और बारिश',
      objective:
          'सौर ऊर्जा द्वारा संचालित वाष्पीकरण, संघनन और वर्षा को प्रदर्शित करने वाले जल चक्र का एक कार्यशील मॉडल बनाना।',
      steps: [
        LabStep(
          concept: 'सौर ऊर्जा',
          action: 'अवधारणा: सौर ऊर्जा। ऊष्मा प्रदान करने के लिए सूर्य को समुद्र के ऊपर खींचें।',
        ),
        LabStep(
          concept: 'वाष्पीकरण',
          action: 'अवधारणा: वाष्पीकरण। समुद्र को गर्म करने और पानी को वाष्प में बदलने के लिए सूर्य को ऊपर खींचें।',
        ),
        LabStep(
          concept: 'संघनन',
          action: 'अवधारणा: संघनन। वाष्प को ठंडा करने और बादल बनाने के लिए उस पर क्लिक करें।',
        ),
        LabStep(
          concept: 'गति',
          action: 'अवधारणा: हवा की गति। बादल को दाईं ओर, सूखी जमीन के ऊपर खींचें।',
        ),
        LabStep(
          concept: 'वर्षा और संचय',
          action: 'अवधारणा: वर्षा। बारिश कराने के लिए बादल पर क्लिक करें।',
        ),
        LabStep(concept: 'चक्र', action: 'जल चक्र के निरंतर लूप का निरीक्षण करें।'),
      ],
    ),
  ],
};

/// Detailed task instructions (HTML step `i`, shown in the "Interactive
/// Task" card). `<b>` and `<br>` are rendered by [_richTask].
const Map<String, List<List<String>>> _tasks = {
  'en': [
    [
      'From the Lab Tray on the right, DRAG the <b>Glass Beaker</b> and DROP it onto the center of the wooden table.',
      'From the Lab Tray, DRAG the <b>Ice Cube</b> and DROP it inside the glass beaker.',
      'From the Lab Tray, DRAG the <b>Sun Lamp</b> and DROP it onto the table to the left of the beaker.',
      "CLICK and HOLD the massive <b>'+' Hold Heat</b> button on the bottom right to increase the heat transfer.",
      'The simulation pauses. A simple overlay highlights the flow of energy from the lamp to the ice, resulting in water.',
    ],
    [
      'The scene shows a cross-section of land next to the sea. The water cycle needs an energy source to begin.<br><br><b>Task:</b> DRAG the <b>Sun</b> from the tray and drop it high into the clear blue sky above the sea.',
      'As the Sun heats the ocean, liquid water turns into invisible water vapor (gas) and rises into the atmosphere.<br><br><b>Task:</b> CLICK and DRAG the Sun higher into the sky to increase the heat and start the evaporation process.',
      'High in the sky, the air is cooler. The rising water vapor cools down and turns back into tiny liquid droplets, clumping together to form clouds.<br><br><b>Task:</b> CLICK on the rising water vapors to cool them down and group them into a cloud.',
      "Clouds don't stay in one place. Wind currents in the atmosphere push clouds across the globe, bringing water to dry areas.<br><br><b>Task:</b> DRAG the cloud to the right, placing it over the dry green landmass.",
      'When the cloud becomes too heavy with water, it releases it back to the Earth. The water then flows over the land and eventually collects back into the sea.<br><br><b>Task:</b> CLICK the cloud repeatedly to make it heavy enough to release rain.',
      'The simulation pauses. An animated arrow appears, tracing a full circle summarizing the entire continuous loop of the water cycle.',
    ],
  ],
  'hi': [
    [
      'दाईं ओर लैब ट्रे से <b>कांच के बीकर</b> को खींचें और लकड़ी की मेज के बीच में छोड़ दें।',
      'लैब ट्रे से <b>बर्फ के टुकड़े</b> को खींचें और कांच के बीकर के अंदर छोड़ दें।',
      'लैब ट्रे से <b>सन लैंप</b> को खींचें और बीकर के बाईं ओर मेज पर छोड़ दें।',
      "ऊष्मा स्थानांतरण को बढ़ाने के लिए नीचे दाईं ओर बड़े <b>'+' होल्ड हीट</b> बटन को क्लिक करके दबाए रखें।",
      'सिमुलेशन रुक जाता है। एक सरल ओवरले लैंप से बर्फ तक ऊर्जा के प्रवाह को उजागर करता है, जिसके परिणामस्वरूप पानी बनता है।',
    ],
    [
      'दृश्य समुद्र के बगल में भूमि का क्रॉस-सेक्शन दिखाता है। जल चक्र को शुरू होने के लिए एक ऊर्जा स्रोत की आवश्यकता होती है।<br><br><b>कार्य:</b> ट्रे से <b>सूर्य</b> को खींचें और समुद्र के ऊपर साफ आसमान में छोड़ दें।',
      'जैसे ही सूर्य समुद्र को गर्म करता है, तरल पानी अदृश्य जल वाष्प (गैस) में बदल जाता है और वायुमंडल में ऊपर उठता है।<br><br><b>कार्य:</b> गर्मी बढ़ाने और वाष्पीकरण प्रक्रिया शुरू करने के लिए सूर्य को आसमान में और ऊपर खींचें।',
      'आसमान में ऊँचाई पर हवा ठंडी होती है। उठती हुई जल वाष्प ठंडी हो जाती है और फिर से तरल बूंदों में बदल जाती है, जो एक साथ मिलकर बादल बनाती हैं।<br><br><b>कार्य:</b> उन्हें ठंडा करने और बादल में बदलने के लिए उठती हुई जल वाष्प पर क्लिक करें।',
      'बादल एक जगह नहीं रहते। वायुमंडल में हवा की धाराएं बादलों को पूरी दुनिया में धकेलती हैं, जिससे सूखे इलाकों में पानी आता है।<br><br><b>कार्य:</b> बादल को दाईं ओर खींचें और सूखी हरी भूमि के ऊपर रखें।',
      'जब बादल पानी से बहुत भारी हो जाता है, तो यह इसे वापस पृथ्वी पर छोड़ देता है। फिर पानी जमीन पर बहता है और अंततः समुद्र में वापस जमा हो जाता है।<br><br><b>कार्य:</b> बारिश कराने के लिए बादल को भारी बनाने के लिए उस पर बार-बार क्लिक करें।',
      'सिमुलेशन रुक जाता है। एक एनिमेटेड तीर दिखाई देता है, जो जल चक्र के पूरे निरंतर लूप का सारांश देते हुए एक पूर्ण चक्र बनाता है।',
    ],
  ],
};

// ===================================================================== CYCLE

/// Scenario 2: the flat 2D cross-section of the water cycle (HTML
/// `buildScenario2Environment`). Coordinates are the HTML world units seen
/// by the fixed camera at (0, 10, 55).
class _CycleDrawer {
  _CycleDrawer(this.s, this.showLabels, this.l);

  final _A4Scene s;
  final bool showLabels;
  final String Function(String key) l;

  Offset p(double x, double y, [double z = 0]) => s.p2(x, y, z);
  double k(double z) => s.k2(z);

  static const Color _seaColor = Color(0xFF29B6F6);
  static const Color _rainColor = Color(0xFF0284C7);

  void paint(Canvas c, Size size) {
    final bleed = labBleed(size);
    _sky(c, bleed, size);
    _mountain(c);
    _ground(c, bleed);
    _trees(c);
    _puddleAndTrickle(c);
    if (s.sun) _sunRays(c);
    if (s.sun) _sun(c, -15, s.sunY, 3, glow: 0.6 + 0.4 * s.intensity);
    for (final pr in s.proxies.values) {
      if (!pr.visible) continue;
      final pulse = s.pulse(pr);
      if (pr.active && s.dragging != pr) {
        labGlow(c, p(pr.pos.x, pr.pos.y, 2), 5 * k(2) * pulse, _Colors.zslYellow, intensity: 0.35);
      }
      _sun(c, pr.pos.x, pr.pos.y, 3 * pr.scale * pulse, glow: 0.5);
    }
    if (s.vapors) _vapors(c);
    if (s.raining) _rain(c);
    if (s.cloud) _cloud(c);
    if (s.cycle) _arrows(c);
    if (showLabels) _labels(c);
  }

  void _sky(Canvas c, Rect bleed, Size size) {
    final sky = Color.lerp(const Color(0xFFA0D8EF), const Color(0xFF87CFEB), s.skyT)!;
    c.drawRect(bleed, Paint()..color = sky);
    final r = Rect.fromLTRB(bleed.left, 0, bleed.right, size.height * 0.75);
    c.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(sky, -0.08), sky, labShade(sky, 0.18)],
          stops: const [0, 0.55, 1],
        ).createShader(r),
    );
    c.drawRect(Rect.fromLTRB(bleed.left, bleed.top, bleed.right, 0), Paint()..color = labShade(sky, -0.08));
  }

  /// Far background mountain (triangle, 0x6e7f80) at z = -2.
  void _mountain(Canvas c) {
    const m = Color(0xFF6E7F80);
    final top = p(5, 18, -2), l = p(-7.12, -3, -2), r = p(17.12, -3, -2);
    final mid = p(5, -3, -2);
    c.drawPath(_poly([top, l, mid]), Paint()..color = labShade(m, 0.08));
    c.drawPath(_poly([top, mid, r]), Paint()..color = labShade(m, -0.1));
    // Snow-free ridge highlight.
    c.drawLine(top, l, Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2);
  }

  /// Dirt (right), sea (left, lowered by evaporation), beach and grass hill.
  void _ground(Canvas c, Rect bleed) {
    // Dirt: x -20..80 (extended), top at y = 0.
    final dTop = p(-20, 0).dy;
    final dirt = Rect.fromLTRB(p(-20, 0).dx, dTop, bleed.right, bleed.bottom);
    c.drawRect(dirt, Paint()..color = const Color(0xFF5D4037));
    final band = Paint()..color = const Color(0xFF4E342E).withValues(alpha: 0.5);
    for (var i = 1; i <= 4; i++) {
      final y = p(0, -3.0 * i).dy;
      c.drawRect(Rect.fromLTRB(dirt.left, y, dirt.right, y + 4), band);
    }
    // Sea: x ..5, top at -seaDrop.
    final seaTop = p(5, -s.seaDrop, 0.05).dy;
    final sea = Rect.fromLTRB(bleed.left, seaTop, p(5, 0, 0.05).dx, bleed.bottom);
    final depth = Rect.fromLTRB(sea.left, seaTop, sea.right, p(0, -13).dy);
    c.drawRect(
      sea,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_seaColor, 0.1), _seaColor, labShade(_seaColor, -0.35)],
          stops: const [0, 0.25, 1],
        ).createShader(depth),
    );
    // Gentle wave highlights on the surface.
    final wave = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final x = -38.0 + i * 4.5 + math.sin(s.time * 0.8 + i) * 0.6;
      final y = -s.seaDrop - 0.9 - (i % 3) * 1.6;
      c.drawLine(p(x, y, 0.05), p(x + 1.6, y, 0.05), wave);
    }
    // Beach (ellipse rx 19.2, ry 4.8) and grass hill (rx 36, ry 12).
    final bc = p(0, 0, 0.08);
    final kb = k(0.08);
    c.drawOval(Rect.fromCenter(center: bc, width: 38.4 * kb, height: 9.6 * kb), Paint()..color = const Color(0xFFFFE082));
    final gc = p(25, 0, 0.1);
    final kg = k(0.1);
    final grass = Rect.fromCenter(center: gc, width: 72 * kg, height: 24 * kg);
    c.drawOval(
      grass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5CBF60), Color(0xFF4CAF50), Color(0xFF3E8E41)],
          stops: [0, 0.4, 1],
        ).createShader(grass),
    );
  }

  /// Three flat trees: dry brown leaves turn bright green when it rains.
  void _trees(Canvas c) {
    final leaf = Color.lerp(const Color(0xFF8D6E63), const Color(0xFF22C55E), s.treeGreen)!;
    for (final t in const [(12.0, 8.0, 0.9), (22.0, 10.0, 1.2), (32.0, 9.0, 1.0)]) {
      final x = t.$1, y = t.$2, sc = t.$3;
      Offset q(double lx, double ly) => p(x + lx * sc, y + ly * sc, 0.2);
      c.drawPath(_poly([q(-0.75, 0), q(0.75, 0), q(0.75, 3), q(-0.75, 3)]), Paint()..color = const Color(0xFF4E342E));
      final l1 = _poly([q(0, 8), q(-3.03, 2.75), q(3.03, 2.75)]);
      final l2 = _poly([q(0, 10.3), q(-2.42, 6.1), q(2.42, 6.1)]);
      for (final leafPath in [l1, l2]) {
        c.drawPath(
          leafPath,
          Paint()
            ..shader = LinearGradient(colors: [labShade(leaf, 0.12), leaf, labShade(leaf, -0.15)])
                .createShader(leafPath.getBounds()),
        );
      }
    }
  }

  /// HTML `startPuddle()`: puddle (0x0284c7) and drops sliding to the sea.
  void _puddleAndTrickle(Canvas c) {
    if (s.puddle && s.puddleScale > 0) {
      final kp = k(0.4);
      c.drawOval(
        Rect.fromCenter(center: p(22, 9, 0.4), width: 9 * s.puddleScale * kp, height: 2.4 * s.puddleScale * kp),
        Paint()..color = _rainColor,
      );
    }
    final kd = k(0.5);
    for (final t in s.drops) {
      if (t < 0 || t > 1) continue;
      final c0 = p(22 + (-2 - 22) * t, 9 + (0 - 9) * t, 0.5);
      c.drawCircle(c0, 1.2 * kd, Paint()..color = _rainColor);
      c.drawCircle(c0.translate(-0.35 * kd, -0.35 * kd), 0.35 * kd, Paint()..color = Colors.white.withValues(alpha: 0.35));
    }
  }

  /// Ray triangle under the Sun (opacity = intensity * 0.4).
  void _sunRays(Canvas c) {
    final a = s.intensity * 0.4;
    if (a <= 0.005) return;
    final apex = p(-15, s.sunY - 2, 1.9);
    final path = _poly([apex, p(-23, s.sunY - 14, 1.9), p(-7, s.sunY - 14, 1.9)]);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFEF08A).withValues(alpha: (a * 1.4).clamp(0, 1)),
            const Color(0xFFFEF08A).withValues(alpha: a * 0.6),
          ],
        ).createShader(path.getBounds()),
    );
  }

  void _sun(Canvas c, double x, double y, double r, {double glow = 0.5}) {
    final o = p(x, y, 2);
    final rp = r * k(2);
    labGlow(c, o, rp * 2.4, const Color(0xFFFDE047), intensity: glow);
    c.drawCircle(
      o,
      rp,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFFEF08A), Color(0xFFFACC15), Color(0xFFEAB308)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: o, radius: rp)),
    );
  }

  /// Four wavy black vapour lines (CatmullRom spline) rising from the sea.
  void _vapors(Canvas c) {
    final a = s.intensity * 0.6 * s.vaporFade;
    if (a <= 0.005) return;
    const pts = [(0.0, 0.0), (-1.0, 2.0), (1.0, 4.0), (-1.0, 6.0), (0.0, 8.0), (1.0, 10.0)];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: a);
    for (var i = 0; i < 4; i++) {
      final ox = -22.0 + i * 4, oy = 2 + s.vaporBob;
      final q = [for (final pt in pts) p(ox + pt.$1, oy + pt.$2, 2)];
      final path = Path()..moveTo(q[0].dx, q[0].dy);
      for (var j = 0; j < q.length - 1; j++) {
        final p0 = q[math.max(j - 1, 0)], p1 = q[j], p2 = q[j + 1], p3 = q[math.min(j + 2, q.length - 1)];
        final c1 = p1 + (p2 - p0) / 6;
        final c2 = p2 - (p3 - p1) / 6;
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
      }
      c.drawPath(path, paint);
    }
  }

  /// 150 rain drops falling from the cloud (loop every 15 units).
  void _rain(Canvas c) {
    final cs = math.max(s.cloudScale, 0.05);
    final paint = Paint()
      ..color = _rainColor.withValues(alpha: 0.8)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < s.rainX.length; i++) {
      final x = s.cloudX + s.rainX[i] * cs;
      final y = 20 + s.rainY[i] * cs;
      c.drawLine(p(x, y, 2.5), p(x, y + 0.7 * cs, 2.5), paint);
    }
  }

  /// Flat cloud of five white circles; turns grey as it gets heavy.
  void _cloud(Canvas c) {
    final cs = s.cloudScale;
    if (cs <= 0.01) return;
    const puffs = [(-2.5, 0.0, 3.0), (0.0, 1.5, 4.0), (2.5, 0.0, 3.0), (-4.0, -1.0, 2.0), (4.0, -0.5, 2.0)];
    final kk = k(3);
    final path = Path();
    for (final pf in puffs) {
      path.addOval(Rect.fromCircle(center: p(s.cloudX + pf.$1 * cs, 20 + pf.$2 * cs, 3), radius: pf.$3 * cs * kk));
    }
    final color = Color.lerp(Colors.white, const Color(0xFF94A3B8), s.cloudGrey)!;
    c.drawPath(
      path.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color, labShade(color, -0.1)],
          stops: const [0, 0.55, 1],
        ).createShader(path.getBounds()),
    );
  }

  static const _arrowDefs = <((double, double), (double, double), (double, double), Color, String, (double, double))>[
    ((-15, 20), (-18, 10), (-10, 2), Color(0xFFFACC15), 'heat', (-3.8, 0)), // Heat
    ((-5, 2), (-5, 10), (-5, 18), Color(0xFF1E293B), 'evap', (4.8, 0)), // Evaporation
    ((-5, 25), (5, 28), (15, 25), Color(0xFFFFFFFF), 'move', (0, 3.0)), // Movement
    ((22, 18), (24, 14), (22, 10), Color(0xFF0284C7), 'rain', (4.6, 0)), // Rain
    ((15, 8), (5, 4), (-5, 2), Color(0xFF0284C7), 'collect', (0, -2.4)), // Collection
  ];

  /// HTML `showCycleArrows()`: five curved arrows that grow out of the
  /// origin one after another (Back.Out), closing the loop of the cycle.
  void _arrows(Canvas c) {
    final kk = k(4);
    for (var i = 0; i < _arrowDefs.length; i++) {
      final sc = s.arrowScale[i];
      if (sc <= 0.001) continue;
      final d = _arrowDefs[i];
      Offset q((double, double) v) => p(v.$1 * sc, v.$2 * sc, 4);
      final a = q(d.$1), cp = q(d.$2), e = q(d.$3);
      final col = d.$4;
      final outline = col.computeLuminance() > 0.5 ? const Color(0xFF0F172A) : Colors.white;
      final dir = e - cp;
      if (dir.distance < 1e-3) continue;
      final u = dir / dir.distance;
      final n = Offset(-u.dy, u.dx);
      final hl = 1.8 * kk * sc.clamp(0.0, 1.2);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(cp.dx, cp.dy, e.dx - u.dx * hl * 0.3, e.dy - u.dy * hl * 0.3);
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..color = outline.withValues(alpha: 0.5),
      );
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..color = col,
      );
      final tip = e + u * hl * 0.45;
      final base = e - u * hl * 0.55;
      final head = _poly([tip, base + n * hl * 0.6, base - n * hl * 0.6]);
      c.drawPath(
        head,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = outline.withValues(alpha: 0.5),
      );
      c.drawPath(head, Paint()..color = col);
      if (showLabels && sc > 0.85) {
        final mid = a * 0.25 + cp * 0.5 + e * 0.25;
        labText(
          c,
          l('arrow_${d.$5}'),
          mid + Offset(d.$6.$1, -d.$6.$2) * kk * sc,
          size: 12,
          weight: FontWeight.w800,
          color: labOnColor(col, _Theme.dark),
          background: col,
          border: outline.withValues(alpha: 0.6),
          radius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        );
      }
    }
  }

  void _labels(Canvas c) {
    _zslLabel(c, l('sea'), p(-15, 3, 2));
    _zslLabel(c, l('land'), p(22, 5, 2));
    if (s.sun) _zslLabel(c, l('sun'), p(-15, s.sunY + 4, 2));
    for (final pr in s.proxies.values) {
      if (!pr.visible || pr.labelHidden) continue;
      _zslLabel(c, l('sun'), p(pr.pos.x, pr.pos.y + 3, 2));
    }
    if (s.lblCondensation && s.cloud) _zslLabel(c, l('condensation'), p(s.cloudX, 24, 3));
    if (s.lblPrecipitation) _zslLabel(c, l('precipitation'), p(20, -5, 2));
  }
}

// ============================================================ SCENE MODEL

const Size _kDesign = Size(1000, 560);
const List<String> _kLabelKeys = [
  'beaker', 'ice', 'lamp', 'table', 'tray', 'thermometer', //
  'sea', 'land', 'sun', 'condensation', 'precipitation',
];
const List<String> _kArrowKeys = ['heat', 'evap', 'move', 'rain', 'collect'];

/// Focal length of the HTML PerspectiveCamera (45° vertical FOV) for a
/// 560 px tall design: (560 / 2) / tan(22.5°).
const double _kFocal = 280 / 0.41421356237;

/// Light direction of the HTML DirectionalLight at (10, 20, 10).
const _V3 _kLight = _V3(0.40825, 0.8165, 0.40825);

class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// A draggable item on the lab tray (HTML `buildProxy`).
class _Proxy {
  _Proxy(this.type, this.home, this.scale) : pos = home;
  final String type;
  final _V3 home;
  final double scale;
  _V3 pos;
  bool visible = true;
  bool active = false;
  double activeSince = 0;
  bool labelHidden = false;
}

/// Triangle wave 0..1..0 with a period of 2 (TWEEN `yoyo(true)`).
double _tri(double x) {
  final m = x % 2;
  return m < 1 ? m : 2 - m;
}

/// Mutable scene state shared by the page logic and the painter.
class _A4Scene {
  int scenario = 0;
  double time = 0;

  // ---- Scenario 1: camera at (0, 10, camZ) looking at the origin.
  double camZ = 24;
  final Map<String, _Proxy> proxies = {};
  _Proxy? dragging;
  bool draggingSun = false;
  bool draggingCloud = false;

  bool beaker = false;
  double beakerY = 0;
  bool ice = false;
  double iceY = 0.95;
  double iceScale = 1;
  List<double> iceRot = const [0, 0, 0];
  double liquid = 0; // liquid.scale.y (0..1)
  double thermo = 0.05; // thermometer liquid scale.y
  bool lamp = false;
  double lampY = 0;
  bool lampLit = false;
  bool holdUi = false;
  bool holding = false;
  bool iceMelted = false;
  double heat = 0;
  bool arrow = false;
  double arrowSince = 0;

  // ---- Scenario 2: flat cross-section, camera at (0, 10, 55).
  double skyT = 0;
  bool sun = false;
  bool sunDrag = false;
  double sunY = 12;
  double intensity = 0;
  bool vapors = false;
  double vaporFade = 1;
  bool vaporClick = false;
  int vaporClicks = 0;
  bool evaporationComplete = false;
  bool cloudFormed = false;
  bool cloudMoved = false;
  bool rainComplete = false;
  bool cloud = false;
  double cloudScale = 0;
  double cloudX = -15;
  double cloudGrey = 0;
  bool cloudDrag = false;
  bool rainClick = false;
  int rainClicks = 0;
  bool raining = false;
  final List<double> rainX = [];
  final List<double> rainY = [];
  double treeGreen = 0;
  bool puddle = false;
  double puddleScale = 0;
  final List<double> drops = List.filled(15, -1);
  double seaDrop = 0;
  bool lblCondensation = false;
  bool lblPrecipitation = false;
  bool cycle = false;
  final List<double> arrowScale = List.filled(5, 0);

  /// HTML `clearScene()` + `buildScenario1Environment()` /
  /// `buildScenario2Environment()`.
  void build(int index, math.Random rng) {
    scenario = index;
    camZ = 24;
    proxies.clear();
    dragging = null;
    draggingSun = false;
    draggingCloud = false;
    beaker = false;
    beakerY = 0;
    ice = false;
    iceY = 0.95;
    iceScale = 1;
    iceRot = const [0, 0, 0];
    liquid = 0;
    thermo = 0.05;
    lamp = false;
    lampY = 0;
    lampLit = false;
    holdUi = false;
    holding = false;
    iceMelted = false;
    heat = 0;
    arrow = false;
    skyT = 0;
    sun = false;
    sunDrag = false;
    sunY = 12;
    intensity = 0;
    vapors = false;
    vaporFade = 1;
    vaporClick = false;
    vaporClicks = 0;
    evaporationComplete = false;
    cloudFormed = false;
    cloudMoved = false;
    rainComplete = false;
    cloud = false;
    cloudScale = 0;
    cloudX = -15;
    cloudGrey = 0;
    cloudDrag = false;
    rainClick = false;
    rainClicks = 0;
    raining = false;
    rainX.clear();
    rainY.clear();
    treeGreen = 0;
    puddle = false;
    puddleScale = 0;
    drops.fillRange(0, drops.length, -1);
    seaDrop = 0;
    lblCondensation = false;
    lblPrecipitation = false;
    cycle = false;
    arrowScale.fillRange(0, 5, 0);
    if (index == 0) {
      proxies['beaker'] = _Proxy('beaker', const _V3(8, 0.1, -4), 0.45);
      proxies['ice'] = _Proxy('ice', const _V3(8, 0.1, 0), 0.7);
      proxies['lamp'] = _Proxy('lamp', const _V3(8, 0.1, 4), 0.35);
    } else {
      proxies['sun'] = _Proxy('sun', const _V3(-25, 28, 2), 0.8);
    }
  }

  _Proxy? get activeProxy {
    for (final p in proxies.values) {
      if (p.active && p.visible) return p;
    }
    return null;
  }

  /// HTML `activateProxy(type)`: only the active item pulses / drags.
  void activateProxy(String type) {
    for (final p in proxies.values) {
      p.active = p.type == type;
      if (p.active) p.activeSince = time;
    }
  }

  /// Group scale of a proxy (1 ↔ 1.1 every 500 ms while active).
  double pulse(_Proxy p) => p.active && p.visible ? 1 + 0.1 * _tri((time - p.activeSince) / 0.5) : 1;

  /// HTML `updateHoldSimulation`: ice shrinks, water rises, mercury rises.
  void applyHeat() {
    final progress = heat / 100;
    iceScale = math.max(0.01, 1 - progress);
    final waterHeight = progress * 1.5;
    final iceBottom = 0.2 + waterHeight * 0.5;
    iceY = iceBottom + 1.5 * iceScale / 2;
    liquid = progress;
    thermo = 0.05 + progress * 0.95;
  }

  /// HTML `startRaining()`: 150 drops under the cloud.
  void startRain(math.Random rng) {
    raining = true;
    rainX.clear();
    rainY.clear();
    for (var i = 0; i < 150; i++) {
      rainX.add((rng.nextDouble() - 0.5) * 10);
      rainY.add(rng.nextDouble() * 15 - 15);
    }
  }

  /// HTML `updateRain(delta)`.
  void updateRain(double dt) {
    if (!raining) return;
    for (var i = 0; i < rainY.length; i++) {
      rainY[i] -= dt * 20;
      if (rainY[i] < -15) rainY[i] = 0;
    }
  }

  // ---------------------------------------------------- projection (S1)

  static const _V3 _fwd = _V3(0, -10 / 26, -24 / 26);
  static const _V3 _up = _V3(0, 24 / 26, -10 / 26);
  _V3 get cam1 => _V3(0, 10, camZ);

  Offset p1(_V3 w) {
    final d = w - cam1;
    final k = _kFocal / d.dot(_fwd);
    return Offset(500 + d.x * k, 280 - d.dot(_up) * k);
  }

  /// Pixels per world unit at [w].
  double k1(_V3 w) => _kFocal / (w - cam1).dot(_fwd);

  _V3 ray1(Offset s) =>
      _fwd + const _V3(1, 0, 0) * ((s.dx - 500) / _kFocal) + _up * (-(s.dy - 280) / _kFocal);

  /// Intersection of the pointer ray with the horizontal plane at [y].
  _V3? unprojectY(Offset s, double y) {
    final d = ray1(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - cam1.y) / d.y;
    if (t <= 0) return null;
    return cam1 + d * t;
  }

  // ---------------------------------------------------- projection (S2)

  double k2(double z) => _kFocal / (55 - z);
  Offset p2(double x, double y, double z) {
    final k = k2(z);
    return Offset(500 + x * k, 280 - (y - 10) * k);
  }

  Offset unproject2(Offset s, double z) {
    final k = k2(z);
    return Offset((s.dx - 500) / k, 10 - (s.dy - 280) / k);
  }

  // ---------------------------------------------------- hit tests

  /// Sphere hit box (radius 3.5) of a proxy, like the HTML raycaster.
  bool hitProxy(_Proxy p, Offset s) {
    final sc = pulse(p);
    if (scenario == 0) {
      final c = p.pos + _V3(0, 2 * sc, 0);
      final d = ray1(s).unit;
      final v = c - cam1;
      final closest = cam1 + d * v.dot(d);
      return (c - closest).length <= 3.5 * sc;
    }
    final w = unproject2(s, p.pos.z);
    return (w - Offset(p.pos.x, p.pos.y)).distance <= 3.5 * sc;
  }

  bool hitSun(Offset s) => (unproject2(s, 2) - Offset(-15, sunY)).distance <= 5;

  double get vaporBob => cloudFormed ? 0 : math.sin(time * 3) * 0.5 * intensity;

  bool hitVapor(Offset s) {
    final w = unproject2(s, 3);
    return (w.dx + 15).abs() <= 10 && (w.dy - 8 - vaporBob).abs() <= 7.5;
  }

  bool hitCloud(Offset s, double hw, double hh, double z) {
    final w = unproject2(s, z);
    final k = math.max(cloudScale, 0.05);
    return (w.dx - cloudX).abs() <= hw * k && (w.dy - 20).abs() <= hh * k;
  }
}

// ============================================================ HELPERS

/// Convex hull (monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <Offset>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

Path _poly(List<Offset> pts) {
  final path = Path();
  if (pts.isEmpty) return path;
  path.moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
    path.lineTo(pts[i].dx, pts[i].dy);
  }
  return path..close();
}

/// HTML `.zsl-label`: dark glass chip, 2 px yellow border, bold yellow text.
void _zslLabel(Canvas c, String text, Offset at, {double opacity = 1}) {
  labText(
    c,
    text,
    at,
    size: 13,
    color: _Colors.zslYellow,
    weight: FontWeight.w800,
    background: const Color(0xE60F172A),
    border: _Colors.zslYellow,
    borderWidth: 2,
    radius: 6,
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    opacity: opacity,
  );
}

/// Draws a filled ellipse-like gradient spot (e.g. light on the table).
void _spot(Canvas c, Offset center, double rx, double ry, Color color, double alpha) {
  if (rx <= 0 || ry <= 0 || alpha <= 0) return;
  c.save();
  c.translate(center.dx, center.dy);
  c.scale(1, ry / rx);
  c.drawCircle(
    Offset.zero,
    rx,
    Paint()
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: alpha),
        color.withValues(alpha: alpha * 0.45),
        color.withValues(alpha: 0),
      ], stops: const [0, 0.5, 1])
          .createShader(Rect.fromCircle(center: Offset.zero, radius: rx)),
  );
  c.restore();
}

// ============================================================ PAINTER

class _A4Painter extends CustomPainter {
  _A4Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labels,
  }) : super(repaint: repaint);

  final _A4Scene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> labels;

  _A4Scene get s => scene;
  String _l(String key) => labels[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    if (s.scenario == 0) {
      _paintLab(canvas, size);
    } else {
      _paintCycle(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _A4Painter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;

  // ========================================================= SCENARIO 1

  Color get _bg => isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

  List<Offset> _ring(_V3 c, double r, {int n = 36}) => [
        for (var i = 0; i < n; i++)
          s.p1(_V3(c.x + r * math.cos(2 * math.pi * i / n), c.y, c.z + r * math.sin(2 * math.pi * i / n))),
      ];

  ({Path hull, List<Offset> top, List<Offset> bottom}) _cyl(_V3 base, double r, double h) {
    final b = _ring(base, r);
    final t = _ring(base + _V3(0, h, 0), r);
    return (hull: _poly(_hull([...b, ...t])), top: t, bottom: b);
  }

  _V3 get _lampHead => _V3(-9.5 + 5.6, s.lampY + 5.9, 0);
  _V3 get _beakerPos => _V3(0, s.beakerY, 0);

  /// The head turns towards the beaker base once the lamp has landed.
  _V3 get _lampAxis => s.lampLit ? (const _V3(0, 0, 0) - _lampHead).unit : const _V3(0, 0, -1);

  void _paintLab(Canvas c, Size size) {
    _floor(c, size);
    _table(c);
    _tray(c);
    final items = s.proxies.values.where((p) => p.visible && p != s.dragging).toList()
      ..sort((a, b) => a.pos.z.compareTo(b.pos.z));
    for (final p in items) {
      _proxy(c, p);
    }
    if (s.lampLit) _lightCone(c);
    if (s.lamp) {
      _castShadow(c, const _V3(-9.5, 0, 0), 2.5, 3);
      _lampModel(c, _V3(-9.5, s.lampY, 0), 1, _lampAxis, glow: s.lampLit ? (s.holding ? 1 : 0.45) : 0);
    }
    if (s.beaker) {
      _castShadow(c, const _V3(0, 0, 0), 2, 5, alpha: 0.22);
      _beakerModel(c, _beakerPos, 1, contents: true);
    }
    if (s.lampLit && s.holding && !s.iceMelted) _particles(c);
    if (s.arrow) _energyArrow(c);
    if (s.dragging != null) _proxy(c, s.dragging!);
    if (showLabels) _labels1(c);
  }

  /// Floor plane at y = -5 fading into the background fog (FogExp2 0.015).
  void _floor(Canvas c, Size size) {
    final bleed = labBleed(size);
    c.drawRect(bleed, Paint()..color = _bg);
    const floor = Color(0xFF2B3A55);
    final top = s.p1(const _V3(0, -5, -100)).dy;
    final bottom = bleed.bottom;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i <= 14; i++) {
      final f = (i / 14) * (i / 14);
      final w = s.unprojectY(Offset(500, top + (bottom - top) * f), -5);
      final dist = w == null ? 200.0 : (w - s.cam1).length;
      final fog = 1 - math.exp(-math.pow(0.015 * dist, 2).toDouble());
      colors.add(Color.lerp(floor, _bg, fog)!);
      stops.add(f);
    }
    final rect = Rect.fromLTRB(bleed.left, top, bleed.right, bottom);
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(rect),
    );
  }

  void _quad(Canvas c, List<_V3> pts, Paint paint) => c.drawPath(_poly([for (final p in pts) s.p1(p)]), paint);

  /// Wooden table 26 x 0.5 x 14 on four legs, with its floor shadow.
  void _table(Canvas c) {
    // Shadow of the table top on the floor (light from +x, +z).
    _quad(
      c,
      const [_V3(-15.5, -5, -9.5), _V3(10.5, -5, -9.5), _V3(10.5, -5, 4.5), _V3(-15.5, -5, 4.5)],
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    const legColor = Color(0xFF8B5A2B);
    for (final z in [-6.0, 6.0]) {
      for (final x in [-12.0, 12.0]) {
        final a = s.p1(_V3(x, -0.5, z));
        final b = s.p1(_V3(x, -5, z));
        final wa = 0.4 * s.k1(_V3(x, -0.5, z));
        final wb = 0.3 * s.k1(_V3(x, -5, z));
        final path = Path()
          ..moveTo(a.dx - wa, a.dy)
          ..lineTo(a.dx + wa, a.dy)
          ..lineTo(b.dx + wb, b.dy)
          ..lineTo(b.dx - wb, b.dy)
          ..close();
        final r = path.getBounds();
        c.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(colors: [
              labShade(legColor, -0.35),
              labShade(legColor, 0.2),
              legColor,
              labShade(legColor, -0.45),
            ], stops: const [0, 0.3, 0.6, 1])
                .createShader(r),
        );
      }
    }
    const wood = Color(0xFFCD853F);
    final topPts = const [_V3(-13, 0, -7), _V3(13, 0, -7), _V3(13, 0, 7), _V3(-13, 0, 7)];
    final topPath = _poly([for (final p in topPts) s.p1(p)]);
    final tb = topPath.getBounds();
    c.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(wood, 0.05), labShade(wood, 0.18), labShade(wood, 0.04)],
        ).createShader(tb),
    );
    // Wood grain.
    final grain = Paint()
      ..color = const Color(0xFF7A4A1E).withValues(alpha: 0.13)
      ..strokeWidth = 1.2;
    for (var i = 1; i < 12; i++) {
      final z = -7 + 14 * i / 12;
      final wob = math.sin(i * 2.3) * 0.4;
      c.drawLine(s.p1(_V3(-13, 0, z + wob)), s.p1(_V3(13, 0, z - wob)), grain);
    }
    // Front edge (z = 7).
    _quad(c, const [_V3(-13, 0, 7), _V3(13, 0, 7), _V3(13, -0.5, 7), _V3(-13, -0.5, 7)],
        Paint()..color = labShade(wood, -0.28));
    c.drawLine(
      s.p1(const _V3(-13, 0, 7)),
      s.p1(const _V3(13, 0, 7)),
      Paint()
        ..color = labShade(wood, 0.35)
        ..strokeWidth = 1.5,
    );
  }

  /// Dark lab tray (8 x 0.1 x 12) at x = 8.
  void _tray(Canvas c) {
    const tray = Color(0xFF333333);
    _quad(
      c,
      const [_V3(3.4, 0.002, -6.6), _V3(12.6, 0.002, -6.6), _V3(12.6, 0.002, 5.4), _V3(3.4, 0.002, 5.4)],
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    _quad(c, const [_V3(4, 0.1, 6), _V3(12, 0.1, 6), _V3(12, 0, 6), _V3(4, 0, 6)],
        Paint()..color = labShade(tray, -0.35));
    _quad(c, const [_V3(4, 0.1, -6), _V3(4, 0.1, 6), _V3(4, 0, 6), _V3(4, 0, -6)],
        Paint()..color = labShade(tray, -0.2));
    final top = _poly([
      for (final p in const [_V3(4, 0.1, -6), _V3(12, 0.1, -6), _V3(12, 0.1, 6), _V3(4, 0.1, 6)]) s.p1(p),
    ]);
    c.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(tray, 0.12), labShade(tray, 0.02)],
        ).createShader(top.getBounds()),
    );
    c.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  /// Soft shadow of an upright object cast on the table (light from +x, +z).
  void _castShadow(Canvas c, _V3 base, double r, double h, {double alpha = 0.3}) {
    final b = _ring(_V3(base.x, 0.01, base.z), r, n: 24);
    final t = _ring(_V3(base.x - h * 0.5, 0.01, base.z - h * 0.5), r * 0.85, n: 24);
    c.drawPath(
      _poly(_hull([...b, ...t])),
      Paint()
        ..color = Colors.black.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  /// Glass beaker (r 2, h 5) with rim, optional liquid, ice and thermometer.
  void _beakerModel(Canvas c, _V3 o, double sc, {bool contents = false}) {
    const glass = Color(0xFF88CCFF);
    final r = 2 * sc, h = 5 * sc;
    final cyl = _cyl(o, r, h);
    // Back wall and inner rim.
    c.drawPath(cyl.hull, Paint()..color = glass.withValues(alpha: 0.14));
    c.drawPath(_poly(cyl.top), Paint()..color = glass.withValues(alpha: 0.10));
    c.drawPath(_poly(_ring(o + _V3(0, 0.2 * sc, 0), r * 0.97)), Paint()..color = glass.withValues(alpha: 0.18));
    if (contents) _contents(c, o);
    // Front wall.
    final b = cyl.hull.getBounds();
    c.drawPath(
      cyl.hull,
      Paint()
        ..shader = LinearGradient(colors: [
          glass.withValues(alpha: 0.42),
          glass.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.05),
          glass.withValues(alpha: 0.08),
          glass.withValues(alpha: 0.36),
        ], stops: const [0, 0.18, 0.45, 0.75, 1])
            .createShader(b),
    );
    final k = s.k1(o + _V3(0, h / 2, 0));
    // Glass highlight streak.
    c.drawLine(
      s.p1(o + _V3(-0.62 * r, h * 0.88, 0.78 * r)),
      s.p1(o + _V3(-0.62 * r, h * 0.12, 0.78 * r)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = math.max(1.5, 0.12 * k)
        ..strokeCap = StrokeCap.round,
    );
    // Graduation marks.
    final tick = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = math.max(1, 0.05 * k);
    for (var i = 1; i <= 4; i++) {
      final y = h * i / 5;
      c.drawLine(s.p1(o + _V3(0.30 * r, y, 0.95 * r)), s.p1(o + _V3(0.62 * r, y, 0.78 * r)), tick);
    }
    // Rim (torus) and outline.
    c.drawPath(
      _poly(cyl.top),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, 0.22 * k * sc.clamp(0.4, 1))
        ..color = glass.withValues(alpha: 0.9),
    );
    c.drawPath(
      cyl.hull,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = glass.withValues(alpha: 0.55),
    );
  }

  /// Liquid (scale.y = progress), the ice cube and the thermometer.
  void _contents(Canvas c, _V3 o) {
    const water = Color(0xFF3B82F6);
    Path? hull;
    List<Offset>? top;
    if (s.liquid > 0.02) {
      final cyl = _cyl(o + const _V3(0, 0.2, 0), 1.9, 1.5 * s.liquid);
      hull = cyl.hull;
      top = cyl.top;
      c.drawPath(
        hull,
        Paint()
          ..shader = LinearGradient(colors: [
            labShade(water, -0.25).withValues(alpha: 0.85),
            water.withValues(alpha: 0.85),
            labShade(water, 0.18).withValues(alpha: 0.85),
            labShade(water, -0.3).withValues(alpha: 0.85),
          ], stops: const [0, 0.3, 0.6, 1])
              .createShader(hull.getBounds()),
      );
      c.drawPath(_poly(top), Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.9));
    }
    if (s.ice) _iceCube(c, _V3(o.x, s.iceY, o.z), 1.5 * s.iceScale, s.iceRot);
    if (hull != null && top != null) {
      final front = Path.combine(PathOperation.difference, hull, _poly(top));
      c.drawPath(front, Paint()..color = water.withValues(alpha: 0.45));
      c.drawPath(
        _poly(top),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.4),
      );
    }
    _thermometer(c, o + const _V3(0, 0.1, 1.5));
  }

  /// Thermometer (tube h 5, red bulb, red column scale.y = thermo).
  void _thermometer(Canvas c, _V3 base) {
    final k = s.k1(base + const _V3(0, 2.5, 0));
    c.drawLine(
      s.p1(base + const _V3(0, 0.3, 0)),
      s.p1(base + const _V3(0, 5, 0)),
      Paint()
        ..color = const Color(0xFFDDDDDD).withValues(alpha: 0.8)
        ..strokeWidth = 0.24 * k
        ..strokeCap = StrokeCap.round,
    );
    final tick = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.8)
      ..strokeWidth = 1;
    for (var i = 0; i < 9; i++) {
      final y = 1.0 + i * 0.45;
      final p = s.p1(base + _V3(0, y, 0.12));
      c.drawLine(p.translate(-0.12 * k, 0), p.translate(i.isEven ? 0.02 * k : -0.04 * k, 0), tick);
    }
    final bottom = s.p1(base + const _V3(0, 0.5, 0.05));
    final colTop = s.p1(base + _V3(0, 0.5 + 4.5 * s.thermo, 0.05));
    c.drawLine(
      bottom,
      colTop,
      Paint()
        ..color = const Color(0xFFFF0000)
        ..strokeWidth = 0.16 * k
        ..strokeCap = StrokeCap.round,
    );
    final bulb = s.p1(base + const _V3(0, 0.3, 0));
    labSphere(c, bulb, 0.25 * k, const Color(0xFFFF0000), highlight: 0.4, shade: 0.3);
  }

  /// Ice cube (BoxGeometry 1.5) with Euler XYZ rotation, lit faces.
  void _iceCube(Canvas c, _V3 center, double size, List<double> rot) {
    if (size < 0.03) return;
    final h = size / 2;
    final cx = math.cos(rot[0]), sx = math.sin(rot[0]);
    final cy = math.cos(rot[1]), sy = math.sin(rot[1]);
    final cz = math.cos(rot[2]), sz = math.sin(rot[2]);
    _V3 rotate(_V3 v) {
      final x1 = v.x * cz - v.y * sz, y1 = v.x * sz + v.y * cz, z1 = v.z;
      final x2 = x1 * cy + z1 * sy, z2 = -x1 * sy + z1 * cy;
      return _V3(x2, y1 * cx - z2 * sx, y1 * sx + z2 * cx);
    }

    final corners = [
      for (var i = 0; i < 8; i++)
        center + rotate(_V3(i & 1 == 1 ? h : -h, i & 2 == 2 ? h : -h, i & 4 == 4 ? h : -h)),
    ];
    const faces = <(List<int>, _V3)>[
      ([1, 3, 7, 5], _V3(1, 0, 0)),
      ([0, 4, 6, 2], _V3(-1, 0, 0)),
      ([2, 6, 7, 3], _V3(0, 1, 0)),
      ([0, 1, 5, 4], _V3(0, -1, 0)),
      ([4, 5, 7, 6], _V3(0, 0, 1)),
      ([0, 2, 3, 1], _V3(0, 0, -1)),
    ];
    const ice = Color(0xFF38BDF8);
    final visible = <(double, Path, double)>[];
    for (final f in faces) {
      final n = rotate(f.$2);
      final fc = (corners[f.$1[0]] + corners[f.$1[1]] + corners[f.$1[2]] + corners[f.$1[3]]) * 0.25;
      if (n.dot(s.cam1 - fc) <= 0) continue;
      final path = _poly([for (final i in f.$1) s.p1(corners[i])]);
      visible.add(((fc - s.cam1).length, path, n.dot(_kLight)));
    }
    visible.sort((a, b) => b.$1.compareTo(a.$1));
    for (final v in visible) {
      final lit = v.$3;
      final color = labShade(ice, lit > 0 ? lit * 0.42 : lit * 0.3 - 0.08);
      c.drawPath(v.$2, Paint()..color = color.withValues(alpha: 0.94));
      c.drawPath(
        v.$2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  void _ball(Canvas c, _V3 w, double r, Color color) =>
      labSphere(c, s.p1(w), r * s.k1(w), color, highlight: 0.3);

  void _rod(Canvas c, _V3 a, _V3 b, double r, Color color) {
    final pa = s.p1(a), pb = s.p1(b);
    final w = 2 * r * s.k1(_V3.lerp(a, b, 0.5));
    c.drawLine(
      pa,
      pb,
      Paint()
        ..color = labShade(color, -0.25)
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round,
    );
    final d = pb - pa;
    if (d.distance < 1e-3) return;
    var n = Offset(-d.dy, d.dx) / d.distance;
    if (n.dy > 0) n = -n;
    c.drawLine(
      pa + n * w * 0.18,
      pb + n * w * 0.18,
      Paint()
        ..color = labShade(color, 0.35)
        ..strokeWidth = w * 0.32
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Desk lamp (HTML `createLampGroup`): base, joints, two arms and a dome
  /// shade whose opening points along [axis]. [glow] 0..1 when switched on.
  void _lampModel(Canvas c, _V3 o, double sc, _V3 axis, {double glow = 0}) {
    const dark = Color(0xFF1E293B);
    const silver = Color(0xFF94A3B8);
    final base = _cyl(o, 2.5 * sc, 0.4 * sc);
    c.drawPath(
      base.hull,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(dark, -0.2),
          labShade(dark, 0.25),
          labShade(dark, -0.3),
        ]).createShader(base.hull.getBounds()),
    );
    c.drawPath(_poly(base.top), Paint()..color = labShade(dark, 0.22));
    _ball(c, o + _V3(0, 0.6 * sc, 0), 0.6 * sc, dark);
    _rod(c, o + _V3(0.03 * sc, 0.48 * sc, 0), o + _V3(2.97 * sc, 4.52 * sc, 0), 0.3 * sc, silver);
    _ball(c, o + _V3(3 * sc, 4.4 * sc, 0), 0.5 * sc, dark);
    _rod(c, o + _V3(3.0 * sc, 4.45 * sc, 0), o + _V3(5.6 * sc, 5.95 * sc, 0), 0.3 * sc, silver);
    _drawLampHead(c, o + _V3(5.6 * sc, 5.9 * sc, 0), sc, axis, glow);
  }

  void _drawLampHead(Canvas c, _V3 h, double sc, _V3 axis, double glow) {
    const dark = Color(0xFF1E293B);
    final ch = s.p1(h);
    final rpx = 2.5 * sc * s.k1(h);
    final rimC = h + axis * (0.957 * sc);
    final rimR = 2.31 * sc;
    final helper = axis.y.abs() > 0.95 ? const _V3(1, 0, 0) : const _V3(0, 1, 0);
    final u1 = axis.cross(helper).unit;
    final u2 = axis.cross(u1).unit;
    final rim = _poly([
      for (var i = 0; i < 32; i++)
        s.p1(rimC + u1 * (math.cos(2 * math.pi * i / 32) * rimR) + u2 * (math.sin(2 * math.pi * i / 32) * rimR)),
    ]);
    final facing = axis.dot(s.cam1 - rimC) > 0;
    final circle = Rect.fromCircle(center: ch, radius: rpx);
    var dome = Path()..addOval(circle);
    final pr = s.p1(rimC);
    var dir = s.p1(h + axis) - ch;
    if (facing && dir.distance > 1e-3) {
      dir = dir / dir.distance;
      final perp = Offset(-dir.dy, dir.dx);
      final keep = _poly([
        pr + perp * 4000,
        pr - perp * 4000,
        pr - perp * 4000 - dir * 8000,
        pr + perp * 4000 - dir * 8000,
      ]);
      dome = Path.combine(PathOperation.intersect, dome, keep);
    }
    if (glow > 0) {
      labGlow(c, pr, rpx * (1.6 + glow), const Color(0xFFFFDD00), intensity: 0.35 + 0.45 * glow);
    }
    c.drawPath(
      dome,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [labShade(dark, 0.4), dark, labShade(dark, -0.5)],
          stops: const [0, 0.5, 1],
        ).createShader(circle),
    );
    if (facing || glow > 0) {
      c.drawPath(
        rim,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFFFEE),
            const Color(0xFFFFAA00),
            labShade(const Color(0xFFFFAA00), -0.25),
          ], stops: const [0, 0.35, 1])
              .createShader(rim.getBounds()),
      );
      c.drawPath(
        rim,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = labShade(dark, 0.3),
      );
    }
  }

  /// Additive yellow light cone (30° half angle) from the lamp head to the
  /// beaker base, clipped by the table plane, plus the lit spot on the table.
  void _lightCone(Canvas c) {
    final h = _lampHead;
    final t = _beakerPos;
    final axis = (t - h).unit;
    final dist = (t - h).length;
    final r = dist * math.tan(math.pi / 6);
    final u1 = axis.cross(const _V3(0, 0, 1)).unit;
    final u2 = axis.cross(u1).unit;
    final apex = s.p1(h);
    final pts = <Offset>[apex];
    for (var i = 0; i < 40; i++) {
      final a = 2 * math.pi * i / 40;
      var p = t + u1 * (math.cos(a) * r) + u2 * (math.sin(a) * r);
      if (p.y < 0) p = h + (p - h) * (h.y / (h.y - p.y));
      pts.add(s.p1(p));
    }
    final hull = _poly(_hull(pts));
    final op = s.holding ? 0.35 : 0.15;
    var far = 0.0;
    for (final p in pts) {
      far = math.max(far, (p - apex).distance);
    }
    // Lit spot on the table (SpotLight intensity 2 → 5 while holding).
    final spot = s.p1(t);
    _spot(c, spot, r * 1.1 * s.k1(t), r * 0.45 * s.k1(t), const Color(0xFFFFDD00), s.holding ? 0.55 : 0.28);
    c.drawPath(
      hull,
      Paint()
        ..blendMode = isDark ? BlendMode.plus : BlendMode.srcOver
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFEA00).withValues(alpha: (op * 2.2).clamp(0, 1)),
          const Color(0xFFFFEA00).withValues(alpha: op * 1.2),
          const Color(0xFFFFEA00).withValues(alpha: op * 0.5),
        ], stops: const [0, 0.5, 1])
            .createShader(Rect.fromCircle(center: apex, radius: math.max(far, 1))),
    );
  }

  /// 50 heat particles streaming from the lamp to the beaker while held.
  void _particles(Canvas c) {
    final start = _lampHead + _lampAxis * 1.5;
    final end = _beakerPos + const _V3(0, 1.5, 0);
    final rnd = math.Random((s.time * 60).floor());
    for (var i = 0; i < 50; i++) {
      final t = (s.time * 4 + i / 50) % 1;
      final p = _V3.lerp(start, end, t) +
          _V3((rnd.nextDouble() - 0.5) * 0.5, (rnd.nextDouble() - 0.5) * 0.5, (rnd.nextDouble() - 0.5) * 0.5);
      final sp = s.p1(p);
      final r = math.max(1.8, 0.16 * s.k1(p));
      c.drawCircle(sp, r * 2.2, Paint()..color = const Color(0xFFFF5500).withValues(alpha: 0.25));
      c.drawCircle(sp, r, Paint()..color = const Color(0xFFFF5500).withValues(alpha: 0.8));
    }
  }

  /// HTML `showEnergyFlowArrow()`: red ArrowHelper bobbing towards the beaker.
  void _energyArrow(Canvas c) {
    final h = _lampHead;
    final target = _beakerPos + const _V3(0, 2, 0);
    final dir = (target - h).unit;
    final len = (target - h).length - 1.5;
    final off = _tri((s.time - s.arrowSince) / 0.6) * 0.5;
    final a = h + dir * off;
    final b = a + dir * len;
    final pa = s.p1(a), pb = s.p1(b);
    c.drawLine(
      pa,
      pb,
      Paint()
        ..color = const Color(0xFFFF0000).withValues(alpha: 0.45)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    labArrow(c, pa, pb, color: const Color(0xFFFF2020), width: 4.5, head: 1.5 * s.k1(b));
  }

  /// A tray item (beaker 0.45, ice 0.7, lamp 0.35 scale), pulsing if active.
  void _proxy(Canvas c, _Proxy p) {
    final pulse = s.pulse(p);
    final sc = p.scale * pulse;
    if (p.active && s.dragging != p) {
      final o = s.p1(p.pos);
      final k = s.k1(p.pos);
      _spot(c, o, 2.6 * k, 1.1 * k, _Colors.zslYellow, 0.18 + 0.2 * (pulse - 1) * 10);
    }
    switch (p.type) {
      case 'beaker':
        _beakerModel(c, p.pos, sc);
      case 'ice':
        _iceCube(c, p.pos + _V3(0, 0.75 * pulse, 0), 1.5 * sc, const [0, 0, 0]);
      case 'lamp':
        _lampModel(c, p.pos, sc, const _V3(0.707, 0.5, -0.5).unit);
    }
  }

  void _labels1(Canvas c) {
    _zslLabel(c, _l('table'), s.p1(const _V3(-10, 0, 7)));
    _zslLabel(c, _l('tray'), s.p1(const _V3(8, 0, 6)));
    for (final p in s.proxies.values) {
      if (!p.visible || p.labelHidden) continue;
      _zslLabel(c, _l(p.type), s.p1(p.pos + _V3(0, 2 * s.pulse(p) + 3, 0)));
    }
    if (s.beaker) {
      _zslLabel(c, _l('beaker'), s.p1(_beakerPos + const _V3(0.6, 6.4, 0)));
      _zslLabel(c, _l('thermometer'), s.p1(const _V3(2.4, 4.2, 1.5)));
    }
    if (s.ice) _zslLabel(c, _l('ice'), s.p1(_V3(0, s.iceY + 2, 0)));
    if (s.lamp) _zslLabel(c, _l('lamp'), s.p1(_V3(-9.5, s.lampY + 8, 0)));
  }

  // ========================================================= SCENARIO 2

  void _paintCycle(Canvas c, Size size) => _CycleDrawer(s, showLabels, _l).paint(c, size);
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
