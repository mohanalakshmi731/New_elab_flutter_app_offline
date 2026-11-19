// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode, mapEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 11 • Activity 5
/// Reflection of Light and Plane Mirror Images.
///
/// Native Flutter port of
/// `Cl7S-Ch11-A5-Reflection_of_Light_and_Plane_Mirror_Images.html`.
/// Scenario 1: drag a torch, a comb (slit) and a plane mirror from the tray
/// onto the paper to make a thin beam and reflect it, then rotate the mirror
/// with a slider. Scenario 2: drop a pen in front of a large mirror, slide it
/// closer / farther to compare object and image distances, swap it for a
/// character and raise its left hand to see lateral inversion.
class Ch11A5ReflectionOfLightAndPlaneMirrorImagesPage extends StatefulWidget {
  const Ch11A5ReflectionOfLightAndPlaneMirrorImagesPage({super.key});

  @override
  State<Ch11A5ReflectionOfLightAndPlaneMirrorImagesPage> createState() =>
      _Ch11A5ReflectionOfLightAndPlaneMirrorImagesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, switchTap 2585.
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
  static const Color teal = Color(0xFF14B8A6);
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

// ============================================================== 3D MATH

const Size _design = Size(1000, 560);

/// Minimal 3D vector in the HTML (Three.js) world coordinates.
@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  static const _V3 zero = _V3(0, 0, 0);

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

  _V3 withY(double v) => _V3(x, v, z);
  _V3 withZ(double v) => _V3(x, y, v);

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Three.js Euler 'XYZ' rotation: v' = Rx · Ry · Rz · v.
_V3 _rotate(_V3 v, _V3 r) {
  var x = v.x, y = v.y, z = v.z;
  if (r.z != 0) {
    final c = math.cos(r.z), s = math.sin(r.z);
    final nx = x * c - y * s;
    y = x * s + y * c;
    x = nx;
  }
  if (r.y != 0) {
    final c = math.cos(r.y), s = math.sin(r.y);
    final nx = x * c + z * s;
    z = -x * s + z * c;
    x = nx;
  }
  if (r.x != 0) {
    final c = math.cos(r.x), s = math.sin(r.x);
    final ny = y * c - z * s;
    z = y * s + z * c;
    y = ny;
  }
  return _V3(x, y, z);
}

/// Position / rotation / uniform scale of a Three.js group.
@immutable
class _Pose {
  const _Pose(this.pos, [this.rot = _V3.zero, this.scale = 1]);
  final _V3 pos;
  final _V3 rot;
  final double scale;

  _V3 apply(_V3 local) => pos + _rotate(local * scale, rot);
  _V3 dir(_V3 local) => _rotate(local, rot);
}

/// Virtual perspective camera (position, look-at target, focal length in
/// design px and the screen point the target projects to).
@immutable
class _Cam {
  const _Cam(this.pos, this.target, this.focal, this.center);
  final _V3 pos;
  final _V3 target;
  final double focal;
  final Offset center;

  static _Cam lerp(_Cam a, _Cam b, double t) => _Cam(
        _V3.lerp(a.pos, b.pos, t),
        _V3.lerp(a.target, b.target, t),
        a.focal + (b.focal - a.focal) * t,
        Offset.lerp(a.center, b.center, t)!,
      );
}

/// Camera basis for one frame: projects world points to design px.
class _View {
  _View(this.cam) {
    f = (cam.target - cam.pos).unit;
    r = f.cross(const _V3(0, 1, 0)).unit;
    u = r.cross(f);
  }

  final _Cam cam;
  late final _V3 f, r, u;

  double depth(_V3 p) => math.max((p - cam.pos).dot(f), 0.5);

  Offset project(_V3 p) {
    final v = p - cam.pos;
    final zc = math.max(v.dot(f), 0.5);
    return cam.center + Offset(v.dot(r) / zc * cam.focal, -v.dot(u) / zc * cam.focal);
  }

  /// Design px per world unit at [p].
  double scaleAt(_V3 p) => cam.focal / depth(p);

  /// Facing test: true when a surface at [p] with normal [n] faces the camera.
  bool faces(_V3 p, _V3 n) => n.dot(cam.pos - p) > 0;

  /// Intersects the camera ray through screen point [s] with the plane
  /// `y = h` (the HTML horizontal drag plane).
  _V3? onPlaneY(Offset s, double h) {
    final d = f + r * ((s.dx - cam.center.dx) / cam.focal) + u * (-(s.dy - cam.center.dy) / cam.focal);
    if (d.y.abs() < 1e-6) return null;
    final t = (h - cam.pos.y) / d.y;
    if (t <= 0) return null;
    return cam.pos + d * t;
  }
}

// Camera presets (HTML camera positions; focal / centre chosen so the
// scene fits the 1000x560 stage clear of the HUD and tool column).
const _Cam _camS1 = _Cam(_V3(0, 30, 30), _V3(0, -2, 0), 860, Offset(500, 282));
const _Cam _camS2Start = _Cam(_V3(0, 18, 32), _V3(0, 0, 5), 560, Offset(500, 318));
const _Cam _camS2 = _Cam(_V3(0, 22, 35), _V3(0, 0, 5), 560, Offset(500, 318));
const _Cam _camS2Person = _Cam(_V3(0, 15, 30), _V3(0, 4, -2), 640, Offset(500, 270));

// ============================================================== MODEL

/// Height of the light beam above the paper (torch axis).
const double _beamY = 0.7;

/// Scenario 1 drop zones (HTML `State.dropZones`, half sizes 3.5 x 3.5).
const Map<_Id, _V3> _zones = {
  _Id.torch: _V3(-12, _beamY, 0),
  _Id.comb: _V3(-2, 0, 0),
  _Id.mirror: _V3(8, 0, 0),
};
const double _zoneHalf = 3.5;

/// Scenario 2 mirror plane and drop grid (HTML `dropZones.grid`).
const double _mirrorZ = -5;
const double _gridMinX = -10, _gridMaxX = 10, _gridMinZ = 0, _gridMaxZ = 15;
const _V3 _penTarget = _V3(0, 0.2, 10);
const _V3 _personPos = _V3(0, 0, 10);

/// Tray tilt (HTML `rotation.x = Math.PI / 6`).
const _V3 _trayRot = _V3(math.pi / 6, 0, 0);

/// In the tray the comb lies across (teeth in a row) and the mirror shows
/// its glass to the viewer, so both are recognisable before they are used.
const _V3 _combTrayRot = _V3(-math.pi / 6, math.pi / 2, 0);
const _V3 _mirrorTrayRot = _V3(-math.pi / 6, math.pi / 2, 0);

enum _Id { torch, comb, mirror, pen }

class _Tween {
  _Tween({
    required this.fromPos,
    required this.toPos,
    required this.fromRot,
    required this.toRot,
    required this.start,
    required this.duration,
    required this.curve,
    this.onDone,
  });

  final _V3 fromPos, toPos, fromRot, toRot;
  final double start;
  final double duration;
  final Curve curve;
  final VoidCallback? onDone;
}

/// One draggable Three.js group.
class _Obj {
  _Obj(this.id, {required this.step, required this.home, this.homeRot = _trayRot})
      : pos = home,
        rot = homeRot;

  final _Id id;

  /// HTML `userData.step`: the step in which the object is used.
  final int step;
  final _V3 home;
  final _V3 homeRot;
  _V3 pos;
  _V3 rot;
  bool draggable = false;
  bool dragging = false;
  bool placed = false;
  bool visible = true;
  _Tween? tween;
}

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  final Map<_Id, _Obj> objects = {};
  _Cam cam = _camS1;

  // Scenario 1.
  bool torchOn = false;
  double mirrorExtraDeg = 0;

  // Scenario 2.
  bool penReflVisible = false;
  bool personVisible = false;
  bool penMoved = false;

  /// Arm raise progress (0..1, overshoots with Back.Out).
  double armRaise = 0;
  bool armLabels = false;

  _Obj? get torch => objects[_Id.torch];
  _Obj? get comb => objects[_Id.comb];
  _Obj? get mirror => objects[_Id.mirror];
  _Obj? get pen => objects[_Id.pen];

  /// Objects for later steps are faded (HTML opacity 0.3).
  double opacityOf(_Obj o) => o.step > step ? 0.3 : 1;

  /// HTML pulse tween (1 → 1.1 yoyo, 500 ms) for the current target and
  /// the 1.2 lift while dragging.
  double scaleOf(_Obj o) {
    if (o.dragging) return 1.2;
    if (o.step == step && o.draggable && !o.placed && o.tween == null) {
      return 1 + 0.1 * (0.5 - 0.5 * math.cos(time * math.pi * 2));
    }
    return 1;
  }

  _Pose poseOf(_Obj o) => _Pose(o.pos, o.rot, scaleOf(o));

  /// Image of the pen (HTML `penRefl`): same x / y, mirrored z, unrotated.
  _V3 get penImage {
    final p = pen!.pos;
    return _V3(p.x, p.y, _mirrorZ - (p.z - _mirrorZ));
  }

  _V3 get personImage => _V3(_personPos.x, _personPos.y, _mirrorZ - (_personPos.z - _mirrorZ));
}

// ============================================================ GESTURES

/// Claims a pointer immediately (no slop) when it lands on a draggable
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
  String get debugDescription => 'reflection lab object drag';
}

// ============================================================== STATE

class _Ch11A5ReflectionOfLightAndPlaneMirrorImagesPageState
    extends State<Ch11A5ReflectionOfLightAndPlaneMirrorImagesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;
  late final AnimationController _bounce;

  /// HTML `#drag-instruction` (text key, or null when hidden).
  String? _hintKey = 'drag_drop_hint';

  // HTML `State.activeDraggable` / `dragOffset` / drag plane height.
  _Obj? _active;
  bool _zOnly = false;
  double _dragPlaneY = 0;
  _V3 _dragOff = _V3.zero;

  // HTML `State.hasRotated` / `State.hasMovedS2` and button states.
  bool _hasRotated = false;
  bool _rotChanged = false;
  bool _swapped = false;
  bool _raised = false;

  // Virtual camera tween (HTML TWEEN on camera.position / controls.target).
  _Cam _camFrom = _camS1, _camTo = _camS1;
  double _camStart = -1, _camDur = 1;

  /// Start time of the "Raise Left Hand" arm tween (-1 = not started).
  double _armStart = -1;

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
      o
        ..pos = _V3.lerp(tw.fromPos, tw.toPos, v)
        ..rot = _V3.lerp(tw.fromRot, tw.toRot, v);
      if (p >= 1) {
        o
          ..pos = tw.toPos
          ..rot = tw.toRot
          ..tween = null;
        if (tw.onDone != null) done.add(tw.onDone!);
      }
    }
    if (_camStart >= 0) {
      if (_camStart > now) _camStart = now;
      final p = ((now - _camStart) / _camDur).clamp(0.0, 1.0);
      _scene.cam = _Cam.lerp(_camFrom, _camTo, Curves.easeOutCubic.transform(p));
      if (p >= 1) _camStart = -1;
    }
    if (_armStart >= 0) {
      if (_armStart > now) _armStart = now;
      final p = ((now - _armStart) / 0.8).clamp(0.0, 1.0);
      _scene.armRaise = Curves.easeOutBack.transform(p);
      if (p >= 1) _armStart = -1;
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

  /// TWEEN.js position + rotation tween of a group.
  void _tweenTo(_Obj o, _V3 pos, _V3 rot, int ms, Curve curve, [VoidCallback? onDone]) {
    o.tween = _Tween(
      fromPos: o.pos,
      toPos: pos,
      fromRot: o.rot,
      toRot: rot,
      start: _scene.time,
      duration: ms / 1000,
      curve: curve,
      onDone: onDone,
    );
  }

  /// HTML camera tween (`TWEEN.Tween(camera.position)` + controls.target).
  void _moveCamera(_Cam to, {int ms = 1000}) {
    _camFrom = _scene.cam;
    _camTo = to;
    _camDur = ms / 1000;
    _camStart = _scene.time;
  }

  // ------------------------------------------------------------- build

  /// HTML `buildScenario()` (clearScene + buildScenarioN + availability)
  /// plus the per-scenario resets done in `resetApp`.
  void _buildScenario() {
    _lab.cancelPending();
    _active = null;
    _zOnly = false;
    _hintKey = 'drag_drop_hint';
    _hasRotated = false;
    _rotChanged = false;
    _swapped = false;
    _raised = false;
    _armStart = -1;
    _camStart = -1;
    _scene
      ..objects.clear()
      ..torchOn = false
      ..mirrorExtraDeg = 0
      ..penReflVisible = false
      ..personVisible = false
      ..penMoved = false
      ..armRaise = 0
      ..armLabels = false;
    if (_scenario == 0) {
      _scene.cam = _camS1;
      // Items rest on the front tray (lifted so their tilt clears it).
      _scene.objects
        ..[_Id.torch] = _Obj(_Id.torch, step: 1, home: const _V3(-10, _beamY, 12))
        ..[_Id.comb] = _Obj(_Id.comb, step: 2, home: const _V3(0, 0.2, 12), homeRot: _combTrayRot)
        ..[_Id.mirror] = _Obj(_Id.mirror, step: 3, home: const _V3(10, 0.3, 12), homeRot: _mirrorTrayRot);
    } else {
      // resetApp(true) -> setCameraView('reset') glides from the build camera.
      _scene.cam = _camS2Start;
      _moveCamera(_camS2);
      _scene.objects[_Id.pen] = _Obj(_Id.pen, step: 1, home: const _V3(0, 0.2, 16));
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
      _buildScenario();
    });
  }

  // ------------------------------------------------------------- logic

  /// HTML `updateObjectAvailability()`.
  void _updateAvailability() {
    for (final o in _scene.objects.values) {
      if (o.step > _step) {
        o.draggable = false;
      } else if (o.step == _step) {
        o.draggable = !o.placed;
      } else {
        // Scenario 2, step 2: the pen can slide along the grid (z only).
        o.draggable = _scenario == 1 && _step == 2 && o.id == _Id.pen;
      }
    }
  }

  /// HTML `advanceStep()`: the last step waits for the slider / buttons.
  void _advanceStep() {
    if (_step < _data.steps.length) {
      _scene.step++;
      _updateAvailability();
    }
  }

  void _showConclusion() {
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_scenario + 1}'),
    );
  }

  /// HTML drag-instruction overlay with a new text, hidden after [ms].
  void _showHint(String key, int ms) {
    _hintKey = key;
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted || _hintKey != key) return;
      setState(() => _hintKey = null);
    });
  }

  /// HTML `checkDrop(obj)`.
  void _checkDrop(_Obj o) {
    var success = false;
    var target = o.pos;
    var targetRot = _V3.zero;
    if (_scenario == 0) {
      final dz = _zones[o.id];
      if (dz != null && (o.pos.x - dz.x).abs() < _zoneHalf && (o.pos.z - dz.z).abs() < _zoneHalf) {
        success = true;
        target = dz;
        // Mirror stands upright, turned 45° to bounce the beam.
        if (o.id == _Id.mirror) targetRot = const _V3(0, -math.pi / 4, 0);
      }
    } else {
      final p = o.pos;
      if (p.x > _gridMinX && p.x < _gridMaxX && p.z > _gridMinZ && p.z < _gridMaxZ) {
        success = true;
        target = _penTarget;
      }
    }

    if (success) {
      _lab.showToast(_t('sci_conclusion'));
      o
        ..draggable = false
        ..placed = true;
      _tweenTo(o, target, targetRot, 400, Curves.easeOutCubic, () {
        if (_scenario == 0) {
          if (o.id == _Id.torch) {
            _scene.torchOn = true; // bulb lights up, point light on
            _Audio.play(_Sound.switchTap);
          }
          _advanceStep();
        } else {
          _scene.penReflVisible = true;
          _advanceStep();
          _showHint('drag_closer_farther', 3000);
        }
      });
    } else {
      _lab.showToast(_t('msg_wrong_drop'), isError: true);
      _tweenTo(o, o.home, o.homeRot, 500, Curves.elasticOut, _updateAvailability);
    }
  }

  /// HTML `rotateMirror(val)` (slider input).
  void _rotateMirror(double deg) {
    if (_scenario != 0 || _step < 4) return;
    final v = deg.roundToDouble();
    setState(() {
      if (v != _scene.mirrorExtraDeg) _rotChanged = true;
      _scene.mirrorExtraDeg = v;
      _scene.mirror!.rot = _V3(0, -math.pi / 4 + v * math.pi / 180, 0);
    });
  }

  /// HTML `checkRotationComplete()` (slider change).
  void _rotationEnd(double _) {
    if (!_rotChanged || _hasRotated) return;
    _hasRotated = true;
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _showConclusion();
    });
  }

  /// HTML `swapObject()`.
  void _swapObject() {
    if (_swapped || _scenario != 1 || _step != 3) return;
    setState(() {
      _swapped = true;
      _scene.pen!.visible = false;
      _scene
        ..penReflVisible = false
        ..personVisible = true;
    });
    // Re-centre the camera on the character and its image.
    _moveCamera(_camS2Person);
    _lab.after(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(_advanceStep);
    });
  }

  /// HTML `raiseLeftHand()`.
  void _raiseLeftHand() {
    if (_raised || _scenario != 1 || _step != 4) return;
    setState(() {
      _raised = true;
      _scene.armLabels = true;
    });
    _armStart = _scene.time;
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _showConclusion();
    });
  }

  // ------------------------------------------------------- interaction

  /// Raycaster stand-in: the draggable object under [p] (design px).
  _Obj? _hit(Offset p) {
    final view = _View(_scene.cam);
    _Obj? best;
    var bestD = double.infinity;
    for (final o in _scene.objects.values) {
      if (!o.visible || !o.draggable || o.tween != null) continue;
      final r = _objectBounds(view, _scene, o);
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

  /// HTML `pointerdown`: grab on a horizontal plane at the object height.
  void _pointerDown(Offset p) {
    final o = _hit(p);
    if (o == null) return;
    final hit = _View(_scene.cam).onPlaneY(p, o.pos.y);
    setState(() {
      _active = o;
      _hintKey = null;
      _zOnly = _scenario == 1 && _step == 2 && o.id == _Id.pen;
      _dragPlaneY = o.pos.y;
      _dragOff = hit == null ? _V3.zero : (hit - o.pos).withY(0);
      o.dragging = true;
    });
    _Audio.play(_Sound.pickup);
  }

  /// HTML `pointermove`.
  void _pointerMove(Offset p) {
    final o = _active;
    if (o == null) return;
    final hit = _View(_scene.cam).onPlaneY(p, _dragPlaneY);
    if (hit == null) return;
    if (_zOnly) {
      // Scenario 2, step 2: x locked, only towards / away from the mirror.
      final z = (hit.z - _dragOff.z).clamp(0.0, 20.0);
      setState(() {
        o.pos = o.pos.withZ(z);
        if (!_scene.penMoved && (z - 10).abs() > 4) {
          _scene.penMoved = true;
          _lab.after(const Duration(milliseconds: 1000), () {
            if (!mounted || _scenario != 1 || _step != 2) return;
            setState(_advanceStep);
          });
        }
      });
    } else {
      o.pos = _V3(
        (hit.x - _dragOff.x).clamp(-30.0, 30.0),
        _dragPlaneY,
        (hit.z - _dragOff.z).clamp(-25.0, 30.0),
      );
    }
  }

  /// HTML `pointerup`.
  void _pointerUp() {
    final o = _active;
    if (o == null) return;
    setState(() {
      _active = null;
      o.dragging = false;
      if (_zOnly) {
        _zOnly = false; // just stop dragging, no drop check
        return;
      }
      _checkDrop(o);
    });
  }

  /// The HTML `#s2-ui` buttons (Swap Object / Raise Left Hand).
  List<LabAction> _actions() {
    if (_scenario == 1 && _step == 3 && !_swapped) {
      return [
        LabAction(
          label: _t('btn_swap'),
          icon: Icons.swap_horiz,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _swapObject,
        ),
      ];
    }
    if (_scenario == 1 && _step == 4 && !_raised) {
      return [
        LabAction(
          label: _t('btn_raise'),
          icon: Icons.waving_hand,
          color: const Color(0xFF059669),
          foreground: Colors.white,
          highlight: true,
          onTap: _raiseLeftHand,
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
        return LabShell(
          controller: _lab,
          icon: Icons.join_inner,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          sidebarExtraTitle: _t('readings'),
          sidebarExtra: _readings(p, s),
          onReset: _fullReset,
          overlays: [
            if (_scenario == 0 && _step >= 4 && _lab.isLabActive) _rotationOverlay(p, s, inset),
            if (_hintKey != null && _lab.isLabActive) _hintOverlay(s, inset),
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
                painter: _ReflectionPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  labels: {
                    'torch': _t('obj_torch'),
                    'comb': _t('obj_comb'),
                    'mirror': _t('obj_mirror'),
                    'pen': _t('obj_pen'),
                    'left': _t('lbl_left'),
                    'right': _t('lbl_right'),
                    'dist': _t('dist_value'),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar readouts (light state / mirror angle, object & image distance).
  Widget _readings(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final dash = _t('dash');
    final rows = <Widget>[];
    if (_scenario == 0) {
      final light = !_scene.torchOn
          ? 'beam_off'
          : (_step <= 2 ? 'beam_wide' : (_step == 3 ? 'beam_thin' : 'beam_reflected'));
      rows.addAll([
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('beam_state'),
          value: _t(light),
          valueColor: _scene.torchOn ? const Color(0xFFF59E0B) : null,
        ),
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('mirror_rotation'),
          value: _step >= 4 ? labFormat(_t('deg_value'), {'d': _signed(_scene.mirrorExtraDeg)}) : dash,
        ),
      ]);
    } else {
      double? d;
      if (_scene.personVisible) {
        d = _personPos.z - _mirrorZ;
      } else if (_scene.penReflVisible) {
        d = _scene.pen!.pos.z - _mirrorZ;
      }
      final v = d == null ? dash : labFormat(_t('dist_value'), {'d': d.toStringAsFixed(1)});
      rows.addAll([
        LabInfoRow(palette: p, scale: f, label: _t('obj_dist'), value: v, valueColor: _Colors.blue),
        LabInfoRow(palette: p, scale: f, label: _t('img_dist'), value: v, valueColor: _Colors.teal),
        LabInfoRow(palette: p, scale: f, label: _t('size_label'), value: d == null ? dash : _t('size_same')),
      ]);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  static String _signed(double v) => v > 0 ? '+${v.round()}' : '${v.round()}';

  /// HTML `#rotation-slider-container` (scenario 1, step 4).
  Widget _rotationOverlay(LabPalette p, double s, EdgeInsets inset) {
    final muted = p.textMuted;
    // Above the HUD chip (shown while the sidebar is open).
    final bottom = inset.bottom + (_lab.isSidebarOpen ? 62 * s : 0);
    return Positioned(
      bottom: bottom,
      left: inset.left,
      right: inset.right,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(offset: Offset(0, 20 * s * (1 - v)), child: child),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400 * s),
            child: LabGlassCard(
              palette: p,
              padding: EdgeInsets.fromLTRB(12 * s, 3 * s, 10 * s, 3 * s),
              borderColor: _Colors.zslYellow.withValues(alpha: 0.6),
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      _t('rotate_mirror'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12 * s),
                    ),
                  ),
                  SizedBox(width: 6 * s),
                  Icon(Icons.rotate_left, size: 16 * s, color: muted),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 30 * s,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4 * s,
                          activeTrackColor: _Colors.zslYellow,
                          inactiveTrackColor: p.cardBorder,
                          thumbColor: _Colors.zslYellow,
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 13 * s),
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8 * s),
                        ),
                        child: Slider(
                          value: _scene.mirrorExtraDeg,
                          min: -45,
                          max: 45,
                          divisions: 90,
                          onChanged: _rotateMirror,
                          onChangeEnd: _rotationEnd,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.rotate_right, size: 16 * s, color: muted),
                  SizedBox(width: 6 * s),
                  SizedBox(
                    width: 38 * s,
                    child: Text(
                      labFormat(_t('deg_value'), {'d': _signed(_scene.mirrorExtraDeg)}),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: TextStyle(
                        color: _Colors.zslYellow,
                        fontWeight: FontWeight.w800,
                        fontSize: 12 * s,
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

  /// HTML `#drag-instruction`: bouncing hand + hint in the middle of the
  /// canvas until an object is grabbed.
  Widget _hintOverlay(double s, EdgeInsets inset) {
    return Positioned.fill(
      left: inset.left,
      right: inset.right,
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.12),
          child: AnimatedBuilder(
            animation: _bounce,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -12 * s * math.sin(_bounce.value * math.pi).abs()),
              child: child,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * s),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 34 * s,
                      color: Colors.white,
                      shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    SizedBox(height: 4 * s),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
                      decoration: BoxDecoration(
                        color: _Colors.slate900.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _Colors.slate700.withValues(alpha: 0.5)),
                        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8)],
                      ),
                      child: Text(
                        _t(_hintKey!),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13 * s),
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

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Reflection of Light and Plane Mirror Images',
    'app_subtitle': 'Class 7 • Light: Shadows and Reflections',
    'scen_1_opt': 'Scenario 1: The Bouncing Beam',
    'scen_2_opt': "Scenario 2: The Mirror's Twin",
    'sci_conclusion': 'Success!',
    'drag_drop_hint': 'Drag & Drop objects to explore!',
    'drag_closer_farther': 'Drag the object closer to or farther from the mirror.',
    'rotate_mirror': 'Rotate Mirror',
    'btn_swap': 'Swap Object',
    'btn_raise': 'Raise Left Hand',
    'lbl_left': 'LEFT',
    'lbl_right': 'RIGHT',
    'msg_wrong_drop': 'Please place the object in the designated area.',
    'conclusion_1':
        'When light falls on a shiny surface like a mirror, its direction changes. This bouncing back of light is called reflection. The angle at which the light hits the mirror determines the angle at which it bounces off.',
    'conclusion_2':
        'An image formed by a plane mirror is always erect (upright), of the same size as the object, and appears at the same distance behind the mirror as the object is in front of it. It also shows lateral inversion (left appears right).',
    'obj_torch': 'Torch',
    'obj_comb': 'Comb',
    'obj_mirror': 'Mirror',
    'obj_pen': 'Pen',
    'obj_person': 'Person',
    // Readouts added to the sidebar (not in the HTML).
    'readings': 'Live Readings',
    'mirror_rotation': 'Mirror rotation',
    'beam_state': 'Light',
    'beam_off': 'Torch not placed',
    'beam_wide': 'Spreading over a wide area',
    'beam_thin': 'Thin straight beam',
    'beam_reflected': 'Reflected by the mirror',
    'obj_dist': 'Object distance from mirror',
    'img_dist': 'Image distance from mirror',
    'size_label': 'Image size',
    'size_same': 'Same as object',
    'dist_value': '{d} cm',
    'deg_value': '{d}°',
    'dash': '—',
  },
  'hi': {
    'app_title': 'प्रकाश का परावर्तन',
    'app_subtitle': 'कक्षा 7 • समतल दर्पण प्रतिबिंब',
    'scen_1_opt': 'परिदृश्य 1: उछलती हुई किरण',
    'scen_2_opt': 'परिदृश्य 2: दर्पण का जुड़वां',
    'sci_conclusion': 'सफलता!',
    'drag_drop_hint': 'अन्वेषण करने के लिए वस्तुओं को खींचें और छोड़ें!',
    'drag_closer_farther': 'वस्तु को दर्पण के करीब या दूर खींचें।',
    'rotate_mirror': 'दर्पण घुमाएं',
    'btn_swap': 'वस्तु बदलें',
    'btn_raise': 'बायां हाथ उठाएं',
    'lbl_left': 'बायां (LEFT)',
    'lbl_right': 'दायां (RIGHT)',
    'msg_wrong_drop': 'कृपया वस्तु को निर्दिष्ट स्थान पर रखें।',
    'conclusion_1':
        'जब प्रकाश दर्पण जैसी चमकदार सतह पर पड़ता है, तो उसकी दिशा बदल जाती है। प्रकाश के इस वापस लौटने को परावर्तन कहते हैं। जिस कोण पर प्रकाश दर्पण से टकराता है, वह उस कोण को निर्धारित करता है जिस पर वह वापस उछलता है।',
    'conclusion_2':
        'समतल दर्पण द्वारा बना प्रतिबिंब हमेशा सीधा (erect) होता है, वस्तु के समान आकार का होता है, और दर्पण के पीछे उतनी ही दूरी पर दिखाई देता है जितनी दूरी पर वस्तु उसके सामने होती है। यह पार्श्व व्युत्क्रमण (lateral inversion) भी दर्शाता है (बायां दायां दिखाई देता है)।',
    'obj_torch': 'टॉर्च',
    'obj_comb': 'कंघी',
    'obj_mirror': 'दर्पण',
    'obj_pen': 'कलम',
    'obj_person': 'व्यक्ति',
    'readings': 'लाइव माप',
    'mirror_rotation': 'दर्पण का घुमाव',
    'beam_state': 'प्रकाश',
    'beam_off': 'टॉर्च नहीं रखी गई',
    'beam_wide': 'विस्तृत क्षेत्र में फैल रहा है',
    'beam_thin': 'पतली सीधी किरण',
    'beam_reflected': 'दर्पण द्वारा परावर्तित',
    'obj_dist': 'दर्पण से वस्तु की दूरी',
    'img_dist': 'दर्पण से प्रतिबिंब की दूरी',
    'size_label': 'प्रतिबिंब का आकार',
    'size_same': 'वस्तु के समान',
    'dist_value': '{d} सेमी',
    'deg_value': '{d}°',
    'dash': '—',
  },
};

// ========================================================== SCENARIOS

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually demonstrate that a plane mirror changes the direction of a light beam that falls on it.',
      steps: [
        LabStep(
          concept: 'Light Source',
          action: 'DRAG the Torch from the tray and DROP it onto the white paper.',
          observation: 'The torch turns on, emitting light over a wide area.',
        ),
        LabStep(
          concept: 'Creating a Beam',
          action: 'DRAG the Comb and DROP it in front of the torch.',
          observation:
              'The comb acts as a slit, allowing only a thin, straight beam of light to pass through.',
        ),
        LabStep(
          concept: 'Reflection of Light',
          action: 'DRAG the Plane Mirror and DROP it in the path of the light beam.',
          observation:
              'The light beam hits the mirror and changes direction instantly. This is reflection.',
        ),
        LabStep(
          concept: 'Angle of Reflection',
          action: 'USE the slider to rotate the mirror and observe the reflected beam.',
          observation:
              'Changing the angle of the mirror changes the direction of the reflected light beam.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To investigate the properties of an image formed by a plane mirror (size, distance, and lateral inversion).',
      steps: [
        LabStep(
          concept: 'Image Formation',
          action: 'DRAG the Pen and DROP it on the grid in front of the mirror.',
          observation:
              'An identical image of the pen appears behind the mirror. The image is upright and the same size.',
        ),
        LabStep(
          concept: 'Object & Image Distance',
          action: 'DRAG the pen closer to and farther away from the mirror along the grid.',
          observation:
              "The image's distance from the mirror is always equal to the object's distance from the mirror.",
        ),
        LabStep(
          concept: 'Testing Asymmetry',
          action: "CLICK the 'Swap Object' button to replace the pen with a character model.",
          observation: "The pen is replaced. The character's image also appears in the mirror.",
        ),
        LabStep(
          concept: 'Lateral Inversion',
          action: "CLICK the 'Raise Left Hand' button on the screen.",
          observation:
              'The real character raises its left hand. The image in the mirror raises its right hand (Lateral Inversion).',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'यह प्रदर्शित करना कि समतल दर्पण उस पर पड़ने वाले प्रकाश पुंज की दिशा बदल देता है।',
      steps: [
        LabStep(
          concept: 'प्रकाश स्रोत',
          action: 'ट्रे से टॉर्च खींचें और इसे सफेद कागज पर छोड़ दें।',
          observation: 'टॉर्च चालू हो जाती है, जिससे एक विस्तृत क्षेत्र में प्रकाश फैलता है।',
        ),
        LabStep(
          concept: 'किरण (Beam) बनाना',
          action: 'कंघी को खींचें और टॉर्च के सामने छोड़ दें।',
          observation:
              'कंघी एक स्लिट के रूप में कार्य करती है, जिससे केवल एक पतली, सीधी प्रकाश किरण गुजर पाती है।',
        ),
        LabStep(
          concept: 'प्रकाश का परावर्तन',
          action: 'समतल दर्पण को खींचें और प्रकाश किरण के पथ में छोड़ दें।',
          observation: 'प्रकाश किरण दर्पण से टकराती है और तुरंत दिशा बदल लेती है। इसे परावर्तन कहते हैं।',
        ),
        LabStep(
          concept: 'परावर्तन कोण',
          action: 'दर्पण को घुमाने के लिए स्लाइडर का उपयोग करें और परावर्तित किरण का निरीक्षण करें।',
          observation: 'दर्पण के कोण को बदलने से परावर्तित प्रकाश किरण की दिशा भी बदल जाती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'समतल दर्पण द्वारा बने प्रतिबिंब के गुणों (आकार, दूरी और पार्श्व व्युत्क्रमण) की जांच करना।',
      steps: [
        LabStep(
          concept: 'प्रतिबिंब निर्माण',
          action: 'कलम को खींचें और दर्पण के सामने ग्रिड पर छोड़ दें।',
          observation:
              'दर्पण के पीछे कलम का एक समान प्रतिबिंब दिखाई देता है। प्रतिबिंब सीधा और समान आकार का है।',
        ),
        LabStep(
          concept: 'वस्तु और प्रतिबिंब की दूरी',
          action: 'कलम को ग्रिड के साथ दर्पण के करीब और दूर खींचें।',
          observation: 'दर्पण से प्रतिबिंब की दूरी हमेशा दर्पण से वस्तु की दूरी के बराबर होती है।',
        ),
        LabStep(
          concept: 'असममिति का परीक्षण',
          action: "कलम को एक चरित्र मॉडल से बदलने के लिए 'Swap Object' (वस्तु बदलें) बटन पर क्लिक करें।",
          observation: 'कलम बदल दी जाती है। दर्पण में चरित्र का प्रतिबिंब भी दिखाई देता है।',
        ),
        LabStep(
          concept: 'पार्श्व व्युत्क्रमण (Lateral Inversion)',
          action: "स्क्रीन पर 'Raise Left Hand' (बायां हाथ उठाएं) बटन पर क्लिक करें।",
          observation:
              'असली चरित्र अपना बायां हाथ उठाता है। दर्पण में प्रतिबिंब अपना दायां हाथ उठाता है (पार्श्व व्युत्क्रमण)।',
        ),
      ],
    ),
  ],
};

// ============================================================ GEOMETRY

/// Local bounding boxes (min, max) of each draggable group.
const Map<_Id, (_V3, _V3)> _localBounds = {
  _Id.torch: (_V3(-3.2, -0.75, -0.75), _V3(1.75, 0.75, 0.75)),
  _Id.comb: (_V3(-0.25, 0, -2.5), _V3(0.25, 2, 2.5)),
  _Id.mirror: (_V3(-0.2, 0, -1), _V3(1, 3, 1)),
  _Id.pen: (_V3(-2, -0.25, -0.25), _V3(2.8, 0.25, 0.25)),
};

/// Design-space hit box of an object (used for drag picking).
Rect _objectBounds(_View v, _Scene scene, _Obj o) {
  final pose = scene.poseOf(o);
  final (a, b) = _localBounds[o.id]!;
  var l = double.infinity, t = double.infinity, r = -double.infinity, bt = -double.infinity;
  for (var i = 0; i < 8; i++) {
    final p = v.project(pose.apply(_V3(
      (i & 1) == 1 ? b.x : a.x,
      (i & 2) == 2 ? b.y : a.y,
      (i & 4) == 4 ? b.z : a.z,
    )));
    l = math.min(l, p.dx);
    t = math.min(t, p.dy);
    r = math.max(r, p.dx);
    bt = math.max(bt, p.dy);
  }
  final rect = Rect.fromLTRB(l, t, r, bt);
  return Rect.fromCenter(
    center: rect.center,
    width: math.max(rect.width, 64),
    height: math.max(rect.height, 64),
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

/// Key light (the HTML fill / tray directional lights, from above-front).
final _V3 _light = const _V3(0.35, 0.85, 0.55).unit;

Color _alpha(Color c, double opacity) => c.withValues(alpha: c.a * opacity);

/// Lambert-ish flat shading of a face with world normal [n].
Color _lit(Color base, _V3 n, {double opacity = 1}) {
  final k = n.unit.dot(_light);
  final c = labShade(base, k >= 0 ? k * 0.24 - 0.08 : k * 0.4 - 0.08);
  return _alpha(c, opacity);
}

Path _poly(List<Offset> pts) => Path()..addPolygon(pts, true);

// ========================================================== PRIMITIVES

/// Box faces: corner indices (bit 0 = x, bit 1 = y, bit 2 = z) and the
/// local outward normal.
const List<(List<int>, _V3)> _boxFaces = [
  ([1, 3, 7, 5], _V3(1, 0, 0)),
  ([0, 4, 6, 2], _V3(-1, 0, 0)),
  ([2, 6, 7, 3], _V3(0, 1, 0)),
  ([0, 1, 5, 4], _V3(0, -1, 0)),
  ([4, 5, 7, 6], _V3(0, 0, 1)),
  ([0, 2, 3, 1], _V3(0, 0, -1)),
];

/// Three.js BoxGeometry [size] centred at local [c] of [pose]: draws the
/// faces that look at the camera with flat shading and thin edges.
void _box(
  Canvas canvas,
  _View v,
  _Pose pose,
  _V3 c,
  _V3 size,
  Color color, {
  double opacity = 1,
  Color? edge,
}) {
  final h = size * 0.5;
  final w = List<_V3>.generate(
    8,
    (i) => pose.apply(_V3(
      c.x + ((i & 1) == 1 ? h.x : -h.x),
      c.y + ((i & 2) == 2 ? h.y : -h.y),
      c.z + ((i & 4) == 4 ? h.z : -h.z),
    )),
  );
  final pts = w.map(v.project).toList();
  final edgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.9
    ..strokeJoin = StrokeJoin.round
    ..color = _alpha(edge ?? labShade(color, -0.45).withValues(alpha: 0.45), opacity);
  for (final (idx, ln) in _boxFaces) {
    final n = pose.dir(ln);
    final fc = (w[idx[0]] + w[idx[2]]) * 0.5;
    if (!v.faces(fc, n)) continue;
    final path = _poly([for (final i in idx) pts[i]]);
    canvas.drawPath(path, Paint()..color = _lit(color, n, opacity: opacity));
    canvas.drawPath(path, edgePaint);
  }
}

/// Cylinder / cone between world points [a] and [b] (radii [ra], [rb]),
/// shaded across its projected axis, with the visible end caps.
void _cylinder(
  Canvas canvas,
  _View v,
  _V3 a,
  _V3 b,
  double ra,
  double rb,
  Color color, {
  double opacity = 1,
  Color? capA,
  Color? capB,
  int seg = 20,
}) {
  final axis = b - a;
  final len = axis.length;
  if (len < 1e-6) return;
  final wv = axis * (1 / len);
  final helper = wv.y.abs() < 0.9 ? const _V3(0, 1, 0) : const _V3(1, 0, 0);
  final e1 = wv.cross(helper).unit;
  final e2 = wv.cross(e1).unit;
  List<Offset> ring(_V3 c, double r) => [
        for (var i = 0; i < seg; i++)
          v.project(c + e1 * (r * math.cos(2 * math.pi * i / seg)) + e2 * (r * math.sin(2 * math.pi * i / seg))),
      ];
  final ringA = ra > 0 ? ring(a, ra) : [v.project(a)];
  final ringB = rb > 0 ? ring(b, rb) : [v.project(b)];
  final hull = _hull([...ringA, ...ringB]);
  final pa = v.project(a), pb = v.project(b);
  var dir = pb - pa;
  if (dir.distance < 1e-3) dir = const Offset(1, 0);
  var n = Offset(-dir.dy, dir.dx) / dir.distance;
  // Lit side towards the upper left of the screen.
  if (n.dx * -0.45 + n.dy * -0.9 < 0) n = -n;
  final mid = (pa + pb) / 2;
  final hw = math.max(ra * v.scaleAt(a), rb * v.scaleAt(b)) + 1;
  canvas.drawPath(
    _poly(hull),
    Paint()
      ..shader = ui.Gradient.linear(
        mid + n * hw,
        mid - n * hw,
        [
          _alpha(labShade(color, 0.38), opacity),
          _alpha(labShade(color, 0.12), opacity),
          _alpha(color, opacity),
          _alpha(labShade(color, -0.3), opacity),
          _alpha(labShade(color, -0.55), opacity),
        ],
        const [0, 0.22, 0.5, 0.8, 1],
      ),
  );
  final capPaint = Paint();
  if (rb > 0 && v.faces(b, wv)) {
    canvas.drawPath(_poly(ringB), capPaint..color = _alpha(capB ?? labShade(color, 0.15), opacity));
  }
  if (ra > 0 && v.faces(a, wv * -1)) {
    canvas.drawPath(_poly(ringA), capPaint..color = _alpha(capA ?? labShade(color, 0.15), opacity));
  }
}

/// Flat polygon lying in the world (paper, tray tops, rings...).
Path _worldPoly(_View v, List<_V3> pts) => _poly(pts.map(v.project).toList());

/// Circle of radius [r] on the horizontal plane through [c].
List<Offset> _floorCircle(_View v, _V3 c, double r, {int n = 48}) => [
      for (var i = 0; i < n; i++)
        v.project(_V3(c.x + r * math.cos(2 * math.pi * i / n), c.y, c.z + r * math.sin(2 * math.pi * i / n))),
    ];

/// Soft contact shadow on the floor under world point [c] ([w] x [d] units).
void _floorShadow(Canvas canvas, _View v, _V3 c, double w, double d, {double opacity = 0.32}) {
  final k = v.scaleAt(c);
  final p = v.project(c);
  final depthSquash = (v.project(c + const _V3(0, 0, 1)) - p).distance;
  labGroundShadow(canvas, p, w * k, math.max(d * depthSquash, 4), opacity: opacity);
}

// ============================================================== OBJECTS

const Color _torchBody = Color(0xFF312E81);
const Color _torchHead = Color(0xFF64748B);
const Color _combColor = Color(0xFF111827);
const Color _frameColor = Color(0xFF94A3B8);
const Color _standColor = Color(0xFF475569);
const Color _penBody = Color(0xFF3B82F6);
const Color _penTip = Color(0xFFD1D5DB);
const Color _shirt = Color(0xFF6366F1);
const Color _skin = Color(0xFFFCB096);
const Color _hair = Color(0xFF3B2A20);
const Color _beamColor = Color(0xFFFFAA00);
const Color _ringColor = Color(0xFFEAB308);

/// Final arm angle for "Raise Left Hand" (raised up beside the head).
const double _raiseAngle = 150 * math.pi / 180;

void _drawSorted(List<(double, VoidCallback)> parts) {
  parts.sort((a, b) => b.$1.compareTo(a.$1));
  for (final p in parts) {
    p.$2();
  }
}

/// Torch lying along local x (body, flared head, lens and bulb).
void _paintTorch(Canvas canvas, _View v, _Pose pose, double t, {required bool on, double opacity = 1}) {
  _V3 w(double x) => pose.apply(_V3(x, 0, 0));
  final s = pose.scale;
  final lensFacing = v.faces(w(1.5), pose.dir(const _V3(1, 0, 0)));
  _drawSorted([
    (
      v.depth(w(-1.5)),
      () {
        _cylinder(canvas, v, w(-3.15), w(-3.0), 0.53 * s, 0.53 * s, const Color(0xFF1E1B4B), opacity: opacity);
        _cylinder(canvas, v, w(-3.0), w(0), 0.5 * s, 0.5 * s, _torchBody, opacity: opacity);
        _box(canvas, v, pose, const _V3(-1.4, 0.48, 0), const _V3(0.7, 0.16, 0.3), const Color(0xFFEF4444),
            opacity: opacity);
      }
    ),
    (
      v.depth(w(0.8)),
      () {
        _cylinder(canvas, v, w(0), w(1.42), 0.5 * s, 0.69 * s, _torchHead, opacity: opacity);
        _cylinder(canvas, v, w(1.38), w(1.5), 0.72 * s, 0.72 * s, const Color(0xFFCBD5E1),
            opacity: opacity, capB: on ? const Color(0xFFFFF1C2) : const Color(0xFFE2E8F0));
        if (lensFacing) {
          final c = v.project(w(1.52));
          final r = 0.3 * s * v.scaleAt(w(1.52));
          if (on) {
            labGlow(canvas, c, r * 4.5, _beamColor, intensity: 0.9 * opacity);
            labSphere(canvas, c, r, _beamColor, highlight: 0.7, shade: 0.1, opacity: opacity);
          } else {
            labSphere(canvas, c, r, Colors.white, highlight: 0.3, shade: 0.25, opacity: opacity);
          }
        }
      }
    ),
  ]);
  if (on && !lensFacing) {
    labGlow(canvas, v.project(w(1.6)), 1.4 * s * v.scaleAt(w(1.6)), _beamColor, intensity: 0.7 * opacity);
  }
}

/// Comb: spine along local z with 0.3-spaced teeth and one gap (the slit).
void _paintComb(Canvas canvas, _View v, _Pose pose, {double opacity = 1}) {
  const edge = Color(0xB364748B);
  _box(canvas, v, pose, const _V3(0, 0.25, 0), const _V3(0.5, 0.5, 5), _combColor, opacity: opacity, edge: edge);
  final teeth = <(double, VoidCallback)>[];
  // Same loop as the HTML (including its floating point steps).
  for (var i = -2.2; i <= 2.2; i += 0.3) {
    if (i.abs() < 0.2) continue; // leave one gap for the light slit
    final c = _V3(0, 1.25, i);
    teeth.add((
      v.depth(pose.apply(c)),
      () => _box(canvas, v, pose, c, const _V3(0.1, 1.5, 0.2), _combColor, opacity: opacity, edge: edge),
    ));
  }
  _drawSorted(teeth);
}

/// Plane mirror: frame, reflective glass facing local -x and a back stand.
void _paintMirror(Canvas canvas, _View v, _Pose pose, {double opacity = 1}) {
  _V3 g(double u, double w) => pose.apply(_V3(-0.11, 0.1 + 2.8 * w, -0.9 + 1.8 * u));
  final glassN = pose.dir(const _V3(-1, 0, 0));
  final facing = v.faces(g(0.5, 0.5), glassN);
  void stand() => _box(canvas, v, pose, const _V3(0.5, 0.1, 0), const _V3(1, 0.2, 1), _standColor, opacity: opacity);
  void frame() => _box(canvas, v, pose, const _V3(0, 1.5, 0), const _V3(0.2, 3, 2), _frameColor, opacity: opacity);
  if (facing) {
    stand();
    frame();
    final quad = [g(0, 0), g(1, 0), g(1, 1), g(0, 1)].map(v.project).toList();
    canvas.drawPath(
      _poly(quad),
      Paint()
        ..shader = ui.Gradient.linear(
          v.project(g(0, 1)),
          v.project(g(1, 0)),
          [
            _alpha(const Color(0xFFF0FDFA), opacity),
            _alpha(const Color(0xFFCCFBF1), opacity),
            _alpha(const Color(0xFF8FE3D3), opacity),
            _alpha(const Color(0xFFCCFBF1), opacity),
            _alpha(const Color(0xFFE6FFFA), opacity),
          ],
          const [0, 0.3, 0.55, 0.8, 1],
        ),
    );
    final sheen = Paint()..color = Colors.white.withValues(alpha: 0.45 * opacity);
    canvas.drawPath(_poly([g(0.12, 1), g(0.34, 1), g(0.7, 0), g(0.48, 0)].map(v.project).toList()), sheen);
    canvas.drawPath(_poly([g(0.42, 1), g(0.5, 1), g(0.86, 0), g(0.78, 0)].map(v.project).toList()),
        sheen..color = Colors.white.withValues(alpha: 0.3 * opacity));
  } else {
    frame();
    // The silvered face peeks out along the top edge.
    canvas.drawLine(
      v.project(g(0, 1)),
      v.project(g(1, 1)),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = _alpha(const Color(0xFF5EEAD4), opacity),
    );
    stand();
  }
}

/// Pen lying along local x (cap end, blue barrel with clip, grip, cone tip).
void _paintPen(Canvas canvas, _View v, _Pose pose, {double opacity = 1}) {
  _V3 w(double x) => pose.apply(_V3(x, 0, 0));
  final s = pose.scale;
  _drawSorted([
    (
      v.depth(w(-1.8)),
      () => _cylinder(canvas, v, w(-2.05), w(-1.6), 0.215 * s, 0.215 * s, const Color(0xFF1E3A8A), opacity: opacity),
    ),
    (
      v.depth(w(0)),
      () {
        _cylinder(canvas, v, w(-1.6), w(1.6), 0.2 * s, 0.2 * s, _penBody, opacity: opacity);
        _box(canvas, v, pose, const _V3(-0.9, 0.22, 0), const _V3(1.4, 0.06, 0.12), const Color(0xFFCBD5E1),
            opacity: opacity);
      }
    ),
    (
      v.depth(w(1.8)),
      () => _cylinder(canvas, v, w(1.6), w(2.0), 0.2 * s, 0.19 * s, const Color(0xFF1D4ED8), opacity: opacity),
    ),
    (
      v.depth(w(2.4)),
      () => _cylinder(canvas, v, w(2.0), w(2.8), 0.19 * s, 0, _penTip, opacity: opacity),
    ),
  ]);
}

/// Direction of the raised (-x side) arm for a raise progress [raise].
_V3 _armDir(double raise) {
  final a = raise * _raiseAngle;
  return _V3(-math.sin(a), -math.cos(a), 0);
}

/// World position just beyond the raised hand (for the LEFT / RIGHT tags).
_V3 _raisedHandTip(_V3 base, double raise) => base + const _V3(-2.1, 3.5, 0) + _armDir(raise) * 3.7;

/// Character from the HTML `createCharacter()` (torso, head, two arms).
/// The arm on the -x side is the one that is raised. [facingCamera]
/// draws the face (the mirror image); otherwise the back of the head.
void _paintPerson(
  Canvas canvas,
  _View v,
  _V3 base, {
  required bool facingCamera,
  required double raise,
  double opacity = 1,
}) {
  final pose = _Pose(base);
  _floorShadow(canvas, v, base, 5, 2.4, opacity: 0.32 * opacity);
  _box(canvas, v, pose, const _V3(0, 2, 0), const _V3(3, 4, 1.5), _shirt, opacity: opacity);
  // Belt and collar / back seam.
  _box(canvas, v, pose, const _V3(0, 0.75, 0), const _V3(3.04, 0.32, 1.54), const Color(0xFF312E81),
      opacity: opacity);
  if (facingCamera) {
    canvas.drawPath(
      _worldPoly(v, [base + const _V3(-0.6, 4, 0.76), base + const _V3(0.6, 4, 0.76), base + const _V3(0, 3.3, 0.76)]),
      Paint()..color = _alpha(labShade(_skin, -0.08), opacity),
    );
  } else {
    canvas.drawLine(
      v.project(base + const _V3(0, 3.9, 0.76)),
      v.project(base + const _V3(0, 1.0, 0.76)),
      Paint()
        ..strokeWidth = 1.2
        ..color = _alpha(labShade(_shirt, -0.35), opacity),
    );
  }
  for (final side in const [-1.0, 1.0]) {
    final d = side < 0 ? _armDir(raise) : const _V3(0, -1, 0);
    final ang = side < 0 ? raise * _raiseAngle : 0.0;
    final sh = base + _V3(side * 2.1, 3.5, 0);
    _cylinder(canvas, v, sh, sh + d * 2.5, 0.6, 0.5, _shirt, opacity: opacity, capA: labShade(_shirt, 0.1));
    _box(canvas, v, _Pose(sh + d * 3, _V3(0, 0, side * ang)), _V3.zero, const _V3(0.8, 1, 0.4), _skin,
        opacity: opacity);
  }
  final hc = base + const _V3(0, 5.2, 0);
  final c = v.project(hc);
  final r = 1.2 * v.scaleAt(hc);
  // Ears, head, hair and face.
  final skinPaint = Paint()..color = _alpha(labShade(_skin, -0.06), opacity);
  for (final sx in const [-1.0, 1.0]) {
    canvas.drawOval(Rect.fromCenter(center: c + Offset(sx * r * 0.97, r * 0.08), width: r * 0.26, height: r * 0.4),
        skinPaint);
  }
  labSphere(canvas, c, r, _skin, opacity: opacity, highlight: 0.35, shade: 0.35);
  canvas.save();
  canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
  final hair = Paint()..color = _alpha(_hair, opacity);
  if (facingCamera) {
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0, -r * 0.78), width: r * 2.3, height: r * 1.06), hair);
  } else {
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0, -r * 0.14), width: r * 2.2, height: r * 2.0), hair);
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(-r * 0.1, -r * 0.3), radius: r * 0.55),
      -2.6,
      1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..color = _alpha(labShade(_hair, 0.25), opacity),
    );
  }
  canvas.restore();
  if (facingCamera) {
    final dark = Paint()..color = _alpha(const Color(0xFF1F2937), opacity);
    final white = Paint()..color = _alpha(Colors.white, opacity);
    for (final sx in const [-1.0, 1.0]) {
      final e = c + Offset(sx * r * 0.36, r * 0.06);
      canvas.drawCircle(e, r * 0.12, dark);
      canvas.drawCircle(e + Offset(r * 0.04, -r * 0.04), r * 0.04, white);
      canvas.drawCircle(c + Offset(sx * r * 0.56, r * 0.36), r * 0.15,
          Paint()..color = _alpha(const Color(0x66F87171), opacity));
    }
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.3, c.dy + r * 0.4)
        ..quadraticBezierTo(c.dx, c.dy + r * 0.66, c.dx + r * 0.3, c.dy + r * 0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.08
        ..color = _alpha(const Color(0xFF7C2D12), opacity),
    );
  }
}

// ============================================================== PAINTER

class _ReflectionPainter extends CustomPainter {
  _ReflectionPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;

  /// Localised labels: torch, comb, mirror, pen, left, right, dist.
  final Map<String, String> labels;

  double get _pulse => 0.5 - 0.5 * math.cos(scene.time * math.pi * 2);

  @override
  void paint(Canvas canvas, Size size) {
    final v = _View(scene.cam);
    _paintBackdrop(canvas, size);
    if (scene.scenario == 0) {
      _paintS1(canvas, v);
    } else {
      _paintS2(canvas, v);
    }
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    canvas.drawRect(
      labBleed(size),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 0.95,
          colors: isDark
              ? const [Color(0xFF17223B), Color(0xFF0B1224), Color(0xFF020617)]
              : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFC3CEDC)],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
  }

  // --------------------------------------------------------- scenario 1

  void _paintS1(Canvas canvas, _View v) {
    final t = scene.time;
    // Desk (BoxGeometry 40 x 2 x 20, top at y = 0).
    const deskColor = Color(0xFF94A3B8);
    final deskTop = _worldPoly(v, const [_V3(-20, 0, -10), _V3(20, 0, -10), _V3(20, 0, 10), _V3(-20, 0, 10)]);
    final deskFront = _worldPoly(v, const [_V3(-20, 0, 10), _V3(20, 0, 10), _V3(20, -2, 10), _V3(-20, -2, 10)]);
    final under = v.project(const _V3(0, -2, 10));
    labGroundShadow(canvas, under + const Offset(0, 16), (v.project(const _V3(20, -2, 10)) - under).dx * 2.1, 40,
        opacity: isDark ? 0.55 : 0.25);
    canvas.drawPath(
      deskTop,
      Paint()
        ..shader = ui.Gradient.linear(
          v.project(const _V3(0, 0, -10)),
          v.project(const _V3(0, 0, 10)),
          [labShade(deskColor, -0.18), labShade(deskColor, 0.06)],
        ),
    );
    canvas.drawPath(deskFront, Paint()..color = labShade(deskColor, -0.32));
    canvas.drawPath(
      deskTop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = labShade(deskColor, 0.3).withValues(alpha: 0.6),
    );

    // White paper (dimmed to off-white, as in the HTML).
    final paperPts = const [_V3(-16, 0.01, -6), _V3(16, 0.01, -6), _V3(16, 0.01, 6), _V3(-16, 0.01, 6)];
    final paper = _worldPoly(v, paperPts);
    canvas.drawPath(
      paper.shift(const Offset(2, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      paper,
      Paint()
        ..shader = ui.Gradient.linear(
          v.project(const _V3(0, 0, -6)),
          v.project(const _V3(0, 0, 6)),
          const [Color(0xFFC3CEDB), Color(0xFFD5DDE7)],
        ),
    );
    canvas.drawPath(
      paper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFAAB7C8),
    );

    // Target rings on the paper (the current target pulses).
    for (final e in _zones.entries) {
      final o = scene.objects[e.key];
      final c = _V3(e.value.x, 0.02, e.value.z);
      final active = o != null && o.step == scene.step && !o.placed;
      _ring(canvas, v, c, active, t);
    }

    // Torch light: a warm pool on the paper (point light), cut off by the
    // comb once it stands in front of the torch.
    if (scene.torchOn) {
      final torch = scene.torch!;
      final c = _V3(torch.pos.x + 4, 0.02, torch.pos.z);
      final cp = v.project(c);
      final rx = (v.project(c + const _V3(9, 0, 0)) - v.project(c - const _V3(9, 0, 0))).distance / 2;
      final rz = (v.project(c + const _V3(0, 0, 9)) - v.project(c - const _V3(0, 0, 9))).distance / 2;
      canvas.save();
      canvas.clipPath(deskTop);
      if (scene.step >= 3) {
        canvas.clipPath(_worldPoly(v, const [_V3(-30, 0, -15), _V3(-2.15, 0, -15), _V3(-2.15, 0, 15), _V3(-30, 0, 15)]));
      }
      canvas.translate(cp.dx, cp.dy);
      canvas.scale(1, rz / rx);
      canvas.drawCircle(
        Offset.zero,
        rx,
        Paint()
          ..shader = RadialGradient(colors: [
            _beamColor.withValues(alpha: 0.5),
            _beamColor.withValues(alpha: 0.22),
            _beamColor.withValues(alpha: 0),
          ], stops: const [0, 0.45, 1])
              .createShader(Rect.fromCircle(center: Offset.zero, radius: rx)),
      );
      canvas.restore();
    }

    // Front shelf tray (32 x 1 x 4).
    _box(canvas, v, const _Pose(_V3(0, -0.5, 12)), _V3.zero, const _V3(32, 1, 4), const Color(0xFF334155),
        edge: const Color(0x8094A3B8));

    // Light beams (amber cylinders), drawn under the objects.
    for (final b in _beamsS1()) {
      _beam(canvas, v, b.$1, b.$2, t);
    }

    final objs = scene.objects.values.where((o) => !o.dragging).toList()
      ..sort((a, b) => v.depth(b.pos).compareTo(v.depth(a.pos)));
    for (final o in [...objs, ...scene.objects.values.where((o) => o.dragging)]) {
      _paintObject(canvas, v, o);
    }

    if (showLabels) {
      for (final o in scene.objects.values) {
        final off = switch (o.id) {
          _Id.torch => 2.0,
          _Id.comb => 2.5,
          _Id.mirror => 3.5,
          _Id.pen => 1.0,
        };
        labPill(
          canvas,
          labels[o.id.name] ?? '',
          v.project(o.pos + _V3(0, off, 0)),
          size: 14,
          opacity: scene.opacityOf(o),
        );
      }
    }
  }

  /// HTML `updateBeamsS1()`: no beam until the comb is placed; then torch →
  /// comb → onwards; with the mirror the beam reflects about its normal.
  List<(_V3, _V3)> _beamsS1() {
    if (scene.step <= 2 || !scene.torchOn) return const [];
    const torchPos = _V3(-10.5, _beamY, 0);
    const combPos = _V3(-2, _beamY, 0);
    const mirrorPos = _V3(8, _beamY, 0);
    if (scene.step == 3) {
      return const [(torchPos, combPos), (combPos, _V3(15, _beamY, 0))];
    }
    final m = scene.mirror!;
    final normal = _rotate(const _V3(-1, 0, 0), m.rot);
    const incident = _V3(1, 0, 0);
    final reflected = (incident - normal * (2 * incident.dot(normal))).unit;
    return [(torchPos, combPos), (combPos, mirrorPos), (mirrorPos, mirrorPos + reflected * 15)];
  }

  void _beam(Canvas canvas, _View v, _V3 a, _V3 b, double t) {
    final pa = v.project(a), pb = v.project(b);
    final w = math.max(2.6, 0.3 * v.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      pa,
      pb,
      Paint()
        ..strokeWidth = w * 4.5
        ..strokeCap = StrokeCap.round
        ..color = _beamColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawLine(
      pa,
      pb,
      Paint()
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..color = _beamColor.withValues(alpha: 0.95),
    );
    canvas.drawLine(
      pa,
      pb,
      Paint()
        ..strokeWidth = w * 0.38
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFF4D6).withValues(alpha: 0.85),
    );
    // Light travelling along the beam.
    labDashedLine(
      canvas,
      pa,
      pb,
      Paint()
        ..strokeWidth = w * 0.55
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.6),
      dash: 8,
      gap: 26,
      phase: -t * 80,
    );
  }

  /// Yellow target ring (RingGeometry 2..2.2) with a pulse when active.
  void _ring(Canvas canvas, _View v, _V3 c, bool active, double t) {
    final k = v.scaleAt(c);
    final ring = _poly(_floorCircle(v, c, 2.1));
    if (active) {
      canvas.drawPath(ring, Paint()..color = _ringColor.withValues(alpha: 0.08 + 0.08 * _pulse));
      final ph = (t % 2) / 2;
      canvas.drawPath(
        _poly(_floorCircle(v, c, 2.1 + 1.4 * ph)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.2 * k
          ..color = _ringColor.withValues(alpha: 0.55 * (1 - ph)),
      );
    }
    canvas.drawPath(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2 * k
        ..color = _ringColor.withValues(alpha: active ? 0.75 + 0.25 * _pulse : 0.6),
    );
  }

  /// One draggable group with its contact shadow (faded when locked).
  void _paintObject(Canvas canvas, _View v, _Obj o, {_Pose? at}) {
    if (!o.visible) return;
    final pose = at ?? scene.poseOf(o);
    final op = scene.opacityOf(o);
    final (sw, sd, sc) = switch (o.id) {
      _Id.torch => (5.0, 1.6, pose.apply(const _V3(-0.75, 0, 0))),
      _Id.comb => (1.0, 5.2, pose.pos),
      _Id.mirror => (2.4, 2.4, pose.apply(const _V3(0.2, 0, 0))),
      _Id.pen => (5.0, 0.9, pose.pos),
    };
    _floorShadow(canvas, v, sc.withY(0), sw * pose.scale, sd * pose.scale, opacity: (o.dragging ? 0.22 : 0.32) * op);
    if (op < 1) canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: op));
    switch (o.id) {
      case _Id.torch:
        _paintTorch(canvas, v, pose, scene.time, on: scene.torchOn);
      case _Id.comb:
        _paintComb(canvas, v, pose);
      case _Id.mirror:
        _paintMirror(canvas, v, pose);
      case _Id.pen:
        _paintPen(canvas, v, pose);
    }
    if (op < 1) canvas.restore();
  }

  // --------------------------------------------------------- scenario 2

  Color get _gridMajor => isDark ? const Color(0xFF475569) : const Color(0xFF64748B);
  Color get _gridMinor => isDark ? const Color(0xFF334155) : const Color(0xFFA3B1C4);

  /// Floor patch with GridHelper(40, 20) style lines (z from [z0] to [z1]).
  /// [reflect] draws the mirror image of the floor in front of the mirror.
  void _floorGrid(Canvas canvas, _View v, double z0, double z1, {bool reflect = false, double alpha = 1}) {
    canvas.drawPath(
      _worldPoly(v, [_V3(-20, 0, z0), _V3(20, 0, z0), _V3(20, 0, z1), _V3(-20, 0, z1)]),
      Paint()
        ..shader = ui.Gradient.linear(
          v.project(_V3(0, 0, z0)),
          v.project(_V3(0, 0, z1)),
          isDark
              ? [const Color(0x00111A2E), const Color(0xCC111A2E)]
              : [const Color(0x00D5DEE9), const Color(0xCCD5DEE9)],
        ),
    );
    final minor = Paint()
      ..strokeWidth = 1
      ..color = _gridMinor.withValues(alpha: alpha);
    final major = Paint()
      ..strokeWidth = 1.4
      ..color = _gridMajor.withValues(alpha: alpha);
    for (var i = -10; i <= 10; i++) {
      final x = i * 2.0;
      canvas.drawLine(v.project(_V3(x, 0, z0)), v.project(_V3(x, 0, z1)), i == 0 ? major : minor);
    }
    for (var i = -10; i <= 10; i++) {
      final z = i * 2.0;
      final zz = reflect ? 2 * _mirrorZ - z : z;
      if (reflect && z <= _mirrorZ) continue;
      if (zz < math.min(z0, z1) || zz > math.max(z0, z1)) continue;
      canvas.drawLine(v.project(_V3(-20, 0, zz)), v.project(_V3(20, 0, zz)), i == 0 ? major : minor);
    }
  }

  void _dashed(Canvas canvas, _View v, _V3 a, _V3 b) {
    labDashedLine(
      canvas,
      v.project(a),
      v.project(b),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF94A3B8),
      dash: 7,
      gap: 5,
    );
  }

  void _paintS2(Canvas canvas, _View v) {
    final t = scene.time;
    final pen = scene.pen!;
    final showPenPair = pen.visible && scene.penReflVisible;
    final realZ = scene.personVisible ? _personPos.z : pen.pos.z;
    final hasPair = scene.personVisible || showPenPair;
    final imgZ = 2 * _mirrorZ - realZ;
    final lineX = scene.personVisible ? _personPos.x : pen.pos.x;
    // Measurement lines run beside the object / image (clear of the body).
    final dimX = lineX + 4.4;
    final showDims = showLabels && hasPair && pen.tween == null;

    _floorGrid(canvas, v, -20, 20);

    // ---- The mirror: what is seen in the glass (the virtual world).
    _V3 g(double u, double w) => _V3(-10 + 20 * u, 1 + 14 * w, _mirrorZ);
    final glass = _worldPoly(v, [g(0, 0), g(1, 0), g(1, 1), g(0, 1)]);
    canvas.save();
    canvas.clipPath(glass);
    canvas.drawPath(
      glass,
      Paint()
        ..shader = ui.Gradient.linear(
          v.project(g(0.5, 1)),
          v.project(g(0.5, 0)),
          isDark
              ? const [Color(0xFF0B1F2A), Color(0xFF123240)]
              : const [Color(0xFFE6F7F4), Color(0xFFC4E8E1)],
        ),
    );
    _floorGrid(canvas, v, _mirrorZ, -32, reflect: true, alpha: 0.85);
    if (hasPair) _dashed(canvas, v, _V3(lineX, 0.02, _mirrorZ - 0.5), _V3(lineX, 0.02, imgZ));
    if (showDims) _dimLine(canvas, v, dimX, _mirrorZ - 0.5, imgZ, _Colors.teal);
    if (scene.personVisible) {
      _paintPerson(canvas, v, scene.personImage, facingCamera: true, raise: scene.armRaise);
    } else if (showPenPair) {
      _floorShadow(canvas, v, scene.penImage.withY(0), 5, 0.9, opacity: 0.3);
      _paintPen(canvas, v, _Pose(scene.penImage));
    }
    canvas.restore();
    // Glass tint, sheen and edge.
    canvas.drawPath(glass, Paint()..color = const Color(0xFFCCFBF1).withValues(alpha: isDark ? 0.1 : 0.16));
    final sheen = Paint()..color = Colors.white.withValues(alpha: isDark ? 0.07 : 0.18);
    canvas.drawPath(_worldPoly(v, [g(0.06, 1), g(0.2, 1), g(0.4, 0), g(0.26, 0)]), sheen);
    canvas.drawPath(_worldPoly(v, [g(0.25, 1), g(0.3, 1), g(0.5, 0), g(0.45, 0)]), sheen);
    canvas.drawPath(_worldPoly(v, [g(0.7, 1), g(0.74, 1), g(0.94, 0), g(0.9, 0)]), sheen);
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF99F6E4).withValues(alpha: 0.55),
    );
    // Frame (four BoxGeometry bars).
    final bars = <(_V3, _V3)>[
      (const _V3(0, 15.5, _mirrorZ), const _V3(20, 1, 1)),
      (const _V3(-10.5, 8, _mirrorZ), const _V3(1, 16, 1)),
      (const _V3(10.5, 8, _mirrorZ), const _V3(1, 16, 1)),
      (const _V3(0, 0.5, _mirrorZ), const _V3(20, 1, 1)),
    ];
    for (final b in bars) {
      _box(canvas, v, _Pose(b.$1), _V3.zero, b.$2, _frameColor);
    }

    // ---- In front of the mirror.
    if (scene.step == 1 && !pen.placed) {
      // Drop area on the grid (HTML dropZones.grid).
      final zone = _worldPoly(v, const [
        _V3(_gridMinX, 0.02, _gridMinZ),
        _V3(_gridMaxX, 0.02, _gridMinZ),
        _V3(_gridMaxX, 0.02, _gridMaxZ),
        _V3(_gridMinX, 0.02, _gridMaxZ),
      ]);
      canvas.drawPath(zone, Paint()..color = _ringColor.withValues(alpha: 0.05 + 0.06 * _pulse));
      labDashedPath(
        canvas,
        zone,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _ringColor.withValues(alpha: 0.45 + 0.35 * _pulse),
        dash: 10,
        gap: 7,
        phase: -t * 20,
      );
    }
    if (hasPair) _dashed(canvas, v, _V3(lineX, 0.02, realZ), _V3(lineX, 0.02, _mirrorZ + 0.5));
    if (showDims) _dimLine(canvas, v, dimX, realZ, _mirrorZ + 0.5, _Colors.blue);

    // Tray (32 x 1 x 4 at z = 16). Empty and out of frame once the
    // camera has moved in on the character.
    if (!scene.personVisible) {
      _box(canvas, v, const _Pose(_V3(0, -0.5, 16)), _V3.zero, const _V3(32, 1, 4), const Color(0xFF334155),
          edge: const Color(0x8094A3B8));
    }

    if (scene.personVisible) {
      _paintPerson(canvas, v, _personPos, facingCamera: false, raise: scene.armRaise);
    }
    _paintObject(canvas, v, pen);

    // Step 2 guide: slide the pen along the grid (towards / away).
    if (scene.step == 2 && !scene.penMoved && !pen.dragging && pen.tween == null) {
      final a = 0.45 + 0.5 * _pulse;
      final c = _ringColor.withValues(alpha: a);
      final p = pen.pos.withY(0.02);
      labArrow(canvas, v.project(p + const _V3(0, 0, 1.6)), v.project(p + const _V3(0, 0, 4.2)), color: c, width: 3);
      labArrow(canvas, v.project(p - const _V3(0, 0, 1.6)), v.project(p - const _V3(0, 0, 4.2)), color: c, width: 3);
    }

    if (!showLabels) return;
    if (showDims) {
      final d = labFormat(labels['dist'] ?? '{d}', {'d': (realZ - _mirrorZ).toStringAsFixed(1)});
      _distPill(canvas, v.project(_V3(dimX, 0.02, (realZ + _mirrorZ) / 2)), d, _Colors.blue);
      _distPill(canvas, v.project(_V3(dimX, 0.02, (imgZ + _mirrorZ) / 2)), d, _Colors.teal);
    }
    if (pen.visible) {
      labPill(canvas, labels['pen'] ?? '', v.project(pen.pos + const _V3(0, 1, 0)), size: 14);
    }
    if (scene.armLabels && scene.personVisible) {
      _armTag(canvas, v.project(_raisedHandTip(_personPos, scene.armRaise)), labels['left'] ?? '',
          const Color(0xFF10B981));
      _armTag(canvas, v.project(_raisedHandTip(scene.personImage, scene.armRaise)), labels['right'] ?? '',
          const Color(0xFF2DD4BF));
    }
  }

  /// Floor measurement line along z at [x] with end ticks.
  void _dimLine(Canvas canvas, _View v, double x, double z0, double z1, Color color) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.9);
    canvas.drawLine(v.project(_V3(x, 0.02, z0)), v.project(_V3(x, 0.02, z1)), paint);
    for (final z in [z0, z1]) {
      canvas.drawLine(v.project(_V3(x - 0.6, 0.02, z)), v.project(_V3(x + 0.6, 0.02, z)), paint);
    }
  }

  void _distPill(Canvas canvas, Offset at, String text, Color accent) {
    labText(
      canvas,
      text,
      at,
      size: 13,
      weight: FontWeight.w800,
      color: isDark ? Colors.white : _Colors.slate900,
      background: isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF),
      border: accent,
      borderWidth: 1.5,
      radius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    );
  }

  /// HTML "LEFT" / "RIGHT" UI labels next to the raised hands.
  void _armTag(Canvas canvas, Offset hand, String text, Color accent) {
    labText(
      canvas,
      text,
      hand - const Offset(0, 4),
      anchor: Alignment.bottomCenter,
      size: 13,
      weight: FontWeight.w800,
      color: isDark ? Colors.white : _Colors.slate800,
      background: isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF),
      border: accent,
      borderWidth: 2,
      radius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }

  @override
  bool shouldRepaint(covariant _ReflectionPainter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || !mapEquals(old.labels, labels);
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
