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

/// Class 7 Science • Chapter 5 • Activity 6
/// Natural Changes: Weathering and Erosion.
///
/// Native Flutter port of `Cl7S-Ch5-A6-Natural_Changes__Weathering_and_Erosion.html`.
///
/// Scenario 1 (Weathering, 2D cliff): drag Sun / Snowflake onto the cliff three
/// times (thermal cracking), Rain Cloud + Snowflake into the deep crack (ice
/// wedging), a Sapling into a crack and the time-lapse slider (root
/// pressure), Rain Cloud onto the black basalt and the time-lapse slider
/// (oxidation), then Summarize.
///
/// Scenario 2 (The River's Journey, isometric 3D diorama): raise the flow
/// speed, watch jagged rocks tumble into smooth pebbles, the sand settle into
/// a delta in the lake, drop the Wind on the sandy bank to raise dunes, then
/// Summarize.
class Ch5A6NaturalChangesWeatheringAndErosionPage extends StatefulWidget {
  const Ch5A6NaturalChangesWeatheringAndErosionPage({super.key});

  @override
  State<Ch5A6NaturalChangesWeatheringAndErosionPage> createState() =>
      _Ch5A6NaturalChangesWeatheringAndErosionPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, splash 1311,
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
  splash('splash.mp3'),
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

class _Ch5A6NaturalChangesWeatheringAndErosionPageState
    extends State<Ch5A6NaturalChangesWeatheringAndErosionPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _WeatherScene _scene = _WeatherScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final GlobalKey _stageKey = GlobalKey();
  final GlobalKey _overlayKey = GlobalKey();
  final GlobalKey _trayKey = GlobalKey();

  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// HTML `State.actionCompleted`: the current step has been validated.
  bool _actionCompleted = false;

  _Item? _dragItem;
  Offset? _dragGlobal;

  int get _scenario => _scene.scenario;
  int get _stepIdx => _scene.stepIdx;

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
    _ticker = createTicker(_onTick)..start();
    _loadScenario(0, notify: false);
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

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    final s = _scene..time = elapsed.inMicroseconds / 1e6;
    final f = dt * 60; // HTML per-frame increments assume 60 fps

    if (s.scenario == 0) {
      // HTML viewBox lerp (5% per frame).
      final k = 1 - math.pow(0.95, f).toDouble();
      s.camX += (s.target.cx - s.camX) * k;
      s.camY += (s.target.cy - s.camY) * k;
      s.camW += (s.target.w - s.camW) * k;
      s.crackWidth = _approach(s.crackWidth, s.crackWidthTarget, dt, 0.5);
      s.waterOpacity = _approach(s.waterOpacity, s.crackWaterFilled ? 0.8 : 0, dt, 0.5);
      s.iceMix = _approach(s.iceMix, s.crackIceFilled ? 1 : 0, dt, 0.5);
      s.treeScale = _approach(s.treeScale, s.treeScaleTarget, dt, 0.3);
      // The wet sheen dries a little as the time-lapse runs, so the rust
      // colour stays visible under the 0.6 black "wet" overlay.
      final wet = s.rockWet ? 0.6 * (1 - 0.6 * s.chemProgress / 100) : 0.0;
      s.wetOpacity = _approach(s.wetOpacity, wet, dt, 0.3);
      s.chemMix = _approach(s.chemMix, s.chemProgress / 100, dt, 0.5);
      s.crumbs.removeWhere((c) => s.time - c.start > 1);
    } else {
      _riverTick(dt, f);
    }
    _frame.value = s.time;
  }

  /// HTML `animate()` 3D section: rocks, abrasion, suspension, deposition,
  /// dunes and wind streaks.
  void _riverTick(double dt, double f) {
    final s = _scene;
    s.camShift += (s.camShiftTarget - s.camShift) * (1 - math.pow(0.95, f).toDouble());
    if (s.flowSpeed > 0) {
      s.waterScroll += s.flowSpeed * 0.0005 * f;
      s.lakeScroll += s.flowSpeed * 0.0005 * 0.3 * f; // calm lake
      var active = s.flowSpeed;
      if (s.stepIdx >= 2) active = math.max(10, s.flowSpeed * 0.3);
      final speed = active * 0.0001 * f;
      var allAtBottom = true;
      for (final r in s.rocks) {
        if (r.progress < 0.95) {
          allAtBottom = false;
          r.progress += speed;
          s._placeOnCurve(r);
          r.rotX += r.rotSpeedX * f;
          r.rotZ += r.rotSpeedZ * f;
          if (!r.isSmooth && r.progress > 0.5) {
            // Morph into a smooth, flattened pebble.
            r.isSmooth = true;
            _Audio.play(_Sound.pop);
            if (_rnd.nextDouble() > 0.3) s.chips.add(_Chip(r.x, r.y, r.z, s.time));
          }
        } else {
          s.sandAccumulation += 0.01 * f;
          r.visible = false;
        }
      }
      // Suspended sand appears once abrasion has started (step 2+).
      if (s.stepIdx >= 1 && s.rocks.isNotEmpty && s.rocks[0].isSmooth) {
        final spawn = 1 - math.pow(0.95, f).toDouble();
        for (final p in s.sand) {
          if (!p.visible && _rnd.nextDouble() < spawn) {
            p
              ..visible = true
              ..progress = 0.5 + _rnd.nextDouble() * 0.2
              ..offsetZ = (_rnd.nextDouble() - 0.5) * 1.5;
          }
          if (p.visible) {
            p.progress += speed * 1.5;
            final pt = _riverPoint(math.min(1, p.progress));
            // In the lake the grains sink to the bottom.
            final sink = p.progress > 0.85 && s.stepIdx >= 2 ? 0.4 : 0.2;
            p
              ..x = pt.$1
              ..y = pt.$2 - sink
              ..z = pt.$3 + p.offsetZ;
            if (p.progress >= 0.98) p.visible = false;
          }
        }
      }
      if (s.stepIdx == 1 && s.rocks[0].isSmooth && !_actionCompleted) _checkStepComplete();
      if (s.stepIdx == 2 && allAtBottom && !_actionCompleted && s.deltaScale < 1) {
        s.deltaScale += 0.01 * f;
        if (s.deltaScale >= 0.99) {
          _Audio.play(_Sound.drop);
          _checkStepComplete();
        }
      }
    }
    if (s.windErosionDone && s.duneRise < 1) s.duneRise = math.min(1, s.duneRise + dt / 1.17);
    for (final w in s.wind) {
      w.x += w.speed * f;
      w.z -= w.speed * 0.2 * f;
    }
    s.wind.removeWhere((w) => w.x >= 7);
    s.chips.removeWhere((c) => s.time - c.start > 1);
  }

  // ---------------------------------------------------------------- logic

  /// HTML `loadScenario(idx)`: step 1 of the scenario and its scene setup.
  void _loadScenario(int index, {bool notify = true}) {
    void apply() {
      _lab.cancelPending();
      _lab.hidePopup(sound: false);
      _scene
        ..scenario = index
        ..stepIdx = 0
        ..dragging = null;
      _actionCompleted = false;
      _dragItem = null;
      _dragGlobal = null;
      if (index == 0) {
        _scene.resetCliff(); // HTML setupCliffScene()
      } else {
        _scene.resetRiver(_rnd); // HTML setupRiverScene()
      }
      _applyStepView();
      _lab.resetView(sound: false);
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _changeScenario(int index) => _loadScenario(index);

  /// Header "Reset Lab": the shell restores its own state; back to S1.
  void _fullReset() => _loadScenario(0);

  /// HTML step `viewTarget2D`: S1 camera view / S2 camera pan.
  void _applyStepView() {
    if (_scenario == 0) {
      _scene.target = const [_viewOverview, _viewIce, _viewBio, _viewChem, _viewOverview][_stepIdx];
    } else {
      _scene.camShiftTarget = _riverShift[_stepIdx];
    }
  }

  /// HTML `nextStep()` + the step's `setup()`.
  void _nextStep() {
    if (_stepIdx >= 4) return;
    setState(() {
      _scene.stepIdx++;
      _actionCompleted = false;
      if (_scenario == 0) {
        switch (_stepIdx) {
          case 1:
            _addLabel('s1Lbl8', 800, 250);
          case 3:
            _addLabel('s1Lbl6', 2000, 300);
          case 4:
            _addLabel('s1Sum1', 200, 200);
            _addLabel('s1Sum2', 800, 200);
            _addLabel('s1Sum3', 1460, 200);
            _addLabel('s1Sum4', 2000, 200);
        }
      }
      _applyStepView();
    });
  }

  void _addLabel(String key, double x, double y) {
    if (_scene.labels.any((l) => l.key == key)) return;
    _scene.labels.add(_Label2D(key, x, y));
  }

  /// HTML step `check()`.
  bool _stepCheck() {
    final s = _scene;
    if (_scenario == 0) {
      return switch (_stepIdx) {
        0 => s.cycleCount >= 3,
        1 => s.crackIceFilled,
        2 => s.chunk3Falling,
        3 => s.chemProgress > 90,
        _ => false,
      };
    }
    return switch (_stepIdx) {
      0 => s.flowSpeed > 50,
      1 => s.flowSpeed > 50 && s.rocks.isNotEmpty && s.rocks[0].isSmooth,
      2 => s.sandAccumulation > 1.5 && s.deltaScale >= 0.99,
      3 => s.windErosionDone,
      _ => false,
    };
  }

  /// HTML `checkStepComplete(manual)`: feedback toast, then the next step
  /// after 3 s, or the observation popup after the last step.
  void _checkStepComplete({bool manual = false}) {
    if (_actionCompleted || !(manual || _stepCheck())) return;
    _actionCompleted = true;
    final scenario = _scenario;
    _lab.showToast(_t('s${scenario + 1}Step${_stepIdx + 1}Val'));
    if (_stepIdx == 4) {
      _lab.openSidebar();
      _lab.showScenarioConclusion(
        scenarioIndex: scenario,
        totalScenarios: 2,
        delay: const Duration(milliseconds: 3000),
        title: () => _t('labObs'),
        heading: () => _t(scenario == 0 ? 'labObs' : 'resConc'),
        body: () => _t(scenario == 0 ? 's1Popup' : 's2Popup'),
      );
    } else {
      _lab.after(const Duration(milliseconds: 3000), () {
        if (!mounted || _scenario != scenario) return;
        _nextStep();
      });
    }
    if (mounted) setState(() {});
  }

  void _hint(String key) => _lab.showToast(_t(key), isError: true);

  /// HTML `handleDropTarget2D(targetArea, type)`. [zone] is 0..3 for the
  /// thermal / ice / bio / chem cliff zones; S2 always targets the bank.
  void _handleDrop(int zone, _Item item) {
    final s = _scene;
    if (_actionCompleted) return;
    if (_scenario == 1) {
      if (_stepIdx == 3 && item == _Item.wind) {
        _Audio.play(_Sound.whoosh);
        for (var i = 0; i < 8; i++) {
          s.wind.add(_WindLine(
            1,
            0.5 + _rnd.nextDouble() * 0.8,
            -2.5 + _rnd.nextDouble() * 3,
            0.06 + _rnd.nextDouble() * 0.05,
          ));
        }
        setState(() => s.windErosionDone = true);
        _lab.after(const Duration(milliseconds: 2000), () {
          if (!mounted || _scenario != 1) return;
          if (!_actionCompleted) _checkStepComplete();
        });
      }
      return;
    }
    if (zone != _stepIdx) {
      _hint('hintZone');
      return;
    }
    setState(() {
      switch (_stepIdx) {
        case 0:
          if (s.cycleCount == 0 && s.sunPhase == 0) s.target = _viewThermal;
          if (item == _Item.sun && s.sunPhase == 0) {
            s
              ..sunPhase = 1
              ..glowRedStart = s.time;
            _Audio.play(_Sound.pop);
          } else if (item == _Item.snowflake && s.sunPhase == 1) {
            s
              ..sunPhase = 0
              ..cycleCount += 1
              ..glowBlueStart = s.time
              ..crackWidthTarget += 1.5;
            _Audio.play(_Sound.drop);
            _spawnCrumbs(200, 350);
            if (s.cycleCount >= 3) {
              _addLabel('s1Lbl1', 150, 420);
              _checkStepComplete();
            }
          } else {
            _hint(item == _Item.sun ? 'hintSnowNow' : 'hintSunFirst');
          }
        case 1:
          if (item == _Item.cloud) {
            s.crackWaterFilled = true;
            _addLabel('s1Lbl2', 900, 200);
            _Audio.play(_Sound.splash);
          } else if (item == _Item.snowflake && s.crackWaterFilled) {
            s
              ..crackIceFilled = true
              ..iceFallStart = s.time;
            _Audio.play(_Sound.drop);
            _addLabel('s1Lbl3', 1000, 300);
            _checkStepComplete();
          } else {
            _hint('hintWaterFirst');
          }
        case 2:
          if (item == _Item.sapling && !s.hasSapling) {
            s
              ..hasSapling = true
              ..treeScaleTarget = 0.4;
            _Audio.play(_Sound.pop);
            _addLabel('s1Lbl4', 1460, 80);
          }
        case 3:
          if (item == _Item.cloudChem) {
            s.rockWet = true;
            _Audio.play(_Sound.splash);
          }
      }
    });
  }

  /// HTML `spawn2DParticles(x, y)`: 15 crumbs falling from the cliff.
  void _spawnCrumbs(double wx, double wy) {
    final s = _scene;
    final k = 1000 / s.camW;
    final cx = 500 + (wx - s.camX) * k, cy = 280 + (wy - s.camY) * k;
    for (var i = 0; i < 15; i++) {
      s.crumbs.add(_Crumb(
        cx + (_rnd.nextDouble() - 0.5) * 50,
        cy + (_rnd.nextDouble() - 0.5) * 28,
        (_rnd.nextDouble() - 0.5) * 150,
        _rnd.nextDouble() * 2 * math.pi,
        s.time,
      ));
    }
  }

  /// HTML `updateTimeLapse(val)` (step 3: tree growth, root pressure).
  void _onTimeLapse(double v) {
    final s = _scene;
    if (!s.hasSapling) return;
    setState(() {
      s
        ..timeLapse = v
        ..treeScaleTarget = 0.4 + v / 140;
      if (v > 80 && !s.chunk3Falling) {
        s
          ..chunk3Falling = true
          ..bioFallStart = s.time;
        _Audio.play(_Sound.drop);
        _addLabel('s1Lbl5', 1600, 300);
        _checkStepComplete();
      }
    });
  }

  /// HTML `updateChemical(val)` (step 4: oxidation of the wet basalt).
  void _onChemical(double v) {
    final s = _scene;
    if (!s.rockWet) return;
    setState(() {
      s.chemProgress = v.round();
      if (v > 90) {
        _addLabel('s1Lbl7', 2100, 350);
        _checkStepComplete();
      }
    });
  }

  /// HTML `updateFlowSpeed(val)`.
  void _onFlow(double v) {
    final s = _scene;
    if (s.flowSpeed == 0 && v > 0) _Audio.play(_Sound.splash);
    setState(() => s.flowSpeed = v.roundToDouble());
    if (_stepIdx == 0 && s.flowSpeed > 50 && !_actionCompleted) _checkStepComplete();
  }

  void _summarize() {
    if (!_actionCompleted) _checkStepComplete(manual: true);
  }

  // ----------------------------------------------------------------- drag

  /// HTML step `tray` contents.
  List<_Item> _trayItems() {
    if (_scenario == 0) {
      return switch (_stepIdx) {
        0 => const [_Item.sun, _Item.snowflake],
        1 => const [_Item.cloud, _Item.snowflake],
        2 => const [_Item.sapling],
        3 => const [_Item.cloudChem],
        _ => const [],
      };
    }
    return _stepIdx == 3 ? const [_Item.wind] : const [];
  }

  String _itemLabel(_Item item) => _t(switch (item) {
        _Item.sun => 'traySun',
        _Item.snowflake => 'traySnow',
        _Item.cloud || _Item.cloudChem => 'trayCloud',
        _Item.sapling => 'traySapling',
        _Item.wind => 'trayWind',
      });

  void _dragStart(_Item item, Offset global) {
    _Audio.play(_Sound.pickup);
    setState(() {
      _dragItem = item;
      _dragGlobal = global;
      _scene.dragging = item;
      // HTML startDrag(): S1 step 1 focuses the camera on the thermal cliff.
      if (_scenario == 0 && _stepIdx == 0) _scene.target = _viewThermal;
    });
  }

  void _dragMove(Offset global) => setState(() => _dragGlobal = global);

  void _dragCancel() => setState(() {
        _dragItem = null;
        _dragGlobal = null;
        _scene.dragging = null;
      });

  /// HTML `endDrag()`: maps the drop point into the scene and picks the
  /// target zone (falling back to the current step's zone like the HTML).
  void _dragEnd() {
    final item = _dragItem;
    final global = _dragGlobal;
    _dragCancel();
    if (item == null || global == null) return;
    final trayBox = _trayKey.currentContext?.findRenderObject();
    if (trayBox is RenderBox && trayBox.hasSize) {
      final local = trayBox.globalToLocal(global);
      if ((Offset.zero & trayBox.size).inflate(6).contains(local)) return; // dropped back
    }
    final design = labGlobalToLocal(_stageKey, global);
    var zone = _stepIdx;
    if (_scenario == 0 && design != null) {
      final s = _scene;
      final k = 1000 / s.camW;
      final wx = s.camX + (design.dx - 500) / k;
      final wy = s.camY + (design.dy - 280) / k;
      if (wy > 0 && wy < 600) zone = (wx / 600).floor().clamp(0, 3);
    }
    _handleDrop(zone, item);
  }

  // ------------------------------------------------------------------- UI

  List<LabAction> _actions() {
    if (_stepIdx != 4) return const [];
    return [
      LabAction(
        label: _t('summaryBtn'),
        icon: Icons.check_circle,
        highlight: !_actionCompleted,
        enabled: !_actionCompleted,
        onTap: _summarize,
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
        final inset = labOverlayInsets(context, _lab);
        final tray = _trayItems();
        return LabShell(
          controller: _lab,
          icon: Icons.terrain,
          title: _t('appTitle'),
          subtitle: _t('appSub'),
          scenarioNames: [_t('scen1'), _t('scen2')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _stepIdx + 1,
          actions: _actions(),
          onReset: _fullReset,
          showHud: false,
          overlays: [
            _hudOverlay(p, s, inset, data),
            if (tray.isNotEmpty) _trayOverlay(p, s, inset, tray),
            _ghostOverlay(s),
          ],
          stage: LayoutBuilder(
            builder: (context, box) {
              final fit = math.min(box.maxWidth / _design.width, box.maxHeight / _design.height);
              final ui = fit <= 0 ? 1.0 : (0.85 / fit).clamp(1.0, 1.8);
              return LabStage(
                designSize: _design,
                child: CustomPaint(
                  key: _stageKey,
                  size: _design,
                  painter: _scenario == 0
                      ? _CliffPainter(
                          scene: _scene,
                          repaint: _frame,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          uiScale: ui,
                        )
                      : _RiverPainter(
                          scene: _scene,
                          repaint: _frame,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          uiScale: ui,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// HTML `#hud-container`: the task text (while the sidebar is open; the
  /// floating mission card shows it otherwise) plus the step's HUD widget.
  Widget _hudOverlay(LabPalette p, double s, EdgeInsets inset, LabScenarioData data) {
    final f = s * _lab.fontScale.clamp(0.9, 1.25);
    final control = _hudControl(p, s, f);
    final showTask = _lab.isSidebarOpen;
    if (control == null && !showTask) return const SizedBox.shrink();
    return Positioned(
      left: inset.left + 4,
      right: inset.right + 4,
      bottom: inset.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 470 * s),
          child: LabGlassCard(
            palette: p,
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
            borderColor: _Colors.zslYellow.withValues(alpha: 0.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showTask)
                  Text.rich(
                    TextSpan(children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(right: 3 * s),
                          child: Icon(Icons.info, size: 13 * f, color: _Colors.zslYellow),
                        ),
                      ),
                      TextSpan(
                        text: '${_t('task')} ',
                        style: const TextStyle(color: _Colors.zslYellow, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: data.steps[_stepIdx].action),
                    ]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.textStrong, fontSize: 10.5 * f, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                if (showTask && control != null) SizedBox(height: 6 * s),
                ?control,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The HTML step `hud` markup for the current step.
  Widget? _hudControl(LabPalette p, double s, double f) {
    Widget chip(String text, {String? sub}) => Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 4 * s),
          decoration: BoxDecoration(
            color: p.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textStrong, fontSize: 12 * f, fontWeight: FontWeight.w800),
              ),
              if (sub != null)
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.textMuted, fontSize: 10 * f, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        );
    Widget gap() => SizedBox(height: 5 * s);
    final sc = _scene;

    if (_stepIdx == 4) {
      return LabActionButton(
        scale: s,
        expand: false,
        action: LabAction(
          label: _t('summaryBtn'),
          icon: Icons.check_circle,
          highlight: !_actionCompleted,
          enabled: !_actionCompleted,
          onTap: _summarize,
        ),
      );
    }
    if (_scenario == 0) {
      return switch (_stepIdx) {
        0 => chip('${_t('cycles')} ${sc.cycleCount} / 3${sc.sunPhase == 1 ? ' ${_t('dropSnow')}' : ''}'),
        1 => chip(_t('s1Step2Hud')),
        2 => _slider(p, s, f, Icons.schedule, _Colors.zslYellow, _t('timeLapse'), sc.timeLapse,
            sc.hasSapling, _onTimeLapse),
        _ => _slider(p, s, f, Icons.schedule, _Colors.zslYellow, _t('timeLapse'),
            sc.chemProgress.toDouble(), sc.rockWet, _onChemical),
      };
    }
    final flow = _slider(p, s, f, Icons.waves, const Color(0xFF60A5FA), _t('flowSpeed'), sc.flowSpeed,
        true, _onFlow);
    return switch (_stepIdx) {
      0 => flow,
      1 => Column(mainAxisSize: MainAxisSize.min, children: [chip(_t('s2Step2Hud')), gap(), flow]),
      2 => Column(mainAxisSize: MainAxisSize.min, children: [
          chip(_t('s2Step3Hud'), sub: _t('s2Step3HudSub')),
          gap(),
          flow,
        ]),
      _ => chip(_t('s2Step4Hud')),
    };
  }

  /// Rounded HUD range input (HTML `#timelapse-slider` / `#flow-slider`).
  Widget _slider(LabPalette p, double s, double f, IconData icon, Color color, String label, double value,
      bool enabled, ValueChanged<double> onChanged) {
    final slider = Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18 * s, color: enabled ? color : p.textMuted),
          SizedBox(width: 4 * s),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.textMuted, fontSize: 10 * f, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4 * s,
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: p.cardBorder,
                disabledThumbColor: p.textMuted,
                disabledActiveTrackColor: p.cardBorder,
                disabledInactiveTrackColor: p.cardBorder.withValues(alpha: 0.5),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * s),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9 * s),
              ),
              child: Slider(
                value: value.clamp(0, 100),
                min: 0,
                max: 100,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 30 * s,
            child: Text(
              '${value.round()}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: enabled ? color : p.textMuted,
                fontSize: 11 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 360 * s),
      child: enabled
          ? slider
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _hint('hintSliderLocked'),
              child: slider,
            ),
    );
  }

  /// HTML `#icon-tray`: draggable items with their `.tray-label` tags.
  Widget _trayOverlay(LabPalette p, double s, EdgeInsets inset, List<_Item> items) {
    final tile = 54 * s;
    return Positioned(
      right: inset.right + 16 * s,
      top: inset.top + 46 * s,
      child: MediaQuery(
        // Short drags must start the drag (default slop is 36 px).
        data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: Column(
          key: _trayKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              Padding(
                padding: EdgeInsets.only(top: 12 * s, bottom: 6 * s),
                child: _trayTile(p, s, item, tile),
              ),
          ],
        ),
      ),
    );
  }

  Widget _trayTile(LabPalette p, double s, _Item item, double tile) {
    final active = _dragItem == item;
    return GestureDetector(
      key: ValueKey('ch5a6-tray-${item.name}'),
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => _dragStart(item, d.globalPosition),
      onPanUpdate: (d) => _dragMove(d.globalPosition),
      onPanEnd: (_) => _dragEnd(),
      onPanCancel: () {
        if (_dragItem != null) _dragCancel();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: active ? 0.35 : 1,
            child: Container(
              width: tile,
              height: tile,
              padding: EdgeInsets.all(6 * s),
              decoration: BoxDecoration(
                color: const Color(0xCC0F172A),
                borderRadius: BorderRadius.circular(14 * s),
                border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.55), width: 1.5),
                boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 6))],
              ),
              child: CustomPaint(painter: _ItemIconPainter(item)),
            ),
          ),
          Positioned(
            top: -11 * s,
            right: tile * 0.35,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
                decoration: BoxDecoration(
                  color: p.isDark ? const Color(0xFF111111) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: const Border(left: BorderSide(color: _Colors.zslYellow, width: 3)),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(2, 2))],
                ),
                child: Text(
                  _itemLabel(item),
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: p.isDark ? Colors.white : Colors.black,
                    fontSize: 10.5 * s,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#drag-ghost`: the dragged icon follows the finger.
  Widget _ghostOverlay(double s) {
    Offset? local;
    final box = _overlayKey.currentContext?.findRenderObject();
    if (_dragItem != null && _dragGlobal != null && box is RenderBox && box.hasSize) {
      local = box.globalToLocal(_dragGlobal!);
    }
    final g = 70 * s;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          key: _overlayKey,
          children: [
            if (local != null)
              Positioned(
                left: local.dx - g / 2,
                top: local.dy - g / 2,
                width: g,
                height: g,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 12))],
                  ),
                  child: CustomPaint(painter: _ItemIconPainter(_dragItem!)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================ STRINGS
//
// Copied from the HTML `i18n` table (Telugu dropped). HTML markup was turned
// into plain text: <br> -> line break, <b>/<i>/<span> removed. Strings the
// HTML hard-coded (or only had in English) were added with natural Hindi.

const LabStringTable _i18n = {
  'en': {
    'appTitle': 'Natural Changes: Weathering and Erosion',
    'appSub': 'Class 7 • Changes Around Us: Physical and Chemical',
    'scen1': 'Scenario 1: Weathering',
    'scen2': "Scenario 2: The River's Journey",
    'task': 'Task:',
    'summaryBtn': 'Summarize',
    'labObs': 'Lab Observation',
    'resConc': 'Result and Conclusion',
    'cycles': 'Cycles:',
    'dropSnow': '(Drop Snow!)',
    's1Step2Hud': 'Fill crack with water, then freeze.',
    's2Step2Hud': 'Keep flow speed high to observe abrasion...',
    's2Step3Hud': 'Observe the river mouth.',
    's2Step3HudSub': 'Auto-advances when complete.',
    's2Step4Hud': 'Drag wind to riverbank...',
    // Validation messages (feedback toast).
    's1Step1Val': 'Excellent! The temperature change caused physical cracking.',
    's1Step2Val': 'Correct! Ice wedging broke off a piece of the rock.',
    's1Step3Val': 'Well done! The growing roots shattered the rock.',
    's1Step4Val': 'Fantastic! The black rock oxidized and turned red.',
    's1Step5Val': 'Scenario 1 Completed! Summary incoming...',
    's2Step1Val': 'Great! The water is transporting the sediments.',
    's2Step2Val': 'Observed! The rocks became smooth pebbles.',
    's2Step3Val': 'Sediment deposited successfully.',
    's2Step4Val': 'Excellent! The wind eroded the sand and built a dune.',
    's2Step5Val': 'Congratulations on completing the virtual lab!',
    // Scene labels (S1, 2D cliff).
    's1Lbl1': 'Cracks widened\n↓\nFalling particles',
    's1Lbl2': 'Filled with water',
    's1Lbl3': 'Large chunk\nof rock\n💥',
    's1Lbl4': 'Tree',
    's1Lbl5': 'Root pressure\n↓\nFalling piece',
    's1Lbl6': 'Dark black basalt',
    's1Lbl7': 'Chemical change\n(Oxidation / iron oxide)',
    's1Lbl8': 'Deep Crack',
    's1Sum1': 'Physical Weathering:\nCracking from Temp',
    's1Sum2': 'Physical Weathering:\nIce Wedging',
    's1Sum3': 'Physical Weathering:\nPlant Roots',
    's1Sum4': 'Chemical Weathering:\nOxidation (Rusting)',
    // Scene labels (S2, 3D diorama).
    's2Lbl1': 'Jagged Rocks',
    's2Lbl2': 'Pre-set fine fracture lines',
    's2Lbl3': 'Small particle effects\nindicating chipping',
    's2Lbl4': 'Smoothed Pebble',
    's2Lbl5': 'Suspended Sand and Silt',
    's2Lbl6': 'Sediment Deposit\n(Delta)',
    's2Lbl7': 'SAND DUNES',
    's2Lbl8': 'COLLIDE!\nCHIP!',
    // Popups.
    's1Popup':
        'Physical Weathering breaks rocks into smaller fragments without changing their chemical composition (e.g., via temperature changes, ice expansion, and plant roots).\n\nChemical Weathering alters the rock\'s chemical composition, creating new substances (e.g., basalt reacting with oxygen and water to form iron oxide).',
    's2Popup':
        'Erosion is the process of moving weathered rock and soil from one place to another. Flowing water and wind are powerful forces of erosion.',
    // Tray items.
    'traySun': 'Sun',
    'traySnow': 'Snowflake',
    'trayCloud': 'Rain Cloud',
    'traySapling': 'Sapling',
    'trayWind': 'Wind',
    // Added for the native version (sliders, drop hints).
    'timeLapse': 'Time-lapse',
    'flowSpeed': 'Flow Speed',
    'hintSunFirst': 'Drop the Sun first to heat the rock.',
    'hintSnowNow': 'Now drop the Snowflake to cool the rock.',
    'hintWaterFirst': 'Fill the crack with water first (Rain Cloud).',
    'hintZone': 'Drop it on the rock for this step.',
    'hintSliderLocked': 'Drop the item on the rock first to unlock the time-lapse slider.',
  },
  'hi': {
    'appTitle': 'प्राकृतिक परिवर्तन: अपक्षय और अपरदन',
    'appSub': 'कक्षा 7 • हमारे आस-पास के परिवर्तन: भौतिक और रासायनिक',
    'scen1': 'परिदृश्य 1: अपक्षय',
    'scen2': 'परिदृश्य 2: नदी की यात्रा',
    'task': 'कार्य:',
    'summaryBtn': 'संक्षेप करें',
    'labObs': 'लैब अवलोकन',
    'resConc': 'परिणाम और निष्कर्ष',
    'cycles': 'चक्र:',
    'dropSnow': '(बर्फ गिराएं!)',
    's1Step2Hud': 'दरार को पानी से भरें, फिर फ्रीज करें।',
    's2Step2Hud': 'घर्षण देखने के लिए प्रवाह की गति अधिक रखें...',
    's2Step3Hud': 'नदी के मुहाने को देखें।',
    's2Step3HudSub': 'पूरा होने पर ऑटो-एडवांस।',
    's2Step4Hud': 'हवा को नदी के किनारे पर खींचें...',
    's1Step1Val': 'उत्कृष्ट! तापमान परिवर्तन के कारण भौतिक दरारें आईं।',
    's1Step2Val': 'सही! बर्फ के जमने से चट्टान का एक टुकड़ा टूट गया।',
    's1Step3Val': 'बहुत बढ़िया! बढ़ती जड़ों ने चट्टान को चकनाचूर कर दिया।',
    's1Step4Val': 'शानदार! काली चट्टान ऑक्सीकृत होकर लाल हो गई।',
    's1Step5Val': 'परिदृश्य 1 पूरा हुआ! सारांश आ रहा है...',
    's2Step1Val': 'महान! पानी तलछट को ले जा रहा है।',
    's2Step2Val': 'देखा गया! चट्टानें चिकने कंकड़ बन गईं।',
    's2Step3Val': 'तलछट सफलतापूर्वक जमा हो गया।',
    's2Step4Val': 'उत्कृष्ट! हवा ने रेत का अपरदन किया और एक टीला बनाया।',
    's2Step5Val': 'वर्चुअल लैब पूरा करने पर बधाई!',
    's1Lbl1': 'दरारें चौड़ी हुईं\n↓\nगिरते हुए कण',
    's1Lbl2': 'पानी से भर गया',
    's1Lbl3': 'चट्टान का\nबड़ा टुकड़ा\n💥',
    's1Lbl4': 'पेड़',
    's1Lbl5': 'जड़ का दबाव\n↓\nगिरता हुआ टुकड़ा',
    's1Lbl6': 'गहरा काला बेसाल्ट',
    's1Lbl7': 'रासायनिक परिवर्तन\n(ऑक्सीकरण / आयरन ऑक्साइड)',
    's1Lbl8': 'गहरी दरार',
    's1Sum1': 'भौतिक अपक्षय:\nतापमान से दरार',
    's1Sum2': 'भौतिक अपक्षय:\nआइस वेजिंग',
    's1Sum3': 'भौतिक अपक्षय:\nपौधों की जड़ें',
    's1Sum4': 'रासायनिक अपक्षय:\nऑक्सीकरण (जंग लगना)',
    's2Lbl1': 'नुकीली चट्टानें',
    's2Lbl2': 'पूर्व-सेट ठीक फ्रैक्चर लाइनें',
    's2Lbl3': 'चिपिंग का संकेत देने वाले\nछोटे कण प्रभाव',
    's2Lbl4': 'चिकना कंकड़',
    's2Lbl5': 'निलंबित रेत और गाद',
    's2Lbl6': 'तलछट जमा\n(डेल्टा)',
    's2Lbl7': 'रेत के टीले',
    's2Lbl8': 'टकराएं!\nटुकड़े!',
    's1Popup':
        'भौतिक अपक्षय चट्टानों को उनके रासायनिक संरचना को बदले बिना छोटे टुकड़ों में तोड़ देता है (जैसे, तापमान परिवर्तन, बर्फ के विस्तार और पौधों की जड़ों के माध्यम से)।\n\nरासायनिक अपक्षय चट्टान की रासायनिक संरचना को बदल देता है, जिससे नए पदार्थ बनते हैं (जैसे, बेसाल्ट ऑक्सीजन और पानी के साथ प्रतिक्रिया करके आयरन ऑक्साइड बनाता है)।',
    's2Popup':
        'अपरदन अपक्षयित चट्टान और मिट्टी को एक स्थान से दूसरे स्थान पर ले जाने की प्रक्रिया है। बहता पानी और हवा अपरदन की शक्तिशाली ताकतें हैं।',
    'traySun': 'सूरज',
    'traySnow': 'बर्फ',
    'trayCloud': 'बारिश का बादल',
    'traySapling': 'पौधा',
    'trayWind': 'हवा',
    'timeLapse': 'टाइम-लैप्स',
    'flowSpeed': 'प्रवाह गति',
    'hintSunFirst': 'चट्टान को गर्म करने के लिए पहले सूरज को छोड़ें।',
    'hintSnowNow': 'अब चट्टान को ठंडा करने के लिए बर्फ को छोड़ें।',
    'hintWaterFirst': 'पहले दरार को पानी से भरें (बारिश का बादल)।',
    'hintZone': 'इसे इस चरण वाली चट्टान पर छोड़ें।',
    'hintSliderLocked': 'टाइम-लैप्स स्लाइडर खोलने के लिए पहले वस्तु को चट्टान पर छोड़ें।',
  },
};

// The HTML step `objective` ("Step 1: Temperature Changes") is the concept,
// `task` the action and `theory` the (teacher-only) observation.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'The Rock Breakers',
      objective:
          'To investigate how natural forces cause both physical and chemical weathering to break down large rocks into smaller sediments.',
      steps: [
        LabStep(
          concept: 'Temperature Changes',
          action:
              "DRAG the 'Sun' icon and DROP it onto the large rock cliff. Then, DRAG the 'Snowflake' icon and DROP it onto the same cliff. Repeat this cycle three times.",
          observation:
              'The rock surface visibly develops small cracks. With each cycle of heating (sun) and cooling (snowflake), the cracks grow wider, and tiny pieces of rock crumble and fall to the base.',
        ),
        LabStep(
          concept: 'Ice Wedging',
          action:
              "DRAG the 'Rain Cloud' icon and DROP it over the largest crack in the cliff. Then, DRAG the 'Snowflake' icon and DROP it onto the same water-filled crack.",
          observation:
              'Water from the cloud fills the crack. When the snowflake is applied, the water turns into ice, visibly expanding and forcing a large chunk of the rock to break off and fall.',
        ),
        LabStep(
          concept: 'Biological Weathering',
          action:
              "DRAG the 'Sapling' icon and DROP it into a crack near the top of the cliff. Then, DRAG the 'Time-lapse' slider from left to right.",
          observation:
              'The sapling is placed in the crack. As the slider moves, the sapling grows into a large tree, and its roots are shown visibly growing larger within the crack, pushing the rock apart until another piece breaks off.',
        ),
        LabStep(
          concept: 'Chemical Weathering',
          action:
              "Notice the dark section of the cliff. DRAG the 'Rain Cloud' icon and DROP it over this black rock. Now, DRAG the 'Time-lapse' slider from left to right.",
          observation:
              'After being wet by the rain, the surface of the black rock slowly changes to a reddish-brown color as the time-lapse slider is moved, indicating a chemical change.',
        ),
        LabStep(
          concept: 'Summary',
          action:
              "CLICK the 'Summarize' button to complete the scenario. An observation popup will appear detailing what we learned.",
          observation:
              'Weathering breaks down large rocks into smaller sediments. Physical weathering (temperature, ice, roots) changes size/shape. Chemical weathering (oxidation) creates new substances.',
        ),
      ],
    ),
    LabScenarioData(
      title: "The River's Journey: How Erosion Shapes the Land",
      objective:
          'To demonstrate how moving water and wind act as agents of erosion, transporting weathered materials and changing the landscape.',
      steps: [
        LabStep(
          concept: 'River Erosion',
          action:
              "The scene shows a fast-flowing mountain river filled with sharp, jagged rocks. CLICK and DRAG the 'Flow Speed' slider to the right to increase the river's speed.",
          observation:
              'Erosion is the process of moving weathered rock and soil. Flowing water is a powerful agent of erosion, carrying large, jagged rocks downhill.',
        ),
        LabStep(
          concept: 'Abrasion and Smoothing',
          action: 'Observe the rocks as they travel further down the river.',
          observation:
              'As rocks tumble in the river, they collide with each other and the riverbed. This physical wear and tear (abrasion) makes them smaller, smoother, and rounder, producing sand.',
        ),
        LabStep(
          concept: 'Deposition in the Lake',
          action:
              'The river now flows into a wide, calm lake. Observe what happens to the sand being carried by the water.',
          observation:
              'When the river enters a lake or ocean, the water slows down. It loses energy and drops its sediment load. This settling process is called deposition.',
        ),
        LabStep(
          concept: 'Wind Erosion',
          action: "DRAG the 'Wind' icon and DROP it over the sandy riverbank next to the lake.",
          observation:
              'Wind also transports fine sediments like sand, often creating landforms like sand dunes.',
        ),
        LabStep(
          concept: 'Summary of Erosion',
          action: "CLICK the 'Summarize' button.",
          observation:
              'Erosion (by water and wind) moves weathered material from one place to another. Deposition occurs when these agents lose energy and drop the material, forming new landforms.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'द रॉक ब्रेकर्स',
      objective:
          'यह जांचने के लिए कि प्राकृतिक बल कैसे भौतिक और रासायनिक अपक्षय का कारण बनते हैं, जिससे बड़ी चट्टानें छोटे तलछट में टूट जाती हैं।',
      steps: [
        LabStep(
          concept: 'तापमान में परिवर्तन',
          action:
              "'सूर्य' आइकन को खींचें और बड़ी चट्टान पर छोड़ दें। फिर, 'बर्फ' आइकन को खींचें और उसी चट्टान पर छोड़ दें। इस चक्र को तीन बार दोहराएं।",
          observation:
              'चट्टान की सतह पर स्पष्ट रूप से छोटी दरारें विकसित होती हैं। हीटिंग (सूरज) और कूलिंग (बर्फ के टुकड़े) के हर चक्र के साथ, दरारें चौड़ी हो जाती हैं, और चट्टान के छोटे टुकड़े टूट कर गिर जाते हैं।',
        ),
        LabStep(
          concept: 'आइस वेजिंग (बर्फ का जमना)',
          action:
              "क्लिफ की सबसे बड़ी दरार पर 'बादल' आइकन खींचें और छोड़ें। फिर, उसी पानी से भरी दरार पर 'बर्फ' आइकन खींचें और छोड़ें।",
          observation:
              'बादल से पानी दरार को भर देता है। जब बर्फ का टुकड़ा लगाया जाता है, तो पानी बर्फ में बदल जाता है, जो स्पष्ट रूप से फैलता है और चट्टान के एक बड़े टुकड़े को तोड़कर गिरा देता है।',
        ),
        LabStep(
          concept: 'जैविक अपक्षय',
          action:
              "'पौधा' आइकन को खींचें और चट्टान के शीर्ष के पास एक दरार में छोड़ दें। फिर, 'टाइम-लैप्स' स्लाइडर को बाएं से दाएं खींचें।",
          observation:
              'पौधा दरार में रखा गया है। जैसे ही स्लाइडर चलता है, पौधा एक बड़े पेड़ में विकसित हो जाता है, और इसकी जड़ें दरार के भीतर स्पष्ट रूप से बड़ी होती दिखाई देती हैं, जिससे चट्टान तब तक अलग होती है जब तक कि दूसरा टुकड़ा न टूट जाए।',
        ),
        LabStep(
          concept: 'रासायनिक अपक्षय',
          action:
              "चट्टान के अंधेरे हिस्से पर ध्यान दें। 'बादल' आइकन खींचें और इस काली चट्टान पर छोड़ दें। अब, 'टाइम-लैप्स' स्लाइडर को बाएं से दाएं खींचें।",
          observation:
              'बारिश से भीगने के बाद, जैसे ही टाइम-लैप्स स्लाइडर को ले जाया जाता है, काली चट्टान की सतह धीरे-धीरे लाल-भूरे रंग में बदल जाती है, जो एक रासायनिक परिवर्तन का संकेत देती है।',
        ),
        LabStep(
          concept: 'सारांश',
          action:
              "परिदृश्य को पूरा करने के लिए 'संक्षेप करें' बटन पर क्लिक करें। हमने जो सीखा उसका विवरण देते हुए एक अवलोकन पॉपअप दिखाई देगा।",
          observation:
              'अपक्षय बड़ी चट्टानों को छोटे तलछट में तोड़ देता है। भौतिक अपक्षय (तापमान, बर्फ, जड़ें) आकार/आकृति को बदलता है। रासायनिक अपक्षय (ऑक्सीकरण) नए पदार्थ बनाता है।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'नदी की यात्रा: अपरदन भूमि को कैसे आकार देता है',
      objective:
          'यह प्रदर्शित करने के लिए कि कैसे बहता पानी और हवा अपरदन के एजेंट के रूप में कार्य करते हैं, अपक्षयित सामग्री को ले जाते हैं और परिदृश्य को बदलते हैं।',
      steps: [
        LabStep(
          concept: 'नदी का अपरदन',
          action:
              "यह दृश्य तेज बहने वाली पहाड़ी नदी को दर्शाता है जो तेज, नुकीली चट्टानों से भरी है। नदी की गति बढ़ाने के लिए 'प्रवाह गति' स्लाइडर को दाईं ओर खींचें।",
          observation:
              'अपरदन अपक्षयित चट्टान और मिट्टी को ले जाने की प्रक्रिया है। बहता पानी अपरदन का एक शक्तिशाली एजेंट है, जो बड़ी, नुकीली चट्टानों को नीचे की ओर ले जाता है।',
        ),
        LabStep(
          concept: 'घर्षण और चिकना होना',
          action: 'चट्टानों को देखें जैसे वे नदी के नीचे यात्रा करते हैं।',
          observation:
              'जैसे-जैसे चट्टानें नदी में लुढ़कती हैं, वे एक-दूसरे से और नदी के तल से टकराती हैं। यह भौतिक टूट-फूट (घर्षण) उन्हें छोटा, चिकना और गोल बनाता है, जिससे रेत का उत्पादन होता है।',
        ),
        LabStep(
          concept: 'झील में निक्षेपण',
          action: 'नदी अब एक विस्तृत, शांत झील में बहती है। देखें कि पानी द्वारा ले जाई जा रही रेत का क्या होता है।',
          observation:
              'जब नदी झील या समुद्र में प्रवेश करती है, तो पानी धीमा हो जाता है। यह ऊर्जा खो देता है और अपना तलछट भार गिरा देता है। इस बसने की प्रक्रिया को निक्षेपण कहा जाता है।',
        ),
        LabStep(
          concept: 'वायु अपरदन',
          action: "झील के बगल में रेतीले नदी के किनारे पर 'हवा' आइकन खींचें और छोड़ें।",
          observation: 'हवा रेत जैसे महीन तलछट को भी ले जाती है, जिससे अक्सर रेत के टीले जैसी भू-आकृतियां बनती हैं।',
        ),
        LabStep(
          concept: 'अपरदन का सारांश',
          action: "'संक्षेप करें' बटन पर क्लिक करें।",
          observation:
              'अपरदन (पानी और हवा द्वारा) अपक्षयित सामग्री को एक स्थान से दूसरे स्थान पर ले जाता है। निक्षेपण तब होता है जब ये एजेंट ऊर्जा खो देते हैं और सामग्री को गिरा देते हैं, जिससे नई भू-आकृतियां बनती हैं।',
        ),
      ],
    ),
  ],
};

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);

/// Tray items (HTML `data-type`). `cloudChem` is the rain cloud of S1 step 4.
enum _Item { sun, snowflake, cloud, cloudChem, sapling, wind }

/// An S1 camera view: world centre and visible width (SVG viewBox units).
class _View {
  const _View(this.cx, this.cy, this.w);
  final double cx, cy, w;
}

// HTML `viewTarget2D` per step, adapted so every object of the step fits.
// The scene sits a little high so the bottom HUD covers ground, not rock.
const _View _viewOverview = _View(1235, 345, 2700);
const _View _viewThermal = _View(400, 330, 900); // viewTarget2DPan
const _View _viewIce = _View(900, 330, 900);
const _View _viewBio = _View(1500, 240, 1150);
const _View _viewChem = _View(2100, 330, 900);

/// S2 camera per step (HTML `viewTarget2D` pans the isometric camera
/// downstream): a screen-space shift in design px that brings the step's
/// focus (river, lake mouth, sandy banks) above the bottom HUD.
const List<Offset> _riverShift = [
  Offset(0, 0),
  Offset(-77, -109),
  Offset(-108, -138),
  Offset(-185, -122),
  Offset(0, 0),
];

/// A scene label (HTML `addLabel2D`) keyed by its i18n key, in world units.
class _Label2D {
  const _Label2D(this.key, this.x, this.y);
  final String key;
  final double x, y;
}

/// Falling rock crumbs (HTML `spawn2DParticles`), in design space.
class _Crumb {
  _Crumb(this.x, this.y, this.dx, this.rot, this.start);
  final double x, y, dx, rot, start;
}

/// One rock carried by the river (HTML `rocks3D`).
class _Rock {
  _Rock({
    required this.progress,
    required this.offsetX,
    required this.offsetZ,
    required this.rotSpeedX,
    required this.rotSpeedZ,
    required this.radii,
  });
  double progress;
  bool isSmooth = false;
  bool visible = true;
  final double offsetX, offsetZ, rotSpeedX, rotSpeedZ;
  double rotX = 0, rotZ = 0;
  final List<double> radii;
  double x = 0, y = 0, z = 0;
}

/// Suspended sand grain (HTML `sandSuspensionGroup` child).
class _Sand {
  bool visible = false;
  double progress = 0, offsetZ = 0;
  double x = 0, y = 0, z = 0;
}

/// Wind streak sweeping over the sandy bank (HTML `playWindAnimation3D`).
class _WindLine {
  _WindLine(this.x, this.y, this.z, this.speed);
  double x, y, z;
  final double speed;
}

/// "COLLIDE! CHIP!" pop-up label shown for one second.
class _Chip {
  _Chip(this.x, this.y, this.z, this.start);
  final double x, y, z, start;
}

/// Mutable state read by the painters every frame.
class _WeatherScene {
  double time = 0;
  int scenario = 0;
  int stepIdx = 0;

  // ---- Scenario 1 (2D cliff) ----
  double camX = _viewOverview.cx, camY = _viewOverview.cy, camW = _viewOverview.w;
  _View target = _viewOverview;

  int cycleCount = 0;
  int sunPhase = 0;
  double crackWidth = 1.5, crackWidthTarget = 1.5;
  double glowRedStart = -10, glowBlueStart = -10;
  bool crackWaterFilled = false, crackIceFilled = false;
  double waterOpacity = 0, iceMix = 0;
  double iceFallStart = -1;
  bool hasSapling = false;
  double treeScale = 0, treeScaleTarget = 0;
  double timeLapse = 0;
  bool chunk3Falling = false;
  double bioFallStart = -1;
  bool rockWet = false;
  double wetOpacity = 0;
  int chemProgress = 0;
  double chemMix = 0;
  final List<_Label2D> labels = [];
  final List<_Crumb> crumbs = [];

  // ---- Scenario 2 (3D river diorama) ----
  double flowSpeed = 0;
  Offset camShift = Offset.zero, camShiftTarget = Offset.zero;
  double waterScroll = 0, lakeScroll = 0;
  final List<_Rock> rocks = [];
  final List<_Sand> sand = List.generate(60, (_) => _Sand());
  double sandAccumulation = 0;
  double deltaScale = 0.001;
  bool windErosionDone = false;
  double duneRise = 0;
  final List<_WindLine> wind = [];
  final List<_Chip> chips = [];

  // ---- Drag feedback ----
  _Item? dragging;

  void resetCliff() {
    camX = _viewOverview.cx;
    camY = _viewOverview.cy;
    camW = _viewOverview.w;
    target = _viewOverview;
    cycleCount = 0;
    sunPhase = 0;
    crackWidth = crackWidthTarget = 1.5;
    glowRedStart = glowBlueStart = -10;
    crackWaterFilled = crackIceFilled = false;
    waterOpacity = iceMix = 0;
    iceFallStart = -1;
    hasSapling = false;
    treeScale = treeScaleTarget = 0;
    timeLapse = 0;
    chunk3Falling = false;
    bioFallStart = -1;
    rockWet = false;
    wetOpacity = 0;
    chemProgress = 0;
    chemMix = 0;
    labels.clear();
    crumbs.clear();
  }

  void resetRiver(math.Random rnd) {
    flowSpeed = 0;
    camShift = camShiftTarget = Offset.zero;
    waterScroll = lakeScroll = 0;
    sandAccumulation = 0;
    deltaScale = 0.001;
    windErosionDone = false;
    duneRise = 0;
    wind.clear();
    chips.clear();
    for (final s in sand) {
      s.visible = false;
    }
    rocks
      ..clear()
      ..addAll(List.generate(8, (_) {
        final r = _Rock(
          progress: rnd.nextDouble() * 0.3,
          offsetX: (rnd.nextDouble() - 0.5) * 1.5,
          offsetZ: (rnd.nextDouble() - 0.5) * 1.5,
          rotSpeedX: rnd.nextDouble() * 0.2 - 0.1,
          rotSpeedZ: rnd.nextDouble() * 0.2 - 0.1,
          radii: List.generate(9, (_) => 0.78 + rnd.nextDouble() * 0.4),
        );
        _placeOnCurve(r);
        return r;
      }));
  }

  /// Positions a rock on the river path (the HTML only did this once the
  /// river flowed; doing it at setup keeps the rocks in the river).
  void _placeOnCurve(_Rock r) {
    final p = _riverPoint(math.min(1, r.progress));
    r
      ..x = p.$1 + r.offsetX
      ..y = p.$2
      ..z = p.$3 + r.offsetZ;
  }
}

// HTML `riverCurve` (CatmullRomCurve3) control points.
const List<(double, double, double)> _riverPts = [
  (-5.5, 1.8, 0),
  (-4, 1.5, 0),
  (-2, 1.2, 0),
  (0, 0.9, 0),
  (3.5, -0.1, 0),
];

List<(double, double, double)>? _riverTable;

/// Point on the river curve at arc-length fraction [u] (like `getPointAt`).
(double, double, double) _riverPoint(double u) {
  final table = _riverTable ??= _buildRiverTable();
  final f = u.clamp(0.0, 1.0) * (table.length - 1);
  final i = f.floor().clamp(0, table.length - 2);
  final t = f - i;
  final a = table[i], b = table[i + 1];
  return (a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t, a.$3 + (b.$3 - a.$3) * t);
}

/// Samples the centripetal-free (uniform) Catmull-Rom curve and
/// re-parameterises it by arc length, as Three.js `getPointAt` does.
List<(double, double, double)> _buildRiverTable() {
  final raw = <(double, double, double)>[];
  final n = _riverPts.length;
  (double, double, double) cr(double t) {
    final p = (n - 1) * t;
    var i = p.floor();
    var w = p - i;
    if (i >= n - 1) {
      i = n - 2;
      w = 1;
    }
    (double, double, double) pt(int k) {
      if (k < 0) {
        final a = _riverPts[0], b = _riverPts[1];
        return (2 * a.$1 - b.$1, 2 * a.$2 - b.$2, 2 * a.$3 - b.$3);
      }
      if (k > n - 1) {
        final a = _riverPts[n - 1], b = _riverPts[n - 2];
        return (2 * a.$1 - b.$1, 2 * a.$2 - b.$2, 2 * a.$3 - b.$3);
      }
      return _riverPts[k];
    }

    final p0 = pt(i - 1), p1 = pt(i), p2 = pt(i + 1), p3 = pt(i + 2);
    double c(double a, double b, double cc, double d) {
      final v0 = (cc - a) * 0.5, v1 = (d - b) * 0.5;
      final t2 = w * w, t3 = w * t2;
      return (2 * b - 2 * cc + v0 + v1) * t3 + (-3 * b + 3 * cc - 2 * v0 - v1) * t2 + v0 * w + b;
    }

    return (c(p0.$1, p1.$1, p2.$1, p3.$1), c(p0.$2, p1.$2, p2.$2, p3.$2), c(p0.$3, p1.$3, p2.$3, p3.$3));
  }

  for (var k = 0; k <= 400; k++) {
    raw.add(cr(k / 400));
  }
  final lens = <double>[0];
  for (var k = 1; k < raw.length; k++) {
    final a = raw[k - 1], b = raw[k];
    lens.add(lens.last +
        math.sqrt(math.pow(b.$1 - a.$1, 2) + math.pow(b.$2 - a.$2, 2) + math.pow(b.$3 - a.$3, 2)));
  }
  final total = lens.last;
  final out = <(double, double, double)>[];
  var j = 0;
  for (var k = 0; k <= 200; k++) {
    final target = total * k / 200;
    while (j < lens.length - 2 && lens[j + 1] < target) {
      j++;
    }
    final seg = lens[j + 1] - lens[j];
    final t = seg <= 0 ? 0.0 : ((target - lens[j]) / seg).clamp(0.0, 1.0);
    final a = raw[j], b = raw[j + 1];
    out.add((a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t, a.$3 + (b.$3 - a.$3) * t));
  }
  return out;
}

/// Exponential approach used for CSS transitions (reaches ~95% in [dur]).
double _approach(double cur, double target, double dt, double dur) {
  if (dur <= 0) return target;
  final k = 1 - math.exp(-3 * dt / dur);
  return cur + (target - cur) * k;
}

/// Linear blend of two colours (HTML `lerpColor`).
Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t.clamp(0.0, 1.0))!;

/// Callout label like the HTML `.svg-label` / 3D labels: white box, black
/// border, hard black shadow and a pointer. With [pointerBelow] the tip sits
/// at [tip]; otherwise the box is centred on [tip] with the pointer hanging
/// below it (3D labels).
void _callout(
  Canvas canvas,
  String text,
  Offset tip, {
  double size = 14,
  Color textColor = Colors.black,
  bool pointerBelow = true,
  double opacity = 1,
  double lift = 0,
}) {
  if (opacity <= 0) return;
  // Lines are laid out one by one so the HTML "↓" and "💥" lines can be
  // drawn as vector icons (they do not depend on symbol / emoji fonts).
  final lines = <({TextPainter? tp, String icon, double w, double h})>[];
  for (final line in text.split('\n')) {
    final trimmed = line.trim();
    if (trimmed == '↓' || trimmed == '💥') {
      lines.add((tp: null, icon: trimmed, w: size * 1.2, h: size * 1.3));
      continue;
    }
    final tp = TextPainter(
      text: TextSpan(
        text: line,
        style: TextStyle(
          fontSize: size,
          color: textColor.withValues(alpha: opacity),
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    lines.add((tp: tp, icon: '', w: tp.width, h: tp.height));
  }
  final contentW = lines.fold(0.0, (m, l) => math.max(m, l.w));
  final contentH = lines.fold(0.0, (m, l) => m + l.h);
  final padX = size * 0.75, padY = size * 0.4;
  final w = contentW + padX * 2, h = contentH + padY * 2;
  final ptrH = size * 0.7;
  final Rect box = pointerBelow
      ? Rect.fromLTWH(tip.dx - w / 2, tip.dy - ptrH - h - lift, w, h)
      : Rect.fromCenter(center: tip, width: w, height: h);
  final rr = RRect.fromRectAndRadius(box, Radius.circular(size * 0.42));
  final black = Colors.black.withValues(alpha: opacity);
  final shadowOff = Offset(size * 0.2, size * 0.2);
  final ptrTop = box.bottom - 1 + lift;
  final ptr = Path()
    ..moveTo(box.center.dx - ptrH * 0.85, ptrTop)
    ..lineTo(box.center.dx + ptrH * 0.85, ptrTop)
    ..lineTo(box.center.dx, ptrTop + ptrH + 1)
    ..close();
  if (lift > 0) {
    // Raised callout: a stem joins the box to its pointer.
    canvas.drawLine(
      Offset(box.center.dx, box.bottom),
      Offset(box.center.dx, ptrTop + 1),
      Paint()
        ..strokeWidth = size * 0.16
        ..color = Colors.black.withValues(alpha: opacity),
    );
  }
  canvas.drawRRect(rr.shift(shadowOff), Paint()..color = black);
  canvas.drawRRect(rr, Paint()..color = Colors.white.withValues(alpha: opacity));
  canvas.drawRRect(
    rr,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.14
      ..color = black,
  );
  canvas.drawPath(ptr, Paint()..color = black);
  var y = box.top + padY;
  for (final l in lines) {
    final cx = box.center.dx;
    if (l.tp != null) {
      l.tp!.paint(canvas, Offset(cx - l.w / 2, y));
    } else if (l.icon == '↓') {
      labArrow(
        canvas,
        Offset(cx, y + l.h * 0.12),
        Offset(cx, y + l.h * 0.88),
        color: textColor.withValues(alpha: opacity),
        width: size * 0.16,
        head: size * 0.5,
      );
    } else {
      _burst(canvas, Offset(cx, y + l.h / 2), l.h * 0.48, opacity);
    }
    y += l.h;
  }
}

/// The "💥" collision burst: a jagged orange star with a yellow core.
void _burst(Canvas canvas, Offset c, double r, double opacity) {
  Path star(double outer, double inner) {
    final p = Path();
    for (var i = 0; i < 20; i++) {
      final a = -math.pi / 2 + i * math.pi / 10;
      final rr = i.isEven ? outer : inner;
      final pt = c + Offset(math.cos(a), math.sin(a)) * rr;
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    return p..close();
  }

  final outer = star(r, r * 0.55);
  canvas.drawPath(outer, Paint()..color = const Color(0xFFF97316).withValues(alpha: opacity));
  canvas.drawPath(
    outer,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.09
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFDC2626).withValues(alpha: opacity),
  );
  canvas.drawPath(star(r * 0.55, r * 0.32), Paint()..color = const Color(0xFFFDE047).withValues(alpha: opacity));
}

// ============================================================ S1: 2D CLIFF

/// Paints the HTML `#svg-layer` cliff (viewBox 2400x600) through a virtual
/// camera that eases between the per-step views.
class _CliffPainter extends CustomPainter {
  _CliffPainter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.uiScale,
  }) : super(repaint: repaint);

  final _WeatherScene scene;
  final bool showLabels;
  final LabLang lang;

  /// Enlarges labels when the stage is shown small (phones).
  final double uiScale;

  static const _ink = Color(0xFF0F172A);
  static const _rock = Color(0xFF64748B);
  static const _grass = Color(0xFF4ADE80);
  static const _dark = Color(0xFF1E293B);

  late double _k;

  Offset _w2d(double x, double y) =>
      Offset(500 + (x - scene.camX) * _k, 280 + (y - scene.camY) * _k);

  @override
  void paint(Canvas canvas, Size size) {
    _k = size.width / scene.camW;
    final b = labBleed(size);
    // Bleed rect in world units.
    final wb = Rect.fromLTRB(
      scene.camX + (b.left - 500) / _k,
      scene.camY + (b.top - 280) / _k,
      scene.camX + (b.right - 500) / _k,
      scene.camY + (b.bottom - 280) / _k,
    );

    canvas.save();
    canvas.translate(500, 280);
    canvas.scale(_k);
    canvas.translate(-scene.camX, -scene.camY);
    _paintBackdrop(canvas, wb);
    _paintZone1(canvas, wb);
    _paintZone2(canvas);
    _paintZone3(canvas);
    _paintZone4(canvas);
    _paintDropHint(canvas);
    canvas.restore();

    _paintCrumbs(canvas);
    if (showLabels) _paintLabels(canvas);
  }

  // ---------------------------------------------------------------- helpers

  /// Rock face with a soft vertical gradient (lit from above), faint strata
  /// and speckles, and an ink outline.
  void _rockFill(Canvas canvas, Path path, Color color, double stroke, {double opacity = 1}) {
    final bounds = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(color, 0.1).withValues(alpha: opacity),
            labShade(color, -0.18).withValues(alpha: opacity),
          ],
        ).createShader(Rect.fromLTRB(bounds.left, 180, bounds.right, 460)),
    );
    if (bounds.width < 4000) {
      canvas.save();
      canvas.clipPath(path);
      final rnd = math.Random(bounds.left.round() * 31 + bounds.top.round());
      final strata = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.07 * opacity);
      for (var y = bounds.top + 40; y < bounds.bottom; y += 38 + rnd.nextDouble() * 18) {
        final tilt = (rnd.nextDouble() - 0.5) * 16;
        canvas.drawPath(
          Path()
            ..moveTo(bounds.left, y)
            ..quadraticBezierTo(bounds.center.dx, y + tilt, bounds.right, y - tilt * 0.5),
          strata,
        );
      }
      final speck = Paint()..color = Colors.white.withValues(alpha: 0.07 * opacity);
      final n = (bounds.width * bounds.height / 2600).clamp(4, 60).round();
      for (var i = 0; i < n; i++) {
        canvas.drawCircle(
          Offset(bounds.left + rnd.nextDouble() * bounds.width, bounds.top + rnd.nextDouble() * bounds.height),
          1.5 + rnd.nextDouble() * 3,
          speck,
        );
      }
      canvas.restore();
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round
        ..color = _ink.withValues(alpha: opacity),
    );
  }

  Path _poly(List<double> pts, {double dx = 0}) {
    final p = Path()..moveTo(pts[0] + dx, pts[1]);
    for (var i = 2; i < pts.length; i += 2) {
      p.lineTo(pts[i] + dx, pts[i + 1]);
    }
    return p..close();
  }

  /// Glow pulse: fades in for 0.5 s, then out for 0.5 s (HTML opacity
  /// transitions on `svg-thermal-glow`).
  double _pulse(double start) {
    final e = scene.time - start;
    if (e < 0 || e > 1) return 0;
    return e < 0.5
        ? Curves.ease.transform(e / 0.5)
        : 1 - Curves.ease.transform((e - 0.5) / 0.5);
  }

  /// CSS `transition-transform duration-700` progress of a falling chunk.
  double _fall(double start) {
    if (start < 0) return 0;
    return Curves.ease.transform(((scene.time - start) / 0.7).clamp(0.0, 1.0));
  }

  // --------------------------------------------------------------- backdrop

  void _paintBackdrop(Canvas canvas, Rect wb) {
    canvas.drawRect(
      Rect.fromLTRB(wb.left, wb.top, wb.right, 460),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFFE0F2FE)],
        ).createShader(const Rect.fromLTRB(0, -420, 10, 170)),
    );
    // Clouds.
    final cloudFill = Paint()..color = Colors.white;
    final cloudLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFCBD5E1);
    for (final c in const [
      [100.0, 100.0, 120.0, 0.0],
      [700.0, 80.0, 100.0, 0.0],
      [1300.0, 120.0, 140.0, 0.0],
      [1900.0, 90.0, 110.0, 0.0],
    ]) {
      final x = c[0], y = c[1], base = c[2];
      final p = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x + 50, y - 50, x + 100, y)
        ..quadraticBezierTo(x + 150, y - 20, x + 180, base)
        ..lineTo(x, base)
        ..close();
      canvas.drawPath(p, cloudFill);
      canvas.drawPath(p, cloudLine);
    }
    // Ground (rect y 450..600, extended).
    final ground = Rect.fromLTRB(wb.left, 450, wb.right, math.max(wb.bottom, 700));
    canvas.drawRect(
      ground,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF57534E), Color(0xFF44403C)],
        ).createShader(const Rect.fromLTRB(0, 450, 10, 700)),
    );
    canvas.drawLine(
      Offset(wb.left, 450),
      Offset(wb.right, 450),
      Paint()
        ..strokeWidth = 4
        ..color = const Color(0xFF1C1917),
    );
    // Boulders at the foot of the cliff.
    final boulders = [
      ([150.0, 550.0, 200.0, 430.0, 300.0, 460.0, 280.0, 550.0], _rock),
      ([350.0, 580.0, 400.0, 440.0, 500.0, 450.0, 480.0, 580.0], const Color(0xFF475569)),
      ([950.0, 520.0, 1000.0, 430.0, 1100.0, 440.0, 1050.0, 520.0], _rock),
      ([1450.0, 550.0, 1500.0, 440.0, 1550.0, 460.0, 1520.0, 550.0], const Color(0xFF475569)),
    ];
    for (final bd in boulders) {
      _rockFill(canvas, _poly(bd.$1), bd.$2, 3);
    }
    // Far cliff band (light grey) behind the zones.
    final band = Path()..addRect(Rect.fromLTRB(wb.left, 180, wb.right, 450));
    canvas.drawPath(band, Paint()..color = const Color(0xFF94A3B8));
    final edge = Paint()
      ..strokeWidth = 4
      ..color = _ink;
    canvas.drawLine(Offset(wb.left, 180), Offset(wb.right, 180), edge);
    canvas.drawLine(Offset(wb.left, 450), Offset(wb.right, 450), edge);
  }

  // ------------------------------------------------------------------ zones

  /// Zone 1: thermal cracking (sun / snowflake cycles).
  void _paintZone1(Canvas canvas, Rect wb) {
    final left = math.min(-100.0, wb.left);
    _rockFill(canvas, _poly([left, 180, 400, 180, 450, 450, left, 450]), _rock, 3);
    canvas.drawPath(_poly([left, 180, 400, 180, 390, 200, left, 200]), Paint()..color = _grass);

    void glow(Color c, double v) {
      if (v <= 0) return;
      const center = Offset(200, 300);
      canvas.drawCircle(
        center,
        150,
        Paint()
          ..shader = RadialGradient(colors: [
            c.withValues(alpha: 0.8 * v),
            c.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: center, radius: 150)),
      );
    }

    glow(const Color(0xFFEF4444), _pulse(scene.glowRedStart));
    glow(const Color(0xFF3B82F6), _pulse(scene.glowBlueStart));

    final cracks = Path()
      ..moveTo(150, 180)
      ..quadraticBezierTo(170, 250, 130, 350)
      ..moveTo(230, 180)
      ..quadraticBezierTo(200, 280, 250, 400)
      ..moveTo(100, 180)
      ..lineTo(90, 250);
    canvas.drawPath(
      cracks,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = scene.crackWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _ink,
    );
  }

  /// Zone 2: ice wedging (rain cloud fills the crack, snowflake freezes it).
  void _paintZone2(Canvas canvas) {
    canvas.save();
    canvas.translate(600, 0);
    _rockFill(canvas, _poly([-200, 180, 250, 180, 250, 450, -200, 450]), _rock, 3);
    canvas.drawPath(_poly([-200, 180, 250, 180, 250, 200, -200, 200]), Paint()..color = _grass);
    final crack = _poly([250, 180, 300, 180, 270, 350, 250, 400]);
    canvas.drawPath(crack, Paint()..color = _dark);
    canvas.drawPath(
      crack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _ink,
    );
    if (scene.waterOpacity > 0.01) {
      final water = _poly([250, 200, 290, 200, 270, 350, 250, 380]);
      final c = _mix(const Color(0xFF3B82F6), const Color(0xFFF8FAFC), scene.iceMix);
      canvas.drawPath(water, Paint()..color = c.withValues(alpha: scene.waterOpacity));
      // Ice crystals glint once frozen.
      if (scene.iceMix > 0.5) {
        final glint = Paint()
          ..strokeWidth = 1.5
          ..color = const Color(0xFF93C5FD).withValues(alpha: (scene.iceMix - 0.5) * 2);
        canvas.drawLine(const Offset(256, 230), const Offset(276, 260), glint);
        canvas.drawLine(const Offset(254, 290), const Offset(270, 320), glint);
      }
    }
    // Falling chunk: translate(30,120) rotate(15deg) about (300,400).
    final p = _fall(scene.iceFallStart);
    canvas.save();
    canvas.translate(300 + 30 * p, 400 + 120 * p);
    canvas.rotate(15 * p * math.pi / 180);
    canvas.translate(-300, -400);
    _rockFill(canvas, _poly([300, 180, 480, 180, 480, 450, 250, 450, 270, 350]), _rock, 3);
    canvas.drawPath(_poly([300, 180, 480, 180, 480, 200, 300, 200]), Paint()..color = _grass);
    canvas.restore();
    canvas.restore();
  }

  /// Zone 3: biological weathering (sapling grows, roots split the rock).
  void _paintZone3(Canvas canvas) {
    canvas.save();
    canvas.translate(1200, 0);
    _rockFill(canvas, _poly([-120, 180, 250, 180, 250, 450, -120, 450]), _rock, 3);
    canvas.drawPath(_poly([-120, 180, 250, 180, 250, 200, -120, 200]), Paint()..color = _grass);
    final crack = _poly([250, 180, 280, 180, 280, 450, 250, 450]);
    canvas.drawPath(crack, Paint()..color = _dark);
    canvas.drawPath(
      crack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _ink,
    );
    // Falling chunk: translate(40,120) rotate(20deg) about (280,450).
    final p = _fall(scene.bioFallStart);
    canvas.save();
    canvas.translate(280 + 40 * p, 450 + 120 * p);
    canvas.rotate(20 * p * math.pi / 180);
    canvas.translate(-280, -450);
    _rockFill(canvas, _poly([280, 180, 480, 180, 480, 450, 280, 450]), _rock, 3);
    canvas.drawPath(_poly([280, 180, 480, 180, 480, 200, 280, 200]), Paint()..color = _grass);
    canvas.restore();

    // Tree group, scaled about (265,180).
    final s = scene.treeScale;
    if (s > 0.005) {
      canvas.save();
      canvas.translate(265, 180);
      canvas.scale(s);
      canvas.translate(-265, -180);
      final roots = Path()
        ..moveTo(265, 180)
        ..quadraticBezierTo(255, 280, 255, 380)
        ..moveTo(265, 180)
        ..quadraticBezierTo(275, 280, 275, 380);
      canvas.drawPath(
        roots,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4 + scene.timeLapse / 10
          ..color = const Color(0xFF78350F),
      );
      const trunk = Rect.fromLTWH(255, 30, 20, 150);
      canvas.drawRect(
        trunk,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF92400E), Color(0xFF78350F), Color(0xFF5B2A0C)],
          ).createShader(trunk),
      );
      canvas.drawRect(
        trunk,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF431407),
      );
      for (final c in const [(265.0, 10.0, 60.0), (225.0, 50.0, 40.0), (305.0, 50.0, 40.0)]) {
        final center = Offset(c.$1, c.$2);
        canvas.drawCircle(
          center,
          c.$3,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.35, -0.4),
              colors: const [Color(0xFF4ADE80), Color(0xFF22C55E), Color(0xFF16A34A)],
              stops: const [0, 0.55, 1],
            ).createShader(Rect.fromCircle(center: center, radius: c.$3)),
        );
        canvas.drawCircle(
          center,
          c.$3,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFF14532D),
        );
      }
      canvas.restore();
    }
    canvas.restore();
  }

  /// Zone 4: chemical weathering (wet basalt oxidises from black to red).
  void _paintZone4(Canvas canvas) {
    canvas.save();
    canvas.translate(1800, 0);
    _rockFill(canvas, _poly([-120, 180, 100, 180, 100, 450, -120, 450]), _rock, 3);
    canvas.drawPath(_poly([-120, 180, 100, 180, 100, 200, -120, 200]), Paint()..color = _grass);
    final chem = _poly([100, 180, 450, 180, 470, 450, 100, 450]);
    final c = _mix(_dark, const Color(0xFF9A3412), scene.chemMix);
    _rockFill(canvas, chem, c, 4);
    // Rust speckles appear as the oxidation progresses.
    if (scene.chemMix > 0.05) {
      final rnd = math.Random(11);
      final speck = Paint()..color = const Color(0xFFC2410C).withValues(alpha: 0.55 * scene.chemMix);
      for (var i = 0; i < 40; i++) {
        final x = 115 + rnd.nextDouble() * 330;
        final y = 210 + rnd.nextDouble() * 230;
        canvas.drawCircle(Offset(x, y), 2 + rnd.nextDouble() * 5, speck);
      }
    }
    canvas.drawPath(_poly([100, 180, 450, 180, 440, 200, 100, 200]), Paint()..color = _grass);
    if (scene.wetOpacity > 0.005) {
      canvas.drawPath(chem, Paint()..color = Colors.black.withValues(alpha: scene.wetOpacity));
      // Wet sheen streaks.
      final sheen = Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.25 * scene.wetOpacity / 0.6);
      for (final x in const [150.0, 230.0, 310.0, 390.0]) {
        canvas.drawLine(Offset(x, 215), Offset(x - 8, 300), sheen);
        canvas.drawLine(Offset(x + 20, 320), Offset(x + 14, 380), sheen);
      }
    }
    canvas.restore();
  }

  /// While an item is dragged, highlight the zone the current step expects
  /// (the HTML hitbox rects: 600 units wide, y 100..500).
  void _paintDropHint(Canvas canvas) {
    if (scene.dragging == null || scene.stepIdx > 3) return;
    final x0 = 600.0 * scene.stepIdx;
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(x0 + 12, 110, 576, 380), const Radius.circular(24));
    final pulse = 0.5 + 0.5 * math.sin(scene.time * 5);
    canvas.drawRRect(r, Paint()..color = _Colors.zslYellow.withValues(alpha: 0.06 + 0.06 * pulse));
    labDashedPath(
      canvas,
      Path()..addRRect(r),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _Colors.zslYellow.withValues(alpha: 0.6 + 0.3 * pulse),
      dash: 18,
      gap: 12,
      phase: scene.time * 40,
    );
  }

  // --------------------------------------------------------- overlays

  void _paintCrumbs(Canvas canvas) {
    const curve = Cubic(0.4, 0, 0.8, 1);
    for (final c in scene.crumbs) {
      final e = (scene.time - c.start).clamp(0.0, 1.0);
      final p = curve.transform(e);
      final pos = Offset(c.x + c.dx * p, c.y + 200 * p);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(c.rot * p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -8, 16, 16), const Radius.circular(3)),
        Paint()..color = const Color(0xFF475569).withValues(alpha: 1 - p),
      );
      canvas.restore();
    }
  }

  void _paintLabels(Canvas canvas) {
    final summary = scene.stepIdx >= 4;
    for (final l in scene.labels) {
      // In the summary view only the four summary callouts are shown, so
      // the overview is not buried under every step's labels.
      if (summary && !l.key.startsWith('s1Sum')) continue;
      // Summary callouts 2 and 4 are raised so neighbours never overlap.
      final lift = l.key == 's1Sum2' || l.key == 's1Sum4' ? 14 * uiScale * 3.6 : 0.0;
      _callout(canvas, labTr(_i18n, lang, l.key), _w2d(l.x, l.y), size: 14 * uiScale, lift: lift);
    }
  }

  @override
  bool shouldRepaint(covariant _CliffPainter old) =>
      old.showLabels != showLabels || old.lang != lang || old.uiScale != uiScale;
}

// ============================================================ S2: 3D RIVER

typedef _V3 = (double, double, double);

/// Water texture streaks (HTML canvas texture: 60 light-blue dashes).
final List<(double, double, double, double)> _streaks = () {
  final rnd = math.Random(3);
  return List.generate(60, (_) {
    return (
      rnd.nextDouble(),
      rnd.nextDouble(),
      (20 + rnd.nextDouble() * 40) / 512,
      (2 + rnd.nextDouble() * 4) / 512,
    );
  });
}();

/// Paints the HTML Three.js isometric river diorama (orthographic camera at
/// (10,10,10) looking at (0,-1,0)) with flat-shaded, black-outlined blocks.
class _RiverPainter extends CustomPainter {
  _RiverPainter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.uiScale,
  }) : super(repaint: repaint);

  final _WeatherScene scene;
  final bool showLabels;
  final LabLang lang;
  final double uiScale;

  static const double _k = 44; // px per world unit
  static const Offset _o = Offset(500, 352); // screen position of the target
  static const _V3 _zc = (0.55814, 0.61396, 0.55814); // towards the camera
  static const _V3 _xc = (0.70711, 0.0, -0.70711); // screen right
  static const _V3 _yc = (-0.43414, 0.78933, -0.43414); // screen up
  static const _V3 _light = (0.40825, 0.8165, 0.40825);
  static const _V3 _upPos = (-2.5, 0, 0);
  static const double _upRot = -0.15;
  static const _V3 _downPos = (3.5, -0.9, 0);

  static const _water = Color(0xFF60A5FA);
  static const _streak = Color(0xFF93C5FD);
  static const _soil = Color(0xFF78350F);

  Offset _p(double x, double y, double z) {
    final rx = x, ry = y + 1, rz = z;
    return Offset(
      _o.dx + scene.camShift.dx + _k * (rx * _xc.$1 + rz * _xc.$3),
      _o.dy + scene.camShift.dy - _k * (rx * _yc.$1 + ry * _yc.$2 + rz * _yc.$3),
    );
  }

  Offset _pv(_V3 v) => _p(v.$1, v.$2, v.$3);

  static double _dot(_V3 a, _V3 b) => a.$1 * b.$1 + a.$2 * b.$2 + a.$3 * b.$3;

  /// Group transform: rotate about Z by [rot], then translate by [pos].
  static _V3 _tf(_V3 l, _V3 pos, double rot) {
    final c = math.cos(rot), s = math.sin(rot);
    return (pos.$1 + l.$1 * c - l.$2 * s, pos.$2 + l.$1 * s + l.$2 * c, pos.$3 + l.$3);
  }

  /// Lambert shading (ambient 0.85 + directional 0.5 like the HTML lights).
  static Color _lit(Color c, _V3 n, {double extra = 1, double opacity = 1}) {
    final i = (0.85 + 0.5 * math.max(0.0, _dot(n, _light))) * extra;
    return Color.from(
      alpha: opacity,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  Paint _edge([double opacity = 1, double w = 1.3]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..color = Colors.black.withValues(alpha: 0.85 * opacity);

  /// Draws the camera-facing faces of a box centred at [c] (group local).
  void _box(
    Canvas canvas,
    _V3 c,
    double w,
    double h,
    double d,
    Color color, {
    _V3 pos = (0, 0, 0),
    double rot = 0,
    double opacity = 1,
  }) {
    final hw = w / 2, hh = h / 2, hd = d / 2;
    _V3 v(double x, double y, double z) => _tf((c.$1 + x, c.$2 + y, c.$3 + z), pos, rot);
    _V3 n(double x, double y, double z) => _tf((x, y, z), (0, 0, 0), rot);
    final faces = <(_V3, List<_V3>, double)>[
      (n(1, 0, 0), [v(hw, -hh, -hd), v(hw, hh, -hd), v(hw, hh, hd), v(hw, -hh, hd)], 0.9),
      (n(-1, 0, 0), [v(-hw, -hh, -hd), v(-hw, -hh, hd), v(-hw, hh, hd), v(-hw, hh, -hd)], 0.9),
      (n(0, 1, 0), [v(-hw, hh, -hd), v(-hw, hh, hd), v(hw, hh, hd), v(hw, hh, -hd)], 1),
      (n(0, -1, 0), [v(-hw, -hh, -hd), v(hw, -hh, -hd), v(hw, -hh, hd), v(-hw, -hh, hd)], 1),
      (n(0, 0, 1), [v(-hw, -hh, hd), v(hw, -hh, hd), v(hw, hh, hd), v(-hw, hh, hd)], 1),
      (n(0, 0, -1), [v(-hw, -hh, -hd), v(-hw, hh, -hd), v(hw, hh, -hd), v(hw, -hh, -hd)], 1),
    ];
    for (final f in faces) {
      if (_dot(f.$1, _zc) <= 0.001) continue;
      final path = Path()..addPolygon(f.$2.map(_pv).toList(), true);
      canvas.drawPath(path, Paint()..color = _lit(color, f.$1, extra: f.$3, opacity: opacity));
      canvas.drawPath(path, _edge(opacity));
    }
  }

  /// HTML `createTerrainBlock`: a soil block with a 0.2 thick coloured top.
  void _terrain(Canvas canvas, _V3 c, double w, double h, double d, Color top, Color side,
      {_V3 pos = (0, 0, 0), double rot = 0}) {
    final sideH = h - 0.2;
    _box(canvas, (c.$1, c.$2 - 0.1, c.$3), w, sideH, d, side, pos: pos, rot: rot);
    _box(canvas, (c.$1, c.$2 + sideH / 2, c.$3), w, 0.2, d, top, pos: pos, rot: rot);
  }

  /// Pyramid (4-segment ConeGeometry): mountains and sand dunes.
  void _pyramid(Canvas canvas, _V3 apex, List<_V3> base, Color color) {
    final bc = (
      base.map((b) => b.$1).reduce((a, b) => a + b) / base.length,
      base.map((b) => b.$2).reduce((a, b) => a + b) / base.length,
      base.map((b) => b.$3).reduce((a, b) => a + b) / base.length,
    );
    for (var i = 0; i < base.length; i++) {
      final a = base[i], b = base[(i + 1) % base.length];
      final e1 = (b.$1 - a.$1, b.$2 - a.$2, b.$3 - a.$3);
      final e2 = (apex.$1 - a.$1, apex.$2 - a.$2, apex.$3 - a.$3);
      var nx = e1.$2 * e2.$3 - e1.$3 * e2.$2;
      var ny = e1.$3 * e2.$1 - e1.$1 * e2.$3;
      var nz = e1.$1 * e2.$2 - e1.$2 * e2.$1;
      final mid = ((a.$1 + b.$1) / 2 - bc.$1, 0.0, (a.$3 + b.$3) / 2 - bc.$3);
      if (nx * mid.$1 + nz * mid.$3 < 0) {
        nx = -nx;
        ny = -ny;
        nz = -nz;
      }
      final len = math.sqrt(nx * nx + ny * ny + nz * nz);
      if (len == 0) continue;
      final nn = (nx / len, ny / len, nz / len);
      if (_dot(nn, _zc) <= 0.001) continue;
      final path = Path()..addPolygon([_pv(a), _pv(b), _pv(apex)], true);
      canvas.drawPath(path, Paint()..color = _lit(color, nn));
      canvas.drawPath(path, _edge());
    }
  }

  /// Textured water surface: [map] turns face UV (0..1) into world points.
  /// Only the V range [v0]..[v1] is drawn (the visible part of the lake).
  void _waterTop(Canvas canvas, _V3 Function(double u, double v) map, double scroll,
      {double v0 = 0, double v1 = 1}) {
    const up = (0.0, 1.0, 0.0);
    final face = Path()..addPolygon([_pv(map(0, v0)), _pv(map(1, v0)), _pv(map(1, v1)), _pv(map(0, v1))], true);
    canvas.drawPath(face, Paint()..color = _lit(_water, up, opacity: 0.85));
    canvas.save();
    canvas.clipPath(face);
    final sp = Paint()
      ..strokeCap = StrokeCap.round
      ..color = _lit(_streak, up, opacity: 0.85);
    for (final s in _streaks) {
      final v = s.$2;
      if (v < v0 || v > v1) continue;
      final u = (s.$1 + scroll) % 1.0;
      final a = _pv(map(u, v)), b = _pv(map(u + s.$3, v));
      final c = _pv(map(u, v + s.$4));
      sp.strokeWidth = math.max(1.4, (c - a).distance);
      canvas.drawLine(a, b, sp);
      if (u + s.$3 > 1) {
        canvas.drawLine(_pv(map(u - 1, v)), _pv(map(u + s.$3 - 1, v)), sp);
      }
    }
    canvas.restore();
    canvas.drawPath(face, _edge(0.6, 1));
  }

  void _waterSide(Canvas canvas, List<_V3> pts, _V3 n) {
    final path = Path()..addPolygon(pts.map(_pv).toList(), true);
    canvas.drawPath(path, Paint()..color = _lit(_water, n, extra: 0.9, opacity: 0.85));
    canvas.drawPath(path, _edge(0.6, 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE3FB), Color(0xFFE0F2FE)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // 1. Table base with a soft shadow.
    final shadowPts = [_p(-7, -2.4, -5), _p(7, -2.4, -5), _p(7, -2.4, 5), _p(-7, -2.4, 5)]
        .map((o) => o + const Offset(0, 26))
        .toList();
    canvas.drawPath(
      Path()..addPolygon(shadowPts, true),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    _box(canvas, (0, -2, 0), 14, 0.4, 10, const Color(0xFFDEB887));
    final grain = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFFB8925F).withValues(alpha: 0.5);
    for (var z = -4.2; z < 5; z += 1.4) {
      canvas.drawLine(_p(-6.8, -1.8, z), _p(6.8, -1.8, z + 0.2), grain);
    }

    // 2. Upstream (slanted mountain river).
    const up = _upPos, rot = _upRot;
    _terrain(canvas, (0, 0, -2.25), 7, 3, 2.5, const Color(0xFFA3E635), _soil, pos: up, rot: rot);
    _terrain(canvas, (0, -0.25, 0), 7, 2.5, 2, const Color(0xFF57534E), _soil, pos: up, rot: rot);
    _waterTop(canvas, (u, v) => _tf((-3.55 + 7.1 * u, 1.4, -1 + 2 * v), up, rot), scene.waterScroll);
    _waterSide(canvas, [
      _tf((3.55, 1.0, -1), up, rot),
      _tf((3.55, 1.4, -1), up, rot),
      _tf((3.55, 1.4, 1), up, rot),
      _tf((3.55, 1.0, 1), up, rot),
    ], _tf((1, 0, 0), (0, 0, 0), rot));

    final rocks = scene.rocks.where((r) => r.visible).toList()
      ..sort((a, b) => _dot((a.x, a.y, a.z), _zc).compareTo(_dot((b.x, b.y, b.z), _zc)));
    bool behindMountain(_Rock r) => r.x < -2.8 && r.z < -0.35;
    bool upstream(double x) => x < 1.0;

    for (final r in rocks) {
      if (upstream(r.x) && behindMountain(r)) _paintRock(canvas, r);
    }
    _pyramid(
      canvas,
      _tf((-2.5, 5.5, -1.5), up, rot),
      [
        _tf((-2.5 + 1.414, 1.5, -1.5 + 1.414), up, rot),
        _tf((-2.5 + 1.414, 1.5, -1.5 - 1.414), up, rot),
        _tf((-2.5 - 1.414, 1.5, -1.5 - 1.414), up, rot),
        _tf((-2.5 - 1.414, 1.5, -1.5 + 1.414), up, rot),
      ],
      const Color(0xFF94A3B8),
    );
    _paintSand(canvas, upstreamOnly: true);
    for (final r in rocks) {
      if (upstream(r.x) && !behindMountain(r)) _paintRock(canvas, r);
    }
    _terrain(canvas, (0, 0, 2.25), 7, 3, 2.5, const Color(0xFFA3E635), _soil, pos: up, rot: rot);

    // 3. Downstream (flat sandy lake).
    const dn = _downPos;
    const sandTop = Color(0xFFFDE047);
    _terrain(canvas, (0, 0, -2.25), 5, 2.5, 2.5, sandTop, _soil, pos: dn);
    _terrain(canvas, (0, -0.5, 0), 5, 1.5, 2, sandTop, _soil, pos: dn);
    // Lake water: only the channel between the banks is visible.
    _waterTop(
      canvas,
      (u, v) => _tf((-2.55 + 5.1 * u, 1.05, -3.5 + 7 * v), dn, 0),
      scene.lakeScroll,
      v0: 2.5 / 7,
      v1: 4.5 / 7,
    );
    _waterSide(canvas, [
      _tf((2.55, 0.25, -1), dn, 0),
      _tf((2.55, 1.05, -1), dn, 0),
      _tf((2.55, 1.05, 1), dn, 0),
      _tf((2.55, 0.25, 1), dn, 0),
    ], (1, 0, 0));
    _paintDelta(canvas);
    _paintDunes(canvas);
    _paintSand(canvas, upstreamOnly: false);
    for (final r in rocks) {
      if (!upstream(r.x)) _paintRock(canvas, r);
    }
    _terrain(canvas, (0, 0, 2.25), 5, 2.5, 2.5, sandTop, _soil, pos: dn);
    _paintDropHint(canvas);

    // 4. Wind streaks.
    for (final w in scene.wind) {
      final a = _p(w.x, w.y, w.z), b = _p(w.x + 0.8, w.y, w.z);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.75),
      );
    }

    if (showLabels) _paintLabels(canvas);
  }

  /// Jagged icosahedron rock, or a flattened smooth pebble after abrasion.
  void _paintRock(Canvas canvas, _Rock r) {
    final c = _p(r.x, r.y, r.z);
    if (!r.isSmooth) {
      final rad = 0.3 * _k;
      final pts = <Offset>[];
      for (var i = 0; i < 9; i++) {
        final a = r.rotZ + i * 2 * math.pi / 9;
        final rr = rad * r.radii[i] * (0.92 + 0.08 * math.sin(r.rotX * 2 + i));
        pts.add(c + Offset(math.cos(a) * rr, math.sin(a) * rr * 0.92));
      }
      final path = Path()..addPolygon(pts, true);
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.45),
            colors: const [Color(0xFFB4B4B4), Color(0xFF888888), Color(0xFF555555)],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: c, radius: rad * 1.2)),
      );
      final facet = Paint()
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.55);
      final inner = c + Offset(math.cos(r.rotX) * rad * 0.2, math.sin(r.rotX) * rad * 0.15);
      for (final i in const [0, 3, 6]) {
        canvas.drawLine(inner, pts[i], facet);
      }
      canvas.drawPath(path, _edge(1, 1.6));
    } else {
      final rx = 0.2 * _k * (0.85 + 0.15 * math.cos(r.rotX).abs());
      final ry = 0.2 * _k * (0.6 + 0.22 * math.sin(r.rotX).abs());
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(r.rotZ * 0.3);
      final oval = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
      canvas.drawOval(
        oval,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.5),
            colors: [Color(0xFFD4D4D4), Color(0xFF8A8A8A), Color(0xFF5F5F5F)],
            stops: [0, 0.6, 1],
          ).createShader(oval),
      );
      canvas.drawOval(oval, _edge(1, 1.3));
      canvas.restore();
    }
  }

  void _paintSand(Canvas canvas, {required bool upstreamOnly}) {
    final paint = Paint()..color = const Color(0xFFCA8A04);
    const half = 0.05 * _k;
    for (final s in scene.sand) {
      if (!s.visible || (s.x < 1.0) != upstreamOnly) continue;
      final c = _p(s.x, s.y, s.z);
      canvas.drawRect(Rect.fromCenter(center: c, width: half * 2, height: half * 2), paint);
    }
  }

  /// Sediment delta (HTML cylinder r1.5 growing at (2,-0.1,0)); drawn over the
  /// translucent lake and clipped to the channel between the sandy banks.
  void _paintDelta(Canvas canvas) {
    final s = scene.deltaScale;
    if (s < 0.02) return;
    final r = 1.5 * s;
    List<Offset> ring(double rr) => [
          for (var i = 0; i < 48; i++)
            _p(
              math.max(1.0, 2 + rr * math.cos(i * 2 * math.pi / 48)),
              -0.05,
              (rr * math.sin(i * 2 * math.pi / 48)).clamp(-1.0, 1.0),
            ),
        ];
    final outer = Path()..addPolygon(ring(r), true);
    canvas.drawPath(outer, Paint()..color = const Color(0xFF854D0E).withValues(alpha: 0.8));
    canvas.drawPath(
      Path()..addPolygon(ring(r * 0.6), true),
      Paint()..color = const Color(0xFFA16207).withValues(alpha: 0.55),
    );
    canvas.drawPath(outer, _edge(0.5, 1));
  }

  void _paintDunes(Canvas canvas) {
    final s = Curves.easeOut.transform(scene.duneRise.clamp(0.0, 1.0));
    if (s <= 0.01) return;
    const baseY = 0.35; // top of the far sandy bank
    for (final d in const [(4.5, -2.0, 1.0), (5.2, -1.5, 0.7)]) {
      final r = 0.6 * d.$3 * s, h = 0.8 * d.$3 * s;
      _pyramid(
        canvas,
        (d.$1, baseY + h, d.$2),
        [
          (d.$1, baseY, d.$2 + r),
          (d.$1 + r, baseY, d.$2),
          (d.$1, baseY, d.$2 - r),
          (d.$1 - r, baseY, d.$2),
        ],
        const Color(0xFFFACC15),
      );
    }
  }

  /// While the wind is dragged, outline the sandy banks around the lake.
  void _paintDropHint(Canvas canvas) {
    if (scene.dragging != _Item.wind) return;
    final pulse = 0.5 + 0.5 * math.sin(scene.time * 5);
    final path = Path()
      ..addPolygon([_p(1.0, 0.36, -3.5), _p(6.0, 0.36, -3.5), _p(6.0, 0.36, 3.5), _p(1.0, 0.36, 3.5)], true);
    canvas.drawPath(path, Paint()..color = _Colors.zslYellow.withValues(alpha: 0.08 + 0.08 * pulse));
    labDashedPath(
      canvas,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.zslYellow.withValues(alpha: 0.6 + 0.3 * pulse),
      dash: 14,
      gap: 9,
      phase: scene.time * 30,
    );
  }

  void _paintLabels(Canvas canvas) {
    String t(String k) => labTr(_i18n, lang, k);
    final labels = switch (scene.stepIdx) {
      0 => [('s2Lbl1', (-3.0, 2.5, 0.0)), ('s2Lbl2', (-1.0, 1.5, 2.0))],
      1 => [('s2Lbl3', (1.5, 0.5, 2.5))],
      2 => [('s2Lbl4', (2.5, 0.5, 0.0)), ('s2Lbl5', (3.0, 0.5, 3.0))],
      3 => [('s2Lbl6', (3.0, -0.5, 0.0))],
      _ => const <(String, _V3)>[],
    };
    for (final l in labels) {
      _callout(canvas, t(l.$1), _pv(l.$2), size: 12 * uiScale, pointerBelow: false);
    }
    if (scene.stepIdx >= 4) {
      // "SAND DUNES" (HTML at (5.5, 1, -2)) points down at the dunes so the
      // label does not hide them.
      _callout(canvas, t('s2Lbl7'), _p(4.85, 1.3, -1.75), size: 12 * uiScale, lift: 10 * uiScale);
    }
    for (final c in scene.chips) {
      final e = scene.time - c.start;
      if (e < 0 || e > 1) continue;
      _callout(
        canvas,
        t('s2Lbl8'),
        _p(c.x, c.y + 1, c.z),
        size: 12 * uiScale,
        textColor: const Color(0xFFDC2626),
        pointerBelow: false,
        opacity: e > 0.85 ? (1 - e) / 0.15 : 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiverPainter old) =>
      old.showLabels != showLabels || old.lang != lang || old.uiScale != uiScale;
}

// ============================================================ TRAY ICONS

/// The HTML tray SVG icons (100x100 viewBox), drawn natively.
class _ItemIconPainter extends CustomPainter {
  const _ItemIconPainter(this.item);
  final _Item item;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    Paint stroke(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;
    switch (item) {
      case _Item.sun:
        const c = Color(0xFFFACC15);
        canvas.drawCircle(const Offset(50, 50), 25, Paint()..color = c);
        final p = stroke(c, 8);
        for (final l in const [
          [50.0, 10.0, 50.0, 20.0], [50.0, 80.0, 50.0, 90.0], [10.0, 50.0, 20.0, 50.0],
          [80.0, 50.0, 90.0, 50.0], [22.0, 22.0, 29.0, 29.0], [71.0, 71.0, 78.0, 78.0],
          [22.0, 78.0, 29.0, 71.0], [71.0, 29.0, 78.0, 22.0], //
        ]) {
          canvas.drawLine(Offset(l[0], l[1]), Offset(l[2], l[3]), p);
        }
      case _Item.snowflake:
        final p = stroke(const Color(0xFF38BDF8), 8);
        canvas.drawLine(const Offset(50, 10), const Offset(50, 90), p);
        canvas.drawLine(const Offset(15, 30), const Offset(85, 70), p);
        canvas.drawLine(const Offset(15, 70), const Offset(85, 30), p);
        for (final pl in const [
          [40.0, 25.0, 50.0, 15.0, 60.0, 25.0], [40.0, 75.0, 50.0, 85.0, 60.0, 75.0],
          [25.0, 45.0, 15.0, 30.0, 30.0, 25.0], [75.0, 55.0, 85.0, 70.0, 70.0, 75.0],
          [25.0, 55.0, 15.0, 70.0, 30.0, 75.0], [75.0, 45.0, 85.0, 30.0, 70.0, 25.0], //
        ]) {
          canvas.drawPath(
            Path()
              ..moveTo(pl[0], pl[1])
              ..lineTo(pl[2], pl[3])
              ..lineTo(pl[4], pl[5]),
            p,
          );
        }
      case _Item.cloud:
      case _Item.cloudChem:
        final body = Path()
          ..moveTo(25, 60)
          ..arcToPoint(const Offset(45, 30), radius: const Radius.circular(20))
          ..arcToPoint(const Offset(80, 40), radius: const Radius.circular(25))
          ..arcToPoint(const Offset(80, 70), radius: const Radius.circular(15))
          ..close();
        canvas.drawPath(body, Paint()..color = const Color(0xFF60A5FA));
        canvas.drawPath(body, stroke(const Color(0xFF1E3A8A), 4));
        for (final x in const [35.0, 55.0, 75.0]) {
          final drop = Path()
            ..moveTo(x, 75)
            ..quadraticBezierTo(x - 5, 85, x, 90)
            ..quadraticBezierTo(x + 5, 85, x, 75);
          canvas.drawPath(drop, Paint()..color = const Color(0xFF93C5FD));
          canvas.drawPath(drop, stroke(const Color(0xFF1E3A8A), 3));
        }
      case _Item.wind:
        final p = stroke(const Color(0xFFE0F2FE), 8);
        canvas.drawPath(
          Path()
            ..moveTo(20, 40)
            ..lineTo(70, 40)
            ..arcToPoint(const Offset(70, 20), radius: const Radius.circular(10), clockwise: false)
            ..arcToPoint(const Offset(55, 25), radius: const Radius.circular(10), clockwise: false),
          p,
        );
        canvas.drawPath(
          Path()
            ..moveTo(10, 60)
            ..lineTo(80, 60)
            ..arcToPoint(const Offset(80, 90), radius: const Radius.circular(15))
            ..arcToPoint(const Offset(60, 80), radius: const Radius.circular(15)),
          p,
        );
        canvas.drawPath(
          Path()
            ..moveTo(30, 80)
            ..lineTo(50, 80)
            ..arcToPoint(const Offset(50, 60), radius: const Radius.circular(10), clockwise: false),
          p,
        );
      case _Item.sapling:
        const brown = Color(0xFF78350F);
        canvas.drawPath(
          Path()
            ..moveTo(50, 90)
            ..quadraticBezierTo(50, 50, 50, 40),
          stroke(brown, 8),
        );
        canvas.drawPath(
          Path()
            ..moveTo(50, 65)
            ..quadraticBezierTo(65, 60, 70, 45),
          stroke(brown, 5),
        );
        canvas.drawPath(
          Path()
            ..moveTo(50, 75)
            ..quadraticBezierTo(35, 70, 30, 55),
          stroke(brown, 5),
        );
        for (final leaf in const [
          [50.0, 40.0, 60.0, 20.0, 50.0, 10.0, 40.0, 20.0],
          [70.0, 45.0, 85.0, 30.0, 80.0, 20.0, 65.0, 30.0],
          [30.0, 55.0, 15.0, 40.0, 20.0, 30.0, 35.0, 40.0],
        ]) {
          final path = Path()
            ..moveTo(leaf[0], leaf[1])
            ..quadraticBezierTo(leaf[2], leaf[3], leaf[4], leaf[5])
            ..quadraticBezierTo(leaf[6], leaf[7], leaf[0], leaf[1]);
          canvas.drawPath(path, Paint()..color = const Color(0xFF4ADE80));
          canvas.drawPath(path, stroke(const Color(0xFF166534), 3));
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ItemIconPainter old) => old.item != item;
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
