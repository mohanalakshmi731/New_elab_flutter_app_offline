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

/// Class 7 Science • Chapter 11 • Activity 1
/// Sources of Light.
///
/// Native Flutter port of `Cl7S-Ch11-A1-Sources_of_Light.html`.
/// Scenario 1: drag the Sun, Moon, Star, Firefly and Mirror from the tray
/// into the "Emits Light" or "Reflects Light" circle. Scenario 2: drag
/// Lightning, a Lamp, a Firefly, a Candle and a Campfire into the natural
/// (forest) or artificial (room) half of the scene. Each correct drop
/// switches the object's light effect on.
class Ch11A1SourcesOfLightPage extends StatefulWidget {
  const Ch11A1SourcesOfLightPage({super.key});

  @override
  State<Ch11A1SourcesOfLightPage> createState() => _Ch11A1SourcesOfLightPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, spark 2365.
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

// ============================================================== MODEL

const Size _design = Size(900, 560);

/// Pixels per board unit at z = 0 and the design point of the board origin.
const double _u = 16;
const Offset _origin = Offset(450, 300);

/// The HTML camera looks straight at the board from z = 80 (fov 30°).
const double _camZ = 80;

double _kz(double z) => _camZ / (_camZ - z);

/// Board point (Three.js world units) → design pixels.
Offset _toDesign(double x, double y, [double z = 0]) {
  final k = _kz(z);
  return Offset(_origin.dx + x * _u * k, _origin.dy - y * _u * k);
}

/// Design pixels → board point on the z = 0 drag plane.
Offset _toBoard(Offset d) => Offset((d.dx - _origin.dx) / _u, (_origin.dy - d.dy) / _u);

/// Drop-zone centres of scenario 1 (radius 8).
const Offset _emitsZone = Offset(-11, 7);
const Offset _reflectsZone = Offset(11, 7);
const double _zoneRadius = 8;

/// A draggable object from the tray.
class _Item {
  _Item({
    required this.id,
    required this.type,
    required this.step,
    required this.initX,
    required this.initY,
    required this.hit,
    required this.labelKey,
    required this.labelOffset,
  }) : x = initX,
       y = initY;

  final String id; // sun, moon, star, firefly, mirror, lightning, lamp, firefly2, candle, campfire
  final String type; // emits, reflects, natural, artificial
  final int step;
  final double initX, initY;
  final double hit; // pick radius in board units
  final String labelKey;
  final double labelOffset;
  double x, y, z = 0;
  double dragScale = 1; // 1.2 while held
  bool placed = false;
  bool active = false; // light / effect switched on
  bool visible = true;
  double activeAt = 0;
  double nextHop = 0; // firefly flight timer
}

/// A light beam (HTML `createBeam`) between two board points.
class _Beam {
  _Beam(this.a, this.b, this.t0);
  final Offset a, b;
  final double t0;
}

/// Mutable scene model read by the painter every frame.
class _LightScene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  final List<_Item> items = [];
  final List<_Beam> beams = [];
  _Item? dragging;
  Offset dragOffset = Offset.zero;
  double flashAt = -100; // lightning flash start

  _Item? item(String id) {
    for (final it in items) {
      if (it.id == id) return it;
    }
    return null;
  }

  /// Ambient light intensity (HTML `State.globalLight`).
  double get ambient {
    if (scenario == 1) {
      final dt = time - flashAt;
      if (dt >= 0 && dt < 0.1) return 2.0;
      if (dt >= 0.1 && dt < 0.2) return 0.1;
      if (dt >= 0.2 && dt < 0.4) return 1.5;
      return 0.2;
    }
    return (item('sun')?.active ?? false) ? 0.3 : 0.2;
  }

  /// Zone the held item is over (for the drop highlight).
  String? get hoverZone {
    final d = dragging;
    if (d == null) return null;
    if (scenario == 0) {
      if ((Offset(d.x, d.y) - _emitsZone).distance < _zoneRadius) return 'emits';
      if ((Offset(d.x, d.y) - _reflectsZone).distance < _zoneRadius) return 'reflects';
      return null;
    }
    return d.x < 0 ? 'natural' : 'artificial';
  }
}

/// A TWEEN.js style tween driven by the scene ticker.
class _Tw {
  _Tw({
    required this.duration,
    required this.update,
    this.curve = Curves.linear,
    this.onStart,
    this.onDone,
    this.owner,
  });

  final double duration;
  final Curve curve;
  final VoidCallback? onStart;
  final void Function(double t) update;
  final VoidCallback? onDone;
  final Object? owner;
  double? start;
}

class _Ch11A1SourcesOfLightPageState extends State<Ch11A1SourcesOfLightPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  _LightScene _s = _LightScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final List<_Tw> _tweens = [];
  final math.Random _rnd = math.Random();
  late final Ticker _ticker;

  bool _hint = true; // "Drag & Drop objects to sort them!"
  bool _concluded = false;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_s.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_tick)..start();
    _buildScenario();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _tweens.clear();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final s = _s;
    s.time = now;
    if (_tweens.isNotEmpty) {
      for (final tw in List<_Tw>.of(_tweens)) {
        if (!_tweens.contains(tw)) continue;
        if (tw.start == null) {
          tw.start = now;
          tw.onStart?.call();
        }
        final p = tw.duration <= 0 ? 1.0 : ((now - tw.start!) / tw.duration).clamp(0.0, 1.0);
        tw.update(tw.curve.transform(p));
        if (p >= 1) {
          _tweens.remove(tw);
          tw.onDone?.call();
        }
      }
    }
    // Fireflies fly to a new random spot every 2.5 s (HTML setInterval).
    for (final it in s.items) {
      if (!it.active || !it.id.startsWith('firefly') || now < it.nextHop) continue;
      it.nextHop = now + 2.5;
      final c = it.id == 'firefly' ? _emitsZone : const Offset(-11, 5);
      final tx = c.dx + (_rnd.nextDouble() - 0.5) * (it.id == 'firefly' ? 8 : 10);
      final ty = c.dy + (_rnd.nextDouble() - 0.5) * (it.id == 'firefly' ? 8 : 5);
      _moveTo(it, tx, ty, it.z, ms: 2000);
    }
    _frame.value = now;
  }

  /// `new TWEEN.Tween(obj.position).to({x, y, z}, ms)`.
  void _moveTo(
    _Item it,
    double x,
    double y,
    double z, {
    required int ms,
    Curve curve = Curves.linear,
    VoidCallback? done,
  }) {
    _tweens.removeWhere((t) => t.owner == it);
    var x0 = it.x, y0 = it.y, z0 = it.z;
    _tweens.add(
      _Tw(
        duration: ms / 1000,
        curve: curve,
        owner: it,
        onStart: () {
          x0 = it.x;
          y0 = it.y;
          z0 = it.z;
        },
        update: (t) {
          it
            ..x = x0 + (x - x0) * t
            ..y = y0 + (y - y0) * t
            ..z = z0 + (z - z0) * t;
        },
        onDone: done,
      ),
    );
  }

  // ------------------------------------------------------------ logic

  /// HTML `buildScenario()`: objects back in the tray, effects off.
  void _buildScenario() {
    _lab.cancelPending();
    _tweens.clear();
    final old = _s;
    _s = _LightScene()
      ..scenario = old.scenario
      ..step = old.step
      ..time = old.time;
    const trayY = -8.0;
    _Item mk(String id, String type, int step, double x, double hit, String label, double off) =>
        _Item(id: id, type: type, step: step, initX: x, initY: trayY, hit: hit, labelKey: label, labelOffset: off);
    if (_s.scenario == 0) {
      _s.items.addAll([
        mk('sun', 'emits', 1, -12, 2.4, 'obj_sun', 4.5),
        mk('moon', 'reflects', 2, -6, 2.0, 'obj_moon', 3.0),
        mk('star', 'emits', 3, 0, 2.0, 'obj_star', 3.0),
        mk('firefly', 'emits', 4, 6, 1.6, 'obj_firefly', 1.5),
        mk('mirror', 'reflects', 5, 12, 2.0, 'obj_mirror', 2.5),
      ]);
    } else {
      _s.items.addAll([
        mk('lightning', 'natural', 1, -12, 2.2, 'obj_lightning', 3.0),
        mk('lamp', 'artificial', 2, -6, 2.0, 'obj_lamp', 2.0),
        mk('firefly2', 'natural', 3, 0, 1.6, 'obj_firefly', 1.5),
        mk('candle', 'artificial', 4, 6, 1.8, 'obj_candle', 2.5),
        mk('campfire', 'natural', 5, 12, 2.0, 'obj_campfire', 3.0),
      ]);
    }
    _hint = true;
    _concluded = false;
  }

  void _changeScenario(int index) {
    setState(() {
      _s.scenario = index;
      _s.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _s.scenario = 0;
      _s.step = 1;
      _buildScenario();
    });
  }

  /// HTML `advanceStep()`.
  void _advanceStep() {
    if (!mounted) return;
    final n = _data.steps.length;
    setState(() {
      if (_s.step < n) {
        _s.step++;
      } else if (_s.step == n && !_concluded) {
        _concluded = true;
        _lab.showScenarioConclusion(
          scenarioIndex: _s.scenario,
          totalScenarios: 2,
          title: () => _t('sci_conclusion'),
          body: () => _t('conclusion_${_s.scenario + 1}'),
        );
      }
    });
  }

  /// The object of the current step that may be dragged
  /// (HTML `updateObjectAvailability()`).
  _Item? get _currentItem {
    for (final it in _s.items) {
      if (it.step == _s.step && !it.placed) return it;
    }
    return null;
  }

  // ---------------------------------------------------- drag & drop

  void _onPanStart(DragStartDetails d) {
    if (!_lab.isLabActive || _concluded || _s.dragging != null) return;
    final it = _currentItem;
    if (it == null) return;
    final p = _toBoard(d.localPosition);
    final centerY = it.id == 'lamp' ? it.y - 0.5 : it.y;
    if ((p - Offset(it.x, centerY)).distance > it.hit + 0.6) return;
    _tweens.removeWhere((t) => t.owner == it); // stop a wrong-drop bounce
    setState(() {
      _hint = false;
      it.dragScale = 1.2;
      _s
        ..dragging = it
        ..dragOffset = Offset(it.x, it.y) - p;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final it = _s.dragging;
    if (it == null) return;
    final p = _toBoard(d.localPosition) + _s.dragOffset;
    it
      ..x = p.dx
      ..y = p.dy;
  }

  void _onPanEnd() {
    final it = _s.dragging;
    if (it == null) return;
    setState(() {
      it.dragScale = 1;
      _s.dragging = null;
    });
    _checkDrop(it);
  }

  /// HTML `checkDrop()`.
  void _checkDrop(_Item it) {
    final s = _s;
    var success = false;
    double tx = 0, ty = 0, tz = 0;
    if (s.scenario == 0) {
      final pos = Offset(it.x, it.y);
      if (it.type == 'emits' && (pos - _emitsZone).distance < _zoneRadius) {
        success = true;
        tx = _emitsZone.dx;
        ty = _emitsZone.dy;
      } else if (it.type == 'reflects' && (pos - _reflectsZone).distance < _zoneRadius) {
        success = true;
        tx = _reflectsZone.dx;
        ty = _reflectsZone.dy;
      }
      // Offsets so objects and labels do not overlap.
      if (success) {
        switch (it.id) {
          case 'sun':
            tx -= 2.5;
            ty += 1.5;
          case 'star':
            tx += 3.5;
            ty += 2.5;
          case 'moon':
            tx -= 2.5;
            ty += 1.0;
          case 'mirror':
            tx += 2.5;
            ty -= 1.0;
        }
      }
    } else {
      if (it.type == 'natural' && it.x < 0) {
        success = true;
        tx = -11 + (_rnd.nextDouble() - 0.5) * 8;
        ty = 5 + _rnd.nextDouble() * 5;
      } else if (it.type == 'artificial' && it.x > 0) {
        success = true;
        tx = 11 + (_rnd.nextDouble() - 0.5) * 8;
        ty = 5 + _rnd.nextDouble() * 5;
      }
      if (success) {
        switch (it.id) {
          case 'lamp': // ceiling
            tx = 11;
            ty = 12;
            tz = -2;
          case 'candle': // on the table top
            tx = 11;
            ty = 3.1;
            tz = -2;
          case 'campfire': // on the ground
            tx = -11;
            ty = -1.4;
            tz = -2;
          case 'lightning': // sky
            tx = -11;
            ty = 15;
            tz = -5;
        }
      }
    }

    if (success) {
      _lab.showToast(_t('sci_conclusion'));
      setState(() => it.placed = true);
      _moveTo(
        it,
        tx,
        ty,
        tz,
        ms: 400,
        curve: Curves.easeOutCubic,
        done: () {
          _triggerEffect(it);
          _advanceStep();
        },
      );
    } else {
      _lab.showToast(_t('msg_wrong_drop'), isError: true);
      _moveTo(it, it.initX, it.initY, 0, ms: 500, curve: Curves.elasticOut);
    }
  }

  /// HTML `triggerActionEffect()`.
  void _triggerEffect(_Item it) {
    final s = _s;
    it
      ..active = true
      ..activeAt = s.time;
    final sun = s.item('sun');
    switch (it.id) {
      case 'moon':
        if (sun != null) s.beams.add(_Beam(Offset(sun.x, sun.y), Offset(it.x, it.y), s.time));
      case 'mirror':
        if (sun != null) s.beams.add(_Beam(Offset(sun.x, sun.y), Offset(it.x, it.y), s.time));
        s.beams.add(_Beam(Offset(it.x, it.y), Offset(it.x + 10, it.y - 10), s.time + 0.3));
      case 'firefly':
      case 'firefly2':
        it.nextHop = s.time + 2.5;
      case 'lightning':
        _Audio.play(_Sound.spark);
        s.flashAt = s.time;
        _lab.after(const Duration(milliseconds: 500), () => it.visible = false);
    }
    setState(() {});
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
        final isS1 = _s.scenario == 0;
        return LabShell(
          controller: _lab,
          icon: Icons.lightbulb,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _s.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _s.step,
          sidebarExtraTitle: _t('progress'),
          sidebarExtra: _progress(p, s),
          onReset: _fullReset,
          overlays: [if (_hint && _lab.isLabActive) _hintOverlay(s)],
          stage: LabStage(
            designSize: _design,
            // A small touch slop so short drags on phones still pick objects up.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                dragStartBehavior: DragStartBehavior.down,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: _design,
                  painter: _LightPainter(
                    scene: _s,
                    repaint: _frame,
                    isDark: _lab.isDark,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang.code,
                    strings: {
                      for (final k in [
                        if (isS1) ...['emits_light', 'reflects_light'] else ...['natural_light', 'artificial_light'],
                        for (final it in _s.items) it.labelKey,
                      ])
                        k: _t(k),
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#drag-instruction`: a bouncing hand with the hint, hidden once
  /// the first object is picked up.
  Widget _hintOverlay(double s) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            builder: (context, v, child) => Opacity(opacity: v, child: child),
            child: _Ch11A1Bounce(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 260 * s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, size: 34 * s, color: Colors.white.withValues(alpha: 0.6)),
                    SizedBox(height: 4 * s),
                    Text(
                      _t('drag_drop_hint'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w800,
                        fontSize: 13 * s,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sidebar readout: where each object has been sorted so far.
  Widget _progress(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final rows = <Widget>[];
    for (final it in _s.items) {
      final String status;
      final Color color;
      final IconData icon;
      if (it.placed) {
        status = _t(switch (it.type) {
          'emits' => 'emits_light',
          'reflects' => 'reflects_light',
          'natural' => 'natural_light',
          _ => 'artificial_light',
        });
        color = _Colors.green;
        icon = Icons.check_circle;
      } else if (it.step == _s.step) {
        status = _t('status_now');
        color = _Colors.zslYellow;
        icon = Icons.pan_tool_alt;
      } else {
        status = _t('status_waiting');
        color = p.textMuted;
        icon = Icons.hourglass_empty;
      }
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3 * s),
          child: Row(
            children: [
              Icon(icon, size: 15 * s, color: color),
              SizedBox(width: 6 * s),
              Expanded(
                child: Text(
                  _t(it.labelKey),
                  style: TextStyle(color: p.text, fontSize: 12 * f, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 6 * s),
              Flexible(
                child: Text(
                  status,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: color, fontSize: 11.5 * f, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }
}

/// Gentle up / down bounce (Tailwind `animate-bounce`).
class _Ch11A1Bounce extends StatefulWidget {
  const _Ch11A1Bounce({required this.child});
  final Widget child;

  @override
  State<_Ch11A1Bounce> createState() => _Ch11A1BounceState();
}

class _Ch11A1BounceState extends State<_Ch11A1Bounce> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = _c.value;
        final up = v < 0.5 ? Curves.easeOut.transform(v * 2) : Curves.easeIn.transform(2 - v * 2);
        return Transform.translate(offset: Offset(0, -12 * up), child: child);
      },
      child: widget.child,
    );
  }
}

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Sources of Light',
    'app_subtitle': 'Class 7 • Light: Shadows and Reflections',
    'scen_1_opt': 'Scenario 1: Luminous vs. Non-Luminous',
    'scen_2_opt': 'Scenario 2: Natural vs. Artificial',
    'sci_conclusion': 'Success!',
    'emits_light': 'Emits Light',
    'reflects_light': 'Reflects Light',
    'natural_light': 'Natural Light',
    'artificial_light': 'Artificial Light',
    'drag_drop_hint': 'Drag & Drop objects to sort them!',
    'msg_wrong_drop': 'Not quite! Try the other category.',
    'conclusion_1':
        'Luminous objects like the Sun, stars, and fireflies create their own light. Non-luminous objects like the Moon and mirrors only shine by reflecting light from a luminous source.',
    'conclusion_2':
        'Natural sources like lightning, fireflies, and fire occur in nature. Artificial sources like lamps and candles are made by humans. Both are important in our daily lives.',
    'obj_sun': 'Sun',
    'obj_moon': 'Moon',
    'obj_star': 'Star',
    'obj_firefly': 'Firefly',
    'obj_mirror': 'Mirror',
    'obj_lightning': 'Lightning',
    'obj_lamp': 'Lamp',
    'obj_candle': 'Candle',
    'obj_campfire': 'Campfire',
    // Sidebar readout (not in the HTML).
    'progress': 'Sorting Progress',
    'status_now': 'Drag now',
    'status_waiting': 'Waiting',
  },
  'hi': {
    'app_title': 'प्रकाश के स्रोत',
    'app_subtitle': 'कक्षा 7 • प्रकाश: छाया और परावर्तन',
    'scen_1_opt': 'परिदृश्य 1: दीप्त बनाम अदीप्त',
    'scen_2_opt': 'परिदृश्य 2: प्राकृतिक बनाम कृत्रिम',
    'sci_conclusion': 'सफलता!',
    'emits_light': 'प्रकाश उत्सर्जित करता है',
    'reflects_light': 'प्रकाश परावर्तित करता है',
    'natural_light': 'प्राकृतिक प्रकाश',
    'artificial_light': 'कृत्रिम प्रकाश',
    'drag_drop_hint': 'वस्तुओं को सॉर्ट करने के लिए खींचें और छोड़ें!',
    'msg_wrong_drop': 'बिल्कुल नहीं! दूसरी श्रेणी का प्रयास करें।',
    'conclusion_1':
        'सूर्य, तारे और जुगनू जैसी दीप्त वस्तुएँ अपना प्रकाश स्वयं उत्पन्न करती हैं। चंद्रमा और दर्पण जैसी अदीप्त वस्तुएँ केवल दीप्त स्रोत से प्रकाश को परावर्तित करके चमकती हैं।',
    'conclusion_2':
        'बिजली, जुगनू और आग जैसे प्राकृतिक स्रोत प्रकृति में पाए जाते हैं। लैंप और मोमबत्तियाँ जैसे कृत्रिम स्रोत मनुष्यों द्वारा बनाए जाते हैं। हमारे दैनिक जीवन में दोनों महत्वपूर्ण हैं।',
    'obj_sun': 'सूर्य',
    'obj_moon': 'चंद्रमा',
    'obj_star': 'तारा',
    'obj_firefly': 'जुगनू',
    'obj_mirror': 'दर्पण',
    'obj_lightning': 'बिजली',
    'obj_lamp': 'लैंप',
    'obj_candle': 'मोमबत्ती',
    'obj_campfire': 'कैम्प फायर',
    'progress': 'छँटाई की प्रगति',
    'status_now': 'अभी खींचें',
    'status_waiting': 'प्रतीक्षा में',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To correctly classify objects as either luminous (emitting their own light) or non-luminous (reflecting light).',
      steps: [
        LabStep(
          concept: 'Luminous Object (Sun)',
          action: "DRAG the Sun from the tray and DROP it into the 'Emits Light' circle.",
          observation: 'The Sun emits its own light, illuminating the space.',
        ),
        LabStep(
          concept: 'Non-Luminous Object (Moon)',
          action: "DRAG the Moon from the tray and DROP it into the 'Reflects Light' circle.",
          observation: "The Moon reflects the Sun's light to become visible.",
        ),
        LabStep(
          concept: 'Luminous Object (Star)',
          action: 'DRAG the Star into the correct circle.',
          observation: 'Stars, like our Sun, create their own light.',
        ),
        LabStep(
          concept: 'Luminous Object (Firefly)',
          action: 'DRAG the Firefly into the correct circle.',
          observation: 'Fireflies naturally generate their own light (bioluminescence).',
        ),
        LabStep(
          concept: 'Non-Luminous Object (Mirror)',
          action: 'DRAG the Mirror into the correct circle.',
          observation: 'A mirror reflects light rays falling on it; it has no light of its own.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To correctly classify sources of light as either natural or artificial (human-made).',
      steps: [
        LabStep(
          concept: 'Natural Source (Lightning)',
          action: 'DRAG the Lightning Bolt icon into the scene where it belongs (Natural vs Artificial).',
          observation: 'Lightning is a natural electrical discharge that produces brief, intense light.',
        ),
        LabStep(
          concept: 'Artificial Source (LED Lamp)',
          action: 'DRAG the LED Lamp into the correct scene.',
          observation: 'A lamp is an artificial light source created by humans.',
        ),
        LabStep(
          concept: 'Natural Source (Firefly)',
          action: 'DRAG the Firefly into the correct scene.',
          observation: 'Fireflies are part of nature and produce natural light.',
        ),
        LabStep(
          concept: 'Artificial Source (Candle)',
          action: 'DRAG the lit Candle into the correct scene.',
          observation: 'Candles are human-made tools to provide light.',
        ),
        LabStep(
          concept: 'Natural Source (Campfire)',
          action: 'DRAG the Campfire into the correct scene.',
          observation: 'Fire naturally occurs, providing heat and natural light in the wilderness.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'वस्तुओं को दीप्त (अपना प्रकाश स्वयं उत्सर्जित करने वाले) या अदीप्त (प्रकाश को परावर्तित करने वाले) के रूप में सही ढंग से वर्गीकृत करना।',
      steps: [
        LabStep(
          concept: 'दीप्त वस्तु (सूर्य)',
          action: "ट्रे से सूर्य को खींचें और इसे 'Emits Light' (प्रकाश उत्सर्जित करता है) चक्र में छोड़ दें।",
          observation: 'सूर्य अपना प्रकाश स्वयं उत्सर्जित करता है, जिससे अंतरिक्ष प्रकाशित होता है।',
        ),
        LabStep(
          concept: 'अदीप्त वस्तु (चंद्रमा)',
          action: "ट्रे से चंद्रमा को खींचें और इसे 'Reflects Light' (प्रकाश परावर्तित करता है) चक्र में छोड़ दें।",
          observation: 'चंद्रमा दृश्यमान होने के लिए सूर्य के प्रकाश को परावर्तित करता है।',
        ),
        LabStep(
          concept: 'दीप्त वस्तु (तारा)',
          action: 'तारे को सही चक्र में खींचें।',
          observation: 'तारे, हमारे सूर्य की तरह, अपना प्रकाश स्वयं बनाते हैं।',
        ),
        LabStep(
          concept: 'दीप्त वस्तु (जुगनू)',
          action: 'जुगनू को सही चक्र में खींचें।',
          observation: 'जुगनू स्वाभाविक रूप से अपना प्रकाश स्वयं उत्पन्न करते हैं।',
        ),
        LabStep(
          concept: 'अदीप्त वस्तु (दर्पण)',
          action: 'दर्पण को सही चक्र में खींचें।',
          observation: 'एक दर्पण उस पर पड़ने वाली प्रकाश किरणों को परावर्तित करता है; इसका अपना कोई प्रकाश नहीं होता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'प्रकाश के स्रोतों को प्राकृतिक या कृत्रिम (मानव निर्मित) के रूप में सही ढंग से वर्गीकृत करना।',
      steps: [
        LabStep(
          concept: 'प्राकृतिक स्रोत (बिजली)',
          action: 'बिजली के बोल्ट आइकन को उस दृश्य (प्राकृतिक या कृत्रिम) में खींचें जहाँ यह संबंधित है।',
          observation: 'बिजली एक प्राकृतिक विद्युत निर्वहन है जो संक्षिप्त, तीव्र प्रकाश उत्पन्न करती है।',
        ),
        LabStep(
          concept: 'कृत्रिम स्रोत (एलईडी लैंप)',
          action: 'एलईडी लैंप को सही दृश्य में खींचें।',
          observation: 'एक लैंप मनुष्यों द्वारा बनाया गया एक कृत्रिम प्रकाश स्रोत है।',
        ),
        LabStep(
          concept: 'प्राकृतिक स्रोत (जुगनू)',
          action: 'जुगनू को सही दृश्य में खींचें।',
          observation: 'जुगनू प्रकृति का हिस्सा हैं और प्राकृतिक प्रकाश उत्पन्न करते हैं।',
        ),
        LabStep(
          concept: 'कृत्रिम स्रोत (मोमबत्ती)',
          action: 'जली हुई मोमबत्ती को सही दृश्य में खींचें।',
          observation: 'मोमबत्तियाँ प्रकाश प्रदान करने के लिए मानव निर्मित उपकरण हैं।',
        ),
        LabStep(
          concept: 'प्राकृतिक स्रोत (कैम्प फायर)',
          action: 'कैम्प फायर को सही दृश्य में खींचें।',
          observation: 'आग स्वाभाविक रूप से होती है, जो जंगल में गर्मी और प्राकृतिक प्रकाश प्रदान करती है।',
        ),
      ],
    ),
  ],
};

// ============================================================ PAINTER

/// Triangle wave 0 → 1 → 0 with the given half period (TWEEN yoyo, linear).
double _tri(double t, double half) {
  final p = (t / half) % 2;
  return p < 1 ? p : 2 - p;
}

/// HTML flicker noise: sin(ms · speed) · cos(ms · speed · 0.8).
double _flick(double t, double speed) {
  final ms = t * 1000;
  return math.sin(ms * speed) * math.cos(ms * speed * 0.8);
}

class _LightPainter extends CustomPainter {
  _LightPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.strings,
  }) : super(repaint: repaint);

  final _LightScene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final Map<String, String> strings;

  String _l(String key) => strings[key] ?? key;

  static final List<(double, double, double, double)> _stars = () {
    final r = math.Random(11);
    return [
      for (var i = 0; i < 300; i++)
        ((r.nextDouble() - 0.5) * 100, (r.nextDouble() - 0.5) * 100, -20 - r.nextDouble() * 20, r.nextDouble() * 6.28),
    ];
  }();

  // (x, z) of the four forest trees (random in the HTML, fixed here).
  static const List<(double, double)> _trees = [(-18.6, -6.2), (-14.2, -9.3), (-7.6, -7.4), (-11.9, -5.6)];

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    final t = s.time;
    if (s.scenario == 0) {
      _paintSpace(canvas, size, t);
      _paintRings(canvas, t);
    } else {
      _paintSplit(canvas, size, t);
    }
    _paintTray(canvas);
    if (s.scenario == 0) _paintBeams(canvas, t);

    // Placed / tray objects first, the held one on top.
    for (final it in s.items) {
      if (it != s.dragging) _paintItem(canvas, it, t);
    }
    if (s.dragging != null) _paintItem(canvas, s.dragging!, t);

    if (s.scenario == 1) _paintFlash(canvas, size);
    _paintLabels(canvas);
    if (s.scenario == 0) {
      _paintZoneTitles(canvas, t);
    } else {
      _paintSceneTitles(canvas);
    }
  }

  // ------------------------------------------------------ scenario 1

  void _paintSpace(Canvas canvas, Size size, double t) {
    final bleed = labBleed(size);
    canvas.drawRect(
      bleed,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020617), Color(0xFF0B1330), Color(0xFF020617)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    // Faint nebulae.
    for (final (c, r, col) in const [
      (Offset(220, 140), 260.0, Color(0xFF4C1D95)),
      (Offset(700, 120), 230.0, Color(0xFF1E3A8A)),
    ]) {
      labGlow(canvas, c, r, col, intensity: 0.25);
    }
    // Background star field (HTML THREE.Points, 300 stars).
    final p = Paint();
    for (final (x, y, z, ph) in _stars) {
      final d = _toDesign(x, y, z);
      final tw = 0.55 + 0.45 * math.sin(t * 1.7 + ph * 3);
      p.color = Colors.white.withValues(alpha: 0.35 + 0.5 * tw);
      canvas.drawCircle(d, 0.9 + 0.5 * tw, p);
    }
    // The Sun's light warms the scene a little (globalLight 0.2 → 0.3).
    final sun = scene.item('sun');
    if (sun != null && sun.active) {
      labGlow(canvas, _toDesign(sun.x, sun.y), 420, const Color(0xFFFFAA00), intensity: 0.22);
    }
  }

  /// Target rings (HTML TorusGeometry r = 8 at z = -2).
  void _paintRings(Canvas canvas, double t) {
    final hover = scene.hoverZone;
    for (final (zone, c, color) in const [
      ('emits', _emitsZone, Color(0xFFEAB308)),
      ('reflects', _reflectsZone, Color(0xFF94A3B8)),
    ]) {
      final center = _toDesign(c.dx, c.dy, -2);
      final r = _zoneRadius * _u * _kz(-2);
      final on = hover == zone;
      canvas.drawCircle(center, r, Paint()..color = color.withValues(alpha: on ? 0.16 : 0.05));
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4 * _u + (on ? 2 : 0)
          ..color = color.withValues(alpha: on ? 0.95 : 0.5),
      );
      if (on) {
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 14
            ..color = color.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
    }
  }

  /// HTML `#s1-ui`: sun / moon icons with "Emits Light" / "Reflects Light",
  /// each with the pulsing `drop-target-active` ring.
  void _paintZoneTitles(Canvas canvas, double t) {
    final pulse = (t / 2) % 1;
    for (final (key, c, border, isSun) in const [
      ('emits_light', _emitsZone, Color(0x80EAB308), true),
      ('reflects_light', _reflectsZone, Color(0x8094A3B8), false),
    ]) {
      final top = _toDesign(c.dx, c.dy + _zoneRadius, -2);
      final iconC = top.translate(0, -26);
      if (isSun) {
        _sunIcon(canvas, iconC, 11);
      } else {
        _moonIcon(canvas, iconC, 11);
      }
      final rect = labText(
        canvas,
        _l(key),
        top.translate(0, 2),
        size: 15,
        color: Colors.white,
        weight: FontWeight.w800,
        background: const Color(0x99000000),
        border: border,
        borderWidth: 1.2,
        letterSpacing: lang == 'en' ? 1 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      );
      // `pulse-ring`: a yellow halo that expands and fades every 2 s.
      final box = Rect.fromLTRB(rect.left, iconC.dy - 14, rect.right, rect.bottom).inflate(4 + 16 * pulse);
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(box.height / 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFEAB308).withValues(alpha: 0.5 * (1 - pulse)),
      );
    }
  }

  void _sunIcon(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = const Color(0xFFFACC15);
    canvas.drawCircle(c, r * 0.55, p);
    final ray = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final u = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + u * r * 0.78, c + u * r * 1.08, ray);
    }
  }

  void _moonIcon(Canvas canvas, Offset c, double r) {
    final path = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.9)),
      Path()..addOval(Rect.fromCircle(center: c.translate(r * 0.45, -r * 0.3), radius: r * 0.75)),
    );
    canvas.drawPath(path, Paint()..color = const Color(0xFFCBD5E1));
  }

  /// Light beams (white cylinders, opacity 0.6) with travelling photons.
  void _paintBeams(Canvas canvas, double t) {
    for (final b in scene.beams) {
      final age = t - b.t0;
      if (age < 0) continue;
      final grow = (age / 0.3).clamp(0.0, 1.0);
      final a = _toDesign(b.a.dx, b.a.dy);
      final end = Offset.lerp(a, _toDesign(b.b.dx, b.b.dy), grow)!;
      canvas.drawLine(
        a,
        end,
        Paint()
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFF7CC).withValues(alpha: 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawLine(
        a,
        end,
        Paint()
          ..strokeWidth = 0.4 * _u
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.6),
      );
      if (grow >= 1) {
        final len = (end - a).distance;
        for (var i = 0; i < 4; i++) {
          final f = ((t * 60 + i * len / 4) % len) / len;
          canvas.drawCircle(Offset.lerp(a, end, f)!, 2.6, Paint()..color = const Color(0xFFFFF3B0));
        }
      }
    }
  }

  // ------------------------------------------------------ scenario 2

  /// Split background: night forest (natural) | room (artificial).
  void _paintSplit(Canvas canvas, Size size, double t) {
    final bleed = labBleed(size);
    canvas.drawRect(bleed, Paint()..color = const Color(0xFF0F172A));
    final mid = _toDesign(0, 0, -5).dx;
    final groundY = _toDesign(0, -2, -2).dy;
    final hover = scene.hoverZone;
    // Forest sky and ground.
    final left = Rect.fromLTRB(bleed.left, bleed.top, mid, groundY);
    canvas.drawRect(
      left,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020617), Color(0xFF0F2A3D)],
        ).createShader(Rect.fromLTRB(0, 0, 10, groundY)),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, groundY, mid, bleed.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14532D), Color(0xFF052E16)],
        ).createShader(Rect.fromLTRB(0, groundY, 10, groundY + 80)),
    );
    // Room wall and floor.
    canvas.drawRect(
      Rect.fromLTRB(mid, bleed.top, bleed.right, groundY),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C1917), Color(0xFF292524)],
        ).createShader(Rect.fromLTRB(0, 0, 10, groundY)),
    );
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.025);
    for (var x = mid + 18; x < bleed.right; x += 36) {
      canvas.drawRect(Rect.fromLTRB(x, bleed.top, x + 14, groundY), stripe);
    }
    final ceilY = _toDesign(0, 13.6, -2).dy;
    canvas.drawRect(Rect.fromLTRB(mid, bleed.top, bleed.right, ceilY), Paint()..color = const Color(0xFF0C0A09));
    canvas.drawRect(
      Rect.fromLTRB(mid, groundY, bleed.right, bleed.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF44403C), Color(0xFF1C1917)],
        ).createShader(Rect.fromLTRB(0, groundY, 10, groundY + 80)),
    );
    if (hover != null) {
      final r = hover == 'natural'
          ? Rect.fromLTRB(bleed.left, bleed.top, mid, bleed.bottom)
          : Rect.fromLTRB(mid, bleed.top, bleed.right, bleed.bottom);
      canvas.drawRect(
        r,
        Paint()..color = (hover == 'natural' ? _Colors.green : _Colors.blue).withValues(alpha: 0.1),
      );
    }
    // Night sky stars over the forest.
    final sp = Paint();
    for (final (x, y, z, ph) in _stars.take(70)) {
      final d = _toDesign(x * 0.5 - 12, 8 + y.abs() * 0.25, z);
      if (d.dx > mid - 4 || d.dy > groundY - 30) continue;
      sp.color = Colors.white.withValues(alpha: 0.3 + 0.3 * math.sin(t * 1.3 + ph * 3).abs());
      canvas.drawCircle(d, 1.1, sp);
    }
    // Forest trees (cone r 3 h 8 on a trunk).
    for (final (x, z) in _trees) {
      final k = _kz(z);
      final base = _toDesign(x, 0, z);
      final trunk = Rect.fromLTRB(base.dx - 0.5 * _u * k, base.dy, base.dx + 0.5 * _u * k, base.dy + 2 * _u * k);
      canvas.drawRect(trunk, Paint()..color = const Color(0xFF451A03));
      final apex = _toDesign(x, 8, z);
      final cone = Path()
        ..moveTo(apex.dx, apex.dy)
        ..lineTo(base.dx + 3 * _u * k, base.dy)
        ..quadraticBezierTo(base.dx, base.dy + 0.8 * _u * k, base.dx - 3 * _u * k, base.dy)
        ..close();
      canvas.drawPath(
        cone,
        Paint()
          ..shader = const LinearGradient(colors: [Color(0xFF022C22), Color(0xFF065F46), Color(0xFF064E3B)])
              .createShader(cone.getBounds()),
      );
    }
    // Table (BoxGeometry 6 × 4 × 3 at (11, 0, -2)).
    final tl = _toDesign(8, 2, -0.5), br = _toDesign(14, -2, -0.5);
    labBox3D(canvas, Rect.fromPoints(tl, br), 0.9 * _u, const Color(0xFF78350F), angle: -1.25);
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = tl.dy + (br.dy - tl.dy) * i / 4;
      canvas.drawLine(Offset(tl.dx + 6, y), Offset(br.dx - 6, y), grain);
    }
    // Divider (white, opacity 0.3).
    canvas.drawRect(
      Rect.fromCenter(center: Offset(mid, 280), width: 0.2 * _u, height: 2000),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  /// HTML `#s2-ui`: "NATURAL LIGHT" / "ARTIFICIAL LIGHT".
  void _paintSceneTitles(Canvas canvas) {
    for (final (key, x, text, border) in const [
      ('natural_light', -11.0, Color(0xFF86EFAC), Color(0x8022C55E)),
      ('artificial_light', 11.0, Color(0xFF93C5FD), Color(0x803B82F6)),
    ]) {
      final label = lang == 'en' ? _l(key).toUpperCase() : _l(key);
      labText(
        canvas,
        label,
        Offset(_toDesign(x, 0).dx, 30),
        size: 17,
        color: text,
        weight: FontWeight.w800,
        background: const Color(0x99000000),
        border: border,
        borderWidth: 2,
        letterSpacing: lang == 'en' ? 1.2 : 0,
        shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 2))],
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      );
    }
  }

  // ------------------------------------------------------ shared bits

  /// The object tray (BoxGeometry 40 × 4 × 1 at (0, -8, -1)), lit by the
  /// dedicated tray light.
  void _paintTray(Canvas canvas) {
    final r = Rect.fromPoints(_toDesign(-20, -6, -1), _toDesign(20, -10, -1));
    final top = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.left + 10, r.top - 10)
      ..lineTo(r.right - 10, r.top - 10)
      ..lineTo(r.right, r.top)
      ..close();
    canvas.drawPath(top, Paint()..color = const Color(0xFF64748B));
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(6));
    canvas.drawRRect(
      rr.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF475569), Color(0xFF334155), Color(0xFF1E293B)],
        ).createShader(r),
    );
    canvas.drawLine(
      r.topLeft.translate(6, 1),
      r.topRight.translate(-6, 1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.5,
    );
    // Tray light pool.
    labGlow(canvas, r.center.translate(0, -24), r.width * 0.45, const Color(0xFFE2E8F0), intensity: 0.08);
  }

  /// Lightning flash (HTML global light 2.0 → 0.1 → 1.5 → 0.2).
  void _paintFlash(Canvas canvas, Size size) {
    final a = scene.ambient;
    if (a > 0.25) {
      canvas.drawRect(
        labBleed(size),
        Paint()..color = const Color(0xFFE0E7FF).withValues(alpha: ((a - 0.2) * 0.3).clamp(0.0, 0.6)),
      );
    } else if (a < 0.15) {
      canvas.drawRect(labBleed(size), Paint()..color = Colors.black.withValues(alpha: 0.15));
    }
  }

  /// Floating object labels (HTML `createLabel`), dimmed for later steps.
  void _paintLabels(Canvas canvas) {
    if (!showLabels) return;
    for (final it in scene.items) {
      if (!it.visible) continue;
      final pos = _toDesign(it.x, it.y + it.labelOffset, it.z);
      labText(
        canvas,
        _l(it.labelKey),
        pos,
        size: 12.5,
        color: Colors.white,
        weight: FontWeight.w700,
        background: const Color(0xCC0F172A),
        border: const Color(0x80334155),
        borderWidth: 1,
        radius: 5,
        opacity: it.step > scene.step ? 0.3 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );
    }
  }

  void _paintItem(Canvas canvas, _Item it, double t) {
    if (!it.visible) return;
    final s = scene;
    final current = it.step == s.step && !it.placed;
    final pulse = current && s.dragging != it ? 1 + 0.1 * _tri(t, 0.5) : 1.0;
    final scale = it.dragScale * pulse;
    final px = _u * _kz(it.z) * scale; // pixels per unit for this object
    final c = _toDesign(it.x, it.y, it.z);
    final opacity = it.step > s.step ? 0.3 : 1.0;
    if (current) {
      labGlow(canvas, c, it.hit * px * 1.5, _Colors.zslYellow, intensity: 0.18 + 0.12 * _tri(t, 0.5));
    }
    if (opacity < 1) canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: opacity));
    switch (it.id) {
      case 'sun':
        _sun(canvas, c, px, it, t);
      case 'moon':
        _moon(canvas, c, px, it);
      case 'star':
        _star(canvas, c, px, it, t);
      case 'firefly':
      case 'firefly2':
        _firefly(canvas, c, px, it, t);
      case 'mirror':
        _mirror(canvas, c, px, it, t);
      case 'lightning':
        _lightning(canvas, c, px, it, t);
      case 'lamp':
        _lamp(canvas, c, px, it, t);
      case 'candle':
        _candle(canvas, c, px, it, t);
      case 'campfire':
        _campfire(canvas, c, px, it, t);
    }
    if (opacity < 1) canvas.restore();
  }

  // ------------------------------------------------- scenario 1 items

  void _sun(Canvas canvas, Offset c, double px, _Item it, double t) {
    var r = 2 * px;
    if (it.active) {
      // scale 1.5, then a slow 1.5 ↔ 1.6 flare (2 s each way).
      r *= 1.5 + 0.1 * _tri(t - it.activeAt, 2);
      labGlow(canvas, c, r * 4.2, const Color(0xFFFFAA00), intensity: 0.75);
      final ray = Paint()
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.55);
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6 + t * 0.25;
        final u = Offset(math.cos(a), math.sin(a));
        final len = r * (1.45 + 0.12 * math.sin(t * 3 + i));
        ray.strokeWidth = r * (i.isEven ? 0.16 : 0.09);
        canvas.drawLine(c + u * r * 1.12, c + u * len, ray);
      }
    } else {
      labGlow(canvas, c, r * 1.8, const Color(0xFFFACC15), intensity: 0.3);
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.3),
          colors: [Color(0xFFFFFBEB), Color(0xFFFDE047), Color(0xFFFACC15), Color(0xFFF59E0B)],
          stops: [0, 0.35, 0.75, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _moon(Canvas canvas, Offset c, double px, _Item it) {
    final r = 1.5 * px;
    final sun = scene.item('sun');
    var light = const Offset(-0.15, -0.45); // the tray light, from above
    if (sun != null && sun.active) {
      final d = Offset(sun.x - it.x, -(sun.y - it.y));
      light = d / math.max(0.001, d.distance) * 0.6;
    }
    if (it.active) {
      labGlow(canvas, c, r * 2.2, const Color(0xFFE2E8F0), intensity: 0.35);
    }
    labSphere(
      canvas,
      c,
      r,
      it.active ? const Color(0xFFE5E7EB) : const Color(0xFF94A3B8),
      light: light,
      highlight: it.active ? 0.7 : 0.35,
      shade: it.active ? 0.35 : 0.6,
    );
    final crater = Paint()..color = Colors.black.withValues(alpha: it.active ? 0.1 : 0.16);
    for (final (dx, dy, cr) in const [(-0.35, -0.25, 0.28), (0.3, 0.2, 0.2), (0.05, 0.5, 0.14), (0.45, -0.4, 0.12)]) {
      canvas.drawCircle(c + Offset(dx * r, dy * r), cr * r, crater);
    }
  }

  Path _starPath(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = (i / 5) * math.pi * 2 + math.pi / 2;
      final b = ((i + 0.5) / 5) * math.pi * 2 + math.pi / 2;
      final p1 = c + Offset(math.cos(a) * outer, -math.sin(a) * outer);
      final p2 = c + Offset(math.cos(b) * inner, -math.sin(b) * inner);
      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.lineTo(p2.dx, p2.dy);
    }
    return path..close();
  }

  void _star(Canvas canvas, Offset c, double px, _Item it, double t) {
    var k = px;
    if (it.active) {
      k *= 1 + 0.3 * _tri(t - it.activeAt, 0.5); // twinkle 1 ↔ 1.3
      labGlow(canvas, c, 4.2 * k, const Color(0xFFFEF08A), intensity: 0.65);
      final sp = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(c.translate(-2.6 * k, 0), c.translate(2.6 * k, 0), sp);
      canvas.drawLine(c.translate(0, -2.6 * k), c.translate(0, 2.6 * k), sp);
    }
    // Extruded body with a bevel.
    canvas.drawPath(_starPath(c.translate(0.12 * k, 0.16 * k), 1.5 * k, 0.6 * k), Paint()..color = const Color(0xFFCA8A04));
    final face = _starPath(c, 1.5 * k, 0.6 * k);
    canvas.drawPath(
      face,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          colors: [Color(0xFFFFFDE7), Color(0xFFFEF08A), Color(0xFFFACC15)],
        ).createShader(Rect.fromCircle(center: c, radius: 1.5 * k)),
    );
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6),
    );
  }

  void _firefly(Canvas canvas, Offset c, double px, _Item it, double t) {
    final noise = it.active ? _flick(t, 0.05) : 0.0;
    final tail = c.translate(0.5 * px, 0);
    if (it.active) {
      labGlow(canvas, tail, 4.5 * px * (1 + 0.15 * noise), const Color(0xFF84CC16), intensity: 0.55 + 0.2 * noise);
    }
    // Wings (flapping while it flies).
    final flap = it.active ? math.sin(t * 38) : 0.4;
    final wing = Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.45);
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(c.dx - 0.05 * px, c.dy - 0.2 * px);
      canvas.rotate(side * (0.5 + 0.35 * flap) - math.pi / 2 * 0.15);
      canvas.drawOval(Rect.fromLTWH(-0.25 * px, -0.75 * px, 0.5 * px, 0.75 * px), wing);
      canvas.restore();
    }
    // Body (ellipsoid 1.2 × 0.6) and head.
    final body = Rect.fromCenter(center: c, width: 1.2 * px, height: 0.6 * px);
    canvas.drawOval(
      body,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          colors: [Color(0xFF4B5563), Color(0xFF222222), Color(0xFF0A0A0A)],
        ).createShader(body),
    );
    canvas.drawCircle(c.translate(-0.62 * px, -0.05 * px), 0.22 * px, Paint()..color = const Color(0xFF1F2937));
    // Glowing abdomen (MeshBasic 0x84cc16, scales with the flicker).
    final gr = 0.4 * px * (1 + math.max(0, noise) * 0.5);
    canvas.drawCircle(
      tail,
      gr,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFECFCCB), Color(0xFFA3E635), Color(0xFF84CC16)],
          stops: [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: tail, radius: gr)),
    );
  }

  void _mirror(Canvas canvas, Offset c, double px, _Item it, double t) {
    final rf = 1.6 * px, rg = 1.4 * px;
    canvas.drawCircle(c.translate(0.12 * px, 0.14 * px), rf, Paint()..color = const Color(0xFF5B3A1A));
    canvas.drawCircle(
      c,
      rf,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB07A45), Color(0xFF8B5A2B), Color(0xFF5B3A1A)],
        ).createShader(Rect.fromCircle(center: c, radius: rf)),
    );
    final glass = Rect.fromCircle(center: c, radius: rg);
    canvas.save();
    canvas.clipPath(Path()..addOval(glass));
    canvas.drawRect(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDFA), Color(0xFFCCFBF1), Color(0xFF99F6E4), Color(0xFFE6FFFB)],
          stops: [0, 0.4, 0.75, 1],
        ).createShader(glass),
    );
    final shine = Paint()..color = Colors.white.withValues(alpha: 0.65);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.8);
    canvas.drawRect(Rect.fromLTWH(-rg, -rg * 0.55, rg * 2, rg * 0.18), shine);
    canvas.drawRect(Rect.fromLTWH(-rg, -rg * 0.25, rg * 2, rg * 0.07), shine);
    canvas.restore();
    canvas.restore();
    if (it.active) {
      final p = 0.5 + 0.5 * math.sin(t * 5);
      labGlow(canvas, c, rg * 1.4, Colors.white, intensity: 0.35 + 0.25 * p);
    }
  }

  void _lightning(Canvas canvas, Offset c, double px, _Item it, double t) {
    final flash = it.active ? (1 - ((t - it.activeAt) / 0.5).clamp(0.0, 1.0)) : 0.0;
    labGlow(canvas, c, (2.2 + 4 * flash) * px, const Color(0xFFFEF08A), intensity: 0.3 + 0.6 * flash);
    Offset p(double x, double y) => c + Offset(x * px, -y * px);
    final pts = [p(0.35, 2.1), p(-0.85, -0.05), p(-0.05, -0.05), p(-0.55, -2.2), p(0.95, 0.35), p(0.15, 0.35), p(0.8, 2.1)];
    final bolt = Path()..addPolygon(pts, true);
    canvas.drawPath(
      bolt,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDE7), Color(0xFFFEF08A), Color(0xFFFACC15)],
        ).createShader(bolt.getBounds()),
    );
    canvas.drawPath(
      bolt,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFCA8A04),
    );
  }

  void _lamp(Canvas canvas, Offset c, double px, _Item it, double t) {
    final bulb = c.translate(0, px);
    if (it.placed && it.dragScale == 1) {
      final ceil = _toDesign(it.x, 13.6, it.z);
      if (ceil.dy < c.dy) {
        canvas.drawLine(
          ceil,
          c.translate(0, -0.25 * px),
          Paint()
            ..color = const Color(0xFF57534E)
            ..strokeWidth = 2.5,
        );
      }
    }
    if (it.active) {
      // SpotLight (angle π/4) pointing down onto the table, kept in the room.
      final floorY = _toDesign(0, -2, -2).dy;
      final mid = _toDesign(0, 0, -5).dx;
      final h = floorY - bulb.dy;
      final cone = Path()
        ..moveTo(bulb.dx - 0.6 * px, bulb.dy)
        ..lineTo(bulb.dx + 0.6 * px, bulb.dy)
        ..lineTo(bulb.dx + h, floorY)
        ..lineTo(bulb.dx - h, floorY)
        ..close();
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(mid + 2, -2000, 4000, floorY + 2));
      canvas.drawPath(
        cone,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFFFF7D6).withValues(alpha: 0.42), const Color(0xFFFFF7D6).withValues(alpha: 0.05)],
          ).createShader(Rect.fromLTRB(0, bulb.dy, 10, floorY)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(bulb.dx, _toDesign(0, 2, -2).dy), width: 7 * px, height: 1.2 * px),
        Paint()
          ..color = const Color(0xFFFFF7D6).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.restore();
      labGlow(canvas, bulb, 3.4 * px, const Color(0xFFFFFBEB), intensity: 0.9);
    }
    // Ceiling base (CylinderGeometry r 1.5, h 0.5).
    labCylinder(canvas, Rect.fromCenter(center: c, width: 3 * px, height: 0.5 * px), const Color(0xFFE2E8F0), tilt: 0.22);
    // Bulb.
    if (it.active) {
      canvas.drawCircle(
        bulb,
        px,
        Paint()
          ..shader = const RadialGradient(colors: [Colors.white, Color(0xFFFFFBEB), Color(0xFFFDE68A)], stops: [0, 0.6, 1])
              .createShader(Rect.fromCircle(center: bulb, radius: px)),
      );
    } else {
      labSphere(canvas, bulb, px, const Color(0xFFE5E7EB), highlight: 0.6, shade: 0.45);
    }
    final fil = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = it.active ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF);
    canvas.drawPath(
      Path()
        ..moveTo(bulb.dx - 0.35 * px, bulb.dy - 0.1 * px)
        ..quadraticBezierTo(bulb.dx, bulb.dy + 0.35 * px, bulb.dx + 0.35 * px, bulb.dy - 0.1 * px),
      fil,
    );
  }

  void _candle(Canvas canvas, Offset c, double px, _Item it, double t) {
    final noise = it.active ? _flick(t, 0.2) : 0.0;
    if (it.active) {
      labGlow(canvas, c.translate(0, -1.3 * px), 5.5 * px * (1 + 0.15 * noise), const Color(0xFFFFAA00), intensity: 0.5);
    }
    final body = Rect.fromLTRB(c.dx - 0.4 * px, c.dy - px, c.dx + 0.4 * px, c.dy + px);
    labCylinder(canvas, body, const Color(0xFFFFFDD0), tilt: 0.35);
    // Wax drip and wick.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(body.left + 0.12 * px, body.top - 0.02 * px, 0.14 * px, 0.45 * px),
        Radius.circular(0.07 * px),
      ),
      Paint()..color = const Color(0xFFFFF8E1),
    );
    canvas.drawLine(
      Offset(c.dx, body.top - 0.05 * px),
      Offset(c.dx, body.top - 0.3 * px),
      Paint()
        ..strokeWidth = math.max(1.2, 0.08 * px)
        ..color = const Color(0xFF292524),
    );
    if (it.active) {
      labFlame(canvas, Offset(c.dx, body.top - 0.12 * px), 0.95 * px * (1 + 0.2 * noise), t);
    }
  }

  void _campfire(Canvas canvas, Offset c, double px, _Item it, double t) {
    final noise = it.active ? _flick(t, 0.3) : 0.0;
    final base = c.translate(0, -0.3 * px);
    if (it.active) {
      labGlow(canvas, base.translate(0, -1.2 * px), 9 * px * (1 + 0.12 * noise), const Color(0xFFFF5500), intensity: 0.55);
      canvas.drawOval(
        Rect.fromCenter(center: c.translate(0, 0.25 * px), width: 8 * px, height: 1.4 * px),
        Paint()
          ..color = const Color(0xFFFF7A1A).withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    // Stones.
    for (var i = 0; i < 7; i++) {
      final x = -1.6 + i * 0.53;
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(x * px, 0.12 * px), width: 0.55 * px, height: 0.35 * px),
        Paint()..color = Color.lerp(const Color(0xFF57534E), const Color(0xFF78716C), (i % 3) / 2)!,
      );
    }
    // Three crossed logs (CylinderGeometry r 0.3, length 3).
    final logPaint = Paint()
      ..strokeWidth = 0.6 * px
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF451A03);
    final ring = Paint()..color = const Color(0xFFB45309);
    for (final a in const [0.32, -0.32]) {
      final d = Offset(math.cos(a), -math.sin(a)) * (1.4 * px);
      canvas.drawLine(base - d, base + d, logPaint);
      canvas.drawCircle(base + d, 0.26 * px, ring);
    }
    canvas.drawCircle(base.translate(0, -0.15 * px), 0.3 * px, Paint()..color = const Color(0xFF451A03));
    canvas.drawCircle(base.translate(0, -0.15 * px), 0.2 * px, ring);
    if (it.active) {
      // Flame (ConeGeometry r 1, h 2, 0xff5500 @ 0.8) with flicker and sparks.
      labFlame(canvas, base.translate(-0.45 * px, 0.05 * px), 1.5 * px * (1 + 0.2 * noise), t + 0.7);
      labFlame(canvas, base.translate(0.45 * px, 0.05 * px), 1.4 * px * (1 - 0.15 * noise), t + 1.9);
      labFlame(canvas, base.translate(0, 0), 2.1 * px * (1 + 0.2 * noise), t);
      final spark = Paint()..color = const Color(0xFFFDBA74);
      for (var i = 0; i < 6; i++) {
        final ph = (t * 0.9 + i / 6) % 1;
        final sx = math.sin(i * 2.3 + t * 2) * 0.8 * px;
        canvas.drawCircle(base + Offset(sx, -(1.5 + ph * 3.5) * px), 1.6 * (1 - ph), spark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LightPainter old) =>
      old.scene != scene || old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
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
