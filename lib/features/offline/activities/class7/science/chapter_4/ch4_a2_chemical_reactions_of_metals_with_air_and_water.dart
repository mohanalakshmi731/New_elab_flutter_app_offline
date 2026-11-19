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

/// Class 7 Science • Chapter 4 • Activity 2
/// Chemical Reactions of Metals with Air and Water.
///
/// Native Flutter port of
/// `Cl7S-Ch4-A2-Chemical_Reactions_of_Metals_with_Air_and_Water.html`.
/// Scenario 1: iron nails in three test tubes (dry air / boiled water under
/// oil / air + water), a 10-day time-lapse and the rusty nail in tube C.
/// Scenario 2: clean, burn and collect magnesium ribbon, dissolve the ash
/// in water, stir and test the solution with red and blue litmus.
class Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPage extends StatefulWidget {
  const Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPage({super.key});

  @override
  State<Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPage> createState() =>
      _Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, splash 1311,
/// fire 1348.
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
  splash('splash.mp3'),
  fire('fire.mp3');

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
  static const Color blue600 = Color(0xFF2563EB);
  static const Color green = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFF97316);
  static const Color slate50 = Color(0xFFF8FAFC);
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

class _Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPageState
    extends State<Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _Tweens _tw = _Tweens();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  double _lastT = 0;

  /// HUD "info" message that replaces the step instruction (HTML showHUD info).
  String? _infoKey;

  /// Time-lapse overlay (HTML #time-lapse-overlay / #time-lapse-ui).
  bool _overlayOn = false;
  bool _overlayUi = false;

  /// Tube summary card (HTML #tube-result-popup), null when closed.
  int? _tubeCard;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;
  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
    _buildScenario();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _tw.clear();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _lastT).clamp(0.0, 0.1);
    _lastT = t;
    _scene.time = t;
    _tw.tick(t);
    _updateParticles(dt);
    _frame.value = t;
  }

  // ------------------------------------------------------------ building

  /// HTML `loadScenarioData()`: clears the bench and builds the scenario.
  void _buildScenario() {
    _lab.cancelPending();
    _tw.clear();
    final s = _scene;
    s.advancing = false;
    s.particles.clear();
    s.dragged = null;
    s.night = false;
    _infoKey = null;
    _overlayOn = false;
    _overlayUi = false;
    _tubeCard = null;
    if (s.scenario == 0) {
      _buildS1();
    } else {
      _buildS2();
    }
    _setupStep();
  }

  void _buildS1() {
    final s = _scene;
    final r = s.rng;
    double jitter() => (r.nextDouble() - 0.5) * 0.5;
    s.nails
      ..clear()
      ..addAll([
        _Obj('nail1', const Offset(58, 458), 0.22 + jitter()),
        _Obj('nail2', const Offset(88, 477), -0.12 + jitter()),
        _Obj('nail3', const Offset(118, 461), 0.4 + jitter()),
      ]);
    s.s1
      ..clear()
      ..addAll({
        'silica': _Obj('silica', const Offset(562, 432)),
        'waterBoiled': _Obj('waterBoiled', const Offset(668, 432)),
        'oil': _Obj('oil', const Offset(764, 432)),
        'waterNormal': _Obj('waterNormal', const Offset(856, 432)),
        'stopperA': _Obj('stopperA', const Offset(195, 472)),
        'stopperB': _Obj('stopperB', const Offset(315, 472)),
      });
    for (var i = 0; i < 3; i++) {
      s.tubes[i] = _Tube();
    }
    s.nailTube.clear();
    s.nailRust.clear();
    s.bubbles
      ..clear()
      ..addAll(
        List.generate(
          15,
          (_) =>
              _Bubble(r.nextDouble() - 0.5, r.nextDouble(), 1.6 + r.nextDouble() * 1.6, 0.45 + r.nextDouble() * 0.45),
        ),
      );
    s.bubblesOn = true;
    s.nailsPlaced = 0;
    s.aSilica = s.aStopper = false;
    s.bWater = s.bOil = s.bStopper = false;
    s.cWater = false;
    s.timeLapseStarted = s.timeLapsed = false;
    s.clickedTubes.clear();
    s.pourId = null;
    s.pour = 0;
  }

  void _buildS2() {
    final s = _scene;
    s.sandpaper = _Obj('sandpaper', const Offset(118, 460));
    s.tongs = _Obj('tongs', const Offset(470, 474), -0.6);
    s.dropper = _Obj('dropper', const Offset(742, 324));
    s.redLit = _Obj('redLit', const Offset(690, 482));
    s.blueLit = _Obj('blueLit', const Offset(818, 482));
    s.ribbonHeld = false;
    s.ribbonVisible = true;
    s.ribbonClean = 0;
    s.ribbonAsh = 0;
    s.clamp = 0;
    s.tongsAirborne = false;
    s.flare = 0;
    s.wgState = 0;
    s.wgAnim = 1;
    s.dropperWater = 1;
    s.rodA = _rodHomeA;
    s.rodB = _rodHomeB;
    s.rodActive = false;
    s.redToBlue = 0;
    s.cleaned = s.pickedUp = s.burning = s.ashed = false;
    s.watered = s.stirred = s.redTested = s.blueTested = s.done = false;
  }

  /// HTML `steps[i].setup3D()`: activates the objects of the current step.
  void _setupStep() {
    final s = _scene;
    if (s.scenario == 0) {
      switch (s.step) {
        case 1:
          for (final n in s.nails) {
            n.active = true;
          }
        case 2:
          s.s1['silica']!.active = true;
          s.s1['stopperA']!.active = true;
        case 3:
          s.s1['waterBoiled']!.active = true;
          s.s1['oil']!.active = true;
          s.s1['stopperB']!.active = true;
        case 4:
          s.s1['waterNormal']!.active = true;
      }
    } else {
      switch (s.step) {
        case 1:
          s.sandpaper.active = true;
        case 2:
          s.tongs.active = true;
        case 5:
          s.dropper.active = true;
        case 6:
          s.redLit.active = true;
          s.blueLit.active = true;
      }
    }
  }

  /// HTML `steps[i].validate3D()`.
  bool _validate() {
    final s = _scene;
    if (s.scenario == 0) {
      return switch (s.step) {
        1 => s.nailsPlaced >= 3,
        2 => s.aSilica && s.aStopper,
        3 => s.bWater && s.bOil && s.bStopper,
        4 => s.cWater,
        5 => s.timeLapsed,
        _ => s.clickedTubes.length == 3,
      };
    }
    return switch (s.step) {
      1 => s.cleaned,
      2 => s.pickedUp,
      3 => s.burning,
      4 => s.ashed,
      5 => s.stirred,
      6 => s.redTested && s.blueTested,
      _ => s.done,
    };
  }

  /// HTML `evaluateStepCompletion()`: advances 1.5 s after a valid step.
  void _evaluate() {
    if (!mounted || _scene.advancing || !_validate()) return;
    _scene.advancing = true;
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _scene.advancing = false;
      final n = _data.steps.length;
      if (_step < n) {
        setState(() {
          _scene.step++;
          _infoKey = null;
          _setupStep();
        });
      } else {
        if (_scenario == 1 && _step == 7) return;
        _finishScenario();
      }
    });
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _scene.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _scene.step = 1;
      _buildScenario();
    });
  }

  // ------------------------------------------------------------ feedback

  /// HTML `showHUD(msg, 'info')`: replaces the instruction until the next
  /// success / error message or step change.
  void _info(String key, {_Sound? sound}) {
    if (!mounted) return;
    setState(() => _infoKey = key);
    _lab.showToast(_t(key), sound: false);
    if (sound != null) _Audio.play(sound);
  }

  /// HTML `showHUD(msg, 'success')`.
  void _ok(String key) {
    if (!mounted) return;
    setState(() => _infoKey = null);
    _lab.showToast(_t(key));
  }

  /// HTML `showHUD(msg, 'error')`.
  void _err(String key) {
    if (!mounted) return;
    setState(() => _infoKey = null);
    _lab.showToast(_t(key), isError: true);
  }

  // ------------------------------------------------------------- tweens

  /// HTML `snapTo(obj, pos, rot, cb)`: 300 ms Quadratic.Out.
  void _snap(_Obj o, Offset pos, double rot, {double? up, int ms = 300, VoidCallback? done}) {
    final p0 = o.pos, r0 = o.rot, u0 = o.up;
    var dr = rot - r0;
    dr = ((dr + math.pi) % (2 * math.pi)) - math.pi; // shortest turn
    o.moving = true;
    _tw.add(
      ms,
      (v) {
        o.pos = Offset.lerp(p0, pos, v)!;
        o.rot = r0 + dr * v;
        if (up != null) o.up = u0 + (up - u0) * v;
      },
      curve: Curves.easeOutQuad,
      done: () {
        o.moving = false;
        if (mounted) done?.call();
      },
    );
  }

  void _snapBack(_Obj o, {VoidCallback? done, bool dropSound = false}) {
    if (dropSound) _Audio.play(_Sound.drop);
    _snap(o, o.dragStartPos, o.dragStartRot, up: o.dragStartUp, done: done);
  }

  // ----------------------------------------------------------- gestures

  List<_Obj> _draggables() {
    final s = _scene;
    if (s.scenario == 0) {
      return [
        s.s1['stopperA']!,
        s.s1['stopperB']!,
        ...s.nails.reversed,
        s.s1['silica']!,
        s.s1['waterBoiled']!,
        s.s1['oil']!,
        s.s1['waterNormal']!,
      ];
    }
    return [s.blueLit, s.redLit, s.tongs, s.sandpaper, s.dropper];
  }

  bool _hits(_Obj o, Offset p) {
    final s = _scene;
    final id = o.id;
    if (id.startsWith('nail')) {
      final d = _dir(o.rot) * (_nailLen / 2);
      return _segDist(p, o.pos - d, o.pos + d) < 22;
    }
    if (id.startsWith('stopper')) {
      return Rect.fromLTRB(o.pos.dx - 36, o.pos.dy - 44, o.pos.dx + 36, o.pos.dy + 12).contains(p);
    }
    if (_s1Size.containsKey(id)) {
      final sz = _s1Size[id]!;
      return Rect.fromLTRB(
        o.pos.dx - sz.width / 2 - 10,
        o.pos.dy - sz.height - 16,
        o.pos.dx + sz.width / 2 + 10,
        o.pos.dy + 12,
      ).contains(p);
    }
    switch (id) {
      case 'sandpaper':
        return Rect.fromCenter(center: o.pos, width: 100, height: 60).contains(p);
      case 'tongs':
        final d = _dir(o.rot);
        return _segDist(p, o.pos - d * 74, o.pos + d * (_tipDist + 8)) < 28;
      case 'dropper':
        final d = _dir(o.rot);
        return _segDist(p, o.pos - d * 56, o.pos + d * 56) < 26;
      case 'redLit':
      case 'blueLit':
        return _segDist(p, o.pos, _toVp(o.pos, 0.15)) < 22;
    }
    return s.dragged == o;
  }

  void _onPanStart(DragStartDetails d) {
    if (!_lab.isLabActive || _scene.dragged != null) return;
    final p = d.localPosition;
    for (final o in _draggables()) {
      if (!o.active || !o.visible || o.moving) continue;
      if (!_hits(o, p)) continue;
      o
        ..dragging = true
        ..dragStartPos = o.pos
        ..dragStartRot = o.rot
        ..dragStartUp = o.up;
      _scene
        ..dragged = o
        ..grab = o.pos - p
        ..finger = p;
      _Audio.play(_Sound.pickup); // HTML playGrab
      return;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final o = _scene.dragged;
    if (o == null) return;
    final p = d.localPosition;
    _scene.finger = p;
    final np = p + _scene.grab;
    o.pos = Offset(np.dx.clamp(8.0, 992.0), np.dy.clamp(30.0, 548.0));
    final target = _dropTarget(o);
    _scene
      ..hover = target?.$1
      ..hoverR = target?.$2 ?? 40;
  }

  void _onPanEnd() {
    final o = _scene.dragged;
    if (o == null) return;
    o.dragging = false;
    _scene
      ..dragged = null
      ..hover = null;
    if (_scenario == 0) {
      _dropS1(o);
    } else {
      _dropS2(o);
    }
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final p = d.localPosition;
    final s = _scene;
    if (s.scenario == 0) {
      if (s.step < 6) return;
      for (var i = 0; i < 3; i++) {
        final x = _tubeX[i];
        if (Rect.fromLTRB(x - 36, _tubeTop - 44, x + 36, _tubeBottom + 14).contains(p)) {
          _showTubeSummary(i);
          return;
        }
      }
    } else if (s.rodActive && _segDist(p, s.rodA, s.rodB) < 28) {
      _stir();
    }
  }

  /// True when the object (any probe point) or the finger is within [r].
  bool _near(List<Offset> probes, Offset target, double r) {
    final all = [...probes, _scene.finger];
    return all.any((q) => (q - target).distance < r);
  }

  // ------------------------------------------------- snap predicates
  // Shared by the drop handlers and the drop-zone highlight.

  Offset _tubeMid(int i) => Offset(_tubeX[i], 300);

  List<Offset> _probes(_Obj o) {
    final h = _s1Size[o.id]?.height ?? 30;
    return [o.pos, o.pos - Offset(0, h / 2)];
  }

  bool _nearTube(_Obj o, int i) => _near(_probes(o), _tubeMid(i), 150);

  bool _nearMouth(_Obj o, int i) => _near([o.pos, o.pos - const Offset(0, 12)], Offset(_tubeX[i], 280), 125);

  /// Closest empty tube within reach of a dragged nail (HTML minDist 8).
  int? _nailTarget(_Obj o) {
    final s = _scene;
    int? best;
    var bestD = 130.0;
    for (var i = 0; i < 3; i++) {
      if (s.tubes[i].hasNail) continue;
      final c = _tubeMid(i);
      double ell(Offset q) => math.sqrt(math.pow(q.dx - c.dx, 2) + math.pow((q.dy - c.dy) * 0.55, 2));
      final d = math.min(ell(o.pos), ell(s.finger));
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  bool _sandOnRibbon(_Obj o) {
    final s = _scene;
    return !s.cleaned && math.min(_segDist(o.pos, s.ribbonA, s.ribbonB), _segDist(s.finger, s.ribbonA, s.ribbonB)) < 70;
  }

  bool _tongsOnRibbon() {
    final s = _scene;
    return !s.pickedUp &&
        [s.tongsTips, s.tongs.pos, s.finger].map((q) => _segDist(q, s.ribbonA, s.ribbonB)).reduce(math.min) < 60;
  }

  bool _ribbonInFlame() =>
      _scene.ribbonHeld && !_scene.burning && _near([_scene.ribbonB, _scene.ribbonMid], _flame, 95);

  bool _ribbonOverGlass() =>
      !_scene.ashed && _scene.ribbonVisible && _near([_scene.ribbonMid, _scene.ribbonB, _scene.tongsTips], _wgC, 115);

  bool _dropperOverGlass(_Obj o) => _near([o.pos, o.pos + _dir(o.rot) * -50], _wgC, 110);

  bool _litmusOverGlass(_Obj o) => _near([o.pos, Offset.lerp(o.pos, _toVp(o.pos, 0.15), 0.5)!], _wgC, 110);

  /// Where the dragged object would snap if it were released now.
  (Offset, double)? _dropTarget(_Obj o) {
    final s = _scene;
    final step = s.step;
    final id = o.id;
    if (s.scenario == 0) {
      if (id.startsWith('nail') && step == 1) {
        final i = _nailTarget(o);
        return i == null ? null : (_tubeMid(i), 56.0);
      }
      (Offset, double)? tube(int i, bool ok) => ok && _nearTube(o, i) ? (_tubeMid(i), 56.0) : null;
      (Offset, double)? mouth(int i, bool ok) => ok && _nearMouth(o, i) ? (Offset(_tubeX[i], _tubeTop), 34.0) : null;
      return switch (id) {
        'silica' => tube(0, step == 2),
        'stopperA' => mouth(0, step == 2 && s.aSilica),
        'waterBoiled' => tube(1, step == 3),
        'oil' => tube(1, step == 3 && s.bWater),
        'stopperB' => mouth(1, step == 3 && s.bOil),
        'waterNormal' => tube(2, step == 4),
        _ => null,
      };
    }
    if (id == 'sandpaper' && step == 1 && _sandOnRibbon(o)) return (s.ribbonMid, 74.0);
    if (id == 'tongs' && step == 2 && !s.burning && _tongsOnRibbon()) return (s.ribbonMid, 74.0);
    if (id == 'tongs' && step == 3 && _ribbonInFlame()) return (_flame, 42.0);
    if (id == 'tongs' && step == 4 && _ribbonOverGlass()) return (_wgC, 76.0);
    if (id == 'dropper' && step == 5 && !s.watered && _dropperOverGlass(o)) return (_wgC, 76.0);
    if ((id == 'redLit' || id == 'blueLit') && step == 6 && s.stirred && _litmusOverGlass(o)) return (_wgC, 76.0);
    return null;
  }

  // --------------------------------------------------- scenario 1 drops

  /// HTML `handleSnapS1(obj)`.
  void _dropS1(_Obj o) {
    final s = _scene;
    final id = o.id;
    final step = s.step;

    if (id.startsWith('nail') && step == 1) {
      final best = _nailTarget(o);
      if (best != null) {
        final i = best;
        s.tubes[i].hasNail = true;
        o.active = false;
        s.nailsPlaced++;
        s.nailTube[id] = i;
        _snap(
          o,
          Offset(_tubeX[i], _nailInTubeY),
          _nailUpAngle,
          up: 1,
          done: () {
            _ok('msg_nailDropped');
            _Audio.play(_Sound.pop); // HTML playClink
            _evaluate();
          },
        );
      } else {
        _snapBack(
          o,
          done: () {
            _err('msg_nailError');
            _Audio.play(_Sound.drop);
          },
        );
      }
    } else if (id == 'silica' && step == 2) {
      if (_nearTube(o, 0)) {
        _pour(o, 0, 'msg_silicaAdded', () {
          s.aSilica = true;
          final start = s.tubes[0].beads;
          _tw.add(500, (v) => s.tubes[0].beads = math.max(start, (v * 16).round()));
        });
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'stopperA' && step == 2 && s.aSilica) {
      _seal(o, 0, () => s.aStopper = true, 'msg_tubeASealed');
    } else if (id == 'waterBoiled' && step == 3) {
      if (_nearTube(o, 1)) {
        _pour(o, 1, 'msg_boiledWaterAdded', () {
          s.bWater = true;
          final w0 = s.tubes[1].water;
          _tw.add(500, (v) => s.tubes[1].water = w0 + (_waterB - w0) * v);
        });
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'oil' && step == 3 && s.bWater) {
      if (_nearTube(o, 1)) {
        _pour(o, 1, 'msg_oilAdded', () {
          s.bOil = true;
          _tw.add(500, (v) => s.tubes[1].oil = _oilH * v);
        });
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'stopperB' && step == 3 && s.bOil) {
      _seal(o, 1, () => s.bStopper = true, 'msg_tubeBSealed');
    } else if (id == 'waterNormal' && step == 4) {
      if (_nearTube(o, 2)) {
        _pour(o, 2, 'msg_tubeCPrepared', () {
          s.cWater = true;
          final w0 = s.tubes[2].water;
          _tw.add(500, (v) => s.tubes[2].water = w0 + (_waterC - w0) * v);
        });
      } else {
        _snapBack(o, dropSound: true);
      }
    } else {
      _snapBack(o, dropSound: true);
    }
  }

  /// Container tilts above the tube, pours for 500 ms (liquid / beads rise),
  /// then returns to where it was picked up and reports [msg].
  void _pour(_Obj o, int tube, String msg, VoidCallback onArrive) {
    final s = _scene;
    _snap(
      o,
      _pourAnchor(o.id, tube),
      _pourRot,
      done: () {
        o.moving = true;
        s
          ..pourId = o.id
          ..pourTube = tube
          ..pour = 0;
        _Audio.play(_Sound.splash); // HTML playPour
        onArrive();
        _tw.add(
          500,
          (v) => s.pour = v,
          done: () {
            s.pourId = null;
            _snapBack(
              o,
              done: () {
                _ok(msg);
                _evaluate();
              },
            );
          },
        );
      },
    );
  }

  /// Stopper pressed into the tube mouth (HTML stopperA / stopperB).
  void _seal(_Obj o, int tube, VoidCallback mark, String msg) {
    final s = _scene;
    if (_nearMouth(o, tube)) {
      mark();
      o.active = false;
      _snap(
        o,
        Offset(_tubeX[tube], _tubeTop + 9),
        0,
        done: () {
          s.tubes[tube].sealed = true;
          _ok(msg);
          _Audio.play(_Sound.pop);
          _evaluate();
        },
      );
    } else {
      _snapBack(o, dropSound: true);
    }
  }

  /// HTML `triggerTimeLapse()`: dark overlay, 6 day/night flickers, rust.
  void _triggerTimeLapse() {
    final s = _scene;
    if (s.timeLapseStarted) return;
    setState(() {
      s.timeLapseStarted = true;
      _overlayOn = true;
    });
    _lab.after(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _overlayUi = true);
    });
    for (var c = 0; c <= 6; c++) {
      _lab.after(Duration(milliseconds: 400 * (c + 1)), () {
        if (!mounted) return;
        if (c < 6) {
          s.night = c.isEven;
          return;
        }
        s.night = false;
        // Only the nail exposed to air AND water (tube C) rusts.
        s.nailTube.forEach((nail, tube) {
          if (tube == 2) s.nailRust[nail] = 1;
        });
        s.bubblesOn = false;
        setState(() => _overlayUi = false);
        _lab.after(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() => _overlayOn = false);
          s.timeLapsed = true;
          _evaluate();
        });
      });
    }
  }

  /// HTML `showTubeSummary(tube)`.
  void _showTubeSummary(int i) {
    final s = _scene;
    if (s.scenario != 0 || s.step < 6) return;
    s.clickedTubes.add(i);
    s.tubes[i].clicked = true;
    _Audio.play(_Sound.click);
    setState(() => _tubeCard = i);
    _evaluate();
  }

  void _closeTubeCard() {
    _Audio.play(_Sound.click);
    setState(() => _tubeCard = null);
  }

  // --------------------------------------------------- scenario 2 drops

  /// HTML `handleSnapS2(obj)`.
  void _dropS2(_Obj o) {
    final s = _scene;
    final step = s.step;
    final id = o.id;
    if (id == 'sandpaper' && step == 1) {
      if (_sandOnRibbon(o)) {
        _rubRibbon(o);
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'tongs' && step == 2) {
      if (s.burning) return;
      if (_tongsOnRibbon()) {
        _pickUp(o);
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'tongs' && step == 3) {
      if (_ribbonInFlame()) {
        _burn(o);
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'tongs' && step == 4) {
      if (_ribbonOverGlass()) {
        _collectAsh(o);
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if (id == 'dropper' && step == 5 && !s.watered) {
      if (_dropperOverGlass(o)) {
        _addWater(o);
      } else {
        _snapBack(o, dropSound: true);
      }
    } else if ((id == 'redLit' || id == 'blueLit') && step == 6 && s.stirred) {
      if (_litmusOverGlass(o)) {
        _dipLitmus(o, id == 'redLit');
      } else {
        _snapBack(o, dropSound: true);
      }
    } else {
      _snapBack(o, dropSound: true);
    }
  }

  /// Sandpaper rubs back and forth over the ribbon (yoyo 300 ms x 6).
  void _rubRibbon(_Obj o) {
    final s = _scene;
    o.moving = true;
    _info('msg_cleaningRibbon', sound: _Sound.pickup);
    final from = o.pos;
    final to = s.ribbonHome + const Offset(60, -4);
    _tw.add(
      1800,
      (v) {
        final legs = v * 6;
        final k = legs.floor().clamp(0, 5);
        final f = legs - k;
        o.pos = Offset.lerp(from, to, k.isEven ? f : 1 - f)!;
        s.ribbonClean = math.max(s.ribbonClean, v);
      },
      done: () {
        s
          ..ribbonClean = 1
          ..cleaned = true;
        _snapBack(
          o,
          done: () {
            _ok('msg_ribbonClean');
            _evaluate();
          },
        );
      },
    );
  }

  /// Tongs clamp the ribbon and lift it (HTML tongs, step 2).
  void _pickUp(_Obj o) {
    final s = _scene;
    s
      ..ribbonHeld = true
      ..pickedUp = true
      ..tongsAirborne = true;
    _Audio.play(_Sound.pop); // HTML playClink
    _tw.add(200, (v) => s.clamp = v);
    _snap(
      o,
      _heldPivot,
      _heldAngle,
      done: () {
        _ok('msg_ribbonPicked');
        _evaluate();
      },
    );
  }

  /// Free end of the ribbon in the flame: dazzling white burn for 3 s.
  void _burn(_Obj o) {
    final s = _scene;
    _snap(
      o,
      _burnPivot(),
      _burnAngle,
      done: () {
        o.moving = true;
        s.burning = true;
        _info('msg_ribbonBurning', sound: _Sound.fire);
        _tw.add(120, (v) => s.flare = math.max(s.flare, v));
        _tw.add(2500, (v) => s.ribbonAsh = v);
        _lab.after(const Duration(milliseconds: 3000), () {
          if (!mounted) return;
          _tw.add(200, (v) => s.flare = 1 - v);
          o.moving = false;
          _ok('msg_ribbonAsh');
          _evaluate();
        });
      },
    );
  }

  /// Ash falls into the watch glass; tongs open and go back.
  void _collectAsh(_Obj o) {
    final s = _scene;
    _snap(
      o,
      _ashPivot(),
      _ashAngle,
      done: () {
        final a = s.ribbonA, b = s.ribbonB;
        s.ribbonVisible = false;
        for (var i = 0; i < 26; i++) {
          final p = Offset.lerp(a, b, s.rng.nextDouble())!;
          s.particles.add(
            _Particle(
              p,
              Offset((_wgC.dx - p.dx) * 1.6, 40 + s.rng.nextDouble() * 60),
              0.45 + s.rng.nextDouble() * 0.2,
              1.6 + s.rng.nextDouble() * 1.8,
              const Color(0xFFF1F5F9),
              2,
            ),
          );
        }
        s
          ..wgState = 1
          ..wgAnim = 0;
        _tw.add(400, (v) => s.wgAnim = v);
        _tw.add(200, (v) => s.clamp = 1 - 1.5 * v);
        s.ashed = true;
        _snap(
          o,
          o.dragStartPos,
          _heldAngle,
          done: () {
            _ok('msg_ashCollected');
            _evaluate();
          },
        );
      },
    );
  }

  /// Dropper stands over the watch glass, empties and releases 3 drops.
  void _addWater(_Obj o) {
    final s = _scene;
    final over = Offset(_wgC.dx, _wgC.dy - 112);
    _snap(
      o,
      over,
      -math.pi / 2,
      done: () {
        o.moving = true;
        s.watered = true;
        _tw.add(1200, (v) => s.dropperWater = 1 - 0.99 * v);
        for (var i = 0; i < 3; i++) {
          _lab.after(Duration(milliseconds: i * 400), () {
            if (!mounted) return;
            final tip = over + const Offset(0, 54);
            final end = Offset(_wgC.dx + (i - 1) * 6.0, _wgC.dy + 2);
            s.particles.add(_Particle(tip, (end - tip) / 0.3, 0.3, 4.5, const Color(0xFF0EA5E9), 3));
            _Audio.play(_Sound.drop);
          });
        }
        _lab.after(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          s
            ..wgState = 2
            ..wgAnim = 0;
          _tw.add(300, (v) => s.wgAnim = v);
          _snapBack(
            o,
            done: () {
              _info('msg_waterAdded');
              setState(() => s.rodActive = true);
            },
          );
        });
      },
    );
  }

  /// Rod end and top while stirring at angle [phi] (pivot spin in the HTML).
  (Offset, Offset) _rodStirPose(double phi) {
    final low = _wgC + Offset(20 * math.cos(phi), 4 + 7 * math.sin(phi));
    final top = low + Offset(66 * math.cos(phi), -170 + 22 * math.sin(phi));
    return (low, top);
  }

  /// HTML glassRod.onClick: move to the watch glass, stir 2 turns, reset.
  void _stir() {
    final s = _scene;
    _Audio.play(_Sound.pop); // HTML playClink
    setState(() => s.rodActive = false);
    final a0 = s.rodA, b0 = s.rodB;
    final start = _rodStirPose(0);
    _tw.add(
      500,
      (v) {
        s.rodA = Offset.lerp(a0, start.$1, v)!;
        s.rodB = Offset.lerp(b0, start.$2, v)!;
      },
      done: () {
        _tw.add(
          1500,
          (v) {
            final p = _rodStirPose(v * 4 * math.pi);
            s.rodA = p.$1;
            s.rodB = p.$2;
          },
          done: () {
            s
              ..stirred = true
              ..rodA = _rodHomeA
              ..rodB = _rodHomeB
              ..wgState = 3
              ..wgAnim = 0;
            _tw.add(400, (v) => s.wgAnim = v);
            _ok('msg_solutionCreated');
            _evaluate();
          },
        );
      },
    );
  }

  /// Litmus strip plunged upright into the solution.
  void _dipLitmus(_Obj o, bool red) {
    final s = _scene;
    o.active = false;
    final target = _wgC + Offset(red ? -24 : 24, 6);
    _snap(
      o,
      target,
      red ? 0.16 : -0.16,
      up: 1,
      done: () {
        _Audio.play(_Sound.pop);
        if (red) {
          s.redTested = true;
          _tw.add(300, (v) => s.redToBlue = v);
          _lab.after(const Duration(milliseconds: 1000), () {
            _info('msg_redLitmus');
            if (s.blueTested) _evaluate();
          });
        } else {
          s.blueTested = true;
          _lab.after(const Duration(milliseconds: 1000), () {
            if (s.redTested) {
              _ok('msg_litmusComplete');
              _evaluate();
            } else {
              _info('msg_blueLitmus');
            }
          });
        }
      },
    );
  }

  // ------------------------------------------------------- completion

  /// HTML `finishScenario()` (scenario 1).
  void _finishScenario() {
    _scene.advancing = true;
    _ok('msg_scenarioComplete');
    _showConclusion(
      delay: const Duration(milliseconds: 2000),
      title: () => _t('obs_title'),
      extra: () => _s1Observation(context),
    );
  }

  /// HTML `finishScenario2()` (the Conclusion button).
  void _finishScenario2() {
    final s = _scene;
    if (s.done) return;
    setState(() {
      s.done = true;
      s.advancing = true;
    });
    _ok('msg_scenarioComplete');
    _showConclusion(
      delay: const Duration(milliseconds: 1000),
      title: () => _t('concl_title'),
      extra: () => _MgConclusion(lab: _lab),
    );
  }

  /// Same flow as `LabController.showScenarioConclusion` (marks the
  /// scenario complete, re-opens the sidebar, Continue / Restart Lab), but
  /// the popup body is a rich widget instead of a plain string.
  void _showConclusion({required Duration delay, required String Function() title, required Widget Function() extra}) {
    _lab.completedScenarios.add(_scenario);
    final allDone = _lab.completedScenarios.length >= 2;
    _lab.after(delay, () {
      if (!mounted) return;
      setState(() => _tubeCard = null);
      _lab.openSidebar();
      _lab.showPopup(
        () => LabPopupContent(
          title: title(),
          icon: Icons.science,
          extra: extra(),
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
        ),
      );
    });
  }

  // -------------------------------------------------------- particles

  void _updateParticles(double dt) {
    final s = _scene;
    if (s.scenario == 0 && s.bubblesOn) {
      for (final b in s.bubbles) {
        b.y += b.speed * dt;
        if (b.y > 1) {
          b
            ..y = 0
            ..x = s.rng.nextDouble() - 0.5;
        }
      }
    }
    if (s.scenario == 1 && s.flare > 0.05 && s.ribbonVisible) {
      final e = s.ribbonB;
      final r = s.rng;
      final sparks = (dt * 140 * s.flare).ceil();
      for (var i = 0; i < sparks; i++) {
        final a = r.nextDouble() * 2 * math.pi;
        final sp = 60 + r.nextDouble() * 170;
        s.particles.add(
          _Particle(
            e,
            Offset(math.cos(a) * sp, math.sin(a) * sp - 60),
            0.35 + r.nextDouble() * 0.4,
            1.2 + r.nextDouble() * 1.8,
            r.nextBool() ? Colors.white : const Color(0xFFFEF9C3),
            0,
          ),
        );
      }
      if (r.nextDouble() < dt * 18) {
        s.particles.add(
          _Particle(
            e + Offset((r.nextDouble() - 0.5) * 10, -6),
            Offset((r.nextDouble() - 0.5) * 20, -40 - r.nextDouble() * 30),
            1.6,
            9 + r.nextDouble() * 8,
            const Color(0xFFF8FAFC),
            1,
          ),
        );
      }
    }
    if (s.particles.isEmpty) return;
    for (final p in s.particles) {
      p.age += dt;
      p.p += p.v * dt;
      if (p.kind == 0) p.v += Offset(0, 320 * dt);
      if (p.kind == 2) p.v += Offset(0, 260 * dt);
    }
    s.particles.removeWhere((p) => p.age >= p.life || (p.kind == 2 && p.p.dy > _wgC.dy + 4));
    if (s.particles.length > 400) s.particles.removeRange(0, s.particles.length - 400);
  }

  // ------------------------------------------------------------- UI

  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == 0 && s.step == 5 && !s.timeLapseStarted) {
      return [
        LabAction(label: _t('btn_simulate'), icon: Icons.fast_forward, highlight: true, onTap: _triggerTimeLapse),
      ];
    }
    if (s.scenario == 1 && s.step == 7 && !s.done) {
      return [LabAction(label: _t('btn_conclusion'), icon: Icons.zoom_in, highlight: true, onTap: _finishScenario2)];
    }
    return const [];
  }

  Map<String, String> _labels() => {
    for (final k in const [
      'lbl_nail', 'lbl_silica', 'lbl_boiled', 'lbl_oil', 'lbl_water', 'lbl_stopper', //
      'lbl_ribbon', 'lbl_sandpaper', 'lbl_tongs', 'lbl_lamp', 'lbl_wg', 'lbl_dropper', //
      'lbl_rod', 'lbl_redL', 'lbl_blueL',
    ])
      k: _t(k),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          instruction: _infoKey == null ? null : _t(_infoKey!),
          actions: actions,
          onReset: _fullReset,
          overlays: [
            // HTML #action-btn-container: the main action floats on the canvas.
            if (_lab.isSidebarOpen && actions.isNotEmpty)
              Positioned(
                top: inset.top + 46 * s,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LabActionButton(action: actions.first, scale: s * 1.1, expand: false),
                  ),
                ),
              ),
            if (_tubeCard != null) _tubeCardOverlay(_tubeCard!, s, inset),
            _timeLapseOverlay(s),
          ],
          stage: LabStage(
            designSize: _design,
            // Small touch slop so short drags on phones are not swallowed
            // by Flutter's default 36 px pan slop.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
              child: GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: _onTapUp,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: _design,
                  painter: _A2Painter(
                    scene: _scene,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    text: _labels(),
                    lang: _lab.lang,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#time-lapse-overlay`: 85% black, spinning clock, "10 Days Later...".
  Widget _timeLapseOverlay(double s) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_overlayOn,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: Colors.black.withValues(alpha: _overlayOn ? 0.85 : 0),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            opacity: _overlayUi ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: _frame,
                      builder: (context, t, child) => Transform.rotate(angle: t * 2 * math.pi / 3, child: child),
                      child: Icon(Icons.timelapse, size: 64 * s, color: _Colors.zslYellow),
                    ),
                    SizedBox(height: 18 * s),
                    Text(
                      _t('time_lapse').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 18)],
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
// Text copied from `Cl7S-Ch4-A2-Chemical_Reactions_of_Metals_with_Air_and_Water.html`
// (window.T). Strings the HTML hard-coded (Air / Water in the tube summary,
// chemical labels, the S2 conclusion rows) were added here so that
// every visible string is localised. `**text**` marks bold text.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Chemical Reactions of Metals with Air and Water',
    'app_subtitle': 'Class 7 • The World of Metals and Non-metals',
    'scen_1': '1. The Mystery of the Rusty Nail',
    'scen_2': "2. Magnesium's Dazzling Reaction",
    'btn_simulate': 'Simulate 10 Days',
    'btn_conclusion': 'Conclusion',
    'obs_title': 'Observation & Analysis',
    'concl_title': 'Conclusion: Magnesium Reaction',
    'tube_title': 'Test Tube Summary',
    'time_lapse': '10 Days Later...',
    // Feedback (HUD messages)
    'msg_nailDropped': 'Nail dropped successfully.',
    'msg_nailError': 'Drag the nail closer to an empty test tube to drop it inside.',
    'msg_silicaAdded': 'Silica Gel added to Tube A. Now seal it with the stopper.',
    'msg_tubeASealed': 'Tube A Sealed airtight!',
    'msg_boiledWaterAdded': 'Boiled water added to Tube B. Now add the oil layer.',
    'msg_oilAdded': 'Oil layer perfectly created on top of water.',
    'msg_tubeBSealed': 'Tube B Sealed!',
    'msg_tubeCPrepared': 'Test Tube C prepared with partial water. LEAVE OPEN.',
    'msg_cleaningRibbon': 'Cleaning the magnesium ribbon...',
    'msg_ribbonClean': 'Ribbon is clean and shiny!',
    'msg_ribbonPicked': 'Ribbon picked up!',
    'msg_ribbonBurning': 'Magnesium is burning with a dazzling flame!',
    'msg_ribbonAsh': 'Ribbon has turned to ash.',
    'msg_ashCollected': 'White ash collected successfully!',
    'msg_waterAdded': 'Water added. Now CLICK the glass rod to stir.',
    'msg_solutionCreated': 'Cloudy solution created.',
    'msg_redLitmus': 'Red litmus turned Blue! Now try Blue Litmus.',
    'msg_blueLitmus': 'Blue litmus remained Blue.',
    'msg_litmusComplete': 'Litmus tests complete.',
    'msg_scenarioComplete': 'Scenario Completed Successfully!',
    // Scenario 2 conclusion (popup)
    'concl_s2_line1': 'Red litmus turns **Blue**.',
    'concl_s2_line2': 'Metal oxides are **BASIC**.',
    // Scenario 1 observation (popup)
    'obs_analysis_lbl': 'Analysis',
    'obs_analysis':
        'Iron rusting is a chemical process that strictly requires **both** moisture (water) and oxygen (from the air).',
    'obs_a': 'Contained air but was kept completely dry using silica gel.',
    'obs_a_res': 'No rust formed.',
    'obs_b': 'Contained boiled water, and a layer of oil blocked atmospheric oxygen.',
    'obs_b_res': 'No rust formed.',
    'obs_c': 'Was exposed to both ordinary water and air simultaneously.',
    'obs_c_res': 'Rusted heavily!',
    'obs_concl':
        'Conclusion: Iron rusts only when exposed to both air and water simultaneously. This process is called rusting.',
    // Tube summary results
    'tubeRes_A': 'Result: No Rust Formed',
    'tubeRes_B': 'Result: No Rust Formed',
    'tubeRes_C': 'Result: Rusty Nail!',
    'lbl_air': 'Air',
    // 3D labels
    'lbl_nail': 'Iron Nail',
    'lbl_silica': 'Silica Gel',
    'lbl_boiled': 'Boiled Water',
    'lbl_oil': 'Oil',
    'lbl_water': 'Water',
    'lbl_stopper': 'Stopper',
    'lbl_ribbon': 'Magnesium Ribbon',
    'lbl_sandpaper': 'Sandpaper',
    'lbl_tongs': 'Tongs',
    'lbl_lamp': 'Spirit Lamp',
    'lbl_wg': 'Watch Glass',
    'lbl_dropper': 'Dropper (Water)',
    'lbl_rod': 'Glass Rod',
    'lbl_redL': 'Red Litmus',
    'lbl_blueL': 'Blue Litmus',
  },
  'hi': {
    'app_title': 'धातुओं की वायु और जल के साथ रासायनिक अभिक्रियाएं',
    'app_subtitle': 'कक्षा 7 • धातुओं और अधातुओं की दुनिया',
    'scen_1': '1. जंग लगी कील का रहस्य',
    'scen_2': '2. मैग्नीशियम की चमकदार प्रतिक्रिया',
    'btn_simulate': '10 दिन का अनुकरण करें',
    'btn_conclusion': 'निष्कर्ष',
    'obs_title': 'अवलोकन और विश्लेषण',
    'concl_title': 'निष्कर्ष: मैग्नीशियम प्रतिक्रिया',
    'tube_title': 'परखनली सारांश',
    'time_lapse': '10 दिन बाद...',
    'msg_nailDropped': 'कील सफलतापूर्वक गिर गई।',
    'msg_nailError': 'कील को खाली परखनली के करीब खींचें ताकि वह अंदर गिर जाए।',
    'msg_silicaAdded': 'ट्यूब ए में सिलिका जेल मिलाया गया। अब इसे स्टॉपर से सील करें।',
    'msg_tubeASealed': 'ट्यूब ए वायुरोधी सील हो गई!',
    'msg_boiledWaterAdded': 'ट्यूब बी में उबला हुआ पानी डाला गया। अब तेल की परत डालें।',
    'msg_oilAdded': 'पानी के ऊपर तेल की परत पूरी तरह से बन गई।',
    'msg_tubeBSealed': 'ट्यूब बी सील हो गई!',
    'msg_tubeCPrepared': 'परखनली सी को आंशिक पानी के साथ तैयार किया गया। खुला छोड़ दें।',
    'msg_cleaningRibbon': 'मैग्नीशियम रिबन की सफाई...',
    'msg_ribbonClean': 'रिबन साफ और चमकदार है!',
    'msg_ribbonPicked': 'रिबन उठा लिया!',
    'msg_ribbonBurning': 'मैग्नीशियम एक चमकदार लौ के साथ जल रहा है!',
    'msg_ribbonAsh': 'रिबन राख में बदल गया है।',
    'msg_ashCollected': 'सफेद राख सफलतापूर्वक एकत्र की गई!',
    'msg_waterAdded': 'पानी डाला गया। अब हिलाने के लिए ग्लास रॉड पर क्लिक करें।',
    'msg_solutionCreated': 'धुंधला घोल तैयार हो गया।',
    'msg_redLitmus': 'लाल लिटमस नीला हो गया! अब नीला लिटमस आज़माएं।',
    'msg_blueLitmus': 'नीला लिटमस नीला ही रहा।',
    'msg_litmusComplete': 'लिटमस परीक्षण पूर्ण।',
    'msg_scenarioComplete': 'परिदृश्य सफलतापूर्वक पूर्ण हुआ!',
    'concl_s2_line1': 'लाल लिटमस **नीला** हो जाता है।',
    'concl_s2_line2': 'धात्विक आक्साइड **क्षारीय** होते हैं।',
    'obs_analysis_lbl': 'विश्लेषण',
    'obs_analysis':
        'लोहे में जंग लगना एक रासायनिक प्रक्रिया है जिसमें **दोनों** नमी (पानी) और ऑक्सीजन (हवा से) की आवश्यकता होती है।',
    'obs_a': 'हवा थी लेकिन सिलिका जेल का उपयोग करके पूरी तरह से सूखा रखा गया था।',
    'obs_a_res': 'कोई जंग नहीं लगा।',
    'obs_b': 'उबला हुआ पानी था, और तेल की एक परत ने वायुमंडलीय ऑक्सीजन को रोक दिया।',
    'obs_b_res': 'कोई जंग नहीं लगा।',
    'obs_c': 'एक साथ साधारण पानी और हवा दोनों के संपर्क में था।',
    'obs_c_res': 'भारी जंग लगा!',
    'obs_concl':
        'निष्कर्ष: लोहे में जंग तभी लगता है जब वह एक साथ हवा और पानी दोनों के संपर्क में आता है। इस प्रक्रिया को जंग लगना कहते हैं।',
    'tubeRes_A': 'परिणाम: कोई जंग नहीं लगा',
    'tubeRes_B': 'परिणाम: कोई जंग नहीं लगा',
    'tubeRes_C': 'परिणाम: जंग लगी कील!',
    'lbl_air': 'हवा',
    'lbl_nail': 'लोहे की कील',
    'lbl_silica': 'सिलिका जेल',
    'lbl_boiled': 'उबला हुआ पानी',
    'lbl_oil': 'तेल',
    'lbl_water': 'पानी',
    'lbl_stopper': 'स्टॉपर',
    'lbl_ribbon': 'मैग्नीशियम रिबन',
    'lbl_sandpaper': 'सैंडपेपर',
    'lbl_tongs': 'चिमटा',
    'lbl_lamp': 'स्पिरिट लैंप',
    'lbl_wg': 'वाच ग्लास',
    'lbl_dropper': 'ड्रॉपर (पानी)',
    'lbl_rod': 'ग्लास रॉड',
    'lbl_redL': 'लाल लिटमस',
    'lbl_blueL': 'नीला लिटमस',
  },
};

// Steps: concept = step title, action = HUD instruction, observation = the
// teacher-board note (kept as data only, the teacher board is removed).
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'Investigate the conditions required for an iron nail to rust.',
      steps: [
        LabStep(
          concept: 'Setup the Environment',
          action: 'Drag 3 iron nails from the tray and drop one into each test tube (A, B, C).',
          observation:
              'To understand rusting, we must test different environments. Conditions to test: Dry Air Only (No moisture); Water Only (No air); Air + Water (Normal conditions).',
        ),
        LabStep(
          concept: 'Prepare Tube A (Dry Air)',
          action: 'Drag the Silica Gel jar to Tube A, then drag a stopper to seal it airtight.',
          observation:
              "Let's remove moisture from Tube A. Silica Gel is a desiccant. It absorbs moisture from the air, creating a completely dry environment.",
        ),
        LabStep(
          concept: 'Prepare Tube B (Water Only)',
          action:
              'Drag boiled water beaker to Tube B, then drag oil bottle to create a layer, and seal it with a stopper.',
          observation:
              'We need water without dissolved oxygen. Boiled water has less dissolved air. Adding a layer of oil creates a barrier that prevents atmospheric oxygen from dissolving back into the water.',
        ),
        LabStep(
          concept: 'Prepare Tube C (Air + Water)',
          action:
              "Prepare Test Tube C for 'Air and Water'. DRAG the beaker of Water and DROP it into Test Tube C, adding just enough to partially submerge the nail. Leave the tube open to the air.",
          observation:
              'This represents a typical outdoor environment like leaving a bicycle in the rain. The nail is partially submerged, exposing it directly to both water and atmospheric air simultaneously.',
        ),
        LabStep(
          concept: 'Observe Over Time',
          action: "CLICK the 'Time-Lapse' button to observe the test tubes over 10 days.",
          observation:
              "Chemical reactions like rusting occur over time. Rust is hydrated iron(III) oxide: 4Fe + 3O₂ + 6H₂O → 4Fe(OH)₃. Let's fast-forward 10 days to see the results.",
        ),
        LabStep(
          concept: 'Conclusions',
          action: 'CLICK on each test tube to see a summary of the conditions and the result.',
          observation:
              'Click on each of the test tubes to review the outcome of the experiment. This will summarize the essential conditions required for rusting.',
        ),
      ],
    ),
    LabScenarioData(
      objective: "Observe the reaction of magnesium metal with oxygen and test the product's nature.",
      steps: [
        LabStep(
          concept: 'Preparation',
          action: 'DRAG the Sandpaper over the magnesium ribbon repeatedly to clean its surface.',
          observation:
              'Magnesium ribbon often has a dull coating of magnesium oxide from slow reaction with air. We must clean it to expose the pure magnesium metal before burning.',
        ),
        LabStep(
          concept: 'Pick Up Ribbon',
          action: 'DRAG the Tongs to the cleaned Magnesium Ribbon to pick it up.',
          observation:
              'Magnesium burns at a very high temperature. We must use tongs to hold it safely over the flame.',
        ),
        LabStep(
          concept: 'Combustion',
          action:
              'DRAG the tongs holding the ribbon so that the free end touches the flame of the Spirit Lamp.',
          observation:
              'Combustion is a chemical reaction with oxygen. 2Mg + O₂ →(Δ) 2MgO + Heat + Light. This produces a dazzling white light and leaves behind white ash (Magnesium Oxide).',
        ),
        LabStep(
          concept: 'Collect Ash',
          action: 'Quickly DRAG the burning ribbon over the Watch Glass to collect the white powder.',
          observation:
              'We need to collect the product of the combustion, which is Magnesium Oxide (MgO), a white powder.',
        ),
        LabStep(
          concept: 'Dissolve in Water',
          action:
              'DRAG the Dropper filled with water and DROP a few drops onto the white powder in the watch glass. Then, CLICK the Glass Rod to stir.',
          observation:
              'To test if the oxide is acidic or basic, we first dissolve it in water to form Magnesium Hydroxide: MgO + H₂O → Mg(OH)₂.',
        ),
        LabStep(
          concept: 'Litmus Test',
          action:
              'DRAG the strip of Red Litmus Paper and DROP it into the solution. Then DRAG the Blue Litmus Paper.',
          observation:
              'Litmus paper is an indicator. Red litmus turns blue in basic solutions, and blue litmus turns red in acidic solutions.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: "CLICK the 'Conclusion' button to summarize the findings.",
          observation: 'Review the results of the litmus test to determine the nature of metallic oxides.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'लोहे की कील में जंग लगने के लिए आवश्यक स्थितियों की जांच करें।',
      steps: [
        LabStep(
          concept: 'पर्यावरण स्थापित करें',
          action: 'ट्रे से 3 लोहे की कीलें खींचें और प्रत्येक परखनली (A, B, C) में एक-एक छोड़ें।',
          observation:
              'जंग को समझने के लिए, हमें विभिन्न वातावरणों का परीक्षण करना चाहिए। परीक्षण की शर्तें: केवल शुष्क हवा (कोई नमी नहीं); केवल पानी (कोई हवा नहीं); हवा + पानी (सामान्य स्थिति)।',
        ),
        LabStep(
          concept: 'ट्यूब A (शुष्क हवा) तैयार करें',
          action:
              'सिलिका जेल जार को ट्यूब A तक खींचें, फिर इसे वायुरोधी रूप से सील करने के लिए एक स्टॉपर खींचें।',
          observation:
              'आइए ट्यूब A से नमी निकालें। सिलिका जेल एक शोषक है। यह हवा से नमी को अवशोषित करता है, जिससे पूरी तरह से शुष्क वातावरण बनता है।',
        ),
        LabStep(
          concept: 'ट्यूब B (केवल पानी) तैयार करें',
          action:
              'उबले हुए पानी के बीकर को ट्यूब B तक खींचें, फिर एक परत बनाने के लिए तेल की बोतल खींचें, और इसे एक स्टॉपर से सील करें।',
          observation:
              'हमें बिना घुली ऑक्सीजन वाले पानी की आवश्यकता है। उबले हुए पानी में घुली हुई हवा कम होती है। तेल की एक परत जोड़ने से एक अवरोध बनता है जो वायुमंडलीय ऑक्सीजन को पानी में वापस घुलने से रोकता है।',
        ),
        LabStep(
          concept: 'ट्यूब C (हवा + पानी) तैयार करें',
          action:
              "'हवा और पानी' के लिए परखनली C तैयार करें। पानी के बीकर को खींचें और इसे परखनली C में छोड़ें, कील को आंशिक रूप से डुबाने के लिए बस पर्याप्त पानी डालें। ट्यूब को हवा में खुला छोड़ दें।",
          observation:
              'यह बारिश में साइकिल छोड़ने जैसे सामान्य बाहरी वातावरण का प्रतिनिधित्व करता है। कील आंशिक रूप से जलमग्न है, जिससे यह सीधे पानी और वायुमंडलीय हवा दोनों के संपर्क में आ जाती है।',
        ),
        LabStep(
          concept: 'समय के साथ निरीक्षण करें',
          action: "परखनलियों को 10 दिनों तक देखने के लिए 'टाइम-लैप्स' बटन पर क्लिक करें।",
          observation:
              'जंग लगने जैसी रासायनिक प्रतिक्रियाएं समय के साथ होती हैं। जंग हाइड्रेटेड आयरन (III) ऑक्साइड है: 4Fe + 3O₂ + 6H₂O → 4Fe(OH)₃। आइए परिणाम देखने के लिए 10 दिन आगे बढ़ें।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'स्थितियों और परिणाम का सारांश देखने के लिए प्रत्येक परखनली पर क्लिक करें।',
          observation:
              'प्रयोग के परिणाम की समीक्षा करने के लिए प्रत्येक परखनली पर क्लिक करें। यह जंग लगने के लिए आवश्यक आवश्यक शर्तों का सारांश देगा।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'ऑक्सीजन के साथ मैग्नीशियम धातु की प्रतिक्रिया का निरीक्षण करें और उत्पाद की प्रकृति का परीक्षण करें।',
      steps: [
        LabStep(
          concept: 'तैयारी',
          action: 'इसकी सतह को साफ करने के लिए मैग्नीशियम रिबन पर सैंडपेपर को बार-बार खींचें।',
          observation:
              'मैग्नीशियम रिबन में अक्सर हवा के साथ धीमी प्रतिक्रिया से मैग्नीशियम ऑक्साइड की सुस्त कोटिंग होती है। जलने से पहले शुद्ध मैग्नीशियम धातु को उजागर करने के लिए हमें इसे साफ करना चाहिए।',
        ),
        LabStep(
          concept: 'रिबन उठाओ',
          action: 'इसे उठाने के लिए चिमटे को साफ किए गए मैग्नीशियम रिबन पर खींचें।',
          observation:
              'मैग्नीशियम बहुत उच्च तापमान पर जलता है। इसे सुरक्षित रूप से लौ के ऊपर पकड़ने के लिए हमें चिमटे का उपयोग करना चाहिए।',
        ),
        LabStep(
          concept: 'दहन',
          action: 'रिबन पकड़े हुए चिमटे को खींचें ताकि मुक्त सिरा स्पिरिट लैंप की लौ को छुए।',
          observation:
              'दहन ऑक्सीजन के साथ एक रासायनिक प्रतिक्रिया है। 2Mg + O₂ →(Δ) 2MgO + Heat + Light। यह एक चमकदार सफेद रोशनी पैदा करता है और पीछे सफेद राख (मैग्नीशियम ऑक्साइड) छोड़ देता है।',
        ),
        LabStep(
          concept: 'राख ले लीजिए',
          action: 'सफेद पाउडर इकट्ठा करने के लिए जलते हुए रिबन को जल्दी से वॉच ग्लास के ऊपर खींचें।',
          observation:
              'हमें दहन के उत्पाद को इकट्ठा करने की आवश्यकता है, जो मैग्नीशियम ऑक्साइड (MgO) है, एक सफेद पाउडर।',
        ),
        LabStep(
          concept: 'पानी में घोलें',
          action:
              'पानी से भरे ड्रॉपर को खींचें और वॉच ग्लास में सफेद पाउडर पर कुछ बूँदें डालें। फिर, हिलाने के लिए ग्लास रॉड पर क्लिक करें।',
          observation:
              'यह परीक्षण करने के लिए कि ऑक्साइड अम्लीय है या क्षारीय, हम पहले इसे मैग्नीशियम हाइड्रॉक्साइड बनाने के लिए पानी में घोलते हैं: MgO + H₂O → Mg(OH)₂।',
        ),
        LabStep(
          concept: 'लिटमस परीक्षण',
          action: 'लाल लिटमस पेपर की पट्टी को खींचें और इसे घोल में छोड़ दें। फिर नीले लिटमस पेपर को खींचें।',
          observation:
              'लिटमस पेपर एक संकेतक है। लाल लिटमस क्षारीय घोल में नीला हो जाता है, और नीला लिटमस अम्लीय घोल में लाल हो जाता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: "निष्कर्षों को संक्षेप में प्रस्तुत करने के लिए 'निष्कर्ष' बटन पर क्लिक करें।",
          observation: 'धात्विक आक्साइड की प्रकृति निर्धारित करने के लिए लिटमस परीक्षण के परिणामों की समीक्षा करें।',
        ),
      ],
    ),
  ],
};

// ============================================================ LAYOUT
// Everything is drawn in a 1000 x 560 design space. The Three.js camera
// (0, 6, 16) looking at (0, 2, 0) is approximated by a vanishing point at
// [_vp]; [_tilt] gives the ellipse ratio of round tops at a given height.

const Size _design = Size(1000, 560);
const Offset _vp = Offset(500, 112);
const double _tableY = 238;

double _tilt(double y) {
  final a = math.atan(math.max(0.0, y - _vp.dy) / 676);
  return math.sin(a).clamp(0.1, 0.6).toDouble();
}

/// Moves [p] towards the vanishing point (depth illusion for box tops).
Offset _toVp(Offset p, double f) => p + (_vp - p) * f;

Offset _rot(Offset v, double r) => Offset(
      v.dx * math.cos(r) - v.dy * math.sin(r),
      v.dx * math.sin(r) + v.dy * math.cos(r),
    );

Offset _dir(double a) => Offset(math.cos(a), math.sin(a));

double _segDist(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

// ---- Scenario 1: rack, tubes, reagents
const List<double> _tubeX = [195, 315, 435];
const double _tubeW = 46;
const double _tubeTop = 214;
const double _tubeBottom = 380;
const double _nailLen = 78;
const double _nailUpAngle = math.pi / 2 - math.pi / 10; // upright, tilted 18°
const double _nailInTubeY = 334;
const double _waterB = 84; // boiled water column in tube B (px)
const double _waterC = 34; // partial water in tube C
const double _oilH = 14;
const List<Color> _tubeColors = [Color(0xFF22C55E), Color(0xFF3B82F6), Color(0xFFF97316)];
const List<String> _tubeLetters = ['A', 'B', 'C'];
const double _pourRot = 0.8; // ~45° clockwise (HTML z = -PI/4)

/// Body size (width, height incl. cap) and pouring lip of the S1 containers.
const Map<String, Size> _s1Size = {
  'silica': Size(88, 90),
  'waterBoiled': Size(86, 94),
  'oil': Size(50, 100),
  'waterNormal': Size(86, 94),
};
const Map<String, Offset> _s1Lip = {
  'silica': Offset(44, -74),
  'waterBoiled': Offset(43, -94),
  'oil': Offset(11, -92),
  'waterNormal': Offset(43, -94),
};

/// Anchor (base centre) that puts [id]'s lip just above tube [tube]'s mouth.
Offset _pourAnchor(String id, int tube) {
  final lip = _rot(_s1Lip[id]!, _pourRot);
  return Offset(_tubeX[tube] + 4, _tubeTop - 64) - lip;
}

// ---- Scenario 2: magnesium
const Offset _lampBase = Offset(175, 390);
const double _lampW = 92, _lampH = 70;
const Offset _flame = Offset(175, 272); // flame body (target for the ribbon end)
const Offset _wgC = Offset(560, 372); // watch glass rim centre
const double _wgW = 134;
const double _tipDist = 58; // pivot -> tong tips
const double _ribStart = 48; // pivot -> clamped end of the ribbon
const double _ribLen = 124;
const double _heldAngle = math.pi + 0.26;
const Offset _heldPivot = Offset(452, 318);
const double _burnAngle = math.pi + 0.35;
const double _ashAngle = math.pi + 0.3;
const Offset _rodHomeA = Offset(690, 400);
const Offset _rodHomeB = Offset(872, 400);
const double _rodLen = 182;

Offset _burnPivot() => _flame - _dir(_burnAngle) * (_ribStart + _ribLen);
Offset _ashPivot() => Offset(_wgC.dx, _wgC.dy - 58) - _dir(_ashAngle) * (_ribStart + _ribLen / 2);

// ============================================================ TWEENS
// Tiny TWEEN.js replacement driven by the page Ticker (scene time in s).

class _Tween {
  _Tween(this.start, this.duration, this.curve, this.update, this.done);
  final double start;
  final double duration;
  final Curve curve;
  final void Function(double v) update;
  final VoidCallback? done;
}

class _Tweens {
  final List<_Tween> _list = [];
  double now = 0;

  bool get isEmpty => _list.isEmpty;

  void add(
    int ms,
    void Function(double v) update, {
    Curve curve = Curves.linear,
    VoidCallback? done,
  }) {
    _list.add(_Tween(now, ms / 1000, curve, update, done));
  }

  void tick(double t) {
    now = t;
    if (_list.isEmpty) return;
    for (final tw in List<_Tween>.of(_list)) {
      if (!_list.contains(tw)) continue;
      final p = tw.duration <= 0 ? 1.0 : ((t - tw.start) / tw.duration).clamp(0.0, 1.0);
      tw.update(tw.curve.transform(p));
      if (p >= 1) {
        _list.remove(tw);
        tw.done?.call();
      }
    }
  }

  void clear() => _list.clear();
}

// ============================================================ MODEL

/// A movable bench object (the Three.js group with userData).
class _Obj {
  _Obj(this.id, this.home, [this.homeRot = 0])
      : pos = home,
        rot = homeRot;

  final String id;
  final Offset home;
  final double homeRot;
  Offset pos;
  double rot;

  /// Extra pose value (nail: 0 lying → 1 upright, litmus: 0 flat → 1 standing).
  double up = 0;
  bool active = false;
  bool visible = true;
  bool dragging = false;
  bool moving = false;

  /// HTML `State.dragState.startPos / startRot`.
  Offset dragStartPos = Offset.zero;
  double dragStartRot = 0;
  double dragStartUp = 0;

  bool get onTop => dragging || moving || pos != home;
}

class _Tube {
  bool hasNail = false;
  double water = 0; // column height in px
  double oil = 0;
  int beads = 0;
  bool sealed = false;
  bool clicked = false;
}

class _Particle {
  _Particle(this.p, this.v, this.life, this.size, this.color, this.kind);
  Offset p;
  Offset v;
  final double life;
  final double size;
  final Color color;
  final int kind; // 0 spark, 1 smoke, 2 powder / beads, 3 water drop
  double age = 0;
}

class _Bubble {
  _Bubble(this.x, this.y, this.r, this.speed);
  double x; // -0.5..0.5 of beaker width
  double y; // 0..1 of water column
  final double r;
  final double speed;
}

class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  bool advancing = false;
  final math.Random rng = math.Random();

  // Scenario 1 ------------------------------------------------------
  final List<_Obj> nails = [];
  final Map<String, _Obj> s1 = {};
  final List<_Tube> tubes = List.generate(3, (_) => _Tube());
  final Map<String, int> nailTube = {};
  final Map<String, double> nailRust = {};
  final List<_Bubble> bubbles = [];
  bool bubblesOn = true;
  int nailsPlaced = 0;
  bool aSilica = false, aStopper = false;
  bool bWater = false, bOil = false, bStopper = false;
  bool cWater = false;
  bool timeLapseStarted = false, timeLapsed = false;
  bool night = false;
  final Set<int> clickedTubes = {};

  /// Active pour: container id, tube index, 0..1 progress and stream colour.
  String? pourId;
  int pourTube = 0;
  double pour = 0;

  // Scenario 2 ------------------------------------------------------
  late _Obj sandpaper, tongs, dropper, redLit, blueLit;
  Offset ribbonHome = const Offset(300, 458);
  bool ribbonHeld = false;
  bool ribbonVisible = true;
  double ribbonClean = 0; // dull 0x666666 -> shiny white metal
  double ribbonAsh = 0; // -> 0.9 grey ash
  double clamp = 0; // tongs arms: 0 rest, 1 clamped, -1 opened
  bool tongsAirborne = false;
  double flare = 0; // dazzling flare intensity
  int wgState = 0; // 0 empty, 1 ash, 2 wet ash, 3 cloudy solution
  double wgAnim = 1; // appear animation of the current watch glass content
  double dropperWater = 1;
  Offset rodA = _rodHomeA, rodB = _rodHomeB;
  bool rodActive = false;
  double redToBlue = 0;
  bool cleaned = false, pickedUp = false, burning = false, ashed = false;
  bool watered = false, stirred = false, redTested = false, blueTested = false, done = false;

  final List<_Particle> particles = [];

  _Obj? dragged;

  /// Drop zone highlighted while the dragged object would snap there.
  Offset? hover;
  double hoverR = 40;
  Offset grab = Offset.zero;
  Offset finger = Offset.zero;

  Offset get tongsDir => _dir(tongs.rot);
  Offset get tongsTips => tongs.pos + tongsDir * _tipDist;
  Offset get ribbonA => ribbonHeld ? tongs.pos + tongsDir * _ribStart : ribbonHome - const Offset(_ribLen / 2, 0);
  Offset get ribbonB => ribbonHeld ? tongs.pos + tongsDir * (_ribStart + _ribLen) : ribbonHome + const Offset(_ribLen / 2, 0);
  Offset get ribbonMid => (ribbonA + ribbonB) / 2;

  List<_Obj> get s2Objs => [sandpaper, tongs, dropper, redLit, blueLit];
}

// ============================================================ PAINTING
// 2.5D recreation of the Three.js lab bench. Reads the mutable [_Scene]
// every frame (repaint is driven by the page Ticker).

class _A2Painter extends CustomPainter {
  _A2Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.text,
    required this.lang,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final Map<String, String> text;
  final LabLang lang;

  double get t => scene.time;

  static const Color _glass = Color(0xFF93C5FD);
  static const Color _wood = Color(0xFFD97706);
  static const Color _table = Color(0xFF8B5A2B);

  @override
  void paint(Canvas canvas, Size size) {
    _room(canvas, size);
    if (scene.scenario == 0) {
      _paintS1(canvas, size);
    } else {
      _paintS2(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _A2Painter old) =>
      old.scene != scene ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.text != text;

  // ------------------------------------------------------------ room

  void _room(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    // Canvas background (HTML #canvas-wrapper radial gradient).
    final wall = Rect.fromLTRB(bleed.left, bleed.top, bleed.right, _tableY + 1);
    canvas.drawRect(
      wall,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.15),
          radius: 0.9,
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF020617)]
              : const [Color(0xFFF1F5F9), Color(0xFFCBD5E1)],
        ).createShader(Rect.fromLTWH(0, -120, size.width, _tableY + 240)),
    );
    // Wooden table top (BoxGeometry 45 x 0.5 x 25, colour 0x8b5a2b).
    final top = Rect.fromLTRB(bleed.left, _tableY, bleed.right, bleed.bottom);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_table, -0.12), labShade(_table, 0.08), labShade(_table, 0.14)],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTRB(0, _tableY, size.width, size.height)),
    );
    // Grain converging to the vanishing point, plank seams in perspective.
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.07)
      ..strokeWidth = 1.2;
    for (var i = -30; i <= 60; i++) {
      final front = Offset(i * 38.0, size.height + 200);
      final k = (_tableY - front.dy) / (_vp.dy - front.dy);
      final back = Offset.lerp(front, _vp, k)!;
      canvas.drawLine(back, front, grain);
    }
    final seam = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var d = 1; d < 9; d++) {
      final y = _tableY + 22.0 * d * d / 2.4;
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), seam);
    }
    // Back edge highlight + soft contact shadow on the wall.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, _tableY - 10, bleed.right, _tableY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: isDark ? 0.35 : 0.15)],
        ).createShader(Rect.fromLTRB(0, _tableY - 10, 10, _tableY)),
    );
    canvas.drawLine(
      Offset(bleed.left, _tableY),
      Offset(bleed.right, _tableY),
      Paint()
        ..color = labShade(_table, 0.3)
        ..strokeWidth = 1.5,
    );
  }

  // --------------------------------------------------------- helpers

  /// HTML `.item-label` chip (light / dark variants).
  void _label(Canvas canvas, String key, Offset at) {
    if (!showLabels) return;
    labText(
      canvas,
      text[key] ?? key,
      at,
      size: 13,
      weight: FontWeight.w800,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      background: isDark ? const Color(0xCC0F172A) : const Color(0xE6FFFFFF),
      border: isDark ? const Color(0x26FFFFFF) : const Color(0x1A000000),
      borderWidth: 1,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
    );
  }

  /// HTML `.tube-label`: coloured square with a white letter.
  void _badge(Canvas canvas, String letter, Color color, Offset c) {
    if (!showLabels) return;
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 34, height: 34), const Radius.circular(8));
    canvas.drawRRect(
      r.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(r, Paint()..color = color);
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.4),
    );
    labText(canvas, letter, c, size: 18, weight: FontWeight.w900, color: Colors.white, shadows: const [
      Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 1)),
    ]);
  }

  /// Pulsing ring under an object the student can use now.
  void _hint(Canvas canvas, Offset c, double w, {double h = 0}) {
    final pulse = 0.5 + 0.5 * math.sin(t * 4);
    final rect = Rect.fromCenter(center: c, width: w + 8 * pulse, height: (h > 0 ? h : w * 0.32) + 4 * pulse);
    canvas.drawOval(
      rect,
      Paint()
        ..color = _Colors.zslYellow.withValues(alpha: 0.12 + 0.12 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.zslYellow.withValues(alpha: 0.35 + 0.4 * pulse),
    );
  }

  /// Whether [o] is one of the objects the current step asks the student
  /// to use (only those pulse, so the order of actions is clear).
  bool _hintOn(_Obj o) {
    final s = scene;
    if (!o.active || o.dragging || o.moving || s.advancing) return false;
    if (s.scenario == 0) {
      return switch (o.id) {
        'silica' => s.step == 2 && !s.aSilica,
        'stopperA' => s.step == 2 && s.aSilica,
        'waterBoiled' => s.step == 3 && !s.bWater,
        'oil' => s.step == 3 && s.bWater && !s.bOil,
        'stopperB' => s.step == 3 && s.bOil,
        'waterNormal' => s.step == 4 && !s.cWater,
        _ => s.step == 1,
      };
    }
    return switch (o.id) {
      'sandpaper' => s.step == 1 && !s.cleaned,
      'tongs' => (s.step == 2 && !s.pickedUp) || (s.step == 3 && !s.burning) || (s.step == 4 && !s.ashed),
      'dropper' => s.step == 5 && !s.watered,
      _ => s.step == 6,
    };
  }

  /// Glowing drop zone shown while a dragged object would snap here.
  void _target(Canvas canvas, Offset c, double r) {
    final pulse = 0.5 + 0.5 * math.sin(t * 7);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = _Colors.green.withValues(alpha: 0.18 + 0.12 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    labDashedPath(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.green.withValues(alpha: 0.8),
      dash: 7,
      gap: 5,
      phase: t * 30,
    );
  }

  /// Box with perspective (top face and inner side face towards [_vp]).
  void _pbox(Canvas canvas, Rect front, double f, Color color) {
    final tl = _toVp(front.topLeft, f), tr = _toVp(front.topRight, f);
    final top = Path()
      ..moveTo(front.left, front.top)
      ..lineTo(front.right, front.top)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(tl.dx, tl.dy)
      ..close();
    canvas.drawPath(top, Paint()..color = labShade(color, 0.16));
    Path? side;
    if (front.right < _vp.dx - 2) {
      final br = _toVp(front.bottomRight, f);
      side = Path()
        ..moveTo(front.right, front.top)
        ..lineTo(tr.dx, tr.dy)
        ..lineTo(br.dx, br.dy)
        ..lineTo(front.right, front.bottom)
        ..close();
    } else if (front.left > _vp.dx + 2) {
      final bl = _toVp(front.bottomLeft, f);
      side = Path()
        ..moveTo(front.left, front.top)
        ..lineTo(tl.dx, tl.dy)
        ..lineTo(bl.dx, bl.dy)
        ..lineTo(front.left, front.bottom)
        ..close();
    }
    if (side != null) canvas.drawPath(side, Paint()..color = labShade(color, -0.28));
    canvas.drawRect(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(color, 0.02), labShade(color, -0.18)],
        ).createShader(front),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = labShade(color, -0.45).withValues(alpha: 0.55);
    canvas.drawPath(top, edge);
    canvas.drawRect(front, edge);
  }

  /// Metallic gradient across a strip drawn in a local frame (x along it).
  Paint _metal(Rect r, Color c, {double shine = 0.55}) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [labShade(c, shine), c, labShade(c, -0.45)],
      stops: const [0, 0.45, 1],
    ).createShader(r);
}

// ====================================================== SCENARIO 1 PAINT

extension _S1Paint on _A2Painter {
  void _paintS1(Canvas canvas, Size size) {
    final s = scene;
    // Rack base (HTML BoxGeometry 8.5 x 0.2 x 2.5, wood 0xd97706).
    labGroundShadow(canvas, const Offset(315, 396), 380, 22, opacity: 0.35);
    _pbox(canvas, const Rect.fromLTRB(136, 386, 494, 397), 0.07, _A2Painter._wood);
    for (var i = 0; i < 3; i++) {
      _tube(canvas, i);
    }
    // Side columns of the rack.
    _pbox(canvas, const Rect.fromLTRB(138, 288, 154, 386), 0.07, _A2Painter._wood);
    _pbox(canvas, const Rect.fromLTRB(476, 288, 492, 386), 0.07, _A2Painter._wood);
    if (s.step == 6) {
      for (var i = 0; i < 3; i++) {
        if (!s.tubes[i].clicked) _tubeHint(canvas, i);
      }
    }

    // Reagents (z = 2), stoppers (z = 3.5), tray of nails (z = 4).
    for (final id in const ['silica', 'waterBoiled', 'oil', 'waterNormal']) {
      final o = s.s1[id]!;
      if (!o.onTop) _container(canvas, o);
    }
    for (final id in const ['stopperA', 'stopperB']) {
      final o = s.s1[id]!;
      if (!o.onTop) _stopperObj(canvas, o);
    }
    _tray(canvas);
    for (final n in s.nails) {
      if (!n.onTop && !s.nailTube.containsKey(n.id)) _nailObj(canvas, n);
    }

    // Objects that are dragged or animating are drawn above the bench.
    final hover = s.hover;
    if (hover != null) _target(canvas, hover, s.hoverR);
    for (final id in const ['stopperA', 'stopperB']) {
      final o = s.s1[id]!;
      if (o.onTop) _stopperObj(canvas, o);
    }
    for (final id in const ['silica', 'waterBoiled', 'oil', 'waterNormal']) {
      final o = s.s1[id]!;
      if (o.onTop) _container(canvas, o);
    }
    for (final n in s.nails) {
      final inTube = s.nailTube.containsKey(n.id) && !n.moving;
      if (n.onTop && !inTube) _nailObj(canvas, n);
    }
    _pourStream(canvas);

    // Night during the time-lapse (ambient / key light dimmed).
    if (s.night) {
      canvas.drawRect(labBleed(size), Paint()..color = const Color(0xFF020617).withValues(alpha: 0.6));
    }
    _s1Labels(canvas);
  }

  void _s1Labels(Canvas canvas) {
    final s = scene;
    for (var i = 0; i < 3; i++) {
      _badge(canvas, _tubeLetters[i], _tubeColors[i], Offset(_tubeX[i], _tubeTop - 34));
    }
    const offs = {'silica': 108.0, 'waterBoiled': 112.0, 'oil': 118.0, 'waterNormal': 112.0};
    offs.forEach((id, dy) {
      final o = s.s1[id]!;
      final key = switch (id) {
        'silica' => 'lbl_silica',
        'waterBoiled' => 'lbl_boiled',
        'oil' => 'lbl_oil',
        _ => 'lbl_water',
      };
      _label(canvas, key, o.pos - Offset(0, dy));
    });
    for (final id in const ['stopperA', 'stopperB']) {
      final o = s.s1[id]!;
      if (o.active || (!o.moving && o.pos == o.home)) _label(canvas, 'lbl_stopper', o.pos - const Offset(0, 44));
    }
    if (s.nails.any((n) => !s.nailTube.containsKey(n.id))) {
      _label(canvas, 'lbl_nail', const Offset(92, 430));
    }
  }

  void _tubeHint(Canvas canvas, int i) {
    final x = _tubeX[i];
    final pulse = 0.5 + 0.5 * math.sin(t * 4 + i);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTRB(x - _tubeW / 2 - 6, _tubeTop - 8, x + _tubeW / 2 + 6, _tubeBottom + 6),
      const Radius.circular(26),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.zslYellow.withValues(alpha: 0.25 + 0.45 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  /// Glass test tube (open cylinder + hemispherical bottom + rim) with its
  /// nail, silica gel beads, water, oil layer and stopper.
  void _tube(Canvas canvas, int i) {
    final s = scene;
    final tb = s.tubes[i];
    final x = _tubeX[i];
    const w = _tubeW;
    final l = x - w / 2, r = x + w / 2;
    const rr = w / 2;
    final rimH = w * _tilt(_tubeTop);
    final body = Path()
      ..moveTo(l, _tubeTop)
      ..lineTo(l, _tubeBottom - rr)
      ..arcToPoint(Offset(r, _tubeBottom - rr), radius: const Radius.circular(rr), clockwise: false)
      ..lineTo(r, _tubeTop)
      ..close();
    // Back of the glass.
    canvas.drawPath(body, Paint()..color = _A2Painter._glass.withValues(alpha: 0.14));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, _tubeTop), width: w, height: rimH),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _A2Painter._glass.withValues(alpha: 0.55),
    );

    canvas.save();
    canvas.clipPath(body);
    // Silica gel beads behind the nail.
    _beads(canvas, x, tb.beads, back: true);
    for (final n in s.nails) {
      if (s.nailTube[n.id] == i && !n.moving) {
        _nail(canvas, n.pos, n.rot, _nailLen, s.nailRust[n.id] ?? 0);
      }
    }
    _beads(canvas, x, tb.beads, back: false);
    if (tb.water > 0.5) {
      final top = _tubeBottom - tb.water;
      final wr = Rect.fromLTRB(l, top, r, _tubeBottom);
      canvas.drawRect(
        wr,
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF0EA5E9).withValues(alpha: 0.62),
              const Color(0xFF38BDF8).withValues(alpha: 0.42),
              const Color(0xFF0284C7).withValues(alpha: 0.66),
            ],
            stops: const [0, 0.4, 1],
          ).createShader(wr),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, top), width: w - 2, height: (w - 2) * _tilt(top)),
        Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: 0.75),
      );
      if (tb.oil > 0.5) {
        final ot = top - tb.oil;
        final orect = Rect.fromLTRB(l, ot, r, top);
        canvas.drawRect(
          orect,
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFEAB308), Color(0xFFFDE047), Color(0xFFCA8A04)],
              stops: [0, 0.45, 1],
            ).createShader(orect),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, ot), width: w - 2, height: (w - 2) * _tilt(ot)),
          Paint()..color = const Color(0xFFFEF08A),
        );
      }
    }
    canvas.restore();

    // Front of the glass: outline, reflections, rim.
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _A2Painter._glass.withValues(alpha: 0.8),
    );
    final hl = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.32);
    canvas.drawLine(Offset(l + 8, _tubeTop + 10), Offset(l + 8, _tubeBottom - rr - 2), hl);
    canvas.drawLine(
      Offset(r - 6, _tubeTop + 14),
      Offset(r - 6, _tubeBottom - rr - 8),
      hl
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, _tubeTop), width: w + 4, height: rimH + 2),
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _A2Painter._glass.withValues(alpha: 0.9),
    );
  }

  /// White silica-gel granules piled at the bottom of tube A.
  void _beads(Canvas canvas, double x, int count, {required bool back}) {
    for (var k = 0; k < count; k++) {
      if ((k % 3 == 0) != back) continue;
      final row = k ~/ 4;
      final col = k % 4;
      final bx = x - 13 + col * 8.6 + (row.isOdd ? 4 : 0) + ((k * 7) % 3 - 1) * 1.2;
      final by = _tubeBottom - 6 - row * 6.5 - (col.isOdd ? 1.5 : 0);
      labSphere(canvas, Offset(bx, by), 4.4, back ? const Color(0xFFE2E8F0) : Colors.white, highlight: 0.6, shade: 0.3);
    }
  }

  void _nailObj(Canvas canvas, _Obj n) {
    final lifted = n.dragging || n.moving;
    if (n.up < 0.5) {
      labGroundShadow(canvas, n.pos + Offset(3, lifted ? 22 : 5), _nailLen * 0.9, lifted ? 10 : 7,
          opacity: lifted ? 0.18 : 0.3);
    }
    if (_hintOn(n)) _hint(canvas, n.pos, 30, h: 14);
    _nail(canvas, n.pos, n.rot, _nailLen, scene.nailRust[n.id] ?? 0);
  }

  /// Iron nail: shaft, cone tip and flat head (HTML nail group, 0xaaaaaa
  /// metal; 0x9a3412 matte rust after the time-lapse).
  void _nail(Canvas canvas, Offset c, double angle, double len, double rust) {
    final color = Color.lerp(const Color(0xFFAAAAAA), const Color(0xFF9A3412), rust)!;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final h = len / 2;
    final shaft = Path()
      ..moveTo(-h, -3.2)
      ..lineTo(h - 14, -3.2)
      ..lineTo(h, 0)
      ..lineTo(h - 14, 3.2)
      ..lineTo(-h, 3.2)
      ..close();
    final sr = Rect.fromLTRB(-h, -3.2, h, 3.2);
    canvas.drawPath(shaft, _metal(sr, color, shine: 0.6 - 0.45 * rust));
    final head = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-h, 0), width: 5, height: 19), const Radius.circular(2));
    canvas.drawRRect(head, _metal(head.outerRect, labShade(color, -0.05), shine: 0.6 - 0.45 * rust));
    if (rust > 0) {
      final spot = Paint()..color = const Color(0xFF7C2D12).withValues(alpha: rust);
      final spot2 = Paint()..color = const Color(0xFFC2410C).withValues(alpha: 0.9 * rust);
      for (var k = 0; k < 9; k++) {
        final px = -h + 6 + k * (len - 18) / 9;
        canvas.drawCircle(Offset(px, (k.isEven ? -1.2 : 1.4)), 1.6 + (k % 3) * 0.5, k % 3 == 0 ? spot2 : spot);
      }
      canvas.drawCircle(Offset(-h, -5), 2, spot);
      canvas.drawCircle(Offset(-h, 5), 1.8, spot2);
    }
    canvas.restore();
  }

  void _tray(Canvas canvas) {
    // HTML tray: BoxGeometry 4.5 x 0.1 x 4.0, colour 0xf1f5f9.
    labGroundShadow(canvas, const Offset(88, 494), 176, 16, opacity: 0.3);
    _pbox(canvas, const Rect.fromLTRB(6, 488, 166, 497), 0.08, const Color(0xFFF1F5F9));
    final a = _toVp(const Offset(17, 486), 0.068), b = _toVp(const Offset(155, 486), 0.068);
    final inner = Path()
      ..moveTo(17, 486)
      ..lineTo(155, 486)
      ..lineTo(b.dx, b.dy)
      ..lineTo(a.dx, a.dy)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.6),
    );
  }
}

extension _S1Bench on _A2Painter {
  /// Silica jar, boiled / plain water beakers and the oil bottle. Drawn in
  /// a local frame: origin = base centre, rotated by the object's tilt.
  void _container(Canvas canvas, _Obj o) {
    final sz = _s1Size[o.id]!;
    final lifted = o.dragging || o.moving;
    labGroundShadow(canvas, Offset(o.pos.dx, lifted ? 470 : o.pos.dy + 2), sz.width * 1.05, 16,
        opacity: lifted ? 0.15 : 0.32);
    if (_hintOn(o)) _hint(canvas, o.pos + const Offset(0, 2), sz.width + 22);
    canvas.save();
    canvas.translate(o.pos.dx, o.pos.dy);
    canvas.rotate(o.rot);
    final tilt = _tilt(o.pos.dy - sz.height);
    switch (o.id) {
      case 'silica':
        _silicaJar(canvas, sz, tilt);
      case 'oil':
        _oilBottle(canvas, sz, tilt);
      default:
        _beakerLocal(canvas, sz, tilt, boiled: o.id == 'waterBoiled');
    }
    canvas.restore();
  }

  void _silicaJar(Canvas canvas, Size sz, double tilt) {
    final w = sz.width;
    labCylinder(canvas, Rect.fromLTWH(-w / 2, -74, w, 74), const Color(0xFFF8FAFC), tilt: tilt, drawTop: false);
    // Silica beads visible through a window label.
    final win = RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2 + 14, -54, w - 28, 32), const Radius.circular(6));
    canvas.drawRRect(win, Paint()..color = const Color(0xFFDBEAFE));
    canvas.save();
    canvas.clipRRect(win);
    for (var k = 0; k < 18; k++) {
      final bx = -w / 2 + 18 + (k % 6) * 10.0 + ((k ~/ 6).isOdd ? 5 : 0);
      final by = -50 + (k ~/ 6) * 10.0;
      labSphere(canvas, Offset(bx, by), 4.6, k % 4 == 0 ? const Color(0xFF93C5FD) : Colors.white,
          highlight: 0.6, shade: 0.3);
    }
    canvas.restore();
    canvas.drawRRect(
      win,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF94A3B8),
    );
    labCylinder(canvas, Rect.fromLTWH(-w / 2 - 2, -90, w + 4, 16), const Color(0xFFF59E0B), tilt: tilt);
  }

  void _oilBottle(Canvas canvas, Size sz, double tilt) {
    const body = Color(0xFFFACC15);
    final w = sz.width;
    labCylinder(canvas, Rect.fromLTWH(-w / 2, -74, w, 74), body, tilt: tilt, drawTop: false);
    final neck = Path()
      ..moveTo(-w / 2, -74)
      ..cubicTo(-w / 2, -84, -12, -86, -11, -92)
      ..lineTo(11, -92)
      ..cubicTo(12, -86, w / 2, -84, w / 2, -74)
      ..close();
    canvas.drawPath(
      neck,
      Paint()
        ..shader = LinearGradient(colors: [labShade(body, -0.3), labShade(body, 0.3), body, labShade(body, -0.4)])
            .createShader(Rect.fromLTWH(-w / 2, -92, w, 18)),
    );
    labCylinder(canvas, const Rect.fromLTWH(-12, -100, 24, 8), const Color(0xFF222222), tilt: tilt);
    canvas.drawLine(
      Offset(-w / 2 + 9, -66),
      Offset(-w / 2 + 9, -8),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  void _beakerLocal(Canvas canvas, Size sz, double tilt, {required bool boiled}) {
    final w = sz.width, h = sz.height;
    final liquid = boiled ? const Color(0xFF0284C7) : const Color(0xFF0EA5E9);
    final eh = w * tilt;
    final level = h * 1.8 / 2.5;
    // Water column.
    final wr = Rect.fromLTRB(-w / 2 + 3, -level, w / 2 - 3, -2);
    canvas.drawRect(
      wr,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(liquid, -0.15).withValues(alpha: 0.95),
          labShade(liquid, 0.2).withValues(alpha: 0.95),
          labShade(liquid, -0.25).withValues(alpha: 0.95),
        ], stops: const [0, 0.35, 1])
            .createShader(wr),
    );
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, -2), width: w - 6, height: eh), Paint()..color = liquid);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -level), width: w - 6, height: eh),
      Paint()..color = labShade(liquid, 0.35),
    );
    if (boiled && scene.bubblesOn) {
      for (final b in scene.bubbles) {
        final y = -4 - b.y * (level - 6);
        canvas.drawCircle(
          Offset(b.x * (w - 16), y),
          b.r,
          Paint()..color = Colors.white.withValues(alpha: 0.5 * (1 - b.y * 0.4)),
        );
      }
    }
    // Blue base disc (HTML bwBase 0x0284c7).
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: w, height: eh),
      Paint()..color = const Color(0xFF0284C7),
    );
    // Glass walls.
    final glass = Path()
      ..moveTo(-w / 2, -h)
      ..lineTo(-w / 2, 0)
      ..arcTo(Rect.fromCenter(center: Offset.zero, width: w, height: eh), math.pi, -math.pi, false)
      ..lineTo(w / 2, -h);
    canvas.drawPath(glass, Paint()..color = Colors.white.withValues(alpha: 0.1));
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -h), width: w, height: eh),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.drawLine(
      Offset(-w / 2 + 9, -h + 10),
      Offset(-w / 2 + 9, -10),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 1; i <= 3; i++) {
      final y = -h * i / 4;
      canvas.drawLine(Offset(w / 2 - 18, y), Offset(w / 2 - 4, y), g);
    }
  }

  void _stopperObj(Canvas canvas, _Obj o) {
    final lifted = o.dragging || o.moving;
    final sealed = !o.active && !lifted && o.pos != o.home;
    if (!sealed) {
      labGroundShadow(canvas, Offset(o.pos.dx, lifted ? 490 : o.pos.dy + 2), 52, 12, opacity: lifted ? 0.15 : 0.3);
    }
    if (_hintOn(o)) _hint(canvas, o.pos + const Offset(0, 2), 64);
    _stopper(canvas, o.pos);
  }

  /// Cork stopper (CylinderGeometry 0.65 / 0.5 x 0.6, colour 0x8b4513).
  void _stopper(Canvas canvas, Offset base) {
    const c = Color(0xFF8B4513);
    const bw = 36.0, tw = 50.0, h = 24.0;
    final tilt = _tilt(base.dy - h);
    final body = Path()
      ..moveTo(base.dx - tw / 2, base.dy - h)
      ..lineTo(base.dx - bw / 2, base.dy)
      ..arcTo(Rect.fromCenter(center: base, width: bw, height: bw * tilt), math.pi, -math.pi, false)
      ..lineTo(base.dx + tw / 2, base.dy - h)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [labShade(c, -0.35), labShade(c, 0.2), c, labShade(c, -0.45)], stops: const [
          0,
          0.3,
          0.6,
          1,
        ]).createShader(Rect.fromLTRB(base.dx - tw / 2, base.dy - h, base.dx + tw / 2, base.dy)),
    );
    final topR = Rect.fromCenter(center: base - const Offset(0, h), width: tw, height: tw * tilt);
    canvas.drawOval(topR, Paint()..color = labShade(c, 0.22));
    final speck = Paint()..color = labShade(c, -0.4).withValues(alpha: 0.6);
    for (var k = 0; k < 7; k++) {
      canvas.drawCircle(
        Offset(base.dx - 16 + k * 5.3, base.dy - h + (k.isEven ? -1.5 : 1.2)),
        1.1,
        speck,
      );
      canvas.drawCircle(Offset(base.dx - 12 + k * 4, base.dy - 8 - (k % 3) * 4), 0.9, speck);
    }
  }

  /// Liquid / bead stream from the tilted container lip into the tube.
  void _pourStream(Canvas canvas) {
    final s = scene;
    final id = s.pourId;
    if (id == null) return;
    final o = s.s1[id]!;
    final lip = o.pos + _rot(_s1Lip[id]!, o.rot);
    final mouth = Offset(_tubeX[s.pourTube], _tubeTop + 6);
    final fade = (math.sin(s.pour * math.pi) * 1.6).clamp(0.0, 1.0);
    final path = Path()
      ..moveTo(lip.dx, lip.dy)
      ..quadraticBezierTo(lip.dx + 6, lip.dy + 16, mouth.dx, mouth.dy);
    if (id == 'silica') {
      for (final m in path.computeMetrics()) {
        for (var k = 0; k < 8; k++) {
          final d = ((k / 8 + t * 2.2) % 1) * m.length;
          final pt = m.getTangentForOffset(d)!.position;
          labSphere(canvas, pt + Offset(k.isEven ? -2 : 2, 0), 3.4, Colors.white, highlight: 0.6, shade: 0.3,
              opacity: fade);
        }
      }
      return;
    }
    final color = switch (id) {
      'oil' => const Color(0xFFFACC15),
      'waterBoiled' => const Color(0xFF0284C7),
      _ => const Color(0xFF0EA5E9),
    };
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.85 * fade),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.5 * fade),
    );
  }
}

// ====================================================== SCENARIO 2 PAINT

extension _S2Paint on _A2Painter {
  void _paintS2(Canvas canvas, Size size) {
    final s = scene;
    final stirring = s.rodA != _rodHomeA || s.rodB != _rodHomeB;
    // Warm flickering light of the spirit lamp (PointLight 0xffaa00).
    final flick = 0.85 + 0.15 * math.sin(t * 23) * math.sin(t * 7.3);
    labGlow(canvas, _flame, 230, const Color(0xFFFFAA00), intensity: 0.22 * flick);

    if (!s.dropper.onTop) _dropperObj(canvas, s.dropper);
    _lamp(canvas);
    if (!stirring) _rod(canvas);
    _watchGlass(canvas);
    if (stirring) _rod(canvas);
    if (!s.sandpaper.onTop) _sandpaperObj(canvas, s.sandpaper);
    if (s.ribbonVisible && !s.ribbonHeld) _ribbonFlat(canvas);
    for (final o in [s.redLit, s.blueLit]) {
      if (!o.onTop && o.up < 0.5) _litmusObj(canvas, o);
    }
    if (!s.tongs.onTop) _tongsObj(canvas);

    final hover = s.hover;
    if (hover != null) _target(canvas, hover, s.hoverR);
    if (s.sandpaper.onTop) _sandpaperObj(canvas, s.sandpaper);
    for (final o in [s.redLit, s.blueLit]) {
      if (o.onTop && o.up < 0.999) _litmusObj(canvas, o);
    }
    if (s.dropper.onTop) _dropperObj(canvas, s.dropper);
    if (s.tongs.onTop) _tongsObj(canvas);
    _particles(canvas);
    _flare(canvas, size);
    _s2Labels(canvas);
  }

  void _s2Labels(Canvas canvas) {
    final s = scene;
    _label(canvas, 'lbl_lamp', const Offset(175, 222));
    _label(canvas, 'lbl_sandpaper', s.sandpaper.pos - const Offset(0, 36));
    if (s.ribbonVisible) {
      _label(canvas, 'lbl_ribbon', s.ribbonMid - Offset(0, s.ribbonHeld ? 26 : 22));
    }
    final d = s.tongsDir;
    _label(
      canvas,
      'lbl_tongs',
      s.tongsAirborne ? s.tongs.pos - d * 72 + const Offset(0, -26) : s.tongsTips + const Offset(0, -26),
    );
    _label(canvas, 'lbl_wg', Offset(_wgC.dx, _wgC.dy - 38));
    if (s.dropper.rot.abs() < 0.3) _label(canvas, 'lbl_dropper', s.dropper.pos - const Offset(0, 28));
    _label(canvas, 'lbl_rod', (s.rodA + s.rodB) / 2 - const Offset(0, 20));
    for (final o in [s.redLit, s.blueLit]) {
      if (o.up < 0.5) _label(canvas, o == s.redLit ? 'lbl_redL' : 'lbl_blueL', _toVp(o.pos, 0.15) - const Offset(0, 16));
    }
  }

  /// Spirit lamp: body, collar, wick and the flickering flame.
  void _lamp(Canvas canvas) {
    const b = _lampBase;
    labGroundShadow(canvas, b + const Offset(0, 2), _lampW * 1.15, 18, opacity: 0.35);
    final tilt = _tilt(b.dy - _lampH);
    labCylinder(canvas, Rect.fromLTWH(b.dx - _lampW / 2, b.dy - _lampH, _lampW, _lampH), const Color(0xFFE5E7EB),
        tilt: tilt);
    // Spirit level seen through the glass body.
    final fuel = Rect.fromLTWH(b.dx - _lampW / 2 + 6, b.dy - _lampH * 0.55, _lampW - 12, _lampH * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fuel, const Radius.circular(6)),
      Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.28),
    );
    labCylinder(canvas, Rect.fromLTWH(b.dx - 14, b.dy - _lampH - 9, 28, 9), const Color(0xFF9CA3AF), tilt: tilt);
    canvas.drawRect(
      Rect.fromLTWH(b.dx - 3.5, b.dy - _lampH - 22, 7, 14),
      Paint()..color = const Color(0xFF222222),
    );
    // Flame (cone 0xf59e0b, additive) with flicker.
    labFlame(canvas, Offset(b.dx, b.dy - _lampH - 16), 60, t);
  }

  void _watchGlass(Canvas canvas) {
    final s = scene;
    final c = _wgC;
    final rimH = _wgW * _tilt(c.dy);
    final rim = Rect.fromCenter(center: c, width: _wgW, height: rimH);
    labGroundShadow(canvas, c + Offset(0, rimH / 2 + 10), _wgW * 0.85, 16, opacity: 0.32);
    // Outer bowl (SphereGeometry cap, 0x3b82f6, opacity 0.7).
    final bowl = Path()
      ..moveTo(rim.left, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + rimH / 2 + 34, rim.right, c.dy)
      ..arcTo(rim, 0, math.pi, false)
      ..close();
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF3B82F6).withValues(alpha: 0.35), const Color(0xFF1D4ED8).withValues(alpha: 0.6)],
        ).createShader(Rect.fromLTRB(rim.left, c.dy, rim.right, c.dy + rimH / 2 + 20)),
    );
    canvas.drawOval(
      rim,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFBFDBFE).withValues(alpha: 0.35),
          const Color(0xFF3B82F6).withValues(alpha: 0.4),
        ]).createShader(rim),
    );
    // Contents: ash pile, wet ash, cloudy solution.
    final a = Curves.easeOutBack.transform(s.wgAnim.clamp(0.0, 1.0));
    switch (s.wgState) {
      case 1:
        _ashPile(canvas, c + const Offset(0, 4), 72 * a, 18 * a, const Color(0xFFF8FAFC));
      case 2:
        canvas.drawOval(
          Rect.fromCenter(center: c + const Offset(0, 4), width: 96 * a, height: 26 * a),
          Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.28),
        );
        _ashPile(canvas, c + const Offset(0, 4), 80 * a, 9 * a, const Color(0xFFDDDDDD));
      case 3:
        final sol = Rect.fromCenter(center: c + const Offset(0, 3), width: 102 * a, height: rimH * 0.66 * a);
        canvas.drawOval(
          sol,
          Paint()
            ..shader = RadialGradient(colors: [
              const Color(0xFFF8FAFC).withValues(alpha: 0.95),
              const Color(0xFFE2E8F0).withValues(alpha: 0.85),
              const Color(0xFFCBD5E1).withValues(alpha: 0.8),
            ], stops: const [0, 0.6, 1])
                .createShader(sol),
        );
        final swirl = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.6);
        canvas.drawArc(sol.deflate(14), t * 0.6, 2.2, false, swirl);
        canvas.drawArc(sol.deflate(24), -t * 0.5 + 2, 1.8, false, swirl);
    }
    // Litmus strips standing in the solution.
    for (final o in [s.redLit, s.blueLit]) {
      if (o.up >= 0.5 && !(o.onTop && o.up < 0.999)) _litmusObj(canvas, o);
    }
    // Front rim and reflection.
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF93C5FD).withValues(alpha: 0.9),
    );
    canvas.drawArc(
      rim.deflate(6),
      math.pi * 0.62,
      math.pi * 0.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  /// Mound of white powder (MgO) in the watch glass.
  void _ashPile(Canvas canvas, Offset c, double w, double h, Color color) {
    if (w < 1) return;
    final base = Rect.fromCenter(center: c, width: w, height: w * 0.28);
    canvas.drawOval(base, Paint()..color = labShade(color, -0.12));
    final dome = Path()
      ..moveTo(base.left, c.dy)
      ..cubicTo(base.left + w * 0.18, c.dy - h * 1.1, base.right - w * 0.18, c.dy - h * 1.1, base.right, c.dy)
      ..arcTo(base, 0, math.pi, false)
      ..close();
    canvas.drawPath(
      dome,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.6),
          colors: [Colors.white, color, labShade(color, -0.2)],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTRB(base.left, c.dy - h, base.right, base.bottom)),
    );
    final grain = Paint()..color = labShade(color, -0.25).withValues(alpha: 0.5);
    for (var k = 0; k < 10; k++) {
      canvas.drawCircle(Offset(c.dx - w * 0.35 + k * w * 0.07, c.dy - h * 0.3 * ((k * 5) % 3) / 2), 0.9, grain);
    }
  }
}

extension _S2Tools on _A2Painter {
  /// Brown, rough sandpaper sheet lying flat (BoxGeometry 1.5 x 0.1 x 1.5).
  void _sandpaperObj(Canvas canvas, _Obj o) {
    final lifted = o.dragging || o.moving;
    final c = o.pos - Offset(0, lifted ? 10 : 0);
    labGroundShadow(canvas, o.pos + const Offset(0, 14), 84, 16, opacity: lifted ? 0.18 : 0.3);
    if (_hintOn(o)) _hint(canvas, o.pos + const Offset(0, 4), 100, h: 44);
    const col = Color(0xFF8B4513);
    final fl = c + const Offset(-36, 15), fr = c + const Offset(36, 15);
    final bl = _toVp(fl, 0.075), br = _toVp(fr, 0.075);
    final top = Path()
      ..moveTo(fl.dx, fl.dy)
      ..lineTo(fr.dx, fr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();
    canvas.drawRect(Rect.fromLTRB(fl.dx, fl.dy, fr.dx, fl.dy + 4), Paint()..color = labShade(col, -0.35));
    canvas.drawPath(top, Paint()..color = labShade(col, 0.08));
    final grit = Paint()..color = labShade(col, 0.35).withValues(alpha: 0.7);
    final grit2 = Paint()..color = labShade(col, -0.35).withValues(alpha: 0.7);
    for (var k = 0; k < 46; k++) {
      final u = ((k * 37) % 23) / 23, v = ((k * 53) % 19) / 19;
      final p = Offset.lerp(Offset.lerp(bl, br, u)!, Offset.lerp(fl, fr, u)!, v)!;
      canvas.drawCircle(p, 0.9 + (k % 3) * 0.3, k.isEven ? grit : grit2);
    }
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(col, -0.45),
    );
  }

  Color get _ribbonColor {
    final s = scene;
    final base = Color.lerp(const Color(0xFF666666), const Color(0xFFE2E8F0), s.ribbonClean)!;
    return Color.lerp(base, const Color(0xFFE6E6E6), s.ribbonAsh)!;
  }

  /// Ribbon strip in a local frame (x from 0 to [len]).
  void _ribbonStrip(Canvas canvas, double len, double width) {
    final s = scene;
    final c = _ribbonColor;
    final shine = (s.ribbonClean * (1 - s.ribbonAsh)).clamp(0.0, 1.0);
    final r = Rect.fromLTWH(0, -width / 2, len, width);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(1.5)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(c, 0.25 + 0.5 * shine), c, labShade(c, -0.25 - 0.3 * shine)],
        ).createShader(r),
    );
    if (shine > 0.2 && s.ribbonAsh < 0.1) {
      // Specular glints of freshly cleaned magnesium.
      for (var k = 0; k < 3; k++) {
        final x = len * ((0.2 + k * 0.3 + t * 0.12) % 1);
        canvas.drawLine(
          Offset(x, -width / 2 + 1),
          Offset(x + 10, -width / 2 + 1),
          Paint()
            ..strokeWidth = 1.5
            ..color = Colors.white.withValues(alpha: 0.85 * shine),
        );
      }
    }
    if (s.ribbonAsh > 0.3) {
      final crumb = Paint()..color = const Color(0xFFBDBDBD).withValues(alpha: s.ribbonAsh);
      for (var k = 0; k < 12; k++) {
        canvas.drawCircle(Offset(len * k / 12 + 4, (k.isEven ? -1 : 1) * width * 0.2), 1, crumb);
      }
    }
  }

  void _ribbonFlat(Canvas canvas) {
    final s = scene;
    final a = s.ribbonA;
    labGroundShadow(canvas, s.ribbonMid + const Offset(0, 5), _ribLen + 10, 9, opacity: 0.3);
    // Thin front edge then the top face (foreshortened flat strip).
    canvas.drawRect(
      Rect.fromLTWH(a.dx, a.dy + 3, _ribLen, 2),
      Paint()..color = labShade(_ribbonColor, -0.5),
    );
    canvas.save();
    canvas.translate(a.dx, a.dy);
    _ribbonStrip(canvas, _ribLen, 7);
    canvas.restore();
  }

  void _tongsObj(Canvas canvas) {
    final s = scene;
    final o = s.tongs;
    final d = s.tongsDir;
    final lifted = o.dragging || o.moving || s.tongsAirborne;
    final shadowY = lifted ? (o.pos.dy + 150).clamp(430.0, 520.0) : o.pos.dy + 6;
    labGroundShadow(canvas, Offset(o.pos.dx + d.dx * 10, shadowY), 150, lifted ? 14 : 12, opacity: lifted ? 0.14 : 0.3);
    if (_hintOn(o)) {
      _hint(canvas, lifted ? Offset(o.pos.dx + d.dx * 10, shadowY) : o.pos + d * 6, 150, h: 44);
    }
    if (s.ribbonHeld && s.ribbonVisible) {
      canvas.save();
      canvas.translate(o.pos.dx, o.pos.dy);
      canvas.rotate(o.rot);
      canvas.translate(_ribStart, 0);
      _ribbonStrip(canvas, _ribLen, 6);
      canvas.restore();
    }
    // Scissor-style tongs: two arms crossing at the pivot (HTML tongsGrp).
    canvas.save();
    canvas.translate(o.pos.dx, o.pos.dy);
    canvas.rotate(o.rot);
    final gap = (4.5 - 3.5 * s.clamp).clamp(1.2, 10.0);
    const metal = Color(0xFFAAAAAA);
    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = labShade(metal, -0.45);
    final lite = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = labShade(metal, 0.45);
    for (final sign in const [-1.0, 1.0]) {
      final arm = Path()
        ..moveTo(-62, 13 * sign)
        ..lineTo(0, 0)
        ..lineTo(_tipDist - 4, -gap * sign);
      canvas.drawPath(arm, dark);
      canvas.drawPath(arm, lite);
      // Ring handle.
      canvas.drawCircle(Offset(-70, 15 * sign), 9, dark..strokeWidth = 4.5);
      canvas.drawCircle(Offset(-70, 15 * sign), 9, lite..strokeWidth = 1.8);
      dark.strokeWidth = 5.5;
      lite.strokeWidth = 2.4;
      // Flat gripping tip.
      final tip = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(_tipDist + 3, -gap * sign - 1.2 * sign), width: 18, height: 4.5),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(tip, _metal(tip.outerRect, metal));
    }
    labSphere(canvas, Offset.zero, 4.5, const Color(0xFF6B7280), highlight: 0.5);
    canvas.restore();
  }

  /// Dropper: glass pipe with water, black rubber bulb. Local x axis runs
  /// from the tip (-x) to the bulb (+x).
  void _dropperObj(Canvas canvas, _Obj o) {
    final lifted = o.dragging || o.moving;
    if (o.rot.abs() < 0.3) {
      labGroundShadow(canvas, o.pos + Offset(0, lifted ? 40 : 8), 110, 10, opacity: lifted ? 0.15 : 0.3);
    }
    if (_hintOn(o)) _hint(canvas, o.pos + const Offset(0, 6), 120, h: 30);
    canvas.save();
    canvas.translate(o.pos.dx, o.pos.dy);
    canvas.rotate(o.rot);
    final pipe = Path()
      ..moveTo(-54, -1.2)
      ..lineTo(-44, -2.4)
      ..lineTo(18, -5.5)
      ..lineTo(18, 5.5)
      ..lineTo(-44, 2.4)
      ..lineTo(-54, 1.2)
      ..close();
    final water = scene.dropperWater;
    if (water > 0.02) {
      canvas.save();
      canvas.clipPath(pipe);
      canvas.drawRect(
        Rect.fromLTRB(-54, -6, -54 + 70 * water, 6),
        Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.9),
      );
      canvas.restore();
    }
    canvas.drawPath(pipe, Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.22));
    canvas.drawPath(
      pipe,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF93C5FD).withValues(alpha: 0.95),
    );
    canvas.drawLine(
      const Offset(-40, -1.2),
      const Offset(14, -3.6),
      Paint()
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.6),
    );
    final bulb = Rect.fromCenter(center: const Offset(36, 0), width: 40, height: 22);
    canvas.drawOval(
      bulb,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          colors: [Color(0xFF555555), Color(0xFF222222), Color(0xFF0A0A0A)],
        ).createShader(bulb),
    );
    canvas.restore();
  }

  void _rod(Canvas canvas) {
    final s = scene;
    final home = s.rodA == _rodHomeA && s.rodB == _rodHomeB;
    if (home) {
      labGroundShadow(canvas, (s.rodA + s.rodB) / 2 + const Offset(0, 6), _rodLen + 6, 8, opacity: 0.28);
      if (s.rodActive) {
        final pulse = 0.5 + 0.5 * math.sin(t * 5);
        canvas.drawLine(
          s.rodA,
          s.rodB,
          Paint()
            ..strokeWidth = 18
            ..strokeCap = StrokeCap.round
            ..color = _Colors.zslYellow.withValues(alpha: 0.18 + 0.22 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
    canvas.drawLine(
      s.rodA,
      s.rodB,
      Paint()
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF3B82F6).withValues(alpha: 0.7),
    );
    final n = (s.rodB - s.rodA);
    final perp = Offset(-n.dy, n.dx) / n.distance;
    canvas.drawLine(
      s.rodA + perp * 1.4,
      s.rodB + perp * 1.4,
      Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  /// Litmus paper strip (PlaneGeometry 0.4 x 2.5). Lying flat it is drawn
  /// foreshortened; standing ([_Obj.up] = 1) it is upright in the solution.
  void _litmusObj(Canvas canvas, _Obj o) {
    final s = scene;
    final red = o == s.redLit;
    final lifted = o.dragging || o.moving;
    if (o.up < 0.5) {
      labGroundShadow(canvas, o.pos + Offset(-8, lifted ? 24 : 2) - const Offset(0, 28), 28, 62,
          opacity: lifted ? 0.12 : 0.2);
      if (_hintOn(o)) _hint(canvas, Offset.lerp(o.pos, _toVp(o.pos, 0.15), 0.5)!, 50, h: 74);
    }
    final color = red
        ? Color.lerp(const Color(0xFFEF4444), const Color(0xFF3B82F6), s.redToBlue)!
        : const Color(0xFF3B82F6);
    // Lying: a flat strip receding towards the vanishing point; standing:
    // an upright strip tilted by [rot]. Interpolated by [up].
    final u = o.up.clamp(0.0, 1.0);
    final far = _toVp(o.pos, 0.15) - o.pos;
    final upTop = _rot(const Offset(0, -112), o.rot);
    final upSide = _rot(const Offset(9, 0), o.rot);
    final topC = Offset.lerp(far, upTop, u)!;
    final halfTop = Offset.lerp(const Offset(7.5, 0), upSide, u)!;
    final halfBot = Offset.lerp(const Offset(9, 0), upSide, u)!;
    canvas.save();
    canvas.translate(o.pos.dx, o.pos.dy);
    final quad = Path()
      ..moveTo(-halfBot.dx, -halfBot.dy)
      ..lineTo(halfBot.dx, halfBot.dy)
      ..lineTo(topC.dx + halfTop.dx, topC.dy + halfTop.dy)
      ..lineTo(topC.dx - halfTop.dx, topC.dy - halfTop.dy)
      ..close();
    final b = quad.getBounds();
    canvas.drawPath(
      quad,
      Paint()
        ..shader = LinearGradient(colors: [labShade(color, 0.14 + 0.1 * (1 - u)), color, labShade(color, -0.12)])
            .createShader(b),
    );
    canvas.rotate(o.rot * u);
    if (o.up > 0.9 && s.stirred) {
      // Wet end dipped in the solution.
      canvas.drawRect(
        const Rect.fromLTWH(-9, -12, 18, 12),
        Paint()..color = labShade(color, -0.25).withValues(alpha: 0.8),
      );
    }
    canvas.restore();
    canvas.drawPath(
      quad.shift(o.pos),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(color, -0.4).withValues(alpha: 0.6),
    );
  }

  void _particles(Canvas canvas) {
    for (final p in scene.particles) {
      final k = (1 - p.age / p.life).clamp(0.0, 1.0);
      switch (p.kind) {
        case 0: // spark with a short trail
          canvas.drawLine(
            p.p,
            p.p - p.v * 0.025,
            Paint()
              ..strokeWidth = p.size
              ..strokeCap = StrokeCap.round
              ..color = p.color.withValues(alpha: k),
          );
        case 1: // white MgO smoke
          final r = p.size * (1 + p.age * 1.4);
          canvas.drawCircle(
            p.p,
            r,
            Paint()
              ..color = p.color.withValues(alpha: 0.32 * k)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
          );
        case 2: // falling ash powder
          canvas.drawCircle(p.p, p.size, Paint()..color = p.color.withValues(alpha: 0.95));
        case 3: // water drop
          final path = Path()
            ..moveTo(p.p.dx, p.p.dy - p.size * 1.8)
            ..quadraticBezierTo(p.p.dx + p.size, p.p.dy, p.p.dx, p.p.dy + p.size)
            ..quadraticBezierTo(p.p.dx - p.size, p.p.dy, p.p.dx, p.p.dy - p.size * 1.8);
          canvas.drawPath(path, Paint()..color = p.color.withValues(alpha: 0.85));
          canvas.drawCircle(p.p + Offset(-p.size * 0.3, 0), p.size * 0.28, Paint()..color = Colors.white70);
      }
    }
  }

  /// Dazzling white magnesium flare at the free end of the ribbon
  /// (PointLight 0xffffff intensity 15 + additive white sphere).
  void _flare(Canvas canvas, Size size) {
    final s = scene;
    if (s.flare <= 0.01 || !s.ribbonVisible) return;
    final e = s.ribbonB;
    final f = s.flare * (0.85 + 0.15 * math.sin(t * 41) * math.sin(t * 17));
    canvas.drawRect(labBleed(size), Paint()..color = Colors.white.withValues(alpha: 0.2 * f));
    labGlow(canvas, e, 330 * f, const Color(0xFFF8FAFC), intensity: 0.55 * f);
    labGlow(canvas, e, 90, Colors.white, intensity: f);
    final rays = Paint()
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.7 * f);
    for (var k = 0; k < 10; k++) {
      final a = k * math.pi / 5 + t * 1.5;
      final len = 38 + 14 * math.sin(t * 13 + k);
      canvas.drawLine(e + _dir(a) * 12, e + _dir(a) * len, rays);
    }
    canvas.drawCircle(e, 15, Paint()..color = Colors.white.withValues(alpha: f));
  }
}

// ======================================================= POPUP CONTENT

/// Text with `**bold**` segments (the HTML `<strong>` parts).
Widget _boldText(String text, TextStyle base, TextStyle bold, {TextAlign align = TextAlign.start}) {
  final parts = text.split('**');
  return Text.rich(
    TextSpan(children: [
      for (var i = 0; i < parts.length; i++)
        if (parts[i].isNotEmpty) TextSpan(text: parts[i], style: i.isOdd ? bold : null),
    ]),
    style: base,
    textAlign: align,
  );
}

extension _A2Popups on _Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPageState {
  /// HTML `#tube-result-popup` content for tube [i] (A, B, C).
  Widget _tubeSummary(int i) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final dark = _lab.isDark;
    final hasAir = i != 1;
    final hasWater = i != 0;
    const light = [Color(0xFF16A34A), Color(0xFF2563EB), Color(0xFFEA580C)];
    const darkC = [Color(0xFF22C55E), Color(0xFF3B82F6), Color(0xFFF97316)];
    final res = dark ? darkC[i] : light[i];

    Widget cond(IconData icon, String label, bool present) {
      return Opacity(
        opacity: present ? 0.8 : 0.32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _Colors.blue, size: 30 * s),
            SizedBox(height: 2 * s),
            Text(
              label,
              style: TextStyle(
                color: p.textStrong,
                fontSize: 13 * s,
                fontWeight: FontWeight.w800,
                decoration: present ? null : TextDecoration.lineThrough,
                decorationThickness: 2,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cond(Icons.air, _t('lbl_air'), hasAir),
            SizedBox(width: 24 * s),
            cond(Icons.water_drop, _t('lbl_water'), hasWater),
          ],
        ),
        SizedBox(height: 12 * s),
        Text(
          _t('tubeRes_${_tubeLetters[i]}'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: res,
            fontSize: 17 * s,
            fontWeight: FontWeight.w800,
            shadows: i == 2 ? const [Shadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 2))] : null,
          ),
        ),
      ],
    );
  }

  /// HTML `s1_obs`: analysis, the three tubes and the conclusion box.
  Widget _s1Observation(BuildContext context) {
    final p = _Theme.of(_lab.isDark);
    final dark = _lab.isDark;
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final base = TextStyle(color: p.text, fontSize: 13 * f, height: 1.5, fontWeight: FontWeight.w500);
    final bold = TextStyle(color: p.textStrong, fontWeight: FontWeight.w800);

    Widget row(String letter, Color badge, String text, String result, Color resColor) {
      return Padding(
        padding: EdgeInsets.only(top: 10 * s),
        child: Row(
          children: [
            Container(
              width: 30 * s,
              height: 30 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badge,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 5, offset: Offset(0, 2))],
              ),
              child: Text(
                letter,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14 * s),
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$text '),
                  TextSpan(
                    text: result,
                    style: TextStyle(color: resColor, fontWeight: FontWeight.w800),
                  ),
                ]),
                style: base.copyWith(color: dark ? _Colors.slate200 : _Colors.slate700),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _boldText('**${_t('obs_analysis_lbl')}:** ${_t('obs_analysis')}', base, bold),
        SizedBox(height: 4 * s),
        row('A', _Colors.green, _t('obs_a'), _t('obs_a_res'),
            dark ? const Color(0xFF4ADE80) : _Colors.green600),
        row('B', _Colors.blue, _t('obs_b'), _t('obs_b_res'),
            dark ? const Color(0xFF60A5FA) : _Colors.blue600),
        row('C', _Colors.orange, _t('obs_c'), _t('obs_c_res'),
            dark ? const Color(0xFFFB923C) : const Color(0xFFEA580C)),
        SizedBox(height: 14 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: dark ? const Color(0x4D14532D) : const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _Colors.green.withValues(alpha: 0.3)),
          ),
          child: Text(
            _t('obs_concl'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? const Color(0xFF4ADE80) : const Color(0xFF166534),
              fontWeight: FontWeight.w800,
              fontSize: 13 * f,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

/// HTML `finishScenario2()` popup: the two reactions fade in one after the
/// other (0.5 s, 1.5 s), then the result card with a red litmus strip that
/// turns blue from the bottom up (2.5 s, 1 s fill).
class _MgConclusion extends StatefulWidget {
  const _MgConclusion({required this.lab});

  final LabController lab;

  @override
  State<_MgConclusion> createState() => _MgConclusionState();
}

class _MgConclusionState extends State<_MgConclusion> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  );

  @override
  void initState() {
    super.initState();
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lab = widget.lab;
    final dark = lab.isDark;
    final p = _Theme.of(dark);
    final s = context.labScale;
    final f = s * lab.fontScale.clamp(0.9, 1.3);
    String t(String k) => lab.tr(_i18n, k);
    final strong = dark ? Colors.white : _Colors.slate800;
    final blueText = dark ? const Color(0xFF60A5FA) : _Colors.blue600;

    Widget chem(IconData icon, Color color, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 34 * f),
          SizedBox(height: 2 * s),
          _formula(label, TextStyle(color: p.textStrong, fontSize: 13 * f, fontWeight: FontWeight.w800)),
        ],
      );
    }

    Widget op(String text) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          child: Text(
            text,
            style: TextStyle(color: _Colors.slate400, fontWeight: FontWeight.w800, fontSize: 20 * f),
          ),
        );

    Widget arrow({bool fire = false}) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fire) Icon(Icons.local_fire_department, color: _Colors.zslYellow, size: 26 * f),
              Icon(Icons.arrow_forward, color: fire ? _Colors.zslYellow : _Colors.slate400, size: 22 * f),
            ],
          ),
        );

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final sec = _anim.value * 3.5;
        double fade(double start) => ((sec - start) / 0.5).clamp(0.0, 1.0);
        final fill = Curves.easeInOut.transform(((sec - 2.5) / 1.0).clamp(0.0, 1.0));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Opacity(
              opacity: fade(0.5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chem(Icons.hexagon, dark ? _Colors.slate300 : _Colors.slate500, 'Mg'),
                    op('+'),
                    chem(Icons.air, dark ? const Color(0xFF60A5FA) : _Colors.blue, 'O2'),
                    arrow(fire: true),
                    chem(Icons.grain, strong, 'MgO'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16 * s),
            Opacity(
              opacity: fade(1.5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chem(Icons.grain, strong, 'MgO'),
                    op('+'),
                    chem(Icons.water_drop, _Colors.blue, 'H2O'),
                    arrow(),
                    chem(Icons.science, dark ? const Color(0xFF67E8F9) : const Color(0xFF0891B2), 'Mg(OH)2'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18 * s),
            Opacity(
              opacity: fade(2.5),
              child: Container(
                padding: EdgeInsets.all(14 * s),
                decoration: BoxDecoration(
                  color: dark ? const Color(0x801E3A8A) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dark ? _Colors.blue : const Color(0xFF93C5FD)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28 * s,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: _Colors.red,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: _Colors.slate300),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.5 + 0.5 * fill,
                        widthFactor: 1,
                        child: const ColoredBox(color: _Colors.blue),
                      ),
                    ),
                    SizedBox(width: 18 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final key in const ['concl_s2_line1', 'concl_s2_line2'])
                            _boldText(
                              t(key),
                              TextStyle(color: p.text, fontSize: 13.5 * f, height: 1.5, fontWeight: FontWeight.w600),
                              TextStyle(
                                color: blueText,
                                fontWeight: FontWeight.w900,
                                fontSize: 16 * f,
                                letterSpacing: key.endsWith('2') ? 1.6 : 0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Chemical formula with real subscripts: a digit that follows a letter or
/// a closing bracket is drawn smaller and lowered (Mg(OH)2, H2O, O2). Does
/// not rely on the font having the Unicode subscript glyphs.
Widget _formula(String f, TextStyle style) {
  final size = style.fontSize ?? 14;
  final spans = <InlineSpan>[];
  for (var i = 0; i < f.length; i++) {
    final ch = f[i];
    final isSub = RegExp(r'[0-9]').hasMatch(ch) && i > 0 && RegExp(r'[A-Za-z)]').hasMatch(f[i - 1]);
    if (isSub) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Transform.translate(
          offset: Offset(0, size * 0.28),
          child: Text(ch, style: style.copyWith(fontSize: size * 0.7)),
        ),
      ));
    } else {
      spans.add(TextSpan(text: ch));
    }
  }
  return Text.rich(TextSpan(children: spans), style: style);
}

extension _A2Cards on _Ch4A2ChemicalReactionsOfMetalsWithAirAndWaterPageState {
  /// HTML `#tube-result-popup`: a small card on the right of the canvas so
  /// the three tubes stay visible and clickable while it is open.
  Widget _tubeCardOverlay(int i, double s, EdgeInsets inset) {
    final p = _Theme.of(_lab.isDark);
    final dark = _lab.isDark;
    return Positioned(
      top: inset.top + 44 * s,
      right: inset.right + 4,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('tube-card-$i'),
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (context, v, child) => Transform.scale(scale: v, alignment: Alignment.topRight, child: child),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 230 * s, minWidth: 180 * s),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: dark ? _Colors.slate900 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dark ? _Colors.slate700 : _Colors.slate200),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10 * s, 6 * s, 4 * s, 6 * s),
                    decoration: BoxDecoration(
                      color: dark ? _Colors.slate800 : _Colors.slate50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      border: Border(bottom: BorderSide(color: dark ? _Colors.slate700 : _Colors.slate200)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.science, size: 18 * s, color: _Colors.zslYellow),
                        SizedBox(width: 6 * s),
                        Expanded(
                          child: Text(
                            '${_t('tube_title')} ${_tubeLetters[i]}',
                            style: TextStyle(
                              color: dark ? _Colors.zslYellow : const Color(0xFFCA8A04),
                              fontWeight: FontWeight.w800,
                              fontSize: 13 * s,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _closeTubeCard,
                          child: Padding(
                            padding: EdgeInsets.all(4 * s),
                            child: Icon(Icons.close, size: 18 * s, color: p.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 12 * s),
                    child: _tubeSummary(i),
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
