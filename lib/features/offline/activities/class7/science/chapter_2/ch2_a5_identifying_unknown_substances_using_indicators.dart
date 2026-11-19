// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 2 • Activity 5
/// Identifying Unknown Substances using Indicators.
///
/// Native Flutter port of `Cl7S-Ch2-A5-Identifying_Unknown_Substances_using_Indicators.html`.
/// Scenario 1: test beakers A, B, C with blue / red litmus and sort them into
/// the Acidic / Basic / Neutral cabinets. Scenario 2: make a red-rose
/// indicator (crush, steep, filter) and use it to sort test tubes X, Y, Z.
class Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPage extends StatefulWidget {
  const Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPage({super.key});

  /// The HTML shuffles the beaker and cabinet positions every run. Tests set
  /// this to keep them in A/B/C and Acidic/Basic/Neutral order (left to right).
  @visibleForTesting
  static bool debugFixedLayout = false;

  @override
  State<Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPage> createState() =>
      _Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, splash 1311.
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
  splash('splash.mp3');

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

/// One running animation (stands in for a TWEEN.js tween).
class _Tween {
  _Tween(this.ms, this.apply, this.curve, this.done);
  final double ms;
  final void Function(double v) apply;
  final Curve curve;
  final VoidCallback? done;
  double t = 0;
}

/// Pan recognizer that only claims touches starting on a draggable object,
/// so empty-canvas drags still reach the zoom / pan viewer.
class _GrabRecognizer extends PanGestureRecognizer {
  _GrabRecognizer();
  bool Function(Offset local)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && (canGrab?.call(event.localPosition) ?? false);
}

/// Tap recognizer that only joins the arena over the clickable pestle.
class _PestleTapRecognizer extends TapGestureRecognizer {
  _PestleTapRecognizer();
  bool Function(Offset local)? canTap;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      super.isPointerAllowed(event) && (canTap?.call(event.localPosition) ?? false);
}

const DeviceGestureSettings _touch = DeviceGestureSettings(touchSlop: 8);

class _Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPageState
    extends State<Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();
  final List<_Tween> _tweens = [];
  late final Ticker _ticker;

  /// Bumped on every scenario rebuild so stale animation callbacks stop.
  int _gen = 0;

  /// HTML `internalStep` (index into the action sequence).
  int _step = 0;

  /// An action animation is running (blocks new drags / clicks).
  bool _busy = false;

  /// HTML `dropperSubstance`.
  String? _substance;

  /// Steeping countdown (seconds left) after pouring hot water.
  int? _steep;
  Timer? _steepTimer;

  bool _summaryVisible = false;
  bool _finished = false;
  Offset _summaryDrag = Offset.zero;
  bool _toastShown = false;
  LabLang? _lastLang;

  _Obj? _downObj;
  _Obj? _dragged;
  Offset _grab = Offset.zero;
  Offset _finger = Offset.zero;

  String _t(String key) => _lab.tr(_i18n, key);
  List<_Req> get _seq => _scene.scenario == 0 ? _seq1 : _seq2;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      final dt = ((t - _scene.time) * 1000).clamp(0.0, 100.0);
      _scene.time = t;
      _stepTweens(dt);
      final d = _dragged;
      if (d != null) d.pos = _finger - _grab + Offset(0, d.lift);
      _frame.value = t;
    })..start();
    _buildScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _steepTimer?.cancel();
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------- animation

  void _stepTweens(double dt) {
    if (_tweens.isEmpty) return;
    final finished = <_Tween>[];
    for (final tw in List.of(_tweens)) {
      tw.t += dt;
      final f = (tw.t / tw.ms).clamp(0.0, 1.0);
      tw.apply(tw.curve.transform(f));
      if (f >= 1) finished.add(tw);
    }
    finished.forEach(_tweens.remove);
    final g = _gen;
    for (final tw in finished) {
      if (g != _gen || !mounted) return;
      tw.done?.call();
    }
  }

  void _tween(int ms, void Function(double v) apply, {Curve curve = Curves.linear, VoidCallback? done}) {
    _tweens.add(_Tween(ms.toDouble(), apply, curve, done));
  }

  void _move(
    _Obj o, {
    Offset? pos,
    double? lift,
    double? rot,
    double? scale,
    int ms = 300,
    Curve curve = Curves.linear,
    VoidCallback? done,
  }) {
    final p0 = o.pos, l0 = o.lift, r0 = o.rot, s0 = o.scale;
    _tween(ms, (v) {
      if (pos != null) o.pos = Offset.lerp(p0, pos, v)!;
      if (lift != null) o.lift = l0 + (lift - l0) * v;
      if (rot != null) o.rot = r0 + (rot - r0) * v;
      if (scale != null) o.scale = s0 + (scale - s0) * v;
    }, curve: curve, done: done);
  }

  /// HTML `returnToStart` (400 ms, dropper tilts back to 45°).
  void _returnToStart(_Obj o, {VoidCallback? done}) {
    o.active = true;
    _move(o, pos: o.home, lift: o.restLift, rot: o.restRot, ms: 400, done: () {
      o.active = false;
      done?.call();
    });
  }

  void _idle() {
    if (mounted) setState(() => _busy = false);
  }

  /// Virtual camera tween (HTML camera / controls.target, 800 ms Cubic.Out).
  void _camTo(Offset focus, double zoom) {
    final f0 = _scene.focus, z0 = _scene.zoom;
    _tween(800, (v) {
      _scene.focus = Offset.lerp(f0, focus, v)!;
      _scene.zoom = z0 + (zoom - z0) * v;
    }, curve: Curves.easeOutCubic);
  }

  // -------------------------------------------------------- scenarios

  /// HTML `loadScenario` / `clearScenario` / `buildScenario1|2`.
  void _buildScenario(int s) {
    _gen++;
    _tweens.clear();
    _steepTimer?.cancel();
    _steepTimer = null;
    _steep = null;
    _lab.cancelPending();
    _dragged = null;
    _downObj = null;
    _busy = false;
    _step = 0;
    _substance = null;
    _summaryVisible = false;
    _finished = false;
    _summaryDrag = Offset.zero;
    _scene.clear(s);
    if (s == 0) {
      _buildLitmus();
    } else {
      _buildRose();
    }
  }

  void _buildLitmus() {
    final sc = _scene;
    final bx = [300.0, 500.0, 700.0];
    final cx = [280.0, 500.0, 720.0];
    if (!Ch2A5IdentifyingUnknownSubstancesUsingIndicatorsPage.debugFixedLayout) {
      bx.shuffle(_rng);
      cx.shuffle(_rng);
    }
    void beaker(String id, String label, double x, Color liquid) {
      sc.objs[id] = _Obj(id, _Kind.beaker, Offset(x, 339), 13.2, liquid: liquid, labelKey: label, labelColor: _cLabelYellow);
    }

    beaker('beakerA', 'bA', bx[0], _cAcid);
    beaker('beakerB', 'bB', bx[1], _cBaseLiq);
    beaker('beakerC', 'bC', bx[2], _cNeutral);
    sc.objs['blueBox'] = _Obj('blueBox', _Kind.litmusBox, const Offset(150, 430), 16.3, body: _cLitBlue, labelKey: 'litB');
    sc.objs['redBox'] = _Obj('redBox', _Kind.litmusBox, const Offset(850, 430), 16.3, body: _cLitRed, labelKey: 'litR');
    sc.objs['dropper'] = _Obj('dropper', _Kind.dropper, const Offset(285, 462), 17.5,
        restRot: -math.pi / 4, restLift: 6, labelKey: 'drop_tool');
    sc.cabinets['cabAcid'] = Offset(cx[0], 100);
    sc.cabinets['cabBase'] = Offset(cx[1], 100);
    sc.cabinets['cabNeutral'] = Offset(cx[2], 100);
    sc.doors.addAll({'cabAcid': 0, 'cabBase': 0, 'cabNeutral': 0});
  }

  void _buildRose() {
    final sc = _scene;
    sc.objs['dropper'] = _Obj('dropper', _Kind.dropper, const Offset(125, 400), 16.8,
        restRot: -math.pi / 4, restLift: 6, labelKey: 'drop_tool');
    sc.objs['petals'] = _Obj('petals', _Kind.bowl, const Offset(257, 374), 16.2, radius: 2.5, height: 2, labelKey: 'petals');
    sc.objs['mortar'] = _Obj('mortar', _Kind.mortar, const Offset(405, 396), 16.8, radius: 2.8, height: 3.5, labelKey: 'mortar');
    sc.objs['pestle'] = _Obj('pestle', _Kind.pestle, const Offset(338, 340), 15.2,
        restRot: -math.pi / 4, restLift: 1.5 * 15.2, labelKey: 'pestle');
    sc.objs['hotWater'] = _Obj('hotWater', _Kind.beaker, const Offset(709, 418), 17.4,
        liquid: _cNeutral, labelKey: 'hotW', labelColor: _cLabelYellow);
    sc.objs['indicatorBeaker'] = _Obj('indicatorBeaker', _Kind.beaker, const Offset(640, 345), 15.4,
        radius: 2.5, height: 5, liquidTop: 2.2, labelKey: 'empB')
      ..draggable = false
      ..level = 0;
    sc.objs['funnel'] = _Obj('funnel', _Kind.funnel, const Offset(550, 335), 14.9, radius: 2.5, labelKey: 'funnel');
    const tx = [302.0, 500.0, 698.0];
    for (var i = 0; i < 3; i++) {
      final id = 'tube${'XYZ'[i]}';
      sc.objs[id] = _Obj(id, _Kind.tube, Offset(tx[i], 266), 13.2,
          radius: 0.8, height: 6.8, liquidTop: 4.2, liquid: _cNeutral, labelKey: 'tube');
    }
    sc.racks['rackAcid'] = const Offset(315, 234);
    sc.racks['rackBase'] = const Offset(500, 234);
    sc.racks['rackNeutral'] = const Offset(685, 234);
    double r() => _rng.nextDouble();
    for (var i = 0; i < 15; i++) {
      sc.bowlPetals.add(_Petal((r() - 0.5) * 2, 0.5 + r() * 0.8, (r() - 0.5) * 2, r() * math.pi, 1.0));
      sc.mortarPetals.add(_Petal((r() - 0.5) * 1.5, 0.3 + r() * 0.8, (r() - 0.5) * 1.5, r() * math.pi, 0.8));
    }
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _buildScenario(index);
    });
  }

  /// Full "Reset Lab" (HTML `resetLab`): back to scenario 1, reshuffled.
  void _fullReset() {
    setState(() {
      _lastLang = LabLang.en;
      _buildScenario(0);
    });
    // Workaround: the shell builds "Enter Lab" disabled while the curtain
    // is closing and nothing rebuilds it afterwards. A no-op notification
    // after the 1.5 s curtain animation has finished re-enables the button.
    for (final ms in const [1700, 2300]) {
      _lab.after(Duration(milliseconds: ms), () {
        if (!_lab.isLabActive) _lab.markLabActive(false);
      });
    }
  }

  // --------------------------------------------------------- gestures

  /// HTML `onDown`: picks the draggable object under the finger.
  bool _canGrab(Offset local) {
    if (!_lab.isLabActive || _lab.panMode || _busy || _dragged != null || _step >= _seq.length) return false;
    final w = _scene.toWorld(local);
    _downObj = null;
    final pestleInMortar = _scene.objs['pestle']?.container == 'mortar';
    for (final o in _scene.paintOrder().reversed) {
      if (!o.draggable) continue;
      if (o.kind == _Kind.mortar && pestleInMortar) continue;
      if (o.bounds.inflate(8).contains(w)) {
        _downObj = o;
        return true;
      }
    }
    return false;
  }

  void _onPanStart(DragStartDetails d) {
    final o = _downObj;
    if (o == null || _busy) return;
    _Audio.play(_Sound.pickup);
    _finger = _scene.toWorld(d.localPosition);
    setState(() {
      _dragged = o;
      o.active = true;
      _grab = o.kind == _Kind.dropper ? Offset(0, -3.0 * o.k) : _finger - o.base;
    });
    // HTML: the dropper turns upright, everything lifts off the bench.
    _move(o, lift: o.restLift + 22, rot: o.kind == _Kind.dropper ? 0 : null, ms: 200);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final o = _dragged;
    if (o == null) return;
    _finger = _scene.toWorld(d.localPosition);
    o.pos = _finger - _grab + Offset(0, o.lift);
    _scene.hoverZone = _nearestZone(o, _scene.zones(exclude: o.id));
  }

  void _onPanEnd(DragEndDetails d) {
    final o = _dragged;
    if (o == null) return;
    _dragged = null;
    _scene.hoverZone = null;
    _drop(o);
  }

  void _onPanCancel() {
    final o = _dragged;
    if (o == null) return;
    _dragged = null;
    _scene.hoverZone = null;
    _returnToStart(o);
  }

  /// Only the pestle in the mortar is clickable (HTML `handleDirectClick`).
  bool _canTap(Offset local) {
    if (!_lab.isLabActive || _lab.panMode || _busy || _step >= _seq.length) return false;
    final p = _scene.objs['pestle'];
    if (p == null || !p.clickable) return false;
    return p.bounds.inflate(14).contains(_scene.toWorld(local));
  }

  void _onTapUp(TapUpDetails d) {
    final p = _scene.objs['pestle'];
    if (p == null || _busy || _step >= _seq.length) return;
    if (_seq[_step].action == 's2_crush') _crush(p);
  }

  static double _rectDist(Rect r, Offset p) {
    final dx = math.max(math.max(r.left - p.dx, 0.0), p.dx - r.right);
    final dy = math.max(math.max(r.top - p.dy, 0.0), p.dy - r.bottom);
    return math.sqrt(dx * dx + dy * dy);
  }

  double _zoneDist(_Obj o, Rect r) => math.min(_rectDist(r, o.base), _rectDist(r, _finger));

  /// Drop zone under the finger / object (the smallest one when several
  /// overlap, e.g. a tube standing in its rack), else the closest zone
  /// within 30 design px.
  String? _nearestZone(_Obj o, Map<String, Rect> zones) {
    String? best;
    var bestD = double.infinity, bestA = double.infinity;
    zones.forEach((id, r) {
      final d = _zoneDist(o, r);
      if (d > 30) return;
      final area = r.width * r.height;
      final better = d < 0.5 ? (bestD >= 0.5 || area < bestA) : d < bestD;
      if (better) {
        best = id;
        bestD = d;
        bestA = area;
      }
    });
    return best;
  }

  /// HTML `onUp`: the required object dropped on (or generously near) its
  /// target succeeds; otherwise the nearest zone is validated, and a
  /// failure shakes the object back to its start.
  void _drop(_Obj o) {
    if (_step >= _seq.length) {
      _returnToStart(o);
      return;
    }
    final req = _seq[_step];
    final zones = _scene.zones(exclude: o.id);
    final closest = _nearestZone(o, zones);
    _toastShown = false;
    var success = false, tried = false;
    String? zoneId = closest;
    if (o.id == req.src) {
      final exp = zones[req.tgt];
      if (exp != null) {
        final d = _zoneDist(o, exp);
        if (d <= 30 || (closest == null && d < 150)) {
          tried = true;
          zoneId = req.tgt;
          success = _validate(o, req.tgt);
        }
      }
    }
    if (!success && !tried && closest != null) {
      zoneId = closest;
      success = _validate(o, closest);
    }
    if (!success) _reject(o, zoneId);
  }

  void _err(String key) {
    _toastShown = true;
    _lab.showToast(_t(key), isError: true);
  }

  /// HTML `validateAction`.
  bool _validate(_Obj o, String tgt) {
    final req = _seq[_step];
    final src = o.id;
    if (tgt.startsWith('cab') && src.startsWith('beaker') && req.tgt != tgt) {
      _err('wrong_cab');
      return false;
    }
    if (tgt.startsWith('rack') && src.startsWith('tube') && req.tgt != tgt) {
      _err('wrong_rack');
      return false;
    }
    if (src == req.src && tgt == req.tgt) {
      if (req.action.startsWith('drop')) {
        if (_scene.scenario == 0) {
          var exp = 'beakerA';
          if (_step >= 7 && _step <= 13) exp = 'beakerB';
          if (_step >= 14 && _step <= 20) exp = 'beakerC';
          if (_substance != exp) {
            _err('wrong_liq');
            return false;
          }
        } else if (_substance != 'indicatorBeaker') {
          _err('wrong_rose');
          return false;
        }
      }
      _execute(req, o);
      return true;
    }
    // Filling from the wrong vessel gets the HTML "wrong liquid" feedback.
    if (src == 'dropper' && req.action == 'fill') {
      if (_scene.scenario == 0 && tgt.startsWith('beaker')) {
        _err('wrong_liq');
        return false;
      }
      if (_scene.scenario == 1 && tgt.startsWith('tube')) {
        _err('wrong_rose');
        return false;
      }
    }
    return false;
  }

  /// HTML `rejectAndShake`: error sound, shake, then back to the start.
  void _reject(_Obj o, String? zoneId) {
    final quiet = zoneId != null && (zoneId.startsWith('cab') || zoneId.startsWith('rack'));
    if (!_toastShown) {
      if (quiet) {
        _Audio.play(_Sound.wrong);
      } else {
        _lab.showToast(_t('err_act'), isError: true);
      }
    }
    setState(() => _busy = true);
    o.active = true;
    final amp = 0.5 * o.k;
    _tween(300, (v) => o.shake = (1 - math.cos(v * math.pi * 6)) / 2 * amp, done: () {
      o.shake = 0;
      _returnToStart(o, done: _idle);
    });
  }

  void _execute(_Req req, _Obj o) {
    setState(() => _busy = true);
    switch (req.action) {
      case 'placeBlue':
      case 'placeRed':
        _placeStrip(o, req.action == 'placeBlue');
      case 'fill':
        _fill(o, req.tgt);
      case 'dropBlue':
      case 'dropRed':
        _dropTest(o, req.tgt);
      case 'sortA':
      case 'sortB':
      case 'sortC':
        _sortBeaker(o, req.tgt);
      case 's2_placePetals':
        _placePetals(o);
      case 's2_placePestle':
        _placePestle(o);
      case 's2_pourWater':
        _pourWater(o);
      case 's2_placeFunnel':
        _placeFunnel(o);
      case 's2_filter':
        _filter(o);
      case 'dropRose':
        _dropRose(o, req.tgt);
      case 'sortTube':
        _sortTube(o, req.tgt);
    }
  }

  /// HTML `advanceLogic`.
  void _advance() {
    setState(() {
      _step++;
      if (_scene.scenario == 0 && (_step == 7 || _step == 14)) _scene.strips.clear();
    });
    if (_step >= _seq.length) {
      final g = _gen;
      _lab.after(const Duration(milliseconds: 800), () {
        if (!mounted || g != _gen) return;
        setState(() {
          _summaryVisible = true;
          _finished = true;
          _summaryDrag = Offset.zero;
        });
        _showObservation();
      });
    }
  }

  // ------------------------------------------------- scenario 1 actions

  /// HTML `createStripOnTile`.
  void _placeStrip(_Obj box, bool blue) {
    final tc = _scene.tileCenter + Offset(0, -0.4 * _scene.tileK);
    _scene.strips[blue ? 'blue' : 'red'] = _Strip(blue, tc + Offset((blue ? -2.5 : 2.5) * _scene.tileK, 0));
    _Audio.play(_Sound.drop);
    _returnToStart(box, done: _idle);
    _advance();
  }

  /// HTML `animateDropperFill` (both scenarios).
  void _fill(_Obj d, String vesselId) {
    final b = _scene.objs[vesselId]!;
    final hi = 7.0 * b.k, lo = 1.5 * b.k;
    d.active = true;
    _move(d, pos: b.pos + const Offset(0, 0.5), lift: hi, rot: 0, ms: 300, done: () {
      _move(d, lift: lo, ms: 200, done: () {
        d.liquid = _scene.scenario == 0 ? b.liquid : _cRose;
        _substance = vesselId;
        _Audio.play(_Sound.pop);
        _move(d, lift: hi, ms: 200, done: () {
          _returnToStart(d, done: _idle);
          _advance();
        });
      });
    });
  }

  /// HTML `animateDropTest`: acid turns blue litmus red, base turns red
  /// litmus blue, anything else shows no change.
  void _dropTest(_Obj d, String stripId) {
    final st = _scene.strips[stripId == 'stripBlue' ? 'blue' : 'red']!;
    final target = st.center;
    d.active = true;
    _move(d, pos: target + const Offset(0, 0.5), lift: 3.4 * _scene.tileK, rot: 0, ms: 300, done: () {
      Color? res;
      if (_substance == 'beakerA' && st.isBlue) res = _cLitRed;
      if (_substance == 'beakerB' && !st.isBlue) res = _cLitBlue;
      final from = d.base;
      final drop = _Drop(from, d.liquid ?? _cNeutral);
      _scene.drop = drop;
      _tween(300, (v) => drop.pos = Offset.lerp(from, target, v)!, curve: Curves.easeIn, done: () {
        _scene.drop = null;
        _Audio.play(_Sound.drop);
        d.liquid = null;
        if (res != null) {
          st.result = res;
          _tween(450, (v) => st.spread = v, curve: Curves.easeOut);
          _lab.showToast(_t('color_chg'));
        } else {
          st.wet = true;
          _lab.showToast(_t('no_chg'));
        }
        _returnToStart(d, done: _idle);
        _advance();
      });
    });
  }

  /// HTML `animateSorting`: door swings open, beaker shrinks inside, door closes.
  void _sortBeaker(_Obj b, String cabId) {
    b.draggable = false;
    _Audio.play(_Sound.pop);
    final cab = _scene.cabinets[cabId]!;
    const open = math.pi / 1.5;
    b.active = true;
    _tween(400, (v) => _scene.doors[cabId] = v * open, curve: Curves.easeOutCubic, done: () {
      _move(b, pos: Offset(cab.dx, cab.dy + 66), lift: 0, scale: 0.65, ms: 400, done: () {
        b.container = cabId;
        b.active = false;
        _tween(400, (v) => _scene.doors[cabId] = (1 - v) * open, curve: Curves.easeInCubic, done: () {
          _Audio.play(_Sound.success);
          _idle();
          _advance();
        });
      });
    });
  }

  // ------------------------------------------------- scenario 2 actions

  _Obj get _mortarObj => _scene.objs['mortar']!;

  void _placePetals(_Obj bowl) {
    final m = _mortarObj;
    bowl.active = true;
    _move(bowl, pos: m.pos + const Offset(0, 0.5), lift: 5 * m.k, ms: 300, done: () {
      _scene.bowlHasPetals = false;
      _scene.mortarHasPetals = true;
      _Audio.play(_Sound.drop);
      _returnToStart(bowl, done: _idle);
      // HTML: the camera flies in to the mortar.
      _camTo(Offset(m.pos.dx, m.pos.dy - 2 * m.k), 2.2);
      _advance();
    });
  }

  void _placePestle(_Obj p) {
    final m = _mortarObj;
    p.active = true;
    _move(p, pos: m.pos + const Offset(0, 0.5), lift: 3 * m.k, rot: p.restRot, ms: 300, done: () {
      p.draggable = false;
      p.clickable = true;
      p.container = 'mortar';
      p.active = false;
      _Audio.play(_Sound.drop);
      _idle();
      _advance();
    });
  }

  /// One pestle click: bob down and up, petals darken and shrink. After the
  /// third crush the petals become pulp and the camera zooms back out.
  void _crush(_Obj p) {
    setState(() => _busy = true);
    final base = p.lift, depth = 1.5 * _mortarObj.k;
    _tween(200, (v) => p.lift = base - depth * math.sin(v * math.pi), done: () {
      p.lift = base;
      _Audio.play(_Sound.drop);
      setState(() => _scene.crush++);
      if (_scene.crush >= 3) {
        p.clickable = false;
        _scene.mortarHasPetals = false;
        _scene.pulp = true;
        _lab.showToast(_t('crush_done'));
        _camTo(_viewCenter, 1);
        // Lift the pestle out so it does not hang in the air when the
        // mortar is moved later.
        p.container = null;
        _returnToStart(p, done: _idle);
        _advance();
      } else {
        _lab.showToast(labFormat(_t('crush_msg'), {'n': _scene.crush}), sound: false);
        _idle();
      }
    });
  }

  void _pourWater(_Obj hw) {
    final m = _mortarObj;
    hw.active = true;
    _move(hw, pos: m.pos + Offset(2 * m.k, 0.5), lift: 6 * m.k, ms: 300, done: () {
      final flow = _Flow('hotWater', m.base + Offset(0, -3.5 * m.k + 4), _cNeutral);
      _scene.flow = flow;
      _tween(500, (v) => flow.alpha = v, curve: Curves.easeIn);
      _move(hw, rot: -math.pi / 3, ms: 500, done: () {
        _Audio.play(_Sound.splash);
        _scene.mortarLiquid = _cRosePale;
        _scene.mortarLevel = 0.1;
        _tween(1000, (v) {
          hw.level = 1 - 0.8 * v;
          _scene.mortarLevel = 0.1 + 0.9 * v;
        }, done: () {
          _scene.flow = null;
          _tween(600, (v) => _scene.mortarLiquid = Color.lerp(_cRosePale, _cRose, v));
          _move(hw, rot: 0, ms: 500, done: () {
            _returnToStart(hw);
            _startSteep();
          });
        });
      });
    });
  }

  /// HTML 5 s steeping countdown shown in the HUD.
  void _startSteep() {
    setState(() => _steep = 5);
    _steepTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final left = (_steep ?? 1) - 1;
      setState(() => _steep = left);
      if (left <= 0) {
        t.cancel();
        _steepTimer = null;
        setState(() => _steep = null);
        _mortarObj.draggable = true;
        _idle();
        _advance();
      }
    });
  }

  void _placeFunnel(_Obj f) {
    final ib = _scene.objs['indicatorBeaker']!;
    f.active = true;
    _move(f, pos: ib.pos + const Offset(0, 0.5), lift: 3.9 * ib.k, ms: 300, done: () {
      f.draggable = false;
      f.active = false;
      _Audio.play(_Sound.drop);
      _idle();
      _advance();
    });
  }

  /// HTML `s2_filter`: pour the extract through the funnel into the beaker.
  void _filter(_Obj m) {
    final f = _scene.objs['funnel']!, ib = _scene.objs['indicatorBeaker']!;
    final coneTop = f.base + Offset(0, -5 * f.k);
    m.active = true;
    _move(m, pos: f.pos + Offset(-3.2 * m.k, 0.5), lift: f.lift + 6.5 * f.k, ms: 400, done: () {
      final flow = _Flow('mortar', coneTop + const Offset(0, 6), _cRose);
      _scene.flow = flow;
      _tween(500, (v) => flow.alpha = v, curve: Curves.easeIn);
      _move(m, rot: math.pi / 3, ms: 500, done: () {
        _Audio.play(_Sound.splash);
        ib.liquid = _cRose;
        ib.level = 0.1;
        _tween(1500, (v) {
          _scene.mortarLevel = 1 - 0.9 * v;
          ib.level = 0.1 + 0.9 * v;
          _scene.funnelWet = math.min(1.0, v * 4);
        }, done: () {
          _scene.mortarLiquid = null;
          _scene.flow = null;
          setState(() => _scene.indIsIndicator = true);
          _tween(400, (v) => _scene.funnelWet = 1 - v);
          _move(m, rot: 0, ms: 500, done: () {
            _returnToStart(m, done: _idle);
            _advance();
          });
        });
      });
    });
  }

  /// HTML `dropRose`: X turns magenta, Y green, Z pale pink.
  void _dropRose(_Obj d, String tubeId) {
    final tube = _scene.objs[tubeId]!;
    d.active = true;
    _move(d, pos: tube.pos + const Offset(0, 0.5), lift: 7.4 * tube.k, rot: 0, ms: 300, done: () {
      final from = d.base;
      final to = tube.base + Offset(0, -4.2 * tube.k);
      final drop = _Drop(from, _cRose);
      _scene.drop = drop;
      _tween(300, (v) => drop.pos = Offset.lerp(from, to, v)!, curve: Curves.easeIn, done: () {
        _scene.drop = null;
        _Audio.play(_Sound.drop);
        d.liquid = null;
        final target = tubeId == 'tubeX' ? _cRose : (tubeId == 'tubeY' ? _cRoseGreen : _cRosePale);
        final c0 = tube.liquid ?? _cNeutral;
        _tween(400, (v) => tube.liquid = Color.lerp(c0, target, v));
        _lab.showToast(_t('color_chg'));
        _returnToStart(d, done: _idle);
        _advance();
      });
    });
  }

  void _sortTube(_Obj t, String rackId) {
    t.draggable = false;
    _Audio.play(_Sound.pop);
    final a = _scene.racks[rackId]!;
    t.active = true;
    _move(t, pos: a + const Offset(0, 0.5), lift: 0.5 * 12.4, ms: 400, done: () {
      t.container = rackId;
      t.active = false;
      _Audio.play(_Sound.success);
      _idle();
      _advance();
    });
  }

  // ---------------------------------------------------- end of scenario

  /// HTML `showObservation` (+ the shell's "Continue" / "Restart Lab").
  void _showObservation() {
    final idx = _scene.scenario;
    _lab.completedScenarios.add(idx);
    final allDone = _lab.completedScenarios.length >= 2;
    _lab.openSidebar();
    _lab.showPopup(() => LabPopupContent(
          title: _t('lab_obs'),
          icon: Icons.lightbulb,
          extra: _observationBody(idx),
          actions: [
            if (allDone)
              LabAction(label: _lab.t('btn_restart'), icon: Icons.restart_alt, onTap: _lab.requestFullReset)
            else
              LabAction(
                label: _lab.t('btn_continue'),
                icon: Icons.arrow_forward,
                color: _Colors.indigo600,
                foreground: Colors.white,
                onTap: () {
                  _lab.hidePopup(sound: false);
                  _lab.showToast(_lab.t('msg_scenario_complete'));
                },
              ),
          ],
        ));
  }

  /// Renders the `<B>` / colour markup of the observation texts.
  List<InlineSpan> _rich(String src, LabPalette p) {
    final re = RegExp(r'<([Brugps])>(.*?)</\1>');
    final out = <InlineSpan>[];
    var last = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > last) out.add(TextSpan(text: src.substring(last, m.start)));
      final Color? col = switch (m.group(1)) {
        'r' => const Color(0xFFEF4444),
        'u' => const Color(0xFF3B82F6),
        'g' => const Color(0xFF22C55E),
        'p' => p.isDark ? const Color(0xFFF9A8D4) : const Color(0xFFDB2777),
        's' => const Color(0xFF94A3B8),
        _ => null,
      };
      out.add(TextSpan(text: m.group(2), style: TextStyle(fontWeight: FontWeight.w800, color: col ?? p.textStrong)));
      last = m.end;
    }
    if (last < src.length) out.add(TextSpan(text: src.substring(last)));
    return out;
  }

  Widget _observationBody(int idx) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final lines = _t(idx == 0 ? 's1_obs' : 's2_obs').split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in lines)
          Padding(
            padding: EdgeInsets.only(bottom: 9 * s),
            child: Text.rich(
              TextSpan(children: _rich(line, p)),
              style: TextStyle(color: p.text, fontSize: 13.5 * f, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------- UI

  /// The HTML re-announces a language switch with a toast.
  void _checkLanguage() {
    final l = _lab.lang;
    if (_lastLang == null) {
      _lastLang = l;
      return;
    }
    if (l == _lastLang) return;
    _lastLang = l;
    if (!_lab.isLabActive) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _lab.showToast(_t('lang_changed'), sound: false);
    });
  }

  /// HTML `updateHUD` (+ the steeping countdown).
  String _instruction() {
    if (_steep != null) return '${_t('steep')} ${_steep}s';
    if (_step < _seq.length) {
      return _hudMsgs[_lab.lang.code]![_scene.scenario == 0 ? 'm1' : 'm2']![_step];
    }
    return _t('comp_sum');
  }

  List<LabAction> _actions() {
    if (!_finished || _summaryVisible) return const [];
    return [
      LabAction(
        label: _t('btn_view_summary'),
        icon: Icons.emoji_events,
        highlight: true,
        onTap: () => setState(() {
          _summaryVisible = true;
          _summaryDrag = Offset.zero;
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        _checkLanguage();
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _scenarios[_lab.lang.code]![_scene.scenario];
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('title'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('scen1'), _t('scen2')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _uiStep(_scene.scenario, _step) + 1,
          instruction: _instruction(),
          actions: _actions(),
          sidebarExtraTitle: _t('steps'),
          sidebarExtra: _stepsList(p, s, data),
          onReset: _fullReset,
          overlays: [if (_summaryVisible) _summaryOverlay(context, s, inset)],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _GrabRecognizer: GestureRecognizerFactoryWithHandlers<_GrabRecognizer>(
                  _GrabRecognizer.new,
                  (r) => r
                    ..canGrab = _canGrab
                    ..gestureSettings = _touch
                    ..dragStartBehavior = DragStartBehavior.down
                    ..onStart = _onPanStart
                    ..onUpdate = _onPanUpdate
                    ..onEnd = _onPanEnd
                    ..onCancel = _onPanCancel,
                ),
                _PestleTapRecognizer: GestureRecognizerFactoryWithHandlers<_PestleTapRecognizer>(
                  _PestleTapRecognizer.new,
                  (r) => r
                    ..canTap = _canTap
                    ..gestureSettings = _touch
                    ..onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _BenchPainter(
                  scene: _scene,
                  repaint: _frame,
                  tr: _t,
                  lang: _lab.lang.code,
                  showLabels: _lab.showLabels,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML "Procedural Steps" list with done / current / upcoming states.
  Widget _stepsList(LabPalette p, double s, LabScenarioData data) {
    final f = s * _lab.fontScale;
    final cur = _uiStep(_scene.scenario, _step);
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
          for (var i = 0; i < data.steps.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20 * s,
                    height: 20 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < cur ? _Colors.green : (i == cur ? _Colors.zslYellow : p.cardBorder),
                      boxShadow: i == cur
                          ? [BoxShadow(color: _Colors.zslYellow.withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 2)]
                          : null,
                    ),
                    child: i < cur
                        ? Icon(Icons.check, size: 12 * s, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w900,
                              color: i == cur ? _Colors.slate900 : p.textMuted,
                            ),
                          ),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: Text(
                      data.steps[i].action,
                      style: TextStyle(
                        fontSize: 11 * f,
                        height: 1.35,
                        fontWeight: i == cur ? FontWeight.w800 : FontWeight.w600,
                        color: i == cur ? p.textStrong : p.textMuted.withValues(alpha: 0.75),
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

  // ------------------------------------------------------ summary screen

  static const Color _gold = Color(0xFFBBA061);

  /// HTML `#summary-overlay`: dimmed canvas + draggable summary card.
  Widget _summaryOverlay(BuildContext context, double s, EdgeInsets inset) {
    final pad = MediaQuery.paddingOf(context);
    final hud = _lab.isSidebarOpen ? 62 * s : 10.0;
    return Positioned.fill(
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Color(0xD9000000)))),
          Positioned(
            left: inset.left + 6,
            right: inset.right + 4,
            top: 44 * s + pad.top,
            bottom: hud + pad.bottom,
            child: Center(
              child: Transform.translate(
                offset: _summaryDrag,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() => _summaryDrag += d.delta),
                  child: FittedBox(fit: BoxFit.scaleDown, child: _summaryBox()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox() {
    final litmus = _scene.scenario == 0;
    return Container(
      width: 640,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D31),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold, width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0xCC000000), blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D31),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gold),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _t(litmus ? 'comp_sum' : 'rose_sum'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (var i = 0; i < 3; i++) Expanded(child: _summaryColumn(i, litmus))],
                ),
                const SizedBox(height: 26),
                _badge(),
              ],
            ),
            Positioned(
              top: -8,
              right: -8,
              child: IconButton(
                onPressed: () {
                  _Audio.play(_Sound.click);
                  setState(() => _summaryVisible = false);
                },
                icon: const Icon(Icons.close, color: _gold, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryColumn(int i, bool litmus) {
    const blue = Color(0xFF3B82F6), red = Color(0xFFEF4444);
    final tint = litmus
        ? const [Color(0xFFFACC15), Color(0xFFF472B6), Color(0xFF93C5FD)][i]
        : const [Color(0xFFF87171), Color(0xFF4ADE80), Color(0xFF93C5FD)][i];
    final badge = Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tint.withValues(alpha: 0.2),
        border: Border.all(color: tint.withValues(alpha: 0.5)),
      ),
      child: litmus
          ? CustomPaint(size: const Size(52, 46), painter: _IconPainter(_Icon.values[i]))
          : Text('XYZ'[i], style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800)),
    );
    final Widget middle;
    if (litmus) {
      Widget strip(Color c, [Color? tip]) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(-0.21),
            child: Container(
              width: 84,
              height: 17,
              decoration: BoxDecoration(
                color: tip == null ? c : null,
                gradient: tip == null
                    ? null
                    : LinearGradient(
                        colors: [c, c, tip.withValues(alpha: 0.9), tip.withValues(alpha: 0.9)],
                        stops: const [0, 0.56, 0.66, 1],
                      ),
                borderRadius: BorderRadius.horizontal(right: Radius.circular(tip == null ? 0 : 4)),
              ),
            ),
          );
      final top = [strip(blue, red), strip(red, blue), strip(blue)][i];
      final bottom = [strip(red), strip(blue), strip(red)][i];
      middle = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          top,
          const SizedBox(height: 6),
          Icon(
            i == 2 ? Icons.remove : Icons.arrow_downward,
            size: 22,
            color: Colors.white.withValues(alpha: i == 2 ? 0.2 : 0.5),
          ),
          const SizedBox(height: 6),
          bottom,
        ],
      );
    } else {
      middle = Container(
        width: 48,
        height: 84,
        decoration: BoxDecoration(
          color: const [Color(0xFF9D174D), Color(0xFF22C55E), Color(0xFFFBCFE8)][i],
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
      );
    }
    final label = litmus
        ? [_t('acid'), _t('base'), _t('neutral')][i]
        : [_t('acidic'), _t('basic'), _t('neutral')][i];
    final lc = litmus
        ? const [Color(0xFFEF4444), Color(0xFF60A5FA), Color(0xFFCBD5E1)][i]
        : const [Color(0xFFEF4444), Color(0xFF4ADE80), Color(0xFFCBD5E1)][i];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          badge,
          const SizedBox(height: 20),
          SizedBox(height: 96, child: Center(child: middle)),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: TextStyle(color: lc, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3)),
          ),
        ],
      ),
    );
  }

  /// "LEARNING OBJECTIVES MET!" medal pill.
  Widget _badge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(46, 10, 30, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C23),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _gold),
            boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('learning'), style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
              Text(_t('met'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
        const Positioned(left: -14, top: -16, child: Icon(Icons.military_tech, color: Color(0xFFFACC15), size: 44)),
      ],
    );
  }
}

// ============================================================ STRINGS
//
// Copied from the HTML `i18n` table (Telugu dropped). Rich observation texts
// use a tiny markup: <B>bold</B>, <r>red</r>, <u>blue</u>, <g>green</g>,
// <p>pink</p>, <s>slate</s> (the HTML `<span class='text-...'>` colours).

const LabStringTable _i18n = {
  'en': {
    'title': 'Identifying Unknown Substances using Indicators',
    'subtitle': 'Class 7 • Acids, Bases and Salts',
    'cur_task': 'Current Task',
    'wait': 'Wait for lab to load...',
    'lab_obs': 'LAB OBSERVATION',
    'mission': 'MISSION OBJECTIVE',
    'steps': 'PROCEDURAL STEPS',
    'conc': 'Conclusion',
    'scen1': 'Scenario 1: The Litmus Test',
    'scen2': 'Scenario 2: The Red Rose Indicator',
    'drop': 'DROP HERE',
    'acidic': 'ACIDIC',
    'basic': 'BASIC',
    'neutral': 'NEUTRAL',
    'acid': 'ACID',
    'base': 'BASE',
    'met': 'LEARNING OBJECTIVES MET!',
    'learning': 'LEARNING',
    'comp_sum': 'Challenge Complete Summary',
    'rose_sum': 'Rose Indicator Summary',
    'bA': 'Beaker A',
    'bB': 'Beaker B',
    'bC': 'Beaker C',
    'litB': 'Blue Litmus',
    'litR': 'Red Litmus',
    'drop_tool': 'Dropper',
    'pestle': 'Pestle',
    'mortar': 'Mortar',
    'funnel': 'Funnel',
    'petals': 'Rose Petals',
    'hotW': 'Hot H₂O',
    'empB': 'Empty Beaker',
    'roseI': 'Rose Indicator',
    'tube': 'Tube',
    'wrong_cab': 'Wrong cabinet! Check litmus results.',
    'wrong_rack': 'Wrong rack! Check color results.',
    'wrong_liq': 'Wrong liquid! Fill dropper from correct beaker.',
    'wrong_rose': 'Fill dropper with Rose Indicator first!',
    'err_act': 'Incorrect action. Follow current task.',
    'steep': 'Waiting for petals to steep...',
    'crush_msg': 'Crushed {n}/3 times. Keep going!',
    'crush_done': 'Petals crushed into pulp!',
    'color_chg': 'Color Changed!',
    'no_chg': 'No Change.',
    'lang_changed': 'Language changed successfully.',
    'btn_view_summary': 'View Summary',
    's1_obj':
        "You are a lab technician. Three unlabeled beakers (A, B, C) have arrived. Use blue and red litmus paper to test each solution and correctly sort them into the 'Acidic,' 'Basic,' and 'Neutral' cabinets.",
    's1_th':
        'Indicators change color to show if a substance is acidic or basic. Acids turn blue litmus red. Bases turn red litmus blue. Neutral substances cause no change.',
    's1_obs': '<B>Analysis Complete!</B>\n'
        '• Beaker A (Lemon Juice) turned blue litmus <r>RED</r>: <B>ACID</B>.\n'
        '• Beaker B (Soap Solution) turned red litmus <u>BLUE</u>: <B>BASE</B>.\n'
        '• Beaker C (Tap Water) showed <s>NO CHANGE</s>: <B>NEUTRAL</B>.',
    's1_con':
        "Acids turn blue litmus red. Bases turn red litmus blue. Neutral substances don't change either.",
    's2_obj':
        'Prepare your own acid-base indicator from red rose petals. Then, use your homemade indicator to determine if three unknown solutions are acidic, basic, or neutral.',
    's2_th':
        'Natural indicators like red rose extract change to a dark pink/magenta color in acids, and turn green when placed in basic solutions.',
    's2_obs': '<B>Rose Indicator Results:</B>\n'
        '• Vinegar (Tube X) turned <r>RED/MAGENTA</r>: <B>ACID</B>.\n'
        '• Baking Soda (Tube Y) turned <g>GREEN</g>: <B>BASE</B>.\n'
        '• Sugar Water (Tube Z) showed <p>PALE PINK (NO CHANGE)</p>: <B>NEUTRAL</B>.',
    's2_con':
        'Natural indicators like Rose Extract are excellent tools. They turn Magenta in Acids and Green in Bases!',
  },
  'hi': {
    'title': 'सूचकों का उपयोग करके अज्ञात पदार्थों की पहचान',
    'subtitle': 'कक्षा 7 • अम्ल, क्षारक और लवण',
    'cur_task': 'वर्तमान कार्य',
    'wait': 'लोड हो रहा है...',
    'lab_obs': 'प्रयोगशाला अवलोकन',
    'mission': 'मिशन उद्देश्य',
    'steps': 'प्रक्रियात्मक चरण',
    'conc': 'निष्कर्ष',
    'scen1': 'परिदृश्य 1: लिटमस परीक्षण',
    'scen2': 'परिदृश्य 2: लाल गुलाब सूचक',
    'drop': 'यहाँ छोड़ें',
    'acidic': 'अम्लीय',
    'basic': 'क्षारीय',
    'neutral': 'उदासीन',
    'acid': 'अम्ल',
    'base': 'क्षारक',
    'met': 'सीखने के उद्देश्य पूरे हुए!',
    'learning': 'सीखना',
    'comp_sum': 'चुनौती पूर्ण सारांश',
    'rose_sum': 'गुलाब सूचक सारांश',
    'bA': 'बीकर A',
    'bB': 'बीकर B',
    'bC': 'बीकर C',
    'litB': 'नीला लिटमस',
    'litR': 'लाल लिटमस',
    'drop_tool': 'ड्रॉपर',
    'pestle': 'मूसल',
    'mortar': 'मोर्टार',
    'funnel': 'फ़नल',
    'petals': 'गुलाब की पंखुड़ियां',
    'hotW': 'गर्म H₂O',
    'empB': 'खाली बीकर',
    'roseI': 'गुलाब सूचक',
    'tube': 'ट्यूब',
    'wrong_cab': 'गलत कैबिनेट! लिटमस परिणामों की जांच करें।',
    'wrong_rack': 'गलत रैक! रंग की जांच करें।',
    'wrong_liq': 'गलत तरल! ड्रॉपर को सही बीकर से भरें।',
    'wrong_rose': 'पहले ड्रॉपर को गुलाब सूचक से भरें!',
    'err_act': 'गलत क्रिया। वर्तमान कार्य का पालन करें।',
    'steep': 'पंखुड़ियों के रंग छोड़ने की प्रतीक्षा...',
    'crush_msg': '{n}/3 बार कुचला। जारी रखें!',
    'crush_done': 'पंखुड़ियां पल्प में बदल गईं!',
    'color_chg': 'रंग बदल गया!',
    'no_chg': 'कोई बदलाव नहीं।',
    'lang_changed': 'भाषा सफलतापूर्वक बदल गई।',
    'btn_view_summary': 'सारांश देखें',
    's1_obj':
        "आप एक लैब तकनीशियन हैं। तीन बिना लेबल वाले बीकर (A, B, C) आए हैं। प्रत्येक घोल का परीक्षण करने के लिए नीले और लाल लिटमस पेपर का उपयोग करें और उन्हें 'अम्लीय', 'क्षारीय', और 'उदासीन' कैबिनेट में सही ढंग से छाँटें।",
    's1_th':
        'सूचक रंग बदलकर बताते हैं कि पदार्थ अम्लीय है या क्षारीय। अम्ल नीले लिटमस को लाल कर देते हैं। क्षारक लाल लिटमस को नीला कर देते हैं। उदासीन पदार्थों से कोई बदलाव नहीं होता।',
    's1_obs': '<B>विश्लेषण पूर्ण!</B>\n'
        '• बीकर A (नींबू का रस) ने नीले लिटमस को <r>लाल</r> किया: <B>अम्ल</B>।\n'
        '• बीकर B (साबुन का घोल) ने लाल लिटमस को <u>नीला</u> किया: <B>क्षारक</B>।\n'
        '• बीकर C (नल का पानी) में <s>कोई बदलाव नहीं</s> हुआ: <B>उदासीन</B>।',
    's1_con':
        'अम्ल नीले लिटमस को लाल कर देते हैं। क्षारक लाल लिटमस को नीला कर देते हैं। उदासीन पदार्थ कोई बदलाव नहीं करते हैं।',
    's2_obj':
        'लाल गुलाब की पंखुड़ियों से अपना स्वयं का अम्ल-क्षारक सूचक तैयार करें। फिर यह निर्धारित करने के लिए इसका उपयोग करें कि तीन अज्ञात घोल अम्लीय, क्षारीय या उदासीन हैं।',
    's2_th':
        'लाल गुलाब के अर्क जैसे प्राकृतिक सूचक अम्लीय घोल में गहरे गुलाबी/मैजेंटा रंग में बदल जाते हैं, और क्षारीय घोल में हरे हो जाते हैं।',
    's2_obs': '<B>गुलाब सूचक परिणाम:</B>\n'
        '• सिरका (ट्यूब X) <r>लाल/मैजेंटा</r> हो गया: <B>अम्ल</B>।\n'
        '• बेकिंग सोडा (ट्यूब Y) <g>हरा</g> हो गया: <B>क्षारक</B>।\n'
        '• चीनी का पानी (ट्यूब Z) <p>हल्का गुलाबी (कोई बदलाव नहीं)</p> रहा: <B>उदासीन</B>।',
    's2_con':
        'गुलाब के अर्क जैसे प्राकृतिक सूचक उत्कृष्ट उपकरण हैं। वे अम्लों में मैजेंटा और क्षारकों में हरे हो जाते हैं!',
  },
};

/// Procedural steps (HTML `u1` / `u2`) shown as "Step n of N".
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          "You are a lab technician. Three unlabeled beakers (A, B, C) have arrived. Use blue and red litmus paper to test each solution and correctly sort them into the 'Acidic,' 'Basic,' and 'Neutral' cabinets.",
      steps: [
        LabStep(concept: '', action: 'Task: DRAG a strip of blue litmus paper from the box and DROP it onto the white tile.'),
        LabStep(concept: '', action: 'Task: DRAG the dropper tool, hover over Beaker A (containing lemon juice) and CLICK to fill.'),
        LabStep(concept: '', action: 'Task: DRAG the filled dropper over the blue litmus paper on the tile and CLICK to release a drop.'),
        LabStep(
            concept: '',
            action:
                'Task: DRAG a strip of red litmus paper from its box and DROP it onto the white tile. DRAG the dropper, CLICK to fill it from Beaker A again, and CLICK over the red litmus paper to release a drop.'),
        LabStep(concept: '', action: "Task: Based on the results, DRAG Beaker A and DROP it into the cabinet labeled 'Acidic'."),
        LabStep(concept: '', action: 'Task: Repeat steps 1-5 for Beaker B (soap solution) and Beaker C (tap water).'),
        LabStep(concept: '', action: 'Task: Once all beakers are sorted, view the summary screen.'),
      ],
    ),
    LabScenarioData(
      objective:
          'Prepare your own acid-base indicator from red rose petals. Then, use your homemade indicator to determine if three unknown solutions are acidic, basic, or neutral.',
      steps: [
        LabStep(concept: '', action: 'Task: DRAG the red rose petals from the bowl and DROP them into the mortar.'),
        LabStep(concept: '', action: 'Task: DRAG the pestle into the mortar. CLICK repeatedly on the pestle to crush the petals.'),
        LabStep(concept: '', action: 'Task: DRAG the beaker of hot water and POUR it into the mortar. Wait to steep.'),
        LabStep(concept: '', action: 'Task: DRAG the filter funnel onto the empty beaker. DRAG the mortar and POUR to extract indicator.'),
        LabStep(concept: '', action: 'Task: DRAG the dropper, CLICK to fill with Red Rose Indicator, APPLY to Test Tube X.'),
        LabStep(concept: '', action: "Task: Based on the red color, DRAG Test Tube X and DROP it into the 'Acidic' test tube rack."),
        LabStep(concept: '', action: "Task: Repeat for Test Tube Y (turns green, 'Basic') and Test Tube Z (no change, 'Neutral')."),
        LabStep(concept: '', action: 'Task: View the summary screen.'),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          "आप एक लैब तकनीशियन हैं। तीन बिना लेबल वाले बीकर (A, B, C) आए हैं। प्रत्येक घोल का परीक्षण करने के लिए नीले और लाल लिटमस पेपर का उपयोग करें और उन्हें 'अम्लीय', 'क्षारीय', और 'उदासीन' कैबिनेट में सही ढंग से छाँटें।",
      steps: [
        LabStep(concept: '', action: 'कार्य: बॉक्स से नीले लिटमस पेपर को खींचें और उसे सफेद टाइल पर छोड़ दें।'),
        LabStep(concept: '', action: 'कार्य: ड्रॉपर को खींचें, बीकर A पर ले जाएं और भरने के लिए क्लिक करें।'),
        LabStep(concept: '', action: 'कार्य: भरे हुए ड्रॉपर को नीले लिटमस पेपर पर खींचें और एक बूंद छोड़ने के लिए क्लिक करें।'),
        LabStep(
            concept: '',
            action:
                'कार्य: लाल लिटमस पेपर खींचें और सफेद टाइल पर छोड़ दें। ड्रॉपर से फिर से बीकर A से भरें, और लाल लिटमस पेपर पर एक बूंद छोड़ें।'),
        LabStep(concept: '', action: "कार्य: परिणामों के आधार पर, बीकर A को खींचें और 'अम्लीय' लेबल वाले कैबिनेट में छोड़ दें।"),
        LabStep(concept: '', action: 'कार्य: बीकर B और बीकर C के लिए चरण 1-5 दोहराएं।'),
        LabStep(concept: '', action: 'कार्य: सारांश स्क्रीन देखें।'),
      ],
    ),
    LabScenarioData(
      objective:
          'लाल गुलाब की पंखुड़ियों से अपना स्वयं का अम्ल-क्षारक सूचक तैयार करें। फिर यह निर्धारित करने के लिए इसका उपयोग करें कि तीन अज्ञात घोल अम्लीय, क्षारीय या उदासीन हैं।',
      steps: [
        LabStep(concept: '', action: 'कार्य: प्याले से लाल गुलाब की पंखुड़ियों को खींचें और मोर्टार में छोड़ दें।'),
        LabStep(concept: '', action: 'कार्य: मूसल को मोर्टार में खींचें। पंखुड़ियों को कुचलने के लिए मूसल पर बार-बार क्लिक करें।'),
        LabStep(concept: '', action: 'कार्य: गर्म पानी के बीकर को खींचें और इसे मोर्टार में डालें। प्रतीक्षा करें।'),
        LabStep(concept: '', action: 'कार्य: फिल्टर कीप को खाली बीकर पर खींचें। मोर्टार को खींचें और सूचक निकालने के लिए डालें।'),
        LabStep(concept: '', action: 'कार्य: ड्रॉपर को खींचें, लाल गुलाब सूचक से भरें, टेस्ट ट्यूब X पर लागू करें।'),
        LabStep(concept: '', action: "कार्य: लाल रंग के आधार पर, टेस्ट ट्यूब X को 'अम्लीय' रैक में छोड़ दें।"),
        LabStep(concept: '', action: "कार्य: टेस्ट ट्यूब Y (हरा, 'क्षारीय') और टेस्ट ट्यूब Z (कोई बदलाव नहीं, 'उदासीन') के लिए दोहराएं।"),
        LabStep(concept: '', action: 'कार्य: सारांश स्क्रीन देखें।'),
      ],
    ),
  ],
};

/// Fine-grained HUD messages for every internal action (HTML `m1` / `m2`).
const Map<String, Map<String, List<String>>> _hudMsgs = {
  'en': {
    'm1': [
      'DRAG Blue Litmus from box to the white tile.',
      'DRAG dropper over Beaker A to fill it.',
      'DRAG filled dropper to Blue Litmus to test.',
      'DRAG Red Litmus from box to the white tile.',
      'FILL dropper from Beaker A again.',
      'APPLY liquid to the Red Litmus.',
      'Result: Blue turned Red. SORT Beaker A into Acidic cabinet.',
      'Testing B: DRAG Blue Litmus to tile.',
      'FILL dropper from Beaker B.',
      'APPLY liquid to Blue Litmus.',
      'Testing B: DRAG Red Litmus to tile.',
      'FILL dropper from Beaker B again.',
      'APPLY liquid to Red Litmus.',
      'Result: Red turned Blue. SORT Beaker B to Basic cabinet.',
      'Testing C: DRAG Blue Litmus to tile.',
      'FILL dropper from Beaker C.',
      'APPLY liquid to Blue Litmus.',
      'Testing C: DRAG Red Litmus to tile.',
      'FILL dropper from Beaker C again.',
      'APPLY liquid to Red Litmus.',
      'Result: No Changes. SORT Beaker C to Neutral cabinet.',
    ],
    'm2': [
      'DRAG the red rose petals into the mortar.',
      'DRAG the pestle into the mortar.',
      'CLICK the pestle in the mortar 3 times to crush petals.',
      'DRAG hot water beaker and POUR into mortar.',
      'DRAG the filter funnel onto the empty beaker.',
      'DRAG the mortar and POUR its contents into the funnel.',
      'FILL dropper with Red Rose Indicator.',
      'APPLY indicator to Test Tube X (Vinegar).',
      'Result: Turned Red/Magenta. SORT Tube X to Acidic rack.',
      'FILL dropper with Indicator.',
      'APPLY indicator to Test Tube Y (Baking Soda).',
      'Result: Turned Green. SORT Tube Y to Basic rack.',
      'FILL dropper with Indicator.',
      'APPLY indicator to Test Tube Z (Sugar).',
      'Result: No Change. SORT Tube Z to Neutral rack.',
    ],
  },
  'hi': {
    'm1': [
      'नीले लिटमस को बॉक्स से सफेद टाइल पर खींचें।',
      'भरने के लिए ड्रॉपर को बीकर A पर खींचें।',
      'परीक्षण के लिए भरे हुए ड्रॉपर को नीले लिटमस पर खींचें।',
      'लाल लिटमस को बॉक्स से सफेद टाइल पर खींचें।',
      'बीकर A से ड्रॉपर को फिर से भरें।',
      'लाल लिटमस पर तरल लागू करें।',
      'परिणाम: नीला लाल हो गया। बीकर A को अम्लीय कैबिनेट में छाँटें।',
      'परीक्षण B: नीले लिटमस को टाइल पर खींचें।',
      'ड्रॉपर को बीकर B से भरें।',
      'नीले लिटमस पर तरल लागू करें।',
      'परीक्षण B: लाल लिटमस को टाइल पर खींचें।',
      'ड्रॉपर को बीकर B से फिर से भरें।',
      'लाल लिटमस पर तरल लागू करें।',
      'परिणाम: लाल नीला हो गया। बीकर B को क्षारीय कैबिनेट में छाँटें।',
      'परीक्षण C: नीले लिटमस को टाइल पर खींचें।',
      'ड्रॉपर को बीकर C से भरें।',
      'नीले लिटमस पर तरल लागू करें।',
      'परीक्षण C: लाल लिटमस को टाइल पर खींचें।',
      'ड्रॉपर को बीकर C से फिर से भरें।',
      'लाल लिटमस पर तरल लागू करें।',
      'परिणाम: कोई बदलाव नहीं। बीकर C को उदासीन कैबिनेट में छाँटें।',
    ],
    'm2': [
      'लाल गुलाब की पंखुड़ियों को मोर्टार में खींचें।',
      'मूसल को मोर्टार में खींचें।',
      'पंखुड़ियों को कुचलने के लिए मूसल पर 3 बार क्लिक करें।',
      'गर्म पानी का बीकर खींचें और मोर्टार में डालें।',
      'फिल्टर कीप को खाली बीकर पर खींचें।',
      'मोर्टार को खींचें और सामग्री को कीप में डालें।',
      'लाल गुलाब सूचक से ड्रॉपर भरें।',
      'टेस्ट ट्यूब X (सिरका) पर सूचक लागू करें।',
      'परिणाम: लाल/मैजेंटा हो गया। ट्यूब X को अम्लीय रैक में छाँटें।',
      'सूचक से ड्रॉपर भरें।',
      'टेस्ट ट्यूब Y (बेकिंग सोडा) पर सूचक लागू करें।',
      'परिणाम: हरा हो गया। ट्यूब Y को क्षारीय रैक में छाँटें।',
      'सूचक से ड्रॉपर भरें।',
      'टेस्ट ट्यूब Z (चीनी) पर सूचक लागू करें।',
      'परिणाम: कोई बदलाव नहीं। ट्यूब Z को उदासीन रैक में छाँटें।',
    ],
  },
};

/// One required action (HTML `getSeq1()` / `getSeq2()` entries).
class _Req {
  const _Req(this.src, this.tgt, this.action);
  final String src;
  final String tgt;
  final String action;
}

const List<_Req> _seq1 = [
  _Req('blueBox', 'tile', 'placeBlue'),
  _Req('dropper', 'beakerA', 'fill'),
  _Req('dropper', 'stripBlue', 'dropBlue'),
  _Req('redBox', 'tile', 'placeRed'),
  _Req('dropper', 'beakerA', 'fill'),
  _Req('dropper', 'stripRed', 'dropRed'),
  _Req('beakerA', 'cabAcid', 'sortA'),
  _Req('blueBox', 'tile', 'placeBlue'),
  _Req('dropper', 'beakerB', 'fill'),
  _Req('dropper', 'stripBlue', 'dropBlue'),
  _Req('redBox', 'tile', 'placeRed'),
  _Req('dropper', 'beakerB', 'fill'),
  _Req('dropper', 'stripRed', 'dropRed'),
  _Req('beakerB', 'cabBase', 'sortB'),
  _Req('blueBox', 'tile', 'placeBlue'),
  _Req('dropper', 'beakerC', 'fill'),
  _Req('dropper', 'stripBlue', 'dropBlue'),
  _Req('redBox', 'tile', 'placeRed'),
  _Req('dropper', 'beakerC', 'fill'),
  _Req('dropper', 'stripRed', 'dropRed'),
  _Req('beakerC', 'cabNeutral', 'sortC'),
];

const List<_Req> _seq2 = [
  _Req('petals', 'mortar', 's2_placePetals'),
  _Req('pestle', 'mortar', 's2_placePestle'),
  _Req('pestle', 'pestle', 's2_crush'),
  _Req('hotWater', 'mortar', 's2_pourWater'),
  _Req('funnel', 'indicatorBeaker', 's2_placeFunnel'),
  _Req('mortar', 'funnel', 's2_filter'),
  _Req('dropper', 'indicatorBeaker', 'fill'),
  _Req('dropper', 'tubeX', 'dropRose'),
  _Req('tubeX', 'rackAcid', 'sortTube'),
  _Req('dropper', 'indicatorBeaker', 'fill'),
  _Req('dropper', 'tubeY', 'dropRose'),
  _Req('tubeY', 'rackBase', 'sortTube'),
  _Req('dropper', 'indicatorBeaker', 'fill'),
  _Req('dropper', 'tubeZ', 'dropRose'),
  _Req('tubeZ', 'rackNeutral', 'sortTube'),
];

/// HTML `getUIStep()`: internal action index -> 0-based procedural step.
int _uiStep(int scenario, int i) {
  if (scenario == 0) {
    if (i <= 2) return i;
    if (i <= 5) return 3;
    if (i == 6) return 4;
    if (i <= 20) return 5;
    return 6;
  }
  if (i == 0) return 0;
  if (i <= 2) return 1;
  if (i == 3) return 2;
  if (i <= 5) return 3;
  if (i <= 7) return 4;
  if (i == 8) return 5;
  if (i <= 14) return 6;
  return 7;
}

// ======================================================== SCENE MODEL
//
// The Three.js bench is redrawn as a 2.5D illustration in a 1000x560 design
// space. Object anchors come from projecting the HTML world positions
// through the HTML camera; each object is then drawn in a local oblique
// frame (x right, y up, z towards the viewer) scaled by `k` px per unit.

const Size _design = Size(1000, 560);
const Offset _viewCenter = Offset(500, 280);

/// Ellipse ratio of horizontal circles (camera elevation).
const double _e = 0.5;

// HTML material colours.
const Color _cWall = Color(0xFF334155);
const Color _cBench = Color(0xFF1E293B);
const Color _cGlass = Color(0xFF7DD3FC);
const Color _cWood = Color(0xFFA16207);
const Color _cRackWood = Color(0xFFF59E0B);
const Color _cMortar = Color(0xFF15803D);
const Color _cMortarIn = Color(0xFF064E3B);
const Color _cMortarBand = Color(0xFFEAB308);
const Color _cStone = Color(0xFF222222);
const Color _cAcid = Color(0xD9FACC15); // liquidAcid, opacity 0.85
const Color _cBaseLiq = Color(0xF2E2E8F0); // liquidBase, opacity 0.95
const Color _cNeutral = Color(0x9938BDF8); // liquidNeutral, opacity 0.6
const Color _cLitBlue = Color(0xFF3B82F6);
const Color _cLitRed = Color(0xFFEF4444);
const Color _cBulb = Color(0xFF111827);
const Color _cPetal = Color(0xFFBE123C);
const Color _cPetalCrushed = Color(0xFF4A0404);
const Color _cRose = Color(0xE69D174D); // roseExtract, opacity 0.9
const Color _cRoseGreen = Color(0xE622C55E); // roseExtractGreen
const Color _cRosePale = Color(0xB3FBCFE8); // roseExtractPale, opacity 0.7
const Color _cLabelYellow = Color(0xFFFACC15);

enum _Kind { beaker, litmusBox, dropper, bowl, mortar, pestle, funnel, tube }

enum _Icon { lemon, soap, tap }

/// A draggable / animated bench object (HTML `THREE.Group` + userData).
class _Obj {
  _Obj(
    this.id,
    this.kind,
    this.home,
    this.k, {
    this.restRot = 0,
    this.restLift = 0,
    this.liquid,
    this.body,
    this.radius = 2.2,
    this.height = 4.5,
    this.liquidTop = 3.1,
    this.labelKey,
    this.labelColor = Colors.white,
  })  : pos = home,
        lift = restLift,
        rot = restRot;

  final String id;
  final _Kind kind;
  final Offset home;

  /// Pixels per world unit at the object's bench position.
  final double k;
  final double restRot;
  final double restLift;

  /// Bench point under the object (shadow position).
  Offset pos;

  /// Height of the drawn base above [pos] in px.
  double lift;

  /// Screen rotation in radians (+ = clockwise).
  double rot;
  double scale = 1;
  double shake = 0;
  bool draggable = true;
  bool clickable = false;

  /// Held or animating: drawn above everything else.
  bool active = false;

  /// Cabinet / rack / mortar id when stored inside it.
  String? container;

  /// Liquid colour (null = empty) and level multiplier.
  Color? liquid;
  double level = 1;

  /// Body colour (litmus boxes).
  final Color? body;

  /// Vessel radius / height in world units.
  final double radius;
  final double height;
  final double liquidTop;
  String? labelKey;
  Color labelColor;

  /// Where the object is drawn: its base / tip / head point.
  Offset get base => pos + Offset(shake, -lift);

  /// Local bounding box in world units (y down), before rotation.
  Rect get localBox {
    switch (kind) {
      case _Kind.beaker:
        return Rect.fromLTRB(-radius - 0.4, -height - radius * _e, radius + 0.1, radius * _e);
      case _Kind.litmusBox:
        return const Rect.fromLTRB(-2.6, -2.0, 2.6, 1.7);
      case _Kind.dropper:
        return const Rect.fromLTRB(-1.1, -6.6, 1.1, 0.2);
      case _Kind.bowl:
        return const Rect.fromLTRB(-2.6, -2.0 - 2.5 * _e, 2.6, 1.5 * _e);
      case _Kind.mortar:
        return const Rect.fromLTRB(-2.9, -3.5 - 2.8 * _e, 2.9, 2.0 * _e);
      case _Kind.pestle:
        return const Rect.fromLTRB(-1.0, -5.0, 1.0, 1.0);
      case _Kind.funnel:
        return const Rect.fromLTRB(-2.6, -5.0 - 2.5 * _e, 2.6, 0.2);
      case _Kind.tube:
        return const Rect.fromLTRB(-0.85, -6.8 - 0.8 * _e, 0.85, 0.1);
    }
  }

  /// Rotation pivot in local units (vessels pour about their middle).
  Offset get pivot {
    switch (kind) {
      case _Kind.beaker:
        return Offset(0, -height / 2);
      case _Kind.mortar:
        return const Offset(0, -1.75);
      default:
        return Offset.zero;
    }
  }

  /// Maps a local point (world units, y down) to design coordinates.
  Offset map(Offset local) {
    final p = (local - pivot) * k * scale;
    final c = math.cos(rot), s = math.sin(rot);
    final r = Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c);
    return base + pivot * k * scale + r;
  }

  /// Axis-aligned design-space bounds (hit-testing and drop zones).
  Rect get bounds {
    final b = localBox;
    final pts = [b.topLeft, b.topRight, b.bottomLeft, b.bottomRight].map(map).toList();
    var l = pts.first.dx, t = pts.first.dy, r = l, btm = t;
    for (final p in pts) {
      l = math.min(l, p.dx);
      r = math.max(r, p.dx);
      t = math.min(t, p.dy);
      btm = math.max(btm, p.dy);
    }
    return Rect.fromLTRB(l, t, r, btm);
  }

  /// Pouring lip of a tilted vessel (rim edge on the downhill side).
  Offset get lip {
    final top = kind == _Kind.mortar ? 3.5 : height;
    final r = kind == _Kind.mortar ? 2.8 : radius;
    return map(Offset(rot < 0 ? -r : r, -top));
  }
}

/// A litmus strip lying on the white tile.
class _Strip {
  _Strip(this.isBlue, this.center);
  final bool isBlue;
  final Offset center;
  Color? result;
  double spread = 0;
  bool wet = false;

  Color get baseColor => isBlue ? _cLitBlue : _cLitRed;
}

/// A crushable rose petal (random pose, like the HTML PlaneGeometry petals).
class _Petal {
  _Petal(this.x, this.y, this.z, this.angle, this.size);
  final double x, y, z, angle, size;
}

/// Falling droplet.
class _Drop {
  _Drop(this.pos, this.color);
  Offset pos;
  final Color color;
}

/// Liquid stream from a tilted vessel's lip to [to].
class _Flow {
  _Flow(this.fromId, this.to, this.color);
  final String fromId;
  final Offset to;
  final Color color;
  double alpha = 0;
}

class _Scene {
  int scenario = 0;
  double time = 0;
  final Map<String, _Obj> objs = {};

  // Scenario 1.
  final Map<String, Offset> cabinets = {};
  final Map<String, double> doors = {};
  final Map<String, _Strip> strips = {};

  // Scenario 2.
  final Map<String, Offset> racks = {};
  final List<_Petal> bowlPetals = [];
  final List<_Petal> mortarPetals = [];
  bool bowlHasPetals = true;
  bool mortarHasPetals = false;
  int crush = 0;
  bool pulp = false;
  Color? mortarLiquid;
  double mortarLevel = 0;
  bool indIsIndicator = false;
  double funnelWet = 0;

  // Effects / UI.
  _Drop? drop;
  _Flow? flow;
  String? hoverZone;

  // Virtual camera (HTML camera tweens to the mortar and back).
  double zoom = 1;
  Offset focus = _viewCenter;

  Offset get tileCenter => scenario == 0 ? const Offset(500, 437) : const Offset(500, 418);
  double get tileK => scenario == 0 ? 16.3 : 17.4;
  double get tileSize => scenario == 0 ? 8 : 6;
  double get benchBack => scenario == 0 ? 280 : 234;

  static const Size cabinetSize = Size(112, 140);

  void clear(int s) {
    scenario = s;
    objs.clear();
    cabinets.clear();
    doors.clear();
    strips.clear();
    racks.clear();
    bowlPetals.clear();
    mortarPetals.clear();
    bowlHasPetals = true;
    mortarHasPetals = false;
    crush = 0;
    pulp = false;
    mortarLiquid = null;
    mortarLevel = 0;
    indIsIndicator = false;
    funnelWet = 0;
    drop = null;
    flow = null;
    hoverZone = null;
    zoom = 1;
    focus = _viewCenter;
  }

  /// Design point -> screen point of the stage under the virtual camera.
  Offset toView(Offset world) => (world - focus) * zoom + _viewCenter;

  /// Stage point -> design point (inverse of [toView]).
  Offset toWorld(Offset view) => (view - _viewCenter) / zoom + focus;

  Rect get tileRect {
    final hw = tileSize / 2 * tileK;
    final hd = tileSize / 2 * tileK * _e;
    return Rect.fromLTRB(tileCenter.dx - hw, tileCenter.dy - hd - 6, tileCenter.dx + hw, tileCenter.dy + hd);
  }

  Rect stripRect(_Strip s) {
    final hw = 1.0 * tileK;
    final hd = 3.0 * tileK * _e;
    return Rect.fromLTRB(s.center.dx - hw, s.center.dy - hd, s.center.dx + hw, s.center.dy + hd);
  }

  Rect cabinetRect(Offset c) =>
      Rect.fromCenter(center: c, width: cabinetSize.width, height: cabinetSize.height + 12);

  Rect rackRect(Offset a) => Rect.fromLTRB(a.dx - 52, a.dy - 70, a.dx + 52, a.dy + 14);

  /// Drop zones (HTML `dropZones`) as design rects, excluding [exclude].
  Map<String, Rect> zones({String? exclude}) {
    final z = <String, Rect>{'tile': tileRect};
    if (scenario == 0) {
      if (strips['blue'] != null) z['stripBlue'] = stripRect(strips['blue']!).inflate(4);
      if (strips['red'] != null) z['stripRed'] = stripRect(strips['red']!).inflate(4);
      for (final id in ['beakerA', 'beakerB', 'beakerC']) {
        final o = objs[id];
        if (o != null && id != exclude) z[id] = o.bounds;
      }
      cabinets.forEach((id, c) => z[id] = cabinetRect(c));
    } else {
      for (final id in ['mortar', 'indicatorBeaker', 'funnel', 'tubeX', 'tubeY', 'tubeZ']) {
        final o = objs[id];
        if (o != null && id != exclude) z[id] = o.bounds;
      }
      racks.forEach((id, a) => z[id] = rackRect(a));
    }
    z.remove(exclude);
    return z;
  }

  /// Objects in paint order: resting ones back-to-front, held / animating
  /// objects last (on top). Objects stored in cabinets / racks / the mortar
  /// are painted by their container.
  List<_Obj> paintOrder() {
    final rest = objs.values.where((o) => o.container == null && !o.active).toList()
      ..sort((a, b) => a.pos.dy.compareTo(b.pos.dy));
    final act = objs.values.where((o) => o.container == null && o.active);
    return [...rest, ...act];
  }
}

// ============================================================ PAINTER

class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.tr,
    required this.lang,
    required this.showLabels,
  }) : super(repaint: repaint);

  final _Scene scene;
  final String Function(String key) tr;
  final String lang;
  final bool showLabels;

  static const List<String> _cabIds = ['cabAcid', 'cabBase', 'cabNeutral'];
  static const Map<String, _Icon> _cabIcons = {'cabAcid': _Icon.lemon, 'cabBase': _Icon.soap, 'cabNeutral': _Icon.tap};
  static const Map<String, String> _zoneKeys = {
    'cabAcid': 'acidic', 'cabBase': 'basic', 'cabNeutral': 'neutral', //
    'rackAcid': 'acidic', 'rackBase': 'basic', 'rackNeutral': 'neutral',
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(_viewCenter.dx, _viewCenter.dy);
    canvas.scale(scene.zoom);
    canvas.translate(-scene.focus.dx, -scene.focus.dy);

    _background(canvas, size);
    if (scene.scenario == 0) {
      for (final id in _cabIds) {
        final c = scene.cabinets[id];
        if (c != null) _cabinet(canvas, id, c);
      }
    } else {
      scene.racks.forEach((id, a) => _rack(canvas, id, a));
    }
    _tile(canvas);
    for (final s in scene.strips.values) {
      _strip(canvas, s);
    }
    for (final o in scene.paintOrder()) {
      _object(canvas, o);
    }
    _effects(canvas);
    _hover(canvas);
    if (showLabels) _labels(canvas);
    canvas.restore();
  }

  // ---------------------------------------------------------- room

  void _background(Canvas c, Size size) {
    final b = labBleed(size);
    final y = scene.benchBack;
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, y),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3F4E66), _cWall],
        ).createShader(Rect.fromLTRB(0, 0, 1000, y)),
    );
    // Tiled lab wall.
    final grout = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    var row = 0;
    for (double ty = y - 44; ty > b.top; ty -= 44, row++) {
      c.drawLine(Offset(b.left, ty), Offset(b.right, ty), grout);
      for (double tx = (row.isEven ? 0 : 33) - 66.0 * 20; tx < b.right; tx += 66) {
        if (tx < b.left) continue;
        c.drawLine(Offset(tx, ty), Offset(tx, ty + 44), grout);
      }
    }
    // Soft light from the directional lamp (upper right).
    labGlow(c, const Offset(760, 40), 420, Colors.white, intensity: 0.08);
    // Shadow where the bench meets the wall, then the bench top.
    c.drawRect(
      Rect.fromLTRB(b.left, y - 14, b.right, y),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.28)],
        ).createShader(Rect.fromLTRB(0, y - 14, 10, y)),
    );
    c.drawRect(
      Rect.fromLTRB(b.left, y, b.right, b.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B3A52), _cBench],
        ).createShader(Rect.fromLTRB(0, y, 10, 560)),
    );
    c.drawLine(
      Offset(b.left, y),
      Offset(b.right, y),
      Paint()
        ..color = const Color(0xFF52627A)
        ..strokeWidth = 2,
    );
  }

  // ------------------------------------------------------ cabinets

  void _cabinet(Canvas c, String id, Offset ctr) {
    final w = _Scene.cabinetSize.width, h = _Scene.cabinetSize.height;
    const d = 24.0, t = 6.0;
    final sk = (500 - ctr.dx) * 0.05;
    final front = Rect.fromCenter(center: ctr + const Offset(0, d / 2), width: w, height: h);
    final back = front.shift(Offset(sk, -d));
    c.drawRRect(
      RRect.fromRectAndRadius(back.inflate(4).shift(const Offset(3, 8)), const Radius.circular(6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    Path quad(Offset a, Offset b, Offset cc, Offset dd) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(cc.dx, cc.dy)
      ..lineTo(dd.dx, dd.dy)
      ..close();
    // Outer top and side faces.
    c.drawPath(quad(front.topLeft, front.topRight, back.topRight, back.topLeft), Paint()..color = labShade(_cWood, 0.22));
    if (sk > 0) {
      c.drawPath(quad(front.topRight, back.topRight, back.bottomRight, front.bottomRight), Paint()..color = labShade(_cWood, -0.32));
    } else {
      c.drawPath(quad(front.topLeft, back.topLeft, back.bottomLeft, front.bottomLeft), Paint()..color = labShade(_cWood, -0.32));
    }
    // Interior.
    final fi = front.deflate(t), bi = back.deflate(t);
    c.drawRect(fi, Paint()..color = const Color(0xFF262626));
    c.drawRect(
      bi,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2A2A), Color(0xFF3A3A3A)],
        ).createShader(bi),
    );
    c.drawPath(quad(fi.bottomLeft, fi.bottomRight, bi.bottomRight, bi.bottomLeft), Paint()..color = const Color(0xFF474747));
    c.drawPath(quad(fi.topLeft, fi.topRight, bi.topRight, bi.topLeft), Paint()..color = const Color(0xFF1C1C1C));
    if (sk > 0) {
      c.drawPath(quad(fi.topLeft, bi.topLeft, bi.bottomLeft, fi.bottomLeft), Paint()..color = const Color(0xFF303030));
    } else {
      c.drawPath(quad(fi.topRight, bi.topRight, bi.bottomRight, fi.bottomRight), Paint()..color = const Color(0xFF303030));
    }
    // Beakers already sorted into this cabinet.
    for (final o in scene.objs.values) {
      if (o.container == id) _object(c, o);
    }
    // Front frame.
    final frame = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(front)
      ..addRect(fi);
    c.drawPath(
      frame,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_cWood, 0.12), labShade(_cWood, -0.18)],
        ).createShader(front),
    );
    c.drawRect(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(_cWood, -0.5),
    );
    _door(c, id, front, scene.doors[id] ?? 0);
  }

  /// Glass door hinged on the left; [angle] 0 = closed, 2.09 = open
  /// (HTML `door.rotation.y` tween to PI / 1.5). It swings towards the viewer.
  void _door(Canvas c, String id, Rect front, double angle) {
    const inset = 3.0, bw = 5.0;
    final wd = front.width - inset * 2, hd = front.height - inset * 2;
    c.save();
    c.translate(front.left + inset, front.center.dy);
    final m = Matrix4.identity()
      ..setEntry(0, 0, math.cos(angle))
      ..setEntry(1, 0, math.sin(angle) * _e);
    c.transform(m.storage);
    final r = Rect.fromLTWH(0, -hd / 2, wd, hd);
    final pane = r.deflate(bw);
    c.drawRect(pane, Paint()..color = _cGlass.withValues(alpha: 0.16));
    // Glass reflections.
    c.save();
    c.clipRect(pane);
    final streak = Paint()..color = Colors.white.withValues(alpha: 0.10);
    for (final x0 in [pane.left + 10.0, pane.left + 38.0]) {
      c.drawPath(
        Path()
          ..moveTo(x0, pane.bottom)
          ..lineTo(x0 + 16, pane.bottom)
          ..lineTo(x0 + 16 + pane.height * 0.45, pane.top)
          ..lineTo(x0 + pane.height * 0.45, pane.top)
          ..close(),
        streak,
      );
    }
    c.restore();
    final frame = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(r)
      ..addRect(pane);
    c.drawPath(frame, Paint()..color = labShade(_cWood, 0.05));
    c.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(_cWood, -0.45),
    );
    labSphere(c, Offset(r.right - 10, 4), 3.2, const Color(0xFFD4A017));
    if (showLabels) {
      final cx = r.center.dx;
      final text = tr(_zoneKeys[id]!);
      final plate = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, -47), width: 86, height: 22), const Radius.circular(6));
      c.drawRRect(plate, Paint()..color = const Color(0xFF111111));
      c.drawRRect(
        plate,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white,
      );
      _fitText(c, text, Offset(cx, -47), 13, 78, Colors.white);
      _paintIcon(c, _cabIcons[id]!, Rect.fromCenter(center: Offset(cx, -15), width: 34, height: 30));
      _fitText(c, text, Offset(cx, 11), 14, 90, Colors.white, shadow: true);
    }
    c.restore();
  }

  // ------------------------------------------------------ boxes / racks

  /// Oblique cuboid centred at local (x, y, z) world units from [a].
  void _box(
    Canvas c,
    Offset a,
    double k, {
    double x = 0,
    double y = 0,
    double z = 0,
    required double sx,
    required double sy,
    required double sz,
    required Color color,
    Color? topColor,
  }) {
    final sk = (a.dx - 500) / 1400;
    Offset p(double px, double py, double pz) => a + Offset((px + pz * sk) * k, (-py + pz * _e) * k);
    final x0 = x - sx / 2, x1 = x + sx / 2, y0 = y - sy / 2, y1 = y + sy / 2, z0 = z - sz / 2, z1 = z + sz / 2;
    Path poly(List<Offset> pts) => Path()..addPolygon(pts, true);
    final side = sk >= 0
        ? poly([p(x0, y1, z0), p(x0, y1, z1), p(x0, y0, z1), p(x0, y0, z0)])
        : poly([p(x1, y1, z0), p(x1, y1, z1), p(x1, y0, z1), p(x1, y0, z0)]);
    c.drawPath(side, Paint()..color = labShade(color, -0.3));
    final frontRect = Rect.fromPoints(p(x0, y1, z1), p(x1, y0, z1));
    c.drawRect(
      frontRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(color, 0.05), labShade(color, -0.15)],
        ).createShader(frontRect),
    );
    c.drawPath(poly([p(x0, y1, z0), p(x1, y1, z0), p(x1, y1, z1), p(x0, y1, z1)]), Paint()..color = topColor ?? labShade(color, 0.2));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = labShade(color, -0.5).withValues(alpha: 0.6);
    c.drawRect(frontRect, edge);
  }

  void _post(Canvas c, Offset a, double k, double x, double z, double y0, double y1) {
    final sk = (a.dx - 500) / 1400;
    final cx = a.dx + (x + z * sk) * k;
    final rect = Rect.fromLTRB(cx - 0.2 * k, a.dy + (-y1 + z * _e) * k, cx + 0.2 * k, a.dy + (-y0 + z * _e) * k);
    labCylinder(c, rect, _cRackWood, tilt: _e, drawTop: false);
  }

  /// Wooden test-tube rack (HTML `createRack`).
  void _rack(Canvas c, String id, Offset a) {
    const k = 12.4;
    labGroundShadow(c, a + const Offset(0, 6), 8.6 * k, 2.6 * k * _e, opacity: 0.35);
    for (final x in [-3.5, 3.5]) {
      _post(c, a, k, x, -1.5, 0.5, 3.25);
    }
    _box(c, a, k, y: 0.25, sx: 8, sy: 0.5, sz: 4, color: _cRackWood);
    final inside = scene.objs.values.where((o) => o.container == id).toList();
    for (final o in inside) {
      _object(c, o);
    }
    _box(c, a, k, y: 3.5, sx: 8, sy: 0.5, sz: 4, color: _cRackWood);
    final holeY = a.dy - 3.75 * k;
    for (final hx in [-2.5, 0.0, 2.5]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(a.dx + hx * k, holeY), width: 1.9 * k, height: 1.9 * k * _e),
        Paint()..color = labShade(_cRackWood, -0.55),
      );
    }
    // Tubes stand in the holes: redraw the part above the top board.
    if (inside.isNotEmpty) {
      c.save();
      c.clipRect(Rect.fromLTRB(a.dx - 200, a.dy - 400, a.dx + 200, holeY));
      for (final o in inside) {
        _object(c, o);
      }
      c.restore();
    }
    for (final x in [-3.5, 3.5]) {
      _post(c, a, k, x, 1.5, 0.5, 3.25);
    }
  }

  // ------------------------------------------------------ tile / strips

  void _tile(Canvas c) {
    final a = scene.tileCenter, k = scene.tileK, s = scene.tileSize;
    labGroundShadow(c, a + Offset(0, s / 2 * k * _e), s * k * 1.05, 10, opacity: 0.35);
    _box(c, a, k, y: 0.2, sx: s, sy: 0.4, sz: s, color: const Color(0xFFCBD5E1), topColor: Colors.white);
    final top = a + Offset(0, -0.4 * k);
    final rx = 0.293 * s * k;
    labDashedPath(
      c,
      Path()..addOval(Rect.fromCenter(center: top, width: rx * 2, height: rx * 2 * _e)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF94A3B8),
      dash: 7,
      gap: 6,
    );
    c.drawOval(
      Rect.fromCenter(center: top, width: 0.08 * s * k, height: 0.08 * s * k * _e),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    c.save();
    c.translate(top.dx, top.dy + 0.2 * s * k * _e);
    c.scale(1, 0.7);
    _fitText(c, tr('drop'), Offset.zero, math.max(13, 0.11 * s * k), s * k * 0.9, const Color(0xFF334155));
    c.restore();
  }

  void _strip(Canvas c, _Strip st) {
    final r = scene.stripRect(st);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(2));
    c.drawRRect(rr.shift(const Offset(1.5, 2)), Paint()..color = Colors.black.withValues(alpha: 0.18));
    c.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(st.baseColor, 0.12), labShade(st.baseColor, -0.08)],
        ).createShader(r),
    );
    if (st.result != null && st.spread > 0) {
      c.save();
      c.clipRRect(rr);
      final reach = r.longestSide * 0.75 * st.spread;
      c.drawOval(
        Rect.fromCenter(center: r.center, width: reach * 2, height: reach * 2),
        Paint()..color = st.result!,
      );
      c.restore();
    }
    if (st.wet) {
      c.drawOval(
        Rect.fromCenter(center: r.center, width: r.width * 0.55, height: r.width * 0.4),
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );
    }
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.25),
    );
  }

  // --------------------------------------------------------- objects

  void _object(Canvas c, _Obj o) {
    if ((o.container == null || o.active) && o.pos.dy >= scene.benchBack - 4) {
      final up = (o.lift - o.restLift).clamp(0.0, 200.0);
      final fade = 1 - up / 260;
      final w = (o.kind == _Kind.dropper || o.kind == _Kind.pestle) ? 3.2 * o.k : o.radius * 2.3 * o.k;
      labGroundShadow(c, o.pos + Offset(o.shake, 2), w * o.scale, w * 0.32 * o.scale, opacity: 0.38 * fade);
    }
    _body(c, o);
    // The pestle sits inside the mortar: clip it to what the rim reveals.
    if (o.kind == _Kind.mortar) {
      final p = scene.objs['pestle'];
      if (p != null && p.container == 'mortar') {
        c.save();
        c.clipPath(Path.combine(PathOperation.difference, Path()..addRect(const Rect.fromLTRB(-3000, -3000, 4000, 4000)), _mortarFront(o)));
        _body(c, p);
        c.restore();
      }
    }
  }

  void _body(Canvas c, _Obj o) {
    c.save();
    final pv = o.pivot * o.k * o.scale;
    c.translate(o.base.dx + pv.dx, o.base.dy + pv.dy);
    c.rotate(o.rot);
    c.translate(-pv.dx, -pv.dy);
    c.scale(o.scale);
    final k = o.k;
    switch (o.kind) {
      case _Kind.beaker:
        _vessel(c, k, r: o.radius, h: o.height, liquid: o.liquid, liquidTop: o.liquidTop * o.level, steam: o.id == 'hotWater' && o.rot == 0);
      case _Kind.litmusBox:
        _litmusBox(c, k, o.body ?? _cLitBlue);
      case _Kind.dropper:
        _dropper(c, k, o.liquid);
      case _Kind.bowl:
        _bowl(c, k);
      case _Kind.mortar:
        _mortar(c, k);
      case _Kind.pestle:
        _pestle(c, k);
      case _Kind.funnel:
        _funnel(c, k);
      case _Kind.tube:
        _tube(c, k, o.liquid);
    }
    c.restore();
  }

  // ------------------------------------------------------ glassware

  Paint _glassFill([double a = 0.13]) => Paint()..color = _cGlass.withValues(alpha: a);
  Paint _glassLine([double a = 0.75, double w = 1.8]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..color = _cGlass.withValues(alpha: a);

  /// Upright cylinder silhouette from y = 0 (base) to y = -[h] (px).
  Path _cylPath(double rad, double h, {double bottom = 0}) => Path()
    ..moveTo(-rad, -h)
    ..lineTo(-rad, -bottom)
    ..arcTo(Rect.fromCenter(center: Offset(0, -bottom), width: rad * 2, height: rad * 2 * _e), math.pi, -math.pi, false)
    ..lineTo(rad, -h)
    ..close();

  void _liquidColumn(Canvas c, double rad, double bottom, double top, Color liquid) {
    if (top - bottom < 0.5) return;
    final body = _cylPath(rad, top, bottom: bottom);
    final rect = Rect.fromLTRB(-rad, -top, rad, -bottom);
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(liquid, -0.25),
          liquid,
          labShade(liquid, 0.15),
          labShade(liquid, -0.3),
        ], stops: const [0, 0.35, 0.6, 1]).createShader(rect),
    );
    final surf = Rect.fromCenter(center: Offset(0, -top), width: rad * 2, height: rad * 2 * _e);
    c.drawOval(surf, Paint()..color = labShade(liquid, 0.22));
    c.drawOval(
      surf,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(liquid, 0.45).withValues(alpha: liquid.a),
    );
  }

  /// Glass beaker (HTML `createBeaker`: open cylinder + liquid cylinder).
  void _vessel(Canvas c, double k, {required double r, required double h, Color? liquid, double liquidTop = 0, bool steam = false}) {
    final rad = r * k, ht = h * k, ey = rad * _e;
    c.drawPath(_cylPath(rad, ht), _glassFill());
    final rim = Rect.fromCenter(center: Offset(0, -ht), width: rad * 2, height: ey * 2);
    c.drawArc(rim, math.pi, math.pi, false, _glassLine(0.45, 1.4));
    if (liquid != null) _liquidColumn(c, rad * 0.91, 0.1 * k, liquidTop * k, liquid);
    // Front glass.
    final line = _glassLine();
    c.drawLine(Offset(-rad, -ht), Offset(-rad, 0), line);
    c.drawLine(Offset(rad, -ht), Offset(rad, 0), line);
    c.drawArc(Rect.fromCenter(center: Offset.zero, width: rad * 2, height: ey * 2), 0, math.pi, false, line);
    c.drawArc(rim, 0, math.pi, false, _glassLine(0.9, 2.2));
    // Pouring lip.
    c.drawPath(
      Path()
        ..moveTo(-rad + 2, -ht - 1)
        ..quadraticBezierTo(-rad - 3, -ht - 2, -rad - 5, -ht - 5),
      _glassLine(0.9, 2.2),
    );
    c.drawLine(
      Offset(-rad * 0.62, -ht + 5),
      Offset(-rad * 0.62, -ey - 2),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.2),
    );
    final grad = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.45);
    for (var i = 1; i <= 3; i++) {
      final y = -ht * i / 4;
      c.drawLine(Offset(rad * 0.45, y), Offset(rad * 0.8, y), grad);
    }
    if (steam) {
      final t = scene.time;
      for (var i = 0; i < 3; i++) {
        final ph = (t * 0.45 + i / 3) % 1.0;
        final x0 = (i - 1) * rad * 0.45;
        final path = Path()..moveTo(x0, -ht - 4);
        for (var s = 1; s <= 10; s++) {
          final f = s / 10;
          path.lineTo(x0 + math.sin(t * 2.2 + i * 2 + f * 5) * 5, -ht - 4 - f * 40 * (0.4 + ph));
        }
        c.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.16 * (1 - ph)),
        );
      }
    }
  }

  /// Litmus paper box (3 x 0.8 x 4, rotated PI/6 like the HTML mesh).
  void _litmusBox(Canvas c, double k, Color color) {
    const yaw = math.pi / 6;
    final cs = math.cos(yaw), sn = math.sin(yaw);
    Offset p(double x, double y, double z) {
      final rx = x * cs + z * sn, rz = -x * sn + z * cs;
      return Offset(rx * k, (-y + rz * _e) * k);
    }

    Path poly(List<Offset> pts) => Path()..addPolygon(pts, true);
    const hx = 1.5, hz = 2.0, hy = 0.8;
    c.drawPath(poly([p(-hx, hy, -hz), p(-hx, hy, hz), p(-hx, 0, hz), p(-hx, 0, -hz)]), Paint()..color = labShade(color, -0.35));
    final front = poly([p(-hx, hy, hz), p(hx, hy, hz), p(hx, 0, hz), p(-hx, 0, hz)]);
    c.drawPath(front, Paint()..color = labShade(color, -0.08));
    // Paper label band on the front face.
    c.drawPath(
      poly([p(-hx * 0.55, hy * 0.75, hz), p(hx * 0.55, hy * 0.75, hz), p(hx * 0.55, hy * 0.3, hz), p(-hx * 0.55, hy * 0.3, hz)]),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    final top = poly([p(-hx, hy, -hz), p(hx, hy, -hz), p(hx, hy, hz), p(-hx, hy, hz)]);
    c.drawPath(top, Paint()..color = labShade(color, 0.18));
    // Stack of paper strips visible on top.
    final strip = Paint()
      ..strokeWidth = 1
      ..color = labShade(color, 0.45);
    for (var i = 1; i < 6; i++) {
      final x = -hx + i * (2 * hx / 6);
      c.drawLine(p(x, hy, -hz * 0.85), p(x, hy, hz * 0.85), strip);
    }
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = labShade(color, -0.55);
    c.drawPath(top, edge);
    c.drawPath(front, edge);
  }

  /// Dropper drawn upright with its tip at the origin.
  void _dropper(Canvas c, double k, Color? liquid) {
    final tube = Path()
      ..moveTo(-0.12 * k, -0.1 * k)
      ..lineTo(-0.34 * k, -5.0 * k)
      ..lineTo(0.34 * k, -5.0 * k)
      ..lineTo(0.12 * k, -0.1 * k)
      ..quadraticBezierTo(0, 0.08 * k, -0.12 * k, -0.1 * k)
      ..close();
    c.drawPath(tube, _glassFill(0.28));
    if (liquid != null) {
      c.drawPath(
        Path()
          ..moveTo(-0.08 * k, -0.15 * k)
          ..lineTo(-0.25 * k, -3.4 * k)
          ..lineTo(0.25 * k, -3.4 * k)
          ..lineTo(0.08 * k, -0.15 * k)
          ..close(),
        Paint()..color = liquid.withValues(alpha: math.max(liquid.a, 0.85)),
      );
    }
    c.drawPath(tube, _glassLine(0.9, 1.4));
    c.drawLine(Offset(-0.15 * k, -4.6 * k), Offset(-0.06 * k, -0.6 * k),
        Paint()..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 1.2);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -3.7 * k), width: 0.95 * k, height: 0.35 * k), Radius.circular(0.1 * k)),
      Paint()..color = const Color(0xFF374151),
    );
    final bulb = Rect.fromCenter(center: Offset(0, -5.1 * k), width: 2.0 * k, height: 3.0 * k);
    c.drawOval(
      bulb,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 0.9,
          colors: [Color(0xFF4B5563), _cBulb, Color(0xFF030712)],
          stops: [0, 0.55, 1],
        ).createShader(bulb),
    );
  }

  void _petal(Canvas c, Offset at, double size, double angle, Color color) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    final r = Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.55);
    c.drawOval(
      r,
      Paint()
        ..shader = LinearGradient(colors: [labShade(color, 0.18), color, labShade(color, -0.3)]).createShader(r),
    );
    c.restore();
  }

  /// Glass bowl of rose petals (open cone 2.5 -> 1.5, height 2).
  void _bowl(Canvas c, double k) {
    final top = 2.0 * k, rt = 2.5 * k, rb = 1.5 * k;
    final body = Path()
      ..moveTo(-rt, -top)
      ..lineTo(-rb, 0)
      ..arcTo(Rect.fromCenter(center: Offset.zero, width: rb * 2, height: rb * 2 * _e), math.pi, -math.pi, false)
      ..lineTo(rt, -top)
      ..close();
    c.drawPath(body, _glassFill(0.16));
    final rim = Rect.fromCenter(center: Offset(0, -top), width: rt * 2, height: rt * 2 * _e);
    c.drawArc(rim, math.pi, math.pi, false, _glassLine(0.45, 1.4));
    if (scene.bowlHasPetals) {
      for (final p in scene.bowlPetals) {
        _petal(c, Offset(p.x * k, (-p.y + p.z * _e) * k), p.size * k, p.angle, _cPetal);
      }
    }
    c.drawPath(body, _glassLine(0.8, 1.6));
    c.drawArc(rim, 0, math.pi, false, _glassLine(0.95, 2.2));
  }

  // ---------------------------------------------- mortar and pestle

  Path _mortarBody(double k) {
    final rt = 2.8 * k, rb = 2.0 * k, h = 3.5 * k;
    return Path()
      ..moveTo(-rt, -h)
      ..lineTo(-rb, 0)
      ..arcTo(Rect.fromCenter(center: Offset.zero, width: rb * 2, height: rb * 2 * _e), math.pi, -math.pi, false)
      ..lineTo(rt, -h)
      ..arcTo(Rect.fromCenter(center: Offset(0, -h), width: rt * 2, height: rt * 2 * _e), 0, math.pi, false)
      ..close();
  }

  Rect _mortarOpening(double k) =>
      Rect.fromCenter(center: Offset(0, -3.5 * k), width: 5.0 * k, height: 5.0 * k * _e);

  /// Front shell of the mortar in design coordinates (occludes the pestle).
  Path _mortarFront(_Obj m) {
    final shell = Path.combine(PathOperation.difference, _mortarBody(m.k), Path()..addOval(_mortarOpening(m.k)));
    return shell.shift(m.base);
  }

  /// Green mortar with a yellow band (HTML hollow mortar group).
  void _mortar(Canvas c, double k) {
    final rt = 2.8 * k, h = 3.5 * k;
    final body = _mortarBody(k);
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_cMortar, -0.4),
          labShade(_cMortar, 0.18),
          _cMortar,
          labShade(_cMortar, -0.5),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(Rect.fromLTRB(-rt, -h, rt, 0)),
    );
    final r31 = (2.0 + 0.8 * 3.1 / 3.5) * k;
    final band = Path()
      ..moveTo(rt, -h)
      ..arcTo(Rect.fromCenter(center: Offset(0, -h), width: rt * 2, height: rt * 2 * _e), 0, math.pi, false)
      ..lineTo(-r31, -3.1 * k)
      ..arcTo(Rect.fromCenter(center: Offset(0, -3.1 * k), width: r31 * 2, height: r31 * 2 * _e), math.pi, -math.pi, false)
      ..close();
    c.drawPath(
      band,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_cMortarBand, -0.35),
          labShade(_cMortarBand, 0.2),
          labShade(_cMortarBand, -0.4),
        ]).createShader(Rect.fromLTRB(-rt, -h, rt, -3.1 * k)),
    );
    c.drawOval(Rect.fromCenter(center: Offset(0, -h), width: rt * 2, height: rt * 2 * _e), Paint()..color = labShade(_cMortar, 0.12));
    final open = _mortarOpening(k);
    c.drawOval(
      open,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF022C22), _cMortarIn],
        ).createShader(open),
    );
    c.save();
    c.clipPath(Path()..addOval(open));
    if (scene.mortarLiquid != null && scene.mortarLevel > 0) {
      final lv = scene.mortarLevel.clamp(0.0, 1.0);
      final cy = -(2.0 + 1.3 * lv) * k;
      final w = open.width * (0.86 + 0.14 * lv);
      final surf = Rect.fromCenter(center: Offset(0, cy), width: w, height: w * _e * 1.4);
      c.drawOval(surf, Paint()..color = scene.mortarLiquid!);
      c.drawOval(
        Rect.fromCenter(center: Offset(-w * 0.15, cy - w * _e * 0.35), width: w * 0.35, height: w * 0.08),
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    }
    if (scene.pulp) {
      final pulpRect = Rect.fromCenter(center: Offset(0, -2.75 * k), width: 4.0 * k, height: 2.0 * k);
      c.drawOval(pulpRect, Paint()..color = const Color(0xFF831843));
      final rng = math.Random(7);
      for (var i = 0; i < 22; i++) {
        final a = rng.nextDouble() * math.pi * 2, d = rng.nextDouble();
        c.drawCircle(
          pulpRect.center + Offset(math.cos(a) * d * pulpRect.width * 0.42, math.sin(a) * d * pulpRect.height * 0.42),
          (0.12 + rng.nextDouble() * 0.16) * k,
          Paint()..color = (i.isEven ? _cPetalCrushed : const Color(0xFFBE185D)).withValues(alpha: 0.85),
        );
      }
    }
    if (scene.mortarHasPetals) {
      final f = 1 - math.pow(0.7, scene.crush).toDouble();
      final col = Color.lerp(_cPetal, _cPetalCrushed, f)!;
      final sz = math.pow(0.9, scene.crush).toDouble();
      for (final p in scene.mortarPetals) {
        _petal(c, Offset(p.x * k, (-(2.65 + p.y * 0.45) + p.z * _e) * k), p.size * k * sz, p.angle, col);
      }
    }
    c.restore();
    c.drawOval(
      open,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    c.drawArc(
      Rect.fromCenter(center: Offset(0, -h), width: rt * 2, height: rt * 2 * _e),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  /// Wooden pestle with a stone head (origin = head centre).
  void _pestle(Canvas c, double k) {
    final handle = Path()
      ..moveTo(-0.6 * k, 0)
      ..lineTo(-0.3 * k, -4.0 * k)
      ..arcToPoint(Offset(0.3 * k, -4.0 * k), radius: Radius.circular(0.3 * k))
      ..lineTo(0.6 * k, 0)
      ..close();
    c.drawPath(
      handle,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_cWood, -0.35),
          labShade(_cWood, 0.25),
          _cWood,
          labShade(_cWood, -0.45),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(Rect.fromLTRB(-0.6 * k, -4 * k, 0.6 * k, 0)),
    );
    labSphere(c, Offset.zero, 1.0 * k, _cStone, highlight: 0.4, shade: 0.6);
    final rng = math.Random(3);
    for (var i = 0; i < 9; i++) {
      final a = rng.nextDouble() * math.pi * 2, d = rng.nextDouble() * 0.75 * k;
      c.drawCircle(Offset(math.cos(a) * d, math.sin(a) * d), 0.06 * k, Paint()..color = Colors.white.withValues(alpha: 0.12));
    }
  }

  /// Glass filter funnel (origin = stem tip).
  void _funnel(Canvas c, double k) {
    final rt = 2.5 * k, top = 5.0 * k, neck = 2.0 * k;
    final stem = Path()
      ..moveTo(-0.3 * k, -neck)
      ..lineTo(-0.3 * k, -0.15 * k)
      ..lineTo(0.3 * k, 0.1 * k)
      ..lineTo(0.3 * k, -neck)
      ..close();
    c.drawPath(stem, _glassFill(0.25));
    final topRim = Rect.fromCenter(center: Offset(0, -top), width: rt * 2, height: rt * 2 * _e);
    final cone = Path()
      ..moveTo(-0.3 * k, -neck)
      ..lineTo(-rt, -top)
      ..arcTo(topRim, math.pi, -math.pi, false)
      ..lineTo(0.3 * k, -neck)
      ..close();
    c.drawPath(cone, _glassFill(0.16));
    c.drawArc(topRim, math.pi, math.pi, false, _glassLine(0.45, 1.4));
    // Filter paper liner.
    c.drawPath(
      Path()
        ..moveTo(-0.15 * k, -neck - 0.5 * k)
        ..lineTo(-rt * 0.9, -top + 0.05 * k)
        ..lineTo(rt * 0.9, -top + 0.05 * k)
        ..lineTo(0.15 * k, -neck - 0.5 * k)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    if (scene.funnelWet > 0) {
      final lvl = neck + 0.4 * k + 1.6 * k * scene.funnelWet;
      final wr = 0.3 * k + (rt - 0.3 * k) * ((lvl - neck) / (top - neck));
      c.drawPath(
        Path()
          ..moveTo(-0.25 * k, -neck)
          ..lineTo(-wr * 0.9, -lvl)
          ..lineTo(wr * 0.9, -lvl)
          ..lineTo(0.25 * k, -neck)
          ..close(),
        Paint()..color = _cRose,
      );
      c.drawOval(Rect.fromCenter(center: Offset(0, -lvl), width: wr * 1.8, height: wr * 1.8 * _e), Paint()..color = labShade(_cRose, 0.2));
      c.drawRect(Rect.fromLTRB(-0.18 * k, -neck, 0.18 * k, 0), Paint()..color = _cRose);
    }
    c.drawPath(cone, _glassLine(0.85, 1.6));
    c.drawPath(stem, _glassLine(0.85, 1.4));
    c.drawArc(topRim, 0, math.pi, false, _glassLine(0.95, 2.2));
  }

  /// Test tube with a round bottom (origin = bottom of the tube).
  void _tube(Canvas c, double k, Color? liquid) {
    final r = 0.8 * k, h = 6.8 * k;
    final body = Path()
      ..moveTo(-r, -h)
      ..lineTo(-r, -r)
      ..arcTo(Rect.fromCircle(center: Offset(0, -r), radius: r), math.pi, -math.pi, false)
      ..lineTo(r, -h)
      ..close();
    c.drawPath(body, _glassFill(0.14));
    final rim = Rect.fromCenter(center: Offset(0, -h), width: r * 2, height: r * 2 * _e);
    c.drawArc(rim, math.pi, math.pi, false, _glassLine(0.45, 1.2));
    if (liquid != null) {
      final lt = 4.2 * k;
      final rect = Rect.fromLTRB(-r, -lt, r, 0);
      c.save();
      c.clipPath(body);
      c.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(colors: [
            labShade(liquid, -0.25),
            liquid,
            labShade(liquid, 0.15),
            labShade(liquid, -0.3),
          ], stops: const [0, 0.35, 0.6, 1]).createShader(rect),
      );
      c.restore();
      c.drawOval(Rect.fromCenter(center: Offset(0, -lt), width: r * 1.84, height: r * 1.84 * _e), Paint()..color = labShade(liquid, 0.25));
    }
    c.drawPath(body, _glassLine(0.8, 1.5));
    c.drawOval(rim, _glassLine(0.95, 2.2));
    c.drawLine(Offset(-r * 0.5, -h + 4), Offset(-r * 0.5, -r - 2),
        Paint()..color = Colors.white.withValues(alpha: 0.25)..strokeWidth = 2..strokeCap = StrokeCap.round);
  }

  // ------------------------------------------------- effects / labels

  void _effects(Canvas c) {
    final f = scene.flow;
    if (f != null && f.alpha > 0) {
      final src = scene.objs[f.fromId];
      if (src != null) {
        final from = src.lip, to = f.to;
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(from.dx + (to.dx - from.dx) * 0.6, from.dy, to.dx, from.dy + (to.dy - from.dy) * 0.3, to.dx, to.dy);
        c.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..color = f.color.withValues(alpha: math.max(f.color.a, 0.75) * f.alpha),
        );
        labDashedPath(
          c,
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.45 * f.alpha),
          dash: 6,
          gap: 10,
          phase: -scene.time * 90,
        );
        for (var i = 0; i < 2; i++) {
          final ph = (scene.time * 1.6 + i * 0.5) % 1.0;
          c.drawOval(
            Rect.fromCenter(center: to, width: 8 + 22 * ph, height: (8 + 22 * ph) * _e),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = Colors.white.withValues(alpha: 0.5 * (1 - ph) * f.alpha),
          );
        }
      }
      // Extract dripping through the funnel into the beaker.
      if (f.fromId == 'mortar') {
        final fn = scene.objs['funnel'], ib = scene.objs['indicatorBeaker'];
        if (fn != null && ib != null) {
          final surf = ib.base + Offset(0, -ib.liquidTop * ib.level * ib.k);
          c.drawLine(
            fn.base,
            Offset(fn.base.dx, math.max(surf.dy, fn.base.dy)),
            Paint()
              ..strokeWidth = 2.4
              ..strokeCap = StrokeCap.round
              ..color = _cRose.withValues(alpha: 0.9 * f.alpha),
          );
        }
      }
    }
    final d = scene.drop;
    if (d != null) {
      labSphere(c, d.pos, 4.8, d.color.withValues(alpha: 1), highlight: 0.6);
    }
  }

  void _hover(Canvas c) {
    final id = scene.hoverZone;
    if (id == null) return;
    final r = scene.zones()[id];
    if (r == null) return;
    final rr = RRect.fromRectAndRadius(r.inflate(5), const Radius.circular(10));
    c.drawRRect(rr, Paint()..color = _Colors.zslYellow.withValues(alpha: 0.10));
    labDashedPath(
      c,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.zslYellow,
      dash: 9,
      gap: 6,
      phase: scene.time * 30,
    );
  }

  void _labels(Canvas c) {
    if (scene.scenario == 1) {
      scene.racks.forEach((id, a) => _outlined(c, tr(_zoneKeys[id]!), Offset(a.dx, 96), color: _cLabelYellow, size: 19));
    }
    for (final o in scene.objs.values) {
      final key = o.labelKey;
      if (key == null) continue;
      var text = tr(key);
      var col = o.labelColor;
      var size = 17.0;
      if (o.id == 'indicatorBeaker' && scene.indIsIndicator) {
        text = tr('roseI');
        col = _cLabelYellow;
        size = 19;
      } else if (o.kind == _Kind.tube) {
        text = '${tr('tube')} ${o.id.substring(4)}';
      }
      final cab = o.container == null ? null : scene.cabinets[o.container];
      final Offset at;
      if (cab != null && !o.active) {
        at = Offset(cab.dx, cab.dy + 12 + _Scene.cabinetSize.height / 2 + 16);
      } else {
        final b = o.bounds;
        at = Offset(b.center.dx, b.top - 13);
      }
      _outlined(c, text, at, color: col, size: size);
    }
  }

  /// HTML `createTextSprite`: bold text with a dark outline.
  void _outlined(Canvas c, String text, Offset center, {Color color = Colors.white, double size = 17}) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      fontFamily: LabFont.active.family,
      fontFamilyFallback: LabFont.active.fallback,
      height: 1.15,
    );
    final stroke = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFF0F172A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final fill = TextPainter(
      text: TextSpan(text: text, style: style.copyWith(color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final o = center - Offset(fill.width / 2, fill.height / 2);
    stroke.paint(c, o);
    fill.paint(c, o);
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) =>
      old.lang != lang || old.showLabels != showLabels || old.scene != scene;
}

/// Text centred on [center], scaled down to fit [maxW].
void _fitText(Canvas c, String text, Offset center, double size, double maxW, Color color, {bool shadow = false}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
        height: 1.1,
        shadows: shadow ? const [Shadow(color: Colors.black, blurRadius: 3)] : null,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final s = tp.width > maxW ? maxW / tp.width : 1.0;
  c.save();
  c.translate(center.dx, center.dy);
  c.scale(s);
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  c.restore();
}

/// Lemon / soap / tap pictograms (the HTML cabinet emoji 🍋 🧼 🚰).
void _paintIcon(Canvas c, _Icon icon, Rect r) {
  final cx = r.center.dx, cy = r.center.dy, w = r.width, h = r.height;
  switch (icon) {
    case _Icon.lemon:
      final hw = w * 0.42, hh = h * 0.34;
      final body = Path()
        ..moveTo(cx - hw * 1.08, cy + hh * 0.1)
        ..cubicTo(cx - hw * 0.8, cy - hh * 1.3, cx + hw * 0.8, cy - hh * 1.3, cx + hw * 1.08, cy + hh * 0.1)
        ..cubicTo(cx + hw * 0.8, cy + hh * 1.45, cx - hw * 0.8, cy + hh * 1.45, cx - hw * 1.08, cy + hh * 0.1)
        ..close();
      c.drawPath(
        body,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.45),
            colors: [Color(0xFFFEF08A), Color(0xFFFACC15), Color(0xFFCA8A04)],
            stops: [0, 0.55, 1],
          ).createShader(r),
      );
      c.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..color = const Color(0xFFA16207),
      );
      c.save();
      c.translate(cx + hw * 0.25, cy - hh * 1.0);
      c.rotate(-0.55);
      final leaf = Rect.fromCenter(center: Offset(w * 0.12, 0), width: w * 0.3, height: h * 0.16);
      c.drawOval(leaf, Paint()..color = const Color(0xFF16A34A));
      c.drawLine(leaf.centerLeft, leaf.centerRight, Paint()..color = const Color(0xFF14532D)..strokeWidth = w * 0.02);
      c.restore();
      c.drawArc(
        Rect.fromCenter(center: Offset(cx - hw * 0.2, cy - hh * 0.1), width: hw * 1.1, height: hh * 1.2),
        3.6,
        0.9,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.6),
      );
    case _Icon.soap:
      final bar = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + h * 0.18), width: w * 0.8, height: h * 0.44),
        Radius.circular(w * 0.12),
      );
      c.drawRRect(
        bar,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBCFE8), Color(0xFFEC4899)],
          ).createShader(bar.outerRect),
      );
      c.drawRRect(
        bar,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..color = const Color(0xFFBE185D),
      );
      for (final b in [
        (Offset(cx - w * 0.2, cy - h * 0.18), w * 0.1),
        (Offset(cx + w * 0.08, cy - h * 0.32), w * 0.14),
        (Offset(cx + w * 0.32, cy - h * 0.12), w * 0.08),
      ]) {
        c.drawCircle(b.$1, b.$2, Paint()..color = Colors.white.withValues(alpha: 0.18));
        c.drawCircle(
          b.$1,
          b.$2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.035
            ..color = Colors.white.withValues(alpha: 0.9),
        );
        c.drawCircle(b.$1 + Offset(-b.$2 * 0.35, -b.$2 * 0.35), b.$2 * 0.22, Paint()..color = Colors.white);
      }
    case _Icon.tap:
      final metal = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE2E8F0), Color(0xFF64748B)],
        ).createShader(r);
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(r.left + w * 0.05, cy - h * 0.2, r.left + w * 0.2, cy + h * 0.1), Radius.circular(w * 0.03)),
        metal,
      );
      c.drawPath(
        Path()
          ..moveTo(r.left + w * 0.18, cy - h * 0.05)
          ..lineTo(cx + w * 0.12, cy - h * 0.05)
          ..quadraticBezierTo(cx + w * 0.3, cy - h * 0.05, cx + w * 0.3, cy + h * 0.14),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.16
          ..strokeCap = StrokeCap.butt
          ..shader = metal.shader,
      );
      c.drawRect(Rect.fromLTRB(cx - w * 0.06, cy - h * 0.3, cx + w * 0.02, cy - h * 0.12), metal);
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.02, cy - h * 0.33), width: w * 0.32, height: h * 0.08), Radius.circular(h * 0.04)),
        Paint()..color = const Color(0xFFEF4444),
      );
      final dc = Offset(cx + w * 0.3, cy + h * 0.36);
      c.drawPath(
        Path()
          ..moveTo(dc.dx, dc.dy - h * 0.16)
          ..quadraticBezierTo(dc.dx + w * 0.1, dc.dy, dc.dx, dc.dy + h * 0.06)
          ..quadraticBezierTo(dc.dx - w * 0.1, dc.dy, dc.dx, dc.dy - h * 0.16)
          ..close(),
        Paint()..color = const Color(0xFF38BDF8),
      );
  }
}

/// Pictogram widget painter for the summary screen.
class _IconPainter extends CustomPainter {
  const _IconPainter(this.icon);
  final _Icon icon;

  @override
  void paint(Canvas canvas, Size size) => _paintIcon(canvas, icon, Offset.zero & size);

  @override
  bool shouldRepaint(covariant _IconPainter old) => old.icon != icon;
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
