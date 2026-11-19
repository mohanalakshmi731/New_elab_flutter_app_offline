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

/// Class 7 Science • Chapter 11 • Activity 4
/// Shadow Formation.
///
/// Native Flutter port of `Cl7S-Ch11-A4-Shadow_Formation.html`.
/// Scenario 1: build the three "ingredients" of a shadow (torch, opaque
/// object, screen) from a tray, then remove each one to see the shadow
/// vanish. Scenario 2: drag the object towards the screen / torch, tilt it
/// and swap it for a red one to see how the shadow's size, shape and colour
/// behave.
class Ch11A4ShadowFormationPage extends StatefulWidget {
  const Ch11A4ShadowFormationPage({super.key});

  @override
  State<Ch11A4ShadowFormationPage> createState() => _Ch11A4ShadowFormationPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, switchTap 2585.
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
  switchTap('switch.mp3');

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

const Size _design = Size(1000, 560);

/// Minimal 3D vector for the HTML world coordinates.
@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }
}

// Perspective projection that mimics the HTML camera (fov 35, at
// (0, 5, 80) looking at the origin) in 1000x560 design pixels.
const double _projF = 1000;
const double _projD = 80;
const double _camY = 5;
const double _projCx = 480;
const double _projCy = 213;

double _kz(double z) => _projF / (_projD - z);

Offset _proj(double x, double y, double z) {
  final f = _kz(z);
  return Offset(_projCx + x * f, _projCy - (y - _camY) * f);
}

Offset _projV(_V3 v) => _proj(v.x, v.y, v.z);

/// Inverse of [_proj] on the plane at depth [z] (the HTML drag plane).
_V3 _unproj(Offset p, double z) {
  final f = _kz(z);
  return _V3((p.dx - _projCx) / f, _camY + (_projCy - p.dy) / f, z);
}

// HTML `State.zones` (table positions already include the +4 / +7 lifts
// that the HTML adds when snapping). The torch is held at the object's
// height (y 4 instead of 0.5) so that moving the object only changes the
// size of its shadow, which stays centred on the screen.
const _V3 _torchTable = _V3(-20, 4, 0);
const _V3 _screenTable = _V3(20, -3.5, 0);
const _V3 _ballTable = _V3(0, 4, 0);
const _V3 _torchTray = _V3(-15, -13.5, 5);
const _V3 _ballTray = _V3(0, -13, 5);
const _V3 _screenTray = _V3(15, -13.5, 5);
const _V3 _redBallTray = _V3(10, -13, 5);

/// Spot light position (torch head on the table) and its target.
const _V3 _lightPos = _V3(-15, 4, 0);
const _V3 _lightTarget = _V3(20, 6.5, 0);

/// Spot light half angle (Math.PI / 5).
const double _spotAngle = math.pi / 5;

/// Torch lens radius (head CylinderGeometry radiusTop = 2).
const double _lensRadius = 2;

/// Effective size of the bulb for the penumbra (fuzziness) of shadows.
const double _bulbRadius = 1.2;

/// The screen board is turned towards the torch so its face (and the
/// shadow on it) can be seen from the front: unit vector along the board.
const double _boardTurn = 55 * math.pi / 180;
final _V3 _boardU = _V3(math.cos(_boardTurn), 0, math.sin(_boardTurn));
final _V3 _boardN = _V3(-math.sin(_boardTurn), 0, math.cos(_boardTurn));

enum _Id { torch, ball, screen, redball }

class _Tween {
  _Tween({
    required this.from,
    required this.to,
    required this.start,
    required this.duration,
    required this.curve,
    this.onDone,
  });

  final _V3 from;
  final _V3 to;
  final double start;
  final double duration;
  final Curve curve;
  final VoidCallback? onDone;
}

class _Obj {
  _Obj(this.id, _V3 p, {this.state = 'tray'})
      : x = p.x,
        y = p.y,
        z = p.z;

  final _Id id;
  double x, y, z;

  /// `rotation.z` (tilt) for the opaque objects.
  double rot = 0;

  /// 'tray' or 'table' (HTML `userData.state`).
  String state;
  bool draggable = false;
  bool dragging = false;
  _Tween? tween;

  _V3 get pos => _V3(x, y, z);

  set pos(_V3 v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }

  bool get isBall => id == _Id.ball || id == _Id.redball;
}

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;
  int step = 1;
  bool torchOn = false;
  bool finished = false;
  double time = 0;
  final Map<_Id, _Obj> objects = {};

  _Obj? get torch => objects[_Id.torch];
  _Obj? get ball => objects[_Id.ball];
  _Obj? get screen => objects[_Id.screen];
  _Obj? get redball => objects[_Id.redball];

  /// Object currently pulsing to guide the student (HTML pulseTween).
  _Id? get pulseId {
    if (finished) return null;
    if (scenario == 0) {
      if (step == 1 || step == 4 || (step == 5 && !torchOn)) return _Id.torch;
      if (step == 2 || step == 3) return _Id.ball;
      if (step == 5 && torchOn) return _Id.screen;
      return null;
    }
    return step == 5 ? _Id.redball : null;
  }

  /// Current drawing scale of [o] (drag lift and guidance pulse).
  double scaleOf(_Obj o) {
    if (o.dragging) return 1.2;
    if (pulseId == o.id) {
      final amp = scenario == 0 ? 0.05 : 0.1;
      return 1 + amp * (0.5 - 0.5 * math.cos(time * math.pi * 2));
    }
    return 1;
  }

  /// The screen shrinks while it sits in the tray so it fits there.
  static double screenSize(_Obj s) => 0.42 + 0.58 * ((s.y - _screenTray.y) / (_screenTable.y - _screenTray.y)).clamp(0.0, 1.0);
}

// ============================================================ GESTURES

/// Claims a pointer immediately (no slop) when it lands on an interactive
/// object, so short drags and taps on objects work and are never taken by
/// the zoom / pan viewer. Touches elsewhere are left to the canvas.
class _ObjectDragRecognizer extends OneSequenceGestureRecognizer {
  _ObjectDragRecognizer({super.debugOwner});

  bool Function(Offset local)? claims;
  ValueChanged<Offset>? onDown;
  ValueChanged<Offset>? onMove;
  VoidCallback? onUp;
  int? _pointer;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_pointer != null) return;
    if (!(claims?.call(event.localPosition) ?? false)) return;
    super.addAllowedPointer(event);
    _pointer = event.pointer;
    resolve(GestureDisposition.accepted);
    onDown?.call(event.localPosition);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _pointer) return;
    if (event is PointerMoveEvent) {
      onMove?.call(event.localPosition);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      onUp?.call();
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer == _pointer) {
      onUp?.call();
      stopTrackingPointer(pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) => _pointer = null;

  @override
  String get debugDescription => 'shadow lab object drag';
}

// ============================================================== STATE

class _Ch11A4ShadowFormationPageState extends State<Ch11A4ShadowFormationPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;
  late final AnimationController _bounce;

  /// HTML `#drag-instruction` (hidden once an object is grabbed).
  bool _hintVisible = true;

  // HTML `State.activeDraggable`, `isTilting`, `dragOffset`, `startMouseY`.
  _Obj? _active;
  bool _tilting = false;
  double _dragDx = 0, _dragDy = 0;
  double _lastTiltY = 0;

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

    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    _ticker = createTicker(_onTick)..start();
    _buildScenario(sound: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _bounce.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    _scene.time = now;
    final done = <VoidCallback>[];
    for (final o in _scene.objects.values) {
      final tw = o.tween;
      if (tw == null) continue;
      final p = ((now - tw.start) / tw.duration).clamp(0.0, 1.0);
      final v = tw.curve.transform(p);
      o.pos = tw.from + (tw.to - tw.from) * v;
      if (p >= 1) {
        o.pos = tw.to;
        o.tween = null;
        if (tw.onDone != null) done.add(tw.onDone!);
      }
    }
    _frame.value = now;
    if (done.isNotEmpty && mounted) {
      setState(() {
        for (final fn in done) {
          fn();
        }
      });
    }
  }

  /// TWEEN.js `new TWEEN.Tween(obj.position).to(target, ms)`.
  void _tweenTo(_Obj o, _V3 target, int ms, Curve curve, [VoidCallback? onDone]) {
    o.tween = _Tween(
      from: o.pos,
      to: target,
      start: _scene.time,
      duration: ms / 1000,
      curve: curve,
      onDone: onDone,
    );
  }

  // ------------------------------------------------------------- build

  /// HTML `buildScenario()` (clearScene + buildScenario1/2 +
  /// updateObjectAvailability).
  void _buildScenario({bool sound = true}) {
    _lab.cancelPending();
    _active = null;
    _tilting = false;
    _hintVisible = true;
    _scene
      ..objects.clear()
      ..torchOn = false
      ..finished = false;
    if (_scenario == 0) {
      // S1: torch & ball in the tray, screen on the table.
      _scene.objects
        ..[_Id.torch] = _Obj(_Id.torch, _torchTray)
        ..[_Id.ball] = _Obj(_Id.ball, _ballTray)
        ..[_Id.screen] = _Obj(_Id.screen, _screenTable, state: 'table');
    } else {
      // S2: torch, ball and screen on the table (torch ON), red ball in tray.
      _scene.objects
        ..[_Id.torch] = _Obj(_Id.torch, _torchTable, state: 'table')
        ..[_Id.ball] = _Obj(_Id.ball, _ballTable, state: 'table')
        ..[_Id.screen] = _Obj(_Id.screen, _screenTable, state: 'table')
        ..[_Id.redball] = _Obj(_Id.redball, _redBallTray);
      _toggleTorch(force: true, sound: sound);
    }
    _updateAvailability();
  }

  void _changeScenario(int index) {
    setState(() {
      _scene
        ..scenario = index
        ..step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
    _lab.resetView(sound: false);
  }

  void _fullReset() {
    setState(() {
      _scene
        ..scenario = 0
        ..step = 1;
      _buildScenario(sound: false);
    });
  }

  // ------------------------------------------------------------- logic

  /// HTML `toggleTorch(forceState)`.
  void _toggleTorch({bool? force, bool sound = true}) {
    if (sound) _Audio.play(_Sound.switchTap);
    _scene.torchOn = force ?? !_scene.torchOn;
    _evaluateStep();
  }

  /// HTML `updateObjectAvailability()`.
  void _updateAvailability() {
    for (final o in _scene.objects.values) {
      o.draggable = false;
    }
    final torch = _scene.torch!, ball = _scene.ball!, screen = _scene.screen!;
    if (_scenario == 0) {
      if (_step == 1) torch.draggable = true;
      if (_step == 2 || _step == 3) ball.draggable = true;
      if (_step == 5) screen.draggable = true;
      if (_step == 6) {
        if (torch.state != 'table') torch.draggable = true;
        if (ball.state != 'table') ball.draggable = true;
        if (screen.state != 'table') screen.draggable = true;
      }
    } else {
      final red = _scene.redball!;
      if (_step >= 2 && _step <= 4) ball.draggable = true;
      if (_step == 5 || _step == 6) red.draggable = true;
    }
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    final n = _data.steps.length;
    if (_step < n) {
      _scene.step++;
      _updateAvailability();
    } else if (_step == n) {
      _showConclusion();
    }
  }

  /// HTML `evaluateStep()`.
  void _evaluateStep() {
    if (_scene.finished) return;
    var complete = false;
    if (_scenario == 0) {
      final torch = _scene.torch!, ball = _scene.ball!, screen = _scene.screen!;
      if (_step == 1 && torch.state == 'table' && _scene.torchOn) complete = true;
      if (_step == 2 && ball.state == 'table') complete = true;
      if (_step == 3 && ball.state == 'tray') complete = true;
      if (_step == 4 && !_scene.torchOn) complete = true;
      if (_step == 5 && screen.state == 'tray' && _scene.torchOn) complete = true;
      if (_step == 6 && torch.state == 'table' && ball.state == 'table' && screen.state == 'table') {
        complete = true;
      }
    } else {
      final ball = _scene.ball!, red = _scene.redball!;
      if (_step == 2 && ball.x > 0) complete = true; // right half of the table
      if (_step == 3 && ball.x < 0) complete = true; // left half of the table
      if (_step == 4 && ball.rot.abs() > 0.15) complete = true; // gentle tilt
      if (_step == 5 && red.state == 'table') complete = true;
      // Steps 1 and 6 use the HUD buttons.
    }
    if (complete) {
      _lab.showToast(_t('sci_conclusion'));
      _advanceStep();
    }
  }

  /// HUD "Continue" / "Finish" (HTML `triggerHudAction`).
  void _hudAction() => setState(_advanceStep);

  void _showConclusion() {
    if (_scenario == 0) _scene.finished = true;
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_scenario + 1}'),
    );
  }

  /// HTML `handleDrop(obj)`.
  void _handleDrop(_Obj obj) {
    final id = obj.id;
    var success = false;
    var target = obj.pos;

    if (_scenario == 0) {
      // Extremely forgiving table bounds (anywhere above the middle of the tray).
      final onTable = obj.y > -15;
      if (id == _Id.torch && _step == 1) {
        if (onTable && obj.x < 5) {
          success = true;
          target = _torchTable;
          obj.state = 'table';
        }
      } else if (id == _Id.ball && _step == 2) {
        if (onTable) {
          success = true;
          target = _ballTable;
          obj.state = 'table';
        }
      } else if (id == _Id.ball && _step == 3) {
        // Dragged downwards or horizontally out of the beam.
        if (obj.y < 3 || obj.x.abs() > 2) {
          success = true;
          target = _ballTray;
          obj.state = 'tray';
        }
      } else if (id == _Id.screen && _step == 5) {
        if (obj.y < 3 || obj.x < 18) {
          success = true;
          target = _screenTray;
          obj.state = 'tray';
        }
      } else if (_step == 6) {
        if (onTable) {
          success = true;
          obj.state = 'table';
          target = switch (id) {
            _Id.torch => _torchTable,
            _Id.screen => _screenTable,
            _ => _ballTable,
          };
        }
      }
    } else {
      if (id == _Id.redball && _step == 5) {
        // Replace the grey object: just drag it up a little from the tray.
        if (obj.y > _redBallTray.y) {
          success = true;
          final ball = _scene.ball!;
          target = _V3(ball.x, ball.y, 0);
          obj.state = 'table';
          _tweenTo(ball, _ballTray, 500, Curves.linear);
        }
      } else if (obj.isBall && (_step == 2 || _step == 3 || _step == 6)) {
        success = true;
        target = _V3(obj.x, _ballTable.y, 0);
      }
    }

    if (success) {
      _Audio.play(_Sound.drop);
      _tweenTo(obj, target, 300, Curves.easeOutCubic, () {
        if (_scenario == 0 && _step == 1 && id == _Id.torch && !_scene.torchOn) {
          // The torch switches itself on once it is placed.
          _toggleTorch(force: true);
        } else {
          final prev = _step;
          _evaluateStep();
          if (_scenario == 1 && _step == prev && _step < 5) {
            if (_step == 2) _lab.showToast(_t('hint_right'), isError: true);
            if (_step == 3) _lab.showToast(_t('hint_left'), isError: true);
          }
        }
      });
    } else {
      _lab.showToast(_t('msg_wrong_drop'), isError: true);
      final _V3 back;
      if (obj.state == 'table') {
        back = switch (id) {
          _Id.torch => _torchTable,
          _Id.screen => _screenTable,
          _ => _ballTable,
        };
      } else {
        back = switch (id) {
          _Id.torch => _torchTray,
          _Id.screen => _screenTray,
          _Id.redball => _redBallTray,
          _ => _ballTray,
        };
      }
      _tweenTo(obj, back, 500, Curves.elasticOut);
    }
  }

  // ------------------------------------------------------- interaction

  /// Scenario 1: the torch on the table is a switch in steps 1, 4, 5, 6.
  bool _torchClickable(_Obj o) =>
      _scenario == 0 && o.id == _Id.torch && o.state == 'table' && const [1, 4, 5, 6].contains(_step);

  /// Raycaster stand-in: the interactive object under [p] (design px).
  _Obj? _hit(Offset p) {
    _Obj? best;
    var bestD = double.infinity;
    for (final o in _scene.objects.values) {
      if (o.tween != null) continue;
      if (!(o.draggable || _torchClickable(o))) continue;
      final r = _objectBounds(_scene, o);
      if (!r.contains(p)) continue;
      final d = (r.center - p).distance;
      if (d < bestD) {
        best = o;
        bestD = d;
      }
    }
    return best;
  }

  bool _claims(Offset p) => _lab.isLabActive && _active == null && _lab.popup == null && _hit(p) != null;

  /// HTML `pointerdown`.
  void _pointerDown(Offset p) {
    final obj = _hit(p);
    if (obj == null) return;
    if (_torchClickable(obj)) {
      setState(() => _toggleTorch());
      return;
    }
    setState(() {
      _active = obj;
      _hintVisible = false;
      if (_scenario == 1 && _step == 4 && obj.isBall) {
        // Scenario 2 tilting: vertical drags rotate the object.
        _tilting = true;
        _lastTiltY = p.dy;
        return;
      }
      final w = _unproj(p, obj.z);
      _dragDx = w.x - obj.x;
      _dragDy = w.y - obj.y;
      obj.dragging = true;
      _Audio.play(_Sound.pickup);
    });
  }

  /// HTML `pointermove`.
  void _pointerMove(Offset p) {
    final obj = _active;
    if (obj == null) return;
    if (_tilting) {
      final dNdc = -(p.dy - _lastTiltY) * 2 / _design.height;
      obj.rot += dNdc * math.pi;
      _lastTiltY = p.dy;
      return;
    }
    final w = _unproj(p, obj.z);
    var tx = w.x - _dragDx;
    // Scenario 2: depth fixed, generous horizontal bounds.
    if (_scenario == 1 && obj.isBall) tx = tx.clamp(-15.0, 18.0);
    obj
      ..x = tx
      ..y = w.y - _dragDy;
  }

  /// HTML `pointerup`.
  void _pointerUp() {
    final obj = _active;
    if (obj == null) return;
    setState(() {
      _active = null;
      if (!_tilting) {
        obj.dragging = false;
        _handleDrop(obj);
      } else {
        _tilting = false;
        final prev = _step;
        _evaluateStep();
        if (_scenario == 1 && _step == prev && _step == 4) {
          _lab.showToast(_t('hint_tilt'), isError: true);
        }
      }
    });
  }

  List<LabAction> _actions() {
    final key = _hudButtons[_scenario]?[_step];
    if (key == null) return const [];
    return [
      LabAction(
        label: _t(key),
        icon: _step == 1 ? Icons.arrow_forward : Icons.flag_rounded,
        color: _Colors.indigo600,
        foreground: Colors.white,
        onTap: _hudAction,
      ),
    ];
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.nightlight_round,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            if (_hintVisible && _lab.isLabActive) _hintOverlay(s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ObjectDragRecognizer: GestureRecognizerFactoryWithHandlers<_ObjectDragRecognizer>(
                  () => _ObjectDragRecognizer(debugOwner: this),
                  (r) => r
                    ..claims = _claims
                    ..onDown = _pointerDown
                    ..onMove = _pointerMove
                    ..onUp = _pointerUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _ShadowPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  labels: {
                    _Id.torch: _t('obj_torch'),
                    _Id.screen: _t('obj_screen'),
                    _Id.ball: _t('obj_ball'),
                    _Id.redball: _t('obj_redball'),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#drag-instruction`: bouncing hand + hint, a third of the way
  /// down the canvas, until the first object is grabbed.
  Widget _hintOverlay(double s, EdgeInsets inset) {
    return Positioned.fill(
      left: inset.left,
      right: inset.right,
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -1 / 3),
          child: AnimatedBuilder(
            animation: _bounce,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -10 * s * (0.5 + 0.5 * math.cos(_bounce.value * 2 * math.pi))),
              child: child,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 34 * s, color: Colors.white.withValues(alpha: 0.6)),
                  SizedBox(height: 4 * s),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      _t('drag_drop_hint'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 13 * s,
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

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Shadow Formation',
    'app_subtitle': 'Class 7 • Light: Shadows and Reflections',
    'scen_1_opt': 'Scenario 1: Essential Ingredients',
    'scen_2_opt': 'Scenario 2: Resizing Shadows',
    'sci_conclusion': 'Success!',
    'drag_drop_hint': 'Follow the HUD instructions below!',
    'msg_wrong_drop': 'Incorrect placement. Try again.',
    'conclusion_1':
        'A shadow requires exactly three things to form: 1. A Source of Light, 2. An Opaque Object to block the light, and 3. A Screen to cast the shadow upon.',
    'conclusion_2':
        "The size of a shadow depends on the object's distance from the light and the screen. Moving the object closer to the light makes the shadow larger. Tilting an object changes the shape of its shadow. The color of an opaque object does not affect the color of its shadow; shadows are always dark.",
    'obj_torch': 'Torch',
    'obj_screen': 'Screen',
    'obj_ball': 'Opaque Object',
    'obj_redball': 'Red Opaque Object',
    'action_continue': 'Continue',
    'action_finish': 'Finish',
    // Feedback that was hard-coded in English in the HTML.
    'hint_tilt': 'Drag up or down to tilt it further!',
    'hint_right': 'Drag it further RIGHT (towards the screen)!',
    'hint_left': 'Drag it further LEFT (towards the torch)!',
  },
  'hi': {
    'app_title': 'छाया निर्माण',
    'app_subtitle': 'कक्षा 7 • प्रकाश: छाया और परावर्तन',
    'scen_1_opt': 'परिदृश्य 1: आवश्यक सामग्री',
    'scen_2_opt': 'परिदृश्य 2: छाया का आकार बदलना',
    'sci_conclusion': 'सफलता!',
    'drag_drop_hint': 'नीचे दिए गए HUD निर्देशों का पालन करें!',
    'msg_wrong_drop': 'गलत स्थान। पुनः प्रयास करें।',
    'conclusion_1':
        'छाया बनने के लिए ठीक तीन चीजों की आवश्यकता होती है: 1. प्रकाश का स्रोत, 2. प्रकाश को रोकने के लिए एक अपारदर्शी वस्तु, और 3. छाया डालने के लिए एक स्क्रीन।',
    'conclusion_2':
        'छाया का आकार प्रकाश और स्क्रीन से वस्तु की दूरी पर निर्भर करता है। वस्तु को प्रकाश के करीब ले जाने से छाया बड़ी हो जाती है। किसी वस्तु को झुकाने से उसकी छाया का आकार बदल जाता है। किसी अपारदर्शी वस्तु का रंग उसकी छाया के रंग को प्रभावित नहीं करता है; छाया हमेशा काली होती है।',
    'obj_torch': 'टॉर्च',
    'obj_screen': 'स्क्रीन',
    'obj_ball': 'अपारदर्शी वस्तु',
    'obj_redball': 'लाल अपारदर्शी वस्तु',
    'action_continue': 'जारी रखें',
    'action_finish': 'समाप्त करें',
    'hint_tilt': 'इसे और झुकाने के लिए ऊपर या नीचे खींचें!',
    'hint_right': 'इसे और दाईं ओर (स्क्रीन की ओर) खींचें!',
    'hint_left': 'इसे और बाईं ओर (टॉर्च की ओर) खींचें!',
  },
};

// ========================================================== SCENARIOS

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To discover the three necessary components required to form a shadow: a light source, an opaque object, and a screen.',
      steps: [
        LabStep(
          concept: 'Light Source',
          action: "DRAG the 'Torch' from the tray to the left side of the table. It will automatically turn ON.",
          observation: 'A beam of light travels across the table, hitting the screen.',
        ),
        LabStep(
          concept: 'Opaque Object',
          action: "DRAG the 'Opaque Object' from the tray and DROP it in the middle of the light beam.",
          observation: 'A dark shadow immediately appears on the screen.',
        ),
        LabStep(
          concept: 'Removing the Object',
          action: "DRAG the 'Opaque Object' back to the tray.",
          observation: 'The shadow disappears, showing the object is necessary.',
        ),
        LabStep(
          concept: 'Removing Light',
          action: 'CLICK the Torch to turn it OFF.',
          observation: 'The light and shadow disappear, showing light is necessary.',
        ),
        LabStep(
          concept: 'Removing the Screen',
          action: "CLICK the Torch to turn it back ON. Then DRAG the 'Screen' to the tray.",
          observation: 'The light travels, but without a surface, no shadow is seen.',
        ),
        LabStep(
          concept: 'Reassembly',
          action: "DRAG the 'Screen' back to the table, and DRAG the 'Opaque Object' back into the light.",
          observation: 'With all three components present, the shadow forms again.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          "To investigate how the shadow's size and shape are affected by the relative positions of the light, object, and screen.",
      steps: [
        LabStep(
          concept: 'Baseline Setup',
          action: 'Observe the initial size of the shadow on the screen.',
          observation: 'A clear shadow is visible, serving as a baseline.',
        ),
        LabStep(
          concept: 'Closer to Screen',
          action: "DRAG the 'Opaque Object' closer to the Screen.",
          observation: 'The shadow becomes smaller and sharper.',
        ),
        LabStep(
          concept: 'Closer to Light',
          action: "DRAG the 'Opaque Object' closer to the Torch.",
          observation: 'The shadow becomes much larger and fuzzier.',
        ),
        LabStep(
          concept: 'Tilting the Object',
          action: 'DRAG the Object UP or DOWN to tilt it.',
          observation: 'The shape of the shadow changes from a circle to an oval.',
        ),
        LabStep(
          concept: 'Object Color',
          action: "DRAG the 'Red Opaque Object' from the tray to replace the current object.",
          observation: 'The shadow remains black, proving shadow color is independent of object color.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: "Experiment with the red object's position, then Finish.",
          observation: 'The shadow size changes, but color is always dark.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'छाया बनाने के लिए आवश्यक तीन घटकों की खोज करना: प्रकाश स्रोत, अपारदर्शी वस्तु और स्क्रीन।',
      steps: [
        LabStep(
          concept: 'प्रकाश स्रोत',
          action: "ट्रे से 'टॉर्च' को मेज के बाईं ओर खींचें। यह अपने आप चालू हो जाएगा।",
          observation: 'प्रकाश की एक किरण मेज के पार जाती है और स्क्रीन से टकराती है।',
        ),
        LabStep(
          concept: 'अपारदर्शी वस्तु',
          action: "ट्रे से 'अपारदर्शी वस्तु' खींचें और इसे प्रकाश किरण के बीच में छोड़ दें।",
          observation: 'स्क्रीन पर तुरंत एक काली छाया दिखाई देती है।',
        ),
        LabStep(
          concept: 'वस्तु को हटाना',
          action: "'अपारदर्शी वस्तु' को वापस ट्रे में खींचें।",
          observation: 'छाया गायब हो जाती है, यह दर्शाता है कि वस्तु आवश्यक है।',
        ),
        LabStep(
          concept: 'प्रकाश हटाना',
          action: 'इसे बंद करने के लिए टॉर्च पर क्लिक करें।',
          observation: 'प्रकाश और छाया गायब हो जाते हैं, यह दर्शाता है कि प्रकाश आवश्यक है।',
        ),
        LabStep(
          concept: 'स्क्रीन हटाना',
          action: "इसे वापस चालू करने के लिए टॉर्च पर क्लिक करें। फिर 'स्क्रीन' को ट्रे में खींचें।",
          observation: 'प्रकाश यात्रा करता है, लेकिन सतह के बिना, कोई छाया नहीं दिखती है।',
        ),
        LabStep(
          concept: 'पुन: संयोजन',
          action: "'स्क्रीन' को मेज पर वापस लाएँ, और 'अपारदर्शी वस्तु' को वापस प्रकाश में लाएँ।",
          observation: 'तीनों घटकों के उपस्थित होने पर छाया फिर से बनती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह जांच करने के लिए कि प्रकाश, वस्तु और स्क्रीन की सापेक्ष स्थितियों से छाया का आकार और स्वरूप कैसे प्रभावित होता है।',
      steps: [
        LabStep(
          concept: 'आधार रेखा सेटअप',
          action: 'स्क्रीन पर छाया के प्रारंभिक आकार का निरीक्षण करें।',
          observation: 'एक स्पष्ट छाया दिखाई देती है, जो एक आधार रेखा के रूप में कार्य करती है।',
        ),
        LabStep(
          concept: 'स्क्रीन के करीब',
          action: "'अपारदर्शी वस्तु' को स्क्रीन के करीब खींचें।",
          observation: 'छाया छोटी और तेज हो जाती है।',
        ),
        LabStep(
          concept: 'प्रकाश के करीब',
          action: "'अपारदर्शी वस्तु' को टॉर्च के करीब खींचें।",
          observation: 'छाया बहुत बड़ी और धुंधली हो जाती है।',
        ),
        LabStep(
          concept: 'वस्तु को झुकाना',
          action: 'वस्तु को झुकाने के लिए उसे ऊपर या नीचे खींचें।',
          observation: 'छाया का आकार वृत्त से अंडाकार में बदल जाता है।',
        ),
        LabStep(
          concept: 'वस्तु का रंग',
          action: "वर्तमान वस्तु को बदलने के लिए ट्रे से 'लाल अपारदर्शी वस्तु' खींचें।",
          observation: 'छाया काली रहती है, यह साबित करता है कि छाया का रंग वस्तु के रंग से स्वतंत्र है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'लाल वस्तु की स्थिति के साथ प्रयोग करें, फिर समाप्त करें।',
          observation: 'छाया का आकार बदलता है, लेकिन रंग हमेशा गहरा रहता है।',
        ),
      ],
    ),
  ],
};

/// Steps whose HUD shows an action button (`hasActionBtn` / `btnText`),
/// per scenario (0-based) and 1-based step.
const Map<int, Map<int, String>> _hudButtons = {
  1: {1: 'action_continue', 6: 'action_finish'},
};

// ============================================================ GEOMETRY

const _V3 _up = _V3(0, 1, 0);

/// Screen board at the screen's current position (the board grows from
/// the stand base, like the Three.js group scale).
class _Board {
  _Board(_Obj screen, double pulse) {
    size = _Scene.screenSize(screen);
    final s = size * pulse;
    scale = s;
    // Shrunk in the tray: rest the base on the tray floor.
    baseY = screen.y - 1.5 * (1 - size) / 0.58;
    base = _V3(screen.x, baseY, screen.z);
    // The board sits in the slot of its stand base.
    center = _V3(screen.x, baseY + 9 * s, screen.z) + _boardN * (0.6 * s);
    hw = 12 * s;
    hh = 9 * s;
  }

  late final double size;
  late final double scale;
  late final double baseY;
  late final _V3 base;
  late final _V3 center;
  late final double hw;
  late final double hh;

  _V3 at(double u, double v) => center + _boardU * u + _up * v;

  List<_V3> get corners => [at(-hw, hh), at(hw, hh), at(hw, -hh), at(-hw, -hh)];

  Path get path {
    final c = corners.map(_projV).toList();
    return Path()..addPolygon(c, true);
  }
}

/// Design-space hit box of an object (used for tap / drag picking).
Rect _objectBounds(_Scene scene, _Obj o) {
  final s = scene.scaleOf(o);
  Rect r;
  switch (o.id) {
    case _Id.torch:
      r = Rect.fromPoints(
        _proj(o.x - 4.5 * s, o.y + 2.4 * s, o.z),
        _proj(o.x + 5.4 * s, o.y - 2.4 * s, o.z),
      );
    case _Id.ball:
    case _Id.redball:
      r = Rect.fromPoints(
        _proj(o.x - 2.2 * s, o.y + 3.3 * s, o.z),
        _proj(o.x + 2.2 * s, o.y - 3.3 * s, o.z),
      );
    case _Id.screen:
      final b = _Board(o, s);
      final pts = [...b.corners, b.base + _boardU * 4, b.base - _boardU * 4].map(_projV);
      var l = double.infinity, t = double.infinity, rr = -double.infinity, bb = -double.infinity;
      for (final p in pts) {
        l = math.min(l, p.dx);
        t = math.min(t, p.dy);
        rr = math.max(rr, p.dx);
        bb = math.max(bb, p.dy);
      }
      r = Rect.fromLTRB(l, t, rr, bb);
  }
  return Rect.fromCenter(
    center: r.center,
    width: math.max(r.width, 64),
    height: math.max(r.height, 64),
  ).inflate(6);
}

/// Convex hull (monotone chain) of 2D points.
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

/// A shadow cast by one opaque object in the torch beam.
class _Cast {
  _Cast({
    required this.outline,
    required this.volume,
    required this.sigma,
    required this.umbra,
    required this.onBoard,
  });

  /// Shadow outline on the receiving plane (design px).
  final List<Offset> outline;

  /// Blocked part of the beam between the object and the plane.
  final Path volume;

  /// Penumbra blur (design px): larger when the object is near the torch.
  final double sigma;

  /// Umbra size relative to the full shadow (0..1).
  final double umbra;
  final bool onBoard;
}

/// 2D outline of an opaque object (squashed sphere, tilted by `rot`).
List<Offset> _objectOutline(_Obj o, double s, {int n = 28}) {
  final c = _proj(o.x, o.y, o.z);
  final f = _kz(o.z) * s;
  final cr = math.cos(-o.rot), sr = math.sin(-o.rot);
  return [
    for (var i = 0; i < n; i++)
      () {
        final a = i / n * 2 * math.pi;
        final px = 1.5 * f * math.cos(a), py = 3 * f * math.sin(a);
        return c + Offset(px * cr - py * sr, px * sr + py * cr);
      }(),
  ];
}

/// Casts the shadow of [o] from the torch onto [board] (or into the empty
/// room when the screen is missing). Returns null when the object is
/// outside the light cone.
_Cast? _castShadow(_Scene scene, _Obj o, _Board? board) {
  final s = scene.scaleOf(o);
  const l = _lightPos;
  final toB = o.pos - l;
  final dist = toB.length;
  final r = 3 * s;
  if (dist < 0.5) return null;
  final d = toB.unit;
  if (d.x <= 0.05) return null; // behind the torch lens
  final axis = (_lightTarget - l).unit;
  final ang = math.acos(d.dot(axis).clamp(-1.0, 1.0));
  final angR = math.asin(math.min(1.0, r / dist));
  if (ang - angR > _spotAngle) return null;

  final e2 = d.cross(_up).unit;
  final e1 = e2.cross(d).unit;
  final hv = math.sqrt(math.pow(1.5 * math.sin(o.rot), 2) + math.pow(3 * math.cos(o.rot), 2)) * s;
  final hz = 3.0 * s;

  double tFor(_V3 p) {
    final v = p - l;
    if (board != null) {
      final num = _boardN.dot(board.center - l);
      final den = _boardN.dot(v);
      if (den > -1e-3) return 60;
      return math.min(num / den, 60);
    }
    if (v.x < 1e-3) return 60;
    return math.min((32 - l.x) / v.x, 60);
  }

  final tc = tFor(o.pos);
  if (tc <= 1.0) return null; // the object is beyond the screen
  final outline = <Offset>[];
  const n = 40;
  for (var i = 0; i < n; i++) {
    final a = i / n * 2 * math.pi;
    final sp = o.pos + e1 * (hv * math.sin(a)) + e2 * (hz * math.cos(a));
    final t = math.max(tFor(sp), 1.0);
    outline.add(_projV(l + (sp - l) * t));
  }
  final hull = _hull([...outline, ..._objectOutline(o, s)]);
  final volume = Path()..addPolygon(hull, true);

  // Extended source: penumbra = bulb * (d_obj_screen / d_light_obj).
  final pen = _bulbRadius * (tc - 1);
  final sigma = (pen * _kz(0) * 0.3).clamp(0.6, 34.0);
  final umbra = (1 - pen / (hv * tc + pen)).clamp(0.05, 1.0);
  return _Cast(outline: outline, volume: volume, sigma: sigma, umbra: umbra, onBoard: board != null);
}

// ============================================================ PAINTER

class _ShadowPainter extends CustomPainter {
  _ShadowPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final Map<_Id, String> labels;

  static const Color _tableColor = Color(0xFF475569);
  static const Color _legColor = Color(0xFF334155);
  static const Color _trayColor = Color(0xFF94A3B8);
  static const Color _beamColor = Color(0xFFFFFFEE);

  Path _poly(List<_V3> pts) => Path()..addPolygon(pts.map(_projV).toList(), true);

  @override
  void paint(Canvas canvas, Size size) {
    final lit = scene.torchOn;
    final screen = scene.screen!;
    final board = _Board(screen, scene.scaleOf(screen));
    // The board catches the beam when it stands on the table inside the cone.
    final axis = (_lightTarget - _lightPos).unit;
    final toBoard = (board.center - _lightPos).unit;
    final catches = board.size > 0.95 && math.acos(toBoard.dot(axis).clamp(-1.0, 1.0)) < _spotAngle;
    final receiver = catches ? board : null;

    // Shadows cast by the opaque objects inside the beam.
    final casts = <_Cast>[];
    if (lit) {
      for (final o in scene.objects.values) {
        if (!o.isBall) continue;
        final c = _castShadow(scene, o, receiver);
        if (c != null) casts.add(c);
      }
    }

    _paintRoom(canvas, size, lit);
    _paintTable(canvas, size, lit);

    // Objects resting at table level vs. in the tray vs. being dragged.
    bool inTray(_Obj o) => o.z > 2.5 && o.y < -9 && !o.dragging;
    final tableObjs = scene.objects.values.where((o) => !o.dragging && !inTray(o)).toList();
    final trayObjs = scene.objects.values.where(inTray).toList();
    final dragged = scene.objects.values.where((o) => o.dragging).toList();

    if (lit) _paintBeam(canvas, receiver, casts);
    if (tableObjs.contains(screen)) _paintScreen(canvas, screen, board, lit && catches, casts);
    for (final o in tableObjs) {
      if (o.id != _Id.screen) _paintObject(canvas, o, lit, board);
    }
    _paintTrayBack(canvas);
    for (final o in trayObjs) {
      _paintObject(canvas, o, lit, board);
    }
    _paintTrayFront(canvas);
    for (final o in dragged) {
      _paintObject(canvas, o, lit, board);
    }
    if (lit) labGlow(canvas, _proj(_lightPos.x, _lightPos.y, 0), 46, const Color(0xFFFFF4C2), intensity: 0.8);
    if (showLabels) _paintLabels(canvas, board);
  }

  void _paintObject(Canvas canvas, _Obj o, bool lit, _Board board) {
    switch (o.id) {
      case _Id.torch:
        _paintTorch(canvas, o, lit);
      case _Id.screen:
        _paintScreen(canvas, o, board, false, const []);
      case _Id.ball:
      case _Id.redball:
        _paintBall(canvas, o, lit);
    }
  }

  // --------------------------------------------------------------- room

  void _paintRoom(Canvas canvas, Size size, bool lit) {
    final bleed = labBleed(size);
    final wallBottom = _proj(0, -26, -15).dy;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, wallBottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF070C1A), Color(0xFF111A2E), Color(0xFF1E293B)]
              : const [Color(0xFF3B4A5F), Color(0xFF4F5F75), Color(0xFF64748B)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, wallBottom)),
    );
    // Faint wall panels.
    final seam = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 2;
    for (var x = -90.0; x <= 90; x += 18) {
      final a = _proj(x, 40, -15), b = _proj(x, -26, -15);
      canvas.drawLine(a, b, seam);
    }
    // Floor.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, wallBottom, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1120), Color(0xFF020617)]
              : const [Color(0xFF334155), Color(0xFF1E293B)],
        ).createShader(Rect.fromLTRB(0, wallBottom, size.width, wallBottom + 120)),
    );
    canvas.drawLine(
      Offset(bleed.left, wallBottom),
      Offset(bleed.right, wallBottom),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..strokeWidth = 2,
    );
    if (lit) {
      // Spill of the spot light on the back wall.
      final c = _proj(24, 6, -15);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 520, height: 330),
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFF7D6).withValues(alpha: 0.16),
            const Color(0xFFFFF7D6).withValues(alpha: 0),
          ]).createShader(Rect.fromCenter(center: c, width: 520, height: 330)),
      );
    }
  }

  // -------------------------------------------------------------- table

  void _paintLeg(Canvas canvas, double x, double z) {
    // BoxGeometry(2, 20, 2) from y -6 to -26.
    final front = _poly([_V3(x - 1, -6, z + 1), _V3(x + 1, -6, z + 1), _V3(x + 1, -26, z + 1), _V3(x - 1, -26, z + 1)]);
    final side = x < 0
        ? _poly([_V3(x + 1, -6, z + 1), _V3(x + 1, -6, z - 1), _V3(x + 1, -26, z - 1), _V3(x + 1, -26, z + 1)])
        : _poly([_V3(x - 1, -6, z + 1), _V3(x - 1, -6, z - 1), _V3(x - 1, -26, z - 1), _V3(x - 1, -26, z + 1)]);
    canvas.drawPath(side, Paint()..color = labShade(_legColor, -0.35));
    canvas.drawPath(front, Paint()..color = _legColor);
    labGroundShadow(canvas, _proj(x, -26, z), 60, 12, opacity: 0.35);
  }

  void _paintTable(Canvas canvas, Size size, bool lit) {
    for (final p in const [[-28.0, -8.0], [28.0, -8.0], [-28.0, 8.0], [28.0, 8.0]]) {
      _paintLeg(canvas, p[0], p[1]);
    }
    // Table top (BoxGeometry 60 x 2 x 20 at y = -5).
    final top = _poly(const [_V3(-30, -4, -10), _V3(30, -4, -10), _V3(30, -4, 10), _V3(-30, -4, 10)]);
    final topRect = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_tableColor, -0.25), labShade(_tableColor, 0.08)],
        ).createShader(topRect),
    );
    // Wood-like grain lines.
    final grain = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (var z = -8.0; z <= 8; z += 4) {
      canvas.drawLine(_proj(-30, -4, z), _proj(30, -4, z), grain);
    }
    if (lit) {
      // Light pool on the table top under the beam.
      final c = _proj(10, -4, 0);
      final r = Rect.fromCenter(center: c, width: 470, height: 34);
      canvas.save();
      canvas.clipPath(top);
      canvas.drawOval(
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFF7D6).withValues(alpha: 0.32),
            const Color(0xFFFFF7D6).withValues(alpha: 0),
          ]).createShader(r),
      );
      canvas.restore();
    }
    final front = _poly(const [_V3(-30, -4, 10), _V3(30, -4, 10), _V3(30, -6, 10), _V3(-30, -6, 10)]);
    canvas.drawPath(front, Paint()..color = labShade(_tableColor, -0.3));
    canvas.drawLine(
      _proj(-30, -4, 10),
      _proj(30, -4, 10),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.5,
    );
  }

  // --------------------------------------------------------------- tray

  // Tray (BoxGeometry 45 x 1 x 10 at (0, -14, 5)) drawn as an open tray.
  static const double _trayFloor = -15;
  static const double _trayRim = -13.8;

  void _paintTrayBack(Canvas canvas) {
    final outerTop = _poly(const [
      _V3(-22.5, _trayRim, 0), _V3(22.5, _trayRim, 0), _V3(22.5, _trayRim, 10), _V3(-22.5, _trayRim, 10), //
    ]);
    canvas.drawPath(outerTop, Paint()..color = labShade(_trayColor, 0.15));
    final floor = _poly(const [
      _V3(-21.9, _trayFloor, 0.6), _V3(21.9, _trayFloor, 0.6), _V3(21.9, _trayFloor, 9.4), _V3(-21.9, _trayFloor, 9.4), //
    ]);
    canvas.drawPath(
      floor,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_trayColor, -0.35), labShade(_trayColor, -0.15)],
        ).createShader(floor.getBounds()),
    );
    // Inner back rim face.
    canvas.drawPath(
      _poly(const [_V3(-21.9, _trayRim, 0.6), _V3(21.9, _trayRim, 0.6), _V3(21.9, _trayFloor, 0.6), _V3(-21.9, _trayFloor, 0.6)]),
      Paint()..color = labShade(_trayColor, -0.05),
    );
  }

  void _paintTrayFront(Canvas canvas) {
    final face = _poly(const [_V3(-22.5, _trayRim, 10), _V3(22.5, _trayRim, 10), _V3(22.5, -15.6, 10), _V3(-22.5, -15.6, 10)]);
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_trayColor, 0.05), labShade(_trayColor, -0.3)],
        ).createShader(face.getBounds()),
    );
    canvas.drawPath(
      _poly(const [_V3(-22.5, _trayRim, 9.4), _V3(22.5, _trayRim, 9.4), _V3(22.5, _trayRim, 10), _V3(-22.5, _trayRim, 10)]),
      Paint()..color = labShade(_trayColor, 0.35),
    );
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(_trayColor, -0.5).withValues(alpha: 0.5),
    );
  }

  // --------------------------------------------------------------- beam

  /// Volumetric cone from the torch lens to the screen (or across the
  /// empty table when the screen is in the tray), minus the dark region
  /// behind each opaque object.
  void _paintBeam(Canvas canvas, _Board? receiver, List<_Cast> casts) {
    const l = _lightPos;
    final lens = [
      for (var i = 0; i < 24; i++)
        _proj(l.x, l.y + _lensRadius * math.sin(i / 24 * 2 * math.pi), l.z + _lensRadius * math.cos(i / 24 * 2 * math.pi)),
    ];
    // HTML cone: CylinderGeometry(15, 1.5, 45) -> radius 15 at x = 30.
    final end = receiver != null
        ? receiver.corners.map(_projV).toList()
        : [
            for (var i = 0; i < 24; i++)
              _proj(30, l.y + 15 * math.sin(i / 24 * 2 * math.pi), 15 * math.cos(i / 24 * 2 * math.pi)),
          ];
    var beam = Path()..addPolygon(_hull([...lens, ...end]), true);
    for (final c in casts) {
      beam = Path.combine(PathOperation.difference, beam, c.volume);
    }
    final from = _projV(l);
    final to = receiver != null ? _projV(receiver.center) : _proj(30, l.y, 0);
    canvas.drawPath(
      beam,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.linear(from, to, [
          _beamColor.withValues(alpha: 0.42),
          _beamColor.withValues(alpha: 0.16),
          _beamColor.withValues(alpha: receiver != null ? 0.1 : 0),
        ], const [0, 0.45, 1]),
    );
    // Brighter core along the axis.
    final coreEnd = receiver != null
        ? [for (final c in receiver.corners) _projV(receiver.center + (c - receiver.center) * 0.45)]
        : [for (final p in end) to + (p - to) * 0.45];
    var core = Path()..addPolygon(_hull([...lens.map((p) => from + (p - from) * 0.6), ...coreEnd]), true);
    for (final c in casts) {
      core = Path.combine(PathOperation.difference, core, c.volume);
    }
    canvas.drawPath(
      core,
      Paint()
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..shader = ui.Gradient.linear(from, to, [
          _beamColor.withValues(alpha: 0.22),
          _beamColor.withValues(alpha: 0),
        ]),
    );
    // Dust motes drifting along the beam.
    canvas.save();
    canvas.clipPath(beam);
    final mote = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 26; i++) {
      final seed = i * 12.9898;
      final u = ((math.sin(seed) * 43758.5453).abs() % 1 + scene.time * 0.05 * (1 + i % 3)) % 1;
      final v = (math.sin(seed * 1.7) * 0.5) * (0.2 + u);
      final p = Offset.lerp(from, to, u)! + Offset(0, v * 140 + 6 * math.sin(scene.time + i));
      canvas.drawCircle(p, 1.1 + (i % 3) * 0.4, mote);
    }
    canvas.restore();
  }

  // ------------------------------------------------------------- screen

  void _paintScreen(Canvas canvas, _Obj o, _Board b, bool litFace, List<_Cast> casts) {
    final s = b.scale;
    final f = _kz(o.z) * s;
    labGroundShadow(canvas, _projV(b.base), 9 * f, 2 * f, opacity: 0.4);
    // Stand base: BoxGeometry(8, 0.5, 4).
    final bu = _boardU * (4 * s), bn = _boardN * (2 * s), h = _up * (0.5 * s);
    final p0 = b.base - bu - bn, p1 = b.base + bu - bn, p2 = b.base + bu + bn, p3 = b.base - bu + bn;
    const baseColor = Color(0xFF1E293B);
    canvas.drawPath(_poly([p3, p2, p2 + h, p3 + h]), Paint()..color = labShade(baseColor, -0.2));
    canvas.drawPath(_poly([p1, p2, p2 + h, p1 + h]), Paint()..color = labShade(baseColor, -0.35));
    canvas.drawPath(_poly([p0 + h, p1 + h, p2 + h, p3 + h]), Paint()..color = labShade(baseColor, 0.2));
    // Pillar: BoxGeometry(0.5, 10, 1) behind the board.
    final pu = _boardU * (0.3 * s);
    canvas.drawPath(
      _poly([b.base - pu + h, b.base + pu + h, b.base + pu + _up * (10 * s), b.base - pu + _up * (10 * s)]),
      Paint()..color = const Color(0xFF334155),
    );
    // Board thickness.
    final front = b.corners;
    final back = [for (final c in front) c - _boardN * (0.45 * s)];
    canvas.drawPath(
      Path()..addPolygon(_hull([...front.map(_projV), ...back.map(_projV)]), true),
      Paint()..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFFA8B3C2),
    );
    final face = b.path;
    final bounds = face.getBounds();
    // Unlit board (ambient light only).
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF7D8696), Color(0xFF636C7C)]
              : const [Color(0xFF9AA3B2), Color(0xFF7E8798)],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipPath(face);
    if (litFace) {
      // Spot light hitting the board.
      final axis = (_lightTarget - _lightPos).unit;
      final t = _boardN.dot(b.center - _lightPos) / _boardN.dot(axis);
      final hit = _projV(_lightPos + axis * t);
      final r = Rect.fromCircle(center: hit, radius: 300 * s);
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFFFFFEF6), Color(0xFFF6F1DD), Color(0xFFD9D3BC)],
            stops: const [0, 0.55, 1],
          ).createShader(r),
      );
    }
    // Faint grid (GridHelper 24 x 12 at 10% opacity).
    final grid = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 0.8;
    for (var u = -12.0; u <= 12; u += 2) {
      canvas.drawLine(_projV(b.at(u * s, b.hh)), _projV(b.at(u * s, -b.hh)), grid);
    }
    for (var v = -9.0; v <= 9; v += 2) {
      canvas.drawLine(_projV(b.at(-b.hw, v * s)), _projV(b.at(b.hw, v * s)), grid);
    }
    // Shadows: always dark, whatever the object's colour.
    if (litFace) {
      for (final c in casts) {
        if (!c.onBoard) continue;
        canvas.drawPath(
          Path()..addPolygon(c.outline, true),
          Paint()
            ..color = const Color(0xFF2B313B).withValues(alpha: 0.88)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, c.sigma),
        );
        var cx = 0.0, cy = 0.0;
        for (final p in c.outline) {
          cx += p.dx;
          cy += p.dy;
        }
        final cen = Offset(cx / c.outline.length, cy / c.outline.length);
        canvas.drawPath(
          Path()..addPolygon([for (final p in c.outline) cen + (p - cen) * c.umbra], true),
          Paint()
            ..color = const Color(0xFF1C2129).withValues(alpha: 0.9)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.6, c.sigma * 0.35)),
        );
      }
    }
    canvas.restore();
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF475569),
    );
    // Front half of the stand base, in front of the board (the slot).
    final m1 = b.base + bu, m0 = b.base - bu;
    canvas.drawPath(_poly([p3, p2, p2 + h, p3 + h]), Paint()..color = labShade(baseColor, -0.2));
    canvas.drawPath(_poly([m1, p2, p2 + h, m1 + h]), Paint()..color = labShade(baseColor, -0.35));
    canvas.drawPath(_poly([m0 + h, m1 + h, p2 + h, p3 + h]), Paint()..color = labShade(baseColor, 0.2));
    canvas.drawLine(
      _projV(m0 + h),
      _projV(m1 + h),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 1.2,
    );
  }

  // -------------------------------------------------------------- torch

  void _paintTorch(Canvas canvas, _Obj o, bool lit) {
    final s = scene.scaleOf(o);
    final f = _kz(o.z) * s;
    Offset p(double lx, double ly) => _proj(o.x + lx * s, o.y + ly * s, o.z);
    final on = lit && o.state == 'table';
    const blue = Color(0xFF3B82F6);
    const grey = Color(0xFF64748B);

    if (o.state == 'table' && !o.dragging && o.tween == null) {
      // Small clamp stand holding the torch above the table.
      final top = p(-1, -1.2);
      final foot = _proj(o.x - 1 * s, -4, o.z);
      labGroundShadow(canvas, foot, 4 * f, 1.1 * f, opacity: 0.45);
      canvas.drawOval(Rect.fromCenter(center: foot, width: 3.4 * f, height: 0.9 * f), Paint()..color = const Color(0xFF1F2937));
      final rod = Rect.fromLTRB(top.dx - 0.22 * f, top.dy, top.dx + 0.22 * f, foot.dy);
      canvas.drawRect(
        rod,
        Paint()
          ..shader = const LinearGradient(colors: [Color(0xFF374151), Color(0xFF9CA3AF), Color(0xFF374151)]).createShader(rod),
      );
    } else if (o.dragging) {
      labGroundShadow(canvas, p(0.5, -3.4), 9 * f, 1.2 * f, opacity: 0.22);
    }

    // Body: CylinderGeometry(1.5, 1.2, 6) along +x.
    final body = Path()..addPolygon([p(-4, 1.2), p(2, 1.5), p(2, -1.5), p(-4, -1.2)], true);
    final bodyRect = Rect.fromPoints(p(-4, 1.5), p(2, -1.5));
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(blue, 0.45), blue, labShade(blue, -0.25), labShade(blue, -0.6)],
          stops: const [0, 0.35, 0.7, 1],
        ).createShader(bodyRect),
    );
    canvas.drawOval(Rect.fromCenter(center: p(-4, 0), width: 0.7 * f, height: 2.4 * f), Paint()..color = labShade(blue, -0.45));
    final grip = Paint()
      ..color = labShade(blue, -0.5).withValues(alpha: 0.7)
      ..strokeWidth = math.max(1, 0.18 * f);
    for (final lx in const [-3.3, -2.8, -2.3]) {
      canvas.drawLine(p(lx, 1.24), p(lx, -1.24), grip);
    }
    // Head: CylinderGeometry(2, 1.5, 3), wide end forward.
    final head = Path()..addPolygon([p(2, 1.5), p(5, 2), p(5, -2), p(2, -1.5)], true);
    canvas.drawPath(
      head,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(grey, 0.6), grey, labShade(grey, -0.45)],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromPoints(p(2, 2), p(5, -2))),
    );
    // Lens.
    final lens = Rect.fromCenter(center: p(5, 0), width: 0.9 * f, height: 4 * f);
    if (on) {
      labGlow(canvas, lens.center, 5 * f, const Color(0xFFFFF7CC), intensity: 0.9);
      canvas.drawOval(lens, Paint()..color = const Color(0xFFFFFBEB));
    } else {
      canvas.drawOval(
        lens,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF64748B)],
          ).createShader(lens),
      );
    }
    canvas.drawOval(
      lens,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 0.2 * f)
        ..color = labShade(grey, -0.35),
    );
    // Red switch (pressed down while the torch is ON).
    final sy = scene.torchOn ? 1.4 : 1.6;
    labBox3D(canvas, Rect.fromPoints(p(-1.4, sy + 0.2), p(-0.6, sy - 0.2)), 0.25 * f, const Color(0xFFEF4444));
  }

  // ------------------------------------------------------ opaque object

  void _paintBall(Canvas canvas, _Obj o, bool lit) {
    final s = scene.scaleOf(o);
    final f = _kz(o.z) * s;
    final c = _proj(o.x, o.y, o.z);
    final color = o.id == _Id.redball ? const Color(0xFFEF4444) : const Color(0xFF64748B);
    final resting = !o.dragging && o.tween == null && o.state == 'table' && (o.y - _ballTable.y).abs() < 0.05;
    if (resting) {
      // Holder stand under the object.
      final foot = _proj(o.x, -4, o.z);
      labGroundShadow(canvas, foot, 3.6 * f, 1 * f, opacity: 0.45);
      canvas.drawOval(Rect.fromCenter(center: foot, width: 3 * f, height: 0.85 * f), Paint()..color = const Color(0xFF1F2937));
      final rod = Rect.fromLTRB(c.dx - 0.18 * f, c.dy, c.dx + 0.18 * f, foot.dy);
      canvas.drawRect(
        rod,
        Paint()
          ..shader = const LinearGradient(colors: [Color(0xFF374151), Color(0xFF9CA3AF), Color(0xFF374151)]).createShader(rod),
      );
    } else if (o.dragging) {
      labGroundShadow(canvas, c + Offset(0, 3.8 * f), 3 * f, 0.8 * f, opacity: 0.22);
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-o.rot);
    final rect = Rect.fromCenter(center: Offset.zero, width: 3 * f, height: 6 * f);
    // Highlight faces the torch when it is lit.
    final hx = lit && o.x > _lightPos.x ? -0.6 : -0.35;
    final hy = lit && o.x > _lightPos.x ? -0.15 : -0.4;
    final cr = math.cos(o.rot), sr = math.sin(o.rot);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(hx * cr - hy * sr, hx * sr + hy * cr),
          radius: 1.05,
          colors: [labShade(color, 0.5), color, labShade(color, -0.6)],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    // Dark ring (TorusGeometry) seen edge-on.
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 0.55 * f, height: 6.1 * f),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 0.22 * f)
        ..color = const Color(0xFF333333),
    );
    canvas.restore();
  }

  // ------------------------------------------------------------- labels

  void _paintLabels(Canvas canvas, _Board board) {
    void label(_Obj? o, double offset) {
      if (o == null) return;
      final s = scene.scaleOf(o);
      labPill(canvas, labels[o.id]!, _proj(o.x, o.y + offset * s, o.z), size: 12);
    }

    if (scene.scenario == 0) {
      label(scene.torch, 4);
      label(scene.ball, 4.4);
      labPill(canvas, labels[_Id.screen]!, _projV(board.at(0, board.hh + 2 * board.scale)), size: 12);
    } else {
      label(scene.ball, 5);
      label(scene.redball, 5);
    }
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      _Id.values.any((id) => old.labels[id] != labels[id]);
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
