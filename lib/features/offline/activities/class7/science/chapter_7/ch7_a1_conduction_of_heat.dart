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

/// Class 7 Science • Chapter 7 • Activity 1
/// Conduction of Heat.
///
/// Native Flutter port of `Cl7S-Ch7-A1-Conduction_of_Heat.html`.
///
/// Scenario 1 (Conduction in a Metal Strip): drag the metal strip onto the
/// stand clamp, four wax blobs onto the strip, a pin into each blob and the
/// lit candle under the free end, then "Fast Forward": the heat-map spreads
/// along the strip and the pins drop one by one, nearest the flame first.
///
/// Scenario 2 (Conductors vs. Insulators): test the metal, wooden and glass
/// strips with pre-waxed pins and the candle ("Start Heating"). Metal drops
/// every pin; wood and glass trap the heat. A result popup follows each test
/// and "Reset Stand" clears the stand for the next material.
class Ch7A1ConductionOfHeatPage extends StatefulWidget {
  const Ch7A1ConductionOfHeatPage({super.key});

  @override
  State<Ch7A1ConductionOfHeatPage> createState() => _Ch7A1ConductionOfHeatPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356.
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
  pickup('pickup.mp3');

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
  static const Color cyan = Color(0xFF06B6D4);
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

/// Where the candle sits under the free end of the strip.
const _V _candleSpot = _V(-4.0, 0.0, 0);

/// Pan recognizer that only claims pointers that start on a draggable item
/// (decided by [canGrab]), so other drags still pan the zoomed canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _Ch7A1ConductionOfHeatPageState extends State<Ch7A1ConductionOfHeatPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _HeatScene _scene = _HeatScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();

  late final Ticker _ticker;

  /// HTML `#btn-action-main` ("Fast Forward" / "Start Heating") is visible.
  bool _showHeatButton = false;

  /// S2: a test finished and the stand has not been cleared yet.
  bool _resultPending = false;

  /// Item under the finger at pointer-down (validated, not yet dragging).
  _Item? _grab;
  double _dragPlaneY = 1;
  Offset? _lastDrag;

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
    _scene.reset();
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

  // ------------------------------------------------------------ animation

  /// HTML `animate()` + TWEEN.update(): camera, snap-back and candle tweens,
  /// falling pins and the 7 s heat tween.
  void _onTick(Duration elapsed) {
    final s = _scene..time = elapsed.inMicroseconds / 1e6;

    if (s.camStart >= 0) {
      final t = ((s.time - s.camStart) / s.camDur).clamp(0.0, 1.0);
      final k = s.camCurve.transform(t);
      s.eye = _V.lerp(s.eyeFrom, s.eyeTo, k);
      s.target = _V.lerp(s.tgtFrom, s.tgtTo, k);
      if (t >= 1) s.camStart = -1;
    }

    for (final it in s.items) {
      if (it.backStart >= 0 && it.backFrom != null) {
        // Failed drop: back to origPos (300 ms, Quadratic.Out).
        final t = ((s.time - it.backStart) / 0.3).clamp(0.0, 1.0);
        it.pos = _V.lerp(it.backFrom!, it.home, Curves.easeOutQuad.transform(t));
        if (t >= 1) it.backStart = -1;
      }
      if (it.moveStart >= 0 && it.moveFrom != null) {
        // Candle glides under the free end (500 ms, Quadratic.Out).
        final t = ((s.time - it.moveStart) / 0.5).clamp(0.0, 1.0);
        it.pos = _V.lerp(it.moveFrom!, _candleSpot, Curves.easeOutQuad.transform(t));
        if (t >= 1) {
          it.moveStart = -1;
          _onCandlePlaced(it);
        }
      }
    }

    // Falling pins: y 3.0 -> 0.02 (500 ms, Bounce.Out).
    for (final p in s.pins) {
      if (!p.fallen) continue;
      final t = ((s.time - p.fallStart) / 0.5).clamp(0.0, 1.0);
      p.pos = _V(p.pos.x, 3.0 + (0.02 - 3.0) * Curves.bounceOut.transform(t), p.pos.z);
    }

    if (s.isHeating) {
      // HTML: TWEEN State.heatValue 0 -> 1 over 7000 ms (linear).
      s.heat = ((s.time - s.heatStart) / 7.0).clamp(0.0, 1.0);
      _checkPinsDropping();
      if (s.heat >= 1) {
        s.isHeating = false;
        _onHeatingDone();
      }
    }

    _frame.value = s.time;
  }

  /// HTML `checkPinsDropping()`: a pin falls once the conducted heat passes
  /// its distance from the flame ((x + 4) / 9 along the strip).
  void _checkPinsDropping() {
    final s = _scene;
    final effective = s.heat * s.conductivity;
    for (final p in s.pins) {
      if (p.fallen) continue;
      final dist = (p.pos.x + 4.0) / 9.0;
      if (effective <= dist) continue;
      p
        ..fallen = true
        ..fallStart = s.time
        ..fallRotZ = (_rnd.nextDouble() - 0.5) * math.pi;
      if (s.scenario == 0) {
        if (p.waxId >= 0 && p.waxId < s.waxes.length) s.waxes[p.waxId].meltStart = s.time;
      } else {
        p.meltStart = s.time;
      }
      _Audio.play(_Sound.pop); // HTML playSound('clink')
      _lab.showToast(_t('msg_pin_fell'), sound: false);
    }
  }

  /// HTML heat tween `onComplete`: 1.5 s later S1 advances to the
  /// conclusion; S2 records the material and shows the test result.
  void _onHeatingDone() {
    final scenario = _scenario;
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!mounted || _scenario != scenario) return;
      if (scenario == 0) {
        _advanceStep();
        return;
      }
      final strip = _scene.strip;
      if (strip == null) return;
      setState(() {
        switch (strip) {
          case _Tool.woodStrip:
            _scene.woodTested = true;
          case _Tool.glassStrip:
            _scene.glassTested = true;
          default:
            _scene.metalTested = true;
        }
        _resultPending = true;
      });
      _showTestResultPopup(strip);
    });
  }

  // ---------------------------------------------------------------- logic

  /// HTML `resetApp(true)` (scenario change) / `resetApp(false)` (Reset Lab):
  /// rebuilds the bench for [scenario] at step 1 with the camera at home.
  void _loadScenario(int scenario) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene
        ..scenario = scenario
        ..step = 1
        ..reset();
      _showHeatButton = false;
      _resultPending = false;
      _grab = null;
      _lastDrag = null;
    });
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => _loadScenario(index);

  /// Header "Reset Lab": the shell restores its own state; back to S1.
  void _fullReset() => _loadScenario(0);

  /// HTML `advanceStep()`.
  void _advanceStep() {
    final n = _data.steps.length;
    if (_step >= n) return;
    setState(() => _scene.step++);
    if (_scenario == 0 && _step == 5) {
      // Camera eases back a little to frame the heating (1000 ms, linear).
      _scene.moveCamera(_camStep5, _scene.target, 1.0, Curves.linear);
    }
    if (_step == n) _showConclusion();
  }

  /// HTML `showConclusion()`: the "Scientific Conclusion" popup after 3 s.
  void _showConclusion() {
    final scenario = _scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 3000),
      title: () => _t('sci_conclusion'),
      heading: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${scenario + 1}'),
    );
  }

  String _stripName(_Tool tool) => _t(switch (tool) {
        _Tool.woodStrip => 'lbl_wood_strip',
        _Tool.glassStrip => 'lbl_glass_strip',
        _ => 'lbl_metal_strip',
      });

  _Proj get _proj => _Proj(_scene.eye, _scene.target);

  /// HTML raycast against the inventory hit boxes: every item under the
  /// point, nearest first.
  List<_Item> _pickItems(Offset design) {
    final proj = _proj;
    final hits = <(double, _Item)>[];
    for (final it in _scene.items) {
      if (!it.visible) continue;
      // The placed candle stays put (it is the heat source now).
      if (it.tool == _Tool.candle && (_scene.hasCandle || it.moveStart >= 0)) continue;
      final t = proj.hitBox(design, it.hitCenter, it.hitSize);
      if (t != null) hits.add((t, it));
    }
    hits.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final h in hits) h.$2];
  }

  /// Error key when [tool] is not what the current step asks for (HTML
  /// `onPointerDown` validation), or null when it may be picked up.
  String? _wrongItemError(_Tool tool) {
    if (_scenario == 0) {
      final wanted = switch (_step) {
        1 => _Tool.metalStrip,
        2 => _Tool.wax,
        3 => _Tool.pin,
        4 => _Tool.candle,
        _ => null,
      };
      return tool == wanted ? null : 'err_wrong_item';
    }
    if (_step == 1 || _step == 4) return tool.isStrip ? null : 'err_sel_mat_strip';
    if (_step == 2) return tool == _Tool.waxedPin ? null : 'err_place_waxed_pins';
    if (_step == 3) return tool == _Tool.candle ? null : 'err_place_candle';
    return null;
  }

  /// HTML `onPointerDown`: only the item the current step asks for can be
  /// picked up; anything else shows the step's error message. Where tray
  /// items overlap (waxed pins over the glass strip), the wanted one wins.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (_step >= 5 || s.isHeating || s.dragging != null) return false;
    final hits = _pickItems(event.localPosition);
    if (hits.isEmpty) return false;
    for (final it in hits) {
      if (_wrongItemError(it.tool) == null) {
        _grab = it;
        return true;
      }
    }
    _lab.showToast(_t(_wrongItemError(hits.first.tool)!), isError: true);
    return false;
  }

  void _dragStart(DragStartDetails d) {
    final it = _grab;
    if (it == null) return;
    _Audio.play(_Sound.pickup);
    setState(() {
      it.backStart = -1;
      _dragPlaneY = it.pos.y + 1; // HTML dragPlane: 1 unit above the item
      _scene.dragging = it;
      _lastDrag = d.localPosition;
    });
  }

  void _dragUpdate(DragUpdateDetails d) {
    final it = _scene.dragging;
    if (it == null) return;
    _lastDrag = d.localPosition;
    final p = _proj.onPlane(d.localPosition, _dragPlaneY);
    if (p != null) it.pos = p;
  }

  void _dragEnd() {
    final it = _scene.dragging;
    final at = _lastDrag;
    setState(() {
      _scene.dragging = null;
      _grab = null;
    });
    if (it == null || at == null) return;
    _drop(it, at);
  }

  void _dragCancel() {
    final it = _scene.dragging;
    _grab = null;
    if (it == null) return;
    setState(() => _scene.dragging = null);
    _snapBack(it);
  }

  void _snapBack(_Item it) {
    it
      ..backFrom = it.pos
      ..backStart = _scene.time;
  }

  /// HTML `onPointerUp`: raycast at the release point against the target
  /// boxes for the dragged tool, then run the matching `execute*` step.
  void _drop(_Item it, Offset at) {
    final s = _scene;
    final proj = _proj;
    bool hit(_V c, _V size) => proj.hitBox(at, c, size) != null;
    final tool = it.tool;
    var ok = false;

    if (tool.isStrip) {
      // Stand clamp target: 8 x 6 x 6 box at (3.5, 3, 0).
      if (s.strip == null && hit(const _V(3.5, 3.0, 0), const _V(8, 6, 6))) {
        ok = true;
        _placeStrip(it);
      }
    } else if (tool == _Tool.wax || tool == _Tool.waxedPin) {
      // Strip surface target: 10 x 4 x 4 box around the placed strip.
      if (s.strip != null && hit(const _V(0.5, 3.0, 0), const _V(10, 4, 4))) {
        ok = true;
        tool == _Tool.wax ? _placeWax(it) : _placeWaxedPin(it);
      }
    } else if (tool == _Tool.pin) {
      // Nearest wax blob target (1.5 cube around each blob).
      int? waxId;
      var bestT = double.infinity;
      for (var i = 0; i < s.waxes.length; i++) {
        final t = proj.hitBox(at, s.waxes[i].pos, const _V(1.5, 1.5, 1.5));
        if (t != null && t < bestT) {
          bestT = t;
          waxId = i;
        }
      }
      if (waxId != null) {
        if (s.pins.any((p) => p.waxId == waxId)) {
          _lab.showToast(_t('msg_pin_already_here'), isError: true);
          _snapBack(it);
          return;
        }
        ok = true;
        _placePin(it, waxId);
      }
    } else if (tool == _Tool.candle) {
      // Candle target: 6 x 6 x 6 box at (-4, 0, 0), present once a strip is up.
      if (s.strip != null && hit(_candleSpot, const _V(6, 6, 6))) {
        ok = true;
        _Audio.play(_Sound.drop);
        it
          ..moveFrom = it.pos
          ..moveStart = s.time;
      }
    }

    if (!ok) {
      _Audio.play(_Sound.wrong);
      _snapBack(it);
    }
  }

  /// HTML `executeStripPlacement()`.
  void _placeStrip(_Item it) {
    setState(() {
      it.visible = false;
      _scene
        ..strip = it.tool
        ..stripPop = _scene.time;
    });
    _lab.showToast('${_stripName(it.tool)}${_t('msg_strip_secured')}');
    if (_scenario == 0) {
      _advanceStep();
    } else if (_step == 1 || _step == 4) {
      setState(() => _scene.step = 2);
    }
  }

  /// HTML `executeWax()`: blobs at x = -3, -1, 1, 3 on the strip's side.
  void _placeWax(_Item it) {
    final s = _scene;
    setState(() {
      it.visible = false;
      s.waxes.add(_Placed(_V(-3.0 + s.waxes.length * 2.0, 3.0, 0.15), s.time));
    });
    final n = s.waxes.length;
    if (n == 4) {
      _lab.showToast(_t('msg_all_wax_placed'));
      _advanceStep();
    } else {
      _lab.showToast('${_t('msg_placed_wax')}$n/4');
    }
  }

  /// HTML `executePin()`: the pin sits in the blob, half above the strip.
  void _placePin(_Item it, int waxId) {
    final s = _scene;
    setState(() {
      it.visible = false;
      s.pins.add(_Placed(_V(s.waxes[waxId].pos.x, 3.0, 0.25), s.time, waxId: waxId));
    });
    final n = s.pins.length;
    if (n == 4) {
      _lab.showToast(_t('msg_all_pins_placed'));
      _advanceStep();
    } else {
      _lab.showToast('${_t('msg_placed_pin')}$n/4');
    }
  }

  /// HTML `executeWaxedPin()` (S2): pre-waxed pins at x = -3, -1, 1, 3.
  void _placeWaxedPin(_Item it) {
    final s = _scene;
    setState(() {
      it.visible = false;
      s.pins.add(_Placed(_V(-3.0 + s.pins.length * 2.0, 3.0, 0.3), s.time));
    });
    final n = s.pins.length;
    if (n == 4) {
      _lab.showToast(_t('msg_all_pins_placed'));
      if (_step == 2) _advanceStep();
    } else {
      _lab.showToast('${_t('msg_placed_pin')}$n/4');
    }
  }

  /// HTML `executeCandle()` tween `onComplete`.
  void _onCandlePlaced(_Item candle) {
    if (!mounted) return;
    setState(() {
      _scene.hasCandle = true;
      candle.popStart = _scene.time;
      _showHeatButton = true;
    });
    _lab.showToast(_t('msg_candle_placed'));
    if (_scenario == 0 && _step == 4) _advanceStep();
  }

  /// HTML `triggerSimulation()` ("Fast Forward" / "Start Heating").
  void _triggerSimulation() {
    final s = _scene;
    if (s.isHeating || !s.hasCandle) return;
    setState(() {
      _showHeatButton = false;
      s
        ..isHeating = true
        ..heat = 0
        ..heatStart = s.time;
    });
    s.moveCamera(_camHeat, _tgtHeat, 1.5, Curves.easeInOutCubic);
  }

  /// HTML `showTestResultPopup(material)`.
  void _showTestResultPopup(_Tool material) {
    _lab.showPopup(() {
      final insulator = material != _Tool.metalStrip;
      final name = _stripName(material);
      return LabPopupContent(
        title: insulator ? '$name${_t('res_insulator')}' : _t('res_conductor'),
        heading: _t('obs_complete'),
        body: insulator ? '$name${_t('res_insulator_desc')}' : _t('res_conductor_desc'),
        icon: switch (material) {
          _Tool.woodStrip => Icons.park,
          _Tool.glassStrip => Icons.water_drop,
          _ => Icons.bolt,
        },
        actions: [
          LabAction(label: _t('reset_stand'), icon: Icons.restart_alt, onTap: _clearStand),
        ],
      );
    });
  }

  /// HTML `clearStand()`: removes the strip and pins, returns the candle
  /// and waxed pins to the tray and loops back to step 4. Once all three
  /// materials are tested the conclusion follows.
  void _clearStand() {
    final s = _scene;
    _lab.hidePopup(sound: false);
    setState(() {
      s
        ..strip = null
        ..hasCandle = false
        ..isHeating = false
        ..heat = 0
        ..step = 4;
      s.pins.clear();
      final candle = s.item(_Tool.candle);
      if (candle != null) {
        candle
          ..pos = candle.home
          ..visible = true
          ..moveStart = -1
          ..backStart = -1
          ..popStart = -10;
      }
      for (final pin in s.itemsOf(_Tool.waxedPin)) {
        pin
          ..pos = pin.home
          ..visible = true
          ..backStart = -1;
      }
      _showHeatButton = false;
      _resultPending = false;
    });
    s.moveCamera(_camHome, _tgtHome, 1.0, Curves.easeOutCubic);
    _lab.showToast(_t('msg_stand_cleared'));
    if (s.woodTested && s.metalTested && s.glassTested) {
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || _scenario != 1) return;
        setState(() => _scene.step = 5);
        _showConclusion();
      });
    }
  }

  // ------------------------------------------------------------------- UI

  /// HTML `#btn-action-main` plus "Reset Stand" (the result popup's button,
  /// kept here too so closing the popup never leaves the test stuck).
  List<LabAction> _actions() {
    return [
      if (_showHeatButton)
        LabAction(
          label: _t(_scenario == 0 ? 'fast_forward' : 'start_heating'),
          icon: _scenario == 0 ? Icons.fast_forward : Icons.local_fire_department,
          highlight: true,
          onTap: _triggerSimulation,
        ),
      if (_resultPending)
        LabAction(
          label: _t('reset_stand'),
          icon: Icons.restart_alt,
          highlight: true,
          onTap: _clearStand,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: actions,
          onReset: _fullReset,
          overlays: [
            // HTML `#btn-action-main`: big pulsing button above the HUD. While
            // the sidebar is collapsed the floating mission card carries it.
            if (actions.isNotEmpty && _lab.isSidebarOpen && _lab.popup == null)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + 66 * s,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final a in actions)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5 * s),
                            child: LabActionButton(action: a, scale: s * 1.1, expand: false),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          // HTML hides the HUD once Scenario 1 reaches its conclusion step.
          showHud: !(_scenario == 0 && _step >= data.steps.length),
          sidebarExtraTitle: _scenario == 1 ? _t('lbl_test_result') : null,
          sidebarExtra: _scenario == 1 ? _resultsPanel(p, s) : null,
          stage: LayoutBuilder(
            builder: (context, box) {
              final fit = math.min(box.maxWidth / _design.width, box.maxHeight / _design.height);
              final ui = fit <= 0 ? 1.0 : (0.85 / fit).clamp(1.0, 1.8);
              return LabStage(
                designSize: _design,
                child: MediaQuery(
                  // Short drags must pick items up (default pan slop is large).
                  data: MediaQuery.of(context).copyWith(
                    gestureSettings: const DeviceGestureSettings(touchSlop: 8),
                  ),
                  child: RawGestureDetector(
                    behavior: HitTestBehavior.opaque,
                    gestures: {
                      _GrabPanRecognizer: GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                        () => _GrabPanRecognizer(debugOwner: this),
                        (r) => r
                          ..canGrab = _canGrab
                          ..dragStartBehavior = DragStartBehavior.down
                          ..onStart = _dragStart
                          ..onUpdate = _dragUpdate
                          ..onCancel = _dragCancel
                          ..onEnd = (_) {
                            _dragEnd();
                          },
                      ),
                    },
                    child: CustomPaint(
                      size: _design,
                      painter: _BenchPainter(
                        scene: _scene,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        lang: _lab.lang,
                        uiScale: ui,
                      ),
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

  /// S2 comparison card: each material and what its test showed.
  Widget _resultsPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final sc = _scene;
    final tested = [sc.metalTested, sc.woodTested, sc.glassTested].where((b) => b).length;

    Widget row(_Tool tool, bool done) {
      final insulator = tool != _Tool.metalStrip;
      final status = !done
          ? _t('lbl_not_tested')
          : _t(insulator ? 'lbl_poor_conductor' : 'lbl_good_conductor');
      final color = !done ? p.textMuted : (insulator ? _Colors.cyan : _Colors.green);
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16 * s,
              height: 16 * s,
              margin: EdgeInsets.only(top: 1 * s),
              decoration: BoxDecoration(
                color: _stripColor[tool]!.withValues(alpha: tool == _Tool.glassStrip ? 0.7 : 1),
                borderRadius: BorderRadius.circular(4 * s),
                border: Border.all(color: p.cardBorder),
              ),
            ),
            SizedBox(width: 8 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stripName(tool),
                    style: TextStyle(color: p.textStrong, fontSize: 12 * f, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 1 * s),
                  Row(
                    children: [
                      Icon(
                        !done ? Icons.hourglass_empty : (insulator ? Icons.block : Icons.bolt),
                        size: 12 * f,
                        color: color,
                      ),
                      SizedBox(width: 3 * s),
                      Expanded(
                        child: Text(
                          status,
                          style: TextStyle(color: color, fontSize: 11 * f, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
            labFormat(_t('lbl_tested_count'), {'n': tested}),
            style: TextStyle(color: p.textMuted, fontSize: 11 * f, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4 * s),
          row(_Tool.metalStrip, sc.metalTested),
          row(_Tool.woodStrip, sc.woodTested),
          row(_Tool.glassStrip, sc.glassTested),
        ],
      ),
    );
  }
}

// ============================================================ STRINGS
//
// Copied from the HTML `i18n` / `ScenariosData` tables (Telugu dropped).
// <b> markup removed. Message fragments that the HTML concatenated
// (" Secured!", "Placed wax " + "2/4") are kept as fragments.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Conduction of Heat',
    'app_subtitle': 'Class 7 • Heat Transfer in Nature',
    'scen_1_opt': 'Scenario 1: Conduction in a Metal Strip',
    'scen_2_opt': 'Scenario 2: Conductors vs. Insulators',
    'fast_forward': 'Fast Forward',
    'start_heating': 'Start Heating',
    'reset_stand': 'Reset Stand',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Scientific Conclusion',
    'lbl_mat_strip': 'Material Strip',
    'lbl_metal_strip': 'Metal Strip',
    'lbl_wood_strip': 'Wooden Strip',
    'lbl_glass_strip': 'Glass Strip',
    'lbl_stand': 'Stand',
    'lbl_candle': 'Candle',
    'lbl_wax_blobs': 'Wax Blobs',
    'lbl_waxed_pins': 'Waxed Pins',
    'err_wrong_item': 'Select the correct item specified in the current objective.',
    'err_sel_mat_strip': 'Select a material strip (Wood, Glass, or Metal) to proceed.',
    'err_place_waxed_pins': 'Place the waxed pins now.',
    'err_place_candle': 'Place the candle to test.',
    'err_place_metal': 'Please place the Metal Strip.',
    'err_place_pins': 'Place the waxed pins.',
    'msg_strip_secured': ' Secured!',
    'msg_all_wax_placed': 'All wax blobs placed!',
    'msg_placed_wax': 'Placed wax ',
    'msg_pin_already_here': 'A pin is already here!',
    'msg_all_pins_placed': 'All pins placed!',
    'msg_placed_pin': 'Placed pin ',
    'msg_candle_placed': 'Candle placed! The strip is ready to heat.',
    'msg_pin_fell': '*Clink* Pin fell!',
    'msg_stand_cleared': 'Stand cleared. Test another material.',
    'res_insulator': ' is an Insulator',
    'res_insulator_desc':
        ' is a poor conductor of heat. The heat was trapped near the source and did not travel far enough to drop the pins.',
    'res_conductor': 'Metal is a Conductor',
    'res_conductor_desc':
        'Metal is a good conductor of heat. The heat traveled quickly along the strip, melting the wax and dropping all the pins!',
    'conclusion_1':
        'Heat traveled from the hot end to the cold end, melting the wax in sequence. This transfer of heat through a solid is called Conduction. Metals are good conductors of heat.',
    'conclusion_2':
        "Good Conductors, like metal, allow heat to pass through them easily. Poor Conductors (Insulators), like wood and glass, do not. That's why a metal spoon in hot soup gets hot, but a wooden handle protects your hand.",
    'lbl_test_result': 'Test Result',
    // Added for the native version (S2 comparison panel in the sidebar).
    'lbl_not_tested': 'Not tested yet',
    'lbl_good_conductor': 'Good Conductor',
    'lbl_poor_conductor': 'Poor Conductor (Insulator)',
    'lbl_tested_count': 'Materials tested: {n} / 3',
  },
  'hi': {
    'app_title': 'ऊष्मा का चालन',
    'app_subtitle': 'कक्षा 7 • प्रकृति में ऊष्मा स्थानांतरण',
    'scen_1_opt': 'परिदृश्य 1: धातु की पट्टी में चालन',
    'scen_2_opt': 'परिदृश्य 2: सुचालक बनाम कुचालक',
    'fast_forward': 'तेजी से आगे बढ़ाएं',
    'start_heating': 'गर्म करना शुरू करें',
    'reset_stand': 'स्टैंड रीसेट करें',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'वैज्ञानिक निष्कर्ष',
    'lbl_mat_strip': 'सामग्री की पट्टी',
    'lbl_metal_strip': 'धातु की पट्टी',
    'lbl_wood_strip': 'लकड़ी की पट्टी',
    'lbl_glass_strip': 'कांच की पट्टी',
    'lbl_stand': 'स्टैंड',
    'lbl_candle': 'मोमबत्ती',
    'lbl_wax_blobs': 'मोम की बूंदें',
    'lbl_waxed_pins': 'मोम लगी पिन',
    'err_wrong_item': 'वर्तमान उद्देश्य में निर्दिष्ट सही वस्तु का चयन करें।',
    'err_sel_mat_strip': 'आगे बढ़ने के लिए एक सामग्री पट्टी (लकड़ी, कांच, या धातु) का चयन करें।',
    'err_place_waxed_pins': 'अब मोम लगी पिन रखें।',
    'err_place_candle': 'परीक्षण करने के लिए मोमबत्ती रखें।',
    'err_place_metal': 'कृपया धातु की पट्टी रखें।',
    'err_place_pins': 'मोम लगी पिन रखें।',
    'msg_strip_secured': ' सुरक्षित हो गई!',
    'msg_all_wax_placed': 'सभी मोम की बूंदें रख दी गईं!',
    'msg_placed_wax': 'मोम रखा गया ',
    'msg_pin_already_here': 'एक पिन पहले से ही यहाँ है!',
    'msg_all_pins_placed': 'सभी पिन रख दी गईं!',
    'msg_placed_pin': 'पिन रखी गई ',
    'msg_candle_placed': 'मोमबत्ती रख दी गई! पट्टी गर्म होने के लिए तैयार है।',
    'msg_pin_fell': '*क्लिंक* पिन गिर गई!',
    'msg_stand_cleared': 'स्टैंड साफ़ हो गया। दूसरी सामग्री का परीक्षण करें।',
    'res_insulator': ' एक कुचालक है',
    'res_insulator_desc':
        ' ऊष्मा का खराब सुचालक है। ऊष्मा स्रोत के पास फंस गई थी और पिन को गिराने के लिए पर्याप्त दूर तक नहीं गई।',
    'res_conductor': 'धातु एक सुचालक है',
    'res_conductor_desc':
        'धातु ऊष्मा का अच्छा सुचालक है। ऊष्मा पट्टी के साथ तेजी से यात्रा करती है, मोम को पिघलाती है और सभी पिनों को गिरा देती है!',
    'conclusion_1':
        'ऊष्मा गर्म सिरे से ठंडे सिरे तक गई, जिससे मोम क्रम से पिघल गया। किसी ठोस पदार्थ के माध्यम से ऊष्मा के इस स्थानांतरण को चालन (Conduction) कहा जाता है। धातुएं ऊष्मा की अच्छी सुचालक होती हैं।',
    'conclusion_2':
        'अच्छे सुचालक, जैसे धातु, ऊष्मा को आसानी से अपने से गुजरने देते हैं। खराब सुचालक (कुचालक), जैसे लकड़ी और कांच, नहीं। यही कारण है कि गर्म सूप में धातु का चम्मच गर्म हो जाता है, लेकिन लकड़ी का हैंडल आपके हाथ की रक्षा करता है।',
    'lbl_test_result': 'परीक्षण परिणाम',
    'lbl_not_tested': 'अभी परीक्षण नहीं हुआ',
    'lbl_good_conductor': 'अच्छा सुचालक',
    'lbl_poor_conductor': 'खराब सुचालक (कुचालक)',
    'lbl_tested_count': 'परीक्षित सामग्री: {n} / 3',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'Scenario 1: Conduction in a Metal Strip',
      objective:
          'To observe and understand how heat is transferred along a solid metal strip through the process of conduction.',
      steps: [
        LabStep(
          concept:
              'Metals are generally good conductors. We need a solid medium to observe how heat travels from particle to particle.',
          action: 'DRAG the metal strip from the inventory and DROP it onto the clamps of the stand.',
          observation: 'The metal strip snaps vertically onto the stand, ready to act as a heat pathway.',
        ),
        LabStep(
          concept:
              'Heat energy is invisible. We need thermal indicators to show us exactly when heat reaches specific points on the metal.',
          action: 'DRAG four wax blobs from the inventory and DROP them onto the side of the metal strip.',
          observation:
              'The solid wax blobs stick to the surface and will melt when a certain temperature is reached.',
        ),
        LabStep(
          concept:
              'To make the wax melting unmistakably visible, we can attach weights. Gravity will pull them down once the wax softens.',
          action: 'DRAG four pins from the inventory and DROP one into each wax blob.',
          observation:
              'The pins are embedded vertically in the wax. Half the pin is above the strip and half hangs below.',
        ),
        LabStep(
          concept:
              'Conduction requires a temperature difference to flow. We introduce a concentrated heat source at one end.',
          action: 'DRAG the lit candle and PLACE it directly under the free end of the metal strip.',
          observation:
              'A heat-map visualization appears. The area directly above the flame begins to glow bright red.',
        ),
        LabStep(
          concept:
              'In conduction, heat transfers sequentially from the hotter region to the colder region through the solid material.',
          action: "OBSERVE the setup. CLICK the 'Fast Forward' button to speed up time.",
          observation:
              'The pins detach and fall one by one, strictly starting from the pin closest to the heat source.',
        ),
        LabStep(
          concept: 'Scientific Conclusion',
          action: 'Review the outcome of the experiment.',
          observation:
              'The sequential melting proves heat traveled linearly through the solid metal without the particles themselves moving.',
        ),
      ],
    ),
    LabScenarioData(
      title: 'Scenario 2: Conductors vs. Insulators',
      objective:
          'To compare the heat conductivity of different materials and visually distinguish between good conductors and poor conductors (insulators).',
      steps: [
        LabStep(
          concept: 'Different materials react differently to heat.',
          action: 'DRAG any material strip (Wood, Glass, or Metal) and DROP it onto the stand.',
          observation: 'The strip snaps into place.',
        ),
        LabStep(
          concept: 'Instead of separate parts, we use pre-assembled thermal indicators for efficiency.',
          action: "DRAG four 'pins with wax' from the inventory and DROP them onto the strip.",
          observation: 'The pre-waxed pins stick to the strip vertically in a single action.',
        ),
        LabStep(
          concept: "We apply heat to test the material's ability to conduct energy.",
          action: "DRAG the lit candle and PLACE it under the free end of the strip. CLICK 'Start Heating'.",
          observation: 'Observe if the heat travels along the material.',
        ),
        LabStep(
          concept: 'Compare the results across different materials.',
          action: 'Clear the stand using the popup button and test the other materials to compare.',
          observation: 'Good conductors melt the wax quickly. Insulators trap the heat.',
        ),
        LabStep(
          concept: 'Scientific Conclusion',
          action: 'Review the comparison of the experiments.',
          observation:
              'We clearly see the distinction between a material that allows heat transfer and one that blocks it.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'परिदृश्य 1: धातु की पट्टी में चालन',
      objective: 'चालन की प्रक्रिया के माध्यम से एक ठोस धातु की पट्टी के साथ ऊष्मा कैसे स्थानांतरित होती है, इसे देखना और समझना।',
      steps: [
        LabStep(
          concept:
              'धातुएं आमतौर पर अच्छी सुचालक होती हैं। हमें यह देखने के लिए एक ठोस माध्यम की आवश्यकता है कि ऊष्मा एक कण से दूसरे कण में कैसे यात्रा करती है।',
          action: 'इन्वेंट्री से धातु की पट्टी को खींचें और इसे स्टैंड के क्लैंप पर छोड़ दें।',
          observation: 'धातु की पट्टी स्टैंड पर लंबवत रूप से जुड़ जाती है, जो ऊष्मा मार्ग के रूप में कार्य करने के लिए तैयार है।',
        ),
        LabStep(
          concept:
              'ऊष्मीय ऊर्जा अदृश्य है। हमें यह दिखाने के लिए थर्मल संकेतक की आवश्यकता है कि धातु पर विशिष्ट बिंदुओं तक ऊष्मा कब पहुंचती है।',
          action: 'इन्वेंट्री से मोम की चार बूंदों को खींचें और उन्हें धातु की पट्टी के किनारे पर छोड़ दें।',
          observation: 'ठोस मोम की बूंदें सतह पर चिपक जाती हैं और एक निश्चित तापमान तक पहुंचने पर पिघल जाएंगी।',
        ),
        LabStep(
          concept:
              'मोम के पिघलने को स्पष्ट रूप से दृश्यमान बनाने के लिए, हम वजन संलग्न कर सकते हैं। एक बार मोम नरम हो जाने पर गुरुत्वाकर्षण उन्हें नीचे खींच लेगा।',
          action: 'इन्वेंट्री से चार पिन खींचें और प्रत्येक मोम की बूंद में एक को छोड़ दें।',
          observation: 'पिनें मोम में लंबवत रूप से अंतःस्थापित हैं। आधी पिन पट्टी के ऊपर है और आधी नीचे लटकती है।',
        ),
        LabStep(
          concept: 'चालन को प्रवाहित होने के लिए तापमान के अंतर की आवश्यकता होती है। हम एक सिरे पर एक केंद्रित ऊष्मा स्रोत पेश करते हैं।',
          action: 'जलती हुई मोमबत्ती को खींचें और इसे धातु की पट्टी के मुक्त सिरे के ठीक नीचे रखें।',
          observation: 'एक हीट-मैप विज़ुअलाइज़ेशन दिखाई देता है। लौ के ठीक ऊपर का क्षेत्र चमकीला लाल चमकने लगता है।',
        ),
        LabStep(
          concept: 'चालन में, ऊष्मा ठोस सामग्री के माध्यम से गर्म क्षेत्र से ठंडे क्षेत्र में क्रमिक रूप से स्थानांतरित होती है।',
          action: "सेटअप का निरीक्षण करें। समय को तेज करने के लिए 'तेजी से आगे बढ़ाएं' बटन पर क्लिक करें।",
          observation: 'पिनें एक-एक करके अलग होती हैं और गिरती हैं, जो ऊष्मा स्रोत के सबसे करीब वाले पिन से शुरू होती हैं।',
        ),
        LabStep(
          concept: 'वैज्ञानिक निष्कर्ष',
          action: 'प्रयोग के परिणाम की समीक्षा करें।',
          observation: 'क्रमिक पिघलना यह साबित करता है कि ऊष्मा बिना कणों के स्वयं चले ठोस धातु के माध्यम से रैखिक रूप से यात्रा करती है।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'परिदृश्य 2: सुचालक बनाम कुचालक',
      objective:
          'विभिन्न सामग्रियों की ऊष्मा चालकता की तुलना करना और अच्छे सुचालक और खराब सुचालक (कुचालक) के बीच नेत्रहीन रूप से अंतर करना।',
      steps: [
        LabStep(
          concept: 'विभिन्न सामग्रियां ऊष्मा पर अलग-अलग प्रतिक्रिया करती हैं।',
          action: 'कोई भी सामग्री पट्टी (लकड़ी, कांच, या धातु) खींचें और इसे स्टैंड पर छोड़ दें।',
          observation: 'पट्टी अपनी जगह पर जुड़ जाती है।',
        ),
        LabStep(
          concept: 'अलग-अलग हिस्सों के बजाय, हम दक्षता के लिए पूर्व-संयोजित थर्मल संकेतक का उपयोग करते हैं।',
          action: "इन्वेंट्री से चार 'मोम लगी पिन' खींचें और उन्हें पट्टी पर छोड़ दें।",
          observation: 'पूर्व-मोम वाली पिन एक ही क्रिया में पट्टी से लंबवत रूप से चिपक जाती हैं।',
        ),
        LabStep(
          concept: 'हम सामग्री की ऊष्मा का संचालन करने की क्षमता का परीक्षण करने के लिए ऊष्मा लागू करते हैं।',
          action: "जलती हुई मोमबत्ती को खींचें और इसे पट्टी के मुक्त सिरे के नीचे रखें। 'गर्म करना शुरू करें' पर क्लिक करें।",
          observation: 'देखें कि क्या ऊष्मा सामग्री के साथ यात्रा करती है।',
        ),
        LabStep(
          concept: 'विभिन्न सामग्रियों में परिणामों की तुलना करें।',
          action: 'पॉपअप बटन का उपयोग करके स्टैंड को साफ़ करें और तुलना करने के लिए अन्य सामग्रियों का परीक्षण करें।',
          observation: 'अच्छे सुचालक मोम को जल्दी पिघला देते हैं। कुचालक ऊष्मा को फंसाते हैं।',
        ),
        LabStep(
          concept: 'वैज्ञानिक निष्कर्ष',
          action: 'प्रयोगों की तुलना की समीक्षा करें।',
          observation: 'हम उस सामग्री के बीच का अंतर स्पष्ट रूप से देखते हैं जो ऊष्मा हस्तांतरण की अनुमति देता है और जो इसे रोकता है।',
        ),
      ],
    ),
  ],
};

// ============================================================ 3D MATH

const Size _design = Size(1000, 560);

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);
  final double x, y, z;

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Euler XYZ rotation (Three.js default order) of [v] by [rx] and [rz].
_V _rotXZ(_V v, double rx, double rz) {
  final cz = math.cos(rz), sz = math.sin(rz);
  final a = _V(v.x * cz - v.y * sz, v.x * sz + v.y * cz, v.z);
  final cx = math.cos(rx), sx = math.sin(rx);
  return _V(a.x, a.y * cx - a.z * sx, a.y * sx + a.z * cx);
}

// HTML camera: PerspectiveCamera(fov 40) at (-2,12,18) looking at (0,2,0).
const _V _camHome = _V(-2, 12, 18);
const _V _tgtHome = _V(0, 2, 0);
const _V _camHeat = _V(0, 8, 15); // triggerSimulation()
const _V _tgtHeat = _V(0, 2.5, 0);
const _V _camStep5 = _V(0, 10, 18); // S1 advanceStep() to step 5
const _V _light = _V(0.2673, 0.8018, 0.5345); // dirLight (5,15,10)

/// Pinhole projection for the current camera. The look-at point is drawn a
/// little above the stage centre so the bench sits clear of the bottom HUD.
class _Proj {
  _Proj(this.eye, _V target) {
    f = (target - eye).unit;
    r = f.cross(const _V(0, 1, 0)).unit;
    u = r.cross(f);
  }

  static const double focal = 800; // ≈ 40° vertical fov over the 560 px stage
  static const Offset center = Offset(500, 178);

  final _V eye;
  late final _V f, r, u;

  double depth(_V w) => (w - eye).dot(f);

  /// Pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal)).unit;

  /// Where that ray crosses the horizontal plane y = [py] (drag plane).
  _V? onPlane(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Ray / axis-aligned box intersection distance (slab method), or null.
  double? hitBox(Offset s, _V c, _V size) {
    final d = ray(s);
    var tMin = 0.0, tMax = double.infinity;
    for (var i = 0; i < 3; i++) {
      final o = [eye.x, eye.y, eye.z][i];
      final dir = [d.x, d.y, d.z][i];
      final lo = [c.x - size.x / 2, c.y - size.y / 2, c.z - size.z / 2][i];
      final hi = [c.x + size.x / 2, c.y + size.y / 2, c.z + size.z / 2][i];
      if (dir.abs() < 1e-9) {
        if (o < lo || o > hi) return null;
        continue;
      }
      var t1 = (lo - o) / dir, t2 = (hi - o) / dir;
      if (t1 > t2) {
        final tmp = t1;
        t1 = t2;
        t2 = tmp;
      }
      tMin = math.max(tMin, t1);
      tMax = math.min(tMax, t2);
      if (tMin > tMax) return null;
    }
    return tMin;
  }
}

// ============================================================ SCENE MODEL

/// HTML inventory tool names.
enum _Tool { metalStrip, woodStrip, glassStrip, wax, pin, waxedPin, candle }

extension on _Tool {
  bool get isStrip => index <= 2;
}

const Map<_Tool, Color> _stripColor = {
  _Tool.metalStrip: Color(0xFFA0AAB5),
  _Tool.woodStrip: Color(0xFF8B5A2B),
  _Tool.glassStrip: Color(0xFFADD8E6),
};

/// An inventory object on the tray (HTML `inventoryItems`).
class _Item {
  _Item(this.tool, this.home) : pos = home;
  final _Tool tool;
  final _V home; // userData.origPos
  _V pos;
  bool visible = true;

  // Snap-back tween after a failed drop (300 ms, Quadratic.Out).
  _V? backFrom;
  double backStart = -1;

  // Candle placement tween to (-4, 0, 0) (500 ms, Quadratic.Out).
  _V? moveFrom;
  double moveStart = -1;
  double popStart = -10;

  /// Hit box size (HTML invisible hitBox meshes).
  _V get hitSize => switch (tool) {
        _Tool.metalStrip || _Tool.woodStrip || _Tool.glassStrip => const _V(9.5, 1.0, 1.5),
        _Tool.wax => const _V(1, 1, 1),
        _Tool.pin => const _V(1.0, 1.6, 1.0),
        _Tool.waxedPin => const _V(1.2, 1.8, 1.2),
        _Tool.candle => const _V(2.4, 2.5, 2.4),
      };

  _V get hitCenter => tool == _Tool.candle ? pos + const _V(0, 1.0, 0) : pos;
}

/// A wax blob / pin / waxed pin placed on the strip.
class _Placed {
  _Placed(this.pos, this.popStart, {this.waxId = -1});
  _V pos;
  final double popStart;
  final int waxId;
  bool fallen = false;
  double fallStart = -1;
  double fallRotZ = 0;
  double meltStart = -1;
}

/// Mutable state read by the painter every frame.
class _HeatScene {
  double time = 0;
  int scenario = 0;
  int step = 1;

  // Camera (position + controls.target) and its tween.
  _V eye = _camHome, target = _tgtHome;
  _V eyeFrom = _camHome, eyeTo = _camHome, tgtFrom = _tgtHome, tgtTo = _tgtHome;
  double camStart = -1, camDur = 1;
  Curve camCurve = Curves.linear;

  final List<_Item> items = [];
  _Tool? strip; // placed strip type (activeStripType)
  double stripPop = -10;
  final List<_Placed> waxes = []; // S1 wax blobs on the strip
  final List<_Placed> pins = []; // S1 pins / S2 waxed pins on the strip
  bool hasCandle = false;
  bool isHeating = false;
  double heat = 0; // State.heatValue
  double heatStart = -1;

  _Item? dragging;
  bool woodTested = false, metalTested = false, glassTested = false;

  double get conductivity => strip == _Tool.woodStrip || strip == _Tool.glassStrip ? 0.08 : 1.0;

  _Item? item(_Tool t) {
    for (final i in items) {
      if (i.tool == t) return i;
    }
    return null;
  }

  Iterable<_Item> itemsOf(_Tool t) => items.where((i) => i.tool == t);

  void moveCamera(_V eyeTarget, _V tgtTarget, double dur, Curve curve) {
    eyeFrom = eye;
    tgtFrom = target;
    eyeTo = eyeTarget;
    tgtTo = tgtTarget;
    camStart = time;
    camDur = dur;
    camCurve = curve;
  }

  /// HTML `buildInventory()` for the current scenario.
  void buildInventory() {
    items.clear();
    if (scenario == 0) {
      items.add(_Item(_Tool.metalStrip, const _V(-4, 0.075, 1.5)));
      for (var i = 0; i < 4; i++) {
        items.add(_Item(_Tool.wax, _V(-6.2 + i * 1.2, 0.45, 3.5)));
      }
      for (var i = 0; i < 4; i++) {
        items.add(_Item(_Tool.pin, _V(-6.2 + i * 1.2, 0.4, 5.5)));
      }
      items.add(_Item(_Tool.candle, const _V(-1.0, 0, 5.5)));
    } else {
      items
        ..add(_Item(_Tool.metalStrip, const _V(-4, 0.075, 1.5)))
        ..add(_Item(_Tool.woodStrip, const _V(-4, 0.075, 3.5)))
        ..add(_Item(_Tool.glassStrip, const _V(-4, 0.075, 5.5)));
      for (var i = 0; i < 4; i++) {
        items.add(_Item(_Tool.waxedPin, _V(-6.2 + i * 1.2, 0.4, 6.5)));
      }
      items.add(_Item(_Tool.candle, const _V(-1.0, 0, 7.0)));
    }
  }

  /// HTML `resetApp(true)` scene part.
  void reset() {
    eye = eyeFrom = eyeTo = _camHome;
    target = tgtFrom = tgtTo = _tgtHome;
    camStart = -1;
    strip = null;
    stripPop = -10;
    waxes.clear();
    pins.clear();
    hasCandle = false;
    isHeating = false;
    heat = 0;
    heatStart = -1;
    dragging = null;
    woodTested = metalTested = glassTested = false;
    buildInventory();
  }
}

/// HTML `applyPopEffect`: 0.01 -> 1.3 (200 ms, Back.Out) -> 1 (150 ms).
double _pop(double now, double start) {
  final e = now - start;
  if (e < 0) return 0.01;
  if (e < 0.2) return 0.01 + (1.3 - 0.01) * Curves.easeOutBack.transform(e / 0.2);
  if (e < 0.35) return 1.3 - 0.3 * ((e - 0.2) / 0.15);
  return 1;
}

/// The strip heat shader (`createHeatShaderMaterial`) colour at local x.
Color _heatColor(Color base, double litK, double localX, double heat, double conductivity) {
  final d = (localX + 4.0) / 9.0;
  final e = heat * conductivity;
  final tt = ((e + 0.15 - d) / 0.3).clamp(0.0, 1.0);
  final spread = tt * tt * (3 - 2 * tt);
  final intensity = (1 - d) * spread;
  // GLSL mix() extrapolates when t > 1; the result is clamped on output.
  double mix(double a, double b, double t) => a + (b - a) * t;
  final m = intensity * 1.5;
  var hr = mix(0.8, 1.0, m), hg = mix(0.1, 0.4, m), hb = mix(0.1, 0.0, m);
  final hotT = intensity > 0.7 ? (intensity - 0.7) * 3.3 : 0.0;
  hr = mix(hr, 1.0, hotT);
  hg = mix(hg, 0.9, hotT);
  hb = mix(hb, 0.2, hotT);
  final k = spread * 0.85;
  return Color.from(
    alpha: 1,
    red: mix(base.r * litK, hr, k).clamp(0.0, 1.0),
    green: mix(base.g * litK, hg, k).clamp(0.0, 1.0),
    blue: mix(base.b * litK, hb, k).clamp(0.0, 1.0),
  );
}

// ============================================================ PRIMITIVES

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) => (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [...lower.sublist(0, lower.length - 1), ...upper.sublist(0, upper.length - 1)];
}

/// Flat-shaded mesh drawing in the current projection (MeshStandardMaterial
/// look: ambient 0.7 + directional 0.8 from (5,15,10), toned down).
class _Draw {
  _Draw(this.canvas, this.proj);
  final Canvas canvas;
  final _Proj proj;

  static Color lit(Color c, _V n, {double opacity = 1, double amb = 0.6, double dif = 0.55}) {
    final i = amb + dif * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: (c.a * opacity).clamp(0.0, 1.0),
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  bool faces(_V n, _V point) => n.dot(proj.eye - point) > 0;

  Path poly(List<_V> pts) => Path()..addPolygon(pts.map(proj.p).toList(), true);

  /// Box centred at [c]; [paintFace] can override a face (normal, corners).
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    bool Function(_V n, List<_V> corners)? paintFace,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    _V v(double x, double y, double z) => _V(c.x + x * hx, c.y + y * hy, c.z + z * hz);
    final faceList = <(_V, List<_V>)>[
      (const _V(1, 0, 0), [v(1, -1, -1), v(1, 1, -1), v(1, 1, 1), v(1, -1, 1)]),
      (const _V(-1, 0, 0), [v(-1, -1, -1), v(-1, -1, 1), v(-1, 1, 1), v(-1, 1, -1)]),
      (const _V(0, 1, 0), [v(-1, 1, -1), v(-1, 1, 1), v(1, 1, 1), v(1, 1, -1)]),
      (const _V(0, -1, 0), [v(-1, -1, -1), v(1, -1, -1), v(1, -1, 1), v(-1, -1, 1)]),
      (const _V(0, 0, 1), [v(-1, -1, 1), v(1, -1, 1), v(1, 1, 1), v(-1, 1, 1)]),
      (const _V(0, 0, -1), [v(-1, -1, -1), v(-1, 1, -1), v(1, 1, -1), v(1, -1, -1)]),
    ];
    for (final f in faceList) {
      final center = c + f.$1 * (f.$1.x != 0 ? hx : (f.$1.y != 0 ? hy : hz));
      if (!faces(f.$1, center)) continue;
      if (paintFace != null && paintFace(f.$1, f.$2)) continue;
      final path = poly(f.$2);
      canvas.drawPath(path, Paint()..color = lit(color, f.$1, opacity: opacity));
      if (edge > 0) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..strokeJoin = StrokeJoin.round
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// Cylinder from [base] along unit [axis] (CylinderGeometry look).
  void cylinder(_V base, _V axis, double radius, double length, Color color,
      {Color? cap, double opacity = 1, double sheen = 0.3}) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : const _V(0, 1, 0);
    final a1 = axis.cross(helper).unit, a2 = axis.cross(a1).unit;
    final top = base + axis * length;
    List<_V> ring(_V c) => [
          for (var i = 0; i < 24; i++)
            c + (a1 * math.cos(i * math.pi / 12) + a2 * math.sin(i * math.pi / 12)) * radius,
        ];
    final rb = ring(base), rt = ring(top);
    final hull = _hull([...rb.map(proj.p), ...rt.map(proj.p)]);
    if (hull.length < 3) return;
    final mid = base + axis * (length / 2);
    final pm = proj.p(mid), pa = proj.p(top) - proj.p(base);
    final len = pa.distance;
    final perp = len < 0.001 ? const Offset(1, 0) : Offset(-pa.dy / len, pa.dx / len);
    final rr = radius * proj.scaleAt(mid) * 1.1;
    Color c(double k) => labShade(color, k).withValues(alpha: color.a * opacity);
    canvas.drawPath(
      Path()..addPolygon(hull, true),
      Paint()
        ..shader = ui.Gradient.linear(pm - perp * rr, pm + perp * rr, [
          c(-0.45),
          c(sheen),
          c(0),
          c(-0.5),
        ], const [0, 0.35, 0.62, 1]),
    );
    final capTop = faces(axis, top);
    final capRing = capTop ? rt : (faces(axis * -1, base) ? rb : null);
    if (capRing != null) {
      canvas.drawPath(
        poly(capRing),
        Paint()..color = (cap ?? labShade(color, 0.2)).withValues(alpha: (cap ?? color).a * opacity),
      );
    }
  }

  /// Ellipsoid blob (wax: SphereGeometry(0.25) flattened along Z).
  void blob(_V c, double rx, double ry, Color color, {double opacity = 1}) {
    final k = proj.scaleAt(c);
    final o = proj.p(c);
    final rect = Rect.fromCenter(center: o, width: math.max(1, 2 * rx * k), height: math.max(1, 2 * ry * k));
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.45),
          colors: [
            labShade(color, 0.45).withValues(alpha: opacity),
            color.withValues(alpha: opacity),
            labShade(color, -0.3).withValues(alpha: opacity),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = labShade(color, -0.45).withValues(alpha: 0.6 * opacity),
    );
  }

  /// Pin: steel needle (length 1) with a dark round head at +axis.
  void pin(_V center, _V axis, {double scale = 1}) {
    final a = proj.p(center - axis * (0.5 * scale)), b = proj.p(center + axis * (0.5 * scale));
    final k = proj.scaleAt(center);
    final w = math.max(1.4, 0.05 * k * scale);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = w + 1
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF3F3F46),
    );
    canvas.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFB8BCC2),
    );
    cylinder(center + axis * (0.475 * scale), axis, 0.12 * scale, 0.05 * scale, const Color(0xFF444444),
        cap: const Color(0xFF6B6B6B));
  }

  /// Soft contact shadow of a footprint polygon on the table (y = 0).
  void shadow(List<_V> footprint, {double opacity = 0.3, double blur = 6}) {
    canvas.drawPath(
      poly(footprint),
      Paint()
        ..color = Colors.black.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }
}

// ============================================================ PAINTER

/// Paints the HTML Three.js bench: table, battery + wire, retort stand,
/// inventory tray, strips with the heat-map shader, wax, pins and candle.
class _BenchPainter extends CustomPainter {
  _BenchPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.uiScale,
  }) : super(repaint: repaint);

  final _HeatScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double uiScale;

  static const _up = _V(0, 1, 0);
  static const _wax = Color(0xFFE5C865);

  late _Draw _d;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = _Proj(scene.eye, scene.target);
    _d = _Draw(canvas, proj);
    final bleed = labBleed(size);

    // Scene background (scene.background: #0f172a / #e2e8f0).
    canvas.drawRect(bleed, Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0));
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.1,
          colors: [
            (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.7),
            (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    _paintTable();
    _paintShadows();
    _paintTray();

    // Draw in three layers around the strip plane (z ≈ 0): things behind
    // it (battery, wire), the strip with everything attached to it and the
    // stand clamp, then everything in front of it, each sorted far to near.
    // A single depth key for the long strip would hide blobs at its far end.
    final behind = <(double, VoidCallback)>[];
    final front = <(double, VoidCallback)>[];
    void add(List<(double, VoidCallback)> list, _V ref, VoidCallback fn) => list.add((proj.depth(ref), fn));
    void flush(List<(double, VoidCallback)> list) {
      list.sort((a, b) => b.$1.compareTo(a.$1));
      for (final dr in list) {
        dr.$2();
      }
    }

    add(behind, const _V(-8, 0.75, -2), _paintBattery);
    add(behind, const _V(-1, 0.4, -1.4), _paintWire);
    flush(behind);

    if (scene.strip != null) _paintPlacedStrip();
    for (final w in scene.waxes) {
      _paintWax(w);
    }
    for (final p in scene.pins) {
      if (!p.fallen) _paintPlacedPin(p);
    }
    _paintStand();

    for (final p in scene.pins) {
      if (p.fallen) add(front, p.pos + const _V(0, 0, 0.05), () => _paintPlacedPin(p));
    }
    for (final it in scene.items) {
      if (!it.visible || it == scene.dragging) continue;
      add(front, it.tool == _Tool.candle ? it.pos + const _V(0, 1, 0) : it.pos, () => _paintItem(it));
    }
    flush(front);
    _paintHeatGlow();

    final drag = scene.dragging;
    if (drag != null) {
      // Lifted item: drop shadow on the table, then the item on top.
      _d.shadow([
        drag.pos + const _V(-0.6, 0, -0.4) - _V(0, drag.pos.y, 0),
        drag.pos + const _V(0.6, 0, -0.4) - _V(0, drag.pos.y, 0),
        drag.pos + const _V(0.6, 0, 0.4) - _V(0, drag.pos.y, 0),
        drag.pos + const _V(-0.6, 0, 0.4) - _V(0, drag.pos.y, 0),
      ], opacity: 0.25, blur: 10);
      _paintItem(drag);
    }

    if (showLabels) _paintLabels(canvas);
  }

  // ------------------------------------------------------------ static set

  void _paintTable() {
    const leg = Color(0xFF6B4226);
    for (final p in const [_V(-14, -4.5, -7), _V(14, -4.5, -7), _V(-14, -4.5, 7), _V(14, -4.5, 7)]) {
      _d.box(p, const _V(1, 8, 1), leg);
    }
    const wood = Color(0xFFA0522D);
    _d.box(const _V(0, -0.25, 0), const _V(30, 0.5, 16), wood, edge: 0.5);
    // Wood grain on the table top.
    final grain = Paint()
      ..strokeWidth = 1
      ..color = labShade(wood, -0.35).withValues(alpha: 0.28);
    for (var z = -7.4; z < 8; z += 0.9) {
      final wobble = math.sin(z * 3.1) * 0.08;
      _d.canvas.drawLine(_d.proj.p(_V(-15, 0.001, z)), _d.proj.p(_V(15, 0.001, z + wobble)), grain);
    }
  }

  void _paintShadows() {
    // Light from (5,15,10): shadows fall towards -x / -z.
    _V s(double x, double z, double h) => _V(x - h / 3, 0.002, z - h * 2 / 3);
    _d.shadow([s(4.25, -1.25, 0.4), s(7.75, -1.25, 0.4), s(7.75, 1.25, 0.4), s(4.25, 1.25, 0.4)]);
    _d.shadow([s(5.9, 0, 0), s(6.1, 0, 0), s(6.1, 0, 4), s(5.9, 0, 4)], opacity: 0.22, blur: 4);
    _d.shadow([s(-9.25, -2.75, 1.5), s(-6.75, -2.75, 1.5), s(-6.75, -1.25, 1.5), s(-9.25, -1.25, 1.5)]);
    _d.shadow([s(-8, -4.5, 0), s(0, -4.5, 0), s(0, 6.5, 0.3), s(-8, 6.5, 0.3)], opacity: 0.18, blur: 8);
    if (scene.strip != null) {
      _d.shadow([s(-4, -0.1, 2.6), s(5, -0.1, 2.6), s(5, 0.1, 3.4), s(-4, 0.1, 3.4)], opacity: 0.2, blur: 5);
    }
    final candle = scene.item(_Tool.candle);
    if (candle != null && candle.pos.z < 4.5 && scene.dragging != candle) {
      final c = candle.pos;
      _d.shadow([
        _V(c.x - 0.35, 0.002, c.z - 0.35),
        _V(c.x + 0.35, 0.002, c.z - 0.35),
        s(c.x + 0.35, c.z, 2),
        s(c.x - 0.35, c.z, 2),
      ], opacity: 0.22, blur: 5);
    }
  }

  void _paintTray() {
    _d.box(const _V(-4, 0.15, 3.5), const _V(8, 0.3, 6), const Color(0xFF88929E));
    for (final z in const [1.5, 3.5, 5.5]) {
      _d.box(_V(-4, 0.3, z), const _V(7.5, 0.1, 1.5), const Color(0xFF66707C), edge: 0.2);
    }
  }

  void _paintBattery() {
    _d.box(const _V(-8, 0.75, -2), const _V(2.5, 1.5, 1.5), const Color(0xFF111111), edge: 0.8);
    for (final x in const [-8.6, -7.4]) {
      _d.cylinder(_V(x, 1.45, -2), _up, 0.2, 0.3, const Color(0xFFCCA623), sheen: 0.45);
    }
  }

  void _paintWire() {
    // QuadraticBezierCurve3 tube (radius 0.05), colour #991111.
    const a = _V(-7.4, 1.6, -2), c = _V(-4, 0.1, -1), b = _V(5, 0.1, -1);
    final pts = <Offset>[];
    for (var i = 0; i <= 28; i++) {
      final t = i / 28;
      final p = a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);
      pts.add(_d.proj.p(p));
    }
    final k = _d.proj.scaleAt(c);
    final path = Path()..addPolygon(pts, false);
    _d.canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.5, 0.1 * k)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF5F0B0B),
    );
    _d.canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 0.04 * k)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD14343),
    );
  }

  void _paintStand() {
    const metal = Color(0xFF4A4A4A);
    _d.box(const _V(6, 0.2, 0), const _V(3.5, 0.4, 2.5), metal, edge: 0.6);
    _d.cylinder(const _V(6, 0, 0), _up, 0.15, 4.0, const Color(0xFFCCCCCC), sheen: 0.55);
    _d.box(const _V(5.25, 3.0, 0), const _V(1.5, 0.3, 0.5), metal, edge: 0.6);
    _d.cylinder(const _V(6, 3.0, -0.3), const _V(0, 0, 1), 0.35, 0.6, metal, sheen: 0.25);
  }

  // --------------------------------------------------------------- strips

  void _paintPlacedStrip() {
    final type = scene.strip!;
    final s = _pop(scene.time, scene.stripPop);
    const c = _V(0.5, 3, 0);
    final size = _V(9 * s, 0.8 * s, 0.15 * s);
    final base = _stripColor[type]!;
    final glass = type == _Tool.glassStrip;
    final opacity = glass ? 0.8 : 1.0;
    _d.box(c, size, base, opacity: opacity, paintFace: (n, corners) {
      if (n.z < 0.5 && n.y < 0.5) return false;
      final top = n.y > 0.5;
      final y = top ? c.y + size.y / 2 : c.y;
      final z = top ? c.z : c.z + size.z / 2;
      final from = _d.proj.p(_V(c.x - size.x / 2, y, z));
      final to = _d.proj.p(_V(c.x + size.x / 2, y, z));
      final colors = [
        for (var i = 0; i <= 24; i++)
          _heatColor(base, top ? 0.95 : 0.62, -4.5 + 9 * i / 24, scene.heat, scene.conductivity)
              .withValues(alpha: opacity),
      ];
      final path = _d.poly(corners);
      _d.canvas.drawPath(
        path,
        Paint()..shader = ui.Gradient.linear(from, to, colors, [for (var i = 0; i <= 24; i++) i / 24]),
      );
      if (!top) _stripDetail(type, corners, size, c);
      _d.canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = labShade(base, -0.6).withValues(alpha: 0.7),
      );
      return true;
    });
  }

  /// Material look on the strip's front face: wood grain, glass glint or a
  /// brushed-metal sheen line.
  void _stripDetail(_Tool type, List<_V> corners, _V size, _V c) {
    final canvas = _d.canvas;
    final z = c.z + size.z / 2;
    final x0 = c.x - size.x / 2, x1 = c.x + size.x / 2;
    switch (type) {
      case _Tool.woodStrip:
        final p = Paint()
          ..strokeWidth = 1
          ..color = const Color(0xFF5B3A1A).withValues(alpha: 0.35);
        for (final f in const [-0.28, -0.1, 0.06, 0.22]) {
          final path = Path();
          for (var i = 0; i <= 16; i++) {
            final x = x0 + (x1 - x0) * i / 16;
            final o = _d.proj.p(_V(x, c.y + size.y * (f + 0.03 * math.sin(i * 1.3 + f * 9)), z));
            i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
          }
          canvas.drawPath(path, p..style = PaintingStyle.stroke);
        }
      case _Tool.glassStrip:
        canvas.drawLine(
          _d.proj.p(_V(x0 + 0.4, c.y + size.y * 0.3, z)),
          _d.proj.p(_V(x1 - 0.4, c.y + size.y * 0.3, z)),
          Paint()
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.55),
        );
      default:
        canvas.drawLine(
          _d.proj.p(_V(x0 + 0.2, c.y + size.y * 0.28, z)),
          _d.proj.p(_V(x1 - 0.2, c.y + size.y * 0.28, z)),
          Paint()
            ..strokeWidth = 1.2
            ..color = Colors.white.withValues(alpha: 0.18),
        );
    }
  }

  // ------------------------------------------------------------ wax & pins

  void _paintWax(_Placed w) {
    final s = _pop(scene.time, w.popStart);
    final m = w.meltStart < 0 ? 0.0 : ((scene.time - w.meltStart) / 0.4).clamp(0.0, 1.0);
    _waxBlob(w.pos, s, m);
  }

  /// Wax blob; [melt] 0..1 flattens it (scale x 1.5, y 0.1) with a drip.
  void _waxBlob(_V pos, double s, double melt) {
    final sx = 1 + 0.5 * melt, sy = 1 - 0.9 * melt;
    if (melt > 0) {
      final k = _d.proj.scaleAt(pos);
      final top = _d.proj.p(pos);
      final dripLen = 0.35 * k * melt;
      final drip = Path()
        ..moveTo(top.dx - 0.06 * k, top.dy)
        ..quadraticBezierTo(top.dx - 0.05 * k, top.dy + dripLen * 0.8, top.dx, top.dy + dripLen)
        ..quadraticBezierTo(top.dx + 0.05 * k, top.dy + dripLen * 0.8, top.dx + 0.06 * k, top.dy)
        ..close();
      _d.canvas.drawPath(drip, Paint()..color = _wax.withValues(alpha: 0.75 * melt));
    }
    _d.blob(pos, 0.25 * sx * s, 0.25 * sy * s, _wax, opacity: 1 - 0.35 * melt);
  }

  /// Fall rotation (Euler x -> PI/2, z -> random) over 500 ms.
  (double, double) _fallRot(_Placed p) {
    if (!p.fallen) return (0, 0);
    final t = ((scene.time - p.fallStart) / 0.5).clamp(0.0, 1.0);
    return (math.pi / 2 * t, p.fallRotZ * t);
  }

  void _paintPlacedPin(_Placed p) {
    final s = _pop(scene.time, p.popStart);
    final (rx, rz) = _fallRot(p);
    final axis = _rotXZ(_up, rx, rz);
    if (scene.scenario == 1) {
      // Waxed pin: the wax (local z -0.15) travels with the pin.
      final melt = p.meltStart < 0 ? 0.0 : ((scene.time - p.meltStart) / 0.4).clamp(0.0, 1.0);
      final waxPos = p.pos + _rotXZ(const _V(0, 0, -0.15), rx, rz) * s;
      _waxBlob(waxPos, s, melt);
    }
    _d.pin(p.pos, axis, scale: s);
  }

  // -------------------------------------------------------------- items

  void _paintItem(_Item it) {
    switch (it.tool) {
      case _Tool.metalStrip:
      case _Tool.woodStrip:
      case _Tool.glassStrip:
        final glass = it.tool == _Tool.glassStrip;
        _d.box(it.pos, const _V(9, 0.15, 0.8), _stripColor[it.tool]!, opacity: glass ? 0.6 : 1);
        if (it.tool == _Tool.woodStrip) {
          final p = Paint()
            ..strokeWidth = 1
            ..color = const Color(0xFF5B3A1A).withValues(alpha: 0.35);
          for (final dz in const [-0.22, 0.0, 0.2]) {
            _d.canvas.drawLine(_d.proj.p(it.pos + _V(-4.4, 0.08, dz)), _d.proj.p(it.pos + _V(4.4, 0.08, dz + 0.03)), p);
          }
        }
      case _Tool.wax:
        _d.blob(it.pos, 0.25, 0.25, _wax);
      case _Tool.pin:
        _d.pin(it.pos, const _V(0, 0, 1));
      case _Tool.waxedPin:
        _d.pin(it.pos, const _V(0, 0, 1));
        _d.blob(it.pos + const _V(0, 0.15, 0), 0.25, 0.25, _wax);
      case _Tool.candle:
        _paintCandle(it);
    }
  }

  void _paintCandle(_Item it) {
    final s = _pop(scene.time, it.popStart);
    final placed = scene.hasCandle;
    final base = it.pos;
    _d.cylinder(base, _up, 0.35 * s, 2.0 * s, const Color(0xFFF8FAFC), cap: const Color(0xFFFFFFFF), sheen: 0.05);
    final wickA = _d.proj.p(base + _V(0, 2.0 * s, 0)), wickB = _d.proj.p(base + _V(0, 2.2 * s, 0));
    _d.canvas.drawLine(
      wickA,
      wickB,
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.black,
    );
    final flameBase = base + _V(0, 2.12 * s, 0);
    final k = _d.proj.scaleAt(flameBase);
    // Point light glow (intensity 1 in the tray, 2 once placed).
    labGlow(_d.canvas, _d.proj.p(flameBase + const _V(0, 0.25, 0)), (placed ? 2.4 : 1.2) * k,
        const Color(0xFFF59E0B), intensity: placed ? 0.45 : 0.28);
    // Flame cone (r 0.12, h 0.4) flickering like the HTML scale animation.
    final flick = 1 + math.sin(scene.time * 15) * 0.1;
    labFlame(_d.canvas, _d.proj.p(flameBase), 0.5 * k * s * flick, scene.time);
  }

  /// Warm light from the placed candle on the underside of the strip.
  void _paintHeatGlow() {
    if (!scene.hasCandle || scene.strip == null) return;
    final candle = scene.item(_Tool.candle);
    if (candle == null) return;
    final p = _d.proj.p(_V(candle.pos.x, 2.6, 0.08));
    final k = _d.proj.scaleAt(const _V(-4, 2.6, 0));
    labGlow(_d.canvas, p, 0.9 * k, const Color(0xFFF97316), intensity: 0.35 + 0.25 * scene.heat);
  }

  // -------------------------------------------------------------- labels

  void _paintLabels(Canvas canvas) {
    String t(String k) => labTr(_i18n, lang, k);
    String stripName(_Tool tool) => t(switch (tool) {
          _Tool.woodStrip => 'lbl_wood_strip',
          _Tool.glassStrip => 'lbl_glass_strip',
          _ => 'lbl_metal_strip',
        });
    void label(String text, _V at) {
      labText(
        canvas,
        text,
        _d.proj.p(at),
        size: 12 * uiScale,
        weight: FontWeight.w700,
        color: isDark ? Colors.white : _Colors.slate800,
        background: isDark ? const Color(0xD91E293B) : const Color(0xE6FFFFFF),
        border: isDark ? _Colors.slate600 : _Colors.slate300,
        borderWidth: 1,
        radius: 6 * uiScale,
        padding: EdgeInsets.symmetric(horizontal: 8 * uiScale, vertical: 4 * uiScale),
      );
    }

    // Strip label (placed strip, otherwise the inventory strips).
    if (scene.strip != null) {
      label(stripName(scene.strip!), const _V(0.5, 4.5, 0));
    } else {
      for (final it in scene.items) {
        if (it.tool.isStrip && it.visible) label(stripName(it.tool), it.pos + const _V(0, 1.0, 0));
      }
    }
    // Candle.
    final candle = scene.item(_Tool.candle);
    if (candle != null) label(t('lbl_candle'), candle.pos + const _V(0, 2.8, 0));
    // Wax blobs / waxed pins.
    final waxName = t(scene.scenario == 0 ? 'lbl_wax_blobs' : 'lbl_waxed_pins');
    if (scene.waxes.isNotEmpty) {
      label(waxName, scene.waxes.first.pos + const _V(0, 1.5, 0));
    } else if (scene.pins.isNotEmpty && scene.scenario == 1) {
      // Anchored at the strip height so it stays put while the pin falls.
      final first = scene.pins.first.pos;
      label(waxName, _V(first.x, 3.0 + 1.5, first.z));
    } else {
      final first = scene.items.where((i) => i.tool == _Tool.wax || i.tool == _Tool.waxedPin).firstOrNull;
      if (first != null) label(waxName, first.pos + const _V(0, 1.0, 0));
    }
    label(t('lbl_stand'), const _V(6, 2.5, 0));
  }

  @override
  bool shouldRepaint(covariant _BenchPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.uiScale != uiScale;
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
