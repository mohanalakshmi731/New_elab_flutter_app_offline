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

/// Class 7 Science • Chapter 2 • Activity 3
/// Investigating Olfactory Indicators.
///
/// Native Flutter port of `Cl7S-Ch2-A3-Investigating_Olfactory_Indicators.html`.
/// Scenario 1: onion-infused cloth strips keep their smell with tamarind
/// water (acid) but lose it with baking soda solution (base).
/// Scenario 2: clove oil on cotton swabs keeps its smell with lemon juice
/// but loses it with lime water.
class Ch2A3InvestigatingOlfactoryIndicatorsPage extends StatefulWidget {
  const Ch2A3InvestigatingOlfactoryIndicatorsPage({super.key});

  @override
  State<Ch2A3InvestigatingOlfactoryIndicatorsPage> createState() =>
      _Ch2A3InvestigatingOlfactoryIndicatorsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, magic 871.
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

/// A TWEEN.js style tween driven by the scene ticker.
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

class _Ch2A3InvestigatingOlfactoryIndicatorsPageState
    extends State<Ch2A3InvestigatingOlfactoryIndicatorsPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _OlfScene _scene = _OlfScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Tw> _tweens = [];

  late final Ticker _ticker;
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  int _gen = 0;
  bool _overnight = false;
  bool _validated = false;
  bool _dropperBusy = false;
  bool _lidBusy = false;
  bool _advancePending = false;
  _Tw? _liftTween;
  double _grabDx = 0, _grabDz = 0, _grabY = 0;
  bool _prevLocked = true, _prevPan = false;

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
    _prevLocked = _lab.camLocked;
    _lab.addListener(_onLabChanged);
    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      _scene.time = t;
      _runTweens(t);
      _scene.smells.removeWhere((s) => t - s.start > s.duration);
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
    _spin.dispose();
    _frame.dispose();
    _lab.removeListener(_onLabChanged);
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ tweens

  /// End time of the tween whose `onDone` is running, so chained tweens
  /// start exactly when the previous one ended (TWEEN.js chaining).
  double? _clock;

  _Tw _add(_Tw tw) {
    if (_clock != null) tw.start = _clock! + tw.delay;
    _tweens.add(tw);
    return tw;
  }

  void _tween(int ms, Curve curve, void Function(double v) update,
      {int delayMs = 0, VoidCallback? onDone}) {
    _add(_Tw(ms / 1000, curve, update, onDone, delayMs / 1000));
  }

  _Tw _moveTo(_V3 p, _V3 target, int ms, Curve curve, {int delayMs = 0, VoidCallback? onDone}) {
    _V3? from;
    return _add(_Tw(ms / 1000, curve, (v) {
      from ??= p.copy();
      p.setFrom(from!.lerpTo(target, v));
    }, onDone, delayMs / 1000));
  }

  void _runTweens(double now) {
    final gen = _gen;
    final seen = <_Tw>{};
    // Tweens chained from an `onDone` run in the same frame.
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

  // ------------------------------------------------------------- setup

  /// HTML `loadScenario(index)`.
  void _load(int index) {
    _gen++;
    _tweens.clear();
    _liftTween = null;
    _lab.cancelPending();
    _spin.stop();
    setState(() {
      _overnight = false;
      _validated = false;
      _dropperBusy = false;
      _lidBusy = false;
      _advancePending = false;
      _scene.build(index, _scene.time);
    });
  }

  void _changeScenario(int index) {
    _lab.hidePopup(sound: false);
    _load(index);
  }

  void _fullReset() {
    _prevLocked = _lab.camLocked;
    _prevPan = _lab.panMode;
    _load(0);
  }

  void _onEnter() => _scene.builtAt = _scene.time;

  /// The HTML tool buttons show a toast when the camera lock / pan mode
  /// changes; the shell owns those buttons, so react to the controller.
  void _onLabChanged() {
    if (_lab.camLocked != _prevLocked) {
      _prevLocked = _lab.camLocked;
      if (_lab.isLabActive) {
        _lab.showToast(_t(_prevLocked ? 'toastCameraLocked' : 'toastCameraUnlocked'), sound: false);
      }
    }
    if (_lab.panMode != _prevPan) {
      _prevPan = _lab.panMode;
      if (_lab.isLabActive) {
        _lab.showToast(_t(_prevPan ? 'toastPanMode' : 'toastPanOff'), sound: false);
      }
    }
  }

  // ------------------------------------------------------- hit testing

  bool get _canInteract => _lab.isLabActive && !_overnight && _scene.dragging == null;

  Rect _hitRect(_Obj o) {
    final s = _scene;
    final p = s.posOf(o)!;
    switch (o) {
      case _Obj.dropAcid:
      case _Obj.dropBase:
      case _Obj.dropOil:
        // Bulb only; the thin tube is tested separately in [_hits].
        return _bounds(p.x - 0.3, p.x + 0.3, p.y + 2.15, p.y + 3.05, p.z - 0.3, p.z + 0.3).inflate(7);
      case _Obj.lid:
        return _bounds(p.x - 2.1, p.x + 2.1, p.y - 0.1, p.y + 0.1, p.z - 1.6, p.z + 1.6);
      case _Obj.strip1:
      case _Obj.strip2:
        final rot = o == _Obj.strip1 ? s.strip1Rot : s.strip2Rot;
        final hw = rot ? 0.4 : 1.25, hd = rot ? 1.25 : 0.4;
        return _bounds(p.x - hw, p.x + hw, p.y - 0.1, p.y + 0.1, p.z - hd, p.z + hd).inflate(8);
      case _Obj.bowl:
        final r = 1.2 * s.bowlScale;
        return _bounds(p.x - r, p.x + r, p.y, p.y + r, p.z - r, p.z + r);
      case _Obj.stack:
        return _bounds(p.x - 1.25, p.x + 1.25, p.y - 0.2, p.y + 0.2, p.z - 0.4, p.z + 0.4).inflate(4);
      case _Obj.swab1:
      case _Obj.swab2:
        return _bounds(p.x - 1.05, p.x + 1.05, p.y - 0.15, p.y + 0.15, p.z - 0.15, p.z + 0.15).inflate(10);
    }
  }

  /// Top-most object under [at] (the HTML raycaster over `interactables`).
  _Obj? _hitTest(Offset at) {
    final s = _scene;
    final List<_Obj> order;
    if (s.isOnion) {
      final lidOnBench = s.lid.y < 0.15 && s.lidOpen;
      order = [
        _Obj.dropAcid,
        _Obj.dropBase,
        if (!lidOnBench) _Obj.lid,
        if (s.stripsVisible) ...[_Obj.strip2, _Obj.strip1],
        _Obj.bowl,
        _Obj.stack,
        if (lidOnBench) _Obj.lid,
      ];
    } else {
      order = [_Obj.dropOil, _Obj.dropAcid, _Obj.dropBase, _Obj.swab2, _Obj.swab1];
    }
    for (final o in order) {
      if (s.posOf(o) == null) continue;
      if (_hits(o, at)) return o;
    }
    return null;
  }

  bool _hits(_Obj o, Offset at) {
    if (_hitRect(o).contains(at)) return true;
    final d = _scene.droppers[o];
    if (d == null) return false;
    // Dropper glass tube (y + 0.2 .. y + 2.2).
    final p = d.pos;
    final top = _proj(p.x, p.y + 2.2, p.z), bot = _proj(p.x, p.y + 0.2, p.z);
    final w = 0.1 * _unit * _k(p.y + 1.2, p.z) + 9;
    return Rect.fromLTRB(math.min(top.dx, bot.dx) - w, top.dy, math.max(top.dx, bot.dx) + w, bot.dy + 6)
        .contains(at);
  }

  bool _canGrabAt(Offset local) {
    if (!_canInteract) return false;
    final hit = _hitTest(local);
    return hit != null && _scene.draggable.contains(hit);
  }

  // ------------------------------------------------------ interaction

  /// HTML `onPointerDown` for clicks. A click on a draggable object picks
  /// it up and puts it straight back down, exactly like the HTML.
  void _onTapUp(TapUpDetails d) {
    if (!_canInteract) return;
    final hit = _hitTest(d.localPosition);
    if (hit == null) return;
    final s = _scene;
    if (s.droppers.containsKey(hit)) {
      _Audio.play(_Sound.click);
      _handleDropper(hit);
    } else if (s.draggable.contains(hit)) {
      _grab(hit, d.localPosition);
      _release();
    } else if (hit == _Obj.lid) {
      _Audio.play(_Sound.click);
      _handleLid();
    } else if (hit == _Obj.strip1 || hit == _Obj.strip2) {
      _Audio.play(_Sound.click);
      _handleStrip(hit);
    } else if (hit == _Obj.swab1 || hit == _Obj.swab2) {
      _Audio.play(_Sound.click);
      _handleSwab(hit);
    }
  }

  void _onPanStart(DragStartDetails d) {
    if (!_canInteract) return;
    final hit = _hitTest(d.localPosition);
    if (hit == null || !_scene.draggable.contains(hit)) return;
    _grab(hit, d.localPosition);
  }

  /// Picks an object up: lifts it 2 units (200 ms, Quadratic.Out).
  void _grab(_Obj o, Offset at) {
    _Audio.play(_Sound.pickup);
    final p = _scene.posOf(o)!;
    final (px, pz) = _unproject(at);
    _grabDx = p.x - px;
    _grabDz = p.z - pz;
    _grabY = p.y;
    _scene.dragging = o;
    _scene.airborne = o;
    final y0 = p.y;
    _liftTween = _add(_Tw(0.2, Curves.easeOutQuad, (v) => p.y = y0 + 2.0 * v, null, 0));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final o = _scene.dragging;
    if (o == null) return;
    final p = _scene.posOf(o)!;
    final (px, pz) = _unproject(d.localPosition);
    p.x = (px + _grabDx).clamp(-8.5, 8.5);
    p.z = (pz + _grabDz).clamp(-4.5, 6.8);
  }

  /// HTML `onPointerUp`: lowers the object (200 ms, Quadratic.In), then
  /// `evaluateDrop`.
  void _release() {
    final o = _scene.dragging;
    if (o == null) return;
    _scene.dragging = null;
    if (_liftTween != null) _tweens.remove(_liftTween);
    _liftTween = null;
    _Audio.play(_Sound.drop);
    final s = _scene;
    final p = s.posOf(o)!;
    final overContainer = s.isOnion &&
        (p.x - s.containerPos.x).abs() < 2 &&
        (p.z - s.containerPos.z).abs() < 1.5;
    final rest = overContainer ? math.max(_grabY, s.restY(o)) : s.restY(o);
    final from = p.y;
    final gen = _gen;
    _tween(200, Curves.easeInQuad, (v) => p.y = from + (rest - from) * v, onDone: () {
      if (gen != _gen) return;
      s.airborne = null;
      _evaluateDrop(o);
    });
  }

  /// HTML `evaluateDrop(obj)`: snaps objects released within 5 units of
  /// their target.
  void _evaluateDrop(_Obj o) {
    final s = _scene;
    final p = s.posOf(o)!;
    double dist(_V3 t) => math.sqrt(math.pow(p.x - t.x, 2) + math.pow(p.z - t.z, 2));
    var relevant = false, placed = false;
    if (s.isOnion) {
      if (s.step == 0) {
        if (o == _Obj.bowl) {
          relevant = true;
          if (dist(s.containerPos) < 5) {
            p.set(s.containerPos.x - 0.9, 0.02, s.containerPos.z - 0.4);
            s.bowlScale = 0.8;
            s.draggable.remove(o);
            s.onionsIn = placed = true;
            _lab.showToast(_t('toastOnionsIn'));
          }
        }
        if (o == _Obj.stack) {
          relevant = true;
          if (dist(s.containerPos) < 5) {
            p.set(s.containerPos.x + 0.4, 0.22, s.containerPos.z + 0.9);
            s.draggable.remove(o);
            s.stripsIn = placed = true;
            _lab.showToast(_t('toastStripsIn'));
          }
        }
        _checkStep();
      } else if (s.step == 1 && s.lidOpen) {
        if (o == _Obj.strip1 || o == _Obj.strip2) {
          relevant = true;
          if (dist(s.tilePos) < 5) {
            final first = o == _Obj.strip1;
            p.set(s.tilePos.x + (first ? -0.8 : 0.8), 0.125, s.tilePos.z);
            s.draggable.remove(o);
            if (first) {
              s.strip1Rot = s.strip1OnTile = true;
            } else {
              s.strip2Rot = s.strip2OnTile = true;
            }
            placed = true;
            _lab.showToast(_t(first ? 'toastStrip1Placed' : 'toastStrip2Placed'));
          }
        }
      }
    } else if (s.step == 0) {
      if (o == _Obj.swab1 || o == _Obj.swab2) {
        relevant = true;
        if (dist(s.dishPos) < 5) {
          final first = o == _Obj.swab1;
          p.set(s.dishPos.x, 0.3, s.dishPos.z + (first ? -0.5 : 0.5));
          s.draggable.remove(o);
          if (first) {
            s.swab1In = true;
          } else {
            s.swab2In = true;
          }
          placed = true;
          _lab.showToast(_t(first ? 'toastSwab1Placed' : 'toastSwab2Placed'));
        }
      }
      _checkStep();
    }
    if (relevant && !placed) _lab.showToast(_t('toastCloser'), isError: true);
    if (mounted) setState(() {});
  }

  /// HTML `handleLidClick`.
  void _handleLid() {
    final s = _scene;
    if (!s.isOnion || _lidBusy) return;
    final c = s.containerPos;
    if (s.step == 0 && s.onionsIn && s.stripsIn && !s.closed) {
      _lidBusy = true;
      _moveTo(s.lid, _V3(c.x, 2.6, c.z), 500, Curves.easeOutCubic, onDone: () {
        s.closed = true;
        s.lidOpen = false;
        _Audio.play(_Sound.pop);
        _later(1000, _triggerTimelapse);
      });
    } else if (s.step == 1 && s.infused && !s.lidOpen) {
      _lidBusy = true;
      _moveTo(s.lid, _V3(c.x - 4.0, 0.1, c.z), 500, Curves.easeOutCubic, onDone: () {
        _lidBusy = false;
        s.lidOpen = true;
        s.strip1.set(c.x, 1.2, c.z - 0.3);
        s.strip2.set(c.x, 1.25, c.z + 0.3);
        s.stripsVisible = true;
        s.strip1Color = s.strip2Color = const Color(0xFFB45309);
        s.draggable.addAll([_Obj.strip1, _Obj.strip2]);
        _lab.showToast(_t('toastContainerOpened'));
      });
    }
  }

  /// HTML `triggerTimelapse`: the "Overnight" screen for 3 s.
  void _triggerTimelapse() {
    setState(() => _overnight = true);
    _spin.repeat();
    _Audio.play(_Sound.magic);
    _later(3000, () {
      _spin.stop();
      setState(() {
        _overnight = false;
        _lidBusy = false;
        _scene.infused = true;
      });
      _lab.showToast(_t('toastOvernightPassed'));
      _nextStep();
    });
  }

  /// HTML `handleStripClick`.
  void _handleStrip(_Obj o) {
    final s = _scene;
    if (!s.isOnion) return;
    if (s.step == 1) {
      if (!s.strip1OnTile || !s.strip2OnTile) {
        _lab.showToast(_t('toastPlaceBothStrips'), isError: true);
        return;
      }
      _smell(o, _SmellType.onion);
      if (o == _Obj.strip1) s.strip1Smelled = true;
      if (o == _Obj.strip2) s.strip2Smelled = true;
      if (s.strip1Smelled && s.strip2Smelled && !s.step1Done) {
        s.step1Done = true;
        _later(2500, _checkStep);
      }
    } else if (s.step == 2 && s.strip1Acid && o == _Obj.strip1) {
      _smell(o, _SmellType.onion);
      if (!s.strip1AcidSmelled) {
        s.strip1AcidSmelled = true;
        _later(3000, _checkStep);
      }
    } else if (s.step == 3 && s.strip2Base && o == _Obj.strip2) {
      _smell(o, _SmellType.none);
      if (!s.strip2BaseSmelled) {
        s.strip2BaseSmelled = true;
        _later(2500, _checkStep);
      }
    }
  }

  /// HTML `handleSwabClick`.
  void _handleSwab(_Obj o) {
    final s = _scene;
    if (s.isOnion) return;
    void advanceLater(VoidCallback fn) {
      if (_advancePending) return;
      _advancePending = true;
      _later(2500, () {
        _advancePending = false;
        fn();
      });
    }

    if (s.step == 1 && s.swab1Oiled && s.swab2Oiled) {
      _smell(o, _SmellType.clove);
      if (o == _Obj.swab1) s.swab1OiledCheck = true;
      if (o == _Obj.swab2) s.swab2OiledCheck = true;
      if (s.swab1OiledCheck && s.swab2OiledCheck) advanceLater(_checkStep);
    } else if (s.step == 2 && s.swab1Acid && o == _Obj.swab1) {
      _smell(o, _SmellType.clove);
      advanceLater(_nextStep);
    } else if (s.step == 3 && s.swab2Base && o == _Obj.swab2) {
      _smell(o, _SmellType.none);
      advanceLater(_nextStep);
    }
  }

  /// HTML `showSmellCloud`: smoke for a smell, a wisp when it is destroyed.
  void _smell(_Obj o, _SmellType type) {
    _Audio.play(type == _SmellType.none ? _Sound.wrong : _Sound.success);
    _scene.smells.add(_Smell(o, type, _scene.time));
  }

  /// HTML `checkStepCompletion`.
  void _checkStep() {
    final s = _scene;
    if (s.isOnion) {
      if (s.step == 0 && s.closed) return _nextStep();
      if (s.step == 1 && s.strip1Smelled && s.strip2Smelled) return _nextStep();
      if (s.step == 2 && s.strip1AcidSmelled) return _nextStep();
      if (s.step == 3 && s.strip2BaseSmelled) return _nextStep();
    } else {
      if (s.step == 0 && s.swab1In && s.swab2In) return _nextStep();
      if (s.step == 1 && s.swab1OiledCheck && s.swab2OiledCheck) return _nextStep();
    }
  }

  /// HTML `nextStep` + `updateCurrentStepUI` (the last step shows the
  /// Validate button with the success chime).
  void _nextStep() {
    if (_scene.step >= _stepCount - 1) return;
    setState(() => _scene.step++);
    if (_scene.step == _stepCount - 1) _Audio.play(_Sound.success);
  }

  // ---------------------------------------------------------- droppers

  /// HTML `handleDropperClick`.
  void _handleDropper(_Obj id) {
    if (_dropperBusy) return;
    final s = _scene;
    if (s.isOnion) {
      if (s.step == 2 && id == _Obj.dropAcid) {
        _runDropper(id, s.strip1.copy(), const Color(0xFF5C2E16), () {
          s.strip1Acid = true;
          s.strip1Color = const Color(0xFF944230);
          _lab.showToast(_t('toastTamarindAdded'));
        });
      } else if (s.step == 3 && id == _Obj.dropBase) {
        _runDropper(id, s.strip2.copy(), const Color(0xFFFFFFFF), () {
          s.strip2Base = true;
          s.strip2Color = const Color(0xFFE2E8F0);
          _lab.showToast(_t('toastBakingSodaAdded'));
        });
      } else {
        _lab.showToast(_t('toastWrongDropper'), isError: true);
      }
      return;
    }
    // Precision targets: the +x cotton tip of each swab.
    _V3 tip(_V3 p) => _V3(p.x + 0.9, p.y, p.z);
    if (s.step == 1 && id == _Obj.dropOil) {
      _runMultiDropper(id, [tip(s.swab1), tip(s.swab2)], const Color(0xFFD97706), () {
        s.swab1Oiled = s.swab2Oiled = true;
        s.swab1Marker = s.swab2Marker = true;
        _lab.showToast(_t('toastCloveOilAdded'));
      });
    } else if (s.step == 2 && id == _Obj.dropAcid) {
      _runDropper(id, tip(s.swab1), const Color(0xFFFEF08A), () {
        s.swab1Acid = true;
        _lab.showToast(_t('toastLemonAdded'));
      });
    } else if (s.step == 3 && id == _Obj.dropBase) {
      _runDropper(id, tip(s.swab2), const Color(0xFFFFFFFF), () {
        s.swab2Base = true;
        _lab.showToast(_t('toastLimeWaterAdded'));
      });
    } else {
      _lab.showToast(_t('toastWrongDropper'), isError: true);
    }
  }

  /// Bulb squeeze: scale to (1.1, 0.7) and back, 150 ms each way.
  void _squeeze(_Dropper d, VoidCallback onDone) {
    _tween(300, Curves.linear, (v) => d.squeeze = v < 0.5 ? v * 2 : (1 - v) * 2, onDone: () {
      d.squeeze = 0;
      onDone();
    });
  }

  /// One drop falls from the dropper tip onto [target] (200 ms).
  void _fallDrop(_Dropper d, _V3 target, Color color, VoidCallback onDone) {
    final drop = _Droplet(_V3(d.pos.x, d.pos.y + 0.15, d.pos.z), color);
    _scene.droplets.add(drop);
    final y0 = drop.pos.y;
    _tween(200, Curves.linear, (v) => drop.pos.y = y0 + (target.y + 0.1 - y0) * v, onDone: () {
      _scene.droplets.remove(drop);
      _Audio.play(_Sound.pop);
      onDone();
    });
  }

  /// HTML `runDropperSequence`: move over the target (500 ms), squeeze,
  /// release a drop, return home (200 ms delay + 500 ms).
  void _runDropper(_Obj id, _V3 target, Color color, VoidCallback onComplete) {
    final d = _scene.droppers[id]!;
    final orig = d.pos.copy();
    final dropColor = color == const Color(0xFFFFFFFF) ? const Color(0xFFE2E8F0) : color;
    setState(() => _dropperBusy = true);
    _moveTo(d.pos, _V3(target.x, target.y + 2, target.z), 500, Curves.easeInOutQuad, onDone: () {
      d.showLiquid = true;
      _squeeze(d, () {
        _fallDrop(d, target, dropColor, () {
          d.showLiquid = false;
          _moveTo(d.pos, orig, 500, Curves.easeInOutQuad, delayMs: 200, onDone: () {
            setState(() => _dropperBusy = false);
            onComplete();
          });
        });
      });
    });
  }

  /// HTML `runMultiDropperSequence`: one drop on each target in turn.
  void _runMultiDropper(_Obj id, List<_V3> targets, Color color, VoidCallback onComplete) {
    final d = _scene.droppers[id]!;
    final orig = d.pos.copy();
    setState(() => _dropperBusy = true);
    void moveAndDrop(_V3 t, VoidCallback next) {
      _moveTo(d.pos, _V3(t.x, t.y + 2, t.z), 400, Curves.easeInOutQuad, onDone: () {
        d.showLiquid = true;
        _squeeze(d, () => _fallDrop(d, t, color, next));
      });
    }

    moveAndDrop(targets[0], () {
      moveAndDrop(targets[1], () {
        _moveTo(d.pos, orig, 500, Curves.easeInOutQuad, delayMs: 200, onDone: () {
          d.showLiquid = false;
          setState(() => _dropperBusy = false);
          onComplete();
        });
      });
    });
  }

  // -------------------------------------------------------- conclusion

  /// HTML `validateInvestigation`: after 1 s the sidebar opens and the
  /// "Observation & Analysis" popup shows the conclusion.
  void _validate() {
    final scenario = _scene.scenario;
    setState(() {
      _validated = true;
      _scene.step = _stepCount; // every step done
    });
    _lab.completedScenarios.add(scenario);
    final allDone = _lab.completedScenarios.length >= _scenarios['en']!.length;
    _later(1000, () {
      _lab.openSidebar();
      _lab.showPopup(() => LabPopupContent(
            title: _t('lblObs'),
            icon: Icons.lightbulb,
            extra: _conclusionText(_t('conclusion_${scenario + 1}')),
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

  /// Conclusion text with the HTML `**bold**` parts highlighted in yellow.
  Widget _conclusionText(String text) {
    return Builder(builder: (context) {
      final s = context.labScale;
      final f = s * _lab.fontScale.clamp(0.9, 1.4);
      final p = _Theme.of(_lab.isDark);
      final parts = text.split('**');
      return Text.rich(
        TextSpan(children: [
          for (var i = 0; i < parts.length; i++)
            if (parts[i].isNotEmpty)
              TextSpan(
                text: parts[i],
                style: i.isOdd
                    ? TextStyle(
                        color: _Colors.zslYellow,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5 * f,
                        letterSpacing: 0.4,
                      )
                    : null,
              ),
        ]),
        style: TextStyle(color: p.text, fontSize: 13 * f, fontWeight: FontWeight.w500, height: 1.55),
      );
    });
  }

  bool get _canValidate => _scene.step == _stepCount - 1 && !_validated;

  LabAction get _validateAction => LabAction(
        label: _t('btnValidate'),
        icon: Icons.check_circle,
        highlight: true,
        onTap: _validate,
      );

  List<LabAction> _actions() => _canValidate ? [_validateAction] : const [];

  /// HTML `#canvas-validate-btn`: pulsing button above the HUD (the
  /// floating mission card carries it while the sidebar is collapsed).
  Widget _validateOverlay(double s) {
    final pad = MediaQuery.paddingOf(context);
    return Positioned(
      left: 12,
      right: 60 + pad.right,
      bottom: 74 * s + pad.bottom,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: LabActionButton(action: _validateAction, scale: s * 1.1, expand: false),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
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
          actions: _actions(),
          onEnterLab: _onEnter,
          onReset: _fullReset,
          overlays: [
            if (_canValidate && _lab.isSidebarOpen && _lab.isLabActive) _validateOverlay(s),
            _overnightOverlay(s),
          ],
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
                painter: _OlfPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  text: {
                    for (final k in const [
                      'lblWhiteTile',
                      'lblPlasticContainer',
                      'lblChoppedOnions',
                      'lblClothStrips',
                      'lblTamarindWater',
                      'lblBakingSoda',
                      'lblPetriDish',
                      'lblSwabBox',
                      'lblCloveOil',
                      'lblLemonJuice',
                      'lblLimeWater',
                      'smellDestroyed',
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

  /// HTML `#timelapse-overlay`: spinning clock + "OVERNIGHT" (1 s fades).
  Widget _overnightOverlay(double s) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_overnight,
        child: AnimatedOpacity(
          opacity: _overnight ? 1 : 0,
          duration: const Duration(milliseconds: 1000),
          child: ColoredBox(
            color: const Color(0xF20F172A),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(16 * s),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _spin,
                        child: Icon(Icons.history, size: 76 * s, color: _Colors.zslYellow),
                      ),
                      SizedBox(height: 18 * s),
                      Text(
                        _t('lblOvernight').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: _lab.lang == LabLang.en ? 5 : 0,
                          shadows: const [Shadow(color: Color(0x99000000), blurRadius: 18)],
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
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Investigating Olfactory Indicators',
    'app_subtitle': 'Class 7 • Acids, Bases and Salts',
    'scen_1': 'Scenario 1: The Onion Smell Test',
    'scen_2': 'Scenario 2: The Clove Oil Challenge',
    'btnValidate': 'Validate Investigation',
    'lblOvernight': 'Overnight',
    'lblObs': 'Observation & Analysis',
    'smellDestroyed': 'Odour Destroyed',
    'lblWhiteTile': 'White Tile',
    'lblPlasticContainer': 'Plastic Container',
    'lblChoppedOnions': 'Chopped Onions',
    'lblClothStrips': 'Clean Cloth Strips',
    'lblTamarindWater': 'Tamarind Water',
    'lblBakingSoda': 'Baking Soda Solution',
    'lblPetriDish': 'Petri Dish',
    'lblSwabBox': 'Cotton Swabs Box',
    'lblCloveOil': 'Clove Oil',
    'lblLemonJuice': 'Lemon Juice',
    'lblLimeWater': 'Lime Water',
    'toastTamarindAdded': 'Tamarind Water added. CLICK strip to check odour.',
    'toastBakingSodaAdded': 'Baking Soda added. CLICK strip to check odour.',
    'toastWrongDropper': 'Not the correct step or dropper.',
    'toastCloveOilAdded': 'Clove oil added. CLICK BOTH swabs to smell.',
    'toastLemonAdded': 'Lemon Juice added. CLICK swab to smell.',
    'toastLimeWaterAdded': 'Lime Water added. CLICK swab to smell.',
    'toastOnionsIn': 'Onions placed inside container.',
    'toastStripsIn': 'Strips placed inside container.',
    'toastStrip1Placed': 'Strip 1 placed. CLICK to verify smell.',
    'toastStrip2Placed': 'Strip 2 placed. CLICK to verify smell.',
    'toastSwab1Placed': 'Swab 1 placed.',
    'toastSwab2Placed': 'Swab 2 placed.',
    'toastContainerOpened': 'Container opened. DRAG 2 infused strips out to the white tile.',
    'toastPlaceBothStrips': 'Place BOTH strips on the tile first!',
    'toastOvernightPassed': 'Overnight passed. Strips are infused. CLICK lid to open.',
    'toastCameraLocked': 'Camera Locked',
    'toastCameraUnlocked': 'Camera Unlocked',
    'toastPanMode': 'Pan Mode Enabled',
    'toastPanOff': 'Pan Mode Disabled',
    'toastCloser': 'Move it closer to the target area.',
    'conclusion_1':
        'The characteristic smell of onion is **destroyed by bases** (Baking Soda Solution), but **retained in acids** (Tamarind Water). Therefore, onion acts as an olfactory indicator.',
    'conclusion_2':
        'Conclusion: Clove oil also acts as an olfactory indicator. Its smell is destroyed by basic solutions but not by acidic solutions.',
  },
  'hi': {
    'app_title': 'घ्राण सूचकों की जांच (Olfactory Indicators)',
    'app_subtitle': 'कक्षा 7 • अम्ल, क्षारक और लवण',
    'scen_1': 'परिदृश्य 1: प्याज की गंध का परीक्षण',
    'scen_2': 'परिदृश्य 2: लौंग के तेल की चुनौती',
    'btnValidate': 'जांच का सत्यापन करें',
    'lblOvernight': 'रात भर (Overnight)',
    'lblObs': 'अवलोकन और विश्लेषण',
    'smellDestroyed': 'गंध नष्ट हो गई',
    'lblWhiteTile': 'सफ़ेद टाइल',
    'lblPlasticContainer': 'प्लास्टिक कंटेनर',
    'lblChoppedOnions': 'कटे हुए प्याज',
    'lblClothStrips': 'साफ़ कपड़े की पट्टियाँ',
    'lblTamarindWater': 'इमली का पानी',
    'lblBakingSoda': 'बेकिंग सोडा का घोल',
    'lblPetriDish': 'पेट्री डिश',
    'lblSwabBox': 'कॉटन स्वैब बॉक्स',
    'lblCloveOil': 'लौंग का तेल',
    'lblLemonJuice': 'नींबू का रस',
    'lblLimeWater': 'चूने का पानी',
    'toastTamarindAdded': 'इमली का पानी डाला गया। गंध की जांच के लिए पट्टी पर क्लिक करें।',
    'toastBakingSodaAdded': 'बेकिंग सोडा डाला गया। गंध की जांच के लिए पट्टी पर क्लिक करें।',
    'toastWrongDropper': 'सही चरण या ड्रॉपर नहीं है।',
    'toastCloveOilAdded': 'लौंग का तेल डाला गया। सूंघने के लिए दोनों स्वैब पर क्लिक करें।',
    'toastLemonAdded': 'नींबू का रस डाला गया। सूंघने के लिए स्वैब पर क्लिक करें।',
    'toastLimeWaterAdded': 'चूने का पानी डाला गया। सूंघने के लिए स्वैब पर क्लिक करें।',
    'toastOnionsIn': 'प्याज को कंटेनर के अंदर रखा गया।',
    'toastStripsIn': 'पट्टियों को कंटेनर के अंदर रखा गया।',
    'toastStrip1Placed': 'पट्टी 1 रखी गई। गंध की जांच के लिए क्लिक करें।',
    'toastStrip2Placed': 'पट्टी 2 रखी गई। गंध की जांच के लिए क्लिक करें।',
    'toastSwab1Placed': 'स्वैब 1 रखा गया।',
    'toastSwab2Placed': 'स्वैब 2 रखा गया।',
    'toastContainerOpened': 'कंटेनर खुल गया। 2 इन्फ्यूज्ड पट्टियों को सफेद टाइल पर खींचें (DRAG)।',
    'toastPlaceBothStrips': 'पहले दोनों पट्टियों को टाइल पर रखें!',
    'toastOvernightPassed': 'रात बीत गई। पट्टियाँ इन्फ्यूज हो गई हैं। खोलने के लिए ढक्कन पर क्लिक करें।',
    'toastCameraLocked': 'कैमरा लॉक हो गया',
    'toastCameraUnlocked': 'कैमरा अनलॉक हो गया',
    'toastPanMode': 'पैन मोड सक्षम',
    'toastPanOff': 'पैन मोड अक्षम',
    'toastCloser': 'इसे लक्ष्य क्षेत्र के करीब ले जाएं।',
    'conclusion_1':
        'प्याज की विशिष्ट गंध **क्षारकों द्वारा नष्ट हो जाती है** (बेकिंग सोडा का घोल), लेकिन **अम्लों में बनी रहती है** (इमली का पानी)। इसलिए, प्याज एक घ्राण सूचक के रूप में कार्य करता है।',
    'conclusion_2':
        'निष्कर्ष: लौंग का तेल भी एक घ्राण सूचक के रूप में कार्य करता है। इसकी गंध क्षारीय विलयनों द्वारा नष्ट हो जाती है लेकिन अम्लीय विलयनों द्वारा नहीं।',
  },
};

// ========================================================== SCENARIOS
// `action` is the HTML step `hud` text; `observation` is the step's
// teacher-board (`sidebar`) text, whose prefix is the `concept`.

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          "To investigate if onion can act as an olfactory indicator by testing its smell with an acidic and a basic solution.",
      steps: [
        LabStep(
          concept: 'Preparation',
          action:
              'DRAG the bowl of finely chopped onions into the large container. DRAG the stack of clean cotton cloth strips into the same container. CLICK the lid to close the container tightly.',
          observation:
              "Preparation: Onion pieces are mixed with cloth strips in a closed container to allow the strips to absorb the onion's characteristic odour.",
        ),
        LabStep(
          concept: 'Initial Check',
          action:
              'CLICK the lid to open the container. DRAG two onion-infused strips out of the container and DROP them onto the white tile. CLICK BOTH to verify the initial smell.',
          observation:
              'Initial Check: The strips have successfully absorbed the onion odour. This establishes our baseline smell for the indicator.',
        ),
        LabStep(
          concept: 'Acid Test',
          action:
              "CLICK the dropper from the beaker labeled 'Tamarind Water' to add drops onto the first cloth strip. CLICK the strip to check its odour.",
          observation:
              'Acid Test: Tamarind water (an acidic solution) is applied. Observation: The characteristic odour of the onion remains unaffected by the acid.',
        ),
        LabStep(
          concept: 'Base Test',
          action:
              "CLICK the dropper from the beaker labeled 'Baking Soda Solution' to add drops onto the second cloth strip. CLICK the strip to check its odour.",
          observation:
              'Base Test: Baking soda solution (a basic solution) is applied. Observation: The characteristic odour of the onion is completely destroyed.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the results and validate your investigation.',
          observation:
              "Conclusion: Since the onion's smell changes (is destroyed) in a basic medium but remains in an acidic medium, it acts as an olfactory indicator.",
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To determine if clove oil can also be used as an olfactory indicator by testing it with an acid and a base.',
      steps: [
        LabStep(
          concept: 'Preparation',
          action: 'DRAG two clean cotton swabs from the box and DROP them onto the petri dish.',
          observation: 'Preparation: Clean cotton swabs are arranged for testing the clove oil.',
        ),
        LabStep(
          concept: 'Initial Check',
          action:
              "CLICK the dropper from the bottle labeled 'Clove Oil' to add one drop onto each cotton swab. CLICK each swab to check the initial odour.",
          observation:
              'Initial Check: Clove oil is applied to the swabs. The strong, characteristic odour of clove is noted as the baseline.',
        ),
        LabStep(
          concept: 'Acid Test',
          action:
              "CLICK the dropper from the beaker labeled 'Lemon Juice' to add a few drops onto the first cotton swab. CLICK the swab to check its odour.",
          observation:
              'Acid Test: Lemon juice (an acidic solution) is added to the first swab. Observation: The characteristic odour of clove oil persists.',
        ),
        LabStep(
          concept: 'Base Test',
          action:
              "CLICK the dropper from the test tube labeled 'Lime Water' to add a few drops onto the second cotton swab. CLICK the swab to check its odour.",
          observation:
              'Base Test: Lime water (a basic solution) is added to the second swab. Observation: The characteristic odour of clove oil is destroyed.',
        ),
        LabStep(
          concept: 'Conclusion',
          action:
              'Compare the results. The clove oil smell is unaffected by the acidic lemon juice but is destroyed by the basic lime water.',
          observation:
              'Conclusion: Similar to onion, clove oil retains its smell in acids but loses it in bases, confirming it as an olfactory indicator.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह जांचने के लिए कि क्या प्याज एक घ्राण सूचक के रूप में कार्य कर सकता है, इसे अम्लीय और क्षारीय विलयन के साथ परीक्षण करके।',
      steps: [
        LabStep(
          concept: 'तैयारी',
          action:
              'कटे हुए प्याज के कटोरे को बड़े कंटेनर में खींचें (DRAG)। साफ सूती कपड़े की पट्टियों को उसी कंटेनर में खींचें। कंटेनर को कसकर बंद करने के लिए ढक्कन पर क्लिक (CLICK) करें।',
          observation:
              'तैयारी: प्याज के टुकड़ों को एक बंद कंटेनर में कपड़े की पट्टियों के साथ मिलाया जाता है ताकि पट्टियाँ प्याज की गंध को सोख सकें।',
        ),
        LabStep(
          concept: 'प्रारंभिक जांच',
          action:
              'कंटेनर खोलने के लिए ढक्कन पर क्लिक (CLICK) करें। प्याज की गंध वाली दो पट्टियों को कंटेनर से बाहर खींचें (DRAG) और उन्हें सफेद टाइल पर छोड़ दें (DROP)। प्रारंभिक गंध को सत्यापित करने के लिए दोनों पर क्लिक (CLICK) करें।',
          observation:
              'प्रारंभिक जांच: पट्टियों ने प्याज की गंध को सफलतापूर्वक सोख लिया है। यह सूचक के लिए हमारी प्रारंभिक गंध निर्धारित करता है।',
        ),
        LabStep(
          concept: 'अम्ल परीक्षण',
          action:
              "'Tamarind Water' (इमली का पानी) वाले बीकर से ड्रॉपर पर क्लिक (CLICK) करके पहली कपड़े की पट्टी पर कुछ बूंदें डालें। इसकी गंध की जांच के लिए पट्टी पर क्लिक (CLICK) करें।",
          observation:
              'अम्ल परीक्षण: इमली का पानी (एक अम्लीय विलयन) डाला गया है। अवलोकन: प्याज की गंध पर अम्ल का कोई प्रभाव नहीं पड़ता है।',
        ),
        LabStep(
          concept: 'क्षारक परीक्षण',
          action:
              "'Baking Soda Solution' (बेकिंग सोडा का घोल) वाले बीकर से ड्रॉपर पर क्लिक (CLICK) करके दूसरी कपड़े की पट्टी पर कुछ बूंदें डालें। इसकी गंध की जांच के लिए पट्टी पर क्लिक (CLICK) करें।",
          observation:
              'क्षारक परीक्षण: बेकिंग सोडा का घोल (एक क्षारीय विलयन) डाला गया है। अवलोकन: प्याज की गंध पूरी तरह से नष्ट हो जाती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'परिणामों का अवलोकन करें और अपनी जांच का सत्यापन करें।',
          observation:
              'निष्कर्ष: चूँकि प्याज की गंध क्षारीय माध्यम में बदल जाती है (नष्ट हो जाती है) लेकिन अम्लीय माध्यम में बनी रहती है, यह एक घ्राण सूचक के रूप में कार्य करता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह निर्धारित करने के लिए कि क्या लौंग के तेल का उपयोग एक घ्राण सूचक के रूप में किया जा सकता है, इसे अम्ल और क्षारक के साथ परीक्षण करके।',
      steps: [
        LabStep(
          concept: 'तैयारी',
          action: 'बॉक्स से दो साफ कॉटन स्वैब खींचें (DRAG) और उन्हें पेट्री डिश पर छोड़ दें (DROP)।',
          observation: 'तैयारी: लौंग के तेल का परीक्षण करने के लिए साफ कॉटन स्वैब रखे गए हैं।',
        ),
        LabStep(
          concept: 'प्रारंभिक जांच',
          action:
              "'Clove Oil' (लौंग का तेल) वाली बोतल से ड्रॉपर पर क्लिक (CLICK) करके प्रत्येक कॉटन स्वैब पर एक बूंद डालें। प्रारंभिक गंध की जांच के लिए प्रत्येक स्वैब पर क्लिक (CLICK) करें।",
          observation:
              'प्रारंभिक जांच: स्वैब पर लौंग का तेल लगाया गया है। लौंग की तेज गंध को आधार रेखा के रूप में नोट किया जाता है।',
        ),
        LabStep(
          concept: 'अम्ल परीक्षण',
          action:
              "'Lemon Juice' (नींबू का रस) वाले बीकर से ड्रॉपर पर क्लिक (CLICK) करके पहले कॉटन स्वैब पर कुछ बूंदें डालें। इसकी गंध की जांच के लिए स्वैब पर क्लिक (CLICK) करें।",
          observation:
              'अम्ल परीक्षण: नींबू का रस (एक अम्लीय विलयन) पहले स्वैब में जोड़ा गया है। अवलोकन: लौंग के तेल की गंध बनी रहती है।',
        ),
        LabStep(
          concept: 'क्षारक परीक्षण',
          action:
              "'Lime Water' (चूने का पानी) वाली टेस्ट ट्यूब से ड्रॉपर पर क्लिक (CLICK) करके दूसरे कॉटन स्वैब पर कुछ बूंदें डालें। इसकी गंध की जांच के लिए स्वैब पर क्लिक (CLICK) करें।",
          observation:
              'क्षारक परीक्षण: चूने का पानी (एक क्षारीय विलयन) दूसरे स्वैब में जोड़ा गया है। अवलोकन: लौंग के तेल की गंध नष्ट हो जाती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action:
              'परिणामों की तुलना करें। लौंग के तेल की गंध अम्लीय नींबू के रस से अप्रभावित रहती है लेकिन क्षारीय चूने के पानी द्वारा नष्ट हो जाती है।',
          observation:
              'निष्कर्ष: प्याज के समान, लौंग का तेल अम्लों में अपनी गंध बरकरार रखता है लेकिन क्षारकों में इसे खो देता है, जो एक घ्राण सूचक के रूप में इसकी पुष्टि करता है।',
        ),
      ],
    ),
  ],
};

// ======================================================= SCENE MODEL
//
// The Three.js scene (camera at (0, 20, 26) looking at the origin) is drawn
// as a 2.5D perspective illustration. World units are the HTML units:
// x to the right, y up, z towards the viewer; the bench top is y = 0.

const Size _design = Size(1000, 560);
const double _unit = 56; // design px per world unit at the origin
const double _cx = 500, _cy = 284;
const double _camD = 32.8; // camera distance to the origin
const double _sinP = 0.6097, _cosP = 0.7926; // camera elevation 37.6°

/// Perspective scale factor of a world point.
double _k(double y, double z) => _camD / (_camD - (y * _sinP + z * _cosP));

/// Projects a world point to design coordinates.
Offset _proj(double x, double y, double z) {
  final k = _k(y, z);
  return Offset(_cx + x * _unit * k, _cy + (z * _sinP - y * _cosP) * _unit * k);
}

/// Inverse of [_proj] on the horizontal plane at height [y] (the HTML drag
/// plane / raycast). Returns (x, z).
(double, double) _unproject(Offset p, {double y = 0}) {
  final v = (p.dy - _cy) / _unit;
  final z = (v * (_camD - y * _sinP) + _camD * y * _cosP) / (_camD * _sinP + v * _cosP);
  final x = (p.dx - _cx) / (_unit * _k(y, z));
  return (x, z);
}

/// Screen bounds of a world-space axis aligned box.
Rect _bounds(double x0, double x1, double y0, double y1, double z0, double z1) {
  var l = double.infinity, t = double.infinity, r = -double.infinity, b = -double.infinity;
  for (final x in [x0, x1]) {
    for (final y in [y0, y1]) {
      for (final z in [z0, z1]) {
        final p = _proj(x, y, z);
        l = math.min(l, p.dx);
        r = math.max(r, p.dx);
        t = math.min(t, p.dy);
        b = math.max(b, p.dy);
      }
    }
  }
  return Rect.fromLTRB(l, t, r, b);
}

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
}

/// Every interactive object of both scenarios.
enum _Obj { lid, bowl, stack, strip1, strip2, swab1, swab2, dropAcid, dropBase, dropOil }

/// Smell effects: onion / clove smoke clouds, or the "Odour Destroyed" wisp.
enum _SmellType { onion, clove, none }

class _Smell {
  _Smell(this.obj, this.type, this.start);
  final _Obj obj;
  final _SmellType type;
  final double start;
  double get duration => type == _SmellType.none ? 1.5 : 4.5;
}

class _Droplet {
  _Droplet(this.pos, this.color);
  final _V3 pos;
  final Color color;
}

class _Dropper {
  _Dropper(this.home, this.liquid, this.rimY, {this.behindVessel = false, this.inGlass = false})
      : pos = home.copy();
  final _V3 home;
  final _V3 pos;
  final Color liquid;

  /// Rim height of the vessel the dropper rests in.
  final double rimY;

  /// True when the vessel is opaque / narrow (oil bottle, test tube), so the
  /// dropper is drawn before it while resting inside.
  final bool behindVessel;

  /// True when the dropper rests in a glass vessel (beaker / test tube): the
  /// vessel draws it between its back and front glass.
  final bool inGlass;
  bool showLiquid = false;

  /// 0..1 bulb squeeze (HTML bulb scale y 1 -> 0.7, x/z 1 -> 1.1).
  double squeeze = 0;
  bool get atHome => (pos.x - home.x).abs() < 1e-3 && (pos.y - home.y).abs() < 1e-3 && (pos.z - home.z).abs() < 1e-3;
}

class _Bit {
  _Bit(this.x, this.y, this.z, this.rot, this.light);
  final double x, y, z, rot;
  final bool light;
}

/// Mutable scene model shared by the State (logic) and the painter.
class _OlfScene {
  int scenario = 0;

  /// HTML `currentStepIndex` (0-based).
  int step = 0;
  double time = 0;

  /// Time the current scenario was built (labels fade in after it).
  double builtAt = 0;

  // ---- Scenario 1 (onion) ----
  final _V3 containerPos = _V3(-1.5, 0, -2);
  final _V3 tilePos = _V3(0, 0.05, 3.5);
  final _V3 lid = _V3(-5.5, 0.1, -2);
  final _V3 bowl = _V3(-6.3, 0.2, -2);
  double bowlScale = 1;
  final _V3 stack = _V3(2.5, 0.2, -2);
  final _V3 strip1 = _V3(-1.5, 0.2, -2.3);
  final _V3 strip2 = _V3(-1.5, 0.25, -1.7);
  bool stripsVisible = false;
  bool strip1Rot = false, strip2Rot = false;
  Color strip1Color = const Color(0xFFF1F5F9);
  Color strip2Color = const Color(0xFFF1F5F9);
  final List<_Bit> onionBits = [];

  // HTML state.s1
  bool onionsIn = false, stripsIn = false, closed = false, infused = false, lidOpen = true;
  bool strip1OnTile = false, strip2OnTile = false;
  bool strip1Smelled = false, strip2Smelled = false;
  bool strip1Acid = false, strip1AcidSmelled = false;
  bool strip2Base = false, strip2BaseSmelled = false, step1Done = false;

  // ---- Scenario 2 (clove oil) ----
  final _V3 dishPos = _V3(0, 0.1, 3.5);
  final _V3 swabBoxPos = _V3(-3.5, 0, -2);
  final _V3 bottlePos = _V3(3.5, 0, -2);
  final _V3 swab1 = _V3(-1.5, 0.15, -1.5);
  final _V3 swab2 = _V3(-1.5, 0.15, -2.5);
  bool swab1Marker = false, swab2Marker = false;

  // HTML state.s2
  bool swab1In = false, swab2In = false, swab1Oiled = false, swab2Oiled = false;
  bool swab1OiledCheck = false, swab2OiledCheck = false;
  bool swab1Acid = false, swab2Base = false;

  // ---- Shared ----
  final _V3 acidVessel = _V3(-4, 0, 3.5);
  final _V3 baseVessel = _V3(4, 0, 3.5);
  final Map<_Obj, _Dropper> droppers = {};
  final List<_Droplet> droplets = [];
  final List<_Smell> smells = [];
  final Set<_Obj> draggable = {};

  /// Object currently held by the pointer (drawn on top).
  _Obj? dragging;

  /// Object being lifted or lowered (also drawn on top).
  _Obj? airborne;

  bool get isOnion => scenario == 0;

  _V3? posOf(_Obj o) => switch (o) {
        _Obj.lid => lid,
        _Obj.bowl => bowl,
        _Obj.stack => stack,
        _Obj.strip1 => strip1,
        _Obj.strip2 => strip2,
        _Obj.swab1 => swab1,
        _Obj.swab2 => swab2,
        _ => droppers[o]?.pos,
      };

  /// Resting height of a draggable object when dropped on the bench.
  double restY(_Obj o) => switch (o) {
        _Obj.bowl => onLid(bowl) ? 0.2 : 0,
        _Obj.stack => 0.2,
        _Obj.strip1 || _Obj.strip2 => 0.03,
        _ => 0.15,
      };

  /// Resets everything for [scenarioIndex] (HTML buildScenario1/2).
  void build(int scenarioIndex, double now) {
    scenario = scenarioIndex;
    step = 0;
    builtAt = now;
    dragging = null;
    airborne = null;
    droplets.clear();
    smells.clear();
    droppers.clear();
    draggable.clear();

    lid.set(-5.5, 0.1, -2);
    bowl.set(-6.3, 0.2, -2);
    bowlScale = 1;
    stack.set(2.5, 0.2, -2);
    strip1.set(-1.5, 0.2, -2.3);
    strip2.set(-1.5, 0.25, -1.7);
    stripsVisible = false;
    strip1Rot = strip2Rot = false;
    strip1Color = strip2Color = const Color(0xFFF1F5F9);
    onionsIn = stripsIn = closed = infused = false;
    lidOpen = true;
    strip1OnTile = strip2OnTile = strip1Smelled = strip2Smelled = false;
    strip1Acid = strip1AcidSmelled = strip2Base = strip2BaseSmelled = step1Done = false;

    swab1.set(-1.5, 0.15, -1.5);
    swab2.set(-1.5, 0.15, -2.5);
    swab1Marker = swab2Marker = false;
    swab1In = swab2In = swab1Oiled = swab2Oiled = false;
    swab1OiledCheck = swab2OiledCheck = swab1Acid = swab2Base = false;

    if (scenarioIndex == 0) {
      draggable.addAll([_Obj.bowl, _Obj.stack]);
      droppers[_Obj.dropAcid] =
          _Dropper(_V3(-4, 0.9, 3.5), const Color(0xFF5C2E16), 2.5, inGlass: true);
      droppers[_Obj.dropBase] =
          _Dropper(_V3(4, 0.9, 3.5), const Color(0xFFFFFFFF), 2.5, inGlass: true);
      final rnd = math.Random(7);
      onionBits
        ..clear()
        ..addAll(List.generate(
          30,
          (_) => _Bit(
            (rnd.nextDouble() - 0.5) * 1.2,
            0.2 + rnd.nextDouble() * 0.4,
            (rnd.nextDouble() - 0.5) * 1.2,
            rnd.nextDouble() * math.pi,
            rnd.nextDouble() > 0.5,
          ),
        ));
    } else {
      draggable.addAll([_Obj.swab1, _Obj.swab2]);
      droppers[_Obj.dropOil] =
          _Dropper(_V3(3.5, 0.3, -2), const Color(0xFFD97706), 2.2, behindVessel: true);
      droppers[_Obj.dropAcid] =
          _Dropper(_V3(-4, 0.9, 3.5), const Color(0xFFFEF08A), 2.5, inGlass: true);
      droppers[_Obj.dropBase] =
          _Dropper(_V3(4, 0.9, 3.5), const Color(0xFFF8FAFC), 3.0, inGlass: true);
    }
  }

  /// True when [p] is over the open lid lying on the bench.
  bool onLid(_V3 p) =>
      lidOpen && lid.y < 0.15 && (p.x - lid.x).abs() < 2.1 && (p.z - lid.z).abs() < 1.6;

  /// True when a free object rests inside the plastic container.
  bool insideContainer(_V3 p) =>
      (p.x - containerPos.x).abs() < 2 && (p.z - containerPos.z).abs() < 1.5 && p.y < 2.4;
}

// ===================================================== DRAW HELPERS

Path _quad(Offset a, Offset b, Offset c, Offset d) => Path()
  ..moveTo(a.dx, a.dy)
  ..lineTo(b.dx, b.dy)
  ..lineTo(c.dx, c.dy)
  ..lineTo(d.dx, d.dy)
  ..close();

Color _a(Color c, double opacity) => c.withValues(alpha: c.a * opacity);

/// Axis aligned box (Three.js BoxGeometry) centred at (x, y, z). Draws the
/// faces the camera can see: the side facing x = 0, the front and the top.
void _box(
  Canvas c,
  double x,
  double y,
  double z,
  double w,
  double h,
  double d,
  Color color, {
  double opacity = 1,
  Color? edge,
  double edgeWidth = 1.2,
  double topShade = 0.16,
}) {
  final x0 = x - w / 2, x1 = x + w / 2, y0 = y - h / 2, y1 = y + h / 2, z0 = z - d / 2, z1 = z + d / 2;
  final faces = <Path>[];
  if (x1 < 0) {
    final f = _quad(_proj(x1, y0, z0), _proj(x1, y0, z1), _proj(x1, y1, z1), _proj(x1, y1, z0));
    c.drawPath(f, Paint()..color = _a(labShade(color, -0.12), opacity));
    faces.add(f);
  } else if (x0 > 0) {
    final f = _quad(_proj(x0, y0, z0), _proj(x0, y0, z1), _proj(x0, y1, z1), _proj(x0, y1, z0));
    c.drawPath(f, Paint()..color = _a(labShade(color, -0.24), opacity));
    faces.add(f);
  }
  final fa = _proj(x0, y1, z1), fb = _proj(x1, y1, z1), fc = _proj(x1, y0, z1), fd = _proj(x0, y0, z1);
  final front = _quad(fa, fb, fc, fd);
  c.drawPath(
    front,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_a(labShade(color, -0.02), opacity), _a(labShade(color, -0.18), opacity)],
      ).createShader(Rect.fromPoints(fa, fc).inflate(0.5)),
  );
  faces.add(front);
  final top = _quad(_proj(x0, y1, z0), _proj(x1, y1, z0), fb, fa);
  c.drawPath(top, Paint()..color = _a(labShade(color, topShade), opacity));
  faces.add(top);
  if (edge != null) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = edgeWidth
      ..strokeJoin = StrokeJoin.round
      ..color = _a(edge, opacity);
    for (final f in faces) {
      c.drawPath(f, p);
    }
  }
}

/// Vertical (optionally tapered) cylinder standing on (x, y0, z).
void _cyl(
  Canvas c,
  double x,
  double y0,
  double z,
  double rBot,
  double rTop,
  double h,
  Color color, {
  double opacity = 1,
  bool top = true,
  Color? topColor,
  double sx = 1,
}) {
  final b = _proj(x, y0, z), t = _proj(x, y0 + h, z);
  final rbx = rBot * _unit * _k(y0, z) * sx, rtx = rTop * _unit * _k(y0 + h, z) * sx;
  final rby = rbx * _sinP, rty = rtx * _sinP;
  final body = Path()
    ..moveTo(t.dx - rtx, t.dy)
    ..lineTo(b.dx - rbx, b.dy)
    ..arcTo(Rect.fromCenter(center: b, width: rbx * 2, height: rby * 2), math.pi, -math.pi, false)
    ..lineTo(t.dx + rtx, t.dy)
    ..arcTo(Rect.fromCenter(center: t, width: rtx * 2, height: rty * 2), 0, -math.pi, false)
    ..close();
  final bounds = body.getBounds();
  c.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        _a(labShade(color, -0.35), opacity),
        _a(labShade(color, 0.22), opacity),
        _a(color, opacity),
        _a(labShade(color, -0.45), opacity),
      ], stops: const [0, 0.3, 0.62, 1]).createShader(bounds),
  );
  if (top && rtx > 0.3) {
    c.drawOval(
      Rect.fromCenter(center: t, width: rtx * 2, height: rty * 2),
      Paint()..color = _a(topColor ?? labShade(color, 0.22), opacity),
    );
  }
}

/// Ellipse of a horizontal circle (radius r) at world (x, y, z).
Rect _ring(double x, double y, double z, double r) {
  final p = _proj(x, y, z);
  final rx = r * _unit * _k(y, z);
  return Rect.fromCenter(center: p, width: rx * 2, height: rx * 2 * _sinP);
}

/// Transparent glass vessel (beaker / test tube) with liquid.
void _glassVessel(
  Canvas c,
  double x,
  double z,
  double r,
  double h,
  Color liquid,
  double liquidH, {
  double liquidOpacity = 0.92,
  VoidCallback? inside,
}) {
  final bottom = _ring(x, 0, z, r), topR = _ring(x, h, z, r);
  // Back half of the rim and the faint glass body.
  final body = Path()
    ..moveTo(topR.left, topR.center.dy)
    ..lineTo(bottom.left, bottom.center.dy)
    ..arcTo(bottom, math.pi, -math.pi, false)
    ..lineTo(topR.right, topR.center.dy)
    ..arcTo(topR, 0, -math.pi, false)
    ..close();
  c.drawPath(body, Paint()..color = const Color(0x1AFFFFFF));
  c.drawArc(
    topR,
    math.pi,
    math.pi,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x8094A3B8),
  );
  inside?.call();
  if (liquidH > 0) {
    _cyl(c, x, 0.03, z, r * 0.94, r * 0.94, liquidH, liquid,
        opacity: liquidOpacity, topColor: labShade(liquid, 0.18));
    // Meniscus highlight.
    final m = _ring(x, liquidH + 0.03, z, r * 0.94);
    c.drawOval(
      m,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..color = const Color(0xCC64748B);
  c.drawLine(Offset(topR.left, topR.center.dy), Offset(bottom.left, bottom.center.dy), edge);
  c.drawLine(Offset(topR.right, topR.center.dy), Offset(bottom.right, bottom.center.dy), edge);
  c.drawArc(bottom, 0, math.pi, false, edge);
  c.drawArc(topR, 0, math.pi, false, edge..color = const Color(0xE694A3B8));
  // Glass highlight streaks.
  final hl = Paint()
    ..strokeWidth = math.max(2, topR.width * 0.06)
    ..strokeCap = StrokeCap.round
    ..color = Colors.white.withValues(alpha: 0.28);
  final hx = topR.left + topR.width * 0.2;
  c.drawLine(Offset(hx, topR.center.dy + topR.height * 0.6), Offset(hx, bottom.center.dy + bottom.height * 0.2), hl);
  c.drawLine(
    Offset(topR.right - topR.width * 0.14, topR.center.dy + topR.height * 0.7),
    Offset(topR.right - topR.width * 0.14, topR.center.dy + (bottom.center.dy - topR.center.dy) * 0.45),
    hl..color = Colors.white.withValues(alpha: 0.14),
  );
}

/// Soft contact shadow of an object with footprint radius [r] standing at
/// height [y] above the bench (light from the upper right front).
void _shadow(Canvas c, double x, double z, double r, {double y = 0, double opacity = 0.32}) {
  final off = y * 0.25;
  final e = _ring(x - 0.15 - off, 0.001, z - 0.1 - off, r * (1 + y * 0.08));
  labGroundShadow(c, e.center, e.width * 1.05, e.height * 1.1,
      opacity: opacity / (1 + y * 0.35));
}

// ============================================================ PAINTER

class _OlfPainter extends CustomPainter {
  _OlfPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.text,
  }) : super(repaint: repaint);

  final _OlfScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;

  /// Localised canvas strings, keyed like the i18n table.
  final Map<String, String> text;

  static const Color _wood = Color(0xFFC49B71);
  static const Color _cotton = Color(0xFFF1F5F9);

  @override
  void paint(Canvas canvas, Size size) {
    _paintBench(canvas, size);
    if (scene.isOnion) {
      _paintOnionScene(canvas);
    } else {
      _paintCloveScene(canvas);
    }
    for (final d in scene.droplets) {
      final p = _proj(d.pos.x, d.pos.y, d.pos.z);
      labSphere(canvas, p, 0.12 * _unit * _k(d.pos.y, d.pos.z), d.color, highlight: 0.6);
    }
    if (showLabels) _paintLabels(canvas);
    for (final s in scene.smells) {
      _paintSmell(canvas, s);
    }
  }

  // ------------------------------------------------------------ bench

  void _paintBench(Canvas c, Size size) {
    final bleed = labBleed(size);
    final fog = isDark ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1);
    // Back wall above the far edge of the 100 x 40 bench.
    final backEdge = _proj(0, 0, -20).dy;
    c.drawRect(bleed, Paint()..color = fog);
    final benchRect = Rect.fromLTRB(bleed.left, backEdge, bleed.right, bleed.bottom);
    c.drawRect(
      benchRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB08860), _wood, Color(0xFFD1AC85)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromLTRB(0, backEdge, 0, 700)),
    );
    // Plank seams converge towards the vanishing point.
    final seam = Paint()
      ..strokeWidth = 1.2
      ..color = const Color(0x40704A2A);
    for (var x = -31.0; x <= 31; x += 2.6) {
      c.drawLine(_proj(x, 0, -20), _proj(x, 0, 14), seam);
    }
    final grain = Paint()
      ..strokeWidth = 0.8
      ..color = const Color(0x1A5C3A1E);
    for (var z = -19.0; z <= 12; z += 0.9) {
      final a = _proj(-40, 0, z), b = _proj(40, 0, z);
      c.drawLine(a, b, grain);
    }
    // Front edge of the bench.
    final fy = _proj(0, 0, 20).dy;
    if (fy < bleed.bottom) {
      c.drawRect(Rect.fromLTRB(bleed.left, fy, bleed.right, bleed.bottom),
          Paint()..color = labShade(_wood, -0.35));
    }
    // Fog (Three.js Fog 10..60) darkens the far bench.
    c.drawRect(
      Rect.fromLTRB(bleed.left, backEdge - 2, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fog, fog.withValues(alpha: 0.72), fog.withValues(alpha: 0.28), fog.withValues(alpha: 0.12)],
          stops: const [0, 0.25, 0.7, 1],
        ).createShader(Rect.fromLTRB(0, backEdge, 0, 560)),
    );
    // Soft key light pool on the work area.
    final pool = Rect.fromCenter(center: const Offset(500, 330), width: 1100, height: 560);
    c.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: isDark ? 0.10 : 0.16),
          Colors.white.withValues(alpha: 0),
        ]).createShader(pool),
    );
  }

  // ------------------------------------------------------ onion scene

  void _paintOnionScene(Canvas c) {
    final s = scene;
    // Flat items lying on the bench first.
    _paintTile(c);
    final lidResting = s.lid.y < 0.15 && s.lidOpen;
    if (lidResting) _paintLid(c);

    final items = <(double, void Function())>[];
    items.add((s.containerPos.z, () => _paintContainer(c, lidResting)));
    for (final o in [_Obj.bowl, _Obj.stack, _Obj.strip1, _Obj.strip2]) {
      if (o == s.dragging || o == s.airborne) continue;
      if ((o == _Obj.strip1 || o == _Obj.strip2) && !s.stripsVisible) continue;
      final p = s.posOf(o)!;
      if (_inContainerGroup(o)) continue;
      if (_onTile(o)) continue;
      items.add((p.z + p.y * 0.001, () => _paintObj(c, o)));
    }
    items.add((s.acidVessel.z, () => _glassVessel(c, -4, 3.5, 1.2, 2.5, const Color(0xFF5C2E16), 2.0,
        inside: _homeDropper(c, _Obj.dropAcid))));
    items.add((s.baseVessel.z, () => _glassVessel(c, 4, 3.5, 1.2, 2.5, const Color(0xFFF8FAFC), 2.0,
        inside: _homeDropper(c, _Obj.dropBase))));
    _addDroppers(c, items);
    items.sort((a, b) => a.$1.compareTo(b.$1));
    for (final i in items) {
      i.$2();
    }
    for (final o in [s.airborne, s.dragging]) {
      if (o != null && o != _Obj.lid && _isVisible(o)) _paintObj(c, o, lifted: true);
    }
  }

  bool _inContainerGroup(_Obj o) {
    final s = scene;
    if (o == s.dragging || o == s.airborne) return false;
    if (o == _Obj.bowl) return s.onionsIn || s.insideContainer(s.bowl);
    if (o == _Obj.stack) return s.stripsIn || s.insideContainer(s.stack);
    if (o == _Obj.strip1) return s.stripsVisible && !s.strip1OnTile && s.insideContainer(s.strip1);
    if (o == _Obj.strip2) return s.stripsVisible && !s.strip2OnTile && s.insideContainer(s.strip2);
    return false;
  }

  bool _onTile(_Obj o) {
    final s = scene;
    if (o == s.dragging || o == s.airborne) return false;
    return (o == _Obj.strip1 && s.strip1OnTile) || (o == _Obj.strip2 && s.strip2OnTile);
  }

  void _paintTile(Canvas c) {
    final t = scene.tilePos;
    _shadow(c, t.x, t.z, 2.8, opacity: 0.25);
    _box(c, t.x, t.y, t.z, 5, 0.1, 4, const Color(0xFFF8FAFC),
        edge: const Color(0xFF64748B), topShade: 0.0);
    // Glazed reflection.
    final a = _proj(t.x - 2.3, 0.101, t.z - 1.8), b = _proj(t.x + 1.0, 0.101, t.z - 1.8);
    final d = _proj(t.x - 2.3, 0.101, t.z - 0.2);
    c.drawPath(
      _quad(a, b, Offset.lerp(b, d, 0.5)!, d),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    for (final o in [_Obj.strip1, _Obj.strip2]) {
      if (_onTile(o)) _paintObj(c, o);
    }
  }

  void _paintLid(Canvas c) {
    final l = scene.lid;
    if (l.y < 0.15) _shadow(c, l.x, l.z, 2.3, opacity: 0.22);
    _box(c, l.x, l.y, l.z, 4.2, 0.2, 3.2, const Color(0xFF0284C7),
        opacity: 0.72, edge: const Color(0xFF0EA5E9), edgeWidth: 1.6);
    // Moulded handle ridge.
    final h0 = _proj(l.x - 0.9, l.y + 0.1, l.z), h1 = _proj(l.x + 0.9, l.y + 0.1, l.z);
    c.drawLine(
      h0,
      h1,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xCC38BDF8),
    );
  }

  /// Hollow transparent box (HTML createHollowBox) with its contents and
  /// (when closed or moving) the lid.
  void _paintContainer(Canvas c, bool lidResting) {
    final s = scene;
    final p = s.containerPos;
    final x0 = p.x - 2, x1 = p.x + 2, y0 = p.y, y1 = p.y + 2.5, z0 = p.z - 1.5, z1 = p.z + 1.5;
    Offset q(double x, double y, double z) => _proj(x, y, z);
    _shadow(c, p.x, p.z, 2.6, opacity: 0.2);
    const plastic = Color(0xFF475569);
    final wall = Paint()..color = plastic.withValues(alpha: 0.24);
    c.drawPath(_quad(q(x0, y0, z0), q(x1, y0, z0), q(x1, y0, z1), q(x0, y0, z1)),
        Paint()..color = plastic.withValues(alpha: 0.3));
    c.drawPath(_quad(q(x0, y0, z0), q(x1, y0, z0), q(x1, y1, z0), q(x0, y1, z0)), wall);
    c.drawPath(_quad(q(x0, y0, z0), q(x0, y0, z1), q(x0, y1, z1), q(x0, y1, z0)), wall);
    c.drawPath(_quad(q(x1, y0, z0), q(x1, y0, z1), q(x1, y1, z1), q(x1, y1, z0)), wall);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xE60284C7);
    final back = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x990284C7);
    c.drawPath(_quad(q(x0, y0, z0), q(x1, y0, z0), q(x1, y1, z0), q(x0, y1, z0)), back);
    c.drawLine(q(x0, y0, z0), q(x0, y0, z1), back);
    c.drawLine(q(x1, y0, z0), q(x1, y0, z1), back);

    // Contents, lowest first.
    final inside = [_Obj.bowl, _Obj.stack, _Obj.strip1, _Obj.strip2].where(_inContainerGroup).toList()
      ..sort((a, b) => s.posOf(a)!.y.compareTo(s.posOf(b)!.y));
    for (final o in inside) {
      _paintObj(c, o);
    }

    c.drawPath(_quad(q(x0, y0, z1), q(x1, y0, z1), q(x1, y1, z1), q(x0, y1, z1)),
        Paint()..color = plastic.withValues(alpha: 0.2));
    c.drawPath(_quad(q(x0, y0, z1), q(x1, y0, z1), q(x1, y1, z1), q(x0, y1, z1)), edge);
    c.drawLine(q(x0, y1, z0), q(x0, y1, z1), edge);
    c.drawLine(q(x1, y1, z0), q(x1, y1, z1), edge);
    // Plastic sheen.
    c.drawLine(
      q(x0 + 0.35, y1 - 0.3, z1),
      q(x0 + 0.35, y0 + 0.4, z1),
      Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.12),
    );
    if (!lidResting) _paintLid(c);
  }

  bool _isVisible(_Obj o) =>
      (o != _Obj.strip1 && o != _Obj.strip2) || scene.stripsVisible;

  void _paintObj(Canvas c, _Obj o, {bool lifted = false}) {
    final s = scene;
    final p = s.posOf(o)!;
    switch (o) {
      case _Obj.bowl:
        _paintBowl(c, p, s.bowlScale, lifted);
      case _Obj.stack:
        if (lifted || !s.insideContainer(p)) _shadow(c, p.x, p.z, 1.3, y: p.y - 0.2, opacity: 0.25);
        _box(c, p.x, p.y, p.z, 2.5, 0.4, 0.8, _cotton, edge: const Color(0x55475569));
        // Stacked strip layers.
        final layer = Paint()
          ..strokeWidth = 1
          ..color = const Color(0x6694A3B8);
        for (var i = 1; i <= 3; i++) {
          final y = p.y - 0.2 + i * 0.1;
          c.drawLine(_proj(p.x - 1.25, y, p.z + 0.4), _proj(p.x + 1.25, y, p.z + 0.4), layer);
        }
      case _Obj.strip1:
      case _Obj.strip2:
        final rot = o == _Obj.strip1 ? s.strip1Rot : s.strip2Rot;
        final color = o == _Obj.strip1 ? s.strip1Color : s.strip2Color;
        final infused = s.stripsVisible;
        if (lifted || p.y < 0.5) _shadow(c, p.x, p.z, rot ? 0.6 : 1.2, y: p.y, opacity: 0.22);
        _box(c, p.x, p.y, p.z, rot ? 0.8 : 2.5, 0.05, rot ? 2.5 : 0.8, color,
            edge: infused ? const Color(0xFF78350F) : null, edgeWidth: 1, topShade: 0.06);
        // Cloth weave texture.
        final weave = Paint()
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.2).withValues(alpha: 0.5);
        for (var i = 1; i < 6; i++) {
          final f = -0.5 + i / 6;
          if (rot) {
            c.drawLine(_proj(p.x - 0.4, p.y + 0.026, p.z + f * 2.5), _proj(p.x + 0.4, p.y + 0.026, p.z + f * 2.5), weave);
          } else {
            c.drawLine(_proj(p.x + f * 2.5, p.y + 0.026, p.z - 0.4), _proj(p.x + f * 2.5, p.y + 0.026, p.z + 0.4), weave);
          }
        }
      case _Obj.swab1:
      case _Obj.swab2:
        _paintSwab(c, p, o == _Obj.swab1 ? s.swab1Marker : s.swab2Marker, lifted);
      default:
        break;
    }
  }

  void _paintBowl(Canvas c, _V3 p, double sc, bool lifted) {
    final r = 1.2 * sc;
    const green = Color(0xFF22C55E);
    if (lifted || !scene.insideContainer(p)) _shadow(c, p.x, p.z, r * 0.9, y: p.y, opacity: 0.3);
    // Foot.
    _cyl(c, p.x, p.y, p.z, 0.6 * sc, 0.6 * sc, 0.2 * sc, labShade(green, -0.15));
    final rim = _ring(p.x, p.y + r, p.z, r);
    final rc = rim.center;
    final rx = rim.width / 2;
    final body = Path()
      ..moveTo(rim.left, rc.dy)
      ..arcTo(Rect.fromCircle(center: rc, radius: rx), math.pi, -math.pi, false)
      ..arcTo(rim, 0, math.pi, false)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.6),
          radius: 1.0,
          colors: [labShade(green, 0.35), green, labShade(green, -0.45)],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: rc, radius: rx)),
    );
    // Inside of the bowl.
    c.drawOval(
      rim,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(green, -0.5), labShade(green, -0.1)],
        ).createShader(rim),
    );
    // Chopped onion pieces (purple 0x800080 / plum 0xdda0dd).
    c.save();
    c.clipPath(Path()..addOval(rim.deflate(1)));
    final bits = [...scene.onionBits]..sort((a, b) => a.z.compareTo(b.z));
    for (final b in bits) {
      final bp = _proj(p.x + b.x * sc, p.y + (b.y + 0.42) * sc, p.z + b.z * sc);
      final bs = 0.17 * sc * _unit * _k(p.y, p.z);
      c.save();
      c.translate(bp.dx, bp.dy);
      c.rotate(b.rot);
      final rect = Rect.fromCenter(center: Offset.zero, width: bs * 1.5, height: bs);
      c.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(bs * 0.25)),
        Paint()..color = b.light ? const Color(0xFFDDA0DD) : const Color(0xFF800080),
      );
      c.drawLine(
        rect.topLeft + Offset(bs * 0.2, bs * 0.25),
        rect.topRight + Offset(-bs * 0.2, bs * 0.25),
        Paint()
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.45),
      );
      c.restore();
    }
    c.restore();
    c.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = labShade(green, 0.3),
    );
  }

  void _paintSwab(Canvas c, _V3 p, bool marker, bool lifted) {
    if (lifted || p.y < 0.4) _shadow(c, p.x, p.z, 0.9, y: p.y, opacity: 0.25);
    final a = _proj(p.x - 0.9, p.y, p.z), b = _proj(p.x + 0.9, p.y, p.z);
    final k = _k(p.y, p.z);
    c.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 0.08 * _unit * k
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD2B48C),
    );
    c.drawLine(
      a.translate(0, -0.02 * _unit * k),
      b.translate(0, -0.02 * _unit * k),
      Paint()
        ..strokeWidth = 0.025 * _unit * k
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    final tr = 0.15 * _unit * k;
    labSphere(c, a, tr * 1.15, _cotton, highlight: 0.2, shade: 0.3);
    labSphere(c, b, tr * 1.15, _cotton, highlight: 0.2, shade: 0.3);
    if (marker) labSphere(c, b, 0.16 * _unit * k * 1.1, const Color(0xFF8B5A2B), highlight: 0.35);
  }

  void _addDroppers(Canvas c, List<(double, void Function())> items) {
    for (final e in scene.droppers.entries) {
      final d = e.value;
      final home = d.atHome;
      if (home && d.inGlass) continue; // drawn inside its vessel
      var key = d.pos.z + d.pos.y * 0.001 + 0.0005;
      if (home && d.behindVessel) key = d.home.z - 0.0005;
      items.add((key, () => _paintDropper(c, d)));
    }
  }

  /// Draw callback for a dropper resting inside its glass vessel.
  VoidCallback? _homeDropper(Canvas c, _Obj id) {
    final d = scene.droppers[id];
    if (d == null || !d.inGlass || !d.atHome) return null;
    return () => _paintDropper(c, d);
  }

  void _paintDropper(Canvas c, _Dropper d) {
    final p = d.pos;
    final k = _k(p.y + 1.2, p.z);
    // Glass tube (r 0.08 -> 0.05, from y + 0.2 to y + 2.2).
    final tTop = _proj(p.x, p.y + 2.2, p.z), tBot = _proj(p.x, p.y + 0.2, p.z);
    final wTop = 0.08 * _unit * k, wBot = 0.05 * _unit * k;
    final tube = Path()
      ..moveTo(tTop.dx - wTop, tTop.dy)
      ..lineTo(tBot.dx - wBot, tBot.dy)
      ..quadraticBezierTo(tBot.dx, tBot.dy + wBot * 1.5, tBot.dx + wBot, tBot.dy)
      ..lineTo(tTop.dx + wTop, tTop.dy)
      ..close();
    c.drawPath(tube, Paint()..color = const Color(0x55E2E8F0));
    if (d.showLiquid) {
      final l0 = _proj(p.x, p.y + 1.5, p.z), l1 = _proj(p.x, p.y + 0.3, p.z);
      c.drawPath(
        Path()
          ..moveTo(l0.dx - wTop * 0.75, l0.dy)
          ..lineTo(l1.dx - wBot * 0.75, l1.dy)
          ..lineTo(l1.dx + wBot * 0.75, l1.dy)
          ..lineTo(l0.dx + wTop * 0.75, l0.dy)
          ..close(),
        Paint()..color = labShade(d.liquid, d.liquid.computeLuminance() > 0.8 ? -0.12 : 0),
      );
    }
    c.drawPath(
      tube,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0xCCCBD5E1),
    );
    // Rubber bulb (scale y 1 -> 0.7, x 1 -> 1.1 when squeezed).
    final sy = 1 - 0.3 * d.squeeze, sx = 1 + 0.1 * d.squeeze;
    final bh = 0.8 * sy;
    final by0 = p.y + 2.6 - bh / 2;
    const rubber = Color(0xFF1E293B);
    _cyl(c, p.x, by0, p.z, 0.3, 0.3, bh, rubber, top: false, sx: sx);
    final domeC = _proj(p.x, by0 + bh, p.z);
    final dr = 0.3 * _unit * _k(by0 + bh, p.z) * sx;
    c.drawOval(
      Rect.fromCenter(center: domeC.translate(0, -dr * 0.25), width: dr * 2, height: dr * 1.5),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [labShade(rubber, 0.35), rubber, labShade(rubber, -0.3)],
        ).createShader(Rect.fromCircle(center: domeC, radius: dr)),
    );
    // Collar.
    final collar = _proj(p.x, by0, p.z);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: collar, width: dr * 1.5, height: math.max(3, dr * 0.35)),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF334155),
    );
  }

  // ------------------------------------------------------ clove scene

  void _paintCloveScene(Canvas c) {
    final s = scene;
    _paintDish(c);
    final items = <(double, void Function())>[];
    items.add((s.swabBoxPos.z, () => _paintSwabBox(c)));
    items.add((s.bottlePos.z, () => _paintBottle(c)));
    items.add((s.acidVessel.z, () => _glassVessel(c, -4, 3.5, 1.2, 2.5, const Color(0xFFFEF08A), 2.0,
        liquidOpacity: 0.85, inside: _homeDropper(c, _Obj.dropAcid))));
    items.add((s.baseVessel.z, () => _paintTestTube(c)));
    for (final o in [_Obj.swab1, _Obj.swab2]) {
      if (o == s.dragging || o == s.airborne) continue;
      final onDish = o == _Obj.swab1 ? s.swab1In : s.swab2In;
      if (onDish) continue;
      final p = s.posOf(o)!;
      items.add((p.z + p.y * 0.001, () => _paintObj(c, o)));
    }
    _addDroppers(c, items);
    items.sort((a, b) => a.$1.compareTo(b.$1));
    for (final i in items) {
      i.$2();
    }
    for (final o in [s.airborne, s.dragging]) {
      if (o != null) _paintObj(c, o, lifted: true);
    }
  }

  void _paintDish(Canvas c) {
    final s = scene;
    final d = s.dishPos;
    _shadow(c, d.x, d.z, 2.6, opacity: 0.18);
    final bottom = _ring(d.x, 0, d.z, 2.5), top = _ring(d.x, 0.2, d.z, 2.5);
    c.drawOval(bottom, Paint()..color = const Color(0x40E2E8F0));
    c.drawOval(top, Paint()..color = const Color(0x26FFFFFF));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xCC64748B);
    c.drawArc(top, math.pi, math.pi, false, edge);
    // Swabs resting on the dish sit inside its rim.
    for (final o in [_Obj.swab1, _Obj.swab2]) {
      if (o == s.dragging || o == s.airborne) continue;
      if (o == _Obj.swab1 ? s.swab1In : s.swab2In) _paintObj(c, o);
    }
    c.drawArc(top, 0, math.pi, false, edge);
    c.drawArc(bottom, 0, math.pi, false, edge);
    c.drawLine(Offset(top.left, top.center.dy), Offset(bottom.left, bottom.center.dy), edge);
    c.drawLine(Offset(top.right, top.center.dy), Offset(bottom.right, bottom.center.dy), edge);
    c.drawArc(
      top.deflate(6),
      math.pi * 0.62,
      math.pi * 0.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _paintSwabBox(Canvas c) {
    final b = scene.swabBoxPos;
    const tan = Color(0xFFD2B48C);
    _shadow(c, b.x, b.z, 1.3, opacity: 0.3);
    _box(c, b.x, b.y + 0.05, b.z, 2, 0.1, 1, tan); // bottom
    _box(c, b.x, b.y + 1.25, b.z - 0.45, 2, 2.5, 0.1, tan, edge: const Color(0x55704A2A)); // back
    _box(c, b.x - 0.95, b.y + 1.25, b.z, 0.1, 2.5, 1, tan, edge: const Color(0x55704A2A));
    // Swabs standing in the box.
    for (var i = 0; i < 5; i++) {
      final x = b.x - 0.6 + i * 0.3;
      final s0 = _proj(x, b.y + 0.2, b.z - 0.1), s1 = _proj(x, b.y + 2.2, b.z - 0.1);
      final k = _k(b.y + 1.2, b.z);
      c.drawLine(
        s0,
        s1,
        Paint()
          ..strokeWidth = 0.06 * _unit * k
          ..color = const Color(0xFFFEF08A),
      );
      labSphere(c, s1, 0.1 * _unit * k * 1.2, _cotton, highlight: 0.2, shade: 0.3);
    }
    _box(c, b.x + 0.95, b.y + 1.25, b.z, 0.1, 2.5, 1, tan, edge: const Color(0x55704A2A));
    _box(c, b.x, b.y + 0.75, b.z + 0.45, 2, 1.5, 0.1, tan, edge: const Color(0x55704A2A)); // front
    // White label plane on the front.
    final l = _quad(_proj(b.x - 0.8, b.y + 1.2, b.z + 0.51), _proj(b.x + 0.8, b.y + 1.2, b.z + 0.51),
        _proj(b.x + 0.8, b.y + 0.4, b.z + 0.51), _proj(b.x - 0.8, b.y + 0.4, b.z + 0.51));
    c.drawPath(l, Paint()..color = Colors.white);
    final ink = Paint()
      ..strokeWidth = 1.4
      ..color = const Color(0x8894A3B8);
    for (final y in [0.95, 0.75, 0.6]) {
      c.drawLine(_proj(b.x - 0.6, b.y + y, b.z + 0.52), _proj(b.x + (y == 0.95 ? 0.6 : 0.3), b.y + y, b.z + 0.52), ink);
    }
  }

  void _paintBottle(Canvas c) {
    final b = scene.bottlePos;
    const glass = Color(0xFF451A03);
    _shadow(c, b.x, b.z, 0.9, opacity: 0.35);
    _cyl(c, b.x, 0, b.z, 0.8, 0.8, 1.6, glass, top: false);
    // Label band (front half, y 0.3 .. 1.3).
    final lb = _ring(b.x, 0.3, b.z, 0.81), lt = _ring(b.x, 1.3, b.z, 0.81);
    final band = Path()
      ..moveTo(lt.left, lt.center.dy)
      ..lineTo(lb.left, lb.center.dy)
      ..arcTo(lb, math.pi, -math.pi, false)
      ..lineTo(lt.right, lt.center.dy)
      ..arcTo(lt, 0, math.pi, false)
      ..close();
    c.drawPath(
      band,
      Paint()
        ..shader = const LinearGradient(colors: [
          Color(0xFFC9A57A),
          Color(0xFFFFE4B5),
          Color(0xFFFFE4B5),
          Color(0xFFB8956A),
        ], stops: [0, 0.35, 0.6, 1]).createShader(band.getBounds()),
    );
    // Clove sketch on the label.
    final lc = _proj(b.x, 0.8, b.z + 0.81);
    final ink = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF78350F);
    c.drawLine(lc.translate(0, 9), lc.translate(0, -5), ink);
    for (final a in [-0.9, 0.0, 0.9]) {
      c.drawCircle(lc.translate(math.sin(a) * 5, -7 - math.cos(a) * 4), 2.6, Paint()..color = const Color(0xFF92400E));
    }
    _cyl(c, b.x, 1.6, b.z, 0.8, 0.3, 0.6, glass, topColor: const Color(0xFF2A1002));
    // Glass gloss.
    final g0 = _proj(b.x - 0.5, 1.45, b.z + 0.55), g1 = _proj(b.x - 0.5, 0.2, b.z + 0.55);
    c.drawLine(
      g0,
      g1,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  void _paintTestTube(Canvas c) {
    final t = scene.baseVessel;
    _shadow(c, t.x, t.z, 0.9, opacity: 0.25);
    _box(c, t.x, 0.05, t.z, 1.5, 0.1, 1.5, const Color(0xFF94A3B8), edge: const Color(0x66475569));
    _glassVessel(c, t.x, t.z, 0.4, 3.0, const Color(0xFFF8FAFC), 2.0,
        liquidOpacity: 0.9, inside: _homeDropper(c, _Obj.dropBase));
  }

  // ----------------------------------------------------------- labels

  void _paintLabels(Canvas c) {
    final s = scene;
    final fade = ((s.time - s.builtAt - 0.1) / 0.3).clamp(0.0, 1.0);
    if (fade <= 0) return;
    final labels = <(String, _V3)>[];
    if (s.isOnion) {
      labels.add(('lblWhiteTile', _V3(s.tilePos.x, 0.45, s.tilePos.z - 2.0)));
      labels.add(('lblPlasticContainer', _V3(s.containerPos.x, 4.0, s.containerPos.z)));
      labels.add(('lblChoppedOnions', _V3(s.bowl.x, s.bowl.y + 1.8, s.bowl.z)));
      labels.add(('lblClothStrips', _V3(s.stack.x, s.stack.y + 1.0, s.stack.z)));
      labels.add(('lblTamarindWater', _V3(-4, 2.8, 3.5)));
      labels.add(('lblBakingSoda', _V3(4, 2.8, 3.5)));
    } else {
      labels.add(('lblPetriDish', _V3(s.dishPos.x, 0.6, s.dishPos.z - 2.6)));
      labels.add(('lblSwabBox', _V3(s.swabBoxPos.x, 4.0, s.swabBoxPos.z)));
      labels.add(('lblCloveOil', _V3(s.bottlePos.x, 3.9, s.bottlePos.z)));
      labels.add(('lblLemonJuice', _V3(-4, 2.8, 3.5)));
      labels.add(('lblLimeWater', _V3(4, 2.3, 3.5)));
    }
    labels.sort((a, b) => a.$2.z.compareTo(b.$2.z));
    for (final l in labels) {
      labText(
        c,
        text[l.$1] ?? l.$1,
        _proj(l.$2.x, l.$2.y, l.$2.z),
        size: 15,
        weight: FontWeight.w800,
        color: Colors.white,
        background: const Color(0xF20F172A),
        border: Colors.white.withValues(alpha: 0.15),
        borderWidth: 2,
        radius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        letterSpacing: 0.5,
        opacity: fade,
      );
    }
  }

  // ------------------------------------------------------ smell effects

  static final Path _smoke = Path()
    ..moveTo(50, 190)
    ..cubicTo(20, 170, 0, 130, 30, 100)
    ..cubicTo(60, 70, 20, 40, 45, 5)
    ..cubicTo(70, 30, 90, 70, 60, 100)
    ..cubicTo(30, 130, 80, 170, 50, 190)
    ..close();
  static final Path _smokeVeins = Path()
    ..moveTo(40, 160)
    ..cubicTo(25, 145, 25, 125, 45, 110)
    ..moveTo(60, 90)
    ..cubicTo(75, 75, 75, 55, 55, 40);

  /// Piecewise CSS keyframe interpolation with ease-out per segment.
  static double _kf(double t, List<double> stops, List<double> values) {
    if (t <= stops.first) return values.first;
    for (var i = 1; i < stops.length; i++) {
      if (t <= stops[i]) {
        final u = Curves.easeOut.transform((t - stops[i - 1]) / (stops[i] - stops[i - 1]));
        return values[i - 1] + (values[i] - values[i - 1]) * u;
      }
    }
    return values.last;
  }

  void _paintSmell(Canvas c, _Smell s) {
    final t = (scene.time - s.start) / s.duration;
    if (t < 0 || t >= 1) return;
    final pos = scene.posOf(s.obj);
    if (pos == null) return;
    final a = _proj(pos.x, pos.y + 0.5, pos.z);
    if (s.type == _SmellType.none) {
      _paintWisp(c, a, t);
      return;
    }
    // HTML @keyframes billowingSmoke (4.5 s).
    const stops = [0.0, 0.15, 0.85, 1.0];
    final scale = _kf(t, stops, const [0.2, 1, 1.1, 1.2]);
    final ty = _kf(t, stops, const [1.0, 1.0, 1.05, 1.10]);
    final opacity = _kf(t, stops, const [0.0, 1, 1, 0]);
    const w = 96.0, h = 192.0;
    final fill = s.type == _SmellType.onion ? const Color(0xFFA3E635) : const Color(0xFFD97706);
    final vein = s.type == _SmellType.onion ? const Color(0xFF4D7C0F) : const Color(0xFF78350F);
    c.save();
    c.translate(a.dx, a.dy - (ty - 1) * h);
    c.scale(scale);
    c.rotate(math.sin((scene.time - s.start) * 2.4) * 0.05);
    c.translate(-w / 2, -h);
    c.scale(w / 100, h / 200);
    c.drawPath(
      _smoke.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    c.drawPath(_smoke, Paint()..color = fill.withValues(alpha: 0.9 * opacity));
    c.drawPath(
      _smoke,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.25 * opacity), Colors.white.withValues(alpha: 0)],
        ).createShader(const Rect.fromLTWH(0, 0, 100, 200)),
    );
    c.drawPath(
      _smokeVeins,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = vein.withValues(alpha: opacity),
    );
    c.restore();
  }

  /// HTML `.smell-cloud-none` pill with @keyframes fadeWisp (1.5 s).
  void _paintWisp(Canvas c, Offset a, double t) {
    const stops = [0.0, 0.3, 1.0];
    final scale = _kf(t, stops, const [0.5, 1, 1.1]);
    final ty = _kf(t, stops, const [1.0, 1.1, 1.3]);
    final opacity = _kf(t, stops, const [0.0, 0.9, 0.0]);
    final textColor = isDark ? _Colors.slate300 : _Colors.slate600;
    final tp = TextPainter(
      text: TextSpan(children: [
        TextSpan(
          text: String.fromCharCode(Icons.air.codePoint),
          style: TextStyle(
            fontFamily: Icons.air.fontFamily,
            package: Icons.air.fontPackage,
            fontSize: 24,
            color: textColor,
          ),
        ),
        TextSpan(
          text: '  ${text['smellDestroyed'] ?? ''}',
          style: TextStyle(
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: lang == 'en' ? 1.7 : 0,
            color: textColor,
          ),
        ),
      ]),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + 40, h = tp.height + 22;
    c.save();
    c.translate(a.dx, a.dy - (ty - 1) * h);
    c.scale(scale);
    final rect = Rect.fromLTWH(-w / 2, -h, w, h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));
    c.saveLayer(rect.inflate(20), Paint()..color = Colors.white.withValues(alpha: opacity));
    c.drawRRect(
      rr.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    c.drawRRect(rr, Paint()..color = isDark ? const Color(0xE61E293B) : const Color(0xE6FFFFFF));
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = isDark ? _Colors.slate600 : _Colors.slate300,
    );
    tp.paint(c, Offset(-tp.width / 2, -h + 11));
    c.restore();
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _OlfPainter old) =>
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
