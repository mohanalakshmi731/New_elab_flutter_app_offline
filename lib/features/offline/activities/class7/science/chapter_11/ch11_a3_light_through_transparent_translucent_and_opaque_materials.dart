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

/// Class 7 Science • Chapter 11 • Activity 3
/// Light through Transparent, Translucent, and Opaque Materials.
///
/// Native Flutter port of
/// `Cl7S-Ch11-A3-Light_through_Transparent__Translucent__and_Opaque_Materials.html`.
/// Scenario 1: drag a glass pane, tracing paper, cardboard, thick cloth and
/// clear plastic into a torch beam and watch the spot on the screen stay
/// bright, turn dim and fuzzy, or vanish into a dark shadow. Scenario 2:
/// predict each material's class by dropping it into a sorting bin, then
/// test it in the beam; wrong predictions are corrected automatically.
class Ch11A3LightThroughTransparentTranslucentAndOpaqueMaterialsPage extends StatefulWidget {
  const Ch11A3LightThroughTransparentTranslucentAndOpaqueMaterialsPage({super.key});

  @override
  State<Ch11A3LightThroughTransparentTranslucentAndOpaqueMaterialsPage> createState() =>
      _Ch11A3LightThroughTransparentTranslucentAndOpaqueMaterialsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, test 2585.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right prediction (HTML "drop_ok").
  correct('correct.mp3'),

  /// Wrong action / wrong prediction (HTML "drop_err").
  wrong('wrong.mp3'),

  /// Scenario completed / summary popup (HTML "enter").
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// A material is dropped into a sorting bin (HTML "drop_ok").
  drop('drop.mp3'),

  /// A material is picked up.
  pickup('pickup.mp3'),

  /// A material is placed in the light beam (HTML "test_sound").
  test('switch.mp3');

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
      await player.play(AssetSource('audio/class7/${sound.file}'), volume: volume, mode: PlayerMode.lowLatency);
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
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color green = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color red = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color amber700 = Color(0xFFB45309);
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
const _font = LabFont(family: null, fallback: null, size: 15, minSize: 12, maxSize: 24);

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
  double get length => math.sqrt(x * x + y * y + z * z);
}

// Perspective projection that mimics the HTML camera (fov 35, at
// (0, 5, 75) looking at the origin) in 1000x560 design pixels. The scene is
// framed a little higher than the HTML so the tray clears the HUD.
const double _projF = 1000;
const double _projD = 75;
const double _camY = 5;
const double _projCx = 500;
const double _projCy = 190;

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

const _V3 _up = _V3(0, 1, 0);

/// The torch lens (HTML head CylinderGeometry(1.5, 1, 2) ending at x = -16;
/// the spot light itself sits at x = -17).
const double _lensX = -16;
const double _lensRadius = 1.4;

/// HTML `State.dropZones.testBeam`.
const _V3 _beamPos = _V3(0, 0, 0);

/// Tray slots (`createMaterialObject` start positions) and bin drop points.
const double _trayY = -8.5;
const double _trayZ = 5;
const double _binY = 12;
const double _binZ = -15;

/// Half the side of a material sheet (BoxGeometry 4 x 4 x 0.2).
const double _plateHalf = 2;

/// The screen board and a sheet in the beam are turned towards the viewer
/// so their faces (and the spot of light) can be seen from the front.
const double _turn = 55 * math.pi / 180;
final _V3 _boardU = _V3(math.cos(_turn), 0, math.sin(_turn));
final _V3 _boardN = _V3(-math.sin(_turn), 0, math.cos(_turn));

/// A sheet in the beam turns less than the board, so its face stays easy
/// to see while it still reads as blocking the beam.
const double _plateTurn = 35 * math.pi / 180;

/// Radius of the bright spot on the screen, sized so that a sheet in the
/// beam covers the whole cone.
const double _spotRadius = 4.4;

/// How a material treats light (HTML `userData.behavior`). Each class also
/// has a sorting bin in scenario 2.
enum _Behavior {
  transparent(binX: -14, binColor: _Colors.blue, readout: _Colors.green600),
  translucent(binX: 0, binColor: _Colors.slate400, readout: _Colors.yellow400),
  opaque(binX: 14, binColor: _Colors.slate700, readout: _Colors.red600);

  const _Behavior({required this.binX, required this.binColor, required this.readout});

  final double binX;
  final Color binColor;

  /// Colour of the "Bright / Dim / No Light" readout and summary column.
  final Color readout;

  String get binKey => 'bin_$name';

  String get lightKey => switch (this) {
    _Behavior.transparent => 'bright_light',
    _Behavior.translucent => 'dim_light',
    _Behavior.opaque => 'no_light',
  };

  _V3 get binPos => _V3(binX, _binY, _binZ);
}

/// The five sheets of the HTML tray.
enum _Mat {
  glass(color: Color(0xFF88CCFF), opacity: 0.3, behavior: _Behavior.transparent, slot: -10, tile: _Colors.blue400),
  paper(color: Color(0xFFFFFADD), opacity: 0.85, behavior: _Behavior.translucent, slot: -5, tile: _Colors.slate300),
  cardboard(color: _Colors.amber700, opacity: 1, behavior: _Behavior.opaque, slot: 0, tile: _Colors.amber700),
  cloth(color: _Colors.slate800, opacity: 1, behavior: _Behavior.opaque, slot: 5, tile: _Colors.slate500),
  plastic(color: Color(0xFFFFFFFF), opacity: 0.15, behavior: _Behavior.transparent, slot: 10, tile: _Colors.cyan500);

  const _Mat({
    required this.color,
    required this.opacity,
    required this.behavior,
    required this.slot,
    required this.tile,
  });

  final Color color;
  final double opacity;
  final _Behavior behavior;

  /// x of the sheet's place in the tray.
  final double slot;

  /// Accent of the sheet's tile in the observation summary.
  final Color tile;

  String get labelKey => 'obj_$name';

  _V3 get trayPos => _V3(slot, _trayY, _trayZ);
}

class _Tween {
  _Tween({
    required this.from,
    required this.to,
    required this.fromTurn,
    required this.toTurn,
    required this.start,
    required this.duration,
    required this.curve,
    this.onDone,
  });

  final _V3 from;
  final _V3 to;
  final double fromTurn;
  final double toTurn;
  final double start;
  final double duration;
  final Curve curve;
  final VoidCallback? onDone;
}

/// One material sheet (HTML mesh + `userData`).
class _Plate {
  _Plate(this.mat) : pos = mat.trayPos;

  final _Mat mat;
  _V3 pos;

  /// 0 = facing the viewer (tray, bins, dragging); [_turn] = facing the torch.
  double turn = 0;
  bool draggable = false;
  bool tested = false;
  bool dragging = false;

  /// Scenario 2: the bin the sheet was predicted into, and its place there.
  _Behavior? inBin;
  _V3? binPos;
  _Tween? tween;

  bool get resting => tween == null && !dragging;
  bool get inTray => resting && (pos - mat.trayPos).length < 0.01;
  bool get inBinRest => resting && binPos != null && (pos - binPos!).length < 0.01;
}

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  final Map<_Mat, _Plate> plates = {};

  /// HTML `setScreenEffect`: what the screen shows (null = empty beam).
  _Behavior? effect;

  /// The sheet being tested in the beam.
  _Plate? inBeam;

  /// Drawing scale of [p]: lifted while dragged, pulsing while it is the
  /// sheet to move next (HTML `pulseTween` 1 -> 1.1, 500 ms yoyo).
  double scaleOf(_Plate p) {
    if (p.dragging) return 1.2;
    if (p.draggable && p.tween == null) {
      return 1 + 0.1 * (0.5 - 0.5 * math.cos(time * math.pi * 2));
    }
    return 1;
  }
}

/// Front-face corners of [p] at scale [s] (top-left, top-right,
/// bottom-right, bottom-left).
List<_V3> _plateCorners(_Plate p, double s) {
  final u = _V3(math.cos(p.turn), 0, math.sin(p.turn)) * (_plateHalf * s);
  final v = _up * (_plateHalf * s);
  return [p.pos - u + v, p.pos + u + v, p.pos + u - v, p.pos - u - v];
}

/// Design-space hit box of a sheet (used for drag picking).
Rect _plateBounds(_Scene scene, _Plate p) {
  final pts = _plateCorners(p, scene.scaleOf(p)).map(_projV).toList();
  var r = Rect.fromPoints(pts[0], pts[2]);
  for (final q in pts) {
    r = r.expandToInclude(Rect.fromCircle(center: q, radius: 0.1));
  }
  return Rect.fromCenter(center: r.center, width: math.max(r.width, 64), height: math.max(r.height, 64)).inflate(6);
}

// Drop zones in design pixels: the HTML split the screen into the bins
// band (top), the beam band (middle) and the tray (bottom).

/// Drops below this line land back in the tray.
final double _trayZoneTop = _proj(0, -6.5, _trayZ).dy - 4;

/// Scenario 2: drops above this line go into the nearest bin.
final double _binZoneBottom = (_proj(0, 7.4, _binZ).dy + _proj(0, 2.5, 0).dy) / 2;

/// Design-space point of a scene item, for widget tests that drag on the
/// painted scene: a material in the tray (`glass`, `paper`, `cardboard`,
/// `cloth`, `plastic`), the light `beam`, an empty spot in the `tray`, or a
/// bin (`bin_transparent`, `bin_translucent`, `bin_opaque`).
@visibleForTesting
Offset ch11A3ScenePoint(String id) {
  if (id == 'beam') return _projV(_beamPos);
  if (id == 'tray') return _proj(0, -9.6, _trayZ + 3);
  for (final b in _Behavior.values) {
    if (id == b.binKey) return _projV(b.binPos);
  }
  for (final m in _Mat.values) {
    if (id == m.name) return _projV(m.trayPos);
  }
  throw ArgumentError.value(id, 'id', 'Unknown scene point');
}

// ============================================================ GESTURES

/// Claims a pointer immediately (no slop) when it lands on a sheet that can
/// be dragged, so short drags work and are never taken by the zoom / pan
/// viewer. Touches elsewhere are left to the canvas.
class _SheetDragRecognizer extends OneSequenceGestureRecognizer {
  _SheetDragRecognizer({super.debugOwner});

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
  String get debugDescription => 'light lab sheet drag';
}

// ============================================================== STATE

enum _DropAction { test, predict }

class _Ch11A3LightThroughTransparentTranslucentAndOpaqueMaterialsPageState
    extends State<Ch11A3LightThroughTransparentTranslucentAndOpaqueMaterialsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;
  late final AnimationController _bounce;

  /// The big check / cross of scenario 2 (HTML `#validation-overlay`).
  late final AnimationController _verdict;
  bool? _verdictCorrect;

  /// HTML `#drag-instruction` (hidden once a sheet is grabbed).
  bool _hintVisible = true;

  /// Scenario 1: both free-experiment sheets are tested and the observation
  /// summary is waiting for its Continue button.
  bool _summaryPending = false;

  /// A sheet is in (or on its way out of) the beam. Grabbing is blocked so
  /// the beam never holds two sheets (the HTML had no such guard).
  bool _busy = false;

  // HTML `State.activeDraggable`, `dragOffset` and the last pointer position.
  _Plate? _active;
  double _dragDx = 0, _dragDy = 0;
  Offset _pointer = Offset.zero;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;
  bool get _done => _step > _data.steps.length;
  _Plate _plate(_Mat m) => _scene.plates[m]!;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    _verdict = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _ticker = createTicker(_onTick)..start();
    _buildScenario();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _bounce.dispose();
    _verdict.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    _scene.time = now;
    final done = <VoidCallback>[];
    for (final p in _scene.plates.values) {
      final tw = p.tween;
      if (tw == null) continue;
      final k = ((now - tw.start) / tw.duration).clamp(0.0, 1.0);
      final v = tw.curve.transform(k);
      p
        ..pos = tw.from + (tw.to - tw.from) * v
        ..turn = tw.fromTurn + (tw.toTurn - tw.fromTurn) * v.clamp(0.0, 1.0);
      if (k >= 1) {
        p
          ..pos = tw.to
          ..turn = tw.toTurn
          ..tween = null;
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

  /// TWEEN.js `new TWEEN.Tween(obj.position).to(target, ms)`; the sheet also
  /// turns to [turn].
  void _tweenTo(_Plate p, _V3 target, int ms, Curve curve, {double turn = 0, VoidCallback? onDone}) {
    p.tween = _Tween(
      from: p.pos,
      to: target,
      fromTurn: p.turn,
      toTurn: turn,
      start: _scene.time,
      duration: ms / 1000,
      curve: curve,
      onDone: onDone,
    );
  }

  // ------------------------------------------------------------- build

  /// HTML `buildScenario()` (clearScenarioElements + build assets +
  /// updateObjectAvailability).
  void _buildScenario() {
    _lab.cancelPending();
    _active = null;
    _busy = false;
    _summaryPending = false;
    _hintVisible = true;
    _verdictCorrect = null;
    _verdict.reset();
    _scene
      ..plates.clear()
      ..effect = null
      ..inBeam = null;
    for (final m in _Mat.values) {
      _scene.plates[m] = _Plate(m);
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

  /// HTML `updateObjectAvailability()`. Sheets already tested stay put.
  void _updateAvailability() {
    for (final p in _scene.plates.values) {
      p.draggable = false;
    }
    if (_done) return;
    final glass = _plate(_Mat.glass), cardboard = _plate(_Mat.cardboard);
    if (_scenario == 0) {
      final ids = switch (_step) {
        1 => const [_Mat.glass],
        2 => const [_Mat.paper],
        3 => const [_Mat.cardboard],
        4 => const [_Mat.cloth, _Mat.plastic],
        _ => const <_Mat>[],
      };
      for (final id in ids) {
        final p = _plate(id);
        if (!p.tested) p.draggable = true;
      }
    } else if (_step == 1 && glass.inBin == null) {
      glass.draggable = true;
    } else if (_step == 2 && !glass.tested) {
      glass.draggable = true;
    } else if (_step == 3 && cardboard.inBin == null) {
      cardboard.draggable = true;
    } else if (_step == 4 && !cardboard.tested) {
      cardboard.draggable = true;
    } else if (_step == 5) {
      for (final id in const [_Mat.paper, _Mat.cloth, _Mat.plastic]) {
        final p = _plate(id);
        p.draggable = !p.tested;
      }
    }
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    final n = _data.steps.length;
    if (_scenario == 0 && _step == 4) {
      _summaryPending = false;
      _showConclusion();
    } else if (_step < n) {
      _scene.step++;
      _updateAvailability();
    } else if (_step == n) {
      _showConclusion();
    }
  }

  /// HTML `showConclusion()`: the steps are all ticked off and the shared
  /// conclusion popup opens.
  void _showConclusion() {
    _scene.step = _data.steps.length + 1;
    _updateAvailability();
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_scenario + 1}'),
    );
  }

  /// HTML `setScreenEffect('default')`.
  void _clearEffect() {
    _scene
      ..effect = null
      ..inBeam = null;
  }

  /// Scenario 2: the place of [p] in [bin]. Sheets that share a bin sit side
  /// by side (the HTML stacked them on the same spot).
  _V3 _binSlot(_Behavior bin, _Plate p) {
    const offsets = [0.0, 2.6, -2.6, 1.3, -1.3];
    final others = _scene.plates.values.where((o) => o != p && o.inBin == bin).length;
    return bin.binPos + _V3(offsets[math.min(others, offsets.length - 1)], 0, 0);
  }

  /// The bin nearest to the pointer, horizontally.
  _Behavior _nearestBin(Offset p) {
    var best = _Behavior.translucent;
    var bestD = double.infinity;
    for (final b in _Behavior.values) {
      final d = (_projV(b.binPos).dx - p.dx).abs();
      if (d < bestD) {
        best = b;
        bestD = d;
      }
    }
    return best;
  }

  /// HTML `handleDrop(obj, dropMouse)`, using the pointer position.
  void _handleDrop(_Plate p) {
    final at = _pointer;
    final m = p.mat;
    _DropAction? action;
    _V3? target;
    var turn = 0.0;

    if (_scenario == 0) {
      // The beam fills the middle of the scene; below it is the tray.
      if (at.dy < _trayZoneTop) action = _DropAction.test;
    } else {
      final inBins = at.dy < _binZoneBottom;
      final inBeam = !inBins && at.dy < _trayZoneTop;
      if (inBeam) {
        if ((_step == 2 && m == _Mat.glass) || (_step == 4 && m == _Mat.cardboard)) {
          action = _DropAction.test;
        } else if (_step == 5) {
          if (p.inBin != null) {
            action = _DropAction.test;
          } else {
            _lab.showToast(_t('msg_predict_first'), isError: true);
          }
        } else {
          _lab.showToast(_t('msg_wrong_drop'), isError: true);
        }
      } else if (inBins) {
        final bin = _nearestBin(at);
        if ((_step == 1 && m == _Mat.glass && bin == _Behavior.transparent) ||
            (_step == 3 && m == _Mat.cardboard && bin == _Behavior.translucent) ||
            (_step == 5 && !p.tested)) {
          action = _DropAction.predict;
          target = _binSlot(bin, p);
          p
            ..inBin = bin
            ..binPos = target;
        } else {
          _lab.showToast(_t('msg_wrong_drop'), isError: true);
        }
      }
    }

    if (action == _DropAction.test) {
      target = _beamPos;
      turn = _plateTurn;
      _busy = true;
    }
    if (action != null && target != null) {
      final a = action;
      _tweenTo(p, target, 400, Curves.easeOutCubic, turn: turn, onDone: () => _executeDrop(p, a));
    } else {
      // Invalid drop: spring back to the tray (or to the sheet's bin).
      _tweenTo(p, p.binPos ?? m.trayPos, 500, Curves.elasticOut);
      _clearEffect();
    }
  }

  /// HTML `executeDropAction(obj, type)`.
  void _executeDrop(_Plate p, _DropAction action) {
    if (action == _DropAction.predict) {
      _Audio.play(_Sound.drop);
      if (_step == 1 || _step == 3) {
        _advanceStep();
      } else {
        _updateAvailability();
      }
      return;
    }

    _Audio.play(_Sound.test);
    _scene
      ..effect = p.mat.behavior
      ..inBeam = p;
    p
      ..tested = true
      ..draggable = false;

    if (_scenario == 0) {
      _lab.after(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          // The beam is free again as soon as the sheet starts back.
          _busy = false;
          _clearEffect();
          _tweenTo(p, p.mat.trayPos, 600, Curves.linear);
          if (_step < 4) {
            _advanceStep();
          } else if (_plate(_Mat.cloth).tested && _plate(_Mat.plastic).tested) {
            _summaryPending = true;
            _showSummary();
          }
        });
      });
      return;
    }

    final correct = p.inBin == p.mat.behavior;
    _showVerdict(correct);
    _lab.showToast(_t(correct ? 'msg_correct_pred' : 'msg_wrong_pred'), isError: !correct);
    _lab.after(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        // A wrong prediction is corrected to the right bin.
        final bin = p.mat.behavior;
        final slot = p.inBin == bin ? p.binPos! : _binSlot(bin, p);
        p
          ..inBin = bin
          ..binPos = slot;
        _busy = false;
        _clearEffect();
        _tweenTo(p, slot, correct ? 600 : 1000, correct ? Curves.linear : Curves.bounceOut);
        if (_step == 2 || _step == 4) {
          _advanceStep();
        } else if (_step == 5) {
          _checkS2Completion();
        }
      });
    });
  }

  /// HTML `checkS2Completion()`.
  void _checkS2Completion() {
    final all = [_Mat.paper, _Mat.cloth, _Mat.plastic].every((m) => _plate(m).tested);
    if (all) {
      _advanceStep();
    } else {
      _updateAvailability();
    }
  }

  void _showVerdict(bool correct) {
    _verdictCorrect = correct;
    _verdict.forward(from: 0);
  }

  /// Scenario 1 observation summary (HTML `#s1-summary`); its Continue
  /// button leads to the conclusion.
  void _showSummary() {
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('s1_summary_title'),
        icon: Icons.fact_check_rounded,
        extra: _summaryTable(),
        actions: [
          LabAction(
            label: _lab.t('btn_continue'),
            icon: Icons.arrow_forward,
            color: _lab.palette.primary,
            foreground: _lab.palette.onPrimary,
            onTap: () {
              _lab.hidePopup(sound: false);
              setState(_advanceStep);
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- interaction

  /// Raycaster stand-in: the draggable sheet under [p] (design px).
  _Plate? _hit(Offset p) {
    _Plate? best;
    var bestD = double.infinity;
    for (final o in _scene.plates.values) {
      if (!o.draggable || o.tween != null) continue;
      final r = _plateBounds(_scene, o);
      if (!r.contains(p)) continue;
      final d = (r.center - p).distance;
      if (d < bestD) {
        best = o;
        bestD = d;
      }
    }
    return best;
  }

  bool _claims(Offset p) => _lab.isLabActive && _active == null && !_busy && _lab.popup == null && _hit(p) != null;

  /// HTML `pointerdown`.
  void _pointerDown(Offset p) {
    final obj = _hit(p);
    if (obj == null) return;
    setState(() {
      _active = obj;
      _hintVisible = false;
      _pointer = p;
      final w = _unproj(p, obj.pos.z);
      _dragDx = w.x - obj.pos.x;
      _dragDy = w.y - obj.pos.y;
      obj
        ..dragging = true
        ..turn = 0;
      _Audio.play(_Sound.pickup);
    });
  }

  /// HTML `pointermove`: free movement on the sheet's depth plane.
  void _pointerMove(Offset p) {
    final obj = _active;
    if (obj == null) return;
    _pointer = p;
    final w = _unproj(p, obj.pos.z);
    obj.pos = _V3(w.x - _dragDx, w.y - _dragDy, obj.pos.z);
  }

  /// HTML `pointerup`.
  void _pointerUp() {
    final obj = _active;
    if (obj == null) return;
    setState(() {
      _active = null;
      obj.dragging = false;
      _handleDrop(obj);
    });
  }

  List<LabAction> _actions() {
    if (!_summaryPending) return const [];
    return [
      LabAction(
        label: _t('s1_summary_title'),
        icon: Icons.fact_check_rounded,
        color: _Colors.indigo600,
        foreground: Colors.white,
        highlight: true,
        onTap: _showSummary,
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
          icon: Icons.flashlight_on,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          instruction: _done ? _lab.t('msg_scenario_complete') : null,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            if (_hintVisible && _lab.isLabActive) _hintOverlay(s, inset),
            if (_verdictCorrect != null) _verdictOverlay(s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _SheetDragRecognizer: GestureRecognizerFactoryWithHandlers<_SheetDragRecognizer>(
                  () => _SheetDragRecognizer(debugOwner: this),
                  (r) => r
                    ..claims = _claims
                    ..onDown = _pointerDown
                    ..onMove = _pointerMove
                    ..onUp = _pointerUp,
                ),
              },
              child: CustomPaint(
                key: const ValueKey('light-scene'),
                size: _design,
                painter: _LightPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  labels: {
                    for (final m in _Mat.values) m.labelKey: _t(m.labelKey),
                    for (final b in _Behavior.values) ...{b.binKey: _t(b.binKey), b.lightKey: _t(b.lightKey)},
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#drag-instruction`: bouncing hand + hint in the middle of the
  /// canvas until the first sheet is grabbed.
  Widget _hintOverlay(double s, EdgeInsets inset) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(left: inset.left, right: inset.right),
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
      ),
    );
  }

  /// HTML `showValidationUI(isCorrect)`: a large check or cross pops in,
  /// stays for 1.5 s and fades out.
  Widget _verdictOverlay(double s, EdgeInsets inset) {
    final correct = _verdictCorrect!;
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(left: inset.left, right: inset.right),
          child: Center(
            child: AnimatedBuilder(
              animation: _verdict,
              builder: (context, child) {
                final t = _verdict.value * 1.8;
                final pop = Curves.easeOutBack.transform((t / 0.3).clamp(0.0, 1.0));
                final fade = t < 1.5 ? 1.0 : (1 - (t - 1.5) / 0.3).clamp(0.0, 1.0);
                return Opacity(
                  opacity: _verdict.isDismissed ? 0 : fade,
                  child: Transform.scale(scale: 0.5 + 0.5 * pop, child: child),
                );
              },
              child: Icon(
                correct ? Icons.check_circle : Icons.cancel,
                key: ValueKey(correct ? 'verdict-correct' : 'verdict-wrong'),
                size: 128 * s,
                color: correct ? _Colors.green : _Colors.red,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 24)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The three columns of the HTML observation summary.
  Widget _summaryTable() {
    final s = context.labScale;
    final p = _lab.palette;

    Widget column(_Behavior b, List<_Mat> mats) {
      final onHeader = b == _Behavior.translucent ? _Colors.slate900 : Colors.white;
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 6 * s),
              decoration: BoxDecoration(color: b.readout, borderRadius: BorderRadius.circular(8)),
              child: Text(
                _t(b.lightKey),
                textAlign: TextAlign.center,
                style: TextStyle(color: onHeader, fontWeight: FontWeight.w800, fontSize: 13 * s),
              ),
            ),
            for (final m in mats)
              Container(
                key: ValueKey('summary-${m.name}'),
                margin: EdgeInsets.only(top: 8 * s),
                constraints: BoxConstraints(minHeight: 48 * s),
                alignment: Alignment.center,
                padding: EdgeInsets.all(6 * s),
                decoration: BoxDecoration(
                  color: m.tile.withValues(alpha: p.isDark ? 0.16 : 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: m.tile.withValues(alpha: 0.55), width: 2),
                ),
                child: Text(
                  _t(m.labelKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w700, fontSize: 12.5 * s),
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        column(_Behavior.transparent, const [_Mat.plastic, _Mat.glass]),
        SizedBox(width: 8 * s),
        column(_Behavior.translucent, const [_Mat.paper]),
        SizedBox(width: 8 * s),
        column(_Behavior.opaque, const [_Mat.cardboard, _Mat.cloth]),
      ],
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Light through Transparent, Translucent, and Opaque Materials',
    'app_subtitle': 'Class 7 • Light: Shadows and Reflections',
    'scen_1_opt': 'Scenario 1: Light Path Observatory',
    'scen_2_opt': 'Scenario 2: Predict, Test, & Classify',
    'sci_conclusion': 'Success!',
    'drag_drop_hint': 'Drag & Drop objects to interact!',
    's1_summary_title': 'Observation Summary',
    'bright_light': 'Bright Light',
    'dim_light': 'Dim Light',
    'no_light': 'No Light',
    'bin_transparent': 'Transparent',
    'bin_translucent': 'Translucent',
    'bin_opaque': 'Opaque',
    'msg_correct_pred': 'Correct! The material behaves as predicted.',
    'msg_wrong_pred': "Incorrect! Let's correct the classification based on the test.",
    'msg_wrong_drop': 'Please follow the instructions for the current step.',
    // Hard-coded in English in the HTML.
    'msg_predict_first': 'Predict first by dragging to a bin!',
    'conclusion_1':
        'Based on the amount of light that passes through, materials are transparent (all light), translucent (some light), or opaque (no light, creating shadows).',
    'conclusion_2':
        "We can predict a material's property, but testing it in a light path confirms its classification. Clear materials are transparent, frosted/thin materials are translucent, and solid materials are opaque.",
    'obj_glass': 'Glass Pane',
    'obj_paper': 'Tracing Paper',
    'obj_cardboard': 'Cardboard',
    'obj_cloth': 'Thick Cloth',
    'obj_plastic': 'Clear Plastic',
  },
  'hi': {
    'app_title': 'पारदर्शी, पारभासी और अपारदर्शी सामग्रियों के माध्यम से प्रकाश',
    'app_subtitle': 'कक्षा 7 • प्रकाश: छाया और परावर्तन',
    'scen_1_opt': 'परिदृश्य 1: प्रकाश पथ वेधशाला',
    'scen_2_opt': 'परिदृश्य 2: भविष्यवाणी, परीक्षण और वर्गीकरण',
    'sci_conclusion': 'सफलता!',
    'drag_drop_hint': 'बातचीत करने के लिए वस्तुओं को खींचें और छोड़ें!',
    's1_summary_title': 'अवलोकन सारांश',
    'bright_light': 'तेज प्रकाश',
    'dim_light': 'मंद प्रकाश',
    'no_light': 'कोई प्रकाश नहीं',
    'bin_transparent': 'पारदर्शी',
    'bin_translucent': 'पारभासी',
    'bin_opaque': 'अपारदर्शी',
    'msg_correct_pred': 'सही! सामग्री भविष्यवाणी के अनुसार व्यवहार करती है।',
    'msg_wrong_pred': 'गलत! आइए परीक्षण के आधार पर वर्गीकरण को सही करें।',
    'msg_wrong_drop': 'कृपया वर्तमान चरण के निर्देशों का पालन करें।',
    'msg_predict_first': 'पहले किसी बिन में खींचकर भविष्यवाणी करें!',
    'conclusion_1':
        'पारित होने वाले प्रकाश की मात्रा के आधार पर, सामग्री पारदर्शी (सभी प्रकाश), पारभासी (कुछ प्रकाश), या अपारदर्शी (कोई प्रकाश नहीं, छाया बनाना) होती है।',
    'conclusion_2':
        'हम किसी सामग्री की संपत्ति की भविष्यवाणी कर सकते हैं, लेकिन प्रकाश पथ में इसका परीक्षण इसके वर्गीकरण की पुष्टि करता है। स्पष्ट सामग्री पारदर्शी हैं, पाले जैसी/पतली सामग्री पारभासी हैं, और ठोस सामग्री अपारदर्शी हैं।',
    'obj_glass': 'कांच की प्लेट',
    'obj_paper': 'ट्रेसिंग पेपर',
    'obj_cardboard': 'गत्ता',
    'obj_cloth': 'मोटा कपड़ा',
    'obj_plastic': 'स्पष्ट प्लास्टिक',
  },
};

// ========================================================== SCENARIOS

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'To observe and directly experience how different materials affect a beam of light.',
      steps: [
        LabStep(
          concept: 'Transparent Material',
          action: "DRAG the 'Glass Pane' from the tray and DROP it into the path of the light beam.",
          observation: 'The light beam passes through it, and the spot on the screen remains sharp and bright.',
        ),
        LabStep(
          concept: 'Translucent Material',
          action: "DRAG the 'Tracing Paper' into the light beam.",
          observation: 'The spot of light becomes dim, fuzzy, and scattered. It is partially blocked.',
        ),
        LabStep(
          concept: 'Opaque Material',
          action: "DRAG the 'Cardboard' into the light beam.",
          observation: 'The spot of light disappears completely. A crisp, dark shadow is cast.',
        ),
        LabStep(
          concept: 'Free Experimentation',
          action: 'DRAG the remaining objects (Thick Cloth, Clear Plastic Sheet) into the light beam one by one.',
          observation: 'Cloth is opaque (creates shadow). Plastic is transparent (creates bright spot).',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To predict the category of a material and then use the virtual lab to test and confirm the classification.',
      steps: [
        LabStep(
          concept: 'Predicting Transparency',
          action: "DRAG the 'Glass Pane' into the 'Transparent' sorting bin.",
          observation: 'Prediction logged.',
        ),
        LabStep(
          concept: 'Testing Prediction',
          action: "DRAG the 'Glass Pane' from the bin to the light beam to test.",
          observation: 'Bright spot appears. Prediction confirmed!',
        ),
        LabStep(
          concept: 'Predicting Translucency (Intentional Error)',
          action: "DRAG the 'Cardboard' into the 'Translucent' bin.",
          observation: 'Prediction logged.',
        ),
        LabStep(
          concept: 'Testing & Correcting',
          action: "DRAG the 'Cardboard' from the bin to the light beam to test.",
          observation: "Shadow appears. Red X! It autocorrects to the 'Opaque' bin.",
        ),
        LabStep(
          concept: 'Classify Remaining',
          action:
              'Predict and test the Tracing Paper (Translucent), Thick Cloth (Opaque), and Plastic (Transparent). Drag to bin, then drag to beam.',
          observation: 'All materials classified correctly based on physical evidence.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'यह देखने और अनुभव करने के लिए कि विभिन्न सामग्रियां प्रकाश की किरण को कैसे प्रभावित करती हैं।',
      steps: [
        LabStep(
          concept: 'पारदर्शी सामग्री',
          action: "'ग्लास पैन' को ट्रे से खींचें और इसे प्रकाश किरण के पथ में छोड़ दें।",
          observation: 'प्रकाश की किरण इसके माध्यम से गुजरती है, और स्क्रीन पर स्थान तेज और उज्ज्वल रहता है।',
        ),
        LabStep(
          concept: 'पारभासी सामग्री',
          action: "'ट्रेसिंग पेपर' को प्रकाश किरण में खींचें।",
          observation: 'प्रकाश का स्थान मंद, धुंधला और बिखरा हुआ हो जाता है। यह आंशिक रूप से अवरुद्ध है।',
        ),
        LabStep(
          concept: 'अपारदर्शी सामग्री',
          action: "'गत्ते' को प्रकाश किरण में खींचें।",
          observation: 'प्रकाश का स्थान पूरी तरह से गायब हो जाता है। एक कुरकुरी, गहरी छाया डाली जाती है।',
        ),
        LabStep(
          concept: 'स्वतंत्र प्रयोग',
          action: 'शेष वस्तुओं (मोटा कपड़ा, स्पष्ट प्लास्टिक शीट) को एक-एक करके प्रकाश किरण में खींचें।',
          observation: 'कपड़ा अपारदर्शी है (छाया बनाता है)। प्लास्टिक पारदर्शी है (उज्ज्वल स्थान बनाता है)।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'किसी सामग्री की श्रेणी की भविष्यवाणी करना और फिर वर्गीकरण का परीक्षण और पुष्टि करने के लिए आभासी प्रयोगशाला का उपयोग करना।',
      steps: [
        LabStep(
          concept: 'पारदर्शिता की भविष्यवाणी',
          action: "'ग्लास पैन' को 'पारदर्शी' छँटाई बिन में खींचें।",
          observation: 'भविष्यवाणी दर्ज की गई।',
        ),
        LabStep(
          concept: 'परीक्षण भविष्यवाणी',
          action: "परीक्षण करने के लिए बिन से 'ग्लास पैन' को प्रकाश किरण में खींचें।",
          observation: 'उज्ज्वल स्थान दिखाई देता है। भविष्यवाणी की पुष्टि की!',
        ),
        LabStep(
          concept: 'पारभासी की भविष्यवाणी (जानबूझकर त्रुटि)',
          action: "'गत्ते' को 'पारभासी' बिन में खींचें।",
          observation: 'भविष्यवाणी दर्ज की गई।',
        ),
        LabStep(
          concept: 'परीक्षण और सुधार',
          action: "परीक्षण करने के लिए बिन से 'गत्ते' को प्रकाश किरण में खींचें।",
          observation: "छाया दिखाई देती है। लाल एक्स! यह 'अपारदर्शी' बिन में स्वतः सुधार करता है।",
        ),
        LabStep(
          concept: 'शेष वर्गीकृत करें',
          action:
              'ट्रेसिंग पेपर (पारभासी), मोटे कपड़े (अपारदर्शी) और प्लास्टिक (पारदर्शी) की भविष्यवाणी करें और उनका परीक्षण करें। बिन में खींचें, फिर बीम में खींचें।',
          observation: 'भौतिक साक्ष्य के आधार पर सभी सामग्रियों को सही ढंग से वर्गीकृत किया गया है।',
        ),
      ],
    ),
  ],
};

// ============================================================ GEOMETRY

/// Screen board (HTML BoxGeometry 2 x 15 x 20 at x = 20), turned towards
/// the viewer.
abstract final class _Board {
  static const _V3 center = _V3(20, 0, 0);
  static const double hw = 10;
  static const double hh = 7.5;

  static _V3 at(double u, double v) => center + _boardU * u + _up * v;

  static List<_V3> get corners => [at(-hw, hh), at(hw, hh), at(hw, -hh), at(-hw, -hh)];
}

/// Projected circle of radius [r] on the screen board, around the beam axis.
List<Offset> _spot(double r, {int n = 40}) => [
  for (var i = 0; i < n; i++)
    _projV(_Board.at(r * math.cos(i / n * 2 * math.pi), r * math.sin(i / n * 2 * math.pi)) + _boardN * 0.05),
];

/// Projected rim of the torch lens.
List<Offset> _lens() => [
  for (var i = 0; i < 24; i++)
    _proj(_lensX, _lensRadius * math.sin(i / 24 * 2 * math.pi), _lensRadius * math.cos(i / 24 * 2 * math.pi)),
];

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

// ============================================================ PAINTER

class _LightPainter extends CustomPainter {
  _LightPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.labels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> labels;

  static const Color _beamColor = Color(0xFFFFFFAA); // HTML beam 0xffffaa
  static const Color _tableColor = _Colors.slate700; // HTML table 0x334155
  static const Color _trayColor = _Colors.slate500; // HTML tray 0x64748b

  Path _poly(List<_V3> pts) => Path()..addPolygon(pts.map(_projV).toList(), true);

  @override
  void paint(Canvas canvas, Size size) {
    final plates = scene.plates.values.toList();
    final inBeam = scene.inBeam;
    final effect = scene.effect;

    _paintRoom(canvas, size);
    _paintTable(canvas, size);
    if (scene.scenario == 1) {
      for (final b in _Behavior.values) {
        _paintBin(canvas, b, plates.where((p) => p.inBinRest && p.inBin == b && p != inBeam).toList());
      }
    }
    _paintScreen(canvas, effect);
    _paintTorch(canvas);

    // The beam: torch -> sheet (if one is being tested) -> screen.
    final lens = _lens();
    final lensC = _projV(const _V3(_lensX, 0, 0));
    final boardC = _projV(_Board.center);
    if (inBeam != null && effect != null) {
      final corners = _plateCorners(inBeam, 1).map(_projV).toList();
      final plateC = _projV(inBeam.pos);
      _paintBeam(canvas, lens, corners, lensC, plateC, 1);
      _paintPlate(canvas, inBeam, lit: true);
      switch (effect) {
        case _Behavior.transparent:
          _paintBeam(canvas, corners, _spot(_spotRadius), plateC, boardC, 0.9);
        case _Behavior.translucent:
          _paintBeam(canvas, corners, _spot(6.2), plateC, boardC, 0.32, blur: 6);
        case _Behavior.opaque:
          break;
      }
    } else {
      _paintBeam(canvas, lens, _spot(_spotRadius), lensC, boardC, 1);
    }

    // Sheets on their way somewhere (not in the tray, a bin or a hand).
    for (final p in plates) {
      if (p == inBeam || p.dragging || p.inTray || p.inBinRest) continue;
      _paintPlate(canvas, p);
    }
    _paintTrayBack(canvas);
    for (final p in plates.where((p) => p.inTray)) {
      _paintPlate(canvas, p);
    }
    _paintTrayFront(canvas);
    for (final p in plates.where((p) => p.dragging)) {
      _paintPlate(canvas, p);
    }
    labGlow(canvas, lensC, 34, const Color(0xFFFFF4C2), intensity: 0.8);
    if (showLabels) _paintLabels(canvas, plates, effect);
  }

  // --------------------------------------------------------------- room

  void _paintRoom(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    // Back wall (PlaneGeometry at z = -40) in a dark room.
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF060B18), Color(0xFF0F172A), Color(0xFF1A2435)]
              : const [Color(0xFF334155), Color(0xFF475569), Color(0xFF526075)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, _proj(0, -10, -40).dy)),
    );
    final seam = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 2;
    for (var x = -100.0; x <= 100; x += 20) {
      canvas.drawLine(_proj(x, 60, -40), _proj(x, -10, -40), seam);
    }
    // Soft spill of the torch light on the wall behind the screen.
    final c = _proj(10, 0, -40);
    final r = Rect.fromCenter(center: c, width: 640, height: 300);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFF7D6).withValues(alpha: 0.09), const Color(0xFFFFF7D6).withValues(alpha: 0)],
        ).createShader(r),
    );
  }

  // -------------------------------------------------------------- table

  void _paintTable(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    // Table: BoxGeometry(100, 2, 60) at (0, -11, -10).
    final top = _poly(const [_V3(-50, -10, -40), _V3(50, -10, -40), _V3(50, -10, 20), _V3(-50, -10, 20)]);
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_tableColor, isDark ? -0.35 : -0.1), labShade(_tableColor, isDark ? 0 : 0.2)],
        ).createShader(top.getBounds()),
    );
    final grain = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var z = -35.0; z <= 15; z += 6) {
      canvas.drawLine(_proj(-50, -10, z), _proj(50, -10, z), grain);
    }
    // Light pool under the beam.
    final pool = Rect.fromCenter(center: _proj(2, -10, 0), width: 520, height: 46);
    canvas.save();
    canvas.clipPath(top);
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFF7D6).withValues(alpha: 0.14), const Color(0xFFFFF7D6).withValues(alpha: 0)],
        ).createShader(pool),
    );
    canvas.restore();
    final frontTop = _proj(0, -10, 20).dy, frontBottom = _proj(0, -12, 20).dy;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, frontTop, bleed.right, frontBottom),
      Paint()..color = labShade(_tableColor, -0.4),
    );
    canvas.drawLine(
      Offset(bleed.left, frontTop),
      Offset(bleed.right, frontTop),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..strokeWidth = 1.5,
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, frontBottom, bleed.right, bleed.bottom),
      Paint()..color = isDark ? const Color(0xFF020617) : const Color(0xFF1E293B),
    );
  }

  // --------------------------------------------------------------- bins

  /// HTML `buildBins()`: an open box (10 x 8 x 8) tilted towards the viewer
  /// with a tinted front panel, a coloured rim and its class written on it.
  void _paintBin(Canvas canvas, _Behavior b, List<_Plate> contents) {
    const tilt = 0.15;
    final ct = math.cos(tilt), st = math.sin(tilt);
    _V3 w(double lx, double ly, double lz) => _V3(b.binX + lx, 8 + ly * ct - lz * st, _binZ + ly * st + lz * ct);
    final wall = Paint()..color = _Colors.slate600.withValues(alpha: 0.5);
    final back = [w(-5, 8, -4), w(5, 8, -4), w(5, 0, -4), w(-5, 0, -4)];
    final bottom = [w(-5, 0, -4), w(5, 0, -4), w(5, 0, 4), w(-5, 0, 4)];
    final left = [w(-5, 8, -4), w(-5, 8, 4), w(-5, 0, 4), w(-5, 0, -4)];
    final right = [w(5, 8, -4), w(5, 8, 4), w(5, 0, 4), w(5, 0, -4)];
    final front = [w(-5, 8, 4), w(5, 8, 4), w(5, 0, 4), w(-5, 0, 4)];
    for (final face in [back, bottom, left, right]) {
      canvas.drawPath(_poly(face), wall);
    }
    for (final p in contents) {
      _paintPlate(canvas, p);
    }
    canvas.drawPath(_poly(front), Paint()..color = b.binColor.withValues(alpha: 0.35));
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = labShade(b.binColor, 0.25);
    for (final face in [back, front]) {
      canvas.drawPath(_poly(face), rim);
    }
    for (final e in [
      [w(-5, 8, -4), w(-5, 8, 4)],
      [w(5, 8, -4), w(5, 8, 4)],
      [w(-5, 0, -4), w(-5, 0, 4)],
      [w(5, 0, -4), w(5, 0, 4)],
    ]) {
      canvas.drawLine(_projV(e[0]), _projV(e[1]), rim);
    }
    labText(
      canvas,
      labels[b.binKey]!,
      // Low on the front panel, so sheets inside the bin do not hide it.
      _projV(w(0, 1.4, 4.1)),
      size: 14,
      weight: FontWeight.w800,
      maxWidth: 110,
      padding: EdgeInsets.zero,
      shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
    );
  }

  // ------------------------------------------------------------- screen

  void _paintScreen(Canvas canvas, _Behavior? effect) {
    // Stand: BoxGeometry(4, 10, 4) at (21, -7.5, 0), from the table up.
    const standColor = _Colors.slate800;
    const sx = 21.0;
    final base = Rect.fromPoints(_proj(sx - 3, -9.2, 0), _proj(sx + 3, -10, 0));
    labGroundShadow(canvas, _proj(sx, -10, 0), base.width * 1.4, 10, opacity: 0.45);
    labBox3D(canvas, base, 6, standColor);
    final pillar = Rect.fromPoints(_proj(sx - 0.6, -2.5, 0), _proj(sx + 0.6, -9.2, 0));
    canvas.drawRect(pillar, Paint()..color = labShade(standColor, 0.15));

    // Board thickness, then its face.
    final front = _Board.corners;
    final backFace = [for (final c in front) c - _boardN * 0.6];
    canvas.drawPath(
      Path()..addPolygon(_hull([...front.map(_projV), ...backFace.map(_projV)]), true),
      Paint()..color = const Color(0xFF94A3B8),
    );
    final face = _poly(front);
    final bounds = face.getBounds();
    // HTML MeshStandardMaterial 0xf8fafc lit by the torch's spot light.
    canvas.drawPath(
      face,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: const [Color(0xFFD5D2C6), Color(0xFFA4A9B2), Color(0xFF737C8C)],
          stops: const [0, 0.6, 1],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipPath(face);
    final spotC = _projV(_Board.center);
    switch (effect) {
      case null:
      case _Behavior.transparent:
        // Sharp, bright spot (CircleGeometry r 5, additive, opacity 0.9).
        final spot = Path()..addPolygon(_spot(_spotRadius), true);
        canvas.drawPath(
          spot,
          Paint()
            ..color = const Color(0xFFFFFDE7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.drawPath(spot, Paint()..color = Colors.white.withValues(alpha: 0.95));
        labGlow(canvas, spotC, 40, const Color(0xFFFFFFFF), intensity: 0.6);
      case _Behavior.translucent:
        // Dim, fuzzy, scattered spot (r 6, opacity 0.3).
        canvas.drawPath(
          Path()..addPolygon(_spot(6.2), true),
          Paint()
            ..color = const Color(0xFFFFFBEA).withValues(alpha: 0.42)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
      case _Behavior.opaque:
        // Crisp dark shadow (PlaneGeometry 8 x 8, 0x0f172a at 0.9).
        final shadow = [
          _Board.at(-4, 4),
          _Board.at(4, 4),
          _Board.at(4, -4),
          _Board.at(-4, -4),
        ].map((v) => _projV(v + _boardN * 0.05)).toList();
        canvas.drawPath(Path()..addPolygon(shadow, true), Paint()..color = _Colors.slate900.withValues(alpha: 0.9));
    }
    canvas.restore();
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _Colors.slate600,
    );
  }

  // -------------------------------------------------------------- torch

  void _paintTorch(Canvas canvas) {
    // Clamp stand down to the table.
    final top = _proj(-20, -1, 0);
    final foot = _proj(-20, -10, 0);
    final f = _kz(0);
    labGroundShadow(canvas, foot, 5 * f, 1.2 * f, opacity: 0.45);
    canvas.drawOval(
      Rect.fromCenter(center: foot, width: 4 * f, height: 0.9 * f),
      Paint()..color = const Color(0xFF1F2937),
    );
    final rod = Rect.fromLTRB(top.dx - 0.25 * f, top.dy, top.dx + 0.25 * f, foot.dy);
    canvas.drawRect(
      rod,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF374151), Color(0xFF9CA3AF), Color(0xFF374151)],
        ).createShader(rod),
    );
    // Body: CylinderGeometry(1, 1, 4) along x, 0x475569.
    const body = _Colors.slate600;
    final bodyRect = Rect.fromPoints(_proj(-22, 1, 0), _proj(-18, -1, 0));
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(0.3 * f)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(body, 0.45), body, labShade(body, -0.5)],
          stops: const [0, 0.4, 1],
        ).createShader(bodyRect),
    );
    final grip = Paint()
      ..color = labShade(body, -0.45)
      ..strokeWidth = math.max(1, 0.15 * f);
    for (final x in const [-21.4, -21.0, -20.6]) {
      canvas.drawLine(_proj(x, 0.98, 0), _proj(x, -0.98, 0), grip);
    }
    labBox3D(canvas, Rect.fromPoints(_proj(-20.2, 1.35, 0), _proj(-19.4, 1, 0)), 0.2 * f, const Color(0xFFEF4444));
    // Head: CylinderGeometry(1.5, 1, 2), wide end forward, 0x1e293b.
    const head = _Colors.slate800;
    final headPath = Path()
      ..addPolygon([
        _proj(-18, 1, 0),
        _proj(_lensX, _lensRadius + 0.1, 0),
        _proj(_lensX, -_lensRadius - 0.1, 0),
        _proj(-18, -1, 0),
      ], true);
    canvas.drawPath(
      headPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(head, 0.6), head, labShade(head, -0.3)],
          stops: const [0, 0.45, 1],
        ).createShader(headPath.getBounds()),
    );
    // Glowing lens.
    final lens = Rect.fromCenter(center: _proj(_lensX, 0, 0), width: 0.8 * f, height: 2 * _lensRadius * f);
    labGlow(canvas, lens.center, 4 * f, const Color(0xFFFFF7CC), intensity: 0.9);
    canvas.drawOval(lens, Paint()..color = const Color(0xFFFFFBEB));
    canvas.drawOval(
      lens,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 0.15 * f)
        ..color = labShade(head, 0.4),
    );
  }

  // --------------------------------------------------------------- beam

  /// One part of the visible beam (HTML additive cone), between two rims.
  void _paintBeam(
    Canvas canvas,
    List<Offset> from,
    List<Offset> to,
    Offset a,
    Offset b,
    double strength, {
    double blur = 0,
  }) {
    final beam = Path()..addPolygon(_hull([...from, ...to]), true);
    final paint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = ui.Gradient.linear(
        a,
        b,
        [
          _beamColor.withValues(alpha: 0.4 * strength),
          _beamColor.withValues(alpha: 0.2 * strength),
          _beamColor.withValues(alpha: 0.14 * strength),
        ],
        const [0, 0.5, 1],
      );
    if (blur > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(beam, paint);
    // Dust motes drifting along the beam.
    canvas.save();
    canvas.clipPath(beam);
    final mote = Paint()..color = Colors.white.withValues(alpha: 0.32 * strength);
    for (var i = 0; i < 14; i++) {
      final seed = i * 12.9898 + a.dx;
      final u = ((math.sin(seed) * 43758.5453).abs() % 1 + scene.time * 0.06 * (1 + i % 3)) % 1;
      final v = math.sin(seed * 1.7) * 0.5;
      final p = Offset.lerp(a, b, u)! + Offset(0, v * 40 + 4 * math.sin(scene.time + i));
      canvas.drawCircle(p, 1 + (i % 3) * 0.4, mote);
    }
    canvas.restore();
  }

  // -------------------------------------------------------------- sheets

  /// A material sheet: a thin tinted panel with a light edge (HTML
  /// MeshPhysicalMaterial / MeshStandardMaterial + EdgesGeometry).
  void _paintPlate(Canvas canvas, _Plate p, {bool lit = false}) {
    final s = scene.scaleOf(p);
    final m = p.mat;
    final corners = _plateCorners(p, s);
    final pts = corners.map(_projV).toList();
    final face = Path()..addPolygon(pts, true);
    final bounds = face.getBounds();
    final f = _kz(p.pos.z) * s;

    if (p.dragging) {
      labGroundShadow(canvas, _proj(p.pos.x, p.pos.y - 3.2 * s, p.pos.z), 4 * f, 0.8 * f, opacity: 0.22);
    }
    // Sheet thickness (0.2) seen when it is turned or lifted.
    final n = _V3(-math.sin(p.turn), 0, math.cos(p.turn)) * -0.35;
    final backPts = [for (final c in corners) _projV(c + n)];
    canvas.drawPath(
      Path()..addPolygon(_hull([...pts, ...backPts]), true),
      Paint()..color = labShade(m.color, -0.45).withValues(alpha: math.max(m.opacity, 0.35)),
    );

    switch (m) {
      case _Mat.glass:
      case _Mat.plastic:
        canvas.drawPath(
          face,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                m.color.withValues(alpha: m.opacity + 0.12),
                m.color.withValues(alpha: m.opacity),
                m.color.withValues(alpha: m.opacity + 0.08),
              ],
            ).createShader(bounds),
        );
        // Glossy streaks.
        canvas.save();
        canvas.clipPath(face);
        final streak = Paint()
          ..color = Colors.white.withValues(alpha: m == _Mat.glass ? 0.45 : 0.35)
          ..strokeWidth = math.max(1.5, 0.35 * f)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset.lerp(pts[0], pts[3], 0.55)!, Offset.lerp(pts[0], pts[1], 0.55)!, streak);
        canvas.drawLine(
          Offset.lerp(pts[0], pts[3], 0.85)!,
          Offset.lerp(pts[0], pts[1], 0.85)!,
          streak..strokeWidth = math.max(1, 0.18 * f),
        );
        canvas.restore();
      case _Mat.paper:
        canvas.drawPath(face, Paint()..color = m.color.withValues(alpha: m.opacity));
        // Frosted fibres.
        canvas.save();
        canvas.clipPath(face);
        final fibre = Paint()
          ..color = const Color(0xFFD6CFAE).withValues(alpha: 0.35)
          ..strokeWidth = 1;
        for (var i = 1; i < 6; i++) {
          final k = i / 6;
          canvas.drawLine(Offset.lerp(pts[0], pts[3], k)!, Offset.lerp(pts[1], pts[2], k * 0.9 + 0.05)!, fibre);
        }
        if (lit) {
          // The sheet glows as it scatters the light.
          labGlow(canvas, bounds.center, bounds.longestSide * 0.7, const Color(0xFFFFF4C2), intensity: 0.7);
        }
        canvas.restore();
      case _Mat.cardboard:
        canvas.drawPath(
          face,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [labShade(m.color, 0.18), m.color, labShade(m.color, -0.15)],
            ).createShader(bounds),
        );
        // Corrugation ribs.
        final rib = Paint()
          ..color = labShade(m.color, -0.35).withValues(alpha: 0.6)
          ..strokeWidth = 1;
        for (var i = 1; i < 8; i++) {
          final k = i / 8;
          canvas.drawLine(Offset.lerp(pts[0], pts[1], k)!, Offset.lerp(pts[3], pts[2], k)!, rib);
        }
      case _Mat.cloth:
        canvas.drawPath(face, Paint()..color = labShade(m.color, 0.12));
        // Woven threads.
        canvas.save();
        canvas.clipPath(face);
        final thread = Paint()
          ..color = Colors.white.withValues(alpha: 0.07)
          ..strokeWidth = 1;
        for (var i = 1; i < 10; i++) {
          final k = i / 10;
          canvas.drawLine(Offset.lerp(pts[0], pts[1], k)!, Offset.lerp(pts[3], pts[2], k)!, thread);
          canvas.drawLine(Offset.lerp(pts[0], pts[3], k)!, Offset.lerp(pts[1], pts[2], k)!, thread);
        }
        canvas.restore();
    }
    if (lit && m.behavior == _Behavior.opaque) {
      // Lit face towards the torch.
      canvas.drawPath(face, Paint()..color = const Color(0xFFFFF7D6).withValues(alpha: 0.12));
    }
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  // --------------------------------------------------------------- tray

  // Tray: BoxGeometry(30, 1, 10) at (0, -9.5, 5), drawn as an open tray.
  static const double _trayRim = -9;
  static const double _trayFloor = -9.8;

  void _paintTrayBack(Canvas canvas) {
    canvas.drawPath(
      _poly(const [_V3(-15, _trayRim, 0), _V3(15, _trayRim, 0), _V3(15, _trayRim, 10), _V3(-15, _trayRim, 10)]),
      Paint()..color = labShade(_trayColor, 0.1),
    );
    final floor = _poly(const [
      _V3(-14.4, _trayFloor, 0.6),
      _V3(14.4, _trayFloor, 0.6),
      _V3(14.4, _trayFloor, 9.4),
      _V3(-14.4, _trayFloor, 9.4), //
    ]);
    canvas.drawPath(
      floor,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_trayColor, -0.4), labShade(_trayColor, -0.2)],
        ).createShader(floor.getBounds()),
    );
    // The tray's own light (HTML DirectionalLight aimed at the tray).
    final r = Rect.fromCenter(center: _proj(0, _trayFloor, 5), width: 420, height: 70);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0)],
        ).createShader(r),
    );
  }

  void _paintTrayFront(Canvas canvas) {
    final face = _poly(const [_V3(-15, _trayRim, 10), _V3(15, _trayRim, 10), _V3(15, -10.6, 10), _V3(-15, -10.6, 10)]);
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_trayColor, 0.1), labShade(_trayColor, -0.3)],
        ).createShader(face.getBounds()),
    );
    canvas.drawLine(
      _proj(-15, _trayRim, 10),
      _proj(15, _trayRim, 10),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.5,
    );
    labGroundShadow(canvas, _proj(0, -10.6, 10), 470, 14, opacity: 0.35);
  }

  // ------------------------------------------------------------- labels

  void _paintLabels(Canvas canvas, List<_Plate> plates, _Behavior? effect) {
    for (final p in plates) {
      final s = scene.scaleOf(p);
      final active = p.draggable || p.tested;
      // HTML labels sit 3 units above each sheet; in the tray every other
      // one is raised so neighbouring names do not overlap.
      final lift = p.inTray && p.mat.index.isOdd ? 4.6 : 3.0;
      final at = p.pos + _up * (lift * s);
      labPill(canvas, labels[p.mat.labelKey]!, _projV(at), size: 11.5, opacity: active ? 1 : 0.5);
    }
    if (effect != null) {
      // Readout of what reaches the screen.
      final onLight = effect == _Behavior.translucent;
      labPill(
        canvas,
        labels[effect.lightKey]!,
        _projV(_Board.at(0, -_Board.hh - 2.4)),
        size: 13,
        background: effect.readout,
        color: onLight ? _Colors.slate900 : Colors.white,
        border: null,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LightPainter old) =>
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
