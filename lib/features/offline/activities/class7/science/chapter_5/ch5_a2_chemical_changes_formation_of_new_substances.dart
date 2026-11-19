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

/// Class 7 Science • Chapter 5 • Activity 2
/// Chemical Changes: Formation of New Substances.
///
/// Native Flutter port of
/// `Cl7S-Ch5-A2-Chemical_Changes__Formation_of_New_Substances.html`.
///
/// Scenario 1 (Exhaled Air Test): drag a straw into beaker A (tap water),
/// BLOW AIR (bubbles, no change = physical change), drag the second straw
/// into beaker B (lime water), BLOW AIR (it turns milky = chemical change),
/// then a comparison summary with the calcium carbonate magnifier.
///
/// Scenario 2 (Vinegar & Baking Soda): drag the spoon of baking soda into
/// test tube 1 (fizzing), CONNECT TUBE (click the delivery tube or the
/// button), gas bubbles travel into the lime water which turns milky, and a
/// side-by-side comparison with the scenario 1 beaker.
class Ch5A2ChemicalChangesFormationOfNewSubstancesPage extends StatefulWidget {
  const Ch5A2ChemicalChangesFormationOfNewSubstancesPage({super.key});

  @override
  State<Ch5A2ChemicalChangesFormationOfNewSubstancesPage> createState() =>
      _Ch5A2ChemicalChangesFormationOfNewSubstancesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, pickup 2356, bubble 732, magic 871.
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
  pickup('pickup.mp3'),
  bubble('bubble.mp3'),
  magic('magic.mp3');

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

/// Pan recognizer that only joins the gesture arena for touches that start
/// on a draggable object (empty-canvas drags still pan the zoomed canvas),
/// with a small slop so short drags register.
class _ObjectDragRecognizer extends PanGestureRecognizer {
  _ObjectDragRecognizer({required this.accept});

  bool Function(Offset local) accept;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && accept(event.localPosition);
}

double _distToSeg(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-6) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

class _Ch5A2ChemicalChangesFormationOfNewSubstancesPageState
    extends State<Ch5A2ChemicalChangesFormationOfNewSubstancesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  double _lastBubbleSound = -1;

  /// HTML `state.step` (0-based).
  int _step = 0;

  /// BLOW AIR button visible for beaker A (1) or beaker B (2); 0 = hidden.
  int _blowPhase = 0;

  /// CONNECT TUBE button visible.
  bool _connectVisible = false;

  /// A straw is snapping into place (its step change is pending).
  bool _snapPending = false;
  bool _connected = false;

  // Drag state (HTML `state.isDragging` / `draggedObject` / dragPlane).
  Object? _dragObj;
  double _dragPlaneY = 0;
  double _grabDx = 0, _grabDz = 0;

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

    _buildScenario(animateCamera: false);
    _ticker = createTicker(_onTick)..start();
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

  /// HTML `animate()`: TWEEN.update + Animators + render.
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _scene.time).clamp(0.0, 0.1);
    _scene.time = now;
    _scene.tickAnims();
    final pops = _scene.tickParticles(dt);
    if (pops > 0 && now - _lastBubbleSound > 0.3) {
      _lastBubbleSound = now;
      _Audio.play(_Sound.bubble, volume: 0.3);
    }
    _frame.value = now;
  }

  // ------------------------------------------------------------ tweens

  void _tweenV3(_V3 Function() get, void Function(_V3) set, _V3 to, double ms,
      {Curve curve = Curves.linear, double delayMs = 0, VoidCallback? done, Object? tag}) {
    _scene.animate(ms, () {
      final from = get();
      return (t) => set(_V3.lerp(from, to, t));
    }, curve: curve, delayMs: delayMs, done: done, tag: tag);
  }

  void _tweenD(double Function() get, void Function(double) set, double to, double ms,
      {Curve curve = Curves.linear, double delayMs = 0, VoidCallback? done, Object? tag}) {
    _scene.animate(ms, () {
      final from = get();
      return (t) => set(from + (to - from) * t);
    }, curve: curve, delayMs: delayMs, done: done, tag: tag);
  }

  /// Liquid colour / opacity / emissive tween (HTML `mat.color`, `mat.opacity`,
  /// `mat.emissive`).
  void _tweenLiquid(_Vessel v, Color to, double ms, {double? opacity, double? milk, VoidCallback? done}) {
    _scene.animate(ms, () {
      final c0 = v.liquid, o0 = v.opacity, m0 = v.milk;
      return (t) {
        v.liquid = Color.lerp(c0, to, t)!;
        if (opacity != null) v.opacity = o0 + (opacity - o0) * t;
        if (milk != null) v.milk = m0 + (milk - m0) * t;
      };
    }, done: done);
  }

  /// Camera position (Cubic.Out) and target (linear) tweens, 1000 ms.
  void _camTo(_V3 eye, _V3 target) {
    _scene.cancel(#cam);
    final cam = _scene.cam;
    _tweenV3(() => cam.eye, (v) => cam.eye = v, eye, 1000, curve: Curves.easeOutCubic, tag: #cam);
    _tweenV3(() => cam.target, (v) => cam.target = v, target, 1000, tag: #cam);
  }

  /// HTML `resetCamera()`.
  void _resetCamera() =>
      _scenario == 0 ? _camTo(_s1Eye, _s1Target) : _camTo(_s2Eye, _s2Target);

  void _feedback(bool ok, String key) => _lab.showToast(_t(key), isError: !ok);

  // ------------------------------------------------------------- scenes

  /// HTML `loadScenario()` + `clearScene()`.
  void _buildScenario({bool animateCamera = true}) {
    _lab.cancelPending();
    _scene.clear();
    _step = 0;
    _blowPhase = 0;
    _connectVisible = false;
    _snapPending = false;
    _connected = false;
    _dragObj = null;
    if (_scenario == 0) {
      _scene.beakerA = _Vessel.beaker(const _V3(-3.5, 0, 0), const Color(0xFF3B82F6), 0.4);
      _scene.beakerB = _Vessel.beaker(const _V3(3.5, 0, 0), Colors.white, 0.15);
      _scene.straws
        ..add(_Straw(const _V3(-5.5, 3.5, 2), const Color(0xFF4F46E5)))
        ..add(_Straw(const _V3(5.5, 3.5, 2), const Color(0xFFEAB308)));
      _scene.annotate(_AnnKind.tapWater, const _V3(-3.5, -0.5, 0));
      _scene.annotate(_AnnKind.limeWater, const _V3(3.5, -0.5, 0));
    } else {
      _scene.hasRack = true;
      _scene.tubeA = _Vessel.tube(const _V3(-1.5, 1.8, 0), const Color(0xFF3B82F6), 0.4);
      _scene.tubeB = _Vessel.tube(const _V3(1.5, 1.8, 0), Colors.white, 0.15);
      _scene.spoon = _Spoon(const _V3(5.5, 1.8, 1.5));
      _scene.annotate(_AnnKind.tube1, const _V3(-1.5, -0.8, 0));
      _scene.annotate(_AnnKind.tube2, const _V3(1.5, -0.8, 0));
      _scene.annotate(_AnnKind.soda, const _V3(5.5, 0.75, 2.4)); // HTML (5.5, 1.7, 1.5) hid the spoon
    }
    if (animateCamera) {
      _resetCamera();
    } else {
      _scene.cam
        ..eye = _scenario == 0 ? _s1Eye : _s2Eye
        ..target = _scenario == 0 ? _s1Target : _s2Target;
    }
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _buildScenario(animateCamera: false);
    });
  }

  // --------------------------------------------------------- drag & drop

  _V3 _posOf(Object o) => o is _Straw ? o.pos : (o as _Spoon).pos;

  void _setPos(Object o, _V3 v) {
    if (o is _Straw) {
      o.pos = v;
    } else if (o is _Spoon) {
      o.pos = v;
    }
  }

  /// Raycast stand-in: the draggable straw / spoon under [p] (design px).
  Object? _hitDraggable(Offset p) {
    if (!_lab.isLabActive) return null;
    final cam = _scene.cam..prepare();
    var best = double.infinity;
    Object? hit;
    for (final s in _scene.straws) {
      if (!s.draggable) continue;
      final d = _distToSeg(p, cam.pt(s.bottom), cam.pt(s.top));
      if (d < math.max(18.0, 0.1 * cam.k(s.pos) + 14) && d < best) {
        best = d;
        hit = s;
      }
    }
    final sp = _scene.spoon;
    if (sp != null && sp.draggable) {
      final k = cam.k(sp.pos);
      final d = math.min(
        _distToSeg(p, cam.pt(sp.pos), cam.pt(sp.handleEnd)),
        (p - cam.pt(sp.pos)).distance - 0.45 * k,
      );
      if (d < 20 && d < best) hit = sp;
    }
    return hit;
  }

  bool _hitTube(_DeliveryTube d, Offset p) {
    final cam = _scene.cam..prepare();
    var prev = cam.pt(d.point(0));
    for (var i = 1; i <= 30; i++) {
      final o = cam.pt(d.point(i / 30));
      if (_distToSeg(p, prev, o) < 22) return true;
      prev = o;
    }
    return (p - cam.pt(d.start + d.offset + const _V3(0, 0.25, 0))).distance < 30;
  }

  void _onDragStart(DragStartDetails d) {
    final obj = _hitDraggable(d.localPosition);
    if (obj == null) return;
    final pos = _posOf(obj);
    final hit = _scene.cam.onPlaneY(d.localPosition, pos.y);
    if (hit == null) return;
    _scene.cancel(obj);
    _dragObj = obj;
    _dragPlaneY = pos.y;
    _grabDx = pos.x - hit.x;
    _grabDz = pos.z - hit.z;
    _scene.dragged = obj;
    _Audio.play(_Sound.pickup);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final obj = _dragObj;
    if (obj == null) return;
    _scene.cam.prepare();
    final hit = _scene.cam.onPlaneY(d.localPosition, _dragPlaneY);
    if (hit == null) return;
    _setPos(obj, _V3((hit.x + _grabDx).clamp(-11.0, 11.0), _dragPlaneY, (hit.z + _grabDz).clamp(-9.0, 9.0)));
  }

  void _onDragEnd() {
    final obj = _dragObj;
    if (obj == null) return;
    _dragObj = null;
    _scene.dragged = null;
    _evaluateDrop(obj);
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final p = d.localPosition;
    final tube = _scene.dTube;
    if (_scenario == 1 && tube != null && tube.clickable && _hitTube(tube, p)) {
      _connectTube();
      return;
    }
    // A click on a straw / the spoon is a zero-length drag in the HTML.
    final obj = _hitDraggable(p);
    if (obj != null) _evaluateDrop(obj);
  }

  /// HTML `evaluateDrop(obj)`.
  void _evaluateDrop(Object obj) {
    var snapped = false;
    if (_scenario == 0 && obj is _Straw) {
      final target = _step == 0 ? _scene.beakerA : (_step == 2 ? _scene.beakerB : null);
      if (target != null && !_snapPending && obj.pos.distXZ(target.mouth) < 3.0) {
        snapped = true;
        _snapPending = true;
        obj
          ..draggable = false
          ..placedIn = target;
        _tweenV3(() => obj.pos, (v) => obj.pos = v, target.mouth, 500, curve: Curves.easeOutQuad, tag: obj);
        _tweenD(() => obj.rotZ, (v) => obj.rotZ = v, 0, 500, tag: obj);
        _Audio.play(_Sound.pop);
        _feedback(true, 'fb_straw_correct');
        _lab.after(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _snapPending = false;
            if (_step == 0) {
              _step = 1;
              _blowPhase = 1;
            } else if (_step == 2) {
              _step = 3;
              _blowPhase = 2;
            }
          });
        });
      }
    }
    if (_scenario == 1 && _step == 0 && obj is _Spoon) {
      final tube = _scene.tubeA!;
      if (obj.pos.distXZ(tube.mouth) < 4.0) {
        snapped = true;
        obj.draggable = false;
        _feedback(true, 'fb_ingredients_added');
        _pourSpoon(obj, tube);
      }
    }
    if (!snapped) {
      final start = obj is _Straw ? obj.start : (obj as _Spoon).start;
      _tweenV3(() => _posOf(obj), (v) => _setPos(obj, v), start, 500, curve: Curves.bounceOut, tag: obj);
      _feedback(false, 'fb_wrong_spot');
    }
    setState(() {});
  }

  // ------------------------------------------------------ scenario 1 flow

  /// HTML `triggerBlowAir(phase)`.
  void _blowAir(int phase) {
    if (phase == 0) return;
    setState(() => _blowPhase = 0);
    _feedback(true, 'fb_blowing_air');
    final b = phase == 1 ? _scene.beakerA! : _scene.beakerB!;
    b.bubbles = _Bubbles(0.5, 2.5, 1.0, _scene.rnd);
    _camTo(_V3(b.pos.x, 2, 8), _V3(b.pos.x, 2, 0));
    _lab.after(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      b.bubbles?.visible = false;
      if (phase == 1) {
        setState(() => _step = 2);
        _feedback(true, 'fb_obs_complete');
        _resetCamera();
      } else {
        _tweenLiquid(b, Colors.white, 2000, opacity: 1, milk: 1, done: () {
          if (!mounted) return;
          setState(() => _step = 4);
          _showStep5Visuals();
        });
      }
    });
  }

  /// HTML `showStep5Visuals()`: beakers slide together, summary labels.
  void _showStep5Visuals() {
    for (final (v, x) in [(_scene.beakerA!, -2.5), (_scene.beakerB!, 2.5)]) {
      _tweenV3(() => v.pos, (p) {
        v.pos = p;
        for (final s in _scene.straws) {
          if (s.placedIn == v) s.pos = _V3(p.x, s.pos.y, p.z);
        }
      }, _V3(x, 0, 0), 1000, curve: Curves.easeOutQuad);
    }
    _camTo(_s1SumEye, _s1SumTarget);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _scene.annotations.clear();
      _scene
        ..annotate(_AnnKind.aClear, const _V3(-2.5, 2.5, 1.6))
        ..annotate(_AnnKind.aDesc, const _V3(-2.5, -1, 0))
        ..annotate(_AnnKind.bMilky, const _V3(2.5, 2.5, 1.6))
        ..annotate(_AnnKind.bDesc, const _V3(2.5, -1, 0))
        ..annotate(_AnnKind.s1Summary, const _V3(0, 5.0, 0))
        ..annotate(_AnnKind.calcium, const _V3(4.7, 1.4, 1)); // HTML (3.5, 1.5, 1) covered the B label
      _Audio.play(_Sound.magic);
      _finishScenario();
    });
  }

  // ------------------------------------------------------ scenario 2 flow

  /// Spoon over test tube 1, tilt to pour, powder in, spoon put away.
  void _pourSpoon(_Spoon s, _Vessel tube) {
    final top = tube.mouth;
    _tweenV3(() => s.pos, (v) => s.pos = v, _V3(top.x + 1.0, top.y + 0.5, top.z), 500,
        curve: Curves.easeOutQuad, tag: s, done: () {
      _tweenD(() => s.rotZ, (v) => s.rotZ = v, math.pi / 2 + math.pi / 4, 500, tag: s, done: () {
        if (!mounted) return;
        s.powder = false;
        for (var i = 0; i < 26; i++) {
          final jitter = _V3((_scene.rnd.nextDouble() - 0.5) * 0.25, 0, (_scene.rnd.nextDouble() - 0.5) * 0.2);
          _scene.grains.add(_Grain(s.pos + jitter, top + jitter * 0.6, i * 0.012));
        }
        _triggerFizzing();
        _tweenV3(() => s.pos, (v) => s.pos = v, const _V3(6.5, 0.5, 3), 1000, delayMs: 500, tag: s);
        _tweenD(() => s.rotZ, (v) => s.rotZ = v, 0, 1000, delayMs: 500, tag: s);
        setState(() => _step = 1);
        _scene.dTube = _DeliveryTube(_scene.tubeA!.mouth, _scene.tubeB!.mouth);
        _lab.after(const Duration(milliseconds: 1500), () {
          if (!mounted || _connected) return;
          setState(() => _connectVisible = true);
        });
      });
    });
  }

  /// HTML `triggerFizzing()`.
  void _triggerFizzing() {
    final a = _scene.tubeA!;
    a.bubbles = _Bubbles(-1.5, 0, 0.3, _scene.rnd);
    _tweenLiquid(a, const Color(0xFFDDDDDD), 1000);
    _Audio.play(_Sound.bubble);
    _camTo(_s2FizzEye, _s2FizzTarget);
  }

  /// HTML `showDeliveryTubeButton()`: lower the tube, gas flows, lime water
  /// turns milky.
  void _connectTube() {
    final d = _scene.dTube;
    if (d == null || _connected) return;
    _connected = true;
    d.clickable = false;
    setState(() {
      _connectVisible = false;
      _step = 2;
    });
    _feedback(true, 'fb_tube_connected');
    _tweenV3(() => d.offset, (v) => d.offset = v, const _V3(0, -0.5, 0), 1000, curve: Curves.easeOutQuad,
        done: () {
      if (!mounted) return;
      _Audio.play(_Sound.pop);
      d.bubblesOn = true;
      final b = _scene.tubeB!;
      b.bubbles = _Bubbles(-1.5, 0, 0.3, _scene.rnd);
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _tweenLiquid(b, Colors.white, 2500, opacity: 1, milk: 1, done: () {
          if (!mounted) return;
          _scene.tubeA?.bubbles?.visible = false;
          b.bubbles?.visible = false;
          d.bubblesOn = false;
          setState(() => _step = 3);
          _showScenario2Conclusion();
        });
      });
    });
  }

  /// HTML `showScenario2Conclusion()`: tube 2 next to the milky beaker of
  /// scenario 1. (The HTML left tube 2 sunk 1 unit into the bench; it is
  /// lifted here so it stands on it, with the delivery tube following.)
  void _showScenario2Conclusion() {
    final b = _scene.tubeB!;
    _tweenV3(() => b.pos, (v) => b.pos = v, const _V3(2.5, 2.75, 4), 1000);
    final d = _scene.dTube;
    if (d != null) _tweenV3(() => d.offset, (v) => d.offset = v, const _V3(1.1, 0.45, 4), 1000);
    _scene.milkyBeaker = _Vessel.beaker(const _V3(-2.5, 0, 4), Colors.white, 1)..milk = 1;
    // The HTML left the tube / baking soda labels floating over the
    // comparison; they fade out here (like scenario 1's summary clears them).
    for (final a in _scene.annotations) {
      a.fadeFrom = _scene.time;
    }
    _camTo(_s2SumEye, _s2SumTarget);
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _scene.annotations.removeWhere((a) => a.fadeFrom != null);
      _scene
        ..annotate(_AnnKind.scen1Beaker, const _V3(-2.5, 2.5, 4))
        ..annotate(_AnnKind.scen2Tube, const _V3(2.5, 2.5, 4))
        ..annotate(_AnnKind.arrow, const _V3(0, 2, 4))
        ..annotate(_AnnKind.s2Summary, const _V3(0, 6, 4));
      _Audio.play(_Sound.magic);
      _finishScenario();
    });
  }

  /// HTML `finishScenario()`: feedback, open the sidebar, then after 4 s the
  /// draggable "Observation & Analysis" popup. Same flow as
  /// `LabController.showScenarioConclusion` (completed tick, Continue /
  /// Restart Lab), but with a rich body: bold terms, real subscripts and the
  /// Ca(OH)₂ equation that the HTML rendered with KaTeX.
  void _finishScenario() {
    _feedback(true, 'fb_scenario_complete');
    _lab.openSidebar();
    final idx = _scenario;
    _lab.completedScenarios.add(idx);
    final allDone = _lab.completedScenarios.length >= 2;
    _lab.after(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      _lab.openSidebar();
      _lab.showPopup(() => LabPopupContent(
            title: _t('popup_obs_title'),
            heading: _t('what_happened'),
            icon: Icons.lightbulb,
            extra: _conclusionBody(idx),
            actions: [
              if (allDone)
                LabAction(
                  label: _lab.t('btn_restart'),
                  icon: Icons.restart_alt,
                  onTap: _lab.requestFullReset,
                )
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
    });
  }

  /// Parses the `<b>`, `<sub>` and `<arrow>` markup of the popup strings.
  List<InlineSpan> _markup(String src, TextStyle base) {
    final size = base.fontSize ?? 14;
    final re = RegExp(r'<b>(.*?)</b>|<sub>(.*?)</sub>|<arrow>');
    final out = <InlineSpan>[];
    var i = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > i) out.add(TextSpan(text: src.substring(i, m.start)));
      if (m.group(1) != null) {
        out.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w800)));
      } else if (m.group(2) != null) {
        out.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Transform.translate(
            offset: Offset(0, size * 0.28),
            child: Text(m.group(2)!, style: base.copyWith(fontSize: size * 0.68)),
          ),
        ));
      } else {
        out.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.2),
            child: Icon(Icons.arrow_right_alt, size: size * 1.5, color: base.color),
          ),
        ));
      }
      i = m.end;
    }
    if (i < src.length) out.add(TextSpan(text: src.substring(i)));
    return out;
  }

  Widget _conclusionBody(int idx) {
    final p = _Theme.of(_lab.isDark);
    return Builder(builder: (context) {
      final s = context.labScale;
      final body = TextStyle(
        color: p.text,
        fontSize: 13 * s * _lab.fontScale.clamp(0.9, 1.4),
        fontWeight: FontWeight.w500,
        height: 1.5,
      );
      final eq = TextStyle(
        color: p.textStrong,
        fontSize: 17 * s,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.4,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(TextSpan(style: body, children: _markup(_t('s${idx + 1}_conclusion'), body))),
          if (idx == 0) ...[
            SizedBox(height: 12 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.5)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(TextSpan(style: eq, children: _markup(_t('equation'), eq))),
              ),
            ),
          ],
        ],
      );
    });
  }

  // ------------------------------------------------------------------ UI

  List<LabAction> _actions() => [
        if (_blowPhase != 0)
          LabAction(
            label: _t('btn_blow'),
            icon: Icons.air,
            color: const Color(0xFF3B82F6),
            foreground: Colors.white,
            highlight: true,
            onTap: () => _blowAir(_blowPhase),
          ),
        if (_connectVisible)
          LabAction(
            label: _t('btn_connect'),
            icon: Icons.cable,
            highlight: true,
            onTap: _connectTube,
          ),
      ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen1_name'), _t('scen2_name')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step + 1,
          actions: _actions(),
          showHud: false,
          onReset: _fullReset,
          overlays: [
            _hud(context, p, s),
            if (_lab.isSidebarOpen && _lab.isLabActive) ..._canvasButtons(context, s),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ObjectDragRecognizer: GestureRecognizerFactoryWithHandlers<_ObjectDragRecognizer>(
                  () => _ObjectDragRecognizer(accept: (o) => _hitDraggable(o) != null),
                  (r) {
                    r
                      ..accept = ((o) => _hitDraggable(o) != null)
                      ..gestureSettings = const DeviceGestureSettings(touchSlop: 6)
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _onDragStart
                      ..onUpdate = _onDragUpdate
                      ..onEnd = ((_) => _onDragEnd())
                      ..onCancel = _onDragEnd;
                  },
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _LabPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#ui-overlay`: the BLOW AIR / CONNECT TUBE buttons floating at the
  /// bottom right of the canvas (the floating mission card shows them while
  /// the sidebar is collapsed).
  List<Widget> _canvasButtons(BuildContext context, double s) {
    final acts = _actions();
    if (acts.isEmpty) return const [];
    final pad = MediaQuery.paddingOf(context);
    return [
      Positioned(
        right: 62 + pad.right,
        bottom: 58 * s + pad.bottom,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final a in acts)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 220 * s),
                child: LabActionButton(action: a, scale: s * 1.05, expand: false),
              ),
          ],
        ),
      ),
    ];
  }

  /// HTML bottom "Current Task" mini HUD (always visible, like the HTML).
  Widget _hud(BuildContext context, LabPalette p, double s) {
    final pad = MediaQuery.paddingOf(context);
    final text = _lab.isLabActive ? _t('s${_scenario + 1}_h$_step') : _t('hud_init');
    return Positioned(
      left: 12,
      right: 60 + pad.right,
      bottom: pad.bottom,
      child: Center(
        child: IgnorePointer(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420 * s),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14 * s)),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14 * s)),
                child: IntrinsicWidth(
                  child: Container(
                    color: (p.isDark ? _Colors.slate800 : Colors.white).withValues(alpha: 0.93),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(height: 3.5 * s, color: _Colors.zslYellow),
                        Padding(
                          padding: EdgeInsets.fromLTRB(18 * s, 5 * s, 18 * s, 7 * s),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _t('current_task').toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: p.text.withValues(alpha: 0.75),
                                  fontSize: 9 * s,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              SizedBox(height: 2 * s),
                              Text(
                                text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.textStrong,
                                  fontSize: 13.5 * s,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
//
// Copied from the HTML `translations` object (EN + HI; Telugu dropped).
// HTML-formatted labels (<br>, highlighted <span>s) are split into plain
// parts so the painter can draw the same highlight boxes natively. The
// popup texts keep a tiny markup: <b>bold</b>, <sub>subscript</sub> and
// <arrow> (the KaTeX formulas of the HTML).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Chemical Changes: Formation of New Substances',
    'app_subtitle': 'Class 7 • Changes Around Us: Physical and Chemical',
    'scen1_name': 'Scenario 1: Exhaled Air Test',
    'scen2_name': 'Scenario 2: Vinegar & Baking Soda',
    'current_task': 'Current Task',
    'hud_init': 'Initialize...',
    'btn_blow': 'BLOW AIR',
    'btn_connect': 'CONNECT TUBE',
    'popup_obs_title': 'Observation & Analysis',
    'what_happened': 'What happened here?',
    's1_conclusion':
        'When air is blown into tap water, no new substance forms (<b>Physical Change</b>).\n\n'
            'When blown into lime water, the carbon dioxide (CO<sub>2</sub>) reacts to form an insoluble white '
            'precipitate, calcium carbonate (CaCO<sub>3</sub>). Because a completely new substance was formed, '
            'this is a <b>Chemical Change</b>.',
    's2_conclusion':
        'Mixing vinegar and baking soda produces a rapid fizzing, indicating a gas is formed.\n\n'
            'Passing this gas through lime water turns it milky, confirming the gas is carbon dioxide '
            '(CO<sub>2</sub>). This formation of new substances (the gas and the calcium carbonate) are distinct '
            'examples of <b>Chemical Changes</b>.',
    'equation': 'Ca(OH)<sub>2</sub> + CO<sub>2</sub> <arrow> CaCO<sub>3</sub> + H<sub>2</sub>O',
    // HUD task per step.
    's1_h0': 'Drag Straw 1 to Beaker A',
    's1_h1': "Click 'BLOW AIR' button",
    's1_h2': 'Drag Straw 2 to Beaker B',
    's1_h3': "Click 'BLOW AIR' button",
    's1_h4': 'Observe the final summary',
    's2_h0': 'Drag Spoon to Test Tube 1',
    's2_h1': "Click 'CONNECT TUBE' button",
    's2_h2': 'Observe the results',
    's2_h3': 'Compare with Scenario 1',
    // Feedback.
    'fb_straw_correct': 'Excellent! Straw placed correctly.',
    'fb_ingredients_added': 'Great! Ingredients added.',
    'fb_wrong_spot': "Oops! That's not the right spot. Try again.",
    'fb_blowing_air': 'Blowing air...',
    'fb_obs_complete': 'Observation complete! Move to next step.',
    'fb_tube_connected': 'Tube connected! Gas is transferring...',
    'fb_scenario_complete': 'Scenario Complete! Reviewing Observation...',
    // 3D scene annotations.
    'lbl_a_tap_water': 'A - Tap Water',
    'lbl_b_lime_water': 'B - Lime Water',
    'lbl_tube1_vinegar': 'Test Tube 1 - Vinegar',
    'lbl_tube2_lime_water': 'Test Tube 2 - Lime Water',
    'lbl_baking_soda': 'Baking Soda',
    // Result labels.
    'lbl_a': 'A',
    'lbl_clear': '(Clear)',
    'lbl_b': 'B',
    'lbl_milky': '(Milky)',
    'lbl_a_desc': 'A: Physical change,\nno new substance',
    'lbl_b_desc': 'B: Chemical change,\nnew substance',
    's1sum_1a': 'Blowing air in water is a ',
    's1sum_1b': 'PHYSICAL CHANGE',
    's1sum_1c': '.',
    's1sum_2a': 'Blowing air in Lime Water is a ',
    's1sum_2b': 'CHEMICAL CHANGE',
    's1sum_2c': '.',
    's1sum_3a': 'NEW SUBSTANCE FORMED',
    's1sum_3b': ' (Calcium Carbonate).',
    'lbl_calcium_carb': 'Calcium Carbonate',
    'lbl_milky_settling': 'Milky white.\nParticles settling.',
    'lbl_scen1_beaker': 'Scenario 1 Beaker:\nCHEMICAL CHANGE,\nNEW SUBSTANCE',
    'lbl_scen2_tube': 'Scenario 2 Tube:\nCHEMICAL CHANGE,\nNEW SUBSTANCE',
    'lbl_same_change': '(same change!)',
    's2sum_1': 'The same chemical change occurred.',
    's2sum_2a': 'The gas produced is ',
    's2sum_2b': 'Carbon Dioxide',
    's2sum_2c': '',
  },
  'hi': {
    'app_title': 'रासायनिक परिवर्तन: नए पदार्थों का निर्माण',
    'app_subtitle': 'कक्षा 7 • हमारे चारों ओर के परिवर्तन: भौतिक और रासायनिक',
    'scen1_name': 'परिदृश्य 1: छोड़ी गई हवा का परीक्षण',
    'scen2_name': 'परिदृश्य 2: सिरका और बेकिंग सोडा',
    'current_task': 'वर्तमान कार्य',
    'hud_init': 'प्रारंभ हो रहा है...',
    'btn_blow': 'हवा फूंकें',
    'btn_connect': 'ट्यूब कनेक्ट करें',
    'popup_obs_title': 'अवलोकन और विश्लेषण',
    'what_happened': 'यहाँ क्या हुआ?',
    's1_conclusion':
        'जब नल के पानी में हवा फूंकी जाती है, तो कोई नया पदार्थ नहीं बनता है (<b>भौतिक परिवर्तन</b>)।\n\n'
            'जब चूने के पानी में हवा फूंकी जाती है, तो कार्बन डाइऑक्साइड (CO<sub>2</sub>) प्रतिक्रिया करके एक '
            'अघुलनशील सफेद अवक्षेप, कैल्शियम कार्बोनेट (CaCO<sub>3</sub>) बनाता है। चूंकि एक पूरी तरह से नया '
            'पदार्थ बना है, इसलिए यह एक <b>रासायनिक परिवर्तन</b> है।',
    's2_conclusion':
        'सिरका और बेकिंग सोडा मिलाने से तेज़ बुदबुदाहट होती है, जो दर्शाता है कि गैस बनी है।\n\n'
            'इस गैस को चूने के पानी से गुज़ारने पर यह दूधिया हो जाता है, जिससे पुष्टि होती है कि गैस '
            'कार्बन डाइऑक्साइड (CO<sub>2</sub>) है। नए पदार्थों (गैस और कैल्शियम कार्बोनेट) का यह निर्माण '
            '<b>रासायनिक परिवर्तन</b> के स्पष्ट उदाहरण हैं।',
    'equation': 'Ca(OH)<sub>2</sub> + CO<sub>2</sub> <arrow> CaCO<sub>3</sub> + H<sub>2</sub>O',
    's1_h0': 'स्ट्रॉ 1 को बीकर A में खींचें',
    's1_h1': "'हवा फूंकें' बटन पर क्लिक करें",
    's1_h2': 'स्ट्रॉ 2 को बीकर B में खींचें',
    's1_h3': "'हवा फूंकें' बटन पर क्लिक करें",
    's1_h4': 'अंतिम सारांश देखें',
    's2_h0': 'चम्मच को टेस्ट ट्यूब 1 में खींचें',
    's2_h1': "'ट्यूब कनेक्ट करें' बटन पर क्लिक करें",
    's2_h2': 'परिणाम देखें',
    's2_h3': 'परिदृश्य 1 के साथ तुलना करें',
    'fb_straw_correct': 'बहुत बढ़िया! स्ट्रॉ सही ढंग से रखी गई।',
    'fb_ingredients_added': 'बहुत बढ़िया! सामग्री डाल दी गई।',
    'fb_wrong_spot': 'उफ़! यह सही जगह नहीं है। पुनः प्रयास करें।',
    'fb_blowing_air': 'हवा फूंक रहे हैं...',
    'fb_obs_complete': 'अवलोकन पूरा हुआ! अगले कदम पर बढ़ें।',
    'fb_tube_connected': 'ट्यूब जुड़ गई! गैस स्थानांतरित हो रही है...',
    'fb_scenario_complete': 'परिदृश्य पूरा हुआ! अवलोकन की समीक्षा हो रही है...',
    'lbl_a_tap_water': 'A - नल का पानी',
    'lbl_b_lime_water': 'B - चूने का पानी',
    'lbl_tube1_vinegar': 'टेस्ट ट्यूब 1 - सिरका',
    'lbl_tube2_lime_water': 'टेस्ट ट्यूब 2 - चूने का पानी',
    'lbl_baking_soda': 'बेकिंग सोडा',
    'lbl_a': 'A',
    'lbl_clear': '(साफ़)',
    'lbl_b': 'B',
    'lbl_milky': '(दूधिया)',
    'lbl_a_desc': 'A: भौतिक परिवर्तन,\nकोई नया पदार्थ नहीं',
    'lbl_b_desc': 'B: रासायनिक परिवर्तन,\nनया पदार्थ',
    's1sum_1a': 'पानी में हवा फूंकना एक ',
    's1sum_1b': 'भौतिक परिवर्तन',
    's1sum_1c': ' है।',
    's1sum_2a': 'चूने के पानी में हवा फूंकना एक ',
    's1sum_2b': 'रासायनिक परिवर्तन',
    's1sum_2c': ' है।',
    's1sum_3a': 'नया पदार्थ बना',
    's1sum_3b': ' (कैल्शियम कार्बोनेट)।',
    'lbl_calcium_carb': 'कैल्शियम कार्बोनेट',
    'lbl_milky_settling': 'दूधिया सफ़ेद।\nकण नीचे बैठ रहे हैं।',
    'lbl_scen1_beaker': 'परिदृश्य 1 बीकर:\nरासायनिक परिवर्तन,\nनया पदार्थ',
    'lbl_scen2_tube': 'परिदृश्य 2 ट्यूब:\nरासायनिक परिवर्तन,\nनया पदार्थ',
    'lbl_same_change': '(समान परिवर्तन!)',
    's2sum_1': 'वही रासायनिक परिवर्तन हुआ।',
    's2sum_2a': 'उत्पन्न गैस ',
    's2sum_2b': 'कार्बन डाइऑक्साइड',
    's2sum_2c': ' है।',
  },
};

// Steps: concept = HTML step title, action = the instruction sentence of the
// step body, observation = its tagged Concept / Observation / Conclusion
// paragraph (teacher-board content kept as data only).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To observe that exhaled air can cause a chemical change when bubbled through lime water, indicating the formation of a new substance.',
      steps: [
        LabStep(
          concept: 'Setup the Control',
          action:
              "DRAG the first straw from the rack and DROP it into the beaker labeled 'A - Tap Water'.",
          observation:
              "Concept: A 'control' helps us understand how an ordinary substance behaves as a baseline comparison. Since tap water doesn't chemically react with exhaled air, it will show us what a physical change looks like.",
        ),
        LabStep(
          concept: 'Bubble Air in Beaker A',
          action:
              "Click the 'BLOW AIR' button to bubble your exhaled breath into Beaker A. Observe what happens to the water.",
          observation:
              'Observation: The bubbles indicate air passing through the liquid, but no new solid or color change occurs. The water remains water. This is a Physical Change.',
        ),
        LabStep(
          concept: 'Setup the Test',
          action:
              "DRAG the second straw from the rack and DROP it into the beaker labeled 'B - Lime Water'.",
          observation:
              'Concept: Lime water acts as a special chemical indicator. It contains dissolved calcium hydroxide, which can react with certain gases.',
        ),
        LabStep(
          concept: 'Bubble Air in Beaker B',
          action:
              "Click the 'BLOW AIR' button to bubble your exhaled breath into Beaker B. Observe the changes carefully.",
          observation:
              'Observation: The clear lime water slowly turns cloudy and milky. This visual change is direct evidence that a chemical reaction is taking place.',
        ),
        LabStep(
          concept: 'Summary & Comparison',
          action:
              'Observe the final state of both beakers. Blowing air in water is a PHYSICAL CHANGE. Blowing air in Lime Water is a CHEMICAL CHANGE.',
          observation:
              'Conclusion: Because a completely new, insoluble white substance (Calcium Carbonate precipitate) formed in the lime water, we can confirm a Chemical Change occurred.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To demonstrate that mixing an acid (vinegar) and a base (baking soda) produces a new gaseous substance, and to identify this gas as carbon dioxide.',
      steps: [
        LabStep(
          concept: 'The Vinegar and Baking Soda Reaction',
          action:
              'DRAG the spoonful of baking soda from the jar and DROP it into Test Tube 1 (containing vinegar).',
          observation:
              'Concept: Mixing an acid (vinegar) and a base (baking soda) causes a rapid reaction. The vigorous fizzing and bubbling are visual evidence that a new gas is being generated.',
        ),
        LabStep(
          concept: 'Connect Delivery Tube',
          action:
              "A delivery tube has appeared. CLICK on the tube or the 'CONNECT TUBE' button to connect the two test tubes.",
          observation:
              'Concept: By directing the unknown gas into the lime water indicator, we can test its chemical properties to identify it.',
        ),
        LabStep(
          concept: 'Observe the Reaction',
          action: 'Observe what happens in the second test tube.',
          observation:
              'Observation: Bubbles of gas travel through the delivery tube and enter the lime water, which then turns milky.',
        ),
        LabStep(
          concept: 'Compare Results',
          action:
              'Compare the results. The gas produced by mixing vinegar and baking soda is the same substance in your exhaled breath that caused the chemical change in the lime water.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह देखने के लिए कि बाहर निकाली गई हवा चूने के पानी में बुलबुले के रूप में प्रवाहित होने पर रासायनिक परिवर्तन का कारण बन सकती है, जो एक नए पदार्थ के निर्माण का संकेत देता है।',
      steps: [
        LabStep(
          concept: 'नियंत्रण (Control) सेट करें',
          action: "रैक से पहली स्ट्रॉ को ड्रैग करें और इसे 'A - नल का पानी' वाले बीकर में ड्रॉप करें।",
          observation:
              "अवधारणा: एक 'नियंत्रण' हमें यह समझने में मदद करता है कि तुलना के लिए एक साधारण पदार्थ कैसे व्यवहार करता है। चूंकि नल का पानी छोड़ी गई हवा के साथ रासायनिक प्रतिक्रिया नहीं करता है, यह हमें दिखाएगा कि भौतिक परिवर्तन कैसा दिखता है।",
        ),
        LabStep(
          concept: 'बीकर A में हवा फूंकें',
          action: "'हवा फूंकें' बटन पर क्लिक करें। पानी का क्या होता है यह देखें।",
          observation:
              'अवलोकन: बुलबुले तरल से हवा गुजरने का संकेत देते हैं, लेकिन कोई नया ठोस या रंग परिवर्तन नहीं होता है। पानी, पानी ही रहता है। यह एक भौतिक परिवर्तन है।',
        ),
        LabStep(
          concept: 'परीक्षण (Test) सेट करें',
          action: "दूसरी स्ट्रॉ को ड्रैग करें और इसे 'B - चूने का पानी' वाले बीकर में ड्रॉप करें।",
          observation:
              'अवधारणा: चूने का पानी एक विशेष रासायनिक संकेतक के रूप में कार्य करता है। इसमें घुला हुआ कैल्शियम हाइड्रॉक्साइड होता है, जो कुछ गैसों के साथ प्रतिक्रिया कर सकता है।',
        ),
        LabStep(
          concept: 'बीकर B में हवा फूंकें',
          action: "'हवा फूंकें' बटन पर क्लिक करें। परिवर्तनों को ध्यान से देखें।",
          observation:
              'अवलोकन: साफ़ चूने का पानी धीरे-धीरे दूधिया हो जाता है। यह दृश्य परिवर्तन प्रत्यक्ष प्रमाण है कि रासायनिक प्रतिक्रिया हो रही है।',
        ),
        LabStep(
          concept: 'सारांश और तुलना',
          action:
              'दोनों बीकरों की अंतिम स्थिति का निरीक्षण करें। पानी में हवा फूंकना एक भौतिक परिवर्तन है। चूने के पानी में हवा फूंकना एक रासायनिक परिवर्तन है।',
          observation:
              'निष्कर्ष: चूंकि चूने के पानी में एक पूरी तरह से नया, अघुलनशील सफेद पदार्थ (कैल्शियम कार्बोनेट अवक्षेप) बना है, हम पुष्टि कर सकते हैं कि एक रासायनिक परिवर्तन हुआ है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह प्रदर्शित करने के लिए कि एक अम्ल (सिरका) और एक क्षार (बेकिंग सोडा) को मिलाने से एक नया गैसीय पदार्थ बनता है, और इस गैस की पहचान कार्बन डाइऑक्साइड के रूप में करना।',
      steps: [
        LabStep(
          concept: 'सिरका और बेकिंग सोडा की प्रतिक्रिया',
          action:
              'जार से बेकिंग सोडा की चम्मच ड्रैग करें और इसे टेस्ट ट्यूब 1 (जिसमें सिरका है) में ड्रॉप करें।',
          observation:
              'अवधारणा: एक अम्ल (सिरका) और एक क्षार (बेकिंग सोडा) को मिलाने से तेज़ प्रतिक्रिया होती है। ज़ोरदार बुदबुदाहट इस बात का दृश्य प्रमाण है कि एक नई गैस उत्पन्न हो रही है।',
        ),
        LabStep(
          concept: 'डिलीवरी ट्यूब कनेक्ट करें',
          action:
              "एक डिलीवरी ट्यूब दिखाई दी है। दोनों टेस्ट ट्यूब को जोड़ने के लिए ट्यूब या 'ट्यूब कनेक्ट करें' बटन पर क्लिक करें।",
          observation:
              'अवधारणा: अज्ञात गैस को चूने के पानी के संकेतक में भेजकर, हम इसे पहचानने के लिए इसके रासायनिक गुणों का परीक्षण कर सकते हैं।',
        ),
        LabStep(
          concept: 'प्रतिक्रिया का निरीक्षण करें',
          action: 'दूसरी टेस्ट ट्यूब में क्या होता है यह देखें।',
          observation:
              'अवलोकन: गैस के बुलबुले डिलीवरी ट्यूब के माध्यम से यात्रा करते हैं और चूने के पानी में प्रवेश करते हैं, जो फिर दूधिया हो जाता है।',
        ),
        LabStep(
          concept: 'परिणामों की तुलना करें',
          action:
              'परिणामों की तुलना करें। सिरका और बेकिंग सोडा मिलाने से उत्पन्न गैस वही पदार्थ है जो आपकी छोड़ी गई हवा में है जिसने चूने के पानी में रासायनिक परिवर्तन किया।',
        ),
      ],
    ),
  ],
};

// ============================================================ 3D MATH
//
// The HTML renders a Three.js scene with a 45° perspective camera that
// tweens between presets (overview, focus on a beaker, summary). Here a tiny
// perspective projector maps the same world coordinates (units of the HTML
// scene) onto the 1000x560 design stage, so positions, drop distances and
// camera moves match the original.

const Size _design = Size(1000, 560);

@immutable
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

  _V3 withY(double v) => _V3(x, v, z);
  double distXZ(_V3 o) => math.sqrt((x - o.x) * (x - o.x) + (z - o.z) * (z - o.z));

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Perspective camera (fov 45°, like the HTML PerspectiveCamera).
class _Cam {
  _Cam(this.eye, this.target) {
    prepare();
  }

  _V3 eye;
  _V3 target;

  static final double _tanHalf = math.tan(22.5 * math.pi / 180);
  _V3 _f = const _V3(0, 0, -1);
  _V3 _r = const _V3(1, 0, 0);
  _V3 _u = const _V3(0, 1, 0);
  double _focal = 1;

  void prepare() {
    _f = (target - eye).unit;
    _r = _f.cross(const _V3(0, 1, 0)).unit;
    _u = _r.cross(_f);
    _focal = _design.height / 2 / _tanHalf;
  }

  /// Distance along the view direction (larger = further away).
  double depth(_V3 p) => (p - eye).dot(_f);

  /// Design pixels per world unit at [p].
  double k(_V3 p) => _focal / math.max(depth(p), 0.1);

  Offset pt(_V3 p) {
    final d = p - eye;
    final kk = _focal / math.max(d.dot(_f), 0.1);
    return Offset(_design.width / 2 + d.dot(_r) * kk, _design.height / 2 - d.dot(_u) * kk);
  }

  /// Minor / major axis ratio of a horizontal circle seen at [p].
  double tilt(_V3 p) => (eye - p).unit.y.abs().clamp(0.04, 1.0);

  /// Projected ellipse of a horizontal circle of radius [r] centred at [c].
  Rect ellipse(_V3 c, double r) {
    final a = r * k(c);
    return Rect.fromCenter(center: pt(c), width: 2 * a, height: 2 * a * tilt(c));
  }

  /// Ray through design point [s] intersected with the plane y = [h]
  /// (the HTML drag plane).
  _V3? onPlaneY(Offset s, double h) {
    final dir = _f +
        _r * ((s.dx - _design.width / 2) / _focal) +
        _u * (-(s.dy - _design.height / 2) / _focal);
    if (dir.y.abs() < 1e-6) return null;
    final t = (h - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

// Camera presets. The HTML values are kept where everything fits; a few are
// pulled back slightly so the straws, spoon and delivery tube stay on the
// 1000x560 stage (the HTML cut some of them off).
const _V3 _s1Eye = _V3(0, 6.8, 15); // HTML (0, 6, 12)
const _V3 _s1Target = _V3(0, 3, 0);
const _V3 _s1SumEye = _V3(0, 5.4, 13.5); // HTML (0, 5, 14)
const _V3 _s1SumTarget = _V3(0, 2.6, 0);
const _V3 _s2Eye = _V3(1.2, 6.2, 15.5); // HTML (0, 5, 10)
const _V3 _s2Target = _V3(1.2, 2.4, 0);
const _V3 _s2FizzEye = _V3(0, 4.5, 12.5); // HTML (0, 2, 8)
const _V3 _s2FizzTarget = _V3(0, 3.6, 0);
const _V3 _s2SumEye = _V3(0, 7.4, 17); // HTML (0, 7, 16)
const _V3 _s2SumTarget = _V3(0, 2.7, 4);

/// Height the unconnected delivery tube hovers at (HTML: 3, which was
/// outside the camera view).
const double _tubeHover = 1.2;

// ============================================================ SCENE MODEL

const Color _glassColor = Color(0xFF94A3B8);
const Color _ink = Color(0xFF0F172A);
const Color _cardYellow = Color(0xFFFEF08A);

class _Bubble {
  _Bubble(this.x, this.y, this.z, this.scale, this.speed);
  double x, y, z;
  final double scale;
  final double speed; // units per 60 fps frame, like the HTML
}

/// HTML `createBubbles()`: 40 bubbles rising from [yStart] to [yEnd]
/// (relative to the parent group) within ±0.75 * [radius].
class _Bubbles {
  _Bubbles(this.yStart, this.yEnd, this.radius, math.Random rnd) {
    for (var i = 0; i < 40; i++) {
      items.add(_Bubble(
        (rnd.nextDouble() - 0.5) * radius * 1.5,
        yStart + rnd.nextDouble() * (yEnd - yStart),
        (rnd.nextDouble() - 0.5) * radius * 1.5,
        rnd.nextDouble() * 0.5 + 0.5,
        rnd.nextDouble() * 0.08 + 0.04,
      ));
    }
  }

  final double yStart, yEnd, radius;
  final List<_Bubble> items = [];
  bool visible = true;

  /// Advances the bubbles; returns how many wrapped back to the bottom.
  int update(double dt, math.Random rnd) {
    if (!visible) return 0;
    var wraps = 0;
    final f = dt * 60;
    for (final b in items) {
      b.y += b.speed * f;
      if (b.y > yEnd) {
        b.y = yStart;
        b.x = (rnd.nextDouble() - 0.5) * radius * 1.5;
        b.z = (rnd.nextDouble() - 0.5) * radius * 1.5;
        wraps++;
      }
    }
    return wraps;
  }
}

/// A beaker (HTML `createBeaker`) or a test tube (`createTestTube`).
class _Vessel {
  _Vessel.beaker(this.pos, this.liquid, this.opacity) : isTube = false;
  _Vessel.tube(this.pos, this.liquid, this.opacity) : isTube = true;

  final bool isTube;

  /// Group position (beaker: base centre; tube: centre of the glass).
  _V3 pos;
  Color liquid;
  double opacity;

  /// Emissive "milky" glow (0..1), the HTML emissive 0x333333 tween.
  double milk = 0;
  _Bubbles? bubbles;

  double get radius => isTube ? 0.5 : 1.5;
  double get liquidRadius => isTube ? 0.45 : 1.45;

  /// Bottom / top of the straight glass wall (a tube adds a hemisphere).
  double get wallBottom => isTube ? pos.y - 2.25 : pos.y;
  double get wallTop => isTube ? pos.y + 2.25 : pos.y + 4;
  double get liquidBottom => isTube ? pos.y - 2.25 : pos.y + 0.1;
  double get liquidTop => isTube ? pos.y - 0.25 : pos.y + 2.6;

  /// The rim (HTML `targetPos` / `topPos` use y = 4.5).
  _V3 get mouth => _V3(pos.x, 4.5, pos.z);

  /// Inside the wooden rack (the base board hides the bottom).
  bool get inRack => isTube && pos.z.abs() <= 1.0 && pos.x.abs() <= 3.0;
}

/// HTML `createStraw`: 7 units long, tilted by π/12 until placed.
class _Straw {
  _Straw(this.pos, this.color) : start = pos;
  _V3 pos;
  final _V3 start;
  final Color color;
  double rotZ = math.pi / 12;
  bool draggable = true;
  _Vessel? placedIn;

  _V3 get axis => _V3(-math.sin(rotZ), math.cos(rotZ), 0);
  _V3 get top => pos + axis * 3.5;
  _V3 get bottom => pos - axis * 3.5;
}

/// HTML `createSpoon`: bowl at the origin, 3.5 unit handle along +x.
class _Spoon {
  _Spoon(this.pos) : start = pos;
  _V3 pos;
  final _V3 start;
  double rotZ = 0;
  bool powder = true;
  bool draggable = true;

  _V3 get dir => _V3(math.cos(rotZ), math.sin(rotZ), 0);
  _V3 get handleEnd => pos + dir * 3.5;
}

/// HTML `createDeliveryTube`: cubic bezier between the two tube mouths
/// plus a cork on tube 1, moved as a group by [offset].
class _DeliveryTube {
  _DeliveryTube(this.start, this.end) : offset = const _V3(0, _tubeHover, 0);
  final _V3 start, end;
  _V3 offset;
  bool clickable = true;
  bool bubblesOn = false;
  final List<double> progress = [for (var i = 0; i < 15; i++) i / 15];

  _V3 point(double t) {
    final p0 = start, p3 = end;
    final p1 = start + const _V3(0, 3, 0), p2 = end + const _V3(0, 3, 0);
    final u = 1 - t;
    return p0 * (u * u * u) + p1 * (3 * u * u * t) + p2 * (3 * u * t * t) + p3 * (t * t * t) + offset;
  }
}

/// Baking soda grains falling from the tilted spoon (visual polish for the
/// HTML's instant powder disappearance).
class _Grain {
  _Grain(this.pos, this.mouth, this.delay) : start = pos;
  _V3 pos;
  final _V3 start;

  /// Mouth of test tube 1: grains converge on it while falling.
  final _V3 mouth;
  double delay;
  double vy = 0;
}

enum _AnnKind {
  tapWater,
  limeWater,
  tube1,
  tube2,
  soda,
  aClear,
  aDesc,
  bMilky,
  bDesc,
  s1Summary,
  calcium,
  scen1Beaker,
  scen2Tube,
  arrow,
  s2Summary,
}

/// HTML `createHTMLAnnotation(html, pos3D)`.
class _Annotation {
  _Annotation(this.kind, this.pos, this.born);
  final _AnnKind kind;
  final _V3 pos;
  final double born;

  /// Time a fade-out started (stale labels in the scenario 2 comparison).
  double? fadeFrom;
}

/// One running tween (HTML TWEEN.Tween). [setup] runs when the tween starts
/// (after its delay), captures the start values and returns the updater.
class _Anim {
  _Anim(this.at, this.dur, this.curve, this.setup, this.done, this.tag);
  final double at;
  final double dur;
  final Curve curve;
  final void Function(double t) Function() setup;
  final VoidCallback? done;
  final Object? tag;
  void Function(double t)? apply;
}

/// Mutable scene read by the painter every frame.
class _Scene {
  int scenario = 0;
  double time = 0;
  final _Cam cam = _Cam(_s1Eye, _s1Target);
  final math.Random rnd = math.Random(7);

  _Vessel? beakerA, beakerB, tubeA, tubeB, milkyBeaker;
  final List<_Straw> straws = [];
  _Spoon? spoon;
  _DeliveryTube? dTube;
  bool hasRack = false;
  final List<_Grain> grains = [];
  final List<_Annotation> annotations = [];
  final List<_Anim> anims = [];

  /// Floating dust (HTML `THREE.Points`, 200 points in a 50 unit cube).
  late final List<_V3> dust = [
    for (var i = 0; i < 200; i++)
      _V3((rnd.nextDouble() - 0.5) * 50, (rnd.nextDouble() - 0.5) * 50, (rnd.nextDouble() - 0.5) * 50),
  ];
  double dustRotX = 0, dustRotY = 0;

  /// Object being dragged (a straw or the spoon) — drawn highlighted.
  Object? dragged;

  Iterable<_Vessel> get vessels =>
      [beakerA, beakerB, tubeA, tubeB, milkyBeaker].whereType<_Vessel>();

  void clear() {
    beakerA = beakerB = tubeA = tubeB = milkyBeaker = null;
    straws.clear();
    spoon = null;
    dTube = null;
    hasRack = false;
    grains.clear();
    annotations.clear();
    anims.clear();
    dragged = null;
  }

  void annotate(_AnnKind kind, _V3 pos) => annotations.add(_Annotation(kind, pos, time));

  void animate(
    double ms,
    void Function(double t) Function() setup, {
    double delayMs = 0,
    Curve curve = Curves.linear,
    VoidCallback? done,
    Object? tag,
  }) {
    anims.add(_Anim(time + delayMs / 1000, ms / 1000, curve, setup, done, tag));
  }

  void cancel(Object tag) => anims.removeWhere((a) => a.tag == tag);

  void tickAnims() {
    if (anims.isEmpty) return;
    for (final a in List<_Anim>.of(anims)) {
      if (!anims.contains(a) || time < a.at) continue;
      a.apply ??= a.setup();
      final t = a.dur <= 0 ? 1.0 : ((time - a.at) / a.dur).clamp(0.0, 1.0);
      a.apply!(a.curve.transform(t));
      if (t >= 1) {
        anims.remove(a);
        a.done?.call();
      }
    }
  }

  /// Advances bubbles, tube bubbles, grains and dust. Returns the number of
  /// bubble "pops" that should play a sound (10 % / 20 % chance per wrap,
  /// like the HTML `Sounds.bubble()` calls).
  int tickParticles(double dt) {
    var sounds = 0;
    for (final v in vessels) {
      final w = v.bubbles?.update(dt, rnd) ?? 0;
      for (var i = 0; i < w; i++) {
        if (rnd.nextDouble() < 0.1) sounds++;
      }
    }
    final d = dTube;
    if (d != null && d.bubblesOn) {
      for (var i = 0; i < d.progress.length; i++) {
        d.progress[i] += 0.01 * dt * 60;
        if (d.progress[i] > 1) {
          d.progress[i] = 0;
          if (rnd.nextDouble() < 0.2) sounds++;
        }
      }
    }
    for (final g in List<_Grain>.of(grains)) {
      if (g.delay > 0) {
        g.delay -= dt;
        continue;
      }
      g.vy -= 9.8 * dt;
      final y = g.pos.y + g.vy * dt;
      final f = ((y - g.mouth.y) / (g.start.y - g.mouth.y)).clamp(0.0, 1.0);
      g.pos = _V3(
        g.mouth.x + (g.start.x - g.mouth.x) * f,
        y,
        g.mouth.z + (g.start.z - g.mouth.z) * f,
      );
      if (y < g.mouth.y - 0.7) grains.remove(g);
    }
    dustRotY += 0.0005 * dt * 60;
    dustRotX += 0.0002 * dt * 60;
    return sounds;
  }
}

// ============================================================ PAINTER

Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..color = color;

/// Side silhouette of a vertical cylinder between ellipses [top] and [bot]
/// (with a hemispherical bottom when [round]).
Path _bodyPath(Rect top, Rect bot, {bool round = false}) {
  final p = Path()
    ..moveTo(top.left, top.center.dy)
    ..lineTo(bot.left, bot.center.dy);
  if (round) {
    p.arcTo(Rect.fromCircle(center: bot.center, radius: bot.width / 2), math.pi, -math.pi, false);
  } else {
    p.arcTo(bot, math.pi, -math.pi, false);
  }
  p
    ..lineTo(top.right, top.center.dy)
    ..arcTo(top, 0, -math.pi, false)
    ..close();
  return p;
}

/// Shaded rod (straws, spoon handle, pillars seen side-on).
void _rod(Canvas c, Offset a, Offset b, double w, Color color, {double opacity = 1}) {
  final d = b - a;
  final len = d.distance;
  if (len < 0.5 || w <= 0) return;
  c.save();
  c.translate(a.dx, a.dy);
  c.rotate(math.atan2(d.dy, d.dx));
  final r = Rect.fromLTWH(0, -w / 2, len, w);
  c.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(w / 2)),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          labShade(color, 0.4).withValues(alpha: opacity),
          color.withValues(alpha: opacity),
          labShade(color, -0.4).withValues(alpha: opacity),
        ],
        stops: const [0, 0.42, 1],
      ).createShader(r),
  );
  c.restore();
}

class _LabPainter extends CustomPainter {
  _LabPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final String Function(String key) tr;

  _Cam get cam => scene.cam;

  @override
  void paint(Canvas canvas, Size size) {
    cam.prepare();
    _background(canvas, size);
    _bench(canvas, size);
    _dust(canvas, size);
    _shadows(canvas);

    // Painter's algorithm: far objects first.
    final items = <(double, VoidCallback)>[];
    void add(_V3 anchor, VoidCallback draw, {double bias = 0}) =>
        items.add((cam.depth(anchor) + bias, draw));

    for (final v in [scene.beakerA, scene.beakerB, scene.milkyBeaker].whereType<_Vessel>()) {
      add(v.pos.withY(2), () => _vessel(canvas, v));
    }
    if (scene.hasRack) {
      add(const _V3(0, 1.5, 0), () => _rack(canvas));
    }
    for (final v in [scene.tubeA, scene.tubeB].whereType<_Vessel>()) {
      if (!v.inRack) add(v.pos, () => _vessel(canvas, v));
    }
    final d = scene.dTube;
    if (d != null) add(d.start + d.offset, () => _deliveryTube(canvas, d), bias: -0.6);
    if (scene.scenario == 1) add(const _V3(5.5, 0.8, 1.5), () => _jar(canvas));
    final sp = scene.spoon;
    if (sp != null) add(sp.pos, () => _spoon(canvas, sp), bias: -0.2);
    for (final s in scene.straws) {
      if (s.placedIn == null) add(s.pos, () => _straw(canvas, s));
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final i in items) {
      i.$2();
    }
    _grains(canvas);
    if (showLabels) _annotations(canvas);
  }

  // ------------------------------------------------------------ backdrop

  void _background(Canvas c, Size size) {
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 1.25, height: size.width * 1.25);
    c.drawRect(
      labBleed(size),
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF020617)]
              : const [Color(0xFFF1F5F9), Color(0xFFCBD5E1)],
        ).createShader(rect),
    );
  }

  /// Dark wooden table (HTML 40x25 plane, colour 0x3d2314).
  void _bench(Canvas c, Size size) {
    final bleed = labBleed(size);
    final yFar = cam.pt(const _V3(0, 0, -12.5)).dy;
    if (yFar > bleed.bottom) return;
    final top = math.max(yFar, bleed.top);
    const wood = Color(0xFF3D2314);
    c.drawRect(
      Rect.fromLTRB(bleed.left, top, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(wood, -0.3), labShade(wood, 0.08), labShade(wood, 0.16)],
          stops: const [0, 0.5, 1],
        ).createShader(Rect.fromLTRB(0, top, size.width, size.height + 60)),
    );
    // Plank seams and grain receding towards the back edge.
    final zNear = math.min(12.5, cam.eye.z - 1.2);
    final seam = _stroke(Colors.black.withValues(alpha: 0.3), 1.3);
    final grain = _stroke(const Color(0xFFD6A77A).withValues(alpha: 0.06), 1);
    for (var x = -40.0; x <= 40.0; x += 2.4) {
      c.drawLine(cam.pt(_V3(x, 0, -12.5)), cam.pt(_V3(x, 0, zNear)), seam);
      for (var g = 0; g < 3; g++) {
        final gx = x + 0.5 + g * 0.6 + 0.2 * math.sin(x * 3.1 + g);
        final z0 = -12.5 + 6 * (0.5 + 0.5 * math.sin(x * 1.7 + g * 2.3));
        c.drawLine(cam.pt(_V3(gx, 0, z0)), cam.pt(_V3(gx, 0, math.min(z0 + 7, zNear))), grain);
      }
    }
    // Back edge of the table top.
    c.drawLine(Offset(bleed.left, top), Offset(bleed.right, top), _stroke(labShade(wood, 0.35), 2));
  }

  /// Slowly rotating dust points (HTML `THREE.Points`, opacity 0.3).
  void _dust(Canvas c, Size size) {
    final cy = math.cos(scene.dustRotY), sy = math.sin(scene.dustRotY);
    final cx = math.cos(scene.dustRotX), sx = math.sin(scene.dustRotX);
    final paint = Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.3);
    final view = labBleed(size);
    for (final p in scene.dust) {
      final x1 = p.x * cy + p.z * sy;
      final z1 = -p.x * sy + p.z * cy;
      final w = _V3(x1, p.y * cx - z1 * sx, p.y * sx + z1 * cx);
      if (w.y < 0 || cam.depth(w) < 0.6) continue;
      final o = cam.pt(w);
      if (!view.contains(o)) continue;
      c.drawCircle(o, (0.05 * cam.k(w)).clamp(0.6, 4.0), paint);
    }
  }

  /// Soft shadows on the bench (directional light from (5, 10, 5)).
  void _shadows(Canvas c) {
    _V3 onBench(_V3 p) => _V3(p.x - 0.5 * p.y, 0.001, p.z - 0.5 * p.y);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (final s in scene.straws) {
      if (s.placedIn != null) continue;
      shadow.strokeWidth = 0.25 * cam.k(s.pos);
      c.drawLine(cam.pt(onBench(s.bottom)), cam.pt(onBench(s.top)), shadow);
    }
    final sp = scene.spoon;
    if (sp != null) {
      shadow.strokeWidth = 0.18 * cam.k(sp.pos);
      c.drawLine(cam.pt(onBench(sp.pos)), cam.pt(onBench(sp.handleEnd)), shadow);
      final b = cam.ellipse(onBench(sp.pos), 0.4);
      c.drawOval(b, Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  // ------------------------------------------------------------- vessels

  /// Glass beaker / test tube between world heights [lo] and [hi] (the rack
  /// draws a tube in two parts around its top board).
  void _vessel(Canvas c, _Vessel v, {double? lo, double? hi}) {
    final r = v.radius;
    final sphereBottom = v.isTube ? v.wallBottom - r : v.wallBottom;
    final cut = lo ?? (v.inRack ? 0.5 : 0.0);
    final yTop = math.min(hi ?? v.wallTop, v.wallTop);
    final round = v.isTube && sphereBottom >= cut - 1e-6;
    final yBot = round ? v.wallBottom : math.max(v.wallBottom, cut);
    if (yTop <= yBot) return;
    _V3 at(double y) => _V3(v.pos.x, y, v.pos.z);
    final eTop = cam.ellipse(at(yTop), r);
    final eBot = cam.ellipse(at(yBot), r);
    final body = _bodyPath(eTop, eBot, round: round);
    final isFullTop = yTop >= v.wallTop - 1e-6;

    // Contact shadow (beakers and free-standing tubes).
    if (lo == null && !v.inRack) {
      final s = cam.ellipse(_V3(v.pos.x - 0.45, 0.001, v.pos.z - 0.45), r * 1.15);
      c.drawOval(s, Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }

    Color g(double a) => _glassColor.withValues(alpha: a);
    // Back wall of the glass (seen through the front).
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [g(0.34), g(0.12), g(0.07), g(0.28)],
          stops: const [0, 0.3, 0.7, 1],
        ).createShader(body.getBounds()),
    );
    if (isFullTop) c.drawArc(eTop, math.pi, math.pi, false, _stroke(g(0.7), 1.6));

    for (final s in scene.straws) {
      if (s.placedIn == v) _straw(c, s);
    }
    _liquid(c, v, cut, yTop);
    _bubbles(c, v, cut, yTop);

    // Front wall: edges, bottom, highlight and the rim (HTML torus).
    final outline = Path()
      ..moveTo(eTop.left, eTop.center.dy)
      ..lineTo(eBot.left, eBot.center.dy);
    if (round) {
      outline.arcTo(Rect.fromCircle(center: eBot.center, radius: eBot.width / 2), math.pi, -math.pi, false);
    } else {
      outline.arcTo(eBot, math.pi, -math.pi, false);
    }
    outline.lineTo(eTop.right, eTop.center.dy);
    c.drawPath(outline, _stroke(g(0.9), 1.8));
    final hw = math.max(2.0, eTop.width * 0.07);
    c.drawLine(
      Offset(eTop.left + eTop.width * 0.2, eTop.center.dy + eTop.height * 0.6),
      Offset(eBot.left + eBot.width * 0.2, eBot.center.dy - (round ? 0 : eBot.height * 0.2)),
      _stroke(Colors.white.withValues(alpha: 0.28), hw),
    );
    c.drawLine(
      Offset(eTop.left + eTop.width * 0.84, eTop.center.dy + eTop.height * 0.7),
      Offset(eBot.left + eBot.width * 0.84, eBot.center.dy - eBot.height * 0.1),
      _stroke(Colors.white.withValues(alpha: 0.12), hw * 0.6),
    );
    if (isFullTop) {
      c.drawArc(eTop, 0, math.pi, false, _stroke(Colors.white.withValues(alpha: 0.65), 2.6));
      c.drawArc(eTop, math.pi, math.pi, false, _stroke(Colors.white.withValues(alpha: 0.3), 1.4));
    }
  }

  void _liquid(Canvas c, _Vessel v, double cut, double hi) {
    if (v.opacity <= 0) return;
    final lr = v.liquidRadius;
    final round = v.isTube && v.liquidBottom - lr >= cut - 1e-6;
    final yb = round ? v.liquidBottom : math.max(v.liquidBottom, cut);
    final yt = math.min(v.liquidTop, hi);
    if (yt <= yb) return;
    _V3 at(double y) => _V3(v.pos.x, y, v.pos.z);
    final eT = cam.ellipse(at(yt), lr);
    final eB = cam.ellipse(at(yb), lr);
    final path = _bodyPath(eT, eB, round: round);
    final col = v.liquid;
    final a = v.opacity.clamp(0.0, 1.0);
    final glow = v.milk;
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(col, -0.32 + 0.2 * glow).withValues(alpha: a),
          labShade(col, 0.05 * glow).withValues(alpha: a),
          labShade(col, 0.22).withValues(alpha: a),
          labShade(col, -0.38 + 0.2 * glow).withValues(alpha: a),
        ], stops: const [0, 0.35, 0.65, 1]).createShader(path.getBounds()),
    );
    if (glow > 0.01) {
      // Cloudy calcium carbonate swirls in the milky liquid.
      c.save();
      c.clipPath(path);
      final b = path.getBounds();
      for (var i = 0; i < 9; i++) {
        final fx = 0.5 + 0.42 * math.sin(i * 2.1 + scene.time * 0.35);
        final fy = 0.15 + 0.8 * ((i * 0.37 + scene.time * 0.03) % 1.0);
        c.drawCircle(
          Offset(b.left + b.width * fx, b.top + b.height * fy),
          b.width * (0.14 + 0.05 * (i % 3)),
          Paint()
            ..color = (i.isEven ? Colors.white : const Color(0xFFCBD5E1)).withValues(alpha: 0.35 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      c.restore();
    }
    if (yt >= v.liquidTop - 1e-6) {
      c.drawOval(eT, Paint()..color = labShade(col, 0.28).withValues(alpha: math.min(1.0, a * 0.9 + 0.1)));
      c.drawOval(eT, _stroke(Colors.white.withValues(alpha: 0.3), 1));
    }
  }

  void _bubbles(Canvas c, _Vessel v, double cut, double hi) {
    final b = v.bubbles;
    if (b == null || !b.visible) return;
    for (final bb in b.items) {
      final w = _V3(v.pos.x + bb.x, v.pos.y + bb.y, v.pos.z + bb.z);
      if (w.y < cut + 0.05 || w.y > hi) continue;
      final f = (bb.y - b.yStart) / (b.yEnd - b.yStart);
      final alpha = (f < 0.08 ? f / 0.08 : (f > 0.88 ? (1 - f) / 0.12 : 1.0)).clamp(0.0, 1.0);
      final o = cam.pt(w);
      final rr = math.max(1.2, 0.08 * bb.scale * cam.k(w));
      c.drawCircle(o, rr, Paint()..color = Colors.white.withValues(alpha: 0.92 * alpha));
      c.drawCircle(o, rr, _stroke(const Color(0xFF64748B).withValues(alpha: 0.45 * alpha), 0.8));
    }
  }

  // ------------------------------------------------------- straws, spoon

  void _straw(Canvas c, _Straw s) {
    final a = cam.pt(s.bottom), b = cam.pt(s.top);
    final w = math.max(3.0, 0.2 * cam.k(s.pos));
    if (scene.dragged == s) {
      c.drawLine(a, b, Paint()
        ..color = _Colors.zslYellow.withValues(alpha: 0.5)
        ..strokeWidth = w + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    _rod(c, a, b, w, s.color);
    // Flexible "bendy" section near the top.
    final ringPaint = _stroke(labShade(s.color, -0.45).withValues(alpha: 0.7), 1.2);
    final d = b - a;
    final n = Offset(-d.dy, d.dx) / d.distance * (w / 2);
    for (var i = 0; i < 5; i++) {
      final p = Offset.lerp(a, b, 0.76 + i * 0.022)!;
      c.drawLine(p - n, p + n, ringPaint);
    }
  }

  void _spoon(Canvas c, _Spoon s) {
    const metal = Color(0xFFE2E8F0);
    final k = cam.k(s.pos);
    final bowlC = cam.pt(s.pos);
    if (scene.dragged == s) labGlow(c, bowlC, 0.9 * k, _Colors.zslYellow, intensity: 0.6);
    _rod(c, cam.pt(s.pos + s.dir * 0.3), cam.pt(s.handleEnd), math.max(4.0, 0.12 * k), metal);
    final along = cam.pt(s.pos + s.dir * 0.42) - bowlC;
    final half = math.max(along.distance, 6.0);
    final depthHalf = math.max(0.28 * k * cam.tilt(s.pos), 0.15 * k);
    c.save();
    c.translate(bowlC.dx, bowlC.dy);
    c.rotate(math.atan2(along.dy, along.dx));
    final rect = Rect.fromCenter(center: Offset.zero, width: half * 2, height: depthHalf * 2);
    c.drawOval(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Colors.white, metal, Color(0xFF94A3B8)],
          stops: [0, 0.5, 1],
        ).createShader(rect),
    );
    c.drawOval(rect, _stroke(const Color(0xFF64748B), 1));
    if (s.powder) {
      final pr = Rect.fromCenter(center: Offset(0, -depthHalf * 0.6), width: half * 1.55, height: depthHalf * 1.7);
      c.drawOval(
        pr,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.2, -0.5),
            colors: [Colors.white, Color(0xFFF1F5F9), Color(0xFFCBD5E1)],
          ).createShader(pr),
      );
    }
    c.restore();
  }

  // ------------------------------------------------- jar, rack, tubing

  /// Opaque upright cylinder / frustum (jar, lid, pillars, cork).
  void _solid(Canvas c, _V3 base, double r, double y0, double y1, Color color,
      {double? rTop, bool top = true}) {
    final eB = cam.ellipse(base.withY(y0), r);
    final eT = cam.ellipse(base.withY(y1), rTop ?? r);
    final body = _bodyPath(eT, eB);
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(color, -0.35),
          labShade(color, 0.22),
          color,
          labShade(color, -0.45),
        ], stops: const [0, 0.3, 0.62, 1]).createShader(body.getBounds()),
    );
    if (top) {
      c.drawOval(eT, Paint()..color = labShade(color, 0.12));
      c.drawOval(eT, _stroke(labShade(color, -0.3).withValues(alpha: 0.6), 1));
    }
  }

  /// HTML `createBakingSodaJar` at (5.5, 0, 1.5): white jar, blue label and lid.
  void _jar(Canvas c) {
    const base = _V3(5.5, 0, 1.5);
    c.drawOval(cam.ellipse(const _V3(5.1, 0.001, 1.1), 0.95), Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    _solid(c, base, 0.8, 0, 1.5, const Color(0xFFF8FAFC), top: false);
    const blue = Color(0xFF2563EB);
    final eT = cam.ellipse(base.withY(1.2), 0.82);
    final eB = cam.ellipse(base.withY(0.4), 0.82);
    final band = Path()
      ..moveTo(eT.left, eT.center.dy)
      ..arcTo(eT, math.pi, -math.pi, false)
      ..lineTo(eB.right, eB.center.dy)
      ..arcTo(eB, 0, math.pi, false)
      ..close();
    c.drawPath(
      band,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(blue, -0.35),
          labShade(blue, 0.25),
          blue,
          labShade(blue, -0.45),
        ], stops: const [0, 0.3, 0.62, 1]).createShader(band.getBounds()),
    );
    _solid(c, base, 0.85, 1.5, 1.7, blue);
  }

  /// Cuboid with its camera-facing faces shaded (Three.js BoxGeometry).
  void _box(Canvas c, _V3 center, _V3 half, Color color) {
    final x0 = center.x - half.x, x1 = center.x + half.x;
    final y0 = center.y - half.y, y1 = center.y + half.y;
    final z0 = center.z - half.z, z1 = center.z + half.z;
    Offset p(double x, double y, double z) => cam.pt(_V3(x, y, z));
    final edge = _stroke(labShade(color, -0.55).withValues(alpha: 0.5), 1);
    void face(List<Offset> pts, Color fill) {
      final path = Path()..addPolygon(pts, true);
      c.drawPath(path, Paint()..color = fill);
      c.drawPath(path, edge);
    }

    final e = cam.eye;
    if (e.x < x0) face([p(x0, y0, z0), p(x0, y0, z1), p(x0, y1, z1), p(x0, y1, z0)], labShade(color, -0.28));
    if (e.x > x1) face([p(x1, y0, z0), p(x1, y0, z1), p(x1, y1, z1), p(x1, y1, z0)], labShade(color, -0.28));
    if (e.z > z1) face([p(x0, y0, z1), p(x1, y0, z1), p(x1, y1, z1), p(x0, y1, z1)], labShade(color, -0.08));
    if (e.y > y1) face([p(x0, y1, z0), p(x1, y1, z0), p(x1, y1, z1), p(x0, y1, z1)], labShade(color, 0.16));
  }

  /// HTML `createTestTubeRack` plus the tubes standing in it.
  void _rack(Canvas c) {
    const wood = Color(0xFF8B5A2B);
    c.drawOval(cam.ellipse(const _V3(-0.6, 0.001, -0.6), 3.6), Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    _box(c, const _V3(0, 0.25, 0), const _V3(3, 0.25, 1), wood);
    for (final x in [-2.8, 2.8]) {
      _solid(c, _V3(x, 0, -0.8), 0.2, 0.5, 2.75, wood, top: false);
    }
    final inRack = [scene.tubeA, scene.tubeB].whereType<_Vessel>().where((v) => v.inRack).toList()
      ..sort((a, b) => cam.depth(b.pos).compareTo(cam.depth(a.pos)));
    for (final v in inRack) {
      _vessel(c, v, lo: 0.5, hi: 2.75);
    }
    for (final x in [-2.8, 2.8]) {
      _solid(c, _V3(x, 0, 0.8), 0.2, 0.5, 2.75, wood, top: false);
    }
    _box(c, const _V3(0, 3, 0), const _V3(3, 0.25, 1), wood);
    for (final v in inRack) {
      c.drawOval(cam.ellipse(v.pos.withY(3.25), 0.56), Paint()..color = labShade(wood, -0.6));
      _vessel(c, v, lo: 3.25);
    }
  }

  /// HTML `createDeliveryTube`: glass tube along the bezier, cork on tube 1
  /// and the gas bubbles travelling through it.
  void _deliveryTube(Canvas c, _DeliveryTube d) {
    final pts = [for (var i = 0; i <= 40; i++) cam.pt(d.point(i / 40))];
    final path = Path()..addPolygon(pts, false);
    final w = math.max(4.0, 0.3 * cam.k(d.start + d.offset));
    if (d.clickable) {
      final pulse = 0.5 + 0.5 * math.sin(scene.time * 4);
      c.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w + 10 + 6 * pulse
        ..strokeCap = StrokeCap.round
        ..color = _Colors.zslYellow.withValues(alpha: 0.25 + 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    c.drawPath(path, _stroke(_glassColor.withValues(alpha: 0.85), w));
    c.drawPath(path, _stroke(const Color(0xFFE2E8F0).withValues(alpha: 0.35), w * 0.55));
    c.drawPath(path.shift(Offset(0, -w * 0.18)), _stroke(Colors.white.withValues(alpha: 0.55), w * 0.18));
    if (d.bubblesOn) {
      for (final p in d.progress) {
        final wp = d.point(p);
        c.drawCircle(cam.pt(wp), math.max(1.5, 0.08 * cam.k(wp)), Paint()..color = Colors.white);
      }
    }
    final cork = d.start + d.offset;
    _solid(c, cork, 0.48, cork.y, cork.y + 0.5, const Color(0xFF4B5563), rTop: 0.55);
  }

  void _grains(Canvas c) {
    final paint = Paint()..color = Colors.white;
    for (final g in scene.grains) {
      if (g.delay > 0) continue;
      c.drawCircle(cam.pt(g.pos), math.max(1.2, 0.05 * cam.k(g.pos)), paint);
    }
  }

  // --------------------------------------------------------- annotations

  /// HTML annotation divs, projected from their 3D anchor points.
  void _annotations(Canvas c) {
    const slate300 = Color(0xFFCBD5E1);
    for (final a in scene.annotations) {
      var fade = ((scene.time - a.born) / 0.3).clamp(0.0, 1.0);
      final f0 = a.fadeFrom;
      if (f0 != null) fade = math.min(fade, (1 - (scene.time - f0) / 0.4).clamp(0.0, 1.0));
      if (fade <= 0 || cam.depth(a.pos) < 0.5) continue;
      final at = cam.pt(a.pos);
      if (fade < 1) c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: fade));
      switch (a.kind) {
        case _AnnKind.tapWater:
        case _AnnKind.limeWater:
          _card(c, [_Seg(tr(a.kind == _AnnKind.tapWater ? 'lbl_a_tap_water' : 'lbl_b_lime_water'), size: 18, color: Colors.white)], at,
              bg: _Colors.slate900, border: _Colors.slate700, radius: 6);
        case _AnnKind.tube1:
        case _AnnKind.tube2:
        case _AnnKind.soda:
          final key = switch (a.kind) {
            _AnnKind.tube1 => 'lbl_tube1_vinegar',
            _AnnKind.tube2 => 'lbl_tube2_lime_water',
            _ => 'lbl_baking_soda',
          };
          _card(c, [_Seg(tr(key), size: 15)], at,
              maxWidth: a.kind == _AnnKind.soda ? null : math.max(92.0, 2.75 * cam.k(a.pos) - 14),
              bg: Colors.white, border: slate300, borderW: 1, radius: 5,
              pad: const EdgeInsets.symmetric(horizontal: 8, vertical: 3));
        case _AnnKind.aClear:
        case _AnnKind.bMilky:
          final isA = a.kind == _AnnKind.aClear;
          _card(c, [
            _Seg('${tr(isA ? 'lbl_a' : 'lbl_b')}\n', size: 25, weight: FontWeight.w800),
            _Seg(tr(isA ? 'lbl_clear' : 'lbl_milky'), size: 15, weight: FontWeight.w600),
          ], at, bg: Colors.white, border: slate300, radius: 12);
        case _AnnKind.aDesc:
        case _AnnKind.bDesc:
          final isA = a.kind == _AnnKind.aDesc;
          _card(c, [_Seg(tr(isA ? 'lbl_a_desc' : 'lbl_b_desc'), size: 18)], at,
              bg: isA ? _cardYellow : Colors.white, border: _ink, borderW: 3, radius: 12, hardShadow: true,
              pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 7));
        case _AnnKind.s1Summary:
          _card(c, [
            _Seg(tr('s1sum_1a')),
            _Seg(tr('s1sum_1b'), box: true),
            _Seg('${tr('s1sum_1c')}\n'),
            _Seg(tr('s1sum_2a')),
            _Seg(tr('s1sum_2b'), box: true),
            _Seg('${tr('s1sum_2c')}\n'),
            _Seg(tr('s1sum_3a'), box: true, color: const Color(0xFF1D4ED8)),
            _Seg(tr('s1sum_3b')),
          ], at,
              bg: _cardYellow, border: _ink, borderW: 4, radius: 16, hardShadow: true, maxWidth: 680,
              pad: const EdgeInsets.symmetric(horizontal: 20, vertical: 12));
        case _AnnKind.calcium:
          _calcium(c, at);
        case _AnnKind.scen1Beaker:
          _card(c, [_Seg(tr('lbl_scen1_beaker'), size: 17.5, weight: FontWeight.w800)], at,
              bg: Colors.white, border: slate300, radius: 12);
        case _AnnKind.scen2Tube:
          _card(c, [
            _Seg('${tr('lbl_scen2_tube')}\n', size: 17.5, weight: FontWeight.w800),
            _Seg(tr('lbl_same_change'), size: 14.5, weight: FontWeight.w600, color: const Color(0xFF2563EB)),
          ], at, bg: Colors.white, border: slate300, radius: 12);
        case _AnnKind.arrow:
          _bigArrow(c, at);
        case _AnnKind.s2Summary:
          _card(c, [
            _Seg('${tr('s2sum_1')}\n', size: 23, weight: FontWeight.w900, color: const Color(0xFFDC2626)),
            _Seg(tr('s2sum_2a')),
            _Seg(tr('s2sum_2b'), box: true, weight: FontWeight.w900),
            _Seg(tr('s2sum_2c')),
          ], at,
              bg: _cardYellow, border: _ink, borderW: 4, radius: 16, hardShadow: true, maxWidth: 680,
              pad: const EdgeInsets.symmetric(horizontal: 20, vertical: 12));
      }
      if (fade < 1) c.restore();
    }
  }

  /// Rounded label with rich text; segments marked [_Seg.box] get the
  /// HTML's white outlined highlight boxes.
  Rect _card(
    Canvas c,
    List<_Seg> segs,
    Offset at, {
    Color? bg,
    Color? border,
    double borderW = 2,
    double radius = 10,
    bool hardShadow = false,
    double? maxWidth,
    EdgeInsets pad = const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
  }) {
    final tp = TextPainter(
      text: TextSpan(children: [
        for (final s in segs)
          TextSpan(
            text: s.text,
            style: TextStyle(
              fontSize: s.size,
              fontWeight: s.weight,
              color: s.color,
              fontFamily: LabFont.active.family,
              fontFamilyFallback: LabFont.active.fallback,
              height: 1.32,
            ),
          ),
      ]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    final rect = Rect.fromCenter(center: at, width: tp.width + pad.horizontal, height: tp.height + pad.vertical);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(radius, rect.height / 2)));
    if (hardShadow) {
      c.drawRRect(rr.shift(const Offset(4, 4)), Paint()..color = _ink);
    } else {
      c.drawRRect(rr.shift(const Offset(0, 3)), Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    if (bg != null) c.drawRRect(rr, Paint()..color = bg);
    if (border != null) c.drawRRect(rr.deflate(borderW / 2), _stroke(border, borderW));
    final origin = Offset(rect.left + pad.left, rect.top + pad.top);
    var i = 0;
    for (final s in segs) {
      if (s.box && s.text.isNotEmpty) {
        final sel = TextSelection(baseOffset: i, extentOffset: i + s.text.length);
        final lines = <Rect>[];
        for (final b in tp.getBoxesForSelection(sel)) {
          final r = b.toRect();
          final j = lines.indexWhere((l) => (l.center.dy - r.center.dy).abs() < r.height * 0.5);
          if (j < 0) {
            lines.add(r);
          } else {
            lines[j] = lines[j].expandToInclude(r);
          }
        }
        for (final line in lines) {
          final r = line.shift(origin).inflate(2.5);
          c.drawRect(r.shift(const Offset(1, 1.5)), Paint()..color = Colors.black.withValues(alpha: 0.2));
          c.drawRect(r, Paint()..color = Colors.white);
          c.drawRect(r, Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = _ink);
        }
      }
      i += s.text.length;
    }
    tp.paint(c, origin);
    tp.dispose();
    return rect;
  }

  /// HTML "calcium-particles" magnifier: dotted white precipitate settling.
  void _calcium(Canvas c, Offset at) {
    const r = 58.0;
    c.drawCircle(at + const Offset(0, 6), r, Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: at, radius: r)));
    c.drawCircle(at, r, Paint()..color = const Color(0xFFCBD5E1));
    const sp = 9.0;
    final drift = (scene.time * 5) % sp;
    final dot = Paint()..color = Colors.white;
    for (var y = -r - sp; y <= r + sp; y += sp) {
      for (var x = -r - sp; x <= r + sp; x += sp) {
        c.drawCircle(at + Offset(x, y + drift), 1.9, dot);
        c.drawCircle(at + Offset(x + sp / 2, y + sp / 2 + drift * 0.7), 1.9, dot);
      }
    }
    c.drawRect(
      Rect.fromLTRB(at.dx - r, at.dy + r * 0.62, at.dx + r, at.dy + r),
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
    c.restore();
    c.drawCircle(at, r - 2, _stroke(_ink, 4));
    _card(c, [_Seg(tr('lbl_milky_settling'), size: 11.5, weight: FontWeight.w800)], at + const Offset(0, r * 0.42),
        bg: Colors.white, border: _ink, borderW: 1, radius: 5,
        pad: const EdgeInsets.symmetric(horizontal: 6, vertical: 2));
    _card(c, [_Seg(tr('lbl_calcium_carb'), size: 13, weight: FontWeight.w800)], at + const Offset(0, -r - 1),
        bg: Colors.white, border: _ink, borderW: 1, radius: 999,
        pad: const EdgeInsets.symmetric(horizontal: 9, vertical: 3));
  }

  /// The big yellow "➔" between the two results.
  void _bigArrow(Canvas c, Offset at) {
    const w = 66.0, h = 38.0;
    final path = Path()
      ..moveTo(-w / 2, -h * 0.17)
      ..lineTo(w * 0.08, -h * 0.17)
      ..lineTo(w * 0.08, -h / 2)
      ..lineTo(w / 2, 0)
      ..lineTo(w * 0.08, h / 2)
      ..lineTo(w * 0.08, h * 0.17)
      ..lineTo(-w / 2, h * 0.17)
      ..close();
    final p = path.shift(at);
    c.drawPath(p.shift(const Offset(0, 4)), Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    c.drawPath(p, Paint()..color = _Colors.zslYellow);
    c.drawPath(p, _stroke(labShade(_Colors.zslYellow, -0.35), 2));
  }

  @override
  bool shouldRepaint(covariant _LabPainter old) => true;
}

class _Seg {
  const _Seg(this.text, {this.size = 18, this.weight = FontWeight.w700, this.color = _ink, this.box = false});
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final bool box;
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
