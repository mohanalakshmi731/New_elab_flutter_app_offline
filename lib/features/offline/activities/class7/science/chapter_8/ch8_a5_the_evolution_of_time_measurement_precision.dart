// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 8 • Activity 5
/// The Evolution of Time Measurement Precision.
///
/// Native Flutter port of `Cl7S-Ch8-A5-The_Evolution_of_Time_Measurement_Precision.html`.
/// Scenario 1 builds a water clock (cut the bottle, pierce the cap, invert
/// the funnel, pour water) and times a ball rolling down a ramp by marking
/// water levels. Scenario 2 runs a photo-finish race that a water clock
/// cannot judge, then replays it in slow motion with a digital stopwatch.
class Ch8A5TheEvolutionOfTimeMeasurementPrecisionPage extends StatefulWidget {
  const Ch8A5TheEvolutionOfTimeMeasurementPrecisionPage({super.key});

  @override
  State<Ch8A5TheEvolutionOfTimeMeasurementPrecisionPage> createState() =>
      _Ch8A5TheEvolutionOfTimeMeasurementPrecisionPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, splash 1311, whoosh 1492.
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
  splash('splash.mp3'),
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
  static const Color green600 = Color(0xFF16A34A);
  static const Color red = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
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

// ============================================================== MODEL

const Size _design = Size(900, 560);

/// Mutable 3D point (a Three.js `position`).
class _V3 {
  _V3(this.x, this.y, this.z);
  double x, y, z;

  void setAll(double nx, double ny, double nz) {
    x = nx;
    y = ny;
    z = nz;
  }
}

/// A falling water drop (HTML `createDrop()`), from y0 to y1 in 400 ms.
class _Drop {
  _Drop(this.t0, this.y0, this.y1);
  final double t0, y0, y1;
}

/// Bottom of the pierced cap once the funnel is inverted in the receiver.
const double _capBottomY = 1.1;

/// Mutable scene model read by the painter every frame.
class _TimeScene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  final _V3 camPos = _V3(0, 15, 30);
  final _V3 camTarget = _V3(0, 5, 0);
  // Zoom and screen centre of the virtual camera (tweened with it).
  double camFocal = 980;
  double camCx = 540, camCy = 260;

  void setCamera(double px, double py, double pz, double tx, double ty, double tz, double focal, double cx, double cy) {
    camPos.setAll(px, py, pz);
    camTarget.setAll(tx, ty, tz);
    camFocal = focal;
    camCx = cx;
    camCy = cy;
  }

  // ---- Scenario 1: water clock.
  final _V3 top = _V3(-6, 4, 0); // funnel (top half), pivot at its wide rim
  double topRot = 0;
  final _V3 scissors = _V3(-6, 0.1, 4);
  double scissorsFly = 0; // 0 = lying on the table, 1 = aimed at the bottle
  double snip = 0; // blade open / close phase while cutting
  double scissorsAlpha = 1;
  bool scissorsVisible = true;
  final _V3 pin = _V3(-2, 0.15, 4);
  double pinUpright = 0; // 0 = lying, 1 = needle pointing down
  double pinAlpha = 1;
  bool pinVisible = true;
  final _V3 pitcher = _V3(4, 0, 4);
  double pitcherRot = 0;
  double pitcherFill = 0.67;
  double pitcherAlpha = 1;
  bool pitcherVisible = true;
  bool isCut = false, isPierced = false, isAssembled = false, isPouring = false;
  bool hasHole = false;
  bool streamOn = false;
  double stream = 0; // 0..1 length of the pouring stream
  double topWater = 0; // 0..1 fill of the funnel
  bool dripping = false;
  double nextDrip = 0;
  int dripCount = 0;
  double waterLevel = 0; // 0..1 of the receiver height (4 units)
  final List<_Drop> drops = [];
  final _V3 ball = _V3(-13.5, 11.5, -5);
  final List<double> marks = []; // water levels marked at Start / Stop
  // Which tool labels exist (HTML create3DLabels() at each step change).
  bool lblScissors = true, lblPin = true, lblPitcher = true;

  // ---- Scenario 2: photo-finish race.
  double r1x = -40, r2x = -40;
  String raceState = 'idle';
  bool waterClockVisible = true;
  final _V3 stopwatch = _V3(36, 4, -12);
  bool stopwatchPicked = false;
  bool swRunning = false;
  bool swUsed = false;
  double swStart = 0;
  double swTime = 0;

  String get swDisplay => swUsed ? swTime.toStringAsFixed(2) : '00.00';

  _Cam camera() => _Cam(camPos, camTarget, camFocal, Offset(camCx, camCy));
}

/// A TWEEN.js style tween driven by the scene ticker.
class _Tw {
  _Tw({
    required this.duration,
    required this.update,
    this.delay = 0,
    this.curve = Curves.linear,
    this.onStart,
    this.onDone,
    this.yoyo = false,
  });

  final double duration; // seconds
  final double delay; // seconds
  final Curve curve;
  final VoidCallback? onStart;
  final void Function(double t) update;
  final VoidCallback? onDone;

  /// `.yoyo(true).repeat(1)`: there and back again.
  final bool yoyo;
  double? start;
  bool begun = false;
}

class _Ch8A5TheEvolutionOfTimeMeasurementPrecisionPageState
    extends State<Ch8A5TheEvolutionOfTimeMeasurementPrecisionPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  _TimeScene _s = _TimeScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Tw> _tweens = [];
  late final Ticker _ticker;

  // Overlay / button state (the HTML panels).
  bool _rampUi = false, _timerStarted = false, _timerStopped = false, _resultUi = false;
  bool _startUi = false, _ambiguousUi = false, _stopwatchUi = false, _resultsUi = false;
  bool _swStartEnabled = true, _lapEnabled = false;
  int _lapCount = 0;
  String? _r1Time, _r2Time;
  bool _concluded = false;

  String _t(String key) => _lab.tr(_i18n, key);

  /// Letter spacing for Latin text only (it breaks Devanagari clusters).
  double _ls(double v) => _lab.lang == LabLang.en ? v : 0;
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_s.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_tick)..start();
    _buildScenario();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _tweens.clear();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final s = _s;
    s.time = now;
    _runTweens(now);
    // HTML setInterval(…, 200): one drop every 200 ms while dripping.
    if (s.dripping) {
      if (now - s.nextDrip > 2) s.nextDrip = now;
      while (now >= s.nextDrip) {
        _spawnDrop(s.nextDrip);
        s.nextDrip += 0.2;
      }
    }
    s.drops.removeWhere((d) => now - d.t0 > 0.4);
    if (s.swRunning) s.swTime = now - s.swStart;
    _frame.value = now;
  }

  void _runTweens(double now) {
    if (_tweens.isEmpty) return;
    for (final tw in List<_Tw>.of(_tweens)) {
      if (!_tweens.contains(tw)) continue;
      final start = tw.start ??= now + tw.delay;
      if (now < start) continue;
      if (!tw.begun) {
        tw.begun = true;
        tw.onStart?.call();
      }
      final span = tw.duration * (tw.yoyo ? 2 : 1);
      final raw = now - start;
      final done = raw >= span;
      var p = tw.duration <= 0 ? 1.0 : (raw / tw.duration).clamp(0.0, tw.yoyo ? 2.0 : 1.0);
      if (tw.yoyo && p > 1) p = 2 - p;
      if (done) p = tw.yoyo ? 0 : 1;
      tw.update(tw.curve.transform(p));
      if (done) {
        _tweens.remove(tw);
        tw.onDone?.call();
      }
    }
  }

  /// `new TWEEN.Tween(v).to({x, y, z}, ms)`.
  void _tweenV3(
    _V3 v, {
    double? x,
    double? y,
    double? z,
    required int ms,
    int delay = 0,
    Curve curve = Curves.linear,
    bool yoyo = false,
    VoidCallback? done,
  }) {
    var x0 = v.x, y0 = v.y, z0 = v.z;
    _tweens.add(_Tw(
      duration: ms / 1000,
      delay: delay / 1000,
      curve: curve,
      yoyo: yoyo,
      onStart: () {
        x0 = v.x;
        y0 = v.y;
        z0 = v.z;
      },
      update: (t) {
        if (x != null) v.x = x0 + (x - x0) * t;
        if (y != null) v.y = y0 + (y - y0) * t;
        if (z != null) v.z = z0 + (z - z0) * t;
      },
      onDone: done,
    ));
  }

  /// Tween of a single number (rotations, fills, opacities…).
  void _tweenNum(
    double Function() get,
    void Function(double v) set,
    double to, {
    required int ms,
    int delay = 0,
    Curve curve = Curves.linear,
    VoidCallback? done,
  }) {
    var from = get();
    _tweens.add(_Tw(
      duration: ms / 1000,
      delay: delay / 1000,
      curve: curve,
      onStart: () => from = get(),
      update: (t) => set(from + (to - from) * t),
      onDone: done,
    ));
  }

  // ------------------------------------------------------------ logic

  /// HTML `buildScenario()` (+ `clearScene()`): fresh objects and overlays.
  void _buildScenario() {
    _lab.cancelPending();
    _tweens.clear();
    final old = _s;
    _s = _TimeScene()
      ..scenario = old.scenario
      ..step = old.step
      ..time = old.time;
    if (_s.scenario == 0) {
      _s.setCamera(0, 15, 30, 0, 5, 0, 980, 540, 260);
    } else {
      _setWideRaceCamera();
    }
    _rampUi = _timerStarted = _timerStopped = _resultUi = false;
    _startUi = _ambiguousUi = _stopwatchUi = _resultsUi = false;
    _swStartEnabled = true;
    _lapEnabled = false;
    _lapCount = 0;
    _r1Time = _r2Time = null;
    _concluded = false;
    if (_s.scenario == 0) {
      _updateS1UI();
    } else {
      _updateS2UI();
    }
  }

  void _changeScenario(int index) {
    setState(() {
      _s.scenario = index;
      _s.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _s.scenario = 0;
      _s.step = 1;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`. Buttons pass [silent] because the button already
  /// played its click.
  void _advanceStep({bool silent = false}) {
    if (!mounted) return;
    if (!silent) _Audio.play(_Sound.click);
    final n = _data.steps.length;
    setState(() {
      if (_s.step < n) {
        _s.step++;
        if (_s.scenario == 0) {
          _updateS1UI();
          if (_s.step == 6) _s.dripping = false;
        } else {
          _updateS2UI();
        }
      } else if (_s.step == n && !_concluded) {
        _resultUi = false;
        _resultsUi = false;
        _showConclusion();
      }
    });
  }

  void _showConclusion() {
    _concluded = true;
    _s.dripping = false; // failsafe, like the HTML
    _lab.showScenarioConclusion(
      scenarioIndex: _s.scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_s.scenario + 1}'),
    );
  }

  /// HTML `updateS1UI()`: labels for the tools still on the table, the
  /// ramp timer panel at step 5 and the digital result at step 6.
  void _updateS1UI() {
    _s
      ..lblScissors = !_s.isCut
      ..lblPin = !_s.isPierced
      ..lblPitcher = !_s.isPouring;
    if (_s.step == 5) {
      _rampUi = true;
      _timerStarted = false;
      _timerStopped = false;
    } else if (_s.step == 6) {
      _resultUi = true;
    }
  }

  /// HTML `updateS2UI()`.
  void _updateS2UI() {
    _startUi = _ambiguousUi = _stopwatchUi = _resultsUi = false;
    if (_s.step == 1) {
      _startUi = _s.raceState == 'idle';
      _setWideRaceCamera();
    } else if (_s.step == 2 && _s.raceState == 'finished_ambiguous') {
      _ambiguousUi = true;
    } else if (_s.step == 4) {
      _stopwatchUi = true;
    } else if (_s.step == 5) {
      _resultsUi = true;
    }
  }

  /// HTML camera (0, 20, 50) → (0, 0, 0), shifted 2 units along the track
  /// and zoomed so the start, the finish line and the table all fit.
  void _setWideRaceCamera() => _s.setCamera(2, 20, 50, 2, 0, 0, 460, 415, 300);

  // ---------------------------------------------------- scene clicks

  void _onStageTap(Offset p) {
    if (!_lab.isLabActive || _concluded) return;
    final s = _s;
    final cam = s.camera();
    bool hit(double x, double y, double z, double r) {
      final c = cam.p(x, y, z);
      final rad = math.max(r * cam.k(x, y, z), 34.0);
      return (p - c).distance <= rad;
    }

    if (s.scenario == 0) {
      switch (s.step) {
        case 1:
          if (!s.isCut && hit(s.scissors.x + 0.3, s.scissors.y + 0.4, s.scissors.z, 1.6)) _cutBottle();
        case 2:
          if (!s.isPierced && hit(s.pin.x, s.pin.y + 0.2, s.pin.z, 1.2)) _pierceCap();
        case 3:
          if (!s.isAssembled && hit(s.top.x, s.top.y + 1.4, s.top.z, 2.4)) _assemble();
        case 4:
          if (!s.isPouring && hit(s.pitcher.x + 0.3, s.pitcher.y + 1.5, s.pitcher.z, 2.4)) _pour();
      }
    } else if (s.step == 3 && !s.stopwatchPicked) {
      if (hit(s.stopwatch.x, s.stopwatch.y + 1.5, s.stopwatch.z, 2.6)) _pickStopwatch();
    }
  }

  /// Step 1: the scissors fly to the bottle, snip, and the top half lifts off.
  void _cutBottle() {
    final s = _s;
    setState(() => s.isCut = true);
    _tweenNum(() => s.scissorsFly, (v) => s.scissorsFly = v, 1, ms: 500);
    _tweenV3(s.scissors, x: -9.3, y: 4.0, z: 0.6, ms: 500, done: () {
      _Audio.play(_Sound.pop);
      _tweenNum(() => s.snip, (v) => s.snip = v, 1, ms: 500);
      // Separate the bottle.
      _tweenV3(s.top, x: 0, y: 0, z: -2, ms: 800, curve: Curves.easeOutCubic);
      // Scissors fly back out of view.
      _tweenNum(() => s.scissorsAlpha, (v) => s.scissorsAlpha = v, 0, ms: 500, delay: 500);
      _tweenV3(s.scissors, y: -5, ms: 500, delay: 500, done: () => s.scissorsVisible = false);
      _lab.after(const Duration(milliseconds: 1000), () => _advanceStep());
    });
  }

  /// Step 2: the drawing pin pokes a hole in the cap.
  void _pierceCap() {
    final s = _s;
    setState(() => s.isPierced = true);
    _tweenNum(() => s.pinUpright, (v) => s.pinUpright = v, 1, ms: 500);
    _tweenV3(s.pin, x: 0, y: 4.2, z: -2, ms: 500, done: () {
      _Audio.play(_Sound.pop);
      _tweenV3(s.pin, y: 3.5, ms: 200, yoyo: true, done: () {
        s.hasHole = true; // the hole appears
        _tweenNum(() => s.pinAlpha, (v) => s.pinAlpha = v, 0, ms: 500);
        _tweenV3(s.pin, y: -5, ms: 500, done: () => s.pinVisible = false);
        _lab.after(const Duration(milliseconds: 500), () => _advanceStep());
      });
    });
  }

  /// Step 3: the funnel is inverted onto the receiver.
  void _assemble() {
    final s = _s;
    setState(() => s.isAssembled = true);
    _Audio.play(_Sound.pop);
    _tweenV3(s.top, x: -6, y: 6, z: 0, ms: 600);
    _tweenNum(() => s.topRot, (v) => s.topRot = v, math.pi, ms: 600, done: () {
      // Rest exactly on the cup rim (y = 4).
      _tweenV3(s.top, y: 4, ms: 400, done: () => _advanceStep());
    });
  }

  /// Step 4: the pitcher fills the funnel and the drip starts.
  void _pour() {
    final s = _s;
    setState(() => s.isPouring = true);
    _Audio.play(_Sound.splash);
    _tweenV3(s.pitcher, x: -4.5, y: 6.5, z: 0, ms: 600, done: () {
      _tweenNum(() => s.pitcherRot, (v) => s.pitcherRot = v, math.pi / 2.2, ms: 400, done: () {
        s.streamOn = true;
        _tweenNum(() => s.stream, (v) => s.stream = v, 1, ms: 200);
        _tweenNum(() => s.topWater, (v) => s.topWater = v, 1, ms: 2000);
        _tweenNum(() => s.pitcherFill, (v) => s.pitcherFill = v, 0.2, ms: 2000);
        s
          ..dripping = true
          ..nextDrip = s.time + 0.2;
        _lab.after(const Duration(milliseconds: 2000), () {
          if (!mounted || !identical(s, _s)) return;
          _tweenNum(() => s.stream, (v) => s.stream = v, 0, ms: 200, done: () => s.streamOn = false);
          _tweenNum(() => s.pitcherRot, (v) => s.pitcherRot = v, 0, ms: 400);
          _tweenNum(() => s.pitcherAlpha, (v) => s.pitcherAlpha = v, 0, ms: 600);
          _tweenV3(s.pitcher, y: -5, ms: 600, done: () {
            s.pitcherVisible = false;
            _advanceStep();
          });
        });
      });
    });
  }

  void _spawnDrop(double t) {
    final s = _s;
    s.dripCount++;
    // The HTML beeps on every drop; a soft drip every third drop keeps
    // the sound pool free for the lab's other sounds.
    if (s.dripCount % 3 == 1) _Audio.play(_Sound.drop, volume: 0.25);
    s.drops.add(_Drop(t, _capBottomY, math.max(0.2, s.waterLevel * 4)));
    if (s.waterLevel < 1) s.waterLevel = math.min(1, s.waterLevel + 0.01);
  }

  /// HTML `startRampTest()`.
  void _startRampTest() {
    if (_timerStarted) return;
    final s = _s;
    setState(() {
      _timerStarted = true;
      s.marks.add(s.waterLevel); // mark the start level
    });
    s.ball.setAll(-13.5, 11.5, -5);
    _tweenV3(s.ball, x: 3.5, y: 1.6, ms: 3200, curve: Curves.easeInQuad);
  }

  /// HTML `stopRampTest()`.
  void _stopRampTest() {
    if (!_timerStarted || _timerStopped) return;
    _Audio.play(_Sound.pop);
    setState(() {
      _timerStopped = true;
      _s.marks.add(_s.waterLevel);
    });
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _rampUi = false);
      _advanceStep();
    });
  }

  /// HTML `startRace()`: the fast race judged with the water clock.
  void _startRace() {
    final s = _s;
    if (s.raceState != 'idle') return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      _startUi = false;
      s.raceState = 'fast';
    });
    _tweenNum(() => s.r1x, (v) => s.r1x = v, 40, ms: 2000);
    _tweenNum(() => s.r2x, (v) => s.r2x = v, 40, ms: 2020, done: () {
      s.raceState = 'finished_ambiguous';
      _advanceStep();
      _lab.after(const Duration(milliseconds: 500), () {
        if (mounted) setState(_updateS2UI);
      });
    });
  }

  /// Step 3: swap the water clock for the digital stopwatch and move the
  /// camera to the finish line.
  void _pickStopwatch() {
    final s = _s;
    _Audio.play(_Sound.pop);
    setState(() {
      s.stopwatchPicked = true;
      _ambiguousUi = false;
      s.waterClockVisible = false;
      s.r1x = -40;
      s.r2x = -40;
      s.raceState = 'reset';
    });
    _tweenV3(s.stopwatch, x: 40, y: 4, z: -12, ms: 500);
    _tweenV3(s.camPos, x: 30, y: 15, z: 30, ms: 1500);
    _tweenNum(() => s.camFocal, (v) => s.camFocal = v, 650, ms: 1500);
    _tweenNum(() => s.camCx, (v) => s.camCx = v, 430, ms: 1500);
    _tweenNum(() => s.camCy, (v) => s.camCy = v, 250, ms: 1500);
    _tweenV3(s.camTarget, x: 40, y: 0, z: 0, ms: 1500, done: () => _advanceStep());
  }

  /// HTML `startSlowMoRace()`.
  void _startSlowMo() {
    final s = _s;
    if (!_swStartEnabled) return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      _swStartEnabled = false;
      _lapEnabled = true;
      _lapCount = 0;
      s
        ..swTime = 0
        ..swUsed = true
        ..swRunning = true
        ..swStart = s.time
        ..raceState = 'slow';
    });
    _tweenNum(() => s.r1x, (v) => s.r1x = v, 40, ms: 10210);
    _tweenNum(() => s.r2x, (v) => s.r2x = v, 40, ms: 10230, done: () {
      s
        ..swRunning = false
        ..swTime = 10.23
        ..raceState = 'done';
      setState(() => _lapEnabled = false);
      _lab.after(const Duration(milliseconds: 1000), () => _advanceStep());
    });
  }

  /// HTML `recordLap()`.
  void _recordLap() {
    if (!_lapEnabled) return;
    _Audio.play(_Sound.pop);
    setState(() {
      _lapCount++;
      final time = _s.swTime.toStringAsFixed(2);
      if (_lapCount == 1) {
        _r1Time = time;
      } else if (_lapCount == 2) {
        _r2Time = time;
      }
    });
  }

  // ------------------------------------------------------------ actions

  LabAction _continueAction() => LabAction(
        label: _t('btn_continue'),
        icon: Icons.arrow_forward,
        onTap: () => _advanceStep(silent: true),
      );

  List<LabAction> _actions() {
    if (_concluded) return const [];
    final s = _s;
    if (s.scenario == 0) {
      if (s.step == 5 && _rampUi) {
        return [
          LabAction(
            label: _t('btn_start_timer'),
            icon: Icons.play_arrow,
            color: _Colors.green600,
            foreground: Colors.white,
            enabled: !_timerStarted,
            highlight: !_timerStarted,
            onTap: _startRampTest,
          ),
          LabAction(
            label: _t('btn_stop_timer'),
            icon: Icons.stop,
            color: _Colors.red600,
            foreground: Colors.white,
            enabled: _timerStarted && !_timerStopped,
            highlight: _timerStarted && !_timerStopped,
            silent: true,
            onTap: _stopRampTest,
          ),
        ];
      }
      if (s.step == 6 && _resultUi) return [_continueAction()];
      return const [];
    }
    if (s.step == 1 && _startUi) {
      return [
        LabAction(
          label: _t('btn_start_race'),
          icon: Icons.flag,
          highlight: true,
          silent: true,
          onTap: _startRace,
        ),
      ];
    }
    if (s.step == 2 && _ambiguousUi) return [_continueAction()];
    if (s.step == 4 && _stopwatchUi) {
      return [
        LabAction(
          label: _t('btn_sw_start'),
          icon: Icons.play_arrow,
          color: _Colors.green600,
          foreground: Colors.white,
          enabled: _swStartEnabled,
          highlight: _swStartEnabled,
          silent: true,
          onTap: _startSlowMo,
        ),
        LabAction(
          label: _t('btn_sw_lap'),
          icon: Icons.flag,
          color: _Colors.indigo600,
          foreground: Colors.white,
          enabled: _lapEnabled,
          highlight: _lapEnabled,
          silent: true,
          onTap: _recordLap,
        ),
      ];
    }
    if (s.step == 5 && _resultsUi) return [_continueAction()];
    return const [];
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
        final pad = MediaQuery.paddingOf(context);
        // Bottom panels sit above the HUD while the sidebar is open.
        final bottom = (_lab.isSidebarOpen ? 14 + 58 * s : 12) + pad.bottom;
        final isS1 = _s.scenario == 0;
        return LabShell(
          controller: _lab,
          icon: Icons.hourglass_top,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _s.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _s.step,
          actions: _actions(),
          sidebarExtraTitle: _t('readings'),
          sidebarExtra: _readings(p, s),
          onReset: _fullReset,
          overlays: [
            if (isS1 && _rampUi) _rampPanel(p, s, inset, bottom),
            if (isS1 && _resultUi) _s1ResultCard(s, inset, bottom),
            if (!isS1 && _startUi) _startRaceButton(s, inset, bottom),
            if (!isS1 && _ambiguousUi) _ambiguousCard(s, inset, bottom),
            if (!isS1 && _stopwatchUi) _stopwatchPanel(s, inset, bottom),
            if (!isS1 && _resultsUi) _raceResultsCard(s, inset, bottom),
          ],
          stage: LabStage(
            designSize: _design,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _onStageTap(d.localPosition),
              child: CustomPaint(
                size: _design,
                painter: _TimePainter(
                  scene: _s,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  labels: {
                    for (final k in const [
                      'lbl_scissors',
                      'lbl_pin',
                      'lbl_pitcher',
                      'lbl_funnel',
                      'lbl_receiver',
                      'lbl_stopwatch',
                      'lbl_runner_1',
                      'lbl_runner_2',
                    ])
                      k: _t(k),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Live readouts (water level and marks / stopwatch and lap times).
  Widget _readings(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, _, _) {
        final sc = _s;
        String pct(double v) => '${(v * 100).round()}%';
        final unit = _t('unit_s');
        final rows = sc.scenario == 0
            ? [
                LabInfoRow(palette: p, scale: f, label: _t('water_level'), value: pct(sc.waterLevel), valueColor: const Color(0xFF38BDF8)),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('start_mark'),
                  value: sc.marks.isNotEmpty ? pct(sc.marks[0]) : _t('not_marked'),
                  valueColor: _Colors.zslYellow,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('stop_mark'),
                  value: sc.marks.length > 1 ? pct(sc.marks[1]) : _t('not_marked'),
                  valueColor: _Colors.zslYellow,
                ),
              ]
            : [
                LabInfoRow(palette: p, scale: f, label: _t('stopwatch'), value: '${sc.swDisplay}$unit'),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('runner_1'),
                  value: '${_r1Time ?? '--.--'}$unit',
                  valueColor: _r1Time != null ? const Color(0xFF60A5FA) : null,
                ),
                LabInfoRow(
                  palette: p,
                  scale: f,
                  label: _t('runner_2'),
                  value: '${_r2Time ?? '--.--'}$unit',
                  valueColor: _r2Time != null ? const Color(0xFFF87171) : null,
                ),
              ];
        return Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        );
      },
    );
  }

  /// Positions an overlay card at the top (or bottom) of the canvas,
  /// clear of the shell UI; it scrolls if the canvas is short.
  Widget _placed(EdgeInsets inset, double bottom, Widget child,
      {Alignment align = Alignment.topCenter, double top = 0}) {
    return Positioned(
      top: inset.top + top,
      left: inset.left,
      right: inset.right,
      bottom: bottom,
      child: Align(alignment: align, child: child),
    );
  }

  Widget _scrollCard({
    required double s,
    required double maxWidth,
    required Widget child,
    Color color = _Colors.slate900,
    Color border = _Colors.slate600,
    double borderWidth = 2,
    double radius = 16,
    EdgeInsets? padding,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius * s),
          border: Border.all(color: border, width: borderWidth),
          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius * s),
          child: SingleChildScrollView(
            padding: padding ?? EdgeInsets.all(14 * s),
            child: child,
          ),
        ),
      ),
    );
  }

  /// HTML `#s1-ramp-ui`: Start Timer / Stop Timer.
  Widget _rampPanel(LabPalette p, double s, EdgeInsets inset, double bottom) {
    // Bottom-right, so the receiver and its water marks stay visible.
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: bottom,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: p.isDark ? const Color(0xE61E293B) : const Color(0xE6FFFFFF),
              borderRadius: BorderRadius.circular(14 * s),
              border: Border.all(color: p.border),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LabActionButton(
                  scale: s,
                  expand: false,
                  action: LabAction(
                    label: _t('btn_start_timer'),
                    icon: Icons.play_arrow,
                    color: _Colors.green600,
                    foreground: Colors.white,
                    enabled: !_timerStarted,
                    onTap: _startRampTest,
                  ),
                ),
                SizedBox(width: 10 * s),
                LabActionButton(
                  scale: s,
                  expand: false,
                  action: LabAction(
                    label: _t('btn_stop_timer'),
                    icon: Icons.stop,
                    color: _Colors.red600,
                    foreground: Colors.white,
                    enabled: _timerStarted && !_timerStopped,
                    silent: true,
                    onTap: _stopRampTest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#s1-result-ui`: the digital time (3.2 s) for comparison.
  Widget _s1ResultCard(double s, EdgeInsets inset, double bottom) {
    return _placed(
      inset,
      bottom,
      _appear(
        _scrollCard(
          s: s,
          maxWidth: 330 * s,
          border: const Color(0xFF6366F1),
          borderWidth: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('digital_time').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFA5B4FC),
                  fontSize: 11.5 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: _ls(2),
                ),
              ),
              SizedBox(height: 2 * s),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: '3.2'),
                  TextSpan(text: _t('unit_s'), style: TextStyle(fontSize: 22 * s)),
                ]),
                style: TextStyle(
                  color: const Color(0xFF4ADE80),
                  fontSize: 44 * s,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                _t('s1_conclusion'),
                textAlign: TextAlign.center,
                style: TextStyle(color: _Colors.slate300, fontSize: 12 * s, height: 1.4, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10 * s),
              LabActionButton(scale: s, expand: false, action: _continueAction()),
            ],
          ),
        ),
      ),
    );
  }

  /// HTML `#s2-start-ui`: the big pulsing START RACE button.
  Widget _startRaceButton(double s, EdgeInsets inset, double bottom) {
    return Positioned(
      top: inset.top,
      left: inset.left,
      right: inset.right,
      bottom: bottom,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: _Ch8A5PulseButton(label: _t('btn_start_race'), scale: s, onTap: _startRace),
        ),
      ),
    );
  }

  /// HTML `#s2-ambiguous-msg`.
  Widget _ambiguousCard(double s, EdgeInsets inset, double bottom) {
    return _placed(
      inset,
      bottom,
      _appear(
        _scrollCard(
          s: s,
          maxWidth: 380 * s,
          color: _Colors.red,
          border: const Color(0xFFFCA5A5),
          radius: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('s2_ambiguous'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14 * s, fontWeight: FontWeight.w800, height: 1.35),
              ),
              SizedBox(height: 10 * s),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8 * s),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8 * s),
                  onTap: () {
                    _Audio.play(_Sound.click);
                    _advanceStep(silent: true);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 8 * s),
                    child: Text(
                      _t('btn_continue').toUpperCase(),
                      style: TextStyle(
                        color: _Colors.red600,
                        fontWeight: FontWeight.w800,
                        fontSize: 12 * s,
                        letterSpacing: _ls(1.2),
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

  /// HTML `#s2-stopwatch-ui`: the digital display with Start and LAP.
  Widget _stopwatchPanel(double s, EdgeInsets inset, double bottom) {
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: bottom,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: _Colors.slate900,
              borderRadius: BorderRadius.circular(22 * s),
              border: Border.all(color: const Color(0xFF6366F1), width: 3),
              boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 210 * s,
                  padding: EdgeInsets.symmetric(vertical: 6 * s),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10 * s),
                    border: Border.all(color: _Colors.slate700),
                  ),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _frame,
                    builder: (context, _, _) => Text(
                      _s.swDisplay,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabActionButton(
                      scale: s,
                      expand: false,
                      action: LabAction(
                        label: _t('btn_sw_start'),
                        icon: Icons.play_arrow,
                        color: _Colors.green600,
                        foreground: Colors.white,
                        enabled: _swStartEnabled,
                        silent: true,
                        onTap: _startSlowMo,
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    LabActionButton(
                      scale: s,
                      expand: false,
                      action: LabAction(
                        label: _t('btn_sw_lap'),
                        icon: Icons.flag,
                        color: _Colors.indigo600,
                        foreground: Colors.white,
                        enabled: _lapEnabled,
                        silent: true,
                        onTap: _recordLap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#s2-results-ui`: the lap times and the verdict.
  Widget _raceResultsCard(double s, EdgeInsets inset, double bottom) {
    final unit = _t('unit_s');
    Widget row(String label, Color labelColor, String? time, Color timeColor) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8 * s),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: labelColor, fontWeight: FontWeight.w800, fontSize: 12.5 * s),
              ),
            ),
            SizedBox(width: 8 * s),
            Text(
              '${time ?? '--.--'}$unit',
              style: TextStyle(
                color: time != null ? timeColor : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20 * s,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return _placed(
      inset,
      bottom,
      // Keep clear of the runners at the finish line (canvas centre): top-left
      // next to the open sidebar, top-right next to the floating mission card.
      align: _lab.isSidebarOpen ? Alignment.topLeft : Alignment.topRight,
      top: 6 * s,
      _appear(
        _scrollCard(
          s: s,
          maxWidth: 250 * s,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _t('race_results').toUpperCase(),
                style: TextStyle(
                  color: _Colors.zslYellow,
                  fontWeight: FontWeight.w800,
                  fontSize: 14 * s,
                  letterSpacing: _ls(1.2),
                ),
              ),
              Divider(color: _Colors.slate700, height: 16 * s),
              row(_t('runner_1'), const Color(0xFF60A5FA), _r1Time, const Color(0xFF60A5FA)),
              row(_t('runner_2'), const Color(0xFFF87171), _r2Time, const Color(0xFFF87171)),
              SizedBox(height: 4 * s),
              Container(
                padding: EdgeInsets.all(9 * s),
                decoration: BoxDecoration(
                  color: const Color(0x8014532D),
                  borderRadius: BorderRadius.circular(8 * s),
                  border: Border.all(color: const Color(0x8022C55E)),
                ),
                child: Text(
                  _t('s2_conclusion'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF4ADE80),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5 * s,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              LabActionButton(scale: s, action: _continueAction()),
            ],
          ),
        ),
      ),
    );
  }

  /// Fade / scale-in for overlay cards (HTML `animate-fade-in-up`).
  Widget _appear(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
      ),
      child: child,
    );
  }
}

/// The big round "START RACE" button with the pulsing glow
/// (HTML `.action-btn` with a white border).
class _Ch8A5PulseButton extends StatefulWidget {
  const _Ch8A5PulseButton({required this.label, required this.scale, required this.onTap});

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  State<_Ch8A5PulseButton> createState() => _Ch8A5PulseButtonState();
}

class _Ch8A5PulseButtonState extends State<_Ch8A5PulseButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.4 + 0.4 * _pulse.value),
              blurRadius: (15 + 10 * _pulse.value) * s,
            ),
            const BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: child,
      ),
      child: Material(
        color: _Colors.zslYellow,
        shape: StadiumBorder(side: BorderSide(color: Colors.white, width: 4 * s)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 34 * s, vertical: 16 * s),
            child: Text(
              widget.label,
              style: TextStyle(
                color: _Colors.slate900,
                fontSize: 26 * s,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Evolution of Time Measurement',
    'app_subtitle': 'Class 7 • Measurement of Time and Motion',
    'scen_1_opt': 'Scenario 1: The Ancient Water Clock',
    'scen_2_opt': 'Scenario 2: The Photo-Finish Race',
    'sci_conclusion': 'Success!',
    'btn_start_timer': 'Start Timer',
    'btn_stop_timer': 'Stop Timer',
    'btn_continue': 'Continue',
    'digital_time': 'Digital Time',
    's1_conclusion':
        'Your measurement is imprecise for fractions of a second. Notice the gap in precision!',
    'btn_start_race': 'START RACE',
    's2_ambiguous': 'Both finished within one drop! Cannot determine winner with a water clock.',
    'race_results': 'Race Results',
    'runner_1': 'Runner 1 (Blue)',
    'runner_2': 'Runner 2 (Red)',
    's2_conclusion': 'Runner 1 wins by 0.02s! High precision detects the hundredths.',
    'conclusion_1':
        'Ancient devices like the water clock relied on steady, periodic events (water dripping) but lacked the precision to measure fractions of a second accurately.',
    'conclusion_2':
        'Modern activities, especially sports, require highly precise instruments like digital stopwatches to differentiate milliseconds and ensure fairness.',
    // Strings that were hard-coded (English only) in the HTML.
    'btn_sw_start': 'Start',
    'btn_sw_lap': 'LAP',
    'lbl_scissors': 'Cutting Tool',
    'lbl_pin': 'Drawing Pin',
    'lbl_pitcher': 'Water Pitcher',
    'lbl_funnel': 'Funnel (Top)',
    'lbl_receiver': 'Receiver (Bottom)',
    'lbl_stopwatch': 'Digital Stopwatch',
    'lbl_runner_1': 'Runner 1',
    'lbl_runner_2': 'Runner 2',
    'unit_s': 's',
    'readings': 'Lab Readings',
    'water_level': 'Water level (receiver)',
    'start_mark': 'Start mark',
    'stop_mark': 'Stop mark',
    'not_marked': 'Not marked',
    'stopwatch': 'Stopwatch',
  },
  'hi': {
    'app_title': 'समय मापन का विकास',
    'app_subtitle': 'कक्षा 7 • समय और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: प्राचीन जल घड़ी',
    'scen_2_opt': 'परिदृश्य 2: फोटो-फिनिश रेस',
    'sci_conclusion': 'सफलता!',
    'btn_start_timer': 'टाइमर शुरू करें',
    'btn_stop_timer': 'टाइमर रोकें',
    'btn_continue': 'जारी रखें',
    'digital_time': 'डिजिटल समय',
    's1_conclusion': 'एक सेकंड के अंशों के लिए आपका मापन गलत है। सटीकता में अंतर पर ध्यान दें!',
    'btn_start_race': 'दौड़ शुरू करें',
    's2_ambiguous': 'दोनों एक ही बूंद के भीतर समाप्त हो गए! जल घड़ी से विजेता का निर्धारण नहीं कर सकते।',
    'race_results': 'दौड़ के परिणाम',
    'runner_1': 'धावक 1 (नीला)',
    'runner_2': 'धावक 2 (लाल)',
    's2_conclusion': 'धावक 1 0.02s से जीता! उच्च सटीकता सौवें हिस्से का पता लगाती है।',
    'conclusion_1':
        'जल घड़ी जैसे प्राचीन उपकरण स्थिर घटनाओं (पानी टपकना) पर निर्भर थे, लेकिन एक सेकंड के अंशों को सटीक रूप से मापने के लिए सटीकता की कमी थी।',
    'conclusion_2':
        'आधुनिक गतिविधियों, विशेष रूप से खेलों में, मिलीसेकंड को अलग करने और निष्पक्षता सुनिश्चित करने के लिए डिजिटल स्टॉपवॉच जैसे अत्यधिक सटीक उपकरणों की आवश्यकता होती है।',
    'btn_sw_start': 'प्रारंभ',
    'btn_sw_lap': 'LAP',
    'lbl_scissors': 'काटने का औज़ार',
    'lbl_pin': 'ड्रॉइंग पिन',
    'lbl_pitcher': 'पानी का जग',
    'lbl_funnel': 'फ़नल (ऊपरी भाग)',
    'lbl_receiver': 'पात्र (निचला भाग)',
    'lbl_stopwatch': 'डिजिटल स्टॉपवॉच',
    'lbl_runner_1': 'धावक 1',
    'lbl_runner_2': 'धावक 2',
    'unit_s': 's',
    'readings': 'लैब रीडिंग',
    'water_level': 'जल स्तर (पात्र)',
    'start_mark': 'प्रारंभ चिह्न',
    'stop_mark': 'समाप्ति चिह्न',
    'not_marked': 'चिह्नित नहीं',
    'stopwatch': 'स्टॉपवॉच',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To construct and use a simple water clock to understand its mechanics and limitations in measuring time accurately.',
      steps: [
        LabStep(
          concept: 'Setup',
          action: 'CLICK the scissors on the table to cut the bottle in half.',
          observation: 'The bottle is separated into a funnel and a cup.',
        ),
        LabStep(
          concept: 'Preparation',
          action: 'CLICK the drawing pin on the table to make a hole in the cap.',
          observation: 'A small hole allows water to flow.',
        ),
        LabStep(
          concept: 'Assembly',
          action: 'CLICK the top half (Funnel) to build the water clock.',
          observation: 'The top half is inverted into the bottom half.',
        ),
        LabStep(
          concept: 'Activation',
          action: 'CLICK the pitcher on the table to fill the top funnel.',
          observation: 'Water pours slowly into the top funnel, initiating the drip.',
        ),
        LabStep(
          concept: 'Timing Test',
          action: "CLICK 'Start Timer' when the ball rolls, and 'Stop' when it ends.",
          observation: 'You mark the water levels to measure elapsed time.',
        ),
        LabStep(
          concept: 'Comparison',
          action: 'Compare your water clock measurement with the digital timer.',
          observation: 'The water clock cannot accurately measure 3.2 seconds.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To experience the necessity of high-precision timing by comparing results from a water clock and a digital stopwatch in a close race.',
      steps: [
        LabStep(
          concept: 'The Race',
          action: "CLICK 'START RACE' to begin the sprint using the water clock.",
          observation: 'Runners dash towards the finish line.',
        ),
        LabStep(
          concept: 'Ambiguity',
          action: 'Attempt to determine the winner.',
          observation: "Both runners finish within a single water drop. It's too close to call.",
        ),
        LabStep(
          concept: 'Upgrade Gear',
          action: 'CLICK the digital stopwatch on the table to get a better tool.',
          observation: 'The water clock is replaced by a digital stopwatch.',
        ),
        LabStep(
          concept: 'Precision Timing',
          action: "CLICK 'Start' for a slow-motion replay, then CLICK 'LAP' as each crosses.",
          observation: 'The stopwatch records exact times for both runners.',
        ),
        LabStep(
          concept: 'The Verdict',
          action: 'Analyze the final results.',
          observation: 'The difference is only 0.02s, impossible to measure without a stopwatch.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'समय को सटीक रूप से मापने में इसके यांत्रिकी और सीमाओं को समझने के लिए एक साधारण जल घड़ी का निर्माण और उपयोग करना।',
      steps: [
        LabStep(
          concept: 'सेटअप',
          action: 'बोतल को आधा काटने के लिए मेज पर कैंची पर क्लिक करें।',
          observation: 'बोतल एक फ़नल और एक कप में अलग हो जाती है।',
        ),
        LabStep(
          concept: 'तैयारी',
          action: 'टोपी में छेद करने के लिए मेज पर पिन पर क्लिक करें।',
          observation: 'एक छोटा छेद पानी को बहने देता है।',
        ),
        LabStep(
          concept: 'संयोजन',
          action: 'जल घड़ी बनाने के लिए ऊपरी हिस्से पर क्लिक करें।',
          observation: 'ऊपरी आधा हिस्सा निचले आधे हिस्से में उलटा होता है।',
        ),
        LabStep(
          concept: 'सक्रियण',
          action: 'ऊपरी फ़नल को भरने के लिए मेज पर घड़े पर क्लिक करें।',
          observation: 'पानी धीरे-धीरे ऊपरी फ़नल में डाला जाता है, जिससे टपकना शुरू होता है।',
        ),
        LabStep(
          concept: 'परीक्षण',
          action: "गेंद के लुढ़कने पर 'टाइमर शुरू करें' पर क्लिक करें, और 'रोकें' पर क्लिक करें।",
          observation: 'आप बीता हुआ समय मापने के लिए जल स्तर को चिह्नित करते हैं।',
        ),
        LabStep(
          concept: 'तुलना',
          action: 'डिजिटल टाइमर के साथ अपने जल घड़ी माप की तुलना करें।',
          observation: 'जल घड़ी 3.2 सेकंड को सटीक रूप से नहीं माप सकती।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'एक करीबी दौड़ में पानी की घड़ी और डिजिटल स्टॉपवॉच के परिणामों की तुलना करके उच्च-सटीक समय की आवश्यकता का अनुभव करना।',
      steps: [
        LabStep(
          concept: 'दौड़',
          action: "जल घड़ी का उपयोग करके दौड़ शुरू करने के लिए 'दौड़ शुरू करें' पर क्लिक करें।",
          observation: 'धावक फिनिश लाइन की ओर दौड़ते हैं।',
        ),
        LabStep(
          concept: 'अस्पष्टता',
          action: 'विजेता का निर्धारण करने का प्रयास करें।',
          observation: 'दोनों धावक एक ही पानी की बूंद के भीतर समाप्त होते हैं।',
        ),
        LabStep(
          concept: 'गियर अपग्रेड',
          action: 'बेहतर टूल पाने के लिए मेज पर स्टॉपवॉच पर क्लिक करें।',
          observation: 'जल घड़ी को डिजिटल स्टॉपवॉच से बदल दिया जाता है।',
        ),
        LabStep(
          concept: 'सटीक समय',
          action:
              "धीमी गति के रीप्ले के लिए 'प्रारंभ' पर क्लिक करें, फिर प्रत्येक पार होने पर 'LAP' पर क्लिक करें।",
          observation: 'स्टॉपवॉच दोनों धावकों के लिए सटीक समय रिकॉर्ड करती है।',
        ),
        LabStep(
          concept: 'निर्णय',
          action: 'अंतिम परिणामों का विश्लेषण करें।',
          observation: 'अंतर केवल 0.02s है, जिसे स्टॉपवॉच के बिना मापना असंभव है।',
        ),
      ],
    ),
  ],
};

// ======================================================== PROJECTION

typedef _P3 = (double, double, double);

/// Perspective "look-at" camera that reproduces the HTML PerspectiveCamera
/// (position + controls.target) on the design canvas.
class _Cam {
  _Cam(_V3 pos, _V3 target, this.focal, this.center)
      : px = pos.x,
        py = pos.y,
        pz = pos.z {
    final fx0 = target.x - px, fy0 = target.y - py, fz0 = target.z - pz;
    final fl = math.sqrt(fx0 * fx0 + fy0 * fy0 + fz0 * fz0);
    fx = fx0 / fl;
    fy = fy0 / fl;
    fz = fz0 / fl;
    // right = forward × up(0, 1, 0)
    final rl = math.sqrt(fz * fz + fx * fx);
    rx = -fz / rl;
    rz = fx / rl;
    // up = right × forward
    ux = -rz * fy;
    uy = rz * fx - rx * fz;
    uz = rx * fy;
  }

  static const double near = 1.0;
  final double px, py, pz, focal;
  final Offset center;
  late final double fx, fy, fz, rx, rz, ux, uy, uz;

  _P3 toCam(double x, double y, double z) {
    final dx = x - px, dy = y - py, dz = z - pz;
    return (dx * rx + dz * rz, dx * ux + dy * uy + dz * uz, dx * fx + dy * fy + dz * fz);
  }

  Offset _screen(_P3 c) {
    final d = math.max(near, c.$3);
    return Offset(center.dx + c.$1 * focal / d, center.dy - c.$2 * focal / d);
  }

  Offset p(double x, double y, double z) => _screen(toCam(x, y, z));

  /// Pixels per world unit at this point.
  double k(double x, double y, double z) => focal / math.max(near, toCam(x, y, z).$3);

  /// Polygon of world points, clipped against the near plane.
  Path? poly(List<_P3> pts) {
    final cs = [for (final q in pts) toCam(q.$1, q.$2, q.$3)];
    final out = <_P3>[];
    for (var i = 0; i < cs.length; i++) {
      final a = cs[i], b = cs[(i + 1) % cs.length];
      final ain = a.$3 >= near, bin = b.$3 >= near;
      if (ain) out.add(a);
      if (ain != bin) {
        final t = (near - a.$3) / (b.$3 - a.$3);
        out.add((a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t, near));
      }
    }
    if (out.length < 3) return null;
    return Path()..addPolygon([for (final c in out) _screen(c)], true);
  }
}

/// Object transform: position + rotation about the world z axis.
class _Xf {
  const _Xf(this.x, this.y, this.z, [this.rot = 0]);
  final double x, y, z, rot;

  _P3 w(double lx, double ly, [double lz = 0]) {
    final c = math.cos(rot), s = math.sin(rot);
    return (x + lx * c - ly * s, y + lx * s + ly * c, z + lz);
  }

  Offset p(_Cam cam, double lx, double ly, [double lz = 0]) {
    final q = w(lx, ly, lz);
    return cam.p(q.$1, q.$2, q.$3);
  }

  double worldY(double ly) => y + ly * math.cos(rot);
}

Color _a(Color c, double opacity) => c.withValues(alpha: (c.a * opacity).clamp(0.0, 1.0));

/// Lambert-ish brightness (ambient 0.62 + diffuse from the HTML key light).
Color _lit(Color c, double b) => b <= 1 ? Color.lerp(Colors.black, c, b)! : labShade(c, (b - 1) * 1.2);

List<Offset> _ring(_Cam cam, _Xf xf, double ly, double r, {int n = 28}) {
  return [
    for (var i = 0; i < n; i++)
      xf.p(cam, r * math.cos(2 * math.pi * i / n), ly, r * math.sin(2 * math.pi * i / n)),
  ];
}

/// Convex hull (monotone chain) as a closed path.
Path _hull(List<Offset> pts) {
  final ps = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in ps) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in ps.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  final hull = [...lower..removeLast(), ...upper..removeLast()];
  return Path()..addPolygon(hull, true);
}

/// Opaque cylinder / cone section between local heights y0 (radius r0)
/// and y1 (radius r1), with its visible end cap.
void _frustum(
  Canvas canvas,
  _Cam cam,
  _Xf xf,
  double y0,
  double r0,
  double y1,
  double r1,
  Color color, {
  double opacity = 1,
  bool cap = true,
  Color? capColor,
}) {
  final a = _ring(cam, xf, y0, r0);
  final b = _ring(cam, xf, y1, r1);
  final hull = _hull([...a, ...b]);
  final bounds = hull.getBounds();
  if (bounds.width < 0.5) return;
  canvas.drawPath(
    hull,
    Paint()
      ..shader = LinearGradient(colors: [
        _a(labShade(color, -0.35), opacity),
        _a(labShade(color, 0.25), opacity),
        _a(color, opacity),
        _a(labShade(color, -0.45), opacity),
      ], stops: const [0, 0.3, 0.6, 1]).createShader(bounds),
  );
  if (cap) {
    final topRing = xf.worldY(y1) >= xf.worldY(y0) ? b : a;
    canvas.drawPath(
      Path()..addPolygon(topRing, true),
      Paint()..color = _a(capColor ?? labShade(color, 0.3), opacity),
    );
  }
}

/// Transparent plastic body (MeshPhysicalMaterial, opacity 0.55):
/// a tinted fill drawn behind the contents.
void _glassFill(Canvas canvas, _Cam cam, _Xf xf, List<(double, double)> profile, Color tint,
    {double opacity = 1, bool light = false}) {
  final pts = <Offset>[for (final pr in profile) ..._ring(cam, xf, pr.$1, pr.$2)];
  canvas.drawPath(_hull(pts), Paint()..color = _a(tint, (light ? 0.32 : 0.2) * opacity));
}

/// Edges, rims and the specular highlight of a plastic body, drawn in
/// front of the contents.
void _glassEdges(Canvas canvas, _Cam cam, _Xf xf, List<(double, double)> profile, Color tint,
    {double opacity = 1, bool light = false}) {
  final edge = light ? labShade(tint, -0.45) : labShade(tint, 0.15);
  final rings = [for (final pr in profile) _ring(cam, xf, pr.$1, pr.$2)];
  final hull = _hull([for (final r in rings) ...r]);
  canvas.drawPath(
    hull,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = _a(edge, 0.75 * opacity),
  );
  for (var i = 0; i < rings.length; i++) {
    final last = i == 0 || i == rings.length - 1;
    canvas.drawPath(
      Path()..addPolygon(rings[i], true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = last ? 1.8 : 1.1
        ..color = _a(edge, (last ? 0.8 : 0.45) * opacity),
    );
  }
  // Specular streak down the front-left of each section.
  final hl = Paint()
    ..strokeWidth = 2.6
    ..strokeCap = StrokeCap.round
    ..color = Colors.white.withValues(alpha: 0.45 * opacity);
  for (var i = 0; i + 1 < profile.length; i++) {
    final (ya, ra) = profile[i];
    final (yb, rb) = profile[i + 1];
    if ((yb - ya).abs() < 0.3) continue;
    final dir = yb > ya ? 1 : -1;
    canvas.drawLine(
      xf.p(cam, -ra * 0.62, ya + 0.15 * dir, ra * 0.7),
      xf.p(cam, -rb * 0.62, yb - 0.15 * dir, rb * 0.7),
      hl,
    );
  }
}

const List<(List<double>, List<List<double>>)> _boxFaces = [
  ([1, 0, 0], [[1, -1, -1], [1, 1, -1], [1, 1, 1], [1, -1, 1]]),
  ([-1, 0, 0], [[-1, -1, -1], [-1, -1, 1], [-1, 1, 1], [-1, 1, -1]]),
  ([0, 1, 0], [[-1, 1, -1], [-1, 1, 1], [1, 1, 1], [1, 1, -1]]),
  ([0, -1, 0], [[-1, -1, -1], [1, -1, -1], [1, -1, 1], [-1, -1, 1]]),
  ([0, 0, 1], [[-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1]]),
  ([0, 0, -1], [[-1, -1, -1], [-1, 1, -1], [1, 1, -1], [1, -1, -1]]),
];

/// BoxGeometry with MeshStandardMaterial-like shading and back-face culling.
void _box(Canvas canvas, _Cam cam, double cx, double cy, double cz, double w, double h, double d,
    Color color, {double rot = 0, double opacity = 1}) {
  final c = math.cos(rot), s = math.sin(rot);
  final hw = w / 2, hh = h / 2, hd = d / 2;
  _P3 world(double lx, double ly, double lz) => (cx + lx * c - ly * s, cy + lx * s + ly * c, cz + lz);
  const lx = 0.408, ly = 0.816, lz = 0.408; // normalised (10, 20, 10)
  for (final (n, corners) in _boxFaces) {
    final nx = n[0] * c - n[1] * s, ny = n[0] * s + n[1] * c, nz = n[2];
    final fc = world(n[0] * hw, n[1] * hh, n[2] * hd);
    final vx = cam.px - fc.$1, vy = cam.py - fc.$2, vz = cam.pz - fc.$3;
    if (nx * vx + ny * vy + nz * vz <= 0) continue;
    final path = cam.poly([for (final q in corners) world(q[0] * hw, q[1] * hh, q[2] * hd)]);
    if (path == null) continue;
    final b = 0.62 + 0.55 * math.max(0, nx * lx + ny * ly + nz * lz);
    canvas.drawPath(path, Paint()..color = _a(_lit(color, b), opacity));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _a(labShade(color, -0.5), 0.45 * opacity),
    );
  }
}

// ============================================================ PAINTER

const Color _plastic = Color(0xFF7DD3FC);
const Color _water = Color(0xFF0EA5E9);
const Color _capNavy = Color(0xFF1E3A8A);
const Color _wood = Color(0xFF8B5A2B);
const Color _steel = Color(0xFF94A3B8);
const Color _redTool = Color(0xFFEF4444);

class _TimePainter extends CustomPainter {
  _TimePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labels,
  }) : super(repaint: repaint);

  final _TimeScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> labels;

  String _l(String key) => labels[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = scene.camera();
    if (scene.scenario == 0) {
      _paintLab(canvas, size, cam);
    } else {
      _paintRace(canvas, size, cam);
    }
  }

  // ------------------------------------------------------ shared bits

  /// Pulsing highlight behind the object that can be clicked now
  /// (stands in for the HTML hover emissive + `active-tool-glow`).
  void _hint(Canvas canvas, Offset c, double r, double t) {
    final pulse = 0.5 + 0.5 * math.sin(t * 4);
    labGlow(canvas, c, r * (1 + 0.08 * pulse), _Colors.zslYellow, intensity: 0.22 + 0.18 * pulse);
  }

  /// Floating 3D label (HTML `.absolute px-3 py-1 bg-slate-800/90 …`);
  /// the current step's tool gets the yellow ring.
  void _label(Canvas canvas, String text, Offset at, double t,
      {bool active = false, Alignment anchor = Alignment.center, double opacity = 1, Color? background}) {
    if (!showLabels || opacity <= 0.02) return;
    if (active) {
      final pulse = 0.5 + 0.5 * math.sin(t * 4);
      canvas.drawCircle(
        at,
        34 + 6 * pulse,
        Paint()
          ..color = _Colors.zslYellow.withValues(alpha: 0.14 + 0.12 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
    labText(
      canvas,
      text,
      at,
      size: 14,
      color: Colors.white,
      weight: FontWeight.w700,
      background: background ?? const Color(0xE61E293B),
      border: active ? _Colors.zslYellow : const Color(0xFF475569),
      borderWidth: active ? 2.4 : 1,
      anchor: anchor,
      opacity: opacity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
    );
  }

  // ===================================================== SCENARIO 1

  void _paintLab(Canvas canvas, Size size, _Cam cam) {
    final s = scene;
    final t = s.time;
    _labBackground(canvas, size, cam);
    _paintRamp(canvas, cam);
    _paintBall(canvas, cam);

    final items = <(double, VoidCallback)>[
      (0.0, () => _paintReceiver(canvas, cam, t)),
      if (!s.isAssembled) (s.top.z + 0.01, () => _paintFunnel(canvas, cam, t)),
      if (s.scissorsVisible) (s.scissors.z + 0.03, () => _paintScissors(canvas, cam, t)),
      if (s.pinVisible) (s.pin.z + 0.02, () => _paintPin(canvas, cam, t)),
      if (s.pitcherVisible) (s.pitcher.z + 0.025, () => _paintPitcher(canvas, cam, t)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final item in items) {
      item.$2();
    }
    _labLabels(canvas, cam, t);
  }

  void _labBackground(Canvas canvas, Size size, _Cam cam) {
    final bleed = labBleed(size);
    final backY = cam.p(0, 0, -9).dy;
    final frontY = cam.p(0, 0, 7).dy;
    // Bench front (fills the lower letterbox too).
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, frontY, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF273449), Color(0xFF0F172A)]
              : const [Color(0xFFB08C62), Color(0xFF8A6A45)],
        ).createShader(Rect.fromLTRB(0, frontY, 10, frontY + 120)),
    );
    // Lab wall.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, backY + 1),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1120), Color(0xFF1E293B)]
              : const [Color(0xFFDDE6F0), Color(0xFFF1F5F9)],
        ).createShader(Rect.fromLTRB(0, 0, 10, backY)),
    );
    // Wall tiles.
    final tile = Paint()
      ..color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: isDark ? 0.035 : 0.08)
      ..strokeWidth = 1;
    for (var y = backY - 34; y > bleed.top; y -= 34) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), tile);
    }
    for (var x = -20.0; x < size.width + 20; x += 52) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, backY), tile);
    }
    // Bench top.
    final top = cam.poly(const [(-200, 0, -9), (200, 0, -9), (200, 0, 7), (-200, 0, 7)]);
    if (top != null) {
      canvas.drawPath(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF2B3A52), Color(0xFF475569)]
                : const [Color(0xFFE9D8BC), Color(0xFFD4B48A)],
          ).createShader(Rect.fromLTRB(0, backY, 10, frontY)),
      );
    }
    // Back edge shadow and front lip.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, backY, bleed.right, backY + 6),
      Paint()..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, frontY, bleed.right, frontY + 9),
      Paint()..color = isDark ? const Color(0xFF64748B) : const Color(0xFFC29B6B),
    );
    canvas.drawLine(
      Offset(bleed.left, frontY),
      Offset(bleed.right, frontY),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.25 : 0.45)
        ..strokeWidth = 1.5,
    );
  }

  /// HTML `createRampEnvironment()`: wooden ramp (20 × 0.5 × 3, tilted
  /// 30°) with side rails and two support pillars.
  void _paintRamp(Canvas canvas, _Cam cam) {
    final kb = cam.k(-13, 0, -5);
    labGroundShadow(canvas, cam.p(-13, 0, -4.6), 2.2 * kb, 0.8 * kb, opacity: 0.35);
    labGroundShadow(canvas, cam.p(-3, 0, -4.6), 2.2 * kb, 0.8 * kb, opacity: 0.35);
    _box(canvas, cam, -13, 6, -5, 1, 12, 3, _wood);
    _box(canvas, cam, -3, 3, -5, 1, 6, 3, _wood);
    const rot = -math.pi / 6;
    final sn = math.sin(rot), co = math.cos(rot);
    final rx = -5 - 0.75 * sn, ry = 6 + 0.75 * co;
    _box(canvas, cam, rx, ry, -6.25, 20, 1, 0.5, _wood, rot: rot);
    _box(canvas, cam, -5, 6, -5, 20, 0.5, 3, labShade(_wood, 0.08), rot: rot);
    _box(canvas, cam, rx, ry, -3.75, 20, 1, 0.5, _wood, rot: rot);
  }

  void _paintBall(Canvas canvas, _Cam cam) {
    final b = scene.ball;
    final c = cam.p(b.x, b.y, b.z);
    final r = 0.8 * cam.k(b.x, b.y, b.z);
    labSphere(canvas, c, r, const Color(0xFFF8FAFC), highlight: 0.6, shade: 0.4);
    // Seam so the roll is visible.
    final dx = b.x + 13.5, dy = b.y - 11.5;
    final angle = math.sqrt(dx * dx + dy * dy) / 0.8;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.72),
      -1.0,
      2.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.13
        ..strokeCap = StrokeCap.round
        ..color = _redTool.withValues(alpha: 0.75),
    );
    canvas.restore();
  }

  /// Bottom half of the bottle (the receiver) with its water, the drops,
  /// the inverted funnel (once assembled) and the yellow level marks.
  void _paintReceiver(Canvas canvas, _Cam cam, double t) {
    final s = scene;
    const xf = _Xf(-6, 0, 0);
    const profile = [(0.0, 2.0), (4.0, 2.0)];
    final k = cam.k(-6, 2, 0);
    labGroundShadow(canvas, cam.p(-6, 0, 0.5), 5.0 * k, 1.4 * k, opacity: isDark ? 0.4 : 0.25);
    _glassFill(canvas, cam, xf, profile, _plastic, light: !isDark);
    final h = s.waterLevel * 4;
    if (h > 0.02) {
      _frustum(canvas, cam, xf, 0.08, 1.92, h, 1.92, _water, opacity: 0.85, capColor: labShade(_water, 0.35));
    }
    for (final d in s.drops) {
      if (d.y1 >= d.y0) continue;
      final pr = ((t - d.t0) / 0.4).clamp(0.0, 1.0);
      final y = d.y0 + (d.y1 - d.y0) * Curves.easeInQuad.transform(pr);
      final dk = cam.k(-6, y, 0);
      final c = cam.p(-6, y, 0);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 0.3 * dk, height: 0.42 * dk),
        Paint()..color = labShade(_water, 0.15),
      );
      canvas.drawCircle(c.translate(-0.05 * dk, -0.07 * dk), 0.05 * dk, Paint()..color = Colors.white70);
    }
    if (s.isAssembled) _paintFunnel(canvas, cam, t);
    _glassEdges(canvas, cam, xf, profile, _plastic, light: !isDark);
    // Water marks (HTML `.water-mark`: 30 × 4 px yellow bars).
    for (final m in s.marks) {
      final c = cam.p(-6, m * 4, 2.1);
      final w = 1.3 * cam.k(-6, m * 4, 2.1);
      final r = Rect.fromCenter(center: c, width: w, height: 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.shift(const Offset(0, 1.5)), const Radius.circular(2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), Paint()..color = _Colors.zslYellow);
    }
  }

  /// Top half of the bottle: cone (wide end at its pivot), neck and cap.
  void _paintFunnel(Canvas canvas, _Cam cam, double t) {
    final s = scene;
    final xf = _Xf(s.top.x, s.top.y, s.top.z, s.topRot);
    const profile = [(0.0, 2.0), (2.0, 0.5), (2.5, 0.5)];
    final k = cam.k(s.top.x, s.top.y + 1.4, s.top.z);
    if (s.step == 3 && !s.isAssembled) _hint(canvas, xf.p(cam, 0, 1.4), 3.4 * k, t);
    if (s.top.y < 0.4 && s.topRot.abs() < 0.2) {
      labGroundShadow(canvas, cam.p(s.top.x, 0, s.top.z + 0.5), 5.0 * k, 1.4 * k, opacity: isDark ? 0.4 : 0.25);
    }
    _glassFill(canvas, cam, xf, profile, _plastic, light: !isDark);
    if (s.topWater > 0.01) {
      // Water fills the inverted cone from the neck up.
      final h = 1.8 * s.topWater * (1 - 0.5 * s.waterLevel);
      _frustum(canvas, cam, xf, 2.45, 0.44, 2.0, 0.46, _water, opacity: 0.88, cap: false);
      final ly = 2.0 - h;
      _frustum(canvas, cam, xf, 2.0, 0.46, ly, (2 - 0.75 * ly) * 0.93, _water,
          opacity: 0.88, capColor: labShade(_water, 0.35));
    }
    _frustum(canvas, cam, xf, 2.5, 0.55, 2.9, 0.55, _capNavy, capColor: labShade(_capNavy, 0.25));
    if (s.hasHole && math.cos(s.topRot) > 0) {
      canvas.drawPath(Path()..addPolygon(_ring(cam, xf, 2.91, 0.12), true), Paint()..color = Colors.black);
    }
    _glassEdges(canvas, cam, xf, profile, _plastic, light: !isDark);
  }

  /// Scissors (steel blades, red handle rings).
  void _paintScissors(Canvas canvas, _Cam cam, double t) {
    final s = scene;
    if (s.scissorsAlpha <= 0.01) return;
    final idle = s.step == 1 && !s.isCut;
    final bob = idle ? math.sin(t * 5) * 0.2 : 0.0;
    final x = s.scissors.x, y = s.scissors.y + bob, z = s.scissors.z;
    final c = cam.p(x, y, z);
    final k = cam.k(x, y, z);
    if (idle) _hint(canvas, c.translate(0.2 * k, -0.2 * k), 2.4 * k, t);
    if (s.scissors.y < 1) {
      labGroundShadow(canvas, cam.p(x + 0.2, 0, z), 2.8 * k, 0.7 * k, opacity: 0.3 * s.scissorsAlpha);
    }
    final open = (s.snip > 0 && s.snip < 1) ? 0.32 * (0.5 + 0.5 * math.cos(s.snip * 4 * math.pi)) : 0.3;
    final fade = s.scissorsAlpha < 1;
    if (fade) {
      canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: s.scissorsAlpha));
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-1.0 + s.scissorsFly);
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.rotate(side * open / 2);
      // Handle ring + shank on the opposite side of the blade.
      final ring = Offset(-0.85 * k, -side * 0.34 * k);
      final redPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.17 * k
        ..strokeCap = StrokeCap.round
        ..color = _redTool;
      canvas.drawLine(Offset.zero, ring * 0.55, redPaint);
      canvas.drawCircle(ring, 0.3 * k, redPaint);
      canvas.drawCircle(
        ring.translate(-0.05 * k, -0.06 * k),
        0.3 * k,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05 * k
          ..color = Colors.white.withValues(alpha: 0.35),
      );
      // Blade.
      final blade = Path()
        ..moveTo(-0.1 * k, side * 0.02 * k)
        ..quadraticBezierTo(0.9 * k, side * 0.16 * k, 1.8 * k, side * 0.01 * k)
        ..lineTo(1.75 * k, -side * 0.03 * k)
        ..lineTo(-0.1 * k, -side * 0.1 * k)
        ..close();
      canvas.drawPath(
        blade,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [labShade(_steel, 0.55), _steel, labShade(_steel, -0.35)],
          ).createShader(Rect.fromLTRB(0, -0.2 * k, 1.8 * k, 0.2 * k)),
      );
      canvas.drawPath(
        blade,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = labShade(_steel, -0.5),
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 0.1 * k, Paint()..color = _Colors.slate600);
    canvas.drawCircle(Offset.zero, 0.05 * k, Paint()..color = _Colors.slate300);
    canvas.restore();
    if (fade) canvas.restore();
  }

  /// Drawing pin: red head + steel needle. Lies on the table, then turns
  /// needle-down to pierce the cap.
  void _paintPin(Canvas canvas, _Cam cam, double t) {
    final s = scene;
    if (s.pinAlpha <= 0.01) return;
    final idle = s.step == 2 && !s.isPierced;
    final bob = idle ? math.sin(t * 5) * 0.2 : 0.0;
    final x = s.pin.x, y = s.pin.y + bob, z = s.pin.z;
    final c = cam.p(x, y, z);
    final k = cam.k(x, y, z);
    final u = s.pinUpright;
    if (idle) _hint(canvas, c, 1.9 * k, t);
    if (s.pin.y < 1) labGroundShadow(canvas, cam.p(x + 0.3, 0, z), 1.6 * k, 0.5 * k, opacity: 0.3);
    final o = s.pinAlpha;
    final dir = Offset.lerp(const Offset(0.8, 0.6), const Offset(0, 1), u)!;
    final len = (1.25 + 0.15 * u) * k;
    final tip = c + dir / dir.distance * len;
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..strokeWidth = math.max(1.8, 0.13 * k)
        ..strokeCap = StrokeCap.round
        ..color = _a(_steel, o),
    );
    canvas.drawLine(
      Offset.lerp(c, tip, 0.2)!,
      Offset.lerp(c, tip, 0.85)!,
      Paint()
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.6 * o),
    );
    // Head: a disc facing the viewer when lying, seen edge-on-ish upright.
    final hw = 0.4 * k;
    final hh = hw * (1 - 0.62 * u);
    final band = 0.2 * k * u;
    if (band > 0.5) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(c.dx - hw, c.dy, c.dx + hw, c.dy + band), Radius.circular(hh)),
        Paint()..color = _a(labShade(_redTool, -0.35), o),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c.translate(0, band), width: hw * 2, height: hh * 2),
        Paint()..color = _a(labShade(_redTool, -0.35), o),
      );
    }
    final head = Rect.fromCenter(center: c, width: hw * 2, height: hh * 2);
    canvas.drawOval(
      head,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [_a(labShade(_redTool, 0.45), o), _a(_redTool, o), _a(labShade(_redTool, -0.4), o)],
        ).createShader(head),
    );
  }

  /// Water pitcher (transparent body, ring handle, water inside). Pours
  /// into the funnel when tilted.
  void _paintPitcher(Canvas canvas, _Cam cam, double t) {
    final s = scene;
    if (s.pitcherAlpha <= 0.01) return;
    final idle = s.step == 4 && !s.isPouring;
    final bob = idle ? math.sin(t * 5) * 0.2 : 0.0;
    final xf = _Xf(s.pitcher.x, s.pitcher.y + bob, s.pitcher.z, s.pitcherRot);
    final k = cam.k(xf.x, xf.y + 1.5, xf.z);
    final fade = s.pitcherAlpha < 1;
    if (fade) canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: s.pitcherAlpha));
    if (idle) _hint(canvas, xf.p(cam, 0.4, 1.5), 3.2 * k, t);
    if (s.pitcher.y < 0.5 && s.pitcherRot.abs() < 0.1) {
      labGroundShadow(canvas, cam.p(xf.x + 0.3, 0, xf.z + 0.4), 4.4 * k, 1.2 * k, opacity: isDark ? 0.4 : 0.25);
    }
    // Handle (torus in the x-y plane).
    final hc = xf.p(cam, 1.5, 1.5);
    final edge = isDark ? labShade(_plastic, 0.15) : labShade(_plastic, -0.45);
    canvas.drawCircle(
      hc,
      0.8 * k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3 * k
        ..color = _plastic.withValues(alpha: isDark ? 0.4 : 0.55),
    );
    for (final r in [0.65, 0.95]) {
      canvas.drawCircle(
        hc,
        r * k,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = edge.withValues(alpha: 0.6),
      );
    }
    const profile = [(0.0, 1.2), (3.0, 1.5)];
    _glassFill(canvas, cam, xf, profile, _plastic, light: !isDark);
    // Water inside: an elliptical surface when upright, a level line when tilted.
    if (s.pitcherFill > 0.01) {
      if (s.pitcherRot.abs() < 0.03) {
        final top = 0.1 + 2.85 * s.pitcherFill;
        _frustum(canvas, cam, xf, 0.1, 1.13, top, (1.2 + 0.1 * top) * 0.94, _water,
            opacity: 0.85, capColor: labShade(_water, 0.35));
      } else {
        final clip = _hull([..._ring(cam, xf, 0.1, 1.13), ..._ring(cam, xf, 2.95, 1.42)]);
        final b = clip.getBounds();
        final levelY = b.bottom - b.height * s.pitcherFill * 0.85;
        canvas.save();
        canvas.clipPath(clip);
        canvas.drawRect(
          Rect.fromLTRB(b.left - 2, levelY, b.right + 2, b.bottom + 2),
          Paint()..color = _water.withValues(alpha: 0.85),
        );
        canvas.drawLine(
          Offset(b.left, levelY),
          Offset(b.right, levelY),
          Paint()
            ..strokeWidth = 2
            ..color = labShade(_water, 0.45),
        );
        canvas.restore();
      }
    }
    _glassEdges(canvas, cam, xf, profile, _plastic, light: !isDark);
    if (s.streamOn && s.stream > 0) _paintStream(canvas, cam, xf, k);
    if (fade) canvas.restore();
  }

  /// The water stream from the pitcher lip into the funnel.
  void _paintStream(Canvas canvas, _Cam cam, _Xf xf, double k) {
    final s = scene;
    final lip = xf.w(-1.5, 3.0);
    final surf = 2 + 1.8 * s.topWater * (1 - 0.5 * s.waterLevel);
    final a = cam.p(lip.$1, lip.$2, lip.$3);
    final b = cam.p(-6.5, math.min(surf, lip.$2 - 0.3), 0);
    final e = Offset.lerp(a, b, s.stream)!;
    final ctrl = Offset(a.dx + (e.dx - a.dx) * 0.85, a.dy + (e.dy - a.dy) * 0.12);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, e.dx, e.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.28 * k
        ..strokeCap = StrokeCap.round
        ..color = _water.withValues(alpha: 0.92),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.08 * k
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    if (s.stream > 0.95) {
      // Little splash where the stream lands.
      final w = s.time * 12;
      for (var i = 0; i < 4; i++) {
        final ang = -math.pi / 2 + (i - 1.5) * 0.6;
        final r = (0.25 + 0.15 * math.sin(w + i)) * k;
        canvas.drawCircle(
          e + Offset(math.cos(ang), math.sin(ang)) * r,
          0.06 * k,
          Paint()..color = labShade(_water, 0.4).withValues(alpha: 0.85),
        );
      }
    }
  }

  void _labLabels(Canvas canvas, _Cam cam, double t) {
    if (!showLabels) return;
    final s = scene;
    if (s.lblScissors && s.scissorsVisible) {
      final bob = s.step == 1 && !s.isCut ? math.sin(t * 5) * 0.2 : 0.0;
      _label(canvas, _l('lbl_scissors'), cam.p(s.scissors.x + 0.3, s.scissors.y + bob + 1.6, s.scissors.z), t,
          active: s.step == 1, opacity: s.scissorsAlpha);
    }
    if (s.lblPin && s.pinVisible) {
      final bob = s.step == 2 && !s.isPierced ? math.sin(t * 5) * 0.2 : 0.0;
      _label(canvas, _l('lbl_pin'), cam.p(s.pin.x, s.pin.y + bob + 1.3, s.pin.z), t,
          active: s.step == 2, opacity: s.pinAlpha);
    }
    if (s.lblPitcher && s.pitcherVisible) {
      final bob = s.step == 4 && !s.isPouring ? math.sin(t * 5) * 0.2 : 0.0;
      _label(canvas, _l('lbl_pitcher'), cam.p(s.pitcher.x + 0.2, s.pitcher.y + bob + 4.1, s.pitcher.z), t,
          active: s.step == 4, opacity: s.pitcherAlpha);
    }
    final topY = math.max(s.top.y, s.top.y + 2.9 * math.cos(s.topRot)) + 0.9;
    _label(canvas, _l('lbl_funnel'), cam.p(s.top.x, topY, s.top.z), t, active: s.step == 3);
    _label(canvas, _l('lbl_receiver'), cam.p(-8.4, 2.0, 0), t, anchor: Alignment.centerRight);
  }

  // ===================================================== SCENARIO 2

  void _paintRace(Canvas canvas, Size size, _Cam cam) {
    final s = scene;
    final t = s.time;
    _raceBackground(canvas, size, cam);
    _raceTrack(canvas, cam);
    // Table with the water clock and the stopwatch.
    final kt = cam.k(40, 0, -12);
    labGroundShadow(canvas, cam.p(40, 0, -11), 11 * kt, 2.5 * kt, opacity: 0.35);
    _box(canvas, cam, 40, 2, -12, 10, 4, 5, const Color(0xFF78350F));
    if (s.waterClockVisible) _paintMiniWaterClock(canvas, cam);
    _paintStopwatch(canvas, cam, t);
    final moving = s.raceState == 'fast' || s.raceState == 'slow';
    _paintRunner(canvas, cam, s.r1x, -2, _Colors.blue, t, moving && s.r1x < 40);
    _paintRunner(canvas, cam, s.r2x, 2, _Colors.red, t, moving && s.r2x < 40);
    if (showLabels) {
      _label(canvas, _l('lbl_runner_1'), cam.p(s.r1x, 5.9, -2), t, background: const Color(0xE61D4ED8));
      _label(canvas, _l('lbl_runner_2'), cam.p(s.r2x, 4.7, 2), t, background: const Color(0xE6B91C1C));
      if (s.step == 3 && !s.stopwatchPicked) {
        final bob = math.sin(t * 5) * 0.2;
        _label(canvas, _l('lbl_stopwatch'), cam.p(s.stopwatch.x, s.stopwatch.y + bob + 3.9, s.stopwatch.z), t,
            active: true);
      }
    }
  }

  static final List<List<(double, Color)>> _crowd = () {
    final rnd = math.Random(7);
    const colors = [
      Color(0xFFF87171), Color(0xFF60A5FA), Color(0xFFFBBF24), Color(0xFF34D399), //
      Color(0xFFA78BFA), Color(0xFFF472B6), Color(0xFFE2E8F0), Color(0xFFFB923C),
    ];
    return [
      for (var row = 0; row < 8; row++)
        [
          for (var x = -130.0; x <= 130; x += 2.6)
            if (rnd.nextDouble() > 0.12) (x + rnd.nextDouble() * 1.2, colors[rnd.nextInt(colors.length)]),
        ],
    ];
  }();

  void _raceBackground(Canvas canvas, Size size, _Cam cam) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF020617), Color(0xFF1E3A5F)]
              : const [Color(0xFF38BDF8), Color(0xFFE0F2FE)],
        ).createShader(Rect.fromLTRB(0, -150, 10, 300)),
    );
    // Grass.
    final ground = cam.poly(const [(-500, 0, -500), (500, 0, -500), (500, 0, 200), (-500, 0, 200)]);
    if (ground != null) {
      canvas.drawPath(
        ground,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF14532D), Color(0xFF166534)]
                : const [Color(0xFF4ADE80), Color(0xFF22C55E)],
          ).createShader(Rect.fromLTRB(0, 100, 10, 560)),
      );
    }
    // Mowing stripes.
    final stripe = Paint()..color = (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.12 : 0.1);
    for (var x = -200.0; x < 200; x += 16) {
      final q = cam.poly([(x, 0.001, -19), (x + 8, 0.001, -19), (x + 8, 0.001, 200), (x, 0.001, 200)]);
      if (q != null) canvas.drawPath(q, stripe);
    }
    // Grandstand: eight tiers, drawn back to front, with the crowd.
    final riser = isDark ? const Color(0xFF1E293B) : const Color(0xFF94A3B8);
    final seat = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    for (var i = 7; i >= 0; i--) {
      final z0 = -24.0 - 4 * i, y0 = 2.5 * i, y1 = 2.5 * (i + 1);
      final r = cam.poly([(-140, y0, z0), (140, y0, z0), (140, y1, z0), (-140, y1, z0)]);
      final st = cam.poly([(-140, y1, z0), (140, y1, z0), (140, y1, z0 - 4), (-140, y1, z0 - 4)]);
      if (st != null) canvas.drawPath(st, Paint()..color = seat);
      for (final (x, color) in _crowd[i]) {
        final c = cam.p(x, y1 + 0.6, z0 - 1.6);
        if (c.dx < -60 || c.dx > 1060 || c.dy < -80 || c.dy > 640) continue;
        final k = cam.k(x, y1, z0);
        canvas.drawCircle(c, 0.62 * k, Paint()..color = isDark ? labShade(color, -0.35) : color);
        canvas.drawCircle(c.translate(0, -0.75 * k), 0.36 * k, Paint()..color = const Color(0xFFD6A77A));
      }
      if (r != null) canvas.drawPath(r, Paint()..color = riser);
    }
    // Advertising boards in front of the stand.
    const boards = [Color(0xFF1D4ED8), Color(0xFFEAB308), Color(0xFF0F766E), Color(0xFFDC2626)];
    for (var i = 0; i < 22; i++) {
      final x0 = -132.0 + i * 12;
      final b = cam.poly([(x0, 0, -20), (x0 + 12, 0, -20), (x0 + 12, 1.6, -20), (x0, 1.6, -20)]);
      if (b != null) canvas.drawPath(b, Paint()..color = boards[i % boards.length]);
    }
    final trim = cam.poly(const [(-132, 1.6, -20), (132, 1.6, -20), (132, 1.85, -20), (-132, 1.85, -20)]);
    if (trim != null) canvas.drawPath(trim, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  /// HTML `createRaceEnvironment()`: red track, white lane lines and the
  /// finish line at x = 40.
  void _raceTrack(Canvas canvas, _Cam cam) {
    final track = cam.poly(const [(-50, 0, -10), (50, 0, -10), (50, 0, 10), (-50, 0, 10)]);
    if (track != null) canvas.drawPath(track, Paint()..color = const Color(0xFF991B1B));
    final line = Paint()..color = Colors.white.withValues(alpha: 0.95);
    for (var i = -2; i <= 2; i++) {
      final z = i * 4.0;
      final l = cam.poly([(-50, 0.01, z - 0.1), (50, 0.01, z - 0.1), (50, 0.01, z + 0.1), (-50, 0.01, z + 0.1)]);
      if (l != null) canvas.drawPath(l, line);
    }
    // Chequered finish line (1 × 20).
    for (var col = 0; col < 2; col++) {
      for (var row = 0; row < 20; row++) {
        final x0 = 39.5 + col * 0.5, z0 = -10.0 + row;
        final q = cam.poly([(x0, 0.02, z0), (x0 + 0.5, 0.02, z0), (x0 + 0.5, 0.02, z0 + 1), (x0, 0.02, z0 + 1)]);
        if (q != null) {
          canvas.drawPath(q, Paint()..color = (col + row).isEven ? Colors.white : const Color(0xFF111827));
        }
      }
    }
  }

  /// Miniature water clock on the table (cylinder + inverted cone).
  void _paintMiniWaterClock(Canvas canvas, _Cam cam) {
    const xf = _Xf(40, 4, -12);
    const body = [(0.0, 1.0), (2.0, 1.0)];
    const cone = [(2.0, 0.03), (4.0, 1.0)];
    _glassFill(canvas, cam, xf, body, _plastic, light: !isDark);
    _frustum(canvas, cam, xf, 0.05, 0.9, 1.0, 0.9, _water, opacity: 0.88, capColor: labShade(_water, 0.35));
    _glassEdges(canvas, cam, xf, body, _plastic, light: !isDark);
    _glassFill(canvas, cam, xf, cone, _plastic, light: !isDark);
    _glassEdges(canvas, cam, xf, cone, _plastic, light: !isDark);
  }

  /// Digital stopwatch model: slate body, two push buttons, dark face.
  void _paintStopwatch(Canvas canvas, _Cam cam, double t) {
    final s = scene;
    final idle = s.step == 3 && !s.stopwatchPicked;
    final bob = idle ? math.sin(t * 5) * 0.2 : 0.0;
    final x = s.stopwatch.x, y = s.stopwatch.y + bob + 1.5, z = s.stopwatch.z;
    final c = cam.p(x, y, z);
    final k = cam.k(x, y, z);
    if (idle) _hint(canvas, c, 3.6 * k, t);
    labGroundShadow(canvas, cam.p(x, 4.02, z + 0.4), 2.6 * k, 0.6 * k, opacity: 0.35);
    // Push buttons at (±1.2, +1.0), tilted 45°.
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(c.dx + side * 1.2 * k, c.dy - 1.0 * k);
      canvas.rotate(side * math.pi / 4);
      final r = Rect.fromCenter(center: Offset.zero, width: 0.6 * k, height: 0.5 * k);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(0.12 * k)),
        Paint()
          ..shader = const LinearGradient(colors: [Color(0xFFCBD5E1), Color(0xFF64748B)]).createShader(r),
      );
      canvas.restore();
    }
    // Body (slightly offset darker disc gives it thickness).
    canvas.drawCircle(c.translate(0.12 * k, 0.14 * k), 1.5 * k, Paint()..color = const Color(0xFF1E293B));
    final body = Rect.fromCircle(center: c, radius: 1.5 * k);
    canvas.drawCircle(
      c,
      1.5 * k,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [Color(0xFF64748B), Color(0xFF334155), Color(0xFF1E293B)],
          stops: [0, 0.55, 1],
        ).createShader(body),
    );
    canvas.drawCircle(c, 1.3 * k, Paint()..color = const Color(0xFF0F172A));
    final tick = Paint()
      ..strokeWidth = math.max(1, 0.05 * k)
      ..color = _Colors.slate500;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final u = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + u * 1.12 * k, c + u * 1.24 * k, tick);
    }
    if (k > 11) {
      labText(
        canvas,
        s.swDisplay,
        c,
        size: 0.58 * k,
        color: const Color(0xFF4ADE80),
        weight: FontWeight.w800,
      );
    }
  }

  /// A sprinter (side view, running towards +x) standing in for the HTML
  /// blue / red runner cylinders.
  void _paintRunner(Canvas canvas, _Cam cam, double x, double z, Color color, double t, bool moving) {
    final foot = cam.p(x, 0, z);
    // Slightly taller than the 4-unit HTML cylinder so the figure reads well.
    final k = cam.k(x, 2, z) * 1.15;
    if (foot.dx < -100 || foot.dx > 1100) return;
    labGroundShadow(canvas, foot.translate(0, 0.1 * k), 2.0 * k, 0.5 * k, opacity: 0.4);
    final phase = x * 1.15;
    final lean = moving ? 0.3 : 0.06;
    final bob = moving ? (math.sin(phase * 2)).abs() * 0.12 : math.sin(t * 2.4 + z) * 0.03;
    Offset pt(double ux, double uy) => Offset(foot.dx + ux * k, foot.dy - uy * k);
    final hip = pt(0, 2.05 + bob);
    final up = Offset(math.sin(lean), -math.cos(lean));
    final shoulder = hip + up * (1.35 * k);
    final head = shoulder + up * (0.62 * k);
    const skin = Color(0xFFC68642);
    final shorts = labShade(color, -0.5);

    void limb(Offset a, Offset b, Offset c, double w, Color col) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = col;
      canvas.drawPath(Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy), p);
    }

    Offset dirOf(double ang) => Offset(math.sin(ang), math.cos(ang));

    void leg(double ph, bool far) {
      final sw = moving ? math.sin(ph) * 0.75 : 0.08 * (far ? -1 : 1);
      final bend = moving ? 0.25 + 0.95 * math.max(0, -math.cos(ph)) : 0.06;
      final knee = hip + dirOf(sw) * (1.0 * k);
      final ft = knee + dirOf(sw - bend) * (1.0 * k);
      final col = far ? labShade(skin, -0.3) : skin;
      limb(hip, knee, ft, 0.3, col);
      // Shorts over the thigh and the shoe at the foot.
      canvas.drawLine(hip, Offset.lerp(hip, knee, 0.45)!, Paint()
        ..strokeWidth = 0.42 * k
        ..strokeCap = StrokeCap.round
        ..color = far ? labShade(shorts, -0.2) : shorts);
      canvas.drawLine(ft, ft + Offset(0.32 * k, 0.02 * k), Paint()
        ..strokeWidth = 0.22 * k
        ..strokeCap = StrokeCap.round
        ..color = far ? const Color(0xFFCBD5E1) : Colors.white);
    }

    void arm(double ph, bool far) {
      final sw = moving ? -math.sin(ph) * 0.8 : 0.1;
      final elbow = shoulder + dirOf(sw) * (0.72 * k);
      final hand = elbow + dirOf(sw + (moving ? 1.5 : 0.3)) * (0.6 * k);
      limb(shoulder, elbow, hand, 0.22, far ? labShade(skin, -0.3) : skin);
    }

    leg(phase + math.pi, true);
    arm(phase + math.pi, true);
    // Torso (jersey).
    canvas.drawLine(hip, shoulder, Paint()
      ..strokeWidth = 0.66 * k
      ..strokeCap = StrokeCap.round
      ..color = color);
    canvas.drawLine(Offset.lerp(hip, shoulder, 0.15)!, Offset.lerp(hip, shoulder, 0.85)!, Paint()
      ..strokeWidth = 0.16 * k
      ..strokeCap = StrokeCap.round
      ..color = labShade(color, 0.35));
    // Head with hair.
    canvas.drawCircle(head, 0.38 * k, Paint()..color = skin);
    canvas.drawArc(Rect.fromCircle(center: head, radius: 0.4 * k), math.pi * 0.95 + lean, math.pi * 1.05, true,
        Paint()..color = const Color(0xFF1F2937));
    leg(phase, false);
    arm(phase, false);
  }

  @override
  bool shouldRepaint(covariant _TimePainter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
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
