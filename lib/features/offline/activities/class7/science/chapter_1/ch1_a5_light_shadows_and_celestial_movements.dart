// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 1 • Activity 5
/// Light, Shadows and Celestial Movements.
///
/// Native Flutter port of `Cl7S-Ch1-A5-Light__Shadows__and_Celestial_Movements.html`.
/// Scenario 1 (The Sun's Clock): place a gnomon on a sundial, move the Sun
/// from sunrise to sunset and mark three shadows. Scenario 2 (Shadows of
/// the Cosmos): spin the Earth (day / night), play the Moon's orbit and
/// pause it at a solar and then a lunar eclipse.
class Ch1A5LightShadowsAndCelestialMovementsPage extends StatefulWidget {
  const Ch1A5LightShadowsAndCelestialMovementsPage({super.key});

  @override
  State<Ch1A5LightShadowsAndCelestialMovementsPage> createState() =>
      _Ch1A5LightShadowsAndCelestialMovementsPageState();
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
  static const Color red600 = Color(0xFFDC2626);
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

const List<String> _kLabelKeys = [
  'lbl_sun', 'lbl_gnomon', 'lbl_earth', 'lbl_moon', 'lbl_solar', //
  'lbl_lunar', 'lbl_sunlight', 'lbl_day', 'lbl_night', 'lbl_axis',
];

class _Ch1A5LightShadowsAndCelestialMovementsPageState
    extends State<Ch1A5LightShadowsAndCelestialMovementsPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A5Scene _scene = _A5Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _canvasKey = GlobalKey();

  late final Ticker _ticker;
  double _last = 0;

  int _step = 1; // 1-based, like `state.step`
  int? _pointer;
  double _lastX = 0;
  Offset? _gnomonDrag; // canvas-local position of the drag clone

  // Scenario 2 camera move (eclipse close-ups / default view).
  _V3 _camFromPos = const _V3(0, 20, 45), _camFromTarget = const _V3(0, 0, 0);
  _V3 _camToPos = const _V3(0, 20, 45), _camToTarget = const _V3(0, 0, 0);
  double _camT0 = -1;

  int get _scenario => _scene.scenario;
  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];
  bool get _done => _step > _data.steps.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker(_onTick)..start();
    _loadScenario(0);
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

  // ------------------------------------------------------------ ticker

  /// HTML `animate()`: the Moon orbits (+0.01 rad / frame) and the Earth
  /// spins (+0.005 rad / frame) while orbiting.
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _last).clamp(0.0, 0.1);
    _last = now;
    final sc = _scene;
    sc.time = now;
    if (_scenario == 1 && sc.orbiting) {
      sc.moonAngle += 0.01 * dt * 60;
      sc.earthRot += 0.005 * dt * 60;
    }
    if (_camT0 >= 0) {
      final t = ((now - _camT0) / 0.7).clamp(0.0, 1.0);
      final v = Curves.easeInOutCubic.transform(t);
      sc.camPos = _V3.lerp(_camFromPos, _camToPos, v);
      sc.camTarget = _V3.lerp(_camFromTarget, _camToTarget, v);
      if (t >= 1) _camT0 = -1;
    }
    _frame.value = now;
  }

  void _moveCamera(_V3 pos, _V3 target) {
    _camFromPos = _scene.camPos;
    _camFromTarget = _scene.camTarget;
    _camToPos = pos;
    _camToTarget = target;
    _camT0 = _scene.time;
  }

  // ------------------------------------------------------------ flow

  /// Fresh state for a scenario (HTML `changeScenario` / `resetLab`).
  void _loadScenario(int index) {
    _lab.cancelPending();
    final sc = _scene;
    sc.scenario = index;
    sc.stickPlaced = false;
    sc.timeVal = 0;
    sc.marks.clear();
    sc.markSunrise = sc.markNoon = sc.markSunset = false;
    sc.draggingSun = false;
    sc.earthRot = 0;
    sc.moonAngle = math.pi / 2;
    sc.orbiting = false;
    sc.earthSpun = false;
    sc.playedAfterSolar = false;
    sc.draggingEarth = false;
    sc.camPos = const _V3(0, 20, 45);
    sc.camTarget = const _V3(0, 0, 0);
    _camT0 = -1;
    _step = 1;
    _pointer = null;
    _gnomonDrag = null;
    _lab.hidePopup(sound: false);
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() => setState(() => _loadScenario(0));

  /// HTML `checkValidation()`: success sound + feedback, next step, and the
  /// observation popup 4.5 s after the last step.
  void _validate() {
    if (_done) return;
    _Audio.play(_Sound.success);
    final msg = _data.steps[_step - 1].observation;
    final ex = _t('excellent');
    _lab.showToast(msg.startsWith(ex) ? msg : '$ex $msg', sound: false);
    setState(() => _step++);
    if (_done) {
      final scenario = _scenario;
      _lab.showScenarioConclusion(
        scenarioIndex: scenario,
        totalScenarios: 2,
        delay: const Duration(milliseconds: 4500),
        title: () => _t('obs_title'),
        heading: () => _t('scenario_outcome'),
        body: () => _t('conclusion_${scenario + 1}'),
      );
    }
  }

  // ------------------------------------------------- scenario 1 actions

  /// Drop of the gnomon anywhere on the canvas (HTML `startStickDrag`).
  void _placeGnomon() {
    if (_scenario != 0) return;
    setState(() => _scene.stickPlaced = true);
    _Audio.play(_Sound.drop);
    if (_step == 1) _validate();
  }

  /// HTML `updateTimeSlider(val)`.
  void _setTime(int v) {
    if (_scenario != 0 || !_scene.stickPlaced) {
      _lab.showToast(_t('place_gnomon_first'), isError: true);
      return;
    }
    setState(() => _scene.timeVal = v);
    if (_step == 2 && v >= 45 && v <= 55) _validate();
    if (_step == 3 && v >= 90) _validate();
  }

  /// HTML `markShadow()`: a black plane along the current shadow.
  void _markShadow() {
    final sc = _scene;
    if (_scenario != 0 || !sc.stickPlaced) return;
    final p = sc.sunPos;
    final sx = -(5.98 / p.y) * p.x;
    final sz = (5.98 / p.y) * 15;
    final len = math.sqrt(sx * sx + sz * sz);
    if (len > 150 || len < 0.1 || len.isNaN) {
      _lab.showToast(_t('shadow_too_long'), isError: true);
      return;
    }
    setState(() {
      sc.marks.add(_Mark(sx / len, sz / len, len));
      if (sc.timeVal < 30) {
        sc.markSunrise = true;
      } else if (sc.timeVal > 40 && sc.timeVal < 60) {
        sc.markNoon = true;
      } else if (sc.timeVal > 70) {
        sc.markSunset = true;
      }
    });
    if (_step == 4 && sc.marks.length >= 3) {
      _validate();
    } else {
      _lab.showToast('${_t('shadow_marked')} (${sc.marks.length}/3)', sound: false);
    }
  }

  /// HTML `resetMarks()`.
  void _resetMarks() {
    setState(() {
      _scene.marks.clear();
      _scene.markSunrise = _scene.markNoon = _scene.markSunset = false;
    });
  }

  // ------------------------------------------------- scenario 2 actions

  /// HTML `toggleOrbit()`: play / pause; pausing checks for an eclipse.
  void _toggleOrbit() {
    final sc = _scene;
    if (_scenario != 1 || _step == 1) {
      _lab.showToast(_t('complete_step1'), isError: true);
      return;
    }
    setState(() => sc.orbiting = !sc.orbiting);
    if (sc.orbiting) {
      // Restore the default view if the camera wandered into a close-up.
      if (sc.camPos.length < 25) _moveCamera(const _V3(0, 20, 45), const _V3(0, 0, 0));
      if (_step == 2) _validate();
      if (_step == 4) sc.playedAfterSolar = true;
      return;
    }
    final a = sc.normAngle;
    final base = sc.moonAngle - a;
    if (sc.isSolar) {
      sc.moonAngle = base + math.pi;
      _moveCamera(const _V3(-10, 3, 12), const _V3(0, 0, 0));
      if (_step == 3) {
        _validate();
      } else {
        _lab.showToast(_t('solar_captured'));
      }
    } else if (sc.isLunar) {
      sc.moonAngle = base + (a > math.pi ? 2 * math.pi : 0);
      _moveCamera(const _V3(8, 4, 15), const _V3(16, 0, 0));
      if (_step == 4 && sc.playedAfterSolar) {
        _validate();
      } else {
        _lab.showToast(_t('lunar_captured'));
      }
    } else {
      _lab.showToast(_t('not_aligned'), isError: true);
    }
  }

  // ------------------------------------------------- pointer (raycaster)

  void _onDown(PointerDownEvent e) {
    if (!_lab.isLabActive || _pointer != null) return;
    final pos = e.localPosition;
    final sc = _scene;
    if (_scenario == 0) {
      if (sc.stickPlaced && sc.hitSun(pos)) {
        _pointer = e.pointer;
        sc.draggingSun = true;
      }
    } else if (!sc.orbiting && sc.hitEarth(pos)) {
      _pointer = e.pointer;
      sc.draggingEarth = true;
      _lastX = pos.dx;
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final pos = e.localPosition;
    final sc = _scene;
    if (sc.draggingSun) {
      // Pointer x across the canvas maps to 0 (sunrise) .. 100 (sunset).
      final v = (pos.dx / _kDesign.width * 100).clamp(0, 100).round();
      if (v != sc.timeVal) _setTime(v);
    } else if (sc.draggingEarth) {
      sc.earthRot += (pos.dx - _lastX) * 0.01;
      _lastX = pos.dx;
      sc.earthSpun = true;
      if (_step == 1 && sc.earthRot.abs() > 1.0) _validate();
    }
  }

  void _onUp(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    _scene.draggingSun = false;
    _scene.draggingEarth = false;
  }

  Offset? _toCanvas(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  bool _insideCanvas(Offset? p) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (p == null || box is! RenderBox || !box.hasSize) return false;
    return p.dx > 0 && p.dy > 0 && p.dx < box.size.width && p.dy < box.size.height;
  }

  // --------------------------------------------------------------- UI

  List<LabAction> _actions() {
    if (_scenario == 0 && _step >= 4) {
      return [
        LabAction(
          label: _t('mark_shadow'),
          icon: Icons.edit,
          highlight: !_done,
          onTap: _markShadow,
        ),
        LabAction(
          label: _t('reset'),
          icon: Icons.delete_outline,
          color: _Colors.red600,
          foreground: Colors.white,
          onTap: _resetMarks,
        ),
      ];
    }
    if (_scenario == 1 && _step >= 2) {
      final on = _scene.orbiting;
      return [
        LabAction(
          label: on ? _t('pause_orbit') : _t('play_orbit'),
          icon: on ? Icons.pause_circle_filled : Icons.play_circle_fill,
          color: on ? _Colors.slate700 : _Colors.zslYellow,
          foreground: on ? Colors.white : _Colors.slate900,
          highlight: !_done && (_step == 2 || on),
          onTap: _toggleOrbit,
        ),
      ];
    }
    return const [];
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
        return LabShell(
          controller: _lab,
          icon: Icons.wb_sunny,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          instruction: _done ? _t('free_explore') : null,
          actions: actions,
          sidebarExtraTitle: _t('theory'),
          sidebarExtra: _theoryCard(p, s),
          onReset: _fullReset,
          showHud: false,
          overlays: [
            Positioned.fill(child: IgnorePointer(child: SizedBox.expand(key: _canvasKey))),
            _hud(context, p, s, actions),
            if (_gnomonDrag != null) _dragClone(s),
          ],
          stage: LabStage(
            designSize: _kDesign,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onDown,
              onPointerMove: _onMove,
              onPointerUp: _onUp,
              onPointerCancel: _onUp,
              child: CustomPaint(
                size: _kDesign,
                painter: _A5Painter(
                  scene: _scene,
                  repaint: _frame,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  labels: {for (final k in _kLabelKeys) k: _t(k)},
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar: the variables, the current step's theory (or the "Complete"
  /// free-exploration note) and the shadow-mark counter.
  Widget _theoryCard(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t('vars_${_scenario + 1}'),
          style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w700, height: 1.35),
        ),
        SizedBox(height: 8 * s),
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: (_done ? _Colors.green : _Colors.zslYellow).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(color: _done ? _Colors.green : _Colors.zslYellow, width: 3),
            ),
          ),
          child: _done
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 15 * s, color: _Colors.green),
                        SizedBox(width: 6 * s),
                        Text(
                          _t('complete'),
                          style: TextStyle(color: _Colors.green, fontWeight: FontWeight.w800, fontSize: 12 * f),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * s),
                    Text(_t('free_explore'), style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.45)),
                  ],
                )
              : Text(
                  _t('theory_${_scenario + 1}_$_step'),
                  style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.5, fontWeight: FontWeight.w500),
                ),
        ),
        if (_scenario == 0 && _step >= 4) ...[
          SizedBox(height: 6 * s),
          LabInfoRow(
            palette: p,
            scale: f,
            label: _t('marks_count'),
            value: '${_scene.marks.length}/3',
            valueColor: _Colors.zslYellow,
          ),
        ],
      ],
    );
  }

  /// HTML bottom HUD ("Mission Control"): step status, the variables and
  /// the interaction area (gnomon toolbox, time slider, Mark / Reset,
  /// Play / Pause Orbit). The buttons also live in the sidebar / floating
  /// card, so here they are shown only while the sidebar is open.
  Widget _hud(BuildContext context, LabPalette p, double s, List<LabAction> actions) {
    final pad = MediaQuery.paddingOf(context);
    final done = _done;
    final n = _data.steps.length;
    final status = done ? _t('complete') : '${_lab.t('step')} $_step / $n';
    final accent = done ? _Colors.green : _Colors.zslYellow;
    final controls = <Widget>[
      if (_scenario == 0 && _step == 1) _toolboxRow(p, s),
      if (_scenario == 0 && _step >= 2) _timeSlider(p, s),
      if (actions.isNotEmpty && _lab.isSidebarOpen)
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) SizedBox(width: 8 * s),
                LabActionButton(action: actions[i], scale: s, expand: false, dense: true),
              ],
            ],
          ),
        ),
    ];
    return Positioned(
      left: 12,
      right: 64 + pad.right,
      bottom: 8 + pad.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560 * s),
          child: LabGlassCard(
            palette: p,
            padding: EdgeInsets.fromLTRB(12 * s, 7 * s, 12 * s, 8 * s),
            borderColor: accent.withValues(alpha: 0.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(done ? Icons.check_circle : Icons.info, size: 13 * s, color: accent),
                    SizedBox(width: 5 * s),
                    Flexible(
                      child: Text(
                        '${_t('mission_control').toUpperCase()} · $status',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: accent, fontSize: 10 * s, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(
                      child: Text(
                        _t('vars_${_scenario + 1}'),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                for (final w in controls) ...[SizedBox(height: 6 * s), w],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Toolbox:" + the draggable "Drag Gnomon (Stick)" tile. Releasing it
  /// anywhere over the canvas plants the gnomon at the sundial centre.
  Widget _toolboxRow(LabPalette p, double s) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_t('toolbox'), style: TextStyle(color: p.textMuted, fontSize: 12 * s, fontWeight: FontWeight.w700)),
          SizedBox(width: 10 * s),
          Listener(
            onPointerDown: (e) {
              _Audio.play(_Sound.pickup);
              setState(() => _gnomonDrag = _toCanvas(e.position));
            },
            onPointerMove: (e) {
              if (_gnomonDrag != null) setState(() => _gnomonDrag = _toCanvas(e.position));
            },
            onPointerUp: (e) {
              final at = _toCanvas(e.position);
              setState(() => _gnomonDrag = null);
              if (_insideCanvas(at)) _placeGnomon();
            },
            onPointerCancel: (_) => setState(() => _gnomonDrag = null),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
              decoration: BoxDecoration(
                color: _Colors.zslYellow.withValues(alpha: _gnomonDrag != null ? 0.16 : 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _Colors.zslYellow, width: 2),
                boxShadow: [BoxShadow(color: _Colors.zslYellow.withValues(alpha: 0.25), blurRadius: 12 * s)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pan_tool_alt, size: 17 * s, color: _Colors.zslYellow),
                  SizedBox(width: 6 * s),
                  Text(
                    _t('drag_gnomon'),
                    style: TextStyle(color: _Colors.zslYellow, fontWeight: FontWeight.w800, fontSize: 12.5 * s),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Time slider from SUNRISE (0) to SUNSET (100).
  Widget _timeSlider(LabPalette p, double s) {
    Widget end(String key, Color color) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny, size: 18 * s, color: color),
            Text(_t(key), style: TextStyle(color: p.text, fontSize: 8.5 * s, fontWeight: FontWeight.w800)),
          ],
        );
    return Row(
      children: [
        end('sunrise', const Color(0xFFF97316)),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5 * s,
              activeTrackColor: _Colors.zslYellow,
              inactiveTrackColor: p.isDark ? Colors.white24 : Colors.black26,
              thumbColor: _Colors.zslYellow,
              overlayColor: _Colors.zslYellow.withValues(alpha: 0.25),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10 * s, elevation: 4),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * s),
            ),
            child: Slider(
              value: _scene.timeVal.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (v) {
                final iv = v.round();
                if (iv != _scene.timeVal) _setTime(iv);
              },
            ),
          ),
        ),
        end('sunset', const Color(0xFFEA580C)),
      ],
    );
  }

  /// HTML `#drag-clone`: the stick follows the pointer while dragging.
  Widget _dragClone(double s) {
    final at = _gnomonDrag!;
    return Positioned(
      left: at.dx - 30 * s,
      top: at.dy - 30 * s,
      child: IgnorePointer(
        child: SizedBox(
          width: 60 * s,
          height: 60 * s,
          child: Center(
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 8 * s,
                height: 52 * s,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3E2A21), Color(0xFF8A6450), Color(0xFF5C4033)]),
                  borderRadius: BorderRadius.circular(4 * s),
                  boxShadow: [BoxShadow(color: _Colors.zslYellow.withValues(alpha: 0.7), blurRadius: 16 * s)],
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
// From Cl7S-Ch1-A5-Light__Shadows__and_Celestial_Movements.html (`i18n`,
// `SCENARIOS`), Telugu dropped. English keys of the HTML table became ids.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Light Shadows and Celestial Movements',
    'app_subtitle': 'Class 7 • The Ever-Evolving World of Science',
    'scen_1': "1. The Sun's Clock",
    'scen_2': '2. Shadows of the Cosmos',
    'obs_title': 'Observation Analysis',
    'mission_control': 'Mission Control',
    'toolbox': 'Toolbox:',
    'drag_gnomon': 'Drag Gnomon (Stick)',
    'sunrise': 'SUNRISE',
    'sunset': 'SUNSET',
    'mark_shadow': 'Mark Shadow',
    'reset': 'Reset',
    'play_orbit': 'Play Orbit',
    'pause_orbit': 'Pause Orbit',
    'vars_1': 'Independent: Time | Dependent: Shadow',
    'vars_2': 'Independent: Celestial Alignment | Dependent: Eclipses',
    'theory': 'Theory',
    'task_instr': 'Task Instructions',
    'sci_conclusion': 'Scientific Conclusion',
    'free_explore': 'Free Exploration! Feel free to manipulate the variables to observe the outcomes.',
    'complete': 'Complete',
    'excellent': 'Excellent!',
    'action_done': 'Action completed successfully.',
    'place_gnomon_first': 'Place the gnomon first!',
    'shadow_too_long': 'Shadow is too long to mark clearly here.',
    'shadow_marked': 'Shadow marked!',
    'complete_step1': 'Complete step 1 first!',
    'solar_captured': "Solar Eclipse captured! The Moon's shadow is on Earth.",
    'lunar_captured': "Lunar Eclipse captured! The Moon is within Earth's shadow.",
    'not_aligned': 'Not perfectly aligned for an eclipse. Keep orbiting.',
    'scenario_outcome': 'Scenario Outcome',
    'lbl_sun': 'Sun',
    'lbl_gnomon': 'Gnomon',
    'lbl_earth': 'Earth',
    'lbl_moon': 'Moon',
    'lbl_solar': 'Solar Eclipse',
    'lbl_lunar': 'Lunar Eclipse',
    'lbl_sunlight': 'Sunlight ➔',
    'lbl_day': 'Daytime',
    'lbl_night': 'Nighttime',
    'lbl_axis': "Earth's Rotation Axis",
    'conclusion_1':
        'As the Sun moves across the sky, shadows change predictably. They are longest at sunrise and sunset, and shortest at noon. Ancient sundials use this principle to measure time.',
    'conclusion_2':
        "Day and night are caused by Earth rotating into and out of its own shadow. Eclipses occur when one celestial body casts its shadow onto another (Solar Eclipse = Moon's shadow, Lunar Eclipse = Earth's shadow).",
    'theory_1_1':
        'Light travels in straight lines. When an opaque object blocks light, a shadow is formed. Ancient people used the predictable movement of the sun to tell time.',
    'theory_1_2': 'As the sun rises higher in the sky, the angle of light hitting the object becomes steeper.',
    'theory_1_3': 'As the sun sets, the angle of light becomes shallower again, but from the opposite direction.',
    'theory_1_4':
        'By marking the shadows at different times, we create a device that uses the sun to indicate the time of day.',
    'theory_2_1':
        'The Earth rotates on its axis. The side facing the Sun experiences day, while the side in its own shadow experiences night.',
    'theory_2_2': 'The Moon revolves around the Earth continuously.',
    'theory_2_3':
        'A solar eclipse occurs when the Moon passes exactly between the Sun and Earth, casting its shadow on Earth.',
    'theory_2_4':
        'A lunar eclipse occurs when the Earth passes exactly between the Sun and the Moon, casting its massive shadow onto the Moon.',
    // Added: small sidebar readout.
    'marks_count': 'Shadow marks',
  },
  'hi': {
    'app_title': 'प्रकाश, छाया और खगोलीय गतियां',
    'app_subtitle': 'कक्षा 7 • विज्ञान की निरंतर विकसित होती दुनिया',
    'scen_1': '1. सूर्य की घड़ी',
    'scen_2': '2. ब्रह्मांड की छायाएं',
    'obs_title': 'अवलोकन विश्लेषण',
    'mission_control': 'मिशन नियंत्रण',
    'toolbox': 'टूलबॉक्स:',
    'drag_gnomon': 'ग्नोमोन (छड़ी) खींचें',
    'sunrise': 'सूर्योदय',
    'sunset': 'सूर्यास्त',
    'mark_shadow': 'छाया चिह्नित करें',
    'reset': 'रीसेट',
    'play_orbit': 'कक्षा शुरू करें',
    'pause_orbit': 'कक्षा रोकें',
    'vars_1': 'स्वतंत्र: समय | आश्रित: छाया',
    'vars_2': 'स्वतंत्र: खगोलीय संरेखण | आश्रित: ग्रहण',
    'theory': 'सिद्धांत',
    'task_instr': 'कार्य निर्देश',
    'sci_conclusion': 'वैज्ञानिक निष्कर्ष',
    'free_explore': 'मुफ़्त अन्वेषण! परिणामों को देखने के लिए चर में हेरफेर करने के लिए स्वतंत्र महसूस करें।',
    'complete': 'पूर्ण',
    'excellent': 'बहुत बढ़िया!',
    'action_done': 'कार्रवाई सफलतापूर्वक पूरी हुई।',
    'place_gnomon_first': 'पहले ग्नोमोन रखें!',
    'shadow_too_long': 'यहाँ स्पष्ट रूप से चिह्नित करने के लिए छाया बहुत लंबी है।',
    'shadow_marked': 'छाया चिह्नित!',
    'complete_step1': 'पहले चरण 1 पूरा करें!',
    'solar_captured': 'सूर्य ग्रहण कैद! चंद्रमा की छाया पृथ्वी पर है।',
    'lunar_captured': 'चंद्र ग्रहण कैद! चंद्रमा पृथ्वी की छाया में है।',
    'not_aligned': 'ग्रहण के लिए पूरी तरह से संरेखित नहीं है। कक्षा में घूमते रहें।',
    'scenario_outcome': 'परिदृश्य का परिणाम',
    'lbl_sun': 'सूर्य',
    'lbl_gnomon': 'ग्नोमोन',
    'lbl_earth': 'पृथ्वी',
    'lbl_moon': 'चंद्रमा',
    'lbl_solar': 'सूर्य ग्रहण',
    'lbl_lunar': 'चंद्र ग्रहण',
    'lbl_sunlight': 'सूर्य का प्रकाश ➔',
    'lbl_day': 'दिन',
    'lbl_night': 'रात',
    'lbl_axis': 'पृथ्वी के घूर्णन की धुरी',
    'conclusion_1':
        'जैसे-जैसे सूर्य आकाश में घूमता है, छाया अनुमानित रूप से बदलती है। वे सूर्योदय और सूर्यास्त के समय सबसे लंबी और दोपहर में सबसे छोटी होती हैं। प्राचीन धूपघड़ी समय मापने के लिए इसी सिद्धांत का उपयोग करती थीं।',
    'conclusion_2':
        'दिन और रात पृथ्वी के अपनी ही छाया में अंदर-बाहर घूमने के कारण होते हैं। ग्रहण तब होते हैं जब एक खगोलीय पिंड दूसरे पर अपनी छाया डालता है (सूर्य ग्रहण = चंद्रमा की छाया, चंद्र ग्रहण = पृथ्वी की छाया)।',
    'theory_1_1':
        'प्रकाश सीधी रेखाओं में यात्रा करता है। जब एक अपारदर्शी वस्तु प्रकाश को रोकती है, तो एक छाया बनती है। प्राचीन लोग समय बताने के लिए सूर्य की अनुमानित गति का उपयोग करते थे।',
    'theory_1_2': 'जैसे-जैसे सूर्य आकाश में ऊंचा उठता है, वस्तु से टकराने वाले प्रकाश का कोण अधिक तीव्र हो जाता है।',
    'theory_1_3': 'जैसे-जैसे सूरज ढलता है, प्रकाश का कोण फिर से उथला हो जाता है, लेकिन विपरीत दिशा से।',
    'theory_1_4':
        'अलग-अलग समय पर छाया को चिह्नित करके, हम एक उपकरण बनाते हैं जो दिन का समय बताने के लिए सूर्य का उपयोग करता है।',
    'theory_2_1':
        'पृथ्वी अपनी धुरी पर घूमती है। सूर्य के सामने वाले भाग में दिन होता है, जबकि अपनी ही छाया वाले भाग में रात होती है।',
    'theory_2_2': 'चंद्रमा लगातार पृथ्वी की परिक्रमा करता है।',
    'theory_2_3':
        'सूर्य ग्रहण तब होता है जब चंद्रमा सूर्य और पृथ्वी के ठीक बीच से गुजरता है, जिससे पृथ्वी पर उसकी छाया पड़ती है।',
    'theory_2_4':
        'चंद्र ग्रहण तब होता है जब पृथ्वी सूर्य और चंद्रमा के ठीक बीच से गुजरती है, जिससे चंद्रमा पर उसकी विशाल छाया पड़ती है।',
    'marks_count': 'छाया चिह्न',
  },
};

/// Steps: `concept` = HTML step `obj`, `action` = `task`,
/// `observation` = `validationMsg`. The objective is the first step's `obj`.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: "The Sun's Clock",
      objective: 'Understand how the position of the Sun affects the length and direction of a shadow.',
      steps: [
        LabStep(
          concept: 'Understand how the position of the Sun affects the length and direction of a shadow.',
          action: 'DRAG the Stick (Gnomon) from the toolbox and DROP it onto the center blue mark of the sundial.',
          observation: 'Gnomon placed correctly!',
        ),
        LabStep(
          concept: 'Observe shadow changes from Sunrise to Noon.',
          action: "DRAG the Sun icon on the Time Slider (or drag the Sun directly in the sky) from 'Sunrise' to 'Noon'.",
          observation: 'Notice how the shadow shortens at noon!',
        ),
        LabStep(
          concept: 'Observe shadow changes from Noon to Sunset.',
          action: "DRAG the Time Slider (or drag the Sun manually) towards 'Sunset'.",
          observation: 'The shadow grows long in the opposite direction!',
        ),
        LabStep(
          concept: 'Create a simple sundial.',
          action: "CLICK 'Mark Shadow' at three different times to create a sundial.",
          observation: "You've created a basic sundial!",
        ),
      ],
    ),
    LabScenarioData(
      title: 'Shadows of the Cosmos',
      objective: "Understand how Earth's rotation causes day and night.",
      steps: [
        LabStep(
          concept: "Understand how Earth's rotation causes day and night.",
          action:
              'In this space view, you see the Sun, Earth, and Moon. A red marker shows your location on Earth. CLICK and DRAG the Earth horizontally to spin it on its axis.',
          observation: "Excellent! Earth's rotation creates the day/night cycle.",
        ),
        LabStep(
          concept: "Observe the Moon's Orbit.",
          action: "Now, let's observe the Moon. CLICK the 'Play Orbit' button to see the Moon travel around the Earth.",
          observation: 'Orbit initiated!',
        ),
        LabStep(
          concept: 'Identify a Solar Eclipse.',
          action:
              "Watch the Moon's orbit. CLICK the 'Pause' button exactly when the Moon passes between the Sun and the Earth.",
          observation: "Solar Eclipse captured! The Moon's shadow is on Earth.",
        ),
        LabStep(
          concept: 'Identify a Lunar Eclipse.',
          action: "CLICK 'Play Orbit' again. Now, CLICK 'Pause' when the Earth passes directly between the Sun and the Moon.",
          observation: "Lunar Eclipse captured! The Moon is in Earth's shadow.",
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'सूर्य की घड़ी',
      objective: 'समझें कि सूर्य की स्थिति छाया की लंबाई और दिशा को कैसे प्रभावित करती है।',
      steps: [
        LabStep(
          concept: 'समझें कि सूर्य की स्थिति छाया की लंबाई और दिशा को कैसे प्रभावित करती है।',
          action: 'टूलबॉक्स से छड़ी (ग्नोमोन) को खींचें और धूपघड़ी के केंद्र के नीले निशान पर छोड़ दें।',
          observation: 'ग्नोमोन सही ढंग से रखा गया!',
        ),
        LabStep(
          concept: 'सूर्योदय से दोपहर तक छाया के परिवर्तनों का निरीक्षण करें।',
          action: "समय स्लाइडर पर सूर्य के आइकन को (या सूर्य को सीधे आकाश में) 'सूर्योदय' से 'दोपहर' तक खींचें।",
          observation: 'ध्यान दें कि दोपहर में छाया कैसे छोटी हो जाती है!',
        ),
        LabStep(
          concept: 'दोपहर से सूर्यास्त तक छाया के परिवर्तनों का निरीक्षण करें।',
          action: "समय स्लाइडर को (या सूर्य को मैन्युअल रूप से) 'सूर्यास्त' की ओर खींचें।",
          observation: 'विपरीत दिशा में छाया लंबी हो जाती है!',
        ),
        LabStep(
          concept: 'एक साधारण धूपघड़ी बनाएं।',
          action: "धूपघड़ी बनाने के लिए तीन अलग-अलग समय पर 'छाया चिह्नित करें' पर क्लिक करें।",
          observation: 'आपने एक बुनियादी धूपघड़ी बना ली है!',
        ),
      ],
    ),
    LabScenarioData(
      title: 'ब्रह्मांड की छायाएं',
      objective: 'समझें कि पृथ्वी का घूर्णन दिन और रात कैसे बनाता है।',
      steps: [
        LabStep(
          concept: 'समझें कि पृथ्वी का घूर्णन दिन और रात कैसे बनाता है।',
          action:
              'इस अंतरिक्ष दृश्य में, आप सूर्य, पृथ्वी और चंद्रमा देखते हैं। एक लाल मार्कर पृथ्वी पर आपका स्थान दिखाता है। पृथ्वी को अपनी धुरी पर घुमाने के लिए क्षैतिज रूप से खींचें।',
          observation: 'बहुत बढ़िया! पृथ्वी का घूर्णन दिन/रात का चक्र बनाता है।',
        ),
        LabStep(
          concept: 'चंद्रमा की कक्षा का निरीक्षण करें।',
          action: "अब, आइए चंद्रमा का निरीक्षण करें। चंद्रमा को पृथ्वी के चारों ओर यात्रा करते देखने के लिए 'कक्षा शुरू करें' बटन पर क्लिक करें।",
          observation: 'कक्षा शुरू की गई!',
        ),
        LabStep(
          concept: 'सूर्य ग्रहण की पहचान करें।',
          action: "चंद्रमा की कक्षा देखें। चंद्रमा के सूर्य और पृथ्वी के बीच से गुजरने पर ठीक 'रोकें' बटन पर क्लिक करें।",
          observation: 'सूर्य ग्रहण कैद! चंद्रमा की छाया पृथ्वी पर है।',
        ),
        LabStep(
          concept: 'चंद्र ग्रहण की पहचान करें।',
          action: "फिर से 'कक्षा शुरू करें' पर क्लिक करें। अब, जब पृथ्वी सूर्य और चंद्रमा के ठीक बीच से गुजरे तो 'रोकें' पर क्लिक करें।",
          observation: 'चंद्र ग्रहण कैद! चंद्रमा पृथ्वी की छाया में है।',
        ),
      ],
    ),
  ],
};

// ============================================================ SCENE MODEL

const Size _kDesign = Size(1000, 560);

/// (560 / 2) / tan(22.5°): the HTML PerspectiveCamera (45° vertical FOV).
const double _kFocal = 280 / 0.41421356237;

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

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Perspective camera at [pos] looking at [target] (OrbitControls lookAt).
class _Cam {
  _Cam(this.pos, this.target) {
    f = (target - pos).unit;
    r = f.cross(const _V3(0, 1, 0)).unit;
    u = r.cross(f);
  }

  final _V3 pos, target;
  late final _V3 f, r, u;

  double depth(_V3 w) => (w - pos).dot(f);
  double k(_V3 w) => _kFocal / math.max(depth(w), 0.05);

  Offset p(_V3 w) {
    final d = w - pos;
    final kk = _kFocal / math.max(d.dot(f), 0.05);
    return Offset(500 + d.dot(r) * kk, 280 - d.dot(u) * kk);
  }
}

/// A marked shadow (HTML `markShadow` plane): unit direction + length.
class _Mark {
  const _Mark(this.dx, this.dz, this.length);
  final double dx, dz, length;
}

/// A texture blob of the procedural Earth / Moon canvas textures, stored
/// as a unit vector on the sphere (local frame) + angular radius.
class _Blob {
  const _Blob(this.n, this.alpha, this.color);
  final _V3 n;
  final double alpha;
  final Color color;
}

/// Three.js SphereGeometry UV → local point (x = -cos φ sin θ, y = cos θ,
/// z = sin φ sin θ) for a canvas pixel (u, v) of a w x h texture.
_V3 _uvToSphere(double u, double v, double w, double h) {
  final phi = u / w * 2 * math.pi;
  final theta = v / h * math.pi;
  return _V3(-math.cos(phi) * math.sin(theta), math.cos(theta), math.sin(phi) * math.sin(theta));
}

/// HTML `createEarthTexture()` blobs (ocean shades, land, sand).
final List<_Blob> _earthBlobs = () {
  final rnd = math.Random(7);
  final list = <_Blob>[];
  void add(int count, double minR, double spread, Color color) {
    for (var i = 0; i < count; i++) {
      final n = _uvToSphere(rnd.nextDouble() * 512, rnd.nextDouble() * 256, 512, 256);
      list.add(_Blob(n, (rnd.nextDouble() * spread + minR) * math.pi / 256, color));
    }
  }

  add(50, 10, 30, const Color(0xFF2389DA));
  add(60, 5, 25, const Color(0xFF228B22));
  add(20, 5, 15, const Color(0xFFEAB676));
  return list;
}();

/// HTML `createMoonTexture()` craters.
final List<_Blob> _moonBlobs = () {
  final rnd = math.Random(11);
  return [
    for (var i = 0; i < 40; i++)
      _Blob(
        _uvToSphere(rnd.nextDouble() * 256, rnd.nextDouble() * 256, 256, 256),
        (rnd.nextDouble() * 15 + 2) * math.pi / 160,
        const Color(0xFF999999),
      ),
  ];
}();

class _A5Scene {
  int scenario = 0;
  double time = 0;

  // ---- Scenario 1: the Sun's clock.
  bool stickPlaced = false;
  int timeVal = 0;
  final List<_Mark> marks = [];
  bool markSunrise = false, markNoon = false, markSunset = false;
  bool draggingSun = false;

  static final _Cam cam1 = _Cam(const _V3(0, 15, 35), const _V3(0, 0, 0));

  double get sunAngle => math.pi - (timeVal / 100) * math.pi;

  /// HTML `updateSunPositionS1()`.
  _V3 get sunPos {
    final a = sunAngle;
    return _V3(math.cos(a) * 30, math.max(math.sin(a) * 30, 2.0), -15);
  }

  double get lightIntensity => math.max(0.4, math.sin(sunAngle) * 1.4);

  /// Diffuse factor for horizontal surfaces: ambient + sun (n·L), softly
  /// compressed so that the noon Sun does not wash the dial out to white.
  double get groundLight {
    final p = sunPos;
    return 0.62 + 0.5 * lightIntensity * (p.y / p.length);
  }

  // ---- Scenario 2: shadows of the cosmos.
  double earthRot = 0;
  double moonAngle = math.pi / 2;
  bool orbiting = false;
  bool earthSpun = false;
  bool playedAfterSolar = false;
  bool draggingEarth = false;
  _V3 camPos = const _V3(0, 20, 45);
  _V3 camTarget = const _V3(0, 0, 0);

  _Cam get cam2 => _Cam(camPos, camTarget);

  _V3 get moonPos => _V3(math.cos(moonAngle) * 16, 0, math.sin(moonAngle) * 16);

  double get normAngle => ((moonAngle % (2 * math.pi)) + 2 * math.pi) % (2 * math.pi);
  bool get isSolar => (normAngle - math.pi).abs() < 0.35;
  bool get isLunar => normAngle < 0.35 || normAngle > 2 * math.pi - 0.35;

  /// Blood-moon tint of `updateMoonPositionS2()` (within 0.25 rad).
  bool get lunarTint => normAngle < 0.25 || (normAngle - 2 * math.pi).abs() < 0.25;

  /// Earth's axis (child cylinder tilted -0.3 about z, spun with the Earth).
  _V3 get axisDir => _V3(math.sin(0.3) * math.cos(earthRot), math.cos(0.3), -math.sin(0.3) * math.sin(earthRot));

  _V3 get markerPos => _V3(4 * math.sin(earthRot), 0, 4 * math.cos(earthRot));

  // ---- Hit tests (design coordinates).

  bool hitSun(Offset s) {
    final c = cam1;
    final p = sunPos;
    return (c.p(p) - s).distance <= 4.5 * c.k(p);
  }

  bool hitEarth(Offset s) {
    final c = cam2;
    const o = _V3(0, 0, 0);
    if ((c.p(o) - s).distance <= 4 * c.k(o)) return true;
    // The rotation axis child (14 units long) is part of the hit test.
    final a = c.p(axisDir * 7), b = c.p(axisDir * -7);
    final ab = b - a;
    final t = (((s - a).dx * ab.dx + (s - a).dy * ab.dy) / math.max(ab.distanceSquared, 1e-6)).clamp(0.0, 1.0);
    return (a + ab * t - s).distance <= 8;
  }
}

// ============================================================ HELPERS

Path _poly(List<Offset> pts) {
  final path = Path();
  if (pts.isEmpty) return path;
  path.moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
    path.lineTo(pts[i].dx, pts[i].dy);
  }
  return path..close();
}

/// Multiplies a colour by a light factor (MeshStandardMaterial look).
Color _lit(Color c, double f) => Color.fromARGB(
      (c.a * 255).round(),
      (c.r * 255 * f).clamp(0, 255).round(),
      (c.g * 255 * f).clamp(0, 255).round(),
      (c.b * 255 * f).clamp(0, 255).round(),
    );

/// HTML `.html-label` (dark glass chip), `.eclipse-label` (red, pulsing)
/// and `.light-label` (plain white text with a dark glow).
void _htmlLabel(Canvas c, String text, Offset at, {int kind = 0, double pulse = 1}) {
  if (kind == 2) {
    // "Sunlight ➔": the arrow is drawn as a vector so it never depends on
    // the font having the dingbat glyph.
    final arrow = text.contains('➔');
    final r = labText(
      c,
      text.replaceAll('➔', '').trim(),
      arrow ? at.translate(-10, 0) : at,
      size: 14,
      weight: FontWeight.w800,
      color: Colors.white,
      shadows: const [Shadow(color: Colors.black, blurRadius: 4), Shadow(color: Colors.black, blurRadius: 2)],
    );
    if (arrow) {
      final y = r.center.dy;
      labArrow(c, Offset(r.right + 5, y + 1), Offset(r.right + 23, y + 1), color: Colors.black54, width: 3, head: 8);
      labArrow(c, Offset(r.right + 4, y), Offset(r.right + 22, y), color: Colors.white, width: 2.4, head: 8);
    }
    return;
  }
  if (kind == 1) {
    c.save();
    c.translate(at.dx, at.dy);
    c.scale(pulse);
    labGlow(c, Offset.zero, 60, const Color(0xFFEF4444), intensity: 0.45);
    labText(
      c,
      text,
      Offset.zero,
      size: 14,
      weight: FontWeight.w800,
      color: Colors.white,
      background: const Color(0xE6EF4444),
      border: const Color(0xFFFCA5A5),
      borderWidth: 1,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
    c.restore();
    return;
  }
  labText(
    c,
    text,
    at,
    size: 13,
    weight: FontWeight.w800,
    color: Colors.white,
    background: const Color(0xB3000000),
    border: const Color(0x33FFFFFF),
    borderWidth: 1,
    radius: 6,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  );
}

/// Convex hull (monotone chain) of projected points.
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

// ============================================================ PAINTER

class _A5Painter extends CustomPainter {
  _A5Painter({
    required this.scene,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labels,
  }) : super(repaint: repaint);

  final _A5Scene scene;
  final bool showLabels;
  final String lang;
  final Map<String, String> labels;

  _A5Scene get s => scene;
  String _l(String key) => labels[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    if (s.scenario == 0) {
      _paintSundial(canvas, size);
    } else {
      _SpaceDrawer(s, showLabels, _l).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _A5Painter old) => old.showLabels != showLabels || old.lang != lang;

  // ===================================================== SCENARIO 1

  List<Offset> _ring(_Cam cam, double y, double r, {int n = 72}) => [
        for (var i = 0; i < n; i++)
          cam.p(_V3(r * math.cos(2 * math.pi * i / n), y, r * math.sin(2 * math.pi * i / n))),
      ];

  void _paintSundial(Canvas c, Size size) {
    final cam = _A5Scene.cam1;
    final bleed = labBleed(size);
    final b = s.groundLight;
    // CSS `.sky-bg` gradient behind the transparent renderer.
    c.drawRect(
      bleed,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6EB6FF), Color(0xFFD4F0FF)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    // Desert ground (300 x 300), lit by the Sun.
    final ground = _poly([
      for (final p in const [_V3(-150, 0, -150), _V3(150, 0, -150), _V3(150, 0, 33), _V3(-150, 0, 33)]) cam.p(p),
    ]);
    c.drawPath(ground, Paint()..color = _lit(const Color(0xFF937C62), b));
    final far = cam.p(const _V3(0, 0, -150)).dy;
    final haze = Rect.fromLTRB(bleed.left, far, bleed.right, far + 170);
    c.drawRect(
      haze,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFD4F0FF).withValues(alpha: 0.55), const Color(0x00D4F0FF)],
        ).createShader(haze),
    );
    _sunArc(c, cam);
    _sun(c, cam);
    _dial(c, cam, b);
    for (var i = 0; i < s.marks.length; i++) {
      _mark(c, cam, s.marks[i], 0.52 + i * 0.005);
    }
    if (s.stickPlaced) {
      _stickShadow(c, cam);
      _stick(c, cam);
    }
    _toolbox(c, cam, b);
    if (showLabels) {
      _htmlLabel(c, _l('lbl_sun'), cam.p(s.sunPos) + const Offset(0, -30));
      if (s.stickPlaced) _htmlLabel(c, _l('lbl_gnomon'), cam.p(const _V3(0, 3.5, 0)) + const Offset(0, -20));
    }
  }

  /// Faint white arc of the Sun's path (radius 30 at z = -15).
  void _sunArc(Canvas c, _Cam cam) {
    final pts = <Offset>[];
    for (var i = 0; i <= 50; i++) {
      final a = math.pi - (i / 50) * math.pi;
      pts.add(cam.p(_V3(math.cos(a) * 30, math.max(math.sin(a) * 30, 0) + 0.5, -15)));
    }
    final path = Path()..addPolygon(pts, false);
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  void _sun(Canvas c, _Cam cam) {
    final p = s.sunPos;
    final o = cam.p(p);
    final k = cam.k(p);
    labGlow(c, o, 9 * k, const Color(0xFFFFAA00), intensity: 0.45);
    c.drawCircle(o, 4.5 * k, Paint()..color = const Color(0xFFFFAA00).withValues(alpha: 0.3));
    c.drawCircle(
      o,
      3 * k,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFFFF3B0), Color(0xFFFFDD44), Color(0xFFFFC21A)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: o, radius: 3 * k)),
    );
  }

  /// Sundial (cylinder r 12, h 0.5) with its canvas texture: sand base,
  /// white outer circle and 16 hour lines; blue target ring at the centre.
  void _dial(Canvas c, _Cam cam, double b) {
    const sand = Color(0xFFBFA58A);
    final top = _ring(cam, 0.5, 12);
    final bottom = _ring(cam, 0, 12);
    c.drawPath(_poly(_hull([...top, ...bottom])), Paint()..color = _lit(sand, 0.6 + (b - 0.6) * 0.35));
    final topPath = _poly(top);
    c.drawPath(topPath, Paint()..color = _lit(sand, b));
    final k = cam.k(const _V3(0, 0.5, 0));
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, 0.14 * k)
      ..strokeCap = StrokeCap.round
      ..color = _lit(Colors.white, b);
    c.drawPath(_poly(_ring(cam, 0.5, 11.72)), line);
    for (var i = 0; i < 16; i++) {
      final a = i / 16 * 2 * math.pi;
      c.drawLine(cam.p(const _V3(0, 0.5, 0)), cam.p(_V3(math.cos(a) * 11.72, 0.5, math.sin(a) * 11.72)), line);
    }
    c.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _lit(sand, b * 1.15),
    );
    c.drawPath(
      _poly(_ring(cam, 0.51, 0.9, n: 32)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, 0.2 * k)
        ..color = const Color(0xFF3B82F6),
    );
  }

  /// A marked shadow: black plane 0.4 wide, 60% opacity.
  void _mark(Canvas c, _Cam cam, _Mark m, double y) {
    final px = -m.dz * 0.2, pz = m.dx * 0.2;
    final tx = m.dx * m.length, tz = m.dz * m.length;
    c.drawPath(
      _poly([
        cam.p(_V3(px, y, pz)),
        cam.p(_V3(tx + px, y, tz + pz)),
        cam.p(_V3(tx - px, y, tz - pz)),
        cam.p(_V3(-px, y, -pz)),
      ]),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
  }

  /// Soft quad from [a] to [b] (world) with per-end widths and opacities.
  void _shadowSeg(Canvas c, _Cam cam, _V3 a, _V3 b, double wa, double wb, double aa, double ab) {
    final pa = cam.p(a), pb = cam.p(b);
    final d = pb - pa;
    if (d.distance < 0.5) return;
    final n = Offset(-d.dy, d.dx) / d.distance;
    final ka = wa * cam.k(a) / 2, kb = wb * cam.k(b) / 2;
    c.drawPath(
      _poly([pa + n * ka, pb + n * kb, pb - n * kb, pa - n * ka]),
      Paint()
        ..shader = ui.Gradient.linear(pa, pb, [
          Colors.black.withValues(alpha: aa),
          Colors.black.withValues(alpha: ab),
        ])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  /// The gnomon's shadow cast away from the Sun (on the dial, then on the
  /// ground if it runs past the dial's edge).
  void _stickShadow(Canvas c, _Cam cam) {
    final sp = s.sunPos;
    final lightPart = s.lightIntensity * sp.y / sp.length;
    final alpha = 0.32 + 0.4 * lightPart / (0.6 + lightPart);
    final tipD = _V3(-6 * sp.x / sp.y, 0.5, -6 * sp.z / sp.y);
    final h = math.sqrt(tipD.x * tipD.x + tipD.z * tipD.z);
    const base = _V3(0, 0.5, 0);
    if (h <= 12) {
      _shadowSeg(c, cam, base, tipD, 0.42, 0.6, alpha, alpha * 0.6);
      return;
    }
    final ex = tipD.x / h * 12, ez = tipD.z / h * 12;
    final f = 12 / h;
    final mid = alpha * (1 - 0.45 * f);
    _shadowSeg(c, cam, base, _V3(ex, 0.5, ez), 0.42, 0.48, alpha, mid);
    final tipG = _V3(-6.5 * sp.x / sp.y, 0, -6.5 * sp.z / sp.y);
    _shadowSeg(c, cam, _V3(ex, 0, ez), tipG, 0.48, 0.75, mid, alpha * 0.35);
  }

  /// Gnomon: brown cylinder (r 0.15) from y 0.5 to 6.5, lit from the Sun.
  void _stick(Canvas c, _Cam cam) {
    const wood = Color(0xFF5C4033);
    final a = cam.p(const _V3(0, 0.5, 0)), b = cam.p(const _V3(0, 6.5, 0));
    final wa = 0.15 * cam.k(const _V3(0, 0.5, 0)), wb = 0.15 * cam.k(const _V3(0, 6.5, 0));
    final path = _poly([a.translate(-wa, 0), b.translate(-wb, 0), b.translate(wb, 0), a.translate(wa, 0)]);
    final lit = _lit(wood, 0.6 + s.lightIntensity * 0.8);
    final dark = _lit(wood, 0.55);
    final fromLeft = s.sunPos.x < 0;
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: fromLeft ? [lit, wood, dark] : [dark, wood, lit],
        ).createShader(path.getBounds()),
    );
    c.drawOval(Rect.fromCenter(center: b, width: wb * 2, height: wb * 0.8), Paint()..color = _lit(wood, 1.2));
  }

  /// Slate toolbox (4 x 0.5 x 4) near the camera.
  void _toolbox(Canvas c, _Cam cam, double b) {
    const slate = Color(0xFF64748B);
    final sp = s.sunPos;
    final off = _V3(-sp.x / sp.y * 0.5, 0, 15 / sp.y * 0.5);
    c.drawPath(
      _poly([
        for (final p in const [_V3(-2, 0, 13), _V3(2, 0, 13), _V3(2, 0, 17), _V3(-2, 0, 17)]) cam.p(p + off * 0.5),
      ]),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    c.drawPath(
      _poly([for (final p in const [_V3(-2, 0.5, 17), _V3(2, 0.5, 17), _V3(2, 0, 17), _V3(-2, 0, 17)]) cam.p(p)]),
      Paint()..color = _lit(slate, 0.6),
    );
    c.drawPath(
      _poly([for (final p in const [_V3(-2, 0.5, 13), _V3(2, 0.5, 13), _V3(2, 0.5, 17), _V3(-2, 0.5, 17)]) cam.p(p)]),
      Paint()..color = _lit(slate, b),
    );
  }
}

// ===================================================================== SPACE

/// Scenario 2: Sun (far left), sunlight beam, Earth (with axis and red
/// location marker), Moon on a dashed orbit, day / night shading and the
/// eclipse shadows. Directional light travels along +x (Sun at x = -60).
class _SpaceDrawer {
  _SpaceDrawer(this.s, this.showLabels, this.l);

  final _A5Scene s;
  final bool showLabels;
  final String Function(String key) l;

  static const _V3 _origin = _V3(0, 0, 0);
  static const _V3 _toLight = _V3(-1, 0, 0);
  static const double _near = 0.5;

  static final List<(Offset, double, double)> _stars = () {
    final rnd = math.Random(3);
    return [
      for (var i = 0; i < 240; i++)
        (
          Offset(rnd.nextDouble() * 3000 - 1000, rnd.nextDouble() * 1800 - 620),
          0.5 + rnd.nextDouble() * 1.1,
          0.2 + rnd.nextDouble() * 0.55,
        ),
    ];
  }();

  void paint(Canvas c, Size size) {
    final cam = s.cam2;
    final bleed = labBleed(size);
    c.drawRect(bleed, Paint()..color = Colors.black);
    final center = Offset(size.width / 2, size.height / 2);
    final rad = math.sqrt(center.dx * center.dx + center.dy * center.dy);
    c.drawCircle(
      center,
      rad,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFF0F172A), Color(0xFF000000)])
            .createShader(Rect.fromCircle(center: center, radius: rad)),
    );
    for (final st in _stars) {
      final tw = 0.75 + 0.25 * math.sin(s.time * 1.7 + st.$1.dx);
      c.drawCircle(st.$1, st.$2, Paint()..color = Colors.white.withValues(alpha: st.$3 * tw));
    }
    _sun(c, cam);
    _orbit(c, cam);
    // Painter's order: Moon behind the sunlight plane, plane, then the
    // Earth and the Moon sorted by depth.
    final behindPlane = s.moonPos.z < -1.2;
    if (behindPlane) _moon(c, cam);
    _sunlightPlane(c, cam);
    final moonFar = cam.depth(s.moonPos) > cam.depth(_origin);
    if (!behindPlane && moonFar) _moon(c, cam);
    _earth(c, cam);
    if (!behindPlane && !moonFar) _moon(c, cam);
    if (showLabels) _labels(c, cam);
  }

  /// Clips a world polygon against the camera's near plane and projects it.
  List<Offset> _clipProject(_Cam cam, List<_V3> pts) {
    final out = <_V3>[];
    for (var i = 0; i < pts.length; i++) {
      final a = pts[i], b = pts[(i + 1) % pts.length];
      final da = cam.depth(a), db = cam.depth(b);
      if (da >= _near) out.add(a);
      if ((da >= _near) != (db >= _near)) {
        out.add(_V3.lerp(a, b, (_near - da) / (db - da)));
      }
    }
    return [for (final p in out) cam.p(p)];
  }

  void _sun(Canvas c, _Cam cam) {
    const p = _V3(-60, 0, 0);
    if (cam.depth(p) < 8) return;
    final o = cam.p(p);
    final k = cam.k(p);
    labGlow(c, o, 16 * k, const Color(0xFFFFAA00), intensity: 0.5);
    c.drawCircle(o, 9.5 * k, Paint()..color = const Color(0xFFFFAA00).withValues(alpha: 0.2));
    c.drawCircle(
      o,
      8 * k,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.2, -0.2),
          colors: [Color(0xFFFFF6C2), Color(0xFFFFDD44), Color(0xFFFFB81A)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: o, radius: 8 * k)),
    );
  }

  /// Gradient sunlight plane (60 x 24) from the Sun towards the Earth.
  void _sunlightPlane(Canvas c, _Cam cam) {
    final pts = _clipProject(cam, const [_V3(-60, 12, 0), _V3(0, 12, 0), _V3(0, -12, 0), _V3(-60, -12, 0)]);
    if (pts.length < 3) return;
    var from = const _V3(-60, 0, 0);
    if (cam.depth(from) < _near) {
      final dt = cam.depth(_origin);
      from = _V3.lerp(_origin, from, (dt - _near) / math.max(dt - cam.depth(from), 1e-6));
    }
    final a = cam.p(from), b = cam.p(_origin);
    if ((b - a).distance < 1) return;
    final full = (b - a).distance;
    final startAlpha = 0.4 * (from.x / -60).clamp(0.0, 1.0);
    c.drawPath(
      _poly(pts),
      Paint()
        ..shader = ui.Gradient.linear(a, a + (b - a) / full * full, [
          const Color(0xFFFFD700).withValues(alpha: startAlpha),
          const Color(0x00FFD700),
        ]),
    );
  }

  /// Dashed white orbit (radius 16, XZ plane, 50% opacity).
  void _orbit(Canvas c, _Cam cam) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: 0.5);
    Path? run;
    for (var i = 0; i <= 100; i++) {
      final a = i / 100 * 2 * math.pi;
      final w = _V3(math.cos(a) * 16, 0, math.sin(a) * 16);
      if (cam.depth(w) < _near + 0.5) {
        if (run != null) labDashedPath(c, run, paint, dash: 6, gap: 6);
        run = null;
        continue;
      }
      final p = cam.p(w);
      if (run == null) {
        run = Path()..moveTo(p.dx, p.dy);
      } else {
        run.lineTo(p.dx, p.dy);
      }
    }
    if (run != null) labDashedPath(c, run, paint, dash: 6, gap: 6);
  }

  /// Night side of a sphere lit from [toLight]: the visible half of the
  /// terminator great circle plus the night half of the limb.
  Path? _nightPath(_Cam cam, _V3 c0, double r, _V3 toLight, Offset pc, double rp) {
    final v = (cam.pos - c0).unit;
    final w0 = toLight.cross(v);
    if (w0.length < 1e-3) {
      return toLight.dot(v) > 0 ? null : (Path()..addOval(Rect.fromCircle(center: pc, radius: rp)));
    }
    final w = w0.unit;
    var q = w.cross(toLight).unit;
    if (q.dot(v) < 0) q = q * -1;
    var side = v.cross(w).unit;
    if (side.dot(toLight) > 0) side = side * -1;
    final pts = <Offset>[];
    for (var i = 0; i <= 28; i++) {
      final a = math.pi * i / 28;
      pts.add(cam.p(c0 + (w * math.cos(a) + q * math.sin(a)) * r));
    }
    for (var i = 0; i <= 28; i++) {
      final a = math.pi - math.pi * i / 28;
      pts.add(cam.p(c0 + (w * math.cos(a) + side * math.sin(a)) * (r * 1.06)));
    }
    return _poly(pts);
  }

  static Color _mul(Color a, Color? t) => t == null
      ? a
      : Color.fromARGB(255, (a.r * t.r * 255).round(), (a.g * t.g * 255).round(), (a.b * t.b * 255).round());

  /// Procedurally textured, lit sphere (MeshStandardMaterial + CanvasTexture).
  void _sphere(Canvas c, _Cam cam, _V3 c0, double r, double rotY, Color base, List<_Blob> blobs,
      {bool caps = false, Color? tint, double night = 0.74}) {
    if (cam.depth(c0) < r + _near) return;
    final pc = cam.p(c0);
    final rp = r * cam.k(c0);
    final rect = Rect.fromCircle(center: pc, radius: rp);
    c.save();
    c.clipPath(Path()..addOval(rect));
    c.drawCircle(pc, rp, Paint()..color = _mul(base, tint));
    final v = (cam.pos - c0).unit;
    final cr = math.cos(rotY), sr = math.sin(rotY);
    void blob(_V3 n0, double alpha, Color color) {
      final n = _V3(n0.x * cr + n0.z * sr, n0.y, -n0.x * sr + n0.z * cr);
      final facing = n.dot(v);
      if (facing < -0.02) return;
      final p = cam.p(c0 + n * r);
      final radial = p - pc;
      final ang = radial.distance < 1e-3 ? 0.0 : math.atan2(radial.dy, radial.dx);
      final major = rp * math.sin(alpha.clamp(0.0, 1.5));
      final minor = major * math.max(facing, 0.08);
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(ang);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: minor * 2, height: major * 2), Paint()..color = _mul(color, tint));
      c.restore();
    }

    for (final b in blobs) {
      blob(b.n, b.alpha, b.color);
    }
    if (caps) {
      blob(const _V3(0, 1, 0), 0.245, Colors.white);
      blob(const _V3(0, -1, 0), 0.245, Colors.white);
    }
    // Sun-facing sheen.
    final sub = cam.p(c0 + (_toLight + v).unit * (r * 0.75));
    c.drawCircle(
      sub,
      rp * 1.2,
      Paint()
        ..shader = RadialGradient(colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: sub, radius: rp * 1.2)),
    );
    final nightPath = _nightPath(cam, c0, r, _toLight, pc, rp);
    if (nightPath != null) {
      c.drawPath(
        nightPath,
        Paint()
          ..color = Colors.black.withValues(alpha: night)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(1.5, rp * 0.07)),
      );
    }
    c.drawCircle(
      pc,
      rp,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
        ], stops: const [0, 0.78, 1])
            .createShader(rect),
    );
    c.restore();
  }

  void _axisSeg(Canvas c, _Cam cam, _V3 dir) {
    final a = dir * 4, b = dir * 7;
    if (cam.depth(a) < _near || cam.depth(b) < _near) return;
    c.drawLine(
      cam.p(a),
      cam.p(b),
      Paint()
        ..color = Colors.white
        ..strokeWidth = math.max(1.4, 0.1 * cam.k(b))
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Earth (r 4): textured, day / night, Moon's umbra (solar eclipse),
  /// tilted rotation axis and the red location marker.
  void _earth(Canvas c, _Cam cam) {
    final v = (cam.pos - _origin).unit;
    final ax = s.axisDir;
    final front = ax.dot(v) >= 0 ? ax : ax * -1;
    _axisSeg(c, cam, front * -1);
    _sphere(c, cam, _origin, 4, s.earthRot, const Color(0xFF0F5E9C), _earthBlobs, caps: true);
    _moonShadowOnEarth(c, cam);
    _axisSeg(c, cam, front);
    final m = s.markerPos;
    if (m.unit.dot(v) > 0.05 && cam.depth(m) > _near) {
      final p = cam.p(m * 1.02);
      final rr = math.max(2.5, 0.3 * cam.k(m));
      labGlow(c, p, rr * 2.6, const Color(0xFFEF4444), intensity: 0.5);
      c.drawCircle(p, rr, Paint()..color = const Color(0xFFEF4444));
      c.drawCircle(p.translate(-rr * 0.3, -rr * 0.3), rr * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.5));
    }
  }

  /// The Moon's shadow on the Earth's day side when it is between them.
  void _moonShadowOnEarth(Canvas c, _Cam cam) {
    final m = s.moonPos;
    if (m.x >= 0 || m.z.abs() > 5.2) return;
    final v = (cam.pos - _origin).unit;
    final cz = m.z.clamp(-3.99, 3.99);
    final centerN = _V3(-math.sqrt(16 - cz * cz), 0, cz) * 0.25;
    if (centerN.dot(v) < -0.1) return;
    Path spot(double radius) {
      final pts = <Offset>[];
      for (var i = 0; i < 40; i++) {
        final a = 2 * math.pi * i / 40;
        var y = radius * math.cos(a), z = m.z + radius * math.sin(a);
        var rr = y * y + z * z;
        if (rr >= 15.99) {
          final f = 3.998 / math.sqrt(rr);
          y *= f;
          z *= f;
          rr = y * y + z * z;
        }
        pts.add(cam.p(_V3(-math.sqrt(math.max(0, 16 - rr)), y, z)));
      }
      return _poly(pts);
    }

    final pc = cam.p(_origin);
    final rp = 4 * cam.k(_origin);
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: pc, radius: rp)));
    c.drawPath(
      spot(2.4),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    c.drawPath(
      spot(1.2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.88)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    c.restore();
  }

  /// Moon (r 1.2): cratered, lit, blood-red near the lunar eclipse point
  /// and darkened by the Earth's umbra.
  void _moon(Canvas c, _Cam cam) {
    final m = s.moonPos;
    if (cam.depth(m) < 1.2 + _near) return;
    final tint = s.lunarTint ? const Color(0xFF6A2F2F) : null;
    _sphere(c, cam, m, 1.2, 0, const Color(0xFFCCCCCC), _moonBlobs, tint: tint, night: 0.7);
    if (m.x > 0 && m.z.abs() < 5.2) {
      final pm = cam.p(m);
      final rp = 1.2 * cam.k(m);
      final umbra = _poly([
        for (var i = 0; i < 48; i++)
          cam.p(_V3(m.x, 4 * math.cos(2 * math.pi * i / 48), 4 * math.sin(2 * math.pi * i / 48))),
      ]);
      c.save();
      c.clipPath(Path()..addOval(Rect.fromCircle(center: pm, radius: rp)));
      c.drawPath(
        umbra,
        Paint()
          ..color = Colors.black.withValues(alpha: tint != null ? 0.35 : 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      c.restore();
    }
    if (tint != null) {
      labGlow(c, cam.p(m), 1.2 * cam.k(m) * 1.8, const Color(0xFFB91C1C), intensity: 0.25);
    }
  }

  void _labels(Canvas c, _Cam cam) {
    final pulse = 1 + 0.05 * (0.5 - 0.5 * math.cos(s.time * math.pi));
    const sunP = _V3(-60, 0, 0);
    final e = cam.p(_origin);
    if (cam.depth(sunP) > _near) _htmlLabel(c, l('lbl_sun'), cam.p(sunP) + const Offset(-30, 0));
    _htmlLabel(c, l('lbl_earth'), e);
    final m = s.moonPos;
    final mp = cam.depth(m) > _near ? cam.p(m) : null;
    if (mp != null) _htmlLabel(c, l('lbl_moon'), mp);
    if (s.isSolar && !s.orbiting) _htmlLabel(c, l('lbl_solar'), e + const Offset(0, 30), kind: 1, pulse: pulse);
    if (s.isLunar && !s.orbiting && mp != null) {
      _htmlLabel(c, l('lbl_lunar'), mp + const Offset(0, 30), kind: 1, pulse: pulse);
    }
    _htmlLabel(c, l('lbl_sunlight'), e + const Offset(-80, 0), kind: 2);
    _htmlLabel(c, l('lbl_day'), e + const Offset(-60, -30), kind: 2);
    _htmlLabel(c, l('lbl_night'), e + const Offset(70, -30), kind: 2);
    _htmlLabel(c, l('lbl_axis'), e + const Offset(0, -70), kind: 2);
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
