// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 8 • Activity 4
/// Analyzing Uniform and Non-uniform Linear Motion.
///
/// Native Flutter port of
/// `Cl7S-Ch8-A4-Analyzing_Uniform_and_Non_uniform_Linear_Motion.html`.
/// Scenario 1: Train X (uniform) and Train Y (non-uniform) run along two
/// tracks from 09:30 to 11:00, leaving ghost images every 15 minutes while
/// a data table fills in; the trails are then labelled by drag and drop.
/// Scenario 2: a highway car (constant 80 km/h) and a city car (stops at a
/// red light) drop a dot every second for 30 s; the dot trails transform
/// into distance-time graphs and a fill-in-the-blank sentence is completed.
class Ch8A4AnalyzingUniformAndNonUniformLinearMotionPage extends StatefulWidget {
  const Ch8A4AnalyzingUniformAndNonUniformLinearMotionPage({super.key});

  @override
  State<Ch8A4AnalyzingUniformAndNonUniformLinearMotionPage> createState() =>
      _Ch8A4AnalyzingUniformAndNonUniformLinearMotionPageState();
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
  static const Color primary = Color(0xFF6366F1); // indigo-500
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

class _Ch8A4AnalyzingUniformAndNonUniformLinearMotionPageState
    extends State<Ch8A4AnalyzingUniformAndNonUniformLinearMotionPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _A4Scene _scene = _A4Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  // Drop zones (HTML `.drop-zone`).
  final GlobalKey _dzTrainX = GlobalKey();
  final GlobalKey _dzTrainY = GlobalKey();
  final GlobalKey _dzStraight = GlobalKey();
  final GlobalKey _dzCurved = GlobalKey();

  /// Offsets of the draggable panels (HTML `makePanelDraggable`).
  final Map<String, Offset> _panelOffsets = {};

  late final Ticker _ticker;
  late final AnimationController _trainAnim;
  late final AnimationController _graphAnim;
  Timer? _trainTimer;
  Timer? _carTimer;

  /// Invalidates pending ghost spawns after a reset.
  int _run = 0;
  double _fromX = -60, _toX = -60, _fromY = -60, _toY = -60;
  bool _moveX = false, _moveY = false, _yEaseIn = false;

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

    // HTML: TWEEN 900 ms per interval (linear; Train Y Quadratic.In at t = 3).
    _trainAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(() {
        final v = _trainAnim.value;
        if (_moveX) _scene.trainX = _fromX + (_toX - _fromX) * v;
        if (_moveY) _scene.trainY = _fromY + (_toY - _fromY) * (_yEaseIn ? Curves.easeInQuad.transform(v) : v);
      });
    // HTML transformToGraph: dots tween for 2000 ms.
    _graphAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..addListener(() => _scene.graphT = _graphAnim.value);
    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
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
    _trainTimer?.cancel();
    _carTimer?.cancel();
    _ticker.dispose();
    _trainAnim.dispose();
    _graphAnim.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ general

  /// HTML `resetApp(true)` -> `buildScenario()`.
  void _buildScenario() {
    _lab.cancelPending();
    _trainTimer?.cancel();
    _carTimer?.cancel();
    _trainAnim.stop();
    _graphAnim.stop();
    _run++;
    _scene.reset();
    _panelOffsets.clear();
    _lab.resetView(sound: false);
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

  /// HTML `advanceStep()`.
  void _advanceStep() {
    if (!mounted) return;
    final steps = _data.steps.length;
    if (_scene.step < steps) {
      setState(() => _scene.step++);
    } else if (_scene.step == steps) {
      _showConclusion();
    }
  }

  void _showConclusion() {
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 1000),
      title: () => _t('sci_conclusion'),
      heading: () => _t('lbl_observation'),
      body: () => _t('conclusion_${_scene.scenario + 1}'),
    );
  }

  /// HTML drop test: pointer inside the zone grown by a 35 px touch buffer.
  bool _isOver(Offset global, GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return false;
    final rect = MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
    return rect.inflate(35).contains(global);
  }

  // --------------------------------------------------------- scenario 1

  /// HTML `selectTrainMode()`: picks the train(s) and resets the run.
  void _selectMode(_Mode mode, {bool sound = true}) {
    final sc = _scene;
    if (sc.playing) return;
    if (sound) _Audio.play(_Sound.click);
    _trainAnim.stop();
    _run++;
    setState(() {
      sc.mode = mode;
      sc.resetTrains();
    });
  }

  /// HTML `startTrainSimulation()`: one 15-minute interval per second.
  void _startSimulation() {
    final sc = _scene;
    if (sc.playing) return;
    if (sc.finished) {
      // The button reads "Reset" once a run has finished.
      _selectMode(sc.mode);
      return;
    }
    _Audio.play(_Sound.whoosh);
    final run = ++_run;
    setState(() {
      sc.playing = true;
      sc.finished = false;
      // Starting a run completes the "observe the control panel" step.
      if (sc.step == 1) sc.step = 2;
    });
    var t = 0;
    _trainTimer?.cancel();
    _trainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || run != _run) {
        timer.cancel();
        return;
      }
      t++;
      setState(() => sc.simTime = t);
      _moveX = sc.xVisible;
      _moveY = sc.yVisible;
      _fromX = sc.trainX;
      _toX = -60 + _dataX[t];
      _fromY = sc.trainY;
      _toY = -60 + _dataY[t];
      _yEaseIn = t == 3;
      _trainAnim.forward(from: 0);
      // HTML spawnGhost(): a translucent copy appears when the move ends.
      final gx = _toX, gy = _toY, mx = _moveX, my = _moveY;
      _lab.after(const Duration(milliseconds: 900), () {
        if (!mounted || run != _run) return;
        setState(() {
          if (mx) sc.ghosts.add(_Ghost(gx, true));
          if (my) sc.ghosts.add(_Ghost(gy, false));
        });
      });
      if (t >= 6) {
        timer.cancel();
        setState(() {
          sc.playing = false;
          sc.finished = true;
          // HTML "smart step advancement".
          if (sc.mode == _Mode.x && sc.step <= 2) {
            sc.step = 3;
          } else if (sc.mode == _Mode.y && sc.step == 3) {
            sc.step = 4;
          } else if (sc.mode == _Mode.both && sc.step == 4) {
            sc.step = 5;
            sc.dndVisible = true;
          }
        });
      }
    });
  }

  /// Label dropped on a trail (scenario 1) or a blank (scenario 2).
  void _onWordDropped(_Kind kind, Offset global) {
    final sc = _scene;
    final s1 = sc.scenario == 0;
    final zones = s1
        ? [(_dzTrainX, _Kind.uniform), (_dzTrainY, _Kind.nonuniform)]
        : [(_dzStraight, _Kind.uniform), (_dzCurved, _Kind.nonuniform)];
    var dropped = false;
    for (final (key, accept) in zones) {
      if (accept == kind && _isOver(global, key)) dropped = true;
    }
    if (!dropped) {
      _lab.showToast(_t('msg_incorrect'), isError: true);
      setState(() {});
      return;
    }
    _Audio.play(_Sound.drop);
    setState(() {
      if (s1) {
        if (kind == _Kind.uniform) sc.xFilled = true;
        if (kind == _Kind.nonuniform) sc.yFilled = true;
      } else {
        if (kind == _Kind.uniform) sc.straightFilled = true;
        if (kind == _Kind.nonuniform) sc.curvedFilled = true;
      }
    });
    if (s1 && sc.xFilled && sc.yFilled) {
      _lab.after(const Duration(milliseconds: 1000), _advanceStep);
    } else if (!s1 && sc.straightFilled && sc.curvedFilled) {
      setState(() => sc.fibDone = true);
      _lab.after(const Duration(milliseconds: 1500), _advanceStep);
    }
  }

  // --------------------------------------------------------- scenario 2

  /// HTML `startCarSimulation()`: 100 ms physics ticks for 30 s.
  void _go() {
    final sc = _scene;
    if (!sc.goVisible) return;
    setState(() {
      sc.goVisible = false;
      sc.speedosVisible = true;
      sc.carsPlaying = true;
      sc.frame = 0;
      sc.lastTick = sc.time;
    });
    _advanceStep();
    final run = _run;
    _carTimer?.cancel();
    _carTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || run != _run || !sc.carsPlaying) {
        timer.cancel();
        return;
      }
      _carTick();
      if (sc.secs >= 30) {
        timer.cancel();
        setState(() {
          sc.carsPlaying = false;
          sc.graphButton = true;
        });
        _advanceStep();
      }
    });
  }

  void _carTick() {
    final sc = _scene;
    sc.frame++;
    sc.lastTick = sc.time;
    sc.prevHighwayX = sc.highwayX;
    sc.prevCityX = sc.cityX;
    sc.prevCitySpeed = sc.citySpeed;
    final secs = sc.secs;

    // Highway car: uniform, 80 km/h.
    sc.highwayX += 80 * 0.003;

    // City car: red light between x = -15 and 2, green after it.
    var target = 60.0;
    if (sc.cityX > -15 && sc.cityX < 2) {
      sc.redLight = true;
      target = 0;
    } else if (sc.cityX >= 2) {
      sc.redLight = false;
      target = 70;
    }
    if (sc.citySpeed < target) {
      sc.citySpeed += 2;
    } else if (sc.citySpeed > target) {
      sc.citySpeed -= 4;
    }
    if (sc.citySpeed < 0) sc.citySpeed = 0;
    sc.cityX += sc.citySpeed * 0.003;

    // A dot from each car every second.
    if (sc.frame % 10 == 0) {
      sc.dots.add(_Dot(highway: true, time: secs, initX: sc.highwayX));
      sc.dots.add(_Dot(highway: false, time: secs, initX: sc.cityX));
    }
    setState(() {});
    if (secs == 10 && sc.step == 2) _advanceStep(); // focus on the city car
  }

  /// HTML `transformToGraph()`.
  void _showGraph() {
    final sc = _scene;
    if (!sc.graphButton || sc.graphMode) return;
    _Audio.play(_Sound.success);
    setState(() {
      sc.graphButton = false;
      sc.graphMode = true;
    });
    final run = _run;
    _graphAnim.forward(from: 0).whenComplete(() {
      if (!mounted || run != _run || _graphAnim.value < 1) return;
      setState(() {
        sc.axes = true;
        sc.fibVisible = true;
      });
      _advanceStep();
    });
  }

  /// Moves a draggable panel (kept on the canvas).
  void _movePanel(String id, Offset delta, Size canvas) {
    final o = (_panelOffsets[id] ?? Offset.zero) + delta;
    setState(() {
      _panelOffsets[id] = Offset(
        o.dx.clamp(-canvas.width + 60, canvas.width - 60),
        o.dy.clamp(-canvas.height + 40, canvas.height - 40),
      );
    });
  }

  // ------------------------------------------------------------ actions

  List<LabAction> _actions() {
    final sc = _scene;
    if (sc.scenario == 0) {
      final resetLabel = sc.playing || sc.finished;
      return [
        LabAction(
          label: resetLabel ? _t('btn_reset') : _t('btn_start_sim'),
          icon: resetLabel ? Icons.restart_alt : Icons.play_circle_fill,
          color: _indigo600,
          foreground: Colors.white,
          enabled: !sc.playing,
          highlight: !resetLabel && sc.step < 5,
          silent: true, // plays its own sound
          onTap: _startSimulation,
        ),
      ];
    }
    return [
      if (sc.goVisible)
        LabAction(
          label: _t('btn_go'),
          icon: Icons.flag_rounded,
          color: _Colors.green,
          foreground: Colors.white,
          highlight: true,
          onTap: _go,
        ),
      if (sc.graphButton)
        LabAction(
          label: _t('btn_show_graph'),
          icon: Icons.show_chart_rounded,
          color: _indigo600,
          foreground: Colors.white,
          highlight: true,
          silent: true,
          onTap: _showGraph,
        ),
    ];
  }

  // ----------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.train,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, c) => _uiLayer(context, c.biggest, p, s),
              ),
            ),
          ],
          stage: LabStage(
            designSize: _design,
            child: CustomPaint(
              size: _design,
              painter: _A4Painter(
                scene: _scene,
                repaint: _frame,
                isDark: _lab.isDark,
                showLabels: _lab.showLabels,
                text: {
                  for (final k in const [
                    'train_x',
                    'train_y',
                    'lbl_highway',
                    'lbl_city',
                    'km',
                    'axis_time',
                    'axis_dist',
                    'highway_car',
                    'city_car',
                  ])
                    k: _t(k == 'km' ? 'u_km' : k),
                },
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
    'app_title': 'Analyzing Uniform and Non-uniform Linear Motion',
    'app_subtitle': 'Class 7 • Measurement of Time and Motion',
    'scen_1_opt': 'Scenario 1: The Tale of Two Trains',
    'scen_2_opt': 'Scenario 2: Highway vs. City Traffic',
    'sci_conclusion': 'Success!',
    'lbl_observation': 'Observation',
    'drop_here': 'Drop Here',
    'btn_start_sim': 'Start Simulation',
    'btn_both': 'Both',
    'sim_controls': 'Simulation Controls',
    'data_table_title': 'Distance Covered (km)',
    'time': 'Time',
    's1_dnd_title': 'Identify the Motion Type',
    'lbl_uniform': 'Uniform Motion',
    'lbl_nonuniform': 'Non-Uniform Motion',
    'train_x_trail': 'Train X Trail',
    'train_y_trail': 'Train Y Trail',
    'highway_car': 'Highway Car',
    'city_car': 'City Car',
    'btn_show_graph': 'Show Graph',
    'fib_part1': 'The straight line graph shows',
    'fib_part2': 'motion, while the curved line graph shows',
    'fib_part3': 'motion.',
    'conclusion_1':
        'Uniform motion covers equal distances in equal intervals of time. Non-uniform motion covers unequal distances in equal intervals.',
    'conclusion_2':
        'A straight, diagonal distance-time graph indicates uniform motion (constant speed). A curved graph indicates non-uniform motion (changing speed).',
    // Strings that were hard-coded (English only) in the HTML.
    'word_uniform': 'Uniform',
    'word_nonuniform': 'Non-uniform',
    'train_x': 'Train X',
    'train_y': 'Train Y',
    'btn_reset': 'Reset',
    'btn_go': 'GO!',
    'lbl_highway': 'Highway',
    'lbl_city': 'City Road',
    'u_kmph': 'km/h',
    'u_km': 'km',
    'msg_incorrect': 'Incorrect match. Try again!',
    'drag': 'DRAG',
    'time_am': '{t} AM',
    'axis_time': 'Time (s)',
    'axis_dist': 'Distance',
  },
  'hi': {
    'app_title': 'एकसमान और असमान रैखिक गति का विश्लेषण',
    'app_subtitle': 'कक्षा 7 • समय और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: दो ट्रेनों की कहानी',
    'scen_2_opt': 'परिदृश्य 2: राजमार्ग बनाम शहर यातायात',
    'sci_conclusion': 'सफलता!',
    'lbl_observation': 'अवलोकन',
    'drop_here': 'यहाँ छोड़ें',
    'btn_start_sim': 'सिमुलेशन शुरू करें',
    'btn_both': 'दोनों',
    'sim_controls': 'सिमुलेशन नियंत्रण',
    'data_table_title': 'तय की गई दूरी (किमी)',
    'time': 'समय',
    's1_dnd_title': 'गति के प्रकार को पहचानें',
    'lbl_uniform': 'एकसमान गति',
    'lbl_nonuniform': 'असमान गति',
    'train_x_trail': 'ट्रेन X मार्ग',
    'train_y_trail': 'ट्रेन Y मार्ग',
    'highway_car': 'राजमार्ग कार',
    'city_car': 'शहर की कार',
    'btn_show_graph': 'ग्राफ दिखाएं',
    'fib_part1': 'सीधी रेखा का ग्राफ',
    'fib_part2': 'गति को दर्शाता है, जबकि घुमावदार रेखा',
    'fib_part3': 'गति को दर्शाता है।',
    'conclusion_1':
        'एकसमान गति समान समय अंतराल में समान दूरी तय करती है। असमान गति समान समय अंतराल में असमान दूरी तय करती है।',
    'conclusion_2':
        'एक सीधा दूरी-समय ग्राफ एकसमान गति (निरंतर गति) को इंगित करता है। एक घुमावदार ग्राफ असमान गति को इंगित करता है।',
    'word_uniform': 'एकसमान',
    'word_nonuniform': 'असमान',
    'train_x': 'ट्रेन X',
    'train_y': 'ट्रेन Y',
    'btn_reset': 'रीसेट',
    'btn_go': 'GO!',
    'lbl_highway': 'राजमार्ग',
    'lbl_city': 'शहर की सड़क',
    'u_kmph': 'किमी/घंटा',
    'u_km': 'किमी',
    'msg_incorrect': 'गलत मिलान। फिर से प्रयास करें!',
    'drag': 'खींचें',
    'time_am': 'सुबह {t}',
    'axis_time': 'समय (सेकंड)',
    'axis_dist': 'दूरी',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually analyze and compare the motion of two trains based on given data, identifying uniform and non-uniform motion.',
      steps: [
        LabStep(
          concept: 'Setup',
          action: 'The scene shows a straight railway track. Observe the control panel.',
          observation: 'Trains are at 0 km.',
        ),
        LabStep(
          concept: 'Train X Motion',
          action: "Select 'Train X' and click 'Start Simulation'.",
          observation:
              'Train X moves, leaving equally spaced ghost images every 10 mins (20km, 40km...). Data table updates.',
        ),
        LabStep(
          concept: 'Train Y Motion',
          action: "Click 'Reset', select 'Train Y', and 'Start Simulation'.",
          observation: 'Train Y leaves unequally spaced ghost images (20km, 35km, 50km...). Its speed varies.',
        ),
        LabStep(
          concept: 'Direct Comparison',
          action: "Click 'Reset', select 'Both', and 'Start Simulation'.",
          observation: 'Comparing them side-by-side reveals the stark difference between constant and changing speed.',
        ),
        LabStep(
          concept: 'Identification',
          action: "Drag and drop the labels 'Uniform Motion' and 'Non-Uniform Motion' onto the correct trails.",
          observation: 'Terminology is linked to the visual evidence.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To distinguish between motion types by comparing a highway car with a city traffic car, and analyzing their distance-time graphs.',
      steps: [
        LabStep(
          concept: 'Start Journey',
          action: "Click the large 'GO!' button to start both cars simultaneously.",
          observation: 'Timer starts. Cars begin moving on different roads.',
        ),
        LabStep(
          concept: 'Uniform Observation',
          action: "Observe the Highway Car's speedometer and trail.",
          observation: 'Speed remains constant (80 km/h). Drops blue dots at perfectly equal intervals.',
        ),
        LabStep(
          concept: 'Non-Uniform Observation',
          action: "Observe the City Car's speedometer and trail.",
          observation: 'Speed fluctuates (stops at red light). Red dots bunch up when slow and spread out when fast.',
        ),
        LabStep(
          concept: 'Graph Transformation',
          action: "Wait for pause (30s), then click 'Show Graph'.",
          observation: 'Dot trails transform into distance-time graphs. Highway is straight; City is curved.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Fill in the blanks by dragging the correct terms.',
          observation: 'Graphs are correlated with uniform/non-uniform definitions.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'दिए गए डेटा के आधार पर दो ट्रेनों की गति का तुलनात्मक विश्लेषण करना।',
      steps: [
        LabStep(concept: 'सेटअप', action: 'नियंत्रण कक्ष का निरीक्षण करें।', observation: 'ट्रेनें 0 किमी पर हैं।'),
        LabStep(
          concept: 'ट्रेन X की गति',
          action: "'ट्रेन X' चुनें और 'सिमुलेशन शुरू करें' पर क्लिक करें।",
          observation: 'ट्रेन X हर 10 मिनट में समान दूरी पर चित्र छोड़ती है।',
        ),
        LabStep(
          concept: 'ट्रेन Y की गति',
          action: "'रीसेट' पर क्लिक करें, 'ट्रेन Y' चुनें और शुरू करें।",
          observation: 'ट्रेन Y असमान दूरी पर चित्र छोड़ती है। इसकी गति भिन्न होती है।',
        ),
        LabStep(
          concept: 'तुलना',
          action: 'दोनों को एक साथ चलाकर तुलना करें।',
          observation: 'निरंतर और बदलती गति के बीच का अंतर स्पष्ट है।',
        ),
        LabStep(
          concept: 'पहचान',
          action: "सही मार्ग पर 'एकसमान' और 'असमान' लेबल खींचें और छोड़ें।",
          observation: 'शब्दावली को दृश्य साक्ष्य से जोड़ा गया है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'राजमार्ग और शहर यातायात कार की तुलना करके दूरी-समय ग्राफ का विश्लेषण करना।',
      steps: [
        LabStep(
          concept: 'यात्रा शुरू करें',
          action: "दोनों कारों को शुरू करने के लिए 'GO!' पर क्लिक करें।",
          observation: 'टाइमर शुरू होता है।',
        ),
        LabStep(
          concept: 'एकसमान गति',
          action: 'राजमार्ग कार का निरीक्षण करें।',
          observation: 'गति स्थिर रहती है। नीले बिंदु समान अंतराल पर गिरते हैं।',
        ),
        LabStep(
          concept: 'असमान गति',
          action: 'शहर कार का निरीक्षण करें।',
          observation: 'गति में उतार-चढ़ाव होता है। लाल बिंदु असमान दूरी पर गिरते हैं।',
        ),
        LabStep(
          concept: 'ग्राफ',
          action: "रुकने की प्रतीक्षा करें, फिर 'ग्राफ दिखाएं' पर क्लिक करें।",
          observation: 'बिंदु दूरी-समय ग्राफ में बदल जाते हैं।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सही शब्दों को खींचकर रिक्त स्थान भरें।',
          observation: 'ग्राफ़ को परिभाषाओं के साथ सहसंबंधित किया जाता है।',
        ),
      ],
    ),
  ],
};

// ======================================================= ACTIVITY DATA

/// HTML `TrainData` (Table 8.3): clock times and distances from the start.
const List<String> _times = ['09:30', '09:45', '10:00', '10:15', '10:30', '10:45', '11:00'];
const List<double> _dataX = [0, 20, 40, 60, 80, 100, 120]; // uniform
const List<double> _dataY = [0, 15, 35, 60, 75, 95, 120]; // non-uniform

/// Train modes of the HTML `selectTrainMode()`.
enum _Mode { x, y, both }

/// Drag-and-drop label kinds (HTML `data-type` / `data-accept`).
enum _Kind { uniform, nonuniform }

// HTML / Tailwind colours.
const Color _trainBlue = Color(0xFF3B82F6);
const Color _trainRed = Color(0xFFEF4444);
const Color _indigo600 = Color(0xFF4F46E5);
const Color _purple = Color(0xFFA855F7);

// ======================================================== 3D HELPERS

const Size _design = Size(1000, 560);

/// Render-space compression of the travel axis so the whole 120 km track
/// (scenario 1) and both roads (scenario 2) fit the default view; object
/// sizes are not compressed.
const double _xs1 = 0.36;
const double _xs2 = 0.6;

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);
  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = length;
    return l < 1e-9 ? this : this * (1 / l);
  }

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// Perspective look-at camera (HTML PerspectiveCamera, fov 45) on the
/// 1000x560 design canvas. [shift] / [hshift] move the projected image
/// down / right (keeps the scene clear of the canvas overlays).
class _Cam {
  _Cam(this.pos, _V3 target, {this.shift = 0, this.hshift = 0}) {
    f = (target - pos).unit;
    final side = f.cross(const _V3(0, 1, 0));
    // Looking straight down: Three.js keeps screen-up = -z.
    r = side.length < 1e-6 ? const _V3(1, 0, 0) : side.unit;
    u = r.cross(f);
  }

  final _V3 pos;
  final double shift, hshift;
  late final _V3 f, r, u;
  static const double focal = 280 / 0.41421356; // (h / 2) / tan(22.5°)

  double depth(_V3 p) => (p - pos).dot(f);
  double scaleAt(_V3 p) => focal / math.max(0.1, depth(p));

  Offset project(_V3 p) {
    final d = p - pos;
    final z = math.max(0.1, d.dot(f));
    return Offset(500 + hshift + focal * d.dot(r) / z, 280 + shift - focal * d.dot(u) / z);
  }
}

/// Scenario 1 camera: HTML direction (0, 30, 40), a little closer.
final _Cam _cam1 = _Cam(const _V3(0, 24, 32), const _V3(0, 0, 0), shift: 100, hshift: -60);

/// Scenario 2 camera: oblique road view (HTML (0, 35, 30)) easing to the
/// top-down graph view as [t] goes 0 -> 1.
_Cam _cam2(double t) => _Cam(
      _V3.lerp(const _V3(0, 35, 30), const _V3(0, 130, -16.3), t),
      _V3.lerp(const _V3(0, 0, 0), const _V3(0, 0, -16.3), t),
      shift: 30 * (1 - t),
      hshift: 45 * (1 - t),
    );

/// HTML lights: ambient 0.6 + directional 0.8 from (20, 40, 20).
final _V3 _light = const _V3(20, 40, 20).unit;

Color _lit(Color c, _V3 n, {double opacity = 1}) {
  final d = math.max(0.0, n.dot(_light));
  final f = 0.7 + 0.42 * d;
  final out = f >= 1 ? labShade(c, (f - 1) * 1.2) : labShade(c, -(1 - f));
  return out.withValues(alpha: c.a * opacity);
}

// ============================================================== MODEL

@immutable
class _Ghost {
  const _Ghost(this.x, this.isX);
  final double x; // world x
  final bool isX;
}

/// A dot dropped by a car every second (HTML `dropDot`).
@immutable
class _Dot {
  const _Dot({required this.highway, required this.time, required this.initX});
  final bool highway;
  final int time;
  final double initX;

  /// Position on the road (render space).
  _V3 get road => _V3(initX * _xs2, 0.1, highway ? -5 : 5);

  /// HTML `transformToGraph`: X = time, Z = distance (screen up).
  _V3 get graph {
    final gx = -40 + time / 30 * 80;
    final dist = initX - (-50);
    final gz = 20 - (dist / 100) * 40 + (highway ? -5 : 5);
    return _V3(gx, 0.5, gz);
  }
}

/// Mutable state of both scenarios, read by the painter and the overlays.
class _A4Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  // ---------------------------------------------------- scenario 1
  _Mode mode = _Mode.x;
  bool playing = false;
  bool finished = false;
  int simTime = 0;
  double trainX = -60, trainY = -60; // world x of the train centres
  final List<_Ghost> ghosts = [];
  bool dndVisible = false;
  bool xFilled = false, yFilled = false;

  bool get xVisible => mode != _Mode.y;
  bool get yVisible => mode != _Mode.x;

  // ---------------------------------------------------- scenario 2
  bool goVisible = true;
  bool speedosVisible = false;
  bool carsPlaying = false;
  int frame = 0;
  double highwayX = -50, cityX = -50;
  double prevHighwayX = -50, prevCityX = -50;
  double citySpeed = 0, prevCitySpeed = 0;
  double lastTick = 0;
  bool redLight = false;
  final List<_Dot> dots = [];
  bool graphButton = false;
  bool graphMode = false;
  double graphT = 0; // 0..1 over the 2 s transformation
  bool axes = false;
  bool fibVisible = false;
  bool straightFilled = false, curvedFilled = false;
  bool fibDone = false;

  int get secs => (frame * 0.1 + 1e-9).floor();

  /// Smooths the 100 ms physics steps for drawing.
  double get _tick => carsPlaying ? ((time - lastTick) / 0.1).clamp(0.0, 1.0) : 1.0;
  double get highwayDrawX => prevHighwayX + (highwayX - prevHighwayX) * _tick;
  double get cityDrawX => prevCityX + (cityX - prevCityX) * _tick;
  double get citySpeedDraw => prevCitySpeed + (citySpeed - prevCitySpeed) * _tick;

  void resetTrains() {
    playing = false;
    finished = false;
    simTime = 0;
    trainX = -60;
    trainY = -60;
    ghosts.clear();
  }

  void reset() {
    step = 1;
    mode = _Mode.x;
    resetTrains();
    dndVisible = false;
    xFilled = false;
    yFilled = false;
    goVisible = true;
    speedosVisible = false;
    carsPlaying = false;
    frame = 0;
    highwayX = cityX = prevHighwayX = prevCityX = -50;
    citySpeed = prevCitySpeed = 0;
    lastTick = 0;
    redLight = false;
    dots.clear();
    graphButton = false;
    graphMode = false;
    graphT = 0;
    axes = false;
    fibVisible = false;
    straightFilled = false;
    curvedFilled = false;
    fibDone = false;
  }
}

// ============================================================ PAINTING

/// The Three.js scene: two railway tracks with Train X / Train Y and their
/// ghost images (scenario 1), or the highway and city roads with the cars,
/// traffic light and dot trails that turn into distance-time graphs
/// (scenario 2).
class _A4Painter extends CustomPainter {
  _A4Painter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.text,
  }) : super(repaint: repaint);

  final _A4Scene scene;
  final bool isDark;
  final bool showLabels;

  /// Localised canvas strings (train / road names, units, axis titles).
  final Map<String, String> text;

  String _s(String k) => text[k] ?? k;

  @override
  void paint(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [_Colors.slate900, Color(0xFF1E293B)]
              : const [_Colors.slate100, _Colors.slate200],
        ).createShader(Rect.fromLTRB(0, 0, size.width, size.height * 0.45)),
    );
    if (scene.scenario == 0) {
      _paintTrains(canvas);
    } else {
      _paintCars(canvas);
    }
  }

  // ----------------------------------------------------------- helpers

  Path _path(_Cam cam, List<_V3> pts) => Path()..addPolygon(pts.map(cam.project).toList(), true);

  /// Flat horizontal rectangle (ground planes, roads, sleepers, markings).
  void _flat(Canvas canvas, _Cam cam, double x0, double x1, double z0, double z1, double y, Color color,
      {double opacity = 1, bool lit = true}) {
    final c = lit ? _lit(color, const _V3(0, 1, 0), opacity: opacity) : color.withValues(alpha: color.a * opacity);
    canvas.drawPath(
      _path(cam, [_V3(x0, y, z0), _V3(x1, y, z0), _V3(x1, y, z1), _V3(x0, y, z1)]),
      Paint()..color = c,
    );
  }

  void _poly(Canvas canvas, _Cam cam, List<_V3> pts, Color color, _V3 center, {double opacity = 1, bool lit = true}) {
    var n = (pts[1] - pts[0]).cross(pts[2] - pts[0]).unit;
    if (n.dot(pts[0] - center) < 0) n = n * -1;
    if (n.dot(cam.pos - pts[0]) <= 0) return; // back face
    final path = _path(cam, pts);
    canvas.drawPath(
      path,
      Paint()..color = lit ? _lit(color, n, opacity: opacity) : color.withValues(alpha: color.a * opacity),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.5).withValues(alpha: 0.35 * opacity),
    );
  }

  /// BoxGeometry centred at [c] with size [s] (bottom face never visible).
  void _box(Canvas canvas, _Cam cam, _V3 c, _V3 s, Color color, {double opacity = 1, bool lit = true}) {
    final hx = s.x / 2, hy = s.y / 2, hz = s.z / 2;
    _V3 v(double a, double b, double d) => _V3(c.x + a * hx, c.y + b * hy, c.z + d * hz);
    for (final f in [
      [v(1, -1, -1), v(1, 1, -1), v(1, 1, 1), v(1, -1, 1)],
      [v(-1, -1, -1), v(-1, -1, 1), v(-1, 1, 1), v(-1, 1, -1)],
      [v(-1, -1, -1), v(-1, 1, -1), v(1, 1, -1), v(1, -1, -1)],
      [v(-1, -1, 1), v(1, -1, 1), v(1, 1, 1), v(-1, 1, 1)],
      [v(-1, 1, -1), v(-1, 1, 1), v(1, 1, 1), v(1, 1, -1)],
    ]) {
      _poly(canvas, cam, f, color, c, opacity: opacity, lit: lit);
    }
  }

  void _shadow(Canvas canvas, _Cam cam, _V3 at, double w, double d, {double opacity = 0.3}) {
    final k = cam.scaleAt(at);
    final c = cam.project(at);
    final h = (cam.project(at + _V3(0, 0, d / 2)) - cam.project(at - _V3(0, 0, d / 2))).distance;
    labGroundShadow(canvas, c, w * k, math.max(4, h * 1.3), opacity: opacity);
  }

  void _label(Canvas canvas, _Cam cam, String t, _V3 at) {
    if (!showLabels) return;
    labPill(canvas, t, cam.project(at), size: 17, border: const Color(0x6694A3B8));
  }

  // ------------------------------------------------------- scenario 1

  void _paintTrains(Canvas canvas) {
    final cam = _cam1;
    final sc = scene;
    // Grass plane (200 x 50) and the distance markers behind the tracks.
    _flat(canvas, cam, -100, 100, -25, 25, 0, const Color(0xFF65A30D));
    for (var d = 0; d <= 120; d += 20) {
      final x = (-60 + d) * _xs1;
      _box(canvas, cam, _V3(x, 1, -5), const _V3(0.1, 2, 0.5), Colors.white, lit: false);
    }
    // Distance readout for the markers: a ruler in front of the near track
    // (clear of the train labels, which stop right above the markers).
    if (showLabels) {
      final tick = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 2;
      canvas.drawLine(cam.project(const _V3(-21.6, 0.02, 4.6)), cam.project(const _V3(21.6, 0.02, 4.6)),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..strokeWidth = 1.5);
      for (var d = 0; d <= 120; d += 20) {
        final x = (-60 + d) * _xs1;
        canvas.drawLine(cam.project(_V3(x, 0.02, 4.3)), cam.project(_V3(x, 0.02, 4.9)), tick);
        labText(
          canvas,
          '$d ${_s('km')}',
          cam.project(_V3(x, 0.02, 5.1)),
          size: 14,
          weight: FontWeight.w800,
          color: Colors.white,
          anchor: Alignment.topCenter,
          background: const Color(0xCC0F172A),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        );
      }
    }
    // Far track: Train X; near track: Train Y.
    for (final isX in const [true, false]) {
      final z = isX ? -3.0 : 3.0;
      final color = isX ? _trainBlue : _trainRed;
      _track(canvas, cam, z);
      for (final g in sc.ghosts.where((g) => g.isX == isX)) {
        _train(canvas, cam, g.x * _xs1, z, color, 0.38);
      }
      if (isX ? sc.xVisible : sc.yVisible) {
        _train(canvas, cam, (isX ? sc.trainX : sc.trainY) * _xs1, z, color, 1);
      }
    }
    if (sc.xVisible) _label(canvas, cam, _s('train_x'), _V3(sc.trainX * _xs1, 3.1, -3));
    if (sc.yVisible) _label(canvas, cam, _s('train_y'), _V3(sc.trainY * _xs1, 3.1, 3));
  }

  void _track(Canvas canvas, _Cam cam, double z) {
    const sleeper = Color(0xFF451A03);
    for (var x = -75.0; x <= 75.0; x += 1.5) {
      final p = cam.project(_V3(x, 0, z));
      if (p.dx < -300 || p.dx > 1300) continue;
      _flat(canvas, cam, x - 0.1, x + 0.1, z - 0.6, z + 0.6, 0.05, sleeper);
    }
    for (final dz in const [-0.4, 0.4]) {
      _box(canvas, cam, _V3(0, 0.1, z + dz), const _V3(150, 0.1, 0.1), const Color(0xFF94A3B8));
    }
  }

  /// HTML `createTrain()`: 6 x 1.5 x 1.2 body with dark windows (height and
  /// depth exaggerated a little so the trains read well on phones).
  void _train(Canvas canvas, _Cam cam, double x, double z, Color color, double opacity) {
    const k = 1.25, len = 4.6 / 6; // length scaled to the compressed track
    if (opacity >= 1) _shadow(canvas, cam, _V3(x + 0.3, 0, z + 0.3), 5.0, 1.6 * k, opacity: 0.32);
    _box(canvas, cam, _V3(x, 0.75 * k, z), const _V3(6 * len, 1.5 * k, 1.2 * k), color, opacity: opacity);
    if (opacity < 1) {
      // Ghost outline so the translucent copies read on the grass.
      final hx = 3 * len, hy = 1.5 * k, hz = 0.6 * k;
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = labShade(color, 0.35).withValues(alpha: 0.85);
      canvas.drawPath(
        _path(cam, [_V3(x - hx, 0, z + hz), _V3(x + hx, 0, z + hz), _V3(x + hx, hy, z + hz), _V3(x - hx, hy, z + hz)]),
        outline,
      );
      canvas.drawPath(
        _path(cam, [_V3(x - hx, hy, z + hz), _V3(x - hx, hy, z - hz), _V3(x + hx, hy, z - hz), _V3(x + hx, hy, z + hz)]),
        outline,
      );
    }
    const win = Color(0xFF1E293B);
    final fz = z + 0.6 * k + 0.01;
    for (var j = -2.0; j <= 2.0 + 1e-9; j += 1.2) {
      final i = j * len;
      final path = _path(cam, [
        _V3(x + i - 0.4, 1.0 * k - 0.25 * k, fz),
        _V3(x + i + 0.4, 1.0 * k - 0.25 * k, fz),
        _V3(x + i + 0.4, 1.0 * k + 0.25 * k, fz),
        _V3(x + i - 0.4, 1.0 * k + 0.25 * k, fz),
      ]);
      canvas.drawPath(path, Paint()..color = win.withValues(alpha: opacity));
      // Glass glint.
      canvas.drawPath(
        _path(cam, [
          _V3(x + i - 0.35, 1.0 * k + 0.05 * k, fz + 0.001),
          _V3(x + i - 0.1, 1.0 * k + 0.2 * k, fz + 0.001),
          _V3(x + i - 0.25, 1.0 * k + 0.2 * k, fz + 0.001),
        ]),
        Paint()..color = Colors.white.withValues(alpha: 0.18 * opacity),
      );
    }
  }

  // ------------------------------------------------------- scenario 2

  void _paintCars(Canvas canvas) {
    final sc = scene;
    final g = sc.graphT;
    // HTML transformToGraph: camera 1.5 s Cubic.InOut, scene sinks 10 units
    // in 1 s (linear), dots fly to the graph in 2 s (Cubic.Out).
    final camT = Curves.easeInOutCubic.transform((g * 2000 / 1500).clamp(0.0, 1.0));
    final sinkT = (g * 2).clamp(0.0, 1.0);
    final cam = _cam2(camT);
    final y0 = -10 * sinkT;
    // The sinking scene also fades so the graph reads clearly.
    final fade = 1 - 0.85 * sinkT;

    // Ground, roads (highway z = -5, city z = 5), lane dashes, crosswalk.
    _flat(canvas, cam, -100, 100, -25, 25, y0, const Color(0xFF22C55E), opacity: 1 - 0.9 * sinkT);
    const road = Color(0xFF334155);
    _flat(canvas, cam, -75, 75, -8, -2, y0 + 0.01, road, opacity: fade);
    _flat(canvas, cam, -75, 75, 2, 8, y0 + 0.01, road, opacity: fade);
    for (var x = -70.0; x <= 70.0; x += 4) {
      _flat(canvas, cam, x - 1, x + 1, -5.1, -4.9, y0 + 0.02, Colors.white, opacity: fade, lit: false);
    }
    for (var z = 3.0; z <= 7.0 + 1e-9; z += 0.8) {
      _flat(canvas, cam, -0.75, 0.75, z - 0.2, z + 0.2, y0 + 0.02, Colors.white, opacity: fade, lit: false);
    }

    if (!sc.graphMode) {
      for (final d in sc.dots) {
        _dot(canvas, cam, d.road, d.highway);
      }
    }

    _car(canvas, cam, sc.highwayDrawX * _xs2, y0, -5, _trainBlue, fade);
    _car(canvas, cam, sc.cityDrawX * _xs2, y0, 5, _trainRed, fade);
    _trafficLight(canvas, cam, y0, fade);

    if (sc.graphMode) _paintGraph(canvas, cam, sinkT);

    if (!sc.graphMode) {
      _label(canvas, cam, _s('lbl_highway'), _V3(sc.highwayDrawX * _xs2, 2.6, -5));
      _label(canvas, cam, _s('lbl_city'), _V3(sc.cityDrawX * _xs2, 2.6, 5));
    }
  }

  /// HTML `createCar()` (body, white cabin, four wheels), 1.5x size.
  void _car(Canvas canvas, _Cam cam, double x, double y0, double z, Color color, double opacity) {
    const k = 1.5;
    const tyre = Color(0xFF111111);
    _shadow(canvas, cam, _V3(x + 0.2, y0, z + 0.3), 2.4 * k, 1.2 * k, opacity: 0.3 * opacity);
    void wheel(double dx, double dz) {
      final c = _V3(x + dx * k, y0 + 0.2 * k, z + dz * k);
      final r = 0.2 * k * cam.scaleAt(c);
      canvas.drawOval(
        Rect.fromCenter(center: cam.project(c), width: r * 2, height: r * 1.7),
        Paint()..color = tyre.withValues(alpha: opacity),
      );
      canvas.drawCircle(cam.project(c), r * 0.4, Paint()..color = _Colors.slate500.withValues(alpha: opacity));
    }

    wheel(-0.6, -0.5);
    wheel(0.6, -0.5);
    _box(canvas, cam, _V3(x, y0 + 0.4 * k, z), const _V3(2 * k, 0.6 * k, 1 * k), color, opacity: opacity);
    _box(canvas, cam, _V3(x - 0.2 * k, y0 + 0.9 * k, z), const _V3(1.2 * k, 0.5 * k, 0.9 * k), Colors.white,
        opacity: opacity);
    // Headlight on the front face.
    final hl = cam.project(_V3(x + 1.0 * k + 0.01, y0 + 0.45 * k, z + 0.3 * k));
    labGlow(canvas, hl, 6, const Color(0xFFFEF08A), intensity: 0.8 * opacity);
    wheel(-0.6, 0.5);
    wheel(0.6, 0.5);
  }

  /// HTML traffic light at (2, *, 8): pole, box, red and green lamps.
  void _trafficLight(Canvas canvas, _Cam cam, double y0, double opacity) {
    final lx = 2 * _xs2;
    final base = cam.project(_V3(lx, y0, 8)), top = cam.project(_V3(lx, y0 + 4, 8));
    final k = cam.scaleAt(_V3(lx, y0 + 2, 8));
    labCylinder(canvas, Rect.fromLTRB(top.dx - 0.1 * k, top.dy, top.dx + 0.1 * k, base.dy), const Color(0xFF111111),
        tilt: 0.3, opacity: opacity);
    _box(canvas, cam, _V3(lx, y0 + 3.5, 8), const _V3(0.5, 1.5, 0.5), const Color(0xFF333333), opacity: opacity);
    for (final red in const [true, false]) {
      final c = _V3(lx - 0.3, y0 + (red ? 4 : 3), 8 + 0.1);
      final on = red ? scene.redLight : !scene.redLight;
      final color = red ? _trainRed : const Color(0xFF22C55E);
      final p = cam.project(c);
      final r = 0.15 * 1.6 * cam.scaleAt(c);
      if (on) labGlow(canvas, p, r * 4, color, intensity: opacity);
      labSphere(canvas, p, r, on ? color : labShade(color, -0.65), opacity: opacity, highlight: on ? 0.6 : 0.2);
    }
  }

  void _dot(Canvas canvas, _Cam cam, _V3 at, bool highway) {
    final r = math.max(4.0, 0.3 * 1.4 * cam.scaleAt(at));
    labSphere(canvas, cam.project(at), r, highway ? _trainBlue : _trainRed, highlight: 0.5, outline: true);
  }

  /// Dots flying to (time, distance) positions, then the axes (HTML
  /// LineSegments) with a light graph card behind them.
  void _paintGraph(Canvas canvas, _Cam cam, double sinkT) {
    final sc = scene;
    final card = isDark ? const Color(0xFF0F172A) : Colors.white;
    _flat(canvas, cam, -52, 52, -31, 31, 0.3, card, opacity: 0.94 * sinkT, lit: false);
    final edge = _path(cam, const [_V3(-52, 0.3, -31), _V3(52, 0.3, -31), _V3(52, 0.3, 31), _V3(-52, 0.3, 31)]);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = (isDark ? _Colors.slate600 : _Colors.slate300).withValues(alpha: sinkT),
    );
    final grid = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : _Colors.slate900).withValues(alpha: 0.08 * sinkT);
    for (var x = -45.0; x <= 45.0 + 1e-9; x += 10) {
      canvas.drawLine(cam.project(_V3(x, 0.35, -25)), cam.project(_V3(x, 0.35, 25)), grid);
    }
    for (var z = -25.0; z <= 25.0 + 1e-9; z += 10) {
      canvas.drawLine(cam.project(_V3(-45, 0.35, z)), cam.project(_V3(45, 0.35, z)), grid);
    }

    final e = Curves.easeOutCubic.transform(sc.graphT);
    if (sc.axes) {
      final ink = isDark ? _Colors.slate200 : Colors.black;
      final o = cam.project(const _V3(-45, 0.4, 25));
      labArrow(canvas, o, cam.project(const _V3(47, 0.4, 25)), color: ink, width: 2.5, head: 12);
      labArrow(canvas, o, cam.project(const _V3(-45, 0.4, -27)), color: ink, width: 2.5, head: 12);
      // Faint guide line through each trail: straight vs curved.
      for (final hw in const [true, false]) {
        final pts = [for (final d in sc.dots.where((d) => d.highway == hw)) cam.project(d.graph)];
        if (pts.length > 1) {
          canvas.drawPath(
            Path()..addPolygon(pts, false),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = (hw ? _trainBlue : _trainRed).withValues(alpha: 0.45),
          );
        }
      }
      if (showLabels) {
        labText(canvas, _s('axis_time'), cam.project(const _V3(46, 0.4, 25)) + const Offset(0, 12),
            size: 14, weight: FontWeight.w800, color: ink, anchor: Alignment.topRight);
        labText(canvas, _s('axis_dist'), cam.project(const _V3(-45, 0.4, -26)) + const Offset(10, 0),
            size: 14, weight: FontWeight.w800, color: ink, anchor: Alignment.topLeft);
        labText(canvas, '0', o + const Offset(-6, 6), size: 13, weight: FontWeight.w700, color: ink,
            anchor: Alignment.topRight);
      }
    }
    for (final d in sc.dots) {
      _dot(canvas, cam, _V3.lerp(d.road, d.graph, e), d.highway);
    }
    if (sc.axes && showLabels) {
      for (final hw in const [true, false]) {
        final last = sc.dots.lastWhere((d) => d.highway == hw, orElse: () => const _Dot(highway: true, time: -1, initX: 0));
        if (last.time < 0) continue;
        labPill(
          canvas,
          _s(hw ? 'highway_car' : 'city_car'),
          cam.project(last.graph) + const Offset(0, -26),
          size: 14,
          background: hw ? const Color(0xE61D4ED8) : const Color(0xE6B91C1C),
          border: null,
          anchor: Alignment.bottomRight,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _A4Painter old) =>
      old.isDark != isDark || old.showLabels != showLabels || !mapEquals(old.text, text);
}

// ======================================================================== UI

/// HTML `font-digital` (monospace). Uses the lab font override when one is
/// set (headless screenshot tests have no "monospace" family).
String get _monoFamily => LabFont.active.family ?? 'monospace';

TextStyle _mono(Color color, double size, {double spacing = 1.5}) => TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
      fontFamily: _monoFamily,
      fontFamilyFallback: LabFont.active.fallback,
      letterSpacing: spacing,
    );

/// Dashed rounded border (HTML `.drop-zone`).
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    labDashedPath(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius((Offset.zero & size).deflate(1), Radius.circular(radius))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
      dash: 6,
      gap: 4,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color || old.radius != radius;
}

/// HTML speedometer dial: upper-half scale arc, red needle, hub, "km/h".
class _DialPainter extends CustomPainter {
  _DialPainter({required this.speed, required this.accent, required this.isDark, required this.unit});

  final double speed;
  final Color accent;
  final bool isDark;
  final String unit;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = isDark ? _Colors.slate700 : _Colors.slate100);
    canvas.drawCircle(
      c,
      r - r * 0.06,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..color = accent,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.74),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = isDark ? _Colors.slate500 : _Colors.slate300,
    );
    // Map 0-100 km/h to -90..+90 degrees.
    final a = (-90 + (speed / 100) * 180) * math.pi / 180;
    canvas.drawLine(
      c,
      c + Offset(math.sin(a), -math.cos(a)) * (r * 0.66),
      Paint()
        ..color = _Colors.red
        ..strokeWidth = math.max(2, r * 0.08)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, r * 0.13, Paint()..color = isDark ? Colors.white : _Colors.slate900);
    labText(
      canvas,
      unit,
      Offset(c.dx, c.dy + r * 0.82),
      size: r * 0.26,
      weight: FontWeight.w800,
      color: isDark ? _Colors.slate200 : _Colors.slate800,
      anchor: Alignment.bottomCenter,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.speed != speed || old.accent != accent || old.isDark != isDark || old.unit != unit;
}

extension _A4Ui on _Ch8A4AnalyzingUniformAndNonUniformLinearMotionPageState {
  /// Canvas overlays: scenario 1 control panel, data table and labelling
  /// panel; scenario 2 GO! button, speedometers, Show Graph button and the
  /// fill-in-the-blank panel.
  Widget _uiLayer(BuildContext context, Size canvas, LabPalette p, double s) {
    final sc = _scene;
    final inset = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final left = open ? 8.0 : inset.left;
    final right = inset.right;
    final top = inset.top;
    // Room for the HUD while the sidebar is open.
    final bottom = inset.bottom + (open ? 64 * s : 0);
    final availW = math.max(0.0, canvas.width - left - right);

    if (sc.scenario == 0) {
      final cw = 196 * s, tw = 186 * s, gap = 10 * s;
      final f = math.min(1.0, availW / (cw + tw + gap));
      return Stack(
        children: [
          Positioned(left: left, top: top, child: _drag('s1c', canvas, _fit(cw, f, _controlsPanel(p, s, canvas)))),
          Positioned(right: right, top: top, child: _drag('s1t', canvas, _fit(tw, f, _tablePanel(p, s, canvas)))),
          // Placed at the top so the trails stay visible below it.
          if (sc.dndVisible)
            Positioned(
              left: left,
              right: right,
              top: top,
              child: Center(
                child: _drag('s1d', canvas, _fit(440 * s, math.min(1.0, availW / (440 * s)), _labelPanel(p, s, canvas))),
              ),
            ),
        ],
      );
    }

    final sw = 372 * s;
    return Stack(
      children: [
        // The speedometers belong to the cars, so they fade out with them
        // when the dots turn into graphs.
        if (sc.speedosVisible && !sc.axes)
          Positioned(
            left: left,
            top: top,
            child: IgnorePointer(
              ignoring: sc.graphMode,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: sc.graphMode ? 0 : 1,
                child: _drag('s2s', canvas, _fit(sw, math.min(1.0, availW / sw), _speedoPanel(p, s, canvas))),
              ),
            ),
          ),
        if (sc.goVisible)
          Positioned(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            child: Center(child: _goButton(s)),
          ),
        if (sc.graphButton)
          Positioned(
            right: right + 8 * s,
            bottom: bottom + 10 * s,
            child: LabActionButton(action: _actions().last, scale: s, expand: false),
          ),
        // At the top, above the graph.
        if (sc.fibVisible)
          Positioned(
            left: left,
            right: right,
            top: top,
            child: Center(
              child: _drag('s2f', canvas, _fit(520 * s, math.min(1.0, availW / (520 * s)), _fibPanel(p, s, canvas))),
            ),
          ),
      ],
    );
  }

  /// Shrinks a fixed-width panel to `width * f` without reflowing it.
  Widget _fit(double width, double f, Widget child) {
    return SizedBox(
      width: width * f,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    );
  }

  /// HTML `makePanelDraggable`: the panel follows its "DRAG" grip.
  Widget _drag(String id, Size canvas, Widget child) {
    return Transform.translate(
      offset: _panelOffsets[id] ?? Offset.zero,
      child: child,
    );
  }

  Widget _grip(String id, Size canvas, LabPalette p, double s) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => _movePanel(id, d.delta, canvas),
      child: Container(
        margin: EdgeInsets.only(bottom: 5 * s),
        padding: EdgeInsets.symmetric(vertical: 1 * s),
        decoration: BoxDecoration(
          color: (p.isDark ? _Colors.slate700 : _Colors.slate200).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(5 * s),
          border: Border(bottom: BorderSide(color: p.isDark ? _Colors.slate600 : _Colors.slate300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drag_indicator, size: 12 * s, color: p.textMuted),
            SizedBox(width: 3 * s),
            Text(
              _t('drag'),
              style: TextStyle(color: p.textMuted, fontSize: 9 * s, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  /// Panel title that doubles as the drag grip (HTML "DRAG" handle).
  Widget _header(String id, Size canvas, LabPalette p, double s, String title, {double size = 12}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => _movePanel(id, d.delta, canvas),
      child: Container(
        margin: EdgeInsets.only(bottom: 6 * s),
        padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 3 * s),
        decoration: BoxDecoration(
          color: (p.isDark ? _Colors.slate700 : _Colors.slate200).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6 * s),
          border: Border(bottom: BorderSide(color: p.isDark ? _Colors.slate600 : _Colors.slate300)),
        ),
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 14 * s, color: p.textMuted),
            SizedBox(width: 4 * s),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(color: p.textStrong, fontSize: size * s, fontWeight: FontWeight.w800, height: 1.2),
                ),
              ),
            ),
            SizedBox(width: 10 * s),
          ],
        ),
      ),
    );
  }

  BoxDecoration _panelBox(LabPalette p, double s, {Color? border, double width = 1, Color? color}) {
    return BoxDecoration(
      color: color ?? (p.isDark ? _Colors.slate800.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.94)),
      borderRadius: BorderRadius.circular(12 * s),
      border: Border.all(color: border ?? (p.isDark ? _Colors.slate600 : _Colors.slate300), width: width),
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 6))],
    );
  }
}

/// Shared drag-and-drop pieces (HTML `.draggable` / `.drop-zone`).
extension _A4UiDnd on _Ch8A4AnalyzingUniformAndNonUniformLinearMotionPageState {
  Widget _wordChip(String text, LabPalette p, double s, {double size = 12}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: p.isDark ? const Color(0x99312E81) : const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(7 * s),
        border: Border.all(color: const Color(0xFFA5B4FC)),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: p.isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3),
          fontSize: size * s,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  /// A label that follows the finger and is checked on release.
  Widget _draggableWord(_Kind kind, String text, LabPalette p, double s, {double size = 12}) {
    final chip = _wordChip(text, p, s, size: size);
    return Draggable<_Kind>(
      data: kind,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          // HTML `.draggable:active { opacity: 0.8; transform: scale(0.95) }`.
          child: Opacity(opacity: 0.85, child: Transform.scale(scale: 0.95, child: chip)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: chip),
      onDragStarted: () => _Audio.play(_Sound.pickup),
      onDragEnd: (d) => _onWordDropped(kind, d.offset),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: chip),
    );
  }

  /// Empty zone: dashed border + "Drop Here"; filled: green with the label.
  Widget _dropZone(GlobalKey key, bool filled, String filledText, LabPalette p, double s,
      {required double height, double minWidth = 0, bool showHint = true, Color? fill}) {
    return CustomPaint(
      key: key,
      foregroundPainter:
          filled ? null : _DashedBorderPainter(color: _Colors.slate400.withValues(alpha: 0.6), radius: 6 * s),
      child: Container(
        height: height,
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.symmetric(horizontal: 4 * s),
        decoration: BoxDecoration(
          color: filled ? _Colors.green.withValues(alpha: 0.1) : fill,
          borderRadius: BorderRadius.circular(6 * s),
          border: filled ? Border.all(color: _Colors.green, width: 2) : null,
        ),
        child: Center(
          widthFactor: 1,
          child: filled
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) => Transform.scale(scale: v, child: child),
                  child: FittedBox(fit: BoxFit.scaleDown, child: _wordChip(filledText, p, s, size: 11)),
                )
              : (showHint
                  ? Text(
                      _t('drop_here'),
                      style: TextStyle(color: _Colors.slate400, fontSize: 11 * s, fontWeight: FontWeight.w600),
                    )
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// Scenario 1 panels.
extension _A4UiS1 on _Ch8A4AnalyzingUniformAndNonUniformLinearMotionPageState {
  /// HTML `#s1-controls`: train selection, Start / Reset and the clock.
  Widget _controlsPanel(LabPalette p, double s, Size canvas) {
    final sc = _scene;
    Widget chip(_Mode m, String label, Color text, Color textDark, Color bg, Color bgDark, Color edge) {
      final selected = sc.mode == m;
      return Opacity(
        opacity: sc.playing ? 0.55 : 1,
        child: GestureDetector(
          onTap: () => _selectMode(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(selected ? 2 * s : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7 * s),
              border: selected ? Border.all(color: _Colors.primary, width: 2) : null,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5 * s, horizontal: 2 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.isDark ? bgDark : bg,
                borderRadius: BorderRadius.circular(5 * s),
                border: Border.all(color: selected ? edge : Colors.transparent, width: 2),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(color: p.isDark ? textDark : text, fontSize: 11.5 * s, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(9 * s),
      decoration: _panelBox(p, s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header('s1c', canvas, p, s, _t('sim_controls')),
          Row(
            children: [
              Expanded(
                child: chip(_Mode.x, _t('train_x'), const Color(0xFF1D4ED8), const Color(0xFF93C5FD),
                    const Color(0xFFDBEAFE), const Color(0x801E3A8A), _trainBlue),
              ),
              SizedBox(width: 4 * s),
              Expanded(
                child: chip(_Mode.y, _t('train_y'), const Color(0xFFB91C1C), const Color(0xFFFCA5A5),
                    const Color(0xFFFEE2E2), const Color(0x807F1D1D), _trainRed),
              ),
              SizedBox(width: 4 * s),
              Expanded(
                child: chip(_Mode.both, _t('btn_both'), const Color(0xFF7E22CE), const Color(0xFFD8B4FE),
                    const Color(0xFFF3E8FF), const Color(0x80581C87), _purple),
              ),
            ],
          ),
          SizedBox(height: 7 * s),
          LabActionButton(action: _actions().first, scale: s * 0.92, dense: true),
          SizedBox(height: 7 * s),
          Container(
            padding: EdgeInsets.symmetric(vertical: 3 * s),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _Colors.slate900, borderRadius: BorderRadius.circular(6 * s)),
            // Tracking splits Devanagari, so only English is spaced out.
            child: Text(
              _clock(sc.simTime),
              style: _mono(const Color(0xFF4ADE80), 15 * s, spacing: _lab.lang == LabLang.en ? 1.5 : 0),
            ),
          ),
        ],
      ),
    );
  }

  String _clock(int i) => labFormat(_t('time_am'), {'t': _times[i]});

  /// HTML `#s1-table-panel` / `renderS1Table()`.
  Widget _tablePanel(LabPalette p, double s, Size canvas) {
    final sc = _scene;
    final txt = p.isDark ? _Colors.slate200 : _Colors.slate800;
    final blue = p.isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final red = p.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    final border = _Colors.slate400.withValues(alpha: 0.3);
    Widget cell(String v, Color c, {bool bold = false, double opacity = 1}) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 3 * s, vertical: 1 * s),
          child: Opacity(
            opacity: opacity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                v,
                textAlign: TextAlign.center,
                style: TextStyle(color: c, fontSize: 10 * s, fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
              ),
            ),
          ),
        );
    return Container(
      padding: EdgeInsets.all(9 * s),
      decoration: _panelBox(p, s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header('s1t', canvas, p, s, _t('data_table_title'), size: 10.5),
          Table(
            border: TableBorder.all(color: border),
            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: _Colors.slate400.withValues(alpha: 0.1)),
                children: [
                  cell(_t('time'), p.textStrong, bold: true),
                  cell(_t('train_x'), blue, bold: true),
                  cell(_t('train_y'), red, bold: true),
                ],
              ),
              for (var i = 0; i <= 6; i++)
                () {
                  final show = i <= sc.simTime;
                  final hi = show && i == sc.simTime && i > 0;
                  return TableRow(
                    decoration: BoxDecoration(color: hi ? _Colors.zslYellow.withValues(alpha: 0.3) : null),
                    children: [
                      cell(_clock(i), hi ? p.textStrong : txt, bold: hi),
                      cell(show ? '${_dataX[i].round()}' : '-', blue, bold: hi, opacity: sc.mode == _Mode.y ? 0.3 : 1),
                      cell(show ? '${_dataY[i].round()}' : '-', red, bold: hi, opacity: sc.mode == _Mode.x ? 0.3 : 1),
                    ],
                  );
                }(),
            ],
          ),
        ],
      ),
    );
  }

  /// HTML `#s1-dnd-overlay`: label the two trails.
  Widget _labelPanel(LabPalette p, double s, Size canvas) {
    final sc = _scene;
    Widget trail(String title, Color c, GlobalKey key, bool filled, String text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: c, fontSize: 11.5 * s, fontWeight: FontWeight.w800)),
          SizedBox(height: 3 * s),
          _dropZone(key, filled, text, p, s, height: 42 * s),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: _panelBox(p, s, border: _Colors.zslYellow, width: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header('s1d', canvas, p, s, _t('s1_dnd_title'), size: 13),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 30 * s),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10 * s,
              runSpacing: 6 * s,
              children: [
                if (!sc.xFilled) _draggableWord(_Kind.uniform, _t('lbl_uniform'), p, s),
                if (!sc.yFilled) _draggableWord(_Kind.nonuniform, _t('lbl_nonuniform'), p, s),
              ],
            ),
          ),
          SizedBox(height: 8 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: trail(_t('train_x_trail'), _trainBlue, _dzTrainX, sc.xFilled, _t('lbl_uniform'))),
              SizedBox(width: 12 * s),
              Expanded(child: trail(_t('train_y_trail'), _trainRed, _dzTrainY, sc.yFilled, _t('lbl_nonuniform'))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Scenario 2 panels.
extension _A4UiS2 on _Ch8A4AnalyzingUniformAndNonUniformLinearMotionPageState {
  /// HTML `#btn-s2-go`: big green "GO!" button in the middle of the canvas.
  Widget _goButton(double s) {
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, t, child) => Transform.scale(scale: 1 + 0.04 * math.sin(t * 3), child: child),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            _Audio.play(_Sound.click);
            _go();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 44 * s, vertical: 16 * s),
            decoration: BoxDecoration(
              color: _Colors.green,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 4 * s),
              boxShadow: [BoxShadow(color: _Colors.green.withValues(alpha: 0.6), blurRadius: 30)],
            ),
            child: Text(
              _t('btn_go'),
              style: TextStyle(color: Colors.white, fontSize: 34 * s, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#s2-speedometers`: highway / city dials and the 30 s timer.
  Widget _speedoPanel(LabPalette p, double s, Size canvas) {
    Widget card(bool highway) {
      final accent = highway ? _trainBlue : _trainRed;
      final valueColor = highway
          ? (p.isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
          : (p.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));
      return ValueListenableBuilder<double>(
        valueListenable: _frame,
        builder: (context, _, _) {
          final sc = _scene;
          final speed = highway ? (sc.frame > 0 ? 80.0 : 0.0) : sc.citySpeed;
          final needle = highway ? speed : sc.citySpeedDraw;
          return Container(
            padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 6 * s),
            decoration: BoxDecoration(
              color: p.isDark ? _Colors.slate800.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10 * s),
              border: Border(left: BorderSide(color: accent, width: 4 * s)),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48 * s,
                  height: 48 * s,
                  child: CustomPaint(
                    painter: _DialPainter(speed: needle, accent: accent, isDark: p.isDark, unit: _t('u_kmph')),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(highway ? 'highway_car' : 'city_car').toUpperCase(),
                        style: TextStyle(
                          color: _Colors.slate500,
                          fontSize: 9.5 * s,
                          fontWeight: FontWeight.w800,
                          letterSpacing: _lab.lang == LabLang.en ? 1 : 0,
                        ),
                      ),
                      Text('${speed.round()}', style: _mono(valueColor, 21 * s)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(7 * s),
      decoration: _panelBox(p, s, color: (p.isDark ? _Colors.slate900 : _Colors.slate100).withValues(alpha: 0.55)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _grip('s2s', canvas, p, s),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: card(true)),
                SizedBox(width: 6 * s),
                Expanded(child: card(false)),
                SizedBox(width: 6 * s),
                Container(
                  width: 74 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _Colors.slate900,
                    borderRadius: BorderRadius.circular(8 * s),
                    border: Border.all(color: _Colors.slate700),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '00:${_scene.secs.toString().padLeft(2, '0')}',
                      style: _mono(Colors.white, 17 * s),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#s2-fib-overlay`: drag "Uniform" / "Non-uniform" into the
  /// sentence about the two graphs.
  Widget _fibPanel(LabPalette p, double s, Size canvas) {
    final sc = _scene;
    final style = TextStyle(color: p.text, fontSize: 13.5 * s, fontWeight: FontWeight.w600, height: 1.3);
    List<Widget> words(String key) => [for (final w in _t(key).split(' ')) Text(w, style: style)];
    Widget blank(GlobalKey key, bool filled, String text) => _dropZone(
          key,
          filled,
          text,
          p,
          s,
          height: 32 * s,
          minWidth: 104 * s,
          showHint: false,
          fill: p.isDark ? _Colors.slate700 : _Colors.slate200,
        );
    final done = sc.fibDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(12 * s),
      decoration: _panelBox(
        p,
        s,
        border: done ? _Colors.green : _Colors.zslYellow,
        width: 2,
        color: done ? (p.isDark ? const Color(0xF2052E16) : const Color(0xFFF0FDF4)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _grip('s2f', canvas, p, s),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 30 * s),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12 * s,
              runSpacing: 6 * s,
              children: [
                if (!sc.straightFilled) _draggableWord(_Kind.uniform, _t('word_uniform'), p, s, size: 13),
                if (!sc.curvedFilled) _draggableWord(_Kind.nonuniform, _t('word_nonuniform'), p, s, size: 13),
              ],
            ),
          ),
          SizedBox(height: 8 * s),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5 * s,
            runSpacing: 6 * s,
            children: [
              ...words('fib_part1'),
              blank(_dzStraight, sc.straightFilled, _t('word_uniform')),
              ...words('fib_part2'),
              blank(_dzCurved, sc.curvedFilled, _t('word_nonuniform')),
              ...words('fib_part3'),
            ],
          ),
        ],
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
