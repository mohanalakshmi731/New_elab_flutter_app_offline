// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode, mapEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 8 • Activity 1
/// Investigating Ancient Timekeeping Devices.
///
/// Native Flutter port of `Cl7S-Ch8-A1-Investigating_Ancient_Timekeeping_Devices.html`.
/// Scenario 1: a Samrat Yantra style sundial. The Time of Day slider moves
/// the sun across the sky and the gnomon's shadow across the hour scale;
/// "Cloudy Day" hides the sun and the shadow (the dial shows ??:??).
/// Scenario 2: build an outflow water clock (cut the bottle, pierce the
/// cap, invert the funnel into the receiver, pour water) and calibrate it
/// with a stopwatch, marking the water level every minute.
class Ch8A1InvestigatingAncientTimekeepingDevicesPage extends StatefulWidget {
  const Ch8A1InvestigatingAncientTimekeepingDevicesPage({super.key});

  @override
  State<Ch8A1InvestigatingAncientTimekeepingDevicesPage> createState() =>
      _Ch8A1InvestigatingAncientTimekeepingDevicesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, splash 1311, switchTap
/// 2585, whoosh 1492.
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
  drop('drop.mp3'),
  pickup('pickup.mp3'),
  splash('splash.mp3'),
  switchTap('switch.mp3'),
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

/// Pan recognizer that only claims touches starting on a scene item, so
/// drags on empty canvas still pan the (unlocked) zoomable canvas.
class _A1ItemPanRecognizer extends PanGestureRecognizer {
  _A1ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

// ============================================================== MODEL

const Size _design = Size(1000, 560);

// Water clock geometry in Three.js world units (bottle radius 2 like the
// HTML; the cut line is a little higher so the inverted funnel's cap sits
// well above the bottom of the receiver).
const double _bottleR = 2.0;
const double _cutY = 5.2; // dotted cut line = height of the receiver
const double _coneH = 1.5; // shoulder of the top half
const double _neckH = 0.5;
const double _neckR = 0.5;
const double _capH = 0.3;
const double _capR = 0.55;
const double _neckTop = _coneH + _neckH; // in funnel-local units
const double _maxLevel = 4.6; // receiver water stops rising here
const double _fillRate = 0.08; // receiver rise in units per real second
const double _dropSpeed = 6; // HTML: 0.1 per frame at 60 fps
const double _simSpeed = 6; // stopwatch seconds per real second (HTML: +1 per frame / 10)

// Original inventory positions (HTML `userData.originalPos`).
const (double, double) _toolHome = (-6, 4);
const (double, double) _pinHome = (8, 3);
const (double, double) _capHome = (6, 3);
const (double, double) _funnelHome = (-4, 0);
const (double, double) _pitcherHome = (-6, -4);

/// Water surface inside the inverted funnel, in funnel-local units
/// measured from the rim, for a fill of [f] (0..1).
double _funnelSurface(double f) => 0.12 + (_coneH - 0.2) * (1 - f.clamp(0.0, 1.0));

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

enum _Item { tool, pin, cap, funnel, pitcher }

/// A falling drop (HTML drip particle) released at [t0] from height [y0].
class _Drop {
  _Drop(this.t0, this.y0);
  final double t0, y0;
}

/// One cloud (HTML `createCloud()` group) at a random sky position.
class _Cloud {
  _Cloud(this.x, this.y, this.z);
  final double x, y, z;
}

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  // ---------------------------------------------------- Scenario 1: sundial
  double sunTime = 6; // slider value, 6..18 h
  bool cloudy = false;
  double cloudFade = 0; // 0 = clear sky, 1 = overcast (1 s transition)
  double cloudDrift = 0; // clouds.position.x (drifts while cloudy)
  final List<_Cloud> clouds = [];

  /// Sun position (HTML `updateSunTime`): 6 AM east (+x), noon overhead,
  /// 6 PM west (-x), always 10 units towards the viewer.
  (double, double, double) get sunPos {
    final a = math.pi - ((sunTime - 6) / 12) * math.pi;
    return (-math.cos(a) * 25, math.max(math.sin(a) * 25, 0.1), 10);
  }

  // ------------------------------------------------ Scenario 2: water clock
  bool bottleVisible = true;
  bool toolVisible = true;
  final _V3 tool = _V3(_toolHome.$1, 0, _toolHome.$2);
  bool halvesVisible = false;
  final _V3 top = _V3(0, _cutY, 0); // funnel pivot = centre of its wide rim
  double topRot = 0; // rotation about z (π = inverted)
  final _V3 bottom = _V3(0, 0, 0); // receiver base centre
  bool assembled = false;

  // Cap: on the bottle neck, then on the table, then attached to the funnel.
  bool capOnBottle = true;
  bool capAttached = false;
  double capAttach = 0; // 0..1 hop from the table onto the funnel neck
  final _V3 cap = _V3(0, _cutY + _neckTop, 0); // base centre while free
  final _V3 capFrom = _V3(0, 0, 0);
  bool hasHole = false;

  bool pinVisible = false;
  final _V3 pin = _V3(_pinHome.$1, 0, _pinHome.$2);

  bool pitcherVisible = false;
  final _V3 pitcher = _V3(_pitcherHome.$1, 0, _pitcherHome.$2);
  double pitcherRot = 0;
  double pitcherAlpha = 1;
  double pitcherFill = 1; // 1 = HTML pWater (2.5 of 3 units)
  bool pouring = false;
  double pourStream = 0; // 0..1 length of the pour stream

  bool funnelWaterVisible = false;
  double funnelWater = 0; // HTML funnelWater.scale.y (0.1..1)
  bool dripping = false;
  bool receiverWaterVisible = false;
  double level = 0; // receiver water height (units)
  final List<_Drop> drops = [];
  double nextDrop = 0;

  bool stopwatchVisible = false;
  bool calibrating = false;
  double calibStart = 0;
  int simSecs = 0;
  final List<double> marks = []; // water levels marked every minute

  // HTML `.item-label` visibility.
  bool lblBottle = true, lblTool = true, lblPin = false, lblCap = false;
  bool lblFunnel = false, lblBeaker = false, lblPitcher = false;

  _Item? dragging; // item being dragged (shows the DROP HERE zone)

  /// Transform of the top half (funnel).
  _Xf get topXf => _Xf(top.x, top.y, top.z, topRot);

  /// World position of the cap's base and its rotation (follows the
  /// funnel once attached).
  (double, double, double, double) get capPose {
    if (capOnBottle || !capAttached) return (cap.x, cap.y, cap.z, 0);
    final neck = topXf.w(0, _neckTop);
    final t = capAttach;
    if (t >= 1) return (neck.$1, neck.$2, neck.$3, topRot);
    return (
      capFrom.x + (neck.$1 - capFrom.x) * t,
      capFrom.y + (neck.$2 - capFrom.y) * t + math.sin(t * math.pi) * 1.5,
      capFrom.z + (neck.$3 - capFrom.z) * t,
      topRot * t,
    );
  }

  /// Height of the receiver water surface above the table.
  double get waterSurface => 0.05 + level;

  /// Height of the drip hole (bottom of the inverted cap).
  double get holeY => topXf.w(0, _neckTop + _capH).$2;
}

/// A TWEEN.js style tween driven by the scene ticker.
class _Tw {
  _Tw({required this.duration, required this.update, this.delay = 0, this.curve = Curves.linear, this.done});

  final double duration; // seconds
  final double delay; // seconds
  final Curve curve;
  final void Function(double t) update;
  final VoidCallback? done;
  double? start;
}

class _Ch8A1InvestigatingAncientTimekeepingDevicesPageState
    extends State<Ch8A1InvestigatingAncientTimekeepingDevicesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();
  final List<_Tw> _tweens = [];
  late final Ticker _ticker;
  _Scene _s = _Scene();

  /// True while a drop's animation runs (blocks a second drop in the same
  /// step, which would skip a step in the HTML).
  bool _busy = false;
  bool _concluded = false;
  bool _cloudTimer = false; // "Cloudy Day" already scheduled advanceStep
  (double, double) _grabOff = (0, 0);

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_s.scenario];

  /// Letter spacing for Latin text only (it breaks Devanagari clusters).
  double _ls(double v) => _lab.lang == LabLang.en ? v : 0;

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

  /// HTML `animate()` + `updateLogic()`, time based instead of per frame.
  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final s = _s;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    _runTweens(now);

    if (s.scenario == 0) {
      // Sky / light transition (CSS `transition: all 1s`).
      final target = s.cloudy ? 1.0 : 0.0;
      if (s.cloudFade != target) {
        s.cloudFade = target > s.cloudFade
            ? math.min(target, s.cloudFade + dt)
            : math.max(target, s.cloudFade - dt);
      }
      // clouds.position.x += 0.01 per frame while visible.
      if (s.cloudy || s.cloudFade > 0) s.cloudDrift += 0.6 * dt;
    } else {
      _tickWaterClock(now, dt);
    }
    _frame.value = now;
  }

  void _tickWaterClock(double now, double dt) {
    final s = _s;
    if (s.dripping) {
      // Funnel water shrinks while the receiver water grows.
      s.level = math.min(_maxLevel, s.level + _fillRate * dt);
      s.funnelWater = 1 - 0.9 * (s.level / _maxLevel).clamp(0.0, 1.0);
      if (s.level >= _maxLevel) s.dripping = false;
      // Dripping particles (HTML: Math.random() > 0.8 per frame ≈ 12/s).
      if (now - s.nextDrop > 1) s.nextDrop = now;
      while (now >= s.nextDrop) {
        s.drops.add(_Drop(s.nextDrop, s.holeY));
        s.nextDrop += 0.03 + _rng.nextDouble() * 0.11;
      }
    }
    final surface = s.waterSurface;
    s.drops.removeWhere((d) => d.y0 - _dropSpeed * (now - d.t0) < surface || now - d.t0 > 2);

    if (s.calibrating) {
      final secs = math.min(180, ((now - s.calibStart) * _simSpeed).floor());
      if (secs != s.simSecs) {
        s.simSecs = secs;
        // Add a mark every 60 simulated seconds.
        while (s.marks.length < secs ~/ 60) {
          s.marks.add(s.level);
          _Audio.play(_Sound.switchTap);
        }
        // Stop after 3 marks, then finish the scenario.
        if (s.marks.length >= 3) {
          s.calibrating = false;
          _lab.after(const Duration(milliseconds: 1000), () {
            if (!mounted || !identical(s, _s)) return;
            _advanceStep();
          });
        }
      }
    }
  }

  void _runTweens(double now) {
    if (_tweens.isEmpty) return;
    for (final tw in List<_Tw>.of(_tweens)) {
      if (!_tweens.contains(tw)) continue;
      final start = tw.start ??= now + tw.delay;
      if (now < start) continue;
      final p = tw.duration <= 0 ? 1.0 : ((now - start) / tw.duration).clamp(0.0, 1.0);
      tw.update(tw.curve.transform(p));
      if (p >= 1) {
        _tweens.remove(tw);
        tw.done?.call();
      }
    }
  }

  /// `new TWEEN.Tween(v).to({x, y, z}, ms)`; [lift] adds a hop arc.
  void _tweenV3(
    _V3 v, {
    double? x,
    double? y,
    double? z,
    required int ms,
    Curve curve = Curves.linear,
    double lift = 0,
    VoidCallback? done,
  }) {
    double? x0, y0, z0;
    _tweens.add(_Tw(
      duration: ms / 1000,
      curve: curve,
      update: (t) {
        x0 ??= v.x;
        y0 ??= v.y;
        z0 ??= v.z;
        if (x != null) v.x = x0! + (x - x0!) * t;
        if (y != null) v.y = y0! + (y - y0!) * t + lift * math.sin(t * math.pi);
        if (z != null) v.z = z0! + (z - z0!) * t;
      },
      done: done,
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
    double? from;
    _tweens.add(_Tw(
      duration: ms / 1000,
      delay: delay / 1000,
      curve: curve,
      update: (t) {
        from ??= get();
        set(from! + (to - from!) * t);
      },
      done: done,
    ));
  }

  // ------------------------------------------------------------ logic

  /// HTML `buildScenario()` (+ `clearScene()`): fresh objects and overlays.
  void _buildScenario() {
    _lab.cancelPending();
    _tweens.clear();
    final old = _s;
    _s = _Scene()
      ..scenario = old.scenario
      ..step = old.step
      ..time = old.time;
    // Three clouds at random sky positions (hidden until "Cloudy Day").
    for (var i = 0; i < 3; i++) {
      _s.clouds.add(_Cloud(
        (_rng.nextDouble() - 0.5) * 10,
        15 + _rng.nextDouble() * 2,
        (_rng.nextDouble() - 0.5) * 5 - 5,
      ));
    }
    _busy = false;
    _concluded = false;
    _cloudTimer = false;
  }

  /// HTML `changeScenario()` → `resetApp(true)`.
  void _changeScenario(int index) {
    setState(() {
      _s.scenario = index;
      _s.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  /// HTML `resetApp(false)` (after the shell restored its own state).
  void _fullReset() {
    setState(() {
      _s.scenario = 0;
      _s.step = 1;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    if (!mounted) return;
    final n = _data.steps.length;
    setState(() {
      _busy = false;
      if (_s.step < n) {
        _s.step++;
        // Reaching the sundial's last step ("Reflect…") ends the scenario.
        // The water clock ends once the third minute has been marked.
        if (_s.step == n && _s.scenario == 0) _showConclusion();
      } else {
        _showConclusion();
      }
    });
  }

  void _showConclusion() {
    if (_concluded) return;
    _concluded = true;
    _lab.showScenarioConclusion(
      scenarioIndex: _s.scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_s.scenario + 1}'),
      delay: const Duration(milliseconds: 1000),
    );
  }

  // ------------------------------------------------- scenario 1: sundial

  /// HTML `updateSunTime()`: moves the sun / shadow and advances the steps.
  void _onSunTime(double v) {
    setState(() => _s.sunTime = v);
    if (_s.cloudy) return; // the dial shows ??:??
    if (_s.step == 1 && v > 10) {
      _advanceStep();
    } else if (_s.step == 2 && v > 15) {
      _advanceStep();
    }
  }

  /// Digital clock text (`h:mm AM`), or `??:??` under clouds.
  String _clockText() {
    if (_s.cloudy) return '??:??';
    final tenths = (_s.sunTime * 10).round();
    final hours = tenths ~/ 10;
    final mins = (tenths % 10) * 6;
    final ampm = hours >= 12 ? _t('pm') : _t('am');
    final dh = hours % 12 == 0 ? 12 : hours % 12;
    return '$dh:${mins.toString().padLeft(2, '0')} $ampm';
  }

  /// HTML `triggerMainAction()` in scenario 1: Cloudy Day / Sunny Day.
  void _toggleCloudy() {
    if (_s.scenario != 0 || _s.step != 3) return;
    setState(() => _s.cloudy = !_s.cloudy);
    if (_s.cloudy && !_cloudTimer) {
      _cloudTimer = true;
      final s = _s;
      _lab.after(const Duration(milliseconds: 2000), () {
        if (!mounted || !identical(s, _s) || s.step != 3) return;
        _advanceStep();
      });
    }
  }

  // --------------------------------------------- scenario 2: water clock

  _Cam get _cam => _cameraFor(_s.scenario);

  bool _isVisibleItem(_Item it) {
    final s = _s;
    return switch (it) {
      _Item.tool => s.toolVisible,
      _Item.pin => s.pinVisible,
      _Item.cap => !s.capOnBottle && !s.capAttached,
      _Item.funnel => s.halvesVisible,
      _Item.pitcher => s.pitcherVisible && !s.pouring,
    };
  }

  /// HTML pointerdown validation: which item may be dragged in this step.
  bool _isValidItem(_Item it) {
    final step = _s.step;
    return (step == 1 && it == _Item.tool) ||
        (step == 2 && it == _Item.pin) ||
        (step == 3 && it == _Item.funnel) ||
        (step == 4 && it == _Item.pitcher);
  }

  /// World centre and grab radius of an item (the HTML invisible hitboxes).
  (double, double, double, double) _itemHitSphere(_Item it) {
    final s = _s;
    return switch (it) {
      _Item.tool => (s.tool.x + 1.06, s.tool.y + 1.06, s.tool.z, 1.9),
      _Item.pin => (s.pin.x, s.pin.y + 0.35, s.pin.z, 1.2),
      _Item.cap => (s.cap.x, s.cap.y + 0.15, s.cap.z, 1.3),
      _Item.funnel => () {
          final c = s.topXf.w(0, 1.1);
          return (c.$1, c.$2, c.$3, 2.4);
        }(),
      _Item.pitcher => (s.pitcher.x, s.pitcher.y + 1.5, s.pitcher.z, 2.3),
    };
  }

  /// Raycaster equivalent: the visible item under [p] (design coords),
  /// preferring the item that is valid for the current step.
  _Item? _hitItem(Offset p) {
    if (_s.scenario != 1) return null;
    final cam = _cam;
    _Item? best;
    var bestD = double.infinity;
    for (final it in _Item.values) {
      if (!_isVisibleItem(it)) continue;
      final (x, y, z, r) = _itemHitSphere(it);
      final c = cam.p(x, y, z);
      final rad = math.max(r * cam.k(x, y, z), 30.0);
      final d = (p - c).distance;
      if (d > rad) continue;
      if (_isValidItem(it)) return it;
      if (d < bestD) {
        bestD = d;
        best = it;
      }
    }
    return best;
  }

  _V3 _itemPos(_Item it) => switch (it) {
        _Item.tool => _s.tool,
        _Item.pin => _s.pin,
        _Item.cap => _s.cap,
        _Item.funnel => _s.top,
        _Item.pitcher => _s.pitcher,
      };

  (double, double) _homeOf(_Item it) => switch (it) {
        _Item.tool => _toolHome,
        _Item.pin => _pinHome,
        _Item.cap => _capHome,
        _Item.funnel => _funnelHome,
        _Item.pitcher => _pitcherHome,
      };

  void _wrongItem() {
    _lab.showToast(_t('msg_wrong_item'), isError: true);
  }

  bool _acceptsDrag(Offset p) => _lab.isLabActive && !_concluded && _hitItem(p) != null;

  /// A click is a pointerdown + pointerup without moving; the item is still
  /// inside the (very forgiving) drop range, so it drops in place.
  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive || _s.scenario != 1) return;
    final it = _hitItem(d.localPosition);
    if (it == null) return;
    if (!_isValidItem(it)) {
      _wrongItem();
      return;
    }
    if (_busy) return;
    _Audio.play(_Sound.pickup);
    _release(it);
  }

  void _grab(Offset p) {
    final it = _hitItem(p);
    if (it == null) return;
    if (!_isValidItem(it)) {
      _wrongItem();
      return;
    }
    if (_busy) return;
    final pos = _itemPos(it);
    final w = _cam.unproject(p, pos.y);
    _grabOff = w == null ? (0, 0) : (pos.x - w.$1, pos.z - w.$2);
    _Audio.play(_Sound.pickup);
    setState(() => _s.dragging = it);
  }

  void _dragTo(Offset p) {
    final it = _s.dragging;
    if (it == null) return;
    final pos = _itemPos(it);
    final w = _cam.unproject(p, pos.y);
    if (w == null) return;
    pos.x = (w.$1 + _grabOff.$1).clamp(-16.0, 16.0);
    pos.z = (w.$2 + _grabOff.$2).clamp(-12.0, 9.0);
  }

  void _endDrag() {
    final it = _s.dragging;
    if (it == null) return;
    setState(() => _s.dragging = null);
    _release(it);
  }

  /// HTML pointerup: drop-target check with the same forgiving distances.
  void _release(_Item it) {
    final s = _s;
    final pos = _itemPos(it);
    final dist = math.sqrt(pos.x * pos.x + pos.z * pos.z);
    var hit = false;
    if (s.step == 1 && it == _Item.tool && dist < 14) hit = true;
    if (s.step == 2 && it == _Item.pin) {
      final dx = pos.x - s.cap.x, dy = pos.y - s.cap.y, dz = pos.z - s.cap.z;
      if (math.sqrt(dx * dx + dy * dy + dz * dz) < 12) hit = true;
    }
    if (s.step == 3 && it == _Item.funnel && dist < 14) hit = true;
    if (s.step == 4 && it == _Item.pitcher && dist < 14) hit = true;
    if (hit) {
      _executeDrop(it);
    } else {
      _Audio.play(_Sound.wrong);
      final home = _homeOf(it);
      _tweenV3(pos, x: home.$1, z: home.$2, ms: 400, curve: Curves.easeOutQuad);
    }
  }

  /// HTML `executeDrop()`.
  void _executeDrop(_Item it) {
    final s = _s;
    _busy = true;
    switch (it) {
      case _Item.tool:
        _cutBottle(s);
      case _Item.pin:
        _pierceCap(s);
      case _Item.funnel:
        _assemble(s);
      case _Item.pitcher:
        _pour(s);
      case _Item.cap:
        break;
    }
    setState(() {});
  }

  /// Step 1: the bottle is cut into the funnel (left) and receiver (right);
  /// its cap pops off onto the table and the drawing pin appears.
  void _cutBottle(_Scene s) {
    _Audio.play(_Sound.whoosh); // HTML 'cut'
    s
      ..toolVisible = false
      ..lblTool = false
      ..bottleVisible = false
      ..lblBottle = false
      ..halvesVisible = true
      ..capOnBottle = false;
    s.top.setAll(0, _cutY, 0);
    s.bottom.setAll(0, 0, 0);
    _tweenV3(s.top, x: _funnelHome.$1, y: 0, z: _funnelHome.$2, ms: 1000, curve: Curves.easeOutCubic, lift: 1.2);
    _tweenV3(s.bottom, x: 4, y: 0, z: 0, ms: 1000, curve: Curves.easeOutCubic);
    _tweenV3(s.cap, x: _capHome.$1, y: 0, z: _capHome.$2, ms: 1000, curve: Curves.easeOutCubic, lift: 2.5);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted || !identical(s, _s)) return;
      s
        ..pinVisible = true
        ..lblCap = true
        ..lblPin = true
        ..lblFunnel = true
        ..lblBeaker = true;
      _advanceStep();
    });
  }

  /// Step 2: the pin pierces the cap; the cap then goes onto the funnel neck.
  void _pierceCap(_Scene s) {
    _Audio.play(_Sound.drop); // HTML 'snap'
    _tweenV3(s.pin, x: s.cap.x, y: 0.32, z: s.cap.z, ms: 300, done: () {
      s.hasHole = true;
      _lab.after(const Duration(milliseconds: 500), () {
        if (!mounted || !identical(s, _s)) return;
        s
          ..pinVisible = false
          ..lblPin = false
          ..capAttached = true
          ..capAttach = 0;
        s.capFrom.setAll(s.cap.x, s.cap.y, s.cap.z);
        _tweenNum(() => s.capAttach, (v) => s.capAttach = v, 1, ms: 450, curve: Curves.easeInOutQuad);
        _advanceStep();
      });
    });
  }

  /// Step 3: the funnel is turned over and dropped into the receiver.
  void _assemble(_Scene s) {
    _Audio.play(_Sound.drop); // HTML 'snap'
    s
      ..lblCap = false
      ..assembled = true;
    _tweenNum(() => s.topRot, (v) => s.topRot = v, math.pi, ms: 800, curve: Curves.easeInOutQuad);
    _tweenV3(s.top, x: 0, y: _cutY, z: 0, ms: 800, curve: Curves.easeInOutQuad, lift: 2.5);
    _tweenV3(s.bottom, x: 0, y: 0, z: 0, ms: 800, curve: Curves.easeInOutQuad);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted || !identical(s, _s)) return;
      s
        ..pitcherVisible = true
        ..lblPitcher = true;
      _advanceStep();
    });
  }

  /// Step 4: the pitcher pours coloured water into the funnel; 2.5 s later
  /// the water starts dripping into the receiver.
  void _pour(_Scene s) {
    _Audio.play(_Sound.splash); // HTML 'water'
    s
      ..lblPitcher = false
      ..pouring = true
      ..funnelWaterVisible = true
      ..funnelWater = 0.1;
    _tweenV3(s.pitcher, x: -3.2, y: 6.3, z: 0, ms: 300, curve: Curves.easeOutCubic);
    _tweenNum(() => s.pitcherRot, (v) => s.pitcherRot = v, -math.pi / 4, ms: 300, curve: Curves.easeOutCubic,
        done: () {
      _tweenNum(() => s.pourStream, (v) => s.pourStream = v, 1, ms: 200);
    });
    _tweenNum(() => s.funnelWater, (v) => s.funnelWater = v, 1, ms: 2000);
    _tweenNum(() => s.pitcherFill, (v) => s.pitcherFill = v, 0.3, ms: 2000);
    _tweenNum(() => s.pourStream, (v) => s.pourStream = v, 0, ms: 200, delay: 2200);
    _lab.after(const Duration(milliseconds: 2500), () {
      if (!mounted || !identical(s, _s)) return;
      _tweenNum(() => s.pitcherAlpha, (v) => s.pitcherAlpha = v, 0, ms: 250, done: () => s.pitcherVisible = false);
      s
        ..dripping = true
        ..nextDrop = s.time
        ..receiverWaterVisible = true
        ..level = 0;
      _advanceStep();
    });
  }

  /// HTML `triggerMainAction()` in scenario 2: start the calibration timer.
  void _calibrate() {
    final s = _s;
    if (s.scenario != 1 || s.step != 5) return;
    setState(() {
      s
        ..stopwatchVisible = true
        ..calibrating = true
        ..calibStart = s.time
        ..simSecs = 0;
    });
    _advanceStep();
  }

  /// Stopwatch text `mm:ss` (simulated time).
  String _stopwatchText() {
    final secs = _s.simSecs;
    final m = secs ~/ 60, sec = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------ actions

  /// The HTML `#btn-action-main` (Cloudy Day / Sunny Day, Calibrate).
  List<LabAction> _actions() {
    final s = _s;
    if (s.scenario == 0 && s.step == 3) {
      return [
        LabAction(
          label: s.cloudy ? _t('btn_sunny') : _t('btn_cloudy'),
          icon: s.cloudy ? Icons.wb_sunny : Icons.cloud,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _toggleCloudy,
        ),
      ];
    }
    if (s.scenario == 1 && s.step == 5) {
      return [
        LabAction(
          label: _t('btn_calibrate'),
          icon: Icons.timer,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _calibrate,
        ),
      ];
    }
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
          onReset: _fullReset,
          overlays: [
            if (isS1) _sundialPanel(p, s, inset),
            if (!isS1 && _s.stopwatchVisible) _stopwatchPanel(p, s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _A1ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_A1ItemPanRecognizer>(
                  _A1ItemPanRecognizer.new,
                  (r) => r
                    ..accepts = _acceptsDrag
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 6)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _endDrag())
                    ..onCancel = _endDrag,
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _A1Painter(
                  scene: _s,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  latin: _lab.lang == LabLang.en,
                  validItem: _busy || _concluded || _s.scenario != 1 ? null : _Item.values.where(_isValidItem).firstOrNull,
                  labels: {
                    for (final k in const [
                      'lbl_sundial',
                      'lbl_gnomon',
                      'lbl_bottle',
                      'lbl_tool',
                      'lbl_pin',
                      'lbl_cap',
                      'lbl_funnel',
                      'lbl_beaker',
                      'lbl_pitcher',
                      'drop_here',
                    ])
                      k: _t(k),
                    for (var i = 1; i <= 3; i++) 'mark_$i': labFormat(_t('mark_min'), {'n': i}),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#sundial-ui`: sun / digital clock / moon, the Time of Day slider
  /// and its 6:00 AM … 6:00 PM legend (top centre of the canvas).
  Widget _sundialPanel(LabPalette p, double s, EdgeInsets inset) {
    final dark = p.isDark;
    final muted = dark ? _Colors.slate400 : _Colors.slate500;
    final legend = TextStyle(color: muted, fontSize: 10.5 * s, fontWeight: FontWeight.w700);
    return Positioned(
      top: inset.top,
      left: inset.left,
      right: inset.right,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380 * s),
          child: Container(
            padding: EdgeInsets.fromLTRB(12 * s, 7 * s, 12 * s, 6 * s),
            decoration: BoxDecoration(
              color: (dark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: dark ? _Colors.slate600 : _Colors.slate300),
              boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny, color: const Color(0xFFEAB308), size: 20 * s),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 2 * s),
                            decoration: BoxDecoration(
                              color: dark ? _Colors.slate800 : _Colors.slate200,
                              borderRadius: BorderRadius.circular(6 * s),
                            ),
                            child: Text(
                              _clockText(),
                              style: TextStyle(
                                color: dark ? Colors.white : _Colors.slate900,
                                fontSize: 21 * s,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.nightlight_round, color: const Color(0xFF818CF8), size: 20 * s),
                  ],
                ),
                SizedBox(
                  height: 30 * s,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8 * s,
                      trackShape: const _A1GradientTrack(),
                      thumbShape: _A1ThumbShape(11 * s),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * s),
                      overlayColor: _Colors.zslYellow.withValues(alpha: 0.2),
                      tickMarkShape: SliderTickMarkShape.noTickMark,
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: Slider(
                      value: _s.sunTime,
                      min: 6,
                      max: 18,
                      divisions: 120,
                      onChanged: _lab.isLabActive ? _onSunTime : null,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Flexible(child: Text(_t('time_6am'), style: legend, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(
                      child: Text(
                        _t('time_of_day'),
                        textAlign: TextAlign.center,
                        style: legend,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(child: Text(_t('time_6pm'), style: legend, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#stopwatch-ui`: the calibration timer (top right).
  Widget _stopwatchPanel(LabPalette p, double s, EdgeInsets inset) {
    final dark = p.isDark;
    return Positioned(
      top: inset.top + 4 * s,
      right: inset.right + 4,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(scale: 0.8 + 0.2 * v, child: Opacity(opacity: v.clamp(0, 1), child: child)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
            decoration: BoxDecoration(
              color: (dark ? _Colors.slate900 : Colors.white).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16 * s),
              border: Border.all(color: _Colors.zslYellow, width: 3.5 * s),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t('calibration_timer').toUpperCase(),
                  style: TextStyle(
                    color: _Colors.slate500,
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: _ls(1.2),
                  ),
                ),
                SizedBox(height: 2 * s),
                ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, _, _) => Text(
                    _stopwatchText(),
                    style: TextStyle(
                      color: dark ? Colors.white : _Colors.slate900,
                      fontSize: 34 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

/// Slider track with the HTML gradient (#fbbf24 → #f59e0b).
class _A1GradientTrack extends SliderTrackShape with BaseSliderTrackShape {
  const _A1GradientTrack();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(parentBox: parentBox, offset: offset, sliderTheme: sliderTheme);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    context.canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]).createShader(rect),
    );
    context.canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x1A000000),
    );
  }
}

/// Yellow thumb with a white border and a soft shadow (HTML range thumb).
class _A1ThumbShape extends SliderComponentShape {
  const _A1ThumbShape(this.radius);

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center.translate(0, 1.5),
      radius + 1,
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, radius, Paint()..color = _Colors.zslYellow);
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Ancient Timekeeping Devices',
    'app_subtitle': 'Class 7 • Measurement of Time and Motion',
    'scen_1_opt': "Scenario 1: The Sun's Clock (Sundial)",
    'scen_2_opt': 'Scenario 2: The Dripping Clock (Water)',
    'sci_conclusion': 'Success!',
    'drop_here': 'DROP HERE',
    'btn_cloudy': 'Cloudy Day',
    'btn_sunny': 'Sunny Day',
    'btn_calibrate': 'Calibrate',
    'calibration_timer': 'Calibration Timer',
    'time_of_day': 'Time of Day',
    'time_6am': '6:00 AM',
    'time_6pm': '6:00 PM',
    'am': 'AM',
    'pm': 'PM',
    'conclusion_1':
        "The sundial is a powerful tool connecting the sun's movement to simple time measurement. However, its major limitation is that it requires daylight and clear skies to function.",
    'conclusion_2':
        "By using a constant process (dripping water) and marking it with a known time unit (a minute), you created a reliable device to measure time intervals, solving the sundial's nighttime limitation!",
    // Strings that were hard-coded in the HTML (labels, feedback).
    'lbl_sundial': 'Samrat Yantra (Sundial)',
    'lbl_gnomon': 'Gnomon (Shadow Caster)',
    'lbl_bottle': 'Plastic Bottle',
    'lbl_tool': 'Cutting Tool',
    'lbl_pin': 'Drawing Pin',
    'lbl_cap': 'Cap',
    'lbl_funnel': 'Funnel (Top)',
    'lbl_beaker': 'Receiver (Bottom)',
    'lbl_pitcher': 'Water Pitcher',
    'msg_wrong_item': 'Not the right item for this step!',
    'mark_min': '{n} min',
  },
  'hi': {
    'app_title': 'प्राचीन समय मापन उपकरण',
    'app_subtitle': 'कक्षा 7 • समय और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: धूपघड़ी (Sundial)',
    'scen_2_opt': 'परिदृश्य 2: जल घड़ी (Water Clock)',
    'sci_conclusion': 'सफलता!',
    'drop_here': 'यहाँ छोड़ें',
    'btn_cloudy': 'बादल वाला दिन',
    'btn_sunny': 'धूप वाला दिन',
    'btn_calibrate': 'कैलिब्रेट करें',
    'calibration_timer': 'कैलिब्रेशन टाइमर',
    'time_of_day': 'दिन का समय',
    'time_6am': 'सुबह 6:00',
    'time_6pm': 'शाम 6:00',
    'am': 'AM',
    'pm': 'PM',
    'conclusion_1':
        'धूपघड़ी सूर्य की गति को समय से जोड़ती है। हालाँकि, इसकी मुख्य सीमा यह है कि इसे काम करने के लिए दिन के उजाले और साफ आसमान की आवश्यकता होती है।',
    'conclusion_2':
        'एक निरंतर प्रक्रिया (टपकता पानी) का उपयोग करके और इसे चिह्नित करके, आपने समय मापने के लिए एक उपकरण बनाया है!',
    'lbl_sundial': 'सम्राट यंत्र (धूपघड़ी)',
    'lbl_gnomon': 'शंकु (छाया बनाने वाला)',
    'lbl_bottle': 'प्लास्टिक की बोतल',
    'lbl_tool': 'काटने का उपकरण',
    'lbl_pin': 'ड्राइंग पिन',
    'lbl_cap': 'ढक्कन',
    'lbl_funnel': 'फ़नल (ऊपरी भाग)',
    'lbl_beaker': 'पात्र (निचला भाग)',
    'lbl_pitcher': 'पानी का जग',
    'msg_wrong_item': 'इस चरण के लिए यह सही वस्तु नहीं है!',
    'mark_min': '{n} मिनट',
  },
};

// ========================================================== SCENARIOS

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          "To understand how a sundial uses the changing position of the sun's shadow to measure the time of day.",
      steps: [
        LabStep(
          concept: "Sun's Movement",
          action: 'DRAG the Time of Day slider handle from left to right past 10:00 AM.',
          observation: "The glowing sun icon in the sky changes its position, simulating the earth's rotation.",
        ),
        LabStep(
          concept: 'Shadow Casting',
          action:
              "Continue to DRAG the slider past 3:00 PM and observe the long shadow cast by the sundial's gnomon.",
          observation: 'The shadow moves across the curved highlighted scale. The shortest shadow occurs around noon.',
        ),
        LabStep(
          concept: 'Environmental Limitations',
          action: "CLICK the 'Cloudy Day' button above.",
          observation: 'Clouds cover the sun, the shadow disappears entirely, and the sundial stops working (shows ??:??).',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Reflect on the limitations of the sundial.',
          observation: 'It requires direct sunlight and clear skies, making it useless at night or on cloudy days.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To construct a simple water clock (outflow type) and understand how it measures time intervals through calibration.',
      steps: [
        LabStep(
          concept: 'Preparation',
          action: 'DRAG the cutting tool to the dotted line on the plastic bottle.',
          observation: 'The bottle is cut into two halves: a top funnel and a bottom beaker.',
        ),
        LabStep(
          concept: 'Creating the Orifice',
          action: 'DRAG the drawing pin and DROP it onto the center of the bottle cap.',
          observation: 'A small hole is made to allow a slow, steady drip of water.',
        ),
        LabStep(
          concept: 'Assembly',
          action: 'DRAG the top half (funnel) and DROP it inverted into the bottom half.',
          observation: 'The water clock apparatus is assembled securely.',
        ),
        LabStep(
          concept: 'Starting the Flow',
          action: 'DRAG the pitcher of colored water and POUR it into the top funnel.',
          observation: 'Water fills the top and begins to drip steadily into the bottom.',
        ),
        LabStep(
          concept: 'Calibration Process',
          action: "CLICK the 'Calibrate' button to start the stopwatch.",
          observation: 'The timer begins, creating a standard unit of measurement alongside the dripping process.',
        ),
        LabStep(
          concept: 'Marking Intervals',
          action: 'Watch the stopwatch and the bottom container.',
          observation: 'Every minute, a line is automatically marked on the container at the current water level.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'यह समझने के लिए कि धूपघड़ी समय को मापने के लिए सूर्य की छाया की बदलती स्थिति का उपयोग कैसे करती है।',
      steps: [
        LabStep(
          concept: 'सूर्य की गति',
          action: 'समय स्लाइडर को बाएं से दाएं खींचें।',
          observation: 'आकाश में सूर्य की स्थिति बदलती है।',
        ),
        LabStep(
          concept: 'छाया',
          action: 'स्लाइडर को खींचना जारी रखें और छाया का निरीक्षण करें।',
          observation: 'छाया पैमाने पर चलती है। सबसे छोटी छाया दोपहर के आसपास होती है।',
        ),
        LabStep(
          concept: 'पर्यावरणीय सीमाएँ',
          action: "'बादल वाला दिन' बटन पर क्लिक करें।",
          observation: 'बादल सूर्य को ढक लेते हैं, छाया गायब हो जाती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'धूपघड़ी की सीमाओं पर विचार करें।',
          observation: 'इसे सीधे धूप की आवश्यकता होती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'एक साधारण जल घड़ी का निर्माण करना और यह समझना कि यह समय अंतराल को कैसे मापती है।',
      steps: [
        LabStep(
          concept: 'तैयारी',
          action: 'प्लास्टिक की बोतल पर काटने के उपकरण को खींचें।',
          observation: 'बोतल को दो हिस्सों में काटा जाता है।',
        ),
        LabStep(
          concept: 'छेद बनाना',
          action: 'ड्राइंग पिन को बोतल के ढक्कन पर खींचें।',
          observation: 'पानी टपकने के लिए एक छोटा छेद बनाया जाता है।',
        ),
        LabStep(
          concept: 'संयोजन',
          action: 'शीर्ष आधे हिस्से (फ़नल) को खींचें और इसे नीचे के हिस्से में छोड़ दें।',
          observation: 'जल घड़ी उपकरण इकट्ठा किया गया है।',
        ),
        LabStep(
          concept: 'प्रवाह शुरू करना',
          action: 'रंगीन पानी के घड़े को खींचें और शीर्ष फ़नल में डालें।',
          observation: 'पानी ऊपर से भरता है और नीचे टपकने लगता है।',
        ),
        LabStep(
          concept: 'कैलिब्रेशन',
          action: "स्टॉपवॉच शुरू करने के लिए 'कैलिब्रेट करें' पर क्लिक करें।",
          observation: 'टाइमर शुरू होता है।',
        ),
        LabStep(
          concept: 'अंतराल चिह्नित करना',
          action: 'स्टॉपवॉच और निचले कंटेनर को देखें।',
          observation: 'हर मिनट, कंटेनर पर एक रेखा चिह्नित की जाती है।',
        ),
      ],
    ),
  ],
};

// ======================================================== PROJECTION

typedef _P3 = (double, double, double);

/// Perspective "look-at" camera standing in for the HTML PerspectiveCamera
/// (position + controls.target) on the design canvas.
class _Cam {
  _Cam(_P3 pos, _P3 target, this.focal, this.center)
      : px = pos.$1,
        py = pos.$2,
        pz = pos.$3 {
    final fx0 = target.$1 - px, fy0 = target.$2 - py, fz0 = target.$3 - pz;
    final fl = math.sqrt(fx0 * fx0 + fy0 * fy0 + fz0 * fz0);
    fx = fx0 / fl;
    fy = fy0 / fl;
    fz = fz0 / fl;
    // right = forward × up(0, 1, 0); up = right × forward.
    final rl = math.sqrt(fz * fz + fx * fx);
    rx = -fz / rl;
    rz = fx / rl;
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
  Offset p3(_P3 q) => p(q.$1, q.$2, q.$3);

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

  /// Ray from the eye through screen point [s] intersected with the plane
  /// `y = planeY` (the HTML drag plane). Returns world (x, z).
  (double, double)? unproject(Offset s, double planeY) {
    final a = (s.dx - center.dx) / focal, b = -(s.dy - center.dy) / focal;
    final wx = rx * a + ux * b + fx;
    final wy = uy * b + fy;
    final wz = rz * a + uz * b + fz;
    if (wy.abs() < 1e-6) return null;
    final t = (planeY - py) / wy;
    if (t <= 0) return null;
    return (px + wx * t, pz + wz * t);
  }
}

/// Scenario 1 looks down on the sundial from the front (slightly from the
/// left so the gnomon's side shows); scenario 2 is the HTML camera
/// (0, 8, 20) → (0, 3, 0) over the work table.
_Cam _cameraFor(int scenario) => scenario == 0
    ? _Cam((-4, 15, 38), (0, 0, -0.5), 1350, const Offset(500, 400))
    : _Cam((0, 8, 20), (0, 3, 0), 840, const Offset(440, 300));

/// Object transform: position + rotation about the world z axis.
class _Xf {
  const _Xf(this.x, this.y, this.z, [this.rot = 0]);
  final double x, y, z, rot;

  _P3 w(double lx, double ly, [double lz = 0]) {
    final c = math.cos(rot), s = math.sin(rot);
    return (x + lx * c - ly * s, y + lx * s + ly * c, z + lz);
  }

  Offset p(_Cam cam, double lx, double ly, [double lz = 0]) => cam.p3(w(lx, ly, lz));
}

// =========================================================== HELPERS

Color _a(Color c, double opacity) => c.withValues(alpha: (c.a * opacity).clamp(0.0, 1.0));

/// Lambert-ish brightness: ambient 0.4 + directional light (HTML lights).
/// Values above 1 lighten, below 1 darken (with a floor so night is legible).
Color _lit(Color c, double b) {
  final v = b.clamp(0.0, 2.2);
  if (v <= 1) return Color.lerp(Colors.black, c, 0.3 + 0.7 * v)!;
  return labShade(c, (v - 1) * 0.28);
}

List<Offset> _ring(_Cam cam, _Xf xf, double ly, double r, {int n = 36}) {
  return [
    for (var i = 0; i < n; i++) xf.p(cam, r * math.cos(2 * math.pi * i / n), ly, r * math.sin(2 * math.pi * i / n)),
  ];
}

/// Convex hull (monotone chain) as a closed path.
Path _hull(List<Offset> pts) {
  if (pts.length < 3) return Path();
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

/// Opaque cylinder / cone section between local heights y0 (radius r0) and
/// y1 (radius r1), with its upper end cap.
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
    final topRing = xf.w(0, y1).$2 >= xf.w(0, y0).$2 ? b : a;
    canvas.drawPath(Path()..addPolygon(topRing, true), Paint()..color = _a(capColor ?? labShade(color, 0.3), opacity));
  }
}

/// Transparent plastic (HTML MeshPhysicalMaterial 0xdbeafe, opacity 0.8):
/// a tinted body drawn behind the contents.
void _glassFill(Canvas canvas, _Cam cam, _Xf xf, List<(double, double)> profile, {double opacity = 1}) {
  final pts = <Offset>[for (final pr in profile) ..._ring(cam, xf, pr.$1, pr.$2)];
  final hull = _hull(pts);
  final b = hull.getBounds();
  canvas.drawPath(
    hull,
    Paint()
      ..shader = LinearGradient(colors: [
        _a(const Color(0xFFDBEAFE), 0.42 * opacity),
        _a(const Color(0xFFDBEAFE), 0.16 * opacity),
        _a(const Color(0xFFBFDBFE), 0.30 * opacity),
      ], stops: const [0, 0.45, 1]).createShader(b),
  );
}

/// Edges (HTML EdgesGeometry, 0x334155 at 60 %), rims and a specular streak,
/// drawn in front of the contents. [skipRims] leaves out rings by index.
void _glassEdges(Canvas canvas, _Cam cam, _Xf xf, List<(double, double)> profile,
    {double opacity = 1, Set<int> skipRims = const {}}) {
  const edge = Color(0xFF334155);
  final rings = [for (final pr in profile) _ring(cam, xf, pr.$1, pr.$2)];
  canvas.drawPath(
    _hull([for (final r in rings) ...r]),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _a(edge, 0.55 * opacity),
  );
  for (var i = 0; i < rings.length; i++) {
    if (skipRims.contains(i)) continue;
    canvas.drawPath(
      Path()..addPolygon(rings[i], true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = _a(edge, 0.6 * opacity),
    );
  }
  final hl = Paint()
    ..strokeWidth = 2.6
    ..strokeCap = StrokeCap.round
    ..color = Colors.white.withValues(alpha: 0.55 * opacity);
  for (var i = 0; i + 1 < profile.length; i++) {
    final (ya, ra) = profile[i];
    final (yb, rb) = profile[i + 1];
    if ((yb - ya).abs() < 0.3) continue;
    final dir = yb > ya ? 1 : -1;
    canvas.drawLine(
      xf.p(cam, -ra * 0.6, ya + 0.15 * dir, ra * 0.75),
      xf.p(cam, -rb * 0.6, yb - 0.15 * dir, rb * 0.75),
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

/// BoxGeometry centred at local (lx, ly) of [xf], with MeshStandardMaterial
/// like shading (light from above-front) and back-face culling.
void _box(Canvas canvas, _Cam cam, _Xf xf, double lx, double ly, double w, double h, double d, Color color,
    {double opacity = 1}) {
  final c = math.cos(xf.rot), s = math.sin(xf.rot);
  final hw = w / 2, hh = h / 2, hd = d / 2;
  const lxN = 0.3, lyN = 0.85, lzN = 0.43; // normalised light direction
  for (final (n, corners) in _boxFaces) {
    final nx = n[0] * c - n[1] * s, ny = n[0] * s + n[1] * c, nz = n[2];
    final fc = xf.w(lx + n[0] * hw, ly + n[1] * hh, n[2] * hd);
    final vx = cam.px - fc.$1, vy = cam.py - fc.$2, vz = cam.pz - fc.$3;
    if (nx * vx + ny * vy + nz * vz <= 0) continue;
    final path = cam.poly([for (final q in corners) xf.w(lx + q[0] * hw, ly + q[1] * hh, q[2] * hd)]);
    if (path == null) continue;
    final b = 0.55 + 0.6 * math.max(0, nx * lxN + ny * lyN + nz * lzN);
    canvas.drawPath(path, Paint()..color = _a(_lit(color, b), opacity));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _a(labShade(color, -0.5), 0.4 * opacity),
    );
  }
}

// ============================================================ PAINTER

const Color _lime = Color(0xFF84CC16); // HTML ground
const Color _stone = Color(0xFFCBD5E1); // dial base
const Color _gnomonGrey = Color(0xFF64748B);
const Color _yellow = Color(0xFFEAB308);
const double _horizonY = 284;
const double _gnomonW = 0.12; // half thickness of the wedge

class _A1Painter extends CustomPainter {
  _A1Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.latin,
    required this.validItem,
    required this.labels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final bool latin;
  final _Item? validItem;
  final Map<String, String> labels;

  String _l(String key) => labels[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = _cameraFor(scene.scenario);
    if (scene.scenario == 0) {
      _paintSundial(canvas, size, cam);
    } else {
      _paintWaterClock(canvas, size, cam);
    }
  }

  /// HTML `.item-label` chip (dark pill, white bold text).
  void _label(Canvas canvas, String text, Offset at, {Alignment anchor = Alignment.bottomCenter}) {
    if (!showLabels) return;
    labText(
      canvas,
      text,
      at,
      size: 16,
      weight: FontWeight.w700,
      color: Colors.white,
      background: const Color(0xE61E293B),
      border: const Color(0x6694A3B8),
      borderWidth: 1.2,
      anchor: anchor,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
    );
  }

  // ===================================================== SCENARIO 1

  void _paintSundial(Canvas canvas, Size size, _Cam cam) {
    final s = scene;
    final fade = s.cloudFade;
    final (sx, sy, sz) = s.sunPos;
    final sl = math.sqrt(sx * sx + sy * sy + sz * sz);
    final lx = sx / sl, ly = sy / sl, lz = sz / sl;
    // Directional light 1.3 (sunny) → 0.2 (cloudy), ambient 0.4.
    final dirI = 1.3 + (0.2 - 1.3) * fade;
    final bTop = 0.4 + dirI * math.max(0, ly);

    _sky(canvas, size, fade);
    _sunPath(canvas, fade);
    _sun(canvas, fade, s.time);
    _ground(canvas, size, bTop, fade);
    _clouds(canvas, fade);

    // Shadow strength: lit area vs. ambient-only shadow; none under clouds.
    final shadowA = ((bTop - 0.4) / bTop).clamp(0.0, 0.75) * 0.75 * (1 - fade);
    final shadowPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: shadowA)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
    if (shadowA > 0.01) {
      canvas.drawPath(_hull(_shadowPts(cam, lx, ly, lz, -0.25)), shadowPaint);
    }
    final topPath = _dialBase(canvas, cam, bTop, 0.4 + dirI * math.max(0, lz));
    if (shadowA > 0.01) {
      canvas.save();
      canvas.clipPath(topPath);
      canvas.drawPath(_hull(_shadowPts(cam, lx, ly, lz, 0.25)), shadowPaint);
      canvas.restore();
    }
    _dialScale(canvas, cam);
    _gnomon(canvas, cam, lx, ly, lz, dirI);

    // Labels (HTML lbl-gnomon / lbl-sundial).
    _label(canvas, _l('lbl_gnomon'), cam.p(0, 4.25, 2).translate(0, -10));
    _label(canvas, _l('lbl_sundial'), cam.p(4.6, 0.25, 4.4), anchor: Alignment.center);
  }

  void _sky(Canvas canvas, Size size, double fade) {
    final bleed = labBleed(size);
    final c0 = Color.lerp(isDark ? const Color(0xFF0F172A) : const Color(0xFF87CEEB), const Color(0xFF64748B), fade)!;
    final c1 = Color.lerp(isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F6FF), const Color(0xFFCBD5E1), fade)!;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, _horizonY + 4),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c0, c1],
        ).createShader(Rect.fromLTRB(0, 0, size.width, _horizonY)),
    );
  }

  /// Screen position of the sun on its arc (6 AM east/right → 6 PM west/left).
  Offset _sunScreen() {
    final a = math.pi - ((scene.sunTime - 6) / 12) * math.pi;
    return Offset(500 - math.cos(a) * 360, _horizonY - 6 - math.sin(a) * 120);
  }

  /// Faint dotted arc of the sun's daily path across the sky.
  void _sunPath(Canvas canvas, double fade) {
    if (!showLabels || fade >= 1) return;
    final path = Path()
      ..addArc(
        Rect.fromCenter(center: const Offset(500, _horizonY - 6), width: 720, height: 240),
        math.pi,
        math.pi,
      );
    labDashedPath(
      canvas,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: (isDark ? 0.22 : 0.55) * (1 - fade)),
      dash: 3,
      gap: 9,
    );
  }

  /// HTML sun sprite: 12 amber rays, #fbbf24 disc with #f59e0b border, and
  /// the soft 0xffaa00 glow sphere behind it. Dims behind the clouds.
  void _sun(Canvas canvas, double fade, double t) {
    final c = _sunScreen();
    final o = 1 - 0.75 * fade;
    const u = 84 / 256; // sprite pixels → design pixels
    labGlow(canvas, c, 70 + 3 * math.sin(t * 2), const Color(0xFFFFAA00), intensity: 0.55 * o);
    final rays = Paint()..color = _a(const Color(0xFFF59E0B), o);
    for (var i = 0; i < 12; i++) {
      final ang = (i + 1) * math.pi / 6;
      final cs = math.cos(ang), sn = math.sin(ang);
      Offset r(double x, double y) => c + Offset(x * cs - y * sn, x * sn + y * cs) * u;
      canvas.drawPath(
        Path()
          ..moveTo(r(-15, -80).dx, r(-15, -80).dy)
          ..lineTo(r(15, -80).dx, r(15, -80).dy)
          ..lineTo(r(0, -120).dx, r(0, -120).dy)
          ..close(),
        rays,
      );
    }
    final disc = Rect.fromCircle(center: c, radius: 70 * u);
    canvas.drawCircle(
      c,
      70 * u,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: [_a(const Color(0xFFFDE68A), o), _a(const Color(0xFFFBBF24), o)],
        ).createShader(disc),
    );
    canvas.drawCircle(
      c,
      70 * u,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * u
        ..color = _a(const Color(0xFFF59E0B), o),
    );
  }

  /// Rolling hills on the horizon and the lime grass plane (HTML ground
  /// 0x84cc16), lit by the sun.
  void _ground(Canvas canvas, Size size, double b, double fade) {
    final bleed = labBleed(size);
    final haze = Color.lerp(isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F6FF), const Color(0xFFCBD5E1), fade)!;
    Path hills(double base, double a1, double a2, double ph) {
      final path = Path()..moveTo(bleed.left, _horizonY + 10);
      for (var x = bleed.left; x <= bleed.right; x += 12) {
        path.lineTo(x, base - a1 * (0.5 + 0.5 * math.sin(x / 110 + ph)) - a2 * (0.5 + 0.5 * math.sin(x / 41 + ph * 2)));
      }
      return path
        ..lineTo(bleed.right, _horizonY + 10)
        ..close();
    }

    canvas.drawPath(
      hills(_horizonY, 26, 9, 0.6),
      Paint()..color = Color.lerp(_lit(const Color(0xFF4D7C0F), b), haze, 0.45)!,
    );
    canvas.drawPath(
      hills(_horizonY + 2, 13, 6, 2.1),
      Paint()..color = Color.lerp(_lit(const Color(0xFF65A30D), b), haze, 0.25)!,
    );
    final grass = Rect.fromLTRB(bleed.left, _horizonY, bleed.right, bleed.bottom);
    canvas.drawRect(
      grass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(_lit(_lime, b), haze, 0.2)!,
            _lit(_lime, b),
            _lit(labShade(_lime, -0.12), b),
          ],
          stops: const [0, 0.35, 1],
        ).createShader(Rect.fromLTRB(0, _horizonY, size.width, 600)),
    );
    // Mowing stripes for depth.
    final stripe = Paint()..color = Colors.black.withValues(alpha: 0.035);
    for (var i = 0; i < 9; i++) {
      final y0 = _horizonY + 8 + i * i * 4.0;
      final y1 = y0 + 3 + i * 2.2;
      if (i.isEven) canvas.drawRect(Rect.fromLTRB(bleed.left, y0, bleed.right, y1), stripe);
    }
  }

  /// Three white clouds (5 spheres each) drifting to the right.
  void _clouds(Canvas canvas, double fade) {
    if (fade <= 0.01) return;
    // Overcast layer that veils the sun.
    final haze = Rect.fromLTRB(-400, 60, 1400, _horizonY - 10);
    canvas.drawRect(
      haze,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE2E8F0).withValues(alpha: 0),
            const Color(0xFFE2E8F0).withValues(alpha: 0.55 * fade),
            const Color(0xFFCBD5E1).withValues(alpha: 0.35 * fade),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(haze),
    );
    const offsets = [(0.0, 0.0, 0.0, 1.5), (1.5, 0.5, 0.0, 1.2), (-1.5, 0.2, 0.0, 1.3), (0.8, 1.0, 0.5, 1.4), (-0.5, 0.8, -0.5, 1.1)];
    for (final c in scene.clouds) {
      final x = ((c.x + scene.cloudDrift + 20) % 40) - 20;
      final scale = 1 + (c.z + 5) * 0.06;
      final u = 21 * scale;
      final center = Offset(500 + x * 30, 226 - (c.y - 15) * 18);
      canvas.drawOval(
        Rect.fromCenter(center: center.translate(0, 1.4 * u), width: 5 * u, height: 1.1 * u),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12 * fade)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.4),
      );
      final puffs = [...offsets]..sort((a, b) => a.$3.compareTo(b.$3));
      for (final (ox, oy, _, r) in puffs) {
        final pc = center + Offset(ox * u, -oy * u);
        final rr = r * u * 0.92;
        canvas.drawCircle(
          pc,
          rr,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.45),
              radius: 1.0,
              colors: [
                _a(Colors.white, fade),
                _a(const Color(0xFFE2E8F0), fade),
                _a(const Color(0xFF94A3B8), fade),
              ],
              stops: const [0, 0.6, 1],
            ).createShader(Rect.fromCircle(center: pc, radius: rr)),
        );
      }
    }
  }

  /// Corners of the gnomon's shadow on the plane `y = planeY` (directional
  /// light from the sun; length capped like the HTML shadow camera).
  List<Offset> _shadowPts(_Cam cam, double lx, double ly, double lz, double planeY) {
    final pts = <Offset>[];
    for (final x in const [-_gnomonW, _gnomonW]) {
      for (final (y, z) in const [(0.25, 2.0), (4.25, 2.0), (0.25, 6.0)]) {
        final t = (y - planeY) / math.max(ly, 1e-4);
        var ox = lx * t, oz = lz * t;
        final m = math.sqrt(ox * ox + oz * oz);
        if (m > 20) {
          ox *= 20 / m;
          oz *= 20 / m;
        }
        pts.add(cam.p(x - ox, planeY, z - oz));
      }
    }
    return pts;
  }

  /// The dial base (cylinder r 9.5, 0.5 thick, 0xcbd5e1). Returns the top
  /// face path (used to clip the shadow).
  Path _dialBase(Canvas canvas, _Cam cam, double bTop, double bSide) {
    const xf = _Xf(0, 0, 0);
    final top = _ring(cam, xf, 0.25, 9.5, n: 96);
    final bot = _ring(cam, xf, -0.25, 9.5, n: 96);
    final bounds = _hull([...top, ...bot]).getBounds();
    // Contact shadow on the grass.
    canvas.drawOval(
      Rect.fromLTRB(bounds.left - 6, bounds.top + 8, bounds.right + 10, bounds.bottom + 10),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    final side = _lit(_stone, bSide);
    canvas.drawPath(
      _hull([...top, ...bot]),
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(side, -0.35),
          labShade(side, 0.1),
          side,
          labShade(side, -0.4),
        ], stops: const [0, 0.3, 0.65, 1]).createShader(bounds),
    );
    final topPath = Path()..addPolygon(top, true);
    final tb = topPath.getBounds();
    final face = _lit(_stone, bTop);
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.15, -0.2),
          radius: 0.85,
          colors: [labShade(face, 0.12), face, labShade(face, -0.08)],
          stops: const [0, 0.6, 1],
        ).createShader(tb),
    );
    // Bevel highlight and an inner carved ring.
    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawPath(
      Path()..addPolygon(_ring(cam, xf, 0.25, 9.15, n: 96), true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = labShade(face, -0.25).withValues(alpha: 0.6),
    );
    return topPath;
  }

  /// Yellow highlight ring (r 8.5), hour ticks and the 6…12…6 number badges
  /// (HTML `createNumberLabel`: slate-900 disc, yellow border, white text).
  void _dialScale(Canvas canvas, _Cam cam) {
    const xf = _Xf(0, 0, 0);
    canvas.drawPath(
      Path()..addPolygon(_ring(cam, xf, 0.26, 8.5, n: 120), true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = _yellow,
    );
    double angleOf(int i) => math.pi - ((i - 6) / 12) * math.pi;
    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF334155);
    for (var i = 6; i <= 18; i++) {
      if (i == 12) continue;
      final a = angleOf(i);
      final ux = math.cos(a), uz = -math.sin(a);
      final k = cam.k(ux * 7.25, 0.26, uz * 7.25);
      canvas.drawLine(
        cam.p(ux * 6.7, 0.26, uz * 6.7),
        cam.p(ux * 7.75, 0.26, uz * 7.75),
        tick..strokeWidth = math.max(2.0, 0.15 * k),
      );
    }
    // Badges, far ones first.
    final order = [for (var i = 6; i <= 18; i++) i]..sort((a, b) => math.sin(angleOf(b)).compareTo(math.sin(angleOf(a))));
    for (final i in order) {
      final a = angleOf(i);
      final x = math.cos(a) * 8.5, z = -math.sin(a) * 8.5;
      final c = cam.p(x, 0.27, z);
      final k = cam.k(x, 0.27, z);
      final r = 0.75 * k;
      final rect = Rect.fromCenter(center: c, width: 2 * r, height: 1.64 * r);
      canvas.drawOval(
        rect.shift(Offset(0, 0.12 * r)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawOval(rect, Paint()..color = const Color(0xFF0F172A));
      canvas.drawOval(
        rect.deflate(0.05 * r),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.6, 0.1 * r)
          ..color = _yellow,
      );
      labText(
        canvas,
        '${i > 12 ? i - 12 : i}',
        c.translate(0, 0.02 * r),
        size: 0.78 * r,
        weight: FontWeight.w800,
        color: const Color(0xFFF8FAFC),
      );
    }
  }

  /// Triangular gnomon wedge (0x64748b): vertical edge at z = 2, sloping to
  /// z = 6, 4 units tall, shaded by the sun.
  void _gnomon(Canvas canvas, _Cam cam, double lx, double ly, double lz, double dirI) {
    const w = _gnomonW;
    final faces = <((double, double, double), List<_P3>)>[
      ((-1, 0, 0), const [(-w, 0.25, 2), (-w, 4.25, 2), (-w, 0.25, 6)]),
      ((1, 0, 0), const [(w, 0.25, 2), (w, 0.25, 6), (w, 4.25, 2)]),
      ((0, 0, -1), const [(-w, 0.25, 2), (w, 0.25, 2), (w, 4.25, 2), (-w, 4.25, 2)]),
      ((0, 0.7071, 0.7071), const [(-w, 4.25, 2), (w, 4.25, 2), (w, 0.25, 6), (-w, 0.25, 6)]),
    ];
    for (final (n, pts) in faces) {
      var cx = 0.0, cy = 0.0, cz = 0.0;
      for (final q in pts) {
        cx += q.$1 / pts.length;
        cy += q.$2 / pts.length;
        cz += q.$3 / pts.length;
      }
      if (n.$1 * (cam.px - cx) + n.$2 * (cam.py - cy) + n.$3 * (cam.pz - cz) <= 0) continue;
      final path = cam.poly(pts);
      if (path == null) continue;
      final b = 0.4 + dirI * math.max(0, n.$1 * lx + n.$2 * ly + n.$3 * lz);
      canvas.drawPath(path, Paint()..color = _lit(_gnomonGrey, b));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..strokeJoin = StrokeJoin.round
          ..color = labShade(_gnomonGrey, -0.45),
      );
    }
  }

  // ===================================================== SCENARIO 2

  static const Color _tableCol = Color(0xFFD97706);
  static const Color _water = Color(0xFF2563EB);
  static const Color _drip = Color(0xFF3B82F6);
  static const Color _capBlue = Color(0xFF3B82F6);
  static const Color _red = Color(0xFFEF4444);
  static const Color _steel = Color(0xFF94A3B8);
  static const List<(double, double)> _bottleProfile = [
    (0, _bottleR),
    (_cutY, _bottleR),
    (_cutY + _coneH, _neckR),
    (_cutY + _neckTop, _neckR),
  ];
  static const List<(double, double)> _funnelProfile = [(0, _bottleR), (_coneH, _neckR), (_neckTop, _neckR)];
  static const List<(double, double)> _receiverProfile = [(0, _bottleR), (_cutY, _bottleR)];

  void _paintWaterClock(Canvas canvas, Size size, _Cam cam) {
    final s = scene;
    _labBackground(canvas, size, cam);
    if (s.dragging != null) _dropZone(canvas, cam, text: false);

    final cp = s.capPose;
    final items = <(double, int, VoidCallback)>[
      if (s.bottleVisible) (0.0, 0, () => _fullBottle(canvas, cam)),
      if (s.halvesVisible) (s.bottom.z, 0, () => _receiver(canvas, cam)),
      if (s.halvesVisible && !s.assembled) (s.top.z, 1, () => _funnel(canvas, cam)),
      if (!s.capOnBottle && (!s.capAttached || s.capAttach < 1))
        (cp.$3, 2, () => _capFree(canvas, cam, _Xf(cp.$1, cp.$2, cp.$3, cp.$4))),
      if (s.pinVisible) (s.pin.z, 3, () => _pin(canvas, cam)),
      if (s.toolVisible) (s.tool.z, 3, () => _tool(canvas, cam)),
      if (s.pitcherVisible) (s.pitcher.z, 4, () => _pitcher(canvas, cam)),
    ]..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
    for (final it in items) {
      it.$3();
    }
    _waterLabels(canvas, cam);
    if (s.dragging != null) _dropZone(canvas, cam, text: true);
  }

  /// HTML `#sky-bg` + `.grid-overlay` behind the orange work table
  /// (BoxGeometry 30 × 1 × 15, 0xd97706, lit from above).
  void _labBackground(Canvas canvas, Size size, _Cam cam) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [Color(0xFF87CEEB), Color(0xFFE0F6FF)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, size.height)),
    );
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.05 : 0.18)
      ..strokeWidth = 1;
    for (var x = (bleed.left / 40).floor() * 40.0; x < bleed.right; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    for (var y = (bleed.top / 40).floor() * 40.0; y < bleed.bottom; y += 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
    // Front panel (reaches into tall letterboxes) and the top.
    final front = cam.poly(const [(-15, 0, 7.5), (15, 0, 7.5), (15, -16, 7.5), (-15, -16, 7.5)]);
    if (front != null) {
      final fy = cam.p(0, 0, 7.5).dy;
      canvas.drawPath(
        front,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lit(_tableCol, 0.62), _lit(_tableCol, 0.35)],
          ).createShader(Rect.fromLTRB(0, fy, 10, fy + 300)),
      );
      canvas.drawLine(
        cam.p(-15, -1, 7.5),
        cam.p(15, -1, 7.5),
        Paint()
          ..strokeWidth = 2
          ..color = Colors.black.withValues(alpha: 0.2),
      );
    }
    final top = cam.poly(const [(-15, 0, -7.5), (15, 0, -7.5), (15, 0, 7.5), (-15, 0, 7.5)]);
    if (top == null) return;
    final backY = cam.p(0, 0, -7.5).dy;
    final frontY = cam.p(0, 0, 7.5).dy;
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_tableCol, -0.05), labShade(_tableCol, 0.12), labShade(_tableCol, 0.2)],
          stops: const [0, 0.5, 1],
        ).createShader(Rect.fromLTRB(0, backY, 10, frontY)),
    );
    // Wood grain and the back edge.
    canvas.save();
    canvas.clipPath(top);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = labShade(_tableCol, -0.35).withValues(alpha: 0.18);
    for (var z = -7.0; z <= 7.5; z += 1.25) {
      final path = Path();
      for (var x = -15.0; x <= 15; x += 1) {
        final pt = cam.p(x, 0, z + 0.12 * math.sin(x * 0.7 + z * 2));
        if (x == -15) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, grain);
    }
    canvas.restore();
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = labShade(_tableCol, -0.4).withValues(alpha: 0.6),
    );
  }

  /// Pulsing highlight behind the item that can be dragged in this step.
  void _hint(Canvas canvas, _Cam cam, _Item item, (double, double, double) c, double r) {
    if (validItem != item || scene.dragging != null) return;
    final pulse = 0.5 + 0.5 * math.sin(scene.time * 4);
    final k = cam.k(c.$1, c.$2, c.$3);
    labGlow(canvas, cam.p(c.$1, c.$2, c.$3), r * k * (1 + 0.06 * pulse), _yellow, intensity: 0.3 + 0.2 * pulse);
    // Pulsing target ring on the table under the item.
    final ring = _ring(cam, _Xf(c.$1, 0.02, c.$3), 0, r * (0.75 + 0.12 * pulse), n: 40);
    canvas.drawPath(
      Path()..addPolygon(ring, true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _yellow.withValues(alpha: 0.45 + 0.4 * pulse),
    );
  }

  /// The full plastic bottle with its cap and the dotted cut line.
  void _fullBottle(Canvas canvas, _Cam cam) {
    const xf = _Xf(0, 0, 0);
    final k = cam.k(0, 0, 0);
    labGroundShadow(canvas, cam.p(0.3, 0, 0.6), 4.8 * k, 1.2 * k, opacity: 0.3);
    _glassFill(canvas, cam, xf, _bottleProfile);
    canvas.drawPath(Path()..addPolygon(_ring(cam, xf, 0.05, 1.95), true), Paint()..color = const Color(0x22334155));
    _capShape(canvas, cam, const _Xf(0, _cutY + _neckTop, 0));
    _glassEdges(canvas, cam, xf, _bottleProfile, skipRims: const {1});
    labDashedPath(
      canvas,
      Path()..addPolygon(_ring(cam, xf, _cutY, 2.05, n: 72), true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = Colors.black.withValues(alpha: 0.85),
      dash: 7,
      gap: 5,
    );
  }

  /// Blue bottle cap (0x3b82f6); the drilled hole shows on its top face.
  void _capShape(Canvas canvas, _Cam cam, _Xf xf, {bool hole = false}) {
    _frustum(canvas, cam, xf, 0, _capR, _capH, _capR, _capBlue, capColor: labShade(_capBlue, 0.3));
    // Grip ridges.
    final ridge = Paint()
      ..strokeWidth = 1
      ..color = labShade(_capBlue, -0.4).withValues(alpha: 0.6);
    for (var i = 1; i < 8; i++) {
      final a = math.pi * i / 8;
      final x = -_capR * math.cos(a), z = _capR * math.sin(a);
      canvas.drawLine(xf.p(cam, x, 0.04, z), xf.p(cam, x, _capH - 0.03, z), ridge);
    }
    if (hole && math.cos(xf.rot) > 0.2) {
      canvas.drawPath(Path()..addPolygon(_ring(cam, xf, _capH + 0.005, 0.14, n: 16), true), Paint()..color = Colors.black);
    }
  }

  void _capFree(Canvas canvas, _Cam cam, _Xf xf) {
    final k = cam.k(xf.x, xf.y, xf.z);
    if (xf.y < 0.4) labGroundShadow(canvas, cam.p(xf.x + 0.1, 0, xf.z + 0.1), 1.6 * k, 0.5 * k, opacity: 0.35);
    _capShape(canvas, cam, xf, hole: scene.hasHole);
  }

  /// Bottom half (receiver): water, drops, the inverted funnel once
  /// assembled, and the red minute marks.
  void _receiver(Canvas canvas, _Cam cam) {
    final s = scene;
    final xf = _Xf(s.bottom.x, s.bottom.y, s.bottom.z);
    final k = cam.k(xf.x, 0, xf.z);
    labGroundShadow(canvas, cam.p(xf.x + 0.3, 0, xf.z + 0.6), 4.8 * k, 1.2 * k, opacity: 0.3);
    _glassFill(canvas, cam, xf, _receiverProfile);
    canvas.drawPath(Path()..addPolygon(_ring(cam, xf, 0.05, 1.95), true), Paint()..color = const Color(0x22334155));
    // Back halves of the marks (seen through the plastic).
    for (final m in s.marks) {
      _markArc(canvas, cam, xf, 0.05 + m, back: true);
    }
    if (s.receiverWaterVisible) {
      _frustum(canvas, cam, xf, 0.05, 1.93, s.waterSurface, 1.93, _water,
          opacity: 0.82, capColor: labShade(_water, 0.35).withValues(alpha: 0.9));
    }
    // Falling drops (HTML 0x3b82f6 spheres) from the cap's hole.
    final now = s.time;
    for (final d in s.drops) {
      final y = d.y0 - _dropSpeed * (now - d.t0);
      if (y < s.waterSurface || y > d.y0 + 0.01) continue;
      final c = cam.p(xf.x, y, xf.z);
      final dk = cam.k(xf.x, y, xf.z);
      canvas.drawOval(Rect.fromCenter(center: c, width: 0.2 * dk, height: 0.3 * dk), Paint()..color = _drip);
      canvas.drawCircle(c.translate(-0.03 * dk, -0.05 * dk), 0.035 * dk, Paint()..color = Colors.white70);
    }
    if (s.assembled) {
      _hint(canvas, cam, _Item.funnel, s.topXf.w(0, 1.1), 2.6);
      _funnel(canvas, cam);
    }
    _glassEdges(canvas, cam, xf, _receiverProfile);
    for (final m in s.marks) {
      _markArc(canvas, cam, xf, 0.05 + m, back: false);
    }
  }

  /// HTML minute mark: red torus (r 2.01) round the receiver.
  void _markArc(Canvas canvas, _Cam cam, _Xf xf, double y, {required bool back}) {
    const n = 40;
    final path = Path();
    for (var i = 0; i <= n ~/ 2; i++) {
      final a = math.pi * i / (n / 2) + (back ? math.pi : 0);
      final pt = xf.p(cam, 2.02 * math.cos(a), y, 2.02 * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = back ? 2 : 3.2
        ..strokeCap = StrokeCap.round
        ..color = _red.withValues(alpha: back ? 0.45 : 1),
    );
  }

  /// Top half: a funnel (wide rim at its pivot), turned over into the
  /// receiver with water inside and the pierced cap underneath.
  void _funnel(Canvas canvas, _Cam cam) {
    final s = scene;
    final xf = s.topXf;
    if (!s.assembled) _hint(canvas, cam, _Item.funnel, xf.w(0, 1.1), 2.6);
    if (s.top.y < 0.3 && math.cos(s.topRot) > 0.9) {
      final k = cam.k(xf.x, 0, xf.z);
      labGroundShadow(canvas, cam.p(xf.x + 0.3, 0, xf.z + 0.6), 4.8 * k, 1.2 * k, opacity: 0.28);
    }
    _glassFill(canvas, cam, xf, _funnelProfile);
    if (s.funnelWaterVisible && s.funnelWater > 0.01) {
      final ys = _funnelSurface(s.funnelWater); // measured from the rim
      final rs = (_bottleR - (ys / _coneH) * (_bottleR - _neckR)) * 0.93;
      _frustum(canvas, cam, xf, _neckTop, _neckR * 0.86, _coneH, _neckR * 0.86, _water, opacity: 0.85, cap: false);
      _frustum(canvas, cam, xf, _coneH, _neckR * 0.9, ys, rs, _water,
          opacity: 0.85, capColor: labShade(_water, 0.35).withValues(alpha: 0.92));
    }
    // HTML waterStream: water running through the neck while dripping.
    if (s.dripping) {
      final k = cam.k(xf.x, xf.y, xf.z);
      canvas.drawLine(
        xf.p(cam, 0, _coneH - 0.1),
        xf.p(cam, 0, _neckTop + _capH),
        Paint()
          ..strokeWidth = math.max(2.0, 0.16 * k)
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF60A5FA).withValues(alpha: 0.9),
      );
    }
    if (s.capAttached && s.capAttach >= 1) {
      final c = xf.w(0, _neckTop);
      _capShape(canvas, cam, _Xf(c.$1, c.$2, c.$3, s.topRot), hole: s.hasHole);
    }
    _glassEdges(canvas, cam, xf, _funnelProfile);
  }

  /// Drawing pin: red head (0xef4444) on a steel needle.
  void _pin(Canvas canvas, _Cam cam) {
    final p = scene.pin;
    final k = cam.k(p.x, p.y, p.z);
    _hint(canvas, cam, _Item.pin, (p.x, p.y + 0.4, p.z), 1.3);
    labGroundShadow(canvas, cam.p(p.x + 0.12, 0, p.z + 0.1), 0.9 * k, 0.3 * k, opacity: 0.35);
    canvas.drawLine(
      cam.p(p.x, p.y, p.z),
      cam.p(p.x, p.y + 0.55, p.z),
      Paint()
        ..strokeWidth = math.max(2.0, 0.07 * k)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFAAAAAA),
    );
    _frustum(canvas, cam, _Xf(p.x, p.y + 0.5, p.z), 0, 0.27, 0.14, 0.27, _red, capColor: labShade(_red, 0.35));
  }

  /// Cutting tool: red handle with a steel blade, leaning at 45°.
  void _tool(Canvas canvas, _Cam cam) {
    final t = scene.tool;
    final xf = _Xf(t.x, t.y, t.z, -math.pi / 4);
    final k = cam.k(t.x, t.y, t.z);
    _hint(canvas, cam, _Item.tool, xf.w(0, 1.6), 2.0);
    final tip = xf.w(0, 3.0);
    labGroundShadow(canvas, cam.p((t.x + tip.$1) / 2 + 0.2, 0, t.z + 0.2), 2.6 * k, 0.5 * k, opacity: 0.3);
    // Blade (behind the handle's slider), slanted at the tip.
    final blade = Path()
      ..addPolygon([
        xf.p(cam, -0.17, 1.4, 0.02),
        xf.p(cam, 0.17, 1.4, 0.02),
        xf.p(cam, 0.17, 2.65, 0.02),
        xf.p(cam, -0.17, 3.0, 0.02),
      ], true);
    final bb = blade.getBounds();
    canvas.drawPath(
      blade,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_steel, 0.6), _steel, labShade(_steel, -0.3)],
        ).createShader(bb),
    );
    canvas.drawPath(
      blade,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(_steel, -0.5),
    );
    canvas.drawLine(
      xf.p(cam, -0.14, 1.5, 0.02),
      xf.p(cam, -0.14, 2.9, 0.02),
      Paint()
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.75),
    );
    _box(canvas, cam, xf, 0, 0.75, 0.5, 1.5, 0.26, _red);
    // Grip ridges and the blade slider.
    final ridge = Paint()
      ..strokeWidth = 1.2
      ..color = labShade(_red, -0.45).withValues(alpha: 0.7);
    for (var i = 0; i < 4; i++) {
      final y = 0.3 + i * 0.25;
      canvas.drawLine(xf.p(cam, -0.2, y, 0.135), xf.p(cam, 0.2, y, 0.135), ridge);
    }
    _box(canvas, cam, xf, 0, 1.38, 0.22, 0.2, 0.3, _Colors.slate700);
  }

  /// Water pitcher (plastic body r 1.5 × 3 with coloured water), with a
  /// handle and a spout; tilts to pour into the funnel.
  void _pitcher(Canvas canvas, _Cam cam) {
    final s = scene;
    final o = s.pitcherAlpha;
    if (o <= 0.01) return;
    final xf = _Xf(s.pitcher.x, s.pitcher.y, s.pitcher.z, s.pitcherRot);
    final k = cam.k(xf.x, xf.y + 1.5, xf.z);
    final fade = o < 1;
    if (fade) canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: o));
    _hint(canvas, cam, _Item.pitcher, (xf.x, xf.y + 1.5, xf.z), 2.4);
    if (s.pitcher.y < 0.3 && s.pitcherRot.abs() < 0.05) {
      labGroundShadow(canvas, cam.p(xf.x + 0.3, 0, xf.z + 0.5), 3.8 * k, 1.0 * k, opacity: 0.3);
    }
    // Handle on the far side from the spout.
    final handle = Path();
    const hp = [(-1.45, 2.55), (-2.2, 2.45), (-2.35, 1.7), (-2.15, 1.0), (-1.45, 0.75)];
    for (var i = 0; i < hp.length; i++) {
      final pt = xf.p(cam, hp[i].$1, hp[i].$2);
      if (i == 0) {
        handle.moveTo(pt.dx, pt.dy);
      } else {
        handle.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.32 * k
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.85),
    );
    const profile = [(0.0, 1.5), (3.0, 1.5)];
    _glassFill(canvas, cam, xf, profile);
    if (s.pitcherFill > 0.01) {
      if (s.pitcherRot.abs() < 0.03) {
        _frustum(canvas, cam, xf, 0.05, 1.4, 0.05 + 2.5 * s.pitcherFill, 1.4, _water,
            opacity: 0.88, capColor: labShade(_water, 0.35));
      } else {
        final clip = _hull([..._ring(cam, xf, 0.06, 1.42), ..._ring(cam, xf, 2.95, 1.42)]);
        final b = clip.getBounds();
        final levelY = b.bottom - b.height * s.pitcherFill * 0.62;
        canvas.save();
        canvas.clipPath(clip);
        canvas.drawRect(Rect.fromLTRB(b.left - 2, levelY, b.right + 2, b.bottom + 2), Paint()..color = _a(_water, 0.88));
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
    // Spout on the pouring side.
    canvas.drawPath(
      Path()
        ..addPolygon([xf.p(cam, 1.45, 3.0), xf.p(cam, 2.0, 3.2), xf.p(cam, 1.45, 2.55)], true),
      Paint()..color = const Color(0xFFDBEAFE).withValues(alpha: 0.6),
    );
    _glassEdges(canvas, cam, xf, profile);
    if (s.pourStream > 0) _pourStream(canvas, cam, xf, k);
    if (fade) canvas.restore();
  }

  /// Stream of water from the spout into the funnel.
  void _pourStream(Canvas canvas, _Cam cam, _Xf xf, double k) {
    final s = scene;
    final lip = xf.w(1.95, 3.15);
    final surfaceY = s.top.y - _funnelSurface(s.funnelWater);
    final a = cam.p3(lip);
    final b = cam.p(s.top.x + 0.2, math.min(surfaceY, lip.$2 - 0.3), s.top.z);
    final e = Offset.lerp(a, b, s.pourStream)!;
    final ctrl = Offset(a.dx + (e.dx - a.dx) * 0.8, a.dy + (e.dy - a.dy) * 0.1);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, e.dx, e.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.24 * k
        ..strokeCap = StrokeCap.round
        ..color = _water.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.07 * k
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    if (s.pourStream > 0.95) {
      final ph = (s.time * 3) % 1;
      canvas.drawOval(
        Rect.fromCenter(center: e, width: (0.4 + 0.8 * ph) * k, height: (0.12 + 0.24 * ph) * k),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withValues(alpha: 0.7 * (1 - ph)),
      );
    }
  }

  /// HTML `#global-drop-zone` ("DROP HERE"), shown around the target of the
  /// item being dragged.
  void _dropZone(Canvas canvas, _Cam cam, {required bool text}) {
    final s = scene;
    final (cx, cz, hw, y1) = switch (s.dragging) {
      _Item.tool => (0.0, 0.0, 2.6, _cutY + _neckTop + 1.7),
      _Item.pin => (s.cap.x, s.cap.z, 1.2, 1.9),
      _Item.funnel => (s.bottom.x, s.bottom.z, 2.6, _cutY + 0.5),
      _ => (s.top.x, s.top.z, 2.6, _cutY + 1.6),
    };
    var r = Rect.zero;
    for (final x in [cx - hw, cx + hw]) {
      for (final y in [-0.2, y1]) {
        for (final z in [cz - hw, cz + hw]) {
          final pt = cam.p(x, y, z);
          r = r == Rect.zero ? Rect.fromCenter(center: pt, width: 0, height: 0) : r.expandToInclude(Rect.fromCenter(center: pt, width: 0, height: 0));
        }
      }
    }
    r = r.inflate(10);
    final pulse = 0.5 + 0.5 * math.sin(s.time * math.pi); // animate-pulse (2 s)
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(22));
    if (!text) {
      canvas.drawRRect(rr, Paint()..color = _yellow.withValues(alpha: 0.1 + 0.08 * pulse));
      labDashedPath(
        canvas,
        Path()..addRRect(rr),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = _yellow.withValues(alpha: 0.6),
        dash: 12,
        gap: 8,
        phase: s.time * 20,
      );
      return;
    }
    labText(
      canvas,
      _l('drop_here'),
      Offset(r.center.dx, r.top),
      size: 18,
      weight: FontWeight.w800,
      color: _yellow.withValues(alpha: 0.55 + 0.45 * pulse),
      background: const Color(0xE60F172A),
      border: _yellow.withValues(alpha: 0.6),
      borderWidth: 2,
      letterSpacing: latin ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    );
  }

  /// Floating item labels (HTML `updateLabelPosition`) and minute marks.
  void _waterLabels(Canvas canvas, _Cam cam) {
    if (!showLabels) return;
    final s = scene;
    if (s.receiverWaterVisible) {
      for (var i = 0; i < s.marks.length; i++) {
        final y = 0.05 + s.marks[i];
        labText(
          canvas,
          _l('mark_${i + 1}'),
          cam.p(s.bottom.x + 2.25, y, s.bottom.z + 0.4),
          anchor: Alignment.centerLeft,
          size: 13,
          weight: FontWeight.w800,
          color: Colors.white,
          background: _red.withValues(alpha: 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        );
      }
    }
    if (s.bottleVisible && s.lblBottle) _label(canvas, _l('lbl_bottle'), cam.p(0, _cutY + _neckTop + _capH + 0.5, 0));
    if (s.toolVisible && s.lblTool) {
      final tip = _Xf(s.tool.x, s.tool.y, s.tool.z, -math.pi / 4).w(0, 3.0);
      _label(canvas, _l('lbl_tool'), cam.p(tip.$1, tip.$2 + 0.5, tip.$3));
    }
    if (s.pinVisible && s.lblPin) _label(canvas, _l('lbl_pin'), cam.p(s.pin.x, s.pin.y + 1.0, s.pin.z));
    if (s.lblCap && !s.capOnBottle) {
      final cp = s.capPose;
      if (s.capAttached) {
        // Beside the cap once it sits on the funnel neck (the funnel's own
        // label is above it).
        _label(canvas, _l('lbl_cap'), cam.p(cp.$1 + 0.8, cp.$2 + 0.15, cp.$3), anchor: Alignment.centerLeft);
      } else {
        _label(canvas, _l('lbl_cap'), cam.p(cp.$1, cp.$2 + 0.8, cp.$3));
      }
    }
    if (s.halvesVisible && s.lblFunnel) {
      final xf = s.topXf;
      final top = math.max(xf.w(0, 0).$2, xf.w(0, _neckTop + _capH).$2);
      _label(canvas, _l('lbl_funnel'), cam.p(xf.x, top + 0.5, xf.z));
    }
    if (s.halvesVisible && s.lblBeaker) {
      _label(canvas, _l('lbl_beaker'), cam.p(s.bottom.x, 0, s.bottom.z + 2.6), anchor: Alignment.topCenter);
    }
    if (s.pitcherVisible && s.lblPitcher) {
      _label(canvas, _l('lbl_pitcher'), cam.p(s.pitcher.x, s.pitcher.y + 3.6, s.pitcher.z));
    }
  }

  @override
  bool shouldRepaint(covariant _A1Painter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.latin != latin ||
      old.validItem != validItem ||
      !mapEquals(old.labels, labels);
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
