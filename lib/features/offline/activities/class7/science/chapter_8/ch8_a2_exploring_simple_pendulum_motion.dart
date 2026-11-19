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

/// Class 7 Science • Chapter 8 • Activity 2
/// Exploring Simple Pendulum Motion.
///
/// Native Flutter port of `Cl7S-Ch8-A2-Exploring_Simple_Pendulum_Motion.html`.
/// Scenario 1 assembles a 100 cm / iron-bob pendulum from the toolkit, sets
/// it swinging, times 10 oscillations with the stopwatch and auto-fills two
/// more trials. Scenario 2 measures 50 cm, 150 cm, 100 cm (iron) and
/// 100 cm (lead) pendulums to show that only the length changes the period.
class Ch8A2ExploringSimplePendulumMotionPage extends StatefulWidget {
  const Ch8A2ExploringSimplePendulumMotionPage({super.key});

  @override
  State<Ch8A2ExploringSimplePendulumMotionPage> createState() =>
      _Ch8A2ExploringSimplePendulumMotionPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, switchTap 2585.
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

/// Pan recognizer that only claims touches starting on a draggable object
/// (so empty-canvas drags still pan the zoomed canvas) and starts after a
/// small slop.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch8A2ExploringSimplePendulumMotionPageState extends State<Ch8A2ExploringSimplePendulumMotionPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _PendulumScene _scene = _PendulumScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();

  late final Ticker _ticker;
  late final AnimationController _snap;
  _Item? _snapItem;
  Offset _snapFrom = Offset.zero;

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
    _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..addListener(() {
        final it = _snapItem;
        if (it == null) return;
        it.pos = Offset.lerp(_snapFrom, it.home, Curves.easeOutQuad.transform(_snap.value))!;
      });
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
    _snap.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ physics

  /// HTML `animate()`: simple harmonic swing, stopwatch and oscillation
  /// counter (one count each time the bob crosses the centre line moving
  /// from left to right).
  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _scene.time).clamp(0.0, 0.1);
    _scene.time = t;
    final sc = _scene;
    if (sc.isSwinging && sc.stringLength != null) {
      final w = math.sqrt(_gravity / (int.parse(sc.stringLength!) / 100));
      sc.pTime += dt;
      final angle = sc.maxAngle * math.cos(w * sc.pTime);
      final prev = sc.angle;
      sc.angle = angle;
      final sw = sc.sw;
      if (sw.running) {
        sw.time += dt;
        if (prev < 0 && angle >= 0) {
          _Audio.play(_Sound.switchTap);
          setState(() {
            sw.osc++;
            if (sw.osc >= 10) sw.pulse = true;
          });
        }
      }
    }
    _frame.value = t;
  }

  // -------------------------------------------------------------- logic

  /// HTML `buildScenario()` / `resetApp(true)`.
  void _buildScenario() {
    _lab.cancelPending();
    _snap.stop();
    _snapItem = null;
    _scene.build();
    _lab.resetView(sound: false);
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

  /// HTML `advanceStep()`, including the stopwatch / table toggles for the
  /// new step.
  void _advanceStep() {
    final n = _data.steps.length;
    final sc = _scene;
    if (sc.step > n) return;
    setState(() {
      sc.step++;
      final st = sc.step;
      final sw = sc.sw;
      if (sc.scenario == 0) {
        if (st == 4) {
          sw.visible = true;
          sw.showStart = true;
        }
        if (st == 5) sc.tableVisible = true;
      } else {
        if (st == 2 || st == 4 || st == 7) {
          sw
            ..visible = true
            ..showStart = true
            ..showStop = false
            ..time = 0
            ..osc = 0;
          sc.tableVisible = true;
        } else {
          // Hide the stopwatch during non-measuring steps.
          sw.visible = false;
        }
      }
    });
    if (sc.step > n) _showConclusion();
  }

  void _showConclusion() {
    setState(() => _scene.sw.pulse = false);
    _lab.showScenarioConclusion(
      scenarioIndex: _scene.scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 1000),
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${_scene.scenario + 1}'),
    );
  }

  void _addRow(int len, int mass, String t10, String period) {
    _scene.rows.add(_Row(_scene.rowSeq++, len, mass, t10, period, _scene.time));
  }

  /// HTML `updatePendulumVisuals()`: period from the string length and the
  /// attached items hidden from the toolkit.
  void _updatePendulumVisuals() {
    final sc = _scene;
    final len = sc.stringLength;
    if (len != null) {
      final l = int.parse(len) / 100;
      sc.basePeriod = 2 * math.pi * math.sqrt(l / _gravity);
      sc.items['s$len']?.visible = false;
    }
    final bob = sc.bobType;
    if (bob != null && len != null) sc.items[_PendulumScene.bobKey(bob)]?.visible = false;
  }

  // ------------------------------------------------------- interaction

  /// Hit-test in design coordinates using the painted geometry (the HTML
  /// raycaster hit boxes).
  String? _hitTest(Offset design) {
    final sc = _scene;
    final w = _d2w(design);
    if (sc.hasBob && (w - sc.bobWorld).distance < 1.5) return 'swing';
    for (final it in sc.items.values) {
      if (!it.visible || it.isString) continue;
      if ((w.dx - it.pos.dx).abs() <= 0.75 && (w.dy - it.pos.dy).abs() <= 1.0) return it.key;
    }
    for (final it in sc.items.values) {
      if (!it.visible || !it.isString) continue;
      final l = _strings[it.id]!.length;
      if ((w.dx - it.pos.dx).abs() <= 0.75 && w.dy <= it.pos.dy + 0.5 && w.dy >= it.pos.dy - l - 0.9) {
        return it.key;
      }
    }
    return null;
  }

  /// HTML pointerdown validation: only the item the current step needs.
  bool _isValid(String key) {
    final sc = _scene;
    if (key == 'swing') {
      return sc.hasBob &&
          !sc.isSwinging &&
          ((sc.scenario == 0 && sc.step == 3) || (sc.scenario == 1 && const [2, 4, 7].contains(sc.step)));
    }
    final it = sc.items[key]!;
    final str = it.isString, bob = !it.isString;
    if (sc.scenario == 0) {
      if (sc.step == 1 && str && it.id == '100') return true;
      if (sc.step == 2 && bob && it.id == 'iron') return true;
    } else {
      if (sc.step == 1 && ((str && it.id == '50') || (bob && it.id == 'iron'))) return true;
      if (sc.step == 3 && str && it.id == '150') return true;
      if (sc.step == 5 && str && it.id == '100') return true;
      if (sc.step == 6 && bob && it.id == 'lead') return true;
    }
    return false;
  }

  /// Pointer down on an object. Returns true when a drag has begun.
  bool _grab(Offset design) {
    if (!_lab.isLabActive || _scene.dragKey != null) return false;
    final key = _hitTest(design);
    if (key == null) return false;
    if (!_isValid(key)) {
      _lab.showToast(_t('wrong_item'), isError: true);
      return false;
    }
    // Finish any snap-back that is still running.
    if (_snapItem != null) {
      _snap.stop();
      _snapItem!.pos = _snapItem!.home;
      _snapItem = null;
    }
    _Audio.play(_Sound.pickup);
    setState(() => _scene.dragKey = key);
    return true;
  }

  void _dragTo(Offset design) {
    final sc = _scene;
    final key = sc.dragKey;
    if (key == null) return;
    final w = _d2w(design);
    if (key == 'swing') {
      final l = _strings[sc.stringLength]!.length;
      final angle = math.atan2(w.dx - _hookW.dx, l).clamp(-math.pi / 4, math.pi / 4);
      sc.angle = angle;
      sc.maxAngle = angle;
    } else {
      sc.items[key]!.pos = w;
    }
  }

  /// HTML pointerup: release the swing, or drop a toolkit item on the stand.
  void _release() {
    final sc = _scene;
    final key = sc.dragKey;
    if (key == null) return;
    if (key == 'swing') {
      setState(() {
        sc.dragKey = null;
        if (sc.maxAngle.abs() > 0.1) {
          sc.isSwinging = true;
          sc.pTime = 0;
          sc.sw.osc = 0;
          // Auto advance.
          if (sc.scenario == 0 && sc.step == 3) {
            _lab.after(const Duration(milliseconds: 500), () {
              if (mounted) _advanceStep();
            });
          }
        } else {
          sc.angle = 0; // Snap back if barely moved.
        }
      });
      return;
    }

    final it = sc.items[key]!;
    final dist = (it.pos - _hookW).distance;
    var hit = false;
    if (it.isString && dist < 10) hit = true;
    if (!it.isString && sc.stringLength != null && dist < 15) hit = true;

    if (!hit) {
      _Audio.play(_Sound.wrong);
      setState(() => sc.dragKey = null);
      _snapItem = it;
      _snapFrom = it.pos;
      _snap.forward(from: 0);
      return;
    }

    _Audio.play(_Sound.drop);
    setState(() {
      sc.dragKey = null;
      if (it.isString) {
        // Return the old string to the toolkit.
        final old = sc.stringLength == null ? null : sc.items['s${sc.stringLength}'];
        if (old != null) {
          old.pos = old.home;
          old.visible = true;
        }
        sc.stringLength = it.id;
      } else {
        final old = sc.bobType == null ? null : sc.items[_PendulumScene.bobKey(sc.bobType!)];
        if (old != null) {
          old.pos = old.home;
          old.visible = true;
        }
        sc.bobType = it.id;
      }
      it.pos = it.home;
      _updatePendulumVisuals();
    });

    // Step progression.
    if (sc.scenario == 0) {
      if (sc.step == 1 && it.isString) _advanceStep();
      if (sc.step == 2 && !it.isString) _advanceStep();
    } else {
      if (sc.step == 1 && sc.stringLength == '50' && sc.bobType == 'iron') _advanceStep();
      if (sc.step == 3 && it.isString && it.id == '150') _advanceStep();
      if (sc.step == 5 && it.isString && it.id == '100') {
        // Auto populate the table for the baseline.
        setState(() => _addRow(100, 50, (2.006 * 10).toStringAsFixed(2), '2.01'));
        _advanceStep();
      }
      if (sc.step == 6 && !it.isString && it.id == 'lead') _advanceStep();
    }
  }

  /// A tap is a pointerdown + pointerup at the same spot (the HTML drop
  /// test then runs with the item still in the toolkit).
  void _onTapUp(TapUpDetails d) {
    if (_grab(d.localPosition)) _release();
  }

  /// HTML `handleStopwatch(action)`.
  void _handleStopwatch(String action) {
    final sc = _scene;
    final sw = sc.sw;
    if (action == 'start') {
      setState(() {
        sw
          ..running = true
          ..time = 0
          ..osc = 0;
        // Auto-start the swing if needed so oscillations can occur.
        if (!sc.isSwinging) {
          sc.maxAngle = math.pi / 6;
          sc.isSwinging = true;
          sc.pTime = 0;
        }
        sw
          ..showStart = false
          ..showStop = true;
      });
      if (sc.scenario == 0 && sc.step == 4) _advanceStep();
    } else if (action == 'stop') {
      // Enforce 10 oscillations before allowing Stop.
      if (sw.osc < 10) {
        _lab.showToast(_t('wait_10_osc'), isError: true);
        return;
      }
      setState(() {
        sw
          ..running = false
          ..showStop = false;
        if (sc.scenario == 0) sw.showReset = true;
        final len = int.parse(sc.stringLength!);
        final mass = _bobs[sc.bobType]!.mass;
        _addRow(len, mass, (sc.basePeriod * 10).toStringAsFixed(2), sc.basePeriod.toStringAsFixed(2));
      });
      if (sc.scenario == 0 && sc.step == 5) _advanceStep();
      if (sc.scenario == 1 && const [2, 4, 7].contains(sc.step)) {
        setState(() {
          sc.isSwinging = false;
          sc.angle = 0;
        });
        _advanceStep();
      }
    } else {
      setState(() {
        sw
          ..time = 0
          ..osc = 0
          ..showReset = false
          ..showStart = true;
      });
      if (sc.scenario == 0 && sc.step == 6) {
        // Auto fill the remaining 2 trials.
        final len = int.parse(sc.stringLength!);
        final mass = _bobs[sc.bobType]!.mass;
        final p = sc.basePeriod;
        setState(() {
          _addRow(len, mass, (p * 10 + (_rng.nextDouble() * 0.04 - 0.02)).toStringAsFixed(2), p.toStringAsFixed(2));
          _addRow(len, mass, (p * 10 + (_rng.nextDouble() * 0.04 - 0.02)).toStringAsFixed(2), p.toStringAsFixed(2));
          sc.isSwinging = false;
          sc.angle = 0;
        });
        _advanceStep();
      }
    }
  }

  List<LabAction> _actions() {
    final sc = _scene;
    final sw = sc.sw;
    if (!sw.visible) return const [];
    final st = sc.step;
    final measureStep = (sc.scenario == 0 && st == 4) || (sc.scenario == 1 && const [2, 4, 7].contains(st));
    return [
      if (sw.showStart)
        LabAction(
          label: _t('start'),
          icon: Icons.play_arrow_rounded,
          color: _Colors.green,
          foreground: Colors.white,
          highlight: measureStep,
          onTap: () => _handleStopwatch('start'),
        ),
      if (sw.showStop)
        LabAction(
          label: _t('stop'),
          icon: Icons.stop_rounded,
          color: _Colors.red,
          foreground: Colors.white,
          highlight: sw.osc >= 10,
          onTap: () => _handleStopwatch('stop'),
        ),
      if (sw.showReset)
        LabAction(
          label: _t('reset'),
          icon: Icons.restart_alt,
          color: _Colors.slate500,
          foreground: Colors.white,
          highlight: sc.scenario == 0 && st == 6,
          onTap: () => _handleStopwatch('reset'),
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
        final sc = _scene;
        final inset = labOverlayInsets(context, _lab);
        final size = MediaQuery.sizeOf(context);
        final complete = sc.step > data.steps.length;
        final swHeight = 182 * s;
        return LabShell(
          controller: _lab,
          icon: Icons.ssid_chart,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: complete ? _t('objective_complete') : null,
          actions: _actions(),
          sidebarExtraTitle: _t('data_table'),
          sidebarExtra: sc.tableVisible ? _tableCard(p, s, overlay: false) : null,
          onReset: _fullReset,
          overlays: [
            if (sc.sw.visible)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _stopwatchCard(p, s),
              ),
            if (sc.tableVisible && !_lab.isSidebarOpen)
              Positioned(
                right: inset.right,
                bottom: inset.bottom,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.min(300 * s, size.width * 0.42),
                    maxHeight: math.max(
                      70.0,
                      size.height - inset.top - inset.bottom - (sc.sw.visible ? swHeight + 10 : 0),
                    ),
                  ),
                  child: _tableCard(p, s, overlay: true),
                ),
              ),
            if (sc.dragItem != null) Positioned.fill(child: IgnorePointer(child: _dropZone(s))),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_ItemPanRecognizer>(
                  _ItemPanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _lab.isLabActive && _hitTest(local) != null)
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _release())
                    ..onCancel = _release,
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTapUp = _onTapUp,
                ),
              },
              child: CustomPaint(
                size: _design,
                painter: _PendulumPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#stopwatch-ui`: dial with hand and digital time, the current
  /// Start / Stop / Reset button and the oscillation counter.
  Widget _stopwatchCard(LabPalette p, double s) {
    const indigo = Color(0xFF6366F1);
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, t, _) {
        final sw = _scene.sw;
        final ph = sw.pulse ? (((t % 2) / 2) / 0.7).clamp(0.0, 1.0) : 0.0;
        final actions = _actions();
        return Container(
          width: 132 * s,
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: (p.isDark ? _Colors.slate800 : Colors.white).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: indigo, width: 2),
            boxShadow: [
              const BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 6)),
              if (sw.pulse)
                BoxShadow(
                  color: _Colors.zslYellow.withValues(alpha: 0.7 * (1 - ph)),
                  spreadRadius: 10 * ph * s,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 13 * s, color: indigo),
                    SizedBox(width: 4 * s),
                    Text(
                      _t('stopwatch').toUpperCase(),
                      style: TextStyle(
                        color: indigo,
                        fontWeight: FontWeight.w800,
                        fontSize: 10 * s,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6 * s),
              Center(
                child: SizedBox(
                  width: 80 * s,
                  height: 80 * s,
                  child: CustomPaint(painter: _DialPainter(time: sw.time, isDark: p.isDark)),
                ),
              ),
              for (final a in actions) ...[
                SizedBox(height: 6 * s),
                LabActionButton(action: a, scale: s * 0.85, dense: true),
              ],
              SizedBox(height: 6 * s),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4 * s, horizontal: 4 * s),
                decoration: BoxDecoration(
                  color: p.isDark ? _Colors.slate700 : _Colors.slate200,
                  borderRadius: BorderRadius.circular(6 * s),
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _t('osc_counter').toUpperCase(),
                        style: TextStyle(
                          color: p.isDark ? _Colors.slate400 : _Colors.slate500,
                          fontSize: 8.5 * s,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '${sw.osc}',
                      style: TextStyle(
                        color: p.isDark ? Colors.white : _Colors.slate900,
                        fontSize: 19 * s,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Highlight alpha of a new table row (HTML `.highlight-row` for 1 s,
  /// then a 0.3 s fade).
  double _rowHighlight(double age) {
    if (age < 1) return 0.2;
    if (age < 1.3) return 0.2 * (1 - (age - 1) / 0.3);
    return 0;
  }

  /// HTML `#data-table-ui`: Length | Mass | Time for 10 osc | Time Period.
  Widget _tableCard(LabPalette p, double s, {required bool overlay}) {
    final f = overlay ? s : s * _lab.fontScale;
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, t, _) {
        final rows = _scene.rows;
        final head = TextStyle(color: p.textStrong, fontSize: 9 * f, fontWeight: FontWeight.w700, height: 1.2);
        final cell = TextStyle(color: p.text, fontSize: 10.5 * f, fontWeight: FontWeight.w600);
        final period = cell.copyWith(
          color: p.isDark ? const Color(0xFF818CF8) : _Colors.indigo600,
          fontWeight: FontWeight.w800,
        );
        Widget c(String text, TextStyle st) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 3 * s, vertical: 4 * s),
              child: Text(text, textAlign: TextAlign.center, style: st),
            );
        final table = Table(
          border: TableBorder.all(color: p.isDark ? const Color(0x26FFFFFF) : const Color(0x26000000)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(0.9),
            2: FlexColumnWidth(1.25),
            3: FlexColumnWidth(1.15),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: p.isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000)),
              children: [
                c(_t('th_length'), head),
                c(_t('th_mass'), head),
                c(_t('th_t10'), head),
                c(_t('th_period'), head),
              ],
            ),
            for (final r in rows)
              TableRow(
                decoration: BoxDecoration(
                  color: _Colors.zslYellow.withValues(alpha: _rowHighlight(t - r.addedAt)),
                ),
                children: [
                  c('${r.len}', cell),
                  c(labFormat(_t('mass_fmt'), {'m': r.mass}), cell),
                  c(r.t10, cell),
                  c(r.period, period),
                ],
              ),
          ],
        );
        final body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (overlay) ...[
              Row(
                children: [
                  Icon(Icons.table_chart_outlined, size: 14 * s, color: p.text),
                  SizedBox(width: 6 * s),
                  Expanded(
                    child: Text(
                      _t('data_table'),
                      style: TextStyle(color: p.text, fontSize: 12 * s, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              Divider(height: 10 * s, color: p.cardBorder),
            ],
            table,
            if (rows.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 6 * s),
                child: Text(
                  _t('no_rows'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.textMuted, fontSize: 10.5 * f),
                ),
              ),
          ],
        );
        if (overlay) {
          return Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: (p.isDark ? _Colors.slate800 : Colors.white).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: p.isDark ? _Colors.slate600 : _Colors.slate300),
              boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: SingleChildScrollView(child: body),
          );
        }
        return Container(
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: body,
        );
      },
    );
  }

  /// HTML `#global-drop-zone` shown while a toolkit item is dragged.
  Widget _dropZone(double s) {
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, t, _) {
        final o = 0.75 + 0.25 * math.cos(t * math.pi);
        return Padding(
          padding: EdgeInsets.all(48 * s),
          child: Center(
            child: Opacity(
              opacity: o,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomPaint(
                  foregroundPainter: _DashedBorderPainter(
                    color: _Colors.zslYellow.withValues(alpha: 0.6),
                    radius: 22 * s,
                    width: 3 * s,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 26 * s, vertical: 12 * s),
                    decoration: BoxDecoration(
                      color: _Colors.zslYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(22 * s),
                    ),
                    child: Text(
                      _t('drop_here'),
                      style: TextStyle(
                        color: _Colors.zslYellow,
                        fontWeight: FontWeight.w800,
                        fontSize: 22 * s,
                        letterSpacing: 3,
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
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Exploring Simple Pendulum Motion',
    'app_subtitle': 'Class 7 • Measurement of Time and Motion',
    'scen_1_opt': 'Scenario 1: The Constant Beat of a Pendulum',
    'scen_2_opt': 'Scenario 2: What Changes the Swing?',
    'sci_conclusion': 'Success!',
    'drop_here': 'DROP HERE',
    'stopwatch': 'Stopwatch',
    'start': 'Start',
    'stop': 'Stop',
    'reset': 'Reset',
    'osc_counter': 'Oscillations',
    'data_table': 'Observation Table',
    'wait_10_osc': 'Please wait for 10 oscillations before stopping!',
    'conclusion_1':
        "Notice that for a 100 cm pendulum, the time for one swing (the Time Period) is almost the same every time you measure it. This constant 'beat' is why pendulums were used in clocks!",
    'conclusion_2':
        "You've discovered what Galileo did! A pendulum's swing time depends ONLY on its LENGTH, not the mass of the bob. Longer pendulums swing slower, and shorter ones swing faster.",
    // Strings that were hard-coded (English only) in the HTML.
    'wrong_item': 'Not the right item for this step!',
    'objective_complete': 'Objective Complete!',
    'th_length': 'Length (cm)',
    'th_mass': 'Mass',
    'th_t10': 'Time for 10 osc (s)',
    'th_period': 'Time Period (s)',
    'no_rows': 'No readings recorded yet.',
    'unit_cm': 'cm',
    'unit_g': 'g',
    'mass_fmt': '{m}g',
    'bob_wood': 'WOOD',
    'bob_iron': 'IRON',
    'bob_lead': 'LEAD',
    'lbl_stand': 'Rigid Support',
    'lbl_toolkit': 'Toolkit',
  },
  'hi': {
    'app_title': 'सरल लोलक की गति का अन्वेषण',
    'app_subtitle': 'कक्षा 7 • समय और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: लोलक की निरंतर धड़कन',
    'scen_2_opt': 'परिदृश्य 2: दोलन को क्या बदलता है?',
    'sci_conclusion': 'सफलता!',
    'drop_here': 'यहाँ छोड़ें',
    'stopwatch': 'स्टॉपवॉच',
    'start': 'शुरू',
    'stop': 'रुकें',
    'reset': 'रीसेट',
    'osc_counter': 'दोलन',
    'data_table': 'अवलोकन तालिका',
    'wait_10_osc': 'रुकने से पहले कृपया 10 दोलनों की प्रतीक्षा करें!',
    'conclusion_1':
        'ध्यान दें कि 100 सेमी पेंडुलम के लिए, एक स्विंग (समय अवधि) का समय लगभग समान होता है। इसी कारण घड़ियों में पेंडुलम का उपयोग किया जाता था!',
    'conclusion_2':
        'पेंडुलम का झूलने का समय केवल उसकी लंबाई पर निर्भर करता है, न कि बॉब के द्रव्यमान पर। लंबे पेंडुलम धीमे झूलते हैं, और छोटे पेंडुलम तेज।',
    'wrong_item': 'इस चरण के लिए यह सही वस्तु नहीं है!',
    'objective_complete': 'उद्देश्य पूर्ण!',
    'th_length': 'लंबाई (सेमी)',
    'th_mass': 'द्रव्यमान',
    'th_t10': '10 दोलनों का समय (सेकंड)',
    'th_period': 'समय अवधि (सेकंड)',
    'no_rows': 'अभी तक कोई माप दर्ज नहीं हुआ।',
    'unit_cm': 'सेमी',
    'unit_g': 'ग्रा',
    'mass_fmt': '{m} ग्रा',
    'bob_wood': 'लकड़ी',
    'bob_iron': 'लोहा',
    'bob_lead': 'सीसा',
    'lbl_stand': 'दृढ़ आधार',
    'lbl_toolkit': 'टूलकिट',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To set up a simple pendulum of fixed length (100 cm) and experimentally determine that its time period is constant.',
      steps: [
        LabStep(
          concept: 'Setup String',
          action: 'DRAG the 100 cm string from the toolkit to the hook on the support stand.',
          observation: 'The string hangs vertically from the support stand.',
        ),
        LabStep(
          concept: 'Attach Bob',
          action: 'DRAG the iron bob (50g) and ATTACH it to the bottom of the string.',
          observation: 'The pendulum is now complete and at rest in its mean position.',
        ),
        LabStep(
          concept: 'Start Oscillation',
          action: 'CLICK and DRAG the bob to one side and RELEASE it.',
          observation: 'The pendulum swings back and forth in oscillatory motion.',
        ),
        LabStep(
          concept: 'Timing',
          action: "CLICK 'Start' on the stopwatch when the bob passes its center line.",
          observation: 'The stopwatch runs and the counter increments on each full oscillation.',
        ),
        LabStep(
          concept: 'Measurement',
          action: "CLICK 'Stop' on the stopwatch when the Counter reaches '10'.",
          observation: 'The time is recorded in the data table.',
        ),
        LabStep(
          concept: 'Verification',
          action: "CLICK 'Reset' on the stopwatch to auto-complete 2 more trials.",
          observation: 'The Time Period is calculated and is consistent across trials.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To investigate how the length of the string and the mass of the bob affect the time period.',
      steps: [
        LabStep(
          concept: 'Test Length (Short)',
          action: 'DRAG the 50 cm string from the toolkit to the stand.',
          observation: 'A 50 cm pendulum with an iron bob is assembled.',
        ),
        LabStep(
          concept: 'Measure (50cm)',
          action: "CLICK 'Start' to measure 10 oscillations, then 'Stop'.",
          observation: 'The shorter pendulum swings noticeably faster.',
        ),
        LabStep(
          concept: 'Test Length (Long)',
          action: 'DRAG the 150 cm string to the stand to replace it.',
          observation: 'A 150 cm pendulum is now assembled.',
        ),
        LabStep(
          concept: 'Measure (150cm)',
          action: "CLICK 'Start' to measure 10 oscillations, then 'Stop'.",
          observation: 'The longer pendulum swings much slower. Length increases Time Period.',
        ),
        LabStep(
          concept: 'Baseline Mass',
          action: 'DRAG the 100 cm string back to the stand.',
          observation: 'Baseline 100 cm / 50g Iron bob is ready. (Measurement auto-filled).',
        ),
        LabStep(
          concept: 'Change Mass',
          action: 'DRAG the heavy Lead bob (100g) to the pendulum.',
          observation: 'The bob is swapped without changing the length.',
        ),
        LabStep(
          concept: 'Measure (Heavy)',
          action: "CLICK 'Start' to measure 10 oscillations, then 'Stop'.",
          observation: 'The heavy pendulum swings at the EXACT same rate as the lighter one.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'एक निश्चित लंबाई (100 सेमी) का एक सरल लोलक स्थापित करना और प्रयोगात्मक रूप से यह निर्धारित करना कि इसकी समय अवधि स्थिर है।',
      steps: [
        LabStep(
          concept: 'धागा सेट करें',
          action: 'टूलकिट से 100 सेमी धागे को स्टैंड के हुक पर खींचें।',
          observation: 'धागा लंबवत लटकता है।',
        ),
        LabStep(
          concept: 'बॉब संलग्न करें',
          action: 'लोहे के बॉब (50 ग्राम) को खींचें और इसे धागे के नीचे संलग्न करें।',
          observation: 'पेंडुलम अब अपनी माध्य स्थिति में पूर्ण है।',
        ),
        LabStep(
          concept: 'दोलन शुरू करें',
          action: 'बॉब को एक तरफ खींचें और छोड़ दें।',
          observation: 'पेंडुलम दोलन गति में आगे-पीछे झूलता है।',
        ),
        LabStep(
          concept: 'समय',
          action: "जब बॉब अपनी मध्य रेखा से गुजरे तो स्टॉपवॉच पर 'प्रारंभ' पर क्लिक करें।",
          observation: 'स्टॉपवॉच चलती है।',
        ),
        LabStep(
          concept: 'माप',
          action: "काउंटर '10' तक पहुंचने पर 'स्टॉप' पर क्लिक करें।",
          observation: 'समय डेटा तालिका में दर्ज किया गया है।',
        ),
        LabStep(
          concept: 'सत्यापन',
          action: "2 और परीक्षणों को स्वतः पूर्ण करने के लिए 'रीसेट' पर क्लिक करें।",
          observation: 'समय अवधि की गणना की जाती है और यह सुसंगत है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'यह जांचने के लिए कि धागे की लंबाई और बॉब का द्रव्यमान समय अवधि को कैसे प्रभावित करते हैं।',
      steps: [
        LabStep(
          concept: 'लंबाई परीक्षण (छोटा)',
          action: 'टूलकिट से 50 सेमी धागे को स्टैंड पर खींचें।',
          observation: '50 सेमी पेंडुलम इकट्ठा किया गया है।',
        ),
        LabStep(
          concept: 'माप (50 सेमी)',
          action: "10 दोलनों को मापने के लिए 'प्रारंभ' पर क्लिक करें, फिर 'स्टॉप' पर।",
          observation: 'छोटा पेंडुलम तेजी से झूलता है।',
        ),
        LabStep(
          concept: 'लंबाई परीक्षण (लंबा)',
          action: 'इसे बदलने के लिए 150 सेमी धागे को स्टैंड पर खींचें।',
          observation: 'अब 150 सेमी पेंडुलम तैयार है।',
        ),
        LabStep(
          concept: 'माप (150 सेमी)',
          action: "10 दोलनों को मापने के लिए 'प्रारंभ' पर क्लिक करें, फिर 'स्टॉप' पर।",
          observation: 'लंबा पेंडुलम धीमा झूलता है।',
        ),
        LabStep(
          concept: 'आधार रेखा द्रव्यमान',
          action: '100 सेमी धागे को वापस स्टैंड पर खींचें।',
          observation: 'आधार रेखा 100 सेमी / 50 ग्राम तैयार है।',
        ),
        LabStep(
          concept: 'द्रव्यमान बदलें',
          action: 'भारी लीड बॉब (100 ग्राम) को पेंडुलम पर खींचें।',
          observation: 'लंबाई बदले बिना बॉब की अदला-बदली की जाती है।',
        ),
        LabStep(
          concept: 'माप (भारी)',
          action: "10 दोलनों को मापने के लिए 'प्रारंभ' पर क्लिक करें, फिर 'स्टॉप' पर।",
          observation: 'भारी पेंडुलम हल्के पेंडुलम के समान दर से झूलता है।',
        ),
      ],
    ),
  ],
};

// ============================================================== MODEL

const double _gravity = 9.8;
const Size _design = Size(1000, 560);

/// Design px per Three.js world unit, and the design position of world (0, 0)
/// (the table top under the stand). The HTML camera looks straight at the
/// bench, so a front view with a slight top-down tilt is used.
const double _k = 28;
const Offset _origin = Offset(430, 480);

/// The hook on the stand arm, where the pendulum group hangs (HTML (1, 11.3)).
const Offset _hookW = Offset(1, 11.3);

Offset _w2d(double x, double y) => Offset(_origin.dx + x * _k, _origin.dy - y * _k);
Offset _wp(Offset w) => _w2d(w.dx, w.dy);
Offset _d2w(Offset d) => Offset((d.dx - _origin.dx) / _k, (_origin.dy - d.dy) / _k);

@immutable
class _StringConf {
  const _StringConf(this.color, this.length);
  final Color color;
  final double length; // world units (50 cm = 3)
}

@immutable
class _BobConf {
  const _BobConf(this.color, this.size, this.mass);
  final Color color;
  final double size; // sphere radius in world units
  final int mass; // grams
}

const Map<String, _StringConf> _strings = {
  '50': _StringConf(Color(0xFF94A3B8), 3),
  '100': _StringConf(Color(0xFF64748B), 6),
  '150': _StringConf(Color(0xFF475569), 9),
};

const Map<String, _BobConf> _bobs = {
  'wood': _BobConf(Color(0xFFD97706), 0.5, 20),
  'iron': _BobConf(Color(0xFF94A3B8), 0.45, 50),
  'lead': _BobConf(Color(0xFF334155), 0.4, 100),
};

/// A draggable toolkit item (HTML `createToolkitItem`). [pos] is the group
/// position in world units: the top of a string, or the centre of a bob.
class _Item {
  _Item(this.key, this.type, this.id, this.home) : pos = home;

  final String key; // s50, s100, s150, bWood, bIron, bLead
  final String type; // 'string' | 'bob'
  final String id; // '50' / 'iron' ...
  final Offset home;
  Offset pos;
  bool visible = true;

  bool get isString => type == 'string';
}

/// One row of the observation table.
@immutable
class _Row {
  const _Row(this.id, this.len, this.mass, this.t10, this.period, this.addedAt);
  final int id;
  final int len;
  final int mass;
  final String t10;
  final String period;
  final double addedAt; // scene time, for the 1 s highlight
}

class _Stopwatch {
  bool visible = false;
  bool running = false;
  bool showStart = false;
  bool showStop = false;
  bool showReset = false;

  /// HTML `.pulse-border` (set at 10 oscillations, cleared at conclusion).
  bool pulse = false;
  double time = 0;
  int osc = 0;
}

/// Mutable scene state read by the painter and overlays every frame.
class _PendulumScene {
  int scenario = 0;
  int step = 1;

  String? stringLength; // '50' | '100' | '150'
  String? bobType; // 'wood' | 'iron' | 'lead'
  bool isSwinging = false;
  double angle = 0; // pendulumGroup.rotation.z
  double maxAngle = 0;
  double pTime = 0;
  double basePeriod = 0;

  final Map<String, _Item> items = {};
  final _Stopwatch sw = _Stopwatch();
  bool tableVisible = false;
  final List<_Row> rows = [];
  int rowSeq = 0;

  /// Key of the toolkit item being dragged, or 'swing' while pulling the bob.
  String? dragKey;
  double time = 0;

  bool get swingDrag => dragKey == 'swing';
  _Item? get dragItem => dragKey == null || swingDrag ? null : items[dragKey];

  /// HTML `buildScenario()` + the state reset of `resetApp(true)`.
  void build() {
    stringLength = null;
    bobType = null;
    isSwinging = false;
    angle = 0;
    maxAngle = 0;
    pTime = 0;
    basePeriod = 0;
    dragKey = null;
    items
      ..clear()
      ..['s50'] = _Item('s50', 'string', '50', const Offset(-8, 10.5))
      ..['s100'] = _Item('s100', 'string', '100', const Offset(-6, 10.5))
      ..['s150'] = _Item('s150', 'string', '150', const Offset(-4, 10.5))
      ..['bWood'] = _Item('bWood', 'bob', 'wood', const Offset(-8, 3))
      ..['bIron'] = _Item('bIron', 'bob', 'iron', const Offset(-6, 3))
      ..['bLead'] = _Item('bLead', 'bob', 'lead', const Offset(-4, 3));
    final s = sw;
    s
      ..visible = false
      ..running = false
      ..showStart = false
      ..showStop = false
      ..showReset = false
      ..pulse = false
      ..time = 0
      ..osc = 0;
    tableVisible = false;
    rows.clear();
  }

  static String bobKey(String id) => 'b${id[0].toUpperCase()}${id.substring(1)}';

  /// HTML `highlightToolkit()`: the items needed for the current step.
  Set<String> get highlighted {
    if (scenario == 0) {
      if (step == 1) return {'s100'};
      if (step == 2) return {'bIron'};
    } else {
      if (step == 1) return {'s50', 'bIron'};
      if (step == 3) return {'s150'};
      if (step == 5) return {'s100'};
      if (step == 6) return {'bLead'};
    }
    return const {};
  }

  /// World position of the pendulum bob centre at the current angle.
  Offset get bobWorld {
    final l = _strings[stringLength]!.length;
    return Offset(_hookW.dx + l * math.sin(angle), _hookW.dy - l * math.cos(angle));
  }

  bool get hasBob => stringLength != null && bobType != null;
}

// ============================================================ PAINTING

const Color _metal = Color(0xFF94A3B8);
const Color _boardColor = Color(0xFFCA8A04);
const Color _tableColor = Color(0xFFDDB17E);
const Color _dimTarget = Color(0xFF555555);

double _textWidth(String text, double size, FontWeight weight) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
        height: 1.2,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.width;
}

/// Draws the lab bench, rigid stand, toolkit board, toolkit items and the
/// pendulum (HTML `buildScenario()` + `animate()`).
class _PendulumPainter extends CustomPainter {
  _PendulumPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _PendulumScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRoom(canvas, size);
    _paintBoard(canvas);
    _paintStand(canvas);
    _paintCenterLine(canvas);

    final hl = scene.highlighted;
    final drag = scene.dragItem;
    // Strings first, bobs in front of them (as in the 3D scene).
    for (final item in scene.items.values) {
      if (!item.visible || !item.isString || item == drag) continue;
      _paintToolString(canvas, item, hl.contains(item.key));
    }
    for (final item in scene.items.values) {
      if (!item.visible || item.isString || item == drag) continue;
      _paintToolBob(canvas, item, hl.contains(item.key));
    }

    _paintPendulum(canvas);
    if (scene.swingDrag) _paintProtractor(canvas);

    if (drag != null) {
      _paintDropTarget(canvas, drag);
      if (drag.isString) {
        _paintToolString(canvas, drag, true, lifted: true);
      } else {
        _paintToolBob(canvas, drag, true, lifted: true);
      }
    }

    if (showLabels) {
      labPill(canvas, tr('lbl_stand'), _w2d(4, 12.9), size: 12);
      labPill(canvas, tr('lbl_toolkit'), _w2d(-6, 12.9), size: 12);
    }
  }

  // ------------------------------------------------------------ room

  void _paintRoom(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    const tableBack = 466.0, tableFront = 502.0;
    // Wall (HTML grey backdrop plane 0xe2e8f0).
    final wall = Rect.fromLTRB(bleed.left, bleed.top, bleed.right, tableBack);
    canvas.drawRect(
      wall,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFFC9D2DE), Color(0xFFB4BFCD)]
              : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, tableBack)),
    );
    // Faint lab grid on the wall.
    final grid = Paint()
      ..color = Colors.black.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var x = -400.0; x <= size.width + 400; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, tableBack), grid);
    }
    for (var y = tableBack - 40; y >= bleed.top; y -= 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
    // Soft shadow where the wall meets the bench.
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, tableBack - 18, bleed.right, tableBack),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.12)],
        ).createShader(Rect.fromLTRB(0, tableBack - 18, 10, tableBack)),
    );
    // Bench top (HTML table 0xddb17e) seen slightly from above.
    final top = Rect.fromLTRB(bleed.left, tableBack, bleed.right, tableFront);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_tableColor, -0.1), labShade(_tableColor, 0.08)],
        ).createShader(Rect.fromLTRB(0, tableBack, 10, tableFront)),
    );
    final grain = Paint()
      ..color = labShade(_tableColor, -0.35).withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (final y in [472.0, 479.0, 487.0, 496.0]) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grain);
    }
    // Front edge + front face.
    canvas.drawLine(
      Offset(bleed.left, tableFront),
      Offset(bleed.right, tableFront),
      Paint()
        ..color = labShade(_tableColor, 0.3)
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, tableFront + 1, bleed.right, bleed.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_tableColor, -0.18), labShade(_tableColor, -0.5)],
        ).createShader(Rect.fromLTRB(0, tableFront, 10, 640)),
    );
  }

  // ----------------------------------------------------------- board

  void _paintBoard(Canvas canvas) {
    final front = Rect.fromLTRB(_w2d(-10, 0).dx, _w2d(0, 12).dy - 6, _w2d(-2, 0).dx, _origin.dy - 6);
    labGroundShadow(canvas, Offset(front.center.dx, front.bottom + 4), front.width * 1.05, 16, opacity: 0.25);
    labBox3D(canvas, front, 12, _boardColor, angle: -1.75);
    // Pegboard frame and holes.
    final inner = front.deflate(9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = labShade(_boardColor, -0.3).withValues(alpha: 0.6),
    );
    final hole = Paint()..color = labShade(_boardColor, -0.45).withValues(alpha: 0.35);
    for (var y = inner.top + 12; y < inner.bottom - 6; y += 18) {
      for (var x = inner.left + 12; x < inner.right - 6; x += 18) {
        canvas.drawCircle(Offset(x, y), 1.8, hole);
      }
    }
    // Pegs the strings hang from.
    for (final x in [-8.0, -6.0, -4.0]) {
      final c = _w2d(x, 10.5 + 0.12);
      labSphere(canvas, c, 4.5, const Color(0xFF64748B), highlight: 0.5);
    }
  }

  // ----------------------------------------------------------- stand

  void _paintStand(Canvas canvas) {
    final base = Rect.fromLTRB(_w2d(2.5, 0).dx, 479, _w2d(5.5, 0).dx, 493);
    labGroundShadow(canvas, Offset(base.center.dx, base.bottom + 2), base.width * 1.2, 14, opacity: 0.3);
    labBox3D(canvas, base, 16, _metal, angle: -1.75);
    // Vertical rod (r = 0.2, 12 high).
    final rodTop = _w2d(4, 12).dy;
    labCylinder(
      canvas,
      Rect.fromLTRB(_w2d(3.8, 0).dx, rodTop, _w2d(4.2, 0).dx, 484),
      _metal,
      tilt: 0.5,
    );
    // Horizontal arm (r = 0.15) from x = 0.5 to the rod.
    final armRect = Rect.fromLTRB(_w2d(0.5, 0).dx, _w2d(0, 11.65).dy, _w2d(4.2, 0).dx, _w2d(0, 11.35).dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(armRect, Radius.circular(armRect.height / 2)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_metal, 0.45), _metal, labShade(_metal, -0.45)],
        ).createShader(armRect),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(armRect.left + 1, armRect.center.dy), width: 4, height: armRect.height),
      Paint()..color = labShade(_metal, 0.2),
    );
    // Clamp boss holding the arm on the rod.
    final boss = Rect.fromCenter(center: _w2d(4, 11.5), width: 22, height: 18);
    labBox3D(canvas, boss, 5, labShade(_metal, -0.2), angle: -1.75, radius: 3);
    // Hook ring (torus r = 0.2) at the pivot.
    final pivot = _wp(_hookW);
    canvas.drawCircle(
      pivot,
      0.2 * _k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = labShade(_metal, -0.25),
    );
    canvas.drawCircle(
      pivot.translate(-1, -1),
      0.2 * _k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  /// Dotted centre (mean position) line below the hook.
  void _paintCenterLine(Canvas canvas) {
    final pivot = _wp(_hookW);
    labDashedLine(
      canvas,
      pivot,
      pivot.translate(0, 12 * _k),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 1.5,
      dash: 0.2 * _k,
      gap: 0.2 * _k,
    );
  }

  // --------------------------------------------------------- toolkit

  Color _itemColor(Color c, bool active) => active ? c : Color.lerp(c, _dimTarget, 0.5)!;

  double get _pulse => 0.5 + 0.5 * math.sin(scene.time * 4);

  void _drawString(Canvas canvas, Offset a, Offset b, Color color) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = labShade(color, -0.45)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintToolString(Canvas canvas, _Item item, bool active, {bool lifted = false}) {
    final conf = _strings[item.id]!;
    final top = _wp(item.pos);
    final bottom = _w2d(item.pos.dx, item.pos.dy - conf.length);
    final color = _itemColor(conf.color, active);
    if (lifted) {
      canvas.drawLine(
        top.translate(6, 8),
        bottom.translate(6, 8),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    } else if (active) {
      canvas.drawLine(
        top,
        bottom,
        Paint()
          ..color = _Colors.zslYellow.withValues(alpha: 0.25 + 0.3 * _pulse)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    _drawString(canvas, top, bottom, color);
    // Loop at the top and a knot at the bottom end.
    canvas.drawCircle(
      top,
      4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = labShade(color, -0.3),
    );
    canvas.drawCircle(bottom, 3, Paint()..color = labShade(color, -0.3));
    if (showLabels) {
      labText(
        canvas,
        '${item.id} ${tr('unit_cm')}',
        _w2d(item.pos.dx, item.pos.dy - conf.length - 0.5),
        size: 12,
        weight: FontWeight.w800,
        color: Colors.white,
        background: const Color(0xCC0F172A),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        opacity: active ? 1 : 0.4,
      );
    }
  }

  void _drawBob(Canvas canvas, Offset c, _BobConf conf, Color color, {double angle = 0}) {
    final r = conf.size * _k;
    // Small hook ring on top of the bob, along the string direction.
    final up = Offset(-math.sin(angle), -math.cos(angle));
    final hook = c + up * ((conf.size + 0.1) * _k);
    canvas.drawCircle(
      hook,
      0.1 * _k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = labShade(_metal, -0.2),
    );
    labSphere(canvas, c, r, color, highlight: 0.55, shade: 0.6);
    // Metallic specular spot.
    canvas.drawCircle(
      c.translate(-r * 0.35, -r * 0.4),
      r * 0.22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
  }

  void _paintToolBob(Canvas canvas, _Item item, bool active, {bool lifted = false}) {
    final conf = _bobs[item.id]!;
    final c = _wp(item.pos);
    final r = conf.size * _k;
    if (lifted) {
      labGroundShadow(canvas, c.translate(7, r + 10), r * 2.2, r * 0.7, opacity: 0.25);
    } else if (active) {
      labGlow(canvas, c, r * 2.6, _Colors.zslYellow, intensity: 0.35 + 0.35 * _pulse);
    }
    _drawBob(canvas, c, conf, _itemColor(conf.color, active));
    if (showLabels) {
      final at = _w2d(item.pos.dx, item.pos.dy - 1.0);
      final name = tr('bob_${item.id}');
      final mass = labFormat(tr('mass_fmt'), {'m': conf.mass});
      final w = math.max(_textWidth(name, 12, FontWeight.w800), _textWidth(mass, 11, FontWeight.w700)) + 18;
      final rect = Rect.fromCenter(center: at, width: w, height: 32);
      final op = active ? 1.0 : 0.4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(9)),
        Paint()..color = const Color(0xCC0F172A).withValues(alpha: 0.8 * op),
      );
      labText(canvas, name, at.translate(0, -7), size: 12, weight: FontWeight.w800, opacity: op);
      labText(canvas, mass, at.translate(0, 8), size: 11, weight: FontWeight.w700, color: const Color(0xFFCBD5E1), opacity: op);
    }
  }

  // -------------------------------------------------------- pendulum

  void _paintPendulum(Canvas canvas) {
    final len = scene.stringLength;
    if (len == null) return;
    final conf = _strings[len]!;
    final pivot = _wp(_hookW);
    final a = scene.angle;
    final end = _w2d(_hookW.dx + conf.length * math.sin(a), _hookW.dy - conf.length * math.cos(a));

    // Faint swing path (amplitude arc) while oscillating.
    if (scene.isSwinging && scene.maxAngle.abs() > 0.05) {
      final m = scene.maxAngle.abs();
      final r = conf.length * _k;
      final path = Path()
        ..addArc(Rect.fromCircle(center: pivot, radius: r), math.pi / 2 - m, 2 * m);
      labDashedPath(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _Colors.indigo600.withValues(alpha: 0.3),
        dash: 5,
        gap: 5,
      );
    }

    final bob = scene.bobType;
    if (bob != null) {
      final bc = _bobs[bob]!;
      // Shadow of the bob on the bench.
      final h = (_origin.dy - end.dy) / _k;
      labGroundShadow(canvas, Offset(end.dx, 488), bc.size * _k * (2.6 - h * 0.08), 7,
          opacity: (0.32 - h * 0.015).clamp(0.08, 0.3));
    }
    _drawString(canvas, pivot, end, conf.color);
    if (bob != null) {
      _drawBob(canvas, end, _bobs[bob]!, _bobs[bob]!.color, angle: a);
    }
  }

  /// HTML `protractorMesh`: half ring of radius 4 shown while pulling the bob.
  void _paintProtractor(Canvas canvas) {
    final pivot = _wp(_hookW);
    final r = 4 * _k;
    final rect = Rect.fromCircle(center: pivot, radius: r);
    canvas.drawArc(
      rect,
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1 * _k
        ..color = Colors.black.withValues(alpha: 0.2),
    );
    final tick = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1.2;
    for (var d = -90; d <= 90; d += 10) {
      final t = d * math.pi / 180;
      final u = Offset(math.sin(t), math.cos(t));
      final len = d % 30 == 0 ? 10.0 : 6.0;
      canvas.drawLine(pivot + u * r, pivot + u * (r - len), tick);
    }
    final a = scene.angle;
    canvas.drawArc(
      Rect.fromCircle(center: pivot, radius: r - 2),
      math.pi / 2,
      -a,
      true,
      Paint()..color = _Colors.zslYellow.withValues(alpha: 0.22),
    );
    if (showLabels) {
      final mid = pivot + Offset(math.sin(a / 2), math.cos(a / 2)) * (r + 16);
      labText(
        canvas,
        '${(a.abs() * 180 / math.pi).round()}°',
        mid,
        size: 12,
        weight: FontWeight.w800,
        color: _Colors.slate800,
        background: const Color(0xF2FFFFFF),
        border: _Colors.zslYellow,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      );
    }
  }

  /// Pulsing ring where the dragged item will attach.
  void _paintDropTarget(Canvas canvas, _Item item) {
    Offset? at;
    if (item.isString) {
      at = _wp(_hookW);
    } else if (scene.stringLength != null) {
      at = _w2d(_hookW.dx, _hookW.dy - _strings[scene.stringLength]!.length);
    }
    if (at == null) return;
    final p = _pulse;
    canvas.drawCircle(
      at,
      14 + 6 * p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.zslYellow.withValues(alpha: 0.5 + 0.4 * (1 - p)),
    );
    labGlow(canvas, at, 26, _Colors.zslYellow, intensity: 0.35);
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
}

/// Analogue stopwatch face (HTML `#sw-hand`: one turn every 6 s) with the
/// digital `00.00` display.
class _DialPainter extends CustomPainter {
  _DialPainter({required this.time, required this.isDark});

  final double time;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = isDark ? _Colors.slate900 : _Colors.slate100);
    canvas.drawCircle(
      c,
      r - r * 0.05,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.1
        ..color = isDark ? _Colors.slate700 : _Colors.slate300,
    );
    final tick = Paint()..color = isDark ? _Colors.slate500 : _Colors.slate400;
    for (var i = 0; i < 60; i++) {
      final a = i * math.pi / 30;
      final u = Offset(math.sin(a), -math.cos(a));
      final major = i % 5 == 0;
      tick.strokeWidth = major ? 1.6 : 0.8;
      canvas.drawLine(c + u * (r * 0.84), c + u * (r * (major ? 0.7 : 0.77)), tick);
    }
    final a = time * 60 * math.pi / 180;
    final tip = c + Offset(math.sin(a), -math.cos(a)) * (r * 0.9);
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = const Color(0xFF6366F1)
        ..strokeWidth = math.max(2, r * 0.07)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, r * 0.12, Paint()..color = _Colors.indigo600);
    final text = time.toStringAsFixed(2).padLeft(5, '0');
    labText(
      canvas,
      text,
      Offset(c.dx, c.dy + r * 0.5),
      size: r * 0.3,
      weight: FontWeight.w800,
      color: isDark ? Colors.white : _Colors.slate900,
      background: isDark ? const Color(0xB3000000) : const Color(0xE6FFFFFF),
      padding: EdgeInsets.symmetric(horizontal: r * 0.08, vertical: 0),
      radius: 4,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.time != time || old.isDark != isDark;
}

/// Dashed rounded border (the CSS `border-dashed` of the drop zone).
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius, required this.width});

  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    labDashedPath(
      canvas,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: 12,
      gap: 8,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.width != width;
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
