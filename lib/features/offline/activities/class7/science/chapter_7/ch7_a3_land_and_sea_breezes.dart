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

/// Class 7 Science • Chapter 7 • Activity 3
/// Land and Sea Breezes.
///
/// Native Flutter port of `Cl7S-Ch7-A3-Land_and_Sea_Breezes.html`.
/// Scenario 1: drag the sun / moon into the sky and compare how fast soil
/// and water heat up and cool down (thermometers, timer and a live graph).
/// Scenario 2: a coastal diorama where convection arrows and a pinwheel
/// show the sea breeze by day and the land breeze by night.
class Ch7A3LandAndSeaBreezesPage extends StatefulWidget {
  const Ch7A3LandAndSeaBreezesPage({super.key});

  @override
  State<Ch7A3LandAndSeaBreezesPage> createState() => _Ch7A3LandAndSeaBreezesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356.
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

// =============================================================== MODEL

const Size _design = Size(1000, 560);

/// One fixed simulation tick of the HTML `requestAnimationFrame` loop.
const double _tickSeconds = 1 / 60;

/// Minimal TWEEN.js stand-in driven by the scene clock.
class _Tw {
  _Tw(this.value);
  double value;
  double _from = 0, _to = 0, _t0 = 0, _dur = 0;
  Curve _curve = Curves.linear;

  void to(double target, double now, double seconds, [Curve curve = Curves.linear]) {
    _from = value;
    _to = target;
    _t0 = now;
    _dur = seconds;
    _curve = curve;
    if (seconds <= 0) set(target);
  }

  void set(double v) {
    value = v;
    _dur = 0;
  }

  void update(double now) {
    if (_dur <= 0) return;
    final k = ((now - _t0) / _dur).clamp(0.0, 1.0);
    value = _from + (_to - _from) * _curve.transform(k);
    if (k >= 1) _dur = 0;
  }
}

/// A convection arrow riding an elliptical loop centred at (0, 6).
class _Arrow {
  _Arrow(this.angle, this.rx, this.ry, this.speed, this.z);
  double angle;
  final double rx, ry, speed, z;
  double get x => math.cos(angle) * rx;
  double get y => 6 + math.sin(angle) * ry;
}

enum _Body { sun, moon }

/// Mutable scene model read by the painters every frame.
class _BreezeScene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  double viewShift = 0;

  // HTML lights: ambient 0.8 -> 0.9 (day) / 0.4 (night), sun 0 -> 1.5,
  // moon 0 -> 1.0; sky cross-fade (0 day .. 1 night).
  final _Tw ambient = _Tw(0.8), sun = _Tw(0), moon = _Tw(0), night = _Tw(0);
  final _Tw sunAlpha = _Tw(0), moonAlpha = _Tw(0);
  Offset? sunPos, moonPos;
  bool? isDay;

  // Scenario 1 (graph, timer, thermometers).
  bool graphVisible = false, graphRunning = false;
  int gTime = 0;
  double soilTemp = 20, waterTemp = 20;
  final List<Offset> soilData = [], waterData = [];

  // Scenario 2 (glows, arrows, pinwheel).
  final _Tw landGlow = _Tw(0), seaGlow = _Tw(0);
  bool particlesRunning = false, particlesVisible = false, airflowButton = false;
  double pinwheel = 0;
  final List<_Arrow> arrows = [];

  /// HTML `buildScenario()` + the per-scenario part of `resetApp(true)`.
  void build(math.Random rnd) {
    step = 1;
    for (final tw in [sun, moon, night, sunAlpha, moonAlpha, landGlow, seaGlow]) {
      tw.set(0);
    }
    ambient.set(0.8);
    sunPos = moonPos = null;
    isDay = null;
    graphVisible = graphRunning = false;
    gTime = 0;
    soilTemp = waterTemp = 20;
    soilData.clear();
    waterData.clear();
    particlesRunning = particlesVisible = airflowButton = false;
    pinwheel = 0;
    arrows.clear();
    if (scenario == 1) {
      for (var ring = 0; ring < 3; ring++) {
        for (var i = 0; i < 35; i++) {
          arrows.add(
            _Arrow(
              (i / 35) * math.pi * 2 + (rnd.nextDouble() - 0.5) * 0.1,
              8 + ring * 1.5 + (rnd.nextDouble() - 0.5) * 0.5,
              5 + ring * 1.2 + (rnd.nextDouble() - 0.5) * 0.5,
              0.015 + rnd.nextDouble() * 0.005,
              (rnd.nextDouble() - 0.5) * 3,
            ),
          );
        }
      }
    }
  }

  void updateTweens(double now) {
    for (final tw in [ambient, sun, moon, night, sunAlpha, moonAlpha, landGlow, seaGlow]) {
      tw.update(now);
    }
  }

  /// Digital timer: 200 ticks = 15:00 simulated minutes.
  String get timerText {
    final secs = (gTime / 200 * 900).floor();
    final m = secs ~/ 60, sec = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

// =============================================================== STATE

class _Ch7A3LandAndSeaBreezesPageState extends State<Ch7A3LandAndSeaBreezesPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: false);
  final _BreezeScene _scene = _BreezeScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final GlobalKey _layerKey = GlobalKey();
  final GlobalKey _stageKey = GlobalKey();

  late final Ticker _ticker;
  double _acc = 0;

  /// Which icons the tray shows (HTML `icon-sun` / `icon-moon` display).
  bool _sunIcon = true, _moonIcon = false;
  _Body? _dragBody;
  Offset? _dragGlobal;

  /// Graph card position (canvas coordinates) once the student moves it.
  Offset? _graphPos;
  bool _done = false;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.build(_rnd);
    _ticker = createTicker(_tick)..start();
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

  // ------------------------------------------------------------ frame loop

  void _tick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    s.viewShift += ((_lab.isSidebarOpen ? 0.0 : 90.0) - s.viewShift) * math.min(1.0, dt * 6);
    s.updateTweens(now);
    // The HTML advances its graph / arrows once per animation frame; run
    // the same logic at a fixed 60 Hz so timings match on any device.
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

  void _fixedStep() {
    final s = _scene;
    if (s.scenario == 0) {
      _graphTick();
    } else if (s.particlesRunning) {
      final day = s.isDay ?? true;
      final dir = day ? -1.0 : 1.0;
      for (final a in s.arrows) {
        a.angle += a.speed * dir;
      }
      s.pinwheel += day ? 0.15 : -0.15;
    }
  }

  /// HTML `updateGraphData()`.
  void _graphTick() {
    final s = _scene;
    if (!s.graphRunning) return;
    s.gTime++;
    if (s.isDay == true) {
      if (s.soilTemp < 80) s.soilTemp += 0.35;
      if (s.waterTemp < 40) s.waterTemp += 0.1;
    } else {
      if (s.soilTemp > 20) s.soilTemp -= 0.4;
      if (s.waterTemp > 20) s.waterTemp -= 0.15;
    }
    s.soilData.add(Offset(s.gTime.toDouble(), s.soilTemp));
    s.waterData.add(Offset(s.gTime.toDouble(), s.waterTemp));
    if (s.gTime >= 200) {
      s.graphRunning = false;
      if (s.step == 2 || s.step == 4) _advanceStep();
    }
  }

  // -------------------------------------------------------------- logic

  void _buildScenario() {
    _lab.cancelPending();
    _done = false;
    _sunIcon = true;
    _moonIcon = false;
    _dragBody = null;
    _dragGlobal = null;
    _graphPos = null;
    _scene.build(_rnd);
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

  /// HTML `advanceStep()`: reaching the last step shows the conclusion.
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

  /// HTML `executeCelestialDrop()`. [at] is the drop point in design
  /// coordinates (where the sun / moon is drawn).
  void _executeDrop(_Body body, Offset? at) {
    final s = _scene;
    final now = s.time;
    final isSun = body == _Body.sun;
    _Audio.play(_Sound.drop);
    final pos = Offset((at?.dx ?? 260).clamp(110.0, 890.0), (at?.dy ?? 110).clamp(55.0, 215.0));
    setState(() {
      s.isDay = isSun;
      s.night.to(isSun ? 0 : 1, now, 2, Curves.easeInOut);
      s.ambient.to(isSun ? 0.9 : 0.4, now, 1);
      s.sun.to(isSun ? 1.5 : 0, now, 1);
      s.moon.to(isSun ? 0 : 1.0, now, 1);
      if (isSun) {
        s.sunPos = pos;
        s.sunAlpha.to(1, now, 0.6);
        s.moonAlpha.to(0, now, 0.6);
      } else {
        s.moonPos = pos;
        s.moonAlpha.to(1, now, 0.6);
        s.sunAlpha.to(0, now, 0.6);
      }
      _sunIcon = !isSun;
      _moonIcon = isSun;

      if (s.scenario == 0) {
        s.gTime = 0;
        s.soilData.clear();
        s.waterData.clear();
        if (isSun) {
          s.soilTemp = 20;
          s.waterTemp = 20;
          s.graphVisible = true;
        }
        s.graphRunning = true;
      } else {
        s.particlesRunning = false;
        s.particlesVisible = false;
        if (isSun) {
          s.landGlow.to(0.6, now, 2);
          s.seaGlow.to(0, now, 1);
        } else {
          s.landGlow.to(0, now, 1);
          s.seaGlow.to(0.6, now, 2);
        }
        // At night the learner is asked only to observe; begin the reverse
        // airflow automatically rather than requiring an unmentioned tap.
        s.airflowButton = isSun;
        if (!isSun) {
          _lab.after(const Duration(milliseconds: 1800), _showAirFlow);
        }
      }
    });
    _lab.showToast(_t(isSun ? 'msg_sun_placed' : 'msg_moon_placed'), sound: false);
    if ((isSun && s.step == 1) || (!isSun && s.step == 3)) _advanceStep();
  }

  /// HTML `triggerSimulation()` ("Show Air Flow").
  void _showAirFlow() {
    final s = _scene;
    setState(() {
      s.airflowButton = false;
      s.particlesRunning = true;
      s.particlesVisible = true;
    });
    if (s.scenario == 1 && (s.step == 2 || s.step == 4)) _advanceStep();
  }

  // ------------------------------------------------- sun / moon dragging

  bool _iconValid(_Body b) => (_scene.step == 1 && b == _Body.sun) || (_scene.step == 3 && b == _Body.moon);

  /// HTML icon `pointerdown`: validates the body for the current step.
  void _iconDown(_Body b, Offset global) {
    if (!_lab.isLabActive || _dragBody != null || _scene.step == 5) return;
    if (!_iconValid(b)) {
      _lab.showToast(_t('msg_wrong_icon'), isError: true);
      return;
    }
    _Audio.play(_Sound.pickup);
    setState(() {
      _dragBody = b;
      _dragGlobal = global;
    });
  }

  void _iconMove(Offset global) {
    if (_dragBody == null) return;
    setState(() => _dragGlobal = global);
  }

  /// HTML `endDragHandler`: a release in the top 45 % (the sky) drops it.
  void _iconUp() {
    final b = _dragBody, g = _dragGlobal;
    if (b == null || g == null) return;
    setState(() {
      _dragBody = null;
      _dragGlobal = null;
    });
    final box = _layerKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(g);
    if (local.dy < box.size.height * 0.45) {
      _executeDrop(b, labGlobalToLocal(_stageKey, g));
    } else {
      _Audio.play(_Sound.wrong);
    }
  }

  // ----------------------------------------------------------------- UI

  List<LabAction> _actions() {
    if (_scene.scenario != 1 || !_scene.airflowButton || _done) return const [];
    return [
      LabAction(
        label: _t('btn_show_airflow'),
        icon: Icons.air,
        color: _Colors.slate800,
        foreground: Colors.white,
        highlight: true,
        onTap: _showAirFlow,
      ),
    ];
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
      TextSpan(
        children: [
          TextSpan(
            text: '$head\n',
            style: const TextStyle(color: _Colors.zslYellow, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: body),
        ],
      ),
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

  double _trayIconSize(double s) => math.min(42 * s, 46.0);

  /// HTML `#ui-inventory`: the draggable sun / moon icons.
  Widget _tray(LabPalette p, double s, EdgeInsets inset) {
    final collapsed = !_lab.isSidebarOpen;
    final pad = MediaQuery.paddingOf(context);
    final size = _trayIconSize(s);
    final bodies = [if (_sunIcon) _Body.sun, if (_moonIcon) _Body.moon];
    return Positioned(
      left: collapsed ? 8 + pad.left : inset.left,
      top: collapsed ? 76 + pad.top : inset.top,
      child: _lowSlop(
        LabGlassCard(
          palette: p,
          radius: 12,
          padding: EdgeInsets.all(math.min(5 * s, 6.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final b in bodies)
                Opacity(
                  opacity: _dragBody != null && _dragBody != b ? 0.5 : 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (d) => _iconDown(b, d.globalPosition),
                    onPanUpdate: (d) => _iconMove(d.globalPosition),
                    onPanEnd: (_) => _iconUp(),
                    onPanCancel: _iconUp,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: Size.square(size),
                          painter: _BodyIconPainter(
                            body: b,
                            hint: _iconValid(b) && _dragBody == null && _lab.isLabActive,
                            scene: _scene,
                            repaint: _frame,
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        SizedBox(
                          width: size,
                          child: Text(
                            _t(b == _Body.sun ? 'item_sun' : 'item_moon'),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: p.text, fontSize: 9.5 * s, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Short drags start immediately (Flutter's default pan slop is 36 px).
  Widget _lowSlop(Widget child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
    child: child,
  );

  /// Sky drop zone (top 45 %) and the dragged icon following the finger.
  Widget _dragLayer(double s) {
    final size = _trayIconSize(s);
    Offset? local;
    if (_dragGlobal != null) {
      final box = _layerKey.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) local = box.globalToLocal(_dragGlobal!);
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, c) => Stack(
            key: _layerKey,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: c.maxHeight * 0.45,
                child: AnimatedOpacity(
                  opacity: _dragBody != null ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Center(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _frame,
                      builder: (context, tm, _) => Opacity(
                        opacity: 0.6 + 0.4 * (0.5 + 0.5 * math.cos(tm * math.pi)),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: CustomPaint(
                            painter: _DashedBoxPainter(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 10 * s),
                              child: Text(
                                _t('drop_sky_here'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18 * s,
                                  letterSpacing: 2,
                                  shadows: const [Shadow(color: Color(0x66000000), blurRadius: 6)],
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
              if (_dragBody != null && local != null)
                Positioned(
                  left: local.dx - size * 0.6,
                  top: local.dy - size * 0.6,
                  child: Transform.scale(
                    scale: 1.2,
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _BodyIconPainter(body: _dragBody!, hint: false, scene: _scene, repaint: _frame),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _graphWidth(double s) => (165 * s).clamp(130.0, 240.0);

  /// HTML `#digital-timer-container` (LCD style).
  Widget _timerOverlay(double s, EdgeInsets inset) {
    final trayW = _lab.isSidebarOpen ? _trayIconSize(s) + 20 : 0.0;
    final graphW = _scene.graphVisible && _graphPos == null ? _graphWidth(s) + 8 : 0.0;
    // A monospace face in the app; the test font hook when it is set.
    final family = LabFont.active.family ?? 'monospace';
    final fallback = [...?LabFont.active.fallback, 'Courier', 'Menlo'];
    return Positioned(
      top: inset.top,
      left: inset.left + trayW,
      right: inset.right + graphW,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 4 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3342),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF55627A), width: 3),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 15, offset: Offset(0, 8))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 18 * s, color: const Color(0xFF94A3B8)),
                SizedBox(width: 8 * s),
                ValueListenableBuilder<double>(
                  valueListenable: _frame,
                  builder: (context, _, _) => Text(
                    _scene.timerText,
                    style: TextStyle(
                      fontFamily: family,
                      fontFamilyFallback: fallback,
                      color: const Color(0xFFD1D5DB),
                      fontSize: 22 * s,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontFeatures: const [ui.FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#graph-container`: draggable Temperature vs. Time card.
  Widget _graphOverlay(LabPalette p, double s, EdgeInsets inset) {
    final w = _graphWidth(s);
    Widget legend(Color c, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14 * s, height: 3, color: c),
        SizedBox(width: 4 * s),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: c, fontSize: 10 * s, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
    final card = Container(
      width: w,
      padding: EdgeInsets.all(7 * s),
      decoration: BoxDecoration(
        color: p.isDark ? const Color(0xF20F172A) : const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.isDark ? _Colors.slate700 : _Colors.slate200, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.drag_indicator, size: 12 * s, color: p.textMuted),
              SizedBox(width: 3 * s),
              Flexible(
                child: Text(
                  _t('graph_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.textStrong, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * s),
          AspectRatio(
            aspectRatio: 220 / 130,
            child: CustomPaint(
              painter: _GraphPainter(scene: _scene, repaint: _frame, isDark: p.isDark),
            ),
          ),
          SizedBox(height: 4 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(child: legend(const Color(0xFFE87834), _t('lbl_soil'))),
              Flexible(child: legend(const Color(0xFF52A6FF), _t('lbl_water'))),
            ],
          ),
        ],
      ),
    );
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, c) {
          final estH = w * 130 / 220 + 50 * s;
          final def = Offset(c.maxWidth - inset.right - w, inset.top);
          final pos = _graphPos ?? def;
          final double left = pos.dx.clamp(0.0, math.max(0.0, c.maxWidth - w));
          final double top = pos.dy.clamp(0.0, math.max(0.0, c.maxHeight - estH));
          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: _lowSlop(
                  GestureDetector(
                    onPanStart: (_) => _Audio.play(_Sound.pickup),
                    onPanUpdate: (d) => setState(() => _graphPos = Offset(left, top) + d.delta),
                    onPanEnd: (_) => _Audio.play(_Sound.drop),
                    child: card,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const List<String> _painterKeys = ['lbl_soil', 'lbl_water', 'lbl_land', 'lbl_sea'];

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
          icon: Icons.air,
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
            if (_scene.scenario == 0) _timerOverlay(s, inset),
            if (_scene.scenario == 0 && _scene.graphVisible) _graphOverlay(p, s, inset),
            _tray(p, s, inset),
            _dragLayer(s),
          ],
          stage: LabStage(
            designSize: _design,
            child: CustomPaint(
              key: _stageKey,
              size: _design,
              painter: _BreezePainter(
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
    'app_title': 'Land and Sea Breezes',
    'app_subtitle': 'Class 7 • Heat Transfer in Nature',
    'scen_1_opt': 'Scenario 1: The Great Heat Race',
    'scen_2_opt': 'Scenario 2: The Coastal Wind Machine',
    'btn_show_airflow': 'Show Air Flow',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Success!',
    'graph_title': 'Temperature vs. Time',
    'lbl_soil': 'Soil',
    'lbl_water': 'Water',
    'lbl_land': 'Land',
    'lbl_sea': 'Sea',
    'drop_sky_here': 'DROP IN SKY',
    'msg_sun_placed': 'The sun is shining! Heating started.',
    'msg_moon_placed': 'Night has fallen! Cooling started.',
    'msg_wrong_icon': 'That is not the correct celestial body for this step.',
    'conclusion_1':
        'You have discovered that land heats up much faster than water during the day, and also cools down much faster at night! This difference is the key to understanding sea and land breezes.',
    'conclusion_2':
        'During the day, cool air moves from the sea to the land (Sea Breeze).\n\nAt night, the pattern reverses, and cool air moves from the land to the sea (Land Breeze).\n\nThis is all caused by land and sea heating and cooling at different speeds!',
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario from the sidebar.',
    // Strings that were hard-coded in the HTML.
    'lbl_scen_1': 'Scenario 1:',
    'lbl_scen_2': 'Scenario 2:',
    'item_sun': 'Sun',
    'item_moon': 'Moon',
    'timer': 'Timer',
  },
  'hi': {
    'app_title': 'थल और समुद्र समीर',
    'app_subtitle': 'कक्षा 7 • प्रकृति में ऊष्मा स्थानांतरण',
    'scen_1_opt': 'परिदृश्य 1: महान ऊष्मा दौड़',
    'scen_2_opt': 'परिदृश्य 2: तटीय पवन मशीन',
    'btn_show_airflow': 'वायु प्रवाह दिखाएं',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'सफलता!',
    'graph_title': 'तापमान बनाम समय',
    'lbl_soil': 'मिट्टी',
    'lbl_water': 'पानी',
    'lbl_land': 'भूमि',
    'lbl_sea': 'समुद्र',
    'drop_sky_here': 'आकाश में छोड़ें',
    'msg_sun_placed': 'सूरज चमक रहा है! गर्म होना शुरू हुआ।',
    'msg_moon_placed': 'रात हो गई है! ठंडा होना शुरू हुआ।',
    'msg_wrong_icon': 'इस चरण के लिए यह सही खगोलीय पिंड नहीं है।',
    'conclusion_1':
        'आपने पाया है कि दिन के दौरान भूमि (मिट्टी) पानी की तुलना में बहुत तेजी से गर्म होती है, और रात में भी बहुत तेजी से ठंडी होती है! यह अंतर समुद्र और भूमि की हवाओं को समझने की कुंजी है।',
    'conclusion_2':
        'दिन के दौरान, ठंडी हवा समुद्र से भूमि (समुद्र समीर) की ओर बढ़ती है।\n\nरात में, पैटर्न उलट जाता है, और ठंडी हवा भूमि से समुद्र (भूमि समीर) की ओर बढ़ती है।\n\nयह सब भूमि और समुद्र के अलग-अलग गति से गर्म और ठंडा होने के कारण होता है!',
    'msg_scenario_complete': 'परिदृश्य पूर्ण! कृपया साइडबार से अगला परिदृश्य चुनें।',
    'lbl_scen_1': 'परिदृश्य 1:',
    'lbl_scen_2': 'परिदृश्य 2:',
    'item_sun': 'सूर्य',
    'item_moon': 'चंद्रमा',
    'timer': 'टाइमर',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually and interactively discover that land (soil) heats up and cools down much faster than water when exposed to the same amount of heat.',
      steps: [
        LabStep(
          concept: "Different materials absorb heat at different rates. Let's compare soil and water.",
          action: 'DRAG the sun icon and DROP it into the sky above the bowls to simulate day.',
          observation: 'The sun shines down on the bowls. A real-time graph starts plotting.',
        ),
        LabStep(
          concept: 'Observe the heating rates.',
          action: 'Watch the thermometers and the graph as the timer runs.',
          observation:
              'The red liquid in the soil thermometer rises significantly faster and higher than in the water. The soil line on the graph has a much steeper upward slope.',
        ),
        LabStep(
          concept: 'Materials also lose heat at different rates.',
          action: 'DRAG the moon icon and DROP it into the sky, replacing the sun to simulate night.',
          observation: 'The scene becomes dark. The cooling phase begins.',
        ),
        LabStep(
          concept: 'Observe the cooling rates.',
          action: 'Watch the thermometers and the graph as the bowls cool down.',
          observation:
              'The red liquid in the soil thermometer falls much faster than in the water. The soil line drops steeply.',
        ),
        LabStep(
          concept: 'Scientific Conclusion',
          action: 'Review the outcome of the experiment.',
          observation: 'Land heats up and cools down faster than water.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visualize how the differential heating of land and water creates sea breezes during the day and land breezes at night.',
      steps: [
        LabStep(
          concept: 'Daytime Heating: Land heats faster than the sea.',
          action: 'DRAG the sun icon and DROP it into the sky over the coastal scene.',
          observation: 'The land surface begins to glow warm, while the sea remains cool.',
        ),
        LabStep(
          concept: 'Convection creates a Sea Breeze.',
          action: "CLICK the 'Show Air Flow' button.",
          observation:
              'Warm air rises over the land. Cooler air from the sea flows in to replace it. The pinwheel spins, showing wind from the sea.',
        ),
        LabStep(
          concept: 'Nighttime Cooling: Land cools faster than the sea.',
          action: 'DRAG the moon icon and DROP it into the sky.',
          observation: 'The land loses its heat quickly. The sea is now relatively warmer.',
        ),
        LabStep(
          concept: 'Convection creates a Land Breeze.',
          action: 'Observe the air flow at night.',
          observation:
              'Warm air rises over the sea. Cooler air from the land flows out to replace it. The pinwheel spins, showing wind from the land.',
        ),
        LabStep(
          concept: 'Scientific Conclusion',
          action: 'Review the daily wind cycles.',
          observation: 'Temperature differences drive predictable coastal winds.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह देखने और अन्वेषण करने के लिए कि समान मात्रा में ऊष्मा के संपर्क में आने पर भूमि (मिट्टी) पानी की तुलना में बहुत तेज़ी से गर्म और ठंडी होती है।',
      steps: [
        LabStep(
          concept: 'विभिन्न सामग्रियां अलग-अलग दरों पर ऊष्मा को अवशोषित करती हैं। आइए मिट्टी और पानी की तुलना करें।',
          action: 'दिन का अनुकरण करने के लिए सूर्य आइकन खींचें और इसे कटोरे के ऊपर आकाश में छोड़ दें।',
          observation: 'सूरज कटोरे पर चमकता है। एक वास्तविक समय ग्राफ प्लॉट करना शुरू करता है।',
        ),
        LabStep(
          concept: 'हीटिंग दरों का निरीक्षण करें।',
          action: 'जैसे-जैसे टाइमर चलता है, थर्मामीटर और ग्राफ देखें।',
          observation:
              'मिट्टी के थर्मामीटर में लाल तरल पदार्थ पानी की तुलना में काफी तेज और ऊंचा उठता है। ग्राफ पर मिट्टी की रेखा में बहुत तेज ऊपर की ओर ढलान है।',
        ),
        LabStep(
          concept: 'सामग्री भी अलग-अलग दरों पर गर्मी खोती है।',
          action: 'रात का अनुकरण करने के लिए सूरज की जगह चंद्रमा आइकन खींचें और आकाश में छोड़ दें।',
          observation: 'दृश्य अंधेरा हो जाता है। शीतलन चरण शुरू होता है।',
        ),
        LabStep(
          concept: 'शीतलन दरों का निरीक्षण करें।',
          action: 'जैसे-जैसे कटोरे ठंडे होते हैं, थर्मामीटर और ग्राफ देखें।',
          observation: 'मिट्टी के थर्मामीटर में लाल तरल पानी की तुलना में बहुत तेज गिरता है। मिट्टी की रेखा तेजी से नीचे गिरती है।',
        ),
        LabStep(
          concept: 'वैज्ञानिक निष्कर्ष',
          action: 'प्रयोग के परिणाम की समीक्षा करें।',
          observation: 'भूमि पानी की तुलना में तेजी से गर्म और ठंडी होती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह कल्पना करने के लिए कि कैसे भूमि और पानी की अलग-अलग हीटिंग दिन के दौरान समुद्री हवाएं और रात में भूमि हवाएं बनाती है।',
      steps: [
        LabStep(
          concept: 'दिन के समय हीटिंग: भूमि समुद्र की तुलना में तेजी से गर्म होती है।',
          action: 'सूर्य के आइकन को खींचें और इसे तटीय दृश्य के ऊपर आकाश में छोड़ दें।',
          observation: 'भूमि की सतह गर्म चमकने लगती है, जबकि समुद्र ठंडा रहता है।',
        ),
        LabStep(
          concept: 'संवहन से समुद्र समीर उत्पन्न होता है।',
          action: "'वायु प्रवाह दिखाएं' बटन पर क्लिक करें।",
          observation:
              'भूमि पर गर्म हवा ऊपर उठती है। इसकी जगह लेने के लिए समुद्र से ठंडी हवा बहती है। पिनव्हील घूमता है, जो समुद्र से हवा दिखाता है।',
        ),
        LabStep(
          concept: 'रात के समय शीतलन: भूमि समुद्र की तुलना में तेजी से ठंडी होती है।',
          action: 'चंद्रमा आइकन खींचें और इसे आकाश में छोड़ दें।',
          observation: 'भूमि अपनी गर्मी जल्दी खो देती है। समुद्र अब अपेक्षाकृत अधिक गर्म है।',
        ),
        LabStep(
          concept: 'संवहन से स्थल समीर उत्पन्न होता है।',
          action: 'रात में वायु प्रवाह का निरीक्षण करें।',
          observation:
              'समुद्र के ऊपर गर्म हवा उठती है। भूमि से ठंडी हवा इसकी जगह लेने के लिए बहती है। पिनव्हील घूमता है, जो भूमि से हवा दिखाता है।',
        ),
        LabStep(
          concept: 'वैज्ञानिक निष्कर्ष',
          action: 'दैनिक हवा चक्र की समीक्षा करें।',
          observation: 'तापमान में अंतर अनुमानित तटीय हवाओं को चलाता है।',
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

/// Scenario 1: camera (0, 8, 28) -> (0, 0, 0). Scenario 2: (0, 12, 30).
/// [shift] slides the view right while the floating mission card covers
/// the top-left of the canvas.
_Cam _a3Cam(int scenario, [double shift = 0]) => scenario == 0
    ? _Cam(eye: const _V(0, 8, 28), target: const _V(0, 0, 0), focal: 760, center: Offset(500 + shift, 345))
    : _Cam(eye: const _V(0, 12, 30), target: const _V(0, 0, 0), focal: 700, center: Offset(500 + shift, 350));

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

class _BreezePainter extends CustomPainter {
  _BreezePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.text,
    this.labelScale = 1,
  }) : super(repaint: repaint);

  final _BreezeScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> text;
  final double labelScale;

  static const Color _tableTop = Color(0xFFC48753);
  static const Color _legColor = Color(0xFF8A542B);
  static const Color _soil = Color(0xFF4A2A18);
  static const Color _water = Color(0xFF22A2EB);
  static const Color _fluid = Color(0xFFE62020);
  static const Color _dirt = Color(0xFF5C4033);
  static const Color _grass = Color(0xFF6B8E23);
  static const Color _sea = Color(0xFF1CA3EC);

  late _Cam cam;
  double get t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    cam = _a3Cam(scene.scenario, scene.viewShift);
    _paintSky(canvas, size);
    _paintCelestial(canvas);
    if (scene.scenario == 0) {
      _paintLab(canvas, size);
    } else {
      _paintCoast(canvas, size);
    }
    if (showLabels) _paintLabels(canvas);
  }

  /// Object colour under the HTML lights (ambient, warm sun, bluish moon).
  Color _lit(Color c, [double facing = 1]) {
    final amb = scene.ambient.value, sun = scene.sun.value, moon = scene.moon.value;
    final b = 0.3 + 0.7 * amb + 0.22 * sun * facing + 0.18 * moon * facing;
    final warm = (0.05 * sun).clamp(0.0, 1.0);
    final cool = (0.3 * moon).clamp(0.0, 1.0);
    double ch(double v, double w, double cl) {
      var x = v * b;
      x = x * (1 - warm) + w * warm * b;
      x = x * (1 - cool) + cl * cool * b;
      return x.clamp(0.0, 1.0);
    }

    return Color.from(
      alpha: c.a,
      red: ch(c.r, 1.0, 0.553),
      green: ch(c.g, 0.96, 0.631),
      blue: ch(c.b, 0.714, 0.725),
    );
  }

  // ----------------------------------------------------------------- sky

  void _paintSky(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    final n = scene.night.value;
    final top = Color.lerp(const Color(0xFF74C2FF), const Color(0xFF0D1B2A), n)!;
    final bottom = Color.lerp(const Color(0xFFD4F0FF), const Color(0xFF1B263B), n)!;
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );
    if (n > 0.02) {
      final rnd = math.Random(7);
      for (var i = 0; i < 70; i++) {
        final p = Offset(rnd.nextDouble() * size.width * 1.4 - size.width * 0.2, rnd.nextDouble() * 300 - 40);
        final tw = 0.55 + 0.45 * math.sin(t * (1.5 + rnd.nextDouble() * 2) + i);
        canvas.drawCircle(p, 0.8 + rnd.nextDouble() * 1.4, Paint()..color = Colors.white.withValues(alpha: 0.75 * n * tw));
      }
    }
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = (bleed.left / 40).floor() * 40.0; x < bleed.right; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    for (var y = (bleed.top / 40).floor() * 40.0; y < bleed.bottom; y += 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
  }

  /// The dropped sun / moon in the sky (where the student released it).
  void _paintCelestial(Canvas canvas) {
    final s = scene;
    final sa = s.sunAlpha.value;
    if (sa > 0 && s.sunPos != null) {
      final c = s.sunPos!;
      final target = s.scenario == 0 ? cam.pt(0, -1, 0) : cam.pt(-4, 0.5, 0);
      final dir = target - c;
      final n = Offset(-dir.dy, dir.dx) / math.max(dir.distance, 1);
      final beam = _poly([c + n * 30, target + n * 260, target - n * 260, c - n * 30]);
      canvas.drawPath(
        beam,
        Paint()
          ..shader = ui.Gradient.linear(c, target, [
            const Color(0xFFFFF5B6).withValues(alpha: 0.22 * sa),
            const Color(0xFFFFF5B6).withValues(alpha: 0),
          ]),
      );
      labGlow(canvas, c, 110 * (1 + 0.04 * math.sin(t * 2)), const Color(0xFFFDE047), intensity: 0.6 * sa);
      final ray = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: sa)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6 + t * 0.25;
        final d = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c + d * 42, c + d * (56 + 5 * math.sin(t * 3 + i)), ray);
      }
      labSphere(canvas, c, 34, const Color(0xFFFACC15), highlight: 0.55, shade: 0.12, opacity: sa);
    }
    final ma = s.moonAlpha.value;
    if (ma > 0 && s.moonPos != null) {
      final c = s.moonPos!;
      labGlow(canvas, c, 90, const Color(0xFFBFDBFE), intensity: 0.35 * ma);
      labSphere(canvas, c, 30, const Color(0xFFE2E8F0), highlight: 0.3, shade: 0.25, opacity: ma);
      final crater = Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.9 * ma);
      canvas.drawCircle(c + const Offset(-6, -9), 5.5, crater);
      canvas.drawCircle(c + const Offset(9, 8), 7.5, crater);
      canvas.drawCircle(c + const Offset(-9, 11), 3.8, crater);
    }
  }

  // -------------------------------------------------------------- labels

  void _label(Canvas canvas, String key, _V at) {
    labText(
      canvas,
      text[key]!,
      cam.p(at),
      size: 15 * labelScale,
      weight: FontWeight.w700,
      color: isDark ? Colors.white : _Colors.slate800,
      background: isDark ? const Color(0xCC1E293B) : const Color(0xE6FFFFFF),
      border: isDark ? _Colors.slate600 : _Colors.slate300,
      borderWidth: 1,
      radius: 5,
      padding: EdgeInsets.symmetric(horizontal: 9 * labelScale, vertical: 4 * labelScale),
    );
  }

  void _paintLabels(Canvas canvas) {
    if (scene.scenario == 0) {
      _label(canvas, 'lbl_soil', const _V(-5, 2.5, 0));
      _label(canvas, 'lbl_water', const _V(5, 2.5, 0));
    } else {
      // Nudged right of the pinwheel pole so it never hides it.
      _label(canvas, 'lbl_land', const _V(-5, 2.2, 1.5));
      _label(canvas, 'lbl_sea', const _V(7, 0, 0));
    }
  }

  @override
  bool shouldRepaint(covariant _BreezePainter old) =>
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.scene != scene ||
      old.labelScale != labelScale;

  // ----------------------------------------------------- scenario 1 lab

  void _paintLab(Canvas canvas, Size size) {
    // Legs (1.5 x 10 x 1.5), lengthened so they never end inside the
    // letterbox area. Back pair first.
    for (final z in [-5.0, 5.0]) {
      for (final x in [-10.0, 10.0]) {
        _box(canvas, cam, _V(x, -30, z), const _V(1.5, 56, 1.5), _lit(_legColor));
      }
    }
    // Table top (22 x 1.5 x 12, top at y = -1.5) with a subtle wood grain.
    final top = _poly([cam.pt(-11, -1.5, -6), cam.pt(11, -1.5, -6), cam.pt(11, -1.5, 6), cam.pt(-11, -1.5, 6)]);
    final tb = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lit(labShade(_tableTop, -0.12)), _lit(labShade(_tableTop, 0.06))],
        ).createShader(tb),
    );
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _lit(labShade(_tableTop, -0.35)).withValues(alpha: 0.25);
    for (var i = 0; i < 9; i++) {
      final z = -5.4 + i * 1.35;
      final path = Path();
      for (var j = 0; j <= 22; j++) {
        final x = -11.0 + j;
        final p = cam.pt(x, -1.5, z + 0.12 * math.sin(j * 0.9 + i * 1.7));
        j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, grain);
    }
    final front = _poly([cam.pt(-11, -1.5, 6), cam.pt(11, -1.5, 6), cam.pt(11, -3, 6), cam.pt(-11, -3, 6)]);
    canvas.drawPath(front, Paint()..color = _lit(labShade(_tableTop, -0.28)));
    canvas.drawLine(cam.pt(-11, -1.5, 6), cam.pt(11, -1.5, 6), Paint()
      ..strokeWidth = 1.5
      ..color = _lit(labShade(_tableTop, 0.25)));

    _bowl(canvas, -5, soil: true);
    _bowl(canvas, 5, soil: false);
  }

  /// Glass bowl (hemisphere r 3.5, rim at y = -0.5) set into the table,
  /// filled with a soil mound or water, with its angled thermometer.
  void _bowl(Canvas canvas, double bx, {required bool soil}) {
    const ex = _V(1, 0, 0), ez = _V(0, 0, 1);
    final s = scene;
    // Where the hemisphere meets the table top (y = -1.5): r = sqrt(3.5^2 - 1).
    final cut = _ring(cam, _V(bx, -1.5, 0), 3.354, ex, ez, seg: 40);
    final rim = _ring(cam, _V(bx, -0.5, 0), 3.5, ex, ez, seg: 40);
    canvas.drawPath(_poly(cut), Paint()..color = Colors.black.withValues(alpha: 0.28));
    final band = _poly(_hull([...cut, ...rim]));
    canvas.drawPath(band, Paint()..color = Colors.white.withValues(alpha: 0.12));

    final tx = soil ? -4.5 : 4.5;
    final rz = soil ? 0.4 : -0.4;
    final temp = soil ? s.soilTemp : s.waterTemp;
    if (soil) {
      _soilMound(canvas, bx);
      _thermometer(canvas, tx, rz, temp, from: _soilExit(tx, rz, bx), to: 7);
      _shimmer(canvas, bx, 1.1, (s.soilTemp - 20) / 60);
    } else {
      final exit = 1 / math.cos(rz);
      _thermometer(canvas, tx, rz, temp, from: 0, to: exit, bulb: true);
      final wb = _ring(cam, _V(bx, -1.5, 0), 3.3, ex, ez, seg: 40);
      final wt = _ring(cam, _V(bx, -0.55, 0), 3.3, ex, ez, seg: 40);
      final body = _poly(_hull([...wb, ...wt]));
      canvas.drawPath(body, Paint()..color = _lit(_water).withValues(alpha: 0.72));
      final surf = _poly(wt);
      final sb = surf.getBounds();
      canvas.drawPath(
        surf,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_lit(labShade(_water, 0.35)).withValues(alpha: 0.85), _lit(_water).withValues(alpha: 0.8)],
          ).createShader(sb),
      );
      final ripple = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.35);
      for (var i = 0; i < 3; i++) {
        final r = 0.8 + ((t * 0.35 + i / 3) % 1) * 2.3;
        canvas.drawPath(_disc(cam, _V(bx + 0.4, -0.55, 0.3), r), ripple..color = Colors.white.withValues(alpha: 0.3 * (1 - (r - 0.8) / 2.3)));
      }
      _thermometer(canvas, tx, rz, temp, from: exit, to: 7);
      _shimmer(canvas, bx, -0.4, (s.waterTemp - 20) / 60);
    }
    // Rim (torus r 3.5, tube 0.2) and glass front.
    final k = cam.k(_V(bx, -0.5, 3.5));
    canvas.drawPath(_poly(rim), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 * k
      ..color = Colors.white.withValues(alpha: 0.45));
    canvas.drawPath(_poly(rim).shift(Offset(0, -0.1 * k)), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.75));
    canvas.drawPath(band, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.3));
  }

  void _soilMound(Canvas canvas, double bx) {
    const ex = _V(1, 0, 0), ez = _V(0, 0, 1);
    final pts = <Offset>[];
    for (var i = 0; i <= 10; i++) {
      final y = -1.5 + 2.48 * i / 10;
      final q = (y + 1) / 1.98;
      final r = 3.3 * math.sqrt(math.max(0, 1 - q * q));
      if (r > 0.01) pts.addAll(_ring(cam, _V(bx, y, 0), r, ex, ez, seg: 32));
    }
    pts.add(cam.pt(bx, 0.98, 0));
    final dome = _poly(_hull(pts));
    final b = dome.getBounds();
    canvas.drawPath(
      dome,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.35, -0.55),
          radius: 0.95,
          colors: [_lit(labShade(_soil, 0.32)), _lit(_soil), _lit(labShade(_soil, -0.45))],
          stops: const [0, 0.55, 1],
        ).createShader(b),
    );
    // Soil grains.
    final rnd = math.Random(11);
    for (var i = 0; i < 120; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final rr = 3.1 * math.sqrt(rnd.nextDouble());
      final x = bx + rr * math.cos(a), z = rr * math.sin(a);
      final q = rr / 3.3;
      final y = -1 + 1.98 * math.sqrt(math.max(0, 1 - q * q));
      if (y < -1.45 || z < -0.4) continue;
      canvas.drawCircle(
        cam.pt(x, y, z),
        0.9 + rnd.nextDouble() * 1.3,
        Paint()..color = _lit(labShade(_soil, rnd.nextBool() ? 0.28 : -0.35)).withValues(alpha: 0.8),
      );
    }
  }

  /// Distance along the thermometer at which it leaves the soil mound.
  double _soilExit(double tx, double rz, double bx) {
    for (var d = 0.0; d < 7; d += 0.05) {
      final x = tx - d * math.sin(rz), y = -1.5 + d * math.cos(rz);
      final q = (x - bx) / 3.3;
      final surface = q.abs() >= 1 ? -1.5 : -1 + 1.98 * math.sqrt(1 - q * q);
      if (y > surface) return d;
    }
    return 7;
  }

  /// Angled thermometer (white body, glass bulb, red fluid column of
  /// length `0.5 + temp / 15`, like the HTML `fluid.scale.y`). Only the
  /// part between [from] and [to] (distance along the body) is drawn.
  void _thermometer(Canvas canvas, double tx, double rz, double temp,
      {required double from, required double to, bool bulb = false}) {
    final dir = _V(-math.sin(rz), math.cos(rz), 0);
    final p0 = _V(tx, -1.5, 0);
    _V at(double d) => p0 + dir * d;
    if (bulb) {
      final c = cam.p(p0), k = cam.k(p0);
      labSphere(canvas, c, 0.6 * k, _lit(const Color(0xFFF1F5F9)), highlight: 0.6, shade: 0.3);
      canvas.drawCircle(c, 0.4 * k, Paint()..color = _fluid);
    }
    if (to <= from) return;
    _tube(canvas, cam, at(from), at(to), 0.3, 0.3, _lit(const Color(0xFFF1F5F9)),
        caps: to >= 7, capColor: _lit(Colors.white));
    final sa = cam.p(at(0)), sb = cam.p(at(1));
    final u = (sb - sa) / math.max((sb - sa).distance, 1e-3);
    final n = Offset(-u.dy, u.dx);
    final tick = Paint()
      ..color = const Color(0xFF475569).withValues(alpha: 0.75)
      ..strokeWidth = 1.1;
    for (var d = 1.0; d <= 6.6; d += 0.4) {
      if (d < from + 0.1 || d > to - 0.1) continue;
      final a = cam.p(at(d) + const _V(0, 0, 0.3));
      final w = (d * 10).round() % 2 == 0 ? 0.24 : 0.14;
      canvas.drawLine(a + n * (0.06 * cam.k(at(d))), a + n * (w * cam.k(at(d))), tick);
    }
    final c0 = math.max(0.5, from);
    final c1 = math.min(0.5 + (0.5 + temp / 15), to);
    if (c1 > c0) {
      final k = cam.k(at(c1));
      canvas.drawLine(
        cam.p(at(c0) + const _V(0, 0, 0.2)),
        cam.p(at(c1) + const _V(0, 0, 0.2)),
        Paint()
          ..color = _fluid
          ..strokeWidth = math.max(2.5, 0.3 * k * 0.9)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// Heat shimmer above a warm surface (stronger as it heats up).
  void _shimmer(Canvas canvas, double bx, double y0, double heat) {
    if (heat <= 0.04) return;
    for (var i = 0; i < 4; i++) {
      final path = Path();
      final x0 = bx - 1.9 + i * 1.25;
      for (var j = 0; j <= 14; j++) {
        final y = y0 + (1.2 + 1.4 * heat) * j / 14;
        final p = cam.pt(x0 + 0.12 * math.sin(y * 5 - t * 5 + i), y, 0.6);
        j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = Colors.white.withValues(alpha: (0.22 * heat).clamp(0.0, 0.22))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }
  }

  // --------------------------------------------------- scenario 2 coast

  void _paintCoast(Canvas canvas, Size size) {
    // Arrows below sea level are seen through the translucent sea.
    _paintArrows(canvas, (a) => a.y < 0.5 && a.x > 0);

    // Land block: dirt (14 x 3 x 15) with a 0.5 grass layer, x -14..0.
    canvas.drawPath(
      _poly([cam.pt(-14, 0, 7.5), cam.pt(0, 0, 7.5), cam.pt(0, -3, 7.5), cam.pt(-14, -3, 7.5)]),
      Paint()..color = _lit(labShade(_dirt, -0.05)),
    );
    final strata = Paint()
      ..strokeWidth = 1.2
      ..color = _lit(labShade(_dirt, -0.3)).withValues(alpha: 0.6);
    for (final y in [-1.0, -2.0]) {
      canvas.drawLine(cam.pt(-14, y, 7.5), cam.pt(0, y, 7.5), strata);
    }
    canvas.drawPath(
      _poly([cam.pt(-14, 0.5, 7.5), cam.pt(0, 0.5, 7.5), cam.pt(0, 0, 7.5), cam.pt(-14, 0, 7.5)]),
      Paint()..color = _lit(labShade(_grass, -0.12)),
    );
    final grassTop = _poly([cam.pt(-14, 0.5, -7.5), cam.pt(0, 0.5, -7.5), cam.pt(0, 0.5, 7.5), cam.pt(-14, 0.5, 7.5)]);
    canvas.drawPath(
      grassTop,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lit(labShade(_grass, -0.1)), _lit(labShade(_grass, 0.12))],
        ).createShader(grassTop.getBounds()),
    );

    // Sea block (14 x 3.5 x 15, opacity 0.85), x 0..14.
    canvas.drawPath(
      _poly([cam.pt(0, 0.5, 7.5), cam.pt(14, 0.5, 7.5), cam.pt(14, -3, 7.5), cam.pt(0, -3, 7.5)]),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lit(_sea).withValues(alpha: 0.85), _lit(labShade(_sea, -0.35)).withValues(alpha: 0.9)],
        ).createShader(Rect.fromPoints(cam.pt(0, 0.5, 7.5), cam.pt(14, -3, 7.5))),
    );
    final seaTop = _poly([cam.pt(0, 0.5, -7.5), cam.pt(14, 0.5, -7.5), cam.pt(14, 0.5, 7.5), cam.pt(0, 0.5, 7.5)]);
    canvas.drawPath(seaTop, Paint()..color = _lit(labShade(_sea, 0.12)).withValues(alpha: 0.85));
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: 0.28);
    for (var i = 0; i < 7; i++) {
      final z = -6.5 + i * 2.1;
      final path = Path();
      for (var j = 0; j <= 28; j++) {
        final x = j * 0.5;
        final p = cam.pt(x, 0.5, z + 0.18 * math.sin(x * 1.3 + t * 1.6 + i));
        j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, wave);
    }
    canvas.drawLine(cam.pt(0, 0.5, 7.5), cam.pt(14, 0.5, 7.5), Paint()
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.4));

    // Heat glows (additive radial planes 10 x 10 at y = 0.6).
    _heatGlow(canvas, -7, scene.landGlow.value);
    _heatGlow(canvas, 7, scene.seaGlow.value);

    _paintArrows(canvas, (a) => a.y >= 0.5 && a.z < 0);
    _paintHouse(canvas);
    _paintArrows(canvas, (a) => a.y >= 0.5 && a.z >= 0);
  }

  void _heatGlow(Canvas canvas, double x, double opacity) {
    if (opacity <= 0.005) return;
    final disc = _disc(cam, _V(x, 0.6, 0), 5);
    canvas.drawPath(
      disc,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(colors: [
          const Color(0xFFFF3C00).withValues(alpha: 0.8 * opacity),
          const Color(0xFFFF3C00).withValues(alpha: 0),
        ]).createShader(disc.getBounds()),
    );
  }

  /// Convection arrows (3 elliptical rings of 35 cones). Day: clockwise
  /// (sea breeze at the surface); night: counter-clockwise (land breeze).
  void _paintArrows(Canvas canvas, bool Function(_Arrow a) test) {
    final s = scene;
    if (!s.particlesVisible) return;
    final isDay = s.isDay ?? true;
    final dir = isDay ? -1.0 : 1.0;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.black.withValues(alpha: 0.25);
    for (final a in s.arrows) {
      if (!test(a)) continue;
      if (a.y < 0.5 && a.x <= 0) continue; // hidden inside the land block
      final p = _V(a.x, a.y, a.z);
      final tan = _V(-math.sin(a.angle) * a.rx * dir, math.cos(a.angle) * a.ry * dir, 0).unit;
      final tip = cam.p(p + tan * 0.4), base = cam.p(p - tan * 0.4);
      final d = tip - base;
      if (d.distance < 0.01) continue;
      final n = Offset(-d.dy, d.dx) / d.distance;
      final hw = 0.3 * cam.k(p);
      final nx = (a.x + a.rx) / (a.rx * 2);
      final r = isDay ? math.max(0.0, 1 - nx * 1.5) : math.max(0.0, nx * 1.5 - 0.5);
      final b = isDay ? math.max(0.0, nx * 1.5) : math.max(0.0, 1.5 - nx * 1.5);
      final col = Color.from(alpha: 1, red: (r * 1.5).clamp(0.0, 1.0), green: 0.1, blue: (b * 1.5).clamp(0.0, 1.0));
      final tri = _poly([tip, base + n * hw, base - n * hw]);
      canvas.drawPath(tri, Paint()..color = col.withValues(alpha: a.y < 0.5 ? 0.55 : 1));
      canvas.drawPath(tri, outline);
    }
  }

  void _paintHouse(Canvas canvas) {
    const hx = -10.0, hy = 0.5;
    final shadow = _disc(cam, const _V(hx - 0.6, hy + 0.01, -0.6), 2.4);
    canvas.drawPath(shadow, Paint()
      ..color = Colors.black.withValues(alpha: 0.18 + 0.12 * scene.sun.value / 1.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    _box(canvas, cam, const _V(hx, hy + 1.25, 0), const _V(3, 2.5, 3), _lit(const Color(0xFF8B5A2B)));
    // Door and a window that glows warm at night.
    canvas.drawPath(
      _poly([cam.pt(hx - 0.85, hy, 1.51), cam.pt(hx - 0.1, hy, 1.51), cam.pt(hx - 0.1, hy + 1.5, 1.51), cam.pt(hx - 0.85, hy + 1.5, 1.51)]),
      Paint()..color = _lit(const Color(0xFF4A2C12)),
    );
    final night = scene.night.value;
    final win = _poly([cam.pt(hx + 0.35, hy + 1.1, 1.51), cam.pt(hx + 1.15, hy + 1.1, 1.51), cam.pt(hx + 1.15, hy + 1.8, 1.51), cam.pt(hx + 0.35, hy + 1.8, 1.51)]);
    canvas.drawPath(win, Paint()..color = Color.lerp(_lit(const Color(0xFFBAE6FD)), const Color(0xFFFDE68A), night)!);
    if (night > 0.3) labGlow(canvas, win.getBounds().center, 26, const Color(0xFFFDE68A), intensity: 0.5 * night);

    // Pyramid roof (4-sided cone r 2.5, h 1.5, rotated 45 degrees).
    const a = 1.768;
    const apex = _V(hx, hy + 4.0, 0);
    const corners = [_V(hx - a, hy + 2.5, a), _V(hx + a, hy + 2.5, a), _V(hx + a, hy + 2.5, -a), _V(hx - a, hy + 2.5, -a)];
    const roof = Color(0xFF8B0000);
    for (var i = 0; i < 4; i++) {
      final c0 = corners[i], c1 = corners[(i + 1) % 4];
      var normal = (c0 - apex).cross(c1 - apex).unit;
      final mid = (apex + c0 + c1) * (1 / 3);
      if (normal.dot(mid - const _V(hx, hy + 2.5, 0)) < 0) normal = normal * -1;
      final facing = (cam.eye - mid).unit.dot(normal);
      if (facing <= 0) continue;
      canvas.drawPath(_poly([cam.p(apex), cam.p(c0), cam.p(c1)]),
          Paint()..color = _lit(labShade(roof, -0.2 + 0.35 * facing + 0.1 * normal.x)));
    }

    // Pole and pinwheel.
    _tube(canvas, cam, const _V(hx + 2.5, hy, 0), const _V(hx + 2.5, hy + 4, 0), 0.1, 0.1, _lit(const Color(0xFF94A3B8)));
    _pinwheel(canvas, const _V(hx + 2.5, hy + 4, 0.3), scene.pinwheel);
  }

  /// Four blades built in the XY plane and spun about the X axis
  /// (HTML `pinwheel.rotation.x`).
  void _pinwheel(Canvas canvas, _V c, double phi) {
    final cp = math.cos(phi), sp = math.sin(phi);
    _V rotX(_V v) => _V(v.x, v.y * cp - v.z * sp, v.y * sp + v.z * cp);
    final blades = <(_V, _V, _V, _V, Color)>[];
    for (final (psi, col) in const [
      (0.0, Color(0xFFEF4444)),
      (math.pi / 2, Color(0xFF3B82F6)),
      (math.pi, Color(0xFFEF4444)),
      (-math.pi / 2, Color(0xFF3B82F6)),
    ]) {
      final ex = rotX(_V(math.cos(psi), math.sin(psi), 0));
      final ey = rotX(_V(-math.sin(psi), math.cos(psi), 0));
      final ez = rotX(const _V(0, 0, 1));
      blades.add((c + ey * 0.9, ex, ey, ez, col));
    }
    blades.sort((a, b) => a.$1.z.compareTo(b.$1.z));
    for (final (center, ex, ey, ez, col) in blades) {
      _obox(canvas, cam, center, ex, ey, ez, 0.05, 0.9, 0.2, col);
    }
    labSphere(canvas, cam.p(c), 0.2 * cam.k(c), const Color(0xFFCBD5E1));
  }
}

// ======================================================== UI PAINTERS

/// The sun / moon inventory icons (the HTML inline SVGs on their tiles).
class _BodyIconPainter extends CustomPainter {
  _BodyIconPainter({required this.body, required this.hint, required this.scene, required Listenable repaint})
      : super(repaint: repaint);

  final _Body body;
  final bool hint;
  final _BreezeScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.2));
    final sun = body == _Body.sun;
    if (hint) {
      final pulse = 0.5 + 0.5 * math.sin(scene.time * math.pi);
      canvas.drawRRect(
        rr.inflate(2 + 2 * pulse),
        Paint()
          ..color = _Colors.zslYellow.withValues(alpha: 0.35 + 0.4 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    canvas.drawRRect(rr, Paint()..color = sun ? const Color(0xFF5EB4F6) : const Color(0xFF1E293B));
    canvas.drawRRect(
      rr.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: sun ? 0.5 : 0.2),
    );
    // 24 x 24 SVG viewBox drawn at 10/14 of the tile.
    final k = size.width * (10 / 14) / 24;
    canvas.save();
    canvas.translate(size.width / 2 - 12 * k, size.height / 2 - 12 * k);
    canvas.scale(k);
    if (sun) {
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFF59E0B);
      canvas.drawCircle(const Offset(12, 12), 5, Paint()..color = const Color(0xFFFACC15));
      canvas.drawCircle(const Offset(12, 12), 5, stroke);
      const rays = [
        (Offset(12, 2), Offset(12, 4)),
        (Offset(12, 20), Offset(12, 22)),
        (Offset(4.93, 4.93), Offset(6.34, 6.34)),
        (Offset(17.66, 17.66), Offset(19.07, 19.07)),
        (Offset(2, 12), Offset(4, 12)),
        (Offset(20, 12), Offset(22, 12)),
        (Offset(4.93, 19.07), Offset(6.34, 17.66)),
        (Offset(17.66, 6.34), Offset(19.07, 4.93)),
      ];
      for (final (a, b) in rays) {
        canvas.drawLine(a, b, stroke);
      }
    } else {
      canvas.drawCircle(const Offset(12, 12), 8, Paint()..color = const Color(0xFFE2E8F0));
      final crater = Paint()..color = const Color(0xFF94A3B8);
      canvas.drawCircle(const Offset(10, 9), 1.5, crater);
      canvas.drawCircle(const Offset(14, 14), 2, crater);
      canvas.drawCircle(const Offset(9, 15), 1, crater);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BodyIconPainter old) => old.body != body || old.hint != hint;
}

/// Dashed rounded border of the "DROP IN SKY" zone.
class _DashedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16));
    canvas.drawRRect(rr, Paint()..color = Colors.white.withValues(alpha: 0.12));
    labDashedPath(
      canvas,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.6),
      dash: 9,
      gap: 6,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBoxPainter old) => false;
}

/// HTML `drawGraph()` on its 220 x 130 canvas (scaled to fit).
class _GraphPainter extends CustomPainter {
  _GraphPainter({required this.scene, required Listenable repaint, required this.isDark}) : super(repaint: repaint);

  final _BreezeScene scene;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 220.0, h = 130.0, padX = 20.0, padY = 20.0;
    canvas.save();
    canvas.scale(size.width / w, size.height / h);
    final grid = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: isDark ? 0.35 : 1)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = padY + (h - padY * 2) * (i / 4);
      canvas.drawLine(const Offset(padX, 0) + Offset(0, y), Offset(w - padX, y), grid);
    }
    final axis = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(padX, padY)
        ..lineTo(padX, h - padY)
        ..lineTo(w - padX, h - padY),
      axis,
    );
    void plot(List<Offset> data, Color color) {
      if (data.length < 2) return;
      final path = Path();
      for (var i = 0; i < data.length; i++) {
        final x = padX + (data[i].dx / 200) * (w - padX * 2);
        final y = (h - padY) - ((data[i].dy - 10) / 80) * (h - padY * 2);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    plot(scene.soilData, const Color(0xFFE87834));
    plot(scene.waterData, const Color(0xFF52A6FF));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) => old.isDark != isDark || old.scene != scene;
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
