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

/// Class 7 Science • Chapter 5 • Activity 1
/// Physical Changes: Appearance Changes, Substance Remains.
///
/// Native Flutter port of
/// `Cl7S-Ch5-A1-Physical_Changes__Appearance_Changes__Substance_Remains.html`.
///
/// Scenario 1 (The Paper Transformer): drag the paper to fold its corners to
/// the centre, drag again to make a paper boat, then UNFOLD it back into a
/// flat sheet with crease marks (a reversible physical change).
///
/// Scenario 2 (The Balloon's Big Day Out): drag the air pump onto the
/// balloon, click the pump five times to inflate it, RELEASE AIR (the
/// balloon zips around and shrinks back), "Check Again" re-inflates it and a
/// sharp pin pops it into rubber pieces (an irreversible physical change).
class Ch5A1PhysicalChangesAppearanceChangesSubstanceRemainsPage extends StatefulWidget {
  const Ch5A1PhysicalChangesAppearanceChangesSubstanceRemainsPage({super.key});

  @override
  State<Ch5A1PhysicalChangesAppearanceChangesSubstanceRemainsPage> createState() =>
      _Ch5A1PhysicalChangesAppearanceChangesSubstanceRemainsPageState();
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

class _Tween {
  _Tween(this.start, this.dur, this.onT, this.onDone);
  final double start, dur;
  final void Function(double t) onT;
  final VoidCallback? onDone;
}

/// Pan recogniser that only claims pointers starting on a draggable object,
/// so empty-canvas drags still pan the (unlocked) camera.
class _PickPanRecognizer extends PanGestureRecognizer {
  _PickPanRecognizer({required this.canStart});

  bool Function(Offset global) canStart;

  @override
  bool isPointerAllowed(PointerEvent event) => super.isPointerAllowed(event) && canStart(event.position);
}

const _V3 _balloonHome = _V3(1.5, 0, -1);
const _V3 _pumpHome = _V3(-1.5, 0, 1.5);
const _V3 _pinHome = _V3(2, 1, 1);
const double _balloonMin = 0.6;
const double _balloonMax = 1.8;
const int _maxPumpClicks = 5;

class _Ch5A1PhysicalChangesAppearanceChangesSubstanceRemainsPageState
    extends State<Ch5A1PhysicalChangesAppearanceChangesSubstanceRemainsPage>
    with TickerProviderStateMixin {
  // HTML AppState.tools.locked starts false.
  final LabController _lab = LabController(style: _style, camLocked: false);
  final _PcScene _sc = _PcScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();
  final math.Random _rng = math.Random();
  late final Ticker _ticker;
  final List<_Tween> _tweens = [];

  // Drag state (HTML currentDragTarget / startDragPos / startMouse2D).
  String? _dragTarget;
  Offset? _dragStart;
  _V3? _dragPrev;

  // Smooth camera move between scenarios.
  _Cam _camFrom = _camPaper, _camTo = _camPaper;
  double _camStart = -10;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_sc.scenario];
  bool get _s1 => _sc.scenario == 0;
  int get _step => _sc.step;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
    _loadScenario(0, instantCam: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _sc.time).clamp(0.0, 0.1);
    _sc.time = now;

    if (_camStart >= 0) {
      final t = ((now - _camStart) / 1.0).clamp(0.0, 1.0);
      _sc.cam = _Cam.lerp(_camFrom, _camTo, Curves.easeOutCubic.transform(t));
      if (t >= 1) _camStart = -10;
    }

    if (_tweens.isNotEmpty) {
      for (final tw in List.of(_tweens)) {
        if (!_tweens.contains(tw)) continue;
        final t = ((now - tw.start) / tw.dur).clamp(0.0, 1.0);
        tw.onT(t);
        if (t >= 1) {
          _tweens.remove(tw);
          tw.onDone?.call();
        }
      }
    }

    _updatePieces(dt);
    _frame.value = now;
  }

  void _tween(int ms, void Function(double t) onT, [VoidCallback? onDone]) {
    _tweens.add(_Tween(_sc.time, ms / 1000, onT, onDone));
  }

  /// HTML `createRubberParticles` animation: gravity, tumbling, then the
  /// pieces lie flat on the bench (rates scaled from 60 fps).
  void _updatePieces(double dt) {
    final f = dt * 60;
    for (final p in _sc.pieces) {
      if (p.landed) continue;
      if (p.pos.y > 0.02) {
        p.vy -= 0.15 * f;
        p.pos = _V3(p.pos.x + p.vx * 0.016 * f, p.pos.y + p.vy * 0.016 * f, p.pos.z + p.vz * 0.016 * f);
        p.rx += p.drx * f;
        p.ry += p.dry * f;
      } else {
        p
          ..pos = _V3(p.pos.x, 0.01, p.pos.z)
          ..rx = math.pi / 2
          ..ry = 0
          ..landed = true;
      }
    }
  }

  // ------------------------------------------------------------ scenarios

  /// HTML `loadScenario()` + `buildScenario1/2()`.
  void _loadScenario(int index, {bool instantCam = false}) {
    _lab.cancelPending();
    _tweens.clear();
    _dragTarget = null;
    _sc.reset(index);
    final target = index == 0 ? _camPaper : _camBalloon;
    if (instantCam) {
      _sc.cam = target;
      _camStart = -10;
    } else {
      _camFrom = _sc.cam;
      _camTo = target;
      _camStart = _sc.time;
    }
    if (_lab.isLabActive) _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _loadScenario(index);
    });
  }

  /// HTML `resetLab()`: back to scenario 1, camera locked.
  void _fullReset() {
    setState(() {
      _lab.camLocked = true;
      _loadScenario(0, instantCam: true);
    });
  }

  void _setStep(int step) {
    if (!mounted) return;
    setState(() => _sc.step = step);
  }

  // ------------------------------------------------------- scenario 1

  /// HTML `handleInteraction('flatPaper')`.
  void _paperInteraction() {
    if (_sc.animating) return;
    if (_step == 0) {
      _sc.animating = true;
      _Audio.play(_Sound.pop);
      _tween(1000, (t) => _sc.foldT = Curves.easeInOutCubic.transform(t), () {
        _sc
          ..dashGreen = true
          ..animating = false;
        _setStep(1);
      });
    } else if (_step == 1) {
      _sc.animating = true;
      _Audio.play(_Sound.pop);
      _tween(500, (t) => _sc.paperScale = 1 - 0.9 * Curves.easeInQuad.transform(t), () {
        _sc
          ..paperVisible = false
          ..linesVisible = false
          ..boatScale = 0.1
          ..boatVisible = true;
        _Audio.play(_Sound.magic);
        _tween(500, (t) => _sc.boatScale = 0.1 + 0.9 * Curves.bounceOut.transform(t), () {
          _sc.animating = false;
          _setStep(2);
        });
      });
    }
  }

  /// HTML `performAction('unfold')`.
  void _unfold() {
    if (_sc.animating) return;
    setState(() => _sc.animating = true);
    _tween(600, (t) => _sc.boatScale = 1 - 0.9 * Curves.easeInQuad.transform(t), () {
      _sc
        ..boatVisible = false
        ..paperVisible = true
        ..linesVisible = true;
      _tween(600, (t) => _sc.paperScale = 0.1 + 0.9 * Curves.bounceOut.transform(t));
      _tween(1500, (t) => _sc.foldT = 1 - Curves.easeInOutCubic.transform(t), () {
        _sc
          ..foldT = 0
          ..animating = false;
        _setStep(3);
        _triggerCompletion();
      });
    });
  }

  // ------------------------------------------------------- scenario 2

  /// HTML: pump nozzle snapped onto the balloon opening.
  void _connectPump() {
    _Audio.play(_Sound.drop);
    _sc
      ..pump = _sc.balloon
      ..targetVisible = false;
    _dragTarget = null;
    _setStep(1);
  }

  /// HTML `handleInteraction('pumpGroup')` at step 1.
  void _pumpStroke() {
    if (_sc.animating || _sc.pumpClicks >= _maxPumpClicks) return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      _sc.animating = true;
      _sc.pumpClicks++;
    });
    final newScale = _balloonMin + _sc.pumpClicks * (_balloonMax - _balloonMin) / _maxPumpClicks;
    // Handle pushed in and pulled back (yoyo, 2 x 150 ms).
    _tween(300, (t) => _sc.handleOff = t < 0.5 ? t * 2 : (1 - t) * 2, () {
      _sc.handleOff = 0;
      final from = _sc.balloonScale;
      _tween(200, (t) => _sc.balloonScale = from + (newScale - from) * t);
      final wobble = (_rng.nextDouble() - 0.5) * 0.1;
      _tween(200, (t) => _sc.balloonRot = wobble * (t < 0.5 ? t * 2 : (1 - t) * 2), () => _sc.balloonRot = 0);
      _sc.animating = false;
      if (_sc.pumpClicks >= _maxPumpClicks) {
        _setStep(2);
      } else {
        setState(() {});
      }
    });
  }

  /// HTML `performAction('release')`: the balloon zips around (4 x 300 ms
  /// yoyo) while shrinking back and settling with a bounce.
  void _releaseAir() {
    if (_sc.animating) return;
    _Audio.play(_Sound.whoosh);
    setState(() => _sc.animating = true);
    final start = _sc.balloon;
    final s0 = _sc.balloonScale;
    const end = _V3(2, 0, -1);
    const zip = _V3(3, 0, 0);
    _tween(
      1500,
      (t) {
        final e = Curves.bounceOut.transform(t);
        _sc.balloonScale = s0 + (_balloonMin - s0) * e;
        final ms = t * 1500;
        if (ms < 1200) {
          final leg = ms ~/ 300;
          final lt = (ms % 300) / 300;
          _sc.balloon = _V3.lerp(start, zip, leg.isEven ? lt : 1 - lt);
        } else {
          _sc.balloon = _V3.lerp(start, end, e);
        }
      },
      () {
        _sc
          ..balloon = end
          ..animating = false;
        _setStep(3);
        // "Check Again" appears 1.5 s later.
        _lab.after(const Duration(milliseconds: 1500), () {
          if (!mounted || _sc.step != 3 || _sc.pinVisible) return;
          setState(() => _sc.checkReady = true);
        });
      },
    );
  }

  /// HTML `performAction('getPin')`.
  void _getPin() {
    setState(() {
      _sc
        ..balloon = _balloonHome
        ..balloonScale = _balloonMax
        ..pinVisible = true
        ..checkReady = false
        ..step = 3;
    });
  }

  /// HTML `handleInteraction('pop')`.
  void _pop() {
    _Audio.play(_Sound.pop);
    _dragTarget = null;
    final c = _balloonCenter(_sc);
    _sc
      ..balloonVisible = false
      ..pinVisible = false;
    _sc.pieces.clear();
    for (var i = 0; i < 30; i++) {
      _sc.pieces.add(
        _Piece(
          _V3(
            c.x + (_rng.nextDouble() - 0.5) * 1.5,
            c.y + (_rng.nextDouble() - 0.5) * 1.5,
            c.z + (_rng.nextDouble() - 0.5) * 1.5,
          ),
          vx: (_rng.nextDouble() - 0.5) * 4,
          vy: _rng.nextDouble() * 4 + 1,
          vz: (_rng.nextDouble() - 0.5) * 4,
          rx: _rng.nextDouble() * math.pi,
          ry: _rng.nextDouble() * math.pi,
          rz: _rng.nextDouble() * math.pi,
          drx: _rng.nextDouble() * 0.2,
          dry: _rng.nextDouble() * 0.2,
        ),
      );
    }
    _setStep(4);
    _triggerCompletion();
  }

  /// HTML `triggerCompletion()`: the "Key Observation" popup 2.5 s later.
  /// Also marks the scenario complete and offers Continue / Restart Lab.
  void _triggerCompletion() {
    final index = _sc.scenario;
    _lab.completedScenarios.add(index);
    _lab.after(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _lab.openSidebar();
      _lab.showPopup(() {
        final allDone = _lab.completedScenarios.length >= 2;
        return LabPopupContent(
          title: _t('key_obs'),
          icon: Icons.lightbulb,
          accent: _Colors.zslYellow,
          extra: _conclusionBody(index),
          actions: [
            if (allDone)
              LabAction(
                label: _lab.t('btn_restart'),
                icon: Icons.replay,
                color: _Colors.indigo600,
                foreground: Colors.white,
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
        );
      });
    });
  }

  // ------------------------------------------------------------ input

  /// Which object a pointer at [q] would start dragging (HTML pointerdown
  /// rules), or null.
  String? _dragCandidate(Offset q) {
    if (_sc.animating || _lab.popup != null) return null;
    final cam = _sc.cam;
    if (_s1 && (_step == 0 || _step == 1) && _sc.paperVisible && _hitPaper(cam, _sc, q)) return 'paper';
    if (!_s1 && _step == 0 && _hitPump(cam, _sc, q)) return 'pump';
    if (!_s1 && _step == 3 && _sc.pinVisible && _hitPin(cam, _sc, q)) return 'pin';
    return null;
  }

  bool _canStartDrag(Offset global) {
    if (!_lab.isLabActive) return false;
    final local = labGlobalToLocal(_stageKey, global);
    return local != null && _dragCandidate(local) != null;
  }

  void _onDragStart(Offset q) {
    final target = _dragCandidate(q);
    if (target == null) return;
    if (target != 'paper') _Audio.play(_Sound.pickup);
    _dragTarget = target;
    _dragStart = q;
    _dragPrev = _rayPlane(_sc.cam, q, 0.2);
  }

  void _onDragUpdate(Offset q) {
    final target = _dragTarget;
    if (target == null) return;
    if (target == 'paper') {
      // HTML: a drag of more than 20 px folds the paper.
      if ((q - _dragStart!).distance > 20) {
        _dragTarget = null;
        _paperInteraction();
      }
      return;
    }
    final w = _rayPlane(_sc.cam, q, 0.2);
    final prev = _dragPrev;
    if (w == null || prev == null) return;
    final d = w - prev;
    _dragPrev = w;
    if (target == 'pump') {
      _sc.pump = _V3(_sc.pump.x + d.x, _sc.pump.y, _sc.pump.z + d.z);
      if ((_sc.pump - _sc.balloon).length < 1.0) _connectPump();
    } else if (target == 'pin') {
      _sc.pin = _V3(_sc.pin.x + d.x, _sc.pin.y, _sc.pin.z + d.z);
      if ((_sc.pin - _sc.balloon).length < 2.0) _pop();
    }
  }

  void _onDragEnd() {
    _dragTarget = null;
    _dragStart = null;
    _dragPrev = null;
  }

  /// HTML pointerup with < 5 px movement on the pump at step 1.
  void _onTap(Offset q) {
    if (!_lab.isLabActive || _lab.popup != null) return;
    if (!_s1 && _step == 1 && _hitPump(_sc.cam, _sc, q)) _pumpStroke();
  }

  // ------------------------------------------------------------ UI

  /// HTML `#hud-actions` buttons.
  List<LabAction> _actions() {
    if (_s1 && _step == 2) {
      return [
        LabAction(
          label: _t('btn_unfold'),
          icon: Icons.unfold_more,
          color: _Colors.green,
          foreground: Colors.white,
          highlight: true,
          enabled: !_sc.animating,
          onTap: _unfold,
        ),
      ];
    }
    if (!_s1 && _step == 2) {
      return [
        LabAction(
          label: _t('btn_release'),
          icon: Icons.air,
          color: _Colors.green,
          foreground: Colors.white,
          highlight: true,
          enabled: !_sc.animating,
          silent: true, // plays the hiss itself
          onTap: _releaseAir,
        ),
      ];
    }
    if (!_s1 && _step == 3 && !_sc.pinVisible && _sc.checkReady) {
      return [
        LabAction(
          label: _t('btn_check'),
          icon: Icons.search,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _getPin,
        ),
      ];
    }
    return const [];
  }

  String _hudKey() {
    final keys = _hudKeys[_sc.scenario];
    if (!_s1 && _step == 3 && _sc.pinVisible) return 'hud_s2_3_pin';
    return keys[_step.clamp(0, keys.length - 1)];
  }

  /// Keeps canvas labels readable (>= ~9 px) when the stage is scaled down.
  double _labelScale(BoxConstraints box) {
    if (!box.hasBoundedWidth || !box.hasBoundedHeight) return 1;
    final fit = math.min(box.maxWidth / _design.width, box.maxHeight / _design.height);
    if (fit <= 0) return 1;
    return (9.5 / (13 * fit)).clamp(1.0, 1.7);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final hudKey = _hudKey();
        return LabShell(
          controller: _lab,
          icon: Icons.category,
          title: _t('appTitle'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('scen1_name'), _t('scen2_name')],
          scenarioIndex: _sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step + 1,
          // Only the pin variant differs from the step's default task text.
          instruction: hudKey == 'hud_s2_3_pin' ? _plain(_t(hudKey)) : null,
          actions: _actions(),
          onReset: _fullReset,
          showHud: false,
          overlays: [_hud(context, p, s, hudKey)],
          stage: LayoutBuilder(
            builder: (context, box) => LabStage(
              designSize: _design,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  _PickPanRecognizer: GestureRecognizerFactoryWithHandlers<_PickPanRecognizer>(
                    () => _PickPanRecognizer(canStart: _canStartDrag),
                    (r) => r
                      ..canStart = _canStartDrag
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = ((d) => _onDragStart(d.localPosition))
                      ..onUpdate = ((d) => _onDragUpdate(d.localPosition))
                      ..onEnd = ((_) => _onDragEnd())
                      ..onCancel = _onDragEnd,
                  ),
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    TapGestureRecognizer.new,
                    (r) => r.onTapUp = (d) => _onTap(d.localPosition),
                  ),
                },
                child: CustomPaint(
                  key: _stageKey,
                  size: _design,
                  painter: _PcPainter(
                    sc: _sc,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    textScale: _labelScale(box),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#hud-panel`: "Task Instructions", the current instruction and the
  /// pump click counter.
  Widget _hud(BuildContext context, LabPalette p, double s, String key) {
    final pad = MediaQuery.paddingOf(context);
    final done = key == 'hud_s2_4';
    final base = TextStyle(
      color: done ? (p.isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)) : p.textStrong,
      fontSize: 12.5 * s,
      fontWeight: done ? FontWeight.w800 : FontWeight.w600,
      height: 1.45,
    );
    final showCounter = !_s1 && _step == 1;
    final clicks = _sc.pumpClicks;
    final counter = _t('clicks') + (clicks > 0 ? [for (var i = 1; i <= clicks; i++) i * 4].join('... ') : '0');
    return Positioned(
      left: 12,
      right: 60 + pad.right,
      bottom: 10 + pad.bottom,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560 * s, minWidth: 280 * s),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
                boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: p.panel,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(height: 4 * s, color: const Color(0xFFEAB308)),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16 * s, 6 * s, 16 * s, 8 * s),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _t('task_inst').toUpperCase(),
                              style: TextStyle(
                                color: p.textMuted,
                                fontSize: 9.5 * s,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                            ),
                            SizedBox(height: 3 * s),
                            Text.rich(
                              TextSpan(children: _richHud(_t(key)), style: base),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (showCounter) ...[
                              SizedBox(height: 4 * s),
                              Text(
                                counter,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFFACC15),
                                  fontSize: 17 * s,
                                  fontWeight: FontWeight.w900,
                                  shadows: const [
                                    Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(2, 2)),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }

  /// Popup body: conclusion with highlighted keywords plus the badge.
  Widget _conclusionBody(int index) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final base = TextStyle(color: p.text, fontSize: 14 * f, height: 1.6, fontWeight: FontWeight.w500);
    final hlBg = p.isDark ? const Color(0x66A16207) : const Color(0xFFFEF08A);
    final hlFg = p.isDark ? const Color(0xFFFACC15) : const Color(0xFF854D0E);
    final first = index == 0;
    final badgeBg = first
        ? (p.isDark ? const Color(0x4D713F12) : const Color(0xFFFEF9C3))
        : (p.isDark ? const Color(0x4D7F1D1D) : const Color(0xFFFEE2E2));
    final badgeFg = first
        ? (p.isDark ? const Color(0xFFFACC15) : const Color(0xFF854D0E))
        : (p.isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B));
    final text = _t(first ? 'conc_s1' : 'conc_s2');
    final spans = <InlineSpan>[];
    final re = RegExp(r"<span class='highlight-word'>(.*?)</span>");
    var i = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4 * s),
            decoration: BoxDecoration(color: hlBg, borderRadius: BorderRadius.circular(4)),
            child: Text(
              m.group(1)!,
              style: base.copyWith(color: hlFg, fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
        ),
      );
      i = m.end;
    }
    if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(TextSpan(children: spans, style: base)),
        SizedBox(height: 16 * s),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
            child: Text(
              _t(first ? 'badge_s1' : 'badge_s2'),
              textAlign: TextAlign.center,
              style: TextStyle(color: badgeFg, fontWeight: FontWeight.w800, fontSize: 12 * f),
            ),
          ),
        ),
      ],
    );
  }
}

/// HUD markup: `<br/>` line breaks and `<strong>` bold.
List<InlineSpan> _richHud(String text) {
  final spans = <InlineSpan>[];
  final src = text.replaceAll('<br/>', '\n');
  final re = RegExp(r'<strong>(.*?)</strong>');
  var i = 0;
  for (final m in re.allMatches(src)) {
    if (m.start > i) spans.add(TextSpan(text: src.substring(i, m.start)));
    spans.add(
      TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    i = m.end;
  }
  if (i < src.length) spans.add(TextSpan(text: src.substring(i)));
  return spans;
}

/// Plain text version of HUD markup (sidebar / floating card).
String _plain(String text) =>
    text.replaceAll('<br/>', ' ').replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

// ============================================================ STRINGS
//
// HTML markup kept where it carries meaning: <strong> (bold), <br/> (line
// break) and <span class='highlight-word'> (highlighted keyword).

const LabStringTable _i18n = {
  'en': {
    'appTitle': 'Physical Changes: Appearance Changes, Substance Remains',
    'header_title': 'Appearance Changes, Substance Remains',
    'subtitle': 'Class 7 • Changes Around Us: Physical and Chemical',
    'task_inst': 'Task Instructions',
    'key_obs': 'Key Observation',
    'scen1_name': '1. The Paper Transformer',
    'scen2_name': "2. The Balloon's Big Day Out",
    'scen1_mission':
        'To observe that changing the shape of an object through folding is a physical change, and the original object can be recovered.',
    'scen2_mission':
        'To observe that changing the size and shape of an object is a physical change, and to differentiate between a reversible and an irreversible physical change.',

    // Teacher board step details ("What we did" / "How").
    's1_s0_w': 'Altered the physical shape of the paper.',
    's1_s0_h': 'Clicked and dragged the corners of the flat paper to the highlighted dotted lines.',
    's1_s1_w': 'Completed the folding into a simple boat shape.',
    's1_s1_h': 'Continued to click and drag the paper along the next set of glowing dotted lines.',
    's1_s2_w': 'Tested if the shape change is reversible.',
    's1_s2_h': "Clicked the 'Unfold' button after noticing the shape had changed.",
    's1_s3_w': 'Examined the final state of the object.',
    's1_s3_h': 'Observed the unfolded flat paper.',
    's2_s0_w': 'Connected the air pump to the balloon.',
    's2_s0_h': 'Dragged the pump nozzle and connected it to the balloon opening.',
    's2_s1_w': 'Inflated the balloon with air.',
    's2_s1_h': 'Clicked on the pump handle repeatedly.',
    's2_s2_w': 'Reversed the inflation process.',
    's2_s2_h': "Clicked the 'Release Air' button.",
    's2_s3_w': 'Tested an irreversible action.',
    's2_s3_h': 'Dragged a pin and touched the inflated balloon with it.',
    's2_s4_w': 'Analyzed the popped balloon pieces.',
    's2_s4_h': 'Observed the torn rubber pieces.',

    // HUD task instructions.
    'hud_s1_0':
        'A flat sheet of paper is on a virtual workbench.<br/><strong>CLICK and DRAG</strong> the corners of the paper to the highlighted dotted lines to begin folding.',
    'hud_s1_1': 'Continue to <strong>CLICK and DRAG</strong> the paper.',
    'hud_s1_2': 'The shape has changed. Is it still paper?',
    'hud_s1_3': 'Observe the flat paper. The substance has not changed.',
    'hud_s2_0': '<strong>DRAG</strong> pump nozzle. <strong>CONNECT</strong> to balloon opening.<br/>Target visible.',
    'hud_s2_1': '<strong>CLICK</strong> repeatedly to inflate.',
    'hud_s2_2': 'Is it still a balloon? Size has changed.',
    'hud_s2_3_pin': '<strong>DRAG</strong> the pin and <strong>TOUCH</strong> the balloon with it.',
    'hud_s2_3_def': 'Balloon zips around, deflates.<br/>Returns to original state.',
    'hud_s2_4': 'Observation Complete. Awaiting Summary Popup...',

    // Canvas labels.
    'lbl_paper': 'Flat Sheet of Paper',
    'lbl_boat': 'Paper Boat',
    'lbl_pump': 'Air Pump',
    'lbl_balloon': 'Blue Balloon',
    'lbl_pin': 'Sharp Pin',

    'btn_unfold': 'UNFOLD',
    'btn_release': 'RELEASE AIR',
    'btn_check': 'Check Again',
    'clicks': 'CLICKS: ',

    'conc_s1':
        "The paper only changed its <span class='highlight-word'>shape</span>. No new substance was formed. This is a <span class='highlight-word'>physical change</span>.",
    'conc_s2':
        "The balloon popped! The pieces are still <span class='highlight-word'>rubber</span>, but its form has changed permanently. This is also a <span class='highlight-word'>physical change</span>, but it cannot be easily reversed.",
    'badge_s1': 'Physical Change Verified',
    'badge_s2': 'Irreversible Physical Change Verified',
  },
  'hi': {
    'appTitle': 'भौतिक परिवर्तन: रूप बदलता है, पदार्थ वही रहता है',
    'header_title': 'रूप बदलता है, पदार्थ वही रहता है',
    'subtitle': 'कक्षा 7 • हमारे चारों ओर के परिवर्तन: भौतिक और रासायनिक',
    'task_inst': 'कार्य निर्देश',
    'key_obs': 'मुख्य अवलोकन',
    'scen1_name': '1. कागज का रूपांतरण',
    'scen2_name': '2. गुब्बारे का बड़ा दिन',
    'scen1_mission':
        'यह देखने के लिए कि मोड़ने के माध्यम से किसी वस्तु का आकार बदलना एक भौतिक परिवर्तन है, और मूल वस्तु को वापस प्राप्त किया जा सकता है।',
    'scen2_mission':
        'यह देखने के लिए कि किसी वस्तु का आकार और रूप बदलना एक भौतिक परिवर्तन है, और प्रतिवर्ती (reversible) और अपरिवर्तनीय (irreversible) भौतिक परिवर्तन के बीच अंतर करने के लिए।',

    's1_s0_w': 'कागज के भौतिक आकार को बदल दिया।',
    's1_s0_h': 'सपाट कागज के कोनों को क्लिक करके हाइलाइट की गई बिंदीदार रेखाओं तक खींचा।',
    's1_s1_w': 'एक साधारण नाव के आकार में मोड़ने का काम पूरा किया।',
    's1_s1_h': 'चमकती बिंदीदार रेखाओं के अगले सेट के साथ कागज को क्लिक और ड्रैग करना जारी रखा।',
    's1_s2_w': 'परीक्षण किया कि क्या आकार परिवर्तन प्रतिवर्ती (उलटा जा सकने वाला) है।',
    's1_s2_h': "आकार बदलने के बाद 'अनफोल्ड (खोलें)' बटन पर क्लिक किया।",
    's1_s3_w': 'वस्तु की अंतिम स्थिति की जांच की।',
    's1_s3_h': 'खुले हुए सपाट कागज का अवलोकन किया।',
    's2_s0_w': 'हवा पंप को गुब्बारे से जोड़ा।',
    's2_s0_h': 'पंप के नोजल को ड्रैग करके गुब्बारे के मुहाने से जोड़ा।',
    's2_s1_w': 'गुब्बारे में हवा भरी।',
    's2_s1_h': 'पंप के हैंडल पर बार-बार क्लिक किया।',
    's2_s2_w': 'हवा भरने की प्रक्रिया को उलट दिया।',
    's2_s2_h': "'हवा निकालें' बटन पर क्लिक किया।",
    's2_s3_w': 'एक अपरिवर्तनीय क्रिया का परीक्षण किया।',
    's2_s3_h': 'एक पिन को ड्रैग किया और फूले हुए गुब्बारे को छुआ।',
    's2_s4_w': 'फटे हुए गुब्बारे के टुकड़ों का विश्लेषण किया।',
    's2_s4_h': 'फटे हुए रबर के टुकड़ों का अवलोकन किया।',

    'hud_s1_0':
        'वर्चुअल मेज पर एक सपाट कागज रखा है।<br/>मोड़ना शुरू करने के लिए कागज के कोनों को <strong>क्लिक करें और ड्रैग करके</strong> हाइलाइट की गई बिंदीदार रेखाओं तक लाएं।',
    'hud_s1_1': 'कागज को <strong>क्लिक और ड्रैग</strong> करना जारी रखें।',
    'hud_s1_2': 'आकार बदल गया है। क्या यह अभी भी कागज है?',
    'hud_s1_3': 'सपाट कागज को देखें। पदार्थ में कोई बदलाव नहीं हुआ है।',
    'hud_s2_0':
        'पंप नोजल को <strong>ड्रैग</strong> करें। गुब्बारे के मुहाने से <strong>जोड़ें</strong>।<br/>लक्ष्य दिखाई दे रहा है।',
    'hud_s2_1': 'हवा भरने के लिए बार-बार <strong>क्लिक</strong> करें।',
    'hud_s2_2': 'क्या यह अभी भी गुब्बारा है? आकार बदल गया है।',
    'hud_s2_3_pin': 'पिन को <strong>ड्रैग</strong> करें और गुब्बारे से <strong>छुआएं</strong>।',
    'hud_s2_3_def': 'गुब्बारा इधर-उधर घूमता है, हवा निकल जाती है।<br/>अपनी मूल स्थिति में लौट आता है।',
    'hud_s2_4': 'अवलोकन पूरा हुआ। सारांश पॉपअप की प्रतीक्षा कर रहा है...',

    'lbl_paper': 'कागज की सपाट शीट',
    'lbl_boat': 'कागज की नाव',
    'lbl_pump': 'हवा पंप',
    'lbl_balloon': 'नीला गुब्बारा',
    'lbl_pin': 'नुकीली पिन',

    'btn_unfold': 'खोलें (UNFOLD)',
    'btn_release': 'हवा निकालें',
    'btn_check': 'फिर से जांचें',
    'clicks': 'क्लिक: ',

    'conc_s1':
        "कागज ने केवल अपना <span class='highlight-word'>आकार</span> बदला। कोई नया पदार्थ नहीं बना। यह एक <span class='highlight-word'>भौतिक परिवर्तन</span> है।",
    'conc_s2':
        "गुब्बारा फूट गया! टुकड़े अभी भी <span class='highlight-word'>रबर</span> हैं, लेकिन इसका रूप स्थायी रूप से बदल गया है। यह भी एक <span class='highlight-word'>भौतिक परिवर्तन</span> है, लेकिन इसे आसानी से उलटा नहीं जा सकता।",
    'badge_s1': 'भौतिक परिवर्तन सत्यापित',
    'badge_s2': 'अपरिवर्तनीय भौतिक परिवर्तन सत्यापित',
  },
};

/// HUD instruction key of every step (0-based HTML `AppState.step`).
/// Step 3 of scenario 2 switches to `hud_s2_3_pin` once the pin appears.
const List<List<String>> _hudKeys = [
  ['hud_s1_0', 'hud_s1_1', 'hud_s1_2', 'hud_s1_3'],
  ['hud_s2_0', 'hud_s2_1', 'hud_s2_2', 'hud_s2_3_def', 'hud_s2_4'],
];

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: '1. The Paper Transformer',
      objective:
          'To observe that changing the shape of an object through folding is a physical change, and the original object can be recovered.',
      steps: [
        LabStep(
          concept: 'First Fold',
          action:
              'A flat sheet of paper is on a virtual workbench. CLICK and DRAG the corners of the paper to the highlighted dotted lines to begin folding.',
          observation: 'The 3D paper model animated smoothly as it was folded. The dotted lines turned green.',
        ),
        LabStep(
          concept: 'Origami Construction',
          action: 'Continue to CLICK and DRAG the paper.',
          observation:
              'With each fold, the 3D model changed shape. The object became clearly identifiable as a paper boat and could be rotated in 3D space.',
        ),
        LabStep(
          concept: 'Reversibility Test',
          action: 'The shape has changed. Is it still paper?',
          observation:
              'The paper boat animated in reverse, unfolding step-by-step until it was a flat sheet of paper again, with visible crease marks.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observe the flat paper. The substance has not changed.',
          observation:
              'The substance did not change. The paper only changed its shape, meaning no new substance was formed. This confirmed a physical change.',
        ),
      ],
    ),
    LabScenarioData(
      title: "2. The Balloon's Big Day Out",
      objective:
          'To observe that changing the size and shape of an object is a physical change, and to differentiate between a reversible and an irreversible physical change.',
      steps: [
        LabStep(
          concept: 'Initial State',
          action: 'DRAG pump nozzle. CONNECT to balloon opening. Target visible.',
          observation:
              'The pump nozzle snapped onto the balloon opening with a soft click sound. The balloon was uninflated and made of blue rubber.',
        ),
        LabStep(
          concept: 'Inflation',
          action: 'CLICK repeatedly to inflate.',
          observation: 'The balloon visibly grew larger with each click. The balloon wobbled slightly as it inflated.',
        ),
        LabStep(
          concept: 'Reversibility Test',
          action: 'Is it still a balloon? Size has changed.',
          observation:
              "The balloon zipped around the screen with a 'pssssh' sound effect and then fell to the workbench, returning to its original uninflated state.",
        ),
        LabStep(
          concept: 'Destruction',
          action: 'Balloon zips around, deflates. Returns to original state.',
          observation:
              "A sharp 'POP!' sound played. The balloon model instantly disappeared and was replaced by several small, torn pieces of rubber that fluttered down.",
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Observation Complete. Awaiting Summary Popup...',
          observation:
              'The pieces were still rubber, but the original form was permanently lost. This demonstrated an irreversible physical change.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: '1. कागज का रूपांतरण',
      objective:
          'यह देखने के लिए कि मोड़ने के माध्यम से किसी वस्तु का आकार बदलना एक भौतिक परिवर्तन है, और मूल वस्तु को वापस प्राप्त किया जा सकता है।',
      steps: [
        LabStep(
          concept: 'पहला मोड़',
          action:
              'वर्चुअल मेज पर एक सपाट कागज रखा है। मोड़ना शुरू करने के लिए कागज के कोनों को क्लिक करें और ड्रैग करके हाइलाइट की गई बिंदीदार रेखाओं तक लाएं।',
          observation: 'मोड़े जाने पर 3D पेपर मॉडल सुचारू रूप से एनिमेट हुआ। बिंदीदार रेखाएं हरी हो गईं।',
        ),
        LabStep(
          concept: 'ओरिगेमी निर्माण',
          action: 'कागज को क्लिक और ड्रैग करना जारी रखें।',
          observation:
              'प्रत्येक मोड़ के साथ, 3D मॉडल का आकार बदल गया। वस्तु स्पष्ट रूप से एक कागज की नाव के रूप में पहचानी जाने लगी और इसे 3D स्पेस में घुमाया जा सकता था।',
        ),
        LabStep(
          concept: 'प्रतिवर्ती परीक्षण',
          action: 'आकार बदल गया है। क्या यह अभी भी कागज है?',
          observation:
              'कागज की नाव उल्टे क्रम में एनिमेट हुई, और धीरे-धीरे खुलकर फिर से एक सपाट कागज बन गई, जिसमें सिलवटों के निशान दिखाई दे रहे थे।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सपाट कागज को देखें। पदार्थ में कोई बदलाव नहीं हुआ है।',
          observation:
              'पदार्थ नहीं बदला। कागज ने केवल अपना आकार बदला, जिसका अर्थ है कि कोई नया पदार्थ नहीं बना। इससे भौतिक परिवर्तन की पुष्टि हुई।',
        ),
      ],
    ),
    LabScenarioData(
      title: '2. गुब्बारे का बड़ा दिन',
      objective:
          'यह देखने के लिए कि किसी वस्तु का आकार और रूप बदलना एक भौतिक परिवर्तन है, और प्रतिवर्ती (reversible) और अपरिवर्तनीय (irreversible) भौतिक परिवर्तन के बीच अंतर करने के लिए।',
      steps: [
        LabStep(
          concept: 'प्रारंभिक अवस्था',
          action: 'पंप नोजल को ड्रैग करें। गुब्बारे के मुहाने से जोड़ें। लक्ष्य दिखाई दे रहा है।',
          observation:
              "पंप का नोजल एक हल्की 'क्लिक' ध्वनि के साथ गुब्बारे के मुहाने पर जुड़ गया। गुब्बारा बिना फूला हुआ था और नीले रबर का बना था।",
        ),
        LabStep(
          concept: 'फुलाना',
          action: 'हवा भरने के लिए बार-बार क्लिक करें।',
          observation:
              'प्रत्येक क्लिक के साथ गुब्बारा स्पष्ट रूप से बड़ा होता गया। फूलते समय गुब्बारा थोड़ा हिल रहा था।',
        ),
        LabStep(
          concept: 'प्रतिवर्ती परीक्षण',
          action: 'क्या यह अभी भी गुब्बारा है? आकार बदल गया है।',
          observation:
              "गुब्बारा 'प्सस्स' ध्वनि के साथ स्क्रीन पर घूमा और फिर अपनी मूल बिना फूली हुई अवस्था में लौटकर मेज पर गिर गया।",
        ),
        LabStep(
          concept: 'विनाश',
          action: 'गुब्बारा इधर-उधर घूमता है, हवा निकल जाती है। अपनी मूल स्थिति में लौट आता है।',
          observation:
              "एक तेज 'पॉप!' ध्वनि बजी। गुब्बारे का मॉडल तुरंत गायब हो गया और उसकी जगह रबर के कई छोटे, फटे हुए टुकड़े नीचे गिर गए।",
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'अवलोकन पूरा हुआ। सारांश पॉपअप की प्रतीक्षा कर रहा है...',
          observation:
              'टुकड़े अभी भी रबर के थे, लेकिन उनका मूल रूप स्थायी रूप से नष्ट हो गया था। इसने एक अपरिवर्तनीय भौतिक परिवर्तन का प्रदर्शन किया।',
        ),
      ],
    ),
  ],
};

// ============================================================== CAMERA
//
// The HTML used a 45° perspective camera at (0, 7, 8) looking at
// (0, 0.5, 0). The same viewing direction is used here; only the target and
// distance are tuned per scenario so the scene fills the landscape stage.

const Size _design = Size(960, 540);
const Offset _c0 = Offset(480, 258);

/// 270 / tan(22.5°): focal length for a 45° vertical field of view.
const double _focal = 651.9;

/// Unit vector from the target back to the camera: (0, 6.5, 8) / |..|.
const double _by = 0.63059;
const double _bz = 0.77611;

/// Key light direction (HTML DirectionalLight at (5, 12, 8)).
const _V3 _light = _V3(0.3276, 0.7862, 0.5241);

const _Cam _camPaper = _Cam(_V3(0, 0.45, 0.9), 7.4);
const _Cam _camBalloon = _Cam(_V3(-0.4, 0.95, 0), 12);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;
  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);
  _V3 operator -() => _V3(-x, -y, -z);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

@immutable
class _Cam {
  const _Cam(this.target, this.dist);
  final _V3 target;
  final double dist;
  _V3 get pos => _V3(target.x, target.y + _by * dist, target.z + _bz * dist);
  static _Cam lerp(_Cam a, _Cam b, double t) => _Cam(_V3.lerp(a.target, b.target, t), a.dist + (b.dist - a.dist) * t);
}

/// Perspective projection: screen point and camera depth.
({Offset p, double z}) _pj(_Cam cam, _V3 q) {
  final pos = cam.pos;
  final dx = q.x - pos.x, dy = q.y - pos.y, dz = q.z - pos.z;
  final yc = dy * _bz - dz * _by;
  final zc = math.max(0.05, -(dy * _by + dz * _bz));
  return (p: Offset(_c0.dx + dx / zc * _focal, _c0.dy - yc / zc * _focal), z: zc);
}

/// Intersection of the pointer ray with the horizontal plane y = [y0]
/// (the HTML drag plane).
_V3? _rayPlane(_Cam cam, Offset s, double y0) {
  final sx = (s.dx - _c0.dx) / _focal, sy = (s.dy - _c0.dy) / _focal;
  final dir = _V3(sx, -sy * _bz - _by, sy * _by - _bz);
  if (dir.y >= -1e-6) return null;
  final pos = cam.pos;
  return pos + dir * ((y0 - pos.y) / dir.y);
}

// =========================================================== SCENE MODEL

class _Piece {
  _Piece(
    this.pos, {
    required this.vx,
    required this.vy,
    required this.vz,
    required this.rx,
    required this.ry,
    required this.rz,
    required this.drx,
    required this.dry,
  });
  _V3 pos;
  double vx, vy, vz, rx, ry, rz;
  final double drx, dry;
  bool landed = false;
}

/// Mutable scene state shared by the State (logic) and the painter.
class _PcScene {
  int scenario = 0;

  /// 0-based like the HTML `AppState.step`.
  int step = 0;
  double time = 0;
  _Cam cam = _camPaper;
  bool animating = false;

  // Scenario 1: paper / boat.
  double foldT = 0;
  double paperScale = 1;
  bool paperVisible = true;
  bool linesVisible = true;
  bool dashGreen = false;
  double boatScale = 1;
  bool boatVisible = false;

  // Scenario 2: pump / balloon / pin.
  _V3 pump = _pumpHome;
  bool targetVisible = true;
  double handleOff = 0;
  _V3 balloon = _balloonHome;
  double balloonScale = _balloonMin;
  double balloonRot = 0;
  bool balloonVisible = true;
  _V3 pin = _pinHome;
  bool pinVisible = false;
  int pumpClicks = 0;
  bool checkReady = false;
  final List<_Piece> pieces = [];

  void reset(int index) {
    scenario = index;
    step = 0;
    animating = false;
    foldT = 0;
    paperScale = 1;
    paperVisible = true;
    linesVisible = true;
    dashGreen = false;
    boatScale = 1;
    boatVisible = false;
    pump = _pumpHome;
    targetVisible = true;
    handleOff = 0;
    balloon = _balloonHome;
    balloonScale = _balloonMin;
    balloonRot = 0;
    balloonVisible = true;
    pin = _pinHome;
    pinVisible = false;
    pumpClicks = 0;
    checkReady = false;
    pieces.clear();
  }
}

/// Balloon sphere centre (HTML geometry translated by (1, 1, 0), so the
/// balloon grows up and to the right from its tied end).
_V3 _balloonCenter(_PcScene sc) {
  final s = sc.balloonScale, th = sc.balloonRot;
  final c = math.cos(th), sn = math.sin(th);
  return sc.balloon + _V3(s * c - s * sn, s * sn + s * c, 0);
}

/// Balloon group local point (x, y) rotated by the wobble.
_V3 _balloonLocal(_PcScene sc, double x, double y) {
  final c = math.cos(sc.balloonRot), sn = math.sin(sc.balloonRot);
  return sc.balloon + _V3(x * c - y * sn, x * sn + y * c, 0);
}

/// The 3 x 3 paper vertices (HTML PlaneGeometry(4, 4, 2, 2)) with the
/// corners folded towards the centre by [foldT].
List<_V3> _paperVerts(_PcScene sc) {
  final t = sc.foldT, s = sc.paperScale, k = 2 * (1 - t), h = 0.5 * t;
  final raw = [
    _V3(-k, h, -k), const _V3(0, 0, -2), _V3(k, h, -k), //
    const _V3(-2, 0, 0), const _V3(0, 0, 0), const _V3(2, 0, 0), //
    _V3(-k, h, k), const _V3(0, 0, 2), _V3(k, h, k), //
  ];
  return [for (final v in raw) _V3(v.x * s, v.y * s + 0.01, v.z * s)];
}

/// Pump group points (HTML pumpGroup children) relative to its origin.
_V3 _pumpPt(_PcScene sc, double x, double y, double z) => sc.pump + _V3(x, y, z);

/// The pin is drawn twice its HTML size so it stays visible and easy to grab.
const double _pinScale = 2.0;
const double _pinLen = 0.4 * _pinScale;
const _V3 _pinDir = _V3(0.866, 0.5, 0);

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

double _segDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final l2 = ab.distanceSquared;
  if (l2 < 1e-9) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / l2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// Inside the convex outline of [pts], or within [pad] px of it.
bool _nearHull(List<Offset> pts, Offset q, double pad) {
  final h = _hull(pts);
  if (h.length >= 3 && (Path()..addPolygon(h, true)).contains(q)) return true;
  for (var i = 0; i < h.length; i++) {
    if (_segDist(q, h[i], h[(i + 1) % h.length]) < pad) return true;
  }
  return false;
}

bool _hitPaper(_Cam cam, _PcScene sc, Offset q) => _nearHull([for (final v in _paperVerts(sc)) _pj(cam, v).p], q, 10);

bool _hitPump(_Cam cam, _PcScene sc, Offset q) {
  final hx = -4.3 + sc.handleOff;
  final pts = <Offset>[
    for (final v in [
      _pumpPt(sc, -4.05, 0.5, 0),
      _pumpPt(sc, -4.05, 0, 0),
      _pumpPt(sc, -1.55, 0.5, 0),
      _pumpPt(sc, -1.55, 0, 0),
      _pumpPt(sc, hx - 1.25, 0.25, -0.5),
      _pumpPt(sc, hx - 1.25, 0.25, 0.5),
      _pumpPt(sc, -0.8, 0.4, 0.5),
      _pumpPt(sc, 0, 1.0, 0),
      _pumpPt(sc, -0.2, 1.1, 0),
    ])
      _pj(cam, v).p,
  ];
  return _nearHull(pts, q, 14);
}

bool _hitPin(_Cam cam, _PcScene sc, Offset q) {
  final a = _pj(cam, sc.pin - _pinDir * _pinLen).p;
  final b = _pj(cam, sc.pin + _pinDir * _pinLen).p;
  return _segDist(q, a, b) < 28;
}

// ============================================================== PAINTER

class _PcPainter extends CustomPainter {
  _PcPainter({
    required this.sc,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    this.textScale = 1,
  }) : super(repaint: repaint);

  final _PcScene sc;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double textScale;

  _Cam _cam = _camPaper;

  String _t(String key) => labTr(_i18n, lang, key);
  Offset _p(_V3 v) => _pj(_cam, v).p;
  double _px(_V3 v, double r) => r * _focal / _pj(_cam, v).z;

  Path _poly(List<_V3> pts) => Path()..addPolygon([for (final v in pts) _p(v)], true);

  /// Lambert shading of a face colour (two-sided, like DoubleSide).
  Color _lit(Color base, List<_V3> pts, {double bias = 0}) {
    var n = (pts[1] - pts[0]).cross(pts[2] - pts[0]).unit;
    final centroid = pts.reduce((a, b) => a + b) * (1 / pts.length);
    if (n.dot(_cam.pos - centroid) < 0) n = -n;
    final k = math.max(0.0, n.dot(_light));
    return labShade(base, (-0.2 + 0.38 * k + bias).clamp(-0.9, 0.9));
  }

  @override
  void paint(Canvas canvas, Size size) {
    _cam = sc.cam;
    _background(canvas, size);
    _table(canvas, size);
    if (sc.scenario == 0) {
      _paperScene(canvas);
    } else {
      _balloonScene(canvas);
    }
  }

  // ---------------------------------------------------------- environment

  void _background(Canvas c, Size size) {
    final b = labBleed(size);
    c.drawRect(
      b,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF0F172A), Color(0xFF0B1222)] : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final glow = Rect.fromCircle(center: const Offset(480, 170), radius: 520);
    c.drawRect(
      b,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFFFFFF)).withValues(alpha: isDark ? 0.45 : 0.8),
            const Color(0x00000000),
          ],
        ).createShader(glow),
    );
  }

  /// HTML workbench: 14 x 0.4 x 8 sienna top on four legs.
  void _table(Canvas c, Size size) {
    const wood = Color(0xFFA0522D);
    const legs = Color(0xFF8B4513);
    // Front legs (behind the front face, below the top).
    for (final x in const [-6.5, 6.5]) {
      final face = _poly([
        _V3(x - 0.25, -0.4, 3.75),
        _V3(x + 0.25, -0.4, 3.75),
        _V3(x + 0.25, -4.4, 3.75),
        _V3(x - 0.25, -4.4, 3.75),
      ]);
      c.drawPath(face, Paint()..color = labShade(legs, -0.15));
    }
    final top = [const _V3(-7, 0, -4), const _V3(7, 0, -4), const _V3(7, 0, 4), const _V3(-7, 0, 4)];
    final topPath = _poly(top);
    final back = _p(const _V3(0, 0, -4)), front = _p(const _V3(0, 0, 4));
    c.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(wood, -0.12), labShade(wood, 0.1)],
        ).createShader(Rect.fromPoints(back, front)),
    );
    // Wood grain and plank seams running along the bench.
    c
      ..save()
      ..clipPath(topPath);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF5C2A12).withValues(alpha: 0.16);
    var i = 0;
    for (var z = -3.9; z < 4; z += 0.31, i++) {
      final wob = 0.04 * math.sin(i * 1.7);
      grain.strokeWidth = math.max(0.8, _px(_V3(0, 0, z), 0.012));
      final path = Path();
      for (var x = -7.0; x <= 7.0; x += 1.0) {
        final q = _p(_V3(x, 0.001, z + wob * math.sin(x * 0.9 + i)));
        if (x == -7.0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      c.drawPath(path, grain);
    }
    final seam = Paint()
      ..strokeWidth = 1.4
      ..color = const Color(0xFF3B1A0B).withValues(alpha: 0.35);
    for (var z = -2.4; z < 4; z += 1.6) {
      c.drawLine(_p(_V3(-7, 0.001, z)), _p(_V3(7, 0.001, z)), seam);
    }
    c.restore();
    // Front edge face.
    final face = _poly([const _V3(-7, 0, 4), const _V3(7, 0, 4), const _V3(7, -0.4, 4), const _V3(-7, -0.4, 4)]);
    c.drawPath(face, Paint()..color = labShade(wood, -0.28));
    c.drawLine(
      _p(const _V3(-7, 0, 4)),
      _p(const _V3(7, 0, 4)),
      Paint()
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  /// Soft contact shadow: circle of radius [r] at height [h] above (x, z),
  /// cast along the key light onto the bench.
  void _shadow(Canvas c, _V3 at, double r, {double opacity = 0.32}) {
    final cx = at.x - at.y * 5 / 12, cz = at.z - at.y * 8 / 12;
    final pts = <Offset>[
      for (var i = 0; i < 20; i++)
        _p(_V3(cx + math.cos(i * math.pi / 10) * r, 0.005, cz + math.sin(i * math.pi / 10) * r)),
    ];
    final blur = _px(_V3(cx, 0, cz), r * 0.35);
    c.drawPath(
      Path()..addPolygon(pts, true),
      Paint()
        ..color = Colors.black.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2, blur)),
    );
  }

  // ------------------------------------------------------------ paper

  void _paperScene(Canvas c) {
    final linesOnTop = sc.foldT < 0.02 && sc.paperScale > 0.98;
    if (sc.linesVisible && !linesOnTop) _creases(c);
    if (sc.paperVisible && sc.paperScale > 0.02) _paper(c);
    if (sc.linesVisible && linesOnTop) _creases(c);
    if (sc.boatVisible && sc.boatScale > 0.02) _boat(c);
    if (sc.paperVisible) _label(c, 'lbl_paper', _V3(0, 0.35, -2.5 * sc.paperScale));
    if (sc.boatVisible) _label(c, 'lbl_boat', _V3(0, 2.45 * sc.boatScale, 0));
  }

  /// HTML lineGrp: white crease grid and the glowing dashed fold diagonals
  /// (yellow, green once folded).
  void _creases(Canvas c) {
    final white = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.85);
    for (final o in const [-0.66, 0.66]) {
      c
        ..drawLine(_p(_V3(-2, 0.03, o)), _p(_V3(2, 0.03, o)), white)
        ..drawLine(_p(_V3(o, 0.03, -2)), _p(_V3(o, 0.03, 2)), white);
    }
    final col = sc.dashGreen ? const Color(0xFF22C55E) : const Color(0xFFFFCC00);
    final pulse = (0.5 + 0.5 * math.sin(sc.time * 4)).clamp(0.3, 1.0);
    for (final diag in const [
      [_V3(-1.8, 0.03, -1.8), _V3(1.8, 0.03, 1.8)],
      [_V3(-1.8, 0.03, 1.8), _V3(1.8, 0.03, -1.8)],
    ]) {
      final a = diag[0], b = diag[1];
      final len = (b - a).length;
      final dir = (b - a) * (1 / len);
      for (var d = 0.0; d + 0.2 <= len; d += 0.35) {
        final s0 = a + dir * d, s1 = a + dir * (d + 0.2);
        final w = math.max(2.2, _px(s0, 0.05));
        c
          ..drawLine(
            _p(s0),
            _p(s1),
            Paint()
              ..strokeWidth = w * 2.6
              ..strokeCap = StrokeCap.round
              ..color = col.withValues(alpha: 0.25 * pulse)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          )
          ..drawLine(
            _p(s0),
            _p(s1),
            Paint()
              ..strokeWidth = w
              ..strokeCap = StrokeCap.round
              ..color = col.withValues(alpha: 0.45 + 0.55 * pulse),
          );
      }
    }
  }

  void _paper(Canvas c) {
    const base = Color(0xFF6EA8E6);
    final v = _paperVerts(sc);
    if (sc.foldT > 0.02) _shadow(c, const _V3(0, 0.25, 0), 1.6 * sc.paperScale, opacity: 0.2 * sc.foldT);
    // Each quadrant is split along the diagonal joining the two edge
    // midpoints, so every corner flap folds up as one triangle towards the
    // centre (corner, edge midpoint, edge midpoint) over the flat diamond.
    const tris = [
      [0, 3, 1], [3, 4, 1], // back-left
      [2, 1, 5], [1, 4, 5], // back-right
      [6, 7, 3], [7, 4, 3], // front-left
      [8, 5, 7], [5, 4, 7], // front-right
    ];
    double depth(List<int> t) => (_pj(_cam, v[t[0]]).z + _pj(_cam, v[t[1]]).z + _pj(_cam, v[t[2]]).z) / 3;
    final order = [...tris]..sort((x, y) => depth(y).compareTo(depth(x)));
    for (final t in order) {
      final pts = [v[t[0]], v[t[1]], v[t[2]]];
      final col = _lit(base, pts);
      final path = _poly(pts);
      c
        ..drawPath(path, Paint()..color = col)
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..strokeJoin = StrokeJoin.round
            ..color = col,
        );
    }
    // Paper outline.
    c.drawPath(
      _poly([
        for (final i in const [0, 1, 2, 5, 8, 7, 6, 3]) v[i],
      ]),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF3F7CC0),
    );
  }

  /// HTML origami boat built from planes: two hull sides, bottom, two sails.
  void _boat(Canvas c) {
    const base = Color(0xFF6EA8E6);
    final s = sc.boatScale;
    _V3 v(double x, double y, double z) => _V3(x * s, y * s, z * s);
    _shadow(c, v(0, 0.6, 0), 1.9 * s, opacity: 0.28);
    final parts = <(List<_V3>, double)>[
      ([v(-1.5, 0, -0.2), v(1.5, 0, -0.2), v(2, 0.6, -0.2), v(-2, 0.6, -0.2)], -0.12),
      ([v(-1.5, 0, -0.2), v(1.5, 0, -0.2), v(1.5, 0, 0.2), v(-1.5, 0, 0.2)], -0.05),
      ([v(-0.8, 0.6, 0), v(0, 0.6, 0), v(0, 2.0, 0)], 0),
      ([v(0, 0.6, 0.1), v(1.2, 0.6, 0.1), v(0, 1.6, 0.1)], 0.06),
      ([v(-1.5, 0, 0.2), v(1.5, 0, 0.2), v(2, 0.6, 0.2), v(-2, 0.6, 0.2)], 0.02),
    ];
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF3F7CC0);
    for (final (pts, bias) in parts) {
      final path = _poly(pts);
      c
        ..drawPath(path, Paint()..color = _lit(base, pts, bias: bias))
        ..drawPath(path, edge);
    }
    // Centre fold line on the hull.
    c.drawLine(_p(v(0, 0, 0.2)), _p(v(0, 0.6, 0.2)), edge..color = const Color(0x803F7CC0));
  }

  // ---------------------------------------------------------- balloon

  /// Cylinder between two world points with perspective widths and the end
  /// facing the camera capped.
  void _rod(Canvas c, _V3 a, _V3 b, double ra, double rb, Color color, {Color? capColor, double minW = 1.2}) {
    final pa = _pj(_cam, a), pb = _pj(_cam, b);
    final wa = math.max(minW / 2, ra * _focal / pa.z), wb = math.max(rb > 0 ? minW / 2 : 0.0, rb * _focal / pb.z);
    final axis = (b - a).unit;
    final facing = axis.dot((_cam.pos - (a + b) * 0.5).unit);
    final d = pb.p - pa.p;
    final len = d.distance;
    final u = len < 1e-3 ? const Offset(1, 0) : d / len;
    var n = Offset(-u.dy, u.dx);
    if (n.dy > 0 || (n.dy == 0 && n.dx > 0)) n = -n;
    final wm = math.max(wa, wb);
    final body = Paint()
      ..shader = ui.Gradient.linear(
        pa.p + n * wm,
        pa.p - n * wm,
        [labShade(color, 0.42), labShade(color, 0.08), color, labShade(color, -0.45)],
        const [0, 0.3, 0.55, 1],
      );
    final ang = math.atan2(u.dy, u.dx);
    final minor = math.max(facing.abs(), 0.05);
    void cap(Offset ctr, double r, Paint paint) {
      if (r <= 0.05) return;
      c
        ..save()
        ..translate(ctr.dx, ctr.dy)
        ..rotate(ang)
        ..drawOval(Rect.fromCenter(center: Offset.zero, width: 2 * r * minor, height: 2 * r), paint)
        ..restore();
    }

    final bFront = facing >= 0;
    cap(bFront ? pa.p : pb.p, bFront ? wa : wb, body);
    c.drawPath(Path()..addPolygon([pa.p + n * wa, pb.p + n * wb, pb.p - n * wb, pa.p - n * wa], true), body);
    cap(bFront ? pb.p : pa.p, bFront ? wb : wa, Paint()..color = capColor ?? labShade(color, 0.15));
  }

  void _tube(Canvas c, List<_V3> pts, double r, Color color) {
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final q = _p(pts[i]);
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    final w = math.max(2.0, _px(pts[pts.length ~/ 2], r * 2));
    Paint stroke(double width, Color col) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = col;
    c
      ..drawPath(path, stroke(w, labShade(color, -0.3)))
      ..drawPath(path, stroke(w * 0.65, color))
      ..drawPath(path.shift(Offset(-w * 0.1, -w * 0.18)), stroke(w * 0.2, labShade(color, 0.5).withValues(alpha: 0.6)));
  }

  void _balloonScene(Canvas c) {
    if (sc.balloonVisible) _balloonBody(c);
    if (sc.step == 0 && sc.targetVisible) _target(c);
    _pumpBody(c);
    if (sc.pinVisible) _pinBody(c);
    _pieces(c);
    _label(c, 'lbl_pump', _pumpPt(sc, -2.8, 1.0, 0));
    if (sc.balloonVisible) _label(c, 'lbl_balloon', _balloonCenter(sc) + _V3(0, sc.balloonScale + 0.45, 0));
    if (sc.pinVisible) _label(c, 'lbl_pin', sc.pin + const _V3(0, 0.95, 0));
  }

  /// HTML pumpGroup: barrel, sliding handle with T-grip, hose and nozzle.
  void _pumpBody(Canvas c) {
    const plastic = Color(0xFF64748B), dark = Color(0xFF334155), metal = Color(0xFF94A3B8);
    final hx = -4.3 + sc.handleOff;
    _shadow(c, _pumpPt(sc, -3.4, 0.25, 0), 1.0, opacity: 0.22);
    _shadow(c, _pumpPt(sc, -2.4, 0.25, 0), 0.9, opacity: 0.18);
    _rod(c, _pumpPt(sc, hx - 1.25, 0.25, 0), _pumpPt(sc, hx + 1.25, 0.25, 0), 0.06, 0.06, metal);
    _rod(c, _pumpPt(sc, -4.05, 0.25, 0), _pumpPt(sc, -1.55, 0.25, 0), 0.25, 0.25, plastic);
    _rod(c, _pumpPt(sc, hx - 1.25, 0.25, -0.5), _pumpPt(sc, hx - 1.25, 0.25, 0.5), 0.2, 0.2, dark);
    // Hose (HTML CatmullRomCurve3 through three points).
    final p0 = _pumpPt(sc, -0.2, 1.0, 0), p1 = _pumpPt(sc, -0.8, 0.4, 0.5), p2 = _pumpPt(sc, -1.5, 0.25, 0);
    final ctrl = [p0 * 2 - p1, p0, p1, p2, p2 * 2 - p1];
    final hose = <_V3>[];
    for (var seg = 1; seg <= 2; seg++) {
      final a = ctrl[seg - 1], b = ctrl[seg], cc = ctrl[seg + 1], d = ctrl[seg + 2];
      for (var i = 0; i <= 12; i++) {
        final t = i / 12, t2 = t * t, t3 = t2 * t;
        hose.add((b * 2 + (cc - a) * t + (a * 2 - b * 5 + cc * 4 - d) * t2 + (b * 3 - a - cc * 3 + d) * t3) * 0.5);
      }
    }
    _tube(c, hose, 0.05, dark);
    _rod(c, _pumpPt(sc, -0.2, 1.0, 0), _pumpPt(sc, 0, 1.0, 0), 0.06, 0.04, dark);
  }

  /// HTML balloon group: glossy blue sphere and the tied knot.
  void _balloonBody(Canvas c) {
    final s = sc.balloonScale;
    final ctr = _balloonCenter(sc);
    _shadow(c, ctr, s * 0.9, opacity: 0.3);
    final pc = _p(ctr);
    final r = _px(ctr, s);
    final rect = Rect.fromCircle(center: pc, radius: r);
    c.drawCircle(
      pc,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.42),
          radius: 1.05,
          colors: [Color(0xFF93C5FD), Color(0xFF2563EB), Color(0xFF1E3A8A)],
          stops: [0, 0.48, 1],
        ).createShader(rect),
    );
    // Clear-coat highlights and rim light.
    c
      ..drawOval(
        Rect.fromCenter(center: pc + Offset(-0.38 * r, -0.42 * r), width: 0.42 * r, height: 0.26 * r),
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      )
      ..drawCircle(pc + Offset(-0.12 * r, -0.62 * r), 0.06 * r, Paint()..color = Colors.white.withValues(alpha: 0.6))
      ..drawCircle(
        pc,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, 0.04 * r)
          ..color = const Color(0xFF60A5FA).withValues(alpha: 0.35),
      );
    _rod(c, _balloonLocal(sc, 0.0, 1.0), _balloonLocal(sc, 0.4, 1.0), 0.08, 0.12, const Color(0xFF2563EB));
  }

  /// Pulsing yellow target ring at the balloon opening (step 1).
  void _target(Canvas c) {
    final pulse = sc.animating ? 1.0 : 1 + math.sin(sc.time * 5) * 0.1;
    final ctr = _balloonHome + const _V3(0, 1.0, 0);
    labGlow(c, _p(ctr), _px(ctr, 0.55 * pulse), const Color(0xFFFFEA00), intensity: 0.55);
    for (final rr in [0.2 * pulse, 0.25 * pulse]) {
      final pts = [
        for (var i = 0; i < 28; i++) _p(ctr + _V3(0, math.cos(i * math.pi / 14) * rr, math.sin(i * math.pi / 14) * rr)),
      ];
      c.drawPath(
        Path()..addPolygon(pts, true),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = const Color(0xFFFFEA00).withValues(alpha: 0.85),
      );
    }
  }

  /// HTML pinGroup: steel shaft and red head, tilted 60°.
  void _pinBody(Canvas c) {
    final head = sc.pin + _pinDir * _pinLen;
    final tip = sc.pin - _pinDir * _pinLen;
    _shadow(c, sc.pin, 0.35, opacity: 0.25);
    _rod(c, _V3.lerp(tip, head, 0.18), head, 0.015 * _pinScale, 0.015 * _pinScale, const Color(0xFFCBD5E1), minW: 2.6);
    _rod(c, tip, _V3.lerp(tip, head, 0.18), 0, 0.015 * _pinScale, const Color(0xFFCBD5E1), minW: 2.6);
    labSphere(c, _p(head), math.max(5, _px(head, 0.08 * _pinScale)), const Color(0xFFEF4444));
  }

  /// Torn rubber pieces of the popped balloon.
  void _pieces(Canvas c) {
    const rubber = Color(0xFF2563EB);
    final list = [...sc.pieces]..sort((a, b) => _pj(_cam, b.pos).z.compareTo(_pj(_cam, a.pos).z));
    for (final pc in list) {
      final cx = math.cos(pc.rx), sx = math.sin(pc.rx);
      final cy = math.cos(pc.ry), sy = math.sin(pc.ry);
      final cz = math.cos(pc.rz), sz = math.sin(pc.rz);
      _V3 rot(double x, double y) {
        // Euler XYZ: v' = Rx(Ry(Rz(v))).
        final x1 = x * cz - y * sz, y1 = x * sz + y * cz;
        final x2 = x1 * cy, z2 = -x1 * sy;
        return _V3(x2, y1 * cx - z2 * sx, y1 * sx + z2 * cx);
      }

      final pts = [
        for (final q in const [(-0.1, -0.1), (0.1, -0.1), (0.1, 0.1), (-0.1, 0.1)]) pc.pos + rot(q.$1, q.$2),
      ];
      if (pc.landed) _shadow(c, pc.pos, 0.09, opacity: 0.15);
      c.drawPath(_poly(pts), Paint()..color = _lit(rubber, pts, bias: 0.05));
    }
  }

  // ------------------------------------------------------------ labels

  /// HTML `.canvas-label`: dark translucent chip with white text.
  void _label(Canvas c, String key, _V3 at) {
    if (!showLabels) return;
    final fs = 13 * textScale;
    labText(
      c,
      _t(key),
      _p(at),
      size: fs,
      color: Colors.white,
      weight: FontWeight.w600,
      background: const Color(0xCC000000),
      border: Colors.white.withValues(alpha: 0.2),
      borderWidth: 1,
      radius: 6,
      padding: EdgeInsets.symmetric(horizontal: 10 * textScale, vertical: 4 * textScale),
    );
  }

  @override
  bool shouldRepaint(covariant _PcPainter old) =>
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.textScale != textScale ||
      old.sc != sc;
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
