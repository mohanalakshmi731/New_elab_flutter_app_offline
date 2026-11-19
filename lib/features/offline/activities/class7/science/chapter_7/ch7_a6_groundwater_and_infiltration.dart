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

/// Class 7 Science • Chapter 7 • Activity 6
/// Groundwater and Infiltration.
///
/// Native Flutter port of `Cl7S-Ch7-A6-Groundwater_and_Infiltration.html`.
/// Scenario 1 races water through gravel, sand and clay in inverted
/// bottles (with a seepage bar chart and a microscopic view). Scenario 2
/// builds ground layers in a tank, rains on them to form an aquifer and
/// extracts the groundwater with a handpump.
class Ch7A6GroundwaterAndInfiltrationPage extends StatefulWidget {
  const Ch7A6GroundwaterAndInfiltrationPage({super.key});

  @override
  State<Ch7A6GroundwaterAndInfiltrationPage> createState() => _Ch7A6GroundwaterAndInfiltrationPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, drop 2364, pickup 2356, bubble 732,
/// splash 1311, magic 871.
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
  bubble('bubble.mp3'),
  splash('splash.mp3'),
  magic('magic.mp3');

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

/// A toolbox item (HTML `.tool-item`).
class _ToolDef {
  const _ToolDef(this.icon, this.color, this.labelKey, this.tipKey);
  final IconData icon;
  final Color color;
  final String labelKey;
  final String tipKey;
}

const Map<String, _ToolDef> _toolDefs = {
  's1-bottles': _ToolDef(Icons.science, Color(0xFF38BDF8), 'lbl_bottles', 'tip_bottles'),
  's1-materials': _ToolDef(Icons.shopping_bag, Color(0xFFB45309), 'lbl_materials', 'tip_materials'),
  's1-water': _ToolDef(Icons.water_drop, Color(0xFF3B82F6), 'lbl_water', 'tip_water'),
  's2-gravel': _ToolDef(Icons.grid_view_rounded, Color(0xFF94A3B8), 'lbl_gravel', 'tip_gravel'),
  's2-clay': _ToolDef(Icons.grid_view_rounded, Color(0xFFEA580C), 'lbl_clay', 'tip_clay'),
  's2-topsoil': _ToolDef(Icons.grid_view_rounded, Color(0xFF92400E), 'lbl_topsoil', 'tip_topsoil'),
  's2-pump': _ToolDef(Icons.local_gas_station, Color(0xFF059669), 'lbl_pump', 'tip_pump'),
};

class _Ch7A6GroundwaterAndInfiltrationPageState extends State<Ch7A6GroundwaterAndInfiltrationPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _GwScene _scene = _GwScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();

  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// Visible toolbox items, in order.
  final List<String> _tools = [];
  bool _dragging = false;
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

    _rebuild(0);
    _ticker = createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
      _last = elapsed;
      _scene.time = elapsed.inMicroseconds / 1e6;
      _scene.update(dt);
      if (_scene.aquiferJustFilled) {
        _scene.aquiferJustFilled = false;
        _onAquiferFilled();
      }
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

  /// HTML `buildScenario()`.
  void _rebuild(int scenario) {
    _lab.cancelPending();
    _scene.build(scenario);
    _tools
      ..clear()
      ..add(scenario == 0 ? 's1-bottles' : 's2-gravel');
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

  /// HTML `advanceStep()`.
  void _advanceStep() {
    if (!mounted) return;
    if (_step < _data.steps.length) {
      setState(() => _scene.step++);
      if (_scenario == 1 && _step == 6) {
        // Process summary overlays, then the conclusion.
        setState(() => _scene.summary = true);
        _Audio.play(_Sound.magic);
        _lab.after(const Duration(milliseconds: 3000), _showConclusion);
      }
    } else {
      _showConclusion();
    }
  }

  /// HTML `executeDrop(type)` (drop on the canvas or tap on the item).
  void _executeDrop(String type) {
    if (!_tools.contains(type)) return;
    _Audio.play(_Sound.drop);
    final s = _scene;
    if (_scenario == 0) {
      if (type == 's1-bottles' && _step == 1) {
        setState(() {
          _tools.remove(type);
          s
            ..bottlesVisible = true
            ..bottlesT0 = s.time;
        });
        _lab.after(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() => _tools.add('s1-materials'));
          _advanceStep();
        });
      } else if (type == 's1-materials' && _step == 2) {
        setState(() {
          _tools.remove(type);
          s
            ..soilsVisible = true
            ..soilsT0 = s.time;
        });
        _lab.after(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() => _tools.add('s1-water'));
          _advanceStep();
        });
      } else if (type == 's1-water' && _step >= 3 && _step <= 5 && !s.pouring) {
        _pour(_step - 3);
      }
    } else {
      if (type == 's2-gravel' && _step == 1) {
        setState(() {
          _tools
            ..remove(type)
            ..add('s2-clay');
          s.layers = 1;
          s.layerT0[0] = s.time;
        });
      } else if (type == 's2-clay' && _step == 1) {
        setState(() {
          _tools
            ..remove(type)
            ..add('s2-topsoil');
          s.layers = 2;
          s.layerT0[1] = s.time;
        });
      } else if (type == 's2-topsoil' && _step == 1) {
        setState(() {
          _tools.remove(type);
          s.layers = 3;
          s.layerT0[2] = s.time;
        });
        _lab.after(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() => s.cloudVisible = true);
          _advanceStep();
        });
      } else if (type == 's2-pump' && _step == 4) {
        setState(() {
          _tools.clear();
          s
            ..pumpVisible = true
            ..pumpT0 = s.time;
        });
        _lab.after(const Duration(milliseconds: 1500), _advanceStep);
      }
    }
  }

  /// HTML `doPourAnim()` for column [i] (gravel 1.5 s, sand 3 s, clay 5 s).
  void _pour(int i) {
    final s = _scene;
    setState(() {
      s
        ..pouring = true
        ..pourIndex = i
        ..pourStart[i] = s.time;
    });
    _lab.after(const Duration(milliseconds: 500), () => _Audio.play(_Sound.splash));
    final total = 500 + 200 + (_pourSpeed[i] * 1000).round() + 500;
    _lab.after(Duration(milliseconds: total), () {
      if (!mounted) return;
      setState(() {
        s.pouring = false;
        if (i == 2) _tools.remove('s1-water');
      });
      _advanceStep();
    });
  }

  /// HTML `triggerRain()` from the cloud overlay.
  void _triggerRain() {
    final s = _scene;
    if (_scenario != 1 || _step != 2 || s.raining) return;
    _Audio.play(_Sound.splash);
    setState(() {
      s
        ..raining = true
        ..cloudHint = false;
      for (var i = 0; i < 50; i++) {
        s.rain.add(_Drop(-5 + _rnd.nextDouble() * 10, 8 + _rnd.nextDouble() * 3, -1.5 + _rnd.nextDouble() * 3));
      }
    });
    _lab.after(const Duration(milliseconds: 1500), () {
      if (mounted && _step == 2) _advanceStep();
    });
  }

  /// The first drop reached the gravel: the aquifer glows, then the cloud
  /// leaves and the Handpump appears in the toolbox.
  void _onAquiferFilled() {
    _Audio.play(_Sound.bubble);
    _lab.after(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() {
        _scene
          ..cloudVisible = false
          ..raining = false;
        _tools
          ..clear()
          ..add('s2-pump');
      });
      if (_step == 3) _advanceStep();
    });
  }

  void _onStageTap(Offset pos) {
    if (!_lab.isLabActive) return;
    if (_scenario == 1 && _step == 5 && !_scene.pumping && _scene.hitPump(pos)) _triggerPump();
  }

  /// HTML `triggerPump()`.
  void _triggerPump() {
    final s = _scene;
    _Audio.play(_Sound.click);
    setState(() {
      s
        ..pumping = true
        ..pumpingT0 = s.time;
    });
    for (var i = 0; i < 20; i++) {
      _lab.after(Duration(milliseconds: i * 150), () {
        if (mounted) s.pumpDrops.add(_Drop(4, 0.5, 2.1));
      });
    }
    _lab.after(const Duration(milliseconds: 1100), () => _Audio.play(_Sound.splash));
    _lab.after(const Duration(milliseconds: 4000), _advanceStep);
  }

  /// HTML `showConclusion()`.
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

  // ------------------------------------------------------------ popups

  /// HTML `#modal-chart` (S1 step 6).
  void _openChart() {
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('chart_title'),
        icon: Icons.bar_chart_rounded,
        accent: _theme,
        extra: _SeepageChart(isDark: _lab.isDark, scale: context.labScale, tr: _t),
        actions: [
          LabAction(
            label: _t('btn_continue'),
            icon: Icons.arrow_forward,
            color: _Colors.indigo600,
            foreground: Colors.white,
            onTap: () {
              _lab.hidePopup(sound: false);
              if (_scenario == 0 && _step == 6) _advanceStep();
            },
          ),
        ],
      ),
      sound: _Sound.pop,
    );
  }

  /// HTML `#modal-magnifier` (S1 step 7).
  void _openMagnifier() {
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('mag_title'),
        icon: Icons.search,
        accent: _theme,
        body: _t('mag_desc'),
        extra: _MagnifierRow(frame: _frame, scale: context.labScale, isDark: _lab.isDark, tr: _t),
        actions: [
          LabAction(
            label: _t('btn_finish'),
            icon: Icons.check,
            color: _Colors.indigo600,
            foreground: Colors.white,
            onTap: () {
              _lab.hidePopup(sound: false);
              if (_scenario == 0 && _step == 7 && !_scenarioDone) _advanceStep();
            },
          ),
        ],
      ),
      sound: _Sound.pop,
    );
  }

  List<LabAction> _actions() {
    if (_scenario == 0 && _step == 6) {
      return [
        LabAction(
          label: _t('btn_compare'),
          icon: Icons.bar_chart_rounded,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          onTap: _openChart,
        ),
      ];
    }
    if (_scenario == 0 && _step == 7) {
      return [
        LabAction(
          label: _t('btn_particles'),
          icon: Icons.search,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: !_scenarioDone,
          onTap: _openMagnifier,
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
        return LabShell(
          controller: _lab,
          icon: Icons.filter_alt,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(child: _dropTarget(s)),
            if (_tools.isNotEmpty) _toolbox(p, s, inset),
            if (_scene.cloudVisible) _cloudOverlay(s, inset),
          ],
          stage: LabStage(
            designSize: _design,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _onStageTap(d.localPosition),
              child: CustomPaint(
                size: _design,
                painter: _GwPainter(
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
      onAcceptWithDetails: (d) => _executeDrop(d.data),
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
                            color: const Color(0xFF818CF8),
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

  /// HTML `#ui-toolbox`: drag an item onto the scene or tap it.
  Widget _toolbox(LabPalette p, double s, EdgeInsets inset) {
    Widget icon(_ToolDef d, double size, {double opacity = 1}) => Opacity(
          opacity: opacity,
          child: Icon(
            d.icon,
            size: size,
            color: d.color,
            shadows: const [Shadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
        );
    Widget item(String id) {
      final d = _toolDefs[id]!;
      final body = ValueListenableBuilder<double>(
        valueListenable: _frame,
        builder: (context, time, child) {
          final glow = 0.5 + 0.5 * math.sin(time * 4);
          return Container(
            padding: EdgeInsets.all(6 * s),
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
            icon(d, 36 * s),
            SizedBox(height: 3 * s),
            Text(
              _t(d.labelKey),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textStrong, fontSize: 10.5 * s, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
      return Tooltip(
        message: _t(d.tipKey),
        child: Draggable<String>(
          data: id,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Transform.translate(offset: Offset(-24 * s, -24 * s), child: icon(d, 48 * s, opacity: 0.85)),
          childWhenDragging: Opacity(opacity: 0.35, child: body),
          onDragStarted: () {
            _Audio.play(_Sound.pickup);
            setState(() => _dragging = true);
          },
          onDragEnd: (_) {
            if (mounted) setState(() => _dragging = false);
          },
          child: GestureDetector(onTap: () => _executeDrop(id), child: body),
        ),
      );
    }

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
                Container(height: 1, width: 60 * s, margin: EdgeInsets.symmetric(vertical: 6 * s), color: p.cardBorder),
                for (final id in _tools) item(id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML `#cloud-overlay` with the bouncing "CLICK TO RAIN" hint.
  Widget _cloudOverlay(double s, EdgeInsets inset) {
    return Positioned(
      top: inset.top + 28 * s,
      left: inset.left,
      right: inset.right,
      child: Center(
        child: GestureDetector(
          onTap: _triggerRain,
          child: ValueListenableBuilder<double>(
            valueListenable: _frame,
            builder: (context, time, _) {
              final bounce = (math.sin(time * math.pi * 2)).abs();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(0, math.sin(time * 1.6) * 3 * s),
                    child: SizedBox(
                      width: 96 * s,
                      height: 80 * s,
                      child: const CustomPaint(painter: _CloudIconPainter()),
                    ),
                  ),
                  if (_scene.cloudHint)
                    Transform.translate(
                      offset: Offset(0, -bounce * 6 * s),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
                        decoration: BoxDecoration(
                          color: _Colors.slate900,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _Colors.slate700),
                          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8)],
                        ),
                        child: Text(
                          _t('cloud_hint'),
                          style: TextStyle(color: Colors.white, fontSize: 10 * s, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// HTML "Seepage Rate Comparison" bar chart (bars grow after 300 ms).
class _SeepageChart extends StatelessWidget {
  const _SeepageChart({required this.isDark, required this.scale, required this.tr});

  final bool isDark;
  final double scale;
  final String Function(String key) tr;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = _Theme.of(isDark);
    final bars = [
      (100.0, _gravel, 'seep_fast', 'lbl_gravel', isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)),
      (50.0, _sand, 'seep_slow', 'lbl_sand', isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
      (10.0, _clay, 'seep_very_slow', 'lbl_clay', isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C)),
    ];
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1300),
          curve: const Interval(0.23, 1, curve: Curves.easeOut),
          builder: (context, v, _) => Container(
            padding: EdgeInsets.only(bottom: 4 * s),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (h, color, cap, name, capColor) in bars)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * s),
                    child: SizedBox(
                      width: 72 * s,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tr(cap),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: capColor, fontSize: 11 * s, fontWeight: FontWeight.w800, height: 1.2),
                          ),
                          SizedBox(height: 8 * s),
                          Container(
                            width: 60 * s,
                            height: math.max(1, h * v) * s,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            tr(name),
                            style: TextStyle(color: p.textStrong, fontSize: 12 * s, fontWeight: FontWeight.w800),
                          ),
                        ],
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
}

/// HTML "Microscopic View": gravel, sand and clay under the magnifier.
class _MagnifierRow extends StatelessWidget {
  const _MagnifierRow({required this.frame, required this.scale, required this.isDark, required this.tr});

  final ValueNotifier<double> frame;
  final double scale;
  final bool isDark;
  final String Function(String key) tr;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = _Theme.of(isDark);
    const names = ['lbl_gravel', 'lbl_sand', 'lbl_clay'];
    const gaps = ['gap_large', 'gap_medium', 'gap_tiny'];
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var kind = 0; kind < 3; kind++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: frame,
                      builder: (context, time, _) => SizedBox(
                        width: 90 * s,
                        height: 90 * s,
                        child: CustomPaint(painter: _MagPainter(kind, time)),
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(tr(names[kind]), style: TextStyle(color: p.textStrong, fontSize: 13 * s, fontWeight: FontWeight.w800)),
                    Text(tr(gaps[kind]),
                        style: TextStyle(color: p.textMuted, fontSize: 11 * s, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Groundwater & Infiltration',
    'app_subtitle': 'Class 7 • Heat Transfer in Nature',
    'scen_1_opt': 'Scenario 1: The Great Seepage Race',
    'scen_2_opt': 'Scenario 2: Building an Aquifer',
    'obs_complete': 'Success!',
    'drop_here': 'DROP HERE',
    'toolbox': 'Toolbox',
    'btn_reset_lab': 'Reset Lab',
    'lbl_bottles': 'Bottles Setup',
    'lbl_materials': 'Soil Bags',
    'lbl_water': 'Water Beaker',
    'lbl_pump': 'Handpump',
    'lbl_gravel': 'Gravel',
    'lbl_sand': 'Sand',
    'lbl_clay': 'Clay',
    'lbl_topsoil': 'Topsoil',
    'lbl_aquifer': 'Groundwater Storage (Aquifer)',
    'conclusion_1':
        'Water infiltrates fastest through gravel because of large spaces between particles. It is slowest through clay, which has tiny, packed spaces.',
    'conclusion_2':
        'Rainwater infiltrates the ground through topsoil and clay, eventually stopping at bedrock. It collects in the gravel layer, forming an aquifer. We extract this groundwater using wells.',
    // Strings that were hard-coded (English only) in the HTML.
    'tip_bottles': 'Inverted Bottles',
    'tip_materials': 'Soil Materials',
    'tip_water': 'Water Beaker',
    'tip_gravel': 'Gravel & Sand Layer',
    'tip_clay': 'Clay Layer',
    'tip_topsoil': 'Topsoil Layer',
    'tip_pump': 'Handpump',
    'cloud_hint': 'CLICK TO RAIN',
    'btn_compare': 'Compare Results',
    'btn_particles': 'View Particles',
    'chart_title': 'Seepage Rate Comparison',
    'seep_fast': 'Fast\nSeepage',
    'seep_slow': 'Slow\nSeepage',
    'seep_very_slow': 'Very Slow\nSeepage',
    'btn_continue': 'Continue',
    'mag_title': 'Microscopic View',
    'mag_desc': 'Larger spaces between particles allow for faster infiltration.',
    'gap_large': 'Large Gaps',
    'gap_medium': 'Medium Gaps',
    'gap_tiny': 'Tiny Gaps',
    'btn_finish': 'Finish Observation',
    'sum_precip': 'Precipitation',
    'sum_infil': 'Infiltration',
    'sum_extract': 'Extraction',
    'scen_label_1': 'Scenario 1:',
    'scen_label_2': 'Scenario 2:',
  },
  'hi': {
    'app_title': 'भूजल और अंतःस्यंदन (Infiltration)',
    'app_subtitle': 'कक्षा 7 • प्रकृति में ऊष्मा का स्थानांतरण',
    'scen_1_opt': 'परिदृश्य 1: महान रिसाव दौड़',
    'scen_2_opt': 'परिदृश्य 2: एक जलभृत (Aquifer) बनाना',
    'obs_complete': 'सफलता!',
    'drop_here': 'यहां छोड़ें',
    'toolbox': 'टूलबॉक्स',
    'btn_reset_lab': 'लैब रीसेट करें',
    'lbl_bottles': 'बोतलें',
    'lbl_materials': 'मिट्टी के बैग',
    'lbl_water': 'पानी का बीकर',
    'lbl_pump': 'हैंडपंप',
    'lbl_gravel': 'बजरी',
    'lbl_sand': 'रेत',
    'lbl_clay': 'मिट्टी',
    'lbl_topsoil': 'ऊपरी मिट्टी',
    'lbl_aquifer': 'भूजल भंडारण (Aquifer)',
    'conclusion_1':
        'कणों के बीच बड़े स्थानों के कारण पानी बजरी के माध्यम से सबसे तेजी से रिसता है। यह मिट्टी (Clay) के माध्यम से सबसे धीमा है।',
    'conclusion_2':
        'वर्षा जल मिट्टी में रिसकर बजरी की परत में जमा हो जाता है, जिससे जलभृत (Aquifer) बनता है। हम कुओं का उपयोग करके इसे निकालते हैं।',
    'tip_bottles': 'उल्टी बोतलें',
    'tip_materials': 'मिट्टी की सामग्री',
    'tip_water': 'पानी का बीकर',
    'tip_gravel': 'बजरी और रेत की परत',
    'tip_clay': 'मिट्टी (Clay) की परत',
    'tip_topsoil': 'ऊपरी मिट्टी की परत',
    'tip_pump': 'हैंडपंप',
    'cloud_hint': 'बारिश के लिए क्लिक करें',
    'btn_compare': 'परिणामों की तुलना करें',
    'btn_particles': 'कण देखें',
    'chart_title': 'रिसाव दर की तुलना',
    'seep_fast': 'तेज़\nरिसाव',
    'seep_slow': 'धीमा\nरिसाव',
    'seep_very_slow': 'बहुत धीमा\nरिसाव',
    'btn_continue': 'जारी रखें',
    'mag_title': 'सूक्ष्म दृश्य',
    'mag_desc': 'कणों के बीच बड़े स्थान तेज़ अंतःस्यंदन की अनुमति देते हैं।',
    'gap_large': 'बड़े अंतराल',
    'gap_medium': 'मध्यम अंतराल',
    'gap_tiny': 'बहुत छोटे अंतराल',
    'btn_finish': 'अवलोकन समाप्त करें',
    'sum_precip': 'वर्षण',
    'sum_infil': 'अंतःस्यंदन',
    'sum_extract': 'निष्कर्षण',
    'scen_label_1': 'परिदृश्य 1:',
    'scen_label_2': 'परिदृश्य 2:',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'To visually compare the rate of water infiltration through clay, sand, and gravel.',
      steps: [
        LabStep(
          concept: 'Setup Apparatus',
          action: 'DRAG the Inverted Bottles from the toolbox and DROP them on the table.',
          observation: 'The three bottles snap into place on the stands.',
        ),
        LabStep(
          concept: 'Adding Materials',
          action: 'DRAG the Soil Bags and DROP them onto the bottles.',
          observation: 'The bottles fill with Clay, Sand, and Gravel. Beakers appear below to collect water.',
        ),
        LabStep(
          concept: 'Gravel Infiltration',
          action: 'DRAG the Water Beaker and DROP it onto the canvas.',
          observation: 'Water flows very quickly through the large gaps in the gravel. The beaker fills rapidly.',
        ),
        LabStep(
          concept: 'Sand Infiltration',
          action: 'DRAG the Water Beaker again and DROP it.',
          observation: 'Water seeps through the sand at a moderate pace. The beaker fills partially.',
        ),
        LabStep(
          concept: 'Clay Infiltration',
          action: 'DRAG the Water Beaker a final time and DROP it.',
          observation: 'Water barely moves through the tightly packed clay. Only a few drops fall.',
        ),
        LabStep(
          concept: 'Compare Results',
          action: "CLICK 'Compare Results' button.",
          observation:
              'A bar chart shows Gravel allows the fastest seepage, Sand is medium, and Clay is very slow.',
        ),
        LabStep(
          concept: 'Magnified View',
          action: "CLICK 'View Particles' button.",
          observation: 'Magnification reveals that larger spaces between particles allow for faster infiltration.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To build a model of underground layers to visualize how rainwater forms an aquifer.',
      steps: [
        LabStep(
          concept: 'Ground Layers',
          action: 'DRAG the Gravel, Clay, and Topsoil layers sequentially into the tank.',
          observation:
              'The tank fills with distinct layers: Gravel & Sand at the bottom, then Clay, then Topsoil.',
        ),
        LabStep(
          concept: 'Precipitation',
          action: 'CLICK the Cloud icon that appears above the tank.',
          observation: 'Rain drops fall onto the topsoil layer.',
        ),
        LabStep(
          concept: 'Aquifer Formation',
          action: "Observe the water's movement downwards.",
          observation:
              'Water easily passes topsoil, slows in clay, and accumulates in the gravel layer, forming a saturated Aquifer (glows blue).',
        ),
        LabStep(
          concept: 'Well Placement',
          action: 'DRAG the Handpump and DROP it on the surface.',
          observation: "The pump's pipe extends down into the saturated aquifer layer.",
        ),
        LabStep(
          concept: 'Extraction',
          action: 'CLICK the handle of the handpump.',
          observation: 'Groundwater is drawn up from the aquifer through the pipe and pours out.',
        ),
        LabStep(
          concept: 'Process Summary',
          action: 'Review the water cycle stages.',
          observation: 'Precipitation -> Infiltration -> Groundwater Storage -> Extraction.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective: 'मिट्टी, रेत और बजरी के माध्यम से पानी के रिसाव की दर की तुलना करना।',
      steps: [
        LabStep(
          concept: 'उपकरण सेट करें',
          action: 'टूलबॉक्स से बोतलों को खींचें और टेबल पर छोड़ दें।',
          observation: 'तीनों बोतलें स्टैंड पर आ जाती हैं।',
        ),
        LabStep(
          concept: 'सामग्री जोड़ना',
          action: 'मिट्टी के बैग खींचें और बोतलों पर छोड़ दें।',
          observation: 'बोतलें मिट्टी, रेत और बजरी से भर जाती हैं।',
        ),
        LabStep(
          concept: 'बजरी का रिसाव',
          action: 'पानी का बीकर खींचें और कैनवास पर छोड़ दें।',
          observation: 'पानी बजरी के बड़े अंतरालों से बहुत तेजी से बहता है।',
        ),
        LabStep(
          concept: 'रेत का रिसाव',
          action: 'पानी का बीकर फिर से खींचें और छोड़ें।',
          observation: 'पानी रेत के माध्यम से मध्यम गति से रिसता है।',
        ),
        LabStep(
          concept: 'मिट्टी का रिसाव',
          action: 'अंतिम बार पानी का बीकर खींचें और छोड़ें।',
          observation: 'पानी मुश्किल से मिट्टी से होकर गुजरता है।',
        ),
        LabStep(
          concept: 'परिणामों की तुलना',
          action: "'परिणामों की तुलना करें' बटन पर क्लिक करें।",
          observation: 'एक बार चार्ट बजरी में सबसे तेज रिसाव दिखाता है।',
        ),
        LabStep(
          concept: 'आवर्धित दृश्य',
          action: "'कण देखें' बटन पर क्लिक करें।",
          observation: 'आवर्धन से पता चलता है कि कणों के बीच बड़े स्थान तेजी से रिसाव की अनुमति देते हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'एक जलभृत (aquifer) मॉडल बनाना।',
      steps: [
        LabStep(
          concept: 'जमीन की परतें',
          action: 'बजरी, मिट्टी और ऊपरी मिट्टी को क्रमिक रूप से टैंक में खींचें।',
          observation: 'टैंक परतों से भर जाता है।',
        ),
        LabStep(
          concept: 'वर्षा',
          action: 'टैंक के ऊपर दिखाई देने वाले बादल आइकन पर क्लिक करें।',
          observation: 'ऊपरी मिट्टी पर बारिश की बूंदें गिरती हैं।',
        ),
        LabStep(
          concept: 'जलभृत निर्माण',
          action: 'पानी की नीचे की ओर गति का निरीक्षण करें।',
          observation: 'पानी बजरी की परत में जमा हो जाता है, जिससे जलभृत (नीला रंग) बनता है।',
        ),
        LabStep(
          concept: 'कुआं स्थापन',
          action: 'हैंडपंप को खींचें और सतह पर छोड़ दें।',
          observation: 'पंप का पाइप जलभृत की परत तक नीचे जाता है।',
        ),
        LabStep(
          concept: 'निष्कर्षण',
          action: 'हैंडपंप के हैंडल पर क्लिक करें।',
          observation: 'भूजल पाइप के माध्यम से जलभृत से ऊपर खींचा जाता है।',
        ),
        LabStep(
          concept: 'सारांश',
          action: 'जल चक्र के चरणों की समीक्षा करें।',
          observation: 'वर्षण -> अंतःस्यंदन -> भूजल भंडारण -> निष्कर्षण।',
        ),
      ],
    ),
  ],
};

// ============================================================ SCENE MODEL

const Size _design = Size(1000, 560);
const Color _theme = Color(0xFF6366F1); // zsl.theme (indigo-500)
const Color _water = Color(0xFF38BDF8);
const Color _glass = Color(0xFF7DD3FC);
const Color _gravel = Color(0xFF94A3B8);
const Color _sand = Color(0xFFFCD34D);
const Color _clay = Color(0xFFC2410C);
const Color _topsoil = Color(0xFF5D4037);

/// Perspective camera emulating the Three.js PerspectiveCamera.
class _Cam {
  _Cam(this.px, this.py, this.pz, double tx, double ty, double tz, this.focal, this.center) {
    var fx = tx - px, fy = ty - py, fz = tz - pz;
    final fl = math.sqrt(fx * fx + fy * fy + fz * fz);
    _f = [fx / fl, fy / fl, fz / fl];
    var rx = -_f[2], rz = _f[0];
    final rl = math.sqrt(rx * rx + rz * rz);
    rx /= rl;
    rz /= rl;
    _r = [rx, 0, rz];
    _u = [-rz * _f[1], rz * _f[0] - rx * _f[2], rx * _f[1]];
  }

  final double px, py, pz, focal;
  final Offset center;
  late final List<double> _f, _r, _u;

  Offset p(double x, double y, double z) {
    final dx = x - px, dy = y - py, dz = z - pz;
    final d = math.max(0.1, dx * _f[0] + dy * _f[1] + dz * _f[2]);
    final sx = dx * _r[0] + dy * _r[1] + dz * _r[2];
    final sy = dx * _u[0] + dy * _u[1] + dz * _u[2];
    return Offset(center.dx + focal * sx / d, center.dy - focal * sy / d);
  }

  double k(double x, double y, double z) =>
      focal / math.max(0.1, (x - px) * _f[0] + (y - py) * _f[1] + (z - pz) * _f[2]);

  Rect box(double x0, double y0, double z0, double x1, double y1, double z1) {
    var r = Rect.fromPoints(p(x0, y0, z0), p(x0, y0, z0));
    for (final x in [x0, x1]) {
      for (final y in [y0, y1]) {
        for (final z in [z0, z1]) {
          final q = p(x, y, z);
          r = r.expandToInclude(Rect.fromPoints(q, q));
        }
      }
    }
    return r;
  }
}

/// Scenario 1 camera (Three.js (0, 8, 25) -> (0, 3, 0)).
final _Cam _cam1 = _Cam(0, 8, 25, 0, 3, 0, 930, const Offset(500, 262));

/// Scenario 2 camera (Three.js (0, 8, 20) -> (0, 5, 0)).
final _Cam _cam2 = _Cam(0, 8, 20, 0, 5, 0, 700, const Offset(500, 300));

const List<double> _colX = [-4, 0, 4];
const List<double> _pourSpeed = [1.5, 3.0, 5.0]; // gravel, sand, clay (s)
const List<double> _botScale = [1, 0.5, 0.1];
const List<double> _botY = [0.9, 0.5, 0.2];

class _Drop {
  _Drop(this.x, this.y, this.z);
  double x, y, z;
  bool hidden = false;
  int state = 0; // pump water: 0 up, 1 spout, 2 falling
}

/// Mutable scene (HTML `State.objects` / `State.flags`).
class _GwScene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  final math.Random rnd = math.Random(3);

  _Cam get cam => scenario == 0 ? _cam1 : _cam2;

  // ---------------------------------------------------------- scenario 1
  bool bottlesVisible = false;
  double bottlesT0 = 0;
  bool soilsVisible = false;
  double soilsT0 = 0;
  final List<double> pourStart = [-1, -1, -1];
  int pourIndex = -1;
  bool pouring = false;

  // ---------------------------------------------------------- scenario 2
  int layers = 0;
  final List<double> layerT0 = [0, 0, 0];
  bool cloudVisible = false;
  bool cloudHint = true;
  bool raining = false;
  final List<_Drop> rain = [];
  bool aquiferFull = false;
  bool aquiferJustFilled = false;
  double aquiferT0 = 0;
  bool pumpVisible = false;
  double pumpT0 = 0;
  bool pumping = false;
  double pumpingT0 = 0;
  final List<_Drop> pumpDrops = [];
  bool summary = false;

  void build(int sc) {
    scenario = sc;
    step = 1;
    bottlesVisible = soilsVisible = pouring = false;
    for (var i = 0; i < 3; i++) {
      pourStart[i] = -1;
    }
    pourIndex = -1;
    layers = 0;
    cloudVisible = raining = aquiferFull = aquiferJustFilled = false;
    cloudHint = true;
    pumpVisible = pumping = summary = false;
    rain.clear();
    pumpDrops.clear();
  }

  // ---------------------------------------------------- S1 pour timeline
  // 0.0-0.5 beaker moves in and tilts, 0.5-0.7 water appears on top,
  // 0.7-(0.7+speed) it drains into the beaker, then 0.5 s to leave.

  double pourU(int i) => pourStart[i] < 0 ? -1 : time - pourStart[i];

  /// Water standing on top of the soil: (bottom, top) in world y or null.
  (double, double)? topWater(int i) {
    final u = pourU(i);
    if (u < 0.5) return null;
    double scale, pos = 6.5;
    if (u < 0.7) {
      scale = 0.01 + 0.99 * ((u - 0.5) / 0.2);
    } else {
      final v = ((u - 0.7) / _pourSpeed[i]).clamp(0.0, 1.0);
      scale = 1 - 0.9 * v;
      pos = 6.5 - 1.7 * v;
    }
    return (pos - 0.5 * scale, pos + 0.5 * scale);
  }

  /// Water collected in the beaker below: (bottom, top) in world y.
  (double, double)? botWater(int i) {
    final u = pourU(i);
    if (u < 0.5) return null;
    final v = u < 0.7 ? 0.0 : ((u - 0.7) / _pourSpeed[i]).clamp(0.0, 1.0);
    final scale = 0.01 + (_botScale[i] - 0.01) * v;
    final pos = 0.9 + (_botY[i] - 0.9) * v;
    return (math.max(0.3, pos - 0.65 * scale), pos + 0.65 * scale);
  }

  /// Water is draining through column [i] right now.
  bool draining(int i) {
    final u = pourU(i);
    return u >= 0.7 && u < 0.7 + _pourSpeed[i];
  }

  double get bottlesDrop =>
      bottlesVisible ? 5 * (1 - Curves.bounceOut.transform(((time - bottlesT0) / 0.8).clamp(0.0, 1.0))) : 0;

  // --------------------------------------------------------- S2 helpers

  double layerDrop(int i) => 3 * (1 - Curves.easeOutCubic.transform(((time - layerT0[i]) / 0.45).clamp(0.0, 1.0)));

  /// Aquifer height factor: fills over 2 s, then shrinks to 0.8 while pumping.
  double get aquiferLevel {
    if (!aquiferFull) return 0;
    var v = ((time - aquiferT0) / 2).clamp(0.0, 1.0);
    if (pumping) v *= 1 - 0.2 * ((time - pumpingT0) / 3).clamp(0.0, 1.0);
    return v;
  }

  double get pumpOffset => 5 * (1 - Curves.bounceOut.transform(((time - pumpT0) / 1.0).clamp(0.0, 1.0)));

  double get handleAngle {
    if (!pumping) return 0;
    final u = (time - pumpingT0) / 0.25;
    if (u >= 6 || u < 0) return 0;
    final n = u.floor();
    final f = u - n;
    return math.pi / 4 * (n.isEven ? f : 1 - f);
  }

  void update(double dt) {
    if (scenario != 1) return;
    if (raining) {
      for (final p in rain) {
        if (p.hidden) continue;
        // Falls through the air, passes topsoil easily, slows in clay.
        final speed = p.y > 8 ? 9.0 : (p.y > 5 ? 7.0 : (p.y > 2.5 ? 2.2 : 3.5));
        p.y -= speed * dt;
        if (p.y <= 1.5) {
          p.hidden = true;
          if (!aquiferFull) {
            aquiferFull = true;
            aquiferJustFilled = true;
            aquiferT0 = time;
          }
        }
      }
    }
    for (final d in pumpDrops) {
      if (d.hidden) continue;
      switch (d.state) {
        case 0:
          d.y += 12 * dt;
          if (d.y >= 9.2) {
            d
              ..y = 9.2
              ..state = 1;
          }
        case 1:
          d.x += 6 * dt;
          if (d.x >= 4.8) {
            d
              ..x = 4.8
              ..state = 2;
          }
        case 2:
          d.y -= 12 * dt;
          if (d.y <= 8.05) d.hidden = true;
      }
    }
  }

  Rect get pumpRect => _cam2.box(2.6, 7.8 + pumpOffset, 1.6, 5.3, 10.2 + pumpOffset, 2.6);

  bool hitPump(Offset pos) => pumpVisible && pumpRect.inflate(30).contains(pos);
}

// ============================================================ PAINTER

Path _poly(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final q in pts.skip(1)) {
    path.lineTo(q.dx, q.dy);
  }
  return path..close();
}

class _GwPainter extends CustomPainter {
  _GwPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _GwScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final String Function(String key) tr;

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

  // HTML `#sky-bg` + `.grid-overlay`.
  void _paintSky(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E1B4B)]
              : const [Color(0xFFE0E7FF), Color(0xFFF1F5F9)],
        ).createShader(Offset.zero & size),
    );
    final grid = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF6366F1)).withValues(alpha: isDark ? 0.05 : 0.08)
      ..strokeWidth = 1;
    for (var x = (bleed.left / 40).floor() * 40.0; x <= bleed.right; x += 40) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    for (var y = (bleed.top / 40).floor() * 40.0; y <= bleed.bottom; y += 40) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
  }

  void _label(Canvas canvas, String key, Offset at, {Color? bg, Color? border}) {
    if (!showLabels) return;
    labPill(
      canvas,
      tr(key),
      at,
      size: 19,
      background: bg ?? const Color(0xE61E293B),
      border: border ?? const Color(0x6694A3B8),
    );
  }

  void _hintRect(Canvas canvas, Rect r) {
    final rr = RRect.fromRectAndRadius(r.inflate(4 + 4 * pulse), const Radius.circular(14));
    canvas.drawRRect(rr, Paint()..color = _theme.withValues(alpha: 0.06 + 0.06 * pulse));
    labDashedPath(
      canvas,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _theme.withValues(alpha: 0.4 + 0.5 * pulse),
      dash: 10,
      gap: 7,
      phase: t * 20,
    );
  }

  // ========================================================== SCENARIO 1

  void _paintS1(Canvas canvas) {
    final c = cam;
    labGroundShadow(canvas, c.p(0, -4, 0).translate(0, 6), 720, 44, opacity: isDark ? 0.45 : 0.2);
    for (final lx in const [-7.5, 7.5]) {
      _leg(canvas, lx, -2.5);
    }
    _table(canvas);
    for (final lx in const [-7.5, 7.5]) {
      _leg(canvas, lx, 2.5);
    }
    if (scene.bottlesVisible) {
      for (var i = 0; i < 3; i++) {
        _column(canvas, i);
      }
    }
    if (scene.pourIndex >= 0) _pourBeaker(canvas, scene.pourIndex);
    if (scene.soilsVisible) {
      const keys = ['lbl_gravel', 'lbl_sand', 'lbl_clay'];
      for (var i = 0; i < 3; i++) {
        _label(canvas, keys[i], c.p(_colX[i], -1, 0));
      }
    }
  }

  void _leg(Canvas canvas, double x, double z) {
    final c = cam;
    final top = c.p(x, -0.25, z), bot = c.p(x, -4, z);
    final w = 0.2 * c.k(x, -2, z);
    final r = Rect.fromLTRB(top.dx - w, top.dy, top.dx + w, bot.dy);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(colors: [
          labShade(_gravel, -0.35),
          labShade(_gravel, 0.2),
          labShade(_gravel, -0.4),
        ], stops: const [0, 0.4, 1]).createShader(r),
    );
  }

  void _table(Canvas canvas) {
    final c = cam;
    const col = Color(0xFFE2E8F0);
    final top = _poly([c.p(-8, 0.25, -3), c.p(8, 0.25, -3), c.p(8, 0.25, 3), c.p(-8, 0.25, 3)]);
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(col, -0.12), col],
        ).createShader(top.getBounds()),
    );
    final front = Rect.fromPoints(c.p(-8, 0.25, 3), c.p(8, -0.25, 3));
    canvas.drawRect(front, Paint()..color = labShade(col, -0.3));
    canvas.drawLine(front.topLeft, front.topRight, Paint()
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.7));
  }

  Path _bottlePath(double x, double dy) {
    final c = cam;
    return _poly([
      c.p(x - 0.75, 7 + dy, 0),
      c.p(x - 0.75, 4 + dy, 0),
      c.p(x - 0.2, 3 + dy, 0),
      c.p(x + 0.2, 3 + dy, 0),
      c.p(x + 0.75, 4 + dy, 0),
      c.p(x + 0.75, 7 + dy, 0),
    ]);
  }

  void _column(Canvas canvas, int i) {
    final c = cam;
    final x = _colX[i];
    final dy = scene.bottlesDrop;
    final k = c.k(x, 3, 0);
    double eh(double y, double r) => (c.p(x, y, r).dy - c.p(x, y, -r).dy).abs();
    const metal = Color(0xFF64748B);

    // Retort stand: pole, arm and base.
    final poleTop = c.p(x - 1.5, 5 + dy, -0.5), poleBot = c.p(x - 1.5, dy, -0.5);
    final pw = 0.1 * c.k(x - 1.5, 2.5, -0.5);
    canvas.drawRect(Rect.fromLTRB(poleTop.dx - pw, poleTop.dy, poleTop.dx + pw, poleBot.dy), Paint()..color = metal);
    canvas.drawLine(
      c.p(x - 1.5, 4 + dy, -0.5),
      c.p(x, 4 + dy, -0.5),
      Paint()
        ..strokeWidth = 0.1 * k
        ..color = metal,
    );
    final baseTop = _poly([c.p(x - 1, 0.45 + dy, -1), c.p(x + 1, 0.45 + dy, -1), c.p(x + 1, 0.45 + dy, 1), c.p(x - 1, 0.45 + dy, 1)]);
    canvas.drawPath(baseTop, Paint()..color = labShade(const Color(0xFF475569), 0.15));
    canvas.drawRect(Rect.fromPoints(c.p(x - 1, 0.45 + dy, 1), c.p(x + 1, 0.25 + dy, 1)),
        Paint()..color = labShade(const Color(0xFF475569), -0.2));

    // Collecting beaker with the water that seeped through.
    if (scene.soilsVisible) {
      final bw = scene.botWater(i);
      final fill = bw == null ? 0.0 : ((bw.$2 - 0.3) / 1.45).clamp(0.0, 1.0);
      final br = Rect.fromPoints(c.p(x - 0.8, 1.75 + dy, 0), c.p(x + 0.8, 0.25 + dy, 0));
      labBeaker(canvas, br, fill: fill, liquid: _water, glass: _glass, liquidOpacity: 0.8);
    }

    // Ring clamp, back half.
    final ringC = c.p(x, 4 + dy, 0);
    final ringR = Rect.fromCenter(center: ringC, width: 1.6 * k, height: math.max(4, eh(4, 0.8)));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1 * k
      ..color = metal;
    canvas.drawArc(ringR, math.pi, math.pi, false, ring);

    // Inverted bottle: soil, water on top, glass.
    final body = _bottlePath(x, dy);
    canvas.drawPath(body, Paint()..color = _glass.withValues(alpha: 0.16));
    canvas.save();
    canvas.clipPath(body);
    if (scene.soilsVisible) {
      final soilCol = [_gravel, _sand, _clay][i];
      final soil = Rect.fromPoints(c.p(x - 0.8, 5.5 + dy, 0), c.p(x + 0.8, 3.0 + dy, 0));
      canvas.drawRect(
        soil,
        Paint()
          ..shader = LinearGradient(colors: [
            labShade(soilCol, -0.25),
            labShade(soilCol, 0.12),
            labShade(soilCol, -0.3),
          ], stops: const [0, 0.45, 1]).createShader(soil),
      );
      _soilTexture(canvas, soil, soilCol, i);
      canvas.drawOval(
        Rect.fromCenter(center: c.p(x, 5.5 + dy, 0), width: 1.5 * k, height: eh(5.5, 0.75)),
        Paint()..color = labShade(soilCol, 0.2),
      );
    }
    final tw = scene.topWater(i);
    if (tw != null) {
      final wr = Rect.fromPoints(c.p(x - 0.8, tw.$2 + dy, 0), c.p(x + 0.8, tw.$1 + dy, 0));
      canvas.drawRect(wr, Paint()..color = _water.withValues(alpha: 0.6));
      canvas.drawOval(
        Rect.fromCenter(center: c.p(x, tw.$2 + dy, 0), width: 1.4 * k, height: eh(tw.$2, 0.7)),
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.75),
      );
    }
    canvas.restore();
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _glass.withValues(alpha: 0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c.p(x, 7 + dy, 0), width: 1.5 * k, height: eh(7, 0.75)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _glass.withValues(alpha: 0.9),
    );
    canvas.drawLine(
      c.p(x - 0.5, 6.7 + dy, 0),
      c.p(x - 0.5, 4.2 + dy, 0),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.3),
    );

    // Drips from the bottle neck into the beaker.
    if (scene.draining(i)) {
      final neck = c.p(x, 3 + dy, 0);
      final bw = scene.botWater(i);
      final floor = c.p(x, (bw?.$2 ?? 0.3) + dy, 0).dy;
      final drop = Paint()..color = _water;
      if (i == 0) {
        // Gravel: a steady stream.
        canvas.drawLine(neck, Offset(neck.dx, floor), Paint()
          ..strokeWidth = 0.12 * k
          ..strokeCap = StrokeCap.round
          ..color = _water.withValues(alpha: 0.85));
      }
      final n = [5, 3, 1][i];
      final rate = [2.4, 1.4, 0.7][i];
      for (var j = 0; j < n; j++) {
        final ph = (t * rate + j / n) % 1.0;
        final y = neck.dy + (floor - neck.dy) * ph * ph;
        canvas.drawOval(Rect.fromCenter(center: Offset(neck.dx, y), width: 0.14 * k, height: 0.2 * k), drop);
      }
    }
    // Ring clamp, front half.
    canvas.drawArc(ringR, 0, math.pi, false, ring);
  }

  void _soilTexture(Canvas canvas, Rect r, Color color, int kind) {
    final rnd = math.Random(30 + kind);
    if (kind == 0) {
      for (var i = 0; i < 40; i++) {
        final o = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
        labSphere(canvas, o, 3.5 + rnd.nextDouble() * 3.5, labShade(color, rnd.nextDouble() * 0.4 - 0.25),
            highlight: 0.35, shade: 0.4);
      }
    } else if (kind == 1) {
      for (var i = 0; i < 160; i++) {
        final o = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
        canvas.drawCircle(o, 0.9 + rnd.nextDouble() * 0.8,
            Paint()..color = labShade(color, rnd.nextDouble() * 0.5 - 0.3).withValues(alpha: 0.8));
      }
    } else {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = labShade(color, -0.3).withValues(alpha: 0.45);
      for (var y = r.top + 6; y < r.bottom; y += 9) {
        final path = Path()..moveTo(r.left, y);
        for (var x = r.left; x <= r.right; x += 5) {
          path.lineTo(x, y + math.sin(x / 8 + y) * 1.2);
        }
        canvas.drawPath(path, line);
      }
    }
  }

  /// The pouring beaker (HTML `doPourAnim`): moves in and tilts by PI/4,
  /// pours, then tilts back and leaves upwards.
  void _pourBeaker(Canvas canvas, int i) {
    final u = scene.pourU(i);
    final sp = _pourSpeed[i];
    if (u < 0 || u > 0.7 + sp + 0.5) return;
    final x = _colX[i];
    double px, py, rot;
    if (u < 0.5) {
      final a = u / 0.5;
      px = x - 2 + a;
      py = 12 - 4 * a;
      rot = -math.pi / 4 * a;
    } else if (u < 0.7 + sp) {
      px = x - 1;
      py = 8;
      rot = -math.pi / 4;
    } else {
      final b = ((u - 0.7 - sp) / 0.5).clamp(0.0, 1.0);
      px = x - 1;
      py = 8 + 7 * b;
      rot = -math.pi / 4 * (1 - b);
    }
    final c = cam;
    final o = c.p(px, py, 0);
    final k = c.k(px, py, 0);
    final a = -rot; // canvas rotation (clockwise)
    Offset local(double lx, double ly) =>
        o + Offset(lx * math.cos(a) - ly * math.sin(a), lx * math.sin(a) + ly * math.cos(a));

    // Stream of water from the lip into the bottle.
    final streaming = u >= 0.5 && u < 0.7 + sp * 0.5;
    if (streaming) {
      final lip = local(k, -k);
      final target = c.p(x, 6.9 + scene.bottlesDrop, 0);
      final path = Path()
        ..moveTo(lip.dx, lip.dy)
        ..quadraticBezierTo(lip.dx + 0.5 * k, lip.dy + 0.1 * k, target.dx, target.dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.24 * k
          ..strokeCap = StrokeCap.round
          ..color = _water.withValues(alpha: 0.85),
      );
      labDashedPath(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.08 * k
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.7),
        dash: 6,
        gap: 10,
        phase: -t * 60,
      );
    }

    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(a);
    final body = Rect.fromLTRB(-k, -k, k, k);
    // Water inside, its surface kept level.
    final level = u < 0.5 ? 0.9 : 0.9 * (1 - 0.75 * ((u - 0.5) / (0.2 + sp * 0.5)).clamp(0.0, 1.0));
    canvas.save();
    canvas.clipRect(body.deflate(0.08 * k));
    canvas.rotate(-a);
    final surface = (k - 2 * k * level) * math.cos(a).abs();
    canvas.drawRect(Rect.fromLTRB(-3 * k, surface, 3 * k, 3 * k), Paint()..color = _water.withValues(alpha: 0.6));
    canvas.restore();
    canvas.drawRect(body, Paint()..color = _glass.withValues(alpha: 0.15));
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _glass.withValues(alpha: 0.9);
    canvas.drawLine(body.topLeft, body.bottomLeft, edge);
    canvas.drawLine(body.topRight, body.bottomRight, edge);
    canvas.drawLine(body.bottomLeft, body.bottomRight, edge);
    canvas.drawOval(Rect.fromCenter(center: body.topCenter, width: 2 * k, height: 0.3 * k), edge);
    canvas.drawLine(Offset(-0.6 * k, -0.7 * k), Offset(-0.6 * k, 0.7 * k), Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.3));
    canvas.restore();
  }

  // ========================================================== SCENARIO 2

  void _paintS2(Canvas canvas) {
    final c = cam;
    labGroundShadow(canvas, c.p(0, -0.1, 2.1).translate(0, 10), 560, 34, opacity: isDark ? 0.45 : 0.2);
    // Glass tank: back, sides and bottom.
    final back = _poly([c.p(-6.1, 8.1, -2.1), c.p(6.1, 8.1, -2.1), c.p(6.1, -0.1, -2.1), c.p(-6.1, -0.1, -2.1)]);
    final glassFill = Paint()..color = _glass.withValues(alpha: 0.12);
    final glassEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _glass.withValues(alpha: 0.5);
    canvas.drawPath(back, glassFill);
    canvas.drawPath(back, glassEdge);
    for (final sx in const [-6.1, 6.1]) {
      final side = _poly([c.p(sx, 8.1, -2.1), c.p(sx, 8.1, 2.1), c.p(sx, -0.1, 2.1), c.p(sx, -0.1, -2.1)]);
      canvas.drawPath(side, glassFill);
      canvas.drawPath(side, glassEdge);
    }
    canvas.drawPath(
      _poly([c.p(-6.1, -0.1, -2.1), c.p(6.1, -0.1, -2.1), c.p(6.1, -0.1, 2.1), c.p(-6.1, -0.1, 2.1)]),
      Paint()..color = _glass.withValues(alpha: 0.2),
    );

    for (var i = 0; i < scene.layers; i++) {
      _layer(canvas, i);
    }
    _aquifer(canvas);

    // Rain drops: falling above the tank, then seeping through the layers.
    if (scene.raining) {
      final streak = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = _water;
      for (final p in scene.rain) {
        if (p.hidden) continue;
        if (p.y > 8.05) {
          canvas.drawLine(c.p(p.x, p.y, p.z), c.p(p.x, p.y + 0.35, p.z), streak);
        } else {
          final o = c.p(p.x, p.y, 2.05);
          final k = c.k(p.x, p.y, 2.05);
          canvas.drawOval(Rect.fromCenter(center: o, width: 0.18 * k, height: 0.26 * k),
              Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.9));
        }
      }
    }

    // Front glass.
    final ftl = c.p(-6.1, 8.1, 2.1), fbl = c.p(-6.1, -0.1, 2.1);
    final front = _poly([ftl, c.p(6.1, 8.1, 2.1), c.p(6.1, -0.1, 2.1), fbl]);
    canvas.drawPath(front, Paint()..color = Colors.white.withValues(alpha: 0.05));
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _glass.withValues(alpha: 0.85),
    );
    for (final sx in const [-6.1, 6.1]) {
      canvas.drawLine(c.p(sx, 8.1, -2.1), c.p(sx, 8.1, 2.1), glassEdge);
    }
    canvas.drawLine(
      Offset.lerp(ftl, c.p(6.1, 8.1, 2.1), 0.06)! + const Offset(0, 10),
      Offset.lerp(ftl, fbl, 0.45)! + const Offset(12, 0),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.18),
    );

    if (scene.pumpVisible) _pump(canvas);
    if (scene.step == 5 && scene.pumpVisible && !scene.pumping) _hintRect(canvas, scene.pumpRect);
    _paintS2Labels(canvas);
    if (scene.summary) _paintSummary(canvas);
  }

  void _layer(Canvas canvas, int i) {
    final c = cam;
    const ys = [(0.0, 2.5), (2.5, 5.0), (5.0, 8.0)];
    final col = [_gravel, _clay, _topsoil][i];
    final dy = scene.layerDrop(i);
    final y0 = ys[i].$1 + dy, y1 = ys[i].$2 + dy;
    canvas.drawPath(
      _poly([c.p(-6, y1, -2), c.p(6, y1, -2), c.p(6, y1, 2), c.p(-6, y1, 2)]),
      Paint()..color = labShade(col, 0.15),
    );
    final face = _poly([c.p(-6, y1, 2), c.p(6, y1, 2), c.p(6, y0, 2), c.p(-6, y0, 2)]);
    final r = face.getBounds();
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(col, 0.08), labShade(col, -0.15)],
        ).createShader(r),
    );
    canvas.save();
    canvas.clipPath(face);
    final rnd = math.Random(50 + i);
    if (i == 0) {
      // Gravel & sand: pebbles in fine sand.
      for (var j = 0; j < 260; j++) {
        canvas.drawCircle(Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height),
            0.8 + rnd.nextDouble(), Paint()..color = labShade(_sand, rnd.nextDouble() * 0.3 - 0.35).withValues(alpha: 0.5));
      }
      for (var j = 0; j < 90; j++) {
        final o = Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height);
        labSphere(canvas, o, 3 + rnd.nextDouble() * 4, labShade(col, rnd.nextDouble() * 0.4 - 0.25),
            highlight: 0.35, shade: 0.4);
      }
    } else if (i == 1) {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = labShade(col, -0.3).withValues(alpha: 0.45);
      for (var y = r.top + 7; y < r.bottom; y += 10) {
        final path = Path()..moveTo(r.left, y);
        for (var x = r.left; x <= r.right; x += 6) {
          path.lineTo(x, y + math.sin(x / 11 + y) * 1.5);
        }
        canvas.drawPath(path, line);
      }
    } else {
      for (var j = 0; j < 220; j++) {
        canvas.drawCircle(Offset(r.left + rnd.nextDouble() * r.width, r.top + rnd.nextDouble() * r.height),
            0.8 + rnd.nextDouble() * 1.4, Paint()..color = labShade(col, rnd.nextDouble() * 0.5 - 0.25));
      }
    }
    canvas.restore();
    if (i == 2) {
      // Grass on the surface.
      final blade = Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF4ADE80);
      for (var j = 0; j < 40; j++) {
        final x = r.left + 6 + j * (r.width - 12) / 39 + rnd.nextDouble() * 3;
        for (var d = -1; d <= 1; d++) {
          canvas.drawLine(Offset(x, r.top + 1), Offset(x + d * 3, r.top - 5 - rnd.nextDouble() * 3), blade);
        }
      }
    }
  }

  void _aquifer(Canvas canvas) {
    final lv = scene.aquiferLevel;
    if (lv <= 0) return;
    final c = cam;
    final h = 2.5 * lv;
    final face = _poly([c.p(-6.05, h, 2.05), c.p(6.05, h, 2.05), c.p(6.05, 0, 2.05), c.p(-6.05, 0, 2.05)]);
    final r = face.getBounds();
    canvas.drawPath(
      face,
      Paint()
        ..color = _water.withValues(alpha: 0.25 + 0.1 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(face, Paint()..color = _water.withValues(alpha: 0.5));
    canvas.save();
    canvas.clipPath(face);
    final wave = Path()..moveTo(r.left, r.top);
    for (var x = r.left; x <= r.right; x += 6) {
      wave.lineTo(x, r.top + math.sin(x / 15 + t * 3) * 1.5);
    }
    canvas.drawPath(
      wave,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    final rnd = math.Random(8);
    for (var i = 0; i < 22; i++) {
      final x = r.left + rnd.nextDouble() * r.width;
      final y = r.bottom - ((rnd.nextDouble() + t * 0.15) % 1.0) * r.height;
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white.withValues(alpha: 0.4));
    }
    canvas.restore();
  }

  /// Handpump whose transparent pipe reaches down into the gravel layer.
  void _pump(Canvas canvas) {
    final c = cam;
    final oy = scene.pumpOffset;
    const z = 2.1;
    final k = c.k(4, 8, z);
    final pipe = Rect.fromPoints(c.p(3.8, 8 + oy, z), c.p(4.2, 0.5 + oy, z));
    canvas.drawRect(pipe, Paint()..color = _glass.withValues(alpha: 0.4));
    canvas.drawRect(
      pipe,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _glass.withValues(alpha: 0.9),
    );
    final landed = scene.pumpDrops.where((d) => d.hidden).length;
    if (landed > 0) {
      final pr = (landed / 20).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(center: c.p(4.9, 8.05, z + 0.2), width: (0.5 + 1.4 * pr) * k, height: (0.14 + 0.25 * pr) * k),
        Paint()..color = _water.withValues(alpha: 0.8),
      );
    }
    for (final d in scene.pumpDrops) {
      if (d.hidden) continue;
      canvas.drawCircle(c.p(d.x, d.y + oy, z), 0.15 * k, Paint()..color = _water);
    }
    const dark = Color(0xFF1E293B);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _Colors.slate400.withValues(alpha: 0.75);
    // Concrete platform on the surface around the pipe.
    final slabL = c.p(3.25, 8 + oy, z), slabR = c.p(4.75, 8 + oy, z);
    labBox3D(
      canvas,
      Rect.fromLTRB(slabL.dx, slabL.dy - 0.18 * k, slabR.dx, slabL.dy + 0.04 * k),
      0.22 * k,
      const Color(0xFF94A3B8),
    );
    // Spout with its mouth.
    final spout = Rect.fromPoints(c.p(4, 9.35 + oy, z), c.p(5, 9.05 + oy, z));
    final spoutR = RRect.fromRectAndRadius(spout, Radius.circular(spout.height / 2));
    canvas.drawRRect(
      spoutR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(dark, 0.4), labShade(dark, -0.2)],
        ).createShader(spout),
    );
    canvas.drawRRect(spoutR, rim);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(spout.right - 0.04 * k, spout.center.dy + 0.05 * k), width: 0.16 * k, height: 0.3 * k),
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
    // Pump body (cylinder y 8 .. 9.5) with bands, rim light and a domed cap.
    final bodyR = Rect.fromPoints(c.p(3.6, 9.5 + oy, z), c.p(4.4, 8 + oy, z));
    labCylinder(canvas, bodyR, labShade(dark, 0.18), tilt: 0.18);
    canvas.drawLine(bodyR.topLeft, bodyR.bottomLeft, rim);
    canvas.drawLine(bodyR.topRight, bodyR.bottomRight, rim);
    final band = Paint()..color = labShade(dark, 0.42);
    for (final by in const [8.3, 9.15]) {
      final o = c.p(4, by + oy, z);
      canvas.drawRect(Rect.fromCenter(center: o, width: bodyR.width + 0.06 * k, height: 0.08 * k), band);
    }
    final capC = c.p(4, 9.5 + oy, z);
    final cap = Path()
      ..moveTo(capC.dx - 0.44 * k, capC.dy)
      ..quadraticBezierTo(capC.dx, capC.dy - 0.5 * k, capC.dx + 0.44 * k, capC.dy)
      ..close();
    canvas.drawPath(
      cap,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.5),
          colors: [labShade(dark, 0.5), labShade(dark, 0.05)],
        ).createShader(Rect.fromCenter(center: capC, width: 0.9 * k, height: 0.6 * k)),
    );
    canvas.drawPath(cap, rim);
    // Handle on its pivot (3.6, 9.4), rotated by the pumping tween.
    final pivot = c.p(3.6, 9.4 + oy, z);
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(-scene.handleAngle);
    final handle = Rect.fromLTRB(-1.35 * k, -0.1 * k, 0.15 * k, 0.1 * k);
    canvas.drawRRect(
      RRect.fromRectAndRadius(handle, Radius.circular(0.08 * k)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(const Color(0xFFEF4444), 0.25), labShade(const Color(0xFFEF4444), -0.3)],
        ).createShader(handle),
    );
    // Grip at the end of the handle.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(-1.42 * k, -0.14 * k, -0.95 * k, 0.14 * k), Radius.circular(0.1 * k)),
      Paint()..color = const Color(0xFF7F1D1D),
    );
    canvas.restore();
    canvas.drawCircle(pivot, 0.1 * k, Paint()..color = _Colors.slate400);
    canvas.drawCircle(pivot, 0.04 * k, Paint()..color = dark);
  }

  void _paintS2Labels(Canvas canvas) {
    final c = cam;
    if (scene.layers >= 1) _label(canvas, 'lbl_gravel', c.p(-6, 1.25 + scene.layerDrop(0), 2));
    if (scene.layers >= 2) _label(canvas, 'lbl_clay', c.p(-6, 3.75 + scene.layerDrop(1), 2));
    if (scene.layers >= 3) _label(canvas, 'lbl_topsoil', c.p(-6, 6.5 + scene.layerDrop(2), 2));
    if (scene.aquiferFull) {
      _label(canvas, 'lbl_aquifer', c.p(0, 1.25, 2.5), bg: const Color(0xE60EA5E9), border: _glass);
    }
    if (scene.pumpVisible) _label(canvas, 'lbl_pump', c.p(4, 11 + scene.pumpOffset, 2.1));
  }

  /// HTML `#summary-overlays`: Precipitation, Infiltration, Extraction.
  void _paintSummary(Canvas canvas) {
    final c = cam;
    final op = 0.6 + 0.4 * pulse;
    void tag(String key, Offset at, Color border, Color arrow, bool down) {
      final r = labText(
        canvas,
        tr(key),
        at,
        size: 18,
        weight: FontWeight.w800,
        color: Colors.white,
        background: const Color(0xCC0F172A),
        border: border,
        borderWidth: 1.5,
        radius: 9,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 26),
        opacity: op,
      );
      final ax = r.center.dx, ay = r.bottom - 13;
      labArrow(
        canvas,
        Offset(ax, down ? ay - 8 : ay + 8),
        Offset(ax, down ? ay + 8 : ay - 8),
        color: arrow.withValues(alpha: op),
        width: 3,
        head: 8,
      );
    }

    tag('sum_precip', c.p(-3.6, 10.6, 2), const Color(0xFF818CF8), const Color(0xFF93C5FD), true);
    tag('sum_infil', c.p(-1.2, 6.6, 2.2), const Color(0xFF818CF8), const Color(0xFF93C5FD), true);
    tag('sum_extract', c.p(7.4, 10.0, 2.1), const Color(0xFF34D399), const Color(0xFF6EE7B7), false);
  }

  @override
  bool shouldRepaint(covariant _GwPainter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

// ============================================================ 2D PAINTERS

/// HTML cloud overlay SVG (sky-blue fill, white outline).
class _CloudIconPainter extends CustomPainter {
  const _CloudIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final p1 = Path()
      ..moveTo(17.5, 19)
      ..lineTo(7.5, 19)
      ..cubicTo(4.73858, 19, 2.5, 16.7614, 2.5, 14)
      ..cubicTo(2.5, 11.2386, 4.73858, 9, 7.5, 9)
      ..cubicTo(8.05233, 9, 8.58023, 9.08783, 9.06836, 9.25482)
      ..cubicTo(9.85101, 6.92492, 12.1893, 5.5, 14.75, 5.5)
      ..cubicTo(18.0632, 5.5, 20.75, 8.1868, 20.75, 11.5)
      ..cubicTo(20.75, 12.5854, 20.4587, 13.5995, 19.9571, 14.4745);
    final p2 = Path()
      ..moveTo(19.9571, 14.4745)
      ..cubicTo(19.7154, 14.1948, 19.4311, 13.9548, 19.1093, 13.7602)
      ..cubicTo(19.4311, 13.9548, 20.5, 15, 20.5, 16.5)
      ..cubicTo(20.5, 17.8807, 19.1358, 19, 17.5, 19);
    canvas.drawPath(
      p1.shift(const Offset(0, 1.2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
    final fill = Paint()..color = _water;
    canvas.drawPath(p1, fill);
    canvas.drawPath(p2, fill);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    canvas.drawPath(p1, stroke);
    canvas.drawPath(p2, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// One circle of the HTML "Microscopic View" (`.mag-circle`): particles
/// laid out like the CSS flex-wrap and a water drop trickling through.
class _MagPainter extends CustomPainter {
  _MagPainter(this.kind, this.time);
  final int kind; // 0 gravel, 1 sand, 2 clay
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final f = size.width / 100;
    canvas.scale(f, f);
    const c = Offset(50, 50);
    canvas.drawCircle(c, 50, Paint()..color = Colors.white);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: 46)));
    final size0 = [30.0, 12.0, 5.0][kind];
    final margin = [2.0, 1.0, 0.0][kind];
    final count = [4, 30, 150][kind];
    final fillC = [_gravel, _sand, _clay][kind];
    final edgeC = [const Color(0xFF64748B), const Color(0xFFD97706), const Color(0xFF9A3412)][kind];
    final cell = size0 + 2 + margin * 2;
    final perRow = (92 / cell).floor();
    final rows = (count / perRow).ceil();
    final top = 4 + (92 - rows * cell) / 2;
    for (var r = 0; r < rows; r++) {
      final inRow = math.min(perRow, count - r * perRow);
      final left = 4 + (92 - inRow * cell) / 2;
      for (var j = 0; j < inRow; j++) {
        final o = Offset(left + j * cell + cell / 2, top + r * cell + cell / 2);
        canvas.drawCircle(o, size0 / 2 + 1, Paint()..color = edgeC);
        canvas.drawCircle(o, size0 / 2, Paint()..color = fillC);
      }
    }
    // Trickling water (CSS `@keyframes trickle`).
    final dur = [2.0, 3.0, 5.0][kind];
    final ds = [15.0, 10.0, 5.0][kind];
    final left = [40.0, 45.0, 47.0][kind];
    final ph = Curves.ease.transform((time % dur) / dur);
    final ty = -50 + 100 * ph;
    final sc = 1 - 0.5 * ph;
    canvas.drawCircle(
      Offset(4 + left + ds / 2, 4 + 20 + ds / 2 + ty),
      ds / 2 * sc,
      Paint()..color = _water.withValues(alpha: 0.6 * (1 - ph)),
    );
    canvas.restore();
    // Inset shadow and border.
    canvas.drawCircle(
      c,
      46,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      c,
      48,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF334155),
    );
  }

  @override
  bool shouldRepaint(covariant _MagPainter old) => old.time != time || old.kind != kind;
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
