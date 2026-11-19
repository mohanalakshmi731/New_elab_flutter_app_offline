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

/// Class 7 Science • Chapter 7 • Activity 5
/// The Water Cycle.
///
/// Native Flutter port of `Cl7S-Ch7-A5-The_Water_Cycle.html`.
/// Scenario 1 builds the water cycle on an ocean / land / mountain diorama
/// (drop the Sun, tap the trees, the vapour and the cloud, observe runoff).
/// Scenario 2 compares percolation through gravel, sand and clay, then
/// shows infiltration into an aquifer that a handpump draws from.
class Ch7A5TheWaterCyclePage extends StatefulWidget {
  const Ch7A5TheWaterCyclePage({super.key});

  @override
  State<Ch7A5TheWaterCyclePage> createState() => _Ch7A5TheWaterCyclePageState();
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

class _Ch7A5TheWaterCyclePageState extends State<Ch7A5TheWaterCyclePage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _WcScene _scene = _WcScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();

  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// A toolbox item is being dragged (shows the "DROP HERE" zone).
  bool _dragging = false;

  /// The current scenario has reached its conclusion.
  bool _scenarioDone = false;

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

    _scene.build(0);
    _ticker = createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
      _last = elapsed;
      _scene.time = elapsed.inMicroseconds / 1e6;
      _scene.update(dt);
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

  // ------------------------------------------------------------ logic

  /// HTML `resetApp(true)` / `buildScenario()`.
  void _rebuild(int scenario) {
    _lab.cancelPending();
    _scene.build(scenario);
    _dragging = false;
    _scenarioDone = false;
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _rebuild(index);
    });
    _lab.resetView(sound: false);
  }

  void _fullReset() => setState(() => _rebuild(0));

  void _advanceStep() {
    if (!mounted) return;
    final n = _data.steps.length;
    if (_step < n) {
      setState(() => _scene.step++);
    } else {
      _showConclusion();
    }
  }

  /// HTML `handleToolDeploy()` (drop or click on a toolbox item).
  void _deployTool(String id) {
    if (_scenario == 0 && id == 'sun' && _step == 1 && !_scene.toolUsed) {
      _dropSun();
    } else if (_scenario == 1 && id == 'wcan' && _step == 1 && !_scene.toolUsed) {
      _dropCan();
    } else {
      _lab.showToast(_t('msg_wrong_item'), isError: true);
    }
  }

  /// HTML `executeDrop('sun')`: the Sun flies over the ocean and water
  /// vapour starts to rise.
  void _dropSun() {
    _Audio.play(_Sound.drop);
    setState(() {
      _scene
        ..toolUsed = true
        ..sunVisible = true
        ..sunT0 = _scene.time
        ..evaporating = true;
      for (var i = 0; i < 30; i++) {
        // Staggered below the surface so the vapour rises in a steady stream.
        _scene.vapor.add(_Vap(-15 + _rnd.nextDouble() * 10, -_rnd.nextDouble() * 10, -5 + _rnd.nextDouble() * 10));
      }
    });
    _advanceStep();
  }

  /// HTML `executeDrop('wateringcan')`: water percolates through the three
  /// columns (gravel 1.5 s, sand 3 s, clay 6 s), then the cross-section.
  void _dropCan() {
    _Audio.play(_Sound.drop);
    setState(() {
      _scene
        ..toolUsed = true
        ..canVisible = true
        ..canT0 = _scene.time
        ..colWater = true
        ..pourT0 = _scene.time;
    });
    _lab.after(const Duration(milliseconds: 900), () => _Audio.play(_Sound.splash));
    _lab.after(const Duration(milliseconds: 6500), () {
      if (!mounted) return;
      setState(() {
        _scene
          ..canVisible = false
          ..columnsVisible = false
          ..crossVisible = true;
      });
      _Audio.play(_Sound.pop);
      _advanceStep();
    });
  }

  /// HTML raycaster `pointerdown` handler on the 3D scene.
  void _onStageTap(Offset pos) {
    if (!_lab.isLabActive) return;
    final s = _scene;
    if (_scenario == 0) {
      if (_step == 2 && s.hitTrees(pos)) {
        _Audio.play(_Sound.click);
        setState(() => s.transpiring = true);
        _advanceStep();
      } else if (_step == 3 && s.hitVapor(pos)) {
        _Audio.play(_Sound.whoosh);
        _condense();
        _advanceStep();
      } else if (_step == 4 && s.hitCloud1(pos)) {
        _Audio.play(_Sound.click);
        _cloudClick();
      }
    } else {
      if (_step == 2 && s.hitCloud2(pos)) {
        _s2Rain();
      } else if (_step == 4 && s.hitPump(pos)) {
        _pumpClick();
      }
    }
  }

  /// HTML `handleCondensation()`: every vapour particle flies to the cloud
  /// spot; when the last one arrives the cloud pops in (Elastic.Out).
  void _condense() {
    final s = _scene;
    setState(() {
      s
        ..evaporating = false
        ..transpiring = false
        ..condensing = true
        ..cloudPending = true;
      for (final p in s.vapor) {
        p
          ..cx0 = p.x
          ..cy0 = p.y
          ..cz0 = p.z
          ..cdur = 1 + _rnd.nextDouble() * 0.5
          ..ct0 = s.time;
      }
    });
  }

  /// HTML `handleCloudClick()`: the cloud grows and darkens; on the third
  /// click it rains (and snows over the mountains).
  void _cloudClick() {
    final s = _scene;
    setState(() {
      s.cloudClicks++;
      s.cloudScale = _Tw(s.cloudScale.at(s.time), 1 + s.cloudClicks * 0.2, s.time, 0.3);
      if (s.cloudClicks >= 3) {
        s.raining = true;
        for (var i = 0; i < 100; i++) {
          s.rain.add(_P3(-15 + _rnd.nextDouble() * 30, _rnd.nextDouble() * 10, -10 + _rnd.nextDouble() * 20));
        }
      }
    });
    if (s.cloudClicks >= 3) {
      _Audio.play(_Sound.splash);
      _advanceStep();
    }
  }

  /// HTML `triggerSimulation()` for "Observe Runoff".
  void _observeRunoff() {
    if (_scenario != 0 || _step != 5 || _scene.runoff) return;
    setState(() {
      _scene
        ..runoff = true
        ..runoffT0 = _scene.time;
    });
    _Audio.play(_Sound.splash);
    _lab.after(const Duration(milliseconds: 2000), _showConclusion);
  }

  /// HTML `handleS2Rain()`: rain seeps down, the aquifer forms on the
  /// bedrock, then the handpump bounces in.
  void _s2Rain() {
    if (_step != 2 || _scene.seeping) return;
    _Audio.play(_Sound.splash);
    setState(() {
      for (var i = 0; i < 80; i++) {
        // Staggered behind the cloud so the rain falls in a steady shower.
        _scene.rain2.add(_P3(-8 + _rnd.nextDouble() * 6, 9.4 + _rnd.nextDouble() * 3, (_rnd.nextDouble() - 0.5) * 3));
      }
      _scene.seeping = true;
    });
    _advanceStep();
    _lab.after(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _scene
          ..aquiferVisible = true
          ..aquiferT0 = _scene.time;
      });
      _lab.after(const Duration(milliseconds: 4000), () {
        if (!mounted) return;
        setState(() {
          _scene
            ..seeping = false
            ..aquiferLabel = true
            ..pumpVisible = true
            ..pumpT0 = _scene.time;
          _scene.rain2.clear();
        });
        _Audio.play(_Sound.pop);
        if (_step == 3) _advanceStep();
      });
    });
  }

  /// HTML `handlePumpClick()`: the handle pumps and water rises up the pipe.
  void _pumpClick() {
    if (_step != 4 || _scene.pumping) return;
    _Audio.play(_Sound.click);
    setState(() {
      _scene
        ..pumping = true
        ..handleT0 = _scene.time;
    });
    for (var i = 0; i < 30; i++) {
      _lab.after(Duration(milliseconds: i * 150), () {
        if (mounted) _scene.pumpWater.add(_PumpDrop());
      });
    }
    _lab.after(const Duration(milliseconds: 1300), () => _Audio.play(_Sound.splash));
    _lab.after(const Duration(milliseconds: 6000), _showConclusion);
  }

  /// HTML `showConclusion()`. When every scenario is done the popup shows
  /// both conclusions and offers "Restart Lab".
  void _showConclusion() {
    if (!mounted || _scenarioDone) return;
    final sc = _scenario;
    final allDone = {..._lab.completedScenarios, sc}.length >= 2;
    setState(() => _scenarioDone = true);
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      title: () => _t('obs_complete'),
      heading: () => _lab.t('sci_conclusion'),
      body: () => allDone
          ? '${_t('scen_label_1')}\n${_t('conclusion_1')}\n\n${_t('scen_label_2')}\n${_t('conclusion_2')}'
          : _t('conclusion_${sc + 1}'),
      delay: Duration(milliseconds: allDone ? 1000 : 500),
    );
  }

  List<LabAction> _actions() {
    if (_scenario == 0 && _step == 5 && !_scene.runoff) {
      return [
        LabAction(
          label: _t('btn_observe'),
          icon: Icons.play_arrow_rounded,
          color: const Color(0xFF0284C7),
          foreground: Colors.white,
          highlight: true,
          onTap: _observeRunoff,
        ),
      ];
    }
    return const [];
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final allDone = _lab.completedScenarios.length >= 2;
        return LabShell(
          controller: _lab,
          icon: Icons.water_drop,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          instruction: _scenarioDone && !allDone ? _t('msg_scenario_complete') : null,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(child: _dropTarget(s)),
            if (_step == 1 && !_scene.toolUsed) _toolbox(p, s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _onStageTap(d.localPosition),
              child: CustomPaint(
                size: _design,
                painter: _WcPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#global-drop-zone`: the whole canvas accepts a toolbox drop.
  Widget _dropTarget(double s) {
    return DragTarget<String>(
      onAcceptWithDetails: (d) => _deployTool(d.data),
      builder: (context, candidates, rejected) {
        return IgnorePointer(
          child: AnimatedOpacity(
            opacity: _dragging ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: EdgeInsets.all(48 * s),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _frame,
                    builder: (context, time, child) => Opacity(
                      opacity: 0.6 + 0.4 * (0.5 + 0.5 * math.sin(time * 4)),
                      child: child,
                    ),
                    child: CustomPaint(
                      painter: const _DropZonePainter(_theme),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 14 * s),
                        child: Text(
                          _t('drop_here'),
                          style: TextStyle(
                            color: _theme,
                            fontSize: 26 * s,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#ui-toolbox` with the Sun (scenario 1) or the Watering Can
  /// (scenario 2). Drag it onto the scene or simply tap it.
  Widget _toolbox(LabPalette p, double s, EdgeInsets inset) {
    final isSun = _scenario == 0;
    final id = isSun ? 'sun' : 'wcan';
    final label = _t(isSun ? 'lbl_sun' : 'lbl_wateringcan');
    Widget icon(double size, {double opacity = 1}) => Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: isSun ? const _SunIconPainter() : const _CanIconPainter()),
          ),
        );
    final item = ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, time, child) {
        final glow = 0.5 + 0.5 * math.sin(time * 4);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: _theme.withValues(alpha: 0.08 + 0.06 * glow),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _theme.withValues(alpha: 0.35 + 0.4 * glow), width: 1.5),
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon(44 * s),
          SizedBox(height: 3 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textStrong, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
    return Positioned(
      top: inset.top + 50 * s,
      right: inset.right + 6,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: LabGlassCard(
          palette: p,
          padding: EdgeInsets.all(8 * s),
          radius: 12,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 92 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t('toolbox').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 9.5 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  height: 1,
                  width: 60 * s,
                  margin: EdgeInsets.symmetric(vertical: 6 * s),
                  color: p.cardBorder,
                ),
                Draggable<String>(
                  data: id,
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: Transform.translate(
                    offset: Offset(-24 * s, -24 * s),
                    child: icon(52 * s, opacity: 0.85),
                  ),
                  childWhenDragging: Opacity(opacity: 0.35, child: item),
                  onDragStarted: () {
                    _Audio.play(_Sound.pickup);
                    setState(() => _dragging = true);
                  },
                  onDragEnd: (_) {
                    if (mounted) setState(() => _dragging = false);
                  },
                  child: GestureDetector(
                    onTap: () => _deployTool(id),
                    child: item,
                  ),
                ),
              ],
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
    'app_title': 'The Water Cycle',
    'app_subtitle': 'Class 7 • Heat Transfer in Nature',
    'scen_1_opt': "Scenario 1: The Sun's Great Water Journey",
    'scen_2_opt': 'Scenario 2: The Journey Beneath Our Feet',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Success!',
    'drop_here': 'DROP HERE',
    'toolbox': 'Toolbox',
    'btn_observe': 'Observe Runoff',
    'lbl_sun': 'Sun',
    'lbl_wateringcan': 'Watering Can',
    'lbl_gravel': 'Gravel',
    'lbl_sand': 'Sand',
    'lbl_clay': 'Clay',
    'lbl_aquifer': 'Aquifer (Saturated Zone)',
    'lbl_topsoil': 'Topsoil',
    'lbl_porous': 'Sand/Gravel',
    'lbl_bedrock': 'Bedrock',
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario.',
    'conclusion_1':
        "The water cycle is a continuous loop. The sun's heat causes evaporation and transpiration. The vapor cools and condenses into clouds, leading to precipitation which collects back into oceans and rivers.",
    'conclusion_2':
        'Water percolates through soil at different rates based on particle size. It stops at impermeable bedrock, forming saturated zones called Aquifers. We extract this groundwater using handpumps.',
    // Strings that were hard-coded (English only) in the HTML.
    'msg_wrong_item': 'Not the right time or item for this step!',
    'scen_label_1': 'Scenario 1:',
    'scen_label_2': 'Scenario 2:',
    // Scene captions added for the native version.
    'lbl_ocean': 'Ocean',
    'lbl_evaporation': 'Evaporation',
    'lbl_transpiration': 'Transpiration',
    'lbl_vapor': 'Water Vapour',
    'lbl_condensation': 'Condensation',
    'lbl_precipitation': 'Precipitation',
    'lbl_runoff': 'Runoff',
    'lbl_cloud': 'Cloud',
    'lbl_infiltration': 'Infiltration',
    'lbl_handpump': 'Handpump',
  },
  'hi': {
    'app_title': 'जल चक्र (Water Cycle)',
    'app_subtitle': 'कक्षा 7 • प्रकृति में ऊष्मा का स्थानांतरण',
    'scen_1_opt': 'परिदृश्य 1: सूर्य की महान जल यात्रा',
    'scen_2_opt': 'परिदृश्य 2: हमारे पैरों के नीचे की यात्रा',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'सफलता!',
    'drop_here': 'यहां छोड़ें',
    'toolbox': 'टूलबॉक्स',
    'btn_observe': 'प्रवाह का निरीक्षण करें',
    'lbl_sun': 'सूर्य',
    'lbl_wateringcan': 'झरनी',
    'lbl_gravel': 'बजरी',
    'lbl_sand': 'रेत',
    'lbl_clay': 'मिट्टी',
    'lbl_aquifer': 'जलभृत (Aquifer)',
    'lbl_topsoil': 'ऊपरी मिट्टी',
    'lbl_porous': 'रेत/बजरी',
    'lbl_bedrock': 'आधार चट्टान',
    'msg_scenario_complete': 'परिदृश्य पूर्ण! कृपया अगला परिदृश्य चुनें।',
    'conclusion_1':
        'जल चक्र एक निरंतर लूप है। सूर्य की गर्मी वाष्पीकरण (Evaporation) और वाष्पोत्सर्जन (Transpiration) का कारण बनती है। वाष्प ठंडी होकर बादलों में संघनित (Condense) होती है, जिससे वर्षा (Precipitation) होती है।',
    'conclusion_2':
        'पानी कणों के आकार के आधार पर अलग-अलग दरों पर मिट्टी से रिसता है। यह अभेद्य चट्टान पर रुक जाता है, जिससे जलभृत (Aquifer) बनते हैं।',
    'msg_wrong_item': 'इस चरण के लिए यह सही समय या सही वस्तु नहीं है!',
    'scen_label_1': 'परिदृश्य 1:',
    'scen_label_2': 'परिदृश्य 2:',
    'lbl_ocean': 'महासागर',
    'lbl_evaporation': 'वाष्पीकरण',
    'lbl_transpiration': 'वाष्पोत्सर्जन',
    'lbl_vapor': 'जलवाष्प',
    'lbl_condensation': 'संघनन',
    'lbl_precipitation': 'अवक्षेपण',
    'lbl_runoff': 'अपवाह',
    'lbl_cloud': 'बादल',
    'lbl_infiltration': 'अंतःस्यंदन',
    'lbl_handpump': 'हैंडपंप',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To build a complete water cycle by manipulating environmental elements and observing the transformation of water through its different stages.',
      steps: [
        LabStep(
          concept: 'Evaporation',
          action: 'DRAG the Sun icon from the toolbox and DROP it over the ocean.',
          observation: 'The sun shines on the ocean, and water vapor particles rise from the surface.',
        ),
        LabStep(
          concept: 'Transpiration',
          action: 'CLICK on the group of trees on the land.',
          observation: 'Water vapor is released from the leaves of the trees and rises into the air.',
        ),
        LabStep(
          concept: 'Condensation',
          action: 'CLICK on the collected water vapor high in the sky.',
          observation: 'Vapor particles transform into a visible, white, fluffy cloud.',
        ),
        LabStep(
          concept: 'Precipitation',
          action: 'CLICK repeatedly on the newly formed cloud.',
          observation:
              'The cloud grows and darkens. It starts raining over land and snowing over mountains.',
        ),
        LabStep(
          concept: 'Collection (Runoff)',
          action: "CLICK 'Observe Runoff' to watch the landscape.",
          observation: 'Rainwater forms streams that flow into the ocean. Snow visibly melts.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To investigate how water seeps into the ground and forms aquifers, based on Activity 7.5.',
      steps: [
        LabStep(
          concept: 'Percolation Rates',
          action: 'DRAG the Watering Can and DROP it over the three columns.',
          observation:
              'Water seeps fastest through Gravel, slower through Sand, and extremely slowly through Clay.',
        ),
        LabStep(
          concept: 'Infiltration',
          action: 'A cross-section appears. CLICK the cloud to make it rain.',
          observation: 'Rain falls and water percolates through the topsoil into the porous layer.',
        ),
        LabStep(
          concept: 'Forming an Aquifer',
          action: 'Watch the water seep downwards.',
          observation: 'Water stops at solid bedrock, filling spaces to form an Aquifer.',
        ),
        LabStep(
          concept: 'Extracting Groundwater',
          action: 'CLICK the handle of the handpump.',
          observation: 'Water is drawn up from the aquifer through the transparent pipe.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'पर्यावरणीय तत्वों में हेरफेर करके एक संपूर्ण जल चक्र का निर्माण करना।',
      steps: [
        LabStep(
          concept: 'वाष्पीकरण (Evaporation)',
          action: 'सूर्य को टूलबॉक्स से खींचें और समुद्र के ऊपर छोड़ दें।',
          observation: 'समुद्र से जलवाष्प के कण ऊपर उठते हैं।',
        ),
        LabStep(
          concept: 'वाष्पोत्सर्जन (Transpiration)',
          action: 'जमीन पर पेड़ों के समूह पर क्लिक करें।',
          observation: 'पेड़ों की पत्तियों से जलवाष्प हवा में निकलती है।',
        ),
        LabStep(
          concept: 'संघनन (Condensation)',
          action: 'आसमान में जमा जलवाष्प पर क्लिक करें।',
          observation: 'वाष्प के कण एक सफेद बादल में बदल जाते हैं।',
        ),
        LabStep(
          concept: 'अवक्षेपण (Precipitation)',
          action: 'नए बने बादल पर बार-बार क्लिक करें।',
          observation: 'बादल बड़ा और गहरा हो जाता है। बारिश होने लगती है।',
        ),
        LabStep(
          concept: 'संग्रह (Collection)',
          action: "'प्रवाह का निरीक्षण करें' पर क्लिक करें।",
          observation: 'वर्षा जल धाराएं बनाता है जो समुद्र में बहती हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'जांच करने के लिए कि पानी जमीन में कैसे रिसता है और जलभृत (aquifer) बनाता है।',
      steps: [
        LabStep(
          concept: 'रिसने की दर',
          action: 'झरनी (Watering Can) को खींचें और तीनों कॉलम के ऊपर छोड़ दें।',
          observation: 'पानी बजरी (Gravel) से सबसे तेजी से रिसता है, और मिट्टी (Clay) से बहुत धीरे।',
        ),
        LabStep(
          concept: 'अंतःस्यंदन (Infiltration)',
          action: 'एक क्रॉस-सेक्शन दिखाई देता है। बारिश करने के लिए बादल पर क्लिक करें।',
          observation: 'बारिश गिरती है और पानी ऊपरी मिट्टी से रिसता है।',
        ),
        LabStep(
          concept: 'जलभृत बनाना',
          action: 'पानी को नीचे की ओर रिसते हुए देखें।',
          observation: 'पानी ठोस चट्टान पर रुक जाता है, जिससे एक जलभृत (Aquifer) बनता है।',
        ),
        LabStep(
          concept: 'भूजल निकालना',
          action: 'हैंडपंप के हैंडल पर क्लिक करें।',
          observation: 'पारदर्शी पाइप के जरिए जलभृत से पानी ऊपर खींचा जाता है।',
        ),
      ],
    ),
  ],
};

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);
const Color _theme = Color(0xFF0EA5E9); // zsl.theme (sky-500)
const Color _rainBlue = Color(0xFF38BDF8);

/// Tiny TWEEN.js stand-in: interpolates [from] -> [to] between [t0] and
/// `t0 + dur` (seconds of scene time) with [curve].
class _Tw {
  _Tw(this.from, this.to, this.t0, this.dur, [this.curve = Curves.linear]);
  final double from, to, t0, dur;
  final Curve curve;

  double at(double t) {
    final u = dur <= 0 ? 1.0 : ((t - t0) / dur).clamp(0.0, 1.0);
    return from + (to - from) * curve.transform(u);
  }

  bool done(double t) => t >= t0 + dur;
}

/// Perspective camera emulating the Three.js PerspectiveCamera that looks
/// from [pos] at a target. Projects world units to design pixels.
class _Cam {
  _Cam(this.px, this.py, this.pz, double tx, double ty, double tz, this.focal, this.center) {
    var fx = tx - px, fy = ty - py, fz = tz - pz;
    final fl = math.sqrt(fx * fx + fy * fy + fz * fz);
    fx /= fl;
    fy /= fl;
    fz /= fl;
    _f = [fx, fy, fz];
    // right = forward x worldUp(0,1,0)
    var rx = -fz, rz = fx;
    final rl = math.sqrt(rx * rx + rz * rz);
    rx /= rl;
    rz /= rl;
    _r = [rx, 0, rz];
    // up = right x forward
    _u = [0 * fz - rz * fy, rz * fx - rx * fz, rx * fy - 0 * fx];
  }

  final double px, py, pz, focal;
  final Offset center;
  late final List<double> _f, _r, _u;

  double _depth(double x, double y, double z) =>
      (x - px) * _f[0] + (y - py) * _f[1] + (z - pz) * _f[2];

  Offset p(double x, double y, double z) {
    final dx = x - px, dy = y - py, dz = z - pz;
    final d = math.max(0.1, dx * _f[0] + dy * _f[1] + dz * _f[2]);
    final sx = dx * _r[0] + dy * _r[1] + dz * _r[2];
    final sy = dx * _u[0] + dy * _u[1] + dz * _u[2];
    return Offset(center.dx + focal * sx / d, center.dy - focal * sy / d);
  }

  /// Design pixels per world unit at that point.
  double k(double x, double y, double z) => focal / math.max(0.1, _depth(x, y, z));

  /// Screen bounding rect of a world-space box.
  Rect box(double x0, double y0, double z0, double x1, double y1, double z1) {
    final pts = [
      for (final x in [x0, x1])
        for (final y in [y0, y1])
          for (final z in [z0, z1]) p(x, y, z),
    ];
    var r = Rect.fromPoints(pts.first, pts.first);
    for (final q in pts) {
      r = r.expandToInclude(Rect.fromPoints(q, q));
    }
    return r;
  }
}

/// Scenario 1 camera: Three.js camera (0, 15, 30) looking at the diorama.
final _Cam _cam1 = _Cam(0, 15, 30, 0, 2, 0, 600, const Offset(500, 282));

/// Scenario 2 camera: Three.js camera (0, 6, 25) looking at the cross-section.
final _Cam _cam2 = _Cam(0, 8.5, 26, 0, 6.2, 0, 780, const Offset(500, 280));

class _Tree {
  _Tree(this.x, this.z);
  final double x, z;
}

class _Vap {
  _Vap(this.x, this.y, this.z, {this.fromTree = false});
  double x, y, z;
  final bool fromTree;
  bool hidden = false;
  // Condensation tween towards the cloud (0, 12, 0).
  double cx0 = 0, cy0 = 0, cz0 = 0, ct0 = -1, cdur = 1;
}

class _P3 {
  _P3(this.x, this.y, this.z);
  double x, y, z;
}

class _PumpDrop {
  _PumpDrop();
  double x = 5, y = 1.5;
  int state = 0; // 0 up the pipe, 1 along the spout, 2 falling, 3 gone
}

class _Pebble {
  _Pebble(this.x, this.y, this.r, this.rot, this.shade);
  final double x, y, r, rot, shade;
}

/// Mutable scene read by the painter every frame (the HTML `State.objects`
/// and `State.flags`).
class _WcScene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  final math.Random rnd = math.Random(7);

  _Cam get cam => scenario == 0 ? _cam1 : _cam2;

  // ---------------------------------------------------------- scenario 1
  final List<_Tree> trees = [];
  bool sunVisible = false;
  double sunT0 = 0;
  bool evaporating = false, transpiring = false, raining = false;
  final List<_Vap> vapor = [];
  double _spawnAcc = 0;
  bool condensing = false;
  bool cloudPending = false;
  bool cloudVisible = false;
  _Tw cloudScale = _Tw(1, 1, 0, 0);
  int cloudClicks = 0;
  final List<_P3> rain = [];
  bool runoff = false;
  double runoffT0 = 0;

  // ---------------------------------------------------------- scenario 2
  bool toolUsed = false;
  bool canVisible = false;
  double canT0 = 0;
  bool columnsVisible = true;
  bool colWater = false;
  double pourT0 = 0;
  bool crossVisible = false;
  final List<_Pebble> pebbles = [];
  bool seeping = false;
  final List<_P3> rain2 = [];
  bool aquiferVisible = false;
  double aquiferT0 = 0;
  bool aquiferLabel = false;
  bool pumpVisible = false;
  double pumpT0 = 0;
  bool pumping = false;
  double handleT0 = 0;
  final List<_PumpDrop> pumpWater = [];

  /// HTML `buildScenario()` + `clearScene()`.
  void build(int sc) {
    scenario = sc;
    step = 1;
    trees.clear();
    vapor.clear();
    rain.clear();
    rain2.clear();
    pebbles.clear();
    pumpWater.clear();
    sunVisible = evaporating = transpiring = raining = false;
    condensing = cloudPending = cloudVisible = runoff = false;
    cloudScale = _Tw(1, 1, 0, 0);
    cloudClicks = 0;
    toolUsed = canVisible = colWater = crossVisible = false;
    columnsVisible = true;
    seeping = aquiferVisible = aquiferLabel = pumpVisible = pumping = false;
    _spawnAcc = 0;
    if (sc == 0) {
      final r = math.Random(11);
      for (var i = 0; i < 12; i++) {
        trees.add(_Tree(2 + r.nextDouble() * 8, -8 + r.nextDouble() * 16));
      }
    } else {
      final r = math.Random(5);
      for (var i = 0; i < 60; i++) {
        pebbles.add(_Pebble(
          (r.nextDouble() - 0.5) * 19,
          2.5 + r.nextDouble() * 3,
          0.1 + r.nextDouble() * 0.1,
          r.nextDouble() * math.pi,
          r.nextDouble(),
        ));
      }
    }
  }

  // Sun drop tween: (0, 15, -5) -> (-10, 10, -5), 1000 ms Quadratic.Out.
  ({double x, double y, double z}) get sunPos {
    final u = Curves.easeOutQuad.transform(((time - sunT0) / 1.0).clamp(0.0, 1.0));
    return (x: -10.0 * u, y: 15 - 5 * u, z: -5.0);
  }

  /// Cloud grey value (HTML `1 - clicks * 0.2`).
  double get cloudGrey => (1 - cloudClicks * 0.2).clamp(0.2, 1.0);

  // Watering can drop tween: y 15 -> 7, 1000 ms Quadratic.Out.
  double get canY => 15 - 8 * Curves.easeOutQuad.transform(((time - canT0) / 1.0).clamp(0.0, 1.0));

  /// Percolation progress (0..1) of a column with duration [ms].
  double percolation(double ms) => colWater ? ((time - pourT0) / (ms / 1000)).clamp(0.0, 1.0) : 0;

  /// Aquifer height in world units (scale.y 0.01 -> 1.5 over 4 s).
  double get aquiferHeight =>
      aquiferVisible ? 0.01 + 1.49 * ((time - aquiferT0) / 4).clamp(0.0, 1.0) : 0;

  /// Handpump vertical offset (bounces from +5 down to 0 in 1 s).
  double get pumpOffset =>
      5 * (1 - Curves.bounceOut.transform(((time - pumpT0) / 1.0).clamp(0.0, 1.0)));

  /// Handle rotation: 0 -> PI/4, 250 ms, yoyo, repeat 5.
  double get handleAngle {
    if (!pumping) return 0;
    final u = (time - handleT0) / 0.25;
    if (u >= 6 || u < 0) return 0;
    final n = u.floor();
    final f = u - n;
    return math.pi / 4 * (n.isEven ? f : 1 - f);
  }

  // ------------------------------------------------------------ updates

  /// HTML `updateLogic()` (frame based speeds converted to units/second).
  void update(double dt) {
    if (scenario == 0) {
      if (evaporating || transpiring) {
        final speed = (evaporating ? 3.0 : 0) + (transpiring ? 3.0 : 0);
        if (transpiring) {
          _spawnAcc += dt * 60;
          while (_spawnAcc >= 1 && vapor.length < 50) {
            _spawnAcc -= 1;
            vapor.add(_Vap(2 + rnd.nextDouble() * 8, 3, -8 + rnd.nextDouble() * 16, fromTree: true));
          }
        }
        for (final p in vapor) {
          p.y += speed * dt;
          if (p.y > 10) p.y = p.fromTree ? 3 : 0;
        }
      }
      if (condensing) {
        for (final p in vapor) {
          if (p.hidden || p.ct0 < 0) continue;
          if (time >= p.ct0 + p.cdur) p.hidden = true;
        }
        // The cloud appears when the last particle reaches it (HTML onComplete).
        if (cloudPending && (vapor.isEmpty || vapor.last.hidden)) {
          cloudPending = false;
          cloudVisible = true;
          sunVisible = false;
          cloudScale = _Tw(0.1, 1, time, 1.0, Curves.elasticOut);
        }
      }
      if (raining) {
        for (final p in rain) {
          p.y -= 12 * dt;
          if (p.y < 0) p.y = 10;
        }
      }
    } else {
      if (seeping) {
        for (final p in rain2) {
          // Falls through the air, then seeps more slowly through the soil.
          p.y -= (p.y > 7.2 ? 6 : 2.2) * dt;
          final floor = 2 + aquiferHeight;
          if (p.y < floor) p.y = 9.4 + rnd.nextDouble() * 3;
        }
      }
      for (final d in pumpWater) {
        switch (d.state) {
          case 0:
            d.y += 9 * dt;
            if (d.y >= 8.4) {
              d
                ..y = 8.4
                ..state = 1;
            }
          case 1:
            d.x += 6 * dt;
            if (d.x >= 5.8) {
              d
                ..x = 5.8
                ..state = 2;
            }
          case 2:
            d.y -= 9 * dt;
            if (d.y <= 7.2) d.state = 3;
        }
      }
    }
  }

  /// Vapor particle world position (follows its condensation tween).
  ({double x, double y, double z}) vapPos(_Vap p) {
    if (p.ct0 < 0) return (x: p.x, y: p.y, z: p.z);
    final u = ((time - p.ct0) / p.cdur).clamp(0.0, 1.0);
    return (x: p.cx0 + (0 - p.cx0) * u, y: p.cy0 + (12 - p.cy0) * u, z: p.cz0 + (0 - p.cz0) * u);
  }

  // ------------------------------------------------------------ hit tests

  static const List<List<double>> cloudPoses = [
    [0, 0, 0], [1.5, 0.5, 0], [-1.5, -0.2, 0], [0.8, -0.5, 1], [-0.5, 0.5, -1], //
  ];

  bool _hitCloud(Offset pos, double cx, double cy, double cz, double s) {
    for (final q in cloudPoses) {
      final x = cx + q[0] * s, y = cy + q[1] * s, z = cz + q[2] * s;
      final c = cam.p(x, y, z);
      if ((pos - c).distance <= 1.5 * s * cam.k(x, y, z) + 8) return true;
    }
    return false;
  }

  Rect treeRect(_Tree t) {
    final top = cam.p(t.x, 3.5, t.z);
    final base = cam.p(t.x, 1, t.z);
    final w = 0.8 * cam.k(t.x, 1.5, t.z);
    return Rect.fromLTRB(base.dx - w, top.dy, base.dx + w, base.dy);
  }

  bool hitTrees(Offset pos) => trees.any((t) => treeRect(t).inflate(6).contains(pos));

  Rect get vaporRect => _cam1.box(-5, 8, -5, 5, 12, 5);

  bool hitVapor(Offset pos) => vaporRect.contains(pos);

  bool hitCloud1(Offset pos) => cloudVisible && _hitCloud(pos, 0, 12, 0, cloudScale.at(time));

  static const double cloud2Y = 11.6;

  bool hitCloud2(Offset pos) => crossVisible && _hitCloud(pos, -5, cloud2Y, 0, 1.5);

  Rect get pumpRect => _cam2.box(2.9, 6.6 + pumpOffset, 1.1, 7.1, 10.4 + pumpOffset, 3.1);

  bool hitPump(Offset pos) => pumpVisible && pumpRect.contains(pos);
}

// ============================================================ PAINTER

Path _poly(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final q in pts.skip(1)) {
    path.lineTo(q.dx, q.dy);
  }
  return path..close();
}

class _WcPainter extends CustomPainter {
  _WcPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _WcScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final String Function(String key) tr;

  static const double _labelSize = 19;
  static const double _pumpScale = 1.35;

  _Cam get cam => scene.cam;
  double get t => scene.time;
  double get pulse => 0.5 + 0.5 * math.sin(t * 4);

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    if (scene.scenario == 0) {
      _paintS1(canvas);
    } else {
      _paintS2(canvas);
    }
  }

  // HTML `#sky-bg` gradient + `.grid-overlay` (40 px lines).
  void _paintSky(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E3A8A)]
              : const [Color(0xFFBAE6FD), Color(0xFFE0F2FE)],
        ).createShader(Offset.zero & size),
    );
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.05 : 0.35)
      ..strokeWidth = 1;
    final x0 = (bleed.left / 40).floor() * 40.0;
    for (var x = x0; x <= bleed.right; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    final y0 = (bleed.top / 40).floor() * 40.0;
    for (var y = y0; y <= bleed.bottom; y += 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
  }

  void _label(Canvas canvas, String key, Offset at, {Color? bg, Color? border, double opacity = 1}) {
    if (!showLabels) return;
    labPill(
      canvas,
      tr(key),
      at,
      size: _labelSize,
      background: bg ?? const Color(0xE61E293B),
      border: border ?? const Color(0x6694A3B8),
      opacity: opacity,
    );
  }

  /// Small caption for a water-cycle process (sky-blue outline).
  void _process(Canvas canvas, String key, Offset at, {double opacity = 1}) {
    if (!showLabels) return;
    labText(
      canvas,
      tr(key),
      at,
      size: 18,
      weight: FontWeight.w800,
      color: isDark ? const Color(0xFFE0F2FE) : const Color(0xFF075985),
      background: isDark ? const Color(0xCC0C4A6E) : const Color(0xE6FFFFFF),
      border: _theme,
      borderWidth: 1.5,
      radius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      opacity: opacity,
    );
  }

  /// Pulsing dashed "tap here" ring (stands in for the HTML pointer cursor).
  void _hintRect(Canvas canvas, Rect r, {bool oval = false}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = _theme.withValues(alpha: 0.35 + 0.5 * pulse);
    final rr = r.inflate(4 + 4 * pulse);
    final path = oval
        ? (Path()..addOval(rr))
        : (Path()..addRRect(RRect.fromRectAndRadius(rr, const Radius.circular(14))));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = _theme.withValues(alpha: 0.05 + 0.06 * pulse),
    );
    labDashedPath(canvas, path, paint, dash: 10, gap: 7, phase: t * 20);
  }

  // ========================================================== SCENARIO 1

  void _paintS1(Canvas canvas) {
    final c = cam;
    // Soft shadow under the floating diorama.
    labGroundShadow(canvas, c.p(0, -2, 10).translate(0, 26), 980, 46, opacity: isDark ? 0.45 : 0.18);
    _paintOcean(canvas);
    _paintLand(canvas);
    if (scene.runoff) _paintRivers(canvas);

    if (scene.cloudVisible) {
      final s = scene.cloudScale.at(t);
      labGroundShadow(canvas, c.p(0, 0.5, 2), 6.5 * s * c.k(0, 0.5, 2), 1.4 * s * c.k(0, 0.5, 2),
          opacity: 0.1 + 0.15 * (1 - scene.cloudGrey));
    }

    // Mountains, trees, vapour and rain, far to near (painter's algorithm),
    // so particles behind a mountain are hidden by it.
    final rainPaint = Paint()
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..color = _rainBlue.withValues(alpha: 0.9);
    final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    final items = <(double, VoidCallback)>[
      for (final m in const [
        [12.0, -5.0, 8.0],
        [16.0, 2.0, 6.0],
        [8.0, 6.0, 5.0],
      ])
        (m[1], () => _mountain(canvas, m[0], m[1], m[2])),
      for (final tree in scene.trees) (tree.z, () => _tree(canvas, tree)),
      // Vapor particles (evaporation / transpiration / condensing).
      for (final p in scene.vapor)
        if (!p.hidden) (scene.vapPos(p).z, () => _vapour(canvas, p)),
      if (scene.raining)
        for (final p in scene.rain) (p.z, () => _rainDrop(canvas, p, rainPaint, snowPaint)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final it in items) {
      it.$2();
    }

    if (scene.sunVisible) _paintSun(canvas);
    if (scene.cloudVisible) _cloud(canvas, 0, 12, 0, scene.cloudScale.at(t), scene.cloudGrey);

    _paintS1Hints(canvas);
    _paintS1Labels(canvas);
  }

  void _paintOcean(Canvas canvas) {
    final c = cam;
    const ocean = Color(0xFF0284C7);
    final top = _poly([c.p(-20, 0, -10), c.p(0, 0, -10), c.p(0, 0, 10), c.p(-20, 0, 10)]);
    final front = _poly([c.p(-20, 0, 10), c.p(0, 0, 10), c.p(0, -2, 10), c.p(-20, -2, 10)]);
    final tb = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(ocean, 0.25).withValues(alpha: 0.92), ocean.withValues(alpha: 0.92)],
        ).createShader(tb),
    );
    // Sun glitter on the water.
    if (scene.sunVisible) {
      final sp = scene.sunPos;
      final g = c.p(sp.x, 0, 1);
      canvas.save();
      canvas.clipPath(top);
      canvas.translate(g.dx, g.dy);
      canvas.scale(1, 0.28);
      labGlow(canvas, Offset.zero, 230, const Color(0xFFFEF08A), intensity: 0.55);
      canvas.restore();
    }
    // Moving wave highlights.
    canvas.save();
    canvas.clipPath(top);
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.28);
    for (var i = 0; i < 9; i++) {
      final z = -9.5 + i * 2.4;
      final path = Path();
      for (var x = -20.0; x <= 0; x += 0.5) {
        final o = c.p(x, 0, z) + Offset(0, math.sin(x * 1.2 + t * 2 + i) * 1.6);
        if (x == -20.0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      labDashedPath(canvas, path, wave, dash: 18, gap: 26, phase: t * 14 + i * 9);
    }
    canvas.restore();
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEB0369A1), Color(0xF00C4A6E)],
        ).createShader(front.getBounds()),
    );
    canvas.drawLine(
      c.p(-20, 0, 10),
      c.p(0, 0, 10),
      Paint()
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _paintLand(Canvas canvas) {
    final c = cam;
    const land = Color(0xFF4ADE80);
    final top = _poly([c.p(0, 1, -10), c.p(20, 1, -10), c.p(20, 1, 10), c.p(0, 1, 10)]);
    final front = _poly([c.p(0, 1, 10), c.p(20, 1, 10), c.p(20, -2, 10), c.p(0, -2, 10)]);
    // Coast wall (x = 0) between sea level and the land top, seen edge-on.
    canvas.drawPath(
      _poly([c.p(0, 1, -10), c.p(0, 1, 10), c.p(0, 0, 10), c.p(0, 0, -10)]),
      Paint()..color = labShade(land, -0.35),
    );
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(land, -0.08), land],
        ).createShader(top.getBounds()),
    );
    // Grass speckles.
    final r = math.Random(3);
    final speck = Paint()..color = labShade(land, -0.22).withValues(alpha: 0.55);
    for (var i = 0; i < 140; i++) {
      final x = 0.8 + r.nextDouble() * 19, z = -9.6 + r.nextDouble() * 19.2;
      final o = c.p(x, 1, z);
      canvas.drawOval(Rect.fromCenter(center: o, width: 0.22 * c.k(x, 1, z), height: 0.1 * c.k(x, 1, z)), speck);
    }
    // Sandy beach strip along the coast.
    canvas.drawPath(
      _poly([c.p(0, 1, -10), c.p(0.7, 1, -10), c.p(0.7, 1, 10), c.p(0, 1, 10)]),
      Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.9),
    );
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(land, -0.18), labShade(land, -0.48)],
        ).createShader(front.getBounds()),
    );
    canvas.drawPath(
      _poly([c.p(0, 1, 10), c.p(20, 1, 10), c.p(20, 0.75, 10), c.p(0, 0.75, 10)]),
      Paint()..color = labShade(land, 0.05),
    );
  }

  /// Rain-fed streams flowing over the land into the ocean (HTML rivers).
  void _paintRivers(Canvas canvas) {
    final c = cam;
    final reveal = ((t - scene.runoffT0) / 1.4).clamp(0.0, 1.0);
    List<(double, double)> meander(double ax, double az, double bx, double bz, double amp, double waves) {
      final dx = bx - ax, dz = bz - az;
      final len = math.sqrt(dx * dx + dz * dz);
      final nx = -dz / len, nz = dx / len;
      return [
        for (var i = 0; i <= 30; i++)
          (
            ax + dx * i / 30 + nx * amp * math.sin(i / 30 * math.pi * waves),
            az + dz * i / 30 + nz * amp * math.sin(i / 30 * math.pi * waves),
          ),
      ];
    }

    final rivers = [
      (meander(10.5, 1.2, -0.3, 0.2, 0.6, 3), 0.8),
      (meander(4.6, 7.0, -0.3, 6.0, 0.35, 2), 0.7),
    ];
    for (final (pts, width) in rivers) {
      final n = (pts.length * reveal).ceil().clamp(0, pts.length);
      if (n < 2) continue;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final o = c.p(pts[i].$1, 1.05, pts[i].$2);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      final k = c.k(pts[n ~/ 2].$1, 1, pts[n ~/ 2].$2);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width * k + 3
          ..color = labShade(const Color(0xFF4ADE80), -0.3),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width * k
          ..color = _rainBlue,
      );
      labDashedPath(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.2, width * k * 0.3)
          ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.85),
        dash: 7,
        gap: 12,
        phase: -t * 45,
      );
    }
    // Ripples where the main stream meets the ocean.
    for (final (mx, mz) in const [(-0.6, 0.2), (-0.6, 6.0)]) {
      if (reveal < 1) break;
      final mouth = c.p(mx, 0, mz);
      final k = c.k(mx, 0, mz);
      for (var i = 0; i < 3; i++) {
        final ph = ((t * 0.8 + i / 3) % 1.0);
        canvas.drawOval(
          Rect.fromCenter(center: mouth, width: (0.5 + 2.5 * ph) * k, height: (0.2 + 0.8 * ph) * k),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.white.withValues(alpha: 0.6 * (1 - ph)),
        );
      }
    }
  }

  /// Four-sided cone mountain with a snow cap (HTML `buildMountain`).
  void _mountain(Canvas canvas, double x, double z, double h) {
    final c = cam;
    const mtn = Color(0xFF64748B);
    final r = 0.8 * h;
    const by = 1.0;
    final apex = c.p(x, by + h, z);
    final l = c.p(x - r, by, z), f = c.p(x, by, z + r), rr = c.p(x + r, by, z);
    labGroundShadow(canvas, c.p(x + 0.6, by, z + r * 0.4), 1.7 * r * c.k(x, by, z), 0.5 * r * c.k(x, by, z),
        opacity: 0.22);
    canvas.drawPath(_poly([l, f, apex]), Paint()..color = labShade(mtn, -0.16));
    canvas.drawPath(_poly([f, rr, apex]), Paint()..color = labShade(mtn, 0.14));
    canvas.drawLine(
      f,
      apex,
      Paint()
        ..strokeWidth = 1.2
        ..color = labShade(mtn, -0.35).withValues(alpha: 0.6),
    );
    // Snow cap; it shrinks while the snow melts during runoff.
    final melt = scene.runoff ? 1 - 0.3 * ((t - scene.runoffT0) / 2.5).clamp(0.0, 1.0) : 1.0;
    final cr = 0.3 * h * melt;
    final cy = by + h * (1 - 0.3 * melt);
    final sl = c.p(x - cr, cy, z), sf = c.p(x, cy, z + cr), sr = c.p(x + cr, cy, z);
    final jag = (sf - sl) / 3;
    final jag2 = (sr - sf) / 3;
    canvas.drawPath(
      _poly([sl, sl + jag + const Offset(0, 4), sl + jag * 2, sf + const Offset(0, 3), apex]),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawPath(
      _poly([sf + const Offset(0, 3), sf + jag2, sf + jag2 * 2 + const Offset(0, 4), sr, apex]),
      Paint()..color = Colors.white,
    );
    if (scene.runoff && melt < 1) {
      // Meltwater trickles.
      final drip = Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = _rainBlue.withValues(alpha: 0.8);
      for (var i = 0; i < 3; i++) {
        final a = Offset.lerp(sf, sr, 0.2 + i * 0.3)!;
        final ph = (t * 0.9 + i * 0.37) % 1.0;
        canvas.drawLine(a + Offset(0, 6 + ph * 28), a + Offset(0, 12 + ph * 28), drip);
      }
    }
  }

  void _tree(Canvas canvas, _Tree tree) {
    final c = cam;
    final base = c.p(tree.x, 1, tree.z);
    final k = c.k(tree.x, 1, tree.z);
    labGroundShadow(canvas, base.translate(0.35 * k, 0), 1.9 * k, 0.55 * k, opacity: 0.28);
    final trunkTop = c.p(tree.x, 2, tree.z);
    canvas.drawRect(
      Rect.fromLTRB(base.dx - 0.2 * k, trunkTop.dy, base.dx + 0.2 * k, base.dy),
      Paint()..color = const Color(0xFF78350F),
    );
    final apex = c.p(tree.x, 3.5, tree.z);
    final bl = c.p(tree.x - 0.8, 1.5, tree.z), br = c.p(tree.x + 0.8, 1.5, tree.z);
    final path = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(br.dx, br.dy)
      ..quadraticBezierTo((bl.dx + br.dx) / 2, br.dy + 0.35 * k, bl.dx, bl.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF15803D), Color(0xFF22C55E)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromLTRB(bl.dx, apex.dy, br.dx, br.dy)),
    );
  }

  void _paintSun(Canvas canvas) {
    final c = cam;
    final sp = scene.sunPos;
    final o = c.p(sp.x, sp.y, sp.z);
    final k = c.k(sp.x, sp.y, sp.z);
    labGlow(canvas, o, 5 * k, const Color(0xFFFDE047), intensity: 0.75);
    final ray = Paint()
      ..strokeWidth = 0.18 * k
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.7);
    for (var i = 0; i < 12; i++) {
      final a = t * 0.35 + i * math.pi / 6;
      final u = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(o + u * 2.45 * k, o + u * (i.isEven ? 3.3 : 2.9) * k, ray);
    }
    canvas.drawCircle(
      o,
      2 * k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2 * k
        ..color = const Color(0xFFFEF08A),
    );
    labSphere(canvas, o, 1.5 * k, const Color(0xFFFACC15), highlight: 0.55, shade: 0.2);
  }

  void _vapour(Canvas canvas, _Vap p) {
    final c = cam;
    final q = scene.vapPos(p);
    if (q.y < 0) return; // still below the water surface
    final o = c.p(q.x, q.y, q.z);
    final r = 0.2 * c.k(q.x, q.y, q.z);
    canvas.drawCircle(o, r * 1.8, Paint()..color = Colors.white.withValues(alpha: 0.12));
    canvas.drawCircle(o, r, Paint()..color = Colors.white.withValues(alpha: 0.55));
  }

  void _rainDrop(Canvas canvas, _P3 p, Paint rain, Paint snow) {
    final c = cam;
    final a = c.p(p.x, p.y, p.z);
    if (p.x > 9) {
      // Over the mountains the precipitation falls as snow.
      final k = c.k(p.x, p.y, p.z);
      canvas.drawCircle(a + Offset(math.sin(t * 3 + p.z) * 3, 0), 0.13 * k, snow);
    } else {
      canvas.drawLine(a, c.p(p.x, p.y + 0.5, p.z), rain);
    }
  }

  /// HTML `createCloud()`: five spheres merged into one fluffy cloud;
  /// [grey] darkens it (HTML `material.color.setRGB(val, val, val)`).
  void _cloud(Canvas canvas, double cx, double cy, double cz, double s, double grey) {
    final c = cam;
    final v = (255 * grey).round().clamp(0, 255);
    final col = Color.fromARGB(255, v, v, (v + 10).clamp(0, 255));
    final poses = [..._WcScene.cloudPoses]..sort((a, b) => a[2].compareTo(b[2]));
    final circles = <(Offset, double)>[
      for (final q in poses)
        (
          c.p(cx + q[0] * s, cy + q[1] * s, cz + q[2] * s),
          1.5 * s * c.k(cx + q[0] * s, cy + q[1] * s, cz + q[2] * s),
        ),
    ];
    final union = Path();
    for (final (o, r) in circles) {
      union.addOval(Rect.fromCircle(center: o, radius: r));
    }
    final b = union.getBounds();
    canvas.drawPath(
      union.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      union,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(col, 0.2), col, labShade(col, -0.3)],
          stops: const [0, 0.5, 1],
        ).createShader(b),
    );
    // Soft highlight on each puff.
    for (final (o, r) in circles) {
      final hc = o.translate(-0.25 * r, -0.35 * r);
      canvas.drawCircle(
        hc,
        r * 0.7,
        Paint()
          ..shader = RadialGradient(colors: [
            Colors.white.withValues(alpha: 0.35 + 0.25 * grey),
            Colors.white.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: hc, radius: r * 0.7)),
      );
    }
  }

  void _paintS1Hints(Canvas canvas) {
    final c = cam;
    final step = scene.step;
    if (step == 2 && !scene.transpiring && scene.trees.isNotEmpty) {
      var r = scene.treeRect(scene.trees.first);
      for (final tree in scene.trees) {
        r = r.expandToInclude(scene.treeRect(tree));
      }
      _hintRect(canvas, r);
    } else if (step == 3) {
      // Haze where the vapour collects high in the sky.
      final vr = scene.vaporRect;
      canvas.save();
      canvas.translate(vr.center.dx, vr.center.dy);
      canvas.scale(1, 0.45);
      labGlow(canvas, Offset.zero, vr.width * 0.42, Colors.white, intensity: 0.35 + 0.15 * pulse);
      canvas.restore();
      _hintRect(canvas, Rect.fromCenter(center: vr.center, width: vr.width * 0.8, height: vr.height * 0.55),
          oval: true);
    } else if (step == 4 && scene.cloudVisible && !scene.raining) {
      final s = scene.cloudScale.at(t);
      final o = c.p(0, 12, 0);
      final k = c.k(0, 12, 0);
      _hintRect(canvas, Rect.fromCenter(center: o, width: 7.4 * s * k, height: 4.6 * s * k), oval: true);
    }
  }

  void _paintS1Labels(Canvas canvas) {
    final c = cam;
    if (scene.step == 1 && !scene.sunVisible) _process(canvas, 'lbl_ocean', c.p(-10, 0, 4));
    if (scene.sunVisible) {
      final sp = scene.sunPos;
      _label(canvas, 'lbl_sun', c.p(sp.x, sp.y + 3, sp.z));
    }
    if (scene.evaporating) _process(canvas, 'lbl_evaporation', c.p(-14.5, 4.5, 3));
    if (scene.transpiring) _process(canvas, 'lbl_transpiration', c.p(8.5, 6.2, 3));
    if (scene.step == 3) _process(canvas, 'lbl_vapor', c.p(0, 13.4, 0));
    if (scene.cloudVisible && scene.step == 4) {
      final s = scene.cloudScale.at(t);
      _process(canvas, 'lbl_condensation', c.p(3.2 * s + 3.2, 12.6, 0));
    }
    if (scene.raining) _process(canvas, 'lbl_precipitation', c.p(-9.5, 8.6, 2));
    if (scene.runoff) _process(canvas, 'lbl_runoff', c.p(13.5, 1.2, 8.6));
  }

  // ========================================================== SCENARIO 2

  void _paintS2(Canvas canvas) {
    if (scene.columnsVisible) _paintColumns(canvas);
    if (scene.canVisible) _paintCan(canvas);
    if (scene.crossVisible) _paintCross(canvas);
  }

  void _paintColumns(Canvas canvas) {
    final c = cam;
    const cols = [
      (-5.0, Color(0xFF94A3B8), 1500.0, 'lbl_gravel', 0),
      (0.0, Color(0xFFFCD34D), 3000.0, 'lbl_sand', 1),
      (5.0, Color(0xFFC2410C), 6000.0, 'lbl_clay', 2),
    ];
    labGroundShadow(canvas, c.p(0, -0.1, 0).translate(0, 8), 860, 40, opacity: isDark ? 0.4 : 0.16);
    for (final (x, color, ms, label, kind) in cols) {
      final k = c.k(x, 3, 0);
      final w = 1.5 * k;
      double sy(double y) => c.p(x, y, 0).dy;
      double eh(double y, double r) => (c.p(x, y, r).dy - c.p(x, y, -r).dy).abs();
      final cx = c.p(x, 3, 0).dx;
      // Dark base disc.
      labCylinder(canvas, Rect.fromLTRB(cx - w, sy(0.1), cx + w, sy(-0.1)), const Color(0xFF333333),
          tilt: eh(0.1, 1.5) / (2 * w));
      // Back of the glass tube.
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, sy(6)), width: 2 * w, height: eh(6, 1.5)),
        Paint()..color = Colors.white.withValues(alpha: 0.08),
      );
      // Soil fill (y 0.1 .. 4.1).
      final fw = 1.45 * k;
      final soil = Rect.fromLTRB(cx - fw, sy(4.1), cx + fw, sy(0.1));
      final soilPath = Path()
        ..addRect(soil)
        ..addOval(Rect.fromCenter(center: Offset(cx, soil.bottom), width: 2 * fw, height: eh(0.1, 1.45)));
      canvas.drawPath(
        soilPath,
        Paint()
          ..shader = LinearGradient(colors: [
            labShade(color, -0.25),
            labShade(color, 0.1),
            labShade(color, -0.3),
          ], stops: const [0, 0.45, 1]).createShader(soil),
      );
      canvas.save();
      canvas.clipPath(soilPath);
      _soilTexture(canvas, soil, color, kind);
      canvas.restore();
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, soil.top), width: 2 * fw, height: eh(4.1, 1.45)),
        Paint()..color = labShade(color, 0.18),
      );
      if (scene.colWater) {
        final u = scene.percolation(ms);
        // Water seeped to the bottom (scale.y 1 -> 20, y 0.2 -> 1.0).
        final bs = 1 + 19 * u, bp = 0.2 + 0.8 * u;
        final bot = Rect.fromLTRB(cx - 1.46 * k, sy(bp + 0.05 * bs), cx + 1.46 * k, sy(bp - 0.05 * bs));
        canvas.drawRect(bot, Paint()..color = _theme.withValues(alpha: 0.72));
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, bot.top), width: 2.92 * k, height: eh(bp, 1.46)),
          Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: 0.75),
        );
        // Water still above the soil (scale.y 1 -> 0.1, y 5 -> 4.2).
        final ts = 1 - 0.9 * u, tp = 5 - 0.8 * u;
        final top = Rect.fromLTRB(cx - 1.4 * k, sy(tp + 0.9 * ts), cx + 1.4 * k, sy(tp - 0.9 * ts));
        canvas.drawRect(top, Paint()..color = _theme.withValues(alpha: 0.6));
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, top.top), width: 2.8 * k, height: eh(tp + 0.9 * ts, 1.4)),
          Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: 0.7),
        );
      }
      // Front of the glass tube with rim and highlight.
      final glass = Rect.fromLTRB(cx - w, sy(6), cx + w, sy(0));
      canvas.drawRect(glass, Paint()..color = Colors.white.withValues(alpha: 0.1));
      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.55);
      canvas.drawLine(glass.topLeft, glass.bottomLeft, edge);
      canvas.drawLine(glass.topRight, glass.bottomRight, edge);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, glass.top), width: 2 * w, height: eh(6, 1.5)), edge);
      canvas.drawLine(
        Offset(cx - w * 0.62, glass.top + 10),
        Offset(cx - w * 0.62, glass.bottom - 10),
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.22),
      );
      _label(canvas, label, c.p(x, -1, 0));
    }
  }

  void _soilTexture(Canvas canvas, Rect r, Color color, int kind) {
    final rnd = math.Random(20 + kind);
    if (kind == 0) {
      // Gravel: chunky pebbles.
      for (var i = 0; i < 70; i++) {
        final o = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
        final rad = 3.0 + rnd.nextDouble() * 4;
        labSphere(canvas, o, rad, labShade(color, rnd.nextDouble() * 0.4 - 0.25), highlight: 0.35, shade: 0.4);
      }
    } else if (kind == 1) {
      // Sand: fine grains.
      for (var i = 0; i < 260; i++) {
        final o = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
        canvas.drawCircle(o, 0.9 + rnd.nextDouble() * 0.9,
            Paint()..color = labShade(color, rnd.nextDouble() * 0.5 - 0.3).withValues(alpha: 0.8));
      }
    } else {
      // Clay: smooth, compact layers.
      final line = Paint()
        ..strokeWidth = 1.2
        ..color = labShade(color, -0.3).withValues(alpha: 0.45);
      for (var y = r.top + 8; y < r.bottom; y += 11) {
        final path = Path()..moveTo(r.left, y);
        for (var x = r.left; x <= r.right; x += 6) {
          path.lineTo(x, y + math.sin(x / 9 + y) * 1.5);
        }
        canvas.drawPath(path, line..style = PaintingStyle.stroke);
      }
    }
  }

  /// Watering can (HTML `wCan` group, tilted by PI/4) pouring water.
  void _paintCan(Canvas canvas) {
    final c = cam;
    const canX = 1.5;
    final y = scene.canY;
    final o = c.p(canX, y, 0);
    final k = c.k(canX, y, 0);
    const blue = Color(0xFF0284C7);
    // Pouring drops from the rose (spout tip at local (-1.9, 0.8)).
    if (scene.colWater && t - scene.canT0 > 0.9) {
      final tipX = canX - 1.909, tipY = y - 0.778;
      final drop = Paint()..color = _rainBlue.withValues(alpha: 0.9);
      for (var i = 0; i < 10; i++) {
        final ph = (t * 1.8 + i / 10) % 1.0;
        final dx = tipX + (i % 3 - 1) * 0.18 - ph * 0.25;
        final p = c.p(dx, tipY - ph * 1.0, 0);
        canvas.drawOval(Rect.fromCenter(center: p, width: 0.12 * k, height: 0.22 * k), drop);
      }
    }
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(-math.pi / 4);
    // Handle.
    canvas.drawPath(
      Path()
        ..moveTo(0.9 * k, -2.2 * k)
        ..cubicTo(1.9 * k, -2.0 * k, 1.9 * k, -0.6 * k, 0.9 * k, -0.5 * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.24 * k
        ..strokeCap = StrokeCap.round
        ..color = labShade(blue, -0.25),
    );
    // Spout (thin at the rose, thicker at the body).
    final spout = Path()
      ..moveTo(-0.72 * k, -2.42 * k)
      ..lineTo(-2.0 * k, -0.95 * k)
      ..lineTo(-1.76 * k, -0.68 * k)
      ..lineTo(-0.3 * k, -2.0 * k)
      ..close();
    canvas.drawPath(spout, Paint()..color = labShade(blue, -0.3));
    // Rose (sprinkler head) at the spout tip.
    canvas.save();
    canvas.translate(-1.9 * k, -0.8 * k);
    canvas.rotate(math.pi / 4);
    final rose = Path()
      ..moveTo(-0.16 * k, -0.1 * k)
      ..lineTo(0.16 * k, -0.1 * k)
      ..lineTo(0.38 * k, 0.28 * k)
      ..lineTo(-0.38 * k, 0.28 * k)
      ..close();
    canvas.drawPath(rose, Paint()..color = labShade(blue, -0.45));
    canvas.drawOval(Rect.fromCenter(center: Offset(0, 0.28 * k), width: 0.76 * k, height: 0.2 * k),
        Paint()..color = const Color(0xFF7DD3FC));
    canvas.restore();
    labCylinder(canvas, Rect.fromLTRB(-k, -2.5 * k, k, 0), blue, tilt: 0.22);
    canvas.restore();
    _label(canvas, 'lbl_wateringcan', c.p(canX, y + 3.6, 0));
  }

  void _paintCross(Canvas canvas) {
    final c = cam;
    labGroundShadow(canvas, c.p(0, 0, 2).translate(0, 14), 720, 38, opacity: isDark ? 0.45 : 0.18);
    // Grass top face, receding to the back.
    canvas.drawPath(
      _poly([c.p(-10, 7.2, -2), c.p(10, 7.2, -2), c.p(10, 7.2, 2), c.p(-10, 7.2, 2)]),
      Paint()..color = labShade(const Color(0xFF4ADE80), 0.08),
    );
    _bgMountain(canvas);

    Rect layer(double y0, double y1) => Rect.fromPoints(c.p(-10, y1, 2), c.p(10, y0, 2));
    final grass = layer(7, 7.2), topsoil = layer(6, 7), porous = layer(2, 6), bedrock = layer(0, 2);
    void fill(Rect r, Color col) => canvas.drawRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [labShade(col, 0.06), labShade(col, -0.12)],
            ).createShader(r),
        );
    fill(bedrock, const Color(0xFF607D8B));
    fill(porous, const Color(0xFFD7CCC8));
    fill(topsoil, const Color(0xFF5D4037));
    fill(grass, const Color(0xFF4ADE80));
    _layerTextures(canvas, topsoil, porous, bedrock);

    // Aquifer (scales up from the bedrock line).
    final ah = scene.aquiferHeight;
    if (scene.aquiferVisible && ah > 0) {
      final aq = Rect.fromPoints(c.p(-10.05, 2 + ah, 2.05), c.p(10.05, 2, 2.05));
      canvas.drawRect(aq, Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.6));
      final wave = Path()..moveTo(aq.left, aq.top);
      for (var x = aq.left; x <= aq.right; x += 6) {
        wave.lineTo(x, aq.top + math.sin(x / 16 + t * 3) * 1.6);
      }
      canvas.drawPath(
        wave,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.8),
      );
      final rnd = math.Random(9);
      for (var i = 0; i < 26; i++) {
        final x = aq.left + rnd.nextDouble() * aq.width;
        final y = aq.top + ((rnd.nextDouble() + t * 0.12) % 1.0) * aq.height;
        canvas.drawCircle(Offset(x, y), 1.4, Paint()..color = Colors.white.withValues(alpha: 0.35));
      }
    }
    // Layer outline.
    canvas.drawRect(
      Rect.fromPoints(c.p(-10, 7.2, 2), c.p(10, 0, 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.25),
    );

    // Rain (in the air) and water seeping through the soil.
    if (scene.seeping) {
      final streak = Paint()
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..color = _rainBlue.withValues(alpha: 0.9);
      // A steady shower from the cloud base down to the grass.
      final shower = math.Random(31);
      final splash = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.8);
      for (var i = 0; i < 48; i++) {
        final x = -8 + shower.nextDouble() * 6;
        final z = (shower.nextDouble() - 0.5) * 3;
        final ph = (t * 1.25 + shower.nextDouble()) % 1.0;
        final y = 9.3 - ph * 2.1;
        canvas.drawLine(c.p(x, y, z), c.p(x, y + 0.45, z), streak);
        if (ph > 0.85) {
          final g = c.p(x, 7.2, z);
          final k = c.k(x, 7.2, z);
          final u = (ph - 0.85) / 0.15;
          canvas.drawOval(Rect.fromCenter(center: g, width: (0.15 + 0.4 * u) * k, height: (0.05 + 0.12 * u) * k),
              splash..color = const Color(0xFFBAE6FD).withValues(alpha: 0.8 * (1 - u)));
        }
      }
      for (final p in scene.rain2) {
        if (p.y > 7.2) {
          canvas.drawLine(c.p(p.x, p.y, p.z), c.p(p.x, p.y + 0.4, p.z), streak);
        } else {
          final o = c.p(p.x, p.y, 2.05);
          final k = c.k(p.x, p.y, 2.05);
          canvas.drawOval(Rect.fromCenter(center: o, width: 0.16 * k, height: 0.24 * k),
              Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.85));
        }
      }
    }
    _cloud(canvas, -5, _WcScene.cloud2Y, 0, 1.5, scene.seeping ? 0.85 : 1);
    if (scene.pumpVisible) _paintPump(canvas);
    _paintS2Hints(canvas);
    _paintS2Labels(canvas);
  }

  /// Background mountain on the surface (cone r3 h4, rotated PI/4).
  void _bgMountain(Canvas canvas) {
    final c = cam;
    const mtn = Color(0xFF64748B);
    const x = 8.0, z = -1.0, by = 7.2;
    const a = 2.12;
    final apex = c.p(x, by + 4, z);
    final fl = c.p(x - a, by, z + a), fr = c.p(x + a, by, z + a), bl = c.p(x - a, by, z - a);
    canvas.drawPath(_poly([bl, fl, apex]), Paint()..color = labShade(mtn, -0.25));
    canvas.drawPath(_poly([fl, fr, apex]), Paint()..color = labShade(mtn, 0.08));
    // Snow peak (cone r1.2 h1.5 from local y 2.5 to 4).
    const s = 1.2 * 0.707;
    final sbl = c.p(x - s, by + 2.5, z - s), sfl = c.p(x - s, by + 2.5, z + s), sfr = c.p(x + s, by + 2.5, z + s);
    canvas.drawPath(_poly([sbl, sfl, apex]), Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(_poly([sfl, sfr, apex]), Paint()..color = Colors.white);
  }

  void _layerTextures(Canvas canvas, Rect topsoil, Rect porous, Rect bedrock) {
    final c = cam;
    final rnd = math.Random(4);
    // Topsoil crumbs and roots.
    for (var i = 0; i < 160; i++) {
      final o = Offset(topsoil.left + rnd.nextDouble() * topsoil.width, topsoil.top + rnd.nextDouble() * topsoil.height);
      canvas.drawCircle(o, 0.8 + rnd.nextDouble() * 1.4,
          Paint()..color = labShade(const Color(0xFF5D4037), rnd.nextDouble() * 0.5 - 0.25));
    }
    final blade = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF22C55E);
    final grassTop = c.p(0, 7.2, 2).dy;
    for (var i = 0; i < 46; i++) {
      final x = topsoil.left + 6 + i * (topsoil.width - 12) / 45 + rnd.nextDouble() * 4;
      for (var j = -1; j <= 1; j++) {
        canvas.drawLine(Offset(x, grassTop + 1), Offset(x + j * 3, grassTop - 5 - rnd.nextDouble() * 3), blade);
      }
    }
    // Sand grains in the porous layer.
    for (var i = 0; i < 420; i++) {
      final o = Offset(porous.left + rnd.nextDouble() * porous.width, porous.top + rnd.nextDouble() * porous.height);
      canvas.drawCircle(o, 0.8 + rnd.nextDouble(),
          Paint()..color = labShade(const Color(0xFFD7CCC8), rnd.nextDouble() * 0.4 - 0.3));
    }
    // Pebbles (HTML: 60 dodecahedrons, colour #888888).
    for (final pb in scene.pebbles) {
      final o = c.p(pb.x, pb.y, 2);
      final r = pb.r * c.k(pb.x, pb.y, 2) * 1.2;
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = pb.rot + i * math.pi / 3;
        final q = o + Offset(math.cos(a), math.sin(a)) * r * (i.isEven ? 1 : 0.82);
        if (i == 0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4),
            colors: [labShade(const Color(0xFF888888), 0.3 + pb.shade * 0.1), labShade(const Color(0xFF888888), -0.3)],
          ).createShader(Rect.fromCircle(center: o, radius: r)),
      );
    }
    // Bedrock joints and cracks.
    final joint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = labShade(const Color(0xFF607D8B), -0.35).withValues(alpha: 0.7);
    final midY = bedrock.center.dy;
    canvas.drawLine(Offset(bedrock.left, midY), Offset(bedrock.right, midY), joint);
    for (var i = 0; i < 12; i++) {
      final x = bedrock.left + (i + (i.isEven ? 0.3 : 0.75)) * bedrock.width / 12;
      final top = i.isEven ? bedrock.top : midY;
      canvas.drawLine(Offset(x, top), Offset(x, top + bedrock.height / 2), joint);
    }
  }

  /// Maps a pump point to the screen. The above-ground part of the pump is
  /// drawn [_pumpScale] times larger (about the pipe's ground point) so it
  /// reads clearly at phone sizes; underground points are unchanged.
  Offset _pp(double x, double y, double oy, {double z = 2.1}) {
    if (y > 7.2) {
      x = 5 + (x - 5) * _pumpScale;
      y = 7.2 + (y - 7.2) * _pumpScale;
    }
    return cam.p(x, y + oy, z);
  }

  /// Handpump with a transparent pipe down into the aquifer.
  void _paintPump(Canvas canvas) {
    final c = cam;
    final oy = scene.pumpOffset;
    const z = 2.1;
    final k = c.k(5, 8, z);
    final ks = k * _pumpScale;
    const blue = Color(0xFF2563EB);
    // Transparent pipe (y 1.5 .. ground).
    final pipe = Rect.fromPoints(c.p(4.8, 7.6 + oy, z), c.p(5.2, 1.5 + oy, z));
    canvas.drawRect(pipe, Paint()..color = Colors.white.withValues(alpha: 0.22));
    canvas.drawRect(
      pipe,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawLine(
      Offset(pipe.left + pipe.width * 0.3, pipe.top + 4),
      Offset(pipe.left + pipe.width * 0.3, pipe.bottom - 4),
      Paint()
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.4),
    );
    // Strainer at the bottom of the pipe, inside the aquifer.
    final strainer = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.55);
    for (var i = 0; i < 4; i++) {
      final y = c.p(5, 1.7 + i * 0.22 + oy, z).dy;
      canvas.drawLine(Offset(pipe.left + 1, y), Offset(pipe.right - 1, y), strainer);
    }
    // Puddle growing where the pumped water lands on the grass.
    final landed = scene.pumpWater.where((d) => d.state == 3).length;
    if (landed > 0) {
      final pr = (landed / 30).clamp(0.0, 1.0);
      final puddle = c.p(5 + 0.95 * _pumpScale, 7.2 + oy, z + 0.3);
      canvas.drawOval(
        Rect.fromCenter(center: puddle, width: (0.6 + 1.8 * pr) * k, height: (0.15 + 0.32 * pr) * k),
        Paint()..color = _rainBlue.withValues(alpha: 0.75),
      );
    }
    // Concrete platform around the pump.
    final slabL = _pp(4.35, 7.2, oy), slabR = _pp(5.95, 7.2, oy);
    labBox3D(
      canvas,
      Rect.fromLTRB(slabL.dx, slabL.dy - 0.2 * ks, slabR.dx, slabL.dy + 0.05 * ks),
      0.25 * ks,
      const Color(0xFF94A3B8),
    );
    // Water drawn up the pipe, along the spout and falling to the grass.
    final dropPaint = Paint()..color = _rainBlue;
    final dropGlow = Paint()..color = _rainBlue.withValues(alpha: 0.3);
    for (final d in scene.pumpWater) {
      if (d.state == 3) continue;
      final o = _pp(d.x, d.y, oy);
      if (d.y < 7.2) canvas.drawCircle(o, 0.22 * k, dropGlow);
      canvas.drawCircle(o, 0.12 * k, dropPaint);
    }
    // Pump body (blue cylinder y 7.2 .. 8.7), cap and spout.
    final spoutA = _pp(5, 8.55, oy), spoutB = _pp(6, 8.25, oy);
    final spout = Rect.fromPoints(spoutA, spoutB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(spout, Radius.circular(spout.height / 2)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(blue, 0.3), labShade(blue, -0.3)],
        ).createShader(spout),
    );
    // Spout mouth.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(spout.right - 0.05 * ks, spout.center.dy + 0.06 * ks), width: 0.22 * ks, height: 0.34 * ks),
      Paint()..color = labShade(blue, -0.5),
    );
    final b0 = _pp(4.6, 8.7, oy), b1 = _pp(5.4, 7.25, oy);
    labCylinder(canvas, Rect.fromPoints(b0, b1), blue, tilt: 0.18);
    // Reinforcing bands and the domed cap.
    final band = Paint()..color = labShade(blue, -0.35);
    for (final by in const [7.55, 8.35]) {
      final o = _pp(5, by, oy);
      canvas.drawRect(Rect.fromCenter(center: o, width: 0.84 * ks, height: 0.08 * ks), band);
    }
    final capC = _pp(5, 8.7, oy);
    canvas.drawPath(
      Path()
        ..moveTo(capC.dx - 0.44 * ks, capC.dy)
        ..quadraticBezierTo(capC.dx, capC.dy - 0.55 * ks, capC.dx + 0.44 * ks, capC.dy)
        ..close(),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [labShade(blue, 0.35), labShade(blue, -0.25)],
        ).createShader(Rect.fromCenter(center: capC, width: 0.9 * ks, height: 0.6 * ks)),
    );
    // Handle on its pivot (4.6, 8.6), rotated by the pumping tween.
    final pivot = _pp(4.6, 8.6, oy);
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(-scene.handleAngle);
    final handle = Rect.fromLTRB(-1.35 * ks, -0.1 * ks, 0.15 * ks, 0.1 * ks);
    canvas.drawRRect(
      RRect.fromRectAndRadius(handle, Radius.circular(0.08 * ks)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(const Color(0xFFEF4444), 0.25), labShade(const Color(0xFFEF4444), -0.3)],
        ).createShader(handle),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(-1.4 * ks, -0.14 * ks, -0.95 * ks, 0.14 * ks), Radius.circular(0.1 * ks)),
      Paint()..color = const Color(0xFF7F1D1D),
    );
    canvas.restore();
    canvas.drawCircle(pivot, 0.1 * ks, Paint()..color = _Colors.slate800);
    canvas.drawCircle(pivot, 0.04 * ks, Paint()..color = _Colors.slate400);
  }

  void _paintS2Hints(Canvas canvas) {
    final c = cam;
    if (scene.step == 2 && !scene.seeping) {
      final o = c.p(-5, _WcScene.cloud2Y + 0.2, 0);
      final k = c.k(-5, _WcScene.cloud2Y, 0);
      _hintRect(canvas, Rect.fromCenter(center: o, width: 11 * k, height: 6.6 * k), oval: true);
    } else if (scene.step == 4 && scene.pumpVisible && !scene.pumping) {
      _hintRect(canvas, scene.pumpRect.deflate(6));
    }
  }

  void _paintS2Labels(Canvas canvas) {
    final c = cam;
    if (scene.step >= 2) {
      _label(canvas, 'lbl_topsoil', c.p(-10, 6.5, 2.5));
      _label(canvas, 'lbl_porous', c.p(-10, 4, 2.5));
      _label(canvas, 'lbl_bedrock', c.p(-10, 1, 2.5));
    }
    if (scene.step == 2 && !scene.seeping) _process(canvas, 'lbl_cloud', c.p(0.8, _WcScene.cloud2Y + 1.6, 0));
    if (scene.seeping) _process(canvas, 'lbl_infiltration', c.p(-4.6, 4.9, 2.5));
    if (scene.step >= 4 && scene.aquiferLabel) {
      _label(
        canvas,
        'lbl_aquifer',
        c.p(-6, 2.5, 2.5),
        bg: const Color(0xE60284C7),
        border: const Color(0xFF075985),
      );
    }
    if (scene.pumpVisible) _label(canvas, 'lbl_handpump', c.p(2.3, 10.5 + scene.pumpOffset, 2.1));
  }

  @override
  bool shouldRepaint(covariant _WcPainter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

// ============================================================ TOOLBOX ICONS

/// The toolbox Sun icon (HTML inline SVG, 24x24 view box).
class _SunIconPainter extends CustomPainter {
  const _SunIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    const c = Offset(12, 12);
    final ray = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF94A3B8);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final u = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + u * 7.4, c + u * 9.5, ray);
    }
    canvas.drawCircle(c, 4, Paint()..color = _theme);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The toolbox Watering Can icon.
class _CanIconPainter extends CustomPainter {
  const _CanIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    const grey = Color(0xFF94A3B8);
    canvas.drawPath(
      Path()
        ..moveTo(17.5, 12.5)
        ..cubicTo(22, 12.5, 22, 19.5, 17.5, 19.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = labShade(_theme, -0.25),
    );
    canvas.drawLine(
      const Offset(9, 15.5),
      const Offset(3.2, 9.6),
      Paint()
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = _theme,
    );
    canvas.drawOval(Rect.fromCenter(center: const Offset(2.8, 9.2), width: 3.4, height: 2), Paint()..color = labShade(_theme, -0.2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(8, 11, 18, 21), const Radius.circular(2.2)),
      Paint()..color = _theme,
    );
    canvas.drawRect(const Rect.fromLTRB(8, 11, 18, 12.4), Paint()..color = labShade(_theme, 0.25));
    final drop = Paint()..color = grey;
    canvas.drawCircle(const Offset(1.6, 13.4), 0.9, drop);
    canvas.drawCircle(const Offset(3.6, 14.6), 0.9, drop);
    canvas.drawCircle(const Offset(1.4, 16.6), 0.9, drop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dashed rounded border of the HTML `#global-drop-zone`.
class _DropZonePainter extends CustomPainter {
  const _DropZonePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24));
    canvas.drawRRect(rr, Paint()..color = color.withValues(alpha: 0.2));
    labDashedPath(
      canvas,
      Path()..addRRect(rr.deflate(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color.withValues(alpha: 0.6),
      dash: 14,
      gap: 9,
    );
  }

  @override
  bool shouldRepaint(covariant _DropZonePainter oldDelegate) => oldDelegate.color != color;
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
