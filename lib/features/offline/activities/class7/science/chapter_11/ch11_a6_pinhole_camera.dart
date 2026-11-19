// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode, mapEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 11 • Activity 6
/// Pinhole Camera.
///
/// Native Flutter port of `Cl7S-Ch11-A6-Pinhole_Camera.html`.
/// Scenario 1: place a candle, a cardboard with a pinhole and a white screen
/// on the table, watch the rays cross at the pinhole and form an inverted
/// flame, slide the screen and change the pinhole size. Scenario 2: cut a
/// pinhole and a square opening in two cardboard boxes, cover the opening
/// with tracing paper, slide the boxes together, take the camera to a park
/// and focus the inverted image of a tree.
class Ch11A6PinholeCameraPage extends StatefulWidget {
  const Ch11A6PinholeCameraPage({super.key});

  @override
  State<Ch11A6PinholeCameraPage> createState() => _Ch11A6PinholeCameraPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, magic 871,
/// whoosh 1492.
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

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Perspective camera (position, look-at target, focal length in design
/// px) standing in for the Three.js PerspectiveCamera.
class _Cam {
  _Cam({required this.pos, required _V3 target, required this.focal, required this.center})
      : fwd = (target - pos).unit {
    right = fwd.cross(const _V3(0, 1, 0)).unit;
    up = right.cross(fwd);
  }

  final _V3 pos;
  final double focal;
  final Offset center;
  final _V3 fwd;
  late final _V3 right;
  late final _V3 up;

  double depth(_V3 v) => (v - pos).dot(fwd);

  /// Design px per world unit at [v].
  double scaleAt(_V3 v) => focal / math.max(0.1, depth(v));

  Offset p(_V3 v) {
    final d = v - pos;
    final k = focal / math.max(0.1, d.dot(fwd));
    return Offset(center.dx + d.dot(right) * k, center.dy - d.dot(up) * k);
  }

  Offset pt(double x, double y, double z) => p(_V3(x, y, z));

  _V3 _ray(Offset s) =>
      fwd + right * ((s.dx - center.dx) / focal) + up * (-(s.dy - center.dy) / focal);

  /// The point under [s] on the plane `z = const` (the HTML drag plane).
  _V3? onPlaneZ(Offset s, double z) {
    final d = _ray(s);
    if (d.z.abs() < 1e-6) return null;
    final t = (z - pos.z) / d.z;
    return t <= 0 ? null : pos + d * t;
  }

  /// The point under [s] on the plane `y = const` (the park ground).
  _V3? onPlaneY(Offset s, double y) {
    final d = _ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (y - pos.y) / d.y;
    return t <= 0 ? null : pos + d * t;
  }
}

// HTML camera at (0, 15, 60) looking at the origin; raised a little here so
// the table top, the drop rings and the box tops read clearly in 2.5D.
final _Cam _camS1 = _Cam(pos: const _V3(6, 32, 66), target: const _V3(6, 4, 0), focal: 980, center: const Offset(480, 285));
final _Cam _camS2 = _Cam(pos: const _V3(0, 32, 66), target: const _V3(0, 4, 0), focal: 980, center: const Offset(480, 285));

/// Outdoor park (HTML `envGrp`): sky, ground, tree at z = -60.
final _Cam _camPark = _Cam(pos: const _V3(0, 16, 40), target: const _V3(0, 7, -40), focal: 760, center: const Offset(480, 250));

/// The cardboard and the white screen are turned towards the candle and
/// the viewer so the rays and the inverted image can be seen on their faces.
const double _turn = 50 * math.pi / 180;
final _V3 _boardU = _V3(math.cos(_turn), 0, math.sin(_turn));
final _V3 _boardN = _V3(-math.sin(_turn), 0, math.cos(_turn));

// HTML `State.dropZones` (scenario 1) and the inventory column (invX 23.5).
const _V3 _zoneCandle = _V3(-11, 0, 0);
const _V3 _zoneCardboard = _V3(0, 0, 0);
const _V3 _zoneScreen = _V3(11, 0, 0);
const _V3 _invCandle = _V3(23.5, 15, 0);
const _V3 _invCardboard = _V3(23.5, 1.5, 0);
const _V3 _invScreen = _V3(23.5, -10, 0);

/// HTML `restrictDrag 'x'` limits of the screen in step 4 (kept on the table).
const double _screenMinX = 3;
const double _screenMaxX = 17;

/// HTML drop tolerance (`getDist(...) < 10`).
const double _dropRadius = 10;

// Scenario 2 (HTML buildScenario2Assets). The boxes end up side by side on
// the bench instead of overlapping in its centre.
const _V3 _largeHome = _V3(-15, 4, 0);
const _V3 _smallHome = _V3(15, 3.5, 0);
const _V3 _paperHome = _V3(0, 3.5, 10);
const _V3 _zoneLarge = _V3(0, 4, 0);
const _V3 _zoneSmall = _V3(0, 3, 0);
const _V3 _benchLarge = _V3(-6, 4, 0);
const _V3 _benchSmall = _V3(6.5, 3.5, 0);

/// Box sizes (w, h, d) from the HTML.
const double _lW = 10, _lH = 8, _lD = 12;
const double _sW = 9, _sH = 7, _sD = 14;

/// Tracing paper offset in front of the small box (HTML `d / 2 + 0.1`).
const double _paperDz = _sD / 2 + 0.1;

// Park: the camera starts on the grass and goes to the centre of the view.
const _V3 _parkStart = _V3(-17, 4, -4);
const _V3 _parkTarget = _V3(0, 4, -14);

/// Focus slider start (out of focus, as the step text describes).
const double _focusStart = 2;

enum _Id { candle, cardboard, screen, largeBox, smallBox, tracing, camera }

class _Obj {
  _Obj(this.id, _V3 home, {required this.step})
      : home = home,
        x = home.x,
        y = home.y,
        z = home.z;

  final _Id id;

  /// HTML `userData.initPos` (where a wrong drop springs back to).
  _V3 home;
  double x, y, z;

  /// HTML `userData.step`.
  int step;
  bool draggable = false;

  /// HTML `userData.restrictDrag = 'x'`.
  bool restrictX = false;
  bool placed = false;
  bool dragging = false;

  /// True while a tween moves the object.
  bool busy = false;

  _V3 get pos => _V3(x, y, z);

  set pos(_V3 v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }
}

/// A running tween (TWEEN.js stand-in) driven by the scene ticker.
class _Anim {
  _Anim(this.start, this.duration, this.curve, this.update, this.done, this.tag);

  final double start;
  final double duration;
  final Curve curve;
  final void Function(double v) update;
  final VoidCallback? done;
  final Object? tag;
}

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  final Map<_Id, _Obj> objects = {};

  /// Floating label font size in design px (bigger when the stage shrinks).
  double labelPx = 16;

  // Scenario 1.
  double holeSize = 0.2; // #slider-hole-size
  bool raysOn = false;
  bool s1Step4Done = false;
  bool s1Done = false;
  final Set<_Id> ghostHidden = {};

  // Scenario 2.
  bool largeCut = false;
  bool smallCut = false;
  bool paperOn = false;
  double paperFlat = 1; // 1 = lying in the inventory, 0 = upright
  bool assembled = false;
  _Id? cutter; // box showing the cutter tool
  _Id? cutting; // box being cut
  double cutProgress = 0;
  double envFade = 0; // 0 workshop -> 1 outdoor park
  double look = 0; // 0 park -> 1 looking through the camera
  bool parkMode = false;
  double focus = _focusStart; // #slider-focus
  bool s2Done = false;

  _Obj? operator [](_Id id) => objects[id];

  _Cam get cam => scenario == 0 ? _camS1 : _camS2;

  /// HTML pulse tween (scale 1 -> 1.05, 500 ms yoyo) on the object of the
  /// current step; dragged objects are scaled to 1.1.
  bool pulsing(_Obj o) {
    if (o.dragging || o.busy) return false;
    if (o.id == _Id.camera) return step == 5 && !o.placed;
    return o.draggable && o.step == step;
  }

  double scaleOf(_Obj o) {
    if (o.dragging) return 1.1;
    if (!pulsing(o)) return 1;
    final ph = time % 1.0;
    return 1 + 0.05 * (ph < 0.5 ? ph * 2 : 2 - ph * 2);
  }

  /// Flame flicker noise (HTML `sin(t * 0.2) * cos(t * 0.16)`, t in ms).
  double get flicker {
    final ms = time * 1000;
    return math.sin(ms * 0.2) * math.cos(ms * 0.16);
  }
}

// ============================================================ GESTURES

/// Claims a pointer immediately (no slop) when it lands on a draggable
/// object or the cutter, so short drags and taps work and are never taken
/// by the zoom / pan viewer. Touches elsewhere are left to the canvas.
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
  String get debugDescription => 'pinhole lab object drag';
}

// ============================================================== STATE

class _Ch11A6PinholeCameraPageState extends State<Ch11A6PinholeCameraPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Anim> _anims = [];

  late final Ticker _ticker;
  late final AnimationController _bounce;

  /// HTML `#drag-instruction` (hidden once an object is grabbed).
  bool _hintVisible = true;

  // HTML `State.activeDraggable` and `dragOffset`.
  _Obj? _active;
  double _dragDa = 0, _dragDb = 0;
  bool _cutterDown = false;

  /// Bumped on every scene rebuild so stale timers do nothing.
  int _epoch = 0;

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
    if (_anims.isNotEmpty) {
      final done = <VoidCallback>[];
      for (final a in List.of(_anims)) {
        var p = a.duration <= 0 ? 1.0 : ((now - a.start) / a.duration).clamp(0.0, 1.0);
        if (p > 1 - 1e-6) p = 1.0;
        a.update(a.curve.transform(p));
        if (p >= 1) {
          _anims.remove(a);
          if (a.done != null) done.add(a.done!);
        }
      }
      if (done.isNotEmpty && mounted) {
        setState(() {
          for (final fn in done) {
            fn();
          }
        });
      }
    }
    _frame.value = now;
  }

  /// Starts a tween of [seconds]; a new tween with the same [tag] replaces
  /// the old one.
  void _animate(double seconds, Curve curve, void Function(double v) update,
      {VoidCallback? done, Object? tag}) {
    if (tag != null) _anims.removeWhere((a) => a.tag == tag);
    _anims.add(_Anim(_scene.time, seconds, curve, update, done, tag));
  }

  /// TWEEN.js `new TWEEN.Tween(obj.position).to(target, ms)`.
  void _tweenObj(_Obj o, _V3 to, int ms, Curve curve, [VoidCallback? done]) {
    final from = o.pos;
    o.busy = true;
    _animate(ms / 1000, curve, (v) => o.pos = _V3.lerp(from, to, v), tag: o, done: () {
      o.busy = false;
      done?.call();
    });
  }

  /// HTML `setTimeout` bound to the current scene.
  void _later(int ms, VoidCallback fn) {
    final epoch = _epoch;
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted || epoch != _epoch) return;
      setState(fn);
    });
  }

  // ------------------------------------------------------------- build

  /// HTML `buildScenario()` (clearScene + buildScenarioNAssets +
  /// updateObjectAvailability).
  void _buildScenario() {
    _epoch++;
    _lab.cancelPending();
    _anims.clear();
    _active = null;
    _cutterDown = false;
    _hintVisible = true;
    final s = _scene
      ..holeSize = 0.2
      ..raysOn = false
      ..s1Step4Done = false
      ..s1Done = false
      ..largeCut = false
      ..smallCut = false
      ..paperOn = false
      ..paperFlat = 1
      ..assembled = false
      ..cutter = null
      ..cutting = null
      ..cutProgress = 0
      ..envFade = 0
      ..look = 0
      ..parkMode = false
      ..focus = _focusStart
      ..s2Done = false;
    s.objects.clear();
    s.ghostHidden.clear();
    if (s.scenario == 0) {
      s.objects
        ..[_Id.candle] = _Obj(_Id.candle, _invCandle, step: 1)
        ..[_Id.cardboard] = _Obj(_Id.cardboard, _invCardboard, step: 2)
        ..[_Id.screen] = _Obj(_Id.screen, _invScreen, step: 3);
    } else {
      s.objects
        ..[_Id.largeBox] = _Obj(_Id.largeBox, _largeHome, step: 1)
        ..[_Id.smallBox] = _Obj(_Id.smallBox, _smallHome, step: 2)
        ..[_Id.tracing] = _Obj(_Id.tracing, _paperHome, step: 3);
    }
    _updateAvailability();
  }

  /// HTML `resetApp(true)` also restores the canvas tools.
  void _resetTools() {
    _lab
      ..showLabels = true
      ..camLocked = true
      ..panMode = false;
  }

  void _changeScenario(int index) {
    setState(() {
      _scene
        ..scenario = index
        ..step = 1;
      _lab.hidePopup(sound: false);
      _resetTools();
      _buildScenario();
    });
    _lab.resetView(sound: false);
  }

  void _fullReset() {
    setState(() {
      _scene
        ..scenario = 0
        ..step = 1;
      _resetTools();
      _buildScenario();
    });
  }

  // ------------------------------------------------------------- logic

  /// HTML `updateObjectAvailability()`.
  void _updateAvailability() {
    for (final o in _scene.objects.values) {
      o.draggable = o.step == _step && !o.placed && o.id != _Id.camera;
      o.restrictX = false;
    }
    if (_scenario == 0 && _step == 4) {
      // The placed screen slides along the table in step 4.
      _scene[_Id.screen]!
        ..draggable = true
        ..restrictX = true;
    }
    if (_scenario == 1 && _step == 4) {
      // The small box is picked up again to slide it into the large box.
      _scene[_Id.smallBox]!
        ..step = 4
        ..placed = false
        ..draggable = true;
    }
    final cam = _scene[_Id.camera];
    if (cam != null) cam.draggable = _step == 5 && _scene.parkMode && !cam.placed && _scene.envFade >= 1;
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

  void _showConclusion() {
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_scenario + 1}'),
    );
  }

  double _distXY(_V3 a, _V3 b) => math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));

  /// HTML `checkDrop(obj)`.
  void _checkDrop(_Obj o) {
    var ok = false;
    var target = o.pos;
    if (_scenario == 0) {
      final zone = switch (o.id) {
        _Id.candle => _zoneCandle,
        _Id.cardboard => _zoneCardboard,
        _ => _zoneScreen,
      };
      if (_distXY(o.pos, zone) < _dropRadius) {
        ok = true;
        target = zone;
      }
    } else {
      final large = _scene[_Id.largeBox]!, small = _scene[_Id.smallBox]!;
      switch (o.id) {
        case _Id.largeBox:
          if (_distXY(o.pos, _zoneLarge) < _dropRadius) {
            ok = true;
            target = _zoneLarge;
          }
        case _Id.smallBox:
          if (_step == 4) {
            ok = _distXY(o.pos, large.pos) < _dropRadius;
          } else if (_distXY(o.pos, _zoneSmall) < _dropRadius) {
            ok = true;
            target = _benchSmall;
          }
        case _Id.tracing:
          if (_distXY(o.pos, small.pos) < _dropRadius) {
            ok = true;
            target = small.pos + const _V3(0, 0, _paperDz);
          }
        case _Id.camera:
          final d = math.sqrt(math.pow(o.x - _parkTarget.x, 2) + math.pow(o.z - _parkTarget.z, 2));
          if (d < _dropRadius) {
            ok = true;
            target = _parkTarget;
          }
        default:
      }
    }

    if (!ok) {
      _lab.showToast(_t('msg_wrong_drop'), isError: true);
      _tweenObj(o, o.home, 500, Curves.elasticOut, _updateAvailability);
      return;
    }

    _lab.showToast(_t('sci_conclusion'));
    o
      ..draggable = false
      ..placed = true;
    if (_scenario == 1 && o.id == _Id.smallBox && _step == 4) {
      _assemble();
      return;
    }
    if (_scenario == 1 && o.id == _Id.smallBox) {
      // Both boxes settle side by side on the bench.
      final large = _scene[_Id.largeBox]!;
      large.home = _benchLarge;
      o.home = _benchSmall;
      _tweenObj(large, _benchLarge, 450, Curves.easeInOutCubic);
    }
    if (o.id == _Id.tracing) {
      final flat = _scene.paperFlat;
      _animate(0.4, Curves.easeOutCubic, (v) => _scene.paperFlat = flat * (1 - v), tag: #paper);
    }
    final ms = o.id == _Id.smallBox ? 450 : 400;
    _tweenObj(o, target, ms, Curves.easeOutCubic, () {
      o.home = target;
      _scene.ghostHidden.add(o.id);
      _triggerActionEffect(o);
    });
  }

  /// HTML `triggerActionEffect(obj)`.
  void _triggerActionEffect(_Obj o) {
    if (_scenario == 0) {
      if (_step == 3 && o.id == _Id.screen) {
        // The rays and the inverted image appear as soon as the screen
        // stands on the table (HTML `updateS1Rays()`).
        _scene.raysOn = true;
        _Audio.play(_Sound.magic);
        _later(1000, _advanceStep);
      } else {
        _advanceStep();
      }
      return;
    }
    switch (o.id) {
      case _Id.largeBox when _step == 1:
        _scene.cutter = _Id.largeBox;
      case _Id.smallBox when _step == 2:
        _scene.cutter = _Id.smallBox;
      case _Id.tracing when _step == 3:
        _scene.paperOn = true;
        _advanceStep();
      case _Id.camera when _step == 5:
        // Look through the camera's open end (HTML render-target view).
        _Audio.play(_Sound.whoosh);
        _advanceStep();
        _animate(1.0, Curves.easeInOutCubic, (v) => _scene.look = v, tag: #look);
      default:
    }
  }

  /// HTML cutter button click (`showCutterTool` callback).
  void _cut() {
    final id = _scene.cutter;
    if (id == null || _scene.cutting != null) return;
    _Audio.play(_Sound.pop);
    setState(() {
      _hintVisible = false;
      _scene
        ..cutter = null
        ..cutting = id
        ..cutProgress = 0;
    });
    _animate(0.5, Curves.easeInOut, (v) => _scene.cutProgress = v, tag: #cut, done: () {
      _scene.cutting = null;
      if (id == _Id.largeBox) {
        _scene.largeCut = true;
      } else {
        _scene.smallCut = true;
      }
      _advanceStep();
    });
  }

  /// Step 4 of scenario 2: the small box slides into the open end of the
  /// large box, then the finished camera is centred on the bench.
  void _assemble() {
    final large = _scene[_Id.largeBox]!, small = _scene[_Id.smallBox]!;
    final behind = _V3(large.x, large.y, -(_lD / 2 + _sD / 2));
    final inside = _V3(large.x, large.y, -5);
    _tweenObj(small, behind, 400, Curves.easeOutCubic, () {
      _Audio.play(_Sound.drop);
      _tweenObj(small, inside, 500, Curves.easeInOutCubic, () {
        _scene.assembled = true;
        final lx = large.x, sx = small.x;
        _animate(0.35, Curves.easeInOutCubic, (v) {
          large.x = lx * (1 - v);
          small.x = sx - lx * v;
        }, done: () {
          _scene.objects[_Id.camera] = _Obj(_Id.camera, _parkStart, step: 5);
          _advanceStep();
          _later(900, _enterPark);
        });
      });
    });
  }

  /// Step 5: the workshop fades into the outdoor park with the tree.
  void _enterPark() {
    _Audio.play(_Sound.whoosh);
    _scene.parkMode = true;
    _animate(0.9, Curves.easeInOut, (v) => _scene.envFade = v, tag: #env, done: _updateAvailability);
  }

  /// HTML `#slider-hole-size` input (`updateS1Rays`).
  void _onHoleSize(double v) {
    setState(() => _scene.holeSize = v);
    if (_scenario == 0 && _step == 5 && v >= 0.8 - 1e-6 && !_scene.s1Done) {
      _scene.s1Done = true;
      _lab.showToast(_t('sci_conclusion'));
      _later(1500, _advanceStep);
    }
  }

  /// HTML `#slider-focus` input (`updateS2Focus`). The image is sharpest
  /// at the middle of the slider (value 5).
  void _onFocus(double v) {
    setState(() => _scene.focus = v);
    if (_scenario == 1 && _step == 6 && !_scene.s2Done && (v - 5).abs() <= 0.1 + 1e-6) {
      setState(() {
        _scene
          ..s2Done = true
          ..focus = 5;
      });
      _lab.showToast(_t('sci_conclusion'));
      _later(1500, _advanceStep);
    }
  }

  // ------------------------------------------------------- interaction

  bool _grabbable(_Obj o) => !o.busy && o.draggable && (o.step == _step || o.restrictX);

  /// Raycaster stand-in: the draggable object under [p] (design px).
  _Obj? _hit(Offset p) {
    if (_scene.look > 0) return null;
    _Obj? best;
    var bestD = double.infinity;
    for (final o in _scene.objects.values) {
      if (!_grabbable(o)) continue;
      final r = _objBounds(_scene, o);
      if (!r.contains(p)) continue;
      final d = (r.center - p).distance;
      if (d < bestD) {
        best = o;
        bestD = d;
      }
    }
    return best;
  }

  bool _cutterHit(Offset p) =>
      _scene.cutter != null && _scene.cutting == null && (_cutterHitRect(_scene)?.contains(p) ?? false);

  bool _claims(Offset p) =>
      _lab.isLabActive && _active == null && !_cutterDown && (_cutterHit(p) || _hit(p) != null);

  /// HTML drag plane: `z = const` on the bench, the ground in the park.
  _V3? _planePoint(_Obj o, Offset p) =>
      o.id == _Id.camera ? _camPark.onPlaneY(p, o.y) : _scene.cam.onPlaneZ(p, o.z);

  /// HTML `pointerdown`.
  void _pointerDown(Offset p) {
    if (_cutterHit(p)) {
      _cutterDown = true;
      return;
    }
    final o = _hit(p);
    if (o == null) return;
    final w = _planePoint(o, p);
    setState(() {
      _active = o;
      _hintVisible = false;
      o.dragging = true;
      if (w != null) {
        _dragDa = w.x - o.x;
        _dragDb = o.id == _Id.camera ? w.z - o.z : w.y - o.y;
      }
    });
    _Audio.play(_Sound.pickup);
  }

  /// HTML `pointermove`.
  void _pointerMove(Offset p) {
    final o = _active;
    if (o == null) return;
    final w = _planePoint(o, p);
    if (w == null) return;
    if (o.id == _Id.camera) {
      o
        ..x = (w.x - _dragDa).clamp(-34.0, 34.0)
        ..z = (w.z - _dragDb).clamp(-40.0, 6.0);
    } else if (o.restrictX) {
      o.x = (w.x - _dragDa).clamp(_screenMinX, _screenMaxX);
    } else {
      o
        ..x = (w.x - _dragDa).clamp(-40.0, 40.0)
        ..y = (w.y - _dragDb).clamp(-16.0, 28.0);
    }
  }

  /// HTML `pointerup`.
  void _pointerUp() {
    if (_cutterDown) {
      _cutterDown = false;
      _cut();
      return;
    }
    final o = _active;
    if (o == null) return;
    setState(() {
      _active = null;
      o.dragging = false;
      if (o.restrictX) {
        _screenReleased();
      } else {
        _checkDrop(o);
      }
    });
  }

  /// Scenario 1 step 4: releasing the screen after sliding it.
  void _screenReleased() {
    if (_scenario == 0 && _step == 4 && !_scene.s1Step4Done) {
      _scene.s1Step4Done = true;
      _lab.showToast(_t('sci_conclusion'));
      _later(1500, _advanceStep);
    }
  }

  List<LabAction> _actions() {
    if (_scene.cutter == null) return const [];
    return [
      LabAction(
        label: _t('click_to_cut'),
        icon: Icons.content_cut,
        color: _Colors.indigo600,
        foreground: Colors.white,
        highlight: true,
        silent: true, // the cut plays its own sound
        onTap: _cut,
      ),
    ];
  }

  static const List<String> _sceneKeys = [
    'obj_candle',
    'obj_cardboard',
    'obj_screen',
    'obj_large_box',
    'obj_small_box',
    'obj_tracing',
    'obj_camera',
    'inventory',
    'click_to_cut',
  ];

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
          icon: Icons.photo_camera,
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
            if (_scenario == 0 && _step == 5)
              _sliderPanel(
                context,
                s: s,
                inset: inset,
                title: _t('pinhole_size'),
                start: _sliderEnd(_t('small'), s),
                end: _sliderEnd(_t('large'), s),
                value: _scene.holeSize,
                min: 0.1,
                max: 1,
                divisions: 9,
                onChanged: _onHoleSize,
              ),
            if (_scenario == 1 && _step == 6)
              _sliderPanel(
                context,
                s: s,
                inset: inset,
                title: _t('focus'),
                start: Icon(Icons.zoom_out, color: _Colors.slate400, size: 20 * s),
                end: Icon(Icons.zoom_in, color: _Colors.slate400, size: 20 * s),
                value: _scene.focus,
                min: 0,
                max: 10,
                divisions: 100,
                onChanged: _onFocus,
              ),
          ],
          stage: LayoutBuilder(
            builder: (context, box) {
              final fit = math.min(box.maxWidth / _design.width, box.maxHeight / _design.height);
              _scene.labelPx = (11.5 / math.max(fit, 0.05)).clamp(15.0, 25.0);
              return LabStage(
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
                    painter: _PinholePainter(
                      scene: _scene,
                      repaint: _frame,
                      isDark: _lab.isDark,
                      showLabels: _lab.showLabels,
                      text: {for (final k in _sceneKeys) k: _t(k)},
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _sliderEnd(String text, double s) => Text(
        text,
        style: TextStyle(color: _Colors.slate400, fontWeight: FontWeight.w800, fontSize: 11.5 * s),
      );

  /// HTML `#s1-ui-slider` / `#s2-ui-slider`: a compact panel at the top
  /// of the canvas, below the toast.
  Widget _sliderPanel(
    BuildContext context, {
    required double s,
    required EdgeInsets inset,
    required String title,
    required Widget start,
    required Widget end,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Positioned(
      top: inset.top + 40 * s,
      left: inset.left,
      right: inset.right,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400 * s),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8 * s),
            padding: EdgeInsets.fromLTRB(14 * s, 7 * s, 14 * s, 1 * s),
            decoration: BoxDecoration(
              color: const Color(0xD90F172A),
              borderRadius: BorderRadius.circular(14 * s),
              border: Border.all(color: _Colors.slate700),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13 * s),
                ),
                Row(
                  children: [
                    start,
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6 * s,
                          activeTrackColor: _Colors.zslYellow,
                          inactiveTrackColor: _Colors.slate600,
                          thumbColor: _Colors.zslYellow,
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * s),
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9 * s),
                        ),
                        child: Slider(
                          value: value.clamp(min, max),
                          min: min,
                          max: max,
                          divisions: divisions,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                    end,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#drag-instruction`: bouncing hand and hint in the middle of the
  /// canvas until the first object is grabbed.
  Widget _hintOverlay(double s, EdgeInsets inset) {
    return Positioned.fill(
      left: inset.left,
      right: inset.right,
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.1),
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
                      color: Colors.black.withValues(alpha: 0.45),
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
    'app_title': 'Pinhole Camera',
    'app_subtitle': 'Class 7 • Light: Shadows and Reflections',
    'scen_1_opt': 'Scenario 1: The Inverted Flame',
    'scen_2_opt': 'Scenario 2: Build Your Own Camera',
    'sci_conclusion': 'Success!',
    'pinhole_size': 'Pinhole Size',
    'small': 'Small',
    'large': 'Large',
    'focus': 'Focus Inner Box',
    'inventory': 'Inventory',
    'drag_drop_hint': 'Follow the instructions below to proceed!',
    'click_to_cut': 'Click to Cut',
    'msg_wrong_drop': 'Not quite! Try dragging to the highlighted designated area.',
    'conclusion_1':
        'Light travels in straight lines (rectilinear propagation). This causes the pinhole camera to form an inverted image. Rays from the top of the object go down through the hole, and rays from the bottom go up.',
    'conclusion_2':
        'A sliding box pinhole camera can view real-world objects. The image formed on the tracing paper screen is always inverted and colored. Sliding the inner box adjusts the focus.',
    'obj_candle': 'Candle',
    'obj_cardboard': 'Cardboard with Pinhole',
    'obj_screen': 'White Screen',
    'obj_large_box': 'Larger Box',
    'obj_small_box': 'Smaller Box',
    'obj_tracing': 'Tracing Paper',
    'obj_camera': 'Pinhole Camera',
  },
  'hi': {
    'app_title': 'पिनहोल कैमरा',
    'app_subtitle': 'कक्षा 7 • प्रकाश: छाया और परावर्तन',
    'scen_1_opt': 'परिदृश्य 1: उल्टी लौ',
    'scen_2_opt': 'परिदृश्य 2: अपना खुद का कैमरा बनाएं',
    'sci_conclusion': 'सफलता!',
    'pinhole_size': 'पिनहोल का आकार',
    'small': 'छोटा',
    'large': 'बड़ा',
    'focus': 'फोकस',
    'inventory': 'इन्वेंट्री',
    'drag_drop_hint': 'आगे बढ़ने के लिए निर्देशों का पालन करें!',
    'click_to_cut': 'काटने के लिए क्लिक करें',
    'msg_wrong_drop': 'बिल्कुल नहीं! हाइलाइट किए गए क्षेत्र में खींचने का प्रयास करें।',
    'conclusion_1':
        'प्रकाश सीधी रेखाओं में यात्रा करता है। इससे पिनहोल कैमरा एक उल्टा चित्र बनाता है। वस्तु के शीर्ष से किरणें छेद के माध्यम से नीचे जाती हैं, और नीचे से किरणें ऊपर जाती हैं।',
    'conclusion_2':
        'एक स्लाइडिंग बॉक्स पिनहोल कैमरा वास्तविक दुनिया की वस्तुओं को देख सकता है। ट्रेसिंग पेपर स्क्रीन पर बनी छवि हमेशा उल्टी और रंगीन होती है।',
    'obj_candle': 'मोमबत्ती',
    'obj_cardboard': 'पिनहोल के साथ कार्डबोर्ड',
    'obj_screen': 'सफ़ेद स्क्रीन',
    'obj_large_box': 'बड़ा बॉक्स',
    'obj_small_box': 'छोटा बॉक्स',
    'obj_tracing': 'ट्रेसिंग पेपर',
    'obj_camera': 'पिनहोल कैमरा',
  },
};

// ========================================================== SCENARIOS

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To observe the formation of an image using a simple pinhole setup and understand why the image is inverted.',
      steps: [
        LabStep(
          concept: 'The candle is placed and its flame is visibly flickering.',
          action:
              'DRAG the lighted candle from the inventory panel and DROP it onto the designated spot on the left side of the table.',
          observation: 'Light travels in a straight line from the source.',
        ),
        LabStep(
          concept: 'The cardboard stands vertically on the table between the candle and the right side.',
          action:
              'DRAG the cardboard with a small hole (pinhole) from the inventory and DROP it onto the designated spot in the middle of the table, in front of the candle.',
          observation: 'No light rays are visible yet.',
        ),
        LabStep(
          concept: 'An inverted image of the candle flame appears on the screen.',
          action:
              'DRAG the white screen from the inventory and DROP it onto the designated spot on the right side of the table.',
          observation: 'Notice how light rays cross at the pinhole, creating an inverted image.',
        ),
        LabStep(
          concept: 'The user observes that the image size changes.',
          action:
              'CLICK and DRAG the screen horizontally on the table, moving it closer to and farther from the pinhole.',
          observation: 'Closer is smaller and sharper. Farther is larger and dimmer.',
        ),
        LabStep(
          concept: "The user observes how the pinhole size affects the image's brightness and sharpness.",
          action:
              "CLICK the 'Pinhole Size' slider at the bottom of the screen and DRAG it from 'Small' to 'Large'.",
          observation: 'Large hole = bright, blurry image. Small hole = dim, sharp image.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To construct a sliding box pinhole camera as described in the textbook and use it to view an outdoor object.',
      steps: [
        LabStep(
          concept: "A small, clean hole is now visible in the center of the larger box's face.",
          action:
              'You are in a workshop. DRAG the larger cardboard box to the center of the workbench. CLICK the cutter tool, then CLICK on the marked circle on the face of the box to create a pinhole.',
          observation: 'The outer shell of the camera is prepared.',
        ),
        LabStep(
          concept: 'A square opening is created on the face of the smaller box.',
          action:
              'DRAG the smaller cardboard box to the workbench. CLICK the cutter tool, then DRAG it across the marked square on the face of the box to cut an opening.',
          observation: 'This opening will act as our viewing area.',
        ),
        LabStep(
          concept: 'The tracing paper covers the opening, acting as a screen.',
          action:
              'DRAG the sheet of tracing paper from the inventory and DROP it over the square opening on the smaller box.',
          observation: 'Tracing paper acts as a translucent screen.',
        ),
        LabStep(
          concept: 'The two boxes are assembled into a single pinhole camera.',
          action: 'DRAG the smaller box and slide it into the open end of the larger box.',
          observation: 'The sliding mechanism allows focusing.',
        ),
        LabStep(
          concept:
              'The user is now looking at the tracing paper screen inside the camera, which initially shows a blurry, inverted image of the tree.',
          action:
              "The scene changes to an outdoor park with a large tree. DRAG your assembled camera into the center of the view. The view will automatically switch to look through the camera's open end.",
          observation: 'We can see an inverted image of the real world.',
        ),
        LabStep(
          concept:
              'The user finds the correct position where a clear, colorful, and inverted image of the tree is formed on the tracing paper screen.',
          action:
              "A 'Focus' slider appears. DRAG the slider left and right to move the inner box. Stop when the image of the tree on the screen is sharpest.",
          observation: 'Adjusting the focal length sharpens the final image.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'एक सरल पिनहोल सेटअप का उपयोग करके छवि निर्माण का निरीक्षण करना और समझना कि छवि उल्टी क्यों होती है।',
      steps: [
        LabStep(
          concept: 'मोमबत्ती रखी गई है और उसकी लौ टिमटिमा रही है।',
          action: 'इन्वेंट्री पैनल से जलाई हुई मोमबत्ती को खींचें और मेज के बाईं ओर निर्दिष्ट स्थान पर छोड़ दें।',
          observation: 'प्रकाश स्रोत से एक सीधी रेखा में यात्रा करता है।',
        ),
        LabStep(
          concept: 'कार्डबोर्ड मेज पर मोमबत्ती और दाईं ओर के बीच लंबवत खड़ा है।',
          action:
              'एक छोटे छेद (पिनहोल) वाले कार्डबोर्ड को इन्वेंट्री से खींचें और मेज के बीच में, मोमबत्ती के सामने निर्दिष्ट स्थान पर छोड़ दें।',
          observation: 'अभी कोई प्रकाश किरण दिखाई नहीं दे रही है।',
        ),
        LabStep(
          concept: 'मोमबत्ती की लौ की उल्टी छवि स्क्रीन पर दिखाई देती है।',
          action: 'इन्वेंट्री से सफेद स्क्रीन खींचें और मेज के दाईं ओर निर्दिष्ट स्थान पर छोड़ दें।',
          observation: 'ध्यान दें कि प्रकाश किरणें पिनहोल पर कैसे पार करती हैं।',
        ),
        LabStep(
          concept: 'उपयोगकर्ता देखता है कि छवि का आकार बदलता है।',
          action: 'स्क्रीन को क्षैतिज रूप से खींचें, इसे पिनहोल के करीब और दूर ले जाएं।',
          observation: 'करीब छोटा और तेज है। दूर बड़ा और धुंधला है।',
        ),
        LabStep(
          concept: 'पिनहोल का आकार छवि को कैसे प्रभावित करता है।',
          action: "'पिनहोल आकार' स्लाइडर पर क्लिक करें और इसे 'छोटा' से 'बड़ा' तक खींचें।",
          observation: 'बड़ा छेद = उज्ज्वल, धुंधला। छोटा छेद = मंद, तेज।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'स्लाइडिंग बॉक्स पिनहोल कैमरा बनाना और बाहरी वस्तु को देखने के लिए इसका उपयोग करना।',
      steps: [
        LabStep(
          concept: 'बड़े बॉक्स के केंद्र में एक छोटा छेद दिखाई दे रहा है।',
          action:
              'बड़े कार्डबोर्ड बॉक्स को खींचें। कटर टूल पर क्लिक करें, फिर पिनहोल बनाने के लिए बॉक्स के चेहरे पर चिह्नित सर्कल पर क्लिक करें।',
          observation: 'कैमरे का बाहरी आवरण तैयार है।',
        ),
        LabStep(
          concept: 'छोटे बॉक्स के चेहरे पर एक चौकोर उद्घाटन बनाया गया है।',
          action: 'छोटे कार्डबोर्ड बॉक्स को खींचें। कटर टूल पर क्लिक करें, फिर इसे चिह्नित वर्ग पर खींचें।',
          observation: 'यह उद्घाटन हमारे देखने के क्षेत्र के रूप में कार्य करेगा।',
        ),
        LabStep(
          concept: 'ट्रेसिंग पेपर उद्घाटन को कवर करता है, एक स्क्रीन के रूप में कार्य करता है।',
          action: 'इन्वेंट्री से ट्रेसिंग पेपर की शीट खींचें और इसे छोटे बॉक्स पर छोड़ दें।',
          observation: 'ट्रेसिंग पेपर एक पारभासी स्क्रीन के रूप में कार्य करता है।',
        ),
        LabStep(
          concept: 'दो बक्से एक कैमरे में इकट्ठे होते हैं।',
          action: 'छोटे बॉक्स को खींचें और इसे बड़े बॉक्स के खुले सिरे में स्लाइड करें।',
          observation: 'स्लाइडिंग तंत्र फोकस करने की अनुमति देता है।',
        ),
        LabStep(
          concept: 'उपयोगकर्ता स्क्रीन को देख रहा है जो पेड़ की धुंधली, उल्टी छवि दिखाता है।',
          action: 'दृश्य बदलता है। इकट्ठे कैमरे को दृश्य के केंद्र में खींचें।',
          observation: 'हम वास्तविक दुनिया की एक उल्टी छवि देख सकते हैं।',
        ),
        LabStep(
          concept: 'पेड़ की एक स्पष्ट, रंगीन और उल्टी छवि बनती है।',
          action: "'फोकस' स्लाइडर दिखाई देता है। आंतरिक बॉक्स को स्थानांतरित करने के लिए स्लाइडर को खींचें।",
          observation: 'फोकल लंबाई को समायोजित करने से छवि तेज हो जाती है।',
        ),
      ],
    ),
  ],
};

// ============================================================ GEOMETRY

/// HTML directional light at (10, 30, 20).
final _V3 _lightDir = const _V3(10, 30, 20).unit;

/// Ambient 0.6 + directional 0.5 shading of a face with normal [n].
Color _shadeFace(Color c, _V3 n) {
  final f = 0.62 + 0.5 * math.max(0.0, n.dot(_lightDir));
  return f < 1 ? Color.lerp(Colors.black, c, f)! : Color.lerp(c, Colors.white, (f - 1) * 0.8)!;
}

/// Turns a local vector about Y so local +x runs along [_boardU] (for
/// `turn == _turn`) and local +z along [_boardN].
_V3 _rot(_V3 l, double turn) {
  if (turn == 0) return l;
  final c = math.cos(turn), s = math.sin(turn);
  return _V3(l.x * c - l.z * s, l.y, l.x * s + l.z * c);
}

/// One face of an oriented box. [index]: 0 +x, 1 -x, 2 +y, 3 -y, 4 +z, 5 -z.
class _Face {
  _Face(this.index, this.pts, this.normal, this.center);
  final int index;
  final List<_V3> pts;
  final _V3 normal;
  final _V3 center;
}

List<_Face> _boxFaces(_V3 c, double hx, double hy, double hz, double turn) {
  _V3 w(double x, double y, double z) => c + _rot(_V3(x, y, z), turn);
  final ax = _rot(const _V3(1, 0, 0), turn), az = _rot(const _V3(0, 0, 1), turn);
  return [
    _Face(0, [w(hx, -hy, hz), w(hx, -hy, -hz), w(hx, hy, -hz), w(hx, hy, hz)], ax, w(hx, 0, 0)),
    _Face(1, [w(-hx, -hy, -hz), w(-hx, -hy, hz), w(-hx, hy, hz), w(-hx, hy, -hz)], ax * -1, w(-hx, 0, 0)),
    _Face(2, [w(-hx, hy, hz), w(hx, hy, hz), w(hx, hy, -hz), w(-hx, hy, -hz)], const _V3(0, 1, 0), w(0, hy, 0)),
    _Face(3, [w(-hx, -hy, -hz), w(hx, -hy, -hz), w(hx, -hy, hz), w(-hx, -hy, hz)], const _V3(0, -1, 0), w(0, -hy, 0)),
    _Face(4, [w(-hx, -hy, hz), w(hx, -hy, hz), w(hx, hy, hz), w(-hx, hy, hz)], az, w(0, 0, hz)),
    _Face(5, [w(hx, -hy, -hz), w(-hx, -hy, -hz), w(-hx, hy, -hz), w(hx, hy, -hz)], az * -1, w(0, 0, -hz)),
  ];
}

/// Draws an oriented box (Three.js BoxGeometry + MeshStandardMaterial look):
/// visible faces only, shaded by the light, with optional edge lines.
/// [decorate] runs after each visible face (front-face details).
void _drawBox(
  Canvas canvas,
  _Cam cam,
  _V3 c,
  double hx,
  double hy,
  double hz,
  Color color, {
  double turn = 0,
  double opacity = 1,
  Color? edge,
  double edgeWidth = 1.2,
  Set<int> skip = const {},
  void Function(_Face f)? decorate,
}) {
  final faces = _boxFaces(c, hx, hy, hz, turn)
      .where((f) => !skip.contains(f.index) && f.normal.dot(cam.pos - f.center) > 0)
      .toList()
    ..sort((a, b) => cam.depth(b.center).compareTo(cam.depth(a.center)));
  for (final f in faces) {
    final pts = f.pts.map(cam.p).toList();
    final path = Path()..addPolygon(pts, true);
    final col = _shadeFace(color, f.normal);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(col, 0.06).withValues(alpha: opacity),
            labShade(col, -0.06).withValues(alpha: opacity),
          ],
        ).createShader(path.getBounds()),
    );
    if (edge != null) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = edgeWidth
          ..strokeJoin = StrokeJoin.round
          ..color = edge.withValues(alpha: edge.a * opacity),
      );
    }
    decorate?.call(f);
  }
}

/// Affine approximation of the perspective mapping of the plane through
/// [o] spanned by [u] and [v] (one local unit each); local +v is up.
Float64List _planeXf(_Cam cam, _V3 o, _V3 u, _V3 v) {
  final p0 = cam.p(o);
  final pu = cam.p(o + u * 0.5) - cam.p(o - u * 0.5);
  final pv = cam.p(o + v * 0.5) - cam.p(o - v * 0.5);
  return Float64List.fromList([
    pu.dx, pu.dy, 0, 0, //
    pv.dx, pv.dy, 0, 0, //
    0, 0, 1, 0, //
    p0.dx, p0.dy, 0, 1, //
  ]);
}

/// Upright cylinder / truncated cone between two centre points.
void _cyl(Canvas canvas, _Cam cam, _V3 b, _V3 tp, double rb, double rt, Color color, {double opacity = 1}) {
  final pb = cam.p(b), pt = cam.p(tp);
  final rbx = rb * cam.scaleAt(b), rtx = rt * cam.scaleAt(tp);
  final rby = (cam.p(b + _V3(0, 0, rb)).dy - pb.dy).abs();
  final rty = (cam.p(tp + _V3(0, 0, rt)).dy - pt.dy).abs();
  final bottom = Rect.fromCenter(center: pb, width: rbx * 2, height: rby * 2);
  final top = Rect.fromCenter(center: pt, width: rtx * 2, height: rty * 2);
  final body = Path()
    ..moveTo(pt.dx - rtx, pt.dy)
    ..lineTo(pb.dx - rbx, pb.dy)
    ..arcTo(bottom, math.pi, -math.pi, false)
    ..lineTo(pt.dx + rtx, pt.dy)
    ..close();
  Color a(Color c) => c.withValues(alpha: opacity);
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        a(labShade(color, -0.4)),
        a(labShade(color, 0.22)),
        a(color),
        a(labShade(color, -0.5)),
      ], stops: const [0, 0.3, 0.62, 1]).createShader(body.getBounds()),
  );
  canvas.drawOval(top, Paint()..color = a(labShade(color, 0.18)));
}

/// Teardrop flame centred at [c] (cone of half width [rx], height [h]).
void _flame(Canvas canvas, Offset c, double rx, double h, {double opacity = 1}) {
  Path drop(double sx, double sy, double dy) {
    final tip = Offset(c.dx, c.dy - h / 2 * sy + dy);
    final base = Offset(c.dx, c.dy + h / 2 * sy * 0.85 + dy);
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(c.dx + rx * 0.5 * sx, c.dy - h * 0.15 * sy + dy, c.dx + rx * 1.35 * sx, base.dy - rx * 0.4,
          base.dx, base.dy)
      ..cubicTo(c.dx - rx * 1.35 * sx, base.dy - rx * 0.4, c.dx - rx * 0.5 * sx, c.dy - h * 0.15 * sy + dy,
          tip.dx, tip.dy)
      ..close();
  }

  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  canvas.drawPath(drop(1.25, 1.12, 0), Paint()..color = a(const Color(0x66F97316))..maskFilter = MaskFilter.blur(BlurStyle.normal, rx * 0.5));
  canvas.drawPath(drop(1, 1, 0), Paint()..color = a(const Color(0xFFFAB733)));
  canvas.drawPath(drop(0.62, 0.68, h * 0.08), Paint()..color = a(const Color(0xFFFFE680)));
  canvas.drawPath(drop(0.32, 0.36, h * 0.2), Paint()..color = a(const Color(0xFFFFFBEB)));
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(0, h * 0.4), width: rx * 0.9, height: rx * 0.55),
    Paint()..color = a(const Color(0x993B82F6)),
  );
}

/// Light beam (HTML `createColorBeam`): glow, core and light pulses
/// flowing from [a] to [b].
void _beam(Canvas canvas, Offset a, Offset b, Color color, double t) {
  canvas.drawLine(
    a,
    b,
    Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  canvas.drawLine(
    a,
    b,
    Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round,
  );
  final len = (b - a).distance;
  final n = math.max(2, (len / 45).round());
  for (var i = 0; i < n; i++) {
    final f = (t * 0.7 + i / n) % 1.0;
    final p = Offset.lerp(a, b, f)!;
    final alpha = math.sin(math.pi * f);
    canvas.drawCircle(p, 2.6, Paint()..color = Color.lerp(color, Colors.white, 0.55)!.withValues(alpha: 0.9 * alpha));
  }
}

/// Floating object label (HTML `createLabel`): dark rounded chip whose
/// bottom sits on [at].
void _label(Canvas canvas, String text, Offset at, double size, {double opacity = 1}) {
  labText(
    canvas,
    text,
    at,
    size: size,
    color: Colors.white,
    weight: FontWeight.w700,
    anchor: Alignment.bottomCenter,
    background: const Color(0xD90F172A),
    border: const Color(0x99475569),
    borderWidth: 1,
    radius: size * 0.4,
    padding: EdgeInsets.symmetric(horizontal: size * 0.55, vertical: size * 0.22),
    opacity: opacity,
  );
}

/// Soft contact shadow of a footprint (half sizes [hx], [hz]) on the plane
/// `y = [y]` around [c].
void _footShadow(Canvas canvas, _Cam cam, _V3 c, double hx, double hz, double y, {double opacity = 0.35}) {
  final pts = <Offset>[
    for (var i = 0; i < 24; i++)
      cam.p(_V3(c.x + hx * math.cos(i / 24 * 2 * math.pi), y, c.z + hz * math.sin(i / 24 * 2 * math.pi))),
  ];
  canvas.drawPath(
    Path()..addPolygon(pts, true),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
}

/// Design-space hit box of a draggable object (raycaster stand-in).
Rect _objBounds(_Scene s, _Obj o) {
  final k = s.scaleOf(o);
  final cam = o.id == _Id.camera ? _camPark : s.cam;
  final p = o.pos;
  final pts = <_V3>[];
  void box(_V3 c, double hx, double hy, double hz, [double turn = 0]) {
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          pts.add(c + _rot(_V3(hx * sx, hy * sy, hz * sz), turn));
        }
      }
    }
  }

  switch (o.id) {
    case _Id.candle:
      box(p + _V3(0, 3 * k, 0), 2 * k, 3.1 * k, 2 * k);
    case _Id.cardboard:
      box(p + _V3(0, 5 * k, 0), 4 * k, 5 * k, 1 * k, _turn);
    case _Id.screen:
      box(p + _V3(0, 4.25 * k, 0), 5 * k, 4.25 * k, 1 * k, _turn);
    case _Id.largeBox:
      box(p, _lW / 2 * k, _lH / 2 * k, _lD / 2 * k);
    case _Id.smallBox:
      box(p, _sW / 2 * k, _sH / 2 * k, _sD / 2 * k);
    case _Id.tracing:
      box(p, 3.5 * k, 0.6, 3.5 * k);
    case _Id.camera:
      box(p, _lW / 2 * k, _lH / 2 * k, _lD / 2 * k);
      box(p + _V3(0, 0, 5 * k), _sW / 2 * k, _sH / 2 * k, _sD / 2 * k);
  }
  final first = cam.p(pts.first);
  var r = Rect.fromLTRB(first.dx, first.dy, first.dx, first.dy);
  for (final q in pts) {
    final pq = cam.p(q);
    r = r.expandToInclude(Rect.fromLTRB(pq.dx, pq.dy, pq.dx, pq.dy));
  }
  return Rect.fromCenter(center: r.center, width: math.max(r.width, 70), height: math.max(r.height, 70)).inflate(6);
}

/// Cutter tool button (HTML `#cutter-tool-btn`) over the box face centre.
({Offset c, double r})? _cutterGeom(_Scene s) {
  final id = s.cutter;
  if (id == null) return null;
  final o = s[id];
  if (o == null) return null;
  final d = id == _Id.largeBox ? _lD : _sD;
  return (c: s.cam.p(o.pos + _V3(0, 0, d / 2)), r: s.labelPx * 1.5);
}

Rect? _cutterHitRect(_Scene s) {
  final g = _cutterGeom(s);
  if (g == null) return null;
  return Rect.fromLTRB(g.c.dx - g.r * 2.2, g.c.dy - g.r - 10, g.c.dx + g.r * 2.2, g.c.dy + g.r * 2.4);
}

/// Scenario 1 ray geometry (HTML `updateS1Rays`).
class _Rays {
  _Rays(this.tip, this.base, this.hole, this.end1, this.end2, this.ratio);
  final _V3 tip, base, hole, end1, end2;
  final double ratio;
}

_Rays _rayGeo(_V3 candle, _V3 board, _V3 screen) {
  final tip = candle + const _V3(0, 5, 0);
  final base = candle + const _V3(0, 2.5, 0);
  final hole = board + const _V3(0, 5, 0);
  final ratio = ((screen.x - hole.x) / math.max(0.01, (hole.x - tip.x).abs())).abs();
  return _Rays(
    tip,
    base,
    hole,
    _V3(screen.x, hole.y - (tip.y - hole.y) * ratio, screen.z),
    _V3(screen.x, hole.y - (base.y - hole.y) * ratio, screen.z),
    ratio,
  );
}

const Color _rayOrange = Color(0xFFFF8800);
const Color _rayBlue = Color(0xFF00AAFF);

// ============================================================ PAINTER

class _PinholePainter extends CustomPainter {
  _PinholePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.text,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> text;

  String _tx(String key) => text[key] ?? key;
  double get _lp => scene.labelPx;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintS1(canvas, size);
      return;
    }
    final env = scene.envFade, look = scene.look;
    final bleed = labBleed(size);
    if (look >= 1) {
      _paintLookThrough(canvas, size);
      return;
    }
    if (env > 0) _paintPark(canvas, size);
    if (env < 1) {
      if (env > 0) canvas.saveLayer(bleed, Paint()..color = Colors.black.withValues(alpha: 1 - env));
      _paintS2Bench(canvas, size);
      if (env > 0) canvas.restore();
    }
    if (look > 0) {
      final a = ((look - 0.45) / 0.55).clamp(0.0, 1.0);
      if (a > 0) {
        canvas.saveLayer(bleed, Paint()..color = Colors.black.withValues(alpha: a));
        _paintLookThrough(canvas, size);
        canvas.restore();
      }
    }
  }

  // ------------------------------------------------------------- room

  /// HTML `createRoom()`: grey walls (0x475569) and floor.
  void _paintRoom(Canvas canvas, Size size, _Cam cam) {
    final bleed = labBleed(size);
    final base = cam.pt(cam.pos.x, -20, -40).dy;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, base),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF1E2633), Color(0xFF334155), Color(0xFF3B4A5E)]
              : const [Color(0xFF7D8BA0), Color(0xFF94A3B8), Color(0xFFA9B6C8)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, base)),
    );
    // Wall panels.
    final seam = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 2;
    for (var x = -80.0; x <= 80; x += 16) {
      canvas.drawLine(cam.pt(x, -20, -40), cam.pt(x, 60, -40), seam);
    }
    // Skirting board.
    final sk = Path()
      ..addPolygon([
        Offset(bleed.left, cam.pt(0, -18.6, -40).dy),
        Offset(bleed.right, cam.pt(0, -18.6, -40).dy),
        Offset(bleed.right, base),
        Offset(bleed.left, base),
      ], true);
    canvas.drawPath(sk, Paint()..color = isDark ? const Color(0xFF1F2937) : const Color(0xFF64748B));
    // Floor.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, base, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF263241), Color(0xFF151C27)]
              : const [Color(0xFF8391A5), Color(0xFF5B6B80)],
        ).createShader(Rect.fromLTRB(0, base, size.width, size.height)),
    );
    final board = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.5;
    for (var x = -96.0; x <= 96; x += 9) {
      canvas.drawLine(cam.pt(x, -20, -40), cam.pt(x, -20, 40), board);
    }
  }

  /// HTML `createTable()`: wooden top 32 x 1 x 16 on four legs.
  void _paintTable(Canvas canvas, _Cam cam) {
    _footShadow(canvas, cam, const _V3(0, -20, 0), 18, 9, -20, opacity: 0.4);
    const leg = Color(0xFF5C4033);
    for (final lz in const [-6.5, 6.5]) {
      for (final lx in const [-14.0, 14.0]) {
        _drawBox(canvas, cam, _V3(lx, -6.5, lz), 0.75, 6, 0.75, leg, edge: const Color(0x44000000));
      }
    }
    _drawBox(
      canvas,
      cam,
      const _V3(0, -0.5, 0),
      16,
      0.5,
      8,
      const Color(0xFF8B5A2B),
      edge: const Color(0x55000000),
      decorate: (f) {
        if (f.index != 2) return;
        // Wood grain on the table top.
        final grain = Paint()
          ..strokeWidth = 1.2
          ..color = const Color(0xFF5C3A1A).withValues(alpha: 0.22);
        for (var i = 0; i < 9; i++) {
          final z = -7.2 + i * 1.8;
          final wob = math.sin(i * 1.7) * 0.4;
          canvas.drawLine(cam.pt(-15.6, 0, z + wob), cam.pt(15.6, 0, z - wob), grain);
        }
      },
    );
  }

  // ======================================================= SCENARIO 1

  bool _onTable(_Obj o) => !o.dragging && o.y.abs() < 0.3 && o.x.abs() < 17;

  void _paintS1(Canvas canvas, Size size) {
    final s = scene;
    final cam = _camS1;
    final t = s.time;
    _paintRoom(canvas, size, cam);
    _paintTable(canvas, cam);
    final candle = s[_Id.candle]!, board = s[_Id.cardboard]!, screen = s[_Id.screen]!;

    // Warm candle light pooled on the table (HTML PointLight 0xffaa00).
    if (_onTable(candle)) {
      final c = cam.p(candle.pos);
      final inten = 1 + s.flicker * 0.3;
      final r = Rect.fromCenter(center: c, width: 420, height: 120);
      canvas.drawOval(
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFAA00).withValues(alpha: 0.26 * inten),
            const Color(0xFFFFAA00).withValues(alpha: 0),
          ]).createShader(r),
      );
    }

    // HTML `createGhostDropMarker` rings on the table.
    const zones = {_Id.candle: _zoneCandle, _Id.cardboard: _zoneCardboard, _Id.screen: _zoneScreen};
    zones.forEach((id, z) {
      if (s.ghostHidden.contains(id)) return;
      _ghostRing(canvas, cam, z, active: s[id]!.step == s.step && !s[id]!.placed, t: t);
    });

    if (!(candle.placed && board.placed && screen.placed)) _paintInventory(canvas, cam);

    for (final o in [candle, board, screen]) {
      if (!_onTable(o)) continue;
      final hx = o.id == _Id.candle ? 2.2 : 4.4;
      _footShadow(canvas, cam, o.pos, hx, 1.6, 0.02, opacity: 0.3);
    }

    if (s.raysOn) {
      // Back to front: screen, rays behind the board, cardboard, incoming
      // rays, candle.
      final g = _rayGeo(candle.pos, board.pos, screen.pos);
      _paintScreen(canvas, cam, screen, s.scaleOf(screen));
      _paintImage(canvas, cam, screen, g);
      _beam(canvas, cam.p(g.hole), cam.p(g.end1), _rayOrange, t);
      _beam(canvas, cam.p(g.hole), cam.p(g.end2), _rayBlue, t);
      _paintCardboard(canvas, cam, board, s.scaleOf(board));
      _beam(canvas, cam.p(g.tip), cam.p(g.hole), _rayOrange, t);
      _beam(canvas, cam.p(g.base), cam.p(g.hole), _rayBlue, t);
      _paintCandle(canvas, cam, candle, s.scaleOf(candle));
    } else {
      final order = [candle, board, screen]
        ..sort((a, b) {
          if (a.dragging != b.dragging) return a.dragging ? 1 : -1;
          return b.x.compareTo(a.x);
        });
      for (final o in order) {
        final k = s.scaleOf(o);
        switch (o.id) {
          case _Id.candle:
            _paintCandle(canvas, cam, o, k);
          case _Id.cardboard:
            _paintCardboard(canvas, cam, o, k);
          default:
            _paintScreen(canvas, cam, o, k);
        }
      }
    }

    if (s.step == 4 && !s.s1Step4Done && !screen.dragging) _slideHint(canvas, cam, screen.pos, t);

    if (showLabels) {
      for (final (o, key, off) in [
        (candle, 'obj_candle', 6.3),
        (board, 'obj_cardboard', 10.4),
        (screen, 'obj_screen', 8.9),
      ]) {
        final k = s.scaleOf(o);
        _label(canvas, _tx(key), cam.p(o.pos + _V3(0, off * k, 0)), _lp, opacity: o.step > s.step ? 0.3 : 1);
      }
    }
  }

  /// Dashed-looking ring marking a designated spot on the table.
  void _ghostRing(Canvas canvas, _Cam cam, _V3 c, {required bool active, required double t}) {
    final outer = <Offset>[], inner = <Offset>[];
    for (var i = 0; i < 48; i++) {
      final a = i / 48 * 2 * math.pi;
      outer.add(cam.pt(c.x + 3 * math.cos(a), 0.05, c.z + 3 * math.sin(a)));
      inner.add(cam.pt(c.x + 2.5 * math.cos(a), 0.05, c.z + 2.5 * math.sin(a)));
    }
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addPolygon(outer, true)
      ..addPolygon(inner, true);
    final pulse = active ? 0.5 + 0.5 * math.sin(t * 4) : 0.0;
    if (active) {
      canvas.drawPath(
        path,
        Paint()
          ..color = _Colors.zslYellow.withValues(alpha: 0.35 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.drawPath(
      path,
      Paint()..color = Color.lerp(const Color(0xFF94A3B8), _Colors.zslYellow, 0.4 * pulse)!.withValues(alpha: 0.55 + 0.3 * pulse),
    );
  }

  /// Glass inventory panel behind the item column (HTML inventory, x 23.5).
  void _paintInventory(Canvas canvas, _Cam cam) {
    final r = Rect.fromPoints(cam.pt(17.6, 23.6, 0), cam.pt(29.4, -11, 0));
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(18));
    canvas.drawRRect(
      rr.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(rr, Paint()..color = const Color(0x8C0F172A));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.16),
    );
    labText(
      canvas,
      _tx('inventory').toUpperCase(),
      Offset(r.center.dx, r.bottom),
      size: _lp * 0.7,
      color: _Colors.zslYellow,
      weight: FontWeight.w800,
      letterSpacing: 1.4,
      background: const Color(0xF20F172A),
      border: const Color(0x80EAB308),
      padding: EdgeInsets.symmetric(horizontal: _lp * 0.6, vertical: _lp * 0.2),
    );
  }

  /// HTML candle group: gold base, cream body, flickering flame + light.
  void _paintCandle(Canvas canvas, _Cam cam, _Obj o, double k) {
    _V3 w(double x, double y, double z) => o.pos + _V3(x, y, z) * k;
    final noise = scene.flicker;
    final flameC = w(0, 5, 0);
    final fp = cam.p(flameC);
    final px = cam.scaleAt(flameC) * k;
    labGlow(canvas, fp, 7.5 * px, const Color(0xFFFFAA00), intensity: 0.32 * (1 + noise * 0.3));
    _cyl(canvas, cam, w(0, -0.25, 0), w(0, 0.25, 0), 2 * k, 1.5 * k, const Color(0xFFD4AF37));
    _cyl(canvas, cam, w(0, 0.25, 0), w(0, 4.25, 0), 0.6 * k, 0.6 * k, const Color(0xFFFFFDD0));
    canvas.drawLine(
      cam.p(w(0, 4.15, 0)),
      cam.p(w(0, 4.55, 0)),
      Paint()
        ..color = const Color(0xFF3F2A14)
        ..strokeWidth = math.max(1.5, 0.12 * px)
        ..strokeCap = StrokeCap.round,
    );
    _flame(canvas, fp, 0.4 * px * (1 + noise * 0.1), 1.5 * px * (1 + noise * 0.2));
  }

  /// HTML cardboard group: tan board (8 x 10) with a pinhole on a stand.
  void _paintCardboard(Canvas canvas, _Cam cam, _Obj o, double k) {
    _V3 w(double x, double y, double z) => o.pos + _rot(_V3(x, y, z) * k, _turn);
    final candle = scene[_Id.candle]!;
    final lit = _onTable(candle) && _onTable(o);
    final hole = 0.2 + (scene.holeSize - 0.1) * 1.5;
    _drawBox(
      canvas,
      cam,
      w(0, 5, 0),
      4 * k,
      5 * k,
      0.1 * k,
      const Color(0xFFD2B48C),
      turn: _turn,
      edge: const Color(0x668B6B3D),
      decorate: (f) {
        if (f.index != 4) return;
        canvas.save();
        canvas.transform(_planeXf(cam, w(0, 5, 0.1), _boardU * k, _V3(0, k, 0)));
        // Corrugation lines.
        final flute = Paint()
          ..strokeWidth = 0.05
          ..color = const Color(0xFF8B6B3D).withValues(alpha: 0.18);
        for (var x = -3.5; x <= 3.5; x += 0.7) {
          canvas.drawLine(Offset(x, -4.8), Offset(x, 4.8), flute);
        }
        if (lit) {
          final r = Rect.fromCircle(center: Offset.zero, radius: 4.6);
          canvas.drawRect(
            Rect.fromLTRB(-4, -5, 4, 5),
            Paint()
              ..shader = RadialGradient(colors: [
                const Color(0xFFFFAA00).withValues(alpha: 0.22),
                const Color(0xFFFFAA00).withValues(alpha: 0),
              ]).createShader(r),
          );
        }
        canvas.drawCircle(Offset.zero, hole + 0.08, Paint()..color = const Color(0xFF7A5A32));
        canvas.drawCircle(Offset.zero, hole, Paint()..color = const Color(0xFF120A04));
        if (scene.raysOn) {
          labGlow(canvas, Offset.zero, hole * 1.4 + 0.25, const Color(0xFFFFE9A8), intensity: 0.8);
        }
        canvas.restore();
      },
    );
    _drawBox(canvas, cam, w(0, 0.25, 0), 4 * k, 0.25 * k, 1 * k, const Color(0xFF5C4033),
        turn: _turn, edge: const Color(0x55000000));
  }

  /// HTML screen group: light grey board (10 x 8) on a stand.
  void _paintScreen(Canvas canvas, _Cam cam, _Obj o, double k) {
    _V3 w(double x, double y, double z) => o.pos + _rot(_V3(x, y, z) * k, _turn);
    _drawBox(canvas, cam, w(0, 4.5, 0), 5 * k, 4 * k, 0.1 * k, const Color(0xFFCCCCCC),
        turn: _turn, edge: const Color(0x66475569));
    _drawBox(canvas, cam, w(0, 0.25, 0), 4 * k, 0.25 * k, 1 * k, const Color(0xFF5C4033),
        turn: _turn, edge: const Color(0x55000000));
  }

  /// Inverted flame on the screen (HTML flame canvas texture rotated by
  /// PI). Bigger hole: bigger, brighter and blurrier; farther screen:
  /// bigger and dimmer.
  void _paintImage(Canvas canvas, _Cam cam, _Obj screen, _Rays g) {
    final v = scene.holeSize;
    final ratio = g.ratio;
    final m = (0.4 + v * 1.6) / 0.72;
    final h0 = 1.855 * ratio * 0.72;
    final h = h0 * m;
    final cy = 5 + h0 / 2;
    final dim = (1 / (0.55 + 0.45 * ratio * ratio)).clamp(0.4, 1.25);
    final alpha = ((0.35 + (v - 0.1) / 0.9 * 0.65) * dim * (1 + scene.flicker * 0.1)).clamp(0.0, 1.0);
    final sigma = (v - 0.1) * 0.263 * h + 0.03 * h;
    final origin = _V3(screen.x, screen.y + cy, screen.z) + _boardN * 0.12;
    canvas.save();
    canvas.transform(_planeXf(cam, origin, _boardU, const _V3(0, 1, 0)));
    canvas.clipRect(Rect.fromLTRB(-5, 0.5 - cy, 5, 8.5 - cy));
    // Soft glow of light around the image.
    final halo = Rect.fromCenter(center: Offset.zero, width: h * 1.1, height: h * 1.5);
    canvas.drawOval(
      halo,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFB347).withValues(alpha: 0.35 * alpha),
          const Color(0xFFFFB347).withValues(alpha: 0),
        ]).createShader(halo),
    );
    // Inverted teardrop: round base up, tip down.
    final path = Path()
      ..moveTo(0, 0.5 * h)
      ..cubicTo(-0.274 * h, 0.5 * h, -0.274 * h, -0.1316 * h, 0, -0.5 * h)
      ..cubicTo(0.274 * h, -0.1316 * h, 0.274 * h, 0.5 * h, 0, 0.5 * h)
      ..close();
    final grd = Rect.fromCircle(center: Offset(0, 0.184 * h), radius: 0.474 * h);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha),
            const Color(0xFFFFE600).withValues(alpha: alpha),
            const Color(0xFFFF6400).withValues(alpha: 0.9 * alpha),
            const Color(0x00FF0000),
          ],
          stops: const [0, 0.2, 0.6, 1],
        ).createShader(grd)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.01, sigma)),
    );
    canvas.restore();
  }

  /// Arrows under the screen hinting the horizontal slide in step 4.
  void _slideHint(Canvas canvas, _Cam cam, _V3 at, double t) {
    final a = 0.55 + 0.35 * math.sin(t * 4);
    final mid = cam.pt(at.x, 0.05, 5.2);
    final c = _Colors.zslYellow.withValues(alpha: a);
    labArrow(canvas, mid.translate(16, 0), mid.translate(70, 0), color: c, width: 4, head: 14);
    labArrow(canvas, mid.translate(-16, 0), mid.translate(-70, 0), color: c, width: 4, head: 14);
  }

  // ======================================================= SCENARIO 2

  void _paintS2Bench(Canvas canvas, Size size) {
    final s = scene;
    final cam = _camS2;
    _paintRoom(canvas, size, cam);
    _paintTable(canvas, cam);
    final large = s[_Id.largeBox]!, small = s[_Id.smallBox]!, paper = s[_Id.tracing]!;

    if (!s.paperOn) _paintPaperTray(canvas, cam);

    for (final (o, hx, hz) in [(large, _lW / 2, _lD / 2), (small, _sW / 2, _sD / 2)]) {
      if (o.dragging || o.y > 4.6 || o.x.abs() > 12) continue;
      _footShadow(canvas, cam, _V3(o.x, 0, o.z), hx + 0.6, hz + 0.3, 0.02, opacity: 0.3);
    }

    final camObj = s[_Id.camera];
    final gk = s.assembled && camObj != null ? s.scaleOf(camObj) : 1.0;
    if (s.assembled) {
      final g = large.pos;
      final sc = g + (small.pos - g) * gk;
      _paintSmallBox(canvas, cam, sc, gk);
      _paintLargeBox(canvas, cam, g, gk);
      _xray(canvas, cam, g, sc, gk);
    } else {
      final items = <_Obj>[large, small, if (!s.paperOn) paper]
        ..sort((a, b) {
          if (a.dragging != b.dragging) return a.dragging ? 1 : -1;
          return a.z.compareTo(b.z);
        });
      for (final o in items) {
        final k = s.scaleOf(o);
        switch (o.id) {
          case _Id.largeBox:
            _paintLargeBox(canvas, cam, o.pos, k);
          case _Id.smallBox:
            _paintSmallBox(canvas, cam, o.pos, k);
          default:
            _paintPaper(canvas, cam, o.pos, k, s.paperFlat, s.step < 3 ? 0.25 : 0.88);
        }
      }
    }

    _paintCutter(canvas);

    if (!showLabels) return;
    if (s.assembled) {
      _label(canvas, _tx('obj_camera'), cam.p(large.pos + _V3(0, 6 * gk, 0)), _lp);
      return;
    }
    for (final (o, key, off) in [(large, 'obj_large_box', 6.0), (small, 'obj_small_box', 5.0)]) {
      final k = s.scaleOf(o);
      _label(canvas, _tx(key), cam.p(o.pos + _V3(0, off * k, 0)), _lp, opacity: o.step > s.step ? 0.3 : 1);
    }
    final pAt = s.paperOn ? small.pos + const _V3(0, 2, _paperDz) : paper.pos + _V3(0, 2 * s.scaleOf(paper), 0);
    _label(canvas, _tx('obj_tracing'), cam.p(pAt), _lp, opacity: paper.step > s.step ? 0.3 : 1);
  }

  /// Faint corrugation lines on a cardboard face (local units).
  void _corrugation(Canvas canvas, double hw, double hh) {
    final p = Paint()
      ..strokeWidth = 0.05
      ..color = const Color(0xFF5E4524).withValues(alpha: 0.14);
    for (var x = -hw + 0.6; x < hw; x += 0.75) {
      canvas.drawLine(Offset(x, -hh + 0.15), Offset(x, hh - 0.15), p);
    }
  }

  Paint get _cutGuide => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.08
    ..color = const Color(0xFF333333);

  /// Bright cut line traced along [path] up to [progress] with a blade dot.
  void _traceCut(Canvas canvas, Path path, double progress) {
    for (final m in path.computeMetrics()) {
      final part = m.extractPath(0, m.length * progress);
      canvas.drawPath(
        part,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3
          ..color = _Colors.zslYellow.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15),
      );
      canvas.drawPath(
        part,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.1
          ..strokeCap = StrokeCap.round
          ..color = Colors.white,
      );
      final tan = m.getTangentForOffset(m.length * progress);
      if (tan != null) {
        labGlow(canvas, tan.position, 0.6, const Color(0xFFFFF3C4));
        canvas.drawCircle(tan.position, 0.14, Paint()..color = Colors.white);
      }
    }
  }

  /// HTML larger box (10 x 8 x 12, 0xbd9a5c): dashed circle, then a pinhole.
  void _paintLargeBox(Canvas canvas, _Cam cam, _V3 c, double k) {
    _drawBox(canvas, cam, c, _lW / 2 * k, _lH / 2 * k, _lD / 2 * k, const Color(0xFFBD9A5C),
        edge: const Color(0xFF5E4524), edgeWidth: 1.6, decorate: (f) {
      if (f.index != 4) return;
      canvas.save();
      canvas.transform(_planeXf(cam, c + _V3(0, 0, _lD / 2 * k + 0.01), _V3(k, 0, 0), _V3(0, k, 0)));
      _corrugation(canvas, _lW / 2, _lH / 2);
      if (scene.largeCut) {
        canvas.drawCircle(Offset.zero, 0.6, Paint()..color = const Color(0xFF8A6B3A));
        canvas.drawCircle(Offset.zero, 0.5, Paint()..color = const Color(0xFF0B0704));
      } else {
        final circle = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 0.5));
        labDashedPath(canvas, circle, _cutGuide, dash: 0.3, gap: 0.15);
        if (scene.cutting == _Id.largeBox) {
          final arc = Path()..addArc(Rect.fromCircle(center: Offset.zero, radius: 0.5), -math.pi / 2, 2 * math.pi - 0.001);
          _traceCut(canvas, arc, scene.cutProgress);
        }
      }
      canvas.restore();
    });
  }

  /// HTML smaller box (9 x 7 x 14, 0xa19060): dashed square, then a square
  /// opening covered by the tracing paper.
  void _paintSmallBox(Canvas canvas, _Cam cam, _V3 c, double k) {
    _drawBox(canvas, cam, c, _sW / 2 * k, _sH / 2 * k, _sD / 2 * k, const Color(0xFFA19060),
        edge: const Color(0xFF5E4524), edgeWidth: 1.6, decorate: (f) {
      if (f.index != 4) return;
      canvas.save();
      canvas.transform(_planeXf(cam, c + _V3(0, 0, _sD / 2 * k + 0.01), _V3(k, 0, 0), _V3(0, k, 0)));
      _corrugation(canvas, _sW / 2, _sH / 2);
      final sq = Rect.fromCenter(center: Offset.zero, width: 5, height: 5);
      if (scene.smallCut) {
        canvas.drawRect(sq.inflate(0.1), Paint()..color = const Color(0xFF7D6E45));
        canvas.drawRect(
          sq,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2B2113), Color(0xFF0C0804)],
            ).createShader(sq),
        );
        if (scene.paperOn) {
          final pr = Rect.fromCenter(center: Offset.zero, width: 7, height: 7);
          canvas.drawRect(pr, Paint()..color = Colors.white.withValues(alpha: 0.84));
          final fib = Paint()
            ..strokeWidth = 0.04
            ..color = const Color(0xFF94A3B8).withValues(alpha: 0.25);
          for (var y = -3.0; y <= 3; y += 0.9) {
            canvas.drawLine(Offset(-3.4, y), Offset(3.4, y + 0.2), fib);
          }
          canvas.drawRect(
            pr,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.06
              ..color = const Color(0xFFCBD5E1),
          );
        }
      } else {
        labDashedPath(canvas, Path()..addRect(sq), _cutGuide, dash: 0.3, gap: 0.15);
        if (scene.cutting == _Id.smallBox) {
          final perim = Path()
            ..moveTo(-2.5, 2.5)
            ..lineTo(2.5, 2.5)
            ..lineTo(2.5, -2.5)
            ..lineTo(-2.5, -2.5)
            ..lineTo(-2.5, 2.5);
          _traceCut(canvas, perim, scene.cutProgress);
        }
      }
      canvas.restore();
    });
  }

  /// Sheet of tracing paper (7 x 7): lying flat ([flat] 1) or upright (0).
  void _paintPaper(Canvas canvas, _Cam cam, _V3 c, double k, double flat, double opacity) {
    final a = flat * math.pi / 2;
    _V3 corner(double u, double v) => c + _V3(u * k, v * math.cos(a) * k, -v * math.sin(a) * k);
    final pts = [corner(-3.5, -3.5), corner(3.5, -3.5), corner(3.5, 3.5), corner(-3.5, 3.5)].map(cam.p).toList();
    final path = Path()..addPolygon(pts, true);
    canvas.drawPath(
      path.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: opacity));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFCBD5E1).withValues(alpha: opacity),
    );
  }

  /// Glass inventory tray under the tracing paper.
  void _paintPaperTray(Canvas canvas, _Cam cam) {
    const c = _paperHome;
    final y = c.y - 0.2;
    final pts = [
      cam.pt(c.x - 4.8, y, c.z - 4.8),
      cam.pt(c.x + 4.8, y, c.z - 4.8),
      cam.pt(c.x + 4.8, y, c.z + 4.8),
      cam.pt(c.x - 4.8, y, c.z + 4.8),
    ];
    final path = Path()..addPolygon(pts, true);
    canvas.drawPath(path, Paint()..color = const Color(0x8C0F172A));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    labText(
      canvas,
      _tx('inventory').toUpperCase(),
      cam.pt(c.x, y, c.z + 4.8),
      size: _lp * 0.7,
      color: _Colors.zslYellow,
      weight: FontWeight.w800,
      letterSpacing: 1.4,
      background: const Color(0xF20F172A),
      border: const Color(0x80EAB308),
      padding: EdgeInsets.symmetric(horizontal: _lp * 0.6, vertical: _lp * 0.2),
    );
  }

  /// Dashed outline of the inner box hidden inside the larger box.
  void _xray(Canvas canvas, _Cam cam, _V3 g, _V3 sc, double k) {
    final back = g.z - _lD / 2 * k;
    final hx = _sW / 2 * k, hy = _sH / 2 * k, hz = _sD / 2 * k;
    final paint = Paint()
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.6);
    void seg(_V3 a, _V3 b) {
      if (a.z < back && b.z < back) return;
      if (a.z < back) a = _V3.lerp(a, b, (back - a.z) / (b.z - a.z));
      if (b.z < back) b = _V3.lerp(b, a, (back - b.z) / (a.z - b.z));
      labDashedLine(canvas, cam.p(a), cam.p(b), paint, dash: 6, gap: 4);
    }

    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        seg(sc + _V3(sx * hx, sy * hy, -hz), sc + _V3(sx * hx, sy * hy, hz));
      }
    }
    final f = sc.z + hz;
    final front = [
      _V3(sc.x - hx, sc.y - hy, f),
      _V3(sc.x + hx, sc.y - hy, f),
      _V3(sc.x + hx, sc.y + hy, f),
      _V3(sc.x - hx, sc.y + hy, f),
    ];
    for (var i = 0; i < 4; i++) {
      seg(front[i], front[(i + 1) % 4]);
    }
    // The tracing paper screen inside the camera.
    final pr = [
      cam.pt(sc.x - 3.5 * k, sc.y - 3.5 * k, f + 0.1),
      cam.pt(sc.x + 3.5 * k, sc.y - 3.5 * k, f + 0.1),
      cam.pt(sc.x + 3.5 * k, sc.y + 3.5 * k, f + 0.1),
      cam.pt(sc.x - 3.5 * k, sc.y + 3.5 * k, f + 0.1),
    ];
    canvas.drawPath(Path()..addPolygon(pr, true), Paint()..color = Colors.white.withValues(alpha: 0.12));
  }

  /// HTML `#cutter-tool-btn`: glass circle with the cutter icon and
  /// "Click to Cut", over the marked spot on the box face.
  void _paintCutter(Canvas canvas) {
    final g = _cutterGeom(scene);
    if (g == null) return;
    final r = g.r * (1 + 0.06 * math.sin(scene.time * 5));
    final c = g.c;
    canvas.drawCircle(
      c.translate(0, 4),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(c, r, Paint()..color = const Color(0xB31E1B4B));
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.1));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    final icon = r * 1.15;
    canvas.save();
    canvas.translate(c.dx - icon / 2, c.dy - icon / 2);
    canvas.scale(icon / 24);
    final body = Path()
      ..moveTo(21.41, 9.41)
      ..lineTo(13.59, 1.59)
      ..arcToPoint(const Offset(12.18, 1), radius: const Radius.circular(2), clockwise: false)
      ..lineTo(4, 1)
      ..arcToPoint(const Offset(2, 3), radius: const Radius.circular(2), clockwise: false)
      ..lineTo(2, 21)
      ..arcToPoint(const Offset(4, 23), radius: const Radius.circular(2), clockwise: false)
      ..lineTo(20, 23)
      ..arcToPoint(const Offset(22, 21), radius: const Radius.circular(2), clockwise: false)
      ..lineTo(22, 10.82)
      ..arcToPoint(const Offset(21.41, 9.41), radius: const Radius.circular(2), clockwise: false)
      ..close();
    final fold = Path()
      ..moveTo(13, 3.18)
      ..lineTo(13, 7)
      ..arcToPoint(const Offset(14, 8), radius: const Radius.circular(1), clockwise: false)
      ..lineTo(17.82, 8)
      ..close();
    final blade = Path()
      ..moveTo(10.29, 12.29)
      ..lineTo(13, 15)
      ..lineTo(9, 19)
      ..lineTo(7, 19)
      ..lineTo(7, 17)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF6366F1));
    canvas.drawPath(fold, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawPath(blade, Paint()..color = const Color(0xFFF8FAFC));
    canvas.restore();
    labText(
      canvas,
      _tx('click_to_cut').toUpperCase(),
      c.translate(0, r + 6),
      size: _lp * 0.62,
      color: Colors.white,
      weight: FontWeight.w800,
      letterSpacing: 1,
      anchor: Alignment.topCenter,
      background: const Color(0x99000000),
      padding: EdgeInsets.symmetric(horizontal: _lp * 0.5, vertical: _lp * 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _PinholePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || !mapEquals(old.text, text);
}

// ======================================================= OUTDOOR PARK

const Color _skyTop = Color(0xFF4FA3D9);
const Color _sky = Color(0xFF87CEEB); // HTML sky sphere
const Color _skyLow = Color(0xFFCDEBF7);
const Color _grass = Color(0xFF2D5A27); // HTML ground
const Color _trunk = Color(0xFF5C4033);
const Color _leaves = Color(0xFF3A7A33);
const Color _sun = Color(0xFFFFD700);

/// Upright picture of the park as seen from the pinhole, drawn into [r]
/// (y down). Used for the image on the tracing paper.
void _paintTreeImage(Canvas canvas, Rect r, double t) {
  final w = r.width, h = r.height;
  final horizon = r.top + h * 0.64;
  canvas.drawRect(
    Rect.fromLTRB(r.left, r.top, r.right, horizon),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_skyTop, _sky, _skyLow],
      ).createShader(Rect.fromLTRB(r.left, r.top, r.right, horizon)),
  );
  final sun = Offset(r.left + w * 0.82, r.top + h * 0.13);
  labGlow(canvas, sun, w * 0.16, const Color(0xFFFFF3B0), intensity: 0.8);
  canvas.drawCircle(sun, w * 0.06, Paint()..color = _sun);
  for (final (bx, by, sz) in [(0.1, 0.12, 0.13), (0.55, 0.22, 0.1)]) {
    final x = r.left + ((bx + t * 0.012) % 1.2 - 0.1) * w;
    _cloud(canvas, Offset(x, r.top + by * h), sz * w);
  }
  canvas.drawRect(
    Rect.fromLTRB(r.left, horizon, r.right, r.bottom),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A8C3F), _grass],
      ).createShader(Rect.fromLTRB(r.left, horizon, r.right, r.bottom)),
  );
  // Tree: trunk from the horizon, three leafy spheres.
  final cx = r.left + w * 0.5;
  final u = h / 34;
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx + u, horizon + u * 0.6), width: u * 16, height: u * 2.4),
    Paint()..color = Colors.black.withValues(alpha: 0.25),
  );
  labSphere(canvas, Offset(cx - 8 * u, horizon - 15 * u), 9 * u, labShade(_leaves, -0.1));
  canvas.drawRect(Rect.fromLTRB(cx - 1.7 * u, horizon - 14 * u, cx + 1.7 * u, horizon + 0.4 * u), Paint()..color = _trunk);
  labSphere(canvas, Offset(cx, horizon - 18 * u), 11 * u, _leaves);
  labSphere(canvas, Offset(cx + 8 * u, horizon - 13 * u), 9 * u, labShade(_leaves, 0.06));
}

void _cloud(Canvas canvas, Offset c, double s) {
  final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
  canvas.drawOval(Rect.fromCenter(center: c, width: s * 1.8, height: s * 0.55), p);
  canvas.drawCircle(c.translate(-s * 0.3, -s * 0.18), s * 0.32, p);
  canvas.drawCircle(c.translate(s * 0.22, -s * 0.22), s * 0.4, p);
}

extension _ParkPaint on _PinholePainter {
  /// Sky, sun, clouds, ground and the tree (HTML `envGrp`).
  void _paintOutdoor(Canvas canvas, Size size, _Cam cam, double t) {
    final bleed = labBleed(size);
    final horizon = cam.pt(0, 0, -400).dy;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, horizon),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _sky, _skyLow],
        ).createShader(Rect.fromLTRB(0, 0, size.width, horizon)),
    );
    const sun = Offset(805, 72);
    labGlow(canvas, sun, 120, const Color(0xFFFFF3B0), intensity: 0.75);
    canvas.drawCircle(
      sun,
      30,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFFFFF7C2), _sun]).createShader(Rect.fromCircle(center: sun, radius: 30)),
    );
    for (final (bx, by, sz) in [(0.0, 60.0, 70.0), (430.0, 105.0, 52.0), (820.0, 150.0, 60.0)]) {
      final x = (bx + t * 9) % 1500 - 250;
      _cloud(canvas, Offset(x, by), sz);
    }
    // Distant hills and tree line.
    final hills = Path()..moveTo(bleed.left, horizon);
    for (var x = bleed.left; x <= bleed.right; x += 12) {
      hills.lineTo(x, horizon - 18 - 14 * math.sin(x / 90) - 8 * math.sin(x / 37 + 1));
    }
    hills
      ..lineTo(bleed.right, horizon + 1)
      ..lineTo(bleed.left, horizon + 1)
      ..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFF7FB27A));
    final line = Path()..moveTo(bleed.left, horizon);
    for (var x = bleed.left; x <= bleed.right; x += 8) {
      line.lineTo(x, horizon - 6 - 6 * (0.5 + 0.5 * math.sin(x / 11)) * (0.6 + 0.4 * math.sin(x / 70)));
    }
    line
      ..lineTo(bleed.right, horizon + 1)
      ..lineTo(bleed.left, horizon + 1)
      ..close();
    canvas.drawPath(line, Paint()..color = const Color(0xFF4F8A45));
    // Ground.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, horizon, bleed.right, bleed.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A8C3F), _grass, Color(0xFF1F4219)],
          stops: [0, 0.45, 1],
        ).createShader(Rect.fromLTRB(0, horizon, size.width, size.height)),
    );
    // Grass tufts (deterministic, in perspective).
    final tuft = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6BAA5C).withValues(alpha: 0.7);
    for (var i = 0; i < 70; i++) {
      final x = ((i * 37) % 97) / 97 * 90 - 45;
      final z = -((i * 53) % 89) / 89 * 80 + 12;
      final p = cam.pt(x, 0, z);
      final k = cam.scaleAt(_V3(x, 0, z)) * 0.5;
      canvas.drawLine(p, p.translate(-k * 0.4, -k), tuft);
      canvas.drawLine(p, p.translate(k * 0.1, -k * 1.3), tuft);
      canvas.drawLine(p, p.translate(k * 0.5, -k * 0.9), tuft);
    }
    // The tree (HTML: trunk r2 h15, leaves r12 / r10 / r10) at z = -60.
    _footShadow(canvas, cam, const _V3(3, 0, -57), 15, 9, 0.02, opacity: 0.35);
    void leaf(_V3 c, double r, double shade) {
      final p = cam.p(c);
      final pr = r * cam.scaleAt(c);
      labSphere(canvas, p, pr, labShade(_leaves, shade), highlight: 0.3);
      final blob = Paint()..color = labShade(_leaves, shade + 0.12).withValues(alpha: 0.5);
      for (var i = 0; i < 6; i++) {
        final a = i * 1.1 + c.x;
        canvas.drawCircle(p + Offset(math.cos(a), math.sin(a) * 0.8) * pr * 0.55, pr * 0.22, blob);
      }
    }

    leaf(const _V3(-8, 15, -65), 10, -0.12);
    _cyl(canvas, cam, const _V3(0, 0, -60), const _V3(0, 15, -60), 2, 2, _trunk);
    leaf(const _V3(0, 18, -60), 12, 0);
    leaf(const _V3(8, 14, -55), 10, 0.05);
  }

  /// Park view (step 5): drag the camera to the ring in the centre. While
  /// switching to the camera view the park zooms into the open end.
  void _paintPark(Canvas canvas, Size size) {
    final s = scene;
    final cam = _camPark;
    final camObj = s[_Id.camera];
    final zoom = Curves.easeInCubic.transform(s.look.clamp(0.0, 1.0));
    canvas.save();
    if (zoom > 0 && camObj != null) {
      final f = cam.p(camObj.pos + const _V3(0, 0, 12));
      final z = 1 + 8 * zoom;
      canvas
        ..translate(f.dx, f.dy)
        ..scale(z)
        ..translate(-f.dx, -f.dy);
    }
    _paintOutdoor(canvas, size, cam, s.time);
    if (camObj != null) {
      if (s.step == 5 && !camObj.placed) _targetRing(canvas, cam, s.time);
      final k = s.scaleOf(camObj);
      _paintCameraRear(canvas, cam, camObj.pos, k);
      if (showLabels && s.look == 0) {
        _label(canvas, _tx('obj_camera'), cam.p(camObj.pos + _V3(0, 4.6 * k, 6 * k)), _lp);
      }
    }
    canvas.restore();
  }

  /// Designated spot in the centre of the view.
  void _targetRing(Canvas canvas, _Cam cam, double t) {
    final c = _parkTarget;
    final pulse = 0.5 + 0.5 * math.sin(t * 4);
    final pts = <Offset>[
      for (var i = 0; i < 48; i++)
        cam.pt(c.x + 8 * math.cos(i / 48 * 2 * math.pi), 0.02, c.z + 8 * math.sin(i / 48 * 2 * math.pi)),
    ];
    final ring = Path()..addPolygon(pts, true);
    canvas.drawPath(ring, Paint()..color = _Colors.zslYellow.withValues(alpha: 0.1 + 0.1 * pulse));
    canvas.drawPath(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = _Colors.zslYellow.withValues(alpha: 0.25 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    labDashedPath(
      canvas,
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Color.lerp(const Color(0xFFE2E8F0), _Colors.zslYellow, pulse)!,
      dash: 12,
      gap: 8,
      phase: t * 20,
    );
  }

  /// The assembled camera seen from behind: the larger box with the
  /// smaller box sticking out of its open end. Through the open end the
  /// tracing paper glows with a tiny inverted image of the tree.
  void _paintCameraRear(Canvas canvas, _Cam cam, _V3 g, double k) {
    const edge = Color(0xFF5E4524);
    _footShadow(canvas, cam, _V3(g.x, 0, g.z + 3 * k), 6.5 * k, 10 * k, 0.02, opacity: 0.4);
    final lhx = _lW / 2 * k, lhy = _lH / 2 * k, lhz = _lD / 2 * k;
    _drawBox(canvas, cam, g, lhx, lhy, lhz, const Color(0xFFBD9A5C), edge: edge, edgeWidth: 1.4, skip: const {4});
    // Dark gap around the inner box in the larger box's open end.
    final bz = g.z + lhz;
    final gap = [
      cam.pt(g.x - lhx, g.y - lhy, bz),
      cam.pt(g.x + lhx, g.y - lhy, bz),
      cam.pt(g.x + lhx, g.y + lhy, bz),
      cam.pt(g.x - lhx, g.y + lhy, bz),
    ];
    final gapPath = Path()..addPolygon(gap, true);
    canvas.drawPath(gapPath, Paint()..color = const Color(0xFF1A130A));
    canvas.drawPath(
      gapPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = edge,
    );
    // Part of the smaller box outside the larger one.
    final rimZ = g.z + (5 + _sD / 2) * k;
    _drawBox(canvas, cam, _V3(g.x, g.y, (bz + rimZ) / 2), _sW / 2 * k, _sH / 2 * k, (rimZ - bz) / 2,
        const Color(0xFFA19060),
        edge: edge, edgeWidth: 1.4, skip: const {4, 5});
    _openEnd(canvas, cam, g, k, rimZ);
  }

  /// Interior of the smaller box seen through its open end.
  void _openEnd(Canvas canvas, _Cam cam, _V3 g, double k, double rimZ) {
    final t = 0.2 * k;
    final hx = _sW / 2 * k - t, hy = _sH / 2 * k - t;
    final farZ = rimZ - _sD * k + t;
    List<Offset> quad(double z, double ax, double ay) => [
          cam.pt(g.x - ax, g.y - ay, z),
          cam.pt(g.x + ax, g.y - ay, z),
          cam.pt(g.x + ax, g.y + ay, z),
          cam.pt(g.x - ax, g.y + ay, z),
        ];
    final rimOuter = quad(rimZ, _sW / 2 * k, _sH / 2 * k);
    final rim = quad(rimZ, hx, hy);
    final far = quad(farZ, hx, hy);
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addPolygon(rimOuter, true)
        ..addPolygon(rim, true),
      Paint()..color = const Color(0xFFC9B47E),
    );
    final rimPath = Path()..addPolygon(rim, true);
    canvas.save();
    canvas.clipPath(rimPath);
    canvas.drawPath(rimPath, Paint()..color = const Color(0xFF140E07));
    canvas.drawPath(Path()..addPolygon(far, true), Paint()..color = const Color(0xFF4A3C22));
    canvas.save();
    canvas.transform(_planeXf(cam, _V3(g.x, g.y, farZ), _V3(k, 0, 0), _V3(0, k, 0)));
    _smallPaperImage(canvas);
    canvas.restore();
    // Inner walls facing the viewer (bottom, left, right, top).
    final walls = [
      (const _V3(0, 1, 0), [rim[0], rim[1], far[1], far[0]], const Color(0xFF6B5A32), g.y - hy),
      (const _V3(1, 0, 0), [rim[0], rim[3], far[3], far[0]], const Color(0xFF4F4024), g.x - hx),
      (const _V3(-1, 0, 0), [rim[1], rim[2], far[2], far[1]], const Color(0xFF4F4024), g.x + hx),
      (const _V3(0, -1, 0), [rim[3], rim[2], far[2], far[3]], const Color(0xFF2E2414), g.y + hy),
    ];
    for (final (n, pts, col, at) in walls) {
      final probe = n.y != 0 ? _V3(g.x, at, (rimZ + farZ) / 2) : _V3(at, g.y, (rimZ + farZ) / 2);
      if (n.dot(cam.pos - probe) <= 0) continue;
      canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = col);
    }
    canvas.restore();
    canvas.drawPath(
      rimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF5E4524),
    );
  }

  /// The tracing paper window (5 x 5, local units, +y up) with the tiny
  /// inverted image; out of focus it looks washed out.
  void _smallPaperImage(Canvas canvas) {
    const r = Rect.fromLTRB(-2.5, -2.5, 2.5, 2.5);
    canvas.save();
    canvas.clipRect(r);
    canvas.drawRect(r, Paint()..color = const Color(0xFFF3EBD6));
    canvas.save();
    // Local +y is up, so a horizontal mirror makes the picture turn 180°.
    canvas.scale(-1, 1);
    _paintTreeImage(canvas, r, scene.time);
    canvas.restore();
    final wash = 0.15 + 0.6 * math.min(1.0, (scene.focus - 5).abs() / 5);
    canvas.drawRect(r, Paint()..color = const Color(0xFFFFF8E7).withValues(alpha: wash));
    canvas.restore();
  }

  /// Looking through the camera's open end (HTML step 6 view): the inner
  /// box walls lead to the tracing paper, which shows the inverted image
  /// of the tree. Sliding the inner box moves the paper and changes the
  /// focus; the out-of-focus park shows around the camera.
  void _paintLookThrough(Canvas canvas, Size size) {
    final s = scene;
    const view = Rect.fromLTRB(-420, -360, 1420, 920);
    canvas.saveLayer(view, Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6, tileMode: TileMode.clamp));
    canvas
      ..save()
      ..translate(480, 200)
      ..scale(1.7)
      ..translate(-480, -200);
    _paintOutdoor(canvas, size, _camPark, s.time);
    canvas
      ..restore()
      ..restore();

    const c = Offset(480, 272);
    const f = 1100.0;
    final dr = 14 + (s.focus - 5) * 0.6;
    final dp = dr + _sD - 0.2;
    Rect box(double hx, double hy, double d) =>
        Rect.fromCenter(center: c, width: 2 * hx * f / d, height: 2 * hy * f / d);
    final outer = box(_sW / 2, _sH / 2, dr);
    final inner = box(_sW / 2 - 0.2, _sH / 2 - 0.2, dr);
    final far = box(_sW / 2 - 0.2, _sH / 2 - 0.2, dp);
    final win = box(2.5, 2.5, dp);

    canvas.drawRect(
      outer.inflate(16),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawRect(outer, Paint()..color = const Color(0xFFC9B47E));
    canvas.save();
    canvas.clipRect(inner);
    Path quad(List<Offset> p) => Path()..addPolygon(p, true);
    void wall(List<Offset> p, Alignment from, Alignment to, Color a, Color b) {
      final path = quad(p);
      canvas.drawPath(
        path,
        Paint()..shader = LinearGradient(begin: from, end: to, colors: [a, b]).createShader(path.getBounds()),
      );
    }

    wall([inner.topLeft, inner.topRight, far.topRight, far.topLeft], Alignment.topCenter, Alignment.bottomCenter,
        const Color(0xFF221A0E), const Color(0xFF4A3B21));
    wall([inner.bottomLeft, inner.bottomRight, far.bottomRight, far.bottomLeft], Alignment.bottomCenter,
        Alignment.topCenter, const Color(0xFF4F4024), const Color(0xFF8A7642));
    wall([inner.topLeft, far.topLeft, far.bottomLeft, inner.bottomLeft], Alignment.centerLeft, Alignment.centerRight,
        const Color(0xFF30260F), const Color(0xFF6A5833));
    wall([inner.topRight, far.topRight, far.bottomRight, inner.bottomRight], Alignment.centerRight,
        Alignment.centerLeft, const Color(0xFF30260F), const Color(0xFF6A5833));
    // Corrugation lines running into the box.
    final flute = Paint()
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.12);
    for (var i = 1; i < 8; i++) {
      final u = i / 8;
      canvas.drawLine(Offset.lerp(inner.bottomLeft, inner.bottomRight, u)!,
          Offset.lerp(far.bottomLeft, far.bottomRight, u)!, flute);
      canvas.drawLine(Offset.lerp(inner.topLeft, inner.topRight, u)!, Offset.lerp(far.topLeft, far.topRight, u)!, flute);
    }
    canvas.drawRect(far, Paint()..color = const Color(0xFF5B4A28));

    // Tracing paper with the inverted, possibly blurred image.
    final sigma = 14 * math.pow((s.focus - 5).abs() / 5, 0.6).toDouble();
    canvas.save();
    canvas.clipRect(win);
    canvas.drawRect(win, Paint()..color = const Color(0xFFF3EBD6));
    canvas.saveLayer(
      win,
      sigma > 0.05 ? (Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma)) : Paint(),
    );
    canvas
      ..translate(win.center.dx, win.center.dy)
      ..rotate(math.pi)
      ..translate(-win.center.dx, -win.center.dy);
    _paintTreeImage(canvas, win.inflate(sigma * 2), s.time);
    canvas.restore();
    canvas.drawRect(win, Paint()..color = const Color(0xFFFFF8E7).withValues(alpha: 0.14));
    final fib = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.12);
    for (var i = 1; i < 10; i++) {
      final y = win.top + win.height * i / 10;
      canvas.drawLine(Offset(win.left, y), Offset(win.right, y + 3), fib);
    }
    canvas.drawRect(
      win,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.28),
        ], stops: const [0.6, 1]).createShader(win),
    );
    canvas.restore();
    // Light from the paper spilling onto the walls.
    final spill = Rect.fromCenter(center: c, width: far.width * 2.6, height: far.height * 2.6);
    canvas.drawRect(
      inner,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE6A8).withValues(alpha: 0.2),
          const Color(0xFFFFE6A8).withValues(alpha: 0),
        ]).createShader(spill),
    );
    canvas.restore();
    final edgeP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF5E4524);
    canvas.drawRect(inner, edgeP);
    canvas.drawRect(outer, edgeP);
    canvas.drawRect(win, edgeP..color = const Color(0xFF3B2F1A));
    if (showLabels) _label(canvas, _tx('obj_tracing'), Offset(c.dx, win.top - 10), _lp);
  }
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
