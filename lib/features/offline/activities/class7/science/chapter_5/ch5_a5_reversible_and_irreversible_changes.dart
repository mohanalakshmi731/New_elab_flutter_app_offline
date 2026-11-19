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

/// Class 7 Science • Chapter 5 • Activity 5
/// Reversible and Irreversible Changes.
///
/// Native Flutter port of `Cl7S-Ch5-A5-Reversible_and_Irreversible_Changes.html`.
///
/// Scenario 1 (The Ice Cube's Journey): ice cube → beaker → heating pad (ON)
/// melts it while the thermometer rises to 25 °C; OFF, open the freezer, put
/// the beaker inside, close it, wait while it cools to 0 °C, then bring the
/// re-frozen ice back to the desk (reversible).
///
/// Scenario 2 (The Popcorn Puzzle): pour the kernels into the machine, START
/// pops 25 kernels, move the popcorn to the bowl, freeze it for 10 s and
/// bring it back: still popcorn (irreversible).
class Ch5A5ReversibleAndIrreversibleChangesPage extends StatefulWidget {
  const Ch5A5ReversibleAndIrreversibleChangesPage({super.key});

  @override
  State<Ch5A5ReversibleAndIrreversibleChangesPage> createState() =>
      _Ch5A5ReversibleAndIrreversibleChangesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, switchTap
/// 2585.
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

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);

/// Shown part of the design space (trims empty wall; scene code uses
/// design coordinates, pointer positions are offset by its origin).
const Rect _crop = Rect.fromLTRB(10, 40, 990, 556);

/// Interactive objects (HTML `userData.id`).
enum _Obj { ice, beaker, heaterButton, door, scoop, machineButton, tray, bowl }

/// Resting places of the beaker / bowl (HTML drop zones).
enum _Spot { home, heater, freezer, desk }

const Offset _iceHome = Offset(355, 440); // bottom centre on the red tray
const Offset _beakerHome = Offset(520, 470); // bottom centres…
const Offset _heaterSpot = Offset(731, 428);
const Offset _freezerSlot = Offset(152, 232);
const Offset _deskSpot = Offset(505, 516);
const Offset _bowlHome = Offset(735, 452);
const Offset _scoopHome = Offset(800, 478); // rim centre of the scoop
const Offset _pourPos = Offset(531, 150);
const Offset _trayHome = Offset(520, 380); // front-top centre of the tray
const Offset _thermoBulb = Offset(615, 452);
const Offset _heaterBtn = Offset(772, 455);
const Offset _machineBtn = Offset(520, 430);
const Rect _doorRect = Rect.fromLTRB(40, 120, 250, 255);
const Rect _cavity = Rect.fromLTRB(54, 134, 236, 243);

/// Containers inside the freezer are drawn smaller (further away).
const double _freezerScale = 0.75;

/// Eased move of an object; holds [from] until [start].
class _Move {
  const _Move(this.from, this.to, this.start, this.dur);
  final Offset from, to;
  final double start, dur;

  double t(double now) => dur <= 0 ? 1 : ((now - start) / dur).clamp(0.0, 1.0);
  Offset at(double now) => Offset.lerp(from, to, Curves.easeInOutCubic.transform(t(now)))!;
  bool done(double now) => now >= start + dur;
}

/// Mutable scene read by the painter every frame.
class _A5Scene {
  int scenario = 0;
  int step = 0; // HTML AppState.step (0-based)
  double time = 0;

  // Dragging.
  _Obj? drag;
  Offset dragPos = Offset.zero;
  final Map<_Obj, _Move> moves = {};

  // Freezer door: 0 closed … 1 open (HTML pivot.rotation.y 0 → −π/2).
  double doorFrom = 0, doorTo = 0, doorStart = -10;
  double get door {
    final v = ((time - doorStart) / 0.33).clamp(0.0, 1.0);
    return doorFrom + (doorTo - doorFrom) * v;
  }

  bool get doorClosedNow => door < 0.02;

  _Spot beakerSpot = _Spot.home;
  _Spot bowlSpot = _Spot.home;

  // ---- Scenario 1: ice.
  bool iceInBeaker = false;
  double iceDropAt = -10; // ice settling into the beaker
  bool iceRefrozen = false;
  bool heaterOn = false;
  double meltStart = -1; // melting animation start
  double melt = 0; // 0..1
  double temp = 0; // °C shown by the thermometer
  bool waterVisible = false;

  // ---- Scenario 2: popcorn.
  bool scoopFull = true;
  double pourStart = -1;
  bool machineKernels = false;
  bool popping = false;
  bool potHot = false;
  final List<double> popTimes = [];
  bool trayPopcorn = false;
  bool bowlPopcorn = false;
  bool bowlCold = false;

  // Cooling wait (HTML coolingAnim).
  double coolStart = -1;
  double coolDur = 4;

  // Hint glow (expected object) — set by the page.
  _Obj? hint;

  bool get isIce => scenario == 0;

  Offset spotPos(_Spot s, {required bool bowl}) => switch (s) {
        _Spot.home => bowl ? _bowlHome : _beakerHome,
        _Spot.heater => _heaterSpot,
        _Spot.freezer => _freezerSlot,
        _Spot.desk => _deskSpot,
      };

  /// Current bottom-centre / anchor position of an object.
  Offset pos(_Obj o) {
    if (drag == o) return dragPos;
    final m = moves[o];
    if (m != null) return m.at(time);
    return switch (o) {
      _Obj.ice => _iceHome,
      _Obj.beaker => spotPos(beakerSpot, bowl: false),
      _Obj.bowl => spotPos(bowlSpot, bowl: true),
      _Obj.scoop => _scoopHome,
      _Obj.tray => _trayHome,
      _Obj.heaterButton => _heaterBtn,
      _Obj.machineButton => _machineBtn,
      _Obj.door => _doorRect.center,
    };
  }

  /// True while [o] sits (or is settling) inside the freezer cavity.
  bool inFreezer(_Obj o) {
    if (drag == o) return false;
    final spot = o == _Obj.bowl ? bowlSpot : beakerSpot;
    final m = moves[o];
    if (m != null && !m.done(time)) return false;
    return spot == _Spot.freezer;
  }

  double scaleOf(_Obj o) => inFreezer(o) ? _freezerScale : 1.0;

  Rect hitRect(_Obj o) {
    final p = pos(o);
    final k = scaleOf(o);
    return switch (o) {
      _Obj.ice => Rect.fromLTRB(p.dx - 42, p.dy - 76, p.dx + 42, p.dy + 10),
      _Obj.beaker => Rect.fromLTRB(p.dx - 72 * k, p.dy - 124 * k, p.dx + 72 * k, p.dy + 14 * k),
      _Obj.bowl => Rect.fromLTRB(p.dx - 72 * k, p.dy - 84 * k, p.dx + 72 * k, p.dy + 12 * k),
      _Obj.scoop => Rect.fromLTRB(p.dx - 48, p.dy - 44, p.dx + 118, p.dy + 30),
      _Obj.tray => Rect.fromLTRB(p.dx - 70, p.dy - 34, p.dx + 76, p.dy + 22),
      _Obj.heaterButton => Rect.fromCircle(center: p, radius: 28),
      _Obj.machineButton => Rect.fromCenter(center: p, width: 64, height: 54),
      _Obj.door => door < 0.5 ? _doorRect.inflate(4) : const Rect.fromLTRB(244, 104, 336, 276),
    };
  }

  /// Top-most interactive object under [p].
  _Obj? objectAt(Offset p) {
    final order = isIce
        ? [
            if (!doorClosedNow && inFreezer(_Obj.beaker)) _Obj.beaker,
            _Obj.door,
            _Obj.heaterButton,
            _Obj.beaker,
            if (!iceInBeaker) _Obj.ice,
          ]
        : [
            if (!doorClosedNow && inFreezer(_Obj.bowl)) _Obj.bowl,
            _Obj.door,
            _Obj.machineButton,
            _Obj.bowl,
            _Obj.tray,
            _Obj.scoop,
          ];
    for (final o in order) {
      if (o == _Obj.beaker || o == _Obj.bowl) {
        if (inFreezer(o) && doorClosedNow) continue; // behind the door
      }
      if (hitRect(o).contains(p)) return o;
    }
    return null;
  }

  void reset() {
    drag = null;
    moves.clear();
    doorFrom = doorTo = 0;
    doorStart = -10;
    beakerSpot = _Spot.home;
    bowlSpot = _Spot.home;
    iceInBeaker = false;
    iceDropAt = -10;
    iceRefrozen = false;
    heaterOn = false;
    meltStart = -1;
    melt = 0;
    temp = 0;
    waterVisible = false;
    scoopFull = true;
    pourStart = -1;
    machineKernels = false;
    popping = false;
    potHot = false;
    popTimes.clear();
    trayPopcorn = false;
    bowlPopcorn = false;
    bowlCold = false;
    coolStart = -1;
    hint = null;
  }
}

/// Pan recogniser that only claims pointers starting on an object that may
/// be dragged now, so empty-canvas drags still pan an unlocked camera.
class _ObjPanRecognizer extends PanGestureRecognizer {
  _ObjPanRecognizer({required this.canStart});

  bool Function(Offset global) canStart;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && canStart(event.position);
}

// ================================================================== STATE

class _Ch5A5ReversibleAndIrreversibleChangesPageState
    extends State<Ch5A5ReversibleAndIrreversibleChangesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A5Scene _scene = _A5Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();
  final math.Random _rand = math.Random();

  late final Ticker _ticker;

  // HTML AppState flags.
  bool _animating = false;
  bool _heaterOff = false; // step3_heaterOff
  bool _doorOpened = false; // step3_doorOpened
  bool _doorOpened2 = false; // step4_doorOpened2
  bool _doorOpen = false; // door userData.state
  bool _containerInFreezer = false;

  /// Between a completed action and the step advancing.
  bool _busy = false;
  bool _meltDone = true;
  bool _coolDone = true;
  int _waitLeft = 10;

  // HUD message (HTML updateHUD(customMessage)); null → step instruction.
  String? _statusKey;
  Map<String, Object> _statusArgs = const {};

  // Pointer / drag.
  _Obj? _press;
  bool _dragging = false;
  Offset _grab = Offset.zero;

  double _uiScale = 1;

  bool get _isIce => _scene.isIce;
  int get _step => _scene.step;
  int get _stepCount => _isIce ? 5 : 6;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _onFrame();
      _frame.value = _scene.time;
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

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _setStatus(String? key, [Map<String, Object> args = const {}]) {
    _statusKey = key;
    _statusArgs = args;
  }

  // ------------------------------------------------------------ scenario

  /// HTML `loadScenario(n)`.
  void _buildScenario() {
    _lab.cancelPending();
    _animating = false;
    _heaterOff = false;
    _doorOpened = false;
    _doorOpened2 = false;
    _doorOpen = false;
    _containerInFreezer = false;
    _busy = false;
    _meltDone = true;
    _coolDone = true;
    _press = null;
    _dragging = false;
    _setStatus(null);
    _scene.reset();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _scene.step = 0;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  /// HTML `resetSceneFull()` (the shell restores language / theme / etc).
  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _scene.step = 0;
      _buildScenario();
    });
  }

  /// HTML `completeStep()`: "Great job!" for 1.5 s, then the next step
  /// (cooling wait or the summary popup where needed).
  void _completeStep() {
    _busy = true;
    _Audio.play(_Sound.correct);
    _setStatus('msg_greatJob');
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _busy = false;
        final wasSummary = (_isIce && _step == 4) || (!_isIce && _step == 5);
        _scene.step++;
        if (wasSummary || _step >= _stepCount) {
          _setStatus('scenComplete');
          _showSummary();
          return;
        }
        _setStatus(null);
        final isWait = (_isIce && _step == 3) || (!_isIce && _step == 4);
        final isSummaryNow = (_isIce && _step == 4) || (!_isIce && _step == 5);
        if (isSummaryNow) _showSummary();
        if (isWait) _startCooling();
      });
    });
  }

  /// HTML `triggerErrorHUD(key)`.
  void _error([String key = 'err_general']) {
    _lab.showToast(_t(key), isError: true);
    _lab.after(const Duration(milliseconds: 2500), () {
      if (!mounted || _animating) return;
      setState(() => _setStatus(null));
    });
  }

  /// HTML `coolingAnim` (4 s to 0 °C, or a 10 s countdown).
  void _startCooling() {
    _animating = true;
    _coolDone = false;
    _scene.coolStart = _scene.time;
    _scene.coolDur = _isIce ? 4 : 10;
    _waitLeft = 10;
    if (_isIce) {
      _setStatus('msg_waitTemp');
    } else {
      _setStatus('msg_waitX', {'sec': 10});
    }
  }

  /// Per-frame logic driven by the ticker (melting and cooling).
  void _onFrame() {
    final s = _scene;
    if (!_meltDone && s.meltStart >= 0) {
      final p = ((s.time - s.meltStart) / 1.1).clamp(0.0, 1.0);
      s.melt = p;
      final temp = (p * 25).floorToDouble();
      if (temp != s.temp) {
        s.temp = temp;
        _refresh();
      }
      if (p >= 1) {
        _meltDone = true;
        _animating = false;
        _completeStep();
        _refresh();
      }
    }
    if (!_coolDone && s.coolStart >= 0) {
      final elapsed = s.time - s.coolStart;
      final t = (elapsed / s.coolDur).clamp(0.0, 1.0);
      if (s.isIce) {
        final temp = math.max(0, (25 * (1 - t)).floor()).toDouble();
        if (temp != s.temp) {
          s.temp = temp;
          _refresh();
        }
      } else {
        final left = math.max(0, 10 - elapsed.floor());
        if (left != _waitLeft) {
          _waitLeft = left;
          _setStatus('msg_waitX', {'sec': left});
          _refresh();
        }
      }
      if (t >= 1) {
        _coolDone = true;
        _animating = false;
        _Audio.play(_Sound.correct);
        _setStatus(null);
        if (s.isIce) {
          s.waterVisible = false;
          s.iceRefrozen = true;
        } else {
          s.bowlCold = true;
        }
        _refresh();
      }
    }
  }

  void _showSummary() {
    final sc = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 500),
      title: () => _t('obsOutcome'),
      heading: () => _t('scenComplete'),
      body: () => _t(sc == 0 ? 'type_rev_short' : 'type_irrev_short'),
      extra: () => _summaryExtra(sc),
    );
  }

  // ------------------------------------------------------ interaction

  /// HTML `isAllowed` for clickable objects.
  bool _clickAllowed(_Obj o) {
    if (_isIce) {
      if (_step == 1) return o == _Obj.heaterButton;
      if (_step == 2) return o == _Obj.heaterButton || o == _Obj.door;
      if (_step == 3) return o == _Obj.door;
      return false;
    }
    if (_step == 1) return o == _Obj.machineButton;
    if (_step == 3 || _step == 4) return o == _Obj.door;
    return false;
  }

  /// HTML `isAllowed` for draggable objects.
  bool _dragAllowed(_Obj o) {
    if (_isIce) {
      if (_step == 0) return o == _Obj.ice;
      if (_step >= 1 && _step <= 3) return o == _Obj.beaker;
      return false;
    }
    if (_step == 0) return o == _Obj.scoop;
    if (_step == 2) return o == _Obj.tray;
    if (_step == 3 || _step == 4) return o == _Obj.bowl;
    return false;
  }

  bool get _blocked => _animating || _busy || !_lab.isLabActive;

  bool _canStartAt(Offset global) {
    final local = labGlobalToLocal(_stageKey, global);
    if (local == null || _blocked) return false;
    final o = _scene.objectAt(local + _crop.topLeft);
    return o != null && _dragAllowed(o);
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_press != null || _dragging || _blocked) return;
    final o = _scene.objectAt(e.localPosition + _crop.topLeft);
    if (o == null) return;
    if (_clickAllowed(o)) {
      setState(() => _click(o));
    } else if (_dragAllowed(o)) {
      _press = o;
      _Audio.play(_Sound.pickup);
    }
  }

  /// A press that never became a drag: the HTML drop test runs from the
  /// object's resting place, which is always within its huge tolerance, so
  /// a tap places the object on its target.
  void _onPointerUp(PointerUpEvent e) {
    final o = _press;
    if (o == null || _dragging) return;
    _press = null;
    setState(() => _drop(o, _scene.pos(o), tap: true));
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (!_dragging) _press = null;
  }

  void _onDragStart(DragStartDetails d) {
    final at = d.localPosition + _crop.topLeft;
    final o = _press ?? _scene.objectAt(at);
    if (o == null || !_dragAllowed(o) || _blocked) return;
    _press = o;
    _dragging = true;
    final p = _scene.pos(o);
    _grab = p - at;
    setState(() {
      _scene.moves.remove(o);
      _scene.drag = o;
      _scene.dragPos = p;
    });
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_scene.drag == null) return;
    final p = d.localPosition + _crop.topLeft + _grab;
    _scene.dragPos = Offset(
      p.dx.clamp(_crop.left + 30, _crop.right - 30),
      p.dy.clamp(_crop.top + 60, _crop.bottom - 6),
    );
  }

  void _onDragEnd(DragEndDetails d) {
    final o = _scene.drag;
    _dragging = false;
    _press = null;
    if (o == null) return;
    final p = _scene.dragPos;
    setState(() {
      _scene.drag = null;
      _drop(o, p, tap: false);
    });
  }

  void _onDragCancel() {
    final o = _scene.drag;
    _dragging = false;
    _press = null;
    if (o == null) return;
    setState(() {
      _scene.drag = null;
      _returnHome(o, _scene.dragPos);
    });
  }

  /// Eases [o] from [from] back to its current resting place.
  void _returnHome(_Obj o, Offset from) {
    _scene.moves[o] = _Move(from, _restPos(o), _scene.time, 0.3);
  }

  Offset _restPos(_Obj o) => switch (o) {
        _Obj.beaker => _scene.spotPos(_scene.beakerSpot, bowl: false),
        _Obj.bowl => _scene.spotPos(_scene.bowlSpot, bowl: true),
        _Obj.ice => _iceHome,
        _Obj.scoop => _scoopHome,
        _Obj.tray => _trayHome,
        _ => _scene.pos(o),
      };

  void _placeContainer(_Obj o, Offset from, _Spot spot) {
    if (o == _Obj.bowl) {
      _scene.bowlSpot = spot;
    } else {
      _scene.beakerSpot = spot;
    }
    _scene.moves[o] = _Move(from, _scene.spotPos(spot, bowl: o == _Obj.bowl), _scene.time, 0.28);
  }

  // Generous drop zones (the HTML accepted 16–25 world units).
  static const Offset _beakerTarget = Offset(520, 416);
  static const Offset _heaterTarget = Offset(731, 400);
  static const Offset _freezerTarget = Offset(150, 190);
  static const Offset _machineTarget = Offset(531, 270);
  static const Offset _bowlTarget = Offset(735, 410);
  static const Rect _deskZone = Rect.fromLTRB(290, 285, 990, 560);

  /// HTML `onPointerUp` drop logic.
  void _drop(_Obj o, Offset p, {required bool tap}) {
    bool near(Offset target, double r) => tap || (p - target).distance < r;
    final from = p;
    if (_isIce) {
      if (_step == 0) {
        if (o == _Obj.ice && near(_beakerTarget, 230)) {
          _Audio.play(_Sound.drop);
          _scene.moves.remove(_Obj.ice);
          _scene.iceInBeaker = true;
          _scene.iceDropAt = _scene.time;
          _completeStep();
        } else {
          _returnHome(o, from);
          _error();
        }
        return;
      }
      if (_step == 1) {
        if (o == _Obj.beaker && near(_heaterTarget, 230)) {
          _Audio.play(_Sound.drop);
          _placeContainer(o, from, _Spot.heater);
          _setStatus('msg_clickOn');
        } else {
          _returnHome(o, from);
          _error();
        }
        return;
      }
    } else {
      if (_step == 0) {
        if (o == _Obj.scoop && near(_machineTarget, 220)) {
          _pour(from);
        } else {
          _returnHome(o, from);
          _error('err_scoop');
        }
        return;
      }
      if (_step == 2) {
        if (o == _Obj.tray && near(_bowlTarget, 230)) {
          _Audio.play(_Sound.drop);
          _scene.trayPopcorn = false;
          _scene.bowlPopcorn = true;
          _returnHome(o, from);
          _completeStep();
        } else {
          _returnHome(o, from);
          _error();
        }
        return;
      }
    }
    // Into the freezer (scenario 1 step 2 / scenario 2 step 3).
    if ((_isIce && _step == 2) || (!_isIce && _step == 3)) {
      if (near(_freezerTarget, 240)) {
        if (!_doorOpened) {
          _returnHome(o, from);
          _error('err_doorClosed');
          return;
        }
        _Audio.play(_Sound.drop);
        _placeContainer(o, from, _Spot.freezer);
        _containerInFreezer = true;
        _setStatus('msg_placed');
        // The HTML message promises the door closes automatically.
        final step = _step;
        _lab.after(const Duration(milliseconds: 1300), () {
          if (!mounted || _step != step || !_doorOpen || _animating || _busy) return;
          setState(_closeDoorAndComplete);
        });
      } else {
        _returnHome(o, from);
        _error('err_freezerDrop');
      }
      return;
    }
    // Back to the desk (scenario 1 step 3 / scenario 2 step 4).
    if ((_isIce && _step == 3) || (!_isIce && _step == 4)) {
      if (tap || _deskZone.contains(p)) {
        if (!_doorOpened2) {
          _returnHome(o, from);
          _error('err_doorClosed');
          return;
        }
        _Audio.play(_Sound.drop);
        _placeContainer(o, from, _Spot.desk);
        _completeStep();
      } else {
        _returnHome(o, from);
        _error('err_deskDrop');
      }
      return;
    }
    _returnHome(o, from);
  }

  /// HTML pour: the scoop hops above the machine, tilts (≈0.33 s), the
  /// kernels drop in and the empty scoop returns to the desk.
  void _pour(Offset from) {
    _animating = true;
    _Audio.play(_Sound.pickup);
    _scene.moves[_Obj.scoop] = _Move(from, _pourPos, _scene.time, 0.22);
    _scene.pourStart = _scene.time + 0.22;
    _lab.after(const Duration(milliseconds: 940), () {
      if (!mounted) return;
      _Audio.play(_Sound.drop);
      setState(() {
        _scene.scoopFull = false;
        _scene.machineKernels = true;
        _scene.pourStart = -1;
        _scene.moves[_Obj.scoop] = _Move(_pourPos, _scoopHome, _scene.time, 0.35);
        _animating = false;
        _completeStep();
      });
    });
  }

  /// HTML `handleClicks(id)`.
  void _click(_Obj o) {
    if (_isIce && _step == 2) {
      if (o == _Obj.heaterButton && !_heaterOff) {
        _Audio.play(_Sound.switchTap);
        _scene.heaterOn = false;
        _heaterOff = true;
        _setStatus('msg_heaterOff');
      } else if (o == _Obj.door) {
        if (!_heaterOff) {
          _error('err_heaterOn');
          return;
        }
        _doorClick(openMsg: 'msg_doorOpenBeaker');
      }
      return;
    }
    if (!_isIce && _step == 3) {
      if (o == _Obj.door) _doorClick(openMsg: 'msg_doorOpenBowl');
      return;
    }
    if ((_isIce && _step == 3) || (!_isIce && _step == 4)) {
      if (o == _Obj.door && !_doorOpened2 && !_animating) {
        _animateDoor(true, () {
          _doorOpened2 = true;
          _setStatus('msg_doorOpenDesk');
        });
      }
      return;
    }
    if (o == _Obj.heaterButton && _step == 1) {
      if (_scene.beakerSpot != _Spot.heater) {
        _error('err_beakerFirst');
        return;
      }
      _Audio.play(_Sound.switchTap);
      _scene.heaterOn = true;
      _setStatus('msg_heatingBeaker');
      _animating = true;
      _scene.waterVisible = true;
      _scene.meltStart = _scene.time;
      _meltDone = false;
    } else if (o == _Obj.machineButton && _step == 1) {
      _Audio.play(_Sound.switchTap);
      _setStatus('msg_popping');
      _animating = true;
      _scene.popping = true;
      _scene.potHot = true;
      _lab.after(const Duration(milliseconds: 800), _popNext);
    }
  }

  void _doorClick({required String openMsg}) {
    if (_doorOpen) {
      if (!_containerInFreezer) {
        _error();
        return;
      }
      _closeDoorAndComplete();
    } else if (!_doorOpened && !_animating) {
      _animateDoor(true, () {
        _doorOpened = true;
        _setStatus(openMsg);
      });
    }
  }

  void _closeDoorAndComplete() => _animateDoor(false, _completeStep);

  /// HTML doorAnimOpen / doorAnimClose (20 frames ≈ 0.33 s).
  void _animateDoor(bool open, VoidCallback onDone) {
    _animating = true;
    _Audio.play(_Sound.click);
    _scene.doorFrom = _scene.door;
    _scene.doorTo = open ? 1 : 0;
    _scene.doorStart = _scene.time;
    _lab.after(const Duration(milliseconds: 340), () {
      if (!mounted) return;
      setState(() {
        _animating = false;
        _doorOpen = open;
        onDone();
      });
    });
  }

  /// HTML popAnim: 25 pops, 80–230 ms apart.
  void _popNext() {
    if (!mounted) return;
    if (_scene.popTimes.length < 25) {
      _Audio.play(_Sound.pop, volume: 0.45);
      setState(() => _scene.popTimes.add(_scene.time));
      _lab.after(Duration(milliseconds: 80 + _rand.nextInt(150)), _popNext);
      return;
    }
    setState(() {
      _scene.popping = false;
      _scene.potHot = false;
      _scene.machineKernels = false;
      _scene.trayPopcorn = true;
      _animating = false;
      _completeStep();
    });
  }

  /// Pulsing hint on the object the current state expects.
  _Obj? _expected() {
    if (_blocked) return null;
    if (_isIce) {
      switch (_step) {
        case 0:
          return _Obj.ice;
        case 1:
          return _scene.beakerSpot == _Spot.heater ? _Obj.heaterButton : _Obj.beaker;
        case 2:
          if (!_heaterOff) return _Obj.heaterButton;
          if (!_doorOpened) return _Obj.door;
          return _containerInFreezer ? _Obj.door : _Obj.beaker;
        case 3:
          return _doorOpened2 ? _Obj.beaker : _Obj.door;
      }
      return null;
    }
    switch (_step) {
      case 0:
        return _Obj.scoop;
      case 1:
        return _Obj.machineButton;
      case 2:
        return _Obj.tray;
      case 3:
        if (!_doorOpened) return _Obj.door;
        return _containerInFreezer ? _Obj.door : _Obj.bowl;
      case 4:
        return _doorOpened2 ? _Obj.bowl : _Obj.door;
    }
    return null;
  }

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        _uiScale = s;
        final data = _data;
        _scene.hint = _expected();
        final key = _statusKey;
        return LabShell(
          controller: _lab,
          icon: Icons.swap_horiz_rounded,
          title: _t('appTitle'),
          subtitle: _t('appSubtitle'),
          scenarioNames: [_t('scen1Title'), _t('scen2Title')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: math.min(_step + 1, _stepCount),
          instruction: key == null ? null : labFormat(_t(key), _statusArgs),
          sidebarExtra: _sidebarExtra(p, s),
          onReset: _fullReset,
          stage: LabStage(designSize: _crop.size, child: _stageChild()),
        );
      },
    );
  }

  Widget _stageChild() {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: RawGestureDetector(
        key: _stageKey,
        behavior: HitTestBehavior.opaque,
        gestures: {
          _ObjPanRecognizer: GestureRecognizerFactoryWithHandlers<_ObjPanRecognizer>(
            () => _ObjPanRecognizer(canStart: _canStartAt),
            (r) {
              r
                ..canStart = _canStartAt
                ..dragStartBehavior = DragStartBehavior.down
                ..gestureSettings = const DeviceGestureSettings(touchSlop: 8)
                ..onStart = _onDragStart
                ..onUpdate = _onDragUpdate
                ..onEnd = _onDragEnd
                ..onCancel = _onDragCancel;
            },
          ),
        },
        child: CustomPaint(
          size: _crop.size,
          painter: _A5Painter(
            scene: _scene,
            repaint: _frame,
            isDark: _lab.isDark,
            showLabels: _lab.showLabels,
            lang: _lab.lang,
          ),
        ),
      ),
    );
  }

  /// Mission type badge (HTML mission box) and live readouts.
  Widget _sidebarExtra(LabPalette p, double s) {
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    final badgeFg = p.isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1D4ED8);
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
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
              decoration: BoxDecoration(
                color: _Colors.blue.withValues(alpha: p.isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _Colors.blue.withValues(alpha: 0.5)),
              ),
              child: Text(
                _t(_isIce ? 'typeRev' : 'typeIrrev'),
                style: TextStyle(color: badgeFg, fontSize: 11.5 * f, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          if (_isIce) ...[
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('ctl_temp'),
              value: labFormat(_t('l_temp'), {'t': _scene.temp.round()}),
              valueColor: const Color(0xFFF87171),
            ),
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('ctl_heater'),
              value: _t(_scene.heaterOn ? 'ctl_on' : 'ctl_off'),
              valueColor: _scene.heaterOn ? const Color(0xFFFB923C) : p.textMuted,
            ),
          ],
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t('ctl_door'),
            value: _t(_scene.door > 0.5 ? 'ctl_open' : 'ctl_closed'),
            valueColor: const Color(0xFF7DD3FC),
          ),
          if (!_isIce && !_coolDone)
            LabInfoRow(
              palette: p,
              scale: f,
              label: _t('ctl_wait'),
              value: labFormat(_t('ctl_sec'), {'sec': _waitLeft}),
              valueColor: _Colors.zslYellow,
            ),
        ],
      ),
    );
  }

  /// HTML summary modal body: before / after icons and "What we learnt".
  Widget _summaryExtra(int sc) {
    final p = _Theme.of(_lab.isDark);
    final s = _uiScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final labelStyle = TextStyle(color: p.textStrong, fontSize: 11.5 * f, fontWeight: FontWeight.w700, height: 1.25);
    Widget item(_Icon icon, String label) => Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(size: Size.square(52 * s), painter: _SummaryIconPainter(icon)),
              SizedBox(height: 6 * s),
              Text(label, textAlign: TextAlign.center, style: labelStyle),
            ],
          ),
        );
    final desc = _t(sc == 0 ? 's1_sum' : 's2_sum').split('**');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 14 * s),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: p.isDark ? 0.2 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: sc == 0
                ? [
                    item(_Icon.ice, _t('l_ice')),
                    CustomPaint(size: Size(64 * s, 40 * s), painter: const _SummaryIconPainter(_Icon.reversible)),
                    item(_Icon.ice, _t('l_recovered')),
                  ]
                : [
                    item(_Icon.corn, _t('l_kernels')),
                    CustomPaint(size: Size(80 * s, 40 * s), painter: const _SummaryIconPainter(_Icon.irreversible)),
                    item(_Icon.popcorn, _t('l_popcorn')),
                  ],
          ),
        ),
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('whatWeLearnt').toUpperCase(),
                style: TextStyle(
                  color: _Colors.zslYellow,
                  fontSize: 11 * f,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 6 * s),
              Text.rich(
                TextSpan(children: [
                  for (var i = 0; i < desc.length; i++)
                    TextSpan(
                      text: desc[i],
                      style: i.isOdd ? TextStyle(fontWeight: FontWeight.w800, color: p.textStrong) : null,
                    ),
                ]),
                style: TextStyle(color: p.text, fontSize: 12.5 * f, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================ STRINGS
//
// From the HTML `TRANSLATIONS` table (Telugu dropped). `<b>…</b>` became
// `**…**` (rendered bold) and `H<sub>2</sub>O` became `H₂O`.

const LabStringTable _i18n = {
  'en': {
    'appTitle': 'Reversible and Irreversible Changes',
    'appSubtitle': 'Class 7 • Changes Around Us',
    'currentTask': 'Current Task',
    'typeRev': 'Type: Reversible Change',
    'typeIrrev': 'Type: Irreversible Change',
    'scen1Title': "Scenario 1: The Ice Cube's Journey",
    'scen2Title': 'Scenario 2: The Popcorn Puzzle',
    'scenComplete': 'Scenario Complete!',
    'obsOutcome': 'Observation Outcome',
    'whatWeLearnt': 'What we learnt:',
    's1_sum':
        'You have successfully demonstrated a **reversible change**. Melting the solid ice into liquid water and then freezing it back into solid ice proves that the substance remains water (H₂O) throughout the process and the original state can be recovered.',
    's2_sum':
        'You have successfully demonstrated an **irreversible change**. Popping the corn is a permanent chemical and physical alteration caused by heat. Cooling the popcorn does not revert it to its original kernel state.',
    'l_ice': 'Ice Cube',
    'l_tray': 'Plastic Tray',
    'l_beaker': 'Glass Beaker',
    'l_pad': 'Heating Pad',
    'l_freezer': 'Freezer',
    'l_machine': 'Popcorn Machine',
    'l_scoop': 'Kernels Scoop',
    'l_bowl': 'Ceramic Bowl',
    'l_recovered': 'Ice Cube\n(Recovered)',
    'l_kernels': 'Kernels',
    'l_popcorn': 'Popcorn',
    'l_temp': '{t}°C',
    'msg_heaterOff': 'Heater OFF. Now OPEN the freezer door.',
    'err_heaterOn': 'Turn OFF the heating pad first!',
    'msg_doorOpenBeaker': 'Door opened. Now DRAG the beaker inside.',
    'msg_doorOpenBowl': 'Door opened. Now DRAG the bowl inside.',
    'msg_doorOpenDesk': 'Door opened. Now DRAG the container to the desk.',
    'msg_heatingBeaker': 'Heating active! Beaker warming...',
    'msg_popping': 'Machine popping kernels...',
    'err_scoop': 'Drag the scoop over the top of the Popcorn Machine to pour.',
    'err_doorClosed': 'Open the freezer door first!',
    'msg_placed': 'Container placed! Closing freezer door automatically...',
    'err_freezerDrop': 'Drop the container inside the virtual freezer cavity.',
    'err_deskDrop': 'Drag the container back onto the desk.',
    'msg_waitTemp': 'Waiting for temperature to drop...',
    'msg_wait10': 'Waiting for 10 seconds...',
    'msg_waitX': 'Waiting for {sec} seconds...',
    'msg_cooled': 'Cooling complete. Now OPEN the freezer door.',
    'err_general': 'Oops! Incorrect action. Please read the instruction.',
    'msg_greatJob': 'Great job! Proceeding...',
    'msg_clickOn': "Perfect. Now CLICK the red 'ON' button on the pad.",
    'msg_clickCorrect': 'Perfect. Now CLICK the correct button/door to proceed.',
    'type_rev_short': 'Reversible Process',
    'type_irrev_short': 'Irreversible Process',
    // Not in the HTML (added guard / readouts).
    'err_beakerFirst': 'Place the beaker on the heating pad first!',
    'ctl_temp': 'Temperature',
    'ctl_heater': 'Heating Pad',
    'ctl_on': 'ON',
    'ctl_off': 'OFF',
    'ctl_door': 'Freezer Door',
    'ctl_open': 'Open',
    'ctl_closed': 'Closed',
    'ctl_wait': 'Cooling time left',
    'ctl_sec': '{sec} s',
    'btn_on': 'ON',
    'btn_off': 'OFF',
    'btn_start': 'START',
  },
  'hi': {
    'appTitle': 'प्रतिवर्ती और अपरिवर्तनीय परिवर्तन',
    'appSubtitle': 'कक्षा 7 • हमारे चारों ओर के परिवर्तन',
    'currentTask': 'वर्तमान कार्य',
    'typeRev': 'प्रकार: प्रतिवर्ती परिवर्तन',
    'typeIrrev': 'प्रकार: अपरिवर्तनीय परिवर्तन',
    'scen1Title': 'परिदृश्य 1: बर्फ के टुकड़े की यात्रा',
    'scen2Title': 'परिदृश्य 2: पॉपकॉर्न पहेली',
    'scenComplete': 'परिदृश्य पूर्ण!',
    'obsOutcome': 'अवलोकन परिणाम',
    'whatWeLearnt': 'हमने क्या सीखा:',
    's1_sum':
        'आपने सफलतापूर्वक एक **प्रतिवर्ती परिवर्तन** का प्रदर्शन किया है। ठोस बर्फ को तरल पानी में पिघलाना और फिर उसे वापस ठोस बर्फ में जमाना यह साबित करता है कि पूरी प्रक्रिया में पदार्थ पानी (H₂O) ही रहता है और मूल अवस्था प्राप्त की जा सकती है।',
    's2_sum':
        'आपने सफलतापूर्वक एक **अपरिवर्तनीय परिवर्तन** का प्रदर्शन किया है। मकई का फूटना गर्मी के कारण होने वाला एक स्थायी रासायनिक और भौतिक परिवर्तन है। पॉपकॉर्न को ठंडा करने से वह वापस अपनी मूल दाने की अवस्था में नहीं लौटता।',
    'l_ice': 'बर्फ का टुकड़ा',
    'l_tray': 'प्लास्टिक ट्रे',
    'l_beaker': 'कांच का बीकर',
    'l_pad': 'हीटिंग पैड',
    'l_freezer': 'फ्रीजर',
    'l_machine': 'पॉपकॉर्न मशीन',
    'l_scoop': 'स्कूप',
    'l_bowl': 'सिरेमिक कटोरा',
    'l_recovered': 'बर्फ\n(बरामद)',
    'l_kernels': 'मकई के दाने',
    'l_popcorn': 'पॉपकॉर्न',
    'l_temp': '{t}°C',
    'msg_heaterOff': 'हीटर बंद। अब फ्रीजर का दरवाजा खोलें।',
    'err_heaterOn': 'पहले हीटिंग पैड को बंद करें!',
    'msg_doorOpenBeaker': 'दरवाजा खुल गया। अब बीकर को अंदर खींचें।',
    'msg_doorOpenBowl': 'दरवाजा खुल गया। अब कटोरे को अंदर खींचें।',
    'msg_doorOpenDesk': 'दरवाजा खुल गया। अब कंटेनर को डेस्क पर खींचें।',
    'msg_heatingBeaker': 'हीटिंग सक्रिय! बीकर गर्म हो रहा है...',
    'msg_popping': 'मशीन पॉपकॉर्न बना रही है...',
    'err_scoop': 'पॉपकॉर्न मशीन के ऊपर से स्कूप को खींचकर डालें।',
    'err_doorClosed': 'पहले फ्रीजर का दरवाजा खोलें!',
    'msg_placed': 'कंटेनर रखा गया! फ्रीजर का दरवाजा स्वचालित रूप से बंद हो रहा है...',
    'err_freezerDrop': 'कंटेनर को वर्चुअल फ्रीजर के अंदर छोड़ें।',
    'err_deskDrop': 'कंटेनर को वापस डेस्क पर खींचें।',
    'msg_waitTemp': 'तापमान गिरने की प्रतीक्षा करें...',
    'msg_wait10': '10 सेकंड तक प्रतीक्षा करें...',
    'msg_waitX': '{sec} सेकंड तक प्रतीक्षा करें...',
    'msg_cooled': 'ठंडा हो गया। अब फ्रीजर का दरवाजा खोलें।',
    'err_general': 'उफ़! गलत क्रिया। कृपया निर्देश पढ़ें।',
    'msg_greatJob': 'बहुत बढ़िया! आगे बढ़ रहे हैं...',
    'msg_clickOn': "उत्तम। अब पैड पर लाल 'ON' बटन पर क्लिक करें।",
    'msg_clickCorrect': 'उत्तम। अब आगे बढ़ने के लिए सही बटन/दरवाजे पर क्लिक करें।',
    'type_rev_short': 'प्रतिवर्ती प्रक्रिया',
    'type_irrev_short': 'अपरिवर्तनीय प्रक्रिया',
    'err_beakerFirst': 'पहले बीकर को हीटिंग पैड पर रखें!',
    'ctl_temp': 'तापमान',
    'ctl_heater': 'हीटिंग पैड',
    'ctl_on': 'चालू',
    'ctl_off': 'बंद',
    'ctl_door': 'फ्रीजर का दरवाजा',
    'ctl_open': 'खुला',
    'ctl_closed': 'बंद',
    'ctl_wait': 'ठंडा होने का शेष समय',
    'ctl_sec': '{sec} सेकंड',
    'btn_on': 'ON',
    'btn_off': 'OFF',
    'btn_start': 'START',
  },
};

// HTML steps: `sX_sN_t` → concept, `sX_sN_i` → action, `sX_sN_th` → observation.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To observe and demonstrate that a change of state (melting and freezing) is a reversible process.',
      steps: [
        LabStep(
          concept: 'Move Ice to Beaker',
          action: 'DRAG the ice cube from the tray and DROP it into the glass beaker.',
          observation:
              'Matter can change state when heated or cooled. We start with a solid ice cube. A physical change is often reversible.',
        ),
        LabStep(
          concept: 'Apply Heat',
          action: "DRAG the beaker to the heating pad. Then CLICK the red 'ON' button.",
          observation:
              'Heating the solid ice increases the energy of water molecules, causing them to break rigid bonds and melt into liquid.',
        ),
        LabStep(
          concept: 'Cool it down',
          action:
              "CLICK the red 'OFF' button. Then OPEN the freezer door and DRAG the beaker inside. CLOSE the freezer door.",
          observation:
              "The ice has melted into liquid water. Let's see if we can reverse this change by removing heat.",
        ),
        LabStep(
          concept: 'Wait and Observe',
          action: 'WAIT for the temperature to drop. Then OPEN the door and DRAG the beaker back to the desk.',
          observation:
              'The cold environment is removing heat from the liquid water. The temperature needs to drop back to 0°C.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'OBSERVE the initial ice cube and the final ice cube side-by-side on the summary screen.',
          observation:
              'The water has returned to solid ice! This process is reversible because we recovered our starting material.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To observe and demonstrate that making popcorn is an irreversible process where the original substance cannot be recovered.',
      steps: [
        LabStep(
          concept: 'Prepare the Machine',
          action:
              'DRAG the scoop of corn kernels and DROP them into the popcorn machine through the top opening.',
          observation: 'Some changes alter the internal structure and composition of a material permanently.',
        ),
        LabStep(
          concept: 'Pop the Corn',
          action: "CLICK the green 'START' button on the popcorn machine.",
          observation:
              'Applying heat causes the moisture inside the kernel to turn to steam. The pressure builds until it bursts!',
        ),
        LabStep(
          concept: 'Collect Popcorn',
          action: "DRAG the freshly made popcorn from the machine's tray and PLACE it into a bowl.",
          observation: 'The physical and chemical structure of the corn has changed drastically.',
        ),
        LabStep(
          concept: 'Attempt to Reverse',
          action:
              "Now, let's try to reverse it. DRAG the bowl of popcorn and PLACE it inside the virtual freezer. CLOSE the freezer door.",
          observation: "Let's test if cooling can reverse this change, just like it did with water.",
        ),
        LabStep(
          concept: 'Observe Result',
          action:
              'WAIT for 10 seconds, then OPEN the freezer door. DRAG the bowl back to the lab bench. OBSERVE the contents.',
          observation: 'Cooling the popcorn will lower its temperature, but will it revert?',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'OBSERVE the initial corn kernels and the final popcorn side-by-side on the summary screen.',
          observation: 'The popcorn is cold, but it has not reverted to kernels. A new substance was formed.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह देखने और प्रदर्शित करने के लिए कि अवस्था परिवर्तन (पिघलना और जमना) एक प्रतिवर्ती प्रक्रिया है।',
      steps: [
        LabStep(
          concept: 'बर्फ को बीकर में डालें',
          action: 'बर्फ के टुकड़े को ट्रे से खींचें और कांच के बीकर में छोड़ दें।',
          observation: 'गर्म या ठंडा होने पर पदार्थ की अवस्था बदल सकती है। भौतिक परिवर्तन अक्सर प्रतिवर्ती होता है।',
        ),
        LabStep(
          concept: 'गर्मी दें',
          action: "बीकर को हीटिंग पैड पर खींचें। फिर लाल 'ON' बटन पर क्लिक करें।",
          observation:
              'ठोस बर्फ को गर्म करने से पानी के अणुओं की ऊर्जा बढ़ जाती है, जिससे वे पिघलकर तरल हो जाते हैं।',
        ),
        LabStep(
          concept: 'इसे ठंडा करें',
          action:
              "लाल 'OFF' बटन पर क्लिक करें। फिर फ्रीजर का दरवाजा खोलें और बीकर को अंदर खींचें। फ्रीजर का दरवाजा बंद करें।",
          observation:
              'बर्फ पिघलकर तरल पानी बन गई है। आइए देखें कि क्या हम गर्मी हटाकर इस परिवर्तन को उलट सकते हैं।',
        ),
        LabStep(
          concept: 'प्रतीक्षा करें और देखें',
          action: 'तापमान गिरने की प्रतीक्षा करें। फिर दरवाजा खोलें और बीकर को वापस डेस्क पर खींचें।',
          observation: 'ठंडा वातावरण तरल पानी से गर्मी निकाल रहा है। तापमान को 0°C तक गिरने की आवश्यकता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश स्क्रीन पर शुरुआती बर्फ और अंतिम बर्फ को एक साथ देखें।',
          observation:
              'पानी वापस ठोस बर्फ बन गया है! यह प्रक्रिया प्रतिवर्ती है क्योंकि हमने अपनी शुरुआती सामग्री प्राप्त कर ली है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह देखने और प्रदर्शित करने के लिए कि पॉपकॉर्न बनाना एक अपरिवर्तनीय प्रक्रिया है जहाँ मूल पदार्थ वापस नहीं प्राप्त किया जा सकता।',
      steps: [
        LabStep(
          concept: 'मशीन तैयार करें',
          action: 'मक्के के दानों के स्कूप को खींचें और उन्हें मशीन के ऊपर से पॉपकॉर्न मशीन में छोड़ दें।',
          observation: 'कुछ परिवर्तन किसी सामग्री की आंतरिक संरचना और संरचना को स्थायी रूप से बदल देते हैं।',
        ),
        LabStep(
          concept: 'पॉपकॉर्न बनाएं',
          action: "पॉपकॉर्न मशीन पर हरे 'START' बटन पर क्लिक करें।",
          observation:
              'गर्मी लगाने से दाने के अंदर की नमी भाप में बदल जाती है। दबाव तब तक बढ़ता है जब तक वह फट न जाए!',
        ),
        LabStep(
          concept: 'पॉपकॉर्न इकट्ठा करें',
          action: 'ताज़ा बने पॉपकॉर्न को मशीन की ट्रे से खींचें और कटोरे में रखें।',
          observation: 'मकई की भौतिक और रासायनिक संरचना में भारी परिवर्तन आया है।',
        ),
        LabStep(
          concept: 'उलटने का प्रयास करें',
          action:
              'अब, इसे उलटने का प्रयास करें। पॉपकॉर्न के कटोरे को खींचें और इसे वर्चुअल फ्रीजर के अंदर रखें। फ्रीजर का दरवाजा बंद करें।',
          observation: 'आइए जांचें कि क्या पानी की तरह ठंडा करने से इस परिवर्तन को उलट सकते हैं।',
        ),
        LabStep(
          concept: 'परिणाम देखें',
          action: '10 सेकंड तक प्रतीक्षा करें, फिर फ्रीज़र का दरवाजा खोलें। कटोरे को वापस डेस्क पर लाएँ।',
          observation: 'पॉपकॉर्न को ठंडा करने से उसका तापमान कम हो जाएगा, लेकिन क्या यह वापस आएगा?',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सारांश स्क्रीन पर शुरुआती मक्के के दानों और अंतिम पॉपकॉर्न को एक साथ देखें।',
          observation: 'पॉपकॉर्न ठंडा है, लेकिन यह वापस दानों में नहीं बदला है। एक नया पदार्थ बन गया है।',
        ),
      ],
    ),
  ],
};

// ================================================================ PAINTER
//
// 2.5D version of the Three.js lab: dark desk (0x2c3e50) against the wall
// (0x1e293b), the two-door freezer (0xcdddf4) on the left, and either the
// ice tray / beaker / thermometer / heating pad (scenario 1) or the popcorn
// machine / scoop / ceramic bowl (scenario 2). Colours are the HTML values.

const Color _cWall = Color(0xFF1E293B);
const Color _cDesk = Color(0xFF2C3E50);
const Color _cFridge = Color(0xFFCDDDF4);
const Color _cFridgeIn = Color(0xFF94A3B8);
const Color _cIce = Color(0xFF0284C7);
const Color _cTrayRed = Color(0xFFEF4444);
const Color _cGlass = Color(0xFFF1F5F9);
const Color _cWater = Color(0xFF3B82F6);
const Color _cHeater = Color(0xFF94A3B8);
const Color _cMachineGlass = Color(0xFFBAE6FD);
const Color _cGreen = Color(0xFF22C55E);
const Color _cKernel = Color(0xFFFFD700);
const Color _cPopcorn = Color(0xFFFFFDD0);
const Color _cBowl = Color(0xFF3B82F6);
const Color _cBowlCold = Color(0xFFA5F3FC);

/// Seeded random layouts (the HTML used Math.random at build time).
List<List<double>> _seeded(int seed, int n, int k) {
  final r = math.Random(seed);
  return List.generate(n, (_) => List.generate(k, (_) => r.nextDouble()));
}

final List<List<double>> _machineKernelSeeds = _seeded(21, 30, 2);
final List<List<double>> _machinePopSeeds = _seeded(22, 25, 3);
final List<List<double>> _trayPopSeeds = _seeded(23, 15, 3);
final List<List<double>> _bowlPopSeeds = _seeded(24, 20, 3);
final List<List<double>> _scoopKernelSeeds = _seeded(25, 30, 2);

class _A5Painter extends CustomPainter {
  _A5Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
  }) : super(repaint: repaint);

  final _A5Scene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;

  String _tr(String key) => labTr(_i18n, lang, key);
  double get _time => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-_crop.left, -_crop.top);
    _background(canvas);
    _freezer(canvas);
    if (scene.isIce) {
      _iceTray(canvas);
      if (!scene.iceInBeaker && scene.drag != _Obj.ice) {
        _iceCube(canvas, scene.pos(_Obj.ice), 46, 1);
      }
      _thermometer(canvas);
      _heater(canvas);
      if (scene.drag != _Obj.beaker && !scene.inFreezer(_Obj.beaker)) {
        _beaker(canvas, scene.pos(_Obj.beaker), _containerScale(_Obj.beaker));
      }
    } else {
      _machine(canvas);
      if (scene.drag != _Obj.scoop) _scoop(canvas, scene.pos(_Obj.scoop));
      if (scene.drag != _Obj.bowl && !scene.inFreezer(_Obj.bowl)) {
        _bowl(canvas, scene.pos(_Obj.bowl), _containerScale(_Obj.bowl));
      }
      _pourKernels(canvas);
    }
    _hint(canvas);
    if (showLabels) _labels(canvas);
    final d = scene.drag;
    if (d != null) {
      final p = scene.dragPos;
      labGroundShadow(canvas, Offset(p.dx + 12, math.max(p.dy + 30, 300)), 120, 22, opacity: 0.35);
      switch (d) {
        case _Obj.ice:
          _iceCube(canvas, p, 50, 1);
        case _Obj.beaker:
          _beaker(canvas, p, 1.04);
        case _Obj.bowl:
          _bowl(canvas, p, 1.04);
        case _Obj.scoop:
          _scoop(canvas, p);
        case _Obj.tray:
          _tray(canvas, p);
        default:
          break;
      }
    }
    canvas.restore();
  }

  /// Scale of a container moving into / out of the freezer cavity.
  double _containerScale(_Obj o) {
    final spot = o == _Obj.bowl ? scene.bowlSpot : scene.beakerSpot;
    final m = scene.moves[o];
    if (m != null && !m.done(_time)) {
      final t = Curves.easeInOutCubic.transform(m.t(_time));
      if (spot == _Spot.freezer) return 1 + (_freezerScale - 1) * t;
      if (m.from == _freezerSlot) return _freezerScale + (1 - _freezerScale) * t;
      return 1;
    }
    return spot == _Spot.freezer ? _freezerScale : 1;
  }

  // ---------------------------------------------------------- backdrop

  void _background(Canvas canvas) {
    final bleed = labBleed(_design);
    const deskY = 236.0;
    const frontY = 532.0;
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, bleed.top, bleed.right, deskY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cWall, -0.35), _cWall, labShade(_cWall, 0.06)],
          stops: const [0, 0.6, 1],
        ).createShader(const Rect.fromLTRB(0, -60, 1000, deskY)),
    );
    // Key light from the upper right on the wall.
    canvas.drawCircle(
      const Offset(760, 40),
      520,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.white.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: const Offset(760, 40), radius: 520)),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, deskY, bleed.right, frontY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cDesk, -0.25), _cDesk, labShade(_cDesk, 0.08)],
          stops: const [0, 0.5, 1],
        ).createShader(const Rect.fromLTRB(0, deskY, 1000, frontY)),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, frontY, bleed.right, bleed.bottom),
      Paint()..color = labShade(_cDesk, -0.45),
    );
    canvas.drawLine(
      Offset(bleed.left, frontY),
      Offset(bleed.right, frontY),
      Paint()
        ..strokeWidth = 2
        ..color = labShade(_cDesk, 0.35),
    );
    canvas.drawLine(
      Offset(bleed.left, deskY),
      Offset(bleed.right, deskY),
      Paint()
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      const Offset(560, 400),
      380,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF90B0D0).withValues(alpha: 0.10),
          const Color(0xFF90B0D0).withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: const Offset(560, 400), radius: 380)),
    );
  }

  // ------------------------------------------------------------ labels

  /// HTML `.scene-label` (dark pill, bold white text, light border).
  void _label(Canvas canvas, String text, Offset c, {double size = 14, Color color = Colors.white}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1.25,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    const padH = 10.0, padV = 4.0;
    final w = tp.width + padH * 2, h = tp.height + padV * 2;
    final left = (c.dx - w / 2).clamp(_crop.left + 4, math.max(_crop.left + 4, _crop.right - 4 - w)).toDouble();
    final top = (c.dy - h / 2).clamp(_crop.top + 4, math.max(_crop.top + 4, _crop.bottom - 4 - h)).toDouble();
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, w, h), const Radius.circular(6));
    canvas.drawRRect(
      rr.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(rr, Paint()..color = const Color(0xCC000000));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    tp.paint(canvas, Offset(left + padH, top + padV));
  }

  void _labels(Canvas canvas) {
    _label(canvas, _tr('l_freezer'), const Offset(160, 64));
    if (scene.isIce) {
      _label(canvas, _tr('l_tray'), const Offset(352, 492));
      if (!scene.iceInBeaker && scene.drag != _Obj.ice) {
        _label(canvas, _tr('l_ice'), scene.pos(_Obj.ice).translate(0, -80));
      }
      final b = scene.drag == _Obj.beaker ? scene.dragPos : scene.pos(_Obj.beaker);
      final k = scene.drag == _Obj.beaker ? 1.0 : _containerScale(_Obj.beaker);
      _label(canvas, _tr('l_beaker'), b.translate(0, -132 * k));
      _label(canvas, _tr('l_pad'), const Offset(724, 494));
      _label(
        canvas,
        labFormat(_tr('l_temp'), {'t': scene.temp.round()}),
        _thermoBulb.translate(0, -190),
        color: const Color(0xFFFCA5A5),
      );
      return;
    }
    _label(canvas, _tr('l_machine'), const Offset(532, 152));
    final sc = scene.drag == _Obj.scoop ? scene.dragPos : scene.pos(_Obj.scoop);
    _label(canvas, _tr('l_scoop'), sc.translate(30, -62));
    final bw = scene.drag == _Obj.bowl ? scene.dragPos : scene.pos(_Obj.bowl);
    final k = scene.drag == _Obj.bowl ? 1.0 : _containerScale(_Obj.bowl);
    _label(canvas, _tr('l_bowl'), bw.translate(0, -112 * k));
  }

  @override
  bool shouldRepaint(covariant _A5Painter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;

  // ------------------------------------------------------------ freezer

  /// Two-compartment fridge (0xcdddf4) with the freezer cavity on top.
  void _freezer(Canvas canvas) {
    labGroundShadow(canvas, const Offset(176, 474), 300, 30, opacity: 0.55);
    const front = Rect.fromLTRB(40, 120, 250, 470);
    final top = Path()
      ..moveTo(40, 120)
      ..lineTo(250, 120)
      ..lineTo(280, 84)
      ..lineTo(70, 84)
      ..close();
    final side = Path()
      ..moveTo(250, 120)
      ..lineTo(280, 84)
      ..lineTo(280, 434)
      ..lineTo(250, 470)
      ..close();
    canvas.drawPath(
      side,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cFridge, -0.28), labShade(_cFridge, -0.45)],
        ).createShader(const Rect.fromLTRB(250, 84, 280, 470)),
    );
    canvas.drawPath(top, Paint()..color = labShade(_cFridge, 0.12));
    canvas.drawRect(
      front,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_cFridge, -0.08),
          labShade(_cFridge, 0.12),
          labShade(_cFridge, -0.05),
        ]).createShader(front),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = labShade(_cFridge, -0.4);
    canvas.drawRect(front, edge);
    canvas.drawPath(top, edge);
    canvas.drawPath(side, edge);
    canvas.drawLine(const Offset(40, 256), const Offset(250, 256), Paint()
      ..strokeWidth = 3
      ..color = labShade(_cFridge, -0.32));
    canvas.drawRect(
      const Rect.fromLTRB(46, 262, 244, 464),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(_cFridge, -0.22),
    );
    _handle(canvas, const Offset(218, 355), 80, 1);
    _cavityInterior(canvas);
    final o = scene.isIce ? _Obj.beaker : _Obj.bowl;
    if (scene.inFreezer(o)) {
      canvas.save();
      canvas.clipRect(_cavity);
      if (o == _Obj.beaker) {
        _beaker(canvas, scene.pos(o), _freezerScale);
      } else {
        _bowl(canvas, scene.pos(o), _freezerScale);
      }
      canvas.restore();
    }
    _door(canvas);
  }

  void _cavityInterior(Canvas canvas) {
    const c = _cavity;
    const d = Offset(24, -28); // depth of the cavity
    final back = c.shift(d);
    canvas.save();
    canvas.clipRect(c);
    canvas.drawRect(c, Paint()..color = labShade(_cFridgeIn, -0.4));
    final left = Path()
      ..moveTo(c.left, c.top)
      ..lineTo(back.left, back.top)
      ..lineTo(back.left, back.bottom)
      ..lineTo(c.left, c.bottom)
      ..close();
    canvas.drawPath(left, Paint()..color = labShade(_cFridge, -0.2));
    final floor = Path()
      ..moveTo(c.left, c.bottom)
      ..lineTo(c.right, c.bottom)
      ..lineTo(back.right, back.bottom)
      ..lineTo(back.left, back.bottom)
      ..close();
    canvas.drawPath(floor, Paint()..color = labShade(_cFridge, -0.08));
    canvas.drawRect(
      back,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cFridgeIn, -0.15), _cFridgeIn],
        ).createShader(back),
    );
    // Cold glow and frost along the top.
    canvas.drawRect(
      c,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.7),
          radius: 1.1,
          colors: [Color(0x66E0F2FE), Color(0x00E0F2FE)],
        ).createShader(c),
    );
    final icicle = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 9; i++) {
      final x = c.left + 14 + i * 20.0;
      final h = 5.0 + (i * 7 % 6);
      canvas.drawPath(
        Path()
          ..moveTo(x - 3, c.top)
          ..lineTo(x + 3, c.top)
          ..lineTo(x, c.top + h)
          ..close(),
        icicle,
      );
    }
    canvas.restore();
    canvas.drawRect(
      c,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = labShade(_cFridge, -0.38),
    );
  }

  void _handle(Canvas canvas, Offset c, double h, double widthK) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 9 * widthK, height: h),
      const Radius.circular(4),
    );
    canvas.drawRRect(rr.shift(const Offset(2, 2)), Paint()..color = Colors.black.withValues(alpha: 0.2));
    canvas.drawRRect(rr, Paint()..color = _cFridgeIn);
    canvas.drawLine(
      Offset(c.dx - 1.5 * widthK, c.dy - h / 2 + 5),
      Offset(c.dx - 1.5 * widthK, c.dy + h / 2 - 5),
      Paint()
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  /// Freezer door hinged on its right edge (HTML pivot rotation 0 → −π/2).
  void _door(Canvas canvas) {
    final a = scene.door * math.pi / 2;
    const r = Rect.fromLTRB(38, 118, 252, 258);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = labShade(_cFridge, -0.42);
    if (a < 0.001) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(4));
      canvas.drawRRect(
        rr.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(colors: [
            labShade(_cFridge, -0.04),
            labShade(_cFridge, 0.14),
            labShade(_cFridge, -0.02),
          ]).createShader(r),
      );
      canvas.drawRRect(rr, edge);
      canvas.drawRect(
        r.deflate(6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = labShade(_cFridge, -0.2),
      );
      _handle(canvas, Offset(r.left + 18, r.center.dy), 66, 1);
      return;
    }
    const px = 252.0;
    final cosA = math.cos(a), sinA = math.sin(a);
    final fx = px - r.width * cosA + 74 * sinA;
    final hh = r.height / 2 * (1 + 0.12 * sinA);
    final cy = r.center.dy + 7 * sinA;
    final quad = Path()
      ..moveTo(px, r.top)
      ..lineTo(fx, cy - hh)
      ..lineTo(fx, cy + hh)
      ..lineTo(px, r.bottom)
      ..close();
    final outer = fx < px - 1;
    canvas.drawPath(
      quad.shift(const Offset(3, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      quad,
      Paint()..color = outer ? labShade(_cFridge, -0.3 * sinA) : const Color(0xFFE2E8F0),
    );
    canvas.drawPath(quad, edge);
    if (outer) {
      _handle(canvas, Offset(fx + (px - fx) * 0.09, cy), 66 * (1 + 0.12 * sinA), cosA.clamp(0.25, 1.0));
    } else {
      // Inner face: gasket and door shelf.
      final k = 0.12;
      final inner = Path()
        ..moveTo(px + (fx - px) * k, r.top + 8)
        ..lineTo(fx - (fx - px) * k, cy - hh + 10)
        ..lineTo(fx - (fx - px) * k, cy + hh - 10)
        ..lineTo(px + (fx - px) * k, r.bottom - 8)
        ..close();
      canvas.drawPath(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _cFridgeIn,
      );
      canvas.drawLine(
        Offset(px + (fx - px) * 0.15, r.center.dy + 22),
        Offset(fx - (fx - px) * 0.15, cy + 26),
        Paint()
          ..strokeWidth = 3
          ..color = labShade(_cFridgeIn, -0.1),
      );
    }
  }

  // ------------------------------------------------------ scenario 1

  /// Red plastic ice tray (BoxGeometry 4 × 0.4 × 4, 0xef4444).
  void _iceTray(Canvas canvas) {
    labGroundShadow(canvas, const Offset(358, 466), 160, 20, opacity: 0.4);
    final top = Path()
      ..moveTo(285, 452)
      ..lineTo(405, 452)
      ..lineTo(425, 428)
      ..lineTo(305, 428)
      ..close();
    final side = Path()
      ..moveTo(405, 452)
      ..lineTo(425, 428)
      ..lineTo(425, 440)
      ..lineTo(405, 464)
      ..close();
    canvas.drawRect(const Rect.fromLTRB(285, 452, 405, 464), Paint()..color = labShade(_cTrayRed, -0.25));
    canvas.drawPath(side, Paint()..color = labShade(_cTrayRed, -0.45));
    canvas.drawPath(top, Paint()..color = labShade(_cTrayRed, 0.1));
    // Moulded compartments.
    final mould = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = labShade(_cTrayRed, -0.3);
    for (var i = 1; i < 4; i++) {
      final x = 285 + i * 30.0;
      canvas.drawLine(Offset(x, 452), Offset(x + 20, 428), mould);
    }
    canvas.drawLine(const Offset(295, 440), const Offset(415, 440), mould);
  }

  /// Translucent ice cube (BoxGeometry 1.6, 0x0284c7 @ 0.85, white edges).
  void _iceCube(Canvas canvas, Offset bottom, double size, double opacity) {
    if (size < 1.5) return;
    final f = Rect.fromLTWH(bottom.dx - size / 2, bottom.dy - size, size, size);
    final dv = Offset(size * 0.24, -size * 0.27);
    final top = Path()
      ..moveTo(f.left, f.top)
      ..lineTo(f.right, f.top)
      ..lineTo(f.right + dv.dx, f.top + dv.dy)
      ..lineTo(f.left + dv.dx, f.top + dv.dy)
      ..close();
    final side = Path()
      ..moveTo(f.right, f.top)
      ..lineTo(f.right + dv.dx, f.top + dv.dy)
      ..lineTo(f.right + dv.dx, f.bottom + dv.dy)
      ..lineTo(f.right, f.bottom)
      ..close();
    final a = 0.85 * opacity;
    canvas.drawPath(side, Paint()..color = labShade(_cIce, -0.25).withValues(alpha: a));
    canvas.drawPath(top, Paint()..color = labShade(_cIce, 0.4).withValues(alpha: a));
    canvas.drawRect(
      f,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_cIce, 0.25).withValues(alpha: a), _cIce.withValues(alpha: a)],
        ).createShader(f),
    );
    final e = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, size / 30)
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.9 * opacity);
    canvas.drawRect(f, e);
    canvas.drawPath(top, e);
    canvas.drawPath(side, e);
    canvas.drawLine(
      f.topLeft + Offset(size * 0.18, size * 0.2),
      f.topLeft + Offset(size * 0.18, size * 0.65),
      Paint()
        ..strokeWidth = math.max(1.5, size / 16)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45 * opacity),
    );
  }

  /// Glass beaker (open cylinder r 2 × 4, 0xf1f5f9 @ 0.4, white edges)
  /// with melt water (0x3b82f6) and the ice cube inside.
  void _beaker(Canvas canvas, Offset b, double k) {
    final w = 120 * k, h = 108 * k, eh = 22 * k;
    final hw = w / 2;
    final topY = b.dy - h;
    final rim = Rect.fromCenter(center: Offset(b.dx, topY), width: w, height: eh);
    final base = Rect.fromCenter(center: b, width: w, height: eh);
    if (k > 0.95) labGroundShadow(canvas, b.translate(8, 4), w + 26, 18, opacity: 0.4);
    final body = Path()
      ..moveTo(b.dx - hw, topY)
      ..lineTo(b.dx - hw, b.dy)
      ..arcTo(base, math.pi, -math.pi, false)
      ..lineTo(b.dx + hw, topY)
      ..arcTo(rim, 0, -math.pi, false)
      ..close();
    canvas.drawPath(body, Paint()..color = _cGlass.withValues(alpha: 0.16));
    canvas.drawOval(base.deflate(2 * k), Paint()..color = Colors.white.withValues(alpha: 0.3));

    if (scene.waterVisible && scene.melt > 0) {
      final level = 81 * k * scene.melt;
      final wy = b.dy - 3 * k - level;
      final inner = base.deflate(3 * k);
      final water = Path()
        ..moveTo(b.dx - hw + 3 * k, wy)
        ..lineTo(b.dx - hw + 3 * k, b.dy)
        ..arcTo(inner, math.pi, -math.pi, false)
        ..lineTo(b.dx + hw - 3 * k, wy)
        ..close();
      canvas.drawPath(
        water,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [labShade(_cWater, 0.15).withValues(alpha: 0.8), labShade(_cWater, -0.2).withValues(alpha: 0.8)],
          ).createShader(Rect.fromLTRB(b.dx - hw, wy, b.dx + hw, b.dy + eh)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(b.dx, wy), width: w - 6 * k, height: eh - 4 * k),
        Paint()..color = labShade(_cWater, 0.35).withValues(alpha: 0.85),
      );
    }
    if (scene.iceInBeaker) {
      final s = scene.iceRefrozen ? 1.0 : 1 - scene.melt;
      final drop = ((_time - scene.iceDropAt) / 0.4).clamp(0.0, 1.0);
      final yOff = -80 * k * (1 - Curves.bounceOut.transform(drop));
      _iceCube(canvas, Offset(b.dx, b.dy - 16 * k + yOff), 46 * k * s, 1);
    }

    final glassEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * k
      ..color = Colors.white.withValues(alpha: 0.85);
    final front = Path()
      ..moveTo(b.dx - hw, topY)
      ..lineTo(b.dx - hw, b.dy)
      ..arcTo(base, math.pi, -math.pi, false)
      ..lineTo(b.dx + hw, topY);
    canvas.drawPath(front, glassEdge);
    canvas.drawOval(rim, glassEdge);
    canvas.drawLine(
      Offset(b.dx - hw + 12 * k, topY + 16 * k),
      Offset(b.dx - hw + 12 * k, b.dy - 12 * k),
      Paint()
        ..strokeWidth = 5 * k
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  /// Thermometer (red bulb, glass tube, mercury 0 → 25 °C).
  void _thermometer(Canvas canvas) {
    const bulb = _thermoBulb;
    const tube = Rect.fromLTRB(606, 300, 624, 444);
    labGroundShadow(canvas, bulb.translate(6, 17), 46, 10, opacity: 0.4);
    final rr = RRect.fromRectAndRadius(tube, const Radius.circular(9));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFCCCCCC).withValues(alpha: 0.3));
    final scaleY = 0.05 + 2.6 * (scene.temp / 25);
    final mercTop = tube.bottom - (tube.height + 6) * (scaleY / 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(611, mercTop, 619, tube.bottom + 4), const Radius.circular(4)),
      Paint()..color = const Color(0xFFFF0000),
    );
    canvas.drawLine(
      Offset(613.5, mercTop + 3),
      Offset(613.5, tube.bottom),
      Paint()
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    final tick = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 0; i <= 5; i++) {
      final y = tube.bottom - (tube.height - 10) * i / 5;
      canvas.drawLine(Offset(tube.right - 6, y), Offset(tube.right - 1, y), tick);
    }
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    labSphere(canvas, bulb, 17, const Color(0xFFFF0000), shade: 0.4);
  }

  /// Heating pad (base 0x94a3b8, plate 0x333333 glowing 0xcc4400 when ON,
  /// red button that turns green while heating).
  void _heater(Canvas canvas) {
    labGroundShadow(canvas, const Offset(738, 474), 190, 22, opacity: 0.45);
    const front = Rect.fromLTRB(650, 440, 790, 470);
    final top = Path()
      ..moveTo(650, 440)
      ..lineTo(790, 440)
      ..lineTo(812, 414)
      ..lineTo(672, 414)
      ..close();
    final side = Path()
      ..moveTo(790, 440)
      ..lineTo(812, 414)
      ..lineTo(812, 444)
      ..lineTo(790, 470)
      ..close();
    canvas.drawPath(side, Paint()..color = labShade(_cHeater, -0.35));
    canvas.drawPath(top, Paint()..color = labShade(_cHeater, 0.15));
    canvas.drawRect(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cHeater, labShade(_cHeater, -0.2)],
        ).createShader(front),
    );
    const pc = Offset(731, 427);
    final plate = Rect.fromCenter(center: pc, width: 106, height: 24);
    canvas.drawOval(plate.shift(const Offset(0, 4)), Paint()..color = const Color(0xFF1A1A1A));
    final on = scene.heaterOn;
    if (on) {
      final pulse = 0.85 + 0.15 * math.sin(_time * 5);
      labGlow(canvas, pc.translate(0, -6), 95, const Color(0xFFFF6A00), intensity: 0.45 * pulse);
      canvas.drawOval(
        plate,
        Paint()
          ..shader = const RadialGradient(colors: [Color(0xFFFF8A3D), Color(0xFFCC4400), Color(0xFF7A2800)])
              .createShader(plate),
      );
    } else {
      canvas.drawOval(plate, Paint()..color = const Color(0xFF333333));
    }
    final coil = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = on ? const Color(0xFFFFC07A).withValues(alpha: 0.8) : const Color(0xFF555555);
    for (var i = 1; i <= 3; i++) {
      canvas.drawOval(plate.deflate(i * 9.0).translate(0, 0), coil);
    }
    // ON / OFF button on the front face.
    canvas.drawCircle(_heaterBtn, 14, Paint()..color = const Color(0xFF475569));
    labSphere(canvas, _heaterBtn, 10.5, on ? const Color(0xFF00FF00) : const Color(0xFFFF0000), shade: 0.35);
    labText(canvas, _tr(on ? 'btn_on' : 'btn_off'), _heaterBtn.translate(-34, 0),
        size: 11, color: const Color(0xFF1E293B), weight: FontWeight.w800);
  }

  // ------------------------------------------------------ scenario 2

  /// One piece of popcorn (three puffy lobes, 0xfffdd0).
  void _puff(Canvas canvas, Offset c, double r, double rot) {
    if (r <= 0.5) return;
    for (var i = 0; i < 3; i++) {
      final a = rot * 6 + i * 2.1;
      final p = c + Offset(math.cos(a), math.sin(a)) * r * 0.55;
      canvas.drawCircle(
        p,
        r * 0.72,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [Colors.white, _cPopcorn, labShade(_cPopcorn, -0.18)],
          ).createShader(Rect.fromCircle(center: p, radius: r * 0.72)),
      );
    }
    canvas.drawCircle(c + Offset(r * 0.2, r * 0.25), r * 0.14, Paint()..color = const Color(0xFFB45309));
  }

  /// Popcorn machine: red base (0xef4444), glass box (0xbae6fd @ 0.4, white
  /// edges), red lid, hanging pot, green START button and collector tray.
  void _machine(Canvas canvas) {
    labGroundShadow(canvas, const Offset(534, 474), 230, 26, opacity: 0.5);
    const d = Offset(22, -26);
    const base = Rect.fromLTRB(445, 390, 595, 470);
    final baseSide = Path()
      ..moveTo(595, 390)
      ..lineTo(617, 364)
      ..lineTo(617, 444)
      ..lineTo(595, 470)
      ..close();
    canvas.drawPath(baseSide, Paint()..color = labShade(_cTrayRed, -0.4));
    canvas.drawRect(
      base,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_cTrayRed, 0.08), labShade(_cTrayRed, -0.22)],
        ).createShader(base),
    );
    const gf = Rect.fromLTRB(449, 228, 591, 390);
    final gb = gf.shift(d);
    // Inside floor and back glass.
    final floor = Path()
      ..moveTo(gf.left, gf.bottom)
      ..lineTo(gf.right, gf.bottom)
      ..lineTo(gb.right, gb.bottom)
      ..lineTo(gb.left, gb.bottom)
      ..close();
    canvas.drawPath(floor, Paint()..color = labShade(_cTrayRed, -0.45));
    canvas.drawRect(gb, Paint()..color = _cMachineGlass.withValues(alpha: 0.12));
    final backEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRect(gb, backEdge);
    // Hanging pot (0x666666 → glowing 0xff4400 while popping).
    canvas.drawLine(const Offset(531, 216), const Offset(531, 262), Paint()
      ..strokeWidth = 3
      ..color = const Color(0xFF475569));
    final hot = scene.potHot;
    if (hot) labGlow(canvas, const Offset(531, 282), 70, const Color(0xFFFF4400), intensity: 0.5);
    labCylinder(canvas, const Rect.fromLTRB(495, 264, 567, 300),
        hot ? const Color(0xFFFF4400) : const Color(0xFF666666), tilt: 0.25);
    // Kernels shaking on the floor.
    if (scene.machineKernels) {
      for (var i = 0; i < _machineKernelSeeds.length; i++) {
        final s = _machineKernelSeeds[i];
        var p = Offset(466 + s[0] * 118 + s[1] * 18, 384 - s[1] * 20);
        if (scene.popping) p += Offset(math.sin(_time * 47 + i * 1.7) * 1.6, math.cos(_time * 39 + i) * 1.2);
        labSphere(canvas, p, 4.5, _cKernel, shade: 0.4);
      }
    }
    // Popped corn floating in the glass box.
    for (var i = 0; i < scene.popTimes.length && i < _machinePopSeeds.length; i++) {
      final s = _machinePopSeeds[i];
      final t = ((_time - scene.popTimes[i]) / 0.18).clamp(0.0, 1.0);
      final k = Curves.easeOutBack.transform(t);
      _puff(canvas, Offset(460 + s[0] * 128 + s[1] * 14, 372 - s[1] * 74), 8 * k, s[2]);
    }
    if (scene.drag != _Obj.tray) _tray(canvas, scene.pos(_Obj.tray));
    // Front glass and side glass with white edges.
    final gSide = Path()
      ..moveTo(gf.right, gf.top)
      ..lineTo(gb.right, gb.top)
      ..lineTo(gb.right, gb.bottom)
      ..lineTo(gf.right, gf.bottom)
      ..close();
    canvas.drawPath(gSide, Paint()..color = _cMachineGlass.withValues(alpha: 0.2));
    canvas.drawRect(gf, Paint()..color = _cMachineGlass.withValues(alpha: 0.16));
    final glassEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRect(gf, glassEdge);
    canvas.drawPath(gSide, glassEdge);
    canvas.drawLine(gf.topLeft, gb.topLeft, glassEdge);
    final shine = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawLine(const Offset(462, 300), const Offset(500, 240), shine);
    canvas.drawLine(const Offset(470, 340), const Offset(530, 246), shine);
    // Lid with its top opening.
    const lid = Rect.fromLTRB(441, 202, 599, 229);
    final lidTop = Path()
      ..moveTo(441, 202)
      ..lineTo(599, 202)
      ..lineTo(623, 176)
      ..lineTo(465, 176)
      ..close();
    final lidSide = Path()
      ..moveTo(599, 202)
      ..lineTo(623, 176)
      ..lineTo(623, 203)
      ..lineTo(599, 229)
      ..close();
    canvas.drawPath(lidSide, Paint()..color = labShade(_cTrayRed, -0.4));
    canvas.drawPath(lidTop, Paint()..color = labShade(_cTrayRed, 0.15));
    canvas.drawOval(Rect.fromCenter(center: const Offset(532, 189), width: 64, height: 13),
        Paint()..color = labShade(_cTrayRed, -0.65));
    canvas.drawRect(
      lid,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cTrayRed, labShade(_cTrayRed, -0.25)],
        ).createShader(lid),
    );
    // START button (green; red while popping).
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: _machineBtn, width: 36, height: 36), const Radius.circular(7)),
      Paint()..color = const Color(0xFF7F1D1D),
    );
    final btn = Rect.fromCenter(center: _machineBtn, width: 26, height: 26);
    final btnCol = scene.popping ? const Color(0xFFFF0000) : _cGreen;
    canvas.drawRRect(
      RRect.fromRectAndRadius(btn, const Radius.circular(5)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(btnCol, 0.3), labShade(btnCol, -0.2)],
        ).createShader(btn),
    );
    labText(canvas, _tr('btn_start'), _machineBtn.translate(0, 28),
        size: 10.5, color: Colors.white, weight: FontWeight.w800);
  }

  /// Green collector tray (0x22c55e); [p] is its front-top centre.
  void _tray(Canvas canvas, Offset p) {
    const hw = 52.0;
    final top = Path()
      ..moveTo(p.dx - hw, p.dy)
      ..lineTo(p.dx + hw, p.dy)
      ..lineTo(p.dx + hw + 16, p.dy - 18)
      ..lineTo(p.dx - hw + 16, p.dy - 18)
      ..close();
    final side = Path()
      ..moveTo(p.dx + hw, p.dy)
      ..lineTo(p.dx + hw + 16, p.dy - 18)
      ..lineTo(p.dx + hw + 16, p.dy - 6)
      ..lineTo(p.dx + hw, p.dy + 12)
      ..close();
    canvas.drawRect(Rect.fromLTRB(p.dx - hw, p.dy, p.dx + hw, p.dy + 12), Paint()..color = labShade(_cGreen, -0.2));
    canvas.drawPath(side, Paint()..color = labShade(_cGreen, -0.4));
    canvas.drawPath(top, Paint()..color = labShade(_cGreen, 0.12));
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = labShade(_cGreen, -0.35),
    );
    if (scene.trayPopcorn) {
      for (final s in _trayPopSeeds) {
        _puff(canvas, Offset(p.dx - 40 + s[0] * 84 + s[1] * 14, p.dy - 6 - s[1] * 12), 7.5, s[2]);
      }
    }
  }

  /// Kernels scoop (grey hemisphere 0xaaaaaa, handle 0x444444, yellow
  /// kernels). Tilts while pouring (HTML rotation.z 0 → 2π/3).
  void _scoop(Canvas canvas, Offset c) {
    var tilt = 0.0;
    if (scene.pourStart >= 0) {
      tilt = ((_time - scene.pourStart) / 0.35).clamp(0.0, 1.0) * (2 * math.pi / 3);
    }
    final resting = scene.drag != _Obj.scoop && scene.pourStart < 0 && !scene.moves.containsKey(_Obj.scoop) ||
        (scene.moves[_Obj.scoop]?.done(_time) ?? false);
    if (resting) labGroundShadow(canvas, c.translate(34, 38), 160, 16, opacity: 0.4);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-tilt);
    canvas.drawLine(const Offset(34, 2), const Offset(112, 2), Paint()
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF444444));
    canvas.drawLine(const Offset(40, -1), const Offset(108, -1), Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.2));
    final bowl = Path()
      ..moveTo(-36, 0)
      ..arcTo(const Rect.fromLTRB(-36, -34, 36, 34), math.pi, -math.pi, false)
      ..close();
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF8A8A8A), Color(0xFFD4D4D4), Color(0xFF7A7A7A)])
            .createShader(const Rect.fromLTRB(-36, 0, 36, 34)),
    );
    const rim = Rect.fromLTRB(-36, -10, 36, 10);
    canvas.drawOval(rim, Paint()..color = const Color(0xFF6B6B6B));
    if (scene.scoopFull) {
      for (final s in _scoopKernelSeeds) {
        labSphere(canvas, Offset((s[0] - 0.5) * 54, (s[1] - 0.5) * 12 - 4), 4.3, _cKernel, shade: 0.4);
      }
    }
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFCFCFCF),
    );
    canvas.restore();
  }

  /// Kernels falling from the tilted scoop into the machine.
  void _pourKernels(Canvas canvas) {
    if (scene.pourStart < 0) return;
    final t = _time - scene.pourStart - 0.18;
    if (t < 0) return;
    final tilt = (2 * math.pi / 3) * ((_time - scene.pourStart) / 0.35).clamp(0.0, 1.0);
    final c = scene.pos(_Obj.scoop);
    final lip = c + Offset(-36 * math.cos(tilt), 36 * math.sin(tilt));
    for (var i = 0; i < 18; i++) {
      final ph = t * 2.6 - i * 0.07;
      if (ph < 0 || ph > 1) continue;
      final p = lip + Offset((i % 5 - 2) * 3.5, 200 * ph * ph);
      if (p.dy > 382) continue;
      labSphere(canvas, p, 4.2, _cKernel, shade: 0.4);
    }
  }

  /// Ceramic bowl (hemisphere r 2, 0x3b82f6; frosty 0xa5f3fc once frozen).
  void _bowl(Canvas canvas, Offset b, double k) {
    final r = 60 * k;
    final rimY = b.dy - 52 * k;
    final rim = Rect.fromCenter(center: Offset(b.dx, rimY), width: 2 * r, height: 26 * k);
    if (k > 0.95) labGroundShadow(canvas, b.translate(8, 2), 2 * r + 24, 18, opacity: 0.4);
    final col = scene.bowlCold ? _cBowlCold : _cBowl;
    final body = Path()
      ..moveTo(b.dx - r, rimY)
      ..arcTo(Rect.fromLTRB(b.dx - r, rimY - 52 * k, b.dx + r, b.dy), math.pi, -math.pi, false)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(col, -0.35),
          labShade(col, 0.3),
          col,
          labShade(col, -0.4),
        ], stops: const [0, 0.3, 0.6, 1]).createShader(Rect.fromLTRB(b.dx - r, rimY, b.dx + r, b.dy)),
    );
    canvas.drawOval(rim, Paint()..color = labShade(col, -0.3));
    if (scene.bowlPopcorn) {
      for (final s in _bowlPopSeeds) {
        final x = b.dx + (s[0] - 0.5) * 1.55 * r;
        final y = rimY + 4 * k - s[1] * 26 * k * (1 - (s[0] - 0.5).abs());
        _puff(canvas, Offset(x, y), 9 * k, s[2]);
      }
    }
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * k
        ..color = labShade(col, 0.45),
    );
    canvas.drawArc(
      Rect.fromLTRB(b.dx - r * 0.8, rimY - 30 * k, b.dx + r * 0.4, b.dy - 6 * k),
      math.pi * 0.62,
      math.pi * 0.28,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * k
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    if (scene.bowlCold) {
      final sp = Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.85);
      for (var i = 0; i < 6; i++) {
        final tw = 0.5 + 0.5 * math.sin(_time * 3 + i * 1.3);
        final p = Offset(b.dx - r * 0.7 + i * r * 0.28, rimY + 14 * k + (i % 2) * 12 * k);
        final s = 3 * k * tw + 1;
        canvas.drawLine(p.translate(-s, 0), p.translate(s, 0), sp);
        canvas.drawLine(p.translate(0, -s), p.translate(0, s), sp);
      }
    }
  }

  // --------------------------------------------------------- guidance

  /// Pulsing ring around the object the current step expects.
  void _hint(Canvas canvas) {
    final o = scene.hint;
    if (o == null || scene.drag != null) return;
    final Rect r = switch (o) {
      _Obj.door => _doorRect.inflate(6),
      _Obj.heaterButton => Rect.fromCircle(center: _heaterBtn, radius: 22),
      _Obj.machineButton => Rect.fromCenter(center: _machineBtn, width: 50, height: 50),
      _ => scene.hitRect(o).deflate(4),
    };
    final pulse = 0.5 + 0.5 * math.sin(_time * 4);
    final rr = RRect.fromRectAndRadius(r, Radius.circular(math.min(r.shortestSide / 2, 16)));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = _Colors.zslYellow.withValues(alpha: 0.18 + 0.2 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.zslYellow.withValues(alpha: 0.4 + 0.45 * pulse),
    );
  }
}

// ================================================== SUMMARY POPUP ICONS

enum _Icon { ice, reversible, corn, popcorn, irreversible }

/// Icons of the HTML summary modal: the beaker SVG (here holding the ice
/// cube), reversible / irreversible arrows (the irreversible one is the
/// HTML SVG), and drawn corn cob / popcorn instead of the 🌽 / 🍿 emoji.
class _SummaryIconPainter extends CustomPainter {
  const _SummaryIconPainter(this.icon);

  final _Icon icon;

  @override
  void paint(Canvas canvas, Size size) {
    switch (icon) {
      case _Icon.ice:
        _beakerIcon(canvas, size);
      case _Icon.reversible:
        _arrows(canvas, size, reversible: true);
      case _Icon.irreversible:
        _arrows(canvas, size, reversible: false);
      case _Icon.corn:
        _corn(canvas, size);
      case _Icon.popcorn:
        _popcorn(canvas, size);
    }
  }

  /// HTML beaker SVG (24 × 24 viewBox, 0x6366f1 / 0xf8fafc).
  void _beakerIcon(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final outer = Path()
      ..moveTo(9, 3)
      ..lineTo(9, 4)
      ..lineTo(8, 4)
      ..lineTo(8, 6)
      ..lineTo(9, 6)
      ..lineTo(9, 15.2)
      ..lineTo(5.7, 20.7)
      ..cubicTo(5.4, 21.2, 5.6, 21.8, 6.1, 22.0)
      ..cubicTo(6.2, 22.1, 6.4, 22.1, 6.5, 22.1)
      ..lineTo(19.5, 22.1)
      ..cubicTo(20.1, 22.1, 20.5, 21.7, 20.5, 21.1)
      ..cubicTo(20.5, 20.9, 20.5, 20.8, 20.4, 20.6)
      ..lineTo(17, 15.2)
      ..lineTo(17, 6)
      ..lineTo(18, 6)
      ..lineTo(18, 4)
      ..lineTo(17, 4)
      ..lineTo(17, 3)
      ..close();
    canvas.drawPath(outer, Paint()..color = const Color(0xFF6366F1));
    final inner = Path()
      ..moveTo(7.5, 17)
      ..lineTo(9.3, 14)
      ..lineTo(14.7, 14)
      ..lineTo(16.5, 17)
      ..close()
      ..addRect(const Rect.fromLTRB(9, 6, 15, 14));
    canvas.drawPath(inner, Paint()..color = const Color(0xFFF8FAFC));
    // Ice cube in the flask.
    final cube = RRect.fromRectAndRadius(const Rect.fromLTRB(10.2, 8.6, 13.8, 12.2), const Radius.circular(0.5));
    canvas.drawRRect(cube, Paint()..color = _cIce.withValues(alpha: 0.9));
    canvas.drawRRect(
      cube,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.35
        ..color = Colors.white,
    );
    canvas.restore();
  }

  /// 100 × 50 viewBox arrows. Irreversible: the HTML SVG (solid forward
  /// arrow, dashed way back, red ✕). Reversible: both ways solid green.
  void _arrows(Canvas canvas, Size size, {required bool reversible}) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 50);
    final color = reversible ? _cGreen : const Color(0xFFEF4444);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawPath(
      Path()
        ..moveTo(10, 15)
        ..lineTo(80, 15)
        ..moveTo(70, 5)
        ..lineTo(80, 15)
        ..lineTo(70, 25),
      p,
    );
    final back = Path()
      ..moveTo(90, 35)
      ..lineTo(20, 35)
      ..moveTo(30, 25)
      ..lineTo(20, 35)
      ..lineTo(30, 45);
    if (reversible) {
      canvas.drawPath(back, p);
    } else {
      labDashedPath(canvas, back, p, dash: 6, gap: 6);
      canvas.drawPath(
        Path()
          ..moveTo(45, 25)
          ..lineTo(65, 45)
          ..moveTo(65, 25)
          ..lineTo(45, 45),
        p..strokeWidth = 5,
      );
    }
    canvas.restore();
  }

  void _corn(Canvas canvas, Size size) {
    final s = size.width / 52;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    canvas.rotate(-0.5);
    const cob = Rect.fromLTRB(-11, -24, 11, 20);
    canvas.drawOval(cob, Paint()..color = const Color(0xFFEAB308));
    for (var row = 0; row < 7; row++) {
      for (var col = -1; col <= 1; col++) {
        final c = Offset(col * 6.0 + (row.isEven ? 0 : 3) - 1.5, -18 + row * 5.5);
        if (!cob.deflate(2).contains(c)) continue;
        labSphere(canvas, c, 2.6, const Color(0xFFFACC15), shade: 0.35);
      }
    }
    final leaf = Paint()..color = const Color(0xFF16A34A);
    canvas.drawPath(
      Path()
        ..moveTo(0, 26)
        ..quadraticBezierTo(-18, 10, -10, -10)
        ..quadraticBezierTo(-8, 8, 0, 18)
        ..close(),
      leaf,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 26)
        ..quadraticBezierTo(18, 10, 11, -6)
        ..quadraticBezierTo(8, 10, 0, 18)
        ..close(),
      Paint()..color = const Color(0xFF22C55E),
    );
    canvas.restore();
  }

  void _popcorn(Canvas canvas, Size size) {
    final s = size.width / 52;
    canvas.save();
    canvas.scale(s);
    final bucket = Path()
      ..moveTo(11, 22)
      ..lineTo(41, 22)
      ..lineTo(37, 50)
      ..lineTo(15, 50)
      ..close();
    canvas.drawPath(bucket, Paint()..color = Colors.white);
    canvas.save();
    canvas.clipPath(bucket);
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(12 + i * 8.0, 20, 4, 32), Paint()..color = const Color(0xFFEF4444));
    }
    canvas.restore();
    const puffs = [
      [14.0, 19.0], [21.0, 14.0], [29.0, 13.0], [36.0, 17.0], [18.0, 8.0], [27.0, 6.0], [34.0, 9.0], [40.0, 21.0],
    ];
    for (var i = 0; i < puffs.length; i++) {
      final c = Offset(puffs[i][0], puffs[i][1]);
      for (var j = 0; j < 3; j++) {
        final a = i * 1.3 + j * 2.1;
        final p = c + Offset(math.cos(a), math.sin(a)) * 2.6;
        canvas.drawCircle(
          p,
          3.8,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [Colors.white, _cPopcorn, labShade(_cPopcorn, -0.2)],
            ).createShader(Rect.fromCircle(center: p, radius: 3.8)),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SummaryIconPainter old) => old.icon != icon;
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
