// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show DeviceGestureSettings;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 7 • Activity 4
/// Radiation of Heat.
///
/// Native Flutter port of `Cl7S-Ch7-A4-Radiation_of_Heat.html`.
/// Scenario 1: dress two mannequins in a black and a white T-shirt, attach
/// thermometers and fast-forward time in the sun. Scenario 2: a heat lamp
/// warms a thermometer inside a bell jar even after the air is pumped out.
class Ch7A4RadiationOfHeatPage extends StatefulWidget {
  const Ch7A4RadiationOfHeatPage({super.key});

  @override
  State<Ch7A4RadiationOfHeatPage> createState() => _Ch7A4RadiationOfHeatPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, whoosh 1492.
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

// =============================================================== MODEL

const Size _design = Size(1000, 560);

/// One fixed simulation tick of the HTML `requestAnimationFrame` loop.
const double _tickSeconds = 1 / 60;

enum _Item { blackShirt, whiteShirt, thermometer, heatlamp, belljar, vacuumpump }

/// Minimal TWEEN.js stand-in driven by the scene clock.
class _Tw {
  _Tw(this.value);
  double value;
  double _from = 0, _to = 0, _t0 = 0, _dur = 0;

  void to(double target, double now, double seconds) {
    _from = value;
    _to = target;
    _t0 = now;
    _dur = seconds;
    if (seconds <= 0) set(target);
  }

  void set(double v) {
    value = v;
    _dur = 0;
  }

  void update(double now) {
    if (_dur <= 0) return;
    final k = ((now - _t0) / _dur).clamp(0.0, 1.0);
    value = _from + (_to - _from) * k;
    if (k >= 1) _dur = 0;
  }
}

class _RayLine {
  double x = 0, y = 0, z = 0, opacity = 0;
}

class _Wave {
  double x = 0, y = 0, z = 0, vx = 0, vy = 0, vz = 0, opacity = 0;
}

class _Air {
  double x = 0, y = 0, z = 0, opacity = 0;
}

/// Mutable scene model read by the painter every frame.
class _RadScene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  double viewShift = 0;

  // Scenario 1: shirts, thermometers, the rising sun and radiation lines.
  bool shirtA = false, shirtB = false, thermoA = false, thermoB = false;
  bool fastForward = false, ffStarted = false;
  double tempA = 25, tempB = 25;
  final _Tw sunI = _Tw(0.5), sunX = _Tw(20), sunY = _Tw(2), sunZ = _Tw(-20);
  final List<_RayLine> rays = List.generate(30, (_) => _RayLine());

  // Scenario 2: lamp, bench thermometer, bell jar, vacuum pump.
  bool lamp = false, benchThermo = false, lampOn = false, jar = false, pump = false;
  bool vacuumOn = false, vacuumLabel = false;
  double bench = 22;
  int vacuumTimer = 0;
  final _Tw lampI = _Tw(0);
  final List<_Wave> waves = List.generate(20, (_) => _Wave());
  final List<_Air> air = List.generate(40, (_) => _Air());

  /// Fade-in start times of placed objects.
  final Map<String, double> placedAt = {};

  /// HTML `buildScenario()` + `resetApp(true)` state reset.
  void build() {
    step = 1;
    shirtA = shirtB = thermoA = thermoB = fastForward = ffStarted = false;
    tempA = tempB = 25;
    sunI.set(0.5);
    sunX.set(20);
    sunY.set(2);
    sunZ.set(-20);
    lamp = benchThermo = lampOn = jar = pump = vacuumOn = vacuumLabel = false;
    bench = 22;
    vacuumTimer = 0;
    lampI.set(0);
    for (final r in rays) {
      r.opacity = 0;
    }
    for (final w in waves) {
      w.opacity = 0;
    }
    for (final a in air) {
      a.opacity = 0;
    }
    placedAt.clear();
  }

  void updateTweens(double now) {
    for (final tw in [sunI, sunX, sunY, sunZ, lampI]) {
      tw.update(now);
    }
  }
}

// =============================================================== STATE

class _Ch7A4RadiationOfHeatPageState extends State<Ch7A4RadiationOfHeatPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _RadScene _scene = _RadScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final GlobalKey _layerKey = GlobalKey();

  late final Ticker _ticker;
  double _acc = 0;
  _Item? _dragItem;
  Offset? _dragGlobal;
  bool _done = false;

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
    _scene.build();
    _ticker = createTicker(_tick)..start();
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

  // ------------------------------------------------------------ frame loop

  void _tick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    s.viewShift += ((_lab.isSidebarOpen ? 0.0 : 100.0) - s.viewShift) * math.min(1.0, dt * 6);
    s.updateTweens(now);
    // HTML `updateLogic()` runs once per animation frame: replay it at a
    // fixed 60 Hz so the timings match on every device.
    _acc += dt;
    var n = 0;
    while (_acc >= _tickSeconds && n < 8) {
      _acc -= _tickSeconds;
      n++;
      _fixedStep();
    }
    if (n == 8) _acc = 0;
    _frame.value = now;
  }

  double _r() => _rnd.nextDouble();

  void _fixedStep() {
    final s = _scene;
    if (s.scenario == 0 && s.fastForward) {
      if (s.tempA < 45) s.tempA += 0.2;
      if (s.tempB < 30) s.tempB += 0.05;
      for (final r in s.rays) {
        if (_r() > 0.9) {
          r
            ..x = (_r() - 0.5) * 15
            ..y = 9 + _r() * 7
            ..z = (_r() - 0.5) * 5
            ..opacity = 0.8;
        }
        r.y -= 0.5;
        r.x -= 0.25;
        if (r.y < 0) r.opacity = 0;
      }
      if (s.tempA >= 45) {
        s.fastForward = false;
        for (final r in s.rays) {
          r.opacity = 0;
        }
        _advanceStep();
      }
    }
    if (s.scenario == 1) {
      if (s.lampOn) {
        if (s.bench < 35) s.bench += 0.1;
        for (final w in s.waves) {
          if (_r() > 0.95 && w.opacity <= 0) {
            w
              ..x = -2
              ..y = 3
              ..z = 0
              ..vx = 0.1 + _r() * 0.05
              ..vy = (_r() - 0.5) * 0.05
              ..vz = (_r() - 0.5) * 0.1
              ..opacity = 0.8;
          }
          if (w.opacity > 0) {
            w.x += w.vx;
            w.y += w.vy;
            w.z += w.vz;
            w.opacity -= 0.02;
          }
        }
        if (s.bench >= 35 && s.step == 3) _advanceStep();
      }
      if (s.vacuumOn) {
        var active = 0;
        for (final p in s.air) {
          if (p.opacity == 0 && _r() > 0.9 && active < 10) {
            p
              ..x = (_r() - 0.5) * 5
              ..y = 1 + _r() * 4
              ..z = (_r() - 0.5) * 5
              ..opacity = 1;
          }
          if (p.opacity > 0) {
            active++;
            final dx = 3.5 - p.x, dy = 1 - p.y, dz = 0 - p.z;
            p.x += dx * 0.05;
            p.y += dy * 0.05;
            p.z += dz * 0.05;
            if (dx.abs() < 0.5 && dy.abs() < 0.5) p.opacity = 0;
          }
        }
        s.vacuumTimer++;
        if (s.vacuumTimer > 150) {
          s.vacuumOn = false;
          for (final p in s.air) {
            p.opacity = 0;
          }
          _advanceStep();
        }
      }
    }
  }

  // -------------------------------------------------------------- logic

  void _buildScenario() {
    _lab.cancelPending();
    _done = false;
    _dragItem = null;
    _dragGlobal = null;
    _scene.build();
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
      _buildScenario();
    });
  }

  void _advanceStep() {
    final n = _data.steps.length;
    if (_scene.step >= n) return;
    setState(() {
      _scene.step++;
      if (_scene.step == n) _showConclusion();
    });
  }

  void _showConclusion() {
    _done = true;
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      heading: () => _lab.t('sci_conclusion'),
      body: () => _t(_scene.scenario == 0 ? 'conclusion_1' : 'conclusion_2'),
      extra: _lab.completedScenarios.length >= 2 ? _conclusionsExtra : null,
    );
  }

  /// HTML `populateInventory()`: the one item offered at this step.
  _Item? get _currentItem {
    final st = _scene.step;
    if (_scene.scenario == 0) {
      if (st == 1) return _Item.blackShirt;
      if (st == 2) return _Item.whiteShirt;
      if (st == 3 || st == 4) return _Item.thermometer;
      return null;
    }
    return switch (st) {
      1 => _Item.heatlamp,
      2 => _Item.thermometer,
      4 => _Item.belljar,
      5 => _Item.vacuumpump,
      _ => null,
    };
  }

  /// HTML `executeDrop()`.
  void _executeDrop(_Item item) {
    final s = _scene;
    _Audio.play(_Sound.drop);
    void place(String key) => s.placedAt[key] = s.time;
    var ok = false;
    setState(() {
      if (s.scenario == 0) {
        if (item == _Item.blackShirt && s.step == 1) {
          s.shirtA = ok = true;
          place('shirtA');
        } else if (item == _Item.whiteShirt && s.step == 2) {
          s.shirtB = ok = true;
          place('shirtB');
        } else if (item == _Item.thermometer && s.step == 3) {
          s.thermoA = ok = true;
        } else if (item == _Item.thermometer && s.step == 4) {
          s.thermoB = ok = true;
        }
      } else {
        if (item == _Item.heatlamp && s.step == 1) {
          s.lamp = ok = true;
          place('lamp');
        } else if (item == _Item.thermometer && s.step == 2) {
          s.benchThermo = ok = true;
          place('thermo');
        } else if (item == _Item.belljar && s.step == 4) {
          s.jar = ok = true;
          place('jar');
        } else if (item == _Item.vacuumpump && s.step == 5) {
          s.pump = ok = true;
          place('pump');
        }
      }
    });
    if (ok) _advanceStep();
  }

  /// HTML `triggerSimulation()`.
  void _trigger() {
    final s = _scene;
    final now = s.time;
    setState(() {
      if (s.scenario == 0 && s.step == 5) {
        s.ffStarted = true;
        s.fastForward = true;
        s.sunI.to(1.5, now, 1);
        // The sun moves overhead over 5 s.
        s.sunX.to(0, now, 5);
        s.sunY.to(30, now, 5);
        s.sunZ.to(-10, now, 5);
      } else if (s.scenario == 1 && s.step == 3) {
        s.lampOn = true;
        s.lampI.to(2, now, 0.5);
      } else if (s.scenario == 1 && s.step == 6) {
        s.vacuumOn = true;
        s.vacuumLabel = true;
        _Audio.play(_Sound.whoosh);
      }
    });
  }

  // ------------------------------------------------------ item dragging

  /// HTML icon `pointerdown` validation for the current step.
  bool _isValid(_Item item) => item == _currentItem;

  void _itemDown(_Item item, Offset global) {
    if (!_lab.isLabActive || _dragItem != null) return;
    if (!_isValid(item)) {
      _lab.showToast(_t('msg_wrong_icon'), isError: true);
      return;
    }
    _Audio.play(_Sound.pickup);
    setState(() {
      _dragItem = item;
      _dragGlobal = global;
    });
  }

  void _itemMove(Offset global) {
    if (_dragItem == null) return;
    setState(() => _dragGlobal = global);
  }

  /// HTML `handleDragEnd`: on touch screens any release places the item.
  void _itemUp() {
    final item = _dragItem;
    if (item == null) return;
    setState(() {
      _dragItem = null;
      _dragGlobal = null;
    });
    _executeDrop(item);
  }

  // ----------------------------------------------------------------- UI

  List<LabAction> _actions() {
    final s = _scene;
    if (_done) return const [];
    LabAction main(String key, IconData icon) => LabAction(
          label: _t(key),
          icon: icon,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _trigger,
        );
    if (s.scenario == 0 && s.step == 5 && !s.ffStarted) return [main('btn_fast_forward', Icons.fast_forward)];
    if (s.scenario == 1 && s.step == 3 && !s.lampOn) return [main('btn_turn_on_lamp', Icons.power_settings_new)];
    if (s.scenario == 1 && s.step == 6 && !s.vacuumLabel) return [main('btn_turn_on_vacuum', Icons.air)];
    return const [];
  }

  String? _instruction() {
    if (!_done) return null;
    return _lab.completedScenarios.length >= 2 ? _lab.t('msg_all_complete') : _t('msg_scenario_complete');
  }

  Widget _conclusionsExtra() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    Widget para(String head, String body) => Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '$head\n',
              style: const TextStyle(color: _Colors.zslYellow, fontWeight: FontWeight.w800),
            ),
            TextSpan(text: body),
          ]),
          style: TextStyle(color: p.text, fontSize: 13 * f, height: 1.5, fontWeight: FontWeight.w500),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        para(_t('lbl_scen_1'), _t('conclusion_1')),
        SizedBox(height: 10 * s),
        para(_t('lbl_scen_2'), _t('conclusion_2')),
      ],
    );
  }

  double _labelScale(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final canvasW = size.width * (_lab.isSidebarOpen ? 0.7 : 1.0);
    final stage = math.min(canvasW / _design.width, size.height / _design.height);
    return (0.667 / math.max(stage, 0.1)).clamp(1.0, 1.6);
  }

  double _iconSize(double s) => math.min(42 * s, 46.0);

  String _itemName(_Item item) => _t(switch (item) {
        _Item.blackShirt => 'item_black_shirt',
        _Item.whiteShirt => 'item_white_shirt',
        _Item.thermometer => 'item_thermometer',
        _Item.heatlamp => 'item_heatlamp',
        _Item.belljar => 'item_belljar',
        _Item.vacuumpump => 'item_vacuumpump',
      });

  /// HTML `#ui-inventory` (shows only the item for the current step).
  Widget _tray(LabPalette p, double s, EdgeInsets inset) {
    final item = _currentItem;
    if (item == null) return const SizedBox.shrink();
    final collapsed = !_lab.isSidebarOpen;
    final pad = MediaQuery.paddingOf(context);
    final size = _iconSize(s);
    return Positioned(
      left: collapsed ? 8 + pad.left : inset.left,
      top: collapsed ? 76 + pad.top : inset.top,
      child: MediaQuery(
        // Short drags start immediately (Flutter's default pan slop is 36 px).
        data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: LabGlassCard(
          palette: p,
          radius: 12,
          padding: EdgeInsets.all(math.min(5 * s, 6.0)),
          child: Opacity(
            opacity: _dragItem == item ? 0.5 : 1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (d) => _itemDown(item, d.globalPosition),
              onPanUpdate: (d) => _itemMove(d.globalPosition),
              onPanEnd: (_) => _itemUp(),
              onPanCancel: _itemUp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: _ItemIconPainter(
                      item: item,
                      hint: _dragItem == null && _lab.isLabActive,
                      scene: _scene,
                      repaint: _frame,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  SizedBox(
                    width: size + 14,
                    child: Text(
                      _itemName(item),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(color: p.text, fontSize: 9 * s, fontWeight: FontWeight.w700, height: 1.15),
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

  /// HTML `#global-drop-zone` plus the dragged icon following the finger.
  Widget _dragLayer(double s) {
    final size = _iconSize(s);
    Offset? local;
    if (_dragGlobal != null) {
      final box = _layerKey.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) local = box.globalToLocal(_dragGlobal!);
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          key: _layerKey,
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _dragItem != null ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Center(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _frame,
                    builder: (context, tm, _) => Opacity(
                      opacity: 0.6 + 0.4 * (0.5 + 0.5 * math.cos(tm * math.pi)),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CustomPaint(
                          painter: _DropZonePainter(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 14 * s),
                            child: Text(
                              _t('drop_here'),
                              style: TextStyle(
                                color: _Colors.zslYellow,
                                fontWeight: FontWeight.w800,
                                fontSize: 22 * s,
                                letterSpacing: 3,
                                shadows: const [Shadow(color: Color(0x99000000), blurRadius: 6)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_dragItem != null && local != null)
              Positioned(
                left: local.dx - size * 0.6,
                top: local.dy - size * 0.6,
                child: Transform.scale(
                  scale: 1.2,
                  child: CustomPaint(size: Size.square(size), painter: _ItemIconPainter(item: _dragItem!)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const List<String> _painterKeys = ['lbl_vacuum', 'lbl_a', 'lbl_b', 'deg_c'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final inset = labOverlayInsets(context, _lab);
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.wb_sunny_outlined,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          instruction: _instruction(),
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            _tray(p, s, inset),
            _dragLayer(s),
          ],
          stage: LabStage(
            designSize: _design,
            child: CustomPaint(
              size: _design,
              painter: _RadiationPainter(
                scene: _scene,
                repaint: _frame,
                isDark: _lab.isDark,
                showLabels: _lab.showLabels,
                lang: _lab.lang.code,
                text: {for (final k in _painterKeys) k: _t(k)},
                labelScale: _labelScale(context),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Radiation of Heat',
    'app_subtitle': 'Class 7 • Heat Transfer in Nature',
    'scen_1_opt': 'Scenario 1: The Tale of Two Shirts',
    'scen_2_opt': 'Scenario 2: Heat Through Nothing',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Success!',
    'drop_here': 'DROP HERE',
    'btn_fast_forward': 'Fast Forward Time',
    'btn_turn_on_lamp': 'Turn On Lamp',
    'btn_turn_on_vacuum': 'Turn On Vacuum',
    'msg_wrong_icon': 'That is not the correct item for this step.',
    'conclusion_1':
        'Dark surfaces absorb more heat from radiation, making them hotter. Light surfaces reflect more heat, keeping them cooler. This is why we wear light-colored clothes in summer!',
    'conclusion_2':
        "Even with no air inside the jar (a vacuum), the thermometer stays hot. This proves that heat radiation can travel through empty space. This is how the Sun's heat reaches Earth!",
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario.',
    // Strings that were hard-coded in the HTML.
    'lbl_vacuum': 'VACUUM',
    'lbl_a': 'A',
    'lbl_b': 'B',
    'lbl_scen_1': 'Scenario 1:',
    'lbl_scen_2': 'Scenario 2:',
    'item_black_shirt': 'Black T-shirt',
    'item_white_shirt': 'White T-shirt',
    'item_thermometer': 'Thermometer',
    'item_heatlamp': 'Heat Lamp',
    'item_belljar': 'Bell Jar',
    'item_vacuumpump': 'Vacuum Pump',
    'deg_c': '{t}°C',
  },
  'hi': {
    'app_title': 'ऊष्मा का विकिरण',
    'app_subtitle': 'कक्षा 7 • प्रकृति में ऊष्मा स्थानांतरण',
    'scen_1_opt': 'परिदृश्य 1: दो शर्ट की कहानी',
    'scen_2_opt': 'परिदृश्य 2: शून्य के माध्यम से ऊष्मा',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'सफलता!',
    'drop_here': 'यहाँ छोड़ें',
    'btn_fast_forward': 'समय आगे बढ़ाएं',
    'btn_turn_on_lamp': 'लैंप चालू करें',
    'btn_turn_on_vacuum': 'वैक्यूम चालू करें',
    'msg_wrong_icon': 'यह इस चरण के लिए सही वस्तु नहीं है।',
    'conclusion_1':
        'गहरे रंग की सतहें विकिरण से अधिक ऊष्मा को अवशोषित करती हैं, जिससे वे अधिक गर्म हो जाती हैं। हल्के रंग की सतहें अधिक ऊष्मा को दर्शाती हैं, जिससे वे ठंडी रहती हैं। इसलिए हम गर्मियों में हल्के रंग के कपड़े पहनते हैं!',
    'conclusion_2':
        'जार के अंदर हवा न होने (वैक्यूम) के बावजूद, थर्मामीटर गर्म रहता है। यह साबित करता है कि ऊष्मा विकिरण खाली जगह से यात्रा कर सकता है। इसी तरह सूर्य की गर्मी पृथ्वी तक पहुँचती है!',
    'msg_scenario_complete': 'परिदृश्य पूर्ण! कृपया अगला परिदृश्य चुनें।',
    'lbl_vacuum': 'निर्वात',
    'lbl_a': 'A',
    'lbl_b': 'B',
    'lbl_scen_1': 'परिदृश्य 1:',
    'lbl_scen_2': 'परिदृश्य 2:',
    'item_black_shirt': 'काली टी-शर्ट',
    'item_white_shirt': 'सफेद टी-शर्ट',
    'item_thermometer': 'थर्मामीटर',
    'item_heatlamp': 'हीट लैंप',
    'item_belljar': 'बेल जार',
    'item_vacuumpump': 'वैक्यूम पंप',
    'deg_c': '{t}°C',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually and interactively demonstrate that dark-colored surfaces absorb more heat radiation than light-colored surfaces.',
      steps: [
        LabStep(
          concept: 'Color and Heat Absorption',
          action: 'DRAG the black T-shirt from the inventory and DROP it.',
          observation: 'Mannequin A is now wearing the black T-shirt.',
        ),
        LabStep(
          concept: 'Color and Heat Reflection',
          action: 'DRAG the white T-shirt and DROP it.',
          observation: 'Mannequin B is now wearing the white T-shirt.',
        ),
        LabStep(
          concept: 'Measuring Initial State',
          action: 'DRAG a digital thermometer onto the black T-shirt.',
          observation: 'A thermometer is attached, showing the initial ambient temperature.',
        ),
        LabStep(
          concept: 'Measuring Initial State',
          action: 'DRAG another thermometer onto the white T-shirt.',
          observation: 'A second thermometer is attached, showing the same initial temperature.',
        ),
        LabStep(
          concept: 'Exposing to Radiation',
          action: "CLICK the 'Fast Forward Time' button to simulate 30 minutes in the hot sun.",
          observation:
              "The temperature on the black shirt's thermometer rises significantly higher and faster than the white shirt's thermometer.",
        ),
        LabStep(
          concept: 'Scientific Conclusion',
          action: 'Review the outcome of the experiment.',
          observation: 'Dark surfaces are better absorbers of heat radiation.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To prove that heat transfer by radiation does not require a medium (like air).',
      steps: [
        LabStep(
          concept: 'Setting up the Heat Source',
          action: 'DRAG the heat lamp to the bench.',
          observation: 'The heat lamp is placed on the bench.',
        ),
        LabStep(
          concept: 'Placing the Sensor',
          action: 'DRAG a thermometer next to the lamp.',
          observation: 'The thermometer is placed next to the lamp, showing room temperature.',
        ),
        LabStep(
          concept: 'Activating Radiation',
          action: "CLICK 'Turn On Lamp'.",
          observation: "The lamp glows, and the thermometer's temperature begins to rise due to radiation.",
        ),
        LabStep(
          concept: 'Isolating the Setup',
          action: 'DRAG a glass bell jar over the setup.',
          observation: 'The lamp and thermometer are enclosed. Heat still radiates through the air inside.',
        ),
        LabStep(
          concept: 'Preparing for Vacuum',
          action: 'DRAG the vacuum pump to connect it.',
          observation: 'The hose is connected to the bell jar.',
        ),
        LabStep(
          concept: 'Removing the Medium (Air)',
          action: "CLICK 'Turn On Vacuum' to remove the air.",
          observation:
              "Air is sucked out creating a vacuum, but the thermometer's reading stays high! Radiation travels through empty space.",
        ),
        LabStep(
          concept: 'Scientific Conclusion',
          action: 'Review the experiment.',
          observation: 'Heat radiation does not need a medium.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह देखने और प्रदर्शित करने के लिए कि गहरे रंग की सतहें हल्के रंग की सतहों की तुलना में अधिक ऊष्मा विकिरण को अवशोषित करती हैं।',
      steps: [
        LabStep(
          concept: 'रंग और ऊष्मा अवशोषण',
          action: 'इन्वेंट्री से काली टी-शर्ट खींचें और इसे छोड़ दें।',
          observation: 'पुतला A ने अब काली टी-शर्ट पहन ली है।',
        ),
        LabStep(
          concept: 'रंग और ऊष्मा परावर्तन',
          action: 'सफेद टी-शर्ट खींचें और छोड़ दें।',
          observation: 'पुतला B ने अब सफेद टी-शर्ट पहन ली है।',
        ),
        LabStep(
          concept: 'प्रारंभिक स्थिति मापना',
          action: 'काली टी-शर्ट पर एक डिजिटल थर्मामीटर खींचें।',
          observation: 'एक थर्मामीटर जुड़ा हुआ है, जो प्रारंभिक परिवेश का तापमान दिखा रहा है।',
        ),
        LabStep(
          concept: 'प्रारंभिक स्थिति मापना',
          action: 'सफेद टी-शर्ट पर एक और थर्मामीटर खींचें।',
          observation: 'एक दूसरा थर्मामीटर जुड़ा हुआ है, जो समान प्रारंभिक तापमान दिखा रहा है।',
        ),
        LabStep(
          concept: 'विकिरण के संपर्क में आना',
          action: "तेज धूप में 30 मिनट का अनुकरण करने के लिए 'समय आगे बढ़ाएं' बटन पर क्लिक करें।",
          observation: 'काली शर्ट के थर्मामीटर का तापमान सफेद शर्ट के थर्मामीटर की तुलना में काफी अधिक और तेजी से बढ़ता है।',
        ),
        LabStep(
          concept: 'वैज्ञानिक निष्कर्ष',
          action: 'प्रयोग के परिणाम की समीक्षा करें।',
          observation: 'गहरे रंग की सतहें ऊष्मा विकिरण की बेहतर अवशोषक होती हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'यह साबित करने के लिए कि विकिरण द्वारा ऊष्मा स्थानांतरण के लिए किसी माध्यम (जैसे हवा) की आवश्यकता नहीं होती है।',
      steps: [
        LabStep(
          concept: 'ऊष्मा स्रोत स्थापित करना',
          action: 'हीट लैंप को बेंच पर खींचें।',
          observation: 'हीट लैंप बेंच पर रखा गया है।',
        ),
        LabStep(
          concept: 'सेंसर लगाना',
          action: 'लैंप के बगल में थर्मामीटर खींचें।',
          observation: 'थर्मामीटर लैंप के बगल में रखा गया है, जो कमरे का तापमान दिखा रहा है।',
        ),
        LabStep(
          concept: 'विकिरण सक्रिय करना',
          action: "'लैंप चालू करें' पर क्लिक करें।",
          observation: 'दीपक चमकता है, और विकिरण के कारण थर्मामीटर का तापमान बढ़ने लगता है।',
        ),
        LabStep(
          concept: 'सेटअप को अलग करना',
          action: 'सेटअप के ऊपर एक ग्लास बेल जार खींचें।',
          observation: 'दीपक और थर्मामीटर संलग्न हैं। ऊष्मा अभी भी अंदर हवा के माध्यम से विकीर्ण होती है।',
        ),
        LabStep(
          concept: 'वैक्यूम की तैयारी',
          action: 'इसे जोड़ने के लिए वैक्यूम पंप खींचें।',
          observation: 'नली बेल जार से जुड़ी हुई है।',
        ),
        LabStep(
          concept: 'माध्यम (हवा) हटाना',
          action: "हवा निकालने के लिए 'वैक्यूम चालू करें' पर क्लिक करें।",
          observation:
              'वैक्यूम बनाने के लिए हवा निकाली जाती है, लेकिन थर्मामीटर की रीडिंग उच्च रहती है! विकिरण खाली जगह से यात्रा करता है।',
        ),
        LabStep(
          concept: 'वैज्ञानिक निष्कर्ष',
          action: 'प्रयोग की समीक्षा करें।',
          observation: 'ऊष्मा विकिरण के लिए माध्यम की आवश्यकता नहीं होती।',
        ),
      ],
    ),
  ],
};

// ============================================================ GEOMETRY
//
// A small perspective camera mirroring the HTML PerspectiveCamera so every
// Three.js mesh is drawn from its real world coordinates.

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
}

class _Cam {
  _Cam({required this.eye, required _V target, required this.focal, required this.center}) {
    f = (target - eye).unit;
    r = f.cross(const _V(0, 1, 0)).unit;
    u = r.cross(f);
  }

  final _V eye;
  final double focal;
  final Offset center;
  late final _V f, r, u;

  Offset p(_V v) {
    final d = v - eye;
    final zc = math.max(d.dot(f), 0.1);
    return Offset(center.dx + d.dot(r) / zc * focal, center.dy - d.dot(u) / zc * focal);
  }

  Offset pt(double x, double y, double z) => p(_V(x, y, z));

  /// Pixels per world unit at [v].
  double k(_V v) => focal / math.max((v - eye).dot(f), 0.1);

  /// Intersects the view ray through screen point [s] with the plane y = [py]
  /// (the HTML drag plane).
  _V? onPlaneY(Offset s, double py) {
    final dir = f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal);
    if (dir.y >= -1e-6) return null;
    final t = (py - eye.y) / dir.y;
    return eye + dir * t;
  }
}

/// Scenario 1: camera (0, 5, 20) -> (0, 3, 0). Scenario 2: (0, 8, 20) ->
/// (0, 2, 0). [shift] slides the view right while the floating mission
/// card covers the top-left of the canvas.
_Cam _a4Cam(int scenario, [double shift = 0]) => scenario == 0
    ? _Cam(eye: const _V(0, 5, 20), target: const _V(0, 3, 0), focal: 700, center: Offset(500 + shift, 292))
    : _Cam(eye: const _V(0, 8, 20), target: const _V(0, 2, 0), focal: 700, center: Offset(500 + shift, 300));

List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final s = [...pts]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in s) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in s.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

Path _poly(List<Offset> pts) {
  final path = Path();
  if (pts.isEmpty) return path;
  path.moveTo(pts.first.dx, pts.first.dy);
  for (final p in pts.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// Projected circle of radius [r] around [c] in the plane spanned by e1, e2.
List<Offset> _ring(_Cam cam, _V c, double r, _V e1, _V e2, {int seg = 24}) => [
      for (var i = 0; i < seg; i++)
        cam.p(c + e1 * (r * math.cos(i / seg * math.pi * 2)) + e2 * (r * math.sin(i / seg * math.pi * 2))),
    ];

/// Horizontal disc (ellipse on screen) at height c.y.
Path _disc(_Cam cam, _V c, double r) =>
    _poly(_ring(cam, c, r, const _V(1, 0, 0), const _V(0, 0, 1), seg: 36));

/// Cylinder / frustum / cone between [a] (radius [ra]) and [b] (radius
/// [rb]) with cylinder shading across the screen-space axis. Draws the end
/// caps that face the camera.
void _tube(
  Canvas canvas,
  _Cam cam,
  _V a,
  _V b,
  double ra,
  double rb,
  Color color, {
  double opacity = 1,
  bool caps = true,
  Color? capColor,
  bool flat = false,
}) {
  if (opacity <= 0) return;
  final axis = (b - a).unit;
  final ref = axis.y.abs() < 0.9 ? const _V(0, 1, 0) : const _V(1, 0, 0);
  final e1 = axis.cross(ref).unit;
  final e2 = axis.cross(e1).unit;
  final pa = ra > 0 ? _ring(cam, a, ra, e1, e2) : [cam.p(a)];
  final pb = rb > 0 ? _ring(cam, b, rb, e1, e2) : [cam.p(b)];
  final hull = _hull([...pa, ...pb]);
  Color o(Color c) => c.withValues(alpha: c.a * opacity);
  final sa = cam.p(a), sb = cam.p(b);
  var dir = sb - sa;
  if (dir.distance < 1e-3) dir = const Offset(0, -1);
  var n = Offset(-dir.dy, dir.dx) / dir.distance;
  if (n.dx < 0 || (n.dx.abs() < 1e-6 && n.dy < 0)) n = -n;
  final w = math.max(ra * cam.k(a), rb * cam.k(b)) + 0.5;
  final mid = (sa + sb) / 2;
  final paint = Paint();
  if (flat) {
    paint.color = o(color);
  } else {
    paint.shader = ui.Gradient.linear(
      mid - n * w,
      mid + n * w,
      [o(labShade(color, -0.35)), o(labShade(color, 0.28)), o(color), o(labShade(color, -0.45))],
      const [0, 0.3, 0.62, 1],
    );
  }
  canvas.drawPath(_poly(hull), paint);
  if (!caps) return;
  final cap = Paint()..color = o(capColor ?? labShade(color, 0.22));
  if (rb > 0 && (cam.eye - b).dot(axis) > 0) canvas.drawPath(_poly(pb), cap);
  if (ra > 0 && (cam.eye - a).dot(axis * -1) > 0) canvas.drawPath(_poly(pa), cap);
}

/// Axis-aligned box (Three.js BoxGeometry) centred at [c].
void _box(Canvas canvas, _Cam cam, _V c, _V size, Color color, {double opacity = 1}) {
  final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
  _V v(double sx, double sy, double sz) => _V(c.x + sx * hx, c.y + sy * hy, c.z + sz * hz);
  final faces = <(_V, List<_V>, double)>[
    (const _V(0, 1, 0), [v(-1, 1, -1), v(1, 1, -1), v(1, 1, 1), v(-1, 1, 1)], 0.2),
    (const _V(0, 0, 1), [v(-1, 1, 1), v(1, 1, 1), v(1, -1, 1), v(-1, -1, 1)], -0.02),
    (const _V(1, 0, 0), [v(1, 1, 1), v(1, 1, -1), v(1, -1, -1), v(1, -1, 1)], -0.18),
    (const _V(-1, 0, 0), [v(-1, 1, -1), v(-1, 1, 1), v(-1, -1, 1), v(-1, -1, -1)], -0.32),
    (const _V(0, -1, 0), [v(-1, -1, 1), v(1, -1, 1), v(1, -1, -1), v(-1, -1, -1)], -0.5),
    (const _V(0, 0, -1), [v(1, 1, -1), v(-1, 1, -1), v(-1, -1, -1), v(1, -1, -1)], -0.4),
  ];
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = labShade(color, -0.5).withValues(alpha: 0.5 * opacity);
  for (final (normal, quad, shade) in faces) {
    final fc = (quad[0] + quad[2]) * 0.5;
    if ((cam.eye - fc).dot(normal) <= 0) continue;
    final path = _poly([for (final q in quad) cam.p(q)]);
    canvas.drawPath(path, Paint()..color = labShade(color, shade).withValues(alpha: opacity));
    canvas.drawPath(path, edge);
  }
}

/// Oriented box: centre [c], unit axes [ax] [ay] [az] and half extents
/// (the pinwheel blades). Faces are flat-coloured, lightly shaded.
void _obox(Canvas canvas, _Cam cam, _V c, _V ax, _V ay, _V az, double hx, double hy, double hz, Color color,
    {double opacity = 1}) {
  final faces = <(_V, double, _V, double, _V, double)>[
    (ax, hx, ay, hy, az, hz),
    (ax * -1, hx, ay, hy, az, hz),
    (ay, hy, ax, hx, az, hz),
    (ay * -1, hy, ax, hx, az, hz),
    (az, hz, ax, hx, ay, hy),
    (az * -1, hz, ax, hx, ay, hy),
  ];
  for (final (n, hn, u, hu, v, hv) in faces) {
    final fc = c + n * hn;
    final facing = (cam.eye - fc).unit.dot(n);
    if (facing <= 0) continue;
    final quad = [
      cam.p(fc + u * hu + v * hv),
      cam.p(fc + u * hu - v * hv),
      cam.p(fc - u * hu - v * hv),
      cam.p(fc - u * hu + v * hv),
    ];
    canvas.drawPath(
      _poly(quad),
      Paint()..color = labShade(color, -0.25 + 0.3 * facing).withValues(alpha: opacity),
    );
  }
}

// ============================================================= PAINTER

class _RadiationPainter extends CustomPainter {
  _RadiationPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.text,
    this.labelScale = 1,
  }) : super(repaint: repaint);

  final _RadScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> text;
  final double labelScale;

  static const Color _wood = Color(0xFF8B5A2B);
  static const Color _skin = Color(0xFFDDCBA4);
  static const Color _black = Color(0xFF222222);
  static const Color _white = Color(0xFFEEEEEE);
  static const Color _grass = Color(0xFF4D8C31);
  static const Color _slate = Color(0xFF475569);
  static const Color _orange = Color(0xFFFF6600);

  late _Cam cam;
  double get t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    cam = _a4Cam(scene.scenario, scene.viewShift);
    if (scene.scenario == 0) {
      _paintOutdoor(canvas, size);
    } else {
      _paintBench(canvas, size);
    }
    if (showLabels) _paintLabels(canvas);
  }

  /// Colour under the HTML lights: ambient + the (warm) sun directional.
  Color _lit(Color c, [double facing = 1]) {
    final s = scene;
    final amb = s.scenario == 0 ? 0.8 : 0.5;
    final sun = s.scenario == 0 ? s.sunI.value : 0.2;
    final b = 0.32 + 0.6 * amb + 0.3 * sun * facing;
    final warm = (0.06 * sun).clamp(0.0, 1.0);
    double ch(double v, double w) => ((v * (1 - warm) + w * warm) * b).clamp(0.0, 1.0);
    return Color.from(alpha: c.a, red: ch(c.r, 1.0), green: ch(c.g, 0.96), blue: ch(c.b, 0.714));
  }

  /// Digital LCD readout (HTML `font-digital` red text on slate-900).
  void _lcd(Canvas canvas, String value, Offset at, double size) {
    labText(
      canvas,
      value,
      at,
      size: size * labelScale,
      weight: FontWeight.w800,
      color: const Color(0xFFEF4444),
      fontFamily: LabFont.active.family == null ? 'monospace' : null,
      background: const Color(0xE60F172A),
      border: _Colors.slate700,
      borderWidth: 1.2,
      radius: 5,
      padding: EdgeInsets.symmetric(horizontal: 7 * labelScale, vertical: 3 * labelScale),
      shadows: const [Shadow(color: Color(0x80EF4444), blurRadius: 5)],
      letterSpacing: 1,
    );
  }

  String _deg(double v) => (text['deg_c'] ?? '{t}°C').replaceAll('{t}', '${v.floor()}');

  void _paintLabels(Canvas canvas) {
    final s = scene;
    if (s.scenario == 0) {
      for (final (key, x) in const [('lbl_a', -4.0), ('lbl_b', 4.0)]) {
        labText(
          canvas,
          text[key]!,
          cam.pt(x, 7.5, 0),
          size: 15 * labelScale,
          weight: FontWeight.w800,
          color: _Colors.slate900,
          background: _Colors.slate200,
          border: _Colors.slate400,
          borderWidth: 1,
          padding: EdgeInsets.symmetric(horizontal: 9 * labelScale, vertical: 2 * labelScale),
        );
      }
      if (s.thermoA) _lcd(canvas, _deg(s.tempA), cam.pt(-4, 4.5, 1.3), 16);
      if (s.thermoB) _lcd(canvas, _deg(s.tempB), cam.pt(4, 4.5, 1.3), 16);
    } else {
      if (s.benchThermo) _lcd(canvas, _deg(s.bench), cam.pt(1, 0, 1), 20);
      if (s.vacuumLabel) {
        labText(
          canvas,
          text['lbl_vacuum']!,
          cam.pt(0, 6.5, 0),
          size: 16 * labelScale,
          weight: FontWeight.w800,
          letterSpacing: 3,
          color: Colors.white,
          background: const Color(0xE6DC2626),
          border: const Color(0xFF991B1B),
          borderWidth: 1.2,
          radius: 5,
          padding: EdgeInsets.symmetric(horizontal: 12 * labelScale, vertical: 4 * labelScale),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadiationPainter old) =>
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.scene != scene ||
      old.labelScale != labelScale;

  double _fade(String key) {
    final at = scene.placedAt[key];
    if (at == null) return 0;
    return ((t - at) / 0.35).clamp(0.0, 1.0);
  }

  // ------------------------------------------------- scenario 1 outdoors

  void _paintOutdoor(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    // Sky (HTML #sky-bg, theme dependent) and grid.
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF141E30), Color(0xFF243B55)]
              : const [Color(0xFF4CA1AF), Color(0xFFC4E0E5)],
        ).createShader(Offset.zero & size),
    );
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = (bleed.left / 40).floor() * 40.0; x < bleed.right; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    for (var y = (bleed.top / 40).floor() * 40.0; y < bleed.bottom; y += 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }

    // Visual sun (sphere r 3, follows the sun light).
    final sunPos = _V(scene.sunX.value, scene.sunY.value, scene.sunZ.value);
    final sc = cam.p(sunPos);
    final sr = 3 * cam.k(sunPos);
    labGlow(canvas, sc, sr * 3.2, const Color(0xFFFFD700), intensity: 0.55 + 0.3 * (scene.sunI.value - 0.5));
    canvas.drawCircle(sc, sr, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(sc, sr * 0.8, Paint()..color = const Color(0xFFFFE680));

    // Grass floor (50 x 50) to the horizon, extended across the letterbox.
    final horizon = cam.pt(0, 0, -25).dy;
    final ground = Rect.fromLTRB(bleed.left, horizon, bleed.right, bleed.bottom);
    canvas.drawRect(
      ground,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, horizon), Offset(0, size.height), [
          _lit(labShade(_grass, -0.18)),
          _lit(labShade(_grass, 0.08)),
        ]),
    );
    final blade = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = _lit(labShade(_grass, -0.25)).withValues(alpha: 0.55);
    final rnd = math.Random(5);
    for (var i = 0; i < 160; i++) {
      final x = (rnd.nextDouble() - 0.5) * 50, z = -24 + rnd.nextDouble() * 38;
      final p = cam.pt(x, 0, z);
      final h = 0.25 * cam.k(_V(x, 0, z));
      canvas.drawLine(p, p + Offset(-h * 0.3, -h), blade);
      canvas.drawLine(p, p + Offset(h * 0.3, -h * 0.9), blade);
    }
    canvas.drawLine(Offset(bleed.left, horizon), Offset(bleed.right, horizon), Paint()
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.18));

    _paintWardrobe(canvas);
    _mannequin(canvas, -4, shirt: scene.shirtA ? _black : null, shirtA: _fade('shirtA'), heat: (scene.tempA - 25) / 20);
    _mannequin(canvas, 4, shirt: scene.shirtB ? _white : null, shirtA: _fade('shirtB'), heat: (scene.tempB - 25) / 20 * 0.5);
    _paintRays(canvas);
    _paintToolbox(canvas);
  }

  /// Soft ground shadow cast away from the moving sun.
  void _groundShadow(Canvas canvas, double x, double z, double r, double h) {
    final sx = scene.sunX.value, sy = math.max(scene.sunY.value, 0.5), sz = scene.sunZ.value;
    var dx = -sx / sy, dz = -sz / sy;
    final len = math.sqrt(dx * dx + dz * dz);
    if (len > 1.1) {
      dx = dx / len * 1.1;
      dz = dz / len * 1.1;
    }
    final c = _V(x + dx * h * 0.45, 0.01, z + dz * h * 0.45);
    final path = _disc(cam, c, r * (1 + 0.15 * h / 4));
    canvas.drawPath(path, Paint()
      ..color = Colors.black.withValues(alpha: 0.18 + 0.1 * scene.sunI.value)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2, path.getBounds().height * 0.3)));
  }

  /// Cylinder T-shirt (HTML `buildTShirtMesh`): body plus two sleeves
  /// tilted 45 degrees, centred at [c] and scaled by [k].
  void _tshirt(Canvas canvas, _V c, double k, Color color, {double opacity = 1}) {
    final col = _lit(color);
    for (final side in [-1.0, 1.0]) {
      final axis = _V(side * 0.7071, 0.7071, 0);
      final mid = c + _V(side * 1.4 * k, 0.8 * k, 0);
      _tube(canvas, cam, mid - axis * (0.75 * k), mid + axis * (0.75 * k), 0.4 * k, 0.5 * k, col,
          opacity: opacity, capColor: labShade(col, -0.2));
    }
    _tube(canvas, cam, c - _V(0, 1.75 * k, 0), c + _V(0, 1.75 * k, 0), 1.2 * k, 1.3 * k, col,
        opacity: opacity, caps: false);
    // Hem and collar lines for a fabric look.
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = labShade(col, color.computeLuminance() > 0.5 ? -0.25 : 0.25).withValues(alpha: 0.6 * opacity);
    final hem = [
      for (var i = 0; i <= 16; i++)
        cam.p(c + _V(1.21 * k * math.cos(math.pi * i / 16), -1.55 * k, 1.21 * k * math.sin(math.pi * i / 16))),
    ];
    canvas.drawPath(Path()..addPolygon(hem, false), seam);
  }

  void _paintWardrobe(Canvas canvas) {
    const w = _V(-12, 0, -4);
    final wood = _lit(_wood);
    _groundShadow(canvas, -12, -4, 3.4, 6);
    _box(canvas, cam, w + const _V(0, 6, -2), const _V(6, 12, 0.2), labShade(wood, -0.25));
    _box(canvas, cam, w + const _V(-2.9, 6, 0), const _V(0.2, 12, 4), wood);
    _box(canvas, cam, w + const _V(0, 0.1, 0), const _V(6, 0.2, 4), wood);
    _box(canvas, cam, w + const _V(0, 11.9, 0), const _V(6, 0.2, 4), wood);
    // Rack pole and the two shirts hanging inside.
    _tube(canvas, cam, w + const _V(-2.9, 10, 0), w + const _V(2.9, 10, 0), 0.1, 0.1, _lit(const Color(0xFFAAAAAA)));
    final hook = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = _lit(const Color(0xFF9CA3AF));
    for (final (dx, visible, color) in [(-1.5, !scene.shirtA, _black), (1.5, !scene.shirtB, _white)]) {
      if (!visible) continue;
      final top = w + _V(dx, 7.5 + 1.225, 0);
      canvas.drawLine(cam.p(w + _V(dx, 10, 0)), cam.p(top), hook);
      canvas.drawLine(cam.p(top + const _V(-0.8, -0.1, 0)), cam.p(w + _V(dx, 9.6, 0)), hook);
      canvas.drawLine(cam.p(top + const _V(0.8, -0.1, 0)), cam.p(w + _V(dx, 9.6, 0)), hook);
      _tshirt(canvas, w + _V(dx, 7.5, 0), 0.7, color);
    }
    _box(canvas, cam, w + const _V(2.9, 6, 0), const _V(0.2, 12, 4), wood);
    // Open doors (rotated +/-60 degrees about Y).
    for (final (cx, th) in [(-4.4, math.pi / 3), (4.4, -math.pi / 3)]) {
      final ax = _V(math.cos(th), 0, -math.sin(th));
      final az = _V(math.sin(th), 0, math.cos(th));
      _obox(canvas, cam, w + _V(cx, 6, 1.4), ax, const _V(0, 1, 0), az, 1.5, 5.9, 0.1, wood);
      final knob = w + _V(cx, 6, 1.4) + ax * (cx < 0 ? 1.2 : -1.2) + az * 0.15;
      canvas.drawCircle(cam.p(knob), 0.13 * cam.k(knob), Paint()..color = _lit(const Color(0xFFD4AF37)));
    }
  }

  void _mannequin(Canvas canvas, double x, {Color? shirt, double shirtA = 0, double heat = 0}) {
    _groundShadow(canvas, x, 0, 1.6, 7);
    _tube(canvas, cam, _V(x, 0, 0), _V(x, 0.2, 0), 1.5, 1.5, _lit(const Color(0xFF333333)));
    _tube(canvas, cam, _V(x, 0.2, 0), _V(x, 2.95, 0), 0.1, 0.1, _lit(_wood));
    final skin = _lit(_skin);
    if (shirt == null || shirtA < 1) {
      _tube(canvas, cam, _V(x, 2.9, 0), _V(x, 6.1, 0), 0.9, 1.1, skin, caps: false);
    }
    if (shirt != null) {
      if (heat > 0.01) {
        labGlow(canvas, cam.pt(x, 4.6, 0.6), 2.6 * cam.k(_V(x, 4.6, 0)), const Color(0xFFFF5A1F),
            intensity: (heat * 0.75).clamp(0.0, 0.75));
      }
      _tshirt(canvas, _V(x, 4.5, 0), 1, shirt, opacity: shirtA);
    }
    _tube(canvas, cam, _V(x, 5.75, 0), _V(x, 7.25, 0), 0.5, 0.4, skin, caps: false);
    canvas.drawPath(_disc(cam, _V(x, 7.25, 0), 0.4), Paint()..color = labShade(skin, -0.15));
    // Clip-on sensor once a thermometer is attached.
    final attached = x < 0 ? scene.thermoA : scene.thermoB;
    if (attached) {
      final p = _V(x, 4.5, 1.25);
      canvas.drawCircle(cam.p(p), 0.22 * cam.k(p), Paint()..color = const Color(0xFF64748B));
    }
  }

  /// Falling radiation streaks while time is fast-forwarded.
  void _paintRays(Canvas canvas) {
    const d = _V(-0.4472, -0.8944, 0); // direction of travel
    for (final r in scene.rays) {
      if (r.opacity <= 0) continue;
      final c = _V(r.x, r.y, r.z);
      final a = cam.p(c - d), b = cam.p(c + d);
      canvas.drawLine(a, b, Paint()
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFCC00).withValues(alpha: 0.25 * r.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawLine(a, b, Paint()
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFCC00).withValues(alpha: r.opacity));
    }
  }

  void _paintToolbox(Canvas canvas) {
    _groundShadow(canvas, 0, 4, 1.8, 2);
    _box(canvas, cam, const _V(0, 0.75, 4), const _V(3, 1.5, 2), _lit(const Color(0xFF64748B)));
    _box(canvas, cam, const _V(0, 1.75, 4), const _V(3, 0.5, 2), _lit(const Color(0xFFE87834)));
    final handle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.14 * cam.k(const _V(0, 2, 4))
      ..strokeCap = StrokeCap.round
      ..color = _lit(const Color(0xFF334155));
    canvas.drawPath(
      Path()
        ..moveTo(cam.pt(-0.6, 2.0, 4).dx, cam.pt(-0.6, 2.0, 4).dy)
        ..lineTo(cam.pt(-0.6, 2.35, 4).dx, cam.pt(-0.6, 2.35, 4).dy)
        ..lineTo(cam.pt(0.6, 2.35, 4).dx, cam.pt(0.6, 2.35, 4).dy)
        ..lineTo(cam.pt(0.6, 2.0, 4).dx, cam.pt(0.6, 2.0, 4).dy),
      handle,
    );
  }

  // --------------------------------------------------- scenario 2 bench

  void _paintBench(Canvas canvas, Size size) {
    final s = scene;
    final bleed = labBleed(size);
    final lampGlow = (s.lampI.value / 2).clamp(0.0, 1.0);
    // Wall (50 x 30 at z = -6), filling the whole background.
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lit(labShade(const Color(0xFF94A3B8), 0.05)), _lit(labShade(const Color(0xFF94A3B8), -0.25))],
        ).createShader(Offset.zero & size),
    );
    if (lampGlow > 0) {
      final c = cam.pt(-2, 3, -6);
      labGlow(canvas, c, 9 * cam.k(const _V(-2, 3, -6)), _orange, intensity: 0.45 * lampGlow);
    }
    // Shelf.
    _box(canvas, cam, const _V(-6, 8, -4.5), const _V(12, 0.5, 3), _lit(const Color(0xFFCBD5E1)));

    // Table legs (lengthened into the letterbox) and slate table top.
    for (final z in [-4.0, 4.0]) {
      for (final x in [-9.0, 9.0]) {
        _box(canvas, cam, _V(x, -20, z), const _V(1, 39, 1), _lit(_slate));
      }
    }
    final top = _poly([cam.pt(-10, 0, -5), cam.pt(10, 0, -5), cam.pt(10, 0, 5), cam.pt(-10, 0, 5)]);
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lit(labShade(_slate, -0.1)), _lit(labShade(_slate, 0.1))],
        ).createShader(top.getBounds()),
    );
    canvas.drawPath(
      _poly([cam.pt(-10, 0, 5), cam.pt(10, 0, 5), cam.pt(10, -1, 5), cam.pt(-10, -1, 5)]),
      Paint()..color = _lit(labShade(_slate, -0.3)),
    );
    canvas.drawLine(cam.pt(-10, 0, 5), cam.pt(10, 0, 5), Paint()
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.25));
    if (lampGlow > 0) {
      final pool = _disc(cam, const _V(-2, 0.01, 0), 6);
      canvas.drawPath(
        pool,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(colors: [
            _orange.withValues(alpha: 0.45 * lampGlow),
            _orange.withValues(alpha: 0),
          ]).createShader(pool.getBounds()),
      );
    }

    final lampA = s.lamp ? _fade('lamp') : 0.0;
    if (lampA > 0) _lamp(canvas, lampA, lampGlow);
    if (s.benchThermo) _benchThermometer(canvas, _fade('thermo'));

    // Radiation waves leaving the lamp and air being pumped out.
    for (final w in s.waves) {
      if (w.opacity <= 0) continue;
      final p = _V(w.x, w.y, w.z);
      final c = cam.p(p);
      final r = math.max(2.5, 0.1 * cam.k(p) * 1.4);
      canvas.drawCircle(c, r * 2.6, Paint()..color = _orange.withValues(alpha: 0.25 * w.opacity));
      canvas.drawCircle(c, r, Paint()..color = _orange.withValues(alpha: w.opacity.clamp(0.0, 1.0)));
    }
    for (final a in s.air) {
      if (a.opacity <= 0) continue;
      final p = _V(a.x, a.y, a.z);
      canvas.drawCircle(cam.p(p), math.max(2.2, 0.08 * cam.k(p) * 1.4), Paint()..color = Colors.white.withValues(alpha: a.opacity));
    }

    final jarA = s.jar ? _fade('jar') : 0.0;
    if (jarA > 0) _bellJar(canvas, jarA);
    final pumpA = s.pump ? _fade('pump') : 0.0;
    if (pumpA > 0) _pump(canvas, pumpA);
  }

  void _lamp(Canvas canvas, double a, double glow) {
    const x = -2.0;
    final shadow = _disc(cam, const _V(x - 0.4, 0.01, -0.4), 1.8);
    canvas.drawPath(shadow, Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * a)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    _tube(canvas, cam, const _V(x, 0, 0), const _V(x, 0.3, 0), 1.5, 1.5, _lit(const Color(0xFF222222)), opacity: a);
    _tube(canvas, cam, const _V(x, 0.3, 0), const _V(x, 3.3, 0), 0.2, 0.2, _lit(const Color(0xFF555555)), opacity: a);
    final bulb = cam.pt(x, 3, 0);
    final bk = cam.k(const _V(x, 3, 0));
    if (scene.lampOn) {
      labSphere(canvas, bulb, 0.5 * bk, _orange, highlight: 0.6, shade: 0.1, opacity: a);
    } else {
      labSphere(canvas, bulb, 0.5 * bk, const Color(0xFF555555), opacity: a);
    }
    _tube(canvas, cam, const _V(x, 2.5, 0), const _V(x, 4.5, 0), 1.5, 0, _lit(const Color(0xFF94A3B8)), opacity: a);
    if (glow > 0) {
      labGlow(canvas, bulb + Offset(0, 0.4 * bk), 3.2 * bk, _orange, intensity: 0.8 * glow * a);
      labGlow(canvas, bulb + Offset(0, 0.4 * bk), 1.1 * bk, const Color(0xFFFFE0B2), intensity: 0.9 * glow * a);
    }
  }

  /// Small digital thermometer standing on the bench next to the lamp.
  void _benchThermometer(Canvas canvas, double a) {
    _box(canvas, cam, const _V(1, 0.25, 0.6), const _V(1.4, 0.5, 0.6), _lit(const Color(0xFF334155)), opacity: a);
    _tube(canvas, cam, const _V(0.6, 0.5, 0.6), const _V(0.6, 2.2, 0.6), 0.07, 0.07, _lit(const Color(0xFFCBD5E1)), opacity: a);
    final tip = cam.pt(0.6, 2.2, 0.6);
    canvas.drawCircle(tip, 0.12 * cam.k(const _V(0.6, 2.2, 0.6)), Paint()..color = const Color(0xFFEF4444).withValues(alpha: a));
  }

  void _bellJar(Canvas canvas, double a) {
    const e1 = _V(1, 0, 0), e2 = _V(0, 0, 1);
    final pts = <Offset>[
      ..._ring(cam, const _V(0, 0, 0), 3.5, e1, e2, seg: 40),
      for (var i = 0; i <= 8; i++)
        ..._ring(cam, _V(0, 6 + 3.5 * math.sin(i / 8 * math.pi / 2), 0), 3.5 * math.cos(i / 8 * math.pi / 2), e1, e2,
            seg: 40),
      cam.pt(0, 9.5, 0),
    ];
    final body = _poly(_hull(pts));
    final b = body.getBounds();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16 * a),
            Colors.white.withValues(alpha: 0.05 * a),
            Colors.white.withValues(alpha: 0.03 * a),
            Colors.white.withValues(alpha: 0.14 * a),
          ],
          stops: const [0, 0.25, 0.7, 1],
        ).createShader(b),
    );
    canvas.drawPath(body, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.5 * a));
    final k = cam.k(const _V(0, 3, 3.5));
    // Base ring (torus r 3.5, tube 0.2) and a highlight streak.
    canvas.drawPath(_disc(cam, const _V(0, 0.05, 0), 3.5), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 * k
      ..color = Colors.white.withValues(alpha: 0.45 * a));
    canvas.drawLine(cam.pt(-2.4, 0.8, 2.4), cam.pt(-2.4, 6.2, 2.4), Paint()
      ..strokeWidth = 0.35 * k
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.25 * a));
    // Knob and side nozzle.
    _tube(canvas, cam, const _V(0, 9.25, 0), const _V(0, 9.75, 0), 0.5, 0.5, Colors.white.withValues(alpha: 0.55),
        opacity: a);
    _tube(canvas, cam, const _V(3, 4, 0), const _V(4, 4, 0), 0.3, 0.3, _lit(const Color(0xFF888888)), opacity: a);
  }

  void _pump(Canvas canvas, double a) {
    final s = scene;
    final jitter = s.vacuumOn ? Offset(math.sin(t * 60) * 1.2, math.cos(t * 47) * 0.8) : Offset.zero;
    canvas.save();
    canvas.translate(jitter.dx, jitter.dy);
    final shadow = _disc(cam, const _V(7.6, 0.01, -0.4), 2.6);
    canvas.drawPath(shadow, Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * a)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    _box(canvas, cam, const _V(8, 1.5, 0), const _V(4, 3, 3), _lit(const Color(0xFF94A3B8)), opacity: a);
    // Gauge facing the viewer.
    final gc = const _V(8, 1.5, 1.61);
    final dial = _poly(_ring(cam, gc, 0.8, const _V(1, 0, 0), const _V(0, 1, 0), seg: 28));
    canvas.drawPath(dial, Paint()..color = const Color(0xFFEEEEEE).withValues(alpha: a));
    canvas.drawPath(dial, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF475569).withValues(alpha: a));
    final needle = s.vacuumOn || s.vacuumLabel ? -0.6 - 1.6 * math.min(1.0, s.vacuumTimer / 150) : -0.6;
    final tipV = gc + _V(0.6 * math.sin(needle + math.pi / 2) * -1, 0.6 * math.cos(needle + math.pi / 2) * -1, 0);
    canvas.drawLine(cam.p(gc), cam.p(tipV), Paint()
      ..strokeWidth = 2
      ..color = const Color(0xFFDC2626).withValues(alpha: a));
    canvas.restore();
    // Hose (Catmull-Rom through the HTML points) into the jar.
    final pts = [cam.pt(6.5, 1.5, 0), cam.pt(5, 1.5, 0), cam.pt(4, 1, 0), cam.pt(3, 1, 0)];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[math.max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[math.min(pts.length - 1, i + 2)];
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx, p2.dy,
      );
    }
    final hk = cam.k(const _V(5, 1.2, 0));
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 * hk
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF222222).withValues(alpha: a));
    canvas.drawPath(path.shift(Offset(0, -0.08 * hk)), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.25 * a));
  }
}

// ======================================================== UI PAINTERS

/// Inventory tiles with the HTML `SVGIcons` glyphs (24 x 24 viewBox).
class _ItemIconPainter extends CustomPainter {
  _ItemIconPainter({required this.item, this.hint = false, this.scene, super.repaint});

  final _Item item;
  final bool hint;
  final _RadScene? scene;

  static Color tileColor(_Item item) => switch (item) {
        _Item.blackShirt => const Color(0xFF1E293B),
        _Item.whiteShirt => const Color(0xFFE2E8F0),
        _Item.thermometer => const Color(0xFF6366F1),
        _Item.heatlamp => const Color(0xFFF97316),
        _Item.belljar => const Color(0xFF0891B2),
        _Item.vacuumpump => const Color(0xFF2563EB),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width * 0.22));
    if (hint && scene != null) {
      final pulse = 0.5 + 0.5 * math.sin(scene!.time * math.pi);
      canvas.drawRRect(
        rr.inflate(2 + 2 * pulse),
        Paint()
          ..color = _Colors.zslYellow.withValues(alpha: 0.35 + 0.4 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    canvas.drawRRect(rr, Paint()..color = tileColor(item));
    canvas.drawRRect(
      rr.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.2),
    );
    final k = size.width * (8 / 14) / 24;
    canvas.save();
    canvas.translate(size.width / 2 - 12 * k, size.height / 2 - 12 * k);
    canvas.scale(k);
    switch (item) {
      case _Item.blackShirt:
      case _Item.whiteShirt:
        final fill = item == _Item.blackShirt ? Colors.white : const Color(0xFF1E293B);
        canvas.drawPath(
          _poly(const [
            Offset(7, 4), Offset(4, 7), Offset(4, 10), Offset(6, 10), Offset(6, 20), //
            Offset(18, 20), Offset(18, 10), Offset(20, 10), Offset(20, 7), Offset(17, 4),
          ]),
          Paint()..color = fill,
        );
      case _Item.thermometer:
        final outer = Path()
          ..addRRect(RRect.fromLTRBR(9, 2, 15, 15, const Radius.circular(3)))
          ..addOval(Rect.fromCircle(center: const Offset(12, 16.5), radius: 5));
        final inner = Path()
          ..addRRect(RRect.fromLTRBR(11, 4, 13, 15, const Radius.circular(1)))
          ..addOval(Rect.fromCircle(center: const Offset(12, 16.5), radius: 3));
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, inner),
          Paint()..color = const Color(0xFF94A3B8),
        );
        canvas.drawRRect(RRect.fromLTRBR(10, 15, 14, 17, const Radius.circular(1)), Paint()..color = const Color(0xFFEF4444));
      case _Item.heatlamp:
        final p = Paint()..color = Colors.white;
        canvas.drawPath(
          Path()
            ..moveTo(12, 2)
            ..arcToPoint(const Offset(6, 8), radius: const Radius.circular(6), clockwise: false)
            ..lineTo(6, 12)
            ..lineTo(18, 12)
            ..lineTo(18, 8)
            ..arcToPoint(const Offset(12, 2), radius: const Radius.circular(6), clockwise: false)
            ..close(),
          p,
        );
        canvas.drawRect(const Rect.fromLTWH(10, 14, 4, 6), p);
        canvas.drawRect(const Rect.fromLTWH(6, 12, 12, 2), p);
        canvas.drawRect(const Rect.fromLTWH(10, 22, 4, 2), p);
      case _Item.belljar:
        final outer = Path()
          ..moveTo(12, 2)
          ..cubicTo(7, 2, 4, 6, 4, 12)
          ..lineTo(4, 20)
          ..lineTo(20, 20)
          ..lineTo(20, 12)
          ..cubicTo(20, 6, 17, 2, 12, 2)
          ..close();
        final inner = Path()
          ..moveTo(18, 20)
          ..lineTo(6, 20)
          ..lineTo(6, 12)
          ..cubicTo(6, 7.6, 8.7, 4, 12, 4)
          ..cubicTo(15.3, 4, 18, 7.6, 18, 12)
          ..close();
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, inner),
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
      case _Item.vacuumpump:
        canvas.drawPath(
          Path.combine(
            PathOperation.difference,
            Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 10)),
            Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8)),
          ),
          Paint()..color = const Color(0xFF94A3B8),
        );
        final blue = Paint()..color = const Color(0xFF93C5FD);
        canvas.drawRRect(RRect.fromLTRBR(11, 6, 13, 12, const Radius.circular(1)), blue);
        canvas.drawRRect(RRect.fromLTRBR(16, 10.5, 17, 13.5, const Radius.circular(0.5)), blue);
        canvas.drawRRect(RRect.fromLTRBR(7, 10.5, 8, 13.5, const Radius.circular(0.5)), blue);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ItemIconPainter old) => old.item != item || old.hint != hint;
}

/// Dashed yellow border of the "DROP HERE" zone.
class _DropZonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22));
    canvas.drawRRect(rr, Paint()..color = _Colors.zslYellow.withValues(alpha: 0.12));
    labDashedPath(
      canvas,
      Path()..addRRect(rr.deflate(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = _Colors.zslYellow.withValues(alpha: 0.65),
      dash: 12,
      gap: 8,
    );
  }

  @override
  bool shouldRepaint(covariant _DropZonePainter old) => false;
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
