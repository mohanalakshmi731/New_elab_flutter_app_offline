// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 4 • Activity 1
/// Investigating Physical Properties of Materials.
///
/// Native Flutter port of
/// `Cl7S-Ch4-A1-Investigating_Physical_Properties_of_Materials.html`.
/// Scenario 1 (The Hammer Test): drag or click a material from the
/// MATERIALS tray onto the anvil and click the hammer: metals flatten
/// (malleable), coal and sulfur shatter (brittle) and wood only dents.
/// Scenario 2 (Circuit Challenge): drop a material into the gap between
/// the alligator clips; conductors light the bulb, insulators do not.
/// Testing all six materials opens the conclusion with the classification.
class Ch4A1InvestigatingPhysicalPropertiesOfMaterialsPage extends StatefulWidget {
  const Ch4A1InvestigatingPhysicalPropertiesOfMaterialsPage({super.key});

  @override
  State<Ch4A1InvestigatingPhysicalPropertiesOfMaterialsPage> createState() =>
      _Ch4A1InvestigatingPhysicalPropertiesOfMaterialsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, spark 2365.
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
  spark('spark.mp3');

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
  static const Color green600 = Color(0xFF16A34A);
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

class _Ch4A1InvestigatingPhysicalPropertiesOfMaterialsPageState
    extends State<Ch4A1InvestigatingPhysicalPropertiesOfMaterialsPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;
  final math.Random _rnd = math.Random();

  /// HTML `scenarioCompletedFlags`: the conclusion pops up only once.
  final Set<int> _completedOnce = {};

  String _t(String key) => _lab.tr(_i18n, key);
  String _mat(_Mat m) => _t('mat_${m.name}');
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _scene.comics.removeWhere((c) => _scene.time - c.born > 4);
      _frame.value = _scene.time;
    })..start();
    _loadScenario(0, animateCamera: false);
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

  // ---------------------------------------------------------------- logic

  void _hud(String title, String status, String instr, {_Mat? mat, String suffix = ''}) {
    _scene
      ..hudTitleKey = title
      ..hudTitleMat = mat
      ..hudTitleSuffix = suffix
      ..hudStatus = status
      ..hudInstr = instr;
  }

  /// HTML `clearScene()` (test item, hammer, effects, floating labels).
  void _clearScene() {
    _scene
      ..active = null
      ..hammerVisible = false
      ..clickLabel = false
      ..strikeStart = -10
      ..effect = 0
      ..shards = const []
      ..bulbOn = false
      ..dropStart = -10;
    _scene.comics.clear();
  }

  /// HTML `loadScenario(scenId)`.
  void _loadScenario(int index, {bool animateCamera = true}) {
    final s = _scene;
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    s.camFromScenario = animateCamera ? s.scenario : index;
    s
      ..scenario = index
      ..task = 'idle'
      ..nextBtn = false;
    s.tested.clear();
    s.results[index].clear();
    _clearScene();
    final view = _views[index];
    if (animateCamera) s.moveCamera(view.$1, view.$2, view.$3);
    if (index == 0) {
      _hud('hud_phase1', 'hud_status_action', 'hud_idle_s1');
    } else {
      _hud('hud_phase2', 'hud_status_action', 'hud_idle_s2');
    }
  }

  void _changeScenario(int index) => setState(() => _loadScenario(index));

  void _fullReset() {
    setState(() {
      _completedOnce.clear();
      _scene.moveCamera(_introEye, _introTarget, 1, animate: false);
      _loadScenario(0, animateCamera: false);
    });
  }

  void _onEnterLab() {
    final view = _views[_scene.scenario];
    _scene.camFromScenario = _scene.scenario;
    _scene.moveCamera(view.$1, view.$2, view.$3);
  }

  /// Width of the MATERIALS tray overlay.
  static double _trayWidth(double s) => (128 * s).clamp(112.0, 170.0);

  /// Centres the camera in the canvas area left of the MATERIALS tray (the
  /// stage is scaled to fit [canvas], so convert screen px to design units).
  void _fitView(Size canvas, double s, double padRight) {
    if (canvas.isEmpty) return;
    final k = math.min(canvas.width / _design.width, canvas.height / _design.height);
    final x0 = (canvas.width - _design.width * k) / 2;
    const freeL = 8.0;
    final freeR = math.max(freeL + 60, canvas.width - (56 + padRight + 2 + _trayWidth(s) + 10));
    _scene
      ..viewCx = (((freeL + freeR) / 2 - x0) / k).clamp(280.0, 470.0)
      ..freeW = (freeR - freeL) / k;
  }

  bool get _blocked => const ['testing', 'animating', 'tested'].contains(_scene.task);

  /// HTML `handleMaterialSelection(matKey)` (tray click or drop on canvas).
  void _selectMaterial(_Mat m) {
    if (_blocked) return;
    _Audio.play(_Sound.click);
    final s = _scene;
    setState(() {
      s
        ..active = m
        ..task = 'placed'
        ..effect = 0
        ..shards = const []
        ..dropStart = s.time;
      if (s.scenario == 0) {
        // placeMaterialOnAnvil: drops from y 10 to 4.6 (Bounce.Out 500 ms).
        s
          ..dropFrom = 10
          ..dropTo = 4.6
          ..dropDur = 0.5
          ..dropBounce = true
          ..hammerVisible = true
          ..strikeStart = -10
          ..clickLabel = true;
        _hud('hud_testing', 'hud_status_ready', 'hud_test_s1', mat: m);
      } else {
        // placeMaterialInCircuit: drops into the gap (Quadratic.Out 300 ms).
        s
          ..dropFrom = 3
          ..dropTo = 0.6
          ..dropDur = 0.3
          ..dropBounce = false
          ..bulbOn = false
          ..task = 'animating';
        _hud('hud_testing', 'hud_status_obs', 'hud_test_s2', mat: m);
        _lab.after(const Duration(milliseconds: 300), () => _circuitResult(m));
      }
    });
  }

  /// End of the circuit drop tween: bulb + GOOD / POOR CONDUCTOR label.
  void _circuitResult(_Mat m) {
    if (!mounted || _scene.active != m || _scene.scenario != 1) return;
    final s = _scene;
    setState(() {
      if (_matData[m]!.conductor) {
        _Audio.play(_Sound.spark);
        s
          ..bulbOn = true
          ..bulbStart = s.time;
        s.comics.add(_Comic('lbl_good_cond', 1, const _V3(0, 3, -1.5), s.time));
      } else {
        _Audio.play(_Sound.wrong);
        s.comics.add(_Comic('lbl_poor_cond', 2, const _V3(0, 3, -1.5), s.time));
      }
    });
    _lab.after(const Duration(milliseconds: 1500), () {
      if (mounted && _scene.active == m) setState(_validateInvestigation);
    });
  }

  /// HTML `triggerHammer()` + `animateHammerStrike()`.
  void _triggerHammer() {
    final s = _scene;
    if (s.task != 'placed' || s.active == null) return;
    final m = s.active!;
    setState(() {
      s
        ..task = 'animating'
        ..clickLabel = false
        ..strikeStart = s.time;
      _hud('hud_status_testing', 'hud_status_testing', 'hud_applying', suffix: '...');
    });
    _lab.after(const Duration(milliseconds: 150), () {
      if (!mounted || s.active != m) return;
      _Audio.play(_Sound.drop);
      setState(() {
        final d = _matData[m]!;
        s.effectStart = s.time;
        if (m == _Mat.wood) {
          s.effect = 3;
          s.comics
            ..add(_Comic('lbl_neither', 3, const _V3(-1, 8, 0), s.time))
            ..add(_Comic('lbl_thud', 0, const _V3(0, 9, 2), s.time));
        } else if (d.malleable) {
          s.effect = 1;
          s.comics
            ..add(_Comic('lbl_malleable', 1, const _V3(-3, 8, 0), s.time))
            ..add(_Comic('lbl_clang', 0, const _V3(0, 9, 2), s.time));
        } else {
          _Audio.play(_Sound.pop);
          s.effect = 2;
          final o = s.itemPos();
          s.shards = [
            for (var i = 0; i < 8; i++)
              () {
                final from = o + _V3(_rnd.nextDouble() - 0.5, 0, _rnd.nextDouble() - 0.5);
                return _Shard(
                  from,
                  _V3(from.x + (_rnd.nextDouble() - 0.5) * 2, 4.5, from.z + (_rnd.nextDouble() - 0.5) * 2),
                  0.2 + _rnd.nextDouble() * 0.2,
                  _rnd.nextDouble() * math.pi * 2,
                );
              }(),
          ];
          s.comics
            ..add(_Comic('lbl_brittle', 2, const _V3(3, 8, 0), s.time))
            ..add(_Comic('lbl_crack', 0, const _V3(0, 9, 2), s.time));
        }
      });
    });
    // Hammer lifts back after 400 ms (+400 ms tween) and hides.
    _lab.after(const Duration(milliseconds: 950), () {
      if (!mounted || s.active != m) return;
      setState(() {
        s
          ..hammerVisible = false
          ..task = 'tested';
        final res = m == _Mat.wood ? 'res_wood_s1' : (_matData[m]!.malleable ? 'res_malleable' : 'res_brittle');
        _hud('hud_status_result', 'hud_status_result', res);
      });
      _lab.after(const Duration(seconds: 1), () {
        if (mounted && _scene.active == m) setState(_validateInvestigation);
      });
    });
  }

  /// HTML `validateInvestigation()`.
  void _validateInvestigation() {
    final s = _scene;
    final m = s.active;
    if (m == null) return;
    final d = _matData[m]!;
    _Audio.play(_Sound.correct);
    s.tested.add(m);
    if (s.scenario == 0) {
      if (m == _Mat.wood) {
        s.results[0][m] = 'r_neither';
        _lab.showToast(_t('toast_wood_s1'), sound: false);
      } else if (d.malleable) {
        s.results[0][m] = 'r_malleable';
        _lab.showToast(_mat(m) + _t('toast_malleable'), sound: false);
      } else {
        s.results[0][m] = 'r_brittle';
        _lab.showToast(_mat(m) + _t('toast_brittle'), isError: true, sound: false);
      }
    } else {
      if (d.conductor) {
        s.results[1][m] = 'r_conductor';
        _lab.showToast(_mat(m) + _t('toast_cond'), sound: false);
      } else {
        s.results[1][m] = 'r_insulator';
        _lab.showToast(_mat(m) + _t('toast_insul'), isError: true, sound: false);
      }
      s.task = 'tested';
    }
    s.nextBtn = true;
    if (s.tested.length == _Mat.values.length) {
      _hud('hud_status_done', 'hud_status_done', 'scenario_complete', suffix: '!');
      final scen = s.scenario;
      if (_completedOnce.add(scen)) {
        _lab.after(const Duration(seconds: 2), () {
          if (mounted && _scene.scenario == scen) _showConclusion(scen);
        });
      }
    }
  }

  /// HTML `resetAnvilState()` ("Reset Anvil" / "Next Material").
  void _resetAnvilState() {
    final s = _scene;
    setState(() {
      s
        ..nextBtn = false
        ..task = 'idle';
      _clearScene();
      _hud('btn_next_mat', 'hud_status_action', s.scenario == 0 ? 'hud_idle_s1' : 'hud_idle_s2');
    });
  }

  /// The HTML completion popup (classification table + final conclusion).
  void _showConclusion(int scen) {
    _lab.completedScenarios.add(scen);
    _lab.openSidebar();
    _lab.showPopup(() {
      final allDone = _lab.completedScenarios.length >= 2;
      return LabPopupContent(
        title: _t('observation'),
        icon: Icons.lightbulb,
        extra: _conclusionView(scen),
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
      );
    });
  }

  // ------------------------------------------------------------ gestures

  /// HTML raycast on the hammer or the test item (scenario 1, "placed").
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    if (s.scenario != 0 || s.task != 'placed') return;
    final v = s.view();
    final pos = d.localPosition;
    final ang = s.hammerAngle() ?? 120;
    final dir = _hammerDir(ang);
    final a = v.p(_pivot - dir * 0.5), b = v.p(_pivot + dir * _handleLen);
    final ab = b - a;
    final t = (((pos - a).dx * ab.dx + (pos - a).dy * ab.dy) / (ab.dx * ab.dx + ab.dy * ab.dy)).clamp(0.0, 1.0);
    final nearHandle = (pos - (a + ab * t)).distance < 24;
    final k = v.k(_pivot);
    final nearHead = (pos - b).distance < 1.3 * k;
    final nearItem = (pos - v.p(s.itemPos())).distance < 1.4 * k;
    if (nearHandle || nearHead || nearItem) _triggerHammer();
  }

  // ------------------------------------------------------------------ UI

  /// Step shown in the target card (the HTML step boxes are static; this
  /// follows the progress through them).
  int _currentStep() {
    final s = _scene;
    final n = s.tested.length;
    final busy = s.task == 'placed' || s.task == 'animating' || (s.task == 'tested' && !s.nextBtn);
    if (s.scenario == 0) {
      if (n >= _Mat.values.length) return 6;
      if (n == 0) return busy ? 2 : 1;
      if (n == 1) return busy ? 4 : 3;
      return 5;
    }
    if (n >= _Mat.values.length) return 4;
    if (n == 0) return busy ? 2 : 1;
    return 3;
  }

  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.scenario == 0 && s.task == 'placed')
        LabAction(label: _t('lbl_click_strike'), icon: Icons.gavel, highlight: true, onTap: _triggerHammer),
      if (s.nextBtn)
        LabAction(
          label: s.scenario == 0 ? _t('btn_reset_anvil') : _t('btn_next_mat'),
          icon: s.scenario == 0 ? Icons.restart_alt : Icons.arrow_forward,
          color: _Colors.slate800,
          foreground: Colors.white,
          highlight: true,
          onTap: _resetAnvilState,
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
        final done = _scene.tested.length == _Mat.values.length;
        return LabShell(
          controller: _lab,
          icon: Icons.handyman,
          title: _t('title'),
          subtitle: _t('subtitle'),
          scenarioNames: [_t('s1_title'), _t('s2_title')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _currentStep(),
          instruction: done ? _t('scenario_complete') : null,
          actions: _actions(),
          sidebarExtraTitle: _t('results_title'),
          sidebarExtra: _resultsPanel(p, s),
          onReset: _fullReset,
          onEnterLab: _onEnterLab,
          showHud: false,
          overlays: [_trayOverlay(p, s), _bottomOverlay(p, s)],
          stage: LayoutBuilder(
            builder: (context, box) {
              _fitView(box.biggest, s, MediaQuery.paddingOf(context).right);
              return LabStage(
                designSize: _design,
                child: DragTarget<_Mat>(
                  onAcceptWithDetails: (d) => _selectMaterial(d.data),
                  builder: (context, candidates, _) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: _onTapUp,
                    child: CustomPaint(
                      size: _design,
                      painter: _LabPainter(
                        scene: _scene,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        tr: _i18n[_lab.lang.code]!,
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

  static const ColorFilter _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  /// HTML `#materials-panel`: wooden tray of draggable / clickable materials.
  Widget _trayOverlay(LabPalette p, double s) {
    final inset = labOverlayInsets(context, _lab);
    final h = MediaQuery.sizeOf(context).height;
    final w = _trayWidth(s);
    final itemW = (w - 14 * s - 6 - 6) / 2;
    final mats = _Mat.values;
    return Positioned(
      top: inset.top + 2,
      right: inset.right + 2,
      child: Container(
        width: w,
        constraints: BoxConstraints(maxHeight: h * 0.62),
        decoration: BoxDecoration(
          color: const Color(0xFFD4A373),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B5A2B), width: 3),
          boxShadow: const [BoxShadow(color: Color(0x66000000), offset: Offset(4, 4))],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(7 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 4 * s),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF8B5A2B), width: 2)),
                ),
                child: Text(
                  _t('materialsTitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF4A3018),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 11 * s,
                  ),
                ),
              ),
              SizedBox(height: 6 * s),
              for (var r = 0; r < mats.length; r += 2) ...[
                if (r > 0) SizedBox(height: 6 * s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _trayItem(mats[r], s, itemW)),
                    const SizedBox(width: 6),
                    Expanded(child: _trayItem(mats[r + 1], s, itemW)),
                  ],
                ),
              ],
              SizedBox(height: 6 * s),
              Container(
                padding: EdgeInsets.symmetric(vertical: 3 * s, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6C280),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF8B5A2B)),
                ),
                child: Text(
                  _t('clickOrDrag').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF5C3A21), fontWeight: FontWeight.w800, fontSize: 8.5 * s),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trayItem(_Mat m, double s, double itemW) {
    final tested = _scene.tested.contains(m);
    final active = _scene.active == m;
    final canDrag = !_blocked && !tested;
    final (icon, iconColor) = _matIcon[m]!;
    Widget card({bool lifted = false}) => Container(
      height: 50 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? _Colors.zslYellow : const Color(0xFFA0A0A0), width: active ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.5 : 0.1),
            offset: lifted ? const Offset(0, 8) : const Offset(2, 2),
            blurRadius: lifted ? 18 : 0,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: tested ? _grayscale : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: Opacity(
              opacity: tested ? 0.5 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 19 * s, color: iconColor),
                    SizedBox(height: 2 * s),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _mat(m).toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w800,
                          fontSize: 8.5 * s,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (tested)
            DecoratedBox(
              decoration: BoxDecoration(
                color: _Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.check_circle, color: _Colors.green600, size: 20 * s),
            ),
        ],
      ),
    );
    return Draggable<_Mat>(
      data: m,
      maxSimultaneousDrags: canDrag ? 1 : 0,
      onDragStarted: () => _Audio.play(_Sound.pickup),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
          child: Transform.scale(
            scale: 1.1,
            child: SizedBox(width: itemW, child: card(lifted: true)),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: card()),
      child: GestureDetector(onTap: () => _selectMaterial(m), child: card()),
    );
  }

  /// HTML "Reset Anvil" / "Next Material" button above the bottom HUD
  /// (title, status chip and instruction / coloured result).
  Widget _bottomOverlay(LabPalette p, double s) {
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final sc = _scene;
    final title = _t(sc.hudTitleKey) + (sc.hudTitleMat != null ? _mat(sc.hudTitleMat!) : '') + sc.hudTitleSuffix;
    final status = sc.hudStatus;
    final statusColor = switch (status) {
      'hud_status_action' => const Color(0xFF60A5FA),
      'hud_status_testing' || 'hud_status_obs' => const Color(0xFFFACC15),
      'hud_status_done' || 'hud_status_result' => const Color(0xFF4ADE80),
      _ => const Color(0xFF9CA3AF),
    };
    final instrColor = switch (sc.hudInstr) {
      'res_wood_s1' => const Color(0xFFD97706),
      'res_malleable' => p.isDark ? const Color(0xFF4ADE80) : _Colors.green600,
      'res_brittle' => p.isDark ? const Color(0xFFF87171) : _Colors.red600,
      _ => p.textStrong,
    };
    final isResult = sc.hudInstr.startsWith('res_');
    return Positioned(
      left: inset.left,
      right: inset.right,
      bottom: 8 + pad.bottom,
      child: LayoutBuilder(
        builder: (context, box) => box.maxWidth < 170 * s
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sc.nextBtn) ...[
                    Material(
                      color: const Color(0xFF1F2937),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF9CA3AF), width: 3),
                      ),
                      elevation: 6,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _Audio.play(_Sound.click);
                          _resetAnvilState();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 8 * s),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restart_alt, color: Colors.white, size: 18 * s),
                              SizedBox(width: 6 * s),
                              Flexible(
                                child: Text(
                                  (sc.scenario == 0 ? _t('btn_reset_anvil') : _t('btn_next_mat')).toUpperCase(),
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14 * s),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * s),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 540 * s),
                    child: IgnorePointer(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                        decoration: BoxDecoration(
                          color: p.isDark ? const Color(0xE60F172A) : const Color(0xE6FFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.3)),
                          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18)],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _Colors.zslYellow,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      fontSize: 11 * s,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8 * s),
                                // Capped and scaled so the row never overflows
                                // while the canvas narrows (sidebar animating).
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: math.max(0.0, (math.min(box.maxWidth, 540 * s) - 28 * s) * 0.5),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _t(status),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontFamily: LabFont.active.family ?? 'monospace',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10 * s,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4 * s),
                            Text(
                              _t(sc.hudInstr),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: instrColor,
                                fontWeight: isResult ? FontWeight.w800 : FontWeight.w500,
                                fontSize: 12 * s,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  (String, Color) _resultChip(String? key, LabPalette p) => switch (key) {
    'r_malleable' || 'r_conductor' => (_t(key!), _Colors.green),
    'r_brittle' || 'r_insulator' => (_t(key!), _Colors.red),
    'r_neither' => (_t(key!), const Color(0xFFD97706)),
    _ => (_t('r_pending'), p.textMuted),
  };

  /// Sidebar readout: which materials are tested and how they behaved.
  Widget _resultsPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final res = _scene.results[_scene.scenario];
    final n = _scene.tested.length;
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
            labFormat(_t('tested_n'), {'n': n}),
            style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12 * f),
          ),
          SizedBox(height: 5 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: n / _Mat.values.length,
              minHeight: 5 * s,
              color: _Colors.zslYellow,
              backgroundColor: p.cardBorder,
            ),
          ),
          SizedBox(height: 6 * s),
          for (final m in _Mat.values)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3 * s),
              child: Row(
                children: [
                  Icon(
                    _matIcon[m]!.$1,
                    size: 15 * f,
                    color: _matIcon[m]!.$2 == const Color(0xFF111827) && p.isDark
                        ? _Colors.slate400
                        : _matIcon[m]!.$2,
                  ),
                  SizedBox(width: 6 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mat(m),
                          style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w700, fontSize: 11.5 * f),
                        ),
                        Text(
                          _matData[m]!.metal ? _t('metal') : _t('nonmetal'),
                          style: TextStyle(color: p.textMuted, fontSize: 9.5 * f),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Flexible(
                    child: Builder(
                      builder: (context) {
                        final (label, color) = _resultChip(res[m], p);
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 9.5 * f),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<TextSpan> _rich(String text, TextStyle bold) {
    final parts = text.split('**');
    return [for (var i = 0; i < parts.length; i++) TextSpan(text: parts[i], style: i.isOdd ? bold : null)];
  }

  /// HTML `getConclusionHTML(scenario)`.
  Widget _conclusionView(int scen) {
    final s = context.labScale;
    final p = _Theme.of(_lab.isDark);
    final fs = 12.5 * s * _lab.fontScale.clamp(0.9, 1.4);
    final left = scen == 0 ? 'lbl_malleable' : 'lbl_good_cond';
    final right = scen == 0 ? 'lbl_brittle' : 'lbl_poor_cond';
    const leftMats = [_Mat.iron, _Mat.copper, _Mat.aluminium];
    final rightMats = scen == 0 ? const [_Mat.coal, _Mat.sulfur] : const [_Mat.wood, _Mat.coal, _Mat.sulfur];
    Widget column(String key, Color color, List<_Mat> mats) => Padding(
      padding: EdgeInsets.all(8 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(4 * s),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(
              _t(key).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12 * s),
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            mats.map(_mat).join(', '),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text, fontSize: fs * 0.95, height: 1.4),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: column(left, _Colors.green, leftMats)),
            Container(width: 1, height: 70 * s, color: p.cardBorder),
            Expanded(child: column(right, _Colors.red, rightMats)),
          ],
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0x801F2937) : _Colors.slate100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_t('conclusionHeading')}:\n',
                  style: const TextStyle(color: _Colors.zslYellow, fontWeight: FontWeight.w800),
                ),
                ..._rich(_t('concl_s${scen + 1}_text'), const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            style: TextStyle(color: p.text, fontSize: fs, height: 1.5),
          ),
        ),
      ],
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'title': 'Investigating Physical Properties of Materials',
    'subtitle': 'Class 7 • The World of Metals and Non-metals',
    'observation': 'Observation',
    'materialsTitle': 'MATERIALS',
    'clickOrDrag': 'Click or Drag',
    's1_title': '1. The Hammer Test: Malleable or Brittle?',
    's2_title': '2. Circuit Challenge: Conductor or Insulator?',
    'conclusionHeading': 'Final Conclusion',
    'mat_iron': 'Iron Nail',
    'mat_copper': 'Copper',
    'mat_aluminium': 'Aluminium',
    'mat_coal': 'Coal',
    'mat_sulfur': 'Sulfur',
    'mat_wood': 'Wood',
    'hud_idle_s1': 'DRAG a material from the tray (top right) and DROP on the anvil.',
    'hud_idle_s2': 'DRAG a material from the tray to bridge the gap in the circuit.',
    'hud_test_s1': 'CLICK the 3D Hammer to strike the material!',
    'hud_test_s2': 'Observing the circuit completion...',
    'hud_phase1': 'Material Testing Phase',
    'hud_phase2': 'Conductivity Test',
    'hud_testing': 'Testing: ',
    'hud_status_action': 'Action Required',
    'hud_status_ready': 'Ready',
    'hud_status_obs': 'Observation',
    'hud_status_testing': 'Testing',
    'hud_status_result': 'Result',
    'hud_status_done': 'Done',
    'hud_applying': 'Applying force...',
    'res_wood_s1': 'Dented. Neither Malleable nor Brittle.',
    'res_malleable': 'Flattened! It is Malleable.',
    'res_brittle': 'Shattered! It is Brittle.',
    'btn_reset_anvil': 'Reset Anvil',
    'btn_next_mat': 'Next Material',
    'toast_wood_s1': 'Wood is Neither Malleable nor Brittle.',
    'toast_malleable': ' is Malleable!',
    'toast_brittle': ' is Brittle!',
    'toast_cond': ' conducts electricity!',
    'toast_insul': ' is an insulator.',
    'scenario_complete': 'All materials tested successfully. Feel free to keep exploring!',
    'concl_s1_text':
        'Metals like iron, copper, and aluminium can be hammered into thin sheets. This property is called **Malleability**. Non-metals like coal and sulfur are **brittle** and break into pieces. Wood is neither.',
    'concl_s2_text':
        'Metals are **good conductors** of electricity, allowing it to pass through them. Non-metals are generally **poor conductors** (insulators) of electricity.',
    'lbl_anvil': 'ANVIL',
    'lbl_battery': 'BATTERY',
    'lbl_bulb': 'BULB',
    'lbl_clips': 'OPEN CLIPS',
    'lbl_good_cond': 'GOOD CONDUCTOR',
    'lbl_poor_cond': 'POOR CONDUCTOR',
    'lbl_malleable': 'MALLEABLE',
    'lbl_brittle': 'BRITTLE',
    'lbl_neither': 'NEITHER MALLEABLE NOR BRITTLE',
    'lbl_click_strike': 'CLICK HERE TO STRIKE',
    'lbl_thud': 'THUD!',
    'lbl_clang': 'CLANG!',
    'lbl_crack': 'CRACK!',
    // Added for the native port (sidebar results readout).
    'results_title': 'Test Results',
    'tested_n': '{n} / 6 tested',
    'r_malleable': 'Malleable',
    'r_brittle': 'Brittle',
    'r_neither': 'Neither',
    'r_conductor': 'Conductor',
    'r_insulator': 'Insulator',
    'r_pending': 'Not tested',
    'metal': 'Metal',
    'nonmetal': 'Non-metal',
  },
  'hi': {
    'title': 'पदार्थों के भौतिक गुणों की जांच',
    'subtitle': 'कक्षा 7 • धातु और अधातु की दुनिया',
    'observation': 'अवलोकन',
    'materialsTitle': 'सामग्री',
    'clickOrDrag': 'क्लिक करें या खींचें',
    's1_title': '1. हथौड़ा परीक्षण: आघातवर्ध्य या भंगुर?',
    's2_title': '2. परिपथ चुनौती: सुचालक या कुचालक?',
    'conclusionHeading': 'अंतिम निष्कर्ष',
    'mat_iron': 'लोहे की कील',
    'mat_copper': 'तांबा',
    'mat_aluminium': 'एल्युमिनियम',
    'mat_coal': 'कोयला',
    'mat_sulfur': 'गंधक',
    'mat_wood': 'लकड़ी',
    'hud_idle_s1': 'ट्रे (ऊपर दाईं ओर) से सामग्री खींचें और निहाई पर छोड़ें।',
    'hud_idle_s2': 'परिपथ में गैप को पाटने के लिए ट्रे से एक सामग्री खींचें।',
    'hud_test_s1': 'सामग्री पर वार करने के लिए 3D हथौड़े पर क्लिक करें!',
    'hud_test_s2': 'परिपथ के पूरा होने का अवलोकन किया जा रहा है...',
    'hud_phase1': 'सामग्री परीक्षण चरण',
    'hud_phase2': 'चालकता परीक्षण',
    'hud_testing': 'परीक्षण: ',
    'hud_status_action': 'कार्रवाई आवश्यक',
    'hud_status_ready': 'तैयार',
    'hud_status_obs': 'अवलोकन',
    'hud_status_testing': 'परीक्षण हो रहा है',
    'hud_status_result': 'परिणाम',
    'hud_status_done': 'संपन्न',
    'hud_applying': 'बल लगाया जा रहा है...',
    'res_wood_s1': 'धंस गया। ना आघातवर्ध्य ना भंगुर।',
    'res_malleable': 'चपटा हो गया! यह आघातवर्ध्य है।',
    'res_brittle': 'टूट गया! यह भंगुर है।',
    'btn_reset_anvil': 'निहाई रीसेट करें',
    'btn_next_mat': 'अगली सामग्री',
    'toast_wood_s1': 'लकड़ी ना आघातवर्ध्य है ना भंगुर।',
    'toast_malleable': ' आघातवर्ध्य है!',
    'toast_brittle': ' भंगुर है!',
    'toast_cond': ' बिजली का संचालन करता है!',
    'toast_insul': ' कुचालक (इन्सुलेटर) है।',
    'scenario_complete': 'सभी सामग्रियों का सफलतापूर्वक परीक्षण किया गया। बेझिझक आगे खोजना जारी रखें!',
    'concl_s1_text':
        'लोहे, तांबे और एल्यूमीनियम जैसी धातुओं को हथौड़े से पीटकर पतली चादरों में बदला जा सकता है। इस गुण को **आघातवर्ध्यता (Malleability)** कहा जाता है। कोयले और गंधक जैसी अधातुएँ **भंगुर (brittle)** होती हैं और टुकड़ों में टूट जाती हैं। लकड़ी दोनों में से कुछ भी नहीं है।',
    'concl_s2_text':
        'धातुएं बिजली की **सुचालक (good conductors)** होती हैं, जिससे बिजली उनके माध्यम से गुजर सकती है। अधातुएँ आमतौर पर बिजली की **कुचालक (insulators)** होती हैं।',
    'lbl_anvil': 'निहाई',
    'lbl_battery': 'बैटरी',
    'lbl_bulb': 'बल्ब',
    'lbl_clips': 'खुले क्लिप्स',
    'lbl_good_cond': 'सुचालक',
    'lbl_poor_cond': 'कुचालक',
    'lbl_malleable': 'आघातवर्ध्य',
    'lbl_brittle': 'भंगुर',
    'lbl_neither': 'ना आघातवर्ध्य ना भंगुर',
    'lbl_click_strike': 'वार करने के लिए यहाँ क्लिक करें',
    'lbl_thud': 'धप!',
    'lbl_clang': 'टन!',
    'lbl_crack': 'कड़क!',
    'results_title': 'परीक्षण परिणाम',
    'tested_n': '{n} / 6 परीक्षित',
    'r_malleable': 'आघातवर्ध्य',
    'r_brittle': 'भंगुर',
    'r_neither': 'दोनों नहीं',
    'r_conductor': 'सुचालक',
    'r_insulator': 'कुचालक',
    'r_pending': 'परीक्षण बाकी',
    'metal': 'धातु',
    'nonmetal': 'अधातु',
  },
};

/// Bold segments in the conclusion texts are marked with `**` (the HTML
/// used `<strong>`).

enum _Mat { iron, copper, aluminium, coal, sulfur, wood }

enum _Model { nail, wire, foil, rock, wood }

/// HTML `MATERIALS_DATA`.
const Map<_Mat, ({bool metal, bool malleable, bool conductor, Color color, _Model model})> _matData = {
  _Mat.iron: (metal: true, malleable: true, conductor: true, color: Color(0xFF888888), model: _Model.nail),
  _Mat.copper: (metal: true, malleable: true, conductor: true, color: Color(0xFFC87E3A), model: _Model.wire),
  _Mat.aluminium: (metal: true, malleable: true, conductor: true, color: Color(0xFFD3D3D3), model: _Model.foil),
  _Mat.coal: (metal: false, malleable: false, conductor: false, color: Color(0xFF222222), model: _Model.rock),
  _Mat.sulfur: (metal: false, malleable: false, conductor: false, color: Color(0xFFCCCC22), model: _Model.rock),
  _Mat.wood: (metal: false, malleable: false, conductor: false, color: Color(0xFF8B5A2B), model: _Model.wood),
};

/// Tray icons / colours (HTML Phosphor icons and Tailwind text colours).
const Map<_Mat, (IconData, Color)> _matIcon = {
  _Mat.iron: (Icons.push_pin, Color(0xFF4B5563)),
  _Mat.copper: (Icons.cyclone, Color(0xFFF97316)),
  _Mat.aluminium: (Icons.crop_square, Color(0xFF9CA3AF)),
  _Mat.coal: (Icons.hexagon, Color(0xFF111827)),
  _Mat.sulfur: (Icons.hexagon, Color(0xFFEAB308)),
  _Mat.wood: (Icons.forest, Color(0xFFB45309)),
};

const String _act1En = 'Activity 4.1: The Hammer Test';
const String _act2En = 'Activity 4.4: Electrical Conduction';
const String _act1Hi = 'गतिविधि 4.1: हथौड़ा परीक्षण';
const String _act2Hi = 'गतिविधि 4.4: विद्युत चालन';
const String _th1En =
    'Metals like iron are heated and hammered into strong shapes to make tools because they are malleable.';
const String _th2En = 'Metals are generally good conductors of electricity, allowing power to flow safely.';
const String _th1Hi =
    'लोहे जैसी धातुओं को गर्म करके और हथौड़े से पीटकर मजबूत आकार में ढाला जाता है ताकि औजार बनाए जा सकें क्योंकि वे आघातवर्ध्य होती हैं।';
const String _th2Hi = 'धातुएं आमतौर पर बिजली की सुचालक होती हैं, जिससे बिजली सुरक्षित रूप से प्रवाहित हो सकती है।';

/// HTML `s1_theory` / `s2_theory` step boxes.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually determine if different materials are malleable (flatten) or brittle (break) by striking them with a hammer.',
      steps: [
        LabStep(concept: _act1En, action: 'DRAG iron nail to anvil.', observation: _th1En),
        LabStep(concept: _act1En, action: 'CLICK hammer to strike.', observation: _th1En),
        LabStep(concept: _act1En, action: 'CLICK Reset, then DRAG coal.', observation: _th1En),
        LabStep(concept: _act1En, action: 'Strike coal with hammer.', observation: _th1En),
        LabStep(concept: _act1En, action: 'Test remaining materials.', observation: _th1En),
      ],
    ),
    LabScenarioData(
      objective:
          'To investigate which materials conduct electricity by using them to complete a simple circuit and make a bulb glow.',
      steps: [
        LabStep(
          concept: _act2En,
          action: 'DRAG a material from the tray to place it in the circuit gap.',
          observation: _th2En,
        ),
        LabStep(concept: _act2En, action: 'Observe the circuit completion and glowing bulb.', observation: _th2En),
        LabStep(concept: _act2En, action: 'Test all remaining materials to classify them.', observation: _th2En),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'हथौड़े से वार करके यह दृष्टिगत रूप से निर्धारित करना कि विभिन्न सामग्रियां आघातवर्ध्य (चपटी) हैं या भंगुर (टूटने वाली)।',
      steps: [
        LabStep(concept: _act1Hi, action: 'लोहे की कील को निहाई पर खींचें।', observation: _th1Hi),
        LabStep(concept: _act1Hi, action: 'वार करने के लिए हथौड़े पर क्लिक करें।', observation: _th1Hi),
        LabStep(concept: _act1Hi, action: 'रीसेट पर क्लिक करें, फिर कोयले को खींचें।', observation: _th1Hi),
        LabStep(concept: _act1Hi, action: 'कोयले पर हथौड़े से वार करें।', observation: _th1Hi),
        LabStep(concept: _act1Hi, action: 'शेष सामग्रियों का परीक्षण करें।', observation: _th1Hi),
      ],
    ),
    LabScenarioData(
      objective:
          'एक साधारण परिपथ को पूरा करने और बल्ब को रोशन करने के लिए सामग्री का उपयोग करके यह जांचना कि कौन सी सामग्री बिजली का संचालन करती है।',
      steps: [
        LabStep(concept: _act2Hi, action: 'ट्रे से सामग्री खींचकर परिपथ के गैप में रखें।', observation: _th2Hi),
        LabStep(concept: _act2Hi, action: 'परिपथ के पूरा होने और चमकते बल्ब का अवलोकन करें।', observation: _th2Hi),
        LabStep(concept: _act2Hi, action: 'वर्गीकरण के लिए शेष सभी सामग्रियों का परीक्षण करें।', observation: _th2Hi),
      ],
    ),
  ],
};

// ============================================================ GEOMETRY

const Size _design = Size(1000, 560);

@immutable
class _V3 {
  const _V3(this.x, this.y, this.z);

  final double x, y, z;

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double k) => _V3(x * k, y * k, z * k);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V3 get unit => this * (1 / length);

  static _V3 lerp(_V3 a, _V3 b, double t) => a + (b - a) * t;
}

/// A perspective camera (HTML PerspectiveCamera, 45° FOV) looking from
/// [eye] at [target]; [zoom] scales the focal length.
class _View {
  _View(this.eye, this.target, this.zoom, {this.center = const Offset(430, 262)}) {
    _f = (target - eye).unit;
    _r = _f.cross(const _V3(0, 1, 0)).unit;
    _u = _r.cross(_f);
    focal = (_design.height / 2) / math.tan(22.5 * math.pi / 180) * zoom;
  }

  final _V3 eye, target;
  final double zoom;
  late final _V3 _f, _r, _u;
  late final double focal;

  /// Design point the camera target projects to (kept clear of the
  /// MATERIALS tray overlay on the right).
  final Offset center;

  Offset p(_V3 v) {
    final d = v - eye;
    final z = d.dot(_f);
    return Offset(center.dx + d.dot(_r) / z * focal, center.dy - d.dot(_u) / z * focal);
  }

  Offset pp(double x, double y, double z) => p(_V3(x, y, z));

  /// Design pixels per world unit at [v].
  double k(_V3 v) => focal / (v - eye).dot(_f);

  /// Minor / major ratio of a horizontal circle at [v].
  double tilt(_V3 v) {
    final a = p(v + const _V3(0, 0, 1)), b = p(v - const _V3(0, 0, 1));
    return ((a.dy - b.dy).abs() / 2 / k(v)).clamp(0.15, 1.0);
  }
}

/// Camera presets: start (HTML init), scenario 1 anvil, scenario 2 circuit.
const _V3 _introEye = _V3(0, 10, 20), _introTarget = _V3(0, 0, 0);
const List<(_V3, _V3, double)> _views = [(_V3(0, 8.5, 15), _V3(0, 4.8, 0), 1.0), (_V3(0, 12, 8), _V3(0, 1, 0), 1.25)];

// ============================================================ MODEL

/// HTML `addFloatingDOMLabel` comic labels: 0 generic, 1 green, 2 red, 3 amber.
class _Comic {
  _Comic(this.key, this.kind, this.pos, this.born);

  final String key;
  final int kind;
  final _V3 pos;
  final double born;
}

/// One shard of a brittle material (HTML `createShatterEffect`).
class _Shard {
  _Shard(this.from, this.to, this.size, this.rot);

  final _V3 from, to;
  final double size, rot;
}

class _Scene {
  int scenario = 0;
  _Mat? active;

  /// HTML `currentTaskState`: idle, placed, animating, tested.
  String task = 'idle';
  final Set<_Mat> tested = {};

  /// Last result per material for each scenario (sidebar readout).
  final List<Map<_Mat, String>> results = [{}, {}];
  double time = 0;

  // Camera tween.
  _V3 eyeFrom = _introEye, eyeTo = _introEye;
  _V3 tgtFrom = _introTarget, tgtTo = _introTarget;
  double zoomFrom = 1, zoomTo = 1;
  double camStart = -10;
  int camFromScenario = 0;

  /// Free area left of the MATERIALS tray, in design units (set from the
  /// canvas layout): its centre x and width. The camera is centred there
  /// and zooms out a little when it is narrow (small phones).
  double viewCx = 430;
  double freeW = 1000;

  /// Design width each scenario's scene needs at zoom 1.
  static const List<double> _need = [520, 700];

  double _fit(int scen) => (freeW / _need[scen]).clamp(0.62, 1.0);

  // Test item.
  double dropStart = -10;
  double dropFrom = 10, dropTo = 4.6, dropDur = 0.5;
  bool dropBounce = true;

  // Hammer.
  bool hammerVisible = false;
  double strikeStart = -10;
  bool clickLabel = false;

  /// 0 none, 1 flattened, 2 shattered, 3 dented.
  int effect = 0;
  double effectStart = -10;
  List<_Shard> shards = const [];

  // Circuit bulb.
  bool bulbOn = false;
  double bulbStart = -10;

  final List<_Comic> comics = [];

  // HUD (HTML updateHUD): keys resolved at build time.
  String hudTitleKey = 'hud_phase1';
  _Mat? hudTitleMat;
  String hudTitleSuffix = '';
  String hudStatus = 'hud_status_action';
  String hudInstr = 'hud_idle_s1';
  bool nextBtn = false;

  _View view() {
    final t = ((time - camStart) / 1.0).clamp(0.0, 1.0);
    final e = Curves.easeOutCubic.transform(t);
    final fit = _fit(camFromScenario) + (_fit(scenario) - _fit(camFromScenario)) * e;
    return _View(
      _V3.lerp(eyeFrom, eyeTo, e),
      _V3.lerp(tgtFrom, tgtTo, e),
      (zoomFrom + (zoomTo - zoomFrom) * e) * fit,
      center: Offset(viewCx, 262),
    );
  }

  void moveCamera(_V3 eye, _V3 target, double zoom, {bool animate = true}) {
    final t = ((time - camStart) / 1.0).clamp(0.0, 1.0);
    final e = Curves.easeOutCubic.transform(t);
    eyeFrom = animate ? _V3.lerp(eyeFrom, eyeTo, e) : eye;
    tgtFrom = animate ? _V3.lerp(tgtFrom, tgtTo, e) : target;
    zoomFrom = animate ? zoomFrom + (zoomTo - zoomFrom) * e : zoom;
    eyeTo = eye;
    tgtTo = target;
    zoomTo = zoom;
    camStart = time;
  }

  /// World position of the test item (drop tween).
  _V3 itemPos() {
    final t = ((time - dropStart) / dropDur).clamp(0.0, 1.0);
    final e = dropBounce ? Curves.bounceOut.transform(t) : Curves.easeOutQuad.transform(t);
    final y = dropFrom + (dropTo - dropFrom) * e;
    return scenario == 0 ? _V3(0, y, 0) : _V3(0, y, -1.5);
  }

  /// Per-axis scale of the test item: flattening tween in scenario 1, the
  /// HTML `placeMaterialInCircuit` scales in scenario 2.
  _V3 itemScale(_Mat m) {
    if (scenario == 1) {
      return switch (_matData[m]!.model) {
        _Model.rock => const _V3(3.5, 1.5, 1.5),
        _Model.nail => const _V3(1, 2.8, 1),
        _Model.wire => const _V3(1.2, 1.2, 1.2),
        _Model.foil => const _V3(1.5, 1, 1),
        _Model.wood => const _V3(1.8, 1, 1.5),
      };
    }
    if (effect != 1) return const _V3(1, 1, 1);
    final t = ((time - effectStart) / 0.2).clamp(0.0, 1.0);
    return _V3(1 + 0.5 * t, 1 - 0.8 * t, 1 + 0.5 * t);
  }

  /// Hammer swing angle (degrees in the x-y plane) or null when hidden.
  /// Swing down 150 ms (Quadratic.In), hold 400 ms, lift 400 ms (Quadratic.Out).
  double? hammerAngle() {
    if (!hammerVisible) return null;
    const raised = 120.0, strike = 180.0;
    final t = time - strikeStart;
    if (t < 0) return raised;
    if (t < 0.15) return raised + 60 * Curves.easeInQuad.transform(t / 0.15);
    if (t < 0.55) return strike;
    if (t < 0.95) return strike - 60 * Curves.easeOutQuad.transform((t - 0.55) / 0.4);
    return raised;
  }

  double bulbGlow() {
    final t = ((time - bulbStart) / 0.2).clamp(0.0, 1.0);
    return bulbOn ? t : 0;
  }
}

/// Hammer pivot (grip) and handle length in world units.
const _V3 _pivot = _V3(3.6, 5.75, 0.6);
const double _handleLen = 3.6;

_V3 _hammerDir(double deg) => _V3(math.cos(deg * math.pi / 180), math.sin(deg * math.pi / 180), 0);

/// Points of a Catmull-Rom curve through [pts] (HTML CatmullRomCurve3 with
/// mirrored end tangents), [per] samples per segment.
List<_V3> _catmull(List<_V3> pts, {int per = 10}) {
  final ext = [pts.first * 2 - pts[1], ...pts, pts.last * 2 - pts[pts.length - 2]];
  final out = <_V3>[pts.first];
  for (var i = 1; i < ext.length - 2; i++) {
    final q0 = ext[i - 1], q1 = ext[i], q2 = ext[i + 1], q3 = ext[i + 2];
    for (var s = 1; s <= per; s++) {
      final t = s / per, t2 = t * t, t3 = t2 * t;
      out.add((q1 * 2 + (q2 - q0) * t + (q0 * 2 - q1 * 5 + q2 * 4 - q3) * t2 + (q1 * 3 - q0 - q2 * 3 + q3) * t3) * 0.5);
    }
  }
  return out;
}

// ============================================================ PAINTER

class _LabPainter extends CustomPainter {
  _LabPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;

  /// Current language table (labels are looked up by HTML key).
  final Map<String, String> tr;

  late _View v;

  static const Color _anvil = Color(0xFF9BA4B5);
  static const Color _tableWood = Color(0xFF8B5A2B);
  static const Color _copper = Color(0xFFC87E3A);

  String _s(String key) => tr[key] ?? key;
  double get _t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    v = scene.view();
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = bg);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = RadialGradient(
          colors: [(isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.9), bg.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: const Offset(430, 200), radius: 520)),
    );
    _table(canvas, size, bg);
    if (scene.scenario == 0) {
      _anvilScene(canvas);
    } else {
      _circuitScene(canvas);
    }
    if (showLabels) _comics(canvas);
  }

  // ------------------------------------------------------------ helpers

  Paint _fill(Color c) => Paint()..color = c;

  /// Projected box with the faces that look towards the camera.
  void _box(Canvas c, _V3 min, _V3 max, Color color, {double opacity = 1, bool metal = false}) {
    Color a(Color col) => col.withValues(alpha: col.a * opacity);
    Offset p(double x, double y, double z) => v.pp(x, y, z);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = a(labShade(color, -0.5).withValues(alpha: 0.5));
    void face(List<Offset> pts, Color col) {
      final path = Path()..addPolygon(pts, true);
      c.drawPath(path, _fill(a(col)));
      c.drawPath(path, edge);
    }

    if (v.eye.x > max.x) {
      face([
        p(max.x, min.y, max.z),
        p(max.x, min.y, min.z),
        p(max.x, max.y, min.z),
        p(max.x, max.y, max.z),
      ], labShade(color, -0.3));
    } else if (v.eye.x < min.x) {
      face([
        p(min.x, min.y, max.z),
        p(min.x, min.y, min.z),
        p(min.x, max.y, min.z),
        p(min.x, max.y, max.z),
      ], labShade(color, -0.3));
    }
    if (v.eye.y > max.y) {
      face([
        p(min.x, max.y, min.z),
        p(max.x, max.y, min.z),
        p(max.x, max.y, max.z),
        p(min.x, max.y, max.z),
      ], labShade(color, metal ? 0.3 : 0.15));
    }
    final front = [p(min.x, max.y, max.z), p(max.x, max.y, max.z), p(max.x, min.y, max.z), p(min.x, min.y, max.z)];
    final path = Path()..addPolygon(front, true);
    final b = path.getBounds();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: metal ? Alignment.topLeft : Alignment.topCenter,
          end: metal ? Alignment.bottomRight : Alignment.bottomCenter,
          colors: metal
              ? [a(labShade(color, 0.35)), a(color), a(labShade(color, -0.25)), a(labShade(color, 0.1))]
              : [a(labShade(color, -0.02)), a(labShade(color, -0.22))],
          stops: metal ? const [0, 0.4, 0.75, 1] : null,
        ).createShader(b),
    );
    c.drawPath(path, edge);
  }

  /// Cylinder along the x axis between [a] and [b] (radius [ry] vertically).
  void _xCyl(Canvas c, _V3 a, _V3 b, double ry, Color color, {double opacity = 1, bool metal = false}) {
    Color al(Color col) => col.withValues(alpha: col.a * opacity);
    final pa = v.p(a), pb = v.p(b);
    final ra = ry * v.k(a), rb = ry * v.k(b);
    final body = Path()
      ..addPolygon([pa.translate(0, -ra), pb.translate(0, -rb), pb.translate(0, rb), pa.translate(0, ra)], true);
    final mid = Offset.lerp(pa, pb, 0.5)!;
    final rm = (ra + rb) / 2;
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: metal
              ? [al(labShade(color, 0.1)), al(labShade(color, 0.6)), al(color), al(labShade(color, -0.45))]
              : [al(labShade(color, 0.05)), al(labShade(color, 0.3)), al(color), al(labShade(color, -0.4))],
          stops: const [0, 0.3, 0.55, 1],
        ).createShader(Rect.fromCenter(center: mid, width: 4, height: math.max(1, rm * 2))),
    );
    final cap = b.x < v.eye.x ? (pb, rb) : (a.x > v.eye.x ? (pa, ra) : null);
    if (cap != null) {
      c.drawOval(
        Rect.fromCenter(center: cap.$1, width: cap.$2 * 0.7, height: cap.$2 * 2),
        _fill(al(labShade(color, 0.15))),
      );
    }
  }

  /// Copper tube wire along [pts] (HTML TubeGeometry radius 0.08).
  void _tube(Canvas c, List<_V3> pts, Color color, double r) {
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final p = v.p(pts[i]);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    final w = 2 * r * v.k(pts[pts.length ~/ 2]);
    Paint s(Color col, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..color = col;
    c.drawPath(path.shift(const Offset(1.5, 3)), s(Colors.black.withValues(alpha: 0.2), w));
    c.drawPath(path, s(labShade(color, -0.45), w + 1.4));
    c.drawPath(path, s(color, w));
    c.drawPath(path.shift(Offset(0, -w * 0.2)), s(labShade(color, 0.5).withValues(alpha: 0.8), w * 0.3));
  }

  void _shadow(Canvas c, _V3 at, double rx, double rz, {double opacity = 0.35}) {
    final p = v.p(at), k = v.k(at);
    labGroundShadow(c, p, rx * 2 * k, rz * 2 * k * v.tilt(at), opacity: opacity);
  }

  /// HTML `createLabel` sprite: dark rounded box, coloured border + text.
  void _sprite(Canvas c, String text, _V3 at, Color color, double scale) {
    final k = v.k(at);
    labText(
      c,
      text,
      v.p(at),
      size: (0.42 * k * scale).clamp(10.0, 30.0),
      weight: FontWeight.w800,
      color: color,
      background: const Color(0xCC0F172A),
      border: color,
      borderWidth: 2.2,
      radius: 9,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    );
  }

  // -------------------------------------------------------- environment

  /// HTML workbench table (40 x 2 x 20, top at y = 0) fading into the fog.
  void _table(Canvas c, Size size, Color bg) {
    final far = v.pp(0, 0, -10).dy;
    final top = Rect.fromLTRB(labBleed(size).left, far, labBleed(size).right, labBleed(size).bottom);
    final fogged = Color.lerp(_tableWood, bg, isDark ? 0.62 : 0.5)!;
    c.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fogged, Color.lerp(_tableWood, bg, 0.2)!, _tableWood, labShade(_tableWood, -0.1)],
          stops: const [0, 0.12, 0.5, 1],
        ).createShader(Rect.fromLTRB(0, far, 1, far + 420)),
    );
    // Planks running away from the viewer.
    final line = Paint()
      ..strokeWidth = 1.2
      ..color = labShade(_tableWood, -0.4).withValues(alpha: 0.35);
    final zNear = math.min(9.0, v.eye.z - 2);
    for (var x = -20.0; x <= 20; x += 2.5) {
      c.drawLine(v.pp(x, 0, -10), v.pp(x, 0, zNear), line);
    }
    c.drawLine(
      Offset(top.left, far),
      Offset(top.right, far),
      Paint()
        ..strokeWidth = 2
        ..color = labShade(_tableWood, 0.25).withValues(alpha: 0.35),
    );
  }

  // ------------------------------------------------- scenario 1: anvil

  void _anvilScene(Canvas c) {
    _shadow(c, const _V3(0.6, 0, 0.2), 3.6, 1.8, opacity: 0.45);
    // HTML anvil: base 4x2x2.5, waist 2.5x1.5x1.5, face 5x1x2 and horn.
    _box(c, const _V3(-2, 0, -1.25), const _V3(2, 2, 1.25), _anvil, metal: true);
    _box(c, const _V3(-1.25, 2, -0.75), const _V3(1.25, 3.5, 0.75), _anvil, metal: true);
    _horn(c);
    _box(c, const _V3(-2.5, 3.5, -1), const _V3(2.5, 4.5, 1), _anvil, metal: true);
    // Polished striking face.
    final face = Path()
      ..addPolygon([v.pp(-2.4, 4.5, -0.9), v.pp(2.4, 4.5, -0.9), v.pp(2.4, 4.5, 0.9), v.pp(-2.4, 4.5, 0.9)], true);
    c.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.05),
          ],
        ).createShader(face.getBounds()),
    );
    if (showLabels) _sprite(c, _s('lbl_anvil'), const _V3(-3, 6, 0), _Colors.zslYellow, 1);

    final m = scene.active;
    if (m != null && scene.effect != 2) _item(c, m, scene.itemPos(), scene.itemScale(m));
    if (scene.effect == 2) _shards(c);
    _hammer(c);
    if (scene.clickLabel && showLabels && scene.hammerVisible) _clickLabel(c);
  }

  /// Anvil horn: a cone pointing away from the face (+x).
  void _horn(Canvas c) {
    const a = _V3(2.4, 4.05, 0), b = _V3(4.6, 4.2, 0);
    final pa = v.p(a), pb = v.p(b);
    final ra = 0.5 * v.k(a), rb = 0.08 * v.k(b);
    final path = Path()
      ..moveTo(pa.dx, pa.dy - ra)
      ..quadraticBezierTo((pa.dx + pb.dx) / 2, pa.dy - ra * 0.75, pb.dx, pb.dy - rb)
      ..lineTo(pb.dx, pb.dy + rb)
      ..quadraticBezierTo((pa.dx + pb.dx) / 2, pa.dy + ra * 0.55, pa.dx, pa.dy + ra)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_anvil, 0.5), _anvil, labShade(_anvil, -0.4)],
        ).createShader(path.getBounds()),
    );
  }

  /// A test material (HTML `generateMaterialMesh`) at [o] scaled by [sc].
  void _item(Canvas c, _Mat m, _V3 o, _V3 sc) {
    final d = _matData[m]!;
    _V3 w(double x, double y, double z) => o + _V3(x * sc.x, y * sc.y, z * sc.z);
    final metal = d.metal;
    switch (d.model) {
      case _Model.nail:
        _xCyl(c, w(-0.75, 0, 0), w(0.75, 0, 0), 0.1 * sc.y, d.color, metal: metal);
        final tipA = v.p(w(0.75, 0, 0)), tipB = v.p(w(1.05, 0, 0));
        final r = 0.1 * sc.y * v.k(o);
        c.drawPath(
          Path()..addPolygon([tipA.translate(0, -r), tipB, tipA.translate(0, r)], true),
          _fill(labShade(d.color, -0.1)),
        );
        final head = v.p(w(-0.8, 0, 0));
        final hr = 0.25 * sc.y * v.k(o);
        c.drawOval(
          Rect.fromCenter(center: head, width: math.max(3, 0.1 * sc.x * v.k(o) * 2), height: hr * 2),
          _fill(labShade(d.color, 0.15)),
        );
      case _Model.wire:
        _xCyl(c, w(-1.95, 0, 0), w(-0.45, 0, 0), 0.08 * sc.y, d.color, metal: true);
        _xCyl(c, w(0.45, 0, 0), w(1.95, 0, 0), 0.08 * sc.y, d.color, metal: true);
        for (final cx in const [-0.3, 0.0, 0.3]) {
          final p = v.p(w(cx, 0, 0));
          final k = v.k(o);
          c.drawOval(
            Rect.fromCenter(center: p, width: 0.6 * sc.x * k, height: math.max(2, 0.6 * sc.z * k * v.tilt(o))),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(1.2, 0.16 * sc.y * k)
              ..color = labShade(d.color, cx == 0 ? 0.2 : 0),
          );
        }
      case _Model.foil:
        _box(c, w(-1, -0.025, -0.75), w(1, 0.025, 0.75), d.color, metal: true);
      case _Model.wood:
        final dented = scene.effect == 3;
        final th = dented ? 0.05 : 0.075;
        final base = dented ? o + const _V3(0, -0.05, 0) : o;
        _box(
          c,
          base + _V3(-0.9 * sc.x, -th * sc.y, -0.6 * sc.z),
          base + _V3(0.9 * sc.x, th * sc.y, 0.6 * sc.z),
          _tableWood,
        );
        if (dented) {
          final p = v.p(base + _V3(0, th, 0));
          final k = v.k(base);
          c.drawOval(
            Rect.fromCenter(center: p, width: 0.4 * k, height: 0.4 * k * v.tilt(base)),
            _fill(const Color(0xFF3B2413)),
          );
        }
      case _Model.rock:
        _rock(c, m, o, sc, d.color);
    }
  }

  /// Irregular dodecahedron lump (coal / sulfur).
  void _rock(Canvas c, _Mat m, _V3 o, _V3 sc, Color color) {
    final p = v.p(o);
    final k = v.k(o);
    final rnd = math.Random(m.index * 7 + 3);
    final pts = <Offset>[];
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * math.pi * 2;
      final r = 0.5 * (0.85 + rnd.nextDouble() * 0.3);
      pts.add(p + Offset(math.cos(a) * r * sc.x * k, math.sin(a) * r * sc.y * k * 0.95));
    }
    final path = Path()..addPolygon(pts, true);
    c.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: [labShade(color, 0.35), color, labShade(color, -0.45)],
        ).createShader(path.getBounds()),
    );
    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = labShade(color, color.computeLuminance() < 0.05 ? 0.25 : -0.3).withValues(alpha: 0.6);
    for (var i = 0; i < 10; i += 2) {
      c.drawLine(Offset.lerp(p, pts[i], 0.45)!, pts[i], facet);
      c.drawLine(Offset.lerp(p, pts[i], 0.45)!, Offset.lerp(p, pts[(i + 2) % 10], 0.45)!, facet);
    }
  }

  void _shards(Canvas c) {
    final m = scene.active;
    if (m == null) return;
    final color = _matData[m]!.color;
    final t = Curves.easeOutQuad.transform(((_t - scene.effectStart) / 0.3).clamp(0.0, 1.0));
    for (final sh in scene.shards) {
      final pos = _V3.lerp(sh.from, sh.to, t);
      final p = v.p(pos);
      final r = sh.size * v.k(pos);
      final rot = sh.rot * t;
      final pts = [
        for (var i = 0; i < 3; i++)
          p + Offset(math.cos(rot + i * 2.1), math.sin(rot + i * 2.1)) * r * (i == 0 ? 1.15 : 0.9),
      ];
      c.drawPath(Path()..addPolygon(pts, true), _fill(color));
      c.drawPath(Path()..addPolygon([pts[0], pts[1], p], true), _fill(labShade(color, 0.25)));
    }
  }

  /// HTML hammer group: wooden handle (r 0.2) and a 2 x 1 x 1 steel head.
  void _hammer(Canvas c) {
    final ang = scene.hammerAngle();
    if (ang == null) return;
    final dir = _hammerDir(ang);
    final grip = _pivot - dir * 0.5;
    final head = _pivot + dir * _handleLen;
    final pg = v.p(grip), ph = v.p(head);
    final k = v.k(head);
    // Handle.
    c.drawLine(
      pg,
      ph,
      Paint()
        ..strokeWidth = 0.42 * k
        ..strokeCap = StrokeCap.round
        ..color = labShade(_tableWood, -0.35),
    );
    c.drawLine(
      pg,
      ph,
      Paint()
        ..strokeWidth = 0.34 * k
        ..strokeCap = StrokeCap.round
        ..color = _tableWood,
    );
    final n = Offset(-(ph.dy - pg.dy), ph.dx - pg.dx) / (ph - pg).distance;
    c.drawLine(
      pg + n * 0.08 * k,
      ph + n * 0.08 * k,
      Paint()
        ..strokeWidth = 0.08 * k
        ..strokeCap = StrokeCap.round
        ..color = labShade(_tableWood, 0.3),
    );
    // Head (long axis across the handle).
    final sa = math.atan2(ph.dy - pg.dy, ph.dx - pg.dx);
    c.save();
    c.translate(ph.dx, ph.dy);
    c.rotate(sa);
    final rect = Rect.fromCenter(center: Offset.zero, width: 1.0 * k, height: 2.0 * k);
    const steel = Color(0xFF8A9096);
    c.drawRRect(
      RRect.fromRectAndRadius(rect.shift(Offset(0.18 * k, -0.18 * k)), Radius.circular(0.08 * k)),
      _fill(labShade(steel, -0.35)),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(0.08 * k)),
      Paint()..shader = LinearGradient(colors: [labShade(steel, 0.5), steel, labShade(steel, -0.3)]).createShader(rect),
    );
    final faceH = 0.16 * k;
    for (final y in [rect.top, rect.bottom - faceH]) {
      c.drawRect(Rect.fromLTWH(rect.left, y, rect.width, faceH), _fill(labShade(steel, 0.35)));
    }
    c.restore();
  }

  /// HTML persistent "CLICK HERE TO STRIKE" bouncing tag at the hammer. It
  /// sits beside the raised hammer head (pointing at it) so the toast and
  /// the MATERIALS tray never cover it.
  void _clickLabel(Canvas c) {
    final head = _pivot + _hammerDir(120) * _handleLen;
    final ph = v.p(head);
    final k = v.k(head);
    final bounce = -7 * (0.5 + 0.5 * math.cos(_t * math.pi * 2));
    final tip = Offset(ph.dx - 1.25 * k, ph.dy + bounce);
    final r = labText(
      c,
      _s('lbl_click_strike'),
      tip - const Offset(9, 0),
      size: 15,
      weight: FontWeight.w800,
      color: _Colors.slate900,
      background: _Colors.zslYellow,
      anchor: Alignment.centerRight,
      padding: const EdgeInsets.fromLTRB(34, 6, 14, 6),
    );
    c.drawPath(
      Path()
        ..moveTo(r.right - 1, r.center.dy - 7)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(r.right - 1, r.center.dy + 7)
        ..close(),
      _fill(_Colors.zslYellow),
    );
    final icon = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.ads_click.codePoint),
        style: TextStyle(fontFamily: Icons.ads_click.fontFamily, fontSize: 19, color: _Colors.slate900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    icon.paint(c, Offset(r.left + 10, r.center.dy - icon.height / 2));
  }

  // ----------------------------------------------- scenario 2: circuit

  void _circuitScene(Canvas c) {
    const boardColor = Color(0xFFD4A373);
    _shadow(c, const _V3(0.3, 0, 0.4), 6.6, 3.9, opacity: 0.4);
    _box(c, const _V3(-6, 0, -3.5), const _V3(6, 0.4, 3.5), boardColor);
    final grain = Paint()
      ..strokeWidth = 1
      ..color = labShade(boardColor, -0.3).withValues(alpha: 0.3);
    for (var z = -3.2; z < 3.5; z += 0.7) {
      c.drawLine(v.pp(-5.9, 0.4, z), v.pp(5.9, 0.4, z + 0.05), grain);
    }
    final glow = scene.bulbGlow();
    if (glow > 0) {
      final p = v.pp(3, 0.4, 0);
      final r = 6 * v.k(const _V3(3, 0.4, 0));
      c.save();
      c.translate(p.dx, p.dy);
      c.scale(1, v.tilt(const _V3(3, 0.4, 0)));
      c.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFCC00).withValues(alpha: 0.45 * glow),
              const Color(0x00FFCC00),
            ],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
      );
      c.restore();
    }
    // Copper wires (HTML CatmullRomCurve3 tubes).
    _tube(c, _catmull(const [_V3(-3, 0.5, -1), _V3(-3, 0.48, -1.8), _V3(-2, 0.6, -1.5)]), _copper, 0.08);
    _tube(c, _catmull(const [_V3(2, 0.6, -1.5), _V3(3, 0.48, -1.5), _V3(3, 0.6, -0.4)]), _copper, 0.08);
    _tube(
      c,
      _catmull(const [_V3(3, 0.6, 0.4), _V3(2, 0.48, 1.2), _V3(-2, 0.48, 1.2), _V3(-3, 0.5, 1.0)]),
      _copper,
      0.08,
    );
    // Alligator clips facing each other across the gap.
    _clip(c, const _V3(-1.8, 0.6, -1.5), -math.pi / 8, 1);
    _clip(c, const _V3(1.8, 0.6, -1.5), math.pi / 8, -1);
    final m = scene.active;
    if (m != null) _item(c, m, scene.itemPos(), scene.itemScale(m));
    // Battery holder with two cells.
    _box(c, const _V3(-4.7, 0.4, -1.2), const _V3(-1.3, 0.6, 1.2), const Color(0xFF222222));
    for (final z in const [-0.6, 0.6]) {
      _xCyl(c, _V3(-4.4, 0.85, z), _V3(-1.6, 0.85, z), 0.3, const Color(0xFF1E3A8A));
      _xCyl(c, _V3(-1.6, 0.85, z), _V3(-1.4, 0.85, z), 0.1, const Color(0xFFEAB308), metal: true);
    }
    // Bulb holder and bulb.
    final pt = v.pp(3, 0.9, 0), pb = v.pp(3, 0.3, 0);
    final hr = 0.8 * v.k(const _V3(3, 0.9, 0));
    labCylinder(
      c,
      Rect.fromLTRB(pt.dx - hr, pt.dy, pt.dx + hr, pb.dy),
      const Color(0xFF94A3B8),
      tilt: v.tilt(const _V3(3, 0.9, 0)),
    );
    final bc = v.pp(3, 1.8, 0);
    final br = 0.9 * v.k(const _V3(3, 1.8, 0));
    if (glow > 0) labGlow(c, bc, br * 2.6, const Color(0xFFFFCC00), intensity: glow);
    labSphere(
      c,
      bc,
      br,
      Color.lerp(const Color(0xFF9CA3AF), const Color(0xFFFFE600), glow)!,
      opacity: 0.9 + 0.1 * glow,
      highlight: 0.5 + 0.3 * glow,
      shade: 0.5 - 0.3 * glow,
    );
    if (glow > 0) labGlow(c, bc, br * 0.9, Colors.white, intensity: 0.8 * glow);
    if (showLabels) {
      const grey = Color(0xFF9CA3AF);
      _sprite(c, _s('lbl_battery'), const _V3(-3, 1.4, 0), grey, 0.6);
      _sprite(c, _s('lbl_bulb'), const _V3(3, 3.4, 0), grey, 0.6);
      _sprite(c, _s('lbl_clips'), const _V3(0, 1.4, -1.5), grey, 0.5);
    }
  }

  /// HTML alligator clip: body cylinder plus two open jaws ([side] = +1 jaws
  /// towards +x, -1 towards -x), rotated about y by [rot].
  void _clip(Canvas c, _V3 at, double rot, double side) {
    _V3 w(double x, double y, double z) =>
        at + _V3(x * math.cos(rot) + z * math.sin(rot), y, -x * math.sin(rot) + z * math.cos(rot));
    const metal = Color(0xFFCCCCCC);
    final a = v.p(w(-0.6 * side, 0, 0)), b = v.p(w(0.25 * side, 0, 0));
    final k = v.k(at);
    c.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 0.34 * k
        ..strokeCap = StrokeCap.round
        ..color = labShade(metal, -0.45),
    );
    c.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 0.26 * k
        ..strokeCap = StrokeCap.round
        ..color = metal,
    );
    c.drawLine(
      a.translate(0, -0.06 * k),
      b.translate(0, -0.06 * k),
      Paint()
        ..strokeWidth = 0.07 * k
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.8),
    );
    final jaw = Paint()
      ..strokeWidth = math.max(2, 0.12 * k)
      ..strokeCap = StrokeCap.round
      ..color = labShade(metal, -0.15);
    c.drawLine(v.p(w(0.25 * side, 0.05, 0)), v.p(w(0.9 * side, 0.2, 0)), jaw);
    c.drawLine(v.p(w(0.25 * side, -0.05, 0)), v.p(w(0.9 * side, -0.1, 0)), jaw);
  }

  // ----------------------------------------------------- comic labels

  void _comics(Canvas c) {
    const colors = [Color(0xFFEAB308), Color(0xFF22C55E), Color(0xFFEF4444), Color(0xFFD97706)];
    for (final cm in scene.comics) {
      final age = _t - cm.born;
      if (age < 0 || age > 3.8) continue;
      final pop = Curves.easeOutBack.transform((age / 0.3).clamp(0.0, 1.0));
      final alpha = age > 3.5 ? 1 - ((age - 3.5) / 0.3).clamp(0.0, 1.0) : (age / 0.3).clamp(0.0, 1.0);
      final color = colors[cm.kind];
      final at = v.p(cm.pos);
      c.save();
      c.translate(at.dx, at.dy);
      c.rotate(-5 * math.pi / 180 * pop);
      c.scale(0.5 + 0.5 * pop);
      final text = _s(cm.key).toUpperCase();
      final size = cm.kind == 3 ? 17.0 : 26.0;
      const pad = EdgeInsets.symmetric(horizontal: 16, vertical: 6);
      labText(
        c,
        text,
        const Offset(4, 4),
        size: size,
        weight: FontWeight.w900,
        color: Colors.transparent,
        background: Colors.black.withValues(alpha: 0.2),
        radius: 8,
        padding: pad,
        opacity: alpha,
      );
      labText(
        c,
        text,
        Offset.zero,
        size: size,
        weight: FontWeight.w900,
        color: color,
        background: Colors.white,
        border: color,
        borderWidth: 4,
        radius: 8,
        padding: pad,
        opacity: alpha,
      );
      c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LabPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || !identical(old.tr, tr) || old.scene != scene;
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
