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

/// Class 7 Science • Chapter 2 • Activity 4
/// The Process of Neutralization.
///
/// Native Flutter port of `Cl7S-Ch2-A4-The_Process_of_Neutralization.html`.
/// Scenario 1: a red ant's formic acid sting is neutralized with a baking
/// soda paste (pain meter). Scenario 2: acidic farm soil is tested with a
/// probe and treated with lime so the wilted plant recovers (plant health).
class Ch2A4TheProcessOfNeutralizationPage extends StatefulWidget {
  const Ch2A4TheProcessOfNeutralizationPage({super.key});

  @override
  State<Ch2A4TheProcessOfNeutralizationPage> createState() =>
      _Ch2A4TheProcessOfNeutralizationPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, splash 1311, spark
/// 2365, switchTap 2585, fire 1348, magic 871.
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
  spark('spark.mp3'),
  switchTap('switch.mp3'),
  fire('fire.mp3'),
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

/// A GSAP style tween driven by the scene ticker.
class _Tw {
  _Tw(this.duration, this.curve, this.update, this.onDone, this.delay);
  final double duration;
  final double delay;
  final Curve curve;
  final void Function(double v) update;
  final VoidCallback? onDone;
  double? start;
}

/// Pan recognizer that only joins the gesture arena when the pointer goes
/// down on a draggable object, so canvas panning still works elsewhere.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({required this.canGrab});

  bool Function(Offset local) canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      canGrab(event.localPosition) && super.isPointerAllowed(event);
}

// GSAP eases used by the HTML.
const Curve _power1Out = Curves.easeOutQuad; // GSAP default ease
const Curve _power1In = Curves.easeInQuad;
const Curve _power2In = Curves.easeInCubic;
const Curve _power2InOut = Curves.easeInOutCubic;

class _Ch2A4TheProcessOfNeutralizationPageState
    extends State<Ch2A4TheProcessOfNeutralizationPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _NeuScene _scene = _NeuScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Tw> _tweens = [];
  final math.Random _rnd = math.Random(42);

  late final Ticker _ticker;

  int _gen = 0;
  double? _clock;
  bool _busy = false;
  double _bitePulseStart = 0;
  _V3 _grabOffset = _V3(0, 0, 0);
  double _grabDepth = 0;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];
  int get _stepCount => _data.steps.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _scene.build(0, 0);
    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      _scene.time = t;
      _runTweens(t);
      _updateParticles(t);
      if (_scene.bitePulsing) {
        _scene.biteOpacity = 0.6 + 0.2 * math.cos(math.pi * (t - _bitePulseStart) / 0.3);
      }
      _scene.cam.sync();
      _frame.value = t;
    })..start();
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

  // ------------------------------------------------------------ tweens

  _Tw _add(_Tw tw) {
    if (_clock != null) tw.start = _clock! + tw.delay;
    _tweens.add(tw);
    return tw;
  }

  /// `gsap.to(...)` on a scalar.
  void _to(double from, double to, int ms, void Function(double v) set,
      {Curve curve = _power1Out, int delayMs = 0, VoidCallback? onDone}) {
    _add(_Tw(ms / 1000, curve, (v) => set(from + (to - from) * v), onDone, delayMs / 1000));
  }

  /// `gsap.to(obj.position, ...)`.
  void _move(_V3 p, _V3 target, int ms, {Curve curve = _power1Out, int delayMs = 0, VoidCallback? onDone}) {
    _V3? from;
    _add(_Tw(ms / 1000, curve, (v) {
      from ??= p.copy();
      p.setFrom(from!.lerpTo(target, v));
    }, onDone, delayMs / 1000));
  }

  void _runTweens(double now) {
    final gen = _gen;
    final seen = <_Tw>{};
    for (var pass = 0; pass < 16; pass++) {
      final batch = _tweens.where((t) => !seen.contains(t)).toList();
      if (batch.isEmpty) return;
      for (final tw in batch) {
        if (gen != _gen) return;
        seen.add(tw);
        if (!_tweens.contains(tw)) continue;
        tw.start ??= now + tw.delay;
        if (now < tw.start!) continue;
        final raw = tw.duration <= 0 ? 1.0 : ((now - tw.start!) / tw.duration).clamp(0.0, 1.0);
        tw.update(tw.curve.transform(raw));
        if (raw >= 1) {
          _tweens.remove(tw);
          _clock = tw.start! + tw.duration;
          tw.onDone?.call();
          _clock = null;
        }
      }
    }
  }

  /// HTML `setTimeout`.
  void _later(int ms, VoidCallback fn) {
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      fn();
    });
  }

  void _updateParticles(double t) {
    final list = _scene.particles;
    for (final p in List.of(list)) {
      if (!p.landed && t >= p.t0 + p.dur) {
        p.landed = true;
        p.landedAt = p.t0 + p.dur;
        p.onLand?.call(p);
      }
      if (p.landed && (p.shrinkDelay == null || p.scaleAt(t) <= 0)) list.remove(p);
    }
  }

  /// Adds [n] particles flying from [from] to random points from [target].
  void _burst(
    int n, {
    required _V3 Function(int i) from,
    required _V3 Function(int i) to,
    required double Function() dur,
    required double stagger,
    required Color color,
    required double r,
    Curve curve = _power1Out,
    bool cube = false,
    void Function(_Particle p)? onLand,
    double? shrinkDelay,
  }) {
    final now = _scene.time;
    for (var i = 0; i < n; i++) {
      _scene.particles.add(_Particle(
        from: from(i),
        to: to(i),
        t0: now + i * stagger,
        dur: dur(),
        color: color,
        r: r,
        curve: curve,
        cube: cube,
        onLand: onLand,
        shrinkDelay: shrinkDelay,
      ));
    }
  }

  double _rand() => _rnd.nextDouble();

  // ------------------------------------------------------------- setup

  /// HTML `loadScenario(id)`.
  void _load(int index) {
    _gen++;
    _tweens.clear();
    _lab.cancelPending();
    setState(() {
      _busy = false;
      _scene.build(index, _scene.time);
    });
  }

  void _changeScenario(int index) {
    _lab.hidePopup(sound: false);
    _load(index);
  }

  void _onEnter() => _scene.builtAt = _scene.time;

  void _advanceStep() {
    if (!mounted) return;
    setState(() => _scene.step++);
  }

  void _returnToStart(_Obj o) {
    _move(_scene.posOf(o), _scene.startOf(o).copy(), 300);
  }

  // ------------------------------------------------------- hit testing

  bool get _canInteract => _lab.isLabActive && !_busy && _scene.dragging == null;

  Rect _bounds(double x0, double x1, double y0, double y1, double z0, double z1) {
    final cam = _scene.cam;
    var l = double.infinity, t = double.infinity, r = -double.infinity, b = -double.infinity;
    for (final x in [x0, x1]) {
      for (final y in [y0, y1]) {
        for (final z in [z0, z1]) {
          final p = cam.p(x, y, z);
          l = math.min(l, p.dx);
          r = math.max(r, p.dx);
          t = math.min(t, p.dy);
          b = math.max(b, p.dy);
        }
      }
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  Rect _hitRect(_Obj o) {
    final s = _scene;
    final cam = s.cam;
    final p = s.posOf(o);
    switch (o) {
      case _Obj.ant:
        return Rect.fromCircle(center: cam.pv(p), radius: math.max(26, 0.55 * cam.kv(p)));
      case _Obj.soda:
        return _bounds(p.x - 0.6, p.x + 0.6, p.y - 0.1, p.y + 0.1, p.z - 0.75, p.z + 0.75).inflate(10);
      case _Obj.lemon:
        return Rect.fromCircle(center: cam.pv(p), radius: 0.5 * cam.kv(p) + 6);
      case _Obj.beaker:
        return _bounds(p.x - 0.6, p.x + 0.5, p.y, p.y + 1.35, p.z - 0.5, p.z + 0.5).inflate(6);
      case _Obj.probe:
        return _bounds(p.x - 0.45, p.x + 0.45, p.y - 1.5, p.y + 1.25, p.z - 0.2, p.z + 0.2).inflate(6);
      case _Obj.limeBag:
      case _Obj.acidBag:
        return _bounds(p.x - 0.75, p.x + 0.75, p.y - 1, p.y + 1, p.z - 0.3, p.z + 0.3).inflate(4);
      case _Obj.can:
        return _bounds(p.x - 1.9, p.x + 1.05, p.y, p.y + 1.8, p.z - 0.6, p.z + 0.6).inflate(4);
    }
  }

  /// Nearest interactive object under [at] (the HTML raycaster).
  _Obj? _hitTest(Offset at) {
    final s = _scene;
    _Obj? best;
    var bestDepth = double.infinity;
    for (final o in {...s.draggable, ...s.clickable}) {
      if (o == _Obj.limeBag && !s.limeVisible) continue;
      if (o == _Obj.ant && !s.antVisible) continue;
      if (!_hitRect(o).contains(at)) continue;
      final p = s.posOf(o);
      final d = s.cam.depthOf(p.x, p.y, p.z);
      if (d < bestDepth) {
        bestDepth = d;
        best = o;
      }
    }
    return best;
  }

  bool _canGrabAt(Offset local) {
    if (!_canInteract) return false;
    final hit = _hitTest(local);
    return hit != null && _scene.draggable.contains(hit);
  }

  // ------------------------------------------------------ interaction

  void _onTapUp(TapUpDetails d) {
    if (!_canInteract) return;
    final hit = _hitTest(d.localPosition);
    if (hit == null) return;
    if (_scene.draggable.contains(hit)) {
      // HTML: pointerdown on a draggable starts a drag, pointerup drops it.
      _grab(hit, d.localPosition);
      _release();
    } else if (_scene.clickable.contains(hit)) {
      _Audio.play(_Sound.click);
      _validateClick(hit);
    }
  }

  void _onPanStart(DragStartDetails d) {
    if (!_canInteract) return;
    final hit = _hitTest(d.localPosition);
    if (hit == null || !_scene.draggable.contains(hit)) return;
    _grab(hit, d.localPosition);
  }

  void _grab(_Obj o, Offset at) {
    _Audio.play(_Sound.pickup);
    final p = _scene.posOf(o);
    _grabDepth = _scene.cam.depthOf(p.x, p.y, p.z);
    _grabOffset = p - _scene.cam.unproject(at, _grabDepth);
    setState(() => _scene.dragging = o);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final o = _scene.dragging;
    if (o == null) return;
    final n = _scene.cam.unproject(d.localPosition, _grabDepth) + _grabOffset;
    if (n.y < 0) n.y = 0;
    _scene.posOf(o).setFrom(n);
  }

  void _release() {
    final o = _scene.dragging;
    if (o == null) return;
    _Audio.play(_Sound.drop);
    setState(() => _scene.dragging = null);
    _validateDrop(o);
  }

  /// HTML `validateDrop(obj)`.
  void _validateDrop(_Obj o) {
    final s = _scene;
    final p = s.posOf(o);
    if (s.step >= _stepCount) return _returnToStart(o);
    if (s.isAnt) {
      if (s.step == 0 && o == _Obj.ant && p.distanceTo(s.hand) < 5) {
        s.draggable.remove(_Obj.ant);
        final b = s.bite;
        _busy = true;
        _move(p, _V3(b.x, b.y + 0.1, b.z), 300, onDone: _triggerAntBite);
        return;
      }
      if (s.step == 2 && o == _Obj.soda && p.distanceTo(s.beakerStart) < 4) return _pourSoda();
      if (s.step == 3 && o == _Obj.beaker && p.distanceTo(s.hand) < 5) return _applyPaste();
    } else {
      if (s.step == 0 && o == _Obj.probe && p.distanceTo(s.soil) < 8) return _insertProbe();
      if (s.step == 1) {
        if (o == _Obj.acidBag && p.distanceTo(s.soil) < 8) {
          _lab.showToast(_t('notifFert'), isError: true);
          for (var i = 0; i < 6; i++) {
            _to(s.leafRot[i], 1.5, 500, (v) => s.leafRot[i] = v);
          }
          _setProbe('probeMoreAcid', const Color(0xFFB91C1C), true);
        } else if (o == _Obj.limeBag && p.distanceTo(s.soil) < 8) {
          _move(p, _V3(s.soil.x + 0.5, s.soil.y + 3.0, s.soil.z), 400);
          s.draggable.remove(_Obj.limeBag);
          s.clickable.add(_Obj.limeBag);
          _advanceStep();
          return;
        }
      }
    }
    _returnToStart(o);
  }

  /// HTML `validateClick(obj)`.
  void _validateClick(_Obj o) {
    final s = _scene;
    if (s.step >= _stepCount) return;
    if (s.isAnt && s.step == 1) {
      if (o == _Obj.soda) {
        _lab.showToast(_t('notifSoda'));
        s.clickable.clear(); // lemon is no longer interactive
        s.draggable.add(_Obj.soda);
        _advanceStep();
      } else if (o == _Obj.lemon) {
        _lab.showToast(_t('notifLemon'), isError: true);
        // Bite patch scale 1 -> 1.5, yoyo, repeat 3 (0.2 s each way).
        _add(_Tw(0.8, Curves.linear, (v) {
          final seg = (v * 4).floor().clamp(0, 3);
          final u = v * 4 - seg;
          final e = _power1Out.transform(seg.isEven ? u : 1 - u);
          s.biteScale = 1 + 0.5 * e;
        }, () => s.biteScale = 1, 0));
      }
    } else if (!s.isAnt && s.step == 2 && o == _Obj.limeBag) {
      _spreadLime();
    } else if (!s.isAnt && s.step == 3 && o == _Obj.can) {
      _waterPlant();
    }
  }

  // ------------------------------------------------- scenario 1 events

  /// HTML `triggerAntBite`.
  void _triggerAntBite() {
    final s = _scene;
    _Audio.play(_Sound.spark);
    s.markerOn = false;
    _to(0, math.pi / 4, 200, (v) => s.eyeRot = v);
    _to(1, 1.5, 200, (v) => s.mouthSx = v);
    _to(1, 2, 200, (v) => s.mouthSy = v);
    final b = s.bite;
    _burst(15,
        from: (_) => _V3(b.x + (_rand() - 0.5) * 0.3, b.y + 0.3, b.z + (_rand() - 0.5) * 0.3),
        to: (_) => _V3(b.x + (_rand() - 0.5) * 0.3, b.y - 0.1, b.z + (_rand() - 0.5) * 0.3),
        dur: () => 0.5,
        stagger: 0.05,
        color: const Color(0xFFFF0000),
        r: 0.06);
    s.biteOpacity = 0.8;
    s.bitePulsing = true;
    _bitePulseStart = s.time;
    _to(s.meterMask, 0.1, 1000, (v) => s.meterMask = v);
    s.painFace = true;
    _move(s.ant, _V3(8, s.ant.y, -5), 2000, delayMs: 500, onDone: () {
      s.antVisible = false;
      s.antLabelOn = false;
    });
    s.clickable.addAll([_Obj.soda, _Obj.lemon]);
    _busy = false;
    _lab.showToast(_t('notifFormic'), isError: true);
    _advanceStep();
  }

  /// Soda pours into the beaker, the paste is stirred (HTML drag_soda_to_beaker).
  void _pourSoda() {
    final s = _scene;
    _busy = true;
    final bk = s.beakerStart;
    _move(s.soda, _V3(bk.x + 1.0, bk.y + 1.5, bk.z), 400, onDone: () {
      _to(0, math.pi / 4, 300, (v) => s.sodaRot = v, onDone: () {
        _Audio.play(_Sound.splash);
        final mouth = _rotZ(_V3(s.soda.x - 0.6, s.soda.y, s.soda.z), s.soda, s.sodaRot);
        _burst(30,
            from: (_) => mouth.copy(),
            to: (_) => _V3(bk.x + (_rand() - 0.5) * 0.3, bk.y + 0.5, bk.z + (_rand() - 0.5) * 0.3),
            dur: () => 0.4 + _rand() * 0.2,
            stagger: 0.05,
            color: Colors.white,
            r: 0.06,
            cube: true,
            curve: _power2In);
        _later(1000, () {
          s.waterColor = const Color(0xFF88CCFF);
          _to(1, 1.2, 500, (v) => s.waterScale = v);
          _to(0, math.pi * 8, 2000, (v) => s.stirAngle = v, curve: _power2InOut);
          _later(2000, () {
            _to(s.sodaRot, 0, 300, (v) => s.sodaRot = v);
            _move(s.soda, s.sodaStart.copy(), 500);
            _later(500, () {
              s.draggable.add(_Obj.beaker);
              setState(() => _busy = false);
              _advanceStep();
            });
          });
        });
      });
    });
  }

  /// HTML `applyPasteAndNeutralize`.
  void _applyPaste() {
    final s = _scene;
    _busy = true;
    final b = s.bite;
    _move(s.beaker, _V3(b.x + 1.0, b.y + 1.5, b.z), 400);
    _to(0, math.pi / 3, 400, (v) => s.beakerRot = v, delayMs: 400, onDone: () {
      _Audio.play(_Sound.splash);
      _to(s.waterScale, 0.2, 1500, (v) => s.waterScale = v);
      final spout = _rotZ(_V3(s.beaker.x - 0.55, s.beaker.y + 1.25, s.beaker.z), s.beaker, s.beakerRot);
      _burst(30,
          from: (_) => spout.copy(),
          to: (_) => _V3(b.x + (_rand() - 0.5) * 0.4, b.y + 0.1, b.z + (_rand() - 0.5) * 0.4),
          dur: () => 0.4 + _rand() * 0.2,
          stagger: 0.05,
          color: const Color(0xFF88CCFF),
          r: 0.06,
          curve: _power1In);
      _later(1500, () {
        _to(s.beakerRot, 0, 300, (v) => s.beakerRot = v);
        _move(s.beaker, s.beakerStart.copy(), 500);
        _to(s.eyeRot, 0, 500, (v) => s.eyeRot = v);
        _to(s.mouthSx, 1.5, 500, (v) => s.mouthSx = v);
        _to(s.mouthSy, 0.5, 500, (v) => s.mouthSy = v);
        s.relieved = true;
        s.bitePulsing = false;
        _to(s.biteOpacity, 0, 1500, (v) => s.biteOpacity = v);
        _Audio.play(_Sound.fire);
        _to(s.meterMask, 1, 1500, (v) => s.meterMask = v);
        s.painFace = false;
        _lab.showToast(_t('notifNeut'));
        setState(() => _busy = false);
        _advanceStep();
        _finish();
      });
    });
  }

  // ------------------------------------------------- scenario 2 events

  void _setProbe(String key, Color color, bool arrow) {
    _scene
      ..probeKey = key
      ..probeColor = color
      ..probeArrow = arrow;
  }

  /// Moves the virtual camera towards the HTML probe close-up ([f] = 0 is
  /// the default view; the full HTML close-up hides the bags, so 0.45).
  void _cameraTo(double f) {
    final cam = _scene.cam;
    final eye = _V3(0, 8, 15).lerpTo(_V3(-1, 2.5, 6), f);
    final target = _V3(0, 0, 0).lerpTo(_V3(-1, 1.5, 2.5), f);
    _move(cam.eye, eye, 1000);
    _move(cam.target, target, 1000);
  }

  /// HTML drag_probe: the probe goes into the soil and reads ACIDIC.
  void _insertProbe() {
    final s = _scene;
    s.draggable.remove(_Obj.probe);
    _busy = true;
    _move(s.probe, _V3(s.soil.x + 1.5, s.soil.y + 1.5, s.soil.z + 1), 400);
    _to(0, math.pi / 6, 400, (v) => s.probeRot = v, onDone: () {
      _setProbe('probeAcid', const Color(0xFFEF4444), true);
      _Audio.play(_Sound.switchTap);
      _cameraTo(0.45);
      setState(() => _busy = false);
      _advanceStep();
    });
  }

  /// HTML click_spread_lime: lime powder neutralises the acid particles.
  void _spreadLime() {
    final s = _scene;
    _busy = true;
    _cameraTo(0);
    final soil = s.soil;
    _move(s.limeBag, _V3(s.limeBag.x, s.limeBag.y + 2, s.limeBag.z), 500);
    _to(0, -math.pi / 3, 500, (v) => s.limeRot = v, onDone: () {
      _Audio.play(_Sound.splash);
      _later(500, () => _Audio.play(_Sound.fire));
      final bag = s.limeBag;
      _burst(40,
          from: (_) => _V3(bag.x - 0.5, bag.y - 0.5, bag.z),
          to: (_) => _V3(soil.x - 2.5 + _rand() * 5, soil.y + 0.6, soil.z - 2.5 + _rand() * 5),
          dur: () => 0.5 + _rand() * 0.3,
          stagger: 0.02,
          color: Colors.white,
          r: 0.12,
          curve: _power1In,
          shrinkDelay: 0.5,
          onLand: (p) {
            // A red "acid" particle appears; the lime turns blue and sinks into it.
            s.particles.add(_Particle(
              from: p.to.copy(),
              to: p.to.copy(),
              t0: p.landedAt,
              dur: 0,
              color: const Color(0xFFDC2626),
              r: 0.15,
              shrinkDelay: 0.5,
            )..landed = true..landedAt = p.landedAt);
            p.color = const Color(0xFF3B82F6);
            p.moveTo = p.to.copy();
          });
      _to(0, 1, 3000, (v) => s.soilT = v, delayMs: 500);
      _later(3500, () {
        s.limeVisible = false;
        s.clickable
          ..remove(_Obj.limeBag)
          ..add(_Obj.can);
        setState(() => _busy = false);
        _advanceStep();
      });
    });
  }

  /// HTML click_water: the plant recovers and blooms.
  void _waterPlant() {
    final s = _scene;
    _busy = true;
    s.clickable.remove(_Obj.can);
    final soil = s.soil;
    _move(s.can, _V3(soil.x + 1.5, soil.y + 3.5, soil.z), 500);
    _to(0, math.pi / 4, 500, (v) => s.canRot = v, onDone: () {
      _Audio.play(_Sound.splash);
      _later(1000, () => _Audio.play(_Sound.magic));
      final tip = _rotZ(_V3(s.can.x - 1.6, s.can.y + 1.1, s.can.z), s.can, s.canRot);
      _burst(30,
          from: (_) => tip.copy(),
          to: (_) => _V3(soil.x - 2 + _rand() * 4, soil.y + 0.3, soil.z - 2 + _rand() * 4),
          dur: () => 0.4 + _rand() * 0.2,
          stagger: 0.05,
          color: const Color(0xFF88CCFF),
          r: 0.08,
          curve: _power1In);
      _to(s.stemRot, 0, 2000, (v) => s.stemRot = v, delayMs: 500);
      for (var i = 0; i < 6; i++) {
        _to(s.leafRot[i], 0.1, 2000, (v) => s.leafRot[i] = v, delayMs: 500 + i * 100);
      }
      _to(0, 1, 2000, (v) => s.plantT = v, delayMs: 500);
      _to(0, 1.5, 2000, (v) => s.flowerScale = v, delayMs: 2000, curve: const ElasticOutCurve(0.4));
      _to(s.meterMask, 0, 2000, (v) => s.meterMask = v, delayMs: 500);
      _later(4000, () {
        _to(s.canRot, 0, 500, (v) => s.canRot = v);
        _move(s.can, s.canStart.copy(), 500);
        _setProbe('probeNeut', const Color(0xFF22C55E), false);
        _lab.showToast(_t('notifSoil'));
        setState(() => _busy = false);
        _advanceStep();
        _finish();
      });
    });
  }

  // -------------------------------------------------------- conclusion

  /// HTML `showObservation` 2 s after the last step: opens the sidebar and
  /// the "Observation & Outcome" popup.
  void _finish() {
    final scenario = _scene.scenario;
    _lab.completedScenarios.add(scenario);
    final allDone = _lab.completedScenarios.length >= _scenarios['en']!.length;
    _later(2000, () {
      _lab.openSidebar();
      _lab.showPopup(() => LabPopupContent(
            title: _t('obsTitle'),
            icon: Icons.info,
            accent: _Colors.blue,
            extra: _conclusion(scenario),
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

  Widget _conclusion(int scenario) {
    return Builder(builder: (context) {
      final s = context.labScale;
      final f = s * _lab.fontScale.clamp(0.9, 1.4);
      final p = _Theme.of(_lab.isDark);
      final body = TextStyle(color: p.text, fontSize: 13 * f, fontWeight: FontWeight.w500, height: 1.55);
      final bold = TextStyle(color: p.textStrong, fontWeight: FontWeight.w800);
      final eq = TextStyle(
        color: p.textStrong,
        fontSize: 16 * f,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5,
      );
      final n = scenario + 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(text: _t('conc${n}_lead'), style: bold),
              TextSpan(text: _t('conc${n}_a')),
            ]),
            style: body,
          ),
          if (scenario == 0) ...[
            SizedBox(height: 12 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
              decoration: BoxDecoration(
                color: _Colors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _Colors.blue.withValues(alpha: 0.4)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_t('conc1_eq_l'), style: eq),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s),
                      child: Icon(Icons.arrow_right_alt, size: 24 * f, color: _Colors.blue),
                    ),
                    Text(_t('conc1_eq_r'), style: eq),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * s),
            Text(_t('conc1_b'), style: body),
          ],
        ],
      );
    });
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final p = _Theme.of(_lab.isDark);
        final data = _data;
        final done = _scene.step >= _stepCount;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step + 1,
          instruction: done ? _t('taskCompleted') : null,
          onEnterLab: _onEnter,
          onReset: () => _load(0),
          overlays: [if (_lab.isLabActive) _meterOverlay(s, p)],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
                _GrabPanRecognizer: GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                  () => _GrabPanRecognizer(canGrab: _canGrabAt),
                  (r) => r
                    ..canGrab = _canGrabAt
                    // Only joins on draggables, so it can claim short drags.
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 5)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..onStart = _onPanStart
                    ..onUpdate = _onPanUpdate
                    ..onEnd = ((_) => _release())
                    ..onCancel = _release,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _NeuPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  text: {
                    for (final k in const [
                      'lblAnt',
                      'lblSoda',
                      'lblLemon',
                      'lblSoil',
                      'lblPlant',
                      'lblBench',
                      'lblProbe',
                      'lblWater',
                      'lblLime',
                      'lblAcid',
                      'probeAcid',
                      'probeMoreAcid',
                      'probeNeut',
                      'ml',
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

  /// HTML `#ui-pain-meter`: the Pain Meter (scenario 1) or the Plant
  /// Health meter (scenario 2), right of the scene.
  Widget _meterOverlay(double s, LabPalette p) {
    final pad = MediaQuery.paddingOf(context);
    // Clear of the shell's tool column (42 px wide at its own scale).
    final toolW = 42 * s.clamp(0.85, 1.25);
    return Positioned(
      right: pad.right + 16 + toolW,
      top: 8 + pad.top,
      bottom: 8 + pad.bottom,
      child: IgnorePointer(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedBuilder(animation: _frame, builder: (context, _) => _meter(s, p)),
          ),
        ),
      ),
    );
  }

  Widget _meter(double s, LabPalette p) {
    final sc = _scene;
    final pain = sc.isAnt;
    final barH = 150 * s, barW = 16 * s;
    final caption = TextStyle(
      color: p.textMuted,
      fontSize: 8.5 * s,
      fontWeight: FontWeight.w800,
      // Letter spacing breaks Devanagari clusters apart.
      letterSpacing: _lab.lang == LabLang.en ? 1.3 : 0,
      height: 1.2,
    );
    final bar = Container(
      width: barW,
      height: barH,
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate800 : _Colors.slate200,
        borderRadius: BorderRadius.circular(barW),
        border: Border.all(color: p.isDark ? _Colors.slate600 : _Colors.slate400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(barW),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: pain
                      ? const [Color(0xE622C55E), Color(0xE6FACC15), Color(0xE6EF4444)]
                      : const [Color(0xE6EF4444), Color(0xE6FACC15), Color(0xE622C55E)],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: barH * sc.meterMask.clamp(0.0, 1.0),
                color: p.isDark ? _Colors.slate900 : _Colors.slate300,
              ),
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 76 * s),
            child: Text(
              (pain ? _t('painMeter') : _t('plantHealth')).toUpperCase(),
              textAlign: TextAlign.center,
              style: caption,
            ),
          ),
          SizedBox(height: 8 * s),
          if (!pain) ...[
            Text(_t('exc').toUpperCase(),
                style: caption.copyWith(color: p.isDark ? const Color(0xFF4ADE80) : _Colors.green600)),
            SizedBox(height: 5 * s),
          ],
          bar,
          if (pain) ...[
            SizedBox(height: 8 * s),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Icon(
                sc.painFace ? Icons.sentiment_very_dissatisfied : Icons.sentiment_satisfied_alt,
                key: ValueKey(sc.painFace),
                size: 28 * s,
                color: sc.painFace ? const Color(0xFFF87171) : const Color(0xFF4ADE80),
              ),
            ),
          ] else ...[
            SizedBox(height: 5 * s),
            Text(_t('poor').toUpperCase(),
                style: caption.copyWith(color: p.isDark ? const Color(0xFFF87171) : _Colors.red600)),
          ],
        ],
      ),
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'The Process of Neutralization',
    'app_subtitle': 'Class 7 • Acids, Bases and Salts',
    'scen_1': 'Scenario 1: First Aid for an Ant Bite',
    'scen_2': "Scenario 2: Saving the Farmer's Crops",
    'taskCompleted': 'Task Completed! Check Observations.',
    'painMeter': 'Pain\nMeter',
    'plantHealth': 'Plant Health',
    'poor': 'Poor',
    'exc': 'Excellent',
    'obsTitle': 'Observation & Outcome',
    'conc1_lead': 'Conclusion:',
    'conc1_a':
        ' The acidic formic acid from the ant sting was effectively neutralized by the basic baking soda paste.',
    'conc1_eq_l': 'Acid + Base',
    'conc1_eq_r': 'Salt + Water',
    'conc1_b':
        'This reaction nullified the acidic properties, relieving the burning sensation and reducing inflammation.',
    'conc2_lead': 'Analysis:',
    'conc2_a':
        ' The soil was initially too acidic. Adding Lime (a basic substance) initiated a neutralization reaction. This balanced the pH level closer to neutral, directly restoring the plants to a healthy, vibrant state.',
    'lblAnt': 'Red Ant (Acid)',
    'lblSoda': 'Baking Soda',
    'lblLemon': 'Lemon',
    'lblSoil': 'Farm Soil',
    'lblPlant': 'Wilted Plant',
    'lblBench': 'Tool Bench',
    'lblProbe': 'Soil Probe',
    'lblWater': 'Water',
    'lblLime': 'LIME\n(Base)',
    'lblAcid': 'ACIDIC\nFERTILIZER',
    'notifSoda': 'Correct! Baking Soda is a base.',
    'notifLemon': 'Try Again! Lemon is an acid.',
    'notifFormic': 'Formic Acid Injected!',
    'notifNeut': 'Neutralized successfully!',
    'notifFert': 'Wrong! Fertilizer makes it MORE acidic.',
    'notifSoil': 'Soil Neutralized!',
    'probeAcid': 'ACIDIC',
    'probeMoreAcid': 'MORE ACIDIC!',
    'probeNeut': 'NEUTRAL',
    'ml': 'ml',
  },
  'hi': {
    'app_title': 'उदासीनीकरण की प्रक्रिया',
    'app_subtitle': 'कक्षा 7 • अम्ल, क्षारक और लवण',
    'scen_1': 'परिदृश्य 1: चींटी के काटने पर प्राथमिक चिकित्सा',
    'scen_2': 'परिदृश्य 2: किसान की फसलों को बचाना',
    'taskCompleted': 'कार्य पूर्ण! अवलोकन जांचें।',
    'painMeter': 'दर्द\nमीटर',
    'plantHealth': 'पौधे का स्वास्थ्य',
    'poor': 'खराब',
    'exc': 'उत्कृष्ट',
    'obsTitle': 'अवलोकन और परिणाम',
    'conc1_lead': 'निष्कर्ष:',
    'conc1_a':
        ' चींटी के डंक से अम्लीय फॉर्मिक एसिड को क्षारीय बेकिंग सोडा पेस्ट द्वारा प्रभावी ढंग से बेअसर कर दिया गया था।',
    'conc1_eq_l': 'अम्ल + क्षारक',
    'conc1_eq_r': 'लवण + जल',
    'conc1_b': 'इस प्रतिक्रिया ने अम्लीय गुणों को शून्य कर दिया, जलन से राहत दी और सूजन को कम किया।',
    'conc2_lead': 'विश्लेषण:',
    'conc2_a':
        ' मिट्टी शुरू में बहुत अम्लीय थी। चूना (एक क्षारीय पदार्थ) जोड़ने से एक उदासीनीकरण प्रतिक्रिया शुरू हुई। इसने पीएच स्तर को तटस्थ के करीब संतुलित किया, जिससे पौधे सीधे एक स्वस्थ, जीवंत स्थिति में बहाल हो गए।',
    'lblAnt': 'लाल चींटी (अम्ल)',
    'lblSoda': 'बेकिंग सोडा',
    'lblLemon': 'नींबू',
    'lblSoil': 'खेत की मिट्टी',
    'lblPlant': 'मुरझाया हुआ पौधा',
    'lblBench': 'टूल बेंच',
    'lblProbe': 'मृदा प्रोब',
    'lblWater': 'पानी',
    'lblLime': 'चूना\n(क्षारक)',
    'lblAcid': 'अम्लीय\nउर्वरक',
    'notifSoda': 'सही! बेकिंग सोडा एक क्षारक है।',
    'notifLemon': 'पुनः प्रयास करें! नींबू एक अम्ल है।',
    'notifFormic': 'फॉर्मिक एसिड इंजेक्ट किया गया!',
    'notifNeut': 'सफलतापूर्वक बेअसर किया गया!',
    'notifFert': 'गलत! उर्वरक इसे और अधिक अम्लीय बनाता है।',
    'notifSoil': 'मिट्टी बेअसर हुई!',
    'probeAcid': 'अम्लीय',
    'probeMoreAcid': 'अधिक अम्लीय!',
    'probeNeut': 'तटस्थ',
    'ml': 'मिली',
  },
};

// ========================================================== SCENARIOS
// `action` is the HTML step `hud` text; `observation` is the step's
// teacher-board text (HTML tags removed).

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To use a basic substance to neutralize the acidic effect of a red ant bite and relieve the pain.',
      steps: [
        LabStep(
          concept: 'Ant Bite (Formic Acid)',
          action: 'Drag the ant to the hand.',
          observation:
              'Observation: A red ant stings the hand, injecting formic acid into the skin. The affected area becomes red, swollen, and painful.',
        ),
        LabStep(
          concept: 'Choosing a Base',
          action: 'Click the correct base.',
          observation:
              'Action: Baking soda (Sodium Bicarbonate), a mild base, is selected as the appropriate neutralizing agent to counteract the acidic sting.',
        ),
        LabStep(
          concept: 'Making a Basic Paste',
          action: 'Drag Baking Soda to the beaker.',
          observation:
              'Action: The baking soda is mixed with water to create a basic paste. This facilitates the chemical reaction when applied.',
        ),
        LabStep(
          concept: 'Neutralization',
          action: 'Drag the Paste to the Ant Bite.',
          observation:
              'Observation: The basic paste is applied to the sting. The acid and base neutralize each other, providing immediate relief from the burning sensation.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To test the farm soil, identify its acidic nature, and treat it with a base to help the plants grow well.',
      steps: [
        LabStep(
          concept: 'Testing the Soil',
          action: 'Drag the Soil Test Probe to the soil.',
          observation:
              "Task Instructions: A plant in a patch of soil looks wilted and unhealthy. DRAG the Soil Test Probe and DROP it into the soil next to the plant.\n\nExpected Outcome: The probe is inserted into the soil, and its digital screen flashes 'ACIDIC' in red letters.",
        ),
        LabStep(
          concept: 'Choosing the Base',
          action: 'Drag the correct bag to the soil.',
          observation:
              "Task Instructions: On the tool bench, you have a bag of Lime (a base) and a bag of Acidic Fertilizer. DRAG the correct bag and DROP it onto the soil to help the plant.\n\nExpected Outcome: The user correctly selects and drags the appropriate neutralizing bag. If the wrong bag is chosen, the plant wilts even more, and the probe's screen flashes 'MORE ACIDIC!'.",
        ),
        LabStep(
          concept: 'Spreading Lime',
          action: 'Click the correct bag to spread its contents.',
          observation:
              "Task Instructions: CLICK on the correct bag you placed to spread it evenly over the soil.\n\nExpected Outcome: The powder is spread over the soil, and the soil's color changes. Blue 'base' particles sink into the soil and neutralize the red 'acid' particles. The soil's color slowly shifts from reddish-brown to a healthy, dark brown.",
        ),
        LabStep(
          concept: 'Watering the Plant',
          action: 'Click the Watering Can.',
          observation:
              "Task Instructions: Now that the soil is neutralized, CLICK the watering can to water the plant and see the result.\n\nExpected Outcome: The plant becomes healthy, green, and vibrant. A time-lapse animation plays: the wilted plant straightens up, its leaves turn a vibrant green, and a flower blooms on top. The 'Plant Health' meter animates from red (poor) to green (excellent).",
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'लाल चींटी के काटने के अम्लीय प्रभाव को बेअसर करने और दर्द से राहत देने के लिए क्षारीय पदार्थ का उपयोग करना।',
      steps: [
        LabStep(
          concept: 'चींटी का डंक (फॉर्मिक अम्ल)',
          action: 'चींटी को हाथ पर खींचें।',
          observation:
              'अवलोकन: एक लाल चींटी हाथ पर डंक मारती है, त्वचा में फॉर्मिक एसिड इंजेक्ट करती है। प्रभावित क्षेत्र लाल, सूजा हुआ और दर्दनाक हो जाता है।',
        ),
        LabStep(
          concept: 'क्षारक का चयन',
          action: 'सही क्षारक पर क्लिक करें।',
          observation:
              'कार्रवाई: बेकिंग सोडा (सोडियम बाइकार्बोनेट), एक हल्का क्षारक, अम्लीय डंक का मुकाबला करने के लिए उपयुक्त बेअसर करने वाले एजेंट के रूप में चुना जाता है।',
        ),
        LabStep(
          concept: 'क्षारीय पेस्ट बनाना',
          action: 'बेकिंग सोडा को बीकर में खींचें।',
          observation:
              'कार्रवाई: एक क्षारीय पेस्ट बनाने के लिए बेकिंग सोडा को पानी में मिलाया जाता है। यह लागू होने पर रासायनिक प्रतिक्रिया को सुविधाजनक बनाता है।',
        ),
        LabStep(
          concept: 'उदासीनीकरण',
          action: 'पेस्ट को चींटी के काटने वाली जगह पर खींचें।',
          observation:
              'अवलोकन: क्षारीय पेस्ट डंक पर लगाया जाता है। अम्ल और क्षारक एक-दूसरे को बेअसर करते हैं, जिससे जलन से तुरंत राहत मिलती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'खेत की मिट्टी का परीक्षण करना, इसकी अम्लीय प्रकृति की पहचान करना, और पौधों को अच्छी तरह से बढ़ने में मदद करने के लिए इसे क्षारक के साथ उपचारित करना।',
      steps: [
        LabStep(
          concept: 'मिट्टी का परीक्षण',
          action: 'मृदा परीक्षण प्रोब को मिट्टी में खींचें।',
          observation:
              "कार्य निर्देश: मिट्टी के एक हिस्से में एक पौधा मुरझाया हुआ और अस्वस्थ दिखता है। मृदा परीक्षण प्रोब को खींचें और इसे पौधे के बगल की मिट्टी में छोड़ दें।\n\nअपेक्षित परिणाम: प्रोब मिट्टी में डाला जाता है, और इसकी डिजिटल स्क्रीन लाल अक्षरों में 'अम्लीय' (ACIDIC) चमकती है।",
        ),
        LabStep(
          concept: 'क्षारक का चयन',
          action: 'सही बैग को मिट्टी में खींचें।',
          observation:
              "कार्य निर्देश: टूल बेंच पर, आपके पास चूने (एक क्षारक) का एक बैग और अम्लीय उर्वरक का एक बैग है। पौधे की मदद करने के लिए सही बैग को खींचें और उसे मिट्टी पर छोड़ दें।\n\nअपेक्षित परिणाम: उपयोगकर्ता सही ढंग से उपयुक्त बेअसर करने वाले बैग का चयन करता है और खींचता है। यदि गलत बैग चुना जाता है, तो पौधा और भी अधिक मुरझा जाता है, और प्रोब की स्क्रीन 'अधिक अम्लीय!' (MORE ACIDIC!) चमकती है।",
        ),
        LabStep(
          concept: 'चूना फैलाना',
          action: 'सामग्री फैलाने के लिए सही बैग पर क्लिक करें।',
          observation:
              "कार्य निर्देश: इसे मिट्टी पर समान रूप से फैलाने के लिए आपके द्वारा रखे गए सही बैग पर क्लिक करें।\n\nअपेक्षित परिणाम: पाउडर मिट्टी पर फैल जाता है, और मिट्टी का रंग बदल जाता है। नीले 'क्षारक' कण मिट्टी में डूब जाते हैं और लाल 'अम्ल' कणों को बेअसर कर देते हैं। मिट्टी का रंग धीरे-धीरे लाल-भूरे से स्वस्थ, गहरे भूरे रंग में बदल जाता है।",
        ),
        LabStep(
          concept: 'पौधे को पानी देना',
          action: 'पानी देने वाले डिब्बे पर क्लिक करें।',
          observation:
              "कार्य निर्देश: अब जब मिट्टी बेअसर हो गई है, तो पौधे को पानी देने और परिणाम देखने के लिए पानी देने वाले डिब्बे (watering can) पर क्लिक करें।\n\nअपेक्षित परिणाम: पौधा स्वस्थ, हरा और जीवंत हो जाता है। एक टाइम-लैप्स एनीमेशन चलता है: मुरझाया हुआ पौधा सीधा हो जाता है, उसके पत्ते जीवंत हरे हो जाते हैं, और शीर्ष पर एक फूल खिलता है। 'पौधे का स्वास्थ्य' मीटर लाल (खराब) से हरे (उत्कृष्ट) में चेतन होता है।",
        ),
      ],
    ),
  ],
};

// ================================================ SCENARIO 2: FARM

Rect _ellipseXZ(_Cam cam, double x, double y, double z, double rx, double rz) {
  final l = cam.p(x - rx, y, z), r = cam.p(x + rx, y, z);
  final f = cam.p(x, y, z + rz), b = cam.p(x, y, z - rz);
  return Rect.fromLTRB(l.dx, b.dy, r.dx, f.dy);
}

/// Rotation of the plant parts: Rz(stem) * Ry(yaw) * Rx(pitch) applied to v.
_V3 _plantRot(_V3 v, double stem, double yaw, double pitch) {
  // Rx
  var y = v.y * math.cos(pitch) - v.z * math.sin(pitch);
  var z = v.y * math.sin(pitch) + v.z * math.cos(pitch);
  var x = v.x;
  // Ry
  final x2 = x * math.cos(yaw) + z * math.sin(yaw);
  final z2 = -x * math.sin(yaw) + z * math.cos(yaw);
  x = x2;
  z = z2;
  // Rz
  final x3 = x * math.cos(stem) - y * math.sin(stem);
  y = x * math.sin(stem) + y * math.cos(stem);
  return _V3(x3, y, z);
}

extension _FarmPaint on _NeuPainter {
  static const Color _benchWood = Color(0xFF6E452A);

  void _paintFarm(Canvas c, Size size) {
    final s = scene;
    final bleed = labBleed(size);
    c.drawRect(bleed, Paint()..color = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD1D5DB));
    final far = cam.p(0, 0, -100).dy;
    final ground = Rect.fromLTRB(bleed.left, far, bleed.right, bleed.bottom);
    c.drawRect(
      ground,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E2822), Color(0xFF3D352D), Color(0xFF463D33)],
          stops: [0, 0.45, 1],
        ).createShader(Rect.fromLTRB(0, -40, 0, 600)),
    );
    final rnd = math.Random(3);
    for (var i = 0; i < 140; i++) {
      final x = -16 + rnd.nextDouble() * 32, z = -14 + rnd.nextDouble() * 22;
      final p = cam.p(x, 0, z);
      final k = cam.k(x, 0, z);
      c.drawOval(
        Rect.fromCenter(center: p, width: 0.08 * k, height: 0.04 * k),
        Paint()..color = (i.isEven ? const Color(0x33000000) : const Color(0x22FFFFFF)),
      );
    }

    _paintBench(c);
    _paintSoil(c);
    _paintPlant(c);
    // Objects moved off the bench (drawn in front, nearest last).
    final moved = <(_V3, VoidCallback)>[];
    if (!_atStart(_Obj.probe) || s.dragging == _Obj.probe) moved.add((s.probe, () => _paintProbe(c)));
    if (s.limeVisible && (!_atStart(_Obj.limeBag) || s.dragging == _Obj.limeBag)) {
      moved.add((s.limeBag, () => _paintBag(c, s.limeBag, true, s.limeRot)));
    }
    if (!_atStart(_Obj.acidBag) || s.dragging == _Obj.acidBag) {
      moved.add((s.acidBag, () => _paintBag(c, s.acidBag, false, 0)));
    }
    if (!_atStart(_Obj.can)) moved.add((s.can, () => _paintCan(c)));
    moved.sort((a, b) => a.$1.z.compareTo(b.$1.z));
    for (final m in moved) {
      if (scene.dragging != null && m.$1 == scene.posOf(scene.dragging!)) continue;
      m.$2();
    }
    if (s.dragging != null) {
      switch (s.dragging!) {
        case _Obj.probe:
          _paintProbe(c);
        case _Obj.limeBag:
          _paintBag(c, s.limeBag, true, s.limeRot);
        case _Obj.acidBag:
          _paintBag(c, s.acidBag, false, 0);
        default:
          break;
      }
    }
  }

  void _paintBench(Canvas c) {
    final s = scene;
    const bx = 4.0, bz = -5.0;
    _shadow(c, cam, bx, bz, 5.2, 1.6, opacity: 0.3);
    // Spade leaning on the ground in front of the bench.
    _paintSpade(c);
    _box(c, cam, _V3(bx, 2.5, bz - 1.4), 10, 2.5, 0.2, _benchWood, edge: const Color(0x33000000));
    for (final lx in [-4.5, 4.5]) {
      _box(c, cam, _V3(bx + lx, 1, bz - 1.2), 0.2, 2, 0.2, _benchWood);
    }
    _box(c, cam, _V3(bx, 0.5, bz), 10, 0.1, 2.8, _benchWood, edge: const Color(0x33000000));
    if (_atStart(_Obj.can)) _paintCan(c);
    if (_atStart(_Obj.probe) && s.dragging != _Obj.probe) {
      _rod(c, cam, _V3(s.probe.x, s.probe.y - 1.5, s.probe.z), s.probe, 0.04, const Color(0xFFCCCCCC));
    }
    for (final lx in [-4.5, 4.5]) {
      _box(c, cam, _V3(bx + lx, 1, bz + 1.2), 0.2, 2, 0.2, _benchWood);
    }
    _box(c, cam, _V3(bx, 2, bz), 10, 0.2, 3, _benchWood, edge: const Color(0x33000000));
    final grain = Paint()
      ..strokeWidth = 1
      ..color = const Color(0x22000000);
    for (var i = 1; i < 6; i++) {
      final z = bz - 1.5 + i * 0.5;
      c.drawLine(cam.p(bx - 5, 2.101, z), cam.p(bx + 5, 2.101, z), grain);
    }
    if (s.limeVisible && _atStart(_Obj.limeBag) && s.dragging != _Obj.limeBag) {
      _paintBag(c, s.limeBag, true, s.limeRot);
    }
    if (_atStart(_Obj.acidBag) && s.dragging != _Obj.acidBag) _paintBag(c, s.acidBag, false, 0);
    if (_atStart(_Obj.probe) && s.dragging != _Obj.probe) _paintProbe(c, pin: false);
  }

  void _paintSpade(Canvas c) {
    final base = _V3(-0.5, 0, -4);
    const a = -0.2;
    _V3 at(double lx, double ly) => _rotZ(_V3(base.x + lx, base.y + ly, base.z), base, a);
    _shadow(c, cam, base.x - 0.3, base.z, 0.5, 0.2, opacity: 0.25);
    _rod(c, cam, at(0, 0.5), at(0, 2.45), 0.04, const Color(0xFFD4D4D8));
    final blade = [at(-0.25, 0.6), at(0.25, 0.6), at(0.05, 0.02), at(-0.05, 0.02)].map(cam.pv).toList();
    c.drawPath(
      _poly(blade),
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFFD1D5DB), Color(0xFF9CA3AF)])
            .createShader(_poly(blade).getBounds()),
    );
    final g = cam.pv(at(0, 2.5));
    c.drawCircle(
      g,
      0.12 * cam.kv(at(0, 2.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, 0.06 * cam.kv(at(0, 2.5)))
        ..color = const Color(0xFF4B5563),
    );
  }

  void _paintSoil(Canvas c) {
    final s = scene;
    final soilColor = Color.lerp(const Color(0xFF9B4522), const Color(0xFF472E1C), s.soilT)!;
    final base = _ellipseXZ(cam, s.soil.x, 0, s.soil.z, 3.48, 2.95);
    final top = cam.p(s.soil.x, 0.775, s.soil.z);
    labGroundShadow(c, base.center.translate(-6, 6), base.width * 1.04, base.height * 1.06, opacity: 0.35);
    final mound = Path()
      ..addOval(base)
      ..addOval(Rect.fromCenter(
        center: Offset(base.center.dx, (base.center.dy + top.dy) / 2),
        width: base.width * 0.94,
        height: base.height * 0.94,
      ));
    final bounds = mound.getBounds();
    c.drawPath(
      mound,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.25, -0.45),
          radius: 0.85,
          colors: [labShade(soilColor, 0.18), soilColor, labShade(soilColor, -0.35)],
          stops: const [0, 0.55, 1],
        ).createShader(bounds),
    );
    // Clods (HTML dodecahedrons, colour 0x6a2c11).
    final clod = Color.lerp(const Color(0xFF6A2C11), const Color(0xFF2E1D11), s.soilT)!;
    final sorted = [...s.clods]..sort((a, b) => a.z.compareTo(b.z));
    for (final cl in sorted) {
      final p = cam.p(s.soil.x + cl.x, cl.y, s.soil.z + cl.z);
      final r = cl.size * cam.k(s.soil.x + cl.x, cl.y, s.soil.z + cl.z);
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final ang = cl.rot + i * math.pi / 3;
        final rr = r * (i.isEven ? 1 : 0.8);
        final q = p + Offset(math.cos(ang) * rr, math.sin(ang) * rr * 0.8);
        if (i == 0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      path.close();
      c.drawPath(path, Paint()..color = clod);
      c.drawCircle(p.translate(r * 0.25, -r * 0.3), r * 0.3, Paint()..color = labShade(clod, 0.2).withValues(alpha: 0.6));
    }
  }

  void _paintPlant(Canvas c) {
    final s = scene;
    final color = Color.lerp(const Color(0xFF9E9D24), const Color(0xFF21C45C), s.plantT)!;
    final base = _V3(-2.5, 0.4, 1.5);
    final dir = _V3(-math.sin(s.stemRot), math.cos(s.stemRot), 0);
    final top = base + dir * 2.5;
    // Leaves sorted by depth so near leaves cover far ones.
    final leaves = <(double, VoidCallback)>[];
    for (var i = 0; i < 6; i++) {
      final at = base + dir * (0.3 + i * 0.35);
      final axis = _plantRot(_V3(0, 0, 1), s.stemRot, math.pi / 3 * i, s.leafRot[i]);
      final side = _plantRot(_V3(1, 0, 0), s.stemRot, math.pi / 3 * i, s.leafRot[i]);
      final ctr = at + axis * 0.9;
      leaves.add((-cam.depthOf(ctr.x, ctr.y, ctr.z), () => _leaf(c, at, axis, side, 0.02, 1.78, 0.32, color)));
    }
    leaves.sort((a, b) => a.$1.compareTo(b.$1));
    final stemDepth = -cam.depthOf(base.x, base.y + 1, base.z);
    var stemDrawn = false;
    void stem() {
      _rod(c, cam, base, top, 0.07, color);
      stemDrawn = true;
    }

    for (final l in leaves) {
      if (!stemDrawn && l.$1 > stemDepth) stem();
      l.$2();
    }
    if (!stemDrawn) stem();
    if (s.flowerScale > 0.01) _paintFlower(c, top, s.flowerScale);
  }

  /// One leaf / petal: an ellipse from [from] to [to] along [axis].
  void _leaf(Canvas c, _V3 at, _V3 axis, _V3 side, double from, double to, double half, Color color) {
    final p0 = cam.pv(at + axis * from), p1 = cam.pv(at + axis * to);
    final mid = at + axis * ((from + to) / 2);
    final l = cam.pv(mid + side * half), r = cam.pv(mid - side * half);
    final m = cam.pv(mid);
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(l.dx + (l.dx - m.dx) * 0.6, l.dy + (l.dy - m.dy) * 0.6, p1.dx, p1.dy)
      ..quadraticBezierTo(r.dx + (r.dx - m.dx) * 0.6, r.dy + (r.dy - m.dy) * 0.6, p0.dx, p0.dy)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(colors: [labShade(color, 0.12), color, labShade(color, -0.3)])
            .createShader(Rect.fromPoints(l, r).inflate(1)),
    );
    c.drawLine(
      p0,
      p1,
      Paint()
        ..strokeWidth = 1
        ..color = labShade(color, -0.35).withValues(alpha: 0.7),
    );
  }

  void _paintFlower(Canvas c, _V3 top, double fs) {
    final s = scene;
    final petals = <(double, VoidCallback)>[];
    for (var i = 0; i < 5; i++) {
      final axis = _plantRot(_V3(0, 0, 1), s.stemRot, math.pi * 2 / 5 * i, 0.2);
      final side = _plantRot(_V3(1, 0, 0), s.stemRot, math.pi * 2 / 5 * i, 0.2);
      final ctr = top + axis * (0.45 * fs);
      petals.add((
        -cam.depthOf(ctr.x, ctr.y, ctr.z),
        () => _leaf(c, top, axis, side, 0, 0.93 * fs, 0.3 * fs, const Color(0xFFD946EF)),
      ));
    }
    petals.sort((a, b) => a.$1.compareTo(b.$1));
    final centerDepth = -cam.depthOf(top.x, top.y, top.z);
    var centerDrawn = false;
    void center() {
      final p = cam.pv(top);
      final k = cam.kv(top) * fs;
      final r = Rect.fromCenter(center: p, width: 0.5 * k, height: 0.3 * k);
      c.drawOval(
        r,
        Paint()
          ..shader = const RadialGradient(colors: [Color(0xFFFFF59D), Color(0xFFFFEB3B), Color(0xFFF59E0B)])
              .createShader(r),
      );
      centerDrawn = true;
    }

    for (final p in petals) {
      if (!centerDrawn && p.$1 > centerDepth) center();
      p.$2();
    }
    if (!centerDrawn) center();
  }

  /// Digital soil probe: grey body, steel pin and the HTML canvas screen.
  void _paintProbe(Canvas c, {bool pin = true}) {
    final s = scene;
    final p = s.probe;
    if (pin) {
      final a = _rotZ(_V3(p.x, p.y - 1.5, p.z), p, s.probeRot);
      _rod(c, cam, a, p, 0.04, const Color(0xFFCCCCCC));
    }
    _box(
      c,
      cam,
      _V3(p.x, p.y + 0.6, p.z),
      0.8,
      1.2,
      0.3,
      const Color(0xFF666666),
      rotZ: s.probeRot,
      pivot: p,
      edge: const Color(0x44000000),
      printFront: (o, ex, ey) {
        // Screen 0.6 x 0.4 centred 0.8 above the base (face is 0.8 x 1.2).
        final so = o + ex * (0.1 / 0.8) + ey * (0.2 / 1.2);
        _onFace(c, so, ex * (0.6 / 0.8) / 256, ey * (0.4 / 1.2) / 128, () => _probeScreen(c));
      },
    );
  }

  /// HTML `updateProbeScreen` drawn into a 256 x 128 canvas.
  void _probeScreen(Canvas c) {
    final s = scene;
    c.drawRect(const Rect.fromLTWH(0, 0, 256, 128), Paint()..color = const Color(0xFF222222));
    final key = s.probeKey;
    if (key == null) return;
    final txt = _s(key);
    final glow = [Shadow(color: s.probeColor.withValues(alpha: 0.8), blurRadius: 10)];
    if (s.probeArrow) {
      labText(c, txt, const Offset(90, 64),
          size: 36, weight: FontWeight.w900, color: s.probeColor, maxWidth: 170, shadows: glow);
      c.drawPath(
        _poly(const [
          Offset(180, 30),
          Offset(210, 30),
          Offset(210, 70),
          Offset(230, 70),
          Offset(195, 105),
          Offset(160, 70),
          Offset(180, 70),
        ]),
        Paint()..color = s.probeColor,
      );
    } else {
      labText(c, txt, const Offset(128, 64),
          size: 44, weight: FontWeight.w900, color: s.probeColor, maxWidth: 240, shadows: glow);
    }
  }

  /// Lime (blue, base) or acidic fertilizer (red) bag with its printed label.
  void _paintBag(Canvas c, _V3 at, bool lime, double rot) {
    final color = lime ? const Color(0xFF3B82F6) : const Color(0xFFDC2626);
    if (at.y < 3.5) _shadow(c, cam, at.x, at.z, 0.8, 0.35, y: at.y - 1.0, opacity: 0.3);
    _box(
      c,
      cam,
      at,
      1.5,
      2.0,
      0.6,
      color,
      rotZ: rot,
      edge: const Color(0x44000000),
      printFront: (o, ex, ey) {
        // Label plane 1.2 x 1.0, 0.2 above the centre of the 1.5 x 2.0 face.
        final lo = o + ex * (0.15 / 1.5) + ey * (0.3 / 2.0);
        _onFace(c, lo, ex * (1.2 / 1.5) / 512, ey * (1.0 / 2.0) / 512, () {
          c.drawRect(const Rect.fromLTWH(0, 0, 512, 512), Paint()..color = color);
          c.drawCircle(const Offset(256, 150), 80, Paint()..color = Colors.white.withValues(alpha: 0.2));
          final white = Paint()..color = Colors.white;
          if (lime) {
            c.drawCircle(const Offset(256, 150), 40, white);
          } else {
            c.drawPath(_poly(const [Offset(256, 100), Offset(296, 180), Offset(216, 180)]), white);
          }
          final lines = _s(lime ? 'lblLime' : 'lblAcid').split('\n');
          if (lines.length > 1) {
            labText(c, lines[0], const Offset(256, 320), size: 64, weight: FontWeight.w900, maxWidth: 500);
            labText(c, lines[1], const Offset(256, 400), size: 48, weight: FontWeight.w800, maxWidth: 500);
          } else {
            labText(c, lines[0], const Offset(256, 360), size: 64, weight: FontWeight.w900, maxWidth: 500);
          }
        });
      },
    );
    // Folded top seam.
    final s0 = cam.pv(_rotZ(_V3(at.x - 0.75, at.y + 0.85, at.z + 0.31), at, rot));
    final s1 = cam.pv(_rotZ(_V3(at.x + 0.75, at.y + 0.85, at.z + 0.31), at, rot));
    c.drawLine(
      s0,
      s1,
      Paint()
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.25),
    );
  }

  /// Watering can: body, spout (tilted 60°) and handle.
  void _paintCan(Canvas c) {
    final s = scene;
    final g = s.can;
    const metal = Color(0xFF9CA3AF);
    if (_atStart(_Obj.can)) _shadow(c, cam, g.x, g.z, 0.7, 0.6, y: 0.55, opacity: 0.25);
    final pivot = cam.pv(g);
    c.save();
    if (s.canRot != 0) {
      c.translate(pivot.dx, pivot.dy);
      c.rotate(-s.canRot);
      c.translate(-pivot.dx, -pivot.dy);
    }
    final spout0 = _V3(g.x - 0.5, g.y + 0.2, g.z);
    final spout1 = _V3(g.x - 0.5 - 1.5 * math.sin(math.pi / 3), g.y + 0.2 + 1.5 * math.cos(math.pi / 3), g.z);
    _rod(c, cam, spout0, spout1, 0.08, metal);
    final rose = cam.pv(spout1);
    c.drawCircle(rose, 0.12 * cam.kv(spout1), Paint()..color = labShade(metal, -0.15));
    _cylV(c, cam, g.x, g.y, g.z, 0.6, 1.2, metal);
    final hc = cam.p(g.x + 0.6, g.y + 0.6, g.z);
    final hk = cam.k(g.x + 0.6, g.y + 0.6, g.z);
    c.drawArc(
      Rect.fromCircle(center: hc, radius: 0.4 * hk),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.16 * hk
        ..strokeCap = StrokeCap.round
        ..color = labShade(metal, -0.1),
    );
    c.restore();
  }
}

// ======================================================= SCENE MODEL
//
// The Three.js scenes are drawn with a small perspective camera (FOV 45°,
// same eye / target as the HTML) projecting world units into a 1000 x 560
// design canvas.

const Size _design = Size(1000, 560);

class _V3 {
  _V3(this.x, this.y, this.z);
  double x, y, z;

  _V3 copy() => _V3(x, y, z);

  void set(double nx, double ny, double nz) {
    x = nx;
    y = ny;
    z = nz;
  }

  void setFrom(_V3 o) => set(o.x, o.y, o.z);

  _V3 lerpTo(_V3 o, double t) => _V3(x + (o.x - x) * t, y + (o.y - y) * t, z + (o.z - z) * t);

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit => this * (1 / length);
  double distanceTo(_V3 o) => (this - o).length;
}

/// Look-at perspective camera (Three.js PerspectiveCamera, FOV 45°).
class _Cam {
  _Cam(this.eye, this.target, {this.cx = 500, this.cy = 280, this.zoom = 1}) {
    sync();
  }

  final _V3 eye;
  final _V3 target;
  double cx, cy, zoom;
  late _V3 _f, _r, _u;

  double get focal => 280 / 0.41421356 * zoom; // (H / 2) / tan(22.5°)

  /// Recomputes the camera basis after eye / target changed.
  void sync() {
    _f = (target - eye).unit;
    _r = _f.cross(_V3(0, 1, 0)).unit;
    _u = _r.cross(_f);
  }

  double depthOf(double x, double y, double z) => _V3(x - eye.x, y - eye.y, z - eye.z).dot(_f);

  Offset p(double x, double y, double z) {
    final d = _V3(x - eye.x, y - eye.y, z - eye.z);
    final zc = math.max(0.05, d.dot(_f));
    final s = focal / zc;
    return Offset(cx + d.dot(_r) * s, cy - d.dot(_u) * s);
  }

  Offset pv(_V3 v) => p(v.x, v.y, v.z);

  /// Design px per world unit at a point.
  double k(double x, double y, double z) => focal / math.max(0.05, depthOf(x, y, z));

  double kv(_V3 v) => k(v.x, v.y, v.z);

  /// The world point at camera depth [depth] under screen point [s] (the
  /// HTML drag plane, perpendicular to the view direction).
  _V3 unproject(Offset s, double depth) {
    final sx = (s.dx - cx) / focal * depth, sy = -(s.dy - cy) / focal * depth;
    return eye + _f * depth + _r * sx + _u * sy;
  }
}

/// Interactive objects of both scenarios.
enum _Obj { ant, soda, lemon, beaker, probe, limeBag, acidBag, can }

/// A GSAP-tweened particle (soda powder, paste drops, lime, water...).
class _Particle {
  _Particle({
    required this.from,
    required this.to,
    required this.t0,
    required this.dur,
    required this.color,
    required this.r,
    this.curve = Curves.linear,
    this.cube = false,
    this.onLand,
    this.shrinkDelay,
  });

  final _V3 from;
  _V3 to;
  final double t0, dur;
  Color color;
  final double r;
  final Curve curve;
  final bool cube;
  final void Function(_Particle p)? onLand;

  /// When set, the particle stays after landing and shrinks to 0 over
  /// [shrinkDur] seconds starting [shrinkDelay] seconds after landing.
  final double? shrinkDelay;
  static const double shrinkDur = 1.5;
  bool landed = false;
  double landedAt = 0;

  /// Optional second move after landing (blue lime particle onto the acid).
  _V3? moveTo;
  double moveDur = 0.5;

  _V3 posAt(double t) {
    final u = dur <= 0 ? 1.0 : ((t - t0) / dur).clamp(0.0, 1.0);
    final base = from.lerpTo(to, curve.transform(u));
    if (landed && moveTo != null) {
      final m = ((t - landedAt) / moveDur).clamp(0.0, 1.0);
      return base.lerpTo(moveTo!, Curves.easeOutQuad.transform(m));
    }
    return base;
  }

  double scaleAt(double t) {
    if (!landed || shrinkDelay == null) return 1;
    return 1 - ((t - landedAt - shrinkDelay!) / shrinkDur).clamp(0.0, 1.0);
  }

  bool visibleAt(double t) => t >= t0;
}

class _Clod {
  _Clod(this.x, this.y, this.z, this.size, this.rot);
  final double x, y, z, size, rot;
}

/// Mutable scene model shared by the State (logic) and the painter.
class _NeuScene {
  int scenario = 0;
  int step = 0;
  double time = 0;
  double builtAt = 0;
  late _Cam cam;
  final List<_Particle> particles = [];
  final Set<_Obj> draggable = {};
  final Set<_Obj> clickable = {};
  _Obj? dragging;

  /// Meter mask (HTML `scaleY` of #pain-mask): 1 = nothing revealed.
  double meterMask = 1;

  // ---- Scenario 1: ant bite ----
  final _V3 ant = _V3(1.5, 0.15, 3.5);
  final _V3 antStart = _V3(1.5, 0.15, 3.5);
  bool antVisible = true;
  bool markerOn = true;
  bool antLabelOn = true;
  double eyeRot = 0;
  double mouthSx = 1, mouthSy = 1;
  bool relieved = false;
  bool painFace = false;
  double biteOpacity = 0;
  bool bitePulsing = false;
  double biteScale = 1;
  final _V3 hand = _V3(0.3, 3.8, 0.5);
  final _V3 soda = _V3(3.2, 3.75, -0.2);
  final _V3 sodaStart = _V3(3.2, 3.75, -0.2);
  double sodaRot = 0;
  final _V3 lemon = _V3(4.8, 3.85, 0.4);
  final _V3 beaker = _V3(4.8, 3.65, -0.7);
  final _V3 beakerStart = _V3(4.8, 3.65, -0.7);
  double beakerRot = 0;
  Color waterColor = const Color(0xFFAADDFF);
  double waterScale = 1;
  double stirAngle = 0;

  /// World position of the red bite patch on the palm.
  _V3 get bite => _V3(hand.x + 0.14, hand.y + 0.075, hand.z);

  // ---- Scenario 2: farmer's crops ----
  final _V3 soil = _V3(-2.5, 0, 1.5);
  double soilT = 0; // 0 = acidic red-brown, 1 = healthy dark brown
  final List<_Clod> clods = [];
  double stemRot = 0.5;
  final List<double> leafRot = List.filled(6, 1.2);
  double plantT = 0; // 0 = wilted olive, 1 = healthy green
  double flowerScale = 0;
  final _V3 probe = _V3(6.5, 2.1, -4.5);
  final _V3 probeStart = _V3(6.5, 2.1, -4.5);
  double probeRot = 0;
  String? probeKey;
  Color probeColor = Colors.white;
  bool probeArrow = false;
  final _V3 limeBag = _V3(1.5, 3.1, -4.5);
  final _V3 limeStart = _V3(1.5, 3.1, -4.5);
  double limeRot = 0;
  bool limeVisible = true;
  final _V3 acidBag = _V3(4.0, 3.1, -4.5);
  final _V3 acidStart = _V3(4.0, 3.1, -4.5);
  final _V3 can = _V3(4, 0.6, -4.5);
  final _V3 canStart = _V3(4, 0.6, -4.5);
  double canRot = 0;

  bool get isAnt => scenario == 0;

  _V3 posOf(_Obj o) => switch (o) {
        _Obj.ant => ant,
        _Obj.soda => soda,
        _Obj.lemon => lemon,
        _Obj.beaker => beaker,
        _Obj.probe => probe,
        _Obj.limeBag => limeBag,
        _Obj.acidBag => acidBag,
        _Obj.can => can,
      };

  _V3 startOf(_Obj o) => switch (o) {
        _Obj.ant => antStart,
        _Obj.soda => sodaStart,
        _Obj.beaker => beakerStart,
        _Obj.probe => probeStart,
        _Obj.limeBag => limeStart,
        _Obj.acidBag => acidStart,
        _Obj.can => canStart,
        _Obj.lemon => lemon,
      };

  /// HTML `loadScenario(id)` + `buildScenario1/2`.
  void build(int index, double now) {
    scenario = index;
    step = 0;
    builtAt = now;
    particles.clear();
    draggable.clear();
    clickable.clear();
    dragging = null;
    if (index == 0) {
      cam = _Cam(_V3(0, 7, 14), _V3(0, 3, 0), cx: 450);
      meterMask = 1;
      ant.setFrom(antStart);
      antVisible = markerOn = antLabelOn = true;
      eyeRot = 0;
      mouthSx = mouthSy = 1;
      relieved = painFace = bitePulsing = false;
      biteOpacity = 0;
      biteScale = 1;
      soda.setFrom(sodaStart);
      sodaRot = 0;
      beaker.setFrom(beakerStart);
      beakerRot = 0;
      waterColor = const Color(0xFFAADDFF);
      waterScale = 1;
      stirAngle = 0;
      draggable.add(_Obj.ant);
    } else {
      cam = _Cam(_V3(0, 8, 15), _V3(0, 0, 0), cx: 420, cy: 336, zoom: 1.15);
      meterMask = 0.85;
      soilT = 0;
      stemRot = 0.5;
      for (var i = 0; i < 6; i++) {
        leafRot[i] = 1.2;
      }
      plantT = 0;
      flowerScale = 0;
      probe.setFrom(probeStart);
      probeRot = 0;
      probeKey = null;
      probeColor = Colors.white;
      probeArrow = false;
      limeBag.setFrom(limeStart);
      limeRot = 0;
      limeVisible = true;
      acidBag.setFrom(acidStart);
      can.setFrom(canStart);
      canRot = 0;
      final rnd = math.Random(11);
      clods
        ..clear()
        ..addAll(List.generate(40, (_) {
          final th = rnd.nextDouble() * math.pi * 2;
          final r = rnd.nextDouble() * 2.8;
          return _Clod(math.cos(th) * r, 0.3 + rnd.nextDouble() * 0.3, math.sin(th) * r * 0.8,
              0.08 + rnd.nextDouble() * 0.15, rnd.nextDouble() * math.pi);
        }));
      draggable.addAll([_Obj.probe, _Obj.limeBag, _Obj.acidBag]);
    }
  }
}

// ===================================================== DRAW HELPERS

Color _a(Color c, double opacity) => c.withValues(alpha: c.a * opacity);

/// Directional light of the HTML scenes (position (20, 30, -10)).
final _V3 _light = _V3(20, 30, -10).unit;

/// Shade amount for a face with normal [n] (Lambert + ambient).
double _lambert(_V3 n) => -0.22 + 0.4 * math.max(0, n.dot(_light));

Path _poly(List<Offset> pts) {
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final q in pts.skip(1)) {
    p.lineTo(q.dx, q.dy);
  }
  return p..close();
}

_V3 _rotZ(_V3 v, _V3 pivot, double a) {
  if (a == 0) return v;
  final dx = v.x - pivot.x, dy = v.y - pivot.y;
  final c = math.cos(a), s = math.sin(a);
  return _V3(pivot.x + dx * c - dy * s, pivot.y + dx * s + dy * c, v.z);
}

/// Runs [draw] with the unit square mapped onto the parallelogram
/// (o, o + ex, o + ey) - used to print labels on box faces.
void _onFace(Canvas c, Offset o, Offset ex, Offset ey, VoidCallback draw) {
  c.save();
  c.transform(Matrix4(ex.dx, ex.dy, 0, 0, ey.dx, ey.dy, 0, 0, 0, 0, 1, 0, o.dx, o.dy, 0, 1).storage);
  draw();
  c.restore();
}

/// World box centred at [ctr] (Three.js BoxGeometry), optionally rotated
/// by [rotZ] about the z axis through [pivot]. Only faces turned towards
/// the camera are drawn. [print] receives the front (+z) or top (+y) face
/// corners (top-left, top-right, bottom-left) for printed labels.
void _box(
  Canvas c,
  _Cam cam,
  _V3 ctr,
  double w,
  double h,
  double d,
  Color color, {
  double rotZ = 0,
  _V3? pivot,
  double opacity = 1,
  Color? edge,
  void Function(Offset o, Offset ex, Offset ey)? printFront,
  void Function(Offset o, Offset ex, Offset ey)? printTop,
}) {
  final pv = pivot ?? ctr;
  _V3 at(double sx, double sy, double sz) =>
      _rotZ(_V3(ctr.x + sx * w / 2, ctr.y + sy * h / 2, ctr.z + sz * d / 2), pv, rotZ);
  final cs = math.cos(rotZ), sn = math.sin(rotZ);
  _V3 n(double x, double y, double z) => _V3(x * cs - y * sn, x * sn + y * cs, z);
  // (normal, corners) for +x, -x, +y, -y, +z, -z.
  final faces = <(_V3, List<_V3>, int)>[
    (n(1, 0, 0), [at(1, 1, 1), at(1, 1, -1), at(1, -1, -1), at(1, -1, 1)], 0),
    (n(-1, 0, 0), [at(-1, 1, -1), at(-1, 1, 1), at(-1, -1, 1), at(-1, -1, -1)], 1),
    (n(0, 1, 0), [at(-1, 1, -1), at(1, 1, -1), at(1, 1, 1), at(-1, 1, 1)], 2),
    (n(0, -1, 0), [at(-1, -1, 1), at(1, -1, 1), at(1, -1, -1), at(-1, -1, -1)], 3),
    (n(0, 0, 1), [at(-1, 1, 1), at(1, 1, 1), at(1, -1, 1), at(-1, -1, 1)], 4),
    (n(0, 0, -1), [at(1, 1, -1), at(-1, 1, -1), at(-1, -1, -1), at(1, -1, -1)], 5),
  ];
  for (final f in faces) {
    final pts = f.$2;
    final fc = (pts[0] + pts[2]) * 0.5;
    if (f.$1.dot(cam.eye - fc) <= 0) continue;
    final q = pts.map(cam.pv).toList();
    final path = _poly(q);
    c.drawPath(path, Paint()..color = _a(labShade(color, _lambert(f.$1)), opacity));
    if (edge != null) {
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..strokeJoin = StrokeJoin.round
          ..color = _a(edge, opacity),
      );
    }
    if (f.$3 == 4 && printFront != null) printFront(q[0], q[1] - q[0], q[3] - q[0]);
    if (f.$3 == 2 && printTop != null) printTop(q[0], q[1] - q[0], q[3] - q[0]);
  }
}

/// Screen rect of the horizontal circle of radius [r] at (x, y, z).
Rect _ring(_Cam cam, double x, double y, double z, double r) {
  final l = cam.p(x - r, y, z), rr = cam.p(x + r, y, z);
  final f = cam.p(x, y, z + r), b = cam.p(x, y, z - r);
  final ctr = cam.p(x, y, z);
  return Rect.fromCenter(
    center: Offset(ctr.dx, (f.dy + b.dy) / 2),
    width: (rr.dx - l.dx).abs(),
    height: math.max(1, (f.dy - b.dy).abs()),
  );
}

/// Vertical (optionally tapered) cylinder standing on (x, y0, z).
void _cylV(
  Canvas c,
  _Cam cam,
  double x,
  double y0,
  double z,
  double r,
  double h,
  Color color, {
  double? rTop,
  double opacity = 1,
  bool top = true,
  Color? topColor,
}) {
  final b = _ring(cam, x, y0, z, r), t = _ring(cam, x, y0 + h, z, rTop ?? r);
  final body = Path()
    ..moveTo(t.left, t.center.dy)
    ..lineTo(b.left, b.center.dy)
    ..arcTo(b, math.pi, -math.pi, false)
    ..lineTo(t.right, t.center.dy)
    ..arcTo(t, 0, -math.pi, false)
    ..close();
  c.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        _a(labShade(color, -0.32), opacity),
        _a(labShade(color, -0.08), opacity),
        _a(labShade(color, 0.14), opacity),
        _a(labShade(color, -0.12), opacity),
      ], stops: const [0, 0.35, 0.72, 1]).createShader(body.getBounds()),
  );
  if (top) c.drawOval(t, Paint()..color = _a(topColor ?? labShade(color, 0.12), opacity));
}

/// Thick shaded rod between two world points (arms, stems, pins...).
void _rod(Canvas c, _Cam cam, _V3 a, _V3 b, double r, Color color, {double opacity = 1}) {
  final pa = cam.pv(a), pb = cam.pv(b);
  final w = r * (cam.kv(a) + cam.kv(b));
  final dir = pb - pa;
  final len = dir.distance;
  final nrm = len < 0.01 ? const Offset(1, 0) : Offset(-dir.dy / len, dir.dx / len);
  c.drawLine(
    pa,
    pb,
    Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(colors: [
        _a(labShade(color, -0.3), opacity),
        _a(labShade(color, 0.15), opacity),
        _a(labShade(color, -0.2), opacity),
      ]).createShader(Rect.fromPoints(pa - nrm * w / 2, pa + nrm * w / 2)),
  );
}

/// Lit sphere at a world point (light from the upper right).
void _ball(Canvas c, _Cam cam, _V3 p, double r, Color color, {double opacity = 1}) {
  labSphere(c, cam.pv(p), r * cam.kv(p), color,
      light: const Offset(0.35, -0.45), highlight: 0.35, shade: 0.45, opacity: opacity);
}

/// Soft shadow on the ground under an object at height [h] (the light
/// comes from the upper right / back, so shadows fall left and forward).
void _shadow(Canvas c, _Cam cam, double x, double z, double rx, double rz,
    {double h = 0, double y = 0, double opacity = 0.3}) {
  final e = _ring(cam, x - 0.45 * h, y + 0.01, z + 0.2 * h, 1);
  final k = e.width / 2;
  labGroundShadow(
    c,
    e.center,
    rx * 2 * k,
    math.max(2, rz * 2 * e.height / 2),
    opacity: opacity,
  );
}

/// Sprite label (HTML createTextSprite: dark translucent rounded box).
void _label(Canvas c, _Cam cam, String text, _V3 at, {double opacity = 1}) {
  final k = cam.kv(at);
  labText(
    c,
    text,
    cam.pv(at),
    size: (0.34 * k).clamp(12.0, 17.0),
    weight: FontWeight.w800,
    color: Colors.white,
    background: const Color(0xB3000000),
    border: Colors.white.withValues(alpha: 0.12),
    borderWidth: 1,
    radius: 9,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    opacity: opacity,
  );
}

// ============================================================ PAINTER

class _NeuPainter extends CustomPainter {
  _NeuPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.text,
  }) : super(repaint: repaint);

  final _NeuScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> text;

  _Cam get cam => scene.cam;
  String _s(String k) => text[k] ?? k;

  static const Color _skin = Color(0xFFFFDAB9);
  static const Color _shirt = Color(0xFF3B82F6);
  static const Color _pants = Color(0xFF1E3A8A);
  static const Color _wood = Color(0xFF825736);

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.isAnt) {
      _paintAntScene(canvas, size);
    } else {
      _paintFarm(canvas, size);
    }
    if (showLabels) _paintLabels(canvas);
    _paintParticles(canvas);
  }

  bool _atStart(_Obj o) => scene.posOf(o).distanceTo(scene.startOf(o)) < 1e-3;

  // ------------------------------------------------------ ant scene

  void _paintAntScene(Canvas c, Size size) {
    final s = scene;
    final bleed = labBleed(size);
    final horizon = cam.p(0, 0, -100).dy;
    c.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, horizon + 1),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5FB4E6), Color(0xFF87CEEB), Color(0xFFCBEAF6)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromLTRB(0, -60, 0, horizon + 1)),
    );
    // Soft clouds.
    for (final cl in const [(150.0, 40.0, 1.0), (430.0, 22.0, 0.8), (820.0, 48.0, 1.2)]) {
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.75);
      final o = Offset(cl.$1, cl.$2);
      for (final b in const [(-34.0, 6.0, 20.0), (-10.0, -4.0, 26.0), (18.0, 2.0, 22.0), (40.0, 8.0, 15.0)]) {
        c.drawCircle(o + Offset(b.$1, b.$2) * cl.$3, b.$3 * cl.$3, paint);
      }
    }
    final floor = Rect.fromLTRB(bleed.left, horizon, bleed.right, bleed.bottom);
    c.drawRect(
      floor,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF9BD97A), Color(0xFF6BCA3A), Color(0xFF58B02D)],
          stops: const [0, 0.35, 1],
        ).createShader(Rect.fromLTRB(0, horizon, 0, 600)),
    );
    // Grass tufts for depth.
    final rnd = math.Random(5);
    final tuft = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x403F8F1F);
    for (var i = 0; i < 90; i++) {
      final x = -14 + rnd.nextDouble() * 28, z = -12 + rnd.nextDouble() * 20;
      final p = cam.p(x, 0, z);
      final k = cam.k(x, 0, z) * 0.12;
      c.drawLine(p, p.translate(-k * 0.6, -k * 1.6), tuft);
      c.drawLine(p, p.translate(k * 0.5, -k * 1.4), tuft);
    }

    // Shadows: character, table, ant.
    _shadow(c, cam, -3.5, 0.2, 1.6, 1.3, opacity: 0.28);
    _shadow(c, cam, 2.5, 0.5, 3.6, 2.1, h: 1.6, opacity: 0.2);
    if (s.antVisible && s.ant.y < 0.6) _shadow(c, cam, s.ant.x, s.ant.z, 0.35, 0.25, opacity: 0.3);

    _paintCharacter(c);
    _paintTable(c);
    _paintTray(c);
    if (_atStart(_Obj.beaker) && s.dragging != _Obj.beaker) _paintBeaker(c);
    if (_atStart(_Obj.soda) && s.dragging != _Obj.soda) _paintSoda(c);
    _paintLemon(c);
    _paintRightArm(c);
    if (s.antVisible && s.dragging != _Obj.ant) _paintAnt(c);
    // Moving / dragged objects on top.
    if (!_atStart(_Obj.soda) || s.dragging == _Obj.soda) _paintSoda(c);
    if (!_atStart(_Obj.beaker) || s.dragging == _Obj.beaker) _paintBeaker(c);
    if (s.antVisible && s.dragging == _Obj.ant) _paintAnt(c);
  }

  void _paintCharacter(Canvas c) {
    const x = -3.5;
    for (final lx in [x - 0.6, x + 0.6]) {
      _cylV(c, cam, lx, 0.3, 0, 0.4, 2.2, _pants);
      _box(c, cam, _V3(lx, 0.2, 0.2), 0.9, 0.4, 1.2, const Color(0xFF333333));
    }
    // Left arm hanging by the side.
    _cylV(c, cam, x - 1.4, 2.35, 0, 0.35, 2.5, _shirt, topColor: labShade(_shirt, 0.15));
    _ball(c, cam, _V3(x - 1.4, 2.3, 0), 0.35, _skin);
    // Torso.
    _cylV(c, cam, x, 2.3, 0, 1.2, 3.0, _shirt);
    // Head.
    final head = _V3(x, 6.2, 0);
    _ball(c, cam, head, 1.2, _skin);
    final s = scene;
    final ink = Paint()..color = const Color(0xFF111111);
    for (final side in [-1.0, 1.0]) {
      final e = cam.p(head.x + 0.4 * side, head.y + 0.2, head.z + 1.15);
      final k = cam.k(head.x, head.y, head.z + 1.15);
      c.save();
      c.translate(e.dx, e.dy);
      c.rotate(-side * s.eyeRot);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: 0.22 * k, height: (s.eyeRot > 0 ? 0.1 : 0.2) * k), ink);
      if (s.eyeRot == 0) {
        c.drawCircle(Offset(0.03 * k, -0.04 * k), 0.035 * k, Paint()..color = Colors.white);
      }
      c.restore();
    }
    final m = cam.p(head.x, head.y - 0.3, head.z + 1.15);
    final k = cam.k(head.x, head.y, head.z + 1.15);
    final mw = 0.3 * s.mouthSx * k, mh = math.max(1.5, 0.05 * s.mouthSy * k);
    if (s.relieved) {
      c.drawArc(
        Rect.fromCenter(center: m.translate(0, -mw * 0.25), width: mw, height: mw * 0.5),
        0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, mh * 1.4)
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF111111),
      );
    } else {
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: m, width: mw, height: mh), Radius.circular(mh / 2)),
        ink,
      );
    }
    if (s.painFace) {
      // Sweat drop.
      final d = cam.p(head.x + 1.0, head.y + 0.5, head.z + 0.6);
      final dk = cam.k(head.x, head.y, head.z);
      c.drawPath(
        Path()
          ..moveTo(d.dx, d.dy - 0.22 * dk)
          ..quadraticBezierTo(d.dx + 0.12 * dk, d.dy, d.dx, d.dy + 0.06 * dk)
          ..quadraticBezierTo(d.dx - 0.12 * dk, d.dy, d.dx, d.dy - 0.22 * dk),
        Paint()..color = const Color(0xCC7DD3FC),
      );
    }
  }

  void _paintTable(Canvas c) {
    const tx = 2.5, tz = 0.5;
    for (final lz in [-1.7, 1.7]) {
      for (final lx in [-3.2, 3.2]) {
        _box(c, cam, _V3(tx + lx, 1.6, tz + lz), 0.15, 3.2, 0.15, _wood);
      }
    }
    _box(c, cam, _V3(tx, 3.3, tz), 7, 0.2, 4.0, _wood, edge: const Color(0x33000000));
    // Wood grain on the table top.
    final grain = Paint()
      ..strokeWidth = 1
      ..color = const Color(0x22000000);
    for (var i = 1; i < 8; i++) {
      final z = tz - 2 + i * 0.5;
      c.drawLine(cam.p(tx - 3.5, 3.401, z), cam.p(tx + 3.5, 3.401, z), grain);
    }
  }

  void _paintTray(Canvas c) {
    const tray = Color(0xFF9CA3AF);
    final t = _V3(4.0, 3.55, -0.2);
    _box(c, cam, t, 3.7, 0.3, 2.7, tray, edge: const Color(0x33000000));
    final inner = [
      cam.p(t.x - 1.7, 3.701, t.z - 1.2),
      cam.p(t.x + 1.7, 3.701, t.z - 1.2),
      cam.p(t.x + 1.7, 3.701, t.z + 1.2),
      cam.p(t.x - 1.7, 3.701, t.z + 1.2),
    ];
    c.drawPath(_poly(inner), Paint()..color = labShade(tray, 0.12));
  }

  void _paintSoda(Canvas c) {
    final s = scene;
    _box(
      c,
      cam,
      s.soda,
      1.2,
      0.15,
      1.5,
      const Color(0xFFF97316),
      rotZ: s.sodaRot,
      edge: const Color(0x33000000),
      printTop: (o, ex, ey) => _onFace(c, o, ex / 200, ey / 100, () {
        c.drawRect(const Rect.fromLTWH(0, 0, 200, 100), Paint()..color = const Color(0xFFF97316));
        labText(c, _s('lblSoda'), const Offset(100, 50),
            size: 30, weight: FontWeight.w900, color: Colors.white, maxWidth: 190);
      }),
    );
  }

  void _paintLemon(Canvas c) {
    final l = scene.lemon;
    final p = cam.pv(l);
    final k = cam.kv(l);
    _shadow(c, cam, l.x, l.z, 0.4, 0.35, y: 3.7, opacity: 0.25);
    final r = Rect.fromCenter(center: p, width: 0.84 * k, height: 0.7 * k);
    c.drawOval(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.3, -0.45),
          colors: [Color(0xFFFEF9C3), Color(0xFFFACC15), Color(0xFFB45309)],
          stops: [0, 0.55, 1],
        ).createShader(r),
    );
    final leaf = cam.p(l.x + 0.4, l.y + 0.2, l.z);
    c.save();
    c.translate(leaf.dx, leaf.dy);
    c.rotate(math.pi / 4);
    c.drawPath(
      Path()
        ..moveTo(0, -0.15 * k)
        ..lineTo(0.1 * k, 0.15 * k)
        ..lineTo(-0.1 * k, 0.15 * k)
        ..close(),
      Paint()..color = const Color(0xFF228B22),
    );
    c.restore();
  }

  void _paintBeaker(Canvas c) {
    final s = scene;
    final b = s.beaker;
    final pivot = cam.pv(b);
    if (_atStart(_Obj.beaker)) _shadow(c, cam, b.x, b.z, 0.55, 0.5, y: 3.7, opacity: 0.25);
    c.save();
    if (s.beakerRot != 0) {
      c.translate(pivot.dx, pivot.dy);
      c.rotate(-s.beakerRot);
      c.translate(-pivot.dx, -pivot.dy);
    }
    final bottom = _ring(cam, b.x, b.y, b.z, 0.5), top = _ring(cam, b.x, b.y + 1.2, b.z, 0.5);
    final body = Path()
      ..moveTo(top.left, top.center.dy)
      ..lineTo(bottom.left, bottom.center.dy)
      ..arcTo(bottom, math.pi, -math.pi, false)
      ..lineTo(top.right, top.center.dy)
      ..arcTo(top, 0, -math.pi, false)
      ..close();
    c.drawPath(body, Paint()..color = Colors.white.withValues(alpha: 0.16));
    c.drawArc(top, math.pi, math.pi, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.5));
    // Water / basic paste.
    final wh = 0.6 * s.waterScale;
    if (wh > 0.01) {
      _cylV(c, cam, b.x, b.y + 0.03, b.z, 0.48, wh, s.waterColor, opacity: 0.85, topColor: labShade(s.waterColor, 0.25));
    }
    // Glass stirrer spinning about the beaker axis (HTML stirrerGroup).
    final a = s.stirAngle;
    _V3 sp(double lx, double ly) {
      final rx = lx * math.cos(a), rz = -lx * math.sin(a);
      return _V3(b.x + rx, b.y + 0.6 + ly, b.z + rz);
    }
    final tilt = math.sin(0.15) * 0.7, rise = math.cos(0.15) * 0.7;
    _rod(c, cam, sp(0.2 - tilt, -rise + 0.15), sp(0.2 + tilt, rise), 0.025, const Color(0xFFEEEEEE), opacity: 0.85);
    // Glass outline, spout and scale.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.7);
    c.drawLine(Offset(top.left, top.center.dy), Offset(bottom.left, bottom.center.dy), edge);
    c.drawLine(Offset(top.right, top.center.dy), Offset(bottom.right, bottom.center.dy), edge);
    c.drawArc(bottom, 0, math.pi, false, edge);
    c.drawArc(top, 0, math.pi, false, edge);
    final k = cam.kv(b);
    c.drawPath(
      Path()
        ..moveTo(top.left + 0.02 * k, top.center.dy - 0.04 * k)
        ..lineTo(top.left - 0.16 * k, top.center.dy - 0.12 * k)
        ..lineTo(top.left + 0.05 * k, top.center.dy + 0.08 * k)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    final mark = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.85);
    final mx = top.center.dx + top.width * 0.18;
    double yAt(double frac) => bottom.center.dy + (top.center.dy - bottom.center.dy) * frac;
    for (final m in const [(0.8, '200'), (0.5, '100'), (0.25, '50')]) {
      final y = yAt(m.$1) + top.height * 0.45;
      c.drawLine(Offset(mx, y), Offset(mx + 0.12 * k, y), mark);
      labText(c, m.$2, Offset(mx - 0.03 * k, y), size: math.max(6, 0.13 * k),
          weight: FontWeight.w800, anchor: Alignment.centerRight, color: Colors.white.withValues(alpha: 0.9));
    }
    labText(c, _s('ml'), Offset(mx - 0.03 * k, yAt(0.96) + top.height * 0.45), size: math.max(6, 0.13 * k),
        weight: FontWeight.w800, anchor: Alignment.centerRight, color: Colors.white.withValues(alpha: 0.9));
    c.drawLine(
      Offset(top.left + top.width * 0.18, top.center.dy + top.height * 0.6),
      Offset(bottom.left + bottom.width * 0.18, bottom.center.dy - bottom.height * 0.2),
      Paint()
        ..strokeWidth = math.max(2, 0.05 * k)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    c.restore();
  }

  void _paintRightArm(Canvas c) {
    final s = scene;
    final shoulder = _V3(-2.3, 4.3, 0);
    final hand = s.hand;
    final dir = hand - shoulder;
    final sleeveEnd = shoulder + dir * (0.8 / dir.length);
    _rod(c, cam, shoulder, hand, 0.25, _skin);
    _rod(c, cam, shoulder, sleeveEnd, 0.4, _shirt);
    // Palm (0.8 x 0.1 x 0.8, scaled 1.4) and fingers.
    _box(c, cam, hand, 1.12, 0.14, 1.12, _skin, rotZ: -0.1);
    for (final f in const [(0.4, 0.2, 0.5, math.pi / 4), (0.6, 0.4, 0.3, 0.0), (0.65, 0.4, 0.1, 0.0), (0.6, 0.4, -0.1, 0.0), (0.5, 0.4, -0.3, 0.0)]) {
      final start = _V3(hand.x + f.$2 * 1.4, hand.y + 0.03, hand.z + f.$3 * 1.4);
      final end = start + _V3(math.cos(f.$4), 0, -math.sin(f.$4)) * (f.$1 * 1.4);
      _rod(c, cam, start, end, 0.09, _skin);
    }
    // Bite patch (red, pulsing) on the palm.
    if (s.biteOpacity > 0.01) {
      final bp = s.bite;
      final r = _ring(cam, bp.x, bp.y, bp.z, 0.42 * s.biteScale);
      c.drawOval(
        r.inflate(r.width * 0.2),
        Paint()
          ..color = const Color(0xFFFF0000).withValues(alpha: s.biteOpacity * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      c.drawOval(r, Paint()..color = const Color(0xFFFF0000).withValues(alpha: s.biteOpacity));
    }
  }

  void _paintAnt(Canvas c) {
    final s = scene;
    final a = s.ant;
    final k = cam.kv(a);
    if (s.markerOn) {
      final pulse = 1 + 0.5 * (0.5 - 0.5 * math.cos(s.time * math.pi));
      final ring = _ring(cam, a.x, a.y - 0.15, a.z, 0.27 * pulse);
      c.drawOval(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, 0.06 * k * pulse)
          ..color = const Color(0xFFEAB308).withValues(alpha: 0.8),
      );
    }
    const red = Color(0xFFCC0000);
    final leg = Paint()
      ..strokeWidth = math.max(1.2, 0.03 * k)
      ..strokeCap = StrokeCap.round
      ..color = labShade(red, -0.3);
    final wiggle = s.dragging == _Obj.ant ? math.sin(s.time * 30) * 0.05 : 0.0;
    for (var i = 0; i < 3; i++) {
      for (final side in [-1.0, 1.0]) {
        final from = cam.p(a.x + (-0.2 + i * 0.2) * 0.6, a.y, a.z);
        final to = cam.p(a.x + (-0.28 + i * 0.22 + wiggle * side) * 0.6, a.y - 0.15, a.z + side * 0.25);
        c.drawLine(from, to, leg);
      }
    }
    _ball(c, cam, _V3(a.x - 0.24, a.y, a.z), 0.15, red);
    _ball(c, cam, a, 0.12, red);
    _ball(c, cam, _V3(a.x + 0.18, a.y + 0.06, a.z), 0.13, red);
    // Antennae.
    final h = cam.p(a.x + 0.22, a.y + 0.12, a.z);
    final ant = Paint()
      ..strokeWidth = math.max(1, 0.02 * k)
      ..strokeCap = StrokeCap.round
      ..color = labShade(red, -0.35);
    c.drawLine(h, h + Offset(0.12 * k, -0.14 * k), ant);
    c.drawLine(h, h + Offset(0.2 * k, -0.06 * k), ant);
  }

  // -------------------------------------------------------- particles

  void _paintParticles(Canvas c) {
    final t = scene.time;
    for (final p in scene.particles) {
      if (!p.visibleAt(t)) continue;
      final sc = p.scaleAt(t);
      if (sc <= 0.01) continue;
      final pos = p.posAt(t);
      final at = cam.pv(pos);
      final r = p.r * cam.kv(pos) * sc;
      if (p.cube) {
        c.drawRect(Rect.fromCenter(center: at, width: r * 2, height: r * 2), Paint()..color = p.color);
        c.drawRect(
          Rect.fromCenter(center: at, width: r * 2, height: r * 2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6
            ..color = const Color(0x33000000),
        );
      } else {
        labSphere(c, at, math.max(1.2, r), p.color, highlight: 0.5, shade: 0.25);
      }
    }
  }

  // ----------------------------------------------------------- labels

  void _paintLabels(Canvas c) {
    final s = scene;
    final fade = ((s.time - s.builtAt - 0.1) / 0.3).clamp(0.0, 1.0);
    if (fade <= 0) return;
    if (s.isAnt) {
      if (s.antLabelOn) _label(c, cam, _s('lblAnt'), _V3(1.5, 1.5, 3.5), opacity: fade);
      _label(c, cam, _s('lblSoda'), _V3(3.2, 4.95, -0.2), opacity: fade);
      _label(c, cam, _s('lblLemon'), _V3(4.8, 4.75, 0.6), opacity: fade);
    } else {
      _label(c, cam, _s('lblSoil'), _V3(-2.5, 1.2, 3.5), opacity: fade);
      _label(c, cam, _s('lblPlant'), _V3(-2.5, 3.5, 1.5), opacity: fade);
      _label(c, cam, _s('lblBench'), _V3(4, 4.5, -5), opacity: fade);
      _label(c, cam, _s('lblProbe'), _V3(6.5, 3.5, -4.5), opacity: fade);
      _label(c, cam, _s('lblWater'), _V3(4, 1.8, -4.5), opacity: fade);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
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
